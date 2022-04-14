--
-- @Author: LaoY
-- @Date:   2018-09-15 15:38:53
-- 功能开放等级配置

--OpenConfig = {
--    role = { level = 120, task = 0 }, -- 角色信息
--    bag = { level = 1, task = 0 }, -- 背包
--    equip = { level = 1, task = 0 }, -- 装备
--    mount = { level = 2, task = 0 }, -- 坐骑
--    skill = { level = 1, task = 0 }, -- 技能u
--    vision = { level = 1, task = 0 }, -- 外观
--    huaxing = { level = 1, task = 0 }, -- 化形
--    dungeon = { level = 8, task = 0 }, -- 副本
--    expDungeon = { level = 75, task = 0 }, -- 经验副本
--    worldBoss = { level = 6, task = 0 }, -- 世界boss
--    combine = { level = 1, task = 0 }, -- 合成
--    welfare = { level = 5, task = 0 }, -- 福利
--    shop = { level = 7, task = 0 }, -- 商店
--    daily = { level = 9, task = 0 }, -- 日常
--    market = { level = 8, task = 0 }, -- 市场
--    wake = { level = 4, task = 0 }, -- 觉醒
--    title = { level = 1, task = 0 }, -- 称号
--    guild = { level = 1, task = 0 }, -- 帮派
--    card = { level = 1, task = 0 }, -- 魔法卡
--    mttreasure = { level = 10, task = 0 }, -- 魔法卡寻宝
--    fashion = { level = 1, task = 0 }, -- 时装
--    book = { level = 11, task = 0 }, -- 天书
--    rank = { level = 1, task = 0 }, --排行榜
--    beast = { level = 1, task = 0 }, --神兽
--    escort = { level = 120, task = 0 }, --护送
--    candy = { level = 1, task = 0 }, --糖果屋
--    melee = { level = 13, task = 0 }, --乱斗
--    athletics = { level = 14, task = 0 }, --竞技
--    setting = { level = 1, task = 0 }, --设置
--    searchtreasure = { level = 25, task = 0 }, --装备寻宝
--    role_info = { level = 1, task = 0 }, --角色信息
--    guildBattle = { level = 150, task = 0 }, --角色信息
--    sevenDay = { level = 1, task = 0 }, --七天登录
--}
OpenConfig = OpenConfig or {}
-- require('game/config/auto/db_sysopen')
require('game.config.auto.sysopen.db_sysopen')

local function HandleConfig()
    for key, cf in pairs(Config.db_sysopen) do
        --local link_cf = GetOpenByKey(key)
        --local key_str = link_cf.key_str
        --if cf.sub_id == 1 then
        OpenConfig[cf.id .. '@' .. cf.sub_id] = { level = cf.level, task = cf.task }
        --end
    end
end

HandleConfig()
