_G.UISmithingStar = BaseUI:new("UISmithingStar");
UISmithingStar.currSelect = nil;
UISmithingStar.expendGold = 0;

function UISmithingStar:Create()
	self:AddSWF("smithingStarPanelV.swf",true,nil);
end

function UISmithingStar:OnLoaded(objSwf)
	objSwf.roleEquipList.itemClick = function(e) self:OnBodyEquipClick(e); end
	objSwf.roleEquipList.itemRollOver = function(e) self:OnBodyEquipOver(e); end
	objSwf.roleEquipList.itemRollOut = function(e) TipsManager:Hide(); end	
	-- objSwf.bagList.itemClick = function(e) self:OnBagEquipClick(e); end
	-- objSwf.bagList.itemRollOver = function(e) self:OnBagEquipOver(e); end
	-- objSwf.bagList.itemRollOut = function(e) TipsManager:Hide(); end
	objSwf.btnAdd.click = function(e) self:OnAddClick(e); end
	objSwf.btnAdd.rollOver = function() self:OnAddBtnOver() end
	objSwf.btnAdd.rollOut = function() self:OnAddBtnOut() end
	objSwf.panel.btnStren.click = function(e) self:OnStarClick(e); end
	objSwf.selecetItem.iconEquip.rollOver = function() self:OnSelectOver(); end
	objSwf.selecetItem.iconEquip.rollOut = function() TipsManager:Hide(); end
	objSwf.selectMax.rollOver = function() self:OnSelectMaxOver() end
	objSwf.selectMax.rollOut = function() TipsManager:Hide() end
	
	objSwf.panel.tfNeedItem.rollOver = function(e) self:OnNeedItemOver(e) end
	objSwf.panel.tfNeedItem.rollOut = function(e) TipsManager:Hide() end
	objSwf.panel.itemGetBtn.htmlLabel = StrConfig['smithing031']
	objSwf.panel.itemGetBtn.click = function() self:OnGetBtnClick() end

	objSwf.btnRules.rollOver =  function() TipsManager:ShowBtnTips(StrConfig["smithingRule1"],TipsConsts.Dir_RightDown); end
	objSwf.btnRules.rollOut = function(e) TipsManager:Hide(); end
	
end

--获取格子VO
local function GetViewData(item,isBig)
	local vo = {};
	vo.hasItem = true;
	vo.pos = item:GetPos();
	vo.isBig = isBig and true or false;
	EquipUtil:GetDataToEquipUIVO(vo,item,isBig);
	return vo;
end

function UISmithingStar:OnBodyEquipClick(e)
	if not e.item then return end
	local bag = BagModel:GetBag(BagConsts.BagType_Role);
	local item = bag:GetItemByPos(e.item.pos);

	if item == self.currSelect then
		return
	end
	self.currSelect = item
	self:RefreshSelect()
	self:CheckShowGetPath()
end

function UISmithingStar:OnBodyEquipOver(e)
	if not e.item then
		return;
	end
	
	local bag = BagModel:GetBag(BagConsts.BagType_Role);
	local item = bag:GetItemByPos(e.item.pos);
	if item then
		--TipsManager:ShowItemTips(item.tid);
		TipsManager:ShowBagTips(BagConsts.BagType_Role,item.pos, TipsConsts.Dir_LeftDown);
	end
end

function UISmithingStar:getSelectVo(bMax)
	local config = t_equip[self.currSelect:GetTid()]
	local data = {}
	data.id = config.id;
	data.count = self.currSelect:GetCount();
	data.showCount = "";
	data.iconUrl = ResUtil:GetItemIconUrl(config.icon);
	data.bigIconUrl = ResUtil:GetItemIconUrl(config.icon,54);
	data.iconUrl64 = ResUtil:GetItemIconUrl(config.icon,64);
	data.bind = self.currSelect:GetBindState();
	data.showBind = data.bind==BagConsts.Bind_GetBind or data.bind==BagConsts.Bind_Bind
	data.qualityUrl = ResUtil:GetSlotQuality(config.quality);
	data.bigQualityUrl = ResUtil:GetSlotQuality(config.quality, 54)
	data.qualityUrl64 = ResUtil:GetSlotQuality(config.quality, 64)
	data.quality = config.quality
	data.isBlack = false;
	data.super = 0;
	if data.quality == BagConsts.Quality_Green1 then
		data.super = 1
	elseif data.quality == BagConsts.Quality_Green2 then
		data.super = 2
	elseif data.quality == BagConsts.Quality_Green3 then
		data.super = 3
	end
	if bMax then
		data.strenLvl = SmithingModel:GetMaxStarCount(self.currSelect:GetTid())
	else
		data.strenLvl = EquipModel:GetStrenLvl(self.currSelect:GetId());
	end
	data.biaoshiUrl = ResUtil:GetBiaoShiUrl(config.identifying)
	data.bigBiaoshiUrl = ResUtil:GetBiaoShiUrl(config.identifying, 54)
	data.biaoshiUrl64 = ResUtil:GetBiaoShiUrl(config.identifying, 64)
	return UIData.encode(data)
