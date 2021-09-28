--HandlersManager.lua



local HandlersManager = class ("HandlersManager")

function HandlersManager:ctor( ... )
    self._monitorProtocals = {}
    self._handlers = {}
    self:_initHandlers(...)
end

function HandlersManager:_createHandler(handlerClass, handlerName)
    local handler = require(handlerClass).new()
    handler:initHandler()
    self._handlers[handlerName] = handler
    return handler
end

function HandlersManager:_initHandlers( ... )
    self.chatHandler = self:_createHandler("app.network.message.ChatHandler", "chatHandler")
    self.cardHandler = self:_createHandler("app.network.message.CardHandler", "cardHandler")
    self.arenaHandler = self:_createHandler("app.network.message.ArenaHandler", "arenaHandler")
    self.coreHandler = self:_createHandler("app.network.message.CoreHandler", "coreHandler")
    self.friendHandler = self:_createHandler("app.network.message.FriendHandler", "friendHandler")
    self.fundHandler = self:_createHandler("app.network.message.FundHandler", "fundHandler")
    self.battleHandler = self:_createHandler("app.network.message.BattleHandler", "battleHandler")
    self.monthFundHandler = self:_createHandler("app.network.message.MonthFundHandler", "monthFundHandler")

    self.dungeonHandler = self:_createHandler("app.network.message.DungeonHandler", "dungeonHandler")
    self.hardDungeonHandler = self:_createHandler("app.network.message.HardDungeonHandler", "hardDungeonHandler")
