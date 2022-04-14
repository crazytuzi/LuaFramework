--机甲（机甲竞速活动用）
MachineArmor = MachineArmor or class("MachineArmor", SceneObject)

function MachineArmor:ctor()
	self.default_res = self._default_res

	self.object_type = enum.ACTOR_TYPE.ACTOR_TYPE_ROBOT
    self:InitMachine()
	self:ChangeBody()
	
	self.loaded_call_back = nil

	
	
end

function MachineArmor:dctor()
	
end 

function MachineArmor:AddEvent()

end

--切换身体
function MachineArmor:ChangeBody()

	local abName = "model_mech_10002"
	local assetName = "model_mech_10002"

	self:CreateBodyModel(abName,assetName)

end

--加载身体完毕后回调
function MachineArmor:LoadBodyCallBack()
	--面向右侧
	self:SetRotateY(90)

	--设置缩放
	self:SetScale(RaceConfig.MachineArmorSize)

	if self.loaded_call_back then
	   self.loaded_call_back()
	   self.loaded_call_back = nil
	end
end

--初始化状态机
function MachineArmor:InitMachine()
    self:RegisterMachineState(SceneConstant.ActionName.idle,true)
    self:RegisterMachineState(SceneConstant.ActionName.run,true)
    self:RegisterMachineState(SceneConstant.ActionName.Fly,true)
end

--设置名字颜色
function MachineArmor:SetNameColor()
	self.name_container:SetColor(Color.green,Color.black)
end

--设置名称容器位置
function MachineArmor:SetNameContainerPos()

	if self.name_container then
		
		local name_pos_offset_x = 0.2
	    local name_pos_offset_y = -0.4
		if RaceModel.GetInstance().robot_1_uid == self.object_id then
			name_pos_offset_y = -0.9
		end

		local world_pos = { x = self.position.x / SceneConstant.PixelsPerUnit, y = self.position.y / SceneConstant.PixelsPerUnit }
		local body_height = self:GetBodyHeight()  / SceneConstant.PixelsPerUnit -- + (self.body_pos.y <= 0 and 0 or self.body_pos.y + 30)
		self.name_container:SetGlobalPosition(world_pos.x + name_pos_offset_x, world_pos.y + body_height + name_pos_offset_y, self.position.z * 1.1)
	end
end

