--[[
功能开启 经验副本tips
lizhuangzhuang
2015年9月11日14:11:38
]]

_G.FuncLSFBTipsDraw = {};

FuncLSFBTipsDraw.objUIDraw = nil;
FuncLSFBTipsDraw.objCenterUIDraw = nil;

FuncLSFBTipsDraw.sceneName = "ui_jingyanfuben_open.sen";

function FuncLSFBTipsDraw:Enter(uiloader)
	uiloader._x = -5;
	uiloader._y = -55;
	
	self.objUIDraw = UISceneDraw:new( "FuncLSFBTipsDraw",uiloader,_Vector2.new(200,200));
	self.objUIDraw:SetScene(self.sceneName);
	self.objUIDraw:SetDraw( true );
end

function FuncLSFBTipsDraw:Exit()
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
		self.objUIDraw:SetUILoader(nil);
		UIDrawManager:RemoveUIDraw(self.objUIDraw);
		self.objUIDraw = nil;
	end
	self:ExitCenter();
end

function FuncLSFBTipsDraw:EnterCenter(panel)
	panel.mcBg._visible = false;
	panel.mcText._visible = false;
	panel.nameloader._visible = false;
	panel.name2loader._visible = false;
	panel.desloader._visible = false;
	
	-- panel.loader._x = -450;
	-- panel.loader._y = -350;
	
	self.objCenterUIDraw = UISceneDraw:new( "FuncLSFBTipCentersDraw",panel.loader,_Vector2.new(1500,1000));
	self.objCenterUIDraw:SetScene(self.sceneName);
	self.objCenterUIDraw:SetDraw( true );
end

function FuncLSFBTipsDraw:ExitCenter()
	if self.objCenterUIDraw then
		self.objCenterUIDraw:SetDraw(false);
		self.objCenterUIDraw:SetUILoader(nil);
		UIDrawManager:RemoveUIDraw(self.objCenterUIDraw);
		self.objCenterUIDraw = nil;
	end
end