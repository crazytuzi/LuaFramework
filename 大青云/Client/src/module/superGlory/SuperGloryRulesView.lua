--[[
至尊王城，详细规则
wangshuai
]]

_G.UISuperGloryRules = BaseUI:new("UISuperGloryRules");

function UISuperGloryRules:Create()
	self:AddSWF("SuperGloryRulesView.swf",true,nil)
end;

function UISuperGloryRules:OnLoaded(objSwf)
	objSwf.closebtn.click = function() self:ClosePanle() end;
end;

function UISuperGloryRules:OnShow()

end;

function UISuperGloryRules:OnHide()

end;

function UISuperGloryRules:ClosePanle()
	self:Hide();
end;
