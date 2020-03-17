--[[
寻路指示："自动寻路中"
郝户
2015年2月12日11:39:18
]]

_G.classlist['UIAutoRunIndicator'] = 'UIAutoRunIndicator'
_G.UIAutoRunIndicator = BaseUI:new("UIAutoRunIndicator");
UIAutoRunIndicator.objName = 'UIAutoRunIndicator'

UIAutoRunIndicator.isAutoRun = false;

function UIAutoRunIndicator:Create()
	self:AddSWF("autoRunIndicator.swf", true, "interserver" );
end

function UIAutoRunIndicator:OnShow(name)
	self.objSwf.mc:gotoAndPlay(1);
end

function UIAutoRunIndicator:OnHide()
	self.objSwf.mc:gotoAndStop(1);
end

function UIAutoRunIndicator:SetAutoRun( autoRun )
	if self.isAutoRun ~= autoRun then
		self.isAutoRun = autoRun;
		if autoRun then
			self:Show();
		else
			self:Hide();
		end
	end
end

function UIAutoRunIndicator:GetAutoRun()
	return self.isAutoRun;
end