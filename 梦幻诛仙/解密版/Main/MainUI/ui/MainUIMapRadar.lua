local Lplus = require("Lplus")
local ComponentBase = require("Main.MainUI.ui.MainUIComponentBase")
local MainUIMapRadar = Lplus.Extend(ComponentBase, "MainUIMapRadar")
local GUIUtils = require("GUI.GUIUtils")
local DeviceUtility = require("Utility.DeviceUtility")
local def = MainUIMapRadar.define
def.field("number").updateTimeTimer = 0
def.field("userdata").ui_Label_MiniMap = nil
def.field("userdata").ui_Label_Coordinate = nil
def.field("userdata").ui_Img_BgMapPhone = nil
def.field("userdata").ui_Label_Time = nil
def.field("table").uiObjs = nil
local instance
def.static("=>", MainUIMapRadar).Instance = function()
  if instance == nil then
    instance = MainUIMapRadar()
    instance:Init()
  end
  return instance
end
def.override().Init = function(self)
end
def.override().OnCreate = function(self)
  self.ui_Label_MiniMap = self.m_node:FindDirect("Btn_MiniMap/Label_MiniMap")
  self.ui_Label_Coordinate = self.m_node:FindDirect("Img_Coordinate/Label_Coordinate")
  self.ui_Img_BgMapPhone = self.m_panel:FindDirect("Pnl_MapInfo/Img_BgMapPhone")
  self.ui_Label_Time = GUIUtils.FindDirect(self.ui_Img_BgMapPhone, "Label_Time")
  self.uiObjs = {}
  self.uiObjs.Img_NetWifi = GUIUtils.FindDirect(self.ui_Img_BgMapPhone, "Img_Net01")
  self.uiObjs.Img_NetData = GUIUtils.FindDirect(self.ui_Img_BgMapPhone, "Img_Net03")
  self.uiObjs.label_mapPos = self.ui_Label_Coordinate:GetComponent("UILabel")
  self.uiObjs.Img_Battery01 = GUIUtils.FindDirect(self.ui_Img_BgMapPhone, "Img_Battery01")
  self.uiObjs.Group_Slider_Battery = GUIUtils.FindDirect(self.uiObjs.Img_Battery01, "Group_Slider_Battery")
  Event.RegisterEvent(ModuleId.MAP, gmodule.notifyId.Map.MAP_CHANGE, MainUIMapRadar.OnMapChange)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.SYNC_HERO_MAP_POS, MainUIMapRadar.OnSyncHeroMapPos)
  Event.RegisterEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.HERO_FINDPATH_FINISHED, MainUIMapRadar.OnHeroFindPathFinished)
  self.updateTimeTimer = GameUtil.AddGlobalTimer(5, false, function()
    self:UpdateTime()
  end)
  self:UpdateNetState()
  GameUtil.AddGlobalTimer(10, true, function()
    self:UpdateNetState()
  end)
  DeviceUtility.GetBattery(MainUIMapRadar.OnBattery)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.MAP, gmodule.notifyId.Map.MAP_CHANGE, MainUIMapRadar.OnMapChange)
  Event.UnregisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.SYNC_HERO_MAP_POS, MainUIMapRadar.OnSyncHeroMapPos)
  Event.UnregisterEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.HERO_FINDPATH_FINISHED, MainUIMapRadar.OnHeroFindPathFinished)
  GameUtil.RemoveGlobalTimer(self.updateTimeTimer)
  self.updateTimeTimer = 0
  self.ui_Label_MiniMap = nil
  self.ui_Label_Coordinate = nil
  self.ui_Img_BgMapPhone = nil
  self.ui_Label_Time = nil
  self.uiObjs = nil
end
local show_count = 0
local last_show_time = 0
def.override().OnShow = function(self)
  show_count = show_count + 1
  if show_count == 1 then
    last_show_time = Time.time
  elseif show_count == 10 then
    show_count = 0
    local curtm = Time.time
    if curtm > last_show_time then
      local dt = (curtm - last_show_time) / 9
      if dt < 0.1 then
        Debug.LogWarning(debug.traceback())
        error("OnShow too many times!")
      end
    end
  end
  self:UpdateUI()
