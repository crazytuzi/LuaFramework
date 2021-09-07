GatherSoulView = GatherSoulView or BaseClass(BaseView)
-------------------------------------------------------
-------------------------------------------------------
----------------------废弃不用-------------------------
-------------------------------------------------------
-------------------------------------------------------
function GatherSoulView:__init()
	self.ui_config = {"uis/views/hunqiview", "GatherSoulView"}
	self.soul_item_list = {}
	self.hunqi_item_list = {}
end

function GatherSoulView:ReleaseCallBack()
	for _, v in ipairs(self.soul_item_list) do
		v:DeleteMe()
	end
	self.soul_item_list = {}

	for _, v in ipairs(self.hunqi_item_list) do
		v:DeleteMe()
	end
	self.hunqi_item_list = {}

	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end

	self.soul_list = nil
	self.hunqi_list = nil
	self.model_display = nil
	self.hunqi_name = nil
	self.is_max = nil
	self.cost_des = nil
	self.now_attr_des = nil
	self.next_attr = nil
	self.power = nil
	self.now_special_attr = nil
	self.next_special_attr = nil
	self.have_next_perattr = nil
	self.now_level = nil
	self.next_level = nil
	self.attr_res = nil
	self.cost_des1 = nil
	self.icon_img = nil
	self.show_icon_img = nil
end

function GatherSoulView:LoadCallBack()
	self.soul_list = self:FindObj("SoulList")
	self.soul_item_list = {}
	for i = 0, HunQiData.SHENZHOU_ELEMET_MAX_TYPE-1 do
		local obj = self.soul_list.transform:GetChild(i).gameObject
		local soul_cell = HunQiSoulItemCell.New(obj)
		soul_cell:SetIndex(i+1)
		soul_cell:SetClickCallBack(BindTool.Bind(self.ClickSoulCallBack, self))
		table.insert(self.soul_item_list, soul_cell)
	end

	self.hunqi_list = self:FindObj("HunQiList")
	self.hunqi_item_list = {}
	for i = 0, HunQiData.SHENZHOU_WEAPON_COUNT-1 do
		local obj = self.hunqi_list.transform:GetChild(i).gameObject
		local equip_cell = SoulEquipItemCell.New(obj)
		equip_cell:SetIndex(i+1)
		equip_cell:SetClickCallBack(BindTool.Bind(self.ClickHunQiCallBack, self))
		table.insert(self.hunqi_item_list, equip_cell)
	end

	self.model_display = self:FindObj("ModelDisplay")

	self.hunqi_name = self:FindVariable("HunQiName")
	self.is_max = self:FindVariable("IsMax")
	self.cost_des = self:FindVariable("CostDes")
	self.cost_des1 = self:FindVariable("CostDes1")
	self.icon_img = self:FindVariable("icon_img")
	self.show_icon_img = self:FindVariable("show_icon_img")
	self.now_attr_des = self:FindVariable("NowAttrDes")
	self.next_attr = self:FindVariable("NextAttr")
	self.power = self:FindVariable("Power")
	self.now_special_attr = self:FindVariable("NowSpecialAttr")
	self.next_special_attr = self:FindVariable("NextSpecialAttr")
	self.have_next_perattr = self:FindVariable("HaveNextPerAttr")
	self.now_level = self:FindVariable("NowLevel")
	self.next_level = self:FindVariable("NextLevel")
	self.attr_res = self:FindVariable("AttrRes")

	self:ListenEvent("Close", BindTool.Bind(self.CloseWindow, self))
	self:ListenEvent("ClickFire", BindTool.Bind(self.ClickFire, self))
	self:ListenEvent("ClickAttr", BindTool.Bind(self.ClickAttr, self))
	self:ListenEvent("ClickHun", BindTool.Bind(self.ClickHun, self))
	self:ListenEvent("OnClickHelp", BindTool.Bind(self.ClickHelp, self))
end

function GatherSoulView:ClickSoulCallBack(cell)
	if nil == cell then
		return
	end
	cell:SetToggleState(true)
	local index = cell:GetIndex()
	if index == self.select_soul_index then
		return
	end
	self.select_soul_index = index

	self:FlushRight()
end

function GatherSoulView:ClickHunQiCallBack(cell)
	if nil == cell then
		return
	end
	cell:SetToggleState(true)
	local index = cell:GetIndex()
	if index == self.select_hunqi_index then
		return
	end
	self.select_hunqi_index = index

	self.select_soul_index = 1
	self:FlushSoulList()
	self:FlushRight()
	self:FlushModel()
