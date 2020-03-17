--[[境界主面板
zhangshuhui
2015年4月1日18:31:00
]]

_G.UIRealmMainView = BaseUI:new("UIRealmMainView");

--当前显示的境界
UIRealmMainView.curRealmOrder = 0;
UIRealmMainView.curRealmGongGuId = 0;

UIRealmMainView.confirmUID = 0;
UIRealmMainView.isShowClearConfirm = true;

UIRealmMainView.posList = {};

function UIRealmMainView:Create()
	self:AddSWF("realmMainPanel.swf", true, "center")
end

function UIRealmMainView:OnLoaded(objSwf,name)
	--关闭
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end;
	
	objSwf.btnPre.click     = function() self:OnBtnPreClick(); end
	objSwf.btnNext.click    = function() self:OnBtnNextClick(); end
	
	objSwf.jinjiepanel.btnLvlUp.click	 = function() self:OnBtnLvlUpClick(); end
	objSwf.jinjiepanel.btnLvlUp.rollOver = function() self:OnRollBreakTip(); end
	objSwf.jinjiepanel.btnLvlUp.rollOut = function() self:OnRollBreakrollOut(); end
	objSwf.jinjiepanel.btnAutoLvlUp.click = function() self:OnBtnAutoLvlUpClick(); end
	objSwf.jinjiepanel.btnAutoLvlUp.rollOver = function() self:OnRollBreakTip(); end
	objSwf.jinjiepanel.btnAutoLvlUp.rollOut = function() self:OnRollBreakrollOut(); end
	objSwf.jinjiepanel.btnCancelAuto.click = function() self:OnBtnCancelAutoClick(); end
	-- objSwf.jinjiepanel.cbAutoBuy._visible = false
	objSwf.jinjiepanel.cbAutoBuy.select  = function(e) self:OnCBAutoBuySelect(e) end
	self.proLoaderValuex = objSwf.jinjiepanel.proLoaderValue._x;
	objSwf.jinjiepanel.proLoaderValue.loadComplete = function(e) 
														objSwf.jinjiepanel.proLoaderValue._x = self.proLoaderValuex - objSwf.jinjiepanel.proLoaderValue.width / 2
														end
	objSwf.jinjiepanel.btnConsume.rollOver = function() self:OnbtnBreakItemRollOver(); end
	objSwf.jinjiepanel.btnConsume.rollOut  = function() TipsManager:Hide();  end
	objSwf.jinjiepanel.tipsArea.rollOver = function() self:OnTipsAreaRollOver(); end
	objSwf.jinjiepanel.tipsArea.rollOut  = function() self:OnTipsAreaRollOut(); end
	
	--灌注
	objSwf.orderuppanel.btnguanzhu.click = function() self:OnBtnGuanZhuClick(); end;
	objSwf.orderuppanel.btnfreeguanzhu.click = function() self:OnBtnFreeGuanZhuClick(); end;
	objSwf.orderuppanel.btnvipguanzhu.click = function() self:OnBtnVIPGuanZhuClick(); end;
	
	-- objSwf.orderuppanel.btnguanzhu.rollOver = function() self:OnGuanZhuRollOver(); end
	-- objSwf.orderuppanel.btnguanzhu.rollOut = function() TipsManager:Hide(); end
	-- objSwf.orderuppanel.btnfreeguanzhu.rollOver = function() self:OnRollVIPGuanZhuTip(); end
	-- objSwf.orderuppanel.btnfreeguanzhu.rollOut = function() TipsManager:Hide(); end
	objSwf.orderuppanel.btnvipguanzhu.rollOver = function() self:OnRollVIPGuanZhuTip(); end
	objSwf.orderuppanel.btnvipguanzhu.rollOut = function() TipsManager:Hide(); end
	
	--技能
	objSwf.btnskill1.rollOver = function() self:BtnSkill1RollOver(); end
	objSwf.btnskill1.rollOut = function() TipsManager:Hide(); end
	
	objSwf.orderuppanel.guanzhutiaojianpanel.expinfo.rollOver = function() self:OnbtnExpInfoRollOver(); end
	objSwf.orderuppanel.guanzhutiaojianpanel.expinfo.rollOut  = function() TipsManager:Hide();  end
	
	objSwf.orderuppanel.guanzhutiaojianpanel.ConstomRealmDanPanel.btnConsumeRealmDan.rollOver = function() self:OnConsumeRealmDanRollOver(); end
	objSwf.orderuppanel.guanzhutiaojianpanel.ConstomRealmDanPanel.btnConsumeRealmDan.rollOut = function() TipsManager:Hide(); end
	
	--屏蔽灌注消耗的tips，现给为消耗修为
	-- objSwf.btnfloodtool.rollOver = function() self:OnbtnFloodItemRollOver(); end
	-- objSwf.btnfloodtool.rollOut  = function() TipsManager:Hide();  end
	
	objSwf.btntoolget.click = function() self:OnBtnGetItemClick(); end
	objSwf.btntoolget.rollOver = function() self:OnbtnGetItemRollOver(); end
	objSwf.btntoolget.rollOut  = function() TipsManager:Hide();  end
	
	--进阶进度值居右
	self.numjinjiex = objSwf.orderuppanel.leftpronum._x
	objSwf.orderuppanel.leftpronum.loadComplete = function()
									objSwf.orderuppanel.leftpronum._x = self.numjinjiex - objSwf.orderuppanel.leftpronum.width
								end
	--属性进度值居右
	self.numattrx = objSwf.attnumpanel.attleftpronum._x;
	for _, type in pairs( RealmConsts.Attrs ) do
		objSwf[type.."numpanel"].attleftpronum.loadComplete = function()
									objSwf[type.."numpanel"].attleftpronum._x = self.numattrx - objSwf[type.."numpanel"].attleftpronum.width
								end
	end
	--战斗力值居中
	self.numFightx = objSwf.numFight._x
	objSwf.numFight.loadComplete = function()
									objSwf.numFight._x = self.numFightx - objSwf.numFight.width / 2
								end
	--战斗力值居中
	self.tubiaoLoaderx = objSwf.tubiaoLoader._x
	objSwf.tubiaoLoader.loaded = function()
									objSwf.tubiaoLoader._x = self.tubiaoLoaderx - objSwf.tubiaoLoader._width / 2
									objSwf.tubiaoLoader._y = objSwf.nameLoader._y + objSwf.nameLoader._height
								end

	objSwf.btnVipBack.click    = function() self:OnBtnVipBackClick() end
	objSwf.btnVipBack.rollOver = function() self:OnBtnVipBackRollOver() end
	objSwf.btnVipBack.rollOut  = function() self:OnBtnVipBackRollOut() end
	
	--巩固
	objSwf.gongguPanel.progresspanel.gonggupanel.btnGongGu.click    = function() self:OnBtnGongGuClick() end
	objSwf.gongguPanel.progresspanel.gonggupanel.btnGongGu.rollOver    = function() self:OnBtnGongGurollOver() end
	objSwf.gongguPanel.progresspanel.gonggupanel.btnGongGu.rollOut    = function() self:OnBtnGongGurollOut() end
	objSwf.gongguPanel.progresspanel.tupopanel.btnbreak.click    = function() self:OnBtnGongGuBreakClick() end
	objSwf.gongguPanel.progresspanel.tupopanel.btnbreak.rollOver    = function() self:OnBtnGongGuBreakrollOver() end
	objSwf.gongguPanel.progresspanel.tupopanel.btnbreak.rollOut    = function() self:OnBtnGongGuBreakrollOut() end
	objSwf.gongguPanel.progresspanel.gonggupanel.btnConsume.rollOver = function() self:OnBtnGongGuConsumeRollOver() end
	objSwf.gongguPanel.progresspanel.gonggupanel.btnConsume.rollOut  = function() TipsManager:Hide(); end
	objSwf.gongguPanel.progresspanel.tupopanel.btnConsume.rollOver = function() self:OnBtnGongGuConsumeRollOver() end
	objSwf.gongguPanel.progresspanel.tupopanel.btnConsume.rollOut  = function() TipsManager:Hide(); end
	objSwf.gongguPanel.progresspanel.gonggupanel.proLoaderValue.loadComplete = function(e) self:OnNumValueLoadComplete(e); end
	objSwf.gongguPanel.progresspanel.gonggupanel.tipsArea.rollOver	= function() self:OnBtnGongGuProrollOver() end
	objSwf.gongguPanel.progresspanel.gonggupanel.tipsArea.rollOut	= function() TipsManager:Hide(); end
	for i=1,9 do
		objSwf.gongguPanel["btnChong"..i].click = function() self:OnTabButtonClick(i); end;
		objSwf.gongguPanel["btnChongMan"..i].click = function() self:OnTabButtonClick(i); end;
	end
	
	objSwf.chkBoxUseModel.click      = function() self:OnChkBoxUseModelClick() end
	
	-- objSwf.gongguPanel._visible = false;
	-- objSwf.orderuppanel._visible = false;
	-- objSwf.btnfloodtool._visible = false;
	-- objSwf.btntoolget._visible = false;
	objSwf.bg._visible = false;
	-- objSwf.tubiaoLoader._visible = false;
	objSwf.chkBoxUseModel._visible = false;
	objSwf.gongguLoader._visible = false;
	objSwf.orderuppanel.guanzhutiaojianpanel.ConstomRealmDanPanel._visible = false;
	objSwf.orderuppanel.guanzhutiaojianpanel.checkRealmDan._visible = false;
	objSwf.orderuppanel.guanzhutiaojianpanel.expinfo._visible = false;
	
	self.posList = {};
	for _, type in ipairs( RealmConsts.Attrs ) do
		local pos = {};
		local panel = objSwf["label"..type];
		table.push(pos,{x=panel.x,y=panel.y});
		panel = objSwf["tf"..type];
		table.push(pos,{x=panel.x,y=panel.y});
		panel = objSwf[type.."pro"];
		table.push(pos,{x=panel.x,y=panel.y});
		panel = objSwf["tfgongguadd"..type];
		table.push(pos,{x=panel.x,y=panel.y});
		panel = objSwf[type.."numpanel"];
		table.push(pos,{x=panel.x,y=panel.y});
		
		table.push(self.posList,pos);
	end

	objSwf.btnShuXingDan.click = function() self:OnBtnFeedSXDClick() end
	objSwf.btnShuXingDan.rollOver = function() self:OnShuXingDanRollOver(); end
	objSwf.btnShuXingDan.rollOut = function() UIMountFeedTip:Hide(); end

	objSwf.btnZZD.click = function() self:OnBtnZZDClick() end
	objSwf.btnZZD.rollOver = function() self:OnZZDRollOver(); end
	objSwf.btnZZD.rollOut  = function()  UIMountFeedTip:Hide();  end
	
	objSwf.orderuppanel.touch.rollOver = function() self:XiuweiChiTips();  end
	objSwf.orderuppanel.touch.rollOut = function() TipsManager:Hide() end;
	local itemId, itemNum, isEnough = RealmUtil:GetConsumeItem(RealmModel:GetRealmOrder());
	objSwf.jinjiepanel.btnGotWay.click = function(e)
								UIQuickBuyConfirm:Open(self,itemId);
							 end
	objSwf.jinjiepanel.btnGotWay.htmlLabel = StrConfig["common002"];
end

function UIRealmMainView:OnShow(name)


	--初始化数据
	self:InitData(true);
	--初始化UI
	self:InitUI();
	--显示
	self:ShowRealmMainInfo(self.curRealmOrder);
	--请求获得世界最高等阶
	RealmController:ReqGetRealmMax();
	self:InitVip();   
	self:SwitchAutoLvlUpState( RealmController.isAutoLvlUp );
	
	-- 调整mask的大小
	-- self:UpdateMask()
	-- 调整按钮位置
	-- self:UpdateCloseButton()
	
	self:InitRedPoint();
	self:RegisterTimes();

	self:ShowvipEffect();
	self:showVipBackInfo()
   -- 属性丹 资质丹 特效 
	--self:ShowAttrRed()
