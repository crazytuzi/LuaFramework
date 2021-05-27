local View = BaseClass(SubView)

View.CanWearEquipNumMax = 6			--战将装备可佩戴最大数
View.AlreadyCanGetEquipNum = ItemData.ItemType.itHeroEquipMax - ItemData.ItemType.itHeroCuff	--战将已经能获取的装备数

function View:__init(view_def, data_model)
	self:SetModal(true)
	self.def_index = TabIndex.zhanjiang_zhanjiang

	self.texture_path_list[1] = "res/xui/zhanjiang.png"
	self.texture_path_list[2] = "res/xui/role.png"
	self.texture_path_list[3] = "res/xui/wing.png"

	self.config_tab = {
		{"zhanjiang_ui_cfg", 1, {TabIndex.zhanjiang_zhanjiang}},
	}
	self.data = data_model
end

function View:LoadCallBack()
	self.hero_model = nil
	self.cell_list = nil
	self.zhanjiang_attr_list = nil
	self.futi_attr_list = nil
	self.confirmDlg = nil
	
	self:CreateHeroModel()
	-- self:CreateEquipCells()
	self:CreateZhanjiangAttrList()
	self:CreateFutiAttrList()
	self:CreateConfirmDlg()
	self.stars_ui = UiInstanceMgr.Instance:CreateStarsUi({x = self.ph_list.ph_star.x, y = self.ph_list.ph_star.y, interval_x = 3,
		star_num = 10, parent = self.node_t_list.layout_zhanjiang.node, zorder = 10,})

	-- self.txt_get_material = RichTextUtil.CreateLinkText(Language.Zhanjiang.ObtainUpdateMaterial, 20, COLOR3B.GREEN)
	-- self.txt_get_material:setPosition(750, 170)
	-- self.node_t_list.layout_zhanjiang.node:addChild(self.txt_get_material, 100)

	if not self.data:IsActivatedSucc() then
		if not self.btn_activate then
			self.btn_activate = XUI.CreateButton(269, 356, 112, 115, false, ResPath.GetCommon("btn_activate"), nil, nil, true)
			self.btn_activate:setVisible(false)
			self.node_t_list.layout_zhanjiang.node:addChild(self.btn_activate, 100, 100)
			--激活按钮加特效
			-- local act_eff = RenderUnit.CreateEffect(900, self.btn_activate, 10, FrameTime.Effect, COMMON_CONSTS.MAX_LOOPS)
			-- act_eff:setScale(1.2)
			XUI.AddClickEventListener(self.btn_activate, BindTool.Bind(self.OnActivateClicked, self), true)
		end
	end
	self:SetTextUiAttrs()
	self:RegisterAllEvents()
	self:SetRonghunBtnVis()

	self.node_t_list.img_flag_1.node:setVisible(false)
	-- self.node_t_list.img_flag_2.node:setVisible(false)

	-- EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.ItemDataListChangeCallback, self))
end

function View:ReleaseCallBack()
	if nil ~= self.hero_model then
		self.hero_model:DeleteMe()
		self.hero_model = nil
	end
	if nil ~= self.cell_list then
		for k, v in pairs(self.cell_list) do
			v:DeleteMe()
		end
		self.cell_list = nil
	end
	if nil ~= self.zhanjiang_attr_list then
		self.zhanjiang_attr_list:DeleteMe()
		self.zhanjiang_attr_list = nil
	end
	if nil ~= self.futi_attr_list then
		self.futi_attr_list:DeleteMe()
		self.futi_attr_list = nil
	end
	if nil ~= self.confirmDlg then
		self.confirmDlg:DeleteMe()
		self.confirmDlg = nil
	end
	self.zhu_up_add = nil
	self.fu_up_add = nil
	self.btn_activate = nil
	self.layout_wing_auto_hook = nil
	self.play_eff = nil
	self.btn_ronghun = nil
	self.stars_ui = nil
end

function View:CreateHeroModel()
	self.hero_model = MonsterDisplay.New(self.node_t_list["layout_zhanjiang"].node, 20)
	self.hero_model:SetPosition(269, 326)
	self.hero_model:SetScale(1.2)
