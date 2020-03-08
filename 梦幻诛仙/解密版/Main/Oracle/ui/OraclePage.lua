local Lplus = require("Lplus")
local GUIUtils = require("GUI.GUIUtils")
local ECPanelBase = require("GUI.ECPanelBase")
local Vector = require("Types.Vector")
local OracleData = require("Main.Oracle.data.OracleData")
local ItemModule = Lplus.ForwardDeclare("ItemModule")
local OracleUtils = require("Main.Oracle.OracleUtils")
local OraclePage = Lplus.Extend(ECPanelBase, "OraclePage")
local def = OraclePage.define
def.const("userdata").COLOR_DISABLE = Color.Color(0.45, 0.45, 0.45, 1)
def.const("userdata").COLOR_ENABLE = Color.Color(1, 1, 1, 1)
def.const("number").ANCHOR_LEFT = 1
def.const("number").ANCHOR_CENTER = 2
def.const("number").ANCHOR_RIGHT = 3
def.field("table")._uiObjs = nil
def.field("userdata")._anchor = nil
def.field("number")._anchorType = 2
def.field("table")._oracleCfg = nil
def.field("table")._talentMap = nil
def.field("table")._oracleAlloc = nil
def.field("table")._btn2TalentMap = nil
def.static("table", "userdata", "number", "=>", OraclePage).CreatePage = function(oracleCfg, anchor, anchorType)
  if nil == oracleCfg then
    error("[OraclePage:CreatePage] oracleCfg nil!")
    return nil
  end
  if nil == anchor then
    error("[OraclePage:CreatePage] anchor nil!")
    return nil
  end
  local page = OraclePage()
  page:_ShowPanel(oracleCfg, anchor, anchorType)
  return page
end
def.method("table", "userdata", "number")._ShowPanel = function(self, oracleCfg, anchor, anchorType)
  self._oracleCfg = oracleCfg
  self:_InitTalentCfgs()
  self._anchor = anchor
  self._anchorType = anchorType
  self:CreatePanel(self._oracleCfg.uiName, 0)
end
def.method()._InitTalentCfgs = function(self)
  self._talentMap = {}
  if self._oracleCfg then
    self._talentMap = OracleData.Instance():GetOracleTalentCfgs(self._oracleCfg.id)
  end
end
def.override().OnCreate = function(self)
  self:SetModal(false)
  self:_SetAnchor()
  self:_InitUI()
end
def.method()._SetAnchor = function(self)
  if self._anchor then
    if self.m_panel.parent ~= self._anchor then
      self.m_panel.parent = self._anchor
      self.m_panel:set_localPosition(Vector.Vector3.zero)
      self.m_panel:set_localScale(Vector.Vector3.one)
    end
  else
    self:DestroyPanel()
  end
end
def.method()._InitUI = function(self)
  self._uiObjs = {}
  self._uiObjs.Img_Bg = self.m_panel:FindDirect("Img_Bg")
  self._uiObjs.Btn_Reset = self.m_panel:FindDirect("Btn_Reset")
  self._uiObjs.Btn_Save = self.m_panel:FindDirect("Btn_Save")
  self._uiObjs.Label_Num = self.m_panel:FindDirect("Group_Point/Label_Num")
  self._uiObjs.btnSwitchGrop = self.m_panel:FindDirect("Group_Change")
  self._btn2TalentMap = {}
  self._uiObjs.talentBtns = {}
  local talentBtn
  for talentId, talentCfg in pairs(self._talentMap) do
    talentBtn = self.m_panel:FindDirect(talentCfg.uiName)
    if talentBtn then
      self._uiObjs.talentBtns[talentId] = talentBtn
      self._btn2TalentMap[talentBtn.name] = talentCfg
    else
      warn(string.format("[OraclePage:_InitUI] can not find talentBtn[%s] for talent[%d] of oracle[%d].", talentCfg.uiName, talentId, self._oracleCfg.id))
    end
  end
end
def.override("boolean").OnShow = function(self, show)
  if show then
    self:UpdatePage()
  end
