--[[
文件名:CacheGuild.lua
描述：帮派数据抽象类型
创建人：liaoyuangang
创建时间：2016.05.09
--]]

-- 帮派数据说明
--[[
-- 服务器返回帮派数据格式为
	{
	    IsEnterGuild:改变的帮派加入退出状态枚举(1:加入帮派 2:自己退出帮派 3:被踢出帮派 4:帮派解散) 状态改变时在Avatar里返回此字段
	    PlayerGuildInfo:玩家的帮派信息
	    {
	        FundTotal:个人累计贡献
	        IfCanBuildTime:今日是否可以建设
	        IfCanShare:今日是否可以共享佣兵
	        PostId:职位
	    }
	    GuildInfo:帮派信息
	    {
	        Id:社团Id
	        Name:社团名称
	        Lv:社团等级
	        GuildFund:帮派资金
	        GuildFundTotal:帮派累计资金
	        GuildFundWeek:每周帮派累计资金
	        Notice:公告
	        GuildBuildCount:每日累计建设次数
	        LeaderName:帮派会长名称
	        MemberCount:成员数量
	        RandNum:帮派排名
	        IsAutoApply:是否免审核
	    }
	    GuildBuildInfo:帮派建筑信息(可以升级的建筑)
	    {
            {
                BuildingId:建筑ID
                Lv:建筑等级
            }
            ...
	    }
	    GlobalGuildNewsInfo:新帮派信息
	    {
	        Id:信息ID
	        Content:内容
	    }
	    GlobalGuildRedInfo
	    {
	        ApplyList:申请列表
	        PostLack:成员职务空缺
	        BuildingLv:建筑升级
	    }
        GuildBookInfo
        {
            GuildBook:帮派已解锁秘籍信息
        }
	}
]]

-- 帮派Avatar数据说明
--[[
-- 服务器返回帮派Avatar数据格式为
    {
        Id: 帮派Id
        Name: 帮派名称
        Fund:帮派资金
        FundTotal:累计资金
        MemberCount:成员数量
        GuildBuildCount:每日累计建设次数
        PostId:职位更改
        Notice:公告
        Declaration:宣言
        BuildLv:帮派升级信息
        {
            {建筑Id, 建筑等级}
        }
        GuildNews:帮派信息
        {
            {Id, Content}
        }
        GuildBookInfo:帮派已解锁秘籍信息
        IfApplyList:是否有申请列表
        IfPostLack:是否有成员职务空缺
        IfBuildingLv:是否有建筑升级
    }
]]

-- 帮派战数据说明
--[[
-- 服务器返回帮派数据格式为
    {
    IsFightDay：是否是战斗日
    IsMatchSuccess:是否匹配成功
    IsEnrollEndTime:报名结束时间
    IsEnroll：是否报名
    PlayerGuildBattleInfo:玩家帮派战信息（战斗日，匹配成功则有些消息）
    {
        ChallengeNum : 挑战次数
        RollingNum : 辗压次数
        TotalScore:赛季总积分
        BattleNodeIdStr : 已挑战节点
        [
        ]
    }
    GuildBattleSeasonInfo:帮派战赛季信息
    {
        Season:赛季数
        BeginDate:开始时间
        EndDate:结束时间
    }
    GuildBattleGuildInfo:帮派战信息
    {
        Score：当前积分
        TotalScore：当前赛季总积分
        BattleInfo：节点挑战信息
    }
    GuildBattlePlayerInfo:帮派战玩家信息
    [
        {
            Order：序号
            Id：玩家Id
            Name：玩家名
            Lv：等级
            Vip：vip等级
            HeadImageId：头像
            FAP：战力
            PVPInterLv：
            DesignationId：
            FashionModelId：时装
        }....
    ]
    MatchGuildInfo:战斗日匹配帮派信息（战斗日，匹配成功则有具体内容）
    {
        GuildId:帮派Id
        GuildName:帮派名称
        Lv:等级
        ServerId:区服Id
        Zone:区服名
        Score:当前积分
        TotalScore:赛季总积分
    }
    MatchGuildBattlePlayerInfo:帮派战玩家信息(对方)
    [
        {
            Order：序号
            Id：玩家Id
            Name：玩家名
            Lv：等级
            Vip：vip等级
            HeadImageId：头像
            FAP：战力
            FashionModelId：时装
            Star:被攻击的星数
        }....
    ]
}
]]

local CacheGuild = class("CacheGuild", {})

function CacheGuild:ctor()
    -- 重置帮派缓存对象 
    self:reset()
