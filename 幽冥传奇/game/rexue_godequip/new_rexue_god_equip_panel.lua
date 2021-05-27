local  NewReXueGodEquipPanel = BaseClass(SubView)

function NewReXueGodEquipPanel:__init( ... )
	--self.title_img_path = ResPath.GetWord("title_rexue")
	self.texture_path_list = {
		'res/xui/equipbg.png',
		'res/xui/rexue.png',
	}
	self.config_tab = {
		--{"common_ui_cfg", 1, {0}},
		{"rexue_god_equip_ui_cfg", 6, {0}},
		--{"common_ui_cfg", 2, {0}, nil, 999},
	}
	
end


function NewReXueGodEquipPanel:__delete( ... )
	-- body
end


function NewReXueGodEquipPanel:ReleaseCallBack( ... )
	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end

	if self.tabbar_list then
		self.tabbar_list:DeleteMe()
		self.tabbar_list = nil
	end
	if self.effect_model then
		self.effect_model:setStop()
		self.effect_model = nil 
	end
	if self.cur_attr_list then
		self.cur_attr_list:DeleteMe()
		self.cur_attr_list = nil
	end
	if self.num_bar then
		self.num_bar:DeleteMe()
		self.num_bar = nil 
	end
	if self.skill_cell then
		self.skill_cell:DeleteMe()
		self.skill_cell = nil 
	end

	if self.zhizun_comsume_cell_list  then
		for k,v in pairs(self.zhizun_comsume_cell_list) do
			v:DeleteMe()
		end
		self.zhizun_comsume_cell_list = {}
	end 

	if self.bag_compose_result then
		GlobalEventSystem:UnBind(self.bag_compose_result)
		self.bag_compose_result = nil
	end

	if self.effect_show2 then
		self.effect_show2:setStop()
		self.effect_show2 = nil
	end
	if nil ~= self.time_delay then
		GlobalTimerQuest:CancelQuest(self.time_delay)
		self.time_delay = nil
	end

	if self.cell_list then
		for k, v in pairs(self.cell_list) do
			v:DeleteMe()
		end 
		self.cell_list = {}
	end

	if self.sha_shen_cell_list then
		for k, v in pairs(self.sha_shen_cell_list) do
			v:DeleteMe()
		end
		self.sha_shen_cell_list = {}
	end
	if self.equip_cell then
		self.equip_cell:DeleteMe()
		self.equip_cell = nil
	end

	if self.bag_cell then
		self.bag_cell:DeleteMe()
		self.bag_cell = nil
	end
	if self.preview_cell then
		self.preview_cell:DeleteMe()
		self.preview_cell = nil 
	end
	if self.num_bar1 then
		self.num_bar1:DeleteMe()
		self.num_bar1 = nil
	end
end

function NewReXueGodEquipPanel:LoadCallBack( ... )
	self.select_equip_pos = EquipData.EquipSlot.itGodWarHelmetPos
	self.select_sha_equip_pos = EquipData.EquipSlot.itKillArrayShaPos
	self.cell_list = {}
	self.sha_shen_cell_list = {}
	self:InitTabbar()
	self:CreateAccordition()
	self:CreateEffEct()
	self:CreateNumBar()
	self:CreateSkillCell()
	self:CreateConsumeCell()
	self:CreateZhanSHenCell()
	self:CreateShaShenCell()
	self:CreateShowCell()
	self.index = 1
	XUI.AddClickEventListener(self.node_t_list.btn_get.node,BindTool.Bind1(self.ComposeReXueZhiZun,self))
	XUI.AddClickEventListener(self.node_t_list.btn_suit_img.node,BindTool.Bind1(self.OpenSuitTips,self))
	XUI.AddClickEventListener(self.node_t_list.btn_suit_tip2.node,BindTool.Bind1(self.OpenZhanShenSuitTips,self))
	XUI.AddClickEventListener(self.node_t_list.btn_suit_tip3.node,BindTool.Bind1(self.OpenShaShenSuitTips,self))


	--XUI.AddClickEventListener(self.node_t_list.btn_suit_img.node:BindTool.Bind1(self.OpenSuitTips,self))
	XUI.AddClickEventListener(self.node_t_list.img_tips_show.node,BindTool.Bind1(self.OpenDescConetnt,self))

	XUI.AddClickEventListener(self.node_t_list.img_show_tip.node,BindTool.Bind1(self.OpenOpenOtherConetnt,self))

	
	self.bag_compose_result = GlobalEventSystem:Bind(KnapsackEventType.KNAPSACK_COMPOSE_EQUIP, BindTool.Bind(self.ComposeResult, self))
	--XUI.AddClickEventListener(self.node_t_list.btn_suit_img.node:BindTool.Bind1(self.OpenSuitTips,self

	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.ItemDataListChangeCallback, self))

	XUI.AddClickEventListener(self.node_t_list.btn_compose.node,BindTool.Bind1(self.ComposeOtherEquip,self))
	self:FlushLayoutShow()
end

function NewReXueGodEquipPanel:OpenShaShenSuitTips( ... )
	ReXueGodEquipCtrl.Instance:OpenTipView(13)
end

function NewReXueGodEquipPanel:OpenZhanShenSuitTips()
	ReXueGodEquipCtrl.Instance:OpenTipView(12)
end

function NewReXueGodEquipPanel:OpenDescConetnt(  )
	DescTip.Instance:SetContent(Language.DescTip.GodEquipContent, Language.DescTip.GodEquipTitle)
end

function NewReXueGodEquipPanel:OpenOpenOtherConetnt()
	if self.index == 3 then
		DescTip.Instance:SetContent(Language.DescTip.ZhanShenGodEquipContent, Language.DescTip.ZhenShenGodEquipTitle)
	elseif self.index == 4 then
		DescTip.Instance:SetContent(Language.DescTip.ShaShenGodEquipContent, Language.DescTip.SHaShenGodEquipTitle)
	end
end

function NewReXueGodEquipPanel:ItemDataListChangeCallback( ... )
	self:FlushComsumeCell()
	--self:FlushOtherReXue()
	self:FlushAccorditionPoint()
	
	
	self:FlushZhanShenLeftShow()
	self:FlushShaShenLeftShow()
	self:FlushZhanShenPoint()
	self:FlushShaShenPoint()
	self:FlushRightShow()
	self:FlushShow()
	self:FlushTabbarPoint()
	self:SetSkillShow()
end

