
Guide.tbNotifyGuide = {}

local tbNotifyGuide = Guide.tbNotifyGuide;


tbNotifyGuide.tbSpecialCheck =
{
	Kin = function (self)
		if me.dwKinId > 0 then
			self:StartNotifyGuide("KinBuildUpgrade");
		end
	end;
	House = function (self)
		if House.bHasHouse then
			self:StartNotifyGuide("BtnHome");
		end
	end;
	PartnerCardTab = function (self)
		if PartnerCard:IsOpen() then
			self:StartNotifyGuide("PartnerCardTab");
		end
	end;
}

-- 提示引导
function tbNotifyGuide:LoadNotifyGuide()
	self.tbSetting = LoadTabFile("Setting/Guide/NotifyGuide.tab", "sddssds", "GuideName", {"GuideName", "SaveId", "StartLevel", "TimeFrame", "Fuben", "DelLevel", "DelTimeFrame"});
	self.tbLevelCheck = {}
	self.tbFubenCheck = {};
	local tbSaveKey = {}
	for szGuide, tbInfo in pairs(self.tbSetting) do
		if not tbSaveKey[tbInfo.SaveId] then
			tbSaveKey[tbInfo.SaveId] = true;
			tbInfo.nKeyId = math.ceil(tbInfo.SaveId / 31)
			tbInfo.nBitIdx = (tbInfo.SaveId - 1) % 31 + 1
			if tbInfo.StartLevel and tbInfo.StartLevel > 0 then
				self.tbLevelCheck[tbInfo.StartLevel] = self.tbLevelCheck[tbInfo.StartLevel] or {}
				table.insert(self.tbLevelCheck[tbInfo.StartLevel], szGuide);
				tbInfo.bLevelStart = true;
			elseif tbInfo.Fuben and tbInfo.Fuben ~= "" then
				local tbParam = Lib:SplitStr(tbInfo.Fuben, "_")
				if #tbParam == 2 then
					local nSectionId, nSubSectionId = tonumber(tbParam[1]), tonumber(tbParam[2])
					local nKey = 100 * nSectionId + nSubSectionId
					self.tbFubenCheck[nKey] = self.tbFubenCheck[nKey] or {};
					table.insert(self.tbFubenCheck[nKey], szGuide);
					tbInfo.nFubenStartKey = nKey;
				else
					Log("NotifyGuide Setting Error!!! Fuben is wrong! "..tostring(tbInfo.SaveId))
				end
			end
		else
			Log("NotifyGuide Guide Setting Error!!! SaveId is wrong! "..tostring(tbInfo.SaveId));
		end
	end

	UiNotify:RegistNotify(UiNotify.emNOTIFY_SYNC_KIN_DATA, self.tbSpecialCheck.Kin, self);
	UiNotify:RegistNotify(UiNotify.emNOTIFY_SYNC_HAS_HOUSE, self.tbSpecialCheck.House, self);
end
tbNotifyGuide:LoadNotifyGuide()

function tbNotifyGuide:IsFinishGuide(szGuide)
	local tbSetting = self.tbSetting[szGuide];
	if not tbSetting then
		print("Error!! unexist notify guide "..szGuide)
		return;
	end
	if tbSetting.DelLevel and tbSetting.DelLevel > 0 and me.nLevel >= tbSetting.DelLevel then
		return;
	end
	local nValue = me.GetUserValue(Guide.NOTIFY_GUIDE_SAVE, tbSetting.nKeyId)
	local nRet = KLib.GetBit(nValue, tbSetting.nBitIdx)
	return nRet;
end


function tbNotifyGuide:LoginCheck()
	local nSectionId, nSubSectionId = 1, 1;
	local nCurFubenKey = 100 * nSectionId + nSubSectionId;
	local nLevel = me.nLevel
	for szName, tbInfo in pairs(self.tbSetting) do
		if tbInfo.bLevelStart and tbInfo.StartLevel <= nLevel then
			self:StartNotifyGuide(szName);
		elseif tbInfo.nFubenStartKey and tbInfo.nFubenStartKey < nCurFubenKey then
			self:StartNotifyGuide(szName);
		end
	end

	for szName, fnCheck in pairs(self.tbSpecialCheck) do
		fnCheck(self);
	end
end

function tbNotifyGuide:CheckStartGuide(nLevel)
	if self.tbLevelCheck[nLevel] then
		for x, szName in pairs(self.tbLevelCheck[nLevel]) do
			self:StartNotifyGuide(szName)
		end
	end
end

function tbNotifyGuide:CheckStartFubenGuide(nSectionId, nSubSectionId)
	local nCurFubenKey = 100 * nSectionId + nSubSectionId;
	if self.tbFubenCheck[nCurFubenKey] then
		for x, szName in pairs(self.tbFubenCheck[nCurFubenKey]) do
			self:StartNotifyGuide(szName)
		end
	end
end

function tbNotifyGuide:CheckTimeframe(szName)
	local tbSetting = self.tbSetting[szName];
	if not tbSetting then
		print("Error!! unexist notify guide "..szName)
		return;
	end
	if tbSetting.TimeFrame ~= "" and GetTimeFrameState(tbSetting.TimeFrame) ~= 1 then
		return;
	end
	if tbSetting.DelTimeFrame ~= "" and GetTimeFrameState(tbSetting.DelTimeFrame) == 1 then
		return;
	end
	return true
end

function tbNotifyGuide:StartNotifyGuide(szName)
	if self:IsFinishGuide(szName) ~= 0 then
		return;
	end
	if not self:CheckTimeframe(szName) then
		return;
	end
	Ui:SetRedPointNotify("NG_"..szName)
end

function tbNotifyGuide:ClearNotifyGuide(szName, bForce)
	if szName and Ui:GetRedPointState("NG_"..szName) then
		Ui:ClearRedPointNotify("NG_"..szName)
		RemoteServer.FinishNotifyGuide(szName)
	elseif bForce then
		if self:IsFinishGuide(szName) == 0 then
			RemoteServer.FinishNotifyGuide(szName)
		end
	end
end