--    self.timeDungeonHandler = self:_createHandler("app.network.message.TimeDungeonHandler", "timeDungeonHandler")
    self.timePrivilegeHandler = self:_createHandler("app.network.message.TimePrivilegeHandler", "timePrivilegeHandler")

    self.towerHandler = self:_createHandler("app.network.message.TowerHandler", "towerHandler")
    self.wushHandler = self:_createHandler("app.network.message.WushHandler", "wushHandler")
    self.bagHandler = self:_createHandler("app.network.message.BagHandler", "bagHandler")
    self.mailHandler = self:_createHandler("app.network.message.MailHandler", "mailHandler")
    self.shopHandler = self:_createHandler("app.network.message.ShopHandler", "shopHandler")
    self.heroUpgradeHandler = self:_createHandler("app.network.message.HeroUpgradeHandler", "heroUpgradeHandler")
    self.equipmentStrengthenHandler = self:_createHandler("app.network.message.EquipmentStrengthenHandler", "equipmentStrengthenHandler")
    self.giftMailHandler = self:_createHandler("app.network.message.GiftMailHandler", "giftMailHandler")
    self.secretShopHandler = self:_createHandler("app.network.message.SecretShopHandler", "secretShopHandler")

    self.storyDungeonHandler = self:_createHandler("app.network.message.StoryDungeonHandler", "storyDungeonHandler")

    self.moshenHandler = self:_createHandler("app.network.message.MoShenHandler", "moShenHandler")
    self.handBookHandler = self:_createHandler("app.network.message.HandBookHandler", "handBookHandler")
    self.treasureRobHandler = self:_createHandler("app.network.message.TreasureRobHandler", "treasureRobHandler")
    self.fightResourcesHandler = self:_createHandler("app.network.message.FightResourcesHandler", "fightResourcesHandler")
    self.treasureHandler = self:_createHandler("app.network.message.TreasureHandler", "treasureHandler")
    self.recycleHandler = self:_createHandler("app.network.message.RecycleHandler", "recycleHandler")
    self.guideHandler = self:_createHandler("app.network.message.GuideHandler", "guideHandler")
    self.noticeHandler = self:_createHandler("app.network.message.NoticeHandler", "noticeHandler")
    self.vipHandler = self:_createHandler("app.network.message.VipHandler", "vipHandler")
    self.dailytaskHandler = self:_createHandler("app.network.message.DailytaskHandler", "dailytaskHandler")
    self.activityHandler = self:_createHandler("app.network.message.ActivityHandler", "activityHandler")  
    self.targetHandler = self:_createHandler("app.network.message.TargetHandler", "targetHandler")
    --三国志handler
    self.sanguozhiHandler = self:_createHandler("app.network.message.SanguozhiHandler","sanguozhiHandler")
    self.hallOfFrameHandler = self:_createHandler("app.network.message.HallOfFrameHandler", "hallofframeHandler")

    self.daysActivityHandler = self:_createHandler("app.network.message.DaysActivityHandler", "daysActivityHandler")
    
    self.cityHandler = self:_createHandler("app.network.message.CityHandler", "CityHandler")
    self.dressHandler = self:_createHandler("app.network.message.DressHandler", "DressHandler")
    self.legionHandler = self:_createHandler("app.network.message.LegionHandler", "LegionHandler")

    self.gmActivityHandler = self:_createHandler("app.network.message.GMActivityHandler", "GMActivityHandler")
    
    self.rookieBuffHandler = self:_createHandler("app.network.message.RookieBuffHandler", "RookieBuffHandler")
    self.avatarFrameHandler = self:_createHandler("app.network.message.AvatarFrameHandler", "AvatarFrameHandler")
    self.crusadeHandler = self:_createHandler("app.network.message.CrusadeHandler", "CrusadeHandler")
    
    self.shareHandler = self:_createHandler("app.network.message.ShareHandler", "ShareHandler")
    self.wheelHandler = self:_createHandler("app.network.message.WheelHandler", "WheelHandler")
    self.richHandler = self:_createHandler("app.network.message.RichHandler", "RichHandler")
    
    self.awakenShopHandler = self:_createHandler("app.network.message.AwakenShopHandler", "AwakenShopHandler")
    self.crossWarHandler = self:_createHandler("app.network.message.CrossWarHandler", "CrossWarHandler")
    self.titleHandler = self:_createHandler("app.network.message.TitleHandler", "TitleHandler")

    self.codeHandler = self:_createHandler("app.network.message.CodeHandler", "CodeHandler")

    self.knightTransformHandler = self:_createHandler("app.network.message.KnightTransformHandler", "knightTransformHandler")

    self.themeDropHandler = self:_createHandler("app.network.message.ThemeDropHandler", "themeDropHandler")

    self.groupBuyHandler = self:_createHandler("app.network.message.GroupBuyHandler", "groupBuyHandler")
    self.petHandler = self:_createHandler("app.network.message.PetHandler", "PetHandler")
    self.dailyPvpHandler = self:_createHandler("app.network.message.DailyPvpHandler", "dailyPvpHandler")

    self.trigramsHandler = self:_createHandler("app.network.message.TrigramsHandler", "TrigramsHandler")

    self.crossPVPHandler = self:_createHandler("app.network.message.CrossPVPHandler", "crossPVPHandler")
    self.specialActivityHandler = self:_createHandler("app.network.message.SpecialActivityHandler", "specialActivityHandler")

    self.expansionDungeonHandler = self:_createHandler("app.network.message.ExpansionDungeonHandler", "expansionDungeonHandler")

    self.changeNameHandler = self:_createHandler("app.network.message.ChangeNameHandler", "ChangeNameHandler")
    self.rCardHandler = self:_createHandler("app.network.message.RCardHandler", "RCardHandler")
    self.heroSoulHandler = self:_createHandler("app.network.message.HeroSoulHandler", "heroSoulHandler")
end


function HandlersManager:unInitHandlers( ... )
    for k,handler in pairs(self._handlers) do
        handler:unInitHandler( ... )
    end
end

function HandlersManager:clearHandlers( ... )
    if uf_messageDispatcher then 
        uf_messageDispatcher:clearMsg()
    end

    for k,handler in pairs(self._handlers) do
        self[k] = nil 
    end
    self._handlers = {}
end

-- function HandlersManager:reCreateHandlers( ... )
--     self:unInitHandlers()
--     self:clearHandlers()
--     self:_initHandlers()
-- end


return HandlersManager