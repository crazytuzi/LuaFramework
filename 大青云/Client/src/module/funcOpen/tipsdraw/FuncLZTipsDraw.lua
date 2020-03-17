--[[
功能开启 灵阵 tips
lizhuangzhuang
2015年9月11日14:16:30 
]]

_G.FuncLZTipsDraw = {};

FuncLZTipsDraw.objUIDraw = nil;
FuncLZTipsDraw.objCenterUIDraw = nil;

FuncLZTipsDraw.sceneName = "lz_mhyl_open.sen";

function FuncLZTipsDraw:Enter(uiloader)
	uiloader._x = -80;
	uiloader._y = -70;
	
	self.objUIDraw = UISceneDraw:new( "FuncLZTipsDraw",uiloader,_Vector2.new(400,240));
	self.objUIDraw:SetScene(self.sceneName);
	self.objUIDraw:SetDraw( true );
end

function FuncLZTipsDraw:Exit()
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
		self.objUIDraw:SetUILoader(nil);
		UIDrawManager:RemoveUIDraw(self.objUIDraw);
		self.objUIDraw = nil;
	end
	self:ExitCenter();
end

function FuncLZTipsDraw:EnterCenter(panel)
	panel.mcBg._visible = true;
	panel.mcText._visible = true;
	panel.nameloader._visible = true;
	panel.name2loader._visible = true;
	panel.desloader._visible = true;

	panel.nameloader.source = ResUtil:GetFuncPreviewUrl("f_center_lingzhen");
	panel.name2loader.source = ResUtil:GetFuncPreviewUrl("f_center_n_lingzhen");
	panel.desloader.source = ResUtil:GetFuncPreviewUrl("f_center_lingzhen_txt");	
		
	-- panel.loader._x = -250;
	-- panel.loader._y = -300;

	self.objCenterUIDraw = UISceneDraw:new( "FuncLZTipsCenterDraw",panel.loader,_Vector2.new(1500,1000));
	self.objCenterUIDraw:SetScene(self.sceneName);
	self.objCenterUIDraw:SetDraw( true );
end

function FuncLZTipsDraw:ExitCenter()
	if self.objCenterUIDraw then
		self.objCenterUIDraw:SetDraw(false);
		self.objCenterUIDraw:SetUILoader(nil);
		UIDrawManager:RemoveUIDraw(self.objCenterUIDraw);
		self.objCenterUIDraw = nil;
	end
end