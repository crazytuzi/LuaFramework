local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local GroupShoppingModule = Lplus.Extend(ModuleBase, "GroupShoppingModule")
require("Main.module.ModuleId")
local GroupShoppingData = require("Main.GroupShopping.GroupShoppingData")
local ItemUtils = require("Main.Item.ItemUtils")
local GroupShoppingUtils = require("Main.GroupShopping.GroupShoppingUtils")
local BigShoppingGroup = require("Main.GroupShopping.data.BigShoppingGroup")
local SmallShoppingGroup = require("Main.GroupShopping.data.SmallShoppingGroup")
local ShoppingGroupBase = require("Main.GroupShopping.data.ShoppingGroupBase")
local def = GroupShoppingModule.define
local instance
def.static("=>", GroupShoppingModule).Instance = function()
  if instance == nil then
    instance = GroupShoppingModule()
    instance.m_moduleId = ModuleId.GROUP_SHOPPING
  end
  return instance
end
def.field(GroupShoppingData).m_data = nil
def.field("table").m_cfgRequest = nil
def.field("table").m_groupRequest = nil
def.field("table").m_banData = nil
def.field("number").m_activityId = 0
def.field("function").m_pageRequestCallback = nil
def.field("table").m_notifyQueue = nil
def.field("number").m_notifyTimer = 0
def.override().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.groupshopping.SGetSmallGroupShoppingItemInfoRes", GroupShoppingModule.OnSGetSmallGroupShoppingItemInfoRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.groupshopping.SGetBigGroupShoppingItemInfoRes", GroupShoppingModule.OnSGetBigGroupShoppingItemInfoRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.groupshopping.SGetGroupShoppingItemInfoFail", GroupShoppingModule.OnSGetGroupShoppingItemInfoFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.groupshopping.SCreateShoppingGroupSuccess", GroupShoppingModule.OnSCreateShoppingGroupSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.groupshopping.SCreateShoppingGroupFail", GroupShoppingModule.OnSCreateShoppingGroupFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.groupshopping.SJoinShoppingGroupSuccess", GroupShoppingModule.OnSJoinShoppingGroupSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.groupshopping.SJoinShoppingGroupFail", GroupShoppingModule.OnSJoinShoppingGroupFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.groupshopping.SGroupShoppingDirectBuySuccess", GroupShoppingModule.OnSGroupShoppingDirectBuySuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.groupshopping.SGroupShoppingDirectBuyFail", GroupShoppingModule.OnSGroupShoppingDirectBuyFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.groupshopping.SBroadcastShoppingGroupCreated", GroupShoppingModule.OnSBroadcastShoppingGroupCreated)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.groupshopping.SBroadcastShoppingGroupSize", GroupShoppingModule.OnSBroadcastShoppingGroupSize)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.groupshopping.SBroadcastGroupShoppingCompleted", GroupShoppingModule.OnSBroadcastGroupShoppingCompleted)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.groupshopping.SGetShoppingGroupInfoRes", GroupShoppingModule.OnSGetShoppingGroupInfoRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.groupshopping.SGetShoppingGroupListRes", GroupShoppingModule.OnSGetShoppingGroupListRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.groupshopping.SSyncMyShoppingGroupList", GroupShoppingModule.OnSSyncMyShoppingGroupList)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.groupshopping.SSyncShoppingGroupSize", GroupShoppingModule.OnSSyncShoppingGroupSize)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.groupshopping.SSyncGroupShoppingBanInfo", GroupShoppingModule.OnSSyncGroupShoppingBanInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.groupshopping.SBroadcastGroupShoppingBanChanged", GroupShoppingModule.OnSBroadcastGroupShoppingBanChanged)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ENTER_WORLD, GroupShoppingModule.OnEnterWorld)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, GroupShoppingModule.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, GroupShoppingModule.OnFeatureChange)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Start, GroupShoppingModule.OnActivityOpen)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Close, GroupShoppingModule.OnActivityClose)
  Event.RegisterEvent(ModuleId.SERVER, gmodule.notifyId.Server.SYNC_SERVER_LEVEL, GroupShoppingModule.OnServeLvChange)
  ModuleBase.Init(self)
end
def.static("table").OnSGetSmallGroupShoppingItemInfoRes = function(p)
  local cfgId = p.group_shopping_item_cfgid
  GroupShoppingModule.Instance():DoCfgCallback(cfgId, {
    cfgId = cfgId,
    remain = p.remaining_num,
    buyCount = p.bought_num,
    groupNum = p.shopping_group_num
  })
end
def.static("table").OnSGetBigGroupShoppingItemInfoRes = function(p)
  local cfgId = p.group_shopping_item_cfgid
  GroupShoppingModule.Instance():DoCfgCallback(cfgId, {
    cfgId = cfgId,
    remain = p.remaining_num,
    buyCount = p.bought_num,
    groupId = p.group_id,
    memberNum = p.member_num
  })
