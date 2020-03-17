_G.UIToolsCamera = BaseUI:new("UIToolsCamera")
UIToolsCamera.step = 1
UIToolsCamera.CurrentCameraVO = nil
UIToolsCamera.cameraLookDif_Vec = nil
-- 场景特效
UIToolsCamera.SceneEffectStr = 'StorySceneEffect_'
UIToolsCamera.StorySceneEffectDic = {}
function UIToolsCamera:Create()
	self:AddSWF("toolsCamara.swf",true,"center")
end

function UIToolsCamera:OnLoaded(objSwf,name)

	objSwf.cameraAniId.text = ''
	objSwf.inputEyeX.text = ''
	objSwf.inputEyeY.text = ''
	objSwf.inputEyeZ.text = ''
	
	objSwf.inputLookX.text = ''
	objSwf.inputLookY.text = ''
	objSwf.inputLookZ.text = ''
	
	objSwf.inputSceneEffect.text = ''
	objSwf.inputNpc.text = ''
	objSwf.inputLast.text = '0'
	objSwf.inputCameraDistance.text = '0'
	objSwf.inputCameraRotateX.text = '0'
	objSwf.inputCameraRotateY.text = '0'
	objSwf.inputShakeTime.text = ''
	objSwf.inputShakeMin.text = ''  
	objSwf.inputShakeMax.text = ''
	objSwf.inputSound.text = ''
	objSwf.inputMax.text = '0'
	objSwf.inputTalk.text = '0'
	
	objSwf.inputPlayerActId.text = ''
	objSwf.checkIsShowUI.selected = true
	objSwf.checkShowNpc.selected = false
	objSwf.checkIsGensuiShijiao.selected = false
	objSwf.checkIsNext.selected = false
	objSwf.checkIsHideMain.selected = false
	objSwf.checkIsLock.selected = false
	objSwf.checkResetRotate.selected = false
	objSwf.checkResetDistance.selected = false
	objSwf.nextByMoveTime.selected = false
	objSwf.inputPatrol.text = ''
	objSwf.inputNPCActCfg.text = ''
	objSwf.inputMyPatrol.text = ''
	objSwf.inputMonsterBorn.text = ''
	objSwf.inputFadeIn.text = ''
	objSwf.inputFadeOut.text = ''
	
	objSwf.TestNpcX.text = ''
	objSwf.TestNpcY.text = ''
	objSwf.TestNpcZ.text = ''
	objSwf.TestNpcDir.text = ''
	objSwf.TestNpcId.text = ''
	objSwf.TestEffectId.text = ''
	objSwf.btnCreateTest.click = function() self:CreateTestNpc() end
	objSwf.btnDelNpc.click = function() self:DelTestNpc() end
	
	objSwf.inputEyeX.textChange = function() self:Lock() self:OnBtnOKClick() end
	objSwf.inputEyeY.textChange = function() self:Lock() self:OnBtnOKClick() end
	objSwf.inputEyeZ.textChange = function() self:Lock() self:OnBtnOKClick() end
	objSwf.inputLookX.textChange = function() self:Lock() self:OnBtnOKClick() end
	objSwf.inputLookY.textChange = function() self:Lock() self:OnBtnOKClick() end
	objSwf.inputLookZ.textChange = function() self:Lock() self:OnBtnOKClick() end
	
	
	objSwf.btnEyeXDel.autoRepeat = true
	objSwf.btnEyeXAdd.autoRepeat = true
	objSwf.btnEyeYDel.autoRepeat = true
	objSwf.btnEyeYAdd.autoRepeat = true
	objSwf.btnEyeZDel.autoRepeat = true
	objSwf.btnEyeZAdd.autoRepeat = true
	objSwf.btnClose.click = function() self:Lock() self:OnBtnCloseClick(); end
	objSwf.btnEyeXDel.click = function() self:Lock() self:OnbtnEyeXDelClick() end
	objSwf.btnEyeXAdd.click = function() self:Lock() self:OnbtnEyeXAddClick() end
	objSwf.btnEyeYDel.click = function() self:Lock() self:OnbtnEyeYDelClick() end
	objSwf.btnEyeYAdd.click = function() self:Lock() self:OnbtnEyeYAddClick() end
	objSwf.btnEyeZDel.click = function() self:Lock() self:OnbtnEyeZDelClick() end
	objSwf.btnEyeZAdd.click = function() self:Lock() self:OnbtnEyeZAddClick() end
	
	objSwf.btnLookXDel.autoRepeat = true
	objSwf.btnLookXAdd.autoRepeat = true
	objSwf.btnLookYDel.autoRepeat = true
	objSwf.btnLookYAdd.autoRepeat = true
	objSwf.btnLookZDel.autoRepeat = true
	objSwf.btnLookZAdd.autoRepeat = true
	objSwf.btnLookXDel.click = function() self:Lock() self:OnbtnLookXDelClick() end
	objSwf.btnLookXAdd.click = function() self:Lock() self:OnbtnLookXAddClick() end
	objSwf.btnLookYDel.click = function() self:Lock() self:OnbtnLookYDelClick() end
	objSwf.btnLookYAdd.click = function() self:Lock() self:OnbtnLookYAddClick() end
	objSwf.btnLookZDel.click = function() self:Lock() self:OnbtnLookZDelClick() end
	objSwf.btnLookZAdd.click = function() self:Lock() self:OnbtnLookZAddClick() end
	objSwf.btnReset.click = function() self:Lock() self:OnbtnResetClick() end
	objSwf.btnSave.click = function() self:OnbtnSaveClick() end
	
	objSwf.btnCameraLock.click = function() 
		local player =  MainPlayerController:GetPlayer()
		local roleAvatar = nil
		if player then
			roleAvatar = player:GetAvatar()
		end
		-- local lookVec = roleAvatar:GetCameraFollowLook()
		
		-- _rd.camera.look.x = lookVec.x
		-- _rd.camera.look.y = lookVec.y
		-- _rd.camera.look.z = lookVec.z
		roleAvatar:SetCameraFollowBySkn()
		
		self:OnbtnResetClick()
		self.cameraLookDif_Vec = _Vector3.new()
				
		 _Vector3.sub(_rd.camera.eye,_rd.camera.look,self.cameraLookDif_Vec)
		 self.CurrentCameraVO.cameraLookDif = {self.cameraLookDif_Vec.x,self.cameraLookDif_Vec.y,self.cameraLookDif_Vec.z} 
	end
