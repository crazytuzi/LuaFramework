_G.UISmithingWash = BaseUI:new("UISmithingWash");

function UISmithingWash:Create()
	self:AddSWF("smithingWashPanel.swf",true,nil);
end

function UISmithingWash:OnLoaded(objSwf)
	objSwf.roleEquipList.itemClick = function(e) self:OnBodyEquipClick(e); end
	objSwf.roleEquipList.itemRollOver = function(e) self:OnBodyEquipOver(e); end
	objSwf.roleEquipList.itemRollOut = function(e) TipsManager:Hide(); end	
	-- objSwf.bagList.itemClick = function(e) self:OnBagEquipClick(e); end
	-- objSwf.bagList.itemRollOver = function(e) self:OnBagEquipOver(e); end
	-- objSwf.bagList.itemRollOut = function(e) TipsManager:Hide(); end

	objSwf.seleceitem.rollOver = function() if not self.selectEquip then return end TipsManager:ShowBagTips(self.selectEquip:GetBagType(), self.selectEquip.pos) end
	objSwf.seleceitem.rollOut = function(e) TipsManager:Hide(); end
	-- RewardManager:RegisterListTips(objSwf.panel.costList);

	objSwf.rult.rollOver =  function() TipsManager:ShowBtnTips(StrConfig["smithingRule3"],TipsConsts.Dir_RightDown); end
	objSwf.rult.rollOut = function(e) TipsManager:Hide(); end

	objSwf.panel.itemGetBtn.htmlLabel = StrConfig['smithing031']
	objSwf.panel.itemGetBtn.click = function() self:OnGetBtnClick() end
end

function UISmithingWash:OnShow()
	self:ShowBodyEquips();
	-- self:ShowBagEquips();
	self:ShowSelectedEquip()
	self:ShowWashLink();
	SmithingModel:DrawScene(self, self.objSwf.loader)

	self.timerKey = TimerManager:RegisterTimer( function()
		if self.auto then
			--处理自动
			if not self.selectEquip then
				self.auto = false
				return
			end
			self:AutoLvUp()
		end
	end, 600, 0 )
end

function UISmithingWash:AutoLvUp()
	local washInfo = EquipModel:getWashInfo(self.selectEquip:GetId())
	local itemCfg = t_equip[self.selectEquip:GetTid()]
	local lvConfig = t_extraclass[itemCfg.level]
	local qualityConfig = t_extraquality[itemCfg.quality]

	local bHaveMaxLv = true
	for i = 1, 5 do
		local info = washInfo[i]
		if info then
			local cfg = t_extraatt[info.id]
			if cfg.lv < lvConfig.maxLv then
				bHaveMaxLv = false
			end
		end
	end

	if bHaveMaxLv then
		self.auto = false
	else
		local cost = split(qualityConfig.cost, ',')
		if BagModel:GetItemNumInBag(toint(cost[1])) < toint(cost[2]) then
			FloatManager:AddNormal(StrConfig["equip507"], self.objSwf.panel.btnAutoLvUp);--道具不足
			UIQuickBuyConfirm:Open(self,toint(cost[1]))
			self.auto = false
			self:SetBtnShow()
			return
		end
		EquipController:ReqWashLvUp(self.selectEquip:GetId()) 
	end
end

local function RefreshEquipList(equips,list)
	if not list or not equips then
		return;
	end
	local equipList = {}

	for index,item in pairs(equips) do 
		if t_extraquality[t_equip[item:GetTid()].quality].num ~= 0 then
			table.push(equipList,UIData.encode(UISmithingWash:GetSlotVO(item,nil,index)));
		end
	end;
	list.dataProvider:cleanUp();
	list.dataProvider:push(unpack(equipList));
	list:invalidateData();
end

function UISmithingWash:ShowBodyEquips()
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
				if EquipUtil:IsCanWash(item:GetId(), item:GetTid()) then
					data.CanOperate = true
				end
				fightValue = fightValue + EquipUtil:GetWashAddFight(item:GetId(), item:GetTid())
			end
		end
		self.objSwf.roleEquipList.dataProvider:push(UIData.encode(data));
	end
	self.objSwf.roleEquipList:invalidateData()
	-- RefreshEquipList(equips,self.objSwf.roleEquipList);
	self.objSwf.fight.fightLoader.num = fightValue
