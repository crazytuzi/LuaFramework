--[[
VIP 属性tips
2015年10月13日16:53:43
haohu
]]
------------------------------------------------------------

_G.UIVipAttrTips = BaseUI:new("UIVipAttrTips")

UIVipAttrTips.target    = nil
UIVipAttrTips.isVip     = false
UIVipAttrTips.hasAddition = false
UIVipAttrTips.tipsStr   = ""
UIVipAttrTips.fight     = 0

UIVipAttrTips.sb = "sb"
UIVipAttrTips.jj = "jj"
UIVipAttrTips.ls = "ls"
UIVipAttrTips.zq = "zq"
UIVipAttrTips.lq = "lq"
UIVipAttrTips.tj = "tj"
UIVipAttrTips.xt = "xt"
UIVipAttrTips.ts = "ts"
function UIVipAttrTips:Create()
	self:AddSWF( "vipAttrTips.swf", true, "top" )
end

function UIVipAttrTips:OnShow()
	self:UpdateShow();
	self:UpdatePos();
end

function UIVipAttrTips:UpdateShow()
	local objSwf = self.objSwf
	if not objSwf then return end
	local frameNamePrefix = self.systemName
	local frameName = self.isVip and "Vip" or "NoVip"

    local title=frameNamePrefix .. frameName;
	objSwf.mc:gotoAndPlay(title)
	objSwf.bgmc:gotoAndPlay(title);
	objSwf.fightattr:gotoAndPlay(title);
	objSwf.mc.textField.text = string.format( "%s%%", self.addition )
	objSwf.textField.htmlText = self.tipsStr
	objSwf.numLoader.num = self.fight;
end

-- 位置
function UIVipAttrTips:UpdatePos()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local tipsDir = TipsConsts.Dir_RightDown;
	local tipsX, tipsY = TipsUtils:GetTipsPos( self:GetWidth(), self:GetHeight(), tipsDir );
	objSwf._x = tipsX;
	objSwf._y = tipsY;

end
function UIVipAttrTips:Open( addition, tipsStr, fight, systemName, isVip )
	self.addition    = addition;
	self.tipsStr     = tipsStr;
	self.fight       = fight;
	self.systemName  = systemName;
	self.isVip 		 = isVip;
	self:Show();
end

---------------------------------消息处理------------------------------------
--监听消息列表
function UIVipAttrTips:ListNotificationInterests()
	return {
		NotifyConsts.StageMove
	};
end

--处理消息
function UIVipAttrTips:HandleNotification(name, body)
	if name == NotifyConsts.StageMove then
		self:UpdatePos();
	end
end
