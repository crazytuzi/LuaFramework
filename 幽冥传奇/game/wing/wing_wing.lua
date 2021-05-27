WingView = WingView or BaseClass(BaseView)

function WingView:openShenyu()
	self:ChangeToIndex(TabIndex.wing_compound)
end

function WingView:InitWingView()
	
	--翅膀技能
	-- self.WingSkills = {
	-- 	[1] = "强力", [2] = "羽盾", [3] = "羽刃", [4] = "影翼", [5] = "千刃", [6] = "幻翼",
	-- }
	self.tip_message = "钻石和精羽毛"

	self.fall_star_eff_t = {}
	self.wing_equ_cells = nil
	self.auto_up_wing = false
	self.up_need_yb = 0

	self:CreateWingAttrList()
	-- self:createWingNextAttrList()
	self:CreateWingStar()
	self:CreateWingEquCell()
	self:ChangeShenyuHookImgShow()
	self:CreateWingEquipList()

	--战力
	local cap_x, cap_y = self.node_t_list.img_zl_bg.node:getPosition()
	self.fight_power_view = FightPowerView.New(cap_x -50, cap_y, self.node_t_list.layout_wing.node, 99)

	XUI.AddClickEventListener(self.node_t_list.btn_jinjie.node, BindTool.Bind(self.OnClickUpWingHandler, self,0))
	self.node_t_list.btn_auto_jinjie.node:addClickEventListener(BindTool.Bind(self.OnClickAutoUpWingHandler, self))
	--self.node_t_list.btn_wing_tips.node:addClickEventListener(BindTool.Bind1(self.OnClickWingTipHandler, self))

	--btn - 神羽
	self.node_t_list.btn_shenyu.node:addClickEventListener(BindTool.Bind1(self.openShenyu, self))
	--左右跳转按钮
	self.node_t_list.btn_turnleft.node:addClickEventListener(BindTool.Bind(self.OnClickTurnWingViewBtn, self,1))
	self.node_t_list.btn_turnright.node:addClickEventListener(BindTool.Bind(self.OnClickTurnWingViewBtn, self,0))

	self.layout_wing_auto_hook = self.node_tree.layout_wing.layout_upgrade.layout_w_auto_hook
	self.layout_wing_auto_hook.btn_nohint_checkbox.node:addClickEventListener(BindTool.Bind1(self.OnClickWingAutoHook, self))
	--翅膀
	self.wing_display = ModelAnimate.New(ResPath.GetChibangBigAnimPath, self.node_t_list.layout_wing_show.node)
	self.wing_display:SetAnimPosition(140,-80)
	self.node_t_list.layout_wing_show.node:setLocalZOrder(999)
	self.wing_display:GetAnimNode():setScale(0.6)
	-- CommonAction.ShowJumpAction(self.wing_display:GetAnimNode(), 100)

	self.activate_img = XUI.CreateImageView(self.ph_list.ph_activate.x, self.ph_list.ph_activate.y, ResPath.GetCommon("btn_activate"), true)
	self.activate_img:setVisible(false)
	self.node_tree.layout_wing.node:addChild(self.activate_img, 99)
	XUI.AddClickEventListener(self.activate_img, BindTool.Bind1(self.OnClickWingActivateHandler, self))
	
	-- local size = self.activate_img:getContentSize()
	-- local act_eff = RenderUnit.CreateEffect(900, self.activate_img, 10, nil, nil, size.width / 2, size.height / 2)
	-- act_eff:setScale(1.2)

	XUI.RichTextSetCenter(self.node_t_list.rich_jingyunum.node)
	XUI.RichTextSetCenter(self.node_t_list.rich_wing_updatetip.node)

	self.layout_wing_auto_hook.img_hook.node:setVisible(false)

	local prog = XUI.CreateLoadingBar(180, 56, ResPath.GetCommon("prog_104_progress"), XUI.IS_PLIST, nil, true, 320, 16, cc.rect(11,1,23,9))
	--XUI.CreateLoadingBar(190, 75, ResPath.GetCommon("prog_104_progress"), true, ResPath.GetCommon("prog_104"))
	-- prog:setScaleX(0.85)
	prog:setLocalZOrder(2)
	self.node_t_list.layout_upgrade.node:addChild(prog)
	self.wing_progressbar = ProgressBar.New()
	self.wing_progressbar:SetView(prog)
	self.wing_progressbar:SetTailEffect(991, nil, true)
	self.wing_progressbar:SetEffectOffsetX(-20)
	self.wing_progressbar:SetPercent(100)

	self.node_t_list.img_flag_1.node:setVisible(false)
	self.node_t_list.img_flag_2.node:setVisible(false)
	self.node_t_list.lbl_wing_name.node:setLocalZOrder(999)

	--获取精羽
	-- self.txt_get_feather = RichTextUtil.CreateLinkText("", 20, COLOR3B.GREEN)
	-- self.txt_get_feather:setPosition(190, -50)
	-- XUI.AddClickEventListener(self.txt_get_feather, BindTool.Bind(self.OnClickGetFeather, self), true)
	-- self.node_t_list.layout_upgrade.node:addChild(self.txt_get_feather, 100)

	--获取进入界面时的翅膀等级
	self.old_wing_level = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SWING_LEVEL)
	--获取进入界面时的翅膀经验
	self.wing_exp = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SWING_EXP)

	self:ChangeLevelAbout(WingData.Instance:GetWingUpgrade())
	self:ChangeExpAbout(WingData.Instance:GetExpChangeData())
	self:ChangeFeatherAbout(WingData.Instance:ChangeAboutFeatherData())

	local proxy = EventProxy.New(WingData.Instance, self)
	proxy:AddEventListener(WingData.WING_UPGRADE, BindTool.Bind(self.ChangeLevelAbout, self))
	proxy:AddEventListener(WingData.WING_EXP_CHANGE, BindTool.Bind(self.ChangeExpAbout, self))
	proxy:AddEventListener(WingData.WING_FEATHER_CHANGE, BindTool.Bind(self.ChangeFeatherAbout, self))
	proxy:AddEventListener(WingData.SHENYU_DATA_CHANGE, BindTool.Bind(self.ChangeShenyuHookImgShow, self))
	
	EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.RoleDataChangeCallback, self))
