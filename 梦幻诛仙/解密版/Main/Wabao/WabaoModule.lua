local Lplus = require("Lplus")
local ItemModule = require("Main.Item.ItemModule")
local WabaoPanel = require("Main.Wabao.ui.WabaoPanel")
local EasyUseDlg = require("Main.Item.ui.EasyUseDlg")
local ItemUtils = require("Main.Item.ItemUtils")
local PersonalHelper = require("Main.Chat.PersonalHelper")
local ModuleBase = require("Main.module.ModuleBase")
local WabaoModule = Lplus.Extend(ModuleBase, "WabaoModule")
require("Main.module.ModuleId")
local def = WabaoModule.define
local _instance
def.static("=>", WabaoModule).Instance = function()
  if _instance == nil then
    _instance = WabaoModule()
    _instance.m_moduleId = ModuleId.WABAO
  end
  return _instance
end
def.field("boolean").isFinding = false
def.field("number").tarMapId = 0
def.field("number").tarX = 0
def.field("number").tarY = 0
def.field("number").itemKey = 0
def.field("number").itemId = 0
def.field("table").award = nil
def.field("table").controllers = nil
def.override().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.baotu.SUseResultRes", WabaoModule._onSUseResultRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.baotu.SBaoTuNormalResult", WabaoModule._onSUseError)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.baotu.SBaotuFanBaoBulletinRes", WabaoModule._onSBaotuFanBaoBulletinRes)
  Event.RegisterEvent(ModuleId.WABAO, gmodule.notifyId.Wabao.BAOTU_USE, WabaoModule._onBaotuUse)
  ModuleBase.Init(self)
end
def.static("table")._onSUseResultRes = function(p)
  WabaoPanel.ShowWabaoReward(p.awardIdList)
  WabaoModule.Instance().award = p.awardIdList[1]
end
def.static("table")._onSUseError = function(p)
  if p.result == p.ERR_BAG_IS_FULL then
    Toast(textRes.Baotu[28])
  end
end
def.static("table")._onSBaotuFanBaoBulletinRes = function(p)
  local AnnouncementTip = require("GUI.AnnouncementTip")
  local ChatModule = require("Main.Chat.ChatModule")
  local ChatMsgData = require("Main.Chat.ChatMsgData")
  local HtmlHelper = require("Main.Chat.HtmlHelper")
  local ChatMsgBuilder = require("Main.Chat.ChatMsgBuilder")
  local roleName = ChatMsgBuilder.Unmarshal(p.roleName)
  local itemId = p.itemId
  local itemBase = ItemUtils.GetItemBase(itemId)
  local ctlId = p.controllerId
  local ctlCfg = WabaoModule.Instance():GetControllerCfg(ctlId)
  local mapId = p.mapId
  local mapCfg = require("Main.Map.MapUtility").GetMapCfg(mapId)
  if roleName and itemBase and ctlCfg and mapCfg then
    local mapName = mapCfg.mapName
    local itemName = itemBase.name
    local type = ctlCfg.type
    if type == 1 then
    elseif type == 2 then
      AnnouncementTip.Announce(string.format(textRes.AnnounceMent[10], roleName, mapName))
      ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.BaoTu, {
        name = roleName,
        mapname = mapName,
        type = type
      })
    elseif type == 3 then
      AnnouncementTip.Announce(string.format(textRes.AnnounceMent[82], roleName, mapName))
      ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.BaoTu, {
        name = roleName,
        mapname = mapName,
        type = type
      })
    end
  end
end
def.method("userdata").Wabao = function(self, uuid)
  local wabao = require("netio.protocol.mzm.gsp.baotu.CUseBaoTuReq").new(uuid)
  gmodule.network.sendProtocol(wabao)
end
def.method().WabaoFinish = function(self)
  local wabaoFinish = require("netio.protocol.mzm.gsp.baotu.CUseBaotuFinish").new()
  gmodule.network.sendProtocol(wabaoFinish)
  WabaoModule.Instance():NoticeAward(WabaoModule.Instance().award)
