
function CangBaoTu:OnUseItem(nItemId, nMapId, nX, nY, szTypeName)
	local pItem = KItem.GetItemObj(nItemId);
	if not pItem then
		return;
	end

	local nMapTemplateId, nPosX, nPosY = Item:GetClass("CangBaoTu"):GetCangBaoTuPos(pItem);
	nMapTemplateId = nMapId or nMapTemplateId;
	nPosX = nX or nPosX;
	nPosY = nY or nPosY;

	local tbMapSetting = Map:GetMapSetting(nMapTemplateId);

	local nItemtype= KItem.GetItemExtParam(pItem.dwTemplateId, 2);
	if nItemtype == Item:GetClass("CangBaoTu").TYPE_SENIOR then
		if TeamMgr:HasTeam() then
			local szLocaltion = string.format("藏宝图位于<%s(%d,%d)>", tbMapSetting.MapName, nPosX*Map.nShowPosScale, nPosY*Map.nShowPosScale);
			ChatMgr:SetChatLink(ChatMgr.LinkType.Position, {nMapTemplateId, nPosX, nPosY, nMapTemplateId});
			ChatMgr:SendMsg(ChatMgr.ChannelType.Team, szLocaltion);
		end
	end

	local function fnOnArive()
		RemoteServer.UseItem(nItemId);
		Ui:CloseWindow("QuickUseItem");
	end

	AutoFight:ChangeState(AutoFight.OperationType.Manual);

	AutoPath:GotoAndCall(nMapTemplateId, nPosX, nPosY, fnOnArive);

	szTypeName = szTypeName or "藏宝点"
	me.CenterMsg(string.format("%s位于[FFFE0D]%s(%s, %s)[-]，正在前往", szTypeName, tbMapSetting.MapName, math.floor(nPosX * Map.nShowPosScale), math.floor(nPosY * Map.nShowPosScale)));
	Ui:CloseWindow("ItemTips")
	Ui:CloseWindow("ItemBox");
	Ui:CloseWindow("QuickUseItem");
	Ui:OpenQuickUseItem(nItemId, "使  用");

end

function CangBaoTu:Update(nItemId)
	Ui:OpenQuickUseItem(nItemId, "使  用");
end

function CangBaoTu:UseItem(nItemId)
	if not nItemId then
		return
	end
	RemoteServer.UseItem(nItemId);
end

function CangBaoTu:UseItemAfterLoadMap( nItemId )
	if self.bRegisterEventLoadMap then
		UiNotify:UnRegistNotify(UiNotify.emNOTIFY_MAP_LOADED, self)
		self.bRegisterEventLoadMap = nil;
	end
	self.nCacheUseItemId = nItemId
	UiNotify:RegistNotify(UiNotify.emNOTIFY_MAP_LOADED, self.UseItemOnLoadMap, self)
end

function CangBaoTu:UseItemOnLoadMap(  )
	UiNotify:UnRegistNotify(UiNotify.emNOTIFY_MAP_LOADED, self)
	self.bRegisterEventLoadMap = nil;
	local nItemId = self.nCacheUseItemId
	if not nItemId then
		return
	end
	local pItem = me.GetItemInBag(nItemId)
	if not pItem  then
		return
	end
	Ui:OpenQuickUseItem(nItemId, "使  用")
	self:UseItem(nItemId)
end