function NewReXueGodEquipPanel:ComposeResult()
	-- if nil == self.effect_show1 then
	-- 	local ph = self.ph_list.ph_reward_cell
	--  	self.effect_show1 = AnimateSprite:create()
	--  	self.effect_show1:setPosition(ph.x + 45, ph.y + 46)
	--  	 self.node_t_list.layout_other_compose.node:addChild(self.effect_show1, 999)
	-- end
	-- local anim_path, anim_name = ResPath.GetEffectUiAnimPath(1151)
	-- self.effect_show1:setAnimate(anim_path, anim_name, 1, FrameTime.Effect, false)
	self.time_delay = GlobalTimerQuest:AddDelayTimer(function ()
			if nil == self.effect_show2 then
				local ph = self.ph_list.ph_model
			 	self.effect_show2 = AnimateSprite:create()
			 	self.effect_show2:setPosition(ph.x + 35, ph.y + 25)
			 	 self.node_t_list.layout_zhizun.node:addChild(self.effect_show2, 999)
			end
			local anim_path, anim_name = ResPath.GetEffectUiAnimPath(1152)
			self.effect_show2:setAnimate(anim_path, anim_name, 1, FrameTime.Effect, false)
		if nil ~= self.time_delay then
			GlobalTimerQuest:CancelQuest(self.time_delay)
			self.time_delay = nil
		end
	end, 0.1)
	self:FlushComsumeCell()
end

function NewReXueGodEquipPanel:InitTabbar()
	if nil == self.tabbar then
		local ph = self.ph_list["ph_common_tabbar"]
		self.exchange_layout = self.node_t_list.layout_common
		self.tabbar = Tabbar.New()
		self.tabbar:CreateWithNameList(self.exchange_layout.node, ph.x, ph.y - 3,
			function(index) self:ChangeToIndex(index) end, 
			Language.ReXueGodEquip.TabGroup1, false, ResPath.GetCommon("toggle_121"))
		self.tabbar:ChangeToIndex(self:GetShowIndex())
		self.tabbar:SetSpaceInterval(5)
	end	
end



function NewReXueGodEquipPanel:CreateNumBar( ... )
	local ph = self.ph_list.ph_numbar_zhizhun
	if nil == self.num_bar then
	    self.num_bar = NumberBar.New()
	    self.num_bar:Create(ph.x - 20, ph.y - 10, 0, 0, ResPath.GetCommon("num_133_"))
	    self.num_bar:SetSpace(-8)
	    self.node_t_list.layout_zhizun.node:addChild(self.num_bar:GetView(), 101)
	end

	local ph = self.ph_list.ph_number_common
	if nil == self.num_bar1 then
	    self.num_bar1 = NumberBar.New()
	    self.num_bar1:Create(ph.x - 20, ph.y - 10, 0, 0, ResPath.GetCommon("num_133_"))
	    self.num_bar1:SetSpace(-8)
	    self.node_t_list.layout_zhan_sha.node:addChild(self.num_bar1:GetView(), 101)
	end
end


function NewReXueGodEquipPanel:CreateSkillCell( ... )
	local ph = self.ph_list.ph_new_skill_cell
	if self.skill_cell == nil then
		self.skill_cell = NewRexueSkillCell.New()
		self.node_t_list.layout_zhizun.node:addChild(self.skill_cell:GetView(), 99)
		self.skill_cell:GetView():setPosition(ph.x, ph.y)
		XUI.AddClickEventListener(self.skill_cell:GetView(), BindTool.Bind1(self.OpenSkillTip, self))
	end
end


function NewReXueGodEquipPanel:CreateConsumeCell( ... )
	-- local ph_1 = self.ph_list.ph_zhizhun_consume_cell1
	-- if self.comsume_cell == nil then
	-- 	self.comsume_cell = BaseCell.New()
	-- 	self.node_t_list.layout_zhizun.node:addChild(self.comsume_cell:GetView(), 99)
	-- 	self.comsume_cell:GetView():setPosition(ph_1.x, ph_1.y)
	-- end

	-- local ph_2 = self.ph_list.ph_zhizhun_consume_cell2
	-- if self.comsume_cell2 == nil then
	-- 	self.comsume_cell2 = BaseCell.New()
	-- 	self.node_t_list.layout_zhizun.node:addChild(self.comsume_cell2:GetView(), 99)
	-- 	self.comsume_cell2:GetView():setPosition(ph_2.x, ph_2.y)
	-- end
	self.zhizun_comsume_cell_list = {}
	for i = 1, 2 do
		local ph = self.ph_list["ph_zhizhun_consume_cell"..i]
		local cell = BaseCell.New()
		self.node_t_list.layout_zhizun.node:addChild(cell:GetView(), 99)
		cell:GetView():setPosition(ph.x, ph.y)
		self.zhizun_comsume_cell_list[i] = cell
	end
end


function NewReXueGodEquipPanel:SetSkillShow( ... )
	local skill_id = 0
	local skiill_level = 0
	local bool = false
	local icon = "2000_1"
	if self.index == 1  then
		skill_id = SuitPlusConfig[10].list[1].skillid
		skill_level =  1
		local suitlevel = EquipData.Instance:GetZhiZunSuitLevel()
		if suitlevel > 0 then
			skill_id = SuitPlusConfig[10].list[suitlevel].skillid
			skill_level =  SuitPlusConfig[10].list[suitlevel].skillLv
			bool = true
		end
		icon = "2000_1"
	elseif self.index == 2 then
		skill_id = SuitPlusConfig[11].list[1].skillid
		skill_level =  1
		local	suitlevel = EquipData.Instance:GetBazheLevel()
		if suitlevel > 0 then
			skill_id = SuitPlusConfig[11].list[suitlevel].skillid
			skill_level =  SuitPlusConfig[11].list[suitlevel].skillLv
			bool = true
		end
		icon = "2001_1"
	end
	local path = ResPath.GetSkillIcon(icon)
	self.skill_cell:SetItemIcon(path)
	self.skill_cell:MakeGray(not bool)
end

function NewReXueGodEquipPanel:OpenSkillTip()
	local skill_id = 0
	local skiill_level = 0
	local suit_type = 0
	local suitlevel = 0
	if self.index == 1  then
		skill_id = SuitPlusConfig[10].list[1].skillid
		skill_level =  0
		suit_type = 10
		suitlevel = EquipData.Instance:GetZhiZunSuitLevel()
		if suitlevel > 0 then
			skill_id = SuitPlusConfig[10].list[suitlevel].skillid
			skill_level =  SuitPlusConfig[10].list[suitlevel].skillLv
			
		end
	elseif self.index == 2 then
		skill_id = SuitPlusConfig[11].list[1].skillid
		skill_level =  0
		suit_type = 11
		suitlevel = EquipData.Instance:GetBazheLevel()
		if suitlevel > 0 then
			skill_id = SuitPlusConfig[11].list[suitlevel].skillid
			skill_level =  SuitPlusConfig[11].list[suitlevel].skillLv
		end
	end
	TipCtrl.Instance:OpenTipSkill(skill_id, skill_level, suit_type, suitlevel)
