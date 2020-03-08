local tbMainUi = Ui:CreateClass("FKBattleMainPanel");
KinBattle.Foku = KinBattle.Foku or {};
local Foku = KinBattle.Foku;

function tbMainUi:OnOpen()
	self.pPanel:Label_SetText("DescribeTxt",Foku.szMainPanel_DescribeTxt);
	self.pPanel:Label_SetText("TimeTxt","活动时间：20:00 ~ 20:25");
	self.pPanel:Label_SetText("Title","龙\n门\n之\n争");
	Foku:AskIsOpen(true);
end

function tbMainUi:RegisterEvent()
	local tbRegEvent = 
	{
		{UiNotify.emNoTIFY_SYNC_FOKU_BATTLE, self.OnNotify, self},
	};
	return tbRegEvent;
end

function tbMainUi:OnNotify(...)
	self:_OnNotify(...)
end

function tbMainUi:_OnNotify(...)
	self:UpdateContent();
end

tbMainUi.tbOnClick = {
	BtnClose = function()
		Ui:CloseWindow("FKBattleMainPanel");
		Ui:CloseWindow("ThreeChoosePanel");
	end,
	BtnElite = function()
		Foku:TryAskMemberMsg(true);
		--Ui:OpenWindow("ThreeChoosePanel");
	end,
	BtnOrdinary = function()
		Foku:TryEnterZone(2);
	end,
	BtnTips = function()
		Ui:OpenWindow("GeneralHelpPanel","KinFokuAct");
	end,
}

function tbMainUi:UpdateContent()
	if Foku.nStartTime then
		if self.nStartTimer then
			Timer:Close(self.nStartTimer);
			self.nStartTimer = nil;
		end

		local nDownTime = Foku.nStartTime - GetTime();
		if nDownTime > 0 then
			local szStr = Lib:TimeDesc(nDownTime);
			self.pPanel:Label_SetText("TimeTxt",string.format("准备时间：[FFFF0E]%s[-]",szStr));
			self.nStartTimer = Timer:Register(Env.GAME_FPS,function()
				nDownTime = nDownTime - 1;
				if nDownTime >= 0 then
					local szStr = Lib:TimeDesc(nDownTime);
					self.pPanel:Label_SetText("TimeTxt",string.format("准备时间：[FFFF0E]%s[-]",szStr));
					return true;
				else
					self.pPanel:Label_SetText("TimeTxt","活动时间：20:00 ~ 20:25");
					self.nStartTimer = nil;
					return false;
				end
			end)
		else
			self.pPanel:Label_SetText("TimeTxt","活动时间：20:00 ~ 20:25");
		end
	end
end

function tbMainUi:OnClose()
	--Foku.bStartTime = nil;
	if self.nStartTimer then
		Timer:Close(self.nStartTimer);
		self.nStartTimer = nil;
	end
end

--------------------------------------------------------------------------

local tbTeamUi = Ui:CreateClass("FKTeamPanel");

function tbTeamUi:OnOpen()
	Ui:CloseWindow("ThreeChoosePanel");
	self:UpdateContent();
end

tbTeamUi.tbOnClick = {
	BtnClose = function()
		Ui:CloseWindow("FKTeamPanel");
		Ui:CloseWindow("ThreeChoosePanel");
	end,
}

function tbTeamUi:RegisterEvent()
	local tbRegEvent = 
	{
		{UiNotify.emNoTIFY_SYNC_FOKU_BATTLE, self.OnNotify, self},
	};
	return tbRegEvent;
end

function tbTeamUi:OnNotify(...)
	self:_OnNotify(...)
end

function tbTeamUi:_OnNotify(...)
	self:UpdateContent();
end

