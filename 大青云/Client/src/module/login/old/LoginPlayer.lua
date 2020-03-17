_G.LoginPlayer = {}
LoginPlayer.roleEnterState = false	-- 入场状态
LoginPlayer.roleExitState = false	-- 退场状态
LoginPlayer.isShow = false
setmetatable(LoginPlayer,{__index = CPlayer})
function LoginPlayer:new()
	local obj = CPlayer:new()
	obj.isAvatarLoaded = false
	obj.recordCreateAct = self.recordCreateAct
	obj.sketch = false;
    setmetatable(obj,{__index = LoginPlayer})
    return obj
end

-- 创建角色的动作加载
function LoginPlayer:recordCreateAct(info)
	local actFile = StoryActionController:GetStoryAnimaFileOld(7, info.dwProf)
	if actFile and actFile ~= "" then
		local loader = _Loader.new()
		FPrint('resfile/model/player/'..actFile)
		loader:load('resfile/model/player/'..actFile)
	end
	
	actFile = StoryActionController:GetStoryAnimaFileOld(9, info.dwProf)
	if actFile and actFile ~= "" then
		local loader = _Loader.new()
		FPrint('resfile/model/player/'..actFile)
		loader:load('resfile/model/player/'..actFile)
	end
	
	-- if self:IsEnterCamera(info.dwProf) then
		-- actFile = 'Camera_kaichang_ruchang_'..info.dwProf..'.san'
		-- local loader = _Loader.new()
		-- loader:load('resfile/cameramov/'..actFile)
	-- end
	
	-- if self:IsIdleCamera(info.dwProf) then
		-- actFile = 'Camera_kaichang_daiji_'..info.dwProf..'.san'
		-- local loader = _Loader.new()
		-- loader:load('resfile/cameramov/'..actFile)
	-- end
	
	if info.dwProf == 1 then
		 UILoaderManager:LoadList({
									"resfile/cameramov/camera_kaichang_ruchang_1.san",
									"resfile/model/player/zhujue_luoli_chujidaiji.san",
									"resfile/model/player/zhujue_luoli_putongdaiji.san",
									"resfile/model/player/zhujue_luoli_denglu_chuchang_old.san",
									"resfile/model/player/zhujue_luoli_denglu_lichang_old.san",
									"resfile/sound/cre_luolisay.ogg",
									"resfile/sound/cre2_luoli1.ogg",
									"resfile/sound/cre2_luoli2.ogg",
									"resfile/sound/cre2_luoli3.ogg"})
	elseif info.dwProf == 3 then
		 UILoaderManager:LoadList({
									"resfile/cameramov/camera_kaichang_ruchang_3.san",
									"resfile/model/player/zhujue_renzu_chujidaiji.san",
									"resfile/model/player/zhujue_renzu_putongdaiji.san",
									"resfile/model/player/zhujue_renzu_denglu_daiji_old.san",
									"resfile/model/player/zhujue_renzu_denglu_chuchang_old.san",
									"resfile/model/player/zhujue_renzu_denglu_lichang_old.san",
									"resfile/sound/cre_nanrensay.ogg",
									"resfile/sound/cre2_nanren1.ogg",
									"resfile/sound/cre2_nanren2.ogg",
									"resfile/sound/cre2_nanren3.ogg",
									"resfile/sound/cre2_nanren4.ogg"})
	elseif info.dwProf == 4 then
		 UILoaderManager:LoadList({
									"resfile/cameramov/camera_kaichang_ruchang_4.san",
									"resfile/model/player/zhujue_yujie_chujidaiji.san",
									"resfile/model/player/zhujue_yujie_putongdaiji.san",
									"resfile/model/player/zhujue_yujie_denglu_daiji_old.san",
									"resfile/model/player/zhujue_yujie_denglu_chuchang_old.san",
									"resfile/model/player/zhujue_yujie_denglu_lichang_old.san",
									"resfile/sound/cre_yujiesay.ogg",
									"resfile/sound/cre2_yujie1.ogg",
									"resfile/sound/cre2_yujie2.ogg",
									"resfile/sound/cre2_yujie3.ogg",
									"resfile/sound/cre2_yujie4.ogg"})
	end
end

function LoginPlayer:Create(info,disabledEquipAct)
	self.dwRoleID = info.dwRoleID
	self.objAvatar = CPlayerAvatar:new()
	self.objAvatar.sketch = self.sketch;
	if disabledEquipAct then
		self.objAvatar.useAct = false;
	end
	if not self.objAvatar:Create(info.dwRoleID, info.dwProf) then
		Debug("CPlayer:Create Create Role Error by Create")
		return false
	end
	self:InitPlayerInfo(info) --初始化playerInfo
	--设置装备
	info.dwHorseID = MountUtil:GetModelIdByLevel(info.dwHorseID or 0, info.dwProf)
	if not self:DefShowInfo(info) then
		Debug("CPlayer:Create Set Default Equip Error")
		return  false
	end
	
	if self.sketch then
		self.objAvatar:StopAllPfx();
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
		CLoginScene:OnPlayEnterActEnd()
		return 
	end
	if self.roleEnterState then return end
	local prof = self.playerInfo[enAttrType.eaProf]
	local actFile = StoryActionController:GetStoryAnimaFileOld(7, prof)
	if not actFile or actFile == "" then
		CLoginScene:OnPlayEnterActEnd()
		return
	end
	-- print(debug.traceback())
	CLoginScene:OnPlayEnterAct()
	-- self:PlayCameraOrbitStart()
	self.roleEnterState = true
	self.roleExitState = false
	
	self:GetAvatar():ExecAction(actFile,false,function() 
		CameraControl:StopAll()
		CLoginScene:OnPlayEnterActEnd()
		-- self:PlayCameraOrbitIdle()		
	end)
end

-- 播放退出动作
function LoginPlayer:PlayExitAction()
	if not self.isAvatarLoaded then 
		self.isShow = false
		self:SetPlayVisible(false)  
		return
	end
	if self.roleExitState then return end
	
	local prof = self.playerInfo[enAttrType.eaProf]
	local actFile = StoryActionController:GetStoryAnimaFileOld(9, prof)
	if not actFile or actFile == "" then
		self.isShow = false
		self:SetPlayVisible(false)
		return
	end
	self:GetAvatar():SetDirValue(CLoginScene.selfPos.dir)
	self.roleExitState = true
	self.roleEnterState = false
	
	--退场动作完音效
	-- if prof == 1 then
		-- SoundManager:PlaySfx(8081)
	-- elseif prof == 2 then
		-- SoundManager:PlaySfx(8084)
	-- elseif prof == 3 then
		-- SoundManager:PlaySfx(8088)
	-- elseif prof == 4 then
		-- SoundManager:PlaySfx(8093)
	-- end
	self:GetAvatar():ExecAction(actFile,false,function()
		if self.roleExitState then
			self.isShow = false
			self:SetPlayVisible(false)
		end
		
		
	end)
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
	-- CLoginScene:PlayCameraOrbitIdle()
end

function LoginPlayer:IsEnterCamera(prof)
	return true
end

function LoginPlayer:IsIdleCamera(prof)
	-- if prof == 1 or prof == 2 then
		-- return true
	-- end
	return false
end