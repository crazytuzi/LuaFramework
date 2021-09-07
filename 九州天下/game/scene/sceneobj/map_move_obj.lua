
MapMoveObj = MapMoveObj or BaseClass()

-- 地图移动对象，包括视野外的对象
function MapMoveObj:__init(vo)
	self.vo = vo

	if self.vo.distance < 0.01 then
		return
	end

	self.move_param = {}
	self.move_param.move_speed = self.vo.move_speed / 100
	self.move_param.last_time = Status.NowTime
	self.move_param.pass_distance = 0
	self.move_param.dir_x = math.cos(self.vo.dir)
	self.move_param.dir_y = math.sin(self.vo.dir)
end

function MapMoveObj:__delete()
	GameVoManager.Instance:DeleteVo(self.vo)
end

function MapMoveObj:GetVo()
	return self.vo
end

function MapMoveObj:GetLogicPos()
	return self.vo.pos_x, self.vo.pos_y
end

function MapMoveObj:Update(now_time, elapse_time)
	if nil == self.move_param then
		return
	end

	elapse_time = now_time - self.move_param.last_time
	local distance = elapse_time * self.move_param.move_speed

	if self.move_param.pass_distance + distance >= self.vo.distance then
		distance = self.vo.distance - self.move_param.pass_distance
		self.move_param.pass_distance = self.vo.distance
		self.vo.pos_x = math.floor(self.vo.pos_x + self.move_param.dir_x * distance)
		self.vo.pos_y = math.floor(self.vo.pos_y + self.move_param.dir_y * distance)
		self.move_param = nil
	else
		self.move_param.last_time = now_time
		self.move_param.pass_distance = self.move_param.pass_distance + distance
		self.vo.pos_x = math.floor(self.vo.pos_x + self.move_param.dir_x * distance)
		self.vo.pos_y = math.floor(self.vo.pos_y + self.move_param.dir_y * distance)
	end
end
