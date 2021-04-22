-- 拉人的选择区域范围，使用技能配置里的aoe范围设置
-- 拉人参数
	-- pos_type 		[required] 目标点类型, "fix" "self" "target"
	-- pos 				[required] 目标点坐标, 如果pos_type等于"self"或者"target"则为相对坐标
	-- duration 		[required] 耗时，秒
	-- mul_pos 			[optional] 目标地点的相对位置点，可以配置多个
	-- flip_with_actor 	[optional] 为true时，pos和mul_pos按照朝向翻转（pos_type等于"fix"时不翻转）
	-- limit 			[optional] 拉人数量上限
	-- accel 			[optional] 加速度, 必须大于0。默认为1。1是匀速，小于1是先快后慢，大于1是先慢后快。

local QSBAction = import(".QSBAction")
local QSBDragActor = class("QSBDragActor", QSBAction)

function QSBDragActor:_execute(dt)
	local actor = self._attacker
	local target = self._target
	local skill = self._skill

	local options = self:getOptions()
	local pos_type = options.pos_type
	local flip_with_actor = options.flip_with_actor
	local pos = options.pos or {x = 0, y = 0}
	local duration = options.duration
	local accel = options.accel or 1
	local mul_pos = options.mul_pos
	local limit = options.limit

	local drag_actors = self._drag_actors
	local original_positions = self._original_positions
	local drag_positions = self._drag_positions
	local accumulated_time = self._accumulated_time
	if drag_actors == nil then
		-- 决定哪些人需要拉
		if options.selectTarget then
			drag_actors = {options.selectTarget}
		elseif skill:getRangeType() == skill.SINGLE then
			if skill:getTargetType() == skill.SELF then
				drag_actors = {actor}
			elseif skill:getTargetType() == skill.TARGET then
				drag_actors = {target}
			else
				assert(false, "")
			end
		elseif skill:getRangeType() == skill.MULTIPLE then
			drag_actors = actor:getMultipleTargetWithSkill(skill, target)
			if #drag_actors == 0 then
				self:finished()
				return
			end
		else
			assert(false, "")
		end

		-- 检查免疫
		local new_drag_actors = {}
		for _, actor in ipairs(drag_actors) do
			local immune = false
			if actor:isSupport() then
				immune = true
			else
				for _, buff in ipairs(actor:getBuffs()) do
					if not buff.effects.is_knockback then
						immune = true
						break
					end
				end
			end
			if not immune then
				table.insert(new_drag_actors, actor)
			end
		end
		drag_actors = new_drag_actors

		-- actors 静止
		for _, actor in ipairs(drag_actors) do
			if actor ~= self._attacker then
				actor:inTimeStop(true)
			end
		end
		-- actors的顺序比较固定，打乱一下
		local random = app.random
		local len = #drag_actors
		for i = 1, #drag_actors - 1 do
			local swap_index = random(i, len)
			drag_actors[i], drag_actors[swap_index] = drag_actors[swap_index], drag_actors[i]
		end
		-- 处理limit
		if limit and limit > 0 then
			for i = limit + 1, #drag_actors do
				drag_actors[i] = nil
			end
		end
		self._drag_actors = drag_actors
		-- 起始位置
		original_positions = {}
		for _, actor in ipairs(drag_actors) do
			table.insert(original_positions, clone(actor:getPosition()))
		end
		self._original_positions = original_positions
		-- 终止位置
		drag_positions = {}
		if pos_type == "fix" then
			pos = pos
		elseif pos_type == "target" then
			if flip_with_actor and not target:isFlipX() then 
				pos.x = -pos.x
				if mul_pos then
					for _, sub_pos in ipairs(mul_pos) do
						sub_pos.x = -sub_pos.x
					end
				end
			end
			pos = {x = pos.x + target:getPosition().x, y = pos.y + target:getPosition().y}
		elseif pos_type == "self" then
			if flip_with_actor and not actor:isFlipX() then 
				pos.x = -pos.x
				if mul_pos then
					for _, sub_pos in ipairs(mul_pos) do
						sub_pos.x = -sub_pos.x
					end
				end
			end
			pos = {x = pos.x + actor:getPosition().x, y = pos.y + actor:getPosition().y}
		else
			assert(false, "")
		end
		if mul_pos then
			local m = #mul_pos
			for i = 0, #original_positions - 1 do
				local rel_pos = mul_pos[i % m + 1]
				table.insert(drag_positions, {x = pos.x + rel_pos.x, y = pos.y + rel_pos.y})
			end
		else
			for i = 1, #original_positions do
				table.insert(drag_positions, clone(pos))
			end
		end
		for _, pos in ipairs(drag_positions) do
			pos.y = pos.y
			if not options.drag_out_of_screen then
				pos.x = math.clamp(pos.x, BATTLE_AREA.left, BATTLE_AREA.right)
			end
		end
		self._drag_positions = drag_positions
		-- 初始化拉人时间
		self._accumulated_time = 0
	else
		accumulated_time = accumulated_time + dt
		local percent = accumulated_time / duration
		percent = percent ^ accel
		percent = math.min(percent, 1.0)
		for index, actor in ipairs(drag_actors) do
			local origninal_position = original_positions[index]
			local drag_position = drag_positions[index]
			local cur_pos = {x = math.sampler(origninal_position.x, drag_position.x, percent), y = math.sampler(origninal_position.y, drag_position.y, percent)}
			app.grid:moveActorTo(actor, cur_pos, true, true, true)
			-- actor:setActorPosition(cur_pos)
		end
		self._accumulated_time = accumulated_time

		if percent == 1.0 then
			-- actors 解除静止
			for _, actor in ipairs(drag_actors) do
				if actor ~= self._attacker then
					actor:inTimeStop(false)
				end
			end
			self._drag_actors = nil
			self:finished()
			return
		end
	end
end

function QSBDragActor:_onCancel()
	-- actors 解除静止
	local drag_actors = self._drag_actors
	if drag_actors then
		for _, actor in ipairs(drag_actors) do
			if actor ~= self._attacker then
				actor:inTimeStop(false)
			end
		end
	end
end

return QSBDragActor