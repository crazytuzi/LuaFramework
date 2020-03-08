local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local UIEditTeamName = Lplus.Extend(ECPanelBase, "UIEditTeamName")
local Cls = UIEditTeamName
local def = Cls.define
local instance
local GangTeamMgr = require("Main.Gang.GangTeamMgr")
local txtConst = textRes.Gang.GangTeam
def.const("number").TEAM_NAME_MAX_LEN = constant.CGangTeamConst.GangTeamNameLength
def.field("table")._uiGOs = nil
def.field("table")._uiStatus = nil
def.field("userdata").input = nil
def.field("function")._callback = nil
def.static("=>", UIEditTeamName).Instance = function()
  if instance == nil then
    instance = UIEditTeamName()
  end
  return instance
end
def.override().OnCreate = function(self)
  self._uiGOs = {}
  self.input = self.m_panel:FindDirect("Img_Bg0/Img_BgInput"):GetComponent("UIInput")
  self.input.characterLimit = Cls.TEAM_NAME_MAX_LEN * 2
  local uiGOs = self._uiGOs
  Event.RegisterEventWithContext(ModuleId.GANG, gmodule.notifyId.Gang.GangTeamNameChg, Cls.OnChgNameSuccess, self)
  uiGOs.imgCorrect = self.m_panel:FindDirect("Img_Bg0/Img_Correct")
  uiGOs.imgWrong = self.m_panel:FindDirect("Img_Bg0/Img_Wrong")
  uiGOs.lblStrCount = self.m_panel:FindDirect("Img_Bg0/Label_NameCount")
  uiGOs.imgWrong:SetActive(false)
  uiGOs.imgCorrect:SetActive(false)
  GUIUtils.SetText(uiGOs.lblStrCount, txtConst[47]:format(0, Cls.TEAM_NAME_MAX_LEN))
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.GangTeamNameChg, Cls.OnChgNameSuccess)
  self._uiGOs = nil
  self._uiStatus = nil
  self.input = nil
  self._callback = nil
end
local GangNameValidator = require("Main.Gang.GangNameValidator")
local NameValidator = require("Main.Common.NameValidator")
def.method("string", "=>", "string", "boolean")._validateNameAndToast = function(self, str)
  local b, reason, len = false, 0, 0
  local strLenMax = Cls.TEAM_NAME_MAX_LEN
  GangNameValidator.Instance():SetCharacterNum(1, strLenMax)
  local bValid, reason, len = GangNameValidator.Instance():IsValid(str)
  if bValid then
    return str, true
  else
    local min, max = GangNameValidator.Instance():GetCharacterNum()
    if reason == NameValidator.InvalidReason.TooShort then
    elseif reason == NameValidator.InvalidReason.TooLong then
      Toast(string.format(txtConst[73], max))
      return str, false
    elseif reason == NameValidator.InvalidReason.NotInSection then
      Toast(textRes.Gang[94])
    elseif reason == NameValidator.InvalidReason.AllNumber then
      Toast(textRes.Gang[97])
    end
    return str, false
  end
end
def.method("userdata").ShowPanel = function(self, teamId)
  if self:IsLoaded() then
    self:DestroyPanel()
  end
  self._uiStatus = {}
  self._uiStatus.teamId = teamId
  self:CreatePanel(RESPATH.PREFAB_EDIT_GANGTEAM_NAME, 2)
  self:SetModal(true)
end
def.method("function").ShowPanelWithCallback = function(self, cb)
  if self:IsLoaded() then
    self:DestroyPanel()
  end
  self._uiStatus = {}
  self._uiStatus.teamId = Int64.new(0)
  self._callback = cb
  self:CreatePanel(RESPATH.PREFAB_EDIT_GANGTEAM_NAME, 2)
  self:SetModal(true)
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if "Btn_Cancel" == id then
    self:DestroyPanel()
  elseif "Btn_Confirm" == id then
    self:onClickConfirm()
  end
end
def.method().onClickConfirm = function(self)
  local ChatMsgBuilder = require("Main.Chat.ChatMsgBuilder")
  local str = self.input:get_value()
  local str, bValid = self:_validateNameAndToast(str)
  if bValid then
    str = ChatMsgBuilder.CustomFilter(str, nil)
    str = _G.TrimIllegalChar(str)
    if string.find(str, "*") then
      Toast(txtConst[8])
      return true
    end
    if str == "" then
      if not self._uiStatus.teamId:eq(0) then
        Toast(txtConst[8])
        return true
      elseif self._callback ~= nil then
        self._callback(str)
        self:DestroyPanel()
      end
    elseif not self._uiStatus.teamId:eq(0) then
      GangTeamMgr.GetProtocol().sendChgGangTeamName(str)
    elseif self._callback ~= nil then
      self._callback(str)
      self:DestroyPanel()
    end
  elseif self._uiStatus.teamId:eq(0) then
    if self._callback ~= nil then
      self._callback(str)
      self:DestroyPanel()
    end
  else
    Toast(txtConst[46])
  end
end
def.method("string", "string").onTextChange = function(self, id, val)
  if self.input then
    local text = self.input:get_value()
    if text then
      local NameFilter = require("Main.Common.NameValidator")
      local text, bValid = self:_validateNameAndToast(text)
      local unicodeName = _G.GameUtil.Utf8ToUnicode(text)
      local wordNum = NameFilter.Instance():GetWordNum(unicodeName)
      wordNum = wordNum - (wordNum - math.floor(wordNum))
      GUIUtils.SetText(self._uiGOs.lblStrCount, txtConst[47]:format(wordNum, Cls.TEAM_NAME_MAX_LEN))
    end
  end
end
def.method("string", "userdata").onSubmit = function(self, id, ctrl)
  if "Img_BgInput" == id then
    self:onClickConfirm()
  end
end
def.method("table").OnChgNameSuccess = function(self, p)
  if p.teamId == self._uiStatus.teamId then
    Toast(txtConst[9])
    self:DestroyPanel()
  end
end
return Cls.Commit()
