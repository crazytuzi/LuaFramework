KuaFuFlowerRankView = KuaFuFlowerRankView or BaseClass(BaseView)

KuaFuFlowerRankView.SexType = {
	Male = 1,
	FeMale = 2,
}

KuaFuFlowerRankView.ServerType = {
	CrossServer = 1,
	OriginServer = 2,
}

function KuaFuFlowerRankView:__init()
	self.ui_config = {"uis/views/kuafuflowerrank", "KuaFuFlowerRankView"}
	self.play_audio = true
	self.is_async_load = false
	self:SetMaskBg(true)

	self.sex_type = KuaFuFlowerRankView.SexType.Male
	self.server_type = KuaFuFlowerRankView.ServerType.CrossServer
	self.cur_page = 1
	self.page_count = 1
	self.row = 6
	self.send_flower = false
	self.rank_list = {}

	self.role_info = GlobalEventSystem:Bind(OtherEventType.RoleInfo, BindTool.Bind(self.RoleInfo, self))
end

function KuaFuFlowerRankView:__delete()
	if self.role_info then
		GlobalEventSystem:UnBind(self.role_info)
		self.role_info = nil
	end
end

function KuaFuFlowerRankView:ReleaseCallBack()
	self.name = nil
	self.meili = nil
	self.rank = nil
	self.title_res = nil
	self.show_meili = nil
	self.show_rank = nil
	self.show_left = nil
	self.show_right = nil
	self.left_time = nil
	self.display = nil
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end

	self.top_cell = {}
	self.top_cell_variables = {}
end

function KuaFuFlowerRankView:OpenCallBack()
	HappyBargainCtrl.Instance:SendGetPersonRankListReq(ACTIVITY_TYPE.CROSS_FLOWER_RANK, CROSS_PERSON_RANK_TYPE.CROSS_PERSON_RANK_TYPE_FLOWER_RANK_MALE)
	HappyBargainCtrl.Instance:SendGetPersonRankListReq(ACTIVITY_TYPE.CROSS_FLOWER_RANK, CROSS_PERSON_RANK_TYPE.CROSS_PERSON_RANK_TYPE_FLOWER_RANK_FEMALE)
	self:SendRequest()
	self:RemoveTimeQuest()
	if nil == self.time_quest then
		self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.TimerFunc, self), 1)
	end
end

function KuaFuFlowerRankView:CloseCallBack()
	self:RemoveTimeQuest()
end

function KuaFuFlowerRankView:RemoveTimeQuest()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
end

function KuaFuFlowerRankView:LoadCallBack()
	self.sex_type = KuaFuFlowerRankView.SexType.Male
	self.server_type = KuaFuFlowerRankView.ServerType.CrossServer

	self.name = self:FindVariable("Name")
	self.meili = self:FindVariable("MeiLi")
	self.rank = self:FindVariable("Rank")
	self.title_res = self:FindVariable("TitleRes")
	self.show_meili = self:FindVariable("ShowMeiLi")
	self.show_rank = self:FindVariable("ShowRank")
	self.show_left = self:FindVariable("ShowLeft")
	self.show_right = self:FindVariable("ShowRight")
	self.left_time = self:FindVariable("LeftTime")
	self.display = self:FindObj("Display")
	self.model = RoleModel.New()
	self.model:SetDisplay(self.display.ui3d_display)

	self.cell = {}
	self.variables = {}
	for i = 1, 6 do
		self.cell[i] = self:FindObj("Cell" .. i)
		self.variables[i] = {}
		self.variables[i].name = self.cell[i]:GetComponent(typeof(UIVariableTable)):FindVariable("name")
		self.variables[i].rank = self.cell[i]:GetComponent(typeof(UIVariableTable)):FindVariable("rank")
		self.variables[i].value = self.cell[i]:GetComponent(typeof(UIVariableTable)):FindVariable("value")
		self.variables[i].show_btn = self.cell[i]:GetComponent(typeof(UIVariableTable)):FindVariable("show_btn")
		self.variables[i].icon_obj = U3DObject(self.cell[i]:GetComponent(typeof(UINameTable)):Find("icon_obj"))
		self.variables[i].raw_obj = U3DObject(self.cell[i]:GetComponent(typeof(UINameTable)):Find("raw_obj"))
		self.cell[i]:GetComponent(typeof(UIEventTable)):ListenEvent("OnClickSend", BindTool.Bind(self.OnClickSend, self, i))
	end

	self.top_cell = {}
	self.top_cell_variables = {}
	for i = 1, 3 do
		self.top_cell[i] = self:FindObj("TopCell" .. i)
		self.top_cell_variables[i] = {}
		self.top_cell_variables[i].name = self.top_cell[i]:GetComponent(typeof(UIVariableTable)):FindVariable("name")
		self.top_cell_variables[i].value = self.top_cell[i]:GetComponent(typeof(UIVariableTable)):FindVariable("value")
		self.top_cell_variables[i].icon_obj = U3DObject(self.top_cell[i]:GetComponent(typeof(UINameTable)):Find("icon_obj"))
		self.top_cell_variables[i].raw_obj = U3DObject(self.top_cell[i]:GetComponent(typeof(UINameTable)):Find("raw_obj"))
		self.top_cell[i]:GetComponent(typeof(UIEventTable)):ListenEvent("ClickHead", BindTool.Bind(self.ClickHead, self, i))
	end

	for i = 1, 2 do
		self:ListenEvent("OnClickSexRank" .. i, BindTool.Bind(self.OnClickSexRank, self, i))
		self:ListenEvent("OnClickServerRank" .. i, BindTool.Bind(self.OnClickServerRank, self, i))
	end
	self:ListenEvent("OnClickPageLeft",  BindTool.Bind(self.OnClickPageLeft, self))
	self:ListenEvent("OnClickPageRight",  BindTool.Bind(self.OnClickPageRight, self))
	self:ListenEvent("OnClickClose", BindTool.Bind(self.Close, self))
	self:ListenEvent("OnClickSendFlower", BindTool.Bind(self.OnClickSendFlower, self))
	self:ListenEvent("OnClickTips", BindTool.Bind(self.OnClickTips, self))
