--******** 文件说明 ********
-- @Author:      hyxing 
-- @description: 战令事件模块
-- @DateTime:    2019-04-19 10:07:45
-- *******************************
OrderActionEvent = OrderActionEvent or {}
--请求数据
OrderActionEvent.OrderAction_Init_Event = "OrderActionEvent.OrderAction_Init_Event"
--任务领取
OrderActionEvent.OrderAction_TaskGet_Event = "OrderActionEvent.OrderAction_TaskGet_Event"
--等级展示
OrderActionEvent.OrderAction_LevReward_Event = "OrderActionEvent.OrderAction_LevReward_Event"
--等级经验变化
OrderActionEvent.OrderAction_Updata_LevExp_Event = "OrderActionEvent.OrderAction_Updata_LevExp_Event"
--购买礼包卡
OrderActionEvent.OrderAction_BuyGiftCard_Event = "OrderActionEvent.OrderAction_BuyGiftCard_Event"
--是否活动结束弹窗
OrderActionEvent.OrderAction_IsPopWarn_Event = "OrderActionEvent.OrderAction_IsPopWarn_Event"