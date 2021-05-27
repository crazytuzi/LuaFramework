GuajiCtrl = GuajiCtrl or BaseClass(BaseController)

-- 检查当前位置是否可发动攻击
function GuajiCtrl.CheckAtkRange(self_x, self_y, x, y, range_info)
	local atk_range = 999
	if range_info.rect_range and not GuajiCtrl.CheckRectRange(self_x, self_y, x, y, range_info.rect_range) then
		atk_range = range_info.rect_range
	end
	if range_info.eight_dir_line_range and not GuajiCtrl.CheckEightDirLineRange(self_x, self_y, x, y, range_info.eight_dir_line_range) then
		atk_range = math.min(atk_range, range_info.eight_dir_line_range)
	end
	return atk_range == 999, atk_range
end

-- 主角移动满一个格子，检查现在有什么事要做
-- 返回是否要停止移动
function GuajiCtrl:CheckAnyThingToDo()
	-- 是否已到达可攻击坐标 是则停止移动
	if self:MoveToAtk() then
		return true
	end

	-- 移动缓存失效
	if not MoveCache.is_valid then
		return false
	end

	local end_type = MoveCache.end_type
	if end_type == MoveEndType.NpcTask then
		local npc = self.scene:GetNpcByNpcId(MoveCache.param1)
		if nil ~= npc then
			self:OnSelectObj(npc, "select")
		end
	end

	return false
end

-- 获得当前主角面向目标的方向
function GuajiCtrl:GetMainRoleTargetDir(x, y)
	local self_x, self_y = self.scene:GetMainRole():GetServerPos()
	if self_x == x and self_y == y then
		return self.scene:GetMainRole():GetDirNumber()
	end
	return GameMath.GetDirectionNumber(x - self_x, y - self_y)
end

-- 检测在8方向直线上范围
function GuajiCtrl.CheckEightDirLineRange(self_x, self_y, x, y, range)
	local x_dis = math.abs(x - self_x)
	local y_dis = math.abs(y - self_y)
	return (x_dis <= range and y_dis <= range) and (x_dis == y_dis or x_dis == 0 or y_dis == 0)
end

-- 检测矩形范围
function GuajiCtrl.CheckRectRange(self_x, self_y, x, y, range)
	return math.abs(x - self_x) <= range and math.abs(y - self_y) <= range 
end

-- 检测范围
function GuajiCtrl:CheckRange(x, y, range)
	local self_x, self_y = self.scene:GetMainRole():GetServerPos()
	return GuajiCtrl.CheckRectRange(self_x, self_y, x, y, range)
end

-- x y 坐标在 range 内 有多个可攻击目标
function GuajiCtrl.IsMultiTarget(x, y, range)
	local count, target_x, target_y = 0, 0, 0

	for k, v in pairs(Scene.Instance:GetMonsterList()) do
		if Scene.Instance:IsEnemy(v) then
			target_x, target_y = v:GetLogicPos()
			if math.abs(target_x - x) <= range and math.abs(target_y - y) <= range then
				count = count + 1
				if count >= 2 then
					return true
				end
			end
		end
	end

	for k, v in pairs(Scene.Instance:GetRoleList()) do
		if Scene.Instance:IsEnemy(v) then
			target_x, target_y = v:GetLogicPos()
			if math.abs(target_x - x) <= range and math.abs(target_y - y) <= range then
				count = count + 1
				if count >= 2 then
					return true
				end
			end
		end
	end

	return false
end