function tbTeamUi:UpdateContent()
	local tbTeamInfo = Foku.tbTeamData or {};
	for i = 1,3 do
		for j = 1,4 do
			local szMem = "Member"..(i-1)*4 + j;
			self.pPanel:SetActive(szMem, false);
		end
	end
	local nIdx = 1;
	for _ , tbTeam in pairs(tbTeamInfo) do
		local nJdx = 1;
		if type(tbTeam) == "table" then
		for _ , tbTmp in pairs(tbTeam) do
			if type(tbTmp) == "table" then
			local nKey = (nIdx-1)*4 + nJdx
			self.pPanel:SetActive("Member"..nKey, true);
			self.pPanel:Label_SetText("Level"..nKey,tbTmp.nLevel);
			self.pPanel:Label_SetText("RoleName"..nKey,tbTmp.szName);
			self.pPanel:Label_SetText("Fighting"..nKey,tbTmp.nFightPower);

			local ImgPrefix, Atlas = Player:GetHonorImgPrefix(tbTmp.nHonorLevel);
			if ImgPrefix then
				self.pPanel:SetActive("PlayerTitle"..nKey,true);
				self.pPanel:Sprite_Animation("PlayerTitle"..nKey, ImgPrefix, Atlas);
			else
				self.pPanel:SetActive("PlayerTitle"..nKey, false);
			end
			self.pPanel:Sprite_SetSprite("Faction"..nKey, Faction:GetIcon(tbTmp.nFaction));
			
			local szBigIcon, szBigIconAtlas = PlayerPortrait:GetPortraitBigIcon(tbTmp.nFaceId);
			self.pPanel:Sprite_SetSprite("Role"..nKey,szBigIcon, szBigIconAtlas);
			self.pPanel:Label_SetText("RoleName"..nKey,tbTmp.szName);
			nJdx = nJdx + 1;
			end
		end
		end
		nIdx = nIdx + 1;
	end
end

--------------------------------------------------------------------------
local tbInfoUi_A = Ui:CreateClass("FKBattleInfoA");

function tbInfoUi_A:OnOpen()
	self.pPanel:Label_SetText("Camp1",  "本方");
	self.pPanel:Label_SetText("Camp2",  "敌方");
	self.pPanel:Label_SetText("Camp1Num", 0);
	self.pPanel:Label_SetText("Camp2Num", 0);
	self.pPanel:Label_SetText("ProgressBarTxt1", Foku.KIN_DOWN_TIME);
	self.pPanel:Label_SetText("ProgressBarTxt2", Foku.KIN_DOWN_TIME);
	self:MainDownTime();
	self.pPanel:SliderBar_SetValue("ProgressBarBg1" , 0);
	self.pPanel:SliderBar_SetValue("ProgressBarBg2" , 0);
	self.pPanel:SetActive("ProgressBarTxt1",false);
	self.pPanel:SetActive("ProgressBarTxt2",false);
	self.pPanel:SetActive("ProgressBarBg1",false);
	self.pPanel:SetActive("ProgressBarBg2",false);
	for i = 1 , 5 do
		local szBtn = "Btn"..i;
		local szBtnTxt = "BtnTxt"..i;
		self.pPanel:Label_SetText(szBtnTxt,"");
		self.pPanel:Button_SetEnabled(szBtn,true);
		--self.pPanel:Button_SetEnabled(szBtn,false);
		self.pPanel:Sprite_SetGray(szBtn,true);
	end
	if Foku.tbFightInfo then
		self:UpdateContent();
	end
end

function tbInfoUi_A:UpdateContent()
	local tbInfo = Foku.tbFightInfo or {};
	if tbInfo.nMsgType == Foku.MSG_TYPE_SCORE then
		if tbInfo.nCamp1Score then
			self.pPanel:Label_SetText("Camp1Num", tbInfo.nCamp1Score);
		end

		if tbInfo.nCamp2Score then
			self.pPanel:Label_SetText("Camp2Num", tbInfo.nCamp2Score);
		end
	elseif tbInfo.nMsgType == Foku.MSG_TYPE_FIGHT_INIT then
		self.pPanel:Label_SetText("Camp1",  tbInfo.szKinName1 or "本方");
		self.pPanel:Label_SetText("Camp2",  tbInfo.szKinName2 or "敌方");
		self:MainDownTime(tbInfo.nEndTime);
	elseif tbInfo.nMsgType == Foku.MSG_TYPE_DOWNTIME then
		self:EndDownTime(1,tbInfo.nCamp1DownTime)
		self:EndDownTime(2,tbInfo.nCamp2DownTime)
	end

	if Foku.nNeedFlushPanel and Foku.tbSkill then
		Lib:Tree(Foku.tbSkill);
		for i , nSkillNum in pairs(Foku.tbSkill) do
			local szBtn = "Btn"..i;
			local szBtnTxt = "BtnTxt"..i;
			if nSkillNum == nil or nSkillNum == 0 then
				self.pPanel:Label_SetText(szBtnTxt,"");
				--self.pPanel:Button_SetEnabled(szBtn,false);
				self.pPanel:Sprite_SetGray(szBtn,true);
			else
				self.pPanel:Label_SetText(szBtnTxt,nSkillNum);
				self.pPanel:Button_SetEnabled(szBtn,true);
				self.pPanel:Sprite_SetGray(szBtn,false);
			end
		end
		Foku.nNeedFlushPanel = false;
	end

