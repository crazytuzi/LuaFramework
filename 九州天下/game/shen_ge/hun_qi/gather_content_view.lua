GatherContentView = GatherContentView or BaseClass(BaseRender)

local EFFECT_CD = 1

-- local AdjustIndexTable = {
-- 	[0] = 1,
-- 	[1] = 0,
-- 	[2] = 3,
-- 	[3] = 2,
-- }

function GatherContentView:__init()

	self.select_hunqi_index = 0								--选择的魂器index
	-- self.select_kapai_index = 0								--选择的卡牌index

	self.model_display = self:FindObj("ModelDisplay")		--模型
	self.select_icon = self:FindObj("SelectImg")					-- 已经选择的模型特效
	self.effect_display_img = self:FindObj("DisplayImg")
	-- self.cost_text = self:FindVariable("CostText")					--消耗描述
	self.power = self:FindVariable("Power")							--战斗力
	self.hunqi_name = self:FindVariable("HunQiName")				--魂器名字
	self.hunqi_level = self:FindVariable("HunqiLevel")				--魂器等级
	self.skill_info_des = self:FindVariable("SkillInfoNum")			--神器描述
	self.skill_level_dec = self:FindVariable("SkillLevelDec")		--技能等级描述
	self.select_soul_icon = self:FindVariable("SeleSoulIcon")		--选择的魂类
	self.display_img = self:FindVariable("GatherDisplayImg")		--形象img
	self.is_max = self:FindVariable("IsMax")
	self.cost_des = self:FindVariable("CostText")
	self.cost_des1 = self:FindVariable("CostText1")
	self.ShowNotAttrTips = self:FindVariable("ShowNotAttrTips")

	self.cell_list = {}
	self.list_view = self:FindObj("ListView")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetMountNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshMountCell, self)
	self:ListenEvent("ClickFire", BindTool.Bind(self.ClickFire, self))
	self:ListenEvent("ClickAttr", BindTool.Bind(self.ClickAttr, self))
	self:ListenEvent("OnClickHelp", BindTool.Bind(self.ClickHelp, self))
	-- 魂类
	self.soul_list = self:FindObj("SoulList")
	self.soul_item_list = {}
	self.effect = {}
	self.select_effect = {}
	self.effect_name = {[1] = "UI_hunqi_kun",[2] = "UI_hunqi_qian",[3] = "UI_hunqi_yang",[4] = "UI_hunqi_yin",[5] = "UI_hunqi_xuanzhong"}
	for i = 0, HunQiData.SHENZHOU_ELEMET_MAX_TYPE - 1 do
		local obj = self.soul_list.transform:GetChild(i).gameObject
		local soul_cell = HunQiSoulItemCell.New(obj)
		soul_cell:SetIndex(i + 1)
		soul_cell:SetClickCallBack(BindTool.Bind(self.ClickSoulCallBack, self, soul_cell))
		table.insert(self.soul_item_list, soul_cell)
	end

	-- 魂器灵枢属性
	self.pai_attr_value = {}
	self.pai_attr_txt = {}
	for k = 1, 4 do
		self.pai_attr_value[k] = self:FindVariable("attr_" .. k)
		self.pai_attr_txt[k] = self:FindVariable("attr_txt_" .. k)
	end

	self.show_list_red_point = {}
	for i = 0, HunQiData.HUQI_WEAPON_COUNT - 1 do
		self.show_list_red_point[i] = false
 	end

 	self.hunqi_select_effect = {}
	self.hunqi_effect_name = HunQiData.Instance:GetHunqiEffectTab()
	self.position_param = {[1] = Vector3(-30, -10, 0), [2] = Vector3(-20, 40, 0), [3] = Vector3(0, 0, 0),
                            [4] = Vector3(-20, 0, 0), [5] = Vector3(-20, -20, 0),[6] = Vector3(-30, -30, 0),
                            [7] = Vector3(-20, -20, 0), [8] = Vector3(2, -12, 0)}
