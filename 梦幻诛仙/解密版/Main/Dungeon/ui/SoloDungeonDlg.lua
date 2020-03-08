local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local SoloDungeonDlg = Lplus.Extend(ECPanelBase, "SoloDungeonDlg")
local DungeonUtils = require("Main.Dungeon.DungeonUtils")
local DungeonModule = require("Main.Dungeon.DungeonModule")
local GUIUtils = require("GUI.GUIUtils")
local MissionType = require("consts.mzm.gsp.instance.confbean.ProcessType")
local EC = require("Types.Vector3")
local def = SoloDungeonDlg.define
local _instance
def.field("number").selectDungeon = 0
def.field("table").selection2Id = nil
def.field("table").Missions = function()
  return {}
end
def.field("boolean").dungeonListShow = false
def.static("=>", SoloDungeonDlg).Instance = function()
  if _instance == nil then
    _instance = SoloDungeonDlg()
  end
  return _instance
end
def.static("number").ShowSoloDungeon = function(selectDungeon)
  local dlg = SoloDungeonDlg.Instance()
  dlg.selectDungeon = selectDungeon
  dlg:CreatePanel(RESPATH.PREFAB_DUNGEON_SOLO, 1)
  dlg:SetModal(true)
end
def.override().OnCreate = function(self)
  Event.RegisterEventWithContext(ModuleId.DUNGEON, gmodule.notifyId.Dungeon.SOLO_DUNGEON_SAODANG, SoloDungeonDlg.OnSoloUpdate, self)
  self:SetLeftTimes()
  self:UpdateSaoDang()
  self:SetDungeonSelection()
  self:SetDungeonInfo()
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.DUNGEON, gmodule.notifyId.Dungeon.SOLO_DUNGEON_SAODANG, SoloDungeonDlg.OnSoloUpdate)
end
def.method("table").OnSoloUpdate = function(self, param)
  if self:IsShow() then
    self:SetLeftTimes()
    self:SetDungeonInfo()
    local effectPath = GetEffectRes(DungeonUtils.GetDungeonConst().EffectId)
    require("Fx.GUIFxMan").Instance():Play(effectPath.path, "saodang", 0, 0, -1, false)
  end
end
def.method("number").SelectDungeon = function(self, id)
  self.selectDungeon = id
  self:SetDungeonSelection()
  self:SetDungeonInfo()
  self:UpdateSaoDang()
end
def.method().SetDungeonSelection = function(self)
  local btn_label = self.m_panel:FindDirect("Img_Bg/Panel_Info/Btn_FightMap/Label_CopyName"):GetComponent("UILabel")
  local title = self.m_panel:FindDirect("Img_Bg/Img_Title/Label_Title"):GetComponent("UILabel")
  local mylv = require("Main.Hero.HeroModule").Instance():GetHeroProp().level
  local curDungeonCfg = DungeonUtils.GetDungeonCfg(self.selectDungeon)
  local btnStr = string.format(textRes.Dungeon[1], curDungeonCfg.level, curDungeonCfg.name)
  btn_label:set_text(btnStr)
  title:set_text(curDungeonCfg.name)
  self:SetDungeonBtns(false)
