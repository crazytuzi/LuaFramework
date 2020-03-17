--[[
功能开启 转生3tips
lizhuangzhuang
2015年10月15日17:24:31
]]

_G.FuncZhuanSheng3Draw = {};

FuncZhuanSheng3Draw.objUIDraw = nil;
FuncZhuanSheng3Draw.objCenterUIDraw = nil;

FuncZhuanSheng3Draw.sceneName = "ui_lingshouqicheng_open.sen";

function FuncZhuanSheng3Draw:Enter(uiloader)
	uiloader._x = -20;
	uiloader._y = -35;
	
	self.objUIDraw = UISceneDraw:new( "FuncZhuanSheng3Draw",uiloader,_Vector2.new(200,180));
	self.objUIDraw:SetScene(self.sceneName);
	self.objUIDraw:SetDraw( true );
end

function FuncZhuanSheng3Draw:Exit()
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
		self.objUIDraw:SetUILoader(nil);
		UIDrawManager:RemoveUIDraw(self.objUIDraw);
		self.objUIDraw = nil;
	end
	self:ExitCenter();
end

function FuncZhuanSheng3Draw:EnterCenter(panel)
	panel.mcBg._visible = false;
	panel.mcText._visible = false;
	panel.nameloader._visible = false;
	panel.name2loader._visible = false;
	panel.desloader._visible = false;
	
	-- panel.loader._x = -450;
	-- panel.loader._y = -350;
	
	self.objCenterUIDraw = UISceneDraw:new( "FuncZhuanSheng3CenterDraw",panel.loader,_Vector2.new(1500,1000));
	self.objCenterUIDraw:SetScene(self.sceneName);
	self.objCenterUIDraw:SetDraw( true );
end

function FuncZhuanSheng3Draw:ExitCenter()
	if self.objCenterUIDraw then
		self.objCenterUIDraw:SetDraw(false);
		self.objCenterUIDraw:SetUILoader(nil);
		UIDrawManager:RemoveUIDraw(self.objCenterUIDraw);
		self.objCenterUIDraw = nil;
	end
end