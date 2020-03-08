
function HousePlant:OnSyncHousePlant(tbData)
	self.tbHousePlant = tbData;

	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_PLANT);

	self:RefreshRepresent();
	self:ShowPlantTip();
end

function HousePlant:OnSyncFriendPlant(tbData)
	local tbSicks = {};
	for _, tbInfo in ipairs(tbData) do
		table.insert(tbSicks, { dwPlayerId = tbInfo.dwPlayerId, nState = tbInfo.nState, nImity = FriendShip:GetImity(me.dwID, tbInfo.dwPlayerId) });
	end
	table.sort(tbSicks, function (a, b)
		return a.nImity > b.nImity;
	end )

	self.tbFriendPlant = tbSicks;

	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_FRIEND_PLANT);
end

function HousePlant:GetLand()
	local tbLand = self.tbHousePlant;
	if not tbLand or tbLand.dwOwnerId ~= House.dwOwnerId then
		return;
	end
	return tbLand;
end

function HousePlant:OnCreateRepresent(nRepId)
	self.nRepId = nRepId;
	self.nRepresentState = nil;
	self:RefreshRepresent();

	Ui:CloseWindow("PlantStatePanel");
	self:ShowPlantTip();
end

function HousePlant:OnClick(nRepId)
	local tbLand = self:GetLand();
	if not tbLand then
		return;
	end

	if tbLand.nState == HousePlant.STATE_NULL then
		if me.dwID ~= tbLand.dwOwnerId then
			me.SendBlackBoardMsg("家园苗圃，房主可种植树木");
			return;
		end

		local fnConfirm = function ()
			RemoteServer.Plant();
		end

		local fnPlant = function ()
			me.MsgBox(string.format("确定要花费[FFFE0D]%d元宝[-]种下树丛吗？\n[FFFE0D]收成后可获得家具材料“木材”[-]", HousePlant.PLANT_COST), { { "确定", fnConfirm }, { "取消", nil } });
		end

		local fnClose = function ()
			HousePlant:ShowPlantTip();
		end
		Ui:CloseWindow("PlantStatePanel");
		Ui:OpenWindow("FurnitureOptUi", nRepId, {{"种植", fnPlant}}, fnClose, 80);
	else
		Ui:OpenWindow("PlantCurePanel");
	end
end

function HousePlant:RefreshRepresent()
	self:CloseStateTimer();

	if not self.nRepId then
		return;
	end

	local pRep = Ui.Effect.GetObjRepresent(self.nRepId);
	if not pRep then
		return;
	end

	local _, tbRepInfo = Decoration:GetRepInfoByRepId(self.nRepId);
	if not tbRepInfo then
		return;
	end

	local nState = nil;
	local tbLand = self:GetLand();
	if tbLand and tbLand.nState ~= HousePlant.STATE_NULL then
		nState = 3;
		if tbLand.nState ~= HousePlant.STATE_RIPEN then
			nState = 2;
			local nStateTime = HousePlant.RIPEN_TIME * 0.5;
			local nLeftTime = math.max(0, tbLand.nRipenTime - GetTime());
			if nLeftTime > nStateTime then
				nState = 1;
				self.nStateTimerId = Timer:Register(Env.GAME_FPS * (nLeftTime - nStateTime + 3), function ()
					self.nStateTimerId = nil;
					self:RefreshRepresent();
				end);
			end
		end
	end

	if self.nRepresentState == nState then
		return;
	end

	local tbSetting = Decoration.tbLandSetting[tbRepInfo.nTemplateId];
	assert(tbSetting, "land setting not exist: " .. tbRepInfo.nTemplateId);

	if self.nRepresentState then
		local tbEffect = assert(tbSetting[self.nRepresentState], string.format("land state setting not exist: %d, %d", tbRepInfo.nTemplateId, self.nRepresentState));
		pRep:RemoveEffectRes(tbEffect.szRes);
	end

	if nState then
		local tbEffect = assert(tbSetting[nState], string.format("land state setting not exist: %d, %d", tbRepInfo.nTemplateId, nState));
		pRep:AddEffectRes(tbEffect.szRes);
	end

	self.nRepresentState = nState;
end

function HousePlant:ShowPlantTip()
	if House.bDecorationMode then
		return;
	end

	if not self.nRepId or Ui:WindowVisible("PlantStatePanel") == 1 then
		return;
	end

	local tbLand = self:GetLand();
	if not tbLand then
		return;
	end

	Ui:OpenWindow("PlantStatePanel", self.nRepId);
end

function HousePlant:OnLeaveMap()
	self.tbHousePlant = nil;
	self.nRepId = nil;
	self.nRepresentState = nil;

	self:CloseStateTimer();
end

function HousePlant:OnCureFinished()
	UiNotify.OnNotify(UiNotify.emNOTIFY_PLANT_CURE_FINISHED);
end

function HousePlant:CloseStateTimer()
	if self.nStateTimerId then
		Timer:Close(self.nStateTimerId);
		self.nStateTimerId = nil;
	end
end

function HousePlant:OnCheckPlayerCanCure(tbSick)
	if not next(tbSick) then
		self.tbOldSickFriend = {};
		self:ClearHelpCureRedPoint();
		return;
	end

	local bNeedRefresh = false;
	for dwPlayerId in pairs(tbSick) do
		if not self.tbOldSickFriend or not self.tbOldSickFriend[dwPlayerId] then
			bNeedRefresh = true;
			break;
		end
	end

	self.tbOldSickFriend = tbSick;

	if not bNeedRefresh then
		return;
	end

	self:SetHelpCureRedPoint();
end

function HousePlant:AutoPlantCure(nMapId, nX, nY)
	Ui:CloseWindow("PlantHelpCurePanel");
	Ui:CloseWindow("SocialPanel");
	Ui:CloseWindow("PlantCurePanel");

	AutoPath:GotoAndCall(nMapId, nX, nY, function ()
		local tbLand = self:GetLand();
		if not tbLand or tbLand.nState == HousePlant.STATE_NULL then
			return;
		end
		Ui:OpenWindow("PlantCurePanel");
	end);
end

function HousePlant:ClearHelpCureRedPoint()
	Ui:ClearRedPointNotify("PlantHelpCure");
	Ui:ClearRedPointNotify("PlantHelpCure_Land");
end

function HousePlant:SetHelpCureRedPoint()
	Ui:SetRedPointNotify("PlantHelpCure");
	Ui:SetRedPointNotify("PlantHelpCure_Land");
end