end

function UISmithingStar:RefreshSelect()
	if self.currSelect then
		local bag = BagModel:GetBag(BagConsts.BagType_Role);
		local item = bag:GetItemByPos(self.currSelect.pos)
		if not item then
			-- self.objSwf["equip" .. (self.currSelect.pos + 1)].selected = false
			self.currSelect = nil
		end
	end
	if not self.currSelect then
		local list = BagUtil:GetBagItemList( BagConsts.BagType_Role, BagConsts.ShowType_All)
		for i, v in ipairs(list) do
			if v.hasItem then
				local bag = BagModel:GetBag(BagConsts.BagType_Role);
				local item = bag:GetItemByPos(v.pos)
				if item then
					if not self.currSelect then
						self.currSelect = item
					end
					if EquipUtil:IsCanStarUp(item) then
						self.currSelect = item
						break
					end
				end
			end
		end
	end

	if not self.currSelect then
		self.objSwf.noChoose._visible = true
		self:ClearInfoView();
		return;
	end
	self:ShowSelectMaxEquip()
	self.objSwf["equip" .. (self.currSelect.pos + 1)].selected = true
	self.objSwf.noChoose._visible = false
	self.objSwf.txt_name.htmlText = string.format(StrConfig["shop504"],TipsConsts:GetItemQualityColor(t_equip[self.currSelect:GetTid()].quality),t_equip[self.currSelect:GetTid()].name)

	self.objSwf.selecetItem.iconEquip:setData(self:getSelectVo());
	
	local equip = SmithingModel:GetEquipStrenInfo(self.currSelect);
	local max = SmithingModel:GetMaxStarCount(self.currSelect:GetTid())
	if max == 0 then
		self.objSwf.siStar._visible = false
		self.objSwf.panel._visible = false
		self.objSwf.selectMax._visible = false
		self.objSwf.selectmaxIcon._visible = false
		self.objSwf.txt_max._visible = false;
		self.objSwf.btnAdd.visible = false
		self.objSwf.icon_NoStar._visible = true
		return
	end
	self.objSwf.icon_NoStar._visible = false
	local star = equip.strenLvl;
	local moon = SmithingModel:GetMoonLevel(self.currSelect.tid);
	local attr = SmithingModel:GetAddAttr(self.currSelect.tid,star);
	-- self.objSwf.panel.tfFight.label = attr.fight..'';
	self.objSwf.panel.fightcur.fightLoader.num = attr.fight
	self.objSwf.panel.lbAttack.label = string.format(StrConfig.smithing023,attr.name);
	self.objSwf.panel.tfAttack.label = attr.value..'';

	local nCurShow = star
	if star > 24 then
		self.objSwf.siStar.star = "EquipStrenSun"
		self.objSwf.siStar.grayStar = "EquipStrenGraySun"
		self.objSwf.panel.star1.star.star = "EquipStrenSun"
		nCurShow = nCurShow - 24
	elseif star >= moon then
		nCurShow = nCurShow - moon + 1
		self.objSwf.siStar.star = "EquipStrenMoon"
		self.objSwf.siStar.grayStar = "EquipStrenGrayMoon"
		self.objSwf.panel.star1.star.star = "EquipStrenMoon"
	else
		self.objSwf.siStar.star = "EquipStrenStar"
		self.objSwf.siStar.grayStar = "EquipStrenGrayStar"
		self.objSwf.panel.star1.star.star = "EquipStrenStar"
	end

	self.objSwf.panel.tfLvl.text = nCurShow..'';

	self.objSwf.panel.star1.star.value = 1;
	local maximum = nCurShow + equip.emptystarnum
	if maximum > 12 then
		maximum = maximum - 12
	end
	if star > 24 then
		maximum = 12
	end
	if maximum == 12 then
		self.objSwf.btnAdd.visible = false
	else
		self.objSwf.btnAdd.visible = true
	end

	self.objSwf.siStar.maximum = maximum;
	self.objSwf.siStar._visible = true;
	self.objSwf.siStar.value = nCurShow;
	self.objSwf.siStar:playStarOk(nCurShow)
	
	if star == max then
		self.objSwf.txt_max._visible = true
		self.objSwf.panel._visible = false
		return
	else
		self.objSwf.txt_max._visible = false
		self.objSwf.panel._visible = true
	end
	
	if not attr.max then
		star = star+1;
	end
	nCurShow = star
	if nCurShow > 24 then
		nCurShow = nCurShow - 24
		self.objSwf.panel.star2.nextStar.star = "EquipStrenSun"
	elseif nCurShow >= moon then
		nCurShow = nCurShow - moon + 1
		self.objSwf.panel.star2.nextStar.star = "EquipStrenMoon"
	else
		self.objSwf.panel.star2.nextStar.star = "EquipStrenStar"
	end
	
	self.objSwf.panel.star2.nextStar.value = 1;
	attr = SmithingModel:GetAddAttr(self.currSelect.tid,star);
	self.objSwf.panel.tfNextLvl.text = nCurShow..'';
	-- self.objSwf.panel.tfNextFight.label = attr.fight..'';
	self.objSwf.panel.fightnext.fightLoader.num = attr.fight
	self.objSwf.panel.lbNextAttack.label = string.format(StrConfig.smithing023,attr.name);
	self.objSwf.panel.tfNextAttack.label = attr.value..'';
	self.objSwf.panel.tfShengxingSuccess.text =	SmithingModel:GetStarSuccessRate(star) .. "%"
	if SmithingModel:GetStarSuccessRate(star) == 100 or star > 24 then
		self.objSwf.panel.cbItemLvUp._visible = false
	else
		self.objSwf.panel.cbItemLvUp._visible = true
	end
	
	local config = t_stren[star];
	self.objSwf.panel.cbItemLvUp.htmlLabel = string.format(StrConfig['smithing014'], 
		config.yuanbaoNum > MainPlayerModel.humanDetailInfo.eaUnBindMoney and "#FF0000" or "#00FF00", config.yuanbaoNum)..StrConfig['smithing025'];
	local has = BagModel:GetItemNumInBag(config.itemId);
	local color = has < config.itemNum and "#FF0000" or "#00FF00";
	if has < config.itemNum then
		self.objSwf.panel.btnStren:clearEffect()
	else
		self.objSwf.panel.btnStren:showEffect(ResUtil:GetButtonEffect10())
	end
	local color1 = TipsConsts:GetItemQualityColor(t_item[config.itemId].quality)
	self.objSwf.panel.tfNeedItem.htmlLabel = string.format( StrConfig['smithing030'], color1, t_item[config.itemId].name, color, config.itemNum, has);
	-- self.objSwf.panel.tfNeedMoney.htmlLabel = string.format( StrConfig['smithing026'], MainPlayerModel.humanDetailInfo.eaBindGold >= config.gold and "#00FF00" or "#FF0000", config.gold .. "银两")
	self.expendGold = config.gold;
