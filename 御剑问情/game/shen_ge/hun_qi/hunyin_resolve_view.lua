HunYinResolve = HunYinResolve or BaseClass(BaseView) 

HunYinResolve.LingzhiColor = {
	blue = 1,	
	purple = 2,
	orange = 3,
	red = 4,
}

function HunYinResolve:__init()
	self.ui_config = {"uis/views/hunqiview_prefab", "HunYinResolve"}
end

function HunYinResolve:__delete()
	-- body
end
-- 创建完调用
function HunYinResolve:LoadCallBack()
	self.cell_count = 40
	self.offset_x = 0
	self.purple = self:FindVariable("purple")
	self.blue = self:FindVariable("blue")
	self.orange = self:FindVariable("orange")
	self.lingxingzhi_add = self:FindVariable("lingxingzhi") 
	self.lingxingzhi_add:SetValue(self:GetColorStr(HunQiData.Instance:GetLingshuExp()))
	self.show_left_arrow = self:FindVariable("show_left_arrow")
	self.show_right_arrow = self:FindVariable("show_right_arrow")

	self.check_list_obj = {}
	for i=1,5 do
 		self.check_list_obj[i] = self:FindObj("Check_"..i)
	end

	self:ListenEvent("CloseWindow", BindTool.Bind(self.CloseWindow, self))
	self:ListenEvent("ClickRight", BindTool.Bind(self.ClickRight, self))
	self:ListenEvent("ClickLeft", BindTool.Bind(self.ClickLeft, self))
	self:ListenEvent("ClickResolve", BindTool.Bind(self.ClickResolve, self))
	self:ListenEvent("Click", BindTool.Bind(self.Click, self))

	-- 魂印列表
    self.hunyin_cell_list = {}
    self.hunyin_cell_list_view = self:FindObj("HunYinCells")
    local page_simple_delegate = self.hunyin_cell_list_view.page_simple_delegate
    page_simple_delegate.NumberOfCellsDel = BindTool.Bind(self.NumberOfCellsDel, self)
    page_simple_delegate.CellRefreshDel = BindTool.Bind(self.CellRefreshDel, self)
	self.hunyin_cell_list_view.scroll_rect.onValueChanged:AddListener(BindTool.Bind(self.OnValueChanged, self))
    self.current_index = 0
    self.curren_click_cell_index = -1
    self.select_item_id = 0
    self.current_click_item_id = 0
    self.current_addExp = 0
    self.hunyin_info = HunQiData.Instance:GetHunQiInfo()
    self.item_id_list = {}
	for k,v in pairs(self.hunyin_info) do
		table.insert(self.item_id_list, k)
	end


	self.add_blue_lingzhi = 0
	self.add_purple_lingzhi = 0
	self.add_orange_lingzhi =0
	self.add_colorlingzhi_list = {}
end

-- 销毁前调用
function HunYinResolve:ReleaseCallBack()
	-- 清理变量和对象
	self.purple = nil
	self.blue = nil
	self.orange = nil
	self.hunyin_cell_list_view = nil
	self.current_index = 0
    self.curren_click_cell_index = -1
	self.lingxingzhi_add = nil
	self.show_left_arrow = nil
	self.show_right_arrow = nil
	-- self.lingzhi_text_list = {}
	for k,v in pairs(self.hunyin_cell_list) do
		v:DeleteMe()
	end
	self.hunyin_cell_list = {}
	self:RemoveDelayTime()
end

-- 打开后调用
function HunYinResolve:OpenCallBack()
    self.hunyin_cell_list_view.list_view:JumpToIndex(0)
    self:FlushHunYinCellList()
    self:InitLingzhi()
    self:FlushHighLight(0.2)
end

-- 关闭前调用
function HunYinResolve:CloseCallBack()
	-- override
end

function HunYinResolve:FlushHunYinCellList()
	self:GetAllItemInfo(self.item_id_list)
	self.hunyin_cell_list_view.list_view:Reload()
end

function HunYinResolve:InitLingzhi()
	local lingzhi_info = ExchangeData.Instance:GetAllLingzhi()
	self.current_purple = lingzhi_info.purple
	self.current_blue = lingzhi_info.blue
	self.current_orange = lingzhi_info.orange
	self.purple:SetValue(self.current_purple)
	self.blue:SetValue(self.current_blue)
	self.orange:SetValue(self.current_orange)
end


-- 刷新
function HunYinResolve:OnFlush(param_list)
	for k,v in pairs(param_list) do
		if k == "beibao" then
			self:FlushHunYinCellList()
			self:FlushLingXingZhi()
		end
	end
