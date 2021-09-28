-- 场景物件(最基本的东西)
Thing =BaseClass()

Thing.AutoId = -10000
Thing.CenterBone = "Bip001 Spine1" -- 中心骨骼，作为受击点或位，或发射默认点

-- 本地对象类型
function Thing:IsMainPlayer()
	if self:IsHuman() and self.guid and  self.sceneModel:IsMainPlayer(self.guid) then
		return true
	end
	return false
end
function Thing:IsHuman()
	return self.type == PuppetVo.Type.PLAYER
end
function Thing:IsSummonThing()
	return self.type == PuppetVo.Type.Summon
end
function Thing:IsMonster()
	return self.type == PuppetVo.Type.MONSTER 
end
function Thing:IsCanClick()
	return self:IsNPC()
end
function Thing:IsNPC()
	return self.type == PuppetVo.Type.NPC
end
function Thing:IsDoor()
	return self.type == PuppetVo.Type.Door
end
function Thing:IsBoss()
	return self.type == PuppetVo.Type.MONSTER and self.vo and self.vo.monsterType == MonsterVo.Type.Boss
end
function Thing:UseOnGroud()
	return self:IsHuman() or self:IsMonster() or self:IsNPC()
end
function Thing:IsLivingThing()
	return self.isLivingThing
end

function Thing.GetAutoId()
	Thing.AutoId = Thing.AutoId - 1
	return Thing.AutoId
end

function Thing:__init()
	self.type = PuppetVo.Type.NONE
	self.isLivingThing = false
	self.topContainer = nil -- 头顶容器
	self.buttomContainer = nil -- 脚下容器
	self.gameObject = nil
	self.transform = nil
	self.modelId = 0 -- 模型ID
	self.bodyRadius = 0.5 -- 身体实体宽度
	self.hitRadius = 0.5 -- 受击半径
	self.bodyHeight = 1 -- 身体高度
	self.animatorMgr = nil -- 动作控制管理器
	self._colorTimes = -1 -- 变色次数
	self.followTarget = nil -- 跟踪目标
	self.aims = nil -- 仇敌目标
	self.sceneCtrl = SceneController:GetInstance()
	self.sceneModel = SceneModel:GetInstance()
	self.is_destroy_ = false  --对象是否被销毁
	self.defaultBodyColor = nil --默认身体颜色
	self.defaultWeapon01Color = nil --默认左手武器颜色
	self.defaultWeapon02Color = nil --默认右手武器颜色
	self.changeBR = 1
	self.bodySize = Vector3.zero -- 身体模型大小

	self.vo = nil
	self.body = nil
	self.wing = nil
	self.bodyMat = nil
	self.weapon01 = nil
	self.weapon02 = nil
end

function Thing:ReInit()
	self.body = nil
	self.wing = nil
	self.bodyMat = nil
	self.weapon01 = nil
	self.weapon02 = nil
end

function Thing:SetGameObject( go )

	self:ReInit()
	self.gameObject = go
	self.transform = go.transform

	if self.vo then
		local animator = go:GetComponent("Animator")  -- 动作控制器
		if not ToLuaIsNull(animator) then
			self.animatorMgr = AnimatorMgr.New(animator, self)
			self.animatorMgr:SetMainName( self.name, self.vo.isMainRole)
		end
		self.changeBR = self.changeBR or 1
		self:SetPosition(self.vo.position or Vector3.zero)
		self:UpdateOnGround()
		self:SetScale(Vector3.one * self.changeBR)
		self:SetEulerAngles(self.vo.direction or Vector3.zero)

		local centerBone = Util.GetBone(Thing.CenterBone, go)
		if centerBone then
			self.centerBone = centerBone.transform
			self.bodyHeight = (self.centerBone.position.y-self.vo.position.y) * self.changeBR
		end

		if self:GetBody() then
			self.bodySize = Util.GetObjectSize(self:GetBody().gameObject)
			self.bodyHeight = self.bodySize.y/self.changeBR
		end
		local headMgr = HeadUIMgr:GetInstance()
		if (self:IsHuman() or self:IsMonster() or self:IsNPC() or self:IsDoor() or self:IsSummonThing()) and self.name ~= nil and self.name ~= "" then
			if self.sceneModel:IsCopy() and self:IsMainPlayer() then return end
			if self.head then
				headMgr:Remove(self.head)
			end
			local ui
			if self:IsMonster() then
				if not self:IsBoss() then
					ui = headMgr:Create(2, self)
				end
			elseif self:IsSummonThing() then
				if not self.sceneModel:IsTower() then
					ui = headMgr:Create(2, self)
				end
			elseif self:IsHuman() then
				if self:IsMainPlayer() then
					ui = headMgr:Create(1, self)
					-- ui:AddGuildName( "天下第一帮●测试=NPC ？！只是测试" )
					-- ui:UpdateName(self.vo.name, self.vo.nameColor, StringFormat("【{0}】", Network.ip))
				else
					ui = headMgr:Create(4, self)
					-- ui:SetTitle("称号●测试")
					-- ui:AddGuildName("天下第一帮●小众")
				end
				ui:AddStageIcon( self.vo.stage )
			elseif self:IsNPC() and self.animatorMgr then
				ui = headMgr:Create(3, self)
				-- ui:SetState(math.random(0, 2))
			elseif self:IsDoor() then
				ui = headMgr:Create(5, self)
				ui:SetOffSet( 100, 1.5 )
				ui:SetNameSize( 32 )
			end
			self.head = ui
		end
	end
