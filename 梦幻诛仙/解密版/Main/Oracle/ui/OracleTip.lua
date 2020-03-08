local Lplus = require("Lplus")
local GUIUtils = require("GUI.GUIUtils")
local ECPanelBase = require("GUI.ECPanelBase")
local Vector = require("Types.Vector")
local OracleData = require("Main.Oracle.data.OracleData")
local OraclePage = require("Main.Oracle.ui.OraclePage")
local OracleUtils = require("Main.Oracle.OracleUtils")
local OracleTip = Lplus.Extend(ECPanelBase, "OracleTip")
local def = OracleTip.define
local instance
def.static("=>", OracleTip).Instance = function()
  if instance == nil then
    instance = OracleTip()
  end
  return instance
end
def.field("userdata")._anchor = nil
def.field("table")._uiObjs = nil
def.field("number")._anchorType = OraclePage.ANCHOR_CENTER
def.field("table")._talentCfg = nil
def.field("table")._oracleAlloc = nil
def.field("function")._operateCallback = nil
def.static("userdata", "table", "table", "function", "number").ShowDlg = function(anchor, talentCfg, oracleAlloc, operateCallback, anchorType)
  if OracleTip.Instance()._anchor == anchor and OracleTip.Instance()._talentCfg == talentCfg then
    warn("[OracleTip:ShowDlg] same anchor and talent, return.")
    return
  end
  if nil == anchor then
    warn("[OracleTip:ShowDlg] anchor nil, return!")
    return
  end
  if nil == talentCfg then
    warn("[OracleTip:ShowDlg] talentCfg nil, return!")
    return
  end
  if nil == oracleAlloc then
    warn("[OracleTip:ShowDlg] oracleAlloc nil, return!")
    return
  end
  OracleTip.Instance():_InitTipInfo(anchor, talentCfg, oracleAlloc, operateCallback, anchorType)
  if OracleTip.Instance():IsShow() then
    OracleTip.Instance():OnShow(true)
  else
    OracleTip.Instance():CreatePanel(RESPATH.PERFAB_ORACLE_TIP, 2)
    OracleTip.Instance():SetOutTouchDisappear()
  end
end
def.method("userdata", "table", "table", "function", "number")._InitTipInfo = function(self, anchor, talentCfg, oracleAlloc, operateCallback, anchorType)
  self._anchor = anchor
  self._talentCfg = talentCfg
  self._oracleAlloc = oracleAlloc
  self._operateCallback = operateCallback
  self._anchorType = anchorType
end
def.override().OnCreate = function(self)
  self:SetModal(false)
  self:_InitUI()
end
def.method()._InitUI = function(self)
  self._uiObjs = {}
  self._uiObjs.tipFrame = self.m_panel:FindDirect("Img_Bg")
  self._uiObjs.Anchor_Single = self.m_panel:FindDirect("Point_Single")
  self._uiObjs.Anchor_Multi_Left = self.m_panel:FindDirect("Point_Double_Left")
  self._uiObjs.Anchor_Multi_Right = self.m_panel:FindDirect("Point_Double_Right")
  self._uiObjs.Img_Icon = self.m_panel:FindDirect("Img_Bg/Group_Icon/Img_BgIcon/Img_Icon")
  self._uiObjs.labelTitle = self.m_panel:FindDirect("Img_Bg/Group_Icon/Label_Title")
  self._uiObjs.Label_Lv = self.m_panel:FindDirect("Img_Bg/Group_Icon/Label_Lv")
  self._uiObjs.labelDesc = self.m_panel:FindDirect("Img_Bg/Label_Describe")
  self._uiObjs.Label_CurName = self.m_panel:FindDirect("Img_Bg/Label_CurName")
  self._uiObjs.Label_CurAtt = self.m_panel:FindDirect("Img_Bg/Label_CurAtt")
  self._uiObjs.Label_NextName = self.m_panel:FindDirect("Img_Bg/Label_NextName")
  self._uiObjs.Label_NextAtt = self.m_panel:FindDirect("Img_Bg/Label_NextAtt")
  self._uiObjs.labelTerm = self.m_panel:FindDirect("Img_Bg/Label_Term")
  self._uiObjs.Group_Button = self.m_panel:FindDirect("Img_Bg/Group_Button")
  self._uiObjs.btnAdd = self.m_panel:FindDirect("Img_Bg/Group_Button/Btn_Plus")
  self._uiObjs.btnReduce = self.m_panel:FindDirect("Img_Bg/Group_Button/Btn_Reduce")
  self._uiObjs.Label_Name = self.m_panel:FindDirect("Img_Bg/Group_Button/Label_Name")
  self._uiObjs.Label_Num = self.m_panel:FindDirect("Img_Bg/Group_Button/Label_Num")
end
def.override().OnDestroy = function(self)
  self._anchor = nil
  self._talentCfg = nil
  self._oracleAlloc = nil
  self._operateCallback = nil
  self._uiObjs = {}
