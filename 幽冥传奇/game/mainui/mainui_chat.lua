----------------------------------------------
--主界面聊天相关 MainuiChat
--@author bzw
-----------------------------------------------

MainuiChat = MainuiChat or BaseClass()
MainuiChat.width = 425
MainuiChat.height = 80

MainuiChat.record_state = RecordState.Free		-- 录音状态
function MainuiChat:__init()
	self.chat_x = 0
	self.auto_hide_btns_time = 20
	self.btns_move_h = 165
	
	self.img9_chat_bg = nil
	self.act_btn_state = true
	
	self.chat_item_list = {}
	
	self.img_record_world = nil
	self.img_record_guild = nil
	self.icon_market = nil
	self.icon_bag = nil
	
	self.chat_head = nil
	
	self.mt_layout_transmit = nil
	self.rtxt_transmit_content = nil
	self.transmit_effect_id = 1
	self.transmit_start_time = 0
	self.show_transmit = false
	self.record_timer = nil
	self.chat_remind_t = {}
	
	self.timer_quest = nil
	self.record_btn_h = 72

	self.exp_prog = nil
	self.is_first_set_exp = true
	self.old_max_exp = 0
	self.last_exp = 0
	self.old_level = 0

	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()
	-- GlobalEventSystem:Bind(SceneEventType.SCENE_HAS_FPS_SHIELD, BindTool.Bind(self.OnSceneHasFpsShield, self))
	-- GlobalEventSystem:Bind(SettingEventType.SYSTEM_SETTING_CHANGE, BindTool.Bind1(self.OnSysSettingChange, self))

	GlobalEventSystem:Bind(MainUIEventType.CHAT_REMIND_CHANGE, BindTool.Bind(self.OnChatRemindChange, self))
	GlobalEventSystem:Bind(MainUIEventType.CHAT_CHANGE, BindTool.Bind(self.UpdateChat, self))
	local role_event_proxy = EventProxy.New(RoleData.Instance)
	role_event_proxy:AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.OnRoleAttrChange, self))

	EventProxy.New(VipData.Instance):AddEventListener(VipData.POLI_CHANGE, function (vo)
		local curr_precent = vo.count / VipChapterConfig.consumeCharm
		curr_precent = curr_precent > 1 and 1 or curr_precent
		self.vip_bar:setProgressPercent(curr_precent)
		if curr_precent >= 1 then
			local anim_path, anim_name = ResPath.GetEffectUiAnimPath(1093)
			self.vip_bar.btn_eff:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
			self.vip_bar.btn_eff:setPositionY(80)
		else
			local anim_path, anim_name = ResPath.GetEffectUiAnimPath(1094)
			self.vip_bar.btn_eff:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
			self.vip_bar.btn_eff:setPositionY(116)
		end
		local num = vo.count - vo.old_count
		if vo.need_play_eff and num > 0 then
			self.vip_bar_bg_node_2:stopAllActions()
			self.vip_number_bar:SetNumber(num)
			self.vip_bar_bg_node_2:setVisible(true)
			self.vip_bar_bg_node_2:setScale(0)
			local scale_to = cc.ScaleTo:create(0.3, 1)
			local delay_time = cc.DelayTime:create(1)
			local fade_out = cc.FadeOut:create(0.3)
			local callback_1 = cc.CallFunc:create(function()
				self.vip_bar_bg_node_2:setOpacity(255)
			end)
			local callback_2 = cc.CallFunc:create(function()
				self.vip_bar_bg_node_2:setVisible(false)
			end)
			local spawn = cc.Sequence:create(callback_1, scale_to, delay_time, fade_out, callback_2)
			self.vip_bar_bg_node_2:runAction(spawn)
		end
	end)

	EventProxy.New(DiamondPetData.Instance, self):AddEventListener(DiamondPetData.OBTAIN_DIAMOND, function (num)
		self.diamond_obtain_bg:stopAllActions()
		self.diamond_number_bar:SetNumber(num)
		self.diamond_obtain_bg:setVisible(true)
		self.diamond_obtain_bg:setScale(0)
		local scale_to = cc.ScaleTo:create(0.3, 1)
		local delay_time = cc.DelayTime:create(1)
		local fade_out = cc.FadeOut:create(0.3)
		local callback_1 = cc.CallFunc:create(function()
			self.diamond_obtain_bg:setOpacity(255)
		end)
		local callback_2 = cc.CallFunc:create(function()
			self.diamond_obtain_bg:setVisible(false)
		end)
		local spawn = cc.Sequence:create(callback_1, scale_to, delay_time, fade_out, callback_2)
		self.diamond_obtain_bg:runAction(spawn)
	end)

	local screen_w = HandleRenderUnit:GetWidth()
	local screen_h = HandleRenderUnit:GetHeight()

	GlobalEventSystem:Bind(ObjectEventType.OBJ_DEAD, function (obj)
		local is_can_get_scene = true
		for i,v in ipairs(VipChapterConfig.noCharmsFbIds) do
			if Scene.Instance:GetFuBenId() == v then
				is_can_get_scene = false
				break 
			end
		end
		if TaskData.Instance:GetCurTaskId() == 0 or TaskData.Instance:GetCurTaskId() >= ClientVipTaskId then
			if VipChapterConfig.monCharms[obj.vo.monster_type] and is_can_get_scene then
				local x, y = obj:GetRealPos()
				local mainrole_vo = GameVoManager.Instance:GetMainRoleVo()
				local c_x, c_y = Scene.Instance:GetMainRole():GetRealPos()
				local s_x = screen_w / 2 + (x - c_x)
				local s_y = screen_h / 2 + (y - c_y)
				BagCtrl.Instance:StartFlyEff("btn_vip", s_x, s_y, 1095, 3, function ()	
					RenderUnit.PlayEffectOnce(1096, self.chat_ui_node_list.layout_bottom.node, 999, 615, 63, true)
				end)
			end
		end
	end)

	GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.OnRecvMainRoleInfo, self))

	-- 场景切换
	self.scene_change = GlobalEventSystem:Bind(SceneEventType.SCENE_CHANGE_COMPLETE, function ()
		self.chat_ui_node_list.layout_dig.node:setVisible(Scene.Instance:GetSceneId() == DigOreSceneId)
	end)
end

function MainuiChat:GetVipIcon()
	return self.chat_ui_node_list.btn_vip.node
end

function MainuiChat:__delete()
	if nil ~= self.action_timer then
		GlobalTimerQuest:CancelQuest(self.action_timer)
		self.action_timer = nil
	end

	self:ClearRecordTimer()
	self:CancelAutoHideTimer()

	if self.list_view then
		self.list_view:DeleteMe()
		self.list_view = nil
	end

	NodeCleaner.Instance:AddNode(self.mt_layout_chat_root:TextLayout())
	self.mt_layout_chat_root = nil
	self.chat_ui_node_list = {}
	self.chat_ui_ph_list = {}

	self.hp_bar = nil
	self.vip_bar = nil
	self.node_zorder_t = {}

	if self.red_icon then
		self.red_icon:DeleteMe()
		self.red_icon = nil
	end
	
	self:DeleteDigTimer()

	GlobalEventSystem:UnBind(self.scene_change)
	self.scene_change = nil

	if self.grap_red_envlope then
		GlobalEventSystem:UnBind(self.grap_red_envlope)
		self.grap_red_envlope = nil
	end
	if self.recharge_change then
		GlobalEventSystem:UnBind(self.recharge_change)
		 self.recharge_change = nil
	end

	if self.vip_number_bar then
		self.vip_number_bar:DeleteMe()
		self.vip_number_bar = nil
	end

	if self.diamond_number_bar then
		self.diamond_number_bar:DeleteMe()
		self.diamond_number_bar = nil
	end
