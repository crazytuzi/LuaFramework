--[[
    文件名：Player.lua
    描述：玩家数据类
    创建人：heguanghui
    创建时间：2015.4.13
-- ]]
require("data.Notification")
require("Config.EnumsConfig")

--
Player = {
    mIsLogin = false, -- 玩家是否已登录
    mGameCache = {},  -- 游戏数据缓存
}

-- ============= 以下的数据缓存实例对象是玩家自己拥有物品的缓存对象，如果是其他玩家数据需要另外实例化 =====================
-- 玩家拥有人物管理对象
HeroObj = require("data.CacheHero"):create()
-- 玩家拥有装备管理对象
EquipObj = require("data.CacheEquip"):create()
-- 玩家拥有神兵管理对象
TreasureObj = require("data.CacheTreasure"):create()
-- 玩家拥有物品管理对象
GoodsObj = require("data.CacheGoods"):create()
-- 玩家拥有内功心法管理对象
ZhenjueObj = require("data.CacheZhenjue"):create()
-- 玩家拥有真元管理对象
ZhenyuanObj = require("data.CacheZhenyuan"):create()
-- 玩家拥有神兵碎片管理对象
TreasureDebrisObj = require("data.CacheTreasureDebris"):create()
-- 玩家拥有外功秘籍管理对象
PetObj = require("data.CachePet"):create()
-- 玩家阵容信息管理对象
FormationObj = require("data.CacheFormation"):create(true)
-- 玩家背包信息管理对象
BagInfoObj = require("data.CacheBag"):create()
-- 玩家模块信息管理对象
ModuleInfoObj = require("data.CacheModuleInfo"):create()
-- 玩家小红点信息管理对象
RedDotInfoObj = require("data.CacheRedDotInfo"):create()
-- 玩家属性信息管理对象
PlayerAttrObj = require("data.CachePlayerAttr"):create()
-- 活动信息管理对象
ActivityObj = require("data.CacheActivity"):create()
-- 帮派信息管理对象
GuildObj = require("data.CacheGuild"):create()
-- 八大门派信息管理对象
SectObj = require("data.CacheSect"):create()
-- 新手引导信息管理对象
GuideObj = require("data.CacheGuide"):create()
-- 走马灯信息管理对象
MarqueeObj = require("data.CacheMarquee"):create()
-- 副本数据管理对象
BattleObj = require("data.CacheBattle"):create()
-- 自动战斗缓存数据
AutoFightObj = require("data.CacheAutoFight"):create()
-- 在线奖励数据管理对象
OnlineRewardObj = require("data.CacheOnlineReward"):create()
-- 光明顶挂机数据管理对象
ExpediGuaJiObj = require("data.CacheExpediGuaJi"):create()
-- 限时赏金数据管理对象
TimeLimitObj = require("data.CacheTimeLimit"):create()
-- 整容卡槽最优数据管理对象
SlotPrefObj = require("data.CacheSlotPref"):create()
-- 黑名单玩家管理对象
EnemyObj = require("data.CacheEnemy"):create()
-- 玩家上线提醒管理对象
OnlineNotifyObj = require("data.CacheOnlineNotify"):create()
-- 好友数据管理对象 
FriendObj = require("data.CacheFriend"):create()
-- 绝学（时装）管理对象 
FashionObj = require("data.CacheFashion"):create()
-- 幻化管理对象 
IllusionObj = require("data.CacheIllusion"):create()
-- 大侠之路管理对象 
RoadOfHeroObj = require("data.CacheRoadOfHero"):create()
-- 珍兽管理对象
ZhenshouObj = require("data.CacheZhenshou"):create()
-- 珍兽阵容管理对象
ZhenshouSlotObj = require("data.CacheZhenshouSlot"):create()
-- Q版时装管理对象
QFashionObj = require("data.CacheQFashion"):create()
-- 宝石管理对象
ImprintObj = require("data.CacheImprint"):create()


--- ========================== 账户登录相关信息 =====================
-- 保存账户登录相关信息（与游戏登录有区别，可能多个游戏服务器登录信息对应一个账户登录信息，账户登录信息与渠道相关，游戏登录与渠道不相关）
--[[
-- 缓存的数据格式为：
    {
        LoginInfo:
        UserID:
        ExtraData:
    }
 ]]
function Player:setUserLoginInfo(value, clearOld)
    self.mUserLoginInfo = clearOld and {} or self.mUserLoginInfo or {}
    table.merge(self.mUserLoginInfo, value or {})
end

-- 获取账户登录相关信息
function Player:getUserLoginInfo()
    return self.mUserLoginInfo
end

--- ========================== 当前选中服务器信息 ===================
-- 设置选中的游戏服务器信息
--[[
-- 参数 serverInfo 的格式为：
    {
        "ChargeServerUrl" = "http://charge.ft.moqikaka.com/HT/HTHD/Communal",
        "ChatServerUrl" = "10.1.0.14:40008",
        "ServerUrl" = "http://local.ft.moqikaka.com:11004/",
        "GameVersionID" = 100,
        "ServerID" = 20016,
        "OfficialOrTest" = 1,
        "ServerState" = 1,
        "ServerName" = "开放测试服2",
        "ServerLoad" = 1,
        "ServerHeat" = 1,
    },
]]
function Player:setSelectServer(serverInfo)
    --dump(serverInfo, "serverInfo:")
    self.mSelectServer = serverInfo
