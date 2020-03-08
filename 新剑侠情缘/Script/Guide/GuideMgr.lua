
Guide.ZHAOLIYING_NAME = "颖宝宝";

local function MakeFubenParam(nFubenLevel, nSectionId, nSubSectionId)
	return nSectionId * 1000 + nSubSectionId * 10 + nFubenLevel;
end

function Guide:Init()
	self.tbRunningGuide = nil;	-- 引导中的
	self.nCurClickKey = self.nCurClickKey or 0;
	self.tbStartCheck = {};
	self.tbWaitingGuide = {}
	self.tbWaitingId = {};

	self.tbGuideSetting = LoadTabFile("Setting/Guide/GuideSetting.tab", "ddddss", "GuideId", {"GuideId", "SaveId", "CheckAchievement", "FightLimit", "StartCheck", "Param"});

	local tbSaveKey = {}
	for _, tbInfo in pairs(self.tbGuideSetting) do
		if not tbSaveKey[tbInfo.SaveId] then
			tbInfo.nKeyId = math.ceil(tbInfo.SaveId / 31)
			tbInfo.nBitIdx = (tbInfo.SaveId - 1) % 31 + 1
			if tbInfo.StartCheck and tbInfo.StartCheck ~= "" then
				self.tbStartCheck[tbInfo.StartCheck] = self.tbStartCheck[tbInfo.StartCheck] or {}

				if tbInfo.StartCheck == "CheckFuben" then
					local tbParam = Lib:SplitStr(tbInfo.Param, "_")
					local nFubenLevel, nSectionId, nSubSectionId = tonumber(tbParam[1]), tonumber(tbParam[2]), tonumber(tbParam[3])
					if nFubenLevel and nSectionId and nSubSectionId then
						tbInfo.Param = MakeFubenParam(nFubenLevel, nSectionId, nSubSectionId)
					else
						Log("Guide Setting Error!!! CheckFuben Error Param! ", tbInfo.Param)
						tbInfo.Param = 0;
					end
				elseif tbInfo.StartCheck == "EnterMap" then
					local tbParam = Lib:SplitStr(tbInfo.Param, "|")
					tbInfo.Param = tbParam[1];
					tbInfo.tbExParam = {unpack(tbParam,2)}
				else
					tbInfo.Param = tonumber(tbInfo.Param)
				end

				self.tbStartCheck[tbInfo.StartCheck][tbInfo.Param] = self.tbStartCheck[tbInfo.StartCheck][tbInfo.Param] or {}
				table.insert(self.tbStartCheck[tbInfo.StartCheck][tbInfo.Param], tbInfo);
			end
		else
			Log("Guide Setting Error!!! SaveId is wrong! "..tostring(tbInfo.SaveId))
		end
	end

	local tbSteps = LoadTabFile("Setting/Guide/GuideStep.tab", "ddsssssssd", nil, {"GuideId", "LoginStart", "ActionType", "Param", "PointerOffset", "DescType", "DescInfo", "FinishCheck", "CheckParam", "SaveFinish"});
	for _, tbInfo in ipairs(tbSteps) do
		if self.tbGuideSetting[tbInfo.GuideId] then
			self.tbGuideSetting[tbInfo.GuideId].tbSteps = self.tbGuideSetting[tbInfo.GuideId].tbSteps or {}
			table.insert(self.tbGuideSetting[tbInfo.GuideId].tbSteps, tbInfo);
		else
			Log("Guide Setting unexist!!! "..tostring(tbInfo.GuideId))
		end
	end
end

Guide:Init()

function Guide:IsFinishGuide(nGuideId)
	local tbSetting = self.tbGuideSetting[nGuideId];
	if not tbSetting then
		return;
	end
	local nValue = me.GetUserValue(Guide.SAVE_GROUP, tbSetting.nKeyId)
	local nRet = KLib.GetBit(nValue, tbSetting.nBitIdx)
	return nRet;
end

function Guide:StartGuideById(nGuideId, bLoginStart, bForce, bFirst)
	local tbSetting = self.tbGuideSetting[nGuideId];
	if not tbSetting then
		Log("Can not Start unexist Guide "..nGuideId);
		return;
	end
	return self:StartGuide(tbSetting, bLoginStart, bForce, bFirst)
end

