_G.UISmithingResp = BaseUI:new("UISmithingResp");

function UISmithingResp:Create()
	self:AddSWF("smithingRespPanel.swf",true,nil);
end

function UISmithingResp:OnLoaded(objSwf)
	objSwf.roleEquipList.itemClick = function(e) self:OnBodyEquipClick(e); end
	objSwf.roleEquipList.itemRollOver = function(e) self:OnBodyEquipOver(e); end
	objSwf.roleEquipList.itemRollOut = function(e) TipsManager:Hide(); end	
	objSwf.bagList.itemClick = function(e) self:OnBagEquipClick(e); end
	objSwf.bagList.itemRollOver = function(e) self:OnBagEquipOver(e); end
	objSwf.bagList.itemRollOut = function(e) TipsManager:Hide(); end

	objSwf.seleceitem.rollOver = function() if not self.selectEquip then return end TipsManager:ShowBagTips(self.selectEquip:GetBagType(), self.selectEquip.pos) end
	objSwf.seleceitem.rollOut = function(e) TipsManager:Hide(); end
	objSwf.seleceitem.click = function() self:OnSelecedEquipClick() end

	objSwf.acceptitem.rollOver = function() if not self.acceptEquip then return end TipsManager:ShowBagTips(self.acceptEquip:GetBagType(), self.acceptEquip.pos) end
	objSwf.acceptitem.rollOut = function(e) TipsManager:Hide(); end
	objSwf.acceptitem.click = function() self:OnAcceptEquipClick() end

	objSwf.outitem.rollOver = function() self:ShowRespTips() end
	objSwf.outitem.rollOut = function(e) TipsManager:Hide(); end

	objSwf.rult.rollOver =  function() TipsManager:ShowBtnTips(StrConfig["smithingRule4"],TipsConsts.Dir_RightDown); end
	objSwf.rult.rollOut = function(e) TipsManager:Hide(); end

	objSwf.chooseStar.click = function() self:ShowOutEquip() end
	objSwf.chooseWash.click = function() self:ShowOutEquip() end

	RewardManager:RegisterListTips(objSwf.costList);
end

function UISmithingResp:OnShow()
	if self.args and self.args[2] then
		local bagVO = BagModel:GetBag(BagConsts.BagType_Bag);
		local item = bagVO:GetItemById(self.args[2])
		if item and EquipUtil:EquipCanResp(item) then
			self.selectEquip = item
			local bagVO = BagModel:GetBag(BagConsts.BagType_Role);
			local item = bagVO:GetItemById(self.args[1])
			if item and EquipUtil:IsCanAcceptResp(self.selectEquip, item) then
				self.acceptEquip = item
			end
		end
	end
	self:ShowBodyEquips()
	self:ShowBagEquips()
	self:ShowSelecteEquip(true)
end

local function RefreshEquipList(equips,list)
	if not list or not equips then
		return;
	end
	local equipList = {}

	for index,item in pairs(equips) do
		if EquipUtil:EquipCanResp(item) then
			local gray
			if UISmithingResp.selectEquip then
				if item ~= UISmithingResp.selectEquip then
					if UISmithingResp.acceptEquip then
						if item ~= UISmithingResp.acceptEquip then
							gray = true
						end
					else
						if not EquipUtil:IsCanAcceptResp(UISmithingResp.selectEquip, item) then
							gray = true
						end
					end
				end
			else
				if not EquipUtil:IsCanResp(item) then
					gray = true
				end
			end
			table.push(equipList,UIData.encode(UISmithingResp:GetSlotVO(item,nil,index,gray)));
		end
	end
	list.dataProvider:cleanUp();
	list.dataProvider:push(unpack(equipList));
	list:invalidateData();
end

function UISmithingResp:ShowBodyEquips()
	local list = {}
	local bag = BagModel:GetBag(BagConsts.BagType_Role);
	local equips = bag:GetItemListByShowType(BagConsts.ShowType_Equip);
	RefreshEquipList(equips,self.objSwf.roleEquipList);
end

function UISmithingResp:ShowBagEquips()
	local bag = BagModel:GetBag(BagConsts.BagType_Bag);
	local equips = bag:GetItemListByShowType(BagConsts.ShowType_Equip);
	RefreshEquipList(equips,self.objSwf.bagList);
end

--获取格子VO
function UISmithingResp:GetSlotVO(item,isBig,index,gray)
	local vo = {};
	vo.hasItem = true;
	vo.myindex = index;
	vo.pos = item:GetPos();
	vo.isBig = isBig and true or false;
	EquipUtil:GetDataToEquipUIVO(vo,item,isBig,gray);
	return vo;
end

function UISmithingResp:OnBodyEquipClick(e)
	if not e.item then return end

	local bag = BagModel:GetBag(BagConsts.BagType_Role);
	local item = bag:GetItemByPos(e.item.pos);
	if not item then return end
	self:OnEquipClick(item)
