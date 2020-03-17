_G.CLoginScene = {}

CLoginScene.mapId = 10200002  
-- CLoginScene.selfPos = {x = 150, y = 151, z = 40, dir = 2.3}
CLoginScene.selfPos = {x = 0, y = 0, z = 0.15, dir = 1.61}

-- 角色蹦到高台的时间 应该是不同的 单位毫秒
CLoginScene.jumpTimes = {1200, 1200, 1200, 1200}
CLoginScene.jumpStartTime = 0 --开始跳跃的时间
CLoginScene.isJump = false
CLoginScene.showTime = 1200

--- 这里既然不要了  我就拿来当玩家初始位置了
CLoginScene.PlayerPos = {{x = -40, y = 30, z = 0.15, dir = 1.59},
						 {x = -40, y = 10, z = 0.15, dir = 1.29},
						 {x = -40, y = -10, z = 0.15, dir = 0.99},
						 {x = -40, y = -30, z = 0.15, dir = 0.79},
						}

CLoginScene.currPlayer = nil
CLoginScene.lastPlayer = 0
CLoginScene.actId = 7
CLoginScene.gMousex = 0
CLoginScene.gMousey = 0

CLoginScene.backMusicId = 1001

CLoginScene.DefaultEye = nil
CLoginScene.DefaultLook = nil
CLoginScene.DefaultInstance = -50
CLoginScene.FeatureInstance = -20
CLoginScene.IsCamaraMoving = false
CLoginScene.dummy1 = nil
CLoginScene.dummy2 = nil
CLoginScene.aabb = nil

CLoginScene.DefaultLookZ = 10		--look点的z轴偏移
CLoginScene.DefaultEyeZ = 10		--eye点的z轴偏移	
CLoginScene.StartDis = -55			--开始时距离
CLoginScene.EndDis = -30			--结束时距离
CLoginScene.StartOffsetZ = 0		--开始时z的偏移量
CLoginScene.EndOffsetZ = 0			--结束时z的偏移量
CLoginScene.AutoEyePos = 2/3		--摄像机eye点相对人的位置
CLoginScene.AutoLookPos = 3/4		--摄像机look点相对人的位置

CLoginScene.roleTurnDir = 0			--旋转角度

CLoginScene.roleDic = {}			-- 角色缓存
CLoginScene.soundStateDic = {}		-- 创角音乐
CLoginScene.timerKey = nil
CLoginScene.actTimeOut = 8000
CLoginScene.createRoleTimeKey = nil
-- CLoginScene.sceneWater = nil
CLoginScene.rotateSpeed = 0.015

CLoginScene.isClear = false
--分配场景管理器
function CLoginScene:Create()
	self.objSceneMap = CSceneMap:new()
    self.currMapId = CLoginScene.mapId
	self.curMapInfo = t_map[CLoginScene.mapId]
	self.curMapInfo.dwMapID = CLoginScene.mapId
	self.curMapInfo.dwDungeonId = 0
	return true
end

