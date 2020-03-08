local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GetBabyActivityTips = Lplus.Extend(ECPanelBase, "GetBabyActivityTips")
local GUIUtils = require("GUI.GUIUtils")
local def = GetBabyActivityTips.define
local instance
def.field("table").uiObjs = nil
def.field("string").strTips = ""
def.field("function").callback = nil
def.field("string").strCondition = ""
def.static("=>", GetBabyActivityTips).Instance = function()
  if instance == nil then
    instance = GetBabyActivityTips()
  end
  return instance
end
def.method("string", "function").ShowPanelWithCallback = function(self, tips, callback)
  if self.m_panel ~= nil then
    return
  end
  self.strTips = tips
  self.callback = callback
  self:CreatePanel(RESPATH.PREFAB_GET_BABY_TIPS, 2)
  self:SetOutTouchDisappear()
end
def.method("string", "string").ShowPanelWithCondition = function(self, tips, condition)
  if self.m_panel ~= nil then
    return
  end
  self.strTips = tips
  self.strCondition = condition
  self:CreatePanel(RESPATH.PREFAB_GET_BABY_TIPS, 2)
  self:SetOutTouchDisappear()
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:ShowActivityTips()
end
def.override().OnDestroy = function(self)
  self.uiObjs = nil
  self.strTips = ""
  self.callback = nil
  self.strCondition = ""
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Img_Bg = self.m_panel:FindDirect("Img_Bg")
  self.uiObjs.Scrollview_Tips = self.uiObjs.Img_Bg:FindDirect("Scrollview_Tips")
  self.uiObjs.Drag_Tips = self.uiObjs.Scrollview_Tips:FindDirect("Drag_Tips")
  self.uiObjs.Btn_Confirm = self.uiObjs.Img_Bg:FindDirect("Btn_Confirm")
  self.uiObjs.Label_Condition = self.uiObjs.Img_Bg:FindDirect("Label")
end
def.method().ShowActivityTips = function(self)
  GUIUtils.SetText(self.uiObjs.Drag_Tips, self.strTips)
  self.uiObjs.Scrollview_Tips:GetComponent("UIScrollView"):ResetPosition()
  if self.callback == nil then
    GUIUtils.SetActive(self.uiObjs.Btn_Confirm, false)
    GUIUtils.SetText(self.uiObjs.Label_Condition, self.strCondition)
  else
    GUIUtils.SetActive(self.uiObjs.Btn_Confirm, true)
    GUIUtils.SetText(self.uiObjs.Label_Condition, "")
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Confirm" then
    self:OnConfirmBtnClick()
  end
end
def.method().OnConfirmBtnClick = function(self)
  if self.callback then
    self.callback()
  end
  self:DestroyPanel()
end
GetBabyActivityTips.Commit()
return GetBabyActivityTips
