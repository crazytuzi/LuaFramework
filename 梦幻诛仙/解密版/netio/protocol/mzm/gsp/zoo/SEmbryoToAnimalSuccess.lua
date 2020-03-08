local AnimalInfo = require("netio.protocol.mzm.gsp.zoo.AnimalInfo")
local SEmbryoToAnimalSuccess = class("SEmbryoToAnimalSuccess")
SEmbryoToAnimalSuccess.TYPEID = 12615431
function SEmbryoToAnimalSuccess:ctor(animal)
  self.id = 12615431
  self.animal = animal or AnimalInfo.new()
end
function SEmbryoToAnimalSuccess:marshal(os)
  self.animal:marshal(os)
end
function SEmbryoToAnimalSuccess:unmarshal(os)
  self.animal = AnimalInfo.new()
  self.animal:unmarshal(os)
end
function SEmbryoToAnimalSuccess:sizepolicy(size)
  return size <= 65535
end
return SEmbryoToAnimalSuccess
