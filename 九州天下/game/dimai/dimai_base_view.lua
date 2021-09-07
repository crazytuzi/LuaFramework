DiMaiBaseView = DiMaiBaseView or BaseClass(BaseRender)

function DiMaiBaseView:__init()
	self.scene_count = 0
end

function DiMaiBaseView:__delete()
	if self.role_info_callback then
		GlobalEventSystem:UnBind(self.role_info_callback)
		self.role_info_callback = nil
	end

	self.role_uid_list = {}

	self.scene_list = {}
	self.scene_name = {}
	self.role_name = {}
	self.role_head = {}
	self.show_role_head = {}
	self.show_head_panel = {}
	self.role_portrait_raw = {}
	self.capability = {}
	self.is_mine = {}

	if self.time_quest then
		for k, v in pairs(self.time_quest) do
			if v then
				GlobalTimerQuest:CancelQuest(v)
				v = nil
			end
		end
		self.time_quest = {}
	end
	self.scene_count = 0
end

function DiMaiBaseView:SetData(count)
	if count and count > 0 then
		self.scene_count = count
		self:OnLoadCallBack()
	end
end

function DiMaiBaseView:OnLoadCallBack()
	self.role_uid_list = {}

	self.scene_list = {}
	self.scene_name = {}
	self.role_name = {}
	self.role_head = {}
	self.show_role_head = {}
	self.show_head_panel = {}
	self.role_portrait_raw = {}
	self.capability = {}
	self.is_mine = {}

	self.time_quest = {}
	
	for i = 1, self.scene_count do
		self.scene_list[i] = self:FindObj("Scene" .. i)

		local ui_variable_table = self.scene_list[i]:GetComponent(typeof(UIVariableTable))
		self.scene_name[i] = ui_variable_table:FindVariable("MapName")
		self.role_name[i] = ui_variable_table:FindVariable("RoleName")		-- 已扩展冷却时间，占领人，正在挑战的切换显示
		self.role_head[i] = ui_variable_table:FindVariable("RoleHead")
		self.show_role_head[i] = ui_variable_table:FindVariable("ShowRoleHead")
		self.show_head_panel[i] = ui_variable_table:FindVariable("ShowHeadPanel")
		self.capability[i] = ui_variable_table:FindVariable("Capability")
		self.is_mine[i] = ui_variable_table:FindVariable("IsMine")
		
		local ui_name_table = self.scene_list[i]:GetComponent(typeof(UINameTable))
		self.role_portrait_raw[i] = U3DObject(ui_name_table:Find("PortraitRaw"))
		
		self.scene_list[i]:GetComponent(typeof(UIEventTable)):ListenEvent("OnClickChallenge", BindTool.Bind(self.OnClickChallenge, self, i))
	end	

	if self.role_info_callback == nil then
		self.role_info_callback = GlobalEventSystem:Bind(OtherEventType.RoleInfo, BindTool.Bind(self.RoleInfoCallBack, self))
	end
end

function DiMaiBaseView:RoleInfoCallBack(uid, info)
	for k, v in pairs(self.role_uid_list) do
		if uid == self.role_uid_list[k] then
			local role_vo = GameVoManager.Instance:GetMainRoleVo()
			if role_vo and role_vo.role_id == info.role_id then
				self.role_name[k]:SetValue(Language.QiangDiMai.OneSelfShow)
			else
				local camp_name = CampData.Instance:GetCampNameByCampType(info.camp_id, true, false, false)
				if camp_name then
					self.role_name[k]:SetValue(camp_name .. info.role_name)
				end
			end

			self.show_role_head[k]:SetValue(AvatarManager.Instance:isDefaultImg(info.role_id) == 0)
			AvatarManager.Instance:SetAvatarKey(info.role_id, info.avatar_key_big, info.avatar_key_small)
			if AvatarManager.Instance:isDefaultImg(info.role_id) == 0 then
				local bundle, asset = AvatarManager.GetDefAvatar(info.prof, false, info.sex)
				self.role_head[k]:SetAsset(bundle, asset)
			else
				local callback = function (path)
					local avatar_path = path or AvatarManager.GetFilePath(info.role_id, false)
					if self.role_portrait_raw ~= nil and self.role_portrait_raw[k] ~= nil then
						self.role_portrait_raw[k].raw_image:LoadSprite(avatar_path, function()
					 	end)
					end
				end
				AvatarManager.Instance:GetAvatar(info.role_id, false, callback)
			end
		end
	end