end

function UISmithingStar:ShowSelectMaxEquip()
	self.objSwf.selectMax:setData(self:getSelectVo(true))
	self.objSwf.selectMax._visible = true
	self.objSwf.selectmaxIcon._visible = true
end

function UISmithingStar:ClearInfoView()
	self.objSwf.panel._visible = false
	self.objSwf.selectMax._visible = false
	self.objSwf.selectmaxIcon._visible = false
	self.objSwf.txt_name.htmlText = ""
	self.objSwf.selecetItem.iconEquip:setData(UIData.encode({}));
	self.objSwf.siStar._visible = false;
	self.objSwf.txt_max._visible = false;
	self.objSwf.btnAdd.visible = false
	self.objSwf.icon_NoStar._visible = false
end

-- function UISmithingStar:OnBagEquipOver(e)
-- 	if not e.item then
-- 		return;
-- 	end
	
-- 	local bag = BagModel:GetBag(BagConsts.BagType_Bag);
-- 	local item = bag:GetItemByPos(e.item.pos);
-- 	if item then
-- 		--TipsManager:ShowItemTips(item.tid);
-- 		TipsManager:ShowBagTips(BagConsts.BagType_Bag,item.pos);		
-- 	end
-- end

function UISmithingStar:OnAddClick()
	if not self.currSelect then
		return;
	end
	local config = t_stren[SmithingModel:GetEquipStrenInfo(self.currSelect).strenLvl + 1];
	local cost = split(config.openstar,',');
	if BagModel:GetItemNumInBag(toint(cost[1])) < tonumber(cost[2]) then
		FloatManager:AddNormal(StrConfig["equip507"]);--道具不足
		UIQuickBuyConfirm:Open(self,toint(cost[1]))
		return
	end
	
	SmithingController:SendOpenStar(self.currSelect.id);
