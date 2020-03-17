--[[
VIP 福利面板
2015-7-24 16:56:53
haohu
]]
--------------------------------------------------------------

_G.UIVipInfo = BaseUI:new("UIVipInfo")
UIVipInfo.vipType = VipConsts.TYPE_GOLD
UIVipInfo.defaultCfg = {
	EyePos   = _Vector3.new(0,-60,25),
	LookPos  = _Vector3.new(1,0,20),
	VPort    = _Vector2.new( 1800, 1200 ),
	Rotation = 0
};
UIVipInfo.isJihuo = false
function UIVipInfo:Create()
	self:AddSWF("vipInfoPanel.swf", true, nil)
end

function UIVipInfo:OnLoaded( objSwf )
	-- RewardManager:RegisterListTips( objSwf.levelRewardList )
	objSwf.btnBack.click = function() UIVip:TurnToSubpanel( UIVip.TAB_RENEW ) end
	objSwf.btnJihuo.click = function() self:OnBtnRenewClick() end
	objSwf.btnJihuo.rollOver    = function() self:OnBtnRenewGoldRollOver1() end
	objSwf.btnJihuo.rollOut     = function() TipsManager:Hide() end
	
	objSwf.btnXufei.click = function() self:OnBtnXufeiClick() end
	objSwf.btnXufei.rollOver    = function() self:OnBtnRenewGoldRollOver() end
	objSwf.btnXufei.rollOut     = function() TipsManager:Hide() end
	
	objSwf.btnDesShow.rollOver = function() TipsManager:ShowItemTips(VipController:GetActAward(self.vipType)) end
	objSwf.btnDesShow.rollOut  = function() TipsManager:Hide() end
end

function UIVipInfo:OnBtnRenewGoldRollOver1()
	local restTime = VipModel:GetVipPeriod( self.vipType )
	local cfg = t_viptype[self.vipType]
	local yuanbao = cfg.price
	local useDay = cfg.duration
	local str =  ""
	str =  str..StrConfig['vip1']..yuanbao..StrConfig['vip2'].."<br/>"
	if useDay <= 0 then
		str =  str..StrConfig['vip3']..StrConfig['vip5'].."<br/>"
	elseif useDay >= UIVipRenew.FOREVER then
		str =  str..StrConfig['vip3']..StrConfig['vip113'].."<br/>"
	else	
		str =  str..StrConfig['vip3']..useDay..StrConfig['vip4'].."<br/>"
	end
	TipsManager:ShowBtnTips( str )
end

function UIVipInfo:OnBtnRenewGoldRollOver()
	local restTime = VipModel:GetVipPeriod( self.vipType )
	local cfg = t_viptype[self.vipType]
	local yuanbao = cfg.price_renew
	local useDay = cfg.duration_renew
	local str =  ""
	str =  str..StrConfig['vip1']..yuanbao..StrConfig['vip2'].."<br/>"
	if useDay <= 0 then
		str =  str..StrConfig['vip3']..StrConfig['vip5'].."<br/>"
	elseif useDay >= UIVipRenew.FOREVER then
		str =  str..StrConfig['vip3']..StrConfig['vip113'].."<br/>"
	else	
		str =  str..StrConfig['vip3']..useDay..StrConfig['vip4'].."<br/>"
	end
	TipsManager:ShowBtnTips( str )
end

function UIVipInfo:OnBtnRenewClick()
	if not Version:IsShowRechargeButton() then return; end
	local needyuanbao = t_viptype[self.vipType].price
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
		VipController:ReqRenewVip( self.vipType )	
	end
	local vipName = VipConsts:GetVipTypeName(self.vipType)
	
	if self.confirmID then
		UIConfirm:Close(self.confirmID);
	end
	UIConfirm:Open(StrConfig['vip7']..needyuanbao..StrConfig['vip8']..vipName..StrConfig['vip9'],func);
end


function UIVipInfo:OnBtnXufeiClick()
	if not Version:IsShowRechargeButton() then return; end
	local needyuanbao = t_viptype[self.vipType].price_renew
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
		VipController:ReqRenewVip( self.vipType )
	end
	local vipName = VipConsts:GetVipTypeName(self.vipType)
	
	if self.confirmID then
		UIConfirm:Close(self.confirmID);
	end
	UIConfirm:Open(StrConfig['vip7']..needyuanbao..StrConfig['vip10']..vipName..StrConfig['vip9'],func);
end

function UIVipInfo:Open(vipType)
	self.vipType = vipType
	if self.IsShow() then
		self:ShowWelfare( vipType )
	else	
		self:Show()
	end
end

function UIVipInfo:OnShow()	
	self:ShowWelfare( self.vipType )
end

function UIVipInfo:OnHide()
	local name = 'UIVipInfo'
	local objUIDraw = UIDrawManager:GetUIDraw(name);
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
	end
	
	if self.confirmID then
		UIConfirm:Close(self.confirmID);
	end
end

