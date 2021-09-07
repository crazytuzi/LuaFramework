TRIGGER_ACTION_TYPE =
{
	INVALID = 0,

	CREATE_MONSTER = 1,								-- 刷怪
	SURROUND_MONSTER = 2,							-- 出埋伏怪
	SET_FB_FOLLOW_NPC = 3,							-- 设置副本跟随NPC
	RESET_FB_FOLLOW_NPC = 4,						-- 取消副本跟随NPC
	SPECIAL_DICI = 5,								-- 地刺
	SPECIAL_BEILAO = 6,								-- 焙烙
	SPECIAL_BANMASUO = 7,							-- 绊马索
	PLAY_STORY = 8,									-- 播放剧情
	CREATE_MONSTER_APPOINT_POS = 9,					-- 定点刷怪
	SPECIALLOGIC = 10,								-- 触发场景特殊逻辑
	ICE_LANDMINE = 11,								-- 冰霜地雷
	FIRE_LANDMINE = 12,								-- 火焰地雷

	MAX = 13
}

TriggerObj = TriggerObj or BaseClass(SceneObj)

function TriggerObj:__init(vo)
	self.res_id = 0
	self.obj_type = SceneObjType.Trigger
	self.draw_obj:SetObjType(self.obj_type)
end

function TriggerObj:__delete()
end

function TriggerObj:InitInfo()
	SceneObj.InitInfo(self)
end

function TriggerObj:IsTrigger()
	return true
end

function TriggerObj:InitShow()
	SceneObj.InitShow(self)
	if self.vo.action_type == TRIGGER_ACTION_TYPE.FIRE_LANDMINE then
		self.res_id = "14001001"
	elseif self.vo.action_type == TRIGGER_ACTION_TYPE.ICE_LANDMINE then
		self.res_id = "14002001"
	end
	self:ChangeModel(SceneObjPart.Main, ResPath.GetTriggerModel(self.res_id))
	if Scene.Instance:GetSceneType() == SceneType.ClashTerritory then
		self.draw_obj:SetVisible(self.vo.affiliation == ClashTerritoryData.Instance:GetMainRoleTerritoryWarSide())
	end
end

function TriggerObj:OnClick()
	if SceneObj.select_obj then
		SceneObj.select_obj:CancelSelect()
		SceneObj.select_obj = nil
	end
	self.is_select = true
	SceneObj.select_obj = self
end