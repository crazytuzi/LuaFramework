--[[
文件名:CachePlayerAttr.lua
描述：玩家数据抽象类型
创建人：liaoyuangang
创建时间：2016.05.09
--]]

local CachePlayerAttr = class("CachePlayerAttr", {})

-- 属性名称列表
local attrNames = {
    "HeadImageId",    -- 玩家头像使用的哪个人物资源的人物模型Id
    "IsDefaultName", -- 是否默认玩家名称(0：非默认名称，不可修改；1：默认名称，可以修改)
    "IsNewPlayer",      -- 是否新用户（0：非新用户；1：新用户）
    "RegisterTime",     -- 注册时间
    "PlayerName",     -- 玩家昵称
    "PlayerId",      --玩家Id
    "Lv",            -- 玩家等级
    "FAP",           -- 战斗力
    "Vip",           -- Vip等级
    "VITNextRecoverTime",    -- 下次体力恢复时间戳
    "VITMaxRecoverTime",     -- 体力全满的时间戳
    "STAMaxNum",             -- 耐力上限
    "STANextRecoverTime",    -- 下次耐力恢复时间戳
    "STAMaxRecoverTime",     -- 耐力全满的时间戳
    "EXP",       -- "经验值"
    "VIT",       -- "体力值"
    "STA",       -- "耐力值"
    "VipEXP",    -- "Vip经验"
    "IfCharge",  -- 是否已首冲
    "Diamond",   -- "元宝"
    "Gold",      -- "铜币"
    "Contribution", -- "贡献"
    "Credit",    -- "学分"
    "PVPCoin",   -- "声望"
    "HeroCoin",  -- "精元"
    "HeroEXP",   -- "将魂"
    "GDDHCoin",  -- "豪侠令"
    "BossCoin",  -- "Boss积分"
    "Merit",         -- 战功
    "Honor",    -- "荣誉"
    "RedBagFund",    -- "红包基金"
    "PetEXP",    -- "兽魂"
    "PetCoin",    -- "兽币"
    "RebornCoin", -- "感悟灵晶"
    "GodDomainGlory",    -- "神域争霸荣誉点"
    "XrxsStar",    -- "赏金点"
    "HuiGen",    -- "慧根"
    "TaoZhuangCoin",    -- "天玉"
    "GuildMoney",    -- "帮派资金"
    "GuildActivity",    -- "帮派活跃度"
    "TitleId",      -- 名望等级

    "guideCoin",    -- "薪火值"
    "TraderTime",   --限时商城结束时间

    "ZBCoin",    -- "卡牌碎片"
    "StarId",    -- 玩家点星节点Id
    "AppErrorLevel", -- 服务器收集客户端调试信息的等级
    "MarqueeInterval",   --
    "XYCurCount",    -- 寻玉次数
    "TowerCount",    -- 妖灵塔的层数
    "HasDrawSuccessReward",  --七日大奖是否领取
    "MonthCardExpireTime",   --月卡过期时间
    "IfDisableSendMsg",      -- 是否需要禁止玩家聊天
    "IsZhiZunFirstCharge", -- 是否是至尊首充（0：非；1：是；)
    "RedBagFund", -- "紅包基金"
    "WechatWorldBeginDate", -- 全服微信红包开启时间
    "WechatWorldEndDate", -- 全服微信红包关闭时间
    "ActivityName",  -- 普通限时活动的名称
    "ActivityPic", -- 普通限时的活动的图片名
    "HolidayActivityName",  -- 节日活动的名称
    "HolidayActivityPic", -- 节日活动的图片名
    "FashionModelId", -- 时装模型Id
    "PVPInterLv",   -- 跨服等级
    "DesignationId", -- 玩家称号头像匡（也包括了PVPInterLv的头像框）
    "ChatBgId", -- 聊天背景
    "RocketVoiceDays", -- 火箭祝福累积天数
    "ExtraNum",   -- 阵决洗练铜币次数
    "HasDrawSuccessReward", -- 7日大奖是否已领取(0:为领取[7日大奖] 1:已领取[成就奖励] 2:已领取[14日登录奖励] )
    "SvipState", -- VIP贵宾状态（0：非；1：是；2：绑定QQ）
    "OpencontestState", -- 开服比拼
    "TriggerLv",  -- 当前触发限时赏金等级 wz
    "IsTriggerReceived", -- 是否已领取限时赏金奖励 用于最后一次领取
    "IsFirstTriggerLv", -- 是否是第一次触发限时任务
    "TeamBattleStatus", -- 守卫襄阳的状态， 取值在 Enums.TeamBattleStatus 中定义
    "ExpedInvitData",   -- 组队邀请的信息
    "ShengyuanWarsInvitData", -- 桃花岛组队邀请信息
    "isExpedTeam",      -- 是否在挑战六大派队伍里面
    "isUseDouble",      -- 是否使用真气翻倍令牌
    "TeamId", -- 当前组队副本队伍ID
    "Merit",--玄金
    "LimitTimeSeckill", --限时秒杀
    "ActiveCardId", --月卡状态
    "MedicineCoin", --药元
    "LoveFlower", -- 情花
    "YinQi", -- 阴气
    "YangQi", -- 阳气
    "XieQi", -- 邪气
    "HonorCoin", -- 江湖杀荣誉点
    "ZslyCoin", -- 兽魂
    "ZhenshouExp", --兽粮
    "ZhenshouCoin", --珍兽精华
    "GuildGongfuCoin", --帮派武技
    "LoginType",    -- 登陆类型(0:互娱 1:普通QQ 2:svipQQ)
    "ExpAddR",      --经验加成
    "JianghuKillForceId", --江湖杀势力id
    "JianghuKillJobId", --江湖杀职业id
    "JianghuKillChannel", --势力频道id
    "FightZhenshouId", --出战的珍兽id(模块未开启 或 没有出战珍兽时为空Guid)
    "IsFunctionOpen", --等级礼包是否开启
    "TimedOnlineRewardCountdown", --限时在线奖励倒计时
    "ChatPartnerIdStr", -- 聊天分组
}