end

function View:CreateZhanjiangAttrList()
	self.zhanjiang_attr_list = ListView.New()
	local positionHelper = self.ph_list.ph_zhanjiang_attr_list
	self.zhanjiang_attr_list:Create(positionHelper.x, positionHelper.y, positionHelper.w, positionHelper.h, nil, ZhanjiangAttrItem, nil, nil, self.ph_list.ph_zhanjiang_attr_item)
	self.node_t_list.layout_attr_panel.node:addChild(self.zhanjiang_attr_list:GetView(), 100, 100)
	self.zhanjiang_attr_list:GetView():setAnchorPoint(0,0)
	self.zhanjiang_attr_list:SetItemsInterval(3)
	self.zhanjiang_attr_list:JumpToTop(true)
end

function View:CreateFutiAttrList()
	self.futi_attr_list = ListView.New()
	local positionHelper = self.ph_list.ph_futi_attr_list
	self.futi_attr_list:Create(positionHelper.x, positionHelper.y, positionHelper.w, positionHelper.h, nil, ZhanjiangAttrItem, nil, nil, self.ph_list.ph_zhanjiang_attr_item)
	self.node_t_list.layout_attr_panel.node:addChild(self.futi_attr_list:GetView(), 100, 100)
	self.futi_attr_list:GetView():setAnchorPoint(0,0)
	self.futi_attr_list:SetItemsInterval(3)
	self.futi_attr_list:JumpToTop(true)
end

function View:CreateConfirmDlg()
	if not self.confirmDlg then
		self.confirmDlg = Alert.New()
		self.confirmDlg:SetShowCheckBox(false)
		self.confirmDlg:SetLableString(Language.Zhanjiang.ConfirmDlgContent)
		self.confirmDlg:SetOkFunc(BindTool.Bind(self.ConfirmFightClicked, self))
	end
end

function View:SetTextUiAttrs()
	self.node_t_list.lbl_zhanjiang_attr.node:setLocalZOrder(999)
	self.node_t_list.img_title_bg.node:setLocalZOrder(998)
	XUI.EnableOutline(self.node_t_list.lbl_zhanjiang_attr.node, c4b, size)
	XUI.RichTextSetCenter(self.node_t_list.rich_zhanjiang_consume.node)
end

function View:RegisterAllEvents()
	XUI.AddClickEventListener(self.node_t_list.layout_zhanjiang.btn_is_fight.node, BindTool.Bind(self.OnClickBtnFightCallBack, self))
	XUI.AddClickEventListener(self.node_t_list.layout_zhanjiang.btn_help.node, BindTool.Bind(self.OnClickBtnHelpCallBack, self))
	XUI.AddClickEventListener(self.node_t_list.layout_zhanjiang.btn_begin_uplv.node, BindTool.Bind(self.OnClickBtnUpLvCallBack, self))
end

function View:ShowIndexCallBack()
	self:Flush()
end

