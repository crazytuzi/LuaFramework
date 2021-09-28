
--[[
文件名:CacheRedDotInfo.lua
描述：小红点数据抽象类型
创建人：liaoyuangang
修改人: heguanghui
创建时间：2016.05.09
--]]

local CacheRedDotInfo = class("CacheRedDotInfo", {})

function CacheRedDotInfo:ctor()
	self.mRedDotInfo = {}

    -- 添加需要特殊处理的小红点模块(子模块变化，当前客户端模块也变化)
    self.redTier = {
        [Enums.ClientRedDot.eHomeShop] = {ModuleSub.eBDDShop, 
            ModuleSub.eTeambattleShop,
            ModuleSub.eStore,
            ModuleSub.eMysteryShop,
            ModuleSub.ePVPShop},
        [Enums.ClientRedDot.eHomeMore] = {ModuleSub.eEmail, 
            ModuleSub.eFriend, 
            ModuleSub.eLeaderBoard,
            ModuleSub.eTitle,},
        [Enums.ClientRedDot.eHomePractice] = {ModuleSub.eZhenyuan,
            ModuleSub.eNeiliMingxiang,
            ModuleSub.eMedicine,
            ModuleSub.eZhenshouLaoyu,},
        [Enums.ClientRedDot.eBattleNormalMore] = {ModuleSub.ePracticeLightenStar,
            ModuleSub.eQuickExp},
        [ModuleSub.eQuickExp] = {ModuleSub.eQuickExpMeetMain},

        --包裹页签
        [Enums.ClientRedDot.eBagHeroAndDebris] = {ModuleSub.eBagHero, ModuleSub.eBagHeroDebris, ModuleSub.eBagIllusionDebris},
        [Enums.ClientRedDot.eBagPetAndZhenJue] = {ModuleSub.eBagZhenjueDebris, ModuleSub.eBagPets, ModuleSub.eBagFashionDebris}, --时装碎片，外功，内功通用
        [Enums.ClientRedDot.eBagEquipAndDebris] = {ModuleSub.eEquip, ModuleSub.eBagEquipDebris},

        -- 阵容头像
        [Enums.ClientRedDot.eTeamHeader] = {Enums.ClientRedDot.eTeamOneKeyEquip,
            Enums.ClientRedDot.eTeamOneKeyZhenJue, Enums.ClientRedDot.eTeamOneKeyZhenyuan, ModuleSub.eHeroChoiceTalent, 
            ModuleSub.eHeroStepUp, ModuleSub.eReborn, ModuleSub.ePetActiveTal, ModuleSub.eTreasureStepUp, ModuleSub.eZhenjueStepUp},
        -- 阵容里的真元切换按钮（不包括真元和内功心法，只包括装备相关、神兵相关、外功相关、培养共鸣）
        [Enums.ClientRedDot.eTeamBtnZhenyuan] = {Enums.ClientRedDot.eTeamOneKeyEquip, 
            ModuleSub.ePetActiveTal, ModuleSub.eTreasureStepUp, 
            ModuleSub.eEquipStarUpMaster, ModuleSub.eEquipStepUpMaster},
        -- 培养共鸣
        [Enums.ClientRedDot.eTeamEquipMaster] = {ModuleSub.eEquipStarUpMaster, ModuleSub.eEquipStepUpMaster},
        -- 阵容
        [ModuleSub.eFormation] = {ModuleSub.eSuccessRecommend, ModuleSub.eEquipStarUpMaster, ModuleSub.eEquipStepUpMaster, ModuleSub.eQbanShizhuang, ModuleSub.eHeroFashion},
        -- 培养
        [Enums.ClientRedDot.eTeamTrain] = {ModuleSub.eHeroStepUp, ModuleSub.eReborn, ModuleSub.eHeroChoiceTalent},
        -- 内功心法
        [Enums.ClientRedDot.eTeamZhenjue] = {Enums.ClientRedDot.eTeamOneKeyZhenJue, ModuleSub.eZhenjueStepUp},

        -- 帮派
        [ModuleSub.eGuild] = {Enums.ClientRedDot.eGuildPostChange, 
            Enums.ClientRedDot.eGuildBuildingUp, 
            Enums.ClientRedDot.eGuildMemberIn,
            ModuleSub.eGuildBattle},
        -- 帮派管理
        [Enums.ClientRedDot.eGuildMana] = {Enums.ClientRedDot.eGuildPostChange, 
            Enums.ClientRedDot.eGuildBuildingUp, 
            Enums.ClientRedDot.eGuildMemberIn},

        -- 聊天
        [ModuleSub.eChat] = {ModuleSub.eEmailFriend},

        -- 铸炼
        [ModuleSub.eDisassemble] = {ModuleSub.eZhenjueRefine},
        -- 分解(装备和内功)
        [Enums.ClientRedDot.eDisassemble] = {ModuleSub.eDisassembleEquip, ModuleSub.eZhenjueRefine},
        -- 国庆活动
        [ModuleSub.eAnniversary] = {ModuleSub.eTimedAcumulateLogin, ModuleSub.eTimedBossDrop, ModuleSub.eChristmasActivity14, ModuleSub.eTimedHolidayDrop},
        --一统武林
        [Enums.ClientRedDot.ePvpTop] = {ModuleSub.eWhosTheGod, ModuleSub.eGodWorship}
    }

    -- 添加需要特殊处理的new事件
    self.newTier = {
        [ModuleSub.eBag] = {ModuleSub.eBagProps,
            ModuleSub.eBagZhenjueDebris,
            ModuleSub.eBagPets,
            ModuleSub.eBagTreasure,
            ModuleSub.eBagHero,
            ModuleSub.eBagHeroDebris,
            ModuleSub.eBagIllusionDebris},
         --包裹页签
        [Enums.ClientRedDot.eBagHeroAndDebris] = {ModuleSub.eBagHero, ModuleSub.eBagHeroDebris, ModuleSub.eBagIllusionDebris},
        [Enums.ClientRedDot.eBagPetAndZhenJue] = {ModuleSub.eBagZhenjueDebris, ModuleSub.eBagPets},
        [Enums.ClientRedDot.eBagEquipAndDebris] = {ModuleSub.eEquip, ModuleSub.eBagEquipDebris},
    }
    -- 添加限时活动
    require("activity.ActivityConfig")
    self.newTier[ModuleSub.eTimedActivity] = {}
    for k, _ in pairs(ActivityConfig[ModuleSub.eTimedActivity]) do
        table.insert(self.newTier[ModuleSub.eTimedActivity], k)
    end
    
    -- 添加仅用于显示一次类型的小红点模块
    self.onceRedDotCached = {
    	-- [ModuleSub.eExtraActivityWeChat] = true,	-- 微信关注礼包
	}
    -- 微信关注礼包特殊渠道才有小红点
    local partnerID = IPlatform:getInstance():getConfigItem("PartnerID")
    if partnerID == "163" or partnerID == "6666203" or partnerID == "6666204" or partnerID == "6666205" then
        self.onceRedDotCached[ModuleSub.eExtraActivityWeChat] = true
    end

    -- 模块ID对应数据缓存
    self.redCached = {}
    self.newCached = {}
