
local tbUi = Ui:CreateClass("CommonDeathPopup")

function tbUi:OnOpen(szType, ...)
	if self[szType] then
		self[szType](self, ...);
	end
end

function tbUi:AutoRevive(szMsg, nTime)
	self.AutoReviveMsg = szMsg;
	self.AutoReviveTime = nTime;
	self:AutoReviveTimer();
end

function tbUi:AutoReviveTimer()
	if self.nAutoReviveTimerId then
		Timer:Close(self.nAutoReviveTimerId);
		self.nAutoReviveTimerId = nil;
	end

	if self.AutoReviveTime <= 0 then
		Ui:CloseWindow(self.UI_NAME);
		return;
	end

	local szMsg = string.format(self.AutoReviveMsg, self.AutoReviveTime);
	self.pPanel:Label_SetText("TextInfo", szMsg);

	self.AutoReviveTime = self.AutoReviveTime - 1;

	self.nAutoReviveTimerId = Timer:Register(Env.GAME_FPS * 1, function() 
			self.nAutoReviveTimerId = nil;
			self:AutoReviveTimer();
		end);
end

function tbUi:OnClose()
	if self.nAutoReviveTimerId then
		Timer:Close(self.nAutoReviveTimerId);
		self.nAutoReviveTimerId = nil;
	end
end

tbUi.tbOnClick = {
	BtnCenter = function (self, tbGameObj)
		Ui:CloseWindow(self.UI_NAME);
	end,
}