function View:OnFlush(param_t)
	local is_activated = self.data:IsActivatedSucc()
	self:FlushIsFightBtn()
	self:FlushIsMergedBtn()
	if self.btn_activate then
		self.btn_activate:setVisible(not is_activated)
	end
	XUI.SetButtonEnabled(self.node_t_list.btn_is_fight.node, is_activated)
	-- XUI.SetButtonEnabled(self.node_t_list.btn_is_merged.node, is_activated)
	XUI.SetButtonEnabled(self.node_t_list.btn_begin_uplv.node, is_activated)
	-- XUI.SetButtonEnabled(self.node_t_list.btn_auto_uplv.node, is_activated)

	for k, v in pairs(param_t) do
		if k == "all" then
			if is_activated then
				self:OnFlushView()
			end
			self:FlushBtnRemind()
		elseif k == "zhanjiang" then
			self:OnFlushView()
		elseif k == "hero_next_lv" then
			if self.is_up_succ then
				self.zhu_up_add, self.fu_up_add = self.data:SetHeroNextAttrsAdd()
				if self.show_next_lv_timer then
					GlobalTimerQuest:CancelQuest(self.show_next_lv_timer)
					self.show_next_lv_timer = nil
				end
				self.is_up_succ = false
				self.show_next_lv_timer = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.ClearNextLvAddData, self), 1.55)
				self:OnFlushView()
			end
		elseif k == "activate_succ" then
			self:PlayShowEffect(901, 350, 300)
		elseif k == "dispossess_succ" then
			self:PlayShowEffect(906, 350, 300)
		elseif k == "merge_succ" then
			self:PlayShowEffect(905, 350, 300)
		elseif k == "money" then
			self:FlushConsumeView()
		elseif k == "equip" then
			-- self:FlushEquipCells()
		elseif k == "state_change" then
			self:FlushIsFightBtn()
			self:FlushIsMergedBtn()
		elseif k == "upgrade_succ" then
			if self.is_auto_upgrade then
				self:BuildReqSendTimer()
			else
				self:CancelReqSendTimer()
			end
			self:FlushAutoXxxBtn()
			self:PlayShowEffect(902, 800, 250)
			self:SetRonghunBtnVis()
		elseif k == "lianti_succ" then
			if self.is_auto_exercise then
				self:BuildReqSendTimer()
			else
				self:CancelReqSendTimer()
			end
			self:FlushAutoXxxBtn()
			self:PlayShowEffect(904, 800, 250)
		elseif k == "stop_upgrade" then
			self.is_auto_upgrade = false
			self:CancelReqSendTimer()
			self:FlushAutoXxxBtn()
			self.node_t_list.btn_begin_uplv.node:setEnabled(true)
		elseif k == "remind" then
			-- self:FlushEquipCells()
			self:FlushBtnRemind()
		elseif k == "stop_exercise" then
			self.is_auto_exercise = false
			self:CancelReqSendTimer()
			self:FlushAutoXxxBtn()
			self.node_t_list.btn_begin_uplv.node:setEnabled(true)
		end
	end
end

function View:SetRonghunBtnVis()
	local hero_data = self.data:GetHeroData()
	local level = hero_data and hero_data.level or 0
	-- self.btn_ronghun:setVisible( self.data:IsActivatedSucc() and level >= ZhanjiangData.HeroLvMax )
end

function View:FlushBtnRemind()
	local remind_num = self.data:GetHeroRemindNum()
	self.node_t_list.img_flag_1.node:setVisible( remind_num > 0 )
	-- self.node_t_list.img_flag_2.node:setVisible( remind_num > 0 )
end

function View:SetUpSuccFlag(bool)
	self.is_up_succ = bool
end

--出战-休战 切换
function View:FlushIsFightBtn()
	local text = Language.Zhanjiang.GoBattle
	local hero_state = self.data:GetHeroState()
	if hero_state == HERO_STATE.SHOW then
		text = Language.Zhanjiang.NotGoBattle
	end
	self.node_t_list["btn_is_fight"].node:setTitleText(text)
end

--合体-解体 切换
function View:FlushIsMergedBtn()
	local text = Language.Zhanjiang.Possess
	local hero_state = self.data:GetHeroState()
	if hero_state == HERO_STATE.MERGE then
		text = Language.Zhanjiang.Dispossess
	end
	-- self.node_t_list["btn_is_merged"].node:setTitleText(text)
end

--战将信息刷新
function View:OnFlushView()
	local zhu_data, fu_data = self.data:GetHeroAttrData()		--战将主/附体属性
	if self.zhu_up_add then
		for k_1,v_1 in pairs(self.zhu_up_add) do
			for k_2, v_2 in pairs(zhu_data) do
				if v_1.type == v_2.type then
					v_2.add_value = v_1.value_str
				end
			end
		end
	end
	if self.fu_up_add then
		for k_1,v_1 in pairs(self.fu_up_add) do
			for k_2,v_2 in pairs(fu_data) do
				if v_1.type == v_2.type then
					v_2.add_value = v_1.value_str
				end
			end
		end
	end
	self.zhanjiang_attr_list:SetDataList(zhu_data)
	self.futi_attr_list:SetDataList(fu_data)

	local name = self.data:GetOtherInfoList().name
	self.node_t_list.lbl_zhanjiang_attr.node:setString(name)
	self:ShowHeroModel()
	self:FlushConsumeView()
	-- self:FlushEquipCells()

	self.stars_ui:SetStarActNum(1)
	-- self.stars_ui:GetView():setVisible(nil ~= equip_data)