end

function MainuiChat.CreateMainuiIcon(x, y, mt_layout, res_id, click_func)
	local icon = MainUiIcon.New(100, 100)
	icon:Create(mt_layout)
	icon:SetPosition(x, y)
	icon:SetIconPath(ResPath.GetMainui("icon_" .. res_id .. "_i"))
	icon:SetBgFramePath(ResPath.GetMainui("icon_bg"))
	icon:SetBottomPath(ResPath.GetMainui("icon_" .. res_id .. "_w"), 20)
	if click_func then
		icon:AddClickEventListener(click_func)
	end
	return icon
end

function MainuiChat:Init(mt_layout_root)
	local mt_size = mt_layout_root:getContentSize()
	self.chat_x = mt_size.width / 2
	self.mt_layout_chat_root = MainuiMultiLayout.CreateMultiLayout(self.chat_x, 0, XUI.ANCHOR_POINTS[XUI.BOTTOM_CENTER], mt_size, mt_layout_root, 2)
	-- self.mt_layout_chat_root:SetBgColor(COLOR3B.GREEN)

	-- create ui
	local ui_config = ConfigManager.Instance:GetUiConfig("main_ui_cfg")
	for k, v in pairs(ui_config) do
		if v.n == "layout_bottom" then
			self.ui_cfg = v
			break
		end
	end

	self.chat_ui_node_list = {}
	self.chat_ui_ph_list = {}
	self.mt_layout_chat_root:TextureLayout():addChild(XUI.GeneratorUI(self.ui_cfg, nil, nil, self.chat_ui_node_list, nil, self.chat_ui_ph_list).node, 999, 999)

	-- 世界聊天
	self.mt_layout_chat = MainuiMultiLayout.CreateMultiLayout(self.chat_x, 20, XUI.ANCHOR_POINTS[XUI.BOTTOM_CENTER], cc.size(MainuiChat.width, MainuiChat.height), self.mt_layout_chat_root, 2)	
	local ph = self.chat_ui_ph_list.ph_chat_view
	self.list_view = ChatListView.New()
	self.list_view:Create(ph.x, ph.y, ph.w, ph.h)
	local design_height = 768
	local design_width = 1380
	local frame_size = cc.Director:getInstance():getOpenGLView():getFrameSize()
	local scale_x = frame_size.width / frame_size.height * design_height - design_width
	self.chat_ui_node_list.layout_bottom.node:setPositionX(self.chat_ui_node_list.layout_bottom.node:getPositionX() + scale_x / 2)
	self.chat_ui_node_list.layout_bottom.node:addChild(self.list_view:GetView(), 100)
	self.list_view:GetView():addTouchEventListener(BindTool.Bind(self.TouchEventCallback, self))
	
	self.chat_point = XUI.CreateImageView(MainuiChat.width - 45, MainuiChat.height - 70, ResPath.GetRemindImg(), true)
	self.mt_layout_chat:TextLayout():addChild(self.chat_point, 200)
	self.chat_point:setVisible(false)
	CommonAction.ShowRemindBlinkAction(self.chat_point)

	-- 语音
	self:CreateRecordState(500, 200, 260, 209)
	self.chat_ui_node_list.layout_record_3_icon.node:addTouchEventListener(BindTool.Bind(self.OnTouchRecord, self, CHANNEL_TYPE.WORLD))
	self.chat_ui_node_list.layout_record_2_icon.node:addTouchEventListener(BindTool.Bind(self.OnTouchRecord, self, CHANNEL_TYPE.GUILD))
	self.chat_ui_node_list.layout_record_1_icon.node:addTouchEventListener(BindTool.Bind(self.OnTouchRecord, self, CHANNEL_TYPE.TEAM))
	self.node_zorder_t = {}
	for i = 1, 3 do
		local node = self.chat_ui_node_list["layout_record_" .. i .. "_icon"].node
		node:setLocalZOrder(i)
		node:setTouchEnabled(true)
		self.node_zorder_t[node] = i
	end

	XUI.AddClickEventListener(self.chat_ui_node_list.btn_vip.node, function ()
		if TaskData.Instance:GetCurTaskId() == 0 or TaskData.Instance:GetCurTaskId() >= ClientVipTaskId then
			ViewManager.Instance:OpenViewByDef(ViewDef.Vip)
		else
			SysMsgCtrl.Instance:FloatingTopRightText("完成主线任务 ‘激活VIP’ 方可激活")
		end
	end)

	XUI.AddClickEventListener(self.chat_ui_node_list.img_mike_arrow.node, function ()
		self:OnClickRecordBtn()
	end)
	
	-- 战宠按钮逻辑
	local data = ZhanjiangCtrl.Instance.zc_data
	local function hero_state_change()
		local name = "icon_fight"
		local hero_state = data:GetHeroState()
		local is_activated = data:IsActivatedSucc()
		if hero_state == HERO_STATE.SHOW then
			name = "icon_relax"
		end
		self.chat_ui_node_list.btn_zj_fight.node:loadTexture(ResPath.GetMainui(name))
		self.chat_ui_node_list.btn_zj_fight.node:setVisible(is_activated)
	end
	EventProxy.New(data, self):AddEventListener(data.DATA_CHANGE, hero_state_change)
	EventProxy.New(data, self):AddEventListener(data.HERO_STATE_CHANGE, hero_state_change)
	hero_state_change()
	XUI.AddClickEventListener(self.chat_ui_node_list.btn_zj_fight.node, function ()
		local hero_state = data:GetHeroState()
		data:SetHeroStateReq(hero_state == HERO_STATE.REST and HERO_STATE.SHOW or HERO_STATE.REST)
		if hero_state == HERO_STATE.SHOW then
			SettingCtrl.Instance:ChangeGuaJiSetting({[GUAJI_SETTING_TYPE.AUTO_CALL_HERO] = false})
		end
	end)

	-- 经验条
	self:InitExpProg()

	--喇叭
	self:CreateHornUi(self.mt_layout_chat)

	-- 血条
	local ph = self.chat_ui_ph_list.ph_hp_pro
	-- 血条光效
	self.hp_top_eff = RenderUnit.CreateEffect(1144, self.chat_ui_node_list.layout_bottom.node, 0, nil, nil, ph.x, 0)
	self.hp_top_eff:setScale(0.8)
	self.onTopEffHpChange = function (top_height)
		self.hp_top_eff:setPositionY(top_height + ph.y / 2 - 4)
		local rate = top_height / ph.h
		if rate > 0.5 then
			rate = 1 - rate
		end
		self.hp_top_eff:setScale(rate + 0.4)
		self.hp_top_eff:setVisible(rate >= 0.06)
	end

	RenderUnit.CreateEffect(1097, self.chat_ui_node_list.layout_bottom.node, 998, nil, nil, ph.x - 30, ph.y + 22)
	local hp_bar_bg_node = XUI.CreateLayout(0, 0, ph.w,ph.h)
	local hp_effect = RenderUnit.CreateEffect(1098, nil, 998)
	hp_bar_bg_node:addChild(hp_effect)
	self.hp_bar = MaskProgressBar.New(self.chat_ui_node_list.layout_bottom.node,hp_bar_bg_node,
	 								XUI.CreateImageViewScale9(-ph.w / 2, -ph.h / 2, ph.w, ph.h, ResPath.GetCommon("img9_160"), true,cc.rect(5,5,10,10)),
	 								cc.size(ph.w, ph.h),nil,function (top_height)
	 									self.onTopEffHpChange(top_height)
	 								end)
	self.hp_bar:getView():setPosition(ph.x + 2, ph.y)
	self.hp_bar:getView():setLocalZOrder(-1)
	self.hp_bar:setProgressPercent(0)

	XUI.AddClickEventListener(self.chat_ui_node_list.layout_click.node, function ()
		ViewManager.Instance:OpenViewByDef(ViewDef.Role)
	end)

	-- vip魄力值
	local ph = self.chat_ui_ph_list.ph_vip_pro
	local vip_bar_bg_node = XUI.CreateLayout(0, 0, ph.w,ph.h)
	vip_bar_bg_node:addChild(RenderUnit.CreateEffect(1120, nil, 999))
	self.vip_bar = MaskProgressBar.New(self.chat_ui_node_list.layout_bottom.node,vip_bar_bg_node,
	 								XUI.CreateImageViewScale9(-ph.w / 2, -ph.h / 2, ph.w, ph.h, ResPath.GetCommon("img9_160"), true,cc.rect(5,5,10,10)),
	 								cc.size(ph.w, ph.h))
	self.vip_bar:getView():setPosition(ph.x + 20, ph.y + 4)
	self.vip_bar:getView():setLocalZOrder(-1)
	self.vip_bar:setProgressPercent(1)
	self.vip_bar.btn_eff = RenderUnit.CreateEffect(1094, self.chat_ui_node_list.layout_bottom.node, 999, nil, nil, ph.x - 2, ph.y + 42)

	self.vip_bar_bg_node_2 = XUI.CreateLayout(600, 230, 262, 115)
	self.vip_bar_bg_node_2:setAnchorPoint(0.5, 0)
	self.vip_bar_bg_node_2:setScale(0)
	self.vip_bar_bg_node_2:setVisible(false)
	self.chat_ui_node_list.layout_bottom.node:addChild(self.vip_bar_bg_node_2, 1000)
	local bg = XUI.CreateImageView(131, 60, ResPath.GetCommon("bg_11"), XUI.IS_PLIST)
	self.vip_bar_bg_node_2:addChild(bg, 1)
	self.vip_number_bar = NumberBar.New()
	self.vip_number_bar:Create(110, 40, 150, 60, ResPath.GetCommon("num_6_"))
	self.vip_number_bar:SetSpace(-3)
	self.vip_number_bar:SetGravity(NumberBarGravity.Center)
	self.vip_number_bar:SetHasPlus(true)
	self.vip_bar_bg_node_2:addChild(self.vip_number_bar:GetView(), 2)

	self.diamond_obtain_bg = XUI.CreateLayout(600, 230, 217, 114)
	self.diamond_obtain_bg:setAnchorPoint(0.5, 0)
	self.diamond_obtain_bg:setScale(0)
	self.diamond_obtain_bg:setVisible(false)
	self.chat_ui_node_list.layout_bottom.node:addChild(self.diamond_obtain_bg, 1000)
	local bg = XUI.CreateImageView(131, 60, ResPath.GetCommon("bg_12"), XUI.IS_PLIST)
	self.diamond_obtain_bg:addChild(bg, 1)
	self.diamond_number_bar = NumberBar.New()
	self.diamond_number_bar:Create(100, 0, 150, 60, ResPath.GetCommon("num_7_"))
	self.diamond_number_bar:SetSpace(-3)
	self.diamond_number_bar:SetGravity(NumberBarGravity.Center)
	-- self.diamond_number_bar:SetHasPlus(true)
	self.diamond_obtain_bg:addChild(self.diamond_number_bar:GetView(), 2)

	-- 挖矿相关
	self.chat_ui_node_list.btn_find_dig.node:setVisible(not ExperimentData.Instance:IsDiging())
	self.chat_ui_node_list.img_dig_award_tip.node:setVisible(ExperimentData.Instance:CheckCanLingquDigAward())
	EventProxy.New(ExperimentData.Instance, self):AddEventListener(ExperimentData.INFO_CHANGE, function ()
		self:FlushDigTimer()
		self.chat_ui_node_list.btn_find_dig.node:setVisible(not ExperimentData.Instance:IsDiging())
		self.chat_ui_node_list.img_dig_award_tip.node:setVisible(ExperimentData.Instance:CheckCanLingquDigAward())
	end)

	
	RenderUnit.CreateEffect(1185, self.chat_ui_node_list.btn_find_dig.node, 2, FrameTime.Effect, COMMON_CONSTS.MAX_LOOPS, 44, 38)

	XUI.AddClickEventListener(self.chat_ui_node_list.btn_find_dig.node, function ()
		if ExperimentData.Instance:IsDiging() then 
			SysMsgCtrl.Instance:FloatingTopRightText(Language.Dig.FindDigTip2)
			return 
		end
		if ExperimentCtrl.Instance:IsNeedOpenAwardView() then return end	

		if not ExperimentData.Instance:CanDig() then
			SysMsgCtrl.Instance:FloatingTopRightText(Language.Dig.FindDigTip3)
			return
		end
		
		local obj = Scene.Instance:GetSceneLogic().GetNearPlayerObj and Scene.Instance:GetSceneLogic():GetNearPlayerObj()
		if nil == obj then
			SysMsgCtrl.Instance:FloatingTopRightText(Language.Dig.FindDigTip)
		else
			GuajiCtrl.Instance:MoveToObj(obj, 0, 0)
		end	
	end)
	self.red_icon = MainUiIcon:CreateMainuiIcon(self.mt_layout_chat,"53", MainuiChat.width, MainuiChat.height + 80)
	
	self.red_icon:AddClickEventListener(function ( ... )
		ViewManager.Instance:OpenViewByDef(ViewDef.GrapRobRedEnvelope)
	end)
	self.grap_red_envlope = GlobalEventSystem:Bind(GRAP_REDENVELOPE_EVENT.GetGrapRedEnvlope, BindTool.Bind1(self.FlushShow,self))
	self.recharge_change = GlobalEventSystem:Bind(OtherEventType.TODAY_CHARGE_GOLD_CHANGE, BindTool.Bind1(self.FlushShow,self))

	EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.RoleDataChangeCallback, self))
	
