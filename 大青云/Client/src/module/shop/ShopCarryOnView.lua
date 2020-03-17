--[[
随身商店view
haohu
2014年11月3日18:00:56

]]

_G.UIShopCarryOn = BaseUI:new("UIShopCarryOn");

UIShopCarryOn.showType = ShopConsts.T_Consumable --默认显示

local s_shopType = {ShopConsts.T_Consumable, ShopConsts.T_Honor, ShopConsts.T_Babel,ShopConsts.T_Guild, ShopConsts.T_Gongxun, ShopConsts.T_Back}
local s_Money = {[ShopConsts.T_Consumable]	 = 10, 
				 [ShopConsts.T_Honor]	 	 = 51, 
				 [ShopConsts.T_Babel]        = 92,
				 [ShopConsts.T_Guild]		 = 80, 
				 [ShopConsts.T_Gongxun] 	 = 62, 
				 [ShopConsts.T_Back]	 	 = nil}
local s_funcOpen = {
	[ShopConsts.T_Consumable] = function() return true end,
	[ShopConsts.T_Back] 	  = function() return true end,
	[ShopConsts.T_Honor]	  = function() return FuncManager:GetFuncIsOpen(FuncConsts.Arena) end,
	[ShopConsts.T_Babel]	  = function() return FuncManager:GetFuncIsOpen(FuncConsts.Babel) end,
	[ShopConsts.T_Guild]	  = function() return UnionUtils:CheckMyUnion() end,
	[ShopConsts.T_Gongxun]	  = function() return FuncManager:GetFuncIsOpen(FuncConsts.KuaFuPVP) end,
}

function UIShopCarryOn:Create()
	self:AddSWF("shopCarryOnV.swf", true, "center" );
end

function UIShopCarryOn:OnLoaded(objSwf)
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end
	objSwf.nsPageTurn.change = function() self:ShowPageList(); end
end


function UIShopCarryOn:SetBtnShow()
	local objSwf = self.objSwf
	if not objSwf then return end
	local index = 1
	for i = 1, 6 do
		local UI = objSwf["btn" ..i]
		if index == 7 then
			UI.visible = false
		else
			for i = index, 6 do
				index = i + 1
				if s_funcOpen[s_shopType[i]]() then
					UI.htmlLabel = StrConfig["shopname" ..i]
					UI.visible = true
					UI.click = function()
						self:ShowShopByType(s_shopType[i])
					end
					break
				end
			end
		end
	end
end

function UIShopCarryOn:ShowShopByType(type)
	local objSwf = self.objSwf
	if not objSwf then return end
	if self.showType == type then
		return
	end
	self.showType = type
	self:ShowPage()
	self:ShowShopInfo()
end

function UIShopCarryOn:OnBtnCloseClick()
	self:Hide();
end

function UIShopCarryOn:OnShow()
	self:SetBtnShow()
	self:ShowPage()
	self:ShowShopInfo()
end

