-- 鱼
Fish = Fish or BaseClass()

local MAX_MOVE_Y_TIMES = 50
function Fish:__init(vo, is_protectfish)
	self.vo = vo
	self.is_protectfish = is_protectfish
	self.obj = nil
	self.tips_obj = nil
	self.is_load = false
	self.is_dead = false
	self:CreateObj()

	local speed = math.random(15, 30)
	speed = speed/100
	self.default_speed = speed			--默认移动速度(像素/帧)
	self.move_speed = speed				--当前移动速度(像素/帧)

	self.elapse_time = 0.02				--固定1次update时间

	self.range_x_min = 0
	self.range_x_max = 0
	self.range_y_min = 0
	self.range_y_max = 0

	self.rotation_y = 0

	self.check_x = 350					--检测范围x
	self.check_y = 50					--检测范围y

	self.move_y_times = 0
	self.move_y = 0
	self.is_run = false					--是否处于逃逸状态

	self.bullet_x = 99999
	self.bullet_y = 99999

	self.random_tips_time = math.random(3, 6)

	Runner.Instance:AddRunObj(self, 8)
end

function Fish:__delete()
	self.vo = nil
	self.is_protectfish = false
	self.is_load = false

	self.is_dead = false

	self.range_x_min = 0
	self.range_x_max = 0
	self.range_y_min = 0
	self.range_y_max = 0

	self.rotation_y = 0

	if self.obj then
		GameObjectPool.Instance:Free(self.obj)
	end
	self.obj = nil
	self.tips_obj = nil

	if self.be_take_time_quest then
		GlobalTimerQuest:CancelQuest(self.be_take_time_quest)
		self.be_take_time_quest = nil
	end

	self:StopTipsTimeQuest()

	self.bullet_x = 99999
	self.bullet_y = 99999

	Runner.Instance:RemoveRunObj(self)
end

function Fish:GetVo()
	return self.vo
end

function Fish:GetObj()
	return self.obj
end

function Fish:IsDead()
	return self.is_dead
end

function Fish:SetParent(parent)
	self.parent = parent
	self.max_x = self.parent.rect.sizeDelta.x
	self.max_y = self.parent.rect.sizeDelta.y
end

--播放被捕效果
function Fish:PlayToBeTake()
	local scale_value = 1
	if not self.obj then return end
	local canvas_group = self.obj:GetComponent(typeof(UnityEngine.CanvasGroup))
	local alpha = 1
	self.is_dead = true
	if self.be_take_time_quest then
		GlobalTimerQuest:CancelQuest(self.be_take_time_quest)
		self.be_take_time_quest = nil
	end
	self.be_take_time_quest = GlobalTimerQuest:AddRunQuest(function()
		if alpha <= 0 then
			--完成了被捕过程，删除鱼
			if self.be_take_time_quest then
				GlobalTimerQuest:CancelQuest(self.be_take_time_quest)
				self.be_take_time_quest = nil
			end
			self:DeleteMe()
			return
		end

		if scale_value >= 1 then
			scale_value = 0.7
			self.obj.transform.localScale = Vector3(scale_value, scale_value, scale_value)
		end
		alpha = alpha - 0.02
		canvas_group.alpha = alpha
	end, 0)
end

--是否守卫鱼
function Fish:IsProtectFish()
	return self.is_protectfish
end

function Fish:SetDelfaultSpeed(speed)
	self.default_speed = speed
end

function Fish:SetIsRun(state)
	self.is_run = state
end

function Fish:BulletPositionChange(x, y)
	self.bullet_x = x
	self.bullet_y = y
end

function Fish:StopTipsTimeQuest()
	if self.tips_activite_time_quest then
		GlobalTimerQuest:CancelQuest(self.tips_activite_time_quest)
		self.tips_activite_time_quest = nil
	end

	if self.tips_disactivite_time_quest then
		GlobalTimerQuest:CancelQuest(self.tips_disactivite_time_quest)
		self.tips_disactivite_time_quest = nil
	end
end

function Fish:StartTipsTimeQuest()
	local function activite()
		if nil ~= self.tips_obj then
			self.tips_obj.gameObject:SetActive(true)
		end
	end
	local function disactivite()
		if nil ~= self.tips_obj then
			self.tips_obj.gameObject:SetActive(false)
		end
	end
	local function time_start()
		self.tips_activite_time_quest = GlobalTimerQuest:AddDelayTimer(
		function()
			disactivite()
			self.tips_disactivite_time_quest = GlobalTimerQuest:AddDelayTimer(
			function()
				activite()
				time_start()
			end, self.random_tips_time)
		end, 2)
	end

	-- 首次打开
	activite()
	time_start()
end

