--[[
灵兽商店 现在的炼器系统下的灵宝界面
wangshuai
]]
_G.UIWarPrintShop = BaseUI:new("UIWarPrintShop")

UIWarPrintShop.shoplist = {};
UIWarPrintShop.gold_duo_timer_key = nil;
UIWarPrintShop.FightX = 0;
UIWarPrintShop.oldDongTianLv = 0;
UIWarPrintShop.goldDuoState = false;
--UIWarPrintShop.UI3D_FPX = "ls_linghunshi_xuanzhong.pfx"
function UIWarPrintShop:Create()
	self:AddSWF("SpiritWarPrintBuy.swf",true,nil)
end;

function UIWarPrintShop:OnLoaded(objSwf)
	objSwf.GoMosaic.click = function() self:OnGoEquipPanel() end;

	objSwf.gold_dan.click = function() self:OnGoldDanClick()
										TipsManager:Hide() end;
	objSwf.gold_duo.click = function() self:OnGoldDuoClick()
										TipsManager:Hide() end;
	objSwf.gold_cancel.click = function() self:StopGoldDuoClick();
										TipsManager:Hide() end
	objSwf.money_dan.click = function() self:OnMoneyDanClick()
	TipsManager:Hide() end;
	--objSwf.money_duo.click = function() self:OnMoneyDuoClick()
	--									TipsManager:Hide() end;

    --规则
	objSwf.rulesBtn.rollOver = function() TipsManager:ShowBtnTips(StrConfig['wuhun62'],TipsConsts.Dir_RightDown); end
	objSwf.rulesBtn.rollOut = function() TipsManager:Hide(); end
	
	objSwf.gold_dan.rollOver = function() self:ShowTipsXiaohao(1) end;
	objSwf.gold_duo.rollOver = function() self:ShowTipsXiaohaoDuo(1) end;
	objSwf.money_dan.rollOver = function() self:ShowTipsXiaohao(2) end;
	--objSwf.money_duo.rollOver = function() self:ShowTipsXiaohaoDuo(2) end;
	objSwf.gold_dan.rollOut  = function() TipsManager:Hide() end;
	objSwf.gold_duo.rollOut  = function() TipsManager:Hide() end;
	objSwf.money_dan.rollOut = function() TipsManager:Hide() end;
	--objSwf.money_duo.rollOut = function() TipsManager:Hide() end;

	self:ChangeShopGoldBuyState(true);

	objSwf.mcMask.click = function() self:McMaskClick()end;

	--战斗力显示位置调整，更加居中
	self.FightX = objSwf.numFight._x
	objSwf.numFight.loadComplete = function()
		objSwf.numFight._x = self.FightX - objSwf.numFight.width / 2
	end

	for i = 1, 5 do
		objSwf["shopitem" .. i].click = function(e) self:OnShopItemClick(i) end;
		objSwf["shopitem" .. i].rollOver = function(e) self:OnShopItemRollOver(i) end;
		objSwf["shopitem" .. i].rollOut = function(e) self:OnShopItemRollOut(i) end;
	end
end;

function UIWarPrintShop:McMaskClick()
	FloatManager:AddNormal(StrConfig["warprintstore014"])
end;

function UIWarPrintShop:ChangeShopGoldBuyState(isStop)
	self.objSwf.gold_duo._visible = isStop;
	self.objSwf.gold_cancel._visible = not isStop;
end

function UIWarPrintShop:UpdateDongTianLvView()
	if not self:IsShow() then return; end
	self:SelectDongTian(WarPrintModel.dongTianLv);


	if self.goldDuoState then return; end
	if WarPrintModel.dongTianLv >= 4 then
		self.objSwf.money_dan.disabled = true;
	else
		self.objSwf.money_dan.disabled = false;
	end

end
function UIWarPrintShop:SelectDongTian(pos)
	for i = 1, 5 do
		local shopItem = self.objSwf["shopitem" .. i];
		if i == pos then
			shopItem.selected = true;
			shopItem.disabled = false;
			shopItem.smoke:playEffect(0);
		else
			shopItem.selected = false;
			shopItem.disabled = true;
			shopItem.smoke:stopEffect();
		end

	end
end
-- 分解碎片
function UIWarPrintShop:OnSetDebrisNum()
	local objSwf = self.objSwf;
	local num = WarPrintModel.curDebris;
	objSwf.decomBtn.text = string.format(StrConfig["warprint006"],num)
end;
-- 更新界面花费显示
function UIWarPrintShop:UpdateCostInfo()
	local objSwf = self.objSwf;
	local goldCost = t_zhanyinachieve[WarPrintModel.dongTianLv].money;
	local moneyCost = t_zhanyincost[2].cost;
	objSwf.yinliangnum.text = goldCost;
	objSwf.yuanbaonum.text = moneyCost;
