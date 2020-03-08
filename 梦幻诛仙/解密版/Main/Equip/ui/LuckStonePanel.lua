local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local GUIUtils = require("GUI.GUIUtils")
local EquipUtils = require("Main.Equip.EquipUtils")
local LuckStonePanel = Lplus.Extend(ECPanelBase, "LuckStonePanel")
local def = LuckStonePanel.define
def.field("number").mCurRate = 0
def.field("number").mAllUsedLockNum = 0
def.field("function").mCallback = nil
def.field("table").mParams = nil
def.field("number").mOriginSliderValue = 0
def.field("number").mNeedAllRate2Base = 0
local instance
def.static("=>", LuckStonePanel).Instance = function()
  if instance == nil then
    instance = LuckStonePanel()
  end
  return instance
end
def.method("table", "function").ShowPanel = function(self, params, cb)
  if self:IsShow() then
    return
  end
  self.mCallback = cb
  self.mParams = params
  self.mAllUsedLockNum = self.mParams.curUsedNum
  local luckItemId = EquipUtils.GetLuckStoneItemId()
  local equip = self.mParams.curEquip
  local extraRate = self.mParams.extraRate
  local strenLevel = EquipUtils.GetEquipStrenLevel(equip.bagId, equip.key)
  local rate = EquipUtils.GetSuccessRate(luckItemId, strenLevel) * self.mAllUsedLockNum + equip.sucRate + extraRate
  local base = EquipUtils.GetJiGaoMax()
  if rate > base then
    rate = base
  end
  self.mNeedAllRate2Base = math.floor(base - math.min(equip.sucRate + extraRate, base))
  self.mOriginSliderValue = math.floor(EquipUtils.GetSuccessRate(luckItemId, strenLevel) * self.mAllUsedLockNum)
  self:CreatePanel(RESPATH.PREFAB_LOCK_STONE_PANEL, 2)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  if self.m_panel == nil or self.m_panel.isnil then
    return
  end
  self:UpdatePanel()
end
def.method("boolean").SetSliderState = function(self, state)
  local slider = self.m_panel:FindDirect("Img_Bg/Group_Slider/Slider_Bg")
  slider:GetComponent("UISlider").enabled = state
end
def.method().UpdatePanel = function(self)
  local luckItemId = EquipUtils.GetLuckStoneItemId()
  local itemInfo = ItemUtils.GetItemBase(luckItemId)
  local hasNum = ItemModule.Instance():GetItemCountById(luckItemId)
  local texture = self.m_panel:FindDirect("Img_Bg/Group_Lucky/Icon_Lucky")
  GUIUtils.FillIcon(texture:GetComponent("UITexture"), itemInfo.icon)
  local hasnumLabel = self.m_panel:FindDirect("Img_Bg/Group_Lucky/Label_Have")
  hasnumLabel:GetComponent("UILabel").text = string.format(textRes.Equip[68], hasNum)
  self:SetCurSuccRate()
  self:UpdateUseLabel(self.mAllUsedLockNum)
end
def.method().UpdateYuanBaoLabel = function(self)
  local yuanbaoToggleBtn = self.m_panel:FindDirect("Img_Bg/Group_Btn/Btn_Gou")
  local uiToggle = yuanbaoToggleBtn:GetComponent("UIToggle")
  local curValue = uiToggle.value
  local costLabel = self.m_panel:FindDirect("Img_Bg/Label_Cost")
  local costTip = self.m_panel:FindDirect("Img_Bg/Label_CostTip")
  if curValue then
    if self.mAllUsedLockNum > 0 then
      local luckItemId = EquipUtils.GetLuckStoneItemId()
      local haveItemNum = ItemModule.Instance():GetItemCountById(luckItemId)
      if haveItemNum < self.mAllUsedLockNum then
        costLabel:SetActive(true)
        costTip:SetActive(true)
        local price = EquipUtils.GetLuckStonePrice()
        local alluseYuanBao = price * (self.mAllUsedLockNum - haveItemNum)
        costLabel:GetComponent("UILabel"):set_text(tostring(alluseYuanBao))
      else
        costLabel:SetActive(false)
        costTip:SetActive(false)
      end
    else
      costLabel:SetActive(false)
      costTip:SetActive(false)
    end
  else
    costLabel:SetActive(false)
    costTip:SetActive(false)
  end
