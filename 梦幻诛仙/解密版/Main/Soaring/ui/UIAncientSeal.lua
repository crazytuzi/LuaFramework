local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local UIAncientSeal = Lplus.Extend(ECPanelBase, "UIAncientSeal")
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local GUIUtils = require("GUI.GUIUtils")
local def = UIAncientSeal.define
local instance
def.field("number")._itemId = 0
def.field("number")._needItemNum = 0
def.field("boolean")._bIsItemEnough = false
def.field("table")._uiGOs = nil
def.const("number").FX_DURATION = 1
def.static("=>", UIAncientSeal).Instance = function()
  if instance == nil then
    instance = UIAncientSeal()
  end
  return instance
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.SOARING, gmodule.notifyId.Soaring.ANCIENTSEAL_COMMIT_SUCCESS, UIAncientSeal.OnCommitItemSuccess)
  local itemModule = ItemModule.Instance()
  local hasItemNum = itemModule:GetNumberByItemId(ItemModule.BAG, self._itemId)
  self._bIsItemEnough = not (hasItemNum < self._needItemNum)
  local ctrlItemRoot = self.m_panel:FindDirect("Img _Bg0/Img_Item")
  local texItem = ctrlItemRoot:FindDirect("Texture_Item")
  local lblItemNum = ctrlItemRoot:FindDirect("Label3")
  local fx = self.m_panel:FindDirect("Img _Bg0/Fx")
  fx:SetActive(false)
  local itemBase = ItemUtils.GetItemBase(self._itemId)
  warn(">>>>itemIcon = " .. itemBase.icon)
  GUIUtils.SetTexture(texItem, itemBase.icon)
  self._uiGOs = {}
  self._uiGOs.lblItemNum = lblItemNum
  self._uiGOs.fx = fx
  local lblCommit = self.m_panel:FindDirect("Img _Bg0/Btn_ConFirm/Label_Finish")
  local lblHow = self.m_panel:FindDirect("Img _Bg0/Btn_ConFirm/Label_Way")
  lblCommit:SetActive(self._bIsItemEnough)
  lblHow:SetActive(not self._bIsItemEnough)
  self:UpdateUILabelItemNum()
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.SOARING, gmodule.notifyId.Soaring.ANCIENTSEAL_COMMIT_SUCCESS, UIAncientSeal.OnCommitItemSuccess)
  self._itemId = 0
  self._bIsItemEnough = false
  self._needItemNum = 0
  self._uiGOs = nil
end
def.method("number", "number").ShowPanel = function(self, itemId, needItemNum)
  if self:IsShow() or itemId == 0 then
    return
  end
  self._itemId = itemId
  self._needItemNum = needItemNum
  self:CreatePanel(RESPATH.PREFAB_UI_ANCIENTSEAL, 1)
  self:SetOutTouchDisappear()
end
def.method().HidePanel = function(self)
  if self:IsShow() then
    self:DestroyPanel()
  end
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_Close" then
    self:HidePanel()
  elseif id == "Btn_ConFirm" then
    if self._bIsItemEnough then
      self:OnBtnCommitClick()
    else
      self:OnBtnHowClick()
    end
  end
end
def.method().OnBtnHowClick = function(self)
  Event.DispatchEvent(ModuleId.HERO, gmodule.notifyId.Hero.CREDITS_SHOP, {5})
  self:HidePanel()
end
def.method().OnBtnCommitClick = function(self)
  local TaskAncientSeal = require("Main.Soaring.proxy.TaskAncientSeal")
  TaskAncientSeal.SendCommitItemReq()
end
def.method().DisplayEffect = function(self)
  self._uiGOs.fx:SetActive(true)
  GameUtil.AddGlobalTimer(UIAncientSeal.FX_DURATION, true, function()
    self:HidePanel()
  end)
end
def.method().UpdateUILabelItemNum = function(self)
  local itemModule = ItemModule.Instance()
  local hasItemNum = itemModule:GetNumberByItemId(ItemModule.BAG, self._itemId)
  GUIUtils.SetText(self._uiGOs.lblItemNum, textRes.Soaring.AncientSeal[5]:format(hasItemNum, self._needItemNum))
end
def.static("table", "table").OnCommitItemSuccess = function(p, context)
  local self = UIAncientSeal.Instance()
  if not self:IsShow() then
    return
  end
  self:DisplayEffect()
end
return UIAncientSeal.Commit()
