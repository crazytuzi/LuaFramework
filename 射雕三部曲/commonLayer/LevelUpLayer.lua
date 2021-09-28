--[[
    文件名：LevelUpLayer
    描述：升级提示页面
    创建人：liaoyuangang
    创建时间：2016.5.25
-- ]]

local LevelUpLayer = class("LevelUpLayer",function()
	return  display.newLayer(cc.c4b(0x1A, 0x1A, 0x1A, 200))
end)

--[[
-- params:
    lvUpData: -- 玩家升级前后的数据
    callback: -- 确定按钮回调函数
--]]
function LevelUpLayer:ctor(params)

    -- 玩家升级前后的数据
    self.mLvUpData = params and params.lvUpData or {}
    -- 关闭升级页面的回调函数
    self.callback = params and params.callback

	-- 屏蔽下层点击事件
    ui.registerSwallowTouch({
        node = self,
        endedEvent = function(touch, event)
            self:closeLayer()
        end,
    })

    -- 整理页面需要显示的属性数据
    self.mViewData = {}
    -- 页面需要显示的模块调整按钮信息
    self.mBtnInfo = {}
    -- 整理页面需要显示的属性数据
    self:initData()

    -- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- 延迟创建控件的parent
    self.mDelayParentLayer = cc.Node:create()
    self.mParentLayer:addChild(self.mDelayParentLayer)

    self:initUI()
end

-- 整理页面需要显示的属性数据
function LevelUpLayer:initData()
    -- 升级前的配置数据
    local oldRelation = PlayerLvRelation.items[self.mLvUpData.oldLv]
    -- 升级后的配置数据
    local newRelation = PlayerLvRelation.items[self.mLvUpData.newLv]

    -- 等级
    table.insert(self.mViewData, {
        name = TR("等       级"),
        oldValue = self.mLvUpData.oldLv,
        newValue = self.mLvUpData.newLv
    })
    -- 气力
    table.insert(self.mViewData, {
        name = TR("气       力"),
        oldValue = self.mLvUpData.oldSTA,
        newValue = self.mLvUpData.newSTA
    })
    -- 好友个数上限
    if newRelation.friendMax > oldRelation.friendMax then
        table.insert(self.mViewData, {
            name = TR("好友个数"),
            oldValue = oldRelation.friendMax,
            newValue = newRelation.friendMax
        })
    end
    -- 闯荡次数
    if ModuleInfoObj:moduleIsOpen(ModuleSub.eChallengeGrab, false) then
        if self.mLvUpData.newXYCurCount > self.mLvUpData.oldXYCurCount then
            table.insert(self.mViewData, {
                name = TR("闯荡次数"),
                oldValue = self.mLvUpData.oldXYCurCount,
                newValue = self.mLvUpData.newXYCurCount
            })
        end
    end

    -- 功能模块跳转按钮
    self.mBtnInfo = ConfigFunc:getOpenModuleInfo(self.mLvUpData.newLv)
end

