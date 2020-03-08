local Lplus = require("Lplus")
local PersonalInfo = Lplus.Class("PersonalInfo")
local PersonalInfoInterface
local FieldType = require("consts.mzm.gsp.personal.confbean.FieldType")
local def = PersonalInfo.define
def.field("number").infoTime = 0
def.field("table").info = nil
def.field("userdata").roleId = nil
def.static("userdata", "table", "=>", PersonalInfo).New = function(roleId, info)
  if PersonalInfoInterface == nil then
    PersonalInfoInterface = require("Main.PersonalInfo.PersonalInfoInterface")
  end
  local instance = PersonalInfo()
  instance:Init()
  instance.roleId = roleId
  instance.info = info
  instance.infoTime = GetServerTime()
  return instance
end
def.method().Init = function(self)
end
def.method("=>", "number").getHeadImgId = function(self)
  return self.info.headImage
end
def.method("number", "number").setPraiseNum = function(self, num, dailyNum)
  self.info.praiseNum = num
  self.info.praise = dailyNum
end
def.method("=>", "string").getDisplayId = function(self)
  local displayId = require("Main.Hero.HeroUtility").Instance():RoleIDToDisplayID(self.roleId)
  return tostring(displayId)
end
def.method("=>", "string").getSign = function(self)
  local signStr = GetStringFromOcts(self.info.sign)
  if signStr and signStr ~= "" then
    return signStr
  else
    local personalCfg = PersonalInfoInterface.GetPersonalCfg(FieldType.SIGN)
    return personalCfg.textValue
  end
end
def.method("=>", "string").getSex = function(self)
  if self.info.gender == 0 then
    local personalCfg = PersonalInfoInterface.GetPersonalCfg(FieldType.GENDER)
    return personalCfg.textValue
  else
    local optionCfg = PersonalInfoInterface.GetPersonalOptionCfg(self.info.gender)
    return optionCfg.content
  end
end
def.method("=>", "string").getBirthdayMonth = function(self)
  local birthday = self.info.birthday
  if birthday.month == 0 then
    local personalCfg = PersonalInfoInterface.GetPersonalCfg(FieldType.BORN_MONTH)
    return personalCfg.textValue
  else
    return string.format(textRes.Personal[3], birthday.month)
  end
end
def.method("=>", "string").getBirthdayDay = function(self)
  local birthday = self.info.birthday
  if birthday.month == 0 then
    local personalCfg = PersonalInfoInterface.GetPersonalCfg(FieldType.BORN_DAY)
    return personalCfg.textValue
  else
    return string.format(textRes.Personal[4], birthday.day)
  end
end
def.method("=>", "string").getConstellation = function(self)
  if self.info.constellation == 0 then
    local personalCfg = PersonalInfoInterface.GetPersonalCfg(FieldType.CONSTELLATION)
    return personalCfg.textValue
  else
    local optionCfg = PersonalInfoInterface.GetPersonalOptionCfg(self.info.constellation)
    return optionCfg.content
  end
end
def.method("=>", "string").getWork = function(self)
  if self.info.occupation == 0 then
    local personalCfg = PersonalInfoInterface.GetPersonalCfg(FieldType.OCCUPATION)
    return personalCfg.textValue
  else
    local optionCfg = PersonalInfoInterface.GetPersonalOptionCfg(self.info.occupation)
    return optionCfg.content
  end
end
def.method("=>", "string").getShengxiao = function(self)
  if self.info.animalSign == 0 then
    local personalCfg = PersonalInfoInterface.GetPersonalCfg(FieldType.ANIMAL_SIGN)
    return personalCfg.textValue
  else
    local optionCfg = PersonalInfoInterface.GetPersonalOptionCfg(self.info.animalSign)
    return optionCfg.content
  end
end
def.method("=>", "string").getBloodType = function(self)
  if self.info.bloodType == 0 then
    local personalCfg = PersonalInfoInterface.GetPersonalCfg(FieldType.BLOOD_TYPE)
    return personalCfg.textValue
  else
    local optionCfg = PersonalInfoInterface.GetPersonalOptionCfg(self.info.bloodType)
    return optionCfg.content
  end
end
def.method("=>", "string").getSchool = function(self)
  local school = GetStringFromOcts(self.info.school)
  if school == nil then
    local personalCfg = PersonalInfoInterface.GetPersonalCfg(FieldType.SCHOOL)
    school = personalCfg.textValue
  end
  return school
end
def.method("=>", "string").getProvince = function(self)
  local location = self.info.location
  if location == nil or location.province == 0 then
    local personalCfg = PersonalInfoInterface.GetPersonalCfg(FieldType.PROVINCE)
    return personalCfg.textValue
  else
    local optionCfg = PersonalInfoInterface.GetPersonalOptionCfg(location.province)
    return optionCfg.content
  end
