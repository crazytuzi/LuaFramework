
-- 烈焰神力
FireGodPowerView = FireGodPowerView or BaseClass(BaseView)

function FireGodPowerView:__init()
	self:SetModal(true)
	self.texture_path_list = {
		'res/xui/godfurnace.png',
	}
	self.config_tab = {
		{"common2_ui_cfg", 1, {0}},
		{"common2_ui_cfg", 2, {0}, nil, 999},
		{"god_furnace_ui_cfg", 2, {0}},
	}
	self.gf_data = GodFurnaceData.Instance
end

function FireGodPowerView:__delete()
end

function FireGodPowerView:ReleaseCallBack()
	if self.progress then
		self.progress:DeleteMe()
		self.progress = nil
	end

	if self.consume_list then
		self.consume_list:DeleteMe()
		self.consume_list = nil
	end

	self.max_txt = nil
	self:RemoveAnimation()
	if self.fire_effect and self.fire_effect.removeFromParent then
		self.fire_effect:stopAllActions()
		self.fire_effect:removeFromParent()
		self.fire_effect = nil
	end
end

function FireGodPowerView:LoadCallBack(index, loaded_times)
	self:CreateTopTitle(ResPath.GetGodFurnace("word_lysl"), 275, 695)

	-- 按钮
	self.node_t_list.btn_opt.node:setTitleText("灌注印记")
	self.node_t_list.btn_opt.node:setTitleFontName(COMMON_CONSTS.FONT)
	self.node_t_list.btn_opt.node:setTitleFontSize(22)
	self.node_t_list.btn_opt.node:setTitleColor(COLOR3B.G_W2)
	XUI.AddClickEventListener(self.node_t_list.btn_opt.node, BindTool.Bind(self.OnClickOpt, self))

	self.progress = ProgressBar.New()
	self.progress:SetView(self.node_t_list.prog9_god_val.node)

	-- 消耗物品列表
	local ph = self.ph_list.ph_list
	self.consume_list = ListView.New()
	self.consume_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, FireGodPowerView.ConsumeItemRender)
	self.node_t_list.layout_fire_gp.node:addChild(self.consume_list:GetView(), 999)
	local consumes = self.gf_data:GetGFImprintItemList()
	self.consume_list:SetDataList(consumes)
	self.consume_list:GetView():setContentSize(cc.size(#consumes * 90, ph.h))

	-- 获取材料
	if not IS_AUDIT_VERSION then
		self.link_stuff = RichTextUtil.CreateLinkText("获取印记", 20, COLOR3B.GREEN)
		self.link_stuff:setPosition(410, 5)
		self.node_t_list.layout_fire_gp.node:addChild(self.link_stuff, 99)
		XUI.AddClickEventListener(self.link_stuff, BindTool.Bind(self.OnClickLinkStuff, self), true)
	end
	self.cur_effect_id = 0

	-- 事件
	local gf_data_proxy = EventProxy.New(self.gf_data, self)
	gf_data_proxy:AddEventListener(GodFurnaceData.GOD_POWER_LEVEL_CHANGE, BindTool.Bind(self.OnGodPowerLevelChange, self))
	gf_data_proxy:AddEventListener(GodFurnaceData.GOD_POWER_VAL_CHANGE, BindTool.Bind(self.OnGodPowerValChange, self))
    EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagItemChange, self))
    EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.RoleDataChangeCallback, self))
    self:CreateAnimation()
end

function FireGodPowerView:RoleDataChangeCallback(vo)
	if vo.key == OBJ_ATTR.ACTOR_FLAMINTAPPEARANCEID then
		self:RemoveAnimation()
		self:CreateAnimation()
	end
end

function FireGodPowerView:OpenCallBack()
end

function FireGodPowerView:CloseCallBack(is_all)
end

function FireGodPowerView:ShowIndexCallBack(index)
	self:Flush()
end

