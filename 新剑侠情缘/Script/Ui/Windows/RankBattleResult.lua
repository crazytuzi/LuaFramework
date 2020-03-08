
local tbRankResult = Ui:CreateClass("RankBattleResult");
local tbRankResultPartner = Ui:CreateClass("RankResultPartner");

tbRankResult.tbOnClick = {
	BtnOk = function (self)
		local nRet;
		if self.tbOKCallback then
			Lib:CallBack(self.tbOKCallback)
		else
			AsyncBattle:LeaveBattle();
		end
		Ui:CloseWindow(self.UI_NAME);
	end
}

local tbCamp2Prefix =
{
	"My",
	"Enemy",
}

local tbFailureHideBattleType = {
	BossFightBattle = true;
	BossFight_Client = true;
	CrossBossFightBattle = true;
	CrossBossFight_Client = true;
};

function tbRankResult:OnOpen(nResult, varMe, varEnemy, tbDamageCounter, tbCallback, szBattleClassType)
	self.tbOKCallback = tbCallback;

	local bHideFail = tbFailureHideBattleType[szBattleClassType];

	if nResult == 1 then
		self.pPanel:SetActive("Victory", true);
		self.pPanel:SetActive("Failure", false);
	else
		self.pPanel:SetActive("Victory", false);
		self.pPanel:SetActive("Failure", not bHideFail);
	end

	self.tbDamageCounter = tbDamageCounter;
	self.nMaxDamage = 0;
	for _, nDamage in pairs(tbDamageCounter) do
		if self.nMaxDamage < nDamage then
			self.nMaxDamage = nDamage;
		end
	end
	print("self.nMaxDamage", self.nMaxDamage);

	if type(varMe) == "number" then
		local pMeAsyncData = KPlayer.GetAsyncData(varMe)
		if pMeAsyncData then
			self:SetPlayerShow(pMeAsyncData, 1)
		end
	elseif type(varMe) == "table" then
		self:SetNpcShow(varMe, 1);
	end

	if type(varEnemy) == "number" then
		local pEnemyAsyncData = KPlayer.GetAsyncData(varEnemy)
		if pEnemyAsyncData then
			self:SetPlayerShow(pEnemyAsyncData, 2)
		end
	elseif type(varEnemy) == "table" then
		self:SetNpcShow(varEnemy, 2);
	end
end

-- tbInfo =
--{
--	{ szName, portrait, nFaction, nLevel },
--	{ nPartnerId1, nGrowthLevel1, nGradeLevel1, nLevel1 },
--	{ nPartnerId2, nGrowthLevel2, nGradeLevel2, nLevel2 },
--	...
--}
function tbRankResult:SetNpcShow(tbEnemy, nCamp)
	local szPrefix = tbCamp2Prefix[nCamp]
	local szName, portrait, nFaction, nLevel = unpack(tbEnemy[1])
	self.pPanel:Label_SetText(szPrefix.."Name",  szName);
	self.pPanel:Label_SetText(szPrefix.."Level", tostring(nLevel));

	local szFactionIcon = Faction:GetIcon(nFaction);
	if nFaction and szFactionIcon then
		self.pPanel:SetActive(szPrefix.."Faction", true);
		self.pPanel:Sprite_SetSprite(szPrefix.."Faction", szFactionIcon);
	else
		self.pPanel:SetActive(szPrefix.."Faction", false);
	end

	if type(portrait) == "number" then
		local szIcon, szIconAtlas = PlayerPortrait:GetSmallIcon(portrait);
		-- print(szIcon, _, szIconAtlas, portrait)
		self.pPanel:Sprite_SetSprite(szPrefix.."Head", szIcon, szIconAtlas);
	elseif type(portrait) == "table" then
		local nFaceId = KNpc.GetNpcShowInfo(unpack(portrait));
    	local IconSmallAtlas, IconSmall = Npc:GetFace(nFaceId);
		self.pPanel:Sprite_SetSprite(szPrefix.."Head", IconSmall, IconSmallAtlas);
	end

	self.pPanel:Sprite_SetFillPercent(szPrefix.."DamageBar1", (self.tbDamageCounter[nCamp * 10 + 1] or 0) / self.nMaxDamage)

	local nPos = 2
	for i = 1, 4 do
		local nIdx = i + 1;
		if tbEnemy[nIdx] then
			local nPartnerId, nFightPower, nLevel = unpack(tbEnemy[nIdx]);
			self[szPrefix..nPos]:SetPartner(nPartnerId, nFightPower, nLevel, self.tbDamageCounter[nCamp * 10 + nIdx] or 0, self.nMaxDamage)
			nPos = nPos + 1;
		end
	end
	for i = nPos, 5 do
		self[szPrefix..i]:SetPartner(0)
	end
end



function tbRankResult:SetPlayerShow(pAsyncData, nCamp)
	local szPrefix = tbCamp2Prefix[nCamp]
	local szName, nPortrait, nLevel, nFaction = pAsyncData.GetPlayerInfo();

	self.pPanel:Label_SetText(szPrefix.."Name",  szName);
	self.pPanel:Label_SetText(szPrefix.."Level", tostring(nLevel));
	local szFactionIcon = Faction:GetIcon(nFaction);
	self.pPanel:Sprite_SetSprite(szPrefix.."Faction", szFactionIcon);

	local szIcon, szIconAtlas = PlayerPortrait:GetSmallIcon(nPortrait);
	self.pPanel:Sprite_SetSprite(szPrefix.."Head", szIcon, szIconAtlas);

	self.pPanel:Sprite_SetFillPercent(szPrefix.."DamageBar1", (self.tbDamageCounter[nCamp * 10 + 1] or 0) / self.nMaxDamage)

	local nPos = 2
	for i = 1, 4 do
		local nIdx = i + 1;
		local nPartnerId, nLevel, nFightPower = pAsyncData.GetPartnerInfo(i);		--- partner ERR ??
		if nPartnerId and nPartnerId > 0 then
			self[szPrefix..nPos]:SetPartner(nPartnerId, nFightPower, nLevel, self.tbDamageCounter[nCamp * 10 + nIdx] or 0, self.nMaxDamage)
			nPos = nPos + 1;
		end
	end
	for i = nPos, 5 do
		self[szPrefix..i]:SetPartner(0)
	end
end

function tbRankResultPartner:SetPartner(nPartnerId, nFightPower, nLevel, nDamage, nMaxDamage)
	if not nPartnerId or nPartnerId == 0 then
		self.pPanel:SetActive("Main", false)
		return;
	end

	self.pPanel:SetActive("Main", true)

	local szName, nQualityLevel, nNpcTemplateId = GetOnePartnerBaseInfo(nPartnerId)
	self.pPanel:Label_SetText("PartnerName", szName);
	self.PartnerBg:SetPartnerFace(nNpcTemplateId, nQualityLevel, nLevel, nFightPower);

	print("SetDamage", nDamage / nMaxDamage)
	self.pPanel:Sprite_SetFillPercent("DamageBar", nDamage / nMaxDamage)
end


