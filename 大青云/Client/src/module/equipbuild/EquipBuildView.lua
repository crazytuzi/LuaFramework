--[[
装备打造
wangshuai
]]
_G.UIEquipBuild = BaseUI:new("UIEquipBuild")

UIEquipBuild.panelTMap = {};
UIEquipBuild.itemlist = {};
UIEquipBuild.isVipbuild = false;

UIEquipBuild.treeData = {};
UIEquipBuild.curIndex = 1;
UIEquipBuild.curId = 10102 --10002;
UIEquipBuild.buildNum = 0;
UIEquipBuild.isCanEquipBuild = false;
UIEquipBuild.noBuildType = true;
UIEquipBuild.okBuildType = true;
UIEquipBuild.BuildType = 3;

function UIEquipBuild:Create()
	self:AddSWF("equipbuildPanel.swf",true,nil)
end;

function UIEquipBuild:OnLoaded(objSwf)

	objSwf.scrollList.itemClick = function (e)self:ItemClick(e);end

	objSwf.noOpen._visible = false;
	objSwf.movc21._visible = true;

	for i=1,8 do 
		objSwf["item"..i].rollOver = function()self:ItemOver(i)end;
		objSwf["item"..i].rollOut = function()TipsManager:Hide();end;
	end;

	objSwf.vip_mc.Icon_mc.rollOver = function() self:ShowVipTipsIcon() end;
	objSwf.vip_mc.Icon_mc.rollOut  = function() TipsManager:Hide()end;

	objSwf.noVip.click = function() self:VipClickNo() end;
	objSwf.isVip.click = function() self:VipClickIs() end;
	objSwf.noBang_btn.click = function() self:NobangClick()end;
	objSwf.okBang_btn.click = function() self:OkbangClick()end;

	objSwf.noBang_btn.rollOver = function() self:NobangOver()end;
	objSwf.okBang_btn.rollOver = function() self:OkbangOver()end;
	objSwf.noBang_btn.rollOut = function() TipsManager:Hide() end;
	objSwf.okBang_btn.rollOut = function() TipsManager:Hide() end;

	objSwf.movc21.zaoa.click = function() self:OnDazaoaClick() end;
--	objSwf.openVip.click = function() self:OnOpenVipClick() end;
	--objSwf.openVip2.click = function() self:OnOpenVipClick() end;
	--objSwf.noOpen.gogofub.click = function() self:OnOpenFubenClick()end;
	-- for i=1,4 do 
	-- 	objSwf["gofuben"..i].click = function() self:OnOpenFubenClick()end;
	-- end;
	--objSwf.gofuben2.click = function() self:OnOpenFubenClick()end;

	--objSwf.noOpen.noOpenTxt.click = function() self:OnOpenFubenClick()end;
	-- objSwf.noOpen.noOpenTxt.rollOver = function()self:ShowNoOpenTxt()end;
	-- objSwf.noOpen.noOpenTxt.rollOut  = function()TipsManager:Hide();end;

	-- objSwf.superAtb.rollOver = function() self:SuperAtbOver()end;
	-- objSwf.superAtb.rollOut  = function()TipsManager:Hide();end;

	objSwf.energyTxt.rollOver = function() UIEquipBuildTips:Show() end;
	objSwf.energyTxt.rollOut  = function()UIEquipBuildTips:Hide();end;

	objSwf.NbLook.rollOver = function() self:LookNbEquip() end;
	objSwf.NbLook.rollOut  = function()TipsManager:Hide();end;

	objSwf.movc21.btnPoliReduce.click = function() self:OnPoliReduce()end;
	objSwf.movc21.btnPoliAdd.click = function() self:OnPoliAdd()end;
	objSwf.movc21.btnPoliReduce.autoRepeat = true;	
	objSwf.movc21.btnPoliAdd.autoRepeat = true;
	objSwf.movc21.vipShow.click = function() UIVip:Show(); end;

	-- 隐藏俩按钮
	objSwf.NbLook._visible = false;
	-- objSwf.superAtb._visible = false;

	objSwf.ruleBtn.rollOver = function() self:OnRuleOver()end;
	objSwf.ruleBtn.rollOut  = function() TipsManager:Hide()end;
end;

function UIEquipBuild:UpdataBuildType()
	local objSwf = self.objSwf;
	objSwf.noBang_btn.selected = self.noBuildType
	objSwf.okBang_btn.selected = self.okBuildType
	if self.noBuildType and self.okBuildType then 
		self.BuildType = 3;
	elseif self.noBuildType then 
		self.BuildType = 0
	elseif self.okBuildType then 
		self.BuildType = 1;
	else
		self.BuildType = 4;
	end;
	self:FunShowBuildPanel();
end;

function UIEquipBuild:NobangOver()
	TipsManager:ShowBtnTips(string.format(StrConfig["equipbuild031"]));
end;

function UIEquipBuild:OkbangOver()
	TipsManager:ShowBtnTips(string.format(StrConfig["equipbuild030"]));
end;

function UIEquipBuild:NobangClick()
	self.noBuildType = not self.noBuildType
	self:UpdataBuildType();
end;

function UIEquipBuild:OkbangClick()
	self.okBuildType = not self.okBuildType
	self:UpdataBuildType();
end;

function UIEquipBuild:OnRuleOver()
	TipsManager:ShowBtnTips(string.format(StrConfig["equipbuild024"]));
end;