end

-- 获取选中的游戏服务器信息
function Player:getSelectServer()
    return self.mSelectServer
end

--- ========================== 缓存数据变化相关 =====================
-- 清空缓存数据, 切换账号时调用
function Player:cleanCache()
    -- 玩家是否已登录
    self.mIsLogin = false
    -- 卸载定时器的
    self:unInstallTimer()
    -- 当前服务器时间戳
    self.mTimeTick = 0

    -- 玩家拥有人物管理对象
    HeroObj:reset()
    -- 玩家拥有装备管理对象
    EquipObj:reset()
    -- 玩家拥有神兵管理对象
    TreasureObj:reset()
    -- 玩家拥有物品管理对象
    GoodsObj:reset()
    -- 玩家拥有内功心法管理对象
    ZhenjueObj:reset()
    -- 玩家拥有真元管理对象
    ZhenyuanObj:reset()
    -- 玩家拥有神兵碎片管理对象
    TreasureDebrisObj:reset()
    -- 玩家拥有外功秘籍管理对象
    PetObj:reset()
    -- 玩家阵容信息管理对象
    FormationObj:reset()
    -- 玩家背包信息管理对象
    BagInfoObj:reset()
    -- 玩家模块信息管理对象
    ModuleInfoObj:reset()
    -- 玩家小红点信息管理对象
    RedDotInfoObj:reset()
    -- 玩家信息管理对象
    PlayerAttrObj:reset()
    -- 活动信息管理对象
    ActivityObj:reset()
    -- 帮派信息管理对象
    GuildObj:reset()
    -- 八大门派信息管理对象
    SectObj:reset()
    -- 新手引导信息管理对象
    GuideObj:reset()
    -- 走马灯信息管理对象
    MarqueeObj:reset()
    -- 在线奖励数据管理对象
    OnlineRewardObj:reset()
    -- 限时赏金数据管理对象
    TimeLimitObj:reset()
    -- 整容卡槽最优数据管理对象
    SlotPrefObj:reset()
    -- 好友数据管理对象
    FriendObj:reset()
    -- 绝学管理对象
    FashionObj:reset()
    -- 大侠之路管理对象
    RoadOfHeroObj:reset()
    -- 光明顶挂机
    ExpediGuaJiObj:reset()
    --珍兽管理对象
    ZhenshouObj:reset()
    --珍兽阵容管理对象
    ZhenshouSlotObj:reset()
    -- Q版时装管理对象
    QFashionObj:reset()
    -- 宝石管理对象
    ImprintObj:reset()
    -- 清空缓存
    self.mGameCache = {}

    -- 玩家已初始化数据
    self.mDataIsInitiated = false  
end

--- 玩家Avatar数据同步更新
function Player:updateAvatar(avatar)
    avatar = avatar or {}

    -- 修改玩家属性
    PlayerAttrObj:changeAttr(avatar)

    -- 修改大侠之路的状态
    RoadOfHeroObj:setCurrTask(avatar)

    --- 服务器模块开启状况信息
    if avatar.ModuleInfo then
        ModuleInfoObj:updateModuleInfo(avatar.ModuleInfo)
    end

    if avatar.IsEnterGuild then
        GuildObj:changeIsEnter(avatar.IsEnterGuild)
    end

    -- 改变的帮派加入退出状态枚举, 帮派名称
    if avatar.EnterGuildInfo then
        GuildObj:changeEnterGuildInfo(avatar.EnterGuildInfo)
    end

    -- 帮派Id改变 或 帮派名称
    if avatar.GuildId or avatar.GuildName then
        GuildObj:updateGuildAvatar({Id = avatar.GuildId, Name = avatar.GuildName})
    end

    --- 更新卡槽属性信息
    if avatar.SlotInfo then
        FormationObj:updateSlotInfos(avatar.SlotInfo)
    end

    --- 更新物品道具信息
    if avatar.GoodsInfo then
        GoodsObj:modifyGoods(avatar.GoodsInfo)
    end

    --- 更新神兵碎片
    if avatar.TreasureDebrisInfo then
        TreasureDebrisObj:modifyTreasureDebris(avatar.TreasureDebrisInfo)
    end
    
    --- 走马灯信息
    if avatar.MarqueeMessage then
        MarqueeObj:updateMarquee(avatar.MarqueeMessage)
    end

    -- 新手引导数据
    if avatar.StepCountList then
        GuideObj:updateGuideInfo(avatar.StepCountList)
    end

    -- 新的普通战役章节开放信息
    if avatar.ChapterInfo then
        --dump(avatar.ChapterInfo, "avatar.ChapterInfo:")
        BattleObj:insertChapterInfo(avatar.ChapterInfo)
    end

    -- 限时活动信息
    if avatar.TimedActivityOpenInfo then
        --dump(avatar.TimedActivityOpenInfo, "avatar.TimedActivityOpenInfo:")
        ActivityObj:setActivityInfo(avatar.TimedActivityOpenInfo)
    end

    -- 限时任务触发
    if avatar.IsTimedRedirect then
        -- if avatar.IsTimedRedirect >= 1 then
        --     --dump("触发限时任务啦", "avatar.IsTimedRedirect")
        --     local cache = require("common.PlayerCacheData")
        --     cache:set("TimedTask.isNotice", true, 0)
        -- end
    end

    -- 通知充值成功的消息
    if avatar.ChargeDiamondInfo then
        local hintLayer
        local hintStr = ""
        for _, v in pairs(avatar.ChargeDiamondInfo) do
            if table.getn(v) > 1 then
                hintStr = string.format(TR("您充值的%d{db_1111.png}(赠送%d{db_1111.png})已到账"), v[1], v[2])
                break
            end
        end
        hintStr = hintStr..TR("请尽情的挥霍吧~")
        MsgBoxLayer.addOKLayer(hintStr, TR("充值提示"))
    end

    if avatar.RedBag then
        --dump(avatar.RedBag, "avatar.RedBag:")
        PlayerAttrObj:setRedBagInfo(avatar.RedBag)
    end

    -- 称号头像框激活
    if avatar.DesignationIds then
        for _,v in ipairs(avatar.DesignationIds) do
            local tmpConfig = DesignationPicRelation.items[tonumber(v)]
            if (tmpConfig ~= nil) then
                ui.showFlashView(TR("恭喜您激活了称号%s[%s]", "#FF3333", tmpConfig.name))
            end
        end
    end

    -- 冰火岛奖励刷新缓存
    if avatar.BaseGetGameResourceList then
        self:addDropToResData({
            BaseGetResource = avatar.BaseGetGameResourceList.BaseGetGameResourceList,
        })
    end