end

function UIToolsCamera:Lock()
	local player =  MainPlayerController:GetPlayer()
	if player then
		-- player:GetAvatar():DisableCameraFollow()
	end
end

function UIToolsCamera:OnbtnSaveClick()
	local objSwf = self:GetSWF("UIToolsCamera")
	if not objSwf then return end
	if not self.CurrentCameraVO then SpiritsUtil:Print('当前摄像机为空') return end
	
	self.CurrentCameraVO = self.CurrentCameraVO
	if self.cameraLookDif_Vec then
		self.CurrentCameraVO.cameraLookDif = {self.cameraLookDif_Vec.x,self.cameraLookDif_Vec.y,self.cameraLookDif_Vec.z} 
	end
	self.CurrentCameraVO.eye = {tonumber(objSwf.inputEyeX.text),tonumber(objSwf.inputEyeY.text),tonumber(objSwf.inputEyeZ.text)}
	self.CurrentCameraVO.look = {tonumber(objSwf.inputLookX.text),tonumber(objSwf.inputLookY.text),tonumber(objSwf.inputLookZ.text)} 
	
	if objSwf.inputSceneEffect.text ~= '' then
		self.CurrentCameraVO.sceneEffect = objSwf.inputSceneEffect.text
	else
		self.CurrentCameraVO.sceneEffect = nil
	end
	
	if objSwf.inputNpc.text ~= '' then self.CurrentCameraVO.npcId = toint(objSwf.inputNpc.text) else self.CurrentCameraVO.npcId = nil end
	if objSwf.inputLast.text ~= '' then self.CurrentCameraVO.lastTime = toint(objSwf.inputLast.text) else self.CurrentCameraVO.lastTime = nil  end
	if objSwf.inputCameraDistance.text ~= '' then self.CurrentCameraVO.cameraDistanceSpeed = tonumber(objSwf.inputCameraDistance.text) else self.CurrentCameraVO.cameraDistanceSpeed = nil  end
	if objSwf.inputCameraRotateX.text ~= '' then self.CurrentCameraVO.cameraRotateX = tonumber(objSwf.inputCameraRotateX.text) else self.CurrentCameraVO.cameraRotateX = nil  end
	if objSwf.inputCameraRotateY.text ~= '' then self.CurrentCameraVO.cameraRotateY = tonumber(objSwf.inputCameraRotateY.text) else self.CurrentCameraVO.cameraRotateY = nil  end
	if objSwf.inputShakeTime.text ~= '' then self.CurrentCameraVO.shakeTime = toint(objSwf.inputShakeTime.text) else self.CurrentCameraVO.shakeTime = nil  end
	if objSwf.inputShakeMin.text ~= '' then self.CurrentCameraVO.shakeMin = tonumber(objSwf.inputShakeMin.text) else self.CurrentCameraVO.shakeMin = nil  end
	if objSwf.inputShakeMax.text ~= '' then self.CurrentCameraVO.shakeMax = tonumber(objSwf.inputShakeMax.text) else self.CurrentCameraVO.shakeMax = nil  end
	if objSwf.inputSound.text ~= '' then self.CurrentCameraVO.soundID = objSwf.inputSound.text else self.CurrentCameraVO.soundID = nil  end
	
	if objSwf.inputMax.text ~= '' then self.CurrentCameraVO.maxTime = toint(objSwf.inputMax.text) else self.CurrentCameraVO.maxTime = nil  end
	if objSwf.inputTalk.text ~= '' then self.CurrentCameraVO.talkStr = toint(objSwf.inputTalk.text) else self.CurrentCameraVO.talkStr = nil  end
	if objSwf.inputNpcPos.text ~= '' then self.CurrentCameraVO.playerMovePos = toint(objSwf.inputNpcPos.text) else self.CurrentCameraVO.playerMovePos = nil end
	if objSwf.inputCamaraTarget.text ~= '' then self.CurrentCameraVO.autoCamaraTaget = toint(objSwf.inputCamaraTarget.text) else self.CurrentCameraVO.autoCamaraTaget = nil end
	
	
	if objSwf.inputPlayerActId.text ~= '' then 
		self.CurrentCameraVO.playerActId = objSwf.inputPlayerActId.text
	else
		self.CurrentCameraVO.playerActId = nil
	end
	
	if objSwf.inputPatrol.text ~= '' then
		self.CurrentCameraVO.Patrol = objSwf.inputPatrol.text
	else
		self.CurrentCameraVO.Patrol = nil
	end
	
	if objSwf.inputNPCActCfg.text ~= '' then
		self.CurrentCameraVO.NPCActCfg = objSwf.inputNPCActCfg.text
	else
		self.CurrentCameraVO.NPCActCfg = nil
	end
	
	if objSwf.inputMyPatrol.text ~= '' then
		self.CurrentCameraVO.MyPatrol = toint(objSwf.inputMyPatrol.text)
	else	
		self.CurrentCameraVO.MyPatrol = nil
	end
	
	if objSwf.inputMonsterBorn.text ~= '' then
		self.CurrentCameraVO.MonsterBorn = objSwf.inputMonsterBorn.text
	else	
		self.CurrentCameraVO.MonsterBorn = nil
	end
	
	self.CurrentCameraVO.bIsShowUI = objSwf.checkIsShowUI.selected
	self.CurrentCameraVO.bShowNpc = objSwf.checkShowNpc.selected
	self.CurrentCameraVO.bGensuiShijiao = objSwf.checkIsGensuiShijiao.selected
	self.CurrentCameraVO.bNext = objSwf.checkIsNext.selected
	self.CurrentCameraVO.bIsHideMain = objSwf.checkIsHideMain.selected
	self.CurrentCameraVO.bIsLock = objSwf.checkIsLock.selected
	self.CurrentCameraVO.isResetRotate = objSwf.checkResetRotate.selected
	self.CurrentCameraVO.isResetDistance = objSwf.checkResetDistance.selected
	self.CurrentCameraVO.bResetDirect = objSwf.checkResetDirect.selected
	if objSwf.inputFadeOut.text ~= '' then
		self.CurrentCameraVO.FadeOutTime = objSwf.inputFadeOut.text
	else	
		self.CurrentCameraVO.FadeOutTime = nil
	end
	if objSwf.inputFadeIn.text ~= '' then
		self.CurrentCameraVO.FadeInTime = objSwf.inputFadeIn.text
	else	
		self.CurrentCameraVO.FadeInTime = nil
	end
	self.CurrentCameraVO.bGotoNextByMoveTime = objSwf.nextByMoveTime.selected
	UIToolsCameraMain:SetCamaraList()
