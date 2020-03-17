_G.SmithingStarItemView = BaseUI:new("SmithingStarItemView");

function SmithingStarItemView:Create()
	self:AddSWF("smithingStarItemPanel.swf",true,"center");
end

function SmithingStarItemView:OnLoaded(objSwf)
	objSwf.closeBtn.click = function(e) self:Hide() end
	objSwf.btnLevel.click = function() self:AskStarUp() end
	objSwf.roleEquipList.itemClick = function(e) self:OnBodyEquipClick(e); end
	objSwf.roleEquipList.itemRollOver = function(e) self:OnBodyEquipOver(e); end
	objSwf.roleEquipList.itemRollOut = function(e) TipsManager:Hide(); end

	objSwf.selecetItem.iconEquip.rollOver = function() self:OnSelectOver(); end
	objSwf.selecetItem.iconEquip.rollOut = function() TipsManager:Hide(); end
	objSwf.selectMax.rollOver = function() self:OnSelectMaxOver() end
	objSwf.selectMax.rollOut = function() TipsManager:Hide() end
end

function SmithingStarItemView:OnSelectOver()
	if not self.currSelect then
		return;
	end
	TipsManager:ShowBagTips(self.currSelect:GetBagType(), self.currSelect.pos);
end

function SmithingStarItemView:OnSelectMaxOver()
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

function SmithingStarItemView:OnShow()
	if self.starType == 1 then
		self.objSwf.txt_desc.htmlText = StrConfig.smithingStar3
	else
		self.objSwf.txt_desc.htmlText = StrConfig.smithingStar4
	end
	self:ShowBodyEquips();
	self:RefreshSelect();
end

function SmithingStarItemView:AskStarUp()
	if not self.currSelect then
		if self.starType == 1 then
			FloatManager:AddNormal("请选择一件12星以下可以升星的装备!")
		else
			FloatManager:AddNormal("请选择一件12星以上24星以下可以升星的装备!")
		end
		return
	end
	local msg = ReqUseShengXingItemMsg:new();
	msg.equipid = self.currSelect:GetId()
	MsgManager:Send(msg);
end

function SmithingStarItemView:ShowBodyEquips()
	local list = BagUtil:GetBagItemList( BagConsts.BagType_Role, BagConsts.ShowType_All)
	self.objSwf.roleEquipList.dataProvider:cleanUp();
	for i,slotVO in ipairs(list) do
		local data = slotVO:GetData()
		data.CanOperate = false
		if slotVO.hasItem then
			local bag = BagModel:GetBag(BagConsts.BagType_Role);
			local item = bag:GetItemByPos(slotVO.pos)
			if item then
				if EquipUtil:IsCanStarUpByItem(item, self.starType) then
					data.CanOperate = true
				else
					data.iconUrl = ImgUtil:GetGrayImgUrl(data.iconUrl)
				end
			end
		end

		self.objSwf.roleEquipList.dataProvider:push(UIData.encode(data));
	end
	self.objSwf.roleEquipList:invalidateData()
end

function SmithingStarItemView:RefreshSelect()
	if self.currSelect then
		local bag = BagModel:GetBag(BagConsts.BagType_Role);
		local item = bag:GetItemByPos(self.currSelect.pos)
		if not item then
			self.currSelect = nil
		elseif not EquipUtil:IsCanStarUpByItem(item, self.starType) then
			self.objSwf["equip" .. (self.currSelect.pos + 1)].selected = false
			self.currSelect = nil
		end
	end
	if not self.currSelect then
		self.objSwf.selecetItem.iconEquip:setData(UIData.encode({}))
		self.objSwf.txtselectmax._visible = false
		self.objSwf.selectMax._visible = false
		return;
	end
	self.objSwf["equip" .. (self.currSelect.pos + 1)].selected = true
	self:ShowSelectMaxEquip()
	self.objSwf.selecetItem.iconEquip:setData(self:getSelectVo())
end

function SmithingStarItemView:ShowSelectMaxEquip()
	self.objSwf.selectMax:setData(self:getSelectVo(true))
	self.objSwf.selectMax._visible = true
	self.objSwf.txtselectmax._visible = true
end

function SmithingStarItemView:getSelectVo(bMax)
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

function SmithingStarItemView:OnBodyEquipClick(e)
	if not e.item then return end
	local bag = BagModel:GetBag(BagConsts.BagType_Role);
	local item = bag:GetItemByPos(e.item.pos);

	if item == self.currSelect then
		return
	end
	if not EquipUtil:IsCanStarUpByItem(item, self.starType) then
		FloatManager:AddNormal("该装备超出提升范围!")
	end
	self.currSelect = item
	self:RefreshSelect()
end

function SmithingStarItemView:OnBodyEquipOver(e)
	if not e.item then
		return;
	end
	
	local bag = BagModel:GetBag(BagConsts.BagType_Role);
	local item = bag:GetItemByPos(e.item.pos);
	if item then
		TipsManager:ShowBagTips(BagConsts.BagType_Role,item.pos);
	end
end

function SmithingStarItemView:GetPanelType()
	return 1;
end

function SmithingStarItemView:ListNotificationInterests()
	return {NotifyConsts.EquipStarResult,
			NotifyConsts.BagAdd,
			NotifyConsts.BagRemove,
			NotifyConsts.PlayerAttrChange,
			}
end

function SmithingStarItemView:HandleNotification(name,body)
	self:ShowBodyEquips()
	self:RefreshSelect()
end

function SmithingStarItemView:OpenView(itemid, starType)
	if not itemid then
		print("道具id没有")
	end
	self.itemid = itemid
	self.starType = starType
	self.currSelect = nil
	if not self:IsShow() then
		self:Show()
	else
		self:Onshow()
	end
end