end
def.static("table").OnSGetGroupShoppingItemInfoFail = function(p)
  GroupShoppingModule.Instance():RemoveCfgCallback(p.group_shopping_item_cfgid)
  local tip = textRes.GroupShopping.ItemInfoFail[p.reason]
  if tip then
    Toast(tip)
  end
end
def.static("table").OnSCreateShoppingGroupSuccess = function(p)
  local self = GroupShoppingModule.Instance()
  local data = self:InitData()
  data:AddGroup(p.group_info)
  GameUtil.AddGlobalTimer(0.5, true, function()
    require("Main.GroupShopping.ui.GroupShoppingShare").ShowShareGroup(textRes.GroupShopping[36], textRes.GroupShopping[37], p.group_info.group_shopping_item_cfgid, p.group_info.group_id)
  end)
  Event.DispatchEvent(ModuleId.GROUP_SHOPPING, gmodule.notifyId.GroupShopping.BuyCountChange, {
    cfgId = p.group_info.group_shopping_item_cfgid,
    groupId = p.group_info.group_id,
    memberNum = p.group_info.member_num
  })
end
def.static("table").OnSCreateShoppingGroupFail = function(p)
  local tip = textRes.GroupShopping.CreateFail[p.reason]
  if tip then
    Toast(tip)
  end
  Event.DispatchEvent(ModuleId.GROUP_SHOPPING, gmodule.notifyId.GroupShopping.NeedRefreshData, {
    cfgId = p.group_shopping_item_cfgid
  })
end
def.static("table").OnSJoinShoppingGroupSuccess = function(p)
  local self = GroupShoppingModule.Instance()
  local data = self:InitData()
  data:AddGroup(p.group_info)
  local group = data:GetGroup(p.group_info.group_id)
  if group then
    if group:IsFull() then
      local cfg = GroupShoppingUtils.GetGroupCfg(group:GetCfgId())
      if cfg then
        local itemBase = ItemUtils.GetItemBase(cfg.itemId)
        if itemBase then
          local str = string.format(textRes.GroupShopping[43], itemBase.name)
          Toast(str)
          local ChatMsgData = require("Main.Chat.ChatMsgData")
          require("Main.Chat.ChatModule").Instance():SendNoteMsg(str, ChatMsgData.MsgType.SYSTEM, ChatMsgData.System.SYS)
        end
      end
    else
      GameUtil.AddGlobalTimer(0.5, true, function()
        require("Main.GroupShopping.ui.GroupShoppingShare").ShowShareGroup(textRes.GroupShopping[38], string.format(textRes.GroupShopping[39], group:GetCurNum()), p.group_info.group_shopping_item_cfgid, p.group_info.group_id)
      end)
    end
  end
  Event.DispatchEvent(ModuleId.GROUP_SHOPPING, gmodule.notifyId.GroupShopping.BuyCountChange, {
    cfgId = p.group_info.group_shopping_item_cfgid,
    groupId = p.group_info.group_id,
    memberNum = p.group_info.member_num
  })
end
def.static("table").OnSJoinShoppingGroupFail = function(p)
  local tip = textRes.GroupShopping.JoinFail[p.reason]
  if tip then
    Toast(tip)
  end
  Event.DispatchEvent(ModuleId.GROUP_SHOPPING, gmodule.notifyId.GroupShopping.NeedRefreshData, {
    cfgId = p.group_shopping_item_cfgid
  })
end
def.static("table").OnSGroupShoppingDirectBuySuccess = function(p)
  local type = GroupShoppingUtils.GetGroupType(p.group_shopping_item_cfgid)
  if type == 0 then
    local cfg = GroupShoppingUtils.GetSmallGroupCfg(p.group_shopping_item_cfgid)
    if cfg then
      local itemBase = ItemUtils.GetItemBase(cfg.itemId)
      if itemBase then
        Toast(string.format(textRes.GroupShopping[1], itemBase.name))
      end
    end
  elseif type == 1 then
    local cfg = GroupShoppingUtils.GetBigGroupCfg(p.group_shopping_item_cfgid)
    if cfg then
      local itemBase = ItemUtils.GetItemBase(cfg.itemId)
      if itemBase then
        Toast(string.format(textRes.GroupShopping[1], itemBase.name))
      end
    end
  end
  Event.DispatchEvent(ModuleId.GROUP_SHOPPING, gmodule.notifyId.GroupShopping.BuyCountChange, {
    cfgId = p.group_shopping_item_cfgid
  })
end
def.static("table").OnSGroupShoppingDirectBuyFail = function(p)
  local tip = textRes.GroupShopping.BuyFail[p.reason]
  if tip then
    Toast(tip)
  end
end
def.static("table").OnSGetShoppingGroupInfoRes = function(p)
  local groupId = p.group_info.group_id
  local type = GroupShoppingUtils.GetGroupType(p.group_info.group_shopping_item_cfgid)
  if type == 0 then
    local smallGroup = SmallShoppingGroup.UnmarshalGroup(p.group_info)
    GroupShoppingModule.Instance():DoGroupCallback(groupId, smallGroup)
  elseif type == 1 then
    local bigGroup = BigShoppingGroup.UnmarshalGroup(p.group_info)
    GroupShoppingModule.Instance():DoGroupCallback(groupId, bigGroup)
  end