end
def.method("boolean").SetDungeonBtns = function(self, show)
  local mylv = require("Main.Hero.HeroModule").Instance():GetHeroProp().level
  local btns = self.m_panel:FindDirect("Img_Bg/Panel_Info/Table_TeamBtn")
  local upArrow = self.m_panel:FindDirect("Img_Bg/Panel_Info/Btn_FightMap/Img_Up")
  local downArrow = self.m_panel:FindDirect("Img_Bg/Panel_Info/Btn_FightMap/Img_Down")
  if show then
    upArrow:SetActive(true)
    downArrow:SetActive(false)
    btns:SetActive(true)
    local SingleDungeons = DungeonUtils.GetSingleDungeons()
    local template = btns:FindDirect("DungeonBtn")
    template:SetActive(false)
    while btns:get_childCount() > 2 do
      local toBeDelete = btns:GetChild(btns:get_childCount() - 1)
      if toBeDelete.name ~= template.name and toBeDelete.name ~= "spaceHolder" then
        Object.DestroyImmediate(toBeDelete)
      end
    end
    for k, v in ipairs(SingleDungeons) do
      local str = string.format(textRes.Dungeon[1], v.level, v.name)
      local newBtn = Object.Instantiate(template)
      newBtn:SetActive(true)
      newBtn:FindDirect("Label_bTN"):GetComponent("UILabel"):set_text(str)
      newBtn.parent = btns
      newBtn.name = string.format("DungeonBtn_%d", v.id)
      newBtn:set_localScale(EC.Vector3.one)
      if mylv >= v.level then
        newBtn:GetComponent("UIButton"):set_isEnabled(true)
      else
        newBtn:GetComponent("UIButton"):set_isEnabled(false)
      end
      self.m_msgHandler:Touch(newBtn)
    end
    btns:GetComponent("UITableResizeBackground"):Reposition()
    self.dungeonListShow = true
  else
    upArrow:SetActive(false)
    downArrow:SetActive(true)
    btns:SetActive(false)
    self.dungeonListShow = false
  end
end
def.method().SetLeftTimes = function(self)
  local lefttimes = DungeonUtils.GetDungeonConst().FailTimeAll - DungeonModule.Instance().singleFailTimes
  local label = self.m_panel:FindDirect("Img_Bg/Panel_Info/Img_FightNum/Label_Num"):GetComponent("UILabel")
  label:set_text(lefttimes)
end
def.method().UpdateSaoDang = function(self)
  local btn = self.m_panel:FindDirect("Img_Bg/Panel_Info/Btn_Sweep")
  local open = IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_SINGLE_INSTANCE_SAO_DANG)
  if open then
    btn:SetActive(true)
  else
    btn:SetActive(false)
  end
  local tipLbl = self.m_panel:FindDirect("Img_Bg/Label_Tips")
  local tipStr = textRes.Dungeon[55]
  local soloDungeonSaoDangCfg = DungeonUtils.GetSoloDungeonSaoDangCfg(self.selectDungeon)
  if soloDungeonSaoDangCfg then
    tipStr = string.format(textRes.Dungeon[57], soloDungeonSaoDangCfg.sao_dang_open_process_id)
  end
  tipLbl:GetComponent("UILabel"):set_text(tipStr)
end
def.method().SetDungeonInfo = function(self)
  self:ClearDungeonInfo()
  self:GenerateMissonIcon()
  self:SetIconState()
end
def.method().ClearDungeonInfo = function(self)
  for k, v in pairs(self.Missions) do
    Object.Destroy(v)
  end
  self.Missions = {}
end
def.method().GenerateMissonIcon = function(self)
  local soloDungeonCfg = DungeonUtils.GetSoloDungeonCfg(self.selectDungeon)
  local template = self.m_panel:FindDirect("Img_Bg/Img_MainFrame/Scroll View/Texture_Bg/Group_Target")
  template:SetActive(false)
  local root = self.m_panel:FindDirect("Img_Bg/Img_MainFrame/Scroll View/Texture_Bg")
  local mostfar = 0
  for k, v in pairs(soloDungeonCfg) do
    local itemNew = Object.Instantiate(template)
    itemNew:SetActive(true)
    itemNew:set_name(string.format("Mission_%d", v.processId))
    itemNew.parent = root
    itemNew:set_localScale(EC.Vector3.one)
    local x = v.posX
    local y = v.posY
    if mostfar < x then
      mostfar = x
    end
    itemNew:set_localPosition(EC.Vector3.new(x, y, 0))
    self:SetIcon(itemNew, v)
    self.Missions[k] = itemNew
  end
  local bgTexture = self.m_panel:FindDirect("Img_Bg/Img_MainFrame/Scroll View/Texture_Bg"):GetComponent("UITexture")
  bgTexture:set_width(mostfar + 100)
  local dungeonCfg = DungeonUtils.GetDungeonCfg(self.selectDungeon)
  GUIUtils.FillIcon(bgTexture, dungeonCfg.image)
  self:TouchGameObject(self.m_panel, self.m_parent)
