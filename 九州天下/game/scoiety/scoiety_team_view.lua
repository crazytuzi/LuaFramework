ScoietyTeamView = ScoietyTeamView or BaseClass(BaseRender)
TEAM_HEAD_COUNT = 3
function ScoietyTeamView:__init()
	self.member_list = {}
	self.model = {}
	self.is_show_model = {}
	self.display = {}
	self.is_show_online = {}
end

function ScoietyTeamView:LoadCallBack()

	self.is_leader_opera = self:FindVariable("isLeader")
	self.have_team_state = self:FindVariable("HaveTeamState")
	self.is_max_num = self:FindVariable("IsMaxNum")
	self.is_show_online = {}
	for i=1,TEAM_HEAD_COUNT do
		self["show_role_bg"..i] = self:FindVariable("Show_Role_Bg".. i)
		self["show_btn_yaoqing"..i] = self:FindVariable("Show_Btn_YaoQing".. i)
		self.is_show_online[i] = self:FindVariable("Is_Show_Online".. i)
		self.is_show_model[i] = self:FindVariable("Is_Show_model".. i)
		self.display[i] = self:FindObj("Display"..i)
		self.model[i] = RoleModel.New()
		self.model[i]:SetDisplay(self.display[i].ui3d_display)
	end


	-- 获取UI
	self.auto_receive = self:FindObj("AutoReceive")
	self.auto_team = self:FindObj("AutoTeam")
	self.free_pick = self:FindObj("FreePick")

	-- 监听事件
	self:ListenEvent("ClickCreateTeam",BindTool.Bind(self.ClickCreateTeam, self))
	self:ListenEvent("ClickNearTeam",BindTool.Bind(self.ClickNearTeam, self))
	self:ListenEvent("ClickTeamInvite",BindTool.Bind(self.ClickTeamInvite, self))

	self:ListenEvent("ClickAutoJoin",BindTool.Bind(self.ClickAutoJoin, self))
	self:ListenEvent("ClickFreePick",BindTool.Bind(self.ClickFreePick, self))
	self:ListenEvent("ClickAutoTeam",BindTool.Bind(self.ClickAutoTeam, self))
	self:ListenEvent("ClickLeaveTeam",BindTool.Bind(self.ClickLeaveTeam, self))


	-- self.auto_receive.toggle:AddValueChangedListener(BindTool.Bind(self.AutoReceive, self))
	-- self.auto_team.toggle:AddValueChangedListener(BindTool.Bind(self.AutoTeam, self))
	-- self.free_pick.toggle:AddValueChangedListener(BindTool.Bind(self.FreePick, self))
	self:CreateTeamList()
end

