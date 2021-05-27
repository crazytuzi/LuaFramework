----------------------------------------------------------
--主ui上的头象栏，如主角，选中怪物，npc后在上部出现的头象栏
--都是规则排列的，零碎的请在mainui_smallparts处理
--@author bzw
----------------------------------------------------------
MainuiHeadBar = MainuiHeadBar or BaseClass()
MainuiHeadBar.MAIN_ROLE_SIZE = cc.size(300, 120)

function MainuiHeadBar:__init()
	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()					-- 增加事件组件

	self.mt_layout_mainrole = nil
	self.mt_layout_otherrole = nil
	self.mt_layout_monster = nil
	self.mt_layout_npc = nil

	self.mainrole_hpbar = nil
	self.click_head_callback = nil

	self.buff_item_list = {}

	self.atk_mode = 0
	self.layout_atk_mode = nil
	self.atk_mode_item_list = {}

	self.target_obj = nil
	self.monster_type = 0
	self.boss_hp_bar_num = 50

	self.low_hp_tip_effect = nil
	self.add_hp_effect = nil

	self.is_lowhp_tiping = false
	self.monster_rewwad_t = {}

	self.remind_flag_list = {}

	self.clicked_head_remind_flag = nil
end

function MainuiHeadBar:__delete()
	self:CancelMainRoleAvatar()
	if self.mode_alert then
		self.mode_alert:DeleteMe()
		self.mode_alert = nil
	end
	for k,v in pairs(self.monster_rewwad_t) do
		v:DeleteMe()
	end
	self.monster_rewwad_t = {}
	self.remind_flag_list = {}
	self.tree = nil

	self.btn_monster_reward = nil

	if self.fun_open_tip then
		self.fun_open_tip:DeleteMe()
	end
	self.fun_open_tip = nil
	self.btn_shan_e = nil
end

function MainuiHeadBar:HeadImg()
	return self.img_mainrole_head
end

function MainuiHeadBar:BindEvents()
	GlobalEventSystem:Bind(ObjectEventType.BE_SELECT, BindTool.Bind(self.OnSelectObj, self))
	GlobalEventSystem:Bind(ObjectEventType.OBJ_DEAD, BindTool.Bind(self.OnObjDead, self))
	GlobalEventSystem:Bind(ObjectEventType.OBJ_DELETE, BindTool.Bind(self.OnObjDel, self))
	GlobalEventSystem:Bind(ObjectEventType.OBJ_ATTR_CHANGE, BindTool.Bind(self.OnObjAttrChange, self))
	GlobalEventSystem:Bind(ObjectEventType.OBJ_BUFF_CHANGE, BindTool.Bind(self.OnObjBuffChange, self))
	GlobalEventSystem:Bind(SceneEventType.SCENE_CHANGE_COMPLETE, BindTool.Bind(self.OnHeadbarSceneChangeComplete, self))
	GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.OnRecvMainRoleInfo, self))
	GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_QUIT, BindTool.Bind(self.OnQuitSceneLoading, self))
	GlobalEventSystem:Bind(OtherEventType.REMINDGROUP_CAHANGE, BindTool.Bind(self.RemindGroupChange, self))
	-- GlobalEventSystem:Bind(OtherEventType.OPEN_DAY_CHANGE, BindTool.Bind(self.OnOpenServerDayChange, self))

	local role_event_proxy = EventProxy.New(RoleData.Instance)
	role_event_proxy:AddEventListener(OBJ_ATTR.ACTOR_PK_MODE, BindTool.Bind(self.OnMainRolePKModeChange, self))
	role_event_proxy:AddEventListener(OBJ_ATTR.CREATURE_LEVEL, BindTool.Bind(self.OnMainRoleLevelChange, self))
	role_event_proxy:AddEventListener(OBJ_ATTR.ACTOR_BATTLE_POWER, BindTool.Bind(self.OnBattlePowerChange, self))
	role_event_proxy:AddEventListener(OBJ_ATTR.CREATURE_HP, BindTool.Bind(self.OnMainRoleHpChange, self))
	role_event_proxy:AddEventListener(OBJ_ATTR.CREATURE_MAX_HP, BindTool.Bind(self.OnMainRoleMaxHpChange, self))
	role_event_proxy:AddEventListener(OBJ_ATTR.CREATURE_MP, BindTool.Bind(self.OnMainRoleMpChange, self))
	role_event_proxy:AddEventListener(OBJ_ATTR.CREATURE_MAX_MP, BindTool.Bind(self.OnMainRoleMaxMpChange, self))
	role_event_proxy:AddEventListener(OBJ_ATTR.ACTOR_SOUL2, BindTool.Bind(self.OnMainRolePartNumChange, self))
	role_event_proxy:AddEventListener(OBJ_ATTR.ACTOR_CIRCLE, BindTool.Bind(self.OnFlushFunOpen, self))

	role_event_proxy:AddEventListener(OBJ_ATTR.ACTOR_VIP_GRADE, BindTool.Bind(self.OnMainRoleVIPChange, self))

	role_event_proxy:AddEventListener(OBJ_ATTR.ACTOR_BIND_COIN, BindTool.Bind(self.FlushMoneyShow, self))
	role_event_proxy:AddEventListener(OBJ_ATTR.ACTOR_COIN, BindTool.Bind(self.FlushMoneyShow, self))
	role_event_proxy:AddEventListener(OBJ_ATTR.ACTOR_GOLD, BindTool.Bind(self.FlushMoneyShow, self))
end

function MainuiHeadBar:FlushReminds(group_name)
	local flag_node = self.remind_flag_list[group_name]
	if nil == flag_node then
		return
	end

	flag_node:setVisible(RemindManager.Instance:GetRemindGroup(group_name) > 0 and (not IS_ON_CROSSSERVER))
end

function MainuiHeadBar:OnFlushFunOpen()
	self:FlushFunOpenTip()
end

function MainuiHeadBar:RemindGroupChange(group_name, num)
	self:FlushReminds(group_name)
end

function MainuiHeadBar:OnQuitSceneLoading()
end

function MainuiHeadBar:OnRecvMainRoleInfo()
	self:UpdateMainRoleAvatar()
	self:UpdateMainRoleLevel()
	-- self:UpdateMainRoleHp()
	-- self:UpdateMainRoleMp()
	-- self:UpdateMainRolePartNum()

	self:SetMainRoleCapability(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_BATTLE_POWER))
	self:SetAttackMode(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PK_MODE))
	self:FlushMoneyShow()
end

function MainuiHeadBar:OnMainRoleVIPChange()
	RemindManager.Instance:DoRemind(RemindName.VipWelfare)
end

function MainuiHeadBar:OnMainRolePKModeChange()
	self:SetAttackMode(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PK_MODE))
end

function MainuiHeadBar:OnBattlePowerChange(vo)
	self:SetMainRoleCapability(vo.value)
end

function MainuiHeadBar:OnMainRoleLevelChange(vo)
	-- if vo.old_value < 70 and vo.value >= 70 then
	-- 	self.exp_award_button:setVisible(not PracticeCtrl.IsInPracticeMap() and not PracticeCtrl.IsInPracticeGate())
	-- 	self.exp_award_switch_btn:setVisible(not PracticeCtrl.IsInPracticeMap() and not PracticeCtrl.IsInPracticeGate())
	-- end
	self:UpdateMainRoleLevel()
end

function MainuiHeadBar:OnMainRoleMaxMpChange(vo)
	self:UpdateMainRoleMp()
end

function MainuiHeadBar:OnMainRoleMpChange(vo)
	self:UpdateMainRoleMp()
end

function MainuiHeadBar:UpdateMainRoleMp()
	-- self:SetMainRoleMp(RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_MP), RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_MAX_MP))
end

function MainuiHeadBar:OnMainRoleMaxHpChange(vo)
	self:UpdateMainRoleHp()
end

function MainuiHeadBar:OnMainRoleHpChange(vo)
	self:UpdateMainRoleHp()
end

function MainuiHeadBar:UpdateMainRoleHp()
	-- self:SetMainRoleHp(RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_HP), RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_MAX_HP))
end

function MainuiHeadBar:UpdateMainRoleLevel()
	if self.label_mainrole_level then
		self.label_mainrole_level:setString(RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL))
	end

	self:FlushFunOpenTip()
end

function MainuiHeadBar:OnMainRolePartNumChange(vo)
	-- self:UpdateMainRolePartNum()
