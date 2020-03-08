local tbUi = Ui:CreateClass("BossPanel");

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_SYNC_BOSS_DATA, self.UpdateUi, self},
		{ UiNotify.emNOTIFY_BOSS_ROB_BATTLE, self.ChangeRobBattleState, self},
		{ UiNotify.emNOTIFY_MAP_LOADED, self.OnMapLoaded, self},
	};

	return tbRegEvent;
end

function tbUi:OnOpen()
	if not Boss:IsFightMap(me.nMapTemplateId) then
		me.CenterMsg("本地图无法参加，请前往[FFFE0D]忘忧岛[-]或[FFFE0D]野外安全区[-]再尝试");
		return 0;
	end

	if me.nFightMode ~= 0 then
		local fnOpenPanel = function ()
			local nX, nY = Map:GetDefaultPos(me.nMapTemplateId)
			AutoPath:GotoAndCall(me.nMapTemplateId, nX, nY, function ()
				Ui:OpenWindow("BossPanel");
			end)
		end

		me.MsgBox("是否返回当前地图安全区参加[FFFE0D]武林盟主[-]活动", {{"同意", fnOpenPanel}, {"取消"}});
		return 0;
	end

	self.bInRobBattle = false;
	Boss:UpdateBossData();
end

function tbUi:OnOpenEnd()
	self.tbOnClick.BtnPlayerRank(self);
	self.pPanel:Toggle_SetChecked("BtnPlayerRank", true);

	if self.nTimer then
		Timer:Close(self.nTimer);
	end
	self.nTimer = Timer:Register(Env.GAME_FPS, self.Schedule, self);
	self:InitUi();
	self:Schedule(true);
	self:UpdateUi();
end

function tbUi:InitUi()
	self.pPanel:Label_SetText("TxtBossHp", "");
	self.pPanel:Label_SetText("TxtLeftTime", "");
	self.pPanel:Label_SetText("TxtBtnRob", "前去抢分");
	self.pPanel:Label_SetText("TxtBtnChallenge", "挑战盟主");
end

function tbUi:OnMapLoaded()
	local tbBossFightResult = Boss:GetFightBossResult();
	if tbBossFightResult then
		local szMsg = string.format("抢夺武林盟主获得%d分", tbBossFightResult.nScore);
		--if tbBossFightResult.bBossDie then
		--	szMsg = string.format("成功干掉武林盟主, 获得%d分", tbBossFightResult.nScore);
		--end
		me.MsgBox(szMsg);
	end
end

function tbUi:ChangeRobBattleState(bInRobBattle)
	self.bInRobBattle = bInRobBattle;
end

function tbUi:Schedule(bForce)
	if self.bInRobBattle and not bForce then
		return true;
	end

	if not Boss:IsOpen() and not bForce then
		self:InitUi();
		self.nTimer = nil;
		Ui:OpenWindow("MessageBox", "挑战结束", {{function ()
			Ui:CloseWindow("BossPanel");
		end}}, {"确定"})
		return false;
	end

	local nNow = GetTime();
	if (nNow + me.dwID) % 5 == 0 and not bForce then
		self:UpdateData();
	end

	local tbBossData = Boss:GetBossData() or {};
	local nLeftTime = math.max((tbBossData.nEndTime or 0) - nNow, 0)
	local szLeftTime = string.format("活动剩余时间:%02d:%02d", nLeftTime / 60, nLeftTime % 60);
	self.pPanel:Label_SetText("TxtLeftTime", szLeftTime);

	local tbMyData = Boss:GetMyData() or {};
	local nNextRobTime = tbMyData.nNextRobTime or 0;
	local szBtnRob = "前去抢分";
	if nNow < nNextRobTime then
		local nLeftRobTime = nNextRobTime - nNow;
		szBtnRob = string.format("%02d:%02d", nLeftRobTime / 60, nLeftRobTime % 60);
	end
	self.pPanel:Label_SetText("TxtBtnRob", szBtnRob);

	local nNextFightTime = tbMyData.nNextFightTime or 0;
	local szBtnChallenge = "挑战盟主";
	if nNow < nNextFightTime then
		local nLeftFightTime = nNextFightTime - nNow;
		szBtnChallenge = string.format("%02d:%02d", nLeftFightTime / 60, nLeftFightTime % 60);
	end
	self.pPanel:Label_SetText("TxtBtnChallenge", szBtnChallenge);


	local szHp = Lib:TimeDesc3(nLeftTime);
	self.pPanel:Label_SetText("TxtBossHp", szHp);
	local nPercent = tbBossData.nEndTime and math.max((tbBossData.nEndTime - nNow) / (tbBossData.nEndTime - tbBossData.nStartTime), 0) or 0;
	self.pPanel:ProgressBar_SetValue("BossBlood", nPercent);

	local _, szRateTexture, szTexture = Boss:GetBossHpStageInfo(nPercent);
	self.pPanel:Sprite_SetSprite("StageDescImg", szTexture);
	self.pPanel:Sprite_SetSprite("IntegralRatio", szRateTexture);
	return true;
