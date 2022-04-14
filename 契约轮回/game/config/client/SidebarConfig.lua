--
-- @Author: LaoY
-- @Date:   2019-02-18 17:31:22
-- 主界面侧边栏以及界面导航栏配置

function GetSysOpenDataById(id)
    if not Config.db_sysopen[id] then
        return
    end
    return Config.db_sysopen[id].level
end

function GetSysOpenTaskById(id)
    if not Config.db_sysopen[id] then
        return
    end
    return Config.db_sysopen[id].task
end

SidebarConfig = {}

--[[
	@author LaoY
	@des
	@param1 text 		显示名字
	@param2 id 			id
	@param3 icon 		选中图标资源
	@param4 dark_icon 	未选中图标资源
	/*以下选填*/
	@param  show_lv 	显示等级(显示不一定开放),不配置默认是开放。
	@param  show_task 	显示任务(显示不一定开放),不配置默认是开放。
	@param  open_lv 	开放等级，不配置默认是开放。
	@param  open_task 	开放任务，不配置默认是开放。
    @param  show_func   显示方法 如果存在，不判断显示等级和显示任务条件。返回错误文本表示失败，不返回表示成功
    @param  open_func   开放方法 如果存在，不判断显示等级和显示任务条件。返回错误文本表示失败，不返回表示成功

	/*导航栏*/
	@param  show_toggle 默认选中的导航栏ID
	@param  toggle_data 导航栏具体配置
		@param1 text 		显示名字
		@param2 id 			id
		/*以下选填*/
		@param  show_lv 	显示等级(显示不一定开放),不配置默认是开放。
		@param  show_task 	显示任务(显示不一定开放),不配置默认是开放。
		@param  open_lv 	开放等级，不配置默认是开放。
		@param  open_task 	开放任务，不配置默认是开放。
        @param  show_func   显示方法 如果存在，不判断显示等级和显示任务条件。返回错误文本表示失败，不返回表示成功
        @param  open_func   开放方法 如果存在，不判断显示等级和显示任务条件。返回错误文本表示失败，不返回表示成功
--]]

-- 这里配置了，对应界面的lua文件不需要添加
-- SidebarConfig.xxx  xxx等于对应界面的__cname(lua文件名)
local ConfigLanguage = require('game.config.language.CnLanguage');

