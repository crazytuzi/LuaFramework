_G.LoginPlayer = {}
setmetatable(LoginPlayer,{__index = CPlayer})
LoginPlayer.roleEnterState = false	-- 入场状态
LoginPlayer.roleExitState = false	-- 退场状态
LoginPlayer.isShow = false
LoginPlayer.timerKey = nil
function LoginPlayer:new()
	local obj = CPlayer:new()
    setmetatable(obj,{__index = LoginPlayer})
	obj.isAvatarLoaded = false
	obj.recordCreateAct = self.recordCreateAct
	obj.useAvatarLoader = true
    return obj
end

function LoginPlayer:IsSelf()
	return true
end

-- 创建角色的动作加载
function LoginPlayer:recordCreateAct(info)
	local actFile = StoryActionController:GetStoryAnimaFile(7, info.dwProf)
	if actFile and actFile ~= "" then
		local loader = _Loader.new()
		FPrint('resfile/model/player/'..actFile)
		loader:load('resfile/model/player/'..actFile)
	end
	
	actFile = StoryActionController:GetStoryAnimaFile(8, info.dwProf)
	if actFile and actFile ~= "" then
		local loader = _Loader.new()
		FPrint('resfile/model/player/'..actFile)
		loader:load('resfile/model/player/'..actFile)
	end
	
	if info.dwProf == 1 then
		 UILoaderManager:LoadList({"resfile/model/player/zhujue_luoli_chujidaiji.san",
									"resfile/model/player/zhujue_luoli_putongdaiji.san",
									"resfile/model/player/zhujue_luoli_denglu_zhanshi.san",
									"resfile/model/player/zhujue_luoli_denglu_lichang.san",
									"resfile/sound/cre_luolisay.ogg",
									"resfile/sound/cre_luolishow.ogg",
									"resfile/sound/cre_luolidissolve.ogg"})
	elseif info.dwProf == 3 then
		 UILoaderManager:LoadList({"resfile/model/player/zhujue_renzu_chujidaiji.san",
									"resfile/model/player/zhujue_renzu_putongdaiji.san",
									"resfile/model/player/zhujue_renzu_denglu_zhanshi.san",
									"resfile/model/player/zhujue_renzu_denglu_lichang.san",
									"resfile/sound/cre_nanrensay.ogg",
									"resfile/sound/cre_nanrenshow.ogg",
									"resfile/sound/cre_nanrendissolve.ogg"})
	elseif info.dwProf == 4 then
		 UILoaderManager:LoadList({"resfile/model/player/zhujue_yujie_chujidaiji.san",
									"resfile/model/player/zhujue_yujie_putongdaiji.san",
									"resfile/model/player/zhujue_yujie_denglu_daiji.san",
									"resfile/model/player/zhujue_yujie_denglu_zhanshi.san",
									"resfile/model/player/zhujue_yujie_denglu_lichang.san",
									"resfile/sound/cre_yujiesay.ogg",
									"resfile/sound/cre_yujieshow.ogg",
									"resfile/sound/cre_yuejiedissolve.ogg"})
	end
end

-- 加载完成
function LoginPlayer:onAvatarLoadCompleted()
	self.isAvatarLoaded = true
	if self.isShow then
		self:PlayStartAction()
	end
end

-- 播放进场动作
function LoginPlayer:PlayStartAction()
	self.isShow = true
	self:SetPlayVisible(true)
	if not self.isAvatarLoaded then
		-- CLoginScene:OnPlayEnterActEnd()
		return 
	end
	if self.roleEnterState then return end
	local prof = self.playerInfo[enAttrType.eaProf]
	local actFile = StoryActionController:GetStoryAnimaFile(7, prof)
	if not actFile or actFile == "" then
		CLoginScene:OnPlayEnterActEnd()
		return
	end
	-- print(debug.traceback())
	CLoginScene:OnPlayEnterAct()
	self:PlayCameraOrbitStart()
	self.roleEnterState = true
	self.roleExitState = false
	-- 音效	
	if prof == 1 then
		SoundManager:PlaySfx(8015)
	elseif prof == 2 then
		SoundManager:PlaySfx(8017)
	elseif prof == 3 then
		SoundManager:PlaySfx(8016)
	elseif prof == 4 then
		SoundManager:PlaySfx(8018)
	end
	
	self:GetAvatar():ExecAction(actFile,false,function() 
		CameraControl:StopAll()
		CLoginScene:OnPlayEnterActEnd()
		-- self:PlayCameraOrbitIdle()
		-- 音效	
		if prof == UICreateRole.prof then
			if prof == 1 then
				SoundManager:PlaySfx(8019)
			elseif prof == 2 then
				SoundManager:PlaySfx(8021)
			elseif prof == 3 then
				SoundManager:PlaySfx(8020)
			elseif prof == 4 then
				SoundManager:PlaySfx(8022)
			end
		end
	end)