function CachePlayerAttr:ctor()
	self.mPlayerAttr = {}
    -- 微信红包信息
    self.mRedBagInfo = {}
end

function CachePlayerAttr:reset()
	self.mPlayerAttr = {}
    self.mRedBagInfo = {}
end

-- 检查是否已升级，并显示升级页面
--[[
-- 参数
    callback: 如果已升级，关闭显示升级页面后的回调，如果没有升级，则直接调用该回调函数
-- 返回值
    显示了升级页面 返回 true，如果没有显示升级页面则返回false
]]
function CachePlayerAttr:showUpdateLayer(callback)
    local ret = false
    if self.mUpdateLvInfo and self.mUpdateLvInfo.oldLv ~= self.mUpdateLvInfo.newLv then
        LayerManager.addLayer({name = "commonLayer.LevelUpLayer",
            data = {lvUpData = self.mUpdateLvInfo, callback = callback},
            cleanUp = false,
            zOrder = Enums.ZOrderType.eLevelUp,
        })
        self.mUpdateLvInfo.oldLv =  self.mUpdateLvInfo.newLv
        self.mUpdateLvInfo.oldSTA = self.mUpdateLvInfo.newSTA
        self.mUpdateLvInfo.oldMaxSTA = self.mUpdateLvInfo.newMaxSTA
        self.mUpdateLvInfo.oldXYCurCount = self.mUpdateLvInfo.newXYCurCount
        ret = true

        -- 通知升级开启
        Notification:postNotification(EventsName.eLvChanged)

        -- 标记是否触发了第一个限时任务
        local configItem = LimitthebountyModel.items[1]
        local isFirstTr = configItem.triggerLV == self.mUpdateLvInfo.newLv
        self:changeAttr({IsFirstTriggerLv = isFirstTr})
    else
        if callback then
            callback()
        end
    end

    -- 开始显示战力变化动画
    FlashHintObj:startShowAction()
    return ret
end

