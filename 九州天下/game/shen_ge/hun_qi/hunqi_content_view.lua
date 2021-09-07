HunQiContentView = HunQiContentView or BaseClass(BaseRender)

local EFFECT_CD = 1

function HunQiContentView:__init()
	self.effect_cd = 0

	self.select_hunqi_index = 0								--选择的魂器index
	self.select_kapai_index = 0								--选择的卡牌index


	self.model_display = self:FindObj("ModelDisplay")		--模型
	self.oct_agon = self:FindObj("Octagon")					--八边形
	self.equip_list = self:FindObj("EquipList")				--魂器列表
	self.effect_obj = self:FindObj("EffectObj")				--升级特效位置
 	self.DisplayImg = self:FindObj("DisplayImg")			--魂器形象
	self.hunqi_equip_list = {}
	for i = 0, HunQiData.SHENZHOU_WEAPON_COUNT - 1 do
		local obj = self.equip_list.transform:GetChild(i).gameObject
		local equip_cell = HunQiEquipItemCell.New(obj)
		equip_cell:SetIndex(i + 1)
		equip_cell:SetClickCallBack(BindTool.Bind(self.ClickHunQiCallBack, self))
		table.insert(self.hunqi_equip_list, equip_cell)
	end

	self.oct_agon_list = {}
	for i = 0, HunQiData.SHENZHOU_WEAPON_SLOT_COUNT - 1 do
		local obj = self.oct_agon.transform:GetChild(i).gameObject
		local oct_agon_cell = OctAgonItemCell.New(obj)
		oct_agon_cell:SetIndex(i + 1)
		oct_agon_cell:SetClickCallBack(BindTool.Bind(self.ClickKaPaiCallBack, self))
		table.insert(self.oct_agon_list, oct_agon_cell)
	end

	self.button_text = self:FindVariable("ButtonText")				--按钮描述
	self.cost_text = self:FindVariable("CostText")					--消耗描述
	self.have_select = self:FindVariable("HaveSelect")				--是否选中魂器
	self.is_max = self:FindVariable("IsMax")						--对应八卦牌是否已满级
	self.power = self:FindVariable("Power")							--战斗力
	self.hunqi_name = self:FindVariable("HunQiName")				--魂器名字
	self.skill_is_active = self:FindVariable("SkillIsActive")		--是否已激活技能
	self.skill_des = self:FindVariable("SkillDes")					--技能描述
	self.show_skill_des = self:FindVariable("ShowSkillDes")			--展示技能描述
	self.relics_time_des = self:FindVariable("RelicsTimeDes")		--遗迹可采集次数
	self.skill_level = self:FindVariable("SkillLevel")				--技能等级
	self.skill_res = self:FindVariable("SkillRes")					--技能图标资源
	self.hunqi_title_name = self:FindVariable("HunQiTitleName")		--魂器名字
	self.show_soul_redpoint = self:FindVariable("ShowSoulRedPoint")	--聚魂红点
	self.skill_name = self:FindVariable("SkillName")				--技能名字
	self.skill_info_des = self:FindVariable("SkillInfoNum")			--神器描述
	self.skill_level_dec = self:FindVariable("SkillLevelDec")		--技能等级描述
	self.display_img = self:FindVariable("DisplayImg")				--模型img
	self.hunqi_level = self:FindVariable("HunqiLevel")				--魂器等级
	self.is_show_attr = self:FindVariable("is_show_attr")			--魂器等级

	self.select_effect = {}
	self.effect_name = HunQiData.Instance:GetHunqiEffectTab()
	self.position_param = {[1] = Vector3(-50, -20, 0), [2] = Vector3(-30, 90, 0), [3] = Vector3(0, 0, 0),
							 [4] = Vector3(-35, 0, 0), [5] = Vector3(-20, -20, 0), [6] = Vector3(-80, -55, 0),
							 [7] = Vector3(-35, 0, 0), [8] = Vector3(2, -12, 0)}
	-- 魂器部位属性
	self.pai_attr_value = {}
	self.pai_attr_txt = {}
	for k = 1,4 do
		self.pai_attr_value[k] = self:FindVariable("attr_" .. k)
		self.pai_attr_txt[k] = self:FindVariable("attr_txt_" .. k)
	end
	self:ListenEvent("ClickButton", BindTool.Bind(self.ClickButton, self))
	self:ListenEvent("OpenAttrView", BindTool.Bind(self.OpenAttrView, self))
	self:ListenEvent("ClickSkill", BindTool.Bind(self.ClickSkill, self))
	self:ListenEvent("ClickRelicsBtn", BindTool.Bind(self.ClickRelicsBtn, self))
	self:ListenEvent("OpenSoul", BindTool.Bind(self.OpenSoul, self))
	self:ListenEvent("OnClickHelp", BindTool.Bind(self.ClickHelp, self))

	self.cell_list = {}
	self.list_view = self:FindObj("ListView")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetMountNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshMountCell, self)
	self.show_list_red_point = {}
	for i = 0, HunQiData.HUQI_WEAPON_COUNT - 1 do
		self.show_list_red_point[i] = false
 	end

