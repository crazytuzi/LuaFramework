EnterWeddingView = EnterWeddingView or BaseClass(BaseView)

function EnterWeddingView:__init()
	self.ui_config = {"uis/views/marriageview","EnterWeddingView"}
	self.scroller_data = {}
	self.cell_list = {}
end

function EnterWeddingView:__delete()
	
end

function EnterWeddingView:ReleaseCallBack()
	if self.cell_list then
		for k,v in pairs(self.cell_list) do
			v:DeleteMe()
		end
		self.cell_list = {}
	end
end

function EnterWeddingView:LoadCallBack()
	self:InitScroller()
	self:ListenEvent("Close",BindTool.Bind(self.ClickClose, self))
end

function EnterWeddingView:SetScrollerData()
	for i=1,10 do
		local data = {}
		self.scroller_data[i] = data
	end
end

function EnterWeddingView:InitScroller()
	self.scroller = self:FindObj("Scroller")
	self:SetScrollerData()
	local delegate = self.scroller.list_simple_delegate
	-- 生成数量
	delegate.NumberOfCellsDel = function()
		return #self.scroller_data
	end
	-- 格子刷新
	delegate.CellRefreshDel = function(cell, data_index, cell_index)
	data_index = data_index + 1
		if nil == self.cell_list[cell] then
			self.cell_list[cell] = WedingScrollerCell.New(cell.gameObject)
		end
		local data = self.cell_list[cell]
		data.data_index = data_index
		self.cell_list[cell]:SetData(data)
	end
end

function EnterWeddingView:ReleaseCallBack()

end

function EnterWeddingView:ClickClose()
	self:Close()
end

--滚动条格子-------------------------------------
WedingScrollerCell = WedingScrollerCell or BaseClass(BaseCell)
function WedingScrollerCell:__init()
	self.male_name = self:FindVariable("MaleName")
	self.female_name = self:FindVariable("Femalename")
	self.wedding_name = self:FindVariable("WeddingName")
	self:ListenEvent("JoinClick", BindTool.Bind(self.OnCLick, self))
end

function WedingScrollerCell:__delete()

end

function WedingScrollerCell:OnCLick()
	print(self.data.data_index, "点击了参与")
end

function WedingScrollerCell:OnFlush()
	self.wedding_name:SetValue(self.data.data_index)
end
