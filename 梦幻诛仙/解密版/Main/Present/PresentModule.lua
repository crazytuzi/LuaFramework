local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local PresentModule = Lplus.Extend(ModuleBase, "PresentModule")
local def = PresentModule.define
local PresentPanel = require("Main.Present.ui.PresentPanel")
local PresentData = require("Main.Present.data.PresentData")
local instance
def.static("=>", PresentModule).Instance = function()
  if instance == nil then
    instance = PresentModule()
    instance.m_moduleId = ModuleId.PRESENT
  end
  return instance
end
def.override().Init = function(self)
  Event.RegisterEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnPresent, PresentModule.OnShowPresentPanel)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, function()
    self:Reset()
  end)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SSynRoleGiveItemInfo", PresentModule.OnSSynRoleGiveItemInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SGiveItemCountChangeInfo", PresentModule.OnSGiveItemCountChangeInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SGiveYuanbaoCountChangeInfo", PresentModule.OnSGiveYuanbaoCountChangeInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SGiveItemSuccess", PresentModule.OnSGiveItemSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SCommonErrorInfo", PresentModule.OnSCommonErrorInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SGiveFlowerRes", PresentModule.OnSGiveFlowerRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.friend.SUpdateRelationValue", PresentModule.OnSUpdateRelationValue)
end
def.override().OnReset = function(self)
  local data = PresentData.Instance()
  data:SetAllNull()
end
def.static("table", "table").OnShowPresentPanel = function(params, tbl)
  PresentPanel.Instance():ShowPanel(params[1], params[2])
end
def.static("table").OnSSynRoleGiveItemInfo = function(p)
  PresentData.Instance():SyncItemMap(p.roleid2count)
  PresentData.Instance():SyncMallMap(p.roleid2yuanbao)
end
def.static("table").OnSGiveItemCountChangeInfo = function(p)
  PresentData.Instance():SetItem(p.roleid, p.count)
  Event.DispatchEvent(ModuleId.PRESENT, gmodule.notifyId.Present.PresentInfoChanged, nil)
end
def.static("table").OnSGiveYuanbaoCountChangeInfo = function(p)
  PresentData.Instance():SetMall(p.roleid, p.count)
  Event.DispatchEvent(ModuleId.PRESENT, gmodule.notifyId.Present.PresentInfoChanged, nil)
end
def.static("table").OnSGiveItemSuccess = function(p)
  Event.DispatchEvent(ModuleId.PRESENT, gmodule.notifyId.Present.PresentSucceed, {
    p.roleid
  })
end
def.static("table").OnSCommonErrorInfo = function(p)
  if textRes.Present.Error[p.errorCode] then
    Toast(textRes.Present.Error[p.errorCode])
  end
end
def.static("table").OnSGiveFlowerRes = function(p)
  local heroProp = require("Main.Hero.Interface").GetBasicHeroProp()
  local itemBase = require("Main.Item.ItemUtils").GetItemBase(p.itemid)
  if p.message == nil then
    p.message = textRes.Present[12]
  end
  local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
  if heroProp.id == p.giverRoleid then
    Event.DispatchEvent(ModuleId.PRESENT, gmodule.notifyId.Present.FlowerSucceed, {
      p.receiverRoleid
    })
    Toast(string.format(textRes.Present[15], ItemTipsMgr.Color[itemBase.namecolor], itemBase.name, p.itemnum, p.receiverRoleName))
    local bFriend = require("Main.friend.FriendModule").Instance():IsFriend(p.receiverRoleid)
    if bFriend and p.addIntimacyNum > 0 then
      Toast(string.format(textRes.Present[16], p.receiverRoleName, p.addIntimacyNum))
    end
  elseif heroProp.id == p.receiverRoleid then
    local PersonalHelper = require("Main.Chat.PersonalHelper")
    local text = string.format(textRes.Present[17], p.giverRoleName, ItemTipsMgr.Color[itemBase.namecolor], itemBase.name, p.itemnum, p.message)
    PersonalHelper.CommonMsg(PersonalHelper.Type.Text, text)
    local bFriend = require("Main.friend.FriendModule").Instance():IsFriend(p.giverRoleid)
    if bFriend and p.addIntimacyNum > 0 then
      Toast(string.format(textRes.Present[16], p.giverRoleName, p.addIntimacyNum))
    end
  end
  if p.effectid ~= 0 and (heroProp.id == p.giverRoleid or heroProp.id == p.receiverRoleid) then
    local effRes = GetEffectRes(p.effectid)
    local name = tostring(p.effectid)
    require("Fx.GUIFxMan").Instance():Play(effRes.path, name, 0, 0, -1, false)
  end
  if p.isall ~= 0 and heroProp.id == p.receiverRoleid then
    require("Main.Present.ui.FlowerEffectPanel").Instance():ShowPanel(p.giverRoleName, itemBase.name, p.itemnum, p.receiverRoleName, p.message, ItemTipsMgr.Color[itemBase.namecolor])
  end
end
def.static("table").OnSUpdateRelationValue = function(p)
  Event.DispatchEvent(ModuleId.PRESENT, gmodule.notifyId.Present.FriendQinMiDuChanged, {
    p.friendId,
    p.relationValue
  })
end
return PresentModule.Commit()