end

-- 重置帮派缓存对象
function CacheGuild:reset()
    -- 帮派信息
	self.mGuildInfo = {}
    -- 玩家的帮派信息
    self.mPlayerGuildInfo = {}
    -- 帮派建筑信息(可以升级的建筑)
    self.mGuildBuildInfo = {}
    -- 帮派小红点心信息
    self.mGlobalGuildRedInfo = {}
    -- 新帮派信息
    self.mGlobalGuildNewsInfo = {}
    -- 帮派战数据
    self.mGuildBattleInfo = {}
    -- 帮派秘籍
    self.mGuildBookInfo = {}
end

-- IsEnterGuild:改变的帮派加入退出状态枚举(1:加入帮派 2:自己退出帮派 3:被踢出帮派 4:帮派解散)
function CacheGuild:changeIsEnter(IsEnter)
	self.mGuildInfo.IsEnterGuild = IsEnter
end

-- 改变的帮派加入退出状态
function CacheGuild:changeEnterGuildInfo(enterGuildInfo)
    -- 退出帮派的提示
    local function quitGuildMsg(msgText)
        local layerName = LayerManager.getTopCleanLayerName()
        local okBtnInfo = {
            text = TR("确定"),
            clickAction = function(msgLayer, btnObj)
                if string.sub(layerName, 1, 11) == "guild.Guild" then
                    LayerManager.addLayer({name = "home.HomeLayer"})
                else
                    LayerManager.removeLayer(msgLayer)
                end
            end
        }
        MsgBoxLayer.addOKLayer(msgText, TR("提示"), {okBtnInfo}, nil)
    end

    local enterState = enterGuildInfo["0"]
    if enterState == 1 then -- 成功加入, 代表加入了帮派但是服务端没有传具体加入的哪个帮派
        self.mGuildInfo.Id = "00000000-0000-0000-0000-000000000012"  
        self.mGuildInfo.Name = enterGuildInfo["1"]
    elseif enterState == 2 then -- 自己退出帮派
        self.mGuildInfo.Id = EMPTY_ENTITY_ID
        self.mGuildInfo.Name = ""
    elseif enterState == 3 then  -- 被踢出帮派
        self.mGuildInfo.Id = EMPTY_ENTITY_ID
        self.mGuildInfo.Name = ""
        -- 提示玩家
        quitGuildMsg(TR("您已被请出了帮派！"))
    elseif enterState == 4 then  -- 帮派解散
       self.mGuildInfo.Id = EMPTY_ENTITY_ID
        self.mGuildInfo.Name = ""
        -- 提示玩家
        quitGuildMsg(TR("你所在的帮派已经解散"))
    end
end

function CacheGuild:changeGuildName(guildName)
    self.mGuildInfo.Name = guildName or ""
end

-- 设置帮派缓存数据
--[[
-- 参数 guildData 中的各项参考文件头处的 “帮派数据说明”
]]
function CacheGuild:updateGuildInfo(guildData)
    guildData = guildData or {}
    -- 帮派信息
    if guildData.GuildInfo ~= nil then
        self.mGuildInfo = guildData.GuildInfo
    end
    -- 玩家的帮派信息
    if guildData.PlayerGuildInfo ~= nil then
        self.mPlayerGuildInfo = guildData.PlayerGuildInfo
    end
    -- 帮派建筑信息(可以升级的建筑)
    if guildData.GuildBuildInfo ~= nil then
        self.mGuildBuildInfo = guildData.GuildBuildInfo
    end
    -- 帮派小红点心信息
    if guildData.GlobalGuildRedInfo ~= nil then
        self.mGlobalGuildRedInfo = guildData.GlobalGuildRedInfo
    end
    -- 帮派秘籍
    if guildData.GuildBookInfo ~= nil then
        self.mGuildBookInfo = guildData.GuildBookInfo
    end

    -- 通知帮派信息改变
    Notification:postNotification(EventsName.eGuildHomeAll)
end

