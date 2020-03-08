local MatrixResponse = class("MatrixResponse")
MatrixResponse.TYPEID = 552
function MatrixResponse:ctor(response)
  self.id = 552
  self.response = response or nil
end
function MatrixResponse:marshal(os)
  os:marshalInt32(self.response)
end
function MatrixResponse:unmarshal(os)
  self.response = os:unmarshalInt32()
end
function MatrixResponse:sizepolicy(size)
  return size <= 64
end
return MatrixResponse
