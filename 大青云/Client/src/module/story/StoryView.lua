--[[剧情主面板
liyuan
2014年10月18日10:32:23
]]

_G.UIStory = BaseUI:new("UIStory") 
-- 自动镜头配置

function UIStory:Create()
	self:AddSWF("storyPanel.swf", true, "story")
	self.dwNpcId = 0
	self.szNpcName = ""
	self.szNpcTxt = ""
	self.Avatar = {}
	self.bOnMovie = false
	self.UIMovie = nil
	self.autoCamaraTaget = nil
	self.bCam = false
	self.bNeedReset = false
	self.CountDownNum = 5
	self.dwTime = nil
	self.dwType = nil
	self.vLookPos = nil
	self.vEyePos = nil
	self.bIsShowUI = false
	self.bIsShowNext = true
	self.bNext = false
	self.FadeInTime = nil
	self.FadeOutTime = nil
	self.bGotoNextByMoveTime = false
	self.bIsLock = false
	self.bResetDirect = false
	self.index = 0
	self.NumWidth = 66
	self.NumHeight = 80
	self.dwWidth = 0
	self.dwHeight = 0
	self.NumTimerId = nil
	self.bGensuiShijiao = false
	self.cameraLookDif = nil
	self.cameraDistanceSpeed = 0
	self.isPreLoadShow = false
	self.storyId = nil
end
local endLookPos = _Vector3.new()
local endEyePos = _Vector3.new()
function UIStory:OnShow()
	local objSwf = self.objSwf
	if not objSwf then return end
	
	local winW,winH = UIManager:GetWinSize()
	self:DoResize(winW,winH)
	if self.isPreLoadShow then self.isPreLoadShow = false return end
	objSwf.mcBtnArea._visible = false
	objSwf.mcDialog._visible = false
	objSwf.btnBack._visible = false;
	--FPrint('剧情面板1')
	objSwf.mcbg._visible = false;
	
	-- --FPrint("剧情Ui打开UIStory:OnShow()")
	-- objSwf._visible = self.bIsShowUI
	self:SetUIVisible(self.bIsShowUI)
	-- self:Hide()
	self:StartMovieStory()
end

function UIStory:Open()
	self.isPreLoadShow = true
	self:Show()
end

function UIStory:OnLoaded(objSwf,name)
	-- ------FPrint("剧情Ui加载完成")
	objSwf.mcBtnArea._visible = false
	objSwf.mcDialog._visible = false
	objSwf.btnBack._visible = false;
	-- objSwf.mcBtnArea.btnNext.labNext.htmlText = StrConfig['dungeon2']
	
	-- objSwf.mcBtnArea.btnNext.click = function() self:OnBtnNextClick() end
	objSwf.btnBack.click = function() self:OnBtnBackClick() end
	objSwf.mcbg.click = function() self:OnBtnNextClick() end
	if objSwf.mcbottom then
		objSwf.mcbottom._visible = false
	end
	
	if objSwf.mctop then
		objSwf.mctop._visible = false
	end
	
	objSwf.numLoaderFight._visible = false
	
end

-- 点击下一步
function UIStory:OnBtnNextClick()
	local objSwf = self.objSwf
	if not objSwf then return end
	if not self.bIsShowUI then return end
	if not self.bIsShowNext then return end

	if self.bNext then
		self.bNext = false
		-- objSwf._visible = false
		self:SetUIVisible(false)
		-- --FPrint('点击下一步')
		self:QuickSetCamera()
		StoryController:OnStoryNext()
	end
end

-- 点击跳过剧情
function UIStory:OnBtnBackClick()
	if not self.bIsShowUI then return end
	
	StoryController:OnStorySkip()
end

