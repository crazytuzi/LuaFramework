--[[
天神展示

]]

_G.UITianShenShowView = BaseUI:new("UITianShenShowView");

UITianShenShowView.timerKey = nil;

UITianShenShowView.objUIDraw = nil;

function UITianShenShowView:Create()
	self:AddSWF("tianshenShowPanel.swf",true,"center");

end
function UITianShenShowView:OnLoaded(objSwf)
	objSwf.hitArea.click = function() self:OnHitAreaClick(); end
	objSwf.btnGet.click = function() self:OnHitAreaClick(); end
	--模型防止阻挡鼠标
	objSwf.loader.hitTestDisable = true;
end
function UITianShenShowView:UpdateMask()
	local objSwf = self.objSwf
	if not objSwf then return end
	
    local x,y = self:GetPos();
    local wWidth,wHeight = UIManager:GetWinSize();
	objSwf.mask._x = -x;
	objSwf.mask._y = -y;
	objSwf.mask._width = wWidth;
	objSwf.mask._height = wHeight;
end
function UITianShenShowView:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
	end
end
function UITianShenShowView:OnHide()

	
    FuncManager:OpenFunc(FuncConsts.NewTianshen,true);
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
	end
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey);
	end
end
function UITianShenShowView:OnResize(wWidth, wHeight)
	if not self.bShowState then return end
	self:UpdateMask()
end
function UITianShenShowView:GetHeight()
	return 980;
end

function UITianShenShowView:GetWidth()
	return 820;
end

function UITianShenShowView:OnShow()
	

	self:Show3DWeapon();
	self:UpdateMask();
end

function UITianShenShowView:OpenPanel()
	if self:IsShow() then
		self:Show3DWeapon();
	else
		self:Show();
	end
end

local viewPort;
function UITianShenShowView:Show3DWeapon()
	local objSwf = self.objSwf;
	if not objSwf then return; end
   
    local modelid=TianShenConsts.roleid;
    local cfg=t_tianshenlv[modelid]
	if not cfg then
		Error("Cannot find config of UITianShenShowView modelid:"..modelid);
		return;
	end
	local wWidth, wHeight = 4000,2000;
	if not self.objUIDraw then
		if not viewPort then viewPort = _Vector2.new(wWidth, wHeight); end
		self.objUIDraw = UISceneDraw:new( "UITianShenShowView", objSwf.loader, viewPort );
	end
	objSwf.loader._x=-1420;
	objSwf.loader._y=-500
	self.objUIDraw:SetUILoader(objSwf.loader);
	self.objUIDraw:SetScene(cfg.ui_sen, function() self:PlayAnimal() end);
	self.objUIDraw:SetDraw(true)
end
function UITianShenShowView:PlayAnimal()
	local objSwf = self.objSwf
	if not objSwf then return end
	if not self.objUIDraw then return end
	local cfg = t_bianshenmodel[1]
	if not cfg then return end
	self.objUIDraw:NodeAnimation(cfg.skn_ui, cfg.bianshen_idle)
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey);
	end
	self.timerKey = TimerManager:RegisterTimer(function()
		self:Hide();
		
	end,5000,1);

end
function UITianShenShowView:OnHitAreaClick()
	self:Hide(); 
end
function UITianShenShowView:Update()
	if not self.bShowState then return end
end