function Fish:CreateObj()
	local fish_type = self.vo.quality + 1
	if self.is_protectfish then
		fish_type = 5
	end
	local bundle, asset = ResPath.GetFishModelRes("uis/icons/fish/fish_0".. fish_type .. "_prefab","Fish_0" .. fish_type)
	GameObjectPool.Instance:SpawnAsset(bundle, asset, function(obj)
		if not obj then
			return
		end

		if nil == self.vo or nil == self.parent then
			GameObjectPool.Instance:Free(obj)
			return
		end

		if self.obj then
			GameObjectPool.Instance:Free(self.obj)
		end
		self.obj = obj

		self.obj.transform:SetParent(self.parent.transform)

		self.obj:GetComponent(typeof(UnityEngine.CanvasGroup)).alpha = 1

		--设置随机旋转角度
		local rotation_y = math.random(0, 1) == 0 and 0 or 180
		self.rotation_y = rotation_y
		self.obj.transform.localRotation = Quaternion.Euler(0, rotation_y, 0)

		self.obj.transform.localScale = Vector3(1, 1, 1)

		self.obj_width = self.obj:GetComponent(typeof(UnityEngine.RectTransform)).sizeDelta.x
		self.obj_heigh = self.obj:GetComponent(typeof(UnityEngine.RectTransform)).sizeDelta.y

		self.range_x_min = -self.max_x/2
		self.range_x_max = self.max_x/2
		--设置随机位置
		if not self.pos then
			local pos_x = math.random(self.range_x_min, self.range_x_max)

			local min_y = 400
			if self.is_protectfish then
				min_y = 200
			end
			self.range_y_min = min_y
			local max_y_diff = 100
			if self.is_protectfish then
				--守卫鱼尽量往下
				max_y_diff = 150
			end
			self.range_y_max = self.max_y - max_y_diff
			local pos_y = math.random(self.range_y_min, self.range_y_max)

			self.obj.transform.localPosition = Vector3(pos_x, pos_y, 0)
		else
			local y = self.pos.y + self.max_y / 2
			self.obj.transform.localPosition = Vector3(self.pos.x, y, 0)
		end

		if fish_type < 5 then
			local name_table = self.obj:GetComponent(typeof(UINameTable))
			local tips_obj = name_table:Find("Tips")
			tips_obj = U3DObject(tips_obj)
			self.tips_obj = tips_obj
			self.tips_obj.transform.localRotation = Quaternion.Euler(0, rotation_y, 0)
			self:StartTipsTimeQuest()
		end

		self.is_load = true
	end)
end

function Fish:Update(now_time, elapse_time)
	local diff_elapse_time = elapse_time - self.elapse_time
	if not self.is_load or self.is_dead then
		return
	end

	if self.move_y_times >= MAX_MOVE_Y_TIMES then
		self.move_y_times = 0
		self.move_y = 0
	end

	local local_position = self.obj.transform.localPosition
	local now_x = local_position.x
	local now_y = local_position.y
	--每次都要重新设置移动的速度
	self.move_speed = self.default_speed + (diff_elapse_time/self.elapse_time) * self.default_speed
	if math.abs(now_x) > self.range_x_max + self.obj_width + 10 then
		--超出范围就重新设置速度
		self.is_run = false
		local speed = math.random(15, 30)
		speed = speed/100
		self.default_speed = speed
		self.move_speed = self.default_speed + (diff_elapse_time/self.elapse_time) * self.default_speed

		self.rotation_y = 0
		if now_x < 0 then
			self.rotation_y = 180
		end
		self.obj.transform.localRotation = Quaternion.Euler(0, self.rotation_y, 0)
		if self.tips_obj then
			self.tips_obj.transform.localRotation = Quaternion.Euler(0, self.rotation_y, 0)
		end
	elseif self.is_run then
		self.move_y_times = 0
		self.move_y = 0
	else
		if self.move_y_times <= 0 then
			--取一个随机值判断是否进行上下移动
			local rand_num = math.random(1, 1000)
			if rand_num == 2 then
				--上游
				self.move_y = self.move_speed
				local half_height = self.max_y/2
				if now_y > half_height then
					local need_y = self.move_speed
					if need_y > self.range_y_max - now_y then
						--上游距离不够改成下游
						self.move_y = -self.move_speed
					end
				end
				self.move_y_times = 1
			elseif rand_num == 3 then
				--下游
				self.move_y = -self.move_speed
				local half_height = self.max_y/2
				if now_y < half_height then
					local need_y = self.move_speed
					if need_y > now_y - self.range_y_min then
						--下游距离不够改成上游
						self.move_y = self.move_speed
					end
				end
				self.move_y_times = 1
			end
		else
			self.move_y_times = self.move_y_times + 1
			if self.move_y < 0 then
				self.move_y = -self.move_speed
				local left_y = now_y - self.range_y_min
				if math.abs(self.move_y) > left_y then
					--重置y轴移动
					self.move_y_times = 0
					self.move_y = 0
				end
			elseif self.move_y > 0 then
				self.move_y = self.move_speed
				local left_y = self.range_y_max - now_y
				if self.move_y > left_y then
					--重置y轴移动
					self.move_y_times = 0
					self.move_y = 0
				end
			end
		end
	end

	if self.is_protectfish then
		local distance_y = now_y - self.bullet_y
		local distance_x = math.abs(now_x - self.bullet_x)
		if distance_y > 0 and distance_y < self.check_y and distance_x < self.check_x then
			--说明子弹在鱼的附近
			self.rotation_y = 0
			if self.bullet_x > now_x then
				self.rotation_y = 180
			end
			self.is_run = true
			self.default_speed = 1.5
			self.move_speed = self.default_speed + (diff_elapse_time/self.elapse_time) * self.default_speed
			self.obj.transform.localRotation = Quaternion.Euler(0, self.rotation_y, 0)
		-- elseif self.is_run and distance_y < -200 then
		-- 	--超出检测范围就初始化速度
		-- 	self.is_run = false
		-- 	local speed = math.random(15, 30)
		-- 	speed = speed/100
		-- 	self.move_speed = speed
		end
	end
	self.obj.transform:Translate(-self.move_speed, self.move_y, 0)
end

function Fish:GetPosition()
	if self.obj then
		return self.obj.transform.position
	end
	return Vector3.zero
end

function Fish:SetPosition(pos)
	self.pos = pos
	if self.obj then
		self.obj.transform.localPosition = Vector3(pos.x, pos.y, 0)
	end
end