end

-- function UISmithingWash:ShowBagEquips()
-- 	local bag = BagModel:GetBag(BagConsts.BagType_Bag);
-- 	local equips = bag:GetItemListByShowType(BagConsts.ShowType_Equip);
-- 	RefreshEquipList(equips,self.objSwf.bagList);
-- end

--获取格子VO
function UISmithingWash:GetSlotVO(item,isBig,index)
	local vo = {};
	vo.hasItem = true;
	vo.myindex = index;
	vo.pos = item:GetPos();
	vo.isBig = isBig and true or false;
	EquipUtil:GetDataToEquipUIVO(vo,item,isBig);
	return vo;
end

function UISmithingWash:OnBodyEquipClick(e)
	if not e.item then return end

	local bag = BagModel:GetBag(BagConsts.BagType_Role);
	local item = bag:GetItemByPos(e.item.pos);

	if not item or item == self.selectEquip then
		return
	end
	self.auto = false
	self.selectEquip = item;
	self:ShowSelectedEquip();
end

-- function UISmithingWash:OnBagEquipClick(e)
-- 	if not e.item then return end

-- 	local bag = BagModel:GetBag(BagConsts.BagType_Bag);
-- 	local item = bag:GetItemByPos(e.item.pos);
-- 	if not item or item == self.selectEquip then
-- 		return
-- 	end

-- 	self.selectEquip = item;
-- 	self:ShowSelectedEquip();
-- end

function UISmithingWash:OnBodyEquipOver(e)
	if not e.item then return end
	
	local bag = BagModel:GetBag(BagConsts.BagType_Role);
	local item = bag:GetItemByPos(e.item.pos);
	if item then
		TipsManager:ShowBagTips(BagConsts.BagType_Role,item.pos, TipsConsts.Dir_LeftDown);
	end
end

-- function UISmithingWash:OnBagEquipOver(e)
-- 	if not e.item then return end
	
-- 	local bag = BagModel:GetBag(BagConsts.BagType_Bag);
-- 	local item = bag:GetItemByPos(e.item.pos);
-- 	if item then
-- 		TipsManager:ShowBagTips(BagConsts.BagType_Bag,item.pos);
-- 	end
-- end

function UISmithingWash:getSelectVo()
	local config = t_equip[self.selectEquip:GetTid()]
	local data = {}
	data.id = config.id;
	data.count = self.selectEquip:GetCount();
	data.showCount = "";
	data.iconUrl = ResUtil:GetItemIconUrl(config.icon);
	data.bigIconUrl = ResUtil:GetItemIconUrl(config.icon,54);
	data.iconUrl64 = ResUtil:GetItemIconUrl(config.icon,64);
	data.bind = self.selectEquip:GetBindState();
	data.showBind = data.bind==BagConsts.Bind_GetBind or data.bind==BagConsts.Bind_Bind
	data.qualityUrl = ResUtil:GetSlotQuality(config.quality);
	data.bigQualityUrl = ResUtil:GetSlotQuality(config.quality, 54)
	data.qualityUrl64 = ResUtil:GetSlotQuality(config.quality, 64)
	data.quality = config.quality
	data.isBlack = false;
	data.super = 0;
	if data.quality == BagConsts.Quality_Green2 then
		data.super = 2;
	elseif data.quality == BagConsts.Quality_Green3 then
		data.super = 3;
	end
	data.strenLvl = EquipModel:GetStrenLvl(self.selectEquip:GetId());
	data.biaoshiUrl = ResUtil:GetBiaoShiUrl(config.identifying)
	data.bigBiaoshiUrl = ResUtil:GetBiaoShiUrl(config.identifying, 54)
	data.biaoshiUrl64 = ResUtil:GetBiaoShiUrl(config.identifying, 64)
	return UIData.encode(data)
end

function UISmithingWash:IsDeleteSelecte()
	local bag = BagModel:GetBag(self.selectEquip:GetBagType());
	return not bag:GetItemByPos(self.selectEquip:GetPos())
end

