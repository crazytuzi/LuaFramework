local RepresentMgr = luanet.import_type("RepresentMgr");
local TouchMgr = luanet.import_type("TouchMgr");
local SkillController = luanet.import_type("SkillController");
local SceneMgr = luanet.import_type("UnityEngine.SceneManagement.SceneManager");

local EffectMoveType =
{
	Rotate = 0,
	Move = 1,
}

Operation.nNoOpDelayOffLineTime  = 15 * 60; -- x秒无操作自动下线
Operation.eTargetModeUnlimited   = 0;
Operation.eTargetModeNpcFirst    = 1;
Operation.eTargetModePlayerFirst = 2;
Operation.tbAutoOfflineMaps = {
	[1003] = true,	--武神殿
	[1015] = true,	--英雄挑战
}

Operation.PRECISE_UI_OFFSET_X = 0
Operation.PRECISE_UI_OFFSET_Y = 0

Operation.PRECISE_CIRCLE_EFFECT = 9149
Operation.PRECISE_ARROW_EFFECT = 9150
Operation.PRECISE_TARGET_EFFECT = 9148

Operation.nAutoPlayBQAction = 60 		-- 自动播放BQ动作

-- 》》视角相关
-- 可进行视角操作的地图
local tbAssistMap = {15, 8009, 4005, 4008}
Operation.tbAssistMap = {}
for _, nMapTID in ipairs(tbAssistMap) do
	Operation.tbAssistMap[nMapTID] = true
end
-- 建安城默认视角
Operation.nJianAnDefaultDistance = 23
Operation.nJianAnDefaultAng = 35
Operation.nJianAnDefaultField = 20
Operation.nJianAnDefaultRotateX = 35
Operation.nJianAnDefaultRotateY = 45
Operation.nJianAnDefaultRotateZ = 0
-- 旋转镜头速度（x坐标滑动偏移 * Operation.nSpinSpeed）
Operation.nSpinSpeed = 0.25
Operation.nRotationSpeed = 10
-- 双指操作移动镜头速度
Operation.n2FingerSpeed = 0.0085
Operation.nMinCameraDistance = 3.5 				-- 镜头最小距离
Operation.nMaxCameraDistance = 12 				-- 镜头最大距离
Operation.nMinCameraAng      = 10 				-- 镜头最小角度
Operation.nMaxCameraAng      = 45 				-- 镜头最大角度
Operation.nMinViewField 	 = 40 				-- 镜头最小视野
Operation.nMaxViewField  	 = 40 				-- 镜头最大视野

-- 可移动的距离（以距离的变化为基准相应地调整角度变化）
local nActiveCameraDistance = Operation.nMaxCameraDistance - Operation.nMinCameraDistance
 -- 线性标准比例（保证距离增加或减少时角度也要成等比增加或减少）
local nStanderScale = (nActiveCameraDistance) / (Operation.nMaxCameraAng - Operation.nMinCameraAng)
-- 角度偏移 = nDistanceChange / nStanderScale
local nMoveSpeed = 1
local nReverse = -1 		-- -1 双指向内推远 1 双指向内推近
local nReverseY = -1 		-- -1 左滑右转 1 左滑左转
local nReverseX = 1;
-- 保存本地
Operation.szCameraSettingKey = "ViewCameraSetting"
Operation.nSaveCameraSettingDistance = 1 			-- 调整后的距离
Operation.nSaveCameraSettingAngle = 2 				-- 调整后的角度
Operation.nSaveCameraSettingField = 3 				-- 调整后的视野
Operation.nSaveCameraSettingViewChange = 4  		-- 调整ViewPanel滑动条的值
Operation.nSaveCameraSettingIsAdjustView = 5  		-- 调整ViewPanel滑动条的值
Operation.nSaveCameraSettingChangeY = 6     		-- 调整后的旋转距离
Operation.nSaveCameraSettingGuide = 7     		-- 导引

Operation.nSaveCameraSettingIsSpouse = 8            -- 屏蔽夫妻选项
Operation.nSaveCameraSettingIsFamily = 9            -- 屏蔽家族选项
Operation.nSaveCameraSettingIsSystemRoles = 10      -- 屏蔽系统角色选项
Operation.nSaveCameraSettingIsOtherPlayer = 11      -- 屏蔽陌生玩家选项
Operation.nSaveCameraSettingIsFriend = 12           -- 屏蔽好友选项
Operation.nSaveCameraSettingIsSworn = 13            -- 屏蔽结拜选项
Operation.nSaveCameraSettingIsHideHeadInfo = 14     -- 屏蔽头部信息选项
Operation.nSaveCameraSettingIsGameInformation = 15  -- 屏蔽游戏信息选项
Operation.nSaveCameraSettingIsDepthOfField = 16     -- 景深选项

local n2FingersMaxChange = 50 						-- 双指距离n以下才有效
local nSaveCameraSettingTime = 60 					-- 镜头配置改变每60秒存本地

Operation.bSuspendAction = false;
Operation.bNotShowShareInfo = false;
Operation.nShowSpecialEffectsId = 0;
Operation.nShowFrameId = 0;
Operation.nShowActionId = 0;
Operation.bIsNewPhotoStateOpen = false;

function Operation:GetChangeByDistance(nDistanceChange, nSpeed)
	nDistanceChange = nDistanceChange * (nSpeed or nMoveSpeed)

	local nCameraDistance = Ui.CameraMgr.s_fCameraDistance + nDistanceChange
	local nCameraLookDownAngle = self.nChangeAngle or Ui.CameraMgr.s_fCameraLookDownAngle;
	local nCameraFieldOfView = Ui.CameraMgr.s_fCameraFieldOfView + (nDistanceChange / nStanderScale)

	local nBigDistance = math.max(nCameraDistance, Operation.nMinCameraDistance)
	local nDistance = math.min(nBigDistance, Operation.nMaxCameraDistance)

	local nBigAngle = math.max(nCameraLookDownAngle, Operation.nMinCameraAng)
	local nAngle = math.min(nBigAngle, Operation.nMaxCameraAng)

	local nBigViewField = math.max(nCameraFieldOfView, Operation.nMinViewField)
	local nViewField = math.min(nBigViewField, Operation.nMaxViewField)
	return nDistance, nAngle, nViewField
end

function Operation:GetViewChangeByDistance(nDistance)
	nDistance = nDistance or Ui.CameraMgr.s_fCameraDistance
	if nDistance < Operation.nMinCameraDistance or nDistance > Operation.nMaxCameraDistance then
		return 0
	end
	local nViewChange = (Operation.nMaxCameraDistance - nDistance) / (Operation.nMaxCameraDistance - Operation.nMinCameraDistance)
	return nViewChange
end

function Operation:DoSaveCameraSetting()
	if Operation:GetAdjustViewState() then
		-- 实时缓存
		Operation:SaveCameraSetting(nil, nil, nil, nil, true)
		-- 定时存本地
		Operation:CheckSaveCameraSetting()
	end
end

function Operation:CheckSaveCameraSetting()
	--只要有改变就最多60秒存一次
	if self.nTimerSaveCameraSetting then
		return
	end
	self.nTimerSaveCameraSetting = Timer:Register(Env.GAME_FPS * nSaveCameraSettingTime, function ()
		Operation:SaveCameraSetting()
		self.nTimerSaveCameraSetting = nil;
	end)
end

function Operation:SaveCameraSetting(nDistance, nAngle, nViewField, nViewSlideValue, bNotSave)
	local nSaveDitance = nDistance or Ui.CameraMgr.s_fCameraDistance
	local nSaveAngle = nAngle or Ui.CameraMgr.s_fCameraLookDownAngle
	local nSaveViewField = nViewField or Ui.CameraMgr.s_fCameraFieldOfView
	local nSaveViewSlideValue = nViewSlideValue or self:GetViewChangeByDistance(nDistance)
	if nSaveDitance ~= Operation.nJianAnDefaultDistance then
		Client:SetFlag(Operation.szCameraSettingKey, nSaveDitance, Operation.nSaveCameraSettingDistance, bNotSave)
		Client:SetFlag(Operation.szCameraSettingKey, nSaveAngle, Operation.nSaveCameraSettingAngle, bNotSave)
		Client:SetFlag(Operation.szCameraSettingKey, nSaveViewField, Operation.nSaveCameraSettingField, bNotSave)
		Client:SetFlag(Operation.szCameraSettingKey, nSaveViewSlideValue, Operation.nSaveCameraSettingViewChange, bNotSave)
	end