local dif = _Vector3.new()
local featureEyePos = _Vector3.new()
-- 进入场景
function CLoginScene:EnterScene(roleInfo)
	--载入场景
	self:PlaySound()
	self.objSceneMap.onSceneLoaded = function()
		if self.isClear then return end
	
		GameController:EnterCreateRole()
		-- 摄像机
		-- local playerPos = self.currPlayer:GetPos()
		-- local eyePos = self:GetRollPos(self.DefaultInstance)
		-- local lPos = _Vector3.new(CLoginScene.selfPos.x,CLoginScene.selfPos.y,CLoginScene.selfPos.z + self.DefaultLookZ)
		-- _rd.camera.look = lPos
		-- eyePos.z = eyePos.z + self.DefaultEyeZ
		-- _rd.camera.eye = eyePos
		
		local defaultCamera = self.objSceneMap.objScene.graData:getCamera'shijiao01'
		-- self.sceneWater = self.objSceneMap.objScene.graData:getWater(1)
		_rd.camera.eye = defaultCamera.eye
		_rd.camera.look = defaultCamera.look
		_rd.camera.fov = defaultCamera.fov
		
		self.DefaultEye = _Vector3.new(_rd.camera.eye.x,_rd.camera.eye.y,_rd.camera.eye.z)
		self.DefaultLook = _Vector3.new(_rd.camera.look.x,_rd.camera.look.y,_rd.camera.look.z)
		CameraControl:RecordCamera()
		
		-- if roleInfo then
			-- self:PlayCameraOrbitIdle(true)
		-- end
		
		--光源
		self.objPointLight = nil
		local mapId = CLoginScene.mapId;
		
		local light = Light.GetEntityLight(enEntType.eEntType_Player,mapId);
		local point = light.pointlight;
		local objPointLight = _PointLight.new();
		objPointLight.color = point.color;
		objPointLight.power = point.power;
		objPointLight.range = point.range;
		self.objPointLight = objPointLight;
		
		local sky = light.skylight;
		self.objSkyLight = _SkyLight.new()
		self.objSkyLight.color = sky.color;
		self.objSkyLight.power = sky.power;
		self.objSkyLight.backLight = false
		
		local back = light.backskylight;
		self.objSkyBackLight = _SkyLight.new()
		self.objSkyBackLight.color = back.color;
		self.objSkyBackLight.power = back.power;
		self.objSkyBackLight.backLight = true;
		
		local scene = Light.GetSceneLight(mapId);
		_rd.glowFactor = scene.glowFactor;
		_rd.lightFactor = scene.lightFactor;
		_G.gameGlowFactor = _rd.glowFactor;
		local pos = _Vector3.new(0, 0, 40);
		_Vector3.add(lPos,pos,self.objPointLight.position);
		
		-- 延时创建角色
		self.createRoleTimeKey = TimerManager:RegisterTimer(function()
					self:CreateScene(roleInfo)
				end, 100, 1)

	end
    self.objSceneMap:Load(self.curMapInfo, function(node) self:OnSceneRender(node) end)
end

function CLoginScene:CreateScene(roleInfo)
	-- 进入创角状态
	-- _Archive.beginRecord() 
	-- TimerManager:RegisterTimer(function()
		-- _Archive.endRecord()
		-- local loginFiles = _Archive:getRecord()
		-- FTrace(loginFiles)
	-- end, 5000, 1)
	
	-- 添加人物
	if roleInfo then
		local c1 = self.objSceneMap.objScene.graData:getCamera('camera'..roleInfo.prof)
		if self.DefaultEye and self.DefaultLook then
			_rd.camera.eye = self.DefaultEye
			_rd.camera.look = self.DefaultLook
		end
		self:CreatePlayer(roleInfo.prof, roleInfo)
		self.currPlayer = self.roleDic[roleInfo.prof]
	else
		-- self:CreatePlayer(_G.enCreateRoleDefaultProf)
		StoryController.isHideUI = true
		StoryController:StoryStartMsg('denglu1002', function() 
			self:PlayersEnterScene()
			self:SelectPlayer(_G.enCreateRoleDefaultProf, true)
			UICreateRole:ResetAutoTimer()
			Notifier:sendNotification(NotifyConsts.CreateRoleShowUIEffect)
		end)
		
		-- TimerManager:RegisterTimer(function()			
		-- end, 2000, 1)
	end
end

-- 旋转
function CLoginScene:OnBtnRoleLeftStateChange(state)
	if not self.currPlayer then return end
	if state == "down" then
		self.roleTurnDir = - CLoginScene.rotateSpeed
	elseif state == "release" then
		self.roleTurnDir = 0
	elseif state == "out" then
		self.roleTurnDir = 0
	end
end

--旋转
function CLoginScene:OnBtnRoleRightStateChange(state)
	if not self.currPlayer then return end
	if state == "down" then
		self.roleTurnDir = CLoginScene.rotateSpeed
	elseif state == "release" then
		self.roleTurnDir = 0
	elseif state == "out" then
		self.roleTurnDir = 0
	end
end