end

function tbUi:UpdateData()
	Boss:UpdateBossData();

	if self.szCurRank == "Kin" then
		Boss:UpdateKinRankData();
	end

	if self.szCurRank == "Player" then
		Boss:UpdatePlayerRankData();
	end
end

function tbUi:UpdateUi(szType)
	if szType == "BossHp" or not szType then
		local tbBossData = Boss:GetBossData() or {};
		local nNow = GetTime();
		local nPercent = tbBossData.nEndTime and math.max((tbBossData.nEndTime - nNow) / (tbBossData.nEndTime - tbBossData.nStartTime), 0) or 0;
		self.pPanel:ProgressBar_SetValue("BossBlood", nPercent);
		local _, szRateTexture, szTexture = Boss:GetBossHpStageInfo(nPercent);
		self.pPanel:Sprite_SetSprite("StageDescImg", szTexture);
		self.pPanel:Sprite_SetSprite("IntegralRatio", szRateTexture);
		self.pPanel:Label_SetText("TxtMainTitle", Boss:IsInCross() and "跨服武林盟主" or "武林盟主");
	end

	if szType == "MyData" or not szType then
		local tbMyData = Boss:GetMyData() or {};
		self.pPanel:Label_SetText("MyRank", tbMyData.nRank or "");
		self.pPanel:Label_SetText("MyPoints", math.floor(tbMyData.nScore or 0));
	end

	if self.szCurRank == "Kin" and (szType == "KinRank" or not szType) then
		self:UpdateKinRank();
	elseif self.szCurRank == "Player" and (szType == "PlayerRank" or not szType) then
		self:UpdatePlayerRankScrollView();
	end

	if szType == "BroadcastMsg" or not szType then
		local tbMsgs = ChatMgr:GetChannelChatData("Boss");
		local szMsg = table.concat(tbMsgs, "\n");
		self.pPanel:Label_SetText("TxtBossMsgs", szMsg);
	end

	if szType == "MyMsg" or not szType then
		local tbMsgs = Boss:GetMyMsg();
		local szMsg = table.concat(tbMsgs, "\n");
		self.pPanel:Label_SetText("TxtMyMsg", szMsg);
	end
end