-- 副本入口界面
SidebarConfig.DungeonEntrancePanel = {
    { text = ConfigLanguage.DungeonEntrance.INDI, id = 1, icon = "bag:bag_icon_bag_s", dark_icon = "bag:bag_icon_bag_n", show_lv = GetSysOpenDataById("150@6"), show_task = GetSysOpenTaskById("150@6"), open_lv = GetSysOpenDataById("150@6"), open_task = GetSysOpenTaskById("150@6"), show_toggle = 1, toggle_data = {
        { id = 1, text = "Tower of Judgment", show_lv = GetSysOpenDataById("150@6"), show_task = GetSysOpenTaskById("150@6"), open_lv = GetSysOpenDataById("150@6"), open_task = GetSysOpenTaskById("150@6") },
        { id = 2, text = "Temple of Trial", show_lv = GetSysOpenDataById("150@7"), show_task = GetSysOpenTaskById("150@7"), open_lv = GetSysOpenDataById("150@7"), open_task = GetSysOpenTaskById("150@7") },
        { id = 3, text = "WFMD", show_lv = GetSysOpenDataById("150@8"), show_task = GetSysOpenTaskById("150@8"), open_lv = GetSysOpenDataById("150@8"), open_task = GetSysOpenTaskById("150@8") },
        { id = 4, text = "Cave of Covet", show_lv = GetSysOpenDataById("150@10"), show_task = GetSysOpenTaskById("150@10"), open_lv = GetSysOpenDataById("150@10"), open_task = GetSysOpenTaskById("150@10") },
        { id = 5, text = "Stigmata Realm", show_lv = GetSysOpenDataById("150@12"), show_task = GetSysOpenTaskById("150@12"), open_lv = GetSysOpenDataById("150@12"), open_task = GetSysOpenTaskById("150@12") },
        { id = 6, text = "Deity's Path", show_lv = GetSysOpenDataById("150@13"), show_task = GetSysOpenTaskById("150@13"), open_lv = GetSysOpenDataById("150@13"), open_task = GetSysOpenTaskById("150@13") },
    } },
    { text = ConfigLanguage.DungeonEntrance.EQUIP, id = 2, icon = "bag:bag_icon_ware_s", dark_icon = "bag:bag_icon_ware_n", show_lv = 100, show_task = 0, open_lv = 70, open_task = 0, show_toggle = 1, toggle_data = {
        { id = 1, text = "Fighter's Path" },
        { id = 2, text = "Demon Invasion", show_lv = GetSysOpenDataById("150@9"), open_lv = GetSysOpenDataById("150@9"), show_task = GetSysOpenTaskById("150@9"), open_task = GetSysOpenTaskById("150@9"), },
    } },
    --{ text = ConfigLanguage.DungeonEntrance.HOME, id = 3, icon = "bag:bag_icon_hs_s", dark_icon = "bag:bag_icon_hs_n", },
}
-- 首领界面
--{ text = ConfigLanguage.Dungeon.WORLD_BOSS, id = 1, icon = "bag:bag_icon_bag_s", dark_icon = "bag:bag_icon_bag_n", },
--    { text = ConfigLanguage.Dungeon.HOME, id = 2, icon = "bag:bag_icon_ware_s", dark_icon = "bag:bag_icon_ware_n", },
--    { text = ConfigLanguage.Dungeon.WILD, id = 3, icon = "bag:bag_icon_ware_s", dark_icon = "bag:bag_icon_ware_n", },
--    { text = ConfigLanguage.Dungeon.PERSONAL, id = 5, icon = "bag:bag_icon_ware_s", dark_icon = "bag:bag_icon_ware_n", },
--    { text = ConfigLanguage.Dungeon.DROP_RECORD, id = 4, icon = "bag:bag_icon_ware_s", dark_icon = "bag:bag_icon_ware_n", },
SidebarConfig.DungeonPanel = {
    { text = ConfigLanguage.Dungeon.WORLD_BOSS, id = 1, icon = "bag:bag_icon_bag_s", dark_icon = "bag:bag_icon_bag_n", show_lv = GetSysOpenDataById("160@1"), show_task = GetSysOpenTaskById("160@1"), open_lv = GetSysOpenDataById("160@1"), open_task = GetSysOpenTaskById("160@1"), show_toggle = 1, toggle_data = {
        { id = 1, text = "World Boss", show_lv = GetSysOpenDataById("160@1"), show_task = GetSysOpenTaskById("160@1"), open_lv = GetSysOpenDataById("160@1"), open_task = GetSysOpenTaskById("160@1") },
        
        -- { id = 2, text = "Boss Home", show_lv = GetSysOpenDataById("160@1"), show_task = GetSysOpenTaskById("160@1"), open_lv = GetSysOpenDataById("160@2"), open_task = GetSysOpenTaskById("160@2") },
        -- { id = 3, text = "Ancient Ruins", show_lv = GetSysOpenDataById("160@1"), show_task = GetSysOpenTaskById("160@1"), open_lv = GetSysOpenDataById("160@1"), open_task = GetSysOpenTaskById("160@1") },
        -- { id = 4, text = "Mirage Island (Single)", show_lv = 80, show_task = GetSysOpenTaskById("160@1"), open_lv = GetSysOpenDataById("160@1"), open_task = GetSysOpenTaskById("160@1"), open_func = function()
        --     return DungeonCtrl:GetInstance():CheckBeastIslandOpen();
        -- end },

        { id = 5, text = "Loot record", show_lv = GetSysOpenDataById("160@1"), show_task = GetSysOpenTaskById("160@1"), open_lv = GetSysOpenDataById("160@1"), open_task = GetSysOpenTaskById("160@1") },
    } },
    { text = ConfigLanguage.Dungeon.PERSONAL, id = 2, icon = "bag:bag_icon_ware_s", dark_icon = "bag:bag_icon_ware_n", show_lv = 100, show_task = 0, open_lv = 100, open_task = 0, show_toggle = 1, toggle_data = {
        { id = 1, text = "Personal Boss", show_lv = 100, open_lv = 100 }, --陈镇火说的写死150级
        { id = 2, text = "Loot record", show_lv = GetSysOpenDataById("160@1"), show_task = GetSysOpenTaskById("160@1"), open_lv = GetSysOpenDataById("160@1"), open_task = GetSysOpenTaskById("160@1") },
    } },
    { text = ConfigLanguage.Dungeon.PET_PAGE, id = 3, icon = "bag:bag_icon_bag_s", dark_icon = "bag:bag_icon_bag_n", show_toggle = 1, toggle_data = {
        { id = 1, text = ConfigLanguage.Dungeon.PET_PAGE_Boss, show_lv = GetSysOpenDataById("160@7"), show_task = GetSysOpenTaskById("160@7"), open_lv = GetSysOpenDataById("160@7"), open_task = GetSysOpenTaskById("160@7"), open_func = function()
            if IsOpenModular(GetSysOpenDataById("160@7"), GetSysOpenTaskById("160@7")) and LoginModel:GetInstance():GetOpenTime() >= 4 then

            else
                return "You didn't reach required level yet"
            end
        end, show_func = function()
            if IsOpenModular(GetSysOpenDataById("160@7"), GetSysOpenTaskById("160@7")) and LoginModel:GetInstance():GetOpenTime() >= 4 then

            else
                return "You didn't reach required level yet"
            end
        end },
        { id = 2, text = ConfigLanguage.Dungeon.PET_PAGE_Record, show_lv = GetSysOpenDataById("160@7"), show_task = GetSysOpenTaskById("160@7"), open_lv = GetSysOpenDataById("160@7"), open_task = GetSysOpenTaskById("160@7"), open_func = function()
            if IsOpenModular(GetSysOpenDataById("160@7"), GetSysOpenTaskById("160@7")) and LoginModel:GetInstance():GetOpenTime() >= 4 then

            else
                return "You didn't reach required level yet"
            end
        end, show_func = function()
            if IsOpenModular(GetSysOpenDataById("160@7"), GetSysOpenTaskById("160@7")) and LoginModel:GetInstance():GetOpenTime() >= 4 then

            else
                return "You didn't reach required level yet"
            end
        end },
        { id = 3, text = ConfigLanguage.Dungeon.PET_PAGE_EggRecord, show_lv = GetSysOpenDataById("160@7"), show_task = GetSysOpenTaskById("160@7"), open_lv = GetSysOpenDataById("160@7"), open_task = GetSysOpenTaskById("160@7"), open_func = function()
            if IsOpenModular(GetSysOpenDataById("160@7"), GetSysOpenTaskById("160@7")) and LoginModel:GetInstance():GetOpenTime() >= 4 then

            else
                return "You didn't reach required level yet"
            end
        end, show_func = function()
            if IsOpenModular(GetSysOpenDataById("160@7"), GetSysOpenTaskById("160@7")) and LoginModel:GetInstance():GetOpenTime() >= 4 then

            else
                return "You didn't reach required level yet"
            end
        end },
    }, open_func = function()
        if IsOpenModular(GetSysOpenDataById("160@7"), GetSysOpenTaskById("160@7")) and LoginModel:GetInstance():GetOpenTime() >= 4 then

        else
            return "You didn't reach required level yet"
        end
    end, show_func = function()
        if IsOpenModular(GetSysOpenDataById("160@7"), GetSysOpenTaskById("160@7")) and LoginModel:GetInstance():GetOpenTime() >= 4 then

        else
            return "You didn't reach required level yet"
        end
    end },
}