end

--配置变动
function UIToolsCamera:OnCfgChange()
	
end

function UIToolsCamera:OnBtnOKClick()
	local objSwf = self:GetSWF("UIToolsCamera")
	if not objSwf then return end

	local veye = _Vector3.new(toint(objSwf.inputEyeX.text),toint(objSwf.inputEyeY.text),toint(objSwf.inputEyeZ.text));  
	local vlook = _Vector3.new(toint(objSwf.inputLookX.text),toint(objSwf.inputLookY.text),toint(objSwf.inputLookZ.text));  
	
	CPlayerControl:SetCameraPos(vlook,veye)
end

function UIToolsCamera:GetCameraId()
	local objSwf = self:GetSWF("UIToolsCamera")
	return toint(objSwf.cameraAniId.text)
end

function UIToolsCamera:OnShow(name)
	local objSwf = self:GetSWF("UIToolsCamera")
	if not objSwf then return end
	
	-- self:UpdateCameraText()
end

function UIToolsCamera:OnEdit(cameraVO)
	local objSwf = self:GetSWF("UIToolsCamera")
	if not objSwf then return end
	self.CurrentCameraVO = cameraVO
	-- SpiritsUtil:Trace(cameraVO)
	-- SpiritsUtil:Trace(self.CurrentCameraVO)
	if cameraVO.eye == nil and cameraVO.look == nil then
		self:OnAdd(cameraVO)
		return
	end
	
	objSwf.cameraAniId.text = cameraVO.cname or ""
	objSwf.inputEyeX.text = cameraVO.eye[1] or ""
	objSwf.inputEyeY.text = cameraVO.eye[2] or ""
	objSwf.inputEyeZ.text = cameraVO.eye[3] or ""
	
	objSwf.inputLookX.text = cameraVO.look[1] or ""
	objSwf.inputLookY.text = cameraVO.look[2] or ""
	objSwf.inputLookZ.text = cameraVO.look[3] or ""
	
	objSwf.inputSceneEffect.text = cameraVO.sceneEffect or ""
	objSwf.inputNpc.text = cameraVO.npcId or ""
	objSwf.inputLast.text = cameraVO.lastTime or "0"
	objSwf.inputCameraDistance.text = cameraVO.cameraDistanceSpeed or "0"
	objSwf.inputCameraRotateX.text = cameraVO.cameraRotateX or "0"
	objSwf.inputCameraRotateY.text = cameraVO.cameraRotateY or "0"
	objSwf.inputShakeTime.text = cameraVO.shakeTime or ""
	objSwf.inputShakeMin.text = cameraVO.shakeMin or ""
	objSwf.inputShakeMax.text = cameraVO.shakeMax or ""
	objSwf.inputSound.text = cameraVO.soundID or ""
	objSwf.inputMax.text = cameraVO.maxTime or "0"
	objSwf.inputTalk.text = cameraVO.talkStr or ""
	objSwf.inputNpcPos.text = cameraVO.playerMovePos or ""
	objSwf.inputCamaraTarget.text = cameraVO.autoCamaraTaget or ""
	
	objSwf.inputPlayerActId.text = cameraVO.playerActId or ""
	
	if cameraVO.bIsShowUI == nil then
		objSwf.checkIsShowUI.selected = true
	else
		objSwf.checkIsShowUI.selected = cameraVO.bIsShowUI
	end
	
	if cameraVO.bShowNpc == nil then
		objSwf.checkShowNpc.selected = false
	else
		objSwf.checkShowNpc.selected = cameraVO.bShowNpc
	end
	
	if cameraVO.bGensuiShijiao == nil then
		objSwf.checkIsGensuiShijiao.selected = false
	else
		objSwf.checkIsGensuiShijiao.selected = cameraVO.bGensuiShijiao
	end
	
	if cameraVO.bNext == nil then
		objSwf.checkIsNext.selected = false
	else
		objSwf.checkIsNext.selected = cameraVO.bNext
	end
	
	if cameraVO.bIsHideMain == nil then
		objSwf.checkIsHideMain.selected = false
	else
		objSwf.checkIsHideMain.selected = cameraVO.bIsHideMain
	end
	
	if cameraVO.isResetRotate == nil then
		objSwf.checkResetRotate.selected = false
	else
		objSwf.checkResetRotate.selected = cameraVO.isResetRotate
	end
	
	if cameraVO.isResetDistance == nil then
		objSwf.checkResetDistance.selected = false
	else
		objSwf.checkResetDistance.selected = cameraVO.isResetDistance
	end
	
	if cameraVO.bIsLock == nil then
		objSwf.checkIsLock.selected = false
	else
		objSwf.checkIsLock.selected = cameraVO.bIsLock
	end
	
	if cameraVO.bResetDirect == nil then
		objSwf.checkResetDirect.selected = false
	else
		objSwf.checkResetDirect.selected = cameraVO.bResetDirect
	end
	
	if cameraVO.FadeInTime == nil then
		objSwf.inputFadeIn.text = ""
	else
		objSwf.inputFadeIn.text = cameraVO.FadeInTime
	end
	
	if cameraVO.FadeOutTime == nil then
		objSwf.inputFadeOut.text = ""
	else
		objSwf.inputFadeOut.text = cameraVO.FadeOutTime
	end
	
	if cameraVO.bGotoNextByMoveTime == nil then
		objSwf.nextByMoveTime.selected = false
	else
		objSwf.nextByMoveTime.selected = cameraVO.bGotoNextByMoveTime
	end
	
	if cameraVO.Patrol then
		objSwf.inputPatrol.text = cameraVO.Patrol or ""
	else
		objSwf.inputPatrol.text = ""
	end
	
	if cameraVO.NPCActCfg then
		objSwf.inputNPCActCfg.text = cameraVO.NPCActCfg or ""
	else
		objSwf.inputNPCActCfg.text = ""
	end
	
	if cameraVO.MyPatrol then
		objSwf.inputMyPatrol.text = cameraVO.MyPatrol or ""
	else
		objSwf.inputMyPatrol.text = ""
	end
	
	if cameraVO.MonsterBorn then
		objSwf.inputMonsterBorn.text = cameraVO.MonsterBorn or ""
	else
		objSwf.inputMonsterBorn.text = ""
	end
	
	if cameraVO.cameraLookDif then
		self.cameraLookDif_Vec = _Vector3.new(cameraVO.cameraLookDif[1],cameraVO.cameraLookDif[2],cameraVO.cameraLookDif[3])
	end
	
	local veye = _Vector3.new(tonumber(objSwf.inputEyeX.text),tonumber(objSwf.inputEyeY.text),tonumber(objSwf.inputEyeZ.text));  
	local vlook = _Vector3.new(tonumber(objSwf.inputLookX.text),tonumber(objSwf.inputLookY.text),tonumber(objSwf.inputLookZ.text));  
	CPlayerControl:SetCameraPos(vlook,veye)