end

function GatherContentView:__delete()
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end

	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	for _, v in ipairs(self.soul_item_list) do
		v:DeleteMe()
	end
	self.soul_item_list = {}

	for k, v in pairs(self.hunqi_select_effect) do
		if v ~= nil then
			GameObject.Destroy(v)
			v = nil
		end
	end
end


function GatherContentView:FlushModel()
	if nil == self.model then
		self.model = RoleModel.New()
		self.model:SetDisplay(self.model_display.ui3d_display)
	end
	if self.select_hunqi_index > 0 then
		self.is_model_change = true
		local res_id = HunQiData.Instance:GetHunQiResIdByIndex(self.select_hunqi_index-1)
		-- local asset, bunble = ResPath.GetHunQiModel(res_id)

		local icon_id = res_id - 17000
		local res_id = "BigHunQi_" .. icon_id
		self.display_img:SetAsset(ResPath.GetRawImage(res_id))

		-- local function complete_callback()
		-- 	self.is_model_change = false
		-- 	if self.model then
		-- 		local is_active_special = HunQiData.Instance:IsActiveSpecial(self.select_hunqi_index)
		-- 		self.model:ShowAttachPoint(AttachPoint.Weapon, not is_active_special)
		-- 		self.model:ShowAttachPoint(AttachPoint.Weapon2, is_active_special)
		-- 	end
		-- end
		-- self.model:SetMainAsset(asset, bunble, complete_callback)
		-- self.model:SetModelTransformParameter(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.HUNQI], tonumber(bunble), DISPLAY_PANEL.FULL_PANEL)
	else
		-- self.model:ClearModel()
	end
end


--改变模型特效
function GatherContentView:FlushModelEffect()
	if not self.is_model_change then
		if self.model then
			local is_active_special = HunQiData.Instance:IsActiveSpecial(self.select_hunqi_index)
			self.model:ShowAttachPoint(AttachPoint.Weapon, not is_active_special)
			self.model:ShowAttachPoint(AttachPoint.Weapon2, is_active_special)
		end
	end
end

function GatherContentView:FlushSoulAttr(attr_data,next_attr_info)
	local result_data, flag = HunQiData.Instance:GetSloatAndSortAttr(attr_data,next_attr_info)
	self.ShowNotAttrTips:SetValue(flag)
	local count = 1
	for k = 1, 4 do
		self.pai_attr_value[k]:SetValue("")
		self.pai_attr_txt[k]:SetValue("")
	end

	for k,v in pairs(result_data) do
		for v1, v2 in pairs(v) do
			self.pai_attr_txt[count]:SetValue(v1)
			self.pai_attr_value[count]:SetValue(tostring(v2))
		end
		count = count + 1
		if count > 4 then
			break
		end
	end

	local item_cfg = ItemData.Instance:GetItemConfig(attr_data.up_level_item.item_id)
	self.hunqi_name:SetValue(item_cfg.name)
end


function GatherContentView:FlushCostDes()
	local hunqi_list = HunQiData.Instance:GetHunQiList()
	if nil == hunqi_list then
		return
	end

	local element_level_list = hunqi_list[self.select_hunqi_index].element_level_list
	if nil == element_level_list then
		return
	end
	for k, v in ipairs(self.soul_item_list) do
		if v:GetIndex() == self.select_soul_index then
			v:SetToggleState(true)
		else
			v:SetToggleState(false)
		end
		v:SetData({parent_index = self.select_hunqi_index, parent_level = hunqi_list[self.select_hunqi_index].weapon_level, level = element_level_list[k]})
	end
end

