
local tbUi = Ui:CreateClass("HomeScreenFuben");
tbUi.nGuideLen = 200;
tbUi.tbGuideCenterPos = {x = -568, y = 0};

function tbUi:OnOpen(szType, tbFubenInfo)
	self:Update(0, 0);
	self:Clear();
	self.pPanel:Label_SetText("FubenLastTime", "--");
	self.pPanel:SetActive("FubenLastTime", true);
	self.pPanel:SetActive("Infos", true)
	self.pPanel:SetActive("BtnProcess", false);
	self.pPanel:SetActive("BtnMarketStall", false)
	self.pPanel:SetActive("BtnAuction", false)
	self.pPanel:SetActive("MarketStallTimesBg", false)
	self.szType = szType or "normal";
	self.nGuideRangenRadius = 100
	if self.szType == "KinNest" then
		--self.pPanel:SetActive("FubenLastTime", false);
		--self:SetEndTime(tbFubenInfo.nEndTime)
	elseif self.szType == "DungeonFuben" then
		self:SetFubenProgress(nil, tbFubenInfo.szName);
		Fuben:SetEndTime(tbFubenInfo.nEndTime);
		self:SetEndTime(tbFubenInfo.nEndTime);
		if tbFubenInfo.bOwner then
			self.pPanel:SetActive("BtnInvite", true);
			self.BtnInvite.pPanel:SetActive("tuoguan", true);
		end
	elseif self.szType == "PartnerCardTripFuben" then
		self:SetFubenProgress(nil, tbFubenInfo.szName);
		Fuben:SetEndTime(tbFubenInfo.nEndTime);
		self:SetEndTime(tbFubenInfo.nEndTime);
		if tbFubenInfo.bOwner then
			self.pPanel:SetActive("BtnInvite", true);
			self.BtnInvite.pPanel:SetActive("tuoguan", true);
		end
	elseif self.szType == "WhiteTigerFuben" then
		self.pPanel:SetActive("ItemCoinSet", false)
		self.pPanel:SetActive("ItemCoinSet2", false)
		self.pPanel:SetActive("WhiteTigerFubenHelp", true)
		tbFubenInfo = tbFubenInfo or {0, false}
		local nTime = tbFubenInfo[1] or 0
		local bShowLeave = tbFubenInfo[2] or false
		self.pPanel:SetActive("FubenLastTime", nTime > 0)
		self.pPanel:SetActive("Sprite", nTime > 0)
		self.pPanel:SetActive("BtnLeaveFuben", bShowLeave)
		if nTime > 0 then
			if tbFubenInfo[3] then
				self:SetEndTime(nTime)
			else
				self:SetEndTime(nTime + GetTime())
			end
		end
	elseif self.szType == "TeamFuben" or self.szType == "RandomFuben" then
		self.pPanel:SetActive("ItemCoinSet", false);
	elseif self.szType == "KinTrain" then
		self.pPanel:SetActive("ItemCoinSet", false)
	elseif self.szType == "KinSecretFuben" then
		self.pPanel:SetActive("BtnHelp", true)
		self.pPanel:ResetGeneralHelp("BtnHelp", "KinSecretFubenHelp")

		self.pPanel:Label_SetText("NumberTxt", string.format("当前人数：%d", Fuben.KinSecretMgr.nJoinCount or 0))
		self.pPanel:SetActive("NumberTxt", true)
		self.pPanel:Label_SetText("FamilyMijingInfoTxt", string.format("头目吸魂数量：%d", Fuben.KinSecretMgr.nDeathCount or 0))
		self.pPanel:SetActive("FamilyMijingInfo", true)
	elseif self.szType == "XinShouFuben" then
		self.pPanel:SetActive("Infos", false)
		self.pPanel:SetActive("Direction", true)
	elseif self.szType == "normal" then
		self.pPanel:SetActive("ItemCoinSet", false);
	elseif self.szType == "SeriesFuben" then
		self.pPanel:SetActive("BtnLeaveFuben", false)
	elseif self.szType == "ArborDayCureAct" then
		self.pPanel:SetActive("FubenLastTime", false)
		self.pPanel:SetActive("BtnLeaveFuben", true)
	elseif self.szType == "WeddingFuben" then
		self.pPanel:SetActive("ItemCoinSet", false);
		self.pPanel:SetActive("Marry", true);
		self.pPanel:SetActive("BtnInvitation", false);
		self.pPanel:SetActive("BtnCash", true);
		self.pPanel:SetActive("BtnCamera", true);
		self.pPanel:SetActive("BtnBlessing", true);
		self.pPanel:SetActive("BtnCandy", false);
		self.pPanel:SetActive("BtnProcess", true);
		self.pPanel:SetActive("BtnBag" ,true);
		self.pPanel:SetActive("BtnMarketStall", true)
		self.pPanel:SetActive("BtnAuction", true)
	elseif self.szType == "WeddingFubenRole" then
		self.pPanel:SetActive("ItemCoinSet", false);
		self.pPanel:SetActive("Marry" , true);
		self.pPanel:SetActive("BtnInvitation" ,true);
		self.pPanel:SetActive("BtnCash" ,true);
		self.pPanel:SetActive("BtnCamera" ,true); 
		self.pPanel:SetActive("BtnBlessing" ,false);
		self.pPanel:SetActive("BtnCandy", false);
		self.pPanel:SetActive("BtnProcess", true);
		self.pPanel:SetActive("BtnBag" ,true);
		if tbFubenInfo and tbFubenInfo.bWeddingCandy then
			self:SetWeddingBtnActive("BtnCandy", true)
		end
		self.pPanel:SetActive("BtnMarketStall", true)
		self.pPanel:SetActive("BtnAuction", true)
	elseif self.szType == "WeddingTour" then
		self.pPanel:SetActive("ItemCoinSet", false);
		self.pPanel:SetActive("Sprite", false)
		self.pPanel:SetActive("Marry" , true);
		self.pPanel:SetActive("BtnInvitation" ,false);
		self.pPanel:SetActive("BtnCash" ,false);
		self.pPanel:SetActive("BtnCamera" ,false);
		self.pPanel:SetActive("BtnCandy" ,false);
		self.pPanel:SetActive("BtnBlessing" ,false);
	elseif self.szType == "HousePeach" then
		self.pPanel:SetActive("FubenLastTime", false);
		self.pPanel:SetActive("BtnInvite", House.tbPeach:InMyFairyland());
		self.BtnInvite.pPanel:SetActive("tuoguan", false);
		self.pPanel:SetActive("BtnLeaveFuben", true);
		self.pPanel:SetActive("Sprite", false);
	elseif self.szType == "KeyQuestFuben" then
		local nFloor = tbFubenInfo.nFloor 
		self.pPanel:SetActive("BtnLeaveFuben", nFloor == #Fuben.KeyQuestFuben.DEFINE.FIGHT_MAP_ID)
	-- else
	-- 	self.pPanel:SetActive("ItemCoinSet", true);--并未发现有使用的，就不默认显示了
	end

	if self.nGuideX and not self.nGuideTimerId then
		self:UpdateGuide();
	end

	if self.szType == "normal" or self.szType == "DungeonFuben" or self.szType == "KinNest" or
		self.szType == "KinSecretFuben" or self.szType == "PartnerCardTripFuben" then
		self.pPanel:SetActive("BtnLeaveFuben", true);
	end

	self.bOpen = true;
	self:OnFubenTargetChange();
end

function tbUi:Clear()
	self.pPanel:SetActive("BtnLeaveFuben", false);
	self.pPanel:SetActive("Direction", false);
	self.pPanel:SetActive("ScroePanel", false);
	self.pPanel:SetActive("Persent", false);
	self.pPanel:SetActive("TargetInfo", false);
	self.pPanel:SetActive("ItemCoinSet", false);
	self.pPanel:SetActive("ItemCoinSet2", false);
	self.pPanel:SetActive("BtnInvite" ,false);
	self.pPanel:SetActive("WhiteTigerFubenHelp" ,false);
	self.pPanel:SetActive("Marry" ,false);
	self.pPanel:SetActive("BtnBag" ,false);
	self.pPanel:SetActive("BtnHelp", false)
	self.pPanel:SetActive("NumberTxt", false)
	self.pPanel:SetActive("FamilyMijingInfo", false)
end

function tbUi:ChangePositionBtn(szBtnName, nX, nY)
	self.tbOldChangePosBtns = self.tbOldChangePosBtns or {};
	if not self.tbOldChangePosBtns[szBtnName] then
		self.tbOldChangePosBtns[szBtnName] = self.pPanel:GetPosition(szBtnName)
	end
	self.pPanel:ChangePosition(szBtnName, nX, nY)
end

function tbUi:ShowLeave()
	self.pPanel:SetActive("BtnLeaveFuben", true);
end

function tbUi:Update(nItemCount, nCoinCount)
	self.pPanel:Label_SetText("ItemCount", nItemCount);
	self.pPanel:Label_SetText("CoinCount", nCoinCount);
end

function tbUi:SetEndTime(nEndTime, szTimeTitle)
	self.nEndTime = nEndTime;
	if self.nTimerId then
		Timer:Close(self.nTimerId);
	end

	self.pPanel:SetActive("FubenLastTime", true)
	self.pPanel:SetActive("Sprite", true)
	self.nTimerId = Timer:Register(Env.GAME_FPS, function ()
		local nLastTime = nEndTime - GetTime();
		if nLastTime < 0 then
			if self.szType == "WhiteTigerFuben" then
				self.pPanel:SetActive("FubenLastTime", false)
				self.pPanel:SetActive("Sprite", false)
			else
				self.pPanel:Label_SetText("FubenLastTime", "00:00");
			end
			self.nTimerId = nil;
			return;
		end
		self.pPanel:Label_SetText("FubenLastTime", self:GetLastTimeStr(nLastTime, szTimeTitle));
		return true;
	end)
end

function tbUi:SetScoreEndTime( szScoreTime, nScoreEndTime )
	self.pPanel:SetActive("ScroePanel", true);
	self.pPanel:Label_SetText("ScroeTxt", szScoreTime);
	
	self:StopScoreEndTime()
	local fnUpdate = function ()
		local nLastTime = nScoreEndTime - GetTime();
		if nLastTime < 0 then
			self.pPanel:Label_SetText("Scroe", "00:00");
			self.pPanel:SetActive("ScroePanel", false);
			self.nTimerIdScroe = nil;
			return;
		end
		self.pPanel:Label_SetText("Scroe", self:GetLastTimeStr(nLastTime));
		return true;
	end
	if fnUpdate() then
		self.nTimerIdScroe = Timer:Register(Env.GAME_FPS, fnUpdate)
	end
end

function tbUi:GetLastTimeStr(nLastTime, szTimeTitle)
	if self.szType=="KinNest" then
		return Lib:TimeDesc3(nLastTime)
	end
	return string.format("%s%02d:%02d", szTimeTitle or "", math.floor(nLastTime / 60), nLastTime % 60)
end

function tbUi:StopEndTime()
	if self.nTimerId then
		Timer:Close(self.nTimerId);
		self.nTimerId = nil;
	end
end

function tbUi:StopScoreEndTime()
	if self.nTimerIdScroe then
		Timer:Close(self.nTimerIdScroe)
		self.nTimerIdScroe = nil
	end
end

function tbUi:SetTargetInfo(szTargetInfo, nEndTime)
	if szTargetInfo == "" then
		self.pPanel:SetActive("TargetInfo", false);
		return;
	end

	self.pPanel:SetActive("TargetInfo", true);
	self.nTargetEndTime = nEndTime;
	if self.nTargetTimerId then
		Timer:Close(self.nTargetTimerId);
		self.nTargetTimerId = nil;
	end

	nEndTime = nEndTime or GetTime();
	local nLastTime = math.max(nEndTime - GetTime(), 0);
	self.pPanel:Label_SetText("TargetInfo", string.format(szTargetInfo, string.format("%02d:%02d", math.floor(nLastTime / 60), nLastTime % 60)));

	self.nTargetTimerId = Timer:Register(Env.GAME_FPS, function ()
		local nCurLastTime = math.max(nEndTime - GetTime(), 0);
		local szInfo = string.format(szTargetInfo, string.format("%02d:%02d", math.floor(nCurLastTime / 60), nCurLastTime % 60));
		self.pPanel:Label_SetText("TargetInfo", szInfo);

		if nCurLastTime <= 0 then
			self.nTargetTimerId = nil;
			return false;
		end

		return true;
	end);
end

function tbUi:UpdateGuide()
	local isAlreadyHaveGuide = self.pPanel:IsActive("Direction")
	self.nGuideTimerId = nil;

	if not self.nGuideX or not self.nGuideY or self.nGuideX == 0 or self.nGuideY == 0 then
		self:CloseGuide();
		return;
	end

	local _, nX, nY = me:GetWorldPos();
	local nGuideRangenRadius = self.nGuideRangenRadius or 100
	if math.abs(nX - self.nGuideX) < nGuideRangenRadius and math.abs(nY - self.nGuideY) < nGuideRangenRadius then
		self:CloseGuide();
		return;
	end

	if not Ui.CameraMgr.s_CurSceneCamera then
		self.nGuideTimerId = Timer:Register(5, self.UpdateGuide, self);
		return;
	end

	local tbPos = Ui.CameraMgr.GetScreenDirection(self.nGuideX, self.nGuideY);
	if not tbPos or (tbPos.x == tbPos.y and tbPos.x == 0) then
		self.pPanel:SetActive("Direction", false);
		return;
	end

	local nPosLen = math.sqrt(tbPos.x * tbPos.x + tbPos.y * tbPos.y);
	local nPosX = tbPos.x * self.nGuideLen / nPosLen;
	local nPosY = tbPos.y * self.nGuideLen / nPosLen;

	if isAlreadyHaveGuide then
		self.pPanel:Tween_Run("Direction", self.tbGuideCenterPos.x + nPosX, self.tbGuideCenterPos.y + nPosY, 0.5);
	else
		self.pPanel:ChangePosition("Direction", self.tbGuideCenterPos.x + nPosX, self.tbGuideCenterPos.y + nPosY);
		self.pPanel:Tween_SetPos("Direction");
	end

	local nAngle = 0;
	if nPosX == 0 then
		nAngle = nPosX >= 0 and 179.9 or 0;
	elseif nPosX > 0 then
		nAngle = math.deg(math.atan(nPosY / nPosX));
		nAngle = nAngle + 90;
	else
		nAngle = 270 + math.deg(math.atan(nPosY / nPosX));
	end

	if isAlreadyHaveGuide then
		self.pPanel:Tween_Rotate("Guide", nAngle, 0.5);
	else
		self.pPanel:ChangeRotate("Guide", nAngle);
		self.pPanel:Tween_SetRotate("Guide");
	end

	if not isAlreadyHaveGuide then
		self.pPanel:SetActive("Direction", true);
		self.pPanel:Tween_AlphaWithStart("Direction", 0.0, 1.0, 0.5)
	end

	self.nGuideTimerId = Timer:Register(5, self.UpdateGuide, self);
end

function tbUi:CloseGuide()
	self.nGuideX = nil;
	self.nGuideY = nil;

	self.pPanel:SetActive("Direction", false);
	me.tbFubenInfo = me.tbFubenInfo or {};
	me.tbFubenInfo.tbTargetPos = {};
end

function tbUi:SetGuidePos(nX, nY)
	self.nGuideX = nX;
	self.nGuideY = nY;

	if Ui:WindowVisible("HomeScreenFuben") ~= 1 and not self.bOpen then
		return;
	end

	if not self.nGuideTimerId then
		self:UpdateGuide();
	end
end

function tbUi:GetGuidePos()
	return self.nGuideX, self.nGuideY;
end

function tbUi:SetScroe(nScroe)
	self.pPanel:SetActive("ScroePanel", true);
	self.pPanel:Label_SetText("Scroe", nScroe);
	self.pPanel:Label_SetText("ScroeTxt", "当前积分");
	self:StopScoreEndTime()
end

function tbUi:SetScoreTxtInfo( szLine1, szLine2 )
	self.pPanel:SetActive("ScroePanel", true);
	self.pPanel:Label_SetText("ScroeTxt", szLine1);
	self.pPanel:Label_SetText("Scroe", szLine2);
	self:StopScoreEndTime()
end

function tbUi:SetFubenProgress(nPersent, szInfo)
	if szInfo then
		self:SetTargetInfo(szInfo);
	end

	if nPersent and nPersent >= 0 then
		self.pPanel:SetActive("Persent", true)
		self.pPanel:Label_SetText("Persent", string.format("（%s%%）", nPersent));
	else
		self.pPanel:SetActive("Persent", false)
	end
end

function tbUi:OnClose()
	self.bOpen = false;
	self.nEndTime = 0;

	if self.nGuideTimerId then
		Timer:Close(self.nGuideTimerId);
		self.nGuideTimerId = nil;
	end

	if self.nTimerId then
		Timer:Close(self.nTimerId);
		self.nTimerId = nil;
	end

	if self.nTargetTimerId then
		Timer:Close(self.nTargetTimerId);
		self.nTargetTimerId = nil;
	end
	self:StopScoreEndTime()

	self:CloseGuide();
	self:ResetBtnPos();
end

function tbUi:ResetBtnPos( ... )
	local tbOldChangePosBtns = self.tbOldChangePosBtns
	if not tbOldChangePosBtns then
		return
	end
	self.tbOldChangePosBtns = nil;
	for szBtnName,v in ipairs(tbOldChangePosBtns) do
		self.pPanel:ChangePosition(szBtnName, v.x, v.y)
	end
end


local LEAVE_MSG = 
{
	["WhiteTigerFuben"] = "确定要离开白虎堂？";
	["WeddingFuben"]    = "是否要离开婚礼现场？";
	["WeddingFubenRole"] = "是否要离开婚礼现场？";
	["QueQiaoFuben"] = "离开后将不能再回到鹊桥，确定离开吗？";
	["KinSecretFuben"] = "如果当前房间的奖励还未发放，离开地图可能会导致大侠没有奖励，确定离开地图吗？";
}
function tbUi:LeaveFuben(bConfirm)
	if self.szType == "DrinkHouseFuben" then
		bConfirm = true;
	end
	if not bConfirm then
		local szMsg = LEAVE_MSG[self.szType] or "确认要离开副本？"
		Ui:OpenWindow("MessageBox", szMsg, {{self.LeaveFuben, self, true}, {}}, {"离开", "取消"});
		return;
	end

	if IsAlone() == 1 then
		PersonalFuben:DoLeaveFuben();
	else
		RemoteServer.LeaveFuben(false);
	end
end

function tbUi:HideInviteButton()
	self.pPanel:SetActive("BtnInvite", false)
end

function tbUi:OnFubenTargetChange()
	me.tbFubenInfo = me.tbFubenInfo or {};
	local tbFubenInfo = me.tbFubenInfo
	tbFubenInfo.tbTargetPos = tbFubenInfo.tbTargetPos or {0, 0};
	local nX, nY = unpack(tbFubenInfo.tbTargetPos);
	if nX and nX > 0 and nY and nY > 0 then
		self:SetGuidePos(nX, nY);
	else
		self:CloseGuide();
	end

	tbFubenInfo.tbTargetInfo = tbFubenInfo.tbTargetInfo or {};
	local szInfo, nEndTime = unpack(tbFubenInfo.tbTargetInfo);
	if szInfo then
		self:SetTargetInfo(szInfo, nEndTime);
		tbFubenInfo.tbTargetInfo = nil;
	end

	tbFubenInfo.tbProgress = tbFubenInfo.tbProgress or {};
	local nProgress, szProgressInfo = unpack(tbFubenInfo.tbProgress);
	if nProgress then
		self:SetFubenProgress(nProgress, szProgressInfo);
		tbFubenInfo.tbProgress = nil;
	end

	if tbFubenInfo.nScore and tbFubenInfo.nScore > 0 then
		self:SetScroe(tbFubenInfo.nScore);
		tbFubenInfo.nScore = nil;
	elseif tbFubenInfo.szScoreLine1 and tbFubenInfo.szScoreLine2 then
		self:SetScoreTxtInfo(tbFubenInfo.szScoreLine1, tbFubenInfo.szScoreLine2)
		tbFubenInfo.szScoreLine1 = nil;
		tbFubenInfo.szScoreLine2 = nil;		
	elseif tbFubenInfo.szScoreTime and tbFubenInfo.nScoreEndTime then
		self:SetScoreEndTime(tbFubenInfo.szScoreTime, tbFubenInfo.nScoreEndTime)
		tbFubenInfo.szScoreTime = nil;
		tbFubenInfo.nScoreEndTime = nil;
	end
	if tbFubenInfo.nEndTime and tbFubenInfo.nEndTime > 0 then
		self:SetEndTime(tbFubenInfo.nEndTime, tbFubenInfo.szTimeTitle);
		tbFubenInfo.nEndTime = nil;
		tbFubenInfo.szTimeTitle = nil
	end

	if tbFubenInfo.szHelpKey then
		self.pPanel:SetActive("BtnHelp", true)
		self.pPanel:ResetGeneralHelp("BtnHelp", tbFubenInfo.szHelpKey)
	end

	tbFubenInfo.tbShowInfo = tbFubenInfo.tbShowInfo or {};
	local nItemCount, nCoinCount = unpack(tbFubenInfo.tbShowInfo);
	if nItemCount then
		self:Update(nItemCount, nCoinCount);
		tbFubenInfo.tbShowInfo = nil;
	end

	if tbFubenInfo.bCanLeave then
		self:ShowLeave();
		tbFubenInfo.bCanLeave = nil;
	end
end

function tbUi:OnTeamUpdate(szType)
	if szType == "MemberChanged" and self.pPanel:IsActive("BtnInvite") and self.szType ~= "HousePeach" then
		if #TeamMgr:GetTeamMember() >= TeamMgr.MAX_MEMBER_COUNT then
			self.BtnInvite.pPanel:SetActive("tuoguan", false)
		else
			self.BtnInvite.pPanel:SetActive("tuoguan", true)
		end
	end
end

function tbUi:PlayTargetChange()
	if self.szType == "RandomFuben" then
		return
	end

	self.pPanel:SetActive("zhangjieshuaxin", true)
	Timer:Register(Env.GAME_FPS * 0.7, function ()
		self.pPanel:SetActive("zhangjieshuaxin", false)
	end)
end

function tbUi:ChangeGuideRange(nRadius)
	self.nGuideRangenRadius = nRadius or 100
end

function tbUi:OnFubenTargetClose()
	self.pPanel:SetActive("BtnLeaveFuben", false);
	me.tbFubenInfo = me.tbFubenInfo or {};
	me.tbFubenInfo.bCanLeave = nil;
end

function tbUi:CheckBagRedPoint()
    local tbTopUi = Ui:GetClass("TopButton")
    if tbTopUi then
        tbTopUi:CheckHasCanEquipItem(1)
    end
end

function tbUi:SetWeddingBtnActive(szBtnName, bActive)
	self.pPanel:SetActive(szBtnName, bActive);
end

function tbUi:OnJoinCountChange()
	self.pPanel:Label_SetText("NumberTxt", string.format("当前人数：%d", Fuben.KinSecretMgr.nJoinCount or 0))
end

function tbUi:OnDeathCountChange()
	self.pPanel:Label_SetText("FamilyMijingInfoTxt", string.format("头目吸魂数量：%d", Fuben.KinSecretMgr.nDeathCount or 0))
end

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_FUBEN_TARGET_CHANGE, self.OnFubenTargetChange, self},
		{ UiNotify.emNOTIFY_TEAM_UPDATE, 		self.OnTeamUpdate, self},
		{ UiNotify.emNOTIFY_FUBEN_STOP_ENDTIME, self.StopEndTime, self},
		{ UiNotify.emNoTIFY_FUBEN_PROGRESS_REFRESH, self.PlayTargetChange, self},
		{ UiNotify.emNOTIFY_GUIDE_RANGE_CHANGE, self.ChangeGuideRange, self},
		{ UiNotify.emNOTIFY_FUBEN_TARGET_CHANGE_CLOSE, self.OnFubenTargetClose, self},
		{ UiNotify.emNOTIFY_SYNC_ITEM,		 	self.CheckBagRedPoint},
		{ UiNotify.emNOTIFY_DEL_ITEM, 			self.CheckBagRedPoint},
		{ UiNotify.emNOTIFY_FUBEN_TARGET_CHANGE_WEDDING_BTN, 			self.SetWeddingBtnActive},
		{ UiNotify.emNOTIFY_FUBEN_JOIN_COUNT_CHANGE, self.OnJoinCountChange, self},
		{ UiNotify.emNOTIFY_FUBEN_DEATH_COUNT_CHANGE, self.OnDeathCountChange, self},
	};

	return tbRegEvent;