end
def.static("table", "table")._onBaotuUse = function(params, context)
  print("_onBaotuUse")
  local item = ItemModule.Instance():GetItemByBagIdAndItemKey(params.bagId, params.itemKey)
  local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
  local mapId = item.extraMap[ItemXStoreType.BAO_TU_MAPID]
  local x = item.extraMap[ItemXStoreType.BAO_TU_X]
  local y = item.extraMap[ItemXStoreType.BAO_TU_Y]
  local curMapId = require("Main.Map.Interface").GetCurMapId()
  local heroModule = gmodule.moduleMgr:GetModule(ModuleId.HERO)
  local pos = heroModule:GetPos()
  if mapId ~= nil and x ~= nil and y ~= nil then
    if mapId == curMapId and x == pos.x and y == pos.y then
      WabaoModule.Instance():Wabao(item.uuid[1])
    else
      heroModule.needShowAutoEffect = true
      heroModule:MoveTo(mapId, x, y, 0, 0, MoveType.AUTO, nil)
      Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.HERO_CLICKMAP_FINDPATH, {x = x, y = y})
      WabaoModule.Instance().isFinding = true
      WabaoModule.Instance().tarX = x
      WabaoModule.Instance().tarY = y
      WabaoModule.Instance().itemKey = params.itemKey
      WabaoModule.Instance().itemId = item.id
      Event.RegisterEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.HERO_FINDPATH_FINISHED, WabaoModule._onArrive)
    end
  end
end
def.static("table", "table")._onArrive = function(params, context)
  warn("Wabao On Arrive")
  Event.UnregisterEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.HERO_FINDPATH_FINISHED, WabaoModule._onArrive)
  if WabaoModule.Instance().isFinding == true then
    WabaoModule.Instance().isFinding = false
    if params.x == WabaoModule.Instance().tarX and params.y == WabaoModule.Instance().tarY then
      local item = ItemModule.Instance():GetItemByBagIdAndItemKey(ItemModule.BAG, WabaoModule.Instance().itemKey)
      if item and item.id == WabaoModule.Instance().itemId then
        local OperationBaotuUse = require("Main.Item.Operations.OperationBaotuUse")
        local ope = OperationBaotuUse()
        ope.quickItem = item
        EasyUseDlg.ShowEasyUse(item, WabaoModule.Instance().itemKey, ope, false, 1)
      else
        Toast(textRes.BaoTu[30])
      end
    end
  end
end
def.method().TryToWabao = function(self)
  warn("TryToWabao")
  local itemKey, item = ItemModule.Instance():SelectOneItemByItemId(ItemModule.BAG, self.itemId)
  if itemKey ~= -1 then
    do
      local OperationBaotuUse = require("Main.Item.Operations.OperationBaotuUse")
      local ope = OperationBaotuUse()
      local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
      local mapId = item.extraMap[ItemXStoreType.BAO_TU_MAPID]
      local curMapId = require("Main.Map.Interface").GetCurMapId()
      if mapId == curMapId then
        ope:Operate(ItemModule.BAG, itemKey, nil, nil)
      else
        GameUtil.AddGlobalTimer(1, true, function()
          ope:Operate(ItemModule.BAG, itemKey, nil, nil)
        end)
      end
    end
  end
