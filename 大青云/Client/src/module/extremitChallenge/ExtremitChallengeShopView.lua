--[[
	2015年6月30日, AM 11:06:07
	wangyanwei
	积分商店
]]

_G.UIExtremitChallengeShop = BaseUI:new('UIExtremitChallengeShop');

function UIExtremitChallengeShop:Create()
	self:AddSWF('extremitChallengeJFShop.swf',true,'center');
end

function UIExtremitChallengeShop:OnLoaded(objSwf)
	objSwf.list.itemRollOver = function (e) TipsManager:ShowItemTips(e.item.itemId); end
	objSwf.list.itemRollOut = function (e) TipsManager:Hide(); end
	objSwf.list.handlerShopClick = function (e) self:OnBuyClick(e) end
	objSwf.btn_close.click = function () self:Hide(); end
end

function UIExtremitChallengeShop:OnShow()
	self:ShowShopItem();
	self:OnShowTxt();
end

function UIExtremitChallengeShop:OnHide()
	
end

--下方文本
function UIExtremitChallengeShop:OnShowTxt()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local myselfJifen = MainPlayerModel.humanDetailInfo.eaExtremityVal;
	objSwf.txt_myJifen.htmlText = string.format( StrConfig['shop604'] , myselfJifen or 0 );
	objSwf.txt_daliyJifen.htmlText = StrConfig['shop605'] ;--string.format( StrConfig['shop605'] , (t_consts[66].val1 or 0) - self.limitJifen  );
end

--点击购买
function UIExtremitChallengeShop:OnBuyClick(e)
	local num = ShopModel:GetDayLimitItemHasBuyNum(e.item.id)
	local cfg = t_shop[e.item.id];
	if cfg.dayLimit - num < 1 and t_shop[e.item.id].dayLimit ~= 0 then
		FloatManager:AddNormal( StrConfig['shop612']);
		return 
	end
	local myselfExtremityVal = MainPlayerModel.humanDetailInfo.eaExtremityVal;
	if myselfExtremityVal < 1 then 
		FloatManager:AddNormal( StrConfig['shop610']);
		return 
	end 
	if myselfExtremityVal < t_shop[e.item.id].price then
		FloatManager:AddNormal( StrConfig['shop610']);
		return 
	end
	ShopController:ReqBuyItem(e.item.id, 1);
end

function UIExtremitChallengeShop:ShowShopItem()
	local objSwf = self.objSwf; 
	if not objSwf then return end
	local shopCfg = {};
	for i , v in pairs(t_shop) do
		if v.type == ShopConsts.ST_JiFen then
			table.push(shopCfg,v);
		end
	end
	table.sort(shopCfg,function(A,B)
		return A.showIndex < B.showIndex
	end)
	objSwf.list.dataProvider:cleanUp();
	for i , v in ipairs(shopCfg) do
		local voCfg = self:GetShowItemData(v);
		objSwf.list.dataProvider:push(voCfg);
	end
	objSwf.list:invalidateData();
end

UIExtremitChallengeShop.limitJifen = 0;
function UIExtremitChallengeShop:GetShowItemData(itemCfg)
	local vo ={};
	vo.id = itemCfg.id;
	
	local cfg = t_item[itemCfg.itemId] or t_equip[itemCfg.itemId];
	local quality = cfg and cfg.quality;
	vo.itemName = string.format(StrConfig["shop504"],TipsConsts:GetItemQualityColor(quality),ShopUtils:GetItemNameById(itemCfg.itemId));    -- 名字
	vo.price = string.format(StrConfig["shop601"],itemCfg.price); -- 消耗积分
	vo.itemId = itemCfg.itemId;
	local num = ShopModel:GetDayLimitItemHasBuyNum(itemCfg.id)
	
	if itemCfg.dayLimit - num == 0 then
		vo.dayLimit = string.format(StrConfig["shop549"],"#ff0000",itemCfg.dayLimit-num,itemCfg.dayLimit); -- 数量
	else
		vo.dayLimit = string.format(StrConfig["shop549"],"#00ff00",itemCfg.dayLimit-num,itemCfg.dayLimit); -- 数量
	end
	if itemCfg.dayLimit == 0 then 
		vo.dayLimit = StrConfig["shop508"];
	end;
	
	self.limitJifen = self.limitJifen + num * itemCfg.price;
	
	local rewardSlotVO = RewardSlotVO:new();
	rewardSlotVO.id = itemCfg.itemId;
	rewardSlotVO.count = 0;
	rewardSlotVO.bind = itemCfg.bind;
	return UIData.encode(vo) .. '*' .. rewardSlotVO:GetUIData();
end

function UIExtremitChallengeShop:ListNotificationInterests()
	return {
		NotifyConsts.PlayerAttrChange
		}
end;
function UIExtremitChallengeShop:HandleNotification(name,body)
	if name == NotifyConsts.PlayerAttrChange then
		if body.type == enAttrType.eaExtremityVal then 
			self:ShowShopItem();
			self:OnShowTxt();
		end;
	end;
end;