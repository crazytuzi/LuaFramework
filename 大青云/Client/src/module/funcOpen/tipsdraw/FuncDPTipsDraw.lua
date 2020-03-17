--[[
功能开启 斗破 tips
lizhuangzhuang
2015年9月19日18:19:20
]]

_G.FuncDPTipsDraw = {};

FuncDPTipsDraw.objUIDraw = nil;
FuncDPTipsDraw.objCenterUIDraw = nil;

FuncDPTipsDraw.sceneName = "ui_doupochangqiong_open.sen";

function FuncDPTipsDraw:Enter(uiloader)
	uiloader._x = -50;
	uiloader._y = -40;
	
	self.objUIDraw = UISceneDraw:new( "FuncDPTipsDraw",uiloader,_Vector2.new(250,200));
	self.objUIDraw:SetScene(self.sceneName);
	self.objUIDraw:SetDraw( true );
end

function FuncDPTipsDraw:Exit()
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
		self.objUIDraw:SetUILoader(nil);
		UIDrawManager:RemoveUIDraw(self.objUIDraw);
		self.objUIDraw = nil;
	end
	self:ExitCenter();
end

function FuncDPTipsDraw:EnterCenter(panel)
	panel.mcBg._visible = false;
	panel.mcText._visible = false;
	panel.nameloader._visible = false;
	panel.name2loader._visible = false;
	panel.desloader._visible = false;

	-- panel.loader._x = -450;
	-- panel.loader._y = -350;
	
	self.objCenterUIDraw = UISceneDraw:new( "FuncDPTipsCenterDraw",panel.loader,_Vector2.new(1500,1000));
	self.objCenterUIDraw:SetScene(self.sceneName);
	self.objCenterUIDraw:SetDraw( true );
end

function FuncDPTipsDraw:ExitCenter()
	if self.objCenterUIDraw then
		self.objCenterUIDraw:SetDraw(false);
		self.objCenterUIDraw:SetUILoader(nil);
		UIDrawManager:RemoveUIDraw(self.objCenterUIDraw);
		self.objCenterUIDraw = nil;
	end
end