-- --------------------------------------------------------------------

-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      公会宝库 后端 国辉 策划 松岳
-- <br/>Create: 2019-09-04
-- --------------------------------------------------------------------
GuildmarketplaceConst = GuildmarketplaceConst or {} 


GuildmarketplaceConst.BagType = {
    eHero     = 0, --宝可梦碎片
    eEquips   = 1, --装备
    eProps    = 2, --道具
    eSpecial  = 3, -- 特殊
}


--宝库奖励记录类型(后端定义的)
GuildmarketplaceConst.RewardRecordType = {
    ePlay       = 1, --玩家操作
    eSystem     = 2, --公会宝库系统(针对过期的)
    eSecretArea = 3, --公会秘境
    eGuildWar   = 4, --联盟战
    eMonopoly   = 5, --圣夜奇境
}