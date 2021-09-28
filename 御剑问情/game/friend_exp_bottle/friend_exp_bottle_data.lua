FriendExpBottleData = FriendExpBottleData or BaseClass()
function FriendExpBottleData:__init()
    if FriendExpBottleData.Instance ~= nil then
        ErrorLog("[FriendExpBottleData] Attemp to create a singleton twice !")
    end
    FriendExpBottleData.Instance = self

    -- 静态数据初始化
    self.exp_bottle_limit = self:GetBottleData()
    self.other = self:GetBottleOther()
    self.max_get_times = self.exp_bottle_limit[#self.exp_bottle_limit].get_exp_times
    self.friend_callback = GlobalEventSystem:Bind(OtherEventType.FRIEND_INFO_CHANGE, BindTool.Bind(self.FriendListChange, self))
    RemindManager.Instance:Register(RemindName.FriendExpBottleView, BindTool.Bind(self.GetExpBottleRemind, self))
    self.get_exp_count = 0
    self.auto_add_friend_count = 0
end

function FriendExpBottleData:__delete()
    FriendExpBottleData.Instance = nil
    self.exp_bottle_limi = nil
    self.other = nil
    RemindManager.Instance:UnRegister(RemindName.FriendExpBottleView)

    if self.remind_text_timer then
        GlobalTimerQuest:CancelQuest(self.remind_text_timer)
        self.remind_text_timer = nil
    end
    self:UnBindFriend()
end
---------------------获取数据----------------------
-- 获取经验瓶限制配置表
function FriendExpBottleData:GetBottleData()
    return ConfigManager.Instance:GetAutoConfig("friend_expbottle_config_auto").exp_bottle_limit
end

-- 获取取其他配置(包括经验总量，好友加成,经验效率)
-- other中包括经验总量，好友加成
function FriendExpBottleData:GetBottleOther()
    return ConfigManager.Instance:GetAutoConfig("friend_expbottle_config_auto").other[1]
end

-- 获取每分钟的经验效率 
function FriendExpBottleData:GetPerMinuteExp()
    return self.other.per_minute_exp
end

function FriendExpBottleData:GetLevelLimit()
    if self:IsMaxTimes() then return 0 end
    local index = self.get_exp_count or 0
    return self:GetBottleData()[index + 1].fetch_level_limit
end

-- 获取总经验
function FriendExpBottleData:GetToTalExp()
    if self:IsMaxTimes() then return 0 end
    local index = self.get_exp_count or 0
    return self:GetBottleData()[index + 1].exp_limit
end

-- 获取好友加成
function FriendExpBottleData:GetFriendAdd()
    return self.other.friend_extra_add_exp
end

--获取当前经验
function FriendExpBottleData:GetCurExp()
    return self.cur_exp or 0
end

--获取次数对应的好友限制
function FriendExpBottleData:GetFriendLimitByCount(count)
    if self:IsMaxTimes() then return 0 end
    for k,v in pairs(self.exp_bottle_limit) do
        if v.get_exp_times == count then
            return v.min_friend_max_count
        end
    end
    return 0
end

-- 获取当前的好友限制
function FriendExpBottleData:GetFriendLimit()
    if self:IsMaxTimes() then return 0 end
    local index = self.get_exp_count or 0
    return self:GetFriendLimitByCount(index + 1)
end

-- 获取征集好友的冷却时间
function FriendExpBottleData:ColdTime()
    if self.next_time - TimeCtrl.Instance:GetServerTime()  > 0 then
        return self.next_time - TimeCtrl.Instance:GetServerTime()
    else
        return 0
    end
end

function FriendExpBottleData:GetFriendNum()
    local friend_list = ScoietyData.Instance:GetFriendInfo()
    local num = #friend_list + self.auto_add_friend_count
    return num
end

------------------ 对数据进行判断-------------------
-- 经验瓶是否满了
function FriendExpBottleData:BottleFull()
    if self:GetCurExp() < self:GetToTalExp() then
        return false
    else
        return true
    end
end

-- 时间条件是否满足
function FriendExpBottleData:ColdTimeEnd()
    return TimeCtrl.Instance:GetServerTime() > self.next_time 
end

-- 是否可以亮红点
function FriendExpBottleData:ShowMainUIExpBottleRedPoint()

    if not OpenFunData.Instance:CheckIsHide("exp_bottle") then
        return false
    end
    if not self:CanGetExp(self:GetFriendNum()) then
        if self.remind_text_timer then
            GlobalTimerQuest:CancelQuest(self.remind_text_timer)
            self.remind_text_timer = nil
        end
        if self.remind_text_timer == nil then
            self.remind_text_timer = GlobalTimerQuest:AddRunQuest(function ()
            MainUICtrl.Instance:ShowEXPBottleText(self:GetFriendLimit() - self:GetFriendNum())
            end,30)
        end
    end
    if self:BottleFull() and self:CanGetExp(self:GetFriendNum()) then
        MainUICtrl.Instance:ShakeExpBottle(true)
        GlobalTimerQuest:CancelQuest(self.remind_text_timer)
        self.remind_text_timer = nil
        MainUICtrl.Instance:CloseExpBottleText()
        return true
    end
    MainUICtrl.Instance:ShakeExpBottle(false)
    return false
end
-- 是否可以领取满经验瓶
function FriendExpBottleData:CanGetExp(friend_num)
    for k,v in pairs(self.exp_bottle_limit) do
        if v.min_friend_max_count<= friend_num and friend_num <= v.max_friend_max_count then
            if self.get_exp_count < v.get_exp_times then
                return true
            end
        end
    end
    return false
end

--是否已经领取到最大次数
function FriendExpBottleData:IsMaxTimes()
    return self.max_get_times == self.get_exp_count
end

--等级是否满足要求
function FriendExpBottleData:IsLevelSatisfy()
    local vo = GameVoManager.Instance:GetMainRoleVo()
    return vo.level >= self:GetLevelLimit()
end
----------------- ------处理数据--------------------------
-- 刷新当前经验 及 征集好友的下次可用时间
function FriendExpBottleData:FlushCurExp(protocol)
    self.cur_exp = protocol.exp or 0
    self.get_exp_count = protocol.get_exp_count or 0
    self.next_time = protocol.next_broadcast_time or 0
    self.auto_add_friend_count = protocol.auto_add_friend_count
    if self:IsMaxTimes() or not self:IsLevelSatisfy() then
        MainUICtrl.Instance.view:SetShowExpBottle(false)
    end
end

function FriendExpBottleData:GetAutoAddFriendCount()
    return self.auto_add_friend_count
end

--将红点判断转化为数字
function FriendExpBottleData:GetExpBottleRemind()
    return self:ShowMainUIExpBottleRedPoint() and 1 or 0
end

function FriendExpBottleData:FriendListChange()
    RemindManager.Instance:Fire(RemindName.FriendExpBottleView)
    ViewManager.Instance:FlushView(ViewName.FriendExpBottleView)
end

function FriendExpBottleData:UnBindFriend()
    if self.friend_callback then
        GlobalEventSystem:UnBind(self.friend_callback)
        self.friend_callback = nil
    end
end