function GatherContentView:FlushRightView()
	--设置魂器名字
	local hunqi_name, color_num = HunQiData.Instance:GetHunQiNameAndColorByIndex(self.select_hunqi_index - 1)
	local color = ITEM_COLOR[color_num]
	hunqi_name = ToColorStr(hunqi_name, color)
	local hunqiLevel = HunQiData.Instance:GetHunQiLevelByIndex(self.select_hunqi_index - 1)
	local skill_info = HunQiData.Instance:GetSkillInfoByIndex(self.select_hunqi_index - 1, hunqiLevel)
	self.hunqi_name:SetValue(hunqi_name)
	self.hunqi_level:SetValue(string.format(Language.HunQi.HunQiLevel,hunqiLevel))
	self.skill_level_dec:SetValue(skill_info.skill_dec)
	--设置战斗力
	-- local capability = HunQiData.Instance:GetHunQiCapability(self.select_hunqi_index)
	-- self.power:SetValue(capability)
	-- --设置消耗描述
	self:FlushCostDes()
end

function GatherContentView:InitView()
	self.select_hunqi_index = 1
	self.select_soul_index = 1
	self:FlushModel()
	self:FlushModelEffect()
	self:FlushRightView()
	self:FlushRight()
 	self:FlushSoulEffect()
 	self:FlushSelectIconEffect()
 	self:FlushListRedPoint()
 	self:OnClickListCell(0)
end

function GatherContentView:FlushView()
	self:FlushRightView()
	self:FlushModelEffect()
	self:FlushRight()
	self:FlushListRedPoint()
    if self.select_hunqi_index <= 5 then
        self.list_view.scroller:ReloadData(0)
    else
        self.list_view.scroller:ReloadData(1)
    end
end

function GatherContentView:GetMountNumberOfCells()
	return #HunQiData.Instance:GetHunQiName()
end

function GatherContentView:RefreshMountCell(cell, cell_index)
	local hunqi_cfg = HunQiData.Instance:GetHunQiName()				--大表
	local mount_cell = self.cell_list[cell]
	if mount_cell == nil then
		mount_cell = GatherHunQiItemCell.New(cell.gameObject)
		self.cell_list[cell] = mount_cell
	end
	mount_cell:SetToggleGroup(self.list_view.toggle_group)
	mount_cell:SetHighLight(self.select_hunqi_index == cell_index + 1)
	mount_cell:SetData(hunqi_cfg[cell_index + 1])
	mount_cell:SetRedPointState(self.show_list_red_point[cell_index])
	mount_cell:ListenClick(BindTool.Bind(self.OnClickListCell, self, cell_index))
end

function GatherContentView:OnClickListCell(cell_index)
	self.select_hunqi_index = cell_index + 1
	self.select_soul_index = 1
 	self:FlushModel()
 	self:FlushRightView()
	self:FlushSoulEffect()
	self:FlushRight()

	for i = 1, HunQiData.HUQI_WEAPON_COUNT do
 		self:HunQiSelectEffect(i == self.select_hunqi_index, i, self.hunqi_effect_name[i])
 	end
end

function GatherContentView:ClickSoulCallBack(cell)
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
	self:FlushSoulEffect()
end

function GatherContentView:FlushSelectIconEffect()
	for i = 1, 4 do
		self:ShowSelectImgEffect(false,i,self.effect_name[i])
	end
end
function GatherContentView:FlushSoulEffect()
	-- 重置
	for i = 1, 4 do
		self.soul_item_list[i]:ShowSelectEffect(i == self.select_soul_index, i, self.effect_name[5])
 		-- self.soul_item_list[i]:ShowEffect(i ~= self.select_soul_index, i, self.effect_name[i])
 		self:ShowSelectImgEffect(i == self.select_soul_index, i, self.effect_name[i])
	end
end


-- 炼魂
function GatherContentView:ClickFire()
	--local true_index = AdjustIndexTable[self.select_soul_index - 1]
	HunQiCtrl.Instance:SendHunQiOperaReq(SHENZHOU_REQ_TYPE.SHENZHOU_REQ_TYPE_UPLEVEL_ELEMENT, self.select_hunqi_index - 1, self.select_soul_index - 1)