end

function UISmithingResp:OnBagEquipClick(e)
	if not e.item then return end

	local bag = BagModel:GetBag(BagConsts.BagType_Bag);
	local item = bag:GetItemByPos(e.item.pos);
	if not item then
		return
	end
	self:OnEquipClick(item)
end

function UISmithingResp:OnEquipClick(item)
	if not self.selectEquip then
		-- 判断装备是否可以传承星级或者有洗练属性
		if not EquipUtil:IsCanResp(item) then
			NoOperationView:Show(StrConfig['equipResp1'], StrConfig['equipResp11'])
			-- FloatManager:AddNormal(StrConfig['equipResp1'])
			return
		end
		self.selectEquip = item
		self:ShowSelecteEquip()
		self:ShowBodyEquips()
		self:ShowBagEquips()
	elseif not self.acceptEquip then
		if self.selectEquip == item then
			FloatManager:AddNormal(StrConfig['equipResp2'])
			return
		end
		-- if not EquipUtil:IsEqualPart(self.selectEquip, item) then
			-- FloatManager:AddNormal(StrConfig['equipResp3'])
			-- NoOperationView:Show(StrConfig['equipResp3'], StrConfig['equipResp11'])
			-- return
		-- end
		local bResult, nFlag = EquipUtil:IsCanAcceptResp(self.selectEquip, item)
		if not bResult then
			if nFlag and nFlag == -1 then
				NoOperationView:Show(StrConfig['equipResp10'], StrConfig['equipResp11'])
				return
			end
			FloatManager:AddNormal(StrConfig['equipResp4'])
			return
		end
		self.acceptEquip = item
		self:ShowSelecteEquip(true)
		self:ShowBodyEquips()
		self:ShowBagEquips()
	else
		FloatManager:AddNormal(StrConfig['equipResp5'])
		return
	end
end

function UISmithingResp:OnSelecedEquipClick()
	if not self.selectEquip then
		return
	end
	if self.acceptEquip then
		FloatManager:AddNormal(StrConfig['equipResp6'])
		return
	end
	self.selectEquip = nil
	self:ShowSelecteEquip()
	self:ShowBodyEquips()
	self:ShowBagEquips()
end

function UISmithingResp:OnAcceptEquipClick()
	if not self.acceptEquip then
		return
	end
	self.acceptEquip = nil
	self:ShowSelecteEquip()
	self:ShowBodyEquips()
	self:ShowBagEquips()
end

function UISmithingResp:OnBodyEquipOver(e)
	if not e.item then return end
	
	local bag = BagModel:GetBag(BagConsts.BagType_Role);
	local item = bag:GetItemByPos(e.item.pos);
	if item then
		TipsManager:ShowBagTips(BagConsts.BagType_Role,item.pos);
	end
end

function UISmithingResp:OnBagEquipOver(e)
	if not e.item then return end
	
	local bag = BagModel:GetBag(BagConsts.BagType_Bag);
	local item = bag:GetItemByPos(e.item.pos);
	if item then
		TipsManager:ShowBagTips(BagConsts.BagType_Bag,item.pos);
	end
end

function UISmithingResp:ShowRespTips()
	if not self.acceptEquip then
		return
	end
	local tipsVO = ItemTipsVO:new()
	ItemTipsUtil:CopyItemDataToTipsVO(self.acceptEquip,tipsVO)
	tipsVO.tipsType = TipsConsts.Type_Equip
	tipsVO.tipsShowType = TipsConsts.ShowType_Normal
	if self.objSwf.chooseStar.selected then
		local equip = EquipModel:GetEquipInfo(self.selectEquip:GetId())
		if equip then
			tipsVO.emptystarnum = equip.emptystarnum
			tipsVO.strenLvl = equip.strenLvl
		end
	end
	-- 这里应该处理下洗练的数据
	if self.objSwf.chooseWash.selected then
		tipsVO.washList = EquipModel:getWashInfo(self.selectEquip:GetId()) 
	end
	tipsVO.equiped = false
	tipsVO.isInBag = false
	TipsManager:ShowRespTips(tipsVO)
end

function UISmithingResp:getSelectVo(equip, equip1)
	local config = t_equip[equip:GetTid()]
	local data = {}
	data.id = config.id;
	data.count = equip:GetCount();
	data.showCount = "";
	data.iconUrl = ResUtil:GetItemIconUrl(config.icon);
	data.bigIconUrl = ResUtil:GetItemIconUrl(config.icon,54);
	data.iconUrl64 = ResUtil:GetItemIconUrl(config.icon,64);
	data.bind = equip1 and BagConsts.Bind_Bind or equip:GetBindState();
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
	data.strenLvl = equip1 and self.objSwf.chooseStar.selected and EquipModel:GetStrenLvl(equip1:GetId()) or EquipModel:GetStrenLvl(equip:GetId());
	data.biaoshiUrl = ResUtil:GetBiaoShiUrl(config.identifying)
	data.bigBiaoshiUrl = ResUtil:GetBiaoShiUrl(config.identifying, 54)
	data.biaoshiUrl64 = ResUtil:GetBiaoShiUrl(config.identifying, 64)
	return UIData.encode(data)
