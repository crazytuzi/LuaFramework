local tbMainUi = Ui:CreateClass("LJFChallengePanel");
local tbResUi = Ui:CreateClass("LJFChallengeResult");
local tbBtnRevive = Ui:CreateClass("HomeScreenResurrection");
Fuben.LingJueFengWeek = Fuben.LingJueFengWeek or {};
local LingJueFengWeek = Fuben.LingJueFengWeek;
local TJMZ = Fuben.TianJiMiZhen;
function tbMainUi:RegisterEvent()
	local tbRegEvent = 
	{
		{UiNotify.emNoTIFY_LJF_WEEK_UPDATE, self.OnNotify, self},
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
	BtnClose = function(self)
		Ui:CloseWindow(self.UI_NAME)
	end;

	BtnTeam = function(self)
		self:CreateTeam();
	end;

	BtnStartChallenge = function(self)
		self:StartChallenge();
	end;

	BtnTips = function(self)
		self:OpenTips();
	end;

	BtnRank = function(self)
		self:OpenRank();
	end;
};

function tbMainUi:OnOpen(szActKey)
	Log("afdadfafdadsf",szActKey);

	self.bIsTJMZ = szActKey == "TianJiMiZhen"

	self.tbTeamMsg = nil;
	LingJueFengWeek:AskTeamMsg();
	self.pPanel:Label_SetText("Introduces", self.bIsTJMZ and TJMZ.szIntroducesTitle or LingJueFengWeek.szIntroducesTitle);
	self.pPanel:Label_SetText("IntroducesTxt", self.bIsTJMZ and TJMZ.szIntroducesTxt or LingJueFengWeek.szIntroducesTxt);
	self.pPanel:Label_SetText("RemainTime","2/2");
	for idx = 1 , 5 do
		local itemObj = self["itemframe"..idx];
		local tbItemId = LingJueFengWeek.tbAwardsId[idx];
		if not tbItemId then 
			itemObj.pPanel:SetActive("Main" , false);
		else
			itemObj.pPanel:SetActive("Main" , true);
			itemObj:SetGenericItem(tbItemId);
			itemObj.fnClick = itemObj.DefaultClick

		end
	end
	self.pPanel:SetActive("TJMZBG",self.bIsTJMZ);
	self.pPanel:SetActive("LJFBG",not self.bIsTJMZ);
	self.pPanel:Label_SetText("Title",self.bIsTJMZ and "天机迷阵" or "决战凌绝峰");
	self:UpdateContent();
end

function tbMainUi:UpdateContent()
	local tbMsg = LingJueFengWeek.tbTeamMsg;
	if tbMsg then 
		local nTmpFaildTime = self.bIsTJMZ and TJMZ.NLIMIT_FAILED_TIME or LingJueFengWeek.NLIMIT_FAILED_TIME;
		local szResTimes = (nTmpFaildTime - tbMsg.nDailyFailTimes) .. "/"..nTmpFaildTime;
		self.pPanel:Label_SetText("RemainTime",szResTimes);
		local szTeamMemer = string.format("%s、%s、%s", tbMsg[1],tbMsg[2],tbMsg[3]);
		self.pPanel:Label_SetText("TeamTime",szTeamMemer);
		self.pPanel:Label_SetText("TeamName",tbMsg.szTeamName);
		local szLevelRoom = "";
		if tbMsg.nLevel > 1 then 
			szLevelRoom = (tbMsg.nLevel - 1).. "层";
		end
		if self.bIsTJMZ then
			szLevelRoom = (TJMZ.tbTeamData and TJMZ.tbTeamData.nPassNum or 0).."/"..TJMZ.COL * TJMZ.ROW;
		end
		self.pPanel:SetActive("TeamTime",true);
		self.pPanel:SetActive("WinningProbability" ,true);
		self.pPanel:Label_SetText("WinningProbability",szLevelRoom);
		self.pPanel:Label_SetText("TeamTitle1","战队名字：");
	else
		local nTmpFaildTime = self.bIsTJMZ and TJMZ.NLIMIT_FAILED_TIME or LingJueFengWeek.NLIMIT_FAILED_TIME;
		local szResTimes = nTmpFaildTime .. "/"..nTmpFaildTime;
		self.pPanel:Label_SetText("RemainTime",szResTimes);
		self.pPanel:Label_SetText("TeamTitle1","");
		self.pPanel:Label_SetText("TeamName","");
		self.pPanel:SetActive("TeamTime",false);
		self.pPanel:SetActive("WinningProbability" ,false);
		self.pPanel:Label_SetText("TeamTitle1","[FFFE0D]暂无战队[-]");
	end
	if self.bIsTJMZ then
		self.pPanel:Label_SetText("ReainTimeTxt","剩余失败次数：");
		self.pPanel:Label_SetText("Title3","通关秘境：")
	end
end

function tbMainUi:CreateTeam()
	if LingJueFengWeek.tbTeamMsg then
		me.CenterMsg("您已在战队当中");
		return ;
	elseif not TeamMgr:HasTeam() then 
		me.CenterMsg((self.bIsTJMZ and "天机迷阵" or "凌绝峰") .. "险象环生，请大侠先寻好队友,再前来组建战队！");
		return
	end

	if TeamMgr:IsCaptain(me.dwID) then
		Ui:OpenWindow("CreateTeamPanel", nil , true);
	else
		me.CenterMsg("您不是队长，无权操作");
	end
end

function tbMainUi:StartChallenge()
	LingJueFengWeek:TryEnterFuben(self.bIsTJMZ and "天机迷阵" or "凌绝峰");
end

function tbMainUi:OpenTips()
	Ui:OpenWindow("GeneralHelpPanel",self.bIsTJMZ and "TianJiMiZhenHelp" or "LingJueFengWeekHelp");
end

function tbMainUi:OpenRank()
	Ui:OpenWindow("RankBoardPanel",self.bIsTJMZ and "TianJiMiZhen" or "LingJueFengWeekRank");
end

---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------

function tbResUi:OnOpen(nLevel)
	if not nLevel then return end;
	for nIdx = 1 , LingJueFengWeek.TOTAL_LEVEL do
		local szDot = "Dot"..nIdx;
		local szStage = "StageDark"..nIdx;
		local szDirection = "Direction"..nIdx;
		
		self.pPanel:SetActive(szDot , nIdx < nLevel-1);
		self.pPanel:SetActive(szStage , nIdx >= nLevel);
		self.pPanel:SetActive(szDirection , nIdx == nLevel-1);
	end
	self.pPanel:SetActive("BtnClose" , false);
end

tbResUi.tbOnClick = {
	BtnClose = function(self)
	end;

	BtnQuit = function(self)
		local szMsg = "确认中止挑战吗？";
		me.MsgBox(szMsg,{
			{"确认", function()
			Ui:CloseWindow("LJFChallengeResult");
			Ui:CloseWindow("MessageBox");
			LingJueFengWeek:TryLeaveRoom();
			end}
		,{"取消", function() end}})
	end;

	BtnContinue = function(self)
		LingJueFengWeek:TryCrossChoice(true);
	end;
};

---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------

function tbBtnRevive:OnOpen(bOpenCostBtn)
	self.pPanel:SetActive("BtnResurrection2",bOpenCostBtn);
end

tbBtnRevive.tbOnClick = {
	BtnResurrection = function(self)
		LingJueFengWeek:TryRevive();
	end;
	BtnResurrection2 = function(self)
		LingJueFengWeek:TryRevive(true);
	end
};
