--[[
面板loading
lizhuangzhuang
2014-12-24 11:02:11
]]

_G.UILoadingPanel = BaseUI:new("UILoadingPanel");

--队列,只显示最后一个的进度
UILoadingPanel.list = {};

function UILoadingPanel:Create()
	self:AddSWF("loadingPanel.swf",true,"loading");
end

function UILoadingPanel:OnLoaded(objSwf)
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end
end

function UILoadingPanel:NeverDeleteWhenHide()
	return true;
end

function UILoadingPanel:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf._visible = false;
	objSwf.mcProgress:gotoAndStop(1);
	self.timerKey = TimerManager:RegisterTimer(function()
		objSwf._visible = true;
	end,200,1);
end

function UILoadingPanel:OnHide()
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey);
	end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.tfPercent.text = "";
end

function UILoadingPanel:Open(uiName)
	table.push(self.list,uiName);
	for k, v in pairs(self.list) do
		WriteLog(LogType.Normal, false, "LoadingPanelView.lua<UILoadingPanel:Open>46 : ", v)
	end
	WriteLog(LogType.Normal, false, "LoadingPanelView.lua<UILoadingPanel:Open>48 : ", '-----------')
	if not self:IsShow() then
		self:Show();
	end
end

function UILoadingPanel:Close(uiName)
	for i=#self.list,1,-1 do
		local name = self.list[i];
		if name == uiName then
			table.remove(self.list,i,1);
		end
	end
	for k, v in pairs(self.list) do
		WriteLog(LogType.Normal, false, "LoadingPanelView.lua<UILoadingPanel:Close>62 : ", v)
	end
	WriteLog(LogType.Normal, false, "LoadingPanelView.lua<UILoadingPanel:Close>64 : ", '-----------')
	if #self.list <= 0 then
		self:Hide();
	end
end

function UILoadingPanel:OnBtnCloseClick()
	for i,uiName in ipairs(self.list) do
		local ui = UIManager:GetUI(uiName);
		if ui then
			ui:Hide();
		end
	end
	self.list = {};
	self:Hide();
end

function UILoadingPanel:SetPercent(uiName,p)
	if not self.bShowState then return; end
	--只显示第一个的进度
	if uiName ~= self.list[1] then
		return;
	end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local percent = toint(p*100,0.5);
	objSwf.tfPercent.text = string.format("%s%%",percent);
	if percent > 0 then
		objSwf.mcProgress:gotoAndStop(percent);
	end
end