function UIEquipBuild:OnHuifuShow()
	local cfg = t_consts[68].val1;
	-- local viplvl = MainPlayerModel.humanDetailInfo.eaVIPLevel
	local vipSpeed = VipController:GetHuolizhiOnlineSpeed()
	local vipNextLevelSpeed = VipController:GetHuolizhiOnlineSpeed(1)
	
	local vipCfg = {}
	if vipSpeed <= 0 then --if viplvl <= 0 then 
		vipCfg = VipController:GetHuolizhiOnlineSpeed(0,1)--t_vip[1].vip_equipval;
	else
		if vipSpeed <= 0 then --if not t_vip[viplvl] then 
			cfg = 0;
		else
			cfg = vipSpeed--t_vip[viplvl].vip_equipval;
			if not cfg then 
				cfg = 0;
			end;
		end;
		if vipNextLevelSpeed <= 0 then --if not t_vip[viplvl+1] then 
			vipCfg = 0;
		else
			vipCfg = vipNextLevelSpeed--t_vip[viplvl+1].vip_equipval;
			if not vipCfg then 
				vipCfg = 0;
			end;
		end;
	end;
	local objSwf = self.objSwf;
	if vipSpeed <= 0 then --if viplvl <= 0 then 
		objSwf.huifu1.text = cfg..StrConfig["equipbuild018"]
		objSwf.huifuV.text = vipCfg..StrConfig["equipbuild018"]
	else
		objSwf.huifu1.text = cfg..StrConfig["equipbuild018"]
		objSwf.huifuV.text = vipCfg..StrConfig["equipbuild018"]
	end;

end;

function UIEquipBuild:OnPoliReduce()
	self.buildNum = self.buildNum - 1;
	self:OnBuildNumBtnState();
end;

function UIEquipBuild:OnPoliAdd()
	self.buildNum = self.buildNum + 1;
	self:OnBuildNumBtnState();
end;

function UIEquipBuild:OnBuildNumBtnState()
	local objSwf = self.objSwf;
	self.objSwf.movc21.buildNum_txt.text = self.buildNum;
	local curMaxNum = EquipBuildUtil:GetCanBuildEquipNum(self.curId,self.isVipbuild,self.BuildType)
	if self.buildNum <= 1 then 
		objSwf.movc21.btnPoliReduce.disabled = true;
	else
		objSwf.movc21.btnPoliReduce.disabled = false;
	end;

	if self.buildNum < curMaxNum then 
		objSwf.movc21.btnPoliAdd.disabled = false;
	else
		objSwf.movc21.btnPoliAdd.disabled = true;
	end;

	if self.buildNum > 1 and self.buildNum < curMaxNum then 
		objSwf.movc21.btnPoliAdd.disabled = false;
		objSwf.movc21.btnPoliReduce.disabled = false;
	end;
end;

function UIEquipBuild:OnShow()
	local lengh = EquipBuildModel:GetInitInfoLenght()
	for i=1,lengh do 
		self.panelTMap[i] = {}
		self.panelTMap[i].type = i; --i-1;
		self.panelTMap[i].label = StrConfig['equipbuildlvl00'..(i+1)];
	end;
	local myLevel = MainPlayerModel.humanDetailInfo.eaLevel;
	for i,info in ipairs(t_equipcreate) do 
		if myLevel >= info.unlock then 
			 self.curIndex = info.order;
		end;
	end;
	self:NewShowTitleHandler();
	self:VipClickNo()
	self:DefaultInfo();
	self:SetEnergytxt();
	self.objSwf.treeBar.position = -1;
	self.objSwf.protexiao._visible = false;
	if #self.args > 0 then
		self:ShowSelecteIndex(self.args[1]);
		if self.args[2] then
			self:VipClickIs();
		end
	end
	self:UpdataBuildType()
end

function UIEquipBuild:OnHide()
	self.buildNum = 0;
	self:DazaoTexiaoContr(false);
	UIEquipBuild.panelTMap = {};
	UIEquipBuild.itemlist = {};
	UIEquipBuild.isVipbuild = false;
	UIEquipBuild.treeData = {};
	UIEquipBuild.curIndex = 1;
	UIEquipBuild.curId = 10102;
	UIEquipBuild.buildNum = 0
end;

-- 活力值tips
function UIEquipBuild:EnergtTxt()
	TipsManager:ShowBtnTips(string.format(StrConfig["equipbuild005"]),TipsConsts.Dir_RightDown);
end;

-- 卓越预览
function UIEquipBuild:SuperAtbOver()
	local cfg = EquipBuildModel:GetBuildCfg(self.curId)

	local equipId = 0;
	if self.isVipbuild then 
		local list = split(cfg.vip_createitem,"#");
		local list2 = split(list[1],",")
		equipId = list2[1];
	else
		equipId = cfg.createitem;
	end;

	local list = EquipBuildUtil:GetAllSuperAtb(toint(equipId),self.isVipbuild)

	--print("装备id",equipId)
	local txt = ""
	for i,info in ipairs(list) do 
		local stratb = string.format(StrConfig["equipbuild004"],info.str)
		if not info.index then
			trace(list) 
			trace(info)
			print("error: 卧槽")
		end;
		stratb = "<textformat leftmargin='2' leading='-15'><p>" .. stratb .. "</p><textformat>"
		local typ = StrConfig["equipbuild31"..info.index]
		--txt = txt .. stratb .. typ
		txt = txt .. stratb .. "<textformat leading='5' leftmargin='220'><p>".. typ .. "</p></textformat>";

	end;
	TipsManager:ShowBtnTips(txt,TipsConsts.Dir_RightDown)
end;

