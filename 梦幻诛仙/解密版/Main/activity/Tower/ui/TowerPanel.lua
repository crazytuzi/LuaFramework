local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local TowerPanel = Lplus.Extend(ECPanelBase, "TowerPanel")
local ECUIModel = require("Model.ECUIModel")
local GUIUtils = require("GUI.GUIUtils")
local TowerMgr = Lplus.ForwardDeclare("TowerMgr")
local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
local ItemUtils = require("Main.Item.ItemUtils")
local instance
local def = TowerPanel.define
def.static("=>", TowerPanel).Instance = function(self)
  if instance == nil then
    instance = TowerPanel()
    Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, TowerPanel.OnFightEnd)
    Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, TowerPanel.OnFightStart)
  end
  return instance
end
def.field("number").selectFloor = 0
def.field("table").floors = nil
def.field("number").activityId = 0
def.field("number").openId = 0
def.field("boolean").fightClose = false
def.field("table").model = nil
def.static("number").ShowTowerPanel = function(activityId)
  local self = TowerPanel.Instance()
  if activityId ~= self.activityId then
    self.activityId = activityId
    self.selectFloor = 0
  end
  if self:IsShow() then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.PREFAB_TOWER, 1)
  self:SetModal(true)
end
def.static().UpdateContent = function()
  local self = TowerPanel.Instance()
  if self:IsShow() then
    self:UpdateAll()
  end
end
def.static("number").UpdateFloor = function(floor)
  local self = TowerPanel.Instance()
  if floor ~= self.selectFloor then
    self.selectFloor = floor
    if self:IsShow() then
      self:UpdateSelect(false)
      self:UpdateFloorInfo()
      self:UpdateFirstKill()
      self:UpdateFastKill()
    end
  end
end
def.static("table", "table").OnFightEnd = function(p1, p2)
  local self = TowerPanel.Instance()
  if not self:IsShow() and self.fightClose then
    self.fightClose = false
    self:CreatePanel(RESPATH.PREFAB_TOWER, 1)
    self:SetModal(true)
  end
end
def.static("table", "table").OnFightStart = function(p1, p2)
  local self = TowerPanel.Instance()
  if self:IsShow() then
    self.fightClose = true
    self:DestroyPanel()
  end
end
def.override().OnCreate = function(self)
  Event.RegisterEventWithContext(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, TowerPanel.OnFunctionOpenChange, self)
  self:UpdateAll()
end
def.method().UpdateAll = function(self)
  self:UpdateList()
  self:UpdateSweep()
  self:AutoSelectFloor()
end
def.method("table").OnFunctionOpenChange = function(self, param)
  if param.feature == self.openId then
    self:UpdateSweep()
  end
