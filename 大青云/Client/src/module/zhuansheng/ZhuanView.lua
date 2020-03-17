--[[
转生view
wangshuai
]]

_G.UIZhuanSheng = BaseUI:new("UIZhuanSheng")

function UIZhuanSheng:Create()
	self:AddSWF("zhuanshengpanel.swf",true,'center')
end;

function UIZhuanSheng:OnLoaded(objSwf)
	objSwf.closebtn.click = function() self:Hide()end;
	objSwf.goZhuan.click = function() self:GoZhuansheng()end;
	-- objSwf.moneyZhuan.click = function() self:MoneyZhuan()end;
	-- objSwf.moneyZhuan.rollOver = function() self:MoneyZhuanOver()end;
	-- objSwf.moneyZhuan.rollOut = function() TipsManager:Hide()end;
end;

function UIZhuanSheng:OnShow()
	self:DrawModel();
	self:SetUifight();
	self:SetCanZhuan()
	self:SetZhuanImg();
	self:Set3ZhuanMask();
end;

function UIZhuanSheng:Set3ZhuanMask()
	local objSwf = self.objSwf;
	local stype = ZhuanModel:GetZhuanType()
	stype = 1
	if stype == 3 then 
		objSwf.Zhuan3_mask._visible = true;
		objSwf.roleLoader._visible = false;
	else
		objSwf.Zhuan3_mask._visible = false;
		objSwf.roleLoader._visible = true;
	end
end;

function UIZhuanSheng:DrawModel()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local stype = ZhuanModel:GetZhuanType()
	stype = stype + 1;
	if stype == 1 then 
		self:DrawRole();
	elseif stype == 2 then 
		self:ErZhuanScene();
	elseif stype == 3 then 
		self:SanZhuanScene();
	end;

end;

function UIZhuanSheng:SetZhuanImg()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local stype = ZhuanModel:GetZhuanType()
	stype = stype + 1
	objSwf.zhuan_img:gotoAndStop(stype)
end;

function UIZhuanSheng:SetCanZhuan()
	local objSwf = self.objSwf;
	local stype = ZhuanModel:GetZhuanType()
	if stype == 0 then stype = 1 end;
	local cfg = t_zhuansheng[stype];
	if not cfg then return end;
	local myLevel = MainPlayerModel.humanDetailInfo.eaLevel; 
	if myLevel >= cfg.level  then 
		objSwf.canZhuan_pfx._visible =true;
	else
		objSwf.canZhuan_pfx._visible =false;
	end;
end

function UIZhuanSheng:MoneyZhuanOver()
	local stype = ZhuanModel:GetZhuanType()
	stype = stype + 1;
	local cfg = t_zhuansheng[stype]
	if not cfg then 
		return 
	end;
	TipsManager:ShowBtnTips(string.format(StrConfig["zhuansheng008"],cfg.money),TipsConsts.Dir_RightDown);
end;

function UIZhuanSheng:GoZhuansheng()
	local stype = ZhuanModel:GetZhuanType()
	stype = stype + 1;
	local cfg = t_zhuansheng[stype]
	local openLvl = cfg.level;
	local myLevel = MainPlayerModel.humanDetailInfo.eaLevel;
	if myLevel >= openLvl then 
		ZhuanContoller:EnterZhuan()
	else
		FloatManager:AddNormal( string.format(StrConfig["zhuansheng010"],openLvl) );
	end;
end;

function UIZhuanSheng:MoneyZhuan()

	local stype = ZhuanModel:GetZhuanType()
	stype = stype + 1;
	local cfg = t_zhuansheng[stype]
	if not cfg then return end;

	if ZhuanModel:GetZhuanActState() then 
		FloatManager:AddNormal(StrConfig["zhuansheng011"]);
		return 
	end;

	local openLvl = cfg.level;
	local myLevel = MainPlayerModel.humanDetailInfo.eaLevel;
	if myLevel < openLvl then 
		FloatManager:AddNormal( string.format(StrConfig["zhuansheng010"],openLvl) );
		return 
	end;
	
	local mymoney = MainPlayerModel.humanDetailInfo.eaUnBindMoney
	if mymoney < cfg.money then 
		FloatManager:AddNormal( StrConfig["zhuansheng003"] );
		return 
	end;
	local func = function ()
		ZhuanContoller:MoneyZhuan()
	end
	self.erjiPanlId = UIConfirm:Open(StrConfig['zhuansheng009'],func);