end

function MainuiHeadBar:UpdateMainRolePartNum()
	local part_num = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SOUL2)
	local exp_num = part_num == 0 and 0 or TrialFloorConfig.Floor[part_num].nExp * 6 * 60
	if exp_num > 0 then
		exp_num = exp_num - exp_num % 100
		exp_num = exp_num / 10000
	end
	local str = exp_num > 0 and exp_num .. "万" or exp_num
	self.lbl_exp_num_hour_tip:setString(str .. Language.ExpAward.text1)
end

function MainuiHeadBar:Init(mt_layout_root)
	self:InitMainRoleHead(mt_layout_root)

	self.mt_layout_target = MainuiMultiLayout.CreateMultiLayout(400, mt_layout_root:getContentSize().height, cc.p(0, 1), cc.size(300, 120), mt_layout_root, 0)

	self:InitOtherRoleHead()
	self:InitMonsterHead()

	for group_name, v in pairs(self.remind_flag_list) do
		self:FlushReminds(group_name)
	end

	self:BindEvents()
end

function MainuiHeadBar:CheckFuncOpen()
	local lv = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL) -- 级
	local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)	 -- 转

	for i,data in ipairs(ClientFunOpenShowUiCfg) do
		local limit_lv = GameCond[data.opne_cond].RoleLevel or 0
		local limit_circle = GameCond[data.opne_cond].RoleCircle or 0

		if circle > 0 then
			if circle < limit_circle then
				return data
			end
		else	
			if lv < limit_lv then
				return data
			end
		end
	end
	
	if circle <= 0 then
		for i,v in ipairs(ClientFunOpenShowUiCfg) do
			local limit_lv = GameCond[v.opne_cond].RoleLevel or 0
			local limit_circle = GameCond[v.opne_cond].RoleCircle or 0
			if limit_circle > 0 then
				return v
			end
		end
	end
end

function MainuiHeadBar:FlushFunOpenTip()
	local show_data = self:CheckFuncOpen()
	if nil == show_data and self.fun_open_tip then
		self.fun_open_tip:DeleteMe()
		NodeCleaner.Instance:AddNode(self.fun_open_tip:GetView())
		self.fun_open_tip = nil
	elseif show_data and nil == self.fun_open_tip then
		local ph = self.head_ui_ph_list.ph_list_item
		self.fun_open_tip = MainUIOpenListRender.New()
		self.fun_open_tip:GetView():setPosition(ph.x, ph.y)
		self.fun_open_tip:GetView():setScale(0.8)
		self.fun_open_tip:SetUiConfig(ph, true)
		self.head_ui_node_list.layout_role_head.node:addChild(self.fun_open_tip:GetView())
		self.fun_open_tip:GetView()
		XUI.AddClickEventListener(self.fun_open_tip:GetView(), function ()
			ViewManager.Instance:OpenViewByDef(ViewDef.FunOpenGuideView)
		end, true)
	end

	if self.fun_open_tip and show_data then
		self.fun_open_tip:SetData(show_data)
	end
end

function MainuiHeadBar:GetBtnStateShanE()
	return self.btn_shan_e:GetView()
end

function MainuiHeadBar:GetBtnState()
	return self.head_ui_node_list.btn_state.node
end

function MainuiHeadBar:InitMainRoleHead(mt_layout_root)
	local size = MainuiHeadBar.MAIN_ROLE_SIZE
	self.mt_layout_mainrole = MainuiMultiLayout.CreateMultiLayout(0, mt_layout_root:getContentSize().height, cc.p(0, 1), size, mt_layout_root)
	-- self.mt_layout_mainrole:SetBgColor(COLOR3B.GREEN)

	local ui_config = ConfigManager.Instance:GetUiConfig("main_ui_cfg")
	for k, v in pairs(ui_config) do
		if v.n == "layout_role_head" then
			self.ui_cfg = v
			break
		end
	end

	self.ui_cfg.x = -10
	self.ui_cfg.y = -self.ui_cfg.h/2
	self.head_ui_node_list = {}
	self.head_ui_ph_list = {}
	self.tree = XUI.GeneratorUI(self.ui_cfg, nil, nil, self.head_ui_node_list, nil, self.head_ui_ph_list)
	self.mt_layout_mainrole:TextureLayout():addChild(self.tree.node, 999, 999)

	self.head_ui_node_list.layout_role_head.node:setAnchorPoint(0.5, 0)
	-- 引导点击头像层
	self.guide_head_layout = XUI.CreateLayout(80, size.height / 2, 100, 100)
	self.mt_layout_mainrole:TextureLayout():addChild(self.guide_head_layout)

	self.img_head_bg = self.head_ui_node_list.img_head_bg.node
	self.img_head_bg:setTouchEnabled(true)
	self.img_head_bg:setIsHittedScale(false)
	self.img_head_bg:addClickEventListener(BindTool.Bind(self.OnClickMainRoleHead, self))

	self.img_mainrole_head = XUI.CreateImageView(self.head_ui_ph_list.ph_head.x, self.head_ui_ph_list.ph_head.y, "", true)
	self.head_ui_node_list.layout_role_head.node:addChild(self.img_mainrole_head, 98)

	self.label_mainrole_level = self.head_ui_node_list.role_level.node

	-- 提醒
	local remind_flag = self.head_ui_node_list.img_remind.node
	-- CommonAction.ShowRemindBlinkAction(remind_flag)
	remind_flag:setVisible(false)
	self.remind_flag_list[RemindGroupName.RoleView] = remind_flag

	self.number_zhanli = self:CreateNumBar(self.head_ui_node_list.img_cap.node:getPositionX() + 30, self.head_ui_node_list.img_cap.node:getPositionY() - 12, 100, 20)
	self.head_ui_node_list.layout_role_head.node:addChild(self.number_zhanli:GetView(), 999)

	-- 底下按钮
	self.btn_buff = self.head_ui_node_list.btn_buff.node
	XUI.AddClickEventListener(self.btn_buff, BindTool.Bind(self.OnClickBuff, self))
	self.btn_atk_mode = self.head_ui_node_list.img_atk_mode.node
	XUI.AddClickEventListener(self.head_ui_node_list.btn_state.node, BindTool.Bind(self.OnClickAttackMode, self))


	-- self.mainrole_hpbar = XUI.CreateLoadingBar(217, 65, ResPath.GetMainui("loading_hp"))
	-- self.mt_layout_mainrole:TextureLayout():addChild(self.mainrole_hpbar)

	-- self.mainrole_mpbar = XUI.CreateLoadingBar(216, 46, ResPath.GetMainui("loading_mp"))
	-- self.mt_layout_mainrole:TextureLayout():addChild(self.mainrole_mpbar)

	-- self.mainrole_text_hp = XUI.CreateText(217, 65, 360, 20, nil, "", nil, 20, nil)
	-- self.mt_layout_mainrole:TextLayout():addChild(self.mainrole_text_hp)

	-- self.mainrole_text_mp = RichTextUtil.ParseRichText(nil, "", 20, COLOR3B.WHITE, 217, 46, 360, 20)
	-- self.mt_layout_mainrole:TextLayout():addChild(self.mainrole_text_mp)
	-- XUI.RichTextSetCenter(self.mainrole_text_mp)

	-- local img_vip = XUI.CreateImageView(73, 8, ResPath.GetMainui("role_head_vip"), true)
	
	-- self.mt_layout_mainrole:TextureLayout():addChild(img_vip, 110)
	-- XUI.AddClickEventListener(img_vip, function()
	-- 	ViewManager.Instance:OpenViewByDef(ViewDef.Vip)
	-- end)
	-- local remind_eff = RenderUnit.CreateEffect(330, img_vip, 1)
	-- -- local vip_img_size = img_vip:getContentSize()
	-- -- local vip_remind_flag = XUI.CreateImageView(vip_img_size.width - 3, vip_img_size.height - 3, ResPath.GetMainui("remind_flag"), true)
	-- remind_eff:setVisible(false)
	-- -- img_vip:addChild(remind_eff)
	-- -- CommonAction.ShowRemindBlinkAction(vip_remind_flag)
	-- self.remind_flag_list[RemindGroupName.VipView] = remind_eff

	-- self.exp_award_button = XUI.CreateLayout(450, 120, 100, 80)
	-- self.exp_award_button:setAnchorPoint(0.5, 1)
	-- local act_eff_2 = RenderUnit.CreateEffect(327, self.exp_award_button, 0, nil, nil, 20, 20)
	-- self.mt_layout_mainrole:TextLayout():addChild(self.exp_award_button, 300)
	-- XUI.AddClickEventListener(self.exp_award_button, function()
	-- 	ViewManager.Instance:OpenViewByDef(ViewDef.ExpAward)
	-- end, true)
	-- local vis = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL) >= 70
	-- self.exp_award_button:setVisible(vis)

	-- self.lbl_exp_num_hour_tip = XUI.CreateText(30, - 30, 200, 30, cc.TEXT_ALIGNMENT_CENTER, "" , nil, 22, COLOR3B.GREEN, nil)
	-- self.exp_award_button:addChild(self.lbl_exp_num_hour_tip, 300)

	-- local exp_num_bg = XUI.CreateImageViewScale9(30, - 26, 200, 30, ResPath.GetCommon("bg_106"), true)
	-- self.exp_award_button:addChild(exp_num_bg, 299)
	-- -- self.lbl_exp_num_hour_tip:enableOutline(cc.c4b(0, 0, 0, 255), 1)

	-- self.exp_award_switch_btn = XUI.CreateImageView(465, 98, ResPath.GetMainui("img_arrow"), true)
	-- -- self.exp_award_switch_btn:setRotation(30)
	-- self.exp_award_switch_btn:setHittedScale(1.05)
	-- self.mt_layout_mainrole:TextLayout():addChild(self.exp_award_switch_btn, 301)
	-- XUI.AddClickEventListener(self.exp_award_switch_btn, BindTool.Bind(self.OnClickExpAwarSwitch, self), true)
	-- self.exp_award_switch_btn:setVisible(RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL) >= 70)
	-- self.exp_awar_switch = true

	-- self.btn_tream = self.CreateBtnAndImgNode(get_btn_pos(), btn_y, ResPath.GetMainui("btn_10"), ResPath.GetMainui("w_team"))
	-- self.mt_layout_mainrole:TextureLayout():addChild(self.btn_tream, 1)
	-- XUI.AddClickEventListener(self.btn_tream, BindTool.Bind(self.OnClickTream, self))

	self:FlushReminds()
	self:FlushFunOpenTip()
