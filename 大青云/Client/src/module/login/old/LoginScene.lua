_G.CLoginScene = {}

CLoginScene.mapId = 10200003  
CLoginScene.selfPos = {x = 0.00, y = 555, z = -59, dir = math.pi}

-- 角色蹦到高台的时间 应该是不同的 单位毫秒
CLoginScene.jumpTimes = {500, 500, 500, 500}
CLoginScene.jumpStartTime = 0 --开始跳跃的时间
-- CLoginScene.isJump = false
CLoginScene.showTime = 500
-- CLoginScene.forbidtime = 1000
-- CLoginScene.isStartBlender = false
-- CLoginScene.isEndBlender = false

--- 这里既然不要了  我就拿来当玩家初始位置了
CLoginScene.PlayerPos = {{x = -11.2, y = 489.89, z = -67.6, dir = 1.59},
						 {x = -0.09, y = 498.37, z = -66.97, dir = 1.29},
						 {x = 8.68, y = 495.15, z = -67.92, dir = 0.99},
						 {x = 19.49, y = 489.64, z = -67.68, dir = 0.79},
						}

CLoginScene.cameras = {"qn_camera", "xyn_camera", "xr_camera", "ms_camera"}

CLoginScene.Markers = {"qn", "xyn", "xr", "ms"}

CLoginScene.currPlayer = nil
-- CLoginScene.lastPlayer = 0
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
CLoginScene.defaultProf = 0 --2 --  _G.enCreateRoleDefaultProf   默认职业  chager：侯旭东修改 purpose：角色只显示2，4
CLoginScene.soundStateDic = {}		-- 创角音乐
CLoginScene.timerKey = nil
CLoginScene.actTimeOut = 8000
CLoginScene.createRoleTimeKey = nil

CLoginScene.isClear = false
CLoginScene.isCreate = false
CLoginScene.isSceneLoaded = false
CLoginScene.onSceneLoaded = false;

--分配场景管理器
function CLoginScene:Create()
	if self.isCreate then return end
	self.objSceneMap = CSceneMap:new()
    self.currMapId = CLoginScene.mapId
	self.curMapInfo = t_map[CLoginScene.mapId]
	self.curMapInfo.dwMapID = CLoginScene.mapId
	self.curMapInfo.dwDungeonId = 0
	self.isCreate = true
	return true
end

