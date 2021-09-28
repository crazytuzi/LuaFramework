require("game/welfare/welfare_data")
require("game/welfare/welfare_view")
require("game/welfare/offline_exp_view")
require("game/welfare/online_reward_view")
require("game/welfare/welfare_tip_view")

WelfareCtrl = WelfareCtrl or BaseClass(BaseController)

function WelfareCtrl:__init()
	if WelfareCtrl.Instance then
		print_error("[WelfareCtrl] 尝试创建第二个单例模式")
		return
	end
	WelfareCtrl.Instance = self
	self.welfare_view = WelfareView.New(ViewName.Welfare)
	self.offline_exp_view = OffLineExpView.New(ViewName.OffLineExp)
	self.online_reward_view = OnLineRewardView.New(ViewName.OnLineReward)
	self.welfare_tip_view = WelfareTipsView.New(ViewName.WelfareTip)
	self:RegisterAllProtocols()
	self.data = WelfareData.New()
	self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.MainuiOpen, self))
end

function WelfareCtrl:__delete()
	if self.welfare_view then
		self.welfare_view:DeleteMe()
		self.welfare_view = nil
	end

	if self.offline_exp_view then
		self.offline_exp_view:DeleteMe()
		self.offline_exp_view = nil
	end

	if self.online_reward_view then
		self.online_reward_view:DeleteMe()
		self.online_reward_view = nil
	end

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.welfare_tip_view then
		self.welfare_tip_view:DeleteMe()
		self.welfare_tip_view = nil
	end

	WelfareCtrl.Instance = nil
end

function WelfareCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCWelfareInfo, "SyncWelfareInfo")
	self:RegisterProtocol(SCDailyFindItemChange, "SyncFindInfo")
	self:RegisterProtocol(SCYuanBaoZhuanpanSenditem,"SyncTurntableReward")
	self:RegisterProtocol(SCYuanBaoZhuanPanInfo,"SyncTurntableYuanbao")
end

function WelfareCtrl:SyncFindInfo(protocol)
	self.data:UpdateFindData(protocol)
	self:SetRedPoint()
	self.welfare_view:FlushFind()
end

function WelfareCtrl:SyncWelfareInfo(protocol)
	--离线奖励（大于或等于一小时才显示离线经验图标）
	if protocol.offline_timestamp >= 3600 then
		MainUICtrl.Instance.view:Flush(MainUIViewChat.IconList.OFF_LINE, {true})
	else
		MainUICtrl.Instance.view:Flush(MainUIViewChat.IconList.OFF_LINE, {false})
	end

	self.data:SetWelfareData(protocol)

	--在线奖励
	MainUICtrl.Instance.view:Flush("on_line")
	if self.online_reward_view:IsOpen() then
		-- self.online_reward_view:Flush()
		if protocol.online_reward_mark > protocol.old_online_reward_mark then
			self.online_reward_view:Flush("start_move")
		else
			self.online_reward_view:Flush()
		end
	end

	RemindManager.Instance:Fire(RemindName.WelfareSign)
	RemindManager.Instance:Fire(RemindName.WelfareFind)
	RemindManager.Instance:Fire(RemindName.WelfareLevelReward)
	RemindManager.Instance:Fire(RemindName.WelfareTurntable)
	self.welfare_view:OnSeverDataChange()
	self.welfare_view:Flush("sign_in")

	-- 开服活动面板
	RemindManager.Instance:Fire(RemindName.KaiFu)
	KaifuActivityCtrl.Instance:FlushKaifuView()
end

--获取元宝物品索引信息
function WelfareCtrl:SyncTurntableReward(protocol)
	self.welfare_view:Flush("startturn", {protocol.index})
end

--获取元宝数量
function WelfareCtrl:SyncTurntableYuanbao(protocol)
	self.data:SetTurnTableDamondNum(protocol.zhuanshinum)
	self.data:SetTurnTableRewardCount(protocol.chou_jiang_times)
	self:SetRedPoint()
	-- 要刷新元宝但界面没加载完，延迟刷新
	GlobalTimerQuest:AddDelayTimer(function()
		self.welfare_view:Flush("yuan_baonum", {self.data:GetTurnTableDamondNum(), self.data:GetTurnTableRewardCount()})
		RemindManager.Instance:Fire(RemindName.WelfareTurntable)
	end, 0.2)