end
--境界红点提示 
UIRealmMainView.timeKey = nil;
function UIRealmMainView:InitRedPoint()
	local objSwf = self.objSwf
	if not objSwf then return; end
	if RealmUtil:CheckCanOperation() then
		PublicUtil:SetRedPoint(objSwf.btnJinjie,nil,1)
	else
		PublicUtil:SetRedPoint(objSwf.btnJinjie)
	end
end

function UIRealmMainView:RegisterTimes()
	self.timeKey = TimerManager:RegisterTimer(function()
		-- print("是否可以使用丹药",RoleUtil:GetBogeyPillList(false))
		self:InitRedPoint()
	end,1000,0); 
end

--境界≥2阶后，第一次打开境界界面时，开始引导
function UIRealmMainView:OnFullShow()
	-- RealmUtil:CheckGongGuGuide();--暂时屏蔽境界新手引导脚本
end

--关闭事件
function UIRealmMainView:OnBeforeHide()
	if UIBlessingWarning:IsShow() then
		return false
	end
	if self.warningState == nil then
		self.warningState = true;
		if ChargesUtil:OnWarningPass(ChargesConsts.Realm) then
			if not UIBlessingWarning:Open(function () self:Hide() end) then
				self.warningState = nil;
				return true
			end
		else
			self.warningState = nil;
			return true			
		end
	else
		self.warningState = nil;
		return true
	end
end

function UIRealmMainView:OnHide()
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	if self.confirmUID > 0 then
		UIConfirm:Close(self.confirmUID);
		self.confirmUID = 0;
	end
	RealmController:SetAutoLevelUp(false);
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.bgLoaderEffect:unload();
	objSwf.bgLoaderEffect.source = nil;
	UIVipBack:Hide()
	
end

--点击关闭按钮
function UIRealmMainView:OnBtnCloseClick()
	self:Hide();
end

UIRealmMainView.lastSendTime = 0;
function UIRealmMainView:OnBtnLvlUpClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	

	if GetCurTime() - self.lastSendTime < 200 then
		return;
	end
	self.lastSendTime = GetCurTime();

	if RealmUtil:GetIsFullProgress() == false then
		return;
	end
	
	--自动购买
	if RealmModel.autoBuy == true then
		--元宝不足
		if RealmUtil:GetIsJinJieByMoney(RealmModel:GetRealmOrder()) == false then
			FloatManager:AddNormal( StrConfig["realm42"], objSwf.jinjiepanel.btnLvlUp);
			return;
		end
	else
		--道具不足
		if RealmUtil:GetIsHaveToolTuPo(RealmModel:GetRealmOrder()) == false then
			FloatManager:AddNormal( StrConfig["realm42"], objSwf.jinjiepanel.btnLvlUp);
			local itemId, itemNum, isEnough = RealmUtil:GetConsumeItem(RealmModel:GetRealmOrder());
			UIQuickBuyConfirm:Open(self,itemId);
			return;
		end
	end
	
	
	--银两不足
	if RealmUtil:GetIsHaveMoneyTuPo(RealmModel:GetRealmOrder()) == false then
		FloatManager:AddNormal( StrConfig["realm43"], objSwf.jinjiepanel.btnLvlUp);
		return;
	end
	
	--清空二次确认提示
	if self.isShowClearConfirm == true then
		local realmcfg = t_jingjie[RealmModel:GetRealmOrder()];
		if realmcfg then
			local isWishclear = realmcfg.is_wishclear
			if isWishclear then
				local confirmFunc = function()
					RealmController:ReqGoBreak();
					self.isShowClearConfirm = false;
				end
				self.confirmUID = UIConfirm:Open( StrConfig["realm48"], confirmFunc );
				return;
			end
		end
	end
	RealmController:SetAutoLevelUp(false);
	RealmController:ReqGoBreak();
end

function UIRealmMainView:OnBtnAutoLvlUpClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	if RealmUtil:GetIsFullProgress() == false then
		return;
	end
	
	--自动购买
	if RealmModel.autoBuy == true then
		--元宝不足
		if RealmUtil:GetIsJinJieByMoney(RealmModel:GetRealmOrder()) == false then
			FloatManager:AddNormal( StrConfig["realm42"], objSwf.jinjiepanel.btnAutoLvlUp);
			return;
		end
	else
		--道具不足
		if RealmUtil:GetIsHaveToolTuPo(RealmModel:GetRealmOrder()) == false then
			FloatManager:AddNormal( StrConfig["realm42"], objSwf.jinjiepanel.btnAutoLvlUp);
			local itemId, itemNum, isEnough = RealmUtil:GetConsumeItem(RealmModel:GetRealmOrder());
			UIQuickBuyConfirm:Open(self,itemId);
			return;
		end
	end
	
	--银两不足
	if RealmUtil:GetIsHaveMoneyTuPo(RealmModel:GetRealmOrder()) == false then
		FloatManager:AddNormal( StrConfig["realm43"], objSwf.jinjiepanel.btnAutoLvlUp);
		return;
	end
	
	--清空二次确认提示
	if self.isShowClearConfirm == true then
		local realmcfg = t_jingjie[RealmModel:GetRealmOrder()];
		if realmcfg then
			local isWishclear = realmcfg.is_wishclear
			if isWishclear then
				local confirmFunc = function()
					RealmController:SetAutoLevelUp(true);
					RealmController:ReqGoBreak();
					self.isShowClearConfirm = false;
				end
				self.confirmUID = UIConfirm:Open( StrConfig["realm48"], confirmFunc );
				return;
			end
		end
	end
	
	RealmController:SetAutoLevelUp(true);
	RealmController:ReqGoBreak();
end

function UIRealmMainView:OnCBAutoBuySelect(e)
	RealmModel.autoBuy = e.selected;
	self:UpdateBtnEffect()
end
function UIRealmMainView:UpdateBtnEffect()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	
	local auto = false;	
	if RealmModel.autoBuy then
		auto = true;
	end
	local isEnough = RealmUtil:GetIsCanJinJie(auto)
	if isEnough then
		objSwf.jinjiepanel.btnLvlUp:showEffect(ResUtil:GetButtonEffect10());
		objSwf.jinjiepanel.btnAutoLvlUp:showEffect(ResUtil:GetButtonEffect10());
	else
		objSwf.jinjiepanel.btnLvlUp:clearEffect();
		objSwf.jinjiepanel.btnAutoLvlUp:clearEffect();
	end
end
function UIRealmMainView:OnRollBreakTip()
	self:ShowAttrInfo(2);
end
function UIRealmMainView:OnRollBreakrollOut()
	self:ShowAttrInfo();
	TipsManager:Hide();
end

function UIRealmMainView:OnNumLoadComplete()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local numLoader = objSwf.jinjiepanel.proLoaderValue;
	local bg = objSwf.jinjiepanel.posSign;
	numLoader._x = bg._x - numLoader.width;
end

UIRealmMainView.lastSendTime2 = 0;
--灌注
function UIRealmMainView:OnBtnGuanZhuClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	-- print('===========================灌注')
	
	if GetCurTime() - self.lastSendTime2 < 200 then
		-- print('===========================< 200')
		return;
	end
	self.lastSendTime2 = GetCurTime();

	--条件判断
	if RealmUtil:GetIsFullProgress() == true then
		-- print('==========================条件判断')
		return;
	end
	local type = 1;
	objSwf.orderuppanel.guanzhutiaojianpanel.checkRealmDan._visible = false;
	if objSwf.orderuppanel.guanzhutiaojianpanel.checkRealmDan.selected == false then
		--经验不足
		if RealmUtil:GetIsHaveExp(RealmModel:GetRealmOrder()) == false then
			FloatManager:AddNormal( StrConfig["realm18"], objSwf.orderuppanel.btnguanzhu);
			-- print('==========================经验不足')
			return;
		end
	else
		type = 2;
		if RealmUtil:GetIsHaveRealmDanUp() == false then
			FloatManager:AddNormal( StrConfig["realm30"], objSwf.orderuppanel.btnguanzhu);
			-- print('==========================realm30')
			return;
		end
	end
	local cfg = t_jingjie[RealmModel:GetRealmOrder()];
	--道具不足
	if RealmUtil:GetIsHaveTool(RealmModel:GetRealmOrder()) == false then
		local reCfg = split(cfg.flood_item_daiti,',');
		if toint(reCfg[1]) > 0 then 
			local NbItemId = toint(reCfg[1]);
			local NbNum = BagModel:GetItemNumInBag(NbItemId);
			if NbNum >= toint(reCfg[2]) then 
			else
				FloatManager:AddNormal( StrConfig["realm30"], objSwf.orderuppanel.btnguanzhu);
				return;
			end;
		else
			FloatManager:AddNormal( StrConfig["realm30"], objSwf.orderuppanel.btnguanzhu);
			return;
		end;	
	end
	
	--大量灵石			--暂时屏蔽大量灌注
	-- local isauto ,progressnum = RealmUtil:GetIsAutoFloot(type);
	-- if isauto == true then
		-- local confirmFunc = function()
			-- RealmController:ReqRealmFlood(progressnum,type);
		-- end
		-- self.confirmUID = UIConfirm:Open( StrConfig["realm41"], confirmFunc );
	-- else
		RealmController:ReqRealmFlood(1,type);
	-- end
end

function UIRealmMainView:OnGuanZhuRollOver()
	local str = "";
	
	local strname = "";
	if RealmModel:GetOrderMaxInGame() <= 0 then
		strname = "";
	else
		strname = t_jingjie[RealmModel:GetOrderMaxInGame()].name;
	end
	
	local percent = RealmUtil:GetFloodExpNum();
	if percent < 1 then
		local strpercent = string.format("%.2f",(1-percent)*100);
		str = string.format(StrConfig["realm24"], strname, strpercent);
	else
		str = string.format(StrConfig["realm25"], strname, 0);
	end
	TipsManager:ShowBtnTips(str,TipsConsts.Dir_RightDown);
end

function UIRealmMainView:OnRollVIPGuanZhuTip()
	local playerinfo = MainPlayerModel.humanDetailInfo;
	local vipcount = 0;
	if playerinfo.eaVIPLevel > 0 then
		vipcount = t_vip[playerinfo.eaVIPLevel].vip_flood_num;
	end
	
	local str = string.format(StrConfig["realm3"],t_consts[56].val1 + vipcount - RealmModel:GetFreeNum());
	TipsManager:ShowBtnTips(str,TipsConsts.Dir_RightDown);
end

function UIRealmMainView:OnBtnFreeGuanZhuClick()
	--条件判断
	if RealmUtil:GetIsFullProgress() == true then
		-- print('==============================RealmUtil:GetIsFullProgress() == true')
		return;
	end
	
	--普通免费次数
	print("---书:",RealmModel:GetFreeNum())
	if RealmModel:GetFreeNum() >= t_consts[56].val1 then
		-- print('==============================普通免费次数')
		return;
	end
	
	RealmController:ReqRealmFlood(0);
end
function UIRealmMainView:OnBtnVIPGuanZhuClick()
	--条件判断
	if RealmUtil:GetIsFullProgress() == true then
		return;
	end
	
	local playerinfo = MainPlayerModel.humanDetailInfo;
	local vipcount = 0;
	if playerinfo.eaVIPLevel > 0 then
		vipcount = t_vip[playerinfo.eaVIPLevel].vip_flood_num;
	end
	if RealmModel:GetFreeNum() >= (t_consts[56].val1 + vipcount) then
		return;
	end
	
	RealmController:ReqRealmFlood(0);
end

function UIRealmMainView:BtnSkill1RollOver()
	
end

function UIRealmMainView:OnbtnBreakItemRollOver()
	local itemId, itemNum, isEnough = RealmUtil:GetConsumeItem(RealmModel:GetRealmOrder());
	if t_item[itemId] then
		TipsManager:ShowItemTips(itemId);
	end
end

