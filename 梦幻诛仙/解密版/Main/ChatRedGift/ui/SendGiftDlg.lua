local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local SendGiftDlg = Lplus.Extend(ECPanelBase, "SendGiftDlg")
local MoneyType = require("consts.mzm.gsp.item.confbean.MoneyType")
local ItemModule = require("Main.Item.ItemModule")
local def = SendGiftDlg.define
local instance
def.field("table").data = nil
def.field("number").select = 0
def.field("function").callback = nil
def.static("table", "function").ShowSendGift = function(data, cb)
  if data == nil then
    return
  end
  local dlg = SendGiftDlg()
  if dlg:IsShow() then
    return
  end
  dlg.data = data
  dlg.callback = cb
  dlg:CreatePanel(RESPATH.PREFAB_SEND_GIFT, 1)
  dlg:SetModal(true)
end
def.override().OnCreate = function(self)
  self:UpdateList()
end
def.override().OnDestroy = function(self)
end
def.method().UpdateList = function(self)
  local scroll = self.m_panel:FindDirect("Img_Bg/Img_Bg01/Scroll View_Item")
  local list = scroll:FindDirect("List_Bg")
  local uiList = list:GetComponent("UIList")
  uiList:set_itemCount(#self.data)
  uiList:Resize()
  GameUtil.AddGlobalLateTimer(0, true, function()
    if not uiList.isnil then
      uiList:Reposition()
    end
  end)
  GameUtil.AddGlobalLateTimer(0.01, true, function()
    if not scroll.isnil then
      scroll:GetComponent("UIScrollView"):ResetPosition()
    end
  end)
  local items = uiList:get_children()
  for i = 1, #items do
    local uiGo = items[i]
    local info = self.data[i]
    local nameLabel = uiGo:FindDirect("Label_Name")
    nameLabel:GetComponent("UILabel"):set_text(info.name)
    uiGo:GetComponent("UIToggle"):set_value(false)
    local spr = uiGo:FindDirect("Img_UseMoney/Img_Icon"):GetComponent("UISprite")
    if info.moneyType == MoneyType.GOLD then
      spr:set_spriteName("Icon_Gold")
    elseif info.moneyType == MoneyType.SILVER then
      spr:set_spriteName("Icon_Sliver")
    elseif info.moneyType == MoneyType.YUANBAO then
      spr:set_spriteName("Img_Money")
    end
    local numLbl = uiGo:FindDirect("Img_UseMoney/Label_Num")
    numLbl:GetComponent("UILabel"):set_text(tostring(info.moneyNum))
  end
  self.m_msgHandler:Touch(list)
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_Give" then
    local info = self.data[self.select]
    if info then
      if info.moneyType == MoneyType.GOLD then
        local count = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_GOLD)
        if count < Int64.new(info.moneyNum) then
          Toast(textRes.Marriage[29])
          return
        end
      elseif info.moneyType == MoneyType.SILVER then
        local count = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER)
        if count < Int64.new(info.moneyNum) then
          Toast(textRes.Marriage[30])
          return
        end
      elseif info.moneyType == MoneyType.YUANBAO then
        local myyuanbao = ItemModule.Instance():GetYuanbao(ItemModule.CASH_TOTAL_CASH) + ItemModule.Instance():GetYuanbao(ItemModule.CASH_PRESENT) - ItemModule.Instance():GetYuanbao(ItemModule.CASH_TOTAL_COST)
        if Int64.new(info.moneyNum):gt(myyuanbao) then
          Toast(textRes.Marriage[27])
          _G.GotoBuyYuanbao()
          return
        end
      end
      self:DestroyPanel()
      if self.callback then
        self.callback(self.select)
      end
    end
  end
end
def.method("string", "boolean").onToggle = function(self, id, active)
  if string.sub(id, 1, 5) == "item_" and active then
    local index = tonumber(string.sub(id, 6))
    self.select = index
  end
end
SendGiftDlg.Commit()
return SendGiftDlg