end
def.method().AutoSelectFloor = function(self)
  if self.selectFloor > 0 then
    self:UpdateSelect(true)
    self:UpdateFloorInfo()
    self:UpdateFirstKill()
    self:UpdateFastKill()
    return
  end
  local select = #self.floors - 1 + 1
  for i = 1, #self.floors do
    local floor = self.floors[i]
    local FloorInfo = TowerMgr.Instance():GetFloorData(self.activityId, floor)
    if FloorInfo == nil or FloorInfo.usedTime == nil or 0 > FloorInfo.usedTime then
      select = #self.floors - i + 1
      break
    end
  end
  local floor = self.floors[#self.floors - select + 1]
  if floor then
    self.selectFloor = floor
    self:UpdateSelect(true)
    self:UpdateFloorInfo()
    self:UpdateFirstKill()
    self:UpdateFastKill()
  end
end
def.method("number").SelectFloor = function(self, index)
  local floor = self.floors[#self.floors - index + 1]
  if floor and floor ~= self.selectFloor then
    self.selectFloor = floor
    self:UpdateSelect(false)
    self:UpdateFloorInfo()
    self:UpdateFirstKill()
    self:UpdateFastKill()
  end
end
def.method("boolean").UpdateSelect = function(self, auto)
  local scroll = self.m_panel:FindDirect("Img_Bg0/Group_Tower/Img_Bg01/ScrollView")
  local list = scroll:FindDirect("Grid")
  local listCmp = list:GetComponent("UIList")
  local count = #self.floors
  listCmp:set_itemCount(count)
  listCmp:Resize()
  local selectItem
  local items = listCmp:get_children()
  for i = 1, #items do
    local uiGo = items[i]
    local floor = self.floors[count - i + 1]
    self:FillSelect(uiGo, floor, i)
    if self.selectFloor == floor then
      selectItem = uiGo
    end
  end
  if auto then
    GameUtil.AddGlobalTimer(0.1, true, function()
      if scroll.isnil or selectItem == nil or selectItem.isnil then
        return
      end
      scroll:GetComponent("UIScrollView"):DragToMakeVisible(selectItem.transform, 128)
    end)
  end
end
def.method().UpdateSweep = function(self)
  local sweepBtn = self.m_panel:FindDirect("Img_Bg0/Group_Reward/Btn_Sweep")
  local towerCfg = TowerMgr.Instance():GetTowerActivityCfg(self.activityId)
  if towerCfg then
    local canSweep = towerCfg.canSweep
    if canSweep then
      self.openId = towerCfg.sweepSwithId
      local open = IsFeatureOpen(self.openId)
      if open then
        sweepBtn:SetActive(true)
      else
        sweepBtn:SetActive(false)
      end
    else
      sweepBtn:SetActive(false)
    end
  else
    sweepBtn:SetActive(false)
  end
end
def.method().UpdateList = function(self)
  self.floors = TowerMgr.Instance():GetActivityFloors(self.activityId)
  local scroll = self.m_panel:FindDirect("Img_Bg0/Group_Tower/Img_Bg01/ScrollView")
  local list = scroll:FindDirect("Grid")
  local listCmp = list:GetComponent("UIList")
  local count = #self.floors
  listCmp:set_itemCount(count)
  listCmp:Resize()
  local items = listCmp:get_children()
  for i = 1, #items do
    local uiGo = items[i]
    local floor = self.floors[count - i + 1]
    self:FillFloor(uiGo, floor, i)
  end
end
def.method("userdata", "number", "number").FillSelect = function(self, uiGo, floor, index)
  local select = uiGo:FindDirect("Img_Select")
  if floor == self.selectFloor then
    uiGo:GetComponent("UISprite"):set_spriteName("Img_Dark")
    select:SetActive(true)
  else
    select:SetActive(false)
    local canFight = TowerMgr.Instance():CanFight(self.activityId, floor)
    if canFight then
      uiGo:GetComponent("UISprite"):set_spriteName("Img_Light")
    else
      uiGo:GetComponent("UISprite"):set_spriteName("Img_Dark")
    end
  end
end
def.method("userdata", "number", "number").FillFloor = function(self, uiGo, floor, index)
  local FloorInfo = TowerMgr.Instance():GetFloorData(self.activityId, floor)
  local canFight = TowerMgr.Instance():CanFight(self.activityId, floor)
  local light = uiGo:FindDirect("Img_BgLight")
  local name = uiGo:FindDirect("Label_Name")
  local select = uiGo:FindDirect("Img_Select")
  name:GetComponent("UISprite"):set_spriteName(tostring(floor))
  if FloorInfo and FloorInfo.usedTime and FloorInfo.usedTime >= 0 then
    light:SetActive(true)
  else
    light:SetActive(false)
  end
  if canFight then
    uiGo:GetComponent("UISprite"):set_spriteName("Img_Light")
  else
    uiGo:GetComponent("UISprite"):set_spriteName("Img_Dark")
  end
  if floor == self.selectFloor then
    uiGo:GetComponent("UISprite"):set_spriteName("Img_Dark")
    select:SetActive(true)
  else
    select:SetActive(false)
  end
end
def.method().UpdateFloorInfo = function(self)
  local towerCfg = TowerMgr.Instance():GetTowerFloorCfg(self.activityId)
  local floorCfg = towerCfg.floors[self.selectFloor]
  local info = self.m_panel:FindDirect("Img_Bg0/Group_Model/Label_Info")
  local name = info:FindDirect("Label_TitleTower")
  local lv = info:FindDirect("Label_LVTower")
  name:GetComponent("UILabel"):set_text(floorCfg.floorName)
  info:GetComponent("UILabel"):set_text(floorCfg.describe)
  lv:GetComponent("UILabel"):set_text(string.format(textRes.activity[900], floorCfg.joinLevel))
  if self.model then
    self.model:Destroy()
    self.model = nil
  end
  local resourcePath, resourceType = GetIconPath(floorCfg.headIconId)
  warn("resourcePath", resourcePath)
  if resourceType == 1 then
    do
      local uiModel = self.m_panel:FindDirect("Img_Bg0/Group_Model/Img_Bg02/Model"):GetComponent("UIModel")
      self.model = ECUIModel.new(0)
      self.model:LoadUIModel(resourcePath, function(ret)
        if ret and not uiModel.isnil and self.model and self.model.m_model and not self.model.m_model.isnil then
          uiModel.modelGameObject = self.model.m_model
          if uiModel.mCanOverflow ~= nil then
            local camera = uiModel:get_modelCamera()
            camera:set_orthographic(true)
          end
        end
      end)
    end
  end
  local list = self.m_panel:FindDirect("Img_Bg0/Group_Reward/List")
  local listCmp = list:GetComponent("UIList")
  local count = #floorCfg.awardItems
  listCmp:set_itemCount(count)
  listCmp:Resize()
  local items = listCmp:get_children()
  for i = 1, #items do
    local uiGo = items[i]
    local itemId = floorCfg.awardItems[i]
    local uiTex = uiGo:FindDirect(string.format("Img_Icon_%d", i)):GetComponent("UITexture")
    local itemBase = ItemUtils.GetItemBase(itemId)
    GUIUtils.FillIcon(uiTex, itemBase.icon)
  end
end
def.method().UpdateFirstKill = function(self)
  local firstKillGroup = self.m_panel:FindDirect("Img_Bg0/Group_Note/Img_Bg03")
  local timeLbl = firstKillGroup:FindDirect("Label_Time1")
  local nameLbl = firstKillGroup:FindDirect("Label_Name1")
  local camera = firstKillGroup:FindDirect("Btn_Search1")
  timeLbl:GetComponent("UILabel"):set_text(textRes.activity[901])
  nameLbl:GetComponent("UILabel"):set_text(textRes.activity[902])
  camera:SetActive(false)
  TowerMgr.Instance():RequestFirstBloodData(self.activityId, self.selectFloor, function(info)
    if timeLbl.isnil or nameLbl.isnil or camera.isnil then
      return
    end
    local timeTbl = AbsoluteTimer.GetServerTimeTable(info.killTime)
    local timeStr = string.format(textRes.activity[904], timeTbl.year, timeTbl.month, timeTbl.day, timeTbl.hour, timeTbl.min)
    timeLbl:GetComponent("UILabel"):set_text(timeStr)
    local names = {}
    for k, v in ipairs(info.names) do
      table.insert(names, textRes.Common[46] .. v)
    end
    nameLbl:GetComponent("UILabel"):set_text(table.concat(names, "\n"))
    local isOpen = IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_LUN_HUI_XU_KONG__CHECK_RECORD)
    camera:SetActive(isOpen)
  end)
end
def.method().UpdateFastKill = function(self)
  local fastKillGroup = self.m_panel:FindDirect("Img_Bg0/Group_Note/Img_Bg04")
  local timeLbl = fastKillGroup:FindDirect("Label_Time2")
  local nameLbl = fastKillGroup:FindDirect("Label_Name2")
  local camera = fastKillGroup:FindDirect("Btn_Search2")
  timeLbl:GetComponent("UILabel"):set_text(textRes.activity[901])
  nameLbl:GetComponent("UILabel"):set_text(textRes.activity[902])
  camera:SetActive(false)
  TowerMgr.Instance():RequestFastKillData(self.activityId, self.selectFloor, function(info)
    if timeLbl.isnil or nameLbl.isnil or camera.isnil then
      return
    end
    local min = math.floor(info.usedTime / 60)
    local sec = info.usedTime % 60
    local timeStr = string.format(textRes.activity[905], min, sec)
    timeLbl:GetComponent("UILabel"):set_text(timeStr)
    local names = {}
    for k, v in ipairs(info.names) do
      table.insert(names, textRes.Common[46] .. v)
    end
    nameLbl:GetComponent("UILabel"):set_text(table.concat(names, "\n"))
    local isOpen = IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_LUN_HUI_XU_KONG__CHECK_RECORD)
    camera:SetActive(isOpen)
  end)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, TowerPanel.OnFunctionOpenChange)
  self.floors = nil
  if self.model then
    self.model:Destroy()
    self.model = nil
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_Search1" then
    TowerMgr.Instance():PlayFirstBloodFightRecord(self.activityId, self.selectFloor)
  elseif id == "Btn_Search2" then
    TowerMgr.Instance():PlayFastKillFightRecord(self.activityId, self.selectFloor)
  elseif id == "Btn_Change" then
    TowerMgr.Instance():FightFloor(self.activityId, self.selectFloor)
  elseif id == "Btn_Sweep" then
    local highFloor, startFloor, endFloor = TowerMgr.Instance():GetSweepData(self.activityId)
    if endFloor < startFloor then
      Toast(textRes.activity[934])
      return
    end
    require("Main.activity.Tower.ui.TowerSweep").ShowTowerSweep(self.activityId)
  elseif id == "Btn_Tips" then
    local towerCfg = TowerMgr.Instance():GetTowerActivityCfg(self.activityId)
    if towerCfg then
      local tipsId = towerCfg.tipsId
      GUIUtils.ShowHoverTip(tipsId, 0, 0)
    end
  elseif string.sub(id, 1, 5) == "item_" then
    local index = tonumber(string.sub(id, 6))
    if index then
      self:SelectFloor(index)
    end
  elseif string.sub(id, 1, 11) == "Item_Award_" then
    local index = tonumber(string.sub(id, 12))
    if index then
      local towerCfg = TowerMgr.Instance():GetTowerFloorCfg(self.activityId)
      local floorCfg = towerCfg.floors[self.selectFloor]
      local itemId = floorCfg.awardItems[index]
      if itemId then
        local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
        local go = self.m_panel:FindDirect("Img_Bg0/Group_Reward/List/" .. id)
        ItemTipsMgr.Instance():ShowBasicTipsWithGO(itemId, go, 0, false)
      end
    end
  end
end
TowerPanel.Commit()
return TowerPanel
