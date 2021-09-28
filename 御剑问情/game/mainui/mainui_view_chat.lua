MainUIViewChat = MainUIViewChat or BaseClass(BaseRender)

MainUIViewChat.ChannelType = {
	0,				-- 世界
	3,				-- 队伍
	4,				-- 公会
}

--主界面聊天小图标
MainUIViewChat.IconList = {
	MAIL_REC = "mail_rec",						--邮件通知
	FRIEND_REC = "friend_rec",					--好友请求
	JOIN_REQ = "join_req",						--入队申请
	TEAM_REQ = "team_req",						--组队邀请
	TRADE_REQ = "trade_req",					--交易请求
	WEEDING_GET_INVITE = "weeding_get_invite",	--婚宴列表
	GIFT_BTN = "gift_btn",						--送礼提醒
	HONGBAO = "hongbao",						--红包提醒
	SERVER_HONGBAO = "server_hongbao",			--全服红包提醒
	SOS_REQ = "sos_req",						--运镖求救信息
	GUILD_YAO = "guild_yao",					--公会邀请
	OFF_LINE = "off_line",						--离线经验
	LOVE_CONTENT = "love_content",				--爱情契约
	GUILD_GODDESS = "guild_goddess",			--公会女神祝福
	GUILD_INVITE = "guild_invite",				--公会邀请
	BAG_FULL = "bag_full",						--背包已满
	DisCount = "discount",						--特惠豪礼
	DisCountRed = "discount_red",				--特惠豪礼红点
	DisCountAni = "discount_ani",				--特惠豪礼动画
	GuildHongBao = "guild_hongbao",				--公会红包
	Congratulate = "Congratulate",				--好友祝贺
	MarryBlessing = "MarryBlessing",			--结婚祝贺
	GuildMemberFull = "GuildMemberFull",		--公会满员
	ChatButtons = "chat_buttons",
	GONGGAO_BTN="gonggao_btn",                  --公告提醒
	CRAZY_TREE = "crazy_rec",                   --疯狂摇钱树

}

local ChatCellHeight = {}
local ClosePopTime = 5							--关闭气泡框时间
local UILayer = GameObject.Find("GameRoot/UILayer")