end

function GatherSoulView:CloseWindow()
	self:Close()
end

function GatherSoulView:ClickFire()
	HunQiCtrl.Instance:SendHunQiOperaReq(SHENZHOU_REQ_TYPE.SHENZHOU_REQ_TYPE_UPLEVEL_ELEMENT, self.select_hunqi_index-1, self.select_soul_index-1)
end

function GatherSoulView:ClickAttr()
	HunQiCtrl.Instance:ShowSoulAttrView(self.select_hunqi_index)
end

function GatherSoulView:ClickHun()
	TipsCtrl.Instance:OpenItem({item_id = self.current_item_id})
end

function GatherSoulView:OpenCallBack()
	self.select_hunqi_index = 1
	self.select_soul_index = 1

	self:FlushHunQiList()
	self:FlushSoulList()
	self:FlushRight()
	self:FlushModel()

	--监听物品变化
	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
end

function GatherSoulView:CloseCallBack()
	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
end

function GatherSoulView:ItemDataChangeCallback(item_id)
	--炼魂物品变化
	for _, v in ipairs(HunQiData.ElementItemList) do
		if item_id == v then
			self:Flush()
			return
		end
	end
end

function GatherSoulView:FlushHunQiList()
	local hunqi_data_list = HunQiData.Instance:GetHunQiList()
	if nil == hunqi_data_list then
		return
	end
	for k, v in ipairs(self.hunqi_item_list) do
		if v:GetIndex() == self.select_hunqi_index then
			v:SetToggleState(true)
		else
			v:SetToggleState(false)
		end
		v:SetData(hunqi_data_list[k])
	end
end

function GatherSoulView:FlushSoulList()
	local hunqi_data_list = HunQiData.Instance:GetHunQiList()
	if nil == hunqi_data_list then
		return
	end
	local hunqi_name, color_num = HunQiData.Instance:GetHunQiNameAndColorByIndex(self.select_hunqi_index-1)
	local color = ITEM_COLOR[color_num]
	local name_str = ToColorStr(hunqi_name, color)
	self.hunqi_name:SetValue(name_str)

	local element_level_list = hunqi_data_list[self.select_hunqi_index].element_level_list
	if nil == element_level_list then
		return
	end
	for k, v in ipairs(self.soul_item_list) do
		if v:GetIndex() == self.select_soul_index then
			v:SetToggleState(true)
		else
			v:SetToggleState(false)
		end
		v:SetData({parent_index = self.select_hunqi_index, parent_level = hunqi_data_list[self.select_hunqi_index].weapon_level, level = element_level_list[k]})
	end
end