SidebarConfig.CrossPanel = {
    { text = ConfigLanguage.Cross.WORLD_BOSS, id = 1, icon = "bag:bag_icon_bag_s", dark_icon = "bag:bag_icon_bag_n", show_lv = GetSysOpenDataById("160@1"), show_task = GetSysOpenTaskById("160@1"), open_lv = GetSysOpenDataById("160@1"), open_task = GetSysOpenTaskById("160@1"), show_toggle = 1, toggle_data = {
        { id = 3, text = "Boss (Cross-server)", show_lv = 80, show_task = GetSysOpenTaskById("160@14"), open_lv = GetSysOpenDataById("160@14"), open_task = GetSysOpenTaskById("160@14"), },
        -- { id = 1, text = "Mirage Island (Cross-server)", show_lv = 80, show_task = GetSysOpenTaskById("160@15"), open_lv = GetSysOpenDataById("160@15"), open_task = GetSysOpenTaskById("160@15") },
        { id = 4, text = "Throne of Star", show_lv = GetSysOpenDataById("1140@1"), show_task = GetSysOpenTaskById("1140@1"), open_lv = GetSysOpenDataById("1140@1"), open_task = GetSysOpenTaskById("1140@1") },
        { id = 5, text = "Time Rift",show_lv = GetSysOpenDataById("160@17"), show_task = GetSysOpenTaskById("160@17"), open_lv = GetSysOpenDataById("160@17"), open_task = GetSysOpenTaskById("160@17") },
	{ id = 2, text = "Loot record", show_lv = GetSysOpenDataById("160@1"), show_task = GetSysOpenTaskById("160@1"), open_lv = GetSysOpenDataById("160@1"), open_task = GetSysOpenTaskById("160@1") },
    } },
}

