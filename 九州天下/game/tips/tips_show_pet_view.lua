TipsShowPetView = TipsShowPetView or BaseClass(BaseView)
function TipsShowPetView:__init()
	self.ui_config = {"uis/views/tips/pettips", "ShowPetInfoTips"}
	self.view_layer = UiLayer.Pop
	self.contain_cell_list = {}
	self.contain_cell_list_2 = {}
	self.play_audio = true
end

function TipsShowPetView:__delete()
end

function TipsShowPetView:LoadCallBack()
	self:InitListView_1()
	self:InitListView_2()
	self:ListenEvent("close_click",BindTool.Bind(self.OnCloseClick, self))
	self:ListenEvent("mine_left_click",BindTool.Bind(self.MineLeftClick, self))
	self:ListenEvent("lover_left_click",BindTool.Bind(self.LoverLeftClick, self))
	self:ListenEvent("mine_right_click",BindTool.Bind(self.MineRightClick, self))
	self:ListenEvent("lover_right_click",BindTool.Bind(self.LoverRightClick, self))
end

function TipsShowPetView:InitListView_1()
	self.list_view_1 = self:FindObj("list_view_1")
	self.list_view_1.scroller.scrollerScrollingChanged = function ()
		-- self:SetBtnActive()
	end
	local list_delegate = self.list_view_1.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells_1, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell_1, self)
end

function TipsShowPetView:GetNumberOfCells_1()
	return PetData.Instance:GetAllInfoList().pet_count_mine
end

function TipsShowPetView:RefreshCell_1(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = TipsPetInfoItem.New(cell.gameObject)
		self.contain_cell_list[cell] = contain_cell
	end
	cell_index = cell_index + 1
	contain_cell:SetPetInfo(PetData.Instance:GetAllInfoList().pet_list_mine[cell_index])
end

function TipsShowPetView:InitListView_2()
	self.list_view_2 = self:FindObj("list_view_2")
	self.list_view_2.scroller.scrollerScrollingChanged = function ()
		-- self:SetBtnActive()
	end
	local list_delegate = self.list_view_2.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells_2, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell_2, self)
end

function TipsShowPetView:GetNumberOfCells_2()
	return PetData.Instance:GetAllInfoList().pet_count_lover
end

function TipsShowPetView:RefreshCell_2(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = TipsPetInfoItem.New(cell.gameObject)
		self.contain_cell_list_2[cell] = contain_cell
	end
	cell_index = cell_index + 1
	contain_cell:SetPetInfo(PetData.Instance:GetAllInfoList().pet_list_lover[cell_index])
end

function TipsShowPetView:BagJumpPage(page, list_view)
	local jump_index = page
	local scrollerOffset = 0
	local cellOffset = 0
	local useSpacing = false
	local scrollerTweenType = self.scroller_list_view.scroller.snapTweenType
	local scrollerTweenTime = 0.1
	local scroll_complete = nil
	list_view.scroller:JumpToDataIndex(
		jump_index, scrollerOffset, cellOffset, useSpacing, scrollerTweenType, scrollerTweenTime, scroll_complete)
end

function TipsShowPetView:OnCloseClick()
	self:Close()
end

function TipsShowPetView:Reload()
	self.list_view_1.scroller:ReloadData(0)
end

function TipsShowPetView:MineLeftClick()

end

function TipsShowPetView:LoverLeftClick()

end

function TipsShowPetView:MineRightClick()

end

function TipsShowPetView:LoverRightClick()

end
-----------------------------------------------------------------
TipsPetInfoItem = TipsPetInfoItem  or BaseClass(BaseCell)
function TipsPetInfoItem:__init()
	self.pet_name = self:FindVariable("pet_name")
	self.show_give_up_click = self:FindVariable("show_give_up_click")
	self.show_rename_btn = self:FindVariable("show_rename_btn")
	self:ListenEvent("give_up_click",BindTool.Bind(self.OnGiveUpClick, self))
	self:ListenEvent("rename_click",BindTool.Bind(self.OnRenameClick, self))
	self.pet_info = {}
	self.pet_model = self:FindObj("model")
	self.model_view = RoleModel.New()
	self.model_view:SetDisplay(self.pet_model.ui3d_display)
end

function TipsPetInfoItem:__delete()
	if nil ~= self.model_view then
		self.model_view:DeleteMe()
		self.model_view = nil
	end
end

function TipsPetInfoItem:SetPetInfo(pet_info)
	if pet_info == nil then
		self.root_node:SetActive(false)
		return
	end
	self.pet_info = pet_info
	self:OnFlush()
end

function TipsPetInfoItem:OnFlush()
	self.pet_name:SetValue(self.pet_info.pet_name)
	self.model_view:SetMainAsset(ResPath.GetMountModel(GODDESS_MODEL_ID_2))
	if self.pet_info.info_type == 0 then
		self.show_give_up_click:SetValue(false)
		self.show_rename_btn:SetValue(false)
	end
end

function TipsPetInfoItem:OnGiveUpClick()
	local func = function()
		PetCtrl.Instance:SendLittlePetREQ(LITTLE_PET_REQ_TYPE.LITTLE_PET_REQ_RELIVE, self.pet_info.index, self.pet_info.info_type, 0)
	end
	TipsCtrl.Instance:ShowCommonTip(func, nil, Language.Common.PetReliveTip, nil, nil, false, false)
end

function TipsPetInfoItem:OnRenameClick()
	local callback = function(name)
		PetCtrl.Instance:SendLittlePetRename(self.pet_info.index, name)
	end
	TipsCtrl.Instance:ShowRename(callback, nil, nil, "是否花费10", "修改宠物名字")
end