end

--显示英雄形象
function View:ShowHeroModel()
	local model_data = self.data:GetHeroModelIdData()
	self.hero_model:SetMonsterVo(model_data)
end

function View:ClearNextLvAddData()
	self.zhu_up_add = nil
	self.fu_up_add = nil
	self:Flush(self:GetShowIndex(), "zhanjiang")
end

function View:FlushEquipCells()
	local owned_equip = self.data:GetOwnedEquipList()
	for k, v in pairs(self.cell_list) do
		v:SetData(owned_equip[k])
		v:SetRemind(nil ~= self.data:GetMaxEquipByType(v.equip_type), true)
	end
end

--自动 xxx -- 取消自动 切换
function View:FlushAutoXxxBtn()
	local text = nil
	text = Language.Zhanjiang.AutoUpgrade
	if self.is_auto_upgrade and self.data:IsUpHeroLvSucc() then 
		text = Language.Zhanjiang.CancelAuto 
	end
	self.node_t_list["btn_auto_uplv"].node:setTitleText(text)
end

function View:FlushConsumeView()
	local hero_data = self.data:GetHeroData()
	local consume_txt = ""
	if hero_data.level >= ZhanjiangData.HeroLvMax then
		consume_txt = Language.Common.AlreadyTopLv
	else
		local consume_id = ZhanjiangData.ConsumeId
		local consume_num = ZhanjiangData.GetHeroUpgradeCfg(hero_data.level).value
		local item_cfg = ItemData.Instance:GetItemConfig(consume_id)
		local num_in_bag = BagData.Instance:GetItemNumInBagById(consume_id)
		if item_cfg then
			consume_txt = string.format(Language.Zhanjiang.UpLvConsumeTxt, item_cfg.name, consume_num, num_in_bag > consume_num and "00ff00" or "ff0000", num_in_bag)
		end
	end

	RichTextUtil.ParseRichText(self.node_t_list.rich_zhanjiang_consume.node, consume_txt, 22)
end

-- 播放特效
function View:PlayShowEffect(eff_id, x, y)
	if self.play_eff == nil then
		self.play_eff = AnimateSprite:create()
		self.root_node:addChild(self.play_eff, 9999)
	end
	self.play_eff:setPosition(x, y)
	local anim_path, anim_name = ResPath.GetEffectUiAnimPath(eff_id)
	self.play_eff:setAnimate(anim_path, anim_name, 1, FrameTime.Effect, false)
end

--创建延迟请求定时器
function View:BuildReqSendTimer()
	if not self.send_req_timer then
		self.send_req_timer = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.OnClickBtnUpLvCallBack, self), 0.25)
	end
end

--取消延迟定时器
function View:CancelReqSendTimer()
	if self.send_req_timer then
		GlobalTimerQuest:CancelQuest(self.send_req_timer)
		self.send_req_timer = nil
	end
end

function View:OnClickBtnRonghunCallBack()
	if CrossServerCtrl.CrossServerPingbi() then return end

	self:ChangeToIndex(TabIndex.zhanjiang_ronghun)
end

function View:OnClickBtnFightCallBack()
	local hero_state = self.data:GetHeroState()
	self.data:SetHeroPreState(hero_state)
	if hero_state == HERO_STATE.REST then
		ZhanjiangCtrl.SetHeroStateReq(self.data:GetOtherInfoList().hero_id, HERO_STATE.SHOW)
	elseif hero_state == HERO_STATE.SHOW then
		ZhanjiangCtrl.SetHeroStateReq(self.data:GetOtherInfoList().hero_id, HERO_STATE.REST)
		SettingCtrl.Instance:ChangeGuaJiSetting({[GUAJI_SETTING_TYPE.AUTO_CALL_HERO] = false})
	elseif hero_state == HERO_STATE.MERGE then 
		if self.confirmDlg then
			self.confirmDlg:Open()
		end
	end
end