function MainUIViewChat:__init()
	MainUIViewChat.Instance = self
	self.chat_data = {}
	self.pop_chat_data = {}
	self.cell_list = {}
	self.channel_state = 1
	self.curr_send_channel = 0
	self.chat_measuring = nil
	self.pop_channel_type = CHANNEL_TYPE.WORLD
	self.guild_invite_list = {}
	self.is_show_icon_tree = true
	-- 查找组件
	self.chat_list = self:FindObj("ChatList")
	self.pop_chat_list = self:FindObj("PopChatList")
	self.mail_btn = self:FindObj("MailButton")
	self.crazy_tree_btn = self:FindObj("CrazyTreeButton")
	self.friend_rec_btn = self:FindObj("FriendRecButton")
	self.team_req_btn = self:FindObj("TeamReqButton")
	self.join_req_btn = self:FindObj("ReqJoinButton")
	self.arraw_btn = self:FindObj("Arraw")
	self.trade_req_btn = self:FindVariable("ShowTradeButton")
	self.show_hongbao_btn = self:FindVariable("show_hongbao_btn")
	self.show_server_hongbao_btn = self:FindVariable("show_server_hongbao_btn")
	self.show_guildchat_pop = self:FindVariable("show_guildchat_pop")
	self.show_guildchat_redpt = self:FindVariable("show_guildchat_redpt")
	self.show_offline_btn = self:FindVariable("ShowOffLineBtn")
	self.show_lovecontent_btn = self:FindVariable("ShowLoveContentBtn")
	self.show_guild_goddess_btn = self:FindVariable("ShowGuildGoddess")
	self.show_bag_full_btn = self:FindVariable("ShowBagFullBtn")
	self.show_discount_btn = self:FindVariable("ShowDisCountBtn")
	-- self.show_guild_hongbao_btn = self:FindVariable("ShowGuildHongBaoBtn")
	self.show_discount_red = self:FindVariable("ShowDiscountRed")
	self.is_cross_server = self:FindVariable("IsCrossServer")
	self.show_congratulate_btn = self:FindVariable("ShowCongratulation")
	self.show_buttons = self:FindVariable("ShowChatButtons")
	self.show_discount_red:SetValue(true)
	self.show_marry_blessing = self:FindVariable("ShowMarryBlessing")
	self.show_member_full = self:FindVariable("ShowMemberFull")
	self.show_marry_gift = self:FindVariable("ShowMarryGift")
	self.show_buy_exp = self:FindVariable("ShowBuyExpBtn")
	self.show_kouling_hongbao = self:FindVariable("ShowKoulingHongbao")
	self.weeding_get_invite_btn = self:FindObj("WeedingGetInviteButton")
	self.weeding_get_invite_btn:SetActive(false)
	self.weeding_invite_btn = self:FindObj("WeedingInviteButton")
	self.chat_buttons = self:FindObj("ChatButtons")
	self.gift_button = self:FindObj("GiftButton")
	self.guild_apply_btn = self:FindObj("GuildApplyBtn")
	self.server_hongbao_btn = self:FindObj("ServerHongBao")
	self.left_down_mount_btn = self:FindObj("MountGuideBtn")
	self.top_button = self:FindObj("TopButton")
	self.top_button_animator = self.top_button.animator
	self.show_arraw_up = self:FindVariable("ShowArrawUp")
	self.wedding_remind = self:FindVariable("WeddingRemind")
	self.show_quick_speak = self:FindVariable("ShowQuickSpeak")
	self.show_mount_btn = self:FindVariable("ShowMountBtn")
	self.mount_state = self:FindVariable("MountState")
	self.show_horn = self:FindVariable("ShowHorn")
	self.chat_view = self:FindObj("ChatView")
	self.JingHuaHuSongTime = self:FindVariable("JingHuaHuSongTime")
	self.show_gonggao = self:FindVariable("ShowGongGaoBtn")
	self.show_gonggao:SetValue(true)
	self.activity_name = self:FindVariable("ActivityName")
	self.open_time = self:FindVariable("OpenTime")
	self.show_act_pre = self:FindVariable("ShowActPre")
	self.touzibutton = self:FindObj("TouZiButton")
	self.showtouzibutton = self:FindVariable("ShowTouZiButton")
	self.showtouziredpoint = self:FindVariable("ShowTouZiRedPoint")
	self.show_return_reward_icon = self:FindVariable("ShowReturnRechargeIcon")

	self.show_speaker = self:FindVariable("ShowSpeaker")

	--气泡框相关绑定
	self.show_pop_title = self:FindVariable("ShowPopTitle")
	self.show_pop_title:SetValue(true)
	self.pop_title_icon_res = self:FindVariable("PopTitleIconRes")
	self.pop_title_text = self:FindVariable("PopTitleText")
	self.pop_bg_res = self:FindVariable("PopBgRes")

	-- 根据平台配置显示聊天快捷
	local is_show_quick_speak = ChatData.Instance:SetNormalQuickSpeak()
	self.show_quick_speak:SetValue(is_show_quick_speak)

	--一折抢购
	local discount_btn = self:FindObj("DisCountBtn")
	self.discount_anictrl = discount_btn.animator

	self:BindGlobalEvent(MainUIEventType.CHAT_TOP_BUTTON_MOVE,
		BindTool.Bind(self.TopButtonMove, self))

	self.data_listen = BindTool.Bind(self.PlayerDataChangeCallback, self)
	PlayerData.Instance:ListenerAttrChange(self.data_listen)

	self.show_hu_song = self:FindVariable("ShowHuSong")
	self.show_Jing_Hua_hu_song = self:FindVariable("ShowJingHuaHuSong")
	self.hongbao_num_text = self:FindVariable("hongbao_num")
	self.server_hongbao_num_text = self:FindVariable("server_hongbao_num")
	self.show_hongbao_redpoint = self:FindVariable("ShowHongBaoRedPoint")
	self.show_server_hongbao_redpoint = self:FindVariable("ShowServerHongBaoRedPoint")
	self.chat_cd = self:FindVariable("ChatCD")

	-- 聊天list
	local list_delegate = self.chat_list.list_simple_delegate
	list_delegate.NumberOfCellsDel = function()
		return #self.chat_data
	end

	list_delegate.CellSizeDel = function(data_index)
		data_index = data_index + 1
		local chat_data = self.chat_data[data_index]
		local height = ChatCellHeight[chat_data.msg_id]
		if height then
			return height
		end
		if self.chat_measuring == nil then
			local cell = list_delegate:CreateCell()
			cell.transform:SetParent(UILayer.transform, false)
			cell.transform.localPosition = Vector3(9999, 0, 0)			--直接放在界面外
			GameObject.DontDestroyOnLoad(cell.gameObject)
			self.chat_measuring = MainUIChatCell.New(cell.gameObject)
		end
		self.chat_measuring:SetEasy(true)
		self.chat_measuring:SetData(chat_data)
		height = self.chat_measuring:GetContentHeight()
		ChatCellHeight[chat_data.msg_id] = height

		return height
	end

	list_delegate.CellRefreshDel = function(cell, data_index)
		local chat_cell = self.cell_list[cell]
		if chat_cell == nil then
			chat_cell = MainUIChatCell.New(cell.gameObject)
			chat_cell.main_chat_view = self
			self.cell_list[cell] = chat_cell
		end
		local chat_data = self.chat_data[data_index + 1]
		chat_cell:SetIndex(data_index + 1)
		chat_cell:SetData(chat_data)
	end

	-- 监听UI事件
	self:ListenEvent("OpenReturnRechargeView",
		BindTool.Bind(self.OpenReturnRechargeView, self))
	self:ListenEvent("OpenChat", BindTool.Bind(
		self.HandleOpenChat, self))
	self:ListenEvent("OpenMail", BindTool.Bind(
		self.HandleOpenMail, self))
	self:ListenEvent("ClickOpenCrazyTree", BindTool.Bind(
		self.ClickOpenCrazyTree, self))
	self:ListenEvent("OpenFriendReq", BindTool.Bind(
		self.ShowApplyView, self, APPLY_OPEN_TYPE.FRIEND))
	self:ListenEvent("OpenTeamReq", BindTool.Bind(
		self.ShowApplyView, self, APPLY_OPEN_TYPE.TEAM))
	self:ListenEvent("OpenJoinReq", BindTool.Bind(
		self.ShowApplyView, self, APPLY_OPEN_TYPE.JOIN))
	self:ListenEvent("OpenTradeTip", BindTool.Bind(
		self.HandleOpenTradeReqTips, self))
	self:ListenEvent("ChangeHeight", BindTool.Bind(
		self.HandleChangeHeight, self))
	self:ListenEvent("OnClickHu", BindTool.Bind(
		self.OnClickHu, self))
	self:ListenEvent("OnClickJiu", BindTool.Bind(
		self.OnClickJiu, self))
	self:ListenEvent("OnClickGo", BindTool.Bind(
		self.OnClickGo, self))
	self:ListenEvent("OnClickContinueJingHuaHuSong", BindTool.Bind(
		self.OnClickContinueJingHuaHuSong, self))											--继续护送精华
	self:ListenEvent("OnClickSpeakDown", BindTool.Bind(
		self.OnClickSpeakDown, self))
	self:ListenEvent("OnClickSpeakUp", BindTool.Bind(
		self.OnClickSpeakUp, self))
	self:ListenEvent("OpenGiftRecordView",
		BindTool.Bind(self.OpenGiftRecordView, self))
	self:ListenEvent("OpenGuildApply",
		BindTool.Bind(self.OpenGuildApply, self))
	self:ListenEvent("OpenHongBao",
		BindTool.Bind(self.OpenHongBao, self))
	self:ListenEvent("OpenGuildChat",
		BindTool.Bind(self.OpenGuildChat, self))
	self:ListenEvent("OpenGongGao",
		BindTool.Bind(self.OpenGongGaoView, self))
	self:ListenEvent("OpenOfflineView",
		BindTool.Bind(self.OpenOfflineView, self))
	self:ListenEvent("ClickLoveContent",
		BindTool.Bind(self.ClickLoveContent, self))
	self:ListenEvent("ClickGuildGoddess",
		BindTool.Bind(self.ClickGuildGoddess, self))
	self:ListenEvent("OpenBagRecyleView",
		BindTool.Bind(self.OpenBagRecyleView, self))
	self:ListenEvent("OpenDiscountView",
		BindTool.Bind(self.OpenDiscountView, self))
	self:ListenEvent("OpenServerHongBao",
		BindTool.Bind(self.OpenServerHongBao, self))
	self:ListenEvent("OpenGuildHongBao",
		BindTool.Bind(self.OpenGuildHongBao, self))
	self:ListenEvent("ClickMount",
		BindTool.Bind(self.ClickMount, self))
	self:ListenEvent("OnClickSetting",
		BindTool.Bind(self.OnClickSetting, self))
	self:ListenEvent("ClickPop",
		BindTool.Bind(self.OnClickPop, self))

	self:ListenEvent("OpenCongratulation",
		BindTool.Bind(self.OpenCongratulation, self))
	self:ListenEvent("OpenMarryBlessing",
		BindTool.Bind(self.OpenMarryBlessing, self))
	self:ListenEvent("ClickMemberFull",
		BindTool.Bind(self.ClickMemberFull, self))
	self:ListenEvent("OpenMarryGift",
		BindTool.Bind(self.OpenMarryGift, self))
	
	self:ListenEvent("OpenBuyExpView",
		BindTool.Bind(self.OpenBuyExpView,self))

	self:ListenEvent("OpenKoulingHongbao",
		BindTool.Bind(self.OpenKoulingHongbao, self))
	self:ListenEvent("ClickQuickChat",
		BindTool.Bind(self.ClickQuickChat, self))
	self:ListenEvent("ClickLaBa",
		BindTool.Bind(self.ClickLaBa, self))
	self:ListenEvent("OpenTouZiView",
		BindTool.Bind(self.OpenTouZiView, self))

	self.root_node.animator:ListenEvent("ToShort",
		BindTool.Bind(self.ToShortFinish, self))
	self.root_node.animator:ListenEvent("ToLength",
		BindTool.Bind(self.ToLengthFinish, self))

	self.root_node.animator:ListenEvent("StartToLength",
		BindTool.Bind(self.StartToLength, self))
	self.root_node.animator:ListenEvent("StartToShort",
		BindTool.Bind(self.StartToShort, self))
	self:ListenEvent("ClickAllActivityView", BindTool.Bind(self.AllActivityViewClick, self))
	self:ListenEvent("ClickActivityView", BindTool.Bind(self.ClickActivityView, self))
	self:BindGlobalEvent(MainUIEventType.NEW_CHAT_CHANGE, BindTool.Bind1(self.NewChatChange, self))
	self.weeding_get_invite_btn.button:AddClickListener(BindTool.Bind(
		self.HandleOpenWeedingGetInvite, self))
	self.weeding_invite_btn.button:AddClickListener(BindTool.Bind(
		self.HandleOpenWeedingInvite, self))
	self.time_pass_day_quest = GlobalEventSystem:Bind(OtherEventType.PASS_DAY, BindTool.Bind(self.FlushActivityPre, self))
	--监听右下角收缩按钮事件
	self:BindGlobalEvent(MainUIEventType.FIGHT_STATE_BUTTON, BindTool.Bind1(self.CheckFlushChatView, self))
	self.hongbao_num = 0

	-- 公会求救列表
	self.guild_sos_list = {}

	self.item_data_change_callback = BindTool.Bind(self.ItemCallBack, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_change_callback)
	self:ItemCallBack()
	self:BindGlobalEvent(LoginEventType.LOGIN_SERVER_CONNECTED, BindTool.Bind(self.OnConnectLoginServer, self))
	self:BindGlobalEvent(LoginEventType.CROSS_SERVER_CONNECTED, BindTool.Bind(self.OnConnectLoginServer, self))

	self.delay_refresh_chate_view_timer = nil
	self.delay_refresh_chat_view = BindTool.Bind(self.DelayRefreshChatView, self)

	--功能引导监听
	self.getui_callback = BindTool.Bind(self.GetUiCallBack, self)
	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.Main, self.getui_callback)

	-- iphoneX把聊天框抬高
	if UnityEngine.Application.platform == UnityEngine.RuntimePlatform.IPhonePlayer
		and UnityEngine.iOS.Device.generation == UnityEngine.iOS.DeviceGeneration.iPhoneX then

		local rect = self.chat_view.transform:GetComponent(typeof(UnityEngine.RectTransform))
		rect.anchoredPosition = Vector2(0, 20)
	end

	self:BindGlobalEvent(ObjectEventType.LEVEL_CHANGE, BindTool.Bind(self.TouZiInfo, self))
	self:BindGlobalEvent(ChatEventType.VOICE_SWITCH, BindTool.Bind(self.UpdateVoiceSwitch, self))
	self:OnFlushActPreviewTimer()
	self:SetActiveName()
	self:TouZiInfo()
	self:UpdateVoiceSwitch()
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	RemindManager.Instance:Bind(self.remind_change, RemindName.TeamFbFull)
	RemindManager.Instance:Bind(self.remind_change, RemindName.MarryGiftBack)