end

function MainuiChat:FlushShow()
	local num = GrabRedEnvelopeData.Instance:GetIsCanLingQu()
	self.red_icon:SetRemindNum(num, 60, 60, 1)
	if num >= 1 then
		local rotationTo1 = cc.RotateTo:create(0.4, 30)
		--local rotationTo3 = cc.RotateTo:create(0.1, 0)
		local rotationTo2 = cc.RotateTo:create(0.4, -30)
		 local action = cc.RepeatForever:create(cc.Sequence:create(rotationTo1, rotationTo2))
		 self.red_icon:GetView():runAction(action)
	else
		self.red_icon:GetView():stopAllActions()
		local rotationTo3 = cc.RotateTo:create(0.1, 0) --位置还原
		local action = cc.Sequence:create(rotationTo3)
		self.red_icon:GetView():runAction(action)	
	end
	-- local vis = GrabRedEnvelopeData.Instance:HadGetAll()
	-- self.red_icon:SetVisible(not vis)
	self:SetRedIconVis()
end

function MainuiChat:RoleDataChangeCallback(vo)
	if vo.key == OBJ_ATTR.CREATURE_LEVEL then
		self:SetRedIconVis()
	end
end
	
function MainuiChat:SetRedIconVis()
	local vis = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL) >= GameCond.CondId149.RoleLevel


	if vis then
		-- 开放时需主动请求一次数据
		if not self.red_icon:GetView():isVisible() and GrabRedEnvelopeData.Instance:GetCurLevel() == nil then
			GrabRedEnvelopeCtrl.SendGetChargeRedEnvlopeData()
			return
		end
		
		vis = not GrabRedEnvelopeData.Instance:HadGetAll() --检测是否领完
	end

	self.red_icon:SetVisible(vis)