function UIStory:SetUIVisible(uiVisible)
	local objSwf = self.objSwf
	if not objSwf then return end
	
	-- if not StoryController.isHideUI then
		-- objSwf.mcBtnArea._visible = uiVisible
		objSwf.mcDialog._visible = uiVisible
		objSwf.btnBack._visible = uiVisible;
		if uiVisible then
			--FPrint('剧情面板2可见')
		else
			--FPrint('剧情面板2不可见')		
		end
		objSwf.mcbg._visible = uiVisible;
		
		if uiVisible then
			-- objSwf.mcBtnArea._visible = self.bIsShowNext
			objSwf.mcbg._visible = self.bIsShowNext
		else
			objSwf.mcBtnArea._visible = false
			objSwf.mcbg._visible = false
		end
	-- else
		-- objSwf.mcBtnArea._visible = false
		-- objSwf.mcDialog._visible = false
		-- objSwf.btnBack._visible = false;
		-- objSwf.mcbg._visible = false;
		-- objSwf.mcBtnArea._visible = false
		-- objSwf.mcbg._visible = false
	-- end
end


-- 重新调整布局
function UIStory:DoResize( dwWidth, dwHeight )
	local objSwf = self.objSwf
	if not objSwf then return end
	self.dwWidth = dwWidth
	self.dwHeight = dwHeight
	objSwf.mcBtnArea._x = dwWidth;
	objSwf.mcBtnArea._y = dwHeight;
	
	objSwf.mcDialog._x = 0
	objSwf.mcDialog._y = dwHeight - 80;
	
	-- objSwf.mcMask._width = dwWidth;
	-- objSwf.mcMask._height = dwHeight;
	objSwf.mcbg._width = dwWidth;
	objSwf.mcbg._height = dwHeight;
	
	-- if objSwf.cover2 then
		-- objSwf.cover2._width = dwWidth;
		-- objSwf.cover2._height = dwHeight;
		-- objSwf.cover2._x = math.floor(-dwWidth/2)
		-- objSwf.cover2._y = math.floor(-dwHeight/2)
	-- end
	
	objSwf.btnBack._x = dwWidth - 228
	objSwf.btnBack._y = 30
	
	if objSwf.mcbottom then
		-- --FPrint(dwHeight)
		objSwf.mcbottom._x = dwWidth / 2;
		objSwf.mcbottom._y = dwHeight
		-- --FPrint(objSwf.mcbottom._y )
	end
	
	if objSwf.mctop then
		objSwf.mctop._x = dwWidth / 2;
		objSwf.mctop._y = 0
		-- --FPrint(objSwf.mctop._x)
		-- objSwf.mctop._width = dwWidth
	end
	
	objSwf.numLoaderFight._x = (dwWidth - self.NumWidth)/2 - self.NumWidth/2
	objSwf.numLoaderFight._y = (dwHeight - self.NumHeight)/2 - self.NumHeight/2 - 100
	
	
end

function UIStory:ShowFrame()
	local objSwf = self.objSwf
	if not objSwf then return end
	
	if objSwf.mcbottom then
		-- objSwf.mcbottom:gotoAndPlay('show')
		objSwf.mcbottom._visible = true
	end
	
	if objSwf.mctop then
		-- objSwf.mctop:gotoAndPlay('show')
		objSwf.mctop._visible = true
	end
end

function UIStory:HideFrame()
	local objSwf = self.objSwf
	if not objSwf then return end
	
	if objSwf.mcbottom then
		-- objSwf.mcbottom:gotoAndPlay('hide')
		objSwf.mcbottom._visible = false
	end
	
	if objSwf.mctop then
		-- objSwf.mctop:gotoAndPlay('hide')
		objSwf.mctop._visible = false
	end
end

--设置NPC模型
function UIStory:SetNpcAvatar(objSwf,dwNpcId)
end
--设置玩家
function UIStory:SetPlayerAvatar(objSwf)
end

