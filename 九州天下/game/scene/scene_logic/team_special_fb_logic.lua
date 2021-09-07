TeamSpecialFbLogic = TeamSpecialFbLogic or BaseClass(BaseFbLogic)

function TeamSpecialFbLogic:__init()
	self.event_handle = BindTool.Bind(self.OnDoorCreate, self)
	self.is_insert_nostop_guaji_scene_id = false
	self.first_nostop_scene_id = 2800 --须弥幻境第一个场景id
	self.last_nostop_scene_id = 2849 --须弥幻境最后一个场景id
end

function TeamSpecialFbLogic:__delete()
	self.is_insert_nostop_guaji_scene_id = false
end

function TeamSpecialFbLogic:Enter(old_scene_type, new_scene_type)
	self.obj_create_event = GlobalEventSystem:Bind(ObjectEventType.OBJ_CREATE, self.event_handle)

	BaseFbLogic.Enter(self, old_scene_type, new_scene_type)
	ViewManager.Instance:Open(ViewName.FuBenTeamSpecialInfoView)
	MainUICtrl.Instance:SetViewState(false)
	ViewManager.Instance:Close(ViewName.TipsEnterFbView)
	GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
	FuBenCtrl.Instance:CloseView()

	if ViewManager.Instance:IsOpen(ViewName.FBVictoryFinishView) then
		ViewManager.Instance:Close(ViewName.FBVictoryFinishView)
	end
	
end

function TeamSpecialFbLogic:Out(old_scene_type, new_scene_type)
	GlobalTimerQuest:CancelQuest(self.delay_move)
	 if self.obj_create_event ~= nil then
		GlobalEventSystem:UnBind(self.obj_create_event)
		self.obj_create_event = nil
	end

	BaseFbLogic.Out(self, old_scene_type, new_scene_type)
	ViewManager.Instance:Close(ViewName.FuBenTeamSpecialInfoView)
	if ViewManager.Instance:IsOpen(ViewName.FBFailFinishView) then
		GlobalEventSystem:Fire(OtherEventType.CLOSE_FUBEN_FAIL_VIEW)
	end
	
	MainUICtrl.Instance:SetViewState(true)
	GuajiCtrl.Instance:StopGuaji()
	FuBenData.Instance:ClearFBSceneLogicInfo()
  	Scene.Instance:DeleteObjsByType(SceneObjType.Door)
end


-- 是否可以拉取移动对象信息
function TeamSpecialFbLogic:CanGetMoveObj()
	return true
end

-- 拉取移动对象信息间隔
function TeamSpecialFbLogic:GetMoveObjAllInfoFrequency()
	return 3
end

-- 角色是否是敌人
function TeamSpecialFbLogic:IsRoleEnemy(target_obj, main_role)
	return false
end

-- 是否可以屏蔽怪物
function TeamSpecialFbLogic:CanShieldMonster()
	return false
end

-- 是否自动设置挂机
function TeamSpecialFbLogic:IsSetAutoGuaji()
	return true
end


function TeamSpecialFbLogic:DelayOut(old_scene_type, new_scene_type)
	BaseFbLogic.DelayOut(self, old_scene_type, new_scene_type)
end

function TeamSpecialFbLogic:GetPickItemMaxDic(item_id)
	return 0
end

function TeamSpecialFbLogic:IsRoleEnemy()
	return false
end

function TeamSpecialFbLogic:OnDoorCreate(obj)
	local scene_door = FuBenData.Instance:GetNextSceneDoor()
	if nil == scene_door or SceneObjType.Door ~= obj:GetType() then
		return
	end

	GlobalTimerQuest:CancelQuest(self.delay_move)
	self.delay_move = GlobalTimerQuest:AddDelayTimer(function () 
		local scene_id = Scene.Instance:GetSceneId()
		GuajiCtrl.Instance:MoveToPos(scene_id, scene_door.x, scene_door.y)
	end, 6)
end

function TeamSpecialFbLogic:GetGuajiPos()
	local scene_id = Scene.Instance:GetSceneId()
	local scene_config = ConfigManager.Instance:GetSceneConfig(scene_id) or {}
	local scene_doors = {}
	for k,v in pairs(scene_config.doors) do
		if v.id == scene_id + 1 then
			scene_doors = v
			break
		end
		scene_doors = v
	end
	local door_x = scene_doors.x
	local door_y = scene_doors.y
	local main_role = Scene.Instance:GetMainRole()
	local logic_x, logic_y = main_role:GetLogicPos()
	local normal = u3d.v2Normalize(Vector2(door_x - logic_x, door_y - logic_y))
	local distance = u3d.v2Length(Vector2(door_x - logic_x, door_y - logic_y), true)
	--最后一关
	if self.last_nostop_scene_id == scene_id then
		return scene_config.monsters[1].x ,scene_config.monsters[1].y
	end
	return door_x + normal.x * (distance + 1), door_y + normal.y * (distance + 1)
end