end

function CacheRedDotInfo:reset()
	self.mRedDotInfo = {}
end

--- 获取所有模块的小红点信息
function CacheRedDotInfo:getRedDotInfo()
    return self.mRedDotInfo
end

-- 获取模块ID需要处理的事件列表(部分界面小红点需要特殊添加其它模块ID)
-- subKey: 子结点数据
function CacheRedDotInfo:getEvents(moduleId, subKey)
    local retList = self:getInnerEvents(EventsName.eRedDotPrefix, 
        self.redTier, self.redCached, moduleId, subKey)

    -- 部分模块的特殊处理
    if moduleId == ModuleSub.eHeroRecruit or moduleId == ModuleSub.eStore then
        -- 主将招募添加额外的道具变化通知
        table.insert(retList, EventsName.ePropRedDotPrefix .. "16050003")
        table.insert(retList, EventsName.ePropRedDotPrefix .. "16050241")
        table.insert(retList, EventsName.ePropRedDotPrefix .. "16050047")
    elseif moduleId == ModuleSub.eChat then
        -- 聊天变化
        table.insert(retList, EventsName.eChatUnreadPrefix)
        table.insert(retList, EventsName.eChatNewMsg)
    end
    return retList
end

-- 判断小红点是否有效
-- subKey: 子结点数据
-- index: 阵容特有index
function CacheRedDotInfo:isValid(moduleId, subKey, index)
    local eventKey = tostring(moduleId) .. (subKey or "")
    -- 子模块时，仅仅查询自己的小红点信息
    local idList = subKey and {eventKey} or self.redCached[eventKey]
    if not idList then
        -- 如没有调用过getEvents, 则调用一次(保存需要判断的事件列表)
        self:getInnerEvents(EventsName.eRedDotPrefix, 
            self.redTier, self.redCached, moduleId, subKey)
        -- getInnerEvents返回事件名，这儿需要[id,id,id]
        idList = self.redCached[eventKey]
    end
    for _,v in ipairs(idList) do
        -- 服务器返回的小红点或本地额外判断(如商城道具满足时也需要小红点)
        if self.mRedDotInfo[v] or self:isInnerValid(v, index) then
            return true
        end
    end
    return false