end

-- 通过聊天服务器返回的Avatar数据同步更新
function Player:updateSocketAvatar(avatar)
    -- 桃花岛好友邀请
    if avatar.ShengyuanInvite then 
        PlayerAttrObj:changeAttr({
            ShengyuanWarsInvitData = {avatar.ShengyuanInvite}
        })
       Notification:postNotification(EventsName.eShengyuanWarsInvite)
    end 
    -- 桃花岛成员变更
    if avatar.ShengyuanTeam then 
        --dump(avatar.ShengyuanTeam)
        Notification:postNotification(EventsName.eShengyuanTeam)
    end 
    -- 桃花岛队长发出开始匹配
    if avatar.ShengyuanMatch then 
        Notification:postNotification(EventsName.eShengyuanMatch, avatar.ShengyuanMatch)
    end 
    -- 帮派战的积分发生变化
    if avatar.GuildBattleScore then 
        GuildObj:setGuildBattlePlayerItem(avatar.GuildBattleScore)
        Notification:postNotification(EventsName.eGuildBattleScore, avatar.GuildBattleScore)
    end 
        
    -- 小红信息
    if avatar.RedDotInfo then
        RedDotInfoObj:setSocketRedDotInfo(avatar.RedDotInfo)
    end

    -- 卡槽最优数据
    if avatar.SlotPrefData then
        SlotPrefObj:updatePrefData(avatar.SlotPrefData)
    end

    -- 组队副本3.0(队伍信息变化)
    if avatar.ExpeditioRefreshTeam then
        Notification:postNotification(EventsName.eExpeditionPrefix, avatar.ExpeditioRefreshTeam)
    end
    -- 战斗信息
    if avatar.ExpeditionFightResult then
        Notification:postNotification(EventsName.eExpeditionFightResultPrefix, avatar.ExpeditionFightResult)
    end

    -- 光明顶挂机
    if avatar.ExpeditionGuajiStatus then
        -- 获取挂机信息
        ExpediGuaJiObj:setIsGuaJi(avatar.ExpeditionGuajiStatus)
        Notification:postNotification(EventsName.eExpeditionGuaJi)
    end

    -- 确认连战信息
    if avatar.SureStartFight then
        Notification:postNotification(EventsName.eSureStartFight, avatar.SureStartFight)
    end

    -- boss血量改变信息
    if avatar.WorldBossRemainHp then
        if avatar.WorldBossRemainHp <= 0 then --boss血量变为0时拍卖行小红点设为true
            RedDotInfoObj:setSocketRedDotInfo({[tostring(ModuleSub.eWorldBossAuction)] = {Default=true}})
        end
        Notification:postNotification(EventsName.eBossHpChanged, avatar.WorldBossRemainHp)
    end

    -- 组队邀请消息    
    if avatar.ExpeditionInviteFriend then
        -- dump(avatar.ExpeditionInviteFriend, "avatar.ExpeditionInviteFriend")
        PlayerAttrObj:changeAttr({
            ExpedInvitData = avatar.ExpeditionInviteFriend
        })
       Notification:postNotification(EventsName.eInviteInfoNewPrefix)
    end

    --dump(avatar, "Player:updateSocketAvatar:")
    local moduleId = tonumber(avatar.TeambattleInfo or "") or 0
    if moduleId > 0 then
        local pushModuleId = avatar.TeambattleInfo
        if moduleId == ModuleSub.eTeambattleHelp then  -- 修改组队副本邀请的状态
            PlayerAttrObj:changeAttr({
                TeamBattleStatus = Enums.TeamBattleStatus.eHelp
            })
            pushModuleId = tostring(ModuleSub.eTeambattleInvite)
        elseif moduleId == ModuleSub.eTeambattleTeam then -- 修改组队副本邀请的状态
            PlayerAttrObj:changeAttr({
                TeamBattleStatus = Enums.TeamBattleStatus.eTeam
            })
            pushModuleId = tostring(ModuleSub.eTeambattleInvite)
        end
        Notification:postNotification(EventsName.eSocketPushPrefix .. pushModuleId)
    end

    -- 好友信息变化信息
    if avatar.FriendInfo then
        if avatar.FriendInfo.ModifyList then
            FriendObj:modifyFriends(avatar.FriendInfo.ModifyList)
        end
        if avatar.FriendInfo.DeleteList then
            FriendObj:deleteFriends(avatar.FriendInfo.DeleteList)
        end
    end

    --江湖杀信息
    --开始移动
    if avatar.BeginMove then
        -- dump(avatar.BeginMove, "BeginMove")
        Notification:postNotification(EventsName.eBeginMove, avatar.BeginMove)
    end
    --移动结束
    if avatar.ArriveNode then
        -- dump(avatar.ArriveNode, "ArriveNode")
        Notification:postNotification(EventsName.eArriveNode, avatar.ArriveNode)
    end
    --节点信息变化
    if avatar.NodeStatusChange then
        dump(avatar.NodeStatusChange, "NodeStatusChange")
        Notification:postNotification(EventsName.eNodeStatusChange, avatar.NodeStatusChange)
    end
    --节点内占领信息变化
    if avatar.AttackInfo then
        dump(avatar.AttackInfo, "AttackInfo")
        Notification:postNotification(EventsName.eAttackInfo, avatar.AttackInfo)
    end
    --驻守推送
    if avatar.OccupyInfo then
        -- dump(avatar.OccupyInfo, "OccupyInfo")
        Notification:postNotification(EventsName.eOccupyInfo, avatar.OccupyInfo)
    end
    --取消驻守推送
    if avatar.CancelOccupyInfo then
        -- dump(avatar.CancelOccupyInfo, "CancelOccupyInfo")
        Notification:postNotification(EventsName.eCancelOccupyInfo, avatar.CancelOccupyInfo)
    end

    -- 有队员退出队伍
    if avatar.QuitTeam then
        if avatar.QuitTeam.PlayerId ~= PlayerAttrObj:getPlayerAttrByName("PlayerId") then 
            ui.showFlashView(TR(TR("有人退出您所在的队伍！")))
        end 
        -- dump(avatar.QuitTeam, "QuitTeam")
        Notification:postNotification(EventsName.eQuitTeam, avatar.QuitTeam)
    end
    -- 有成员加入队伍（不需要队长同意自动加入队伍）
    if avatar.AddTeam then
        if avatar.AddTeam.PlayerId == PlayerAttrObj:getPlayerAttrByName("PlayerId") then 
            ui.showFlashView(TR(TR("恭喜您已加入到队伍中！")))
        else 
            ui.showFlashView(TR(TR("有成员加入到您所处的队伍中！")))
        end 
        -- dump(avatar.AddTeam, "AddTeam")
        Notification:postNotification(EventsName.eAddTeam, avatar.AddTeam)
    end
    -- 有成员加入队伍（创建队伍时队长需要同意之后的加入）
    if avatar.AgreeAddTeam then
        if avatar.AgreeAddTeam.PlayerId == PlayerAttrObj:getPlayerAttrByName("PlayerId") then 
            ui.showFlashView(TR(TR("恭喜您已加入到队伍中！")))
        else 
            ui.showFlashView(TR(TR("有成员加入到您所处的队伍中！")))
        end 
        -- dump(avatar.AgreeAddTeam, "AgreeAddTeam")
        Notification:postNotification(EventsName.eAgreeAddTeam, avatar.AgreeAddTeam)
    end
    -- 队长解散队伍
    if avatar.CancelTeam then
        if avatar.CancelTeam.Leader ~= PlayerAttrObj:getPlayerAttrByName("PlayerId") then 
            ui.showFlashView(TR(TR("队长解散了当前您所处的队伍！")))
        end 
        -- dump(avatar.CancelTeam, "CancelTeam")
        Notification:postNotification(EventsName.eCancelTeam, avatar.CancelTeam)
    end
    -- 队长转让通知
    if avatar.ReplaceLeader then
        if avatar.ReplaceLeader.NextLeader == PlayerAttrObj:getPlayerAttrByName("PlayerId") then 
            ui.showFlashView(TR(TR("您现在已经变成队长！")))
        else 
            ui.showFlashView(TR(TR("队长发生变化！")))
        end 
        -- dump(avatar.ReplaceLeader, "ReplaceLeader")
        Notification:postNotification(EventsName.eReplaceLeader, avatar.ReplaceLeader)
    end
    -- 玩家准备通知
    if avatar.PrepareTeam then
        -- dump(avatar.PrepareTeam, "PrepareTeam")
        Notification:postNotification(EventsName.ePrepareTeam, avatar.PrepareTeam)
    end
    -- 玩家取消准备通知
    if avatar.CancelPrepareTeam then
        -- dump(avatar.CancelPrepareTeam, "CancelPrepareTeam")
        Notification:postNotification(EventsName.eCancelPrepareTeam, avatar.CancelPrepareTeam)
    end
    -- 踢人通知
    if avatar.DeleteMember then
        -- dump(avatar.DeleteMember, "DeleteMember")
        if avatar.DeleteMember.DeleteMember == PlayerAttrObj:getPlayerAttrByName("PlayerId") then 
            ui.showFlashView(TR(TR("您已被队长踢出队伍！")))
        else 
            ui.showFlashView(TR(TR("有人被踢出！")))
        end 
        Notification:postNotification(EventsName.eDeleteMember, avatar.DeleteMember)
    end
    -- 收到被拒绝加入队伍的通知
    if avatar.RejectAddTeam then
        -- dump(avatar.RejectAddTeam, "RejectAddTeam")
        ui.showFlashView(TR(TR("您已被婉拒！")))
    end
    -- 加入江湖杀申请
    if avatar.BegAddTeam then
        -- dump(avatar.BegAddTeam, "avatar.BegAddTeam")
        local begData = avatar.BegAddTeam
        MsgBoxLayer.addOKCancelLayer(
            TR("[%s]%s#FF974A(战力：%s)#ffffff请求加入你的队伍，是否同意？", JianghukillJobModel.items[begData.Profession].name, begData.Name ,Utility.numberWithUnit(begData.Fap)), 
            TR("提示"),
            {
                text = TR("同 意"),
                clickAction = function(layerObj)
                    self:requestAgreeTeam(layerObj,  begData.PlayerId, true)
                end,
            },
            {
                text = TR("拒 绝"),
                clickAction = function(layerObj)
                    self:requestAgreeTeam(layerObj, begData.PlayerId, false)
                end,
            },
            nil,
            false
        )
    end

    -- 组队信息变化
    if avatar.TeamId then
        local oldTeamId = PlayerAttrObj:getPlayerAttrByName("TeamId")
        PlayerAttrObj:changeAttr({
            TeamId = avatar.TeamId
        })
        --组队id变化时清除聊天记录
        if oldTeamId ~= avatar.TeamId then
            ChatMng:deleteTeamChatInfo()
        end
    end