end

function UISmithingStar:OnAddBtnOver()
	if not self.currSelect then
		return
	end
	local star = SmithingModel:GetEquipStrenInfo(self.currSelect).strenLvl
	local max = SmithingModel:GetMaxStarCount(self.currSelect:GetTid())
	if star >= max then
		return
	end
	local config = t_stren[star + 1];
	local cost = split(config.openstar,',');
	TipsManager:ShowBtnTips(string.format(StrConfig['smithing205'], 
		BagModel:GetItemNumInBag(toint(cost[1])) < tonumber(cost[2]) and '#FF0000' or '#00FF00',
		t_item[toint(cost[1])].name .. "*" ..cost[2]), TipsConsts.Dir_RightUp)
end

function UISmithingStar:OnAddBtnOut()
	TipsManager:Hide()
end

function UISmithingStar:OnStarClick()
	if not self.currSelect then
		return;
	end
	local equip = SmithingModel:GetEquipStrenInfo(self.currSelect);
	local use = self.objSwf.panel.cbItemLvUp.selected and 1 or 0;
	local star = equip.strenLvl;
	local config = t_stren[star + 1];

	if use == 1 then
		if config.yuanbaoNum > MainPlayerModel.humanDetailInfo.eaUnBindMoney then
			FloatManager:AddNormal(StrConfig['equip511']) --元宝不足
			return
		end
	end
	if MainPlayerModel.humanDetailInfo.eaBindGold < config.gold then
		FloatManager:AddNormal(StrConfig["equip505"]);--银两不足
		return;
	end

	if BagModel:GetItemNumInBag(config.itemId) < config.itemNum then
		FloatManager:AddNormal(StrConfig["equip507"]);--道具不足
		UIQuickBuyConfirm:Open(self,config.itemId)
		return
	end

	if star < 24 and equip.emptystarnum == 0 and star % 12 ~= 0 then
		FloatManager:AddNormal(StrConfig['smithing206'])
		return
	end

	local bindState = self.currSelect:GetBindState()
	if bindState == BagConsts.Bind_UseBind or bindState == BagConsts.Bind_None or
	 bindState == BagConsts.Bind_UseUnBind then
		local okfun = function()
			SmithingController:SendEquipStar(self.currSelect.id,use)
		end
		UIConfirm:Open(StrConfig["smithing105"], okfun)
	else
		SmithingController:SendEquipStar(self.currSelect.id,use)
	end
end

function UISmithingStar:OnGetBtnClick()
	if not self.currSelect then
		return
	end
	local equip = SmithingModel:GetEquipStrenInfo(self.currSelect);
	local star = equip.strenLvl;
	local config = t_stren[star + 1];
	UIQuickBuyConfirm:Open(self,config.itemId)
end

function UISmithingStar:OnSelectOver()
	if not self.currSelect then
		return;
	end
	TipsManager:ShowBagTips(self.currSelect:GetBagType(), self.currSelect.pos);
	-- TipsManager:ShowItemTips(self.currSelect.tid);
end

function UISmithingStar:OnSelectMaxOver()
	if not self.currSelect then
		return
	end
	local tipsVO = ItemTipsVO:new()
	ItemTipsUtil:CopyItemDataToTipsVO(self.currSelect,tipsVO)
	tipsVO.tipsType = TipsConsts.Type_Equip
	tipsVO.tipsShowType = TipsConsts.ShowType_Normal
	tipsVO.strenLvl = SmithingModel:GetMaxStarCount(self.currSelect:GetTid())
	tipsVO.equiped = false
	tipsVO.isInBag = false
	TipsManager:ShowRespTips(tipsVO)