end
def.static("table").OnSGetShoppingGroupListRes = function(p)
  local groupList = {}
  for k, v in ipairs(p.shopping_groups) do
    local smallGroup = SmallShoppingGroup.UnmarshalGroup(v)
    table.insert(groupList, smallGroup)
  end
  local self = GroupShoppingModule.Instance()
  if self.m_pageRequestCallback then
    self.m_pageRequestCallback(groupList, p.page, p.last_page, p.group_shopping_item_cfgid)
  end
end
def.static("table").OnSSyncMyShoppingGroupList = function(p)
  local self = GroupShoppingModule.Instance()
  local data = self:InitData()
  for k, v in ipairs(p.list) do
    data:AddGroup(v)
  end
  self.m_activityId = GroupShoppingUtils.GetCurActivityId()
  self:UpdataOpen()
end
def.static("table").OnSSyncShoppingGroupSize = function(p)
  local self = GroupShoppingModule.Instance()
  local data = self:InitData()
  local groupData = data:GetGroup(p.group_id)
  groupData:SetCurNum(p.member_num)
  if groupData:IsFull() then
    local cfg = GroupShoppingUtils.GetGroupCfg(groupData:GetCfgId())
    if cfg then
      local itemBase = ItemUtils.GetItemBase(cfg.itemId)
      if itemBase then
        local str = string.format(textRes.GroupShopping[43], itemBase.name)
        Toast(str)
        local ChatMsgData = require("Main.Chat.ChatMsgData")
        require("Main.Chat.ChatModule").Instance():SendNoteMsg(str, ChatMsgData.MsgType.SYSTEM, ChatMsgData.System.SYS)
      end
    end
  end
  Event.DispatchEvent(ModuleId.GROUP_SHOPPING, gmodule.notifyId.GroupShopping.GroupMemberChange, {
    groupId = p.group_id
  })
end
def.static("table").OnSSyncGroupShoppingBanInfo = function(p)
  local self = GroupShoppingModule.Instance()
  for k, v in ipairs(p.ban_infos) do
    self:SetBan(v.id, v.is_ban ~= 0)
  end
end
def.static("table").OnSBroadcastGroupShoppingBanChanged = function(p)
  local self = GroupShoppingModule.Instance()
  self:SetBan(p.info.id, p.info.is_ban ~= 0)
  if self.m_data then
    self.m_data:FailGroup(p.info.id)
    Event.DispatchEvent(ModuleId.GROUP_SHOPPING, gmodule.notifyId.GroupShopping.MyGroupListChange, nil)
  end
end
def.static("table").OnSBroadcastShoppingGroupCreated = function(p)
  local creatorName = GetStringFromOcts(p.creator_name) or textRes.GroupShopping[44]
  local type = GroupShoppingUtils.GetGroupType(p.group_shopping_item_cfgid)
  local itemName = ""
  if type == 0 then
    local cfg = GroupShoppingUtils.GetSmallGroupCfg(p.group_shopping_item_cfgid)
    if cfg then
      local itemBase = ItemUtils.GetItemBase(cfg.itemId)
      if itemBase then
        itemName = itemBase.name
      end
    end
  elseif type == 1 then
    local cfg = GroupShoppingUtils.GetBigGroupCfg(p.group_shopping_item_cfgid)
    if cfg then
      local itemBase = ItemUtils.GetItemBase(cfg.itemId)
      if itemBase then
        itemName = itemBase.name
      end
    end
  end
  local groupIdStr = p.group_id:tostring()
  local content = string.format(textRes.GroupShopping[2], creatorName, itemName, p.group_shopping_item_cfgid, groupIdStr)
  GroupShoppingModule.Instance():SendNotify(content)
end
def.static("table").OnSBroadcastShoppingGroupSize = function(p)
  local memberName = GetStringFromOcts(p.member_name) or textRes.GroupShopping[44]
  local type = GroupShoppingUtils.GetGroupType(p.group_shopping_item_cfgid)
  local itemName = ""
  if type == 0 then
    local cfg = GroupShoppingUtils.GetSmallGroupCfg(p.group_shopping_item_cfgid)
    if cfg then
      local itemBase = ItemUtils.GetItemBase(cfg.itemId)
      if itemBase then
        itemName = itemBase.name
      end
    end
  elseif type == 1 then
    local cfg = GroupShoppingUtils.GetBigGroupCfg(p.group_shopping_item_cfgid)
    if cfg then
      local itemBase = ItemUtils.GetItemBase(cfg.itemId)
      if itemBase then
        itemName = itemBase.name
      end
    end
  end
  local num = p.member_num
  local groupIdStr = p.group_id:tostring()
  local content = string.format(textRes.GroupShopping[3], memberName, itemName, num, p.group_shopping_item_cfgid, groupIdStr)
  GroupShoppingModule.Instance():SendNotify(content)