end

function HunQiContentView:__delete()
	for _, v in ipairs(self.hunqi_equip_list) do
		v:DeleteMe()
	end
	self.hunqi_equip_list = {}

	for _, v in ipairs(self.oct_agon_list) do
		v:DeleteMe()
	end
	self.oct_agon_list = {}

	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end

	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}


	for k, v in pairs(self.select_effect) do
		if v ~= nil then
			GameObject.Destroy(v)
			v = nil
		end
	end
end

function HunQiContentView:ClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(229)
end

function HunQiContentView:OpenSoul()
	ViewManager.Instance:Open(ViewName.GatherSoulView)
end

function HunQiContentView:ClickRelicsBtn()
	local function ok_callback()
		ViewManager.Instance:Close(ViewName.HunQiView)
		GuajiCtrl.Instance:MoveToScene(AncientRelicsData.SCENE_ID)
	end
	local des = Language.HunQi.GoToAncientRelicsDes
	TipsCtrl.Instance:ShowCommonAutoView("hunqi_relics", des, ok_callback)
end

function HunQiContentView:ClickSkill()
	local hunqi_index = self.select_hunqi_index - 1
	local level = HunQiData.Instance:GetHunQiLevelByIndex(hunqi_index)
	local skill_info = HunQiData.Instance:GetSkillInfoByIndex(hunqi_index, level)
	local next_skill_info = HunQiData.Instance:GetSkillInfoByIndex(hunqi_index, level, true)
	if nil == skill_info then
		return
	end

	local skill_name = HunQiData.Instance:GetHunQiSkillByIndex(hunqi_index)
	local skill_level = skill_info.skill_level
	local skill_res_id = HunQiData.Instance:GetHunQiSkillResIdByIndex(hunqi_index)
	local asset, bunble = ResPath.GetHunQiSkillRes(skill_res_id)
	local now_des = ""
	local next_des = ""
	local levelup_des = ""
	if level > 0 then
		now_des = skill_info.skill_dec
	end
	if nil ~= next_skill_info then
		next_des = next_skill_info.skill_dec
		levelup_des = string.format(Language.HunQi.LevelUpDes, next_skill_info.level)
	end
	HunQiCtrl.Instance:ShowSkillTips(skill_name, skill_level, now_des, next_des, levelup_des, asset, bunble)
end

function HunQiContentView:OpenAttrView()
	local attr_list = HunQiData.Instance:GetHunQiAttrByIndex(self.select_hunqi_index)
	local result_data = HunQiData.Instance:GetSloatAttr(attr_list)
	-- 没有激活任何魂牌
	if nil == next(result_data) then
		local attr_list = HunQiData.Instance:GetHunQiAttrByOne(self.select_hunqi_index)
		result_data = HunQiData.Instance:GetNextSloatAttr(attr_list)
	end

	TipsCtrl.Instance:OpenGeneralView(attr_list)
	--HunQiCtrl.Instance:OpenTotalAttrTipView(result_data, attr_list)
end

function HunQiContentView:ClickButton()
	if self.select_hunqi_index <= 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.HunQi.NotSelectHunQi)
		return
	end
	if self.select_kapai_index <= 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.HunQi.NotSelectKaPai)
		return
	end
	HunQiCtrl.Instance:SendHunQiOperaReq(SHENZHOU_REQ_TYPE. SHENZHOU_REQ_TYPE_UPGRADE_WEAPON_SLOT, self.select_hunqi_index-1, self.select_kapai_index-1)
