
local RoleInfoList = BaseClass(SubView)

function RoleInfoList:__init()
	self.texture_path_list = {
		'res/xui/role_btn.png',
	}
	self.config_tab = {
		{"role1_ui_cfg", 1, {0}, nil, 999},
		{"role1_ui_cfg", 2, {0}},
		{"role1_ui_cfg", 4, {0}, false},
	}

	require("scripts/game/role/view/role_info_list/role_intro").New(ViewDef.Role.RoleInfoList.Intro)
	require("scripts/game/role/view/role_info_list/role_god_equip").New(ViewDef.Role.RoleInfoList.GodEquip)
	require("scripts/game/role/view/role_info_list/new_rexue_god_view").New(ViewDef.Role.RoleInfoList.NewReXueEquip)
	require("scripts/game/fuwen/view/fuwen_view").New(ViewDef.Role.RoleInfoList.BiSha)
	require("scripts/game/role/luxury_equip/luxury_equip_view").New(ViewDef.Role.RoleInfoList.LuxuryEquip)

	self.btn_list = {}
	self.btn_info = {}
end

function RoleInfoList:__delete()
end

function RoleInfoList:ReleaseCallBack()
	self.btn_list = {}
	self.btn_info = {}
	if self.zhu_attr_list then
		self.zhu_attr_list:DeleteMe()
		self.zhu_attr_list = nil
	end
	if self.fu_attr_list then
		self.fu_attr_list:DeleteMe()
		self.fu_attr_list = nil
	end
	if self.fight_power_view then
		self.fight_power_view:DeleteMe()
		self.fight_power_view = nil
	end
end