end

function UISmithingStar:OnNeedItemOver(e)
	if not self.currSelect then
		return;
	end
	
	local star = SmithingModel:GetEquipStrenInfo(self.currSelect).strenLvl --self.currSelect.star;
	-- local star = 1;
	local max = SmithingModel:GetMaxStarCount(self.currSelect:GetTid());
	-- if star< max then
		star = star + 1;
	-- end
	local config = t_stren[star];
	if not config then
		return;
	end
	
	TipsManager:ShowItemTips(config.itemId);
end

function UISmithingStar:playSuccessPfx(id, lv)
	local objSwf = self.objSwf
	if not objSwf then return end
	if not self.currSelect then
		return
	end
	if self.currSelect:GetId() ~= id then
		return
	end
	objSwf.EquipPfx:gotoAndPlay(2)
	if lv > 24 then
		-- 太阳特效
		objSwf.siStar:playPfx(1, false, lv - 24)
	elseif lv >= SmithingModel:GetMoonLevel(self.currSelect.tid) then
		objSwf.siStar:playPfx(1, true, lv - SmithingModel:GetMoonLevel(self.currSelect.tid) + 1)
	else
		objSwf.siStar:playPfx(1, false, lv)
	end
end

function UISmithingStar:playFailPfx(id, lv)
	local objSwf = self.objSwf
	if not objSwf then return end
	if not self.currSelect then
		return
	end
	if self.currSelect:GetId() ~= id then
		return
	end
	if lv > 24 then
		--太阳特效
		objSwf.siStar:playPfx(1, false, lv - 24)
	elseif lv > SmithingModel:GetMoonLevel(self.currSelect.tid) then
		objSwf.siStar:playPfx(2, true, 0)
	else
		objSwf.siStar:playPfx(2, false, 0)
	end
end

function UISmithingStar:playOpenPfx(id)
	local objSwf = self.objSwf
	if not objSwf then return end

	if not self.currSelect then
		return
	end
	if self.currSelect:GetId() ~= id then
		return
	end
	objSwf.siStar:playPfx(3, false, 0)
end

function UISmithingStar:playFailPfx1()
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.failPfx:gotoAndPlay(2)
end

function UISmithingStar:HandleNotification(name,body)
	if name == NotifyConsts.EquipStarResult then
		self:RefreshSelect();
		if body[1] == 0 then
			--- 强化成功
			SoundManager:PlaySfx(2006)
			self:playSuccessPfx(body[2], body[3])
		elseif body[1] == -9 then
			--- 掉星
			self:playFailPfx(body[2], body[3])
		end
		self:ShowBodyEquips();
		-- self:ShowBagEquips();
		self:ShowStrenLink()
	elseif name == NotifyConsts.EquipOpenStarResult then
		self:RefreshSelect()
		self:playOpenPfx()
	elseif name == NotifyConsts.PlayerAttrChange then
		if body.type == enAttrType.eaBindGold then
			self:RefreshSelect()
			-- self:ShowBodyEquips();
			-- self:ShowBagEquips();
		end
	elseif name == NotifyConsts.PlayerModelChange then
		SmithingModel:DrawRole(self)
	else
		self:RefreshSelect()
		self:ShowBodyEquips();
		-- self:ShowBagEquips();
	end
end

function UISmithingStar:ListNotificationInterests()
	return {NotifyConsts.EquipStarResult,
			NotifyConsts.EquipOpenStarResult,
			NotifyConsts.BagAdd,NotifyConsts.BagRemove,
			NotifyConsts.BagUpdate,
			NotifyConsts.PlayerAttrChange,
			NotifyConsts.PlayerModelChange,}
end

local function RefreshEquipList(equips,list)
	if not list or not equips then
		return;
	end
	
	list.dataProvider:cleanUp();
	for index,equip in ipairs(equips) do
		local config = equip:GetCfg();
		if config.quality >= EquipStarFullMinQuality then
			local view = GetViewData(equip);
			list.dataProvider:push(UIData.encode(view));
		end
	end
	list:invalidateData();
end

function UISmithingStar:OnShow()
	self:ShowBodyEquips();
	-- self:ShowBagEquips();
	self:RefreshSelect();
	self:ShowStrenLink();
	self:CheckShowGetPath();
	SmithingModel:DrawScene(self, self.objSwf.loader)
