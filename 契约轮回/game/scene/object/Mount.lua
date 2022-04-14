--
-- @Author: LaoY
-- @Date:   2019-12-10 15:20:05
--

--require("game.xx.xxx")
-- require("game/scene/object/Mount")
Mount = Mount or class("Mount",DependStaticObject)

function Mount:ctor()
end

function Mount:dctor()
	if self.alpha ~= 1 then
		self:SetHorseAlpha(1.0)
	end
end

function Mount:ResetParent()
	local parent_transform = self.owner_object.model_parent
	self.parent_transform:SetParent(parent_transform)
end

function Mount:InitMachine()
	self:RegisterMachineState(SceneConstant.ActionName.idle, true)
	self:RegisterMachineState(SceneConstant.ActionName.run1, true)
end

function Mount:AddEvent()
	local function call_back()
		self:ChangeBody()
	end
	self.owner_info_event_list[#self.owner_info_event_list+1] = self.owner_info:BindData("figure.mount",call_back)

	local function call_back()
        self:UpdateEscort()
    end
    self.owner_info_event_list[#self.owner_info_event_list + 1] = self.owner_info:BindData("buffs", call_back)
end

function Mount:UpdateEscort()
    local isEscort = self.owner_object:GetEscortMountID()
    isEscort = isEscort ~= nil and true or false
    self.last_escort_state = self.last_escort_state ~= nil and self.last_escort_state or false
    if self.last_escort_state ~= isEscort then
        self.last_escort_state = isEscort
        if isEscort then
           	self:ChangeBody()
        end
    end
end

function Mount:ChangeBody()
	if self.is_remove_action then
		return
	end
	local _id = self._id
	local is_dctored = self.is_dctored
	Yzprint('--LaoY Mount.lua,line 38--',_id,is_dctored)

	local escort_id = self.owner_object:GetEscortMountID()
	if (not self.owner_info.figure or not self.owner_info.figure.mount or self.owner_info.figure.mount.model == 0) and not escort_id then
		return
	end
	local res_id = self.owner_info.figure.mount and self.owner_info.figure.mount.model
	if escort_id then
		res_id = escort_id
	end
	if not res_id then
		return
	end
	local abName = "model_mount_" .. res_id
	local assetName = "model_mount_" .. res_id
	
	if abName then
		self:CreateBodyModel(abName,assetName)
	end
end

function Mount:LoadBodyCallBack()
	if self.owner_object.is_runing or self.owner_object.move_state then
		self:ChangeMachineState(SceneConstant.ActionName.run1)
	else
		self:ChangeMachineState(SceneConstant.ActionName.idle)
	end
	
	self.owner_object:SetMachineDefaultState(SceneConstant.ActionName.ride)

	if self.owner_object.cur_state_name == SceneConstant.ActionName.idle then
		self.owner_object:ChangeToMachineDefalutState()
	end

	local boneName = "ride"
	local horse_bone = GetComponentChildByName(self.transform, boneName)
	self.owner_object.transform:SetParent(horse_bone)
	SetLocalPosition(self.owner_object.transform, 0, 0, 0)
	SetLocalRotation(self.owner_object.transform)
	SetLocalScale(self.owner_object.transform,1.0)

	SetCacheState(self.gameObject,false)
	
	self:SetHorseAlpha(self.owner_object.alpha)

	local abName = self.last_abName
    local cf = Config.db_mount_high[abName]
    if cf and cf.high > 0 then
        self.owner_object.horse_bone_height = cf.high/SceneConstant.PixelsPerUnit
    else
        self.owner_object.horse_bone_height = GetGlobalPositionY(horse_bone) - self.owner_object.position.y / SceneConstant.PixelsPerUnit
        if abName:find("model_mount_10001") then
            self.owner_object.horse_bone_height = self.owner_object.horse_bone_height + 0.1
        end
    end
    self.owner_object:SetNameContainerPos()
end

function Mount:OwnerEnterState(state_name)
	local horse_state
	if state_name == SceneConstant.ActionName.ride then
		horse_state = SceneConstant.ActionName.idle
	elseif state_name == SceneConstant.ActionName.riderun then
		horse_state = SceneConstant.ActionName.run1
	end
	if horse_state then
		self:ChangeMachineState(horse_state)
	end
end

function Mount:Remove()
	if self.is_dctored or self.is_remove_action then
		return
	end
	local _id = self._id
	local is_dctored = self.is_dctored
	
	Yzprint('--LaoY Mount.lua,line 105--',_id,is_dctored)

	if self.owner_object and self.owner_object.transform then
		self.owner_object.transform:SetParent(self.owner_object.model_parent)
		SetLocalPosition(self.owner_object.transform, 0, 0, 0)
		SetLocalRotation(self.owner_object.transform)
		SetLocalScale(self.owner_object.transform,1.0)
	end

	self:RemoveAction()
end

function Mount:RemoveAction()
	if not self.transform then
		self:destroy()
		return
	end
	local scene_obj_layer = LayerManager:GetInstance():GetLayerByName(LayerManager.LayerNameList.SceneObj)
    self.transform:SetParent(scene_obj_layer)

	self:SetHorseAlpha(0.99,nil,ShaderManager:GetInstance():GetShaderByName(ShaderManager.ShaderNameList.Alpha_shader))

    local delay_time = 0.1
    local action = cc.DelayTime(delay_time)
    local function call_back()
        if self.animator then
            self.animator:CrossFade(SceneConstant.ActionName.run1, 0)
        end
    end
    local call_action = cc.CallFunc(call_back)
    action = cc.Sequence(action, call_action)

    local start_pos = self.owner_object.position
    local vec = Vector2(self.owner_object.direction.x, self.owner_object.direction.y)
    vec:Mul(400)
    local end_pos = Vector3(start_pos.x + vec.x, start_pos.y + vec.y, start_pos.z)
    end_pos:Mul(1 / SceneConstant.PixelsPerUnit)

    local move_time = 1.0 - delay_time
    local move_action = cc.MoveTo(move_time, end_pos.x, end_pos.y, end_pos.z)
    local fadeout_action = cc.FadeOut(move_time, self.default_mat)
    local moveAction = cc.Spawn(fadeout_action, move_action)
    action = cc.Sequence(action, moveAction)
    local function call_back()
    	cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.transform)
    	self:destroy()
    end
    local call_action = cc.CallFunc(call_back)
    action = cc.Sequence(action, call_action)

    cc.ActionManager:GetInstance():addAction(action, self.transform)

    self.is_remove_action = true
end

function Mount:SetAlpha()
end

function Mount:SetHorseAlpha(a,gameObject,shader)
    if not self.default_mat then
        return
    end
    if self.alpha == a then
    	return
    end
    self.alpha = a
	
	local sd = shader or ShaderManager:GetInstance():FindShaderByName("Custom/Outline2")
    if a < 1 then
        if not self.material_shader_list[self.default_mat] then
            self.material_shader_list[self.default_mat] = self.default_mat.shader
        end
    else
        sd = self.material_shader_list[self.default_mat]
    end
    if sd then
        self.default_mat.shader = sd
        -- 重新设置shader,color值居然不确定，不是shader默认值,重新设置
        SetColor(self.default_mat, 255, 255, 255, 255)
    end
    SetAlpha(self.default_mat, a)
end