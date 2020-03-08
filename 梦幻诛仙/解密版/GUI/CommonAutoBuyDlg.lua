local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ItemUtils = require("Main.Item.ItemUtils")
local GUIUtils = require("GUI.GUIUtils")
local EC = require("Types.Vector3")
local CommonAutoBuyDlg = Lplus.Extend(ECPanelBase, "CommonAutoBuyDlg")
local def = CommonAutoBuyDlg.define
def.field("number").type = 0
def.field("string").content = ""
def.field("string").toggleTip = ""
def.field("string").btnYesStr = ""
def.field("string").btnNoStr = ""
def.field("function").callback = nil
def.field("table").tag = nil
def.field("boolean").closeBtn = false
def.field("boolean").callBackDone = false
def.field("number").countDown = 0
def.field("number").countDownDefaultOper = 0
def.field("number").countDownTimer = 0
local getTagPanelLevel = function(tag)
  return tag and getmetatable(tag) == nil and tag.level or 2
end
local getTagUnique = function(tag)
  return tag and tag.unique or nil
end
local getTagToggle = function(tag)
  if tag and nil ~= tag.bToggle then
    return tag.bToggle
  else
    return false
  end
end
local getTagShowCloseBtn = function(tag)
  if tag and nil ~= tag.bShowCloseBtn then
    return tag.bShowCloseBtn
  else
    return false
  end
end
local UniqueMap = {}
setmetatable(UniqueMap, {__mode = "kv"})
def.static("dynamic", "=>", CommonAutoBuyDlg).GetInstanceByUnique = function(tag)
  return UniqueMap[tag]
end
def.static("string", "string", "function", "table", "=>", ECPanelBase).ShowConfirm = function(content, toggleTip, callback, tag)
  local autoBuyConfirmDlg = CommonAutoBuyDlg()
  local unique = getTagUnique(tag)
  if unique then
    if UniqueMap[unique] and UniqueMap[unique].m_created then
      return nil
    else
      UniqueMap[unique] = autoBuyConfirmDlg
    end
  end
  autoBuyConfirmDlg.callback = callback
  autoBuyConfirmDlg.callBackDone = false
  autoBuyConfirmDlg.toggleTip = toggleTip
  autoBuyConfirmDlg.content = content
  autoBuyConfirmDlg.tag = tag
  autoBuyConfirmDlg.type = 0
  local level = getTagPanelLevel(tag)
  autoBuyConfirmDlg:CreatePanel(RESPATH.PREFAB_COMMON_AUTO_BUY_PANEL, level)
  autoBuyConfirmDlg:SetModal(true)
  autoBuyConfirmDlg:SetDepth(4)
  return autoBuyConfirmDlg
end
def.static("string", "string", "string", "string", "function", "table", "=>", ECPanelBase).ShowConfirmEx = function(content, toggleTip, btnYesStr, btnNoStr, callback, tag)
  local autoBuyConfirmDlg = CommonAutoBuyDlg()
  local unique = getTagUnique(tag)
  if unique then
    if UniqueMap[unique] and UniqueMap[unique].m_created then
      return nil
    else
      UniqueMap[unique] = autoBuyConfirmDlg
    end
  end
  autoBuyConfirmDlg.callback = callback
  autoBuyConfirmDlg.callBackDone = true
  autoBuyConfirmDlg.toggleTip = toggleTip
  autoBuyConfirmDlg.content = content
  autoBuyConfirmDlg.btnYesStr = btnYesStr
  autoBuyConfirmDlg.btnNoStr = btnNoStr
  autoBuyConfirmDlg.tag = tag
  autoBuyConfirmDlg.type = 0
  local level = getTagPanelLevel(tag)
  autoBuyConfirmDlg:CreatePanel(RESPATH.PREFAB_COMMON_AUTO_BUY_PANEL, level)
  autoBuyConfirmDlg:SetModal(true)
  autoBuyConfirmDlg:SetDepth(4)
  return autoBuyConfirmDlg
end
def.static("string", "string", "string", "string", "number", "number", "function", "table", "=>", ECPanelBase).ShowConfirmCoundDown = function(content, toggleTip, btnYesStr, btnNoStr, countDownDefaultOper, countDown, callback, tag)
  local autoBuyConfirmDlg = CommonAutoBuyDlg()
  local unique = getTagUnique(tag)
  if unique then
    if UniqueMap[unique] and UniqueMap[unique].m_created then
      return nil
    else
      UniqueMap[unique] = autoBuyConfirmDlg
    end
  end
  autoBuyConfirmDlg.callback = callback
  autoBuyConfirmDlg.callBackDone = false
  autoBuyConfirmDlg.toggleTip = toggleTip
  autoBuyConfirmDlg.content = content
  autoBuyConfirmDlg.tag = tag
  autoBuyConfirmDlg.type = 0
  autoBuyConfirmDlg.btnYesStr = btnYesStr
  autoBuyConfirmDlg.btnNoStr = btnNoStr
  autoBuyConfirmDlg.countDownDefaultOper = countDownDefaultOper
  autoBuyConfirmDlg.countDown = countDown
  local level = getTagPanelLevel(tag)
  autoBuyConfirmDlg:CreatePanel(RESPATH.PREFAB_COMMON_AUTO_BUY_PANEL, level)
  autoBuyConfirmDlg:SetModal(true)
  autoBuyConfirmDlg:SetDepth(4)
  return autoBuyConfirmDlg
end
def.override().OnCreate = function(self)
  self:UpdateContent()
  self:UpdateToggle()
  self:UpdateConfirmBtns()
