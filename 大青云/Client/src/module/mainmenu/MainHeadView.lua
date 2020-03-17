--[[
主界面人物头像
lizhuangzhuang
2014年7月18日11:09:49
]]

_G.UIMainHead = BaseUI:new("UIMainHead");

function UIMainHead:Create()
	self:AddSWF("mainPageHead.swf", false, "interserver");
end

function UIMainHead:OnLoaded(objSwf)
	objSwf.btnHead.click         = function() self:OnHeadClick();  end;
	objSwf.buffList.itemRollOver = function(e) self:OnBuffItemOver(e); end
	objSwf.buffList.itemRollOut  = function(e) self:OnBuffItemOut(e);  end
	--PK
	objSwf.pkState.rollOver      = function() self:OnShowPagePKPanel();end
	objSwf.pkState.click      	= function() self:OnPKClick();end
	objSwf.pkState.rollOut       = function() self:OnHidePagePKPanel();end
	-- 充值 vip
	objSwf.btnCharge.click = function() self:OnBtnChargeClick(); end
	objSwf.btnVip.click = function() self:OnBtnVipClick(); end
	objSwf.btn_autoAdd.click = function() self:OnBtnAutoClick();end
	objSwf.btn_autoAdd._visible = false;

	objSwf.btnCharge._visible       = Version:IsShowRechargeButton()
	---[[ 临时去掉充值和vip按钮
	objSwf.btnVip._visible          = false
	-- objSwf.btnVipEffect._visible    = true
	-- objSwf.btnChargeEffect._visible = false
	--]]
	--mclient buff
	objSwf.btnMClient.rollOver = function() self:OnBtnMClientOver(); end
	objSwf.btnMClient.rollOut  = function() TipsManager:Hide(); end
	objSwf.btnMClient.click    = function() self:OnBtnMClientClick(); end
	if Version:IsHideMClient() then 
		objSwf.btnMClient.visible = false;
	end
	-- vip功能按钮
	objSwf.btnNewVip.click    = function() self:OnBtnVipClick(); end
	--聚灵碗buff
	objSwf.btnJulingBowl.rollOver = function() self:OnBtnJulingBowlOver(); end
	objSwf.btnJulingBowl.rollOut  = function() self:OnBtnJulingBowlOut(); end
	objSwf.btnJulingBowl.click    = function() self:OnBtnJulingBowlClick(); end
	--屠魔徽章buff
	objSwf.btnBossHuizhang.rollOver = function() self:OnBtnBtnBossHuizhanglOver(); end
	objSwf.btnBossHuizhang.rollOut  = function() self:OnBtnBtnBossHuizhanglOut(); end
	objSwf.btnBossHuizhang.click    = function() self:OnBtnBtnBossHuizhanglClick(); end
	objSwf.pkState.pkLoader.loaded = function ()
		-- objSwf.pkState.pkLoader._x = objSwf.pkState._width / 2 - objSwf.pkState.pkLoader._width / 2 ;

		--屏蔽了徽章等 ..按钮 
     objSwf.btnBossHuizhang._visible=false;
     -- objSwf.btnMClient._visible=false;
     objSwf.btnJulingBowl._visible=false;
     objSwf.btnExpHuizhang._visible=false;

	end
end

function UIMainHead:NeverDeleteWhenHide()
	return true;
end
function UIMainHead:OnBtnAutoClick()

	UIFangChenMiView:Show()

end
function UIMainHead:OnShow()
	-- 设置角色信息
	local info = MainPlayerModel.humanDetailInfo;
	local objSwf = self.objSwf;
	if not objSwf then return; end
	--objSwf.lvlLoader.num = info.eaLevel;
	objSwf.tfLv.text = info.eaLevel
	--objSwf.tfName.text = RoleUtil:TailorName( info.eaName )
	objSwf.tfName.text = info.eaName
	objSwf.headLoader.source = ResUtil:GetHeadIcon( MainPlayerModel:GetIconId() )
	self:SetFight();
	self:ShowBuffList();
	self:ShowMClientBtn();
	self:CheckShowNewVipBtn();
	objSwf.pkState.pkLoader.source = ResUtil:GetPKStateIconUrl(MainRolePKModel:GetPKIndex(),1);
	self:ShowVIcon();
	self:ShowJulingBowl();
	self:ShowBossHuizhang();
	self:ShowLovelyPet();
	self:ShowZhenQi();
