local SGiveUpBreedSuccess = class("SGiveUpBreedSuccess")
SGiveUpBreedSuccess.TYPEID = 12609316
function SGiveUpBreedSuccess:ctor()
  self.id = 12609316
end
function SGiveUpBreedSuccess:marshal(os)
end
function SGiveUpBreedSuccess:unmarshal(os)
end
function SGiveUpBreedSuccess:sizepolicy(size)
  return size <= 65535
end
return SGiveUpBreedSuccess
