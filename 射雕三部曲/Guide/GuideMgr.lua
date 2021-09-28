--[[
    文件名：Guide.GuideMgr.lua
    描述：引导管理器
    创建人：杨科
    创建时间：2015.8.19
-- ]]


local GuideRelation_items
local GuideEventModel_items

local table_insert = table.insert
local ipairs       = ipairs
local pairs        = pairs

local MAIN_GUIDE_ID = 1 -- 主引导部分ID

local GuideMgr = {}

-- @进入游戏
-- 该函数在StartGameLayer初始化玩家数据后调用
function GuideMgr:enterGame()
    require("Chat.ChatMng")
    require("Chat.ChatBtnLayer")
    require("Config.GuideRelation")
    require("Config.GuideEventModel")
    GuideRelation_items = GuideRelation.items
    GuideEventModel_items = GuideEventModel.items

    -- GuideObj:updateGuideInfo({[1] = 1})
    self:initGuideInfo()

    -- 进入游戏前，先清空原来的layer栈
    LayerManager.clearLayer(true)
    -- 创建聊天连接对象
    ChatMng:new()
    -- 创建聊天按钮
    ChatBtnLayer:create()

    -- 纠正引导时，有可能需要请求网络，所以这里使用callback形式
    self:correctGuideLocal(function()
        -- 恢复引导
        self:restoreGuide()
    end)
end

-- @登出游戏时调用
function GuideMgr:logout()
    self.mGuideIDMap = nil
end

