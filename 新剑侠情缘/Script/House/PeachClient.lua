local tbPeach = House.tbPeach;

function tbPeach:GetPeachData()
	return self.tbClientPeachData;
end

function tbPeach.OnSyncPeachData(tbPeachData)
	tbPeach.tbClientPeachData = tbPeachData;

	if House:IsInNormalHouse(me) then
		local tbPeachRes = Decoration:GetClass("Peach");
		tbPeachRes:UpdateRepState();
	end


	UiNotify.OnNotify(UiNotify.emNOTIFY_HOUSE_PEACH_SYNC_DATA);
end

function tbPeach:UpdateEffect(nEffectIdx)
	if me.nMapTemplateId ~= tbPeach.FAIRYLAND_MAP_TEMPLATE_ID then
		return;
	end

	local nEffectId = tbPeach.FAIRYLAND_TREE_EFFECT_ID[nEffectIdx];
	if self.nPreEffectId and self.nPreEffectId ~= nEffectId then
		Ui.Effect.StopEffect(self.nPreEffectId);
	end

	if self.nPreEffectId ~= nEffectId and nEffectId then
		local nLoop = 1;
		local nX, nY = unpack(tbPeach.FAIRYLAND_EFFECT_POS);
		nX = nX * Map.CELL_WIDTH;
		nY = nY * Map.CELL_WIDTH;
		Ui.Effect.CreateEffect(nEffectId, nLoop, nX, nY, 0, 0, 0, 0, 0, 0, 1);
		self.nPreEffectId = nEffectId;
	end
end

function tbPeach.OnSyncFairylandEffect(nEffectIdx)
	tbPeach.nFairylandEffectIdx = nEffectIdx;
	tbPeach:UpdateEffect(nEffectIdx);
end


function tbPeach.OnSyncMyPeachData(nFairyId, nAwardIdx)
	tbPeach.nMyFairyId = nFairyId or 0;
	tbPeach.nMyAwardIdx = nAwardIdx or 0;
	UiNotify.OnNotify(UiNotify.emNOTIFY_HOUSE_PEACH_SYNC_DATA);
end

function tbPeach:GetMyAwardIdx()
	return self.nMyAwardIdx or 0;
end

function tbPeach:InMyFairyland()
	if me.nMapTemplateId ~= tbPeach.FAIRYLAND_MAP_TEMPLATE_ID then
		return false;
	end

	local tbPeachData = self:GetPeachData() or {};
	return tbPeachData.nFairyId == self.nMyFairyId;
end

function tbPeach:InFairyLand()
	return me.nMapTemplateId == tbPeach.FAIRYLAND_MAP_TEMPLATE_ID;
end

function tbPeach:OnLeaveHouse()
	self.tbClientPeachData = nil;

	local tbPeachRes = Decoration:GetClass("Peach");
	tbPeachRes:OnLeaveHouse();
end

function tbPeach:GoFairyland()
	self.nPreEffectId = nil;
	RemoteServer.HousePeachReq("GoFairyland");
end

function tbPeach:InvitedIntoFairyland(nInviterId)
	RemoteServer.HousePeachReq("InvitedIntoFairyland", nInviterId);
end

function tbPeach:Water()
	RemoteServer.HousePeachReq("Water");
end

function tbPeach:Fertilizer()
	RemoteServer.HousePeachReq("Fertilizer");
end

function tbPeach:BringUp()
	RemoteServer.HousePeachReq("BringUpFairylandPeach");
end

function tbPeach:TakeTreeAward(nAwardTreeIdx)
	RemoteServer.HousePeachReq("TakeTreeAward", nAwardTreeIdx);
end

function tbPeach.InviteFriend(nFriendId)
	RemoteServer.HousePeachReq("InviteFriend", nFriendId);
end

function tbPeach:OnMapLoaded(nMapTemplateId)
	if nMapTemplateId == tbPeach.FAIRYLAND_MAP_TEMPLATE_ID then
		Ui:OpenWindow("HomeScreenFuben", "HousePeach");
	end
	self.nPreEffectId = nil;
	self:UpdateEffect(self.nFairylandEffectIdx);
end

function tbPeach:OnMapLeave(nMapTemplateId)
	if nMapTemplateId == tbPeach.FAIRYLAND_MAP_TEMPLATE_ID then
		Ui:CloseWindow("HomeScreenFuben");
		self.nFairylandEffectIdx = nil;
	end
end

UiNotify:RegistNotify(UiNotify.emNOTIFY_MAP_LOADED, tbPeach.OnMapLoaded, tbPeach);
UiNotify:RegistNotify(UiNotify.emNOTIFY_MAP_LEAVE, tbPeach.OnMapLeave, tbPeach);