SidebarConfig.RoleInfoPanel = {
    { text = ConfigLanguage.Vision.JueSe, id = 1, icon = "bag:bag_icon_bag_s", dark_icon = "bag:bag_icon_bag_n", show_lv = 0, show_task = 0, open_lv = 0, open_task = 0, },
    -- { text = ConfigLanguage.Vision.XING_PAN, id = 2, icon = "bag:bag_icon_ware_s", dark_icon = "bag:bag_icon_ware_n", show_lv = GetSysOpenDataById("100@2"), show_task = GetSysOpenTaskById("100@2"), open_lv = GetSysOpenDataById("100@2"), open_task = GetSysOpenTaskById("100@2"), },
    -- { text = ConfigLanguage.Vision.FA_BAO, id = 3, icon = "bag:bag_icon_hs_s", dark_icon = "bag:bag_icon_hs_n", show_lv = GetSysOpenDataById("100@3"), show_task = GetSysOpenTaskById("100@3"), open_lv = GetSysOpenDataById("100@3"), open_task = GetSysOpenTaskById("100@3"), },
    -- { text = ConfigLanguage.Vision.WEAPON, id = 4, icon = "bag:bag_icon_hs_s", dark_icon = "bag:bag_icon_hs_n", show_lv = GetSysOpenDataById("100@4"), show_task = GetSysOpenTaskById("100@4"), open_lv = GetSysOpenDataById("100@4"), open_task = GetSysOpenTaskById("100@4"), },
}

--商城
SidebarConfig.ShopPanel = {
    { text = ConfigLanguage.Shop.Limited_Buy, id = 1, icon = "system:side_bar_sel_img", dark_icon = "system:panel_tog_2", show_toggle = 1, toggle_data = {
        { id = 1, text = "Snap up" },
        { id = 2, text = "Weekly Limited Purchase" },
    } },
    { text = ConfigLanguage.Shop.Ingots, id = 2, icon = "system:side_bar_sel_img", dark_icon = "system:panel_tog_2", show_toggle = 1, toggle_data = {
        { id = 1, text = "Daily Item" },
        { id = 2, text = "Bound Diamond Shop" },
        { id = 3, text = "Fashion Shop" },
        { id = 4, text = "Material Shop" },
    } },
    { text = ConfigLanguage.Shop.Exchange, id = 3, icon = "system:side_bar_sel_img", dark_icon = "system:panel_tog_2", show_toggle = 1, toggle_data = {
        { id = 1, text = "Honor Shop" },
        { id = 2, text = "Boss Shop" },
    } },
}