end


function NewReXueGodEquipPanel:ChangeToIndex(index)
	self.index = index
	self:FlushLayoutShow()
	if self.index == 1 or self.index == 2 then
		self:FlushOtherReXue()
		self.tabbar_list:SetSelectChildIndex(1, 1, false)
		self:SetSkillShow()
	elseif self.index == 3 then
		self:FlushZhanShenLeftShow()
		self.select_equip_pos = EquipData.EquipSlot.itGodWarHelmetPos
		for k,v in pairs(self.cell_list) do
			v:SetSelect(false)
		end
		self.select_equip_pos = EquipData.EquipSlot.itGodWarHelmetPos
		if self.select_equip_pos and self.cell_list[self.select_equip_pos] then
		
			self.cell_list[self.select_equip_pos]:SetSelect(true)
		end
		self:FlushShow()
	elseif self.index == 4 then
		self:FlushShaShenLeftShow()
		for k,v in pairs(self.sha_shen_cell_list) do
			v:SetSelect(false)
		end
		self.select_sha_equip_pos = EquipData.EquipSlot.itKillArrayShaPos
		if self.select_sha_equip_pos and self.sha_shen_cell_list[self.select_sha_equip_pos] then
			self.sha_shen_cell_list[self.select_sha_equip_pos]:SetSelect(true)
		end
		self:FlushShow()
	end
end


function NewReXueGodEquipPanel:FlushZhanShenLeftShow()
	for k, v in pairs(NewReXueGodEquipPanel_ZhanShen_EquipPos) do
		if self.cell_list[v.equip_slot] then
			local cell = self.cell_list[v.equip_slot]
			cell:SetData(v) 
		end
	end
end

function NewReXueGodEquipPanel:FlushShaShenLeftShow( ... )
	for k, v in pairs(NewReXueGodEquipPanel_ShaShen_EquipPos) do
		if self.sha_shen_cell_list[v.equip_slot] then
			local cell = self.sha_shen_cell_list[v.equip_slot]
			cell:SetData(v) 
		end
	end
end

function NewReXueGodEquipPanel:OpenSuitTips( ... )
	local suittype = self.index == 2 and 11 or 10
	ReXueGodEquipCtrl.Instance:OpenTipView(suittype)
end

function NewReXueGodEquipPanel:FlushLayoutShow( ... )
	self.node_t_list.layout_zhizun.node:setVisible(self.index == 1 or self.index == 2)
	self.node_t_list.layout_zhan_sha.node:setVisible(self.index == 3 or self.index == 4)
	self.node_t_list.layout_zhanshen.node:setVisible(self.index == 3)
	self.node_t_list.layout_shashen.node:setVisible(self.index == 4)
	local path = ResPath.GetReXuePath("suit1_bg")
	if self.index == 2 then
		path = ResPath.GetReXuePath("suit2_bg")
	end
	self.node_t_list.btn_suit_img.node:loadTexture(path)
end

function NewReXueGodEquipPanel:FlushOtherReXue(  )
	local data = ReXueGodEquipData.Instance:GetComspoeData(self.index)
	-- PrintTable(data)
	if data ~= nil then
		self.tabbar_list:SetData(data)
	end
	self:FlushAccorditionPoint()
end


function NewReXueGodEquipPanel:OpenCallBack( ... )
	if self.tabbar then
		self.tabbar:SelectIndex(1)
	end
end

function NewReXueGodEquipPanel:CloseCallBack( ... )
	self.index = 1
end

function NewReXueGodEquipPanel:ShowIndexCallBack( ... )
	self:Flush(index)
end

function NewReXueGodEquipPanel:OnFlush(param_t)
	self:FlushTabbarPoint()
	for k, v in pairs(param_t) do
		if k == "second_tabbbar_change"  then
			-- print("sssssss", v.child_index)
			self.tabbar:SelectIndex(v.child_index)
		elseif k == "all" then
			self:FlushLayoutShow()
			self:FlushOtherReXue()
			self:FlushComsumeCell()
			self:FlushAccorditionPoint()
			self:FlushRightShow()
			self:FlushShow()
			self:FlushZhanShenLeftShow()
			self:FlushShaShenLeftShow()
			self:FlushZhanShenPoint()
			self:FlushShaShenPoint()
			self:SetSkillShow()
		end
	end
	
end

-- 至尊，霸者
function NewReXueGodEquipPanel:CreateAccordition( ... )
	if nil == self.tabbar_list then
		local ph = self.ph_list.ph_accodition1
		self.tabbar_list = Accordion.New()
		self.tabbar_list:Create(ph.x + 5, ph.y, ph.w, ph.h, AccordionCommonRender, 1, 1, self.ph_list.ph_item_ui_config1, self.ph_list.ph_child_uiConfog1,nil,nil,15, nil)
		self.tabbar_list:SetSelectCallBack(BindTool.Bind(self.SelectChildNodeCallback, self))
		self.node_t_list.layout_zhizun.node:addChild(self.tabbar_list:GetView(), 88)
		self.tabbar_list:SetExpandByIndex(0, false)
		self.tabbar_list:SetExpandCallBack(BindTool.Bind(self.SelectTreeNodeCallBack, self))
	end
end

function NewReXueGodEquipPanel:SelectTreeNodeCallBack(item)
	-- body
	if item == nil or item:GetData() == nil then
		return
	end
	local data = item:GetData()
	self.cur_index = data.type
	self.tabbar_list:SetSelectChildIndex(1, data.type, true)
end

function NewReXueGodEquipPanel:SelectChildNodeCallback(item)
	if item == nil or item:GetData() == nil then
		return
	end
	local data = item:GetData()
	self.tree_index = data.tree_index
	self.child_index = data.index
	self.select_data = data
	-- self.node_t_list.layout_wu_compose.node:setVisible(self.select_data.isClient and true or false)
	-- self.node_t_list.layout_zhan_sha_compose.node:setVisible(not self.select_data.isClient)
	-- if self.select_data.isClient then
	-- 	self:FlushConsume(self.select_data)
	-- else
	-- 	self:FlushShowView()
	-- end
	-- self:FlushModel()
	self:FlushRightShow()
end

