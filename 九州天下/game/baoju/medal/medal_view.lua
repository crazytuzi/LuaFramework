MedalView = MedalView or BaseClass(BaseRender)

local EFFECT_CD = 1
local AttrGetPower = nil
local GrayLevel = 30

local ListViewDelegate = ListViewDelegate
function MedalView:__init()
	MedalView.Instance = self
	MedalCtrl.Instance:RegisterView(self)

	self.list_data = {}
	self.cur_index = 1
	self.cur_level = 0
end

function MedalView:__delete()
	if MedalCtrl.Instance ~= nil then
		MedalCtrl.Instance:UnRegisterView()
	end

	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
	
	if self.attr_list then
		for i,v in ipairs(self.attr_list) do
			v:DeleteMe()
		end
		self.attr_list = {}
	end
	

	self.old_index = -1
end

function MedalView:CloseCallBack()
	self.cur_index = 1
end

function MedalView:LoadCallBack()
	self.medal_max_level = MedalData.Instance:GetMaxLevel()
	self.effect_cd = 0
	self.old_index = -1
	if AttrGetPower == nil then
		AttrGetPower = {
			mount_attr_add = BindTool.Bind(MountData.GetMountAttrSum, MountData.Instance),
			wing_attr_add = BindTool.Bind(WingData.GetWingAttrSum,WingData.Instance),
			halo_attr_add = BindTool.Bind(HaloData.GetHaloAttrSum,HaloData.Instance),
			-- magic_bow_attr_add = BindTool.Bind(ShengongData.GetShengongAttrSum,ShengongData.Instance),
			-- magic_wing_attr_add = BindTool.Bind(ShenyiData.GetShenyiAttrSum,ShenyiData.Instance),
		}
	end

	--变量
	self.activate_days = self:FindVariable("ActivateDays")
	self.level = self:FindVariable("Level")
	self.rand = self:FindVariable("Rank")
	self.medal_name = self:FindVariable("MedalName")
	self.total_name = self:FindVariable("TotalName")
	self.power = self:FindVariable("PowerValue")
	-- self.power_next = self:FindVariable("NextPowerValue")
	-- self.is_show_next_arrow = self:FindVariable("IsShowNextArrow")
	self.is_show_medal_next_arrow = self:FindVariable("IsShowMedalNextArrow")
	self.process_left_value = self:FindVariable("ProcessLeftValue")
	self.process_right_value = self:FindVariable("ProcessRightValue")
	self.slider_value = self:FindVariable("SliderValue")
	self.class_text = self:FindVariable("ClassText")
	self.class_bg = self:FindVariable("ClassBG")
	self.show_right_btn = self:FindVariable("ShowRightBtn")
	self.show_left_btn = self:FindVariable("ShowLeftBtn")
	self.is_show_tips = self:FindVariable("IsShowTips")
	self.stuff_num = self:FindVariable("StuffNum")
	self.is_show_addnum = self:FindVariable("IsShowAddNum")
	self.add_power_num = self:FindVariable("AddPowerNum")
	self.show_image = self:FindVariable("ShowImage")
	self.is_image_gray = self:FindVariable("IsImagegray")
	self.image_effect = self:FindVariable("Effect")
	self.show_name_image = self:FindVariable("ShowImageName")
	-- self.show_right_btn:SetValue(true)
	-- self.show_left_btn:SetValue(true)
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("ItemCell"))

	self:ListenEvent("OnClickRightButton", BindTool.Bind(self.OnClickRightButton, self))
	self:ListenEvent("OnClickLeftButton", BindTool.Bind(self.OnClickLeftButton, self))
	self:ListenEvent("OnClickHelp", BindTool.Bind(self.OnClickHelp, self))
	self:ListenEvent("UpgradeClick", BindTool.Bind(self.OnUpgradeClick, self))

	self.selet_data_index = MedalData.Instance:GetMedalTotalDataIndex()
	if self.selet_data_index <= 0 then
		self.selet_data_index = 1
	end
	--属性文本
	self.attr_list = {}
	local obj_group = self:FindObj("ObjGroup")
	local child_number = obj_group.transform.childCount
	local count = 1
	for i = 0, child_number - 1 do
		local obj = obj_group.transform:GetChild(i).gameObject
		if string.find(obj.name, "Attr") ~= nil then
			self.attr_list[count] = MedalAttrText.New(obj)
			count = count + 1
		end
	end

	--勋章属性文本
	self.attr_line_list = {}
	self.next_attr_line_list = {}
	for i=1,4 do
		self.attr_line_list[i] = self:FindVariable('Attr'..i)
		self.next_attr_line_list[i] = self:FindVariable('NextAttr'..i)
	end

	self.medal_total_data = MedalData.Instance:GetMedalSuitCfg()

	self.effect_root = self:FindObj("EffectRoot")
	-- 勋章模型
	self.center_display = self:FindObj("CenterDisplay")
	-- self:InitMedalModel()

	self:InitScroller()
	self:FlushAttr()
	-- self:ShowCurrentIcon()
