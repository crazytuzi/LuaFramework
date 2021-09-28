require("game/timelimitbiggift/time_limit_big_gift_data")
require("game/timelimitbiggift/time_limit_big_gift_view")

TimeLimitBigGiftCtrl = TimeLimitBigGiftCtrl or BaseClass(BaseController)
function TimeLimitBigGiftCtrl:__init()
	if TimeLimitBigGiftCtrl.Instance then
		print_error("[TimeLimitBigGiftCtrl] Attemp to create a singleton twice !")
	end
	TimeLimitBigGiftCtrl.Instance = self

	self.data = TimeLimitBigGiftData.New()
	self.view = TimeLimitBigGiftView.New(ViewName.TimeLimitBigGiftView)

	self:RegisterAllProtocols()

	ActivityData.Instance:NotifyActChangeCallback(BindTool.Bind(self.ActivityChange, self))

	self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind1(self.MainuiOpenCreate, self))
end

function TimeLimitBigGiftCtrl:__delete()
	TimeLimitBigGiftCtrl.Instance = nil

	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end
end


function TimeLimitBigGiftCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRATimeLimitLuxuryGiftBagInfo , "OnSCRATimeLimitLuxuryGiftBagInfo")
end

function TimeLimitBigGiftCtrl:OnSCRATimeLimitLuxuryGiftBagInfo(protocol)
	self.data:SetTimeLimitGiftInfo(protocol)
	if self.view and self.view:IsOpen() then
		self.view:Flush()
	end

	if 0 == protocol.is_already_buy then
		local act_info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TIME_LIMIT_BIG_GIFT)
		if act_info and act_info.status ~= ACTIVITY_STATUS.OPEN then
			ActivityData.Instance:SetActivityStatus(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TIME_LIMIT_BIG_GIFT,ACTIVITY_STATUS.OPEN,
				act_info.next_time,act_info.start_time,act_info.end_time,act_info.open_type)
		end
	elseif protocol.is_already_buy == 1 then
		local act_info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TIME_LIMIT_BIG_GIFT)
		if act_info then
			ActivityData.Instance:SetActivityStatus(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TIME_LIMIT_BIG_GIFT,ACTIVITY_STATUS.CLOSE,
				act_info.next_time,act_info.start_time,act_info.end_time,act_info.open_type)
		end
	end

	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TIME_LIMIT_BIG_GIFT) then
	local activity_type = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TIME_LIMIT_BIG_GIFT
	local time_tab = ActivityData.Instance:GetActivityResidueTime(activity_type)
		if TimeCtrl.Instance:GetServerTime() > protocol.begin_timestamp + self.data:GetLimitGiftCfg().limit_time then
			local act_info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TIME_LIMIT_BIG_GIFT)
			act_info.status = ACTIVITY_STATUS.CLOSE
		end
	end

	ViewManager.Instance:FlushView(ViewName.ActivityHall)
end

function TimeLimitBigGiftCtrl:SendBuyOrInfo(seq)
	local send_type = seq and 1 or 0
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TIME_LIMIT_BIG_GIFT,
				send_type, seq)
end

function TimeLimitBigGiftCtrl:ActivityChange(activity_type, status, next_time, open_type)
	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TIME_LIMIT_BIG_GIFT then
		-- 活动开启之后才请求
		if status == ACTIVITY_STATUS.OPEN then
			self:SendBuyOrInfo()
		elseif status == ACTIVITY_STATUS.CLOSE then
			ViewManager.Instance:FlushView(ViewName.ActivityHall)
		end
	end
end


-- 主界面创建
function TimeLimitBigGiftCtrl:MainuiOpenCreate()
	local HoldTime = 5
	local function count_down()
		local is_act_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TIME_LIMIT_BIG_GIFT)

		if is_act_open then
			local alpha = self.data:GetTimeLimitGiftInfo()
			--获取表的信息
			local beta  = self.data:GetLimitGiftCfg()
			local begin_timestamp = alpha.begin_timestamp
			local server_time = TimeCtrl.Instance:GetServerTime()
			local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
			local player_level = main_role_vo.level

			if player_level >= 130 then
				local endTime = begin_timestamp + beta.limit_time
				local rest_time = endTime - server_time				

				if rest_time > 0 and alpha.is_already_buy <= 0 then
					ViewManager.Instance:Open(ViewName.TimeLimitBigGiftView)
				end
			end
		end
		--获取协议信息
	end
	count_down()
end





