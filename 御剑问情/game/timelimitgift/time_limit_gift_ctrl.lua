require("game/timelimitgift/time_limit_gift_view")
require("game/timelimitgift/time_limit_gift_data")

TimeLimitGiftCtrl = TimeLimitGiftCtrl or BaseClass(BaseController)
function TimeLimitGiftCtrl:__init()
	if TimeLimitGiftCtrl.Instance then
		print_error("[TimeLimitGiftCtrl] Attemp to create a singleton twice !")
	end
	TimeLimitGiftCtrl.Instance = self

	self.three_piece_data = TimeLimitGiftData.New()
	self.three_piece_view = TimeLimitGiftView.New(ViewName.TimeLimitGiftView)

	self:RegisterAllProtocols()


	ActivityData.Instance:NotifyActChangeCallback(BindTool.Bind(self.ActivityChange, self))
	--登陆时候在主界面创建
	self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind1(self.MainuiOpenCreate, self))
end

function TimeLimitGiftCtrl:__delete()
	TimeLimitGiftCtrl.Instance = nil

	if self.three_piece_view then
		self.three_piece_view:DeleteMe()
		self.three_piece_view = nil
	end

	if self.three_piece_data then
		self.three_piece_data:DeleteMe()
		self.three_piece_data = nil
	end
end


function TimeLimitGiftCtrl:RegisterAllProtocols()

	--test
	--self.three_piece_data:testSetChongZhiInfo()
	self:RegisterProtocol(SCRATimeLimitGiftInfo , "OnSCRATimeLimitGiftInfo")
end

function TimeLimitGiftCtrl:OnSCRATimeLimitGiftInfo(protocol)
	self.three_piece_data:SetTimeLimitGiftInfo(protocol)
	if self.three_piece_view then
		self.three_piece_view:Flush()
	end
	
	if 0 == protocol.open_flag then
		local act_info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TIME_LIMIT_GIFT)
		if act_info then
			ActivityData.Instance:SetActivityStatus(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TIME_LIMIT_GIFT,ACTIVITY_STATUS.CLOSE,
				act_info.next_time,act_info.start_time,act_info.end_time,act_info.open_type)
		end
	elseif protocol.open_flag == 1 then
		local act_info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TIME_LIMIT_GIFT)
		if act_info and act_info.status ~= ACTIVITY_STATUS.OPEN then
			ActivityData.Instance:SetActivityStatus(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TIME_LIMIT_GIFT,ACTIVITY_STATUS.OPEN,
				act_info.next_time,act_info.start_time,act_info.end_time,act_info.open_type)
		end
	end

	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TIME_LIMIT_GIFT) then
		if TimeCtrl.Instance:GetServerTime() > protocol.begin_timestamp + TimeLimitGiftData.Instance:GetLimitGiftCfg().limit_time then
			local act_info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TIME_LIMIT_GIFT)
			act_info.status = ACTIVITY_STATUS.CLOSE
		end
	end
	ViewManager.Instance:FlushView(ViewName.ActivityHall)
end

function TimeLimitGiftCtrl:ActivityChange(activity_type, status, next_time, open_type)
	--.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TIME_LIMIT_GIFT , RA_TIMELIMIT_GIFT_OPERA_TYPE.RA_TIMELIMIT_GIFT_OPERA_TYPE_QUERY_INFO,0,0)
	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TIME_LIMIT_GIFT then
		-- 活动开启之后才请求
		if status == ACTIVITY_STATUS.OPEN then
			KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TIME_LIMIT_GIFT,
				RA_TIMELIMIT_GIFT_OPERA_TYPE.RA_TIMELIMIT_GIFT_OPERA_TYPE_QUERY_INFO,0,0)
			-- if TimeCtrl.Instance:GetServerTime() > self.three_piece_data.time_limit_gift_info.begin_timestamp + 100000 then
			-- 	local act_info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TIME_LIMIT_GIFT)
			-- 	act_info.status = ACTIVITY_STATUS.CLOSE
			-- end
		end
	end
end

-- activity_type, status, next_time, start_time, end_time, open_type

-- 主界面创建
function TimeLimitGiftCtrl:MainuiOpenCreate()

	local HoldTime = 5
	local function count_down()
		local is_act_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TIME_LIMIT_GIFT)
		--获取协议信息
		local alpha = TimeLimitGiftData.Instance:GetTimeLimitGiftInfo()
		--获取表的信息
		local beta  = TimeLimitGiftData.Instance:GetLimitGiftCfg()
		local begin_timestamp = alpha.begin_timestamp
		local server_time = TimeCtrl.Instance:GetServerTime()
		local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
		local player_level = main_role_vo.level

		if player_level >= 130 then
			local EndTime = begin_timestamp + beta.limit_time
			local rest_time = EndTime - server_time
			local begin_timestamp = alpha.begin_timestamp						
			local EndTime = begin_timestamp + 14400						
			local rest_time = EndTime - TimeCtrl.Instance:GetServerTime()			
			if is_act_open  then
				if rest_time > 0 then
					ViewManager.Instance:Open(ViewName.TimeLimitGiftView)
				end
			end
		end
	end
	count_down()
end