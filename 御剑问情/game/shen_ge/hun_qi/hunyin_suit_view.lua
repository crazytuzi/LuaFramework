HunYinSuitView = HunYinSuitView or BaseClass(BaseView)

HunYinSuitView.SuitMaxLevel	= 5 									--套装最大等级
function HunYinSuitView:__init()
	self.ui_config = {"uis/views/hunqiview_prefab", "HunYinSuitView"}
end

function HunYinSuitView:__delete()
	-- body
end
-- 创建完调用
function HunYinSuitView:LoadCallBack()
	self.suit_count = 0
	self.suit_info_list = {}
    -- self.suit_info_list_obj = self:FindObj("SuitList")
    -- local page_simple_delegate = self.suit_info_list_obj.page_simple_delegate
    -- page_simple_delegate.NumberOfCellsDel = BindTool.Bind(self.NumberOfCellsDel, self)
    -- page_simple_delegate.CellRefreshDel = BindTool.Bind(self.CellRefreshDel, self)
    -- self.suit_info_list_obj.list_view:JumpToIndex(0)
	self:ListenEvent("CloseWindow", BindTool.Bind(self.CloseWindow, self))
	self.hunyin_info = HunQiData.Instance:GetHunQiInfo()

	self.color_list = {}
	self.hunqi_color_number_list = { 0,0,0,0 } --用于记录当前镶嵌的各种魂器的数目
	for i=0,7 do
		table.insert(self.color_list, self:FindVariable("color_"..i))
	end

	self.cur_suit_name = self:FindVariable("cur_suit_name")			--当前套装名字
	self.next_suit_name = self:FindVariable("next_suit_name")		--下一级套装名字

	self.number_1 = self:FindVariable("number_1")					--当前套装数字
	self.number_2 = self:FindVariable("number_2")					--下一级套装数字

	self.cur_attr_1 = self:FindVariable("cur_attr_1")				--当前套装属性1
	self.cur_attr_2 = self:FindVariable("cur_attr_2")				--当前套装属性2
	self.next_attr_1 = self:FindVariable("next_attr_1")				--下一级套装属性1
	self.next_attr_2 = self:FindVariable("next_attr_2")				--下一级套装属性2
	self.cur_attr_1_name = self:FindVariable("cur_attr_1_name")
	self.cur_attr_2_name = self:FindVariable("cur_attr_2_name")
	self.next_attr_1_name = self:FindVariable("next_attr_1_name")
	self.next_attr_2_name = self:FindVariable("next_attr_2_name")
	self.cur_icon_1 = self:FindVariable("cur_icon_1")
	self.cur_icon_2 = self:FindVariable("cur_icon_2")
	self.next_icon_1 = self:FindVariable("next_icon_1")
	self.next_icon_2 = self:FindVariable("next_icon_2")
	self.is_zero = self:FindVariable("is_zero")						--套装零级
	self.is_top = self:FindVariable("is_top")						--套装满级
end

-- 销毁前调用
function HunYinSuitView:ReleaseCallBack()
	self.suit_count = nil
	--self.suit_info_list_obj = nil

	for k,v in pairs(self.color_list) do
		v = nil
	end
	self.color_list = {}
	
	for k,v in pairs(self.suit_info_list) do
		v:DeleteMe()
	end
	self.suit_info_list = {}

	self.cur_suit_name = nil
	self.next_suit_name = nil

	self.number_1 = nil
	self.number_2 =  nil

	self.cur_attr_1 = nil
	self.cur_attr_2 = nil
	self.next_attr_1 = nil
	self.next_attr_2 = nil
	self.cur_attr_1_name = nil
	self.cur_attr_2_name = nil
	self.next_attr_1_name = nil
	self.next_attr_2_name = nil
	self.cur_icon_1 = nil
	self.cur_icon_2 = nil
	self.next_icon_1 = nil
	self.next_icon_2 = nil
	self.is_zero = nil
	self.is_top = nil
end