end
function Thing:GetOwnerPlayer()
	return nil
end

-- 身体中心
function Thing:GetBodyCenter()
	if self.guid and not ToLuaIsNull(self.transform) then
		if self:GetCenterBone() then
			return self:GetCenterBone().position
		else
			return self.transform.position
		end
	end
	return Vector3.zero
end
-- 中心骨骼
function Thing:GetCenterBone()
	return self.centerBone or self.transform
end

-- 验证有无离地面
function Thing:UpdateOnGround()
	if not self.guid then return end
	if self:UseOnGroud() then
		local pos = self.transform.position
		local posNew = Vector3.New(pos.x, pos.y + 10, pos.z)
		local layerMask = LayerMask.GetMask("GlobalProjectorLayer")
		local hitFlag, rayHit = UnityEngine.Physics.Raycast(posNew, Vector3.down, nil, 30, layerMask)
		if hitFlag and rayHit then
			self.transform.position = Vector3.New(self.transform.position.x, rayHit.point.y, self.transform.position.z)
		end
	end
end

function Thing:CheckRound()
	local pos = Vector3.New(self.transform.position.x, self.transform.position.y+0.7, self.transform.position.z)
	local show = true -- 画线
	local f, f_ray = self:HitDistance(0.6, pos, Vector3.New(0, 0, 1), show) -- 前
	local fl, fl_ray = self:HitDistance(0.6, pos, Vector3.New(-1, 0, 1), show) -- 前左
	local fr, fr_ray = self:HitDistance(0.6, pos, Vector3.New(1, 0, 1), show) -- 前右

	local b, b_ray = self:HitDistance(0.6, pos, Vector3.New(0, 0, -1), show) -- 后
	local bl, bl_ray = self:HitDistance(0.6, pos, Vector3.New(-1, 0, -1), show) -- 后左
	local br, br_ray = self:HitDistance(0.6, pos, Vector3.New(1, 0, -1), show) -- 后右

	local l, l_ray = self:HitDistance(0.6, pos, Vector3.New(-1, 0, 0), show) -- 左
	local r, r_ray = self:HitDistance(0.6, pos, Vector3.New(1, 0, 0), show) -- 右

	return f, fl, fr, l, r
end

function Thing:HitDistance(dist, start, dir, draw)
	dir = self.transform:TransformDirection(dir or self.transform.forward)
	start = start or self.transform.position
	local hitFlag, rayHit = UnityEngine.Physics.Raycast(start, dir, nil, dist or 1)
	if hitFlag and draw then DrawUtils.DrawRay(start, dir, Color.red, 1) end
	return hitFlag, rayHit
end


function Thing:SetFlyEffect( gameObject, pos )
	self.gameObject = gameObject
	self.transform = gameObject.transform
	self:SetPosition(pos)

end

function Thing:Update(dt)

end

function Thing:GetAnimator() -- 获得动作控制管理器
	return self.animatorMgr
end