end

-- 勋章模型
function MedalView:InitMedalModel()
	if not self.medal_model then
		self.medal_model = RoleModel.New()
		self.medal_model:SetDisplay(self.center_display.ui3d_display)
	end
end

function MedalView:SetMedalModelData(index)
	if self.old_index == index then return end
	self.old_index = index
	-- local res_id = MedalData.Instance:GetMedalResId(index)
	-- local bubble, asset = ResPath.GetMedalModel(res_id)
	-- self.medal_model:SetMainAsset(bubble, asset)
	-- self.medal_model:SetModelTransformParameter(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.XUN_ZHANG], res_id, DISPLAY_PANEL.ADVANCE_SUCCE)

	-- local bundle, asset = ResPath.GetActiveDegreeIcon("hufu_0" .. index)
	local bundle, asset = ResPath.GetRawImage("hufu_0" .. index)
	self.show_image:SetAsset(bundle, asset)

	local eff_name = "Effect_hufu_0" .. index
	self.image_effect:SetAsset("effects2/prefab/ui/" .. string.lower(eff_name) .. "_prefab", eff_name)
	local select_data = self.medal_total_data[index]
	-- if select_data then
	-- 	self.total_name:SetValue(select_data.name)
	-- end
	local bundle, asset = ResPath.GetActiveDegreeIcon("xun_name_" .. index)
	if self.show_name_image then
		self.show_name_image:SetAsset(bundle, asset)
	end
end

function MedalView:OnClickRightButton()
	local active_index = MedalData.Instance:GetCurActiveJie()
	if self.selet_data_index <= active_index then
		self.selet_data_index = self.selet_data_index + 1
	end
	if self.selet_data_index > #self.medal_total_data then
		self.selet_data_index = #self.medal_total_data
	end
	self:SetMedalModelData(self.selet_data_index)
	self:JumpToIndex(self.selet_data_index)

end

function MedalView:OnClickLeftButton()
	self.selet_data_index = self.selet_data_index - 1
	if self.selet_data_index < 1 then
		self.selet_data_index = 1
	end
	self:SetMedalModelData(self.selet_data_index)
	self:JumpToIndex(self.selet_data_index)
end

function MedalView:JumpToIndex(index)
	local active_index = MedalData.Instance:GetCurActiveJie()
	local max_level = MedalData.Instance:GetMaxOtherNum()
	self.show_left_btn:SetValue(true)
	self.show_right_btn:SetValue(true)
	if index > active_index or index == max_level then
		self.show_right_btn:SetValue(false)
	end
	if index <= 1 then
		self.show_left_btn:SetValue(false)
	end
	self:FlushPreviewData()
	self:SetAttr()
end

function MedalView:OnClickHelp()
	local tips_id = 21    -- 勋章tips
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function MedalView:OpenCallBack()
	-- self:ShowCurrentIcon()
end

function MedalView:ShowCurrentIcon()
	self.selet_data_index = MedalData.Instance:GetMedalTotalDataIndex()
	if self.selet_data_index <= 0 then
		self.selet_data_index = 1
	end
	if self.selet_data_index >= 5 then
		self.show_right_btn:SetValue(false)
		self.show_left_btn:SetValue(true)
	elseif self.selet_data_index <= 1 then
		self.show_right_btn:SetValue(true)
		self.show_left_btn:SetValue(false)
	end
end

--初始化滚动条
function MedalView:InitScroller()
	self.medal_cell_list = {}
	self.list_data = MedalData.Instance:GetMedalInfo()
	self.icon_list = self:FindObj("IconListView")
	local list_view_delegate = self.icon_list.list_simple_delegate
	--生成数量
	list_view_delegate.NumberOfCellsDel = function()
		return #self.list_data or 0
	end
	--刷新函数
	list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshMedalListView, self)
