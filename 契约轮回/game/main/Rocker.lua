-- 
-- @Author: LaoY
-- @Date:   2018-07-22 18:04:01
-- 
--摇杆类
Rocker = Rocker or class("Rocker",BasePanel)
local Rocker = Rocker

function Rocker:ctor()
	self.abName = "main"
	self.assetName = "Rocker"
	self.layer = "Bottom"

	self.use_background = false		
	self.change_scene_close = false
	self.last_start_time = 0
	self.once_time = 0.1
	self.is_can_drag = true
	self.move_dir = Vector2(0,0)
	self.last_trigger_vec = nil
	self.last_update_time = Time.time - 1
	self.model = MainModel:GetInstance()
end

function Rocker:dctor()
	if self.event_id then
		GlobalEvent:RemoveListener(self.event_id)
		self.event_id = nil
	end
end

function Rocker:Open( )
	BasePanel.Open(self)
end

function Rocker:LoadCallBack()
	self.nodes = {
		"img_bg","img_icon",
	}
	self:GetChildren(self.nodes)

	SetAlignType(self.transform, bit.bor(AlignType.Left, AlignType.Bottom))

	SetVisible(self.img_icon,true)

	local x,y = GetAnchoredPosition(self.img_bg)
	self.bg_start_pos = {x = x,y = y,z = z}
	x,y = GetAnchoredPosition(self.img_icon)
	self.icon_start_pos = {x = x,y = y}

	self.radius = GetSizeDeltaX(self.img_bg) * 0.5

	self.touch_begin_pos = {x = x,y = y}


	self.is_touch = false
	self:AddEvent()
end

function Rocker:AddEvent()
	AddDragBeginEvent(self.img_bg.gameObject,handler(self,self.BeginDrag))
	AddDragEvent(self.img_bg.gameObject,handler(self,self.Drag))
	AddDragEndEvent(self.img_bg.gameObject,handler(self,self.EndDrag))

	local function call_back(vec)
		self:IconMoveTo(vec)
	end
	self.event_id = GlobalEvent:AddListener(MainEvent.RockerVec, call_back)
end

function Rocker:BeginDrag(target,x,y)
	if not self:IsCanDrag() then
		return
	end
	self:StopTime()
	self.is_touch = true
	-- SetVisible(self.img_icon,true)
	x,y = ScreenToViewportPosition(x,y)
	self.touch_begin_pos = {x = x , y = y}
	self.last_move_pos = self.touch_begin_pos
	self.last_trigger_vec = nil
	self.last_start_time = Time.time

	self:SetDirectVec(x,y)

	Rocker.IsRocking = true
	-- if AutoFightManager:GetInstance():GetAutoFightState() then
	-- 	GlobalEvent:Brocast(FightEvent.AutoFight)
	-- end
end

function Rocker:Drag(target,x,y)
	if not self:IsCanDrag() or not self.is_touch then
		return
	end
	x,y = ScreenToViewportPosition(x,y)
	local distance = (self.last_move_pos.x - x) * (self.last_move_pos.x - x) + (self.last_move_pos.y - y) * (self.last_move_pos.y - y)
	if distance < 8 then
		return
	end
	self:SetDirectVec(x,y)
end

function Rocker:SetDirectVec(x,y)
	local move_pos = {x = x,y = y}
	local target_pos = Vector2.MoveTowards(self.icon_start_pos, move_pos, self.radius)
	self.last_move_pos.x = move_pos.x
	self.last_move_pos.y = move_pos.y
	self.move_dir.x = target_pos.x - self.icon_start_pos.x
	self.move_dir.y = target_pos.y - self.icon_start_pos.y
	self.move_dir:SetNormalize()
	self:IconMoveTo(self.move_dir,target_pos)
	-- print('--LaoY Rocker.lua,line 87-- data=',self.move_dir.x,self.move_dir.y)
	if not self.handler_update then
		LateUpdateBeat:Add(self.Update,self,nil,1)
		self.handler_update = true
	end
end

function Rocker:IconMoveTo(vec,target_pos)
	if vec and (vec.x~= 0 or vec.y ~= 0) then
		-- AutoFightManager:GetInstance():StopAutoFight()
		if AutoFightManager:GetInstance().auto_state == AutoFightManager.AutoState.Auto or 
		AutoFightManager:GetInstance().auto_state == AutoFightManager.AutoState.Tem then
			AutoFightManager:GetInstance():TemAutoFight()
		end
		if not DungeonModel:GetInstance():IsDungeonScene() then
			TaskModel:GetInstance():PauseTask()
		end
		OperationManager:GetInstance():StopAStarMove()
	end

	vec = vec or self.move_dir
	local x,y
	if not target_pos then
		x = vec.x * self.radius + self.icon_start_pos.x
		y = vec.y * self.radius + self.icon_start_pos.y
	else
		x,y = target_pos.x,target_pos.y
	end
	SetAnchoredPosition(self.img_icon,x,y)
end

function Rocker:EndDrag(target,x,y)
	-- if not self:IsCanDrag() then
	-- 	return
	-- end
	self:StopTime()
	local cur_time = Time.time
	local function func()
		if self.handler_update then
			LateUpdateBeat:Remove(self.Update)
			self.handler_update = false
		end
		self.move_dir.x = 0
		self.move_dir.y = 0

		self.is_touch = false
		-- SetVisible(self.img_icon,false)
		self:IconMoveTo(self.move_dir)
		GlobalEvent:Brocast(MainEvent.MoveRocker,nil)
	end
	local time_diff = cur_time - self.last_start_time
	if time_diff < self.once_time then
		self.time_id = GlobalSchedule:StartOnce(func,time_diff)
	else
		func()
	end
	Rocker.IsRocking = false
end

function Rocker:StopTime()
	if self.time_id then
		GlobalSchedule:Stop(self.time_id)
		self.time_id = nil
	end
end

function Rocker:Update()
	-- if self.move_dir:SqrMagnitude() <= 1e-05 then
	-- 	return
	-- end
	if self.last_trigger_vec and self.last_trigger_vec.x == self.move_dir.x and self.last_trigger_vec.y == self.move_dir.y then
	-- and (Time.time - self.last_update_time > 1.0) then
		return
	end
	self.last_update_time = Time.time
	GlobalEvent:Brocast(MainEvent.MoveRocker,self.move_dir)
	self.last_trigger_vec = self.last_trigger_vec or {}
	self.last_trigger_vec.x = self.move_dir.x
	self.last_trigger_vec.y = self.move_dir.y
end

function Rocker:IsCanDrag()
	return (Time.time - self.last_start_time) > self.once_time
end

function Rocker:OpenCallBack()
end

function Rocker:CloseCallBack(  )

end