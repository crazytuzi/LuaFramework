require("game/consume_reward/consume_reward_view")
require("game/consume_reward/consume_reward_data")


ConsumeRewardCtrl = ConsumeRewardCtrl or BaseClass(BaseController)
local LESS_LEVEL = 160

function ConsumeRewardCtrl:__init()
	if ConsumeRewardCtrl.Instance then
		print_error("[ConsumeRewardCtrl] Attemp to create a singleton twice !")
	end
	ConsumeRewardCtrl.Instance = self

	self.data = ConsumeRewardData.New()
	self.view = ConsumeRewardView.New(ViewName.ConsumeRewardView)

	self:RegisterAllProtocols()


	ActivityData.Instance:NotifyActChangeCallback(BindTool.Bind(self.ActivityChange, self))
	self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind1(self.MainuiOpenCreate, self))
end

function ConsumeRewardCtrl:__delete()
    if ConsumeRewardCtrl.Instance then
	    ConsumeRewardCtrl.Instance = nil
	end

	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end
end


function ConsumeRewardCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRAConsumeGoldRewardInfo , "SCRAConsumeGoldRewardInfo")
end

function ConsumeRewardCtrl:SCRAConsumeGoldRewardInfo(protocol)
	self.data:SetConsumeRewardGiftInfo(protocol)
	if self.view then
		self.view:Flush()
	end
	
	if 0 == protocol.fetch_reward_flag then
		local act_info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONSUME_GOLD_FANLI)
		if act_info and act_info.status ~= ACTIVITY_STATUS.OPEN then
			ActivityData.Instance:SetActivityStatus(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONSUME_GOLD_FANLI,ACTIVITY_STATUS.OPEN,
				act_info.next_time,act_info.start_time,act_info.end_time,act_info.open_type)
		end
	elseif protocol.fetch_reward_flag == 1 then
		local act_info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONSUME_GOLD_FANLI)
		if act_info then
			ActivityData.Instance:SetActivityStatus(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONSUME_GOLD_FANLI,ACTIVITY_STATUS.CLOSE,
				act_info.next_time,act_info.start_time,act_info.end_time,act_info.open_type)
		end
	end

	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONSUME_GOLD_FANLI) then
	local activity_type = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONSUME_GOLD_FANLI
	local time_tab = ActivityData.Instance:GetActivityResidueTime(activity_type)
		if time_tab and time_tab <= 0 then
			local act_info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONSUME_GOLD_FANLI)
			act_info.status = ACTIVITY_STATUS.CLOSE
		end
	end
	ViewManager.Instance:FlushView(ViewName.ActivityHall)
end

function ConsumeRewardCtrl:ActivityChange(activity_type, status, next_time, open_type)
	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONSUME_GOLD_FANLI then
		-- 活动开启之后才请求
		if status == ACTIVITY_STATUS.OPEN then
			KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONSUME_GOLD_FANLI,
				RA_CONSUME_GOLD_REWARD_OPERATE_TYPE.RA_CONSUME_GOLD_REWARD_OPERATE_TYPE_INFO,0,0)
		end
	end
end

-- 主界面创建
function ConsumeRewardCtrl:MainuiOpenCreate()
	local function count_down()
		local is_act_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONSUME_GOLD_FANLI)
		local act_info = ActivityData.Instance:GetClockActivityByID(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONSUME_GOLD_FANLI)
		local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
		local player_level = main_role_vo.level
		local activity_type = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONSUME_GOLD_FANLI
        local time_tab = ActivityData.Instance:GetActivityResidueTime(activity_type)	

		if is_act_open then
			if time_tab < 0 or (act_info.min_level ~= nil and player_level < act_info.min_level) then
				return 
			end

			ViewManager.Instance:Open(ViewName.ConsumeRewardView)
		end
	end
	count_down()
end
