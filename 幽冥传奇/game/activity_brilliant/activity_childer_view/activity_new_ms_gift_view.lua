

NewMsGiftView = NewMsGiftView or BaseClass(ActBaseView)

function NewMsGiftView:__init(view, parent, act_id)
	self:LoadView(parent)
end

function NewMsGiftView:__delete()
	
	-- end
	self.cell_buyitem_list = nil

	if self.buy_shop_list then
		self.buy_shop_list:DeleteMe()
		self.buy_shop_list = nil
	end

	if self.update_spare_timer then
		GlobalTimerQuest:CancelQuest(self.update_spare_timer)
		self.update_spare_timer = nil
	end
	if self.gold_cap then
		self.gold_cap:DeleteMe()
		self.gold_cap = nil
	end
	if self.cell_list then
		for k,v in pairs(self.cell_list) do
			v:DeleteMe()
		end
		self.cell_list = {}
	end
	if self.effect_show1 then
		self.effect_show1:setStop()
		self.effect_show1 = nil
	end

	if self.role_display then
		self.role_display:DeleteMe()
		self.role_display = nil
	end
end

function NewMsGiftView:InitView()
	--self.node_t_list.btn_goumai_55_1.node:addClickEventListener(BindTool.Bind(self.OnClickJQPDHandler, self, 1))
	-- self.node_t_list.btn_goumai_55_2.node:addClickEventListener(BindTool.Bind(self.OnClickJQPDHandler, self, 2))
	-- self:CreatPDLeftList()
	--self:CreateCell()
	-- -- self:CreatPDRightList()
	-- -- self:CreatBuyItemCell()
	-- self:CreateBuyShopItemList()
	self:CreateGoldNum()
	self.update_spare_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.UpdateSpareFFTime, self), 1)
	self.node_t_list.btn_buy.node:addClickEventListener(BindTool.Bind(self.OnClickBuyHandler, self))

	if nil == self.effect_show1 then
		local ph = self.ph_list.ph_effect
	 	self.effect_show1 = AnimateSprite:create()
	 	self.effect_show1:setPosition(ph.x + 15, ph.y + 5)
	 	self.node_t_list.layout_ms_gift.node:addChild(self.effect_show1, 999)
	end

	if nil == self.role_display then
		self.role_display = RoleDisplay.New(self.node_t_list.layout_ms_gift.node, 100, false, false, true, true)
		local ph = self.ph_list.ph_effect
		self.role_display:SetPosition(ph.x + 10,ph.y + 100)
		self.role_display:SetScale(0.8)
	end
end


function NewMsGiftView:CreateGoldNum()
	if nil == self.gold_cap then
		local ph = self.ph_list.ph_number
		self.gold_cap = NumberBar.New()
		self.gold_cap:SetRootPath(ResPath.GetScene("zdl_y_"))
		self.gold_cap:SetPosition(ph.x + 20, ph.y - 15 )
		self.gold_cap:SetGravity(NumberBarGravity.Center)
		self.gold_cap:SetSpace(-10)
		self.node_t_list.layout_ms_show.node:addChild(self.gold_cap:GetView(), 300, 300)
	end
end

function NewMsGiftView:CreateCells(num)
	if nil == self.cell_list or nil == self.cell_list[1] then 
		self.cell_list = {}
		local top = math.floor(num / 2)
		local size = 90
		local ph = self.ph_list.ph_56_cell_4
		local mid = (1 + top) / 2
		for i = 1, top do
			local cell = BaseCell.New()
			cell:SetPosition(ph.x + (i - mid) * size, ph.y + size / 2)
			cell:SetAnchorPoint(0.5, 0.5)
			self.node_t_list.layout_ms_gift.node:addChild(cell:GetView(), 300)
			table.insert(self.cell_list, cell)
		end
		local mid = (1 + num - top) / 2
		for i = 1, num - top do
			local cell = BaseCell.New()
			cell:SetPosition(ph.x + (i - mid) * size, ph.y - size / 2)
			cell:SetAnchorPoint(0.5, 0.5)
			self.node_t_list.layout_ms_gift.node:addChild(cell:GetView(), 300)
			table.insert(self.cell_list, cell)
		end
	end
end

function NewMsGiftView:UpdateSpareFFTime()
	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.MSGIFT)
	if nil == cfg then return end
	local now_time =TimeCtrl.Instance:GetServerTime()
	local end_time = cfg.end_time 
	local spare_time = end_time - now_time 
	self.node_t_list.lbl_56_turntable_time.node:setString(TimeUtil.FormatSecond2Str(spare_time))
end

