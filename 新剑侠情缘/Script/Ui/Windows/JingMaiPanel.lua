Require("CommonScript/JingMai/JingMai.lua");

local tbUi = Ui:CreateClass("JingMaiPanel");
local tbXueWeiUi = Ui:CreateClass("XueWei");

-- 连续冲穴时间间隔
tbUi.nAutoXueWeiLevelupTime = 0.5;

tbUi.nOpenXueWeiTime = 3;

tbUi.tbShowTips =
{
	{150000, "九死一生"},
	{300000, "难如登天"},
	{500000, "殊为不易"},
	{700000, "逆水行舟"},
	{900000, "十拿九稳"},
	{1000000, "易如反掌"},
}

tbUi.tbLeftPosInfo = {{-14, 0}, {45, 1}, {25,1}, {25, 1}};
tbUi.tbRightPosInfo = {{45, 0}, {-48, 1}, {-24, 1}, {-24, 1}};

if version_vn then
	tbUi.tbLeftPosInfo = {{-14, 0}, {45, 1}, {25,1}, {25, 1}};
	tbUi.tbRightPosInfo = {{70, 0}, {-48, 1}, {-24, 1}, {-24, 1}};
end

function tbUi:LoadSetting()
	self.tbSetting = {};

	local function GetNumber(szInfo)
		local a, b = string.match(szInfo, "([^|]+)|([^|]+)");
		a = tonumber(a);
		b = tonumber(b);
		assert(a and b);
		return {a, b};
	end
	local tbFile = LoadTabFile("Setting/JingMai/JingMaiUiSetting.tab", "ddsds", nil, {"JingMaiId", "XueWeiId", "MainPos", "NameLeft", "NextXueWeiId"});
	for _, tbRow in pairs(tbFile) do
		self.tbSetting[tbRow.JingMaiId] = self.tbSetting[tbRow.JingMaiId] or {};
		local tbJingMai = self.tbSetting[tbRow.JingMaiId];

		tbJingMai[tbRow.XueWeiId] = {
			tbMainPos = GetNumber(tbRow.MainPos);
			bNameLeft = tbRow.NameLeft == 1;
			tbNextXueWei = {};
		};

		assert(JingMai.tbXueWeiSetting[tbRow.XueWeiId] and JingMai.tbXueWeiSetting[tbRow.XueWeiId].nJingMaiId == tbRow.JingMaiId);
		local nNextXueWei = tonumber(tbRow.NextXueWeiId == "" and "0" or tbRow.NextXueWeiId);
		if nNextXueWei then
			if nNextXueWei > 0 then
				tbJingMai[tbRow.XueWeiId].tbNextXueWei = {nNextXueWei};
			end
		else
			local tbInfo = Lib:SplitStr(tbRow.NextXueWeiId, "|");
			for i = 1, #tbInfo do
				tbInfo[i] = tonumber(tbInfo[i]);
				assert(tbInfo[i] ~= tbRow.XueWeiId);
				assert(JingMai.tbXueWeiSetting[tbInfo[i]] and JingMai.tbXueWeiSetting[tbInfo[i]].nJingMaiId == tbRow.JingMaiId);
				assert(tbInfo[i]);
			end

			tbJingMai[tbRow.XueWeiId].tbNextXueWei = tbInfo;
		end
	end
end
tbUi:LoadSetting();

