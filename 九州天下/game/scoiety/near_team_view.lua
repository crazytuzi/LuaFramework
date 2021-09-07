NearTeamView = NearTeamView or BaseClass(BaseView)

function NearTeamView:__init()
	self.ui_config = {"uis/views/scoietyview", "NearTeamList"}
	self:SetMaskBg(true)
	self.cell_list = {}
	self.self_camp_team = {}
end

function NearTeamView:__delete()

end

function NearTeamView:ReleaseCallBack()
	self.cell_list = {}
	self.have_team = nil
	self.scroller = nil
	self.self_camp_team = {}
end

function NearTeamView:LoadCallBack()
	self.have_team = self:FindVariable("HaveTeam")

	self:ListenEvent("Close",BindTool.Bind(self.CloseWindow, self))
	self:ListenEvent("FastTeam",BindTool.Bind(self.FastTeam, self))
	self:ListenEvent("CreateTeam",BindTool.Bind(self.CreateTeam, self))

	-- 生成滚动条
	self.scroller_data = {}
	self.scroller = self:FindObj("TeamList")
	local scroller_delegate = self.scroller.list_simple_delegate

	--生成数量
	scroller_delegate.NumberOfCellsDel = function()
		return #self.scroller_data or 0
	end
	--刷新函数 table.insert(表,对象)
	scroller_delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1

		local team_cell = self.cell_list[cell]
		if team_cell == nil then
			team_cell = ScrollerTeamCell.New(cell.gameObject)
			team_cell.mail_view = self
			self.cell_list[cell] = team_cell
		end

		team_cell:SetIndex(data_index)
		team_cell:SetData(self.scroller_data[data_index])
	end
	
end

function NearTeamView:OpenCallBack()
	self.scroller_data = ScoietyData.Instance:GetTeamListAck()
	self:Flush()
end

function NearTeamView:OnFlush()
	local team_state = ScoietyData.Instance:GetTeamState()
	self.have_team:SetValue(team_state)

	self.scroller_data = ScoietyData.Instance:GetTeamListAck()
	if self.scroller.scroller.isActiveAndEnabled then
		self.scroller.scroller:ReloadData(0)
	end
end

function NearTeamView:CloseWindow()
	self:Close()
end

function NearTeamView:CloseCallBack()
	ScoietyData.Instance:DelTeamListAck()
	self.scroller_data = {}
end

function NearTeamView:CreateTeam()
	local team_state = ScoietyData.Instance:GetTeamState()
	if team_state then
		SysMsgCtrl.Instance:ErrorRemind(Language.Society.AlreadyInTeam)
		return
	end
	local param_t = {}
	param_t.must_check = 0
	param_t.assign_mode = 2
	ScoietyCtrl.Instance:CreateTeamReq(param_t, true)
	self:Close()
end

function NearTeamView:FastTeam()
	local team_state = ScoietyData.Instance:GetTeamState()
	if team_state then
		SysMsgCtrl.Instance:ErrorRemind(Language.Society.AlreadyInTeam)
		return
	end
	ScoietyCtrl.Instance:AutoHaveTeamReq()
	self:Close()
end

----------------------------------------------------------------------------
--ScrollerTeamCell 		附近队伍滚动条格子
----------------------------------------------------------------------------

ScrollerTeamCell = ScrollerTeamCell or BaseClass(BaseCell)

function ScrollerTeamCell:__init()
	-- 获取变量
	-- self.icon = self:FindVariable("Icon")
	self.name = self:FindVariable("Name")
	self.num = self:FindVariable("Num")

	--头像UI
	self.image_obj = self:FindObj("RoleImage")
	self.raw_image_obj = self:FindObj("RawImage")
	self.btn_add = self:FindObj("BtnAdd")

	self.image_res = self:FindVariable("ImageRes")
	self.rawimage_res = self:FindVariable("RawImageRes")

	-- 监听事件
	self:ListenEvent("ClickEnter",BindTool.Bind(self.ClickEnter, self))
end

function ScrollerTeamCell:__delete()
	self.name = nil
	self.num = nil
	self.image_obj = nil
	self.raw_image_obj = nil
	self.btn_add = nil
	self.image_res = nil
	self.rawimage_res = nil
end

function ScrollerTeamCell:OnFlush()
	if not self.data or not next(self.data) then return end
	self.user_id = self.data.member_uid_list[1]

	AvatarManager.Instance:SetAvatarKey(self.user_id, self.data.avatar_key_big, self.data.avatar_key_small)
	if self.data.avatar_key_small == 0 then
		self.image_obj.gameObject:SetActive(true)
		self.raw_image_obj.gameObject:SetActive(false)
		local bundle, asset = AvatarManager.GetDefAvatar(self.data.leader_prof, false, self.data.leader_sex)
		-- self.image_obj.image:LoadSprite(bundle, asset)
		self.image_res:SetAsset(bundle, asset)
	else
		local function callback(path)
			if IsNil(self.image_obj.gameObject) or IsNil(self.raw_image_obj.gameObject) then
				return
			end
			if path == nil then
				path = AvatarManager.GetFilePath(self.user_id, false)
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
		AvatarManager.Instance:GetAvatar(self.user_id, false, callback)
	end

	local team_state = ScoietyData.Instance:GetTeamState()
	self.btn_add.button.interactable = not team_state
	self.name:SetValue(self.data.leader_name)
	self.num:SetValue(string.format("%d/%d", self.data.cur_member_num, 3))
end

function ScrollerTeamCell:ClickEnter()
	local team_index = self.data.team_index
	ScoietyCtrl.Instance:JoinTeamReq(team_index)
	-- SysMsgCtrl.Instance:ErrorRemind("请求已发送")
end