end

function UISmithingResp:ShowSelecteEquip(bFirst)
	local objSwf = self.objSwf
	if bFirst then
		-- 初次进来需要先处理下面的选中框
		self:ShowRespChooseInfo()
	end
	self:ClearShowInfo()
	if not self.selectEquip then
		return
	end
	objSwf.seleceitem:setData(self:getSelectVo(self.selectEquip))
	if not self.acceptEquip then
		return
	end
	objSwf.chooseStar.visible = true
	objSwf.chooseWash.visible = true
	objSwf.btnLvUp.visible = true
	objSwf.acceptitem:setData(self:getSelectVo(self.acceptEquip))
	self:ShowOutEquip()
end

function UISmithingResp:ShowOutEquip()
	if not self.acceptEquip or not self.selectEquip then return end
	self.objSwf.outitem:setData(self:getSelectVo(self.acceptEquip, self.selectEquip))
	--这里就把消耗直接处理了

	local nType = self.objSwf.chooseStar.selected and self.objSwf.chooseWash.selected and 3 
			or (self.objSwf.chooseStar.selected and 1) or (self.objSwf.chooseWash.selected and 2)
	if nType then
		local costCfg = t_inherit[1000 + self.acceptEquip:GetCfg().level * 10 + nType]

		local cost = split(costCfg.item, ",")
		if toint(cost[2]) > MainPlayerModel.humanDetailInfo.eaBindGold then
			self.objSwf.costLabel.htmlText = string.format(StrConfig['equipResp7'],cost[2])
		else
			self.objSwf.costLabel.htmlText = string.format(StrConfig['equipResp8'],cost[2])
		end

		self.objSwf.btnLvUp.click = function()
			local okfun = function()
				EquipController:ReqEquipResp(self.selectEquip:GetId(), self.acceptEquip:GetId(), nType)
			end
			local str = nType == 1 and "smithing109" or (nType == 2 and "smithing110") or (nType == 3 and "smithing107")
			UIConfirm:Open(StrConfig[str], okfun)
		end
	else
		self.objSwf.costLabel.htmlText = ""
		self.objSwf.btnLvUp.click = function()
			FloatManager:AddNormal(StrConfig['equipResp9'])
		end
	end
end

function UISmithingResp:ClearShowInfo()
	local objSwf = self.objSwf
	if not objSwf then return end

	objSwf.seleceitem:setData(UIData.encode({}))
	objSwf.acceptitem:setData(UIData.encode({}))
	objSwf.outitem:setData(UIData.encode({}))
	objSwf.costLabel.text = ""
	objSwf.chooseStar.visible = false
	objSwf.chooseWash.visible = false
	objSwf.btnLvUp.visible = false
end

function UISmithingResp:ShowRespChooseInfo()
	-- 这里因为只有玩家选中才会进来 简单处理
	local objSwf = self.objSwf
	if not objSwf then return end
	if not self.selectEquip or not self.acceptEquip then
		return
	end
	if EquipUtil:IsCanRespStar(self.selectEquip, self.acceptEquip) then
		objSwf.chooseStar.selected = true
		objSwf.chooseStar.disabled = false
	else
		objSwf.chooseStar.selected = false
		objSwf.chooseStar.disabled = true
	end

	if EquipUtil:IsCanRespWash(self.selectEquip, self.acceptEquip) then
		objSwf.chooseWash.selected = true
		objSwf.chooseWash.disabled = false
	else
		objSwf.chooseWash.selected = false
		objSwf.chooseWash.disabled = true
	end
end

function UISmithingResp:OnHide()
	self.selectEquip = nil
	self.acceptEquip = nil
end

function UISmithingResp:HandleNotification(name,body)
	if name == NotifyConsts.RespSuccess then
		SoundManager:PlaySfx(2017)
		local func = function()
			self.selectEquip = nil
			self.acceptEquip = nil
			self:ShowSelecteEquip()
		end
		-- 成功了都清除
		--播放特效 延迟刷新
		local objSwf = self.objSwf
		if not objSwf then
			return
		end
		-- objSwf.pfx1:gotoAndPlay(2)
		-- objSwf.pfx2:play()
		TimerManager:RegisterTimer(func, 200, 1)
	else
		self:ShowSelecteEquip()
	end
	self:ShowBodyEquips()
	self:ShowBagEquips()
end

function UISmithingResp:ListNotificationInterests()
	return {
		NotifyConsts.RespSuccess,
		NotifyConsts.BagAdd,
		NotifyConsts.BagRemove,
		NotifyConsts.BagUpdate,
		NotifyConsts.PlayerAttrChange,
	}
end