end
def.static("table").OnSBroadcastGroupShoppingCompleted = function(p)
  local creatorName = GetStringFromOcts(p.creator_name) or textRes.GroupShopping[44]
  local type = GroupShoppingUtils.GetGroupType(p.group_shopping_item_cfgid)
  local itemName = ""
  local yuanbaoNum = 0
  if type == 0 then
    local cfg = GroupShoppingUtils.GetSmallGroupCfg(p.group_shopping_item_cfgid)
    if cfg then
      local itemBase = ItemUtils.GetItemBase(cfg.itemId)
      if itemBase then
        itemName = itemBase.name
      end
      yuanbaoNum = cfg.groupPrice
    end
  elseif type == 1 then
    local cfg = GroupShoppingUtils.GetBigGroupCfg(p.group_shopping_item_cfgid)
    if cfg then
      local itemBase = ItemUtils.GetItemBase(cfg.itemId)
      if itemBase then
        itemName = itemBase.name
      end
      yuanbaoNum = cfg.groupPrice
    end
  end
  local content = string.format(textRes.GroupShopping[4], creatorName, itemName, yuanbaoNum)
  GroupShoppingModule.Instance():SendNotify(content)
end
def.static("table", "table").OnActivityOpen = function(p1, p2)
  local activityId = p1[1]
  if GroupShoppingUtils.IsGroupShoppingActivity(activityId) then
    GroupShoppingModule.Instance().m_activityId = activityId
    GroupShoppingModule.Instance():UpdataOpen()
  end
end
def.static("table", "table").OnActivityClose = function(p1, p2)
  local activityId = p1[1]
  local self = GroupShoppingModule.Instance()
  if self.m_activityId == activityId then
    self.m_data = nil
    self.m_cfgRequest = nil
    self.m_groupRequest = nil
    self.m_banData = nil
    self.m_activityId = 0
    self.m_pageRequestCallback = nil
    self.m_notifyQueue = nil
    GameUtil.RemoveGlobalTimer(self.m_notifyTimer)
    self.m_notifyTimer = 0
    self:UpdataOpen()
  end
end
def.static("table", "table").OnEnterWorld = function(p1, p2)
  local self = GroupShoppingModule.Instance()
  if self.m_activityId == 0 then
    self.m_activityId = GroupShoppingUtils.GetCurActivityId()
    self:UpdataOpen()
  end
end
def.static("table", "table").OnLeaveWorld = function(p1, p2)
  local self = GroupShoppingModule.Instance()
  self.m_data = nil
  self.m_cfgRequest = nil
  self.m_groupRequest = nil
  self.m_banData = nil
  self.m_activityId = 0
  self.m_pageRequestCallback = nil
  self.m_notifyQueue = nil
  GameUtil.RemoveGlobalTimer(self.m_notifyTimer)
  self.m_notifyTimer = 0
end
def.static("table", "table").OnFeatureChange = function(p1, p2)
  local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  if p1.feature == ModuleFunSwitchInfo.TYPE_GROUP_SHOPPING then
    local self = GroupShoppingModule.Instance()
    if self.m_data and p1.open == false then
      self.m_data:FailAllSmallGroup()
      self.m_data:FailAllBigGroup()
      Event.DispatchEvent(ModuleId.GROUP_SHOPPING, gmodule.notifyId.GroupShopping.MyGroupListChange, nil)
    end
    GroupShoppingModule.Instance():UpdataOpen()
  elseif p1.feature == ModuleFunSwitchInfo.TYPE_GROUP_SHOPPING_SMALL_GROUP and p1.open == false then
    local self = GroupShoppingModule.Instance()
    if self.m_data then
      self.m_data:FailAllSmallGroup()
      Event.DispatchEvent(ModuleId.GROUP_SHOPPING, gmodule.notifyId.GroupShopping.MyGroupListChange, nil)
    end
  elseif p1.feature == ModuleFunSwitchInfo.TYPE_GROUP_SHOPPING_BIG_GROUP and p1.open == false then
    local self = GroupShoppingModule.Instance()
    if self.m_data then
      self.m_data:FailAllBigGroup()
      Event.DispatchEvent(ModuleId.GROUP_SHOPPING, gmodule.notifyId.GroupShopping.MyGroupListChange, nil)
    end
  end
end
def.static("table", "table").OnServeLvChange = function(p1, p2)
  GroupShoppingModule.Instance():UpdataOpen()
end
def.method().UpdataOpen = function(self)
  Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.MENU_TOP_FLOAT_CHANGE, nil)
end
def.method("=>", GroupShoppingData).InitData = function(self)
  if self.m_data == nil then
    self.m_data = GroupShoppingData.new()
  end
  return self.m_data
end
def.method("number", "function").AddCfgCallback = function(self, cfgId, cb)
  if self.m_cfgRequest == nil then
    self.m_cfgRequest = {}
  end
  if self.m_cfgRequest[cfgId] == nil then
    self.m_cfgRequest[cfgId] = {}
  end
  table.insert(self.m_cfgRequest[cfgId], cb)
