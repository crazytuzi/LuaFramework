
local tbUi = Ui:CreateClass("GetNotice");

tbUi.nMaxMsgCount = 3;

--- 这个随便改
tbUi.nMoveTime = 0.5;
tbUi.nTotalTime = 0.9 + tbUi.nMoveTime;

function tbUi:OnOpen()
	self.tbAllMsg = {};
	self.tbUnUseNotice = {1, 2, 3};
	self.tbCacheMsg = {};
	self.nUpdateTime = GetTime();
	self:UpdateCenterMsg();
end

function tbUi:AddMsg(szMsg)
	assert(self.tbUnUseNotice[1]);

	local nIdx = #self.tbAllMsg;
	local nUseNoticeIdx = self.tbUnUseNotice[1];
	table.insert(self.tbAllMsg, nUseNoticeIdx);
	table.remove(self.tbUnUseNotice, 1);
	self.pPanel:Label_SetText("Info" .. nUseNoticeIdx, szMsg or "");
	local tbSize = self.pPanel:Label_GetSize("Info" .. nUseNoticeIdx);
	self.pPanel:ChangePosition("Info" .. nUseNoticeIdx, -tbSize.x / 2, 10, 0);
	self.pPanel:SetActive("Notice" .. nUseNoticeIdx, true);
	self.pPanel:Tween_RunWhithStartPos("Notice" .. nUseNoticeIdx, 0, -100, 0, 35 - nIdx * 35, self.nMoveTime);

	if nIdx == 0 then
		if self.nUpdateTimerId then
			Timer:Close(self.nUpdateTimerId);
			self.nUpdateTimerId = nil;
		end
		self.nUpdateTime = GetTime();
		self.nUpdateTimerId = Timer:Register(self.nTotalTime * Env.GAME_FPS, self.RemoveOneMsg, self);
	end
end

function tbUi:RemoveOneMsg()
	if #self.tbAllMsg < 1 then
		return;
	end

	if Ui:WindowVisible(self.UI_NAME) ~= 1 then
		return;
	end

	self.nUpdateTime = GetTime();

	local nRemoveNoticeIdx = self.tbAllMsg[1];
	self.pPanel:Tween_RunWhithStartPos("Notice" .. nRemoveNoticeIdx, 0, -100, 0, -120, 0.01);  -- 这句 防止闪烁
	self.pPanel:SetActive("Notice" .. nRemoveNoticeIdx, false);


	table.remove(self.tbAllMsg, 1);
	table.insert(self.tbUnUseNotice, nRemoveNoticeIdx);

	for i = 1, #self.tbAllMsg do
		self.pPanel:Tween_Run("Notice" .. self.tbAllMsg[i], 0, 35 * (2 - i), self.nMoveTime);
	end

	if #self.tbCacheMsg > 0 then
		self:AddMsg(self.tbCacheMsg[1]);
		table.remove(self.tbCacheMsg, 1);
	end

	local nTime = self.nTotalTime;
	if self.tbCacheMsg and #self.tbCacheMsg > 0 then
		nTime = self.nMoveTime;
	end

	self.nUpdateTimerId = nil;

	if self.tbAllMsg[1] then
		self.nUpdateTimerId = Timer:Register(nTime * Env.GAME_FPS, self.RemoveOneMsg, self);
	end
end


function tbUi:UpdateCenterMsg()
	if #self.tbAllMsg == 0 then
		self.tbCacheMsg = {};
	end

	local tbMsg = Ui:FetchCenterMsg()
	for _, szMsg in ipairs(tbMsg) do
		if #self.tbCacheMsg > 0 or #self.tbAllMsg >= self.nMaxMsgCount then
			table.insert(self.tbCacheMsg, szMsg);
		else
			self:AddMsg(szMsg);
		end
	end

	self:DoCheck();
end

function tbUi:DoCheck()
	self.nUpdateTime = self.nUpdateTime or GetTime();
	if GetTime() - self.nUpdateTime >= 5 and #self.tbAllMsg >= 1 then
		Ui:CloseWindow(self.UI_NAME);
	end
end

function tbUi:OnClose()
	if self.nUpdateTimerId then
		Timer:Close(self.nUpdateTimerId);
		self.nUpdateTimerId = nil;
	end

	Ui:FetchCenterMsg();
	self.tbAllMsg = {};
	self.tbUnUseNotice = {1, 2, 3};
	self.tbCacheMsg = {};
	for i = 1, 3 do
		self.pPanel:SetActive("Notice" .. i, false);
	end
end

function tbUi:RegisterEvent()
    local tbRegEvent =
    {
        { UiNotify.emNOTIFY_CENTER_MSG,		self.UpdateCenterMsg},
        { UiNotify.emNOTIFY_MAP_LOADED,		self.DoCheck},
    };

    return tbRegEvent;
end