function NewMsGiftView:RefreshView(param_list)

	local act_cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.MSGIFT) 

	if act_cfg and act_cfg.config then
		local pro = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
		local level = ActivityBrilliantData.Instance:GetMSGIFTLevel() --档次
		local bool = true
	 	if level == 0 then 
	 		--self.node_t_list.btn_buy.node:setEnabled(false)
	 		bool = false
	 		level = #act_cfg.config.GiftLevels
	 	end
	 	self.node_t_list.img_tip_buy.node:setVisible(not bool)
	 	self.node_t_list.btn_buy.node:setVisible(bool)
	 	local number = act_cfg.config.GiftLevels[level].money.count
		self.gold_cap:SetNumber(number)

		local awards = act_cfg.config.GiftLevels[level].award[pro]
		local award = {}
		local sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)
		for k, v in pairs(awards) do
			if v.sex == nil or v.sex == sex or v.sex == - 1 then
				table.insert(award, v)
			end
		end
		self:CreateCells(table.getn(award))

		for k,v in pairs(self.cell_list) do
			v:GetView():setVisible(false)
		end
		for i,v in ipairs(award) do
			local cell = self.cell_list[i]
			if cell then
				cell:GetView():setVisible(true)
				cell:SetData({item_id = v.id, num = v.count, is_bind = v.bind})
			end
		end

		local effect_id = act_cfg.config.GiftLevels[level].effect_id or 7
		local effect_type = act_cfg.config.GiftLevels[level].effect_type  or 1
		self.role_display:SetVisible(false)
		self.effect_show1:setVisible(false)
		if effect_type == 1 then
			self.effect_show1:setVisible(true)
			local anim_path, anim_name = ResPath.GetEffectUiAnimPath(effect_id)
			self.effect_show1:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
		else
			self.role_display:SetVisible(true)
			local role_data = act_cfg.config.GiftLevels[level].role_model_effect  or {}

			local info = {[OBJ_ATTR.ENTITY_MODEL_ID] = 0, [OBJ_ATTR.ACTOR_WEAPON_APPEARANCE] = 0,
		 		[OBJ_ATTR.ACTOR_WING_APPEARANCE] = 0, 	[OBJ_ATTR.ACTOR_THANOSGLOVE_APPEARANCE] = 0,
		 		[OBJ_ATTR.ACTOR_FOOT_APPEARANCE] = 0}
		 	local sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)
		 	local role_model_id = role_data.yifu_model[sex + 1]  or 0
		 	local weaponpos_id = role_data.wuqi_model  or 0 
		 	local wing_model = role_data.wing_model 
		 	info[OBJ_ATTR.ENTITY_MODEL_ID] = role_model_id
		 	info[OBJ_ATTR.ACTOR_WEAPON_APPEARANCE]= weaponpos_id
		 	info[OBJ_ATTR.ACTOR_WING_APPEARANCE] = wing_model

		 	self.role_display:SetRoleVo(info)
		end

		local path_id = act_cfg.config.GiftLevels[level].res_id or 1
		local path1 = ResPath.GetActivityBrilliant("act_56_name_bg"..path_id)
		local path2 = ResPath.GetBigPainting("act_56_text_bg"..path_id, false)
		self.node_t_list.img_name_text.node:loadTexture(path1)
		self.node_t_list.img_bg_1.node:loadTexture(path2)

		local zs_lv = act_cfg.config.GiftLevels[level].zslv or 0
		local show_jieshu = math.ceil(zs_lv / ZsVipView.ENUM_JIE)
		if show_jieshu == 0 then
			show_jieshu = 1
		end

		local curr_e_lv = zs_lv % ZsVipView.ENUM_JIE
		if curr_e_lv == 0 and zs_lv > 0 then
			curr_e_lv = ZsVipView.ENUM_JIE
		end
		self.node_t_list.img_lv_56.node:loadTexture(ResPath.GetZsVip("txt_" .. show_jieshu))
		self.node_t_list.img_level_56.node:loadTexture(ResPath.GetZsVip("hz_" .. curr_e_lv))

		local inx = act_cfg.config.GiftLevels[level].path_level  or 1

		self.node_t_list.img_path1.node:loadTexture(ResPath.GetBigPainting("act_56_show_bg".. inx))
		self.node_t_list.img_show1.node:loadTexture(ResPath.GetBigPainting("act_56_desc_bg".. inx))
		-- self.node_t_list.img_bg_1.node:setPosition(578, 177)
		-- self.node_t_list.img_show1.node:setPosition(450, 249)
		
		self.node_t_list.layout_ms_show.node:setPosition(370, 435)
		self.node_t_list.img_path1.node:setPositionX(130)
		if inx == 6 then
			self.node_t_list.img_path1.node:setPositionX(110)
		end
		self.node_t_list.img_show1.node:setPositionX(430)
		if inx == 1 then
			self.node_t_list.img_show1.node:setPositionX(280)
		end
		-- if inx ==  6 then
		
		-- end

	end

end

function NewMsGiftView:OnClickBuyHandler( )
	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.MSGIFT)
	if nil == cfg then return end
	local act_id = ACT_ID.MSGIFT
 	local level = ActivityBrilliantData.Instance:GetMSGIFTLevel()
	ActivityBrilliantCtrl.Instance.ActivityReq(4, act_id, level)
end