-- @初始化数据
function GuideMgr:initGuideInfo()
    -- 引导数据
    local guideStep = GuideObj:getGuideInfo()

    -- 保存需要在未来执行的各种类型引导
    -- 类型不同，保存的结构会不同
    self.mGuideTable = {
        --[[ -- 等级引导
        {
            -- 触发等级 -> 引导ID
            [level] = guideID,
        }
        --]]
        [GuideTriggerType.eModule] = {},

        --[[ -- 追加触发引导
        {
            引导ID -> {模块ID，触发等级}
            [guideID] = {moduleID, triggerLv},
        }
        --]]
        [GuideTriggerType.eAppend] = {},


        --[[ -- 特殊引导
        {
            -- 引导ID的列表(list)
            1 = guideID,
            2 = guideID,
        }
        ]]
        [GuideTriggerType.eSpecial] = {},

        --[[
        {
            触发条件（章节ID、结点ID） -> 引导ID
            [trigerConfig] = guideID,
        }
        --]]
        [GuideTriggerType.echapteropen]           = {}, -- 进入章节引导
        [GuideTriggerType.eBattleNodeOrdinalStar] = {}, -- 战斗前引导
        [GuideTriggerType.eBattleNodeOrdinalEnd]  = {}, -- 战斗后引导

        --[[ -- Vip等级引导
        {
            -- Vip等级 -> {
                vipLv = VIP触发等级,
                moduleID = 开放的模块ID,
            }
            [vipLv] = {
                vipLv    = x,
                moduleID = n,
            },
        }
        --]]
        [GuideTriggerType.eVipLevel] = {},

        -- 小游戏引导
        -- 未使用
        -- [GuideTriggerType.eGame] = {},
    }

    -- GuideID映射步骤
    self.mGuideIDMap = {}
    -- eventID映射步骤
    self.mEventIDMap = {}

    -- 记录等级最低的引导，用于出现意外后，重进游戏时判断是否跳过主引导
    local miniLvGuide = 9999

    if not Guide.config.IF_OPEN then
        print("新手引导被关闭, 可在GuideConfig中修改")
        return
    end

    require("Config.ModuleSubModel")
    -- 遍历所有引导
    for guideID, item in pairs(GuideRelation_items) do
        local ordinal = guideStep[guideID]
        local maxOrdinal = #GuideRelation_items[guideID]

        if (not ordinal or ordinal <= maxOrdinal) and guideID ~= MAIN_GUIDE_ID then
            local triggerType = item[1] and item[1].triggerTypeEnum or 0
            local triggerConfig = item[1] and item[1].triggerConfig or ""
            local num_trigger_config = tonumber(triggerConfig)

            -- 等级触发
            if triggerType == GuideTriggerType.eModule or triggerType == GuideTriggerType.eAppend then
                local moduelID = num_trigger_config
                -- 查找模块开放等级
                local triggerLv = ModuleSubModel.items[moduelID] and ModuleSubModel.items[moduelID].openLv
                if not triggerLv then
                    dump("\n-----------------------------------------------------\n"
                        .. "unknow moduleID in 'GuideRelation':" .. tostring(moduelID)
                        .. "\n-----------------------------------------------------")
                else
                    local open = ModuleInfoObj:moduleIsOpenInServer(moduelID)

                    -- 模块已开启，并且玩家等级小于等于触发等级
                    if open and PlayerAttrObj:getPlayerAttrByName("Lv") <= triggerLv then
                        -- 将追加引导为普通引导处理
                        if triggerType == GuideTriggerType.eAppend then
                            triggerType = GuideTriggerType.eModule
                        end
                        self.mGuideTable[triggerType][triggerLv] = guideID
                        self:appendGuideToMap(guideID, item)

                    -- 追加引导(模块未开启或者等级已超出触发等级)
                    elseif triggerType == GuideTriggerType.eAppend then
                        self.mGuideTable[triggerType][guideID] = {moduelID, triggerLv}
                    end
                end

            -- 战斗后触发
            -- ordinal == nil   未触发
            -- ordinal == 1     触发未完成
            elseif triggerType == GuideTriggerType.eBattleNodeOrdinalEnd then -- 战斗后触发
                if not ordinal or ordinal == 1 then -- 未完成过
                    self.mGuideTable[triggerType][num_trigger_config] = guideID
                    self:appendGuideToMap(guideID, item)
                end

            -- Vip等级触发
            elseif triggerType == GuideTriggerType.eVipLevel
                and (not ordinal or ordinal == 1)
              then
                -- 判断是否开启VIP
                if ModuleInfoObj:moduleIsOpenInServer(ModuleSub.eVIP) then
                    local info = string.split(triggerConfig, ",")
                    self.mGuideTable[GuideTriggerType.eVipLevel][guideID] = {
                        vipLv    = tonumber(info[1]),
                        moduleID = tonumber(info[2]),
                    }
                    self:appendGuideToMap(guideID, item)
                end

            -- 小游戏
            elseif triggerType == GuideTriggerType.eGame then
                self:appendGuideToMap(guideID, item)

            -- 特殊引导
            elseif triggerType == GuideTriggerType.eSpecial and (not ordinal) then
                table_insert(self.mGuideTable[triggerType], guideID)
                self:appendGuideToMap(guideID, item)
            -- 剧情
            elseif triggerType == GuideTriggerType.echapteropen
                or triggerType == GuideTriggerType.eBattleNodeOrdinalStar
              then
                self.mGuideTable[triggerType][num_trigger_config] = guideID

                self:appendGuideToMap(guideID, item)
            end
        end

        local triggerType = item[1] and item[1].triggerTypeEnum or 0
        if triggerType == GuideTriggerType.eModule then
            local triggerConfig = item[1] and item[1].triggerConfig or ""
            local num_trigger_config = tonumber(triggerConfig)
            local triggerLv = ModuleSubModel.items[num_trigger_config] and ModuleSubModel.items[num_trigger_config].openLv
            if triggerLv and triggerLv < miniLvGuide and triggerLv > 3 then
                miniLvGuide = triggerLv
            end
        end
    end

    dump(miniLvGuide, "miniLvGuide")
    self.mMiniLvGuide = miniLvGuide

    -- 等级已达到普通引导的等级，则跳过强制引导
    if PlayerAttrObj:getPlayerAttrByName("Lv") >= miniLvGuide then
        GuideObj:updateGuideInfo({[MAIN_GUIDE_ID] = 999})

    -- 否则继续强制引导
    else
        self:appendGuideToMap(MAIN_GUIDE_ID, GuideRelation_items[MAIN_GUIDE_ID])
    end
