LuxuryGiftView = LuxuryGiftView or BaseClass(ActBaseView)

function LuxuryGiftView:__init(view, parent, act_id)
	self:LoadView(parent)
end

function LuxuryGiftView:__delete()
	if self.cell_list then 
		for i,v in ipairs(self.cell_list) do
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

function LuxuryGiftView:InitView()
	--self.node_t_list.btn_go_charge.node:addClickEventListener(BindTool.Bind(self.OnClickGoChargeHandler, self))
	self.node_t_list.btn_lingqu.node:addClickEventListener(BindTool.Bind(self.OnClickLingquHandler, self))

	if nil == self.effect_show1 then
		local ph = self.ph_list.ph_act_eff
	 	self.effect_show1 = AnimateSprite:create()
	 	self.effect_show1:setPosition(ph.x + 15, ph.y + 5)
	 	self.node_t_list.layout_luxury_gift.node:addChild(self.effect_show1, 999)
	end

	if nil == self.role_display then
		self.role_display = RoleDisplay.New(self.node_t_list.layout_luxury_gift.node, 100, false, false, true, true)
		local ph = self.ph_list.ph_act_eff
		self.role_display:SetPosition(ph.x + 10,ph.y + 100)
		self.role_display:SetScale(0.8)
	end

end

function LuxuryGiftView:CreateCells(num)
	if nil == self.cell_list or nil == self.cell_list[1] then 
		self.cell_list = {}
		local top = math.floor(num / 2)
		local size = 85
		local ph = self.ph_list.ph_show_cell
		local mid = (1 + top) / 2
		for i = 1, top do
			local cell = BaseCell.New()
			cell:SetPosition(ph.x + (i - mid) * size, ph.y + size / 2)
			cell:SetAnchorPoint(0.5, 0.5)
			self.node_t_list.layout_luxury_gift.node:addChild(cell:GetView(), 300)
			table.insert(self.cell_list, cell)
		end
		local mid = (1 + num - top) / 2
		for i = 1, num - top do
			local cell = BaseCell.New()
			cell:SetPosition(ph.x + (i - mid) * size, ph.y - size / 2)
			cell:SetAnchorPoint(0.5, 0.5)
			self.node_t_list.layout_luxury_gift.node:addChild(cell:GetView(), 300)
			table.insert(self.cell_list, cell)
		end
	end
end

function LuxuryGiftView:RefreshView(param_list)
	local data = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.HHDL)
	if data and data.config then
		local cfg = data.config
		--self.node_t_list.img_act_des.node:loadTexture(ResPath.GetActivityBrilliant("act_69_des_"..cfg.des_id))
		-- local ph = self.ph_list.ph_act_eff
		-- local effect_id = cfg.effect_id or 414
		-- local act_effect = RenderUnit.CreateEffect(effect_id, self.node_t_list.layout_luxury_gift.node, 999)
		-- act_effect:setPosition(ph.x, ph.y)
		local charge_money = ActivityBrilliantData.Instance:GetTotalCharge()
		local cur_grade = ActivityBrilliantData.Instance:GetCurGrade()
		local index = table.getn(cfg.ChargeLevels) >= cur_grade and cur_grade or table.getn(cfg.ChargeLevels)
		if cfg.ChargeLevels[index] then 
			local awards = cfg.ChargeLevels[index].award
			local money = cfg.ChargeLevels[index].paymoney
			self.node_t_list.btn_lingqu.node:setVisible(true)
			self.node_t_list.img_stamp.node:setVisible(false)
			if charge_money < money then 
				self.node_t_list.btn_lingqu.node:setEnabled(true)
				self.node_t_list.btn_lingqu.node:setTitleText(Language.Common.Recharge)
				self.node_t_list.prog9_charge.node:setPercent(charge_money/money * 100)
			else
				self.node_t_list.prog9_charge.node:setPercent(100)
				if index < cur_grade then 
					self.node_t_list.btn_lingqu.node:setVisible(false)
					self.node_t_list.img_stamp.node:setVisible(true)
				else
					self.node_t_list.btn_lingqu.node:setEnabled(true)
					self.node_t_list.btn_lingqu.node:setTitleText(Language.Common.LingQu)
				end
			end
			local anim_path, anim_name = ResPath.GetEffectUiAnimPath(cfg.ChargeLevels[index].effect_id or cfg.effect_id)
			self.effect_show1:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)


			local effect_id = cfg.ChargeLevels[index].effect_id or 7
			local effect_type = cfg.ChargeLevels[index].effect_type  or 1
			local role_data =  cfg.ChargeLevels[index].role_model_effect  or {}
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
			local str = string.format(Language.ActivityBrilliant.HasChargeFormat2, charge_money >= money and COLORSTR.GREEN or COLORSTR.RED, charge_money, money)
			RichTextUtil.ParseRichText(self.node_t_list.rich_charge_money.node, str, 18)
			XUI.RichTextSetCenter(self.node_t_list.rich_charge_money.node)
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
		end
	end
end

function LuxuryGiftView:OnClickLingquHandler()
	local data = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.HHDL)
	if data and data.config then
		local cfg = data.config 
		local charge_money = ActivityBrilliantData.Instance:GetTotalCharge()
		local cur_grade = ActivityBrilliantData.Instance:GetCurGrade()
		local index = table.getn(cfg.ChargeLevels) >= cur_grade and cur_grade or table.getn(cfg.ChargeLevels)
		if cfg.ChargeLevels[index] then 
			local money = cfg.ChargeLevels[index].paymoney
			if charge_money < money then 
				ViewManager.Instance:OpenViewByDef(ViewDef.ZsVip.Recharge)
				ActivityBrilliantCtrl.Instance:CloseView(self.act_id)
			else
				ActivityBrilliantCtrl.Instance.ActivityReq(4, ACT_ID.HHDL)
			end

		end

	end
	
end

