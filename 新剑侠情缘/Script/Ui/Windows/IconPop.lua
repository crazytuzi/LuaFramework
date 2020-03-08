local tbUi = Ui:CreateClass("IconPop")
tbUi.tbOnClick = {};
tbUi.bCanSendLocation = true;

function tbUi:OnOpen()
	self.pPanel:SetActive("CD", false);
	self.pPanel:SetActive("CDTime", false);
end

function tbUi.tbOnClick:BgSprite()
	if self.bCanSendLocation then
		local nMapId, nPosX, nPosY = Decoration:GetPlayerSettingOrgPos(me);
		local nMapTemplateId = me.nMapTemplateId
		local szMapName = Map:GetMapDescInChat(nMapTemplateId)

		local szLocaltion = string.format("火娃在<%s(%d,%d)>附近，请注意！", szMapName, nPosX*Map.nShowPosScale, nPosY*Map.nShowPosScale);
		ChatMgr:SetChatLink(ChatMgr.LinkType.Position, {nMapId, nPosX, nPosY, nMapTemplateId});
		ChatMgr:SendMsg(ChatMgr.ChannelType.Team, szLocaltion);
		self.bCanSendLocation = false;
		self.pPanel:Sprite_SetCDControl("CD", 5, 5);
		Timer:Register(5 * Env.GAME_FPS, self.UpdateSendLocationCD, self);
	end
end

function tbUi:UpdateSendLocationCD()
	self.bCanSendLocation = true;
end