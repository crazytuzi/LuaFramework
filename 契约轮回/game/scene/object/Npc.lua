-- 
-- @Author: LaoY
-- @Date:   2018-08-10 17:57:51
--

Npc = Npc or class("Npc",SceneObject)

function Npc:ctor()
	self.default_res = self._default_res

	self.object_type = enum.ACTOR_TYPE.ACTOR_TYPE_NPC
	self.body_size = {width = 90,height = 160}
	self:ChangeBody()
	self:InitMachine()
	self.idle_action_time = 0

	self:ChangeTaskState()
end

function Npc:dctor()
	if self.task_state_icon then
		if not poolMgr:AddGameObject("system","EmptyImage",self.task_state_icon) then
            destroy(self.task_state_icon)
        end
        self.task_state_icon = nil
    end

	if self.global_event_list then
		TaskModel:GetInstance():RemoveTabListener(self.global_event_list)
		self.global_event_list = {}
	end
end 

-- 需要影子派生类的重写
function Npc:CreateShadowImage()
    self.shadow_image = ShadowImage()
end

function Npc:AddEvent()
	local function call_back()
		self:ChangeTaskState()
	end
	self.global_event_list = self.global_event_list or {}
	self.global_event_list[#self.global_event_list+1] = TaskModel:GetInstance():AddListener(TaskEvent.AccTaskList, call_back)
	self.global_event_list[#self.global_event_list+1] = TaskModel:GetInstance():AddListener(TaskEvent.AccTaskUpdate, call_back)
end

function Npc:ChangeBody()
	local config = Config.db_npc[self.object_id]
	self.config = config
	local res_id = config and config.figure or "model_Npc_3010100"
	-- res_id = 10001
	local abName = res_id
	local assetName = res_id
	poolMgr:AddConfig(abName,assetName,1,Constant.InPoolTime * 0.5,true)

	local fly_pos = SceneConfigManager:GetInstance():GetNPCFlyPos(self.object_id)
	if fly_pos and Vector2.DistanceNotSqrt(fly_pos,self.position) >= SceneConstant.NPCRange * SceneConstant.NPCRange then
		logError("飞鞋落地点超出对话范围，NPC ID 是：",self.object_id,",名字是：",self.config.name)
	end

	self:CreateBodyModel(abName,assetName)
	-- if self:CreateBodyModel(abName, assetName) and self.default_res then
	-- 	SetVisible(self.default_res,true)
	-- end
end

function Npc:ChangeTaskState()
	local state = TaskModel:GetInstance():GetNpcState(self.object_id)
	if not state then
		self.last_task_state = nil
		if self.task_state_icon then
			if not poolMgr:AddGameObject("system","EmptyImage",self.task_state_icon) then
	            destroy(self.task_state_icon)
	        end
	        self.task_state_icon = nil
	    end
	else
		if not self.task_state_icon then
			self.task_state_icon = PreloadManager:GetInstance():CreateWidget("system","EmptyImage")
			self.task_state_icon_transform = self.task_state_icon.transform
			local scene_obj_layer = LayerManager:GetInstance():GetLayerByName(LayerManager.LayerNameList.SceneObj)
			self.task_state_icon_transform:SetParent(scene_obj_layer)
			SetLocalScale(self.task_state_icon_transform,0.01,0.01,0.01)
			self.task_state_icon_img = self.task_state_icon:GetComponent('Image')
			self:SetNameContainerPos()
		end

		if self.last_task_state == state then
			return
		end
		self.last_task_state  = state
		local abName = "scene_image"
		local assetName = string.format("img_task_state_%s",state)
		lua_resMgr:SetImageTexture(self,self.task_state_icon_img,abName,assetName,false)
	end
end

function Npc:SetNameContainerPos()
	Npc.super.SetNameContainerPos(self)
	if self.task_state_icon_transform then
		local world_pos = {x = self.position.x/SceneConstant.PixelsPerUnit,y = self.position.y/SceneConstant.PixelsPerUnit}
		local body_height = self:GetBodyHeight() + (self.body_pos.y <= 0 and 0 or self.body_pos.y + 30) + 60
		SetGlobalPosition(self.task_state_icon_transform, world_pos.x,world_pos.y + body_height/SceneConstant.PixelsPerUnit,self.position.z*1.1)
	end
end

function Npc:LoadBodyCallBack()

	-- if self.default_res then
	-- 	SetVisible(self.default_res,false)
	-- end

	local config = self.config
	if config then
		self.parent_node.name = config.name
		self.name_container:SetName(config.name)
		self:SetRotateY(config.angle)
		if self.config.scale ~= 1 then
			self.body_size.width = self.body_size.width * self.config.scale
			self.body_size.height = self.body_size.height * self.config.scale
			self.body_size.length = self.body_size.length * self.config.scale
			self:SetScale(self.config.scale)
			self:SetPosition(self.position.x,self.position.y)
		end
	end
end

function Npc:InitMachine()
	self:RegisterMachineState(SceneConstant.ActionName.idle,true)
	self:RegisterMachineState(SceneConstant.ActionName.casual,false)

	self:RegisterMachineState(SceneConstant.ActionName.show,false)
	self:RegisterMachineState(SceneConstant.ActionName.show2,false)
end

function Npc:SetNameColor()
	self.name_container:SetColor(Color.green,Color.black)
end

function Npc:GetShowActionName()
	local t = {SceneConstant.ActionName.show,SceneConstant.ActionName.show2}
	return t[math.random(#t)]
end

function Npc:LoopActionOnceEnd()
	if self.cur_state_name == SceneConstant.ActionName.idle then
		local action = self.action_list[self.cur_state_name]
		if action.total_time  >= 8 then
			local action_name = self:GetShowActionName()
			self:ChangeMachineState(action_name)
		end
	end
end

function Npc:DeathOnExit()
	Npc.super.DeathOnExit(self)
	self:destroy()
end

function Npc:OnClick()
	local main_role = SceneManager:GetInstance():GetMainRole()
	local main_pos = main_role:GetPosition()
	local distance = Vector2.DistanceNotSqrt(main_pos,self.position)
	local range_square = SceneConstant.NPCRange * SceneConstant.NPCRange
	if distance <= range_square then
		self:FaceToObject()
		self:ShowTalk()
	else
		local function call_back()
			self:OnClick()
		end
		-- local move_dis = math.max(math.sqrt(distance) - SceneConstant.NPCRange + 2,0)
		-- local end_pos = GetDirDistancePostion(main_pos,self.position,move_dis)
		local fly_pos = SceneConfigManager:GetInstance():GetNPCFlyPos(self.object_id)
		OperationManager:GetInstance():TryMoveToPosition(nil,main_pos,self.position,call_back,SceneConstant.NPCRange,nil,nil,nil,fly_pos)
		-- local scene_id = SceneManager:GetInstance():GetSceneId()
		-- SceneControler:GetInstance():UseFlyShoeToPos(scene_id,fly_pos.x,fly_pos.y,true,call_back)
	end
	SceneManager:GetInstance():LockNpc(self.object_id)
	return true
end

function Npc:OnMainRoleStop()
	self:FaceToObject()
	self:ShowTalk()
end

function Npc:ShowTalk()
	if MagictowerTreasureModel:GetInstance():IsMttNpc(self.object_id) then
		MagictowerTreasureModel:GetInstance():ClickNpc(self.object_id)
		return
	end
	local config = Config.db_npc[self.object_id]
	if not config then
		return
	end
	local function btn_func()
		if self.is_dctored then
			return
		end
		self:SetRotateY(config.angle)
	end
	--检查是否有任务戏份
	if TaskModel:GetInstance():OnTask(self.object_id,btn_func) then
		return
	end
	if FactionEscortModel:GetInstance():IsEscortNpc(self.object_id)  then -- 是否是工会护送任务Npc
		return
	end

	if MarryModel:GetInstance():IsMarryNpc(self.object_id) then --是否是结婚Npc
		return
	end

	-- Dialog.ShowOne(config.name,config.dialog,"确定",btn_func,10)

	lua_panelMgr:OpenPanel(TaskTalkNovicePanel,nil,nil,config.dialog,nil,self.object_id)
end

function Npc:FaceToObject(object)
	object = object or SceneManager:GetInstance():GetMainRole()
	local angle = GetSceneAngle(self.position,object:GetPosition())
	self:SetRotateY(angle)

	-- 互相看
	angle = GetSceneAngle(object:GetPosition(),self.position)
	object:SetRotateY(angle)
end

function Npc:Update(delta_time)
	Npc.super.Update(self,delta_time)
end

function Npc:SetPosition(x,y)
	Npc.super.SetPosition(self,x,y)
end

function Npc:CheckNextBlock()
	return true
end

function Npc:BeLock(flag)
    Npc.super.BeLock(self, flag);
end