function GatherSoulView:FlushRight()
	local hunqi_data_list = HunQiData.Instance:GetHunQiList()
	if nil == hunqi_data_list then
		return
	end
	local select_hunqi_index = self.select_hunqi_index
	local select_soul_index = self.select_soul_index
	local element_level_list = hunqi_data_list[select_hunqi_index].element_level_list
	if nil == element_level_list then
		return
	end
	local select_soul_level = element_level_list[select_soul_index] or 0
	local attr_info = HunQiData.Instance:GetSoulAttrInfo(select_hunqi_index-1, select_soul_index-1, select_soul_level)
	if nil == attr_info then
		return
	end
	attr_info = attr_info[1]
	local next_attr_info = HunQiData.Instance:GetSoulAttrInfo(select_hunqi_index-1, select_soul_index-1, select_soul_level+1)
	--设置当前属性
	local attr_des = ""
	local attr_ibutte = CommonDataManager.GetAttributteNoUnderline(attr_info)
	local attr_type = ""
	local attr_num = 0
	if select_soul_level == 0 then
		if nil ~= next_attr_info then
			next_attr_info = next_attr_info[1]
			local next_attr_ibutte = CommonDataManager.GetAttributteNoUnderline(next_attr_info)
			for k, v in pairs(next_attr_ibutte) do
				if v > 0 then
					attr_type = k
					break
				end
			end
		end
	else
		for k, v in pairs(attr_ibutte) do
			if v > 0 then
				attr_type = k
				attr_num = v
				break
			end
		end
	end
	local attr_name = CommonDataManager.GetAttrName(attr_type)
	attr_des = attr_name .. ":" .. attr_num
	self.now_attr_des:SetValue(attr_des)
	self.attr_res:SetAsset(ResPath.GetBaseAttrIcon(attr_type))

	--设置当前属性战斗力
	local capability = CommonDataManager.GetCapability(attr_ibutte)
	self.power:SetValue(capability)

	--设置当前属性百分比
	self.now_special_attr:SetValue(string.format("%.1f", attr_info.attr_add_per/100))

	if nil == next_attr_info then
		self.cost_des:SetValue("")
		self.cost_des1:SetValue("")
		self.show_icon_img:SetValue(false)
		self.is_max:SetValue(true)
	else
		next_attr_info = next_attr_info[1] or next_attr_info
		self.is_max:SetValue(false)
		--设置下级增加属性
		local next_attr_num = next_attr_info[attr_type] or 0
		local up_attr_num = next_attr_num - attr_num
		self.next_attr:SetValue(up_attr_num)

		--设置下级增加属性百分比
		local next_add_attr_info = HunQiData.Instance:GetNextAddAttrInfo(select_hunqi_index-1, select_soul_index-1, select_soul_level)
		if nil ~= next_add_attr_info then
			next_add_attr_info = next_add_attr_info[1]
			self.have_next_perattr:SetValue(true)
			local next_add_percent_num = string.format("%.1f", next_add_attr_info.attr_add_per/100)
			self.next_special_attr:SetValue(next_add_percent_num)
			self.now_level:SetValue(select_soul_level)
			local next_level = next_add_attr_info.element_level
			self.next_level:SetValue(next_level)
		else
			self.have_next_perattr:SetValue(false)
		end

		--设置消耗显示
		local cost_des = ""
		local huqi_level_limit = attr_info.huqi_level_limit
		if huqi_level_limit > hunqi_data_list[select_hunqi_index].weapon_level then
			self.show_icon_img:SetValue(false)
			self.cost_des1:SetValue("")
			cost_des = string.format(Language.HunQi.NeedHunQiLevelDes, hunqi_data_list[select_hunqi_index].weapon_level, huqi_level_limit)
		else
			local item_data = attr_info.up_level_item
			local item_id = item_data.item_id or 0
			local item_cfg = ItemData.Instance:GetItemConfig(item_id)
			if nil == item_cfg then
				return
			end
			local item_name = item_cfg.name or ""
			local item_color = ITEM_COLOR[item_cfg.color] or TEXT_COLOR.WHITE
			local now_num = ItemData.Instance:GetItemNumInBagById(item_id)
			local cost_num = item_data.num or 0
			local now_num_str = now_num
			if now_num < cost_num then
				now_num_str = ToColorStr(now_num, TEXT_COLOR.RED_1)
			end
			self.cost_des:SetValue(Language.HunQi.NeedCostDes1)
			cost_des = string.format(Language.HunQi.NeedCostDes1, ToColorStr(item_name, item_color), now_num_str, cost_num)
			self.current_item_id =  item_data.item_id
			self.show_icon_img:SetValue(true)
			self.icon_img:SetAsset(ResPath.GetHunQiImg("SoulIcon"..select_soul_index))
			if now_num < 1 then
				self.cost_des1:SetValue("<color=yellow>(<color=red>"..now_num.."</color>/"..cost_num..")</color>")
			else
				self.cost_des1:SetValue("<color=yellow>(<color=green>"..now_num.."</color>/"..cost_num..")</color>")
			end
		end
		self.cost_des:SetValue(cost_des)
	end
end

function GatherSoulView:FlushModel()
	if nil == self.model then
		self.model = RoleModel.New()
		self.model:SetDisplay(self.model_display.ui3d_display)
	end
	if self.select_hunqi_index > 0 then
		self.is_model_change = true
		local res_id = HunQiData.Instance:GetHunQiResIdByIndex(self.select_hunqi_index-1)
		local asset, bunble = ResPath.GetHunQiModel(res_id)
		local function complete_callback()
			self.is_model_change = false
			if self.model then
				local is_active_special = HunQiData.Instance:IsActiveSpecial(self.select_hunqi_index)
				self.model:ShowAttachPoint(AttachPoint.Weapon, false)
				self.model:ShowAttachPoint(AttachPoint.Weapon2, true)
			end
		end
		self.model:SetMainAsset(asset, bunble, complete_callback)
		self.model:SetModelTransformParameter(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.HUNQI], tonumber(bunble), DISPLAY_PANEL.JUHUN)
	else
		self.model:ClearModel()
	end
end

