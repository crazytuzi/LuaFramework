--[[
VIP 续费面板
2015-7-24 16:55:00
haohu
]]
--------------------------------------------------------------

_G.UIVipRenew = BaseUI:new("UIVipRenew")
UIVipRenew.FOREVER = 3*365
UIVipRenew.defaultCfg = {
	EyePos   = _Vector3.new(0,-70,25),
	LookPos  = _Vector3.new(1,0,20),
	VPort    = _Vector2.new( 1800, 1200 ),
	Rotation = 0
};
UIVipRenew.isJihuo = false

function UIVipRenew:Create()
	self:AddSWF("vipRenewPanel.swf", true, nil)
end

function UIVipRenew:OnLoaded( objSwf )
	objSwf.btnRenewGoldVip.click       = function() self:OnBtnRenewGoldClick() end
	objSwf.btnRenewDiamondVip.click    = function() self:OnBtnRenewDiamondClick() end
	objSwf.btnRenewSupremeVip.click    = function() self:OnBtnRenewSupremeClick() end
	objSwf.btnRenewGoldVip.rollOver    = function() self:OnBtnRenewGoldRollOver1() end
	objSwf.btnRenewDiamondVip.rollOver = function() self:OnBtnRenewDiamondRollOver1() end
	objSwf.btnRenewSupremeVip.rollOver = function() self:OnBtnRenewSupremeRollOver1() end
	objSwf.btnRenewGoldVip.rollOut     = function() self:OnBtnRenewRollOut() end
	objSwf.btnRenewDiamondVip.rollOut  = function() self:OnBtnRenewRollOut() end
	objSwf.btnRenewSupremeVip.rollOut  = function() self:OnBtnRenewRollOut() end
	
	objSwf.btnXufeiRenewGoldVip.click       = function() self:OnBtnXufeiGoldClick() end
	objSwf.btnXufeiRenewDiamondVip.click    = function() self:OnBtnXufeiDiamondClick() end
	objSwf.btnXufeiSupremeVip.click    = function() self:OnBtnXufeiSupremeClick() end	
	objSwf.btnXufeiRenewGoldVip.rollOver    = function() self:OnBtnRenewGoldRollOver() end
	objSwf.btnXufeiRenewDiamondVip.rollOver = function() self:OnBtnRenewDiamondRollOver() end
	objSwf.btnXufeiSupremeVip.rollOver = function() self:OnBtnRenewSupremeRollOver() end
	objSwf.btnXufeiRenewGoldVip.rollOut     = function() self:OnBtnRenewRollOut() end
	objSwf.btnXufeiRenewDiamondVip.rollOut  = function() self:OnBtnRenewRollOut() end
	objSwf.btnXufeiSupremeVip.rollOut  = function() self:OnBtnRenewRollOut() end
	
	self.roleLoaders = { objSwf.loader1, objSwf.loader2, objSwf.loader3 };
	table.foreach( self.roleLoaders, function(_, loader) loader.hitTestDisable = true; end );	
	
	-- objSwf.btnVipInfo1.click = function()
		-- if UIVip.currentTab == UIVip.TAB_RENEW then
			-- UIVipInfo.vipType = VipConsts.TYPE_SUPREME
			-- UIVip:TurnToSubpanel( UIVip.TAB_INFO )
		-- end
	-- end
	
	-- objSwf.btnVipInfo2.click = function()
		-- if UIVip.currentTab == UIVip.TAB_RENEW then
			-- UIVipInfo.vipType = VipConsts.TYPE_DIAMOND
			-- UIVip:TurnToSubpanel( UIVip.TAB_INFO )
		-- end
	-- end
	
	-- objSwf.btnVipInfo3.click = function()
		-- if UIVip.currentTab == UIVip.TAB_RENEW then
			-- UIVipInfo.vipType = VipConsts.TYPE_GOLD
			-- UIVip:TurnToSubpanel( UIVip.TAB_INFO )
		-- end
	-- end
	objSwf.btnVipInfo1.rollOver = function() TipsManager:ShowItemTips(VipController:GetActAward(VipConsts.TYPE_SUPREME)) end
	objSwf.btnVipInfo1.rollOut  = function() TipsManager:Hide() end
	objSwf.btnVipInfo3.rollOver = function() TipsManager:ShowItemTips(VipController:GetActAward(VipConsts.TYPE_GOLD)) end
	objSwf.btnVipInfo3.rollOut  = function() TipsManager:Hide() end
	objSwf.btnVipInfo2.rollOver = function() TipsManager:ShowItemTips(VipController:GetActAward(VipConsts.TYPE_DIAMOND)) end
	objSwf.btnVipInfo2.rollOut  = function() TipsManager:Hide() end
