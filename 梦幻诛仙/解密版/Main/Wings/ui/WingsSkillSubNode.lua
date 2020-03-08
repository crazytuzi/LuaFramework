local Lplus = require("Lplus")
local GUIUtils = require("GUI.GUIUtils")
local WingsSubNodeBase = require("Main.Wings.ui.WingsSubNodeBase")
local PersonalHelper = require("Main.Chat.PersonalHelper")
local WingsUtility = require("Main.Wings.WingsUtility")
local SkillUtility = require("Main.Skill.SkillUtility")
local WingsDataMgr = require("Main.Wings.data.WingsDataMgr")
local WingsPanel = Lplus.ForwardDeclare("WingsPanel")
local WingsSkillSubNode = Lplus.Extend(WingsSubNodeBase, "WingsSkillSubNode")
local def = WingsSkillSubNode.define
def.field("table").skillTable = nil
def.field("number").mainSkillNum = 0
local instance
def.static("=>", WingsSkillSubNode).Instance = function()
  if instance == nil then
    instance = WingsSkillSubNode()
  end
  return instance
end
def.override(WingsPanel, "userdata").Init = function(self, base, node)
  WingsSubNodeBase.Init(self, base, node)
end
def.override().OnShow = function(self)
  self:UpdateUI()
  Event.RegisterEvent(ModuleId.WINGS, gmodule.notifyId.Wings.WINGS_PHASEUP_CONSUME, WingsSkillSubNode.OnPhaseUpConsume)
  Event.RegisterEvent(ModuleId.WINGS, gmodule.notifyId.Wings.WINGS_PHASE_UP, WingsSkillSubNode.OnWingsPhaseUp)
end
def.override().OnHide = function(self)
  Event.UnregisterEvent(ModuleId.WINGS, gmodule.notifyId.Wings.WINGS_PHASEUP_CONSUME, WingsSkillSubNode.OnPhaseUpConsume)
  Event.UnregisterEvent(ModuleId.WINGS, gmodule.notifyId.Wings.WINGS_PHASE_UP, WingsSkillSubNode.OnWingsPhaseUp)
  self:ClearUp()
end
def.method().UpdateUI = function(self)
  self:UpdatePhaseUpNotice()
  self:UpdateSkillGrids()
  self:UpdateQualityGrids()
end
def.method().UpdatePhaseUpNotice = function(self)
  local imgRed = self.m_node:FindDirect("Btn_UpLevel/Img_Red")
  local isReadyToPhaseUp = WingsDataMgr.Instance():CheckCanPhaseUp()
  imgRed:SetActive(isReadyToPhaseUp)
end
def.method().UpdateSkillGrids = function(self)
  self.skillTable = WingsDataMgr.Instance():GetCurrentSkillTable()
  if not self.skillTable then
    return
  end
  self:UpdateMainSkillGrids()
  self:UpdateSubSkillGrids()
end
def.method().ClearUp = function(self)
  self.skillTable = nil
  self.mainSkillNum = 0
end
def.method().UpdateMainSkillGrids = function(self)
  local mainSkillTable = self.skillTable.mainSkills
  local gridMainSkill = self.m_node:FindDirect("Scroll View/Grid_Zhu")
  for i = 1, WingsDataMgr.WING_MAIN_SKILL_NUM do
    local cell = gridMainSkill:FindDirect("Zhu_" .. i)
    self:SetSkillCellUI(cell, mainSkillTable[i], i, true)
  end
end
def.method().UpdateSubSkillGrids = function(self)
  local subSkillTable = self.skillTable.subSkills
  local gridSubSkill = self.m_node:FindDirect("Scroll View/Grid_Fu")
  local idx = 1
  for i = 1, WingsDataMgr.WING_MAIN_SKILL_NUM do
    for j = 1, WingsDataMgr.WING_SUB_SKILL_NUM do
      local cell = gridSubSkill:FindDirect("Fu_" .. idx)
      self:SetSkillCellUI(cell, subSkillTable[idx], i, false)
      idx = idx + 1
    end
  end
end
def.method("userdata", "table", "number", "boolean").SetSkillCellUI = function(self, cell, skillInfo, lineNum, isMain)
  if not cell then
    return
  end
  if not skillInfo then
    return
  end
  local texture = cell:FindDirect("Texture")
  local sprite = cell:FindDirect("Sprite")
  local label = cell:FindDirect("Label")
  if isMain then
    if skillInfo.id ~= 0 then
      texture:SetActive(true)
      GUIUtils.FillIcon(texture:GetComponent("UITexture"), skillInfo.cfg.iconId)
      self.mainSkillNum = self.mainSkillNum + 1
    else
      texture:SetActive(false)
    end
  elseif skillInfo.id ~= 0 then
    texture:SetActive(true)
    GUIUtils.FillIcon(texture:GetComponent("UITexture"), skillInfo.cfg.iconId)
  else
    texture:SetActive(false)
  end
  sprite:SetActive(false)
  label:SetActive(false)
end
def.method().UpdateQualityGrids = function(self)
  local phase = WingsDataMgr.Instance():GetCurrentWingsPhase()
  local gridQuality = self.m_node:FindDirect("Grid_PinJie")
  for i = 1, WingsDataMgr.WING_PHASE_LIMIT do
    local img = gridQuality:FindDirect(string.format("Img_QL_Sign%02d", i))
    if i <= phase then
      img:SetActive(true)
    else
      img:SetActive(false)
    end
  end