end

function tbInfoUi_A:EndDownTime(nType , nTime)
	local szBarTxt = "ProgressBarTxt"..nType;
	local szBarBg = "ProgressBarBg"..nType;
	local nAnType = nType == 1 and 2 or 1;
	self.tbTimer = self.tbTimer or {};
	if nTime then
		self.pPanel:SetActive(szBarTxt,true);
		self.pPanel:SetActive(szBarBg,true);
		if self.tbTimer[nType] then
			Timer:Close(self.tbTimer[nType]);
			self.tbTimer[nType] = nil;
		end
		self.pPanel:Label_SetText(szBarTxt,Foku.KIN_DOWN_TIME);
		local nDownTime = nTime - GetTime();
		self.tbTimer[nType] = Timer:Register(Env.GAME_FPS , function() 
		nDownTime = nDownTime - 1;
		if Ui:WindowVisible("SpecialTips") ~= 1 then
			if nDownTime <= 9 and nDownTime > 0 then
				if nType == 1 then
					Log("nDownTime1:",nDownTime)
					Ui:OpenWindow("SpecialTips","距离我方获胜：",nDownTime);
				else
					Log("nDownTime2:",nDownTime)
					Ui:OpenWindow("SpecialTips","距离敌方获胜：",nDownTime);
				end
			end
		end

			if nDownTime < 0 then
				self.pPanel:Label_SetText(szBarTxt,0);
				self.tbTimer[nType] = nil;
				return false;
			end
			self.pPanel:SliderBar_SetValue(szBarBg , (Foku.KIN_DOWN_TIME-nDownTime)/Foku.KIN_DOWN_TIME);
			self.pPanel:Label_SetText(szBarTxt,nDownTime);
			return true;
		end);

	else
		if self.tbTimer[nType] then
			Timer:Close(self.tbTimer[nType]);
			self.tbTimer[nType] = nil;
		end
		self.pPanel:Label_SetText(szBarTxt,Foku.KIN_DOWN_TIME);
		self.pPanel:SetActive(szBarTxt,false);
		self.pPanel:SliderBar_SetValue(szBarBg , 0);
		self.pPanel:SetActive(szBarBg,false);
	end
end

function tbInfoUi_A:MainDownTime(nEndTime)
	if self.nMainTimer then
		Timer:Close(self.nMainTimer);
	end
	local nDownTime = nEndTime and nEndTime - GetTime() or  Foku.GAME_TOTAL_TIME;
	local szStr = Lib:TimeDesc3(nDownTime);
	self.pPanel:Label_SetText("Countdown",szStr);
	self.nMainTimer = Timer:Register(Env.GAME_FPS , function()
		nDownTime = nDownTime - 1;
		if nDownTime >= 0 then
			local szStr = Lib:TimeDesc3(nDownTime);
			self.pPanel:Label_SetText("Countdown",szStr);
			return true;
		else
			self.pPanel:Label_SetText("Countdown","--:--");
			self.nMainTimer = nil;
			return false;
		end
	end)
end

function tbInfoUi_A:OnClose()
	if self.nMainTimer then
		Timer:Close(self.nMainTimer);
	end
	self.nMainTimer = nil;
end



function tbInfoUi_A:RegisterEvent()
	local tbRegEvent = 
	{
		{UiNotify.emNoTIFY_SYNC_FOKU_BATTLE, self.OnNotify, self},
	};
	return tbRegEvent;
end

function tbInfoUi_A:OnNotify(...)
	self:_OnNotify(...)
end

