ShenGeDecomposeDetailView = ShenGeDecomposeDetailView or BaseClass(BaseView)

local COLUMN = 2
local PAGE_NUM = 4		-- 一页格子数

function ShenGeDecomposeDetailView:__init()
	self.ui_config = {"uis/views/shengeview", "ShenGeDecomposeDetailView"}
	self:SetMaskBg(true)
	self.play_audio = true
	self.fight_info_view = true
	self.quality = 0
	self.is_select = false
	self.max_pagg_count = 0
	self.now_page = 1
end

function ShenGeDecomposeDetailView:ReleaseCallBack()
	for _, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	if nil ~= ShenGeData.Instance then
		ShenGeData.Instance:UnNotifyDataChangeCallBack(self.data_change_event)
		self.data_change_event = nil
	end

	-- 清理变量
	self.list_view = nil
	self.cur_page = nil
	self.max_page = nil
	self.fragments = nil
end

function ShenGeDecomposeDetailView:LoadCallBack()
	self.cell_list = {}

	self:ListenEvent("CloseWindow", BindTool.Bind(self.CloseWindow, self))
	self:ListenEvent("OnClickDecompose", BindTool.Bind(self.OnClickDecompose, self))

	self.list_view = self:FindObj("ListView")
	local list_delegate = self.list_view.page_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	self.list_view.scroll_rect.onValueChanged:AddListener(BindTool.Bind(self.OnValueChanged, self))

	self.cur_page = self:FindVariable("CurPage")
	self.max_page = self:FindVariable("MaxPage")
	self.fragments = self:FindVariable("Fragments")

	self.data_change_event = BindTool.Bind(self.OnDataChange, self)
	ShenGeData.Instance:NotifyDataChangeCallBack(self.data_change_event)
end

function ShenGeDecomposeDetailView:OpenCallBack()
	self:SetScrollInfo()
	self:RefreshScroller()
	self:FlushFragments()
end

function ShenGeDecomposeDetailView:RefreshScroller()
	if self.list_view.list_view.isActiveAndEnabled then
		self.list_view.list_view:Reload()
		self.list_view.list_page_scroll2:JumpToPageImmidateWithoutToggle(0)
	end
end

