--[[
    文件名：Notification.lua
    描述：自定义消息分发类，用于控制控件数据的自动更新
    创建人：heguanghui
    创建时间：2015.4.13
-- ]]

-- 消息通知类
Notification = {
    -- 消息通知保存
    mNotifyTable = {},
}

-- 事件通知的名称
EventsName = {
    eTimeTick           = "eTimeTick",      -- 每隔时间间隔通知事件名（游戏中使用 schedule 的地方都可以使用这个事件）
    eNewDayCome         = "eNewDayCome",    -- 新的一天到来事件（游戏中需要在0点刷新的地方可以使用这个时间）
    eHeadImageId        = "eHeadImageId",   -- 玩家头像使用的哪个人物资源的人物模型Id
    ePlayerName         = "ePlayerName",    -- 玩家昵称
    eLv                 = "eLv",            -- 玩家等级
    eFAP                = "eFAP",           -- 战斗力
    eVip                = "eVip",           -- Vip等级
    eVITNextRecoverTime = "eVITNextRecoverTime",    -- 下次体力恢复时间戳
    eSTAMaxNum          = "eSTAMaxNum",             -- 耐力上限
    eSTANextRecoverTime = "eSTANextRecoverTime",    -- 下次耐力恢复时间戳
    eIfCharge           = "eIfCharge",  -- 是否已首冲
    -- 玩家属性
    eEXP                = "eEXP",       -- "经验值"
    eVIT                = "eVIT",       -- "体力值"
    eSTA                = "eSTA",       -- "耐力值"
    eVipEXP             = "eVipEXP",    -- "Vip经验"
    eDiamond            = "eDiamond",   -- "元宝"
    eGold               = "eGold",      -- "铜币"
    eContribution       = "eContribution", -- "贡献"
    ePVPCoin            = "ePVPCoin",   -- "声望"
    eHeroCoin           = "eHeroCoin",  -- "精元"
    eHeroEXP            = "eHeroEXP",   -- "将魂"
    eGDDHCoin           = "eGDDHCoin",  -- "豪侠令"
    eBossCoin           = "eBossCoin",  -- "Boss积分"
    eMerit              = "eMerit",         -- 战功
    eHonor              = "eHonor",            -- "荣誉"
    eRedBagFund         = "eRedBagFund",       -- "红包基金"
    ePetEXP             = "ePetEXP",           -- "兽魂"
    ePetCoin            = "ePetCoin",          -- "兽币"
    eGodDomainGlory     = "eGodDomainGlory",    -- "神域争霸荣誉点"
    eMerit              = "eMerit",   -- 青天令
    eTaoZhuangCoin      = "eTaoZhuangCoin",   -- 神域争霸荣誉点
    eMedicineCoin       = "eMedicineCoin",   -- 药元
    eLoveFlower         = "eLoveFlower",   -- 情花
    eGuildGongfuCoin    = "eGuildGongfuCoin",   -- 帮派武技
    eYinQi              = "eYinQi",   -- 阴气
    eYangQi             = "eYangQi",   -- 阳气
    eXieQi              = "eXieQi",   -- 邪气
    eHonorCoin          = "eHonorCoin",   -- 江湖杀荣誉点
    eZslyCoin           = "eZslyCoin",   -- 兽魂
    eZhenshouExp        = "eZhenshouExp",   -- 兽粮
    eZhenshouCoin       = "eZhenshouCoin",   -- 珍兽精华

    -- 玩家属性
    eZBCoin             = "eZBCoin",    -- "卡牌碎片"
    eStarId             = "eStarId",    -- 玩家点星节点Id
    eAppErrorLevel      = "eAppErrorLevel", -- 服务器收集客户端调试信息的等级
    eGuildId            = "eGuildId",           --
    eMarqueeInterval    = "eMarqueeInterval",   --
    eXYCurCount         = "eXYCurCount",    -- 寻玉次数
    eTowerCount         = "eTowerCount",    -- 妖灵塔的层数
    eExtraNum           = "eExtraNum",      -- 阵决洗练铜币次数 dxj
    eHasDrawSuccessReward  = "eHasDrawSuccessReward",  --七日大奖是否领取
    eSvipState          = "eSvipState", -- VIP贵宾状态（0：非；1：是；2：绑定QQ）
    eMonthCardExpireTime = "eMonthCardExpireTime",   --月卡过期时间
    eIfDisableSendMsg    = "eIfDisableSendMsg",      -- 是否需要禁止玩家聊天
    eIsZhiZunFirstCharge = "eIsZhiZunFirstCharge", -- 是否显示首充
    eOpencontestState   = "eOpencontestState", -- 开服比拼
    eTriggerLv          = "eTriggerLv",  -- 当前触发限时赏金等级
    eIsTriggerReceived  = "eIsTriggerReceived", -- 是否已领取限时赏金奖励 用于最后一次领取
    eIsFirstTriggerLv   = "eIsFirstTriggerLv", -- 是否是第一次触发限时任务
    eLvChanged          = "eLvChanged", -- 等级已变化，开启升级
    eSlotAttrChanged    = "eSlotAttrChanged", -- 卡槽属性存在变化

    -- 小红点相关事件名称的前缀，由于小红点事件与模块Id相关，具体有哪些需要根据配置表确定，
    -- 所以事件名称的格式为 "eRedDot"+模块Id， 如：“eRedDot1100”（人物模块的小红点）
    eRedDotPrefix = "eRedDot",
    -- new本地事件的统一处理前缀, 格式为 "eNewPrefix" + 模块ID
    eNewPrefix = "eNewPrefix",
    -- socket推送统一处理前缀，格式为 "eSocketPushPrefix" + 模块ID
    eSocketPushPrefix = "eSocketPushPrefix",

    -- 队伍卡槽小红点相关事件名称的前缀，格式为 “eSlotRedDot” + SlotId, 如：“eSlotRedDot1” (队伍第一个卡槽的小红点)
    eSlotRedDotPrefix = "eSlotRedDot",
    -- 道具数量改变小红点相关事件名称的前缀， 格式为 “ePropRedDot” + ModelId, 如："ePropRedDot16050003" (召唤符改变的小红点)
    ePropRedDotPrefix = "ePropRedDot",
    -- 副本章节缓存数据修改事件名称前缀, 格式为 "eBattleChapter" + 章节模型Id， 如: "eBattleChapter11"
    eBattleChapterPrefix = "eBattleChapter",
    -- 副本节点缓存数据修改事件名称前缀，格式为 "eBattleNode" + 节点模型Id， 如: "eBattleNode1111"
    eBattleNodePrefix = "eBattleNode",
    -- 神兵碎片数量改变小红点相关事件名称的前缀， 格式为 “eTreasureDebrisRedDot” + ModelId, 如："eTreasureDebrisRedDot15040101" (召唤符改变的小红点)
    eTreasureDebrisRedDotPrefix = "eTreasureDebrisRedDot",
    -- 人物碎片数量改变小红点相关事件名称的前缀，格式为 "eHeroDebrisRedDot" + ModelId, 如： “eHeroDebrisRedDot15011301”
    eHeroDebrisRedDotPrefix = "eHeroDebrisRedDot",

    -- 阵容装备列表的加号变化事件
    eSlotEquipNodeAddFlagVisible = "eSlotEquipNodeAddFlagVisible",
    -- 刷新帮派大厅小红点的事件名称
    eGuildHomeAll = "eGuildHomeAllRedDot",
    -- 副本战役信息缓存数据修改事件名称
    eBattleInfo = "BattleInfo",
    -- 八大门派的变化事件
    eSectHomeAll = "eSectHomeAllRedDot",

    -- 好友数据改变的事件通知
    eFriendChanged = "eFriendChanged",

    -- 有新的聊天消息
    eChatNewMsg = "eChatNewMsg",
    -- 频道聊天信息改变事件名称前缀，格式为 “eChatMsgChange” + 聊天频道Id，如：“eChatMsgChange11”
    eChatMsgChangePrefix = "eChatMsgChange",
    -- 未读聊天信息改变的事件名称前缀，格式为 “eChatUnread” + 聊天频道Id，如：“eChatUnread11”
    eChatUnreadPrefix = "eChatUnread",
    -- 私聊玩家列表改变的事件通知
    eChatPrivateChanged = "eChatPrivateChanged",

    -- ============= GCloudVoice 相关消息 ==========
    -- 加入房间成功的事件名前缀，格式为 "eVoiceJoinRoomSucc" + 房间名称 如: "eVoiceJoinRoomSuccRoomName"
    eVoiceJoinRoomSuccPrefix = "eVoiceJoinRoomSucc",
    -- 加入房间失败的事件名前缀，格式为 "eVoiceJoinRoomFaild" + 房间名称 如: "eVoiceJoinRoomFaildRoomName"
    eVoiceJoinRoomFaildPrefix = "eVoiceJoinRoomFaild",
    -- 离开房间的事件名名前缀，格式为 "eVoiceQuitRoom" + 房间名称 如: "eVoiceQuitRoomRoomName"
    eVoiceQuitRoomPrefix = "eVoiceQuitRoom",
    -- 成员说话状态改变的通知
    eVoiceMemberStatusChange = "eVoiceMemberStatusChange",

    --- 用于消息通知的语音Id是 skd生成的 voiceId md5编码的值，即：string.md5Content(voiceId)
    -- 播放语音消息开始的事件名称前缀，格式为"eVoicePlayBegin" + 语音Id或语音文件名：如: "eVoicePlayBegin1111.spx"
    eVoicePlayBeginPrefix = "eVoicePlayBegin",
    -- 播放语音消息结束的事件名称前缀，格式为"eVoicePlayEnd" + 语音Id或语音文件名 如: "eVoicePlayEnd1111.spx"
    eVoicePlayEndPrefix = "eVoicePlayEnd",
    -- 语音是否已播放状态改变的事件名前缀，格式为 "eVoiceIsPlayed" + 语音Id或语音文件名，如："eVoiceIsPlayed1111.spx"
    eVoiceIsPlayedPrefix = "eVoiceIsPlayed",
    -- 终止播放语音的消息
    eVoiceStopPlay = "eVoiceStopPlay",

    -- 语音异步任务返回的事件名, 改类型的通知中会携带数据
    eVoiceAsyncTaskReturn = "eVoiceAsyncTaskReturn",
    -- 获取语音消息安全密钥key信息返回的事件名
    eVoiceApplyMessageKeyReturn = "eVoiceApplyMessageKeyReturn",

    ---------------------- 组队副本3.0----------------------
    eExpeditionPrefix = "eExpedition",     -- 队伍信息变化
    eExpeditionFightResultPrefix = "eExpeditionFightResult", -- 组队战斗数据
    eSureStartFight = "eSureStartFight",   -- 确认连战
    eInviteInfoNewPrefix = "eInviteInfoNewPrefix",  -- 组队邀请状态
    eExpeditionGuaJi = "eExpeditionGuaJi", -- 光明顶挂机  

    -----------------------桃花岛-----------------
    eShengyuanTeam = "eShengyuanTeam", -- 帮派组队时好友变化
    eShengyuanMatch = "eShengyuanMatch",-- 队长发起开始匹配通知
    eShengyuanWarsInvite = "eShengyuanWarsInvite",-- 接受到好友桃花岛组队的邀请

    -----------------------帮派战-----------------
    eGuildBattleScore = "eGuildBattleScore", -- 帮派战的积分发生变化
    
    ---------------------- 界面通知 ----------------------
    -- 界面通知前缀，格式为 "eBattleNode" + 界面名， 如: "eGameLayerPrefixbag.BagLayer"
    eGameLayerPrefix = "eGameLayerPrefix",
    ---------------------- 门派boss ----------------------
    eBossHpChanged = "eBossHpChanged", -- boss血量改变

    eRoadOfHeroStateChanged = "eRoadOfHeroStateChanged", -- 大侠之路
    ---------------------- 江湖杀 ----------------------
    eBeginMove = "eBeginMove",  --开始移动
    eArriveNode = "eArriveNode",  --结束移动
    eNodeStatusChange = "NodeStatusChange", --节点信息变化
    eAttackInfo = "AttackInfo", --节点内占领信息变化
    eOccupyInfo = "OccupyInfo",   --驻守推送
    eCancelOccupyInfo = "CancelOccupyInfo",  --取消驻守推送
    eQuitTeam = "eQuitTeam",   -- 有队员退出队伍
    eAddTeam = "eAddTeam",   -- 有成员加入队伍（不需要队长同意自动加入队伍）
    eCancelTeam = "eCancelTeam",   -- 队长解散队伍
    eAgreeAddTeam = "eAgreeAddTeam",   -- 有成员加入队伍（创建队伍时队长需要同意之后的加入）
    eReplaceLeader = "eReplaceLeader",   -- 队长转让通知
    eDeleteMember = "eDeleteMember",    -- 踢人通知
    ePrepareTeam = "ePrepareTeam",   -- 有玩家准备的通知
    eCancelPrepareTeam = "eCancelPrepareTeam", -- -- 有玩家取消准备的通知
    eCreateTeam = "eCreateTeam"  --创建队伍(前端事件）
}

-- 根据资源类型Id获取事件名称
function EventsName.getNameByResType(resourcetypeSub)
    local tempList = {
        [ResourcetypeSub.eEXP] = EventsName.eEXP,    -- "經驗值"
        [ResourcetypeSub.eVIT] = EventsName.eVIT,    -- "體力值"
        [ResourcetypeSub.eSTA] = EventsName.eSTA,    -- "耐力值"
        [ResourcetypeSub.eVIPEXP] = EventsName.eVipEXP,    -- "VIP經驗值"
        [ResourcetypeSub.eDiamond] = EventsName.eDiamond,    -- "鑽石"
        [ResourcetypeSub.eGold] = EventsName.eGold,    -- "金幣"
        [ResourcetypeSub.eContribution] = EventsName.eContribution,    -- "貢獻"
        [ResourcetypeSub.ePVPCoin] = EventsName.ePVPCoin,    -- "聲望"
        [ResourcetypeSub.eHeroCoin] = EventsName.eHeroCoin,    -- "宝贝果实"
        [ResourcetypeSub.eHeroExp] = EventsName.eHeroEXP,    -- "神奇晶核"
        [ResourcetypeSub.eGDDHCoin] = EventsName.eGDDHCoin,    -- "武勳"
        [ResourcetypeSub.eBossCoin] = EventsName.eBossCoin,    -- "積分"
        [ResourcetypeSub.eMerit] = EventsName.eMerit,    -- "戰功"
        [ResourcetypeSub.eHonor] = EventsName.eHonor,            -- "荣誉"
        [ResourcetypeSub.eRedBagFund] = EventsName.eRedBagFund, -- "红包基金"
        [ResourcetypeSub.ePetEXP] = EventsName.ePetEXP,           -- "兽魂"
        [ResourcetypeSub.ePetCoin] = EventsName.ePetCoin,          -- "兽币"
        [ResourcetypeSub.eGodDomainGlory] = EventsName.eGodDomainGlory,    -- "神域争霸荣誉点"
        [ResourcetypeSub.eMerit] = EventsName.eMerit,   -- 青天令
        [ResourcetypeSub.eTaoZhuangCoin] = EventsName.eTaoZhuangCoin,   -- 神域争霸荣誉点
        [ResourcetypeSub.eMedicineCoin] = EventsName.eMedicineCoin,   -- 药元
        [ResourcetypeSub.eLoveFlower] = EventsName.eLoveFlower,   -- 情花
        [ResourcetypeSub.eGuildGongfuCoin] = EventsName.eGuildGongfuCoin,   -- 帮派武技
        [ResourcetypeSub.eYinQi] = EventsName.eYinQi,   -- 阴气
        [ResourcetypeSub.eYangQi] = EventsName.eYangQi,   -- 阳气
        [ResourcetypeSub.eXieQi] = EventsName.eXieQi,   -- 邪气
        [ResourcetypeSub.eHonorCoin] = EventsName.eHonorCoin,   -- 江湖杀荣誉点
        [ResourcetypeSub.eZslyCoin] = EventsName.eZslyCoin,   -- 兽魂
        [ResourcetypeSub.eZhenshouExp] = EventsName.eZhenshouExp,   -- 兽粮
        [ResourcetypeSub.eZhenshouCoin] = EventsName.eZhenshouCoin,   -- 珍兽精华
    }

    return tempList[resourcetypeSub] or ""
end

--[[
    params:
    node: 绑定的结点, 不能设置为Layer中的self变量
    notifyFunc: 事件回调函数
    nameList: 事件名或者是事件列表
--]]
function Notification:registerAutoObserver(node, notifyFunc, nameList)
    local function registerOneObserver(name)
        --查找是否存在此name
        if not self.mNotifyTable[name] then
            self.mNotifyTable[name] = {}
        end

        -- 不能对相同node注册相同的事件
        for i,v in ipairs(self.mNotifyTable[name]) do
            if v.node == node then
                return
            end
        end
        table.insert(self.mNotifyTable[name], {node=node, func=notifyFunc})
    end

    if type(nameList) == "table" then
        for _, name in ipairs(nameList) do
            registerOneObserver(name)
        end
    else
        registerOneObserver(nameList)
    end

    -- 添加自动删除事件
    node:registerScriptHandler(function(eventType)
        if eventType == "cleanup" then
--        if eventType == "exit" then
            if type(nameList) == "table" then
                for _, name in ipairs(nameList) do
                    self:unregisterObserver(node, name)
                end
            else
                self:unregisterObserver(node, nameList)
            end
        end
    end)
end

function Notification:unregisterObserver(node, name)
    if self.mNotifyTable[name] then
        -- 移除事件对应的node
        for i,v in ipairs(self.mNotifyTable[name]) do
            if node == v.node then
                table.remove(self.mNotifyTable[name], i)
                break
            end
        end
    end
end

--[[
    参数: 
        name:可以是字符串,也可以是字符串列表
        data: 推送消息的数据
    返回值: 
    说明: 
--]]
function Notification:postNotification(name, data)
    if not name then
        printError("Warning: event name not found!")
        return
    end
    local function _postNotification(_name)
        if self.mNotifyTable[_name] then
            -- 调用注册的函数
            for i, v in ipairs(self.mNotifyTable[_name]) do
                if not tolua.isnull(v.node) then
                    v.func(v.node, data)
                end
            end
        end
    end
    
    if type(name) == "table" then
        for i, tmpName in ipairs(name) do
             _postNotification(tmpName)
        end
    else
        _postNotification(name)
    end
end

function Notification:clean()
    -- 清空所有通知消息
    self.mNotifyTable = {}
end
