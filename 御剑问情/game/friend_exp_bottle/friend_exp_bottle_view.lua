FriendExpBottleView = FriendExpBottleView or BaseClass(BaseView)


-- 界面逻辑说明：点击后发送请求协议，随后收到协议数据，随后刷新界面，只要界面没有关闭，每三十秒发送一次请求协议
-- 点击逻辑说明: 点击领取,只要满足条件,发送协议,随后收到协议数据，刷新界面;点击征集好友，发送协议，随后关闭该点击按钮，时间满足后，打开该按钮

function FriendExpBottleView:__init()
    self.ui_config = {"uis/views/friendexpbottle_prefab", "FriendExpBottleView"}
    self.play_audio = true
    self.show_flag = true
end

function FriendExpBottleView:__delete()
    if self.flush_timer then
        GlobalTimerQuest:CancelQuest(self.flush_timer)
        self.flush_timer = nil
    end
    if self.flag_timer then
        GlobalTimerQuest:CancelQuest(self.flag_timer)
        self.flag_timer = nil
    end
    if self.delay_timer then
        GlobalTimerQuest:CancelQuest(self.delay_timer)
        self.delay_timer = nil
    end
end

function FriendExpBottleView:LoadCallBack()
    self.get_exp_button = self:FindObj("GetExpButton")
    self.need_friend_button = self:FindObj("NeedFriendButton")

    self.friend_limit_value = self:FindVariable("FriendLimit")
    self.show_get_btn = self:FindVariable("ShowGetExp")
    self.is_open_view = self:FindVariable("IsOpenView")
    self.show_need_friend = self:FindVariable("ShowNeedFriend")
    self.each_add_value = self:FindVariable("EachAdd")
    self.progress = self:FindVariable("Progress")
    self.remind_hour_time_value = self:FindVariable("RemindHourTime")
    self.remind_min_time_value = self:FindVariable("RemindMinTime")
    self.total_efficiency_value = self:FindVariable("TotalEfficiency")
    self.base_efficiency_value = self:FindVariable("BaseEfficiency")
    self.add_efficiency_value = self:FindVariable("AddEfficiency")
    self.cur_exp_value = self:FindVariable("CurExp")
    self.total_exp_value = self:FindVariable("TotalExp")
    self.least_time = self:FindVariable("LeastTime")
    self.friend_num_value = self:FindVariable("FriendNum")
    self.show_time = self:FindVariable("ShowTime")
	self.is_gray = self:FindVariable("IsGray")

    self:ListenEvent("Closen", BindTool.Bind(self.Closen, self))
    self:ListenEvent("OnClickGetExp", BindTool.Bind(self.OnClickGetExp, self))
    self:ListenEvent("OnClickNeedFriend", BindTool.Bind(self.OnClickNeedFriend, self))

    -- other中包括经验总量，好友加成(不会改变的值)
    -- self.total_exp = FriendExpBottleData.Instance:GetToTalExp()
    self.friend_add = FriendExpBottleData.Instance:GetFriendAdd()
    self.bottle_cfg = FriendExpBottleData.Instance.exp_bottle_limit
    self.efficiency = FriendExpBottleData.Instance:GetPerMinuteExp()
end

function FriendExpBottleView:ReleaseCallBack()
    if self.flush_timer then
        GlobalTimerQuest:CancelQuest(self.flush_timer)
        self.flush_timer = nil
    end
    if self.flag_timer then
        GlobalTimerQuest:CancelQuest(self.flag_timer)
        self.flag_timer = nil
    end
    if self.delay_timer then
        GlobalTimerQuest:CancelQuest(self.delay_timer)
        self.delay_timer = nil
    end
    self.friend_limit_value = nil
    self.show_get_btn = nil
    self.is_open_view = nil
    self.show_need_friend = nil
    self.each_add_value = nil
    self.progress = nil
    self.get_exp_button = nil
    self.need_friend_button = nil
    self.remind_hour_time_value = nil
    self.remind_min_time_value = nil
    self.total_efficiency_value = nil
    self.base_efficiency_value = nil
    self.add_efficiency_value = nil
    self.cur_exp_value = nil
    self.total_exp_value = nil
    self.least_time = nil
    self.friend_num_value = nil
    self.show_time = nil
    self.is_gray = nil

    self.total_exp = nil
    self.friend_add = nil
    self.bottle_cfg = nil
    self.efficiency = nil
    self.is_gray = nil
end

-- 打开界面刷新
function FriendExpBottleView:OpenCallBack()
    self.friend_num = FriendExpBottleData.Instance:GetFriendNum()
    --代表气泡的初始状态
    self.open_qipao = false
    if not FriendExpBottleData.Instance:CanGetExp(self.friend_num) then
        self.is_open_view:SetValue(true)
        self.open_qipao = true
    end
    self.show_flag = true
    if self.flush_timer then
        GlobalTimerQuest:CancelQuest(self.flush_timer)
        self.flush_timer = nil
    end
    self.flush_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 30)

    FriendExpBottleCtrl.Instance:SendOper(FRIENDEXPBOTTLE_OPER.RequireFlush)
end

function FriendExpBottleView:FlushNextTime()
    FriendExpBottleCtrl.Instance:SendOper(FRIENDEXPBOTTLE_OPER.RequireFlush)
end

function FriendExpBottleView:Closen()
    self:Close()
end

