--[[
	文件名：RoadOfHeroLayer.lua
	描述：大侠之路页面
	创建人：peiyaoqiang
	创建时间：2018.3.1
--]]
local RoadOfHeroLayer = class("RoadOfHeroLayer", function(params)
    return display.newLayer(cc.c4b(0, 0, 0, 128))
end)

--[[
	params:
	{
	}
--]]
function RoadOfHeroLayer:ctor(params)
    -- 创建背景框
    local bgLayer = ui.newSprite("dxzl_05.png")
    bgLayer:setPosition(cc.p(display.cx, display.cy))
    bgLayer:setScale(Adapter.MinScale)
    self:addChild(bgLayer)

    self.mBgLayer = bgLayer
    self.mBgSize = bgLayer:getContentSize()

    -- 触摸图片外面关闭
    ui.registerSwallowTouch({
        node = self,
        allowTouch = true,
        beganEvent = function(touch, event)
            return true
        end,
        endedEvent = function(touch, event)
            if not ui.touchInNode(touch, self.mBgLayer) then
                LayerManager.removeLayer(self)
            end
        end,
    })
    
    -- 刷新UI
    self:refreshUI()
end

-- 刷新UI
function RoadOfHeroLayer:refreshUI()
    -- 清空以前的内容
    self.mBgLayer:removeAllChildren()

    -- 判断是否完成所有任务
    local currId, currState, _ = RoadOfHeroObj:getCurrTask()
    local taskConfig = MaintaskNodeRelation.items[currId]
    if (taskConfig == nil) or ((currId == table.maxn(MaintaskNodeRelation.items)) and (currState == 3)) then
        self.mBgLayer:setTexture("dxzl_06.png")
        return
    end

    -- 读取当前任务
    local playerLv = PlayerAttrObj:getPlayerInfo().Lv
    local mainConfig = MaintaskModel.items[taskConfig.maintaskID]
    
    -- 显示描述背景
    local infoBgSize = cc.size(self.mBgSize.width - 140, 100)
    local infoBgSprite = ui.newScale9Sprite("c_155.png", infoBgSize)
    infoBgSprite:setAnchorPoint(cc.p(0.5, 1))
    infoBgSprite:setPosition(self.mBgSize.width * 0.5 + 8, self.mBgSize.height - 80)
    self.mBgLayer:addChild(infoBgSprite)

    -- 显示任务的前置条件
    local previewLabel = ui.newLabel({
        text = TR("该任务需要先达到%s级", taskConfig.needLV),
        color = (playerLv >= taskConfig.needLV) and Enums.Color.eNormalGreen or Enums.Color.eRed,
        anchorPoint = cc.p(0, 0.5),
        x = 10,
        y = infoBgSize.height * 0.7,
    })
    infoBgSprite:addChild(previewLabel)

    -- 显示任务的达成条件
    local strInfo = mainConfig.introFormat
    local jumpParams = nil
    if (taskConfig.maintaskID == 2) or (taskConfig.maintaskID == 4) or (taskConfig.maintaskID == 19) or (taskConfig.maintaskID == 24) or (taskConfig.maintaskID == 25) then
        strInfo = string.format(mainConfig.introFormat, taskConfig.condition)
        
        -- 处理跳转参数
        if (taskConfig.maintaskID == 2) or (taskConfig.maintaskID == 4) then
            -- 人物升级或突破
            jumpParams = {originalId = FormationObj:getSlotInfoBySlotId(2).HeroId}
        --elseif (taskConfig.maintaskID == 4) then
        end
    elseif (taskConfig.maintaskID == 1) then
        -- 副本任务
        local strNodeKey = taskConfig.condition - math.floor(taskConfig.condition/100)*100 - 10
        local nodeNameList = {
            [1] = TR("一"), [2] = TR("二"), [3] = TR("三"), [4] = TR("四"), [5] = TR("五"),
            [6] = TR("六"), [7] = TR("七"), [8] = TR("八"), [9] = TR("九"), [10] = TR("十"),
        }
        local battleConfig = BattleNodeModel.items[taskConfig.condition]
        strInfo = TR("通关江湖:第%d章 第%s节", (battleConfig.chapterModelID - 10), nodeNameList[strNodeKey])

        -- 读取可挑战的最大章节
        BattleObj:getBattleInfo(function(info)
            jumpParams = {
                subPageType = ModuleSub.eBattleNormal, 
                subPageData = {[ModuleSub.eBattleNormal] = {chapterId = math.min(battleConfig.chapterModelID, info.MaxChapterId)}}
            }
        end)
    elseif (taskConfig.maintaskID == 3) then
        -- 武林谱任务
        local battleConfig = ElitebattleNodeModel.items[taskConfig.condition]
        strInfo = TR("通关武林谱:%s", battleConfig.name)
    end
    local infoLabel = ui.newLabel({
        text = self.getTaskIntro(),
        color = (currState > 1) and Enums.Color.eNormalGreen or Enums.Color.eRed,
        anchorPoint = cc.p(0, 0.5),
        x = 10,
        y = infoBgSize.height * 0.3,
    })
    infoBgSprite:addChild(infoLabel)

    -- 显示前往或领取按钮
    local btnConfigList = {
        [1] = { -- 已接受，但未完成
            name = TR("前往"),
            clickFunc = function ()
                if (playerLv < taskConfig.needLV) then
                    LayerManager.addLayer({name = "dailytask.DlgUpdateWayLayer", data = {needToLv = taskConfig.needLV,}, cleanUp = false})
                    return
                end
                -- LayerManager.showSubModule(mainConfig.jumpModuleID, jumpParams)
                self.gotoTaskClick()

                -- 避免卡死
                local _, _, eventID = Guide.manager:getGuideInfo()
                if eventID == 9006 then
                    Guide.helper:guideError(eventID, -1)
                end
            end
        },
        [2] = { -- 已完成，但尚未领取奖励
            name = TR("领取"),
            image = "c_33.png",
            clickFunc = function ()
                self:requestDrawReward()
            end
        },
        [3] = { -- 已领取奖励，将自动开启下一个任务
            name = TR("完成"),
            image = "c_33.png",
            clickFunc = function ()
                LayerManager.removeLayer(self)
            end
        },
    }
    local btnConfig = btnConfigList[currState]
    local btnGo = ui.newButton({
        normalImage = btnConfig.image or "c_28.png",
        text = btnConfig.name or "",
        clickAction = btnConfig.clickFunc
    })
    btnGo:setPosition(infoBgSize.width - 70, infoBgSize.height * 0.5+15)
    btnGo:setScale(0.8)
    infoBgSprite:addChild(btnGo)
    -- 保存引导按钮
    self.btnGo = btnGo

    -- 显示任务奖励
    local rewardNode = ui.createCardList({
        maxViewWidth = self.mBgSize.width - 140,
        viewHeight = 120,
        cardShowAttrs = {},
        cardDataList = Utility.analysisStrResList(taskConfig.reward),
        allowClick = true,
        isSwallow = false,
    })
    rewardNode:setAnchorPoint(cc.p(0.5, 0))
    rewardNode:setPosition(self.mBgSize.width * 0.5 + 8, 65)
    self.mBgLayer:addChild(rewardNode)