-- 未开启
function UIEquipBuild:ShowNoOpenTxt()
	local cfg = EquipBuildModel:GetBuildCfg(self.curId)
	local zhang = toint(cfg.fubId/10000);
	local jie   = toint(cfg.fubId%10000);
	local zhang1 = StrConfig["equipbuild"..toint(200+zhang)]---1
	local jie1 = StrConfig["equipbuild"..toint(200+jie)]
	TipsManager:ShowBtnTips(string.format(StrConfig["equipbuild003"],cfg.name,zhang1,jie1),TipsConsts.Dir_RightDown);
end;

-- 打开副本界面
function UIEquipBuild:OnOpenFubenClick()
	--一群逗比，这么用id

	for i,cfg in pairs(t_equipcreate) do
		if cfg.cid == self.curId then
			FuncManager:OpenFunc(FuncConsts.DominateRoute,false,cfg.fubId);
			return;
		end
	end
end;

-- 打开vip界面
function UIEquipBuild:OnOpenVipClick()
	FloatManager:AddNormal("这里需要打开vip界面，暂无接口");
end;

-- 打造
function UIEquipBuild:OnDazaoaClick()
	if self.isCanEquipBuild == true then 
		FloatManager:AddNormal(StrConfig["equipbuild022"]);
	return end;
	self:OnGuideClick()
	if self.buildNum <= 0 then 
		FloatManager:AddNormal(StrConfig["equipbuild025"]);
		return
	end;
	local cfg = EquipBuildModel:GetBuildCfg(self.curId)
	local bo,erType = EquipBuildUtil:GetIsCanBuy(cfg.id,self.isVipbuild,self.BuildType)
	if bo == false then 
		if erType == 1 then --不是vip
			FloatManager:AddNormal(StrConfig["equipbuild007"],UIEquipBuild:GetBuildBtn());
		elseif erType == 2 then -- 金币不足
			FloatManager:AddNormal(StrConfig["equipbuild008"],UIEquipBuild:GetBuildBtn());
		elseif erType == 3 then --活力值不足
			FloatManager:AddNormal(StrConfig["equipbuild009"],UIEquipBuild:GetBuildBtn());
		elseif erType == 4 then -- 材料不足
			FloatManager:AddNormal(StrConfig["equipbuild010"],UIEquipBuild:GetBuildBtn());
		end;
		return 
	end;
	if self.BuildType == 4 then 
		FloatManager:AddNormal(StrConfig["equipbuild029"]);
		return 
	end;

	if self.timerKey then 
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end;
	self.isCanEquipBuild = true;
	self.timerKey = TimerManager:RegisterTimer( function() self:OnTimer() end,1000,1);
	SoundManager:PlaySfx(2051);
	self:DazaoTexiaoContr(true)
end;

function UIEquipBuild:OnTimer()
	if self.isCanEquipBuild == true then 
		self.isCanEquipBuild = false;
		local cfg = EquipBuildModel:GetBuildCfg(self.curId)
		if self.isVipbuild then 
			local viplvl = MainPlayerModel.humanDetailInfo.eaVIPLevel
			EquipBuildController:SendDazaoA(cfg.id,1,self.buildNum,self.BuildType)
		else
			EquipBuildController:SendDazaoA(cfg.id,0,self.buildNum,self.BuildType)
		end;
	end;
end;

function UIEquipBuild:DazaoTexiaoContr(isPalyer)
	if not self.bShowState then return; end
	if isPalyer == true then 
		--self.objSwf.protexiao._visible = true;
		local mini = 0;
		self.objSwf.zaofpx_mc._visible = true;
		self.objSwf.zaofpx_mc:gotoAndPlay(1);
		-- self.objSwf.protexiao.maximum = 100;
		-- self.timer2 = TimerManager:RegisterTimer(function()
		-- 		if not self.bShowState then return; end
		-- 		if not self.objSwf.protexiao then return end;
		-- 		mini = mini + 1;
		-- 		self.objSwf.protexiao.value = mini;
		-- 		if mini > 98 then 
		-- 		self.objSwf.protexiao._visible = false;
		-- 		end;
		--	end, 20, 100)
	else
		--self.objSwf.protexiao._visible = false;
		self.objSwf.zaofpx_mc._visible = false;
		if self.timerKey then 
			TimerManager:UnRegisterTimer(self.timerKey);
			self.timerKey = nil;
			self.isCanEquipBuild = false;
		end;
		-- if self.timer2 then 
		-- 	TimerManager:UnRegisterTimer(self.timer2);
		-- end;
		if self.isCanEquipBuild == true then 
			-- if not self.objSwf.protexiao then return end;
			-- self.objSwf.protexiao.maximum = 100;
			-- self.objSwf.protexiao.value = 0;
			self.isCanEquipBuild = false
			SoundManager:StopSfx()
			FloatManager:AddNormal(StrConfig["equipbuild020"],self.objSwf.zhuijiaAtb);
		end;
	end;
end;

-- 活力值文本
function UIEquipBuild:SetEnergytxt()
	local objSwf = self.objSwf;
	local val = MainPlayerModel.humanDetailInfo.eaEnergy
	local constCfg = t_consts[68].param
	local constcfglist = split(constCfg,"#")
	if not val then val = 0 end;
	local vipmax = VipController:GetDazaoHuolizhiMax();
	local myMax = constcfglist[2]
	if vipmax > 0 then 
		myMax = vipmax
	end;
	objSwf.ProValue.maximum = myMax
	objSwf.ProValue.value = val;
	objSwf.txt.text = val .. "/" .. myMax
end;

function UIEquipBuild:VipClickNo()
	local objSwf = self.objSwf;
	self.isVipbuild = false;
	objSwf.noVip.selected = true
	self:NewShowTitleHandler();
	self:FunShowBuildPanel()