function Thing:OnClick(e)
	--[[if not self.isMainRole and 
		((CustomJoystick.mainJoystick and CustomJoystick.mainJoystick.joystick_touch.shape == Stage.inst.touchTarget) or 
		(MainUIController:GetInstance():GetMainUI() and MainUIController:GetInstance():GetMainUI().displayObject == Stage.inst.touchTarget)) then
		local hit = RaycastHit.New()
		local ray = Camera.main:ScreenPointToRay(Vector2.New(Stage.inst.touchPosition.x, UnityEngine.Screen.height-Stage.inst.touchPosition.y))
		local hitFlag, raycastHit = UnityEngine.Physics.Raycast(ray, nil)
		if not ToLuaIsNull(raycastHit.transform) and raycastHit.transform == self.transform then
			-- print(" 返回场景对象 ", self.transform.name)
			GlobalDispatcher:DispatchEvent(EventName.OBJECT_ONCLICK, self) -- 返回场景对象
		end
	end]]--
end

--改变触发器属性： 如 key:"radius" value:0.5, key:"center" value:Vector3
function Thing:SetColliderInfo(key, value, collider)
	if not self.guid then return end
	collider = collider or self.characterController
	if ToLuaIsNull(collider) then return end
	collider[key] = value
end
function Thing:GetGameObject()
	if not ToLuaIsNull(self.gameObject) then
		return self.gameObject
	else
		return nil
	end
end
-- 瞬移 或 设置位置
function Thing:SetPosition( pos )
	if self:GetGameObject() then
		self.transform.position = pos
		-- self:UpdateOnGround()
	end
end
--设置大小
function Thing:SetScale(scale)
	if self:GetGameObject() then
		self.transform.localScale = scale
	end
end

function Thing:GetPosition()
	if self:GetGameObject() then return self.transform.position end
	return Vector3.zero
end
function Thing:SetEulerAngles( angles )
	-- zwx("更新朝向")
	if self:GetGameObject() then 
		self.m_eulerAngles = angles:Clone()
		self.transform.eulerAngles = self.m_eulerAngles
	end
end
function Thing:GetEulerAngles()
	if self:GetGameObject() then
		return self.transform.eulerAngles
	end
	return Vector3.zero
end
-- 获得当前玩家的格子位置 返回，x, y
function Thing:GetGridPos()
	if not self:GetGameObject() then return 0, 0 end
	local x, y = MapUtil.LocalToGrid( self.transform.position )
	return x, y
end
function Thing:GetGridPosV2()
	local x, y = self:GetGridPos()
	if x == nil then return nil end
	return {x=x, y=y}
end
function Thing:SetVo( vo )
	self.vo = vo
	self.modelId = vo.dressStyle
	self.guid = vo.guid
	self.eid = vo.eid
	if self:IsHuman() then
		self.name = vo.name
	else
		self.name = vo.name
	end
end
-- 隐身
function Thing:CloakingHandler()
	if self:GetBody() then
		self.defaultBodyColor = self:GetBody().gameObject:GetComponent("Renderer").material.color
		local newColor = Color.New(self.defaultBodyColor.r, self.defaultBodyColor.g, self.defaultBodyColor.b, 0.3)
		self:ChangeColor(newColor)
	end

	if self:GetWeapon01() then
		local weapon = Util.GetChild(self:GetWeapon01().gameObject.transform, "weapon")
		if weapon then
			self.defaultWeapon01Color = weapon:GetComponent("Renderer").material.color
			local newColor = Color.New(self.defaultWeapon01Color.r, self.defaultWeapon01Color.g, self.defaultWeapon01Color.b, 0.3)
			self:ChangeWeapon01Color(newColor)
		end
	end

	if self:GetWeapon02() then
		local weapon = Util.GetChild(self:GetWeapon02().gameObject.transform, "weapon")
		if weapon then
			self.defaultWeapon02Color = weapon:GetComponent("Renderer").material.color
			local newColor = Color.New(self.defaultWeapon02Color.r, self.defaultWeapon02Color.g, self.defaultWeapon02Color.b, 0.3)
			self:ChangeWeapon01Color(newColor)
		end
	end

end
-- 反隐身
function Thing:UnCloakingHandler()
	self:ChangeColor(self.defaultBodyColor)
	self:ChangeWeapon01Color(self.defaultWeapon01Color)
	self:ChangeWeapon02Color(self.defaultWeapon02Color)
end
-- 设置身上颜色或闪光
function Thing:SetBodyColor( color, times )
	if self._colorTimes > 0 then return end
	if self:GetBody() then
		self._colorTimes = times or 1
		RenderMgr.CreateFrameRender(function ()
			self:_ChangeColor(color)
		end, 2, -1, "ColorChange_Render"..self.guid) -- 每帧更新
	end
end
-- 设置身上颜色或闪光
function Thing:ChangeColor(color)
	if not self:GetBody() then return end
	self:GetBody().gameObject:GetComponent("Renderer").material.color = (color or Color.white)
