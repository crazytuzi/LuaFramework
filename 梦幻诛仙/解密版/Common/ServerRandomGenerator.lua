local ServerRandomGenerator = {}
local MULTIPLIER = 33797
local ADDEND = 1
local MASK = 4294967295
local MAXINT = 2147483648
local function to_int(v)
  return bit.band(v, MASK)
end
function ServerRandomGenerator.make_srg(s)
  local seed = bit.band(bit.bxor(s, MULTIPLIER), MASK)
  local function next(b)
    local old_seed = seed
    local next_seed = bit.band(old_seed * MULTIPLIER + ADDEND, MASK)
    seed = next_seed
    return to_int(bit.rshift(next_seed, 32 - b))
  end
  return function(genType, limit)
    if genType == "int" then
      if limit then
        if limit > 0 then
          if bit.band(limit, -limit) == limit then
            return (Int64.new(limit * next(31)) / Int64.new(MAXINT)):ToNumber()
          end
          local bits, val = 0, 0
          local detect = 0
          repeat
            bits = next(31)
            val = bits % limit
            detect = bits - val + limit - 1
          until detect >= 0 and detect <= MAXINT
          return val
        else
          return 0
        end
      else
        return next(32)
      end
    else
      return nil
    end
  end
end
return ServerRandomGenerator
