--[[
功能开启 打包地宫tips
lizhuangzhuang
2015年9月11日12:27:33
]]

_G.FuncDBDGTipsDraw = {};

FuncDBDGTipsDraw.objUIDraw = nil;
FuncDBDGTipsDraw.objCenterUIDraw = nil;

FuncDBDGTipsDraw.sceneName = "dl_dabaoxiang_open.sen";

function FuncDBDGTipsDraw:Enter(uiloader)
	uiloader._x = -50;
	uiloader._y = -40;
	
	self.objUIDraw = UISceneDraw:new( "FuncDBDGTipsDraw",uiloader,_Vector2.new(250,200));
	self.objUIDraw:SetScene(self.sceneName);
	self.objUIDraw:SetDraw( true );
end

function FuncDBDGTipsDraw:Exit()
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
		self.objUIDraw:SetUILoader(nil);
		UIDrawManager:RemoveUIDraw(self.objUIDraw);
		self.objUIDraw = nil;
	end
	self:ExitCenter();
end

function FuncDBDGTipsDraw:EnterCenter(panel)
	panel.mcBg._visible = false;
	panel.mcText._visible = false;
	panel.nameloader._visible = false;
	panel.name2loader._visible = false;
	panel.desloader._visible = false;
	
	-- panel.loader._x = -450;
	-- panel.loader._y = -350;
	
	self.objCenterUIDraw = UISceneDraw:new( "FuncDBDGTipCentersDraw",panel.loader,_Vector2.new(1500,1000));
	self.objCenterUIDraw:SetScene(self.sceneName);
	self.objCenterUIDraw:SetDraw( true );
end

function FuncDBDGTipsDraw:ExitCenter()
	if self.objCenterUIDraw then
		self.objCenterUIDraw:SetDraw(false);
		self.objCenterUIDraw:SetUILoader(nil);
		UIDrawManager:RemoveUIDraw(self.objCenterUIDraw);
		self.objCenterUIDraw = nil;
	end
end