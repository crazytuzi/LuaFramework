_G.UIOpenFunInfo = BaseUI:new("UIOpenFunInfo");
UIOpenFunInfo.currfuncID = nil;
UIOpenFunInfo.currShowBtn = nil;
function UIOpenFunInfo:Create()
	self:AddSWF("OpenFunInfoPanel.swf",true,"center");
end

function UIOpenFunInfo:OnLoaded(objSwf)
	objSwf.btnJihuo.click = function() self:OnBtnJiHuoClick(); end
	objSwf.btnClose.click = function() self:Hide(); end
end
function UIOpenFunInfo:OnShow()
	self:SetInfo();
end
function UIOpenFunInfo:SetInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self:DrawDummy()
	objSwf.btnJihuo.disabled = true;
	if self.currShowBtn == OpenFunByDayConst.showJihuo then
		objSwf.btnJihuo.disabled = false;
	end
	if objSwf.titleLoader.source ~= ResUtil:GetOpenFunTitle(self.currfuncID) then
		objSwf.titleLoader.source = ResUtil:GetOpenFunTitle(self.currfuncID)
	end
	if objSwf.nameLoader.source ~= ResUtil:GetOpenFunDescribe(self.currfuncID) then
		objSwf.nameLoader.source = ResUtil:GetOpenFunDescribe(self.currfuncID);
	end
	-- objSwf.infolLoader.source =ResUtil:GetOpenFunAttribute(self.currfuncID) ;
	local cfg = t_funcOpen[self.currfuncID];
	local fight = cfg.war
	objSwf.numLoaderFight.num = fight;
end
local viewPort = nil;
UIOpenFunInfo.model = nil;
function UIOpenFunInfo:DrawDummy()
	-- self:DisposeDummy();
	local config = t_funcOpen[self.currfuncID];
	if not config then
		return;
	end
	if self.model ~= config.open_sen then
		self:DisposeDummy()
		self.model = config.open_sen
	else
		return;
	end
	if not self.objUIDraw then
		if not viewPort then viewPort = _Vector2.new(700, 450); end
		self.objUIDraw = UISceneDraw:new( "OpenFunInfoUI", self.objSwf.avatarLoader, viewPort );
	end
	self.objUIDraw:SetUILoader(self.objSwf.avatarLoader);
	-- local model = nil;
	-- if self.currShow.id==1002 then
		-- model =self:getModel()
	-- else
		-- model = config.open_sen
	-- end
	
	self.objUIDraw:SetScene( self.model );
	self.objUIDraw:SetDraw( true );
end
function UIOpenFunInfo:ShowInfo(funcID,state)
	if not funcID then
		return;
	end
	self.currfuncID = toint(funcID)
	self.currShowBtn = state
	if self:IsShow() then
		self:OnShow();
	else
		self:Show();
	end
end
--客户端请求新功能开启
function UIOpenFunInfo:OnBtnJiHuoClick()
	if self.currfuncID == FuncConsts.LingQi then--法宝系统120
		GoalController:SendGoalReward(1010);
	elseif self.currfuncID == FuncConsts.Armor then--宝甲系统125
		GoalController:SendGoalReward(1012);
	elseif self.currfuncID == FuncConsts.MingYuDZZ then--玉佩系统122
		GoalController:SendGoalReward(1013);
	elseif self.currfuncID == FuncConsts.MagicWeapon then--神兵系统21
		GoalController:SendGoalReward(1011);
	end
	FuncOpenController:ReqFunctionOpen(self.currfuncID)
end
function UIOpenFunInfo:OnHide()
	local objSwf = self.objSwf;
	if not objSwf then 
	   return; 
	end
	self:DisposeDummy();
	self.currShow = nil;
	self.model = nil;
end
function UIOpenFunInfo:DisposeDummy()
	if self.objUIDraw then
	   self.objUIDraw:SetDraw(false);
	end
end