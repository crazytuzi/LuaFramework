KinBattle.Foku = KinBattle.Foku or {};
local Foku = KinBattle.Foku;

----------------------------------对服务器接口---------------------------------

function Foku:TryLeaveZone()
	RemoteServer.KinFoKuClientCall("TryLeave");
end

function Foku:TryEnterZone(nEnterType)
	RemoteServer.KinFoKuClientCall("TryEnterGame",nEnterType);
end

function Foku:TryAskMemberMsg(bOpenThree)
	RemoteServer.KinFoKuClientCall("AskMemberMsg",bOpenThree);
end

function Foku:TryUseSkill(nSkill)
	RemoteServer.KinFoKuClientCall("TryUseSkill",nSkill);
end

function Foku:TryApply()
	RemoteServer.KinFoKuClientCall("TryApply");
end

function Foku:AskIsOpen(bAsk)
	if bAsk or self.bIsOpen == nil or Lib:GetLocalDay(GetTime()) ~= (self.nVersion or 0) then
		self.nAskOpenCD = self.nAskOpenCD or 0;
		if self.nAskOpenCD + 10 < GetTime() then
			RemoteServer.KinFoKuClientCall("AskIsOpen");
			self.nAskOpenCD = GetTime();
		end
	end
	return self.bIsOpen;
end

function Foku:EnterSure(nApplyId)
	RemoteServer.KinFoKuClientToServer("AgreePlayer",nApplyId);
end

------------------------------------------------------------------------------

Foku.FnTips = {
	[Foku.TIP_TYPE_DOWNTIME1] = function()
		local szMsg = "我方进入倒计时，保护我方天龙珠持有人！"
		me.Msg(szMsg,ChatMgr.SystemMsgType.Kin);
		me.SendBlackBoardMsg(szMsg);
	end,
	[Foku.TIP_TYPE_DOWNTIME2] = function()
		local szMsg = "敌方进入倒计时，速速击杀对方天龙珠持有人！";
		me.Msg(szMsg,ChatMgr.SystemMsgType.Kin);
		me.SendBlackBoardMsg(szMsg);
	end,
	[Foku.TIP_TYPE_SLZ] = function()
		if Foku.bNotTipSLZ then return end;
		local szTips = "本轮天龙珠已刷新！";
		me.SendBlackBoardMsg(szTips);
	end,

	[Foku.TIP_TYPE_FLAG_ATTACK] = function(nFlagType)
	--注释不开启。旗子受攻击提示。
		-- local tbLinkInfo = {};
		-- tbLinkInfo.nMapId = me.nMapId;
		-- tbLinkInfo.nMapTemplateId = me.nMapTemplateId;
		-- local tbTmp = Foku.tbFlag_Revive[nFlagType];
		-- if not tbTmp then return end;
		-- tbLinkInfo.nX = tbTmp[1];
		-- tbLinkInfo.nY = tbTmp[2];
		-- tbLinkInfo.nLinkType = 2;
		-- local szTips = string.format("家族的<%s>正在被敌方攻击！",tbTmp[3]);
		-- me.SendBlackBoardMsg(szTips);
		-- Foku:ClientMsg(szTips,tbLinkInfo);
	end,
	[Foku.TIP_TYPE_FLAG_DEATH] = function(nFlagType)
		local tbLinkInfo = {};
		tbLinkInfo.nMapId = me.nMapId;
		tbLinkInfo.nMapTemplateId = me.nMapTemplateId;
		local tbTmp = Foku.tbFlag_Revive[nFlagType];
		if not tbTmp then return end;
		tbLinkInfo.nX = tbTmp[1];
		tbLinkInfo.nY = tbTmp[2];
		tbLinkInfo.nLinkType = 2;
		local szTips = string.format("<%s>已经被敌方占据！",tbTmp[3]);
		me.SendBlackBoardMsg(szTips);
		Foku:ClientMsg(szTips,tbLinkInfo);
		local tbMapTextPosInfo = Map:GetMapTextPosInfo(me.nMapTemplateId);
		local tbPosInfo = tbMapTextPosInfo[nFlagType + 6];
		tbPosInfo.Text = string.format("[ff578c]「%s」占据[-]",Foku.szHimKinName or "敌方");
	end,
	[Foku.TIP_TYPE_FLAG_OCCUPY] = function(nFlagType)
		Log("TIP_TYPE_FLAG_OCCUPY",nFlagType);
		local tbMapTextPosInfo = Map:GetMapTextPosInfo(me.nMapTemplateId);
		local tbPosInfo = tbMapTextPosInfo[nFlagType + 6];
		tbPosInfo.Text = string.format("[11adf6]「%s」占据[-]",Foku.szMeKinName or "本方");
	end,
	[Foku.TIP_TYPE_ME_DEATH] = function()
		me.MsgBox( string.format("您已身受重伤\n%%d秒后复活"),{{"确定",function() end}}, nil, 10,
		function() Ui:CloseWindow("MessageBox") end)
	end
}

