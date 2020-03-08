local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local BuildHomelandPanel = Lplus.Extend(ECPanelBase, MODULE_NAME)
local GUIUtils = require("GUI.GUIUtils")
local BuildHomelandMgr = require("Main.Homeland.BuildHomelandMgr")
local ItemUtils = require("Main.Item.ItemUtils")
local def = BuildHomelandPanel.define
def.field("table").m_UIGOs = nil
def.field("number").m_selPayMethod = -1
def.field("table").m_needs = nil
local instance
def.static("=>", BuildHomelandPanel).Instance = function()
  if instance == nil then
    instance = BuildHomelandPanel()
    instance:Init()
  end
  return instance
end
def.static().ShowPanel = function()
  local self = BuildHomelandPanel()
  self:Init()
  self:CreatePanel(RESPATH.PREFAB_BUILD_HOMELAND_PANEL, 1)
end
def.method().Init = function(self)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:UpdateUI()
  Event.RegisterEventWithContext(ModuleId.HOMELAND, gmodule.notifyId.Homeland.Build_Homeland_Success, BuildHomelandPanel.OnSuccessBuildHome, self)
end
def.override().OnDestroy = function(self)
  self.m_UIGOs = nil
  self.m_needs = nil
  Event.UnregisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.Build_Homeland_Success, BuildHomelandPanel.OnSuccessBuildHome)
end
def.method().InitUI = function(self)
  self.m_UIGOs = {}
  self.m_UIGOs.Img_Bg = self.m_panel:FindDirect("Img_Bg")
  self.m_UIGOs.Img_Bg1 = self.m_UIGOs.Img_Bg:FindDirect("Img_Bg1")
  self.m_UIGOs.Img_Bg2 = self.m_UIGOs.Img_Bg:FindDirect("Img_Bg2")
end
def.method().UpdateUI = function(self)
  local needs = BuildHomelandMgr.Instance():GetBuildHomeNeeds()
  self.m_needs = needs
  local needCurrency = needs.currency
  local needItem = needs.item
  local Label_Number = self.m_UIGOs.Img_Bg1:FindDirect("Label_Number")
  GUIUtils.SetText(Label_Number, tostring(needCurrency.number))
  local itemName = "nil"
  local icon = 0
  local itemBase = ItemUtils.GetItemBase(needItem.itemId)
  if itemBase then
    itemName = itemBase.name
    icon = itemBase.icon
  end
  local Label_ItemName = self.m_UIGOs.Img_Bg2:FindDirect("Label")
  GUIUtils.SetText(Label_ItemName, itemName)
  local Texture = self.m_UIGOs.Img_Bg2:FindDirect("Texture")
  GUIUtils.SetTexture(Texture, icon)
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Sprite" then
    self:OnBuildBtnClick()
  elseif id == "Img_Bg1" then
    self:SetPayMethod(BuildHomelandMgr.PayMethod.Currency)
  elseif id == "Img_Bg2" then
    self:SetPayMethod(BuildHomelandMgr.PayMethod.Deed)
  end
end
def.method("number").SetPayMethod = function(self, payMethod)
  self.m_selPayMethod = payMethod
end
def.method().OnBuildBtnClick = function(self)
  if self.m_selPayMethod == BuildHomelandMgr.PayMethod.None then
    Toast(textRes.Homeland[8])
  elseif self.m_selPayMethod == BuildHomelandMgr.PayMethod.Currency then
    self:BuildHomeUseCurrency()
  elseif self.m_selPayMethod == BuildHomelandMgr.PayMethod.Deed then
    self:BuildHomeUseDeed()
  end
end
def.method().BuildHomeUseCurrency = function(self)
  BuildHomelandMgr.Instance():BuildHomeUseCurrency()
end
def.method().BuildHomeUseDeed = function(self)
  local rs = BuildHomelandMgr.Instance():BuildHomeUseDeed()
  if rs == BuildHomelandMgr.CResult.DeedNotEnough then
    local itemId = self.m_needs.item.itemId
    local itemBase = ItemUtils.GetItemBase(itemId)
    local itemName = itemBase and itemBase.name or nil
    if itemName then
      local text = string.format(textRes.Homeland[9], itemName)
      Toast(text)
      local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
      local go = self.m_UIGOs.Img_Bg2
      ItemTipsMgr.Instance():ShowBasicTipsWithGO(itemId, go, 0, true)
    end
  end
end
def.method("table").OnSuccessBuildHome = function(self, params)
  self:DestroyPanel()
end
return BuildHomelandPanel.Commit()