function ScoietyTeamView:__delete()
	for i=1,TEAM_HEAD_COUNT do
		if self.model[i] then
			self.model[i]:DeleteMe()
			self.model[i] = nil
		end
	end
	self.model = {}
	
	for _, v in ipairs(self.member_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.member_list = {}
end

function ScoietyTeamView:ClearTeam()
	for k, v in ipairs(self.member_list) do
		v:SetData(nil)
	end
end

function ScoietyTeamView:CreateTeam()

end

function ScoietyTeamView:CreateTeamList()
	for i = 1, TEAM_HEAD_COUNT do
		self["member" .. i] = RoleModelCell.New(self:FindObj("Member" .. i))
		self["member" .. i]:SetIndex(i)
		self["member" .. i].scoiety_team_view = self
		table.insert(self.member_list, self["member" .. i])
	end
end

--点击自动接受组队邀请
function ScoietyTeamView:ClickAutoTeam()
	if self.auto_receive.toggle.isOn then
		ScoietyData.Instance:SetIsAutoJoinTeam(1)
		ScoietyCtrl.Instance:AutoApplyJoinTeam(1)
	else
		ScoietyData.Instance:SetIsAutoJoinTeam(0)
		ScoietyCtrl.Instance:AutoApplyJoinTeam(0)
	end
end

--点击离开队伍
function ScoietyTeamView:ClickLeaveTeam()
	local team_state = ScoietyData.Instance:GetTeamState()
	if not team_state then
		SysMsgCtrl.Instance:ErrorRemind(Language.Society.NotCurTeam)
		return
	end
	local function ok_func()
		ScoietyCtrl.Instance:ExitTeamReq()
	end
	if ScoietyData.Instance:GetTeamNum() > 1 then
		local des = Language.Society.ExitTeam
		TipsCtrl.Instance:ShowCommonAutoView("leave_team", des, ok_func)
	else
		ok_func()
	end
end


--点击自动接受入队邀请
function ScoietyTeamView:ClickAutoJoin()
	if self.auto_team.toggle.isOn then
		ScoietyCtrl.Instance:ChangeMustCheckReq(0)
	else
		ScoietyCtrl.Instance:ChangeMustCheckReq(1)
	end
end

--点击自由拾取
function ScoietyTeamView:ClickFreePick()
	local main_role = Scene.Instance:GetMainRole()
	local is_leader = ScoietyData.Instance:IsLeaderById(main_role:GetRoleId())
	if not is_leader then
		SysMsgCtrl.Instance:ErrorRemind(Language.Society.IsLeaderChangeDes)
		local team_info = ScoietyData.Instance:GetTeamInfo()
		self.free_pick.toggle.isOn = team_info.assign_mode == 2 and true or false
		return
	end
	if self.free_pick.toggle.isOn then
		ScoietyCtrl.Instance:ChangeAssignModeReq(TEAM_ASSIGN_MODE.TEAM_ASSIGN_MODE_RANDOM)
	else
		ScoietyCtrl.Instance:ChangeAssignModeReq(TEAM_ASSIGN_MODE.TEAM_ASSIGN_MODE_KILL)
	end
end

-- function ScoietyTeamView:AutoReceive(ison)
-- 	if ison then
-- 		ScoietyData.Instance:SetIsAutoJoinTeam(1)
-- 		ScoietyCtrl.Instance:AutoApplyJoinTeam(1)
-- 	else
-- 		ScoietyData.Instance:SetIsAutoJoinTeam(0)
-- 		ScoietyCtrl.Instance:AutoApplyJoinTeam(0)
-- 	end
-- end

-- function ScoietyTeamView:AutoTeam(ison)
-- 	if ison then
-- 		ScoietyCtrl.Instance:ChangeMustCheckReq(0)
-- 	else
-- 		ScoietyCtrl.Instance:ChangeMustCheckReq(1)
-- 	end
-- end

-- function ScoietyTeamView:FreePick(ison)
-- 	if ison then
-- 		ScoietyCtrl.Instance:ChangeAssignModeReq(TEAM_ASSIGN_MODE.TEAM_ASSIGN_MODE_RANDOM)
-- 	else
-- 		ScoietyCtrl.Instance:ChangeAssignModeReq(TEAM_ASSIGN_MODE.TEAM_ASSIGN_MODE_KILL)
-- 	end
-- end

function ScoietyTeamView:ClickCreateTeam()
	local team_state = ScoietyData.Instance:GetTeamState()
	if team_state then return end

	local param_t = {}
	param_t.must_check = 0
	param_t.assign_mode = 2
	ScoietyCtrl.Instance:CreateTeamReq(param_t, true)
end

function ScoietyTeamView:ClickNearTeam()
	ScoietyCtrl.Instance:ShowNearTeamView()
end

function ScoietyTeamView:ClickTeamInvite()
	local main_role_id = Scene.Instance:GetMainRole():GetRoleId()
	local team_state = ScoietyData.Instance:GetTeamState()
	if not team_state then
		SysMsgCtrl.Instance:ErrorRemind(Language.Society.CreateTeam)
		return
	end
	if not ScoietyData.Instance:IsLeaderById(main_role_id) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Society.DontInviety)
		return
	end
	TipsCtrl.Instance:ShowInviteView()
end
function ScoietyTeamView:FlushTeamView()
	self:Flush()