end

function HunQiContentView:FlushLeftView()
	local hunqi_list = HunQiData.Instance:GetHunQiList()
	if nil == hunqi_list then
		return
	end
	for k, v in ipairs(self.hunqi_equip_list) do
		if k == self.select_hunqi_index then
			v:SetToggleState(true)
		else
			v:SetToggleState(false)
		end
		v:SetData(hunqi_list[k])
	end
	self:FlushLeftContent()
end

function HunQiContentView:FlushLeftContent()
	local hunqi_name, color_num = HunQiData.Instance:GetHunQiNameAndColorByIndex(self.select_hunqi_index - 1)
	local color = ITEM_COLOR[color_num]
	hunqi_name = ToColorStr(hunqi_name, color)
	self.hunqi_title_name:SetValue(hunqi_name)

	--刷新采集次数
	local left_gather_times = HunQiData.Instance:GetTodayLeftGatherTimes()
	local count_des = ToColorStr(left_gather_times, TEXT_COLOR.GREEN)
	if left_gather_times <= 0 then
		count_des = ToColorStr(left_gather_times, TEXT_COLOR.RED)
	end
	self.relics_time_des:SetValue(count_des)
end

function HunQiContentView:FlushModel()
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

function HunQiContentView:ShowSelectEffect(flag, show_index, effect_name)
	if nil == self.select_effect[show_index] then
		PrefabPool.Instance:Load(AssetID("effects2/prefab/ui/horcruxescontent/" .. string.lower(effect_name) .. "_prefab", effect_name), function (prefab)
			if not prefab or self.select_effect[show_index] then return  end
			local obj = GameObject.Instantiate(prefab)
			PrefabPool.Instance:Free(prefab)
			local transform = obj.transform
			transform:SetParent(self.DisplayImg.transform, false)
			transform.localPosition = self.position_param[show_index]		--暂时写死特效的位置
			self.select_effect[show_index] = obj.gameObject
			self.is_loading = false
			self.select_effect[show_index]:SetActive(flag)
		end)
	else
		self.select_effect[show_index]:SetActive(flag)
	end
end


--改变模型特效
function HunQiContentView:FlushModelEffect()
	if not self.is_model_change then
		if self.model then
			local is_active_special = HunQiData.Instance:IsActiveSpecial(self.select_hunqi_index)
			self.model:ShowAttachPoint(AttachPoint.Weapon, not is_active_special)
			self.model:ShowAttachPoint(AttachPoint.Weapon2, is_active_special)
		end
	end
end

function HunQiContentView:FlushCostDes()
	local hunqi_list = HunQiData.Instance:GetHunQiList()
	if nil == hunqi_list then
		return
	end

	local kapai_level_list = hunqi_list[self.select_hunqi_index].weapon_slot_level_list
	if nil == kapai_level_list then
		return
	end
	local select_kapai_level = kapai_level_list[self.select_kapai_index] or 0
	local select_kapai_data = HunQiData.Instance:GetSlotAttrByLevel(self.select_hunqi_index - 1, self.select_kapai_index - 1, select_kapai_level)
	if nil == select_kapai_data then
		return
	end
	local item_data = select_kapai_data[1].up_level_item or {}
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
	local cost_des = string.format(Language.HunQi.NeedCostDes, ToColorStr(item_name, item_color), now_num_str, cost_num)
	self.cost_text:SetValue(cost_des)
end