end

--- 添加掉落物品到缓存数据中(人物、装备、神兵、宝石、内功心法、外功秘籍)
--[[
-- 参数
    dropResData 掉落物品，其数据格式为：
    {
        BaseGetResource = { -- 基础掉落
            {
                PlayerAttr = {  -- 玩家属性(元宝、铜币、贡献...)，该函数中不解析这段数据，因为在Avarar数据中已处理
                    {
                        ResourceTypeSub:资源类型
                        Num:数量
                    },
                    ...
                },
                Goods  = {  -- 道具、人物碎片、装备碎片，该函数中不解析这段数据，因为在Avarar数据中已处理
                    {
                        ResourceTypeSub:资源类型
                        GoodsModelId:道具模型Id
                        Num:数量
                        ...
                    },
                    ...
                },
                TreasureDebris = { -- 神兵碎片，该函数中不解析这段数据，因为在Avarar数据中已处理
                    {
                        ResourceTypeSub:资源类型
                        TreasureDebrisModelId: 神兵碎片模型Id
                        Num: 数量
                    },
                    ...
                },
                Hero = {   -- 人物，该函数要解析的数据
                    {
                        Id:1,
                        ModelId:1,
                        Lv:1,
                        Step:1,
                        HP:1,
                        AP:1,
                        DEF:1
                    },
                    ...
                },
                Equip = { -- 装备，该函数要解析的数据
                    {
                        Id: 实体Id
                        EquipModelId: 模型Id
                        Lv: 强化等级
                        Gold: 强化消耗铜币
                        ExtraCount: 成功洗练次数
                        APExtra: 生命洗练
                        HPExtra: 攻击洗练
                        DEFExtra: 防御洗练
                        DAMADDExtra: 伤害加成洗练
                        DAMCUTExtra: 伤害减免洗练
                    },
                    ...
                },
                Treasure = { -- 神兵，该函数要解析的数据
                    {
                        Id: 实体Id
                        TreasureModelId: 模型Id
                        Lv: 强化等级(LV)
                        Step: 精炼等级(Step)
                        EXP: 强化积累经验
                    },
                    ...
                }
                ...
            },
        },
        ChoiceResourceList = {  -- 玩家翻牌抽取列表，该函数只解析人物、装备和神兵资源。
            ResourcetypeSub = 1101,
            ModelId:模型Id
            Num:数量
            DetailInfo = {
                -- 根据不同资源类型组织不同的详细数据，如果不是玩家抽取得到的数据，字段中没有实例Id
            }
        },
        ExtraGetResource = {  -- 额外获得的物品列表
            PlayerAttr = {  -- 玩家属性(元宝、铜币、贡献...)，该函数中不解析这段数据，因为在Avarar数据中已处理
                -- 列表：每条记录包含 资源类型 和 数量
            },
            Goods  = {  -- 道具、人物碎片、装备碎片，该函数中不解析这段数据，因为在Avarar数据中已处理
                -- 列表：每条记录包含道具、人物碎片、装备碎片的完整数据
            },
            TreasureDebris = { -- 神兵碎片，该函数中不解析这段数据，因为在Avarar数据中已处理
                -- 列表：每条记录包含神兵碎片的完整数据
            },
            Hero = {   -- 人物，该函数要解析的数据
                -- 列表：每条记录包含人物的完整数据
            },
            Equip = { -- 装备，该函数要解析的数据
                -- 列表：每条记录包含装备的完整数据
            },
            Treasure = { -- 神兵，该函数要解析的数据
                -- 列表：每条记录包含神兵的完整数据
            }
        }
    }
 ]]