--宠物
SidebarConfig.PetPanel = {
    { text = ConfigLanguage.Pet.Introduce, id = 1, icon = "bag:bag_icon_bag_s", dark_icon = "bag:bag_icon_bag_n" },
    -- { text = ConfigLanguage.Pet.Evolution, show_lv = GetSysOpenDataById("860@6"), open_lv = GetSysOpenDataById("860@6"), show_task = GetSysOpenTaskById("860@6"), open_task = GetSysOpenTaskById("860@6"), id = 2, icon = "bag:bag_icon_ware_s", dark_icon = "bag:bag_icon_ware_n" },
    -- { text = ConfigLanguage.Pet.Fusion, show_lv = GetSysOpenDataById("860@7"), open_lv = GetSysOpenDataById("860@7"), show_task = GetSysOpenTaskById("860@7"), open_task = GetSysOpenTaskById("860@7"), id = 3, icon = "bag:bag_icon_hs_s", dark_icon = "bag:bag_icon_hs_n" },
    -- { text = ConfigLanguage.Pet.Equip, show_lv = GetSysOpenDataById("860@8"), open_lv = GetSysOpenDataById("860@8"), show_task = GetSysOpenTaskById("860@8"), open_task = GetSysOpenTaskById("860@8"), id = 4, icon = "bag:bag_icon_hs_s", dark_icon = "bag:bag_icon_hs_n" },
    -- { text = ConfigLanguage.Pet.PetEquip, show_lv = GetSysOpenDataById("860@9"), open_lv = GetSysOpenDataById("860@9"), show_task = GetSysOpenTaskById("860@9"), open_task = GetSysOpenTaskById("860@9"),id = 5, icon = "bag:bag_icon_hs_s", dark_icon = "bag:bag_icon_hs_n" },
}
--, show_toggle = 1, toggle_data = {
--        --{ id = 1, text = "魂卡镶嵌", show_lv = 1, show_task = 0, open_lv = 1, open_task = 0 },
--        --{ id = 2, text = "魂卡升星", show_lv = 1, show_task = 0, open_lv = 1, open_task = 0 },
--        --{ id = 3, text = "魂卡分解", show_lv = 1, show_task = 0, open_lv = 1, open_task = 0 },
--        --{ id = 4, text = "魂卡兑换", show_lv = 1, show_task = 0, open_lv = 1, open_task = 0 },
--        --{ id = 5, text = "魂卡合成", show_lv = 1, show_task = 0, open_lv = 320, open_task = 0 },
--    }
-- 魂卡界面
SidebarConfig.CardPanel = {
    { text = ConfigLanguage.Card.CARD_EMBED, id = 1, icon = "bag:bag_icon_bag_s", dark_icon = "bag:bag_icon_bag_n", show_lv = GetSysOpenDataById("220@1"), show_task = GetSysOpenTaskById("220@1"), open_lv = GetSysOpenDataById("220@1"), open_task = GetSysOpenTaskById("220@1") },
    { text = ConfigLanguage.Card.CARD_UPSTAR, id = 2, icon = "bag:bag_icon_ware_s", dark_icon = "bag:bag_icon_ware_n", show_lv = 1, show_task = 0, open_lv = 1, open_task = 0, open_func = function()
        return MagicCardCtrl:GetInstance():CheckUpStarOpen();
    end },
    { text = ConfigLanguage.Card.CARD_DECOMPOSE, id = 3, icon = "bag:bag_icon_ware_s", dark_icon = "bag:bag_icon_ware_n", show_lv = 1, show_task = 0, open_lv = 1, open_task = 0, },
    { text = ConfigLanguage.Card.CARD_EXCHANGE, id = 4, icon = "bag:bag_icon_ware_s", dark_icon = "bag:bag_icon_ware_n", show_lv = 1, show_task = 0, open_lv = 1, open_task = 0, },
    { text = ConfigLanguage.Card.CARD_COMBINE, id = 5, icon = "bag:bag_icon_ware_s", dark_icon = "bag:bag_icon_ware_n", show_lv = 320, show_task = 0, open_lv = 320, open_task = 0, open_func = function()
        return MagicCardCtrl:GetInstance():CheckCombineOpen();
    end },
}