end

function UIToolsCamera:OnAdd(cameraVO)
	local objSwf = self:GetSWF("UIToolsCamera")
	if not objSwf then return end
	self.CurrentCameraVO = cameraVO

	objSwf.inputEyeX.text = _rd.camera.eye.x
	objSwf.inputEyeY.text = _rd.camera.eye.y
	objSwf.inputEyeZ.text = _rd.camera.eye.z
	
	objSwf.inputLookX.text = _rd.camera.look.x
	objSwf.inputLookY.text = _rd.camera.look.y
	objSwf.inputLookZ.text = _rd.camera.look.z
	
	cameraVO.eye = {tonumber(objSwf.inputEyeX.text),tonumber(objSwf.inputEyeY.text),tonumber(objSwf.inputEyeZ.text)}
	cameraVO.look = {tonumber(objSwf.inputLookX.text),tonumber(objSwf.inputLookY.text),tonumber(objSwf.inputLookZ.text)} 
	
	objSwf.cameraAniId.text = cameraVO.cname or ""
	objSwf.inputMax.text = '0'
	objSwf.inputLast.text = '0'
	objSwf.inputCameraDistance.text = '0'
	objSwf.inputCameraRotateX.text = '0'
	objSwf.inputCameraRotateY.text = '0'
	objSwf.inputShakeTime.text = ''
	objSwf.inputShakeMin.text = ''
	objSwf.inputShakeMax.text = ''
	objSwf.inputSound.text = ''
	objSwf.inputNpc.text = ''
	objSwf.inputSceneEffect.text = ''
	objSwf.inputTalk.text = ''
	objSwf.inputNpcPos.text = ''
	objSwf.inputCamaraTarget.text = ''
	
	local veye = _Vector3.new(tonumber(objSwf.inputEyeX.text),tonumber(objSwf.inputEyeY.text),tonumber(objSwf.inputEyeZ.text));  
	local vlook = _Vector3.new(tonumber(objSwf.inputLookX.text),tonumber(objSwf.inputLookY.text),tonumber(objSwf.inputLookZ.text));  
	CPlayerControl:SetCameraPos(vlook,veye)