function UIVipInfo:OnDelete()
	-- local name = 'UIVipInfo'
	-- local objUIDraw = UIDrawManager:GetUIDraw(name);
	-- if objUIDraw then
		-- objUIDraw:SetUILoader(nil);
	-- end
end

function UIVipInfo:ShowWelfare( vipType )
	local objSwf = self.objSwf
	if not objSwf then return end
	local cfg = _G.t_viptype[ vipType ]
	if not cfg then return end
	-- objSwf.levelRewardList.dataProvider:cleanUp()
	-- objSwf.levelRewardList.dataProvider:push( unpack( RewardManager:Parse( cfg.reward ) ) )
	-- objSwf.levelRewardList:invalidateData()
	objSwf.mcVipType:gotoAndStop(vipType)
	-- objSwf.txtDes1.text = cfg.des1
	-- objSwf.txtDes2.text = cfg.des2
	-- objSwf.txtDes3.text = cfg.des3
	objSwf.load_info.source = ResUtil:GetVipshowIcon(vipType);
	-- if cfg.image1 then
		-- objSwf.vipShowImage1.source = ResUtil:GetVipshowIcon(cfg.image1)
	-- end
	-- if cfg.image2 then
		-- objSwf.vipShowImage2.source = ResUtil:GetVipshowIcon(cfg.image2)
	-- end
	-- if cfg.image3 then
		-- objSwf.vipShowImage3.source = ResUtil:GetVipshowIcon(cfg.image3)
	-- end
	
	-- objSwf.btnJihuo.disabled = true
	-- if VipModel:GetVipPeriod( vipType ) == 0 or VipModel:GetVipPeriod( vipType ) == -1 then
		-- objSwf.btnJihuo.disabled = false
	-- end
	objSwf.btnJihuo.disabled = false
	objSwf.btnXufei.disabled = false
	local vipTime = VipModel:GetVipPeriod( vipType )
	if vipTime == -1 then
		objSwf.btnJihuo.visible = true
		objSwf.btnXufei.visible = false
		objSwf.txtTime.text = ""
	elseif vipTime == 0 then
		objSwf.btnJihuo.visible = false
		objSwf.btnXufei.visible = true
		objSwf.txtTime.text = StrConfig['vip114']
	else
		objSwf.btnJihuo.visible = false
		objSwf.btnXufei.visible = true
		local useDay = VipController:GetOpenLastTime(vipTime)
		
		if useDay <= 0 then
			objSwf.txtTime.text = StrConfig['vip115']..StrConfig['vip5']
		elseif useDay >= UIVipRenew.FOREVER then
			objSwf.txtTime.text = StrConfig['vip116']
			objSwf.btnJihuo.disabled = true
			objSwf.btnXufei.disabled = true
			objSwf.mcEffect._visible = false
		else		
			objSwf.txtTime.text = StrConfig['vip115']..useDay..StrConfig['vip117']
		end
	end
	
	objSwf.mcIsActiveVip._visible = vipTime == -1 and true or false
	
	self:Show3DWeapon(cfg.id)	
end

function UIVipInfo:ListNotificationInterests()
	return { NotifyConsts.VipPeriod,
			 NotifyConsts.VipJihuoEffect}
end

function UIVipInfo:HandleNotification( name, body )
	if not self:IsShow() then return end
	if name == NotifyConsts.VipPeriod then
		self:ShowWelfare( self.vipType )	
	elseif name == NotifyConsts.VipJihuoEffect then
		if self.isJihuo then
			self.isJihuo = false
			self:GoRewardfun(body.vipType, self.objSwf.btnJihuo)			
		end
	end				
	
end

function UIVipInfo:Show3DWeapon(typeID)
	local objSwf = self.objSwf
	if not objSwf then return end
	
	local cfg = t_viptype[ typeID ]
	if not cfg then return end
	
	local loader = objSwf.roleLoader
	local name      = 'UIVipInfo'
	if not self.objUIDraw then
		self.objUIDraw = UISceneDraw:new( name, loader, _Vector2.new(1800, 1200), true);
	end
	
	self.objUIDraw:SetUILoader( loader )
	
	local src = cfg.model_sen;
	local prof = MainPlayerModel.humanDetailInfo.eaProf;
	src = split(cfg.model_sen,'#')[prof];
	if not src then return end
	self.objUIDraw:SetScene(src);
	
	self.objUIDraw:SetDraw(true);
end

function UIVipInfo:GoRewardfun(vipType, vipbtn)
	local startPos = UIManager:PosLtoG(vipbtn,0,0);
	--奖励
	local prof = MainPlayerModel.humanDetailInfo.eaProf; --取玩家职业
	local rewardList = RewardManager:ParseToVO(t_viptype[vipType]['reward'..prof]);
	local startPos = UIManager:PosLtoG(vipbtn,0,0);
	RewardManager:FlyIcon(rewardList,startPos,5,true,60);
	SoundManager:PlaySfx(2041);
end;