function Player:addDropToResData(dropResData)
    dropResData = dropResData or {}
    --
    local function dealOneDrop(oneData)
        if oneData.Hero then    -- 掉落了人物
            for index, item in pairs(oneData.Hero) do
                HeroObj:insertHero(item, true)
            end
            HeroObj:refreshAssistCache()
        end
        if oneData.Equip then   -- 掉落了装备
            for index, item in pairs(oneData.Equip) do
                EquipObj:insertEquip(item, true)
            end
            EquipObj:refreshAssistCache()
        end
        if oneData.Treasure then   -- 掉落了神兵
            for index, item in pairs(oneData.Treasure) do
                TreasureObj:insertTreasure(item, true)
            end
            TreasureObj:refreshAssistCache()
        end
        if oneData.NewZhenJue then -- 内功心法掉落
            for index, item in pairs(oneData.NewZhenJue) do
                ZhenjueObj:insertZhenjue(item, true)
            end
            ZhenjueObj:refreshAssistCache()
        end
        if oneData.ZhenYuan then -- 真元掉落
            for index, item in pairs(oneData.ZhenYuan) do
                ZhenyuanObj:insertZhenyuan(item, true)
            end
            ZhenyuanObj:refreshAssistCache()
        end

        if oneData.Pet then -- 外功秘籍
            for index, item in pairs(oneData.Pet) do
                PetObj:insertPet(item, true)
            end
            PetObj:refreshAssistCache()
        end
        if oneData.Illusion then -- 幻化将
            for index, item in pairs(oneData.Illusion) do
                IllusionObj:insertIllusion(item)
            end
        end
        if oneData.ZhenShou then -- 珍兽
            for index, item in pairs(oneData.ZhenShou) do
                ZhenshouObj:insertZhenshou(item)
            end
        end
        if oneData.ShiZhuang then -- Q版时装
            for index, item in pairs(oneData.ShiZhuang) do
                QFashionObj:insertShizhuang(item)
            end
        end
        if oneData.Imprint then -- 宝石
            for index, item in pairs(oneData.Imprint) do
                ImprintObj:insertImprint(item)
            end
        end
    end
    -- 有基础掉落
    if dropResData.BaseGetResource then
        for index, item in pairs(dropResData.BaseGetResource) do
            dealOneDrop(item)
        end
    end
    -- 处理选择掉落
    if dropResData.ChiceResource then
        for index, item in pairs(dropResData.ChiceResource) do
            if item.IsDrop and item.DetailInfo then    -- 0:不掉落资源1:掉落资源
                local subType = item.ResourceTypeSub
                if subType == ResourcetypeSub.eHero then    -- "人物"
                    HeroObj:insertHero(item.DetailInfo)
                elseif Utility.isEquip(subType) then -- "装备"
                    EquipObj:insertEquip(item.DetailInfo)
                elseif Utility.isTreasure(subType) then   -- "兵书" 和 “徽章”
                    TreasureObj:insertTreasure(item.DetailInfo)
                elseif subType == ResourcetypeSub.eNewZhenJue then -- 内功心法
                    ZhenjueObj:insertZhenjue(item.DetailInfo, true)
                elseif subType == ResourcetypeSub.eZhenYuan then -- 真元
                    ZhenyuanObj:insertZhenyuan(item.DetailInfo, true)
                elseif subType == ResourcetypeSub.ePet then -- 外功秘籍
                    PetObj:insertPet(item.DetailInfo)
                end
            end
        end
    end
    -- 处理额外掉落
    if dropResData.ExtraGetResource then
        dealOneDrop(dropResData.ExtraGetResource)
    end