end
def.method("number", "table").DoCfgCallback = function(self, cfgId, info)
  if self.m_cfgRequest and self.m_cfgRequest[cfgId] then
    for k, v in ipairs(self.m_cfgRequest[cfgId]) do
      v(info)
    end
    self.m_cfgRequest[cfgId] = nil
  end
end
def.method("number").RemoveCfgCallback = function(self, cfgId)
  if self.m_cfgRequest and self.m_cfgRequest[cfgId] then
    self.m_cfgRequest[cfgId] = nil
  end
end
def.method("number", "=>", "boolean").HaveCfgRequest = function(self, cfgId)
  if self.m_cfgRequest then
    return self.m_cfgRequest[cfgId] ~= nil and #self.m_cfgRequest[cfgId] > 0
  else
    return false
  end
end
def.method("number").C2SRequestCfg = function(self, cfgId)
  local req = require("netio.protocol.mzm.gsp.groupshopping.CGetGroupShoppingItemInfoReq").new(cfgId)
  gmodule.network.sendProtocol(req)
end
def.method("userdata", "function").AddGroupCallback = function(self, groupId, cb)
  if self.m_groupRequest == nil then
    self.m_groupRequest = {}
  end
  local groupIdStr = groupId:tostring()
  if self.m_groupRequest[groupIdStr] == nil then
    self.m_groupRequest[groupIdStr] = {}
  end
  table.insert(self.m_groupRequest[groupIdStr], cb)
end
def.method("userdata", "table").DoGroupCallback = function(self, groupId, info)
  local groupIdStr = groupId:tostring()
  if self.m_groupRequest and self.m_groupRequest[groupIdStr] then
    for k, v in ipairs(self.m_groupRequest[groupIdStr]) do
      v(info)
    end
    self.m_groupRequest[groupIdStr] = nil
  end
end
def.method("userdata").RemoveGroupCallback = function(self, groupId)
  local groupIdStr = groupId:tostring()
  if self.m_groupRequest and self.m_groupRequest[groupIdStr] then
    self.m_groupRequest[groupIdStr] = nil
  end
end
def.method("userdata", "=>", "boolean").HaveGroupRequest = function(self, groupId)
  if self.m_groupRequest then
    local groupIdStr = groupId:tostring()
    return self.m_groupRequest[groupIdStr] ~= nil and #self.m_groupRequest[groupIdStr] > 0
  else
    return false
  end
end
def.method("userdata").C2SRequestGroup = function(self, groupId)
  local req = require("netio.protocol.mzm.gsp.groupshopping.CGetShoppingGroupInfoReq").new(groupId)
  gmodule.network.sendProtocol(req)
end
def.method("number", "userdata").C2SPriceBuy = function(self, cfgId, myYuanbao)
  local req = require("netio.protocol.mzm.gsp.groupshopping.CGroupShoppingDirectBuyReq").new(cfgId, myYuanbao)
  gmodule.network.sendProtocol(req)
end
def.method("number", "userdata").C2SCreateGroup = function(self, cfgId, myYuanbao)
  local req = require("netio.protocol.mzm.gsp.groupshopping.CCreateShoppingGroupReq").new(cfgId, myYuanbao)
  gmodule.network.sendProtocol(req)
end
def.method("userdata", "userdata").C2SJoinGroupBuy = function(self, groupId, myYuanbao)
  local req = require("netio.protocol.mzm.gsp.groupshopping.CJoinShoppingGroupReq").new(groupId, myYuanbao)
  gmodule.network.sendProtocol(req)
end
def.method("number", "number").C2SRequestGroupPage = function(self, page, filter)
  local req = require("netio.protocol.mzm.gsp.groupshopping.CGetShoppingGroupListReq").new(filter, page)
  gmodule.network.sendProtocol(req)
end
def.method("number", "boolean").SetBan = function(self, cfgId, isBan)
  if self.m_banData == nil then
    self.m_banData = {}
  end
  self.m_banData[cfgId] = isBan
  if isBan and self.m_cfgRequest then
    self.m_cfgRequest[cfgId] = nil
  end
end
def.method("number", "=>", "boolean").IsBan = function(self, cfgId)
  if self.m_banData then
    return self.m_banData[cfgId] == true
  else
    return false
  end
end
def.method("string").SendNotify = function(self, notify)
  if self.m_notifyQueue == nil then
    self.m_notifyQueue = {}
  end
  table.insert(self.m_notifyQueue, notify)
  self:SendNotifyFromQueue()
end
def.method().SendNotifyFromQueue = function(self)
  if self.m_notifyQueue and #self.m_notifyQueue >= 1 then
    if self.m_notifyTimer == 0 then
      local notify = self.m_notifyQueue[1]
      require("Main.GroupShopping.ui.GroupShoppingMainPanel").AddNotify(notify)
      require("Main.GroupShopping.ui.GroupShoppingPlatformPanel").AddNotify(notify)
      require("Main.GroupShopping.ui.ShoppingGroupInfoPanel").AddNotify(notify)
      local ChatMsgData = require("Main.Chat.ChatMsgData")
      require("Main.Chat.ChatModule").Instance():SendNoteMsg(notify, ChatMsgData.MsgType.SYSTEM, ChatMsgData.System.SYS)
      self.m_notifyTimer = GameUtil.AddGlobalTimer(4, true, function()
        self.m_notifyTimer = 0
        if self.m_notifyQueue and #self.m_notifyQueue >= 1 then
          table.remove(self.m_notifyQueue, 1)
        end
        self:SendNotifyFromQueue()
      end)
    end
  else
    require("Main.GroupShopping.ui.GroupShoppingMainPanel").AddNotify("")
    require("Main.GroupShopping.ui.GroupShoppingPlatformPanel").AddNotify("")
    require("Main.GroupShopping.ui.ShoppingGroupInfoPanel").AddNotify("")
  end