function NewReXueGodEquipPanel:ComposeReXueZhiZun( ... )
	local index = 10   --写死大类型 合成大类型，神兵神甲10
	if self.index == 2 then
		index = 12    -- 面甲12
	end

	local data = self.select_data 
	if data == nil then
		return
	end
	local compose_index = data and data.index or 1
	local compose_second_type = data.child_index or 1
	if data.isClient then
		if self.index == 1 or self.index == 2 then

			if data.is_need_shouchong then
				if ChargeRewardData.Instance:GetChargeRewardHadGet(1) then --第一档已领取
					--gaibSysMsgCtrl.Instance:FloatingTopRightText("")
					return
				else
					ViewManager.Instance:OpenViewByDef(ViewDef.ChargeFirst)
				end
			else
				ViewManager.Instance:OpenViewByDef(ViewDef.MainGodEquipView.RexueGodEquipDuiHuan)
				GlobalEventSystem:Fire(OPEN_VIEW_EVENT.OpenEvent, 3)
			end
			
		else
			ViewManager.Instance:OpenViewByDef(ViewDef.Explore.RareTreasure)
		end
		return
	else
		local consume_num_count = data.consume[1].count
		local num = BagData.Instance:GetItemNumInBagById(data.consume[1].id)
		if consume_num_count > num then
			 local item_id = data.consume[1].id
			 local config = ItemData.Instance:GetItemConfig(item_id)
			 if config.suitId <= 1 then --只有第一阶才会有
				  local ways = CLIENT_GAME_GLOBAL_CFG.item_get_ways[item_id]
			      local data = string.format("{reward;0;%d;1}", item_id) .. (ways and ways or "")
			      TipCtrl.Instance:OpenBuyTip(data)
			      return
			 end 
		end
		if RoleData.Instance:GetMainMoneyByType(data.consume[3].type) < data.consume[3].count then
			 local item_id = 493
			  local ways = CLIENT_GAME_GLOBAL_CFG.item_get_ways[item_id]
		      local data = string.format("{reward;0;%d;1}", item_id) .. (ways and ways or "")
		      TipCtrl.Instance:OpenBuyTip(data)
			return
		end
	end
	BagCtrl.SendComposeItem(index,compose_second_type, compose_index, 0, 1)
end

--至尊静态属性
function NewReXueGodEquipPanel:FlushRightShow()
	if self.select_data ~= nil then
		--特效显示
		local item_id = self.select_data.award[1].id
		local anim_path = ""
		local anim_name = ""
		local eff_model_cfg = SpecialTipsCfg[item_id] or {}
		local offsetx = 0
		local offsety = 0
		local scale = 1
		if eff_model_cfg.modleType == 1 then
			anim_path, anim_name =  ResPath.GetWuqiBigAnimPath(eff_model_cfg.modleId, SceneObjState.Stand, GameMath.DirDown, sex)
			offsetx = 120
			offsety = -150
			scale = 0.75
		elseif eff_model_cfg.modleType == 2 then
			anim_path, anim_name = ResPath.GetRoleBigAnimPath(eff_model_cfg.modleId, SceneObjState.Stand, GameMath.DirDown)
			offestX = 0
		elseif eff_model_cfg.modleType == 3 then
			anim_path, anim_name = ResPath.GetEffectUiAnimPath(eff_model_cfg.modleId)
		end
		local ph = self.ph_list.ph_model
		self.effect_model:setPosition(ph.x + 35 + (offsetx or 0), ph.y + 5 + offsety)
		self.effect_model:setScale(scale)
		self.effect_model:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)

		--属性显示
		local  reward_iten_cfg = ItemData.Instance:GetItemConfig(self.select_data.award[1].id)
		local attr = reward_iten_cfg.staitcAttrs
		local attr_list = RoleData.FormatRoleAttrStr(attr)
		self.cur_attr_list:SetDataList(attr_list)

		--战力显示
		local score =  CommonDataManager.GetAttrSetScore(attr, RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF))
		self.num_bar:SetNumber(score)

		local bool = true
		local text = "合成"
		if self.select_data.isClient then
			consume_count = ""
			text = "前往兑换"
			data_consume = {} 
			--is_font = ""
			if self.select_data.is_need_shouchong then
				text = "首充获取"
				if  ChargeRewardData.Instance:GetChargeRewardHadGet(1) then
					text = "已领取"
					bool = false
				end
			end
		end
		self.node_t_list.btn_get.node:setTitleText(text)
		XUI.SetButtonEnabled(self.node_t_list.btn_get.node, bool)
		self:FlushComsumeCell()
	end
end

--刷新消耗
function NewReXueGodEquipPanel:FlushComsumeCell()
	if self.select_data == nil then
		return
	end
	for k, v in pairs(self.zhizun_comsume_cell_list) do
		v:GetView():setVisible(false)
	end
	RichTextUtil.ParseRichText(self.node_t_list.rich_text_consume.node, "")
	local text1 = ""
	-- PrintTable(self.select_data)
	-- print(self.select_data.consume)
	if not self.select_data.isClient then
		for k, v in pairs(self.select_data.consume or {}) do
			if v.type <= 0 then
				local cell = self.zhizun_comsume_cell_list[k]
				if cell then
					cell:GetView():setVisible(true)
					cell:SetData({item_id = v.id, is_bind = 0, num =1})
				end
			end

			if v.type > 0 then
				local item_id = tagAwardItemIdDef[v.type]
				local num = RoleData.Instance:GetMainMoneyByType(v.type) or 0
				local path =  RoleData.GetMoneyTypeIconByAwardType(v.type)
				local color = (num >= v.count) and "00ff00" or "ff0000"
				local is_show_tips = v.type > 0 and 0 or 1
				local scale = v.type > 0 and 1 or 0.5

				local num_s = string.format("%.1f",num/10000)
				text1 = text1 .. string.format(Language.Bag.ComposeTip2, path,"20,20", scale, v.id, is_show_tips, color, num_s, v.count/ 10000).."   "
			end
		end
		RichTextUtil.ParseRichText(self.node_t_list.rich_text_consume.node, text1)
		XUI.RichTextSetCenter(self.node_t_list.rich_text_consume.node)
		local text = ""
		local num1 = BagData.Instance:GetItemNumInBagById(self.select_data.consume[1].id)
		local num2 = BagData.Instance:GetItemNumInBagById(self.select_data.consume[2].id)
		local count1 = self.select_data.consume[1].count
		local count2 = self.select_data.consume[2].count
		if self.select_data.consume[1].id == self.select_data.consume[2].id then
			num2 = (num2 - 1) < 0 and 0 or (num2 - 1)
		end
		local color1 = num1 >= count1 and COLOR3B.GREEN or COLOR3B.RED
		local color2 = num2 >= count2 and COLOR3B.GREEN or COLOR3B.RED 

		local text1 = num1 .. "/" .. count1 
		local text22 = num2 .. "/".. count2
		local cell1 = self.zhizun_comsume_cell_list[1]
		local cell2 = self.zhizun_comsume_cell_list[2]
		if cell1 then
			cell1:SetRightBottomText(text1, color1)
		end
		if cell2  then
			cell2:SetRightBottomText(text22, color2)
		end
		--SetRightBottomText
	end