end

--发送获取离线经验请求
function WelfareCtrl:SendGetOffLineExp(type)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSGetOfflineExp)
	send_protocol.type = type
	send_protocol:EncodeAndSend()
end

function WelfareCtrl:SendSignIn(request_type, part, is_quick_sign)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSWelfareSignInReward)
	send_protocol.request_type = request_type or 0
	send_protocol.part = part or 0
	send_protocol.is_quick_sign = is_quick_sign or 0
	send_protocol:EncodeAndSend()
end

--发送找回请求
function WelfareCtrl:SendGetFindReward(find_type, get_type)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSGetDailyFindWelfare)
	send_protocol.dailyfind_type = find_type
	send_protocol.get_type = get_type
	send_protocol:EncodeAndSend()
end

--发送活动找回请求
function WelfareCtrl:SendGetActivityFindReward(find_type, is_free)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSWelfareActivityFind)
	send_protocol.find_type = find_type
	send_protocol.is_free = is_free
	send_protocol:EncodeAndSend()
end

--领取冲级豪礼奖励
function WelfareCtrl:SendGetLevelReward(level)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSWelfareFetchChongjihaoliReward)
	send_protocol.level = level or 0
	send_protocol:EncodeAndSend()
end

--领取在线奖励
function WelfareCtrl:SendGetOnlineReward(part)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSWelfareOnlineReward)
	send_protocol.part = part
	send_protocol:EncodeAndSend()
end

--领取欢乐果树奖励
function WelfareCtrl:SendGetHappyTreeReward(type)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSWelfareFetchHappyTreeReward)
	send_protocol.type = type
	send_protocol:EncodeAndSend()
end

--兑换欢乐果树奖励
function WelfareCtrl:SendHappyTreeExchange(type, index, num)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSScoreToItemConvert)
	send_protocol.scoretoitem_type = type
	send_protocol.index = index
	send_protocol.num = num
	send_protocol:EncodeAndSend()
end

--转盘物品奖励
function WelfareCtrl:SendTurntableReward(sendtype)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSYuanBaoZhuanpanInFo)
	send_protocol.operate_type = sendtype
	send_protocol:EncodeAndSend()
end

--福利红点
function WelfareCtrl:SetRedPoint()
	self.welfare_view:SetRedPoint()
end

function WelfareCtrl:MainuiOpen()
	GlobalTimerQuest:AddDelayTimer(function()
		local offline_timestamp = self.data:GetOffLineTimeStamp()
		--离线时间大于或等于一小时才显示
		if offline_timestamp >= 3600 then
			ViewManager.Instance:Open(ViewName.OffLineExp)
		end
	end, 0)
end

function WelfareCtrl:ShowWelfareTip(func, data, content , cancle_data, no_func, is_show_no_tip, is_show_time, prefs_key, is_recycle, recycle_text, auto_text_desc, hide_cancel, boss_id, no_auto_click_yes, no_button_text, cal_time, auto_click_no)
	if SettingData.Instance:GetCommonTipkey(prefs_key) then
		if data then
			func(data)
		else
			func()
		end
		return
	end
	self.welfare_tip_view:SetOKCallback(func)
	self.welfare_tip_view:SetNoCallback(no_func)
	self.welfare_tip_view:SetData(data, cancle_data, is_show_no_tip, is_show_time, prefs_key, is_recycle, recycle_text, auto_text_desc,hide_cancel, boss_id, no_auto_click_yes, no_button_text, cal_time, auto_click_no)
	self.welfare_tip_view:SetContent(content)
	self.welfare_tip_view:Open()
end

-------------------------------------------------
--福利通用物品格子管理器
function WelfareCtrl.CommonItemManager(self, func, mamanger_name, start_index)
	local cell_list = {}
	mamanger_name = mamanger_name or "ItemManager"
	start_index = start_index or 0

	local item_manager = self:FindObj(mamanger_name)
	local child_number = item_manager.transform.childCount
	local count = 1
	for i = start_index, child_number - 1 do
		cell_list[count] = func(item_manager.transform:GetChild(i).gameObject)
		count = count + 1
	end
	return cell_list
end