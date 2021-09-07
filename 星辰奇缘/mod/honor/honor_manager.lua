HonorManager = HonorManager or BaseClass(BaseManager)

function HonorManager:__init()
    if HonorManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
    end
    HonorManager.Instance = self;
    self:InitHandler()
    self.preStatus = 0   --0表示取消称号操作，1表示使用称号操作
    self.preStatusId = 0
    self.model = HonorModel.New()
    self.onUpdateReward = EventLib.New()
end

function HonorManager:__delete()
    self.model:DeleteMe()
    self.model = nil
end

function HonorManager:RequestInitData()
    self:request12700()
end

function HonorManager:InitHandler()
    self:AddNetHandler(12700,self.on12700)
    self:AddNetHandler(12701,self.on12701)
    self:AddNetHandler(12702,self.on12702)
    self:AddNetHandler(12703,self.on12703)
    self:AddNetHandler(12704,self.on12704)
    self:AddNetHandler(12705,self.on12705)
    self:AddNetHandler(12706,self.on12706)
    self:AddNetHandler(12707,self.on12707)
    self:AddNetHandler(12708,self.on12708)
    self:AddNetHandler(12709,self.on12709)
    self:AddNetHandler(12710,self.on12710)
end

--------协议监听逻辑
function HonorManager:on12700(data)
    -- BaseUtils.dump(data,"接收协议12700================================================")
    self.model.current_honor_id = data.use_id
    self.model.pre_honor_id_list = data.pre_honor_list
    self.model.current_pre_honor_id = data.use_pre_id
    self.model.mine_honor_list = {}
    self.model.rewardList = data.pre_reward_list
    for i=1,#data.honor_list do
        local h = data.honor_list[i]
        local cfg = DataHonor.data_get_honor_list[h.id]
        local data = BaseUtils.copytab(cfg)
        if data ~= nil then
            data.end_time = h.end_time
            data.has = true
            if data.type == 6 then
                data.name = string.format("%s%s%s", RoleManager.Instance.RoleData.lover_name, TI18N("的"), data.name)
            end
            table.insert(self.model.mine_honor_list, data)
        end
    end
    -- ui_backpack_info.update_socket_back()
    -- ui_backpack_character.update_honor()
    -- if (DataHonor.data_get_honor_list[self.model.current_honor_id] ~= nil and DataHonor.data_get_honor_list[self.model.current_honor_id].is_can_pre == 0) or DataHonor.data_get_honor_list[self.model.current_honor_id] ~= nil then
    --     if self.model.current_pre_honor_id ~= 0 then
    --         self:request12708(self.model.current_pre_honor_id)
    --     else
    --         EventMgr.Instance:Fire(event_name.honor_update)
    --     end
    -- else
        EventMgr.Instance:Fire(event_name.honor_update)
    -- end

end

function HonorManager:on12701(data)
    local result=data.flag
    local msg=data.msg

    if result==0 then --失败

    else--成功

    end
    NoticeManager.Instance:FloatTipsByString(msg)
end

function HonorManager:on12702(data)
    local result=data.flag
    local msg=data.msg
    if result==0 then --失败

    else--成功

    end
    NoticeManager.Instance:FloatTipsByString(msg)
end

function HonorManager:on12703(data)
    print("发送协议12703====================================================================")
    -- 服务器端说不发这个协议了，屏蔽处理

    HonorManager.Instance.model:GetNewHonor(data.id,InfoHonorEumn.Status.ForWard)

    -- if self.model.mine_honor_list == nil then
    --     return
    -- end
    -- local cfg = DataHonor.data_get_honor_list[data.id]
    -- local data = BaseUtils.copytab(cfg)
    -- data.end_time = data.end_time
    -- data.status = data.status
    -- table.insert(self.model.mine_honor_list, data)
end