end

function KuaFuFlowerRankView:OnFlush(param_t)
	if self.server_type == KuaFuFlowerRankView.ServerType.CrossServer then
		self.rank_list = KuaFuFlowerRankData.Instance:GetRankList()
	else
		self.rank_list = RankData.Instance:GetRankList()
	end

	self:FlushPageCount()
	self:FlushTopRankInfo()
	self:FlushRankInfo(self.cur_page)
	self:FlushMyRankInfo()
end

function KuaFuFlowerRankView:FlushPageCount()
	local info_count = #self.rank_list
	self.page_count = (info_count - 3) / self.row
	self.page_count = math.ceil(self.page_count)
	if(self.page_count == 0) then
		self.page_count = 1
	end
end

function KuaFuFlowerRankView:OnClickSexRank(sex_type)
	self.cur_page = 1
	self.sex_type = sex_type
	self:SendRequest()
end

function KuaFuFlowerRankView:OnClickServerRank(server_type)
	self.cur_page = 1
	self.server_type = server_type
	self:SendRequest()
end

function KuaFuFlowerRankView:OnClickPageLeft()
	self.cur_page = self.cur_page - 1
	self.cur_page = self.cur_page < 1 and 1 or self.cur_page
	self:FlushRankInfo(self.cur_page)
end

function KuaFuFlowerRankView:OnClickPageRight()
	self.cur_page = self.cur_page + 1
	self.cur_page = self.cur_page > self.page_count and self.page_count or self.cur_page
	self:FlushRankInfo(self.cur_page)
end

function KuaFuFlowerRankView:OnClickSend(index)
	CheckCtrl.Instance:SendQueryRoleInfoReq(self.rank_list[index + (self.cur_page - 1) * 6 + 3].user_id)
	self.send_flower = true
end

function KuaFuFlowerRankView:ClickHead(index)
	if self.server_type == KuaFuFlowerRankView.ServerType.OriginServer then
		ScoietyCtrl.Instance:ShowOperateList(ScoietyData.DetailType.Default, self.rank_list[index].user_name)
		self.send_flower = false
	end
end

function KuaFuFlowerRankView:OnClickSendFlower()
	ViewManager.Instance:Open(ViewName.KuaFuFlowerRewardView)
end

function KuaFuFlowerRankView:OnClickTips()
	TipsCtrl.Instance:ShowHelpTipView(246)
end

function KuaFuFlowerRankView:TimerFunc()
	if self.left_time then
		local server_time = TimeCtrl.Instance:GetServerTime()
		local end_time = TimeUtil.NowDayTimeEnd(server_time)
		self.left_time:SetValue(string.format(Language.KuaFuFlowerRank.LeftTime, TimeUtil.FormatSecond2Str(end_time - server_time)))
	end
end