end

function UIVipRenew:OnHide()
	-- for i = 1, 3 do
		-- local name = 'vip'..i
		-- local objUIDraw = UIDrawManager:GetUIDraw(name);
		-- if objUIDraw then
			-- if objUIDraw.objEntity then
				-- objUIDraw.objEntity:ExitMap();
			-- end
			-- objUIDraw:SetMesh( nil );
			-- objUIDraw:SetDraw(false);
		-- end
	-- end	
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
	end
	
	if self.confirmID then
		UIConfirm:Close(self.confirmID);
	end
end


function UIVipRenew:OnDelete()
	-- for i=1, 3 do
		-- local name = 'vip'..i
		-- local objUIDraw = UIDrawManager:GetUIDraw(name);
		-- if objUIDraw then
			-- objUIDraw:SetUILoader(nil);
		-- end
	-- end
	-- for k,_ in pairs(self.memberDisplays) do
		-- self.memberDisplays[k] = nil;
	-- end
	for k,_ in pairs(self.roleLoaders) do
		self.roleLoaders[k] = nil;
	end
end

function UIVipRenew:OnShow()
	
	self:UpdateShow()
	self:Show3DWeapon(1, t_viptype[VipConsts.TYPE_SUPREME].model_sen)	
	self:Show3DWeapon(2, t_viptype[VipConsts.TYPE_DIAMOND].model_sen)	
	self:Show3DWeapon(3, t_viptype[VipConsts.TYPE_GOLD].model_sen)	
end