end

function MainuiChat:GetRedIcon()
	return self.red_icon
end

function MainuiChat:DigTimerFunc()		
	local time2 = ExperimentData.Instance:GetBaseInfo().start_dig_time + MiningActConfig.finTimes - TimeCtrl.Instance:GetServerTime() --结束挖矿时间
	self.chat_ui_node_list.img_dig_tip.node:setVisible(time2 <= 0 and not ExperimentData.Instance:CheckCanLingquDigAward())
	self.get_item_link:setVisible(time2 > 0)
	self.chat_ui_node_list.lbl_time_tip.node:setVisible(time2 > 0)
	if time2 <= 0 then
		self:DeleteDigTimer()
	else
		self.chat_ui_node_list.lbl_time_tip.node:setString("挖矿中(" .. TimeUtil.FormatSecond(time2) .. ")")
	end
end

function MainuiChat:FlushDigTimer()
	if nil == self.get_item_link then
		self.get_item_link = RichTextUtil.CreateLinkText("快速完成", 20, COLOR3B.GREEN)
		self.get_item_link:setPosition(224, 99)
		self.chat_ui_node_list.layout_dig.node:addChild(self.get_item_link, 50)
		XUI.AddClickEventListener(self.get_item_link, function () 
			if self.alert == nil then
				self.alert = Alert.New()
			end
			-- self.alert:SetShowCheckBox(true)
			self.alert:SetLableString(string.format(Language.Dig.QuickCompelte, MiningActConfig.endConsume[1].count))
			self.alert:SetOkFunc(function ()	
				ExperimentCtrl.SendExperimentOptReq(4)
		  	end)
			self.alert:Open()
		end)
	end

	if nil == self.dig_timer and ExperimentData.Instance:IsDiging() then
		self.dig_timer = GlobalTimerQuest:AddRunQuest(function ()
			self:DigTimerFunc()
		end, 1)
	end
	self:DigTimerFunc()
end

function MainuiChat:DeleteDigTimer()
	if self.dig_timer ~= nil then
		GlobalTimerQuest:CancelQuest(self.dig_timer)
		self.dig_timer = nil
	end
end

function MainuiChat:AddRecordIcon(res_id, channel_type)
	self.layout_record.record_num = self.layout_record.record_num + 1
	self.layout_record:setContentWH(self.record_btn_h, self.layout_record.record_size.height * self.layout_record.record_num + (self.layout_record.record_num - 1) * 10)

	self.layout_record.arrow_node:setPosition(self.layout_record:getContentSize().width / 2, self.layout_record:getContentSize().height + 25)

	local size = self.layout_record.record_size
	local y = self.layout_record.record_size.height / 2 + (self.layout_record.record_num - 1) * (self.layout_record.record_size.height + 10)
	local icon = XUI.CreateLayout(self.layout_record:getContentSize().width / 2, y, self.record_btn_h, self.record_btn_h)
	icon:addChild(XUI.CreateImageView(size.width / 2, size.height / 2, ResPath.GetMainui("icon_" .. res_id .. "_i"), true), 2)
	icon:addChild(XUI.CreateImageView(size.width / 2, size.height / 2, ResPath.GetMainui("icon_bg"), true), 1)
	icon:addChild(XUI.CreateImageView(size.width / 2, size.height / 2 - 30, ResPath.GetMainui("icon_" .. res_id .. "_w"), true), 3)
	icon:addTouchEventListener(BindTool.Bind(self.OnTouchRecord, self, channel_type))
	icon:setTouchEnabled(true)
	self.layout_record:addChild(icon)
	return icon
end	

function MainuiChat:InitRecord()
	self:CreateRecordState(0, 150, 260, 209)
	self.layout_record = XUI.CreateLayout(-10, 0, self.record_btn_h, 0)
	self.layout_record:setAnchorPoint(1, 0)
	self.mt_layout_chat:TextureLayout():addChild(self.layout_record, 10)
	-- self.layout_record:setBackGroundColor(COLOR3B.GREEN)
	-- self.layout_record:setBackGroundColorOpacity(100)

	self.layout_record.begin_pos = cc.p(-10, 5)
	self.layout_record.record_num = 0
	self.layout_record.is_extend = false
	self.layout_record.is_acting = false
	self.layout_record.record_size = cc.size(self.record_btn_h, self.record_btn_h)
	self.layout_record.arrow_node = XUI.CreateImageView(0, 0, ResPath.GetMainui("img_arrow"))
	self.layout_record.FlushExtend = function()
		self.layout_record:stopAllActions()
		self.layout_record.is_acting = false
		if self.layout_record.is_extend then
			self.layout_record:setPositionY(self.layout_record.begin_pos.y)
			self.layout_record.arrow_node:setRotation(180)
		else
			self.layout_record:setPositionY(self.layout_record.begin_pos.y - self.layout_record:getContentSize().height + self.layout_record.record_size.height)
			self.layout_record.arrow_node:setRotation(0)
		end

	end
	XUI.AddClickEventListener(self.layout_record.arrow_node, function()
		if self.layout_record.is_acting then
			return
		end

		self.layout_record.is_extend = not self.layout_record.is_extend
		self.layout_record.is_acting = true
		local x, y = self.layout_record:getPosition()
		if self.layout_record.is_extend then
			y = self.layout_record.begin_pos.y
		else
			y = self.layout_record.begin_pos.y - self.layout_record:getContentSize().height + self.layout_record.record_size.height
		end
		
		self.layout_record:runAction(cc.Sequence:create(cc.MoveTo:create(0.2, cc.p(x, y)), cc.CallFunc:create(self.layout_record.FlushExtend)))
	end)
	self.layout_record:addChild(self.layout_record.arrow_node)

	self.record_list = {
		{channel_type = CHANNEL_TYPE.TEAM, res_id = 202},
		{channel_type = CHANNEL_TYPE.GUILD, res_id = 201},
		{channel_type = CHANNEL_TYPE.WORLD, res_id = 200},
	}
	for k, v in pairs(self.record_list) do
		self:AddRecordIcon(v.res_id, v.channel_type)
	end

	self.layout_record.FlushExtend()

end

function MainuiChat:UpdateChat(chat_data)
	local channel = ChatData.Instance:GetChannel(CHANNEL_TYPE.ALL)
	ChatView.UpdateContentListView(self.list_view, channel.msg_list, channel.unread_num, false)
end

local click_begin = {x = 0, y = 0}
local click_end = {x = 0, y = 0}
function MainuiChat:TouchEventCallback(sender, event_type, touch)
	if event_type == XuiTouchEventType.Began then
		click_begin = touch:getLocation()
	elseif event_type == XuiTouchEventType.Moved then
		
	elseif event_type == XuiTouchEventType.Ended then
		click_end = touch:getLocation()
		if math.abs(click_end.x - click_begin.x) < 10 and math.abs(click_end.y - click_begin.y) < 10 then
			ViewManager.Instance:OpenViewByDef(ViewDef.Chat)
		end
	end
