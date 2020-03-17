--[[
随身商店 消耗品面板
lizhuangzhuang
2014年12月6日16:28:23
]]

_G.UIShopCarryOnConsume = BaseUI:new("UIShopCarryOnConsume");

UIShopCarryOnConsume.list = nil;--商品列表

function UIShopCarryOnConsume:Create()
	self:AddSWF( "shopCarryOnConsume.swf", true, nil );
end

function UIShopCarryOnConsume:OnLoaded(objSwf)
	objSwf.list.itemClick     = function(e) self:OnItemClick(e); end
	objSwf.list.itemRClick    = function(e) self:OnItemRClick(e); end
	objSwf.list.iconRollOver  = function(e) self:OnIconRollOver(e); end
	objSwf.list.iconRollOut   = function() self:OnIconRollOut(); end
	objSwf.list.moneyRollOver = function(e) self:OnMoneyRollOver(e); end
	objSwf.list.moneyRollOut  = function() self:OnMoneyRollOut(); end
	objSwf.chkBox.select = function(e) self:OnChkBoxSelect(e); end
	objSwf.txtInfo.text = StrConfig['shop401'];
	objSwf.nsPageTurn.change = function() self:ShowPageList(); end
end

function UIShopCarryOnConsume:OnShow()
	self:ShowPage();
	self:ShowPageList();
end

--获取数据
function UIShopCarryOnConsume:GetDataList()
	local list = {};
	local objSwf = self.objSwf;
	if not objSwf then return list; end
	local levelFilter = objSwf.chkBox.selected;
	for i,shopVO in ipairs(ShopModel.consumableList) do
		if levelFilter then
			if shopVO:GetNeedLevel() <= MainPlayerModel.humanDetailInfo.eaLevel then
				table.push(list,shopVO);
			end
		else
			table.push(list,shopVO);
		end
	end
	return list;
end

--显示翻页
function UIShopCarryOnConsume:ShowPage()
	self.list = self:GetDataList();
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.nsPageTurn.maximum = math.ceil(#self.list / ShopConsts.NumIn1Page );
	objSwf.nsPageTurn.value = 1;
end

--显示列表
function UIShopCarryOnConsume:ShowPageList()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local pageNum = objSwf.nsPageTurn.value;
	local startIndex = (pageNum-1)*ShopConsts.NumIn1Page + 1;
	local endIndex = pageNum * ShopConsts.NumIn1Page;
	objSwf.list.dataProvider:cleanUp();
	for i=startIndex,endIndex do
		local shopVO = self.list[i];
		if shopVO then
			objSwf.list.dataProvider:push(shopVO:GetUIData());
		else
			objSwf.list.dataProvider:push("");
		end
	end
	objSwf.list:invalidateData();
end

function UIShopCarryOnConsume:OnItemClick(e)
	local id = e.item.id;
	local cfg = t_shop[id];
	if not cfg then return; end
	if cfg.needConfirm then
		UIShopBuyConfirm:Open(id);
	else
		self:Buy1Group(id);
	end
end

--购买一组( 商品id对应t_shop, itemId对应t_item )
function UIShopCarryOnConsume:Buy1Group(id)
	local cfg = t_shop[id];
	if not cfg then return; end
	local itemCfg = t_item[cfg.itemId] or t_equip[cfg.itemId];
	if not itemCfg then return; end
	local repeats = itemCfg and itemCfg.repeats or 1; --最大叠加数(一组)
	local canBuy, maxBuyNum, bottleneck = ShopUtils:CheckCanBuy(id, repeats);
	if canBuy then
		ShopController:ReqBuyItem(id, repeats);
	else
		FloatManager:AddNormal( string.format( ShopConsts.MaxBuyMap[bottleneck], maxBuyNum ) );
	end
end

local rclickCD = 500; -- 500毫秒点击间隔, 绕过scaleForm Button rclick的bug （连续右击2次触发3次）
local rclickTimer; -- 定时器
function UIShopCarryOnConsume:OnItemRClick(e)
	local id = e.item and e.item.id;
	if not id then return end
	if rclickTimer then return end
	rclickTimer = TimerManager:RegisterTimer( function()
		rclickTimer = nil
	end, rclickCD, 1 )
	self:Buy1Group(id);
end

function UIShopCarryOnConsume:OnIconRollOver(e)
	local target = e.renderer;
	local id = e.item.id;
	local cfg = t_shop[id];
	if not cfg then return; end
	local shopVO = ShopVO:new();
	shopVO.id = id;
    TipsManager:ShowItemTips(cfg.itemId,1,TipsConsts.Dir_RightDown,shopVO:GetBind());
end

function UIShopCarryOnConsume:OnIconRollOut()
	TipsManager:Hide();
end

function UIShopCarryOnConsume:OnMoneyRollOver(e)
	local target = e.renderer;
	local cfg = t_shop[e.item.id];
	if not cfg then return; end
    TipsManager:ShowBtnTips( ShopUtils:GetMoneyNameByType(cfg.moneyType));
end

function UIShopCarryOnConsume:OnMoneyRollOut()
	TipsManager:Hide();
end

function UIShopCarryOnConsume:OnChkBoxSelect(e)
	self:ShowPage();
end