function UIVipRenew:UpdateShow()
	local objSwf = self.objSwf
	if not objSwf then return end
	--消耗文本
	objSwf.txtTask1._visible = true
	objSwf.txtTask2._visible = true
	objSwf.txtTask3._visible = true
	objSwf.yuanbao1._visible = true
	objSwf.yuanbao2._visible = true
	objSwf.yuanbao3._visible = true
	local myYuanbao =  MainPlayerModel.humanDetailInfo.eaUnBindMoney
	local cfg1 = t_viptype[VipConsts.TYPE_SUPREME]
	local yuanbao1 = cfg1.price
	if myYuanbao > yuanbao1 then
		objSwf.txtTask1.htmlText  = string.format(StrConfig['vip136'],yuanbao1)
	else
		objSwf.txtTask1.htmlText  = string.format(StrConfig['vip137'],yuanbao1)
	end
	
	local cfg2 = t_viptype[VipConsts.TYPE_DIAMOND]
	local yuanbao2 = cfg2.price
	if myYuanbao > yuanbao2 then
		objSwf.txtTask2.htmlText  = string.format(StrConfig['vip136'],yuanbao2)
	else
		objSwf.txtTask2.htmlText  = string.format(StrConfig['vip137'],yuanbao2)
	end
	
	local cfg3 = t_viptype[VipConsts.TYPE_GOLD]
	local yuanbao3 = cfg3.price
	if myYuanbao > yuanbao3 then
		objSwf.txtTask3.htmlText  = string.format(StrConfig['vip136'],yuanbao3)
	else
		objSwf.txtTask3.htmlText  = string.format(StrConfig['vip137'],yuanbao3)
	end
	--永久激活
	objSwf.forever1._visible = false
	objSwf.forever2._visible = false
	objSwf.forever3._visible = false
	
	local GoldTime = VipModel:GetVipPeriod( VipConsts.TYPE_GOLD )--黄金
	objSwf.btnRenewGoldVip.disabled = false
	objSwf.btnXufeiRenewGoldVip.disabled = false
	if GoldTime == -1 then--未激活
		objSwf.btnRenewGoldVip.visible = true
		objSwf.btnXufeiRenewGoldVip.visible = false
		objSwf.txtHuangjin.text = ""
	elseif GoldTime == 0 then--已到期
		objSwf.btnRenewGoldVip.visible = false
		objSwf.btnEffect2._visible = false
		objSwf.btnXufeiRenewGoldVip.visible = true
		objSwf.txtHuangjin.text = "已到期"
	else
		objSwf.btnRenewGoldVip.visible = false
		objSwf.btnEffect2._visible = false
		objSwf.btnXufeiRenewGoldVip.visible = true
		-- objSwf.txtHuangjin.text = "有效时间:"..VipController:GetOpenLastTime(GoldTime).."天"
		
		local useDay = VipController:GetOpenLastTime(GoldTime)		
		if useDay <= 0 then--有效时间小于1天
			objSwf.txtHuangjin.text = StrConfig['vip115']..StrConfig['vip5']
		elseif useDay >= UIVipRenew.FOREVER then--已永久激活
			objSwf.txtHuangjin.text = StrConfig['vip116']
			objSwf.btnRenewGoldVip.disabled = false
			objSwf.btnXufeiRenewGoldVip.disabled = true
			objSwf.mcEffect2._visible = false
			objSwf.btnEffect2._visible = false
			objSwf.txtTask3._visible = false
			objSwf.yuanbao3._visible = false
			objSwf.forever3._visible = true
		else--未过期
			objSwf.txtHuangjin.text = StrConfig['vip115']..useDay..StrConfig['vip117']
		end
	end
	
	local DiamondTime = VipModel:GetVipPeriod( VipConsts.TYPE_DIAMOND )
	objSwf.btnRenewDiamondVip.disabled = false
	objSwf.btnXufeiRenewDiamondVip.disabled = false
	if DiamondTime == -1 then
		objSwf.btnRenewDiamondVip.visible = true
		objSwf.btnXufeiRenewDiamondVip.visible = false
		objSwf.txtZuanshi.text = ""
	elseif DiamondTime == 0 then
		objSwf.btnRenewDiamondVip.visible = false
		objSwf.btnEffect3._visible = false
		objSwf.btnXufeiRenewDiamondVip.visible = true
		objSwf.txtZuanshi.text = StrConfig['vip114']
	else
		objSwf.btnRenewDiamondVip.visible = false
		objSwf.btnEffect3._visible = false
		objSwf.btnXufeiRenewDiamondVip.visible = true
		-- objSwf.txtZuanshi.text = "有效时间:"..VipController:GetOpenLastTime(DiamondTime).."天"
		local useDay = VipController:GetOpenLastTime(DiamondTime)		
		if useDay <= 0 then
			objSwf.txtZuanshi.text = StrConfig['vip115']..StrConfig['vip5']
		elseif useDay >= UIVipRenew.FOREVER then
			objSwf.txtZuanshi.text = StrConfig['vip116']
			objSwf.btnRenewDiamondVip.disabled = true
			objSwf.btnXufeiRenewDiamondVip.disabled = true
			objSwf.mcEffect3._visible = false
			objSwf.btnEffect3._visible = false
			objSwf.txtTask2._visible = false
			objSwf.yuanbao2._visible = false
			objSwf.forever2._visible = true
		else
			objSwf.txtZuanshi.text = StrConfig['vip115']..useDay..StrConfig['vip117']
		end
	end
	
	local SupremeTime = VipModel:GetVipPeriod( VipConsts.TYPE_SUPREME )
	FPrint('SupremeTime'..SupremeTime)
	objSwf.btnRenewSupremeVip.disabled = false
	objSwf.btnXufeiSupremeVip.disabled = false
	if SupremeTime == -1 then
		objSwf.btnRenewSupremeVip.visible = true
		objSwf.btnXufeiSupremeVip.visible = false
		objSwf.txtBaiying.text = ""
	elseif SupremeTime == 0 then
		objSwf.btnRenewSupremeVip.visible = false
		objSwf.btnEffect1._visible = false
		objSwf.btnXufeiSupremeVip.visible = true
		objSwf.txtBaiying.text = StrConfig['vip114']
	else
		objSwf.btnRenewSupremeVip.visible = false
		objSwf.btnEffect1._visible = false
		objSwf.btnXufeiSupremeVip.visible = true
		-- objSwf.txtBaiying.text = "有效时间:"..VipController:GetOpenLastTime(SupremeTime).."天"
		local useDay = VipController:GetOpenLastTime(SupremeTime)		
		if useDay <= 0 then
			objSwf.txtBaiying.text = StrConfig['vip115']..StrConfig['vip5']
		elseif useDay >= UIVipRenew.FOREVER then
			objSwf.txtBaiying.text = StrConfig['vip116']
			objSwf.btnRenewSupremeVip.disabled = true
			objSwf.btnXufeiSupremeVip.disabled = true
			objSwf.mcEffect1._visible = false
			objSwf.btnEffect1._visible = false
			objSwf.txtTask1._visible = false
			objSwf.yuanbao1._visible = false
			objSwf.forever1._visible = true
		else
			objSwf.txtBaiying.text = StrConfig['vip115']..useDay..StrConfig['vip117']
		end
	end
	
	objSwf.mcIsActiveGoldVip._visible = GoldTime == -1 and true or false
	objSwf.mcIsActiveDiamondVip._visible = DiamondTime == -1 and true or false
	objSwf.mcIsActiveSupremeVip._visible = SupremeTime == -1 and true or false