end

function MainuiChat:InitExpProg()
	local root_size = self.mt_layout_chat_root:getContentSize()

	-- 经验
	self.exp_width = 590	-- 经验进度条
	local exp_x = root_size.width / 2 + 38 -- 经验进度条中点坐标
	self.exp_prog = XUI.CreateLoadingBar(self.exp_width / 2 + 93, 15, ResPath.GetMainui("exp_loading"), true)
	self.exp_prog:setScale9Enabled(true)
	self.exp_prog:setContentWH(self.exp_width, 13)
	self.chat_ui_node_list.layout_bottom.node:addChild(self.exp_prog, 3)

	self.exp_prog_bar = ProgressBar.New()
	self.exp_prog_bar:SetView(self.exp_prog)
	self.exp_prog_bar:SetTotalTime(1)
	-- self.exp_prog_bar:SetTailEffect(991)
	-- self.exp_prog_bar:SetEffectOffsetX(-1)

	--为调整安卓显示问题，将text改为richtext
	XUI.RichTextSetCenter(self.chat_ui_node_list.rich_txt.node)
end

function MainuiChat:OnRecvMainRoleInfo()
	self:SetExpProgValue(RoleData.Instance:GetExp(), RoleData.Instance:GetMaxExp(), false)
	self:OnHpChange(RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_HP) / RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_MAX_HP))
	self:SetRedIconVis()
end

function MainuiChat:OnHpChange(rate)
	self.hp_bar:setProgressPercent(rate, true)
end

function MainuiChat:OnRoleAttrChange(vo)
	local key = vo.key
	if key == OBJ_ATTR.ACTOR_EXP_L or key == OBJ_ATTR.ACTOR_EXP_H
		or key == OBJ_ATTR.ACTOR_MAX_EXP_L or key == OBJ_ATTR.ACTOR_MAX_EXP_H then
		self:SetExpProgValue(RoleData.Instance:GetExp(), RoleData.Instance:GetMaxExp(), vo.is_delay)
	elseif key == OBJ_ATTR.CREATURE_HP or key == OBJ_ATTR.CREATURE_MAX_HP then
		-- self:SetMainRoleHp(RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_HP), RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_MAX_HP))
		self:OnHpChange(RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_HP) / RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_MAX_HP))
	end
end

-- 设置经验值
function MainuiChat:SetExpProgValue(cur_exp, max_exp, is_delay)
	if max_exp <= 0 then return end

	local percent = 100 * (cur_exp / max_exp)
	if percent > 100 then percent = 100 end

	if self.is_first_set_exp then
		self.is_first_set_exp = false
		self.exp_prog_bar:SetPercent(percent)
	else
		if self.exp_prog:getPercent() > percent then
			self.exp_prog_bar:SetPercent(0)
		end
		self.exp_prog_bar:SetPercent(percent, 66)
	end

	local txt = string.format("EXP: %s/%s  {wordcolor;1eff00;(%s%%)}", cur_exp, max_exp, math.floor(percent * 100) / 100)
	RichTextUtil.ParseRichText(self.chat_ui_node_list.rich_txt.node, txt)

	local add_exp = cur_exp - self.last_exp
	if self.old_max_exp < max_exp then
		add_exp = cur_exp + self.old_max_exp - self.last_exp
	end

	if SceneText.ExpEffect.old_role_exp < 0 then
		if nil == self.exp_timer then
			self.exp_timer = GlobalTimerQuest:AddDelayTimer(function()
				self.exp_timer = nil
				--SceneText.ExpEffect.old_role_exp = add_exp
			end, 2)
		end
		
	else
		if nil == self.exp_timer then
			if RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL) >= self.old_level 
				and add_exp >= 5000000
				and add_exp < 1e+014
				and not is_delay then
				self.exp_timer = GlobalTimerQuest:AddDelayTimer(function()
					self.exp_timer = nil
					--SceneText.PlayExpChangeEffect(add_exp)
				end, 0.5)
			end
			
		end
	end
	if cur_exp > self.last_exp or max_exp > self.old_max_exp then
		self.last_exp = cur_exp
	end
	self.old_max_exp = max_exp
	self.old_level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
end
----------------------------------------------------------------------------------------------

function MainuiChat:OnClickAutoFight()
	if GuajiCache.guaji_type ~= GuajiType.Auto then
		Scene.Instance:GetMainRole():StopMove()
		GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
		self:CancelAutoFightRemindEffect()
	else
		Scene.Instance:GetMainRole():StopMove()
	end

	ActivityCtrl.StopAutoEscort()
end

function MainuiChat:ActAutoFightRemindEffect()
	if self.btn_auto_fight then
		UiInstanceMgr.AddCircleEffect(self.btn_auto_fight)
	end
end

function MainuiChat:CancelAutoFightRemindEffect()
	if self.btn_auto_fight then
		UiInstanceMgr.DelCircleEffect(self.btn_auto_fight)
	end
end

function MainuiChat:OnCompleteChangeBtnsShow()
	GlobalTimerQuest:CancelQuest(self.change_btns_show_timer)
	self.change_btns_show_timer = nil
	self:FlushLayoutBtns()
end

function MainuiChat:OnChangeBtnsShow(vis)
	if nil ~= self.change_btns_show_timer then
		return
	end
	
	if nil ~= vis then
		if self.is_show_btns == vis then
			return
		end
		self.is_show_btns = vis
	else
		self.is_show_btns = not self.is_show_btns
	end
	
	self.img_arrow:setVisible(false)
	self.img_r_arrow:setVisible(false)
	
	local action_time = 0.2
	local timer_time = 0.3
	if self.is_show_btns then
		self.mt_layout_btns:setPosition(0, - self.btns_move_h)
		self.mt_layout_btns:setVisible(true)
		self.change_btns_show_timer = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.OnCompleteChangeBtnsShow, self), timer_time)
		local sequence = cc.Sequence:create(cc.MoveTo:create(action_time, cc.p(0, 0)))
		self.mt_layout_btns:runAction(sequence)
	else
		self.mt_layout_btns:setPosition(0, 0)
		self.mt_layout_btns:setVisible(true)
		self.change_btns_show_timer = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.OnCompleteChangeBtnsShow, self), timer_time)
		local sequence = cc.Sequence:create(cc.MoveTo:create(action_time, cc.p(0, - self.btns_move_h)))
		self.mt_layout_btns:runAction(sequence)
	end
end

function MainuiChat:CancelAutoHideTimer()
	if nil ~= self.auto_hide_btns_timer then
		GlobalTimerQuest:CancelQuest(self.auto_hide_btns_timer)
		self.auto_hide_btns_timer = nil
	end
end

function MainuiChat:StartAutoHideBtns()
	self:CancelAutoHideTimer()
	self.auto_hide_btns_timer = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.OnAutoHideBtns, self), self.auto_hide_btns_time)
end

function MainuiChat:OnAutoHideBtns()
	-- 屏蔽隐藏该功能
	-- self:OnChangeBtnsShow(false)
end

function MainuiChat:FlushLayoutBtns()
	self.mt_layout_btns:setVisible(self.is_show_btns)
	self.img_arrow:setVisible(not self.is_show_btns)
	self.img_r_arrow:setVisible(not self.is_show_btns)
	
	if self.is_show_btns then
		self.mt_layout_btns:setPosition(0, 0)
		
		self:StartAutoHideBtns()
	else
		self.mt_layout_btns:setPosition(0, - self.btns_move_h)
	end
end