-- 打开后调用
function HunYinSuitView:OpenCallBack()
	self.suit_level = HunYinSuitView.SuitMaxLevel
	self.current_hunqi_index, self.current_hunyin_list_info  = self.open_callback()
	local hunyin_color = 0
	local hunyin_id = 0
	self.hunqi_color_number_list = { 0,0,0,0,0,0 } 
	for k,v in pairs(self.current_hunyin_list_info) do
		hunyin_id = v.hunyin_id
		if 0 ~= hunyin_id then
			hunyin_color = self.hunyin_info[hunyin_id][1].hunyin_color
			--self.color_list[k]:SetValue(Language.HunYinSuit["color_"..hunyin_color])
			self.color_list[k]:SetValue(ToColorStr(Language.HunQi.HunYinName[k].."·"..Language.HunQi.HunYin, LIAN_QI_NAME_COLOR[hunyin_color]) )
			self.hunqi_color_number_list[hunyin_color] = self.hunqi_color_number_list[hunyin_color] + 1
		else
			hunyin_color = 0
			self.color_list[k]:SetValue(Language.HunQi.HunYinName[k].."·"..Language.HunQi.HunYin)
		end
		--level = 4  遍历当前魂印列表 如果有比4小的数 置换
		if self.suit_level > hunyin_color then
			self.suit_level = hunyin_color
		end
		--结果得到当前魂印等级最小的值
	end
	self.current_hunqi_index = self.current_hunqi_index - 1
	self.current_all_suit = HunQiData.Instance:GetHunYinSuitCfgByIndex(self.current_hunqi_index)
	local count = 0
	for k,v in pairs(self.current_all_suit) do
		count = count +1
	end
	self.suit_count = count
	--self.suit_info_list_obj.list_view:Reload()

	if self.suit_level > 0 and self.suit_level < 5 then  --套装等级为初级及以上顶级以下
		self.is_zero:SetValue(false)
		self.is_top:SetValue(false)
		self.cur_suit_name:SetValue(ToColorStr(self.current_all_suit[self.suit_level].name, LIAN_QI_NAME_COLOR[self.current_all_suit[self.suit_level].suit_color]))
		self.next_suit_name:SetValue(ToColorStr(self.current_all_suit[self.suit_level+1].name, LIAN_QI_NAME_COLOR[self.current_all_suit[self.suit_level+1].suit_color]))
		local temp = 0
		for i = 1, #self.hunqi_color_number_list do
			if i >= self.suit_level then
				temp = temp + self.hunqi_color_number_list[i]
			end
		end
		if temp < 8 then
			temp = ToColorStr(temp, RICH_TEXT_COLOR.RED)
		end
		self.number_1:SetValue(temp)

		temp = 0
		for i = 1, #self.hunqi_color_number_list do
			if i >= self.suit_level + 1 then
				temp = temp + self.hunqi_color_number_list[i]
			end
		end
		if temp < 8 then
			temp = ToColorStr(temp, RICH_TEXT_COLOR.RED)
		end
		self.number_2:SetValue(temp)
		self:SetAttr(true,self.suit_level)			--设置属性值
		self:SetAttr(false,self.suit_level + 1)		--设置属性值
	elseif self.suit_level == 0 then 	--没有套装
		self.is_zero:SetValue(true)
		self.is_top:SetValue(false)
		self.cur_suit_name:SetValue(ToColorStr(self.current_all_suit[self.suit_level+1].name, LIAN_QI_NAME_COLOR[self.current_all_suit[self.suit_level+1].suit_color]))
		local temp = 0
		for i = 1, #self.hunqi_color_number_list do
			if i >= self.suit_level + 1 then
				temp = temp + self.hunqi_color_number_list[i]
			end
		end
		if temp < 8 then
			temp = ToColorStr(temp, RICH_TEXT_COLOR.RED)
		end
		self.number_1:SetValue(temp)

		self:SetAttr(true,self.suit_level + 1)		--设置属性值
	elseif self.suit_level == 5 then	--套装顶级
		self.is_zero:SetValue(false)
		self.is_top:SetValue(true)
		self.cur_suit_name:SetValue(ToColorStr(self.current_all_suit[self.suit_level].name, LIAN_QI_NAME_COLOR[self.current_all_suit[self.suit_level].suit_color]))
		local temp = 0
		for i = 1, #self.hunqi_color_number_list do
			if i >= self.suit_level then
				temp = temp + self.hunqi_color_number_list[i]
			end
		end
		self.number_1:SetValue(temp)
		self:SetAttr(true,self.suit_level)			--设置属性值
	end


