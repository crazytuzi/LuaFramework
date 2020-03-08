
Faction.MAX_JUMPSKILL_COUNT = 10;

function Faction:Init()
	local tbParam = {"nId", "szName", "szSmallIcon", "szIcon", "szBigIcon", "szBigIconAtlas" ,"szWordIcon","szSchoolIcon", "szSchoolIconAtlas", "szSelectIcon", "StatueNpc", "szBackground1", "szBackground2", "szShareBgTextureM", "szShareBgTextureF", "DefaultWeapon"};
	local szType = "dsssssssssdssssd";
	for i = 1, self.MAX_JUMPSKILL_COUNT do
		table.insert(tbParam, "nJumpSkillId" .. i);
		szType = szType .. "d";
	end

	self.tbFactionInfo = LoadTabFile("Setting/Faction/faction.tab", szType, "nId", tbParam);
	if not self.tbFactionInfo then
		Log("error!! Load Faction info faild")
		return;
	end
end

if not Faction.tbFactionInfo then
	Faction:Init();
end

Faction.MAX_FACTION_COUNT = Lib:CountTB(Faction.tbFactionInfo);

function Faction:GetSmallIcon(nFaction)
	local tbInfo = self.tbFactionInfo[nFaction]
	if tbInfo then
		return tbInfo.szSmallIcon
	end
	return ""
end

function Faction:GetIcon(nFaction)
	local tbInfo = self.tbFactionInfo[nFaction]
	if tbInfo then
		return tbInfo.szIcon
	end
	return ""
end

function Faction:GetBigIcon(nFaction)
	local tbInfo = self.tbFactionInfo[nFaction]
	if tbInfo then
		return tbInfo.szBigIcon, tbInfo.szBigIconAtlas
	end
	return ""
end

function Faction:GetWordIcon(nFaction)
	local tbInfo = self.tbFactionInfo[nFaction]
	if tbInfo then
		--同门派的 szBigIcon 和 szWordIcon 是放到一个图集的
		return tbInfo.szWordIcon, tbInfo.szBigIconAtlas
	end
	return ""
end

function Faction:GetFactionSchoolIcon( nFaction )
	local tbInfo = self.tbFactionInfo[nFaction]
	if tbInfo then
		return tbInfo.szSchoolIcon, tbInfo.szSchoolIconAtlas
	end
	return ""
end

function Faction:GetBGSelectIcon(nFaction)
	local tbInfo = self.tbFactionInfo[nFaction]
	if tbInfo then
		return tbInfo.szSelectIcon
	end
	return ""
end

function Faction:GetName(nFaction)
	local tbInfo = self.tbFactionInfo[nFaction]
	if tbInfo then
		return tbInfo.szName;
	end
	return ""
end

function Faction:GetJumpSkillId(nFaction, nJSkillKind)
	local tbFaction = self.tbFactionInfo[nFaction];
	assert(tbFaction);

	local nSkillId = tbFaction["nJumpSkillId" .. nJSkillKind] or 0;
	return nSkillId == 0 and tbFaction.nJumpSkillId1 or nSkillId;
end

function Faction:GetFactionStatue(nFaction)
	local tbFaction = self.tbFactionInfo[nFaction];
	return tbFaction.StatueNpc;
end

function Faction:GetFactionIdByName(szFactionName)
	if not self.tbFactionNameToId then
		self.tbFactionNameToId = {}
		for k,v in pairs(self.tbFactionInfo) do
			self.tbFactionNameToId[v.szName] = k
		end
	end
	return self.tbFactionNameToId[szFactionName]
end

function Faction:GetShareBgTexture(nFaction, nSex)
	local tbFaction = self.tbFactionInfo[nFaction];
	local szDir = "UI/Textures/ShareBg/";
	if nSex == Player.SEX_FEMALE then
		szDir = szDir .. tbFaction.szShareBgTextureF;
	else
		szDir = szDir .. tbFaction.szShareBgTextureM;
	end
	print("szDir", szDir, nFaction, nSex)
	return szDir;
end

function Faction:GetSeriesFaction(nSeries)
	if not self.tbSeriesFaction then
		self.tbSeriesFaction = {}
		for nFaction = 1, Faction.MAX_FACTION_COUNT do
			for nSex = Gift.Sex.Boy, Gift.Sex.Girl do
				local tbInfo = KPlayer.GetPlayerInitInfo(nFaction, nSex)
				if tbInfo then
					self.tbSeriesFaction[tbInfo.nSeries] = self.tbSeriesFaction[tbInfo.nSeries] or {}
					table.insert(self.tbSeriesFaction[tbInfo.nSeries], nFaction)
					break
				end
			end
		end
	end
	return self.tbSeriesFaction[nSeries] 
end

function Faction:IsMultiWeaponFaction(nFaction)
	if nFaction and self.tbFactionInfo[nFaction] then
		return self.tbFactionInfo[nFaction].DefaultWeapon > 0
	end
	return false
end