end

--- 更新初始化数据
function Player:updateInitData(initData)
    initData = initData or {}
    -- 玩家数据
    if initData.PlayerInfo then
        self.mIsLogin = true
        PlayerAttrObj:updatePlayerInfo(initData.PlayerInfo)

        -- 帮派Id改变 或 帮派名称
        if initData.PlayerInfo.GuildId or initData.PlayerInfo.GuildName then
            GuildObj:updateGuildAvatar({Id = initData.PlayerInfo.GuildId, Name = initData.PlayerInfo.GuildName})
        end

        -- 修改大侠之路的状态
        RoadOfHeroObj:setCurrTask(initData.PlayerInfo)
    end
    -- 人物数据列表
    if (initData.HeroInfo) then
        HeroObj:setHeroList(initData.HeroInfo)
    end
    -- 幻化数据列表
    if initData.IllusionInfo then 
        IllusionObj:setIllusionList(initData.IllusionInfo)
    end 
    -- 装备数据列表
    if (initData.EquipInfo) then
        EquipObj:setEquipList(initData.EquipInfo)
    end
    -- 神兵数据列表
    if (initData.TreasureInfo) then
        TreasureObj:setTreasureList(initData.TreasureInfo)
    end
    -- 玩家阵容信息、布阵信息、江湖后援团信息
    if initData.SlotInfo or initData.MateInfo or initData.SlotFormationInfo then
        FormationObj:setFormation(initData.SlotInfo, initData.MateInfo, initData.SlotFormationInfo, initData.PetFormationInfo)
    end
    -- 人物碎片、装备碎片、道具、...
    if initData.GoodsHeroDebrisInfo or initData.GoodsZhenjueDebrisInfo 
        or initData.GoodsPropsInfo or initData.GoodsPetDebrisInfo 
        or initData.GoodsEquipDebrisInfo or initData.GoodsQuenchInfo
        or initData.GoodsFashionDebrisInfo or initData.GoodsIllusionDebrisInfo 
        or initData.GoodsZhenshouDebrisInfo then

        local tempInfo = {}
        tempInfo.PropsInfo = initData.GoodsPropsInfo           -- 道具
        tempInfo.HeroDebrisInfo = initData.GoodsHeroDebrisInfo -- 人物碎片
        tempInfo.ZhenjueDebrisInfo = initData.GoodsZhenjueDebrisInfo -- 内功碎片
        tempInfo.PetDebrisInfo = initData.GoodsPetDebrisInfo -- 外功碎片
        tempInfo.EquipDebrisInfo = initData.GoodsEquipDebrisInfo --装备碎片
        tempInfo.GoodsQuenchInfo = initData.GoodsQuenchInfo --炼丹相关道具
        tempInfo.GoodsFashionDebrisInfo = initData.GoodsFashionDebrisInfo --时装碎片相关道具
        tempInfo.GoodsIllusionDebrisInfo = initData.GoodsIllusionDebrisInfo --幻化碎片相关道具
        tempInfo.GoodsZhenshouDebrisInfo = initData.GoodsZhenshouDebrisInfo --珍兽碎片相关道具
        tempInfo.GoodsShizhuangDebrisInfo = initData.GoodsShizhuangDebrisInfo --Q版时装碎片相关道具
        GoodsObj:setGoodsList(tempInfo)
    end

    -- 宝石
    if initData.ImprintInfo then
        ImprintObj:setImprintList(initData.ImprintInfo)
    end

    --Q版时装
    if initData.ShiZhuangInfo then
        QFashionObj:updateFashionList(initData.ShiZhuangInfo)
    end

    --珍兽
    if initData.ZhenShouInfo then
        ZhenshouObj:setZhenshouList(initData.ZhenShouInfo)
    end

    if initData.ZhenShouSlotInfo then
        ZhenshouSlotObj:setZhenshouSlot(initData.ZhenShouSlotInfo)
    end
    -- 神兵碎片
    if initData.TreasureDebrisInfo then
        TreasureDebrisObj:setTreasureDebrisList(initData.TreasureDebrisInfo)
    end

    -- 背包信息
    if initData.BagInfo then
        BagInfoObj:setBagInfo(initData.BagInfo)
    end

    -- 模块信息
    if initData.ModulesInfo then
        ModuleInfoObj:updateModuleInfo(initData.ModulesInfo)
    end

    -- 寻玉次数信息
    if initData.XYCurCount then
        PlayerAttrObj:setXYCurCount(initData.XYCurCount)
    end

    -- 好友信息
    if initData.FriendInfo then
        FriendObj:setFriendList(initData.FriendInfo)
    end

    -- 内功心法信息
    if initData.ZhenjueInfo then
        ZhenjueObj:setZhenjueList(initData.ZhenjueInfo)
    end

    -- 真元列表
    if (initData.ZhenYuanInfo) then
        ZhenyuanObj:setZhenyuanList(initData.ZhenYuanInfo)
    end
    
    -- 外功秘籍信息
    if initData.PetInfo then
        PetObj:setPetList(initData.PetInfo)
    end

    -- 微信红包信息
    if initData.RedBag then
        --dump(initData.RedBag, "initData.RedBag:")
        PlayerAttrObj:setRedBagInfo(initData.RedBag)
    end

    if initData.ExpeditionGuajiStatus then
        -- 获取挂机信息
        ExpediGuaJiObj:setIsGuaJi(initData.ExpeditionGuajiStatus)
        Notification:postNotification(EventsName.eExpeditionGuaJi)
    end
    
    self.mDataIsInitiated = true
