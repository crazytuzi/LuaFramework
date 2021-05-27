------------------------------------------------------------
--人物相关主View
------------------------------------------------------------
GemStoneUpView = GemStoneUpView or BaseClass(XuiBaseView)

function GemStoneUpView:__init()
	-- self.view_name = GuideModuleName.GemStoneUpView
	-- self:SetHasCommonBag(true)
	self.is_any_click_close = true
	self:SetModal(true)

	self.config_tab = {
		
		{"equipment_ui_cfg", 7, {0}},

	}
	self.diamond_pos = nil
	self.equipment_pos = nil 
end

function GemStoneUpView:__delete()

end

function GemStoneUpView:ReleaseCallBack()
	--清理页面生成信息
	if nil ~= self.cur_show_cell then
		self.cur_show_cell:DeleteMe()
		self.cur_show_cell = nil 
	end

	if nil ~= self.next_show_cell then
		self.next_show_cell:DeleteMe()
		self.next_show_cell = nil 
	end
	if self.gem_info_change then
		GlobalEventSystem:UnBind(self.gem_info_change)
		self.gem_info_change = nil
	end

	-- if self.roledata_change_callback then
	-- 	RoleData.Instance:UnNotifyAttrChange(self.roledata_change_callback)
	-- 	self.roledata_change_callback = nil 
	-- end
end

function GemStoneUpView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:CreateCells()
		XUI.AddClickEventListener(self.node_t_list.btn_up_level.node, BindTool.Bind1(self.OnUpDiamond, self), true)
		self.gem_info_change = GlobalEventSystem:Bind(SoulStoneEventType.GET_MY_SOUL_STONE_INFO, BindTool.Bind(self.FlushGemInfo, self))
		-- self.roledata_change_callback = BindTool.Bind1(self.RoleDataChangeCallback, self)           -- 监听物品数据变化
		-- RoleData.Instance:NotifyAttrChange(self.roledata_change_callback)

		self.node_t_list.layout_gem_hook["btn_gem_checkbox"].node:addClickEventListener(BindTool.Bind(self.OnClickGemAuto, self))
		self.node_t_list.layout_gem_hook["img_gem_hook"].node:setVisible(GemStoneData.Instance:GetBoolUseGold() == 1)
	end
end

function GemStoneUpView:OnClickGemAuto()
	local vis = self.node_t_list.layout_gem_hook["img_gem_hook"].node:isVisible()
	GemStoneData.Instance:SetBoolUseGold(vis and 0 or 1)	
	self.node_t_list.layout_gem_hook["img_gem_hook"].node:setVisible(not vis)
end

-- function GemStoneUpView:RoleDataChangeCallback(key, value)
-- 	if key == OBJ_ATTR.ACTOR_DIAMOND_CRYSTAL then
-- 		self:Flush()
-- 	end
-- end

function GemStoneUpView:FlushGemInfo()
	self:Flush()
end

function GemStoneUpView:CreateCells()
	if self.cur_show_cell == nil then
		local ph = self.ph_list.ph_img_bg_1
		self.cur_show_cell = BaseCell.New()
		self.cur_show_cell:SetPosition(ph.x, ph.y)
		self.cur_show_cell:GetView():setAnchorPoint(0, 0)
		self.node_t_list.layout_soul_tip.node:addChild(self.cur_show_cell:GetView(), 100)
	end

	if self.next_show_cell == nil then
		local ph = self.ph_list.ph_img_bg_2
		self.next_show_cell = BaseCell.New()
		self.next_show_cell:SetPosition(ph.x, ph.y)
		self.next_show_cell:GetView():setAnchorPoint(0, 0)
		self.node_t_list.layout_soul_tip.node:addChild(self.next_show_cell:GetView(), 100)
	end
end

function GemStoneUpView:OpenCallBack()
	--self.tabbar:ChangeToIndex(self.show_index, self.root_node)
end

function GemStoneUpView:ShowIndexCallBack(index)
	self:Flush(index)
end

function GemStoneUpView:CloseCallBack()
	GemStoneData.Instance:SetBoolUseGold(0)
	if self.node_t_list.layout_gem_hook["img_gem_hook"] then
		self.node_t_list.layout_gem_hook["img_gem_hook"].node:setVisible(false)
	end
end

function GemStoneUpView:SetData(equipment_pos, diamond_pos)
	self.equipment_pos = equipment_pos
	self.diamond_pos = diamond_pos
	self:Flush()
end