function UIRealmMainView:OnTipsAreaRollOver()
	local realmcfg = t_jingjie[RealmModel:GetRealmOrder()];
	if realmcfg then
		local blessing = RealmModel:GetBreakProgress();
		local isWishclear = realmcfg.is_wishclear
		local tipStr = StrConfig["wuhun26"]
		if isWishclear then
			tipStr = StrConfig["wuhun27"]
		end

		TipsManager:ShowBtnTips( string.format(StrConfig["wuhun25"],blessing, tipStr));
	end
end

function UIRealmMainView:OnTipsAreaRollOut()
	TipsManager:Hide();
end

function UIRealmMainView:OnbtnExpInfoRollOver()
	TipsManager:ShowBtnTips(StrConfig['realm36'],TipsConsts.Dir_RightDown);
end

function UIRealmMainView:OnConsumeRealmDanRollOver()
	if t_consts[125] then
		local itemId = tonumber(t_consts[125].val1);
		if itemId > 0 then
			TipsManager:ShowItemTips(itemId)
		end
	end
end

function UIRealmMainView:OnbtnFloodItemRollOver()
	local cfg = t_jingjie[RealmModel:GetRealmOrder()];
	if cfg then
		--消耗道具
		local rewardList = RewardManager:ParseToVO(cfg.flood_item);
		for k,cfgvo in pairs(rewardList) do
			if cfgvo and t_item[cfgvo.id] then
				local intemNum = BagModel:GetItemNumInBag(cfgvo.id);
				if intemNum < cfgvo.count then
					local reCfg = split(cfg.flood_item_daiti,',');
					if toint(reCfg[1]) > 0 then 
						local NbItemId = toint(reCfg[1]);
						local NbNum = BagModel:GetItemNumInBag(NbItemId);
						if NbNum >= toint(reCfg[2]) then 
							TipsManager:ShowItemTips(NbItemId)
						else
							TipsManager:ShowItemTips(cfgvo.id)
						end;
					else
						TipsManager:ShowItemTips(cfgvo.id)
					end;
				else
					TipsManager:ShowItemTips(cfgvo.id)
				end
			end
		end
	end
end

function UIRealmMainView:OnBtnGetItemClick()
	if not MapUtils:CanTeleport() then
		FloatManager:AddCenter( StrConfig['realm29'] );
		return;
	end
	
	local realmcfg = t_jingjie[RealmModel:GetRealmOrder()];
	if realmcfg then
		local point = QuestUtil:GetQuestPos(tonumber(realmcfg.position));
		local completeFuc = function()
			AutoBattleController:OpenAutoBattle();
		end
		MainPlayerController:DoAutoRun(point.mapId,_Vector3.new(point.x,point.y,0),completeFuc);
	end
end

function UIRealmMainView:OnbtnGetItemRollOver()
	local realmcfg = t_jingjie[RealmModel:GetRealmOrder()];
	if realmcfg then
		TipsManager:ShowBtnTips(realmcfg.tips,TipsConsts.Dir_RightDown);
	end
end

-- 上一级
function UIRealmMainView:OnBtnPreClick()
	self.curRealmOrder = self.curRealmOrder - 1;
	UIRealmMainView:ShowRealmInfo(self.curRealmOrder)
end

-- 下一级
function UIRealmMainView:OnBtnNextClick()
	self.curRealmOrder = self.curRealmOrder + 1;
	UIRealmMainView:ShowRealmInfo(self.curRealmOrder)
end

function UIRealmMainView:OnSkinChange()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self:ShowSkin();
end

function UIRealmMainView:OnBtnGongGuClick()
	local objSwf = self.objSwf
	if not objSwf then return end
	
	local itemId, itemNum, isEnough = RealmUtil:GetGongGuFloodItem();
	if not isEnough then
		FloatManager:AddNormal( StrConfig["realm49"], objSwf.gongguPanel.progresspanel.gonggupanel.btnGongGu);
		return;
	end
	
	--大量灵石
	local isauto ,progressnum = RealmUtil:GetIsAutoGongGu();
	if isauto == true then
		local confirmFunc = function()
			RealmController:ReqStrenthenChong(RealmModel:GetChongId(), progressnum);
		end
		self.confirmUID = UIConfirm:Open( StrConfig["realm61"], confirmFunc );
	else
		RealmController:ReqStrenthenChong(RealmModel:GetChongId(), 1);
	end
end

function UIRealmMainView:OnBtnGongGurollOver()
	TipsManager:ShowBtnTips(string.format(StrConfig["realm53"], RealmUtil:GetChongAddPercent()),TipsConsts.Dir_RightDown);
end

function UIRealmMainView:OnBtnGongGurollOut()
	TipsManager:Hide();
end

function UIRealmMainView:OnBtnGongGuBreakClick()
	local objSwf = self.objSwf
	if not objSwf then return end
	
	local itemId, itemNum, isEnough = RealmUtil:GetGongGuBreakItem();
	if not isEnough then
		FloatManager:AddNormal( StrConfig["realm50"], objSwf.gongguPanel.progresspanel.tupopanel.btnbreak);
		return;
	end
	RealmController:ReqStrenthenBreak(RealmModel:GetChongId());
end

function UIRealmMainView:OnBtnGongGuBreakrollOver()
	local objSwf = self.objSwf
	if not objSwf then return end
	local list = RealmUtil:GetChongAttrAddList();
	for _, type in pairs( RealmConsts.Attrs ) do
		if list[type] then
			objSwf["tfgongguadd"..type].text = "+"..list[type];
		end
	end
	
	TipsManager:ShowBtnTips(string.format(StrConfig["realm53"], RealmUtil:GetChongAddPercent()),TipsConsts.Dir_RightDown);
end

function UIRealmMainView:OnBtnGongGuBreakrollOut()
	local objSwf = self.objSwf
	if not objSwf then return end
	for _, type in pairs( RealmConsts.Attrs ) do
		objSwf["tfgongguadd"..type].text = "";
	end
	TipsManager:Hide();
end
	
function UIRealmMainView:OnBtnGongGuConsumeRollOver()
	local cfg = t_jingjiegonggu[RealmModel:GetChongId()];
	if not cfg then
		return;
	end
	if RealmModel:GetChongProgress() < cfg.max then
		local itemId, itemNum, isEnough = RealmUtil:GetGongGuFloodItem();
		if t_item[itemId] then
			TipsManager:ShowItemTips(itemId);
		end
	else
		local itemId, itemNum, isEnough = RealmUtil:GetGongGuBreakItem();
		if t_item[itemId] then
			TipsManager:ShowItemTips(itemId);
		end
	end
end

function UIRealmMainView:OnNumValueLoadComplete(e)
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.gongguPanel.progresspanel.gonggupanel.proLoaderValue._x = objSwf.gongguPanel.progresspanel.gonggupanel.posSign._x - objSwf.gongguPanel.progresspanel.gonggupanel.proLoaderValue.width
end

function UIRealmMainView:OnBtnGongGuProrollOver()
	TipsManager:ShowBtnTips(StrConfig["realm56"],TipsConsts.Dir_RightDown);
end

function UIRealmMainView:OnTabButtonClick(index)
	self.curRealmGongGuId = self.curRealmOrder * 100 + index;
	local body = {};
	body.istab = true;
	self:ShowRealmGongGuInfo(self.curRealmGongGuId, body);
end

function UIRealmMainView:OnChkBoxUseModelClick()
	local objSwf = self.objSwf
	if not objSwf then return end
	local curRealmOrder = self.curRealmOrder
	if not curRealmOrder then return end
	local useThisModel = objSwf.chkBoxUseModel.selected
	local currentLevel = RealmModel:GetSelectId()
	if currentLevel == curRealmOrder and useThisModel == false then
		-- objSwf.chkBoxUseModel.selected = true
		if self.curRealmGongGuId == 0 then
			return;
		end 
		if self.curRealmGongGuId == RealmModel:GetSelectId() then
			return;
		end
	end
	
	local modelLevel = useThisModel and curRealmOrder or currentLevel
	if self.curRealmGongGuId > 0 then
		modelLevel = self.curRealmGongGuId;
	end
	
	if modelLevel == RealmModel:GetChongId() then
		FloatManager:AddNormal( StrConfig["realm51"], objSwf.chkBoxUseModel);
		objSwf.chkBoxUseModel.selected = false;
		return;
	end
	
	RealmController:ReqChangeRealmModel(modelLevel)
end

-------------------事件------------------
function UIRealmMainView:HandleNotification(name,body)
	if not self.bShowState then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if name == NotifyConsts.RealmProgress then--境界灌注进度改变
		self:ShowOrderUpPanel(body);
		self:UpdateProDataInfo(body.list);
		self:ShowFight();
		self:ShowRealmMainInfo();
		--self:ShowAttrRed()
		SoundManager:PlaySfx(2040);
		self:SetXiuweiChiVal();
	elseif name == NotifyConsts.RealmBreakProgress then--境界进阶进度改变
		self:ShowOrderUpPanel(body);
		self:PlayJinJieSound();
		SoundManager:PlaySfx(2040);
	elseif name == NotifyConsts.RealmBreakSuccess then--境界升阶成功 
		self:InitData(true);
		self:InitUI();
		self:ShowRealmMainInfo();
		--self:ShowAttrRed()
		RealmController:ReqGetRealmMax();
		self:PlaySucEffect();
		RealmController:SetAutoLevelUp(false);
		SoundManager:PlaySfx(2030);
	elseif name == NotifyConsts.BagItemNumChange then
		self:ShowBtn();
		self:ShowRealmGongGuInfo();
		--self:ShowAttrRed()
	elseif name == NotifyConsts.RealmMaxUpdate then
		self:ShowBtn();
	elseif name == NotifyConsts.PlayerAttrChange then
		if body.type==enAttrType.eaExp then
			self:UpdateExpInfo();
		elseif body.type==enAttrType.eaBindGold or body.type==enAttrType.eaUnBindGold then
			self:ShowBtn();
		elseif body.type==enAttrType.eaFight then
			self:ShowFight();
		end
	elseif name == NotifyConsts.StrenthenUpdate then
		self:ShowRealmGongGuInfo(nil, body);
		self:ShowAttrInfo();
		self:ShowFight();
	elseif name == NotifyConsts.RealmModelChange then
		self:ShowUseModelState();
	elseif name == NotifyConsts.RealmSXDChanged then
		self:ShowAttrInfo();
		--self:ShowAttrRed()
	elseif name == NotifyConsts.VipJihuoEffect then 
		self:ShowvipEffect()
	elseif name ==	NotifyConsts.VipBackInfo then 
		self:ShowvipEffect();
	elseif name ==	NotifyConsts.UseZZDChanged then
		--self:ShowAttrRed()
    elseif name ==  NotifyConsts.VipBackInfoChange then 
    	self:showVipBackInfo()
    	self:ShowvipEffect();
	elseif name ==  NotifyConsts.XiuweiPoolUpdate then
		self:SetXiuweiChiVal();
		self:ShowBtn();
	end
end

function UIRealmMainView:ListNotificationInterests()
	return {NotifyConsts.RealmProgress,NotifyConsts.StrenthenUpdate,
			NotifyConsts.RealmBreakSuccess,NotifyConsts.BagItemNumChange,
			NotifyConsts.RealmMaxUpdate,NotifyConsts.PlayerAttrChange,
			NotifyConsts.RealmBreakProgress,NotifyConsts.RealmModelChange,
			NotifyConsts.VipJihuoEffect,NotifyConsts.VipBackInfo,NotifyConsts.UseZZDChanged,
			NotifyConsts.VipBackInfoChange,NotifyConsts.XiuweiPoolUpdate,NotifyConsts.RealmSXDChanged};
end

-- 初始化数据
function UIRealmMainView:InitData(iscurorder)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	--显示当前境界
	if iscurorder then
		self.curRealmOrder = RealmModel:GetRealmOrder();
		self.curRealmGongGuId = RealmUtil:GetChongIdByOrder(self.curRealmOrder);
	--显示当前巩固的境界重
	else
		local chongId = RealmModel:GetChongId();
		if chongId == 0 then
			self.curRealmOrder = RealmModel:GetRealmOrder();
			self.curRealmGongGuId = 0;
		else
			self.curRealmOrder = toint(chongId / 100);
			self.curRealmGongGuId = RealmUtil:GetChongIdByOrder(self.curRealmOrder);
		end
	end
	
	self.isShowClearConfirm = true;
	