end

-- smart 灵力
function UIMainHead:ShowZhenQi()
	local objSwf = self.objSwf
	if not objSwf then return end
	local zhenqi = MainPlayerModel.humanDetailInfo.eaZhenQi
--	objSwf.numLingliLoader:drawStr( _G.getNumShow( zhenqi, true ) )
	-- objSwf.numLingliLoader:scrollToNum(zhenqi, 1)
end;

function UIMainHead:CheckShowNewVipBtn( )
	local objSwf = self.objSwf
	if not objSwf then return end
	local playLevel = MainPlayerModel.humanDetailInfo.eaLevel
	local vipCfg = t_funcOpen[63]
	if not vipCfg then return end
	local vipOpenLv = vipCfg.open_level
	local openState = false
	if playLevel >= vipOpenLv then
		openState = true
	end
	if openState then
		objSwf.btnNewVip.visible = true
	else
		objSwf.btnNewVip.visible = false
	end
end

function UIMainHead:ShowJulingBowl()
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.btnJulingBowl.selected = LingLiHuiZhangModel:GetHuiZhangOrder() > 0 and true or false;-- 等阶大于零表示聚灵碗激活
end

function UIMainHead:ShowBossHuizhang()
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.btnBossHuizhang.selected = BossMedalModel:IsActive()
end

function UIMainHead:ShowLovelyPet()
	UILovelyPetHeadView:Show();
end

--点击头像
function UIMainHead:OnHeadClick()
	if isDebug then
		if CControlBase.oldKey[_System.KeyCtrl] then
			trace( MainPlayerModel.humanDetailInfo );
			return;
		end
	end
	if MainPlayerController.isInterServer then return; end
	FuncManager:OpenFunc( FuncConsts.Role, true );
end

--显示战斗力
--@param 是否滚动显示
function UIMainHead:SetFight(withScroll, fight)
	local objSwf = self.objSwf;
	if not objSwf then return; end

	local info = MainPlayerModel.humanDetailInfo;
	if withScroll then
		if info.eaFight < 0 then  --处理内部战斗力异常
			-- objSwf.fight.numFight:scrollToNum(0,1)
			PublicUtil.SetNumberValue(objSwf.fight.numFight, 1, true)
		else
			objSwf.fight:gotoAndPlay(2)
			-- objSwf.fight.numFight:scrollToNum(info.eaFight,1)
			PublicUtil.SetNumberValue(objSwf.fight.numFight, info.eaFight, true)
			if self.timeKey1 then
				TimerManager:UnRegisterTimer(self.timeKey1)
			end
			self.timeKey1 = TimerManager:RegisterTimer(function()
				objSwf.fight:gotoAndPlay(5)
			end, 1500, 1)
		end
		return;
	end
	--处理登录界面的战斗力异常
	if info.eaFight < 0 then info.eaFight = 0 end
	PublicUtil.SetNumberValue(objSwf.fight.numFight, fight and fight or info.eaFight, false)
end

--显示Buff列表
function UIMainHead:ShowBuffList()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.buffList.dataProvider:cleanUp();
	local buffList = BuffModel:GetShowList();
	for k, vo in pairs(buffList) do	
		objSwf.buffList.dataProvider:push( UIData.encode(vo) );
	end
	objSwf.buffList:invalidateData();
end

--BuffItem tips
function UIMainHead:OnBuffItemOver(e)
	local buffVO = BuffModel:GetBuff(e.item.id);
	if not buffVO then return; end
	TipsManager:ShowTips( TipsConsts.Type_Buff, buffVO, TipsConsts.ShowType_Normal, TipsConsts.Dir_RightDown );
end