-- 创建玩家
CLoginScene.IsShowReflection = true
function CLoginScene:CreatePlayer(prof, roleInfo)
	-- _Archive.beginRecord() 
	
	if not self.roleDic[prof] then
		local Showcfg = t_playerinfo[prof]
		local sMeInfo = {}
		if roleInfo then
			sMeInfo = {
				dwProf = roleInfo.prof,
				dwRoleID = roleInfo.roleID,
				dwArms = roleInfo.arms,
				dwDress = roleInfo.dress,
				dwFashionsHead = roleInfo.fashionshead,
				dwFashionsHead = roleInfo.fashionshead,
				dwFashionsArms = roleInfo.fashionsarms,
				dwFashionsDress = roleInfo.fashionsdress,
				dwWing = roleInfo.wing,
				suitflag = roleInfo.suitflag
			}
		else
			sMeInfo = {dwProf = prof,dwRoleID = 1,dwArms=Showcfg.create_arm, dwDress=Showcfg.create_dress}
		end
	
		local createRole = LoginPlayer:new(sMeInfo.dwRoleID)
		createRole:Create(sMeInfo)
		createRole.isShowHeadBoard = false
		self:AddRoleToScene(createRole, sMeInfo.dwProf)
		self.roleDic[prof] = createRole
		local objAvatar = createRole:GetAvatar()
		objAvatar.dwRotTime = 150
		objAvatar.objNode.bIsMe = true
		-- objAvatar.objNode.aabbShow = 0.1
		objAvatar.objSkeleton:ignoreShake(false)
			
		if roleInfo and roleInfo.wuhun > 0 then
			SpiritsUtil:SetWuhunFushengPfx(roleInfo.wuhun,roleInfo.prof,objAvatar)
		end
		
		local actFile = StoryActionController:GetStoryAnimaFile(8, prof)
		if actFile and actFile ~= "" then
			objAvatar:SetIdleAction(actFile, true)
		end
		if not roleInfo then
			createRole:SetPlayVisible(false)
		end
	end
	
		
	
	-- 添加人物
	-- _Archive.endRecord()
	-- local loginFiles = _Archive:getRecord()
	-- FTrace(loginFiles)
	return true
end

local s_vec = _Vector3.new()
function CLoginScene:SelectPlayer(prof, bFirst)
	if self.isJump then
		--上一个选择的角色正在跳跃 不让选
		return
	end
	self.lastPlayer = self.currPlayer and self.currPlayer:GetProf() or 0
	self.currPlayer = self:GetLoginPlayer(prof)
	if not self.currPlayer or not self.currPlayer:GetAvatar() then 
		return
	end

	CameraControl:Clear()
	if self.DefaultEye and self.DefaultLook then
		_rd.camera.eye = self.DefaultEye
		_rd.camera.look = self.DefaultLook
	end
	
	if self.lastPlayer and self.lastPlayer > 0 then
		if self.roleDic[self.lastPlayer] then
			--这里让出现的角色退回去 并且新角色到指定地点
			self:SelectPlayerJump(self.currPlayer, bFirst)

			-- self.roleDic[self.lastPlayer]:PlayExitAction(function() 
			-- 	if not self.currPlayer or not self.currPlayer:GetAvatar() then 
			-- 		return
			-- 	end
	
			-- 	self.currPlayer:GetAvatar():SetPos({CLoginScene.selfPos.x,CLoginScene.selfPos.y,CLoginScene.selfPos.z})
			-- 	self.currPlayer:GetAvatar():SetDirValue(CLoginScene.selfPos.dir)
			-- self.currPlayer:PlayStartAction()					
			self.soundStateDic[prof] = true
			-- end)
		end
	else
		-- 这里处理选中角色到指定地点
		-- self.currPlayer:GetAvatar():SetPos({CLoginScene.selfPos.x,CLoginScene.selfPos.y,CLoginScene.selfPos.z})
		-- self.currPlayer:GetAvatar():SetDirValue(CLoginScene.selfPos.dir)
		-- self.currPlayer:PlayStartAction()	
		self:SelectPlayerJump(self.currPlayer, bFirst)		
	end
end

function CLoginScene:SelectPlayerJump(player, bFirst)
	self.jumpStartTime = GetCurTime()
	self.isJump = true
	local loginPos = CLoginScene.selfPos
	s_vec.x = loginPos.x
	s_vec.y = loginPos.y
	s_vec.z = loginPos.z
	local time = not bFirst and CLoginScene.jumpTimes[player:GetProf()] or nil
	player:GetAvatar():SetPos(s_vec, time)
	player:PlayStartAction()
end

function CLoginScene:OnPlayEnterAct()
	Notifier:sendNotification(NotifyConsts.CreateRoleHideUIEffect)
end

function CLoginScene:OnPlayExitAct()
	Notifier:sendNotification(NotifyConsts.CreateRoleHideUIEffect)
end

-- 进场动作播放完成
function CLoginScene:OnPlayEnterActEnd()
	-- FPrint('进场动作播放完成')
	-- print(debug.traceback())
	CLoginScene:PlayCreatePlayerMusic()
	self:StopTimer()
	-- Notifier:sendNotification(NotifyConsts.CreateRoleShowUIEffect)