function UISmithingWash:SetBtnShow()
	local objSwf = self.objSwf
	if not objSwf then return end
	if self.auto then
		objSwf.panel.btnLvUp.visible = false
		objSwf.panel.btnAutoLvUp.visible = true
		objSwf.panel.btnAutoLvUp.htmlLabel = StrConfig["smithing103"]
	else
		objSwf.panel.btnLvUp.visible = true
		objSwf.panel.btnAutoLvUp.visible = true
		objSwf.panel.btnAutoLvUp.htmlLabel = StrConfig["smithing102"]
	end
end

local s_str = "%s：<font color='#00ff00'>%s</font>"
function UISmithingWash:ShowSelectedEquip()
	local objSwf = self.objSwf
	if not objSwf then return end
	if not self.selectEquip or self:IsDeleteSelecte() then
		self.selectEquip = nil
		local list = BagUtil:GetBagItemList( BagConsts.BagType_Role, BagConsts.ShowType_All)
		for i, v in ipairs(list) do
			if v.hasItem then
				local bag = BagModel:GetBag(BagConsts.BagType_Role);
				local item = bag:GetItemByPos(v.pos)
				if item then
					if not self.selectEquip then
						self.selectEquip = item
					end
					if EquipUtil:IsCanWash(item:GetId(), item:GetTid()) then
						self.selectEquip = item
						break
					end
				end
			end
		end
	end

	if not self.selectEquip then
		self:ClearSelectInfo()
		objSwf.seleceitem:setData(UIData.encode({}));
		return 
	end
	self.objSwf["equip" .. (self.selectEquip.pos + 1)].selected = true
	objSwf.nochoose._visible = false
	objSwf.txt_name.htmlText = string.format(StrConfig["shop504"],TipsConsts:GetItemQualityColor(t_equip[self.selectEquip:GetTid()].quality),t_equip[self.selectEquip:GetTid()].name)
	local vo = {}
	vo.isBig = true
	objSwf.seleceitem:setData(self:getSelectVo());

	--这里显示洗练详细属性
	local washInfo = EquipModel:getWashInfo(self.selectEquip:GetId())
	local itemCfg = t_equip[self.selectEquip:GetTid()]
	local lvConfig = t_extraclass[itemCfg.level]
	local qualityConfig = t_extraquality[itemCfg.quality]

	local bAllActive = true
	local bHaveMaxLv = true
	local success = 10000
	for i = 1, 5 do
		local UI = objSwf['washlabel' ..i]
		local info = washInfo[i]
		if info then
			UI._visible = true
			UI.washBtn.visible = true
			UI.progress._visible = true
			local cfg = t_extraatt[info.id]
			UI.progress:setProgress(cfg.lv, lvConfig.maxLv)
			-- UI.progress.value = cfg.lv
			--- 这里处理洗练按钮点击消耗
			local cost = split(qualityConfig.wash, ',')
			UI.washBtn.click = function()
				UI.btnPfx:play()
				if BagModel:GetItemNumInBag(toint(cost[1])) < toint(cost[2]) then
					FloatManager:AddNormal(StrConfig["equip507"], UI.washBtn);--道具不足
					UIQuickBuyConfirm:Open(self,toint(cost[1]))
					return
				end
				EquipController:ReqWashChangeAtt(self.selectEquip:GetId(), info.uid)
			end
			local color = BagModel:GetItemNumInBag(toint(cost[1])) < toint(cost[2]) and '#FF0000' or '#00FF00'
			UI.washBtn.rollOver = function() TipsManager:ShowBtnTips(string.format(StrConfig["smithing106"], color,t_item[toint(cost[1])].name, cost[2]),TipsConsts.Dir_RightDown) end
			UI.washBtn.rollOut = function() TipsManager:Hide() end
			UI.washName.htmlLabel = string.format(s_str, PublicAttrConfig.proName[cfg.type], cfg.att)
			UI.washLv.htmlLabel = cfg.lv .. StrConfig['smithing108']
			if cfg.lv < lvConfig.maxLv then
				bHaveMaxLv = false
				if success > cfg.probability then
					success = cfg.probability
				end
			end
		elseif qualityConfig.num >= i then
			UI._visible = true
			UI.washName.htmlLabel = StrConfig['smithing101']
			UI.washLv.htmlLabel = ""
			UI.washBtn.visible = false
			UI.progress._visible = false
			bAllActive = false
		else
			UI._visible = false
		end
	end

	objSwf.fightcur.fightLoader.num = EquipUtil:GetWashAddFight(self.selectEquip:GetId(), self.selectEquip:GetTid())
	objSwf.max._visible = false
	objSwf.fightcur._visible = true
	objSwf.icon_NoWash._visible = false
	local cost

	if bAllActive then
		if bHaveMaxLv then
			if qualityConfig.num == 0 then
				objSwf.max._visible = false
				objSwf.icon_NoWash._visible = true
				objSwf.fightcur._visible = false
			else
				objSwf.max._visible = true
			end
		else
			cost = split(qualityConfig.cost, ',')
			objSwf.panel.btnLvUp.click = function()
				if BagModel:GetItemNumInBag(toint(cost[1])) < toint(cost[2]) then
					FloatManager:AddNormal(StrConfig["equip507"], objSwf.panel.btnLvUp);--道具不足
					UIQuickBuyConfirm:Open(self,toint(cost[1]))
					return
				end
				EquipController:ReqWashLvUp(self.selectEquip:GetId()) 
			end
			objSwf.panel.btnAutoLvUp.click = function()
				if not self.auto then
					if BagModel:GetItemNumInBag(toint(cost[1])) < toint(cost[2]) then
						FloatManager:AddNormal(StrConfig["equip507"], objSwf.panel.btnAutoLvUp);--道具不足
						UIQuickBuyConfirm:Open(self,toint(cost[1]))
						return
					end
					self.auto = true
					self:SetBtnShow()
					EquipController:ReqWashLvUp(self.selectEquip:GetId()) 
				else
					self.auto = false
					self:SetBtnShow()
				end
			end
			self:SetBtnShow()
			objSwf.panel.btnActive.visible = false
		end
	else
		cost = split(qualityConfig.activate, ',')
		objSwf.panel.btnActive.visible = true
		objSwf.panel.btnLvUp.visible = false
		objSwf.panel.btnAutoLvUp.visible = false
		objSwf.panel.btnActive.click = function()
			if BagModel:GetItemNumInBag(toint(cost[1])) < toint(cost[2]) then
				FloatManager:AddNormal(StrConfig["equip507"], objSwf.panel.btnActive);--道具不足
				UIQuickBuyConfirm:Open(self,toint(cost[1]))
				return
			end
			
			local bindState = self.selectEquip:GetBindState()
			if bindState == BagConsts.Bind_UseBind or bindState == BagConsts.Bind_None or
				bindState == BagConsts.Bind_UseUnBind then
				local okfun = function()
					EquipController:ReqWashActive(self.selectEquip:GetId())
				end
				UIConfirm:Open(StrConfig["smithing104"], okfun)
			else
				EquipController:ReqWashActive(self.selectEquip:GetId())
			end
		end
	end

	if cost then
		objSwf.panel._visible = true
		objSwf.panel.tfLvl.text = lvConfig.maxLv
		objSwf.panel.tfSucess.text = math.ceil(success/100) .. "%"
		local count = BagModel:GetItemNumInBag(toint(cost[1]))
		local color = count < toint(cost[2]) and "#FF0000" or "#00FF00";
		local color1 = TipsConsts:GetItemQualityColor(t_item[toint(cost[1])].quality)
		objSwf.panel.costLabel.htmlLabel = string.format(StrConfig["smithing030"], color1, t_item[toint(cost[1])].name, color, cost[2], count)
		objSwf.panel.costLabel.rollOver = function(e) TipsManager:ShowItemTips(toint(cost[1])) end
		objSwf.panel.costLabel.rollOut = function(e) TipsManager:Hide() end
	else
		objSwf.panel._visible = false
	end