local dif = _Vector3.new()
local featureEyePos = _Vector3.new()
-- 进入场景
local defaultCamera = _Camera.new()
function CLoginScene:EnterScene(roleInfo)
	--载入场景
	if self.isClear then return end
	if self.isSceneLoaded then return end
	self.isSceneLoaded = true
	
	self:PlaySound()
	self.objSceneMap.onSceneLoaded = function()
		local enterLoginSceneMap = function()
			GameController:EnterCreateRole()
			-- 摄像机
			local c1 = self.objSceneMap.objScene.graData:getCamera'camera1'
			local eyePos = _Vector3.new( c1.eye.x, c1.eye.y, c1.eye.z )
			local lPos = _Vector3.new( c1.look.x, c1.look.y, c1.look.z ) 
			defaultCamera.look = lPos
			defaultCamera.fov = c1.fov
			defaultCamera.eye = eyePos
			
			_rd.camera:set(defaultCamera) 
			
			self.DefaultEye = _Vector3.new(_rd.camera.eye.x,_rd.camera.eye.y,_rd.camera.eye.z)
			self.DefaultLook = _Vector3.new(_rd.camera.look.x,_rd.camera.look.y,_rd.camera.look.z)
			CameraControl:RecordCamera()
			
			if roleInfo then
				-- self:PlayCameraOrbitIdle(false)
			end
			
			--光源
			self.objPointLight = nil
			local mapId = CLoginScene.mapId;
			
			local light = Light.GetEntityLight(enEntType.eEntType_Player,mapId);
			-- local point = light.pointlight;
			-- local objPointLight = _PointLight.new();
			-- objPointLight.color = point.color;
			-- objPointLight.power = point.power;
			-- objPointLight.range = point.range;
			-- self.objPointLight = objPointLight;
			
			local sky = light.skylight;
			self.objSkyLight = _SkyLight.new()
			self.objSkyLight.color = sky.color;
			self.objSkyLight.power = sky.power;
			self.objSkyLight.backLight = false
			
			-- local back = light.backskylight;
			-- self.objSkyBackLight = _SkyLight.new()
			-- self.objSkyBackLight.color = back.color;
			-- self.objSkyBackLight.power = back.power;
			-- self.objSkyBackLight.backLight = true;
			
			-- local scene = Light.GetSceneLight(mapId);
			-- _rd.glowFactor = scene.glowFactor;
			-- _rd.lightFactor = scene.lightFactor;
			-- _G.gameGlowFactor = _rd.glowFactor;
			-- local pos = _Vector3.new(0, 0, 40);
			-- _Vector3.add(lPos,pos,self.objPointLight.position);
		end
		
		-- 延时创建角色
		
		if roleInfo then
			enterLoginSceneMap()
			self:CreateScene(roleInfo)
		else
			-- if self.createRoleTimeKey then TimerManager:UnRegisterTimer(self.createRoleTimeKey) end
			-- self.createRoleTimeKey = TimerManager:RegisterTimer(function()
						-- enterLoginSceneMap()
						-- self:CreateScene(roleInfo)
					-- end, 100, 1)
				enterLoginSceneMap()
				self:CreateScene(roleInfo)
		end
		
		if self.objSceneMap.effects then
			local effects = self.objSceneMap.effects;
			for i,effect in ipairs(effects) do
				self.objSceneMap:PlayerPfxByMat(effect.logicname,effect.name,effect.transform);
				effect.playing = true;
			end
		end
	end
    self.objSceneMap:Load(self.curMapInfo, function(node) self:OnSceneRender(node);
		if self.onSceneLoaded then
			self.onSceneLoaded();
			self.onSceneLoaded = nil;
		end;
	end)
end

function CLoginScene:CreateScene(roleInfo)
	-- 进入创角状态
	--[[_Archive.beginRecord() 
	TimerManager:RegisterTimer(function()
		_Archive.endRecord()
		local loginFiles = _Archive:getRecord()
		local str = '';	
		for i,file in ipairs(loginFiles) do
			str = str .. '"'..file ..'",'.. '\r\n';
		end
		WriteLog(LogType.Normal,true,'Record',str);
		-- FTrace(loginFiles)
	end, 5000, 1)]]
	
	-- 添加人物
	if roleInfo then
		self:CreatePlayer(roleInfo.prof, roleInfo, true)
		self.blendPLayer = self.currPlayer;
	else
		self:PlayersEnterScene()
		TimerManager:RegisterTimer(function()
			self:CreatePlayer(_G.enCreateRoleDefaultProf)
		end, 100, 1)
		
		UICreateRole:ResetAutoTimer()
	end
end

-- 鼠标移动
function CLoginScene:OnMouseMove(nXPos,nYPos)
	-- if not self.objPlayer then return end
		
	-- if _sys:isKeyDown(_System.MouseLeft) then
		-- local diffx =  (nXPos -self.gMousex) * 0.005
		-- FPrint(diffx)
		-- local dir = self.objPlayer:GetAvatar():GetDirValue()
		-- dir = dir + diffx
		-- self.objPlayer:GetAvatar():SetDirValue(dir)
	-- end
	
	-- self.gMousex = nXPos self.gMousey = nYPos
end

-- 旋转
function CLoginScene:OnBtnRoleLeftStateChange(state)
	if not self.blendPLayer then return end
	if state == "down" then
		self.roleTurnDir = - 0.05
	elseif state == "release" then
		self.roleTurnDir = 0
	elseif state == "out" then
		self.roleTurnDir = 0
	end
end

