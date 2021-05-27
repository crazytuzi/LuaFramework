MainuiData = MainuiData or BaseClass()

MainUiNodeName = {
	RoleExp = "RoleExp",							-- 主界面经验条
	HeadbarBtn = "HeadbarBtn",						-- 主界面头像按钮
	HeadbarCap = "HeadbarCap",						-- 主界面头像战斗力
}

MainuiData.UI_MAX_SCALE = 1

MainuiData.UI_MIN_SCALE = 0.7
MainuiData.UI_NORAML_SCALE = 1

function MainuiData:__init()
	if MainuiData.Instance then
		ErrorLog("[MainuiData]:Attempt to create singleton twice!")
	end
	MainuiData.Instance = self

	self.ui_scale = 1
	self:UpdateMainuiScale()

	self.area_skill_id = 0
	self.area_skill_range = 0
end

function MainuiData:__delete()
	MainuiData.Instance = nil
end

function MainuiData:UpdateMainuiScale()
	self.ui_scale = tonumber(cc.UserDefault:getInstance():getStringForKey("MAINUI_SCALE_VAL")) or 1

	--ipad 初始化UI大小
	local director = cc.Director:getInstance()
	local glview = director:getOpenGLView()
	local frame_size = glview:getFrameSize()
	if cc.PLATFORM_OS_IPAD == PLATFORM or frame_size.height >= 768 and frame_size.width / frame_size.height <= 4/3 then
		if self.ui_scale > 0.9 then
			self.ui_scale = 0.9
			cc.UserDefault:getInstance():setStringForKey("MAINUI_SCALE_VAL", tostring(self.ui_scale))
		end
	end
end

function MainuiData:SetMainuiScale(scale)
	if scale >= MainuiData.UI_MIN_SCALE and scale <= MainuiData.UI_MAX_SCALE and self.ui_scale ~= scale then
		self.ui_scale = scale
		GlobalEventSystem:Fire(MainUIEventType.UI_SCALE_CHANGE, scale)
	end
end

function MainuiData:SaveMainuiScale()
	cc.UserDefault:getInstance():setStringForKey("MAINUI_SCALE_VAL", tostring(self.ui_scale))
end

function MainuiData:GetMainuiScale()
	return self.ui_scale
end

function MainuiData:GetAreaSkillId()
	return self.area_skill_id
end

function MainuiData:SetAreaSkillId(skill_id)
	self.area_skill_id = skill_id
	GlobalEventSystem:Fire(OtherEventType.AREA_SKILL_ID_CHANGE, skill_id)
end

function MainuiData:GetAreaSkillRange()
	return self.area_skill_range
end

function MainuiData:SetAreaSkillRange(skill_range)
	self.area_skill_range = skill_range
end

function MainuiData:GetMonsterRewardCfg(monster_id)
	for k,v in pairs(ModBossConfig) do
		for k1, v1 in pairs(v) do
			if monster_id == v1.BossId then
				-- local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
				return v1.drops
			end
		end
	end
	return nil
end

function MainuiData:GetSkillbarMenuCfg()
	return not IS_ON_CROSSSERVER and {
		{id = 2, res = "02", page = "1", view_name = ViewName.Equipment, remind_group = RemindGroupName.EquipmentView, view_pos = ViewDef.Equipment},
		{id = 3, res = "05", page = "1", view_name = ViewName.Wing, view_pos = ViewDef.Wing, remind_group = RemindGroupName.WingView},
		{id = 3, res = "08", page = "1", view_name = ViewName.Office, remind_group = RemindGroupName.OfficeView},
		{id = 4, res = "09", page = "1", view_name = ViewName.Achieve, remind_group = RemindGroupName.Achieve},
		
		{id = 1, res = "06", page = "2", view_name = ViewName.Zhanjiang, remind_group = RemindGroupName.ZhanjiangView},
		{id = 5, res = "07", page = "2", view_name = ViewName.Guild,},
		{id = 6, res = "03", page = "2", view_name = ViewName.EqCompose, remind_group = RemindGroupName.EquipmentComposeView},
		{id = 8, res = "35", page = "2", view_name = ViewName.Society, },
	} or {
		{id = 1, res = "06", page = "2", view_name = ViewName.Zhanjiang, remind_group = RemindGroupName.ZhanjiangView},
	}
end