end

function DiMaiBaseView:OnFlush()
	local layer_dimai_info = DiMaiData.Instance:GetLayerDimaiInfo().item_list
	if layer_dimai_info then
		self.role_uid_list = {}
		for i = 1, self.scene_count do
			local dimai_info = layer_dimai_info[i].dimai_info
			-- 冷却时间，占领人，正在挑战的切换显示
			self:FlushRemind(i, layer_dimai_info[i])

			local dimai_info_cfg = DiMaiData.Instance:GetDiMaiInfoCfg(dimai_info.layer, dimai_info.point)
			if dimai_info_cfg then
				self.scene_name[i]:SetValue(dimai_info_cfg.dimai_name)
				
				-- 推荐战力
				local zhanli = dimai_info.challenge_succ_times * dimai_info_cfg.increasing_force + dimai_info_cfg.initial_force
				self.capability[i]:SetValue(string.format(Language.QiangDiMai.RecommendedFightPower, zhanli or 0))
			end

			local role_vo = GameVoManager.Instance:GetMainRoleVo()
			self.is_mine[i]:SetValue(role_vo and role_vo.role_id == dimai_info.uid)
		end
	end
end

-- 冷却时间，占领人，正在挑战的切换显示
function DiMaiBaseView:FlushRemind(i, dimai_info_layer)
	if i <= 0 then return end
	local dimai_info = dimai_info_layer.dimai_info
	local dimai_info_cfg = DiMaiData.Instance:GetDiMaiInfoCfg(dimai_info.layer, dimai_info.point)
	if not dimai_info_cfg then return end

	local protect_time = dimai_info.protect_begin_time + dimai_info_cfg.protect_time
	-- 有人正在挑战
	if dimai_info_layer.is_challenging > 0 then
		self.role_name[i]:SetValue(Language.QiangDiMai.Challenging)

	-- 在冷却中
	elseif protect_time > TimeCtrl.Instance:GetServerTime() then
		if self.time_quest[i] == nil then
			self.time_quest[i] = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.ProtectTime, self, i, dimai_info, protect_time), 0)
		end

	-- 显示占有人
	else
		if dimai_info.uid ~= 0 then
			self.role_uid_list[i] = dimai_info.uid
			CheckCtrl.Instance:SendQueryRoleInfoReq(dimai_info.uid)
		else
			self.role_name[i]:SetValue(Language.Common.ZanWu)
		end
		self.show_head_panel[i]:SetValue(dimai_info.uid ~= 0)
	end
end

function DiMaiBaseView:ProtectTime(i, dimai_info, protect_time)
	local time = protect_time - TimeCtrl.Instance:GetServerTime()
	if time <= 0 then
		GlobalTimerQuest:CancelQuest(self.time_quest[i])
		self.time_quest[i] = nil
		DiMaiCtrl.Instance:SendReqDimaiOpera(DIMAI_OPERA_TYPE.DIMAI_OPERA_TYPE_DIMAI_INFO, dimai_info.layer, 0)
		return
	end
	self.role_name[i]:SetValue(string.format(Language.QiangDiMai.ProtectTime, TimeUtil.FormatSecond(time, time >= 3600 and 3 or 2)))
end

function DiMaiBaseView:OnClickChallenge(index)
	local dimai_info = DiMaiData.Instance:GetLayerDimaiInfo().item_list[index]
	if dimai_info then
		TipsCtrl.Instance:OpenDiMaiChallengeTip(dimai_info)
	end
end