end

-- 大侠之路获取任务描述
function RoadOfHeroLayer.getTaskIntro()
    -- 判断是否完成所有任务
    local currId, currState, currProg = RoadOfHeroObj:getCurrTask()
    
    local taskConfig = MaintaskNodeRelation.items[currId]
    if (taskConfig == nil) or ((currId == table.maxn(MaintaskNodeRelation.items)) and (currState == 3)) then
        return TR("已完成所有任务"), ""
    end

    local taskIntro = MaintaskModel.items[taskConfig.maintaskID].introFormat
    local progColor = "#ea2c00"
    -- 普通副本
    if taskConfig.maintaskID == 1 then
        local battleNodeInfo = BattleNodeModel.items[taskConfig.condition]
        taskIntro = string.format(taskIntro, battleNodeInfo.chapterModelID-10, battleNodeInfo.name)
    -- 武林谱
    elseif taskConfig.maintaskID == 3 then
        local battleConfig = ElitebattleNodeModel.items[taskConfig.condition]
        taskIntro = string.format(taskIntro, battleConfig.name)
    -- 神兵锻造
    elseif taskConfig.maintaskID == 12 then
        taskIntro = string.format(taskIntro, Utility.getColorName(Utility.getQualityColorLv(taskConfig.condition)))
    else
        taskIntro = string.format(taskIntro, taskConfig.condition)
    end

    -- 任务进度
    if taskConfig.maintaskID == 1 or taskConfig.maintaskID == 2 or
         taskConfig.maintaskID == 3 or taskConfig.maintaskID == 6 or
         taskConfig.maintaskID == 12 or taskConfig.maintaskID == 14 or
         taskConfig.maintaskID == 32 then
        taskIntro = taskIntro .. progColor .. string.format("（%d/%d）", currState == 2 and 1 or 0, 1)
    else
        taskIntro = taskIntro .. progColor .. string.format("（%d/%d）", currProg, taskConfig.condition)
    end

    -- 任务奖励
    local taskRewardList = {}
    for _, rewardInfo in pairs(Utility.analysisStrResList(taskConfig.reward)) do
        taskReward = Utility.getGoodsName(rewardInfo.resourceTypeSub, rewardInfo.modelId) .. "*".. Utility.numberWithUnit(rewardInfo.num)
        table.insert(taskRewardList, taskReward)
    end

    return taskIntro, table.concat(taskRewardList, "，")