end

-- 获取背包中所有魂印配置信息
function HunYinResolve:GetAllItemInfo(item_id_list)
	self.all_hunyin_info = {}
	for k, v in pairs(item_id_list) do
		local count = ItemData.Instance:GetItemNumInBagById(v)
		if count > 0 then		
			local item_cfg = self.hunyin_info[v][1]
			if nil == item_cfg then
				print_error("itme_cfg is nil", v)
			else
				--如果count大于每组上限数 拆分
				local group_count = math.ceil(count / 999)
				--如果组数超过1组
				if group_count > 1 then
					for i=1, group_count - 1 do
						table.insert(self.all_hunyin_info,
						{
							item_id = v,
							num = 999,
							is_bind = 0,
							hunyin_color = item_cfg.hunyin_color,
							discard_exp = item_cfg.discard_exp,
							blue_lingzhi = item_cfg.blue_lingzhi,
							purple_lingzhi = item_cfg.purple_lingzhi,
							orange_lingzhi = item_cfg.orange_lingzhi,
						})
					end
					count = count % 999
					table.insert(self.all_hunyin_info,
					{
						item_id = v,
						num = count,
					 	is_bind = 0,
					 	hunyin_color = item_cfg.hunyin_color,
					 	discard_exp = item_cfg.discard_exp,
					 	blue_lingzhi = item_cfg.blue_lingzhi,
					 	purple_lingzhi = item_cfg.purple_lingzhi,
					 	orange_lingzhi = item_cfg.orange_lingzhi,
				 	})
				else
					table.insert(self.all_hunyin_info,
					{
						item_id = v,
						num = count,
						is_bind = 0,
						hunyin_color = item_cfg.hunyin_color,
						discard_exp = item_cfg.discard_exp,
						blue_lingzhi = item_cfg.blue_lingzhi,
						purple_lingzhi = item_cfg.purple_lingzhi,
						orange_lingzhi = item_cfg.orange_lingzhi,
					})
				end
			end
		end
	end
end

function HunYinResolve:NumberOfCellsDel()
	local cell_count = #self.all_hunyin_info % 8
	if cell_count == 0 then
		self.cell_count = #self.all_hunyin_info
	else
		self.cell_count = #self.all_hunyin_info - cell_count + 8
	end
	if self.cell_count == 0 then
		self.cell_count = 8
	end

	if self.cell_count <= 8 then				--如果当前物品少于等于8个，则把左右箭头都隐藏
		self.show_left_arrow:SetValue(true)
		self.show_right_arrow:SetValue(true)
	end

	return self.cell_count
end

function HunYinResolve:OnValueChanged(value)
	--self.current_index = GameMath.Round((400 * value.x) / 100)
	if value.x <= 0 then
		value.x = 0
		self.show_left_arrow:SetValue(true)
	else
		self.show_left_arrow:SetValue(false)
	end

	if value.x >= 1 then
		self.show_right_arrow:SetValue(true)
	else
		self.show_right_arrow:SetValue(false)
	end

	if self.cell_count <= 8 then
		self.show_left_arrow:SetValue(true)
		self.show_right_arrow:SetValue(true)
	end

	local max = self.cell_count - 8

	self.current_index = GameMath.Round((max * 100 * value.x) / 100)
	self:FlushHighLight(0.05) 
end


--格子每次进来刷新
function HunYinResolve:CellRefreshDel(data_index, cell)
	data_index = data_index + 1
	local item_cell = self.hunyin_cell_list[cell]
	if nil == item_cell then
		item_cell = ItemCell.New()
		item_cell:SetInstanceParent(cell.gameObject)
		--item_cell:SetToggleGroup(self.hunyin_cell_list_view.toggle_group) 
		self.hunyin_cell_list[cell] = item_cell
	end

	if data_index % 8 == 2 then 
		data_index = data_index + 3
	elseif data_index % 8 == 3 then
		data_index = data_index - 1
	elseif data_index % 8 == 4 then
		data_index = data_index + 2
	elseif data_index % 8 == 5 then
		data_index = data_index - 2
	elseif data_index % 8 == 6 then
		data_index = data_index + 1
	elseif data_index % 8 == 7 then
		data_index = data_index - 3
	end

	local current_data = self.all_hunyin_info[data_index]
	item_cell:SetData(current_data)
	item_cell:SetIndex(data_index)

	if current_data then
		item_cell:ListenClick(BindTool.Bind(self.OnClickItem, self, item_cell))	
		item_cell:SetInteractable(true)
		item_cell.icon:SetAsset(ResPath.GetItemIcon(HunQiData.Instance:GetHunYinItemIconId(current_data.item_id)))
		if current_data.num > 1 then
			item_cell.show_number:SetValue(true)
			item_cell.number:SetValue(current_data.num)
		end
	else
		item_cell:SetInteractable(false)
	end
	--self.current_index = data_index
	-- if data_index == self.curren_click_cell_index then
	-- 	local item_data = item_cell:GetData()
	-- 	if nil ~= next(item_data) then
	-- 		item_cell.root_node.toggle.isOn = true
	-- 		self:FlushLingXingZhi((item_data.discard_exp * item_data.num))
	-- 		self.current_click_item_id = item_data.item_id
	-- 	else
	-- 		item_cell.root_node.toggle.isOn = false
	-- 		self:FlushLingXingZhi()
	-- 	end
	-- else
	-- 	item_cell.root_node.toggle.isOn = false
	-- end
