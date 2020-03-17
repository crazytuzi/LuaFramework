
_G.UIBeicangjieShop = BaseUI:new('UIBeicangjieShop');

function UIBeicangjieShop:Create()
	self:AddSWF("beicangjieShop.swf", true, "center");
end

function UIBeicangjieShop:OnLoaded(objSwf)
	objSwf.btn_close.click = function () self:Hide(); end
	objSwf.list.itemRollOver = function (e) TipsManager:ShowItemTips(e.item.itemId); end
	objSwf.list.itemRollOut = function (e) TipsManager:Hide(); end
	objSwf.list.handlerShopClick = function (e) self:OnBuyClick(e) end
end

function UIBeicangjieShop:OnShow()
	self:ShowShopItem();
	self:OnDownTxtChange();
end

function UIBeicangjieShop:OnHide()
	
end

--点击购买
function UIBeicangjieShop:OnBuyClick(e)
	local num = ShopModel:GetDayLimitItemHasBuyNum(e.item.id)
	local cfg = t_shop[e.item.id];
	if cfg.dayLimit - num < 1 then
		FloatManager:AddNormal( StrConfig['shop222']);
		return 
	end
	local myselfLingzhi = MainPlayerModel.humanDetailInfo.eaLingZhi;
	if myselfLingzhi < 1 then 
		FloatManager:AddNormal( StrConfig['shop220']);
		return 
	end
	if self.limitLingzhi - t_consts[66].val1 >= 0 then 
		FloatManager:AddNormal( StrConfig['shop221']); 
		return 
	end 
	ShopController:ReqBuyItem(e.item.id, 1);
end

--下方两个文本
function UIBeicangjieShop:OnDownTxtChange()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local myselfLingzhi = MainPlayerModel.humanDetailInfo.eaLingZhi;
	objSwf.txt_myLingZhi.htmlText = string.format( StrConfig['shop552'] , myselfLingzhi or 0 );
	objSwf.txt_daliyLingzhi.htmlText = string.format( StrConfig['shop553'] , (t_consts[66].val1 or 0) - self.limitLingzhi  );
end

function UIBeicangjieShop:ShowShopItem()
	local objSwf = self.objSwf;
	if not objSwf then return end
	self.limitLingzhi = 0;
	objSwf.list.dataProvider:cleanUp();
	local shopItem = {};
	for i , v in pairs(t_shop)do
		if v.type == ShopConsts.ST_Honor then
			table.insert(shopItem ,v);
		end
	end
	table.sort(shopItem,function(A,B)
		if A.id < B.id then
			return true;
		else
			return false;
		end
	end);
	for i , v in ipairs(shopItem) do
		local a = self:getUiData(v);
		objSwf.list.dataProvider:push(a);
	end
	objSwf.list:invalidateData();
end

UIBeicangjieShop.limitLingzhi = 0;
function UIBeicangjieShop:getUiData(itemCfg)
	local cfg = t_item[itemCfg.itemId];
	local vo ={};
	vo.id = itemCfg.id;
	vo.itemName = string.format(StrConfig["shop504"],TipsConsts:GetItemQualityColor(cfg.quality),ShopUtils:GetItemNameById(itemCfg.itemId));    -- 名字
	vo.price = string.format(StrConfig["shop550"],itemCfg.price); -- 消耗荣誉
	vo.itemId = itemCfg.itemId;
	
	vo.btnLabel = StrConfig['beicangjie500'];
	
	local num = ShopModel:GetDayLimitItemHasBuyNum(itemCfg.id)
	
	if itemCfg.dayLimit - num == 0 then
		vo.dayLimit = string.format(StrConfig["shop549"],"#960000",itemCfg.dayLimit-num,itemCfg.dayLimit); -- 数量
	else
		vo.dayLimit = string.format(StrConfig["shop549"],"#32961e",itemCfg.dayLimit-num,itemCfg.dayLimit); -- 数量
	end
	if itemCfg.dayLimit == 0 then 
		vo.dayLimit = StrConfig["shop508"];
	end;
	
	--今日消耗多少灵值
	self.limitLingzhi = self.limitLingzhi + num * itemCfg.price;
	
	local rewardSlotVO = RewardSlotVO:new();
	-- trace(rewardSlotVO)
	-- debug.debug();
	rewardSlotVO.id = itemCfg.itemId;
	rewardSlotVO.count = 0;
	rewardSlotVO.bind = itemCfg.bind ;
	return UIData.encode(vo) .. '*' .. rewardSlotVO:GetUIData();
end

function UIBeicangjieShop:ListNotificationInterests()
	return {
		NotifyConsts.PlayerAttrChange
		}
end;
function UIBeicangjieShop:HandleNotification(name,body)
	if name == NotifyConsts.PlayerAttrChange then
		if body.type == enAttrType.eaLingZhi then 
			self:ShowShopItem();
			self:OnDownTxtChange();
		end;
	end;
end;