-- function MainuiChat:ChatRemindGroupChange(group_name, num)
	-- if group_name == RemindGroupName.GuajiReward then
	-- 	if num > 0 and self.icon_guaji then
	-- 		self.icon_guaji:PlayIconEffect(924, {x = 45, y = 48})
	-- 		-- self.icon_guaji.icon_effect:setScale(0.83)
	-- 		-- self.icon_guaji.icon_effect:setLocalZOrder(-10)
	-- 	else
	-- 		self.icon_guaji:RemoveIconEffect(924)
	-- 	end
	-- end
	-- if group_name == RemindGroupName.RoleView then
	-- 	if num > 0 then
			-- self.icon_role:PlayIconTextureEffect(924, nil, nil, 1.1)
		-- else
			-- self.icon_role:RemoveIconTextureEffect(924)
-- 		end
-- 	end
-- end

function MainuiChat:ChangeBtnState(state)
	self.act_btn_state = state
	if state then
		self.mt_layout_chat:setVisible(true)
		self.mt_layout_chat:FadeIn(PLAY_TIME)
	else
		self.mt_layout_chat:FadeOut(PLAY_TIME)
	end
	local function on_aciton_comoplete()
		self.action_timer = nil
		self.mt_layout_chat:setVisible(state)
		self:UpdatePos()
	end
	self.action_timer = GlobalTimerQuest:AddDelayTimer(on_aciton_comoplete, PLAY_TIME)
end

function MainuiChat:ChangeShowState(show_menu)
	-- if show_menu then
	-- 	self.mt_layout_chat_root:setVisible(false)
	-- 	self.mt_layout_transmit:setVisible(false)
	-- else
	-- 	self.mt_layout_chat_root:setVisible(true)
	-- 	self.mt_layout_transmit:setVisible(self.show_transmit)
	-- end
end

function MainuiChat:ChangeShowStateComoplete(show_menu)
end

--更新聊天内容
function MainuiChat:UpdateWorldChatContent(chat_msg_info)
	local channel = ChatData.Instance:GetChannel(CHANNEL_TYPE.ALL)
	ChatView.UpdateContentListView(self.list_view, channel.msg_list, channel.unread_num, false)
	self:UpdatePos()
end

function MainuiChat:OnChatItemFlush()
	self:UpdatePos()
end

function MainuiChat:UpdatePos()
	self.mt_layout_transmit:setPositionY(self.mt_layout_chat_root:getPositionY() + MainuiChat.height + 20)
	
	self:UpdateTipPos()
end

function MainuiChat:CreateRecordIcon(mt_layout, x, y, res)
	local icon = XUI.CreateImageView(x, y, res, true)
	mt_layout:TextureLayout():addChild(icon)
	icon:setTouchEnabled(true)
	return icon
end

local h_touch_time = Status.NowTime
local timer = nil
local zOrder2posY = {[1] = 148, [2] = 88, [3] = 28}
local is_show = false

function MainuiChat:OnClickRecordBtn(click_node)
	if not is_show then
		self.chat_ui_node_list.img_mike_arrow.node:setScaleY(-1)
		self.chat_ui_node_list.img_mike_arrow.node:setPositionY(zOrder2posY[1] + 40)
		for i = 1, 3 do
			local node = self.chat_ui_node_list["layout_record_" .. i .. "_icon"].node
			node:setPositionY(zOrder2posY[node:getLocalZOrder()])
		end
	else
		self.chat_ui_node_list.img_mike_arrow.node:setScaleY(1)
		self.chat_ui_node_list.img_mike_arrow.node:setPositionY(zOrder2posY[3] + 40)
		if click_node then	
			for k,v in pairs(self.node_zorder_t) do
				if v == 3 then
					self.node_zorder_t[k], self.node_zorder_t[click_node] = self.node_zorder_t[click_node], self.node_zorder_t[k]
					break
				end
			end
		end

		for i = 1, 3 do
			local node = self.chat_ui_node_list["layout_record_" .. i .. "_icon"].node
			node:setLocalZOrder(self.node_zorder_t[node])
			node:setPositionY(zOrder2posY[3])
		end
	end
	is_show = not is_show
end

function MainuiChat:OnTouchRecord(channel, sender, event_type, touch)
	self.cur_record_channel = channel
	local start_time = Status.NowTime
	local check_touch_func = function ()
		h_touch_time = Status.NowTime - start_time
		if h_touch_time >= 0.6 then
			self:Start()
		end
		local move_position = sender:convertToNodeSpace(touch:getLocation())
		if math.abs(move_position.y - self.record_btn_h / 2) > 100 then
			self:Finish(false)
		end
	end
	if event_type == XuiTouchEventType.Began then		
		if nil == timer then
			timer = GlobalTimerQuest:AddRunQuest(check_touch_func, 0.02)
			check_touch_func()
		end
	elseif event_type == XuiTouchEventType.Moved then
		-- local move_position = sender:convertToNodeSpace(touch:getLocation())
		-- if math.abs(move_position.y - self.record_btn_h / 2) > 100 then
		-- 	self:Finish(false)
		-- end
	else
		if timer ~= nil then
			GlobalTimerQuest:CancelQuest(timer)
			timer = nil
		end
		if h_touch_time < 0.6 then
			self:OnClickRecordBtn(sender)
		end
		h_touch_time = 0


		local end_position = sender:convertToNodeSpace(touch:getLocation())
		if math.abs(end_position.y - self.record_btn_h / 2) > 100 then
			self:Finish(false)
		else
			self:Finish(true)
		end
	end
end

-- 开始录音
function MainuiChat:Start()
	if ChatData.ExamineChannelRule(self.curr_send_channel) == false then
		return
	end
	
	if MainuiChat.record_state == RecordState.Free then
		if AudioManager.Instance:StartMediaRecord() then
			MainuiChat.record_state = RecordState.Recording
			self.record_start_time = Status.NowTime
			self:OpenStateView()
		else
			if cc.PLATFORM_OS_IPHONE == PLATFORM or cc.PLATFORM_OS_IPAD == PLATFORM then
				SysMsgCtrl.Instance:ErrorRemind(Language.Chat.NotRecordPermissionIOS)
			else
				SysMsgCtrl.Instance:ErrorRemind(Language.Chat.RecordFail)
			end
		end
	end
end

-- 完成录音
function MainuiChat:Finish(is_send)
	if MainuiChat.record_state == RecordState.Recording then
		self:CloseStateView()
		if is_send then
			MainuiChat.record_state = RecordState.Uploading
			self:OnSoundUpLoadingHandler()
		else
			MainuiChat.record_state = RecordState.Free
			AudioManager.Instance:StopMediaRecord()
		end
	end
end

-- 上传声音处理
function MainuiChat:OnSoundUpLoadingHandler()
	local path = AudioManager.Instance:StopMediaRecord()
	if "" == path then
		SysMsgCtrl.Instance:ErrorRemind(Language.Chat.RecordFail)
		MainuiChat.record_state = RecordState.Free
		return
	end
	
	local duration = math.floor((Status.NowTime - self.record_start_time) * 10)
	if duration < 10 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Chat.RecordToShort)
		MainuiChat.record_state = RecordState.Free
		return
	end
	
	local role_id = RoleData.Instance.role_vo.role_id
	local time = math.floor(TimeCtrl.Instance:GetServerTime())
	
	self.sound_name = string.format("sound_%s_%s_%s.amr", time, role_id, duration)
	self.sound_url = ChatRecordMgr.GetUrlSoundPath(self.sound_name)
	
	local callback = BindTool.Bind1(self.UploadCallback, self)
	if not HttpClient:Upload(self.sound_url, path, callback) then
		MainuiChat.record_state = RecordState.Free
	end
