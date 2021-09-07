RegressionModel = RegressionModel or BaseClass(BaseModel)

function RegressionModel:__init()
    self.window = nil
    self.invitationFriendReturnWindow = nil
    self.inputRecruitidWindow = nil
    self.regressionLoginChestboxView = nil

    self.id = 0
    self.friendTimes = 0
	self.friendList = {}
	self.status = 0
	self.login_status = 0
	self.time_return = 0
	self.login_time_return = 0
	self.berecruit_rewards = {}
	self.logins = {}
	self.loginsTime = {}
	self.flag = 0
	self.recruit_rewards = {}
	self.role_name_bind = ""
	self.role_id_bind = 0
	self.platform_bind = ""
	self.zone_id_bind = 0
	self.activite_bind = nil
	self.time_return_bind = 0
	self.luck_draw_id = 0
	self.limits = {}
	self.role_name_recall = ""
	self.role_id_recall = 0
	self.platform_recall = ""
	self.zone_id_recall = 0
	self.activite_recall = nil
	self.time_return_recall = 0

	self.rainbow_notice_index = 1
    self.rainbow_notice_list = {}

    self.buffs = {}
end

function RegressionModel:Clear()
    self.id = 0
    self.friendTimes = 0
	self.friendList = {}
	self.status = 0
	self.login_status = 0
	self.time_return = 0
	self.login_time_return = 0
	self.berecruit_rewards = {}
	self.logins = {}
	self.loginsTime = {}
	self.flag = 0
	self.recruit_rewards = {}
	self.role_name_bind = ""
	self.role_id_bind = 0
	self.platform_bind = ""
	self.zone_id_bind = 0
	self.activite_bind = nil
	self.time_return_bind = 0
	self.luck_draw_id = 0
	self.limits = {}
	self.role_name_recall = ""
	self.role_id_recall = 0
	self.platform_recall = ""
	self.zone_id_recall = 0
	self.activite_recall = nil
	self.time_return_recall = 0

	self.rainbow_notice_index = 1
    self.rainbow_notice_list = {}

    self.buffs = {}
end

function RegressionModel:__delete()
    if self.window ~= nil then
        WindowManager.Instance:CloseWindow(self.window)
    end
end

function RegressionModel:OpenRegressionWindow(args)
    if self.window == nil then
        self.window = RegressionWindow.New(self)
    end
    self.window:Open(args)
end

function RegressionModel:CloseRegressionWindow()
    if self.window ~= nil then
        WindowManager.Instance:CloseWindow(self.window)
    end
end

function RegressionModel:OpenInvitationFriendReturnWindow(args)
    if self.invitationFriendReturnWindow == nil then
        self.invitationFriendReturnWindow = InvitationFriendReturnWindow.New(self)
    end
    self.invitationFriendReturnWindow:Show(args)
end

function RegressionModel:CloseInvitationFriendReturnWindow()
    if self.invitationFriendReturnWindow ~= nil then
        self.invitationFriendReturnWindow:DeleteMe()
        self.invitationFriendReturnWindow = nil
    end
end

function RegressionModel:OpenInputRecruitidWindow(args)
    if self.inputRecruitidWindow == nil then
        self.inputRecruitidWindow = InputRecruitidWindow.New(self)
    end
    self.inputRecruitidWindow:Show(args)
end

function RegressionModel:CloseInputRecruitidWindow()
    if self.inputRecruitidWindow ~= nil then
        self.inputRecruitidWindow:DeleteMe()
        self.inputRecruitidWindow = nil
    end
end

function RegressionModel:OpenPracSkillChestbox()
    if self.regressionLoginChestboxView == nil then
        self.regressionLoginChestboxView = RegressionLoginChestboxView.New(self)
        self.regressionLoginChestboxView:Open()
    end
end

function RegressionModel:ClosePracSkillChestbox()
    if self.regressionLoginChestboxView ~= nil then
        self.regressionLoginChestboxView:DeleteMe()
        self.regressionLoginChestboxView = nil
    end
end

function RegressionModel:OpenGiftPreview(args)
	if self.giftPreview == nil then
	    self.giftPreview = GiftPreview.New(self.window.gameObject)
	end
	self.giftPreview:Show(args)
end

function RegressionModel:CloseGiftPreview()
	if self.giftPreview ~= nil then
        self.giftPreview:DeleteMe()
        self.giftPreview = nil
    end
end

function RegressionModel:CheckRedPointLogin()
	for key, value in pairs(self.logins) do
		if value ~= nil and value == 1 then
			return true
		end
	end
	return false
end

function RegressionModel:CheckRedPointBerecruit()
	for i=1, #DataFriend.data_get_recalled_reward do
		local data = DataFriend.data_get_recalled_reward[i]
		if not self.berecruit_rewards[data.id] and self.activite_recall ~= nil and self.activite_recall >= data.activity then
			return true
		end
	end
	return false
end

function RegressionModel:CheckRedPointRecruit()
	for i=1, #DataFriend.data_get_recall_reward do
		local data = DataFriend.data_get_recall_reward[i]
		if not self.recruit_rewards[data.id] and self.activite_bind ~= nil and self.activite_bind >= data.activity then
			return true
		end
	end
	return false
end

-- 获取抽奖传闻序号
function RegressionModel:GetRollNoticeIndex()
    self.rainbow_notice_index = self.rainbow_notice_index + 1
    if self.rainbow_notice_index >= #self.rainbow_notice_list then
        self.rainbow_notice_index = 1
    end
    return self.rainbow_notice_index
end