end
def.method("=>", "string").getCity = function(self)
  if self.info.location.city == 0 then
    local optionCfg = PersonalInfoInterface.GetPersonalCfg(FieldType.CITY)
    return optionCfg.textValue
  else
    local optionCfg = PersonalInfoInterface.GetPersonalLocationCfg(self.info.location.city)
    return optionCfg.content
  end
end
def.method("=>", "string").getLocaltion = function(self)
  local location = self.info.location
  if location == nil or location.province == 0 then
    local personalCfg = PersonalInfoInterface.GetPersonalCfg(FieldType.PROVINCE)
    return personalCfg.textValue
  else
    local optionCfg = PersonalInfoInterface.GetPersonalOptionCfg(location.province)
    local str = optionCfg.content
    if location.city ~= 0 then
      optionCfg = PersonalInfoInterface.GetPersonalLocationCfg(location.city)
      return str .. " " .. optionCfg.content
    else
      return str
    end
  end
end
def.method("=>", "string").getHobby = function(self)
  local hobbyNames = {}
  for _, v in pairs(self.info.hobbies) do
    local optionCfg = PersonalInfoInterface.GetPersonalOptionCfg(v)
    table.insert(hobbyNames, optionCfg.content)
  end
  if #hobbyNames == 0 then
    local optionCfg = PersonalInfoInterface.GetPersonalCfg(FieldType.HOBBY)
    return optionCfg.textValue
  else
    return table.concat(hobbyNames, " ")
  end
end
def.method("=>", "number").getInfoPercent = function(self)
  local num = 0
  local percentCfg = PersonalInfoInterface.GetFieldPrecentCfg(FieldType.NAME)
  num = num + percentCfg.precent
  if GetStringFromOcts(self.info.sign) ~= "" then
    percentCfg = PersonalInfoInterface.GetFieldPrecentCfg(FieldType.SIGN)
    num = num + percentCfg.precent
  end
  percentCfg = PersonalInfoInterface.GetFieldPrecentCfg(FieldType.NUMBER)
  num = num + percentCfg.precent
  if self.info.gender ~= 0 then
    percentCfg = PersonalInfoInterface.GetFieldPrecentCfg(FieldType.GENDER)
    num = num + percentCfg.precent
  end
  if self.info.age ~= 0 then
    percentCfg = PersonalInfoInterface.GetFieldPrecentCfg(FieldType.AGE)
    num = num + percentCfg.precent
  end
  local birthday = self.info.birthday
  if birthday.month ~= 0 then
    percentCfg = PersonalInfoInterface.GetFieldPrecentCfg(FieldType.BORN_MONTH)
    num = num + percentCfg.precent
  end
  if birthday.day ~= 0 then
    percentCfg = PersonalInfoInterface.GetFieldPrecentCfg(FieldType.BORN_DAY)
    num = num + percentCfg.precent
  end
  if self.info.animalSign ~= 0 then
    percentCfg = PersonalInfoInterface.GetFieldPrecentCfg(FieldType.ANIMAL_SIGN)
    num = num + percentCfg.precent
  end
  if self.info.constellation ~= 0 then
    percentCfg = PersonalInfoInterface.GetFieldPrecentCfg(FieldType.CONSTELLATION)
    num = num + percentCfg.precent
  end
  if self.info.bloodType ~= 0 then
    percentCfg = PersonalInfoInterface.GetFieldPrecentCfg(FieldType.BLOOD_TYPE)
    num = num + percentCfg.precent
  end
  if self.info.occupation ~= 0 then
    percentCfg = PersonalInfoInterface.GetFieldPrecentCfg(FieldType.OCCUPATION)
    num = num + percentCfg.precent
  end
  if GetStringFromOcts(self.info.school) ~= "" then
    percentCfg = PersonalInfoInterface.GetFieldPrecentCfg(FieldType.SCHOOL)
    num = num + percentCfg.precent
  end
  local location = self.info.location
  if location.province ~= 0 then
    percentCfg = PersonalInfoInterface.GetFieldPrecentCfg(FieldType.PROVINCE)
    num = num + percentCfg.precent
  end
  if location.city ~= 0 then
    percentCfg = PersonalInfoInterface.GetFieldPrecentCfg(FieldType.CITY)
    num = num + percentCfg.precent
  end
  if 0 < #self.info.hobbies then
    percentCfg = PersonalInfoInterface.GetFieldPrecentCfg(FieldType.HOBBY)
    num = num + percentCfg.precent
  end
  if self.info.headImage ~= 0 then
    percentCfg = PersonalInfoInterface.GetFieldPrecentCfg(FieldType.HEAD_IMAGE)
    num = num + percentCfg.precent
  end
  return num
end
def.method("=>", "userdata").getFigureUrl = function(self)
  return self.info.figure_url
end
def.method("=>", "number").getPraiseNum = function(self)
  return self.info.praiseNum
end
def.method("=>", "number").getDailyPraiseNum = function(self)
  return self.info.praise
end
def.method("=>", "number").getAvatarFrameId = function(self)
  return self.info.avatar_frame
end
return PersonalInfo.Commit()