end

function WingView:RoleDataChangeCallback(vo)
	if vo.key == OBJ_ATTR.CREATURE_LEVEL or vo.key == OBJ_ATTR.ACTOR_CIRCLE or vo.key == OBJ_ATTR.ACTOR_SWING_LEVEL then
		self:OnFlushWingView()
	end
end


function WingView:DeleteWingView()
	if self.ten_grade_alert then
		self.ten_grade_alert:DeleteMe()
		self.ten_grade_alert = nil
	end
	if self.wing_dialog then
		self.wing_dialog:DeleteMe()
		self.wing_dialog = nil
	end
	if self.wind_bug_gift_view then
		self.wind_bug_gift_view:DeleteMe()
		self.wind_bug_gift_view = nil
	end

	if self.wing_attr_list then
		self.wing_attr_list:DeleteMe()
		self.wing_attr_list = nil
	end

	if self.wing_equ_cells ~= nil then
		for k,v in pairs(self.wing_equ_cells) do
			v:DeleteMe()
		end
		self.wing_equ_cells = nil
	end

	self.play_eff = nil

	if self.wing_progressbar then
		self.wing_progressbar:DeleteMe()
		self.wing_progressbar = nil
	end
	self.fall_star_eff_t = {}

	if self.one_timer then
		GlobalTimerQuest:CancelQuest(self.one_timer)
		self.one_timer = nil
	end

	if self.wing_equip_list then
		self.wing_equip_list:DeleteMe()
		self.wing_equip_list = nil
	end

	if self.wingup_alert then
		self.wingup_alert:DeleteMe()
		self.wingup_alert = nil
	end

	if self.fight_power_view then
		self.fight_power_view:DeleteMe()
		self.fight_power_view = nil
	end

	self.up_data = nil
	self.max_level_text = nil
	self.last_per = nil
	self.activate_img = nil
	self.show_wing_index = nil
	self.ClickToActive = nil
end

function WingView:CloseCallBack()
	-- self:ChangeLevelAbout(WingData.Instance:GetWingUpgrade())
end