end

function MainUIViewChat:__delete()
	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUiByFun(ViewName.Main, self.getui_callback)
	end
	self.getui_callback = nil

	ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_change_callback)

	if nil ~= self.delay_refresh_chate_view_timer then
		GlobalTimerQuest:CancelQuest(self.delay_refresh_chate_view_timer)
		self.delay_refresh_chate_view_timer = nil
	end

	if self.act_preview_time_time_quest then
		GlobalTimerQuest:CancelQuest(self.act_preview_time_time_quest)
		self.act_preview_time_time_quest = nil
	end

	for _, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	if self.chat_measuring then
		GameObject.Destroy(self.chat_measuring.root_node.gameObject)
		self.chat_measuring:DeleteMe()
		self.chat_measuring = nil
	end

	ChatCellHeight = {}

	if self.pop_chat_quest then
		GlobalTimerQuest:CancelQuest(self.pop_chat_quest)
	end
	MainUIViewChat.Instance = nil

	PlayerData.Instance:UnlistenerAttrChange(self.data_listen)

	for k,v in pairs(self.guild_sos_list) do
		GameObject.Destroy(v.gameObject)
	end
	self.guild_sos_list = {}

	for k,v in pairs(self.guild_invite_list) do
		GameObject.Destroy(v.gameObject)
	end
	self.guild_invite_list = {}

	if self.time_pass_day_quest ~= nil then
		GlobalEventSystem:UnBind(self.time_pass_day_quest)
		self.time_pass_day_quest = nil
	end

	self.is_show_icon_tree = false

	self:StopDisCountAni()
	self:ClearChatCD()
	self:StopClosePopTimeQuest()

	if self.remind_change then
		RemindManager.Instance:UnBind(self.remind_change)
		self.remind_change = nil
	end

	self.show_return_reward_icon = nil
end

function MainUIViewChat:TopButtonMove(state)
	local posy = 17
	if state then
		posy = 77
	end
	self.top_button.rect.anchoredPosition = Vector2(0, posy)
end

function MainUIViewChat:ChangeWeddingRemind()
	if self.wedding_remind then
		local state = MarriageData.Instance:HaveGatherTimesInHunYanList()
		self.wedding_remind:SetValue(state)
	end
end

-- 登录服
function MainUIViewChat:OnConnectLoginServer()
	self.is_cross_server:SetValue(IS_ON_CROSSSERVER)
end

function MainUIViewChat:ShowGuildChatRedPt(is_show)
	self.show_guildchat_redpt:SetValue(is_show)
end

function MainUIViewChat:OnEnterScene()
	if self.chat_measuring then
		GameObject.Destroy(self.chat_measuring.root_node.gameObject)
		self.chat_measuring:DeleteMe()
		self.chat_measuring = nil
	end
end

function MainUIViewChat:HandleChangeHeight()
	local bool = self.root_node.animator:GetBool("changeheight")
	-- self.show_arraw_up:SetValue(bool)
	self.root_node.animator:SetBool("changeheight", not bool)
end

--开始把聊天框变长
function MainUIViewChat:StartToLength()
	GlobalEventSystem:Fire(MainUIEventType.CHAT_VIEW_HIGHT_CHANGE, "to_length")
end

--开始把聊天框变短
function MainUIViewChat:StartToShort()
	GlobalEventSystem:Fire(MainUIEventType.CHAT_VIEW_HIGHT_CHANGE, "to_short")
end

function MainUIViewChat:ToShortFinish(param)
	if param == "1" then
		local state = MainUIData.Instance:GetChatViewState()
		if state ~= MainUIData.ChatViewState.Short then
			MainUIData.Instance:SetChatViewState(MainUIData.ChatViewState.Short)
			self:FulshChatView()
		end
	end
end

function MainUIViewChat:ToLengthFinish(param)
	if param == "1" then
		local state = MainUIData.Instance:GetChatViewState()
		if state ~= MainUIData.ChatViewState.Length then
			MainUIData.Instance:SetChatViewState(MainUIData.ChatViewState.Length)
			self:FulshChatView()
		end
	end
end

function MainUIViewChat:CheckFlushChatView(state)
	if not state then
		GlobalTimerQuest:AddDelayTimer(function()
			self:FulshChatView()
		end, 0)
	end
end

function MainUIViewChat:HandleOpenChat()
	ViewManager.Instance:Open(ViewName.Chat, TabIndex.chat_world)
end

function MainUIViewChat:HandleOpenTradeReqTips()
	local role_info = TradeData.Instance:GetSendTradeRoleInfo()
	local content = string.format(Language.Trade.TradeTipContent, role_info.req_name)
	local func = function ()
		TradeCtrl.Instance:SendTradeStateReq(1, role_info.req_uid)
	end
	local no_func = function ()
		TradeCtrl.Instance:SendTradeStateReq(0, role_info.req_uid)
	end
	TipsCtrl.Instance:ShowCommonTip(func, nil, content, nil, no_func, false)
	self:SetTradeReqVisible(false)
end

function MainUIViewChat:HandleOpenMail()
	if IS_ON_CROSSSERVER then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.OnCrossServerTip)
		return
	end
	ViewManager.Instance:Open(ViewName.Scoiety, TabIndex.society_mail)
end

function MainUIViewChat:ClickOpenCrazyTree()
	ViewManager.Instance:Open(ViewName.CrazyMoneyTreeView)
	if self.crazy_tree_btn then
		self.crazy_tree_btn:SetActive(false)
		self.is_show_icon_tree = false
	end
end

function MainUIViewChat:OpenGuildApply()
	ViewManager.Instance:Open(ViewName.GuildApply)
end

function MainUIViewChat:OpenHongBao()
	HongBaoCtrl.Instance:RecHongBao(HongBaoData.Instance:GetCurHongBaoIdList()[1].id)
end