end

function HunYinResolve:OnClickItem(item_cell)
	self.curren_click_cell_index = item_cell:GetIndex()
	
	self.current_click_item_id = item_cell:GetData().item_id
	-- if item_cell.root_node.toggle.isOn then
	-- 	self:FlushLingXingZhi(item_cell:GetData().discard_exp * item_cell:GetData().num)
	-- else
	-- 	self:FlushLingXingZhi()
	-- end
	local total_exp = 0
	local blue_lingzhi = 0
	local purple_lingzhi = 0
	local orange_lingzhi = 0

	for k,v in pairs(self.hunyin_cell_list) do
		if v:GetToggleIsOn() then
			local data = v:GetData()
			blue_lingzhi = data.blue_lingzhi * data.num
			purple_lingzhi = data.purple_lingzhi * data.num
			orange_lingzhi = data.orange_lingzhi * data.num
			total_exp = total_exp + data.discard_exp * data.num

			local lingzhi = 0
			local colorType = 0
			
			if blue_lingzhi>0 then
				lingzhi = blue_lingzhi
				colorType = self.LingzhiColor.blue
			end

			if purple_lingzhi>0 then
				lingzhi = purple_lingzhi 
				colorType = self.LingzhiColor.purple
			end

			if orange_lingzhi>0 then
				lingzhi = orange_lingzhi 
				colorType = self.LingzhiColor.orange
			end

			if colorType>0 and lingzhi>0 then
				self:SetAddlingzhi(v:GetIndex(), lingzhi, colorType)
			end
		end
	end
	self:FlushLingXingZhi(total_exp)

	if not item_cell:GetToggleIsOn() then
		self.current_click_item_id = 0
	end

	if item_cell:GetToggleIsOn() then
		item_cell:SetIconGrayScale(true)
		item_cell:ShowHaseGet(true)

		self:FlushColorlingzhi()
	else
		item_cell:SetIconGrayScale(false)
		item_cell:ShowHaseGet(false)

		
		self:FlushColorlingzhi(self.curren_click_cell_index)
	end

	--如果有勾选颜色toggle，在按item的时候把勾选去掉
	for k1,v1 in pairs(self.check_list_obj) do
		if v1.toggle.isOn == true then
			v1.toggle.isOn = false
			self:FlushHighLight(0)
			self:FlushLingXingZhi()

			for i,j in pairs(self.add_colorlingzhi_list) do
				self:FlushColorlingzhi(i)
			end
		end
	end
end

function  HunYinResolve:GetColorStr(curlingzhi, lingzhi)
	local str = ""
	str = curlingzhi ~=nil and curlingzhi or ""
	if nil~=lingzhi and lingzhi>0 then
		str = string.format(Language.HunQi.ColorLingZhi, curlingzhi, lingzhi)
	end
	return str
end

