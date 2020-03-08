local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local TeamDungeonDlg = Lplus.Extend(ECPanelBase, "TeamDungeonDlg")
local DungeonUtils = require("Main.Dungeon.DungeonUtils")
local DungeonModule = require("Main.Dungeon.DungeonModule")
local GUIUtils = require("GUI.GUIUtils")
local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local TeamDungeonType = require("consts.mzm.gsp.instance.confbean.InstanceDisType")
local EC = require("Types.Vector3")
local def = TeamDungeonDlg.define
local _instance
def.field("number").selectType = 0
def.field("number").selectDungeon = 0
def.static("=>", TeamDungeonDlg).Instance = function()
  if _instance == nil then
    _instance = TeamDungeonDlg()
    _instance.m_TrigGC = true
  end
  return _instance
end
def.static("number", "number").ShowTeamDungeon = function(selectType, selectDungeon)
  local dlg = TeamDungeonDlg.Instance()
  if not dlg:CheckTypeOpen(selectType) then
    Toast(textRes.Dungeon[46])
    selectType = dlg:ChoiceType()
    if selectType == 0 then
      return
    else
      selectDungeon = 0
    end
  end
  dlg.selectType = selectType
  dlg.selectDungeon = selectDungeon
  dlg:CreatePanel(RESPATH.PREFAB_DUNGEON_TEAM, 1)
  dlg:SetModal(true)
end
def.static().CloseTeamDungeon = function()
  local dlg = TeamDungeonDlg.Instance()
  if dlg.m_panel then
    dlg:DestroyPanel()
  end
end
def.override().OnCreate = function(self)
  Event.RegisterEventWithContext(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, TeamDungeonDlg.OnFeatureChange, self)
  self:InitType()
  self:SelectType(self.selectType)
  self:SelectDungeon(self.selectDungeon)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, TeamDungeonDlg.OnFeatureChange)
end
def.method("table").OnFeatureChange = function(self, param)
  local feature = param.feature
  local open = param.open
  if feature == ModuleFunSwitchInfo.TYPE_JUQINGFUBEN then
    if not open then
      self:DestroyPanel()
    end
  elseif feature == ModuleFunSwitchInfo.TYPE_JUQINGFUBEN_NORMAL or feature == ModuleFunSwitchInfo.TYPE_JUQINGFUBEN_ELITE or feature == ModuleFunSwitchInfo.TYPE_JUQINGFUBEN_HERO or feature == ModuleFunSwitchInfo.TYPE_JUQINGFUBEN_NIGHTMARE or feature == ModuleFunSwitchInfo.TYPE_JUQINGFUBEN_ACTIVITY then
    if self:CheckTypeOpen(self.selectType) then
      self:InitType()
    else
      local firstType = self:ChoiceType()
      if firstType == 0 then
        self:DestroyPanel()
      else
        self:InitType()
        self:SelectType(firstType)
        self:SelectDungeon(0)
      end
    end
  end
end
def.method("number", "=>", "boolean").CheckTypeOpen = function(self, type)
  return DungeonModule.Instance().teamMgr:CheckOpen(type)
end
def.method().InitType = function(self)
  local tapTbls = self.m_panel:FindDirect("Img_Bg0/Group_Table")
  local tapNormal = tapTbls:FindDirect("Tap_CommonFuBen")
  local tapElite = tapTbls:FindDirect("Tap_EliteFuBen")
  local tapHero = tapTbls:FindDirect("Tap_HeroFuBen")
  local tapNightMare = tapTbls:FindDirect("Tap_NightmareFuBen")
  local tapActivity = tapTbls:FindDirect("Tap_ActictyFuBen")
  tapNormal:SetActive(self:CheckTypeOpen(TeamDungeonType.NORMAL))
  tapElite:SetActive(self:CheckTypeOpen(TeamDungeonType.ELITE))
  tapHero:SetActive(self:CheckTypeOpen(TeamDungeonType.HERO))
  tapNightMare:SetActive(self:CheckTypeOpen(TeamDungeonType.NIGHTMARE))
  tapActivity:SetActive(self:CheckTypeOpen(TeamDungeonType.ACTIVITY))
  tapTbls:GetComponent("UITable"):Reposition()
end
def.method("=>", "number").ChoiceType = function(self)
  if self:CheckTypeOpen(TeamDungeonType.NORMAL) then
    return TeamDungeonType.NORMAL
  elseif self:CheckTypeOpen(TeamDungeonType.ELITE) then
    return TeamDungeonType.ELITE
  elseif self:CheckTypeOpen(TeamDungeonType.HERO) then
    return TeamDungeonType.HERO
  elseif self:CheckTypeOpen(TeamDungeonType.NIGHTMARE) then
    return TeamDungeonType.NIGHTMARE
  elseif self:CheckTypeOpen(TeamDungeonType.ACTIVITY) then
    return TeamDungeonType.ACTIVITY
  else
    return 0
  end