--旋转
function CLoginScene:OnBtnRoleRightStateChange(state)
	if not self.blendPLayer then return end
	if state == "down" then
		self.roleTurnDir = 0.05
	elseif state == "release" then
		self.roleTurnDir = 0
	elseif state == "out" then
		self.roleTurnDir = 0
	end
end

--鼠标滚轴
function CLoginScene:OnMouseWheel(fDelta)
	--[[if not self.currPlayer then return end
	if self.IsCamaraMoving then return end
	
	self.IsCamaraMoving = true
	if fDelta > 0 then
		local playerPos = self.currPlayer:GetPos()
		local eyePos = self:GetRollPos(self.FeatureInstance)
		_Vector3.sub(eyePos,playerPos,dif)
		local lPos = _Vector3.new()
		lPos.x = playerPos.x
		lPos.y = playerPos.y
		lPos.z = playerPos.z + 13
		
		_Vector3.add(lPos,dif,featureEyePos)
	
		self:MoveCameraPos(lPos,featureEyePos,500,function() self.IsCamaraMoving = false end)
	else
		local playerPos = self.currPlayer:GetPos()
		local eyePos = self:GetRollPos(self.DefaultInstance)
		local lPos = _Vector3.new(playerPos.x, playerPos.y, playerPos.z + self.DefaultLookZ)
		eyePos.z = eyePos.z + self.DefaultEyeZ
		--self:MoveCameraPos(self.DefaultLook,self.DefaultEye,500,function() self.IsCamaraMoving = false end)
		self:MoveCameraPos(lPos,eyePos,500,function() self.IsCamaraMoving = false end)

	end]]
end

--剧情工具
function CLoginScene:OnKeyDown(dwKeyCode)
	if not _G.isDebug then
		return
	end
    if dwKeyCode == _System.KeyTab then
		if not UIToolsCameraMain:IsShow() then
			UIToolsCameraMain:Show()
		end	
    end
end


local s_vec = _Vector3.new()
-- 创建玩家
function CLoginScene:CreatePlayer(prof, roleInfo, bFirst)
	-- _Archive.beginRecord() 
	-- if not self.roleDic[prof] then
	-- 	self.roleDic[prof] = self:CreateAvatar(prof, roleInfo)
	-- end
	
	-- self.lastPlayer = self.currPlayer and self.currPlayer:GetProf() or 0
	if roleInfo then
		self.currPlayer = self:CreateAvatar(prof, roleInfo)
	else
		self.currPlayer = self:GetLoginPlayer(prof)
	end
	if not self.currPlayer or not self.currPlayer:GetAvatar() then 
		return
	end
	
	if not roleInfo then
		-- self:SetPlayVisible(self.currPlayer, false)
	end
	
	-- 动作
	self.currPlayer:GetAvatar():SetDirValue(CLoginScene.selfPos.dir)
	if bFirst then
		SoundManager:PlaySfx(8018 + self.currPlayer:GetProf(), false, true)
	end
	if not roleInfo then
		CameraControl:Clear()
		-- if self.DefaultEye and self.DefaultLook then
			-- _rd.camera.eye = self.DefaultEye
			-- _rd.camera.look = self.DefaultLook
		-- end
		self:CannelCreateSound()
		self:StopTimer()
		-- self:RemoveRole(self.lastPlayer);
		-- if self.lastPlayer and self.lastPlayer > 0 then
		-- 	-- if self.roleDic[self.lastPlayer] then
		-- 	-- 	-- self.roleDic[self.lastPlayer]:PlayExitAction()
		-- 	-- end
		-- 	-- self.currPlayer:PlayStartAction()
		-- 	-- self:OnPlayEnterActEnd();
		-- 	-- self:StartTimer()
		-- 	-- self.soundStateDic[prof] = true
		-- 	self:SelectPlayerJump(self.currPlayer, bFirst)
		-- else
		-- 	-- self.currPlayer:PlayStartAction()
		-- 	self:OnPlayEnterActEnd();
		-- end
		self:SelectPlayerJump(self.currPlayer, bFirst)
		
		-- self:OnPlayEnterActEnd();
		self:StartTimer()
		self.soundStateDic[prof] = true
	end
	
	-- 添加人物
	-- _Archive.endRecord()
	-- local loginFiles = _Archive:getRecord()
	-- FTrace(loginFiles)
	return true