end

function GatherContentView:FlushRight()
	local hunqi_data_list = HunQiData.Instance:GetHunQiList()
	if nil == hunqi_data_list then
		return
	end
	local select_hunqi_index = self.select_hunqi_index
	local select_soul_index = self.select_soul_index

	local res_id = "SoulIcon" .. select_soul_index
	self.select_soul_icon:SetAsset(ResPath.GetHunQiImg(res_id))

	local element_level_list = hunqi_data_list[select_hunqi_index].element_level_list
	if nil == element_level_list then
		return
	end
	local select_soul_level = element_level_list[select_soul_index] or 0
	local attr_info = HunQiData.Instance:GetSoulAttrInfo(select_hunqi_index - 1, select_soul_index - 1, select_soul_level)

	if nil == attr_info then
		return
	end
	attr_info = attr_info[1]
	local next_attr_info = HunQiData.Instance:GetSoulAttrInfo(select_hunqi_index - 1, select_soul_index - 1, select_soul_level + 1)
	if nil == next_attr_info then
		self:FlushSoulAttr(attr_info)
	else
		self:FlushSoulAttr(attr_info, next_attr_info[1])
	end

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

	-- self.now_attr_des:SetValue(attr_des)
	-- self.attr_res:SetAsset(ResPath.GetBaseAttrIcon(attr_type))

	--设置当前属性战斗力
	local capability = CommonDataManager.GetCapability(attr_ibutte)
	self.power:SetValue(capability)

	--设置当前属性百分比
	-- self.now_special_attr:SetValue(string.format("%.1f", attr_info.attr_add_per/100))

	if nil == next_attr_info then
		self.cost_des1:SetValue("")
		-- self.show_icon_img:SetValue(false)
		self.is_max:SetValue(true)
	else
		next_attr_info = next_attr_info[1] or next_attr_info
		self.is_max:SetValue(false)
		--设置下级增加属性
		local next_attr_num = next_attr_info[attr_type] or 0
		local up_attr_num = next_attr_num - attr_num

		--设置消耗显示
		local cost_des = ""
		local huqi_level_limit = attr_info.huqi_level_limit
		if huqi_level_limit > hunqi_data_list[select_hunqi_index].weapon_level then
			-- self.show_icon_img:SetValue(false)
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
			cost_des = string.format(Language.HunQi.NeedCostDes, ToColorStr(item_name, item_color), now_num_str, cost_num)
			self.current_item_id = item_data.item_id
		end
		self.cost_des:SetValue(cost_des)
	end
end

function GatherContentView:ShowSelectImgEffect(flag, show_index, effect_name)
	if nil == self.select_effect[show_index] then
		PrefabPool.Instance:Load(AssetID("effects2/prefab/ui/" .. string.lower(effect_name) .. "_prefab", effect_name), function (prefab)
			if not prefab or self.select_effect[show_index] then return end
			local obj = GameObject.Instantiate(prefab)
			PrefabPool.Instance:Free(prefab)
			local transform = obj.transform
			transform:SetParent(self.select_icon.transform, false)
			self.select_effect[show_index] = obj.gameObject
			self.is_loading = false
			self.select_effect[show_index]:SetActive(flag)
		end)
	else
		self.select_effect[show_index]:SetActive(flag)
	end
end

function GatherContentView:HunQiSelectEffect(flag, show_index, effect_name)
	if nil == self.hunqi_select_effect[show_index] then
		PrefabPool.Instance:Load(AssetID("effects2/prefab/ui/horcruxescontent/" .. string.lower(effect_name) .. "_prefab", effect_name), function (prefab)
			if not prefab or self.hunqi_select_effect[show_index] then return  end
			local obj = GameObject.Instantiate(prefab)
			PrefabPool.Instance:Free(prefab)
			local transform = obj.transform
			transform:SetParent(self.effect_display_img.transform, false)
			transform.localPosition = self.position_param[show_index]		--暂时写死特效的位置
			transform.localScale = Vector3(0.5, 0.5, 0.5)
			self.hunqi_select_effect[show_index] = obj.gameObject
			self.is_loading = false
			self.hunqi_select_effect[show_index]:SetActive(flag)
		end)
	else
		self.hunqi_select_effect[show_index]:SetActive(flag)
	end
