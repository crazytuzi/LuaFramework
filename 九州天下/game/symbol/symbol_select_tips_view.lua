-- 一键选择提示

SymbolSelectTipsView = SymbolSelectTipsView or BaseClass(BaseView)

function SymbolSelectTipsView:__init()
	self.ui_config = {"uis/views/symbol_prefab", "SymbolSelectTipsView"}
	self.play_audio = true

	self.select_cell_list = {}			--格子的数据
	self.select_cell_toggle_list = {}	--格子的toggle
	self.callback = nil

end

function SymbolSelectTipsView:__delete()
	self.callback = nil
end

function SymbolSelectTipsView:ReleaseCallBack()
	for i,v in ipairs(self.select_cell_list) do
		v:DeleteMe()
	end
	self.select_cell_list = {}

	self.list_view = nil
	self.select_cell_toggle_list = {}
end

function SymbolSelectTipsView:LoadCallBack()
	self:InitSelectListView()
	self:ListenEvent("BGCloseClick",BindTool.Bind(self.Close,self))
	self:ListenEvent("SaveClick",BindTool.Bind(self.SaveClick,self))
end

function SymbolSelectTipsView:OpenCallBack()
	self:Flush()
end

function SymbolSelectTipsView:OnFlush()
end

function SymbolSelectTipsView:InitSelectListView()
	self.list_view = self:FindObj("ListView")
	self.select_list_data = {"一","二","三","四","五","六"}				--一键选择提示界面list数据
	local delegate = self.list_view.list_simple_delegate
	delegate.NumberOfCellsDel = function ()
		return #self.select_list_data
	end
	delegate.CellRefreshDel = function (cell_obj,index)
		index = index + 1
		local cell = self.select_cell_list[cell_obj]
		if nil == cell then
			cell = SymbolSelectCell.New(cell_obj.gameObject)
			self.select_cell_list[cell_obj] = cell
		end
		cell:SetToggleGroup(self.list_view.toggle_group)
		cell:SetData(self.select_list_data[index])
		self.select_cell_toggle_list[index] = cell:GetToggle()
	end

end

function SymbolSelectTipsView:SetCallBack(callback)
	self.callback = callback
end

--保存事件
function SymbolSelectTipsView:SaveClick()
	self.callback(self.select_cell_toggle_list)
	self:Close()
end

----------------一键选择提示格子---------------
SymbolSelectCell = SymbolSelectCell or BaseClass(BaseCell)

function SymbolSelectCell:__init()
	self.toggle = self:FindObj("Toggle").toggle
	self.name_text = self:FindVariable("Name_Text")
end

function SymbolSelectCell:__delete()
	self.toggle = nil
end

function SymbolSelectCell:OnFlush()
	self.name_text:SetValue(self.data)
end

function SymbolSelectCell:GetToggle()
	return self.toggle
end

function SymbolSelectCell:SetToggleGroup(toggle_group)
	if self.root_node.toggle and self:GetActive() then
		self.root_node.toggle.group = toggle_group
	end
end
