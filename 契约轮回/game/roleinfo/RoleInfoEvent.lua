-- 
-- @Author: LaoY
-- @Date:   2018-08-16 11:23:31
-- 
--require("game.xx.xxx")

RoleInfoEvent = {
    OpenRoleInfoPanel = "RoleInfoEvent.OpenRoleInfoPanel",
    CloseRoleInfoPanel = "RoleInfoEvent.CloseRoleInfoPanel",

    ReceiveRoleInfo = "RoleInfoEvent.ReceiveRoleInfo",

    OpenRoleTitlePanel = "RoleInfoEvent.OpenRoleTitlePanel", -- 头衔
    UpdateRoleTitlePanel = "RoleInfoEvent.UpdateRoleTitlePanel", -- 头衔

    QUERY_OTHER_ROLE = "RoleInfoEvent.QueryOtherRole", -- 查询其它玩家信息返回
    QueryOtherRoleGlobal = "RoleInfoEvent.QueryOtherRoleGlobal",
    QUERY_WORLD_LEVEL = "RoleInfoEvent.QueryWorldLevel", --查询世界等级

    UpdateRedDot = "RoleInfoEvent.UpdateRedDot", --更新红点

    OpenOtherInfoPanel = "RoleInfoEvent.OpenOtherInfoPanel", --打开其他角色界面

    RoleReName = "RoleInfoEvent.RoleReName",

    TitleName = "RoleInfoEvent.TitleName", -- 头衔名字更改

    UpdateJobTitleRedDot = "RoleInfoEvent.UpdateJobTitleRedDot", --更新头衔红点
    UpdateFashionRedDot = "RoleInfoEvent.UpdateFashionRedDot", --更新角色界面里时装红点
    UpdateRoleIconFrame = "RoleInfoEvent.UpdateRoleIconFrame", --更新角色头像框体

    -- 打开问卷调查
    OpenQuestionnaire = "RoleInfoEvent.OpenQuestionnaire", --更新角色头像框体
}