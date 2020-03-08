local ByteArrayVarint = class("BitVaiant", import(".ByteArray"))
require("bit")
function ByteArrayVarint:ctor(__endian)
  self._endian = __endian
  self._buf = {}
  self._pos = 1
end
function ByteArrayVarint:readVInt()
  local __v = self:_decodeVarint()
  return self:_zigZagDecode(__v)
end
function ByteArrayVarint:writeVInt(__vint)
  local __v = self:_zigZagEncode(__vint)
  self:_encodeVarint(__v)
  return self
end
function ByteArrayVarint:readUVInt()
  return self:_decodeVarint()
end
function ByteArrayVarint:writeUVInt(__uvint)
  self:_encodeVarint(__uvint)
  return self
end
function ByteArrayVarint:readStringUVInt()
  local __len = self:readUVInt()
  return self:readStringBytes(__len)
end
function ByteArrayVarint:writeStringUVInt(__str)
  self:writeUVInt(#__str)
  self:writeStringBytes(__str)
  return self
end
function ByteArrayVarint:_zigZagEncode(__value)
  if __value >= 0 then
    return bit.lshift(__value, 1)
  end
  return bit.bxor(bit.lshift(__value, 1), bit.bnot(0))
end
function ByteArrayVarint:_zigZagDecode(__value)
  if bit.band(__value, 1) == 0 then
    return bit.rshift(__value, 1)
  end
  return bit.bxor(bit.rshift(__value, 1), bit.bnot(0))
end
function ByteArrayVarint:_encodeVarint(__value)
  assert(type(__value) == "number", "Value to encode must be a number!")
  local __bytes = bit.band(__value, 127)
  __value = bit.rshift(__value, 7)
  while __value ~= 0 do
    self:writeByte(bit.bor(128, __bytes))
    __bytes = bit.band(__value, 127)
    __value = bit.rshift(__value, 7)
  end
  self:writeByte(__bytes)
end
function ByteArrayVarint:_decodeVarint()
  local __result = 0
  local __shift = 0
  local __byte
  while self._pos <= #self._buf do
    __byte = self:readByte()
    __result = bit.bor(__result, bit.lshift(bit.band(__byte, 127), __shift))
    if bit.band(__byte, 128) == 0 then
      return __result
    end
    __shift = __shift + 7
    assert(__shift < 32, "Varint decode error! 32bit bitwise is unavailable in BitOp!")
  end
  error("Read variant at EOF!")
end
return ByteArrayVarint
