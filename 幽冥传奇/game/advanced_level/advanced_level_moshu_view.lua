AdvancedLevelMoShuView = AdvancedLevelMoShuView or BaseClass(SubView)

function AdvancedLevelMoShuView:__init()
	-- self.title_img_path = ResPath.GetWord("title_jinjie")
	self:SetModal(true)
	self.texture_path_list = {
		'res/xui/role.png',
		'res/xui/advanced_level.png',
		 'res/xui/horoscope.png',
		'res/xui/bag.png',
	}
	self.config_tab = {
		{"advance_ui_cfg", 1, {0}},
		--{"common_ui_cfg", 2, {0}, nil, 999},
		--{"common_ui_cfg", 3, {0}},
	}

	-- self.btn_info = {ViewDef.Advanced.Moshu,ViewDef.Advanced.YuanSu, ViewDef.Advanced.ShengShou, ViewDef.Role.ZhuanSheng,}


end

function AdvancedLevelMoShuView:__delete()
	-- body
end

function AdvancedLevelMoShuView:LoadCallBack()
	self:CreateAttrList()
	self:CreateEffectList()
	self:CreateGridList()
	local ph = self.ph_list["ph_link1"]
	self.rich_go_text = RichTextUtil.CreateLinkText(Language.Advanced.LinkDesc[1], 19, COLOR3B.GREEN)
	self.rich_go_text:setPosition(ph.x, ph.y + 5)
	self.node_t_list.layout_attr.node:addChild(self.rich_go_text, 90)
	XUI.AddClickEventListener(self.rich_go_text, BindTool.Bind(self.OnTextBtn, self, 1), true)

	local ph_duihuan = self.ph_list["ph_link2"]
	local text = RichTextUtil.CreateLinkText(Language.Advanced.LinkDesc[2], 19, COLOR3B.GREEN)
	text:setPosition(ph_duihuan.x, ph_duihuan.y + 5)
	self.node_t_list.layout_attr.node:addChild(text, 90)
	XUI.AddClickEventListener(text, BindTool.Bind(self.OnTextBtn, self, 2), true)
	

	self.node_t_list.text_name_1.node:setString(Language.Advanced.LuJingDesc[1])
	self.node_t_list.text_name_2.node:setString(Language.Advanced.LuJingDesc[2])
	XUI.AddClickEventListener(self.node_t_list.btn_tip.node, BindTool.Bind(self.OpenDescTip, self), true)

	self.bool = false

	EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.RoleDataChangeCallback, self))

	self.moshu_change = GlobalEventSystem:Bind(JINJIE_EVENT.NOSHU_CHANGE, BindTool.Bind1(self.OnMoShuChange,self))

	XUI.AddClickEventListener(self.node_t_list.btn_up.node, BindTool.Bind(self.OpenUpView, self), true)
end

function AdvancedLevelMoShuView:OpenUpView()
	if self.auto_upgrade_event then
		GlobalTimerQuest:CancelQuest(self.auto_upgrade_event)
		self.auto_upgrade_event = nil
		self.node_t_list.btn_up.node:setTitleText("自动提升")
	end	
	
	local cfg = AdvancedLevelData.GetInnerCfg(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_INNER_LEVEL) + 1)
	local need_consume = cfg and cfg.consume[1].count  or 0
	local had_num = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_STONE)
	if had_num < need_consume then
		TipCtrl.Instance:OpenGetNewStuffTip(2833)
		return
	end
	self.bool = not self.bool 
	if self.bool then
		self:CheckAuto()
	end
	--
end

function AdvancedLevelMoShuView:CheckAuto()
	
	local cfg = AdvancedLevelData.GetInnerCfg(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_INNER_LEVEL) + 1)
	local need_consume = cfg and cfg.consume[1].count  or 0
	local had_num = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_STONE)
	if cfg == nil then
	 	if self.auto_upgrade_event then
			GlobalTimerQuest:CancelQuest(self.auto_upgrade_event)
			self.auto_upgrade_event = nil
			self.node_t_list.btn_up.node:setTitleText("自动提升")
			return
		end	
	end

	if self.auto_upgrade_event then
		GlobalTimerQuest:CancelQuest(self.auto_upgrade_event)
		self.auto_upgrade_event = nil
		self.node_t_list.btn_up.node:setTitleText("自动提升")
	end
	
	self.auto_upgrade_event = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.CheckAuto,self), 0.25)
	self.node_t_list.btn_up.node:setTitleText("停止提升")

	if had_num >= need_consume then
		AdvancedLevelCtrl.SendInnerUpReq()
	else
		GlobalTimerQuest:CancelQuest(self.auto_upgrade_event)
		self.auto_upgrade_event = nil
		self.node_t_list.btn_up.node:setTitleText("自动提升")
		TipCtrl.Instance:OpenGetNewStuffTip(2833)
	end
