--[[
神兵功能开启tips
lizhuangzhuang
2015年9月11日11:49:58
]]

_G.FuncSBTipsDraw = {};

FuncSBTipsDraw.objUIDraw = nil;
FuncSBTipsDraw.objCenterUIDraw = nil;

FuncSBTipsDraw.sceneName = "sq_dajian_open.sen";

function FuncSBTipsDraw:Enter(uiloader)
	uiloader._x = 0;
	uiloader._y = 0;
	
	self.objUIDraw = UISceneDraw:new( "FuncSBTipsDraw",uiloader,_Vector2.new(180,140));
	self.objUIDraw:SetScene(self.sceneName);
	self.objUIDraw:SetDraw(true);
end

function FuncSBTipsDraw:Exit()
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
		self.objUIDraw:SetUILoader(nil);
		UIDrawManager:RemoveUIDraw(self.objUIDraw);
		self.objUIDraw = nil;
	end
	self:ExitCenter();
end

function FuncSBTipsDraw:EnterCenter(panel)
	panel.mcBg._visible = true;
	panel.mcText._visible = true;
	panel.nameloader._visible = true;
	panel.name2loader._visible = true;
	panel.desloader._visible = true;

	panel.nameloader.source = ResUtil:GetFuncPreviewUrl("f_center_shenbing");
	panel.name2loader.source = ResUtil:GetFuncPreviewUrl("f_center_n_shenbing");
	panel.desloader.source = ResUtil:GetFuncPreviewUrl("f_center_shenbing_txt");
	
	-- panel.loader._x = -450;
	-- panel.loader._y = -350;
	
	self.objCenterUIDraw = UISceneDraw:new( "FuncSBTipsCenterDraw",panel.loader,_Vector2.new(1500,1000));
	self.objCenterUIDraw:SetScene(self.sceneName);
	self.objCenterUIDraw:SetDraw( true );
end

function FuncSBTipsDraw:ExitCenter()
	if self.objCenterUIDraw then
		self.objCenterUIDraw:SetDraw(false);
		self.objCenterUIDraw:SetUILoader(nil);
		UIDrawManager:RemoveUIDraw(self.objCenterUIDraw);
		self.objCenterUIDraw = nil;
	end
end

