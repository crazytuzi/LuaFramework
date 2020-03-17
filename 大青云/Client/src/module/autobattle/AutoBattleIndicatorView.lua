
--[[
挂机指示："自动挂机中"
郝户
2014年10月26日18:48:32
]]

_G.classlist['UIAutoBattleIndicator'] = 'UIAutoBattleIndicator'
_G.UIAutoBattleIndicator = BaseUI:new("UIAutoBattleIndicator");
UIAutoBattleIndicator.objName = 'UIAutoBattleIndicator'

function UIAutoBattleIndicator:Create()
	self:AddSWF("autoBattleIndicator.swf", true, "interserver" );
end

function UIAutoBattleIndicator:OnLoaded( objSwf )
	objSwf.btnSet.click = function() self:OnBtnSetClick(); end
	
end

function UIAutoBattleIndicator:OnShow()
	self.objSwf.mc:gotoAndPlay(1);
end

function UIAutoBattleIndicator:OnHide()
	self.objSwf.mc:gotoAndStop(1);
end

function UIAutoBattleIndicator:OnBtnSetClick()
	if not UIAutoBattle:IsShow() then 
		UIAutoBattle:Show();
	else 
		UIAutoBattle:Hide();
	end
end

function UIAutoBattleIndicator:SwitchHang( hanging )
	local func = hanging and self.Show or self.Hide;
	func(self);
end