EquipmentSoulStoneTipView = EquipmentSoulStoneTipView or BaseClass(XuiBaseView)

function EquipmentSoulStoneTipView:__init()
	self.is_modal = false
	self.can_penetrate = true
	self.texture_path_list[1] = 'res/xui/equipment.png'
	self.config_tab = {
		{"equipment_ui_cfg", 7, {0}},
	}
	self.equip_data = nil 
	
	--self.hunshi_info_event = GlobalEventSystem:Bind(SoulStoneEventType.GET_MY_SOUL_STONE_INFO, BindTool.Bind(self.OnFlushHunShi, self))
end

function EquipmentSoulStoneTipView:__delete()
end

function EquipmentSoulStoneTipView:ReleaseCallBack()
	if self.roledata_change_callback ~= nil then
		RoleData.Instance:UnNotifyAttrChange(self.roledata_change_callback)
		self.roledata_change_callback = nil
	end
end

function EquipmentSoulStoneTipView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self.node_t_list["btn_up_level"].node:addClickEventListener(BindTool.Bind(self.UpLevel, self))
		self.roledata_change_callback = BindTool.Bind1(self.RoleDataChangeCallback,self)
		RoleData.Instance:NotifyAttrChange(self.roledata_change_callback)	
		self.node_t_list.layout_soul_tip.node:setPosition(460, 300)
	end
end

function EquipmentSoulStoneTipView:OpenCallBack()
	
	AudioManager.Instance:PlayOpenCloseUiEffect()	
end

function EquipmentSoulStoneTipView:ShowIndexCallBack(index)
	self:Flush(index)
end

function EquipmentSoulStoneTipView:CloseCallBack(is_all)
	
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function EquipmentSoulStoneTipView:SetData(data)
	self.equip_data = data
	self:Flush()
end

function EquipmentSoulStoneTipView:OnFlush(param_t, index)
	-- for k, v in pairs(param_t) do
	-- 	if k == "all" then
	-- 		self.equip_data = v
	-- 		self:OnFlushHunShi()
	-- 	end
	-- end
	self:OnFlushHunShi()
end

function EquipmentSoulStoneTipView:OnFlushHunShi()
	if self.equip_data == nil then return end
	self.diamond_pos = self.equip_data.index
	self.equip_slots_pos = self.equip_data.pos
	if self.diamond_pos ~= nil and self.equip_slots_pos ~= nil then
		local data = EquipmentData.Instance:GetDiamondData()
		local level = data[self.equip_slots_pos+1].diamond_level[self.diamond_pos]
		local bool_open = data[self.equip_slots_pos+1].bool_open[self.diamond_pos]
		local path = nil
		path = ResPath.GetEquipment("longzhu_"..self.diamond_pos.."_".. level)
		self.node_t_list.img_bg_1.node:loadTexture(path)
		local next_level = (level+1) <= 15 and (level + 1) or 15 
		local path_2 = ResPath.GetEquipment("longzhu_"..self.diamond_pos.."_"..next_level)
		self.node_t_list.img_bg_2.node:loadTexture(path_2)
		-- self.node_t_list.txt_soul_stone_level.node:setString(level)
		local cur_cfg = EquipmentData.GetDiamondAttrCfg(self.diamond_pos, level)
		local next_cfg = EquipmentData.GetDiamondAttrCfg(self.diamond_pos, level +1)
		local txt = "" 
		local txt_1 = ""
		self.node_t_list.txt_type.node:setString(Language.Equipment.Name_activate[self.diamond_pos])
		txt = string.format(Language.Equipment.Name_4[self.diamond_pos], level)
		txt_1 = string.format(Language.Equipment.Name_4[self.diamond_pos], next_level)
		self.node_t_list.txt_name_1.node:setString(txt)
		self.node_t_list.txt_name_2.node:setString(txt_1)

		if next_cfg == nil then
			current_content = RoleData.FormatRoleAttrStr(cur_cfg, is_range)
			next_content = {Language.Equipment.Max_level}
		else
			current_content = RoleData.FormatRoleAttrStr(cur_cfg, is_range)
			next_content = RoleData.FormatRoleAttrStr(next_cfg, is_range)
		end
		self.node_t_list.layout_soul_tip.layout_hunshi["attr_title1"].node:setString(current_content[1] and current_content[1].type_str.. "：" or next_content[1].type_str.. "：")
		self.node_t_list.layout_soul_tip.layout_hunshi["cur_attr1"].node:setString(current_content[1] and current_content[1].value_str or 0)
		self.node_t_list.layout_soul_tip.layout_hunshi["nex_attr1"].node:setString(next_content[1] and next_content[1].value_str or next_content[1])
		local count = EquipmentData.GetSoulStoneCfg(level + 1)  
		local had_own = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_DIAMOND_CRYSTAL)
		if count ~= nil then
			self.node_t_list.layout_had_count.txt_consume_soul.node:setString(count)
			self.node_t_list.layout_had_count.node:setVisible(true)
			self.node_t_list["txt_max_level"].node:setVisible(false)
			XUI.SetButtonEnabled(self.node_t_list["btn_up_level"].node, true)
			-- if had_own >= count then
			-- 	XUI.SetButtonEnabled(self.node_t_list["btn_up_level"].node, true)
			-- else
			-- 	XUI.SetButtonEnabled(self.node_t_list["btn_up_level"].node, false)
			-- end
		else
			self.node_t_list.layout_had_count.node:setVisible(false)
			self.node_t_list["txt_max_level"].node:setVisible(true)
			XUI.SetButtonEnabled(self.node_t_list["btn_up_level"].node, false)
		end
	end
end

function EquipmentSoulStoneTipView:UpLevel()
	if IS_ON_CROSSSERVER then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.OnCrossServerTip)
		return 
	end	
	if self.diamond_pos ~= nil and self.equip_slots_pos ~= nil then
		--EquipmentCtrl.Instance:SendUpgradeDiamondReq(0, self.equip_slots_pos, self.diamond_pos, 0, 0)
	end
end

function EquipmentSoulStoneTipView:RoleDataChangeCallback(key, value)
	if key == OBJ_ATTR.ACTOR_DIAMOND_CRYSTA then
		self:Flush()
	end
end