require("scripts/game/other/other_data")
require("scripts/gameui/view/change_name")

-- 不好归类的小系统放这边

OtherCtrl = OtherCtrl or BaseClass(BaseController)

function OtherCtrl:__init()
	if OtherCtrl.Instance ~= nil then
		ErrorLog("[OtherCtrl] attempt to create singleton twice!")
		return
	end
	OtherCtrl.Instance = self

	self.data = OtherData.New()
	self.changeNameView = ChangeNameView.New()
	self:RegisterAllProtocols()

	self.recv_main_role_info = self:BindGlobalEvent(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.OnRecvMainRoleInfo, self))
end

function OtherCtrl:__delete()
	OtherCtrl.Instance = nil
	
	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.changeNameView then
		self.changeNameView:DeleteMe()
		self.changeNameView = nil
	end

	if self.server_alert then
		self.server_alert:DeleteMe()
		self.server_alert = nil
	end

	if self.server_button_alert then
		self.server_button_alert:DeleteMe()
		self.server_button_alert = nil
	end
end

function OtherCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCOpenView, "OnOpenView")
	-- self:RegisterProtocol(SCCrossServerState, "OnCrossServerState")
	self:RegisterProtocol(SCCloseGuideArrowPromote, "CloseGuideArrowPromote")
	self:RegisterProtocol(SCOpenServerDays, "OnOpenServerDays")
	self:RegisterProtocol(SCForceRename, "OnForceRename")
	self:RegisterProtocol(SCGuildRenameSuccess, "OnGuildRename")
	self:RegisterProtocol(SCSuperChestState, "OnSuperChestState")
	self:RegisterProtocol(SCServerOpenAlert, "OnServerOpenAlert")
	self:RegisterProtocol(SCChargeInfoData, "OnChargeInfoData")
	self:RegisterProtocol(SCCrossLogin, "OnCrossLogin")
end

function OtherCtrl:OnChargeInfoData(protocol)
	self.data:SetDayChargeGoldNum(protocol.day_charge_gold_num)
	self.data:SetDayConsumeGoldNum(protocol.day_consume_gold_num)
end

function OtherCtrl:OnOpenView(protocol)
	local link_cfg = RichTextUtil.GetOpenLinkCfg(protocol.view_type)
	if nil ~= link_cfg then
		if protocol.is_close == 0 then
			ViewManager.Instance:OpenViewByDef(link_cfg.view_def)
			local data = Split(protocol.param_str, ",")
			if #data > 0 then
				ViewManager.Instance:FlushViewByDef(link_cfg.view_def, 0, "OnOpenView", data)
			end
		else
			ViewManager.Instance:CloseViewByDef(link_cfg.view_def)
		end
	end
end

function OtherCtrl:OnCrossServerState(protocol)
	self.data:SetCrossServerState(protocol.state)
end

function OtherCtrl:CloseGuideArrowPromote(protocol)
	Log("======CloseGuideArrowPromote")
end

function OtherCtrl:OnOpenServerDays(protocol)
	self.data:SetOpenServerDays(protocol)
end

function OtherCtrl:OnCrossLogin(protocol)
	GlobalEventSystem:Fire(OtherEventType.FIRST_LOGIN, protocol.is_cross_login == 1)
end

function OtherCtrl:OnForceRename(protocol)
	Log("======Rename Succeed")
	ViewManager.Instance:Close(ViewName.ChangeNameWnd)
end

function OtherCtrl:OnGuildRename(protocol)
	ViewManager.Instance:Close(ViewName.ChangeNameWnd)
end

function OtherCtrl:OnSuperChestState(protocol)
	self.data:SetSuperChestState(protocol.flag)
end

function OtherCtrl.RenameReq(item_series, rename_name)
	local protocol = ProtocolPool.Instance:GetProtocol(CSRenameReq)
	protocol.item_series = item_series
	protocol.rename_name = rename_name
	protocol:EncodeAndSend()
end