end

function CLoginScene:CopyPlayerToBlend(player)
	if self.blendPLayer then
		self.blendPLayer:ExitMap()
		self.blendPLayer = nil
		LuaGC();
	end
	local mark = self.objSceneMap.objScene.graData:getMarker(self.Markers[player:GetProf()] .. "_position")
	if not mark then
		return
	end
	self.blendPLayer = CLoginScene:CreateAvatar(player:GetProf())
	if not self.blendPLayer then return end
	-- self.blendPLayer:GetAvatar():SetBlender(0x88FFFFFF)
	self.blendPLayer:GetAvatar().objNode.transform:set(mark)
	self.blendPLayer:SetPlayVisible(true)
	local actFile = StoryActionController:GetStoryAnimaFile(8, player:GetProf())
	if actFile then
		self.blendPLayer:GetAvatar():ExecAction(actFile, true)
	end
	return self.blendPLayer;
end

function CLoginScene:SelectPlayerJump(player, bFirst)
	self.jumpStartTime = GetCurTime()
	self.isJump = true
	local loginPos = CLoginScene.selfPos
	s_vec.x = loginPos.x
	s_vec.y = loginPos.y
	s_vec.z = loginPos.z
	player = self:CopyPlayerToBlend(player)
	local time = not bFirst and CLoginScene.jumpTimes[player:GetProf()] or nil
	if not bFirst then
		local actFile = StoryActionController:GetStoryAnimaFile(3, player:GetProf())
		if actFile then
			local func = nil
			local actFile1 = StoryActionController:GetStoryAnimaFile(7, player:GetProf())
			if actFile1 then
				func = function()
					if player and player:GetAvatar() then
						local prof = player:GetProf()
						SoundManager:PlaySfx(8018 + prof, false, true)
						player:GetAvatar():ExecAction(actFile1)
					end
				end
			end
			SoundManager:StopSfx()
			player:GetAvatar():ExecAction(actFile, false, func)
		end
		Notifier:sendNotification(NotifyConsts.CreateRoleShowUIEffect)
		self:PlayCameraOrbitIdle(player:GetProf())
	end
	player:GetAvatar():SetPos(s_vec, time)
	player:GetAvatar():SetDirValue(loginPos.dir)
end

-- function CLoginScene:RemoveRole(prof)
-- 	if not self.lastPlayer or self.lastPlayer<=0 then
-- 		return;
-- 	end
	
-- 	local role = self.roleDic[prof];
-- 	if not role then
-- 		return;
-- 	end
	
-- 	role:GetAvatar():ExitMap();
-- 	self.roleDic[prof] = nil;
	
-- end

function CLoginScene:OnPlayEnterAct()
	Notifier:sendNotification(NotifyConsts.CreateRoleHideUIEffect)
end

-- 进场动作播放完成
function CLoginScene:OnPlayEnterActEnd()
	-- FPrint('进场动作播放完成')
	CLoginScene:PlayCreatePlayerMusic()
	self:StopTimer()
	Notifier:sendNotification(NotifyConsts.CreateRoleShowUIEffect)
end

local orbitTimeId = nil
local cam = _Camera.new( )	
function CLoginScene:PlayCameraOrbitIdle(prof)
	local c1 = self.objSceneMap.objScene.graData:getCamera(self.cameras[prof])
	if not c1 then return end

	cam.look = _Vector3.new( c1.look.x, c1.look.y, c1.look.z ) 
	cam.eye = _Vector3.new( c1.eye.x, c1.eye.y, c1.eye.z ) 
	cam.fov = c1.fov
	_rd.camera:move(cam, self.jumpTimes[prof])
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
function CLoginScene:AddRoleToScene(objRole)
	-- if self.objPlayer then
		-- self.objPlayer:ExitMap()
	-- end

	if self.DefaultEye and self.DefaultLook then
		_rd.camera.eye = self.DefaultEye
		_rd.camera.look = self.DefaultLook
	end
	
    objRole:EnterMap(self.objSceneMap,CLoginScene.selfPos.x,CLoginScene.selfPos.y,CLoginScene.selfPos.dir)--设置位置