function MainUIViewChat:OpenGuildChat()
	local privateobj_list = ChatData.Instance:GetPrivateObjList()
	local team_list = ScoietyData.Instance:GetMemberList()
	local friend_list = ScoietyData.Instance:GetFriendInfo()
	local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id

	--没公会也没有私聊对象
	if (guild_id <= 0 and #privateobj_list <= 0) and #team_list <= 0 then
		--判断是否有好友
		if #friend_list <= 0 then
			ViewManager.Instance:Open(ViewName.Guild)
			return
		else
			local friend_info = friend_list[1]
			local private_obj = ChatData.CreatePrivateObj()
			private_obj = ChatData.CreatePrivateObj()
			private_obj.role_id = friend_info.user_id
			private_obj.username = friend_info.gamename
			private_obj.sex = friend_info.sex
			private_obj.camp = friend_info.camp
			private_obj.prof = friend_info.prof
			private_obj.avatar_key_small = friend_info.avatar_key_small
			private_obj.level = friend_info.level
			ChatData.Instance:AddPrivateObj(friend_info.user_id, private_obj)
			ChatData.Instance:SetCurrentId(friend_info.user_id)
		end
	end
	ViewManager.Instance:Open(ViewName.ChatGuild)
end

function MainUIViewChat:OpenOfflineView()
	ViewManager.Instance:Open(ViewName.OffLineExp)
end

--爱情契约
function MainUIViewChat:ClickLoveContent()
	-- local function ok_callback()
	-- 	ViewManager.Instance:Open(ViewName.Marriage, TabIndex.marriage_honeymoon)
	-- 	ViewManager.Instance:Open(ViewName.LoveContract)
	-- end
	-- local can_receive_day_num = MarriageData.Instance:GetQingyuanLoveContractInfo().can_receive_day_num + 1		-- 服务器天数从0开始 所以在这客户端显示要+1
	-- local des = string.format(Language.Marriage.ContentMianTips, can_receive_day_num)
	-- local yes_des = Language.Common.LingQuJiangLi
	-- local canel_des = Language.Common.AfterLater
	-- TipsCtrl.Instance:ShowCommonAutoView("", des, ok_callback, nil, nil, yes_des, canel_des)
	ViewManager.Instance:Open(ViewName.LoveContractFrame, nil, "Receive")
end

--公会女神祝福
function MainUIViewChat:ClickGuildGoddess()
	local function ok_callback()
		GuildBonfireCtrl.SendGuildBonfireGotoReq()
		self.show_guild_goddess_btn:SetValue(false)
	end
	local des = Language.Guild.GoToGuildBonfire
	TipsCtrl.Instance:ShowCommonAutoView("", des, ok_callback)
end

function MainUIViewChat:OpenBagRecyleView()
	ViewManager.Instance:Open(ViewName.Player, TabIndex.role_bag)
	PlayerCtrl.Instance.view:Flush("bag_recycle")
end

function MainUIViewChat:SetDiscountRed(state)
	if self.show_discount_red then
		self.show_discount_red:SetValue(state)
	end
end

--打开特惠豪礼界面
function MainUIViewChat:OpenDiscountView()
	local have_new_discount, new_phase_index = DisCountData.Instance:GetHaveNewDiscount()
	if have_new_discount then
		DisCountCtrl.Instance:JumpToViewIndex(new_phase_index)
		ViewManager.Instance:Open(ViewName.DisCount, nil, "index", {new_phase_index})
	else
		DisCountCtrl.Instance:JumpToViewIndex(1)
		ViewManager.Instance:Open(ViewName.DisCount, nil, "index", {1})
	end
end

function MainUIViewChat:OpenServerHongBao()
	HongBaoCtrl.Instance:RecHongBao(HongBaoData.Instance:GetCurServerHongBaoIdList()[1].id)
end

function MainUIViewChat:OpenCongratulation()
	-- body
	self:SetShowCongratulateBtn(false)
	ViewManager.Instance:Open(ViewName.CongratulationView)
end

function MainUIViewChat:OpenGuildHongBao()
	ViewManager.Instance:Open(ViewName.GuildRedPacket)
end

function MainUIViewChat:OnClickSetting()
	ViewManager.Instance:Open(ViewName.Setting, TabIndex.setting_xianshi)
end

function MainUIViewChat:ClickMount()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local mount_appeid = main_role_vo.mount_appeid
	local fight_mount_appeid = main_role_vo.fight_mount_appeid
	local multi_mount_res_id = main_role_vo.multi_mount_res_id

	if fight_mount_appeid > 0 then
		--先下战斗坐骑
		FightMountCtrl.Instance:SendGoonFightMountReq(0)
	end

	--优先处理双人坐骑
	if multi_mount_res_id > 0 then
		MountCtrl.Instance:SendGoonMountReq(0)
		return
	end

	if mount_appeid > 0 then
		MountCtrl.Instance:SendGoonMountReq(0)
	else
		MountCtrl.Instance:SendGoonMountReq(1)
	end
end

function MainUIViewChat:FlushMountState()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local mount_appeid = main_role_vo.mount_appeid

	self.mount_state:SetValue(mount_appeid <= 0)
end

function MainUIViewChat:CheckShowMountBtn()
	local value = self.show_mount_btn:GetBoolean()
	if value then
		return
	end
	local is_open = OpenFunData.Instance:CheckIsHide("mount_jinjie")
	self.show_mount_btn:SetValue(is_open)
end

function MainUIViewChat:ShowOffLineBtn(enable)
	self.show_offline_btn:SetValue(enable)
end

function MainUIViewChat:ShowLoveContentBtn(enable)
	self.show_lovecontent_btn:SetValue(enable)
end

function MainUIViewChat:SetDisCountTrigger()
	if self.discount_anictrl then
		--self.discount_anictrl:SetTrigger("shake")
	end
end

function MainUIViewChat:StartDisCountAni()
	self:SetDisCountTrigger()
	self:StopDisCountAni()
	self.discount_ani_time_quest = GlobalTimerQuest:AddRunQuest(function()
		self:SetDisCountTrigger()
	end, 600)
end

function MainUIViewChat:StopDisCountAni()
	if self.discount_ani_time_quest then
		GlobalTimerQuest:CancelQuest(self.discount_ani_time_quest)
		self.discount_ani_time_quest = nil
	end
end

function MainUIViewChat:SetShowCongratulateBtn(enable)
	-- body
	self.show_congratulate_btn:SetValue(enable)
end

function MainUIViewChat:ShowDisCountBtn(enable)
	if IS_AUDIT_VERSION then
		enable = false
	end
	self.show_discount_btn:SetValue(enable)
	if enable then
		self:StartDisCountAni()
	else
		self:StopDisCountAni()
	end
end

function MainUIViewChat:ShowApplyView(open_type)
	ScoietyCtrl.Instance:ShowApplyView(open_type)
end

function MainUIViewChat:HandleOpenWeedingGetInvite()
	ViewManager.Instance:Open(ViewName.WeddingEnterView)
end

function MainUIViewChat:HandleOpenWeedingInvite()
	-- ViewManager.Instance:Open(ViewName.WeddingInviteView)
end

function MainUIViewChat:FlushHongBaoNumValue()
	local count = #HongBaoData.Instance:GetCurHongBaoIdList()
	if count > 0 then
		self.hongbao_num_text:SetValue(count)
		if count >= 2 then
			self.show_hongbao_redpoint:SetValue(true)
		else
			self.show_hongbao_redpoint:SetValue(false)
		end
	else
		self.show_hongbao_btn:SetValue(false)
	end
end

function MainUIViewChat:CreateHongBao(id, type)
	self.show_hongbao_btn:SetValue(true)
	HongBaoData.Instance:SetCurHongBaoIdList(id, type)
	self:FlushHongBaoNumValue()
end

function MainUIViewChat:FlushServerHongBaoNumValue()
	local num_text = ""
	local count = #HongBaoData.Instance:GetCurServerHongBaoIdList()
	if count ~= 0 then
		-- if count == 1 then
		-- 	num_text = ""
		-- else
			num_text = tostring(count)
		-- end
		self.server_hongbao_num_text:SetValue(num_text)
		-- if count >= 2 then
			self.show_server_hongbao_redpoint:SetValue(true)
		-- else
		-- 	self.show_server_hongbao_redpoint:SetValue(false)
		-- end
	else
		self.show_server_hongbao_btn:SetValue(false)
	end
end

function MainUIViewChat:CreateServerHongBao(id, type)
	self.show_server_hongbao_btn:SetValue(true)
	self.server_hongbao_btn.animator:SetBool("Shake", true)
	HongBaoData.Instance:SetoveCurServerHongBaoIdList(id, type)
	self:FlushServerHongBaoNumValue()
end

function MainUIViewChat:CreateSos(info)
	PrefabPool.Instance:Load(AssetID("uis/views/main_prefab", "ButtonJiu"), function(prefab)
		if prefab then
			local obj = GameObject.Instantiate(prefab)
			PrefabPool.Instance:Free(prefab)

			if self.guild_sos_list[info.member_uid] then
				GameObject.Destroy(self.guild_sos_list[info.member_uid].gameObject)
				self.guild_sos_list[info.member_uid] = nil
			end
			self.guild_sos_list[info.member_uid] = obj
			obj:GetComponent(typeof(UnityEngine.UI.Button)):AddClickListener(function ()
				GameObject.Destroy(obj.gameObject)
				self.guild_sos_list[info.member_uid] = nil
				GuildCtrl.Instance:OnClickSos(info)
			end)
			local transform = obj.transform
			transform:SetParent(self.chat_buttons.transform, false)
		end
	end)
end

function MainUIViewChat:CreateGuildInvite(info)
	PrefabPool.Instance:Load(AssetID("uis/views/main_prefab", "ButtonInvite"), function(prefab)
		if prefab then
			local obj = GameObject.Instantiate(prefab)
			PrefabPool.Instance:Free(prefab)
			if self.guild_invite_list[info.guild_id] then
				GameObject.Destroy(self.guild_invite_list[info.guild_id].gameObject)
				self.guild_invite_list[info.guild_id] = nil
			end
			self.guild_invite_list[info.guild_id] = obj
			obj:GetComponent(typeof(UnityEngine.UI.Button)):AddClickListener(function ()
				GameObject.Destroy(obj.gameObject)
				self.guild_invite_list[info.guild_id] = nil
				local content = string.format(Language.Guild.GUILDINVITE, info.invite_name, info.guild_name)
				local yes_func = function ()
					GuildCtrl.Instance:OnInviteGuildAck(info.guild_id, info.invite_uid, 0)
				end
				local no_func = function ()
					GuildCtrl.Instance:OnInviteGuildAck(info.guild_id, info.invite_uid, 1)
				end
				TipsCtrl.Instance:ShowCommonAutoView("", content, yes_func, no_func, false, Language.Guild.TONGYI, Language.Guild.JUJUE)
			end)
			local transform = obj.transform
			transform:SetParent(self.chat_buttons.transform, false)
		end
	end)
end

function MainUIViewChat:SetGuildGoddessVisible(state)
	if self.show_guild_goddess_btn then
		self.show_guild_goddess_btn:SetValue(state or false)
	end
end

function MainUIViewChat:SetMailRecVisible(value)
	if self.mail_btn then
		self.mail_btn:SetActive(value)
	end
end

function MainUIViewChat:SetCrazyTreeRecVisible(value)
	local gold = CrazyMoneyTreeData.Instance:GetMoney() or 0
	local max_chongzhi_num = CrazyMoneyTreeData.Instance:GetMaxChongZhiNum() or 0
	if self.crazy_tree_btn and self.is_show_icon_tree then
		self.crazy_tree_btn:SetActive(value and (gold < max_chongzhi_num))
	end
end

function MainUIViewChat:SetGiftBtnVisible(value)
	if self.gift_button then
		self.gift_button:SetActive(value)
	end
end

function MainUIViewChat:SetGongGaoBtnVisible(value)   --设置公告button的显示
	self.show_gonggao:SetValue(value)
end

function MainUIViewChat:SetFriendRecVisible(value)
	if self.friend_rec_btn then
		self.friend_rec_btn:SetActive(value)
	end
end

function MainUIViewChat:SetTeamReqVisible(value)
	if self.team_req_btn then
		self.team_req_btn:SetActive(value)
	end
end

function MainUIViewChat:SetJoinReqVisible(value)
	if self.join_req_btn then
		self.join_req_btn:SetActive(value)
	end
end

function MainUIViewChat:SetGuildApplyVisible(value)
	if self.guild_apply_btn then
		self.guild_apply_btn:SetActive(value)
	end
end

function MainUIViewChat:SetTradeReqVisible(value)
	if self.trade_req_btn then
		self.trade_req_btn:SetValue(value)
	end
end

function MainUIViewChat:SetWeedingGetInbiteVisible(value)
	-- if self.weeding_get_invite_btn then
	-- 	self.weeding_get_invite_btn:SetActive(value)
	-- end
end

function MainUIViewChat:SetFeastVisible(value)
	if self.feast_btn then
		self.feast_btn:SetActive(value)
	end
end

function MainUIViewChat:SetBagFullVisible(value)
	if self.show_bag_full_btn then
		self.show_bag_full_btn:SetValue(value)
	end
end


-- function MainUIViewChat:SetGuildHongBaoVisible(value)
-- 	if self.show_guild_hongbao_btn then
-- 		self.show_guild_hongbao_btn:SetValue(value)
-- 	end
-- end

function MainUIViewChat:SetChatButtonsVisible(vis_value)
	if self.chat_buttons and self.show_buttons then
		self.show_buttons:SetValue(vis_value)
	end
end

function MainUIViewChat:OnClickPop()
	if self.pop_channel_type == CHANNEL_TYPE.WORLD_QUESTION then
		--打开世界答题界面
		ViewManager.Instance:Open(ViewName.Chat, TabIndex.chat_question)
	elseif self.pop_channel_type == CHANNEL_TYPE.GUILD_QUESTION then
		local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
		if guild_id <= 0 then
			--已被踢出仙盟
			SysMsgCtrl.Instance:ErrorRemind(Language.Guild.BeKickOutGuild)
			return
		end

		--打开仙盟答题界面
		ChatData.Instance:SetCurrentId(SPECIAL_CHAT_ID.GUILD)
		ViewManager.Instance:Open(ViewName.ChatGuild)
		ViewManager.Instance:FlushView(ViewName.ChatGuild, "force_new_chat", {CHANNEL_TYPE.GUILD_QUESTION, SPECIAL_CHAT_ID.GUILD})
	elseif self.pop_channel_type == CHANNEL_TYPE.GUILD then
		--打开仙盟聊天界面
		ChatData.Instance:SetCurrentId(SPECIAL_CHAT_ID.GUILD)
		ViewManager.Instance:Open(ViewName.ChatGuild)
		ViewManager.Instance:FlushView(ViewName.ChatGuild, "force_new_chat", {CHANNEL_TYPE.GUILD, SPECIAL_CHAT_ID.GUILD})
	elseif self.pop_channel_type == CHANNEL_TYPE.TEAM then
		local team_state = ScoietyData.Instance:GetTeamState()
		if not team_state then
			--已被踢出队伍
			SysMsgCtrl.Instance:ErrorRemind(Language.CrossTeam.BeKickOut)
			return
		end

		--打开队伍聊天界面
		ChatData.Instance:SetCurrentId(SPECIAL_CHAT_ID.TEAM)
		ViewManager.Instance:Open(ViewName.ChatGuild)
		ViewManager.Instance:FlushView(ViewName.ChatGuild, "force_new_chat", {CHANNEL_TYPE.TEAM, SPECIAL_CHAT_ID.TEAM})
	end
end

-- 喇叭开启
function MainUIViewChat:OpenLevelLimitHorn()
	local level = PlayerData.Instance:GetRoleLevel()
	local horn_limit_level = ChatData.Instance:GetChatOpenLevelLimit(CHAT_OPENLEVEL_LIMIT_TYPE.SPEAKER)
	if horn_limit_level and self.show_horn then
		self.show_horn:SetValue(level >= horn_limit_level)
	end
end

--改变气泡框
function MainUIViewChat:ChangePop(msg_info)

	self:StartClosePopTimeQuest()
	self.show_guildchat_pop:SetValue(true)

	local channel_type = msg_info.channel_type
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	if main_vo.role_id ~= msg_info.from_uid and channel_type ~= CHANNEL_TYPE.WORLD_QUESTION and channel_type ~= CHANNEL_TYPE.GUILD_QUESTION then
		ViewManager.Instance:FlushView(ViewName.Main, "GuildShake", {true})
	end

	--设置气泡图标
	local title_res_bundle, title_res_asset = ResPath.GetMainUI("pop_icon_guild")
	if channel_type == CHANNEL_TYPE.WORLD_QUESTION then
		title_res_bundle, title_res_asset = ResPath.GetMainUI("pop_icon_world")
	end
	self.pop_title_icon_res:SetAsset(title_res_bundle, title_res_asset)

	--设置底图
	local pop_bg_res_bundle, pop_bg_res_asset = ResPath.GetMainUI("pop_msg_bg_blue")
	if channel_type == CHANNEL_TYPE.WORLD_QUESTION then
		pop_bg_res_bundle, pop_bg_res_asset = ResPath.GetMainUI("pop_msg_bg_red")
	end
	self.pop_bg_res:SetAsset(pop_bg_res_bundle, pop_bg_res_asset)

	self:FlushPopChatContent(msg_info)
end

--停止关闭聊天气泡倒计时
function MainUIViewChat:StopClosePopTimeQuest()
	if self.close_pop_time_quest then
		GlobalTimerQuest:CancelQuest(self.close_pop_time_quest)
		self.close_pop_time_quest = nil
	end
end

--开始关闭聊天气泡倒计时
function MainUIViewChat:StartClosePopTimeQuest()
	self:StopClosePopTimeQuest()
	self.close_pop_time_quest = GlobalTimerQuest:AddDelayTimer(function()
		self.show_guildchat_pop:SetValue(false)
	end, ClosePopTime)
end

function MainUIViewChat:FlushPopChatContent(msg_info)
	local rich_text = self.pop_chat_list:GetComponent(typeof(RichTextGroup))

	self:SetContent(rich_text, msg_info)
end

function MainUIViewChat:SetContent(rich_text, msg_info)
	local color = ""
	if msg_info and msg_info.tuhaojin_color and msg_info.tuhaojin_color > 0 then
		color = COLOR.GOLD
	else
		color = COLOR.WHITE
	end
	local content = msg_info.content or ""
	if msg_info.content_type == CHAT_CONTENT_TYPE.AUDIO then
		content = string.format(Language.Chat.Audio, msg_info.username or "")
	end
	if msg_info.from_uid > 0 then
		local name_str = string.format("{wordcolor;ffff00;%s}", msg_info.username)
		content = name_str .. ": " .. content
	end
	local msg = self:GetCutPopChatStr(content)
	RichTextUtil.ParseRichText(rich_text, msg, nil, color)
end

function MainUIViewChat:GetCutPopChatStr(content)
	-- 字符串分段
	local i, j = 0, 0
	local element_list = {}
	local last_pos = 1
	for loop_count = 1, 100 do
		i, j = string.find(content, "({.-})", j + 1)-- 匹配规则{face;20} {item;26000}
		if nil == i or nil == j then
			if last_pos <= #content then
				table.insert(element_list, {0, string.sub(content, last_pos, -1)})
			end
			break
		else
			if 1 ~= i and last_pos ~= i then
				table.insert(element_list, {0, string.sub(content, last_pos, i - 1)})
			end
			table.insert(element_list, {1, string.sub(content, i, j)})
			last_pos = j + 1
		end
	end

	-- 统计表情、字符等数量
	local all_length = 0
	local rest_length = 0
	local msg = ""
	local max_length = 15
	for i=1,#element_list do
		if element_list[i][1] == 1 then
			if string.find(element_list[i][2], "face") ~= nil then
				-- 表情按2个字符算
				all_length = all_length + 2
				if all_length > max_length then
					msg = msg.."..."
					return msg
				else
					msg = msg..ChatData.Instance:SubStringUTF8(element_list[i][2],1,-1)
				end
			else
				-- 坐标等按8个字符算
				all_length = all_length + 8
				if all_length > max_length then
					msg = msg.."..."
					return msg
				else
					msg = msg..ChatData.Instance:SubStringUTF8(element_list[i][2],1,-1)
				end
			end
		else
			rest_length = max_length - all_length
			all_length = all_length + string.utf8len(element_list[i][2])
			if all_length > max_length then
				msg = msg..ChatData.Instance:SubStringUTF8(element_list[i][2],1,rest_length)
				msg = msg.."..."
				return msg
			else
				msg = msg..ChatData.Instance:SubStringUTF8(element_list[i][2],1,-1)
			end
		end
	end

	return msg
end

--新增聊天消息
function MainUIViewChat:NewChatChange(msg_info)
	local channel_type = msg_info.channel_type
	if channel_type == CHANNEL_TYPE.TEAM or channel_type == CHANNEL_TYPE.GUILD or channel_type == CHANNEL_TYPE.WORLD_QUESTION or channel_type == CHANNEL_TYPE.GUILD_QUESTION then
		if channel_type == CHANNEL_TYPE.TEAM then
			self:FulshChatView()
		end
		self.pop_channel_type = channel_type
		self:ChangePop(msg_info)

	else
		self:FulshChatView()
	end
end

function MainUIViewChat:FulshChatView()
	if nil ~= self.delay_refresh_chate_view_timer then
		return
	end

	self.delay_refresh_chate_view_timer = GlobalTimerQuest:AddDelayTimer(self.delay_refresh_chat_view, 0.2)
end

function MainUIViewChat:DelayRefreshChatView()
	self.delay_refresh_chate_view_timer = nil

	if not self.chat_list.scroller.isActiveAndEnabled then
		return
	end

	local channel_list = ChatData.Instance:GetChannel(CHANNEL_TYPE.MAINUI)
	local msg_list = channel_list.msg_list or {}
	local count = 0
	local max_count = 3

	local state = MainUIData.Instance:GetChatViewState()
	if state == MainUIData.ChatViewState.Short then
		max_count = 3
	else
		max_count = 6
	end

	self.chat_data = {}
	for i = #msg_list, 1, -1 do
		if count >= max_count then
			break
		end
		table.insert(self.chat_data, 1, msg_list[i])
		count = count + 1
	end
	self.chat_list.scroller:ReloadData(1)
end

function MainUIViewChat:OnClickHu()
	YunbiaoCtrl.Instance:SendHuSongAddShieldReq()
end

function MainUIViewChat:OnClickJiu()
	YunbiaoCtrl.Instance:QiuJiuHandler()
end

--继续护送任务
function MainUIViewChat:OnClickGo()
	 MainUIView.Instance.task_view:ClickGo()
end

--继续护送精华
function MainUIViewChat:OnClickContinueJingHuaHuSong()
	 JingHuaHuSongCtrl.Instance:ContinueJingHuaHuSong()
end

function MainUIViewChat:SetJingHuaHuSongTime(time)
	self.JingHuaHuSongTime:SetValue(time)
end

function MainUIViewChat:OnClickSpeakDown()
	local function start_voice()
		if self.channel_state > 3 then
			self.channel_state = 1
		end
		local curr_send_channel = MainUIViewChat.ChannelType[self.channel_state]
		local main_vo = GameVoManager.Instance:GetMainRoleVo()
		if curr_send_channel == CHANNEL_TYPE.WORLD then
			if not ChatData.Instance:GetChannelCdIsEnd(curr_send_channel) then
				local time = ChatData.Instance:GetChannelCdEndTime(curr_send_channel) - Status.NowTime
				SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Chat.CanNotChat, math.ceil(time)))
				return
			end

			local level = main_vo.level

			if not ChatData.Instance:IsCanChat(CHAT_OPENLEVEL_LIMIT_TYPE.WORLD) then
				return
			end

			--设置世界聊天冷却时间
			ChatData.Instance:SetChannelCdEndTime(curr_send_channel)
		elseif curr_send_channel == CHANNEL_TYPE.TEAM then
			--是否组队
			if not ScoietyData.Instance:GetTeamState() then
				SysMsgCtrl.Instance:ErrorRemind(Language.Society.CreateTeam)
				return
			end
		elseif curr_send_channel == CHANNEL_TYPE.GUILD then
			if main_vo.guild_id <= 0 then
				SysMsgCtrl.Instance:ErrorRemind(Language.Guild.NotEnterGuild)
				return
			end
		else
			print_error("HandleChangeChannel with unknow index:", curr_send_channel)
			return
		end
		AutoVoiceCtrl.Instance:ShowVoiceView(curr_send_channel)
	end
	GlobalTimerQuest:AddDelayTimer(start_voice, 0)