end
def.method("=>", "string").GetNotify = function(self)
  if self.m_notifyQueue and #self.m_notifyQueue > 0 then
    return self.m_notifyQueue[1]
  else
    return ""
  end
end
def.method("=>", "boolean").IsOpen = function(self)
  local open = IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_GROUP_SHOPPING)
  if open then
    if IsCrossingServer() then
      return false
    end
    return self:IsActivityOpen(self.m_activityId)
  else
    return false
  end
end
def.method("=>", "boolean").IsRed = function(self)
  return false
end
def.method("number", "=>", "boolean").IsActivityOpen = function(self, actId)
  if actId > 0 then
    local actCfg = require("Main.activity.ActivityInterface").GetActivityCfgById(actId)
    local serverInfo = require("Main.Server.ServerModule").Instance():GetServerLevelInfo()
    if actCfg and serverInfo then
      return serverInfo.level >= actCfg.serverLevelMin
    else
      return false
    end
  else
    return false
  end
end
def.method("number", "function").RequestCfgDetailInfo = function(self, cfgId, cb)
  if not self:CheckCfgId(cfgId) then
    return
  end
  if not self:HaveCfgRequest(cfgId) then
    self:AddCfgCallback(cfgId, cb)
    self:C2SRequestCfg(cfgId)
  else
    self:AddCfgCallback(cfgId, cb)
    self:C2SRequestCfg(cfgId)
  end
end
def.method("userdata", "function").RequestGroupDetailInfo = function(self, groupId, cb)
  local open = IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_GROUP_SHOPPING_SMALL_GROUP)
  if not open then
    Toast(textRes.GroupShopping[45])
    return
  end
  if not self:HaveGroupRequest(groupId) then
    self:AddGroupCallback(groupId, cb)
    self:C2SRequestGroup(groupId)
  else
    self:AddGroupCallback(groupId, cb)
    self:C2SRequestGroup(groupId)
  end
end
def.method("number", "number", "function").RequestGroupPageWithCallBack = function(self, page, filter, cb)
  local open = IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_GROUP_SHOPPING_SMALL_GROUP)
  if not open then
    Toast(textRes.GroupShopping[45])
    return
  end
  self.m_pageRequestCallback = cb
  self:C2SRequestGroupPage(page, filter)
end
def.method("=>", "table").GetAllCfgSmallGroup = function(self)
  local cfg = GroupShoppingUtils.GetActivityShoppingCatelog(self.m_activityId)
  if cfg then
    local data = {}
    for k, v in ipairs(cfg.small) do
      if not self:IsBan(v) then
        table.insert(data, v)
      end
    end
    return data
  else
    return {}
  end
end
def.method("=>", "table").GetAllCfgBigGroup = function(self)
  local cfg = GroupShoppingUtils.GetActivityShoppingCatelog(self.m_activityId)
  if cfg then
    do
      local TimeCfgUtils = require("Main.Common.TimeCfgUtils")
      local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
      local data = {}
      for k, v in ipairs(cfg.big) do
        if not self:IsBan(v) then
          table.insert(data, v)
        end
      end
      local stateCache = {}
      local curTime = GetServerTime()
      local function GetState(cfgId)
        if stateCache[cfgId] then
          return stateCache[cfgId]
        end
        local cfg = GroupShoppingUtils.GetBigGroupCfg(cfgId)
        local timeCfg = TimeCfgUtils.GetTimeLimitCommonCfg(cfg.timeLimitCfgId)
        local startSecond = AbsoluteTimer.GetServerTimeByDate(timeCfg.startYear, timeCfg.startMonth, timeCfg.startDay, timeCfg.startHour, timeCfg.startMinute, 0)
        local endSecond = AbsoluteTimer.GetServerTimeByDate(timeCfg.endYear, timeCfg.endMonth, timeCfg.endDay, timeCfg.endHour, timeCfg.endMinute, 0)
        local state = 1
        if startSecond > curTime then
          state = 2
        elseif endSecond <= curTime then
          state = 3
        end
        stateCache[cfgId] = {state = state, startSecond = startSecond}
        return stateCache[cfgId]
      end
      table.sort(data, function(a, b)
        local aInfo = GetState(a)
        local bInfo = GetState(b)
        if aInfo.state == bInfo.state then
          if aInfo.startSecond == bInfo.startSecond then
            return a < b
          else
            return aInfo.startSecond < bInfo.startSecond
          end
        else
          return aInfo.state < bInfo.state
        end
      end)
      return data
    end
  else
    return {}
  end