end

function UISmithingStar:CheckShowGetPath( )
	local objSwf = self.objSwf
	if not objSwf then return end
	local isShow = false
	if not self.currSelect then return end
	local equip = SmithingModel:GetEquipStrenInfo(self.currSelect);
	local star = equip.strenLvl;
	local config = t_stren[star + 1];
	if not config and not config.itemId then return end
	local cfg  = t_itemacquirelist[config.itemId]
	if cfg then 
		if cfg.itemway == nil then
			isShow = false
		else
			isShow = true
		end
	else
		isShow = false
	end
	objSwf.panel.itemGetBtn._visible = isShow
end

function UISmithingStar:ShowBodyEquips()
	local list = BagUtil:GetBagItemList( BagConsts.BagType_Role, BagConsts.ShowType_All)
	self.objSwf.roleEquipList.dataProvider:cleanUp();
	local fightValue = 0
	for i,slotVO in ipairs(list) do
		local data = slotVO:GetData()
		data.CanOperate = false
		if slotVO.hasItem then
			local bag = BagModel:GetBag(BagConsts.BagType_Role);
			local item = bag:GetItemByPos(slotVO.pos)
			if item then
				if EquipUtil:IsCanStarUp(item) then
					data.CanOperate = true
				end
				fightValue = fightValue + EquipUtil:GetStarAddFight(item:GetTid(), SmithingModel:GetEquipStrenInfo(item).strenLvl)
			end
		end

		self.objSwf.roleEquipList.dataProvider:push(UIData.encode(data));
	end
	self.objSwf.roleEquipList:invalidateData()
	-- RefreshEquipList(equips,self.objSwf.roleEquipList);
	self.objSwf.fightLoader.num = fightValue
end

-- function UISmithingStar:ShowBagEquips()
-- 	local bag = BagModel:GetBag(BagConsts.BagType_Bag);
-- 	local equips = bag:GetItemListByShowType(BagConsts.ShowType_Equip);
-- 	RefreshEquipList(equips,self.objSwf.bagList);
-- end

function UISmithingStar:OnHide()
	self.currSelect = nil;
	self:ClearInfoView();
	self.expendGold = 0;
	SmithingModel:ClearScene(self)
end

function UISmithingStar:ShowStrenLink()
	local bOpen = false
	local linkId = EquipModel:GetStrenLinkId()
	if self.currLinkId and self.currLinkId < linkId then
		bOpen = true
	end
	self.currLinkId = linkId;

	for i = 1, 6 do
		self.objSwf["linkBtn" ..i].visible = false
		self.objSwf['linkPfx' ..i]._visible = false
	end
	for i,cfg in ipairs(t_strenlink) do
		if self.currLinkId == cfg.id then
			self:ShowStrenLinkBtn(i, true, bOpen)
		elseif self.currLinkId >= cfg.id then
			self:ShowStrenLinkBtn(i,true);
		else
			self:ShowStrenLinkBtn(i,false);
			break
		end
	end
end

function UISmithingStar:ShowStrenLinkBtn(index,active,bOpen)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local button = objSwf["linkBtn"..index];
	button.alwaysRollEvent = true;
	button.visible = true;
	button.disabled = not active;
	objSwf['linkPfx' ..index]._visible = active
	if bOpen then
		objSwf['linkPfx' ..index].lightPfx:play()
	end
	button.rollOut = function() TipsManager:Hide(); end
	button.rollOver = function() self:OnStrenLinkRollOver(index,button); end
end

function UISmithingStar:OnStrenLinkRollOver(index,button)
	local linkCfg = t_strenlink[index];
	if not linkCfg then return; end
	local tipsVO = {};
	tipsVO.linkId = index;
	if button.disabled then
		tipsVO.activeNum = EquipModel:GetAllStrenLvl();
	else
		tipsVO.activeNum = linkCfg.level
	end
	TipsManager:ShowTips(TipsConsts.Type_StrenLink,tipsVO,TipsConsts.ShowType_Normal,TipsConsts.Dir_RightDown);
end

function UISmithingStar:OnRulesClick()
		
end


-- function UISmithingStar:GetWidth()
	-- return 1146;
-- end

-- function UISmithingStar:GetHeight()
	-- return 687;
-- end


