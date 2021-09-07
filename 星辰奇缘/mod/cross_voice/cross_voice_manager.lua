-- @author pwj
-- @date 2018年6月27日,星期三

CrossVoiceManager = CrossVoiceManager or BaseClass(BaseManager)

function CrossVoiceManager:__init()
    if CrossVoiceManager.Instance ~= nil then
        Log.Error("不可重复实例化")
    end
    CrossVoiceManager.Instance = self
    self.model = CrossVoiceModel.New()

    self:InitHandler()

    self.leftItemListChange = EventLib.New()
    self.rightSendEvent = EventLib.New()
end

function CrossVoiceManager:__delete()
end

function CrossVoiceManager:InitHandler()
    self:AddNetHandler(21000, self.On21000)
    self:AddNetHandler(21001, self.On21001)
    self:AddNetHandler(21002, self.On21002)
    self:AddNetHandler(21003, self.On21003)
end

--获取传声道具信息
function CrossVoiceManager:Send21000()
    print("发送21000")
    Connection.Instance:send(21000, {})
end
function CrossVoiceManager:On21000(data)
    BaseUtils.dump(data,"on21000")
    if data ~= nil and data.item_list then
        self.model.itemList = BaseUtils.copytab(data.item_list)
        self.leftItemListChange:Fire()
    end
end

--购买并使用传声道具
function CrossVoiceManager:Send21001(item_id,cost_msg,rid,platform,zone_id)
    print("发送21001")
    local tt =  {item_id = item_id, cost_msg = cost_msg, rid = rid, platform = platform, zone_id = zone_id}
    BaseUtils.dump(tt)
    --{item_id = item_id, cost_msg = cost_msg, target_id = target_id}
    --{item_id = item_id, cost_msg = cost_msg, target_id = {rid = rid, platform = platform, zone_id = zone_id}}
    Connection.Instance:send(21001, {item_id = item_id, cost_msg = cost_msg, rid = rid, platform = platform, zone_id = zone_id})
end
function CrossVoiceManager:On21001(data)
    BaseUtils.dump(data,"on21001")
    if data ~= nil and data.result == 1 then
        self.rightSendEvent:Fire()
    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--使用传声道具
function CrossVoiceManager:Send21002(item_id,cost_msg,rid,platform,zone_id)
    print("发送21002")
    Connection.Instance:send(21002, {item_id = item_id, cost_msg = cost_msg, rid = rid, platform = platform, zone_id = zone_id})
end
function CrossVoiceManager:On21002(data)
    BaseUtils.dump(data,"on21002")
    if data ~= nil and data.result == 1 then
        self.rightSendEvent:Fire()
    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end


--请求默认发送内容
function CrossVoiceManager:Send21003()
    print("发送21003")
    Connection.Instance:send(21003,{})
end
function CrossVoiceManager:On21003(data)
    BaseUtils.dump(data,"on21003")
    if data ~= nil and data.context_list ~= nil then
        self.model.System_MsgList = BaseUtils.copytab(data.context_list)
    end
end