end

function GatherContentView:FlushListRedPoint()
	local hunqi_list = HunQiData.Instance:GetHunQiList()
	if nil == hunqi_list then
		return
	end

	--判断是否显示红点
	for i = 0, HunQiData.HUQI_WEAPON_COUNT - 1 do
		self.show_list_red_point[i] = false
 	end
	-- 魂器
 	for i = 0, HunQiData.HUQI_WEAPON_COUNT - 1 do
 		local element_level_list = hunqi_list[i + 1].element_level_list
		if nil == element_level_list then
			return
		end
 		for k = 1, 4 do
 			local next_attr_info = HunQiData.Instance:GetSoulAttrInfo(i, k - 1, element_level_list[k] + 1)
			if nil ~= next_attr_info then
			 	local attr_info = HunQiData.Instance:GetSoulAttrInfo(i, k - 1, element_level_list[k])
				if nil == attr_info then
					return
				end
				attr_info = attr_info[1]
				if hunqi_list[i + 1].weapon_level >= attr_info.huqi_level_limit then
					local up_level_item = attr_info.up_level_item
					local have_num = ItemData.Instance:GetItemNumInBagById(up_level_item.item_id)
					if have_num >= up_level_item.num then
						self.show_list_red_point[i] = true
					end
				end
			end
 		end
 	end
end

function GatherContentView:ClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(231)
end

function GatherContentView:ClickAttr()
	local attr_list = HunQiData.Instance:GetAllElementAttrInfo(self.select_hunqi_index)
	local result_data = HunQiData.Instance:GetSloatAttr(attr_list)
	-- 没有激活任何魂器聚魂
	if nil == next(result_data) then
		local attr_list = HunQiData.Instance:GetAllElementAttrOneInfo(self.select_hunqi_index)
		result_data = HunQiData.Instance:GetNextSloatAttr(attr_list)
	end
	--HunQiCtrl.Instance:OpenTotalAttrTipView(result_data,attr_list)
	TipsCtrl.Instance:OpenGeneralView(attr_list)
end
----------------------------------------
GatherHunQiItemCell = GatherHunQiItemCell or BaseClass(BaseRender)

function GatherHunQiItemCell:__init()
	-- self.icon = self:FindVariable("Icon")
	self.name = self:FindVariable("Name")
	self.name_hl = self:FindVariable("Name_HL")
	self.show_red_ponit = self:FindVariable("ShowRedPoint")
	self.itemImg = self:FindVariable("ItemImg")
	self.index = 0
end

function GatherHunQiItemCell:__delete()
	self.icon = nil
	self.name = nil
	self.show_red_ponit = nil
end

function GatherHunQiItemCell:SetData(data)
	if data == nil then
		return
	end

 	local icon_id = data.res_id - 17000
	local res_id = "HunQi_" .. icon_id
	self.itemImg:SetAsset(ResPath.GetHunQiImg(res_id))
	local name_str = data.name

	self.name:SetValue(name_str)
	self.name_hl:SetValue(name_str)
	-- self.show_red_ponit:SetValue(data.is_show)
	self.index = data.index
end

function GatherHunQiItemCell:ListenClick(handler)
	self:ClearEvent("Click")
	self:ListenEvent("Click", handler)
end

function GatherHunQiItemCell:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end

function GatherHunQiItemCell:SetHighLight(enable)
	self.root_node.toggle.isOn = enable
end

