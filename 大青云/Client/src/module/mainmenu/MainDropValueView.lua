--[[
打宝活力值UI
2015年2月5日20:15:28
haohu
]]

_G.classlist['UIDropValue'] = 'UIDropValue'
_G.UIDropValue = BaseUI:new("UIDropValue");
UIDropValue.objName = 'UIDropValue'

function UIDropValue:Create()
	self:AddSWF("dropValuePanel.swf", true, "bottom");
end

function UIDropValue:OnLoaded( objSwf )
	objSwf.btn.rollOver           = function(e) self:OnDropValueRollOver(e); end
	objSwf.btn.rollOut            = function() self:OnDropValueRollOut(); end
	objSwf.btn.click              = function() self:OnDropValueClick(); end
	objSwf.numLoader.loadComplete = function() self:OnNumLoadComplete(); end
end

function UIDropValue:OnShow()
	self:UpdateShow();
end

function UIDropValue:UpdateShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local level = DropValueModel:GetDropValueLevel();
	local _, multiple = DropValueConsts:GetDropValueInfo( level );
	local tianCiRate = multiple * DropValueConsts.BasicDropRate;
	local rateTotal = DropValueConsts.BasicDropRate + tianCiRate;
	objSwf.numLoader:drawStr( rateTotal.."e" );
end

function UIDropValue:OnDropValueRollOver(e)
	UIDropValueTips:Open(e.target);
end

function UIDropValue:OnDropValueRollOut()
	UIDropValueTips:Hide();
end

function UIDropValue:OnDropValueClick()
	if not UIDropValueDetail:IsShow() then
		UIDropValueDetail:Show();
	else
		UIDropValueDetail:Hide();
	end
end

function UIDropValue:OnNumLoadComplete()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local numLoader = objSwf.numLoader;
	local btn = objSwf.btn;
	numLoader._x = btn._x + (btn._width - numLoader._width) * 0.5;
	numLoader._y = btn._y + (btn._height - numLoader._height) * 0.6;
end

---------------------------------消息处理------------------------------------
--监听消息列表
function UIDropValue:ListNotificationInterests()
	return { NotifyConsts.SetDropValueLevel };
end

--处理消息
function UIDropValue:HandleNotification(name, body)
	if name == NotifyConsts.SetDropValueLevel then
		self:UpdateShow();
	end
end