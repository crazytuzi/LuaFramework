local tbUi = Ui:CreateClass("PlayerFace");

local szDefaultFactionIcon = "faction_hammer";

function tbUi:SetNpc(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		self:Clear();
		return;
	end

	self.pPanel:Label_SetText("Level", tostring(pNpc.nLevel));
	self.pPanel:Label_SetText("Name", pNpc.szName);
	self.pPanel:Sprite_SetSprite("Faction", Faction:GetIcon(pNpc.nFaction) or szDefaultFactionIcon);
end

function tbUi:SetFaction(nFaction)
    self.pPanel:Sprite_SetSprite("Faction", Faction:GetIcon(nFaction) or szDefaultFactionIcon);
end

function tbUi:SetLevel(nLevel)
    self.pPanel:Label_SetText("Level", tostring(nLevel));
end

function tbUi:SetFaceByTemplate(nNpcTemplateId)
	local nFaceId = KNpc.GetNpcShowInfo(nNpcTemplateId);
	local szAtlas, szSprite = Npc:GetFace(nFaceId);
	self:SetFace(szAtlas, szSprite);
end

function tbUi:SetFaceByPortrait(nPortrait)
	local szIcon, szIconAtlas = PlayerPortrait:GetPortraitIcon(nPortrait);
	self:SetFace(szIconAtlas, szIcon);
end

function tbUi:SetFace(szAtlas, szSprite)
	if Lib:IsEmptyStr(szAtlas) or Lib:IsEmptyStr(szSprite) then
		return;
	end		

    self.pPanel:Sprite_SetSprite("PlayerFace", szSprite, szAtlas); 
end

function tbUi:Clear()
	self.pPanel:Label_SetText("Level", "--");
	self.pPanel:Label_SetText("Name", "");
	self.pPanel:Sprite_SetSprite("Faction", szDefaultFactionIcon);
end