end


function NewReXueGodEquipPanel:CreateEffEct( ... )
	if nil == self.effect_model then
		local ph = self.ph_list.ph_model
	 	self.effect_model = AnimateSprite:create()
	 	self.effect_model:setPosition(ph.x + 35, ph.y + 5)
	 	self.node_t_list.layout_zhizun.node:addChild(self.effect_model, 999)
	end

	if nil == self.cur_attr_list then
		local ph = self.ph_list.ph_attr_List--获取区间列表
		self.cur_attr_list = ListView.New()
		self.cur_attr_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Vertical, ShenBinAttrItem, nil, nil, self.ph_list.ph_attr_item5)
		self.cur_attr_list:SetItemsInterval(5)--格子间距
		self.cur_attr_list:SetJumpDirection(ListView.Top)--置顶
		self.node_t_list.layout_zhizun.node:addChild(self.cur_attr_list:GetView(), 20)
		self.cur_attr_list:GetView():setAnchorPoint(0, 0)
	end
end

function NewReXueGodEquipPanel:FlushAccorditionPoint()
	local data = ReXueGodEquipData.Instance:GetComspoeData(self.index)
	if data == nil then
		return
	end
	local sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)
	for k, v in pairs(data) do
		local node = self.tabbar_list:GetTreeNodeByTreeIndex(v.type)
		local vis = ReXueGodEquipData.Instance:SetTreepoint(v.index, v.child_index, sex)
		
		if node then
			node:FlushEquipRemind(vis)
		end
		for k1, v1 in pairs(v.child) do
			 local child_node = self.tabbar_list:GetChidNodeByIndex(v.type, k1)
			 if child_node then
			 	local data = v1
			 	local vis  = ReXueGodEquipData.Instance:SetSecondPoint(v1.remin_data)
	
			 	child_node:FlushEquipRemind(vis)
			 end
		end
	end
end

--修改显示
function NewReXueGodEquipPanel:CreateShowCell( ... )
	if nil == self.equip_cell then
		local ph = self.ph_list.ph_cell_1 
		self.equip_cell = BaseCell.New()
		self.node_t_list.layout_zhan_sha.node:addChild(self.equip_cell:GetView(), 99)
		self.equip_cell:GetView():setPosition(ph.x + 15, ph.y + 18)
	end
	if nil == self.bag_cell then
		local ph = self.ph_list.ph_cell_2 
		self.bag_cell = BaseCell.New()
		self.node_t_list.layout_zhan_sha.node:addChild(self.bag_cell:GetView(), 99)
		self.bag_cell:GetView():setPosition(ph.x + 15, ph.y + 18)
	end

	if nil == self.preview_cell then
		local ph = self.ph_list.ph_cell_3 
		self.preview_cell = BaseCell.New()
		self.node_t_list.layout_zhan_sha.node:addChild(self.preview_cell:GetView(), 99)
		self.preview_cell:GetView():setPosition(ph.x + 15, ph.y + 18)
	end
end
--热血战神 
NewReXueGodEquipPanel_ZhanShen_EquipPos =   {
		{equip_slot = EquipData.EquipSlot.itGodWarHelmetPos, cell_pos = 1, cell_img = ResPath.GetEquipImg("cs_bg_3")},	-- 战神_头盔	45
		{equip_slot = EquipData.EquipSlot.itGodWarNecklacePos, cell_pos = 2,cell_img = ResPath.GetEquipImg("cs_bg_4")},	-- 战神_项链
		{equip_slot = EquipData.EquipSlot.itGodWarLeftBraceletPos, cell_pos = 3, cell_img = ResPath.GetEquipImg("cs_bg_5")},	-- 衣战神_左手镯
		{equip_slot = EquipData.EquipSlot.itGodWarRightBraceletPos, cell_pos = 4, cell_img = ResPath.GetEquipImg("cs_bg_5")},	-- 战神_右手镯
		{equip_slot = EquipData.EquipSlot.itGodWarLeftRingPos, cell_pos = 5, cell_img = ResPath.GetEquipImg("cs_bg_6")},	-- 战神_左戒指
		{equip_slot = EquipData.EquipSlot.itGodWarRightRingPos, cell_pos = 6, cell_img = ResPath.GetEquipImg("cs_bg_6")},	-- 战神_右戒指
		{equip_slot = EquipData.EquipSlot.itGodWarGirdlePos, cell_pos =7,cell_img = ResPath.GetEquipImg("cs_bg_7")},	-- 战神_腰带
		{equip_slot = EquipData.EquipSlot.itGodWarShoesPos,  cell_pos =8,cell_img = ResPath.GetEquipImg("cs_bg_8")},	-- 战神_鞋子 52
		
	}
function NewReXueGodEquipPanel:CreateZhanSHenCell( ... )
	self.cell_list = {}
	for k, v in pairs(NewReXueGodEquipPanel_ZhanShen_EquipPos) do
		local cell = NewReXueGodEquipPanel.CommonEquipCell.New()
		local ph = self.ph_list["ph_item_"..(v.cell_pos)]
		cell:GetView():setPosition(ph.x,ph.y)  
		cell:SetData(v)
		self.node_t_list.layout_zhanshen.node:addChild(cell:GetView(), 99)
		cell:SetClickCellCallBack(BindTool.Bind(self.SelectZhanShenCellCallBack, self))
		self.cell_list[v.equip_slot] = cell
	end

	if self.select_equip_pos and self.cell_list[self.select_equip_pos] then
		--print(">>>>>>>>>>", self.select_equip_pos)
		self.cell_list[self.select_equip_pos]:SetSelect(true)
	end
end