end

function Operation:DoSaveChangePhotoSetting()
	if self:CheckAdjustView() then
		-- 实时缓存
		Operation:SaveChangePhotoSetting(true)
		-- 定时存本地
		Operation:CheckSaveChangePhotoSetting()
	end
end

function Operation:CheckSaveChangePhotoSetting()
	--只要有改变就最多60秒存一次
	if self.nTimerSaveChangePhotoSetting then
		return
	end
	self.nTimerSaveChangePhotoSetting = Timer:Register(Env.GAME_FPS * nSaveCameraSettingTime, function ()
		Operation:SaveChangePhotoSetting()
		self.nTimerSaveChangePhotoSetting = nil;
	end)
end

function Operation:SaveChangePhotoSetting(bNotSave)
	local nChangeY = Client:GetFlag(Operation.szCameraSettingKey, Operation.nSaveCameraSettingChangeY)
	if self.nChangeY and (not nChangeY or nChangeY ~= self.nChangeY) then
		Client:SetFlag(Operation.szCameraSettingKey, self.nChangeY, Operation.nSaveCameraSettingChangeY, bNotSave)
	end
	local nChangeAngle = Client:GetFlag(Operation.szCameraSettingKey, Operation.nSaveCameraSettingAngle)
	if self.nChangeAngle and (not nChangeAngle or nChangeAngle ~= self.nChangeAngle) then
		Client:SetFlag(Operation.szCameraSettingKey, self.nChangeAngle, Operation.nSaveCameraSettingAngle, bNotSave)
	end
end

function Operation:GetAdjustViewState()
	return Client:GetFlag(Operation.szCameraSettingKey, Operation.nSaveCameraSettingIsAdjustView) and true or false
end

function Operation:SetAdjustViewState(bAdjust)
	Client:SetFlag(Operation.szCameraSettingKey, bAdjust, Operation.nSaveCameraSettingIsAdjustView)
end

function Operation:DoSwitchAdjustViewState(bNotTip)
	local bAssistMap = Operation:IsAssistMap()
	if not bAssistMap then
		return
	end
	local bAdjustView = Operation:GetAdjustViewState()
	local bSwithView = not bAdjustView
	Operation:SetAdjustViewState(bSwithView)
	Operation:UpdateCameraSettingView()
	--if bSwithView then
--		Operation:DisableClickMap()
		--Operation:DoActivePlayerByType()
	--else
--		Operation:EnableClickMap()
		--Operation:DoActivePlayerDefault()
	--end
	if not bNotTip then
		me.CenterMsg("视角模式切换成功")
	end
	UiNotify.OnNotify(UiNotify.emNOTIFY_VIEW_STATE_CHANGE)
end

-- 显示所有玩家和npc
function Operation:DoActivePlayerDefault()
	Ui.Effect.ShowAllRepresentObj(1)
end

function Operation:DoActivePlayerByType()
	if Operation:CheckAdjustView() then
		local nType = Client:GetFlag("HidePlayerType") or 1
		Ui.Effect.ShowAllRepresentObj(nType)
	end
end
---------------------基本操作--------------------------------------

function Operation:MarkOperate()
	local nNow = GetTime();
	self.nDelayOffLineTime = nNow + Operation.nNoOpDelayOffLineTime;
	self.nLastOperateTime = nNow;
	self.nAutoBQActionTime = nNow + Operation.nAutoPlayBQAction
end

function Operation:DealAutoBQAction()
	local nNow = GetTime();
	if not self.nAutoBQActionTime or nNow % 10 ~= 0 then
		return;
	end
	if not Login.bEnterGame or IsServerConnected() == 0 then
		return
	end
	if AutoFight:IsAuto() then
		return;
	end
	if not Map:IsCityMap(me.nMapTemplateId) and not Map:IsFieldFightMap(me.nMapTemplateId) then
		return;
	end
	if OnHook:IsOnLineOnHook(me) then
		return
	end
	if Wedding:IsRoleWeddingTouring() then
		return
	end
	-- 野外的安全区长期不动也播放
	if me.nFightMode ~= 0 then
		return;
	end
	local nDoing = me.GetDoing();
	-- 已经播放动作
    if nDoing == Npc.Doing.common then
    	return;
    end
    local nActMode = me.GetActionMode();
    if nActMode == Npc.NpcActionModeType.act_mode_ride then
    	return
    end
    -- 并没有可以播放的动作
    local tbAllBQ = ChatMgr.ChatEquipBQ:GetAllEquipBQ(me)
    if not next(tbAllBQ) then
    	return
    end
	if nNow > self.nAutoBQActionTime then
		RemoteServer.AutoPlayChatEquipActionBQ();
	end
end

function Operation:DealDelayOffline()
	local nNow = GetTime();

	if nNow % 10 ~= 0 or not self.nDelayOffLineTime then
		return;
	end

	if not Login.bEnterGame or IsServerConnected() == 0 then
		return
	end

	if AutoFight:IsAuto() and not self.tbAutoOfflineMaps[me.nMapTemplateId] then
		return;
	end

	if not Map:IsCityMap(me.nMapTemplateId) and not Map:IsFieldFightMap(me.nMapTemplateId) and
		not Map:IsKinMap(me.nMapTemplateId) and not self.tbAutoOfflineMaps[me.nMapTemplateId] then
		return;
	end

	if OnHook:IsOnLineOnHook(me) then
		return
	end
	-- 正在游城
	if Wedding:IsRoleWeddingTouring() then
		return
	end

	self.nLastUpdateTime = self.nLastUpdateTime or nNow;
	self.nLastOperateTime = self.nLastOperateTime or nNow;
	if nNow - self.nLastOperateTime > 0 and (nNow - self.nLastUpdateTime) % 20 == 0 then
		if IOS or ANDROID then
			UiNotify.OnNotify(UiNotify.emNOTIFY_NO_OPERATE_UPDATE, self.nLastOperateTime, nNow);
		end
	end

	if me.nFightMode ~= 0 and not self.tbAutoOfflineMaps[me.nMapTemplateId] then
		return;
	end


	if nNow > self.nDelayOffLineTime then
		Log("No Operation Delay Logout")
		-- 防止下线后，仍有代码请求服务造成重连
		PauseRemoteServerReconnect(1000 * 3600);
		self.bDisconnectOnPurpose = true;

		Ui.bKickOffline = true;
		CloseServerConnect();
		Ui.bKickOffline = nil;

		local function fnReconnect()
			self.bDisconnectOnPurpose = nil;
			PauseRemoteServerReconnect(10);
			Ui:ReconnectServer();
		end

		local function fnReturnLogin()
			self.bDisconnectOnPurpose = nil;
			Ui:ReturnToLogin();
		end


		Ui:OpenWindow("MessageBox", string.format("您超过[FFFE0D]%d分钟[-]没有操作游戏，为避免浪费经验，自动帮您下线[FFFE0D]累积离线托管时间[-]，您现在要重新上线吗？", math.floor(self.nNoOpDelayOffLineTime / 60)),
			{
				{fnReconnect},
				{fnReturnLogin},
			},
			{"重连", "返回首页"}, nil, nil, true);
	end
end

function Operation:IsDisconnectOnPurpose()
	return (self.bDisconnectOnPurpose or Ui.bForRetrunLogin or Ui.bKickOffline) and IsServerConnected() == 0;
end

function Operation:OnLogin()
	self.bDisconnectOnPurpose = nil;
	Ui:CloseWindow("ViewPanel");
    Ui:CloseWindow("PhotographPanel");
    Ui:CloseWindow("PhotoBeautifyPanel");
	Ui:CloseWindow("PhotoHidePanel");
	Ui:CloseWindow("PhotographNewPanel");
	Ui:CloseWindow("PhotoStretchingPanel");
    Player:SetAllHeadUi()
end