function HunQiContentView:FlushRightView()
	if self.select_hunqi_index <= 0 then
		self.have_select:SetValue(false)
		return
	end
	self.have_select:SetValue(true)

	local hunqi_list = HunQiData.Instance:GetHunQiList()
	if nil == hunqi_list then
		return
	end

	--设置卡牌数据
	local kapai_level_list = hunqi_list[self.select_hunqi_index].weapon_slot_level_list
	if nil == kapai_level_list then
		return
	end
	local select_index = 0
	local is_select_change = false
	local is_active_skill = true
	for k, v in ipairs(self.oct_agon_list) do
		--判断卡牌红点
		local is_show_redpoint = false
		local kapai_level = kapai_level_list[k]
		if nil ~= kapai_level and kapai_level < HunQiData.SLOT_MAX_LEVEL then
			local kapai_data = HunQiData.Instance:GetSlotAttrByLevel(self.select_hunqi_index - 1, k - 1, kapai_level)
			if nil ~= kapai_data then
				kapai_data = kapai_data[1]
				local up_level_item_data = kapai_data.up_level_item
				local now_item_num = ItemData.Instance:GetItemNumInBagById(up_level_item_data.item_id)
				if now_item_num >= up_level_item_data.num then
					is_show_redpoint = true
				end
			end
		end

		if is_show_redpoint and not is_select_change then
			select_index = k
			is_select_change = true
		end
		if self.select_kapai_index == k and is_show_redpoint then
			select_index = self.select_kapai_index
		end
		v:ShowRedPoint(is_show_redpoint)

		-- 升级消耗的材料id
		local up_level_item_id = 0
		if nil ~= kapai_level and kapai_level <= HunQiData.SLOT_MAX_LEVEL then
			local kapai_data = HunQiData.Instance:GetSlotAttrByLevel(self.select_hunqi_index - 1, k - 1, kapai_level)
			if nil ~= kapai_data then
				kapai_data = kapai_data[1]
				up_level_item_id = kapai_data.up_level_item.item_id
			end
		end

		local res_id = HunQiData.Instance:GetHunQiResIdByIndex(self.select_hunqi_index - 1)
		local data = {parent_res_id = res_id, level = kapai_level, up_level_item_id = up_level_item_id}
		v:SetData(data)
	end

	--设置技能是否已激活
	local hunqi_level = HunQiData.Instance:GetHunQiLevelByIndex(self.select_hunqi_index - 1)
	self.skill_is_active:SetValue(hunqi_level > 0)
	self.hunqi_level:SetValue(string.format(Language.HunQi.HunQiLevel,hunqi_level))

	--设置技能图标
	local skill_res_id = HunQiData.Instance:GetHunQiSkillResIdByIndex(self.select_hunqi_index - 1)
	self.skill_res:SetAsset(ResPath.GetHunQiSkillRes(skill_res_id))

	--设置技能等级
	local skill_info = HunQiData.Instance:GetSkillInfoByIndex(self.select_hunqi_index - 1, hunqi_level)
	if nil ~= skill_info then
		self.skill_level:SetValue("Lv." .. skill_info.skill_level)
	end

	local skill_name = HunQiData.Instance:GetHunQiSkillByIndex(self.select_hunqi_index - 1)
	self.skill_name:SetValue(skill_name)
	local next_skill_desc = nil
	next_skill_desc = string.gsub(skill_info.skill_dec, "%b()%%", function (str)
		return  (tonumber(skill_info[string.sub(str, 2, -3)]) / 1000)..""
	end)
	next_skill_desc = string.gsub(next_skill_desc, "%b[]%%", function (str)
		return (tonumber(skill_info[string.sub(str, 2, -3)]) / 100) .. "%"
	end)
	next_skill_desc = string.gsub(next_skill_desc, "%[.-%]", function (str)
		return skill_info[string.sub(str, 2, -2)]
	end)
	self.skill_level_dec:SetValue(next_skill_desc)

	local kapai_level = kapai_level_list[self.select_kapai_index]
	local attr_list = HunQiData.Instance:GetSlotAttrByLevel(self.select_hunqi_index - 1,self.select_kapai_index - 1,kapai_level)
	local next_attr_list = HunQiData.Instance:GetSlotAttrByLevel(self.select_hunqi_index - 1,self.select_kapai_index - 1,kapai_level + 1)
	-- 设置属性
	if nil == next_attr_list then
		self:FlushPaiAttr(attr_list[1])
	else
		self:FlushPaiAttr(attr_list[1], next_attr_list[1])
	end

	local next_skill_info = HunQiData.Instance:GetSkillInfoByIndex(self.select_hunqi_index - 1, hunqi_level, true)
	if nil ~= next_skill_info then
		-- local levelup_des = string.format(Language.HunQi.LevelUpDes, next_skill_info.level)
		self.skill_info_des:SetValue(next_skill_info.level)
	end

	for k, v in ipairs(self.oct_agon_list) do
		if k == self.select_kapai_index then
			v:SetToggleState(true)
		else
			v:SetToggleState(false)
		end
	end

	--设置战斗力
	local capability = HunQiData.Instance:GetHunQiCapability(self.select_hunqi_index)
	self.power:SetValue(capability)

	--判断卡牌是否满级
	local select_kapai_level = kapai_level_list[self.select_kapai_index] or 0
	if select_kapai_level >= HunQiData.SLOT_MAX_LEVEL then
		self.cost_text:SetValue("")
		self.button_text:SetValue(Language.Common.YiManJi)
		self.is_max:SetValue(true)
		return
	end
	self.is_max:SetValue(false)

	if select_kapai_level <= 0 then
		self.button_text:SetValue(Language.Common.Activate)
	else
		self.button_text:SetValue(Language.Common.UpGrade)
	end

	--设置消耗描述
	self:FlushCostDes()