function View:OnClickZhanjiangAutoHook()
	if CrossServerCtrl.CrossServerPingbi() then return end

	local vis = self.layout_wing_auto_hook.img_hook.node:isVisible()
	self.layout_wing_auto_hook.img_hook.node:setVisible(not vis)
end

function View:OnClickBtnMergedCallBack()
	if CrossServerCtrl.CrossServerPingbi() then return end

	local hero_state = self.data:GetHeroState()
	self.data:SetHeroPreState(hero_state)
	if hero_state ~= HERO_STATE.MERGE then
		ZhanjiangCtrl.SetHeroStateReq(self.data:GetOtherInfoList().hero_id, HERO_STATE.MERGE)
	else
		ZhanjiangCtrl.SetHeroStateReq(self.data:GetOtherInfoList().hero_id, HERO_STATE.SHOW)
	end
end

function View:OnClickBtnHelpCallBack()
	DescTip.Instance:SetContent(Language.Zhanjiang.DescContent, Language.Zhanjiang.TipTitle)
end

function View:OnClickBtnUpLvCallBack()
	if CrossServerCtrl.CrossServerPingbi() then return end

	self:CancelReqSendTimer()
	-- local vis = self.layout_wing_auto_hook.img_hook.node:isVisible()
	ZhanjiangCtrl.UpgradeHeroGradeReq(self.data:GetOtherInfoList().hero_id)
end

function View:OnClickBtnAutoUpLvCallBack()
	if CrossServerCtrl.CrossServerPingbi() then return end

	self.is_auto_upgrade = not self.is_auto_upgrade
	if self.is_auto_upgrade then
		self:BuildReqSendTimer()
	end
end

function View:OnClickHeroEquip(cell)
	if CrossServerCtrl.CrossServerPingbi() then return end
	
	if nil == cell then
		return
	end

	local max_equip = self.data:GetMaxEquipByType(cell.equip_type)
	if nil ~= max_equip then
		ZhanjiangCtrl.HeroPutOnEquipReq(max_equip.series)
		return
	end

	local equip_data = cell:GetData()
	if equip_data ~= nil and next(equip_data) ~= nil then
		TipCtrl.Instance:OpenItem(equip_data, EquipTip.FROM_HERO_EQUIP)
	end
end

function View:OnClickObtainMaterial()
	if CrossServerCtrl.CrossServerPingbi() then return end

	local id = ActiveDegreeData.Instance:GetNpcQuicklyTransportId(80)
	local data = {
		{stuff_way = Language.Zhanjiang.WayTitles[1], go_to = id},
	}
	TipCtrl.Instance:OpenStuffTip(Language.Zhanjiang.AdvanceStuffGetWay, data)
end

--确定出战
function View:ConfirmFightClicked()
	ZhanjiangCtrl.SetHeroStateReq(self.data:GetOtherInfoList().hero_id, HERO_STATE.SHOW)
end

function View:OnActivateClicked()
	ZhanjiangCtrl.HeroActivateReq(0)
end

--战将属性itemrender
ZhanjiangAttrItem = ZhanjiangAttrItem or BaseClass(BaseRender)
function ZhanjiangAttrItem:__init()
end

function ZhanjiangAttrItem:CreateChild()
	BaseRender.CreateChild(self)
	XUI.RichTextSetCenter(self.node_tree.rich_attr_value.node)
	self.node_tree.lbl_attr_name.node:setColor(cc.c3b(0xf5, 0xf3, 0xdf))
end

function ZhanjiangAttrItem:OnFlush()
	if self.data == nil then return end
	if self.data.type == "fight_power" then
		self.node_tree.lbl_attr_name.node:setString(Language.Zhanjiang.FightPower)
	else
		self.node_tree.lbl_attr_name.node:setString(self.data.type_str .. "：")
	end 
	local add_value = ""
	if self.data.add_value then
		add_value = " {wordcolor;1eff00;↑" .. self.data.add_value .. "}"
	end
	RichTextUtil.ParseRichText(self.node_tree.rich_attr_value.node, self.data.value_str .. add_value)
end

function ZhanjiangAttrItem:CreateSelectEffect()
end


return View