end

local orbitTimeId = nil
local cam = _Camera.new( )	
function CLoginScene:PlayCameraOrbitIdle(isPlay)
	local c1 = self.objSceneMap.objScene.graData:getCamera'camera1'
	local c2 = self.objSceneMap.objScene.graData:getCamera'camera2'
	local c3 = self.objSceneMap.objScene.graData:getCamera'camera3'
	local c4 = self.objSceneMap.objScene.graData:getCamera'camera4'
	local c5 = self.objSceneMap.objScene.graData:getCamera'camera5'

	local circle = {
				{time =     0, x = c1.eye.x, y = c1.eye.y, z = c1.eye.z},
				{time = 10000, x = c2.eye.x, y = c2.eye.y, z = c2.eye.z},
				{time = 20000, x = c3.eye.x, y = c3.eye.y, z = c3.eye.z},
				{time = 40000, x = c4.eye.x, y = c4.eye.y, z = c4.eye.z},
				{time = 60000, x = c5.eye.x, y = c5.eye.y, z = c5.eye.z},
				{time = 90000, x = c1.eye.x, y = c1.eye.y, z = c1.eye.z}
			}
	
	if isPlay then
		CameraControl.circleCamera:SetFov(c1.fov)
		CameraControl.circleCamera:SetLook(c1.look.x, c1.look.y, c1.look.z)
		CameraControl:PlayCircle(circle, true)
	else
		-- FPrint('开始缓动到待机视角')
		cam.look = _Vector3.new( c1.look.x, c1.look.y, c1.look.z ) 
		cam.eye = _Vector3.new( c1.eye.x, c1.eye.y, c1.eye.z ) 
		cam.fov = c1.fov
		_rd.camera:move(cam, 1000)	
		
		if orbitTimeId then TimerManager:UnRegisterTimer(orbitTimeId) end
			orbitTimeId = TimerManager:RegisterTimer(function()
				-- FPrint('缓动到待机视角完成 开始呼吸')
				if orbitTimeId then TimerManager:UnRegisterTimer(orbitTimeId) end
				CameraControl.circleCamera:SetFov(c1.fov)
				CameraControl.circleCamera:SetLook(c1.look.x, c1.look.y, c1.look.z)
				CameraControl:PlayCircle(circle, true)
			end,
		1000, 1)
	end		
			
end

function CLoginScene:ClearCameraOrbitIdle()
	if orbitTimeId then TimerManager:UnRegisterTimer(orbitTimeId) end
end

--声音状态全部清空
function CLoginScene:CannelCreateSound()
	for i=1,4 do
		self.soundStateDic[i] = false
	end
end

-- 添加到场景中
function CLoginScene:AddRoleToScene(objRole, prof)
	local playPos = self.selfPos
    objRole:EnterMap(self.objSceneMap,playPos.x,playPos.y,playPos.dir)--设置位置
end

local pos = _Vector3.new()
--pos.x, pos.y, pos.z = 0, 0, 50
local playerMaterial = _Material.new()
playerMaterial:setAmbient( 1.5, 1.5, 1.5, 1 )
playerMaterial:setDiffuse( 0.7, 0.7, 0.7, 1 )