end

function UIVipRenew:OnBtnRenewGoldClick()
	if not Version:IsShowRechargeButton() then return; end
	local needyuanbao = t_viptype[VipConsts.TYPE_GOLD].price
	local myYuanbao =  MainPlayerModel.humanDetailInfo.eaUnBindMoney
	if myYuanbao < needyuanbao then
		local chargefunc = function ()
			Version:Charge()
		end
		if self.confirmID then
			UIConfirm:Close(self.confirmID);
		end
		self.confirmID = UIConfirm:Open(StrConfig['vip6'],chargefunc,nil,StrConfig['vip20']);
		return
	end
	
	local func = function ()
		self.isJihuo = true
		VipController:ReqRenewVip( VipConsts.TYPE_GOLD )
	end
	
	if self.confirmID then
		UIConfirm:Close(self.confirmID);
	end	
	self.confirmID = UIConfirm:Open(string.format(StrConfig['vip119'], needyuanbao),func);
	-- self.confirmID = UIConfirm:Open("是否花费"..needyuanbao.."元宝，激活黄金VIP",func);
end

function UIVipRenew:OnBtnRenewDiamondClick()
	if not Version:IsShowRechargeButton() then return; end
	local needyuanbao = t_viptype[VipConsts.TYPE_DIAMOND].price
	local myYuanbao =  MainPlayerModel.humanDetailInfo.eaUnBindMoney
	if myYuanbao < needyuanbao then
		local chargefunc = function ()
			Version:Charge()
		end
		if self.confirmID then
			UIConfirm:Close(self.confirmID);
		end
		self.confirmID = UIConfirm:Open(StrConfig['vip6'],chargefunc,nil,StrConfig['vip20']);
		return
	end
	local func = function ()
		self.isJihuo = true
		VipController:ReqRenewVip( VipConsts.TYPE_DIAMOND )
	end
	
	if self.confirmID then
		UIConfirm:Close(self.confirmID);
	end
	self.confirmID = UIConfirm:Open(string.format(StrConfig['vip120'], needyuanbao),func);
	-- self.confirmID = UIConfirm:Open("是否花费"..needyuanbao.."元宝，激活钻石VIP",func);
end

function UIVipRenew:OnBtnRenewSupremeClick()
	if not Version:IsShowRechargeButton() then return; end
	local needyuanbao = t_viptype[VipConsts.TYPE_SUPREME].price
	local myYuanbao =  MainPlayerModel.humanDetailInfo.eaUnBindMoney
	if myYuanbao < needyuanbao then
		local chargefunc = function ()
			Version:Charge()
		end
		if self.confirmID then
			UIConfirm:Close(self.confirmID);
		end
		self.confirmID = UIConfirm:Open(StrConfig['vip6'],chargefunc,nil,StrConfig['vip20']);
		return
	end
	local func = function ()
		self.isJihuo = true
		VipController:ReqRenewVip( VipConsts.TYPE_SUPREME )
		
	end
	
	if self.confirmID then
		UIConfirm:Close(self.confirmID);
	end
	
	self.confirmID = UIConfirm:Open(string.format(StrConfig['vip121'], needyuanbao),func);
	-- self.confirmID = UIConfirm:Open("是否花费"..needyuanbao.."元宝，激活白银VIP",func);
