MainUIViewChat = MainUIViewChat or BaseClass(BaseRender)

MainUIViewChat.ViewState = {
	Short = 0,
	Length = 1,
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
	GUILD_BOSS = "guild_boss",					--家族boss通知
	CHAT_INFO  = "chat_info",					--私聊信息
	IS_CAMP_BUILDING = "is_camp_building",		--怪物攻城
	GUILD_STORAGE = "guild_storage",			--家族仓库
}

local ChatCellHeight = {}
local UILayer = GameObject.Find("GameRoot/UILayer")

function MainUIViewChat:__init()
	MainUIViewChat.Instance = self
	self.chat_data = {}
	self.pop_chat_data = {}
	self.cell_list = {}
	self.name_cell_list = {}
	self.curr_send_channel = 0
	self.chat_measuring = nil
	self.pop_chat_measuring = nil
	self.guild_invite_list = {}
	self.is_show_activity = true
	self.state = MainUIViewChat.ViewState.Short
	-- 查找组件
	self.chat_list = self:FindObj("ChatList")
	self.pop_chat_list = self:FindObj("PopChatList")
	self.mail_btn = self:FindObj("MailButton")
	self.friend_rec_btn = self:FindObj("FriendRecButton")
	self.team_req_btn = self:FindObj("TeamReqButton")
	self.join_req_btn = self:FindObj("ReqJoinButton")
	self.show_camp_build_btn = self:FindObj("CampBuildingButton")
	-- self.arraw_btn = self:FindObj("Arraw")
	self.trade_req_btn = self:FindVariable("ShowTradeButton")
	self.show_hongbao_btn = self:FindVariable("show_hongbao_btn")
	self.show_server_hongbao_btn = self:FindVariable("show_server_hongbao_btn")
	self.show_guildchat_bt = self:FindVariable("show_guildchat_bt")
	self.show_guildchat_pop = self:FindVariable("show_guildchat_pop")
	self.show_guildchat_redpt = self:FindVariable("show_guildchat_redpt")
	self.show_offline_btn = self:FindVariable("ShowOffLineBtn")
	self.show_lovecontent_btn = self:FindVariable("ShowLoveContentBtn")
	self.show_guild_goddess_btn = self:FindVariable("ShowGuildGoddess")
	self.show_bag_full_btn = self:FindVariable("ShowBagFullBtn")
	self.show_discount_btn = self:FindVariable("ShowDisCountBtn")
	self.show_discount_red = self:FindVariable("ShowDiscountRed")
	self.is_cross_server = self:FindVariable("IsCrossServer")
	self.show_kouling_hongbao = self:FindVariable("ShowKoulingHongbao")
	self.show_affiche = self:FindVariable("ShowAffiche")
	self.show_discount_red:SetValue(true)
	self.show_chat_button = self:FindVariable("show_chat")
	self.show_chat_button:SetValue(false)
	self.weeding_get_invite_btn = self:FindObj("WeedingGetInviteButton")
	self.weeding_get_invite_btn:SetActive(false)
	self.weeding_invite_btn = self:FindObj("WeedingInviteButton")
	self.chat_buttons = self:FindObj("ChatButtons")
	self.gift_button = self:FindObj("GiftButton")
	self.guild_apply_btn = self:FindObj("GuildApplyBtn")
	self.guild_boss_btn = self:FindObj("GuildBossBtn")
	--self.show_guildchat_res = self:FindVariable("ShowGuildChatRes")
	self.show_tupo_btn = self:FindVariable("show_tupo_btn")
	self.chat_view = self:FindObj("ChatView")

	self.pop_mainchat_list = self:FindObj("PopMainChatList")
	self.show_mainchat_pop = self:FindVariable("show_mainchat_pop")
	self.is_activity_name = self:FindObj("IsActivityName")	

	--私聊提示
	self.btn_chat = MainCHATIcon.New(self:FindObj("Buttonchat"))
	--一折抢购
	local discount_btn = self:FindObj("DisCountBtn")
	self.discount_anictrl = discount_btn.animator
	self.guild_storage_btn = self:FindObj("GuildStorage")

	-- 附近玩家面板
	self.show_near_role_view = self:FindVariable("ShowNearRoleView")
	self.only_show_can_atk_toggle = self:FindObj("OnlyShowCanAtkToggle").toggle
	self.only_show_can_atk_toggle:AddValueChangedListener(BindTool.Bind(self.OnNearRoleToggleChange, self))
	self.near_role_list_view = self:FindObj("NearRoleListView")
	local near_role_list_delegate = self.near_role_list_view.list_simple_delegate
	near_role_list_delegate.NumberOfCellsDel = BindTool.Bind(self.NearRoleNum, self)
	near_role_list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshNearRoleView, self)
	self:BindGlobalEvent(SceneEventType.OBJ_ENTER_LEVEL_ROLE, BindTool.Bind(self.FlushNearRoleView, self))
	self:BindGlobalEvent(ObjectEventType.BE_SELECT,
		BindTool.Bind(self.OnSelectObjHead, self))
	self:BindGlobalEvent(ObjectEventType.OBJ_DELETE,
		BindTool.Bind(self.OnObjDeleteHead, self))
	self:BindGlobalEvent(ObjectEventType.OBJ_DEAD,
		BindTool.Bind(self.OnObjDeleteHead, self))
	self:BindGlobalEvent(MainUIEventType.OPEN_NEAR_VIEW,
		BindTool.Bind(self.OpenNearRole, self))

	self.data_listen = BindTool.Bind(self.PlayerDataChangeCallback, self)
	PlayerData.Instance:ListenerAttrChange(self.data_listen)

	self.show_hu_song = self:FindVariable("ShowHuSong")
	self.hongbao_num_text = self:FindVariable("hongbao_num")
	self.server_hongbao_num_text = self:FindVariable("server_hongbao_num")
	self.show_hongbao_redpoint = self:FindVariable("ShowHongBaoRedPoint")
	self.show_server_hongbao_redpoint = self:FindVariable("ShowServerHongBaoRedPoint")

	self.activity_name = self:FindVariable("ActivityName")
	self.open_time = self:FindVariable("OpenTime")

	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local show_level = SuperVipData.Instance:GetShowLevel()
	self.show_super_vip = self:FindVariable("ShowSuperVip")
	self.show_super_vip_rp = self:FindVariable("ShowSuperVipRp")
	local func = function(gm_info)
		local show_level = SuperVipData.Instance:GetShowLevel()
		self.show_super_vip:SetValue(main_role_vo.level >= show_level and not IS_ON_CROSSSERVER)
	end
	SuperVipCtrl.Instance:GmVerifyCallBack(func)

	self.show_super_vip_rp:SetValue(true)
	self.is_click_super_vip = false

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
	self:ListenEvent("OpenChat", BindTool.Bind(self.HandleOpenChat, self))
	self:ListenEvent("OpenMail", BindTool.Bind(self.HandleOpenMail, self))
	self:ListenEvent("OpenFriendReq", BindTool.Bind(self.ShowApplyView, self, APPLY_OPEN_TYPE.FRIEND))
	self:ListenEvent("OpenTeamReq", BindTool.Bind(self.ShowApplyView, self, APPLY_OPEN_TYPE.TEAM))
	self:ListenEvent("OpenJoinReq", BindTool.Bind(self.ShowApplyView, self, APPLY_OPEN_TYPE.JOIN))
	self:ListenEvent("OpenTradeTip", BindTool.Bind(self.HandleOpenTradeReqTips, self))
	self:ListenEvent("ChangeHeight", BindTool.Bind(self.HandleChangeHeight, self))
	self:ListenEvent("OnClickHu", BindTool.Bind(self.OnClickHu, self))
	self:ListenEvent("OnClickJiu", BindTool.Bind(self.OnClickJiu, self))
	self:ListenEvent("OnClickGo", BindTool.Bind(self.OnClickGo, self))
	self:ListenEvent("OnClickSpeakWorldDown", BindTool.Bind(self.OnClickSpeakDown, self, CHANNEL_TYPE.WORLD))
	self:ListenEvent("OnClickSpeakUp", BindTool.Bind(self.OnClickSpeakUp, self))
	self:ListenEvent("OnClickSpeakCampDown", BindTool.Bind(self.OnClickSpeakDown, self, CHANNEL_TYPE.CAMP))
	self:ListenEvent("OpenGiftRecordView", BindTool.Bind(self.OpenGiftRecordView, self))
	self:ListenEvent("OpenGuildApply", BindTool.Bind(self.OpenGuildApply, self))
	self:ListenEvent("OpenHongBao", BindTool.Bind(self.OpenHongBao, self))
	self:ListenEvent("OpenGuildChat", BindTool.Bind(self.OpenGuildChat, self))
	self:ListenEvent("OpenNearRole", BindTool.Bind(self.OpenNearRole, self))
	self:ListenEvent("CloseNearRoleView", BindTool.Bind(self.CloseNearRoleView, self))
	self:ListenEvent("OpenOfflineView", BindTool.Bind(self.OpenOfflineView, self))
	self:ListenEvent("ClickLoveContent", BindTool.Bind(self.ClickLoveContent, self))
	self:ListenEvent("ClickGuildGoddess", BindTool.Bind(self.ClickGuildGoddess, self))
	self:ListenEvent("OpenBagRecyleView", BindTool.Bind(self.OpenBagRecyleView, self))
	self:ListenEvent("OpenDiscountView", BindTool.Bind(self.OpenDiscountView, self))
	self:ListenEvent("OpenServerHongBao", BindTool.Bind(self.OpenServerHongBao, self))
	self:ListenEvent("OpenVoiceSetting", BindTool.Bind(self.OpenVoiceSetting, self))
	self:ListenEvent("OnClickGuildBoss", BindTool.Bind(self.OnClickGuildBoss, self))
	self:ListenEvent("OpenSpeaker", BindTool.Bind(self.OpenSpeaker, self))
	self:ListenEvent("OpenKoulingHongbao",BindTool.Bind(self.OpenKoulingHongbao, self))
	self:ListenEvent("ClickTuPoBtn",BindTool.Bind(self.ClickTuPoCallBack, self))
	self:ListenEvent("OpenChatInfo",BindTool.Bind(self.ClickChatInfo, self))
	self:ListenEvent("OpenGuildStorage", BindTool.Bind(self.OpenGuildStorage, self))
	self:ListenEvent("ClickGuildPop", BindTool.Bind(self.ClickPop, self, CHAT_POP_TYPE.GUILD))
	self:ListenEvent("ClickMainPop", BindTool.Bind(self.ClickPop, self, CHAT_POP_TYPE.MAIN))
	self:ListenEvent("ClickAllActivityName", BindTool.Bind(self.AllActivityNameClick, self))
	self:ListenEvent("ClickActivityView", BindTool.Bind(self.ClickActivityView, self))
	self:ListenEvent("OpenCampBuildView", BindTool.Bind(self.OpenCampBuildView, self))
	self:ListenEvent("OpenAffiche", BindTool.Bind(self.OpenAfficheView, self))
	self:ListenEvent("OpenSuperVip", BindTool.Bind(self.OpenSuperVipView, self))
	self.root_node.animator:ListenEvent("ToShort", BindTool.Bind(self.ToShortFinish, self))
	self.root_node.animator:ListenEvent("ToLength", BindTool.Bind(self.ToLengthFinish, self))

	self.root_node.animator:ListenEvent("StartToLength", BindTool.Bind(self.StartToLength, self))
	self.root_node.animator:ListenEvent("StartToShort", BindTool.Bind(self.StartToShort, self))

	self:BindGlobalEvent(MainUIEventType.CHAT_CHANGE, BindTool.Bind1(self.FulshChatView, self))
	self.weeding_get_invite_btn.button:AddClickListener(BindTool.Bind(self.HandleOpenWeedingGetInvite, self))
	self.weeding_invite_btn.button:AddClickListener(BindTool.Bind(self.HandleOpenWeedingInvite, self))
	--监听右下角收缩按钮事件
	self:BindGlobalEvent(MainUIEventType.FIGHT_STATE_BUTTON, BindTool.Bind1(self.CheckFlushChatView, self))
	self.hongbao_num = 0

	-- 公会求救列表
	self.guild_sos_list = {}

	-- 判断是否加入公会
	-- local vo = GameVoManager.Instance:GetMainRoleVo()
	-- self.show_guildchat_bt:SetValue(false)
	-- 合并国家,组队聊天到群聊，不再以是否加入公会限制
	-- if vo.guild_id > 0 then
	-- 	self.show_guildchat_bt:SetValue(true)
	-- else
	-- 	self.show_guildchat_bt:SetValue(false)
	-- end

	-- self.pop_chat_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.PopChatFinish, self), 2)

	if self.item_data_change_callback == nil then
		self.item_data_change_callback = BindTool.Bind(self.ItemCallBack, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_change_callback)
	end
	self:ItemCallBack()
	self:BindGlobalEvent(LoginEventType.LOGIN_SERVER_CONNECTED, BindTool.Bind(self.OnConnectLoginServer, self))
	self:BindGlobalEvent(LoginEventType.CROSS_SERVER_CONNECTED, BindTool.Bind(self.OnConnectLoginServer, self))

	-- iphoneX把聊天框抬高
	if UnityEngine.Application.platform == UnityEngine.RuntimePlatform.IPhonePlayer
		and UnityEngine.iOS.Device.generation == UnityEngine.iOS.DeviceGeneration.iPhoneX then

		local rect = self.chat_view.transform:GetComponent(typeof(UnityEngine.RectTransform))
		rect.anchoredPosition = Vector2(0, 20)
	end

	self.guild_way = nil
	self.main_way = nil

	self.delay_refresh_chate_view_timer = nil
	self.delay_refresh_chat_view = BindTool.Bind(self.DelayRefreshChatView, self)