function Operation.ClearScreen()
	--Ui:ChangeUiState(Ui.STATE_HIDE_ALL)
end

function Operation.RecoverScreen()
	--Ui:ChangeUiState(nil)
end

function Operation:OnDestroyMap()
	TouchMgr.SetJoyStick(false);
	SkillController.SetJoyStick(false);
	self:ClearPreciseOPEffect()
	Operation:MarkOperate();
end

function Operation:OnMapLoaded()
	Operation:EnableWalking();
	AutoFight:ClearManualAttack();
	Operation:UpdateJoyStickMovable();
	Operation:MarkOperate();
end

function Operation:SetGuidingJoyStick(bGuid)
	UiNotify.OnNotify(UiNotify.emNOTIFY_FAKE_JOYSTICK_GUIDING, bGuid and true or false);
	TouchMgr.SetJoyStickIgnoreUI(bGuid and true or false);
end

function Operation.ShowFakeJoystick()
	UiNotify.OnNotify(UiNotify.emNOTIFY_FAKE_JOYSTICK_STATE, true);
end

function Operation.HideFakeJoystick()
	UiNotify.OnNotify(UiNotify.emNOTIFY_FAKE_JOYSTICK_STATE, false);
end

function Operation:SetJoyStickUp()
	self.bOnJoyStick = false;
	TouchMgr.SetJoyStickUp();
	SkillController.SetJoyStickUp();
	self:ClearPreciseOPEffect()
end

function Operation:IsJoyStickMovable()
	if Sdk:IsPCVersion() and Client:GetFlag("ForbidJoyStickMoving") == nil then
		return false;
	end

	return not Client:GetFlag("ForbidJoyStickMoving");
end

function Operation:UpdateJoyStickMovable()
	local bMovable = Operation:IsJoyStickMovable();
	TouchMgr.SetJoyStickStartMovingRate(bMovable and 1 or 1000);
end

function Operation:SetJoyStickMovable(bMovable)
	Client:SetFlag("ForbidJoyStickMoving", not bMovable);
	Operation:UpdateJoyStickMovable();
end

function Operation:DisableWalking()
	self.bOnJoyStick = false;
	self.bForbidClickMap = true;
	TouchMgr.SetJoyStickUp();
	TouchMgr.SetJoyStick(false);

	SkillController.SetJoyStickUp();
	SkillController.SetJoyStick(false);
	self:ClearPreciseOPEffect()
end

function Operation:EnableWalking()
	TouchMgr.SetJoyStick(true);
	self.bForbidClickMap = false;
end

function Operation:GetTargetPos()
	local eDoing = me.GetDoing();
	if eDoing ~= Npc.Doing.run and eDoing ~= Npc.Doing.jump then
		return;
	end

	return me.GetTargetPosition();
end

function Operation:SetHuntingMode(bHunting)
	self.bHuntingMode = bHunting
	if bHunting then
		self:DisableClickMap()
	else
		self:EnableClickMap()
	end
end

function Operation.GoDirection(nDir, fAngle)
	if Operation.bHuntingMode then
		UiNotify.OnNotify(UiNotify.emNOTIFY_HUNTING_MOVE, fAngle)
		return
	end
	if Decoration.bActState then
		Decoration:ExitPlayerActState(me.dwID);
		return;
	end

	if not Operation.bOnJoyStick then
		Operation:SetPositionEffect(false);

		if Ui:WindowVisible("RockerGuidePanel") == 1 then
			Ui:CloseWindow("RockerGuidePanel");
		end

		if Ui:WindowVisible("RoleHead") == 1 then
			Ui("RoleHead"):Operation(false);
		end
	end

	if AutoFight:IsAuto() then
		AutoFight:GoDirection(nDir, Env.GAME_FPS);
	else
		me.GoDirection(nDir, Env.GAME_FPS);
		me.StartDirection(nDir);
	end

	Operation.nLastGoDir = nDir;
	Operation.bOnJoyStick = true;

	Operation:MarkOperate();
	AutoPath:ClearGoPath();
	Player:OnPlayerPosChange()
end

function Operation.StopGoDir()
	if Operation.bHuntingMode then
		UiNotify.OnNotify(UiNotify.emNOTIFY_HUNTING_STOP)
		return
	end

	-- 停止往方向走, 停止的方式是往前走一小段距离
	if AutoFight:IsAuto() then
		AutoFight:GoDirection(Operation.nLastGoDir, 1);
	else
		if Operation.nLastGoDir then
			me.GoDirection(Operation.nLastGoDir, 1);
		end
	end

	me.StopDirection();

	Operation.nLastGoDir = nil;
	Operation.bOnJoyStick = false;
	if Ui:WindowVisible("RoleHead") == 1 then
		Ui("RoleHead"):Operation(true);
	end
end

function Operation:StopMoveNow()
	Log("Operation:StopMoveNow")
	local _, nX, nY = me.GetNpc().GetWorldPos()
	me.GotoPosition(nX, nY);
	me.StopDirection();
end

function Operation.ClickObj(nX, nY)
	if not Login.bEnterGame then
		return false
	end

	if Operation.bOnJoyStick then
		return;
	end

	if Operation.bForbidClickMap then
		return;
	end

	if nX < 0 or nY < 0 then
		return false;
	end

	ActionInteract:CancelInteractC();
	Toy:ForceCancelUse()
	UiNotify.OnNotify(UiNotify.emNOTIFY_CLICKOBJ, nX, nY);
end

function Operation:ClickMapIgnore(nX, nY, bShowArrow, nWalkCloseCallbackLength)
	Operation.ClickMap(nX, nY, bShowArrow, nWalkCloseCallbackLength, true)
end

function Operation.ClickMap(nX, nY, bShowArrow, nWalkCloseCallbackLength, bNotIgnore3DClick)
	if not Login.bEnterGame then
		return false
	end

	if Operation.bOnJoyStick then
		return;
	end

	if Operation.bForbidClickMap then
		return;
	end

	if not bNotIgnore3DClick and Operation:CheckAdjustView() then
		return;
	end

	if nX <= 0 or nY <= 0 then
		return false;
	end

	local nDoing = me.GetDoing();
	if nDoing == Npc.Doing.jump or nDoing == Npc.Doing.do_attach then
		return false;
	end

	if Decoration.bActState then
		Decoration:ExitPlayerActState(me.dwID);
	end
	ActionInteract:CancelInteractC();
	Toy:ForceCancelUse()
	Operation:MarkOperate();
	local bCanGetThere = false;
	if AutoFight:IsAuto() then
		bCanGetThere = AutoFight:GotoPosition(nX, nY);
	else
		bCanGetThere = me.GotoPosition(nX, nY, nWalkCloseCallbackLength);
	end

	if bShowArrow and bCanGetThere then
		Operation:UnselectNpc();
		Operation:SetPositionEffect(true, nX, nY);
		AutoPath:ClearGoPath();
		Player:OnPlayerPosChange()
		return true;
	end

	Operation:SetPositionEffect(false);
	return false;
end

function Operation.RepObjSimpleTap(nRepID)
	UiNotify.OnNotify(UiNotify.emNOTIFY_REPOBJSIMPLETAP, nRepID);
	Decoration:OnRepObjSimpleTap(nRepID);
end

function Operation.RepObjLongTapStart(nID, nScreenPosX, nScreenPosY)
	UiNotify.OnNotify(UiNotify.emNOTIFY_REPOBJLONGTAPSTART, nID, nScreenPosX, nScreenPosY);
end

function  Operation.RepObjTouchUp(nRepID)
	UiNotify.OnNotify(UiNotify.emNOTIFY_REPOBJTOUCHUP, nRepID);
end