end

function MainUIViewChat:OpenGiftRecordView()
	self:SetGiftBtnVisible(false)
	ScoietyCtrl.Instance:ShowFriendRecordView()
end

function MainUIViewChat:OpenGongGaoView()    --打开公告面板
	ViewManager.Instance:Open(ViewName.TipsGongGaoView)
end

function MainUIViewChat:OnClickSpeakUp()
	if AutoVoiceCtrl.Instance.view:IsOpen() then
		AutoVoiceCtrl.Instance.view:Close()
	end
end

function MainUIViewChat:ShowHuSong(switch)
	if SceneType.Common == Scene.Instance:GetSceneType() then  -- 护送引导副本不应出现
		self.show_hu_song:SetValue(switch)
	end
end

--显示或隐藏精华护送按钮
function MainUIViewChat:ShowJingHuaHuSong(switch)
	self.show_Jing_Hua_hu_song:SetValue(switch)
end

function MainUIViewChat:PlayerDataChangeCallback(attr_name, value, old_value)
	if attr_name == "guild_id" then
		if value ~= old_value then
			for k,v in pairs(self.guild_invite_list) do
				GameObject.Destroy(v.gameObject)
			end
			self.guild_invite_list = {}
		end
	elseif attr_name == "level" then
		if value ~= old_value then
			self:FlushKoulingHongbao()
			-- self:OpenLevelLimitHorn()
		end
	end
