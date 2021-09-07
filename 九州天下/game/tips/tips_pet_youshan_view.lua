TipsPetYouShanView = TipsPetYouShanView or BaseClass(BaseView)
function TipsPetYouShanView:__init()
	self.ui_config = {"uis/views/tips/pettips", "ShowPetYouShanTips"}
	self.view_layer = UiLayer.Pop
	self.contain_cell_list = {}
	self.play_audio = true
end

function TipsPetYouShanView:__delete()
end

function TipsPetYouShanView:LoadCallBack()
	self:InitListView()
	self:ListenEvent("close_click",BindTool.Bind(self.OnCloseClick, self))
	self.show_no_interact = self:FindVariable("show_no_interact")
end

function TipsPetYouShanView:OpenCallBack()
	if PetData.Instance:GetInteractInfo().count == 0 then
		self.show_no_interact:SetValue(true)
	else
		self.show_no_interact:SetValue(false)
	end
end

function TipsPetYouShanView:InitListView()
	self.list_view = self:FindObj("list_view")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function TipsPetYouShanView:GetNumberOfCells()
	return PetData.Instance:GetInteractInfo().count
end

function TipsPetYouShanView:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = TipsYouShanItem.New(cell.gameObject)
		self.contain_cell_list[cell] = contain_cell
	end
	cell_index = cell_index + 1
	local list = PetData.Instance:GetInteractInfo().log_list[cell_index]
	contain_cell:OnFlush(list)
end

function TipsPetYouShanView:SetYouShanTextList(text_list)
	self.text_list = text_list
end

function TipsPetYouShanView:OnCloseClick()
	self:Close()
end

-----------------------------------------------------------------
TipsYouShanItem = TipsYouShanItem  or BaseClass(BaseCell)
function TipsYouShanItem:__init()
	self.name_1 = self:FindVariable("name_1")
	self.name_2 = self:FindVariable("name_2")
	self.timer_text = self:FindVariable("interacter_timer")
	self.add_youshan_value = self:FindVariable("add_youshan_value")
end

function TipsYouShanItem:OnFlush(the_list)
	local pet_data = PetData.Instance
	self.name_1:SetValue(the_list.name)
	local pet_name = pet_data:GetPetQualityNameById(the_list.pet_id, the_list.pet_name)
	self.name_2:SetValue(pet_name)
	self.add_youshan_value:SetValue(pet_data:GetOtherCfg()[1].per_interact_add_score)
	local time_list = os.date("*t",the_list.timestamp)
	time_desc = time_list.year .."年".. time_list.month  .. "月" .. time_list.day .. "日" .. time_list.hour .. "时" .. time_list.min .. "分" .. time_list.sec.."秒"
	self.timer_text:SetValue(time_desc)
end