end;
function UIEquipBuild:VipClickIs()
	local objSwf = self.objSwf;
	self.isVipbuild = true
	objSwf.isVip.selected = true
	self:NewShowTitleHandler();
	self:FunShowBuildPanel()
end;

-- 默认初始数据
function UIEquipBuild:DefaultInfo()
	--print("执行到DefaultInfo")
	local cfg = EquipBuildModel:GetInitInfo();
	local vo = {};
	local cfgid =  EquipBuildModel:GetBuildCfg(self.curId)
	if not cfgid then return end;
	vo.id = cfg[self.curIndex][cfgid.indexc].cid;
	vo.isOpen = cfg[self.curIndex][cfgid.indexc].isOpen;
	local e = {};
	e.item = vo;
	self:ItemClick(e)
end;

-- vip item 
function UIEquipBuild:ShowVipTipsIcon()
	local vo = self.itemlist["vip"]
	if not vo then return end;
	self:ShowEquipTips(vo,true);
end;

-- item 移入事件
function UIEquipBuild:ItemOver(e)
	local vo = self.itemlist[e];
	if e == 1 then 
		self:ShowEquipTips(vo);
		return 
	end; -- 不显示装备tips
	if not vo then return end;
	local tips = vo:GetTipsInfo();
	if vo.huoli == true then -- 活力值移入
		local txt = string.format(StrConfig['equipbuild014'],vo.count)
		TipsManager:ShowBtnTips(txt,TipsConsts.Dir_RightDown);
		return
	end;
	local tips = vo:GetTipsInfo();
	if not tips then return end;
	if self.zhuoyueAtb then
		if tips.info.superDefStr then  
			tips.info.superDefStr = self.zhuoyueAtb;
		end;
	end
	TipsManager:ShowTips(tips.tipsType,tips.info,tips.tipsShowType,TipsConsts.Dir_RightDown)
end;


function UIEquipBuild:ShowEquipTips(vo,bo)
	local tips = ItemTipsUtil:GetItemTipsVO(vo.id,1);--vo:GetTipsInfo();
	if not tips then return end;
	if self.zhuoyueAtb then
		if tips.superDefStr then  
			tips.superDefStr = self.zhuoyueAtb;
		end;
	end
	if self.isVipbuild then  
		tips.superDetailStr = StrConfig["equipbuild026"];
		tips.newSuperDetailStr = StrConfig["equipbuild027"];
	end
	if bo then 
		tips.superDetailStr = StrConfig["equipbuild026"];
		tips.newSuperDetailStr = StrConfig["equipbuild027"];
	end;
	local meBag,mePos = BagUtil:GetEquipPutBagPos(vo.id);
	if meBag>=0 and mePos>=0 then
		local meBagVO = BagModel:GetBag(meBag);
		if meBagVO then
			local meItem = meBagVO:GetItemByPos(mePos);
			if meItem then
				tips.compareTipsVO = ItemTipsVO:new();
				ItemTipsUtil:CopyItemDataToTipsVO(meItem,tips.compareTipsVO);
				tips.compareTipsVO.isInBag = false;
				tips.tipsShowType = TipsConsts.ShowType_Compare;
			end
		end
	end
	TipsManager:ShowTips(tips.tipsType,tips,tips.tipsShowType, TipsConsts.Dir_RightUp);
end;

--点击事件
function UIEquipBuild:ItemClick(e)
	--print("执行到click")
	local objSwf = self.objSwf;
	--if not e.item.isOpen then return end
	if not e.item.id then return end
	self:DazaoTexiaoContr(false);

	local id = e.item.id;
	local objSwf = self.objSwf;
	objSwf.scrollList:selectedState(id);
	-- print(id)

	if toint(id) < 100 then 
		self.curIndex = id;
		local cfg = EquipBuildModel:GetInitInfo();
		self.curId = cfg[self.curIndex][1].cid
		objSwf.scrollList:selectedState(self.curId);
	else
		self.curId = id;
		local cfg = EquipBuildModel:GetBuildCfg(self.curId)
		self.curIndex = cfg.order;

	end;
	local scrollState = EquipBuildModel:GetScrollIsOpen(self.curId);
	if scrollState then -- 开启状态
		objSwf.noOpen._visible = false;
		objSwf.movc21._visible = true;
		self:FunShowBuildPanel()
	else-- 未开启
		self:FunShowBuildPanel()
		self:FunShowNoOpenPanel(id)
	end;
end

-- 显示打造面板
function UIEquipBuild:FunShowBuildPanel()
	self.buildNum = 1;
	self:OnBuildNumBtnState();
	if self.isVipbuild then  -- 选择了vip打造
		self.objSwf.vipImgc._visible = true;
		self:VipBuildEquip()
		return 
	end;
	self:OrdinaryBuildEquip();
	self.objSwf.vipImgc._visible = false;
end;