function UIMainHead:OnBuffItemOut(e)
	TipsManager:Hide();
end

--PK面板显示PK
UIMainHead.timeKey = nil;
function UIMainHead:OnShowPagePKPanel()
	local cfg = t_map[CPlayerMap:GetCurMapID()];
	-- WriteLog(LogType.Normal,true,'-------------houxudong1',cfg,CPlayerMap:GetCurMapID())
	if not cfg.changePK or cfg.changePK == 1 then return end
	if self.timeKey ~= nil then
		TimerManager:UnRegisterTimer(self.timeKey);
	end
	local objSwf = self.objSwf;
	
	local func = function () 
		UIMainRolePKPanel:Hide();
	end
	UIMainRolePKPanel:Open(func);
	self.objSwf.pkState.pkLoader.source = ResUtil:GetPKStateIconUrl(MainRolePKModel:GetPKIndex(),2);
end

--PK点击事件
function UIMainHead:OnPKClick()
	local cfg = t_map[CPlayerMap:GetCurMapID()];
	if cfg.changePK == 1 then 
		FloatManager:AddSkill(StrConfig['mainmenuNotPk001']);
	end
end

function UIMainHead:OnHidePagePKPanel()
	local objSwf = self.objSwf;
	local func = function()
		UIMainRolePKPanel:Hide();
	end
	self.timeKey = TimerManager:RegisterTimer(func,200,1);
	self.objSwf.pkState.pkLoader.source = ResUtil:GetPKStateIconUrl(MainRolePKModel:GetPKIndex(),1);
end

function UIMainHead:OnBtnChargeClick()
	Version:Charge();
end

function UIMainHead:OnBtnVipClick()
	if MainPlayerController.isInterServer then return; end
	if UIVip:IsShow() then
		UIVip:Hide()
	else
		UIVip:Show()	                                         
	end
end

--微端Buff
function UIMainHead:ShowMClientBtn()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.btnMClient.selected = _G.ismclient and true or false;
end
function UIMainHead:OnBtnMClientOver()
	local addV = t_consts[58].val1;
	if _G.ismclient then
		TipsManager:ShowBtnTips(string.format(StrConfig["mainmenuHead005"],addV),TipsConsts.Dir_RightDown);
	else
		TipsManager:ShowBtnTips(string.format(StrConfig["mainmenuHead004"],addV),TipsConsts.Dir_RightDown);
	end
end
function UIMainHead:OnBtnMClientClick()
	if not _G.ismclient then
		Version:DownloadMClient();
		TipsManager:Hide();
		local objSwf = self.objSwf;
		objSwf.btnMClient.visible = false;
		TimerManager:RegisterTimer(function()
			objSwf.btnMClient.visible = true;
		end,300000,1);
	end
end

--聚灵碗tips
function UIMainHead:OnBtnJulingBowlOver()
	if FuncManager:GetFuncIsOpen( FuncConsts.HuiZhang ) then
		UILingLiHuiZhangTip.showtype = 1;
		UILingLiHuiZhangTip:Show();
	else
		local questvo = t_quest[t_funcOpen[FuncConsts.HuiZhang].open_prama];
		if questvo then
			TipsManager:ShowBtnTips(string.format(StrConfig["linglihuizhang31"],questvo.minLevel), TipsConsts.Dir_RightDown );
		end
	end
end
function UIMainHead:OnBtnJulingBowlOut()
	UILingLiHuiZhangTip:Hide();
	TipsManager:Hide();
end

function UIMainHead:OnBtnJulingBowlClick()
	if MainPlayerController.isInterServer then return; end
	if FuncManager:GetFuncIsOpen( FuncConsts.HuiZhang ) == true then
		FuncManager:OpenFunc( FuncConsts.Homestead, true);
	end
end

function UIMainHead:OnBtnBtnBossHuizhanglOver()
	BossMedalController:ShowBossMedalTips(true)
end

function UIMainHead:OnBtnBtnBossHuizhanglOut()
	BossMedalController:ShowBossMedalTips(false)
end