end
function UIWarPrintShop:ShowTipsXiaohao(type)
	local goldCost = t_zhanyinachieve[WarPrintModel.dongTianLv].money;
	local moneyCost = t_zhanyincost[2].cost;
	if type == 1 then --银两
		TipsManager:ShowBtnTips(string.format(StrConfig["warprintstore005"],goldCost),TipsConsts.Dir_RightDown);
	elseif type == 2 then
		TipsManager:ShowBtnTips(string.format(StrConfig["warprintstore004"],moneyCost),TipsConsts.Dir_RightDown);
	end;
end;

function UIWarPrintShop:ShowTipsXiaohaoDuo(type)

	if type == 1 then --银两
		TipsManager:ShowBtnTips(string.format(StrConfig["warprintstore0061"]),TipsConsts.Dir_RightDown);
	elseif type == 2 then
		TipsManager:ShowBtnTips(string.format(StrConfig["warprintstore006"]),TipsConsts.Dir_RightDown);
	end;
end;
--点击
function UIWarPrintShop:OnShopItemClick(id)
	local dongtianlv = WarPrintModel.dongTianLv;
	if id ~= dongtianlv then return; end
	self:OnGoldDanClick();
	TipsManager:Hide();
end
-- 移入
function UIWarPrintShop:OnShopItemRollOver(id)
	local dongtianlv = id;
	local goldCost = t_zhanyinachieve[dongtianlv].money;
	local costStr = "";
	if MainPlayerModel.humanDetailInfo.eaBindGold >= goldCost then
		--符合
		costStr = string.format("<font color='#00FF00'>%s</font>", goldCost);
	else
		--不符合
		costStr = string.format("<font color='#FF0000'>%s</font>", goldCost);
	end
	local tipStr = string.format(StrConfig["warprintstore030"], t_zhanyinachieve[id].name, costStr);
	TipsManager:ShowBtnTips(tipStr);
end;
-- 移除
function UIWarPrintShop:OnShopItemRollOut(id)
	TipsManager:Hide();
end

function UIWarPrintShop:OnShow()
	local objSwf = self.objSwf;
	objSwf.shoplist.selectedIndex = -1;
	self:OnShopitemList();
	self:UpdateDongTianLvView();
	self:OnSetDebrisNum();
	self:UpdateCostInfo();
	objSwf.resultItem._visible = false;
	self:SetBtnStateBtn(true);
	self:UpdateFightNum();
end;

function UIWarPrintShop:OnHide()
	self:StopGoldDuoClick();
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false)
	end;
end;

UIWarPrintShop.isDanCiClick = false;

--单次金币抽取
function UIWarPrintShop:OnGoldDanClick()
	self.isDanCiClick = true;
	self.oldDongTianLv = WarPrintModel.dongTianLv;
	return WarPrintController:OnReqBuyItem(1,1)
end;
--多次金币抽取
function UIWarPrintShop:OnGoldDuoClick()
	if self:OnGoldDanClick() == false then
		return;
	end
	local func = function ()
		self:OnGoldDanClick()
	end
	self.gold_duo_timer_key = TimerManager:RegisterTimer(func, 500, 0);
	self:ChangeShopGoldBuyState(false);
	self:SetGoldDuoState(true);
	--UIConfirm:Open(string.format(StrConfig['warprintstore016'],goldCost),func);
end;

function UIWarPrintShop:StopGoldDuoClick()
	TimerManager:UnRegisterTimer(self.gold_duo_timer_key);
	self:ChangeShopGoldBuyState(true);
	self:SetGoldDuoState(false);
end

function UIWarPrintShop:SetGoldDuoState(value)
	self.objSwf.gold_dan.disabled = value;
	UIWarPrintBag.objSwf.tunshibtn.disabled = value;
	UIWarPrintBag.objSwf.housebtn.disabled = value;
	UIWarPrintBag.objSwf.shopBtn.disabled = value;
	self.goldDuoState = value;
	if self.goldDuoState then
		self.objSwf.money_dan.disabled = true;
	else
		self:UpdateDongTianLvView();
	end
end

--单词软妹币抽取
function UIWarPrintShop:OnMoneyDanClick()
	self.isDanCiClick = true;
	WarPrintController:OnReqBuyItem(2,1)
end;
--多次软妹币抽取
function UIWarPrintShop:OnMoneyDuoClick()
	local num = WarPrintModel:GetBagLastNum()
	local cfg = t_zhanyincost;
	local val = cfg[2].cost * num;
	local func = function ()
		WarPrintController:OnReqBuyItem(2,0)
	end
	UIConfirm:Open(string.format(StrConfig['warprintstore015'],val),func);
