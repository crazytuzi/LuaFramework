require("framework.init")
local OctetsStream = class("OctetsStream")
OctetsStream.baseTypeMarshalFunc = {
  int8 = __NetIO_MarshalInt8,
  uint8 = __NetIO_MarshalUInt8,
  int16 = __NetIO_MarshalInt16,
  uint16 = __NetIO_MarshalUInt16,
  int32 = __NetIO_MarshalInt32,
  uint32 = __NetIO_MarshalUInt32,
  int64 = __NetIO_MarshalInt64,
  uint64 = __NetIO_MarshalUInt64,
  float = __NetIO_MarshalFloat,
  string = __NetIO_MarshalString,
  octets = __NetIO_MarshalOctets
}
OctetsStream.complexTypeMarshalFunc = {}
function OctetsStream.registerComplexTypeMarshalFunc(tName, func)
  local orig = OctetsStream.complexTypeMarshalFunc[tName]
  if not orig then
    OctetsStream.complexTypeMarshalFunc[tName] = func
  else
    print("*LUA* OctetsStream.registerComplexTypeMarshalFunc exist " .. tName)
  end
end
local safeUnmarshalString = function(nativeos)
  if not nativeos then
    return nil
  end
  local utf16string = __NetIO_UnmarshalStringFromOctets(nativeos)
  if not utf16string or string.len(utf16string) == 0 then
    return ""
  end
  local ret = GameUtil.UnicodeToUtf8(utf16string)
  return ret
end
OctetsStream.baseTypeUnmarshalFunc = {
  int8 = __NetIO_UnmarshalInt8,
  uint8 = __NetIO_UnmarshalUInt8,
  int16 = __NetIO_UnmarshalInt16,
  uint16 = __NetIO_UnmarshalUInt16,
  int32 = __NetIO_UnmarshalInt32,
  uint32 = __NetIO_UnmarshalUInt32,
  int64 = __NetIO_UnmarshalInt64,
  uint64 = __NetIO_UnmarshalUInt64,
  float = __NetIO_UnmarshalFloat,
  string = safeUnmarshalString,
  octets = __NetIO_UnmarshalOctets
}
OctetsStream.complexTypeUnmarshalFunc = {}
function OctetsStream.registerComplexTypeUnmarshalFunc(tName, func)
  local orig = OctetsStream.complexTypeUnmarshalFunc[tName]
  if not orig then
    OctetsStream.complexTypeUnmarshalFunc[tName] = func
  else
    print("*LUA* OctetsStream.registerComplexTypeUnmarshalFunc exist " .. tName)
  end
end
OctetsStream.vectorMarshalToOctetsFunc = {
  int8 = __NetIO_MarshalTableInt8ToOctets,
  uint8 = __NetIO_MarshalTableUInt8ToOctets,
  int16 = __NetIO_MarshalTableInt16ToOctets,
  uint16 = __NetIO_MarshalTableUInt16ToOctets,
  int32 = __NetIO_MarshalTableInt32ToOctets,
  uint32 = __NetIO_MarshalTableUInt32ToOctets,
  int64 = __NetIO_MarshalTableInt64ToOctets,
  uint64 = __NetIO_MarshalTableUInt64ToOctets,
  float = __NetIO_MarshalTableFloatToOctets,
  string = __NetIO_MarshalTableStringToOctets
}
OctetsStream.vectorUnmarshalFromOctetsFunc = {
  int8 = __NetIO_UnmarshalTableInt8FromOctets,
  uint8 = __NetIO_UnmarshalTableUInt8FromOctets,
  int16 = __NetIO_UnmarshalTableInt16FromOctets,
  uint16 = __NetIO_UnmarshalTableUInt16FromOctets,
  int32 = __NetIO_UnmarshalTableInt32FromOctets,
  uint32 = __NetIO_UnmarshalTableUInt32FromOctets,
  int64 = __NetIO_UnmarshalTableInt64FromOctets,
  uint64 = __NetIO_UnmarshalTableUInt64FromOctets,
  float = __NetIO_UnmarshalTableFloatFromOctets,
  string = __NetIO_UnmarshalTableStringFromOctets
}
function OctetsStream.beginRecvStream()
  local nativeos = __NetIO_RecvBegin()
  if nativeos then
    return OctetsStream.new(nativeos)
  else
    return nil
  end
end
function OctetsStream.endRecvStream(os)
  __NetIO_RecvEnd(os.nativeos)
end
function OctetsStream.beginSendStream()
  local nativeos = __NetIO_SendBegin()
  if nativeos then
    return OctetsStream.new(nativeos)
  else
    return nil
  end
end
function OctetsStream.SendStreamSize(os)
  return __NetIO_SendSize(os.nativeos)
end
function OctetsStream.SendStream(os)
  __NetIO_Send(os.nativeos)
