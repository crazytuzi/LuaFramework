-----------------------------------
--角色行为 节点相关定义

local behavior = {}

--游戏数据
local get_target_obj = function ()
	Scene.Instance:GetObjectByObjId(GuajiCache.old_target_obj_id)
end 

----前提条件
--是否在未知暗殿
function behavior.IsInWeiZhiAnDian()
	return Scene.Instance:GetSceneId() == WeiZhiAnDianCfg.SceneId
end

--是否有篝火
function behavior.IsHaveSoakPoint()
	return nil ~= next(Scene.Instance:GetSpecialObjExpFireList())
end

--是否需自动击杀怪物
function behavior.IsNeedAutoKillMonster()
	return GuajiCache.monster_id > 0
end

----行为
--泡点
function behavior.SoakPoint()
	local list = Scene.Instance:GetSpecialObjExpFireList()
	for i,v in ipairs(list) do
		for k2,v2 in pairs(v) do
			local x, y = v:GetLogicPos()
			GuajiCtrl.Instance:MoveToPos(Scene.Instance:GetSceneId(), x, y, 1)
			return
		end
	end
end

--击杀指定id怪物
function behavior.FindKillMonster(monster_id)
	local target_obj = get_target_obj()
	if nil ~= target_obj and target_obj.GetMonsterId and target_obj:GetMonsterId() ~= monster_id then
		GuajiCtrl.Instance:CancelSelect()
		target_obj = nil
	end

	target_obj = Scene.Instance:SelectMinDisMonster(monster_id, COMMON_CONSTS.SELECT_OBJ_DISTANCE)
	if nil ~= target_obj then
		GlobalEventSystem:Fire(ObjectEventType.BE_SELECT, target_obj, "select")
		GuajiCtrl.Instance:DoAttackTarget(target_obj)
	end
	
	return nil ~= target_obj
end

return behavior