--电影剧情
function UIStory:StartMovieStory()
	-- --FPrint("剧情Ui打开UIStory:StartMovieStory()")

	if self.bOnMovie then
		self:SetMovieStory()
	else
		if not StoryController.isHideUI then
			self:ShowFrame()
		end
		self.bOnMovie = true
		
		MainPlayerController:BreakAutoRun();
		self:SetMovieStory()
	end
end

function UIStory:SetCameraAnimation()	
	StoryRequstFun()
	if self.FadeInTime and toint(self.FadeInTime) > 0 then
		-- objSwf.cover2:gotoAndPlay( 'show' )
		
		if not _rd.screenBlender then _rd.screenBlender = _Blender.new(); end
		_rd.screenBlender:fade(0, 1, 0, toint(self.FadeInTime))
	end
	if self.FadeOutTime and toint(self.FadeOutTime) > 0 then
		-- objSwf.cover2:gotoAndPlay( 'hide' )
		
		if not _rd.screenBlender then _rd.screenBlender = _Blender.new(); end
		_rd.screenBlender:fade(0, 0, 1, toint(self.FadeOutTime))
	end

	local player =  MainPlayerController:GetPlayer()
	local roleAvatar = nil
	if player then
		roleAvatar = player:GetAvatar()
	end
	if self.bIsLock then 
		if roleAvatar then
			if self.bGensuiShijiao then
				----FPrint('镜头绑定视角')
				local vLookPos = roleAvatar:GetCameraFollowLook()
				local vEyePos = _Vector3.new()
				-- _Vector3.add(vLookPos,self.cameraLookDif,vEyePos)
				-- --FPrint('镜头绑定视角'..self.cameraLookDif[1]..self.cameraLookDif[2]..self.cameraLookDif[3])
				_Vector3.add(vLookPos,_Vector3.new(self.cameraLookDif[1],self.cameraLookDif[2],self.cameraLookDif[3]),vEyePos)
				endLookPos = nil
				endEyePos = nil
				CPlayerControl:SetCameraPos(vLookPos,vEyePos)
			end
			self.bNeedReset = true
			self.vLookPos = nil
			self.vEyePos = nil
			roleAvatar:SetCameraFollowBySkn()
			----FPrint('镜头绑定')
		end
		return
	else
		if roleAvatar then
			roleAvatar:DisableCameraFollow()
			----FPrint('取消镜头绑定')
		end
	end
	
	-- --FPrint('自动镜头1')
	if self.autoCamaraTaget then
		-- --FPrint('自动镜头2')
		local targetPlayer = nil
		local airHeight = 0
		if self.autoCamaraTaget == StoryAutoCamaraCfg.SelfTargetId then
			targetPlayer = MainPlayerController:GetPlayer()
		else
			targetPlayer = NpcModel:GetCurrNpcByNpcId(self.autoCamaraTaget)
			if targetPlayer then
				local npcModelId = t_npc[self.autoCamaraTaget].look
				airHeight = t_model[npcModelId].airHeight or 0
			end
			if not targetPlayer then
				targetPlayer = NpcModel:GetStoryNpc(self.autoCamaraTaget)
			end
		end
		if targetPlayer then
			local tLookPos, tEyePos = UIStory:GetCamaraPos(targetPlayer,StoryAutoCamaraCfg.StartDis,StoryAutoCamaraCfg.StartOffsetZ,airHeight)
			endLookPos, endEyePos = UIStory:GetCamaraPos(targetPlayer,StoryAutoCamaraCfg.EndDis,StoryAutoCamaraCfg.EndOffsetZ,airHeight)
			if not StoryAutoCamaraCfg.Track then
				endLookPos = nil
				endEyePos = nil
				CPlayerControl:SetCameraPos(tLookPos,tEyePos)
			else
				CPlayerControl:MoveCameraPos(tLookPos,tEyePos, 1000, function() 
														CPlayerControl:ClearFunMoveEndCallBack()
														CPlayerControl:MoveCameraPos(endLookPos,endEyePos, StoryAutoCamaraCfg.AutoMoveTime)
													end)
			end
		else
			--FPrint('自动镜头目标id错误'..self.autoCamaraTaget)
			endLookPos = nil
			endEyePos = nil
			CPlayerControl:ResetCameraPos(self.dwTime)
		end
		self.bNeedReset = true
	elseif self.vLookPos then
		SpiritsUtil:Print("开始self.vLookPos")
		local vLookPos = _Vector3.new(self.vLookPos[1],self.vLookPos[2],self.vLookPos[3])
		local vEyePos = nil
		if self.vEyePos then
			vEyePos = _Vector3.new(self.vEyePos[1],self.vEyePos[2],self.vEyePos[3])
		end
		
		if self.bGotoNextByMoveTime then
			endLookPos = _Vector3.new(self.vLookPos[1],self.vLookPos[2],self.vLookPos[3])
			endEyePos = _Vector3.new(self.vEyePos[1],self.vEyePos[2],self.vEyePos[3])
			CPlayerControl:MoveCameraPos(vLookPos,vEyePos,self.dwTime,  function()
																			self.bNext = false
																			-- objSwf._visible = false
																			self:SetUIVisible(false)
																			----FPrint('摄像机移动完成回调')
																			CPlayerControl:ClearFunMoveEndCallBack()
																			StoryController:OnStoryNext()
																		end)
		else
			if self.dwTime==0 then
				endLookPos = nil
				endEyePos = nil
				CPlayerControl:SetCameraPos(vLookPos,vEyePos)
			else
				endLookPos = _Vector3.new(self.vLookPos[1],self.vLookPos[2],self.vLookPos[3])
				endEyePos = _Vector3.new(self.vEyePos[1],self.vEyePos[2],self.vEyePos[3])
				CPlayerControl:MoveCameraPos(vLookPos,vEyePos,self.dwTime)
			end
		end
		self.bNeedReset = true
		self.vLookPos = nil
		self.vEyePos = nil
	else
		endLookPos = nil
		endEyePos = nil
		CPlayerControl:ResetCameraPos(self.dwTime)
	end
	-- self.bNeedReset = true
