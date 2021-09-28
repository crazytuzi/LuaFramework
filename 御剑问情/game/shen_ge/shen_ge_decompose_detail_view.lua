ShenGeDecomposeDetailView = ShenGeDecomposeDetailView or BaseClass(BaseView)

local COLUMN = 2
local PAGE_NUM = 4		-- 一页格子数
local MAXPAGENUM = 15

function ShenGeDecomposeDetailView:__init()
	self.ui_config = {"uis/views/shengeview_prefab", "ShenGeDecomposeDetailView"}
	self.play_audio = true
	self.fight_info_view = true
	self.quality = 0
	self.type_index= 0
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
	self.show_condition_list1 = nil
	self.show_condition_list2 = nil
	self.show_open_conditon_list = nil

	for k,v in pairs(self.level_cell_list) do
		v:DeleteMe()
	end
	self.level_cell_list = {}

	for k,v in pairs(self.type_cell_list) do
		v:DeleteMe()
	end
	self.type_cell_list = {}
	
	for i=1,MAXPAGENUM do
		self["page_toggle" .. i] = nil
	end
	self.pag_toggle_list = nil
	
	self.level_text = nil
	self.type_text = nil
	self.level_list = nil
	self.type_list = nil
	self.item_data_level_list = {}
	self.item_data_type_list = {}
	self.item_data_two_search_list = {}
	self.pag_toggle_list = {}
	self.search_config = {
		quality = false,
		type_index = false,
	}

end

function ShenGeDecomposeDetailView:LoadCallBack()
	self.cell_list = {}

	self:ListenEvent("CloseWindow", BindTool.Bind(self.CloseWindow, self))
	self:ListenEvent("OnClickDecompose", BindTool.Bind(self.OnClickDecompose, self))
	self:ListenEvent("OpenConditonList1",BindTool.Bind(self.OpenConditonList1, self))
	self:ListenEvent("OpenConditonList2",BindTool.Bind(self.OpenConditonList2, self))
	self:ListenEvent("OnOpenConditonListBlock",BindTool.Bind(self.OnOpenConditonListBlock, self))

	self.list_view = self:FindObj("ListView")
	local list_delegate = self.list_view.page_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	self.list_view.list_view:Reload()
	self.list_view.list_page_scroll2:JumpToPageImmidate(0)
	self.list_view.scroll_rect.onValueChanged:AddListener(BindTool.Bind(self.OnValueChanged, self))

	self.cur_page = self:FindVariable("CurPage")
	self.max_page = self:FindVariable("MaxPage")
	self.fragments = self:FindVariable("Fragments")
	self.show_condition_list1 = self:FindVariable("ShowConditionList1")
	self.show_condition_list2 = self:FindVariable("ShowConditionList2")
	self.level_text = self:FindVariable("LevelText")
	self.type_text = self:FindVariable("TypeText")
	self.show_open_conditon_list = self:FindVariable("ShowOpenConditonList")

	self.data_change_event = BindTool.Bind(self.OnDataChange, self)
	ShenGeData.Instance:NotifyDataChangeCallBack(self.data_change_event)
	self.level_cell_list = {}
	self.type_cell_list = {}
	self.item_data_level_list = {}
	self.item_data_type_list = {}
	self.item_data_two_search_list = {}
	self.pag_toggle_list = {}

	for i=1,MAXPAGENUM do
		self["page_toggle" .. i] = self:FindObj("PageToggle" .. i) 
        table.insert(self.pag_toggle_list, self["page_toggle" .. i])
	end

	self.search_config = {
		quality = false,
		type_index = false,
	}

end

function ShenGeDecomposeDetailView:OpenCallBack()
	self:SetScrollInfo()
	self:RefreshScroller()
	self:FlushFragments()
	self:CreateLevelList()
	self:CreateTypeList()
end