end
function OctetsStream.endSendStream(os)
  __NetIO_SendEnd(os.nativeos)
end
function OctetsStream.beginTempStream()
  local key, nativeos = __NetIO_TempOctetsBegin()
  local os
  if nativeos then
    os = OctetsStream.new(nativeos)
  end
  return key, os
end
function OctetsStream.endTempStream(key)
  __NetIO_TempOctetsEnd(key)
end
function OctetsStream.beginWrapWithOctets(octets)
  local key, nativeos = __NetIO_WrapOctetsStreamWithOctetsBegin(octets)
  local os
  if nativeos then
    os = OctetsStream.new(nativeos)
  end
  return key, os
end
function OctetsStream.getOctetsSize(octets)
  local key, nativeos = __NetIO_WrapOctetsStreamWithOctetsBegin(octets)
  local size = 0
  if nativeos then
    size = __NetIO_GetSize(nativeos)
  end
  __NetIO_WrapOctetsStreamWithOctetsEnd(key)
  return size
end
function OctetsStream.endWrapWithOctets(key)
  __NetIO_WrapOctetsStreamWithOctetsEnd(key)
end
function OctetsStream:ctor(nativeos)
  self.nativeos = nativeos or nil
end
function OctetsStream:marshalCompactUInt32(value)
  if self.nativeos then
    __NetIO_MarshalCompactUInt32(self.nativeos, value)
  end
end
function OctetsStream:marshalInt8(value)
  if self.nativeos then
    __NetIO_MarshalInt8(self.nativeos, value)
  end
end
function OctetsStream:marshalUInt8(value)
  if self.nativeos then
    __NetIO_MarshalUInt8(self.nativeos, value)
  end
end
function OctetsStream:marshalInt16(value)
  if self.nativeos then
    __NetIO_MarshalInt16(self.nativeos, value)
  end
end
function OctetsStream:marshalUInt16(value)
  if self.nativeos then
    __NetIO_MarshalUInt16(self.nativeos, value)
  end
end
function OctetsStream:marshalInt32(value)
  if self.nativeos then
    __NetIO_MarshalInt32(self.nativeos, value)
  end
end
function OctetsStream:marshalUInt32(value)
  if self.nativeos then
    __NetIO_MarshalUInt32(self.nativeos, value)
  end
end
function OctetsStream:marshalInt64(value)
  if self.nativeos then
    __NetIO_MarshalInt64(self.nativeos, value)
  end
end
function OctetsStream:marshalUInt64(value)
  if self.nativeos then
    __NetIO_MarshalUInt64(self.nativeos, value)
  end
end
function OctetsStream:marshalFloat(value)
  if self.nativeos then
    __NetIO_MarshalFloat(self.nativeos, value)
  end
end
function OctetsStream:marshalString(str)
  if self.nativeos then
    __NetIO_MarshalString(self.nativeos, str)
  end
end
function OctetsStream:marshalOctets(data)
  if self.nativeos then
    __NetIO_MarshalOctets(self.nativeos, data)
  end