end



function AdvancedLevelMoShuView:OnMoShuChange()
	self:SetEquipData()
end

function AdvancedLevelMoShuView:CreateEffectList()
	self.effect_list = {}
	for i = 1, 10 do
		local ph = self.ph_list["ph_effect_"..i]
		local play_eff = AnimateSprite:create()
		play_eff:setPosition(ph.x + 7, ph.y + 40)
		self.node_t_list.layout_moshu.node:addChild(play_eff, 999)

		local anim_path, anim_name = ResPath.GetEffectUiAnimPath(1196)
		play_eff:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
		self.effect_list[i] = play_eff
	end

	if self.main_effect  == nil then
		self.main_effect = AnimateSprite:create()
		local ph = self.ph_list.ph_main_effect 
		self.main_effect:setPosition(ph.x, ph.y)
		self.node_t_list.layout_moshu.node:addChild(self.main_effect, 999)

		local anim_path, anim_name = ResPath.GetEffectUiAnimPath(1195)
		self.main_effect:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
	end
end


function AdvancedLevelMoShuView:RoleDataChangeCallback(vo)
	if vo.key == OBJ_ATTR.ACTOR_INNER_LEVEL then
		self:FlushInnerStep()
		self:SetEquipData()
	elseif vo.key == OBJ_ATTR.ACTOR_INNER_EXP then
		--self:FlushInnerStep()
		self:FlushLevelShow()
	elseif vo.key == OBJ_ATTR.ACTOR_STONE then
		self:FlushConsumeShow()
	end
end

function AdvancedLevelMoShuView:OpenDescTip()
	DescTip.Instance:SetContent(Language.DescTip.MoShuContent, Language.DescTip.MoShuTitle)
end


function AdvancedLevelMoShuView:OnTextBtn(index)
	if index == 1 then
		MoveCache.end_type = MoveEndType.Normal
		GuajiCtrl.Instance:FlyByIndex(4)
		ViewManager.Instance:CloseViewByDef(ViewDef.Advanced)
	elseif index == 2 then
		ViewManager.Instance:OpenViewByDef(ViewDef.Shop)
	end
end

function AdvancedLevelMoShuView:OpenCallBack()
	
end

function AdvancedLevelMoShuView:SetEquipData()
	local consume = InnerConfig.ConsumeId
	local data = {}
	for k,v in pairs(consume) do
		local cur_data = {}
		cur_data.index = k
		cur_data.item_id = v
		table.insert(data, cur_data)
	end
	--PrintTable(data)
	self.list_equip:SetDataList(data)
end

function AdvancedLevelMoShuView:ShowIndexCallBack( ... )
	self:Flush(index)
end

function AdvancedLevelMoShuView:ReleaseCallBack()
	if self.cur_attr_list then
		self.cur_attr_list:DeleteMe()
		self.cur_attr_list = nil
	end
	if self.effect_list  then
		for k, v in pairs(self.effect_list) do
			v:setStop()
		end
		self.effect_list = {}
	end

	if self.main_effect then
		self.main_effect:setStop()
		self.main_effect = nil 
	end
	if self.list_equip then
		self.list_equip:DeleteMe()
		self.list_equip = nil 
	end

	if self.moshu_change then
		GlobalEventSystem:UnBind(self.moshu_change)
		self.moshu_change = nil 
	end

	if self.auto_upgrade_event then
		GlobalTimerQuest:CancelQuest(self.auto_upgrade_event)
		self.auto_upgrade_event = nil
	end	
end

function AdvancedLevelMoShuView:CloseCallBack()
	if self.auto_upgrade_event then
		GlobalTimerQuest:CancelQuest(self.auto_upgrade_event)
		self.auto_upgrade_event = nil
		self.node_t_list.btn_up.node:setTitleText("自动提升")
	end	
	self.bool = false
end

function AdvancedLevelMoShuView:OnFlush()
	self:FlushInnerStep()
	self:FlushLevelShow()
	self:FlushConsumeShow()
	self:SetEquipData()
end