function NewReXueGodEquipPanel:SelectZhanShenCellCallBack(cell)
	if cell == nil or cell:GetData() == nil then
		return
	end
	cell:SetSelect(true)
	self.select_data1 = cell:GetData()
	if self.select_equip_pos and self.cell_list[self.select_equip_pos] and 
		self.select_equip_pos ~= self.select_data1.equip_slot then

		self.cell_list[self.select_equip_pos]:SetSelect(false)
	end
	
	self.select_equip_pos = self.select_data1.equip_slot

	local equip_data = ReXueGodEquipData.Instance:SetReXueCanBestData(self.select_equip_pos)
	if equip_data ~= nil then
		EquipCtrl.SendFitOutEquip(equip_data.series, EquipData.SLOT_HAND_POS[self.select_equip_pos])
	end
	self:FlushShow()
end


function NewReXueGodEquipPanel:FlushZhanShenPoint( ... )

	--ReXueGodEquipData:GetCanCompose(equip, type, equip_pos)
	for k, v in pairs(NewReXueGodEquipPanel_ZhanShen_EquipPos) do
		local cell = self.cell_list[v.equip_slot]
		if cell then
			local best_data = ReXueGodEquipData.Instance:SetReXueCanBestData(v.equip_slot)
				
			local vis = (best_data ~= nil) and true or false
			if not vis then
				local equip = EquipData.Instance:GetEquipDataBySolt(v.equip_slot)
				if equip then  
					vis = ReXueGodEquipData.Instance:GetCanCompose(equip, 2, v.equip_slot)
				end
			end
			cell:FlushRemind(vis)
		end
	end
end

function NewReXueGodEquipPanel:FlushTabbarPoint()
	local vis1 = ReXueGodEquipData.Instance:SingleCanPoint(10)
	local vis2 = ReXueGodEquipData.Instance:SingleCanPoint(12) 
	local vis3 = ReXueGodEquipData.Instance:GetZhanShenCanCompose() > 0 and true or false
	local vis4 = ReXueGodEquipData.Instance:GetShaShenCanCompose() > 0 and true or false
	self.tabbar:SetRemindByIndex(1, vis1)
	self.tabbar:SetRemindByIndex(2, vis2)
	self.tabbar:SetRemindByIndex(3, vis3)
	self.tabbar:SetRemindByIndex(4, vis4)
end

--=====杀神
NewReXueGodEquipPanel_ShaShen_EquipPos =   {
		{equip_slot = EquipData.EquipSlot.itKillArrayShaPos, cell_pos = 11, cell_img = ResPath.GetEquipImg("41")},	-- 战神_头盔	45
		{equip_slot = EquipData.EquipSlot.itKillArrayMostPos, cell_pos = 12,cell_img = ResPath.GetEquipImg("42")},	-- 战神_项链
		{equip_slot = EquipData.EquipSlot.itKillArrayRobberyPos, cell_pos = 13, cell_img = ResPath.GetEquipImg("43")},	-- 衣战神_左手镯
		{equip_slot = EquipData.EquipSlot.itKillArrayLifePos, cell_pos = 14, cell_img = ResPath.GetEquipImg("44")},	-- 战神_右手镯
		
	}

function NewReXueGodEquipPanel:CreateShaShenCell( ... )
	self.sha_shen_cell_list = {}
	for k, v in pairs(NewReXueGodEquipPanel_ShaShen_EquipPos) do
		local cell = NewReXueGodEquipPanel.CommonEquipCell.New()
		local ph = self.ph_list["equip_sha_cell"..(v.cell_pos)]
		cell:GetView():setPosition(ph.x,ph.y)  
		cell:SetData(v)
		self.node_t_list.layout_shashen.node:addChild(cell:GetView(), 99)
		cell:SetClickCellCallBack(BindTool.Bind(self.SelectCellCallBack, self))
		self.sha_shen_cell_list[v.equip_slot] = cell
	end

	if self.select_sha_equip_pos and self.sha_shen_cell_list[self.select_sha_equip_pos] then
		--print(">>>>>>>>>>", self.select_sha_equip_pos)
		self.sha_shen_cell_list[self.select_sha_equip_pos]:SetSelect(true)
	end
end
--热血杀神

function NewReXueGodEquipPanel:SelectCellCallBack(cell)
	if cell == nil or cell:GetData() == nil then
		return
	end
	cell:SetSelect(true)
	self.select_data2 = cell:GetData()
	if self.select_sha_equip_pos and self.sha_shen_cell_list[self.select_sha_equip_pos] and 
		self.select_sha_equip_pos ~= self.select_data2.equip_slot then

		self.sha_shen_cell_list[self.select_sha_equip_pos]:SetSelect(false)
	end
	
	self.select_sha_equip_pos = self.select_data2.equip_slot

	local equip_data = ReXueGodEquipData.Instance:SetReXueCanBestData(self.select_sha_equip_pos)
	if equip_data ~= nil then
		EquipCtrl.SendFitOutEquip(equip_data.series, EquipData.SLOT_HAND_POS[self.select_sha_equip_pos])
	end
	self:FlushShow()
end

function NewReXueGodEquipPanel:FlushShaShenPoint()
	for k, v in pairs(NewReXueGodEquipPanel_ShaShen_EquipPos ) do
		local cell = self.sha_shen_cell_list[v.equip_slot]
		if cell then
			local best_data = ReXueGodEquipData.Instance:SetReXueCanBestData(v.equip_slot)
				
			local vis = (best_data ~= nil) and true or false
			if not vis then
				local equip = EquipData.Instance:GetEquipDataBySolt(v.equip_slot)
				if equip then  
					vis = ReXueGodEquipData.Instance:GetCanCompose(equip, 1, v.equip_slot)
				end
			end
			cell:FlushRemind(vis)
		end
	end
end