function Operation.SimpleTap(nNpcID)
	if not Login.bEnterGame then
		Login:SelRole(nNpcID)
		return
	end

	local pNpc = KNpc.GetById(nNpcID);
	if not pNpc then
		return;
	end

	if pNpc.nKind == Npc.KIND.dialoger then
		Operation:OnDialogerClicked(pNpc.nId);
		Operation:SetNpcSelected(nNpcID);
		return;
	end

	if pNpc.nPlayerID == me.dwID then
		return;
	end

	ActionInteract:SelectPlayerInteract(pNpc)
	if pNpc.nKind == Npc.KIND.player and pNpc.dwPlayerID ~= 0 and pNpc.dwPlayerID ~= me.dwID then
		Ui:OpenWindow("RoleHeadPop", {pNpc.dwPlayerID, nNpcID})
		Toy:OnSelectTarget(pNpc.dwPlayerID, pNpc.szName)
	end

	if AutoFight:IsAuto() then
		AutoFight:SelectNpc(nNpcID);
		return;
	end

	Operation:SetNpcSelected(nNpcID);
	Operation:OnGeneralClicked(pNpc.nId)
end

function Operation:OnGeneralClicked(nNpcID)
	local pNpc = KNpc.GetById(nNpcID);
	if not pNpc then
		return;
	end

	local nDistance = me.GetNpc().GetDistance(pNpc.nId);
	if nDistance > Npc.DIALOG_DISTANCE then
		local nMapId, nX, nY = pNpc.GetWorldPos();
		AutoPath:GotoAndCall(nMapId, nX, nY, function ()
			Operation:OnGeneralClicked(nNpcID);
		end, Npc.DIALOG_DISTANCE);
		return;
	end

	if pNpc.IsAlone() then
		GameSetting:SetGlobalObj(me, pNpc, it);
		Npc:OnGeneralDialog(him.szClass, him.szScriptParam);
		GameSetting:RestoreGlobalObj();
	else
		RemoteServer.OnSimpleTapNpc(pNpc.nId);
	end

	if pNpc.szTag ~= "NoTurn" and pNpc.nKind ~= Npc.KIND.player then
		Operation:Turn2Player(pNpc);
	end
end

function Operation:OnDialogerClicked(nNpcID)
	local pNpc = KNpc.GetById(nNpcID);
	if not pNpc then
		return;
	end

	local nDistance = me.GetNpc().GetDistance(pNpc.nId);
	if nDistance > Npc.DIALOG_DISTANCE then
		local nMapId, nX, nY = pNpc.GetWorldPos();
		AutoPath:GotoAndCall(nMapId, nX, nY, function ()
			Operation:OnDialogerClicked(nNpcID);
		end, Npc.DIALOG_DISTANCE);
		return;
	end

	if pNpc.IsAlone() then
		GameSetting:SetGlobalObj(me, pNpc, it);
		Npc:OnDialog(him.szClass, him.szScriptParam);
		GameSetting:RestoreGlobalObj();
	else
		RemoteServer.OnSimpleTapNpc(pNpc.nId);
	end

	if pNpc.szTag ~= "NoTurn" then
		Operation:Turn2Player(pNpc);
	end
end

function Operation:SetPositionEffect(bShow, nX, nY)
	RepresentMgr.SetTargetPositionEffect(bShow, nX or 0, nY or 0);
end

function Operation:Turn2Player(pNpc)
	local npcRep = RepresentMgr.GetNpcRepresent(pNpc.nId);
	if npcRep then
		npcRep.m_fChangerDirSpeed = 45;
	end

	local _, nX1, nY1 = pNpc.GetWorldPos();
	local _, nX2, nY2 = me.GetWorldPos();
	local nAngle = math.atan2(nX1 - nX2, nY1 - nY2);
	local nDir = (nAngle + math.pi) / (2 * math.pi) * Env.LOGIC_MAX_DIR;
	pNpc.SetDir(nDir);
end

local tbJumpType = {
	DoubleClick = 1;
	Slide = 2;
	Both = 3;
	None = 4;
}

local tbJumpTypeDesc = {
	[tbJumpType.None] = "关闭",
	[tbJumpType.Slide] = "滑动跳跃",
	[tbJumpType.DoubleClick] = "双击跳跃",
	[tbJumpType.Both] = "滑动双击跳跃",
}

Operation.nJumpType = Operation.nJumpType or tbJumpType.None;