end

function MainuiHeadBar:FlushMoneyShow()	
	local gold_num =  GameMath.GetStringShowMoneynum(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD))
	self.head_ui_node_list.text_had_zuan.node:setString(gold_num)
		
	local coin = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_COIN)
	local num = coin
	local text  = GameMath.GetStringShowMoneynum(num)
	self.head_ui_node_list.text_had_coin.node:setString(text)
end

function MainuiHeadBar:SetMainRoleHeadVisible(vis)
	self.mt_layout_mainrole:setVisible(vis)
end

function MainuiHeadBar:OnClickExpAwarSwitch()
	self.exp_awar_switch = not self.exp_awar_switch
	self.exp_award_button:stopAllActions()
	self.exp_award_switch_btn:setFlippedY(not self.exp_awar_switch)
	local scaleAction, callFun, moveAction, spawn, ease_sine, seq
	local callBack = function () 
						self.exp_award_button:setVisible(self.exp_awar_switch)
					end
	callFun = cc.CallFunc:create(callBack)
	local time = 0.25
	local scale = self.exp_awar_switch and 1 or 0
	local moveDelt = self.exp_awar_switch and -45 or 35
	local origScale = self.exp_awar_switch and 0 or 1
	self.exp_award_button:setScale(origScale)
	scaleAction = cc.ScaleTo:create(time, scale)
	moveAction = cc.JumpTo:create(time, cc.p(450,120), moveDelt, 1)
	spawn = cc.Spawn:create(scaleAction, moveAction)
	ease_sine = cc.EaseSineIn:create(spawn)
	if not self.exp_awar_switch then
		seq = cc.Sequence:create(ease_sine, callFun)
	else
		seq = cc.Sequence:create(callFun, ease_sine)
	end
	self.exp_award_button:runAction(seq)
end

function MainuiHeadBar:OnClickTream()
	ViewManager.Instance:OpenViewByDef(ViewDef.Team)
end

function MainuiHeadBar.CreateBtnAndImgNode(x, y, btn_res_path, img_res_path)
	local btn = XUI.CreateImageView(x, y, btn_res_path, true)
	if img_res_path then
		local size = btn:getContentSize()
		local img = XUI.CreateImageView(size.width / 2, size.height / 2, img_res_path, true)
		btn:addChild(img, 1, 1)
	end
	return btn
end

function MainuiHeadBar:CreateNumBar(x, y, w, h)
	local number_bar = NumberBar.New()
	number_bar:SetRootPath(ResPath.GetMainui("num_10_"))
	number_bar:SetPosition(x, y)
	number_bar:SetContentSize(w, h)
	number_bar:SetSpace(0)
	return number_bar
end

function MainuiHeadBar:GetMainRoleBtn()
	return self.guide_head_layout
end

-------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------
function MainuiHeadBar:InitOtherRoleHead()
	local size = self.mt_layout_target:getContentSize()
	self.mt_layout_otherrole = MainuiMultiLayout.CreateMultiLayout(100, -5, cc.p(0, 0), size, self.mt_layout_target)
	self.mt_layout_otherrole:setVisible(false)

	local img_head_bg = XUI.CreateImageView(210, size.height - 60, ResPath.GetMainui("otherrole_head_bg"), true)
	self.mt_layout_otherrole:TextureLayout():addChild(img_head_bg)

	self.otherrole_close = XUI.CreateImageView(378, size.height - 30, ResPath.GetCommon("btn_close"), true)
	self.otherrole_close:setScale(0.5)
	self.mt_layout_otherrole:TextureLayout():addChild(self.otherrole_close)
	XUI.AddClickEventListener(self.otherrole_close, function()
		GlobalEventSystem:Fire(ObjectEventType.BE_SELECT, nil, "close")
	end)

	self.otherrole_head = RoleHeadCell.New(false)
	self.otherrole_head:GetView():setScale(1.6)
	self.otherrole_head:SetPosition(75, size.height / 2+15)
	self.mt_layout_otherrole:TextureLayout():addChild(self.otherrole_head:GetView(), 100)
	self.otherrole_head:AddClickEventListener()

	self.otherrole_hpbar = XUI.CreateLoadingBar(242, 58, ResPath.GetMainui("loading_hp"), true)
	self.otherrole_hpbar:setPercent(100)
	self.mt_layout_otherrole:TextureLayout():addChild(self.otherrole_hpbar)

	self.otherrole_mpbar = XUI.CreateLoadingBar(235, 31.5, ResPath.GetMainui("loading_mp"), true)
	self.otherrole_mpbar:setPercent(100)
	self.mt_layout_otherrole:TextureLayout():addChild(self.otherrole_mpbar)

	self.otherrole_text_hp = XUI.CreateText(240, 58, 360, 20, nil, "", nil, 20, nil)
	self.mt_layout_otherrole:TextureLayout():addChild(self.otherrole_text_hp, 2)

	self.otherrole_text_mp = XUI.CreateText(240, 30, 360, 20, nil, "", nil, 20, nil)
	self.mt_layout_otherrole:TextureLayout():addChild(self.otherrole_text_mp, 2)

	self.text_otherrole_level = XUI.CreateText(135, size.height- 27, 100, 21, cc.TEXT_ALIGNMENT_CENTER, "", nil, nil, COLOR3B.YELLOW)
	self.text_otherrole_level:setAnchorPoint(0.5, 0.5)
	self.mt_layout_otherrole:TextureLayout():addChild(self.text_otherrole_level, 101)

	-- self.text_otherrole_prof = XUI.CreateText(48, size.height - 32, 100, 21, cc.TEXT_ALIGNMENT_CENTER, "", nil, nil, COLOR3B.YELLOW)
	-- self.text_otherrole_prof:setAnchorPoint(0.5, 0.5)
	-- self.mt_layout_otherrole:TextureLayout():addChild(self.text_otherrole_prof, 2)

	self.text_otherrole_name = XUI.CreateText(213, 89, 350, 20, nil, "", nil, 20, COLOR3B.WHITE)
	self.mt_layout_otherrole:TextureLayout():addChild(self.text_otherrole_name, 2)
end

