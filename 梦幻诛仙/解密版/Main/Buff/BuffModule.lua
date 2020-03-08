local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local BuffModule = Lplus.Extend(ModuleBase, "BuffModule")
local BuffMgr = require("Main.Buff.BuffMgr")
local def = BuffModule.define
local instance
def.static("=>", BuffModule).Instance = function()
  if instance == nil then
    instance = BuffModule()
    instance.m_moduleId = ModuleId.BUFF
  end
  return instance
end
def.override().Init = function(self)
  require("Main.Buff.BUffUIMgr").Instance()
  require("Main.Buff.NutritionUOPMgr").Instance():Init()
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.buff.SSyncRoleBuffList", BuffModule.OnSSyncRoleBuffList)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.buff.SAddBuff", BuffModule.OnSAddBuff)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.buff.SRemoveBuff", BuffModule.OnSRemoveBuff)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.buff.SBuffAmountChange", BuffModule.OnSBuffAmountChange)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.role.SSyncBaoShiDuInfo", BuffModule.OnSSyncBaoShiDuInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.role.SAddBaoShiDuRes", BuffModule.OnSAddBaoShiDuRes)
  Event.RegisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BUFF_ICON_CLICK, BuffModule.OnBuffIconClick)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Equip_Broken_Update, BuffModule.OnEquipmentBrokenUpdate)
  Event.RegisterEvent(ModuleId.TURNED_CARD, gmodule.notifyId.TurnedCard.Turned_Card_Init_Data_Finish, BuffModule.OnTurnedCardInited)
  Event.RegisterEvent(ModuleId.TURNED_CARD, gmodule.notifyId.TurnedCard.Use_Turned_Card_Change, BuffModule.OnUsedTurnedCardChange)
end
def.static("table", "table").OnBuffIconClick = function(params, context)
  local BuffMgr = require("Main.Buff.BuffMgr")
  if BuffMgr.Instance():GetBuffAmount() == 0 then
    return
  end
  require("Main.Buff.ui.BuffPanel").Instance():ShowPanel()
end
def.static("table").OnSSyncRoleBuffList = function(data)
  BuffMgr.Instance():SetBuffList(data.buffList)
end
def.static("table").OnSAddBuff = function(data)
  BuffMgr.Instance():RawAddBuff(data.buff)
end
def.static("table").OnSRemoveBuff = function(data)
  BuffMgr.Instance():RemoveBuff(data.buffId)
end
def.static("table").OnSBuffAmountChange = function(data)
  BuffMgr.Instance():SetBuffValue(data.buffId, Int64.new(data.buffCount))
end
def.static("table").OnSSyncBaoShiDuInfo = function(data)
  BuffMgr.Instance():SetBuffValue(BuffMgr.NUTRITION_BUFF_ID, Int64.new(data.baoshudu))
end
def.static("table").OnSAddBaoShiDuRes = function(data)
  Event.DispatchEvent(ModuleId.BUFF, gmodule.notifyId.Buff.SUCCESS_SUPPLEMENT_NUTRITION, {
    data.addBaoShuDu
  })
end
def.static("table", "table").OnEquipmentBrokenUpdate = function(params)
  local isBroken = params.broken
  if isBroken then
    local buffData = require("Main.BUff.data.EquipBrokenBuffData").New()
    BuffMgr.Instance():AddBuff(buffData)
  else
    BuffMgr.Instance():RemoveBuff(BuffMgr.EQUIP_BROKEN_BUFF_ID)
  end
end
def.static("table", "table").OnTurnedCardInited = function(params)
  local TurnedCardInterface = require("Main.TurnedCard.TurnedCardInterface")
  local hasTurnedCard = TurnedCardInterface.Instance():getCurTurnedCardId() ~= 0
  local buff = BuffMgr.Instance():GetBuff(BuffMgr.CAC_BUFF_ID)
  if hasTurnedCard and buff == nil then
    local buffData = require("Main.BUff.data.CACBuffData").New()
    BuffMgr.Instance():AddBuffEx(buffData, {silence = true})
  end
end
def.static("table", "table").OnUsedTurnedCardChange = function(params)
  local TurnedCardInterface = require("Main.TurnedCard.TurnedCardInterface")
  local hasTurnedCard = TurnedCardInterface.Instance():getCurTurnedCardId() ~= 0
  local buff = BuffMgr.Instance():GetBuff(BuffMgr.CAC_BUFF_ID)
  if hasTurnedCard then
    if buff then
      buff:OnInit()
      Event.DispatchEvent(ModuleId.BUFF, gmodule.notifyId.Buff.BUFF_INFO_UPDATE, {
        BuffMgr.CAC_BUFF_ID
      })
    else
      local buffData = require("Main.BUff.data.CACBuffData").New()
      BuffMgr.Instance():AddBuff(buffData)
    end
  elseif buff then
    BuffMgr.Instance():RemoveBuff(BuffMgr.CAC_BUFF_ID)
  end
end
return BuffModule.Commit()
