
Monster =BaseClass(LivingThing)

function Monster:__init( vo )
	if not vo then return end
	self.type = PuppetVo.Type.MONSTER
	self:SetVo(vo)
	self.cfg = Monster.GetVO( vo.eid )
	self:InitEvent()
	-- self.moveSpeed=3.2
	if self.cfg then
		vo.name = self.cfg.name or ""
		self.changeBR = self.cfg.changeBR or 1
		self.bodyRadius = MapUtil.DistanceSC( self.cfg.hitBR or 100 ) * self.changeBR-- 身体实体宽度
		self.bodyHeight = MapUtil.DistanceSC( self.cfg.bodyH or 100 ) * self.changeBR -- 身体高度
		self.hitRadius = MapUtil.DistanceSC( self.cfg.hitBR or 1 ) * self.changeBR-- 身体实体宽度
		self.monsterType = self.cfg.monsterType --设置怪物类型
		self.vo.monsterType = self.cfg.monsterType --设置vo的怪物类型
	end
	self.dieCallback = nil
end

-- 清理
function Monster:__delete()
	self.cfg = nil
	self.changeBR = nil
	self.bodyRadius = nil
	self.bodyHeight = nil
	self.hitRadius = nil
	self.monsterType = nil
	self.dieCallback = nil
	if self.vo then
		RenderMgr.Realse(self.vo.guid)
		self.vo:RemoveEventListener(self.handler)
	end
end

function Monster:SetDieHandler(dieCallback)
	self.dieCallback = dieCallback
end

function Monster:ToDie()
	LivingThing.ToDie(self)
	if self.head then
		HeadUIMgr:GetInstance():Remove(self.head)
	end
	self.head = nil
	self:StopMove()
	GlobalDispatcher:DispatchEvent(EventName.MONSTER_DEAD, {self.guid, 0, self:IsBoss()})
	RenderMgr.Delay(function ()
		if ToLuaIsNull(self.gameObject) then return end
			local function DoDead(guid)
				GlobalDispatcher:DispatchEvent(EventName.MONSTER_DEAD, {guid, 1, self:IsBoss()})
				if not ToLuaIsNull(self.gameObject) then
					self.gameObject:SetActive(false)
				end
				RenderMgr.Realse(guid)
			end
			if not ToLuaIsNull(self.gameObject) then
				self.removeRender = RenderMgr.Add(function ()
					local tf = self.transform
					if not ToLuaIsNull(tf) then
						tf.position = tf.position + Vector3.New(0, -0.02, 0)
					end
				end, nil, 2, DoDead, self.vo.guid)
			end
	end, 3)
end

function Monster:InitEvent()
	LivingThing.InitEvent(self)
	local onUpdateHandle = function (key, value, pre)
		local tf = self.transform
		if ToLuaIsNull(tf) then return end
		if self.vo then
			if key == "moveSpeed" then
				if self.agentDriver then
					self.agentDriver:SetMoveSpeed(value)
				end
			end
			if key == "position" then
				if not self:GetDizzyState() then
					local targetPos = value
					if self.vo.state == 3 then  --被击飞或者击退就直接设置位置
						tf.position = targetPos
					else
						self:MoveToPositionByAgent(targetPos)
					end
				end
			end
			if key == "direction" then
				local targetDir = value
				if self.vo.state == 3 then
					tf.rotation = targetDir
				end
			end
			if key == "die" then
				if value then  --如果怪物死亡,全局发布死亡通知
					self:ToDie()
				end
			end
		end
	end
	if self.vo then
		self.handler=self.vo:AddEventListener(SceneConst.OBJ_UPDATE, onUpdateHandle) -- 属性更新变化事件
	end
end

function Monster:SetVo(vo)
	LivingThing.SetVo(self, vo)
end
function Monster:SetGameObject( gameObject )
	if ToLuaIsNull(gameObject) then return end
	LivingThing.SetGameObject(self, gameObject)
end

-- Time.deltaTime
function Monster:Update()
	if not self:GetGameObject() then return end
	if self.isHitPlayer and not self.isWalking then
		self.isHitPlayer = nil
		self:SetColliderInfo("center", Vector3.New(0, self.bodyHeight*0.5, 0))
		self.characterController:Move(Vector3.up*0.01)
	end
	LivingThing.Update(self, Time.deltaTime)
end

function Monster.GetVO( eid )
	local id = tonumber(eid)
	return MonsterVo.GetCfg( id )
end