--当前属性
function WingView:CreateWingAttrList()
	local ph = self.ph_list.ph_curshuxing_list
	self.wing_attr_list = ListView.New()
	self.wing_attr_list:Create(ph.x, ph.y, ph.w, ph.h, nil, self.WingCurAttrItem, nil, nil, self.ph_list.ph_wing_curattr_item)
	self.wing_attr_list:GetView():setAnchorPoint(0, 0)
	self.node_t_list.layout_wing.node:addChild(self.wing_attr_list:GetView(), 100)
	self.wing_attr_list:SetItemsInterval(10)
	self.wing_attr_list:SetJumpDirection(ListView.Top)
	--self.wing_attr_list:SetGravity(ListViewGravity.Left)
end

function WingView:CreateWingStar()
	self.wing_star_effs = {}
	self.wing_stars = {}
	local ph = self.ph_list.ph_wing_star
	for i = 1, 10 do
		local file = ResPath.GetCommon("star_1_lock")	
		local start = XUI.CreateImageView(ph.x + (i - 1) * 34, ph.y , file)
		self.node_t_list.layout_upgrade.node:addChild(start, 99)
		local start_eff = RenderUnit.CreateEffect(911, self.node_t_list.layout_upgrade.node, nil, nil, nil, ph.x + (i - 1) * 34, ph.y)
		start_eff:setVisible(false)
		start:setVisible(false)
		self.wing_star_effs[i] = start_eff
		self.wing_stars[i] = start
	end
end

--创建装备
function WingView:CreateWingEquCell()
	self.wing_equ_cells = {}
	for i = 1, 4 do
		local ph = self.ph_list["ph_equ_cell_" .. i]
		local cell = BaseCell.New()
		cell:SetPosition(ph.x, ph.y)
		self.node_t_list.layout_wing.layout_wing_equ.node:addChild(cell:GetView(), 100)
		-- cell:SetIsShowTips(false)
		cell:SetCellSpecialBg(ResPath.GetZhangjiang("cell_1"))
		cell:SetBgTa(ResPath.GetRole("img_add"))
		cell:SetIndex(i)
		-- local style = {bg = "", bg_ta = ResPath.GetZhangjiang("cell_1"), cell_desc = ""}
		-- cell:SetSkinStyle(style)
		cell:SetItemTipFrom(EquipTip.FROM_WING_EQUIP)
		cell:SetClickCallBack(BindTool.Bind(self.OnClickEquipCallBack, self, cell))
		table.insert(self.wing_equ_cells, cell)
	end
end

-- 创建影翼装备
function WingView:CreateWingEquipList()
	if self.wing_equip_list == nil then
		local ph = self.ph_list.ph_wing_equip_list
		self.wing_equip_list = ListView.New()
		self.wing_equip_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, WingEquipRender, nil, nil, self.ph_list.ph_wing_equip_item)
		self.wing_equip_list:GetView():setAnchorPoint(0, 0)
		self.wing_equip_list:SetItemsInterval(10)
		self.wing_equip_list:SetMargin(2)
		-- self.wing_equip_list:SetJumpDirection(ListView.Top)
		self.wing_equip_list:SetSelectCallBack(BindTool.Bind(self.WingEquCallback, self))
		self.node_t_list.layout_wing.node:addChild(self.wing_equip_list:GetView(), 100)
	end	
end

function WingView:WingEquCallback(item, index)
	if item:GetData() == nil then return end

	local data = item:GetData()
	if data.cfg == nil then
		if WingData.Instance:IsHaveWingEquipOnBag(data.item_id) == 1 then
			local item = BagData.Instance:GetOneItem(data.item_id)
			WingCtrl.SendEquipmentShenyu(item.series)
		else
			self.select_ronghun_slot = index
			self:ChangeToIndex(TabIndex.wing_preview)
			self:FlushPreview()
		end
	end
end