end

-- 大侠之路获取跳转参数
function RoadOfHeroLayer.gotoTaskClick()
    -- 判断是否完成所有任务
    local currId, currState, _ = RoadOfHeroObj:getCurrTask()
    local taskConfig = MaintaskNodeRelation.items[currId]
    if (taskConfig == nil) or ((currId == table.maxn(MaintaskNodeRelation.items)) and (currState == 3)) then
        return
    end
    local mainConfig = MaintaskModel.items[taskConfig.maintaskID]

    -- 普通副本
    if taskConfig.maintaskID == 1 then
        -- 读取可挑战的最大章节
        BattleObj:getBattleInfo(function(info)
            local battleNodeInfo = BattleNodeModel.items[taskConfig.condition]

            local jumpParams = {
                subPageType = ModuleSub.eBattleNormal, 
                subPageData = {
                [ModuleSub.eBattleNormal] = {
                    chapterId = info.MaxNodeId >= battleNodeInfo.ID and battleNodeInfo.chapterModelID or info.MaxChapterId,
                    nodeId = info.MaxNodeId >= battleNodeInfo.ID and battleNodeInfo.ID or nil
                }}
            }

            LayerManager.showSubModule(mainConfig.jumpModuleID, jumpParams)
        end)
    -- 主角突破
    elseif (taskConfig.maintaskID == 6) then
        jumpParams = {originalId = FormationObj:getSlotInfoBySlotId(1).HeroId}
        LayerManager.showSubModule(mainConfig.jumpModuleID, jumpParams)
    -- 人物升级或突破
    elseif (taskConfig.maintaskID == 2) or (taskConfig.maintaskID == 4) or (taskConfig.maintaskID == 16) then
        jumpParams = {originalId = FormationObj:getSlotInfoBySlotId(2).HeroId}
        LayerManager.showSubModule(mainConfig.jumpModuleID, jumpParams)
    else
        LayerManager.showSubModule(mainConfig.jumpModuleID)
    end

    -- 若已完成任务，直接发奖
    if currState == 2 then
        RoadOfHeroObj:getReward()
    end
end

----------------------------------------------------------------------------------------------------
-- 网络接口

-- 获取每日任务的数据
function RoadOfHeroLayer:requestDrawReward()
    HttpClient:request({
        moduleName = "MaintaskInfo",
        methodName = "DrawMainTaskReward",
        callbackNode = self,
        guideInfo = Guide.helper:tryGetGuideSaveInfo(9006),
        callback = function (data)
            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end
            --[[--------新手引导--------]]--
            local _, _, eventID = Guide.manager:getGuideInfo()
            if eventID == 9006 then
                Guide.manager:nextStep(eventID)
                Guide.manager:removeGuideLayer()
            end

            -- 飘窗显示,领取的宝箱奖品
            ui.ShowRewardGoods(data.Value.BaseGetGameResourceList)
            -- 刷新缓存
            RoadOfHeroObj:setCurrTask({MaintaskId = data.Value.MainTaskInfo.Id, MaintaskStatus = data.Value.MainTaskInfo.Status})
            -- 刷新页面
            self:refreshUI()
        end
    })
end

function RoadOfHeroLayer:onEnterTransitionFinish()
    self:executeGuide()
end

function RoadOfHeroLayer:executeGuide()
    Guide.helper:executeGuide({
        -- 前往
        [9003] = {clickNode = self.btnGo},
        [9006] = {clickNode = self.btnGo},
    }, nil, true)
end

return RoadOfHeroLayer