function MainuiHeadBar:InitMonsterHead()
	self.mt_layout_monster = MainuiMultiLayout.CreateMultiLayout(100, -10, cc.p(0, 0), self.mt_layout_target:getContentSize(), self.mt_layout_target)
	self.mt_layout_monster:setVisible(false)

	self.monster_hp_bg = XUI.CreateImageView(0, 65, ResPath.GetMainui("monster_hp_bg"), true)
	self.monster_hp_bg:setAnchorPoint(0, 0.5)
	self.mt_layout_monster:TextureLayout():addChild(self.monster_hp_bg)

	self.monster_hpbar = XUI.CreateLoadingBar(111, 64, ResPath.GetMainui("monster_hp_bar"), true)
	self.monster_hpbar:setAnchorPoint(0, 0.5)
	self.monster_hpbar:setPercent(100)
	self.mt_layout_monster:TextureLayout():addChild(self.monster_hpbar)

	self.monster_text_hp = XUI.CreateText(216, 65, 360, 20, nil, "", nil, 20, nil)
	self.mt_layout_monster:TextureLayout():addChild(self.monster_text_hp)

	self.img_monster_head = XUI.CreateImageView(56, 74, ResPath.GetMainui("monster_head"), true)
	self.img_monster_head:setScale(1.2)
	self.mt_layout_monster:TextureLayout():addChild(self.img_monster_head)

	self.btn_monster_reward = XUI.CreateImageView(56, 10, ResPath.GetMainui("btn_boss_reward"), true)
	self.btn_monster_reward:setScale(1.2)
	XUI.AddClickEventListener(self.btn_monster_reward, function ()
		CrossServerCtrl.Instance:OpenRewardView({boss_id = 1576, asc_role_id = self.asc_role_id, role_name = self.asc_role_name})
	end)
	self.mt_layout_monster:TextureLayout():addChild(self.btn_monster_reward)

	self.text_monster_name = XUI.CreateText(135, 84, 340, 20, cc.TEXT_ALIGNMENT_LEFT, "", nil, 20, cc.c3b(0xe1, 0x7d, 0x11))
	self.text_monster_name:setAnchorPoint(0, 0)
	self.mt_layout_monster:TextureLayout():addChild(self.text_monster_name, 1)


	self.text_monster_level = XUI.CreateText(111, 98, 60, 20, cc.TEXT_ALIGNMENT_CENTER, "99", nil, 20, COLOR3B.YELLOW)
	self.mt_layout_monster:TextureLayout():addChild(self.text_monster_level, 1)

	self.text_monster_owner = RichTextUtil.ParseRichText(nil, "", 20, COLOR3B.ORANGE, 135, 84, 540, 20)
	self.text_monster_owner:setAnchorPoint(0, 0)
	self.mt_layout_monster:TextureLayout():addChild(self.text_monster_owner)

	-- 屠魔令
	self.tumo_card = XUI.CreateImageView(330, 30, ResPath.GetMainui("tumo"), true)
	self.tumo_card:setAnchorPoint(0, 0.5)
	self.mt_layout_monster:TextureLayout():addChild(self.tumo_card)

	self.tumo_num = XUI.CreateText(30, 7, 340, 20, cc.TEXT_ALIGNMENT_LEFT, "", nil, 20, cc.c3b(0x1e, 0xff, 0x00))
	self.tumo_num:setAnchorPoint(0, 0)
	self.tumo_card:addChild(self.tumo_num, 1)

	-- 怪物护盾
	self.mt_layout_monster_shield = MainuiMultiLayout.CreateMultiLayout(0, 0, cc.p(0, 0), self.mt_layout_monster:getContentSize(), self.mt_layout_monster, 50)
	self.mt_layout_monster_shield:setVisible(false)

	self.shield_progress = XUI.CreateLoadingBar(107, 73, ResPath.GetMainui("prog_mainui_01"), true)
	self.shield_progress:setAnchorPoint(0, 0.5)
	local shield_progress_bg = XUI.CreateImageView(107, 74, ResPath.GetMainui("prog_bg_mainui_01"))
	shield_progress_bg:setAnchorPoint(0, 0.5)
	self.mt_layout_monster_shield:TextureLayout():addChild(shield_progress_bg, 1)
	self.mt_layout_monster_shield:TextureLayout():addChild(self.shield_progress, 2)
	self.shield_progress:setPercent(100)

	for i = 1, 6 do
		local cell = BaseCell.New()
		cell:SetPosition(75 + i * 35, 14)
		self.mt_layout_monster:TextureLayout():addChild(cell:GetView(), 2)
		cell:SetVisible(false)
		cell:GetView():setScale(0.42)
		self.monster_rewwad_t[i] = cell
	end
end

function MainuiHeadBar:InitNpcHead()
	self.mt_layout_npc = MainuiMultiLayout.CreateMultiLayout(0, 0, cc.p(0, 0), self.mt_layout_target:getContentSize(), self.mt_layout_target)
	self.mt_layout_npc:setVisible(false)

	local img_hp_bg = XUI.CreateImageView(73, 40, ResPath.GetMainui("monster_hp_bg"), true)
	img_hp_bg:setAnchorPoint(0, 0.5)
	self.mt_layout_npc:TextureLayout():addChild(img_hp_bg)

	local img_hp_bar = XUI.CreateImageView(78, 40, ResPath.GetMainui("monster_hp_bar"), true)
	img_hp_bar:setAnchorPoint(0, 0.5)
	self.mt_layout_npc:TextureLayout():addChild(img_hp_bar)

	local img_head_bg = XUI.CreateImageView(40, 40, ResPath.GetMainui("role_head_bg"), true)
	self.mt_layout_npc:TextureLayout():addChild(img_head_bg)

	local img_npc_head = XUI.CreateImageView(40, 40, ResPath.GetMainui("npc_head"), true)
	self.mt_layout_npc:TextureLayout():addChild(img_npc_head)

	self.text_npc_name = XUI.CreateText(150, 65, 150, 20, nil, "", nil, 20, COLOR3B.YELLOW)
	self.mt_layout_npc:TextLayout():addChild(self.text_npc_name)
end

------------------------------------------------------------------------
function MainuiHeadBar:SetClickHeadCallback(callback)
	self.click_head_callback = callback
end

function MainuiHeadBar:OnClickMainRoleHead()
	-- local times = self:GetClickedHeadTimes()
	-- if times < 2 then
	-- 	times = times + 1
	-- 	cc.UserDefault:getInstance():setStringForKey("clicked_head_times", times)
	-- 	if times >= 2 and self.clicked_head_remind_flag then
	-- 		self.clicked_head_remind_flag:removeFromParent()
	-- 		self.clicked_head_remind_flag = nil
	-- 	end
	-- end

	-- if nil ~= self.click_head_callback then
	-- 	self.click_head_callback()
	-- end

	ViewManager.Instance:OpenViewByDef(ViewDef.Role)
end

function MainuiHeadBar:GetClickedHeadTimes()
	local times = cc.UserDefault:getInstance():getStringForKey("clicked_head_times")
	return times and tonumber(times) or 0
end
------------------------------------------------------------------------


----------------------------------------------------------
-- buff begin
----------------------------------------------------------
function MainuiHeadBar:OnClickBuff()
	if nil == self.layout_buff then
		local x, y = self.btn_buff:getPosition()
		self.layout_buff = XLayout:create()
		self.layout_buff:setAnchorPoint(0, 1)
		self.layout_buff:setPosition(x - 40, y - 20)
		self.mt_layout_mainrole:EffectLayout():addChild(self.layout_buff)

		local layout_touch = XLayout:create(HandleRenderUnit:GetWidth(), HandleRenderUnit:GetHeight())
		local pos = self.layout_buff:convertToNodeSpace(cc.p(0, 0))
		layout_touch:setPosition(pos.x, pos.y)
		self.layout_buff:addChild(layout_touch)
		XUI.AddClickEventListener(layout_touch, function()
			self.layout_buff:setVisible(false)
		end)

		self.img_buff_bg = XUI.CreateImageViewScale9(1, 1, 2, 2, ResPath.GetMainui("common_bg"), true)
		self.layout_buff:addChild(self.img_buff_bg)

		self.img_buff_bg:setTouchEnabled(true)
		self.img_buff_bg:setIsHittedScale(false)
		self.img_buff_bg:addTouchEventListener(BindTool.Bind(self.OnTouchBuffLayout, self))
	else
		self.layout_buff:setVisible(not self.layout_buff:isVisible())
	end

	self:OnFlushBuffLayout()