--更新翅膀经验
function WingView:ChangeExpAbout(vo)

	if vo.eightLevelRemind then
		self:SepcialGradeRemind()
	end

	self.node_t_list.btn_jinjie.node:setEnabled(vo.wind_id > 0)
	self.node_t_list.btn_auto_jinjie.node:setEnabled(vo.wind_id > 0)

	if vo.wing_cfg and WingData.Instance:GetWingLevel() < #WingData.Instance:GetWingConfig() then
		self.node_t_list.layout_upgrade.node:setVisible(true)
		if vo.per ~= nil then
			self.wing_progressbar:SetPercent(vo.per, vo.wing_cfg.appearanceId ~= nil)
		end
		self.node_t_list.lbl_wing_prog.node:setString(vo.per_text)
	else
		self.node_t_list.layout_upgrade.node:setVisible(false)
		self.node_t_list.rich_jingyunum.node:setVisible(false)
		XUI.SetButtonEnabled(self.node_t_list.btn_jinjie.node, false)
		XUI.SetButtonEnabled(self.node_t_list.btn_auto_jinjie.node, false)
		if self.max_level_text == nil and vo.wing_cfg ~= nil then
			self.max_level_text = XUI.CreateText(748, 170, 230, 30, nil, Language.Wing.WingMaxLevel, nil, 26, COLOR3B.OLIVE)
			self.max_level_text:setAnchorPoint(0.5, 0.5)
			self.node_tree.layout_wing.node:addChild(self.max_level_text, 99)
		end
		--可提升标志
		self.node_t_list.img_flag_1.node:setVisible(false)
		self.node_t_list.img_flag_2.node:setVisible(false)
	end	

	for k,v in pairs(self.wing_star_effs) do
		local star = self.wing_stars[k]
		local vis = self.wing_star_effs[k]:isVisible()
		local new_vis = ( vo.isShowStar >= k and star:isVisible() )
		if vis and not new_vis then
			GlobalTimerQuest:AddDelayTimer(function() 
				if ViewManager.Instance:IsOpen(ViewDef.Wing) then 
					v:setVisible(new_vis)
					self:ShowFallStarEff(k, v) 
				end
				end, (10 - k) / 10)
		else
			v:setVisible(new_vis)
		end
	end
end 

--更新等级相关
function WingView:ChangeLevelAbout(data)
	local wing_level = WingData.Instance:GetWingLevel()
	if wing_level >= 8 then
		self.node_t_list.lbl_wing_prog.node:setVisible(false)
	end
	RichTextUtil.ParseRichText(self.node_t_list.rich_wing_updatetip.node, WingData.Instance:GetWingUpdateTip())
	self.activate_img:setVisible(wing_level <= 0)

	if data.isActive and self.ClickToActive then
		self:SetShowPlayEff(14, 620, 320)

		self.door:OpenTheDoor()
	end
	if data.isUp then 
		self:SetAutoUpWing(false)
		if wing_level < 8 then
			self:SetShowPlayEff(17, 620, 320)
		elseif wing_level % 10 == 8 then
			self:SetShowPlayEff(17, 620, 320)
		end
	end

	--星星显示
	for k, v in pairs(self.wing_stars) do
		local star = self.wing_stars[k]
		star:setVisible(WingData.Instance:GetWingLevel() >= 8)
	end

	--刷新属性
	self:UpdateAttr(data.attr_data)
	--获取精羽
	local stuff_cfg = ItemData.Instance:GetItemConfig(SwingLevelConfig.featherItemId)
	-- self.txt_get_feather:setString(Language.Wing.Obtain .. stuff_cfg.name)
	--阶数显示
	self.node_t_list.layout_upgrade_jie.node:setVisible(wing_level > 0)
	--翅膀显示
	if data.appearanceID ~= nil then
		self.node_t_list.rich_jingyunum.node:setVisible(true)
		self.fight_power_view:SetNumber(WingData.Instance:GetWingScore())
		self.wing_display:Show(data.appearanceID)
		CommonDataManager.FlushUiGradeView(self.node_tree.layout_wing.layout_upgrade_jie.img_jie1.node, self.node_tree.layout_wing.layout_upgrade_jie.img_jie2.node, data.level_jie)
		-- self:ChangeWingSkillCells(data.level_jie)
		--翅膀名字更新
		if nil ~= data.wing_item_cfg then
			-- self.node_t_list.lbl_wing_name.node:setString(data.wing_item_cfg)
			-- self.node_t_list.lbl_wing_name.node:setColor(COLOR3B.OLIVE)
		end
	else
		self.fight_power_view:SetNumber(0)
		for k,v in pairs(self.wing_star_effs) do
			local vis = self.wing_star_effs[k]:isVisible()
			if vis then
				GlobalTimerQuest:AddDelayTimer(function() 
					v:setVisible(false)
					self:ShowFallStarEff(k, v) 
				end, (10 - k) / 10)
			else
				v:setVisible(false)
			end
		end
		RichTextUtil.ParseRichText(self.node_t_list.rich_jingyunum.node, "")
		self.wing_progressbar:SetPercent(100, false)
		self.node_t_list.lbl_wing_prog.node:setString("--/--")
	end