--显示翻页
function UIShopCarryOn:ShowPage()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self.list = ShopModel.shopList[self.showType]
local maxValue = math.ceil(#self.list / ShopConsts.NumIn1Page )
	objSwf.nsPageTurn.maximum = maxValue ~= 0 and maxValue or 1
	objSwf.nsPageTurn.value = 1;
end

function UIShopCarryOn:ShowShopInfo()
	local objSwf = self.objSwf
	if not objSwf then return end
	local index = 0
	for k, v in pairs(s_shopType) do
		if s_funcOpen[v]() then
			index = index + 1
			if v == self.showType then
				objSwf['btn' .. index].selected = true
				break
			end
		elseif v == self.showType then
			return
		end
	end

	--- 这里显示具体的商店信息了
	self:ShowPageList()
end

function UIShopCarryOn:ShowPageList()
	local objSwf = self.objSwf
	if not objSwf then return end

	local pageNum = objSwf.nsPageTurn.value;
    

	for i = 1, 10 do
		local UI = objSwf["item" ..i]
		local info = self.list[(pageNum-1)*ShopConsts.NumIn1Page + i]
		
		if info then
			self:SetSlotInfo(UI, info)
		else
			self:ClearSlot(UI)
		end
	end
	self:ShowMyMoney()
end

function UIShopCarryOn:ShowMyMoney()
	local objSwf = self.objSwf
	if not objSwf then return end

	if self.showType == ShopConsts.T_Back then
		objSwf.txtInfo._visible = true
	else
		objSwf.txtInfo._visible = false
	end

	if self.showType == ShopConsts.T_Consumable or self.showType == ShopConsts.T_Back then
		objSwf.moneyName.htmlText = ""
		objSwf.moneyCount.htmlText = ""
		return
	end
	objSwf.moneyName.htmlText = "当前" .. t_item[s_Money[self.showType]].name ..":"
	objSwf.moneyCount.htmlText = ShopUtils:GetMoneyByType(s_Money[self.showType])
end

function UIShopCarryOn:SetSlotInfo(UI, info)

	if not UI or not info then return end

	UI.icon.visible = true
	UI.icon:setData(info:GetIconUIData())
	UI.icon.rollOut = function() TipsManager:Hide() end
	UI.btnBuy.visible = true
	if self.showType == ShopConsts.T_Back then
		UI.icon.rollOver = function() 
			local vo = ShopModel:GetBuyBackItem(info.cid);
			local itemTipsVO = vo:GetTipsVO();
			if not itemTipsVO then return; end
			TipsManager:ShowTips( itemTipsVO.tipsType, itemTipsVO, itemTipsVO.tipsShowType, TipsConsts.Dir_RightDown );
		end
		UI.btnBuy.htmlLabel = "回购"
		UI.btnBuy.disabled = false
		local cfg = info:GetCfg()
		UI.txtName.htmlText = string.format(StrConfig["shop504"],TipsConsts:GetItemQualityColor(cfg.quality),ShopUtils:GetItemNameById(cfg.id))
		UI.buynum.htmlText = ""
		if MainPlayerModel.humanDetailInfo.eaBindGold < info:GetPrice() then
			UI.txtMoney.htmlText = string.format(StrConfig.shop801, "银两:") .. string.format(StrConfig.shoppingmall001, "#ff0000", info:GetPrice())
		else
			UI.txtMoney.htmlText = string.format(StrConfig.shop801, "银两:" .. info:GetPrice())
		end
		UI.btnBuy.click = function() self:BuyBackClick(info.cid) end
		UI.btn.click = function() self:BuyBackClick(info.cid) end
		return
	else
		UI.icon.rollOver = function() TipsManager:ShowItemTips(info:GetCfg().itemId) end
		UI.btnBuy.htmlLabel = "购买"
	end

	local cfg = info:GetCfg();
	
	local cfgitem = t_item[cfg.itemId] or t_equip[cfg.itemId];
	if not cfgitem then
		print("道具丢失", cfg.itemId)
		return
	end
	
	UI.txtName.htmlText = string.format(StrConfig["shop504"],TipsConsts:GetItemQualityColor(cfgitem.quality),ShopUtils:GetItemNameById(cfg.itemId))
	if ShopUtils:GetMoneyByType(cfg.moneyType) < cfg.price then
		UI.txtMoney.htmlText = string.format(StrConfig.shop801, t_item[cfg.moneyType].name .. ":") .. string.format(StrConfig.shoppingmall001, "#ff0000", cfg.price)
	else
		UI.txtMoney.htmlText = string.format(StrConfig.shop801, t_item[cfg.moneyType].name .. ":" .. cfg.price)
	end
	if self.showType == ShopConsts.T_Guild and cfg.needLvl > UnionModel.MyUnionInfo.level then
		UI.buynum.htmlText = string.format(StrConfig.shoppingmall001, "#ff0000", "帮派达到" .. cfg.needLvl .. "级")
		UI.btnBuy.disabled = true
		UI.btn.click = function() end
	elseif cfg.dayLimit == 0 then
		UI.buynum.htmlText = ""
		UI.btnBuy.disabled = false
		UI.btn.click = function() self:OnItemClick(info) end
		UI.btnBuy.click = function() self:OnItemClick(info) end
	else
		local num = ShopModel:GetDayLimitItemHasBuyNum(info:GetTid())
		if num >= cfg.dayLimit then
			UI.buynum.htmlText = string.format(StrConfig.shop801, "每日限购:") .. string.format(StrConfig.shoppingmall001, "#ff0000", 0 .. "/" ..cfg.dayLimit)
			UI.btnBuy.disabled = true
			UI.btn.click = function() end
		else
			UI.buynum.htmlText = string.format(StrConfig.shop801, "每日限购:") .. string.format(StrConfig.shoppingmall001, "#00ff00", (cfg.dayLimit - num) .. "/" ..cfg.dayLimit)
			UI.btnBuy.disabled = false
			UI.btnBuy.click = function() self:OnItemClick(info) end
			UI.btn.click = function() self:OnItemClick(info) end
		end
	end
end

function UIShopCarryOn:OnItemClick(shopVO)
	if shopVO:GetNeedLevel() > MainPlayerModel.humanDetailInfo.eaLevel then
		FloatManager:AddNormal("玩家等级达到" ..shopVO:GetNeedLevel() .. "级才能购买")
		return
	end
	local cfg = shopVO:GetCfg();
	if not cfg then return; end
	if cfg.needConfirm then
		local canBuy, maxBuyNum, bottleneck, moneyType = ShopUtils:CheckCanBuy(shopVO:GetTid(), 1);
		if not canBuy then
			if bottleneck == ShopConsts.ReasonAfford and StrConfig['shopnotice' .. moneyType] then
				FloatManager:AddNormal(StrConfig['shopnotice' ..moneyType])
			else
				FloatManager:AddNormal( string.format( ShopConsts.MaxBuyMap[bottleneck], maxBuyNum ) );
			end
			return
		end
		UIShopBuyConfirm:Open(shopVO:GetTid());
	else
		self:Buy1Group(shopVO:GetTid());
	end
end

--购买一组( 商品id对应t_shop, itemId对应t_item )
function UIShopCarryOn:Buy1Group(id)
	local cfg = t_shop[id];
	if not cfg then return; end
	local itemCfg = t_item[cfg.itemId] or t_equip[cfg.itemId];
	if not itemCfg then return; end
	local repeats = itemCfg and itemCfg.repeats or 1; --最大叠加数(一组)
	local canBuy, maxBuyNum, bottleneck, moneyType = ShopUtils:CheckCanBuy(id, repeats);
	if canBuy then
		ShopController:ReqBuyItem(id, repeats);
	else
		if bottleneck == ShopConsts.ReasonAfford and StrConfig['shopnotice' .. moneyType] then
			FloatManager:AddNormal(StrConfig['shopnotice' ..moneyType])
		else
			FloatManager:AddNormal( string.format( ShopConsts.MaxBuyMap[bottleneck], maxBuyNum ) );
		end
	end
end

function UIShopCarryOn:ClearSlot(UI)
	if not UI then return end
	UI.btn.click = function() end
	UI.btnBuy.visible = false
	UI.icon.visible = false
	UI.txtName.text = ""
	UI.txtMoney.text = ""
	UI.buynum.text = ""
end

function UIShopCarryOn:BuyBackClick(cid)
	local vo = ShopModel:GetBuyBackItem(cid);
	if not vo then return; end
	if ShopUtils:GetMoneyByType(enAttrType.eaBindGold) < vo:GetPrice() then
		FloatManager:AddNormal( StrConfig['shop302'] );
		return;
	end
	local itemCfg = vo:GetCfg();
	if not itemCfg then return; end
	local itemId = vo:GetTid()
	local maxPile = itemCfg.repeats or 1; --最大堆叠
	local bagVO = BagModel:GetBag( BagConsts.BagType_Bag );
	local bagSizeRest = bagVO:GetSize() - bagVO:GetUseSize(); --背包剩余格子数量
	local itemBagSize = bagVO:GetItemUsedSize( itemId );
	local numItem = BagModel:GetItemNumInBag( itemId );
	local numCanPile = itemBagSize * maxPile - numItem;
	local maxNum = maxPile * bagSizeRest + numCanPile;
	if vo.count > maxNum then
		FloatManager:AddNormal( StrConfig['shop301'] );
		return;
	end
	ShopController:ReqBuyBack(cid);
end

function UIShopCarryOn:OpenShopByType(type)
	if not s_funcOpen[type] or not s_funcOpen[type]() then
		return
	end
	if self:IsShow() then
		if self.showType == type then
			self:Hide()
			return
		end
		self.showType = type
		self:ShowPage()
		self:ShowShopInfo()
	else
		self.showType = type
		self:Show()
	end
end


function UIShopCarryOn:OnDelete()
	
end

function UIShopCarryOn:IsTween()
	return true;
end

function UIShopCarryOn:GetPanelType()
	return 0;
end

function UIShopCarryOn:ESCHide()
	return true;
end

function UIShopCarryOn:IsShowLoading()
	return true;
end

function UIShopCarryOn:IsShowSound()
	return true;
end

function UIShopCarryOn:OnHide()
	self.showType = ShopConsts.T_Consumable
end

function UIShopCarryOn:BeforeTween()
	local func = FuncManager:GetFunc(FuncConsts.Bag);
	if not func then return; end
	self.tweenStartPos = func:GetBtnGlobalPos();
end

function UIShopCarryOn:ShopResult()
	self:ShowPageList()
end

function UIShopCarryOn:ListNotificationInterests()
	return { NotifyConsts.BuyBackListRefresh, NotifyConsts.PlayerAttrChange, NotifyConsts.MyUnionInfoUpdate };
end

function UIShopCarryOn:HandleNotification(name, body)
	if name == NotifyConsts.BuyBackListRefresh then
		if self.showType == ShopConsts.T_Back then
			self:ShowPageList()
		end
	elseif name == NotifyConsts.PlayerAttrChange then
		if body.type == enAttrType.eaHonor and self.showType == ShopConsts.T_Honor then
			self:ShowPageList()
		elseif body.type == enAttrType.eaCrossExploit and self.showType == ShopConsts.T_Gongxun then
			self:ShowPageList()
	    elseif body.type == enAttrType.eaTrialScore then 
	        self:ShowPageList()
		end
	elseif name == NotifyConsts.MyUnionInfoUpdate then
		if self.showType == ShopConsts.T_Guild then
			if not UnionUtils:CheckMyUnion() then
				self:Hide()
				return
			end
			self:ShowPageList()
		end
		self:SetBtnShow()
	end
end