function HonorManager:on12704(data)
    if self.model.mine_honor_list == nil then
        return
    end
    local temp = {}
    for i=1,#self.model.mine_honor_list do
        local h = self.model.mine_honor_list[i]
        if h.id ~= data.id then
            table.insert(temp, h)
        end
    end
    self.model.mine_honor_list = temp
    EventMgr.Instance:Fire(event_name.honor_update)
end

function HonorManager:on12705(data)
    if self.model.mine_honor_list == nil then
        self.model.mine_honor_list = {}
    end
    for i=1,#data.honor_list do
        local h = data.honor_list[i]
        local has_this_honor = false
        for j=1,#self.model.mine_honor_list do
            local data = self.model.mine_honor_list[j]
            if data.id == h.id then
                data.end_time = h.end_time
                data.has = true
                has_this_honor = true
            end
        end
        if not has_this_honor then
            local cfg = DataHonor.data_get_honor_list[h.id]
            local data = BaseUtils.copytab(cfg)
            data.end_time = h.end_time
            data.has = true
            table.insert(self.model.mine_honor_list, data)
        end
    end
    -- ui_backpack_character.update_honor()
    EventMgr.Instance:Fire(event_name.honor_update)
end

function HonorManager:on12706(data)
    self.model.current_honor_id = data.use_id
    EventMgr.Instance:Fire(event_name.honor_update)
end

----------------------------协议请求逻辑
--请求协议逻辑
--获取当前称号数据
function HonorManager:request12700()
    -- print("发送协议12700======================42342344444444444444444444444444444444")
    Connection.Instance:send(12700, {})

end

--使用称号
function HonorManager:request12701(_id)

    print("发送协议12701========================================================")
     print(debug.traceback())
    Connection.Instance:send(12701, {id = _id})
end


--取消使用称号
function HonorManager:request12702(_id)
    Connection.Instance:send(12702, {id = _id})
end


function HonorManager:request12708(_id)
    -- print("发送协议12708====================================================：" .. _id)
    Connection.Instance:send(12708, {pre_id = _id})
end


function HonorManager:on12708(data)
    -- BaseUtils.dump(data,"接收协议12708=============================================")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function HonorManager:request12707()
    -- print("发送协议12707====================================================：")
    Connection.Instance:send(12702, {})
end


function HonorManager:on12707(data)
    -- BaseUtils.dump(data,"接收协议12707=============================================")

    if data.pre_code == 1 then
        HonorManager.Instance.model:GetNewHonor(data.pre_id,InfoHonorEumn.Status.Back)
    elseif data.pre_code == 0 then
        NoticeManager.Instance:FloatTipsByString("你获得了重复的物品")

        local myData = {}

        myData.item_list = {{},{}}
        myData.item_list[1].item_id = DataHonor.data_get_pre_honor_list[data.pre_id].itemid
        myData.item_list[1].bind = 0
        myData.item_list[1].number = 1
        myData.item_list[1].type = 1


        for k,v in pairs(DataHonor.data_get_pre_honor_list) do
            if data.pre_id == v.pre_id then
                myData.item_list[2].item_id = v.items[1][1]
                myData.item_list[2].bind = v.items[1][2]
                myData.item_list[2].number = v.items[1][3]
                myData.item_list[2].type = 1
            end
        end

        myData.isChange = true
        myData.desc = string.format("获得已有前缀称号，自动转换为%s",DataItem.data_get[myData.item_list[2].item_id].name)
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.itemsavegetwindow,myData)
    end
end



function HonorManager:request12709(_id)
    -- print("发送协议12709====================================================：" .. _id)
    Connection.Instance:send(12709, {pre_id = _id})
end


function HonorManager:on12709(data)
    -- BaseUtils.dump(data,"接收协议12709=============================================")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end


function HonorManager:request12710(_id)
    -- print("发送协议12710====================================================：" .. _id)
    Connection.Instance:send(12710, {reward_id = _id})
end


function HonorManager:on12710(data)
    -- BaseUtils.dump(data,"接收协议12710=============================================")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.flag == 1 then
        self.onUpdateReward:Fire()
    end
end