end

function MainuiHeadBar:OnFlushBuffBar()
	local mainrole_vo = Scene.Instance:GetMainRole():GetVo()
	if nil == mainrole_vo.buff_list or MainuiBuffRender.ColCount <= 0 then
		return
	end

	for i, v in ipairs(self.buff_item_list) do
		v:SetVisible(false)
	end

	local buff_list = {}
	local is_add = false
	for i, v in ipairs(mainrole_vo.buff_list) do
		is_add = false
		for i2, v2 in ipairs(buff_list) do
			if v.buff_group == v2[1].buff_group then
				is_add = true
				table.insert(v2, v)
				break
			end
		end
		if not is_add then
			table.insert(buff_list, {[1] = v})
		end
	end

	-- 添加虚拟buff
	local fake_buff_list = MainuiHeadBar.GetFakeBuffList()
	for k,v in pairs(fake_buff_list) do
		table.insert(buff_list, {[1] = v})
	end

	local w = MainuiBuffRender.ColCount * MainuiBuffRender.Size
	local h = math.max(math.ceil(#buff_list / MainuiBuffRender.ColCount) * MainuiBuffRender.Size, MainuiBuffRender.Size)
	self.layout_buff:setContentWH(w, h)
	self.img_buff_bg:setPosition(w / 2, h / 2)
	self.img_buff_bg:setContentWH(w, h)

	for i, v in ipairs(buff_list) do
		if nil == self.buff_item_list[i] then
			self.buff_item_list[i] = MainuiBuffRender.New()
			self.layout_buff:addChild(self.buff_item_list[i]:GetView())
		end
		self.buff_item_list[i]:SetVisible(true)
		self.buff_item_list[i]:SetData(v)
		local x = MainuiBuffRender.Size * ((i - 1) % MainuiBuffRender.ColCount) + MainuiBuffRender.Size / 2
		local y = h - MainuiBuffRender.Size * math.floor((i - 1) / MainuiBuffRender.ColCount) - MainuiBuffRender.Size / 2
		self.buff_item_list[i]:SetPosition(x, y)
	end

	if nil ~= self.cur_buff_item then
		if not self.cur_buff_item:GetView():isVisible() then
			self.cur_buff_item = nil
			TipCtrl.Instance:CloseBuffTip()
		else
			TipCtrl.Instance:OpenBuffTip(self.cur_buff_item:GetData())
		end
	end
end

function MainuiHeadBar:OnTouchBuffLayout(sender, event_type, touch)
	if event_type == XuiTouchEventType.Began or event_type == XuiTouchEventType.Moved then
		local item = nil
		local location = touch:getLocation()
		for k, v in pairs(self.buff_item_list) do
			if v:GetView():isVisible() and v:GetView():isContainsPoint(location) then
				item = v
				break
			end
		end

		if nil ~= item and item ~= self.cur_buff_item then
			self.cur_buff_item = item
			TipCtrl.Instance:OpenBuffTip(item:GetData())
		end
	else
		self.cur_buff_item = nil
		TipCtrl.Instance:CloseBuffTip()
	end
end

function MainuiHeadBar:OnObjBuffChange(obj)
	if obj == Scene.Instance:GetMainRole() then
		self:OnFlushBuffLayout()
	end
end

function MainuiHeadBar:OnFlushBuffLayout()
	if nil ~= self.layout_buff and self.layout_buff:isVisible() then
		self:OnFlushBuffBar()
	end
end

----------------------------------------------------------
-- buff end
----------------------------------------------------------

function MainuiHeadBar:OnClickAttackMode()
	--组队副本特殊处理
	if Scene.Instance:GetSceneId() == ZuDuiFuBenCfg[FubenMutilType.Team].sceneInfo[1].sceneId or Scene.Instance:GetSceneId() == ZuDuiFuBenCfg[FubenMutilType.Team].sceneInfo[2].sceneId then
		SysMsgCtrl.Instance:FloatingTopRightText(Language.FubenMutil.Tip)
		PkCtrl.SendSetAttackMode(1)
		return
	end  
	if nil == self.layout_atk_mode then
		local w, h = 280, 0
		local index = 1
		local function create_atk_mode_button(atk_mode, desc)
			local atk_mode_item = MainuiAtkModeRender.New()
			atk_mode_item:Create(w, 40, atk_mode, desc)
			atk_mode_item:SetPosition(0, index * 40)
			self.layout_atk_mode:addChild(atk_mode_item:GetView(), 10)
			self.atk_mode_item_list[atk_mode] = atk_mode_item
			index = index + 1
			h = h + 40

			atk_mode_item:AddClickEventListener(BindTool.Bind(self.OnSelectAttackMode, self))
			return atk_mode_item
		end
		local x, y = self.btn_atk_mode:getPosition()
		self.layout_atk_mode = XLayout:create(w, h)
		self.layout_atk_mode:setAnchorPoint(0, 1)
		self.layout_atk_mode:setPosition(x - 40, y - 20)
		self.mt_layout_mainrole:EffectLayout():addChild(self.layout_atk_mode)
		
		local layout_touch = XLayout:create(HandleRenderUnit:GetWidth(), HandleRenderUnit:GetHeight())
		local pos = self.layout_atk_mode:convertToNodeSpace(cc.p(0, 0))
		layout_touch:setPosition(pos.x, pos.y)
		self.layout_atk_mode:addChild(layout_touch)
		XUI.AddClickEventListener(layout_touch, function()
			self.layout_atk_mode:setVisible(false)
		end)

		create_atk_mode_button(4, Language.Mainui.AttackModeText[4])
		self.btn_shan_e = create_atk_mode_button(3, Language.Mainui.AttackModeText[3]) 	-- 用于引导
		create_atk_mode_button(2, Language.Mainui.AttackModeText[2])
		create_atk_mode_button(1, Language.Mainui.AttackModeText[1])
		create_atk_mode_button(0, Language.Mainui.AttackModeText[0])

		self.layout_atk_mode:setContentWH(w, h)

		local img_bg = XUI.CreateImageViewScale9(w / 2, h / 2-90, w, h+180, ResPath.GetMainui("common_bg"), true)
		self.layout_atk_mode:addChild(img_bg)

		self.PK_tip = XUI.CreateRichText(w / 2, 0, w - 20, 0, false)
		self.PK_tip:setAnchorPoint(cc.p(0.5, 1))
		self.layout_atk_mode:addChild(self.PK_tip)
		RichTextUtil.ParseRichText(self.PK_tip, Language.Mainui.PKTip .. "\n" .. Language.Mainui.PKTip1, 20, COLOR3B.RED)
		self.PK_tip:refreshView()
		local inner_h = self.PK_tip:getInnerContainerSize().height
		self.PK_tip:setPositionY(0)
		img_bg:setContentWH(w, h + inner_h + 10)
		img_bg:setPositionY(h -(h + inner_h + 10) / 2)
	else
		self.layout_atk_mode:setVisible(not self.layout_atk_mode:isVisible())
	end

	self:FlushAttackSelectState()
end

function MainuiHeadBar:OnSelectAttackMode(item)
	local mainrole_vo = Scene.Instance:GetMainRole():GetVo()
	if mainrole_vo.buff_list then
		for k,v in pairs(mainrole_vo.buff_list) do
			if v.buff_type == 93 and item:GetAtkMode() ~= GameEnum.ATTACK_MODE_PEACE then
				if nil == self.mode_alert then
					self.mode_alert = Alert.New()
					self.mode_alert:SetLableString(Language.Common.XinshouModeChangeTips)
				end
				self.mode_alert:SetOkFunc(function ()
					PkCtrl.SendSetAttackMode(item:GetAtkMode())
					self.layout_atk_mode:setVisible(false)
				end)
				self.mode_alert:Open()
				return
			end
		end
	end
	PkCtrl.SendSetAttackMode(item:GetAtkMode())
	self.layout_atk_mode:setVisible(false)
end

function MainuiHeadBar:SetAttackMode(atk_mode)
	if self.atk_mode ~= atk_mode then
		self.atk_mode = atk_mode
		self.btn_atk_mode:loadTexture(ResPath.GetMainui("atk_mode_" .. atk_mode))
		self:FlushAttackSelectState()
	end
end

function MainuiHeadBar:FlushAttackSelectState()
	if nil ~= self.layout_atk_mode and self.layout_atk_mode:isVisible() then
		for k, v in pairs(self.atk_mode_item_list) do
			v:SetSelect(false)
		end

		if nil ~= self.atk_mode_item_list[self.atk_mode] then
			self.atk_mode_item_list[self.atk_mode]:SetSelect(true)
		end
	end
end

--血量n%以下提示特效
function MainuiHeadBar:PlayLowHpTipEffect()
	if self.is_lowhp_tiping then return end

	if self.low_hp_tip_effect == nil then
		self.low_hp_tip_effect = AnimateSprite:create()
		local x, y = self.mainrole_hpbar:getPosition()
		self.low_hp_tip_effect:setPosition(x - 5, y)
		self.mt_layout_mainrole:EffectLayout():addChild(self.low_hp_tip_effect, 1)
	end

	local path, name = ResPath.GetEffectAnimPath(3051)
	self.low_hp_tip_effect:setAnimate(path, name, COMMON_CONSTS.MAX_LOOPS, 0.17, false)
	self.is_lowhp_tiping = true
end

--全屏闪红
function MainuiHeadBar:ShowRedFlash(value)
	if value and self.red_flash == nil then
		local screen_w, screen_h = HandleRenderUnit:GetWidth(), HandleRenderUnit:GetHeight()
		self.red_flash = XUI.CreateImageViewScale9(screen_w / 2, screen_h / 2, screen_w, screen_h, ResPath.GetCommon("img9_131"), true)
		HandleRenderUnit:AddUi(self.red_flash, COMMON_CONSTS.ZORDER_SYSTEM_EFFECT, COMMON_CONSTS.ZORDER_SYSTEM_EFFECT)
		self.red_flash:setOpacity(0)
		local fade_in = cc.FadeIn:create(0.3)
		local fade_out = cc.FadeOut:create(0.7)
		local sequence = cc.Sequence:create(fade_in, fade_out)
		local forever = cc.RepeatForever:create(sequence)
		self.red_flash:runAction(forever)
	elseif self.red_flash then
		self.red_flash:setVisible(value)
	end
end

--mp值低提醒动作
function MainuiHeadBar:ShowMpAction(value)
	if value then
		local scale1 = cc.ScaleTo:create(0.3, 1.5)
		local scale2 = cc.ScaleTo:create(0.7, 1)
		local sequence = cc.Sequence:create(scale1, scale2)
		local forever = cc.RepeatForever:create(sequence)
		self.mainrole_text_mp:stopAllActions()
		self.mainrole_text_mp:runAction(forever)
	else
		self.mainrole_text_mp:stopAllActions()
		self.mainrole_text_mp:setScale(1)
	end
end

--停止血量n%以下提示特效
function MainuiHeadBar:StopLowHpTipEffect()
	if not self.is_lowhp_tiping then return end

	if self.low_hp_tip_effect ~= nil then
		self.low_hp_tip_effect:setStop()
	end
	self.is_lowhp_tiping = false
end

--加血时血条上的特效
function MainuiHeadBar:PlayAddHpEffect()
	if self.add_hp_effect == nil then
		self.add_hp_effect = AnimateSprite:create()
		local x, y = self.mainrole_hpbar:getPosition()
		self.add_hp_effect:setPosition(x, y)
		self.mt_layout_mainrole:EffectLayout():addChild(self.add_hp_effect, 2)
	end

	local path, name = ResPath.GetEffectAnimPath(3045)
	self.add_hp_effect:setAnimate(path, name, 1, 0.17, false)
end

-- 更新主角头像
function MainuiHeadBar:UpdateMainRoleAvatar()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	AvatarManager.Instance:UpdateAvatarImg(self.img_mainrole_head, vo[OBJ_ATTR.ENTITY_ID], vo[OBJ_ATTR.ACTOR_PROF], true, false, vo[OBJ_ATTR.ACTOR_SEX])
end

-- 取消更新主角头像
function MainuiHeadBar:CancelMainRoleAvatar()
	AvatarManager.Instance:CancelUpdateAvatar(self.img_mainrole_head)
end

-- 设置主角战力
function MainuiHeadBar:SetMainRoleCapability(value)
	self.number_zhanli:SetNumber(value)

	self.last_capability = value

	if SceneText.CapabilityEffect.old_role_capability < 0 then
		if nil == self.capability_timer then
			self.capability_timer = GlobalTimerQuest:AddDelayTimer(function()
				self.capability_timer = nil
				SceneText.CapabilityEffect.old_role_capability = self.last_capability
			end, 2)
		end
	else
		if nil == self.capability_timer then
			self.capability_timer = GlobalTimerQuest:AddDelayTimer(function()
				self.capability_timer = nil
				SceneText.PlayCapabilityChangeEffect(self.last_capability)
			end, 0.5)
		end
	end
end

function MainuiHeadBar:SetMainRoleVip()
	local vip_level = VipData.Instance:GetRoleVipLevel()
	-- self.number_vip:SetNumber(vip_level)
end

function MainuiHeadBar:SetMainRoleHp(hp, max_hp)
	max_hp = max_hp <= 0 and 1 or max_hp 
	local percent = 100 * (hp / max_hp)
	self:ShowRedFlash(percent <= 30)
	self.mainrole_hpbar:setPercent(percent)
	self.mainrole_text_hp:setString(hp .. "/" .. max_hp)
end

function MainuiHeadBar:SetMainRoleMp(mp, max_mp)
	max_mp = max_mp <= 0 and 1 or max_mp 
	local percent = 100 * (mp / max_mp)
	local old_per = self.mainrole_mpbar:getPercent()
	self.mainrole_mpbar:setPercent(percent)
	local color = percent <= 10 and "ff0000" or "ffffff"
	RichTextUtil.ParseRichText(self.mainrole_text_mp, "{wordcolor;" .. color .. ";" .. mp .. "}" .. "/" .. max_mp, 20)
	if(old_per > 10 and percent <= 10) or (old_per <= 10 and percent > 10) then
		self:ShowMpAction(percent <= 10)
	end
end

function MainuiHeadBar:SetMainRoleProf(value)
	-- self.label_mainrole_prof:setString(Language.Common.ProfName2[value])
end

-- 设置目标
function MainuiHeadBar:OnSelectObj(target_obj, select_type)
	if self.target_obj == target_obj then
		return
	end


	local obj_type = -1
	if nil ~= target_obj then
		obj_type = target_obj:GetType()
	end

	if obj_type == SceneObjType.Role then
		self.mt_layout_monster:setVisible(false)
		self.target_obj = target_obj
		self:ShowOtherRoleHead(target_obj)
		GlobalEventSystem:Fire(OtherEventType.TARGET_HEAD_CHANGE, true)
	elseif obj_type == SceneObjType.Monster and target_obj:IsBoss() then
		self.mt_layout_otherrole:setVisible(false)
		self.target_obj = target_obj
		self:ShowMonsterHead(target_obj)
		GlobalEventSystem:Fire(OtherEventType.TARGET_HEAD_CHANGE, true)
	elseif FubenData.Instance:GetFubenId() ~= 0 then
	-- elseif PracticeCtrl.IsInPracticeMap()  then	
		self.mt_layout_otherrole:setVisible(false)
		self.mt_layout_monster:setVisible(false)
	else
		self.mt_layout_otherrole:setVisible(false)
		self.mt_layout_monster:setVisible(false)
		
		GlobalEventSystem:Fire(OtherEventType.TARGET_HEAD_CHANGE, false)
		self.target_obj = nil
	end
end

function MainuiHeadBar:OnObjDead(target_obj)
	if self.target_obj == target_obj then
		self:OnSelectObj(nil, "")
	end
end

function MainuiHeadBar:OnObjDel(target_obj)
	if self.target_obj == target_obj then
		self:OnSelectObj(nil, "")
	end
end

function MainuiHeadBar:OnHeadbarSceneChangeComplete(old_scene_type, new_scene_type)
	self:OnSelectObj(nil, "")
	-- self.exp_award_button:setVisible(RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL) >= 70 and not PracticeCtrl.IsInPracticeMap() and not PracticeCtrl.IsInPracticeGate())
	-- self.exp_award_switch_btn:setVisible(RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL) >= 70 and not PracticeCtrl.IsInPracticeMap() and not PracticeCtrl.IsInPracticeGate())
	--组队副本特殊处理
	-- Scene:()
	if Scene.Instance:GetFuBenId() == ZuDuiFuBenCfg[FubenMutilType.Team].fubenId then
		self:SetAttackMode(1)
	end

	-- 试炼经验奖励
	-- self.exp_award_switch_btn:setVisible(not IS_ON_CROSSSERVER)
	-- self.exp_award_button:setVisible(not IS_ON_CROSSSERVER)
