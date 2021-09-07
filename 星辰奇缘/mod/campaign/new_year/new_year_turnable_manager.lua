-- @author author
-- @date 2018年1月20日,星期六

NewYearTurnableManager = NewYearTurnableManager or BaseClass(BaseManager)

function NewYearTurnableManager:__init()
    if NewYearTurnableManager.Instance ~= nil then
        Log.Error("不可重复实例化")
    end
    NewYearTurnableManager.Instance = self

    self:InitHandler()
    self.model = NewYearTurnableModel.New()

    self.OnDrawSuccess = EventLib.New()
    self.OnDrawFailure = EventLib.New()

    self.OnGoldUpdate = EventLib.New()
end

function NewYearTurnableManager:__delete()
    self.OnDrawSuccess:DeleteMe()
    self.OnDrawSuccess = nil

    self.OnDrawFailure:DeleteMe()
    self.OnDrawFailure = nil

    self.OnGoldUpdate:DeleteMe()
    self.OnGoldUpdate = nil

    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
end

function NewYearTurnableManager:RequestInitData()
    --登录请求数据
    self:send20418()
    self:send20419()   --玩家抽奖信息
end

function NewYearTurnableManager:InitHandler()
    self:AddNetHandler(20418,self.on20418)   --全服转盘活动配置信息
    self:AddNetHandler(20419,self.on20419)   --全服转盘抽奖玩家信息
    self:AddNetHandler(20420,self.on20420)   --全服转盘抽奖
end

function NewYearTurnableManager:send20418(data)
    --print("--------20418协议数据---------")
    Connection.Instance:send(20418, {})
end

function NewYearTurnableManager:on20418(data)
    --print("收到20418协议数据")
    local iniData = data
    --BaseUtils.dump(iniData,"全服转盘活动配置信息:")
    self.model.rewardList = iniData.reward_list
    self.model.MaxTime =iniData.max_draw
    self.model.NoticeTips = iniData.tips_msg
    self.model.lossItemId = iniData.draw_loss[1].loss_id

    self.model:InitRewardList()
end

function NewYearTurnableManager:send20419(data)
    --print("--------20419协议数据---------")
    Connection.Instance:send(20419, {})
end

function NewYearTurnableManager:on20419(data)
    --print("收到20419协议数据")
    local PlayerData = data
    -- BaseUtils.dump(PlayerData,"抽奖玩家信息:")
    if PlayerData ~= nil then
        self.model.freeTime = PlayerData.free_times
        self.model.todayDrawTime = PlayerData.draw_times
        self.model.currentGold = PlayerData.cur_gold
        self.model.recordExt = PlayerData.record_msg
    end

    --self.OnMsgUpdate:Fire(PlayerData.record_msg)
    if self.model.mainWin ~= nil then
        -- print("更改奖池...")
        self.OnGoldUpdate:Fire(PlayerData.cur_gold)
    end



    --给个事件，去更新window的显示
end

function NewYearTurnableManager:send20420(data)
    -- print("--------20420购买协议数据---------")
    Connection.Instance:send(20420, {draw_num = data})
end

function NewYearTurnableManager:on20420(data)
    -- print("收到20420协议数据")
    -- BaseUtils.dump(data,"on20420")
    if data.result == 1 then
        local DrawData = data
        self.model.DrawRewardList = DrawData.draw_reward
        -- BaseUtils.dump(DrawData,"抽奖后返回信息:")
        self.OnDrawSuccess:Fire(DrawData.group_id)
        -- self.name = DataItem.data_get[DrawData.draw_reward[1].base_id].name
        -- self.timerId = LuaTimer.Add(3000, function()
        --     NoticeManager.Instance:FloatTipsByString(TI18N("恭喜获得"..self.name))
        --         end)

        self.timerId = LuaTimer.Add(3000, function()
            self.timerId = nil
            for i,v in ipairs(DrawData.draw_reward) do
                NoticeManager.Instance:FloatTipsByString(TI18N("恭喜获得"..DataItem.data_get[DrawData.draw_reward[i].base_id].name))
            end
        end)
    elseif data.result == 0 then
        self.OnDrawFailure:Fire(0)   --抽奖失败
    end
end
