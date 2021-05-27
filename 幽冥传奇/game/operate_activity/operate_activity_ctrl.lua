require("scripts/game/operate_activity/operate_activity_data")
require("scripts/game/operate_activity/operate_activity_data_2")
require("scripts/game/operate_activity/operate_activity_view")
require("scripts/game/operate_activity/operate_activity_items")
require("scripts/game/operate_activity/firend_pindan_view")
require("scripts/game/operate_activity/first_charge_payback_view")
require("scripts/game/operate_activity/tip_fortune_buy_view")
require("scripts/game/operate_activity/spend_score_exch_check_view")
require("scripts/game/operate_activity/national_day_acts/national_day_acts_view")
require("scripts/game/operate_activity/my_shopping_cart_view")
-- require("scripts/game/operate_activity/spring_festival/spring_festival_activity_view")

-- 运营活动
OperateActivityCtrl = OperateActivityCtrl or BaseClass(BaseController)

function OperateActivityCtrl:__init()
	if OperateActivityCtrl.Instance then
		ErrorLog("[OperateActivityCtrl] attempt to create singleton twice!")
		return
	end
	OperateActivityCtrl.Instance = self
	self.view = OperateActivityView.New(ViewName.OperateActivity)
	self.data = OperateActivityData.New()
	self.friend_pindan_view = FriendPinDanView.New(ViewName.FriendPinDan)
	self.first_charge_payback_view = FirstChargePaybackView.New(ViewName.FirstChargePayback)
	self.tip_fortune_buy_view = TipFortuneBuyView.New(ViewName.TipFortuneBuy)
	self.spendscore_exch_check_view = SpendscoreExchCheckView.New(ViewName.SpendscoreExchCheck)
	self.national_day_activity_view = NationalDayActsView.New(ViewName.NationalDayActs)
	self.my_shopping_cart_view = MyShoppingCartView.New(ViewName.HappyShopCart)
	-- self.spring_festival_activity_view = SpringFestivalActView.New(ViewName.SpringFestival)

	self:RegisterAllRemind()
	self:RegisterAllProtocols()
end

function OperateActivityCtrl:__delete()
	if self.role_data_change_evt then
		RoleData.Instance:UnNotifyAttrChange(self.role_data_change_evt)
		self.role_data_change_evt = nil
	end
	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.friend_pindan_view then
		self.friend_pindan_view:DeleteMe()
		self.friend_pindan_view = nil
	end

	if self.first_charge_payback_view then
		self.first_charge_payback_view:DeleteMe()
		self.first_charge_payback_view = nil
	end

	if self.spring_festival_activity_view then
		self.spring_festival_activity_view:DeleteMe()
		self.spring_festival_activity_view = nil
	end

	if self.spendscore_exch_check_view then
		self.spendscore_exch_check_view:DeleteMe()
		self.spendscore_exch_check_view = nil
	end

	if self.tip_fortune_buy_view then
		self.tip_fortune_buy_view:DeleteMe()
		self.tip_fortune_buy_view = nil
	end

	if self.national_day_activity_view then
		self.national_day_activity_view:DeleteMe()
		self.national_day_activity_view = nil
	end
	
	if self.my_shopping_cart_view then
		self.my_shopping_cart_view:DeleteMe()
		self.my_shopping_cart_view = nil
	end

	if self.item_data_change_back then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_change_back)
		self.item_data_change_back = nil 
	end

	OperateActivityCtrl.Instance = nil
end

function OperateActivityCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCIssueOperateActivity, "OnIssueOperateActivity")
	GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.AskforOpenActs, self))
	self:Bind(OtherEventType.PASS_DAY, BindTool.Bind(self.PassDayCheckHandler, self))			-- 跨天重新请求数据
	self.role_data_change_evt = BindTool.Bind(self.RoleDataChangeCallback, self)
	RoleData.Instance:NotifyAttrChange(self.role_data_change_evt)
	self.item_data_change_back = BindTool.Bind(self.ItemDataChangeCallback,self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_change_back)

end

function OperateActivityCtrl:RegisterAllRemind()
	for k, v in pairs(OperateActivityData.ActIDRemindNameMap) do
		RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), v)
	end
end

function OperateActivityCtrl:GetRemindNum(remind_name)
	for k, v in pairs(OperateActivityData.ActIDRemindNameMap) do
		if remind_name == v then
			return self.data:GetRemindNumByRemindName(remind_name)
		end
	end
end

