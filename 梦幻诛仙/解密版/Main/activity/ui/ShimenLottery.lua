local EC = require("Types.Vector3")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ShimenLottery = Lplus.Extend(ECPanelBase, "ShimenLottery")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local PersonalHelper = require("Main.Chat.PersonalHelper")
local def = ShimenLottery.define
def.const("number").countDown = 5
def.field("number").time = 0
def.field("number").timerId = 0
def.field("number").itemIdx = 1
def.field("number").itemId = 0
def.field("number").itemNum = 0
def.field("boolean").isClickStop = false
local instance
local itemAngle = {
  -335,
  -25,
  -290,
  -70,
  -245,
  -115,
  -200,
  -160
}
def.static("=>", ShimenLottery).Instance = function()
  if instance == nil then
    instance = ShimenLottery()
  end
  return instance
end
def.method("number", "number", "number").ShowPanel = function(self, idx, itemId, itemNum)
  if self:IsShow() then
    return
  end
  self.itemIdx = idx
  self.itemId = itemId
  self.itemNum = itemNum
  self:CreatePanel(RESPATH.PREFAB_SHIMEN_LOTTERY, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
end
def.override().OnDestroy = function(self)
  if self.timerId ~= 0 then
    GameUtil.RemoveGlobalTimer(self.timerId)
  end
end
def.override("boolean").OnShow = function(self, b)
  if b then
    self.time = ShimenLottery.countDown
    self:InitUI()
    self.isClickStop = false
  end
end
def.method("string").onClick = function(self, id)
  local strs = string.split(id, "_")
  if id == "Btn_Stop" then
    if not self.isClickStop then
      self.isClickStop = true
      self:StopLottery()
    end
  elseif id == "Btn_Begin" then
    self:StartLottery()
  elseif id == "Btn_Close" then
    self:Hide()
  elseif strs[1] == "Item" then
    local idx = tonumber(strs[2])
    if idx then
      local lotteryCfg = ItemUtils.GetLotteryViewRandomCfg(constant.ShimenActivityCfgConsts.LOTTERY_VIEW_ID)
      local itemId = lotteryCfg.itemIds[idx]
      local Group_Item = self.m_panel:FindDirect("Img_Bg1/Group_Lottery/Group_Item")
      local Item = Group_Item:FindDirect(string.format("Item_%02d", idx))
      local Img_Icon = Item:FindDirect("Img_Icon")
      local sprite = Img_Icon:GetComponent("UITexture")
      local position = Img_Icon:get_position()
      local screenPos = WorldPosToScreen(position.x, position.y)
      ItemTipsMgr.Instance():ShowBasicTips(itemId, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), 0, false)
    end
  end
end
def.method().InitUI = function(self)
  local btn_begin = self.m_panel:FindDirect("Img_Bg1/Btn_Begin")
  local btn_stop = self.m_panel:FindDirect("Img_Bg1/Btn_Stop")
  btn_stop:SetActive(false)
  btn_begin:SetActive(true)
  local Img_Stop = self.m_panel:FindDirect("Img_Bg1/Group_Lottery/Img_Stop")
  local tween = Img_Stop:GetComponent("TweenRotation")
  tween.enabled = false
  local time_label = self.m_panel:FindDirect("Img_Bg1/Label_Time")
  time_label:GetComponent("UILabel"):set_text(self.time)
  local lotteryCfg = ItemUtils.GetLotteryViewRandomCfg(constant.ShimenActivityCfgConsts.LOTTERY_VIEW_ID)
  local Group_Item = self.m_panel:FindDirect("Img_Bg1/Group_Lottery/Group_Item")
  for i, v in pairs(lotteryCfg.itemIds) do
    local Item = Group_Item:FindDirect(string.format("Item_%02d", i))
    local itemBase = ItemUtils.GetItemBase(v)
    local Img_Icon = Item:FindDirect("Img_Icon"):GetComponent("UITexture")
    GUIUtils.FillIcon(Img_Icon, itemBase.icon)
  end
  self:StartLottery()
end
def.method().StartLottery = function(self)
  GameUtil.RemoveGlobalTimer(self.timerId)
  local btn_begin = self.m_panel:FindDirect("Img_Bg1/Btn_Begin")
  local btn_stop = self.m_panel:FindDirect("Img_Bg1/Btn_Stop")
  btn_stop:SetActive(true)
  btn_begin:SetActive(false)
  local time_label = self.m_panel:FindDirect("Img_Bg1/Label_Time")
  time_label:GetComponent("UILabel"):set_text("")
  local Img_Stop = self.m_panel:FindDirect("Img_Bg1/Group_Lottery/Img_Stop")
  local tween = Img_Stop:GetComponent("TweenRotation")
  tween.enabled = true
  self.timerId = GameUtil.AddGlobalTimer(3, true, function()
    self:StopLottery()
  end)
end
def.method().StopLottery = function(self)
  local btn_stop = self.m_panel:FindDirect("Img_Bg1/Btn_Stop")
  GameUtil.RemoveGlobalTimer(self.timerId)
  self.timerId = 0
  local Img_Stop = self.m_panel:FindDirect("Img_Bg1/Group_Lottery/Img_Stop")
  local twRotComp = Img_Stop:GetComponent("TweenRotation")
  twRotComp.style = 0
  twRotComp.method = 2
  twRotComp.tweenFactor = 0
  twRotComp:SetStartToCurrentValue()
  twRotComp.to = EC.Vector3.new(0, 0, itemAngle[self.itemIdx])
  twRotComp.duration = 4
  twRotComp:Play()
  self.timerId = GameUtil.AddGlobalTimer(5, true, function()
    self:Hide()
  end)
end
def.method().Hide = function(self)
  GameUtil.RemoveGlobalTimer(self.timerId)
  self.timerId = 0
  local p = require("netio.protocol.mzm.gsp.item.CLotteryAwardFinish").new()
  gmodule.network.sendProtocol(p)
  PersonalHelper.CommonMsg(PersonalHelper.Type.Text, textRes.activity[371], PersonalHelper.Type.ItemMap, {
    [self.itemId] = self.itemNum
  })
  self:DestroyPanel()
end
return ShimenLottery.Commit()