end

--设置电影剧情
function UIStory:SetMovieStory()
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.mcDialog._visible = true
	if self.szNpcName and self.szNpcName ~= "" then
		objSwf.mcDialog.labTalkName.htmlText = self.szNpcName .. "："
	else
		objSwf.mcDialog._visible = false
	end
	objSwf.mcDialog.txtInfo.htmlText = self.szNpcTxt	
	
	-- if self.index == 1 then
	if StoryController.isShowCountDown then
		StoryController.isShowCountDown = false
		objSwf.numLoaderFight._visible = true
		local countDown = self.CountDownNum
		
		local setCountDownNum = function()
			objSwf.numLoaderFight.num = countDown
			local startX = (self.dwWidth - self.NumWidth*2)/2 -- self.NumWidth
			local startY = (self.dwHeight - self.NumHeight*2)/2 -  100 -- self.NumHeight
			local endX = (self.dwWidth - self.NumWidth)/2 -- self.NumWidth/2
			local endY = (self.dwHeight - self.NumHeight)/2 -  100 -- self.NumHeight/2
			objSwf.numLoaderFight._x = startX;
			objSwf.numLoaderFight._y = startY;
			objSwf.numLoaderFight._alpha = 50;
			objSwf.numLoaderFight._xscale = 200;
			objSwf.numLoaderFight._yscale = 200;
			--
			Tween:To(objSwf.numLoaderFight, .5, {_alpha = 100,_xscale=100,_yscale=100,_x=endX,_y=endY,ease=Back.easeInOut});
		end
		setCountDownNum()
		if self.NumTimerId then 
			TimerManager:UnRegisterTimer(self.NumTimerId)
			self.NumTimerId = nil
		end
		self.NumTimerId = TimerManager:RegisterTimer(function()
			countDown = countDown - 1
			if countDown <= 0 then
				objSwf.numLoaderFight._visible = false
				if self.NumTimerId then 
					TimerManager:UnRegisterTimer(self.NumTimerId)
					self.NumTimerId = nil
				end
				return
			end
			setCountDownNum()
		end, 1000, self.CountDownNum)
	end