--update
local s_vec1 = _Vector3.new()
function CLoginScene:Update(dwInterval)
	if not self.objSceneMap or not self.objSceneMap.objScene or not self.objSceneMap.objScene.terrain then
		return
	end

	if self.objSceneMap then
		-- self.objSceneMap:Update(dwInterval)
		--然后渲染
		if self.objSceneMap.objScene then
		   if self.objSceneMap.sceneLoaded then
				if RenderConfig.showScene then
					self.objSceneMap.objScene:render();
				end
		   else
				_app.console:print("sceneLoader.progress: " .. self.objSceneMap.sceneLoader.progress)
		   end
		end;
	end

	for i = 1, 4 do
		local player = self.roleDic[i]
		if player then
			player:Update(dwInterval)
			if player == self.currPlayer then
				local dir = player:GetAvatar():GetDirValue()
				dir = dir + self.roleTurnDir
				player:GetAvatar():SetDirValue(dir)
			end
		end
	end
	
	--水的倒影
	-- if self.IsShowReflection then
		-- self.sceneWater:refractionBegin()
		-- self:RenderScene()
		-- self.sceneWater:refractionEnd()

		-- self.sceneWater:reflectionBegin()
		-- self:RenderOther()
		-- self.sceneWater:reflectionEnd()
	-- end
	
	if self.objPointLight and self.currPlayer then
		pos.x, pos.y, pos.z = 0, 0, 50
		-- self.objPointLight.range = self.objPointLight.range + 0.5
		_Vector3.add(self.currPlayer:GetPos(), pos, self.objPointLight.position)
	end

	if self.isJump then
		if self.lastPlayer and self.lastPlayer > 0 then
			local player = self.roleDic[self.lastPlayer]
			if player then
				local loginPos = CLoginScene.PlayerPos[self.lastPlayer]
				s_vec1.x = loginPos.x
				s_vec1.y = loginPos.y
				s_vec1.z = loginPos.z
				player:GetAvatar():SetPos(s_vec1)
				self.isJump = false
			end
		elseif GetCurTime() - self.jumpStartTime >= self.showTime then
			--第一次走这里 取消跳跃锁定
			self.isJump = false
		end
	end
	
	self:UpdateCameraMove(dwInterval)
	StoryController:Update(dwInterval)
	CPlayerControl:Update(dwInterval)
	CameraControl:onUpdate(dwInterval)
end

-- 场景render
function CLoginScene:OnSceneRender(node)
	_rd.shadowReceiver = false
    _rd.shadowCaster = false
	
    if node.mesh then
		if node.bIsMe then --me
			local mip = _rd.mip
			_rd.mip = false

			_Vector3.sub(_rd.camera.look, _rd.camera.eye, self.objSkyLight.direction)
			_Vector3.sub(_rd.camera.look, _rd.camera.eye, self.objSkyBackLight.direction)	
			if self.objSkyLight.power ~=0 then _rd:useLight(self.objSkyLight) end
			
			local light = Light.GetEntityLight(enEntType.eEntType_Player,self.currMapId);
			local material = light.material;
			playerMaterial:setAmbient( material.ambient, material.ambient, material.ambient, material.ambient );
			playerMaterial:setDiffuse( material.diffuse, material.diffuse, material.diffuse, material.diffuse );
			
            _rd:useMaterial(playerMaterial)
            _rd.shadowCaster = true
            if node.mesh.objBlender then
        		_rd:useBlender(node.mesh.objBlender)
    		end
			node.mesh:drawMesh()
			_rd.shadowCaster = false
			if self.objSkyLight.power ~=0 then _rd:popLight() end
			if self.objSkyLight.power ~=0 then _rd:popLight() end
            _rd:popMaterial()
            if node.mesh.objBlender then
      			_rd:popBlender()
   			end
			_rd.mip = mip
			
		else --others
			if self.objPointLight.power ~= 0 then 
				_rd:useLight(self.objPointLight)
			end
			node.mesh:drawMesh()
			if self.objPointLight.power ~= 0 then
				_rd:popLight()
			end
		end
	elseif node.terrain then
		self:RenderScene()
    end
end

function CLoginScene:RenderOther()
	for i,v in pairs(self.objSceneMap.objScene:getNodes()) do
		if v.mesh and v.visible then
			if self.objPointLight.power ~= 0 then 
				_rd:useLight(self.objPointLight)
			end
			
			_rd:pushMatrix3D(v.transform)
			v.mesh:drawMesh()
			for i, v in ipairs(v.mesh:getSubMeshs()) do
				v:drawMesh()
			end
			_rd:popMatrix3D()
			
			if self.objPointLight.power ~= 0 then
				_rd:popLight()
			end
		end
	end
end

function CLoginScene:RenderScene()
	if self.objPointLight.power ~= 0 then 
		_rd:useLight(self.objPointLight)
	end
	_rd:pushMatrix3D(self.objSceneMap.objScene.terrainNode.transform)
	self.objSceneMap.objScene.terrain:draw()
	_rd:popMatrix3D()
	if self.objPointLight.power ~= 0 then
		_rd:popLight()
	end
end

-- 播放背景音乐
function CLoginScene:PlayCreatePlayerMusic(prof)
	if self.soundStateDic[prof] then
		SoundManager:StopBackSfx()
		SoundManager:PlayBackSfx(CLoginScene.backMusicId)
	end
end

