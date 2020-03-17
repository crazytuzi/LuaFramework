--[[
灵兽功能开启tips
lizhuangzhuang
2015年9月10日21:29:33
]]

_G.FuncLSTipsDraw = {};

FuncLSTipsDraw.objUIDraw = nil;
FuncLSTipsDraw.objCenterUIDraw = nil;

FuncLSTipsDraw.sceneName = "ls_jiuyouque_open.sen";

function FuncLSTipsDraw:Enter(uiloader)
	uiloader._x = 0;
	uiloader._y = 0;
	
	self.objUIDraw = UISceneDraw:new( "FuncLSTipsDraw",uiloader,_Vector2.new(180,140));
	self.objUIDraw:SetScene(self.sceneName);
	self.objUIDraw:SetDraw(true);
end


function FuncLSTipsDraw:Exit()
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
		self.objUIDraw:SetUILoader(nil);
		UIDrawManager:RemoveUIDraw(self.objUIDraw);
		self.objUIDraw = nil;
	end
	self:ExitCenter();
end

function FuncLSTipsDraw:EnterCenter(panel)
	panel.mcBg._visible = true;
	panel.mcText._visible = true;
	panel.nameloader._visible = true;
	panel.name2loader._visible = true;
	panel.desloader._visible = true;

	panel.nameloader.source = ResUtil:GetFuncPreviewUrl("f_center_lingshou");
	panel.name2loader.source = ResUtil:GetFuncPreviewUrl("f_center_n_lingshou");
	panel.desloader.source = ResUtil:GetFuncPreviewUrl("f_center_lingshou_txt");	
	
	-- panel.loader._x = -450;
	-- panel.loader._y = -350;
	
	self.objCenterUIDraw = UISceneDraw:new( "FuncLSTipsCenterDraw",panel.loader,_Vector2.new(1500,1000));
	self.objCenterUIDraw:SetScene(self.sceneName);
	self.objCenterUIDraw:SetDraw( true );
end

function FuncLSTipsDraw:ExitCenter()
	if self.objCenterUIDraw then
		self.objCenterUIDraw:SetDraw(false);
		self.objCenterUIDraw:SetUILoader(nil);
		UIDrawManager:RemoveUIDraw(self.objCenterUIDraw);
		self.objCenterUIDraw = nil;
	end
end