end
def.override().OnDestroy = function(self)
  self:RemoveTimer()
  local unique = getTagUnique(self.tag)
  if unique then
    UniqueMap[unique] = nil
  end
  if not self.callBackDone and self.callback then
    self:DoCallback(-1, getTagToggle(self.tag))
  end
end
def.method().RemoveTimer = function(self)
  if self.countDownTimer ~= 0 then
    GameUtil.RemoveGlobalTimer(self.countDownTimer)
    self.countDownTimer = 0
  end
end
def.method().UpdateContent = function(self)
  local contentLabel = self.m_panel:FindDirect("Img_0/Img_BgWords/Label")
  GUIUtils.SetText(contentLabel, self.content)
end
def.method().UpdateToggle = function(self)
  local BtnToggle = self.m_panel:FindDirect("Img_0/Btn_Tips")
  GUIUtils.Toggle(BtnToggle, getTagToggle(self.tag))
  local ToggleTip = BtnToggle:FindDirect("Label_Tips")
  if self.toggleTip == "" then
    self.toggleTip = ToggleTip:GetComponent("UILabel"):get_text()
  else
    GUIUtils.SetText(ToggleTip, self.toggleTip)
  end
end
def.method("=>", "boolean").GetCurToggle = function(self)
  local BtnToggle = self.m_panel:FindDirect("Img_0/Btn_Tips")
  local uiToggle = BtnToggle:GetComponent("UIToggle")
  return uiToggle.value
end
def.method().UpdateConfirmBtns = function(self)
  local Label_Confirm = self.m_panel:FindDirect("Img_0/Btn_Confirm/Label_Confirm")
  if self.btnYesStr == "" then
    self.btnYesStr = Label_Confirm:GetComponent("UILabel"):get_text()
  else
    GUIUtils.SetText(Label_Confirm, self.btnYesStr)
  end
  local Label_Cancel = self.m_panel:FindDirect("Img_0/Btn_Cancel/Label_Cancel")
  if self.btnNoStr == "" then
    self.btnNoStr = Label_Cancel:GetComponent("UILabel"):get_text()
  else
    GUIUtils.SetText(Label_Cancel, self.btnNoStr)
  end
  self:UpdateCloseBtn()
  self:UpdateCountdown()
end
def.method().UpdateCountdown = function(self)
  if self.countDown > 0 then
    do
      local countDown = self.countDown
      local startTime = GameUtil.GetTickCount()
      if self.countDownDefaultOper == 1 then
        self.m_panel:FindDirect("Img_0/Btn_Cancel/Label_Cancel"):GetComponent("UILabel"):set_text(self.btnNoStr)
        do
          local btnLabel = self.m_panel:FindDirect("Img_0/Btn_Confirm/Label_Confirm"):GetComponent("UILabel")
          btnLabel:set_text(self.btnYesStr .. string.format("(%d)", countDown))
          self.countDownTimer = GameUtil.AddGlobalTimer(1, false, function()
            local curTime = GameUtil.GetTickCount()
            local leftSeconds = countDown - math.floor((curTime - startTime) / 1000)
            if leftSeconds < 0 then
              self:DoCallback(1, self:GetCurToggle())
              self:RemoveTimer()
              self:DestroyPanel()
              self = nil
            else
              btnLabel:set_text(self.btnYesStr .. string.format("(%d)", leftSeconds))
            end
          end)
        end
      elseif self.countDownDefaultOper == 0 then
        self.m_panel:FindDirect("Img_0/Btn_Confirm/Label_Confirm"):GetComponent("UILabel"):set_text(self.btnNoStr)
        do
          local btnLabel = self.m_panel:FindDirect("Img_0/Btn_Cancel/Label_Cancel"):GetComponent("UILabel")
          btnLabel:set_text(self.btnNoStr .. string.format("(%d)", countDown))
          self.countDownTimer = GameUtil.AddGlobalTimer(1, false, function()
            local curTime = GameUtil.GetTickCount()
            local leftSeconds = countDown - math.floor((curTime - startTime) / 1000)
            if leftSeconds < 0 then
              self:DoCallback(0, self:GetCurToggle())
              self:RemoveTimer()
              self:DestroyPanel()
              self = nil
            else
              btnLabel:set_text(self.btnNoStr .. string.format("(%d)", leftSeconds))
            end
          end)
        end
      end
    end
  end
end
def.method().UpdateCloseBtn = function(self)
  local Btn_Close = self.m_panel:FindDirect("Img_0/Btn_Close")
  GUIUtils.SetActive(Btn_Close, getTagShowCloseBtn(self.tag))
end
def.method("number", "boolean").DoCallback = function(self, oper, bToggle)
  if self.callback ~= nil then
    self.callBackDone = true
    if nil == self.tag then
      self.tag = {}
    end
    self.tag.bToggle = bToggle
    self.callback(oper, self.tag)
    self.callback = nil
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Confirm" then
    self:OnBtnYes()
  elseif id == "Btn_Cancel" then
    self:OnBtnNo()
  elseif id == "Btn_Close" then
    self:OnBtnClose()
  end
end
def.method().OnBtnYes = function(self)
  self:DoCallback(1, self:GetCurToggle())
  self:RemoveTimer()
  self:DestroyPanel()
  self = nil
end
def.method().OnBtnNo = function(self)
  self:DoCallback(0, getTagToggle(self.tag))
  self:RemoveTimer()
  self:DestroyPanel()
  self = nil
end
def.method().OnBtnClose = function(self)
  self:RemoveTimer()
  self:DestroyPanel()
  self = nil
end
CommonAutoBuyDlg.Commit()
return CommonAutoBuyDlg
