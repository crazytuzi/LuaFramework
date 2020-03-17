--[[萌宠Tip面板
zhangshuhui
2015年6月24日11:41:11
]]

_G.UILovelyPetTipView = BaseUI:new("UILovelyPetTipView")

UILovelyPetTipView.objUIDraw = nil;--3d渲染器

function UILovelyPetTipView:Create()
	self:AddSWF("lovelypetTipPanel.swf", true, "top")
end

function UILovelyPetTipView:OnLoaded(objSwf,name)
end

function UILovelyPetTipView:OnShow(name)
	--显示
	self:ShowLovelyPetInfo();
	self:DrawLovelyPet();
	self:UpdatePos();
end

function UILovelyPetTipView:UpdatePos()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local monsePos = _sys:getRelativeMouse();--获取鼠标位置
	self.posX = monsePos.x;
	self.posY = monsePos.y;
	objSwf._x = monsePos.x + 25;
	objSwf._y = monsePos.y + 26;
end

function UILovelyPetTipView:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
	end
end

function UILovelyPetTipView:OnHide()
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
	end
end

function UILovelyPetTipView:ShowLovelyPetInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local petcfg = t_lovelypet[1];
	if not petcfg then
		return;
	end
	
	objSwf.tfget.text = string.format( StrConfig['lovelypet10'], petcfg.getcondition);
	
	objSwf.tfinfo.htmlText = StrConfig['lovelypet11'];
end

function UILovelyPetTipView:HandleNotification(name,body)
	if name == NotifyConsts.StageMove then
		local objSwf = self.objSwf;
		if not objSwf then return; end
		local monsePos = _sys:getRelativeMouse();--获取鼠标位置
		if self.posX ~= monsePos.x or self.posY ~= monsePos.y then
			self.posX = monsePos.x;
			self.posY = monsePos.y;
			objSwf._x = monsePos.x + 25;
			objSwf._y = monsePos.y + 26;
			self:Top();
		end
	end
end

function UILovelyPetTipView:ListNotificationInterests()
	return {NotifyConsts.StageMove};
end

local viewLovelyPetUpPort;
function UILovelyPetTipView : DrawLovelyPet()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local petcfg = t_lovelypet[1];
	if not petcfg then
		Error("Cannot find config of petcfg id:"..1);
		return;
	end
	if not self.objUIDraw then
		if not viewLovelyPetUpPort then viewLovelyPetUpPort = _Vector2.new(270, 475); end
		self.objUIDraw = UISceneDraw:new( "UILovelyPetTipView", objSwf.modelload, viewLovelyPetUpPort);
	end
	self.objUIDraw:SetUILoader( objSwf.modelload );
	
	if petcfg.ui_up_sen and petcfg.ui_up_sen ~= "" then
		self.objUIDraw:SetScene( petcfg.ui_up_sen );
		self.objUIDraw:SetDraw( true );
	end
end;