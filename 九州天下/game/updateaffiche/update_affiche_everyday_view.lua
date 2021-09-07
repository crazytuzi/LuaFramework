-- 日常公告面板
UpdateAfficheEverydayView = UpdateAfficheEverydayView or BaseClass(BaseView)

function UpdateAfficheEverydayView:__init()
	self.ui_config = {"uis/views/updateaffiche", "AfficheView"}

	self.is_use_mask = true
	self.is_maskbg_button_click = true
end

function UpdateAfficheEverydayView:__delete()

end

function UpdateAfficheEverydayView:ReleaseCallBack()
	if self.affiche_cell then
		for k,v in pairs(self.affiche_cell) do
			v:DeleteMe()
		end
		self.affiche_cell = nil
	end
	self.list_view = nil
	self.show_left_button = nil
	self.show_right_button = nil
end

function UpdateAfficheEverydayView:OpenCallBack()
	self.list_view.page_view:JumpToIndex(0)
	self:Flush()
end

function UpdateAfficheEverydayView:CloseCallBack()
	MainUICtrl.Instance.view:Flush("show_affiche", {false})
end

function UpdateAfficheEverydayView:LoadCallBack()
	self.cur_select = 0
	self.affiche_cell = {}

	self.list_view = self:FindObj("List")
	self.show_left_button = self:FindVariable("ShowLeftButton")
	self.show_right_button = self:FindVariable("ShowRightButton")
	self:ListenEvent("LeftButton", BindTool.Bind(self.LeftButton, self))
	self:ListenEvent("RightButton", BindTool.Bind(self.RightButton, self))
	self:ListenEvent("Close", BindTool.Bind(self.CloseView, self))

	local list_delegate = self.list_view.page_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCellsDel, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.AfficheRefreshCell, self)
	self.list_view.page_view:Reload()
end

function UpdateAfficheEverydayView:CloseView()
	self:Close()
end

function UpdateAfficheEverydayView:LeftButton()
	self.cur_select = self.cur_select - 1
	self.list_view.page_view:JumpToIndex(self.cur_select)
	self:Flush()
end

function UpdateAfficheEverydayView:RightButton()
	self.cur_select = self.cur_select + 1
	self.list_view.page_view:JumpToIndex(self.cur_select)
	self:Flush()
end

function UpdateAfficheEverydayView:OnFlush()
	self.show_left_button:SetValue(self.cur_select > 0)
	self.show_right_button:SetValue(self.cur_select < #UpdateAfficheData.Instance:GetImgData())
end

function UpdateAfficheEverydayView:GetNumberOfCellsDel()
	return #UpdateAfficheData.Instance:GetImgData() or 0
end

function UpdateAfficheEverydayView:AfficheRefreshCell(data_index, cell)
	data_index = data_index + 1
	local affiche_cell = self.affiche_cell[cell]
	if affiche_cell == nil then
		affiche_cell = RollViewListRender.New(cell.gameObject)
		self.affiche_cell[cell] = affiche_cell
	end
	local img_data = UpdateAfficheData.Instance:GetImgData()
	affiche_cell:SetData(img_data[data_index])
end



----------------------------------------------------------------------------
--RollViewListRender 	
----------------------------------------------------------------------------

RollViewListRender = RollViewListRender or BaseClass(BaseCell)

function RollViewListRender:__init()
	-- 获取变量
	self.updata_bg = self:FindObj("updata_bg")
	self.affiche_text = self:FindVariable("affiche_text")
end

function RollViewListRender:__delete()
	self.updata_bg = nil
	self.affiche_text = nil
end

function RollViewListRender:OnFlush()
	if not self.data then
		return
	end

	self.affiche_text:SetValue(self.data.text)	
	self.avatar_path_big = self.data.path
	self.updata_bg:SetActive("" ~= self.avatar_path_big)

	if self.avatar_path_big and "" ~= self.avatar_path_big then
		self.updata_bg.raw_image:LoadSprite(self.avatar_path_big, function()
		
		end)
	end
end