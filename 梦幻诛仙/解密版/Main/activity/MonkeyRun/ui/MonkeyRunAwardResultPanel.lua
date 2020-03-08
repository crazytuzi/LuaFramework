local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local MonkeyRunAwardResultPanel = Lplus.Extend(ECPanelBase, MODULE_NAME)
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemModule = require("Main.Item.ItemModule")
local MonkeyRunMgr = require("Main.activity.MonkeyRun.MonkeyRunMgr")
local MonkeyRunUtils = require("Main.activity.MonkeyRun.MonkeyRunUtils")
local AwardItemTipHelper = require("Main.Award.AwardItemTipHelper")
local HtmlHelper = require("Main.Chat.HtmlHelper")
local def = MonkeyRunAwardResultPanel.define
def.field("table").uiObjs = nil
def.field("table").awards = nil
def.field("string").btnName = ""
def.field("function").callback = nil
def.field(AwardItemTipHelper).itemTipHelper = nil
def.field("function").closeCallback = nil
local instance
def.static("=>", MonkeyRunAwardResultPanel).Instance = function()
  if instance == nil then
    instance = MonkeyRunAwardResultPanel()
  end
  return instance
end
def.method("table", "function", "string", "function").ShowOuterAwardPanel = function(self, awards, closeCallback, btnName, callback)
  self.awards = awards
  self.closeCallback = closeCallback
  self.btnName = btnName
  self.callback = callback
  if self.m_panel and not self.m_panel.isnil then
    self:ShowAwardItems()
    return
  end
  local resPath = RESPATH.PREFAB_MONKEYRUN_AWARD_PANEL
  if #self.awards == 1 then
    resPath = RESPATH.PREFAB_MONKEYRUN_SINGLE_AWARD_PANEL
  end
  self:SetModal(true)
  self:CreatePanel(resPath, 2)
end
def.method("table", "function", "string", "function").ShowInnerAwardPanel = function(self, awards, closeCallback, btnName, callback)
  self.awards = awards
  self.closeCallback = closeCallback
  self.btnName = btnName
  self.callback = callback
  if self.m_panel and not self.m_panel.isnil then
    self:ShowAwardItems()
    return
  end
  self:SetModal(true)
  self:CreatePanel(RESPATH.PREFAB_MONKEYRUN_INNER_AWARD_PANEL, 2)
end
def.method("table", "string", "function").ShowPanel = function(self, awards, btnName, callback)
  self.awards = awards
  self.btnName = btnName
  self.callback = callback
  if self.m_panel and not self.m_panel.isnil then
    self:ShowAwardItems()
    return
  end
  self:SetModal(true)
  self:CreatePanel(RESPATH.PREFAB_MONKEYRUN_AWARD_PANEL, 2)
end
def.override().OnCreate = function(self)
  if self.m_panel == nil then
    return
  end
  self:InitUI()
  self:ShowAwardItems()
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_MonkeyRun_OpenChange, MonkeyRunAwardResultPanel.OnOpenChange)
end
def.override().OnDestroy = function(self)
  self.uiObjs = nil
  self.awards = nil
  self.btnName = ""
  self.callback = nil
  self.itemTipHelper = nil
  if self.closeCallback ~= nil then
    self.closeCallback()
    self.closeCallback = nil
  end
  Event.UnregisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_MonkeyRun_OpenChange, MonkeyRunAwardResultPanel.OnOpenChange)
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.uiObjs.Group_Out = self.uiObjs.Img_Bg0:FindDirect("Group_Out")
  self.uiObjs.Group_In = self.uiObjs.Img_Bg0:FindDirect("Group_In")
  self.uiObjs.Group_Ten = self.uiObjs.Img_Bg0:FindDirect("Group_Ten")
  self.uiObjs.Group_One = self.uiObjs.Img_Bg0:FindDirect("Group_One")
  self.itemTipHelper = AwardItemTipHelper()
  if self.callback then
    GUIUtils.SetActive(self.uiObjs.Group_Out, true)
    GUIUtils.SetActive(self.uiObjs.Group_In, false)
    self.uiObjs.Btn_Run = self.uiObjs.Group_Out:FindDirect("Btn_Run")
  else
    GUIUtils.SetActive(self.uiObjs.Group_Out, false)
    GUIUtils.SetActive(self.uiObjs.Group_In, true)
    self.uiObjs.Btn_Run = self.uiObjs.Group_In:FindDirect("Btn_Conform")
  end
  local Label_Run = self.uiObjs.Btn_Run:FindDirect("Label")
  if self.btnName ~= "" then
    GUIUtils.SetText(Label_Run, self.btnName)
  end