end
--请求vip 返还信息
function UIRealmMainView:showVipBackInfo()
    VipController:ReqVipBackInfo(VipConsts.TYPE_REALM);
end
function UIRealmMainView:InitUI()
	local objSwf = self.objSwf;
	if not objSwf then return; end
end

--显示
function UIRealmMainView:ShowRealmInfo(order)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	order = order or self:GetCurRealmOrder();
	self.curRealmGongGuId = RealmUtil:GetChongIdByOrder(order);
	local cfg = t_jingjie[order];
	if cfg then
		--境界名称
		objSwf.nameLoader.source =  ResUtil:GetRealmIconName(cfg.nameicon);
		--境界背景
		objSwf.bgLoader.source =  ResUtil:GetRealmBg(cfg.bg);
		--境界图标
		objSwf.tubiaoLoader.source =  ResUtil:GetRealmIconName(cfg.tubiao);
		--等阶
		objSwf.lvlLoader.source = ResUtil:GetRealmlv("v_jieshu_"..order);
		--巩固图标
		if self.curRealmGongGuId > 0 then
			local gonggucfg = t_jingjiegonggu[self.curRealmGongGuId];
			if gonggucfg and gonggucfg.nameicon ~= "" then
				local iconStr = ResUtil:GetRealmIconName(gonggucfg.nameicon);
				if objSwf.gongguLoader.source ~= iconStr then
					objSwf.gongguLoader.source = iconStr;
				end
			end
		else
			objSwf.gongguLoader:unload();
		end
		
		--显示特效
		self:ShowRealmEffect();
		
		--显示升阶面板
		local body = {};
		body.isShow = true;
		self:ShowOrderUpPanel(body);
		
		--显示属性加成
		self:ShowAttrInfo();
		
		--显示战斗力
		self:ShowFight();
		
		--显示技能信息
		self:ShowSkillInfo();
		
		--显示相关系统
		self:ShowLinkFunc();
		
		--显示预览按钮
		self:ShowPreNextBtn();
		
		--显示切换模型
		self:ShowUseModelState();
	end
end

--显示
function UIRealmMainView:ShowRealmGongGuInfo(Id,body)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if self.curRealmOrder == toint(RealmModel:GetChongId() / 100) then
		self.curRealmGongGuId = Id or RealmModel:GetChongId();
	end
	if body and body.isTuPo then
		--突破到下一阶，即本阶最高级
		if RealmModel:GetChongId() % 100 == 1 then
			if objSwf.btnNext.disabled == false then
				self:OnBtnNextClick();
			end
		end
	end
	
	local order = self:GetCurRealmOrder();
	local cfg = t_jingjie[order];
	if cfg then
		--境界名称
		--objSwf.nameLoader.source =  ResUtil:GetRealmIconName(cfg.nameicon);
		--境界图标
		--objSwf.tubiaoLoader.source =  ResUtil:GetRealmIconName(cfg.tubiao);
		--巩固图标
		if body and (body.isTuPo or body.istab) then
			if self.curRealmGongGuId > 0 then
				local gonggucfg = t_jingjiegonggu[self.curRealmGongGuId];
				if gonggucfg and gonggucfg.nameicon ~= "" then
					local iconStr = ResUtil:GetRealmIconName(gonggucfg.nameicon);
					if objSwf.gongguLoader.source ~= iconStr then
						objSwf.gongguLoader.source = iconStr;
					end
				end
			else
				objSwf.gongguLoader:unload();
			end
		end
		
		--显示升阶面板
		self:ShowOrderUpPanel(body);
		
		--显示属性加成
		self:ShowAttrInfo();
		
		--显示切换模型
		self:ShowUseModelState();
	end
end
function UIRealmMainView:ShowvipEffect()
	local objSwf = self.objSwf;
	if not objSwf then return; end

	local vo = VipModel:GetBackItemInfo(VipConsts.TYPE_REALM);
    if vo and vo.itemNum>0 then 
    	objSwf.vipeffect._visible=true
    	return  
    end
    objSwf.vipeffect._visible=false
end
function UIRealmMainView:ShowRealmEffect()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local func = function ()
		if not self:IsShow() then return; end
		if not objSwf then return; end
		if not objSwf.bgLoaderEffect then return; end
		if objSwf.bgLoaderEffect.source ~= ResUtil:GetRealmEffect(self.curRealmOrder) then
			objSwf.bgLoaderEffect.source = ResUtil:GetRealmEffect(self.curRealmOrder)
		end
	end
	
	-- objSwf.bgLoaderEffect:unload();
	-- objSwf.bgLoaderEffect.source = nil;
	UILoaderManager:LoadList({ResUtil:GetRealmEffect(self.curRealmOrder)},func);
end

function UIRealmMainView:GetCurRealmOrder()
	return self.curRealmOrder;
end

--显示
function UIRealmMainView:ShowRealmMainInfo(order)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local curorder = order or RealmModel:GetRealmOrder();
	-- print("______curorder",curorder)
	local cfg = t_jingjie[curorder];
	-- print("______curorder",cfg)
	-- debug.debug()
	if cfg then
		--境界名称
		local jingjieName = ResUtil:GetRealmIconName(cfg.nameicon);
		if objSwf.nameLoader.source ~=  jingjieName then
			objSwf.nameLoader.source =  jingjieName
		end
		--境界背景
		local jingjieIcon = ResUtil:GetRealmBg(cfg.bg);
		if objSwf.bgLoader.source ~=  jingjieIcon then
			objSwf.bgLoader.source =  jingjieIcon
		end
		--境界图标 .
		objSwf.tubiaoLoader.source =  ResUtil:GetRealmIconName(cfg.tubiao);
		--等阶
		local iconUrl = ResUtil:GetRealmlv("v_jieshu_"..curorder);
		if objSwf.lvlLoader.source ~= iconUrl then
			objSwf.lvlLoader.source = iconUrl
		end
		 
		--巩固图标
		if self.curRealmGongGuId > 0 then
			local gonggucfg = t_jingjiegonggu[self.curRealmGongGuId];
			if gonggucfg and gonggucfg.nameicon ~= "" then
				local iconStr = ResUtil:GetRealmIconName(gonggucfg.nameicon);
				if objSwf.gongguLoader.source ~= iconStr then
					objSwf.gongguLoader.source = iconStr;
				end
			end
		else
			objSwf.gongguLoader:unload();
		end
		
		--显示特效
		self:ShowRealmEffect();
		
		--显示升阶面板
		local body = {};
		body.isShow = true;
		self:ShowOrderUpPanel(body);
		
		--显示属性加成
		self:ShowAttrInfo();
		
		--显示战斗力
		self:ShowFight();
		
		--显示技能信息
		self:ShowSkillInfo();
		
		--显示相关系统
		self:ShowLinkFunc();
		
		--显示预览按钮
		self:ShowPreNextBtn();
		
		--显示切换模型
		self:ShowUseModelState();
	end
end

function UIRealmMainView:InitVip()
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.btnVipLvUp.click = function() UIVip:Show() end	
	objSwf.btnVipLvUp.rollOver = function(e) 
		local attMap = self:GetAttMap()
		VipController:ShowAttrTips( attMap, UIVipAttrTips.jj,VipConsts.TYPE_DIAMOND )
	end
	objSwf.btnVipLvUp.rollOut = function(e) VipController:HideAttrTips() end
end

--显示信息
function UIRealmMainView:GetAttMap()	
	--基本信息
	local info = RealmModel:GetAttrList();
	if info == nil then
		return nil
	end
	local attMap = {}
	-- local isNull = true;
	for _, type in pairs( RealmConsts.Attrs ) do
		for i,vo in ipairs(info) do
			-- if vo.val > 0 then
				-- isNull = false;
			-- end
			if vo.type == AttrParseUtil.AttMap[type] then
				table.push(attMap,{proKey = type, proValue = vo.val})
				break;
			end
		end
	end
	-- if isNull then
		-- return nil;
	-- end
	return attMap
end

function UIRealmMainView:GetListUIVO(Id)
	local vo = {};
	vo.order = Id;
	
	local realmvo = t_jingjie[Id];
	if not realmvo then
		return;
	end

	if RealmModel:GetRealmOrder() >= Id then
		vo.isget = true;
		vo.iconURL = ResUtil:GetRealmIconName(realmvo.button_tubiao .."_"..Id);
		vo.namePicURL = ResUtil:GetRealmIconName(realmvo.button_nameicon .."_"..Id);
	else
		vo.isget = false;
		vo.iconURL = ResUtil:GetRealmIconName(realmvo.button_tubiao.."_hui_"..Id);
		vo.namePicURL = ResUtil:GetRealmIconName(realmvo.button_nameicon.."_hui_"..Id);
	end
	return vo;
end

function UIRealmMainView:GetListUIData()
	local list = {};
	table.insert(list, "");
	for _, vo in ipairs(self.list) do
		local uiData = UIData.encode(vo);
		table.insert(list, uiData);
	end
	table.insert(list, "");
	return list;
end
function UIRealmMainView:ShowAttrRed()
 
    local objSwf = self.objSwf;
	if not objSwf then return; end

	local cfg =t_jingjie[RealmModel.realmOrder];
	if not cfg then
		return;
	end
	if cfg.zizhi_dan <= 0 or cfg.jingjie_dan <= 0 then

		objSwf.btnZZD.effect._visible=false;
		objSwf.btnShuXingDan.effect._visible=false;
		return;
	end
	--资质丹上限
	local zzdCount = 0
	for k,cfg in pairs(t_jingjie) do
		if cfg.id == RealmModel.realmOrder then
			zzdCount = cfg.zizhi_dan
			break
		end
	end
	if ZiZhiModel:GetZZNum(5) >= zzdCount or ZiZhiUtil:GetZZItemNum(5) <= 0 then
		objSwf.btnZZD.effect._visible=false;
	else
		objSwf.btnZZD.effect._visible=true;
	end

    --属性丹上限
	local sXDCount = 0
	for k,cfg in pairs(t_jingjie) do
		if cfg.id == RealmModel.realmOrder then
			sXDCount = cfg.jingjie_dan
			break
		end
	end
	--已达到上限
	if RealmModel:GetPillNum() >= sXDCount or  MountUtil:GetJieJieItemNum(14) <= 0 then
		objSwf.btnShuXingDan.effect._visible=false;
	else
		objSwf.btnShuXingDan.effect._visible=true;
	end
end
--显示升阶面板
function UIRealmMainView:ShowOrderUpPanel(body)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	-- 进度条界面
	objSwf.orderuppanel._visible = false;
	objSwf.btnfloodtool.htmlLabel = "";
	objSwf.btntoolget.visible = false;
	objSwf.jinjiepanel._visible = false;
	objSwf.gongguPanel._visible = false;
	
	if self.curRealmOrder == RealmModel:GetRealmOrder() then
		--显示星等级
		self:ShowXingLevel();
		
		--显示进度条
		self:ShowProgress(body);
		
		--显示按钮
		self:ShowBtn();
		--显示进度条
		self:SetXiuweiChiVal()
	else
		--显示巩固信息
		self:ShowGongGuInfo(body);
	end
end

--显示星等级
function UIRealmMainView:ShowXingLevel()
	local objSwf = self.objSwf;
	if not objSwf then return; end

end

