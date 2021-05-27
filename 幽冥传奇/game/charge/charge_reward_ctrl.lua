require("scripts/game/charge/charge_reward_data")
require("scripts/game/charge/charge_first_view")
-- require("scripts/game/charge/charge_everyday_view")
ChargeRewardCtrl = ChargeRewardCtrl or BaseClass(BaseController)

function ChargeRewardCtrl:__init()
	if	ChargeRewardCtrl.Instance then
		ErrorLog("[ChargeRewardCtrl]:Attempt to create singleton twice!")
	end
	ChargeRewardCtrl.Instance = self
	self.data = ChargeRewardData.New()
	self.first_view = ChargeFirstView.New(ViewDef.ChargeFirst)
    -- self.everyday_view = ChargeEveryDayView.New(ViewDef.ChargeEveryDay) 

	self.role_attr_change_callback = BindTool.Bind(self.RoleDataChangeCallback, self)
	self.role_data_listener_h = RoleData.Instance:AddEventListener(RoleData.ROLE_ATTR_CHANGE, self.role_attr_change_callback)
	self:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.OnRecvMainRoleInfo, self))
	self:RegisterAllProtocols()
	self:RegisterAllRemind()
end

function ChargeRewardCtrl:__delete()
	self.first_view:DeleteMe()
	self.first_view = nil
	-- self.everyday_view:DeleteMe()
	-- self.everyday_view = nil

	self.data:DeleteMe()
	self.data = nil
	self.role_attr_change_callback = nil

	if self.role_data_listener_h and RoleData.Instance then
		RoleData.Instance:RemoveEventListener(self.role_data_listener_h)
	end
	ChargeRewardCtrl.Instance = nil
end

function ChargeRewardCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCFirstChargeState, "OnFirstChargeState")
	self:RegisterProtocol(SCChargeEveryDayState, "OnChargeEveryDayState")
	self:RegisterProtocol(SCChargeEveryDayTreasureState, "OnChargeEveryDayTreasureState")
	self:RegisterProtocol(SCEveryDayChrgeGiftData, "OnChargeEveryDayBoxState")
end

function ChargeRewardCtrl:RegisterAllRemind()
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.ChargeFirst)
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.ChargeEveryDay)
end

function ChargeRewardCtrl:OnRecvMainRoleInfo()
	ChargeRewardCtrl.SendFirstChargeInfoReq()
	ChargeRewardCtrl.SendChargeEveryDayInfoReq()
	ChargeRewardCtrl.SendGetChargeEveryDayTreasureReq(0)
end

--------------------------------------
-- 首充
--------------------------------------
-- 请求首充礼包信息
function ChargeRewardCtrl.SendFirstChargeInfoReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSFirstChargeInfoReq)
	protocol:EncodeAndSend()
end

-- 请求领取首充奖励
function ChargeRewardCtrl.SendGetFirstChargeAwardReq(award_grade)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetFirstChagreAwardReq)
	protocol.award_grade = award_grade
	protocol:EncodeAndSend()
end

-- 下发首充领取状态
function ChargeRewardCtrl:OnFirstChargeState(protocol)
	self.data:SetFirstChargeState(protocol)
	RemindManager.Instance:DoRemindDelayTime(RemindName.ChargeFirst)
end

-- -- 领取首充标识
-- function ChargeRewardCtrl:OnFirstChargeInformation(protocol)
-- 	self.data:SetFirstChargeInformation(protocol)

	-- if self.data:GetFirstChargeIsAllGet() then
	-- 	for k, v in pairs(MainuiIcons) do
	-- 		if v.view_pos == ViewDef.ChargeFirst then
	-- 			table.remove(MainuiIcons, k)
	-- 		end
	-- 	end
	-- 	-- local icon_bar = MainUiIconbar.New()
	-- 	local main_ui = MainuiCtrl.Instance:GetView().mainui_part_list
	-- 	local icon_bar
	-- 	for k, v in pairs(main_ui) do
	-- 		if v.is_top1_visible then
	-- 			icon_bar = v
	-- 			break
	-- 		end
	-- 	end
	-- 	icon = icon_bar:GetIcon(16)
	-- 	icon:SetVisible(false)
	-- 	icon_bar:UpdateIconAllChildPos()
	-- end
	-- if ViewManager.Instance then
	-- 	ViewManager.Instance:FlushView(ViewDef.MainUi, 0, "icon_pos")
	-- end

	-- RemindManager.Instance:DoRemind(RemindName.ChargeFirst)
	-- RemindManager.Instance:DoRemind(RemindName.ChargeEveryDay)