end
def.override("boolean").OnShow = function(self, show)
  if show then
    self:_UpdateTip()
    self:_UpdatePos()
  end
end
def.method()._UpdatePos = function(self)
  local parentObj
  if self._anchorType == OraclePage.ANCHOR_CENTER then
    parentObj = self._uiObjs.Anchor_Single
  elseif self._anchorType == OraclePage.ANCHOR_LEFT then
    parentObj = self._uiObjs.Anchor_Multi_Left
  elseif self._anchorType == OraclePage.ANCHOR_RIGHT then
    parentObj = self._uiObjs.Anchor_Multi_Right
  else
    warn("[ERROR][OracleTip:_UpdatePos] invalid anchorType:", self._anchorType)
  end
  if parentObj then
    self._uiObjs.tipFrame.parent = parentObj
    self._uiObjs.tipFrame:set_localPosition(Vector.Vector3.zero)
    self._uiObjs.tipFrame:set_localScale(Vector.Vector3.one)
  end
end
def.method()._UpdateTip = function(self)
  local skillCfg = self._oracleAlloc:GetTalentSkillCfg(self._talentCfg.id)
  if skillCfg then
    self:_ShowTitle(skillCfg)
    self:_ShowDesc(skillCfg)
    self:_ShowTerm()
  else
    warn("[OracleTip:_UpdateTip] skillCfg nil for talent:", self._talentCfg.id)
  end
  local uiTable = self._uiObjs.tipFrame:GetComponent("UITableResizeBackground")
  uiTable:Reposition()
end
def.method("table")._ShowTitle = function(self, skillCfg)
  GUIUtils.FillIcon(self._uiObjs.Img_Icon:GetComponent("UITexture"), skillCfg.iconId)
  GUIUtils.SetText(self._uiObjs.labelTitle, skillCfg.name)
  local curPoints = self._oracleAlloc:GetTalentPoints(self._talentCfg.id)
  local maxPoints = OracleUtils.GetTalentMaxPoint(self._talentCfg.id)
  GUIUtils.SetText(self._uiObjs.Label_Lv, string.format(textRes.Oracle.ADD_TALENT_LEVEL, curPoints, maxPoints))
end
def.method("table")._ShowDesc = function(self, skillCfg)
  GUIUtils.SetText(self._uiObjs.labelDesc, skillCfg.description)
  local curTalentPoints = self._oracleAlloc:GetTalentPoints(self._talentCfg.id)
  if curTalentPoints < 1 then
    GUIUtils.SetActive(self._uiObjs.Label_CurName, false)
    GUIUtils.SetActive(self._uiObjs.Label_CurAtt, false)
  else
    local curSkillId = OracleUtils.GetSkillIdByTalentPoint(self._talentCfg.id, curTalentPoints)
    self:_ShowSkillEffect(curSkillId, self._uiObjs.Label_CurName, self._uiObjs.Label_CurAtt)
  end
  local maxTalentPoints = OracleUtils.GetTalentMaxPoint(self._talentCfg.id)
  if curTalentPoints >= maxTalentPoints then
    GUIUtils.SetActive(self._uiObjs.Label_NextName, false)
    GUIUtils.SetActive(self._uiObjs.Label_NextAtt, false)
  else
    local nextSkillId = OracleUtils.GetSkillIdByTalentPoint(self._talentCfg.id, curTalentPoints + 1)
    self:_ShowSkillEffect(nextSkillId, self._uiObjs.Label_NextName, self._uiObjs.Label_NextAtt)
  end
end
def.method("number", "userdata", "userdata")._ShowSkillEffect = function(self, skillId, titleLabel, effectLabel)
  local effectDesc = self:_GetPassiveSkillEffectsText(skillId)
  if effectDesc and "" ~= effectDesc then
    GUIUtils.SetActive(titleLabel, true)
    GUIUtils.SetActive(effectLabel, true)
    GUIUtils.SetText(effectLabel, effectDesc)
  else
    GUIUtils.SetActive(titleLabel, false)
    GUIUtils.SetActive(effectLabel, false)
  end
end
def.method("number", "=>", "string")._GetPassiveSkillEffectsText = function(self, skillId)
  local result = ""
  local textTable = {}
  local SkillUtility = require("Main.Skill.SkillUtility")
  local passiveSkillCfg = SkillUtility.GetPassiveSkillCfg(skillId)
  local SkillMgr = require("Main.Skill.SkillMgr")
  local passiveSkillEffects = passiveSkillCfg and SkillMgr.Instance():GetPassiveSkillEffects(skillId, 1) or nil
  if passiveSkillEffects then
    for k, effect in pairs(passiveSkillEffects) do
      local value = effect.value
      local strValue = tostring(value)
      if effect.fenmu == 10000 then
        value = string.format("%d%%", value / 100)
      end
      if effect.value >= 0 then
        strValue = textRes.Common.Plus .. strValue
      else
        strValue = textRes.Common.Minus .. strValue
      end
      local propNameCfg = GetCommonPropNameCfg(effect.prop)
      if propNameCfg then
        local text = string.format(textRes.Oracle.TALENT_SKILL_EFFECT, propNameCfg.propName, strValue)
        table.insert(textTable, text)
      else
        warn(string.format("[ERROR][OracleTip:_GetPassiveSkillEffectsText] propNameCfg nil for prop[%d] of skill[%d].", effect.prop, skillId))
      end
    end
  end
  if textTable and #textTable > 0 then
    result = table.concat(textTable, [[


]])
  end
  return result