SidebarConfig.MountPanel = {
    { text = ConfigLanguage.Mount.MOUNT, id = 1, icon = "bag:bag_icon_bag_s", dark_icon = "bag:bag_icon_bag_n", show_task = GetSysOpenTaskById("130@1"), show_lv = GetSysOpenDataById("130@1"), open_lv = GetSysOpenDataById("130@1"), open_task = GetSysOpenTaskById("130@1"), },
    { text = ConfigLanguage.Mount.LEFT_HAND, id = 2, icon = "bag:bag_icon_ware_s", dark_icon = "bag:bag_icon_ware_n", show_task = GetSysOpenTaskById("130@2"), show_lv = GetSysOpenDataById("130@2"), open_lv = GetSysOpenDataById("130@2"), open_task = GetSysOpenTaskById("130@2"), },
}

SidebarConfig.EquipUpPanel = {
    { text = ConfigLanguage.Equip.Strong, id = 1, show_lv = GetSysOpenDataById("120@1"), open_lv = GetSysOpenDataById("120@1"), img_title = "equip:equip_strong_f", show_task = GetSysOpenTaskById("120@1"), open_task = GetSysOpenTaskById("120@1"), },
    { text = ConfigLanguage.Equip.Mount, id = 2, show_lv = GetSysOpenDataById("120@2"), open_lv = GetSysOpenDataById("120@2"), img_title = "equip:equip_mount_f", show_task = GetSysOpenTaskById("120@2"), open_task = GetSysOpenTaskById("120@2"), },
    { text = ConfigLanguage.Equip.Suit, id = 3, show_lv = GetSysOpenDataById("120@3"), open_lv = GetSysOpenDataById("120@3"), img_title = "equip:equip_suit_f", show_task = GetSysOpenTaskById("120@3"), open_task = GetSysOpenTaskById("120@3"), },
    { text = ConfigLanguage.Equip.Refine, id = 4, show_lv = GetSysOpenDataById("120@4"), open_lv = GetSysOpenDataById("120@4"), img_title = "equip:equip_refine_title", show_task = GetSysOpenTaskById("120@4"), open_task = GetSysOpenTaskById("120@4"), },
}

SidebarConfig.CombinePanel = {
    { text = ConfigLanguage.Combine.Equip, id = 1, show_lv = GetSysOpenDataById("170@2"), open_lv = GetSysOpenDataById("170@2"), show_task = GetSysOpenTaskById("170@2"), open_task = GetSysOpenTaskById("170@2"), icon = "bag:bag_icon_ware_s", dark_icon = "bag:bag_icon_ware_n" },
    { text = ConfigLanguage.Combine.Item, id = 2, show_lv = 1, open_lv = 1, icon = "bag:bag_icon_ware_s", dark_icon = "bag:bag_icon_ware_n" },
    { text = "Weapon Soul", id = 3, open_lv = GetSysOpenDataById("170@1"), icon = "bag:bag_icon_ware_s", dark_icon = "bag:bag_icon_ware_n" },
    { text = "Divine", id = 4, open_lv = GetSysOpenDataById("1460@1"), icon = "bag:bag_icon_ware_s", dark_icon = "bag:bag_icon_ware_n" },
}

