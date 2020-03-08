local MatrixChallenge = class("MatrixChallenge")
MatrixChallenge.TYPEID = 551
function MatrixChallenge:ctor(algorithm, nonce)
  self.id = 551
  self.algorithm = algorithm or nil
  self.nonce = nonce or nil
end
function MatrixChallenge:marshal(os)
  os:marshalInt32(self.algorithm)
  os:marshalInt32(self.nonce)
end
function MatrixChallenge:unmarshal(os)
  self.algorithm = os:unmarshalInt32()
  self.nonce = os:unmarshalInt32()
end
function MatrixChallenge:sizepolicy(size)
  return size <= 64
end
return MatrixChallenge