end

function MainUIViewChat:__delete()
	self:RemoveActivityTime()
	if self.item_data_change_callback then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_change_callback)
		self.item_data_change_callback = nil
	end

	if nil ~= self.delay_refresh_chate_view_timer then
		GlobalTimerQuest:CancelQuest(self.delay_refresh_chate_view_timer)
		self.delay_refresh_chate_view_timer = nil
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

	if self.pop_chat_measuring then
		GameObject.Destroy(self.pop_chat_measuring.root_node.gameObject)
		self.pop_chat_measuring:DeleteMe()
		self.pop_chat_measuring = nil
	end
	ChatCellHeight = {}

	if self.pop_chat_quest then
		GlobalTimerQuest:CancelQuest(self.pop_chat_quest)
	end

	if self.pop_mainchat_quest then
		GlobalTimerQuest:CancelQuest(self.pop_mainchat_quest)
	end

	MainUIViewChat.Instance = nil

	for _, v in pairs(self.name_cell_list) do
		v:DeleteMe()
	end
	self.name_cell_list = {}

	PlayerData.Instance:UnlistenerAttrChange(self.data_listen)

	for k,v in pairs(self.guild_sos_list) do
		GameObject.Destroy(v.gameObject)
	end
	self.guild_sos_list = {}

	for k,v in pairs(self.guild_invite_list) do
		GameObject.Destroy(v.gameObject)
	end
	self.guild_invite_list = {}

	if self.btn_chat ~= nil then
		self.btn_chat:DeleteMe()
	end

	self.pop_mainchat_list = nil
	self.show_mainchat_pop = nil

	self.guild_way = nil
	self.main_way = nil