SidebarConfig.DailyPanel = {
    { text = ConfigLanguage.Daily.DailyTask, id = 1, show_lv = 1, open_lv = 1, icon = "bag:bag_icon_ware_s", dark_icon = "bag:bag_icon_ware_n" },
    { text = ConfigLanguage.Daily.ResourceFind, id = 2, show_lv = GetSysOpenDataById("270@2"), open_lv = GetSysOpenDataById("270@2"), icon = "bag:bag_icon_ware_s", dark_icon = "bag:bag_icon_ware_n" },
    { text = ConfigLanguage.Daily.ActivityPrediction, id = 3, show_lv = 1, open_lv = 1, icon = "bag:bag_icon_ware_s", dark_icon = "bag:bag_icon_ware_n" },
    { text = ConfigLanguage.Daily.GodHouse, id = 4, show_lv = 1, open_lv = 1, icon = "bag:bag_icon_ware_s", dark_icon = "bag:bag_icon_ware_n" , show_lv = GetSysOpenDataById("210@5"), open_lv = GetSysOpenDataById("210@5")},
}

--福利
SidebarConfig.WelfarePanel = {
    { text = ConfigLanguage.Wealfare.Online, id = 1 },
    { text = ConfigLanguage.Wealfare.Sign, id = 2 },
    { text = ConfigLanguage.Wealfare.Level, id = 3 },
    { text = ConfigLanguage.Wealfare.Power, id = 4 },
    { text = ConfigLanguage.Wealfare.Grail, id = 5, show_lv = GetSysOpenDataById("500@5"), open_lv = GetSysOpenDataById("500@5"), show_task = GetSysOpenTaskById("500@5"), open_task = GetSysOpenTaskById("500@5"), },
    { text = ConfigLanguage.Wealfare.Notice, id = 6 },
    { text = ConfigLanguage.Wealfare.Download, id = 7 },
    { text = ConfigLanguage.Wealfare.Exchange, id = 8 },
}

--邮件，好友
SidebarConfig.MailPanel = {
    { text = ConfigLanguage.Mail.Friend, id = 1, img_title = "mail:mail_friend_f", show_lv = GetSysOpenDataById("580@1"), open_lv = GetSysOpenDataById("580@1"), show_task = GetSysOpenTaskById("580@1"), open_task = GetSysOpenTaskById("580@1") },
    { text = ConfigLanguage.Mail.Mail, id = 2, img_title = "mail:mail_mail_f", },
}

