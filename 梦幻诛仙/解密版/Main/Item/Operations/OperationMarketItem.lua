local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local EquipUtils = require("Main.Equip.EquipUtils")
local ItemModule = require("Main.Item.ItemModule")
local ChatModule = require("Main.Chat.ChatModule")
local OperationMarketItem = Lplus.Extend(OperationBase, "OperationMarketItem")
local def = OperationMarketItem.define
def.field("number").m_source = 0
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if source == ItemTipsMgr.Source.TradingArcade or source == ItemTipsMgr.Source.TradingArcadeSell then
    self.m_source = source
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[9520]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  local context = context or {}
  if context.id == "Btn_Share" then
    self:OnShareBtnClick(m_panel, context)
  elseif context.id == "Btn_Connect" and self.m_source ~= ItemTipsMgr.Source.TradingArcadeSell then
    self:ContactSeller(context)
  end
  return false
end
def.method("userdata", "table").OnShareBtnClick = function(self, tip, context)
  if tip == nil or tip.isnil then
    return
  end
  local Vector = require("Types.Vector")
  local go = tip:FindDirect("Table_Tips")
  go:set_localPosition(Vector.Vector3.new(-100, go.localPosition.y, 0))
  local position = go.position
  local screenPos = WorldPosToScreen(position.x, position.y)
  local widget = go:GetComponent("UIWidget")
  local pos = {
    auto = true,
    prefer = 0,
    preferY = 1
  }
  pos.sourceX = screenPos.x
  pos.sourceY = screenPos.y - widget.height / 2
  pos.sourceW = widget.width
  pos.sourceH = widget.height
  local TradingArcadeUtils = require("Main.TradingArcade.TradingArcadeUtils")
  TradingArcadeUtils.ShowShareOptionsPanel(context, pos)
end
def.method("table").ContactSeller = function(self, context)
  local sellerRoleId = context.sellerRoleId
  if sellerRoleId == nil then
    if context.goods then
      do
        local goods = context.goods
        local BuyServiceMgr = require("Main.TradingArcade.BuyServiceMgr")
        BuyServiceMgr.Instance():QueryGoodsDetail(goods, function(params)
          if context.sellerRoleId then
            return
          end
          context.sellerRoleId = goods.sellerRoleId or Int64.new(0)
          self:ContactSeller(context)
        end)
      end
    end
    return
  end
  if sellerRoleId == _G.GetMyRoleID() then
    Toast(textRes.TradingArcade[82])
    return
  end
  gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):ReqRoleInfo(sellerRoleId, function(roleInfo)
    ChatModule.Instance():ClearFriendNewCount(sellerRoleId)
    local content = string.format("{wmgd:%s,%s,%s}", tostring(context.marketId), context.refId, context.price)
    ChatModule.Instance():SendPrivateMsg(sellerRoleId, content, false)
    ChatModule.Instance():StartPrivateChat3(sellerRoleId, roleInfo.name, roleInfo.level, roleInfo.occupationId, roleInfo.gender, roleInfo.avatarId, roleInfo.avatarFrameId)
  end)
end
OperationMarketItem.Commit()
return OperationMarketItem
