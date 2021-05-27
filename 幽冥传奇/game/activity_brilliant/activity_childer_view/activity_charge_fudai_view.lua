ChargeFudaiView = ChargeFudaiView or BaseClass(ActBaseView)

function ChargeFudaiView:__init(view, parent, act_id)
	self:LoadView(parent)
end

function ChargeFudaiView:__delete()
	if self.cell_list then 
		for i,v in ipairs(self.cell_list) do
			v:DeleteMe()
		end
		self.cell_list = {}
	end

	if nil ~= self.fudai_grid then
		self.fudai_grid:DeleteMe()
		self.fudai_grid = nil
	end

	if self.charge_fudai_prog then
		self.charge_fudai_prog:DeleteMe()
		self.charge_fudai_prog = nil
	end
	if self.effect_show1 then
		self.effect_show1:setStop()
		self.effect_show1 = nil
	end
	if self.spare_72_time ~= nil then
		GlobalTimerQuest:CancelQuest(self.spare_72_time)
		self.spare_72_time = nil
	end

	if self.role_display then
		self.role_display:DeleteMe()
		self.role_display = nil
	end
end

function ChargeFudaiView:InitView()
	self.node_t_list["img_text"].node:setVisible(false)

	-- self:CreateFudaiGridScroll()
	self.select_index = 0
	self:CreateFudaiProgressbar()
	--self.node_t_list.btn_go_charge.node:addClickEventListener(BindTool.Bind(self.OnClickGoChargeHandler, self))
	self.node_t_list.layout_charge_fudai.node:setPositionX(362)
	self.node_t_list.btn_lingqu.node:addClickEventListener(BindTool.Bind(self.OnClickLingquHandler, self))

	if nil == self.effect_show1 then
		local ph = self.ph_list.ph_act_eff
	 	self.effect_show1 = AnimateSprite:create()
	 	self.effect_show1:setPosition(ph.x + 15, ph.y + 5)
	 	self.node_t_list.layout_charge_fudai.node:addChild(self.effect_show1, 999)
	end

	if nil == self.role_display then
		self.role_display = RoleDisplay.New(self.node_t_list.layout_charge_fudai.node, 100, false, false, true, true)
		local ph = self.ph_list.ph_act_eff
		self.role_display:SetPosition(ph.x + 10,ph.y + 100)
		self.role_display:SetScale(0.8)
	end
	self.spare_72_time = GlobalTimerQuest:AddRunQuest(BindTool.Bind1(self.UpdateSpareFFTime, self), 1)
end

function ChargeFudaiView:UpdateSpareFFTime()
	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.LCFD)
	if nil == cfg then return end
	local now_time = TimeCtrl.Instance:GetServerTime()
	local end_time = cfg.end_time 
	local spare_time = end_time - now_time 
	self.node_t_list.layout_charge_fudai.lbl_activity72_spare_time.node:setString(TimeUtil.FormatSecond2Str(spare_time))
end

function ChargeFudaiView:CreateCells(num)
	if nil == self.cell_list or nil == self.cell_list[1] or num ~= #self.cell_list then 
		self.cell_list = {}
		local top = math.floor(num / 2)
		local size = 85
		local ph = self.ph_list.ph_show_cell
		local mid = (1 + top) / 2
		for i = 1, top do
			local cell = BaseCell.New()
			cell:SetPosition(ph.x + (i - mid) * size, ph.y + size / 2)
			cell:SetAnchorPoint(0, 0)
			self.node_t_list.layout_charge_fudai.node:addChild(cell:GetView(), 300)
			table.insert(self.cell_list, cell)
		end
		local mid = (1 + num - top) / 2
		for i = 1, num - top do
			local cell = BaseCell.New()
			cell:SetPosition(ph.x + (i - mid) * size, ph.y - size / 2)
			cell:SetAnchorPoint(0, 0)
			self.node_t_list.layout_charge_fudai.node:addChild(cell:GetView(), 300)
			table.insert(self.cell_list, cell)
		end
	end
end

function ChargeFudaiView:CreateFudaiGridScroll(length)
	local ph_shouhun = self.ph_list.ph_fudai_list
	local cell_num = length or 3
	if nil == self.fudai_grid  then
		self.fudai_grid = BaseGrid.New() 
		local grid_node = self.fudai_grid:CreateCells({w = ph_shouhun.w, h = ph_shouhun.h, itemRender = ChargeFudaiRender, ui_config = self.ph_list.ph_charge_fudai_item, cell_count = cell_num, col = cell_num, row = 1})
		self.node_t_list.layout_charge_fudai.node:addChild(grid_node, 300)
		self.fudai_grid:GetView():setPosition(ph_shouhun.x + 38, ph_shouhun.y)
		self.fudai_grid:SetSelectCallBack(BindTool.Bind(self.OnSelectCallBack, self))
	end
