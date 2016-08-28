#pragma once
#ifndef ARRAY_TRACER_HPP
#define ARRAY_TRACER_HPP

#include <cassert>
#include <iostream>
#include <type_traits>
#include <unordered_map>
#include <vector>

class MemoryTracer {
public:
  void getFrame(size_t ad) {
    if (arrayEnded)
      return;

    if (newArray) {
      current0 = ad;
      newArray = false;
    }

    addressToOffset.emplace(ad, offset + ad - current0);
  };

  void postAccess(size_t ad) {
    if (!acAuth)
      return;

    accesses.push_back(addressToOffset.find(ad)->second);
    acAuth = false;
  };

  ~MemoryTracer() {
    for (auto &a : accesses) {
      std::cout << std::hex << a << std::endl;
    }
  };

  void startNewArray(size_t size) {
    newArray = true;
    offset += oldSize;
    oldSize = size;
    arrayEnded = false;
  };

  void endArray() { arrayEnded = true; };

  void authAc() { acAuth = true; }

private:
  std::vector<size_t> accesses;
  size_t offset = 0;
  std::unordered_map<size_t, size_t> addressToOffset;
  bool newArray = false, arrayEnded = true, acAuth = false;
  ;
  size_t oldSize = 0;
  size_t current0 = 0;
};

MemoryTracer __memTracer;

template <typename A> class TracedArray {
public:
  template <typename... Targs>
  TracedArray(Targs... args) : num_args{sizeof...(Targs)} {
    _constructorHelper(args...);

    for (auto &d : dimensions)
      size *= d;

    for (int i = 0; i < dimensions.size(); ++i) {
      size_t mult = 1;
      for (int j = i + 1; j < dimensions.size(); ++j) {
        mult *= dimensions[j];
      }
      factors.push_back(mult);
    }

    __memTracer.startNewArray(size);
    array = new A[size / sizeof(A)];

    if (std::is_fundamental<A>())
      for (size_t i = 0; i < size / sizeof(A); ++i)
        __memTracer.getFrame((size_t)(array + i));

    __memTracer.endArray();
  };

  template <typename... Targs> A &operator()(Targs... args) {
    assert("Not the correct number of arguements!" &&
           sizeof...(Targs) == num_args);

    size_t offset = _accHelper(0, args...);

    __memTracer.authAc();
    if (std::is_fundamental<A>())
      __memTracer.postAccess((size_t)(array + offset));

    return array[offset];
  };

  ~TracedArray() { delete[] array; }

private:
  const int num_args;
  size_t size = sizeof(A);
  std::vector<int> dimensions;
  std::vector<size_t> factors;
  A *array;

  template <typename T, typename... Targs>
  void _constructorHelper(T &first, Targs &... args) {
    dimensions.push_back(first);
    _constructorHelper(args...);
  };

  template <typename T> void _constructorHelper(T &last) {
    dimensions.push_back(last);
  };

  template <typename T, typename... Targs>
  size_t _accHelper(int level, T &first, Targs &... args) {
    return first * factors[level] + _accHelper(level + 1, args...);
  }

  template <typename T> size_t _accHelper(int level, T &last) {
    return factors[level] * last;
  }
};

template <class A> class StructHelper {
public:
  StructHelper() { __memTracer.getFrame((size_t)this); };

  template <typename T> StructHelper &operator=(T e) {
    __memTracer.postAccess((size_t)this);
    _item = e;
    return *this;
  };

  template <typename T> StructHelper &operator=(StructHelper<T> &o) {
    __memTracer.postAccess((size_t)&o);
    __memTracer.postAccess((size_t)this);
    _item = o._item;
    return *this;
  };

  template <typename T> operator T() {
    __memTracer.postAccess((size_t)this);
    return static_cast<T>(_item);
  };

private:
  A _item;
};

#endif // ARRAY_TRACER_HPP
