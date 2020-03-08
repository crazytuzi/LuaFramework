local SGangCombineBrd = class("SGangCombineBrd")
SGangCombineBrd.TYPEID = 12589968
SGangCombineBrd.FROM_MAIN = 0
SGangCombineBrd.FROM_VICE = 1
SGangCombineBrd.RESULT_SUCCEED = 0
SGangCombineBrd.RESULT_FAIL = 1
function SGangCombineBrd:ctor(main_id, main_name, vice_id, vice_name, come_from, result)
  self.id = 12589968
  self.main_id = main_id or nil
  self.main_name = main_name or nil
  self.vice_id = vice_id or nil
  self.vice_name = vice_name or nil
  self.come_from = come_from or nil
  self.result = result or nil
end
function SGangCombineBrd:marshal(os)
  os:marshalInt64(self.main_id)
  os:marshalString(self.main_name)
  os:marshalInt64(self.vice_id)
  os:marshalString(self.vice_name)
  os:marshalInt32(self.come_from)
  os:marshalInt32(self.result)
end
function SGangCombineBrd:unmarshal(os)
  self.main_id = os:unmarshalInt64()
  self.main_name = os:unmarshalString()
  self.vice_id = os:unmarshalInt64()
  self.vice_name = os:unmarshalString()
  self.come_from = os:unmarshalInt32()
  self.result = os:unmarshalInt32()
end
function SGangCombineBrd:sizepolicy(size)
  return size <= 65535
end
return SGangCombineBrd