function FriendExpBottleView:CloseCallBack()
    if self.flush_timer then
        GlobalTimerQuest:CancelQuest(self.flush_timer)
        self.flush_timer = nil
    end
    if self.flag_timer then
        GlobalTimerQuest:CancelQuest(self.flag_timer)
        self.flag_timer = nil
    end
    if self.delay_timer then
        GlobalTimerQuest:CancelQuest(self.delay_timer)
        self.delay_timer = nil
    end

end

-- 初始化会变化的数据
function FriendExpBottleView:InitData()
    self.cur_exp = FriendExpBottleData.Instance:GetCurExp()
    self.friend_num = FriendExpBottleData.Instance:GetFriendNum()
    self.total_exp = FriendExpBottleData.Instance:GetToTalExp()
end

function FriendExpBottleView:OnFlush()
    self:InitData()
    if FriendExpBottleData.Instance:IsMaxTimes() then
        self:Close()
        return
    end
    self.remind_time = self:CalculateTime()
    local time_cfg = TimeUtil.Format2TableDHM(self.remind_time * 60)
    self.hour = time_cfg.hour
    self.min = time_cfg.min
    self:ShowView()
    self:SetDataView()
end

-- 计算剩余时间
function FriendExpBottleView:CalculateTime()
    local efficiency = self.efficiency + self.friend_num * self.friend_add
    return math.floor((self.total_exp - self.cur_exp) / efficiency)
end



-- 界面数据显示
function FriendExpBottleView:SetDataView()
    self.each_add_value:SetValue(self.friend_add)
    self.total_exp_value:SetValue(CommonDataManager.ConverMoney(self.total_exp))
    self.cur_exp_value:SetValue(CommonDataManager.ConverMoney(self.total_exp))
    self.add_efficiency_value:SetValue(self.friend_num * self.friend_add)
    self.base_efficiency_value:SetValue(self.efficiency)
    self.total_efficiency_value:SetValue(self.efficiency + self.friend_num * self.friend_add)
    self.remind_min_time_value:SetValue(self.min)
    self.remind_hour_time_value:SetValue(self.hour)
    self.progress:SetValue(self.cur_exp / self.total_exp)
    self.least_time:SetValue(math.floor(FriendExpBottleData.Instance:ColdTime()))
    self.friend_num_value:SetValue(ToColorStr(self.friend_num,TEXT_COLOR.RED))
    if FriendExpBottleData.Instance:IsMaxTimes() then
        self.friend_limit_value:SetValue(Language.ExpBottle.Limit)
    else
        self.friend_limit_value:SetValue(FriendExpBottleData.Instance:GetFriendLimit())
    end
end


-- 界面的显示状态设置
function FriendExpBottleView:ShowView()
    local show_get_btn = FriendExpBottleData.Instance:BottleFull() and FriendExpBottleData.Instance:CanGetExp(self.friend_num)
    self.get_exp_button.button.interactable = show_get_btn and not FriendExpBottleData.Instance:IsMaxTimes()
	self.is_gray:SetValue(show_get_btn and not FriendExpBottleData.Instance:IsMaxTimes())
    self.show_get_btn:SetValue(show_get_btn)
    if self.open_qipao and show_get_btn then
        self.open_qipao = false
        self.is_open_view:SetValue(false)
    end
    if FriendExpBottleData.Instance:ColdTimeEnd() then
        self.cold_time_end = true
    else
        self.cold_time_end = false
        if self.delay_timer then
            GlobalTimerQuest:CancelQuest(self.delay_timer)
            self.delay_timer = nil
        end
        self.delay_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.DelayTime, self), 1)
    end
    local show_need_friend = self.show_flag and self.cold_time_end
    self.need_friend_button.button.interactable = show_need_friend
    self.show_need_friend:SetValue(not show_need_friend)
    self.show_time:SetValue(not FriendExpBottleData.Instance:BottleFull())
end

function FriendExpBottleView:OnClickNeedFriend()
    FriendExpBottleCtrl.Instance:SendOper(FRIENDEXPBOTTLE_OPER.NeedFriend)
    -- RemindManager.Instance:Fire(RemindName.ScoietyOneKeyFriend)
    -- ScoietyCtrl.Instance:ShowFriendRecView()
    self.is_open_view:SetValue(false)
    self.show_flag = false
    self.delay_time = 10
    self.least_time:SetValue(self.delay_time)
    if self.flag_timer then
        GlobalTimerQuest:CancelQuest(self.flag_timer)
        self.flag_timer = nil
    end
    self.flag_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.WaitNextTime, self), 1)

    self:ShowView()
end

function FriendExpBottleView:WaitNextTime()
    self.delay_time = self.delay_time - 1
    self.least_time:SetValue(self.delay_time)
    if self.delay_time == 0 then
        self:TimeEndCallBack()
        self.delay_time = 10
        if self.flag_timer then
            GlobalTimerQuest:CancelQuest(self.flag_timer)
            self.flag_timer = nil
        end
    end
end

function FriendExpBottleView:DelayTime()
    if FriendExpBottleData.Instance:ColdTime() == 0 then
        if self.delay_timer then
            GlobalTimerQuest:CancelQuest(self.delay_time)
            self.delay_timer = nil
            self:ShowView()
        end
    else
        if self.least_time then
            self.least_time:SetValue(math.floor(FriendExpBottleData.Instance:ColdTime()))
        end
    end
end

function FriendExpBottleView:TimeEndCallBack()
    self.show_flag = true
    self:ShowView()
end

function FriendExpBottleView:OnClickGetExp()
    FriendExpBottleCtrl.Instance:SendOper(FRIENDEXPBOTTLE_OPER.GetExp)
end