end
function OctetsStream:marshalVector(tbl, tName)
  if self.nativeos and tbl and #tbl ~= 0 then
    local os = self.nativeos
    local marshalFunc = OctetsStream.baseTypeMarshalFunc[tName]
    if not marshalFunc then
      os = self
      marshalFunc = OctetsStream.complexTypeMarshalFunc[tName]
      if not marshalFunc then
        return
      end
    end
    self:marshalCompactUInt32(#tbl)
    for k, v in pairs(tbl) do
      marshalFunc(os, v)
    end
  end
end
function OctetsStream:marshalMap(tbl, ktName, vtName)
  if self.nativeos and tbl then
    local kos = self.nativeos
    local vos = self.nativeos
    local marshalKeyFunc = OctetsStream.baseTypeMarshalFunc[ktName]
    if not marshalKeyFunc then
      kos = self
      marshalKeyFunc = OctetsStream.complexTypeMarshalFunc[ktName]
      if not marshalKeyFunc then
        return
      end
    end
    local marshalValueFunc = OctetsStream.baseTypeMarshalFunc[vtName]
    if not marshalValueFunc then
      vos = self
      marshalValueFunc = OctetsStream.complexTypeMarshalFunc[vtName]
      if not marshalValueFunc then
        return
      end
    end
    local tsize = 0
    for k, v in pairs(tbl) do
      tsize = tsize + 1
    end
    self:marshalCompactUInt32(tsize)
    for k, v in pairs(tbl) do
      marshalKeyFunc(kos, k)
      marshalValueFunc(vos, v)
    end
  end
end
function OctetsStream:unmarshalCompactInt32()
  if self.nativeos then
    return __NetIO_UnmarshalCompactInt32(self.nativeos)
  end
  return nil
end
function OctetsStream:unmarshalCompactUInt32()
  if self.nativeos then
    return __NetIO_UnmarshalCompactUInt32(self.nativeos)
  end
  return nil
end
function OctetsStream:unmarshalInt8()
  if self.nativeos then
    return __NetIO_UnmarshalInt8(self.nativeos)
  end
  return nil
end
function OctetsStream:unmarshalUInt8()
  if self.nativeos then
    return __NetIO_UnmarshalUInt8(self.nativeos)
  end
  return nil
end
function OctetsStream:unmarshalInt16()
  if self.nativeos then
    return __NetIO_UnmarshalInt16(self.nativeos)
  end
  return nil
end
function OctetsStream:unmarshalUInt16()
  if self.nativeos then
    return __NetIO_UnmarshalUInt16(self.nativeos)
  end
  return nil
end
function OctetsStream:unmarshalInt32()
  if self.nativeos then
    return __NetIO_UnmarshalInt32(self.nativeos)
  end
  return nil
end
function OctetsStream:unmarshalUInt32()
  if self.nativeos then
    return __NetIO_UnmarshalUInt32(self.nativeos)
  end
  return nil
end
function OctetsStream:unmarshalInt64()
  if self.nativeos then
    return __NetIO_UnmarshalInt64(self.nativeos)
  end
  return nil
end
function OctetsStream:unmarshalUInt64()
  if self.nativeos then
    return __NetIO_UnmarshalUInt64(self.nativeos)
  end
  return nil
end
function OctetsStream:unmarshalFloat()
  if self.nativeos then
    return __NetIO_UnmarshalFloat(self.nativeos)
  end
  return nil
end
function OctetsStream:unmarshalString()
  return safeUnmarshalString(self.nativeos)
end
function OctetsStream:unmarshalOctets()
  if self.nativeos then
    return __NetIO_UnmarshalOctets(self.nativeos)
  end
  return nil
end
function OctetsStream:unmarshalVector(tName)
  local tbl = {}
  if self.nativeos then
    local os = self.nativeos
    local unmarshalFunc = OctetsStream.baseTypeUnmarshalFunc[tName]
    if not unmarshalFunc then
      os = self
      unmarshalFunc = OctetsStream.complexTypeUnmarshalFunc[tName]
      if not unmarshalFunc then
        return tbl
      end
    end
    local tsize = self:unmarshalCompactUInt32()
    for i = 1, tsize do
      local v = unmarshalFunc(os)
      tbl[i] = v
    end
  end
  return tbl
end
function OctetsStream:unmarshalMap(ktName, vtName)
  local tbl = {}
  if self.nativeos then
    local kos = self.nativeos
    local vos = self.nativeos
    local unmarshalKeyFunc = OctetsStream.baseTypeUnmarshalFunc[ktName]
    if not unmarshalKeyFunc then
      kos = self
      unmarshalKeyFunc = OctetsStream.complexTypeUnmarshalFunc[ktName]
      if not unmarshalKeyFunc then
        return tbl
      end
    end
    local unmarshalValueFunc = OctetsStream.baseTypeUnmarshalFunc[vtName]
    if not unmarshalValueFunc then
      vos = self
      unmarshalValueFunc = OctetsStream.complexTypeUnmarshalFunc[vtName]
      if not unmarshalValueFunc then
        return tbl
      end
    end
    local tsize = self:unmarshalCompactUInt32()
    for i = 1, tsize do
      local k = unmarshalKeyFunc(kos)
      local v = unmarshalValueFunc(vos)
      tbl[k] = v
    end
  end
  return tbl
end
function OctetsStream:marshalStringToOctets(str)
  if self.nativeos then
    __NetIO_MarshalStringToOctets(self.nativeos, str)
  end
end
function OctetsStream:marshalVectorToOctets(tbl, tName)
  if self.nativeos and tbl and #tbl ~= 0 then
    local marshalFunc = OctetsStream.vectorMarshalToOctetsFunc[tName]
    if marshalFunc then
      marshalFunc(self.nativeos, tbl)
    end
  end
end
function OctetsStream:marshalMapToOctets(tbl, ktName, vtName)
  if self.nativeos then
  end
end
function OctetsStream:unmarshalStringFromOctets()
  if self.nativeos then
    return __NetIO_UnmarshalStringFromOctets(self.nativeos)
  end
  return nil
end
function OctetsStream:unmarshalVectorFromOctets(tName)
  local tbl = {}
  if self.nativeos then
    local unmarshalFunc = OctetsStream.vectorUnmarshalFromOctetsFunc[tName]
    if unmarshalFunc then
      tbl = unmarshalFunc(self.nativeos)
    end
  end
  return tbl
end
function OctetsStream:unmarshalMapFromOctets(ktName, vtName)
  if self.nativeos then
  end
end
function OctetsStream:getData()
  if self.nativeos then
    return __NetIO_GetOctetsStreamData(self.nativeos)
  end
  return nil
end
return OctetsStream