end

function MainuiHeadBar:OnObjAttrChange(obj, key, value)
	if self.target_obj ~= obj or nil == self.target_obj then
		return
	end

	if key == OBJ_ATTR.CREATURE_HP or key == OBJ_ATTR.CREATURE_MAX_HP then
		if obj:GetType() == SceneObjType.Role then
			self:SetOtherRoleHP(obj:GetHp(), obj:GetMaxHp())
		elseif obj:GetType() == SceneObjType.Monster then
			self:SetMonsterHP(obj:GetHp(), obj:GetMaxHp())
		end
	elseif key == OBJ_ATTR.CREATURE_MP or key == OBJ_ATTR.CREATURE_MAX_MP then
		if obj:GetType() == SceneObjType.Role then
			self:SetOtherRoleMp(obj:GetMp(), obj:GetMaxMp())
		end
	elseif key == OBJ_ATTR.ACTOR_EQUIP_WEIGHT then
		self:SetMonsterShield(self.target_obj)
	elseif key == "ascription" then
		local txt = string.format(Language.Boss.HeadBossName, value[1], value[2])
		RichTextUtil.ParseRichText(self.text_monster_owner, txt, 20, COLOR3B.ORANGE)
		self.asc_role_id = value[3]
		self.asc_role_name = value[2]
	end

	if key == OBJ_ATTR.CREATURE_LEVEL or key == OBJ_ATTR.ACTOR_CIRCLE then
		self:FlushFunOpenTip()
	end
