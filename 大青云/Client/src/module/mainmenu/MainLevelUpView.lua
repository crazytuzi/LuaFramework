--[[
主玩家升级效果
郝户
2014年10月11日12:20:16
]]

_G.UILevelUpEffect = BaseUI:new("UILevelUpEffect");

UILevelUpEffect.level = 0;

function UILevelUpEffect:Create()
	self:AddSWF("mainPlayerLevelUp.swf", true, "top" );
end

function UILevelUpEffect:OnLoaded( objSwf )
	objSwf.levelUpEffect.complete = function() self:OnEffectComplete(); end
	objSwf.panel.levelLoader.loadComplete = function() self:OnLevelLoadComplete(); end
end

function UILevelUpEffect:GetWidth()
	return 400
end

function UILevelUpEffect:GetHeight()
	return 300
end

function UILevelUpEffect:OnShow()
	local objSwf = self.objSwf
	if not objSwf then return end
	local level = MainPlayerModel.humanDetailInfo.eaLevel
	objSwf.panel.levelLoader.num = level
	objSwf.levelUpEffect:playEffect(1)
end

function UILevelUpEffect:OnEffectComplete()
	self:Hide();
end

function UILevelUpEffect:OnLevelLoadComplete()
	local objSwf = self.objSwf
	if not objSwf then return end
	local panel = objSwf.panel
	panel.imglevel._x = panel.levelLoader.width;
	panel._y = objSwf.levely._y;
	panel._x = ( self.GetWidth() - panel._width ) * 0.5
	panel._alpha = 100;
	
	Tween:To(panel,1.5,{_alpha = 20,_y=panel._y-120});
end