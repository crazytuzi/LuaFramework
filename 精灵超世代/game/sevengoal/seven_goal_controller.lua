-- --------------------------------------------------------------------
-- --------------------------------------------------------------------
SevenGoalController = SevenGoalController or BaseClass(BaseController)

function SevenGoalController:config()
    self.model = SevenGoalModel.New(self)
    self.dispather = GlobalEvent:getInstance()
end

function SevenGoalController:getModel()
    return self.model
end

function SevenGoalController:registerEvents()
    --[[if self.init_role_event == nil then
        self.init_role_event = GlobalEvent:getInstance():Bind(EventId.ROLE_CREATE_SUCCESS, function()
            GlobalEvent:getInstance():UnBind(self.init_role_event)
            self.init_role_event = nil
            self:sender13604()
            self:sender13607()
        end)
    end--]]
end

function SevenGoalController:registerProtocals()
    self:RegisterProtocal(13604, "handle13604")
    self:RegisterProtocal(13605, "handle13605")
    self:RegisterProtocal(13606, "handle13606")
    self:RegisterProtocal(13607, "handle13607")
    self:RegisterProtocal(13608, "handle13608")
    self:RegisterProtocal(13609, "handle13609")
end
--任务信息
function SevenGoalController:sender13604()
    self:SendProtocal(13604, {})
end
function SevenGoalController:handle13604(data)
    self.model:setInitSevenGoalData(data)
    GlobalEvent:getInstance():Fire(SevenGoalEvent.BaseMessage,data)
end
--刷新任务列表
function SevenGoalController:handle13605(data)
    self.model:setInitDataUpdata(data.list)
    self.model:checkMainRedPoint()
    GlobalEvent:getInstance():Fire(SevenGoalEvent.Tesk_Updata,data)
end
--提交任务
function SevenGoalController:sender13606(id)
    local proto = {}
    proto.id = id
    self:SendProtocal(13606, proto)
end
function SevenGoalController:handle13606(data)
    message(data.msg)
end
--七天目标冒险界面
function SevenGoalController:openSevenGoalAdventureView(status)
    if status == true then
        if not self.sevengoal_adventure then
            self.sevengoal_adventure = SevenGoalAdventureWindow.New()
        end
        self.sevengoal_adventure:open()
    else
        if self.sevengoal_adventure then 
            self.sevengoal_adventure:close()
            self.sevengoal_adventure = nil
        end
    end
end
--只有当等级改变的时候会推送
function SevenGoalController:handle13609(data)
    GlobalEvent:getInstance():Fire(SevenGoalEvent.Updata_Lev,data)
end

--等级奖励展示
function SevenGoalController:sender13607()
    self:SendProtocal(13607, {})
end
function SevenGoalController:handle13607(data)
    self.model:setSevenGoalLevData(data.reward_list)
    GlobalEvent:getInstance():Fire(SevenGoalEvent.Reward_Lev,data)
end
--领取等级礼包
function SevenGoalController:sender13608(id)
    local proto = {}
    proto.id = id
    self:SendProtocal(13608, proto)
end
function SevenGoalController:handle13608(data)
    message(data.msg)
end
--七天目标等级奖励界面
function SevenGoalController:openSevenGoalAdventureLevRewardView(status)
    if status == true then 
        if not self.sevengoal_adventure_lev then
            self.sevengoal_adventure_lev = SevenGoalAdventureLevRewardWindow.New()
        end
        self.sevengoal_adventure_lev:open()
    else
        if self.sevengoal_adventure_lev then 
            self.sevengoal_adventure_lev:close()
            self.sevengoal_adventure_lev = nil
        end
    end
end
--七天目标任务奖励奖励界面
function SevenGoalController:openSevenGoalTotleChargeView(status)
    if status == true then 
        if not self.sevengoal_adventure_charge then
            self.sevengoal_adventure_charge = SevenGoalTotleChargeWindow.New()
        end
        self.sevengoal_adventure_charge:open()
    else
        if self.sevengoal_adventure_charge then 
            self.sevengoal_adventure_charge:close()
            self.sevengoal_adventure_charge = nil
        end
    end
end

--魔盒界面
function SevenGoalController:openSevenGoalSecretView(status)
    if status == true then 
        if not self.sevengoal_secret_view then
            self.sevengoal_secret_view = SevenGoalSecretWindow.New()
        end
        self.sevengoal_secret_view:open()
    else
        if self.sevengoal_secret_view then 
            self.sevengoal_secret_view:close()
            self.sevengoal_secret_view = nil
        end
    end
end

function SevenGoalController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end