function  ShenGeDecomposeDetailView:OnFlush()
	ShenGeData.Instance:GetAllShenGeItemData()
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
	if not self.search_config.quality and not self.search_config.type_index then
		self.list_data = ShenGeData.Instance:GetAllShenGeItemData()
	elseif self.search_config.quality and not self.search_config.type_index then
		self.list_data = self.item_data_level_list
	elseif not self.search_config.quality and self.search_config.type_index then
		self.list_data = self.item_data_type_list
	else
		self.list_data = self.item_data_two_search_list
	end

	for i=1,MAXPAGENUM do
		self.pag_toggle_list[i]:SetActive(false)
		self.pag_toggle_list[i].toggle.isOn= false
	end

	local page_num_info = math.ceil(#self.list_data / COLUMN / PAGE_NUM)
	if page_num_info >= MAXPAGENUM then
		self.max_pagg_count = MAXPAGENUM
	else
		self.max_pagg_count = page_num_info
	end
	self.list_view.list_page_scroll2:SetPageCount(page_num_info)
	for i=1,self.max_pagg_count do
		self.pag_toggle_list[i]:SetActive(true)
		if i == 1 then
			self.pag_toggle_list[i].toggle.isOn = true
		end 

	end

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

function ShenGeDecomposeDetailView:OpenConditonList1()
	self.is_show_condition_list1 = not self.is_show_condition_list1
	self.show_condition_list1:SetValue(self.is_show_condition_list1)
	self.show_open_conditon_list:SetValue(self.is_show_condition_list1)
end

function ShenGeDecomposeDetailView:OpenConditonList2()
	self.is_show_condition_list2 = 	not self.is_show_condition_list2
	self.show_condition_list2:SetValue(self.is_show_condition_list2)
	self.show_open_conditon_list:SetValue(self.is_show_condition_list2)
end

function ShenGeDecomposeDetailView:OnOpenConditonListBlock()
	self.is_show_condition_list1 = false
	self.is_show_condition_list2 = false
	self.show_condition_list1:SetValue(self.is_show_condition_list1)
	self.show_condition_list2:SetValue(self.is_show_condition_list2)
	self.show_open_conditon_list:SetValue(false)
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
	local list = self.list_data
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
		ShenGeCtrl.Instance:SendShenGeSystemReq(SHENGE_SYSTEM_REQ_TYPE.SHENGE_SYSTEM_REQ_TYPE_DECOMPOSE, 0, 0, 0, #send_index_list, send_index_list)
		ShenGeData.Instance:ClearOneKeyDecomposeData()
		if self.search_config.quality and self.search_config.type_index  or not self.search_config.quality and not self.search_config.type_index  then
			local list = self:ListDataChange(self.item_data_two_search_list)
			self.item_data_two_search_list = list
			self.item_data_level_list = self:ListDataChange(self.item_data_level_list)
			self.item_data_type_list = self:ListDataChange(self.item_data_type_list)
		elseif self.search_config.quality then
			local list = self:ListDataChange(self.item_data_level_list)
			self.item_data_level_list = list
		elseif self.search_config.type_index then
			local list = self:ListDataChange(self.item_data_type_list)
			self.item_data_type_list = list
		end
	end

	if self.quality >= 2 then
		TipsCtrl.Instance:ShowCommonTip(ok_func, nil, Language.ShenGe.DecomposeTip , nil, nil, true, false, "decompose_detail_shen_ge", false, "", "", false, nil, true, Language.Common.Cancel, nil, false)
		return
	end

	ok_func()
end

function ShenGeDecomposeDetailView:ListDataChange(list)
	local cur_lit = list
	local decompose_after_list = {}
	local index = 1
	for k,v in pairs(cur_lit) do
		if v.is_select == false then
			decompose_after_list[index] = v
			index = index + 1
		end
	end
	return decompose_after_list
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
	return math.ceil((#self.list_data + 1) / COLUMN)
	
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
		local cur_index = index
		if not self.search_config.quality and not self.search_config.type_index or self.quality == -1 and self.type_index == -1 then
			cur_index = index -1
		end
		cell:SetIndex(i, cur_index)
		local data = self.list_data[cur_index]
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
			return_score = cfg.return_score or 0
			fragment_num = fragment_num + return_score
		end
	end

	self.fragments:SetValue(fragment_num or 0)
end

function ShenGeDecomposeDetailView:OnSelectCallBack()
	self:FlushFragments()
end

function ShenGeDecomposeDetailView:HideSearchList()
	self.show_condition_list1:SetValue(false)
	self.show_condition_list2:SetValue(false)
	self.is_show_condition_list1 = false
	self.is_show_condition_list2 = false
end

function ShenGeDecomposeDetailView:CreateLevelList()
	self.level_list = self:FindObj("ConditionList1")
	local list_delegate = self.level_list.list_simple_delegate
	list_delegate.NumberOfCellsDel = function ()
		return 7
	end
	list_delegate.CellRefreshDel = function (cell, data_index)
		local cell_item = self.level_cell_list[cell]
		if cell_item == nil then
			cell_item = LevelListCell.New(cell.gameObject)
			self.level_cell_list[cell] = cell_item
		end

		cell_item:SetData(data_index)
		cell_item:ListenClick(BindTool.Bind(self.OnClickLevelCell, self, data_index))
	end
end

function ShenGeDecomposeDetailView:OnClickLevelCell(level)
	self:OnSearchLevel(level)
	self:SetSearchLevel(level)
	self:HideSearchList()
end

function ShenGeDecomposeDetailView:SetSearchLevel(level)   -- 0为搜索全部
	if level == 0 then
		self.level_text:SetValue(Language.ShenGe.SelectAllLevel)
	else
		self.level_text:SetValue(CommonDataManager.GetDaXie(level) .. Language.ShenGe.SelectLevel)
	end
end

function ShenGeDecomposeDetailView:CreateTypeList()
	self.type_list = self:FindObj("ConditionList2")
	local list_delegate = self.type_list.list_simple_delegate
	list_delegate.NumberOfCellsDel = function ()
		return #Language.ShenGe.ShenGeTypeName + 2
	end

	list_delegate.CellRefreshDel = function (cell, data_index)
		local cell_item = self.type_cell_list[cell]
		if cell_item == nil then
			cell_item = TypeListCell.New(cell.gameObject)
			self.type_cell_list[cell] = cell_item
		end
		local index = data_index - 1
		if index > 2 then
			--保证读的是神格属性显示10、11、12的内容 
			index = index + 7
		end
		cell_item:SetData(data_index - 1)
		cell_item:ListenClick(BindTool.Bind(self.OnClickTypeCell, self, index))
	end
end

function ShenGeDecomposeDetailView:OnClickTypeCell(type_index)
	self:OnSearchType(type_index)
	self:SetSearchType(type_index)
	self:HideSearchList()
end

function ShenGeDecomposeDetailView:SetSearchType(type_index)

	if type_index == -1 then
		self.type_text:SetValue(Language.ShenGe.SelectAllType)
	else
		if type_index > 2 then
			--保证读的是神格属性显示10、11、12的内容 
			type_index = type_index - 7
		end
		self.type_text:SetValue(Language.ShenGe.ShenGeTypeName[type_index])
	end
end

function ShenGeDecomposeDetailView:OnSearchLevel(quality)
	self.quality = quality - 1
	self.item_data_level_list = ShenGeData.Instance:GetSameKindItemData(1,self.quality)
	if self.search_config.type_index then
		if self.quality ~= -1 then
			self.search_config.quality = true
			if nil == next(self.item_data_type_list) then
				self:OnTwoSearch(self.item_data_two_search_list, "quality", self.quality)
			else
				self:OnTwoSearch(self.item_data_type_list, "quality", self.quality)
			end
		else
			self.search_config.quality = false
			if self.type_index == -1 then
				self.search_config.type_index =false
			end
		end
	else
		if self.quality == -1 then
			self.item_data_level_list = ShenGeData.Instance:GetAllShenGeItemData()
			self.search_config.quality = false
		else
			self.search_config.quality = true
		end
		
	end
	self:OnSearchFlush()
end

function ShenGeDecomposeDetailView:OnSearchType(type_index)
	self.type_index = type_index
	self.item_data_type_list = ShenGeData.Instance:GetSameKindItemData(2,self.type_index)
	if self.search_config.quality then
		if type_index ~= -1 then
			self.search_config.type_index = true
			if nil == next(self.item_data_level_list) then
				self:OnTwoSearch(self.item_data_two_search_list,"type", self.type_index)
			else
				self:OnTwoSearch(self.item_data_level_list,"type", self.type_index)
			end
		else
			self.search_config.type_index = false
			if self.quality == -1 then
				self.search_config.quality =false
			end
		end
	else
		if type_index == -1 then
			self.item_data_type_list = ShenGeData.Instance:GetAllShenGeItemData()
			self.search_config.type_index = false
		else
			self.search_config.type_index = true
		end
		
	end
	self:OnSearchFlush()
end

function ShenGeDecomposeDetailView:OnSearchFlush()
	self:SetScrollInfo()
	self:RefreshScroller()
	self:FlushFragments()
	if nil == next(self.list_data) then
		SysMsgCtrl.Instance:ErrorRemind(Language.ShenGe.SelectEmpty)
	end
end

function ShenGeDecomposeDetailView:OnTwoSearch(list,cur_search_type,index)
	local cur_data_list = list
	local index = index
	local search_type = cur_search_type
	local list = {}
	local num = 1
	for k,v in pairs(cur_data_list) do
		if v.shen_ge_data[search_type] == index then
			list[num] = v
			num = num + 1
		end
	end
	self.item_data_two_search_list = list
end
-- -------------------ShenGeDetailGroup-----------------------
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
	self.show_repeat = self:FindVariable("ShowRepeat")
	self.des_1 = self:FindVariable("Des1")
	self.des_2 = self:FindVariable("Des2")
	local item = ItemCell.New()
	item:SetInstanceParent(self:FindObj("ItemCell"))
	item:SetData()
	self.item_cell = item

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

	local attr_cfg = ShenGeData.Instance:GetShenGeAttributeCfg(shen_ge_data.type, shen_ge_data.quality, shen_ge_data.level)
	if nil == next(attr_cfg) then
		return
	end
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	if nil == item_cfg then
		return
	end
	local level_str = attr_cfg.name
	--local level_to_color = "<color="..SOUL_NAME_COLOR[item_cfg.color]..">"..level_str.."</color>"
	self.level_des:SetValue(level_str)

	for i = 0, 1 do
		self["des_"..(i + 1)]:SetValue(false)
		local attr_value = attr_cfg["add_attributes_"..i]
		local attr_type = attr_cfg["attr_type_"..i]
		if attr_value > 0 then
			if attr_type == 8 or attr_type == 9 then
				self["attr_des_"..(i + 1)]:SetValue(Language.ShenGe.AttrTypeName[attr_type].."  +"..(attr_value / 100).."%")
			else
				self["attr_des_"..(i + 1)]:SetValue(Language.ShenGe.AttrTypeName[attr_type].."  +"..attr_value)
			end
			self["des_"..(i + 1)]:SetValue(true)
		else
			self["attr_des_"..(i + 1)]:SetValue("")
			self["des_"..(i + 1)]:SetValue(false)
		end
	end
end


-----------------------------------------------------------------------
LevelListCell = LevelListCell or BaseClass(BaseCell)

function LevelListCell:__init(instance)
	self.name = self:FindVariable("Name")
end

function LevelListCell:__delete()

end

function LevelListCell:OnFlush()
	if self.data == 0 then
		self.name:SetValue(Language.ShenGe.SelectAllLevel)
	else
		self.name:SetValue(CommonDataManager.GetDaXie(self.data) .. Language.ShenGe.SelectLevel)
	end
end

function LevelListCell:ListenClick(handler)
	self:ClearEvent("OnClick")
	self:ListenEvent("OnClick", handler)
end

-----------------------------------------------------------------------

TypeListCell = TypeListCell or BaseClass(BaseCell)

function TypeListCell:__init(instance)
	self.name = self:FindVariable("Name")
end

function TypeListCell:__delete()

end

function TypeListCell:OnFlush()
	--self.name:SetValue(Language.Common.ColorNameToMarket[self.data])
	if self.data == -1 then
		self.name:SetValue(Language.ShenGe.SelectAllType)
	else
		self.name:SetValue(Language.ShenGe.ShenGeTypeName[self.data])
	end
end

function TypeListCell:ListenClick(handler)
	self:ClearEvent("OnClick")
	self:ListenEvent("OnClick", handler)
end