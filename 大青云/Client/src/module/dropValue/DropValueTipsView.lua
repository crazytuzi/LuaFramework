--[[
打宝活力值tips
2015年1月22日16:11:10
haohu
]]

_G.UIDropValueTips = BaseUI:new("UIDropValueTips");

function UIDropValueTips:Create()
	self:AddSWF("dropValueTips.swf", true, "top");
end

function UIDropValueTips:OnLoaded(objSwf)
	objSwf.txtPrompt1.htmlText = StrConfig['dropValue101'];
	objSwf.txtPrompt2.htmlText = StrConfig['dropValue102'];
end

function UIDropValueTips:OnShow()
	self:UpdateShow();
	self:UpdatePos();
end

function UIDropValueTips:OnHide()
	self.target = nil;
end

function UIDropValueTips:UpdateShow()
	self:ShowDropRate();
	self:ShowDropValue();
end

function UIDropValueTips:ShowDropRate()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	-- 内容
	local superDropRate = DropValueConsts:GetSuperDrop();
	local vipDrop = DropValueConsts:GetVipDrop();
	local level = DropValueModel:GetDropValueLevel();
	local _, multiple = DropValueConsts:GetDropValueInfo( level );
	local tianCiRate = multiple * DropValueConsts.BasicDropRate;
	local rateTotal = tianCiRate + DropValueConsts.BasicDropRate;
	objSwf.numLoader:drawStr( rateTotal.."e" );
	objSwf.txtContent.htmlText = string.format( StrConfig['dropValue103'], DropValueConsts.BasicDropRate, superDropRate, vipDrop, tianCiRate );
end

function UIDropValueTips:ShowDropValue()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local dropValue = MainPlayerModel.humanDetailInfo.eaDropVal;
	objSwf.txtDropValue.htmlText = string.format( StrConfig['dropValue104'], dropValue );
end

-- 位置
function UIDropValueTips:UpdatePos()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local tipsDir = TipsConsts.Dir_RightDown;
	local tipsX, tipsY = TipsUtils:GetTipsPos( self:GetWidth(), self:GetHeight(), tipsDir );
	objSwf._x = tipsX;
	objSwf._y = tipsY;
end

function UIDropValueTips:Open(target)
	self.target = target;
	self:Show();
end

---------------------------------消息处理------------------------------------
--监听消息列表
function UIDropValueTips:ListNotificationInterests()
	return {
		NotifyConsts.PlayerAttrChange,
		NotifyConsts.SetDropValueLevel,
		NotifyConsts.StageMove
	};
end

--处理消息
function UIDropValueTips:HandleNotification(name, body)
	if name == NotifyConsts.PlayerAttrChange then
		if body.type == enAttrType.eaDropVal then
			self:ShowDropValue();
		end
	elseif name == NotifyConsts.SetDropValueLevel then
		self:ShowDropRate();
	elseif name == NotifyConsts.StageMove then
		self:UpdatePos();
	end
end
