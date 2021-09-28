DafuhaoSceneLogic = DafuhaoSceneLogic or BaseClass(BaseFbLogic)

function DafuhaoSceneLogic:__init()
	-- 监听系统事件
	self.guaji_change = GlobalEventSystem:Bind(OtherEventType.GUAJI_TYPE_CHANGE,
		BindTool.Bind(self.OnGuajiTypeChange, self))
end

function DafuhaoSceneLogic:__delete()
	if nil ~= self.guaji_change then
		GlobalEventSystem:UnBind(self.guaji_change)
		self.guaji_change = nil
	end
end

function DafuhaoSceneLogic:Enter(old_scene_type, new_scene_type)
	BaseFbLogic.Enter(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(false)
	ViewManager.Instance:Open(ViewName.DaFuHao)
	ViewManager.Instance:Open(ViewName.FbIconView)
end

function DafuhaoSceneLogic:Out(old_scene_type, new_scene_type)
	BaseFbLogic.Out(self, old_scene_type, new_scene_type)
	ViewManager.Instance:Close(ViewName.DaFuHao)
	ViewManager.Instance:Close(ViewName.FbIconView)
end

function DafuhaoSceneLogic:DelayOut(old_scene_type, new_scene_type)
	BaseFbLogic.DelayOut(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(true)
end

-- 拉取移动对象信息间隔
function DafuhaoSceneLogic:GetMoveObjAllInfoFrequency()
	return 5
end

-- 使用冰冻技能
function DafuhaoSceneLogic:UseBingDongSkill()
	-- 发送协议
	DaFuHaoCtrl.Instance:SendUseSkillReq(GuajiCache.target_obj_id)

	-- 播放动作
	local main_role = Scene.Instance:GetMainRole()
	if nil ~= main_role.draw_obj then
		local main_part = main_role.draw_obj:GetPart(SceneObjPart.Main)
		if nil ~= main_part then
			main_part:SetTrigger("attack16")
		end
	end
end

function DafuhaoSceneLogic:OnGuajiTypeChange(guaji_type)
	if nil ~= DaFuHaoAutoGatherEvent.func and guaji_type == GuajiType.Auto then
		DaFuHaoAutoGatherEvent.func()
	end
end

-- 拉取移动对象信息间隔
function DafuhaoSceneLogic:CanGetMoveObj()
	return true
end

function DafuhaoSceneLogic:IsRoleEnemy()
	return false
end