end

function MainUIViewChat:ClickPop(pop_type)
	if pop_type == nil then
		return
	end

	if pop_type == CHAT_POP_TYPE.MAIN then
		ViewManager.Instance:Open(ViewName.Chat, TabIndex.chat_answer)
	elseif pop_type == CHAT_POP_TYPE.GUILD then
		ChatData.Instance:SetGuildChatType(self.guild_way)
		ViewManager.Instance:Open(ViewName.ChatGuild)
	end
end

-- 登录服
function MainUIViewChat:OnConnectLoginServer()
	self.is_cross_server:SetValue(IS_ON_CROSSSERVER)
end

function MainUIViewChat:PopChatFinish()
	if ChatData.Instance:GetIsPopChat() then
		ChatData.Instance:SetIsPopChat(false)
		self:ShowGuildPopChat(true)
	else
		self:ShowGuildPopChat(false)
	end
end

function MainUIViewChat:PopMainChatFinish()
	if ChatData.Instance:GetIsPopMainChat() then
		ChatData.Instance:SetIsPopMainChat(false)
		self:ShowMainPopChat(true)
	else
		self:ShowMainPopChat(false)
	end
end

function MainUIViewChat:ShowGuildPopChat(is_show, delay_time)
	if self.pop_chat_quest then
		GlobalTimerQuest:CancelQuest(self.pop_chat_quest)
	end

	if is_show then
		local time = 2
		if delay_time then
			time = delay_time
		end
		self.pop_chat_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.PopChatFinish, self), time)
	end
	self.show_guildchat_pop:SetValue(is_show)
end

function MainUIViewChat:ShowMainPopChat(is_show, delay_time)
	if self.pop_mainchat_quest then
		GlobalTimerQuest:CancelQuest(self.pop_mainchat_quest)
	end

	if is_show then
		local cfg = HotStringChatData.Instance:GetQuestionConfig() or {}
		local limit_cfg = cfg.wg_question or {}
		if limit_cfg ~= nil then
			for k,v in pairs(limit_cfg) do
				if v and v.question_type == 2 then
					local main_vo = GameVoManager.Instance:GetMainRoleVo()
					if main_vo and main_vo.level < v.open_level then
						return
					end
				end
			end
		end

		local time = 2
		if delay_time then
			time = delay_time
		end
		self.pop_mainchat_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.PopMainChatFinish, self), time)
	end
	self.show_mainchat_pop:SetValue(is_show)
end

function MainUIViewChat:ShowGuildChatRedPt(is_show)
	self.show_guildchat_redpt:SetValue(is_show)
end

function MainUIViewChat:OpenSpeaker()
	TipsCtrl.Instance:ShowSpeakerView()
end

--local kouling_hongbao_info = nil
function MainUIViewChat:FlushKoulingHongbao()
	local level = GameVoManager.Instance:GetMainRoleVo().level
	--等级限制
	if level < ChatData.Instance:GetChatOpenLevel(CHAT_OPENLEVEL_LIMIT_TYPE.WORLD) then
		self.show_kouling_hongbao:SetValue(false)
	else
		--kouling_hongbao_info = HongBaoData.Instance:GetOneKoulingRedPaper()
		local kouling_id = HongBaoData.Instance:GetKouLingCanGetId()
		--if nil == kouling_hongbao_info then return end
		if nil ~= kouling_id then
			self.show_kouling_hongbao:SetValue(true)
		else
			self.show_kouling_hongbao:SetValue(false)
		end
	end
end

function MainUIViewChat:CloseKoulingHongbao()
 	self.show_kouling_hongbao:SetValue(false)
end

