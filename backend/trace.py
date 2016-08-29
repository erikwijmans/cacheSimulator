#/usr/bin/env python3

import re, sys, subprocess, shlex, glob
from random import randint, seed

array_finder = re.compile("[\[\]]+", re.IGNORECASE)
struct_dec_finder = re.compile("struct[\d\D]*{", re.IGNORECASE)
mod_tpyes = set('unsigned signed volatile register struct'.split(" "))

def get_type(line):
  t = ""
  for item in [l.strip() for l in line.split(" ") if not l.isspace() and len(l) > 0]:
    if item in mod_tpyes:
      t += "{} ".format(item)
    else:
      return (t + item).strip()

def handle_struct(source_code):
  out = []
  tmp = ""
  for s in source_code:
    if len(tmp) == 0 and struct_dec_finder.search(s) is None:
      out.append(s)
    else:
      if s.find("}") != -1:
        tmp += s
        out.append(tmp)
        tmp = ""
      else:
        tmp += "{};".format(s)

  first = out
  out = []
  for cur in first:
    if struct_dec_finder.search(cur) is not None and array_finder.search(cur) is not None:
      tmp = cur.split("}")
      name = randint(0, sys.maxsize)
      out.append("\n typedef " + tmp[0].replace("\n", "") + "} s" + str(name))
      out.append("\ns{} {}".format(name, tmp[1]))
    else:
      out.append(cur)


  return out

class Tracer:
  def __init__(self, source, working_dir="."):
    self.error = False
    self.prefix = ""
    if __name__ != "__main__":
      self.prefix = "/".join((__name__.split(".")[:-1])) + "/"

    seed()
    self.fileno = "{}/{}".format(working_dir, randint(0, sys.maxsize))
    if not self.__check_syntax(source):
      return

    source = self.__frmt(source)


    source_code = source.split(";")
    source_code = handle_struct(source_code)


    for i, line in enumerate(source_code):
      if array_finder.search(line) is not None:
        line = line.replace("][", ",")
        line = line.replace("[", "(")
        line = line.replace("]", ")")

        if line.find("=") == -1:
          t = get_type(line)
          if t is not None:
            line = line.replace(t, "TracedArray<{}>".format(t))

      elif struct_dec_finder.search(line) is not None:
        tmp = line.split("{")
        tmp = [tmp[0]] + tmp[1].split("}")
        decs = tmp[1].split(";")
        for j, dec in enumerate(decs):
          t = get_type(dec)
          if t is not None:
            decs[j] = dec.replace(t, "StructHelper<{}>".format(t))

        line = tmp[0] + " { " + ";".join(decs) + "} " + tmp[2]

      source_code[i] = line


    source = '''#include "''' + self.prefix + '''ArrayTracer.hpp"
int main(int argc, char** argv) {''' \
      + ";".join(source_code) + '''  return 0;
}'''

    with open("{}.cpp".format(self.fileno), "w") as file:
      file.write(source)
      file.close()

    subprocess.check_call(shlex.split("g++ -std=gnu++11 -g -O3 -o {} {}.cpp".format(self.fileno, self.fileno)))

    with open("{}.trace".format(self.fileno), "w") as outfile:
      subprocess.check_call(shlex.split("{}".format(self.fileno)), stdout=outfile)


    with open("{}.trace".format(self.fileno)) as file:
      self.trace = [l for l in file.read().split("\n") if len(l) > 0]

    self.__clean()

  def __clean(self):
    subprocess.check_call(shlex.split("rm -rf") + glob.glob("{}*".format(self.fileno)))

  def get_res(self):
    return {
      'error': self.error,
      'msg': self.trace
    }

  def __check_syntax(self, code):
    source = "int main() {" + code + " return 0;}"
    source = self.__frmt(source)
    with open("{}.c".format(self.fileno), "w") as file:
      file.write(source)
      file.close()

    with open("{}.err".format(self.fileno), "w") as file:
      exit = subprocess.call(shlex.split("gcc -fsyntax-only -std=std=gnu99 -Wall {}.c".format(self.fileno)), stderr=file)

    if exit != 0:
      with open("{}.err".format(self.fileno), "r") as file:
        msg = file.read()
        self.__clean()
        self.trace = msg.replace(str(self.fileno), "input")
        self.error = True

    return exit == 0

  def __frmt(self, code):
    with open("{}.cpp".format(self.fileno), "w") as file:
      file.write(code)
      file.close()

    with open("{}.frmt".format(self.fileno), "w") as file:
      subprocess.check_call(shlex.split("clang-format {}.cpp".format(self.fileno)), stdout=file)

    with open("{}.frmt".format(self.fileno), "r") as file:
      return file.read()

if __name__ == '__main__':
  t = Tracer("""struct pixel_t{
    unsigned char r;
    unsigned char g;
    unsigned char b;
    unsigned char a;
};

struct pixel_t pixel[16][16];
register int i, j;
int x;
for (i = 0; i < 16; i ++){
    for (j = 0; j < 16; j ++){
        x = pixel[j][i].r;
        pixel[j][i].g = 0;
        pixel[j][i].b = 0;
        pixel[j][i].a = 0;
} }""")

  print(t.get_res())