function KuaFuFlowerRankView:SendRequest()
	if self.sex_type == KuaFuFlowerRankView.SexType.Male then
		if self.server_type == KuaFuFlowerRankView.ServerType.CrossServer then
			HappyBargainCtrl.Instance:SendGetPersonRankListReq(ACTIVITY_TYPE.CROSS_FLOWER_RANK, CROSS_PERSON_RANK_TYPE.CROSS_PERSON_RANK_TYPE_FLOWER_RANK_MALE)
		else
			RankCtrl.Instance:SendGetPersonRankListReq(PERSON_RANK_TYPE.PERSON_RANK_TYPE_FLOWER_MALE)	
		end
	else
		if self.server_type == KuaFuFlowerRankView.ServerType.CrossServer then
			HappyBargainCtrl.Instance:SendGetPersonRankListReq(ACTIVITY_TYPE.CROSS_FLOWER_RANK, CROSS_PERSON_RANK_TYPE.CROSS_PERSON_RANK_TYPE_FLOWER_RANK_FEMALE)	
		else
			RankCtrl.Instance:SendGetPersonRankListReq(PERSON_RANK_TYPE.PERSON_RANK_TYPE_FLOWER_FEMALE)	
		end
	end
end

function KuaFuFlowerRankView:FlushTopRankInfo()
	for i = 1, 3 do
		local info = self.rank_list[i]
		if nil == info then
			self.top_cell[i]:SetActive(false)
		else
			self.top_cell[i]:SetActive(true)
			local camp_name = CampData.Instance:GetCampNameByCampType(info.camp)
			if self.server_type == KuaFuFlowerRankView.ServerType.CrossServer then
				self.top_cell_variables[i].name:SetValue(string.format(Language.KuaFuFlowerRank.CrossName1, info.origin_merge_server_id, info.user_name))
			else
				self.top_cell_variables[i].name:SetValue(info.user_name .. "·" .. camp_name)
			end
			self.top_cell_variables[i].value:SetValue(info.rank_value)
			local is_default_img = AvatarManager.Instance:isDefaultImg(info.user_id) == 0
			self.top_cell_variables[i].icon_obj.gameObject:SetActive(is_default_img)
			self.top_cell_variables[i].raw_obj.gameObject:SetActive(not is_default_img)

			AvatarManager.Instance:SetAvatarKey(info.user_id, info.avatar_key_big, info.avatar_key_small)
			if is_default_img then
				if (info.sex == GameEnum.FEMALE and self.sex_type == KuaFuFlowerRankView.SexType.FeMale) or
					(info.sex == GameEnum.MALE and self.sex_type == KuaFuFlowerRankView.SexType.Male) then
					local bundle, asset = AvatarManager.GetDefAvatar(info.prof, false, info.sex)
					self.top_cell_variables[i].icon_obj.image:LoadSprite(bundle, asset)
				end
			else
				local callback = function (path)
					local avatar_path = path or AvatarManager.GetFilePath(info.user_id, false)
					if self.top_cell_variables[i] ~= nil then
						self.top_cell_variables[i].raw_obj.raw_image:LoadSprite(avatar_path, function()
					 	end)
					end
				end
				AvatarManager.Instance:GetAvatar(info.user_id, false, callback)
			end
		end
	end
	local rank_list = {}
	if self.sex_type == KuaFuFlowerRankView.SexType.Male then
		rank_list = KuaFuFlowerRankData.Instance:GetCrossRankMaleList()
	else
		rank_list = KuaFuFlowerRankData.Instance:GetCrossRankFeMaleList()
	end
	if nil ~= rank_list[1] then
		local vo = GameVoManager.Instance:GetMainRoleVo()
		if vo.origin_merge_server_id == rank_list[1].origin_merge_server_id then
			CheckCtrl.Instance:SendQueryRoleInfoReq(rank_list[1].user_id)
		else
			CheckCtrl.Instance:SendCrossQueryRoleInfo(rank_list[1].plat_type, rank_list[1].user_id)
		end
		self.send_flower = false
	else
		if self.model then
			self.model:SetVisible(false)
		end
	end
end