function tbUi:OnOpen()
	if JingMai:CheckShowRedPoint() then
		Client:SetFlag("JingMai", Lib:GetLocalDay());
	end

	if not JingMai:CheckOpen(me) then
		me.MsgBox("大侠尚未领悟经脉运行的法则，完成[FFFE0D]经脉绝学[-]系列任务，方可领悟！",
		{
			{"确定"},
		});
		return 0;
	end

	self.tbAllJingMai = {};
	for nJingMaiId, tbJingMai in pairs(JingMai.tbJingMaiSetting) do
		if JingMai:CheckJingMaiOpen(nJingMaiId) then
			table.insert(self.tbAllJingMai, nJingMaiId);
		end
	end
	table.sort(self.tbAllJingMai, function (a, b) return a < b; end);

	for _, nJingMaiId in ipairs(self.tbAllJingMai) do
		local nNextOpenJingMaiId = JingMai:GetNextOpenJingMai(nJingMaiId);
		if nNextOpenJingMaiId and not JingMai:CheckJingMaiOpen(nNextOpenJingMaiId) then
			table.insert(self.tbAllJingMai, nNextOpenJingMaiId);
			break;
		end
	end

	if #self.tbAllJingMai <= 0 then
		me.CenterMsg("暂无开放的经脉");
		return 0;
	end
	self.pPanel:SetActive("BtnReset", JingMai.bOpenResetXueWei and true or false)
	self.pPanel:SetActive("BtnResetMeridian", JingMai.bOpenResetJingMai and true or false)
	self.pPanel:Toggle_SetChecked("Toggle1", true);
	self.pPanel:Toggle_SetChecked("Toggle2", true);

	self.nCurJingMaiId = self.tbAllJingMai[1];

	local function fnSetItem(itemObj, index)
		local nJingMaiId = self.tbAllJingMai[index];

		itemObj.nJingMaiId = nJingMaiId;
		itemObj.pPanel:Button_SetSprite("MeridianIcon", string.format("Meridian%s_%s", nJingMaiId, self.nCurJingMaiId == nJingMaiId and 2 or 1));
		itemObj.pPanel:Button_SetCheck("Main", self.nCurJingMaiId == nJingMaiId);
		itemObj.pPanel:Toggle_SetChecked("Main", self.nCurJingMaiId == nJingMaiId);

		itemObj.pPanel:Label_SetText("Txt1", JingMai.tbJingMaiSetting[nJingMaiId].szName);
		itemObj.pPanel:Label_SetText("Txt2", JingMai.tbJingMaiSetting[nJingMaiId].szName);
		itemObj.pPanel:SetActive("Txt3", not JingMai:CheckJingMaiOpen(nJingMaiId));

		local bShowRedPoint = JingMai:CheckJingMaiTabRedPoint(me, nJingMaiId);
		itemObj.pPanel:SetActive("RedPoint", bShowRedPoint);

		itemObj.pPanel.OnTouchEvent = function ()
			local bRet, szMsg = JingMai:CheckJingMaiOpen(nJingMaiId);
			if not bRet then
				me.CenterMsg(szMsg);
				return;
			end

			if Client:GetFlag("JingMai_" .. nJingMaiId) ~= 1 then
				Client:SetFlag("JingMai_" .. nJingMaiId, 1);
			end
			self:UpdateJingMai(nJingMaiId);
			JingMai:OnClickJingMaiPanelTab(nJingMaiId)
			self:UpdateTabRedPoing(nJingMaiId)
		end
	end

	self.ScrollViewMeridian:Update(#self.tbAllJingMai, fnSetItem);
end

function tbUi:UpdateTabRedPoing(nJingMaiId)
	if not nJingMaiId then
		return
	end
	local itemObj = self.ScrollViewMeridian["Grid"]["Item" ..(nJingMaiId - 1)]
	if itemObj then
		local bShowRedPoint = JingMai:CheckJingMaiTabRedPoint(me, nJingMaiId);
		itemObj.pPanel:SetActive("RedPoint", bShowRedPoint);
	end
end

function tbUi:OnOpenEnd(nJingMaiId)
	self:UpdateJingMai(nJingMaiId);
end

function tbUi:UpdateJingMai(nJingMaiId, nDstXueWeiId, bSkipStop, nLevelJingMaiId)
	self:CloseActivationTxtTimer()
	if not bSkipStop then
		self:StopOpenXueWei();
	end

	self.nCurJingMaiId = nJingMaiId or self.nCurJingMaiId;

	local nIdx = 1;
	for i = 1, 1000 do
		local itemObj = self.ScrollViewMeridian.Grid["Item" .. (i - 1)];
		if not itemObj or not itemObj.nJingMaiId then
			break;
		end

		itemObj.pPanel:Button_SetSprite("MeridianIcon", string.format("Meridian%s_%s", itemObj.nJingMaiId, self.nCurJingMaiId == itemObj.nJingMaiId and 2 or 1));
		itemObj.pPanel:Toggle_SetChecked("Main", self.nCurJingMaiId == itemObj.nJingMaiId)
	end

	self.nXueWeiId = nil;
	self.pPanel:Toggle_SetChecked("AcupointSpotSpecial", false);
	self.pPanel:Button_SetCheck("BtnOpen1", false);
	self.pPanel:ChangeRotate("BtnOpen1", 0);
	self.pPanel:Button_SetCheck("BtnOpen2", false);
	self.pPanel:ChangeRotate("BtnOpen2", 0);

	if nJingMaiId then
		self.pPanel:Toggle_SetChecked("Toggle1", false);
	end
	self.pPanel:SetActive("JingMaiInfoPanel", true);
	self.pPanel:SetActive("XueWeiInfoPanel", false);

	self.AcupointSpot.pPanel:SetActive("Main", false);

	local nZhenQi = me.GetMoney("ZhenQi");
	self.pPanel:Label_SetText("TrueNum", string.format("真气值：%s", nZhenQi));

	local tbSetting = self.tbSetting[self.nCurJingMaiId];
	self.tbXueWeiIdxInfo = {};
	for nXueWeiId, tbInfo in pairs(tbSetting) do
		self.tbXueWeiIdxInfo[nXueWeiId] = Lib:CountTB(self.tbXueWeiIdxInfo);
	end

	for i = Lib:CountTB(self.tbXueWeiIdxInfo), 1000 do
		if self["AcupointSpot" .. i] then
			self["AcupointSpot" .. i].pPanel:SetActive("Main", false);
		else
			break;
		end
	end

	for nXueWeiId in pairs(tbSetting) do
		self:UpdateXueWei(nXueWeiId);
	end

	self.pPanel:Label_SetText("VeinName", JingMai.tbJingMaiSetting[self.nCurJingMaiId].szName);
	self:UpdateAttribPanel();

	if nDstXueWeiId or nLevelJingMaiId then
		self.nJingMaiLevelUpId = nLevelJingMaiId
		self:OnClickXueWei(nDstXueWeiId, bSkipStop, nLevelJingMaiId);
	end

	self:UpdateJingMaiLevel(self.nCurJingMaiId)
end

function tbUi:RefreshJingMaiLevelRedPoint(nJingMaiId)
	if nJingMaiId then
		local bCanLevelup = JingMai:CheckJingMaiLevelUp(me, nJingMaiId, false, true, true)
		local bCanActivation = JingMai:CheckJingMaiLevelCanActivation(me, nJingMaiId)
		self.pPanel:SetActive("AcupointUpSpecial_Real", bCanLevelup or bCanActivation);
	end
end

function tbUi:UpdateJingMaiLevel(nCurJingMaiId)
	if not nCurJingMaiId then
		return
	end
	self.pPanel:SetActive("ZhouTianShengJi", false)
	local szName = JingMai:GetJingMaiLevelName(nCurJingMaiId)
	self.pPanel:Label_SetText("AcupointNameSpecial", szName)
	local nLevelIndex, nRequestLevelTime = JingMai:GetJingMaiLevelData(me, nCurJingMaiId)
	nLevelIndex = nLevelIndex or 0
	local bCanActivation = JingMai:CheckJingMaiLevelCanActivation(me, nCurJingMaiId)
	local bRunning = JingMai:IsJingMaiLevelRunning(me, nCurJingMaiId)
	self.pPanel:SetActive("ZhouTianYunZhuan", bRunning or bCanActivation)
	self.pPanel:SetActive("AcupointLevelState", bRunning or bCanActivation)
	local szState = ""
	if bRunning then
		szState = ""
	elseif bCanActivation then
		szState = "可激活"
	end
	self.pPanel:Label_SetText("AcupointLevelState", string.format(szState))
	self.pPanel:SetActive("AcupointLevelSpecial", nLevelIndex > 0)
	local nMaxLevel = JingMai:GetMaxJingMaiLevel(nCurJingMaiId)
	local szColor = (nLevelIndex < nMaxLevel and nLevelIndex ~= 0) and "fff474" or "6cff00"
	self.pPanel:Label_SetText("AcupointLevelSpecial", string.format("第[%s]%s[-]重", szColor, nLevelIndex))
	self:RefreshJingMaiLevelRedPoint(nCurJingMaiId)
	local tbJMSetting = JingMai.tbJingMaiSetting[nCurJingMaiId] or {}
	local nNormalIcon  = tbJMSetting.nLevelNormalIcon
	local nLightIcon = tbJMSetting.nLevelIcon
	local nIcon = nLevelIndex > 0 and nLightIcon or nNormalIcon
    local szIconAtlas, szIconSprite = Item:GetIcon(nIcon);
	self.pPanel:Sprite_SetSprite("AcupointSpotSpecial", szIconSprite, szIconAtlas)
end

function tbUi:OnClickJingMaiLevel(nJingMaiId)
	self:OnClickXueWei(nil, nil, nJingMaiId)
end


function tbUi:UpdateXueWei(nXueWeiId)
	local nIdx = self.tbXueWeiIdxInfo[nXueWeiId];
	if not nIdx then
		return;
	end

	local szTips = "";
	local nTimes = JingMai:GetLevelupLastTimes(me);
	if nTimes <= 0 then
		szTips = string.format("今日还可成功冲穴： %s/%s（次日[FFFE0D]4点[-]重置）", math.max(nTimes, 0), JingMai.nMaxLevelupTimes);
	else
		szTips = string.format("今日还可成功冲穴： %s/%s", math.max(nTimes, 0), JingMai.nMaxLevelupTimes);
	end
	self.pPanel:Label_SetText("DanTianTip", szTips);

	local tbXueWei = JingMai.tbXueWeiSetting[nXueWeiId];
	local tbInfo = self.tbSetting[tbXueWei.nJingMaiId][nXueWeiId];

	local tbXueWeiObj = self["AcupointSpot" .. nIdx];
	if not tbXueWeiObj then
		self.pPanel:CreateWnd("AcupointSpot", "AcupointSpot", tostring(nIdx));
		tbXueWeiObj = self["AcupointSpot" .. nIdx];
	end

	tbXueWeiObj.pPanel:SetActive("Main", true);

	tbXueWeiObj.pPanel:SetActive("JingMai_ChongJiTeXiao" .. nIdx, false);
	tbXueWeiObj.pPanel:SetActive("JingMai_DaTongTieXiao" .. nIdx, false);
	tbXueWeiObj.pPanel:SetActive("JingMai_DaTongChiXuTieXiao" .. nIdx, false);

	tbXueWeiObj.pPanel.OnTouchEvent = function ()
		self.nJingMaiLevelUpId = nil
		self:OnClickXueWei(nXueWeiId);
	end

	local bShowName = self.pPanel:Toggle_GetChecked("Toggle2");
	tbXueWeiObj.pPanel:SetActive("AcupointName" .. nIdx, bShowName);

	local tbPosInfo = tbInfo.bNameLeft and self.tbLeftPosInfo or self.tbRightPosInfo;
	tbXueWeiObj.pPanel:ChangePosition("Main", tbInfo.tbMainPos[1], tbInfo.tbMainPos[2]);
	tbXueWeiObj.pPanel:ChangePosition("AcupointName" .. nIdx, tbPosInfo[1][1], tbPosInfo[1][2]);
	tbXueWeiObj.pPanel:ChangePosition("AcupointUp" .. nIdx, tbPosInfo[3][1], tbPosInfo[3][2]);

	tbXueWeiObj.pPanel:Label_SetText("AcupointName" .. nIdx, tbXueWei.szName);

	local nXueWeiLevel = JingMai:GetXueWeiLevel(me, nXueWeiId);

	if nXueWeiLevel > 0 then
		local szLevelInfo = string.format("[%s]%s[-]", nXueWeiLevel < tbXueWei.nMaxLevel and "fff474" or "6cff00", nXueWeiLevel);
		tbXueWeiObj.pPanel:Label_SetText("AcupointLevel" .. nIdx, szLevelInfo)
	end
	tbXueWeiObj.pPanel:SetActive("AcupointLevel" .. nIdx, nXueWeiLevel > 0);

	if tbXueWei.nType == 1 then
		tbXueWeiObj.pPanel:Button_SetSprite("Main", nXueWeiLevel > 0 and "Acupoint1_2" or "Acupoint1_1");
	else
		tbXueWeiObj.pPanel:Button_SetSprite("Main", nXueWeiLevel > 0 and "Acupoint2_2" or "Acupoint2_1");
	end

	local bCanLevelup = JingMai:CheckXueWeiLevelup(me, nXueWeiId, true);
	tbXueWeiObj.pPanel:SetActive("AcupointUp" .. nIdx, bCanLevelup);

	local tbPos = bCanLevelup and tbPosInfo[2] or tbPosInfo[4];
	tbXueWeiObj.pPanel:ChangePosition("AcupointLevel" .. nIdx, tbPos[1], tbPos[2]);

	tbXueWeiObj.pPanel:Toggle_SetChecked("Main", false);

	tbXueWeiObj.pPanel:SetActive("AcupointLine" .. nIdx, false);
	for i = 1, 100 do
		if tbXueWeiObj.pPanel:CheckHasChildren("AcupointLine" .. i) then
			tbXueWeiObj.pPanel:SetActive("AcupointLine" .. i, false);
		else
			break;
		end
	end

	for i, nNextXueWeiId in pairs(tbInfo.tbNextXueWei) do
		if not tbXueWeiObj.pPanel:CheckHasChildren("AcupointLine" .. i) then
			tbXueWeiObj.pPanel:CreateWnd("AcupointLine" .. nIdx, "AcupointLine", tostring(i));
		end

		local tbNextPos = self.tbSetting[tbXueWei.nJingMaiId][nNextXueWeiId];
		tbXueWeiObj.pPanel:ChangePosition("AcupointLine" .. i, -1 * (tbInfo.tbMainPos[1] - tbNextPos.tbMainPos[1]) / 2, -1 * (tbInfo.tbMainPos[2] - tbNextPos.tbMainPos[2]) / 2);
		local nSize = math.sqrt((tbNextPos.tbMainPos[1] - tbInfo.tbMainPos[1]) * (tbNextPos.tbMainPos[1] - tbInfo.tbMainPos[1]) +
						(tbNextPos.tbMainPos[2] - tbInfo.tbMainPos[2]) * (tbNextPos.tbMainPos[2] - tbInfo.tbMainPos[2]));

		tbXueWeiObj.pPanel:Widget_SetSize("AcupointLine" .. i, 14, nSize);
		tbXueWeiObj.pPanel:Sprite_SetSprite("AcupointLine" .. i, nXueWeiLevel > 0 and "AcupointLine2" or "AcupointLine1");
		local nX = tbInfo.tbMainPos[2] > tbNextPos.tbMainPos[2] and tbInfo.tbMainPos[1] - tbNextPos.tbMainPos[1] or tbNextPos.tbMainPos[1] - tbInfo.tbMainPos[1];
		local nAngle = math.acos((nX) / nSize) * 180 / math.pi;

		tbXueWeiObj.pPanel:ChangeRotate("AcupointLine" .. i, nAngle - 90);
		tbXueWeiObj.pPanel:SetActive("AcupointLine" .. i, true);
	end
end

function tbUi:UpdateAttribPanel()
	local bNotAllAttrib = not self.pPanel:Toggle_GetChecked("Toggle1");
	local tbShowJingMai = JingMai.tbJingMaiSetting
	local szTitle = "全部经脉效果";
	if bNotAllAttrib then
		szTitle = string.format("%s效果", JingMai.tbJingMaiSetting[self.nCurJingMaiId].szName);
		tbShowJingMai = {[self.nCurJingMaiId] = true}
	end
	self.pPanel:Label_SetText("RenTitle", szTitle);

	local tbLearnInfo, bHasNoPartner = JingMai:GetLearnedXueWeiInfo(me);
	local tbAddAttribInfo = JingMai:GetXueWeiAddInfo(tbLearnInfo, bNotAllAttrib and self.nCurJingMaiId or nil);
	tbAddAttribInfo = JingMai:CombineAddInfo(tbAddAttribInfo, JingMai:GetJingMaiLevelAttribInfo(me, tbShowJingMai))

	local function fnOnClickSkill(nSkillId, nSkillLevel, nMaxSkillLevel)
		local tbSubInfo = FightSkill:GetSkillShowTipInfo(nSkillId, nSkillLevel, nMaxSkillLevel);
		Ui:OpenWindow("SkillShow", tbSubInfo);
	end

	local nSLine = #tbAddAttribInfo.tbSkill > 0 and 5 or 0;

	if #tbAddAttribInfo.tbSkill > 0 then
		-- 这里有个目测是锚点和渲染的BUG，直接设置，会导致位置不正确，所以延迟2帧在做处理
		Timer:Register(2, function ()
			self.pPanel:SetActive("PlayerAddSkill", true);
			self.pPanel:SetActive("SkillBgRange2", #tbAddAttribInfo.tbSkill >= 5)
			self.pPanel:SetActive("BtnOpen2", self.bShowBtnOpen2);
		end)
	else
		self.pPanel:SetActive("PlayerAddSkill", false);
		Timer:Register(2, function ()
			self.pPanel:SetActive("BtnOpen2", self.bShowBtnOpen2);
		end)
	end

	self.pPanel:SetActive("PartnerAddSkill", #tbAddAttribInfo.tbPartnerSkill > 0);
	self.pPanel:SetActive("SkillBgRange1", #tbAddAttribInfo.tbPartnerSkill >= 5)

	self.pPanel:Label_SetText("Anchor1", #tbAddAttribInfo.tbPartnerSkill > 0 and string.rep("\n", 5) or "");
	self.ScrollViewSkill1:Update(#tbAddAttribInfo.tbPartnerSkill, function (itemObj, index)
		local nSkillId, nSkillLevel, nMaxSkillLevel = unpack(tbAddAttribInfo.tbPartnerSkill[index]);
		itemObj.pPanel:Label_SetText("Level", nSkillLevel);

		local tbValue = FightSkill:GetSkillShowInfo(nSkillId);
		itemObj.pPanel:Sprite_SetSprite("Icon", tbValue.szIconSprite, tbValue.szIconAtlas);

		itemObj.pPanel.OnTouchEvent = function ()
			fnOnClickSkill(nSkillId, nSkillLevel, nMaxSkillLevel);
		end
	end)

	nSLine = nSLine + (#tbAddAttribInfo.tbSkill > 0 and 5 or 0);
	self.pPanel:Label_SetText("Anchor2", #tbAddAttribInfo.tbSkill > 0 and string.rep("\n", 5) or "");
	self.ScrollViewSkill2:Update(#tbAddAttribInfo.tbSkill, function (itemObj, index)
		local nSkillId, nSkillLevel, nMaxSkillLevel = unpack(tbAddAttribInfo.tbSkill[index]);
		itemObj.pPanel:Label_SetText("Level", nSkillLevel);

		local tbValue = FightSkill:GetSkillShowInfo(nSkillId);
		itemObj.pPanel:Sprite_SetSprite("Icon", tbValue.szIconSprite, tbValue.szIconAtlas);

		itemObj.pPanel.OnTouchEvent = function ()
			fnOnClickSkill(nSkillId, nSkillLevel, nMaxSkillLevel);
		end
	end)
	local szPartnerAttrib, nPartnerLine = JingMai:GetAttribDesc(JingMai:GetAttribInfo(tbAddAttribInfo.tbExtPartnerAttrib));
	if bHasNoPartner then
		szPartnerAttrib = "无同伴上阵经脉属性不生效";
		nPartnerLine = 0
	elseif szPartnerAttrib == "" then
		szPartnerAttrib = "尚未打通任何穴位！";
		nPartnerLine = 0
	end
	self.pPanel:ChangeRotate("BtnOpen1", 180);
	if nPartnerLine > 3 and not self.pPanel:Button_GetCheck("BtnOpen1") then
		szPartnerAttrib = string.match(szPartnerAttrib, "^([^\n]+\n[^\n]+\n[^\n]+)\n");
		self.pPanel:ChangeRotate("BtnOpen1", 0);
		nSLine = nSLine + 3;
	else
		nSLine = nSLine + nPartnerLine;
	end

	self.pPanel:Label_SetText("PartnerAddAttrib", szPartnerAttrib or "");
	self.pPanel:SetActive("BtnOpen1", nPartnerLine > 3);

	local szPlayerAttrib, nPlayerLine = JingMai:GetAttribDesc(JingMai:GetAttribInfo(tbAddAttribInfo.tbExtAttrib));
	if bHasNoPartner then
		szPlayerAttrib = "无同伴上阵经脉属性不生效";
		nPlayerLine = 0
	elseif szPlayerAttrib == "" then
		szPlayerAttrib = "尚未打通任何穴位！";
		nPlayerLine = 0
	end

	self.pPanel:ChangeRotate("BtnOpen2", 180);
	if nPlayerLine > 3 and not self.pPanel:Button_GetCheck("BtnOpen2") then
		szPlayerAttrib = string.match(szPlayerAttrib, "^([^\n]+\n[^\n]+\n[^\n]+)\n");
		self.pPanel:ChangeRotate("BtnOpen2", 0);
		nSLine = nSLine + 3;
	else
		nSLine = nSLine + nPlayerLine;
	end

	self.pPanel:Label_SetText("PlayerAddAttrib", szPlayerAttrib or "");
	self.pPanel:SetActive("BtnOpen2", false);
	self.bShowBtnOpen2 = nPlayerLine > 3;
	self.pPanel:ResizeScrollViewBound("ScrollView1", 60 - nSLine * 20, 220);
	self.pPanel:DragScrollViewGoTop("ScrollView1");
end

function tbUi:OnClickXueWei(nXueWeiId, bSkipStop, nJingMaiId)
	local bRunning = (nJingMaiId and JingMai:IsJingMaiLevelRunning(me, nJingMaiId)) and true or false
	self.pPanel:SetActive("ScrollBar", bRunning)
	self.nJingMaiLevelUpId = nJingMaiId
	self:CloseActivationTxtTimer()
	self:RefreshJingMaiLevelRedPoint(self.nJingMaiLevelUpId)
	if not bSkipStop then
		self:StopOpenXueWei();
	end

	self.pPanel:Toggle_SetChecked("AcupointSpotSpecial", self.nJingMaiLevelUpId and true or false);
	local nIdx = self.tbXueWeiIdxInfo[nXueWeiId];
	if nIdx then
		self["AcupointSpot" .. nIdx].pPanel:Toggle_SetChecked("Main", true);
	end

	self.nXueWeiId = nXueWeiId or self.nXueWeiId;
	self.pPanel:SetActive("JingMaiInfoPanel", false);
	self.pPanel:SetActive("XueWeiInfoPanel", true);

	local tbXueWei = JingMai.tbXueWeiSetting[self.nXueWeiId];
	local szName = ""
	if nJingMaiId then
		szName = JingMai:GetJingMaiLevelName(nJingMaiId)
	else
		szName = tbXueWei and tbXueWei.szName
	end

	self.pPanel:Label_SetText("AcupointTitle", szName or "");

	local nXueWeiLevel = 0
	local nMaxLevel = 0
	if nJingMaiId then
		nXueWeiLevel = JingMai:GetJingMaiLevelData(me, nJingMaiId) or 0
		nMaxLevel = JingMai:GetMaxJingMaiLevel(nJingMaiId)
	else
		nXueWeiLevel = JingMai:GetXueWeiLevel(me, nXueWeiId);
		nMaxLevel = tbXueWei.nMaxLevel
	end

	self.pPanel:Label_SetText("LeftAcupointLevel", string.format("%s/%s重", nXueWeiLevel, nMaxLevel));

	self.pPanel:SetActive("Skill1", false);
	self.pPanel:SetActive("Skill2", false);

	self.pPanel:SetActive("Skill3", false);
	self.pPanel:SetActive("Skill4", false);
	local tbParam = {}
	local nSLine = 0;
	if nXueWeiLevel <= 0 then
		self.pPanel:Label_SetText("Content3", nJingMaiId and "\n周天尚未打通！" or "\n穴位尚未打通！");
		self.pPanel:Label_SetText("Content1", "");
		self.pPanel:Label_SetText("Content2", "");
		self.pPanel:SetActive("Skill1", false);
		self.pPanel:SetActive("Skill2", false);
	else
		local tbAttrib = {}
		if nJingMaiId then
			tbAttrib = JingMai:GetXueWeiAddInfo(nil, nJingMaiId, nXueWeiLevel);
		else
			tbAttrib = JingMai:GetXueWeiAddInfo({[nXueWeiId] = nXueWeiLevel});
		end
		local nMaxLine = 1;
		local szDsc, nLine = JingMai:GetXueWeiAttribDesc(JingMai:GetAttribInfo(tbAttrib.tbExtPartnerAttrib));
		nMaxLine = math.max(nLine, nMaxLine);

		self.pPanel:Label_SetText("Content1", nLine > 0 and "[FFFE0D]同伴：[-]\n" .. szDsc or "[FFFE0D]同伴：[-]");

		szDsc, nLine = JingMai:GetXueWeiAttribDesc(JingMai:GetAttribInfo(tbAttrib.tbExtAttrib));
		nMaxLine = math.max(nLine, nMaxLine);

		self.pPanel:Label_SetText("Content2", nLine > 0 and "[FFFE0D]护主：[-]\n" .. szDsc or "[FFFE0D]护主：[-]");

		local bHasSkill = false;
		if tbAttrib.tbPartnerSkill and tbAttrib.tbPartnerSkill[1] then
			local nSkillId, nSkillLevel, nMaxSkillLevel = unpack(tbAttrib.tbPartnerSkill[1]);
			self.pPanel:Label_SetText("SkillLevel1", nSkillLevel);

			local tbValue = FightSkill:GetSkillShowInfo(nSkillId);
			self.pPanel:Sprite_SetSprite("SkillIcon1", tbValue.szIconSprite, tbValue.szIconAtlas);

			self.tbShowSkillInfo = self.tbShowSkillInfo or {};
			self.tbShowSkillInfo[1] = {nSkillId, nSkillLevel, nMaxSkillLevel};
			self.pPanel:SetActive("Skill1", true);
			bHasSkill = true;
		end

		if tbAttrib.tbSkill and tbAttrib.tbSkill[1] then
			local nSkillId, nSkillLevel, nMaxSkillLevel = unpack(tbAttrib.tbSkill[1]);
			self.pPanel:Label_SetText("SkillLevel2", nSkillLevel);

			local tbValue = FightSkill:GetSkillShowInfo(nSkillId);
			self.pPanel:Sprite_SetSprite("SkillIcon2", tbValue.szIconSprite, tbValue.szIconAtlas);

			self.tbShowSkillInfo = self.tbShowSkillInfo or {};
			self.tbShowSkillInfo[2] = {nSkillId, nSkillLevel, nMaxSkillLevel};
			self.pPanel:SetActive("Skill2", true);
			bHasSkill = true;
		end

		nMaxLine = bHasSkill and nMaxLine or nMaxLine - 1;
		nSLine = nSLine + nMaxLine;
		self.pPanel:Label_SetText("Content3", string.rep("\n", nMaxLine));
	end

	local nNextXueweiLevel = nXueWeiLevel + 1;
	local tbAttrib = {tbSkill = {}; tbPartnerSkill = {}; tbExtAttrib = {}; tbExtPartnerAttrib = {};};
	if nXueWeiLevel < nMaxLevel then
		if nJingMaiId then
			tbAttrib = JingMai:GetXueWeiAddInfo(nil, nJingMaiId, nNextXueweiLevel);
		else
			tbAttrib = JingMai:GetXueWeiAddInfo({[nXueWeiId] = nNextXueweiLevel});
		end
	end

	local nMaxLine = 1;
	local szDsc, nLine = "", 0;
	if nXueWeiLevel < nMaxLevel then
		szDsc, nLine = JingMai:GetXueWeiAttribDesc(JingMai:GetAttribInfo(tbAttrib.tbExtPartnerAttrib));
	end
	nMaxLine = math.max(nLine, nMaxLine);

	self.pPanel:Label_SetText("Content4", nLine > 0 and "[FFFE0D]同伴：[-]\n" .. szDsc or "[FFFE0D]同伴：[-]");

	if nXueWeiLevel < nMaxLevel then
		szDsc, nLine = JingMai:GetXueWeiAttribDesc(JingMai:GetAttribInfo(tbAttrib.tbExtAttrib));
	end

	nMaxLine = math.max(nLine, nMaxLine);

	self.pPanel:Label_SetText("Content5", nLine > 0 and "[FFFE0D]护主：[-]\n" .. szDsc or "[FFFE0D]护主：[-]");

	local bHasSkill = false;
	if tbAttrib.tbPartnerSkill and tbAttrib.tbPartnerSkill[1] then
		local nSkillId, _, nMaxSkillLevel = unpack(tbAttrib.tbPartnerSkill[1]);
		self.pPanel:Label_SetText("SkillLevel3", nNextXueweiLevel);

		local tbValue = FightSkill:GetSkillShowInfo(nSkillId);
		self.pPanel:Sprite_SetSprite("SkillIcon3", tbValue.szIconSprite, tbValue.szIconAtlas);

		self.tbShowSkillInfo = self.tbShowSkillInfo or {};
		self.tbShowSkillInfo[3] = {nSkillId, nNextXueweiLevel, nMaxSkillLevel};
		self.pPanel:SetActive("Skill3", true);
		Timer:Register(2, function ()
			self.pPanel:SetActive("Skill3", false);
			self.pPanel:SetActive("Skill3", true);
		end)
		bHasSkill = true;
	end

	if tbAttrib.tbSkill and tbAttrib.tbSkill[1] then
		local nSkillId, _, nMaxSkillLevel = unpack(tbAttrib.tbSkill[1]);
		self.pPanel:Label_SetText("SkillLevel4", nNextXueweiLevel);

		local tbValue = FightSkill:GetSkillShowInfo(nSkillId);
		self.pPanel:Sprite_SetSprite("SkillIcon4", tbValue.szIconSprite, tbValue.szIconAtlas);

		self.tbShowSkillInfo = self.tbShowSkillInfo or {};
		self.tbShowSkillInfo[4] = {nSkillId, nNextXueweiLevel, nMaxSkillLevel};
		self.pPanel:SetActive("Skill4", true);
		Timer:Register(2, function ()
			self.pPanel:SetActive("Skill4", false);
			self.pPanel:SetActive("Skill4", true);
		end)
		bHasSkill = true;
	end

	nMaxLine = bHasSkill and nMaxLine or nMaxLine - 1;
	if nXueWeiLevel >= nMaxLevel then
		self.pPanel:Label_SetText("Content6", "\n已达上限");
	else
		nSLine = nSLine + nMaxLine;
		self.pPanel:Label_SetText("Content6", string.rep("\n", nMaxLine));
	end

	self.pPanel:ResizeScrollViewBound("ScrollView2", -120 - nSLine * 20, 150);
	self.pPanel:DragScrollViewGoTop("ScrollView2");
	self:UpdateXueWeiLevelupNeedInfo(tbXueWei, nXueWeiLevel, nJingMaiId);
	self:UpdateJingMaiLevel(nJingMaiId)
end

function tbUi:StartActivationTxtTimer()
	self:CloseActivationTxtTimer()
	if self.nJingMaiLevelUpRemainTime and self.nJingMaiLevelUpRemainTime > 0 then
		self.nActivationTxtTimer = Timer:Register(Env.GAME_FPS,
			function (self)
				if self.nJingMaiLevelUpRemainTime > 0 then
					self.nJingMaiLevelUpRemainTime = self.nJingMaiLevelUpRemainTime - 1
					self.pPanel:Label_SetText("ActivationTxt", string.format(JingMai.szJingMaiLevelTimeDes, Lib:TimeDesc(self.nJingMaiLevelUpRemainTime)));
					return true
				end
				self.nActivationTxtTimer = nil
				if self.nCurJingMaiId then
					self:OnClickXueWei(nil, nil, self.nCurJingMaiId)
					self:UpdateTabRedPoing(self.nCurJingMaiId)
				end
				return false
			end, self);
	end
end

function tbUi:CloseActivationTxtTimer()
	if self.nActivationTxtTimer then
		Timer:Close(self.nActivationTxtTimer)
		self.nActivationTxtTimer = nil
	end
end

function tbUi:UpdateXueWeiLevelupNeedInfo(tbXueWei, nXueWeiLevel, nJingMaiId)
	local nMaxLevel = 0
	if nJingMaiId then
		nMaxLevel = JingMai:GetMaxJingMaiLevel(nJingMaiId)
	else
		nMaxLevel = tbXueWei.nMaxLevel
	end
	if nXueWeiLevel >= nMaxLevel then
		self.pPanel:SetActive("BtnUp", false);
		self.pPanel:SetActive("BtnContinuityUp", false);

		self.pPanel:Label_SetText("Difficulty", "");
		self.pPanel:Label_SetText("CurrentAcupoint", "");
		self.pPanel:Label_SetText("RoleLevel", "                           已达上限");
		self.pPanel:Label_SetText("ZhenQiCost", "");
		self.pPanel:Label_SetText("CoinCost", "");
		self.pPanel:SetActive("ItemCost", false);
		self.pPanel:SetActive("Need", false);
		self.pPanel:SetActive("TrueIcon", false);
		self.pPanel:SetActive("MoneyIcon", false);
		self.pPanel:SetActive("BtnActivation", false);
		self.pPanel:SetActive("ActivationTxt", false);
		return;
	end

	self.pPanel:SetActive("TrueIcon", true);
	self.pPanel:SetActive("MoneyIcon", true);
	local bShowUp = true
	local bShowBtnActivation = false
	local szActivationTxt
	local nNowTime = GetTime()
	self.pPanel:Label_SetText("ContinuityTitle", nXueWeiLevel > 0 and "冲穴条件" or "打通条件");
	self.pPanel:Button_SetText("BtnUp", nXueWeiLevel > 0 and "冲穴" or (nJingMaiId and "打通周天" or "打通穴位"));

	local bShowContinuity = (not nJingMaiId and nXueWeiLevel > 0) and true or false
	self.pPanel:SetActive("BtnContinuityUp", bShowContinuity);

	local nRate = JingMai.MAX_RATE;
	local tbCost = {}
	local szTips = "";
	local szRequireXueWeiInfo = "前置穴位：无";
	local szLevel = ""
	if nJingMaiId then
		local tbXueWeiLearnedInfo, _, tbJingMaiLevelInfo = JingMai:GetLearnedXueWeiInfo(me, nil, true);
		local tbLevelAttrib = JingMai:GetXueWeiLevelAttrib(tbXueWeiLearnedInfo)
		local nLevelIndex, nRequestLevelTime = JingMai:GetJingMaiLevelData(me, nJingMaiId)
		local nNextLevelIndex = nLevelIndex + 1
		tbCost = JingMai:GetJingMaiLevelCost(nJingMaiId, nNextLevelIndex)
		local nRequireXueWeiLevel = JingMai:GetJingMaiRequireLevel(nJingMaiId, nNextLevelIndex) or 0
		local szJingMaiName = JingMai.tbJingMaiSetting[nJingMaiId] and JingMai.tbJingMaiSetting[nJingMaiId].szName
		local bGotLevel = tbLevelAttrib[nJingMaiId] and tbLevelAttrib[nJingMaiId][nNextLevelIndex]
		local szColor = bGotLevel and "FFFFFF" or "FF0000";
		szRequireXueWeiInfo = string.format("%s前%d个穴位达到[%s]%s[-]重", szJingMaiName or "", JingMai.nJingMaiPreNum, szColor, nRequireXueWeiLevel)
		szLevel = "无等级要求"
		if nRequestLevelTime > 0 then
			bShowUp = false
			self.nJingMaiLevelUpRemainTime = nRequestLevelTime + JingMai.nJingMaiLevelUpTime - nNowTime
			if self.nJingMaiLevelUpRemainTime > 0 then
				szActivationTxt = string.format(JingMai.szJingMaiLevelTimeDes, Lib:TimeDesc(self.nJingMaiLevelUpRemainTime))
			end
			self:StartActivationTxtTimer()
			if self.nJingMaiLevelUpRemainTime <= 0 then
				bShowBtnActivation = true
			end
		end
	else
		tbCost = tbXueWei.tbCost;
		if nXueWeiLevel > 0 then
			--tbCost, nRate = JingMai:GetTimeFrameDiscountInfo(tbXueWei.nLevelupType, nXueWeiLevel)
			nRate = (JingMai.tbXueWeiLevelupInfo[tbXueWei.nLevelupType][nXueWeiLevel] or {}).nRate;
			tbCost = (JingMai.tbXueWeiLevelupInfo[tbXueWei.nLevelupType][nXueWeiLevel] or {}).tbCost;
		end

		for _, tbInfo in pairs(self.tbShowTips) do
			szTips = tbInfo[2];
			if nRate <= tbInfo[1] then
				break;
			end
		end
		self.szDifficulty = szTips;

		for i, tbInfo in ipairs(tbXueWei.tbRequireXueWei) do
			local nRequire_XueWei, nRequire_Level = unpack(tbInfo);
			local nRLevel = JingMai:GetXueWeiLevel(me, nRequire_XueWei);
			if i == 1 then
				szRequireXueWeiInfo = string.format("%s [%s]%s[-] 重", JingMai.tbXueWeiSetting[nRequire_XueWei].szName, nRLevel >= nRequire_Level and "FFFFFF" or "FF0000", nRequire_Level);
			else
				szRequireXueWeiInfo = string.format("%s, %s [%s]%s[-] 重", szRequireXueWeiInfo, JingMai.tbXueWeiSetting[nRequire_XueWei].szName, nRLevel >= nRequire_Level and "FFFFFF" or "FF0000", nRequire_Level);
			end
			szRequireXueWeiInfo = string.format("前置穴位：%s", szRequireXueWeiInfo)
		end
		local szColor = me.nLevel >= (tbXueWei.tbRequireLevel[nXueWeiLevel + 1] or 0) and "FFFFFF" or "FF0000";
	    szLevel = string.format("角色等级：[%s]%s[-] 级", szColor, tbXueWei.tbRequireLevel[nXueWeiLevel + 1])
	end
	self.pPanel:Label_SetText("Difficulty", szTips);
	self.pPanel:Label_SetText("CurrentAcupoint", szRequireXueWeiInfo);

	self.pPanel:Label_SetText("RoleLevel", szLevel);
	self.pPanel:SetActive("BtnUp", bShowUp);
	self.pPanel:SetActive("ActivationTxt", szActivationTxt and true or false);
	self.pPanel:Label_SetText("ActivationTxt", szActivationTxt or "");
	self.pPanel:SetActive("BtnActivation", bShowBtnActivation);
	local nItemId, nItemNeedCount = nil;
	local nCoinCount = 0;
	local nZhenQi = 0;
	for _, tbInfo in pairs(tbCost or {}) do
		local nType = Player.AwardType[tbInfo[1]];
		if nType and nType == Player.award_type_item then
			nItemId = tbInfo[2];
			nItemNeedCount = tbInfo[3];
		elseif nType and nType == Player.award_type_money then
			if tbInfo[1] == "ZhenQi" then
				nZhenQi = tbInfo[2];
			elseif tbInfo[1] == "coin" or tbInfo[1] == "Coin" then
				nCoinCount = tbInfo[2];
			end
		end
	end

	self.pPanel:SetActive("ItemCost", nItemId and true or false);
	self.pPanel:SetActive("Need", nItemId and true or false);
	if nItemId then
		self.ItemCost:SetItemByTemplate(nItemId, 1, me.nFaction);
		local nHasCount = me.GetItemCountInBags(nItemId);

		self.ItemCost.pPanel:SetActive("LabelSuffix", true);
		self.ItemCost.pPanel:Label_SetText("LabelSuffix", string.format("[%s]%s/%s[-]", nHasCount >= nItemNeedCount and "FFFFFF" or "FF0000", nHasCount, nItemNeedCount));
		self.ItemCost.fnClick = self.ItemCost.DefaultClick;
	end

	self.pPanel:Label_SetText("ZhenQiCost", string.format("消耗真气：[%s]%s[-]", me.GetMoney("ZhenQi") >= nZhenQi and "FFFFFF" or "FF0000", nZhenQi));
	self.pPanel:Label_SetText("CoinCost", string.format("消耗银两：[%s]%s[-]", me.GetMoney("Coin") >= nCoinCount and "FFFFFF" or "FF0000", nCoinCount));
end

function tbUi:_OnSyncXueWeiLevelup(nXueWeiId, bResult, nJingMaiId, bZhouTianLevelUp)
	self:OnSyncXueWeiLevelup(nXueWeiId, bResult, nJingMaiId, bZhouTianLevelUp);
end

function tbUi:OnSyncXueWeiLevelup(nXueWeiId, bResult, nJingMaiId, bZhouTianLevelUp)
	local bSkipStop = false;
	if nXueWeiId and nXueWeiId == self.nXueWeiId and not self.nAutoXueWeiLevelupTimerId and self.pPanel:IsActive("AutoXueWeiLevelupPanel") then
		self:DoAutoXueWeiLevelup(nXueWeiId);
		bSkipStop = true;
	end

	self:UpdateJingMai(self.nCurJingMaiId, self.nXueWeiId, bSkipStop, nJingMaiId);

	self.pPanel:SetActive("ZhouTianShengJi", bZhouTianLevelUp and true or false)
	self:UpdateTabRedPoing(nJingMaiId)
	local nIdx = self.tbXueWeiIdxInfo[nXueWeiId];
	if not nIdx then
		return;
	end


	local tbXueWeiObj = self["AcupointSpot" .. nIdx];
	local nLevel = JingMai:GetXueWeiLevel(me, nXueWeiId);
	if bResult then
		if nLevel > 1 then
			tbXueWeiObj.pPanel:SetActive("JingMai_ChongJiTeXiao" .. nIdx, true);
		else
			tbXueWeiObj.pPanel:SetActive("JingMai_DaTongTieXiao" .. nIdx, true);
		end
	end

	tbXueWeiObj.pPanel:SetActive("JingMai_DaTongChiXuTieXiao" .. nIdx, false);
	self.pPanel:SetActive("OpenXueWeiBar", false);
end

function tbUi:StopOpenXueWei()
	if self.nAutoXueWeiLevelupTimerId then
		Timer:Close(self.nAutoXueWeiLevelupTimerId);
		self.nAutoXueWeiLevelupTimerId = nil;
	end

	if self.nOpenXueWeiTimerId then
		Timer:Close(self.nOpenXueWeiTimerId);
		self.nOpenXueWeiTimerId = nil;
	end

	if self.nOpenXueWeiBarTimerId then
		Timer:Close(self.nOpenXueWeiBarTimerId);
		self.nOpenXueWeiBarTimerId = nil;
	end

	for _, nIdx in pairs(self.tbXueWeiIdxInfo or {}) do
		local tbXueWeiObj = self["AcupointSpot" .. nIdx];
		tbXueWeiObj.pPanel:SetActive("JingMai_DaTongChiXuTieXiao" .. nIdx, false);
		tbXueWeiObj.pPanel:SetActive("JingMai_ChongJiTeXiao" .. nIdx, false);
		tbXueWeiObj.pPanel:SetActive("JingMai_DaTongTieXiao" .. nIdx, false);
	end

	self.pPanel:SetActive("OpenXueWeiBar", false);
	self.pPanel:SetActive("NormalXueWeiLevelupPanel", true);
	self.pPanel:SetActive("AutoXueWeiLevelupPanel", false);
end

function tbUi:DoXueWeiLevelup(nXueWeiId, bConfirm)
	self:StopOpenXueWei();

	if nXueWeiId ~= self.nXueWeiId then
		return;
	end

	local nIdx = self.tbXueWeiIdxInfo[nXueWeiId or -1];
	if not nXueWeiId or not nIdx then
		return;
	end

	local bRet, szMsg = JingMai:CheckXueWeiLevelup(me, nXueWeiId);
	if not bRet then
		me.CenterMsg(szMsg);
		return;
	end

	local nLevel = JingMai:GetXueWeiLevel(me, nXueWeiId);
	if nLevel and nLevel <= 0 and not bConfirm then
		me.MsgBox(string.format("阁下正尝试打通穴位 [FFFE0D]%s[-]，打通难度为 [FFFE0D]%s[-]，确定尝试打通该穴位吗？", JingMai.tbXueWeiSetting[nXueWeiId].szName, self.szDifficulty),
			{{"确认", function ()
							if Ui:WindowVisible("JingMaiPanel") ~= 1 then
								return
							end
							self:DoXueWeiLevelup(nXueWeiId, true);
						end},
			{"取消"}});
		return;
	end

	local nLevel = JingMai:GetXueWeiLevel(me, nXueWeiId);
	if nLevel == 0 then
		local tbXueWeiObj = self["AcupointSpot" .. nIdx];
		tbXueWeiObj.pPanel:SetActive("JingMai_DaTongChiXuTieXiao" .. nIdx, true);

		self.nOpenXueWeiTimerId = Timer:Register(Env.GAME_FPS * self.nOpenXueWeiTime, function (nXueWeiId)
			RemoteServer.XueWeiLevelup(nXueWeiId, nLevel);
			self.nOpenXueWeiTimerId = nil;
		end, nXueWeiId);

		local nPassFrame = 0;
		self.pPanel:SetActive("OpenXueWeiBar", true);
		self.pPanel:Label_SetText("OpenXueWeiBarTxt", string.format("尝试打通穴位：%s", JingMai.tbXueWeiSetting[nXueWeiId].szName));
		self.nOpenXueWeiBarTimerId = Timer:Register(1, function ()
			nPassFrame = nPassFrame + 1;
			self.pPanel:Sprite_SetFillPercent("OpenXueWeiBar", math.min(nPassFrame / (self.nOpenXueWeiTime * Env.GAME_FPS), 1));
			return true;
		end)
	else
		RemoteServer.XueWeiLevelup(nXueWeiId, nLevel);
	end
end

function tbUi:DoAutoXueWeiLevelup(nXueWeiId)
	if nXueWeiId ~= self.nXueWeiId then
		return;
	end

	if self.nAutoXueWeiLevelupTimerId then
		Timer:Close(self.nAutoXueWeiLevelupTimerId);
		self.nAutoXueWeiLevelupTimerId = nil;
	end

	self.nAutoXueWeiLevelupTimerId = Timer:Register(Env.GAME_FPS * self.nAutoXueWeiLevelupTime, function ()
		self.nAutoXueWeiLevelupTimerId = nil;
		if Ui:WindowVisible("JingMaiPanel") ~= 1 then
			return;
		end

		local bRet, szMsg = JingMai:CheckXueWeiLevelup(me, nXueWeiId);
		if not bRet then
			me.CenterMsg(szMsg);
			self.pPanel:SetActive("NormalXueWeiLevelupPanel", true);
			self.pPanel:SetActive("AutoXueWeiLevelupPanel", false);
			return;
		end

		local nLevel = JingMai:GetXueWeiLevel(me, nXueWeiId);
		RemoteServer.XueWeiLevelup(nXueWeiId, nLevel);
	end)

	self.pPanel:SetActive("NormalXueWeiLevelupPanel", false);
	self.pPanel:SetActive("AutoXueWeiLevelupPanel", true);
end

function tbUi:OnRefresMoney()
	self:UpdateJingMai(self.nCurJingMaiId, self.nXueWeiId, true);
end

function tbUi:OnClose()
	self:StopOpenXueWei();
	self:CloseActivationTxtTimer()
	self.nJingMaiLevelUpId = nil
	UiNotify.OnNotify(UiNotify.emNOTIFY_JINGMAI_DATA_CHANGE)
	Partner:UpdateRedPoint()
end

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_SYNC_XUEWEI_LEVELUP,		self._OnSyncXueWeiLevelup },
		{ UiNotify.emNOTIFY_CHANGE_MONEY, 				self.OnRefresMoney },
	};

	return tbRegEvent;
end

tbUi.tbOnClick = tbUi.tbOnClick or {};
tbUi.tbOnClick.BtnClose = function (self)
	Ui:CloseWindow(self.UI_NAME);
end

tbUi.tbOnClick.BtnBack = function (self)
	self:UpdateJingMai();
end

tbUi.tbOnClick.BtnUp = function (self)
	if self.nJingMaiLevelUpId then
		local bRet, szMsg = JingMai:CheckJingMaiLevelUp(me, self.nJingMaiLevelUpId)
		if not bRet then
			me.CenterMsg(szMsg, true)
			return
		end
		RemoteServer.JingMaiReq("RequestJingMaiLevelUp", self.nJingMaiLevelUpId)
	else
		-- 冲穴
		self:DoXueWeiLevelup(self.nXueWeiId)
	end
end

tbUi.tbOnClick.BtnActivation = function (self)
	if not JingMai.tbJingMaiSetting[self.nJingMaiLevelUpId] then
		me.CenterMsg("未知经脉", true)
		return
	end
	local _, nRequestLevelTime = JingMai:GetJingMaiLevelData(me, self.nJingMaiLevelUpId)
	if not nRequestLevelTime or nRequestLevelTime <= 0 or GetTime() - nRequestLevelTime < JingMai.nJingMaiLevelUpTime then
		me.CenterMsg("未到激活时间", true)
		return
	end
	RemoteServer.JingMaiReq("TryDoJingMaiLevelUp", self.nJingMaiLevelUpId)
end

tbUi.tbOnClick.BtnContinuityUp = function (self)
	-- 连续冲穴
	local nXueWeiId = self.nXueWeiId;
	local szTips = string.format("连续冲穴会尝试将[FFFE0D]当前穴位[-]提升到最高境界，除非中途所需冲穴条件不足，阁下确定对穴位 [FFFE0D]%s[-] 进行连续冲穴吗？", JingMai.tbXueWeiSetting[self.nXueWeiId].szName);
	me.MsgBox(szTips,
	{{"确认", function ()
					if Ui:WindowVisible("JingMaiPanel") ~= 1 then
						return
					end
					self:DoAutoXueWeiLevelup(nXueWeiId);
				end},
	{"取消"}});
end

tbUi.tbOnClick.BtnReset = function (self)
	self:StopOpenXueWei();
	-- 重置穴位
	local bRet, szMsg, nLevel = JingMai:CheckCanResetXueWei(me, self.nXueWeiId);
	if not bRet then
		me.CenterMsg(szMsg);
		return;
	end

	local _, nZhenQiCount = JingMai:GetResetXueWeiAward({{self.nXueWeiId, nLevel}});

	local nXueWeiId = self.nXueWeiId;
	me.MsgBox(string.format("重置穴位将返还所有真气但[FFFE0D]不会返还[-]已消耗的道具和银两，阁下打算重置穴位[FFFE0D]%s[-]，并获得[FFFE0D]%s[-]真气返还吗？", JingMai.tbXueWeiSetting[self.nXueWeiId].szName, nZhenQiCount), {{"确认", function () RemoteServer.XueWeiReset(nXueWeiId); end}, {"取消"}})
end

tbUi.tbOnClick.BtnResetMeridian = function (self)
	self:StopOpenXueWei();
	-- 重置经脉
	local bRet, szMsg, _, tbLearnInfo = JingMai:CheckCanResetJingMai(me, self.nCurJingMaiId);
	if not bRet then
		me.CenterMsg(szMsg);
		return;
	end

	local _, nZhenQiCount = JingMai:GetResetXueWeiAward(tbLearnInfo);
	local nJingMaiId = self.nCurJingMaiId;
	me.MsgBox(string.format("重置经脉将返还所有真气但[FFFE0D]不会返还[-]已消耗的道具和银两，阁下打算重置经脉[FFFE0D]%s[-]，并获得[FFFE0D]%s[-]真气返还吗？", JingMai.tbJingMaiSetting[nJingMaiId].szName, nZhenQiCount), {{"确认", function () RemoteServer.ResetJingMai(nJingMaiId); end}, {"取消"}});
end

tbUi.tbOnClick.Toggle1 = function (self)
	-- 是否显示全经脉属性加成
	self:UpdateAttribPanel();
end

tbUi.tbOnClick.Toggle2 = function (self)
	-- 是否显示穴位名字
	local bShowName = self.pPanel:Toggle_GetChecked("Toggle2");
	for _, i in pairs(self.tbXueWeiIdxInfo) do
		self["AcupointSpot" .. i].pPanel:SetActive("AcupointName" .. i, bShowName);
	end
end

tbUi.tbOnClick.BtnOpen1 = function (self)
	-- 展开同伴属性
	self:UpdateAttribPanel();
end

tbUi.tbOnClick.BtnOpen2 = function (self)
	-- 展开玩家属性
	self:UpdateAttribPanel();
end

tbUi.tbOnClick.BtnStopAutoLevelUp = function (self)
	self:StopOpenXueWei();
end

for i = 1, 4 do
	tbUi.tbOnClick["SkillIcon" ..i] = function (self)
		local tbSubInfo = FightSkill:GetSkillShowTipInfo(unpack(self.tbShowSkillInfo[i]));
		Ui:OpenWindow("SkillShow", tbSubInfo);
	end
end

tbUi.tbOnClick.BtnAdd = function (self)
	self:StopOpenXueWei();
	Shop:AutoChooseItem(6151);
end

tbUi.tbOnClick.AcupointSpotSpecial = function (self)
	self:OnClickJingMaiLevel(self.nCurJingMaiId)
end