RoleEvent = RoleEvent or BaseClass()

--角色事件宏定义
RoleEvent.type = {
    Normal = 0,
    GodBattle = 1,          --众神战场的事件
    Prepare_GB = 2,         --众神之战准备阶段的事件
}

--派发基础数据变化
RoleEvent.UPDATE_ROLE_BASE_ATTR = "RoleEvent.UPDATE_ROLE_BASE_ATTR"

--等级变化
RoleEvent.ROLE_LEVEL_CHANGE = "RoleEvent.ROLE_LEVEL_CHANGE"

--派发资产数据变化
RoleEvent.UPDATE_ROLE_ASSETS = "RoleEvent.UPDATE_ROLE_ASSETS"

--派发战斗相关的属性变化
RoleEvent.UPDATE_ROLE_FIGHT_ATTR = "RoleEvent.UPDATE_ROLE_FIGHT_ATTR"

--派发单个属性数据的变化
RoleEvent.UPDATE_ROLE_ATTRIBUTE = "RoleEvent.UPDATE_ROLE_ATTRIBUTE"

--派发角色活动资产变化 assets
RoleEvent.UPDATE_ROLE_ACTION_ASSETS = "RoleEvent.UPDATE_ROLE_ACTION_ASSETS"

-- 其他人的面板数据
RoleEvent.DISPATCH_PLAYER_VO_EVENT = "RoleEvent.DISPATCH_PLAYER_VO_EVENT"

--技能数据更新
RoleEvent.Skill_Data_Event = "RoleEvent.Skill_Data_Event"
--技能卸下成功
RoleEvent.Out_Skill_Success ="RoleEvent.Out_Skill_Success"
--技能替换成功
RoleEvent.Change_Skill_Success ="RoleEvent.Change_Skill_Success"
--技能面板跳转回属性面板
RoleEvent.Change_Select_Panel = "RoleEvent.Change_Select_Panel"
--角色战力改变
RoleEvent.UPDATE_POWER_VALUE = "RoleEvent.UPDATE_POWER_VALUE"

--角色头像框列表请求
RoleEvent.GetFaceList = "RoleEvent.GetFaceList"
RoleEvent.GetBubbleList = "RoleEvent.GetBubbleList"
RoleEvent.UseBubbleItem  = "RoleEvent.UseBubbleItem"
--角色形象
RoleEvent.GetModelList = "RoleEvent.GetModelList"
RoleEvent.UpdateModel = "RoleEvent.UpdateModel"
RoleEvent.ActiveModel = "RoleEvent.ActiveModel"
--角色称号
RoleEvent.GetTitleList = "RoleEvent.GetTitleList"
--使用称号
RoleEvent.UseTitle = "RoleEvent.UseTitle"

--自己被膜拜的数量
RoleEvent.UpdateWorshipEvent = "RoleEvent.UpdateWorshipEvent"

--自己周冠军赛被膜拜的数量
RoleEvent.UpdateCrossChamWorshipEvent = "RoleEvent.UpdateCrossChamWorshipEvent"

--膜拜其他玩家
RoleEvent.WorshipOtherRole = "RoleEvent.WorshipOtherRole"


RoleEvent.UpdataTitleList = "RoleEvent.UpdataTitleList"

-- 世界等级
RoleEvent.WORLD_LEV = "RoleEvent.WORLD_LEV"

-- 开服天数
RoleEvent.OPEN_SRV_DAY = "RoleEvent.OPEN_SRV_DAY"


--更换面板事件 ps = personal_space
RoleEvent.ROLE_PS_CHANGE_PANEL_EVENT = "RoleEvent.ROLE_PS_CHANGE_PANEL_EVENT"

-- 举报事件
RoleEvent.ROLE_REPORTED_EVENT = "RoleEvent.ROLE_REPORTED_EVENT"

--城市变化事件   
RoleEvent.ROLE_CITY_EVENT = "RoleEvent.ROLE_CITY_EVENT"
--关注事件
RoleEvent.ROLE_FOLLOW_EVENT = "RoleEvent.ROLE_FOLLOW_EVENT"
--粉丝排行榜事件
RoleEvent.ROLE_FANS_RANK_EVENT = "RoleEvent.ROLE_FANS_RANK_EVENT"

--更新荣誉墙
RoleEvent.ROLE_UPDATE_HONOR_WALL_EVENT = "RoleEvent.ROLE_UPDATE_HONOR_WALL_EVENT"
--获取荣誉墙信息
RoleEvent.ROLE_GET_HONOR_WALL_EVENT = "RoleEvent.ROLE_GET_HONOR_WALL_EVENT"
--成长之路 --自己
RoleEvent.ROLE_MYSELF_GROWTH_WAY_EVENT = "RoleEvent.ROLE_MYSELF_GROWTH_WAY_EVENT"
--成长之路 --他人
RoleEvent.ROLE_OHTER_GROWTH_WAY_EVENT = "RoleEvent.ROLE_OHTER_GROWTH_WAY_EVENT"

--获取留言信息
RoleEvent.ROLE_MESSAGE_BOARD_GET_INFO_EVENT = "RoleEvent.ROLE_MESSAGE_BOARD_GET_INFO_EVENT"
--回复信息
RoleEvent.ROLE_MESSAGE_BOARD_REPLY_EVENT = "RoleEvent.ROLE_MESSAGE_BOARD_REPLY_EVENT"
--新增留意信息
RoleEvent.ROLE_MESSAGE_BOARD_NEW_INFO_EVENT = "RoleEvent.ROLE_MESSAGE_BOARD_NEW_INFO_EVENT"
--删除留言信息
RoleEvent.ROLE_MESSAGE_BOARD_DELETE_INFO_EVENT = "RoleEvent.ROLE_MESSAGE_BOARD_DELETE_INFO_EVENT"
--设置权限事件
RoleEvent.ROLE_MESSAGE_BOARD_LIMMIT_EVENT = "RoleEvent.ROLE_MESSAGE_BOARD_LIMMIT_EVENT"

--个人空间背景列表事件
RoleEvent.ROLE_BACKGROUND_LIST_EVENT = "RoleEvent.ROLE_BACKGROUND_LIST_EVENT"
--设置个人空间背景事件
RoleEvent.ROLE_SET_BACKGROUND_EVENT = "RoleEvent.ROLE_SET_BACKGROUND_EVENT"

--实名认证
RoleEvent.ROLE_NAME_AUTHENTIC = "RoleEvent.ROLE_NAME_AUTHENTIC"

--更新功能每天首次红点
RoleEvent.UPDATE_RED_POINT = "RoleEvent.UPDATE_RED_POINT"