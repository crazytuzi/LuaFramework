--[[
功能开启 圣灵tips
lizhuangzhuang
2015年12月14日14:41:32
]]

_G.FuncSLTipsDraw = {};

FuncSLTipsDraw.objUIDraw = nil;
FuncSLTipsDraw.objCenterUIDraw = nil;

FuncSLTipsDraw.sceneName = "ui_shengling_open.sen";

function FuncSLTipsDraw:Enter(uiloader)
	uiloader._x = -20;
	uiloader._y = -35;
	
	self.objUIDraw = UISceneDraw:new( "FuncSLTipsDraw",uiloader,_Vector2.new(200,180));
	self.objUIDraw:SetScene(self.sceneName);
	self.objUIDraw:SetDraw( true );
end

function FuncSLTipsDraw:Exit()
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
		self.objUIDraw:SetUILoader(nil);
		UIDrawManager:RemoveUIDraw(self.objUIDraw);
		self.objUIDraw = nil;
	end
	self:ExitCenter();
end

function FuncSLTipsDraw:EnterCenter(panel)
	panel.mcBg._visible = false;
	panel.mcText._visible = false;
	panel.nameloader._visible = false;
	panel.name2loader._visible = false;
	panel.desloader._visible = false;
	
	-- panel.loader._x = -450;
	-- panel.loader._y = -350;
	
	self.objCenterUIDraw = UISceneDraw:new( "FuncSLTipsCenterDraw",panel.loader,_Vector2.new(1500,1000));
	self.objCenterUIDraw:SetScene(self.sceneName);
	self.objCenterUIDraw:SetDraw( true );
end

function FuncSLTipsDraw:ExitCenter()
	if self.objCenterUIDraw then
		self.objCenterUIDraw:SetDraw(false);
		self.objCenterUIDraw:SetUILoader(nil);
		UIDrawManager:RemoveUIDraw(self.objCenterUIDraw);
		self.objCenterUIDraw = nil;
	end
end