--[[
	北仓界进入提示UI
	2015年6月2日, PM 04:24:33
	wangyanwei
]]

_G.UIActivityBeicangjieInTip = BaseUI:new('UIActivityBeicangjieInTip');

function UIActivityBeicangjieInTip:Create()
	self:AddSWF('beicangjinInTips.swf',true,'center')
end

function UIActivityBeicangjieInTip:OnLoaded(objSwf)
	objSwf.txt_info.text = UIStrConfig['beicangjie210'];
end

function UIActivityBeicangjieInTip:OnShow()
	self:OnTweenPanel();
end

function UIActivityBeicangjieInTip:OnTweenPanel()
	local objSwf = self.objSwf ;
	if not objSwf then return end
	objSwf.txt_info._y = 0;
	Tween:To(objSwf.txt_info , 5,{_y = objSwf.txt_info._y - 200},{onComplete = function ()
		self:OnTweenComplete();
	end
	},false);
end

function UIActivityBeicangjieInTip:OnTweenComplete()
	local objSwf = self.objSwf ;
	if not objSwf then return end
	objSwf.txt_info._y = 0;
	self:Hide();
end