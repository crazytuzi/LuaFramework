--
-- @Author: LaoY
-- @Date:   2019-01-28 20:00:21
--
PowerChangeText = PowerChangeText or class("PowerChangeText",BaseCloneItem)
PowerChangeText.__cache_count = 6

function PowerChangeText:ctor(obj,parent_node,layer)
	PowerChangeText.super.Load(self)
end

function PowerChangeText:dctor()
	self:StopAction()
end

function PowerChangeText:__clear()
	PowerChangeText.super.__clear(self)
	self:StopAction()
end

function PowerChangeText:__reset(...)
	PowerChangeText.super.__reset(self,...)
	SetAlpha(self.text,1)
end

function PowerChangeText:LoadCallBack()
	-- self.nodes = {
	-- 	"text",
	-- }
	-- self:GetChildren(self.nodes)

	self.text = self.transform:GetComponent('Text')
	self:AddEvent()
end

function PowerChangeText:AddEvent()
end

function PowerChangeText:SetData(index,data)
	self.index = index
	self.text.text = "+" ..data.key .. data.value
end

function PowerChangeText:StartAction(time,x,y)
	local action = cc.MoveTo(time,x,y,0)
	action = cc.Sequence(action,cc.DelayTime(1.0))
	local action_time = 0.2
	local move_action = cc.Spawn(cc.MoveTo(action_time,x + 200,y,0),cc.FadeOut(action_time,self.text))
	move_action = cc.EaseIn(move_action,4)
	action = cc.Sequence(action,move_action)
	local function end_func()
		self:destroy()
	end
	action = cc.Sequence(action,cc.CallFunc(end_func))
	self.action = action
	cc.ActionManager:GetInstance():addAction(action,self.transform)
end

function PowerChangeText:IsDone()
	if not self.action then
		return false
	end
	return self.action:isDone()
end

function PowerChangeText:StopAction()
	cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.transform)
end