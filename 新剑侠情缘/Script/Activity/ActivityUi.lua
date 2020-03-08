Activity.tbActivityData = Activity.tbActivityData or {};

function Activity:OnSyncActivityInfo(tbData)
	self.tbActivityData = self.tbActivityData or {};

	if Recharge:IsOnActvityDay() then
		local nEndTime = Lib:GetLocalWeekEndTime(GetTime() - 3600 * 4) + 3600 * 4;
		self.tbActivityData["RechargeCardActNormal"] = {szKeyName = "RechargeCardActNormal", szType = "RechargeCardActNormal", nEndTime = nEndTime };
	end

	for _, tbInfo in pairs(tbData) do
		self.tbActivityData[tbInfo.szKeyName] = tbInfo;
		Activity:OnSynActTypeCallBack( tbInfo )
	end

	self:CheckRedPoint();
end

Activity.tbSynActTypeCallBack = {
	["ShopAct"] = function (tbActData)
		Shop.nNewsShopActStartTime = Shop.nNewsShopActStartTime or 0
		if tbActData.nStartTime > Shop.nNewsShopActStartTime then
			Shop.nNewsShopActStartTime = tbActData.nStartTime
			Shop:CheckRedPoint()
		end
	end;
	["BattleActItemBox"] = function ( ... )
		Battle.bShowItemBoxInBackCamp = true
	end
}
Activity.tbEndActClientCallBack = {
	["ShopAct"] = function ( tbActData )
		Shop.nNewstActWareUpdateTime = nil;--清掉该标志让开界面时重新请求检查
	end;
	["BattleActItemBox"] = function ( ... )
		Battle.bShowItemBoxInBackCamp = nil;
	end
};

function Activity:OnSynActTypeCallBack( tbActData )
	local fnCallback = self.tbSynActTypeCallBack[tbActData.szType]
	if fnCallback then
		fnCallback(tbActData)
	end
end

function Activity:ClientEndActivey( szKey )
	local tbData = self.tbActivityData[szKey]
	if not tbData then
		return
	end
	local fnCallback = self.tbEndActClientCallBack[tbData.szType]
	if fnCallback then
		fnCallback(tbData)
	end
	self.tbActivityData[szKey] = nil;
	return true
end

function Activity:OnSyncActivityCustomInfo( szActKeyName, tbCustomInfo )
	local tbInfo = self.tbActivityData[szActKeyName];
	if tbInfo then
		tbInfo.tbCustomInfo = tbCustomInfo
	end
	self:CheckRedPoint();
	if szActKeyName == "ShangShengDian" then
		UiNotify.OnNotify(UiNotify.emNOTIFY_REFRESH_SHANGSHENGDIAN_DATA,tbCustomInfo)
	end
end

function Activity:CloseNewInfomation(szKeyName)
	if not self.tbActivityData then
		return;
	end
	if not self:ClientEndActivey(szKeyName) then
		return
	end

	self:CheckRedPoint();
end

function Activity:ClearData()
	if self.tbActivityData then
		for szKey,tbData in pairs(self.tbActivityData) do
			self:ClientEndActivey( szKey )	
		end
	end
	self.tbActivityData = {}
	Recharge:OnCardActEnd()
end

function Activity:CheckRedPoint()
	self:UpdateActivityData();
	local bShowRedPoint = false;
	for szActKeyName, tbInfo in pairs(self.tbActivityData or {}) do
		local tbSetting = self:GetActUiSetting(szActKeyName)
		if tbSetting and tbSetting.szTitle and (not tbSetting.nShowLevel or tbSetting.nShowLevel <= me.nLevel) then
			if not self:CheckRedPointShowed(szActKeyName) then
				bShowRedPoint = true;
			end
		end
	end

	if bShowRedPoint then
		Ui:SetRedPointNotify("NI_NormalActiveUi");
	else
		Ui:ClearRedPointNotify("NI_NormalActiveUi");
	end

	Activity:CheckRedPointShowAnn2()
end

function Activity:SetRedPointShow(szKeyName)
	local nToday = Lib:GetLocalDay();
	local tbRedPointInfo = Client:GetUserInfo("ActivityUiRedPoint");
	if tbRedPointInfo[szKeyName] and tbRedPointInfo[szKeyName] == nToday then
		return;
	end

	tbRedPointInfo[szKeyName] = nToday;

	local tbInfoToRemove = {};
	for szKey, nDay in pairs(tbRedPointInfo) do
		if nDay ~= nToday then
			tbInfoToRemove[szKey] = true;
		end
	end

	for szKey in pairs(tbInfoToRemove) do
		tbRedPointInfo[szKey] = nil;
	end
	Client:SaveUserInfo();
end