end
def.method().UpdatePage = function(self)
  self:_FetchOracleAllocation()
  self:ShowTalents()
  self:UpdatePoints()
  self:UpdateChosenState()
end
def.method()._FetchOracleAllocation = function(self)
  self._oracleAlloc = OracleData.Instance():GetAllocCopyByOracleId(self._oracleCfg.id)
end
def.method().ShowTalents = function(self)
  if nil == self._talentMap then
    error("[OraclePage:ShowTalents] self._talentMap nil!")
    return
  end
  for talentId, talentCfg in pairs(self._talentMap) do
    self:UpdateTalent(talentId)
  end
end
def.method("number").UpdateTalent = function(self, talentId)
  local talentBtn = self._uiObjs.talentBtns[talentId]
  local talentCfg = self._talentMap[talentId]
  if talentBtn and talentCfg then
    local skillIcon = talentBtn:FindDirect("Icon_ItemSkillIcon")
    local skillCfg = self._oracleAlloc:GetTalentSkillCfg(talentId)
    if skillCfg then
      GUIUtils.FillIcon(skillIcon:GetComponent("UITexture"), skillCfg.iconId)
    else
      warn("[OraclePage:UpdateTalent] skillCfg nil for talent:", talentId)
    end
    self:_UpdateTalentOpenState(talentId, talentBtn)
    local numLabel = talentBtn:FindDirect("Img_NumBg/Label_Num")
    local curPoints = self._oracleAlloc:GetTalentPoints(talentId)
    local maxPoints = talentCfg.maxPoints
    GUIUtils.SetText(numLabel, curPoints .. "/" .. maxPoints)
  elseif talentBtn == nil then
    warn(string.format("[OraclePage:UpdateTalent] talentBtn nil for talent[%d] of oracle[%d].", talentId, self._oracleCfg.id))
  else
    warn(string.format("[OraclePage:UpdateTalent] talentCfg nil for talent[%d] of oracle[%d].", talentId, self._oracleCfg.id))
  end
end
def.method("number", "userdata")._UpdateTalentOpenState = function(self, talentId, talentBtn)
  if talentBtn then
    local skillIcon = talentBtn:FindDirect("Icon_ItemSkillIcon")
    local color
    if self._oracleAlloc:IsTalentOpen(talentId) then
      color = OraclePage.COLOR_ENABLE
    else
      color = OraclePage.COLOR_DISABLE
    end
    GUIUtils.SetColor(skillIcon, color, GUIUtils.COTYPE.TEXTURE)
  else
    warn("[OraclePage:_UpdateTalentOpenState] talentBtn nil!")
  end
end
def.method().UpdateTalentsOpenState = function(self)
  for talentId, talentCfg in pairs(self._talentMap) do
    local talentBtn = self._uiObjs.talentBtns[talentId]
    self:_UpdateTalentOpenState(talentId, talentBtn)
  end
end
def.method().UpdatePoints = function(self)
  local restPoints = self._oracleAlloc:GetRestPoints()
  local totalPoints = OracleData.Instance():GetTotalPoints() or 0
  GUIUtils.SetText(self._uiObjs.Label_Num, restPoints .. "/" .. totalPoints)
end
def.method().UpdateChosenState = function(self)
  GUIUtils.SetActive(self._uiObjs.Btn_Save, self:IsCurrentOracle())
  local color
  if self:IsCurrentOracle() then
    color = OraclePage.COLOR_ENABLE
  else
    color = OraclePage.COLOR_DISABLE
  end
  GUIUtils.SetColor(self._uiObjs.Img_Bg, color, GUIUtils.COTYPE.SPRITE)
  if self._anchorType == OraclePage.ANCHOR_RIGHT then
    GUIUtils.SetActive(self._uiObjs.btnSwitchGrop, true)
  else
    GUIUtils.SetActive(self._uiObjs.btnSwitchGrop, false)
  end