end

--[[
-- 处理数据 --
-- 将事件表和引导表关联，并保存到 mGuideIDMap、mEventIDMap
-- 将GuideEventModel.items插入GuideRelation.items
[1] = {
    [1] = {
        ID = 1,
        ordinal = 1,
        eventID = 101,
        triggerTypeEnum = 20,
        triggerConfig = "2",
        nextID = 1,
        recoverOrdianl = 1,
        eventModel = {
            ID = 101,
            name = "新手關卡演示完畢，直接跳轉到大廳",
            eventTypeEnum = 2,
            dialogList = "",
            sound = ""
        },
    },
    [2] = {
        ID = 1,
        ordinal = 2,
        eventID = 102,
        triggerTypeEnum = 10,
        triggerConfig = "1",
        nextID = 1,
        recoverOrdianl = 2,
        eventModel = {
            ...
        },
    },
--]]
function GuideMgr:appendGuideToMap(guideID, items)
    self.mGuideIDMap[guideID] = {}
    for index, item in pairs(items) do
        local eventID = item.eventID
        item.eventModel = GuideEventModel_items[eventID]

        self.mGuideIDMap[guideID][eventID] = item
        self.mEventIDMap[eventID] = item
    end
end

-- @获取当前引导信息
-- 返回:guideID, ordinal, eventID;当前没有引导时无返回值
function GuideMgr:getGuideInfo()
    local guideStep = GuideObj:getGuideInfo()

    -- 屏蔽新手引导
    if not Guide.config.IF_OPEN then
        return
    end

    -- 未初始化
    if not self.mGuideIDMap or not guideStep then
        return
    end

    local check_proc_queue = {
        [1] = function()
            -- 检查主引导
            if not guideStep[MAIN_GUIDE_ID] then
                return 1, 1
            elseif self:getGuideOrdinal(MAIN_GUIDE_ID) <= #GuideRelation_items[MAIN_GUIDE_ID] then
                if PlayerAttrObj:getPlayerAttrByName("Lv") >= self.mMiniLvGuide then
                    GuideObj:updateGuideInfo({[MAIN_GUIDE_ID] = 999})
                else
                    return MAIN_GUIDE_ID
                end
            end
        end,
        [2] = function()
            -- 获取当前等级引导
            local guideID, ordinal, eventID
                = self:getGuideInfoByType(GuideTriggerType.eModule, PlayerAttrObj:getPlayerAttrByName("Lv"))
            -- local guideID, ordinal, eventID
            --     = self:getGuideInfoByType(GuideTriggerType.eModule, 20)
            if ordinal and ordinal == 1 then
                local guideModel = self:getGuideModel(guideID, ordinal)
                local modelID = tonumber(guideModel.triggerConfig)
                if not ModuleInfoObj:moduleIsOpenInServer(modelID) then
                    return
                end
            end

            return guideID, ordinal, eventID
        end,
        [3] = function()
            -- 检查特殊引导
            return self:getSpecialGuideInfo()
        end,
        [4] = function()
            -- 检查追加引导
            return self:getAppendGuideInfo()
        end,
        [5] = function()
            -- 检查VIP等级引导
            return self:getVipLvGuideInfo()
        end,
    }

    local guideID, ordinal, eventID

    -- 顺序检查各种引导类型
    for _, proc in ipairs(check_proc_queue) do
        guideID, ordinal, eventID = proc()
        if guideID and ordinal and eventID then
            break -- 退出循环
        elseif guideID and (not eventID) then
            -- 获取该引导当前步骤
            ordinal = self:getGuideOrdinal(guideID)

            -- 判断引导是否结束
            local maxOrdinal = #GuideRelation_items[guideID]
            if ordinal <= maxOrdinal then
                -- 引导未完成
                break -- 退出循环
            end
        end

        guideID, ordinal, eventID = nil, nil, nil
    end

    if (not guideID or not ordinal) then
        -- 没有引导，直接返回
        return
    end

    if not eventID then
        eventID = self:getGuideEventID(guideID, ordinal)
    end

    return guideID, ordinal, eventID
end

--[[
-- @获取 model
-- ]]
function GuideMgr:getGuideModel(guideID_or_eventID, ordinal)
    if not guideID_or_eventID then
        return
    end

    if not ordinal then
        -- 将 guideID_or_eventID 当成 eventID
        return self.mEventIDMap[guideID_or_eventID]
    else
        -- 将 guideID_or_eventID 当成 guideID
        return GuideRelation_items[guideID_or_eventID][ordinal]
    end
end

-- 获取正在进行的特殊引导
function GuideMgr:getSpecialGuideInfo()
    local guideStep = GuideObj:getGuideInfo()
    for _, v in ipairs(self.mGuideTable[GuideTriggerType.eSpecial]) do
        local ordinal = guideStep[v]
        if ordinal then
            local maxOrdinal = #GuideRelation_items[v]
            if ordinal <= maxOrdinal then
                local eventID = self:getGuideEventID(v, ordinal)
                return v, ordinal, eventID
            end
        end
    end
end

-- 获取追加引导
function GuideMgr:getAppendGuideInfo()
    for guideID, v in pairs(self.mGuideTable[GuideTriggerType.eAppend]) do
        -- 检查这个模块是否开启
        local open = ModuleInfoObj:moduleIsOpenInServer(v[1])

        if open then
            -- 检查是否需要插入到引导数据
            if not self.mGuideIDMap[guideID] then
                self:appendGuideToMap(guideID, GuideRelation_items[guideID])
            end

            local ordinal = self:getGuideOrdinal(guideID)
            local maxOrdinal = #GuideRelation_items[guideID]

            if ordinal <= maxOrdinal then
                if PlayerAttrObj:getPlayerAttrByName("Lv") > v[2] then
                    -- 已经超过等级，则应该触发
                    if ordinal <= maxOrdinal then
                        local eventID = self:getGuideEventID(guideID, ordinal)
                        return guideID, ordinal, eventID
                    end
                else
                    -- 将其作为普通等级引导处理
                    self.mGuideTable[GuideTriggerType.eModule][v[2]] = guideID
                    self.mGuideTable[guideID] = nil

                    -- 如果刚好达到等级则立即执行
                    if PlayerAttrObj:getPlayerAttrByName("Lv") == v[2] then
                        return self:getGuideInfoByType(GuideTriggerType.eModule, PlayerAttrObj:getPlayerAttrByName("Lv"))
                    end
                end
            end
        end
    end
end

function GuideMgr:getVipLvGuideInfo()
    -- 检查VIP等级触发
    local gInfo = self:getGuideInfoByType(GuideTriggerType.eVipLevel)
    if not gInfo then
        return
    end
    for guideID, info in pairs(gInfo) do
        -- 检查VIP等级和模块是否开启
        if PlayerAttrObj:getPlayerAttrByName("Vip") >= info.vipLv then
            if (not info.moduleID) or ModuleInfoObj:moduleIsOpenInServer(info.moduleID, true) then
                local ordinal = self:getGuideOrdinal(guideID)
                local maxOrdinal = #GuideRelation_items[guideID]
                if ordinal <= maxOrdinal then
                    local eventID = self:getGuideEventID(guideID, ordinal)
                    return guideID, ordinal, eventID
                end
            end
        end
    end
end

-- 手动激活特殊引导
function GuideMgr:activeGuideManually(guideID, ordinal)
    local guideStep = GuideObj:getGuideInfo()
    for _, id in ipairs(self.mGuideTable[GuideTriggerType.eSpecial]) do
        if id == guideID then
            if not guideStep[guideID] or guideStep[guideID] == (ordinal or 1) then
                GuideObj:updateGuideInfo({[guideID] = ordinal or 1})
                -- 立即上传到服务器
                self:saveGuideStep(guideID, ordinal or 1, nil, true)

                return true
            end
        end
    end
end

-- 获取某引导进行到哪一步骤
function GuideMgr:getGuideOrdinal(guideID)
    if not GuideRelation_items[guideID] then
        return 999999
    end
    return GuideObj:getGuideInfo()[guideID] or 1
end

-- 获取引导步骤对应的eventID
function GuideMgr:getGuideEventID(guideID, ordinal)
    local guideModel = GuideRelation_items[guideID]
    return guideModel and guideModel[ordinal] and guideModel[ordinal].eventID
end

-- @恢复引导
-- 根据引导步骤决定跳转到对应界面
function GuideMgr:restoreGuide()
    local guideID, ordinal, eventID = self:getGuideInfo()

    if not guideID then
        dump("没有新手引导，直接进入主页面")
        return Guide.helper:showHomeLayer(0)
    end

    dump("有新手引导:" .. tostring(eventID))

    Guide.config.restoreOnBoot(eventID)
end


-- @纠正引导步骤
--[[
params:
    callback    纠正完成后回调,因为纠正过程可能会请求网络，所以使用回调
--]]
function GuideMgr:correctGuideLocal(callback)
    self:correctGuide(eventID, Guide.config.bootCorrectTable, callback)
end


-- @根据tab,纠正引导步骤
-- 根据当前引导步骤决定执行正确的步骤，或者跳过引导
-- eg1.当前引导步骤为关闭某界面，则跳过该步骤
-- eg2.当前引导步骤为从服务器获取资源，则判断是否已经获取然后决定是否跳过
--[[
params:
    eventID         当前引导，传入nil则调用getGuideInfo获取
    correctTable    table,通过该表纠正，见eg.
    callback        纠正完成后回调,因为纠正过程可能会请求网络，所以使用回调
eg.tab:
{
    [401] = 402,    -- 表示把401(eventID)纠正为402
    [603] = -1,     -- 表示如果为603，则跳过该引导所有步骤
    [501] = function(eventID, callback)
        local newEventID = 502
        callback(502) -- 若callback传入-1表示跳过该引导所有步骤,不传入值则不做处理
        -- 在这个纠正过程中可能请求网络，所以这套函数使用callback
    end,
}
--]]
function GuideMgr:correctGuide(eventID, correctTable, callback)
    if eventID == nil then
        local _, _, t = self:getGuideInfo()
        eventID = t

        if not eventID then
            return callback and callback()
        end
    end

    local result
    repeat
        -- 获取eventID对应引导
        local tmpModel = self:getGuideModel(eventID)
        if not tmpModel then
            break
        end
        -- 引导ID
        local guideID = tmpModel.ID

        local newEventID = correctTable[eventID]
        if not newEventID then
            break
        end

        local function save(newID)
            if newID == -1 then
                -- 跳过引导
                self:saveGuideStep(guideID, 9999, nil, true)
            elseif newID then
                -- 纠正引导
                self:saveGuideStep(guideID, nil, newID)
            end
            return callback and callback(newID)
        end

        if type(newEventID) == "number" then
            return save(newEventID)
        elseif type(newEventID) == "function" then
            return newEventID(eventID, save)
        end
    until true

    local _ = callback and callback(result)
end


-- @显示新手引导
--[[
params:
{
    <eventID>       引导事件ID(必传)
    [clickNode]     点击的按钮
    [clickRect]     点击区域
    [hintPos]       气泡位置
    [parent]        引导页面父节点，默认runningScene()
    [nextStep(eventID)]      点击该区域后回调,比如对话引导时可用该参数,对话结束后会调用

    clickNode、clickRect应该传入任意一个
}
--]]
function GuideMgr:showGuideLayer(params)
    local guideLayer = require("Guide.GuideLayer").new(params)
    return LayerManager.addGuideLayer(guideLayer, params.parent)
end


-- @移除新手引导页面
function GuideMgr:removeGuideLayer(...)
    return LayerManager.removeGuideLayer(...)
end


-- @下一步
-- :如果传入的eventID为当前进行的引导,则将该引导步骤加1
-- :needUpload 是否上传到服务器
function GuideMgr:nextStep(eventID, needUpload)
    local _guideID, _ordinal, _eventID = self:getGuideInfo()
    if _eventID == eventID then
        self:saveGuideStep(_guideID, _ordinal + 1, nil, needUpload)

        -- 判断是否需要运营打点信息
        local eventInfo = GuideEventModel_items[eventID]
        if string.len(eventInfo.saveHit) > 0 then
            Guide.hit(tonumber(eventInfo.saveHit))
        end
        return true
    else
        return false
    end
end


-- @修改引导步骤
--[[
params:
    <guideID>     引导ID
    [ordinal]     步骤序号
    [eventID]     事件ID
    [needUpload]  为true时上传引导信息

    ordinal、eventID至少传入一个,两者同时传入时忽略eventID
--]]
function GuideMgr:saveGuideStep(guideID, ordinal, eventID, needUpload)
    if not ordinal then
        local eventModel = self.mGuideIDMap[guideID][eventID]
        ordinal = eventModel and eventModel.ordinal
    end

    dump(string.format("更新引导:%s->%s->%s", guideID, ordinal, eventID))
    -- 本地立即修改
    GuideObj:updateGuideInfo({[guideID] = ordinal})

    if needUpload or guideID == Guide.config.recordID then
        HttpClient:request{
            moduleName      = "Player",
            methodName      = "AlterPlayerStepCount",
            needWait        = guideID ~= Guide.config.recordID,
            svrMethodData   = {guideID, ordinal},
            callback        = function(response)
                if response.Status == 0 then
                end
            end,
        }
    end
end

--
function GuideMgr:makeExtentionData(guideID, ordinal)
    guideID = guideID or self:getGuideInfo()
    if not guideID then
        return
    end

    ordinal = ordinal or (self:getGuideOrdinal(guideID) + 1)
    if not ordinal then
        return
    end

    return {
        {
            GuideId = tostring(guideID),
            Ordinal = ordinal,
        },
    }
end


-- @是否在引导中
function GuideMgr:isInGuide()
    if not self.mGuideIDMap then
        -- 未初始化直接返回
        return false
    else
        return (self:getGuideInfo() ~= nil)
    end
end

-- 播放音效
function GuideMgr:playSound(file)
    GuideMgr:stopSound()
    if file then
        self.soundID = MqAudio.playEffect(file)
    end
end

-- 停止音效
function GuideMgr:stopSound()
    if self.soundID then
        MqAudio.stopEffect(self.soundID)
        self.soundID = nil
    end
end

-- 根据类型和条件获取引导信息
-- 适用于:GuideTriggerType.eModule、GuideTriggerType.echapteropen、
--       GuideTriggerType.eBattleNodeOrdinalStar、GuideTriggerType.eBattleNodeOrdinalEnd
function GuideMgr:getGuideInfoByType(triggerType, triggerConfig)
    local guideTable = self.mGuideTable[triggerType]
    if not guideTable then
        return
    elseif not triggerConfig then
        return guideTable
    else
        local guideID = guideTable[triggerConfig]
        if guideID then
            local ordinal = self:getGuideOrdinal(guideID)
            local maxOrdinal = #GuideRelation_items[guideID]
            if ordinal <= maxOrdinal then
                local eventID = self:getGuideEventID(guideID, ordinal)
                return guideID, ordinal, eventID
            end
        end
    end
end

-- 领取奖励
--[[
params:{
    <eventID>       事件ID
    <callback>      回调
    [showReward]    是否显示物品
    [extData]       请求时需要携带的引导信息
}
]]
function GuideMgr:getGift(params)
    -- 避免小游戏重复领取奖励
    local guideModel = self:getGuideModel(params.eventID)
    if guideModel and guideModel.triggerTypeEnum == GuideTriggerType.eGame then
        params.showReward = true
        if self:getGuideOrdinal(guideModel.ID) == 886 then
            return params.callback and params.callback(true)
        else
            -- 是小游戏则请求时标记已领取
            params.extData = self:makeExtentionData(guideModel.ID, 886)
        end
    end

    HttpClient:request({
        moduleName      = "Player",
        methodName      = "GetStepCountReward",
        svrMethodData   = {params.eventID},
        guideInfo       = params.extData,
        callback        = function(response)
            if response.Status == 0 or response.Status == -1136 then
                if guideModel and guideModel.triggerTypeEnum == GuideTriggerType.eGame then
                    self:saveGuideStep(guideModel.ID, 886)
                end
                local _ = params.callback and params.callback(true)
                if params.showReward then
                    local data = response.Value
                    if data and data.BaseGetGameResourceList then
                        ui.ShowRewardGoods(data.BaseGetGameResourceList, true)
                    end
                end
            else
                local _ = params.callback and params.callback(false)
            end
        end,
    })
end

----------------- 剧情对话触发 -----------------
-- 触发章节剧情
function GuideMgr:showChapterGuide(charpterID, __callback)
    return self:showDialogGuide(GuideTriggerType.echapteropen, charpterID, __callback)
end

-- 触发战斗前剧情
function GuideMgr:showBeforeBattleGuide(nodeID, __callback)
    -- 打点步骤
    if nodeID == 1115 then
        Guide.hit(200)
    elseif nodeID == 1213 then
        Guide.hit(210)
    end
    return self:showDialogGuide(GuideTriggerType.eBattleNodeOrdinalStar, nodeID, __callback)
end

-- 触发战斗后剧情
function GuideMgr:showAfterBattleGuide(nodeID, __callback)
    -- 打点步骤
    if nodeID == 1115 then
        Guide.hit(220)
    end
    return self:showDialogGuide(GuideTriggerType.eBattleNodeOrdinalEnd, nodeID, __callback)
end

-- 显示剧情对话
function GuideMgr:showDialogGuide(type, config, __callback)
    -- 是否屏蔽新手引导
    if not Guide.config.IF_OPEN then
        return __callback and __callback(true)
    end

    local guideID, ordinal, eventID
       = self:getGuideInfoByType(type, config)

    if not eventID then
        local _ = __callback and __callback(false)
        return false
    end

    -- 标记为已触发
    self:saveGuideStep(guideID, ordinal, nil, self.ifUploadAnyway)

    -- 真正的显示剧情
    self:doShowDialogGuide(guideID, ordinal, eventID, __callback)

    return true
end

function GuideMgr:doShowDialogGuide(guideID, ordinal, eventID, __callback)
    -- 有的剧情没有选择奖励，需要在结束时上传引导步骤
    local needSave = true
    self:showGuideLayer({
        eventID  = eventID,
        nextStep = function(eventID, pickID_or_isSkip, _next)
            if pickID_or_isSkip and type(pickID_or_isSkip) == "number" then
                -- pickID_or_isSkip为number时表示选择奖励
                -- 领取选项奖励
                self:getGift({
                    eventID    = pickID_or_isSkip,
                    showReward = true,
                    guideInfo  = self:makeExtentionData(guideID, ordinal + 1),
                    callback   = function()
                        needSave = nil
                        local _ = _next and _next()
                    end,
                })
            else
                -- 剧情结束
                -- pickID_or_isSkip表示是否跳过对话
                self:removeGuideLayer()

                -- 上传引导步骤
                local isSkip = pickID_or_isSkip -- 是否跳过
                ordinal = ordinal + (isSkip and 2 or 3)
                self:saveGuideStep(guideID, ordinal, nil, needSave or self.ifUploadAnyway)

                return __callback and __callback(true)
            end
        end,
    })
end

return GuideMgr
