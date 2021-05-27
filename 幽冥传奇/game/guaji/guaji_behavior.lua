GuajiCtrl = GuajiCtrl or BaseClass(BaseController)

----------------------------------
--移动

-- 移动到目标对象
function GuajiCtrl:MoveToObj(target_obj, range, offset_range)
	MoveCache.is_valid = true
	MoveCache.move_type = MoveType.Obj
	MoveCache.target_obj = target_obj
	MoveCache.target_obj_id = target_obj:GetObjId()
	MoveCache.range = range or 1
	MoveCache.offset_range = offset_range or 1

	local x, y = target_obj:GetLogicPos()
	if self:CheckRange(x, y, MoveCache.range + MoveCache.offset_range) then				-- 离目标1格，允许误差1格
		self:OnOperate()
		return
	end
	self:MoveHelper(x, y, MoveCache.range, target_obj)
end

-- 移动到某个位置
-- 调用前注意先配置一下 MoveCache 参数
function GuajiCtrl:MoveToPos(scene_id, x, y, range, offset_range)
	MoveCache.is_valid = true
	MoveCache.move_type = MoveType.Pos
	MoveCache.scene_id = scene_id
	MoveCache.x = x
	MoveCache.y = y
	MoveCache.range = range or 0
	MoveCache.offset_range = offset_range or 0

	if scene_id ~= Scene.Instance:GetSceneId() then
		MoveCache.cross_scene = true
		self:MoveToScenePos(scene_id, x, y)
		return
	end

	local self_x, self_y = self.scene:GetMainRole():GetLogicPos()
	if self:CheckRange(x, y, range + MoveCache.offset_range) then
		self:OnOperate()
		return
	end

	self:MoveHelper(x, y, range)
	-- GuajiCtrl.Instance:SetPlayerOptState(false)
end

-- 移动
-- 调用前注意先配置一下 MoveCache 参数
function GuajiCtrl:MoveHelper(x, y, range)
	local move_range = range
	local dir
	for i = range, 1, -1 do
		if nil == dir then
			local self_x, self_y = self.scene:GetMainRole():GetLogicPos()
			dir = GameMath.GetDirectionNumber(self_x - x, self_y - y)
		end
		if not GameMapHelper.IsBlock(x + GameMath.DirOffset[dir].x * range, y + GameMath.DirOffset[dir].y * range) then
			x = x + GameMath.DirOffset[dir].x * range
			y = y + GameMath.DirOffset[dir].y * range
			range = range - i
			break
		end
	end

	if not self.scene:GetMainRole():DoMoveByPos(cc.p(x, y), range, self.on_arrive_func) then
		MoveCache.is_valid = false
	end
end

-- 移动到某个场景位置
function GuajiCtrl:MoveToScenePos(scene_id, x, y)
	if self.scene:GetSceneId() == scene_id then
		self:MoveHelper(x, y, MoveCache.range)
		return
	end

	local door_cfg = MapData.Instance:GetDoorCfg(Scene.Instance:GetSceneId(), scene_id)
	if nil ~= door_cfg then
		self:MoveHelper(door_cfg.posx, door_cfg.posy, 0)
	else
		MoveCache.is_valid = false
	end
end

function GuajiCtrl:AutoMove()
	local x, y = 0, 0
	local self_x, self_y = self.scene:GetMainRole():GetLogicPos()

	for i = 20, 2, -1 do
		x = self_x + math.random(i * 2) - i
		y = self_y + math.random(i * 2) - i
		if not GameMapHelper.IsBlock(x, y) then
			break
		end
	end

	if not GameMapHelper.IsBlock(x, y) then
		MoveCache.end_type = MoveEndType.FightAuto
		self:MoveToPos(self.scene:GetSceneId(), x, y, 0)
	end
end



------------------------------------------
--传送

function GuajiCtrl:FlyByIndex(index)
	MoveCache.is_valid = true
	MoveCache.move_type = MoveType.Fly
	MoveCache.scene_id = 1000000 + math.random(1, 999999)
	Scene.SendQuicklyTransportReq(index)
end

function GuajiCtrl:FlyBySceneId(scene_id, x, y)
	MoveCache.is_valid = true
	MoveCache.move_type = MoveType.Fly
	MoveCache.scene_id = 1000000 + math.random(1, 999999)
	Scene.SendTransmitSceneReq(scene_id, x, y)
end

function GuajiCtrl:FlyByRobEscort(scene_id, x, y)
	MoveCache.is_valid = true
	MoveCache.move_type = MoveType.Fly
	MoveCache.scene_id = 1000000 + math.random(1, 999999)
	Scene.SendTransmitToRobEscortReq(scene_id, x, y)
end