--播放场景背景与音乐
function CLoginScene:PlaySound()
	SoundManager:PlayBackSfx(CLoginScene.backMusicId)
end

-- 停止音乐
function CLoginScene:StopSound()
	SoundManager:StopBackSfx()
end

-- 销毁
function CLoginScene:Clear()
	self.isClear = true
	StoryController:OnStorySkip()
	if self.objSceneMap then
		self.objSceneMap:Unload()
		self.objSceneMap = nil
	end
	if orbitTimeId then TimerManager:UnRegisterTimer(orbitTimeId) end
	GameController:ExitCreateRole()
	CameraControl:Clear()
	self:StopTimer()
	if self.createRoleTimeKey then
		TimerManager:UnRegisterTimer( self.createRoleTimeKey )
		self.createRoleTimeKey = nil
	end
	for k,role in pairs(self.roleDic) do
		role:ClearLoginPlayer()
		role:ExitMap()
		role.objAvatar = nil
		role = nil
	end
	self.currPlayer = nil
	self.lastPlayer = nil
	self:StopSound()
    self.objPointLight = nil
    self.objSkyLight = nil
    self.isJump = false
end

--------------------------------- 镜头移动 ------------------------------------
function CLoginScene:GetRollPos(rollDis)
    local pos1 = _Vector3.new()
	local dir = nil
	local pos = nil
	if self.currPlayer then
		dir = self.currPlayer:GetAvatar():GetDirValue()
		pos = self.currPlayer:GetPos()
	else
		dir = CLoginScene.selfPos.dir
		pos = _Vector3.new(CLoginScene.selfPos.x,CLoginScene.selfPos.y,CLoginScene.selfPos.z)
	end
	
    pos1.x = pos.x - rollDis * math.sin(dir)
    pos1.y = pos.y + rollDis * math.cos(dir)
    pos1.z = pos.z
    if not pos1.z then
        return nil
    end
	
    return pos1
end

function CLoginScene:MoveCameraPos(vLookPos,vEyePos,dwTime,funCallBack)
	self.vecOldLook = self.vecOldLook or _Vector3.new(_rd.camera.look.x,_rd.camera.look.y,_rd.camera.look.z)  
	self.vecOldEye = self.vecOldEye or _Vector3.new(_rd.camera.eye.x,_rd.camera.eye.y,_rd.camera.eye.z)  

	self.vLookOrbit = self.vLookOrbit or _Orbit.new()
	self.vEyeOrbit = self.vEyeOrbit or _Orbit.new()
	if vLookPos then
		-- FPrint('11')
		self.vLookOrbit:create({
			{time=0,pos=_Vector3.new(_rd.camera.look.x,_rd.camera.look.y,_rd.camera.look.z)},
			{time=dwTime,pos=vLookPos}
		})
	end
	if vEyePos then
		-- FPrint('12')
		self.vEyeOrbit:create({
			{time=0,pos=_Vector3.new(_rd.camera.eye.x,_rd.camera.eye.y,_rd.camera.eye.z)},
			{time=dwTime,pos=vEyePos}
		})
	end
	if type(funCallBack)=="function" then
		CTimer:AddTimer( dwTime, false, funCallBack )
	end
	self.bMoving = true
end

function CLoginScene:UpdateCameraMove(dwInterval)
	if self.bMoving then
		self.vLookOrbit:update(dwInterval)
		self.vEyeOrbit:update(dwInterval)
		if self.vLookOrbit.over~=true then
			_rd.camera.look = self.vLookOrbit.pos
		end
		if self.vEyeOrbit.over~=true then
			_rd.camera.eye = self.vEyeOrbit.pos
		end
		
		if (self.vLookOrbit.over==true) and (self.vEyeOrbit.over) then
			self.bMoving = false
			if type(self.funCallBack)=="function" then
				self.funCallBack()
			end
		end
	end
end




--------------------------------- 超时处理 ------------------------------------

function CLoginScene:StopTimer()
	-- if self.timerKey then
		-- TimerManager:UnRegisterTimer( self.timerKey )
		-- self.timerKey = nil
	-- end
end

function CLoginScene:StartTimer()
	-- self.timerKey = TimerManager:RegisterTimer( self.OnTimeOut, self.actTimeOut, 1 )
end

--3秒未播放动作 自动弹出ui
function CLoginScene.OnTimeOut()
	-- CLoginScene:StopTimer()
	-- FPrint('NotifyConsts.CreateRoleShowUIEffect2')
	-- Notifier:sendNotification(NotifyConsts.CreateRoleShowUIEffect)