end

function HunQiContentView:FlushLeftRedPoint()
	local hunqi_list = HunQiData.Instance:GetHunQiList()
	if nil == hunqi_list then
		return
	end

	for i = 0, HunQiData.HUQI_WEAPON_COUNT - 1 do
		self.show_list_red_point[i] = false
 	end
	-- 魂器
 	for i = 0, HunQiData.HUQI_WEAPON_COUNT - 1 do
 		local kapai_level_list = hunqi_list[i + 1].weapon_slot_level_list
		if nil == kapai_level_list then
			return
		end
 		-- 魂器的卡牌
 		for k = 0, 7 do
 			local kapai_level = kapai_level_list[k + 1]
 			if nil ~= kapai_level and kapai_level < HunQiData.SLOT_MAX_LEVEL then
				local kapai_data = HunQiData.Instance:GetSlotAttrByLevel(i, k, kapai_level)
				if nil ~= kapai_data then
					kapai_data = kapai_data[1]
					local up_level_item_data = kapai_data.up_level_item
					local now_item_num = ItemData.Instance:GetItemNumInBagById(up_level_item_data.item_id)
					if now_item_num >= up_level_item_data.num then
						self.show_list_red_point[i] = true
					end
				end
			end
 		end
 	end
end

function HunQiContentView:FlushPaiAttr(attr_data, next_attr_data)
	local result_data, flag = HunQiData.Instance:GetSloatAndSortAttr(attr_data, next_attr_data)
	self.is_show_attr:SetValue(flag)
	local count = 1
	for k = 1, 4 do
		self.pai_attr_value[k]:SetValue("")
		self.pai_attr_txt[k]:SetValue("")
	end

	for k,v in pairs(result_data) do
		for v1, v2 in pairs(v) do
			self.pai_attr_txt[count]:SetValue(v1)
			self.pai_attr_value[count]:SetValue(v2)
		end

		count = count + 1
		if count > 4 then
			break
		end
	end

	local item_cfg = ItemData.Instance:GetItemConfig(attr_data.up_level_item.item_id)
	self.hunqi_name:SetValue(item_cfg.name)
end

function HunQiContentView:FlushElementRed()
	local hunqi_list = HunQiData.Instance:GetHunQiList()
	if hunqi_list == nil then
		return
	end

	local is_show = false
	for k1, v1 in ipairs(hunqi_list) do
		if is_show then
			break
		end
		local hunqi_level = v1.weapon_level
		local element_level_list = v1.element_level_list
		for k2, v2 in ipairs(element_level_list) do
			local next_attr_info = HunQiData.Instance:GetSoulAttrInfo(k1-1, k2-1, v2+1)
			if nil ~= next_attr_info then
				local attr_info = HunQiData.Instance:GetSoulAttrInfo(k1-1, k2-1, v2)
				attr_info = attr_info[1]
				local limit_level = attr_info.huqi_level_limit
				if hunqi_level >= limit_level then
					local up_level_item = attr_info.up_level_item
					local have_num = ItemData.Instance:GetItemNumInBagById(up_level_item.item_id)
					if have_num >= up_level_item.num then
						is_show = true
						break
					end
				end
			end
		end
	end
	self.show_soul_redpoint:SetValue(is_show)
end

function HunQiContentView:InitView()
	self.select_hunqi_index = 1
	self.select_kapai_index = 1

	--隐藏技能描述
	self.show_skill_des:SetValue(false)
	self:FlushLeftView()
	self:FlushModel()
	self:FlushModelEffect()
	self:FlushRightView()
	self:FlushElementRed()
	self:OnClickListCell(0)
	self:FlushLeftRedPoint()
	self.list_view.scroller:ReloadData(0)