end;

function UIZhuanSheng:SetUifight()
	local objSwf = self.objSwf;
	local stype = ZhuanModel:GetZhuanType()
	stype = stype + 1;
	if stype == 0 then stype = 1 end;
	local fi = t_zhuansheng[stype];
	if not fi then return end;
	objSwf.fight:gotoAndStop(stype);
	objSwf.fight.num = fi.addFight;
end;

function UIZhuanSheng:OnHide()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
		self.objUIDraw:SetMesh(nil);
		self.objUIDraw:SetUILoader(nil);
		UIDrawManager:RemoveUIDraw(self.objUIDraw);
		self.objUIDraw = nil;
	end
	if self.objAvatar then
		self.objAvatar:ExitMap();
		self.objAvatar = nil;
	end
	if self.erjiPanlId then 
		UIConfirm:Close(self.erjiPanlId)
	end;
end;

function UIZhuanSheng:OnDelete()
	if self.objUIDraw then 
		self.objUIDraw:SetDraw(false);
		self.objUIDraw:SetMesh(nil);
		self.objUIDraw:SetUILoader(nil);
		UIDrawManager:RemoveUIDraw(self.objUIDraw);
		self.objUIDraw = nil;
	end;
end


--3转画场景   
function UIZhuanSheng:SanZhuanScene()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local monsterAvater =  NpcAvatar:NewNpcAvatar(20300087)
	monsterAvater:InitAvatar();
	local drawcfg =  {
									EyePos = _Vector3.new(5,-150,20),
									LookPos = _Vector3.new(-5,5,40),
									VPort = _Vector2.new(1100,1000)
								  }
	-- if not drawcfg then 
	-- 	drawcfg = self:GetDefaultCfg();
	-- end;
	if not self.objUIDraw then 
		self.objUIDraw = UIDraw:new("UiZhuanshengMonster",monsterAvater, objSwf.roleLoader,  
			drawcfg.VPort,   drawcfg.EyePos,  
			drawcfg.LookPos,  0x00000000,"UIShihunMonster");
	else 
		self.objUIDraw:SetUILoader(objSwf.roleLoader);
		self.objUIDraw:SetCamera(drawcfg.VPort,drawcfg.EyePos,drawcfg.LookPos);
		self.objUIDraw:SetMesh(monsterAvater);
	end;
	self.objUIDraw:SetDraw(true);
	monsterAvater.objMesh.transform:setRotation(0,0,1,0.5);

	-- local cfgnpc = t_npc[20300092]
	-- local cfgmodel = t_model[cfgnpc.look];
	-- monsterAvater:DoAction(cfgmodel.san_leisure, false, function() end)
end;

--2转画场景   
function UIZhuanSheng:ErZhuanScene()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local monsterAvater =  NpcAvatar:NewNpcAvatar(20300092)
	monsterAvater:InitAvatar();
	local drawcfg =  {
									EyePos = _Vector3.new(0,-40,20),
									LookPos = _Vector3.new(0,5,15),
									VPort = _Vector2.new(900,814)
								  }
	-- if not drawcfg then 
	-- 	drawcfg = self:GetDefaultCfg();
	-- end;
	if not self.objUIDraw then 
		self.objUIDraw = UIDraw:new("UiZhuanshengjiuyouque",monsterAvater, objSwf.roleLoader,  
			drawcfg.VPort,   drawcfg.EyePos,  
			drawcfg.LookPos,  0x00000000,"UIShihunMonster");
	else 
		self.objUIDraw:SetUILoader(objSwf.roleLoader);
		self.objUIDraw:SetCamera(drawcfg.VPort,drawcfg.EyePos,drawcfg.LookPos);
		self.objUIDraw:SetMesh(monsterAvater);
	end;
	self.objUIDraw:SetDraw(true);

	local cfgnpc = t_npc[20300092]
	local cfgmodel = t_model[cfgnpc.look];
	monsterAvater:DoAction(cfgmodel.san_leisure, false, function() end)