end

function ChargeFudaiView:CreateFudaiProgressbar()
	self.charge_fudai_prog = ProgressBar.New()
	self.charge_fudai_prog:SetView(self.node_t_list.prog9_qh_fd.node)
	self.charge_fudai_prog:SetTailEffect(991, nil, true)
	self.charge_fudai_prog:SetEffectOffsetX(0)
	self.charge_fudai_prog:SetPercent(0)
end

function ChargeFudaiView:RefreshView(param_list)
	local data = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.LCFD)
	if data and data.config then
		local cfg = data.config
		if cfg then
			self.node_t_list.lbl_activity_about73.node:setString( data.act_desc or "")
		end
			-- local ph = self.ph_list.ph_act_eff
		-- local effect_id = cfg.effect_id or 414
		local fudai_list = ActivityBrilliantData.Instance:GetFudaiList()
		-- local act_effect = RenderUnit.CreateEffect(effect_id, self.node_t_list.layout_charge_fudai.node, 999)
		-- act_effect:setPosition(ph.x, ph.y)
		local index = 0
		for i,v in ipairs(fudai_list) do
			if v.payday <= v.charge_days then 
				index = i
			end
		end
		if index > 0 and index ~= table.getn(fudai_list) then 
			index = index - 0.5
		end
		self.charge_fudai_prog:SetPercent(index / table.getn(fudai_list) * 100)
		if nil == self.fudai_grid then 
			self:CreateFudaiGridScroll(table.getn(fudai_list))
		end
		if not fudai_list[0] and fudai_list[1] then
			fudai_list[0] = table.remove(fudai_list, 1)
		end
		self.fudai_grid:SetDataList(fudai_list)
		self.fudai_grid:SelectCellByIndex(self:GetJumpToPage(fudai_list))
	end
end

function ChargeFudaiView:FlushAward(index)
	local fudai_list = ActivityBrilliantData.Instance:GetFudaiList()
	local index = index + 1
	if fudai_list and fudai_list[index] then 
		local awards = fudai_list[index].award
		local payday = fudai_list[index].payday
		local charge_days = fudai_list[index].charge_days
		local sign = fudai_list[index].sign
		local awards = fudai_list[index].awards
		self.node_t_list.btn_lingqu.node:setVisible(true)
		self.node_t_list.img_stamp.node:setVisible(false)
		if payday > charge_days then 
			self.node_t_list.btn_lingqu.node:setEnabled(true)
			self.node_t_list.btn_lingqu.node:setTitleText(Language.Common.Recharge)
		else
			if sign == 1 then 
				self.node_t_list.btn_lingqu.node:setVisible(false)
				self.node_t_list.img_stamp.node:setVisible(true)
			else
				self.node_t_list.btn_lingqu.node:setEnabled(true)
				self.node_t_list.btn_lingqu.node:setTitleText(Language.Common.LingQu)
			end
		end
		local charge_days = payday > charge_days and charge_days or payday
		local str = string.format(Language.ActivityBrilliant.HasChargeDayFormat, payday == charge_days and COLORSTR.GREEN or COLORSTR.RED, charge_days, payday)
		RichTextUtil.ParseRichText(self.node_t_list.rich_charge_day.node, str, 20)
		self.node_t_list.rich_charge_day.node:setHorizontalAlignment(RichHAlignment.HA_CENTER)
		local award = {}
		local sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)
		for k, v in pairs(awards) do
			if v.sex == nil or v.sex == sex or v.sex == -1 then
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
		local effect_id = fudai_list[index].effect_id or 7
		local anim_path, anim_name = ResPath.GetEffectUiAnimPath(effect_id)
		self.effect_show1:setAnimate(anim_path, anim_name,  COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)


		local effect_id = fudai_list[index].effect_id or 7
		local effect_type = fudai_list[index].effect_type  or 1
		local role_data =  fudai_list[index].role_model_effect  or {}
		self.role_display:SetVisible(false)
		self.effect_show1:setVisible(false)
		if effect_type == 1 then
			self.effect_show1:setVisible(true)
			local anim_path, anim_name = ResPath.GetEffectUiAnimPath(effect_id)
			self.effect_show1:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
		else
			self.role_display:SetVisible(true)

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

		local img_path = fudai_list[index].img_path or 1

		self.node_t_list.img_text.node:loadTexture(ResPath.GetActivityBrilliant("act_72_text_bg"..img_path))
	end
end

