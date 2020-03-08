
local tbUi = Ui:CreateClass("NoticePanel");

function tbUi:OnOpen(bManual, ...)
	if version_xm or version_vn or version_th or version_kor then
		return self:XGBeforeOpen(bManual, ...);
	elseif version_tx then
		-- iOS国服提审时屏蔽，对外后开启
		return self:TXBeforeOpen(bManual);
		--return 0;
	else
		Ui:AddCenterMsg("当前暂无公告信息");
		return 0;
	end
end

local szXGNoticeId = "";
local szXGNoticeMsg = nil;
local nLastOpenTime = 0;
	tbUi.szMsgUrl = Login.ClientSet.Url.NoticeUrl;


function tbUi:XGBeforeOpen(bManual, szNoticeJson)
	local nNow = GetTime();
	if nNow > (nLastOpenTime + 1800) then -- 30分钟后清除
		szXGNoticeId = "";
		szXGNoticeMsg = nil;
		nLastOpenTime = nNow;
	end

	if not szNoticeJson then
		if version_kor then -- 韩国版本需同意用户协议后才可打开
			local tbInfo = Client:GetUserInfo("LoginAgreeUserProtol", -1)
			if not tbInfo[1] then
				return 0;
			end
		end

		if not bManual and szXGNoticeId ~= "" and not self:CheckVersion(szXGNoticeId) then
			return 0;
		end

		if not Lib:IsEmptyStr(szXGNoticeMsg) then
			self.szCurMsg = szXGNoticeMsg;
			return;
		end

		local szUrl = string.format("%s?r=%d", tbUi.szMsgUrl, MathRandom(1000));
		Sdk:DoHttpRequest(szUrl, "", function (szResult)
			Ui:OpenWindow("NoticePanel", bManual, szResult);
		end);

		return 0;
	end

	local tbNoticeInfo = Lib:DecodeJson(szNoticeJson) or {};
	if Lib:IsEmptyStr(tbNoticeInfo.text) then
		return 0;
	end

	szXGNoticeId = tbNoticeInfo.version;
	szXGNoticeMsg = tbNoticeInfo.text;
	self.szCurMsg = szXGNoticeMsg;

	if Ui:WindowVisible("Login") ~= 1 then
		return 0;
	end

	if not bManual and not self:CheckVersion(szXGNoticeId) then
		return 0;
	end
end

function tbUi:TXBeforeOpen(bManual)
	self.szCurMsg = nil;
	self.szNoticeId = "";

	local tbNoticeData = Sdk:GetNoticeData();
	if not tbNoticeData or tbNoticeData.Count < 1 then
		if bManual then
			Ui:AddCenterMsg("当前暂无公告信息");
		end
		return 0;
	end

	local tbTransferTab = {
		["&gt;"] = ">";
		["&lt;"] = "<";
	};
	local nNow = GetTime();
	local tbMsgs = {};
	for i = 0, tbNoticeData.Count - 1 do
		local tbNotice = tbNoticeData[i];
		local szCurMsg = tbNotice.msg_content or "";
		local szNoticeId = tbNotice.msg_id;
		for szBefore, szAfter in pairs(tbTransferTab) do
			szCurMsg = string.gsub(szCurMsg, szBefore, szAfter) or szCurMsg;
		end
		table.insert(tbMsgs, {szCurMsg, tonumber(szNoticeId) or 0});
	end

	table.sort(tbMsgs, function (a, b)
		return a[2] > b[2];
	end)

	self.szCurMsg = tbMsgs[1][1];
	self.szNoticeId = tbMsgs[1][2];

	if not self.szCurMsg or self.szCurMsg == "" then
		if bManual then
			Ui:AddCenterMsg("当前暂无公告信息.");
		end
		return 0;
	end

	if not bManual and not self:CheckVersion(self.szNoticeId) then
		return 0;
	end
end

function tbUi:CheckVersion(szNoticeId)
--[[
	local szLastNoticeId = Client:GetFlag("LastNoticeId");
	local nLastNoticeCount = tonumber(Client:GetFlag("LastNoticeCount")) or 0;
	if szLastNoticeId == szNoticeId and nLastNoticeCount >= 3 then
		return false;
	end

	if szNoticeId ~= szLastNoticeId then
		nLastNoticeCount = 0;
	end

	Client:SetFlag("LastNoticeId", szNoticeId);
	Client:SetFlag("LastNoticeCount", nLastNoticeCount + 1);
]]
	return true;
end

function tbUi:OnOpenEnd()
	self.TxtDesc:SetLinkText(self.szCurMsg);

	local tbTextSize = self.pPanel:Label_GetPrintSize("TxtDesc");
	local tbSize = self.pPanel:Widget_GetSize("datagroup");
	self.pPanel:Widget_SetSize("datagroup", tbSize.x, 50 + tbTextSize.y);
	self.pPanel:DragScrollViewGoTop("datagroup");
	self.pPanel:UpdateDragScrollView("datagroup");
end

tbUi.tbOnClick = {};
tbUi.tbOnClick.BtnSure = function (self)
	Ui:CloseWindow(self.UI_NAME);
end