--显示进度条
function UIRealmMainView:ShowProgress(body)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	-- 境界等阶
	local cfg = t_jingjie[RealmModel:GetRealmOrder()];
	if cfg then
		if RealmUtil:GetIsFullProgress() == true then
			if body and body.istween then
				objSwf.jinjiepanel.siBlessing:tweenProgress( RealmModel:GetBreakProgress(), cfg.wish_max, 0 );
			else
				objSwf.jinjiepanel.siBlessing:setProgress( RealmModel:GetBreakProgress(), cfg.wish_max );
			end
	
			objSwf.jinjiepanel.proLoaderValue:drawStr( tostring(RealmModel:GetBreakProgress()));
			
			--增加的数值提示
			if body and body.istween and body.addnum > 0 then
				if body.addnum >= cfg.wish_interval[1] * 2 then
					local pos = UIManager:PosLtoG(objSwf.jinjiepanel.doubleLoader,0,0);
					UIBingNuFloat:PlayEffect(ResUtil:GetChengZhangDoubleUrl(),pos,body.addnum);
				else
					FloatManager:AddNormal( string.format(StrConfig["realm47"], body.addnum) , objSwf.jinjiepanel.btnnumaddshow)
				end
			end
		else
			if RealmModel:GetRealmProgress() == 0 then
				objSwf.orderuppanel.progressBar:setProgress( RealmModel:GetRealmProgress(), cfg.item_max2 )
			else
				if body and body.list then
					objSwf.orderuppanel.progressBar:tweenProgress( RealmModel:GetRealmProgress(), cfg.item_max2, 0 )
				else
					objSwf.orderuppanel.progressBar:setProgress( RealmModel:GetRealmProgress(), cfg.item_max2 )
				end
			end
			-- objSwf.orderuppanel.leftpronum.num = RealmModel:GetRealmProgress();
			-- objSwf.orderuppanel.rightpronum.num = cfg.item_max2;
			objSwf.orderuppanel.proText.text = RealmModel:GetRealmProgress().."/"..cfg.item_max2
		end
	end
end

--显示(境界提升度+26)
function UIRealmMainView:ShowUpShuZhi(addProgress)
	local objSwf = self.objSwf
	if not objSwf then return end
	
	if objSwf.orderuppanel._visible == true then
		FloatManager:AddNormal( string.format(StrConfig["realm22"], addProgress) , objSwf.orderuppanel.btnnumaddshow);
	end
end

--获得境界vip加成百分比
function UIRealmMainView:GetJingjieLvUp()
	if VipController:GetJingjieLvUp() > 0 then
		return VipController:GetJingjieLvUp()/100;
	end
	return 0;
end

local posList = nil;
--显示属性加成
function UIRealmMainView:ShowAttrInfo(showtype)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local cfg = t_jingjie[self.curRealmOrder];
	if not cfg then
		return;
	end
	local nextcfg = t_jingjie[RealmModel:GetRealmOrder() + 1];
	local precfg = t_jingjie[toint(RealmModel:GetChongId() / 100) - 1];
	local curcfg = t_jingjie[toint(RealmModel:GetChongId() / 100)];
	
	--进度条
	for _, type in ipairs( RealmConsts.Attrs ) do
		objSwf["tfgongguadd"..type].text = "";
		if cfg[type] > 0 then
			objSwf[type.."pro"].visible = true;
			objSwf["label"..type]._visible = true;
			objSwf[type.."pro"].maximum = 100;
			objSwf[type.."pro"].value = 0;
			objSwf["tf"..type]._visible = false;
			objSwf[type.."numpanel"]._visible = true;
			
			if RealmUtil:IsHaveAttrPro(type) == false then
				objSwf[type.."numpanel"].attleftpronum.num = 0;
				objSwf[type.."numpanel"].attrightpronum.num = cfg[type.."max"];
			end
		else
			objSwf[type.."pro"].visible = false;
			objSwf["label"..type]._visible = false;
			objSwf["tf"..type]._visible = false;
			objSwf[type.."numpanel"]._visible = false;
		end
	end
	
	--如果是预览
	if self.curRealmOrder > RealmModel:GetRealmOrder() then
		for _, type in ipairs( RealmConsts.Attrs ) do
			if cfg[type] > 0 then
				objSwf["tf"..type].text = cfg[type.."max"].."/"..cfg[type.."max"]..StrConfig["realm39"];
				objSwf["tf"..type]._visible = true;
				objSwf[type.."numpanel"]._visible = false;
			end
		end
		return;
	end
	local shows = {};
	local list,attrmap = RealmUtil:GetGongGuAttrList();
	local info = RealmModel:GetAttrList();
	-- UILog:print_table(info)
	if info then
		for i,vo in ipairs(info) do
			--百分比加成,VIP加成
			local val = vo.val;
			local addP = 0;
			if Attr_AttrPMap[vo.type] then
				addP = MainPlayerModel.humanDetailInfo[Attr_AttrPMap[vo.type]];
			end
--			val = toint(val * (1+addP+self:GetJingjieLvUp()));
			if vo.type == enAttrType.eaGongJi then
				if attrmap and attrmap.att then
					val = val + attrmap.att;
				end
				local strchongadd = "";
				local chongId = RealmUtil:GetChongIdByOrder(self.curRealmOrder);
				if chongId % 100 > 1 then
					if toint(chongId / 100) >= self.curRealmOrder then
						if toint(chongId / 100) < toint(RealmModel:GetChongId() / 100) then
							strchongadd = "(+"..t_jingjiegonggu[chongId].attr.."%)"
						else
							strchongadd = "(+"..t_jingjiegonggu[chongId-1].attr.."%)"
						end
					end
				end
				objSwf.attpro.maximum = cfg.attmax;
				objSwf.attpro.value = val;
				--objSwf.attnumpanel.attleftpronum.num = val;
				--objSwf.attnumpanel.attrightpronum.num = cfg.attmax;
				if showtype and showtype == 2 and nextcfg then
					objSwf.tfatt.htmlText = val.."/"..cfg.attmax..strchongadd..string.format(StrConfig["realm323"],(nextcfg.attmax - cfg.attmax));
				else
					objSwf.tfatt.text = val.."/"..cfg.attmax..strchongadd;
				end
				objSwf.tfatt._visible = true;
				objSwf.attnumpanel._visible = false;
				
				table.push(shows,vo.type);
			elseif vo.type == enAttrType.eaFangYu then
				if attrmap and attrmap.def then
					val = val + attrmap.def;
				end
				local strchongadd = "";
				local chongId = RealmUtil:GetChongIdByOrder(self.curRealmOrder);
				if chongId % 100 > 1 then
					if toint(chongId / 100) >= self.curRealmOrder then
						if toint(chongId / 100) < toint(RealmModel:GetChongId() / 100) then
							strchongadd = "(+"..t_jingjiegonggu[chongId].attr.."%)"
						else
							strchongadd = "(+"..t_jingjiegonggu[chongId-1].attr.."%)"
						end
					end
				end
				objSwf.defpro.maximum = cfg.defmax;
				objSwf.defpro.value = val;
				-- objSwf.defnumpanel.attleftpronum.num = val;
				-- objSwf.defnumpanel.attrightpronum.num = cfg.defmax;
				if showtype and showtype == 2 and nextcfg then
					objSwf.tfdef.htmlText = val.."/"..cfg.defmax..strchongadd..string.format(StrConfig["realm323"],(nextcfg.defmax - cfg.defmax));
				else
					objSwf.tfdef.text = val.."/"..cfg.defmax..strchongadd;
				end
				objSwf.tfdef._visible = true;
				objSwf.defnumpanel._visible = false;
				
				table.push(shows,vo.type);
			elseif vo.type == enAttrType.eaMaxHp then
				if attrmap and attrmap.hp then
					val = val + attrmap.hp;
				end
				local strchongadd = "";
				local chongId = RealmUtil:GetChongIdByOrder(self.curRealmOrder);
				if chongId % 100 > 1 then
					if toint(chongId / 100) >= self.curRealmOrder then
						if toint(chongId / 100) < toint(RealmModel:GetChongId() / 100) then
							strchongadd = "(+"..t_jingjiegonggu[chongId].attr.."%)"
						else
							strchongadd = "(+"..t_jingjiegonggu[chongId-1].attr.."%)"
						end
					end
				end
				objSwf.hppro.maximum = cfg.hpmax;
				objSwf.hppro.value = val;
				-- objSwf.hpnumpanel.attleftpronum.num = val;
				-- objSwf.hpnumpanel.attrightpronum.num = cfg.hpmax;
				if showtype and showtype == 2 and nextcfg then
					objSwf.tfhp.htmlText = val.."/"..cfg.hpmax..strchongadd..string.format(StrConfig["realm323"],(nextcfg.hpmax - cfg.hpmax));
				else
					objSwf.tfhp.text = val.."/"..cfg.hpmax..strchongadd;
				end
				objSwf.tfhp._visible = true;
				objSwf.hpnumpanel._visible = false;
				
				table.push(shows,vo.type);
			elseif vo.type == enAttrType.eaRenXing then
				if attrmap and attrmap.defcri then
					val = val + attrmap.defcri;
				end
				local strchongadd = "";
				local chongId = RealmUtil:GetChongIdByOrder(self.curRealmOrder);
				if chongId % 100 > 1 then
					if toint(chongId / 100) >= self.curRealmOrder then
						if toint(chongId / 100) < toint(RealmModel:GetChongId() / 100) then
							strchongadd = "(+"..t_jingjiegonggu[chongId].attr.."%)"
						else
							strchongadd = "(+"..t_jingjiegonggu[chongId-1].attr.."%)"
						end
					end
				end
				objSwf.defcripro.maximum = cfg.defcrimax;
				objSwf.defcripro.value = val;
				-- objSwf.defcrinumpanel.attleftpronum.num = val;
				-- objSwf.defcrinumpanel.attrightpronum.num = cfg.defcrimax;
				if showtype and showtype == 2 and nextcfg then
					objSwf.tfdefcri.htmlText = val.."/"..cfg.defcrimax..strchongadd..string.format(StrConfig["realm323"],(nextcfg.defcrimax - cfg.defcrimax));
				else
					objSwf.tfdefcri.text = val.."/"..cfg.defcrimax..strchongadd;
				end
				objSwf.tfdefcri._visible = true;
				objSwf.defcrinumpanel._visible = false;
				
				table.push(shows,vo.type);
			elseif vo.type == enAttrType.eaBaoJi then
				if attrmap and attrmap.hit then
					val = val + attrmap.hit;
				end
				local strchongadd = "";
				local chongId = RealmUtil:GetChongIdByOrder(self.curRealmOrder);
				if chongId % 100 > 1 then
					if toint(chongId / 100) >= self.curRealmOrder then
						if toint(chongId / 100) < toint(RealmModel:GetChongId() / 100) then
							strchongadd = "(+"..t_jingjiegonggu[chongId].attr.."%)"
						else
							strchongadd = "(+"..t_jingjiegonggu[chongId-1].attr.."%)"
						end
					end
				end
				objSwf.cripro.maximum = cfg.crimax;
				objSwf.cripro.value = val;
				-- objSwf.crinumpanel.attleftpronum.num = val;
				-- objSwf.crinumpanel.attrightpronum.num = cfg.crimax;
				if showtype and showtype == 2 and nextcfg then
					objSwf.tfcri.htmlText = val.."/"..cfg.crimax..strchongadd..string.format(StrConfig["realm323"],(nextcfg.crimax - cfg.crimax));
				else
					objSwf.tfcri.text = val.."/"..cfg.crimax..strchongadd;
				end
				objSwf.tfcri._visible = false;
				if cfg.crimax > 0 then
					objSwf.tfcri._visible = true;
				end
				objSwf.crinumpanel._visible = false;
				
				table.push(shows,vo.type);
			elseif vo.type == enAttrType.eaShanBi then
				if attrmap and attrmap.dodge then
					val = val + attrmap.dodge;
				end
				local strchongadd = "";
				local chongId = RealmUtil:GetChongIdByOrder(self.curRealmOrder);
				if chongId % 100 > 1 then
					if toint(chongId / 100) >= self.curRealmOrder then
						if toint(chongId / 100) < toint(RealmModel:GetChongId() / 100) then
							strchongadd = "(+"..t_jingjiegonggu[chongId].attr.."%)"
						else
							strchongadd = "(+"..t_jingjiegonggu[chongId-1].attr.."%)"
						end
					end
				end
				objSwf.dodgepro.maximum = cfg.dodgemax;
				objSwf.dodgepro.value = val;
				-- objSwf.dodgenumpanel.attleftpronum.num = val;
				-- objSwf.dodgenumpanel.attrightpronum.num = cfg.dodgemax;
				if showtype and showtype == 2 and nextcfg then
					objSwf.tfdodge.htmlText = val.."/"..cfg.dodgemax..strchongadd..string.format(StrConfig["realm323"],(nextcfg.dodgemax - cfg.dodgemax));
				else
					objSwf.tfdodge.text = val.."/"..cfg.dodgemax..strchongadd;
				end
				objSwf.tfdodge._visible = false;
				if cfg.dodgemax > 0 then
					objSwf.tfdodge._visible = true;
				end
				objSwf.dodgenumpanel._visible = false;
				
				table.push(shows,vo.type);
			elseif vo.type == enAttrType.eaMingZhong then
				if attrmap and attrmap.cri then
					val = val + attrmap.cri;
				end
				local strchongadd = "";
				local chongId = RealmUtil:GetChongIdByOrder(self.curRealmOrder);
				if chongId % 100 > 1 then
					if toint(chongId / 100) >= self.curRealmOrder then
						if toint(chongId / 100) < toint(RealmModel:GetChongId() / 100) then
							strchongadd = "(+"..t_jingjiegonggu[chongId].attr.."%)"
						else
							strchongadd = "(+"..t_jingjiegonggu[chongId-1].attr.."%)"
						end
					end
				end
				objSwf.hitpro.maximum = cfg.hitmax;
				objSwf.hitpro.value = val;
				-- objSwf.hitnumpanel.attleftpronum.num = val;
				-- objSwf.hitnumpanel.attrightpronum.num = cfg.hitmax;
				if showtype and showtype == 2 and nextcfg then
					objSwf.tfhit.htmlText = val.."/"..cfg.hitmax..strchongadd..string.format(StrConfig["realm323"],(nextcfg.hitmax - cfg.hitmax));
				else
					objSwf.tfhit.text = val.."/"..cfg.hitmax..strchongadd;
				end
				objSwf.tfhit._visible = false;
				if cfg.hitmax > 0 then
					objSwf.tfhit._visible = true;
				end
				objSwf.hitnumpanel._visible = false;
				
				table.push(shows,vo.type);
			end
		end
	end
	
	local index = 0;
	for i,type in ipairs(RealmConsts.Attrs) do
		local panel1 = objSwf["label"..type];
		local panel2 = objSwf["tf"..type];
		local panel3 = objSwf[type.."pro"];
		local panel4 = objSwf["tfgongguadd"..type];
		local panel5 = objSwf[type.."numpanel"];
		
		local show = shows[i];
		if show then
			index = index + 1;
			local pos = self.posList[index][1];
			panel1._visible = true;
			panel1._x = pos.x;
			panel1._y = pos.y;
			
			pos = self.posList[index][2];
			panel2._visible = true;
			panel2._x = pos.x;
			panel2._y = pos.y;
			
			pos = self.posList[index][3];
			panel3._visible = true;
			panel3._x = pos.x;
			panel3._y = pos.y;
			
			pos = self.posList[index][4];
			panel4._visible = true;
			panel4._x = pos.x;
			panel4._y = pos.y;
			
			pos = self.posList[index][5];
			panel5._visible = false;
			panel5._x = pos.x;
			panel5._y = pos.y;
			
		else
			panel1._visible = false;
			panel2._visible = false;
			panel3._visible = false;
			panel4._visible = false;
			panel5._visible = false;
		end
		
	end
	