end

--更新羽毛相关
function WingView:ChangeFeatherAbout(vo)
	if vo.need_count > 0 then 
		local color = vo.has_count < vo.need_count and "FF0000" or "00FF00"

		local txt = ""
		if self.layout_wing_auto_hook.img_hook.node:isVisible() then
			local num = vo.need_count-vo.has_count
			if vo.has_count >= vo.need_count then
				num = 0
			end
			txt = string.format(Language.Wing.ConsumeZs, num*20)
		else
			txt = string.format(Language.Wing.WingUpConsume, color, vo.has_count, vo.need_count)
		end
		RichTextUtil.ParseRichText(self.node_t_list.rich_jingyunum.node, txt, 18)
		local vis = self.layout_wing_auto_hook.img_hook.node:isVisible()
		if vis == true then
			if vo.has_count < vo.need_count and RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD) < vo.need_count*100 then 
				self:SetAutoUpWing(false)
			end
		end
		if vis == false then
			if vo.has_count < vo.need_count then
				self:SetAutoUpWing(false)
			end
		end

		if vis == true then 
			if vo.has_count >= vo.need_count or RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD) >= vo.need_count*100 then
				self.node_t_list.img_flag_1.node:setVisible(true)
				self.node_t_list.img_flag_2.node:setVisible(true)
				self.up_need_yb = vo.need_count
			else
				self.node_t_list.img_flag_1.node:setVisible(false)
				self.node_t_list.img_flag_2.node:setVisible(false)
			end
		else
			if vo.has_count >= vo.need_count then
				self.node_t_list.img_flag_1.node:setVisible(true)
				self.node_t_list.img_flag_2.node:setVisible(true)
			else
				self.node_t_list.img_flag_1.node:setVisible(false)
				self.node_t_list.img_flag_2.node:setVisible(false)
			end
		end
	end

end

--刷新属性
function  WingView:UpdateAttr(vo)
	self.fight_power_view:SetNumber(WingData.Instance:GetWingScore())
	if vo.cur_attr_data then
		-- 提升属性显示
		if self.up_data ~= nil then
			for k, v in pairs(self.up_data) do
				for k_2, v_2 in pairs(vo.cur_attr_data) do
					if v.type == v_2.type then
						v_2.up_str = v.value_str
					end
				end
			end
		end
		self.wing_attr_list:SetDataList(vo.cur_attr_data)
	end

	if vo.next_attr_data  then
		-- 提升属性显示
		if self.up_data ~= nil then
			for k, v in pairs(self.up_data) do
				for k_2, v_2 in pairs(vo.next_attr_data) do
					if v.type == v_2.type then
						v_2.up_str = v.value_str
					end
				end
			end
		end
	end
end

function WingView:OnFlushWingView(param_t)
	local data = WingData.Instance:GetWingEquipData()
	
	self.wing_equip_list:SetDataList(data)

	local equ_data = WingData.Instance:GetNewEquipData()
	
	for k, v in pairs(equ_data) do
		self.wing_equ_cells[k]:SetData(v.cfg)
		if v.cfg == nil then
			local data = BagData.Instance:GetWingEquipData(k)
			
			self.wing_equ_cells[k]:SetRemind(data.item_id ~= nil, nil, 50, 50)
		else
			self.wing_equ_cells[k]:SetRemind(false)
		end
	end
end

--是否自动升级
function WingView:SetAutoUpWing(is_auto)
	self.auto_up_wing = is_auto