end

function HunQiContentView:FlushView()
	self:FlushLeftView()
	self:FlushRightView()
	self:FlushModelEffect()
	self:FlushElementRed()
	self:FlushLeftRedPoint()
	if self.select_hunqi_index <= 5 then
		self.list_view.scroller:ReloadData(0)
	else
		self.list_view.scroller:ReloadData(1)
	end
end

function HunQiContentView:ClickHunQiCallBack(cell)
	if nil == cell then
		return
	end
	cell:SetToggleState(true)
	local index = cell:GetIndex()
	if index == self.select_hunqi_index then
		return
	end
	self.select_hunqi_index = index

	self.select_kapai_index = 1
	self:FlushModel()
	self:FlushRightView()
	self:FlushLeftContent()
end

function HunQiContentView:ClickKaPaiCallBack(cell)
	if nil == cell then
		return
	end

	local index = cell:GetIndex()
	if index == self.select_kapai_index then
		return
	end
	self.select_kapai_index = index
	local data = cell:GetData()
	local level = data.level

	if level >= HunQiData.SLOT_MAX_LEVEL then
		self.cost_text:SetValue("")
		self.button_text:SetValue(Language.Common.YiManJi)
		self.is_max:SetValue(true)
		local select_kapai_data = HunQiData.Instance:GetSlotAttrByLevel(self.select_hunqi_index - 1, index - 1, level)
		if nil == select_kapai_data then
			return
		end
		self:FlushPaiAttr(select_kapai_data[1])
		return
	end

	self.is_max:SetValue(false)
	if level <= 0 then
		self.button_text:SetValue(Language.Common.Activate)
	else
		self.button_text:SetValue(Language.Common.UpGrade)
	end

	--设置消耗描述
	local select_kapai_data = HunQiData.Instance:GetSlotAttrByLevel(self.select_hunqi_index - 1, index - 1, level)
	if nil == select_kapai_data then
		return
	end

	local item_data = select_kapai_data[1].up_level_item or {}
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
	local cost_des = string.format(Language.HunQi.NeedCostDes, ToColorStr(item_name, item_color), now_num_str, cost_num)
	self.cost_text:SetValue(cost_des)

	local next_kapai_data = HunQiData.Instance:GetSlotAttrByLevel(self.select_hunqi_index - 1, index - 1, level + 1)

	self:FlushPaiAttr(select_kapai_data[1], next_kapai_data[1])
end

-------------------------------------------------------------------------------
-------------------------------HunQiEquipItemCell------------------------------
-------------------------------------------------------------------------------
HunQiEquipItemCell = HunQiEquipItemCell or BaseClass(BaseCell)
function HunQiEquipItemCell:__init()
	self.name = self:FindVariable("Name")
	self.icon_res = self:FindVariable("IconRes")
	self.show_red_point = self:FindVariable("ShowRedPoint")
	self.is_active = self:FindVariable("IsActive")

	self:ListenEvent("Click", BindTool.Bind(self.OnClick, self))
end

function HunQiEquipItemCell:__delete()

end

function HunQiEquipItemCell:OnFlush()
	if nil == self.data then
		return
	end

	local level = self.data.weapon_level
	local name_des = "Lv." .. level
	self.name:SetValue(name_des)

	--判断是否激活
	if level <= 0 then
		self.is_active:SetValue(false)
	else
		self.is_active:SetValue(true)
	end

	--设置红点
	local is_show = false
	local kapai_level_list = self.data.weapon_slot_level_list
	if nil == kapai_level_list then
		return
	end
	for k, v in ipairs(kapai_level_list) do
		if v < HunQiData.SLOT_MAX_LEVEL then
			local kapai_data = HunQiData.Instance:GetSlotAttrByLevel(self.index - 1, k - 1, v)
			if nil ~= kapai_data then
				kapai_data = kapai_data[1]
				local up_level_item_data = kapai_data.up_level_item
				local now_item_num = ItemData.Instance:GetItemNumInBagById(up_level_item_data.item_id)
				if now_item_num >= up_level_item_data.num then
					is_show = true
					break
				end
			end
		end
	end
	self.show_red_point:SetValue(is_show)

	--设置图标
	local model_res_id = HunQiData.Instance:GetHunQiResIdByIndex(self.index-1)
	local param = model_res_id - 17000
	local res_id = "HunQi_" .. param
	self.icon_res:SetAsset(ResPath.GetHunQiImg(res_id))