end

function UIVipRenew:OnBtnXufeiGoldClick()
	if not Version:IsShowRechargeButton() then return; end
	local needyuanbao = t_viptype[VipConsts.TYPE_GOLD].price_renew
	local myYuanbao =  MainPlayerModel.humanDetailInfo.eaUnBindMoney
	if myYuanbao < needyuanbao then		
		local chargefunc = function ()
			Version:Charge()
		end
		if self.confirmID then
			UIConfirm:Close(self.confirmID);
		end
		self.confirmID = UIConfirm:Open(StrConfig['vip6'],chargefunc,nil,StrConfig['vip20']);
		return
	end
	
	local func = function ()
		VipController:ReqRenewVip( VipConsts.TYPE_GOLD )
	end
	
	if self.confirmID then
		UIConfirm:Close(self.confirmID);
	end
	
	self.confirmID = UIConfirm:Open(string.format(StrConfig['vip122'], needyuanbao),func);
	-- self.confirmID = UIConfirm:Open("是否花费"..needyuanbao.."元宝，续费黄金VIP",func);
end

function UIVipRenew:OnBtnXufeiDiamondClick()
	if not Version:IsShowRechargeButton() then return; end
	local needyuanbao = t_viptype[VipConsts.TYPE_DIAMOND].price_renew
	local myYuanbao =  MainPlayerModel.humanDetailInfo.eaUnBindMoney
	if myYuanbao < needyuanbao then
		local chargefunc = function ()
			Version:Charge()
		end
		if self.confirmID then
			UIConfirm:Close(self.confirmID);
		end
		self.confirmID = UIConfirm:Open(StrConfig['vip6'],chargefunc,nil,StrConfig['vip20']);
		return
	end
	local func = function ()
		VipController:ReqRenewVip( VipConsts.TYPE_DIAMOND )
	end
	
	if self.confirmID then
		UIConfirm:Close(self.confirmID);
	end
	
	self.confirmID = UIConfirm:Open(string.format(StrConfig['vip123'], needyuanbao),func);
	-- self.confirmID = UIConfirm:Open("是否花费"..needyuanbao.."元宝，续费钻石VIP",func);
end

function UIVipRenew:OnBtnXufeiSupremeClick()
	if not Version:IsShowRechargeButton() then return; end
	local needyuanbao = t_viptype[VipConsts.TYPE_SUPREME].price_renew
	local myYuanbao =  MainPlayerModel.humanDetailInfo.eaUnBindMoney
	if myYuanbao < needyuanbao then
		local chargefunc = function ()
			Version:Charge()
		end
		if self.confirmID then
			UIConfirm:Close(self.confirmID);
		end
		self.confirmID = UIConfirm:Open(StrConfig['vip6'],chargefunc,nil,StrConfig['vip20']);
		return
	end
	local func = function ()
		VipController:ReqRenewVip( VipConsts.TYPE_SUPREME )
	end
	
	if self.confirmID then
		UIConfirm:Close(self.confirmID);
	end
	
	self.confirmID = UIConfirm:Open(string.format(StrConfig['vip124'], needyuanbao),func);
	-- self.confirmID = UIConfirm:Open("是否花费"..needyuanbao.."元宝，续费白银VIP",func);
end

function UIVipRenew:OnBtnRenewGoldRollOver()
	local restTime = VipModel:GetVipPeriod( VipConsts.TYPE_GOLD )
	local txt = restTime > 0 and "延长" or ""
	local cfg = t_viptype[VipConsts.TYPE_GOLD]
	local yuanbao = cfg.price_renew
	local useDay = cfg.duration_renew
	local str =  ""
	str =  str.."<font color='#e59607'>".. StrConfig['vip1'] .."</font>"..yuanbao..StrConfig['vip2'].."<br/>"
	if useDay >= UIVipRenew.FOREVER then
		str =  str.."<font color='#e59607'>".. StrConfig['vip3'] .."</font>".. StrConfig['vip113'] .."<br/>"
	else
		str =  str.."<font color='#e59607'>".. StrConfig['vip3'] .."</font>" .. txt ..useDay..StrConfig['vip4'].."<br/>"
	end
	TipsManager:ShowBtnTips( str )