end

function Thing:ChangeWeapon01Color(color)
	if not self:GetWeapon01() then return end
	local weapon = Util.GetChild(self:GetWeapon01().gameObject.transform, "weapon")
	if weapon then
		weapon:GetComponent("Renderer").material.color = (color or Color.white)
	end
end

function Thing:ChangeWeapon02Color(color)
	if not self:GetWeapon02() then return end
	local weapon = Util.GetChild(self:GetWeapon02().gameObject.transform, "weapon")
	if weapon then
		weapon:GetComponent("Renderer").material.color = (color or Color.white)
	end
end

function Thing:_ChangeColor(color)
	if not self:GetBody() then return end
	if self._colorTimes > 0 then
		self:ChangeColor(color or Color.red)
	else
		if self._colorTimes <= 0 then
			RenderMgr.Realse("ColorChange_Render"..self.guid)
			self:ChangeColor(nil)
		end
	end
	self._colorTimes = self._colorTimes - 1
end

function Thing:PlayAction(action, normalizedTime, cb)
	if not action or not self.animatorMgr then return end
	self.animatorMgr:Play(action, normalizedTime, cb)
end

function Thing:PlayByTime(action, time, cb)
	if not action or not self.animatorMgr then return end
	self.animatorMgr:PlayByTime(action, time, cb)
end

function Thing:StopTimerByAction()
	if not self.animatorMgr then return end
	self.animatorMgr:StopTimerByAction()
end

-------------------------------------------------------------------------------------------- 战斗与跟踪
	-- 跟踪对象(可能处理的是导弹跟踪， 元素跟踪等)
	function Thing:SetFindFollow( sceneObj )
		if sceneObj ~= self.followTarget then
			self:ClearFollowTarget()
			if sceneObj then
				if self:IsLock() then return end
				local targetPosChangeFunc = function ()
					self:TargetPosChange()
				end
				local vo = sceneObj.vo
				if vo then
					vo:RemoveEventListener(self.target_pos_change_handler)
					self.target_pos_change_handler = vo:AddEventListener(SceneConst.TARGET_POS_CHANGE, targetPosChangeFunc) -- 位置改变处理
				end
			end
		else
			if self:IsLock() then return end
		end
		self.followTarget = sceneObj
		self:TargetPosChange()
	end

	-- 踪对象位置变化
	function Thing:TargetPosChange()
		if not self.followTarget then return end
		if self.followTarget.guid then
			self:DoMove(self.followTarget:GetPosition())
		else
			self:DoMove(self.followTarget)
		end
	end
	function Thing:ClearFollowTarget()
		if self.followTarget and self.followTarget.guid then
			local vo = self.followTarget.vo
			if vo then
				vo:RemoveEventListener(self.target_pos_change_handler)
			end
		end
		self.followTarget = nil
	end

	function Thing:SetAims(obj) -- 设置仇恨目标
		self.aims = obj
	end
	function Thing:GetAims() -- 获得仇恨目标
		if ToLuaIsNull(self.gameObject) then return nil end
		if not self.aims or ToLuaIsNull(self.aims.gameObject) then return nil end
		if self.aims.vo == nil or self.aims.vo.die then return nil end
		return self.aims
	end

	function Thing:SetBattle(battle) -- 设置战斗信息(battle唯一id, battle.info)
		if self.battle then
			self.battle = nil
		end
		self.battle = battle
	end

	function Thing:GetBattle()
		return self.battle
	end

	function Thing:GetBattleInfo()
		if self.battle then
			return self.battle.info
		end
		return nil
	end

	function Thing:IsAutoMove()
		if self.battle then
			return self.battle.autoMove
		end
		return false
	end


