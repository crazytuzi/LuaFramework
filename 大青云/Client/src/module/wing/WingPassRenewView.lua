--[[翅膀续费面板
zhangshuhui
2015年10月16日11:41:11
]]

_G.UIWingPassRenewView = BaseUI:new("UIWingPassRenewView")

UIWingPassRenewView.id = 0;
UIWingPassRenewView.objUIDraw = nil;--3d渲染器

function UIWingPassRenewView:Create()
	self:AddSWF("wingPassRenewPanel.swf", true, "top")
end

function UIWingPassRenewView:OnLoaded(objSwf,name)
	--关闭
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end;
	
	--续费
	objSwf.btnrenew.click = function() self:OnBtnRenewClick() end
	
	--属性右对齐
	self.numAttrx = objSwf.numAttr._x
	objSwf.numAttr.loadComplete = function()
									objSwf.numAttr._x = self.numAttrx - objSwf.numAttr.width
								end
end

function UIWingPassRenewView:OnShow(name)
	--初始化数据
	self:InitData();
	--显示
	self:ShowWingRenewInfo();
end

function UIWingPassRenewView:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
	end
end

function UIWingPassRenewView:OnHide()
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
	end
end

function UIWingPassRenewView:GetHeight()
	return 388;
end

function UIWingPassRenewView:GetWidth()
	return 500;
end

--点击关闭按钮
function UIWingPassRenewView:OnBtnCloseClick()
	self:Hide();
end

--点击续费按钮
function UIWingPassRenewView:OnBtnRenewClick()
	self:Hide();
	UIVip:Show();
end

function UIWingPassRenewView:InitData()
end

function UIWingPassRenewView:Open(id)
	self.id = id;
	
	if self:IsShow() then
		self:InitData();
		self:ShowWingRenewInfo();
	else
		self:Show();
	end
end

--显示信息
function UIWingPassRenewView:ShowWingRenewInfo()
	self:ShowRenewInfo();
end

--显示续费信息
local viewTimePassPort;
function UIWingPassRenewView:ShowRenewInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self:ShowWingInfo();
end

function UIWingPassRenewView:ShowWingInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local cfg = t_wing[self.id];
	if not cfg then
		return;
	end
	objSwf.wingpanel._visible = true;
	if not self.objUIDraw then
		if not viewTimePassPort then viewTimePassPort = _Vector2.new(1500, 900); end
		self.objUIDraw = UISceneDraw:new( "UIWingPassRenewView", objSwf.modelload, viewTimePassPort);
	end
	self.objUIDraw:SetUILoader(objSwf.modelload);
	self.objUIDraw:SetScene( cfg.ui_pass_sen );
	self.objUIDraw:SetDraw( true );
	
	objSwf.numFight.num = cfg.fight.."a";
	objSwf.numAttr.num = "10";
end