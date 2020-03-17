--[[
结婚随份子按钮
wangshuai
]]

_G.UIMarrySuifengzi = BaseUI:new("UIMarrySuifengzi")

function UIMarrySuifengzi:Create()
	self:AddSWF("marrySuifengzi.swf", true, "bottom2")
end

function UIMarrySuifengzi:OnLoaded(objSwf,name)
	objSwf.okBtn.click = function() self:OnBtnSendBoxClick(); end;
end

--点击宝箱按钮
function UIMarrySuifengzi:OnBtnSendBoxClick()
	if not MarryGiveFive:IsShow() then 
		MarryGiveFive:Show();
	end;
end