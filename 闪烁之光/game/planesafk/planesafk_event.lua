
-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      位面改版 参考afk的 后端 国辉 策划 中建
-- <br/>Create: 2020-02-05
-- --------------------------------------------------------------------
PlanesafkEvent = PlanesafkEvent or {}

--基础信息
PlanesafkEvent.Planesafk_Main_Base_Info_Event = "Planesafk_Main_Base_Info_Event"
--地图信息
PlanesafkEvent.Planesafk_Main_Map_Info_Event = "Planesafk_Main_Map_Info_Event"
--更新地图新
PlanesafkEvent.Planesafk_Update_Map_Info_Event = "Planesafk_Update_Map_Info_Event"
--下一层
PlanesafkEvent.Planesafk_Next_Map_Info_Event = "Planesafk_Next_Map_Info_Event"
--通关奖励
PlanesafkEvent.Planesafk_Pass_Reward_Info_Event = "Planesafk_Pass_Reward_Info_Event"
--领取通关奖励前
PlanesafkEvent.Planesafk_Last_Reward_Info_Event = "Planesafk_Last_Reward_Info_Event"
--获取的奖励事件
PlanesafkEvent.Planesafk_Update_Get_Reward_Event = "Planesafk_Update_Get_Reward_Event"

--对方阵容数据
PlanesafkEvent.Get_Master_Data_Event = "Get_Master_Data_Event"
--总战力变化
PlanesafkEvent.Update_Form_Atk_Event = "Update_Form_Atk_Event"
--保存阵容
PlanesafkEvent.Save_Form_Success_Event = "Save_Form_Success_Event"
--请求位面阵容
PlanesafkEvent.Get_Form_Data_Event = "Get_Form_Data_Event"

--请求英雄数据
PlanesafkEvent.Get_All_Hero_Event = "Get_All_Hero_Event"
--英雄回血事件
PlanesafkEvent.Get_Hero_Live_Event = "Get_Hero_Live_Event"
--更新阵容信息
PlanesafkEvent.Update_Form_Data_Event = "Update_Form_Data_Event"
--查看英雄信息
PlanesafkEvent.Look_Other_Hero_Event = "Look_Other_Hero_Event"

--播放选择的特效
PlanesafkEvent.Chose_Buff_Event = "Chose_Buff_Event"
--buff列表
PlanesafkEvent.Get_Buff_Data_Event = "Get_Buff_Data_Event"

-- 商店事件
PlanesafkEvent.Evt_Shop_Event = "Evt_Shop_Event"


--战令基础信息
PlanesafkEvent.Planesafk_OrderAction_Init_Event = "Planesafk_OrderAction_Init_Event"
--是否活动结束弹窗
PlanesafkEvent.Planesafk_OrderAction_IsPopWarn_Event = "Planesafk_OrderAction_IsPopWarn_Event"
--首次或重置红点
PlanesafkEvent.Planesafk_OrderAction_First_Red_Event = "Planesafk_OrderAction_First_Red_Event"

--角色创建事件
PlanesafkEvent.Planesafk_Create_Role_Event = "Planesafk_Create_Role_Event"

--位面红点
PlanesafkEvent.Update_Planes_Red_Event = "Update_Planes_Red_Event"