-- 帮派Avatar数据更新
--[[
-- 参数 guildAvatar 中的各项参考文件头处的 “帮派Avatar数据说明” 
]]
function CacheGuild:updateGuildAvatar(guildAvatar)
    guildAvatar = guildAvatar or {}

    -- 社团Id
    if guildAvatar.Id ~= nil then
        self.mGuildInfo.Id = guildAvatar.Id
    end
    -- 社团名称
    if guildAvatar.Name ~= nil then
        self.mGuildInfo.Name = guildAvatar.Name
    end

    -- 帮派资金
    if guildAvatar.Fund ~= nil then 
        self.mGuildInfo.GuildFund = guildAvatar.Fund
    end
    -- 累计资金
    if guildAvatar.FundTotal ~= nil then
        self.mGuildInfo.GuildFundTotal = guildAvatar.FundTotal
    end
    -- 成员数量
    if guildAvatar.MemberCount ~= nil then
        self.mGuildInfo.MemberCount = guildAvatar.MemberCount
    end
    -- 每日累计建设次数
    if guildAvatar.GuildBuildCount ~= nil then
        self.mGuildInfo.GuildBuildCount = guildAvatar.GuildBuildCount
    end
    -- 公告
    if guildAvatar.Notice ~= nil then
        self.mGuildInfo.Notice = guildAvatar.Notice
    end
    -- 宣言
    if guildAvatar.Declaration ~= nil then
        self.mGuildInfo.Declaration = guildAvatar.Declaration
    end

    -- 职位更改
    if guildAvatar.PostId ~= nil then
        self.mPlayerGuildInfo.PostId = guildAvatar.PostId
    end

    -- 帮派新信息
    if guildAvatar.GuildNews ~= nil then
        -- Too
    end

    -- 是否有申请列表
    if guildAvatar.IfApplyList ~= nil then
        self.mGlobalGuildRedInfo.ApplyList = guildAvatar.IfApplyList
    end
    -- 是否有成员职务空缺
    if guildAvatar.IfPostLack ~= nil then
        self.mGlobalGuildRedInfo.PostLack = guildAvatar.IfPostLack
    end
    -- 是否有建筑升级
    if guildAvatar.IfBuildingLv ~= nil then
        self.mGlobalGuildRedInfo.BuildingLv = guildAvatar.IfBuildingLv
    end

    -- 帮派秘籍解锁信息
    if guildAvatar.GuildBookInfo ~= nil then
        self.mGuildBuildInfo.GuildBook = guildAvatar.GuildBookInfo
    end

    -- 帮派建筑升级信息
    for id, lv in pairs(guildAvatar.BuildLv or {}) do
        local buildId = tonumber(id)
        for k, old in ipairs(self.mGuildBuildInfo) do
            if old.BuildingId == buildId then
                old.Lv = lv
            end
        end

        -- 帮派大厅等级
        if buildId == 34004000 then
            self.mGuildInfo.Lv = lv
        end
    end

    -- 新帮派信息
    for _, item in ipairs(guildAvatar.GuildNews or {}) do
        table.insert(self.mGlobalGuildNewsInfo, 1, item)
    end

    -- 通知帮派信息改变
    Notification:postNotification(EventsName.eGuildHomeAll)
end

-- 玩家帮派数据更新
function CacheGuild:updatePlayerGuildInfo(playerGuildInfo)
    if playerGuildInfo.FundTotal ~= nil then
        self.mPlayerGuildInfo.FundTotal = playerGuildInfo.FundTotal
    end

    if playerGuildInfo.IfCanBuildTime ~= nil then
        self.mPlayerGuildInfo.IfCanBuildTime = playerGuildInfo.IfCanBuildTime
    end

    if playerGuildInfo.IfCanShare ~= nil then
        self.mPlayerGuildInfo.IfCanShare = playerGuildInfo.IfCanShare
    end

    if playerGuildInfo.PostId ~= nil then
        self.mPlayerGuildInfo.PostId = playerGuildInfo.PostId
    end

    --通知帮派信息改变
    Notification:postNotification(EventsName.eGuildHomeAll)
end

-- 获取帮派信息
function CacheGuild:getGuildInfo()
    return self.mGuildInfo
end

-- 获取玩家的帮派信息
function CacheGuild:getPlayerGuildInfo()
    return self.mPlayerGuildInfo
end

-- 获取帮派建筑信息(可以升级的建筑)
function CacheGuild:getGuildBuildInfo()
    return self.mGuildBuildInfo
end

--判断是否有某个权限
--[[
-- 参数
    guildAuth: 操作类型，在EnumsConfig.lua 文件的 GuildAuth 中定义
]]
function CacheGuild:havePost(guildAuth)
    local postModel = GuildPostModel.items[self.mPlayerGuildInfo.PostId]
    local tempList = string.splitBySep(postModel and postModel.authIDList, ",")

    for index, value in pairs(tempList) do
        if tonumber(value) == guildAuth then
            return true
        end
    end

    return false
end