end;
function UIWarPrintShop:OnExtractingAnimation(index)
	local objSwf = self.objSwf;
	objSwf.num = 1; -- 基数
	local connum = 12 -- 总数
	self:OnIngShoping(false)
	local idx = connum * 3 + index; --  跑多少格子
	local numIndex = 0;
 	Tween:To(objSwf,2,{num=idx},{onUpdate=function()
 			local numIndecx = math.ceil(objSwf.num%connum)
 			if numIndecx ~= numIndex then
	 			self.objUIDraw:StopNodePfxByBoneName("zhan_"..(numIndex), self.UI3D_FPX)
	 			self.objUIDraw:PlayNodePfxByBoneName("zhan_"..math.ceil(objSwf.num%connum), self.UI3D_FPX, nil)
	 			numIndex = math.ceil(objSwf.num%connum)
	 		end;
			--objSwf.shoplist.selectedIndex = math.floor(objSwf.num%connum)


			end,onComplete=function() self:OnIngShoping(true)end});
end;
function UIWarPrintShop:OnIngShoping(bo)
	local objSwf = self.objSwf;
	if not objSwf then return end;
	if UIWarPrintBag:IsShow() then
		UIWarPrintBag:SetBtnState(bo)
	end;
	self:SetBtnStateBtn(bo);
	if bo then
		objSwf.GoMosaic.disabled = false;
	else
		objSwf.GoMosaic.disabled = true;
	end;
end;

function UIWarPrintShop:SetBtnStateBtn(bo)
	if not self:IsShow() then return end;
	local objSwf = self.objSwf;
	if bo then
		objSwf.gold_dan.disabled = false;
		objSwf.gold_duo.disabled = false;
		objSwf.money_dan.disabled = false;
		--objSwf.money_duo.disabled = false;
		objSwf.mcMask.disabled = true;
		objSwf.mcMask._visible = false;
	else
		objSwf.gold_dan.disabled = true;
		objSwf.gold_duo.disabled = true;
		objSwf.money_dan.disabled = true;
		--objSwf.money_duo.disabled = true;
		objSwf.mcMask.disabled = false;
		objSwf.mcMask._visible = true;
	end;
end;

function UIWarPrintShop:UpdateFightNum()
	self.objSwf.numFight.num = WarPrintModel.fightScore;
end

-- 初始化list
function UIWarPrintShop:OnShopitemList()
	local objSwf = self.objSwf;
	local list = {};
	list,self.shoplist = WarPrintUtils:OnGetCurShopShowItem()

	objSwf.shoplist.dataProvider:cleanUp();
	objSwf.shoplist.dataProvider:push(unpack(list));
	objSwf.shoplist:invalidateData();
end;
--返回炼器界面
function UIWarPrintShop:OnGoEquipPanel()
	UILianQiMainPanelView:OnTabButtonClick(FuncConsts.LianQi);
end;

function UIWarPrintShop:GetOldDongTianItemButton()
	if self.oldDongTianLv == 0 then return; end
	return self.objSwf["shopitem" .. self.oldDongTianLv];
end

function UIWarPrintShop:OnSetShopResult(body)
	local cfg = WarPrintUtils:OnGetItemCfg(body.tid)
	if not cfg then return end;
	local qua = cfg.quality;

	local index = WarPrintUtils:OnGetShopItemIndex(self.shoplist,qua)
	--self:OnExtractingAnimation(index);

	TimerManager:RegisterTimer(function()
		local vo = t_zhanyin[body.tid]
		if not vo then return end;
		local objSwf = self.objSwf;
		if not objSwf then return end;
		local itemvo = {};
		itemvo.quality = vo.quality;
		itemvo.iconUrl = ResUtil:GetSpiritWarPrintIconURL(vo.iconName);
		itemvo.qualityUrl = ResUtil:GetSlotQuality(vo.quality);
		itemvo.lvl = vo.lvl;
		itemvo.name = vo.name;
		itemvo.open = true;
		local objSwf = self.objSwf;
		objSwf.resultItem:setData(UIData.encode(itemvo));
		objSwf.resultItem._visible = true;
		objSwf.resultItem._x = self:GetOldDongTianItemButton()._x + 110;
		objSwf.resultItem._y = self:GetOldDongTianItemButton()._y + 110;
	end, 2100, 1)

	TimerManager:RegisterTimer(function()
		local objSwf = self.objSwf;
		if not objSwf then return end;
		objSwf.resultItem._visible = false;
		self:FlyIn(body.pos,body.tid)
	end, 3000, 1)