function OperateActivityCtrl:DoRemindByActID(act_id)
	if OperateActivityData.ActIDRemindNameMap[act_id] then
		RemindManager.Instance:DoRemind(OperateActivityData.ActIDRemindNameMap[act_id])
	end
end

function OperateActivityCtrl:ItemDataChangeCallback(change_type, item_id, item_index, series)
	if self.data:CheckActIsOpen(OPERATE_ACTIVITY_ID.CONVERT_AWARD) then
		self:DoRemindByActID(OPERATE_ACTIVITY_ID.CONVERT_AWARD)
		self.view:Flush(0, "flush_remind")
	end
	if self.data:CheckActIsOpen(OPERATE_ACTIVITY_ID.BOSS_TREASURE) and self.data:IsBosssuipianItem(item_id) then
		self:DoRemindByActID(OPERATE_ACTIVITY_ID.BOSS_TREASURE)
		self.national_day_activity_view:Flush(0, "flush_remind")
	end
end

function OperateActivityCtrl:RoleDataChangeCallback(key, value, old_value)
	if key == OBJ_ATTR.ACTOR_GOLD or key == OBJ_ATTR.ACTOR_BIND_COIN or key == OBJ_ATTR.ACTOR_COIN or key == OBJ_ATTR.ACTOR_BIND_GOLD then
		if key == OBJ_ATTR.ACTOR_GOLD and (self.data:CheckActIsOpen(OPERATE_ACTIVITY_ID.DISCOUNT_LIMIT_BUY) or 
			self.data:CheckActIsOpen(OPERATE_ACTIVITY_ID.DISCOUNT_TREASURE) or 
			self.data:CheckActIsOpen(OPERATE_ACTIVITY_ID.HAPPY_SHOPPING_CART)) then
			if self.data:CheckActIsOpen(OPERATE_ACTIVITY_ID.DISCOUNT_LIMIT_BUY) then
				self:DoRemindByActID(OPERATE_ACTIVITY_ID.DISCOUNT_LIMIT_BUY)
			end

			if self.data:CheckActIsOpen(OPERATE_ACTIVITY_ID.DISCOUNT_TREASURE) then
				self:DoRemindByActID(OPERATE_ACTIVITY_ID.DISCOUNT_TREASURE)
			end

			if self.data:CheckActIsOpen(OPERATE_ACTIVITY_ID.HAPPY_SHOPPING_CART) then
				self:DoRemindByActID(OPERATE_ACTIVITY_ID.HAPPY_SHOPPING_CART)
			end
			-- self:FlushMainUiPos()
			self.view:Flush(0, "flush_remind")
		end
		if self.data:CheckActIsOpen(OPERATE_ACTIVITY_ID.CONVERT_AWARD) then
			self:DoRemindByActID(OPERATE_ACTIVITY_ID.CONVERT_AWARD)
			self.view:Flush(0, "flush_remind")
		end
		if self.data:CheckActIsOpen(OPERATE_ACTIVITY_ID.BOSS_TREASURE) then
			self:DoRemindByActID(OPERATE_ACTIVITY_ID.BOSS_TREASURE)
			self.national_day_activity_view:Flush(0, "flush_remind")
		end
	elseif key == OBJ_ATTR.ACTOR_VIP_GRADE then
		self:DoRemindByActID(OPERATE_ACTIVITY_ID.CONTINUOUS_LOGIN)
	end
end

-- 请求运营活动配置
function OperateActivityCtrl:AskforOpenActs()
	self:ReqAllOpenOperateActivity()
end

function OperateActivityCtrl:FlushMainUiPos()
	if ViewManager.Instance then
		ViewManager.Instance:FlushView(ViewName.MainUi, 0, "icon_pos")
	end
end