end
def.override("string").onClick = function(self, id)
  if id == "Btn_UpLevel" then
    self:OnBtnPhaseUpClicked()
  elseif id == "Btn_Tips" then
    self:OnBtnTipsClicked()
    local ECMSDK = require("ProxySDK.ECMSDK")
    ECMSDK.SendTLogToServer(_G.TLOGTYPE.PANELNAME, {
      self.m_node.name
    })
  elseif id == "Btn_ResetSkill" then
    self:OnBtnResetSkillsClicked()
  elseif id == "Btn_Gallery" then
    require("Main.Wings.ui.WingsSkillGallery").Instance():ShowPanel()
  elseif string.find(id, "Zhu") or string.find(id, "Fu") then
    self:OnSkillTipsClicked(id)
  end
end
def.method("string").OnSkillTipsClicked = function(self, id)
  if not self.skillTable then
    return
  end
  local idx, cell, skillCfg
  if string.find(id, "Zhu") then
    idx = tonumber(string.sub(id, 5))
    cell = self.m_node:FindDirect("Scroll View/Grid_Zhu"):FindDirect(id)
    skillCfg = self.skillTable.mainSkills[idx]
  elseif string.find(id, "Fu") then
    idx = tonumber(string.sub(id, 4))
    cell = self.m_node:FindDirect("Scroll View/Grid_Fu"):FindDirect(id)
    skillCfg = self.skillTable.subSkills[idx]
  end
  if not skillCfg or skillCfg.id == 0 or not skillCfg.cfg then
    return
  end
  require("Main.Skill.SkillTipMgr").Instance():ShowTipByIdEx(skillCfg.cfg.id, cell, 0)
end
def.method().OnBtnResetSkillsClicked = function(self)
  if self.mainSkillNum == 0 then
    Toast("\232\191\152\230\178\161\230\156\137\231\190\189\231\191\188\230\138\128\232\131\189")
    return
  end
  local idx = WingsDataMgr.Instance():GetCurrentSchemaIdx()
  if idx then
    local p = require("netio.protocol.mzm.gsp.wing.CQueryResetSkill").new(idx)
    gmodule.network.sendProtocol(p)
    require("Main.Wings.ui.WingsSkillResetPanel").Instance():ShowPanel()
  end
end
def.override().OnWingsSchemaChanged = function(self)
  self:UpdateUI()
end
def.method().OnBtnPhaseUpClicked = function(self)
  if not WingsDataMgr.Instance():IsWingsFuncUnlocked() then
    return
  end
  local curWingsLevel = WingsDataMgr.Instance():GetCurrentLevelExp().level
  local curPhase = WingsDataMgr.Instance():GetCurrentWingsPhase()
  local phaseUpCfg = WingsUtility.GetPhaseUpCfg(curPhase)
  if not phaseUpCfg then
    Toast(textRes.Wings[15])
    return
  end
  if curWingsLevel < phaseUpCfg.needWingLevel then
    Toast(string.format(textRes.Wings[16], phaseUpCfg.needWingLevel))
    return
  end
  self:SendOpenPhaseUpReq()
end
def.method().SendOpenPhaseUpReq = function(self)
  local idx = WingsDataMgr.Instance():GetCurrentSchemaIdx()
  if idx then
    local p = require("netio.protocol.mzm.gsp.wing.COpenWingPhaseUp").new(idx)
    gmodule.network.sendProtocol(p)
  end
end
def.method().SendPhaseUpReq = function(self)
  local idx = WingsDataMgr.Instance():GetCurrentSchemaIdx()
  if idx then
    local p = require("netio.protocol.mzm.gsp.wing.CWingPhaseUp").new(idx)
    gmodule.network.sendProtocol(p)
  end
end
def.method().OnBtnTipsClicked = function(self)
  local tmpPosition = {x = 0, y = 0}
  local CommonDescDlg = require("GUI.CommonUITipsDlg")
  local tipString = require("Main.Common.TipsHelper").GetHoverTip(WingsDataMgr.WING_SKILL_TIP_ID)
  if tipString == "" then
    return
  end
  CommonDescDlg.ShowCommonTip(tipString, tmpPosition)
end
def.static("table", "table").OnPhaseUpConsume = function(params, context)
  local ItemConsumeHelper = require("Main.Item.ItemConsumeHelper")
  local curPhase = WingsDataMgr.Instance():GetCurrentWingsPhase()
  local phaseUpCfg = WingsUtility.GetPhaseUpCfg(curPhase)
  local needItemId = phaseUpCfg.needItemId
  local needItemNum = phaseUpCfg.needItemNum
  local toPhase = WingsDataMgr.Instance():GetCurrentWingsPhase() + 1
  ItemConsumeHelper.Instance():ShowItemConsume(textRes.Wings[17], string.format(textRes.Wings[18], toPhase), needItemId, needItemNum, function(select)
    if select >= 0 then
      instance:SendPhaseUpReq()
    else
      return
    end
  end)
end
def.static("table", "table").OnWingsPhaseUp = function(params, context)
  instance:UpdateUI()
end
return WingsSkillSubNode.Commit()