-- 开启引导，Force = true 强制开启
function Guide:StartGuide(tbSetting, bLoginStart, bForce, bFirst)
--[[
	if not bForce and Client:IsCloseIOSEntry() then
		if tbSetting.GuideId == 13 or tbSetting.GuideId == 7 then 
			return
		end
	end

	if not bForce and self:IsFinishGuide(tbSetting.GuideId) ~= 0 then
		return
	end

	if me.nMapTemplateId <= 0 then
		return;
	end

	if (tbSetting.FightLimit ~= -1) and (tbSetting.FightLimit ~= me.nFightMode) and not bForce then
		self:AddWaittingGuide(tbSetting)
		return;
	end

	if not self.tbRunningGuide or bFirst then
		local tbGuide = Lib:NewClass(self.tbBase)
		tbGuide:Init(tbSetting.GuideId, tbSetting.tbSteps)
		if tbGuide:Start(bLoginStart) then
			self.tbRunningGuide = tbGuide;
			return true;
		else
			self:EndGuide()
		end
	else
		self:AddWaittingGuide(tbSetting)
	end
]]

	return
end

function Guide:NextStep()
	if not self.tbRunningGuide then
		return;
	end
	if not self.tbRunningGuide:NextStep() then
		self:EndGuide()
		return;
	end
end

function Guide:EndGuide(bNoAutoNext)
	Ui:CloseWindow("Guide");
	self:CloseCheckClickWnd();
	if self.tbRunningGuide then
		local nGuideId = self.tbRunningGuide.nGuideId
		self.tbRunningGuide = nil;
		if bNoAutoNext or self:OnGuideFinish(nGuideId) then
			return;
		end
	end
	if bNoAutoNext then
		return;
	end
	self:StartWaitingGuide()
end

function Guide:StartWaitingGuide()
	local tbWaiting = self.tbWaitingGuide;
	Guide:ClearWaittingGuide()
	for _, tbSetting in ipairs(tbWaiting) do
		self:StartGuide(tbSetting, true);
	end
end

function Guide:AddWaittingGuide(tbSetting)
	if not self.tbWaitingId[tbSetting.GuideId] then
		self.tbWaitingId[tbSetting.GuideId] = true;
		table.insert(self.tbWaitingGuide, tbSetting);
	end
end

function Guide:ClearWaittingGuide()
	self.tbWaitingGuide = {}
	self.tbWaitingId = {};
end

function Guide:StartCheckDeal(szStartCheck, nParam, bForce)
	local bRet = false;
	if self.tbStartCheck[szStartCheck] and self.tbStartCheck[szStartCheck][nParam] then
		for _, tbSetting in ipairs(self.tbStartCheck[szStartCheck][nParam]) do
			self:StartGuide(tbSetting, false, bForce);
			bRet = true;
		end
	end

	return bRet;
end

function Guide:SetCheckClickWnd(pPanel, szWnd)
	self.nCurClickKey = self.nCurClickKey + 1
	self:CloseCheckClickWnd()
	pPanel:AddButtonGuideClick(szWnd, self.nCurClickKey)
	self.pCheckClickPanel = pPanel

	return self.nCurClickKey
end

function Guide:CloseCheckClickWnd()
	if self.pCheckClickPanel then
		self.pCheckClickPanel:RemoveButtonGuideClick()
		self.pCheckClickPanel = nil
	end
end

function Guide.OnCheckClickWndDestroy(nClickKey)
	if nClickKey == Guide.nCurClickKey then
		Guide.pCheckClickPanel = nil
		Log("OnCheckClickWndDestroy", nClickKey);
	end
end

-------------------------------------- Check Guide Start ----------------------------------------
function Guide:OnLevelUp(nLevel)
	self.tbNotifyGuide:CheckStartGuide(nLevel)
	return self:StartCheckDeal("CheckLevel", nLevel)
end

function Guide:OnLogin()

	self:EndGuide()

	local nLevel = me.nLevel;

	self.tbNotifyGuide:LoginCheck()

	local nNormalFubenId = MakeFubenParam(PersonalFuben.PERSONAL_LEVEL_NORMAL, 1, 1);
	local nEliteFubenId = MakeFubenParam(PersonalFuben.PERSONAL_LEVEL_ELITE, 1, 1)

	local tbCheckInLogin =
	{
		CheckLevel = function (nParam) return nParam <= nLevel end,
		CheckGuide = function (nParam) return Guide:IsFinishGuide(nParam) == 1 end,
		CheckFuben = function (nParam) return nParam < (nParam % 2 == 0 and nEliteFubenId or nNormalFubenId); end,
		CheckTask = function (nParam) return false; end,
	}
	for nGuideId, tbInfo in pairs(self.tbGuideSetting) do
		if tbCheckInLogin[tbInfo.StartCheck] and tbCheckInLogin[tbInfo.StartCheck](tbInfo.Param) and self:IsFinishGuide(nGuideId) == 0 then
			print("Start Guide In Login", nGuideId);
			self:StartGuide(tbInfo, true);
		end
	end