-- 玩家属性改变处理函数
function CachePlayerAttr:changeAttr(playerAttr)
    -- 处理一个玩家属性信息
    local function dealOneAttr(name, value)
        if name == "Lv" then
            print("avatar.Lv", playerAttr.Lv)
            self.mUpdateLvInfo = self.mUpdateLvInfo or {}
            self.mUpdateLvInfo.oldLv = self.mPlayerAttr.Lv
            self.mUpdateLvInfo.newLv = playerAttr.Lv
            self.mUpdateLvInfo.oldSTA = self.mPlayerAttr.STA
            self.mUpdateLvInfo.newSTA = playerAttr.STA or self.mPlayerAttr.STA
            self.mUpdateLvInfo.oldMaxSTA = self.mPlayerAttr.STAMaxNum
            self.mUpdateLvInfo.newMaxSTA = playerAttr.STAMaxNum or self.mPlayerAttr.STAMaxNum -- 最新耐力上限
            self.mUpdateLvInfo.oldXYCurCount = self.mPlayerAttr.XYCurCount or 0
            self.mUpdateLvInfo.newXYCurCount = playerAttr.XYCurCount or self.mUpdateLvInfo.newXYCurCount or 0 -- 最新寻玉次数上限

            self.mPlayerAttr.Lv = value
            -- 修改主角的等级，主角等级和玩家等级相同
            HeroObj:modifyMainHeroLv(value)
            -- 设置战力动画延迟显示
            FlashHintObj:delayShowAction()

            -- 给平台设置等级变化的统计信息
            Utility.cpInvoke("LevelChanged")
        else
            self.mPlayerAttr[name] = value
            if name == "PlayerName" then
                ConfigFunc:modifyMainHeroName(value)
            end
        end

        -- 通知刷新
        if EventsName["e"..name] then
            Notification:postNotification(EventsName["e"..name])
        end
    end

    for _, name in ipairs(attrNames) do
        if playerAttr[name] ~= nil then
            dealOneAttr(name, playerAttr[name])
        end
    end
end

--- 更新玩家数据信息
function CachePlayerAttr:updatePlayerInfo(player)
    if not player then
        return
    end
    table.merge(self.mPlayerAttr, player)

    require("common.ConfigFunc")
    ConfigFunc:modifyMainHeroName(self.mPlayerAttr.PlayerName)

    -- 新手引导数据
    if player.StepCountList then
        GuideObj:updateGuideInfo(player.StepCountList)
    end

    --dump(self.mPlayerAttr, "self.mPlayerAttr:")
end

--
function CachePlayerAttr:setPlayerInfo(playerInfo)
    if not playerInfo then
        return
    end
    self.mPlayerAttr = playerInfo

    --dump(self.mPlayerAttr, "self.mPlayerAttr")
end

-- 设置微信红包信息
--[[
-- 参数
    redBagInfo:
    {
        WechatWorldIfOpen = false,  -- 全服微信红包是否开启
        WechatChargeAndLoginIfOpen = true,  -- 充值登录微信红包是否开启
        WechatSelfIfOpen = false, -- 个人微信红包是否开启
    }
]]
function CachePlayerAttr:setRedBagInfo(redBagInfo)
    self.mRedBagInfo = redBagInfo
    -- Notification:postNotification(EventsName.eWeChatRedBagChange)
end

-- 设置当前的寻玉次数
function CachePlayerAttr:setXYCurCount(XYCurCount)
    self.mPlayerAttr.XYCurCount = XYCurCount
end

--- 返回玩家属性数据信息
function CachePlayerAttr:getPlayerInfo()
    return self.mPlayerAttr
end

-- 获取微信红包信息
--[[
-- 返回值为：
    {
        WechatWorldIfOpen = false,  -- 全服微信红包是否开启
        WechatChargeAndLoginIfOpen = true,  -- 充值登录微信红包是否开启
        WechatSelfIfOpen = false, -- 个人微信红包是否开启
    }
]]
function CachePlayerAttr:getRedBagInfo()
    return self.mRedBagInfo
end

