--[[
翅膀开启
lizhuangzhuang
2015年7月10日11:34:40
]]

_G.UIWingOpen = BaseUI:new("UIWingOpen");

UIWingOpen.objUIDraw = nil;
-- UIWingOpen.objAvatar = nil;

function UIWingOpen:Create()
	self:AddSWF("wingOpen.swf",true,"top");
end

function UIWingOpen:OnLoaded(objSwf)
	objSwf.hitArea.click = function() self:OnHitAreaClick(); end
	objSwf.btnGet.click = function() self:OnHitAreaClick(); end
end

function UIWingOpen:OnResize()
	self:ShowMask();
end

function UIWingOpen:GetHeight()
	return 370;
end

function UIWingOpen:GetWidth()
	return 353;
end

function UIWingOpen:OnShow()
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

function UIWingOpen:OnHide()
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
-- function UIWingOpen:DrawDummy()
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

-- function UIWingOpen:DisposeDummy()
	-- print('------------------UIGoal:DisposeDummy()')
	-- if self.objUIDraw then
	   -- self.objUIDraw:SetDraw(false);
	-- end
-- end

local viewWingHeChengPort;
--显示模型
function UIWingOpen:DrawWingModel()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local cfg = {};
	cfg = t_transferattr[1];
	if not cfg then
		return;
	end
	if not self.objUIDraw then
		if not viewWingHeChengPort then viewWingHeChengPort = _Vector2.new(1279, 732); end
		self.objUIDraw = UISceneDraw:new( "UIWingHeCheng", objSwf.modelLoader, viewWingHeChengPort);
	end
	self.objUIDraw:SetUILoader(objSwf.modelLoader);
	
	self.objUIDraw:SetScene( cfg.mode, function()
		-- local aniName = cfg.show_san;
		-- if not aniName or aniName == "" then return end
		-- if not cfg.ui_node then return end
		
		-- local nodeName = split(cfg.ui_node, "#")
		-- if not nodeName or #nodeName < 1 then return end	
		-- for k,v in pairs(nodeName) do
			-- self.objUIDraw:NodeAnimation( v, aniName );
		-- end
	end );
	--self.objUIDraw:NodeVisible(cfg.ui_node,true);
	self.objUIDraw:SetDraw( true );
end

function UIWingOpen:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
	end
end

function UIWingOpen:OnHitAreaClick()
	self:Hide();
end

function UIWingOpen:ShowMask()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local x,y = self:GetPos();
	local wWidth,wHeight = UIManager:GetWinSize();
	objSwf.mask._x = -x;
	objSwf.mask._y = -y;
	objSwf.mask._width = wWidth;
	objSwf.mask._height = wHeight;
end