function GatherHunQiItemCell:SetRedPointState(state)
	self.show_red_ponit:SetValue(state)
end

-------------------------------HunQiSoulItemCell------------------------------------------
HunQiSoulItemCell = HunQiSoulItemCell or BaseClass(BaseCell)
function HunQiSoulItemCell:__init()
	self.level = self:FindVariable("Level")
	self.icon_res = self:FindVariable("IconRes")
	self.show_red_point = self:FindVariable("ShowRedPoint")
	self.is_active = self:FindVariable("IsActive")
	self.effect_icon = self:FindObj("effect_icon")
	self.effect = {}
	self.select_effect = {}
	self.effect_name = {[1] = "UI_hunqi_kun",[2] = "UI_hunqi_qian",[3] = "UI_hunqi_yang",[4] = "UI_hunqi_yin",[5] = "UI_hunqi_xuanzhong"}
	self:ListenEvent("Click", BindTool.Bind(self.OnClick, self))
end

function HunQiSoulItemCell:__delete()
	for k, v in pairs(self.select_effect) do
		v = nil
	end
	for k, v in pairs(self.effect) do
		v = nil
	end
end

function HunQiSoulItemCell:OnFlush()
	if nil == self.data then
		return
	end
	self.level:SetValue(self.data.level)
	--设置是否已激活
	self.is_active:SetValue(self.data.level > 0)

	--判断是否显示红点
	local next_attr_info = HunQiData.Instance:GetSoulAttrInfo(self.data.parent_index-1, self.index-1, self.data.level+1)
	if nil == next_attr_info then
		self.show_red_point:SetValue(false)
	else
		local attr_info = HunQiData.Instance:GetSoulAttrInfo(self.data.parent_index-1, self.index-1, self.data.level)
		if nil == attr_info then
			return
		end
		attr_info = attr_info[1]
		if self.data.parent_level >= attr_info.huqi_level_limit then
			local up_level_item = attr_info.up_level_item
			local have_num = ItemData.Instance:GetItemNumInBagById(up_level_item.item_id)
			if have_num >= up_level_item.num then
				self.show_red_point:SetValue(true)
			else
				self.show_red_point:SetValue(false)
			end

		else
			self.show_red_point:SetValue(false)
		end
	end
	self:ShowEffect(true,self.index,self.effect_name[self.index])
end


function HunQiSoulItemCell:ShowEffect(flag, show_index, effect_name)
	if nil == self.effect[show_index] then
		PrefabPool.Instance:Load(AssetID("effects2/prefab/ui/" .. string.lower(effect_name) .. "_prefab", effect_name), function (prefab)
			if not prefab or self.effect[show_index] then return end
			local obj = GameObject.Instantiate(prefab)
			PrefabPool.Instance:Free(prefab)
			local transform = obj.transform
			transform:SetParent(self.effect_icon.transform, false)
			self.effect[show_index] = obj.gameObject
			self.is_loading = false
			self.effect[show_index]:SetActive(flag)
		end)
	else
		self.effect[show_index]:SetActive(flag)
	end
end

function HunQiSoulItemCell:ShowSelectEffect(flag, show_index, effect_name)
	if nil == self.select_effect[show_index] then
		PrefabPool.Instance:Load(AssetID("effects2/prefab/ui/" .. string.lower(effect_name) .. "_prefab", effect_name), function (prefab)
			if not prefab or self.select_effect[show_index] then return end
			local obj = GameObject.Instantiate(prefab)
			PrefabPool.Instance:Free(prefab)
			local transform = obj.transform
			transform:SetParent(self.effect_icon.transform, false)
			self.select_effect[show_index] = obj.gameObject
			self.is_loading = false
			self.select_effect[show_index]:SetActive(flag)
		end)
	else
		self.select_effect[show_index]:SetActive(flag)
	end
end

function HunQiSoulItemCell:SetToggleState(state)
	self.root_node.toggle.isOn = state
end