end


-- listview
function MedalView:RefreshMedalListView(cell, data_index, cell_index)
	data_index = data_index + 1

	local medal_cell = self.medal_cell_list[cell]
	if medal_cell == nil then
		medal_cell = MedalScrollCell.New(cell.gameObject)
		medal_cell:SetClickCallBack(BindTool.Bind(self.OnClickItemCallBack, self))

		self.medal_cell_list[cell] = medal_cell
	end
	medal_cell:SetIndex(data_index)
	medal_cell:SetShowSelect(self.cur_index)
	medal_cell:SetData(self.list_data[data_index])
end

function MedalView:OnClickItemCallBack(cell)
	if nil == cell or nil == cell.data then return end
	self.cur_index = cell.index
	self:SetAttr()
	self.icon_list.scroller:RefreshAndReloadActiveCellViews(true)
end

local OrderTable = {
	[1] = "mount_attr_add",
	[2] = "wing_attr_add",
	[3] = "halo_attr_add",
	-- [4] = "magic_bow_attr_add",
	-- [5] = "magic_wing_attr_add",
}

function MedalView:SetAttr()
	local data = self.list_data[self.cur_index]
	if nil == data then return end

	local cfg = MedalData.Instance:GetLevelCfgByIdAndLevel(data.id, data.level) or {}
	local next_cfg = MedalData.Instance:GetLevelCfgByIdAndLevel(data.id, data.level + 1) or {}
	if cfg.level < 1 then
		cfg = next_cfg
	end
	-- --勋章名
	self.medal_name:SetValue(string.format(Language.BaoJu.MedalName, cfg.xunzhang_name, data.level))
	--属性
	local attrs = CommonDataManager.GetAttributteByClass(cfg)
	local count = 1
	for k,v in pairs(attrs) do
		if v > 0 then
			local chs_attr_name = ToColorStr(CommonDataManager.GetAttrName(k)..':', "#84410a")
			local value = 0
			if data.level > 0 then
				value = v
			end
			local attr_value = ToColorStr('  '..value, "#503635")
			self.attr_line_list[count]:SetValue(chs_attr_name..attr_value)
			count = count + 1
			if count > #self.attr_line_list then
				break
			end
		end
	end

	if count <= #self.attr_line_list then
		for i=count,#self.attr_line_list do
			self.attr_line_list[i]:SetValue('')
		end
	end

	--战力
	local power = 0
	if data.level < 1 then
		self.power:SetValue(power)
	else
		power = CommonDataManager.GetCapability(attrs)
		self.power:SetValue(power)
	end

	if next_cfg and next(next_cfg)then
		local next_attrs = CommonDataManager.GetAttributteByClass(next_cfg)
		local next_count = 1
		for k,v in pairs(next_attrs) do
			if v > 0 then
				self.next_attr_line_list[next_count]:SetValue(v)
				next_count = next_count + 1
				if next_count > #self.next_attr_line_list then
					break
				end
			end
		end

		local had_num = ItemData.Instance:GetItemNumInBagById(next_cfg.uplevel_stuff_id)
		had_num = had_num < next_cfg.uplevel_stuff_num and ToColorStr(had_num, TEXT_COLOR.RED) or ToColorStr(had_num, TEXT_COLOR.GREEN)

		self.item_cell:SetData({item_id = next_cfg.uplevel_stuff_id})
		self.stuff_num:SetValue(had_num .. "/" .. next_cfg.uplevel_stuff_num)

		local next_power = CommonDataManager.GetCapability(next_attrs)
		self.add_power_num:SetValue(next_power - power)
		self.is_show_addnum:SetValue(true)
		self.is_show_medal_next_arrow:SetValue(true)
	else
		for i=1,4 do
			self.next_attr_line_list[i]:SetValue("")
		end
		self.is_show_medal_next_arrow:SetValue(false)

		self.item_cell:SetData({item_id = cfg.uplevel_stuff_id})
		self.stuff_num:SetValue("-/-")
		self.is_show_addnum:SetValue(false)
	end
end

