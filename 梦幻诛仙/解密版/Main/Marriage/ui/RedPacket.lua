local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local RedPacket = Lplus.Extend(ECPanelBase, "RedPacket")
local MoneyType = require("consts.mzm.gsp.item.confbean.MoneyType")
local ItemModule = require("Main.Item.ItemModule")
local def = RedPacket.define
local instance
def.static("=>", RedPacket).Instance = function()
  if instance == nil then
    instance = RedPacket()
  end
  return instance
end
def.field("table").data = nil
def.field("number").select = 1
def.field("userdata").roleId = nil
def.field("string").roleName = ""
def.static("table", "userdata", "string").ShowRedPacket = function(info, roleId, roleName)
  if info == nil or roleId == nil then
    return
  end
  local dlg = RedPacket.Instance()
  if dlg:IsShow() then
    return
  end
  dlg.data = info
  dlg.roleId = roleId
  dlg.roleName = roleName
  dlg:CreatePanel(RESPATH.PREFAB_MARRY_REDPACKET, 1)
  dlg:SetModal(true)
end
def.override().OnCreate = function(self)
  self:UpdateList()
end
def.override().OnDestroy = function(self)
end
def.method().UpdateList = function(self)
  local modeList = self.m_panel:FindDirect("Img_Bg/Group_ModeList/Scroll View/List_Mode")
  local uiList = modeList:GetComponent("UIList")
  uiList:set_itemCount(#self.data)
  uiList:Resize()
  for i = 1, #self.data do
    local item = modeList:FindDirect(string.format("ListTemplate_%d", i))
    local nameLabel = item:FindDirect(string.format("Label_Mode_%d", i, i)):GetComponent("UILabel")
    nameLabel:set_text(self.data[i].name)
    if i == self.select then
      local selectToggle = item:FindDirect(string.format("Btn_Select_%d", i)):GetComponent("UIToggle")
      selectToggle:set_value(true)
    end
    local spr = item:FindDirect(string.format("Img_Cost_%d", i)):GetComponent("UISprite")
    if self.data[i].money == MoneyType.GOLD then
      spr:set_spriteName("Icon_Gold")
    elseif self.data[i].money == MoneyType.SILVER then
      spr:set_spriteName("Icon_Sliver")
    elseif self.data[i].money == MoneyType.YUANBAO then
      spr:set_spriteName("Img_Money")
    end
    local numLbl = item:FindDirect(string.format("Img_Cost_%d/Label_Num_%d", i, i)):GetComponent("UILabel")
    numLbl:set_text(string.format("%d", self.data[i].number))
  end
  self.m_msgHandler:Touch(modeList)
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_Send" then
    do
      local info = self.data[self.select]
      if info then
        if info.money == MoneyType.GOLD then
          local count = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_GOLD)
          if count < Int64.new(info.number) then
            Toast(textRes.Marriage[29])
            return
          end
        elseif info.money == MoneyType.SILVER then
          local count = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER)
          if count < Int64.new(info.number) then
            Toast(textRes.Marriage[30])
            return
          end
        elseif info.money == MoneyType.YUANBAO then
          local myyuanbao = ItemModule.Instance():GetYuanbao(ItemModule.CASH_TOTAL_CASH) + ItemModule.Instance():GetYuanbao(ItemModule.CASH_PRESENT) - ItemModule.Instance():GetYuanbao(ItemModule.CASH_TOTAL_COST)
          if Int64.new(info.number):gt(myyuanbao) then
            _G.GotoBuyYuanbao()
            return
          end
        end
        local str = string.format(textRes.Marriage[45], info.number, textRes.Marriage.MoneyType[info.money], self.roleName)
        local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
        CommonConfirmDlg.ShowConfirm(textRes.Marriage[46], str, function(select)
          if select == 1 then
            require("Main.Marriage.MarriageModule").Instance():C2SSendRedPacket(self.roleId, info.id)
            self:DestroyPanel()
          end
        end, nil)
      end
    end
  elseif id == "Btn_Tips" then
    local tip = require("Main.Common.TipsHelper").GetHoverTip(constant.CMarriageConsts.giftTip)
    require("GUI.CommonUITipsDlg").ShowCommonTip(tip, {x = 0, y = 0})
    local ECMSDK = require("ProxySDK.ECMSDK")
    ECMSDK.SendTLogToServer(_G.TLOGTYPE.PANELNAME, {
      self.m_panel.name
    })
  end
end
def.method("string", "boolean").onToggle = function(self, id, active)
  if string.sub(id, 1, 11) == "Btn_Select_" and active then
    local index = tonumber(string.sub(id, 12))
    self.select = index
  end
end
RedPacket.Commit()
return RedPacket