--- 根据资源类型获取玩家属性
-- 参数 resourcetypeSub： 玩家属性资源类型(在EnumsConfig.lua中的ResourcetypeSub中定义)
function CachePlayerAttr:getPlayerAttr(resourcetypeSub)
    local typeAndNameMap = {
        [ResourcetypeSub.eEXP] = "EXP",    -- "经验值"
        [ResourcetypeSub.eVIT] = "VIT",    -- "体力值"
        [ResourcetypeSub.eSTA] = "STA",    -- "耐力值"
        [ResourcetypeSub.eVIPEXP] = "VipEXP",               -- "VIP经验值"
        [ResourcetypeSub.eDiamond] = "Diamond",             -- "元宝"
        [ResourcetypeSub.eGold] = "Gold",                   -- "铜币"
        [ResourcetypeSub.eContribution] = "Contribution",   -- "贡献"
        [ResourcetypeSub.ePVPCoin] = "PVPCoin",             -- "苍茫令"
        [ResourcetypeSub.eHeroCoin] = "HeroCoin",           -- "神魂"
        [ResourcetypeSub.eHeroExp] = "HeroEXP",             -- "灵晶"
        [ResourcetypeSub.eGDDHCoin] = "GDDHCoin",           -- "如风令"
        [ResourcetypeSub.eBossCoin] = "BossCoin",           -- "积分"
        -- 新增类型
        [ResourcetypeSub.eHonor] = "Honor",                 -- "荣誉"
        [ResourcetypeSub.eRedBagFund] = "RedBagFund",       -- "红包基金"
        [ResourcetypeSub.ePetEXP] = "PetEXP",               -- "兽魂"
        [ResourcetypeSub.ePetCoin] = "PetCoin",             -- "兽币"
        [ResourcetypeSub.eMerit] = "Merit",                 -- 青天令

        [ResourcetypeSub.eRebornCoin] = "RebornCoin",       -- "感悟灵晶"
        [ResourcetypeSub.eGodDomainGlory] = "GodDomainGlory", -- "落英铃"
        [ResourcetypeSub.eXrxsStar] = "XrxsStar",           -- "赏金点"
        [ResourcetypeSub.eHuiGen] = "HuiGen",               -- "慧根"
        [ResourcetypeSub.eTaoZhuangCoin] = "TaoZhuangCoin", -- "天玉"
        [ResourcetypeSub.eGuildMoney] = "GuildMoney",       -- "帮派资金"
        [ResourcetypeSub.eGuildActivity] = "GuildActivity", -- "帮派活跃度"
        [ResourcetypeSub.eMedicineCoin] = "MedicineCoin", -- "药元"
        [ResourcetypeSub.eLoveFlower] = "LoveFlower", -- "情花"
        [ResourcetypeSub.eGuildGongfuCoin] = "GuildGongfuCoin", -- "帮派武技"
        [ResourcetypeSub.eYinQi] = "YinQi", -- "阴气"
        [ResourcetypeSub.eYangQi] = "YangQi", -- "阳气"
        [ResourcetypeSub.eXieQi] = "XieQi", -- "邪气"
        [ResourcetypeSub.eHonorCoin] = "HonorCoin", -- "江湖杀荣誉点"
        [ResourcetypeSub.eZslyCoin] = "ZslyCoin", -- "兽魂"
        [ResourcetypeSub.eZhenshouExp] = "ZhenshouExp", -- "兽粮"
        [ResourcetypeSub.eZhenshouCoin] = "ZhenshouCoin", -- "珍兽精华"

    }
    local tempName = typeAndNameMap[resourcetypeSub]
    return tempName and self.mPlayerAttr[tempName] or 0
end

--- 根据属性名称获取玩家属性
function CachePlayerAttr:getPlayerAttrByName(attrName)
    return attrName and self.mPlayerAttr[attrName]
end

--根据传入的playerId判断此玩家是否是自己
function CachePlayerAttr:isPlayerSelf(playerId)
    return playerId == self.mPlayerAttr["PlayerId"]
end

return CachePlayerAttr
