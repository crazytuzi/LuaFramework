--[[
领取超级元宝礼包弹出获取界面
]]

_G.UIYuanbaoOpen = BaseUI:new("UIYuanbaoOpen");

UIYuanbaoOpen.objUIDraw = nil;
-- UIYuanbaoOpen.objAvatar = nil;

function UIYuanbaoOpen:Create()
	self:AddSWF("yuanbaoOpen.swf",true,"top");
end

function UIYuanbaoOpen:OnLoaded(objSwf)
	objSwf.hitArea.click = function() self:OnHitAreaClick(); end
	objSwf.btnGet.click = function() self:OnHitAreaClick(); end
end

function UIYuanbaoOpen:OnResize()
	self:ShowMask();
end

function UIYuanbaoOpen:GetHeight()
	return 370;
end

function UIYuanbaoOpen:GetWidth()
	return 353;
end

function UIYuanbaoOpen:OnShow()
	self:ShowMask();
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey);
	end
	self.timerKey = TimerManager:RegisterTimer(function()
		self.timerKey = nil;
		self:Hide();
	end,FuncConsts.AutoOpenTime,1);

	local objSwf = self.objSwf;
	if not objSwf then return; end
	self:DrawWingModel();
	-- self.objUIDraw:PlayPfx("zuoqifazhen.pfx");
end

function UIYuanbaoOpen:OnHide()
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
	end
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end
	BagController:UseItemByTid(BagConsts.BagType_Bag,150050001,1);
end

local viewWingHeChengPort;
function UIYuanbaoOpen:DrawWingModel()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local cfg = {};
	cfg = t_mubiao[1001];
	if not cfg then
		return;
	end
	if not self.objUIDraw then
		if not viewWingHeChengPort then viewWingHeChengPort = _Vector2.new(1000, 650); end
		self.objUIDraw = UISceneDraw:new( "UIYuanBaoShow", objSwf.modelLoader, viewWingHeChengPort);
	end
	self.objUIDraw:SetUILoader(objSwf.modelLoader);
	
	self.objUIDraw:SetScene(cfg.model);
	self.objUIDraw:SetDraw( true );
end

function UIYuanbaoOpen:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
	end
end

function UIYuanbaoOpen:OnHitAreaClick()
	self:Hide();
end

function UIYuanbaoOpen:ShowMask()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local x,y = self:GetPos();
	local wWidth,wHeight = UIManager:GetWinSize();
	objSwf.mask._x = -x;
	objSwf.mask._y = -y;
	objSwf.mask._width = wWidth;
	objSwf.mask._height = wHeight;
end