function Activity:CheckRedPointShowAnn2()
	Ui:ClearRedPointNotify("AnniversaryQAAct")
	Ui:ClearRedPointNotify("NewYearLoginAct")
	if not Activity:__IsActInProcessByKeyName("ZhouNianQing2") then
		return
	end

	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_DATA, "UpdateTopButton")

	-- if Activity:__IsActInProcessByType("AnniversaryQAAct") then
	-- 	if not Activity:CheckRedPointShowed("AnniversaryQAAct") then
	-- 		Ui:SetRedPointNotify("AnniversaryQAAct")
	-- 	end
	-- end
	-- if Activity:__IsActInProcessByType("NewYearLoginAct") then
	-- 	if not Activity:CheckRedPointShowed("NewYearLoginAct") then
	-- 		Ui:SetRedPointNotify("NewYearLoginAct")
	-- 	end
	-- end
end

function Activity:CheckRedPointShowed(szKeyName)
	if not me.IsUserValueValid() then
		return true
	end
	local tbSetting = self:GetActUiSetting(szKeyName)
	if tbSetting and tbSetting.fnCustomCheckRP then
		local tbInfo = self.tbActivityData[szKeyName]
		if not tbInfo then
			return true
		end
		return not tbSetting.fnCustomCheckRP(tbInfo)
	end

	local nToday = Lib:GetLocalDay();
	local tbRedPointInfo = Client:GetUserInfo("ActivityUiRedPoint");
	if tbRedPointInfo[szKeyName] and tbRedPointInfo[szKeyName] == nToday then
		return true;
	end
	return false;
end

function Activity:UpdateActivityData()
	local nTimeNow = GetTime();
	local tbToRemove = {};
	for szKeyName, tbInfo in pairs(self.tbActivityData or {}) do
		if tbInfo.nEndTime <= nTimeNow then
			tbToRemove[szKeyName] = true;
		end
	end
	for szKeyName in pairs(tbToRemove) do
		self:ClientEndActivey(szKeyName)
	end
end

function Activity:GetActList(tbShowAct)
	self:UpdateActivityData();
	for szActKeyName, tbInfo in pairs(self.tbActivityData or {}) do
		local tbSetting = self:GetActUiSetting(szActKeyName);
		if tbSetting and tbSetting.szTitle and (not tbSetting.nShowLevel or tbSetting.nShowLevel <= me.nLevel) then
			table.insert(tbShowAct, "___Activity___" .. szActKeyName);
		end
	end
end

function Activity:GetActUiSetting(szActKeyName)
	local tbInfo = self.tbActivityData[szActKeyName];
	if not tbInfo then
		return {};
	end
	return tbInfo.tbUiData or self:GetUiSetting(tbInfo.szType, szActKeyName), tbInfo
end

function Activity:GetNormalNewInfomationSetting(szKey)
	local szRealKey = string.match(szKey, "__SendActNewInfomation__(.+)$");
	if not szRealKey then
		return;
	end

	local tbSetting = self:GetNormalNewInfomationUiSetting(szRealKey) or {};
	return tbSetting.tbData or {};
end

function Activity:GetActKeyName(szKey)
	local szActKeyName = string.match(szKey, "^___Activity___(.+)$");
	return szActKeyName;
end

Activity.tbActNewInfomationSetting = Activity.tbActNewInfomationSetting or {};
function Activity:GetNormalNewInfomationUiSetting(szKey)
	if not Activity.tbActNewInfomationSetting[szKey] then
		Activity.tbActNewInfomationSetting[szKey] = {};
	end

	return Activity.tbActNewInfomationSetting[szKey];
end

Activity.tbUiSetting = Activity.tbUiSetting or {};
function Activity:GetUiSetting(szType, szKeyName)
	if not Activity.tbUiSetting[szType] and not Activity.tbUiSetting[szKeyName] then
		Activity.tbUiSetting[szType] = {};
	end
	return Activity.tbUiSetting[szType][szKeyName] or Activity.tbUiSetting[szType];
end

function Activity:__IsActInProcessByType(szType)
	self:UpdateActivityData()
	for _, tbInfo in pairs(self.tbActivityData) do
		if tbInfo.szType == szType then
			return true
		end
	end
end

function Activity:OpenActUi(szKeyName)
	local szUiKey = "___Activity___" .. szKeyName
	Ui:OpenWindow("NewInformationPanel", szUiKey)
end

function Activity:__GetActTimeInfo(szKeyName)
	local tbData = self.tbActivityData[szKeyName]
	if not tbData then
		return
	end

	return  tbData.nStartTime, tbData.nEndTime
end

function Activity:__IsActInProcessByKeyName(szKeyName)
	local nStartTime, nEndTime = self:__GetActTimeInfo(szKeyName)
	if not nStartTime then
		return
	end
	local nNow = GetTime()
	if nNow >= nStartTime and nNow < nEndTime then
		return true
	end
end

function Activity:GetCurRuningActShowDesc(  )
	if Activity:__IsActInProcessByKeyName("IdiomsAct") then
		return "有缘一线牵进行中"
	elseif Activity:__IsActInProcessByKeyName("DefendAct") then
		return "缘定长相守进行中"
	elseif Activity:__IsActInProcessByKeyName("WeekendQuestion") then
		return "乱点鸳鸯谱进行中"
	end
end