end

--update
local pos = _Vector3.new()
function CLoginScene:Update(dwInterval)
	if self.objSceneMap then
		self.objSceneMap:Update(dwInterval)
	end

	-- for i = 1, 4 do
		-- local player = self.roleDic[i]
		-- if player then
			-- player:Update(dwInterval)
			-- if player == self.currPlayer then
				-- local dir = player:GetAvatar():GetDirValue()
				-- dir = dir + self.roleTurnDir
				-- player:GetAvatar():SetDirValue(dir)
			-- end
		-- end
	-- end
	
	if self.blendPLayer then
		self.blendPLayer:Update(dwInterval)
		local dir = self.blendPLayer:GetAvatar():GetDirValue()
		dir = dir + self.roleTurnDir
		self.blendPLayer:GetAvatar():SetDirValue(dir)
	end

	if self.objPointLight and self.currPlayer then
		pos.x, pos.y, pos.z = 0, 0, 50
		_Vector3.add(self.currPlayer:GetPos(), pos, self.objPointLight.position)
	end
	self:UpdateCameraMove(dwInterval)

	if self.isJump then
		-- if self.lastPlayer and self.lastPlayer > 0 then
		-- 	local player = self.roleDic[self.lastPlayer]
		-- 	if player then
		-- 		local avatar = player:GetAvatar()
		-- 		if GetCurTime() - self.jumpStartTime >= self.showTime + self.forbidtime then
		-- 			-- avatar.objMesh.objBlender = nil
		-- 			self.isJump = false
		-- 			self.isStartBlender = false
		-- 			self.isEndBlender = false
		-- 		elseif not self.isStartBlender and GetCurTime() - self.jumpStartTime < self.showTime/2 then
		-- 			-- if not avatar.objMesh.objBlender then
		-- 				-- avatar.objMesh.objBlender = _Blender.new()
		-- 			-- end
		-- 			-- avatar.objMesh.objBlender:blend(0xffffffff,0x00ffffff,self.showTime/2)
		-- 			self.isStartBlender = true
		-- 		elseif not self.isEndBlender and GetCurTime() - self.jumpStartTime >= self.showTime/2 then
		-- 			-- if not avatar.objMesh.objBlender then
		-- 				-- avatar.objMesh.objBlender = _Blender.new()
		-- 			-- end
		-- 			local mark = self.objSceneMap.objScene.graData:getMarker(self.Markers[player:GetProf()] .. "_position")
		-- 			avatar.objNode.transform:set(mark)
		-- 			--待机动作
		-- 			local actFile = StoryActionController:GetStoryAnimaFile(1, player:GetProf())
		-- 			if actFile then
		-- 				player:GetAvatar():ExecAction(actFile, true)
		-- 			end					
		-- 			-- avatar.objMesh.objBlender:blend(0x00ffffff,0xffffffff,self.showTime/2)
		-- 			self.isEndBlender = true
		-- 		end
		-- 	end
		-- else
		if GetCurTime() - self.jumpStartTime >= self.showTime then
			--第一次走这里 取消跳跃锁定
			self.isJump = false
		end
	end
	
	-- StoryController:Update(dwInterval)
	CPlayerControl:Update(dwInterval)
	CameraControl:onUpdate(dwInterval)
end

local playerMaterial = _Material.new()
playerMaterial:setAmbient( 1.5, 1.5, 1.5, 1 )
playerMaterial:setDiffuse( 0.7, 0.7, 0.7, 1 )


