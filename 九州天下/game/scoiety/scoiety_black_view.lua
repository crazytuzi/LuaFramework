ScoietyBlackView = ScoietyBlackView or BaseClass(BaseView)
function ScoietyBlackView:__init()
    self.ui_config = {"uis/views/scoietyview", "BlackList"}
    self:SetMaskBg(true)
	self.cell_list = {}
end

function ScoietyBlackView:__delete()

end

function ScoietyBlackView:ReleaseCallBack()
	for _,v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.cell_list = {}

	-- 清理变量和对象
	self.scroller = nil
end

function ScoietyBlackView:LoadCallBack()
	self.select_index = nil			-- 记录已选择格子位置

	self:ListenEvent("Close",BindTool.Bind(self.CloseWindow, self))

	-- 生成滚动条
	self.scroller_data = {}
	self.scroller = self:FindObj("ListView")
	local scroller_delegate = self.scroller.list_simple_delegate
	--生成数量
	scroller_delegate.NumberOfCellsDel = function()
		return #self.scroller_data or 0
	end
	--刷新函数
	scroller_delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1

		local black_cell = self.cell_list[cell]
		if black_cell == nil then
			black_cell = ScrollerBlackCell.New(cell.gameObject)
			-- black_cell.root_node.toggle.group = self.scroller.toggle_group
			black_cell.black_view = self
			self.cell_list[cell] = black_cell
		end

		black_cell:SetIndex(data_index)
		black_cell:SetData(self.scroller_data[data_index])
	end
end

function ScoietyBlackView:OpenCallBack()
	self:Flush()
end

function ScoietyBlackView:CloseWindow()
	self:Close()
end

function ScoietyBlackView:SetSelectIndex(index)
	if index then
		self.select_index = index
	end
end

function ScoietyBlackView:GetSelectIndex()
	return self.select_index or 0
end

function ScoietyBlackView:OnFlush()
	self.scroller_data = ScoietyData.Instance:GetBlackList()
	self.scroller.scroller:ReloadData(0)
end


----------------------------------------------------------------------------
--ScrollerBlackCell 		好友滚动条格子
----------------------------------------------------------------------------

ScrollerBlackCell = ScrollerBlackCell or BaseClass(BaseCell)

function ScrollerBlackCell:__init()
	self.role_name = self:FindVariable("Name")
	self.lev = self:FindVariable("Lev")
	self.prof = self:FindVariable("Prof")

	--头像UI
	self.image_obj = self:FindObj("RoleImage")
	self.raw_image_obj = self:FindObj("RawImage")

	self.image_res = self:FindVariable("ImageRes")
	self.rawimage_res = self:FindVariable("RawImageRes")

	self:ListenEvent("ClickRemove",BindTool.Bind(self.ClickRemove, self))
	-- self.root_node.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleAcitve,self))
end

function ScrollerBlackCell:__delete()
	self.black_view = nil
end

function ScrollerBlackCell:OnFlush()
	if not self.data or not next(self.data) then return end

	self.role_name:SetValue(self.data.gamename)
	local lv, zhuan = PlayerData.GetLevelAndRebirth(self.data.level)
	self.lev:SetValue(string.format(Language.Common.ZhuanShneng, lv, zhuan))
	self.prof:SetValue(PlayerData.GetProfNameByType(self.data.prof))

	local avatar_path_small = self.data.avatar_key_small
	if self.data.avatar_key_small == 0 then
		self.image_obj.gameObject:SetActive(true)
		self.raw_image_obj.gameObject:SetActive(false)
		local bundle, asset = AvatarManager.GetDefAvatar(self.data.prof, false, self.data.sex)
		self.image_res:SetAsset(bundle, asset)
		return
	end

	local callback = function (path)
		self.avatar_path_small = path or AvatarManager.GetFilePath(self.data.user_id, false)
		self.raw_image_obj.raw_image:LoadSprite(self.avatar_path_small, function()
			if self.data.avatar_key_small == 0 then
				self.image_obj.gameObject:SetActive(true)
				self.raw_image_obj.gameObject:SetActive(false)
				return
			end
			self.image_obj.gameObject:SetActive(false)
			self.raw_image_obj.gameObject:SetActive(true)
		end)
	end
	AvatarManager.Instance:GetAvatar(self.data.user_id, false, callback)
end

function ScrollerBlackCell:OnToggleAcitve(isOn)
	if isOn then
		self.black_view:SetSelectIndex(self.index)
		ScoietyCtrl.Instance:ShowOperateList(ScoietyData.DetailType.BlackType, self.data.gamename)
	end
end

function ScrollerBlackCell:ClickRemove()
	ScoietyCtrl.Instance:DeleteBlackReq(self.data.user_id)
end