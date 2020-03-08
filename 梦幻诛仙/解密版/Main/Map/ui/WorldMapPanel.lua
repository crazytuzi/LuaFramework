local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local WorldMapPanel = Lplus.Extend(ECPanelBase, "WorldMapPanel")
local def = WorldMapPanel.define
local MapUtility = require("Main.Map.MapUtility")
local MapModule = require("Main.Map.MapModule")
local GUIUtils = require("GUI.GUIUtils")
local instance
def.field("string").lastMapNum = ""
def.field("table").worldMapMappingCfg = nil
def.static("=>", WorldMapPanel).Instance = function()
  if instance == nil then
    instance = WorldMapPanel()
    instance:Init()
    instance.m_TrigGC = true
    instance.m_TryIncLoadSpeed = true
  end
  return instance
end
def.method().Init = function(self)
  self.worldMapMappingCfg = {
    Map_001 = 330000000,
    Map_002 = 330000013,
    Map_003 = 330000005,
    Map_004 = 330000001,
    Map_007 = 330000009,
    Map_008 = 330000006,
    Map_009 = 330000007,
    Map_010 = 330000008,
    Map_011 = 330000002,
    Map_013 = 330000003,
    Map_015 = 330000012,
    Map_018 = 330000014,
    Map_021 = 330000011,
    Map_022 = 330000010,
    Map_023 = 330000015,
    Map_024 = 330000022,
    Map_025 = 330001000
  }
  Event.RegisterEvent(ModuleId.MAP, gmodule.notifyId.Map.MAP_CHANGE, WorldMapPanel.OnMapChange)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, WorldMapPanel.OnEnterFight)
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    return
  end
  self:CreatePanel(RESPATH.WORLD_MAP_PANEL_RES, 1)
  self:SetModal(true)
end
def.method().HidePanel = function(self)
  self:DestroyPanel()
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:UpdateUI()
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    return
  end
  self:SetMap()
end
def.override().OnDestroy = function(self)
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:HidePanel()
  elseif id == "Modal" then
    self:HidePanel()
  elseif id == "Btn_School" then
    self:OnReturnMenPaiButtonClick()
  elseif id == "Btn_Home" then
    self:OnReturnHomeButtonClick()
  elseif id == "Btn_Mini" then
    self:OnMiniMapButtonClick()
  elseif string.sub(id, 1, 4) == "Map_" then
    local DungeonModule = require("Main.Dungeon.DungeonModule")
    if DungeonModule.Instance().State == DungeonModule.DungeonState.TEAM then
      local isLeave = require("Main.Team.TeamData").Instance():GetStatus() == require("netio.protocol.mzm.gsp.team.TeamMember").ST_TMP_LEAVE
      if isLeave then
        Toast(textRes.Map[7])
        return
      end
    end
    self:OnMapSelected(id)
  end
end
def.method("string").onLongPress = function(self, id)
  if string.sub(id, 1, 4) == "Map_" then
    self:OnLongPressMapIcon(id)
  end
end
def.method().InitUI = function(self)
  local Btn_Home = self.m_panel:FindDirect("Img_Bg0/Img_BgMap/Btn_Home")
  local homelandModule = gmodule.moduleMgr:GetModule(ModuleId.HOMELAND)
  local isOpen = homelandModule:IsFeatureOpen()
  Btn_Home:SetActive(isOpen)
end
def.method("string").OnMapSelected = function(self, id)
  local mapId = self.worldMapMappingCfg[id]
  if mapId == nil then
    printInfo("map id is nil!")
    Toast(textRes.Map[1])
    return
  end
  print(mapId)
  MapModule.Instance():TransportToMap(mapId)
  self:HidePanel()
end
def.method().OnReturnMenPaiButtonClick = function(self)
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  MapModule.Instance():GotoMenPaiMap()
  self:HidePanel()
end
def.method().OnReturnHomeButtonClick = function(self)
  self:HidePanel()
  gmodule.moduleMgr:GetModule(ModuleId.HOMELAND):ReturnHomeWithVerify()
end
def.method().OnMiniMapButtonClick = function(self)
  self:HidePanel()
  require("Main.Map.ui.MiniMapPanel").Instance():ShowPanel()
end
def.static("table", "table").OnMapChange = function()
  if instance == nil then
    return
  end
  instance:HidePanel()
end
def.static("table", "table").OnEnterFight = function()
  instance:HidePanel()
end
def.method("string", "=>", "string").GetWorldMapNameByObjName = function(self, objName)
  if self.worldMapMappingCfg[objName] == nil then
    return ""
  end
  return self.worldMapMappingCfg[objName]
end
def.method("string", "=>", "string").GetObjNameByWorldMapName = function(self, mapName)
  for objName, value in pairs(self.worldMapMappingCfg) do
    if value == mapName then
      return objName
    end
  end
  return ""
end
def.method("number", "=>", "string").GetObjNameByWorldMapId = function(self, mapId)
  for objName, value in pairs(self.worldMapMappingCfg) do
    if value == mapId then
      return objName
    end
  end
  return ""
end
def.method().SetMap = function(self)
  local mapId = MapModule.Instance():GetMapId()
  local mapCfg = MapUtility.GetMapCfg(mapId)
  self:SetMapName(mapCfg.mapName)
  local objName = self:GetObjNameByWorldMapId(mapCfg.mapId)
  self:SetHeroPos(objName)
end
def.method("string").SetMapName = function(self, mapName)
  local label_miniMap = self.m_panel:FindDirect("Img_Bg0/Img_BgMap/Btn_Mini/Label_Mini"):GetComponent("UILabel")
  label_miniMap:set_text(string.format(textRes.Map[9], mapName))
end
def.method("string").SetHeroPos = function(self, mapResName)
  local num = string.sub(mapResName, -3, -1)
  local baseCtrl = self.m_panel:FindDirect("Img_Bg0/Img_BgMap")
  if self.lastMapNum ~= "" then
    local strNum = self.lastMapNum
    local heroSprite = baseCtrl:FindDirect(string.format("Map_%s/Img_Point", self.lastMapNum))
    if heroSprite ~= nil then
      heroSprite:SetActive(false)
    end
  end
  local strNum = num
  local heroSprite = baseCtrl:FindDirect(string.format("Map_%s/Img_Point", num))
  if heroSprite ~= nil then
    heroSprite:SetActive(true)
  end
  self.lastMapNum = num
end
def.method("string").OnLongPressMapIcon = function(self, id)
  local mapId = self.worldMapMappingCfg[id]
  if mapId == nil then
    mapId = 0
  end
  local mapCfg = MapUtility.GetMapCfg(mapId)
  if mapCfg then
    local tmpPosition = {
      x = 0,
      y = 0,
      z = 0
    }
    require("GUI.CommonUITipsDlg").Instance():ShowDlg(mapCfg.mapDesc, tmpPosition)
  end
end
def.method().UpdateUI = function(self)
  self:UpdateMapFeatures()
end
def.method().UpdateMapFeatures = function(self)
  local isPKOpen = IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_PK)
  local baseCtrl = self.m_panel:FindDirect("Img_Bg0/Img_BgMap")
  for objName, mapId in pairs(self.worldMapMappingCfg) do
    local obj = baseCtrl:FindDirect(objName)
    if obj then
      local Img_Fight = obj:FindDirect("Img_Fight")
      local mapCfg = MapUtility.GetMapCfg(mapId)
      local canShow = isPKOpen and mapCfg and mapCfg.canPK or false
      GUIUtils.SetActive(Img_Fight, canShow)
    end
  end
end
WorldMapPanel.Commit()
return WorldMapPanel