end
def.override().OnHide = function(self)
end
def.override().Expand = function(self)
  ComponentBase.Expand(self)
  TweenAlpha.Begin(self.ui_Img_BgMapPhone, 0.4, 1)
end
def.override().Shrink = function(self)
  ComponentBase.Shrink(self)
  local uiWidget = self.ui_Img_BgMapPhone:GetComponent("UIWidget")
  if uiWidget then
    uiWidget:set_alpha(0)
  end
end
def.method().UpdateUI = function(self)
  local mapCfg = require("Main.Map.Interface").GetCurMapCfg()
  if mapCfg == nil then
    return
  end
  self:SetMapName(mapCfg.mapName)
  local myRole = require("Main.Hero.HeroModule").Instance().myRole
  local pos = myRole and myRole:GetPos()
  if pos then
    self:SetHeroMapPos(pos.x, pos.y)
  end
  self:UpdateTime()
end
def.static("table", "table").OnMapChange = function()
  if instance == nil then
    return
  end
  instance:UpdateUI()
end
def.static("table", "table").OnSyncHeroMapPos = function(pos, p2)
  if instance == nil then
    return
  end
  instance:SetHeroMapPos(pos.x, pos.y)
end
def.static("table", "table").OnHeroFindPathFinished = function()
  if instance == nil then
    return
  end
  local myRole = require("Main.Hero.HeroModule").Instance().myRole
  local pos = myRole:GetPos()
  instance:SetHeroMapPos(pos.x, pos.y)
end
def.static("dynamic", "dynamic", "dynamic").OnBattery = function(level, temperature, status)
  instance:SetBatteryState(level, temperature, status)
end
def.method().UpdateTime = function(self)
  if self.m_panel == nil then
    return
  end
  local curTime = GetServerTime()
  local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
  local time = AbsoluteTimer.GetServerTimeTable(curTime)
  self:SetTime(time.hour, time.min)
end
def.method("string").SetMapName = function(self, name)
  local label_mapName = self.ui_Label_MiniMap:GetComponent("UILabel")
  label_mapName:set_text(name)
end
def.method("number", "number").SetHeroMapPos = function(self, x, y)
  if self.uiObjs == nil then
    return value
  end
  local label_mapPos = self.uiObjs.label_mapPos
  local displayX = math.floor(x / 16 + 0.5)
  local displayY = math.floor(y / 16 + 0.5)
  label_mapPos:set_text(string.format("%d,%d", displayX, displayY))
end
def.method("number", "number").SetTime = function(self, hour, minute)
  if self.uiObjs == nil then
    return
  end
  GUIUtils.SetText(self.ui_Label_Time, string.format("%02d:%02d", hour, minute))
end
def.method().UpdateNetState = function(self)
  if self.uiObjs == nil then
    return
  end
  local Label_LiuLiang = self.m_node:FindDirect("Label_LiuLiang")
  if DeviceUtility.IsWIFIConnected() then
    GUIUtils.SetActive(self.uiObjs.Img_NetWifi, true)
    GUIUtils.SetActive(self.uiObjs.Img_NetData, false)
    GUIUtils.SetActive(Label_LiuLiang, false)
  else
    GUIUtils.SetActive(self.uiObjs.Img_NetWifi, false)
    GUIUtils.SetActive(self.uiObjs.Img_NetData, true)
    local isFreeFlow = gmodule.moduleMgr:GetModule(ModuleId.LOGIN):IsFreeFlowLogin()
    GUIUtils.SetActive(Label_LiuLiang, isFreeFlow)
  end
end
def.method("number", "number", "number").SetBatteryState = function(self, level, temperature, status)
  if self.uiObjs == nil then
    return
  end
  if level == -1 then
    level = 100
  end
  if temperature == -1 then
  end
  if status == -1 then
    status = DeviceUtility.Constants.DISCHARGING
  end
  local val = level / 100
  GUIUtils.SetProgress(self.uiObjs.Group_Slider_Battery, "UISlider", val)
  local Img_Charge = GUIUtils.FindDirect(self.uiObjs.Img_Battery01, "Img_Charge")
  if status == DeviceUtility.Constants.CHARGING then
    GUIUtils.SetActive(Img_Charge, true)
  else
    GUIUtils.SetActive(Img_Charge, false)
  end
end
MainUIMapRadar.Commit()
return MainUIMapRadar
