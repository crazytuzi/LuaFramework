CongratulationView = CongratulationView or BaseClass(BaseView)
function CongratulationView:__init()
	self.ui_config = {"uis/views/congratulate_prefab","Congratulation"}
	self.full_screen = false
	self.play_audio = true
	self.is_async_load = false
	self.is_check_reduce_mem = true
end

function CongratulationView:__delete()
end

function CongratulationView:LoadCallBack()
	self.congratulation_item_list = {}
	self.list_view = self:FindObj("ListView")
	local scroller_delegate = self.list_view.list_simple_delegate
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function CongratulationView:GetNumberOfCells()
	return #CongratulationData.Instance:GetCongratulationlist()
end

function CongratulationView:RefreshCell(cell, data_index)
	data_index = data_index + 1	
	local the_cell = self.congratulation_item_list[cell]
	if the_cell == nil then
		the_cell = CongratulateItem.New(cell.gameObject)
		the_cell.parent = self
		self.congratulation_item_list[cell] = the_cell
	end
	the_cell:SetIndex(data_index)
	the_cell:Flush()
end

function CongratulationView:OpenCallBack()
	self:ListenEvent("CloseView", BindTool.Bind(self.CloseView,self))
	self.list_view.scroller:ReloadData(1)
end

function CongratulationView:OnFlush()
	self.list_view.scroller:ReloadData(1)
end

function CongratulationView:CloseView()
	self:Close()
end

function CongratulationView:CloseCallBack()
	CongratulationCtrl.Instance:SetClosenTime()
	CongratulationData.Instance:ClearTempList()
end

function CongratulationView:ReleaseCallBack()
	self.list_view = nil	
	if next(self.congratulation_item_list) ~= nil then
		local x = #self.congratulation_item_list
		for i=1,x do
			self.congratulation_item_list[i]:DeleteMe()
		end
	end
	self.congratulation_item_list = {}
end

--------------祝贺列表
CongratulateItem = CongratulateItem or BaseClass(BaseCell)
function CongratulateItem:__init()
	self.context = self:FindVariable("Text")
	self.is_show = self:FindVariable("IsShow")
	self.index = 0
end

function  CongratulateItem:__delete()
	self.context = nil
	self.is_show = nil
end

function CongratulateItem:OnFlush()
	local info = CongratulationData.Instance:GetCongratulationlist()[self.index]
	local friend_name = ScoietyData.Instance:GetFriendNameById(info.uid)
	local value = ""
	local experience = CongratulationData.Instance:GetExperience()
	if info._type == CONGRATULATION_TYPE.EGG then
		value = string.format(Language.Congratulation.Info1, friend_name, experience)
	elseif info._type == CONGRATULATION_TYPE.FLOWER then
		value = string.format(Language.Congratulation.Info2, friend_name, experience)
	end
	self.context:SetValue(value)
	self.is_show:SetValue(0 == self.index % 2)
end