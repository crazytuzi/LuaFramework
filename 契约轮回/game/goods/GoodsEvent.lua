--
-- @Author: chk
-- @Date:   2018-08-31 16:09:42
--
GoodsEvent = GoodsEvent or {
	Destroy         =  "GoodsEvent.Destroy",
	GoodsDetail     =  "GoodsEvent.GoodsDetail",
	DelItems        =  "GoodsEvent.DelItems",
	CreateAttEnd    =  "GoodsEvent.CreateAttEnd",
	SellItems       =  "GoodsEvent.SellItems",
	UpdateNum       =  "GoodsEvent.UpdateNum",
	MultySelect     =  "GoodsEvent.MultySelect",     --物品多选状态
	SingleSelect    =  "GoodsEvent.SingleSelect",    --物品单选状态
	SelectItem      =  "GoodsEvent.SelectItem",
	UseGiftSuccess  =  "GoodsEvent.UseGiftSuccess",
	CloseTipView    =  "GoodsEvent.CloseTipView",    --关闭tip
	EnabledQuickDoubleClick = "GoodsEvent.EnabledQuickDoubleClick",  --是否开启快速点击
	QueryDroppedEvent = "GoodsEvent.OnQueryDropped", --查询到掉落物品的详情
	UseItemSuccess = "GoodsEvent.UseItemSuccess",
}