function MainUIViewChat:OpenKoulingHongbao()
	--if kouling_hongbao_info then
		--HongBaoCtrl.Instance:SendCommandRedPaperCheckInfo(kouling_hongbao_info.id)
		--HongBaoData.Instance:RemoveKoulingRedPaper(kouling_hongbao_info.id)
		--self:FlushKoulingHongbao()
	--else
		--self:FlushKoulingHongbao()
	--end
	local kouling_id = HongBaoData.Instance:GetKouLingCanGetId()
	if kouling_id then
		HongBaoCtrl.Instance:SendCommandRedPaperCheckInfo(kouling_id)
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Chat.NoCanGetRed)
	end
	self:FlushKoulingHongbao()
end

-- function MainUIViewChat:ClickQuickChat()
-- 	if not ChatData.Instance:GetChannelCdIsEnd(CHANNEL_TYPE.WORLD) then
-- 		SysMsgCtrl.Instance:ErrorRemind(Language.Chat.WorldChatCD)
-- 		return
-- 	end
-- 	local function callback(str)
-- 		local level = GameVoManager.Instance:GetMainRoleVo().level
-- 		--等级限制
-- 		if level < ChatData.Instance:GetChatOpenLevel(CHAT_OPENLEVEL_LIMIT_TYPE.WORLD) then
-- 			local level_str = PlayerData.GetLevelString(ChatData.Instance:GetChatOpenLevel(CHAT_OPENLEVEL_LIMIT_TYPE.WORLD))
-- 			SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Chat.LevelDeficient, level_str))
-- 			return
-- 		end
-- 		--设置世界聊天冷却时间
-- 		ChatData.Instance:SetChannelCdEndTime(CHANNEL_TYPE.WORLD)
-- 		ChatCtrl.SendChannelChat(CHANNEL_TYPE.WORLD, str, CHAT_CONTENT_TYPE.TEXT)
-- 		self:UpdateChatCD()
-- 	end
-- 	ChatCtrl.Instance:OpenQuickChatView(QUICK_CHAT_TYPE.NORMAL, callback)
-- end

-- -- 刷新快捷聊天冷却时间显示
-- function MainUIViewChat:UpdateChatCD()
-- 	self:ClearChatCD()
-- 	local function timer_func(elapse_time, total_time)
-- 		if elapse_time >= total_time then
-- 			self:ClearChatCD()
-- 			self.chat_cd:SetValue("")
-- 			return
-- 		end
-- 		self.chat_cd:SetValue(math.ceil(total_time - elapse_time))
-- 	end
-- 	local time = ChatData.Instance:GetChannelCdEndTime(CHANNEL_TYPE.WORLD) - Status.NowTime
-- 	time = math.ceil(time)
-- 	self.chat_cd:SetValue(time)
-- 	self.chat_cd_count_down = CountDown.Instance:AddCountDown(time, 1, timer_func)
-- end

-- function MainUIViewChat:ClearChatCD()
-- 	if self.chat_cd_count_down then
-- 		CountDown.Instance:RemoveCountDown(self.chat_cd_count_down)
-- 		self.chat_cd_count_down = nil
-- 	end
-- end

function MainUIViewChat:OnEnterScene()
	if self.chat_measuring then
		GameObject.Destroy(self.chat_measuring.root_node.gameObject)
		self.chat_measuring:DeleteMe()
		self.chat_measuring = nil
	end
end

function MainUIViewChat:OnFlush(param_t)
	for k, v in pairs(param_t) do
		if k == "mail_rec" then
			self:SetMailRecVisible(v[1])
		elseif k == "friend_rec" then
			self:SetFriendRecVisible(v[1])
		elseif k == "team_req" then
			self:SetTeamReqVisible(v[1])
		elseif k == "join_req" then
			self:SetJoinReqVisible(v[1])
		elseif k == "trade_req" then
			self:SetTradeReqVisible(v[1])
		elseif k == "weeding_get_invite" then
			self:SetWeedingGetInbiteVisible(v[1])
		elseif k == "gift_btn" then
			self:SetGiftBtnVisible(v[1])
		elseif k == "hongbao" then
			self:CreateHongBao(v[1], v[2])
		elseif k == "kouling_hongbao" then
			self:FlushKoulingHongbao()
		elseif k == "server_hongbao" then
			self:CreateServerHongBao(v[1], v[2])
		elseif k == "sos_req" then
			self:CreateSos(v[1])
		elseif k == "guild_yao" then
			self:SetGuildApplyVisible(v[1])
		elseif k == "off_line" then
			self:ShowOffLineBtn(v[1])
		elseif k == "love_content" then
			self:ShowLoveContentBtn(v[1])
		elseif k == "discount" then
			self:ShowDisCountBtn(v[1])
		elseif k == "discount_red" then
			self:SetDiscountRed(v[1])
		elseif k == "discount_ani" then
			self:SetDisCountTrigger()
		elseif k == "chat_info" then
			self:SetChatinfo(v[1])
		elseif k == "guild_storage" then
			self:SetGuildStorage(v[1])
		elseif k == "guild_goddess" then
			self:SetGuildGoddessVisible(v[1])
		elseif k == "guild_invite" then
			self:CreateGuildInvite(v[1])
		elseif k == "bag_full" then
			self:SetBagFullVisible(v[1])
		elseif k == "show_guild_popchat" then
			self:ShowGuildPopChat(v[1])
		elseif k == "show_chat_popchat" then
			self:ShowMainPopChat(v[1])
		elseif k == "flush_popchat_view" then
  			self:FlushPopChatView(CHAT_POP_TYPE.GUILD)
  		elseif k == "flush_popmain_view" then
  			self:FlushPopChatView(CHAT_POP_TYPE.MAIN)
  			self:ShowMainPopChat(true, 2)
		elseif k == "guild_boss" then
			self:SetGuildBossVisible(v[1])
		elseif k == "world_level" then
			self:SetWorldLevelVisible(v[1])
		elseif k == "show_affiche" then
			self:SetAfficheVisible(v[1])
		elseif k == "activity_time" then
			self:GetDateActivityTimeAndName()
		elseif k == "is_camp_building" then
			self:SetCampBuildVisible(v[1])
		end
	end
end

function MainUIViewChat:HandleChangeHeight()
	local bool = self.root_node.animator:GetBool("changeheight")
	self.root_node.animator:SetBool("changeheight", not bool)
end