function AdvancedLevelMoShuView:FlushInnerStep()
	local inner_level = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_INNER_LEVEL)

	local inner_cur_attr = AdvancedLevelData.Instance:GetInnerAttr()

	local inner_next_attr = AdvancedLevelData.Instance:GetInnerNextAttr()
	
	local inner_cur_attr_list =  RoleData.FormatRoleAttrStr(inner_cur_attr)

	local inner_next_attr_list =  RoleData.FormatRoleAttrStr(inner_next_attr)

	--PrintTable(inner_next_attr_list)
	local list = inner_cur_attr_list
	if #list == 0 then
		for k, v in ipairs(inner_next_attr_list) do
			local data = {
				type_str = v.type_str,
				value_str = 0,
				next_value_str = v.value_str,
			}
			table.insert(list, data)
		end
	else
		for k, v in ipairs(list) do
			v.next_value_str = inner_next_attr_list[k] and inner_next_attr_list[k].value_str or ""
		end
	end
	self.cur_attr_list:SetDataList(list)

	--图标显示
	local step, level = AdvancedLevelData.Instance:CanGetStepByLevel(inner_level) 
	self.node_t_list.layout_step1.node:setVisible(step <= 10)
	self.node_t_list.layout_step2.node:setVisible(step >= 11 and step <= 20 or step == 30)
	self.node_t_list.layout_step3.node:setVisible(step >= 21 and step <= 29)

	if step <= 10 then
		if inner_level ~= 0 then
			step = (inner_level ~= 0 and step == 10) and 0 or step
		else
			step = (inner_level ~= 0 and step == 10) and 0 or step
		end
		self.node_t_list.step_1.node:loadTexture(ResPath.GetCommon("daxie_"..step))
	elseif step >= 11 and (step <= 20 or step%10 == 0) then
		local cur_show_1 = math.floor(step/10) 
		local cur_show_2 = step % 10 == 10 and 0 or  step % 10 
		if cur_show_1 == 1 then -- 11~19阶显示
			cur_show_1 = 0
		end
		self.node_t_list.step_11.node:loadTexture(ResPath.GetCommon("daxie_"..cur_show_1))
		self.node_t_list.step_12.node:loadTexture(ResPath.GetCommon("daxie_"..cur_show_2))
	elseif (step >= 21 and step%10 ~= 0) then
		local cur_show_1 = math.floor(step/10) 
		local cur_show_2 = step % 10 == 10 and 0 or  step % 10
		self.node_t_list.step_21.node:loadTexture(ResPath.GetCommon("daxie_"..cur_show_1))
		self.node_t_list.step_22.node:loadTexture(ResPath.GetCommon("daxie_"..cur_show_2))
	end

	if inner_level ~= 0 and level == 0 then
		level = 10
	end

	for k, v in pairs(self.effect_list) do
		local bool = true
		if level >= k then
			bool = false
		end
		XUI.MakeGrey(v, bool)
	end
end


function AdvancedLevelMoShuView:FlushLevelShow()
	local cfg = AdvancedLevelData.GetInnerCfg(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_INNER_LEVEL) + 1)
	local need_consume = cfg and cfg.consumeBlessings or 0
	local present = 0
	local text = ""
	if need_consume <= 0 then
		percent = 100
		text = ""
	else
		percent = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_INNER_EXP) / need_consume * 100
		text = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_INNER_EXP) .. "/"..need_consume
	end
	self.node_t_list.lbl_shu_prog.node:setString(text)

	self.node_t_list.prog9_progress.node:setPercent(percent)
end

function AdvancedLevelMoShuView:FlushConsumeShow()
	local cfg = AdvancedLevelData.GetInnerCfg(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_INNER_LEVEL) + 1)
	local need_consume = cfg and cfg.consume[1].count  or 0
	local had_num = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_STONE)
	local color = had_num >= need_consume and COLOR3B.GREEN or COLOR3B.RED
	self.node_t_list.lbl_had_num.node:setString(had_num .."/".. need_consume)
	self.node_t_list.lbl_had_num.node:setColor(color)
end



function AdvancedLevelMoShuView:CreateAttrList()
	if nil == self.cur_attr_list then
		local ph = self.ph_list.ph_base_attr--获取区间列表
		self.cur_attr_list = ListView.New()
		self.cur_attr_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Vertical, ShuLingAttrItem, nil, nil, self.ph_list.ph_item)
		self.cur_attr_list:SetItemsInterval(5)--格子间距
		self.cur_attr_list:SetJumpDirection(ListView.Top)--置顶
		self.node_t_list.layout_attr.node:addChild(self.cur_attr_list:GetView(), 20)

		self.cur_attr_list:GetView():setAnchorPoint(0, 0)
	end
