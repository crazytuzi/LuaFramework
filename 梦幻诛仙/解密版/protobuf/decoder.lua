local string = string
local table = table
local assert = assert
local ipairs = ipairs
local error = error
local pb = require("pb")
local encoder = require("protobuf.encoder")
local wire_format = require("protobuf.wire_format")
local descriptor = require("protobuf.descriptor")
local FieldDescriptor = descriptor.FieldDescriptor
module("protobuf.decoder")
local _DecodeVarint = pb.varint_decoder
local _DecodeSignedVarint = pb.signed_varint_decoder
local _DecodeVarint32 = pb.varint_decoder
local _DecodeSignedVarint32 = pb.signed_varint_decoder
ReadTag = pb.read_tag
local function _SimpleDecoder(field_type, wire_type, decode_value)
  return function(field_number, is_repeated, is_packed, key, new_default)
    if is_packed then
      do
        local DecodeVarint = _DecodeVarint
        return function(buffer, pos, pend, message, field_dict)
          local value = field_dict[key]
          if value == nil then
            value = new_default(message)
            field_dict[key] = value
          end
          local endpoint
          endpoint, pos = DecodeVarint(buffer, pos, field_type)
          endpoint = endpoint + pos
          if pend < endpoint then
            error("Truncated message.")
          end
          local element
          while pos < endpoint do
            element, pos = decode_value(buffer, pos, field_type)
            value[#value + 1] = element
          end
          if endpoint < pos then
            value:remove(#value)
            error("Packed element was truncated.")
          end
          return pos
        end
      end
    elseif is_repeated then
      do
        local tag_bytes = encoder.TagBytes(field_number, wire_type)
        local tag_len = #tag_bytes
        local sub = string.sub
        return function(buffer, pos, pend, message, field_dict)
          local value = field_dict[key]
          if value == nil then
            value = new_default(message)
            field_dict[key] = value
          end
          while true do
            local element, new_pos = decode_value(buffer, pos, field_type)
            value:append(element)
            pos = new_pos + tag_len
            if sub(buffer, new_pos + 1, pos) ~= tag_bytes or pend <= new_pos then
              if pend < new_pos then
                error("Truncated message.")
              end
              return new_pos
            end
          end
        end
      end
    else
      return function(buffer, pos, pend, message, field_dict)
        field_dict[key], pos = decode_value(buffer, pos, field_type)
        if pend < pos then
          field_dict[key] = nil
          error("Truncated message.")
        end
        return pos
      end
    end
  end
end
local function _ModifiedDecoder(field_type, wire_type, decode_value, modify_value)
  local function InnerDecode(buffer, pos)
    local result, new_pos = decode_value(buffer, pos, field_type)
    return modify_value(result), new_pos
  end
  return _SimpleDecoder(field_type, wire_type, InnerDecode)
end
local function _StructPackDecoder(wire_type, value_size, format)
  local struct_unpack = pb.struct_unpack
  function InnerDecode(buffer, pos)
    local new_pos = pos + value_size
    local result = struct_unpack(format, buffer, pos)
    return result, new_pos
  end
  return _SimpleDecoder(FieldDescriptor.TYPE_INT32, wire_type, InnerDecode)
end
local _Boolean = function(value)
  return value ~= 0
end
Int32Decoder = _SimpleDecoder(FieldDescriptor.CPPTYPE_INT32, wire_format.WIRETYPE_VARINT, _DecodeSignedVarint32)
EnumDecoder = Int32Decoder
Int64Decoder = _SimpleDecoder(FieldDescriptor.CPPTYPE_INT64, wire_format.WIRETYPE_VARINT, _DecodeSignedVarint)
UInt32Decoder = _SimpleDecoder(FieldDescriptor.CPPTYPE_UINT32, wire_format.WIRETYPE_VARINT, _DecodeVarint32)
UInt64Decoder = _SimpleDecoder(FieldDescriptor.CPPTYPE_UINT64, wire_format.WIRETYPE_VARINT, _DecodeVarint)
SInt32Decoder = _ModifiedDecoder(FieldDescriptor.CPPTYPE_INT32, wire_format.WIRETYPE_VARINT, _DecodeVarint32, wire_format.ZigZagDecode32)
SInt64Decoder = _ModifiedDecoder(FieldDescriptor.CPPTYPE_INT64, wire_format.WIRETYPE_VARINT, _DecodeVarint, wire_format.ZigZagDecode64)
Fixed32Decoder = _StructPackDecoder(wire_format.WIRETYPE_FIXED32, 4, string.byte("I"))
Fixed64Decoder = _StructPackDecoder(wire_format.WIRETYPE_FIXED64, 8, string.byte("Q"))
SFixed32Decoder = _StructPackDecoder(wire_format.WIRETYPE_FIXED32, 4, string.byte("i"))
SFixed64Decoder = _StructPackDecoder(wire_format.WIRETYPE_FIXED64, 8, string.byte("q"))
FloatDecoder = _StructPackDecoder(wire_format.WIRETYPE_FIXED32, 4, string.byte("f"))
DoubleDecoder = _StructPackDecoder(wire_format.WIRETYPE_FIXED64, 8, string.byte("d"))
BoolDecoder = _ModifiedDecoder(FieldDescriptor.CPPTYPE_BOOL, wire_format.WIRETYPE_VARINT, _DecodeVarint, _Boolean)
function StringDecoder(field_number, is_repeated, is_packed, key, new_default)
  local DecodeVarint = _DecodeVarint
  local sub = string.sub
  assert(not is_packed)
  if is_repeated then
    do
      local tag_bytes = encoder.TagBytes(field_number, wire_format.WIRETYPE_LENGTH_DELIMITED)
      local tag_len = #tag_bytes
      return function(buffer, pos, pend, message, field_dict)
        local value = field_dict[key]
        if value == nil then
          value = new_default(message)
          field_dict[key] = value
        end
        while true do
          local size, new_pos
          size, pos = DecodeVarint(buffer, pos, FieldDescriptor.CPPTYPE_INT32)
          new_pos = pos + size
          if pend < new_pos then
            error("Truncated string.")
          end
          value:append(sub(buffer, pos + 1, new_pos))
          pos = new_pos + tag_len
          if sub(buffer, new_pos + 1, pos) ~= tag_bytes or new_pos == pend then
            return new_pos
          end
        end
      end
    end
  else
    return function(buffer, pos, pend, message, field_dict)
      local size, new_pos
      size, pos = DecodeVarint(buffer, pos, FieldDescriptor.CPPTYPE_INT32)
      new_pos = pos + size
      if pend < new_pos then
        error("Truncated string.")
      end
      field_dict[key] = sub(buffer, pos + 1, new_pos)
      return new_pos
    end
  end
end
function BytesDecoder(field_number, is_repeated, is_packed, key, new_default)
  local DecodeVarint = _DecodeVarint
  local sub = string.sub
  assert(not is_packed)
  if is_repeated then
    do
      local tag_bytes = encoder.TagBytes(field_number, wire_format.WIRETYPE_LENGTH_DELIMITED)
      local tag_len = #tag_bytes
      return function(buffer, pos, pend, message, field_dict)
        local value = field_dict[key]
        if value == nil then
          value = new_default(message)
          field_dict[key] = value
        end
        while true do
          local size, new_pos
          size, pos = DecodeVarint(buffer, pos, FieldDescriptor.CPPTYPE_INT32)
          new_pos = pos + size
          if pend < new_pos then
            error("Truncated string.")
          end
          value:append(sub(buffer, pos + 1, new_pos))
          pos = new_pos + tag_len
          if sub(buffer, new_pos + 1, pos) ~= tag_bytes or new_pos == pend then
            return new_pos
          end
        end
      end
    end
  else
    return function(buffer, pos, pend, message, field_dict)
      local size, new_pos
      size, pos = DecodeVarint(buffer, pos, FieldDescriptor.CPPTYPE_INT32)
      new_pos = pos + size
      if pend < new_pos then
        error("Truncated string.")
      end
      field_dict[key] = sub(buffer, pos + 1, new_pos)
      return new_pos
    end
  end
end
function MessageDecoder(field_number, is_repeated, is_packed, key, new_default)
  local DecodeVarint = _DecodeVarint
  local sub = string.sub
  assert(not is_packed)
  if is_repeated then
    do
      local tag_bytes = encoder.TagBytes(field_number, wire_format.WIRETYPE_LENGTH_DELIMITED)
      local tag_len = #tag_bytes
      return function(buffer, pos, pend, message, field_dict)
        local value = field_dict[key]
        if value == nil then
          value = new_default(message)
          field_dict[key] = value
        end
        while true do
          local size, new_pos
          size, pos = DecodeVarint(buffer, pos, FieldDescriptor.CPPTYPE_INT32)
          new_pos = pos + size
          if pend < new_pos then
            error("Truncated message.")
          end
          if value:add():_InternalParse(buffer, pos, new_pos) ~= new_pos then
            error("Unexpected end-group tag.")
          end
          pos = new_pos + tag_len
          if sub(buffer, new_pos + 1, pos) ~= tag_bytes or new_pos == pend then
            return new_pos
          end
        end
      end
    end
  else
    return function(buffer, pos, pend, message, field_dict)
      local value = field_dict[key]
      if value == nil then
        value = new_default(message)
        field_dict[key] = value
      end
      local size, new_pos
      size, pos = DecodeVarint(buffer, pos, FieldDescriptor.CPPTYPE_INT32)
      new_pos = pos + size
      if pend < new_pos then
        error("Truncated message.")
      end
      if value:_InternalParse(buffer, pos, new_pos) ~= new_pos then
        error("Unexpected end-group tag.")
      end
      return new_pos
    end
  end
end
function _SkipVarint(buffer, pos, pend)
  local value
  value, pos = _DecodeVarint(buffer, pos, FieldDescriptor.CPPTYPE_INT32)
  return pos
end
function _SkipFixed64(buffer, pos, pend)
  pos = pos + 8
  if pend < pos then
    error("Truncated message.")
  end
  return pos
end
function _SkipLengthDelimited(buffer, pos, pend)
  local size
  size, pos = _DecodeVarint(buffer, pos, FieldDescriptor.CPPTYPE_INT32)
  pos = pos + size
  if pend < pos then
    error("Truncated message.")
  end
  return pos
end
function _SkipFixed32(buffer, pos, pend)
  pos = pos + 4
  if pend < pos then
    error("Truncated message.")
  end
  return pos
end
function _RaiseInvalidWireType(buffer, pos, pend)
  error("Tag had invalid wire type.")
end
function _FieldSkipper()
  WIRETYPE_TO_SKIPPER = {
    _SkipVarint,
    _SkipFixed64,
    _SkipLengthDelimited,
    _SkipGroup,
    _EndGroup,
    _SkipFixed32,
    _RaiseInvalidWireType,
    _RaiseInvalidWireType
  }
  local ord = string.byte
  local sub = string.sub
  return function(buffer, pos, pend, tag_bytes)
    local wire_type = ord(sub(tag_bytes, 1, 1)) % 8 + 1
    return WIRETYPE_TO_SKIPPER[wire_type](buffer, pos, pend)
  end
end
SkipField = _FieldSkipper()