function NewReXueGodEquipPanel:FlushShow( ... )
	local equip_data = nil 
	local config = nil 
	local equip_pos = self.select_equip_pos
	local index = 1
	if self.index == 3 then
		equip_pos = self.select_equip_pos
		equip_data = EquipData.Instance:GetEquipDataBySolt(self.select_equip_pos)
		index = 2
	elseif self.index == 4 then
		equip_pos = self.select_sha_equip_pos
		equip_data = EquipData.Instance:GetEquipDataBySolt(self.select_sha_equip_pos)
		index = 1
	end
	
	local config = ReXueGodEquipData.Instance:GetConfiByTypeEquipPos(index, equip_pos, equip_data and equip_data.item_id )
	local text = ""
	local data = nil
	if config ~= nil then
		data = {item_id = config.itemId, num = 1, is_bind = 0}
		local item_config = ItemData.Instance:GetItemConfig(config.itemId)
		text = item_config.name
	end
	local remain_data = equip_data
	if equip_data == nil then

		data = {item_id = ReXueGodEquipShow[equip_pos], num =1,is_bind = 0 }
		local item_config = ItemData.Instance:GetItemConfig(data.item_id)
		text = item_config.name
		remain_data = data 
	end
	self.equip_cell:SetData(remain_data)
	self.equip_cell:SetCellBg(ResPath.GetCommon("cell_118"))

	local num = equip_data and 1 or 0

	local text_right = num .. "/".. 1
	local color = num >= 1 and COLOR3B.GREEN or COLOR3B.RED

	self.equip_cell:SetRightBottomText(text_right, color)

	self.preview_cell:SetData(data)

	if data then
		local item_config = ItemData.Instance:GetItemConfig(data.item_id) or {}
		local score =  CommonDataManager.GetAttrSetScore(item_config.staitcAttrs or {}, RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF))
		self.num_bar1:SetNumber(score) 
	else
		self.num_bar1:SetNumber(0) 
	end

	self.preview_cell:SetCellBg(ResPath.GetCommon("cell_118"))
	--self.node_t_list.text_equip_name.node:setString(text)
	local bag_data = nil 
	local con_text = ""
	local bag_num = 0
	if config  then
		bag_num = BagData.Instance:GetItemNumInBagById(config.consume[1].id, nil)
		bag_data = {item_id = config.consume[1].id, num = 1, is_bind = 0}
		con_text = self:FlushComsumeMoney(config.consume)
	end

	if equip_data == nil then
		con_text = "" 
	end
	self.bag_cell:SetData(bag_data)
	self.bag_cell:SetCellBg(ResPath.GetCommon("cell_118"))


	local text_right = bag_num .. "/"..  (config and config.consume[1].count or 1)
	local color = bag_num >= (config and config.consume[1].count or 1) and COLOR3B.GREEN or COLOR3B.RED

	self.bag_cell:SetRightBottomText(text_right, color)

	RichTextUtil.ParseRichText(self.node_t_list.rich_text_consume1.node, con_text)
	XUI.RichTextSetCenter(self.node_t_list.rich_text_consume1.node)

	for i=1,5 do
		self.node_t_list["text_next_value"..i].node:setString("")
		self.node_t_list["text_name"..i].node:setString("")
		self.node_t_list["text_value"..i].node:setString("")
	end
	--属性显示---
	if config then
		local item_config = ItemData.Instance:GetItemConfig(config.itemId)

		local attr = item_config.staitcAttrs
		local attr_list = RoleData.FormatRoleAttrStr(attr)

		if equip_data == nil then
			for i = 1, 5 do
				if attr_list[i] then
					self.node_t_list["text_value"..i].node:setString(0)
					self.node_t_list["text_name"..i].node:setString(attr_list[i].type_str .. ":")
					self.node_t_list["text_next_value"..i].node:setString(attr_list[i].value_str)
					local color = RoleData.Instance:GetAttrColorByType(attr_list[i].type)
					self.node_t_list["text_value"..i].node:setColor(color)
					self.node_t_list["text_name"..i].node:setColor(color)
					self.node_t_list["text_next_value"..i].node:setColor(color)
				end
			end
		else
			for i = 1, 5 do
				if attr_list[i] then

					self.node_t_list["text_next_value"..i].node:setString(attr_list[i].value_str)
					local color = RoleData.Instance:GetAttrColorByType(attr_list[i].type)
					self.node_t_list["text_next_value"..i].node:setColor(color)
				end
			end
		end
	end
	if equip_data ~= nil then
		local equip_config = ItemData.Instance:GetItemConfig(equip_data.item_id)
		local attr = equip_config.staitcAttrs
		local attr_list = RoleData.FormatRoleAttrStr(attr)
		for i = 1, 5 do
			if attr_list[i] then
				local color = RoleData.Instance:GetAttrColorByType(attr_list[i].type)
				self.node_t_list["text_value"..i].node:setString(attr_list[i].value_str)
				self.node_t_list["text_name"..i].node:setString(attr_list[i].type_str..":")
				self.node_t_list["text_value"..i].node:setColor(color)
				self.node_t_list["text_name"..i].node:setColor(color)
			end
		end
	end



	local text = "合成"
	if equip_data == nil then
		text = "前往获取"
	end
	self.node_t_list.btn_compose.node:setTitleText(text)
end


function NewReXueGodEquipPanel:ShowTabbarPoint( ... )
	-- body
end

function NewReXueGodEquipPanel:FlushComsumeMoney(consume)
	local text = ""
	for k, v in pairs(consume) do
		local item_id = v.id
		local num = BagData.Instance:GetItemNumInBagById(v.id, nil)
		local item_cfg = ItemData.Instance:GetItemConfig(item_id)
		local path = ResPath.GetItem(item_cfg.icon)
		if v.type > 0 then
			item_id = tagAwardItemIdDef[v.type]

			num = RoleData.Instance:GetMainMoneyByType(v.type) or 0
			path =  RoleData.GetMoneyTypeIconByAwardType(v.type)
			local color = (num >= v.count) and "00ff00" or "ff0000"
			local is_show_tips = v.type > 0 and 0 or 1
			local scale = v.type > 0 and 1 or 0.5
			local num_s = string.format("%.1f",num/10000)
			text = text .. string.format(Language.Bag.ComposeTip2, path,"20,20", scale, v.id, is_show_tips, color, num_s, v.count/10000).."   "
		end
		
	end
	return text 
end


function NewReXueGodEquipPanel:ComposeOtherEquip()
	if self.index == 3 then
		local equip_data = EquipData.Instance:GetEquipDataBySolt(self.select_equip_pos)
		if equip_data == nil then
			ViewManager.Instance:OpenViewByDef(ViewDef.MainGodEquipView.RexueGodEquipDuiHuan)
			GlobalEventSystem:Fire(OPEN_VIEW_EVENT.OpenEvent, 3)
		else
			ReXueGodEquipCtrl.Instance:ReqComspoeEquip(2, self.select_equip_pos)
		end
	elseif self.index == 4 then
		local equip_data = EquipData.Instance:GetEquipDataBySolt(self.select_sha_equip_pos)
		if equip_data == nil then
			ViewManager.Instance:OpenViewByDef(ViewDef.MainGodEquipView.RexueGodEquipDuiHuan)
			GlobalEventSystem:Fire(OPEN_VIEW_EVENT.OpenEvent, 3)
		else
			ReXueGodEquipCtrl.Instance:ReqComspoeEquip(1, self.select_sha_equip_pos)
		end

	end
end

AccordionCommonRender = AccordionCommonRender or BaseClass(AccordionItemRender)
function AccordionCommonRender:__init( ... )

end

function AccordionCommonRender:__delete( ... )
	-- body
