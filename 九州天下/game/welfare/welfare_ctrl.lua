require("game/welfare/welfare_data")
require("game/welfare/welfare_view")
require("game/welfare/offline_exp_view")
require("game/welfare/online_reward_view")

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

	WelfareCtrl.Instance = nil
end

function WelfareCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCWelfareInfo, "SyncWelfareInfo")
	self:RegisterProtocol(SCDailyFindItemChange, "SyncFindInfo")
end

function WelfareCtrl:SyncFindInfo(protocol)
	self.data:UpdateFindData(protocol)
	self:SetRedPoint()
	self.welfare_view:FlushFind()
end

function WelfareCtrl:SyncWelfareInfo(protocol)
	--离线奖励
	if protocol.offline_exp > 0 then
		MainUICtrl.Instance.view:Flush(MainUIViewChat.IconList.OFF_LINE, {true})
	else
		MainUICtrl.Instance.view:Flush(MainUIViewChat.IconList.OFF_LINE, {false})
	end
	--在线奖励
	if self.online_reward_view:IsOpen() then
		self.online_reward_view:Flush()
	end
	self.data:SetWelfareData(protocol)
	-- 屏蔽在线奖励
	-- MainUICtrl.Instance.view:Flush("on_line")
	
	RemindManager.Instance:Fire(RemindName.WelfareSign)
	RemindManager.Instance:Fire(RemindName.WelfareFind)
	RemindManager.Instance:Fire(RemindName.WelfareLevelReward)
	self.welfare_view:OnSeverDataChange()
	self.welfare_view:Flush("sign_in")

	MainUICtrl.Instance:OnChangeRewardItemByLevel()
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

--福利红点
function WelfareCtrl:SetRedPoint()
	self.welfare_view:SetRedPoint()
end

function WelfareCtrl:MainuiOpen()
	GlobalTimerQuest:AddDelayTimer(function()
		local off_line_exp = WelfareData.Instance:GetOffLineExp()
		if off_line_exp and off_line_exp > 0 then
			ViewManager.Instance:Open(ViewName.OffLineExp)
		end
	end, 0)
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