-- 获取帮派小红点心信息
--[[
-- 参数
    keyName: 帮派小红点表中的字段名，取值为：“ApplyList”、“PostLack”， “BuildingLv”
]]
function CacheGuild:getRedInfo(keyName)
    return self.mGlobalGuildRedInfo[keyName] or false
end

-- 获取建筑的等级
--[[
-- 参数
    buildingId: 建筑Id
]]
function CacheGuild:getBuildLv(buildingId)
    for index, value in ipairs(self.mGuildBuildInfo) do
        if value.BuildingId == buildingId then
            return value.Lv
        end
    end
    
    --没找到时
    return 1
end

----------------------------------------------------------------------------------------------------

-- 更新帮派战信息
--[[
-- 参数
    guildBattleInfo: 帮派战信息
]]
function CacheGuild:updateGuildBattleInfo(guildBattleInfo)
    if guildBattleInfo then
        self.mGuildBattleInfo = guildBattleInfo
    end
end

-- 更新帮派战本帮玩家信息
--[[
-- 参数
    guildBattlePlayerInfo: 帮派战本帮玩家信息
]]
function CacheGuild:updateGuildBattlePlayerInfo(guildBattlePlayerInfo)
    if guildBattlePlayerInfo then
        self.mGuildBattleInfo.GuildBattlePlayerInfo = guildBattlePlayerInfo
    end
end

-- 更新帮派战对方帮派信息
--[[
-- 参数
    matchGuildInfo: 帮派战对方帮派信息
]]
function CacheGuild:updateMatchGuildInfo(matchGuildInfo)
    if matchGuildInfo then
        self.mGuildBattleInfo.MatchGuildInfo = matchGuildInfo
    end
end

-- 更新帮派战对方帮派玩家信息
--[[
-- 参数
    matchGuildBattlePlayerInfo: 帮派战对方帮派玩家信息
]]
function CacheGuild:updateMatchGuildBattlePlayerInfo(matchGuildBattlePlayerInfo)
    if matchGuildBattlePlayerInfo then
        self.mGuildBattleInfo.MatchGuildBattlePlayerInfo = matchGuildBattlePlayerInfo
    end
end

----------------------------------------------------------------------------------------------------

-- 每个玩家初始状态3颗星
local perPlayerStarNum = 3

-- 辅助接口：累计某个列表里的所有星星
function CacheGuild:calcStarNum(playerList)
    local retNum = 0
    for _,v in pairs(playerList) do
        retNum = retNum + v.Star
    end
    return retNum
end

-- 修改帮派战的人物信息
function CacheGuild:setGuildBattlePlayerItem(newItem)
    local function findItem(playerList)
        for _,info in pairs(playerList) do
            if (info.Id == newItem.PlayerId) then
                info.Star = newItem.Score
                break
            end
        end
    end
    findItem(self.mGuildBattleInfo.GuildBattlePlayerInfo or {})
    findItem(self.mGuildBattleInfo.MatchGuildBattlePlayerInfo or {})
end

----------------------------------------------------------------------------------------------------

-- 获取帮派战信息
function CacheGuild:getGuildBattleInfo()
    return self.mGuildBattleInfo
end

-- 获取帮派战本帮玩家信息
function CacheGuild:getGuildBattlePlayerInfo()
    return self.mGuildBattleInfo.GuildBattlePlayerInfo
end

-- 获取帮派战对方帮派信息
function CacheGuild:getMatchGuildInfo()
    return self.mGuildBattleInfo.MatchGuildInfo
end

-- 获取帮派战对方帮派玩家信息
function CacheGuild:getMatchGuildBattlePlayerInfo()
    return self.mGuildBattleInfo.MatchGuildBattlePlayerInfo
end

-- 获取帮派战赛季信息
function CacheGuild:getGuildBattleSeasonInfo()
    return self.mGuildBattleInfo.GuildBattleSeasonInfo
end

-- 获取玩家帮派战信息
function CacheGuild:getPlayerGuildBattleInfo()
    return self.mGuildBattleInfo.PlayerGuildBattleInfo
end

----------------------------------------------------------------------------------------------------

-- 更新帮派秘籍信息
function CacheGuild:updateGuildBookInfo(guildBookInfo)
    if guildBookInfo then
        self.mGuildBookInfo = guildBookInfo
    end
end

-- 获取帮派秘籍信息
function CacheGuild:getGuildBookInfo()
    return self.mGuildBookInfo
end

----------------------------------------------------------------------------------------------------

return CacheGuild