end
function ScoietyTeamView:OnFlush()
	--不是队长无法执行后两项操作
	for i=1,TEAM_HEAD_COUNT do
		self["show_role_bg"..i]:SetValue(true)
		self["show_btn_yaoqing"..i]:SetValue(false)
		if self.is_show_model[i] then
			self.is_show_model[i]:SetValue(false)
		end
		self.is_show_online[i]:SetValue(false)
	end
	
	local main_role = Scene.Instance:GetMainRole()
	local is_leader = ScoietyData.Instance:IsLeaderById(main_role:GetRoleId())
	local is_auto_join_team_state = ScoietyData.Instance:GetIsAutoJoinTeam()
	self.auto_receive.toggle.isOn = is_auto_join_team_state == 1 and true or false
	self.is_leader_opera:SetValue(is_leader)

	--已有队伍置灰按钮
	local team_state = ScoietyData.Instance:GetTeamState()
	self.have_team_state:SetValue(team_state)

	self.is_max_num:SetValue(false)

	local team_info = ScoietyData.Instance:GetTeamInfo()
	self.auto_team.toggle.isOn = team_info.must_check == 0 and true or false
	self.free_pick.toggle.isOn = team_info.assign_mode == 2 and true or false

	local team_user_list = ScoietyData.Instance:GetTeamUserList()
	if not next(team_user_list) then self:ClearTeam() return end
	--开始创建人员
	if team_info.member_count >= TEAM_HEAD_COUNT then
		self.is_max_num:SetValue(true)
	end
	local leader_index = team_info.team_leader_index or 0
	local my_index = 0
	for i = 1, TEAM_HEAD_COUNT do
		local role_id = team_user_list[i]
		local member_info = ScoietyData.Instance:GetMemberInfoByRoleId(role_id)
		if next(member_info) then
			self["member" .. i]:SetData(member_info)
			if member_info.role_id == main_role:GetRoleId() then
				self["member" .. i]:SetRoleStateText(true)
				-- self["member" .. i]:SetRoleStateVisible(true)
				my_index = i
			else
				self["member" .. i]:SetRoleStateText(false)
				-- self["member" .. i]:SetRoleStateVisible(my_index == 1)
			end
		else
			self["member" .. i]:SetData(nil)
		end
	end

	local team_num = ScoietyData.Instance:GetTeamNum() 						  -- 队伍当前人数
	local cur_team_cfg = ScoietyData.Instance:GetTeamInfo().team_member_list  -- 队伍当前人员信息
	if team_num then
		for i=1, #cur_team_cfg do
			local role_id = team_user_list[i]
			local member_info = ScoietyData.Instance:GetMemberInfoByRoleId(role_id)
			local role_id = team_user_list[i]
			-- self.model[i]:SetModelResInfo(cur_team_cfg[i])
			self.model[i]:SetModelResInfo(member_info)
			self.is_show_model[i]:SetValue(team_num >= i)
			self.is_show_online[i]:SetValue(member_info.is_online == 0)
		end
		for i=1,TEAM_HEAD_COUNT do
			self["show_role_bg"..i]:SetValue(team_num < i)
			self["show_btn_yaoqing"..i]:SetValue(team_num < i)
		end
	end
end

function ScoietyTeamView:UpdateAppearByIndex(role_id)
	local team_user_list = ScoietyData.Instance:GetTeamUserList()
	for k, v in ipairs(team_user_list) do
		if role_id == v then
			if self["member" .. k] then
				self["member" .. k]:UpdateAppearance()
			end
			break
		end
	end
end

RoleModelCell = RoleModelCell or BaseClass(BaseCell)