function tbUi:UpdateKinRank()
	if Kin:HasKin() then
		local tbMyKin = Boss:GetMyKinData() or {};
		self.pPanel:Label_SetText("MyFamilyName", tbMyKin.szName or "");
		self.pPanel:Label_SetText("MyFamilyRank", tbMyKin.nRank or "");
		self.pPanel:Label_SetText("MyFamilyLeader", tbMyKin.szMasterName or "");
		self.pPanel:Label_SetText("MyFamilyParticipation", tbMyKin.nJoinMember or "");
		self.pPanel:Label_SetText("MyFamilyPoint", math.floor(tbMyKin.nScore or 0));

		self.pPanel:SetActive("NoFamilyContainer", false);
		self.pPanel:SetActive("FamilyContainer", true);
	else
		self.pPanel:SetActive("NoFamilyContainer", true);
		self.pPanel:SetActive("FamilyContainer", false);
	end

	local tbItems = Boss:GetKinRankData() or {};
	local fnSetItem = function (itemObj, nIndex)
		local tbItem = tbItems[nIndex];
		itemObj.pPanel:Label_SetText("TxtLeaderName", "领袖:" .. tbItem.szMasterName);
		itemObj.pPanel:Label_SetText("TxtScore", "积分:" .. math.floor(tbItem.nScore));
		itemObj.pPanel:Label_SetText("TxtJoin", "参与人数:" .. (tbItem.nJoinMember == 0 and 1 or math.min(tbItem.nJoinMember * 2, 25)));
		itemObj.pPanel:SetActive("BtnJoin", tbItem.bCanJoin and not Kin:HasKin());
		itemObj.nKinId = tbItem.nKinId;

		local szKinName = tbItem.szName;
		if tbItem.nServerId then
			szKinName = string.format("%s［%s］", szKinName, Sdk:GetServerDesc(tbItem.nServerId));
		end
		itemObj.pPanel:Label_SetText("TxtName", "家族名:" .. szKinName);

		if nIndex <= 3 then
			itemObj.pPanel:SetActive("NO123", true);
			itemObj.pPanel:SetActive("Rank", false);
			for i = 1, 3 do
				itemObj.pPanel:SetActive("NO" .. i, i == nIndex);
			end
		else
			local szRank = string.format("第%s名", Lib:Transfer4LenDigit2CnNum(nIndex));
			itemObj.pPanel:Label_SetText("Rank", szRank);
			itemObj.pPanel:SetActive("NO123", false);
			itemObj.pPanel:SetActive("Rank", true);
		end
	end

	self.KinScrollView:Update(#tbItems, fnSetItem);
end

function tbUi:UpdatePlayerRankScrollView()
	local tbItems = Boss:GetPlayerRankData() or {};
	local fnSetItem = function (itemObj, nIndex)
		local tbItem = tbItems[nIndex];

		itemObj.pPanel:Label_SetText("TxtName", tbItem.szName);
		itemObj.pPanel:Label_SetText("TxtScore", math.floor(tbItem.nScore));

		local szKinName = tbItem.szKinName or "";
		if tbItem.nServerId then
			local szServerDesc = Sdk:GetServerDesc(tbItem.nServerId);
			szKinName = string.format("%s［%s］", szKinName, szServerDesc);
		end
		itemObj.pPanel:Label_SetText("TxtFamilyName", szKinName);

		local ImgPrefix, Atlas = Player:GetHonorImgPrefix(tbItem.nHonorLevel)
		if ImgPrefix then
			itemObj.pPanel:SetActive("PlayerTitle", true);
			itemObj.pPanel:Sprite_Animation("PlayerTitle", ImgPrefix, Atlas);
		else
			itemObj.pPanel:SetActive("PlayerTitle", false);
		end
		itemObj.pPanel:Sprite_SetSprite("ImgFaction", Faction:GetIcon(tbItem.nFaction));


		if nIndex <= 3 then
			itemObj.pPanel:SetActive("NO123", true);
			itemObj.pPanel:SetActive("Rank", false);
			for i = 1, 3 do
				itemObj.pPanel:SetActive("NO" .. i, i == nIndex);
			end
		else
			local szRank = string.format("第%s名", Lib:Transfer4LenDigit2CnNum(nIndex));
			itemObj.pPanel:Label_SetText("Rank", szRank);
			itemObj.pPanel:SetActive("NO123", false);
			itemObj.pPanel:SetActive("Rank", true);
		end
	end

	self.PlayerScrollView:Update(#tbItems, fnSetItem);
end

function tbUi:OnClose()
	if self.nTimer then
		Timer:Close(self.nTimer);
		self.nTimer = nil;
	end
end

tbUi.tbOnClick = tbUi.tbOnClick or {};

function tbUi.tbOnClick:BtnKinRank()
	Boss:UpdateKinRankData();

	self.szCurRank = "Kin";
	self.pPanel:SetActive("FamilyRank", true);
	self.pPanel:SetActive("PlayerScrollView", false);
	self.pPanel:SetActive("ListTitleBackground", false);
	self:UpdatePlayerRankScrollView();
end

function tbUi.tbOnClick:BtnPlayerRank()
	Boss:UpdatePlayerRankData();

	self.szCurRank = "Player";
	self.pPanel:SetActive("FamilyRank", false);
	self.pPanel:SetActive("ListTitleBackground", true);
	self.pPanel:SetActive("PlayerScrollView", true);
	self:UpdateKinRank();
end

function tbUi.tbOnClick:BtnChallenge()
	local tbMyData = Boss:GetMyData() or {};
	local nNextFightTime = tbMyData.nNextFightTime or 0;
	if GetTime() < nNextFightTime then
		me.CenterMsg("冷却时间未到");
		return false;
	end

	if not Boss:IsOpen() then
		me.CenterMsg("本次活动已结束！");
		return false;
	end

	Ui:OpenWindow("PartnerArrayPanel", "开始挑战", Boss.ChallengeBoss, Boss)
end

function tbUi.tbOnClick:BtnRob()
	local tbMyData = Boss:GetMyData() or {};
	local nNextRobTime = tbMyData.nNextRobTime or 0;
	if GetTime() < nNextRobTime then
		me.CenterMsg("挑战间隔尚未结束");
		return false;
	end

	if not Boss:IsOpen() then
		me.CenterMsg("挑战已结束");
		return false;
	end

	Ui:OpenWindow("BossRobList");
end

function tbUi.tbOnClick:BtnBack()
	Ui:CloseWindow("BossPanel");
end

local tbBossPlayerRankItem = Ui:CreateClass("BossPlayerRankItem");
local tbKinRankItem = Ui:CreateClass("BossKinRankItem");

tbKinRankItem.tbOnClick = tbKinRankItem.tbOnClick or {};

function tbKinRankItem.tbOnClick:BtnJoin()
	if self.nKinId then
		Kin:ApplyKin(self.nKinId);
	end
end