function UIMainHead:OnBtnBtnBossHuizhanglClick()
	if MainPlayerController.isInterServer then return; end
	FuncManager:OpenFunc( FuncConsts.BossHuizhang, true )
end

--V计划
function UIMainHead:ShowVIcon()
	-- local objSwf = self.objSwf;
	-- if not objSwf then return; end
	-- local vflagurl = ResUtil:GetVIcon(VplanModel:GetVFlag());
	-- if vflagurl then
		-- objSwf.vloader.source = vflagurl;
	-- end
end

--监听消息列表
function UIMainHead:ListNotificationInterests()
	return {
		NotifyConsts.BuffRefresh,
		NotifyConsts.PlayerAttrChange,
		NotifyConsts.UpPKStateIconUrlChange,
		NotifyConsts.VFlagChange,
		NotifyConsts.ZhuLingProgress,
		NotifyConsts.BossMedalLevel,
		NotifyConsts.ChangePlayerName,
	}
end

--处理消息
function UIMainHead:HandleNotification(name, body)
	if name == NotifyConsts.PlayerAttrChange then
		if body.type == enAttrType.eaLevel then
			self:OnLevelUp( body.val );
			self:CheckShowNewVipBtn()
		elseif body.type == enAttrType.eaFight then  -- 10
			if body.val > body.oldVal then
				-- self:SetFight(true);
				if toint(body.val,0.5)-toint(body.oldVal,0.5) > 0 then
					UIMainFightFly:Open(toint(body.val,0.5)-toint(body.oldVal,0.5), body.val, body.oldVal);
				end
			else
				self:SetFight();
			end
		elseif body.type == enAttrType.eaZhenQi then
			if not UILingliEffect:Play() then
				self:ShowZhenQi();			
			end
		end
	elseif name == NotifyConsts.BuffRefresh then
		self:ShowBuffList();
	elseif	name == NotifyConsts.UpPKStateIconUrlChange then
		local objSwf = self.objSwf;
		if not objSwf then return; end
		objSwf.pkState.pkLoader.source = ResUtil:GetPKStateIconUrl(MainRolePKModel:GetPKIndex(),1);
	elseif name == NotifyConsts.VFlagChange then
		self:ShowVIcon();
	elseif name == NotifyConsts.ZhuLingProgress then
		self:ShowJulingBowl()
	elseif name == NotifyConsts.BossMedalLevel then
		self:ShowBossHuizhang()
	elseif name == NotifyConsts.ChangePlayerName then
		local info = MainPlayerModel.humanDetailInfo;
		local objSwf = self.objSwf;
		if not objSwf then return; end
		--objSwf.tfName.text = RoleUtil:TailorName( info.eaName )
		objSwf.tfName.text = info.eaName
	end
end

function UIMainHead:OnLevelUp( level )
	local objSwf = self.objSwf;
	if not objSwf then return end
	--objSwf.lvlLoader.num = level;
	objSwf.tfLv.text = level
end

function UIMainHead:PlayEffectLingli()
	local objSwf = self.objSwf;
	if not objSwf then return end

	--objSwf.numLingliLoader.mcLingli:gotoAndPlay(1)
	self:ShowZhenQi();	
end

function UIMainHead:GetLingliPosG()
	-- local objSwf = self.objSwf
	-- if not objSwf then return end
	-- local posXL = objSwf.numLingliLoader._x + 14
	-- local posYL = objSwf.numLingliLoader._y + 27
	-- return UIManager:PosLtoG( objSwf, posXL, posYL )
end

function UIMainHead:GetGoldIconGlobalPos()
	local objSwf = self.objSwf;
	if not objSwf then return; end

	return UIManager:PosLtoG(objSwf, objSwf.goldIcon._x, objSwf.goldIcon._y);
end

function UIMainHead:GetBindMoneyIconGlobalPos()
	local objSwf = self.objSwf;
	if not objSwf then return; end

	return UIManager:PosLtoG(objSwf, objSwf.bindMoneyIcon._x, objSwf.bindMoneyIcon._y);
end