end

-- 获取数据是否已初始化
function Player:dataIsInitiated()
    return self.mDataIsInitiated
end

--- ========================== 服务器时间相关信息 =====================
--- 保持客服端与游戏服务器时间同步。
function Player:updateTimeTick(timeTick)
    local oldTime = self.mTimeTick
    self.mTimeTick = timeTick   -- 全局计时变量
    self.mRefreshCount = 0 -- 定时刷新计时，当重新请求服务器接口后，该计时清零(即重新开始计时)，这里不能用局部变量，因为局部变量会与scheduleGlobal函数形成闭包，导致不能清零

    local function checkRereshNewTimed(oldTime, newTime)
        local isSecondDay = not MqTime.isSameDay(oldTime, newTime)
        if isSecondDay  then
            local activeInfo = ActivityObj:getActivityInfo()
            if table.nums(activeInfo or {}) > 0 then
                ActivityObj:refreshNewActivity()
            end
        end
    end
    checkRereshNewTimed(oldTime, self.mTimeTick)

    -- 同步服务器avatar数据检测
    local function syncAvatarInfoCheck()
        local playerInfo = PlayerAttrObj:getPlayerInfo()
        if not playerInfo.VITNextRecoverTime then
            return
        end

        -- 检查倒计时到期的情况
        local VITNextTime = playerInfo.VITNextRecoverTime - self.mTimeTick -- 下次体力恢复剩余时间
        local STANextTime = playerInfo.STANextRecoverTime - self.mTimeTick -- 下次耐力恢复剩余时间
        local VITMax = VitConfig.items[1] and VitConfig.items[1].maxNum  or 150  -- 体力上限是由配置表固定的，不会随其他属性而增长

        if (VITNextTime <= 0 and playerInfo.VIT < VITMax) or  -- 体力未回复满并且下一次回复时间已到
                (STANextTime <= 0 and playerInfo.STA < playerInfo.STAMaxNum) or -- 耐力未回复满并且下一次回复时间已到
                (self.mRefreshCount > 60) then   -- 暂时定为60秒刷新一次

            if VITNextTime <= 0 and playerInfo.VIT < VITMax then
                local VITRecoverCD = VitConfig.items[1] and VitConfig.items[1].recoverCD  or 360
                playerInfo.VITNextRecoverTime = self.mTimeTick + VITRecoverCD
            elseif STANextTime <= 0 and playerInfo.STA < playerInfo.STAMaxNum then
                local STARecoverCD = StaConfig.items[1] and StaConfig.items[1].recoverCD or 900
                playerInfo.STANextRecoverTime = self.mTimeTick + STARecoverCD
            end

            self.mRefreshCount = 0
            -- 同步客服端和服务器的Avatar信息
            Utility.syncAvatarData()
        end
    end

    -- 判断是否新的一天到来
    local function checkIsNewDay()
        local timeDate = os.date("*t", self.mTimeTick)
        if (self.currDay ~= nil) and (self.currDay ~= timeDate.day) then
            -- 发送通知
            Notification:postNotification(EventsName.eNewDayCome)
        end
        self.currDay = timeDate.day
    end

    if not self.mScheduleHandle and self.mIsLogin then
        -- 版本设置是否支持语音，
        local IsSupportVoice = IPlatform:getInstance():getConfigItem("IsSupportVoice") == "1"

        local tempSchedule = cc.Director:getInstance():getScheduler()
        self.mScheduleHandle = tempSchedule:scheduleScriptFunc(function(delay)
            checkIsNewDay()
            self.mTimeTick = self.mTimeTick + delay
            self.mRefreshCount = self.mRefreshCount + delay

            checkRereshNewTimed(self.mTimeTick - delay, self.mTimeTick)
            syncAvatarInfoCheck() -- 同步服务器avatar数据检测

            -- 检测背景音乐是否播放完成，自动下一曲
            LayerManager.nextCurrentMusic()

            -- 该版本支持语音，如果语音sdk已经初始化，则需要循环调用 CloudVoice Poll
            if IsSupportVoice then
                require("Chat.CloudVoiceMng")
                if CloudVoiceMng:isInitialized() then
                    CloudVoiceMng:Poll()
                end
            end
        end, 0.5, false)
    end