end

-- 上传回调
function MainuiChat:UploadCallback(url, path, size)
	MainuiChat.record_state = RecordState.Free
	if size > 0 then
		self:SendSoundMsg(self.sound_name)
		local sound_path = ChatRecordMgr.GetCacheSoundPath(self.sound_name)
		PlatformAdapter.MoveFile(path, sound_path)
	end
end
-- 发送语音消息
function MainuiChat:SendSoundMsg(message)
	ChatCtrl.Instance:SendChannelChat(self.cur_record_channel, message, CHAT_CONTENT_TYPE.AUDIO)
end

-- 创建录音状态界面
function MainuiChat:CreateRecordState(x, y, w, h, has_bg)
	
	self.record_state_view = XUI.CreateLayout(x, y, w, h)
	if has_bg then
		self.record_state_view:setBackGroundColor(COLOR3B.BLACK)
		self.record_state_view:setBackGroundColorOpacity(128)
	end
	self.record_state_view:setVisible(false)
	self.record_state_view:setAnchorPoint(0, 0)
	self.mt_layout_chat_root:TextureLayout():addChild(self.record_state_view)
	
	local img_state_bg = XUI.CreateImageView(100, 100, ResPath.GetMainui("chat_record_bg"), true)
	self.record_state_view:addChild(img_state_bg)
	
	self.line_list = {}
	for i = 1, 4 do
		local item_y = i * 30 + 30
		local item_w =(i - 1) * 13 + 38
		local line = XUI.CreateImageViewScale9(200, item_y, item_w, 21, ResPath.GetMainui("chat_record_bg2"), true)
		self.record_state_view:addChild(line)
		table.insert(self.line_list, line)
	end
	
	local record_tips = XUI.CreateText(120, 0, item_w, 30, cc.TEXT_ALIGNMENT_CENTER, Language.Chat.RecordTips, nil, 26)
	self.record_state_view:addChild(record_tips)
	
	self.text_record_state = XUI.CreateText(200, 30, 100, 30, nil, "", nil, 26)
	self.record_state_view:addChild(self.text_record_state)
end
-- 打开录音面板
function MainuiChat:OpenStateView()
	if self.record_state_view:isVisible() then
		return
	end
	self.record_state_view:setVisible(true)
	
	local state_index = 1
	local function state_update()
		for i, v in ipairs(self.line_list) do
			v:setVisible(i <= state_index)
			
			local residue_time = 8 - math.floor(Status.NowTime - self.record_start_time)
			self.text_record_state:setString(string.format("(%d)", residue_time))
			if residue_time <= 0 then
				self:Finish(true)
			end
		end
		
		state_index = state_index + 1
		if state_index > #self.line_list then state_index = 1 end
	end
	
	state_update()
	self:ClearRecordTimer()
	self.record_timer = GlobalTimerQuest:AddTimesTimer(state_update, 1, 100)
end

-- 关闭录音面板
function MainuiChat:CloseStateView()
	self.record_state_view:setVisible(false)
	self:ClearRecordTimer()
end

function MainuiChat:ClearRecordTimer()
	if nil ~= self.record_timer then
		GlobalTimerQuest:CancelQuest(self.record_timer)
		self.record_timer = nil
	end
end

-----------------------私聊头像 begin---------------------------
--更新聊天头象显示
function MainuiChat:UpdataChatHead()
	if self.chat_head == nil then
		self.chat_head = MainuiChatHead.New()
		self.mt_layout_chat:TextureLayout():addChild(self.chat_head:GetView())
		self.chat_head:GetView():setPosition(MainuiChat.width + 100, 125)
		self.chat_head:GetView():addClickEventListener(BindTool.Bind2(self.ClickChatHeadHandler, self, self.chat_head))
	end
	
	local is_visible
	local data = ChatData.Instance:GetPrivateUnreadList()
	if #data > 0 then
		self.chat_head:SetChatData(data[1])
		is_visible = true
	else
		is_visible = false
	end
	self.chat_head:GetView():setVisible(is_visible)
end

function MainuiChat:RemoveChatHead(role_uid)
	ChatData.Instance:RemPrivateUnreadMsg(role_uid)
	self:UpdataChatHead()
end

--点击角色头象
function MainuiChat:ClickChatHeadHandler(chat_head)
	local uid = chat_head:GetRoleUid()
	local index = ChatData.Instance:GetPrivateIndex(uid)
	ChatCtrl.Instance:OpenPrivate(index)
	self:RemoveChatHead(uid)
end
-----------------------私聊头像 end---------------------------
-----------------------喇叭 begin---------------------------
function MainuiChat:CreateHornUi(mt_layout_root)
	local horn_h = 50
	self.mt_layout_transmit = MainuiMultiLayout.CreateMultiLayout(self.chat_x-825, MainuiChat.height + 530, cc.p(0, 1), cc.size(MainuiChat.width, horn_h), mt_layout_root)
	self.img9_transmit_bg = XUI.CreateImageViewScale9(0, 0, MainuiChat.width, horn_h, ResPath.GetMainui("chat_bg"), true)
	self.img9_transmit_bg:setAnchorPoint(0, 0)
	self.mt_layout_transmit:TextureLayout():addChild(self.img9_transmit_bg)
	
	self.rtxt_transmit_content = XUI.CreateRichText(30, 64, MainuiChat.width - 25, 44, false)
	self.rtxt_transmit_content:setVerticalSpace(1)
	self.rtxt_transmit_content:setAnchorPoint(0, 1)
	self.rtxt_transmit_content:setMaxLine(3)
	self.mt_layout_transmit:TextLayout():addChild(self.rtxt_transmit_content)
	
	self.eff = RenderUnit.CreateEffect(915, self.mt_layout_transmit:EffectLayout(), nil, nil, nil, 15, horn_h / 2)
	
	self:HideTransmitChat()
end

function MainuiChat:OpenHorn(msg_info)
	if msg_info == nil then return end
	
	if nil == self.transmit_timer then
		self.transmit_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind1(self.UpdateTransmitEffect, self), 0.12)
	end
	
	self.transmit_start_time = Status.NowTime
	
	local str = string.format("{wordcolor;00ff00;%s:}", msg_info.name) .. msg_info.content
	
	RichTextUtil.ParseRichText(self.rtxt_transmit_content, str, 22, COLOR3B.YELLOW)
	
	self.rtxt_transmit_content:refreshView()
	local height = self.rtxt_transmit_content:getInnerContainerSize().height + 12
	if height < 50 then height = 50 end
	local size = cc.size(MainuiChat.width, height)
	self.mt_layout_transmit:setContentSize(size)
	self.img9_transmit_bg:setContentSize(size)
	self.rtxt_transmit_content:setPositionY(height - 6)
	
	self:ShowTransmitChat()
end

function MainuiChat:UpdateTransmitEffect()
	if Status.NowTime - self.transmit_start_time >= 5 then
		if nil ~= self.transmit_timer then
			GlobalTimerQuest:CancelQuest(self.transmit_timer)
			self.transmit_timer = nil
		end
		
		self:HideTransmitChat()
		return
	end
	
	-- self.transmit_effect_id = self.transmit_effect_id + 1
	-- if self.transmit_effect_id > 5 then
	-- 	self.transmit_effect_id = 1
	-- end
	-- self.img_transmit_effect:loadTexture(ResPath.GetMainui("chat_eff_" .. self.transmit_effect_id))