function Foku:ClientMsg(szTips, tbLinkInfo)
	ChatMgr:OnChannelMessage(ChatMgr.ChannelType.System, 4, "", nFaction, nPortrait, nLevel, szTips, uFileIdHigh, uFileIdLow, uVoiceTime, nSexAndNamePrefix, nHeadBg, nChatBg, tbLinkInfo, szApolloVoiceId)
end
function Foku:SendTips(nTipType,tbTips)
	if nTipType and Foku.FnTips[nTipType] then
		if me.nMapTemplateId == Foku.nFightMapTID_B or me.nMapTemplateId == Foku.nFightMapTID_A then
			Foku.FnTips[nTipType](tbTips);
		end
	end
end

Foku.FnAnalyMsg = {
	[Foku.MSG_TYPE_PRE] = function(tbInfo)
		Foku.bNotTipSLZ = nil;
		Foku.tbPreMapInfo = tbInfo
		Foku:UpdatePreInfo();
	end,
	[Foku.MSG_TYPE_FIGHT_INIT] = function(tbInfo)
		Foku.bNotTipSLZ = nil;
		Foku.tbFightInfo = tbInfo;
		Ui:OpenWindow(tbInfo.szOpenWnd);
		Foku.szMeKinName = tbInfo.szKinName1;
		Foku.szHimKinName = tbInfo.szKinName2;
		if not Foku.bReconect then 
			Foku:ClearMapTips();
		end
	end,
	[Foku.MSG_TYPE_SCORE] = function(tbInfo)
		Foku.tbFightInfo = tbInfo;
	end,
	[Foku.MSG_TYPE_END] = function(tbInfo)
		if tbInfo.nResult then
			Foku.bNotTipSLZ = true;
			Foku.tbResultInfo = tbInfo;
			Ui:OpenWindow("FKBattleResultPanel");
			local tbDownInfo = {};
			tbDownInfo.nMsgType = Foku.MSG_TYPE_DOWNTIME
			tbDownInfo.nCamp2DownTime = nil
			tbDownInfo.nCamp1DownTime = nil;
			Foku:SyncMsgClient(tbDownInfo);
		end
		Foku:ClearMapTips();
	end,
	[Foku.MSG_TYPE_SKILL] = function(tbInfo)
		Foku.tbInfo = tbInfo;
		Foku:AddSkill(tbInfo.tbSkills)
	end,
	[Foku.MSG_TYPE_DOWNTIME] = function(tbInfo)
		local tbTmp = {};
		tbTmp.nMsgType = Foku.MSG_TYPE_DOWNTIME;
		if tbInfo.bIsEnemy then
			tbTmp.nCamp2DownTime = tbInfo.nCamp1DownTime;
			tbTmp.nCamp1DownTime = tbInfo.nCamp2DownTime;
		else
			tbTmp.nCamp2DownTime = tbInfo.nCamp2DownTime;
			tbTmp.nCamp1DownTime = tbInfo.nCamp1DownTime;
		end
		Foku.tbFightInfo = tbTmp;
	end,

	[Foku.MSG_TYPE_SLZ_SKILL] = function(tbInfo)
		local tbTmp = {};
		tbTmp.nMsgType = Foku.MSG_TYPE_SLZ_SKILL;
		if tbInfo.bIsEnemy then
			tbTmp.nSkill1 = tbInfo.nSkill2;
			tbTmp.nSkill2 = tbInfo.nSkill1;
			tbTmp.nSLZ1 = tbInfo.nSLZ2;
			tbTmp.nSLZ2 = tbInfo.nSLZ1;
		else
			tbTmp = tbInfo;
		end
		Foku.tbFightInfo = tbTmp;
	end,

	[Foku.MSG_TYPE_APPLY] = function(tbInfo)
		--推送感叹号提示
		tbInfo.szType = "KinFoKuBattle"
		Ui:SynNotifyMsg(tbInfo)
	end,

	[Foku.MSG_TYPE_BASEMSG] = function(tbInfo)
		Foku.bNotTipSLZ = nil;
		Foku.bIsOpen = tbInfo.bIsOpen;
		Foku.nStartTime = tbInfo.nStartTime;
		Foku.nVersion = Lib:GetLocalDay(GetTime());
		UiNotify.OnNotify(UiNotify.emNOTIFY_ONACTIVITY_STATE_CHANGE);
	end,

	[Foku.MSG_TYPE_KINDATA] = function(tbInfo)
		Foku.tbKinData = tbInfo.tbKin;
		if tbInfo.bOpenThree then
			Ui:OpenWindow("ThreeChoosePanel");
		end 
		Foku.tbTeamData = tbInfo.tbKin and tbInfo.tbKin.tbTeam or {};
	end,
}