function HunYinResolve:FlushColorlingzhi(index)
	-- if index == nil then
	-- 	print_error("FlushColorlingzhi function param index is nil!")
	-- 	return 
	-- end

	local lingzhi_info = ExchangeData.Instance:GetAllLingzhi()
	self.current_purple = lingzhi_info.purple
	self.current_blue = lingzhi_info.blue
	self.current_orange = lingzhi_info.orange

	
	if nil ~= index then
		local lingzhi = self:GetAddLingzhi(index)~=nil and self:GetAddLingzhi(index).lingzhi or 0
		lingzhi = (lingzhi>=0) and lingzhi or 0
		local color = self:GetAddLingzhi(index)~=nil and self:GetAddLingzhi(index).color or 0
		if color ==0 then
			return 
		end

		local purplingzhi = color == self.LingzhiColor.purple and lingzhi or 0
		local bluelingzhi = color == self.LingzhiColor.blue and lingzhi or 0
		local orangelingzhi = color == self.LingzhiColor.orange and lingzhi or 0

		if color == self.LingzhiColor.purple then
			self.add_purple_lingzhi = self.add_purple_lingzhi - purplingzhi
		end

		if color == self.LingzhiColor.blue then
			self.add_blue_lingzhi = self.add_blue_lingzhi - bluelingzhi
		end

		if color == self.LingzhiColor.orange then
			self.add_orange_lingzhi = self.add_orange_lingzhi - orangelingzhi
		end

		self:ClearAddlingzhi(index)
	end

	

	self.purple:SetValue(self:GetColorStr(self.current_purple, self.add_purple_lingzhi))
	self.blue:SetValue(self:GetColorStr(self.current_blue, self.add_blue_lingzhi))
	self.orange:SetValue(self:GetColorStr(self.current_orange, self.add_orange_lingzhi))
end

function HunYinResolve:SetAddlingzhi(index, lingzhi, color)
	if nil == index then
		return	false
	end

	if nil == self.add_colorlingzhi_list[index] and nil ~= color and nil ~= lingzhi then
		self.add_colorlingzhi_list[index] = {}
		self.add_colorlingzhi_list[index].color = color
		self.add_colorlingzhi_list[index].lingzhi = (lingzhi > 0) and lingzhi or 0

		if color == self.LingzhiColor.purple then
			self.add_purple_lingzhi = self.add_purple_lingzhi + lingzhi
		end

		if color == self.LingzhiColor.blue then
			self.add_blue_lingzhi = self.add_blue_lingzhi + lingzhi
		end

		if color == self.LingzhiColor.orange then
			self.add_orange_lingzhi = self.add_orange_lingzhi + lingzhi 
		end

	else
		if nil == lingzhi then
			self.add_colorlingzhi_list[index].lingzhi = 0
		end
	end	

end

function HunYinResolve:GetAddLingzhi(index)
	if nil == index or nil == self.add_colorlingzhi_list[index] then
		return nil
	end

	return self.add_colorlingzhi_list[index]
end

function HunYinResolve:ClearAddlingzhi(index)
	if nil == index then
		self.add_colorlingzhi_list = nil
	else
		if nil == self.add_colorlingzhi_list[index] then
			return
		else
			self.add_colorlingzhi_list[index] = nil
		end
	end
end


function HunYinResolve:ClickLeft()
	local index = self.current_index - 8
	for k,v in pairs(self.hunyin_cell_list) do
		v.root_node.toggle.isOn = false
	end
	self:JumpToIndex(index)
end

function HunYinResolve:ClickRight()
	local index = self.current_index + 8
	for k,v in pairs(self.hunyin_cell_list) do
		v.root_node.toggle.isOn = false
	end
	self:JumpToIndex(index)
end

function HunYinResolve:JumpToIndex(index)
	local max = self.cell_count - 8
	index = index > max and max or index 
	if index < 0 then 
		index = 0
	end
	self.hunyin_cell_list_view.list_view:JumpToIndex(index)
end

function HunYinResolve:Click()
	local add_exp = 0
	local select_all = {}
	for k1,v1 in pairs(self.check_list_obj) do
		if v1.toggle.isOn == true then
			for k2,v2 in pairs(self.all_hunyin_info) do
			 	if v2.hunyin_color == k1 then
			 		table.insert(select_all, v2)
			 	end
			end
		end
	end
	for k,v in pairs(select_all) do
		add_exp = add_exp + v.num * v.discard_exp
	end

	for k,v in pairs(self.hunyin_cell_list) do
		local flag = false
		for k2,v2 in pairs(select_all) do
			if v:GetData().item_id ==  v2.item_id then
				flag = true
				local data = v:GetData()
				local lingzhi = 0
				local colorType = 0

				if data.blue_lingzhi * data.num>0 then
					lingzhi = data.blue_lingzhi * data.num
					colorType = self.LingzhiColor.blue
				end

				if data.purple_lingzhi * data.num>0 then
					lingzhi = data.purple_lingzhi * data.num
					colorType = self.LingzhiColor.purple
				end

				if data.orange_lingzhi * data.num>0 then
					lingzhi = data.orange_lingzhi * data.num
					colorType = self.LingzhiColor.orange
				end



				if colorType>0 and lingzhi>0 then
					self:SetAddlingzhi(v:GetIndex(), lingzhi, colorType)
				end

				self:FlushColorlingzhi()
			end
		end

		if not flag then
			self:FlushColorlingzhi(v:GetIndex())
		end
		

		v:SetHighLight(flag)
		v:SetIconGrayScale(flag)
		v:ShowHaseGet(flag)
	end


	self:FlushLingXingZhi(add_exp)