end

function UIVipRenew:OnBtnRenewDiamondRollOver()
	local restTime = VipModel:GetVipPeriod( VipConsts.TYPE_DIAMOND )
	local txt = restTime > 0 and "延长" or ""
	local cfg = t_viptype[VipConsts.TYPE_DIAMOND]
	local yuanbao = cfg.price_renew
	local useDay = cfg.duration_renew
	local str =  ""
	str =  str.."<font color='#e59607'>".. StrConfig['vip1'] .."</font>"..yuanbao..StrConfig['vip2'].."<br/>"
	if useDay >= UIVipRenew.FOREVER then
		str =  str.."<font color='#e59607'>".. StrConfig['vip3'] .."</font>".. StrConfig['vip113'] .."<br/>"
	else
		str =  str.."<font color='#e59607'>".. StrConfig['vip3'] .."</font>" .. txt ..useDay..StrConfig['vip4'].."<br/>"
	end
	TipsManager:ShowBtnTips( str )
end

function UIVipRenew:OnBtnRenewSupremeRollOver()
	local restTime = VipModel:GetVipPeriod( VipConsts.TYPE_SUPREME )
	local txt = restTime > 0 and StrConfig['vip125'] or ""
	local cfg = t_viptype[VipConsts.TYPE_SUPREME]
	local yuanbao = cfg.price_renew
	local useDay = cfg.duration_renew
	local str =  ""
	str =  str.."<font color='#e59607'>".. StrConfig['vip1'] .."</font>"..yuanbao..StrConfig['vip2'].."<br/>"
	if useDay >= UIVipRenew.FOREVER then
		str =  str.."<font color='#e59607'>".. StrConfig['vip3'] .."</font>".. StrConfig['vip113'] .."<br/>"
	else
		str =  str.."<font color='#e59607'>".. StrConfig['vip3'] .."</font>"..txt..useDay..StrConfig['vip4'].."<br/>"
	end
	TipsManager:ShowBtnTips( str )
end

function UIVipRenew:OnBtnRenewRollOut()
	TipsManager:Hide()
end

function UIVipRenew:ListNotificationInterests()
	return { NotifyConsts.VipPeriod,
			NotifyConsts.PlayerAttrChange,
			 NotifyConsts.VipJihuoEffect}
end

function UIVipRenew:HandleNotification( name, body )
	if not self:IsShow() then return end
	if name == NotifyConsts.VipPeriod then
		self:UpdateShow()		
	elseif name == NotifyConsts.VipJihuoEffect then
		
		if self.isJihuo then
			self.isJihuo = false
			if body.vipType == VipConsts.TYPE_SUPREME then
				self:GoRewardfun(VipConsts.TYPE_SUPREME, self.objSwf.btnRenewSupremeVip)
			elseif body.vipType == VipConsts.TYPE_GOLD then
				self:GoRewardfun(VipConsts.TYPE_GOLD, self.objSwf.btnRenewGoldVip)
			elseif body.vipType == VipConsts.TYPE_DIAMOND then
				self:GoRewardfun(VipConsts.TYPE_DIAMOND, self.objSwf.btnRenewDiamondVip)
			end
		end
	elseif name == NotifyConsts.PlayerAttrChange then
		if body.type==enAttrType.eaUnBindMoney then
			self:UpdateShow();
		end
	end				
end

