require("game/first_charge/first_charge_view")
require("game/first_charge/second_charge_view")
FirstChargeCtrl = FirstChargeCtrl or BaseClass(BaseController)
function FirstChargeCtrl:__init()
	if FirstChargeCtrl.Instance then
		print_error("[FirstChargeCtrl] Attemp to create a singleton twice !")
	end
	FirstChargeCtrl.Instance = self
	self.view = FirstChargeView.New(ViewName.FirstChargeView)
	self.second_view = SecondChargeView.New(ViewName.SecondChargeView)
	self.role_change_callback = BindTool.Bind(self.RoleChangeCallBack, self)
	PlayerData.Instance:ListenerAttrChange(self.role_change_callback)
	self.open_view_level_list = {70, 90}
	self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind1(self.MainuiOpenCreate, self))
end

function FirstChargeCtrl:__delete()
	self.view:DeleteMe()
	self.view = nil
	if self.role_change_callback then
		PlayerData.Instance:UnlistenerAttrChange(self.role_change_callback)
	end
	GlobalTimerQuest:CancelQuest(self.delay_timer)
	FirstChargeCtrl.Instance = nil
end

function FirstChargeCtrl:GetView()
	return self.view
end

function FirstChargeCtrl:SetAutoCloseViewTime(close_time, is_stop_task)
	self.view:SetAutoCloseTime(close_time, is_stop_task)
end

function FirstChargeCtrl:FlusView()
	if self.view then
		self.view:Flush()
	end
	if self.second_view then
		self.second_view:Flush()
	end
end

local IndexList = {
	3, 2, 1
}

function FirstChargeCtrl:RoleChangeCallBack(key, value, old_value)
	if key == "level" then

		-- 首充标签1,2,3，倒序判断，先判断三充，二冲,首充

		if not DailyChargeData.Instance:GetIsThreeRecharge() then
			for k,v in pairs(self.open_view_level_list) do
				if old_value < v and value >= v then
					for i,v in ipairs(IndexList) do
						if v == 1 then
							local is_first = DailyChargeData.Instance:GetFirstChongzhiOpen()
							local open = is_first and OpenFunData.Instance:CheckIsHide("firstchargeview")
							if open then
								DailyChargeData.Instance:SetShowPushIndex(v)
								ViewManager.Instance:Open(ViewName.SecondChargeView)
								break
							end
						else
							if DailyChargeData.Instance:GetThreeRechargeOpen(v) then
								DailyChargeData.Instance:SetShowPushIndex(v)
								ViewManager.Instance:Open(ViewName.SecondChargeView)
								break
							end
						end
					end
				end
			end
		else
			PlayerData.Instance:UnlistenerAttrChange(self.role_change_callback)
			self.role_change_callback = nil
		end

		-- local history_recharge = DailyChargeData.Instance:GetChongZhiInfo().history_recharge or 0
		-- if history_recharge >= DailyChargeData.GetMinRecharge() then
		-- 	-- 首充过不再弹面板 去除监听
		-- 	PlayerData.Instance:UnlistenerAttrChange(self.role_change_callback)
		-- 	self.role_change_callback = nil
		-- 	return
		-- end
	end
end

-- 主界面创建
function FirstChargeCtrl:MainuiOpenCreate()
	self.delay_timer = GlobalTimerQuest:AddDelayTimer(function()
		self:OpenView()
	end, 2)
end

function FirstChargeCtrl:OpenView()
	-- 三充过后不再弹
	if DailyChargeData.Instance:GetIsThreeRecharge() then
		return
	end
	if GameVoManager.Instance:GetMainRoleVo().level <= 70 then
		return
	end
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local remind_day = UnityEngine.PlayerPrefs.GetInt("open_first_recharge_view_day")
	-- 为空则说明没打开过
	if nil == remind_day or cur_day ~= remind_day then
		for i,v in ipairs(IndexList) do
			if v == 1 then
				local is_first = DailyChargeData.Instance:GetFirstChongzhiOpen()
				local open = is_first and OpenFunData.Instance:CheckIsHide("firstchargeview")
				if open then
					DailyChargeData.Instance:SetShowPushIndex(v)
					ViewManager.Instance:Open(ViewName.SecondChargeView)
					break
				end
			else
				if DailyChargeData.Instance:GetThreeRechargeOpen(v) then
					DailyChargeData.Instance:SetShowPushIndex(v)
					ViewManager.Instance:Open(ViewName.SecondChargeView)
					break
				end
			end
		end

		UnityEngine.PlayerPrefs.SetInt("open_first_recharge_view_day", cur_day)
	end
end

function FirstChargeCtrl:OpenTipView()
	if DailyChargeData.Instance:GetIsThreeRecharge() then
		return
	end
	-- 为空则说明没打开过
		for i,v in ipairs(IndexList) do
			if v == 1 then
				local is_first = DailyChargeData.Instance:GetFirstChongzhiOpen()
				local open = is_first and OpenFunData.Instance:CheckIsHide("firstchargeview")
				if open then
					DailyChargeData.Instance:SetShowPushIndex(v)
					ViewManager.Instance:Open(ViewName.SecondChargeView)
					break
				end
			else
				if DailyChargeData.Instance:GetThreeRechargeOpen(v) then
					DailyChargeData.Instance:SetShowPushIndex(v)
					ViewManager.Instance:Open(ViewName.SecondChargeView)
					break
				end
			end
		end
end