function RoleModelCell:__init()
	self.name = self:FindVariable("Name")
	self.level = self:FindVariable("Lev")
	self.zhanli = self:FindVariable("ZhanLi")
	self.prof = self:FindVariable("Prof")
	self.state_text = self:FindVariable("StateText")
	self.is_leave = self:FindVariable("IsLeave")
	self.is_leader = self:FindVariable("IsLeader")

	self.state = self:FindObj("State")
	-- self.role_display = self:FindObj("RoleDisplay")

	--头像UI
	self.image_obj = self:FindObj("RoleImage")
	self.raw_image_obj = self:FindObj("RawImage")

	self.image_res = self:FindVariable("ImageRes")
	self.rawimage_res = self:FindVariable("RawImageRes")

	self.state.button:AddClickListener(BindTool.Bind(self.ClickState, self))

	self:ListenEvent("ClickItem", BindTool.Bind(self.ClickItem, self))
end

function RoleModelCell:__delete()
	if self.role_model then
		self.role_model:DeleteMe()
		self.role_model = nil
	end
end

function RoleModelCell:OnFlush()
	if not self.data then
		self:SetActive(false)
		return
	end
	self:SetActive(true)
	self:SetRoleIcon()
	self:SetRoleInfo()
	-- local main_role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	-- if main_role_id == self.data.role_id then
	-- 	self:CreateRole()
	-- else
	-- 	self:UpdateAppearance()
	-- end
end

function RoleModelCell:SetRoleIcon()
	local role_id = self.data.role_id
	AvatarManager.Instance:SetAvatarKey(role_id, self.data.avatar_key_big, self.data.avatar_key_small)
	if self.data.avatar_key_small == 0 then
		self.image_obj.gameObject:SetActive(true)
		self.raw_image_obj.gameObject:SetActive(false)
		local bundle, asset = AvatarManager.GetDefAvatar(self.data.prof, false, self.data.sex)
		-- self.image_obj.image:LoadSprite(bundle, asset)
		self.image_res:SetAsset(bundle, asset)
	else
		local function callback(path)
			if IsNil(self.image_obj.gameObject) or IsNil(self.raw_image_obj.gameObject) then
				return
			end
			if path == nil then
				path = AvatarManager.GetFilePath(role_id, false)
			end
			-- self.rawimage_res:SetAsset("C:/Users/Administrator/AppData/LocalLow/YouYan/G16/cache/avatar/10TEAM_HEAD_COUNT8593_small.jpg", )

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
		AvatarManager.Instance:GetAvatar(role_id, false, callback)
	end
end

function RoleModelCell:ClickState()
	-- local main_role = Scene.Instance:GetMainRole()
	-- local yes_button_text = Language.Common.Confirm
	-- local no_button_text = Language.Common.Cancel
	-- if self.data.role_id == main_role:GetRoleId() then
	-- 	local function ok_func()
	-- 		ScoietyCtrl.Instance:ExitTeamReq()
	-- 	end
	-- 	local des = Language.Society.ExitTeam

	-- 	TipsCtrl.Instance:ShowCommonAutoView("leave_team", des, ok_func)
	-- else
	-- 	local function ok_func()
	-- 		ScoietyCtrl.Instance:KickOutOfTeamReq(self.data.role_id)
	-- 	end
	-- 	local des = string.format(Language.Society.KickOutTeam, self.data.name)
	-- 	TipsCtrl.Instance:ShowCommonAutoView("kick_out_of_team", des, ok_func)
	-- end
end

function RoleModelCell:UpdateWingResId(vo)
	local index = vo.wing_info.used_imageid
	local wing_config = ScoietyData.Instance.wing_config
	self.wing_res_id = 0
	if wing_config then
		local image_list = wing_config.image_list[index]
		if image_list then
			self.wing_res_id = image_list.res_id
		end
	end
end

--根据type, index获取服装的配置
function RoleModelCell:GetFashionConfig(fashion_cfg_list, part_type, index)
	for k, v in pairs(fashion_cfg_list) do
		if v.part_type == part_type and index == v.index then
			return v
		end
	end
	return nil
end

