GuildBattleSceneLogic = GuildBattleSceneLogic or BaseClass(CommonActivityLogic)

function GuildBattleSceneLogic:__init()
	self.is_show_auto_effect = true
	self.main_ui_auto_change = GlobalEventSystem:Bind(MainUIEventType.CLICK_AUTO_BUTTON, BindTool.Bind(self.OnAutoChange, self))
end

function GuildBattleSceneLogic:__delete()
	if self.main_ui_auto_change then
		GlobalEventSystem:UnBind(self.main_ui_auto_change)
		self.main_ui_auto_change = nil
	end
end

function GuildBattleSceneLogic:Enter(old_scene_type, new_scene_type)
	CommonActivityLogic.Enter(self, old_scene_type, new_scene_type)
	FightMountCtrl.Instance:SendGoonFightMountReq(0)
	if MainUICtrl.Instance.view then
		MainUICtrl.Instance.view:SetViewState(false)
	end
	GuildFightCtrl.Instance:OpenView()
	ViewManager.Instance:Close(ViewName.Guild)
	MainUICtrl.Instance:FlushView("auto_effect")
end

function GuildBattleSceneLogic:Out(old_scene_type, new_scene_type)
	CommonActivityLogic.Out(self, old_scene_type, new_scene_type)
	if MainUICtrl.Instance.view then
		MainUICtrl.Instance.view:SetViewState(true)
	end
	GuildFightCtrl.Instance:CloseView()

	self.is_show_auto_effect = false
	MainUICtrl.Instance:FlushView("auto_effect")
end

function GuildBattleSceneLogic:OnAutoChange()
	if not self.is_show_auto_effect then return end

	self.is_show_auto_effect = false
	MainUICtrl.Instance:FlushView("auto_effect")
end

function GuildBattleSceneLogic:GetRoleNameBoardText(role_vo)
	local t = {}
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local is_camp = (role_vo.guild_id == main_role_vo.guild_id)
	t[1] = {}
	t[1].color = is_camp and COLOR.BLUE or COLOR.RED
	t[1].text = role_vo.name
	if main_role_vo.role_id == role_vo.role_id then
		t[1].color = COLOR.YELLOW
	end
	return t
end

-- 获取采集物特殊名字显示
function GuildBattleSceneLogic:GetGatherSpecialText(gather_vo)
	local t = {}
	local guild_name, guild_camp = GuildBattleData.Instance:GetGuildNameByGatherId(gather_vo.gather_id)
	if guild_name then
		t[1] = {}
		t[1].color = CAMP_COLOR[guild_camp]
		t[1].text = "【" .. guild_name .. "】"
		return t
	end
	return t
end

function GuildBattleSceneLogic:IsRoleEnemy(target_obj, main_role)
	if main_role:GetVo().guild_id == target_obj:GetVo().guild_id then			-- 同一边
		return false, Language.Fight.Side
	end
	return true
end

-- 是否是挂机打怪的敌人
function GuildBattleSceneLogic:IsGuiJiMonsterEnemy(target_obj)
	if nil == target_obj or target_obj:GetType() ~= SceneObjType.Role
		or target_obj:IsRealDead() or not Scene.Instance:IsEnemy(target_obj) then
		return false
	end
	return true
end

-- 获取挂机打怪的敌人
function GuildBattleSceneLogic:GetGuiJiMonsterEnemy()
	local x, y = Scene.Instance:GetMainRole():GetLogicPos()
	local distance_limit = COMMON_CONSTS.SELECT_OBJ_DISTANCE * COMMON_CONSTS.SELECT_OBJ_DISTANCE
	return Scene.Instance:SelectObjHelper(Scene.Instance:GetRoleList(), x, y, distance_limit, SelectType.Enemy)
end

function GuildBattleSceneLogic:OnClickHeadHandler(is_show)
	CommonActivityLogic.OnClickHeadHandler(self, is_show)
	GuildBattleCtrl.Instance:ShowAction(is_show)
end

function GuildBattleSceneLogic:GetAutoGuajiPriority()
	return true
end

-- 怪物是否是敌人
function GuildBattleSceneLogic:IsMonsterEnemy(target_obj, main_role)
	local id = target_obj:GetMonsterId()
	return GuildFightData.Instance:MonsterIsEnemy(id, target_obj:GetLogicPos())
end

function GuildBattleSceneLogic:AlwaysShowMonsterName()
	return true
end