function ShenGeDecomposeDetailView:SetScrollInfo()
	self.list_data = ShenGeData.Instance:GetShenGeSameQualityItemData(self.quality)

	self.max_pagg_count = math.ceil(#self.list_data / COLUMN / PAGE_NUM)
	self.list_view.list_page_scroll2:SetPageCount(self.max_pagg_count)

	self.now_page = 1
	self.cur_page:SetValue(1)
	self.max_page:SetValue(self.max_pagg_count)
end

function ShenGeDecomposeDetailView:SetQuality(quality)
	self.quality = quality or 0
end

function ShenGeDecomposeDetailView:SetCallBack(call_back)
	self.call_back = call_back
end

function ShenGeDecomposeDetailView:SetIsSelect(is_select)
	self.is_select = is_select
end

function ShenGeDecomposeDetailView:CloseCallBack()
	if nil ~= self.call_back then
		self.call_back(self.quality, self.is_select)
		self.call_back = nil
	end
end

function ShenGeDecomposeDetailView:CloseWindow()
	self:Close()
end

function ShenGeDecomposeDetailView:OnClickDecompose()
	local list = ShenGeData.Instance:GetShenGeSameQualityItemData(self.quality)
	local send_index_list = {}
	for _, v in pairs(list) do
		if v.is_select then
			table.insert(send_index_list, v.shen_ge_data.index)
		end
	end

	if #send_index_list <= 0 then
		return
	end

	local ok_func = function()
		ShenGeCtrl.Instance:SendShenGeSystemReq(SHENGE_SYSTEM_REQ_TYPE.SHENGE_SYSTEM_REQ_TYPE_DECOMPOSE, 0, 0, 0, 0, #send_index_list, send_index_list)
		ShenGeData.Instance:ClearOneKeyDecomposeData()
	end

	if self.quality >= 2 then
		TipsCtrl.Instance:ShowCommonTip(ok_func, nil, Language.ShenGe.DecomposeTip , nil, nil, true, false, "decompose_detail_shen_ge", false, "", "", false, nil, true, Language.Common.Cancel, nil, false)
		return
	end

	ok_func()
end

function ShenGeDecomposeDetailView:OnValueChanged(normalizedPosition)
	local now_page = self.list_view.list_page_scroll2:GetNowPage() + 1
	if now_page ~= self.now_page then
		self.cur_page:SetValue(now_page)
		self.now_page = now_page
	end
end

function ShenGeDecomposeDetailView:OnDataChange(info_type, param1, param2, param3, bag_list)
	if not self:IsOpen() then return end

	if info_type == SHENGE_SYSTEM_INFO_TYPE.SHENGE_SYSTEM_INFO_TYPE_ALL_MARROW_SCORE_INFO
		or info_type == SHENGE_SYSTEM_INFO_TYPE.SHENGE_SYSTEM_INFO_TYPE_ALL_BAG_INFO then
		self:SetScrollInfo()
		self:RefreshScroller()
		self:FlushFragments()
	end
end

function ShenGeDecomposeDetailView:GetNumberOfCells()
	return math.ceil(#ShenGeData.Instance:GetShenGeSameQualityItemData(self.quality) / COLUMN)
end

function ShenGeDecomposeDetailView:RefreshCell(data_index, cellObj)
	local cell = self.cell_list[cellObj]
	if nil == cell then
		cell = ShenGeDetailGroup.New(cellObj)
		-- cell:SetToggleGroup(self.list_view.toggle_group)
		self.cell_list[cellObj] = cell
	end

	for i = 1, COLUMN do
		local index = (data_index)*COLUMN + i
		cell:SetIndex(i, index)
		local data = self.list_data[index]
		cell:SetActive(i, (data ~= nil and data.item_id > 0))
		cell:SetShenGeQuality(i, self.quality)
		cell:SetData(i, data)
		cell:SetToggleChangeCallBack(i, BindTool.Bind(self.OnSelectCallBack, self))
	end
end

function ShenGeDecomposeDetailView:FlushFragments()
	local fragment_num = 0
	local return_score = 0
	for k, v in pairs(self.list_data) do
		if v.is_select then
			cfg = ShenGeData.Instance:GetShenGeAttributeCfg(v.shen_ge_data.type, v.shen_ge_data.quality, v.shen_ge_data.level)
			return_score = cfg and cfg.return_score or 0
			fragment_num = fragment_num + return_score
		end
	end

	self.fragments:SetValue(fragment_num)
end

function ShenGeDecomposeDetailView:OnSelectCallBack()
	self:FlushFragments()
end

-------------------ShenGeDetailGroup-----------------------
ShenGeDetailGroup = ShenGeDetailGroup or BaseClass(BaseRender)
function ShenGeDetailGroup:__init()
	self.item_list = {}
	for i = 1, COLUMN do
		local bag_item = ShenGeDetailCell.New(self:FindObj("Item" .. i))
		table.insert(self.item_list, bag_item)
	end
end

function ShenGeDetailGroup:__delete()
	for k, v in ipairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
end

function ShenGeDetailGroup:SetActive(i, state)
	self.item_list[i]:SetActive(state)
end

function ShenGeDetailGroup:SetData(i, data)
	self.item_list[i]:SetData(data)
end

-- function ShenGeDetailGroup:SetToggleGroup(group)
-- 	for k, v in ipairs(self.item_list) do
-- 		v:SetToggleGroup(group)
-- 	end
-- end

function ShenGeDetailGroup:SetIndex(i, index)
	self.item_list[i]:SetIndex(index)
end

function ShenGeDetailGroup:SetShenGeQuality(i, quality)
	self.item_list[i]:SetShenGeQuality(quality)
end

function ShenGeDetailGroup:SetToggleChangeCallBack(i, call_back)
	self.item_list[i]:SetToggleChangeCallBack(call_back)
end


-------------------ShenGeDetailCell-----------------------
ShenGeDetailCell = ShenGeDetailCell or BaseClass(BaseCell)
function ShenGeDetailCell:__init()
	self.shen_ge_quality = 0

	self.level_des = self:FindVariable("LevelDes")
	self.attr_des_1 = self:FindVariable("AttrDes1")
	self.attr_des_2 = self:FindVariable("AttrDes2")
	self.attr_des_3 = self:FindVariable("AttrDes3")
	
	self.show_repeat = self:FindVariable("ShowRepeat")
	local item = ItemCell.New()
	item:SetInstanceParent(self:FindObj("ItemCell"))
	item:SetData()
	self.item_cell = item

	self.qualityBao = self:FindVariable("QualityBao")	
	self.show_qualityItem = self:FindVariable("ShowQualityItem")
	self.shen_back_level = self:FindVariable("ShenBackLevel")
	self.is_show_attr = self:FindVariable("IsShowAttr")


	self.select_toggle = self:FindObj("SelectToggle").toggle
	self.select_toggle.isOn = false
	self.root_node.toggle.isOn = false
	self.select_toggle:AddValueChangedListener(BindTool.Bind(self.OnSelectToggleChange, self))
	self.root_node.toggle:AddValueChangedListener(BindTool.Bind(self.OnRootNodeToggleChange, self))
end

function ShenGeDetailCell:__delete()
	self.item_cell:DeleteMe()
	self.item_cell = nil
end

function ShenGeDetailCell:SetShenGeQuality(quality)
	self.shen_ge_quality = quality
end

function ShenGeDetailCell:SetToggleGroup(group)
	self.root_node.toggle.group = group
end

function ShenGeDetailCell:SetToggleChangeCallBack(call_back)
	self.call_back = call_back
end

function ShenGeDetailCell:OnSelectToggleChange(is_on)
	if self.data == nil then
		return
	end
	
	self.data.is_select = is_on
	self.root_node.toggle.isOn = is_on

	if nil ~= self.call_back then
		self.call_back()
	end
end

function ShenGeDetailCell:OnRootNodeToggleChange(is_on)
	self.data.is_select = is_on
	self.select_toggle.isOn = is_on

	if nil ~= self.call_back then
		self.call_back()
	end
end

function ShenGeDetailCell:OnFlush()
	self.show_qualityItem:SetValue(false)
	
	if not self.data or not next(self.data) then
		return
	end
	self.item_cell:SetData(self.data)
	self.select_toggle.isOn = self.data.is_select
	self.root_node.toggle.isOn = self.data.is_select

	local shen_ge_data = self.data.shen_ge_data
	if nil == shen_ge_data then
		return
	end

	self.qualityBao:SetAsset(ResPath.GetRomeNumImage(self.data.shen_ge_data.quality))
	self.show_qualityItem:SetValue(true)

	self.shen_back_level:SetValue(self.data.shen_ge_data.level)

	local attr_cfg = ShenGeData.Instance:GetShenGeAttributeCfg(shen_ge_data.type, shen_ge_data.quality, shen_ge_data.level)
	if nil == attr_cfg then
		return
	end
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	if nil == item_cfg then
		return
	end
	local level_str = attr_cfg.name
	local level_to_color = "<color="..SOUL_NAME_COLOR[item_cfg.color]..">"..level_str.."</color>"
	self.level_des:SetValue(level_to_color)
	self.is_show_attr:SetValue(true)
	for i = 0, 2 do
		local attr_value = attr_cfg["add_attributes_"..i]
		local attr_type = attr_cfg["attr_type_"..i]
		if attr_value > 0 then
		    --if attr_type == 8 or attr_type == 9 then
			-- 	self["attr_des_"..(i + 1)]:SetValue(Language.ShenGe.AttrTypeName[attr_type].."  +"..(attr_value / 100).."%")
			-- else
				self["attr_des_"..(i + 1)]:SetValue(Language.ShenGe.AttrTypeName[attr_type].."  +"..attr_value)
			--end
		else
			self["attr_des_"..(i + 1)]:SetValue("")
			self.is_show_attr:SetValue(false)

		end
	end
end