end

function HunQiEquipItemCell:SetToggleState(state)
	self.root_node.toggle.isOn = state
end

-------------------------------------------------------------------------------
-------------------------------OctAgonItemCell------------------------------
-------------------------------------------------------------------------------
OctAgonItemCell = OctAgonItemCell or BaseClass(BaseCell)
function OctAgonItemCell:__init()
	self.gray = self:FindVariable("Gray")
	self.level = self:FindVariable("Level")
	self.show_red_point = self:FindVariable("ShowRedPoint")
	self.ka_pai_res = self:FindVariable("KaPaiRes")

	self:ListenEvent("Click", BindTool.Bind(self.OnClick, self))
end

function OctAgonItemCell:__delete()

end

function OctAgonItemCell:OnFlush()
	if nil == self.data then
		return
	end
	self.gray:SetValue(self.data.level <= 0)

	self.level:SetValue(string.format(Language.HunQi.HunQiLevel,self.data.level))

	local item_cfg = ItemData.Instance:GetItemConfig(self.data.up_level_item_id)
	if self.data.parent_res_id then
		local parent_param = self.data.parent_res_id - 17000
		if item_cfg then
			self.ka_pai_res:SetAsset(ResPath.GetItemIcon(item_cfg.id))
		end
	end
end

function OctAgonItemCell:SetToggleState(state)
	self.root_node.toggle.isOn = state
end

function OctAgonItemCell:ShowRedPoint(state)
	self.show_red_point:SetValue(state)
end

function HunQiContentView:GetMountNumberOfCells()
	return #HunQiData.Instance:GetHunQiName()
end

function HunQiContentView:RefreshMountCell(cell, cell_index)
	local hunqi_cfg = HunQiData.Instance:GetHunQiName()				--大表
	local mount_cell = self.cell_list[cell]
	if mount_cell == nil then
		mount_cell = HunQiItemCell.New(cell.gameObject)
		self.cell_list[cell] = mount_cell
	end
	mount_cell:SetToggleGroup(self.list_view.toggle_group)
	mount_cell:SetHighLight(self.select_hunqi_index == cell_index + 1)

	mount_cell:SetData(hunqi_cfg[cell_index + 1])
	mount_cell:SetRedPointState(self.show_list_red_point[cell_index])

	mount_cell:ListenClick(BindTool.Bind(self.OnClickListCell, self, cell_index))
end

function HunQiContentView:OnClickListCell(cell_index)
	self.select_hunqi_index = cell_index + 1
 	self:FlushModel()
 	self:FlushRightView()
 	for i = 1, HunQiData.HUQI_WEAPON_COUNT do
 		self:ShowSelectEffect(i == self.select_hunqi_index, i, self.effect_name[i])
 	end
end


HunQiItemCell = HunQiItemCell or BaseClass(BaseRender)

function HunQiItemCell:__init()
	-- self.icon = self:FindVariable("Icon")
	self.name = self:FindVariable("Name")
	self.name_hl = self:FindVariable("Name_HL")
	self.show_red_ponit = self:FindVariable("ShowRedPoint")
	self.itemImg = self:FindVariable("ItemImg")
	self.index = 0
end

function HunQiItemCell:__delete()
	self.icon = nil
	self.name = nil
	self.show_red_ponit = nil
end

function HunQiItemCell:SetData(data)
	if data == nil then
		return
	end

	local icon_id = data.res_id - 17000
	local res_id = "HunQi_" .. icon_id
	self.itemImg:SetAsset(ResPath.GetHunQiImg(res_id))
	local name_str = data.name

	self.name:SetValue(name_str)
	self.name_hl:SetValue(name_str)

	self.index = data.index
end

function HunQiItemCell:ListenClick(handler)
	self:ClearEvent("Click")
	self:ListenEvent("Click", handler)
end

function HunQiItemCell:SetRedPointState(state)
	self.show_red_ponit:SetValue(state)
end


function HunQiItemCell:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end

function HunQiItemCell:SetHighLight(enable)
	self.root_node.toggle.isOn = enable
end