end

function AdvancedLevelMoShuView:CreateGridList()
	if nil == self.list_equip then
		local ph = self.ph_list.ph_grid_list--获取区间列表
		self.list_equip = ListView.New()
		self.list_equip:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, ShuLingEquipItem, nil, nil, self.ph_list.ph_item_dan)
		self.list_equip:SetItemsInterval(30)--格子间距
		self.list_equip:SetJumpDirection(ListView.Top)--置顶
		self.node_t_list.layout_attr.node:addChild(self.list_equip:GetView(), 20)
		self.list_equip:SetSelectCallBack(BindTool.Bind(self.SelectEquipListCallback, self))
		self.list_equip:GetView():setAnchorPoint(0, 0)
	end
end


function AdvancedLevelMoShuView:SelectEquipListCallback(item)
	if item == nil or item:GetData() == nil then
		return
	end
	local data = item:GetData()
	if RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_INNER_LEVEL) < InnerConfig.openAptitude then
		local step = AdvancedLevelData.Instance:CanGetStepByLevel(InnerConfig.openAptitude)
		SysMsgCtrl.Instance:FloatingTopRightText(string.format(Language.Advanced.ViewDesc, step))
	else
		AdvancedLevelCtrl.Instance:OpenView(data)
	end
end

ShuLingAttrItem = ShuLingAttrItem or BaseClass(BaseRender)
function ShuLingAttrItem:__init()
	-- body
end

function ShuLingAttrItem:__delete()
	-- body
end

function ShuLingAttrItem:CreateChild()
	BaseRender.CreateChild(self)
end


function ShuLingAttrItem:OnFlush()
	if self.data == nil then
		return
	end
	self.node_tree.lbl_attr_name.node:setString(self.data.type_str .. ":")
	self.node_tree.cur_attr.node:setString(self.data.value_str)

	local text = self.data.next_value_str ~= "" and string.format("{image;%s} %s", ResPath.GetCommon("img_up"), self.data.next_value_str) or ""
	RichTextUtil.ParseRichText(self.node_tree.next_attr.node, text, 18,  COLOR3B.GREEN)
end

ShuLingEquipItem = ShuLingEquipItem or BaseClass(BaseRender)
function ShuLingEquipItem:__init()
	-- body
end

function ShuLingEquipItem:__delete()
	if self.had_number then
		self.had_number:DeleteMe()
		self.had_number = nil 
	end
end

function ShuLingEquipItem:CreateChild()
	BaseRender.CreateChild(self)

	if nil == self.had_number then
		local ph = self.ph_list.ph_number
		self.had_number = NumberBar.New()
	    self.had_number:Create(ph.x, ph.y, 0, 0, ResPath.GetCommon("num_133_"))
	    self.had_number:SetGravity(NumberBarGravity.Center)
	    self.had_number:SetSpace(-8)
	    self.view:addChild(self.had_number:GetView(), 101)
	end
	self.node_tree.remind_img_1.node:setVisible(false)
end


function ShuLingEquipItem:OnFlush()
	if self.data == nil then
		return
	end
	local config = ItemData.Instance:GetItemConfig(self.data.item_id)
	local icon = config.icon 
	self.node_tree.ph_path_1.node:loadTexture(ResPath.GetItem(icon))

	local num = BagData.Instance:GetItemNumInBagById(self.data.item_id)

	local inner_level = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_INNER_LEVEL)
	local cur_cfg = AdvancedLevelData.GetInnerCfg(inner_level)
	local use_num = AdvancedLevelData.Instance:GetHadNumByIndex(self.data.index - 1) or 0
	local  vis = false

	--达到开放等级且该等级上限未用完，并且背包数量未用完
	if (num >= 1) and RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_INNER_LEVEL) >= InnerConfig.openAptitude and ((cur_cfg and cur_cfg.InjectionLimit or 0) > use_num)then
		vis = true
	end

	self.node_tree.remind_img_1.node:setVisible(vis)

	local path = ResPath.GetJinJiePath("shayudan")
	if self.data.index == 2 then
		path = ResPath.GetJinJiePath("xueyadan")
	elseif self.data.index == 3 then
		path = ResPath.GetJinJiePath("zhihuangdan")
	end
	self.node_tree.img_name1.node:loadTexture(path)
	
	if use_num > 0 then
		self.had_number:SetNumber(use_num) 
		self.had_number:SetScale(0.8)
	end
end

function ShuLingEquipItem:CreateSelectEffect()

end


return AdvancedLevelMoShuView