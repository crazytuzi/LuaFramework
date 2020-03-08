local EC = require("Types.Vector3")
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local ItemUtils = require("Main.Item.ItemUtils")
local LotteryPanel = Lplus.Extend(ECPanelBase, "LotteryPanel")
local LotteryModule = Lplus.ForwardDeclare("LotteryModule")
local def = LotteryPanel.define
local instance
def.const("number").ITEMNUM = 8
def.const("number").ROCIRCLE = 10
def.const("table").DescType = {LOTTERY = 1, TXHW = 2}
def.field("number").totalRotTime = 0
def.field("number").stopTime = 0
def.field("number").descType = 1
def.field("table").timerIds = nil
def.field("table").itemList = nil
def.field("number").finalItemIdx = -1
def.field("boolean").notified = false
def.field("boolean").btnStopPressed = false
def.field("number").timeRotBegin = 0
def.field("number").lotteryItemId = 0
local slotAngles = {
  -337.5,
  -22.5,
  -292.5,
  -67.5,
  -247.5,
  -112.5,
  -202.5,
  -157.5
}
def.static("=>", LotteryPanel).Instance = function()
  if instance == nil then
    instance = LotteryPanel()
    local consts = ItemUtils.GetLotteryConst()
    instance.totalRotTime = consts.totalRotTime
    instance.stopTime = consts.stopTime
  end
  return instance