end

function MainUIViewChat:ItemCallBack()
	local empty_num = ItemData.Instance:GetEmptyNum()
	MainUICtrl.Instance:ChangeMainUiChatIconList(string.lower(ViewName.Player), MainUIViewChat.IconList.BAG_FULL, 0 == empty_num)
end

function MainUIViewChat:ShowMarryBlessing(state)
	if self.show_marry_blessing then
		self.show_marry_blessing:SetValue(state or false)
	end
end

function MainUIViewChat:OpenMarryBlessing()
	ViewManager.Instance:Open(ViewName.MarryBlessingView)
	self:ShowMarryBlessing(false)
end

function MainUIViewChat:ShowGuildMemberFull(state)
	if self.show_member_full then
		self.show_member_full:SetValue(state or false)
	end
end

function MainUIViewChat:ClickMemberFull()
	GuildCtrl.Instance:CleanFullMember()
	self.show_member_full:SetValue(false)
end

function MainUIViewChat:OpenMarryGift()
	MarryGiftCtrl.Instance:OpenBackGiftView()
	self.show_marry_gift:SetValue(false)
end

function MainUIViewChat:OpenBuyExpView()
	ViewManager.Instance:Open(ViewName.BuyExp)
end

function MainUIViewChat:ShowBuyExpButton()
	local is_show_btn = BuyExpData.Instance:GetExpRefineIsOpen()
	self.show_buy_exp:SetValue(is_show_btn)
