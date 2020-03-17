--[[
翅膀领取

]]

_G.UIWingGet = BaseUI:new("UIWingGet");

UIWingGet.objUIDraw = nil;
-- UIWingGet.objAvatar = nil;

function UIWingGet:Create()
	self:AddSWF("wingGetView.swf",true,"top");
end

function UIWingGet:OnLoaded(objSwf)
	objSwf.hitArea.click = function() self:OnHitAreaClick(); end
	objSwf.btnGet.click = function() self:OnHitAreaClick(); end
end

function UIWingGet:OnResize()
	self:ShowMask();
end

function UIWingGet:GetHeight()
	return 370;
end

function UIWingGet:GetWidth()
	return 353;
end

function UIWingGet:OnShow()
	self:ShowMask();
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey);
	end
	self.timerKey = TimerManager:RegisterTimer(function()
		self.timerKey = nil;
		self:Hide();
	end,10000,1);

	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	self:DrawWingModel();
end

function UIWingGet:OnHide()
	-- self:DisposeDummy()
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
		-- self.objUIDraw:SetMesh(nil);
	end
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end
end

local viewWingHeChengPort;
--显示模型
function UIWingGet:DrawWingModel()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local cfg = {};
	cfg = t_wing[1002];
	if not cfg then
		return;
	end
	if not self.objUIDraw then
		if not viewWingHeChengPort then viewWingHeChengPort = _Vector2.new(1279, 732); end
		self.objUIDraw = UISceneDraw:new( "UIWingHeCheng", objSwf.modelLoader, viewWingHeChengPort);
	end
	self.objUIDraw:SetUILoader(objSwf.modelLoader);
	
	self.objUIDraw:SetScene( cfg.ui_sen, function()
	
	end );
	self.objUIDraw:SetDraw( true );
end

function UIWingGet:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
	end
end

function UIWingGet:OnHitAreaClick()
	self:Hide();
end

function UIWingGet:ShowMask()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local x,y = self:GetPos();
	local wWidth,wHeight = UIManager:GetWinSize();
	objSwf.mask._x = -x;
	objSwf.mask._y = -y;
	objSwf.mask._width = wWidth;
	objSwf.mask._height = wHeight;
end