end
def.method("=>", "table").GetAllCfgGroup = function(self)
  local cfg = GroupShoppingUtils.GetActivityShoppingCatelog(self.m_activityId)
  if cfg then
    local data = {}
    for k, v in ipairs(cfg.big) do
      table.insert(data, v)
    end
    for k, v in ipairs(cfg.small) do
      table.insert(data, v)
    end
    return data
  else
    return {}
  end
end
def.method("number", "=>", "table").GetMyShoppingGroups = function(self, filter)
  if self.m_data then
    return self.m_data:GetAllGroupSorted(filter)
  else
    return {}
  end
end
def.method("number", "=>", "boolean").IsBuyingItem = function(self, cfgId)
  if self.m_data then
    return self.m_data:IsSmallBuying(cfgId)
  else
    return false
  end
end
def.method("userdata", "=>", "boolean").IsBuyIngGroup = function(self, groupId)
  if self.m_data then
    local group = self.m_data:GetSmallGroup(groupId)
    if group and not group:IsExpired() then
      return true
    else
      return false
    end
  else
    return false
  end
end
def.method().ShowGroupShoppingPanel = function(self)
  require("Main.GroupShopping.ui.GroupShoppingMainPanel").ShowPanel()
end
def.method("table").ShowMyShoppingGroup = function(self, params)
  local GroupShoppingPlatformPanel = require("Main.GroupShopping.ui.GroupShoppingPlatformPanel")
  GroupShoppingPlatformPanel.ShowPanelTo(GroupShoppingPlatformPanel.NodeId.MyGroup, params)
end
def.method("table").ShowShoppingGroupPlatform = function(self, params)
  local GroupShoppingPlatformPanel = require("Main.GroupShopping.ui.GroupShoppingPlatformPanel")
  GroupShoppingPlatformPanel.ShowPanelTo(GroupShoppingPlatformPanel.NodeId.OtherGroup, params)
end
def.method("number", "number").PriceBuy = function(self, cfgId, buyCount)
  if cfgId <= 0 then
    return
  end
  if not self:CheckCfgId(cfgId) then
    return
  end
  if not self:IsActivityOpen(self.m_activityId) then
    Toast(textRes.GroupShopping[41])
    return
  end
  local cfg = GroupShoppingUtils.GetGroupCfg(cfgId)
  if cfg then
    if 0 < cfg.maxBuyNum and buyCount >= cfg.maxBuyNum then
      Toast(textRes.GroupShopping[15])
      return
    end
    do
      local ItemModule = require("Main.Item.ItemModule")
      local yuanbaoNum = ItemModule.Instance():GetAllYuanBao()
      if yuanbaoNum:lt(cfg.singlePrice) then
        GotoBuyYuanbao()
        return
      end
      if ItemModule.Instance():IsBagFull(ItemModule.BAG) then
        Toast(textRes.GroupShopping[16])
        return
      end
      local itemBase = ItemUtils.GetItemBase(cfg.itemId)
      local title = textRes.GroupShopping[19]
      local str = string.format(textRes.GroupShopping[20], cfg.singlePrice, require("Main.Chat.HtmlHelper").NameColor[itemBase.namecolor], itemBase.name or textRes.GroupShopping[21])
      require("GUI.CommonConfirmDlg").ShowConfirm(title, str, function(sel)
        if sel == 1 then
          self:C2SPriceBuy(cfgId, yuanbaoNum)
        end
      end, nil)
    end
  end
end
def.method("number", "=>", "number").IsInTime = function(self, timeLimitCfgId)
  local TimeCfgUtils = require("Main.Common.TimeCfgUtils")
  local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
  local timeCfg = TimeCfgUtils.GetTimeLimitCommonCfg(timeLimitCfgId)
  local startSecond = AbsoluteTimer.GetServerTimeByDate(timeCfg.startYear, timeCfg.startMonth, timeCfg.startDay, timeCfg.startHour, timeCfg.startMinute, 0)
  local endSecond = AbsoluteTimer.GetServerTimeByDate(timeCfg.endYear, timeCfg.endMonth, timeCfg.endDay, timeCfg.endHour, timeCfg.endMinute, 0)
  local curTime = GetServerTime()
  if endSecond < curTime then
    return 1
  elseif startSecond > curTime then
    return -1
  else
    return 0
  end
