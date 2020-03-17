--[[萌宠续费面板
zhangshuhui
2015年6月22日11:41:11
]]

_G.UILovelyPetPassRenewView = BaseUI:new("UILovelyPetPassRenewView")

UILovelyPetPassRenewView.id = 0;
UILovelyPetPassRenewView.objUIDraw = nil;--3d渲染器

function UILovelyPetPassRenewView:Create()
	self:AddSWF("lovelypetPassRenewPanel.swf", true, "top")
	self:AddChild(UILovelyPetRenewViewV, LovelyPetConsts.LOVELYPETRENEWV);
end

function UILovelyPetPassRenewView:OnLoaded(objSwf,name)
	self:GetChild(LovelyPetConsts.LOVELYPETRENEWV):SetContainer(objSwf.childPanel);
	--关闭
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end;
	
	--续费
	objSwf.btnrenew.click = function() self:OnBtnRenewClick() end
	
	objSwf.btnShop.click = function() self:OnBtnShopClick() end
	
	--属性右对齐
	self.numAttrx = objSwf.numAttr._x
	objSwf.numAttr.loadComplete = function()
									objSwf.numAttr._x = self.numAttrx - objSwf.numAttr.width
								end
end
--点击续费按钮
function UILovelyPetPassRenewView:OnBtnRenewClick()
	local lovelypetid = self.id;
	local lovelypettime,servertime = LovelyPetUtil:GetLovelyPetTime(lovelypetid);
	if lovelypettime == -1 then
		FloatManager:AddNormal( StrConfig["lovelypet27"]);
		return;
	end
	UILovelyPetRenewViewV.lovelypetid = lovelypetid;
	if not UILovelyPetRenewViewV.bShowState then
		self:ShowChild(LovelyPetConsts.LOVELYPETRENEWV);
	else
		UILovelyPetRenewViewV:Open();
	end
end
function UILovelyPetPassRenewView:OnShow(name)
	--初始化数据
	self:InitData();
	--显示
	self:ShowLovelyPetRenewInfo();
end

function UILovelyPetPassRenewView:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
	end
end

function UILovelyPetPassRenewView:OnHide()
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
	end
end

function UILovelyPetPassRenewView:GetHeight()
	return 388;
end

function UILovelyPetPassRenewView:GetWidth()
	return 500;
end

--点击关闭按钮
function UILovelyPetPassRenewView:OnBtnCloseClick()
	self:Hide();
end

--点击商店按钮
function UILovelyPetPassRenewView:OnBtnShopClick()
	self:Hide();
	UIShoppingMall:OpenPanel(1, 0);
end

function UILovelyPetPassRenewView:InitData()
end

function UILovelyPetPassRenewView:Open(id)
	self.id = id;
	
	if self:IsShow() then
		self:InitData();
		self:ShowLovelyPetRenewInfo();
	else
		self:Show();
	end
end

--显示信息
function UILovelyPetPassRenewView:ShowLovelyPetRenewInfo()
	self:ShowRenewInfo();
end

--显示续费信息
local viewTimePassPort;
function UILovelyPetPassRenewView:ShowRenewInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self:ShowLovelyPetInfo();
end

function UILovelyPetPassRenewView:ShowLovelyPetInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local lovelypetcfg = t_lovelypet[self.id];
	if not lovelypetcfg then
		return;
	end
	objSwf.lovelypetpanel._visible = true;
	if not self.objUIDraw then
		if not viewTimePassPort then viewTimePassPort = _Vector2.new(1400, 800); end
		self.objUIDraw = UISceneDraw:new( "UILovelyPetPassRenewView", objSwf.modelload, viewTimePassPort);
	end
	self.objUIDraw:SetUILoader(objSwf.modelload);
	self.objUIDraw:SetScene( lovelypetcfg.ui_xiuxian );
	-- if lovelypetcfg.ui_xiuxian then
		-- self.objUIDraw:NodeAnimation(lovelypetcfg.ui_node,lovelypetcfg.ui_xiuxian)
	-- end
	self.objUIDraw:SetDraw( true );
	
	objSwf.numFight.num = LovelyPetUtil:GetLovelyPetFight(self.id).."a";
	objSwf.numAttr.num = toint(t_buffeffect[t_buff[lovelypetcfg.buff_id].effect_1].func_param2 * 100);
end