end
def.method("userdata", "table").SetIcon = function(self, itemNew, data)
  local missionNameLabel = itemNew:FindDirect("Label_name"):GetComponent("UILabel")
  missionNameLabel:set_text(data.name)
  local missionNumLabel = itemNew:FindDirect("Img_Num"):GetComponent("UILabel")
  missionNumLabel:set_text(data.processId)
  local btn = itemNew:FindDirect("Btn_Target")
  local bossFlag = itemNew:FindDirect("Img_Boss")
  bossFlag:SetActive(data.type == MissionType.BOSS)
  local monsterCfg = DungeonUtils.GetDungeonMonsterCfg(data.monsterId)
  if monsterCfg and monsterCfg.headIcon and monsterCfg.headIcon > 0 then
    local headIcon = btn:FindDirect("Img_Head"):GetComponent("UITexture")
    GUIUtils.FillIcon(headIcon, monsterCfg.headIcon)
  end
  local lockFlag = btn:FindDirect("Img_Lock")
  lockFlag:SetActive(false)
  local pass = btn:FindDirect("Img_Pass")
  pass:SetActive(false)
  local select = btn:FindDirect("Img_Select")
  select:SetActive(false)
  btn:set_name(string.format("Mission_%d", data.processId))
end
def.method().SetIconState = function(self)
  local dungeonCfg = DungeonUtils.GetDungeonCfg(self.selectDungeon)
  local mylv = require("Main.Hero.HeroModule").Instance():GetHeroProp().level
  local farMission = 0
  local finishTime = 0
  local curProcess = 1
  local opened = mylv >= dungeonCfg.level and mylv < dungeonCfg.closeLevel
  local dungeonInfo = DungeonModule.Instance():GetSoloDungeonInfo(self.selectDungeon)
  if dungeonInfo then
    farMission = dungeonInfo.highProcess
    finishTime = dungeonInfo.finishTimes
    curProcess = dungeonInfo.curProcess
    opened = dungeonInfo.open
  end
  for k, v in pairs(self.Missions) do
    local btn = v:FindDirect(string.format("Mission_%d", k))
    local lockFlag = btn:FindDirect("Img_Lock")
    local pass = btn:FindDirect("Img_Pass")
    local select = btn:FindDirect("Img_Select")
    local head = btn:FindDirect("Img_Head")
    if k <= farMission then
      lockFlag:SetActive(false)
      head:SetActive(true)
    else
      lockFlag:SetActive(true)
      head:SetActive(false)
    end
  end
  for k, v in pairs(self.Missions) do
    local btn = v:FindDirect(string.format("Mission_%d", k))
    local lockFlag = btn:FindDirect("Img_Lock")
    local pass = btn:FindDirect("Img_Pass")
    local select = btn:FindDirect("Img_Select")
    local head = btn:FindDirect("Img_Head")
    local headTexture = head:GetComponent("UITexture")
    local gray = btn:FindDirect("Img_BgIcon2")
    if finishTime > 0 then
      pass:SetActive(true)
      lockFlag:SetActive(false)
      head:SetActive(true)
      select:SetActive(false)
      gray:SetActive(false)
    elseif k < curProcess then
      pass:SetActive(true)
      select:SetActive(false)
      gray:SetActive(false)
    elseif k == curProcess then
      pass:SetActive(false)
      select:SetActive(true)
      lockFlag:SetActive(false)
      head:SetActive(true)
      gray:SetActive(false)
    elseif k > farMission then
      gray:SetActive(false)
      pass:SetActive(false)
      select:SetActive(false)
    else
      gray:SetActive(true)
      pass:SetActive(false)
      select:SetActive(false)
    end
  end
  if self.Missions[curProcess] then
    local scrollView = self.m_panel:FindDirect("Img_Bg/Img_MainFrame/Scroll View"):GetComponent("UIScrollView")
    scrollView:DragToMakeVisible(self.Missions[curProcess].transform, 4)
  end