end
def.method("userdata", "number", "number", "number").JoinGroupBuy = function(self, groupId, cfgId, buyCount, remain)
  if groupId == nil then
    return
  end
  if not self:CheckCfgId(cfgId) then
    return
  end
  if not self:IsActivityOpen(self.m_activityId) then
    Toast(textRes.GroupShopping[41])
    return
  end
  local cfg = GroupShoppingUtils.GetGroupCfg(cfgId)
  if cfg then
    if cfg.timeLimitCfgId then
      local ret = self:IsInTime(cfg.timeLimitCfgId)
      if ret < 0 then
        Toast(textRes.GroupShopping[42])
        return
      elseif ret > 0 then
        Toast(textRes.GroupShopping[40])
        return
      end
    end
    if self.m_data and self.m_data:IsBuying(cfgId) then
      Toast(textRes.GroupShopping[17])
      return
    end
    if self.m_data and self.m_data:GetGroup(groupId) then
      Toast(textRes.GroupShopping[18])
      return
    end
    if 0 < cfg.maxBuyNum and buyCount >= cfg.maxBuyNum then
      Toast(textRes.GroupShopping[15])
      return
    end
    do
      local ItemModule = require("Main.Item.ItemModule")
      local yuanbaoNum = ItemModule.Instance():GetAllYuanBao()
      if yuanbaoNum:lt(cfg.groupPrice) then
        GotoBuyYuanbao()
        return
      end
      local itemBase = ItemUtils.GetItemBase(cfg.itemId)
      local title = textRes.GroupShopping[22]
      local str = string.format(textRes.GroupShopping[23], require("Main.Chat.HtmlHelper").NameColor[itemBase.namecolor], itemBase.name or textRes.GroupShopping[21], cfg.groupPrice)
      require("Main.GroupShopping.ui.GroupShoppingConfirmDlg").ShowConfirm(title, str, function(sel)
        if sel then
          self:C2SJoinGroupBuy(groupId, yuanbaoNum)
        end
      end)
    end
  end
end
def.method("number", "number", "number").CreateGroupShopping = function(self, cfgId, buyCount, remain)
  if not self:CheckCfgId(cfgId) then
    return
  end
  local cfg = GroupShoppingUtils.GetGroupCfg(cfgId)
  if not self:IsActivityOpen(self.m_activityId) then
    Toast(textRes.GroupShopping[41])
    return
  end
  if cfg then
    if self.m_data and self.m_data:IsBuying(cfgId) then
      Toast(textRes.GroupShopping[17])
      return
    end
    if remain == 0 then
      Toast(textRes.GroupShopping[14])
      return
    end
    if 0 < cfg.maxBuyNum and buyCount >= cfg.maxBuyNum then
      Toast(textRes.GroupShopping[15])
      return
    end
    do
      local ItemModule = require("Main.Item.ItemModule")
      local yuanbaoNum = ItemModule.Instance():GetAllYuanBao()
      if yuanbaoNum:lt(cfg.groupPrice) then
        GotoBuyYuanbao()
        return
      end
      local itemBase = ItemUtils.GetItemBase(cfg.itemId)
      local title = textRes.GroupShopping[24]
      local str = string.format(textRes.GroupShopping[25], require("Main.Chat.HtmlHelper").NameColor[itemBase.namecolor], itemBase.name or textRes.GroupShopping[21], cfg.groupPrice)
      require("Main.GroupShopping.ui.GroupShoppingConfirmDlg").ShowConfirm(title, str, function(sel)
        if sel then
          self:C2SCreateGroup(cfgId, yuanbaoNum)
        end
      end)
    end
  end
end
def.method("string").ShareClick = function(self, link)
  local strs = string.split(link, "_")
  if #strs == 3 then
    local cfgId = tonumber(strs[2])
    if cfgId then
      local type = GroupShoppingUtils.GetGroupType(cfgId)
      if type == 0 then
        local groupId = strs[3] ~= "0" and Int64.new(strs[3]) or nil
        if groupId then
          require("Main.GroupShopping.ui.ShoppingGroupInfoPanel").ShowShoppingGroupById(groupId)
        else
          require("Main.GroupShopping.ui.ShoppingGroupInfoPanel").ShowGroupShoppingItem(cfgId)
        end
      elseif type == 1 then
        local GroupShoppingMainPanel = require("Main.GroupShopping.ui.GroupShoppingMainPanel")
        GroupShoppingMainPanel.ShowPanelTo(GroupShoppingMainPanel.NodeId.BigNode, {cfgId = cfgId})
      end
    end
  end
end
def.method("userdata", "=>", "boolean").IsInSmallGroup = function(self, groupId)
  if self.m_data then
    return self.m_data:GetSmallGroup(groupId) ~= nil
  else
    return false
  end
end
def.method("number", "=>", "boolean").IsInBigGroup = function(self, cfgId)
  if self.m_data then
    return self.m_data:IsBigBuying(cfgId)
  else
    return false
  end
end
def.method("number", "=>", "boolean").CheckCfgId = function(self, cfgId)
  local type = GroupShoppingUtils.GetGroupType(cfgId)
  if type == 0 then
    local open = IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_GROUP_SHOPPING_SMALL_GROUP)
    if not open then
      Toast(textRes.GroupShopping[45])
      return false
    end
  elseif type == 1 then
    local open = IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_GROUP_SHOPPING_BIG_GROUP)
    if not open then
      Toast(textRes.GroupShopping[46])
      return false
    end
  end
  if self:IsBan(cfgId) then
    Toast(textRes.GroupShopping[47])
    return false
  end
  return true
end
GroupShoppingModule.Commit()
return GroupShoppingModule