end;

--画模型
function UIZhuanSheng:DrawRole()
	local uiLoader = self.objSwf.roleLoader;

	local vo = {};
	local info = MainPlayerModel.sMeShowInfo;
	vo.prof = MainPlayerModel.humanDetailInfo.eaProf
	vo.arms = 1-- info.dwArms
	vo.dress = info.dwDress
	vo.shoulder = info.dwShoulder;
	vo.fashionsHead = 0--info.dwFashionsHead
	vo.fashionsArms = 0--info.dwFashionsArms
	vo.fashionsDress = 0--info.dwFashionsDress
	vo.wuhunId = 0;--SpiritsModel:GetFushenWuhunId()
	vo.wing = info.dwWing
	vo.suitflag = info.suitflag
	if self.objAvatar then
		self.objAvatar:ExitMap();
		self.objAvatar = nil;	
	end
	self.objAvatar = CPlayerAvatar:new();
	self.objAvatar:CreateByVO(vo);
	--
	local prof = MainPlayerModel.humanDetailInfo.eaProf; --取玩家职业
    if not self.objUIDraw then
		self.objUIDraw = UIDraw:new("roleZhuansheng", self.objAvatar, uiLoader,
							UIDrawRoleCfg[prof].VPort,UIDrawRoleCfg[prof].EyePos,UIDrawRoleCfg[prof].LookPos,
							0x00000000,"UIRole", prof);
	else
		self.objUIDraw:SetUILoader(uiLoader);
		self.objUIDraw:SetCamera(UIDrawRoleCfg[prof].VPort,UIDrawRoleCfg[prof].EyePos,UIDrawRoleCfg[prof].LookPos);
		self.objUIDraw:SetMesh(self.objAvatar);
	end
	self.meshDir = 0;
	self.objAvatar.objMesh.transform:setRotation(0,0,1,self.meshDir);
	self.objUIDraw:SetDraw(true);
	self.objAvatar:PlayLeisureAction();
	-- --播放特效
	-- local sex = MainPlayerModel.humanDetailInfo.eaSex;
	-- local pfxName = "ui_role_sex" ..sex.. ".pfx";
	-- local name,pfx = self.objUIDraw:PlayPfx(pfxName);
	-- 微调参数
	--pfx.transform:setRotationX(UIDrawRoleCfg[prof].pfxRotationX);
end

-- notifaction
function UIZhuanSheng:ListNotificationInterests()
	return {
			NotifyConsts.PlayerAttrChange,
		}
end;
function UIZhuanSheng:HandleNotification(name,body)
	if not self.bShowState then return; end  -- 关闭等于False
	if name == NotifyConsts.PlayerAttrChange then  
		if body.type==enAttrType.eaZhuansheng then 
			self:SetUifight();
		end;
		if body.type == enAttrType.eaLevel then 
			self:SetCanZhuan();
		end;
	end;
end;

function UIZhuanSheng:GetWidth()
	return 1058
end

function UIZhuanSheng:GetHeight()
	return 676
end

-- 是否缓动
function UIZhuanSheng:IsTween()
	return true;
end

--面板加载的附带资源
function UIZhuanSheng:WithRes()
	return {"vplanPrivilegePanel.swf"}
end

--面板类型
function UIZhuanSheng:GetPanelType()
	return 1;
end
--是否播放开启音效
function UIZhuanSheng:IsShowSound()
	return true;
end

function UIZhuanSheng:IsShowLoading()
	return true;
end