end
def.method()._ShowTerm = function(self)
  if self._oracleAlloc:IsTalentFull(self._talentCfg.id) then
    self:_SetBtnsActive(false, self._oracleAlloc:CanReducePoint(self._talentCfg.id))
    GUIUtils.SetActive(self._uiObjs.labelTerm, false)
  elseif not self._oracleAlloc:IsTalentOpen(self._talentCfg.id) then
    self:_SetBtnsActive(false, false)
    GUIUtils.SetActive(self._uiObjs.labelTerm, true)
    local colorGreen = "00ff00"
    local colorRed = "ff0000"
    local term
    if self._talentCfg.previousPoint > 0 then
      local textColor = colorRed
      if self._oracleAlloc:GetCostPoints() >= self._talentCfg.previousPoint then
        textColor = colorGreen
      else
        textColor = colorRed
      end
      term = string.format(textRes.Oracle.TALENT_TIP_PRE_LAYER_POINTS, textColor, self._talentCfg.previousPoint)
    end
    if self._talentCfg.previousTalents then
      for preTalentId, preTalentPt in pairs(self._talentCfg.previousTalents) do
        local preSkillCfg = OracleUtils.GetTalentSkillCfg(preTalentId, preTalentPt)
        local textColor = colorRed
        if preTalentPt <= self._oracleAlloc:GetTalentPoints(preTalentId) then
          textColor = colorGreen
        else
          textColor = colorRed
        end
        local skillTerm = string.format(textRes.Oracle.TALENT_TIP_PRE_TALENT_SKILL, textColor, preSkillCfg and preSkillCfg.name or "", preTalentPt)
        if term == nil or term == "" then
          term = skillTerm
        else
          term = term .. "\n" .. skillTerm
        end
      end
    end
    GUIUtils.SetText(self._uiObjs.labelTerm, term)
  elseif 0 < self._oracleAlloc:GetRestPoints() then
    self:_SetBtnsActive(true, self._oracleAlloc:CanReducePoint(self._talentCfg.id))
    GUIUtils.SetActive(self._uiObjs.labelTerm, false)
  else
    self:_SetBtnsActive(false, self._oracleAlloc:CanReducePoint(self._talentCfg.id))
    local talentPoints = self._oracleAlloc:GetTalentPoints(self._talentCfg.id)
    GUIUtils.SetActive(self._uiObjs.labelTerm, talentPoints <= 0)
    if talentPoints <= 0 then
      GUIUtils.SetText(self._uiObjs.labelTerm, textRes.Oracle.TALENT_TIP_LACK_POINTS)
    end
  end
end
def.method("boolean", "boolean")._SetBtnsActive = function(self, bAddActive, bReduceActive)
  GUIUtils.SetActive(self._uiObjs.btnAdd, bAddActive)
  GUIUtils.SetActive(self._uiObjs.btnReduce, bReduceActive)
  GUIUtils.SetActive(self._uiObjs.Group_Button, bAddActive or bReduceActive)
  if bAddActive or bReduceActive then
    GUIUtils.SetActive(self._uiObjs.Label_Name, true)
    GUIUtils.SetActive(self._uiObjs.Label_Num, true)
    local curTalentPoints = self._oracleAlloc:GetTalentPoints(self._talentCfg.id)
    local maxTalentPoints = OracleUtils.GetTalentMaxPoint(self._talentCfg.id)
    local canUsePoint = math.min(self._oracleAlloc:GetRestPoints(), maxTalentPoints - curTalentPoints)
    GUIUtils.SetText(self._uiObjs.Label_Num, canUsePoint)
  else
    GUIUtils.SetActive(self._uiObjs.Label_Name, false)
    GUIUtils.SetActive(self._uiObjs.Label_Num, false)
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Plus" then
    self:OnBtn_Plus()
  else
    if id == "Btn_Reduce" then
      self:OnBtn_Reduce()
    else
    end
  end
end
def.method().OnBtn_Plus = function(self)
  if self._oracleAlloc:TryAllocatePoint(self._talentCfg.id, true) then
    self:_UpdateTip()
    if self._operateCallback then
      self._operateCallback(self._talentCfg.id, true)
    end
  end
end
def.method().OnBtn_Reduce = function(self)
  if self._oracleAlloc:TryDeallocatePoint(self._talentCfg.id, true) then
    self:_UpdateTip()
    if self._operateCallback then
      self._operateCallback(self._talentCfg.id, false)
    end
  end
end
OracleTip.Commit()
return OracleTip
