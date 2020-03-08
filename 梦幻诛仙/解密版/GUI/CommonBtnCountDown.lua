local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local CommonBtnCountDown = Lplus.Extend(ECPanelBase, "CommonBtnCountDown")
local def = CommonBtnCountDown.define
def.field("function").callback = nil
def.field("string").title = ""
def.field("string").content = ""
def.field("string").btn = ""
def.field("number").endTime = 0
def.field("number").timer = 0
def.static("string", "string", "string", "number", "function").ShowBtnCountDown = function(title, content, btn, endTime, callback)
  local dlg = CommonBtnCountDown()
  dlg.title = title
  dlg.content = content
  dlg.endTime = endTime
  dlg.btn = btn
  dlg.callback = callback
  dlg:CreatePanel(RESPATH.DLG_COMMONCOMFIRM, 0)
  dlg:SetDepth(GUIDEPTH.TOPMOST2)
  dlg:SetModal(true)
end
def.override().OnCreate = function(self)
  self:UpdateText()
  self:UpdateButton()
end
def.override().OnDestroy = function(self)
  GameUtil.RemoveGlobalTimer(self.timer)
  self.timer = 0
end
def.method().UpdateText = function(self)
  local title = self.m_panel:FindDirect("Img_0/Label_Title"):GetComponent("UILabel")
  title:set_text(self.title)
  local contentLabel = self.m_panel:FindDirect("Img_0/Img_BgWords/Label"):GetComponent("UILabel")
  contentLabel:set_text(self.content)
end
def.method().UpdateButton = function(self)
  local close = self.m_panel:FindDirect("Img_0/Btn_Close")
  local cancel = self.m_panel:FindDirect("Img_0/Btn_Confirm")
  local confirm = self.m_panel:FindDirect("Img_0/Btn_Cancel")
  local special = self.m_panel:FindDirect("Img_0/Btn_Special")
  close:SetActive(false)
  cancel:SetActive(false)
  confirm:SetActive(false)
  special:SetActive(true)
  local lbl = special:FindDirect("Label_Cancel"):GetComponent("UILabel")
  local function SetBtnText()
    if lbl.isnil then
      return
    end
    local curTime = GetServerTime()
    local leftTime = self.endTime - curTime
    if leftTime > 0 then
      lbl:set_text(string.format(textRes.Common[47], self.btn, leftTime))
    else
      if self.callback then
        self.callback(false)
        self.callback = nil
      end
      self:DestroyPanel()
    end
  end
  SetBtnText()
  self.timer = GameUtil.AddGlobalTimer(1, false, SetBtnText)
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Special" then
    if self.callback ~= nil then
      self.callback(true)
      self.callback = nil
    end
    self:DestroyPanel()
  end
end
CommonBtnCountDown.Commit()
return CommonBtnCountDown