--勋章预览数据
function MedalView:FlushPreviewData()
	local cur_jie = MedalData.Instance:GetMedalTotalDataIndex()
	local select_data = self.medal_total_data[cur_jie]
	local next_data = self.medal_total_data[cur_jie + 1]
	if nil == next_data then
		next_data = select_data
	end
	-- local current_data_index = MedalData.Instance:GetMedalTotalDataIndex()
	local cur_jie = MedalData.Instance:GetCurActiveJie()
	if MedalData.Instance:GetMedalTotalLevel() < MedalData.Instance:GetIsActiveById(self.selet_data_index) then
		self.activate_days:SetValue(ToColorStr(select_data and select_data.description or next_data.description, TEXT_COLOR.RED))
	else
		self.activate_days:SetValue(ToColorStr(Language.Common.YiActivate, TEXT_COLOR.GREEN))
	end

	if self.selet_data_index == 0 then
		self.class_text:SetValue('')
		self.class_bg:SetAsset('','')
	else
		self.class_text:SetValue(ZhiBaoData.Instance:GetChsNumber(self.selet_data_index))
		self.class_bg:SetAsset(ResPath.GetMountGradeQualityBG(math.ceil(self.selet_data_index/2)))
	end

	if self.selet_data_index > cur_jie then
		self.is_show_tips:SetValue(true)
		self.level:SetValue(next_data.total_level)
		self.rand:SetValue(Language.Common.NumToChs[self.selet_data_index])
	else
		self.is_show_tips:SetValue(false)
	end
	local current_data = select_data
	if current_data == nil then
		current_data = {
	    total_level=0,
        mount_attr_add=0,
        wing_attr_add=0,
        halo_attr_add=0,
        magic_bow_attr_add=0,
        magic_wing_attr_add=0,
        }
	end

	local original_power = 0
	local current_power = 0
	local select_power = 0

	for k,v in pairs(AttrGetPower) do
		local power = 0
		local attr = v()
		if attr ~= 0 then
			power = CommonDataManager.GetCapability(attr)
		end
		original_power = original_power + power
	end
	local count = 1
	for k,v in ipairs(OrderTable) do
		if count > #self.attr_list then
			print('属性数量超出可显示范围')
			break
		end
		local data = {}
		data.name = Language.BaoJu.AdvanceAttr[v]
		data.icon = Language.BaoJu.IconName[v]
		data.value = current_data[v]
		local power = 0

		local attr = AttrGetPower[v]()
		if attr ~= 0 then
			power = CommonDataManager.GetCapability(attr)
		end
		current_power = current_power + math.floor(power * (1 + data.value / 10000))
		if current_data.total_level < next_data.total_level then
			data.next_value = next_data[v]
			local next_power = 0
			local next_attr = AttrGetPower[v]()
			if next_attr ~= 0 then
				next_power = CommonDataManager.GetCapability(next_attr)
			end
			select_power = select_power + math.floor(next_power * (1 + current_data[v] / 10000))
		else
			data.next_value = nil
		end
		self.attr_list[count]:SetData(data)
		count = count + 1
	end
	if count <= #self.attr_list then
		for i=count,#self.attr_list do
			self.attr_list[i]:SetActive(false)
		end
	end
end

function MedalView:OnUpgradeClick()
	local data = self.list_data[self.cur_index]
	if nil == data then return end

	local next_cfg = MedalData.Instance:GetLevelCfgByIdAndLevel(data.id, data.level + 1)
	if next_cfg == nil then
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.MaxLevel)
	else
		local stuff_cfg = ItemData.Instance:GetItemConfig(next_cfg.uplevel_stuff_id)
		if stuff_cfg ~= nil then
			local had_num = ItemData.Instance:GetItemNumInBagById(next_cfg.uplevel_stuff_id)
			if had_num >= next_cfg.uplevel_stuff_num then
				-- local flag = self.toggle_bind_only.isOn and 1 or 0
				MedalCtrl.Instance:SendMedalUpgrade(data.id, 0)
				AudioService.Instance:PlayAdvancedAudio()
			else
				TipsCtrl.Instance:ShowItemGetWayView(next_cfg.uplevel_stuff_id)
			end
		end
	end
end