end

function UIToolsCamera:UpdateCameraText()
	local objSwf = self:GetSWF("UIToolsCamera")
	local veye = _Vector3.new(tonumber(objSwf.inputEyeX.text),tonumber(objSwf.inputEyeY.text),tonumber(objSwf.inputEyeZ.text));  
	local vlook = _Vector3.new(tonumber(objSwf.inputLookX.text),tonumber(objSwf.inputLookY.text),tonumber(objSwf.inputLookZ.text));
	CPlayerControl:SetCameraPos(vlook,veye)
end

function UIToolsCamera:OnbtnEyeXDelClick()
	local objSwf = self:GetSWF("UIToolsCamera")
	if not objSwf.inputEyeX.text or objSwf.inputEyeX.text == '' then return end
	
	objSwf.inputEyeX.text = tonumber(objSwf.inputEyeX.text) - 1
	self:UpdateCameraText()
end

function UIToolsCamera:OnbtnEyeXAddClick()
	local objSwf = self:GetSWF("UIToolsCamera")
	if not objSwf.inputEyeX.text or objSwf.inputEyeX.text == '' then return end
	
	objSwf.inputEyeX.text = tonumber(objSwf.inputEyeX.text) + 1
	self:UpdateCameraText()
end

function UIToolsCamera:OnbtnEyeYDelClick()
	local objSwf = self:GetSWF("UIToolsCamera")
	if not objSwf.inputEyeY.text or objSwf.inputEyeY.text == '' then return end	
	
	objSwf.inputEyeY.text = tonumber(objSwf.inputEyeY.text) - 1
	self:UpdateCameraText()
