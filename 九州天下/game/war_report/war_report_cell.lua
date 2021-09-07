local REPORT_ITEM_HEIGHT = 45
-- 排行榜
WarRankItem = WarRankItem or BaseClass(BaseCell)
function WarRankItem:__init()
	self.name = self:FindVariable("Name")
	self.kill_num = self:FindVariable("KillNum")
	self.rank_icon = self:FindVariable("RankIcon")
	self.rank_num = self:FindVariable("RankNum")

	self.rank_icon_obj = self:FindObj("RankIconObj")

		--头像UI
	self.image_obj = self:FindObj("RoleImage")
	self.raw_image_obj = self:FindObj("RawImage")

	self.image_res = self:FindVariable("ImageRes")
	self.rawimage_res = self:FindVariable("RawImageRes")

	self.show_select = self:FindVariable("show_select")

	self:ListenEvent("click", BindTool.Bind(self.OnClick, self))
end

function WarRankItem:OnFlush()
	if self.data == nil or not next(self.data) then 
		return 
	end

	local name = ToColorStr(CampData.Instance:GetCampNameByCampType(self.data.camp, true), CAMP_COLOR[self.data.camp]) .. self.data.user_name
	local level = ToColorStr(string.format(Language.Common.LevelFormat, self.data.level), "#ff700c")
	self.name:SetValue(name .. "\n" .. level)

	local kill_num
	if self.data.user_id == GameVoManager.Instance:GetMainRoleVo().role_id then
		local rank, kill = WarReportData.Instance:GetMyRankAndNum()
		kill_num = kill
	else
		kill_num = self.data.rank_value
	end

	local kill_str = string.format(Language.WarReport.RankKill, kill_num)

	self.kill_num:SetValue(kill_str)
	self:FlushRoleHead()
	self:FlushRankIcon()
end

function WarRankItem:FlushRoleHead()
	AvatarManager.Instance:SetAvatarKey(self.data.user_id, self.data.avatar_key_big, self.data.avatar_key_small)
	if self.data.avatar_key_small == 0 then
		self.image_obj.gameObject:SetActive(true)
		self.raw_image_obj.gameObject:SetActive(false)
		local bundle, asset = AvatarManager.GetDefAvatar(self.data.prof, false, self.data.sex)
		self.image_res:SetAsset(bundle, asset)
	else
		local function callback(path)
			if IsNil(self.image_obj.gameObject) or IsNil(self.raw_image_obj.gameObject) then
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
end

function WarRankItem:SetSelect(index)
	self.show_select:SetValue(index == self.index)
end


function WarRankItem:FlushRankIcon()
	self.rank_num:SetValue(self.index)
	local bundle, asset = "", ""
	if self.index <= 3 then
		bundle, asset = ResPath.GetImages("rank_" .. self.index)
	end
	
	self.rank_icon:SetAsset(bundle, asset)
	self.rank_num:SetValue(self.index)
	self.rank_icon_obj:SetActive(self.index < 3)
end

function WarRankItem:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end


---------------------------------------- 战报Cell
WarReportItem = WarReportItem or BaseClass(BaseCell)
function WarReportItem:__init()
	self.report_type = WAR_REPORT_TYPE.HONOR_REPORT

	self.pos_obj = self:FindObj("Pos")
	self.content_obj = self:FindObj("ContentObj")

	self.name = self:FindVariable("Name")
	-- self.pos = self:FindVariable("Pos")

	self:ListenEvent("Fly", BindTool.Bind1(self.FlyToScene, self))
end

function WarReportItem:OnFlush()
	if self.data == nil or not next(self.data) then 
		self:SetActive(false)
		return 
	end

	self.pos_obj:SetActive(false)
	if WAR_REPORT_TYPE.NORMAL_REPORT == self.report_type then
		self.pos_obj:SetActive(true)
		-- self:ShowPosStr()
	end

	self:ShowNameStr()
end

function WarReportItem:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end

function WarReportItem:SetReportType(report_type)
	self.report_type = report_type 
end

function WarReportItem:FlyToScene()
	-- print(ToColorStr("fly_fly_fly_fly", COLOR.RED))
	TaskCtrl.SendFlyByShoe(self.data.scene_id, self.data.pos_x, self.data.pos_y)
	ViewManager.Instance:Close(ViewName.WarReport)
end

function WarReportItem:ShowNameStr()
	local killer_str = ""
	if WAR_REPORT_TYPE.HONOR_REPORT == self.report_type then
		killer_str = string.format(Language.WarReport.Name, 
						CampData.Instance:GetCampNameByCampType(self.data.killer_camp, false, false, true),
						"",
						-- Language.Common.CampPost[self.data.killer_camp_post], 
						self.data.killer_name)
	else
		killer_str = string.format(Language.WarReport.NameShort, 
						CampData.Instance:GetCampNameByCampType(self.data.killer_camp, false, false, true),
						self.data.killer_name)
	end

	local show_str = "" 
	if WAR_REPORT_ENUM.BATTLE_REPORT_TYPE_KILL_OTHER == self.data.type then        
		local dead_str =  ""
		if WAR_REPORT_TYPE.HONOR_REPORT == self.report_type then
			dead_str = string.format(Language.WarReport.Name, 
					CampData.Instance:GetCampNameByCampType(self.data.dead_camp, false, false, true),
					Language.Common.CampPost[self.data.dead_camp_post], 
					self.data.dead_name)
		else
			dead_str = string.format(Language.WarReport.NameShort, 
						CampData.Instance:GetCampNameByCampType(self.data.dead_camp, false, false, true),
						self.data.dead_name)
		end

		if self.data.multi_kill_num > 0 and WAR_REPORT_TYPE.HONOR_REPORT == self.report_type then 
			show_str =  string.format(Language.WarReport.KillOtherNum,
				ToColorStr(killer_str, CAMP_COLOR[self.data.killer_camp]),
				ToColorStr(dead_str, CAMP_COLOR[self.data.dead_camp]),
				self.data.multi_kill_num)
		else
			show_str =  string.format(Language.WarReport.KillOther,
				ToColorStr(killer_str, CAMP_COLOR[self.data.killer_camp]),
				ToColorStr(dead_str, CAMP_COLOR[self.data.dead_camp]))
		end
	else
		local num_str = CommonDataManager.GetDaXie(self.data.kill_num)
		show_str = string.format(Language.WarReport.MultiKill, ToColorStr(killer_str, CAMP_COLOR[self.data.killer_camp]), num_str)
	end
	self.name:SetValue(show_str)
end

function WarReportItem:ShowPosStr()
	local scene_config = ConfigManager.Instance:GetSceneConfig(self.data.scene_id)
	local show_pos = string.format(Language.WarReport.Pos, scene_config.name, self.data.pos_x, self.data.pos_y)
	-- self.pos:SetValue(show_pos)
end

function WarReportItem:GetContentHeight()
	local height = self.content_obj:GetComponent(typeof(UnityEngine.RectTransform)).rect.height
	--local height = self.content_obj.rect.height
	local content_height = height > REPORT_ITEM_HEIGHT and height or REPORT_ITEM_HEIGHT
	return content_height
end