function Foku:ClearMapTips()
	local tbMapTextPosInfo = Map:GetMapTextPosInfo(me.nMapTemplateId);
	if not tbMapTextPosInfo then return end;
	for i = 7 , 12 do 
		local tbPosInfo = tbMapTextPosInfo[i];
		if tbPosInfo then
			tbPosInfo.Text = "无人占据";
		end
	end
end

function Foku:SyncMsgClient(tbInfo)
	if not tbInfo then return end;
	if self.FnAnalyMsg[tbInfo.nMsgType] then
		self.FnAnalyMsg[tbInfo.nMsgType](tbInfo);
		UiNotify.OnNotify(UiNotify.emNoTIFY_SYNC_FOKU_BATTLE);
	end
	Foku:CheckUi();
end


function Foku:CheckUi(bCloseAll)
	-- local tbNeedUi = {};
	-- for nMapTID, tbUi in pairs(Foku.tbMAP_UI) do
	-- 	for _ , szUI in pairs(tbUi) do
	-- 		if nMapTID ~= me.nMapTemplateId then
	-- 			tbNeedUi[szUI] = tbNeedUi[szUI] or false;
	-- 		else
	-- 			tbNeedUi[szUI] = true;
	-- 		end
	-- 	end
	-- end
	-- for szUI , bNeed in pairs(tbNeedUi) do
	-- 	if not bNeed or bCloseAll then
	-- 		Ui:CloseWindow(szUI);
	-- 	else
	-- 		if Ui:WindowVisible(szUI) ~= 1 then
	-- 			Ui:OpenWindow(szUI,"KinFokuPre",{0,0,0});
	-- 			RemoteServer.KinFoKuClientCall("FlushUi");
	-- 		end
	-- 	end
	-- end
end

function Foku:UpdatePreInfo()
	local tbInfo = self.tbPreMapInfo or {0,0,0}
	tbInfo[3] = tbInfo[3] - GetTime();
	if Ui:WindowVisible("QYHLeftInfo") ~= 1 then
	else
		Ui("QYHLeftInfo"):UpdateInfo(tbInfo);
	end
end



function Foku:AddSkill(tbSkillInfo)
	self.tbSkill = self.tbSkill or {};
	for _ , tbSkill in pairs(tbSkillInfo) do
		self.tbSkill[tbSkill[1]] = tbSkill[2];
	end
	self.nNeedFlushPanel = true;
	UiNotify.OnNotify(UiNotify.emNoTIFY_SYNC_FOKU_BATTLE);
end


function Foku:TeamTips(pPlayer , szTips)
	Log("[INFO]","Foku","TeamTips UseLJF_Func");
	Fuben.LingJueFengWeek:TeamTips(pPlayer,szTips);
end

Foku.bIsOpenAct = Foku.bIsOpenAct or MODULE_ZONESERVER;
function Foku:SwitchActOpen(bIsOpen)
	self.bIsOpenAct = bIsOpen;

end



-------------------------------------------------------------------------------

