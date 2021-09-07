AlchemyManager = AlchemyManager or BaseClass(BaseManager)

function AlchemyManager:__init()
    if AlchemyManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
    end
    AlchemyManager.Instance = self;
    self.has_tips_cost = false
    self.data_14503 = nil
    self.model = AlchemyModel.New()
    self:InitHandler()

    self.timer_id = 0
end

function AlchemyManager:__delete()
    self.model:DeleteMe()
    self.model = nil
end

function AlchemyManager:InitHandler()
    self:AddNetHandler(14900,self.on14900)
    self:AddNetHandler(14901,self.on14901)
    self:AddNetHandler(14902,self.on14902)
    self:AddNetHandler(14903,self.on14903)
    self:AddNetHandler(14904,self.on14904)
    self:AddNetHandler(14905,self.on14905)
    self:AddNetHandler(14906,self.on14906)
    self:AddNetHandler(14907,self.on14907)
    self:AddNetHandler(14908,self.on14908)
    self:AddNetHandler(14909,self.on14909)
    self:AddNetHandler(14910,self.on14910)
end

------------------------------------协议接收逻辑
--炼化状态
function AlchemyManager:on14900(data)
    -- print("----------------------------------------收到14900")

    local timer_state = false
    self.model.data_list = {}
    for i=1,#data.shops do
        local socket_data = data.shops[i]
        local cfg_data = BaseUtils.copytab(DataAlchemy.data_base[socket_data.id])
        cfg_data.volume = socket_data.volume
        cfg_data.products = socket_data.products
        cfg_data.is_auto = socket_data.is_auto
        table.insert(self.model.data_list, cfg_data)

        for j=1,#socket_data.products do
            local left_time = socket_data.products[j].time + cfg_data.need_time - BaseUtils.BASE_TIME
            if left_time > 0 then
                timer_state = true
            end
        end
    end

    self.model:UpdateMainInfo()

    local state = self.model:CheckRedPointState()
    AgendaManager.Instance:SetCurrLimitID_Public(state)

    ----------开始收获计时器
    if timer_state then
        self:start_timer()
    else
        self:stop_timer()
    end

end

--扩展空间
function AlchemyManager:on14901(data)
    -- print("------------------------------------收到14901")

    if data.flag == 0 then --失败

    else--成功

    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--开始生产
function AlchemyManager:on14902(data)
    -- print("-------------------------------收到14902")

    if data.flag == 0 then --失败
        self.model:InitLianhuUI()
    else--成功

    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--领取结果
function AlchemyManager:on14903(data)
    if data.flag == 0 then --失败

    else--成功

    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--熔炼物品
function AlchemyManager:on14904(data)
    if data.flag == 0 then --失败

    else--成功
        if self.open_main == nil then
            self.model:CloseLianhuUI()
        end
    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--换取炼化值
function AlchemyManager:on14905(data)
    if data.flag == 0 then --失败
        self.model:CloseLianhuUI_Normal()
    else--成功

    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--一键领取
function AlchemyManager:on14906(data)
    if data.flag == 0 then --失败

    else--成功

    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function AlchemyManager:on14907(data)
    -- print("-------------------------------收到14907")
    if data.flag == 0 then --失败

    else--成功

    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--炼化单个物品
function AlchemyManager:on14908(data)
    -- print("-------------------------------收到14908")
    if data.flag == 0 then --失败

    else--成功

    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end



--标记是否一键炼制
function AlchemyManager:on14909(data)
    -- print("-------------------------------收到14909")
    if data.flag == 0 then --失败

    else--成功

    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--溶炼返回
function AlchemyManager:on14910(data)
    -- print("-------------------------------收到14909")
    if data.flag == 0 then --失败

    else--成功

    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end


------------------------------------------------协议发送逻辑

--请求炼化状态
function AlchemyManager:request14900()
    -- print("------------------------------------发送14900")
    Connection.Instance:send(14900, {})
end

--请求扩展空间
function AlchemyManager:request14901(id)
    -- print("------------------------------------发送14901")
    Connection.Instance:send(14901, {id = id})
end

--请求开始生产
function AlchemyManager:request14902(id)
    -- print("------------------------------------发送14902")
    Connection.Instance:send(14902, {id = id})
end

--请求领取结果
function AlchemyManager:request14903(id)
    Connection.Instance:send(14903, {id = id})
end

--请求熔炼物品
function AlchemyManager:request14904(_list, _type)
    self.open_main = _type
    Connection.Instance:send(14904, {list = _list})
end

--请求换取炼化值
function AlchemyManager:request14905(_num)
    Connection.Instance:send(14905, {num = _num})
end

--一键领取
function AlchemyManager:request14906()
    Connection.Instance:send(14906, {})
end

--一键炼制
function AlchemyManager:request14907()
    print('------------------------------------发送14907')
    Connection.Instance:send(14907, {})
end

--炼化单个物品
function AlchemyManager:request14908(id)
    print('------------------------------------发送14908')
    Connection.Instance:send(14908, {id = id})
end

--标记是否一键炼制
function AlchemyManager:request14909(id, is_auto)
    print('------------------------------------发送14909')
    Connection.Instance:send(14909, {id = id, is_auto = is_auto})
end

--溶炼单个物品
function AlchemyManager:request14910(id)
    print('------------------------------------发送14910')
    Connection.Instance:send(14910, {id = id})
end

------------------------------------------倒计时结束，可收获逻辑
function AlchemyManager:start_timer()
    self:stop_timer()
    self.timer_id = LuaTimer.Add(0, 1000, function() self:timer_tick() end)
end

function AlchemyManager:stop_timer()
    if self.timer_id ~= 0 then
        LuaTimer.Delete(self.timer_id)
        self.timer_id = 0
    end
end

function AlchemyManager:timer_tick()
    for i=1,#self.model.data_list do
        local _data = self.model.data_list[i]
        for j=1,#_data.products do
            local left_time = _data.products[j].time + _data.need_time - BaseUtils.BASE_TIME
            if left_time == 0 then
                local data_base = DataItem.data_get[_data.item_id]
                local good_name = ColorHelper.color_item_name(data_base.quality , string.format("[%s]",data_base.name))
                local msg = string.format(TI18N("炼制%s已完成，可收获啦{face_1,38}"), good_name)
                local msgData = MessageParser.GetMsgData(msg)
                local chatData = ChatData.New()
                -- chatData:Update(RoleManager.Instance.RoleData)
                chatData.msgData = msgData
                chatData.channel = MsgEumn.ChatChannel.System
                chatData.showType = MsgEumn.ChatShowType.System
                chatData.prefix = MsgEumn.ChatChannel.System
                ChatManager.Instance.model:ShowMsg(chatData)
            end
        end
    end
end