end

function UIRealmMainView:GetVIPFightAdd(level)
	if not level then
		level = RealmModel:GetLevel();
	end
	local vipUPRate = VipController:GetJingjieLvUp() / 100
	if vipUPRate <= 0 then
		vipUPRate = VipController:GetJingjieLvUp(1) / 100
	end
	local list = {};
	for i,v in ipairs(RealmModel:GetAttrList()) do
		local vo = {};
		vo.type = v.type;
		vo.val = v.val;
		local addP = 0;
		if Attr_AttrPMap[vo.type] then
			addP = MainPlayerModel.humanDetailInfo[Attr_AttrPMap[vo.type]];
		end
		vo.val = toint(vo.val * (1+addP+self:GetJingjieLvUp()));
		table.push(list,vo);
	end
	local gongguattrlist = RealmUtil:GetGongGuAttrList();
	list = RealmUtil:AddUpAttrIsNil(list,gongguattrlist);
	for k, v in pairs(list) do
		v.val = v.val * vipUPRate
	end
	return PublicUtil:GetFigthValue(list);
end

--显示战斗力
function UIRealmMainView:ShowFight()
	local objSwf = self.objSwf;
	if not objSwf then return; end

	local attrSXDMap = AttrParseUtil:ParseAttrToMap(t_consts[341].param);--属性丹

	--计算百分比加成,VIP加成
	local list = {};
	for i,v in ipairs(RealmModel:GetAttrList()) do
		local vo = {};
		vo.type = v.type;
		vo.val = v.val;
		local addP = 0;
		if Attr_AttrPMap[vo.type] then
			addP = MainPlayerModel.humanDetailInfo[Attr_AttrPMap[vo.type]];
		end
		local zzRate = ZiZhiUtil:GetZZTotalAddPercent(5);

		vo.val = toint(vo.val * (1+addP+self:GetJingjieLvUp() + zzRate));
		--属性丹
		vo.val = vo.val + (attrSXDMap[vo.type] or 0) * RealmModel:GetPillNum();
		table.push(list,vo);
	end
	local gongguattrlist = RealmUtil:GetGongGuAttrList();
	list = RealmUtil:AddUpAttrIsNil(list,gongguattrlist);

	objSwf.numFight.num = PublicUtil:GetFigthValue(list);
end

--显示技能信息
function UIRealmMainView:ShowSkillInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local cfg = t_jingjie[self.curRealmOrder];
	if not cfg then
		return;
	end
	
	local str = string.format(StrConfig["realm37"], cfg.name);
	local strname = StrConfig["realm54"];
	if toint(RealmModel:GetChongId() / 100) >= self.curRealmOrder then
		str = StrConfig["realm52"];
		strname = StrConfig["realm55"];
	end
	objSwf.tfskillinfo.htmlText = str;
	-- objSwf.tfskillname.htmlText = strname;
end

--更新进度值
function UIRealmMainView:UpdateProDataInfo(list)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local curorder = RealmModel:GetRealmOrder();
	local cfg = t_jingjie[curorder];
	if not cfg then
		return;
	end
	
	if not list then
		return;
	end
	
	for i,listvo in ipairs(list) do
		local attrlist = RealmModel:GetAttrList();
		for i,attrlistvo in ipairs(attrlist) do
			if listvo.type == attrlistvo.type then
				local val = attrlistvo.val;
				local addP = 0;
				if Attr_AttrPMap[attrlistvo.type] then
					addP = MainPlayerModel.humanDetailInfo[Attr_AttrPMap[attrlistvo.type]];
				end
				val = toint(val * (1+addP+self:GetJingjieLvUp()));
				if attrlistvo.type == enAttrType.eaGongJi then
					objSwf.attpro.maximum = cfg.attmax
					objSwf.attpro.value = val;
					objSwf.attnumpanel.attleftpronum.num = val;
					objSwf.attnumpanel.attrightpronum.num = cfg.attmax
				elseif attrlistvo.type == enAttrType.eaFangYu then
					objSwf.defpro.maximum = cfg.defmax
					objSwf.defpro.value = val;
					objSwf.defnumpanel.attleftpronum.num = val;
					objSwf.defnumpanel.attrightpronum.num = cfg.defmax
				elseif attrlistvo.type == enAttrType.eaMaxHp then
					objSwf.hppro.maximum = cfg.hpmax
					objSwf.hppro.value = val;
					objSwf.hpnumpanel.attleftpronum.num = val;
					objSwf.hpnumpanel.attrightpronum.num = cfg.hpmax
				elseif attrlistvo.type == enAttrType.eaRenXing then
					objSwf.defcripro.maximum = cfg.defcrimax
					objSwf.defcripro.value = val;
					objSwf.defcrinumpanel.attleftpronum.num = val;
					objSwf.defcrinumpanel.attrightpronum.num = cfg.defcrimax
				elseif attrlistvo.type == enAttrType.eaBaoJi then
					objSwf.cripro.maximum = cfg.crimax
					objSwf.cripro.value = val;
					objSwf.crinumpanel.attleftpronum.num = val;
					objSwf.crinumpanel.attrightpronum.num = cfg.crimax
				elseif attrlistvo.type == enAttrType.eaShanBi then
					objSwf.dodgepro.maximum = cfg.dodgemax
					objSwf.dodgepro.value = val;
					objSwf.dodgenumpanel.attleftpronum.num = val;
					objSwf.dodgenumpanel.attrightpronum.num = cfg.dodgemax
				elseif attrlistvo.type == enAttrType.eaMingZhong then
					objSwf.hitpro.maximum = cfg.hitmax
					objSwf.hitpro.value = val;
					objSwf.hitnumpanel.attleftpronum.num = val;
					objSwf.hitnumpanel.attrightpronum.num = cfg.hitmax
				end
			end
		end
	end
end

--显示相关系统
function UIRealmMainView:ShowLinkFunc()
	local objSwf = self.objSwf;
	if not objSwf then return; end
end

--显示预览按钮
function UIRealmMainView:ShowPreNextBtn()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	objSwf.btnPre.disabled = self.curRealmOrder <= 1;
	objSwf.btnNext.disabled = self.curRealmOrder >= RealmModel:GetRealmOrder() + 1;
	if self.curRealmOrder >= RealmModel:GetRealmOrder() and RealmModel:GetRealmOrder() >= RealmConsts.ordermax then
		objSwf.btnNext.disabled = true;
	end
end
--灌注消耗的修为球
function UIRealmMainView:SetXiuweiChiVal()
	local objSwf = self.objSwf;
	if not objSwf then return end;

	local cfg = t_xiuwei[1];
	if not cfg then 
		return 
	end;
	--单次境界修为的储存上限，要根据境界的阶进行提升
	local jjCfg = t_jingjie[RealmModel.realmOrder]
	if not jjCfg then 
		return 
	end;
	local curVal = XiuweiPoolModel:GetXiuwei();
	
	local maxVal = jjCfg.save_xiuweizhi;

	objSwf.orderuppanel.xiuweiChi_pro.maximum = toint(maxVal)
  	objSwf.orderuppanel.xiuweiChi_pro.value = toint(curVal);	
  	objSwf.orderuppanel.xiuweiChi_pro.proText.text = curVal.."/"..maxVal;	
  	-- 今日还可获得修为值
  	local accumulate = XiuweiPoolModel:getAccumulate()  --当日累积修为值
	local max_accumulate = jjCfg.daily_xiuweizhi
	local canGet = max_accumulate -accumulate
	-- objSwf.xiuweiVal_txt.htmlText =  string.format(StrConfig['xiuweiPool15'],canGet,max_accumulate)

end;
-- 修为球的悬浮tips
function UIRealmMainView:XiuweiChiTips()
	local cfg = t_xiuwei[1];
	if not cfg then 
		return 
	end;
	--单次境界修为的储存上限，要根据境界的阶进行提升
	local jjCfg = t_jingjie[RealmModel.realmOrder]
	if not jjCfg then 
		return 
	end;
  	-- 今日还可获得修为值
  	local accumulate = XiuweiPoolModel:getAccumulate()  --当日累积修为值
	local max_accumulate = jjCfg.daily_xiuweizhi
	local canGet = max_accumulate -accumulate
	local max_accumulate1 = max_accumulate/10000
	local str = string.format( StrConfig['xiuweiPool26'], max_accumulate1,canGet)
	TipsManager:ShowTips( TipsConsts.Type_Normal, str, TipsConsts.ShowType_Normal, TipsConsts.Dir_RightDown );