end
def.method("table").NoticeAward = function(self, info)
  if info == nil then
    return
  end
  local RewardItem = require("netio.protocol.mzm.gsp.baotu.RewardItem")
  local type = info.rewardType
  if type == RewardItem.TYPE_ITEM then
    do
      local itemId = info.paramMap[RewardItem.PARAM_ITEM_ID]
      local num = info.paramMap[RewardItem.PARAM_ITEM_NUM]
      PersonalHelper.CommonMsg(PersonalHelper.Type.Text, textRes.BaoTu[1], PersonalHelper.Type.ItemMap, {
        [itemId] = num
      })
      SafeLuckDog(function()
        local itemBase = ItemUtils.GetItemBase(itemId)
        local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
        return itemBase and (itemBase.itemType == ItemType.WING_VIEW_ITEM or itemBase.itemType == ItemType.AIR_CRAFT_ITEM) or false
      end)
    end
  elseif type == RewardItem.TYPE_ROLE_EXP then
    local exp = info.paramMap[RewardItem.PARAM_EXP]
    PersonalHelper.CommonMsg(PersonalHelper.Type.Text, textRes.BaoTu[1], PersonalHelper.Type.RoleExp, tostring(exp))
  elseif type == RewardItem.TYPE_PET_EXP then
    local exp = info.paramMap[RewardItem.PARAM_EXP]
  elseif type == RewardItem.TYPE_XIULIAN_EXP then
    local exp = info.paramMap[RewardItem.PARAM_EXP]
    PersonalHelper.CommonMsg(PersonalHelper.Type.Text, textRes.BaoTu[1], PersonalHelper.Type.ColorText, textRes.BaoTu[3], "00ff00", PersonalHelper.Type.Text, tostring(exp))
  elseif type == RewardItem.TYPE_SILVER then
    local money = info.paramMap[RewardItem.PARAM_MONEY]
    PersonalHelper.CommonMsg(PersonalHelper.Type.Text, textRes.BaoTu[1], PersonalHelper.Type.Silver, Int64.new(money))
  elseif type == RewardItem.TYPE_GOLD then
    local money = info.paramMap[RewardItem.PARAM_MONEY]
    PersonalHelper.CommonMsg(PersonalHelper.Type.Text, textRes.BaoTu[1], PersonalHelper.Type.Gold, Int64.new(money))
  elseif type == RewardItem.TYPE_BANGGONG then
    local money = info.paramMap[RewardItem.PARAM_MONEY]
    PersonalHelper.CommonMsg(PersonalHelper.Type.Text, textRes.BaoTu[1], PersonalHelper.Type.ColorText, textRes.BaoTu[2], "00ff00", PersonalHelper.Type.Text, tostring(money))
  elseif type == RewardItem.TYPE_CONTROLLER then
    local ctlId = info.paramMap[RewardItem.PARAM_OCNTROLLER_ID]
    local ctlCfg = WabaoModule.Instance():GetControllerCfg(ctlId)
    local mapId = info.paramMap[RewardItem.PARAM_MAP_ID]
    local mapCfg = require("Main.Map.MapUtility").GetMapCfg(mapId)
    local notice = textRes.Wabao.WabaoTypeNotice[ctlCfg.type]
    if ctlCfg and mapCfg and notice then
      local mapName = mapCfg.mapName
      local notice = string.format(notice, mapName)
      PersonalHelper.CommonMsg(PersonalHelper.Type.Text, notice)
    end
  elseif type == RewardItem.TYPE_YUANBAO then
    local money = info.paramMap[RewardItem.PARAM_MONEY]
    PersonalHelper.CommonMsg(PersonalHelper.Type.Text, textRes.BaoTu[1], PersonalHelper.Type.Yuanbao, Int64.new(money))
  end
end
def.method("number", "=>", "table").GetControllerCfg = function(self, id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_BAOTU_CONTROLLER, id)
  if record == nil then
    print("GetControllerCfg nil :" .. id)
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.type = record:GetIntValue("type")
  cfg.name = record:GetStringValue("name")
  cfg.iconId = record:GetIntValue("iconId")
  cfg.desc = record:GetStringValue("desc")
  return cfg
end
def.method("=>", "boolean").GotoWabao = function(self)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  local items = ItemModule.Instance():GetItemsByItemType(ItemModule.BAG, ItemType.ITEMTYPE_BAOTU)
  local minId, itemKey = math.huge, -1
  for k, v in pairs(items) do
    if minId > v.id or v.id == minId and k < itemKey then
      minId = v.id
      itemKey = k
    end
  end
  if itemKey >= 0 then
    local OperationBaotuUse = require("Main.Item.Operations.OperationBaotuUse")
    local ope = OperationBaotuUse()
    return ope:Operate(ItemModule.BAG, itemKey, nil, nil)
  else
    Toast(textRes.BaoTu[29])
    return false
  end
end
WabaoModule.Commit()
return WabaoModule