end

function AccordionCommonRender:CreateChild( ... )
	BaseRender.CreateChild(self)
end

function AccordionCommonRender:OnFlush( ... )
	if self.data == nil then
		return 
	end

	if self.node_tree["img_path1"] and self.data.name_path then
		self.node_tree["img_path1"].node:loadTexture( ResPath.GetReXuePath(self.data.name_path))
	end
	if self.node_tree["text_name1"] then
		self.node_tree["text_name1"].node:setString(self.data.name)
		self.node_tree["text_name1"].node:setColor(self.data.color)
		self.node_tree["text_name1"].node:setLocalZOrder(998)
	end

	if self.node_tree["img_rototation"] then
		local rotation =  self.is_select and 0 or -90
		self.node_tree["img_rototation"].node:setRotation(rotation)
	end

end

function AccordionCommonRender:OnSelectChange( is_select)
	if self.node_tree["img_rototation"] then
		local rotation = is_select and 0 or -90
		self.node_tree["img_rototation"].node:setRotation(rotation)
	end
end


function AccordionCommonRender:FlushEquipRemind(vis)
	--local path = path or ResPath.GetMainui("remind_flag")
	local size = self.view:getContentSize()
	x = size.width - 10
	y = size.height - 15
	if vis and nil == self.remind_bg_sprite then
	
		self.remind_bg_sprite = XUI.CreateImageView(x, y, ResPath.GetMainui("remind_flag"), true)
		self.remind_bg_sprite:setScale(0.6)
		self.view:addChild(self.remind_bg_sprite, 999, 999)
	elseif self.remind_bg_sprite then
		self.remind_bg_sprite:setVisible(vis)
	end
end

function AccordionCommonRender:CreateSelectEffect()
	if self:IsChild() then
		local size = self.view:getContentSize()
		self.select_effect = XUI.CreateImageViewScale9(size.width / 2, size.height / 2, size.width, size.height, ResPath.GetReXuePath("img_select"), true)
		self.view:addChild(self.select_effect, 200, 200)
	end
end

NewRexueSkillCell = NewRexueSkillCell or BaseClass(BaseCell)
function NewRexueSkillCell:SetAddClickEventListener( ... )
	-- body
end



local CommonEquipCell = BaseClass(BaseRender)
 NewReXueGodEquipPanel.CommonEquipCell = CommonEquipCell
CommonEquipCell.size = cc.size(92, 98)
function CommonEquipCell:__init()
	self:SetIsUseStepCalc(true)
	self.view:setContentSize(CommonEquipCell.size)

	self.cell = BaseCell.New()
	self.cell:SetPosition(CommonEquipCell.size.width / 2, CommonEquipCell.size.height - BaseCell.SIZE / 2 -10)
	self.cell:SetAnchorPoint(0.5, 0.5)
	self.cell:SetIsShowTips(false)
	self.cell:SetCellBgVis(true)
	
	self.view:addChild(self.cell:GetView(), 10)
	self.click_cell_callback = nil
	self.cell:AddClickEventListener(function()
		if self.click_cell_callback then
			self.click_cell_callback(self)
		end
	end)
	self.red_image = XUI.CreateImageView(BaseCell.SIZE-15, BaseCell.SIZE -15, ResPath.GetMainUiImg("remind_flag"), true)
	self.red_image:setVisible(false)
	self.cell:GetView():addChild(self.red_image,11)
end

function CommonEquipCell:__delete()
	if self.cell then
		self.cell:DeleteMe()
		self.cell = nil
	end
	self.click_cell_callback = nil
end

function CommonEquipCell:CreateChild()
	CommonEquipCell.super.CreateChild(self)

	self.rich_under = XUI.CreateRichText(CommonEquipCell.size.width / 2, 0, 300, 20)
	XUI.RichTextSetCenter(self.rich_under)
	self.rich_under:setAnchorPoint(0.5, 0)
	self.view:addChild(self.rich_under, 10)
end

function CommonEquipCell:OnFlush()
	local equip_data = EquipData.Instance:GetEquipDataBySolt(self.data.equip_slot)
	if equip_data then
		self.cell:SetData(equip_data)
	end

	--self.cell:SetRemind(EquipData.Instance:GetChuanShiCanUp(self.data.equip_slot) > 0)

	-- local equip = EquipData.Instance:GetBestCSEquip(equip_data, self.data.equip_slot)
	-- local vis = equip  and true or false
	self.red_image:setVisible(vis)
	if nil == equip_data then
		-- local act_cfg = EquipData.GetChuanShiActiveCfg(EquipData.ChuanShiCfgIndex(self.data.equip_slot))
		-- if act_cfg then
		-- 	local next_equip_id = act_cfg.targetEquips
		-- 	RichTextUtil.ParseRichText(self.rich_under, ItemData.Instance:GetItemNameRich(next_equip_id))
		-- 	self.cell:SetData({item_id = next_equip_id, num = 1, is_bind = 0})
		-- 	self.cell:SetCfgEffVis(false)
		-- end
		self.cell:SetData(nil)
		self:SetItemIcon(self.data.cell_img)
		--self.cell:MakeGray(true)
		
	else
		self.cell:SetCfgEffVis(true)
	end
	self.cell:SetCellBg(ResPath.GetCommon("cell_101"))
end

function CommonEquipCell:SetClickCellCallBack(func)
	self.click_cell_callback = func
end

function CommonEquipCell:SetSkinStyle(...)
	if self.cell then
		self.cell:SetSkinStyle(...)
	end
end

function CommonEquipCell:SetItemIcon(path)
	if self.cell then
		self.cell:SetItemIcon(path)
	end
end

function CommonEquipCell:CreateSelectEffect()
	self.select_effect = XUI.CreateImageViewScale9(CommonEquipCell.size.width / 2, CommonEquipCell.size.height/2,
		BaseCell.SIZE, BaseCell.SIZE, ResPath.GetCommon("img9_120"), true)
	self.view:addChild(self.select_effect, 999)
end

function CommonEquipCell:FlushRemind(vis)
	local path = path or ResPath.GetMainui("remind_flag")
	local size = self.view:getContentSize()
	x = size.width -10
	y = size.height - 20
	if vis and nil == self.remind_bg_sprite then		
		self.remind_bg_sprite = XUI.CreateImageView(x, y, path, true)
		self.remind_bg_sprite:setScale(0.6)
		self.view:addChild(self.remind_bg_sprite, 999, 999)
	elseif self.remind_bg_sprite then
		self.remind_bg_sprite:setVisible(vis)
	end
end



return NewReXueGodEquipPanel