end

-- 检测目标点
function UIStory:CheckPos(vPos)
	return true
end
-------------------------------------------------
--外部接口
function UIStory:SetStory(storyId, storyInfo, szNpcName, szNpcTxt,index)
	self.bNext = true
	self.storyId = storyId
	self.dwType = storyInfo.dwPos
	self.dwNpcId = storyInfo.dwNpcId
	self.szNpcName = szNpcName
	self.szNpcTxt = szNpcTxt
	self.autoCamaraTaget = storyInfo.autoCamaraTaget
	self.bCam = storyInfo.bCam or false
	self.bIsLock = storyInfo.bIsLock
	self.bResetDirect = storyInfo.bResetDirect
	self.cameraDistanceSpeed = storyInfo.cameraDistanceSpeed
	self.index = index
	
	if storyInfo.look then
		self.vLookPos = storyInfo.look
	end
	if storyInfo.eye then
		self.vEyePos = storyInfo.eye
	else
		self.vEyePos = {_rd.camera.eye.x-_rd.camera.look.x,_rd.camera.eye.y-_rd.camera.look.y,_rd.camera.eye.z-_rd.camera.look.z}
	end
	
	
	self.dwTime = storyInfo.tm or 1000
	-- if storyInfo.bIsShowUI == nil then
		-- self.bIsShowUI = true
	-- else
		self.bIsShowUI = storyInfo.bIsShowUI
	-- end
	
	if storyInfo.bNext == nil then
		self.bIsShowNext = false
	else
		self.bIsShowNext = storyInfo.bNext
	end
	
	self.FadeInTime = storyInfo.FadeInTime
	self.FadeOutTime = storyInfo.FadeOutTime
	self.bGensuiShijiao = storyInfo.bGensuiShijiao
	self.cameraLookDif = storyInfo.cameraLookDif
	if storyInfo.bGotoNextByMoveTime == nil then
		self.bGotoNextByMoveTime = false
	else
		self.bGotoNextByMoveTime = storyInfo.bGotoNextByMoveTime
	end
	-- --FPrint("请求剧情Ui打开")
	
	self:SetCameraAnimation()
	if self.bShowState then self:OnShow() return end
	self:Show()
end


function UIStory:SetCountNum()
	
end

--设置NPC模型
function UIStory:SetNpcAvatar(objSwf,dwNpcId)

end

--清空模型/还原摄像机
function UIStory:Clear()
	------FPrint("清空模型/还原摄像机开始")
	-- if self.bOnMovie then
		------FPrint("清空模型/还原摄像机开始执行1")
		local objSwf = self.objSwf
		self.bOnMovie = false
		self:HideFrame()
		self:SetUIVisible(false)
		if objSwf then
			objSwf.numLoaderFight._visible = false
		end
		if self.NumTimerId then 
			TimerManager:UnRegisterTimer(self.NumTimerId)
			self.NumTimerId = nil
		end
		
		if self.bNeedReset then
			------FPrint("清空模型/还原摄像机开始执行2")
			CPlayerControl:ClearFunMoveEndCallBack()
			endLookPos = nil
			endEyePos = nil
			if self.bResetDirect then
				self:ResetUI()
				if self:IsResetCamera() then
					CPlayerControl:ResetCameraOldPos()
					StoryController.isUseStoryCamera = false
				else
					CPlayerControl:ClearOldCamera()
				end
			else
				if self:IsResetCamera() then
					CPlayerControl:ResetCameraPos(1000,function() 
						self:ResetUI() 
						StoryController.isUseStoryCamera = false
					end)
				else
					self:ResetUI()
					CPlayerControl:ClearOldCamera()
				end
			end
			
			self.bNeedReset = false
		else
			self:ResetUI()
		end
	-- end