function tbInfoUi_A:_OnNotify(...)
	self:UpdateContent();
end

tbInfoUi_A.tbOnClick = {}
tbInfoUi_A.tbOnLongPress = {};
for i = 1 , 5 do
	local fnShowSkill = function()
		local nSkillId = Foku.tbSkills[i][1];
		local nSkillLevel = Foku.tbSkills[i][2];
		local tbSkillShowInfo = FightSkill:GetSkillShowTipInfo(nSkillId, nSkillLevel);
		Ui:OpenWindow("SkillShow", tbSkillShowInfo);
	end
	tbInfoUi_A.tbOnClick["Btn"..i] = function(self)
		if not Foku.tbSkill or not Foku.tbSkill[i] or Foku.tbSkill[i] == 0 then
		else
			Foku:TryUseSkill(i);
		end
	end
	tbInfoUi_A.tbOnLongPress["Btn"..i] = function(self)
		fnShowSkill();
	end
end


--------------------------------------------------------------------------

local tbInfoUi_B = Ui:CreateClass("FKBattleInfoB");
function tbInfoUi_B:OnOpen()
	self.pPanel:Label_SetText("Camp1",  "本方");
	self.pPanel:Label_SetText("Camp2",  "敌方");
	self.pPanel:Label_SetText("Camp1Num", 0);
	self.pPanel:Label_SetText("Camp2Num", 0);
	self.pPanel:SliderBar_SetValue("ProgressBarBg2" , 0);
	self.pPanel:SliderBar_SetValue("ProgressBarBg1" , 0);
	self.pPanel:Label_SetText("ProgressBarTxt1", 0);
	self.pPanel:Label_SetText("ProgressBarTxt2", 0);
	self:MainDownTime();

	if Foku.tbFightInfo then
		self:UpdateContent();
	end
end

function tbInfoUi_B:RegisterEvent()
	local tbRegEvent = 
	{
		{UiNotify.emNoTIFY_SYNC_FOKU_BATTLE, self.OnNotify, self},
	};
	return tbRegEvent;
end
function tbInfoUi_B:OnNotify(...)
	self:_OnNotify(...)
end

function tbInfoUi_B:_OnNotify(...)
	self:UpdateContent();
end

function tbInfoUi_B:MainDownTime(nEndTime)
	if self.nMainTimer then
		Timer:Close(self.nMainTimer);
		self.nMainTimer = nil;
	end
	local nDownTime = nEndTime and nEndTime - GetTime() or  Foku.GAME_TOTAL_TIME;
	local szStr = Lib:TimeDesc3(nDownTime);
	self.pPanel:Label_SetText("Countdown",szStr);
	self.nMainTimer = Timer:Register(Env.GAME_FPS , function()
		nDownTime = nDownTime - 1;
		if nDownTime >= 0 then
			local szStr = Lib:TimeDesc3(nDownTime);
			self.pPanel:Label_SetText("Countdown",szStr);
			return true;
		else
			self.pPanel:Label_SetText("Countdown","--:--");
			return false;
		end
	end)
end

function tbInfoUi_B:UpdateContent()
	local tbInfo = Foku.tbFightInfo or {};
	if tbInfo.nMsgType == Foku.MSG_TYPE_SLZ_SKILL then
		self.pPanel:Label_SetText("Camp1Num", tbInfo.nSkill1 or 0);
		self.pPanel:Label_SetText("Camp2Num", tbInfo.nSkill2 or 0);
		self.pPanel:Label_SetText("ProgressBarTxt1",tbInfo.nSLZ1 or 0);
		self.pPanel:Label_SetText("ProgressBarTxt2",tbInfo.nSLZ2 or 0);
		self.pPanel:SliderBar_SetValue("ProgressBarBg1" , tbInfo.nSLZ1 / Foku.SLZ_2_SKILL);
		self.pPanel:SliderBar_SetValue("ProgressBarBg2" , tbInfo.nSLZ2 / Foku.SLZ_2_SKILL);
	elseif tbInfo.nMsgType == Foku.MSG_TYPE_FIGHT_INIT then
		self.pPanel:Label_SetText("Camp1",  tbInfo.szKinName1 or "本方");
		self.pPanel:Label_SetText("Camp2",  tbInfo.szKinName2 or "敌方");
		self:MainDownTime(tbInfo.nEndTime);
	end