end

tbUi.tbOnClick = {};
tbUi.tbOnClick.BtnLeaveFuben = function (self)
	if House.tbPeach:InFairyLand() then
		RemoteServer.GoBackFromHome();
		return;
	end

	self:LeaveFuben();
end

tbUi.tbOnClick.BtnInvite = function (self)
	local szType 
	if self.szType == "PartnerCardTripFuben" then
		szType = "PartnerCardTripFuben"
	end
	Ui:OpenWindow("DungeonInviteList", szType)
end


tbUi.tbOnClick.BtnGo = function (self)
	if not self.nGuideX or not self.nGuideY then
		return;
	end

	AutoPath:GotoAndCall(me.nMapId, self.nGuideX, self.nGuideY);
end

tbUi.tbOnClick.BtnCash = function (self)
	RemoteServer.OnWeddingRequest("TryOpenCashPanel");
end

tbUi.tbOnClick.BtnProcess = function (self)
	RemoteServer.OnWeddingRequest("TryOpenProcessPanel");
end

tbUi.tbOnClick.BtnInvitation = function (self)
	Ui:OpenWindow("WeddingWelcomeApplyPanel")
end

tbUi.tbOnClick.BtnCamera = function (self)
	 Ui:OpenWindowAtPos("HouseCameraPanel", 433, 130, true);
end

tbUi.tbOnClick.BtnCandy = function (self)
	 RemoteServer.OnWeddingRequest("TrySendCandy");
end

tbUi.tbOnClick.BtnBlessing = function (self)
	Ui:OpenWindow("WeddingBlessingPanel")
end

tbUi.tbOnClick.BtnBag = function ()
    Ui:OpenWindow("ItemBox")
end

tbUi.tbOnClick.BtnMarketStall = function ()
    Ui:OpenWindow("MarketStallPanel");
end

tbUi.tbOnClick.BtnAuction = function ()
    Ui:OpenWindow("AuctionPanel", "Auction");
end