end

function UIStory:IsResetCamera()
	if self.storyId == StoryConsts.kanyuanfangStoryId or 
		self.storyId == StoryConsts.CreateStoryId then
		return false
	else
		return true
	end
end

--重置ui
function UIStory:ResetUI()	
	if StoryController.isArena then
		StoryController.isArena = false
		return
	end
	
	if self.storyId == StoryConsts.kanyuanfangStoryId then
		UILoadingScene:Open(false);
	end
	StoryRequstFun2()	
end

--隐藏界面
function _G.StoryRequstFun()
	----FPrint("隐藏界面开始")
	if StoryController.bOnStory then
		----FPrint("隐藏界面执行")
		UIManager:HideLayerBeyond("story","storyBottom","loading");
	end
end;

--显示界面
function _G.StoryRequstFun2()
	UIManager:RecoverAllLayer(true);	  
end

local dif = _Vector3.new()
-- 剧情的视角
function UIStory:GetCamaraPos(targetPlayer,dis,offsetZ,airHeight)
	local playerPos = targetPlayer:GetAvatar():GetPos()
	local eyePos = self:GetRollPos(dis, targetPlayer,airHeight)
	
	_Vector3.sub(eyePos,playerPos,dif)
	local lPos = _Vector3.new()
	lPos.x = playerPos.x
	lPos.y = playerPos.y
	
	local aabb = targetPlayer:GetAvatar().objMesh:getBoundBox( )
	local pHeight = aabb.z2 - aabb.z1
	lPos.z = playerPos.z + airHeight + pHeight*StoryAutoCamaraCfg.AutoLookPos + offsetZ
	-- --FPrint('playerPos.z'..playerPos.z)
	-- --FPrint('pHeight'..pHeight)
	-- --FPrint('airHeight'..airHeight)
	-- --FPrint('lpos'..lPos.x..':'..lPos.y..':'..lPos.z)
	-- --FPrint('eyePos'..eyePos.x..':'..eyePos.y..':'..eyePos.z)
	return lPos, eyePos
end

-- 获得摄像机位置
function UIStory:GetRollPos(rollDis, objPlayer,airHeight)
    local dir = objPlayer:GetAvatar():GetDirValue()
    local pos1 = _Vector3.new()
    local pos = objPlayer:GetAvatar():GetPos()
	
	local aabb = objPlayer:GetAvatar().objMesh:getBoundBox( )
	local pHeight = aabb.z2 - aabb.z1
	
    pos1.x = pos.x - rollDis * math.sin(dir)
    pos1.y = pos.y + rollDis * math.cos(dir)
    pos1.z = pos.z + airHeight + pHeight*StoryAutoCamaraCfg.AutoEyePos
    if not pos1.z then
        return nil
    end
	
    return pos1
end

-- 快进镜头
function UIStory:QuickSetCamera()
	CStory:QuickPatrol()
	if endLookPos and endEyePos then
		CPlayerControl:ClearFunMoveEndCallBack()
		CPlayerControl:SetCameraPos(_Vector3.new(endLookPos.x,endLookPos.y,endLookPos.z),_Vector3.new(endEyePos.x,endEyePos.y,endEyePos.z))
	end
	-- objSwf.numLoaderFight._visible = false
	-- if self.NumTimerId then 
		-- TimerManager:UnRegisterTimer(self.NumTimerId)
		-- self.NumTimerId = nil
	-- end
end

--从来不被回收
function UIStory:NeverDeleteWhenHide()
	return true;
end

function UIStory:HandleNotification(name,body)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if name == NotifyConsts.StageClick then
		if self:IsShow() then
			self:OnBtnBackClick();
		end
	end
end

function UIStory:ListNotificationInterests()
	return {NotifyConsts.StageClick};
end




