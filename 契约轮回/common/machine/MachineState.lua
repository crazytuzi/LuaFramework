--
-- Author: LaoY
-- Date: 2018-06-30 15:48:59
--

MachineState = MachineState or class("MachineState")

function MachineState:ctor(state_name,groove)
	self.state_name = state_name
	self.groove = groove
	self.is_playing = false
end

function MachineState:dctor()
	self.is_playing = false
end

function MachineState:GetStateName()
	return self.state_name
end

--[[
	@param onEnter 	进入状态的回调
	@param Update 	更新状态
	@param OnExit 	离开状态的回调
]]
function MachineState:SetCallBack(onEnter,Update,OnExit)
	self.onEnter_callback = onEnter
	self.Update_callback = Update
	self.OnExit_callback = OnExit
end

function MachineState:onEnter()
	if self.is_playing then
		return
	end
	self.is_playing = true
	if self.onEnter_callback then
		self.onEnter_callback(self.state_name)
	end
end

function MachineState:Update(delta_time)
	if not self.is_playing then
		return
	end
	if self.Update_callback then
		self.Update_callback(self.state_name,delta_time)
	end
end

function MachineState:OnExit(last_state_name)
	if not self.is_playing then
		return
	end
	self.is_playing = false
	if self.OnExit_callback then
		self.OnExit_callback(self.state_name,last_state_name)
	end
end