end

function Guide:OnFinishFuben(nLevel, nSectionId, nSubSectionId)
	local nFubenId = MakeFubenParam(nLevel, nSectionId, nSubSectionId)
	return self:StartCheckDeal("CheckFuben", nFubenId)
end

function Guide:OnEnterMap(nMapTemplateId)
	if Map:GetClassDesc(nMapTemplateId) == "city" then
		self:StartWaitingGuide()
	end
end

function Guide:OnGuideFinish(nGuideId)
	return self:StartCheckDeal("CheckGuide", nGuideId)
end

function Guide:OnTaskCheck(nTaskId)
	return self:StartCheckDeal("CheckTask", nTaskId, true);
end

function Guide:OnChangeFightMode(nFightMode)
	self:StartWaitingGuide()
end


-------------------------------------- Check Step Finish -----------------------------------------
function Guide:OnOpenUi(szUi)
	if self.tbRunningGuide and self.tbRunningGuide:CheckOpenUi(szUi) then
		self:NextStep()
	end
end

function Guide:OnGuideClick(tbWndCom, nClickKey)
	if self.tbRunningGuide and self.tbRunningGuide:CheckClickWnd(tbWndCom, nClickKey) then
		self:NextStep()
	else
		Fuben:OnGuideClick(nClickKey);
	end
end

function Guide:OnCheckClickScreen()
	if self.tbRunningGuide and self.tbRunningGuide:CheckClickScreen() then
		self:NextStep()
	end
end

function Guide:OnUiAnimationFinish(szUi, szAniName)
	if self.tbRunningGuide and self.tbRunningGuide:CheckUiAnimation(szUi, szAniName) then
		self:NextStep()
	end
end

function Guide:OnTaskFinishCheck(nTaskId)
	if self.tbRunningGuide and self.tbRunningGuide:CheckTaskFinish(nTaskId) then
		self:NextStep()
	end
end

local tbExceptMap =
{
	[1] = 1,
	[2] = 1,
}
function Guide:OnEnterMap(nTemplateID, nMapID)
	if tbExceptMap[nTemplateID] then
		return;
	end
	if self.tbStartCheck.EnterMap then
		for szType, tbList in pairs(self.tbStartCheck.EnterMap) do
			for _, tbInfo in ipairs(tbList) do
				Guide[szType](Guide, nTemplateID, nMapID, tbInfo)
			end
		end
	end
end

function Guide:Clear()
	if self.tbRunningGuide then
		Guide:ClearWaittingGuide()
		Guide:EndGuide(true);
	end
end


function Guide:RegisterEvent()
	UiNotify:RegistNotify(UiNotify.emNOTIFY_WND_OPENED, self.OnOpenUi, self);
	--UiNotify:RegistNotify(UiNotify.emNOTIFY_SERVER_CONNECT_LOST, self.OnConnectLost, self);
	UiNotify:RegistNotify(UiNotify.emNOTIFY_ANIMATION_FINISH, self.OnUiAnimationFinish, self);
	UiNotify:RegistNotify(UiNotify.emNOTIFY_TASK_FINISH, self.OnTaskFinishCheck, self);
	UiNotify:RegistNotify(UiNotify.emNOTIFY_MAP_LOADED, self.OnEnterMap, self);
end

-- 特殊引导
local tbSkillGuide =
{
	-- Level	Animation
	{	1, 		"GuideBtnSkill1"},
	{	4, 		"GuideBtnSkill2"},
	{	10, 		"GuideBtnSkill3"},
	{	30, 		"GuideBtnSkill4"},
}
function Guide:SkillGuide(nTemplateID, nMapID, tbSetting)
	if self:IsFinishGuide(tbSetting.GuideId) ~= 0 then
		return;
	end
	local nIdx = tonumber(tbSetting.tbExParam[1]);
	if (not nIdx) or (not tbSkillGuide[nIdx]) then
		return;
	end
	local nLevelLimit, szAnimation = unpack(tbSkillGuide[nIdx]);
	if me.nLevel < nLevelLimit then
		return;
	end
	if me.nFightMode == 1 and Ui:WindowVisible("HomeScreenBattle") then
		Ui("HomeScreenBattle").pPanel:PlayUiAnimation(szAnimation, false, false, {})
		RemoteServer.FinishGuide(tbSetting.GuideId)
	end
end


