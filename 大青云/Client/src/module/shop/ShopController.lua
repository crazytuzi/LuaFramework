--[[
商店 controller
郝户
2014年11月3日18:01:16
]]

_G.ShopController = setmetatable( {}, {__index = IController} );

_G.ShopController.name = "ShopController";

ShopController.isShowShopSound = true;
ShopController.timerKey = nil;

function ShopController:Create()
	MsgManager:RegisterCallBack( MsgType.SC_ShopHasBuyList, self, self.OnShopHasBuyListRsv );
	MsgManager:RegisterCallBack( MsgType.SC_BuyBack, self, self.OnBuyBackResultRsv );
	MsgManager:RegisterCallBack( MsgType.SC_ShopPingresult, self, self.ShopPingResult );
	MsgManager:RegisterCallBack( MsgType.SC_ExchangeShopResult, self, self.OnExchangeResult );
end

function ShopController:OnEnterGame()
	ShopModel:Init()
end

function ShopController:OnChangeSceneMap()
	if UIShopXmasExchange:IsShow() then 
		UIShopXmasExchange:Hide();
	end;
	if UIShopExchange:IsShow() then 
		UIShopExchange:Hide();
	end;
	if UIShopBuyConfirm:IsShow() then 
		UIShopBuyConfirm:Hide();
	end;
end;
----------------------------------- handle response msg --------------------------------

-- 收到有每日购买上限的物品的列表
function ShopController:OnShopHasBuyListRsv(msg)
	ShopModel:UpdateHasBuyList( msg.shopHasBuyList );
end

-- SC_SellItemResult
-- 出售成功后，将物品加到回购列表
function ShopController:OnItemSale(msg)
	if msg.result == 0 then -- 出售成功
		ShopModel:AddBuyBackItem( msg.id );
	else -- 出售失败
		ShopModel:RemoveSellCache( msg.id )
	end
end

-- 回购成功，将物品从回购列表删除
function ShopController:OnBuyBackResultRsv(msg)
	if msg.result ~= 0 then return;	end
	ShopModel:RemoveBuyBackItem(msg.cid);
end
-- 商品购买结果
function ShopController:ShopPingResult(msg)
	if msg.result == 0 then 
		-- 成功
		-- 飞图标处理
		local func = FuncManager:GetFunc(FuncConsts.Bag);
		if func then
			local cfg = t_shop[msg.id]
			func:ShowPickEffect(cfg.itemId);
		end
		UIShopCarryOn:ShopResult()
	else
		-- 失败
	end;
end;

function ShopController:OnExchangeResult( msg )
	if msg.result == 0 then 
		-- 成功
		-- 飞图标处理
		local func = FuncManager:GetFunc(FuncConsts.Bag);
		if func then
			local cfg = t_shop[msg.id]
			func:ShowPickEffect(cfg.itemId);
		end
	end
end
----------------------------------- request msg ----------------------------------------

-- 购买商品
-- @param id:商品id(t_shop id)
-- @param num:数量
function ShopController:ReqBuyItem( id, num )
	-- 检查购买条件
	local canBuy, maxBuyNum, bottleneck = ShopUtils:CheckCanBuy(id, num);
	
	--检查ID的购买类型
	local shopVO = ShopUtils:CreateShopVO(id)
	local cfg = shopVO:GetCfg()
	if not canBuy and cfg.type == 5 then
		FloatManager:AddNormal( StrConfig['shop220']);
		return;
	end
	if not canBuy then
		FloatManager:AddNormal( string.format( shopVO:GetPrompt(bottleneck), maxBuyNum ) )
		return;
	end
	local msg = ReqShoppingMsg:new();
	msg.id, msg.num = id, num;
	MsgManager:Send(msg);
end

-- 兑换商品
-- @param id:商品id(t_shop id)
-- @param num:数量
function ShopController:ReqExchangeItem( id, num )
	local msg = ReqExchangeShopMsg:new();
	msg.id, msg.num = id, num;
	MsgManager:Send(msg);
end

--回购物品
--@param cid: 回购物品的cid
function ShopController:ReqBuyBack(cid)
	local msg = ReqBuyBackMsg:new();
	msg.cid = cid;
	MsgManager:Send(msg);
end

function ShopController:StartShopSoundTime()
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end
	self.isShowShopSound = false;
	self.timerKey = TimerManager:RegisterTimer(function()
		if ShopController.timerKey then
			TimerManager:UnRegisterTimer(ShopController.timerKey);
			ShopController.timerKey = nil;
		end
		ShopController.isShowShopSound = true;
	end,4500,1);
end