end

-- 播放退出动作
local axis = _Vector3.new(0,0,1)
local currRot = _Vector4.new()
local mat = _Matrix3D.new()
function LoginPlayer:PlayExitAction(playEndFunc)
	self.roleEnterState = false
	CLoginScene:OnPlayExitAct()
	self.isShow = false
	self:SetPlayVisible(false)
	local prof = self.playerInfo[enAttrType.eaProf]
	-- if prof == 1 then
		
		-- mat:mulRotationRight(axis,1.61);
		-- mat:setTranslation(0, 0, 0.15) 
		-- 音效	
		if prof == 1 then
			SoundManager:PlaySfx(8011)
		elseif prof == 2 then
			SoundManager:PlaySfx(8013)
		elseif prof == 3 then
			SoundManager:PlaySfx(8012)
		elseif prof == 4 then
			SoundManager:PlaySfx(8014)
		end
		for i = 1, 4 do 
			CLoginScene.objSceneMap:StopPfxByName('pfx_changjing_denglu0'..i)
		end
		CLoginScene.objSceneMap:PlayerPfxByMat('pfx_changjing_denglu0'..prof, 'pfx_changjing_denglu0'..prof..'.pfx', mat)
		if self.timerKey then
			TimerManager:UnRegisterTimer( self.timerKey )
			self.timerKey = nil
		end
		self.timerKey = TimerManager:RegisterTimer(function()
					if playEndFunc then
						playEndFunc()
					end
				end, 1500, 1)
	-- else
		-- if playEndFunc then
			-- playEndFunc()
		-- end
	-- end
	
	--[[
	self.roleEnterState = false
	if not self.isAvatarLoaded then 
		self.isShow = false
		self:SetPlayVisible(false)  
		FPrint('播放退出动作')
		if playEndFunc then
			playEndFunc()
		end
		return
	end
	if self.roleExitState then 
		return 
	end
	local prof = self.playerInfo[enAttrType.eaProf]
	local actFile = StoryActionController:GetStoryAnimaFile(9, prof)
	if not actFile or actFile == "" then
		self.isShow = false
		self:SetPlayVisible(false)
		FPrint('播放退出动作1')
		if playEndFunc then
			playEndFunc()
		end
		return
	end
	self:GetAvatar():SetDirValue(CLoginScene.selfPos.dir)
	self.roleExitState = true
	self:GetAvatar():ExecAction(actFile,false,function()
		if self.roleExitState then
			if playEndFunc then
				playEndFunc()
			end
			self.isShow = false
			self:SetPlayVisible(false)
			FPrint('播放退出动作2')
		end
	end)--]]
end

--人物可见
function LoginPlayer:SetPlayVisible(bVisible)
	local avatar = self:GetAvatar()
	if avatar and avatar.objNode and avatar.objNode.entity then
		avatar.objNode.visible = bVisible
	end
end
--------------------------------- 镜头轨迹 ------------------------------------

function LoginPlayer:PlayCameraOrbitStart()
	local prof = self.playerInfo[enAttrType.eaProf]
	local function tar( m )
		local playerPos = self:GetPos()
		local mat = _Matrix3D.new( )
		mat:setRotationZ(2.3)
		mat:mulTranslationRight( playerPos.x, playerPos.y, playerPos.z )
		return mat
	end
	if self:IsEnterCamera(prof) then
		local cameraMoveName = 'Camera_kaichang_ruchang_'..prof..'.san'
		CLoginScene:ClearCameraOrbitIdle()
		CameraControl:PlayAnimation(cameraMoveName, tar, false, nil)
	end
end

function LoginPlayer:PlayCameraOrbitIdle()
	-- local prof = self.playerInfo[enAttrType.eaProf]
	-- local function tar( m )
		-- local playerPos = self:GetPos()
		-- local mat = _Matrix3D.new( )
		-- mat:setRotationZ(2.3)
		-- mat:mulTranslationRight( playerPos.x, playerPos.y, playerPos.z )
		-- return mat
	-- end
	-- if self:IsIdleCamera(prof) then
		-- local cameraMoveName = 'Camera_kaichang_daiji_'..prof..'.san'
		-- CameraControl:RecordCamera()
		-- CameraControl:PlayAnimation(cameraMoveName, tar, true, nil)
	-- end
	CLoginScene:PlayCameraOrbitIdle()
end

function LoginPlayer:IsEnterCamera(prof)
	-- if prof == 1 or prof == 2 or prof == 4 then
		-- return true
	-- end
	return false
end

function LoginPlayer:IsIdleCamera(prof)
	-- if prof == 1 or prof == 2 then
		-- return true
	-- end
	return false
end

function LoginPlayer:ClearLoginPlayer()
	if self.timerKey then
		TimerManager:UnRegisterTimer( self.timerKey )
		self.timerKey = nil
	end
end