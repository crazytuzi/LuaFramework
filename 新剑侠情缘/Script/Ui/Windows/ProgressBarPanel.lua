-- 通用进度条

local tbUi = Ui:CreateClass("ProgressBarPanel");

tbUi.SETTING =
{
	["Muse"] = 
	{ 
		nTotalTime = House.MUSE_TIME, 
		nGapTime = 8, 
		szDesc = "冥想中...",
		fnOnOpen = function (self)
			Ui:OpenWindow("MuseEffectPanel");
		end,
		fnOnClose = function (self)
			Ui:CloseWindow("MuseEffectPanel");
		end
	},
}

function tbUi:OnOpen(setting)
	if not setting then
		return 0;
	end

	self.nCurTime = 0;
	self.tbSetting = nil;

	if type(setting) == "table" then
		self.tbSetting = setting;
	else
		self.tbSetting = self.SETTING[setting];
	end

	if not self.tbSetting then
		return 0;
	end

	self.pPanel:ProgressBar_SetValue("ProgBar", 0);
	self.pPanel:Label_SetText("lbProgBar",  "0%");
	self.pPanel:SetActive("Label", false);
	if self.tbSetting.szDesc then
		self.pPanel:Label_SetText("Label", self.tbSetting.szDesc);
		self.pPanel:SetActive("Label", true);
	end

	self.nTimerId = Timer:Register(Env.GAME_FPS, function ()
		local bRet = self:OnTimer();
		if bRet then
			return true;
		end
		self.nTimerId = nil;
	end);

	local fnOnOpen = self.tbSetting.fnOnOpen;
	if fnOnOpen then
		fnOnOpen(self);
	end
end

function tbUi:OnTimer()
	self.nCurTime = self.nCurTime + 1;
	if self.nCurTime + 1 >= self.tbSetting.nTotalTime then
		self.nCurTime = self.tbSetting.nTotalTime;
		self:Refresh();
		return;
	end

	if self.nCurTime % self.tbSetting.nGapTime == 0 then
		self:Refresh();
		return true;
	end
	
	return true;
end

function tbUi:Refresh()
	local nVal = math.min(1, self.nCurTime / self.tbSetting.nTotalTime);
	self.pPanel:ProgressBar_SetValue("ProgBar", nVal);
	self.pPanel:Label_SetText("lbProgBar", math.floor(100 * nVal) .. "%");
end

function tbUi:OnClose()
	if self.nTimerId then
		Timer:Close(self.nTimerId);
		self.nTimerId = nil;
	end

	local fnOnClose = self.tbSetting.fnOnClose;
	if fnOnClose then
		fnOnClose(self);
	end
end