end
--升级按钮回调
function WingView:OnClickUpWingHandler(flag)
	
	local vis_flag = self.node_t_list.img_flag_1.node:isVisible()
	local vis = self.layout_wing_auto_hook.img_hook.node:isVisible()
	local tip_flag = 0
	if vis == true then
		if vis_flag == true then
			if flag == 1 then	
				WingCtrl.SendWingUpGradeReq(1,1)
			else					
				WingCtrl.SendWingUpGradeReq(0,1)	
			end
		else
			self:OnClickGetFeather()
			tip_flag = 1
		end
	else
		if vis_flag == true then
			if flag == 1 then
				WingCtrl.SendWingUpGradeReq(1,0)
			else					
				WingCtrl.SendWingUpGradeReq(0,0)
			end
		else
			self:OnClickGetFeather()
			tip_flag = 2
		end
	end
	if tip_flag ~= 0 then
		local wing_cfg, grade, wind_id= WingData.Instance:GetWingcfgAndGard()
		if wing_cfg then
			local vo = WingData.Instance:ChangeAboutFeatherData()
			local stuff_cfg = ItemData.Instance:GetItemConfig(SwingLevelConfig.featherItemId)
			if tip_flag == 2 then
				SysMsgCtrl.Instance:FloatingTopRightText(string.format(Language.Wing.ConsumeNotEnough, stuff_cfg.name))
			else
				SysMsgCtrl.Instance:FloatingTopRightText(string.format(Language.Wing.ConsumeNotEnough, self.tip_message))
			end
		end	
	end
end	

function WingView:OnClickWingActivateHandler()
	self.ClickToActive = true
	WingCtrl.SendWingUpGradeReq(0,0)
end	

