_G.UIOperTips = BaseUI:new("UIOperTips");
UIOperTips.currShow = nil;
UIOperTips.getCurrServerTime = nil;
UIOperTips.funcID = 0
function UIOperTips:Create()
	self:AddSWF("mainOperTips.swf",true,"center");
end

function UIOperTips:OnLoaded(objSwf)
	objSwf.closebtn.click = function() self:Hide() end;

	objSwf.toChongZhi.click = function() self:OnChongZhiClick()end;
	
end
function UIOperTips:OnChongZhiClick()
	Version:Charge()
end
function UIOperTips:OnShow()
	self:GetCfg()
	self:SetInfo();
end
function UIOperTips:GetCfg()
	local lv  = MainPlayerModel.humanDetailInfo.eaLevel
	self.cfg = nil
	for i, v in ipairs(OperactivitiesConsts.FirstChargeTipsCfg) do
		if lv >= toint(v.level) then
			self.cfg = v
		else
			break
		end
	end
end

function UIOperTips:IsToShowLevel()
	local lv = MainPlayerModel.humanDetailInfo.eaLevel
	for i, v in ipairs(OperactivitiesConsts.FirstChargeTipsCfg) do
		if lv == v.level and v.compulsion == true then
			self:Open(1)
		end
	end
end
function UIOperTips:Open(typeView)
	self.typeView = typeView
	if self:IsShow() then
		-- self:OnShow();
	else
		self:Show();
	end
end
function UIOperTips:SetInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if not self.cfg then
		return
	end
	objSwf.toChongZhi.htmlLabel = string.format(StrConfig['xiuweiPool25']);
	if self.typeView==1 then--弹出界面
		objSwf.closebtn._visible = true;
		objSwf.toChongZhi._visible = true;
	else--tips
		objSwf.closebtn._visible = false;
		objSwf.toChongZhi._visible = false;
	end
	objSwf.iconDes.source = ResUtil:GetOperName(self.cfg.icon)
	
	objSwf.iconDes.loaded = function()
		objSwf.iconDes._x = (314  - objSwf.iconDes.content._width )/ 2
	end
	self:DrawDummy();
end
local viewPort
function UIOperTips:DrawDummy()
	
	self:DisposeDummy();
	self.model = self.cfg.sen
	if not self.objUIDraw then
		if not viewPort then viewPort = _Vector2.new(700, 300); end
		self.objUIDraw = UISceneDraw:new( "UIOperTipsModel", self.objSwf.avatarLoader, viewPort );
	end
	self.objUIDraw:SetUILoader(self.objSwf.avatarLoader);

	self.objUIDraw:SetScene( self.model );
	self.objUIDraw:SetDraw( true );
end
function UIOperTips:DisposeDummy()
	if self.objUIDraw then
	   self.objUIDraw:SetDraw(false);
	end
end
function UIOperTips:OnHide()
	local objSwf = self.objSwf;
	if not objSwf then 
	   return; 
	end
	self:DisposeDummy();
	self.currShow = nil;
	self.model = nil
	self.cfg = nil
end
function UIOperTips:ListNotificationInterests()
	return {
		NotifyConsts.PlayerAttrChange,
		}
end;
function UIOperTips:HandleNotification(name,body)
	if body.type == enAttrType.eaLevel then
		self:IsToShowLevel()
	end;
end;