function FireGodPowerView:OnFlush(param_t, index)
	local prof = prof or RoleData.Instance:GetRoleBaseProf()

	local level = self.gf_data:GetGodPowerlevel()
	local cur_val = self.gf_data:GetGodPowerVal()
	local need_val = self.gf_data:FireGodSkillNextConsume(level) or self.gf_data:FireGodSkillNextConsume(level - 1)
	local is_max = nil == need_val
	local percent = (not is_max) and (cur_val / need_val * 100) or (100)
	self.progress:SetPercent(percent)
	self.node_t_list.lbl_fire_prog.node:setString(cur_val .. "/" .. need_val)

	local cur_attr, next_attr = self.gf_data:FireGodSkillAttrCfg(level)
	local rich_param = {
		type_str_color = COLOR3B.OLIVE,
		value_str_color = COLOR3B.OLIVE
	}

	-- 无属性时显示0
	if nil == cur_attr then
		local zero_attr
		if nil ~= next_attr then
			zero_attr = DeepCopy(next_attr)
			for k, v in pairs(zero_attr) do
				for _, v1 in pairs(v) do
					v.value = 0
				end
			end
		end
		cur_attr = zero_attr
	end

	RichTextUtil.ParseRichText(self.node_t_list.rich_cur_attr.node, cur_attr and RoleData.FormatAttrContent(cur_attr, rich_param) or "")
	RichTextUtil.ParseRichText(self.node_t_list.rich_next_attr.node, next_attr and RoleData.FormatAttrContent(next_attr, rich_param) or "")

	local is_max = nil == next_attr
	if is_max and nil == self.max_txt then
		self.max_txt = XUI.CreateText(317, 273, 300, 26, cc.TEXT_ALIGNMENT_LEFT, "已经是最高级了", nil, 24, COLOR3B.YELLOW)
		self.node_t_list.layout_fire_gp.node:addChild(self.max_txt, 99)
		self.max_txt:setAnchorPoint(0, 0.5)
	elseif nil ~= self.max_txt then
		self.max_txt:setVisible(is_max)	
	end

	local skill_info = self.gf_data:GetFireGodSkillInfo(level, prof)
	RichTextUtil.ParseRichText(self.node_t_list.rich_skill_name.node, skill_info.name)
	RichTextUtil.ParseRichText(self.node_t_list.rich_skill_desc.node, skill_info.desc)

	self:FlushConsumeItems()
end

function FireGodPowerView:OnClickLinkStuff()
	local item_id = GodFurnaceData.Instance:GetGFImprintItemList()[1].item_id
	local ways = CLIENT_GAME_GLOBAL_CFG.item_get_ways[item_id]
	local data = string.format("{reward;0;%d;1}", item_id) .. (ways and ways or "")
	TipCtrl.Instance:OpenBuyTip(data)
end

function FireGodPowerView:CreateAnimation()
	local new_effect_id = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_FLAMINTAPPEARANCEID)
	if new_effect_id == 0 then
		new_effect_id = 359
	end
	if self.cur_effect_id ~= new_effect_id then
		if self.fire_effect and self.fire_effect.removeFromParent then
			self.fire_effect:removeFromParent()
			self.fire_effect = nil
		end
		self.cur_effect_id = new_effect_id
		self.fire_effect = RenderUnit.CreateEffect(self.cur_effect_id, self.node_t_list.layout_fire_gp.node, 999, nil, nil, self.ph_list.ph_start_pos.x, self.ph_list.ph_start_pos.y)
	end
	self:PlayMoveAnimation()
end

function FireGodPowerView:PlayMoveAnimation()
	if self.explosion_eff then
		self.explosion_eff:removeFromParent()
		self.explosion_eff = nil
	end
	if self.fly_eff then
		self.fly_eff:removeFromParent()
		self.fly_eff = nil
	end
	if self.atk_eff then
		self.atk_eff:removeFromParent()
		self.atk_eff = nil
	end
	local anim_path, anim_name = ResPath.GetEffectAnimPath(100)
	self.atk_eff = RenderUnit.CreateAnimSprite(anim_path, anim_name, nil, 1)
	self.atk_eff:setPosition(self.ph_list.ph_start_pos.x, self.ph_list.ph_start_pos.y)
	self.node_t_list.layout_fire_gp.node:addChild(self.atk_eff, 99)
	anim_path, anim_name = ResPath.GetEffectAnimPath(104)
	self.fly_eff = RenderUnit.CreateAnimSprite(anim_path, anim_name)
	self.fly_eff:setPosition(self.ph_list.ph_start_pos.x, self.ph_list.ph_start_pos.y)
	self.fly_eff:setRotation(120)
	local move_to = cc.MoveTo:create(0.4, cc.p(self.ph_list.ph_end_pos.x, self.ph_list.ph_end_pos.y))
	local move_sequence = cc.Sequence:create(move_to, cc.CallFunc:create(BindTool.Bind(self.PlayExplosionAnimation, self)))
	self.node_t_list.layout_fire_gp.node:addChild(self.fly_eff, 99)
	self.fly_eff:runAction(move_sequence)
end

function FireGodPowerView:PlayExplosionAnimation()
	if self.fly_eff then
		self.fly_eff:removeFromParent()
		self.fly_eff = nil
	end
	if self.explosion_eff then
		self.explosion_eff:removeFromParent()
		self.explosion_eff = nil
	end
	local anim_path, anim_name = ResPath.GetEffectAnimPath(105)
	self.explosion_eff = RenderUnit.CreateAnimSprite(anim_path, anim_name, nil, 1)
	self.explosion_eff:setPosition(self.ph_list.ph_end_pos.x, self.ph_list.ph_end_pos.y)
	local explosion_sequence = cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(BindTool.Bind(self.PlayMoveAnimation, self)))
	self.node_t_list.layout_fire_gp.node:addChild(self.explosion_eff, 99)
	self.node_t_list.layout_fire_gp.node:runAction(explosion_sequence)