end
def.method().SetCurSuccRate = function(self)
  local equip = self.mParams.curEquip
  local extraRate = self.mParams.extraRate
  local luckItemId = EquipUtils.GetLuckStoneItemId()
  local strenLevel = EquipUtils.GetEquipStrenLevel(equip.bagId, equip.key)
  local rate = EquipUtils.GetSuccessRate(luckItemId, strenLevel) * self.mAllUsedLockNum + equip.sucRate + extraRate
  local base = EquipUtils.GetJiGaoMax()
  if rate > base then
    rate = base
  end
  self.mCurRate = rate
  local rateLabel = self.m_panel:FindDirect("Img_Bg/Group_Slider/Label_Num"):GetComponent("UILabel")
  rateLabel.text = string.format("%.2f", rate / base * 100) .. "%"
  if self.mNeedAllRate2Base ~= 0 then
    self.m_panel:FindDirect("Img_Bg/Group_Slider/Slider_Bg"):GetComponent("UISlider").value = EquipUtils.GetSuccessRate(luckItemId, strenLevel) * self.mAllUsedLockNum / self.mNeedAllRate2Base
  else
    self.m_panel:FindDirect("Img_Bg/Group_Slider/Slider_Bg"):GetComponent("UISlider").value = 1
  end
end
def.method("number").UpdateUseLabel = function(self, useNum)
  local useLabel = self.m_panel:FindDirect("Img_Bg/Group_Lucky/Label_Consume")
  local luckItemId = EquipUtils.GetLuckStoneItemId()
  local hasNum = ItemModule.Instance():GetItemCountById(luckItemId)
  if useNum > hasNum then
    useLabel:GetComponent("UILabel"):set_textColor(Color.red)
  else
    useLabel:GetComponent("UILabel"):set_textColor(Color.Color(0.30980392156862746, 0.18823529411764706, 0.09411764705882353, 1))
  end
  useLabel:GetComponent("UILabel").text = string.format(textRes.Equip[69], useNum)
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_Add" then
    if self.mCurRate >= EquipUtils.GetJiGaoMax() then
      Toast(textRes.Equip[70])
      return
    end
    self.mAllUsedLockNum = math.ceil(self.mAllUsedLockNum + 1)
    self:SetCurSuccRate()
    self:UpdateUseLabel(self.mAllUsedLockNum)
  elseif id == "Btn_Minus" then
    if self.mAllUsedLockNum == 0 then
      Toast(textRes.Equip[71])
      return
    end
    self.mAllUsedLockNum = math.ceil(self.mAllUsedLockNum - 1)
    self:SetCurSuccRate()
    self:UpdateUseLabel(self.mAllUsedLockNum)
  elseif id == "Btn_Confirm" then
    warn("Btn_Confirm~~~", self.mAllUsedLockNum, self.mParams.curUsedNum)
    if self.mCallback then
      self.mCallback(self.mAllUsedLockNum)
    end
    self:DestroyPanel()
  elseif id == "Group_Lucky" then
    self:OnClickToBuyLuckItem(obj, "UISprite")
  end
end
def.method("userdata", "string").OnClickToBuyLuckItem = function(self, obj, comName)
  local luckItemId = EquipUtils.GetLuckStoneItemId()
  local position = obj.position
  local screenPosition = WorldPosToScreen(position.x, position.y)
  local sprite = obj:GetComponent(comName)
  local width = sprite:get_width()
  local height = sprite:get_height()
  local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
  ItemTipsMgr.Instance():ShowBasicTips(luckItemId, screenPosition.x, screenPosition.y, width, height, 0, true)
end
def.method("string", "number").onScroll = function(self, id, value)
  if id == "Slider_Bg" then
    local base = EquipUtils.GetJiGaoMax()
    local luckItemId = EquipUtils.GetLuckStoneItemId()
    local equip = self.mParams.curEquip
    local strenLevel = EquipUtils.GetEquipStrenLevel(equip.bagId, equip.key)
    local addRate = EquipUtils.GetSuccessRate(luckItemId, strenLevel)
    local curSliderValue = math.floor(self.mNeedAllRate2Base * value)
    local extraRate = self.mParams.extraRate
    if curSliderValue <= 0 then
      self.mAllUsedLockNum = 0
      self:SetCurSuccRate()
      self:UpdateUseLabel(self.mAllUsedLockNum)
      self:UpdateYuanBaoLabel()
      return
    end
    local luckItemId = EquipUtils.GetLuckStoneItemId()
    local needNum = (curSliderValue - self.mOriginSliderValue) / EquipUtils.GetSuccessRate(luckItemId, strenLevel)
    self.mAllUsedLockNum = math.ceil(self.mParams.curUsedNum + needNum)
    if 0 >= self.mAllUsedLockNum then
      self.mAllUsedLockNum = 0
    end
    self:SetCurSuccRate()
    self:UpdateUseLabel(self.mAllUsedLockNum)
  end
end
def.override().OnDestroy = function(self)
  self.mCurRate = 0
  self.mAllUsedLockNum = 0
  self.mCallback = nil
  self.mParams = nil
  self.mOriginSliderValue = 0
  self.mNeedAllRate2Base = 0
end
LuckStonePanel.Commit()
return LuckStonePanel