function KuaFuFlowerRankView:FlushRankInfo(cur_page)
	local min_dex = 4 + (cur_page - 1) * 6
	local max_dex = 9 + (cur_page - 1) * 6
	for i = min_dex, max_dex do
		local info = self.rank_list[i]
		local index = i - (cur_page - 1) * 6 - 3
		if nil == info then
			self.cell[index]:SetActive(false)
		else
			self.cell[index]:SetActive(true)
			local camp_name = CampData.Instance:GetCampNameByCampType(info.camp)
			if self.server_type == KuaFuFlowerRankView.ServerType.CrossServer then
				self.variables[index].name:SetValue(string.format(Language.KuaFuFlowerRank.CrossName, info.origin_merge_server_id, info.user_name, camp_name))
			else
				self.variables[index].name:SetValue(string.format(Language.KuaFuFlowerRank.OriginName, info.user_name, camp_name))
			end
			self.variables[index].rank:SetValue(string.format(Language.KuaFuFlowerRank.Rank, i))
			self.variables[index].value:SetValue(string.format(Language.KuaFuFlowerRank.MeiLiZhi, info.rank_value))
			self.variables[index].show_btn:SetValue(self.server_type == KuaFuFlowerRankView.ServerType.OriginServer)
			
			local is_default_img = AvatarManager.Instance:isDefaultImg(info.user_id) == 0
			self.variables[index].icon_obj.gameObject:SetActive(is_default_img)
			self.variables[index].raw_obj.gameObject:SetActive(not is_default_img)

			AvatarManager.Instance:SetAvatarKey(info.user_id, info.avatar_key_big, info.avatar_key_small)
			if is_default_img then
				if (info.sex == GameEnum.FEMALE and self.sex_type == KuaFuFlowerRankView.SexType.FeMale) or
					(info.sex == GameEnum.MALE and self.sex_type == KuaFuFlowerRankView.SexType.Male) then
					local bundle, asset = AvatarManager.GetDefAvatar(info.prof, false, info.sex)
					self.variables[index].icon_obj.image:LoadSprite(bundle, asset)
				end
			else
				local callback = function (path)
					local avatar_path = path or AvatarManager.GetFilePath(info.user_id, false)
					self.variables[index].raw_obj.raw_image:LoadSprite(avatar_path, function()
				 	end)
				end
				AvatarManager.Instance:GetAvatar(info.user_id, false, callback)
			end
		end
	end

	self.show_left:SetValue(cur_page > 1)
	self.show_right:SetValue(cur_page < self.page_count)
end

function KuaFuFlowerRankView:FlushMyRankInfo()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local meili_value = 0
	local rank = 0
	for k, v in pairs(self.rank_list) do
		if v.user_id == vo.role_id then
			meili_value = v.rank_value
			rank = k
		end
	end
	self.meili:SetValue(string.format(Language.KuaFuFlowerRank.MyMeiLiZhi, meili_value))
	if rank == 0 then
		self.rank:SetValue(string.format(Language.KuaFuFlowerRank.MyRank, Language.KuaFuFlowerRank.WeiShangBang))
	else
		self.rank:SetValue(string.format(Language.KuaFuFlowerRank.MyRank, rank))
	end
	if self.sex_type == KuaFuFlowerRankView.SexType.Male then
		self.show_meili:SetValue(vo.sex == GameEnum.MALE)
		self.show_rank:SetValue(vo.sex == GameEnum.MALE)
		self.title_res:SetAsset(ResPath.GetKuaFuFlowerRankImage("bg_nanshen"))
	else
		self.show_meili:SetValue(vo.sex == GameEnum.FEMALE)
		self.show_rank:SetValue(vo.sex == GameEnum.FEMALE)
		self.title_res:SetAsset(ResPath.GetKuaFuFlowerRankImage("bg_nvshen"))
	end

	if nil == next(self.rank_list) then
		self.name:SetValue(string.format(Language.KuaFuFlowerRank.Name[self.sex_type], Language.KuaFuFlowerRank.ZanWu))
	else
		local info = self.rank_list[1]
		self.name:SetValue(string.format(Language.KuaFuFlowerRank.Name[self.sex_type], info.user_name))
	end
end

function KuaFuFlowerRankView:RoleInfo(user_id, protocol)
	if self.send_flower then
		if protocol.role_is_online == 0 then
			SysMsgCtrl.Instance:ErrorRemind(Language.Chat.NotOnline)
			return
		end
		FlowersCtrl.Instance:SetFriendInfo(protocol)
		ViewManager.Instance:Open(ViewName.Flowers)
	else
		local male_list = KuaFuFlowerRankData.Instance:GetCrossRankMaleList()
		local female_list = KuaFuFlowerRankData.Instance:GetCrossRankFeMaleList()
		if nil ~= male_list[1] or nil ~= female_list[1] then
			if user_id == male_list[1].user_id or user_id == female_list[1].user_id then
				if self.model then
					self.model:SetVisible(true)
					self.model:SetModelResInfo(protocol)
				end
			end
		end
	end
end