if not PlatformManager:IsEN() then
    SidebarConfig.MailPanel[#SidebarConfig.MailPanel+1] = { text = ConfigLanguage.Mail.Service, id = 3, img_title = "mail:mail_service_f", }
end

SidebarConfig.GodPanel = {
    { text = ConfigLanguage.god.god, id = 1, show_lv = GetSysOpenDataById("1400@1"), open_lv = GetSysOpenDataById("1400@1"), show_task = GetSysOpenTaskById("1400@1"), open_task = GetSysOpenTaskById("1400@1") },
    { text = ConfigLanguage.god.figure, id = 2, show_lv = GetSysOpenDataById("1400@1"), open_lv = GetSysOpenDataById("1400@1"), show_task = GetSysOpenTaskById("1400@1"), open_task = GetSysOpenTaskById("1400@1") },
    { text = ConfigLanguage.god.Equip, id = 3, show_lv = GetSysOpenDataById("1400@1"), open_lv = GetSysOpenDataById("1400@1"), show_task = GetSysOpenTaskById("1400@1"), open_task = GetSysOpenTaskById("1400@1") },
}
--CardModel.cardPanelData = {
--    { id = 1, text = "魂卡镶嵌" },
--    { id = 2, text = "魂卡升星" },
--    { id = 3, text = "魂卡分解" },
--    { id = 4, text = "魂卡兑换" },
--    { id = 5, text = "魂卡合成" },
--}

SidebarConfig.VipPanel = {
    { text = ConfigLanguage.Vip.VipTag, id = 1, show_lv = 1, open_lv = 1, icon = "system:side_bar_sel_img", dark_icon = "system:panel_tog_2",
        show_func = function()
            if LoginModel.IsIOSExamine then
                return '苹果审核不开'
            end
        end},
    { text = ConfigLanguage.Vip.RechargeTag, id = 2, show_lv = 1, open_lv = 1, icon = "system:side_bar_sel_img", dark_icon = "system:panel_tog_2",},
    { text = ConfigLanguage.Vip.Gift, id = 3, show_lv = 1, open_lv = 1, icon = "system:side_bar_sel_img", dark_icon = "system:panel_tog_2", 
        show_func = function()
            if LoginModel.IsIOSExamine then
                return '苹果审核不开'
            end
        end},
    { text = ConfigLanguage.Vip.MonthCard, id = 4, show_lv = 56, open_lv = 56, icon = "system:side_bar_sel_img", dark_icon = "system:panel_tog_2", 
        show_func = function()
            if LoginModel.IsIOSExamine then
                return '苹果审核不开'
            end
        end},
    { text = ConfigLanguage.Vip.Invest, id = 5, show_lv = 100, open_lv = 100, icon = "system:side_bar_sel_img", dark_icon = "system:panel_tog_2", 
        show_func = function()
            if LoginModel.IsIOSExamine then
                return '苹果审核不开'
            end
        end},
}

SidebarConfig.DecoratePanel = {
    { text = "Bubble", id = 1, show_lv = 1, open_lv = 1, icon = "system:side_bar_sel_img", dark_icon = "system:panel_tog_2", },
    { text = "Portrait", id = 2, show_lv = 1, open_lv = 1, icon = "system:side_bar_sel_img", dark_icon = "system:panel_tog_2", },
}


--机甲
SidebarConfig.MachineArmorPanel = {
    { text = ConfigLanguage.MachineArmor.UpGrade, id = 1, show_lv = GetSysOpenDataById("1450@1"), open_lv = GetSysOpenDataById("1450@1"), show_task = GetSysOpenTaskById("1450@1"), open_task = GetSysOpenTaskById("1450@1"),icon = "bag:bag_icon_ware_s", dark_icon = "bag:bag_icon_ware_n" },
    { text = ConfigLanguage.MachineArmor.UpLv,id = 2,icon = "bag:bag_icon_ware_s", dark_icon = "bag:bag_icon_ware_n" ,
      open_func = function()
          return MachineArmorModel:GetInstance():IsCanClick(2)
        end },
    { text = ConfigLanguage.MachineArmor.Equip, id = 3 , icon = "bag:bag_icon_ware_s", dark_icon = "bag:bag_icon_ware_n" ,show_lv = GetSysOpenDataById("1450@3"), open_lv = GetSysOpenDataById("1450@3"), show_task = GetSysOpenTaskById("1450@3"), open_task = GetSysOpenTaskById("1450@3"),
      open_func = function()
          return MachineArmorModel:GetInstance():IsCanClick(3)
      end},

}

SidebarConfig.SiegewarParentPanel = {
    {text = "Siege Battle", id = 1, show_lv = GetSysOpenDataById("160@16"), open_lv = GetSysOpenDataById("160@16"), show_task = GetSysOpenTaskById("160@16"), open_task = GetSysOpenTaskById("160@16"),icon = "bag:bag_icon_ware_s", dark_icon = "bag:bag_icon_ware_n"},
    {text = "Loot", id = 2, show_lv = GetSysOpenDataById("160@16"), open_lv = GetSysOpenDataById("160@16"), show_task = GetSysOpenTaskById("160@16"), open_task = GetSysOpenTaskById("160@16"),icon = "bag:bag_icon_ware_s", dark_icon = "bag:bag_icon_ware_n"},

}
