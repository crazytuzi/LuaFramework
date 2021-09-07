
EventObj = EventObj or BaseClass(Character)

function EventObj:__init(vo)
	self.obj_type = SceneObjType.EventObj
	self.draw_obj:SetObjType(self.obj_type)
	self:SetObjId(vo.obj_id)
	self.vo = vo

	self.vo.name = "<color='#ffff00'>秘境降魔</color>"
end

function EventObj:__delete()

end

function EventObj:GetVo()
	return self.vo
end

function EventObj:InitShow()
	Character.InitShow(self)
	local cfg = ConfigManager.Instance:GetAutoConfig("zhuagui_auto")
	local other_cfg = cfg.other_cfg[1] or {}
	local res_scale = other_cfg.res_scale
	local transform = self.draw_obj.root.transform
	transform.localScale = Vector3(res_scale, res_scale, res_scale)

	local scene_id = Scene.Instance:GetSceneId()
	local npc_flush_cfg = cfg.npc_flush_cfg or {}
	local rotationY = 0
	for k, v in ipairs(npc_flush_cfg) do
		if scene_id == v.scene_id then
			rotationY = v.rotation
			break
		end
	end
	transform.localRotation = Quaternion.Euler(0, rotationY, 0)

	self.res_id = other_cfg.res_id or 3014001
	self:ChangeModel(SceneObjPart.Main, ResPath.GetMonsterModel(self.res_id))
end

function EventObj:HideFollowUi()
end

function EventObj:OnEnterScene()
	Character.OnEnterScene(self)
	self:GetFollowUi()
	-- self:CreateTitle()
	self:SetHpVisiable(false)

end

function EventObj:SetHpVisiable(value)
	if nil == self:GetFollowUi() then return end
	self:GetFollowUi():SetHpVisiable(value)
end

function EventObj:CreateTitle()
	self:ChangeSpecailTitle()
end

function EventObj:ChangeSpecailTitle()
	if nil == self:GetFollowUi() then return end
	local str = "2007"
	self:GetFollowUi():ChangeSpecailTitle(str)
end

function EventObj:IsEvent()
	return true
end

function EventObj:OnClick()
	Character.OnClick(self)
	if nil == self.select_effect then
		self.select_effect = AsyncLoader.New(self.draw_obj:GetRoot().transform)
	end
	self.select_effect:Load(ResPath.GetSelectObjEffect2("lvse"))
	self.select_effect:SetActive(true)
end

function EventObj:SyncShowHp()

end

function EventObj:ArriveOperateHandle()
	-- Language.Activity.ZhongKuiEnterTips
	local level_limit = ZhuaGuiData.Instance:GetLevelLimit()
	local describe = string.format(Language.Activity.ZhongKuiEnterTips, PlayerData.GetLevelString(level_limit))

	local function yes_func()
		local team_state = ScoietyData.Instance:GetTeamState()
		local team_user_list = ScoietyData.Instance:GetTeamUserList()

		if not team_state or #team_user_list < 2 then
			SysMsgCtrl.Instance:ErrorRemind(Language.Activity.ZhongKuiNumNeed)
		else
			for k, v in ipairs(team_user_list) do
				local member_info = ScoietyData.Instance:GetMemberInfoByRoleId(v)
				local level_limit = ZhuaGuiData.Instance:GetLevelLimit()
				if member_info.level < level_limit then
					SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Activity.ZhongKuiLevelNeed, PlayerData.GetLevelString(level_limit)))
					return
				end
			end
			self:OnClickOkHandle()
		end
	end
	TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func)
end

function EventObj:OnClickOkHandle()
	-- if self.event_obj_cfg.obj_type == ActEventObj.ZHONGKUI then
	Scene.SendWorldEventObjTouch(self.vo.obj_id)
	-- end
end