function RoleModelCell:UpdateAppearance()
	if not self.data or not next(self.data) then
		return
	end
	local vo = ScoietyData.Instance.role_vo_list[self.data.role_id]
	if not vo or not next(vo) then return end
	local prof = vo.prof

	--清空缓存
	self.role_res_id = 0
	self.weapon_res_id = 0
	self.wing_res_id = 0
	-- 先查找时装的武器和衣服
	if vo.shizhuang_part_list ~= nil then
		local fashion_wuqi = vo.shizhuang_part_list[1].use_index
		local fashion_body = vo.shizhuang_part_list[2].use_index

		local fashion_cfg_list = FashionData.Instance.fashion_cfg_list
		if fashion_wuqi ~= 0 then
			local wuqi_cfg = self:GetFashionConfig(fashion_cfg_list, SHIZHUANG_TYPE.WUQI, fashion_wuqi)
			local res_id = wuqi_cfg["resouce" .. prof]
			self.weapon_res_id = res_id
		end

		if fashion_body ~= 0 then
			local clothing_cfg = self:GetFashionConfig(fashion_cfg_list, SHIZHUANG_TYPE.BODY, fashion_body)
			local res_id = clothing_cfg["resouce" .. prof]
			self.role_res_id = res_id
		end

		self:UpdateWingResId(vo)
	end

	-- 最后查找职业表
	local job_cfgs = ScoietyData.Instance.job_cfgs
	local role_job = job_cfgs[vo.prof]
	if role_job ~= nil then
		if self.role_res_id == 0 then
			self.role_res_id = role_job.model
		end

		if self.weapon_res_id == 0 then
			self.weapon_res_id = role_job.weapon
		end

		if self.weapon2_res_id == 0 then
			self.weapon2_res_id = role_job.weapon2
		end
	else
		if self.role_res_id == 0 then
			self.role_res_id = 1001001
		end

		if self.weapon_res_id == 0 then
			self.weapon_res_id = 900100101
		end
	end
	self:UpdateRoleModel()
end

function RoleModelCell:UpdateRoleModel()
	if not self.role_model then
		self.role_model = RoleModel.New()
		self.role_model:SetDisplay(self.role_display.ui3d_display)
	end
	self.role_model:SetRoleResid(self.role_res_id)
	self.role_model:SetWeaponResid(self.weapon_res_id)
	self.role_model:SetWingResid(self.wing_res_id)
end

function RoleModelCell:CreateRole()
	local main_role = Scene.Instance:GetMainRole()
	if not self.role_model then
		self.role_model = RoleModel.New()
		self.role_model:SetDisplay(self.role_display.ui3d_display)
	end
	self.role_model:SetRoleResid(main_role:GetRoleResId())
	self.role_model:SetWeaponResid(main_role:GetWeaponResId())
	self.role_model:SetWingResid(main_role:GetWingResId())
end

function RoleModelCell:SetRoleInfo()
	local is_leader = ScoietyData.Instance:IsLeaderById(self.data.role_id)

	local lv, zhuan = PlayerData.GetLevelAndRebirth(self.data.level)
	local level_des = string.format(Language.Common.LevelFormat, lv, zhuan)
	self.level:SetValue(level_des)
	self.is_leader:SetValue(is_leader)
	self.name:SetValue(self.data.name)
	self.zhanli:SetValue(self.data.capability)
	self.is_leave:SetValue(self.data.is_online ~= 1)

	local prof_str = ToColorStr(Language.Common.ProfName[self.data.prof] or "", PROF_COLOR[self.data.prof])
	self.prof:SetValue(prof_str)
end

function RoleModelCell:SetRoleStateText(value)
	local text = ""
	if value then
		text = Language.Society.Leave
	else
		text = Language.Society.Kickout
	end
	-- self.state_text:SetValue(text)
end

function RoleModelCell:SetRoleStateVisible(value)
	self.state:SetActive(value)
end

function RoleModelCell:ClickItem()
	local function canel_callback()
		if self.root_node then
			self.root_node.toggle.isOn = false
		end
	end
	local main_role_id = GameVoManager.Instance.main_role_vo.role_id
	if main_role_id == self.data.role_id then
		self.root_node.toggle.isOn = false
	else
		ScoietyCtrl.Instance:ShowOperateList(ScoietyData.DetailType.Default, self.data.name, nil, canel_callback)
	end
end