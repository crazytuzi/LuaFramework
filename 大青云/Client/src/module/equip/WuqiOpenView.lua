--[[
�����
lizhuangzhuang
2015��7��10��11:34:40
]]

_G.UIWuqiOpen = BaseUI:new("UIWuqiOpen");

UIWuqiOpen.objUIDraw = nil;
-- UIWuqiOpen.objAvatar = nil;

function UIWuqiOpen:Create()
	self:AddSWF("wuqiOpen.swf",true,"top");
end

function UIWuqiOpen:OnLoaded(objSwf)
	objSwf.hitArea.click = function() self:OnHitAreaClick(); end
	objSwf.btnGet.click = function() self:OnHitAreaClick(); end
end

function UIWuqiOpen:OnResize()
	self:ShowMask();
end

function UIWuqiOpen:GetHeight()
	return 370;
end

function UIWuqiOpen:GetWidth()
	return 353;
end

function UIWuqiOpen:OnShow()
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
	-- local cfg = t_wing[1];
	-- if not cfg then return; end
	-- self.objAvatar = CAvatar:new();
	-- self.objAvatar.avtName = "wingPreview";
	-- self.objAvatar:SetPart("Body",cfg.tipsSkn);
	-- self.objAvatar:ChangeSkl(cfg.tipsSkl);
	-- self.objAvatar:ExecAction(cfg.tipsSan,true);
	-- self.objAvatar.objMesh.transform:mulScalingRight(1.5,1.5,1.5);
	
	-- objSwf.modelLoader._x = -750;
	-- objSwf.modelLoader._y = -700;
	
	-- if not self.objUIDraw then
		-- self.objUIDraw = UIDraw:new("WingOpenDraw",self.objAvatar,objSwf.modelLoader,
									-- _Vector2.new(1800,1200),
								-- _Vector3.new(0,-100,25),
								-- _Vector3.new(1,0,20),
								-- 0x00000000);
	-- else
		-- self.objUIDraw:SetUILoader(objSwf.modelLoader);
		-- self.objUIDraw:SetCamera(_Vector2.new(1800,1200),
								-- _Vector3.new(0,-100,25),
								-- _Vector3.new(1,0,20));
		-- self.objUIDraw:SetMesh(self.objAvatar);
	-- end 
	-- if not self.objUIDraw then
	-- if not viewPort then viewPort = _Vector2.new(250, 150); end
		-- self.objUIDraw = UISceneDraw:new( "WingOpenViewUI", self.objSwf.modelLoader, viewPort );
	-- end
	-- self.objUIDraw:SetUILoader(self.objSwf.modelLoader);
	-- self.objUIDraw:SetScene( t_mubiao[1001].model );
	-- self.objUIDraw:SetDraw(true);
	self:DrawWingModel();
	-- self.objUIDraw:PlayPfx("zuoqifazhen.pfx");
end

function UIWuqiOpen:OnHide()
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
-- local viewPort = nil;
-- function UIWuqiOpen:DrawDummy()
	-- self:DisposeDummy();

	-- print('--------------------UIGoal:DrawDummy()--')
	-- local config = self.currShow.cnf;
	-- if not config then
		-- print('--------------------not config--- UIGoal:DrawDummy()--')
		-- return;
	-- end	
	-- if not self.objUIDraw then
		-- if not viewPort then viewPort = _Vector2.new(600, 400); end
		-- self.objUIDraw = UISceneDraw:new( "WingOpenViewUI", self.objSwf.modelLoader, viewPort );
	-- end
	-- self.objUIDraw:SetUILoader(self.objSwf.modelLoader);
	-- self.objUIDraw:SetScene( t_mubiao[1001].model );
	-- self.objUIDraw:SetDraw( true );
	-- self.objUIDraw:PlayPfx("zuoqifazhen.pfx");
-- end

-- function UIWuqiOpen:DisposeDummy()
	-- print('------------------UIGoal:DisposeDummy()')
	-- if self.objUIDraw then
	   -- self.objUIDraw:SetDraw(false);
	-- end
-- end

local viewWingHeChengPort;
--��ʾģ��
function UIWuqiOpen:DrawWingModel()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	-- local cfg = {};
	-- cfg = t_mubiao[1002];
	-- if not cfg then
		-- return;
	-- end
	if not self.objUIDraw then
		if not viewWingHeChengPort then viewWingHeChengPort = _Vector2.new(1279, 732); end
		self.objUIDraw = UISceneDraw:new( "UIWuqiHeCheng", objSwf.modelLoader, viewWingHeChengPort);
	end
	self.objUIDraw:SetUILoader(objSwf.modelLoader);
	
	self.objUIDraw:SetScene(UIGoal:getModel());
	self.objUIDraw:SetDraw( true );
end

function UIWuqiOpen:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
	end
end

function UIWuqiOpen:OnHitAreaClick()
	self:Hide();
end

function UIWuqiOpen:ShowMask()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local x,y = self:GetPos();
	local wWidth,wHeight = UIManager:GetWinSize();
	objSwf.mask._x = -x;
	objSwf.mask._y = -y;
	objSwf.mask._width = wWidth;
	objSwf.mask._height = wHeight;
end