-- end

--------------------------------------
-- 每日充值
--------------------------------------
-- 请求每日充值信息
function ChargeRewardCtrl.SendChargeEveryDayInfoReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSChargeEveryDayInfoReq)
	protocol:EncodeAndSend()
end

-- 请求领取每日充值奖励
function ChargeRewardCtrl.SendGetChargeEveryDayAwardReq(award_grade)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetChargeEveryDayAwardReq)
	protocol.award_grade = award_grade
	protocol:EncodeAndSend()
end

-- 请求领取每日充值宝箱
function ChargeRewardCtrl.SendGetChargeEveryDayTreasureReq(award_grade)
	if nil == award_grade then award_grade = 0 end
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetChargeEveryDayTreasureReq)
	protocol.award_grade = award_grade
	protocol:EncodeAndSend()
end

-- 下发每日充值领取状态
function ChargeRewardCtrl:OnChargeEveryDayState(protocol)
	self.data:SetChargeEveryDayState(protocol)
	RemindManager.Instance:DoRemindDelayTime(RemindName.ChargeEveryDay)
	-- if ViewManager.Instance then
	-- 	ViewManager.Instance:FlushView(ViewDef.MainUi, 0, "icon_pos")
	-- end

	-- RemindManager.Instance:DoRemind(RemindName.ChargeEveryDay)
end

-- 下发每日充值宝箱领取状态
function ChargeRewardCtrl:OnChargeEveryDayTreasureState(protocol)
	self.data:SetChargeEveryDayTreasureState(protocol)
	RemindManager.Instance:DoRemindDelayTime(RemindName.ChargeEveryDay)
end

function ChargeRewardCtrl:OnChargeEveryDayBoxState(protocol)
	self.data:SetChargeEveryDayBoxState(protocol)
	RemindManager.Instance:DoRemindDelayTime(RemindName.ChargeEveryDay)
end

function ChargeRewardCtrl:RoleDataChangeCallback(vo)
	if vo.key == OBJ_ATTR.ACTOR_GOLD then
		ChargeRewardCtrl.SendFirstChargeInfoReq()
		ChargeRewardCtrl.SendChargeEveryDayInfoReq()
		-- ChargeRewardCtrl.SendGetChargeEveryDayTreasureReq(0)
	end
end

function ChargeRewardCtrl:GetRemindNum(remind_name)
	if remind_name == RemindName.ChargeFirst then
		if ChargeRewardData.Instance:GetFirstChargeIsAllGet() then
			return 0
		end
		local num = self.data:GetFirstChargeRemindNum()
		return num
		-- local opened_view_list = ViewManager.Instance:GetEverOpenedViewList()
		-- local is_opened = opened_view_list[ViewDef.ChargeFirst]
		-- print("FirstChargeRemindNum=========", num)
		-- if 0 == num and not is_opened then
		-- 	return 1
		-- elseif num > 0 then
		-- 	return num
		-- end
		-- return 0
	elseif remind_name == RemindName.ChargeEveryDay then
		if ChargeRewardData.Instance:GetEveryDayChargeIsAllGet() then
			return 0
 		end
 		local num = self.data:GetEveryDayChargeRemindNum()
 		return num
		-- local opened_view_list = ViewManager.Instance:GetEverOpenedViewList()
		-- local is_opened = opened_view_list[ViewName.ChargeEveryDay]
		-- print("ChargeEveryDayNum=========", num)
		-- if 0 == num and not is_opened then
		-- 	return 1
		-- elseif num > 0 then
		-- 	return num
		-- end
		-- return 0
	end
end