end
def.method("number").SelectType = function(self, type)
  if self:CheckTypeOpen(type) then
    self.selectType = type
  else
    Toast(textRes.Dungeon[46])
  end
  local tapNormal = self.m_panel:FindDirect("Img_Bg0/Group_Table/Tap_CommonFuBen"):GetComponent("UIToggle")
  local tapElite = self.m_panel:FindDirect("Img_Bg0/Group_Table/Tap_EliteFuBen"):GetComponent("UIToggle")
  local tapHero = self.m_panel:FindDirect("Img_Bg0/Group_Table/Tap_HeroFuBen"):GetComponent("UIToggle")
  local tapNightMare = self.m_panel:FindDirect("Img_Bg0/Group_Table/Tap_NightmareFuBen"):GetComponent("UIToggle")
  local tapActivity = self.m_panel:FindDirect("Img_Bg0/Group_Table/Tap_ActictyFuBen"):GetComponent("UIToggle")
  tapNormal:set_value(false)
  tapElite:set_value(false)
  tapHero:set_value(false)
  tapNightMare:set_value(false)
  tapActivity:set_value(false)
  if self.selectType == TeamDungeonType.NORMAL then
    tapNormal:set_value(true)
  elseif self.selectType == TeamDungeonType.ELITE then
    tapElite:set_value(true)
  elseif self.selectType == TeamDungeonType.HERO then
    tapHero:set_value(true)
  elseif self.selectType == TeamDungeonType.NIGHTMARE then
    tapNightMare:set_value(true)
  elseif self.selectType == TeamDungeonType.ACTIVITY then
    tapActivity:set_value(true)
  end
  self:ClearTeamDungeon()
  self:GenerateTeamDungeon()
end
def.method().ClearTeamDungeon = function(self)
  local root = self.m_panel:FindDirect("Img_Bg0/Group_Info/Scroll View/Grid")
  while root:get_childCount() > 1 do
    Object.DestroyImmediate(root:GetChild(root:get_childCount() - 1))
  end
end
def.method().GenerateTeamDungeon = function(self)
  local dungeons = DungeonUtils.GetDungeonByType(self.selectType)
  local root = self.m_panel:FindDirect("Img_Bg0/Group_Info/Scroll View/Grid")
  local template = root:FindDirect("Btn_FuBen")
  template:SetActive(false)
  for k, v in ipairs(dungeons) do
    local id = v.id
    local dungeonCfg = DungeonUtils.GetDungeonCfg(id)
    local itemNew = Object.Instantiate(template)
    itemNew:SetActive(true)
    itemNew:set_name(string.format("Dungeon_%d", id))
    itemNew.parent = root
    itemNew:set_localScale(EC.Vector3.one)
    self:SetIconData(itemNew, v, dungeonCfg)
  end
  root:GetComponent("UIGrid"):Reposition()
  self.m_msgHandler:Touch(root)
end
def.method("userdata", "table", "table").SetIconData = function(self, itemNew, teamData, commonData)
  local teamDungeonData = DungeonModule.Instance():GetTeamDungeonInfo(commonData.id)
  local uiTex = itemNew:FindDirect("Texture"):GetComponent("UITexture")
  local levelLabel = itemNew:FindDirect("Label_Level"):GetComponent("UILabel")
  local nameLabel = itemNew:FindDirect("Label_FuBenName"):GetComponent("UILabel")
  local countLabel = itemNew:FindDirect("Label_Count"):GetComponent("UILabel")
  local complete = itemNew:FindDirect("Img_Completed")
  local jingying = itemNew:FindDirect("Img_JingYing"):GetComponent("UISprite")
  GUIUtils.FillIcon(uiTex, commonData.image)
  if commonData.closeLevel > 0 then
    levelLabel:set_text(string.format(textRes.Dungeon[10], commonData.level, commonData.closeLevel))
  else
    levelLabel:set_text(string.format(textRes.Dungeon[50], commonData.level))
  end
  nameLabel:set_text("")
  if teamData.type == TeamDungeonType.NORMAL then
    jingying:set_spriteName("Img_TypePT")
  elseif teamData.type == TeamDungeonType.ELITE then
    jingying:set_spriteName("Img_TypeJY")
  elseif teamData.type == TeamDungeonType.HERO then
    jingying:set_spriteName("Img_TypeYX")
  elseif teamData.type == TeamDungeonType.NIGHTMARE then
    jingying:set_spriteName("Img_TypeEM")
  elseif teamData.type == TeamDungeonType.ACTIVITY then
    jingying:set_spriteName("Img_TypeHD")
  end
  local finishTimes = teamDungeonData and teamDungeonData.finishTimes or 0
  local finishProcess = teamDungeonData and teamDungeonData.toProcess or 0
  local allProcess = DungeonUtils.CountTeamDungeonProcess(commonData.id)
  countLabel:set_text(string.format("%d/%d", finishProcess, allProcess))
  if finishTimes > 0 then
    complete:SetActive(true)
  else
    complete:SetActive(false)
  end