end

local kouling_hongbao_info = nil
function MainUIViewChat:FlushKoulingHongbao()
	local level = GameVoManager.Instance:GetMainRoleVo().level
	--等级限制
	if not ChatData.Instance:IsCanChat(CHAT_OPENLEVEL_LIMIT_TYPE.WORLD, true) then
		self.show_kouling_hongbao:SetValue(false)
	else
		kouling_hongbao_info = HongBaoData.Instance:GetOneKoulingRedPaper()
		self.show_kouling_hongbao:SetValue(kouling_hongbao_info ~= nil)
	end
end

function MainUIViewChat:OpenKoulingHongbao()
	if kouling_hongbao_info then
		HongBaoCtrl.Instance:SendCommandRedPaperCheckInfo(kouling_hongbao_info.id)
		HongBaoData.Instance:RemoveKoulingRedPaper(kouling_hongbao_info.id)
		self:FlushKoulingHongbao()
	else
		self:FlushKoulingHongbao()
	end
end

function MainUIViewChat:ClickQuickChat()
	if not ChatData.Instance:GetChannelCdIsEnd(CHANNEL_TYPE.WORLD) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Chat.WorldChatCD)
		return
	end
	local function callback(str)
		local level = GameVoManager.Instance:GetMainRoleVo().level

		if not ChatData.Instance:IsCanChat(CHAT_OPENLEVEL_LIMIT_TYPE.WORLD) then
			return
		end
		--设置世界聊天冷却时间
		ChatData.Instance:SetChannelCdEndTime(CHANNEL_TYPE.WORLD)
		ChatCtrl.SendChannelChat(CHANNEL_TYPE.WORLD, str, CHAT_CONTENT_TYPE.TEXT)
		self:UpdateChatCD()
	end
	ChatCtrl.Instance:OpenQuickChatView(QUICK_CHAT_TYPE.NORMAL, callback)
end

function MainUIViewChat:UpdateChatCD()
	self:ClearChatCD()
	local function timer_func(elapse_time, total_time)
		if elapse_time >= total_time then
			self:ClearChatCD()
			self.chat_cd:SetValue("")
			return
		end
		self.chat_cd:SetValue(math.ceil(total_time - elapse_time))
	end
	local time = ChatData.Instance:GetChannelCdEndTime(CHANNEL_TYPE.WORLD) - Status.NowTime
	time = math.ceil(time)
	self.chat_cd:SetValue(time)
	self.chat_cd_count_down = CountDown.Instance:AddCountDown(time, 1, timer_func)
end

function MainUIViewChat:ClearChatCD()
	if self.chat_cd_count_down then
		CountDown.Instance:RemoveCountDown(self.chat_cd_count_down)
		self.chat_cd_count_down = nil
	end
end

function MainUIViewChat:ClickLaBa()
	TipsCtrl.Instance:ShowSpeakerView()
end

function MainUIViewChat:OpenTouZiView()
	self.showtouzibutton:SetValue(false)
	ViewManager.Instance:Open(ViewName.KaifuActivityView, TEMP_ADD_ACT_TYPE.TOUZI_PLAN_ACTIVITY_TYPE + 100000)
end

function MainUIViewChat:GetUiCallBack(ui_name, ui_param)
	if self[ui_name] and self[ui_name].gameObject.activeInHierarchy then
		return self[ui_name]
	end
end

function MainUIViewChat:AllActivityViewClick()
	MainUIView.Instance:OpenActivityPreview()
end

function MainUIViewChat:ClickActivityView()
	local cfg = ActivityData.Instance:GetCurActOpenInfo()
	if not cfg then
		cfg = ActivityData.Instance:GetNextActOpenInfo()
	end
	if cfg then
		if cfg.act_id == ACTIVITY_TYPE.MOSHEN then 											--世界boss活动跳转到boss界面
			ViewManager.Instance:Open(ViewName.Boss, TabIndex.world_boss)
		elseif cfg.act_id == ACTIVITY_TYPE.KF_GUILDBATTLE then
			ViewManager.Instance:Open(ViewName.KuaFuBattle)
		elseif cfg.act_id == ACTIVITY_TYPE.Triple_LiuJie then
			ViewManager.Instance:Open(ViewName.KuaFuBattle)
		else
			ActivityCtrl.Instance:ShowDetailView(cfg.act_id)
		end
	end
 end

function MainUIViewChat:FlushActivityPre()
	self:OnFlushActPreviewTimer()
	self:SetActiveName()
end

function MainUIViewChat:TouZiInfo()
	local role_level = PlayerData.Instance:GetRoleVo().level
	local level_cfg = KaifuActivityData.Instance:GetTouZicfg()
	local state = KaifuActivityData.Instance:CanShowTouZiPlan()
	local button_state = KaifuActivityData.Instance:TouZiButtonInfo()
	local cfg_num = InvestData.Instance:GetTouZiPlanInfoNum() or 0

	for k, v in pairs(level_cfg) do
		if v.seq == 0 and v.sub_index == 0 then
			if role_level < v.active_level_min then
				self.showtouzibutton:SetValue(false)
			elseif role_level >= v.active_level_min and button_state then
				self.showtouzibutton:SetValue(true)
			end
		end

		if v.seq == cfg_num - 1 and v.sub_index == 2 then
			if role_level > v.active_level_max then
				self.showtouzibutton:SetValue(false)
			end
		end
	end

	if not state then
		if self.touzibutton.animator.isActiveAndEnabled then
			self.touzibutton.animator:SetBool("Shake", true)
		end
	end
end

function MainUIViewChat:IsShowTouZiButton()
	if self.showtouzibutton then
		self.showtouzibutton:SetValue(false)
	end
end

function MainUIViewChat:OnFlushActPreviewTimer()
	if nil == self.act_preview_time_time_quest then
		local timer_func = function()
			local time_str = ActivityData.Instance:GetCurActivityCountDownStr()
			if self.open_time then
				if time_str and time_str ~= "" then
					time_str = ToColorStr(time_str, TEXT_COLOR.GREEN)
					time_str = Language.Activity.ActivityIsOn .. "：" .. time_str
				end
				if not time_str or time_str == "" then
					local info = ActivityData.Instance:GetNextActOpenInfo()
					if info then
						time_str = ToColorStr(info.open_time, TEXT_COLOR.GREEN)
						time_str = Language.Activity.ActivityOpenTime .. time_str
					end
				end
				self.open_time:SetValue(time_str)
			end
			self:SetActiveName()

			if time_str == "" then 					--今天是否已经没有活动
				self.show_act_pre:SetValue(false)
				if self.act_preview_time_time_quest then
					GlobalTimerQuest:CancelQuest(self.act_preview_time_time_quest)
					self.act_preview_time_time_quest = nil
				end
			else
				self.show_act_pre:SetValue(true)
			end
		end
		self.act_preview_time_time_quest = GlobalTimerQuest:AddRunQuest(timer_func, 1)
	end
end

function MainUIViewChat:SetActiveName()
	local cfg = ActivityData.Instance:GetCurActOpenInfo()
	if not cfg then
		cfg = ActivityData.Instance:GetNextActOpenInfo()
	end
	if cfg then
		self.activity_name:SetValue(cfg.act_name)
	end
end

-- 根据渠道开启语音聊天
function MainUIViewChat:UpdateVoiceSwitch()
	self.show_speaker:SetValue(not SHIELD_VOICE)
end

-- 提醒改变
function MainUIViewChat:RemindChangeCallBack(remind_name, num)
	if remind_name == RemindName.TeamFbFull and num > 0 then
		TipsCtrl.Instance:OpenFocusTeamFbFullTip()
	elseif remind_name == RemindName.MarryGiftBack and num > 0 then
		self.show_marry_gift:SetValue(true)
	end
end

function MainUIViewChat:ShowReturnRewardIcon()
	local is_act_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CHONGZHI_CRAZY_REBATE)
	local level_open = self:GetActivityIsOpenByLevel(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CHONGZHI_CRAZY_REBATE)
	self.show_return_reward_icon:SetValue(is_act_open and level_open)
