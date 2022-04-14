--
-- @Author: LaoY
-- @Date:   2019-09-16 20:38:32
--
God = God or class("God",DependStaticObject)
function God:ctor()
	SetLocalPosition(self.model_parent,0,0,0)
	self:SetBodyPosition(0,120)
end

function God:ResetParent()
	local parent_transform = self.owner_object:GetBoneNode(SceneConstant.BoneNode.Root) or self.owner_object.transform
	self.parent_transform:SetParent(parent_transform)
end

function God:dctor()
	self:StopRemoveTime()
end

function God:InitMachine()
	self:RegisterMachineState(SceneConstant.ActionName.idle, true)

	local show_func_list = {
		CheckOutFunc = function() 
				return false 
			end,
	}
	self:RegisterMachineState(SceneConstant.ActionName.show1, false,show_func_list)
	self:RegisterMachineState(SceneConstant.ActionName.show2, false,show_func_list)
	
	-- local run_func_list = {
	-- 	OnEnter = handler(self, self.RunOnEnter),
	-- 	OnExit = handler(self, self.RunOnExit),
	-- 	Update = handler(self, self.UpdateRunState),
	-- }
	self:RegisterMachineState(SceneConstant.ActionName.run, true)
end

function God:AddEvent()
	local function call_back()
		self:ChangeBody()
	end
	self.owner_info_event_list[#self.owner_info_event_list+1] = self.owner_info:BindData("figure.god",call_back)
end

function God:ChangeBody()
	local abName
	local assetName

	local res_id = self.owner_info.figure.god and self.owner_info.figure.god.model
    local show = self.owner_info.figure.god and self.owner_info.figure.god.show
    if show then
    	-- local cf = Config.db_god_morph[res_id]
    	-- if cf then
	    --     abName = "model_soul_".. cf.res_id
	    --     assetName = "model_soul_" .. cf.res_id
	    -- end
	    abName = "model_soul_".. res_id
        assetName = "model_soul_" .. res_id
    end
	
	if abName then
		self:CreateBodyModel(abName,assetName)
	end
end

function God:LoadBodyCallBack()
	self:ChangeMachineState(SceneConstant.ActionName.show2)
	SetLocalPosition(self.transform, 0, 0, 0)
	SetLocalRotation(self.transform)

	self:StartRemoveTime()
end

function God:StartRemoveTime()
	self:StopRemoveTime()
	local function step()
		self:RemoveFormOwer()
	end
	self.time_remove_id = GlobalSchedule:StartOnce(step,SceneConstant.God.showTime)
end

function God:StopRemoveTime()
	if self.time_remove_id then
		GlobalSchedule:Stop(self.time_remove_id)
		self.time_remove_id = nil
	end
end

function God:RemoveFormOwer()
	self.owner_object:RemoveDependObject(self.object_type,self.depend_index)
end

function God:OwnerEnterState(state_name)
	-- if IsSameStateGroup(state_name,SceneConstant.ActionName.run) then
	-- 	self:ChangeMachineState(SceneConstant.ActionName.run)
	-- elseif IsSameStateGroup(state_name,SceneConstant.ActionName.attack) then
	-- 	self:ChangeMachineState(SceneConstant.ActionName.show1)
	-- else
	-- 	self:ChangeMachineState(SceneConstant.ActionName.idle)
	-- end

	if IsSameStateGroup(state_name,SceneConstant.ActionName.idle) then

	else
		self:RemoveFormOwer()
	end
end