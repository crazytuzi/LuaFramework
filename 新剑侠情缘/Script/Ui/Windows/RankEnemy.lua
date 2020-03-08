
local tbRankEnemy = Ui:CreateClass("RankEnemy");

local tbRankNoWnd =
{
	{1, 		"ImgTop1"},
	{2, 		"ImgTop2"},
	{3, 		"ImgTop3"},
	{10, 		"TxtTop10", "TxtTop10"},
	{10000, 	"TxtTopX", "TxtTopX"},
}

tbRankEnemy.tbOnClick = {
	BtnFight = function (self)
		if self.fnClick then
			self.fnClick(self.tbEnemy)
		end
	end
}

function tbRankEnemy:SetEnemy(tbEnemy, fnClickCallback)
	self.tbEnemy = tbEnemy;
	self.fnClick = fnClickCallback;
	self.pPanel:Label_SetText("PlayerName",  tbEnemy.szName);
	self.pPanel:Label_SetText("TxtLevel", tostring(tbEnemy.nLevel));
	if tbEnemy.nHonorLevel and tbEnemy.nHonorLevel > 0 then
		self.pPanel:SetActive("PlayerTitle", true);
		local ImgPrefix, Atlas = Player:GetHonorImgPrefix(tbEnemy.nHonorLevel)
		self.pPanel:Sprite_Animation("PlayerTitle", ImgPrefix, Atlas);
	else
		self.pPanel:SetActive("PlayerTitle", false);
	end
	local szFactionIcon = Faction:GetIcon(tbEnemy.nFaction);
	self.pPanel:Sprite_SetSprite("ImgFaction", szFactionIcon);

	local nPortrait = tbEnemy.nPortrait;
	if not nPortrait then
		nPortrait = PlayerPortrait:GetDefaultId(tbEnemy.nFaction, Player:Faction2Sex(tbEnemy.nFaction));
	end
	local szIcon, szIconAtlas = PlayerPortrait:GetSmallIcon(nPortrait);
    self.pPanel:Sprite_SetSprite("SpRoleHead", szIcon, szIconAtlas);
    
	local nIdx = 0;
	for i, tbInfo in ipairs(tbRankNoWnd) do
		local nRankNo, szWndImg, szWndTxt = unpack(tbInfo)
		if tbEnemy.nRankNo <= nRankNo then
			self.pPanel:SetActive(szWndImg, true);
			if szWndTxt then
				self.pPanel:Label_SetText(szWndTxt, tostring(tbEnemy.nRankNo))
			end
			nIdx = i;
			break;
		else
			self.pPanel:SetActive(szWndImg, false);
		end
	end

	for i = nIdx + 1, #tbRankNoWnd do
		local nRankNo, szWndImg, szWndTxt = unpack(tbRankNoWnd[i])
		self.pPanel:SetActive(szWndImg, false);
	end

	if self.fnClick then
		self.pPanel:SetActive("BtnFight", true);
	else
		self.pPanel:SetActive("BtnFight", false);
	end

	for i = 1, 4 do
		if tbEnemy.tbPartner and tbEnemy.tbPartner[i] then
			local nPartnerId, nGrowthLevel = unpack(tbEnemy.tbPartner[i])
			self:SetPartner(i, nPartnerId, nGrowthLevel)
		else
			self.pPanel:SetActive("CompanionHead"..i, false)
		end
	end
	--self.pPanel:Button_SetEnabled(true);
end

function tbRankEnemy:SetPartner(nIdx, nPartnerId, nGrowthLevel)
	self.pPanel:SetActive("CompanionHead"..nIdx, true)
	self["CompanionHead" .. nIdx]:SetPartnerById(nPartnerId);
end