function ChargeFudaiView:GetJumpToPage(data_list)
	-- local page_count = self.fudai_grid:GetPageCount()
	-- PrintTable(data_list)
	-- for i,v in ipairs(data_list) do
	-- 	if v.sign == 0 then
	-- 		print('activity_charge_fudai_view >>>>> line = 148', i);
	-- 		return i
	-- 	end
	-- end
	for i = 0, table.getn(data_list) do
		if data_list[i].sign == 0 then 
			return i
		end
	end
	return table.getn(data_list)
end

function ChargeFudaiView:OnSelectCallBack(item)
	self.select_index = item:GetIndex()
	self:FlushAward(self.select_index)
end

function ChargeFudaiView:OnClickGoChargeHandler()


	
end

function ChargeFudaiView:OnClickLingquHandler()

	local fudai_list = ActivityBrilliantData.Instance:GetFudaiList()
	local index = self.select_index + 1
	if fudai_list and fudai_list[index] then 
		local awards = fudai_list[index].award
		local payday = fudai_list[index].payday
		local charge_days = fudai_list[index].charge_days
		local sign = fudai_list[index].sign
		local awards = fudai_list[index].awards
	
		if payday > charge_days then 
			ViewManager.Instance:OpenViewByDef(ViewDef.ZsVip.Recharge)
			ActivityBrilliantCtrl.Instance:CloseView(self.act_id)
		else
			ActivityBrilliantCtrl.ActivityReq(4, ACT_ID.LCFD, self.select_index + 1)
		end
	end
	
end


ChargeFudaiRender = ChargeFudaiRender or BaseClass(BaseRender)
function ChargeFudaiRender:__init()
	self:AddClickEventListener()
end

function ChargeFudaiRender:__delete()
	if self.num_bar then
		self.num_bar:DeleteMe()
		self.num_bar = nil 
	end
	if self.num_bar1 then
		self.num_bar1:DeleteMe()
		self.num_bar1 = nil 
	end
end

function ChargeFudaiRender:CreateChild()
	BaseRender.CreateChild(self)
	local ph =self.ph_list.ph_number1
	if nil == self.num_bar then
	    self.num_bar = NumberBar.New()
	    self.num_bar:Create(ph.x - 6, ph.y - 8, 0, 0, ResPath.GetActivityBrilliant("act_2_money_"))
	    self.num_bar:SetSpace(-8)
	     self.num_bar:SetScale(0.8)
	    self.view:addChild(self.num_bar:GetView(), 101)
	end

	local ph = self.ph_list.ph_number2
	if nil == self.num_bar1 then
	    self.num_bar1 = NumberBar.New()
	    self.num_bar1:Create(ph.x - 6, ph.y - 8, 0, 0, ResPath.GetActivityBrilliant("act_2_money_"))
	    self.num_bar1:SetSpace(-8)
	    self.num_bar1:SetScale(0.5)
	   self.view:addChild(self.num_bar1:GetView(), 101)
	end 
end

function ChargeFudaiRender:OnFlush()
	if nil == self.data then return end
	self.node_tree.img_award_1.node:setGrey(self.data.sign ~= 0)
	self.node_tree.img_charge_reward_1.node:setVisible(self.data.sign == 1)

	local can_lingqu = self.data.charge_days >= self.data.payday 
	if can_lingqu and self.data.sign == 0 then
		local fade_in = cc.FadeIn:create(0.3)
		local fade_out = cc.FadeOut:create(0.8)
		local sequence = cc.Sequence:create(fade_in,fade_out)
		local forever = cc.RepeatForever:create(sequence)
		self.node_tree.img_remind_flag_1.node:setVisible(true)
		self.node_tree.img_remind_flag_1.node:runAction(forever)
	else
		self.node_tree.img_remind_flag_1.node:setVisible(false)
	end

	local text = self.data.payday >= self.data.charge_days and self.data.charge_days or self.data.payday 
	self.num_bar:SetNumber(text)
	self.num_bar1:SetNumber(self.data.payday)
	self.num_bar:SetScale(0.7)
	self.num_bar1:SetScale(0.7)
	--self.node_tree.lbl_43_num.node:setString(text .."/"..self.data.payday)
end

function ChargeFudaiRender:CreateSelectEffect()
	local size = self.view:getContentSize()
	self.select_effect = XUI.CreateImageViewScale9(size.width/2 - 9, size.height/2,95, 95, ResPath.GetActivityBrilliant("fudai_select_effect"), true)
	if nil == self.select_effect then
		ErrorLog("BaseRender:CreateSelectEffect fail")
		return
	end
	self.view:addChild(self.select_effect, 999)
end