end


--------------------------------------------------------------------------

local tbResultUi = Ui:CreateClass("FKBattleResultPanel")

tbResultUi.tbKeys = 
{
	--Foku.KIN_AWARD_TYPE_WIN = 1;
	[1] = 
	{
		["szHead"] = "Victory",
		["szFlag1"] = "SelfWinFlag",
		["szFlag2"] = "OtherTransportFlag",
		["szName1"] = "SelfWinName",
		["szTitle1"] = "SelfWinTitle",
		["szTitle2"] = "OtherTransportTitle",
		["szName2"] = "OtherTransportName",
	},
	--Foku.KIN_AWARD_TYPE_LOST = 2;
	[2] =
	{
		["szHead"] = "Fail",
		["szFlag1"] = "SelfTransportFlag",
		["szFlag2"] = "OtherWinFlag",
		["szTitle2"] = "OtherWinTitle",
		["szName1"] = "SelfTransportName",
		["szTitle1"] = "SelfTransportTitle",
		["szName2"] = "OtherWinName",

	},
	--Foku.KIN_AWARD_TYPE_TIED = 3;
	[3] = 
	{
		["szHead"] = "Draw",
		["szFlag1"] = "SelfDrawFlag",
		["szFlag2"] = "OtherDrawFlag",
		["szName1"] = "SelfDrawName",
		["szTitle1"] = "SelfDrawTitle",
		["szName2"] = "OtherDrawName",
		["szTitle2"] = "OtherDrawTitle"
	}
}

function tbResultUi:OnOpen()
	local tbInfo = Foku.tbResultInfo ;
	--self.pPanel:DragScrollViewGoTop("ScrollView");
	self.pPanel:DragScrollViewGoTop("Datagroup");
	--self.Datagroup.pPanel:ScrollViewGoTop()
	--Lib:Tree(self);
	if not tbInfo then return end;
	for i = 1 , 3 do
		local tbTmp = self.tbKeys[i];
		Lib:Tree(tbTmp);
		local bIsShow = (i == tbInfo.nResult);
		self.pPanel:SetActive(tbTmp.szHead,bIsShow)
		self.pPanel:SetActive(tbTmp.szFlag2,bIsShow);
		self.pPanel:SetActive(tbTmp.szFlag1,bIsShow);
	end
	local tbTmp = self.tbKeys[tbInfo.nResult];
	if not tbTmp then return end;
	for i = 1 , 8 do
		local szName1 = tbInfo.tbCamp1[i] and tbInfo.tbCamp1[i].szName or "-";
		local szName2 = tbInfo.tbCamp2[i] and tbInfo.tbCamp2[i].szName or "-";
		local nHonorLevel1 = tbInfo.tbCamp1[i] and tbInfo.tbCamp1[i].nHonorLevel or 0;
		local nHonorLevel2 = tbInfo.tbCamp2[i] and tbInfo.tbCamp2[i].nHonorLevel or 0;
		self.pPanel:Label_SetText(tbTmp.szName1..i , szName1);
		self.pPanel:Label_SetText(tbTmp.szName2..i , szName2);
		local ImgPrefix, Atlas = Player:GetHonorImgPrefix(nHonorLevel1);
		if ImgPrefix then
			self.pPanel:SetActive(tbTmp.szTitle1..i,true);
			self.pPanel:Sprite_Animation(tbTmp.szTitle1..i, ImgPrefix, Atlas);
		else
			self.pPanel:SetActive(tbTmp.szTitle1..i, false);
		end

		ImgPrefix, Atlas = Player:GetHonorImgPrefix(nHonorLevel2);
		if ImgPrefix then
			self.pPanel:SetActive(tbTmp.szTitle2..i,true);
			self.pPanel:Sprite_Animation(tbTmp.szTitle2..i, ImgPrefix, Atlas);
		else
			self.pPanel:SetActive(tbTmp.szTitle2..i, false);
		end
	end
end

tbResultUi.tbOnClick = {
	BtnClose = function()
		Ui:CloseWindow("FKBattleResultPanel");
	end
}

--结算界面 关闭的时候。界面打开离开按钮