end
def.method().ShowAwardItems = function(self)
  self.itemTipHelper:Clear()
  if #self.awards == 1 then
    self:ShowSingleItem()
  else
    self:ShowTenItems()
  end
end
def.method().ShowSingleItem = function(self)
  GUIUtils.SetActive(self.uiObjs.Group_Ten, false)
  GUIUtils.SetActive(self.uiObjs.Group_One, true)
  local Effect_Ten = self.uiObjs.Group_One:FindDirect("Effect_Ten")
  GUIUtils.SetActive(Effect_Ten, false)
  GUIUtils.SetActive(Effect_Ten, true)
  local Group_Items = self.uiObjs.Group_One:FindDirect("Group_Items")
  self:FillAwardItems(Group_Items)
end
def.method().ShowTenItems = function(self)
  GUIUtils.SetActive(self.uiObjs.Group_Ten, true)
  GUIUtils.SetActive(self.uiObjs.Group_One, false)
  local Effect_Ten = self.uiObjs.Group_Ten:FindDirect(Effect_Ten)
  GUIUtils.SetActive(Effect_Ten, false)
  GUIUtils.SetActive(Effect_Ten, true)
  local Group_Items = self.uiObjs.Group_Ten:FindDirect("Group_Items")
  self:FillAwardItems(Group_Items)
end
def.method("userdata").FillAwardItems = function(self, parent)
  local totalCount = parent.transform.childCount
  for i = 1, totalCount do
    local Img_BgIcon = parent:FindDirect("Img_BgIcon" .. i)
    if self.awards[i] then
      GUIUtils.SetActive(Img_BgIcon, true)
      local Texture_Icon = Img_BgIcon:FindDirect("Texture_Icon")
      local Label_Num = Img_BgIcon:FindDirect("Label_Num")
      local Label_Name = Img_BgIcon:FindDirect("Label_Name")
      local itemData = self.awards[i].items[1]
      local itemBase = ItemUtils.GetItemBase(itemData.itemId)
      GUIUtils.SetText(Label_Num, itemData.itemNum)
      GUIUtils.FillIcon(Texture_Icon:GetComponent("UITexture"), itemBase.icon)
      local itemColor = HtmlHelper.NameColor[itemBase.namecolor]
      local text = string.format("[%s]%s[-]", itemColor, itemBase.name)
      GUIUtils.SetText(Label_Name, text)
      local uiWidget = Img_BgIcon:GetComponent("UIWidget")
      local boxCollider = Img_BgIcon:GetComponent("BoxCollider")
      if boxCollider == nil then
        boxCollider = Img_BgIcon:AddComponent("BoxCollider")
        uiWidget:set_autoResizeBoxCollider(true)
        uiWidget:ResizeCollider()
      end
      local iconBoxCollider = Texture_Icon:GetComponent("BoxCollider")
      if iconBoxCollider ~= nil then
        GameObject.Destroy(iconBoxCollider)
      end
      self.itemTipHelper:RegisterItem2ShowTip(itemData.itemId, Img_BgIcon)
    else
      GUIUtils.SetActive(Img_BgIcon, false)
    end
  end
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_Conform" then
    self:DestroyPanel()
  elseif id == "Btn_Run" then
    self:OnClickBtnRun()
  else
    self.itemTipHelper:CheckItem2ShowTip(id)
  end
end
def.method().OnClickBtnRun = function(self)
  if self.callback then
    self.callback()
  end
end
def.static("table", "table").OnOpenChange = function(params, context)
  local self = instance
  if not MonkeyRunMgr.Instance():IsActivityOpened() then
    self:DestroyPanel()
  end
end
return MonkeyRunAwardResultPanel.Commit()