--切换翅膀视图
function WingView:OnClickTurnWingViewBtn(flag)
	local wing_level = WingData.Instance:GetWingLevel()
	local wing_cfg = WingData.Instance:GetWingConfig()
	local cur_level_jie = WingData.Instance:GetWingJie()
	local show_cfg = WingData.Instance:GetWingShowArray()
	local show_name_cfg = WingData.Instance:GetWingNameArray()

	if wing_level == 0 then
		return
	end

	if self.level_jie == nil then
		self.level_jie =  cur_level_jie
	end 
	
	if flag == 1 then
		self.level_jie = self.level_jie - 1
		if(self.level_jie < 1) then self.level_jie = 1 end
	elseif self.level_jie < WingData.Instance:GetWingJie(#WingData.Instance:GetWingConfig()) then
		self.level_jie = self.level_jie + 1
		if self.level_jie > cur_level_jie + 1 then self.level_jie = cur_level_jie + 1 end
	end

	if wing_cfg then
		self.wing_display:Show(show_cfg[self.level_jie])
		CommonDataManager.FlushUiGradeView(self.node_tree.layout_wing.layout_upgrade_jie.img_jie1.node, self.node_tree.layout_wing.layout_upgrade_jie.img_jie2.node, self.level_jie)
		--翅膀名字更新
		-- self.node_t_list.lbl_wing_name.node:setString(show_name_cfg[self.level_jie])
		-- self.node_t_list.lbl_wing_name.node:setColor(COLOR3B.OLIVE)
	end
end

function WingView:ChangeShenyuHookImgShow()
	-- local flag = WingData.Instance:GetShenYuRemindFlag()
	self.node_t_list.img_shenyu.node:setVisible(false)
end

function WingView:OnClickWingTipHandler()
	DescTip.Instance:SetContent(Language.Wing.WingDetail, Language.Wing.WingTitle)
end	

function WingView:OnClickWingAutoHook()
	local vis = self.layout_wing_auto_hook.img_hook.node:isVisible()
	self.layout_wing_auto_hook.img_hook.node:setVisible(not vis)
	WingData.Instance:ChangeAboutFeatherData()
end

-- 播放特效
function WingView:SetShowPlayEff(eff_id, x, y)
	if self.play_eff == nil then
		self.play_eff = AnimateSprite:create()
		self.root_node:addChild(self.play_eff, 999)
	end
	self.play_eff:setPosition(x, y)
	local anim_path, anim_name = ResPath.GetEffectUiAnimPath(eff_id)
	self.play_eff:setAnimate(anim_path, anim_name, 1, FrameTime.Effect, false)
end

-- 播放特效
function WingView:ShowFallStarEff(index, star_eff)
	if self.fall_star_eff_t[index] == nil then
		self.fall_star_eff_t[index] = AnimateSprite:create()
		self.node_t_list.layout_upgrade.node:addChild(self.fall_star_eff_t[index], 9999)
		local x, y = star_eff:getPosition()
		self.fall_star_eff_t[index]:setPosition(x, y)
	end
	local anim_path, anim_name = ResPath.GetEffectUiAnimPath(910)
	self.fall_star_eff_t[index]:setAnimate(anim_path, anim_name, 1, FrameTime.Effect, false)
end

function WingView:OnClickEquipCallBack(cell)
	if cell:GetData() ~= nil then return end
	local index = cell:GetIndex()

	local data = BagData.Instance:GetWingEquipData(index)
	if data.item_id == nil then
		ViewManager.Instance:OpenViewByDef(ViewDef.MainGodEquipView.ReXueFuzhuang.WingShenZhuang)
	else
		WingCtrl.SendEquipmentShenyu(data.series)
	end

end

function WingView:SepcialGradeRemind()
	self:SetAutoUpWing(false)
	self.up_data = nil

	self.ten_grade_alert = self.ten_grade_alert or Alert.New(nil, nil, nil, nil, nil, nil, false)
	self.ten_grade_alert:SetLableString(Language.Wing.TenGradeAlert)
	self.ten_grade_alert:SetOkString(Language.Common.Confirm)
	self.ten_grade_alert:SetCancelString(Language.Common.Cancel)
	self.ten_grade_alert:SetShowCheckBox(false)
	self.ten_grade_alert:Open()
end

function WingView:OnClickAutoUpWingHandler()
	self:SetAutoUpWing(not self.auto_up_wing)
	
	if self.auto_up_wing == true then
		self:OnClickUpWingHandler(1)		
	end

end	

function WingView:OnClickGetFeather()
	TipCtrl.Instance:OpenGetStuffTip(SwingLevelConfig.featherItemId)
end

function WingView:OnGetUiNode(node_name)
	if NodeName.WingActBtn == node_name then
		return self.door:GetActBtnNode(), true
	end

	return WingView.super.OnGetUiNode(self, node_name)
end

----------------------------------------------------------------------------------------------------
-- 羽翼属性item
----------------------------------------------------------------------------------------------------
WingView.WingCurAttrItem = BaseClass(BaseRender)
local WingCurAttrItem = WingView.WingCurAttrItem
function WingCurAttrItem:__init()
end

function WingCurAttrItem:CreateChild()
	BaseRender.CreateChild(self)
	
	XUI.RichTextSetCenter(self.node_tree.rich_attr_value.node)
	
	-- self.node_tree.lbl_attr_name.node:setColor(cc.c3b(140, 138, 125))
	-- self.node_tree.rich_attr_value.node:setColor(cc.c3b(140, 138, 125))
end

function WingCurAttrItem:OnFlush()
	if self.data == nil then return end
	self.node_tree.lbl_attr_name.node:setString(self.data.type_str .. "：")
	local value_str = self.data.value_str
	RichTextUtil.ParseRichText(self.node_tree.rich_attr_value.node, value_str)
end

function WingCurAttrItem:CreateSelectEffect()
end

-------------------------------------
-- WingEquipRender 【影翼装备】
-------------------------------------
WingEquipRender = WingEquipRender or BaseClass(BaseRender)
function WingEquipRender:__init()
	self:AddClickEventListener()
end

function WingEquipRender:__delete()	
	if nil ~= self.cell then
		self.cell:DeleteMe()
		self.cell = nil
	end
end

function WingEquipRender:CreateChild()
	BaseRender.CreateChild(self)
	local ph = self.ph_list.ph_equ_cell
	
	if nil == self.cell then
		self.cell = BaseCell.New()
		self.cell:SetPosition(ph.x, ph.y)
		self.cell:SetIndex(i)
		self.cell:SetAnchorPoint(0.5, 0.5)
		self.cell:SetSpecilImgVisible(false)
		self.cell:SetCellSpecialBg(ResPath.GetCommon("cell_101"))
		self.cell:SetBgTa(ResPath.GetWingResPath("wing_equip_" .. self.index))
		self.view:addChild(self.cell:GetView(), 103)
		
		self.cell:SetItemTipFrom(EquipTip.FROM_WING_EQUIP_SHOW)
		-- self.cell:SetName(GRID_TYPE_BAG)
	end	
end

function WingEquipRender:OnFlush()
	if not self.data then return end

	self.cell:SetSpecilImgVisible(self.data.is_hh == self.index-1, ResPath.GetCommon("stamp_hhicon"), 18, 50)
	local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	local is_circle = item_cfg and circle >= item_cfg.conds[1].value
	local is_remid = WingData.Instance:IsHaveWingEquipOnBag(self.data.item_id) == 1 and self.data.cfg == nil and is_circle
	self.cell:SetRemind(is_remid, nil, 50, 50)

	self.cell:SetData(self.data.cfg)
end