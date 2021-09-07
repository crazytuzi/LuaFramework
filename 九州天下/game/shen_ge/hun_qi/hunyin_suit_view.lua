HunYinSuitView = HunYinSuitView or BaseClass(BaseView)

HunYinSuitView.SuitMaxLevel	= 4 									--套装最大等级
function HunYinSuitView:__init()
	self.ui_config = {"uis/views/hunqiview", "HunYinSuitView"}
	self:SetMaskBg(true)
end

function HunYinSuitView:__delete()
	-- body
end
-- 创建完调用
function HunYinSuitView:LoadCallBack()
	self.suit_count = 0
	self.suit_info_list = {}
    self.suit_info_list_obj = self:FindObj("SuitList")
    local page_simple_delegate = self.suit_info_list_obj.page_simple_delegate
    page_simple_delegate.NumberOfCellsDel = BindTool.Bind(self.NumberOfCellsDel, self)
    page_simple_delegate.CellRefreshDel = BindTool.Bind(self.CellRefreshDel, self)
    self.suit_info_list_obj.list_view:JumpToIndex(0)
	self:ListenEvent("CloseWindow", BindTool.Bind(self.CloseWindow, self))
	self.hunyin_info = HunQiData.Instance:GetHunQiInfo()

	self.color_list = {}
	for i=0,7 do
		table.insert(self.color_list, self:FindVariable("color_"..i))
	end
end

-- 销毁前调用
function HunYinSuitView:ReleaseCallBack()
	self.suit_count = nil
	self.suit_info_list_obj = nil

	for k,v in pairs(self.color_list) do
		v = nil
	end
	self.color_list = {}
	
	for k,v in pairs(self.suit_info_list) do
		v:DeleteMe()
	end
	self.suit_info_list = {}
end

-- 打开后调用
function HunYinSuitView:OpenCallBack()
	self.suit_level = HunYinSuitView.SuitMaxLevel
	self.current_hunqi_index, self.current_hunyin_list_info  = self.open_callback()
	local hunyin_color = 0
	local hunyin_id = 0
	for k,v in pairs(self.current_hunyin_list_info) do
		hunyin_id = v.hunyin_id
		if 0 ~= hunyin_id then
			hunyin_color = self.hunyin_info[hunyin_id][1].hunyin_color
			self.color_list[k]:SetValue(Language.HunYinSuit["color_"..hunyin_color])
		else
			hunyin_color = 0
			self.color_list[k]:SetValue(Language.HunYinSuit.color_0)
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
	self.suit_info_list_obj.list_view:Reload()
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
	self.suit_name:SetValue(self.data.name)
	self.attr_1:SetValue(attr_table[1])
	self.attr1_count:SetValue(attr_table[2])
	self.attr_2:SetValue(attr_table[3])
	self.attr2_count:SetValue(attr_table[4])

	if self.data.suit_color <= self.current_suit_level then
		self.font_color:SetValue(Language.HunYinSuit["color_"..self.data.suit_color])
		self.tips_txt:SetValue(Language.HunYinSuit.isgain)
	else
		self.font_color:SetValue(Language.HunYinSuit.color_txt)
		self.tips_txt:SetValue(Language.HunYinSuit.notgain)
	end
end

function SuitInfoCell:SetCurrrentSuitLevel(level)
	self.current_suit_level = level
end