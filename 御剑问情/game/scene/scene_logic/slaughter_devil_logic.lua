SlaughterDevilLogic = SlaughterDevilLogic or BaseClass(BaseFbLogic)

function SlaughterDevilLogic:__init()
	-- self.event_handle = BindTool.Bind(self.OnDoorCreate, self)
end

function SlaughterDevilLogic:__delete()

end

function SlaughterDevilLogic:Enter(old_scene_type, new_scene_type)
	BaseFbLogic.Enter(self, old_scene_type, new_scene_type)
	-- if ViewManager.Instance:IsOpen(ViewName.) then
	-- 	ViewManager.Instance:Close(ViewName.FuBen)
	-- 	FuBenCtrl.Instance:CloseView()
	-- end
	ViewManager.Instance:CloseAll()
	ViewManager.Instance:Open(ViewName.SlagughterDevilInfoView)
	MainUICtrl.Instance:SetViewState(false)

	-- self.obj_create_event = GlobalEventSystem:Bind(ObjectEventType.OBJ_CREATE,
	-- 	self.event_handle)
end

-- 是否可以拉取移动对象信息
function SlaughterDevilLogic:CanGetMoveObj()
	return true
end

-- 是否可以屏蔽怪物
function SlaughterDevilLogic:CanShieldMonster()
	return false
end

-- 是否自动设置挂机
function SlaughterDevilLogic:IsSetAutoGuaji()
	return true
end

function SlaughterDevilLogic:Out(old_scene_type, new_scene_type)
	BaseFbLogic.Out(self, old_scene_type, new_scene_type)
	ViewManager.Instance:Close(ViewName.SlagughterDevilInfoView)
	if ViewManager.Instance:IsOpen(ViewName.FBFinishStarView) then
		ViewManager.Instance:Close(ViewName.FBFinishStarView)
	end

	if ViewManager.Instance:IsOpen(ViewName.FBFailFinishView) then
		GlobalEventSystem:Fire(OtherEventType.CLOSE_FUBEN_FAIL_VIEW)
	else
	end
	GuajiCtrl.Instance:StopGuaji()
	-- if self.obj_create_event ~= nil then
	-- 	GlobalEventSystem:UnBind(self.obj_create_event)
	-- 	self.obj_create_event = nil
	-- end
	if SlaughterDevilData.Instance:GetInfo() then
		ViewManager.Instance:Open(ViewName.LianhunView, TabIndex.fb_slaughter_devil)
	end
	FuBenData.Instance:ClearFBSceneLogicInfo()
end

function SlaughterDevilLogic:DelayOut(old_scene_type, new_scene_type)
	BaseFbLogic.DelayOut(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(true)
end

-- function SlaughterDevilLogic:OnDoorCreate(obj)
-- 	if SceneObjType.Door ~= obj:GetType() then
-- 		return
-- 	end

-- 	GlobalTimerQuest:CancelQuest(self.delay_set_attached)
-- 	self.delay_set_attached = GlobalTimerQuest:AddDelayTimer(function ()
-- 		for k, v in pairs(Scene.Instance:GetObjListByType(SceneObjType.Door)) do
-- 			local door_x, door_y = v:GetLogicPos()
-- 			local scene_id = Scene.Instance:GetSceneId()

-- 			GuajiCtrl.Instance:MoveToPos(scene_id, door_x, door_y)
-- 			break
-- 		end
-- 	end, 3.5)
-- end