function MainUIViewChat:GetDateActivityTimeAndName()
	local activity_list, activity_type = MainUIData.Instance:OpenActivityTime()
	local on_open_activity_list, activity_num = MainUIData.Instance:GetOnOpenActivityList()
	local server_time = TimeCtrl.Instance:GetServerTime()
	self:RemoveActivityTime()
	-- if activity_num > 0 then
	-- 	if activity_num > 1 then
	-- 		self:OnCountDown()
	-- 		self.on_activity_count_down = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.OnShowCountDown, self), 10)
	-- 	else
	-- 		self:SetOnActivityTime(1)
	-- 	end
	-- else
	if nil ~= activity_list then
		if activity_list.is_close == 0 then
			self.open_time:SetValue(Language.Common.OpenActivityTime .. os.date("%H:%M", activity_list.act_begin_time))
			if activity_list.is_opening == 1 then
				self.is_show_activity = false
				self.open_activity_time = CountDown.Instance:AddCountDown(activity_list.act_begin_cd, 1, BindTool.Bind(self.CountDown, self))
			else
				if activity_list.act_begin_cd <= 300 then
					self.is_show_activity = true
					self.activity_count_down = CountDown.Instance:AddCountDown(activity_list.act_begin_cd, 1, BindTool.Bind(self.CountDown, self))
				end
			end	
		end			
		self.activity_name:SetValue(activity_type)
		self.is_activity_name:SetActive(true)
	else
		self.is_activity_name:SetActive(false)
		self.open_time:SetValue(Language.Common.NilActivity)
	end
	-- end
end

function MainUIViewChat:RemoveActivityTime()
	if self.activity_count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.activity_count_down)
		self.activity_count_down = nil
	end	

	if self.on_activity_count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.on_activity_count_down)
		self.on_activity_count_down = nil
	end	

	if self.open_activity_time ~= nil then
		CountDown.Instance:RemoveCountDown(self.open_activity_time)
		self.open_activity_time = nil
	end	
end

local on_cur_show_index = 0
function MainUIViewChat:OnShowCountDown()
	local on_open_activity_list, activity_num = MainUIData.Instance:GetOnOpenActivityList()
	if on_cur_show_index < activity_num then
		on_cur_show_index = on_cur_show_index + 1
	else
		on_cur_show_index = 1
	end
	self:SetOnActivityTime(on_cur_show_index)
end

function MainUIViewChat:SetOnActivityTime(index)
	local activity_list, activity_type = MainUIData.Instance:OpenActivityTime()
	if self.activity_count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.activity_count_down)
		self.activity_count_down = nil
	end	
	local cur_time = TimeCtrl.Instance:GetServerTime()
	local on_open_activity_list, activity_num = MainUIData.Instance:GetOnOpenActivityList()
	if on_open_activity_list[index] ~= nil then
		local on_open_activity_time = on_open_activity_list[index].act_end_time - cur_time
		if on_open_activity_time <= 0 then
			MainUIData.Instance:SetOnOpenActivityList()
			self:Flush("activity_time")
		else
			self.activity_count_down = CountDown.Instance:AddCountDown(on_open_activity_time, 1, BindTool.Bind(self.OnCountDown, self))
			self.activity_name:SetValue(activity_type or "")
		end
	end
end

function MainUIViewChat:OnCountDown(elapse_time, total_time)
	local time = TimeUtil.FormatSecond(total_time - elapse_time)	
	self.open_time:SetValue(Language.Common.OnOpenActivityTime .. time)
	if elapse_time >= total_time then
		MainUIData.Instance:SetOnOpenActivityList()
		self:Flush("activity_time")
	end
end

function MainUIViewChat:CountDown(elapse_time, total_time)
	local time = TimeUtil.FormatSecond(total_time - elapse_time)
	if self.is_show_activity then	
		self.open_time:SetValue(Language.Common.ResidueActivityTime .. time)
	else
		self.open_time:SetValue(Language.Common.OnOpenActivityTime .. time)
	end
end

function MainUIViewChat:ClickActivityView()
	local activity_list = MainUIData.Instance:OpenActivityTime()	
	if activity_list then 
		local activity_goto_panel = ActivityData.Instance:GetActivityForecast(activity_list.activity_type)
		if "" == activity_goto_panel.goto_panel and activity_list then
			ActivityCtrl.Instance:ShowDetailView(activity_list.activity_type)
		else
			local t = Split(activity_goto_panel.goto_panel, "#")
			local view_name = t[1]
			local tab_index = t[2]
			ViewManager.Instance:Open(view_name, TabIndex[tab_index])
		end
	end
 end

function MainUIViewChat:OpenAfficheView()
	ViewManager.Instance:Open(ViewName.UpdateAffiche)
end

function MainUIViewChat:OpenCampBuildView()
	ViewManager.Instance:Open(ViewName.Camp,TabIndex.camp_build)
end

function MainUIViewChat:OpenSuperVipView()
	ViewManager.Instance:Open(ViewName.SuperVip)
	self.show_super_vip_rp:SetValue(false)
	self.is_click_super_vip = true
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
		if self.state ~= MainUIViewChat.ViewState.Short then
			self.state = MainUIViewChat.ViewState.Short
			self:FulshChatView()
		end
	end
end

function MainUIViewChat:ToLengthFinish(param)
	if param == "1" then
		if self.state ~= MainUIViewChat.ViewState.Length then
			self.state = MainUIViewChat.ViewState.Length
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
	ViewManager.Instance:Open(ViewName.Chat)
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

function MainUIViewChat:OpenGuildApply()
	ViewManager.Instance:Open(ViewName.GuildApply)
end

function MainUIViewChat:OnClickGuildBoss()
	local str = Language.Guild.GuildBossBtnRemind
	local ok_callback = function()
		local guild_id = GuildData.Instance:GetGuildId()
		if guild_id and guild_id > 0 then
			GuildCtrl.Instance:SendGuildBackToStationReq(guild_id)
		end
	end
	TipsCtrl.Instance:ShowCommonTip(ok_callback, nil, str, nil)
end

function MainUIViewChat:OpenHongBao()
	--HongBaoCtrl.Instance:RecHongBao(HongBaoData.Instance:GetCurHongBaoIdList()[1].id)
	local id = HongBaoData.Instance:GetCanGetId()
	if id then
		HongBaoCtrl.Instance:RecHongBao(id)
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Chat.NoCanGetRed)
	end
end

function MainUIViewChat:OpenGuildChat()
	local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
	local open_camp = OpenFunData.Instance:CheckIsHide("camp")
	if guild_id > 0 or open_camp then
		ViewManager.Instance:Open(ViewName.ChatGuild)
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Role.NoGuild)
	end