function UIVipRenew:Show3DWeapon(index, modelId)	
	-- local loader = self.roleLoaders[index];
	-- local name      = 'vip'..index
	-- local drawCfg   = UIDrawVipCfg[toint(modelId)] or self.defaultCfg;
	-- local cameraPos = drawCfg.EyePos;
	-- local lookPos   = drawCfg.LookPos;
	-- local vport     = drawCfg.VPort;
	-- local objAvatar = VipAvatar:new(modelId)
	-- local objUIDraw = UIDrawManager:GetUIDraw( name );
	-- if not objUIDraw then
		-- objUIDraw = UIDraw:new( name, objAvatar, loader, vport, cameraPos, lookPos, 0x00000000);
	-- else
		-- objUIDraw:SetUILoader(loader);
		-- objUIDraw:SetCamera( vport, cameraPos, lookPos );
		-- objUIDraw:SetMesh( objAvatar );
	-- end
	-- objAvatar.objMesh.transform:setRotation( 0, 0, 1, drawCfg.Rotation );
	
	-- objUIDraw:SetDraw(true);
	local objSwf = self.objSwf;
	if not objSwf then return end
	
	local name      = 'UIVipRenew' .. index
	if not self.objUIDraw then
		self.objUIDraw = UISceneDraw:new( name, objSwf.loader, _Vector2.new(1800, 1200), true);
	end
	
	self.objUIDraw:SetUILoader( objSwf.loader )
	local prof = MainPlayerModel.humanDetailInfo.eaProf;
	local src = split(t_viptype[1].model_firstsen,'#')[prof];
	self.objUIDraw:SetScene(src);
	
	self.objUIDraw:SetDraw(true);
end

function UIVipRenew:OnBtnRenewGoldRollOver1()
	local restTime = VipModel:GetVipPeriod( VipConsts.TYPE_GOLD )
	local cfg = t_viptype[VipConsts.TYPE_GOLD]
	local yuanbao = cfg.price
	local useDay = cfg.duration
	local str =  ""
	str =  str.."<font color='#e59607'>".. StrConfig['vip1'] .."</font>"..yuanbao..StrConfig['vip2'].."<br/>"
	if useDay >= UIVipRenew.FOREVER then
		str =  str.."<font color='#e59607'>".. StrConfig['vip3'] .."</font>".. StrConfig['vip113'] .."<br/>"
	else
		str =  str.."<font color='#e59607'>".. StrConfig['vip3'] .."</font>"..useDay..StrConfig['vip4'].."<br/>"
	end
	TipsManager:ShowBtnTips( str )
end

function UIVipRenew:OnBtnRenewDiamondRollOver1()
	local restTime = VipModel:GetVipPeriod( VipConsts.TYPE_DIAMOND )
	local cfg = t_viptype[VipConsts.TYPE_DIAMOND]
	local yuanbao = cfg.price
	local useDay = cfg.duration
	local str =  ""
	str =  str.."<font color='#e59607'>".. StrConfig['vip1'] .."</font>"..yuanbao..StrConfig['vip2'].."<br/>"
	if useDay >= UIVipRenew.FOREVER then
		str =  str.."<font color='#e59607'>".. StrConfig['vip3'] .."</font>".. StrConfig['vip113'] .."<br/>"
	else
		str =  str.."<font color='#e59607'>".. StrConfig['vip3'] .."</font>"..useDay..StrConfig['vip4'].."<br/>"
	end
	TipsManager:ShowBtnTips( str )
end

function UIVipRenew:OnBtnRenewSupremeRollOver1()
	local restTime = VipModel:GetVipPeriod( VipConsts.TYPE_SUPREME )
	local cfg = t_viptype[VipConsts.TYPE_SUPREME]
	local yuanbao = cfg.price
	local useDay = cfg.duration
	local str =  ""
	str =  str.."<font color='#e59607'>".. StrConfig['vip1'] .."</font>"..yuanbao..StrConfig['vip2'].."<br/>"
	if useDay >= UIVipRenew.FOREVER then
		str =  str.."<font color='#e59607'>".. StrConfig['vip3'] .."</font>".. StrConfig['vip113'] .."<br/>"
	else
		str =  str.."<font color='#e59607'>".. StrConfig['vip3'] .."</font>"..useDay..StrConfig['vip4'].."<br/>"
	end
	TipsManager:ShowBtnTips( str )
end

function UIVipRenew:GoRewardfun(vipType, vipbtn)
	local startPos = UIManager:PosLtoG(vipbtn,0,0);
	--奖励
	local prof = MainPlayerModel.humanDetailInfo.eaProf; --取玩家职业
	local rewardList = RewardManager:ParseToVO(t_viptype[vipType]['reward'..prof]);
	local startPos = UIManager:PosLtoG(vipbtn,0,0);
	RewardManager:FlyIcon(rewardList,startPos,5,true,60);
	SoundManager:PlaySfx(2041);
end;