-- 场景render
function CLoginScene:OnSceneRender(node)
	_rd.shadowReceiver = false
    _rd.shadowCaster = false
	
	self:DrawWaterNode(node);
	
    if node.mesh then
		if node.bIsMe then --me
			local mip = _rd.mip
			_rd.mip = false
			
            _Vector3.sub(_rd.camera.look, _rd.camera.eye, self.objSkyLight.direction)
			-- _Vector3.sub(_rd.camera.look, _rd.camera.eye, self.objSkyBackLight.direction)	
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
			-- if self.objSkyLight.power ~=0 then _rd:popLight() end
            _rd:popMaterial()
            if node.mesh.objBlender then
      			_rd:popBlender()
   			end
			_rd.mip = mip
		else --others
			-- if self.objPointLight.power ~= 0 then 
			-- 	_rd:useLight(self.objPointLight)
			-- end
			_rd.shadowReceiver = true
			node.mesh:drawMesh()
			_rd.shadowReceiver = false
			-- if self.objPointLight.power ~= 0 then
			-- 	_rd:popLight()
			-- end
		end
	elseif node.terrain then
		-- if self.objPointLight.power ~= 0 then 
		-- 	_rd:useLight(self.objPointLight)
		-- end
		_rd.shadowReceiver = true
		node.terrain:draw()
		_rd.shadowReceiver = false
		-- if self.objPointLight.power ~= 0 then
		-- 	_rd:popLight()
		-- end
    end

end

function CLoginScene:DrawWaterNode(node)
	for i, v in ipairs(self.objSceneMap.objScene.graData:getWaters()) do
		if node.name and node.isWaterReflecter then
			if _and(v.mode, _Water.Reflect) > 0 and v:reflectionBegin() then
				if node.mesh then
					node.mesh:drawMesh()
				end
				if node.terrain then
					node.terrain:draw()
				end
				v:reflectionEnd()
			end
		end
		if node.name and node.isWaterRefracter then
			if _and(v.mode, _Water.Refract) > 0 and v:refractionBegin() then
				if node.mesh then
					node.mesh:drawMesh();
				end
				if node.terrain then
					node.terrain:draw();
				end
				v:refractionEnd()
			end
		end
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
	-- _rd.camera:set(defaultCamera) 
	self.isClear = true
	if self.objSceneMap then
		self.objSceneMap:Unload()
		self.objSceneMap = nil
	end
	if self.createRoleTimeKey then
		TimerManager:UnRegisterTimer( self.createRoleTimeKey )
		self.createRoleTimeKey = nil
	end
	if orbitTimeId then TimerManager:UnRegisterTimer(orbitTimeId) end
	GameController:ExitCreateRole()
	CameraControl:Clear()
	self:StopTimer()
	for k,role in pairs(self.roleDic) do
		role:ExitMap()
		role.objAvatar = nil
		role = nil
	end
	if self.blendPLayer then
		self.blendPLayer:ExitMap()
		self.blendPLayer = nil
	end
	self.currPlayer = nil
	-- self.lastPlayer = nil
	
	self:StopSound()
    self.objPointLight = nil
    self.objSkyLight = nil
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

function CLoginScene:OnMouseMove(nXPos,nYPos)
    if _sys:isKeyDown(_System.MouseMiddle) then
        if  _sys:isKeyDown(_System.KeyAlt) then
            local diffx =  (nXPos -self.gMousex) / 200;
            _rd.camera:movePhi(diffx);

            local diffy =  (nYPos -self.gMousey) / 200;
            _rd.camera:moveTheta(diffy);
        end
    end
    self.gMousex = nXPos; self.gMousey = nYPos;

    -- if not CPlayerMap:GetSceneMap() then
		-- return;
	-- end;
	
	-- local ray = _rd:buildRay( nXPos,nYPos);
	-- if not ray then
		-- return;
	-- end;
	-- local picked = CPlayerMap:GetSceneMap():DoRayQuery(ray);
	-- if ( not picked or not picked.node ) then
		-- CPlayerControl:OnMouseOut()
		-- return
	-- end
	-- if CPlayerControl.objMoveNode ~= picked.node then
		-- CPlayerControl:OnMouseOut()
		-- CPlayerControl:OnMouseOver(picked.node)
	-- end