end;
--显示按钮
function UIRealmMainView:ShowBtn()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	if self.curRealmOrder ~= RealmModel:GetRealmOrder() then
		return;
	end
	
	objSwf.orderuppanel.btnfreeguanzhu.visible = false;
	objSwf.orderuppanel.btnvipguanzhu.visible = false;
	objSwf.orderuppanel.btnguanzhu.visible = false;
	objSwf.orderuppanel.guanzhuEffect._visible = false;
	objSwf.orderuppanel.guanzhutiaojianpanel._visible = false;
	
	objSwf.btnfloodtool.htmlLabel = "";
	objSwf.btntoolget.visible = false;
	objSwf.fullLevel._visible = false;
	
	--满阶满星满进度
	if RealmModel:GetRealmOrder() >= RealmConsts.ordermax and
	   RealmUtil:GetIsFullProgress() == true then
	   objSwf.fullLevel._visible = true;
		return;
	end
	
	if RealmUtil:GetIsFullProgress() == true then
		self:ShowConsumeMoney();
	else
		objSwf.orderuppanel._visible = true;
		objSwf.orderuppanel.btnfreeguanzhu.visible = false;
		objSwf.orderuppanel.btnvipguanzhu.visible = false;
		objSwf.orderuppanel.btnguanzhu.visible = false;
		objSwf.orderuppanel.guanzhuEffect._visible = false;
		objSwf.orderuppanel.guanzhutiaojianpanel._visible = false;
		
		objSwf.btnfloodtool.htmlLabel = "";
		objSwf.btntoolget.visible = false;
		
		objSwf.orderuppanel.btnguanzhu.visible = true;
		objSwf.orderuppanel.guanzhutiaojianpanel._visible = true;
		
		local cfg = t_jingjie[RealmModel:GetRealmOrder()];
		if cfg then
			--消耗道具
			local stritem = "";
			local intemNum = 0;
			local rewardList = RewardManager:ParseToVO(cfg.flood_item);
			for k,cfgvo in pairs(rewardList) do
				if cfgvo and t_item[cfgvo.id] then
					stritem = t_item[cfgvo.id].name..'X'..cfgvo.count;
					intemNum = BagModel:GetItemNumInBag(cfgvo.id);
				end
			end
			
			--是否满足灌注条件
			local ishave = true;
			
			local expcolor = "2fe00d";
			--经验不足
			if RealmUtil:GetIsHaveExp(RealmModel:GetRealmOrder()) == false then
				expcolor = "960000";
				ishave = false;
			end
			
			local toolcolor = "2fe00d";
			--道具不足
			if RealmUtil:GetIsHaveTool(RealmModel:GetRealmOrder()) == false then
				toolcolor = "960000";
				ishave = false;

				local reCfg = split(cfg.flood_item_daiti,',');
				if toint(reCfg[1]) > 0 then 
					local NbItemId = toint(reCfg[1]);
					local NbNum = BagModel:GetItemNumInBag(NbItemId);
					if NbNum >= toint(reCfg[2]) then 
						toolcolor = "2fe00d";
						ishave = true;
						stritem = t_item[NbItemId].name..'X'..reCfg[2]
						intemNum = NbNum
					end;
				end;
			end
			--显示灌注特效
			if ishave == true then
				objSwf.orderuppanel.guanzhuEffect._visible = true;
			end
			
			local floodexp = cfg.flood_exp;
			local pencent = RealmUtil:GetFloodExpNum();
			floodexp = math.modf(floodexp * pencent);
			objSwf.orderuppanel.guanzhutiaojianpanel.expinfo.htmlLabel = string.format(StrConfig["realm33"], expcolor, getNumShow(floodexp));
			-- objSwf.btnfloodtool.htmlLabel = string.format(StrConfig["realm34"], toolcolor, stritem)..string.format(StrConfig["realm38"], toolcolor, intemNum);
			--灌注消耗改为修为
			local xiuweizhi = cfg.xiuweizhi
			objSwf.btnfloodtool.htmlLabel = string.format(StrConfig["realm62"], toolcolor, xiuweizhi);
			--道具不足
			if RealmUtil:GetIsHaveTool(RealmModel:GetRealmOrder()) == false then
				toolcolor = "960000";
				ishave = false;

				local reCfg = split(cfg.flood_item_daiti,',');
				if toint(reCfg[1]) > 0 then 
					local NbItemId = toint(reCfg[1]);
					local NbNum = BagModel:GetItemNumInBag(NbItemId);
					if NbNum >= toint(reCfg[2]) then 
						toolcolor = "2fe00d";
						ishave = true;
						stritem = t_item[NbItemId].name..'X'..reCfg[2]
						intemNum = NbNum
						objSwf.btnfloodtool.htmlLabel = string.format(StrConfig["realm34"], toolcolor, stritem)..string.format(StrConfig["realm38"], toolcolor, intemNum);
					end;
				end;
			end
			
			--境界经验丹
			local danItem = t_item[tonumber(t_consts[125].val1)];
			if danItem then
				if RealmUtil:GetIsHaveRealmDanUp() == true then
					objSwf.orderuppanel.guanzhutiaojianpanel.ConstomRealmDanPanel.btnConsumeRealmDan.htmlLabel = string.format( StrConfig["realm46"], string.format( StrConfig["lianti8"], danItem.name.."1颗"));
				else
					objSwf.orderuppanel.guanzhutiaojianpanel.ConstomRealmDanPanel.btnConsumeRealmDan.htmlLabel = string.format( StrConfig["realm46"], string.format( StrConfig["lianti9"], danItem.name.."1颗"));
				end
			end
			
			if RealmModel:GetRealmOrder() <= 8 then
				-- objSwf.btntoolget.visible = true;
			end
		end
	end
end

function UIRealmMainView:ShowConsumeMoney()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	--消耗道具
	local realmcfg = t_jingjie[RealmModel:GetRealmOrder()];
	if realmcfg then
		objSwf.jinjiepanel._visible = true;
		objSwf.jinjiepanel.btnLvlUpEff._visible = false;
		objSwf.jinjiepanel.btnLvlUp:clearEffect();
		objSwf.jinjiepanel.btnAutoLvlUp:clearEffect();
		objSwf.jinjiepanel.btnAutoEff._visible = false; 
		objSwf.jinjiepanel.cbAutoBuy.selected = RealmModel.autoBuy;
		objSwf.jinjiepanel.tfcleardata.htmlText = "";
		
		local itemId, itemNum, isEnough = RealmUtil:GetConsumeItem(RealmModel:GetRealmOrder());
		objSwf.jinjiepanel.btnGotWay.htmlLabel = StrConfig["common002"];
		if isEnough then
			-- objSwf.jinjiepanel.btnLvlUpEff._visible = true;
			-- objSwf.jinjiepanel.btnAutoEff._visible = true;
			objSwf.jinjiepanel.btnConsume.htmlLabel = string.format(StrConfig["realm31"],t_item[itemId].name.."X"..itemNum);
			objSwf.jinjiepanel.txtMoney.htmlText = string.format(StrConfig["realm311"],BagModel:GetItemNumInBag(itemId));
		else
			objSwf.jinjiepanel.btnLvlUpEff._visible = false;
			objSwf.jinjiepanel.btnAutoEff._visible = false; 
			objSwf.jinjiepanel.btnConsume.htmlLabel = string.format(StrConfig["realm32"],t_item[itemId].name.."X"..itemNum);
			objSwf.jinjiepanel.txtMoney.htmlText = string.format(StrConfig["realm322"],BagModel:GetItemNumInBag(itemId));
		end
		self:UpdateBtnEffect()
			
		local playerInfo = MainPlayerModel.humanDetailInfo;
		local playerMoney = playerInfo.eaBindGold + playerInfo.eaUnBindGold;
		local moneyEnough = playerMoney >= realmcfg.proce_money;
		local labelMoneyColor = moneyEnough and "#2fe00d" or "#cc0000";
		-- objSwf.jinjiepanel.txtMoney.htmlText = string.format( "<font color='%s'>%s</font>)", labelMoneyColor, realmcfg.proce_money );
				
		if realmcfg.is_wishclear == true then
			objSwf.jinjiepanel.tfcleardata.htmlText = StrConfig["realm45"];
		else
			objSwf.jinjiepanel.tfcleardata.htmlText = StrConfig["realm451"];
		end
	end
end

--刷新道具信息
function UIRealmMainView:UpdateExpInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	if self.curRealmOrder ~= RealmModel:GetRealmOrder() then
		return;
	end
	
	--满阶满星满进度
	if RealmModel:GetRealmOrder() >= RealmConsts.ordermax and
	   RealmUtil:GetIsFullProgress() == true then
		return;
	end
	
	if RealmUtil:GetIsFullProgress() == false then
		objSwf.orderuppanel.btnguanzhu.visible = true;
		objSwf.orderuppanel.guanzhutiaojianpanel._visible = true;
		
		local cfg = t_jingjie[RealmModel:GetRealmOrder()];
		if cfg then
			--是否满足灌注条件
			local ishave = true;
			
			local expcolor = "2fe00d";
			--经验不足
			if RealmUtil:GetIsHaveExp(RealmModel:GetRealmOrder()) == false then
				expcolor = "960000";
				ishave = false;
			end
			
			--道具不足
			if RealmUtil:GetIsHaveTool(RealmModel:GetRealmOrder()) == false then
				ishave = false;
				local reCfg = split(cfg.flood_item_daiti,',');
				if toint(reCfg[1]) > 0 then 
					local NbItemId = toint(reCfg[1]);
					local NbNum = BagModel:GetItemNumInBag(NbItemId);
					if NbNum >= toint(reCfg[2]) then 
						ishave = true;
					end;
				end;

			end
			
			--显示灌注特效
			objSwf.orderuppanel.guanzhuEffect._visible = false;
			if ishave == true then
				objSwf.orderuppanel.guanzhuEffect._visible = true;
			end
			
			local floodexp = cfg.flood_exp;
			local pencent = RealmUtil:GetFloodExpNum();
			floodexp = math.modf(floodexp * pencent);
			objSwf.orderuppanel.guanzhutiaojianpanel.expinfo.htmlLabel = string.format(StrConfig["realm33"], expcolor, getNumShow(floodexp));
		end
	end
end