end

function HunYinResolve:FlushHighLight(delayTime)
		if self.timer == nil then   --避免短时间内重复调用多次
			self.timer =  GlobalTimerQuest:AddDelayTimer(
				function () 
					local select_all = {}
					for k1,v1 in pairs(self.check_list_obj) do
						if v1.toggle.isOn == true then
							for k2,v2 in pairs(self.all_hunyin_info) do
							 	if v2.hunyin_color == k1 then
							 		table.insert(select_all, v2)
							 	end
							end
						end
					end
					for k,v in pairs(self.hunyin_cell_list) do
						local flag = false
						for k2,v2 in pairs(select_all) do
							if v:GetData().item_id ==  v2.item_id then
								flag = true
							end
						end
						v:SetHighLight(flag)
						v:SetIconGrayScale(flag)
						v:ShowHaseGet(flag)
					end
					self:RemoveDelayTime()
				end 
			, delayTime)
		end
	
end

function HunYinResolve:RemoveDelayTime()
	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
end

function HunYinResolve:FlushLingXingZhi(add_value)
	add_value = add_value or 0
	self.current_addExp = add_value
	local current_exp = HunQiData.Instance:GetLingshuExp()
	if  add_value > 0 then
		self.lingxingzhi_add:SetValue(self:GetColorStr(current_exp,add_value))
	else
		self.lingxingzhi_add:SetValue(self:GetColorStr(current_exp))
	end
end

--点击分解
function HunYinResolve:ClickResolve()
	--所有要分解的魂印的配置表
	local count = 0
	local select_to_resolve = {}
	for k1,v1 in pairs(self.check_list_obj) do
		if v1.toggle.isOn == true then
			count = count + 1
			for k2,v2 in pairs(self.all_hunyin_info) do
			 	if v2.hunyin_color == k1 then
			 		table.insert(select_to_resolve, v2)
			 	end
			end
		end
	end
	--当前需要分解的物品在背包中的索引table
	local resolve_index_table = {}
	if select_to_resolve ~= {} then	
		for k,v in pairs(select_to_resolve) do
			local index = ItemData.Instance:GetItemIndex(v.item_id)
			table.insert(resolve_index_table, index)
		end
	end
	if 0 == count then
		-- for k,v in pairs(self.hunyin_cell_list) do
		-- 	if v.root_node.toggle.isOn then
		-- 		v.root_node.toggle.isOn = false
		-- 		self.select_item_id = v:GetData().item_id
		-- 		local index = ItemData.Instance:GetItemIndex(v:GetData().item_id)
		-- 		table.insert(resolve_index_table, index)
		-- 	end
		-- end
		for k,v in pairs(self.hunyin_cell_list) do
			if v:GetToggleIsOn() then
				local index = ItemData.Instance:GetItemIndex(v:GetData().item_id)
				table.insert(resolve_index_table, index)
			end
		end
		-- local index = ItemData.Instance:GetItemIndex(self.current_click_item_id)
		-- table.insert(resolve_index_table, index)
	end
	--如果没有选中签文
	if #resolve_index_table == 0 then
		local index = ItemData.Instance:GetItemIndex(0)
		table.insert(resolve_index_table, index) 
	end

	for k,v in pairs(self.hunyin_cell_list) do
		if v.root_node.toggle.isOn then
			v.root_node.toggle.isOn = false
		end
	end
	if resolve_index_table[1] == -1 then
		SysMsgCtrl.Instance:ErrorRemind(Language.HunQi.NotHunYin)  --提示未选择签文
	else
		SysMsgCtrl.Instance:ErrorRemind(string.format(Language.HunQi.GetLingXing,self.current_addExp))
	end
	HunQiCtrl.Instance:SendHunYiResolveReq(#resolve_index_table, resolve_index_table)
end

function HunYinResolve:CloseWindow()
	for k,v in pairs(self.hunyin_cell_list) do
		if v.root_node.toggle.isOn then
			v.root_node.toggle.isOn = false
		end
	end
	self:Close()
end

function HunYinResolve:OnMoveEnd(obj)
	if not IsNil(obj) then
		GameObjectPool.Instance:Free(obj)
	end
	self.purple:SetValue(self.current_purple)
	self.blue:SetValue(self.current_blue)
	self.orange:SetValue(self.current_orange)
end

