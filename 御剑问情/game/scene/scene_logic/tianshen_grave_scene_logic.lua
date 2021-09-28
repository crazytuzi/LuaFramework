TianShenGraveLogic = TianShenGraveLogic or BaseClass(CommonActivityLogic)

function TianShenGraveLogic:__init()
end

function TianShenGraveLogic:__delete()

end

function TianShenGraveLogic:Enter(old_scene_type, new_scene_type)
	self.is_change = false

	CommonActivityLogic.Enter(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(false)
	TianShenGraveCtrl.Instance:OpenInfoView()

	-- 正在采集的角色列表
	self.gather_role_list = {}
	self.other_stop_gather_event = GlobalEventSystem:Bind(ObjectEventType.OTHER_ROLE_STOP_GATHER,
		BindTool.Bind(self.OtherStopGather, self))
	self.other_start_gather_event = GlobalEventSystem:Bind(ObjectEventType.OTHER_ROLE_START_GATHER,
		BindTool.Bind(self.OtherStartGather, self))
	self.obj_del_event = GlobalEventSystem:Bind(ObjectEventType.OBJ_DELETE,
		BindTool.Bind(self.OnObjDelete, self))
end

function TianShenGraveLogic:Out(old_scene_type, new_scene_type)
	if self.other_stop_gather_event ~= nil then
		GlobalEventSystem:UnBind(self.other_stop_gather_event)
		self.other_stop_gather_event = nil
	end

	if self.other_start_gather_event ~= nil then
		GlobalEventSystem:UnBind(self.other_start_gather_event)
		self.other_start_gather_event = nil
	end

	if self.obj_del_event ~= nil then
		GlobalEventSystem:UnBind(self.obj_del_event)
		self.obj_del_event = nil
	end

	self.gather_role_list = {}

	CommonActivityLogic.Out(self, old_scene_type, new_scene_type)
	TianShenGraveCtrl.Instance:CloseInfoView()
	MainUICtrl.Instance:SetViewState(true)
end

function TianShenGraveLogic:IsCanAutoGather()
	return false
end

function TianShenGraveLogic:ChangeTitle()
	if self.is_change then
		return
	end
	local main_role = Scene.Instance:GetMainRole()
	local title_obj_list = main_role:GetFollowUi():GetTitleObj()
	for k, v in pairs(title_obj_list) do
		if v.gameObject.name == "Title_wudi_gather(Clone)" then
			local ani = v.animator
			ani:SetBool("twinkle", true)
			self.is_change = true
			break
		end
	end
end

function TianShenGraveLogic:IsRoleEnemy()
	return true
end

function TianShenGraveLogic:OnStartGather(role_obj_id, gather_obj_id)
	-- 当这个采集物已经有人采集时，强制中断采集动作
	for k,v in pairs(self.gather_role_list) do
		if v == gather_obj_id then
			local name = ""
			local role = Scene.Instance:GetRoleByObjId(k)
			if role then
				name = role:GetName()
			end
			SysMsgCtrl.Instance:ErrorRemind(string.format(Language.CrossCrystal.CantGather, name))
			Scene.SendStopGatherReq()
			break
		end
	end
end

function TianShenGraveLogic:OtherStopGather(role_obj_id)
	self.gather_role_list[role_obj_id] = nil
end

function TianShenGraveLogic:OtherStartGather(role_obj_id, gather_obj_id)
	self.gather_role_list[role_obj_id] = gather_obj_id
end

function TianShenGraveLogic:OnObjDelete(obj)
	if obj:IsRole() then
		self.gather_list[obj:GetObjId()] = nil
	end
end