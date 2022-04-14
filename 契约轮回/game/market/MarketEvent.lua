

MarketEvent = MarketEvent or
{
	OpenMarketPanel = "MarketEvent.OpenMarketPanel",
	--------交易市场------------
	BuyMarketLeftItemClick = "MarketEvent.BuyMarketLeftItemClick", --点击左边大类按钮
	BuyMarketLeftItemSelect = "MarketEvent.BuyMarketLeftItemSelect",
	BuyMarketRightItemClick = "MarketEvent.BuyMarketRightItemClick", --点击右边小类按钮
	BuyMarketGoodItemClick = "MarketEvent.BuyMarketGoodItemClick",   --点击物品
    BuyMarketUpdateBigTypeData = "MarketEvent.BuyMarketUpdateBigTypeData",   --更新左侧大类的信息
    BuyMarketUpdateSellItemData = "MarketEvent.BuyMarketUpdateSellItemData",  --更新商品列表
	BuyMarketUpdateSearchItemData = "MarketEvent.BuyMarketUpdateSearchItemData",
	BuyMarketUpdateGoodData = "MarketEvent.BuyMarketUpdateGoodData",  --装备详细信息
	BuyMarketUpdateTwoGoodData = "MarketEvent.BuyMarketUpdateTwoGoodData",--非装备的详细信息
	BuyMarketUpdateThreeGoodData = "MarketEvent.BuyMarketUpdateThreeGoodData",  --宠物装备详细信息
	BuyMarketBuyItemData = "MarketEvent.BuyMarketBuyItemData",

	--------上架--------------
	UpShelfMarketUpBtn = "MarketEvent.UpShelfMarketUpBtn",
	OpenUpShelfTowPanel = "MarketEvent,OpenUpShelfTowPanel",
	UpShelfMarketPageBtn = "MarketEvent.UpShelfMarketPageBtn",
	UpShelfMarketPageMoreBtn = "MarketEvent.UpShelfMarketPageMoreBtn",
	UpShelfMarketSalingInfo = "MarketEvent.UpShelfMarketSalingInfo", --已上架商品
	UpShelfMarketSaleInfo = "MarketEvent.UpShelfMarketSaleInfo" ,  --上架之后的返回
	UpShelfMarketRemove = "MarketEvent.UpShelfMarketRemove", -- 修改
	UpShelfMarketAlter = "MarketEvent,UpShelfMarketAlter",
	UpShelfMarketClickRole = "MarketEvent.UpShelfMarketClickRole",
	UpShelfMarketClickSelectRole = "MarketEvent.UpShelfMarketClickSelectRole",
	UpShelfMarketDeal = "MarketEvent.UpShelfMarketDeal",



	----交易记录
	MarketRecordUpdateRecord = "MarketEvent,MarketRecordUpdateRecord",

	--指定交易
	MarketDesignatedDealing = "MarketEvent,MarketDesignatedDealing",
	MarketDesignatedClickItem = "MarketEvent,MarketDesignatedClickItem",
	MarketDesignatedBuy = "MarketEvent,MarketDesignatedBuy",
	MarketDesignatedRefuse = "MarketEvent,MarketDesignatedRefuse",

	BuyMarketReturnTimes = "MarketEvent.BuyMarketReturnTimes",

	ReturnPitem = "MarketEvent.ReturnPitem",

	UpdateRedPoint  = "MarketEvent.UpdateRedPoint",
}