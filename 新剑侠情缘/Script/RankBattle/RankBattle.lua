
function RankBattle:Init()
	self.tbRank = self.tbRank or {}
	self.tbPlayerRank = self.tbPlayerRank or {};
	self.tbEnemy = self.tbEnemy or {};
	self.tbAttrib = {}
	
	self.tbNpcSetting = LoadTabFile("Setting/RankBattle/RankBattleNpcTeam.tab", "dssddddddddddddddddddd", "TeamID", {
		"TeamID", "Name", "HeroName", "Faction", "Level", "ExtAttribId", "HonorLevel",
		"PartnerId1", "PartnerId2", "PartnerId3", "PartnerId4", "PartnerLevel", 
		"Strength", "Vitality", "Dexterity", "Energy", "SkillLevel", "SkillID1","SkillID2","SkillID3","SkillID4","SkillID5",});

	local tbAttribFile = LoadTabFile("Setting/RankBattle/RankNpcAttrib.tab", "dsddd", nil, {"AttribId", "AttribType", "Value1", "Value2", "Value3"});
	
	for _, tbInfo in ipairs(tbAttribFile) do
		self.tbAttrib[tbInfo.AttribId] = self.tbAttrib[tbInfo.AttribId] or {}
		
		table.insert(self.tbAttrib[tbInfo.AttribId],
		{
			szAttribType = tbInfo.AttribType,
			tbValue = 
			{
				tbInfo.Value1,
				tbInfo.Value2,
				tbInfo.Value3,
			},
		})
	end
end

RankBattle:Init()

function RankBattle:UpdateTenPlayer(tbTen, tbSelfInfo, nTimerAward)
	self.tbTen = tbTen;
	self.tbSelfInfo = tbSelfInfo;
	self.nTimerAward = nTimerAward;
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_RANK)
end

function RankBattle:UpdateEnemy(tbEnemy, nFrashEnemyCD)
	self.tbEnemy = tbEnemy;
	self.nFrashEnemyCD = nFrashEnemyCD;
	
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_RANK)
end

function RankBattle:Update()
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_RANK)
end

function RankBattle:UpdateEnemyByIdx(nIdx, tbOneEnemy)
	self.tbEnemy = self.tbEnemy or {}
	
	self.tbEnemy[nIdx] = tbOneEnemy;
	
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_RANK)
end

function RankBattle:UpdateAward(nResValue, nAward)
	self.nResValue = nResValue;
	self.nAward = nAward
	if self.nAward > 0 then
		Ui:SetRedPointNotify("RankBattle_FetchAward")
	else
		Ui:ClearRedPointNotify("RankBattle_FetchAward")
	end
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_RANK)
end

function RankBattle:UpdateLeave(bShow)
	if bShow then
		Ui:SetMapCloseUI(me.nMapTemplateId, {"LeavePanel"})
		Ui:OpenWindow("LeavePanel", "认输", "您确认投降认输么？", {
			function () 
				RemoteServer.EndAsyncBattle()
			end});
	else
		Ui:CloseWindow("LeavePanel");
	end
end

function RankBattle:SynRankData(nDefNo, nVersion)
	self.nActDefNo = nDefNo
	self.nActVersion = nVersion
end