function GemStoneUpView:OnFlush(param_t, index)
	if self.equipment_pos ~= nil and self.diamond_pos ~= nil then
		local data = EquipmentData.Instance:GetDiamondDataByEquipSlots(self.equipment_pos + 1)
		local level = data and data.diamond_level[self.diamond_pos] or 0
		local cur_id = data and data.item_id[self.diamond_pos] or 0
		local next_level = level + 1
		local consume_t, next_Id = GemStoneData.Instance:GetSoulStoneCfg(self.diamond_pos, level)
		local txt_1 = string.format(Language.Equipment.Name_3[self.diamond_pos], level)
		local txt_2 = ""
		if consume_t == nil  then
			txt_2 = ""
			self.node_t_list.layout_consume_count.node:setVisible(false)
			self.node_t_list.txt_max_level.node:setVisible(true)
			self.node_t_list.txt_had_soul.node:setString("")
			self.node_t_list.txt_consume_soul.node:setString("")
		else
			txt_2 = string.format(Language.Equipment.Name_3[self.diamond_pos], next_level)
			self.node_t_list.layout_consume_count.node:setVisible(true)
			self.node_t_list.txt_max_level.node:setVisible(false)
			local id = consume_t.id 
			local num = ItemData.Instance:GetItemNumInBagById(id, nil)
			local config = ItemData.Instance:GetItemConfig(id)
			local name = config.name
			local txt = string.format(Language.Equipment.Gem_Had, name, num)
			self.node_t_list.txt_had_soul.node:setString(txt)
			local txt_1 = string.format(Language.Equipment.Gem_Had, name, consume_t.count)
			self.node_t_list.txt_consume_soul.node:setString(txt_1)
		end
		local bool_max = false
		local us_gold_txt = ""
		local money = GemStoneData.Instance:GetMoney(self.diamond_pos, level)
		if money ~= nil then
			bool_max = true
			local money_name = Language.Equipment.Money_type[money.type]
			local money_count = money.count
			us_gold_txt = string.format(Language.Equipment.BoolUseGold, money_count)
		end
		self.node_t_list.layout_gem_hook.node:setVisible(bool_max)
		self.node_t_list.rich_gem_yunbao.node:setVisible(bool_max)
		RichTextUtil.ParseRichText(self.node_t_list.rich_gem_yunbao.node, us_gold_txt)
		self.node_t_list.txt_name_1.node:setString(txt_1)
		self.node_t_list.txt_name_2.node:setString(txt_2)
		if next_Id == nil then
			next_Id = cur_id
		end
		self.cur_show_cell:SetData({item_id = cur_id,num == 1, is_bind = 0})
		self.next_show_cell:SetData({item_id = next_Id,num == 1, is_bind = 0})
		local cfg = ItemData.Instance:GetItemConfig(cur_id)
		local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
		if cfg ~= nil then
			local attr_cfg = cfg and cfg.staitcAttrs or {}
			local attr_t = RoleData.FormatRoleAttrStr(attr_cfg, is_range)
			self.node_t_list.attr_title1.node:setString(attr_t[1] and attr_t[1].type_str or "")
			self.node_t_list.cur_attr1.node:setString(attr_t[1] and attr_t[1].value_str or "")
		end
		
		-- local attr_t = RoleData.Instance:GetGodZhuEquipAttr(attr_cfg, prof)
		local next_cfg = ItemData.Instance:GetItemConfig(next_Id)
		if next_cfg ~= nil then
			local attr_cfg = next_cfg and next_cfg.staitcAttrs or {}
			local attr_t = RoleData.FormatRoleAttrStr(attr_cfg, is_range)
			self.node_t_list.nex_attr1.node:setString(attr_t[1] and attr_t[1].value_str or "")
		else
			self.node_t_list.nex_attr1.node:setString(Language.Common.MaxLvTips)
		end
		local txt = string.format(Language.Equipment.Name_4[self.diamond_pos], level)
		self.node_t_list.txt_type.node:setString(txt)

		--txt_had_soul
	end
end

function GemStoneUpView:OnUpDiamond()
	if self.equipment_pos ~= nil and self.diamond_pos ~= nil then
		local data = EquipmentData.Instance:GetDiamondDataByEquipSlots(self.equipment_pos + 1)
		local level = data and data.diamond_level[self.diamond_pos] or 0
		local consume_t, next_Id = GemStoneData.Instance:GetSoulStoneCfg(self.diamond_pos, level)
		if consume_t ~= nil then
			local bool_use_gold = GemStoneData.Instance:GetBoolUseGold()
			if bool_use_gold == 0 then
				local id = consume_t.id 
				local num = ItemData.Instance:GetItemNumInBagById(id, nil)
				if num >= consume_t.count then
					EquipmentCtrl.Instance:SendUpgradeDiamondReq(0, self.equipment_pos, self.diamond_pos, 0, bool_use_gold)
				else
					local config = ItemData.Instance:GetItemConfig(id)
					local sub_num = consume_t.count - num
					local txt = string.format(Language.Equipment.SuB_Desc, GuideColorCfg[config.bgquality]or"ffffff", config.name, sub_num)
					SysMsgCtrl.Instance:FloatingTopRightText(txt)
				end
			else
				EquipmentCtrl.Instance:SendUpgradeDiamondReq(0, self.equipment_pos, self.diamond_pos, 0, bool_use_gold)
			end
		else
			SysMsgCtrl.Instance:FloatingTopRightText(Language.Common.MaxLvTips)
		end
	end
end