end

function FireGodPowerView:RemoveAnimation()
	self.node_t_list.layout_fire_gp.node:stopAllActions()
	if self.explosion_eff and self.explosion_eff.removeFromParent then
		self.explosion_eff:stopAllActions()
		self.explosion_eff:removeFromParent()
		self.explosion_eff = nil
	end
	if self.fly_eff and self.fly_eff.removeFromParent then
		self.fly_eff:stopAllActions()
		self.fly_eff:removeFromParent()
		self.fly_eff = nil
	end
	if self.atk_eff and self.atk_eff.removeFromParent then
		self.atk_eff:stopAllActions()
		self.atk_eff:removeFromParent()
		self.atk_eff = nil
	end
end

--------------------------------------------------------------
function FireGodPowerView:OnGodPowerValChange()
	self:Flush()
end

function FireGodPowerView:OnGodPowerLevelChange()
	self:Flush()
end

function FireGodPowerView:OnBagItemChange()
	self:Flush()
end

function FireGodPowerView:OnClickOpt()
	local select_item = self.consume_list:GetSelectItem()
	if nil ~= select_item then
		local item_id = select_item:GetData().item_id
		local bag_num = BagData.Instance:GetItemNumInBagById(item_id)
		if bag_num > 0 then
			GodFurnaceCtrl.SendGFAddGodPowerReq({item_id})
		else
			if IS_AUDIT_VERSION then
				GodFurnaceCtrl.SendGodFurnaceUpReq(self.select_slot)
			else
				self:OnClickLinkStuff()
			end	
			
		end
	else
		if IS_AUDIT_VERSION then
				GodFurnaceCtrl.SendGodFurnaceUpReq(self.select_slot)
			else
				self:OnClickLinkStuff()
			end	
	end
end

function FireGodPowerView:FlushConsumeItems()
	self.consume_list:RefreshCurItems()

	-- 自动选择可消耗的格子
	local select_item = self.consume_list:GetSelectItem()
	if nil == select_item or not select_item:CanSelectToConsume() then
		for k, v in pairs(self.consume_list:GetAllItems()) do
			if v:CanSelectToConsume() then
				self.consume_list:SelectIndex(k)
				break
			end
		end
	end
end
-----------------------------------------------------------------
FireGodPowerView.ConsumeItemRender = BaseClass(BaseRender)
local ConsumeItemRender = FireGodPowerView.ConsumeItemRender
ConsumeItemRender.size = cc.size(80, 80)
function ConsumeItemRender:__init()
	self.view:setContentSize(ConsumeItemRender.size)
	self.animation_pos = {
			start_pos = {100, 200},
			end_pos = {200, 250},
		}
end

function ConsumeItemRender:__delete()
	if self.cell then
		self.cell:DeleteMe()
		self.cell = nil
	end
end

function ConsumeItemRender:CreateChild()
	ConsumeItemRender.super.CreateChild(self)

	self.cell = BaseCell.New()
	self.cell:SetPosition(ConsumeItemRender.size.width / 2, 22)
	self.cell:SetAnchorPoint(0.5, 0)
	self.cell:SetIsShowTips(false)
	self.cell:SetScale(0.8)
	self.view:addChild(self.cell:GetView(), 10)

	self.rich_under = XUI.CreateRichText(ConsumeItemRender.size.width / 2, 0, 300, 20)
	XUI.RichTextSetCenter(self.rich_under)
	self.rich_under:setAnchorPoint(0.5, 0)
	self.view:addChild(self.rich_under, 10)
end

function ConsumeItemRender:OnFlush()
	local item_data = CommonStruct.ItemDataWrapper()
	item_data.item_id = self.data.item_id
	self.cell:SetData(item_data)

	local bag_num = BagData.Instance:GetItemNumInBagById(self.data.item_id)
	RichTextUtil.ParseRichText(self.rich_under, bag_num, 20, bag_num > 0 and COLOR3B.GREEN or COLOR3B.RED)
end

function ConsumeItemRender:CanSelectToConsume()
	if nil == self.data then
		return false
	end

	local bag_num = BagData.Instance:GetItemNumInBagById(self.data.item_id)
	return bag_num > 0
end

function ConsumeItemRender:CreateSelectEffect()
	local size = self.view:getContentSize()
	self.select_effect = XUI.CreateImageViewScale9(size.width / 2, 22 + (BaseCell.SIZE / 2) * 0.8, BaseCell.SIZE * 0.8, BaseCell.SIZE * 0.8, ResPath.GetCommon("img9_120"), true)
	if nil == self.select_effect then
		ErrorLog("BaseRender:CreateSelectEffect fail")
		return
	end

	self.view:addChild(self.select_effect, 999)
end

return FireGodPowerView