-- Vip打造
function UIEquipBuild:VipBuildEquip()
	local objSwf = self.objSwf;
	local id = self.curId;
	local cfg = EquipBuildModel:GetBuildCfg(id)
	if not cfg then return end;
	objSwf.vip_mc._visible = false;

	local equiplist = split(cfg.vip_createitem,"#");
	local equipcfg = split(equiplist[1],",");
	if not equipcfg then return end;


	-- 设置装备属性信息
	self:FunShowCurEquipAtb(toint(equipcfg[1]))
	-- 装备信息
	local equipCfg = t_equip[toint(equipcfg[1])];
	if not equipCfg then return end;
	local nameColor = TipsConsts:GetItemQualityColor(equipCfg.quality)
	objSwf.equipName.htmlText=  "<font color='"..nameColor.. "'>"..equipCfg.name.. "</font>";

	local itemvo = RewardSlotVO:new()
	itemvo.id = toint(equipcfg[1]);
	itemvo.count = 1--toint(equipcfg[1]);
	objSwf.item1:setData(itemvo:GetUIData());

	self.itemlist[1] = itemvo;

	local vipmateriallist = split(cfg.vip_material,"#");


	-- 材料1 
	local materialList= split(vipmateriallist[1],",")

	local itemvo1 = RewardSlotVO:new()	
	itemvo1.id = toint(materialList[1]);
	itemvo1.count = toint(materialList[2]);
	local itemvo1c = UIData.decode(itemvo1:GetUIData())
	local mynum = EquipBuildUtil:GetBindStateItemNumInBag(toint(materialList[1]),self.BuildType);
	if mynum >= toint(materialList[2]) then 
		--itemvo1c.showCount = string.format(StrConfig['equipbuild002'],"#23961e",mynum,materialList[2])
		objSwf.text2.htmlText = string.format(StrConfig['equipbuild002'],"#23961e",mynum,materialList[2])
	else
		--itemvo1c.showCount = string.format(StrConfig['equipbuild002'],"#960000",mynum,materialList[2])
		objSwf.text2.htmlText = string.format(StrConfig['equipbuild002'],"#960000",mynum,materialList[2])
	end;
	objSwf.item2:setData(UIData.encode(itemvo1c));
	self.itemlist[2] = itemvo1;

	-- 材料2
	local materal2 = split(vipmateriallist[2],",")
	local itemvo2 = RewardSlotVO:new()
	itemvo2.id = toint(materal2[1]);
	itemvo2.count = toint(materal2[2]);
	local mynum2 = EquipBuildUtil:GetBindStateItemNumInBag(toint(materal2[1]),self.BuildType);
	local itemvo2c = UIData.decode(itemvo2:GetUIData())
	if mynum2 >= toint(materal2[2]) then
		--itemvo2c.showCount = string.format(StrConfig['equipbuild002'],"#23961e",mynum2,materal2[2])
		objSwf.text3.htmlText = string.format(StrConfig['equipbuild002'],"#23961e",mynum2,materal2[2])
	else
		--itemvo2c.showCount = string.format(StrConfig['equipbuild002'],"#960000",mynum2,materal2[2])
		objSwf.text3.htmlText = string.format(StrConfig['equipbuild002'],"#960000",mynum2,materal2[2])
	end
	objSwf.item3:setData(UIData.encode(itemvo2c));
	self.itemlist[3] = itemvo2


	-- 材料2 赋值 金币
	local itemvo3 = RewardSlotVO:new()
	itemvo3.id = 11
	itemvo3.count = cfg.vipmoney;	
	local itemvo3c = UIData.decode(itemvo3:GetUIData())
	local mynum3 =	MainPlayerModel.humanDetailInfo.eaBindGold + MainPlayerModel.humanDetailInfo.eaUnBindGold
	if mynum3 < cfg.vipmoney then
		--itemvo3c.showCount = string.format(StrConfig['equipbuild021'],cfg.vipmoney)
		objSwf.text4.htmlText = string.format(StrConfig['equipbuild021'],cfg.vipmoney)
	else
		objSwf.text4.htmlText = string.format(StrConfig['equipbuild028'],cfg.vipmoney)
	end
	objSwf.item4:setData(UIData.encode(itemvo3c));
	self.itemlist[4] = itemvo3;

	-- 材料3 赋值 活力
	local itemvo4 = RewardSlotVO:new()
	itemvo4.id = 11;
	itemvo4.count = cfg.vip_activity;
	itemvo4.huoli = true;
	local itemvo4c = UIData.decode(itemvo4:GetUIData())
	itemvo4c.iconUrl = "img://resfile/itemicon/itemicon_ziyuan_huoli.png"
	local mynum4 = MainPlayerModel.humanDetailInfo.eaEnergy;
	if mynum4 < cfg.vip_activity then
		--itemvo4c.showCount = string.format(StrConfig['equipbuild021'],cfg.vip_activity)
		objSwf.text5.htmlText = string.format(StrConfig['equipbuild021'],cfg.vip_activity)
	else
		objSwf.text5.htmlText = string.format(StrConfig['equipbuild028'],cfg.vip_activity)
	end
	objSwf.item5:setData(UIData.encode(itemvo4c));
	self.itemlist[5] = itemvo4;


	objSwf.item6:setData({});
	objSwf.item7:setData({});
	objSwf.item8:setData({});
	objSwf.text6.htmlText = "";
	objSwf.text7.htmlText = "";
	objSwf.text8.htmlText = "";

	--不是任意VIP类型
	local viptype = VipController:GetVipType();
	if viptype <= 0 then 
		objSwf.movc21.zaoa.disabled = true;
		objSwf.movc21.vipShow._visible = true;
	else
		objSwf.movc21.zaoa.disabled = false;
		objSwf.movc21.vipShow._visible = false;
	end;

end;

