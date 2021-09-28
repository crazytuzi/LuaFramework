--用户信息
local Me = class("Me")
function Me:ctor() 
    self.isLogin = false -- 如果为true说明登陆成功
    self.isFlushDataReady = false -- 基本数据是否都准备好了,,   
    
    self.dungeonData = require("app.data.DungeonData").new()

    self.hardDungeonData = require("app.data.HardDungeonData").new()
--    self.timeDungeonData = require("app.data.TimeDungeonData").new()

    self.userData = require("app.data.UserData").new()
    self.formationData = require("app.data.FormationData").new()
    self.friendData = require("app.data.FriendData").new()
    self.mailData = require("app.data.MailData").new()
    self.giftMailData = require("app.data.GiftMailData").new()

    self.skillTreeData = require("app.data.SkillTreeData").new()
    self.shopData = require("app.data.ShopData").new()
    --背包数据
    self.bagData = require("app.data.BagData").new()
    self.storyDungeonData = require("app.data.StoryDungeonData").new()
    
    self.towerData = require("app.data.TowerData").new()
    self.wushData = require("app.data.WushData").new()
    --竞技场data
    self.arenaData = require("app.data.ArenaData").new()

    self.vipData = require("app.data.VipData").new()
    self.dailytaskData = require("app.data.DailytaskData").new()
    self.fundData = require("app.data.FundData").new()
    --月基金
    self.monthFundData = require("app.data.MonthFundData").new()

    --新手光环
    self.rookieBuffData = require("app.data.RookieBuffData").new()

    --叛军data
    self.moshenData = require("app.data.MoShenData").new()

    self.crusadeData = require("app.data.CrusadeData").new()

    --活动数据
    self.activityData = require("app.data.ActivityData").new()
    
    -- 成就数据
    self.achievementData = require("app.data.AchievementData").new()
    
    self.sanguozhiData = require("app.data.SanguozhiData").new()

    self.days7ActivityData = require("app.data.Days7ActivityData").new()
    
    -- 领地征战数据
    self.cityData = require("app.data.CityData").new()

    self.dressData = require("app.data.DressData").new()

    self.wheelData = require("app.data.WheelData").new()
    self.richData = require("app.data.RichData").new()

    -- 军团数据
    self.legionData = require("app.data.LegionData").new()

    -- 跨服演武数据
    self.crossWarData = require("app.data.CrossWarData").new()

    self.arenaRobRiceData = require("app.data.ArenaRobRiceData").new()

    -- 限时优惠
    self.timePrivilegeData = require("app.data.TimePrivilegeData").new()

    -- 武将变身
    self.knightTransformData = require("app.data.KnightTransformData").new()

    -- 限时抽将
    self.themeDropData = require("app.data.ThemeDropData").new()

    -- 限时团购
    self.groupBuyData = require("app.data.GroupBuyData").new()

    --奇门八卦
    self.trigramsData = require("app.data.TrigramsData").new()

    -- 跨服夺帅
    self.crossPVPData = require("app.data.CrossPVPData").new()

    self.specialActivityData = require("app.data.SpecialActivityData").new()
    self.dailyPvpData = require("app.data.DailyPvpData").new()
    self.rCardData = require("app.data.RCardData").new()

    -- 装备养成
    self.equipmentData = require("app.data.EquipmentData").new()

    -- 过关斩将
    self.expansionDungeonData = require("app.data.ExpansionDungeonData").new()

    -- 将灵
    self.heroSoulData = require("app.data.HeroSoulData").new()

    --为了记录什么时候开始数据失去同步, 这样的话我们可以设置一个比如2分钟内 重新连接时不再拉取大量的Flush数据
    --最后断线时间, 
    self.lastOutofNetworkTime = 0
    --最后取得flushdata 的时间
    self.lastFlushDataTime = 0 

end


return Me