end

function UIToolsCamera:OnbtnEyeYAddClick()
	local objSwf = self:GetSWF("UIToolsCamera")
	if not objSwf.inputEyeY.text or objSwf.inputEyeY.text == '' then return end

	objSwf.inputEyeY.text = tonumber(objSwf.inputEyeY.text) + 1
	self:UpdateCameraText()
end

function UIToolsCamera:OnbtnEyeZDelClick()
	local objSwf = self:GetSWF("UIToolsCamera")
	if not objSwf.inputEyeZ.text or objSwf.inputEyeZ.text == '' then return end
	
	objSwf.inputEyeZ.text = tonumber(objSwf.inputEyeZ.text) - 1
	self:UpdateCameraText()
end

function UIToolsCamera:OnbtnEyeZAddClick()
	local objSwf = self:GetSWF("UIToolsCamera")
	if not objSwf.inputEyeZ.text or objSwf.inputEyeZ.text == '' then return end
	
	objSwf.inputEyeZ.text = tonumber(objSwf.inputEyeZ.text) + 1
	self:UpdateCameraText()
end

function UIToolsCamera:OnbtnLookXDelClick()
	local objSwf = self:GetSWF("UIToolsCamera")
	if not objSwf.inputLookX.text or objSwf.inputLookX.text == '' then return end
	
	objSwf.inputLookX.text = tonumber(objSwf.inputLookX.text) - 1
	self:UpdateCameraText()
