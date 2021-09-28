--[[
    filename: GuideHelper.lua
    description: 执行新手引导、跳转页面等
    date: 2016.06.16

    author: 杨科
    email:  h3rvgo@gmail.com
-- ]]

GuideHelper = {}

--@ 尝试执行新手引导
-- 查找传入的eventID是否未当前正在进行的引导，是则执行
--[[
eventIDs(table):   eventID为key，执行该引导所需参数为value

点击事件一般传 clickNode/clickRect
功能开启
发放物品    传nextStep
]]
function GuideHelper:executeGuide(eventIDs)
    -- 获取当前引导
    local _, _, eventID = Guide.manager:getGuideInfo()
    if eventID then
        for id, args in pairs(eventIDs) do
            -- 找到对应引导，开始执行
            if id == eventID then
                self:doExecuteGuide(id, args)
                return true
            end
        end
    else
        Guide.manager:removeGuideLayer()
    end

    return false
end


-- @分类执行引导
function GuideHelper:doExecuteGuide(eventID, args)
    local guideModel = Guide.manager:getGuideModel(eventID)

    local eventModel = guideModel.eventModel

    if eventID == 1020003 then
        -- 弹出提示“李富贵加入队伍”
        Guide.manager:showGuideLayer({
            eventID  = eventID,
            mute     = args.mute,
            nextStep = function()
                Guide.manager:nextStep(eventID, true)
                return args and args.nextStep and args.nextStep(eventID)
            end,
        })
        return

    -- 指引
    elseif eventModel.eventTypeEnum == GuideEventType.ePoint then
        return self:executePoint(guideModel, args)

    -- 对话
    elseif eventModel.eventTypeEnum == GuideEventType.eDailog then
        return self:executeDialog(guideModel, args)

    -- 功能开启
    elseif eventModel.eventTypeEnum == GuideEventType.eGoto then
        self:analysisGoto(eventModel, args)

    -- 发放物品
    elseif eventModel.eventTypeEnum == GuideEventType.eGift then
        Guide.manager:showGuideLayer({
            eventID  = eventID,
            mute     = args.mute,
            nextStep = function(...)
                Guide.manager:nextStep(eventID)
                args.nextStep(...)
            end,
        })
    end
end


-- @执行指引类型引导
function GuideHelper:executePoint(guideModel, args)
    local params = self:getClickConfig(guideModel.eventID)
    params.eventID   = guideModel.eventID

    for k, v in pairs(args) do
        params[k] = v
    end

    -- 如果通过clickNode获取点击位置，尝试覆写点击事件
    if args.clickNode then
        self:hookBtnClickAction(params)
    end

    -- 显示引导页面
    Guide.manager:showGuideLayer(params)
end


-- @执行对话类引导
function GuideHelper:executeDialog(guideModel, args)
    local needSave = true
    Guide.manager:showGuideLayer({
        eventID  = guideModel.eventID,
        nextStep = function(eventID, pickedID, callback)
            if pickedID and type(pickedID) == "number" then
                -- 领取奖励，同时保存这步引导，避免重复执行
                Guide.manager:getGift{
                    eventID    = pickedID,
                    showReward = true,
                    extData    = Guide.manager:makeExtentionData(guideModel.ID
                        , guideModel.ordinal + 1),
                    callback   = function()
                        needSave = nil -- 获取gift时已经上传，无需再次上传
                        local _ = callback and callback()
                    end,
                }
            else
                -- 将引导设到下一步、删除引导页面、回调
                Guide.manager:saveGuideStep(guideModel.ID, guideModel.ordinal + 1, nil, needSave)
                Guide.manager:removeGuideLayer()
                return args and args.nextStep and args.nextStep(eventID)
            end
        end,
    })
end


-- @执行功能开启类引导
function GuideHelper:analysisGoto(eventModel, args)
    return self:showFunctionOpenView(eventModel.ID)
end


-- @获取引导的额外参数配置
function GuideHelper:getClickConfig(eventID)
    return clone(Guide.config.eventParams[eventID]) or {}
end


-- @hook引导按钮点击事件
function GuideHelper:hookBtnClickAction(params)
    local clickNormalButton = Guide.config.clickNormalButton

    if clickNormalButton[params.eventID] ~= nil then
        -- 保存原有点击事件
        local cb = params.clickNode.mClickAction

        -- 设置新的点击事件
        params.clickNode:setClickAction(function(...)
            Guide.manager:removeGuideLayer()
            -- 将引导设到下一步
            Guide.manager:nextStep(params.eventID, clickNormalButton[params.eventID])

            local guideModel = Guide.manager:getGuideModel(params.eventID)
            if guideModel then
                -- 获取当前引导ordinal
                local ordinal = Guide.manager:getGuideOrdinal(guideModel.ID)
                -- 如果 ordinal + 1 仍然有引导，屏蔽点击
                if ordinal and Guide.manager:getGuideEventID(guideModel.ID, ordinal) then
                    -- 如果当前引导未结束，继续屏蔽点击
                    Guide.manager:showGuideLayer({})
                end
            end
            return cb and cb(...)
        end)
    end