-----------------------------下发-------------------------------
-- 返回运营活动
function OperateActivityCtrl:OnIssueOperateActivity(protocol)
	if protocol.handle_type == OPERATE_ACT_OPERATE_TYPE.ALL_OPEN_ACTS then		-- 获取开启活动ID、cm_id
		self.data:SetOpenActsList(protocol)
		self:FlushMainUiPos()
	elseif protocol.handle_type == OPERATE_ACT_OPERATE_TYPE.ACT_CONFIG then		-- 获取配置
		-- print("运营活动配置 ID：", protocol.act_id)
		-- PrintTable(protocol)
		self.data:SetOperateActCfg(protocol)
	elseif protocol.handle_type == OPERATE_ACT_OPERATE_TYPE.ACT_DATA then		-- 获取数据
		-- print("运营活动数据 ID：", protocol.act_data.act_id)
		self.data:SetOperateActData(protocol.act_data)

		if OperateActivityData.GetOperateActBigType(protocol.act_data.act_id) == OperateActivityData.OperateActBigType.SPORTS_RANK then
		   self.view:Flush(0, "flush_sports_rank", {act_id = protocol.act_data.act_id})
	    end
		-- self:DoRemindByActID(protocol.act_data.act_id)
		self.view:Flush(0, "flush_remind")
		self.national_day_activity_view:Flush(0, "flush_remind")
		-- self.spring_festival_activity_view:Flush(0, "flush_remind")
		if protocol.act_data.act_id == OPERATE_ACTIVITY_ID.CHARGE_GIVE_GIFT or protocol.act_data.act_id == OPERATE_ACTIVITY_ID.CONSUME_GIVE_GIFT then
			if protocol.act_data.opened_day > 1 and protocol.act_data.standard_flag == 0 then
				self:FlushMainUiPos()
			end
		elseif protocol.act_data.act_id == OPERATE_ACTIVITY_ID.FIRST_CHARGE_PAYBACK then
			self:FlushMainUiPos()
		end
	elseif protocol.handle_type == OPERATE_ACT_OPERATE_TYPE.ACT_HANDLE then		-- 操作后更新数据
		self.data:UpdateOperateActData(protocol.act_op_result_list)
		if protocol.act_op_result_list.act_id ~= OPERATE_ACTIVITY_ID.DISCOUNT_LIMIT_BUY 
			and protocol.act_op_result_list.act_id ~= OPERATE_ACTIVITY_ID.DISCOUNT_TREASURE then
			-- self:DoRemindByActID(protocol.act_op_result_list.act_id)
			self.view:Flush(0, "flush_remind")
			self.national_day_activity_view:Flush(0, "flush_remind")
			-- self.spring_festival_activity_view:Flush(0, "flush_remind")
		end
	elseif protocol.handle_type == OPERATE_ACT_OPERATE_TYPE.ADD_ACT then		--增加运营活动
		-- print("增加活动-----")
		-- PrintTable(protocol.add_act_info)
		self.data:AddOpenAct(protocol.add_act_info)
		self:FlushMainUiPos()
	elseif protocol.handle_type == OPERATE_ACT_OPERATE_TYPE.DEL_ACT then		--删除运营活动
		-- print("删除运营活动")
		-- PrintTable(protocol.del_act_info)
		self.data:DeleteAct(protocol.del_act_info)
		self:FlushMainUiPos()
	elseif protocol.handle_type == OPERATE_ACT_OPERATE_TYPE.UPDATE_CONFIG then	--更新活动配置
		-- print("更新配置")
		-- PrintTable(protocol.update_config_info)
		self.data:UpdateActConfig(protocol.update_config_info)
	elseif protocol.handle_type == OPERATE_ACT_OPERATE_TYPE.INVATE_DATA_SEND then
		self.time = 1
		self:CheckInvate(protocol)
	end
end

function OperateActivityCtrl:CheckInvate(protocol)
	MainuiCtrl.Instance:InvateTip(MAINUI_TIP_TYPE.INVATE_PINGDAN, self.time, function ()
		RichTextUtil.ParseExe(protocol.send_invate_info and protocol.send_invate_info.content or "")
		self.time = 0
		self:CheckInvate(protocol)
	end)
end

function OperateActivityCtrl:OpenConfirmJoinAlert(oper_type, dindan_id, cost_price, gift_type, join_type)
	local box = Alert.New(string.format(Language.OperateActivity.PinDanDlgContent, cost_price))

	local function ok_callback()
		--发送购买协议
		local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.PINGDAN_QIANGGOU)
		if cmd_id then
			OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, OPERATE_ACTIVITY_ID.PINGDAN_QIANGGOU, gift_type, oper_type,
			 oper_time, dindan_id, role_id, join_type or 2)
		end
		box:DeleteMe()
		box = nil

	end
	local function cancel_callback()
		box:DeleteMe()
		box = nil
	end
	
	box.zorder = COMMON_CONSTS.ZORDER_MAX
	box:SetIsAnyClickClose(false)
	box:SetOkString(Language.Common.HappyBuy)
	box:SetCancelString(Language.Common.NotHappyBuy)
	box:SetOkFunc(ok_callback)
	box:SetCancelFunc(cancel_callback)
	box:Open()
	box:NoCloseButton()
end