-- mat render shader
	function Thing:GetBody() -- 身体
		if not self.body then
			if not self.GetGameObject or not self:GetGameObject() then return nil end
			if self.modelId == 0 or not self.modelId then return nil end
			self.body = self.transform:Find("body")
			if self.body == nil then
				self.body = self.transform
			end
		end
		return self.body
	end
	function Thing:GetWeapon01() -- 左手
		if not self.weapon01 then
			if not self:GetGameObject() then return nil end
			if self.modelId == 0 or not self.modelId then return nil end
			self.weapon01 = self.transform:Find("weapon")
			if not self.weapon01 then
				self.weapon01 = self.transform:Find("weapon01")
			end
		end
		return self.weapon01
	end
	function Thing:GetWeapon02() -- 右手
		-- if ToLuaIsNull(self.gameObject) then return nil end
		if not self.weapon02 and not ToLuaIsNull(self.gameObject) then
			if self.modelId == 0 or not self.modelId then return nil end
			self.weapon02 = self.transform:Find("weapon02")
		end
		return self.weapon02
	end
	function Thing:GetWing() -- 翅膀位置
		-- if ToLuaIsNull(self.gameObject) then return nil end
		if not self.wing and not ToLuaIsNull(self.gameObject) then
			if self.modelId == 0 or not self.modelId then return nil end
			self.wing = Util.GetChild(self.transform, "wing")
		end
		return self.wing
	end
	function Thing:GetBodyMat()
		if not self.bodyMat then
			if self:GetBody() then
				local render = self:GetBody().gameObject:GetComponent("Renderer")
				if not ToLuaIsNull(render) then
					self.bodyMat = render.material
				end
			end
		end
		return self.bodyMat
	end

	function Thing:HideWeapon()
		if self:GetWeapon01() then
			self:GetWeapon01().gameObject:SetActive(false) 
		end
		if self:GetWeapon02() then
			self:GetWeapon02().gameObject:SetActive(false) 
		end
	end

	function Thing:ShowWeapon()
		if self:GetWeapon01() then
			self:GetWeapon01().gameObject:SetActive(true) 
		end
		if self:GetWeapon02() then
			self:GetWeapon02().gameObject:SetActive(true) 
		end
	end

	function Thing:HideRender()
		if self:IsNPC() then
			self.gameObject:SetActive(false) 
		else
			if self:GetBody() then
				self:GetBody().gameObject:GetComponent("Renderer").enabled = false
				self:HideWeapon()
			end
		end
	end
	function Thing:ShowRender()
		if self:IsNPC() then
			self.gameObject:SetActive(true) 
		else
			if self:GetBody() then
				self:GetBody().gameObject:GetComponent("Renderer").enabled  = true
				self:ShowWeapon()
			end
		end
	end

function Thing:ParseGOName() -- gameObject 名字{标识,modelId}
	if ToLuaIsNull(self.gameObject) then return {} end
	return StringSplit(self.gameObject.name or "", "_")
end

-- 显示头顶UI
function Thing:ShowHeadUi(bool)
	if self.head then
		HeadUIMgr:GetInstance():Show(self.head, bool==true)
	end
end
-- 显示影子
function Thing:ShowShadow(bool)
	if ToLuaIsNull(self.gameObject) then return end
	if ToLuaIsNull(self.shadow) then self.shadow = self.gameObject:GetComponent("FS_ShadowSimple") end
	if not ToLuaIsNull(self.shadow) then self.shadow.enabled = bool end
end

function Thing:__delete()
	if self.head then
		HeadUIMgr:GetInstance():Remove(self.head)
	end
	self.head = nil
	if self.animatorMgr then
		self.animatorMgr:Destroy()
		self.animatorMgr = nil
	end
	self.modelId = nil
	if self.guid then
		RenderMgr.Realse("ColorChange_Render"..self.guid)
	end
	self.guid = nil
	self:ClearFollowTarget()
	self:SetBattle(nil)
	if Stage.inst then
		Stage.inst.onTouchBegin:Remove(Thing.OnClick, self)
	end
	self.aims = nil
	self.body = nil
	self.weapon01 = nil
	self.weapon02 = nil
	self.bodyMat = nil
	self.weapon01Mat = nil
	self.weapon02Mat = nil
	self.transform = nil
	if not ToLuaIsNull(self.gameObject) then
		if self.type == PuppetVo.Type.PLAYER and self.vo  then
			PoolMgr.Cache(PoolMgr.PlayerType, self.vo.mId, self.gameObject)
		elseif self.type == PuppetVo.Type.MONSTER and self.vo then
			PoolMgr.Cache(PoolMgr.MonsterType, self.vo.mId, self.gameObject)
		elseif self.type == PuppetVo.Type.Summon and self.vo then
			PoolMgr.Cache(PoolMgr.MonsterType, self.vo.mId, self.gameObject)
		else
			destroyImmediate(self.gameObject) -- 后期优化使用对象池！
		end
	end
	self.gameObject = nil
	if self.vo then
		self.vo:Destroy()
	end
	self.vo = nil
	self.isMainRole = nil
	self.is_destroy_ = true
	self.shadow = nil
	self.type = nil
end

