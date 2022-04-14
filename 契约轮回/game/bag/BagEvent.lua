--
-- @Author: chk
-- @Date:   2018-08-21 11:45:08
--

BagEvent = BagEvent or {
	UpdateGoods     =  "BagEvent.UpdateGoods",       --更新物品数量(统一)

	
	CloseBagPanel   =  "BagEvent.CloseBagPanel",
	OpenBagPanel    =  "BagEvent.OpenBagPanel",      --打开背包事件
	OpenWarePanel   =  "BagEvent.OpenWarePanel",     --打开仓库界面
	OpenCell        =  "BagEvent.OpenCell",          --开吂格子
    OpenCellView    =  "BagEvent.OpenCellView",
	LoadItemByBagId =  "BagEvent.LoadItemByBagId",   --根据背包类型加载格子的信息(scrollView 先创建格子，后请求数据，所以先创建出来的格子没有数据，后面才拿数据显示)
	LoadBagItems    =  "BagEvent.LoadBagItems",      --加载背包的物品
	LoadWareItems   =  "BagEvent.LoadWareItems",     --加载仓库的物品
	AddItems        =  "BagEvent.AddBagItems",       --物品有添加
	DelItems        =  "BagEvent.DelBagItems",       --物品有删除
	UpdateItems     =  "BagEvent.UpdateBagItems",    --物品(数量)有更新
	UpdateRoleLv    =  "BagEvent.UpdateRoleLv",      --更新角色等于名字
	ClickItem       =  "BagEvent.ClickItem",         --点击格子事件
	
	UpdateStar      =  "BagEvent.UpdateStar",        --更新星级
	UpdateQuqlity   =  "BagEvent.UpdateQuqlity",     --更新品质
	BagArrange      =  "BagEvent.ArrangeBag",        --(背包)整理
	-- GoodsDetail     =  "BagEvent.GoodsDetail",       --装备信息
	SetSellMoney    =  "BagEvent.SetSellMoney",      --设置出售的物品价格
	UseGoodsView    =  "BagEvent.UseGoodsView",
	DesUseGoodsView =  "BagEvent.DesUseGoodsView",   --销毁快捷使用
	UseGoods        =  "BagEvent.UseGoods",
	CheckQuickUse   =  "BagEvent.CheckQuickUse",

	NoticeStoreGoods =  "BagEvent.NoticeStoreGoods",    --通知(请求)存储物品
	NoticeStoreGoods =  "BagEvent.NoticeStoreGoods",      --通知(请求)摧毁物品
	NoticeStoreGoods =  "BagEvent.NoticeStoreGoods",   --通知(请求)出售物品
	NoticeUseGoods   =  "BagEvent.NoticeUseGoods",    --通知(请求)使用物品

	SmeltItemClick   =  "BagEvent.SmeltItemClick",    --吞噬装备点击

	----其它背包相关事件
	PetBagDataEvent =  "BagEvent.OnPetBagData",    --其它系统的背包数据处理
	OtherBagAddEvent  =  "BagEvent.OnOtherBagAdd",      --其它系统的背包添加
	OtherBagDelEvent  =  "BagEvent.OnOtherBagDel",      --其它系统的背包删除
	OtherBagUpdateEvent  =  "BagEvent.OnOtherBagUpdate",      --其它系统的背包更新

	OpenBagSmeltPanel = "BagEvent.OpenBagSmeltPanel",    --打开熔炼界面
	OpenBagInputPanel = "BagEvent.OpenBagInputPanel",    --

	OpenBagShowPanel = "BagEvent.OpenBagShowPanel",    --打开背包格子界面

	SmeltRedDotEvent = "BagEvent.SmeltRedDotEvent",      --吞噬红点事件

	OpenSoulPanel = "BagEvent.OpenSoulPanel",  --打开圣痕界面

	UpdateHighScore = "BagEvent.UpdateHighScore",  --更新最高评分
}