function RoleInfoList:LoadCallBack(index, loaded_times)
	self.btn_info = {
		--{
		--	res_id = 1,
		--	view = ViewDef.Role.RoleInfoList.GodEquip,
		--},
		--{
		--	res_id = 2,
		--	view = ViewDef.Role.RoleInfoList.BiSha,
		--},
		--{
		--	res_id = 3,
		--	view = ViewDef.Role.RoleInfoList.ChuanShi,
		--},
		--{
		--	res_id = 4,
		--	view = ViewDef.Role.RoleInfoList.Fashion,
		--},
		--{
		--	res_id = 5,
		--	view = ViewDef.Role.RoleInfoList.ReXue,
		--},
		-- {
		-- 	btn = self.node_t_list.luxury_equip_btn.node,
		-- 	view = ViewDef.Role.RoleInfoList.LuxuryEquip,
		-- 	can_view = ViewDef.Role.RoleInfoList.LuxuryEquip,
		-- 	red_point = self.node_t_list.img_rexue_red.node,
		-- },
		{
			btn = self.node_t_list.chuanshi_btn.node,
			view = ViewDef.Role.RoleInfoList.NewReXueEquip,
			--can_view = ViewDef.MainGodEquipView
			open_cond = "CondId22",
		},
	}

	XUI.AddClickEventListener(self.node_t_list.btn_be_help.node, BindTool.Bind(self.OnClickHelp, self), true)

	for k, v in pairs(self.btn_info) do
		self:CreateRoleInfoList(k, v)
	end

    self:BindGlobalEvent(OtherEventType.GAME_COND_CHANGE, BindTool.Bind(self.OnGameCondChange, self))
	self:BindGlobalEvent(OtherEventType.REMINDGROUP_CAHANGE, BindTool.Bind(self.OnRemindGroupChange, self))



	local size = self.node_t_list.img_title_1.node:getContentSize()
	--self.node_t_list.img_title_1.node:addChild(XUI.CreateTextByType(size.width / 2, size.height / 2, 200, 20, "基础属性", 1))

	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	local attack_attr
	if prof == GameEnum.ROLE_PROF_1 then
		attack_attr = {OBJ_ATTR.CREATURE_PHYSICAL_ATTACK_MIN, OBJ_ATTR.CREATURE_PHYSICAL_ATTACK_MAX}
	elseif prof == GameEnum.ROLE_PROF_2 then
		attack_attr = {OBJ_ATTR.CREATURE_MAGIC_ATTACK_MIN, OBJ_ATTR.CREATURE_MAGIC_ATTACK_MAX}
	else
		attack_attr = {OBJ_ATTR.CREATURE_WIZARD_ATTACK_MIN, OBJ_ATTR.CREATURE_WIZARD_ATTACK_MAX}
	end
	self.zhu_attr = {
		{OBJ_ATTR.CREATURE_HP, OBJ_ATTR.CREATURE_MAX_HP},    --生命值
		{OBJ_ATTR.CREATURE_MP, OBJ_ATTR.CREATURE_MAX_MP},    --魔法值
		{OBJ_ATTR.ACTOR_INNER, OBJ_ATTR.ACTOR_MAX_INNER},	-- 内功吉护盾
		attack_attr,
		{OBJ_ATTR.CREATURE_PHYSICAL_DEFENCE_MIN, OBJ_ATTR.CREATURE_PHYSICAL_DEFENCE_MAX},  --物理攻击
		OBJ_ATTR.ACTOR_PK_VALUE,  --PK值
	}
	self.fu_attr = {
		OBJ_ATTR.CREATURE_HIT_RATE,						--准确
		OBJ_ATTR.CREATURE_DOGE_RATE,					--敏捷
		OBJ_ATTR.ACTOR_1077,							--内功攻击 整数
		OBJ_ATTR.ACTOR_INNER_REDUCE_DAMAGE_ADD,  		--内力减伤
		OBJ_ATTR.ACTOR_CRITRATE,						--暴击率 35
		OBJ_ATTR.ACTOR_REDUCE_BAOJI_REAT,				--韧性
		OBJ_ATTR.ACTOR_RESISTANCECRIT,					--暴击力36
		OBJ_ATTR.ACTOR_REDUCE_BAOJI,					-- 1075 暴击减伤
		OBJ_ATTR.ACTOR_1078,							--切割伤害倍率增加(浮点数)百分比, 下发时先*100转为int, 前端要除100转回float
		OBJ_ATTR.ACTOR_1079,							--切割伤害(BOSS伤害)
		OBJ_ATTR.ACTOR_1080,							--物理免伤
		OBJ_ATTR.ACTOR_1081,							--物防穿透
		OBJ_ATTR.ACTOR_MOUNT_MIN_ATTACK_RATE, 			-- 1064 神圣一击几率	
		OBJ_ATTR.ACTOR_MOUNT_MIN_ATTACK_VALUE, 			-- 1065 神圣一击伤害
		OBJ_ATTR.ACTOR_MOUNT_MIN_PHY_DEFENCE_RATE_RATE,	-- 1070 降低神圣一击几率	
		OBJ_ATTR.ACTOR_MOUNT_MIN_PHY_DEFENCE_RATE_VALUE,-- 1071 降低神圣一击伤害		
		OBJ_ATTR.ACTOR_FATAL_HIT_RATE,		 			-- 1066 致命一击几率	
		OBJ_ATTR.ACTOR_FATAL_HIT_VALUE, 				-- 1067 致命一击伤害	
		OBJ_ATTR.ACTOR_REDUCE_FATAL_HIT_RATE, 			-- 1072 降低致命一击几率	
		OBJ_ATTR.ACTOR_REFLECT_RATE, 					-- 1073 降低致命一击伤害	
		OBJ_ATTR.ACTOR_ABSORBHPRATE,					--吸血几率 155
		OBJ_ATTR.ACTOR_ABOSRBHP, 						--吸血值 156
		OBJ_ATTR.ACTOR_PK_DAMAGE, 		 				-- 1068 pk攻击
		OBJ_ATTR.ACTOR_REDUCE_PK_DAMAGE, 				-- 1069 抵消pk攻击伤害	
		OBJ_ATTR.ACTOR_DAMAGE_UP, 						--伤害加成
		OBJ_ATTR.ACTOR_BOSSCRITRATE,					--对BOSS暴击率 152
		OBJ_ATTR.ACTOR_BATTACKBOSSCRITVALUE,			--对BOSS暴击力153
		OBJ_ATTR.ACTOR_MOUNT_HP_RATE_ADD, 				-- 1074 物理穿透	
		OBJ_ATTR.ACTOR_1082,							--减少伤害加成比(万分比)
		OBJ_ATTR.ACTOR_1083,							--反击伤害（万分比）
		OBJ_ATTR.ACTOR_1084,							--技能攻击的时候 攻击伤害追加n点
	}

	self:CreateZhuAttrList()
	self:CreateFuAttrList()

	self.fight_power_view = FightPowerView.New(136, 35, self.node_t_list.layout_fighting_power.node, 99, false)
	self.fight_power_view:SetNumber(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_BATTLE_POWER))

	EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.RoleAttrChange, self))