end

-- 显示角色头象
function MainuiHeadBar:ShowOtherRoleHead(target_obj)
	self.mt_layout_otherrole:setVisible(true)

	local vo = target_obj:GetVo()

	self.text_otherrole_name:setString(vo.name)
	self.text_otherrole_level:setString(tostring(vo[OBJ_ATTR.CREATURE_LEVEL]))
	-- self.text_otherrole_prof:setString(Language.Common.ProfName2[vo[OBJ_ATTR.ACTOR_PROF]])
	self.otherrole_head:SetRoleInfo(vo[OBJ_ATTR.ENTITY_ID], vo.name, vo[OBJ_ATTR.ACTOR_PROF], true, vo[OBJ_ATTR.ACTOR_SEX])
	self.otherrole_head:GetView():setPosition(76+(vo[OBJ_ATTR.ACTOR_SEX]*5), 74-(vo[OBJ_ATTR.ACTOR_SEX]*6))
	self:SetOtherRoleHP(target_obj:GetHp(), target_obj:GetMaxHp())
	self:SetOtherRoleMp(target_obj:GetMp(), target_obj:GetMaxMp())
end

-- 设置角色HP
function MainuiHeadBar:SetOtherRoleHP(hp, max_hp)
	if max_hp <= 0 then
		return
	end

	local percent = hp / max_hp * 100
	self.otherrole_hpbar:setPercent(percent)
	self.otherrole_text_hp:setString(hp .. "/" .. max_hp)
end

-- 设置角色MP
function MainuiHeadBar:SetOtherRoleMp(mp, max_mp)
	if max_mp <= 0 then
		return
	end

	local percent = mp / max_mp * 100
	self.otherrole_mpbar:setPercent(percent)
	self.otherrole_text_mp:setString(mp .. "/" .. max_mp)
end

-- 显示怪物头象
function MainuiHeadBar:ShowMonsterHead(target_obj)
	--------------------多人副本特殊判断--------------------
	local scene_id = Scene.Instance:GetSceneId()
	local x = FubenMutilLayer[scene_id] and 480 or 100
	self.mt_layout_monster:setPositionX(x)
	--------------------------------------------------------

	self.mt_layout_monster:setVisible(true)
	-- self.text_monster_name:setString(target_obj:GetName())
	-- self.text_monster_owner:setString(target_obj:GetVo().ascription)
	RichTextUtil.ParseRichText(self.text_monster_owner, target_obj:GetName(), 20, COLOR3B.ORANGE)
	self.text_monster_level:setString(tostring(target_obj:GetVo()[OBJ_ATTR.CREATURE_LEVEL]))
	self:SetMonsterHP(target_obj:GetHp(), target_obj:GetMaxHp())
	self:SetMonsterShield(target_obj)
	local reward_cfg = MainuiData.Instance:GetMonsterRewardCfg(target_obj:GetVo().monster_id)
	if StdMonster[target_obj:GetVo().monster_id].nKillDevilTokenLimit == nil then
		self.tumo_card:setVisible(false)
	else
		self.tumo_card:setVisible(true)
		self.tumo_num:setString(" ×" .. StdMonster[target_obj:GetVo().monster_id].nKillDevilTokenLimit)
	end
	
	if reward_cfg then
		for i = 1, 6 do
			if self.monster_rewwad_t[i] then
				self.monster_rewwad_t[i]:SetVisible(reward_cfg[i] ~= nil)
				if reward_cfg[i] then
					self.monster_rewwad_t[i]:SetData({item_id = reward_cfg[i].id, is_bind = reward_cfg[i].bind, num = reward_cfg[i].count})
				end
			end
		end
	else
		for k,v in pairs(self.monster_rewwad_t) do
			v:SetVisible(false)
		end
	end

	self.btn_monster_reward:setVisible(nil ~= CrossBossAwards[target_obj:GetVo().monster_id])
end

-- 怪物护盾
function MainuiHeadBar:SetMonsterShield(obj)
	if nil == obj.GetShieldVal or nil == obj.GetMaxShieldVal then
		return
	end

	local shield_val = obj:GetShieldVal()
	if -1 == shield_val then
		self.mt_layout_monster_shield:setVisible(false)
	else
		self.mt_layout_monster_shield:setVisible(true)
		local max_shield_val = obj:GetMaxShieldVal()
		self.shield_progress:setPercent(shield_val / max_shield_val * 100)
	end
end

function MainuiHeadBar.FormatMonsterVal(value)
	if value >= 10000 and value < 100000000 then
		return string.format("%.1f%s", value / 10000, Language.Common.Wan)
	elseif value >= 100000000 then
		return string.format("%.1f%s", value / 100000000, Language.Common.Yi)
	else
		return string.format("%d", value)
	end
end

-- 设置怪物HP
function MainuiHeadBar:SetMonsterHP(hp, max_hp)
	if max_hp <= 0 then
		return
	end

	local percent = hp / max_hp * 100
	self.monster_hpbar:setPercent(percent)
	self.monster_text_hp:setString(self.FormatMonsterVal(hp) .. "/" .. self.FormatMonsterVal(max_hp))
end

-- 显示npc头象
function MainuiHeadBar:ShowNpcHead(target_obj)
	self.mt_layout_npc:setVisible(true)
	self.text_npc_name:setString(target_obj:GetName())
end



----------------------------------------------------
-- 虚拟buff
----------------------------------------------------
function MainuiHeadBar.GetFakeBuffList()
	local func_list = {
		{func = MainuiHeadBar.GetGuildBuff, params = nil},
		-- {func = MainuiHeadBar.GetSoulBuff, params = nil},
		-- {func = MainuiHeadBar.GetCircleBuff, params = nil},
		{func = MainuiHeadBar.GetZJBuff, params = nil},
		{func = MainuiHeadBar.GetVIPBuff, params = nil},
		{func = MainuiHeadBar.GetHutiBuff, params = nil},

		{func = MainuiHeadBar.GetLsHeadtitleBuff, params = 38},
		{func = MainuiHeadBar.GetLsHeadtitleBuff, params = 39},
		{func = MainuiHeadBar.GetLsHeadtitleBuff, params = 40},
		{func = MainuiHeadBar.GetLsHeadtitleBuff, params = 41},
		-- {func = MainuiHeadBar.GetLsHeadtitleBuff, params = 42},
		-- {func = MainuiHeadBar.GetLsHeadtitleBuff, params = 43},
		{func = MainuiHeadBar.GetLsHeadtitleBuff, params = 44},

		{func =  MainuiHeadBar.GetLsHeadtitleBuff, params = 332},
		{func =  MainuiHeadBar.GetLsHeadtitleBuff, params = 333},
		{func =  MainuiHeadBar.GetLsHeadtitleBuff, params = 334},
	}

	local fake_buff_list = {}
	for k,v in pairs(func_list) do
		local data = v.func(v.params)
		if data then table.insert(fake_buff_list, data) end
	end

	return fake_buff_list
