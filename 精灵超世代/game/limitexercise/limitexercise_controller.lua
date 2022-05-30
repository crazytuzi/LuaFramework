--******** 文件说明 ********
-- @Author:      hyxing 
-- @description: 限时试炼之境界面控制模块
-- @DateTime:    2019-05-29 19:02:46
-- *******************************
LimitExerciseController = LimitExerciseController or BaseClass(BaseController)

function LimitExerciseController:config()
    self.model = LimitExerciseModel.New(self)
    self.dispather = GlobalEvent:getInstance()
end

function LimitExerciseController:getModel()
    return self.model
end

function LimitExerciseController:registerEvents()

end

function LimitExerciseController:registerProtocals()
    self:RegisterProtocal(25410, "handle25410")
    self:RegisterProtocal(25411, "handle25411")
    self:RegisterProtocal(25412, "handle25412")
    self:RegisterProtocal(25413, "handle25413")
    self:RegisterProtocal(25414, "handle25414")
end
--活动boss信息
function LimitExerciseController:send25410()
    self:SendProtocal(25410, {})
end
function LimitExerciseController:handle25410(data)
	self.model:setLimitExerciseData(data)
	GlobalEvent:getInstance():Fire(LimitExerciseEvent.LimitExercise_Message_Event,data)
end
--购买挑战次数
function LimitExerciseController:send25411()
    self:SendProtocal(25411, {})
end
function LimitExerciseController:handle25411(data)
    message(data.msg)
    if data.code == 1 then
        self.model:setChangeCount(data.count,data.buy_count)
        if self.touch_buy_change and data.count == 1 then
            self:send25413()
        end
        self.touch_buy_change = nil
        GlobalEvent:getInstance():Fire(LimitExerciseEvent.LimitExercise_BuyCount_Event,data)
    end
end

--当挑战次数为0的时候，可以根据购买次数是否为0来判断出战
function LimitExerciseController:checkJoinFight()
    local const_data = Config.HolidayBossNewData.data_const
    if not const_data then return end

    local max_count = const_data.fight_buy_max_count.val
    local cur_count = self.model:getDayBuyCount()
    local remain_count = self.model:getReaminCount()
    -- print("max_count,cur_count,remain_count",max_count,cur_count,remain_count)
    if cur_count >= max_count and remain_count == 0 then
        message(TI18N("今日次数已用完~~"))
    else
        if remain_count <= 0 then
            local iconsrc = PathTool.getItemRes(Config.ItemData.data_get_data(3).icon)
            local str = string.format(TI18N("是否花费 <img src='%s' scale=0.3 />%s购买一次挑战次数？"), iconsrc, const_data.action_num_espensive.val)
            local call_back = function()
                self.touch_buy_change = true
                self:send25411()
            end
            CommonAlert.show(str, TI18N("确定"), call_back, TI18N("取消"), nil, CommonAlert.type.rich)
        else
            self:send25413()
        end
    end
end

-- 领取奖励
function LimitExerciseController:send25412()
	self:SendProtocal(25412, {})
end
function LimitExerciseController:handle25412(data)
	message(data.msg)
	GlobalEvent:getInstance():Fire(LimitExerciseEvent.LimitExercise_GetBox_Event,data)
end
-- 挑战活动boss
function LimitExerciseController:send25413()
	self:SendProtocal(25413, {})
end
function LimitExerciseController:handle25413(data)
	message(data.msg)
    if data.code == 1 then
        HeroController:getInstance():openFormGoFightPanel(false)
    end
end
--当前伙伴已使用次数
function LimitExerciseController:send25414()
    self:SendProtocal(25414, {})
end
function LimitExerciseController:handle25414(data)
	self.model:setHeroUseId(data.p_list)
end

--打开挑战界面
function LimitExerciseController:openLimitExerciseChangeView(status)
    if status == true then
        if not self.limit_exercise_view then
            self.limit_exercise_view = LimitExerciseChangeWindow.New()
        end
        self.limit_exercise_view:open()
    else
        if self.limit_exercise_view then 
            self.limit_exercise_view:close()
            self.limit_exercise_view = nil
        end
    end
end

--打开查看奖励界面
function LimitExerciseController:openLimitExerciseRewardView(status)
    if status == true then
        if not self.open_reward_view then
            self.open_reward_view = LimitExerciseRewardWindow.New()
        end
        self.open_reward_view:open()
    else
        if self.open_reward_view then 
            self.open_reward_view:close()
            self.open_reward_view = nil
        end
    end
end

function LimitExerciseController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end