local lastrealmBlessing;
--显示境界巩固信息
function UIRealmMainView:ShowGongGuInfo(body)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.gongguPanel._visible = true;
	
	for i=1,RealmConsts.xingmax do
		objSwf.gongguPanel["btnChongMan"..i]._visible = false;
		objSwf.gongguPanel["btnChong"..i]._visible = false;
		objSwf.gongguPanel["btnChong"..i].disabled = true;
	end
	
	local chongrealm = toint(RealmModel:GetChongId() / 100) ;
	local chongLevel = RealmModel:GetChongId() % 100;
	-- --当前巩固的境界
	-- if not body then
		-- for i=1,RealmConsts.xingmax do
			-- objSwf.gongguPanel["btnChong"..i].selected = false;
		-- end
	-- end
	objSwf.gongguPanel.progresspanel._visible = false;
	objSwf.gongguPanel.imgGongGuMax._visible = false;
	if chongrealm - 1 >= self.curRealmOrder then
		objSwf.gongguPanel.imgGongGuMax._visible = true;
		for i=1,RealmConsts.xingmax do
			objSwf.gongguPanel["btnChongMan"..i]._visible = true;
			objSwf.gongguPanel["btnChongMan"..i].disabled = false;
		end
		objSwf.gongguPanel["btnChongMan"..RealmConsts.xingmax].selected = true;
		return;
	end
	if chongrealm < self.curRealmOrder then
		--如果预览的下一阶境界
		if self.curRealmOrder >= RealmModel:GetRealmOrder() + 1 then
			for i=1,RealmConsts.xingmax do
				objSwf.gongguPanel["btnChong"..i]._visible = false;
			end
		end
		return;
	end
	
	-- objSwf.gongguPanel.progresspanel._visible = true;
	
	for i=chongLevel,RealmConsts.xingmax do
		-- objSwf.gongguPanel["btnChong"..i]._visible = true;
		-- objSwf.gongguPanel["btnChong"..i].disabled = true;
	end
	
	for i=1,chongLevel-1 do
		-- objSwf.gongguPanel["btnChongMan"..i]._visible = true;
		-- objSwf.gongguPanel["btnChongMan"..i].disabled = false;
	end
	objSwf.gongguPanel["btnChong"..chongLevel].disabled = false;
	
	--当前巩固的境界
	if body and (body.isTuPo or body.isShow) then
		for i=1,RealmConsts.xingmax do
			objSwf.gongguPanel["btnChong"..i].selected = false;
		end
		objSwf.gongguPanel["btnChong"..chongLevel].selected = true;
	end
	
	local cfg = t_jingjiegonggu[RealmModel:GetChongId()];
	if not cfg then
		return;
	end
	
	objSwf.gongguPanel.progresspanel.gonggupanel.proLoaderValue.num = RealmModel:GetChongProgress()
	objSwf.gongguPanel.progresspanel.gonggupanel.proLoaderMax.num   = cfg.max
	
	local blessing = RealmModel:GetChongProgress();
	--进度条
	if body and body.isGongGu then
		if lastrealmBlessing and (blessing - lastrealmBlessing > 0) then
			objSwf.gongguPanel.progresspanel.gonggupanel.siBlessing:tweenProgress( blessing, cfg.max, 0 );
		else
			objSwf.gongguPanel.progresspanel.gonggupanel.siBlessing:setProgress( 0, cfg.max );
			objSwf.gongguPanel.progresspanel.gonggupanel.siBlessing:tweenProgress( blessing, cfg.max, 0 );
		end
	else
		objSwf.gongguPanel.progresspanel.gonggupanel.siBlessing:setProgress( blessing, cfg.max )
	end
	lastrealmBlessing = blessing;
	
	objSwf.gongguPanel.progresspanel.gonggupanel._visible = false;
	objSwf.gongguPanel.progresspanel.tupopanel._visible = false;
	-- objSwf.gongguPanel.progresspanel.gonggupanel.tfgongu.text = StrConfig["realm55"];
	-- objSwf.gongguPanel.progresspanel.tupopanel.tftupo.text = StrConfig["realm57"];
	objSwf.gongguPanel.progresspanel.gonggupanel.txtConsume.text = StrConfig["realm59"];
	objSwf.gongguPanel.progresspanel.tupopanel.txtConsume.text = StrConfig["realm58"];
	objSwf.gongguPanel.progresspanel.tupopanel.tftupoinfo.htmlText = string.format(StrConfig["realm60"],RealmUtil:GetChongAddPercent());
	objSwf.gongguPanel.progresspanel.tupopanel.tuopeffect._visible = false;
	--消耗道具
	--巩固
	if RealmModel:GetChongProgress() < cfg.max then
		objSwf.gongguPanel.progresspanel.gonggupanel._visible = true;
		local itemId, itemNum, isEnough = RealmUtil:GetGongGuFloodItem();
		if isEnough then
			objSwf.gongguPanel.progresspanel.gonggupanel.btnConsume.htmlLabel = string.format(StrConfig["realm31"],t_item[itemId].name..itemNum);
			-- objSwf.gongguPanel.progresspanel.gonggupanel.txtMoney.htmlLabel = string.format(StrConfig["realm311"],BagModel:GetItemNumInBag(itemId));
		else
			objSwf.gongguPanel.progresspanel.gonggupanel.btnConsume.htmlLabel = string.format(StrConfig["realm32"],t_item[itemId].name..itemNum);
			-- objSwf.gongguPanel.progresspanel.gonggupanel.txtMoney.htmlLabel = string.format(StrConfig["realm322"],BagModel:GetItemNumInBag(itemId));
		end
	--突破
	else
		objSwf.gongguPanel.progresspanel.tupopanel._visible = true;
		local itemId, itemNum, isEnough = RealmUtil:GetGongGuBreakItem();
		if isEnough then
			objSwf.gongguPanel.progresspanel.tupopanel.tuopeffect._visible = true;
			objSwf.gongguPanel.progresspanel.tupopanel.btnConsume.htmlLabel = string.format(StrConfig["realm31"],t_item[itemId].name..itemNum);
			-- objSwf.gongguPanel.progresspanel.tupopanel.txtMoney.htmlLabel = string.format(StrConfig["realm311"],BagModel:GetItemNumInBag(itemId));
		else
			objSwf.gongguPanel.progresspanel.tupopanel.btnConsume.htmlLabel = string.format(StrConfig["realm32"],t_item[itemId].name..itemNum);
			-- objSwf.gongguPanel.progresspanel.tupopanel.txtMoney.htmlLabel = string.format(StrConfig["realm322"],BagModel:GetItemNumInBag(itemId));
		end
	end
end

function UIRealmMainView:ShowUseModelState()
	local objSwf = self.objSwf
	if not objSwf then return end
	if RealmModel:GetSelectId() > 100 then
		objSwf.chkBoxUseModel.selected = RealmModel:GetSelectId() == self.curRealmGongGuId;
		objSwf.chkBoxUseModel.disabled = self.curRealmGongGuId > RealmModel:GetSelectId();
	else
		objSwf.chkBoxUseModel.selected = RealmModel:GetSelectId() == self.curRealmOrder
	end
	objSwf.chkBoxUseModel.disabled = self.curRealmOrder > RealmModel:GetRealmOrder()
end

--播放升阶特效
function UIRealmMainView:PlaySucEffect()
	--播放特效
	local winW,winH = UIManager:GetWinSize();
	local pos = {};
	pos.x = winW/2;
	pos.y = winH/2;
	UIEffectManager:PlayEffect(ResUtil:GetJingjieUpSuccess(),pos);
	
	--播放升阶音效
	SoundManager:PlaySfx(2030);
end

--播放进阶音效
function UIRealmMainView:PlayJinJieSound()
	if RealmModel:GetBreakProgress() > 0 then
		--播放升阶音效
		SoundManager:PlaySfx(2040);
	end
end

function UIRealmMainView:SwitchAutoLvlUpState(isAutoLvlUp)
	local objSwf = self.objSwf
	if not objSwf then return end
	self.isAutoLvlUp = isAutoLvlUp
	objSwf.jinjiepanel.btnCancelAuto._visible = isAutoLvlUp
	
	if isAutoLvlUp == true then
		objSwf.jinjiepanel.btnAutoLvlUp.visible = false
	else
		objSwf.jinjiepanel.btnAutoLvlUp.visible = true
	end
end

function UIRealmMainView:OnBtnCancelAutoClick()
	RealmController:SetAutoLevelUp(false);
end

---------------------------------------以下是引导相关------------------------
function UIRealmMainView:GetPreBtn()
	if not self:IsShow() then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	return objSwf.btnPre;
end

function UIRealmMainView:GotoGongGuPage()
	if not self:IsShow() then return; end
	local chongId = RealmModel:GetChongId();
	if chongId == 0 then
		self.curRealmOrder = RealmModel:GetRealmOrder();
		self.curRealmGongGuId = 0;
	else
		self.curRealmOrder = toint(chongId / 100);
		self.curRealmGongGuId = RealmUtil:GetChongIdByOrder(self.curRealmOrder);
	end
	
	self:InitUI();
	-- 显示
	self:ShowRealmMainInfo(self.curRealmOrder);
	self:InitVip();
	self:SwitchAutoLvlUpState( RealmController.isAutoLvlUp );
end

function UIRealmMainView:GetCurrGongGuBtn()
	if not self:IsShow() then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local chongLevel = RealmModel:GetChongId() % 100;
	return objSwf.gongguPanel["btnChong"..chongLevel];
end
-------------------------以下是资质丹相关--------------------------------
function UIRealmMainView:OnBtnZZDClick(e)
	local objSwf = self.objSwf;
	if not objSwf then return; end

	local cfgItem = t_jingjie[RealmModel.realmOrder];
	if not cfgItem then
		return;
	end

	if cfgItem.zizhi_dan <= 0 then
		FloatManager:AddNormal( string.format(StrConfig["zizhi1"], ZiZhiUtil:GetOpenLvByCFG(t_jingjie)), objSwf.btnZZD);
		return;
	end

	--资质丹上限
	local zzdCount = 0
	for k,cfg in pairs(t_jingjie) do
		if cfg.id == RealmModel.realmOrder then
			zzdCount = cfg.zizhi_dan
			break
		end
	end

	--已达到上限
	if ZiZhiModel:GetZZNum(5) >= zzdCount then
		FloatManager:AddNormal( StrConfig["mount7"], objSwf.btnZZD);
		return
	end

	--材料不足
	if ZiZhiUtil:GetZZItemNum(5) <= 0 then
		FloatManager:AddNormal( StrConfig["mount6"], objSwf.btnZZD);
		return
	end

	ZiZhiController:FeedZZDan(5)
end

--属性丹tip
function UIRealmMainView:OnZZDRollOver()
	UIMountFeedTip:OpenPanel(105);
end
-------------------------以下是属性丹相关------------------------------------
function UIRealmMainView:OnBtnFeedSXDClick(e)
	local objSwf = self.objSwf;
	if not objSwf then return; end

	local cfgItem = t_jingjie[RealmModel.realmOrder];
	if not cfgItem then
		return;
	end

	if cfgItem.jingjie_dan <= 0 then
		FloatManager:AddNormal(StrConfig["mount18"], objSwf.btnShuXingDan);
		return;
	end

	--属性丹上限
	local sXDCount = 0
	for k, cfg in pairs(t_jingjie) do
		if cfg.id == RealmModel.realmOrder then
			sXDCount = cfg.jingjie_dan
			break
		end
	end

	--已达到上限
	if RealmModel:GetPillNum() >= sXDCount then
		FloatManager:AddNormal(StrConfig["mount7"], objSwf.btnShuXingDan);
		return
	end

	--材料不足
	if MountUtil:GetJieJieItemNum(14) <= 0 then
		FloatManager:AddNormal(StrConfig["mount6"], objSwf.btnShuXingDan);
		return
	end

	MountController:FeedShuXingDan(14)
end

--属性丹tip
function UIRealmMainView:OnShuXingDanRollOver()
	UIMountFeedTip:OpenPanel(15);
end
-------------------------界面的一些基本信息配置-------------------------------

function UIRealmMainView:OnBtnVipBackClick()
	UIVipBack:Open( VipConsts.TYPE_REALM )
end

function UIRealmMainView:OnBtnVipBackRollOver()
	UIVipBackTips:Open( VipConsts.TYPE_REALM )
end

function UIRealmMainView:OnBtnVipBackRollOut()
	UIVipBackTips:Hide()
end

-- 显示加载过程
function UIRealmMainView:IsShowLoading()
	return true;
end

function UIRealmMainView:IsTween()
	return true;
end

function UIRealmMainView:GetPanelType()
	return 1;
end

function UIRealmMainView:IsShowSound()
	return true;
end

function UIRealmMainView:GetWidth()
	return 1397;
end

function UIRealmMainView:GetHeight()
	return 823;
end

function UIRealmMainView:OnResize(wWidth, wHeight)
	if not self.bShowState then return end
	-- self:UpdateMask()
	-- self:UpdateCloseButton()
end

-- function UIRealmMainView:UpdateMask()
	-- local objSwf = self.objSwf
	-- if not objSwf then return end
	-- local wWidth, wHeight = UIManager:GetWinSize()
	-- objSwf.mcMask._width = wWidth + 100
	-- objSwf.mcMask._height = wHeight + 100
-- end

-- function UIRealmMainView:UpdateCloseButton()
	-- local objSwf = self.objSwf
	-- if not objSwf then return end
	-- local wWidth, wHeight = UIManager:GetWinSize()
	-- objSwf.btnClose._x = math.min( math.max( wWidth - 50, 1280 ), 1380 )
-- end