end

function MainuiHeadBar.GetBuffCfg(buff_id)
	if not StdBuff then return end
	for k,v in pairs(StdBuff) do
		if v.id == buff_id then return v end
	end
end

local fake_time_buff = {
	[332] = 1,
	[333] = 2,
	[334] = 3,
}

function MainuiHeadBar.GetFakeBuffDataById(buff_id)
	local cfg = MainuiHeadBar.GetBuffCfg(buff_id)
	if not cfg then
		ErrorLog("unknown buff_id: " .. buff_id .. "!")
		return
	end
	local time = PrivilegeData.Instance:GetPrivilegeTimeByIdx(fake_time_buff[buff_id])
	return {buff_id = buff_id, buff_icon = cfg.icon, buff_name = Language.Role.BuffShowName[buff_id] or "",name = cfg.name, buff_time = time}
end

-- 行会buff
function MainuiHeadBar.GetGuildBuff()
	local guild_id = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GUILD_ID)
	if guild_id <= 0 then return end
	return MainuiHeadBar.GetFakeBuffDataById(46)
end

-- 兽魂buff
function MainuiHeadBar.GetSoulBuff()
	local grade, level = 0, 0
	if not grade or grade <= 0 then return end
	return MainuiHeadBar.GetFakeBuffDataById(47)
end

-- 护体buff
function MainuiHeadBar.GetHutiBuff()
	if not RoleData.Instance:IsEntityState(EntityState.StateShield) then
		return
	end
	return MainuiHeadBar.GetFakeBuffDataById(50)
end


-- 转生buff
function MainuiHeadBar.GetCircleBuff()
	local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	if not circle or circle <= 0 then return end
	return MainuiHeadBar.GetFakeBuffDataById(49)
end

-- 战将附体buff
function MainuiHeadBar.GetZJBuff()
	-- local hero_state = ZhanjiangData.Instance:GetHeroState()
	-- if not hero_state or hero_state ~= HERO_STATE.MERGE then return end
	-- return MainuiHeadBar.GetFakeBuffDataById(48)
end

-- vip buff
function MainuiHeadBar.GetVIPBuff()
	local vip_level = VipData.Instance.vip_level
	if not vip_level or vip_level <= 0 then return end
	return MainuiHeadBar.GetFakeBuffDataById(45)
end

-- 临时称号buff
function MainuiHeadBar.GetLsHeadtitleBuff(buff_id)
	-- local title_id_list = {
	-- 	[38] = 30,
	-- 	[39] = 26,
	-- 	[40] = 29,
	-- 	[41] = 1,
	-- 	[42] = 2,
	-- 	[43] = 3,
	-- 	[44] = 4,
	-- 	[332] = 32,
	-- 	[333] = 33,
	-- 	[334] = 34,
	-- }
	local title_id_list = {
		[332] = 47,
		[333] = 48,
		[334] = 49,
		[44] = 33,
		[41] = 34,
		[38] = 42,
		[40] = 43,
		[39] = 44,
	}
	if not title_id_list[buff_id] then return end
	local is_active = TitleData.Instance:GetTitleActive(title_id_list[buff_id])
	if not is_active or is_active == 0 then return end
	return MainuiHeadBar.GetFakeBuffDataById(buff_id)
end

function MainuiHeadBar:OnGetUiNode(node_name)
	if node_name == MainUiNodeName.HeadbarCap then
		return self.number_zhanli:GetView(), true
	end
	return nil, true
end

----------------------------------------------------
-- 攻击模式
----------------------------------------------------
MainuiAtkModeRender = MainuiAtkModeRender or BaseClass(BaseRender)
function MainuiAtkModeRender:__init()
	self.atk_mode = 0
	self.desc = ""
	self.height = 0

	self.view:setAnchorPoint(0, 1)
end

function MainuiAtkModeRender:__delete()
	
end

function MainuiAtkModeRender:Create(w, h, atk_mode, desc)
	self.height = h
	self.width = w
	self.atk_mode = atk_mode
	self.desc = desc
	self.view:setContentWH(w, h)
	self:Flush()
end

function MainuiAtkModeRender:GetAtkMode()
	return self.atk_mode
end

function MainuiAtkModeRender:CreateChild()
	BaseRender.CreateChild(self)

	local img_atk_mode = MainuiHeadBar.CreateBtnAndImgNode(42, self.height / 2, ResPath.GetMainui("btn_11"), ResPath.GetMainui("atk_mode_" .. self.atk_mode))
	self.view:addChild(img_atk_mode)

	local text_desc = XUI.CreateText(84, self.height / 2, 200, 20, cc.TEXT_ALIGNMENT_LEFT, self.desc, nil, 20, nil)
	text_desc:setAnchorPoint(0, 0.5)
	self.view:addChild(text_desc)

	local img_atk_line = XUI.CreateImageView(self.width / 2, 0, ResPath.GetMainui("task_line"), true)
	self.view:addChild(img_atk_line)
end

function MainuiAtkModeRender:CanSelect()
	return true
end

function MainuiAtkModeRender:CreateSelectEffect()

end


----------------------------------------------------
-- buff图标
----------------------------------------------------
MainuiBuffRender = MainuiBuffRender or BaseClass(BaseRender)
MainuiBuffRender.Size = 44
MainuiBuffRender.ColCount = 4
function MainuiBuffRender:__init()
	self.view:setContentWH(MainuiBuffRender.Size, MainuiBuffRender.Size)
	self.view:setAnchorPoint(0.5, 0.5)
end

function MainuiBuffRender:__delete()
	
end

function MainuiBuffRender:CreateChild()
	BaseRender.CreateChild(self)

	self.img_buff_icon = XUI.CreateImageView(22, 22, ResPath.GetBuff(99), false)
	self.view:addChild(self.img_buff_icon)
end

function MainuiBuffRender:OnFlush()
	if nil == self.data or nil == self.data[1] then
		return
	end
	local cfg = MainuiHeadBar.GetBuffCfg(self.data[1].buff_id)
	local icon = cfg and cfg.icon or 99
	self.img_buff_icon:loadTexture(ResPath.GetBuff(icon))
end


MainUIOpenListRender = MainUIOpenListRender or BaseClass(BaseRender)
function MainUIOpenListRender:__init()
	-- body
end

function MainUIOpenListRender:__delete()
	-- body
end

function MainUIOpenListRender:CreateChild()
	BaseRender.CreateChild(self)
	XUI.EnableOutline(self.node_tree.text_condition.node)
end

function MainUIOpenListRender:OnFlush()
	if self.data == nil then
		return
	end
	self.node_tree.img_name.node:loadTexture(ResPath.GetFunOpenResPath("name_"..self.data.name_id))
	self.node_tree.img_icon.node:loadTexture(ResPath.GetFunOpenResPath("res_"..self.data.res_id))
	self.node_tree.img_name.node:setScale(1.4)
	local cond = GameCond[self.data.opne_cond]
	if cond then
		local text = ""
		if cond.RoleCircle and cond.RoleCircle > 0 then
			text = text..cond.RoleCircle.."转"
		end
		if cond.RoleLevel and cond.RoleLevel > 0 then
			text = text..cond.RoleLevel.."级"
		end

		self.node_tree.text_condition.node:setString(text)
		-- RichTextUtil.ParseRichText(self.node_tree.text_condition.node,text, 20, COLOR3B.GREEN)
		-- XUI.RichTextSetCenter(self.node_tree.text_condition.node)
	end
end

function MainUIOpenListRender:CreateSelectEffect()
	local size = self.view:getContentSize()
	self.select_effect = XUI.CreateImageView(size.width/2, size.height/2+10, ResPath.GetFunOpenResPath("cell_eff"), true)
	if nil == self.select_effect then
		ErrorLog("BaseRender:CreateSelectEffect fail")
		return
	end
	self.view:addChild(self.select_effect, 999)
end