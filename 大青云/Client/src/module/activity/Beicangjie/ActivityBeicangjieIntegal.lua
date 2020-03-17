--[[
	2015年6月2日, PM 12:00:55
	获得或失去积分
	wangyanwei
]]

_G.UIActivityBeicangjieIntegal = BaseUI:new('UIActivityBeicangjieIntegal');

function UIActivityBeicangjieIntegal:Create()
	self:AddSWF('beicangjieIntegral.swf',true,'center');
end

function UIActivityBeicangjieIntegal:OnLoaded(objSwf)
	
end

--加减状态，积分数量
UIActivityBeicangjieIntegal.integalState = nil;
UIActivityBeicangjieIntegal.integalNum = nil;
function UIActivityBeicangjieIntegal:Open(state,num)
	self.integalState = state;
	self.integalNum = num;
	if self:IsShow() then
		self:OnShow();
	else
		self:Show();
	end
end

function UIActivityBeicangjieIntegal:OnShow()
	self:OnChangData();
	self:OnTweenPanel();
end

--UIdata
function UIActivityBeicangjieIntegal:OnChangData()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.integalPanel.icon_remove._visible = self.integalState == 1;
	objSwf.integalPanel.icon_add._visible = self.integalState ~= 1;
	objSwf.integalPanel.integral.num = self.integalNum;
end

--tween
function UIActivityBeicangjieIntegal:OnTweenPanel()
	local objSwf = self.objSwf ;
	if not objSwf then return end
	objSwf.integalPanel._y = 0;
	Tween:To(objSwf.integalPanel , 0.8,{_y = objSwf.integalPanel._y - 200},{onComplete = function ()
		self:OnTweenComplete();
	end
	},false);
end

function UIActivityBeicangjieIntegal:OnTweenComplete()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.integalPanel._y = 0;
	self:Hide();
end

function UIActivityBeicangjieIntegal:OnHide()
	
end

function UIActivityBeicangjieIntegal:GetWidth()
	return 300
end

function UIActivityBeicangjieIntegal:GetHeight()
	return 55
end