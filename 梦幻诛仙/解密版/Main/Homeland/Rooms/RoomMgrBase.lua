local MODULE_NAME = (...)
local Lplus = require("Lplus")
local RoomMgrBase = Lplus.Class(MODULE_NAME)
local PetMgr = require("Main.Pet.mgr.PetMgr")
local CurrencyFactory = require("Main.Currency.CurrencyFactory")
local HouseMgr = require("Main.Homeland.HouseMgr")
local HomelandUtils = require("Main.Homeland.HomelandUtils")
local def = RoomMgrBase.define
def.field("number").m_level = 1
def.field("string").m_name = ""
def.virtual("=>", "number").GetRoomLevel = function(self)
  return self.m_level
end
def.method("=>", "number").GetRoomNextLevel = function(self)
  return self.m_level + 1
end
def.method("=>", "string").GetRoomName = function(self)
  return self.m_name
end
def.method("number").SetRoomLevel = function(self, level)
  self.m_level = level
end
def.method().UpgradeRoom = function(self)
  local HomelandModule = Lplus.ForwardDeclare("HomelandModule")
  if not HomelandModule.Instance():CheckAuthority(HomelandModule.VisitType.Owner) then
    return
  end
  if self:IsReachMaxLevel() then
    local text = string.format(textRes.Homeland[58], self.m_name)
    Toast(text)
    return
  end
  local needs = self:GetUpgradeNeeds()
  self:ShowRoomUpgradeConfirm(needs.currencyType, needs.currencyNum, function()
    self:OnUpgradeRoom()
  end)
end
def.virtual("=>", "boolean").IsReachMaxLevel = function(self)
  return true
end
def.virtual("=>", "table").GetUpgradeNeeds = function(self)
  return {currencyType = 0, currencyNum = 0}
end
def.virtual("=>", "boolean").OnUpgradeRoom = function(self)
  return true
end
def.method("number", "number", "function").ShowRoomUpgradeConfirm = function(self, currencyType, currencyNum, onConfirm)
  local nextLevel = self:GetRoomNextLevel()
  local roomName = self:GetRoomName()
  local currency = CurrencyFactory.Create(currencyType)
  local costCurrencyText = string.format("%s%s", currencyNum, currency:GetName())
  local title = string.format(textRes.Homeland[14], roomName)
  local desc = string.format(textRes.Homeland[15], costCurrencyText, roomName, nextLevel)
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  CommonConfirmDlg.ShowConfirm(title, desc, function(s)
    if s == 1 then
      local haveNum = currency:GetHaveNum()
      if haveNum >= Int64.new(currencyNum) then
        if onConfirm then
          onConfirm()
        end
      else
        currency:AcquireWithQuery()
      end
    end
  end, nil)
end
def.virtual("table").SyncRoomInfo = function(self, p)
end
def.method("=>", "number").GetHouseCleanness = function(self)
  return HouseMgr.Instance():GetMyHouse():GetCleanness()
end
def.method("=>", "table").GetHouseCleannessCfg = function(self)
  local cleanness = self:GetHouseCleanness()
  return HomelandUtils.GetHouseCleanlinessCfg(cleanness)
end
def.virtual("=>", "number").GetDeductCleannessNums = function(self)
  return 0
end
def.method().DailyReset = function(self)
  self:OnDailyRest()
end
def.virtual().OnDailyRest = function(self)
end
return RoomMgrBase.Commit()
