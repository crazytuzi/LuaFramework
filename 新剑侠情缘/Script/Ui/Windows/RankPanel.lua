

local tbRankPanel = Ui:CreateClass("RankPanel");

function tbRankPanel:OnOpen()
	RemoteServer.RankEnemyRequest()
	RemoteServer.BattleArrayRequest();

	self.bBottom = true;
	self:UpdateEnemy()

	self:OnUpdateTimer()
end

function tbRankPanel:OnClose()
	if self.nTimer then
		Timer:Close(self.nTimer)
		self.nTimer = nil
	end
end

tbRankPanel.tbOnClick =
{
	BtnBack = function (self)
		Ui:CloseWindow(self.UI_NAME);
	end,
	BtnRefresh = function (self)
		RemoteServer.RefreshEnemy()
	end,
	BtnBuyTimes = function (self)
		Ui:OpenWindow("QuickBuyOrUse", "RankBattle")
	end,
	BtnChangeArray = function (self)
		Ui:OpenWindow("PartnerArrayPanel", "关闭")
	end,
	BtnReceive = function (self)
		if RankBattle.nAward and RankBattle.nAward > 0 then
			RemoteServer.FetchRankBattleAward()
		else
			me.CenterMsg("当前没有可领奖励")
		end
	end,
}


local function StartFight(nFightType, nRankNo, nId)
	RemoteServer.StartRankBattle(nFightType, nRankNo, nId)
end

local function OnClickFight(tbEnemy)
	local nDegree = DegreeCtrl:GetDegree(me, "RankBattle");
	if nDegree <= 0 then
        Ui:OpenWindow("QuickBuyOrUse", "RankBattle")
		return;
	end

	if Map:IsFieldFightMap(me.nMapTemplateId) and me.nFightMode ~= 0 then
		me.CenterMsg("当前不允许参与，正在自动寻路回安全区");
		Ui:CloseWindow("RankPanel");
		local nX, nY = Map:GetDefaultPos(me.nMapTemplateId);
		AutoPath:GotoAndCall(me.nMapTemplateId, nX, nY, function ()
			Ui:OpenWindow("RankPanel");
			local nDegree = DegreeCtrl:GetDegree(me, "RankBattle");
			if nDegree <= 0 then
				Ui:OpenWindow("QuickBuyOrUse", "RankBattle")
			else
				Ui:OpenWindow("PartnerArrayPanel", "开始战斗", StartFight, tbEnemy.nFightType, tbEnemy.nRankNo, tbEnemy.nId)
			end
			Ui:CloseWindow("RankPanel")
		end);
		return;
	end
	Ui:OpenWindow("PartnerArrayPanel", "开始战斗", StartFight, tbEnemy.nFightType, tbEnemy.nRankNo, tbEnemy.nId)
end


function tbRankPanel:UpdateEnemy()
    if not RankBattle.tbEnemy or not RankBattle.tbTen then
    	return;
    end

    local nSelfNo = RankBattle:GetDefNo();
    if RankBattle.tbSelfInfo then
    	nSelfNo = RankBattle.tbSelfInfo.nRankNo;
    	self.pPanel:Label_SetText("TxtSelfRankNo", tostring(RankBattle.tbSelfInfo.nRankNo));
    end

	self.tbListId = {}
	self.tbInfo = {}
	for _, tbUnableAttack in ipairs(RankBattle.tbTen) do
		self.tbListId[tbUnableAttack.nRankNo] = 0;
		table.insert(self.tbInfo, tbUnableAttack);
	end

	for i =  #RankBattle.tbEnemy, 1, -1 do
		local nRankNo = RankBattle.tbEnemy[i].nRankNo;
		if not self.tbListId[nRankNo] then
			table.insert(self.tbInfo, RankBattle.tbEnemy[i])
		end
		self.tbListId[nRankNo] = 1
	end

	if RankBattle.tbSelfInfo and not self.tbListId[RankBattle.tbSelfInfo.nRankNo] then
		table.insert(self.tbInfo, RankBattle.tbSelfInfo)
	end

    local fnSetItem = function(tbEnemy, index)
    	local nRankNo = self.tbInfo[index].nRankNo;
    	if self.tbListId[nRankNo] == 1 or
    		(nSelfNo <= RankBattle.NO_LIMIT_RANK and nRankNo <= RankBattle.NO_LIMIT_RANK and nSelfNo ~= nRankNo) then	-- 前5能互殴
			tbEnemy:SetEnemy(self.tbInfo[index], OnClickFight);
		else
			tbEnemy:SetEnemy(self.tbInfo[index]);
		end
    end
    self.ScrollView:Update(#self.tbInfo, fnSetItem);

    self:OnUpdateDegree();

    local nHour = tonumber(os.date("%H", GetTime()))
    local nResultHour = 0;
    for _, nAwardTIme in ipairs(RankBattle.tbAWARD_TIME) do
    	if nHour < nAwardTIme then
    		nResultHour = nAwardTIme;
    	end
    end
    self.pPanel:Label_SetText("AwardTime", nResultHour..":00");
    self.pPanel:Label_SetText("TxtAward", tostring(RankBattle.nTimerAward or 0));
    self.pPanel:Label_SetText("TxtAwardAccumulation", tostring(RankBattle.nResValue or 0));

    if self.bBottom and #RankBattle.tbEnemy > 0 and #RankBattle.tbTen > 0 then
    	self.bBottom = false;
		if nSelfNo < 5 then
			self.ScrollView:GoTop()
		elseif nSelfNo < 10 then
			self.ScrollView.pPanel:ScrollViewGoToIndex("Main", nSelfNo)
		else
			self.ScrollView:GoBottom();
		end
    end
end


function tbRankPanel:OnUpdateDegree()
    local nBattleDegree = DegreeCtrl:GetDegree(me, "RankBattle");
    self.pPanel:Label_SetText("TxtTimes", nBattleDegree.."/"..DegreeCtrl:GetMaxDegree("RankBattle"))
    if nBattleDegree == 0 then
    	self.pPanel:SetActive("BtnBuyTimes", true);
    else
    	self.pPanel:SetActive("BtnBuyTimes", false);
    end

    self.nNextAddTime = DegreeCtrl:GetNextAddTime(me, "RankBattle")
    self:UpdateNextAddTime();
end

function tbRankPanel:OnUpdateTimer()
	if not self.nTimer then
		self.nTimer = Timer:Register(Env.GAME_FPS, self.OnUpdateTimer, self)
	end
	if self.nNextAddTime and GetTime() > self.nNextAddTime then
		self:UpdateEnemy();
	end
	self:UpdateNextAddTime();
	return true;
end

function tbRankPanel:UpdateNextAddTime()
	if not self.nNextAddTime then
		self.pPanel:Label_SetText("TxtLassAddTime", "次数已满");
		return true
	end

	local nNextSecond = self.nNextAddTime - GetTime()
	self.pPanel:Label_SetText("TxtLassAddTime", string.format("%02d:%02d:%02d", math.floor(nNextSecond / 3600), math.floor(nNextSecond / 60) % 60, nNextSecond % 60));
	return true
end

function tbRankPanel:OnAutoHide(bHide)
	if not bHide then
		self:UpdateEnemy()
	end
end


function tbRankPanel:RegisterEvent()
    local tbRegEvent =
    {
        { UiNotify.emNOTIFY_SYNC_RANK,				self.UpdateEnemy},
        { UiNotify.emNOTIFY_UI_AUTO_HIDE,			self.OnAutoHide },
        { UiNotify.emNOTIFY_BUY_DEGREE_SUCCESS,		self.OnUpdateDegree}
    };

    return tbRegEvent;
end

