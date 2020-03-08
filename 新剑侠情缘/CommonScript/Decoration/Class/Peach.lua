local tbPeachRes = Decoration:GetClass("Peach");

function tbPeachRes:OnCreateClientRep(tbRepInfo, pRep)
	self.nRepresentState = nil;
	self.nRepId = tbRepInfo.nRepId;
	self:UpdateRepState();
end

function tbPeachRes:UpdateRepState()
	if not self.nRepId then
		return;
	end

	local pRep = Ui.Effect.GetObjRepresent(self.nRepId);
	if not pRep then
		return;
	end

	local tbPeach = House.tbPeach;
	local tbPeachData = tbPeach:GetPeachData() or {nWater = 0};
	local nState = tbPeach:GetHousePeachState(tbPeachData.nWater, tbPeachData.nWaterDay);
	if self.nRepresentState == nState then
		return;
	end

	if tbPeach.PEACH_STATE_RES[self.nRepresentState] then
		pRep:RemoveEffectRes(tbPeach.PEACH_STATE_RES[self.nRepresentState]);
	end

	pRep:AddEffectRes(tbPeach.PEACH_STATE_RES[nState]);
	self.nRepresentState = nState;
end

function tbPeachRes:OnRepObjSimpleTap(nId, nRepId, tbRepInfo)
	self.nRepId = nRepId;
	Ui:OpenWindow("PeachPanel");
end

function tbPeachRes:OnLeaveHouse()
	self.nRepId = nil;
	self.nRepresentState = nil;
end