function MedalView:FlushAttr()
	local current_data_index = MedalData.Instance:GetMedalTotalDataIndex()
	local next_total_level = 0
	if self.medal_total_data[current_data_index + 1] then
		if MedalData.Instance:GetMedalIsOneJie() then
			next_total_level = self.medal_total_data[current_data_index + 1].total_level
		else
			next_total_level = self.medal_total_data[1].total_level
		end
	end
	local current_total_level = MedalData.Instance:GetMedalTotalLevel()

	self.process_left_value:SetValue(current_total_level < self.medal_max_level and current_total_level or "-")
	self.process_right_value:SetValue(current_total_level < self.medal_max_level and next_total_level or "-")

	
	if self.is_frist then
		self.is_frist = false
		self.slider_value:InitValue(current_total_level/next_total_level)
	else
		self.slider_value:SetValue(current_total_level/next_total_level)
	end
	self:JumpToIndex(self.selet_data_index)
	if self.cur_level ~= current_data_index then
		self:SetMedalModelData(current_data_index)
	end
	self.cur_level = current_data_index
	self.is_image_gray:SetValue(current_total_level >= GrayLevel)
end


--升级时刷新数据
function MedalView:OnFlush()
	self:FlushAttr()
	-- self:FlushEffect()
	self.icon_list.scroller:RefreshAndReloadActiveCellViews(true)
end

-- 升级时刷新特效
function MedalView:FlushEffect()
	-- if self.effect_cd and self.effect_cd - Status.NowTime <= 0 then
	-- 	EffectManager.Instance:PlayAtTransformCenter(
	-- 		"effects2/prefab/ui_prefab",
	-- 		"UI_shengjichenggong",
	-- 		self.effect_root.transform,
	-- 		2.0)
	-- 	self.effect_cd = Status.NowTime + EFFECT_CD
	-- end
end

----------------------------------------------------------------------------
--MedalAttrText		勋章属性文本
----------------------------------------------------------------------------
MedalAttrText = MedalAttrText or BaseClass(BaseCell)
function MedalAttrText:__init()
	self.attr_name = self:FindVariable("Name")
	self.current_value = self:FindVariable("CurrentValue")
	self.next_value = self:FindVariable("NextValue")
	self.is_show_arrow = self:FindVariable("IsShowArrow")
	self.attr_icon = self:FindVariable("AttrIcon")
end

function MedalAttrText:__delete()

end

function MedalAttrText:OnFlush()
	self:SetActive(true)
	self.attr_name:SetValue(self.data.name ..':')
	-- local bubble, asset = ResPath.GetImages(self.data.icon)
	-- self.attr_icon:SetAsset(bubble, asset)
	self.current_value:SetValue('+' .. (self.data.value/100) .. '%')
	if self.data.next_value ~= nil then
		if MedalData.Instance:GetMedalIsOneJie() then
			local next_add_value = self.data.next_value/100 - self.data.value/100
			self.next_value:SetValue(string.format(Language.BaoJu.NextJieUp, next_add_value))
			self.is_show_arrow:SetValue(true)
		else
			self.is_show_arrow:SetValue(true)
			self.current_value:SetValue('+'..(0)..'%')
			self.next_value:SetValue(string.format(Language.BaoJu.NextJieUp, self.data.value/100))
		end

	else
		if MedalData.Instance:GetMedalIsOneJie() then
			self.next_value:SetValue('')
			self.is_show_arrow:SetValue(false)
		else
			self.is_show_arrow:SetValue(true)
			self.current_value:SetValue('+' .. (0)..'%')
			self.next_value:SetValue(string.format(Language.BaoJu.NextJieUp, (self.data.value/100)))
		end
	end
end

--------------------------------------------------------------------------
--MedalScrollCell 	格子
--------------------------------------------------------------------------
MedalScrollCell = MedalScrollCell or BaseClass(BaseCell)

function MedalScrollCell:__init(instance, left_view)
	self:ListenEvent("ClickItem", BindTool.Bind(self.OnClick, self))
	-- --勋章图标
	self.medal_icon = self:FindVariable("Icon")
	-- --勋章名
	-- self.medal_name = self:FindVariable("Name")
	self.show_red_point = self:FindVariable("ShowRedPoint")
	self.show_select = self:FindVariable("ShowSelect")
end

function MedalScrollCell:__delete()

end

function MedalScrollCell:OnFlush()
	--图标
	self.medal_icon:SetAsset(ResPath.GetMedalIcon(self.data.id))
	-- --红点
	self.show_red_point:SetValue(self.data.can_upgrade)
end	

function MedalScrollCell:SetShowSelect(index)
	self.show_select:SetValue(index == self.index)
end