end

-- 内部使用，判断额外的判断小红点是否有效
-- index: 阵容特有index
function CacheRedDotInfo:isInnerValid(strModuleId, index)
    local moduleId = tonumber(strModuleId)
    if moduleId == ModuleSub.eHeroRecruit or moduleId == ModuleSub.eStore then
        -- 主将招募的额外判断(判断道具数量是否足够)
        local propNum = GoodsObj:getCountByModelId(16050003)    -- 豪侠招募令
        local singlePropNum = GoodsObj:getCountByModelId(16050241)  -- 宗师单抽令
        local tenPropNum = GoodsObj:getCountByModelId(16050047)  -- 宗师十连令
        if propNum >= 10 or singlePropNum >= 1 or tenPropNum >= 1 then
            return true
        end
    elseif moduleId == Enums.ClientRedDot.eTeamOneKeyEquip then
        -- 是否有最优装备
        return SlotPrefObj:havePreferableEquip(index)
    elseif moduleId == Enums.ClientRedDot.eTeamOneKeyZhenJue then
        -- 是否有最优阵决
        return SlotPrefObj:havePreferableZhenjue(index)
    elseif moduleId == Enums.ClientRedDot.eTeamOneKeyZhenyuan then
        -- 是否有最优真元
        return SlotPrefObj:havePreferableZhenyuan(index)
    elseif moduleId == ModuleSub.eHeroStepUp then
        -- 是否有主将可进阶
        return SlotPrefObj:slotHeroCanStep(index)
    elseif moduleId == ModuleSub.ePetActiveTal then
        -- 是否有神兵可进阶
        return SlotPrefObj:slotPetCanActiveTal(index)
    elseif moduleId == ModuleSub.eZhenjueStepUp then
        -- 是否有内功心法可进阶
        return SlotPrefObj:slotZhenjueCanStep(index)
    elseif moduleId == ModuleSub.eTreasureStepUp then
        -- 是否有外功可参悟
        return SlotPrefObj:slotTreasureCanStep(index)
    elseif moduleId == ModuleSub.eReborn then
        return SlotPrefObj:slotHeroCanReborn(index)
    elseif moduleId == ModuleSub.eHeroChoiceTalent then
        -- 是否有招式可装备
        return SlotPrefObj:haveMainHeroTal(index)
    elseif moduleId == ModuleSub.eEquipStepUpMaster then
        -- 是否有装备可锻造
        return next(SlotPrefObj:haveSlotEquipCanStep())
    elseif moduleId == ModuleSub.eEquipStarUpMaster then
        -- 是否有装备可升星
        return next(SlotPrefObj:haveSlotEquipCanStar())
    elseif moduleId == ModuleSub.eFormation then
        -- 是否有人物可以突破, 是否有最优装备可以上阵
        return SlotPrefObj:slotHeroCanStep() or 
            SlotPrefObj:havePreferableEquip() or 
            SlotPrefObj:havePreferableZhenjue() or
            SlotPrefObj:havePreferableZhenyuan() or
            SlotPrefObj:slotPetCanActiveTal() or
            SlotPrefObj:slotTreasureCanStep() or 
            SlotPrefObj:slotHeroCanReborn() or 
            SlotPrefObj:haveMainHeroTal() or 
            SlotPrefObj:slotZhenjueCanStep()
    elseif moduleId == ModuleSub.eChat then
        return ChatMng:getUnreadCount(Enums.ChatChanne.ePrivate) > 0 or 
            ChatMng:getUnreadCount(Enums.ChatChanne.eUnion) > 0 or 
            ChatMng:getUnreadCount(Enums.ChatChanne.eTeam) > 0
    elseif moduleId == Enums.ClientRedDot.eGuildPostChange then
        return GuildObj:havePost(GuildAuth.ePostChange) and GuildObj:getRedInfo("PostLack")
    elseif moduleId == Enums.ClientRedDot.eGuildBuildingUp then
        return GuildObj:havePost(GuildAuth.eBuildingUp)  and GuildObj:getRedInfo("BuildingLv")
    elseif moduleId == Enums.ClientRedDot.eGuildMemberIn then
        return GuildObj:havePost(GuildAuth.eMemberIn) and GuildObj:getRedInfo("ApplyList")
    -- 一次性小红点
    elseif self.onceRedDotCached[moduleId] ~= nil then
    	return self.onceRedDotCached[moduleId]
    end