end

function CLoginScene:OnMouseDown(nButton,nXPos,nYPos)
	-- FPrint('点击舞台...')
	UICreateRole:ResetAutoTimer()
end;

function CLoginScene:CreateAvatar(prof, roleInfo,sketch)
	local Showcfg = t_playerinfo[prof]
	if not Showcfg then return end
	local sMeInfo = {}
	if roleInfo then
		sMeInfo = {
			dwProf = roleInfo.prof,
			dwRoleID = roleInfo.roleID,
			dwArms = roleInfo.arms,
			dwDress = roleInfo.dress,
			dwShoulder = roleInfo.shoulder,
			dwFashionsHead = roleInfo.fashionshead,
			dwFashionsHead = roleInfo.fashionshead,
			dwFashionsArms = roleInfo.fashionsarms,
			dwFashionsDress = roleInfo.fashionsdress,
			dwWing = roleInfo.wing,
			suitflag = roleInfo.suitflag,
			shenwuId = roleInfo.shenwuId,
		}
	else
		sMeInfo = {dwProf = prof,dwRoleID = 1,dwArms=Showcfg.create_arm, dwDress=Showcfg.create_dress,dwShoulder=Showcfg.create_shoulder}
	end
	
	if isDebug and _G.isRecordRes then
		_Archive:beginRecord();
	end
	local createRole = LoginPlayer:new()
	createRole.sketch = sketch;
	createRole:Create(sMeInfo, nil)
	createRole.isShowHeadBoard = false
	self:AddRoleToScene(createRole)
	local objAvatar = createRole:GetAvatar()
	objAvatar.dwRotTime = 150
	objAvatar.objNode.bIsMe = true
	-- objAvatar.objNode.aabbShow = 0.1
	objAvatar.objSkeleton:ignoreShake(false)
	--登陆场景开启法线贴图
	-- objAvatar:setBumpMap(true)			--For New
	
	-- if roleInfo and roleInfo.wuhun > 0 then
	-- 	SpiritsUtil:SetWuhunFushengPfx(roleInfo.wuhun,roleInfo.prof,objAvatar)
	-- end
	
	objAvatar:ResetShenwuPfx()

	-- if prof == 3 or prof == 4 then
	-- 	local actFile = StoryActionController:GetStoryAnimaFileOld(8, prof)
	-- 	if actFile and actFile ~= "" then
	-- 		objAvatar:SetIdleAction(actFile, true)
	-- 	end
	-- end
	if isDebug and _G.isRecordRes then
		_Archive:endRecord()
		local recordlist = _Archive:getRecord();
		local file = _File.new();
		file:create("record/loginplayer/"..prof..".txt" );
		for _,f in ipairs(recordlist) do
			file:write(f .. "\r");
		end
		file:close();
	end
	return createRole
end

----------------------------------------------------------------这里是新的选角场景--------------------------------------------------------------------
function CLoginScene:PlayersEnterScene()
	for i = 1, 4 do
		local Player = self:GetLoginPlayer(i,true)
		if Player and Player:GetAvatar() then
			local mark = self.objSceneMap.objScene.graData:getMarker(self.Markers[Player:GetProf()] .. "_position")
			if not mark then
				return
			end
			Player:GetAvatar().objNode.transform:set(mark)
			Player:SetPlayVisible(true)
			Player:GetAvatar():SetBlender(0x88FFFFFF)
			local actFile = StoryActionController:GetStoryAnimaFile(1, Player:GetProf())
			if actFile then
				Player:GetAvatar():ExecAction(actFile, true)
			end
		end
	end
end

function CLoginScene:GetLoginPlayer(prof,sketch)
	if not self.roleDic[prof] then
		self.roleDic[prof] = self:CreateAvatar(prof,nil,sketch)
	end
	return self.roleDic[prof]
end

function CLoginScene:EngineUpdate(e)
	if self.objSceneMap then
		self.objSceneMap:EngineUpdate(e);
	end
end