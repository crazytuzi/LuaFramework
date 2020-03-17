--[[
功能开启 奇遇tips
lizhuangzhuang
2015年9月19日18:20:40
]]

_G.FuncQYTipsDraw = {};

FuncQYTipsDraw.objUIDraw = nil;
FuncQYTipsDraw.objCenterUIDraw = nil;

FuncQYTipsDraw.sceneName = "ui_qiyu_open.sen";

function FuncQYTipsDraw:Enter(uiloader)
	uiloader._x = -20;
	uiloader._y = -35;
	
	self.objUIDraw = UISceneDraw:new( "FuncQYTipsDraw",uiloader,_Vector2.new(200,180));
	self.objUIDraw:SetScene(self.sceneName);
	self.objUIDraw:SetDraw( true );
end

function FuncQYTipsDraw:Exit()
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
		self.objUIDraw:SetUILoader(nil);
		UIDrawManager:RemoveUIDraw(self.objUIDraw);
		self.objUIDraw = nil;
	end
	self:ExitCenter();
end

function FuncQYTipsDraw:EnterCenter(panel)
	panel.mcBg._visible = false;
	panel.mcText._visible = false;
	panel.nameloader._visible = false;
	panel.name2loader._visible = false;
	panel.desloader._visible = false;
	
	-- panel.loader._x = -450;
	-- panel.loader._y = -350;
	
	self.objCenterUIDraw = UISceneDraw:new( "FuncQYTipsCenterDraw",panel.loader,_Vector2.new(1500,1000));
	self.objCenterUIDraw:SetScene(self.sceneName);
	self.objCenterUIDraw:SetDraw( true );
end

function FuncQYTipsDraw:ExitCenter()
	if self.objCenterUIDraw then
		self.objCenterUIDraw:SetDraw(false);
		self.objCenterUIDraw:SetUILoader(nil);
		UIDrawManager:RemoveUIDraw(self.objCenterUIDraw);
		self.objCenterUIDraw = nil;
	end
end