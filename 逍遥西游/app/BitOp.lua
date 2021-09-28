ZZMathBit = {}
function ZZMathBit.__andBit(left, right)
  return left == 1 and right == 1 and 1 or 0
end
function ZZMathBit.__orBit(left, right)
  return (left == 1 or right == 1) and 1 or 0
end
function ZZMathBit.__xorBit(left, right)
  return left + right == 1 and 1 or 0
end
function ZZMathBit.__base(left, right, op)
  if left < right then
    left, right = right, left
  end
  local res = 0
  local shift = 1
  while left ~= 0 do
    local ra = left % 2
    local rb = right % 2
    res = shift * op(ra, rb) + res
    shift = shift * 2
    left = math.modf(left / 2)
    right = math.modf(right / 2)
  end
  return res
end
function ZZMathBit.andOp(left, right)
  return ZZMathBit.__base(left, right, ZZMathBit.__andBit)
end
function ZZMathBit.xorOp(left, right)
  return ZZMathBit.__base(left, right, ZZMathBit.__xorBit)
end
function ZZMathBit.orOp(left, right)
  return ZZMathBit.__base(left, right, ZZMathBit.__orBit)
end
function ZZMathBit.notOp(left)
  return left > 0 and -(left + 1) or -left - 1
end
function ZZMathBit.lShiftOp(left, num)
  return left * 2 ^ num
end
function ZZMathBit.rShiftOp(left, num)
  return math.floor(left / 2 ^ num)
end