end

function MainuiChat:ShowTransmitChat()
	self.show_transmit = true
	self.mt_layout_transmit:setVisible(true)
	self:UpdateTipPos()
end

function MainuiChat:HideTransmitChat()
	self.show_transmit = false
	self.mt_layout_transmit:setVisible(false)
	self:UpdateTipPos()
end
-----------------------喇叭 end---------------------------
-- 更新Tip位置
function MainuiChat:UpdateTipPos()
	local height = MainuiChat.height + 25
	if self.mt_layout_transmit:isVisible() then
		height = height + self.mt_layout_transmit:getContentSize().height + 6
	end
end

function MainuiChat:OnNpcDialogOpen()
	self.mt_layout_chat:setVisible(false)
end

function MainuiChat:OnNpcDialogClose()
	self.mt_layout_chat:setVisible(true)
end

function MainuiChat:OnGetUiNode(node_name)
	local view_node = ViewManager.Instance:GetViewByStr(node_name)
	if view_node == ViewDef.Bag then
		-- return self.icon_bag:GetView():TextureLayout(), true
	elseif node_name == NodeName.MainuiRoleExp then
		return self.exp_prog
	end
	return nil, nil
end

function MainuiChat:OnChatRemindChange(index, value)
	if value then
		self.chat_remind_t[index] = value
	else
		self.chat_remind_t[index] = nil
	end
	self.chat_point:setVisible(next(self.chat_remind_t) ~= nil)
end

function MainuiChat:OnSceneHasFpsShield(value)
	self.has_fps_shield = value
	self.icon_pingbi:SetVisible(not self.is_pingbi_other_role and self.has_fps_shield)
end

function MainuiChat:OnSysSettingChange(setting_type, flag)
	if setting_type == SETTING_TYPE.SHIELD_OTHERS then
		self.is_pingbi_other_role = flag
		self.icon_pingbi:SetVisible(not self.is_pingbi_other_role and self.has_fps_shield)
	end
end

function MainuiChat:OnGuajiTypeChange(guaji_type)
	if guaji_type == GuajiType.Auto then
		self.btn_auto_fight:setTogglePressed(true)
	else
		self.btn_auto_fight:setTogglePressed(false)
	end
	self:CancelAutoFightRemindEffect()
end

----------------------------------------------
--私人聊天人物图标  MainuiChatHead
----------------------------------------------
MainuiChatHead = MainuiChatHead or BaseClass()
function MainuiChatHead:__init()
	self.chat_data = nil
	
	self.width = 70
	self.height = 70
	
	self.view = XUI.CreateLayout(0, 0, self.width, self.height)
	self.view:setTouchEnabled(true)
	
	self.icon_bg = XUI.CreateImageView(self.width / 2, self.height / 2, ResPath.GetCommon("cell_105"), true)
	self.view:addChild(self.icon_bg)
	
	self.icon = XUI.CreateImageView(self.width / 2, self.height / 2, ResPath.GetCommon("cell_105"), true)
	self.icon:setScale(0.96)
	self.view:addChild(self.icon)
	
	local anim_aprite = RenderUnit.CreateEffect(3046, self.view, 100, 0.08)
	anim_aprite:setScale(1.2)
end

function MainuiChatHead:__delete()
	AvatarManager.Instance:CancelUpdateAvatar(self.icon)
end

function MainuiChatHead:GetWidth()
	return self.width
end

function MainuiChatHead:GetView()
	return self.view
end

function MainuiChatHead:GetChatData()
	return self.chat_data
end

function MainuiChatHead:GetRoleUid()
	return self.chat_data ~= nil and self.chat_data.from_uid or 0
end

function MainuiChatHead:SetChatData(chat_data)
	if self.chat_data == chat_data then return end
	
	self.chat_data = chat_data
	AvatarManager.Instance:UpdateAvatarImg(self.icon, chat_data.from_uid, chat_data.prof, false)
end

----------------------------------------------------
-- 聊天item
----------------------------------------------------
MainuiChatItem = MainuiChatItem or BaseClass(BaseRender)
function MainuiChatItem:__init()
	self.view:setAnchorPoint(0, 0)
	
	self.rtxt_w = MainuiChat.width - 35
	self.rtxt_chat = nil
	self.record_item = nil
	
	self.height = 25
	self.flush_callback = nil
	
	self:SetIsUseStepCalc(true)
end

function MainuiChatItem:__delete()
	if nil ~= self.record_item then
		self.record_item:DeleteMe()
		self.record_item = nil
	end
end

function MainuiChatItem:CreateChild()
	BaseRender.CreateChild(self)
	
	self.rtxt_chat = XUI.CreateRichText(5, 3, self.rtxt_w, 20, false)
	self.rtxt_chat:setAnchorPoint(0, 0)
	self.rtxt_chat:setMaxLine(1)
	self.view:addChild(self.rtxt_chat)
	
	self.text_dots = XUI.CreateText(MainuiChat.width - 85, 3, 30, 20, cc.TEXT_ALIGNMENT_LEFT, "…", nil, 20)
	self.text_dots:setAnchorPoint(0, 0)
	self.view:addChild(self.text_dots)
end

function MainuiChatItem:GetHeight()
	return self.height
end

function MainuiChatItem:SetFlushCallback(callback)
	self.flush_callback = callback
end

function MainuiChatItem:OnFlush()
	if nil == self.data then
		self.view:setVisible(false)
		return
	end
	
	self.view:setVisible(true)
	
	-- 内容
	local content = string.gsub(self.data.content, "\n", " ")
	if "" ~= self.data.name then
		content = string.format("{wordcolor;%s;[%s]}{wordcolor;e6dfb9;%s：}%s",
		C3b2Str(CHANNEL_COLOR[self.data.channel_type] or COLOR3B.WHITE),
		(Language.Chat.Channel[self.data.channel_type] or "null"),
		self.data.name, content)
	else
		content = string.format("{wordcolor;%s;[%s]}%s",
		C3b2Str(CHANNEL_COLOR[self.data.channel_type] or COLOR3B.WHITE),
		(Language.Chat.Channel[self.data.channel_type] or "null"),
		content)
	end
	
	RichTextUtil.ParseRichText(self.rtxt_chat, content, nil, nil, nil, nil, self.rtxt_w, 20)
	
	self.rtxt_chat:refreshView()
	local size = self.rtxt_chat:getInnerContainerSize()
	self.rtxt_chat:setContentWH(self.rtxt_w, size.height)
	self.text_dots:setPositionX(5 + size.width)
	
	self.height = size.height + 5
	if self.height < 25 then
		self.height = 25
	end
	
	-- 语音
	if self.data.content_type == CHAT_CONTENT_TYPE.AUDIO then
		if self.record_item == nil then
			self.record_item = ChatMsgItemRecord.New(1)
			self.record_item:SetDirection(1)
			self.view:addChild(self.record_item:GetView())
		end
		self.record_item:SetPosition(size.width + 60, 5)
		self.record_item:SetData(self.data)
		self.record_item:GetView():setVisible(true)
		
		self.text_dots:setVisible(false)
	else
		if nil ~= self.record_item then
			self.record_item:GetView():setVisible(false)
			ChatRecordMgr.Instance:RemoveRecordItem(self.record_item:GetSoundKey())
		end
		
		self.text_dots:setVisible(self.rtxt_chat:isClippingContent())
	end
	
	if nil ~= self.flush_callback then
		self.flush_callback()
	end
end 