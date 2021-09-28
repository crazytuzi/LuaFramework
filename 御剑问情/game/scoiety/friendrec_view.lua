FriendRandomView = FriendRandomView or BaseClass(BaseView)

function FriendRandomView:__init()
	self.ui_config = {"uis/views/scoietyview_prefab", "FriendRecList"}
	self.cell_list = {}
end

function FriendRandomView:__delete()

end

function FriendRandomView:ReleaseCallBack()
	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.FriendRec)
	end

	for _,v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.cell_list = {}

	--清除变量
	self.friend_rec_auto_add = nil
	self.scroller = nil
end

function FriendRandomView:LoadCallBack()
	self:ListenEvent("Close",BindTool.Bind(self.CloseWindow, self))
	self:ListenEvent("AutoAdd",BindTool.Bind(self.AutoAdd, self))
	self:ListenEvent("Refresh",BindTool.Bind(self.Refresh, self))

	--引导用按钮
	self.friend_rec_auto_add = self:FindObj("AutoAdd")

	-- 生成滚动条
	self.scroller_data = {}
	self.scroller = self:FindObj("FriendList")
	local scroller_delegate = self.scroller.list_simple_delegate
	--生成数量
	scroller_delegate.NumberOfCellsDel = function()
		return #self.scroller_data or 0
	end
	--刷新函数
	scroller_delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1

		local friend_cell = self.cell_list[cell]
		if friend_cell == nil then
			friend_cell = FriendRecCell.New(cell.gameObject)
			self.cell_list[cell] = friend_cell
		end

		friend_cell:SetIndex(data_index)
		friend_cell:SetData(self.scroller_data[data_index])
	end

	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.FriendRec, BindTool.Bind(self.GetUiCallBack, self))
end

function FriendRandomView:CloseWindow()
	self:Close()
end

function FriendRandomView:AutoAdd()
	local random_list = ScoietyData.Instance:GetRandomRoleList()
	for k,v in ipairs(random_list) do
		if v.is_select then
			ScoietyCtrl.Instance:AddFriendReq(v.user_id, 1)
		end
	end
	self:CloseWindow()
	SysMsgCtrl.Instance:ErrorRemind(Language.Society.AddFriendRec)
end

function FriendRandomView:Refresh()
	ScoietyCtrl.Instance:RandomRoleListReq()
end

function FriendRandomView:OnFlush()
	self.scroller_data = ScoietyData.Instance:GetRandomRoleList()
	self.scroller.scroller:ReloadData(0)
end

function FriendRandomView:GetUiCallBack(ui_name, ui_param)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if self[ui_name] then
		if self[ui_name].gameObject.activeInHierarchy then
			return self[ui_name]
		end
	end
end

----------------------------------------------------------------------------
--FriendRecCell 		好友推荐滚动条格子
----------------------------------------------------------------------------

FriendRecCell = FriendRecCell or BaseClass(BaseCell)

function FriendRecCell:__init()
	-- 获取变量
	self.icon = self:FindVariable("Icon")
	self.name = self:FindVariable("Name")
	self.prof = self:FindVariable("Prof")
	self.lev = self:FindVariable("Lev")

	self.check_select = self:FindObj("CheckSelect")
	--头像UI
	self.image_res = self:FindVariable("ImageRes")
	self.show_image = self:FindVariable("ShowImage")
	self.raw_image_obj = self:FindObj("RawImage")

	-- 监听事件
	self.check_select.toggle:AddValueChangedListener(BindTool.Bind(self.ClickSelect, self))
end

function FriendRecCell:__delete()
	
end

function FriendRecCell:OnFlush()
	if not self.data or not next(self.data) then return end
	self.data.is_select = true

	local role_id = self.data.user_id

	local function download_callback(path)
		if nil == self.raw_image_obj or IsNil(self.raw_image_obj.gameObject) then
			return
		end
		if self.data.user_id ~= role_id then
			return
		end
		local avatar_path = path or AvatarManager.GetFilePath(role_id, true)
		self.raw_image_obj.raw_image:LoadSprite(avatar_path,
		function()
			if self.data.user_id ~= role_id then
				return
			end
			self.show_image:SetValue(false)
		end)
	end

	CommonDataManager.NewSetAvatar(role_id, self.show_image, self.image_res, self.raw_image_obj, self.data.sex, self.data.prof, false, download_callback)

	local level_des = PlayerData.GetLevelString(self.data.level)
	self.lev:SetValue(level_des)
	self.name:SetValue(self.data.gamename)
	self.prof:SetValue(PlayerData.GetProfNameByType(self.data.prof))
end

function FriendRecCell:ClickSelect(ison)
	if ison then
		self.data.is_select = true
	else
		self.data.is_select = false
	end
end