end

function UIToolsCamera:OnbtnLookXAddClick()
	local objSwf = self:GetSWF("UIToolsCamera")
	if not objSwf.inputLookX.text or objSwf.inputLookX.text == '' then return end
	
	objSwf.inputLookX.text = tonumber(objSwf.inputLookX.text) + 1
	self:UpdateCameraText()
end

function UIToolsCamera:OnbtnLookYDelClick()
	local objSwf = self:GetSWF("UIToolsCamera")
	if not objSwf.inputLookY.text or objSwf.inputLookY.text == '' then return end
	
	objSwf.inputLookY.text = tonumber(objSwf.inputLookY.text) - 1
	self:UpdateCameraText()
end

function UIToolsCamera:OnbtnLookYAddClick()
	local objSwf = self:GetSWF("UIToolsCamera")
	if not objSwf.inputLookY.text or objSwf.inputLookY.text == '' then return end

	objSwf.inputLookY.text = tonumber(objSwf.inputLookY.text) + 1
	self:UpdateCameraText()
end

function UIToolsCamera:OnbtnLookZDelClick()
	local objSwf = self:GetSWF("UIToolsCamera")
	if not objSwf.inputLookZ.text or objSwf.inputLookZ.text == '' then return end
	
	objSwf.inputLookZ.text = tonumber(objSwf.inputLookZ.text) - 1
	self:UpdateCameraText()
end

function UIToolsCamera:OnbtnLookZAddClick()
	local objSwf = self:GetSWF("UIToolsCamera")
	if not objSwf.inputLookZ.text or objSwf.inputLookZ.text == '' then return end
	
	objSwf.inputLookZ.text = tonumber(objSwf.inputLookZ.text) + 1
	self:UpdateCameraText()
end

function UIToolsCamera:OnbtnResetClick()
	local objSwf = self:GetSWF("UIToolsCamera")
	objSwf.inputEyeX.text = _rd.camera.eye.x
	objSwf.inputEyeY.text = _rd.camera.eye.y
	objSwf.inputEyeZ.text = _rd.camera.eye.z
	
	objSwf.inputLookX.text = _rd.camera.look.x
	objSwf.inputLookY.text = _rd.camera.look.y
	objSwf.inputLookZ.text = _rd.camera.look.z
	
	self.CurrentCameraVO.eye = {tonumber(objSwf.inputEyeX.text),tonumber(objSwf.inputEyeY.text),tonumber(objSwf.inputEyeZ.text)}
	self.CurrentCameraVO.look = {tonumber(objSwf.inputLookX.text),tonumber(objSwf.inputLookY.text),tonumber(objSwf.inputLookZ.text)} 
end

function UIToolsCamera:OnBtnCloseClick()
	self:Hide();
