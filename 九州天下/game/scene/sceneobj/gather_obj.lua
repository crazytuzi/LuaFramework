SPECIAL_GATHER_TYPE =
{
	JINGHUA = 1,				-- 精华采集
	GUILDBATTLE = 2,			-- 公会争霸采集物
	FUN_OPEN_MOUNT = 3, 		-- 功能开启副本-坐骑
	FUN_OPEN_WING = 4,			-- 功能开启副本-羽翼
	GUILD_BONFIRE = 5,			-- 仙盟篝火
	CROSS_FISHING = 6,			-- 钓鱼鱼篓
	CAMP_BATTLE = 7,			-- 跨服六界宝箱
}

GatherObj = GatherObj or BaseClass(SceneObj)

function GatherObj:__init(item_vo)
	self.obj_type = SceneObjType.GatherObj
	self.draw_obj:SetObjType(self.obj_type)
	self:SetObjId(item_vo.obj_id)
	self.rotation_y = 0
end

function GatherObj:__delete()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
end

function GatherObj:InitInfo()
	SceneObj.InitInfo(self)

	local gather_config = ConfigManager.Instance:GetAutoConfig("gather_auto").gather_list[self.vo.gather_id]
	if nil == gather_config then
		print_log("gather_config not find, gather_id:" .. self.vo.gather_id)
		return
	end

	self.vo.name = gather_config.show_name
	if self.vo.special_gather_type == SPECIAL_GATHER_TYPE.GUILD_BONFIRE then
		self.vo.name = string.format(Language.Guild.GuildGoddessName, self.vo.param2)
	elseif self.vo.special_gather_type == SPECIAL_GATHER_TYPE.CROSS_FISHING then
		self.vo.name = self.vo.param2 .. "·" .. self.vo.name
	elseif self.vo.special_gather_type == SPECIAL_GATHER_TYPE.CAMP_BATTLE then
		self.vo.name = string.format(Language.KuafuGuildBattle.GatherBoxName, Language.Guild.GuildCamp[self.vo.param], self.vo.name, self.vo.param1)
	end

	self.resid = gather_config.resid
	self.scale = gather_config.scale
	self.rotation_y = gather_config.rotation or 0
	self.beauty_res = gather_config.beauty_res or 0
	self.monster_res = gather_config.monster_res or 0
end

function GatherObj:InitShow()
	SceneObj.InitShow(self)

	if self.vo.special_gather_type == SPECIAL_GATHER_TYPE.GUILD_BONFIRE then
		local res_id = GuildBonfireData:GetBonfireOtherCfg().gather_res
		self:ChangeModel(SceneObjPart.Main, ResPath.GetNpcModel(res_id))
		local transform = self.draw_obj:GetRoot().transform
		transform.localScale = Vector3(1.5, 1.5, 1.5)
	else
		--self:ChangeModel(SceneObjPart.Main, ResPath.GetGatherModel(2001))
		-- self:ChangeModel(SceneObjPart.Main, "actors/gather/6001", "6001001")	--没有其他美术资源
		if self.beauty_res ~= 0 then
			self:ChangeModel(SceneObjPart.Main, ResPath.GetGoddessNotLModel(self.beauty_res))
		elseif self.monster_res ~= 0 then
			self:ChangeModel(SceneObjPart.Main, ResPath.GetMonsterModel(self.monster_res))
		else 
			self:ChangeModel(SceneObjPart.Main, ResPath.GetGatherModel(self.resid))
		end
		if self.scale then
			local transform = self.draw_obj:GetRoot().transform
			transform.localScale = Vector3(self.scale, self.scale, self.scale)
		end
	end
	if self.rotation_y ~= 0 then
		self.draw_obj:Rotate(0, self.rotation_y, 0)
	end
end

function GatherObj:OnEnterScene()
	SceneObj.OnEnterScene(self)
	if self.vo and self.vo.special_gather_type == SPECIAL_GATHER_TYPE.GUILD_BONFIRE then
		self:GetFollowUi():Show()
		self.follow_ui.root_obj.transform.localScale = Vector3(1.5, 1.5, 1.5)
	end
	self:PlayAction()
end

function GatherObj:GetGatherId()
	return self.vo.gather_id
end

function GatherObj:IsGather()
	return true
end

function GatherObj:CanHideFollowUi()
	return not self.is_select and (self.vo and self.vo.special_gather_type ~= SPECIAL_GATHER_TYPE.GUILD_BONFIRE)
end

function GatherObj:PlayAction()
	if nil == self.vo or self.vo.special_gather_type ~= SPECIAL_GATHER_TYPE.GUILD_BONFIRE then
		return
	end

	local draw_obj = self:GetDrawObj()
	if draw_obj then
		local part = draw_obj:GetPart(SceneObjPart.Main)
		if part then
			part:SetTrigger("Action")
			self.time_quest = GlobalTimerQuest:AddDelayTimer(function() self:PlayAction() end, 10)
		end
	end
end