end

function RoleInfoList:OpenCallBack()
end

function RoleInfoList:ShowIndexCallBack(index)
	--self:FlushRoleBackBtn()
	self:FlushRoleInfoList()
	self:Flush()
end

function RoleInfoList:OnFlush(param_t, index)
	if ViewManager.Instance:IsOpen(ViewDef.Role.RoleInfoList.Intro) then
		self.node_t_list["layout_btn_list"].node:setVisible(true)
		self.node_t_list["layout_attr"].node:setVisible(true)
	else
		self.node_t_list["layout_attr"].node:setVisible(false)
	end

end
---------------------------------------------------------------------------
function RoleInfoList:OnGameCondChange(cond_def)
	self:FlushRoleInfoList()
end

function RoleInfoList:OnRemindGroupChange(group_name, num)
	self:FlushRoleInfoList()
end

function RoleInfoList:OnClickBackBtn()
	if ViewManager.Instance:IsOpen(ViewDef.Role.RoleInfoList.BiSha.FuwenZhuling) then
		ViewManager.Instance:OpenViewByDef(ViewDef.Role.RoleInfoList.BiSha.SuitAttr)
	else
		ViewManager.Instance:OpenViewByDef(ViewDef.Role.RoleInfoList.Intro)
	end
end

function RoleInfoList:OnOpenView(view_def)
	ViewManager.Instance:OpenViewByDef(view_def)
end

function RoleInfoList:OnClickHelp()
	ViewManager.Instance:OpenViewByDef(ViewDef.Help)
end


function RoleInfoList:CreateRoleInfoList(index, info)

	--local ph = self.ph_list.ph_role_btn
	--local x = ph.x + (index - 1) * (ph.w + 40)
	local btn = info.btn
	--btn:addChild(XUI.CreateImageView(ph.w / 2, ph.h / 2, ResPath.GetRoleBtn("img_100")), 1, 1)
	--btn:addChild(XUI.CreateImageView(ph.w / 2, ph.h / 2, ResPath.GetRoleBtn("img_" .. info.res_id)), 2, 2)
	--btn:addChild(XUI.CreateImageView(ph.w / 2, 18, ResPath.GetRoleBtn("word_" .. info.res_id)), 3, 3)
	--btn:addChild(XUI.CreateImageView(ph.w / 2, ph.h / 2, ResPath.GetRoleBtn("img_101")), 4, 4)
	function btn:SetRemind(is_remind)
		if nil == self.remind_eff and is_remind then
			self.remind_eff = RenderUnit.CreateEffect(22, self, 99)
		elseif nil ~= self.remind_eff then
			self.remind_eff:setVisible(is_remind)
		end
	end
	self.btn_list[index] = btn
	XUI.AddClickEventListener(btn, BindTool.Bind(self.OnClickBtn, self, info), true)
end