end

--- 返回当前时间(根据服务器时间进行的计时)
function Player:getCurrentTime()
    return self.mTimeTick
end

--- 返回当前日期(来自服务器)
--[[
{
    [hour]      0~24
    [min]       0~59
    [wday]      1~7  星期天为1
    [day]       1~31
    [month]     1~12
    [year]      2014年
    [sec]       0~59
    [yday]      1~366
    [isdst]
}
--]]
function Player:getServerDate()
    return os.date("*t", self.mTimeTick or 0)
end

--- 获取当前是否是夜间
function Player:getTimeIsNight()
    local tempHour = self:getServerDate().hour or 0
    return tempHour < 6 or tempHour >= 22
end

--- 提供一个卸载定时器的方法，可选使用
function Player:unInstallTimer()
    if self.mScheduleHandle then
        local tempHandle = self.mScheduleHandle
        self.mScheduleHandle = nil
        local tempSchedule = cc.Director:getInstance():getScheduler()
        tempSchedule:unscheduleScriptEntry(tempHandle)
    end
end

function Player:getBlacklist()
    self.mBlackList = self.mBlackList or {}
    return self.mBlackList
end

function Player:setBlackList(blackList)
    self.mBlackList = blackList
end

--判断玩家是否在黑名单中
function Player:isPlayerInBlackList(playerId)
    local inBlackList, index = false, 0

    if self.mBlackList then
        for k,v in pairs(self.mBlackList) do
            if v.PlayerId == playerId then
                inBlackList = true
                index = k
                break
            end
        end
    end
    return inBlackList, index
end

-- 江湖杀队长收到申请通知
function Player:requestAgreeTeam(obj, playerId, isAgree)
    HttpClient:request({
        moduleName = "JianghuKillTeamHall",
        methodName = "AgreeAddTeam",
        svrMethodData = {playerId, isAgree},
        callbackNode = obj,
        callback = function(response)
            -- 容错处理
            if response.Status ~= 0 then
                return
            end
            obj:removeFromParent()
        end
    })
end

-- 保存游戏临时数据
function Player:saveGameData(key, value)
    self.mGameCache[key] = value
end

-- 读取游戏临时数据
function Player:getGameData(key)
    return self.mGameCache[key]
end