end

function MainUIViewChat:OpenOfflineView()
	ViewManager.Instance:Open(ViewName.OffLineExp)
end

function MainUIViewChat:OpenVoiceSetting()
	ViewManager.Instance:Open(ViewName.VoiceSetting)
end

--爱情契约
function MainUIViewChat:ClickLoveContent()
	local function ok_callback()
		ViewManager.Instance:Open(ViewName.Marriage, TabIndex.marriage_love_contract)
	end
	local can_receive_day_num = MarriageData.Instance:GetQingyuanLoveContractInfo().can_receive_day_num + 1		-- 服务器天数从0开始 所以在这客户端显示要+1
	local des = string.format(Language.Marriage.ContentMianTips, can_receive_day_num)
	local yes_des = Language.Common.LingQuJiangLi
	local canel_des = Language.Common.AfterLater
	TipsCtrl.Instance:ShowCommonAutoView("", des, ok_callback, nil, nil, yes_des, canel_des)
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
	--PlayerCtrl.Instance.view:Flush("bag_recycle")
	PlayerCtrl.Instance.view:Flush("bag")
end

function MainUIViewChat:SetDiscountRed(state)
	if self.show_discount_red then
		self.show_discount_red:SetValue(state)
	end
end

--打开特惠豪礼界面
function MainUIViewChat:OpenDiscountView()
	local have_new_discount = DisCountData.Instance:GetHaveNewDiscount()
	if have_new_discount then
		ViewManager.Instance:Open(ViewName.DisCount, nil, "index", {"all"})
	else
		ViewManager.Instance:Open(ViewName.DisCount, nil, "index", {1})
	end
end

-- 打开全服红包
function MainUIViewChat:OpenServerHongBao()
	--HongBaoCtrl.Instance:RecHongBao(HongBaoData.Instance:GetCurServerHongBaoIdList()[1].id)
	local id = HongBaoData.Instance:GetServerCanGetId()
	if id then
		HongBaoCtrl.Instance:RecHongBao(id)
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Chat.NoCanGetRed)
	end
end

function MainUIViewChat:ShowOffLineBtn(enable)
	self.show_offline_btn:SetValue(enable)
end

function MainUIViewChat:ShowLoveContentBtn(enable)
	self.show_lovecontent_btn:SetValue(enable)
end

function MainUIViewChat:SetDisCountTrigger()
	if self.discount_anictrl and not IsNil(self.discount_anictrl.gameObject) then
		self.discount_anictrl:SetTrigger("shake")
	end
end

function MainUIViewChat:StartDisCountAni()
	self:SetDisCountTrigger()
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

function MainUIViewChat:ShowGuildChatIcon(is_show)
	-- self.show_guildchat_bt:SetValue(false)
end

function MainUIViewChat:FlushHongBaoNumValue()
	local num_text = ""
	local count = 0
	local data = HongBaoData.Instance:GetKoulingRedPaper()
	for k,v in pairs(data) do
		if v and v.id ~= nil then
			count = count + 1
		end
	end
	if count ~= 0 then
		if count == 1 then
			num_text = ""
		else
			num_text = tostring(count)
		end
		self.hongbao_num_text:SetValue(num_text)
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

-- 全服红包数量刷新
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

-- 全服红包按钮显示
function MainUIViewChat:CreateServerHongBao(id, type)
	self.show_server_hongbao_btn:SetValue(true)
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

function MainUIViewChat:SetGiftBtnVisible(value)
	if self.gift_button then
		self.gift_button:SetActive(value)
	end
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

function MainUIViewChat:SetGuildBossVisible(value)
	if self.guild_boss_btn then
		self.guild_boss_btn:SetActive(value)
	end
end

function MainUIViewChat:SetTradeReqVisible(value)
	if self.trade_req_btn then
		self.trade_req_btn:SetValue(value)
	end
end

function MainUIViewChat:SetWeedingGetInbiteVisible(value)
	if self.weeding_get_invite_btn then
		self.weeding_get_invite_btn:SetActive(value)
	end
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

function MainUIViewChat:SetWorldLevelVisible(value)
	if self.show_tupo_btn then
		self.show_tupo_btn:SetValue(value)
	end
end

function MainUIViewChat:SetAfficheVisible(value)
	if self.show_affiche then
		self.show_affiche:SetValue(value)
	end
end

function MainUIViewChat:SetChatinfo(value)
	if self.show_chat_button then
		self.show_chat_button:SetValue(value)
		self.btn_chat:SetData(ChatData.Instance:GetChatInfoList())
	end
end

function MainUIViewChat:SetGuildStorage(value)
	if self.guild_storage_btn then
		self.guild_storage_btn:SetActive(value)
	end
end

function MainUIViewChat:SetCampBuildVisible(value)
	if self.show_camp_build_btn then
		self.show_camp_build_btn:SetActive(value)
	end
end

function MainUIViewChat:DelayRefreshChatView()
	self.delay_refresh_chate_view_timer = nil
	if not self.chat_list.scroller.isActiveAndEnabled then
		return
	end
	local channel_list = ChatData.Instance:GetChannel(CHANNEL_TYPE.ALL)
	local msg_list = channel_list.msg_list or {}
	local count = 0
	local max_count = 3

	if self.state == MainUIViewChat.ViewState.Short then
		max_count = 3
	else
		max_count = 6
	end

	self.chat_data = {}
	for i = #msg_list, 1, -1 do
		if count >= max_count then
			break
		end

		if not msg_list[i].is_spec then
			-- if msg_list[i].from_type then
			-- 	if msg_list[i].from_type ~= 2 then
			-- 		table.insert(self.chat_data, 1, msg_list[i])
			-- 		count = count + 1
			-- 	end
			-- else
				table.insert(self.chat_data, 1, msg_list[i])
				count = count + 1
			--end
		end
	end
	self.chat_list.scroller:ReloadData(1)

	--self:FlushPopChatView()
end

function MainUIViewChat:FulshChatView()
	if nil ~= self.delay_refresh_chate_view_timer then
		return
	end

	self.delay_refresh_chate_view_timer = GlobalTimerQuest:AddDelayTimer(self.delay_refresh_chat_view, 0.2)
end