end
-- 设置套装属性
function HunYinSuitView:SetAttr(isCurrent,level)

	self.data = self.current_all_suit[level]
	local attr_table = {}
	for k,v in pairs(self.data) do
		if type(v)== "number" and v > 0 and k ~= "suit_color" and k ~= "hunqi_id" then
			table.insert(attr_table, Language.HunYinSuit[k])
			table.insert(attr_table, v)
		end
	end
	if isCurrent then
		self.cur_attr_1_name:SetValue(attr_table[1])
		self.cur_attr_1:SetValue(attr_table[2])
		self.cur_attr_2_name:SetValue(attr_table[3])
		self.cur_attr_2:SetValue(attr_table[4])
		self.cur_icon_1:SetAsset(ResPath.GetBaseAttrIcon(attr_table[1]))
		self.cur_icon_2:SetAsset(ResPath.GetBaseAttrIcon(attr_table[3]))
	else
		self.next_attr_1_name:SetValue(attr_table[1])
		self.next_attr_1:SetValue(attr_table[2])
		self.next_attr_2_name:SetValue(attr_table[3])
		self.next_attr_2:SetValue(attr_table[4])
		self.next_icon_1:SetAsset(ResPath.GetBaseAttrIcon(attr_table[1]))
		self.next_icon_2:SetAsset(ResPath.GetBaseAttrIcon(attr_table[3]))
	end
end

-- 关闭前调用
function HunYinSuitView:CloseCallBack()
	self.current_hunqi_index = nil
end

function HunYinSuitView:CellRefreshDel(data_index, cell)
	local item_cell = self.suit_info_list[cell]
	if nil == item_cell then
		item_cell = SuitInfoCell.New(cell.gameObject)
		self.suit_info_list[cell] = item_cell
	end
	--将套装等级通过index设置进去
	item_cell:SetCurrrentSuitLevel(self.suit_level)
	item_cell.parentsView = self
	item_cell:SetData(self.current_all_suit[data_index+1])
	item_cell:Flush()
end

function HunYinSuitView:NumberOfCellsDel()
	return self.suit_count
end

function HunYinSuitView:CloseWindow()
	self:Close()
end

function HunYinSuitView:SetOpenCallBack(callback)
	self.open_callback = callback
end
--------------------------SuitInfoCell-----------------------------
SuitInfoCell = SuitInfoCell or BaseClass(BaseCell)

function SuitInfoCell:__init()
	self.suit_name = self:FindVariable("suitname")				-- 套装名称
	self.font_color = self:FindVariable("color")				-- 字体颜色
	self.is_gain = self:FindVariable("isgain")					-- 获取提示
	self.tips_txt = self:FindVariable("tips")					-- 获取提示
	self.attr_1 = self:FindVariable("attr_1")					-- 属性一名称
	self.attr_2 = self:FindVariable("attr_2")					-- 属性二名称
	self.attr1_count = self:FindVariable("attr1_count")			-- 属性一数值
	self.attr2_count = self:FindVariable("attr2_count")			-- 属性二数值
	self.parentsView = nil
	self.icon_1 = self:FindVariable("icon_1")
	self.icon_2 = self:FindVariable("icon_2")
end

function SuitInfoCell:__delete()
	self.suit_name = nil
	self.font_color = nil
	self.is_gain = nil
	self.tips_txt = nil
	self.attr_1 = nil
	self.attr_2 = nil
	self.attr1_count = nil
	self.attr2_count = nil
	self.icon_1 = nil
	self.icon_2 = nil
end

function SuitInfoCell:OnFlush()
	self.data = self:GetData()
	local attr_table = {}
	for k,v in pairs(self.data) do
		if type(v)== "number" and v > 0 and k ~= "suit_color" and k ~= "hunqi_id" then
			table.insert(attr_table, Language.HunYinSuit[k])
			table.insert(attr_table, v)
		end
	end
	self.suit_name:SetValue(ToColorStr(self.data.name, LIAN_QI_NAME_COLOR[self.data.suit_color]))
	self.attr_1:SetValue(attr_table[1])
	self.attr1_count:SetValue(attr_table[2])
	self.attr_2:SetValue(attr_table[3])
	self.attr2_count:SetValue(attr_table[4])
	if self.data.suit_color <= self.current_suit_level then
		self.font_color:SetValue(Language.HunYinSuit["color_"..self.data.suit_color])
		self.tips_txt:SetValue(ToColorStr(Language.HunYinSuit.isgain, LIAN_QI_NAME_COLOR[self.data.suit_color]))
	else
		self.font_color:SetValue(Language.HunYinSuit.color_txt)
		self.tips_txt:SetValue(ToColorStr(Language.HunYinSuit.notgain, TEXT_COLOR.BLACK_1))
	end
	
	self.icon_1:SetAsset(ResPath.GetBaseAttrIcon(attr_table[1]))
	self.icon_2:SetAsset(ResPath.GetBaseAttrIcon(attr_table[3]))
end

function SuitInfoCell:SetCurrrentSuitLevel(level)
	self.current_suit_level = level
end