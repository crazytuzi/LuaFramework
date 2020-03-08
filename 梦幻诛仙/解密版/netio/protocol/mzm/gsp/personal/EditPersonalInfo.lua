local OctetsStream = require("netio.OctetsStream")
local Birthday = require("netio.protocol.mzm.gsp.personal.Birthday")
local Location = require("netio.protocol.mzm.gsp.personal.Location")
local EditPersonalInfo = class("EditPersonalInfo")
function EditPersonalInfo:ctor(sign, gender, age, birthday, animalSign, constellation, bloodType, occupation, school, location, hobbies, headImage, photos)
  self.sign = sign or nil
  self.gender = gender or nil
  self.age = age or nil
  self.birthday = birthday or Birthday.new()
  self.animalSign = animalSign or nil
  self.constellation = constellation or nil
  self.bloodType = bloodType or nil
  self.occupation = occupation or nil
  self.school = school or nil
  self.location = location or Location.new()
  self.hobbies = hobbies or {}
  self.headImage = headImage or nil
  self.photos = photos or {}
end
function EditPersonalInfo:marshal(os)
  os:marshalOctets(self.sign)
  os:marshalInt32(self.gender)
  os:marshalInt32(self.age)
  self.birthday:marshal(os)
  os:marshalInt32(self.animalSign)
  os:marshalInt32(self.constellation)
  os:marshalInt32(self.bloodType)
  os:marshalInt32(self.occupation)
  os:marshalOctets(self.school)
  self.location:marshal(os)
  os:marshalCompactUInt32(table.getn(self.hobbies))
  for _, v in ipairs(self.hobbies) do
    os:marshalInt32(v)
  end
  os:marshalInt32(self.headImage)
  os:marshalCompactUInt32(table.getn(self.photos))
  for _, v in ipairs(self.photos) do
    os:marshalInt32(v)
  end
end
function EditPersonalInfo:unmarshal(os)
  self.sign = os:unmarshalOctets()
  self.gender = os:unmarshalInt32()
  self.age = os:unmarshalInt32()
  self.birthday = Birthday.new()
  self.birthday:unmarshal(os)
  self.animalSign = os:unmarshalInt32()
  self.constellation = os:unmarshalInt32()
  self.bloodType = os:unmarshalInt32()
  self.occupation = os:unmarshalInt32()
  self.school = os:unmarshalOctets()
  self.location = Location.new()
  self.location:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.hobbies, v)
  end
  self.headImage = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.photos, v)
  end
end
return EditPersonalInfo
