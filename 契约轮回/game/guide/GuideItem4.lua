--
-- @Author: LaoY
-- @Date:   2019-05-16 22:14:08
--
GuideItem4 = GuideItem4 or class("GuideItem4",BaseItem)

GuideItem4.ShowTime = 15
GuideItem4.SpecialShowTime = 10
GuideItem4.AutoMaintaskTip = 30
GuideItem4.AutoDailyTaskTip = 25
GuideItem4.AutoActiveTaskTip = 20

GuideItem4.VisibleState = {
	Scroll = BitState.State[1],
	Action = BitState.State[2],
	Guide  = BitState.State[3],
}

function GuideItem4:ctor(parent_node,layer)
	self.abName = "guide"
	self.assetName = "GuideItem4"
	self.layer = layer

	self.last_check_pos = {x = -1,y = -1}
	UpdateBeat:Add(self.Update,self,2,2)

	self.visible_state = BitState()

	GuideItem4.super.Load(self)
end

function GuideItem4:dctor()
	UpdateBeat:Remove(self.Update)

	if self.destroy_call_back then
		self.destroy_call_back()
	end
	self.destroy_call_back = nil
	self.follow_object = nil
end

function GuideItem4:LoadCallBack()
	self.nodes = {
		"con","img_bg/text","img_bg",
	}
	self:GetChildren(self.nodes)

	self.text_component = self.text:GetComponent('Text')

	SetChildLayer(self.transform,LayerManager.BuiltinLayer.UI)

	if self.is_need_setdata then
		self:SetData(self.data)
	end
	self:StartAction()

	self:AddEvent()
	self:Update()
	-- step()
	-- Yzprint('--LaoY GuideItem4.lua,line 54--',self.follow_object,self.follow_object and  self.follow_object.transform)
end

function GuideItem4:AddEvent()
end

function GuideItem4:SetCallBack(update_call_back,destroy_call_back)
	self.update_call_back = update_call_back
	self.destroy_call_back = destroy_call_back
end

function GuideItem4:SetFollowObject(object,offset_x,offset_y)
	if self.follow_object and self.follow_object == object then
		self:StopAction()
		self:StartAction()
	end
	self.last_check_pos.x = 0
	self.last_check_pos.y = 0

	self.follow_object = object
	self.offset_x = offset_x or 0
	self.offset_x = self.offset_x * 0.01

	self.offset_y = offset_y or 0
	self.offset_y = self.offset_y * 0.01
end

function GuideItem4:SetData(data)
	self.data = data
	local task_id = self.data.task_id
	local info = TaskModel:GetInstance():GetTask(task_id)
	if info then
		self.task_type = info.task_type
	end
	self.end_time = data.end_time
	if self.is_loaded then
		self.is_need_setdata = false
		self:SetText(data.text)
		SetVisible(self.img_bg,data.text ~= "")
	else
		self.is_need_setdata = true
	end
end

function GuideItem4:SetText(text)
	self.text_component.text = text
	local preferredHeight = self.text_component.preferredHeight
	SetSizeDeltaY(self.img_bg,preferredHeight + 40)
end

function GuideItem4:StartAction()
	if not self.is_loaded then
		return
	end

	AutoTaskManager:GetInstance():SetLastOperateTaskTime()

	self:StopAction()
	local isTaskconfigGuide = not TaskModel:GetInstance():IsSpecialGuide(self.data.task_id)

	local time = 0.3
	local all_time = isTaskconfigGuide and GuideItem4.ShowTime or GuideItem4.SpecialShowTime
	if self.end_time and (isTaskconfigGuide or self.task_type ~= enum.TASK_TYPE.TASK_TYPE_SIDE) and self.end_time > Time.time  then
		all_time = self.end_time - Time.time
	end
	local offset = 10
	local move_action = cc.MoveTo(time/2, offset, 0, 0)
	local m_l_action = cc.MoveTo(time, -offset, 0, 0)
	local m_r_action = cc.MoveTo(time, offset, 0, 0)

	m_l_action = cc.EaseIn(m_l_action, 2)
	m_r_action = cc.EaseOut(m_r_action, 2)
	local action = cc.Repeat(cc.Sequence(m_l_action,m_r_action), math.floor(all_time/time/2))
	action = cc.Sequence(move_action,action)

	if not isTaskconfigGuide and self.task_type == enum.TASK_TYPE.TASK_TYPE_SIDE then
	    action = cc.Sequence(action,cc.CallFunc(function()
			self:SetVisibleState(GuideItem4.VisibleState.Action,true)			
		end),cc.DelayTime(10),cc.CallFunc(function()
			self:SetVisibleState(GuideItem4.VisibleState.Action,false)			
			AutoTaskManager:GetInstance():SetLastOperateTaskTime()
		end))
		action = cc.RepeatForever(action)
	else
		local function call_back()
	    	self:destroy()
	    	-- AutoTaskManager:GetInstance():SetLastOperateTaskTime()
	    	if isTaskconfigGuide then
	    		TaskModel:GetInstance():Brocast(TaskEvent.UpdateGuild)
	    	end
	    end
	    action = cc.Sequence(action,cc.CallFunc(call_back))
	end

    cc.ActionManager:GetInstance():addAction(action, self.con)
end

function GuideItem4:StopAction()
	cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.con)
end

function GuideItem4:Update()
	AutoTaskManager:GetInstance():SetLastOperateTaskTime()
	
	local cur_guide_state = GuideModel:GetInstance():HasGuide()
	-- if cur_guide_state then
	-- 	self:SetVisible(false)
	-- 	self.last_check_pos.x = -1
	-- 	self.last_check_pos.y = -1
	-- end
	local is_force = self.last_guide_state ~= nil and self.last_guide_state ~= cur_guide_state
	if self.last_guide_state ~= cur_guide_state then
		self:SetVisibleState(GuideItem4.VisibleState.Guide,cur_guide_state)
		self.last_check_pos.x = -1
		self.last_check_pos.y = -1
	end
	self.last_guide_state = cur_guide_state
	if cur_guide_state and self.last_check_pos.x ~=-1 and self.last_check_pos.y ~= -1 then
		return
	end
	if not self.follow_object or not self.follow_object.transform then
		return
	end
	if not self.is_loaded then
		return
	end
	local x,y,z = GetGlobalPosition(self.follow_object.transform)
	if Vector2.DistanceNotSqrt(self.last_check_pos,{x = x,y = y}) < 1e-05 and not is_force then
		return
	end
	self.last_check_pos.x = x
	self.last_check_pos.y = y

	local x,y = GetLocalPosition(self.follow_object.transform)
	SetGlobalPosition(self.transform,self.last_check_pos.x + self.offset_x,self.last_check_pos.y + self.offset_y,0)

	if self.update_call_back then
		self.update_call_back()
	end
end

function GuideItem4:SetVisibleState(state,is_add)
	if is_add then
		self.visible_state:Add(state)
	else
		self.visible_state:Remove(state)
	end
	local bo = not self.visible_state:Contain()
	self:SetVisible(bo)
end

function GuideItem4:SetVisible(flag)
	if self.isVisible == flag then
		return
	end
	GuideItem4.super.SetVisible(self,flag)
end