end

function UISmithingWash:OnGetBtnClick()
	UIQuickBuyConfirm:Open(self,150100011)
end

function UISmithingWash:ClearSelectInfo()
	local objSwf = self.objSwf
	if not objSwf then return end
	for i = 1, 5 do
		objSwf["washlabel"..i]._visible = false
	end
	objSwf.fightcur._visible = false
	objSwf.panel._visible = false
	objSwf.nochoose._visible = true
	objSwf.txt_name.htmlText = ""
	objSwf.max._visible = false
	objSwf.icon_NoWash._visible = false
end

function UISmithingWash:PlayWashPfx(id, uid)
	local objSwf = self.objSwf
	if not objSwf then return end
	if not self.selectEquip then return end
	local index = 0
	for k, v in pairs(EquipModel:getWashInfo(id)) do
		if v.uid == uid then
			objSwf["washlabel" ..k].washPfx:gotoAndPlay(2)
			break
		end
	end
end

function UISmithingWash:PlayLvPfx(id, uid)
	local objSwf = self.objSwf
	if not objSwf then return end
	if not self.selectEquip then return end
	local index = 0
	if not id then
		index = #EquipModel:getWashInfo(self.selectEquip:GetId())
	else
		for k, v in pairs(EquipModel:getWashInfo(id)) do
			if v.uid == uid then
				index = k
				break
			end
		end
	end
	if index ~= 0 then
		objSwf["washlabel" ..index].pfx.pfx:gotoAndPlay(2)
		objSwf["washlabel" ..index].pfx.pfx1:gotoAndPlay(2)
	end
