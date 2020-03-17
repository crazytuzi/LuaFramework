--[[
主界面：杀戮值（每日杀戮属性）
2015年1月23日16:50:26
haohu
]]
_G.classlist['UIKillValue'] = 'UIKillValue'
_G.UIKillValue = BaseUI:new("UIKillValue");
UIKillValue.objName = 'UIKillValue'
function UIKillValue:Create()
	self:AddSWF("killValuePanel.swf", true, "bottom");
end

function UIKillValue:OnLoaded( objSwf )
	objSwf.btn.click    = function(e) self:OnBtnClick(e); end
	objSwf.btn.rollOver = function(e) self:OnBtnRollOver(e); end
	objSwf.btn.rollOut  = function() self:OnBtnRollOut(); end
	objSwf.numLoader.loadComplete = function() self:OnNumLoadComplete(); end
	objSwf.wordArt.hitTestDisable = true;
	objSwf.wordArt._visible = false;
end

function UIKillValue:OnShow()
	self:UpdateShow();
	self:PlayEffect(true);
end

function UIKillValue:OnHide()
	self:PlayEffect(false);
end

function UIKillValue:PlayEffect(play)
	local objSwf = self.objSwf;
	local effect = objSwf and objSwf.effect;
	if not effect then return; end
	if play then
		effect:playEffect(0);
	else
		effect:stopEffect();
	end
end

-- 显示属性增加艺术字
function UIKillValue:PlayWordArt()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if not self.bShowState then return end
	
	local mc = objSwf.wordArt;
	local startX, startY = mc._x, mc._y;
	mc._visible = true;
	TimerManager:RegisterTimer( function()
		-- Tween:To( mc, 1, { _x = 0, _y = 40, _xscale = 10, _yscale = 10, _alpha = 0 }, { onComplete = function()
		-- 	mc._x       = startX;
		-- 	mc._y       = startY;
		-- 	mc._visible = false;
		-- 	mc._xscale  = 100;
		-- 	mc._yscale  = 100;
		-- 	mc._alpha   = 100;
		-- end}, false );
		mc._visible = false;
	end, 2000, 1 );
end

function UIKillValue:UpdateShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local killValue = KillValueModel:GetKillValue();
	local level = KillValueUtils:GetLevel(killValue);
	if level >= KillValueConsts:GetMaxLevel() then
		self:Hide();
		return;
	end
	objSwf.numLoader.num = killValue;
end

function UIKillValue:OnBtnClick(e)
	if UIKillValueDetail:IsShow() then
		UIKillValueDetail:Hide();
	else
		UIKillValueDetail:Show();
	end
end

function UIKillValue:OnBtnRollOver(e)
	UIMainKillValueTips:Show();
end

function UIKillValue:OnBtnRollOut()
	UIMainKillValueTips:Hide();
end

function UIKillValue:OnNumLoadComplete()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local numLoader = objSwf.numLoader;
	local bg = objSwf.bg;
	numLoader._x = math.max( 0, bg._x - numLoader._width * 0.5 );
end

--消息处理-----------------
--监听消息
function UIKillValue:ListNotificationInterests()
	return { NotifyConsts.KillValueChange, };
end

--消息处理
function UIKillValue:HandleNotification( name, body )
	if name == NotifyConsts.KillValueChange then
		self:UpdateShow();
	end
end