-- 普通打造
function UIEquipBuild:OrdinaryBuildEquip()
	--print("执行懂啊OrdinaryBuildEquip")
	local objSwf = self.objSwf;
	local id = self.curId;
	local cfg = EquipBuildModel:GetBuildCfg(id)
	if not cfg then return end;

	--vipicon
	local equiplist = split(cfg.vip_createitem,"#");
	local equipcfg = split(equiplist[1],",");
	if not equipcfg then return end;
	objSwf.vip_mc._visible = true;

	local itemvoVip = RewardSlotVO:new()
	itemvoVip.id = toint(equipcfg[1]);
	itemvoVip.count = 1;
	objSwf.vip_mc.Icon_mc:setData(itemvoVip:GetUIData())
	self.itemlist["vip"] = itemvoVip;


	-- 设置装备属性信息
	local idlist = cfg.createitem_new;
	local idta = split(idlist,"#");
	local de  = split(idta[1],",")
	self:FunShowCurEquipAtb(toint(de[1]))
	--print("跳过reunt，执行")
	self:EmptyItemData();
	-- 装备  

	local equipCfg = t_equip[toint(de[1])];
	if not equipCfg then return end;
	local nameColor = TipsConsts:GetItemQualityColor(equipCfg.quality)
	objSwf.equipName.htmlText=  "<font color='"..nameColor.. "'>"..equipCfg.name.. "</font>";

	local itemvo = RewardSlotVO:new();
	itemvo.id = toint(de[1]);
	itemvo.count = 1;
	objSwf.item1:setData(itemvo:GetUIData());
	self.itemlist[1] = itemvo;

	-- 材料1 赋值 材料
	local itemvo1cfg = split(cfg.material,",");
	local mynum = EquipBuildUtil:GetBindStateItemNumInBag(toint(itemvo1cfg[1]),self.BuildType);
	local itemvo1 = RewardSlotVO:new()
	itemvo1.id = toint(itemvo1cfg[1]);
	itemvo1.count = toint(itemvo1cfg[2]);
	local itemvo1c = UIData.decode(itemvo1:GetUIData())
	if mynum >= toint(itemvo1cfg[2]) then 
		--itemvo1c.showCount = string.format(StrConfig['equipbuild002'],"#23961e",mynum,itemvo1cfg[2])
		objSwf.text6.htmlText = string.format(StrConfig['equipbuild002'],"#23961e",mynum,itemvo1cfg[2])
	else
		--itemvo1c.showCount = string.format(StrConfig['equipbuild002'],"#960000",mynum,itemvo1cfg[2])
		objSwf.text6.htmlText = string.format(StrConfig['equipbuild002'],"#960000",mynum,itemvo1cfg[2])
	end;
	objSwf.item6:setData(UIData.encode(itemvo1c));
	self.itemlist[6] = itemvo1;

	-- 材料2 赋值 金币
	local itemvo2 = RewardSlotVO:new()
	itemvo2.id = 11
	itemvo2.count = cfg.money;	
	local itemvo2c = UIData.decode(itemvo2:GetUIData())
	local mynum2 =	MainPlayerModel.humanDetailInfo.eaBindGold + MainPlayerModel.humanDetailInfo.eaUnBindGold
	if mynum2 < cfg.money then
	--	itemvo2c.showCount = string.format(StrConfig['equipbuild021'],cfg.money)
		objSwf.text7.htmlText = string.format(StrConfig['equipbuild021'],cfg.money)
	else
		objSwf.text7.htmlText = string.format(StrConfig['equipbuild028'],cfg.money)
	end
	objSwf.item7:setData(UIData.encode(itemvo2c));
	self.itemlist[7] = itemvo2;



	-- 材料3 赋值 活力
	local itemvo3 = RewardSlotVO:new()
	itemvo3.id = 11;
	itemvo3.count = cfg.activity;
	itemvo3.huoli = true;
	local itemvo3c = UIData.decode(itemvo3:GetUIData())
	itemvo3c.iconUrl = "img://resfile/itemicon/itemicon_ziyuan_huoli.png"
	local mynum4 = MainPlayerModel.humanDetailInfo.eaEnergy;
	if mynum4 < cfg.activity then
		--itemvo3c.showCount = string.format(StrConfig['equipbuild021'],cfg.activity)
		objSwf.text8.htmlText = string.format(StrConfig['equipbuild021'],cfg.activity)
	else
		objSwf.text8.htmlText =  string.format(StrConfig['equipbuild028'],cfg.activity)
	end
	objSwf.item8:setData(UIData.encode(itemvo3c));
	self.itemlist[8] = itemvo3;
	objSwf.item2:setData({});
	objSwf.item3:setData({});
	objSwf.item4:setData({});
	objSwf.item5:setData({});
	objSwf.text2.htmlText = "";
	objSwf.text3.htmlText = "";
	objSwf.text4.htmlText = "";
	objSwf.text5.htmlText = "";


	-- objSwf.gofuben1._visible = true;
	-- objSwf.gofuben2._visible = false;
	-- objSwf.gofuben3._visible = false;
	-- objSwf.gofuben4._visible = false;

	objSwf.movc21.zaoa.disabled = false;
	objSwf.movc21.vipShow._visible = false;
end;

-- 清空数据
function UIEquipBuild:EmptyItemData()
	local objSwf = self.objSwf;
	for i=1,4 do 
		objSwf["item"..i]:setData({})
	end;
end;