function MainUIViewChat:FlushPopChatView(chat_type)
	local check_type = chat_type == CHAT_POP_TYPE.GUILD and CHANNEL_TYPE.GUILD or CHANNEL_TYPE.ALL
	local channel_list = ChatData.Instance:GetChannel(check_type)
	local msg_list = channel_list.msg_list or {}

	local last_msg = msg_list[#msg_list] or {}
	for i = #msg_list, 1, -1 do
		if msg_list[i] ~= nil and msg_list[i].from_type == SHOW_CHAT_TYPE.ANSWER then
			last_msg = msg_list[i]
			break
		end
	end

	if not next(last_msg) then
		return
	end

	local color = COLOR.WHITE
	-- if last_msg.tuhaojin_color > 0 then
	-- 	color = COLOR.GOLD
	-- else
	-- 	color = COLOR.WHITE
	-- end

	local content = last_msg.content
	if last_msg.content_type == CHAT_CONTENT_TYPE.AUDIO then
		content = string.format(Language.Chat.Audio, last_msg.username or "")
	end
	local msg = self:GetCutPopChatStr(content)

	if check_type == CHANNEL_TYPE.GUILD then
		self.guild_way = last_msg.from_type
	end
	
	self:SetContent(msg, color, chat_type)
end

function MainUIViewChat:SetContent(msg, color, chat_type)
	local cur_color = ""
	if color then
		cur_color = color
	else
		cur_color = COLOR.WHITE
	end

	local rich_text = self.pop_chat_list:GetComponent(typeof(RichTextGroup))
	if chat_type == CHAT_POP_TYPE.MAIN then
		rich_text = self.pop_mainchat_list:GetComponent(typeof(RichTextGroup))
	end

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
	local max_length = 16
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

function MainUIViewChat:OnClickHu()
	YunbiaoCtrl.Instance:SendHuSongAddShieldReq()
end

function MainUIViewChat:OnClickJiu()
	YunbiaoCtrl.Instance:QiuJiuHandler()
end

--继续护送任务
function MainUIViewChat:OnClickGo()
	--if TaskData.Instance:GetCurTaskId() == TASK_ID.YUNBIAO then return end
	MainUICtrl.Instance:OnClickGo()
	--MainUIView.Instance.task_view:ClickGo()
end

function MainUIViewChat:OnClickSpeakDown(channel_state)
	channel_state = channel_state or 0

	local function start_voice()
		if channel_state > 2 then
			channel_state = 0
		end

		local curr_send_channel = channel_state
		local main_vo = GameVoManager.Instance:GetMainRoleVo()
		if curr_send_channel == CHANNEL_TYPE.WORLD then
			if not ChatData.Instance:GetChannelCdIsEnd(curr_send_channel) then
				local time = ChatData.Instance:GetChannelCdEndTime(curr_send_channel) - Status.NowTime
				SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Chat.CanNotChat, math.ceil(time)))
				return
			end

			local level = main_vo.level
			--等级限制
			if level < COMMON_CONSTS.CHAT_LEVEL_LIMIT then
				local level_str = PlayerData.GetLevelString(COMMON_CONSTS.CHAT_LEVEL_LIMIT)
				SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Chat.LevelDeficient, level_str))
				return
			end

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
		elseif curr_send_channel == CHANNEL_TYPE.CAMP then
			if not ChatData.Instance:GetChannelCdIsEnd(curr_send_channel) then
				local time = ChatData.Instance:GetChannelCdEndTime(curr_send_channel) - Status.NowTime
				SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Chat.CanNotChat, math.ceil(time)))
				return
			end

			if main_vo.camp <= 0 then
				SysMsgCtrl.Instance:ErrorRemind(Language.Common.PleaseJoinCamp)
				return
			end
		else
			print_error("HandleChangeChannel with unknow index:", curr_send_channel)
			return
		end

		--设置聊天冷却时间
		ChatData.Instance:SetChannelCdEndTime(curr_send_channel)
		AutoVoiceCtrl.Instance:ShowVoiceView(curr_send_channel)
	end
	GlobalTimerQuest:AddDelayTimer(start_voice, 0)
end

function MainUIViewChat:AllActivityNameClick()
	ViewManager.Instance:Open(ViewName.ActivityName)
end

function MainUIViewChat:OpenGiftRecordView()
	self:SetGiftBtnVisible(false)
	ScoietyCtrl.Instance:ShowFriendRecordView()
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

-- 附近玩家面板
function MainUIViewChat:OpenNearRole()
	self.show_near_role_view:SetValue(true)
	if self.near_role_list_view and self.near_role_list_view.scroller.isActiveAndEnabled then
		self.near_role_list_view.scroller:ReloadData(0)
	end
end

-- 取消
function MainUIViewChat:OnObjDeleteHead(obj)
	if SceneObj.select_obj == nil or SceneObj.select_obj == obj then
		self:FlushNearRoleView()
	end
end


function MainUIViewChat:OnSelectObjHead(target_obj, select_type)
	self:FlushNearRoleView()
end
function MainUIViewChat:FlushNearRoleView()
	if self.near_role_list_view and self.near_role_list_view.scroller.isActiveAndEnabled then
		self.near_role_list_view.scroller:ReloadData(0)
	end
end

function MainUIViewChat:CloseNearRoleView()
	self.show_near_role_view:SetValue(false)
end

function MainUIViewChat:OnNearRoleToggleChange(is_on)
	self.near_role_toggle_is_on = is_on
	if self.near_role_list_view and self.near_role_list_view.scroller.isActiveAndEnabled then
		self.near_role_list_view.scroller:ReloadData(0)
	end
end

function MainUIViewChat:NearRoleNum()
	return #self:GetCanAtkRole()
end

function MainUIViewChat:GetCanAtkRole()
	local list = {}
	for k, v in pairs(Scene.Instance:GetRoleList()) do
		if not v:IsMainRole() then
			if not self.near_role_toggle_is_on then
				table.insert(list, v)
			elseif self.near_role_toggle_is_on and Scene.Instance:IsEnemy(v) then
				table.insert(list, v)
			end
		end
	end
	return list
end

function MainUIViewChat:RefreshNearRoleView(cell, data_index)
	local name_cell = self.name_cell_list[cell]
	if not name_cell then
		name_cell = NearRoleNameCell.New(cell.gameObject)
		self.name_cell_list[cell] = name_cell
	end
	local list = self:GetCanAtkRole()
	name_cell:ListenClick(BindTool.Bind(self.OnClickRoleName, self, list[data_index + 1]))
	name_cell:SetData(list[data_index + 1])
end