--改变模型特效
function GatherSoulView:FlushModelEffect()
	if not self.is_model_change then
		if self.model then
			local is_active_special = HunQiData.Instance:IsActiveSpecial(self.select_hunqi_index)
			self.model:ShowAttachPoint(AttachPoint.Weapon,  false)
			self.model:ShowAttachPoint(AttachPoint.Weapon2, true)
		end
	end
end

function GatherSoulView:OnFlush()
	self:FlushHunQiList()
	self:FlushSoulList()
	self:FlushRight()
	-- self:FlushModelEffect()
end

function GatherSoulView:ClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(231)
end

-------------------------------HunQiSoulItemCell------------------------------------------
-- HunQiSoulItemCell = HunQiSoulItemCell or BaseClass(BaseCell)
-- function HunQiSoulItemCell:__init()
-- 	self.level = self:FindVariable("Level")
-- 	self.icon_res = self:FindVariable("IconRes")
-- 	self.show_red_point = self:FindVariable("ShowRedPoint")
-- 	self.is_active = self:FindVariable("IsActive")

-- 	self:ListenEvent("Click", BindTool.Bind(self.OnClick, self))
-- end

-- function HunQiSoulItemCell:__delete()

-- end

-- function HunQiSoulItemCell:OnFlush()
-- 	if nil == self.data then
-- 		return
-- 	end

-- 	self.level:SetValue(self.data.level)

-- 	--设置是否已激活
-- 	self.is_active:SetValue(self.data.level > 0)

-- 	--判断是否显示红点
-- 	local next_attr_info = HunQiData.Instance:GetSoulAttrInfo(self.data.parent_index-1, self.index-1, self.data.level+1)
-- 	if nil == next_attr_info then
-- 		self.show_red_point:SetValue(false)
-- 	else
-- 		local attr_info = HunQiData.Instance:GetSoulAttrInfo(self.data.parent_index-1, self.index-1, self.data.level)
-- 		if nil == attr_info then
-- 			return
-- 		end
-- 		attr_info = attr_info[1]
-- 		if self.data.parent_level >= attr_info.huqi_level_limit then
-- 			local up_level_item = attr_info.up_level_item
-- 			local have_num = ItemData.Instance:GetItemNumInBagById(up_level_item.item_id)
-- 			if have_num >= up_level_item.num then
-- 				self.show_red_point:SetValue(true)
-- 			else
-- 				self.show_red_point:SetValue(false)
-- 			end
-- 		else
-- 			self.show_red_point:SetValue(false)
-- 		end
-- 	end
-- end

-- function HunQiSoulItemCell:SetToggleState(state)
-- 	self.root_node.toggle.isOn = state
-- end


-------------------------------SoulEquipItemCell------------------------------------------
SoulEquipItemCell = SoulEquipItemCell or BaseClass(BaseCell)
function SoulEquipItemCell:__init()
	self.icon_res = self:FindVariable("IconRes")
	self.level = self:FindVariable("Level")
	self.show_red_point = self:FindVariable("ShowRedPoint")
	self.is_active = self:FindVariable("IsActive")

	self:ListenEvent("Click", BindTool.Bind(self.OnClick, self))
end

function SoulEquipItemCell:__delete()

end

function SoulEquipItemCell:OnFlush()
	if nil == self.data then
		return
	end

	self.level:SetValue(self.data.weapon_level)

	--设置图标
	local model_res_id = HunQiData.Instance:GetHunQiResIdByIndex(self.index-1)
	local param = model_res_id - 17000
	local res_id = "HunQi_" .. param
	self.icon_res:SetAsset(ResPath.GetHunQiImg(res_id))

	--设置是否已激活
	self.is_active:SetValue(self.data.weapon_level > 0)

	--判断是否显示红点
	local element_level_list = self.data.element_level_list
	local is_show = false
	for k, v in ipairs(element_level_list) do
		local next_attr_info = HunQiData.Instance:GetSoulAttrInfo(self.index-1, k-1, v+1)
		if next_attr_info then
			local attr_info = HunQiData.Instance:GetSoulAttrInfo(self.index-1, k-1, v)
			attr_info = attr_info[1]
			--判断等级是否足够
			if attr_info.huqi_level_limit <= self.data.weapon_level then
				local up_level_item = attr_info.up_level_item
				local have_num = ItemData.Instance:GetItemNumInBagById(up_level_item.item_id)
				if have_num >= up_level_item.num then
					is_show = true
					break
				end
			end
		end
	end
	self.show_red_point:SetValue(is_show)
end

function SoulEquipItemCell:SetToggleState(state)
	self.root_node.toggle.isOn = state
end