-- 当前装备属性
function UIEquipBuild:FunShowCurEquipAtb(equipid)
	do return end;
	local objSwf = self.objSwf;
	local equipcfg = t_equip[equipid];
	if not equipcfg then return end;

	-- 基础属性
	local jichuAtb = "";
	local jichuatblist = AttrParseUtil:Parse(equipcfg.baseAttr);
	for i,info in ipairs(jichuatblist) do 
		local name = enAttrTypeName[info.type];
		jichuAtb = jichuAtb .. "<font color='#A0A0A0'>"..name..":    </font><font color='#a0a0a0'>+"..info.val.."</font>";
	end;
	objSwf.jichuAtb.htmlText = jichuAtb;

	-- 追加属性
	local  fujiaLeng = EquipConsts:DefaultSuperNum(equipcfg.quality)
	if fujiaLeng == "" then 
		-- wu 
	else
		objSwf.zhuijiaAtb.htmlText = string.format(StrConfig["equipbuild012"],fujiaLeng)
	end;

	-- local zhuijiaAtb = "";
	-- local addAtbId = equipcfg.level*10+equipcfg.quality;
	-- local atb = t_equipExtra[addAtbId];
	-- local mininum = -1;
	-- local maxnum = -1;
	-- if atb then 
	-- 	local str = atb.weight;
	-- 	for i,info in ipairs(str) do
	-- 		if info > 0 then 
	-- 			if mininum == -1 then 
	-- 				mininum = i;
	-- 			end;
	-- 			maxnum = i;
	-- 		end;
	-- 	end;
	-- end
	-- if maxnum <= 1 then 
	-- 	zhuijiaAtb = zhuijiaAtb..StrConfig["equipbuild011"];
	-- else
	-- 	zhuijiaAtb = zhuijiaAtb..string.format(StrConfig["equipbuild012"],(mininum - 1),(maxnum -1))--..(mininum - 1).."~"..(maxnum -1).."级追加属性";
	-- end;
	-- objSwf.zhuijiaAtb.htmlText = zhuijiaAtb;


	-- 卓越属性
	local  atbLeng = EquipConsts:DefaultNewSuperNum(equipcfg.quality)
	if atbLeng == "" then 
		-- 无
	else 
		if self.isVipbuild then 
			objSwf.zhuoyueAtb.htmlText = string.format(StrConfig["equipbuild023"])
		else
			objSwf.zhuoyueAtb.htmlText = string.format(StrConfig["equipbuild017"])
		end;
	end;


	-- local zhuoyueAtb = "";
	-- local zhuoyueId =  1000000 + (equipcfg.level * 10000) + (equipcfg.pos * 100)+equipcfg.quality--(equipcfg.level * 10000) + (equipcfg.pos * 10) +equipcfg.quality
	-- local zhuoyueCfg = nil;
	-- if self.isVipbuild  then 
	-- 	zhuoyueCfg = t_zhuoyue[zhuoyueId]
	-- else
	-- 	zhuoyueCfg = t_zhuoyue[zhuoyueId]
	-- end;
	-- local supermininum = 1;
	-- local supermaxnum = -1;
	-- if zhuoyueCfg then 
	-- 	local superstr = zhuoyueCfg.weight;
	-- 	for ao,wu in ipairs(superstr) do
	-- 		if wu > 0 then 
	-- 			if supermininum == -1 then 
	-- 				supermininum = ao;
	-- 			end;
	-- 			supermaxnum = ao;
	-- 		end;
	-- 	end;
	-- end;
	-- if supermaxnum <= 1 then 
	-- 	zhuoyueAtb = zhuoyueAtb..StrConfig["equipbuild011"];
	-- else
	-- 	zhuoyueAtb = zhuoyueAtb..string.format(StrConfig["equipbuild017"],(supermininum),(supermaxnum -1))--"随机获得"..(supermininum - 1).."~"..(supermaxnum - 1).."条卓越属性";
	-- 	self.zhuoyueAtb = supermininum.."-"..supermaxnum-1;
	-- end;
	-- objSwf.zhuoyueAtb.htmlText = zhuoyueAtb;

end;

-- 显示未开启面板
function UIEquipBuild:FunShowNoOpenPanel()
	local objSwf = self.objSwf;
	local id = self.curId;
	local cfg = EquipBuildModel:GetBuildCfg(id)
	if not cfg then return end;
	local txt = string.format(StrConfig["equipbuild001"],cfg.unlock)
	objSwf.noOpen.noOpenTxt.textField.htmlText = txt;
	objSwf.noOpen._visible = true;
	objSwf.movc21._visible = false;
end;