-- 初始化页面控件
function LevelUpLayer:initUI()
    -- local bgSprite = ui.newSprite("zdjs_10.png")
    -- bgSprite:setPosition(cc.p(320, 800))
    -- self.mParentLayer:addChild(bgSprite)

    -- local tempSprite = ui.newSprite("zdjs_13.png") --临时飘带，特效出后删掉
    -- tempSprite:setPosition(320, 850)
    -- self.mParentLayer:addChild(tempSprite)

    -- local bottomBgSprite = ui.newSprite("zdjs_05.png")
    -- bottomBgSprite:setAnchorPoint(cc.p(0.5, 1))
    -- bottomBgSprite:setPosition(cc.p(320, 830))
    -- self.mParentLayer:addChild(bottomBgSprite)

    Utility.performWithDelay(self.mParentLayer, function()
        self:delayInitUI()
    end, 0.1)

    local attrBgSize = cc.size(0, 180)
    -- 升级后属性变化的背景
    local attrBgSprite = ui.newScale9Sprite("c_101.png", attrBgSize)
    attrBgSprite:setPosition(cc.p(320, 750))
    attrBgSprite:setOpacity(0)
    self.mParentLayer:addChild(attrBgSprite)

    -- 升级后的属性变化信息
    local spaceY = 55
    local startPosY = (attrBgSize.height + #self.mViewData * spaceY )/ 2 - spaceY / 2 - 80
    local leftPosX, rightPosX = 120, 410
    for index, item in pairs(self.mViewData) do
        local tempPosY = startPosY - (index - 1) * spaceY

        -- 显示背景
        local labelBgSprite = ui.newSprite("zdjs_06.png")
        labelBgSprite:setPosition(cc.p(attrBgSize.width / 2, tempPosY))
        attrBgSprite:addChild(labelBgSprite)

        -- 升级前的属性显示
        local oldLabel = ui.newLabel({
            text = string.format("%s:  %d", item.name, item.oldValue),
            color = Enums.Color.eNormalWhite,
            size = 22,
        })
        oldLabel:setAnchorPoint(cc.p(0, 0.5))
        oldLabel:setPosition(-300, 25)
        labelBgSprite:addChild(oldLabel)

        -- 播放出现时的特效
        oldLabel:runAction(cc.Sequence:create(
            cc.DelayTime:create(0.1 * index),
            cc.MoveTo:create(0.2, cc.p(leftPosX, 25))
        ))

         -- 显示中间箭头
        local tempSprite = ui.newSprite("zdjs_11.png")
        tempSprite:setPosition(340, 25)
        labelBgSprite:addChild(tempSprite)

        -- 升级后的属性显示
        local newLabel = ui.newLabel({
            text = string.format("%s:  %s%d", item.name, "#57DC45", item.newValue),
            color = Enums.Color.eNormalWhite,
            size = 22,
        })
        newLabel:setAnchorPoint(cc.p(0, 0.5))
        newLabel:setPosition(700, 25)
        labelBgSprite:addChild(newLabel)

        -- 播放出现时的特效
        newLabel:runAction(cc.Sequence:create(
            cc.DelayTime:create(0.1 * index),
            cc.MoveTo:create(0.2, cc.p(rightPosX, 25))
        ))
    end

    -- 创建listview
    local mListView = ccui.ListView:create()
    mListView:setDirection(ccui.ScrollViewDir.vertical)
    mListView:setGravity(ccui.ListViewGravity.centerVertical)
    mListView:setBounceEnabled(false)
    mListView:setContentSize(cc.size(640, 320))
    mListView:setAnchorPoint(cc.p(0.5, 0))
    mListView:setPosition(320, 255)
    mListView:setChildrenActionType(ui.LISTVIEW_ACTION_NONE)
    self.mParentLayer:addChild(mListView)
    self.mListView = mListView

    self:refreshListItem()

    -- 点击屏幕提示信息的label
    local hintLabel = ui.newLabel({
        text = TR("点击屏幕继续"),
        color = Enums.Color.eNormalWhite,
        outlineColor = Enums.Color.eBlack,
    })
    hintLabel:setPosition(320, 190)
    self.mParentLayer:addChild(hintLabel)
    -- 添加动作
    local action = {
        cc.ScaleTo:create(0.5, 1.1),
        cc.ScaleTo:create(0.5, 1)
    }
    hintLabel:runAction(cc.RepeatForever:create(cc.Sequence:create(action)))
end

local width, height = 640, 130
-- 创建单个Item
function LevelUpLayer:refreshListItem()
    self.gotoButtonList = {}
    local newBtnCount = 0
    for _, btnInfo in pairs(self.mBtnInfo) do
        if next(btnInfo) then
            -- 创建cell
            local customCell = ccui.Layout:create()
            customCell:setContentSize(cc.size(width, height))
            self.mListView:pushBackCustomItem(customCell)
            newBtnCount = newBtnCount + 1

            -- 图标
            local moduleBtn = ui.newButton({
                normalImage = btnInfo.modulePic .. ".png",
                clickAction = function()
                    -- 新手引导，执行下一步
                    local playerLv = PlayerAttrObj:getPlayerAttrByName("Lv")
                    local guideID, ordinal, eventID = Guide.manager:getGuideInfoByType(GuideTriggerType.eModule, playerLv)
                    if guideID and ordinal == 1 then
                        Guide.manager:removeGuideLayer()
                        Guide.manager:nextStep(eventID)
                    end

                    if btnInfo.moduleID == "" then
                        LayerManager.addLayer({name = "home.HomeLayer"})
                    else
                        LayerManager.showSubModule(tonumber(btnInfo.moduleID))
                    end
                end
            })
            -- moduleBtn:setAnchorPoint(cc.p(0.5, 0))
            moduleBtn:setPosition(width * 0.2, 80)
            customCell:addChild(moduleBtn)
            -- 保存按钮
            table.insert(self.gotoButtonList, moduleBtn)

            local moduleNameLabel = ui.newLabel({
                text = btnInfo.moduleName,
                size = 22,
                color = cc.c3b(0xfd, 0xc9, 0x7f),
                })
            moduleNameLabel:setPosition(width * 0.5, 115)
            customCell:addChild(moduleNameLabel)

            local moduleIntroLabel = ui.newLabel({
                text = btnInfo.intro,
                size = 20,
                color = cc.c3b(0xb6, 0x8c, 0x6a),
                dimensions = cc.size(200, 0)
                })
            moduleIntroLabel:setAnchorPoint(0.5, 1)
            moduleIntroLabel:setPosition(width * 0.5, 100)
            customCell:addChild(moduleIntroLabel)
            dump(btnInfo)

            local openSprite = ui.newSprite("zdjs_10.png")
            openSprite:setPosition(width * 0.85, 80)
            customCell:addChild(openSprite)

            dump(self.mLvUpData.newLv,"self.mLvUpData.newLv")
            if self.mLvUpData.newLv < btnInfo.openLv then
                openSprite:setTexture("zdjs_12.png")
                local openLabel = ui.newLabel({
                    text = (TR("%d级开启", btnInfo.openLv)),
                    size = 18,
                    color = cc.c3b(0xed, 0x6b, 0x56),
                    })
                openLabel:setPosition(44, 35)
                openLabel:setRotation(-18)
                openSprite:addChild(openLabel)
            end

            -- 判断是否开启
            -- local openLabel = ui.newLabel({
            --     text = (self.mLvUpData.newLv >= openLv) and TR("点击前往") or TR("%d级开启", openLv),
            --     size = 20,
            --     color = (self.mLvUpData.newLv >= openLv) and Enums.Color.eNormalGreen or Enums.Color.eRed,
            -- })
            -- openLabel:setAnchorPoint(cc.p(0.5, 0))
            -- openLabel:setPosition(width * 0.5, 0)
            -- customCell:addChild(openLabel)
        end
    end

    if (newBtnCount == 0) then
        local label = ui.newLabel({
            text = TR("暂无新功能开启"),
            size = 26,
            color = Enums.Color.eNormalWhite,
        })
        label:setPosition(320, 405)
        self.mParentLayer:addChild(label)
        self.mListView:setVisible(false)
    elseif (newBtnCount <= 3) then
        -- self.mListView:setContentSize(cc.size(width, 120))
    end
end


-- 延迟创建页面控件
function LevelUpLayer:delayInitUI()
    -- 显示页面的光柱效果
    local effect = ui.newEffect({
        parent = self.mParentLayer,
        effectName = "effect_ui_gongxishenji_tw",
        position = cc.p(320, 855),
        loop = false,
        zorder = -1,
        animation = "kaishi",
        endRelease = true,
        completeListener = function()
            ui.newEffect({
                parent = self.mParentLayer,
                effectName = "effect_ui_gongxishenji_tw",
                position = cc.p(320, 855),
                zorder = -1,
                loop = true,
                animation = "xuanhuan",
                endRelease = false,
            })
        end,
    })

    MqAudio.playEffect("gongxishengji.mp3")
end

-- 关闭页面的逻辑处理
function LevelUpLayer:closeLayer()
    -- 判断是否新功能开启
    if Guide.helper:onPlayerLvUp() then
        LayerManager.removeLayer(self)
        return
    end

    local callback = self.callback
    LayerManager.removeLayer(self)
    if callback then
        callback()
    end
end

--[[---------------------新手引导---------------------]]--
-- 进入该页面时的执行函数
function LevelUpLayer:onEnterTransitionFinish()
    self:executeGuide()
end

-- 执行新手引导
function LevelUpLayer:executeGuide()
    local playerLv = PlayerAttrObj:getPlayerAttrByName("Lv")
    -- 是否有模块开启
    local guideID, ordinal, eventID = Guide.manager:getGuideInfoByType(GuideTriggerType.eModule, playerLv)
    if not guideID or ordinal > 1 then
        -- 如当前有引导且不是开启功能，则屏蔽跳转按钮点击
        local _, _, curEventID = Guide.manager:getGuideInfo()
        if curEventID then
            for _,v in ipairs(self.gotoButtonList) do
                v:setEnabled(false)
            end
        end
    else
        if #GuideRelation.items[guideID] > 1 then
            -- 先屏蔽界面
            Guide.manager:showGuideLayer({})
            -- 强制引导
            Utility.performWithDelay(self.gotoButtonList[1], function ()
                Guide.helper:executeGuide({
                    [eventID] = {clickNode = self.gotoButtonList[1],},
                })
            end, 0.1)
        else
            Guide.helper:executeGuide({
                [eventID] = {clickRect = cc.rect(display.cx - 150 * Adapter.MinScale, display.cy, 0, 0),
                    hintPos = cc.p(display.cx, 140 * Adapter.MinScale), 
                    nextStep = function ( )
                        Guide.manager:removeGuideLayer()
                        -- 非强制引导仅有一步
                        Guide.manager:nextStep(eventID, true)
                    end},
            })
        end
    end
end

return LevelUpLayer