end


-- @跳转到主界面
function GuideHelper:showHomeLayer(eventID)
    local data = Guide.config.homeLayerData[eventID]
    if data then
        Guide.manager:showGuideLayer({})
    end

    LayerManager.addLayer{
        name = "home.HomeLayer",
        data = data,
    }
end

-- @跳转到队伍界面
function GuideHelper:showTeamLayer(eventID)
    local data = {showIndex = Guide.config.eventToTeamIdx[eventID or 0]}

    LayerManager.addLayer({
        name        = "team.TeamLayer",
        isRootLayer = true,
        data        = data.showIndex and data or nil,
    })
end

-- @显示功能开启
function GuideHelper:showFunctionOpenView(eventID)
    local config = Guide.config.moduleOpenConfig[eventID]
    if not config then
        return
    end

    local jumpProc

    if config.jump == "home" then
        jumpProc = handler(self, self.showHomeLayer)
    elseif config.jump == "team" then
        jumpProc = handler(self, self.showTeamLayer)
    end

    Guide.manager:showGuideLayer({
        eventID  = eventID,
        icon     = config.icon,
        nextStep = jumpProc,
    })

    return ture
end


-- @播放首场战斗
function GuideHelper:playerFirstBattle()
    -- 播发Cg动画
    local function playCGGame(params)
        LayerManager.addLayer({
            name = "login.CgLayer",
            data = {
                callback = function(isJump)
                    -- 进入主界面后续引导
                    Guide.manager:saveGuideStep(1, 2, nil, true)
                    Guide.helper:showHomeLayer(0)
                end
            },
        })
        -- 打点步骤
        HttpClient:hitPoint(40, params.isskip and 1 or 0)
    end

    -- 播放第一场战斗
    local battleData = require("ComBattle.BattleGuideConfig.Battle000")
    LayerManager.addLayer {
        name = "ComBattle.BattleLayer",
        data = {
            data      = battleData,
            forceSkip = true,
            skip      = {viewable = true,},
            trustee   = {viewable = false, state = bd.trusteeState.eNormal,},
            beforeBattleFunc = function(_, cb)
                return cb and cb()
            end,
            callback  = playCGGame,
        },
    }
end

-- @升级时调用此函数检查是否有功能开启
function GuideHelper:onPlayerLvUp(dry)
    local guideID, _, eventID = Guide.manager:getGuideInfo()
    if not eventID then
        return
    end

    if Guide.config.moduleOpenConfig[eventID]
      -- 判断是否为当前等级引导
      and guideID == Guide.manager:getGuideInfoByType(GuideTriggerType.eModule
            , PlayerAttrObj:getPlayerAttrByName("Lv"))
      then
        if not dry then
            self:showFunctionOpenView(eventID)
        end

        return true
    end
end


-- @引导错误，跳过整个引导
function GuideHelper:guideError(inID, errCode)
    local guideID, _, eventID = Guide.manager:getGuideInfo()
    if eventID and inID == eventID then
        --[[
        if table.indexof({9125, 91154, 91157, 9127}, eventID) then
            Guide.manager:saveGuideStep(guideID, nil, 1821, true)
            return self:showHomeLayer(1821)
        elseif table.indexof({9306, }, eventID) then
            Guide.manager:saveGuideStep(guideID, nil, 136, true)
            return self:showBattleNormalLayer(136)
        end
        --]]

        Guide.manager:saveGuideStep(guideID, inID * 1000 - (errCode % 1000), nil, true)
        Guide.manager:removeGuideLayer()
    end
end


-- @根据传入ID，如果正在进行该ID步骤，则生成上传信息
function GuideHelper:tryGetGuideSaveInfo(inID)
    local guideID, ordinal, eventID = Guide.manager:getGuideInfo()
    if eventID and inID == eventID then
        return Guide.manager:makeExtentionData(guideID, ordinal + 1)
    end
end


-- @穿戴套装
function GuideHelper:suitDress(cb)
    local tempList = {}
    local totalArray = string.split(DressSuitModel.items[35].partList,",")
    for index,value in ipairs(totalArray) do
        table.insert(tempList, DressObj:getPartInforByModelId(tonumber(value)).Id)
    end

    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "DressInfo",
        methodName = "DressCombat",
        svrMethodData = tempList,
        guideInfo = self:tryGetGuideSaveInfo(91155),
        callback = function(response)
            if not response or response.Status ~= 0 then
                return cb(response.Status)
            end
            DressObj:modifyCombatInfo(response.Value.CombatInfo)
            DressObj:setDressSetInfo(response.Value.Info)

            cb(0)
        end,
    })
end


return GuideHelper