function UIEquipBuild:NewShowTitleHandler()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	UIData.cleanTreeData( objSwf.scrollList.dataProvider.rootNode);
	self.treeData.label = "root";
	self.treeData.open = true;
	self.treeData.isShowRoot = false;
	self.treeData.nodes = {};
	for i , v in ipairs(self.panelTMap) do
		local trunkVO = v;
		if trunkVO then
			local scrollNode = {};
			scrollNode.str = v.label;
			scrollNode.nodes = {};
			if i == self.curIndex then
				scrollNode.open = true;
			else
				scrollNode.open = false;
			end;
			scrollNode.withIcon = true;
			scrollNode.nodeType = 1;
			scrollNode.id = i;
			scrollNode.isOpen = true;
			for ao , wu in pairs( EquipBuildModel:GetScrollList(v.type) ) do
				local ChildNode = {};
				ChildNode.nodeType = 2;
				ChildNode.isOpen = true
				local cfg = EquipBuildModel:GetBuildCfg(wu.cid)
				local name = BagConsts:GetEquipName(cfg.pos);
				local equipCfg = {};
				if self.isVipbuild then 
					equipCfg = t_equip[cfg.createitem_vip]
				else
					equipCfg = t_equip[cfg.createitem]
				end;
				if not equipCfg then return end;
				local isopnn = EquipBuildModel:GetScrollIsOpen(wu.cid);
				local buildNum = EquipBuildUtil:GetCanBuildEquipNum(wu.cid,self.isVipbuild)
				if buildNum <= 0 then 
					if not equipCfg then return end;
					local nameColor = TipsConsts:GetItemQualityColor(equipCfg.quality)
					local txt =  "<font color='"..nameColor.. "'>"..equipCfg.name.. "</font>";
					ChildNode.jian =  self:CpmtrastRoleEquip(cfg.pos,equipCfg);
					ChildNode.ItemText = txt--string.format(StrConfig["equipbuild015"],name,buildNum);
					
					if not isopnn then 
						ChildNode.ItemText ="<font color='#5a5a5a'>"..equipCfg.name.."</font>";
					end;
				else
					if not equipCfg then return end;
					local nameColor = TipsConsts:GetItemQualityColor(equipCfg.quality)
					local txt =  "<font color='"..nameColor.. "'>"..equipCfg.name.. "</font>";
					ChildNode.ItemText = string.format(StrConfig["equipbuild016"],txt,buildNum);--name
					ChildNode.jian = self:CpmtrastRoleEquip(cfg.pos,equipCfg);
					--ChildNode.ItemText2 = string.format(StrConfig["equipbuild016"],buildNum);
					if not isopnn then 
						ChildNode.ItemText = "<font color='#5a5a5a'>"..string.format(StrConfig["equipbuild016"],equipCfg.name,buildNum).."</font>"
					end;
				end;
				if not isopnn then 
					ChildNode.ItemText = "<font color='#5a5a5a'>"..ChildNode.ItemText.."</font>"
				end;
				ChildNode.id = wu.cid;
				ChildNode.btnSelected = false;
				if wu.cid == self.curId then
					ChildNode.btnSelected = true;
				end
				table.push(scrollNode.nodes, ChildNode);
			end
			table.push(self.treeData.nodes, scrollNode);
		end
	end
	--trace(self.treeData)
	UIData.copyDataToTree(self.treeData,objSwf.scrollList.dataProvider.rootNode);
	objSwf.scrollList.dataProvider:preProcessRoot();
	objSwf.scrollList:invalidateData();
end


function UIEquipBuild:CpmtrastRoleEquip(pos,equipCfg)
	local bagVO = BagModel:GetBag(BagConsts.BagType_Role); 
	if not bagVO then return end;
	local item = bagVO:GetItemByPos(pos);
	if not item then return true end
	local roleEquipCfg = item:GetCfg();
	if equipCfg.quality > roleEquipCfg.quality then 
		return true;
	end;

	if equipCfg.level > roleEquipCfg.level then 
		return true;
	end;

	return false;
end;

function UIEquipBuild:LookNbEquip()
	local cfg = EquipBuildModel:GetBuildCfg(self.curId)
	local equipId = 0;
	if self.isVipbuild then 
		local list = split(cfg.vip_createitem,"#");
		local list2 = split(list[1],",")
		equipId = list2[1];
	else
		equipId = cfg.createitem;
	end;
	local attrAdd,superList = EquipBuildUtil:GetNBEquip(toint(equipId),self.isVipbuild)
	if not attrAdd then attrAdd = 0 end;
	if not superList then superList = {} end;
	local itemTipsVO = ItemTipsUtil:GetItemTipsVO(toint(equipId),1,1);
	if not itemTipsVO then return; end
	itemTipsVO.superVO = {};
	itemTipsVO.superVO = superList;
	itemTipsVO.extraLvl = attrAdd;

	TipsManager:ShowTips(itemTipsVO.tipsType,itemTipsVO,itemTipsVO.tipsShowType, TipsConsts.Dir_RightDown);
end;

function UIEquipBuild:ListNotificationInterests()
	return {
		NotifyConsts.EquipBuildOpenList,
		NotifyConsts.PlayerAttrChange,
		NotifyConsts.BagAdd,
		NotifyConsts.BagRemove,
		NotifyConsts.BagUpdate,
		NotifyConsts.EquipBuildResultUpdata,
	}
end

function UIEquipBuild:HandleNotification(name,body)
	if not self.bShowState then return; end
	if name == NotifyConsts.EquipBuildOpenList then
		self:NewShowTitleHandler();
		self:DefaultInfo()
	elseif name == NotifyConsts.PlayerAttrChange then
		if body.type == enAttrType.eaEnergy then 
			self:SetEnergytxt();
			self:DefaultInfo();
			self:NewShowTitleHandler();
		end;
	elseif name == NotifyConsts.BagAdd or name == NotifyConsts.BagRemove or  name == NotifyConsts.BagUpdate then 
		self:FunShowBuildPanel();
	elseif name == NotifyConsts.EquipBuildResultUpdata then 
		--print("接收到消息,这是装备解雇破")
		--debug.debug();
		--self:NewShowTitleHandler();
		--self:DefaultInfo()
	end
end


function UIEquipBuild:ShowSelecteIndex(id)
	if not self.bShowState then return; end
	local cfg = t_equipcreate[id]
	UIEquipBuild.curIndex = cfg.order
	UIEquipBuild.curId = cfg.cid;
	UIEquipBuild.buildNum = 0;
	UIEquipBuild.isVipbuild = false;
	self:DefaultInfo();
	self:NewShowTitleHandler();
end;
function UIEquipBuild:GetBuildBtn()
	if not self:IsShow() then return end;
	return self.objSwf.movc21.zaoa;
end;

----------------------------------  点击任务接口 ----------------------------------------

function UIEquipBuild:OnGuideClick()
	QuestController:TryQuestClick( QuestConsts.EquipBuildClick1 )
	QuestController:TryQuestClick( QuestConsts.EquipBuildClick2 )
	QuestController:TryQuestClick( QuestConsts.EquipBuildClick3 )
end

------------------------------------------------------------------------------------------