end

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
UIToolsCamera.TestNpcDic = {}
function UIToolsCamera:CreateTestNpc()
	local objSwf = self:GetSWF("UIToolsCamera")
	if not objSwf then return end

	if objSwf.TestNpcId.text ~= '' and objSwf.TestNpcDir.text ~= '' and objSwf.TestNpcX.text ~= '' and objSwf.TestNpcY.text ~= '' then
		local npcId = tonumber(objSwf.TestNpcId.text)
		local bornX = tonumber(objSwf.TestNpcX.text)
		local bornY = tonumber(objSwf.TestNpcY.text)
		local faceto = tonumber(objSwf.TestNpcDir.text)
		
		FPrint('创建测试NPC')
		
		local npc = self.TestNpcDic[npcId]
		if npc then
			return
		end
		
		local npcCfg = t_npc[npcId]
		if npcCfg and npcCfg.type == StoryConsts.StoryNpcType then
			local npcInfo = {}
			npcInfo.configId = npcId
			npcInfo.gid = 888
			npcInfo.x = bornX or 0
			npcInfo.y = bornY or 0
			npcInfo.faceto = faceto or 0
			
			npc = NpcController:AddTestNpc(npcInfo)
			self.TestNpcDic[npcId] = npc
		end
	end
	if objSwf.TestEffectId.text ~= '' and objSwf.TestNpcZ.text ~= '' and objSwf.TestNpcX.text ~= '' and objSwf.TestNpcY.text ~= '' then
		local bornX = tonumber(objSwf.TestNpcX.text)
		local bornY = tonumber(objSwf.TestNpcY.text)
		local bornZ = tonumber(objSwf.TestNpcZ.text)
		local sceneEffectId = objSwf.TestEffectId.text
		FPrint('创建测试effect')
		UIToolsCamera:ParseSceneEffect(sceneEffectId,bornX,bornY,bornZ)
	end
end

function UIToolsCamera:DelTestNpc()
	for k,npc in pairs(self.TestNpcDic) do
		if not npc.avatar then
			return
		end
		npc.avatar:ExitMap()
		npc.avatar = nil
		npc = nil
		
	end
	self.TestNpcDic = {}
	
	self:StopAllStorySceneEffect()
end

---------------播放场景特效---------------------------------------------------
function UIToolsCamera:ParseSceneEffect(sceneEffectId,bornX,bornY,bornZ)
	local sceneEffectCfg = StorySceneEffect[sceneEffectId]
	if sceneEffectCfg then
		for k,v in pairs (sceneEffectCfg) do
			self:PlayStorySceneEffect(v.effectName, {bornX,bornY,bornZ}, k)
			-- FPrint('播放场景特效'..k)
		end
	else
		--FPrint('没有找到场景特效配置文件：'..sceneEffectId)
	end
	
end

local mat =_Matrix3D.new()

function UIToolsCamera:PlayStorySceneEffect(effectName, pos, index)
	local eName = self.SceneEffectStr .. effectName..index
	local offsetZ = CPlayerMap:GetSceneMap():getSceneHeight(pos[1], pos[2])
	mat:setTranslation(_Vector3.new(pos[1], pos[2], pos[3] + offsetZ))
	local scenePfx = nil
	if GameController.loginState then
		scenePfx = CLoginScene.objSceneMap:PlayerPfxByMat(eName, effectName, mat)
	else
		scenePfx = CPlayerMap:GetSceneMap():PlayerPfxByMat(eName, effectName, mat)
	end
	if scenePfx then 
		-- FPrint('播放场景特效成功'..eName) 
		-- FTrace(pos)
		self.StorySceneEffectDic[eName] = scenePfx 
	end
	
	
end

function UIToolsCamera:StopStorySceneEffect(eName)
	CPlayerMap:GetSceneMap():StopPfxByName(eName)
end

function UIToolsCamera:StopAllStorySceneEffect()
	for k,v in pairs(self.StorySceneEffectDic) do
		self:StopStorySceneEffect(k)
		self.StorySceneEffectDic[k] = nil
	end
	
	self.StorySceneEffectDic = {}
end