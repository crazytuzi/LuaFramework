local Lplus = require("Lplus")
local Json = require("Utility.json")
local MultiOccupationData = Lplus.Class("MultiOccupationData")
local OccupationEnum = require("consts.mzm.gsp.occupation.confbean.SOccupationEnum")
local def = MultiOccupationData.define
local instance
def.field("number").switch_time = 0
def.field("number").activate_time = 0
def.field("table").occupationInfo = nil
def.static("=>", MultiOccupationData).Instance = function()
  if not instance then
    instance = MultiOccupationData()
  end
  return instance
end
def.method("table").sysOccupationInfo = function(self, occpationIds)
  if not self.occupationInfo then
    self.occupationInfo = {}
  end
  local occupationInfo = self.occupationInfo
  for k, occupationId in pairs(OccupationEnum) do
    if _G.IsOccupationExist(occupationId) then
      local name = GetOccupationName(occupationId)
      occupationInfo[occupationId] = {
        id = occupationId,
        sort = occupationId,
        own = false,
        name = name
      }
    end
  end
  for k, occupationId in pairs(occpationIds) do
    self:addOwnOccupation(occupationId)
  end
  local prop = Lplus.ForwardDeclare("HeroModule").Instance():GetHeroProp()
  local occupation = occupationInfo[prop.occupation]
  if occupation and not occupation.own then
    occupation.own = true
  end
end
def.method("number").addOwnOccupation = function(self, occupationId)
  local occupation = self.occupationInfo[occupationId]
  if occupation then
    occupation.own = true
  else
    warn("------------------occupationInfo own not exsit!!", occupationId)
  end
end
def.method("number").setSwitchTime = function(self, switchTime)
  warn("--------MultiOccupation setSwitchTime", os.date("%Y-%m-%d %H:%M", switchTime))
  self.switch_time = switchTime
end
def.method("number").setActivateTime = function(self, activateTime)
  warn("--------MultiOccupation setActivateTime", os.date("%Y-%m-%d %H:%M", activateTime))
  self.activate_time = activateTime
end
def.method("=>", "number").getSwitchTime = function(self)
  return self.switch_time
end
def.method("=>", "number").getActivateTime = function(self)
  return self.activate_time
end
def.method("=>", "table").getOwnOccupations = function(self)
  local occupations = {}
  if self.occupationInfo then
    for id, occupation in pairs(self.occupationInfo) do
      if occupation.own then
        table.insert(occupations, id)
      end
    end
  end
  return occupations
end
def.method("=>", "table").getOccupationInfo = function(self)
  if not self.occupationInfo then
    self:sysOccupationInfo({})
    warn("----------------not Multi Occupation Info!!")
  end
  return self.occupationInfo
end
def.method("=>", "number").getOwnOccupationCount = function(self)
  if not self.occupationInfo then
    return 1
  end
  local ownCount = 0
  for id, occupation in pairs(self.occupationInfo) do
    if occupation.own then
      ownCount = ownCount + 1
    end
  end
  return ownCount
end
def.method("number", "=>", "table").getNewOccupationCfg = function(self, newNum)
  local info
  local record = DynamicData.GetRecord(CFG_PATH.DATA_NEWOCCUPCOST_CFG, newNum)
  if record ~= nil then
    info = {}
    info.newN = DynamicRecord.GetIntValue(record, "newN")
    info.gold = DynamicRecord.GetIntValue(record, "gold")
    info.itemid = DynamicRecord.GetIntValue(record, "itemid")
    info.itemNumber = DynamicRecord.GetIntValue(record, "itemNumber")
  else
    warn("error getNewOccupationCfg not exit for:", newNum)
  end
  return info
end
def.method("=>", "table").getCurNewOccupationCfg = function(self)
  local ownCount = self:getOwnOccupationCount()
  return self:getNewOccupationCfg(ownCount)
end
def.method("=>", "number").getNewOccupationNeedGold = function(self)
  local ownCount = self:getOwnOccupationCount()
  local cfgInfo = self:getNewOccupationCfg(ownCount)
  if cfgInfo then
    return cfgInfo.gold
  end
  return 0
end
def.method("=>", "boolean").isOwnAllOccupation = function(self)
  if not self.occupationInfo then
    return false
  end
  for id, occupation in pairs(self.occupationInfo) do
    if not occupation.own then
      return false
    end
  end
  return true
end
return MultiOccupationData.Commit()