end
def.method("number").SelectDungeon = function(self, id)
  if id == 0 then
    local dungeons = DungeonUtils.GetDungeonByType(self.selectType)
    if #dungeons > 0 then
      id = dungeons[1].id
    end
  end
  self.selectDungeon = id
  local item = self.m_panel:FindDirect(string.format("Img_Bg0/Group_Info/Scroll View/Grid/Dungeon_%d", id))
  if item then
    item:GetComponent("UIToggle"):set_value(true)
    self:SetDungeonInfo()
  else
    self:HideDungeonInfo()
  end
end
def.method().HideDungeonInfo = function(self)
  local dungeonInfo = self.m_panel:FindDirect("Img_Bg0/Group_Info/Img_BgInfo")
  dungeonInfo:SetActive(false)
end
def.method().SetDungeonInfo = function(self)
  local dungeonInfo = self.m_panel:FindDirect("Img_Bg0/Group_Info/Img_BgInfo")
  dungeonInfo:SetActive(true)
  local ItemUtils = require("Main.Item.ItemUtils")
  local storyLabel = self.m_panel:FindDirect("Img_Bg0/Group_Info/Img_BgInfo/Label_StoryContent"):GetComponent("UILabel")
  local teamDungeonCfg = DungeonUtils.GetTeamDungeonCfg(self.selectDungeon)
  storyLabel:set_text(teamDungeonCfg.desc)
  local itemRoot = self.m_panel:FindDirect("Img_Bg0/Group_Info/Img_BgInfo/Group_Item")
  for i = 1, 4 do
    local item = itemRoot:FindDirect(string.format("Img_Item%d", i))
    local itemId = teamDungeonCfg.items[i]
    if itemId then
      item:SetActive(true)
      local itemBase = ItemUtils.GetItemBase(itemId)
      local uitex = item:FindDirect("Texture"):GetComponent("UITexture")
      GUIUtils.FillIcon(uitex, itemBase.icon)
    else
      item:SetActive(false)
    end
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Tap_CommonFuBen" then
    self:SelectType(TeamDungeonType.NORMAL)
    self:SelectDungeon(0)
  elseif id == "Tap_EliteFuBen" then
    self:SelectType(TeamDungeonType.ELITE)
    self:SelectDungeon(0)
  elseif id == "Tap_HeroFuBen" then
    self:SelectType(TeamDungeonType.HERO)
    self:SelectDungeon(0)
  elseif id == "Tap_NightmareFuBen" then
    self:SelectType(TeamDungeonType.NIGHTMARE)
    self:SelectDungeon(0)
  elseif id == "Tap_ActictyFuBen" then
    self:SelectType(TeamDungeonType.ACTIVITY)
    self:SelectDungeon(0)
  elseif string.find(id, "Dungeon_") then
    local index = tonumber(string.sub(id, 9))
    self:SelectDungeon(index)
  elseif string.find(id, "Img_Item") then
    local index = tonumber(string.sub(id, 9))
    local teamDungeonCfg = DungeonUtils.GetTeamDungeonCfg(self.selectDungeon)
    local itemId = teamDungeonCfg.items[index]
    local source = self.m_panel:FindDirect("Img_Bg0/Group_Info/Img_BgInfo/Group_Item/" .. id)
    local position = source:get_position()
    local screenPos = WorldPosToScreen(position.x, position.y)
    local sprite = source:GetComponent("UISprite")
    local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
    ItemTipsMgr.Instance():ShowBasicTips(itemId, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), 0, false)
  elseif id == "Btn_QuickTeam" then
    local teamDungeonCfg = DungeonUtils.GetTeamDungeonCfg(self.selectDungeon)
    require("Main.TeamPlatform.ui.TeamPlatformPanel").Instance():FocusOnTarget(teamDungeonCfg.teamPlatformid)
  elseif id == "Btn_Enter" then
    DungeonModule.Instance().teamMgr:FightTeamDungeon(self.selectDungeon)
  end
end
TeamDungeonDlg.Commit()
return TeamDungeonDlg