function MainUIViewChat:OnClickRoleName(obj)
	if not obj then return end
	obj:OnClicked()
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
		local func = function(gm_info)
			local show_level = SuperVipData.Instance:GetShowLevel()
			self.show_super_vip:SetValue(value >= show_level and not IS_ON_CROSSSERVER)
		end
		SuperVipCtrl.Instance:GmVerifyCallBack(func)
	elseif attr_name == "gold" then
		local need_chongzhi = SuperVipData.Instance:GetNeedChongzhiNum()
		self.show_super_vip_rp:SetValue(not self.is_click_super_vip or (value >= need_chongzhi and old_value < need_chongzhi))
	end
end

function MainUIViewChat:ItemCallBack()
	local empty_num = ItemData.Instance:GetEmptyNum()
	MainUICtrl.Instance:ChangeMainUiChatIconList(string.lower(ViewName.Player), MainUIViewChat.IconList.BAG_FULL, empty_num <= 0)
end

function MainUIViewChat:ShowGuildChatRes(value)
	-- if ViewManager.Instance:IsOpen(ViewName.ChatGuild) ~= value then
	-- 	self.show_guildchat_res:SetValue(value)
	-- else
	-- 	self.show_guildchat_res:SetValue(false)
	-- end
end

function MainUIViewChat:ShowGuildChatDaTi(value)
	if ViewManager.Instance:IsOpen(ViewName.ChatGuild) ~= value then
		self.show_guildchat_redpt:SetValue(value)
	else
		self.show_guildchat_redpt:SetValue(false)
	end
end



function MainUIViewChat:ClickTuPoCallBack()
	PlayerCtrl.Instance:SendServerLevelInfo()
	TipsCtrl.Instance:OpenWorldLevelInfoView()
end

function MainUIViewChat:ClickChatInfo()
	self:SetChatinfo(false)
	ViewManager.Instance:Open(ViewName.ChatGuild)
end

function MainUIViewChat:OpenGuildStorage()
	local ok_callback = function ()
		ViewManager.Instance:Open(ViewName.Guild, TabIndex.guild_storage_destory)
	end
	TipsCtrl.Instance:OpenMessageBox(Language.Guild.StorageIsFull, ok_callback)
end

-- 附近玩家Cell
NearRoleNameCell = NearRoleNameCell or BaseClass(BaseRender)
function NearRoleNameCell:__init(instance)
	self.name = self:FindVariable("Name")
	self.show_select = self:FindVariable("ShowSelect")
end

function NearRoleNameCell:SetData(obj)
	local vo = obj and obj:GetVo() or {}
	local color = vo.name_color == EvilColorList.NAME_COLOR_WHITE and TEXT_COLOR.YELLOW or TEXT_COLOR.RED
	local name = "<color="..color..">"..(vo.name or "").."</color>"
	local cap = vo.total_capability or 0
	if cap > 0 then
		name = name .. " <color=#00ff00>"..Language.Common.ZhanLi ..":" .. cap .."</color>"
	end
	self.name:SetValue(name)
	self.show_select:SetValue(SceneObj.select_obj == obj)
end

function NearRoleNameCell:ListenClick(handler)
	self:ClearEvent("OnClickName")
	self:ListenEvent("OnClickName", handler)
end


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
	self.discount_anictrl = nil
end

function MainUIChatCell:PlayOrStopVoice(file_name)
	ChatCtrl.Instance:ClearPlayVoiceList()
	ChatCtrl.Instance:SetStartPlayVoiceState(false)
	local call_back = BindTool.Bind(self.ChangeVoiceAni, self)
	ChatRecordMgr.Instance:PlayVoice(file_name, call_back, call_back)
end

function MainUIChatCell:ChangeVoiceAni(state)
	if self.voice_animator and self.voice_animator.gameObject and not IsNil(self.voice_animator.gameObject) then
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
	local bundle, asset = ResPath.GetMainlblIcon(CHANNEL_TYPE.WORLD)
	local title_text = Language.Channel[data.channel_type or 0]
	local not_clear = false
	if CanShowChannel[data.channel_type] then
		bundle, asset = ResPath.GetMainlblIcon(data.channel_type)			
	end

	self.title:SetValue(title_text)
	self.title_bg:SetAsset(bundle, asset)
	--设置描边颜色
	local outline_color = CHANEL_TEXT_OUTLINE_COLOR[data.channel_type] or CHANEL_TEXT_OUTLINE_COLOR[CHANNEL_TYPE.WORLD]
	self.chanel_text.outline.effectColor = outline_color

	local content = data.content
	local name = data.username
	local color = TEXT_COLOR.GREEN
	if name and name ~= "" and data.username ~= Language.Channel[6] then
		local role_vo = GameVoManager.Instance:GetMainRoleVo()
		local str_name = ""
		if role_vo.role_id ~= data.from_uid then
			color = TEXT_COLOR.BLUE
		end
		str_name = string.format("{wordcolor;%s;%s:}", color, name)
		content = str_name .. content
	end

	--是否语音
	if data.content_type == CHAT_CONTENT_TYPE.AUDIO then
		local temp_str = data.content
		local tbl = {}
		for i = 1, 3 do
			local j, k = string.find(temp_str, "(%d+)")
			if j and k then
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

	if data.from_uid ~= 0 then
		content = ChatFilter.Instance:Filter(content)
	end

	RichTextUtil.ParseRichText(self.rich_text.rich_text, content, nil, color, true)
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
	local time = tbl[3] or 0
	local btn_name = "VioceButtonLeft"
	local prefab = PreloadManager.Instance:GetPrefab("uis/views/miscpreload_prefab", btn_name)
	local obj = GameObject.Instantiate(prefab)
	if obj ~= nil then
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



----------------------------------------------------------------------------
-- 主界面答题聊天弹出框
PopMainChatCell = PopMainChatCell or BaseClass(BaseRender)

function PopMainChatCell:__init()
	self.rich_text = self:FindObj("Content")
end

function PopMainChatCell:__delete()
end

function PopMainChatCell:SetData(data)
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

function PopMainChatCell:GetData()
	return self.data or {}
end

function PopMainChatCell:SetIndex(index)
	self.index = index
end

function PopMainChatCell:GetIndex()
	return self.index
end

function PopMainChatCell:GetContentHeight()
	if IsNil(self.rich_text.gameObject) then
		return 30
	end

	local rect = self.rich_text.rect
	UnityEngine.UI.LayoutRebuilder.ForceRebuildLayoutImmediate(rect)
	local hegiht = rect.rect.height < 30 and 30 or rect.rect.height
	return hegiht
end