function Operation:SwitchJumpType()
	self.nJumpType = self.nJumpType % (#tbJumpTypeDesc) + 1;
	local szTips = string.format("当前轻功模式为:%s", tbJumpTypeDesc[self.nJumpType]);
	me.CenterMsg(szTips);
end

function Operation.DoubleTap(nPosX, nPosY)
	if Operation.nJumpType ~= tbJumpType.Both and Operation.nJumpType ~= tbJumpType.DoubleClick then
		return;
	end

	if not Login.bEnterGame then --选择角色场景是没地图id的
		return
	end

	if me.GetDoing() == Npc.Doing.jump then
		return false;
	end

	Operation:JumpTo(nPosX, nPosY, false);
end

function Operation.Slide(nDirX, nDirY)
	if Operation.nJumpType ~= tbJumpType.Both and Operation.nJumpType ~= tbJumpType.Slide then
		return;
	end

	if not Login.bEnterGame then
		return
	end
	Operation:SetPositionEffect(false);
	Operation:JumpTo(nDirX, nDirY, true);
end

function Operation.LongTapStart(nNpcID, nScreenPosX, nScreenPosY)
end

function Operation:Attack(nSkillID, bAngerSkill)
	if Operation:IsNeedOpenPreciseUI(nSkillID)  then
		return
	end

	local bRet = Operation:JoyStickAttack(nSkillID);
	if bRet then
		Operation:SetPositionEffect(false);
	end
end

function Operation:_UseSkill(nSkillID, nTargetId, nDir, nX, nY)
	local nSelector = Operation:SkillSelectorTarget(nSkillID);
	if nSelector then
		nTargetId = nSelector;
	end

	local nSkillAttackType = FightSkill:GetSkillAttackType(nSkillID);
	if AutoFight:IsAuto() and not self.bOnJoyStick and nSkillAttackType ~= FightSkill.AttackType.Normal then
		local nType = AutoFight.MANUAL_SKILL_TYPE.NPC
		if (not nTargetId or nTargetId == 0) and nDir then
			AutoFight:ManualAttack(nSkillID, AutoFight.MANUAL_SKILL_TYPE.DIR, nDir);
		elseif nX and nY then
			AutoFight:ManualAttack(nSkillID, AutoFight.MANUAL_SKILL_TYPE.POS, nX, nY);
		else
			AutoFight:ManualAttack(nSkillID, AutoFight.MANUAL_SKILL_TYPE.NPC, nTargetId);
		end
	else
		if nTargetId and nTargetId ~= 0 then
			return Operation:UseSkillToNpc(nSkillID, nTargetId, true);
		elseif nDir then
			return Operation:UseSkillToDir(nSkillID, nDir);
		elseif nX and nY then
			return Operation:UseSkillToPos(nSkillID, nX, nY)
		end
	end
end

function Operation:JoyStickAttack(nSkillID)
	local nSkillAttackType = FightSkill:GetSkillAttackType(nSkillID);
	local nSkillAttackRadius = FightSkill:GetAttackRadius(nSkillID);
	local pNpc = me.GetNpc();
	local nDir = self.nLastGoDir or pNpc.GetDir();
	local nTargetId = nil;

	-- 摇杆普通攻击
	if nSkillAttackType == FightSkill.AttackType.Normal then
		nTargetId = Operation:GetNearestEnemyIdByDir(nDir, nSkillAttackRadius);
		nTargetId = nTargetId or Operation:GetNearestEnemyId(nSkillAttackRadius);

		return self:_UseSkill(nSkillID, nTargetId, nDir);
	end

	-- 摇杆强制方向攻击
	if nSkillAttackType == FightSkill.AttackType.Direction then
		if not self.bOnJoyStick then
			nTargetId = Operation:GetNearestEnemyIdByDir(nDir, nSkillAttackRadius)
						or Operation:GetNearestEnemyId(nSkillAttackRadius);
		end

		return self:_UseSkill(nSkillID, nTargetId, nDir);
	end

	-- 摇杆强制目标攻击
	if nSkillAttackType == FightSkill.AttackType.Target then
		nTargetId = Operation:GetNearestEnemyIdByDir(nDir, nSkillAttackRadius)
					or Operation:GetNearestEnemyId(nSkillAttackRadius);

		return self:_UseSkill(nSkillID, nTargetId);
	end

	assert(false, "SkillAttack表填错啦~~");
end

function Operation:SetNpcSelected(nNpcID)
	if Ui.bShowDebugInfo then
		local pNpc = KNpc.GetById(nNpcID);
		if pNpc then
			local szDebugInfo = "" ..
			"nId: " .. pNpc.nId .. "\n" ..
			"szName: " .. pNpc.szName .. "\n" ..
			"nLevel: " .. pNpc.nLevel .. "\n" ..
			"nTemplateId: " .. pNpc.nTemplateId .. "\n" ..
			"szClass: " .. pNpc.szClass .. "\n" ..
			"szScriptParam: " .. pNpc.szScriptParam .. "\n";
			Ui:SetDebugInfo(szDebugInfo);
		end
	end

	local eDoing = me.GetDoing();
	if eDoing == Npc.Doing.stand and nNpcID ~= me.GetNpc().nId then

		me.GetNpc().SetDirToNpc(nNpcID or 0);
	end

	local nCurSelectNpcId = RepresentMgr.GetTargetSelectNpcId();
	if not nNpcID or nNpcID == 0 or nNpcID == nCurSelectNpcId then
		return;
	end

	local npcRep = RepresentMgr.GetNpcRepresent(nNpcID);
	if npcRep then
		--Log("dddddddd[Operation.lua]1,me.nAttackSkillId=", me.nAttackSkillId);
		--Log("dddddddd[Operation.lua]2,nNpcID=", nNpcID);
		--Log("dddddddd[Operation.lua]3,GetSkillIdByBtnName=", FightSkill:GetSkillIdByBtnName(me.nFaction, "Attack"));
		--me.nAttackSkillId = me.nAttackSkillId or FightSkill:GetSkillIdByBtnName(me.nFaction, "Attack");
		local nBaseSkill = FightSkill:GetCurBaseSkill()
		--Log("CCCCCCCC[CheckSkillAvailable2Npc_4]", nBaseSkill, nNpcID);
		local bCanAttack = me.CheckSkillAvailable2Npc(nBaseSkill, nNpcID) and true or false;
		if not bCanAttack then
			npcRep:SetSelectedEffect(true, bCanAttack);
			npcRep:PlayNpcEffect(13, 1, false); -- 13为选中时的特效id
		end
	end
end

function Operation:UnselectNpc()
	AutoAI.SetTargetIndex(0);

	local nCurSelectNpcId = RepresentMgr.GetTargetSelectNpcId();
	if nCurSelectNpcId == 0 then
		return;
	end

	local npcRep = RepresentMgr.GetNpcRepresent(nCurSelectNpcId);
	if npcRep then
		npcRep:SetSelectedEffect(false, false);
	end
end

function Operation:ManualJump(nJumpSkillId)
	local pNpc = me.GetNpc();
	local  nDir = self.nLastGoDir or (pNpc and pNpc.GetDir());
	if not nDir  then
		return
	end

	local nDistance, nDstX, nDstY = me.GetCanMoveDistance(nDir, 100);
	if nDistance <= 0 then
		return
	end

	self:DoJump(nJumpSkillId, nDstX, nDstY, false, false);
end

function Operation:JumpTo(nX, nY, bSlide)
	local nJumpSkillId = Faction:GetJumpSkillId(me.nFaction, 10);
	self:DoJump(nJumpSkillId, nX, nY, bSlide, false);
end

function Operation:ForceJump(nX, nY, nSkillKindId)
	local nJumpSkillId = Faction:GetJumpSkillId(me.nFaction, nSkillKindId or 2);
	self:DoJump(nJumpSkillId, nX, nY, false, true);
end

function Operation:DoJump(nJumpSkillId, nX, nY, bSlide, bTrap)
	local nDoing = me.GetDoing();
	if AutoFight:IsAuto() and nDoing ~= Npc.Doing.sit then
		AutoFight:ManualJumpTo(nJumpSkillId, nX, nY, bSlide, bTrap);
	else
		me.JumpTo(nJumpSkillId, nX, nY, bSlide, bTrap);
	end

	if nDoing == Npc.Doing.jump then
		Operation:SetPositionEffect(false);
	end
end

function Operation:UseSkillToNpc(nSkillID, nNpcID, bNotSelector)
	if not bNotSelector then
		local nSelector = Operation:SkillSelectorTarget(nSkillID);
		if nSelector then
			nNpcID = nSelector;
		end
	end

	if not nNpcID or nNpcID == 0 then
		nNpcID = me.GetNpc().nId;
	end

	if not me.CanCastSkill(nSkillID) then
		return false;
	end

	local bRet = me.UseSkill(nSkillID, -1, nNpcID);
	if self.bOnJoyStick then
		Operation.GoDirection(self.nLastGoDir);
	end

	self:CacheLastTargetNpcId(nNpcID);
	return bRet;
end

function Operation:UseSkillToPos(nSkillID, nPosX, nPosY)
	local bRet = me.UseSkill(nSkillID, nPosX, nPosY);
	if self.bOnJoyStick then
		Operation.GoDirection(self.nLastGoDir);
	end
	return bRet;
end

function Operation:UseSkillToDir(nSkillID, nDir)
	local bRet = me.UseSkillToDir(nSkillID, nDir);
	if self.bOnJoyStick then
		Operation.GoDirection(self.nLastGoDir);
	end
	return bRet;
end

function Operation:OnKinDPGatherClicked(pNpc)
	local bMature, nMatureId, nUnMatureId, nMatureTime = KinDinnerParty:ResolveGatherParam(pNpc.szScriptParam);
	if not KinDinnerParty:GatherThingInTask(me, nMatureId) then
		return;
	end

	local nMapTemplateId, nX1, nY1 = pNpc.GetWorldPos();
	local _, nX2, nY2 = me.GetWorldPos();
	local nDistance = math.abs(nX2 - nX1) + math.abs(nY2 - nY1);
	if nDistance > 300 then
		local fnCallBack = function ()
			RemoteServer.OnSimpleTapNpc(pNpc.nId);
		end
		AutoPath:GotoAndCall(nMapTemplateId, nX1, nY1, fnCallBack)
	else
		RemoteServer.OnSimpleTapNpc(pNpc.nId);
	end
end

function Operation:OnGatherClicked(pNpc)
	local bMature, nMatureId, nUnMatureId, nMatureTime = CommerceTask:ResolveGatherParam(pNpc.szScriptParam);
	if not CommerceTask:GatherThingInTask(me, nMatureId) then
		return;
	end

	local nMapTemplateId, nX1, nY1 = pNpc.GetWorldPos();
	local _, nX2, nY2 = me.GetWorldPos();
	local nDistance = math.abs(nX2 - nX1) + math.abs(nY2 - nY1);
	if nDistance > 300 then
		local fnCallBack = function ()
			RemoteServer.OnSimpleTapNpc(pNpc.nId);
		end
		AutoPath:GotoAndCall(nMapTemplateId, nX1, nY1, fnCallBack)
	else
		RemoteServer.OnSimpleTapNpc(pNpc.nId);
	end
end


Operation.tbTargetModeSelectList = {
	[Operation.eTargetModeNpcFirst] = {
		{2^Npc.RELATION.enemy + 2^Npc.RELATION.npc, 2^Npc.RELATION.npc_call + 2^Npc.RELATION.hide_grass},
		{2^Npc.RELATION.enemy + 2^Npc.RELATION.player, 2^Npc.RELATION.hide_grass},
		{2^Npc.RELATION.enemy + 2^Npc.RELATION.npc_call, 2^Npc.RELATION.hide_grass},
	};
	[Operation.eTargetModePlayerFirst] = {
		{2^Npc.RELATION.enemy + 2^Npc.RELATION.player, 2^Npc.RELATION.hide_grass},
		{2^Npc.RELATION.enemy + 2^Npc.RELATION.npc, 2^Npc.RELATION.npc_call + 2^Npc.RELATION.hide_grass},
		{2^Npc.RELATION.enemy + 2^Npc.RELATION.npc_call, 2^Npc.RELATION.hide_grass},
	};
	[Operation.eTargetModeUnlimited] = {
		{2^Npc.RELATION.enemy, 2^Npc.RELATION.hide_grass},
	};
};

function Operation:GetNearestEnemyId(nRadius)
	local pNpc = me.GetNpc();
	if not pNpc then
		return;
	end

	nRadius = nRadius or 10000;
	local nSelectMode = Operation:GetSelectTargetMode();
	local tbSelectList = self.tbTargetModeSelectList[nSelectMode] or {};
	for _, tbRelationInfo in ipairs(tbSelectList) do
		local nEnemyId = pNpc.GetNearestNpcIdByRelation(nRadius, unpack(tbRelationInfo));
		if nEnemyId then
			return nEnemyId;
		end
	end
end

function Operation:GetNearestEnemyIdByDir(nDir, nRadius)
	local pNpc = me.GetNpc();
	if not pNpc then
		return;
	end

	-- 若上次攻击对象在朝向有效范围内，则优先选择
	if Operation:IsLastTargetNpcOnDir(nDir, nRadius) then
		return self.nLastTargetNpcId;
	end

	nRadius = nRadius or 10000;
	local nSelectMode = Operation:GetSelectTargetMode();
	local tbSelectList = self.tbTargetModeSelectList[nSelectMode] or {};
	for _, tbRelationInfo in ipairs(tbSelectList) do
		local nEnemyId = pNpc.GetNearestNpcIdByDir(nDir, nRadius, unpack(tbRelationInfo));
		if nEnemyId then
			return nEnemyId;
		end
	end
end

function Operation:CacheLastTargetNpcId(nNpcId)
	self.nLastTargetNpcId = nNpcId;
end

function Operation:IsLastTargetNpcOnDir(nDir, nRadius)
	if self.nLastTargetNpcId then
		local nTargetNpcDir = self:GetTargetNpcDir4Me(self.nLastTargetNpcId);
		if nTargetNpcDir then
			local pNpc = me.GetNpc();
			if not pNpc then
				return;
			end
			if pNpc.GetDistance(self.nLastTargetNpcId) <= nRadius then
				local nDirDiff = math.abs(nDir - nTargetNpcDir);
				nDirDiff = (nDirDiff > (Env.LOGIC_MAX_DIR / 2)) and (Env.LOGIC_MAX_DIR - nDirDiff) or nDirDiff;
				if nDirDiff <= (Env.LOGIC_MAX_DIR / 8) then
					return true;
				end
			end
		else
			self.nLastTargetNpcId = nil;
		end
	end
end

function Operation:GetTargetNpcDir4Me(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc or pNpc.IsDeath() then
		return;
	end

	local _, nX1, nY1 = pNpc.GetWorldPos();
	local _, nX2, nY2 = me.GetWorldPos();
	local nAngle = math.atan2(nX2 - nX1, nY2 - nY1);
	local nDir = (nAngle + math.pi) / (2 * math.pi) * Env.LOGIC_MAX_DIR;

	return nDir;
end

function Operation:SkillSelectorTarget(nSkillId, pNpc)
	if not pNpc then
		pNpc = me.GetNpc();
	end

    local tbSelectorInfo = FightSkill:GetSelectorSkill(nSkillId);
    if not tbSelectorInfo or not pNpc then
    	return;
    end

    local nType = FightSkill.tbSelectorType[tbSelectorInfo.SelectorType];
    if not nType then
    	return;
    end

    local pSelector = KNpc.SelectorNpc(pNpc.nId, nType, tbSelectorInfo.SelectorRange, tbSelectorInfo.Relation);
    if not pSelector then
    	return;
    end

    return pSelector.nId;
end

function Operation:GetNearestEnemyIdByPos(nRadius, nX, nY)
	nRadius = nRadius or 10000

	local nRelationUnlimited = 2^Npc.RELATION.enemy;
	local nSelectMode = Operation:GetSelectTargetMode();
	if nSelectMode == Operation.eTargetModeNpcFirst then
		return AutoAI.GetNearestNpcByPosition(nX, nY, nRadius, nRelationUnlimited + 2^Npc.RELATION.npc)
				or AutoAI.GetNearestNpcByPosition(nX, nY, nRadius, nRelationUnlimited);
	elseif nSelectMode == Operation.eTargetModePlayerFirst then
		return AutoAI.GetNearestNpcByPosition(nX, nY, nRadius, nRelationUnlimited + 2^Npc.RELATION.player)
				or AutoAI.GetNearestNpcByPosition(nX, nY, nRadius, nRelationUnlimited);
	end

	return AutoAI.GetNearestNpcByPosition(nX, nY, nRadius, nRelationUnlimited);
end

function Operation.OnTouchReturn(szTopUi, bClose)
	if szTopUi then
		if bClose then
			Ui:CloseWindow(szTopUi);
		elseif szTopUi ~= "" then
			local tbWnd = Ui(szTopUi)
			if tbWnd and tbWnd.OnTouchReturn then
				tbWnd:OnTouchReturn();
			end
		end
	else
		Sdk:Exit();
	end
end


-- Windows客户端下配置快捷键用于测试
local tbKeyFun = {
--[[	a = function ()
		Operation:Attack(410);
	end;
	s = function ()
		Operation:Attack(407);
	end;
	d = function ()
		Operation:Attack(406);
	end;
	f = function ()
		Operation:Attack(412);
	end;
	w = function ()
		Operation:Attack(401);
	end;--]]
};

function Operation:KeyDown(szKeys)
	if not Login.bEnterGame then
		return;
	end

	for i = 1, #szKeys do
		local szKey = string.sub(szKeys, i, i);
		if tbKeyFun[szKey] then
			tbKeyFun[szKey]();
		end
	end
end

function Operation:GetSelectTargetMode()
	if not me.IsUserValueValid() then --无差别变身情况下
		return Client:GetFlag("SelectTargetModeAvatar") or (Client:GetFlag("SelectTargetMode") or Operation.eTargetModeUnlimited)
	else
		return Client:GetFlag("SelectTargetMode") or Operation.eTargetModeUnlimited;
	end
end

function Operation:SetSelectTargetMode(nMode)
	local szKey = me.IsUserValueValid() and "SelectTargetMode" or "SelectTargetModeAvatar"
	Client:SetFlag(szKey, nMode or Operation.eTargetModeUnlimited);
end

function Operation:SetPreciseSkillOp()
	Ui:GetPlayerSetting().nPreciseSkillOp= math.mod((Ui:GetPlayerSetting().nPreciseSkillOp or 0) + 1, 2)
end

--是否开启精准操作释放技能
function Operation:IsPreciseSkillOp()
	local tbUserSet = Ui:GetPlayerSetting();

	return tbUserSet.nPreciseSkillOp == 1;
end

function Operation:IsNeedOpenPreciseUI(nSkillID)
	return FightSkill:GetPreciseCastSkill(nSkillID) and self:IsPreciseSkillOp();
end

function Operation:OpenPreciseUI(nSkillID)
	SkillController.SetJoyStick(true);
	self.nCurPreciseCastSkill = nSkillID

	UiNotify.OnNotify(UiNotify.emNOTIFY_PRECISE_CAST, true)

	self.bCancelPreciseCast = false;

	local pNpc = me.GetNpc()
	if not pNpc then
		return
	end

	local npcRep = RepresentMgr.GetNpcRepresent(pNpc.nId);
	if not npcRep then
		return
	end

	self.tbCurSkillPreciseInfo = FightSkill:GetPreciseCastSkill(nSkillID);
	if not self.tbCurSkillPreciseInfo then
		return
	end

	local nCastRadius = self.tbCurSkillPreciseInfo.CastRadius/100;
	local nDamageRadius = self.tbCurSkillPreciseInfo.DamageRadius/100;


	npcRep:PlayNpcEffect(self.PRECISE_CIRCLE_EFFECT, 1, true);
	npcRep:SetEffectScale(self.PRECISE_CIRCLE_EFFECT, nCastRadius, 1, nCastRadius);

	if self.tbCurSkillPreciseInfo.CastType == "direction"  then
		SkillController.BindNpcEffect(EffectMoveType.Rotate, pNpc.nId, self.PRECISE_ARROW_EFFECT, nCastRadius, 0.05);
		npcRep:PlayNpcEffect(self.PRECISE_ARROW_EFFECT, 1, true);
		npcRep:SetEffectScale(self.PRECISE_ARROW_EFFECT, nCastRadius*0.7, 1, nCastRadius);

		local nOrgTargetNpcId = Operation:GetNearestEnemyId(self.tbCurSkillPreciseInfo.CastRadius);
		self.nStartPreciseDirectionSkillDir = nOrgTargetNpcId and self:GetTargetNpcDir4Me(nOrgTargetNpcId) or pNpc.GetDir();

		npcRep:SetEffectDir(self.PRECISE_ARROW_EFFECT, (self.nStartPreciseDirectionSkillDir + Env.LOGIC_MAX_DIR / 2) % Env.LOGIC_MAX_DIR)
	elseif self.tbCurSkillPreciseInfo.CastType == "target" then
		SkillController.BindNpcEffect(EffectMoveType.Move, pNpc.nId, self.PRECISE_TARGET_EFFECT, nCastRadius, 0.05);
		npcRep:PlayNpcEffect(self.PRECISE_TARGET_EFFECT, 1, true);
		npcRep:SetEffectRotate(self.PRECISE_TARGET_EFFECT, 0,0,0);
		npcRep:SetEffectScale(self.PRECISE_TARGET_EFFECT, nDamageRadius, 1, nDamageRadius);
		local nTargetId = Operation:GetNearestEnemyId(self.tbCurSkillPreciseInfo.CastRadius);
		if nTargetId and nTargetId ~= 0 then
			local pNpc = KNpc.GetById(nTargetId);
			if pNpc then
				local _,nX,nY = pNpc.GetWorldPos();
				npcRep:SetEffectWorldPosition(self.PRECISE_TARGET_EFFECT, nX,nY);
			end
		end
	end
end

function Operation:ClosePreciseUI()
	SkillController.SetJoyStickUp();
	self:ClearPreciseOPEffect()
end

function Operation:IsCancelPreciseCast ()
	return self.bCancelPreciseCast
end

function Operation:OnSkillControllerTouchStart()
end

function Operation.OnSkillControllerTouchUp()
	UiNotify.OnNotify(UiNotify.emNOTIFY_PRECISE_TOUCH_UP)

	UiNotify.OnNotify(UiNotify.emNOTIFY_PRECISE_CAST, false)

	if not Operation.nCurPreciseCastSkill then
		Operation:ClearPreciseOPEffect()
		return
	end

	local nSkillId = Operation.nCurPreciseCastSkill
	Operation.nCurPreciseCastSkill = nil

	if Operation:IsCancelPreciseCast() then
		Operation:ClearPreciseOPEffect()
		return
	end

	Operation:SetCancelPreciseCast(true);

	if Operation.tbCurSkillPreciseInfo.CastType == "direction"  then
		local nDir = SkillController.GetJoyStickDir();
		if nDir < 0 or not SkillController.s_bAlreadyFirstUpdate then
			nDir = Operation.nStartPreciseDirectionSkillDir or nDir;
		end

		Operation:_UseSkill(nSkillId, nil, nDir);
	elseif Operation.tbCurSkillPreciseInfo.CastType == "target" then
		local vecPos = SkillController.GetTargetPos()

		Operation:_UseSkill(nSkillId, nil, nil, vecPos.x, vecPos.y);
	end
	Operation:ClearPreciseOPEffect()
end

function Operation:ClearPreciseOPEffect()
	local pNpc = me.GetNpc()
	if not pNpc then
		return
	end

	local npcRep = RepresentMgr.GetNpcRepresent(pNpc.nId);
	if not npcRep then
		return
	end

	npcRep:ClearPlayNpcEffect(self.PRECISE_CIRCLE_EFFECT, true)
	npcRep:ClearPlayNpcEffect(self.PRECISE_ARROW_EFFECT, true)
	npcRep:ClearPlayNpcEffect(self.PRECISE_TARGET_EFFECT, true)
end

function Operation:SetCancelPreciseCast(bCancel)
	self.bCancelPreciseCast = bCancel;
end

Operation.tbKEY2BUTTON =
{
	R1 = "SkillDodge";
	R2 = "Attack";
	L1 = "BtnDazuo";
	L2 = "Skill5";
	A = "Skill1",
	B = "Skill4",
	X = "Skill2",
	Y = "Skill3",
}

function Operation.OnGamesirStickClick(szKeyName)
	if not Login.bEnterGame then
		return;
	end
	local tbUiBattle = Ui("HomeScreenBattle")
	local szButton = Operation.tbKEY2BUTTON[szKeyName]
	if tbUiBattle and szButton and tbUiBattle.tbOnClick[szButton] then
		tbUiBattle.tbOnClick[szButton](tbUiBattle);
	end
 end


function Operation:InitGamesir()
	if version_tx then
		--if ANDROID and not Ui.ToolFunction.IsEmulator() then
		--	TouchMgr.InitGamesirStick()
		--end
	end
end

function Operation:ConnectGamesir()
	if version_tx then
		TouchMgr.TryConnectGamesir()
	end
end

function Operation:OnHorseClick()
	if not Login.bEnterGame then
		return;
	end
 	local tbUiBattle = Ui("RoleHead")
 	if tbUiBattle and tbUiBattle.tbOnClick["BtnMount"] then
 		tbUiBattle.tbOnClick["BtnMount"](tbUiBattle);
 	end
end

function Operation:DisableClickMap()
	self.bForbidClickMap = true;
end

function Operation:EnableClickMap()
	self.bForbidClickMap = false;
end


function Operation:UpdateAssistState()
	if self:CheckAdjustView() then
		--self:DisableClickMap()
	end
end

function Operation:CheckAdjustView()
	return self:IsAssistMap() and Operation:GetAdjustViewState()
end

function Operation:IsAssistMap(nTemplateID)
	return self.tbAssistMap[nTemplateID or me.nMapTemplateId] and true or false;
end

function Operation.OnTouchStart(nX, nY)
	if Operation:CheckAdjustView() then
		Operation.tbViewTouchPos = {nX, nY};
		--if Ui:WindowVisible("PhotoStretchingPanel") == 1 then
		--	UiNotify.OnNotify(UiNotify.emNOTIFY_NEW_PHOTO_STATE_EVENT, "SetSeletedInvisible");
		--end
	end
end

function Operation.OnTouchDown(nX, nY)
	Operation:TrySpinCamera(nil, nX, nY)
end

function Operation:TryChangeCamera(nX, nY)

end

-- 双指或单指支持旋转
function Operation:TrySpinCamera(nDistance, nX, nY)
	if self:CheckAdjustView() then
		if nDistance or Operation.tbViewTouchPos then
			local nSlideDistance = 0
			if nDistance then
				nSlideDistance = nDistance
			elseif nX and nY and Operation.tbViewTouchPos then
				local nStartX, nStartY = unpack(Operation.tbViewTouchPos)
				nSlideDistance = nX - nStartX
				Operation.tbViewTouchPos = {nX, nY}
			end
			if nSlideDistance ~= 0 then
				local nActChange = nSlideDistance * Operation.nSpinSpeed * nReverseY
				Ui.CameraMgr.ChangeCarermaRotionY(nActChange, Operation.nRotationSpeed)
				self.nChangeY = (self.nChangeY or 0) + nActChange
				Operation:CloseStopCameraCrossRoateTimer()
			end
		end
	end
end

function Operation.OnTouchUp(nX, nY)
	Operation.tbViewTouchPos = nil
	if Operation:CheckAdjustView() then
		Operation:DoSaveChangeY()
        --Operation:DoSaveChangePhotoSetting()
	end
	Operation:StartStopCameraCrossRoateTimer()
end

function Operation.OnTouchStart2Fingers(nDeltaDistance)
	Operation.n2FingersDistance = nDeltaDistance
end

function Operation.OnTouchDown2Fingers(nDeltaDistance)
	if Operation:CheckAdjustView() and Operation.n2FingersDistance and nDeltaDistance ~= 0 then
		local nChange = nDeltaDistance - Operation.n2FingersDistance
		if nChange ~= 0 and math.abs(nChange) <= n2FingersMaxChange then
			-- 摇杆移动中不缩放要旋转
			if not Operation.bOnJoyStick then
				local nDistance, nAngle, nViewField = Operation:GetChangeByDistance(nChange * nReverse, Operation.n2FingerSpeed)
				local nSaveDistance = Client:GetFlag(Operation.szCameraSettingKey, Operation.nSaveCameraSettingDistance)
				if not nSaveDistance or nSaveDistance ~= nDistance then
					Ui.CameraMgr.ChangeCameraSetting(nDistance, nAngle, nViewField)
					UiNotify.OnNotify(UiNotify.emNOTIFY_CAMERA_SETTING_CHANGE)
				end
			else
				Operation:TrySpinCamera(nChange)
			end
		end
		Operation.n2FingersDistance = nDeltaDistance
	end
end

function Operation.OnTouchUp2Fingers()
	Operation.n2FingersDistance = nil
	if Operation:GetAdjustViewState() then
		Operation:DoSaveCameraSetting()
	end
end

function Operation:UpdateCameraSettingView(bMapLoad)
	if not Operation:IsAssistMap(me.nMapTemplateId) then
		return
	end
	local bAdjustView = Operation:GetAdjustViewState()
	local nDistance = Client:GetFlag(Operation.szCameraSettingKey, Operation.nSaveCameraSettingDistance) or Operation.nMaxCameraDistance
	local nAngle = Client:GetFlag(Operation.szCameraSettingKey, Operation.nSaveCameraSettingAngle) or Operation.nMaxCameraAng
	local nViewField = Client:GetFlag(Operation.szCameraSettingKey, Operation.nSaveCameraSettingField) or Operation.nMaxViewField
	local nChangeY = Client:GetFlag(Operation.szCameraSettingKey, Operation.nSaveCameraSettingChangeY) or 0
	if not bAdjustView then
		nDistance = Operation.nJianAnDefaultDistance
		nAngle = Operation.nJianAnDefaultAng
		nViewField = Operation.nJianAnDefaultField
		nChangeY = -nChangeY
	end
	local szSceneName = SceneMgr.GetActiveScene().name
	local nMapTemplateId = me.nMapTemplateId and me.nMapTemplateId > 0 and me.nMapTemplateId or self.nDstMaptemplateId
	local szMapResName = Map:GetMapResName(nMapTemplateId)
	-- 针对快速切两次地图的情况优化,延迟切换视角
	if szSceneName == szMapResName then
		Ui.CameraMgr.ChangeCameraSetting(nDistance, nAngle, nViewField)
	else
		Timer:Register(5 * Env.GAME_FPS, function ()
				if Operation:IsAssistMap(me.nMapTemplateId) then
					Ui.CameraMgr.ChangeCameraSetting(nDistance, nAngle, nViewField)
				end
			end)
			Log("[Operation] SceneName is Not same as MapResName !!!", szSceneName, szMapResName, me.nMapTemplateId)
	end
	if bMapLoad and not bAdjustView then
		nChangeY = 0
	end
	if nChangeY ~= 0 then
		if bAdjustView then
			Ui.CameraMgr.ChangeCarermaRotionXY(0, nChangeY)
			self.nChangeY = nChangeY;
			self.nChangeAngle = nAngle;
		else
			Ui.CameraMgr.CreateCameraCrossRoate(Operation.nJianAnDefaultRotateX, Operation.nJianAnDefaultRotateY, Operation.nJianAnDefaultRotateZ, 10)
		end
		Operation:CloseStopCameraCrossRoateTimer()
		Operation:StartStopCameraCrossRoateTimer()
	end

end

function Operation:OnEnterMap(nTemplateID)

end

function Operation:OnMapLoadedFinish(nMapTemplateID)
	if Operation:IsAssistMap(nTemplateID) then
		Operation:UpdateCameraSettingView(true)
		TouchMgr.SetAdjustCamera(true);
		if Operation:GetAdjustViewState() then
--			Operation:DisableClickMap()
		end
	else
		TouchMgr.SetAdjustCamera(false);
--		Operation:EnableClickMap()
		Ui:CloseWindow("ViewPanel")
		Ui:CloseWindow("FrameSettingPanel")
		--Operation:QuiteAssistUiState();
	end
end

function Operation:StartScreenShotState()
	if Ui:WindowVisible("ViewPanel") == 1 then
		me.CenterMsg("请先完成当前操作")
		return
	end
	Ui:ChangeUiState(Ui.STATE_ViewPhoto);
	UiNotify.OnNotify(UiNotify.emNOTIFY_VIEW_STATE_CHANGE)
	Ui:OpenWindow("PhotographPanel")
	Ui:OpenWindow("ViewPanel", true)
end

function Operation:EndScreenShotState()
	UiNotify.OnNotify(UiNotify.emNOTIFY_VIEW_STATE_CHANGE, true)
   	Ui:ChangeUiState(Ui.STATE_DEFAULT, true)
   	Ui:CloseWindow("ViewPanel")
end

function Operation:TakeScreenShot(fnTake, bLogo)
	Ui:CloseWindow("ViewPanel")
	UiNotify.OnNotify(UiNotify.emNOTIFY_SHARE_PHOTO, bLogo);
	UiNotify.OnNotify(UiNotify.emNOTIFY_REFRESH_QYH_BTN, nil, {"BtnLeave"})
    Timer:Register(3, function ()
        fnTake();
        return false;
    end);

    Timer:Register(8, function ()
    	Ui:OpenWindow("ViewPanel", true)
        UiNotify.OnNotify(UiNotify.emNOTIFY_SHARE_PHOTO_END, bLogo);
        UiNotify.OnNotify(UiNotify.emNOTIFY_REFRESH_QYH_BTN, nil, {"BtnLeave"}, true)
        return false;
    end);
end

function Operation:OpenAssistHelpClicker()
	local nGuide = Client:GetFlag(Operation.szCameraSettingKey, Operation.nSaveCameraSettingGuide)
	if Operation:IsAssistMap() and not nGuide then
		-- 为了解决层级问题才重新打开（rolehead挡住导引头像）
		Ui:CloseWindow("ChatSmall")
		Ui:OpenWindow("ChatSmall", true)
	end
end

-- 现在旋转动画那边有个bug，导致手动结束旋转动画
function Operation:StartStopCameraCrossRoateTimer()
	if self.nTimerStopCameraCrossRoate then
		return
	end
	self.nTimerStopCameraCrossRoate = Timer:Register(Env.GAME_FPS * 2, function ()
		Ui.CameraMgr.StopCameraCrossRoate()
		self.nTimerStopCameraCrossRoate = nil
	end)
end

function Operation:CloseStopCameraCrossRoateTimer()
	if self.nTimerStopCameraCrossRoate then
		Timer:Close(self.nTimerStopCameraCrossRoate)
		self.nTimerStopCameraCrossRoate = nil
	end
end

function Operation:QuiteAssistUiState()
	if Ui:WindowVisible("ViewPanel") == 1 then
		Ui:CloseWindow("ViewPanel")
	end
	if Ui:WindowVisible("PhotographPanel") == 1 then
		Operation:EndScreenShotState()
		Ui:CloseWindow("PhotographPanel")
	end
	Ui:CloseWindow("FrameSettingPanel");

	if Operation.bIsNewPhotoState then
		Ui:CloseWindow("PhotoBeautifyPanel");
		Ui:CloseWindow("PhotoHidePanel");
		Operation:EndNewPhotoState();
	end
end

function Operation:OnPlayerSetPos()
	if Operation.bOnJoyStick then
		Operation:StopMoveNow();
	end
end

function Operation:ChangeActionPlayState()
	local nNpcId = me.GetNpc().nId;
	local rep = Ui.Effect.GetNpcRepresent(nNpcId);
	Operation.bSuspendAction = not Operation.bSuspendAction;
	if Operation.bSuspendAction then
		rep:PauseAnimation();
	else
		rep:ContinuePlayAnimation();
	end
end

UiNotify:RegistNotify(UiNotify.emNOTIFY_SYNC_PLAYER_SET_POS, Operation.OnPlayerSetPos, Operation);