function OperateActivityCtrl:PassDayCheckHandler()
	local act_id = OPERATE_ACTIVITY_ID.CHARGE_GIVE_GIFT
	if self.data:CheckActIsOpen(act_id) then
		local charge_give_open_info = self.data:GetChargeGiveOpenInfo()
		if charge_give_open_info.standard_flag == 1 then
			local cmd_id = self.data:GetOneOpenActCmdID(act_id)
			self:ReqOperateActData(cmd_id, act_id)
		else
			charge_give_open_info.opened_day = charge_give_open_info.opened_day + 1
			GlobalEventSystem:Fire(OperateActivityEventType.DELETE_CLOSE_ACT)
			self:FlushMainUiPos()
		end
	end

	act_id = OPERATE_ACTIVITY_ID.CONSUME_GIVE_GIFT
	if self.data:CheckActIsOpen(act_id) then
		local consume_give_open_info = self.data:GetConsumeGiveOpenInfo()
		if consume_give_open_info.standard_flag == 1 then
			local cmd_id = self.data:GetOneOpenActCmdID(act_id)
			self:ReqOperateActData(cmd_id, act_id)
		else
			consume_give_open_info.opened_day = consume_give_open_info.opened_day + 1
			GlobalEventSystem:Fire(OperateActivityEventType.DELETE_CLOSE_ACT)
			self:FlushMainUiPos()
		end
	end

	act_id = OPERATE_ACTIVITY_ID.TIME_LIMIT_ONCE_CHARGE
	if self.data:CheckActIsOpen(act_id) then
		local cmd_id = self.data:GetOneOpenActCmdID(act_id)
		self:ReqOperateActData(cmd_id, act_id)
	else
		GlobalEventSystem:Fire(OperateActivityEventType.DELETE_CLOSE_ACT)
		self:FlushMainUiPos()
	end

	act_id = OPERATE_ACTIVITY_ID.LOGIN_SEND_GIFT
	if self.data:CheckActIsOpen(act_id) then
		local cmd_id = self.data:GetOneOpenActCmdID(act_id)
		self:ReqOperateActData(cmd_id, act_id)
	else
		GlobalEventSystem:Fire(OperateActivityEventType.DELETE_CLOSE_ACT)
		self:FlushMainUiPos()
	end

	act_id = OPERATE_ACTIVITY_ID.HAPPY_SHOPPING_CART
	if self.data:CheckActIsOpen(act_id) then
		local cmd_id = self.data:GetOneOpenActCmdID(act_id)
		self:ReqOperateActData(cmd_id, act_id)
	else
		GlobalEventSystem:Fire(OperateActivityEventType.DELETE_CLOSE_ACT)
		self:FlushMainUiPos()
	end
end

-------------------------请求------------------------
-- 请求所有开启的运营活动 (返回145 1, 1)
function OperateActivityCtrl:ReqAllOpenOperateActivity()
	local protocol = ProtocolPool.Instance:GetProtocol(CSOperateActivityReq)
	protocol.handle_type = 1
	protocol:EncodeAndSend()
end

-- 请求运营活动配置 (返回145 1, 2)
function OperateActivityCtrl:ReqOperateActCfg(cmd_id, act_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSOperateActivityReq)
	protocol.handle_type = OPERATE_ACT_OPERATE_TYPE.ACT_CONFIG
	protocol.cmd_id = cmd_id or 1
	protocol.act_id = act_id
	protocol:EncodeAndSend()
end

-- 请求运营活动数据 (返回145 1, 3)
function OperateActivityCtrl:ReqOperateActData(cmd_id, act_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSOperateActivityReq)
	protocol.handle_type = OPERATE_ACT_OPERATE_TYPE.ACT_DATA
	protocol.cmd_id = cmd_id or 1
	protocol.act_id = act_id
	protocol:EncodeAndSend() 
end

-- 运营活动操作请求 如领奖 (返回145 1, 4)
function OperateActivityCtrl:ReqOperateActOpr(cmd_id, act_id, award_index, oper_type, oper_time, dindan_id, role_id, join_type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSOperateActivityReq)
	protocol.handle_type = OPERATE_ACT_OPERATE_TYPE.ACT_HANDLE
	protocol.cmd_id = cmd_id or 1
	protocol.act_id = act_id
	protocol.award_index = award_index or 1
	protocol.oper_type = oper_type
	protocol.oper_time = oper_time
	protocol.dindan_id = dindan_id or 0
	protocol.role_id = role_id or 0
	protocol.join_type = join_type or 0

	protocol:EncodeAndSend()
end