--[[
功能开启 骑战tips
lizhuangzhuang
2015年11月17日22:13:54
]]

_G.FuncQZTipsDraw = {};

FuncQZTipsDraw.objUIDraw = nil;
FuncQZTipsDraw.objCenterUIDraw = nil;

FuncQZTipsDraw.sceneName = "ui_qichengzhandou_open.sen";

function FuncQZTipsDraw:Enter(uiloader)
	uiloader._x = -20;
	uiloader._y = -35;
	
	self.objUIDraw = UISceneDraw:new( "FuncQZTipsDraw",uiloader,_Vector2.new(200,180));
	self.objUIDraw:SetScene(self.sceneName);
	self.objUIDraw:SetDraw( true );
end


function FuncQZTipsDraw:Exit()
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
		self.objUIDraw:SetUILoader(nil);
		UIDrawManager:RemoveUIDraw(self.objUIDraw);
		self.objUIDraw = nil;
	end
	self:ExitCenter();
end

function FuncQZTipsDraw:EnterCenter(panel)
	panel.mcBg._visible = false;
	panel.mcText._visible = false;
	panel.nameloader._visible = false;
	panel.name2loader._visible = false;
	panel.desloader._visible = false;
	
	self.objCenterUIDraw = UISceneDraw:new( "FuncQZTipsCenterDraw",panel.loader,_Vector2.new(1500,1000));
	self.objCenterUIDraw:SetScene(self.sceneName);
	self.objCenterUIDraw:SetDraw( true )
end

function FuncQZTipsDraw:ExitCenter()
	if self.objCenterUIDraw then
		self.objCenterUIDraw:SetDraw(false);
		self.objCenterUIDraw:SetUILoader(nil);
		UIDrawManager:RemoveUIDraw(self.objCenterUIDraw);
		self.objCenterUIDraw = nil;
	end
end