end;

function UIWarPrintShop:ShowDanciFpx(body)
	local cfg = WarPrintUtils:OnGetItemCfg(body.tid)
	if not cfg then return end;
	local qua = cfg.quality;

	local vo = t_zhanyin[body.tid]
	if not vo then return end;
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local itemvo = {};
	itemvo.quality = vo.quality;
	itemvo.iconUrl = ResUtil:GetSpiritWarPrintIconURL(vo.iconName);
	itemvo.qualityUrl = ResUtil:GetSlotQuality(vo.quality);
	itemvo.lvl = vo.lvl;
	itemvo.name = vo.name;
	itemvo.open = true;
	local objSwf = self.objSwf;
	objSwf.resultItem:setData(UIData.encode(itemvo));
	objSwf.resultItem._visible = true;
	objSwf.resultItem._x = self:GetOldDongTianItemButton()._x + 110;
	objSwf.resultItem._y = self:GetOldDongTianItemButton()._y + 110;
	TimerManager:RegisterTimer(function()
		local objSwf = self.objSwf;
		if not objSwf then return end;
		objSwf.resultItem._visible = false;
		self:FlyIn(body.pos,body.tid)
	end, 300, 1)

end;



---------------------------图标飞效果-----------------------------------------
--飞入
function UIWarPrintShop:FlyIn(fromPos,tid)
	local objSwf = self.objSwf;
	if not objSwf then return; end

	objSwf.result_iconload._x = self:GetOldDongTianItemButton()._x + 110;
	objSwf.result_iconload._y = self:GetOldDongTianItemButton()._y + 110;

	local item;
	if fromPos > 0 then
		item = WarPrintUtils:OnGetItem(WarPrintModel.spirit_Bag,fromPos)
	end
	local vo = t_zhanyin[tid]
	local flyVO = {};
	flyVO.objName = 'FlyVO'
	flyVO.startPos = UIManager:PosLtoG(objSwf.result_iconload,0,0);
	if tid == WarPrintModel.tianHeXingShaID then
		flyVO.endPos = UIManager:PosLtoG(objSwf.fly_pos_tianhexingsha,0,0);
	else
		flyVO.endPos = UIManager:PosLtoG(objSwf.fly_pos,0,0);
	end
	flyVO.time = 0.5;
	flyVO.url = ResUtil:GetSpiritWarPrintIconURL(vo.iconName);
	flyVO.onStart = function(loader)
		loader._width = 40;
		loader._height = 40;
		if objSwf then
			objSwf.fly_pos_tianhexingsha.hide = true;
			objSwf.fly_pos.hide = true;
			objSwf.result_iconload._visible = true;
		end;
	end
	flyVO.tweenParam = {};
	flyVO.tweenParam._width = 54;
	flyVO.tweenParam._height = 54;
	flyVO.onUpdate = function()
	if objSwf then
		objSwf.fly_pos_tianhexingsha.hide = true;
		objSwf.fly_pos.hide = true;
	end;
	end
	flyVO.onComplete = function()
		if objSwf then
			objSwf.fly_pos_tianhexingsha.hide = false;
			objSwf.fly_pos.hide = false;
			objSwf.resultItem._visible = false;
			objSwf.result_iconload._visible = false;
		end
	end
	FlyManager:FlyIcon(flyVO);
end


function UIWarPrintShop:ListNotificationInterests()
	return {
			NotifyConsts.SpiritWarPrintShoping,
			NotifyConsts.SpiritWarPrintDebris,
			NotifyConsts.SpiritWarPrintUpdateDongTianLv,
		}
end;
function UIWarPrintShop:HandleNotification(name,body)
	if not self.bShowState then return end;
	if name == NotifyConsts.SpiritWarPrintShoping then
		--if self.isDanCiClick then

			-- local objSwf = self.objSwf;
			-- if not objSwf then return end;
			-- objSwf.resultItem._visible = false;
			-- self:FlyIn(body.pos,body.tid)
			self.objSwf["shopitem" .. self.oldDongTianLv].blink:playEffect(1);
			self:ShowDanciFpx(body);
			self.isDanCiClick = false;
		--	return
		--end;
		--self:OnSetShopResult(body);
	elseif name == NotifyConsts.SpiritWarPrintDebris then
		self:OnSetDebrisNum()
	elseif name == NotifyConsts.SpiritWarPrintUpdateDongTianLv then
		self:UpdateDongTianLvView();
		self:UpdateCostInfo();
	end;
end;

-- function UIWarPrintShop:GetWidth()
-- 	return 789
-- end;

-- function UIWarPrintShop:GetHeight()
-- 	return 269
-- end;