function OtherCtrl.RenameGuildReq(new_guild_name)
	local protocol = ProtocolPool.Instance:GetProtocol(CSRenameGuild)
	protocol.new_guild_name = new_guild_name
	protocol:EncodeAndSend()
end

-- 服务端弹出提示框
function OtherCtrl:OnServerOpenAlert(protocol)
	local alert_type = protocol.type
	local tips_str = protocol.content
	self.server_alert = self.server_alert or Alert.New()
	if alert_type == SERVER_ALERT_TYPE.RECHARGE_GOLD then
		local recharge_text = tips_str ~= "" and tips_str or Language.Common.RechargeAlertText
		self.server_alert:SetLableString(recharge_text)
		self.server_alert:SetOkFunc(BindTool.Bind1(function ()
			ViewManager.Instance:OpenViewByDef(ViewDef.ZsVip.Recharge)
		end, self))
		self.server_alert:SetOkString(Language.Common.BtnRechargeGo)
		self.server_alert:SetCancelString(Language.Common.Cancel)
		self.server_alert:SetShowCheckBox(false)
		self.server_alert:Open()

	elseif alert_type == SERVER_ALERT_TYPE.COMMON_DESC then
		self.server_alert:SetLableString(tips_str)

		-- 复选框
		local checkbox_t = RichTextUtil.ParseCheckBoxTable(tips_str)
		if checkbox_t and checkbox_t[1] and checkbox_t[1].desc then
			self.server_alert:SetShowCheckBox(true)
			self.server_alert:SetCheckBoxText(checkbox_t[1].desc)
		else
			self.server_alert:SetShowCheckBox(false)
		end

		-- 确认按钮
		local btn_t = RichTextUtil.ParseBtnTable(tips_str)
		self.server_alert:SetOkFunc(BindTool.Bind(function(is_nolonger_tips, data)
			if btn_t[1] and btn_t[1].func_name and string.sub(btn_t[1].func_name, 1, 9) == "OpenView," then
				local func_name = btn_t[1].func_name
				local param = Split(string.sub(func_name, 10, -1), ",")
				local link_cfg = RichTextUtil.GetOpenLinkCfg(tonumber(param[1]))
				if nil ~= link_cfg then
					ViewManager.Instance:OpenViewByDef(link_cfg.view_def)
				end
				if nil ~= param[2] then
					ViewManager.Instance:FlushView(link_cfg.view_def, 0, "param", {param[2]})
				end
			elseif TaskCtrl.Instance and TaskCtrl.Instance.npc_obj_id and btn_t[1] and btn_t[1].func_name then
				local func_name = btn_t[1].func_name
				if checkbox_t and checkbox_t[1] then
					local par = is_nolonger_tips and 1 or 0
					func_name = func_name .. "," .. par
				end
				TaskCtrl.SendNpcTalkReq(TaskCtrl.Instance.npc_obj_id, func_name)
			end
		end))

		--取消按钮
		self.server_alert:SetCancelFunc(BindTool.Bind(function(is_nolonger_tips, data)
			if btn_t[2] and btn_t[2].func_name and string.sub(btn_t[2].func_name, 1, 9) == "OpenView," then
				local func_name = btn_t[2].func_name
				local param = Split(string.sub(func_name, 10, -1), ",")
				local link_cfg = RichTextUtil.GetOpenLinkCfg(tonumber(param[1]))
				if nil ~= link_cfg then
					ViewManager.Instance:OpenViewByDef(link_cfg.view_def)
				end
				if nil ~= param[2] then
					ViewManager.Instance:FlushView(link_cfg.view_def, 0, "param", {param[2]})
				end
			elseif TaskCtrl.Instance and TaskCtrl.Instance.npc_obj_id and btn_t[2] and btn_t[2].func_name then
				local func_name = btn_t[2].func_name
				if checkbox_t and checkbox_t[1] then
					local par = is_nolonger_tips and 1 or 0
					func_name = func_name .. "," .. par
				end
				TaskCtrl.SendNpcTalkReq(TaskCtrl.Instance.npc_obj_id, func_name)
			end
		end))

		--关闭回调
		self.server_alert:SetCloseFunc(BindTool.Bind(function(is_nolonger_tips, data)
			if btn_t[3] and btn_t[3].func_name and string.sub(btn_t[3].func_name, 1, 9) == "OpenView," then
				local func_name = btn_t[3].func_name
				local param = Split(string.sub(func_name, 10, -1), ",")
				local link_cfg = RichTextUtil.GetOpenLinkCfg(tonumber(param[1]))
				if nil ~= link_cfg then
					ViewManager.Instance:OpenViewByDef(link_cfg.view_def)
				end
				if nil ~= param[2] then
					ViewManager.Instance:FlushView(link_cfg.view_def, 0, "param", {param[2]})
				end
			elseif TaskCtrl.Instance and TaskCtrl.Instance.npc_obj_id and btn_t[3] and btn_t[3].func_name then
				local func_name = btn_t[3].func_name
				if checkbox_t and checkbox_t[1] then
					local par = is_nolonger_tips and 1 or 0
					func_name = func_name .. "," .. par
				end
				TaskCtrl.SendNpcTalkReq(TaskCtrl.Instance.npc_obj_id, func_name)
			end
		end))


		self.server_alert:SetOkString((btn_t and btn_t[1] and btn_t[1].text) or Language.Common.Confirm)
		self.server_alert:SetCancelString((btn_t and btn_t[2] and btn_t[2].text) or Language.Common.Cancel)
		self.server_alert:Open()
		
	elseif alert_type == SERVER_ALERT_TYPE.BUY_WINDOW then
		TipCtrl.Instance:OpenBuyTip(tips_str)
	elseif alert_type == SERVER_ALERT_TYPE.USE_ITEM then
		self.server_alert:SetLableString(tips_str or "")

		local btn_t = RichTextUtil.ParseBtnTable(tips_str)
		self.server_alert:SetOkString((btn_t and btn_t[1] and btn_t[1].text) or Language.Common.Confirm)
		self.server_alert:SetOkFunc(BindTool.Bind(BagCtrl.ConfirmUseItem, BagCtrl.Instance, 1))
		self.server_alert:Open()
	elseif alert_type == SERVER_ALERT_TYPE.MULTI_BUTTON then
		self.server_button_alert = self.server_button_alert or AlertMlutiButton.New()
		self.server_button_alert:SetLableString(tips_str or "")

		local btn_t = RichTextUtil.ParseBtnTable(tips_str)
		local func_list = {}
		if nil == btn_t then return end

		for k,v in pairs(btn_t) do
			if TaskCtrl.Instance and TaskCtrl.Instance.npc_obj_id and btn_t[2] and btn_t[2].func_name then
				table.insert(func_list, v.func_name)
			end
		end

		self.server_button_alert:SetBtnString({btn_t[1].text, btn_t[2].text, btn_t[3].text})
		self.server_button_alert:SetFuncList(func_list)
		-- self.server_button_alert:SetBtnOneString(btn_t[1].text)
		-- self.server_button_alert:SetBtnTwoString(btn_t[2].text)
		-- self.server_button_alert:SetBtnThreeString(btn_t[3].text)
		self.server_button_alert:Open()
	end
end

----------------------------------------------------------------------
function OtherCtrl:OpenChangeName(item_data)
	self.changeNameView:Open()
	self.changeNameView:Flush(0, "Open", {item_data.series})
end

function OtherCtrl:OnRecvMainRoleInfo()
	local is_ios = cc.PLATFORM_OS_IPHONE == PLATFORM or cc.PLATFORM_OS_IPAD == PLATFORM
	local _type = is_ios and 1 or 0
	OtherCtrl.SendSetPlayerSystemTypeReq(_type)
	self:UnBindGlobalEvent(self.recv_main_role_info)
end

-- 设置玩家系统类型(139, 12)
function OtherCtrl.SendSetPlayerSystemTypeReq(_type)
    local protocol = ProtocolPool.Instance:GetProtocol(CSSetPlayerSystemTypeReq)
    protocol.type = _type
    protocol:EncodeAndSend()
end