end
def.method("number").ShowPanel = function(self, type)
  if self:IsShow() then
    return
  end
  self.descType = type
  self:CreatePanel(RESPATH.PREFAB_LOTTERY_PANEL, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  if not LotteryModule.isDebugging then
    self:InitUI()
  else
    self.finalItemIdx = 5
    self:InitRotation()
  end
end
def.override().OnDestroy = function(self)
  if not LotteryModule.isDebugging then
    self:Notify()
    self:RaiseCloseEvent()
    self:ResetStates()
  end
end
def.method().RaiseCloseEvent = function(self)
  Event.DispatchEvent(ModuleId.LOTTERY, gmodule.notifyId.Lottery.LOTTERY_PANEL_CLOSE, {
    lotteryItemId = self.lotteryItemId
  })
end
def.method().ResetStates = function(self)
  self.itemList = nil
  self.finalItemIdx = -1
  self.notified = false
  self.btnStopPressed = false
  self.timeRotBegin = 0
  self.timerIds = nil
  self.descType = 1
  self.lotteryItemId = 0
end
def.method().InitUI = function(self)
  if self.itemList == nil or self.finalItemIdx == -1 or #self.itemList ~= LotteryPanel.ITEMNUM then
    self:DestroyPanel()
    return
  end
  self:ShowTitle()
  local grids = self.m_panel:FindDirect("Img_Bg1/Group_Lottery/Group_Item")
  for index = 1, #self.itemList do
    local item = self.itemList[index]
    local grid = grids:FindDirect(string.format("Item_%02d", index))
    self:SetIcon(grid, item)
  end
  self:InitRotation()
end
def.method().ShowTitle = function(self)
  local imgTitle = self.m_panel:FindDirect("Img_Bg1/Img_Title")
  local titleXYFD = imgTitle:FindDirect("Img_XYFD"):SetActive(self.descType == LotteryPanel.DescType.LOTTERY)
  local titleDLT = imgTitle:FindDirect("Img_DLT"):SetActive(self.descType == LotteryPanel.DescType.TXHW)
end
def.method().InitRotation = function(self)
  local twRot = self.m_panel:FindDirect("Img_Bg1/Group_Lottery/Img_Stop"):GetComponent("TweenRotation")
  twRot.to = EC.Vector3.new(0, 0, LotteryPanel.ROCIRCLE * -360 + slotAngles[self.finalItemIdx])
  twRot.style = 0
  twRot.method = 2
  twRot.duration = self.totalRotTime
  twRot:Play()
  self.timeRotBegin = Time.realtimeSinceStartup
  self.timerIds = {}
  local timerId
  timerId = GameUtil.AddGlobalTimer(self.totalRotTime + 0.5, true, function()
    if not self.timerIds then
      return
    end
    if not self.btnStopPressed and timerId == self.timerIds.DefaultTimer then
      self:Notify()
      self:ShowPointerStopEffect()
    end
  end)
  self.timerIds.DefaultTimer = timerId
  local timerId2
  timerId2 = GameUtil.AddGlobalTimer(self.totalRotTime - self.stopTime, true, function()
    if not self.timerIds then
      return
    end
    if not self.btnStopPressed and timerId2 == self.timerIds.DisableStopTimer then
      self:DarkenStopBtnImg()
    end
  end)
  self.timerIds.DisableStopTimer = timerId2
end
def.method().ShowPointerStopEffect = function(self)
  if self.m_panel and not self.m_panel.isnil then
    for i = 1, LotteryPanel.ITEMNUM do
      local item = self.m_panel:FindDirect("Img_Bg1/Group_Lottery/Group_Item/Item_0" .. i)
      local imgSelect = item:FindDirect("Img_Select")
      local twAlpha = imgSelect:GetComponent("TweenAlpha")
      if i == self.finalItemIdx then
        TweenAlpha.Begin(imgSelect, 0.15, 1)
      else
        TweenAlpha.Begin(imgSelect, -1, 0)
      end
    end
  end
end
def.method("userdata", "table").SetIcon = function(self, grid, itemBase)
  local icon = grid:FindDirect("Img_Icon")
  local uiTexture = icon:GetComponent("UITexture")
  icon:SetActive(true)
  GUIUtils.FillIcon(uiTexture, itemBase.icon)
  local num = grid:FindDirect("Label_Num")
  num:SetActive(false)
end
def.method().DarkenStopBtnImg = function(self)
  if self.m_panel and not self.m_panel.isnil then
    local img = self.m_panel:FindDirect("Img_Bg1/Btn_Stop")
    local sprite = img:GetComponent("UISprite")
    sprite:set_color(Color.gray)
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Modal" then
    self:DestroyPanel()
  elseif string.find(id, "Item_") then
    if not LotteryModule.isDebugging then
      local index = tonumber(string.sub(id, 6))
      self:ShowItemTip(id)
    end
  elseif id == "Btn_Stop" then
    self:OnStopRotation()
  end
end
def.method().Notify = function(self)
  if self.notified then
    return
  end
  if not LotteryModule.isDebugging then
    LotteryModule.Instance():NotifyItemGet()
    self.notified = true
  end
end
def.method("string").ShowItemTip = function(self, id)
  local index = tonumber(string.sub(id, 6))
  local item = self.itemList[index]
  if item == nil then
    return
  end
  local sourceObj = self.m_panel:FindDirect("Img_Bg1/Group_Lottery/Group_Item/" .. id)
  local position = sourceObj:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local sprite = sourceObj:FindDirect("Img_Bg"):GetComponent("UISprite")
  ItemTipsMgr.Instance():ShowBasicTips(item.itemid, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), 0, false)
end
def.method().OnStopRotation = function(self)
  if self.btnStopPressed then
    return
  end
  local timePassed = Time.realtimeSinceStartup - self.timeRotBegin
  if timePassed > self.totalRotTime - self.stopTime then
    return
  end
  local twRotComp = self.m_panel:FindDirect("Img_Bg1/Group_Lottery/Img_Stop"):GetComponent("TweenRotation")
  twRotComp.style = 0
  twRotComp.method = 2
  twRotComp.tweenFactor = 0
  twRotComp:SetStartToCurrentValue()
  twRotComp.to = EC.Vector3.new(0, 0, slotAngles[self.finalItemIdx] - 360)
  twRotComp.duration = self.stopTime
  local timerId
  timerId = GameUtil.AddGlobalTimer(self.stopTime + 0.5, true, function()
    if not self.timerIds then
      return
    end
    if timerId == self.timerIds.StopperTimer then
      self:Notify()
      self:ShowPointerStopEffect()
    end
  end)
  self.timerIds.StopperTimer = timerId
  self:DarkenStopBtnImg()
  self.btnStopPressed = true
end
return LotteryPanel.Commit()
