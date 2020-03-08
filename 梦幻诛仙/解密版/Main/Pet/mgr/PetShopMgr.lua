local Lplus = require("Lplus")
local PetShopMgr = Lplus.Class("PetShopMgr")
local def = PetShopMgr.define
local PetData = require("Main.Pet.data.PetData")
local PetMgr = require("Main.Pet.mgr.PetMgr")
local PetUtility = require("Main.Pet.PetUtility")
local HeroInterface = require("Main.Hero.Interface")
def.const("string").SELL_2_BUY_RATE = "SELL_2_BUY_RATE"
def.field("number").canSellPetAmount = 0
def.field("table").banPetList = nil
local instance
def.static("=>", PetShopMgr).Instance = function()
  if instance == nil then
    instance = PetShopMgr()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
end
def.method("=>", "table").GetCanBuyPetList = function(self)
  local heroProp = HeroInterface.GetHeroProp()
  local maxCatchLevel = heroProp.level + 10
  local petList = PetUtility.FindPetsByTypeAndCatachLevel(PetData.PetType.WILD, 0, maxCatchLevel)
  local classfieldPetList = {}
  local petMap = {}
  for i, v in ipairs(petList) do
    if PetUtility.PetCanBuyInShop(v.templateId) and not self:IsPetInBanList(v.templateId) then
      if petMap[v.catchLevel] == nil then
        petMap[v.catchLevel] = {}
        petMap[v.catchLevel].catchLevel = v.catchLevel
        table.insert(classfieldPetList, petMap[v.catchLevel])
      end
      table.insert(petMap[v.catchLevel], v)
    end
  end
  table.sort(classfieldPetList, function(left, right)
    if left.catchLevel < right.catchLevel then
      return true
    else
      return false
    end
  end)
  return classfieldPetList
end
def.method("number", "=>", "boolean").IsPetInBanList = function(self, petCfgId)
  if self.banPetList == nil then
    return false
  else
    return self.banPetList[petCfgId] ~= nil
  end
end
def.method("=>", "table").GetCanSellPetList = function(self)
  local petMap = PetMgr.Instance():GetPetList()
  local petList = {}
  for petId, petData in pairs(petMap) do
    if self:CanSell(petData.id) then
      table.insert(petList, petData)
    end
  end
  table.sort(petList, PetShopMgr.SortOnSellPet)
  return petList
end
def.method("userdata", "=>", "boolean").CanSell = function(self, petId)
  local pet = PetMgr.Instance():GetPet(petId)
  local petCfg = pet:GetPetCfgData()
  if petCfg.type == PetData.PetType.WILD then
    return true
  end
  return false
end
def.method("number", "=>", "number").CalcSellPrice = function(self, buyPrice)
  local rate = (PetUtility.GetPetShopConstants(PetShopMgr.SELL_2_BUY_RATE) or 0) / 10000
  return buyPrice * rate
end
def.static(PetData, PetData, "=>", "boolean").SortOnSellPet = function(left, right)
  if left.typeId < right.typeId then
    return true
  end
  return false
end
def.method("number").SetCanSellPetAmount = function(self, num)
  self.canSellPetAmount = num >= 0 and num or 0
end
def.method("=>", "number").GetCanSellPetAmount = function(self, num)
  return self.canSellPetAmount
end
def.method().DecCanSellPetAmount = function(self)
  local num = self:GetCanSellPetAmount() - 1
  self:SetCanSellPetAmount(num)
end
def.method("number").BuyPet = function(self, petCfgId)
  if self:IsPetInBanList(petCfgId) then
    Toast(textRes.Pet[164])
    return
  end
  self:C2S_BuyPetReq(petCfgId)
end
def.method("table").BuyPetSuccess = function(self, data)
  Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_SHOP_BUY_PET_SUCCESS, {
    petCfgId = data.petCfgId
  })
end
def.method("userdata").SellPet = function(self, petId)
  local pet = PetMgr.Instance():GetPet(petId)
  if pet == nil then
    return
  end
  local petCfg = pet:GetPetCfgData()
  if self:IsPetInBanList(petCfg.templateId) then
    Toast(textRes.Pet[164])
    return
  end
  self:C2S_SellPetReq(petId)
end
def.method("table").SellPetSuccess = function(self, data)
  self:DecCanSellPetAmount()
  Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_SHOP_SELL_PET_SUCCESS, {
    petCfgId = data.petCfgId,
    addMoney = data.addMoney
  })
end
def.method("number", "=>", "boolean").IsNeeded = function(self, petTemplateId)
  local TaskInterface = require("Main.task.TaskInterface")
  local taskInterface = TaskInterface.Instance()
  local PetRequirements = taskInterface:GetTaskPetRequirements()
  for taskId, graphIdRequiremnt in pairs(PetRequirements) do
    for graphId, requiremnt in pairs(graphIdRequiremnt) do
      if requiremnt.requirementID == petTemplateId then
        return true
      end
    end
  end
  return false
end
def.method("=>", "number").GetNextNeededPetTemplateId = function(self)
  local TaskInterface = require("Main.task.TaskInterface")
  local taskInterface = TaskInterface.Instance()
  local PetRequirements = taskInterface:GetTaskPetRequirements()
  for taskId, graphIdRequiremnt in pairs(PetRequirements) do
    for graphId, requiremnt in pairs(graphIdRequiremnt) do
      return requiremnt.requirementID
    end
  end
  return 0
end
local REQ_MIN_INTERVAL_SEC = 60
local lastreqtime = 0
def.method("=>", "boolean").ReqCanSellPetNum = function(self)
  local reqtime = GameUtil.GetTickCount()
  local msInterval = REQ_MIN_INTERVAL_SEC * 1000
  if msInterval <= reqtime - lastreqtime then
    lastreqtime = reqtime
    self:C2S_GetSellPetNumReq()
    return true
  else
    return false
  end
end
def.method("table").SetBanPetList = function(self, banPetList)
  self.banPetList = {}
  for idx, petCfgId in pairs(banPetList) do
    self.banPetList[petCfgId] = petCfgId
  end
end
def.method("number").C2S_BuyPetReq = function(self, petCfgId)
  local p = require("netio.protocol.mzm.gsp.pet.CBuyPetReq").new(petCfgId)
  gmodule.network.sendProtocol(p)
end
def.method("userdata").C2S_SellPetReq = function(self, petId)
  local p = require("netio.protocol.mzm.gsp.pet.CSellPetReq").new(petId)
  gmodule.network.sendProtocol(p)
end
def.method().C2S_GetSellPetNumReq = function(self)
  local p = require("netio.protocol.mzm.gsp.pet.CGetSellPetNumReq").new()
  gmodule.network.sendProtocol(p)
end
return PetShopMgr.Commit()
