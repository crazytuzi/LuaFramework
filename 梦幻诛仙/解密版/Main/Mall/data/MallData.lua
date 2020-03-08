local Lplus = require("Lplus")
local MallUtility = require("Main.Mall.MallUtility")
local MallData = Lplus.Class("MallData")
local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
local def = MallData.define
local instance
def.field("table").mallItemsList = nil
def.field("boolean").dailyPurchaseRedPoint = false
local configPath = string.format("%s/%s", Application.persistentDataPath, "config/daily_purchase_info.lua")
def.static("=>", MallData).Instance = function()
  if nil == instance then
    instance = MallData()
    instance.mallItemsList = {}
  end
  return instance
end
def.method().SetAllNull = function(self)
  self.mallItemsList = {}
end
def.method("table").SyncAllMallItemsList = function(self, tbl)
  if self.mallItemsList == nil then
    self.mallItemsList = {}
  end
  if #self.mallItemsList > 0 then
    for k, v in pairs(tbl) do
      for m, n in pairs(self.mallItemsList) do
        if n.malltype == v.malltype then
          n.itemid2count = {}
          for i, j in pairs(v.itemid2count) do
            n.itemid2count[i] = j
          end
        end
      end
    end
  else
    self.mallItemsList = tbl
  end
end
def.method("=>", "table").GetAllMallItemsList = function(self)
  return self.mallItemsList
end
def.method("number", "number", "=>", "number").GetItemLeft = function(self, type, itemId)
  for k, v in pairs(self.mallItemsList) do
    if v.malltype == type then
      return v.itemid2count[itemId]
    end
  end
  return 0
end
def.method("=>", "number").GetTypeOneBtnNumByItemList = function(self)
  local btnList = {}
  local PageEnum = require("consts.mzm.gsp.mall.confbean.PageEnum")
  for k, v in pairs(self.mallItemsList) do
    local pageType = MallUtility.GetPageTypeByMallType(v.malltype)
    if pageType == PageEnum.PAGE_1 then
      table.insert(btnList, v.malltype)
    end
  end
  return #btnList
end
def.method("number", "number", "number").SetItemLeft = function(self, type, itemId, left)
  for k, v in pairs(self.mallItemsList) do
    if v.malltype == type then
      v.itemid2count[itemId] = left
    end
  end
end
def.method("boolean").SetDailyPurchaseRedPoint = function(self, flag)
  if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_DAILY_LIMIT_MALL) then
    return
  end
  local chunk, errorMsg = loadfile(configPath)
  local activityInfo = {}
  if chunk == nil then
    GameUtil.CreateDirectoryForFile(configPath)
  else
    activityInfo = chunk()
  end
  if activityInfo == nil then
    warn("!!!!!!!!!create daily_purchase_info is erro!!!! ")
    return
  end
  local myHero = require("Main.Hero.HeroModule").Instance()
  local myRoleId = myHero:GetMyRoleId()
  local roleId = Int64.tostring(myRoleId)
  activityInfo[roleId] = _G.GetServerTime()
  require("Main.Common.LuaTableWriter").SaveTable("timeInfo", configPath, activityInfo)
end
def.method("=>", "boolean").isShowDailyPurchaseRedPoint = function(self)
  if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_DAILY_LIMIT_MALL) then
    return false
  end
  local chunk, errorMsg = loadfile(configPath)
  local activityInfo = {}
  if chunk == nil then
    GameUtil.CreateDirectoryForFile(configPath)
  else
    activityInfo = chunk()
  end
  if activityInfo == nil then
    warn("!!!!!!!!!create daily_purchase_info is erro!!!! ")
    return false
  end
  local myHero = require("Main.Hero.HeroModule").Instance()
  local myRoleId = myHero:GetMyRoleId()
  local roleId = Int64.tostring(myRoleId)
  local lastShowTime = 0
  if activityInfo[roleId] then
    lastShowTime = activityInfo[roleId]
  end
  local curTime = GetServerTime()
  local lastTimeTable = AbsoluteTimer.GetServerTimeTable(lastShowTime)
  local curTimeTable = AbsoluteTimer.GetServerTimeTable(curTime)
  if lastShowTime == 0 or lastTimeTable.year ~= curTimeTable.year or lastTimeTable.month ~= curTimeTable.month or lastTimeTable.day ~= curTimeTable.day then
    return true
  end
  return false
end
return MallData.Commit()
