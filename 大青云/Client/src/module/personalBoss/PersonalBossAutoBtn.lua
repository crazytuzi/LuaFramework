--[[
	2015-11-7 20:48:14
	wangyanwei
	自动个人BOSS按钮
]]

_G.UIPersonalBossAutoBtn = BaseUI:new('UIPersonalBossAutoBtn');

function UIPersonalBossAutoBtn:Create()
	self:AddSWF('personalbossAutoBtn.swf',true,'bottom');
end

function UIPersonalBossAutoBtn:OnLoaded(objSwf)
	objSwf.btn_cancel.click = function () PersonalBossModel:SetAutoNum(nil) PersonalBossModel:SetAutoFlag(false) self:Hide(); end
end

function UIPersonalBossAutoBtn:OnShow()
	
end

function UIPersonalBossAutoBtn:OnHide()
	
end