end
def.method().SaoDang = function(self)
  if DungeonModule.Instance().State == DungeonModule.DungeonState.OUT then
    local soloDungeonSaoDangCfg = DungeonUtils.GetSoloDungeonSaoDangCfg(self.selectDungeon)
    if soloDungeonSaoDangCfg then
      local soloDungeonInfo = DungeonModule.Instance():GetSoloDungeonInfo(self.selectDungeon)
      local farMission = 0
      if soloDungeonInfo then
        farMission = soloDungeonInfo.highProcess
      end
      local toMission = farMission - soloDungeonSaoDangCfg.sao_dang_reserve_process_num
      if DungeonModule.Instance().soloMgr then
        DungeonModule.Instance().soloMgr:SaoDangDungeon(self.selectDungeon, toMission)
      end
    else
      Toast(textRes.Dungeon[55])
    end
  else
    Toast(textRes.Dungeon[58])
  end
end
def.method("string", "string", "number").onSelect = function(self, id, selected, index)
  if id == "Btn_FightMap" then
    local dungeonId = self.selection2Id[index]
    self:SelectDungeon(dungeonId)
  end
end
def.method("string").onClick = function(self, id)
  if id ~= "Btn_FightMap" and self.dungeonListShow then
    self:SetDungeonBtns(false)
  end
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_Help" then
    local tipsId = DungeonUtils.GetDungeonConst().TipsId
    GUIUtils.ShowHoverTip(tipsId)
  elseif id == "Btn_Sweep" then
    self:SaoDang()
  elseif id == "Btn_FightMap" then
    if self.dungeonListShow then
      self:SetDungeonBtns(false)
    else
      self:SetDungeonBtns(true)
    end
  elseif string.find(id, "DungeonBtn_") then
    local index = tonumber(string.sub(id, 12))
    self:SelectDungeon(index)
  elseif string.find(id, "Mission_") then
    local index = tonumber(string.sub(id, 9))
    local farMission = 0
    local finishTime = 0
    local curProcess = 1
    local dungeonCfg = DungeonUtils.GetDungeonCfg(self.selectDungeon)
    local mylv = require("Main.Hero.HeroModule").Instance():GetHeroProp().level
    local opened = mylv >= dungeonCfg.level and mylv < dungeonCfg.closeLevel
    local dungeonInfo = DungeonModule.Instance():GetSoloDungeonInfo(self.selectDungeon)
    if dungeonInfo then
      farMission = dungeonInfo.highProcess
      finishTime = dungeonInfo.finishTimes
      curProcess = dungeonInfo.curProcess
      opened = dungeonInfo.open
    end
    local SoloMissionDlg = require("Main.Dungeon.ui.SoloMissionDlg")
    if opened then
      if finishTime > 0 then
        SoloMissionDlg.ShowMission(self.selectDungeon, index, -1)
      elseif index == curProcess then
        SoloMissionDlg.ShowMission(self.selectDungeon, index, 0)
      elseif index > farMission then
        Toast(textRes.Dungeon[9])
      elseif index > curProcess then
        SoloMissionDlg.ShowMission(self.selectDungeon, index, 1)
      else
        SoloMissionDlg.ShowMission(self.selectDungeon, index, -1)
      end
    elseif index == curProcess then
      SoloMissionDlg.ShowMission(self.selectDungeon, index, -2)
    elseif index > farMission then
      Toast(textRes.Dungeon[9])
    else
      SoloMissionDlg.ShowMission(self.selectDungeon, index, -2)
    end
  end
end
SoloDungeonDlg.Commit()
return SoloDungeonDlg