end

------------------------------ 剧情工具-----------------------------------

function CLoginScene:OnMouseMove(nXPos,nYPos)
    if _G.isDebug then
		if _sys:isKeyDown(_System.MouseMiddle) then
			if _G.IsCameraToolsShow and not _sys:isKeyDown(_System.KeyAlt) then
				local dir = _Vector3.sub(_rd.camera.look, _rd.camera.eye)
				local vx = _Vector3.cross(dir,  _rd.camera.up):normalize()
				local vy = _Vector3.cross(dir, vx):normalize()
				local nearx = _Vector3.mul(vx, -(self.gMousex - nXPos) * 0.001)
				local neary = _Vector3.mul(vy,  (self.gMousey - nYPos) * 0.001)
				local movex = _Vector3.mul(nearx, dir:magnitude() / _rd.camera.viewNear)
				local movey = _Vector3.mul(neary, dir:magnitude() / _rd.camera.viewNear)
				local move = _Vector3.add(movex , movey)
				_rd.camera:moveEye(_rd.camera.eye.x + move.x, _rd.camera.eye.y + move.y, _rd.camera.eye.z + move.z)
				_rd.camera:moveLook(_rd.camera.look.x + move.x, _rd.camera.look.y + move.y, _rd.camera.look.z + move.z)
				self.gMousex = nXPos; self.gMousey = nYPos;
			else
				if _sys:isKeyDown(_System.KeyAlt) and _G.IsCameraToolsShow then
					local diffx =  (nXPos -self.gMousex) / 200;
					_rd.camera:movePhi(diffx);

					local diffy =  (nYPos -self.gMousey) / 200;
					_rd.camera:moveTheta(diffy);
				end
			end
		end
		self.gMousex = nXPos; self.gMousey = nYPos;
	end
end

function CLoginScene:OnMouseDown(nButton,nXPos,nYPos)
	-- FPrint('点击舞台...')
	UICreateRole:ResetAutoTimer()
end;

--剧情工具
function CLoginScene:OnKeyDown(dwKeyCode)
	if not _G.isDebug then
		return
	end
	if dwKeyCode == _System.KeyB then--跳过剧情
		for i = 2, 4 do   --chager：侯旭东修改 purpose：角色只显示2，4
			local mainPlayer = CLoginScene:GetLoginPlayer(i)
			if mainPlayer then
				if i ~= _G.enCreateRoleDefaultProf then
					mainPlayer:SetPlayVisible(false)
				end
				local roleAvatar = mainPlayer:GetAvatar()
				if roleAvatar and roleAvatar.objNode then
					roleAvatar:ExecIdleAction()
					roleAvatar.objNode.transform:identity()
				end
			end
		end
		-- StoryController:OnStorySkip()
	end
    if dwKeyCode == _System.KeyTab then
		_debug.monitor = not _debug.monitor
    end
	
	if dwKeyCode == _System.KeyT then
		if not UIToolsCameraMain:IsShow() then
			UIToolsCameraMain:Show()
		end
    end
	
	if dwKeyCode == _System.KeyO then
		GMView:Show();
	end
end

function CLoginScene:OnMouseWheel(fDelta)
	if _G.isDebug and _G.IsCameraToolsShow then
		_rd.camera:moveRadius(fDelta * -0.1 * _rd.camera.radius)
		return
	end
end;

function CLoginScene:GetLoginPlayer(prof)
	if not self.roleDic[prof] then
		-- FPrint('创建的主角..prof')
		self:CreatePlayer(prof)
	end
	-- FPrint('创建的主角1..prof')
	return self.roleDic[prof]
end

----------------------------------------------------------------这里是新的选角场景--------------------------------------------------------------------
local s_vec2 = _Vector3.new()
function CLoginScene:PlayersEnterScene()
	for i = 1, 4 do
		local Player = self:GetLoginPlayer(i)
		if Player and Player:GetAvatar() then
			local pos = CLoginScene.PlayerPos[i]
			s_vec2.x = pos.x
			s_vec2.y = pos.y
			s_vec2.z = pos.z
			Player:GetAvatar():SetPos(s_vec2)
			Player:GetAvatar():SetDirValue(pos.dir)
			Player:SetPlayVisible(true)
		end
	end
end