end

-- 内部使用，获取对应的事件列表并缓存
function CacheRedDotInfo:getInnerEvents(prefix, tierMap, cacheMap, moduleId, subKey)
    local strModuleId = tostring(moduleId)
    local retIdList = {strModuleId}
    if subKey then
        -- 子模块自动添加父模块变化事件
        table.insert(retIdList, retIdList[1] .. subKey)
    else
        -- 非子模块时判断是否需要其它模块
        local tierList = tierMap[moduleId]
        if tierList then
            for _,v in ipairs(tierList) do
                table.insert(retIdList, tostring(v))
            end
        end
    end
    -- 生成所有的事件名
    local retList = {}
    for _,v in ipairs(retIdList) do
        table.insert(retList, prefix .. v)
    end
    -- 缓存需要判断的总Id
    cacheMap[strModuleId .. (subKey or "")] = retIdList
    return retList
end

--- ========================== 其它地方的new或小红点判断 =====================
-- 添加new事件的事件
function CacheRedDotInfo:getNewEvents(moduleId)
    return self:getInnerEvents(EventsName.eNewPrefix, self.newTier, self.newCached, moduleId)
end

-- 判断模块对应的new是否有效
function CacheRedDotInfo:isNewValid(moduleId)
    local function isModuleNewValid(curId)
        if curId == ModuleSub.eBagProps then
            return #(GoodsObj:getNewPropsIdObj():getNewIdList()) > 0
        elseif curId == ModuleSub.eBagHero then
            return #(HeroObj:getNewIdObj():getNewIdList()) > 0
        elseif curId == ModuleSub.eBagHeroDebris then 
            return #(GoodsObj:getNewHeroDebrisIdObj():getNewIdList()) > 0
        elseif curId == ModuleSub.eBagTreasure then
            return #(TreasureObj:getNewIdObj():getNewIdList()) > 0
        elseif curId == ModuleSub.eBagZhenjueDebris then
            return #(ZhenjueObj:getNewIdObj():getNewIdList()) > 0 or #(GoodsObj:getNewZhenjueDebrisIdObj():getNewIdList()) > 0
        elseif curId == ModuleSub.eBagPets then
            return #(PetObj:getNewIdObj():getNewIdList()) > 0 or #(GoodsObj:getNewPetDebrisIdObj():getNewIdList()) > 0
        elseif curId == ModuleSub.eBagIllusionDebris then
            return #(IllusionObj:getNewIdObj():getNewIdList()) > 0 or #(GoodsObj:getNewIllusionDebrisIdObj():getNewIdList()) > 0
        end
        -- 判断活动是否有new
        return ActivityObj:activityIsNew(curId)
    end

    local eventKey = tostring(moduleId)
    local idList = self.newCached[eventKey] or {eventKey}
    for _,v in ipairs(idList) do
        -- 判断是否有new
        if isModuleNewValid(tonumber(v)) then
            return true
        end
    end
    return false
end

-- 保存小红点状态(仅用于显示一次类型的小红点)
function CacheRedDotInfo:saveOnceRedDot(moduleId, status)
    if type(status) == "boolean" then
        self.onceRedDotCached[moduleId] = status
        Notification:postNotification(EventsName.eRedDotPrefix .. tostring(moduleId))
    end
end

--- ========================== 服务器相关信息 =====================

-- 设置通过聊天服务器返回的小红点信息
--[[
-- info 的数据格式为
    {
        [moduleId] = {
            Default = true, -- 
            key1 = true,
            key2 = true, 
        },
        ...
    }
]]
function CacheRedDotInfo:setSocketRedDotInfo(info)
    -- dump(info, "CacheRedDotInfo:setSocketRedDotInfo info:")
    for key, value in pairs(info or {}) do
        for subKey, valid in pairs(value or {}) do
            if subKey == "Default" then
                -- 主模块的小红点信息
                self.mRedDotInfo[key] = valid
            else
                -- 保存其它子结点的小红点信息
                self.mRedDotInfo[key .. subKey] = valid
            end
        end

        -- 由于小红点事件与模块Id相关，具体有哪些需要根据配置表确定，
        -- 所以事件名称的格式为 "eRedDot"+模块Id， 如：“eRedDot1100”（人物模块的小红点）
        Notification:postNotification(EventsName.eRedDotPrefix .. key)
    end
end

return CacheRedDotInfo