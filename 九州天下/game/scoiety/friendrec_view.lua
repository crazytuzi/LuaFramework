FriendRandomView = FriendRandomView or BaseClass(BaseView)

function FriendRandomView:__init()
	self.ui_config = {"uis/views/scoietyview", "FriendRecList"}
	self:SetMaskBg(true)
	self.cell_list = {}
	self.select_list = {}
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
	self.friend_rec_auto_add = nil
	self.scroller = nil
	self.select_list = {}
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
		friend_cell:SetSelectCall(BindTool.Bind(self.SelectCall, self, data_index))
		friend_cell:SetData(self.scroller_data[data_index])
	end

	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.FriendRec, BindTool.Bind(self.GetUiCallBack, self))
end

function FriendRandomView:CloseWindow()
	self:Close()
end

function FriendRandomView:SelectCall(index, value)
	if self.select_list ~= nil and index ~= nil then
		self.select_list[index] = value or false
	end
end

function FriendRandomView:AutoAdd()
	local random_list = ScoietyData.Instance:GetRandomRoleList()
	for k,v in ipairs(random_list) do
		--if v.is_select then
		if self.select_list ~= nil and self.select_list[k] then
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
	self.image_obj = self:FindObj("RoleImage")
	self.raw_image_obj = self:FindObj("RawImage")

	self.image_res = self:FindVariable("ImageRes")
	--self.rawimage_res = self:FindVariable("RawImageRes")

	-- 监听事件
	self.check_select.toggle:AddValueChangedListener(BindTool.Bind(self.ClickSelect, self))
end

function FriendRecCell:__delete()
	self.icon = nil
	self.name = nil
	self.prof = nil
	self.lev = nil
	self.check_select = nil 
	self.image_obj =nil
	self.raw_image_obj = nil
	self.image_res = nil
	self.rawimage_res = nil
	self.select_call = nil
end

function FriendRecCell:SetSelectCall(call)
	self.select_call = call
end

function FriendRecCell:OnFlush()
	if not self.data or not next(self.data) then return end
	self.check_select.toggle.isOn = self.data.is_select or false

	if self.select_call ~= nil then
		self.select_call(self.data.is_select)
	end

	AvatarManager.Instance:SetAvatarKey(self.data.user_id, self.data.avatar_key_big, self.data.avatar_key_small)
	if self.data.avatar_key_small == 0 then
		self.image_obj.gameObject:SetActive(true)
		self.raw_image_obj.gameObject:SetActive(false)
		local bundle, asset = AvatarManager.GetDefAvatar(self.data.prof, false, self.data.sex)
		-- self.image_obj.image:LoadSprite(bundle, asset)
		self.image_res:SetAsset(bundle, asset)
	else
		local function callback(path)
			if nil == self.image_obj or IsNil(self.image_obj.gameObject) or IsNil(self.raw_image_obj.gameObject) then
				return
			end
			if path == nil then
				path = AvatarManager.GetFilePath(self.data.user_id, false)
			end
			self.raw_image_obj.raw_image:LoadSprite(path, function ()
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

	local lv, zhuan = PlayerData.GetLevelAndRebirth(self.data.level)
	local level_des = string.format(Language.Common.LevelFormat, lv, zhuan)
	self.lev:SetValue(level_des)
	self.name:SetValue(Language.RankTogle.StrCamp[self.data.camp] .. self.data.gamename)
	--self.prof:SetValue(PlayerData.GetProfNameByType(self.data.prof))
	self.prof:SetValue(Language.Common.ProfName[self.data.prof])
end

function FriendRecCell:ClickSelect(ison)
	if ison then
		self.data.is_select = true
	else
		self.data.is_select = false
	end

	if self.select_call ~= nil then
		self.select_call(ison)
	end
end