function RoleInfoList:FlushRoleInfoList()
	for k, v in pairs(self.btn_info) do
		local vis = ViewManager.Instance:CanOpen(v.view)
		self.btn_list[k]:setVisible(vis)
	end
	-- local count = 0
	for k, v in pairs(self.btn_list) do
		if v:isVisible() then
			local remind_group_name = self.btn_info[k].view.remind_group_name
			if k == 1 then
				local is_remind = (RemindManager.Instance:GetRemindGroup(remind_group_name) > 0 or RemindManager.Instance:GetRemindGroup(ViewDef.Role.RoleInfoList.LuxuryEquip.remind_group_name) > 0) and (not IS_ON_CROSSSERVER)
				self.node_t_list.img_rexue_red.node:setVisible(is_remind)
			end
		end
	end
end

function RoleInfoList:OnClickBtn(info)
	if IS_ON_CROSSSERVER then
		SysMsgCtrl.Instance:FloatingTopRightText(Language.Common.OnCrossServerTip)
		return
	else
		if info.can_view and ViewManager.Instance:CanOpen(info.can_view) then
			ViewManager.Instance:OpenViewByDef(info.view)
		else
			if info.open_cond and GameCondMgr.Instance:GetValue(info.open_cond) then
				ViewManager.Instance:OpenViewByDef(info.view)
			end
			-- local text = GameCond[info.can_view.v_open_cond] and GameCond[info.can_view.v_open_cond].Tip or ""
			-- SysMsgCtrl.Instance:FloatingTopRightText(text)
		end
	end
end

function RoleInfoList:RoleAttrChange(vo)
	local attr_key = vo.key
	local zhu_attr_change = false
	local fu_attr_change = false
	for k2, v2 in pairs(self.zhu_attr) do
		if type(v2) == "table" then
			for k3,v3 in pairs(v2) do
				if attr_key == v3 then
					zhu_attr_change = true
				end
			end
		elseif v2 == attr_key then
			zhu_attr_change = true
		end
	end

	for k2, v2 in pairs(self.fu_attr) do
		if attr_key == v2 then
			fu_attr_change = true
		end
	end

	if zhu_attr_change then
		self.zhu_attr_list:SetDataList(self.zhu_attr)
	end
	if fu_attr_change then
		self.fu_attr_list:SetDataList(self.fu_attr)
	end

	if attr_key == OBJ_ATTR.ACTOR_BATTLE_POWER then
		self.fight_power_view:SetNumber(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_BATTLE_POWER))
	end
end

function RoleInfoList:CreateZhuAttrList()
	self.zhu_attr_list = ListView.New()
	local ph_role_zhuattr_list = self.ph_list.ph_base_attr
	self.zhu_attr_list:Create(ph_role_zhuattr_list.x, ph_role_zhuattr_list.y, ph_role_zhuattr_list.w, ph_role_zhuattr_list.h, nil, RoleAttrItem)
	self.node_t_list.layout_attr.node:addChild(self.zhu_attr_list:GetView(), 100, 100)
	self.zhu_attr_list:GetView():setAnchorPoint(0.5, 0.5)
	self.zhu_attr_list:SetItemsInterval(4)
	self.zhu_attr_list:SetDataList(self.zhu_attr)
	self.zhu_attr_list:JumpToTop(true)
end

function RoleInfoList:CreateFuAttrList()
	self.fu_attr_list = ListView.New()
	local ph_attr = self.ph_list.ph_extend_attr
	self.fu_attr_list:Create(ph_attr.x, ph_attr.y, ph_attr.w, ph_attr.h, nil, RoleAttrItem)
	self.node_t_list.layout_attr.node:addChild(self.fu_attr_list:GetView(), 100, 100)
	self.fu_attr_list:GetView():setAnchorPoint(0.5, 0.5)
	self.fu_attr_list:SetItemsInterval(12)
	self.fu_attr_list:SetDataList(self.fu_attr)
	self.fu_attr_list:JumpToTop(true)
end

return RoleInfoList