end
def.override().OnDestroy = function(self)
  self._uiObjs = {}
  self._anchor = nil
  self._anchorType = 2
  self._oracleCfg = nil
  self._talentMap = nil
  if self._oracleAlloc then
    self._oracleAlloc:Release()
    self._oracleAlloc = nil
  end
  self._btn2TalentMap = nil
end
def.method("string", "=>", "boolean").onClick = function(self, id)
  if id == "Btn_Reset" then
    self:OnBtn_Reset()
    return true
  elseif id == "Btn_Save" then
    self:OnBtn_Save()
    return true
  elseif id == "Btn_Change" then
    self:OnBtn_Change()
    return true
  elseif self._btn2TalentMap then
    for btnName, talentCfg in pairs(self._btn2TalentMap) do
      if btnName == id then
        self:OnTalentClicked(talentCfg)
        return true
      end
    end
  end
  return false
end
def.method().OnBtn_Reset = function(self)
  if self:IsCurrentOracle() and nil ~= OracleData.Instance():GetCurrentAllocation() then
    require("GUI.CommonConfirmDlg").ShowConfirm(textRes.Oracle.ORACLE_RESET_CONFIRM_TITLE, string.format(textRes.Oracle.ORACLE_RESET_CONFIRM_CONTENT, constant.COracleConsts.RESET_GENIUS_COST_GOLD), function(id, tag)
      if id == 1 then
        local goldnum = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_GOLD)
        if Int64.lt(goldnum, constant.COracleConsts.RESET_GENIUS_COST_GOLD) then
          _G.GoToBuyGold(true)
        else
          self:_DoReset()
        end
      end
    end, nil)
  else
    self:_DoReset()
  end
end
def.method()._DoReset = function(self)
  if self._oracleAlloc then
    if not self._oracleAlloc:IsEmpty() then
      self._oracleAlloc:Reset()
      self:UpdatePage()
    else
      warn("[OraclePage:_DoReset] reset failed, self._oracleAlloc is empty!")
    end
  else
    warn("[OraclePage:_DoReset] self._oracleAlloc nil!")
  end
end
def.method().OnBtn_Save = function(self)
  if self:NeedSave() then
    self:DoSave()
  else
    warn("[OraclePage:OnBtn_Save] save failed, self._oracleAlloc is not dirty!")
  end
end
def.method().DoSave = function(self)
  if self._oracleAlloc then
    self._oracleAlloc:Save()
  end
end
def.method("=>", "boolean").NeedSave = function(self)
  if self._oracleAlloc and self:IsCurrentOracle() then
    return self._oracleAlloc:IsDirty()
  else
    warn("[OraclePage:NeedSave] self._oracleAlloc nil!")
    return false
  end
end
def.method("table").OnTalentClicked = function(self, talentCfg)
  require("Main.Oracle.ui.OracleTip").ShowDlg(self._uiObjs.talentBtns[talentCfg.id], talentCfg, self._oracleAlloc, function(talentId, bAlloc)
    self:_OnOperateTalent(talentId, bAlloc)
  end, self._anchorType)
end
def.method("number", "boolean")._OnOperateTalent = function(self, talentId, bAlloc)
  self:UpdateTalent(talentId)
  self:UpdateTalentsOpenState()
  self:UpdatePoints()
end
def.method("=>", "boolean").IsCurrentOracle = function(self)
  return self._oracleCfg and self._oracleCfg.id == OracleData.Instance():GetCurrentOracleId()
end
def.method().OnBtn_Change = function(self)
  if self._anchorType == OraclePage.ANCHOR_RIGHT then
    warn("[OraclePage:OnBtn_Change] Btn_Change clicked.")
    local DlgOracle = require("Main.Oracle.ui.DlgOracle")
    if DlgOracle.Instance():IsShow() then
      DlgOracle.Instance():OnBtn_Change()
    end
  else
    warn("[OraclePage:OnBtn_Change] self._anchorType~=OraclePage.ANCHOR_RIGHT.")
  end
end
OraclePage.Commit()
return OraclePage