end

function UISmithingWash:ShowWashLink()
	local objSwf = self.objSwf
	if not objSwf then return end

	local bOpen = false
	local linkId = EquipModel:GetWashLinkID()
	if self.currLinkId and self.currLinkId < linkId then
		bOpen = true
	end
	self.currLinkId = linkId; 
	for i = 1, 6 do
		local ui = objSwf['linkBtn' ..i]
		if self.currLinkId + 1 < i then
			ui.visible = false
			objSwf['linkPfx' ..i]._visible = false
		else
			ui.visible = true
			if linkId == i then
				ui.disabled = false
				objSwf['linkPfx' ..i]._visible = true
				if bOpen then
					objSwf['linkPfx' ..i].lightPfx:play()
				end
			elseif linkId >= i then
				ui.disabled = false
				objSwf['linkPfx' ..i]._visible = true
			else
				ui.disabled = true
				objSwf['linkPfx' ..i]._visible = false
			end
			ui.alwaysRollEvent = true
			ui.rollOut = function() TipsManager:Hide(); end
			ui.rollOver = function() self:OnWashLinkRollOver(i, linkId >= i); end
		end
	end
end

function UISmithingWash:OnWashLinkRollOver(index, activate)
	local linkCfg = t_extrachain[index];
	if not linkCfg then return; end
	local tipsVO = {};
	tipsVO.linkId = index;
	tipsVO.activeNum = EquipModel:GetWashAllLv()
	TipsManager:ShowTips(TipsConsts.Type_WashLink,tipsVO,TipsConsts.ShowType_Normal,TipsConsts.Dir_RightDown);
end

function UISmithingWash:OnHide()
	self.selectEquip = nil
	SmithingModel:ClearScene(self)
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey)
		self.timerKey = nil;
	end
	self.auto = false
end

function UISmithingWash:HandleNotification(name,body)
	if name == NotifyConsts.PlayerModelChange then
		SmithingModel:DrawRole(self)
		return
	end
	self:ShowBodyEquips();
	-- self:ShowBagEquips();
	self:ShowSelectedEquip();
	self:ShowWashLink()
	if name == NotifyConsts.WashActive then
		SoundManager:PlaySfx(2005)
		self:PlayLvPfx()
	elseif name == NotifyConsts.WashUpdate then
		SoundManager:PlaySfx(2005)
		self:PlayLvPfx(body[1], body[2])
	elseif name == NotifyConsts.WashChange then
		SoundManager:PlaySfx(2005)
		self:PlayWashPfx(body[1], body[2])
	end
end

function UISmithingWash:ListNotificationInterests()
	return {
		NotifyConsts.WashUpdate,
		NotifyConsts.WashActive,
		NotifyConsts.WashChange,
		NotifyConsts.BagAdd,
		NotifyConsts.BagRemove,
		NotifyConsts.BagUpdate,
		NotifyConsts.PlayerModelChange,
	}
end