end

function MainUIViewChat:GetActivityIsOpenByLevel(activity_type)
	local act_info = ActivityData.Instance:GetActivityConfig(activity_type)
	if not act_info then return false end
	local level = GameVoManager.Instance:GetMainRoleVo().level
	return level >= act_info.min_level
end

function MainUIViewChat:OpenReturnRechargeView()
	ViewManager.Instance:Open(ViewName.RechargeReturnReward)
end

-------------------------------------------------------------------------------------------------------------

MainUIChatCell = MainUIChatCell or BaseClass(BaseRender)

function MainUIChatCell:__init()
	self.is_easy = false 											--简单设置数据模式(计算高度用)

	self.rich_text = self:FindObj("Content")
	self.chanel_text = self:FindObj("ChanelText")

	self.title = self:FindVariable("Title")
	self.title_bg = self:FindVariable("TitleBg")
end

function MainUIChatCell:__delete()
	self.voice_animator = nil
	StepPool.Instance:DelStep(self)
	if self.main_chat_view then
		self.main_chat_view = nil
	end
end

function MainUIChatCell:PlayOrStopVoice(file_name)
	ChatCtrl.Instance:ClearPlayVoiceList()
	ChatCtrl.Instance:SetStartPlayVoiceState(false)
	local call_back = BindTool.Bind(self.ChangeVoiceAni, self)

	-- GVoice
	local is_gvoice, file_id, str = GVoiceManager.ParseGVoice(file_name)
	if is_gvoice then
		if AudioGVoice then
			call_back(true)
			GVoiceManager.Instance:PlayVoice(file_id, function ()
				call_back(false)
			end)
		else
			SysMsgCtrl.Instance:ErrorRemind(Language.Chat.CantParseVoice)
			call_back(false)
		end

		return
	end

	ChatRecordMgr.Instance:PlayVoice(file_name, call_back, call_back)
end

function MainUIChatCell:ChangeVoiceAni(state)
	if self.voice_animator and not IsNil(self.voice_animator.gameObject) then
		self.voice_animator:SetBool("play", state)
	end
end

function MainUIChatCell:SetEasy(state)
	self.is_easy = state
end

function MainUIChatCell:SetData(data)
	if data == nil or IsNil(self.rich_text.gameObject) then
		return
	end

	self.data = data

	if self.is_easy then
		self.is_easy = false
		self:Step()
	else
		-- 分步执行
		StepPool.Instance:DelStep(self)
		StepPool.Instance:AddStep(self)
	end
end

function MainUIChatCell:Step()
	local data = self.data
	local content = data.content
	local name = data.username
	local color = TEXT_COLOR.GREEN
	if name and name ~= "" and data.username ~= Language.Channel[6] then
		local role_vo = GameVoManager.Instance:GetMainRoleVo()
		local str_name = ""
		-- if role_vo.role_id ~= data.from_uid then
		-- 	color = TEXT_COLOR.BLUE
		-- end
		str_name = string.format("{wordcolor;%s;%s:}", color, name)
		content = str_name .. content
	end

	--设置频道图标
	local bundle, asset = ResPath.GetA2ChatLableIcon("word")
	local title_text = Language.Channel[data.channel_type or 0]
	if data.channel_type == CHANNEL_TYPE.WORLD then
		bundle, asset = ResPath.GetA2ChatLableIcon("word")
	elseif data.channel_type == CHANNEL_TYPE.TEAM then
		bundle, asset = ResPath.GetA2ChatLableIcon("team")
	elseif data.channel_type == CHANNEL_TYPE.GUILD then
		bundle, asset = ResPath.GetA2ChatLableIcon("guild")
	elseif data.channel_type == CHANNEL_TYPE.SYSTEM then
		bundle, asset = ResPath.GetA2ChatLableIcon("system")
	elseif data.channel_type == CHANNEL_TYPE.SPEAKER then
		bundle, asset = ResPath.GetA2ChatLableIcon("local")
	elseif data.channel_type == CHANNEL_TYPE.CROSS then
		bundle, asset = ResPath.GetA2ChatLableIcon("cross")
	end
	self.title:SetValue(title_text)
	self.title_bg:SetAsset(bundle, asset)

	--是否语音
	if data.content_type == CHAT_CONTENT_TYPE.AUDIO then
		local temp_str = data.content
		local tbl = {}
		-- GVoice
		local is_gvoice, file_id, str, time = GVoiceManager.ParseGVoice(temp_str)
		if is_gvoice then
			tbl[3] = time
		else
			for i = 1, 3 do
				local j, k = string.find(temp_str, "(%d+)")
				local num = string.sub(temp_str, j, k)
				temp_str = string.gsub(temp_str, num, "num")
				table.insert(tbl, num)
			end
		end

		local callback = BindTool.Bind(self.PlayOrStopVoice, self)
		self:AddVoiceBtn(self.rich_text.rich_text, name, color, tbl, callback, data.content)
		return
	end

	if self.data.tuhaojin_color > 0 then
		color = CoolChatData.Instance:GetTuHaoJinColorByIndex(self.data.tuhaojin_color)
	else
		color = COLOR.WHITE
	end
	RichTextUtil.ParseRichText(self.rich_text.rich_text, content, nil, color, true)

	--设置描边颜色
	-- local shadow_color = CHANEL_TEXT_OUTLINE_COLOR[data.channel_type] or CHANEL_TEXT_OUTLINE_COLOR[CHANNEL_TYPE.WORLD]
	-- self.chanel_text.outline.effectColor = shadow_color
end

function MainUIChatCell:GetData()
	return self.data or {}
end

function MainUIChatCell:SetIndex(index)
	self.index = index
end

function MainUIChatCell:GetIndex()
	return self.index
end

function MainUIChatCell:GetContentHeight()
	if IsNil(self.rich_text.gameObject) then
		return 30
	end

	local rect = self.rich_text.rect
	UnityEngine.UI.LayoutRebuilder.ForceRebuildLayoutImmediate(rect)
	local hegiht = rect.rect.height < 30 and 30 or rect.rect.height
	return hegiht
end

function MainUIChatCell:ClickCallBack(callback, file_name)
	if callback then
		callback(file_name)
	end
end

function MainUIChatCell:AddVoiceBtn(rich_text, name, color, tbl, callback, file_name)
	rich_text:Clear()
	if name and color then
		rich_text:AddText(string.format("<color='#%s'>%s</color>：", color, name))
	end
	local time = tbl[3]
	local prefab = PreloadManager.Instance:GetPrefab("uis/views/miscpreload_prefab", "VioceButtonLeft")
	local obj = GameObject.Instantiate(prefab)
	local variable_table = obj:GetComponent(typeof(UIVariableTable))
	if variable_table then
		local time_value = variable_table:FindVariable("Time")
		time_value:SetValue(time)
	end
	rich_text:AddObject(obj)
	local event_table = obj:GetComponent(typeof(UIEventTable))
	if event_table and callback then
		event_table:ListenEvent("ClickPlayOrStop", BindTool.Bind(self.ClickCallBack, self, callback, file_name))
	end

	self.voice_animator = obj:GetComponent(typeof(UnityEngine.Animator))
end

-- 公会聊天弹出框
PopGuildChatCell = PopGuildChatCell or BaseClass(BaseRender)

function PopGuildChatCell:__init()
	self.rich_text = self:FindObj("Content")
end

function PopGuildChatCell:__delete()
end

function PopGuildChatCell:SetData(data)
	if data == nil or IsNil(self.rich_text.gameObject) then
		return
	end
	self.data = data
	local content = data.content
	local color = ""
	if self.data.tuhaojin_color > 0 then
		color = CoolChatData.Instance:GetTuHaoJinColorByIndex(self.data.tuhaojin_color)
	else
		color = COLOR.WHITE
	end
	RichTextUtil.ParseRichText(self.rich_text.rich_text, content, nil, color, true)
end

function PopGuildChatCell:GetData()
	return self.data or {}
end

function PopGuildChatCell:SetIndex(index)
	self.index = index
end

function PopGuildChatCell:GetIndex()
	return self.index
end

function PopGuildChatCell:GetContentHeight()
	if IsNil(self.rich_text.gameObject) then
		return 30
	end

	local rect = self.rich_text.rect
	UnityEngine.UI.LayoutRebuilder.ForceRebuildLayoutImmediate(rect)
	local hegiht = rect.rect.height < 30 and 30 or rect.rect.height
	return hegiht
end