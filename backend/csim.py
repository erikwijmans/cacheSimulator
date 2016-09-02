#! /usr/bin/env python3
from enum import Enum
from json import dumps

ACC_TYPE = Enum("ACC_TYPE", "hit miss evict")
TRACE_TYPE = Enum("TRACE_TYPE", "auto valgrid")

class CSim:
  def __init__(self, s, E, b, mem_bits, trace=None, style=TRACE_TYPE.auto):
    self.s, self.E, self.b, self.mem_bits, self.style = s, E, b, mem_bits, style

    self.num_sets = 1 << s
    self.tag_offset = s + b
    self.set_offset = b
    self.set_mask = ((1 << s) - 1)
    self.hits = 0
    self.misses = 0
    self.evicts = 0

    self.mem = []

    for i in range(self.num_sets*self.E):
      self.mem.append(
        {
          'tag': 0,
          'u': 0,
          'valid': False
        }
      )

    self.time = 0
    self.res = []

    if trace is not None:
      for t in trace:
        self.simulate(t)

  def __post_res(self, address, block, tag, set_index, acc_type):
    self.res.append(
      {
        'address': address,
        'block': block,
        'acc_type': acc_type.value,
        'tag': tag,
        'set': set_index
      }
    )

    if acc_type == ACC_TYPE.hit:
      self.hits += 1
    else:
      self.misses += 1
      if acc_type == ACC_TYPE.evict:
        self.evicts += 1

  def get_res(self):
    return {
      'trace':self.res,
      'hits': self.hits,
      'misses': self.misses,
      'evicts': self.evicts,
      'miss_rate': "{:1.3f}".format(float(self.misses)/(self.hits + self.misses))
    }

  def simulate(self, line):
    self.time += 1

    address = 0
    valgrind_type = "S"
    if self.style == TRACE_TYPE.valgrid.value:
      if line[1] != "L" and line[1] != "M" and line[1] != "S":
        return

      line = line.split(",")[0].strip()
      tmp = line.split(" ")

      valgrind_type = tmp[0]
      address = int(tmp[1], 16)
    else:
      address = int(line, 16)

    tag = address >> self.tag_offset
    set_index = (address >> self.set_offset) & self.set_mask
    willEvict = True

    for i in range(self.E):
      if not self.mem[self.E*set_index + i]['valid']:
        self.mem[self.E*set_index + i] = {
          'tag': tag,
          'u': self.time,
          'valid': True
        }

        self.__post_res(address, self.E*set_index + i, tag, set_index, ACC_TYPE.miss)
        willEvict = False
        break
      elif self.mem[self.E*set_index + i]['tag'] == tag:
        self.mem[self.E*set_index + i]['u'] = self.time

        self.__post_res(address, self.E*set_index + i, tag, set_index, ACC_TYPE.hit)
        willEvict = False
        break

    if willEvict:
      lru = int(1e9)
      block = 0

      for i in range(self.E):
        if self.mem[self.E*set_index + i]['u'] < lru:
          block = self.E*set_index + i
          lru = self.mem[block]['u']


      self.mem[block]['u'] = self.time
      self.mem[block]['tag'] = tag
      self.__post_res(address, block, tag, set_index, ACC_TYPE.evict)

    if valgrind_type == 'M':
      self.__post_res(address, self.E*set_index + i, tag, set_index, ACC_TYPE.hit)


if __name__ == '__main__':

  with open('/Users/erikwijmans/School/cse361s/erikwijmans/lab4/traces/dave.trace', 'r') as file:
    data = [line for line in file.read().split("\n") if len(line) != 0]


  sim = CSim(2, 2, 2, 64, data)
  print(dumps(sim.get_res()))