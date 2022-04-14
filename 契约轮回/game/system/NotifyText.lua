-- -- 
-- -- @Author: LaoY
-- -- @Date:   2018-07-13 20:37:31
-- -- 
-- NotifyText = NotifyText or class("NotifyText",BaseWidget)
-- local NotifyText = NotifyText
-- NotifyText.__cache_count = 14

-- NotifyText.MaxCount = NotifyText.__cache_count - 1
-- NotifyText.FlyHeight = 100
-- NotifyText.OffHeight = 35
-- NotifyText.FlyTime 	 = 0.15
-- NotifyText.DeltaTime = 2.0
-- NotifyText.FlySpeed = NotifyText.FlyTime/NotifyText.FlyHeight

-- function NotifyText:ctor(parent_node,builtin_layer)
-- 	self.abName = "system"
-- 	self.assetName = "NotifyText"
-- 	NotifyText.super.Load(self)
-- end

-- function NotifyText:dctor()
-- 	self:SetVisible(false)
-- 	self:StopAction()
-- 	SystemTipManager:GetInstance():RemoveTextNotify(self)
-- end

-- function NotifyText:LoadCallBack()
-- 	self.nodes = {
-- 		"img_bg","Text"
-- 	}
-- 	self:GetChildren(self.nodes)

-- 	self.canvasGroup = GetCanvasGroup(self)
-- 	self.show_text = self.Text:GetComponent('Text')
-- 	self.img_component = self.img_bg:GetComponent('Image')

-- 	self:AddEvent()
-- 	self.start_x,self.start_y,self.start_z = self:GetPosition()
-- 	if self.is_need_SetText then
-- 		self:SetText()
-- 	end
-- end

-- function NotifyText:AddEvent()
-- end

-- function NotifyText:__reset()
-- 	NotifyText.super.__reset(self)
-- 	self:SetPosition(self.start_x,self.start_y,self.start_z)
-- 	SetAlpha(self.show_text,1)
-- 	SetAlpha(self.img_component,1)
-- end

-- function NotifyText:__clear()
-- 	Yzprint('--LaoY NotifyText.lua,line 53-- data=',data)
-- 	self:StopAction()
-- 	SystemTipManager:GetInstance():RemoveTextNotify(self)
-- 	NotifyText.super.__clear(self)
-- end

-- function NotifyText:SetData(str)
-- 	self.str = str
-- 	self:SetText()
-- end

-- function NotifyText:SetText()
-- 	if self.is_loaded then
-- 		self.is_need_SetText = false
-- 		self.show_text.text = self.str or ""
-- 		-- self.show_text.text = tostring(self.index)
-- 		local width = self.show_text.preferredWidth + 120
-- 		width = width < 90 and 90 or width
-- 		SetSizeDeltaX(self.img_bg,width)
-- 	else
-- 		self.is_need_SetText = true
-- 	end
-- end

-- function NotifyText:GetFlyHeight()
-- 	local _,y = self:GetPosition()
-- 	return y - self.start_y
-- end

-- function NotifyText:GetDelayTime()
-- 	local height = self:GetFlyHeight() - NotifyText.OffHeight
-- 	height = height <= 0 and 0 or height
-- 	return height * NotifyText.FlySpeed
-- end

-- function NotifyText:StartAction(index,delta_time,show_index)
-- 	index = index or 1
-- 	delta_time = delta_time or 0
-- 	show_index = show_index or 0
-- 	self:SetSiblingIndex(index)
-- 	self:StopAction()

-- 	local speed = NotifyText.FlySpeed
-- 	local _,y = self:GetPosition()
-- 	local action
-- 	if y <= self.start_y +NotifyText.FlyHeight then
-- 		local time = (self.start_y +NotifyText.FlyHeight - y) * speed
-- 		local moveAction = cc.MoveTo(time,self.start_x,self.start_y+NotifyText.FlyHeight,self.start_z)
-- 		action = self:ComboAction(action,moveAction)
-- 	end
-- 	if delta_time > 0 then
-- 		local delayaction = cc.DelayTime(delta_time)
-- 		action = self:ComboAction(action,delayaction)
-- 	end
-- 	if index > 1 then
-- 		local off_y = (index - 1) * NotifyText.OffHeight
-- 		local target_y = self.start_y+NotifyText.FlyHeight+off_y
-- 		local time = (target_y - y) * speed
-- 		local moveAction = cc.MoveTo(time,self.start_x,target_y,self.start_z)
-- 		action = self:ComboAction(action,moveAction)
-- 	end
-- 	local delayaction = cc.DelayTime(NotifyText.DeltaTime + show_index * 0.1)
-- 	action = self:ComboAction(action,delayaction)
	
-- 	local function on_callback()
-- 		SystemTipManager:GetInstance():RemoveTextNotify(self)
-- 	end
-- 	local call_action = cc.CallFunc(on_callback)
-- 	action = self:ComboAction(action,call_action)

-- 	local fadeout_action = cc.Spawn(cc.FadeOut(0.1,self.show_text),cc.FadeOut(0.1,self.img_component))
-- 	action = self:ComboAction(action,fadeout_action)
-- 	local function on_end_callback()
-- 		self:destroy()
-- 	end
-- 	local end_action = cc.CallFunc(on_end_callback)
-- 	action = self:ComboAction(action,end_action)
-- 	cc.ActionManager:GetInstance():addAction(action,self.transform)
-- end

-- function NotifyText:ComboAction(action1,action2)
-- 	if action1 and action2 then
-- 		return cc.Sequence(action1,action2)
-- 	elseif not action1 then
-- 		return action2
-- 	elseif not action2 then
-- 		return action1
-- 	end
-- end

-- function NotifyText:StopAction()
-- 	cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.transform)
-- end