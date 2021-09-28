--[[
    文件名：StepDropLayer.lua
	描述：一个一个出现展示获得物品资源
	创建人：yanghongsheng
	创建时间：2019.01.12
-- ]]

StepDropLayer = class("StepDropLayer", function()
    return display.newLayer(cc.c4b(0, 0, 0, 178))
end)

--[[
-- 参数params 中的字段为：
    {
        baseDrop: 基础掉落物品列表，在网络请求返回的 Value.BaseGetGameResourceList
        extraDrop: 额外掉落物品列表，在网络请求返回的 Value.ExtraGetGameResource
        resourceList: 自定义物品列表
        showCallBack: 全部显示后回调
        endCallBack: 关闭页面前回调
        isOutOrder: 是否乱序
        DIYUiCallback:  可选参数，调用者DIY页面的回调，回调参数为 (parent, bgSize, cardListSize, cardListView), 默认为 nil
    }
]]
function StepDropLayer:ctor(params)
    self.mResourceList = {}
    --self.mResourceList = Utility.analysisGameDrop(params.baseDrop, params.extraDrop)

	-- 处理数据（默认显示方式会显示几十个相同的物体，因此要将其折叠起来，方便显示）
    local tmpResourceList = Utility.analysisGameDrop(params.baseDrop, params.extraDrop)
    local function addItemToResList(item)
        local isFind = false
        for _,tmpV in pairs(self.mResourceList) do
            if (tmpV.modelId == item.modelId) then
                tmpV.instanceData.Num = tmpV.instanceData.Num + (item.num or 1)
                isFind = true
                break
            end
        end
        if (isFind == false) then
            local tmpItem = clone(item)
            tmpItem.instanceData.Num = tmpItem.num or 1
            table.insert(self.mResourceList, tmpItem)
        end
    end
    for _,v in pairs(tmpResourceList) do
        if (v.modelId ~= nil) and (v.modelId > 0) and (v.instanceData ~= nil) then
            addItemToResList(v)
        else
            table.insert(self.mResourceList, clone(v))
        end
    end
    for _,v in pairs(params.resourceList or {}) do
    	table.insert(self.mResourceList, clone(v))
    end
    
    self.mEndCallBack = params.endCallBack or false
    self.mShowCallBack = params.showCallBack or false
    self.mCol = 4
    self.mIsShowEnd = false   -- 奖励是否已全部显示出来
    self.mIsOutOrder = params.isOutOrder
    self.mDIYUiCallback = params.DIYUiCallback

    -- 初始化页面控件
    self:initUI()
    -- 显示窗体出现和消失的特效
    self:showEffect()
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(function()
        return true
    end, cc.Handler.EVENT_TOUCH_BEGAN)

    listener:registerScriptHandler(function(touch, event)
        if self.mIsShowEnd then
            if ui.touchInNode(touch, self.mListView) then return end
            --完毕回调
            if self.mEndCallBack then
                self.mEndCallBack()
            end
            LayerManager.removeLayer(self)
        else
            -- 全部显示出来
            self:showAllReward()
            --全部显示回调
            if self.mShowCallBack then
                self.mShowCallBack()
            end
        end

    end, cc.Handler.EVENT_TOUCH_ENDED)

    local dispatcher = self:getEventDispatcher()
    dispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

-- 初始化页面控件
function StepDropLayer:initUI()
    local lines = math.ceil(#self.mResourceList / self.mCol)
    local cardHightNum = 4
    local cardListSize = cc.size(640, 120 * (lines > cardHightNum and cardHightNum or lines) + 30)
    self.mBgSize = cc.size(cardListSize.width, cardListSize.height+340)
    -- 创建父节点
    self.mParentLayer = cc.Node:create()
    self.mParentLayer:setContentSize(self.mBgSize)
    self.mParentLayer:setScale(Adapter.MinScale)
    self.mParentLayer:setAnchorPoint(cc.p(0.5, 0.5))
    self.mParentLayer:setPosition(display.cx, display.cy+Adapter.MinScale*100)
    self:addChild(self.mParentLayer)

    -- 奖励列表
    self.mListView = ccui.ListView:create()
    self.mListView:setDirection(ccui.ScrollViewDir.vertical)
    self.mListView:setContentSize(cc.size(cardListSize.width, cardListSize.height-30))
    self.mListView:setAnchorPoint(cc.p(0.5, 1))
    self.mListView:setPosition(self.mBgSize.width*0.5, self.mBgSize.height-355)
    self.mListView:setSwallowTouches(false)
    self.mParentLayer:addChild(self.mListView, 1)
    -- 乱序
    if self.mIsOutOrder then
        self.mResourceList = Utility.shuffle(self.mResourceList)
    end
    -- 创建物品
    self.mCardNodeList = {}
    local startPosY = self.mBgSize.height - 60
    local tempPosX = self.mBgSize.width / 2

    if #self.mResourceList > self.mCol then
        for i = 1, math.ceil(#self.mResourceList/self.mCol) do
            local cellSize = cc.size(self.mListView:getContentSize().width, 120)
            local itemCell = ccui.Layout:create()
            itemCell:setContentSize(cellSize)
            self.mListView:pushBackCustomItem(itemCell)

            local space = 140
            for j = 1, self.mCol do
                local index = (i-1)*self.mCol + j
                local resInfo = self.mResourceList[index]
                if not resInfo then break end

                resInfo.allowClick = false
                resInfo.cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eName, CardShowAttr.eNum, CardShowAttr.eLevel or 0}

                local tempCard = CardNode.createCardNode(resInfo)
                tempCard:setPosition(cellSize.width*0.5 - space*self.mCol*0.5 + j*space-0.5*space, cellSize.height*0.5+10)
                itemCell:addChild(tempCard)
                tempCard:setSwallowTouches(false)

                table.insert(self.mCardNodeList, tempCard)
            end
        end
    else
        local cellSize = cc.size(self.mListView:getContentSize().width, 120)
        local itemCell = ccui.Layout:create()
        itemCell:setContentSize(cellSize)
        self.mListView:pushBackCustomItem(itemCell)

        local space = 140
        for i, resInfo in ipairs(self.mResourceList) do
            resInfo.allowClick = false
            resInfo.cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eName, CardShowAttr.eNum, CardShowAttr.eLevel or 0}

            local tempCard = CardNode.createCardNode(resInfo)
            tempCard:setPosition(space*i-space*0.5+cellSize.width*0.5-space*#self.mResourceList*0.5, cellSize.height*0.5+10)
            itemCell:addChild(tempCard)
            tempCard:setSwallowTouches(false)

            table.insert(self.mCardNodeList, tempCard)
        end
    end

    -- 创建其他ui
    if self.mDIYUiCallback then
        self.mDIYUiCallback(self.mParentLayer, self.mBgSize, cardListSize, self.mListView)
    else
        self:createOtherUI(cardListSize)
    end
end

-- 显示窗体出现和消失的特效
--[[
prams:
    stayTime: 动作停顿时间
    fadeInTime: 渐变进入时间
    fadeOutTime: 渐变小时时间
--]]
function StepDropLayer:showEffect()
    local cardTime = 0
    for i, card in ipairs(self.mCardNodeList) do
        cardTime = self:createCardAction(i, true)
    end
    self.listviewAction(self.mListView, cardTime*self.mCol, true)
    -- 播放获得奖励音效
    MqAudio.playEffect("reward_gongxihuode.mp3")
end

function StepDropLayer.listviewAction(listObj, dt, isAction)
    if not listObj then
        return
    end
    if not dt then
        dt = 0.5
    end

    -- 取消动作
    if not isAction then
        for _, item in pairs(listObj:getItems()) do
            item:stopAllActions()
        end
        listObj:jumpToTop()
        return
    end

    -- 设置动画效果
    listObj:forceDoLayout()
    local innerNode = listObj:getInnerContainer()
    local listSize = listObj:getContentSize()
    local innerSize = innerNode:getContentSize()
    local innerX, innerY = innerNode:getPosition()

    local listCount = 0
    local curItem = listObj:getItem(listCount)
    while curItem do
        -- 动画配置
        local actionList = {
            -- 延时
            cc.DelayTime:create(listCount*dt),
            -- 动作
            cc.CallFunc:create(function(curItem)
                local x, y = curItem:getPosition()
                local offestY = innerSize.height - y
                if offestY > listSize.height then
                    local moveInner = cc.MoveTo:create(0.25, cc.p(innerX, -y))
                    innerNode:runAction(moveInner)
                end
            end)
        }
        -- 执行动作
        curItem:runAction(cc.Sequence:create(actionList))
        -- 更新循环变量
        listCount = listCount + 1
        curItem = listObj:getItem(listCount)
    end
end

function StepDropLayer:createCardAction(index, isAction)
    self.mUseTime = self.mUseTime or 0
    local cardObj = self.mCardNodeList[index]
    if isAction then
        cardObj:setOpacity(0)
        cardObj:setVisible(false)
    else
        cardObj:stopAllActions()
        cardObj:setVisible(true)
        cardObj:setOpacity(255)
        return 0
    end

    local time = 0.2
    local delayAction = cc.DelayTime:create(self.mUseTime)
    local callAction = cc.CallFunc:create(function (nodeObj)
        cardObj:setVisible(true)
        if index == #self.mCardNodeList then
            self.mIsShowEnd = true
            if self.mShowCallBack then
                self.mShowCallBack()
            end
        end
    end)
    local fadeAction = cc.FadeTo:create(time, 255)
    cardObj:runAction(cc.Sequence:create({delayAction, callAction, fadeAction})) 

    self.mUseTime = self.mUseTime + time

    return time
end

-- 全部显示出来
function StepDropLayer:showAllReward()
    for i, card in ipairs(self.mCardNodeList) do
        cardTime = self:createCardAction(i, false)
    end
    self.listviewAction(self.mListView, 0, false)
    self.mIsShowEnd = true
    if self.mShowCallBack then
        self.mShowCallBack()
    end
end

-- 创建界面特效显示
function StepDropLayer:createOtherUI(cardListSize)
    -- 创建光
    ui.newEffect({
            parent = self.mParentLayer,
            effectName = "effect_ui_gongxihuode",
            animation = "zhuan",
            loop = true,
            position = cc.p(self.mBgSize.width*0.5, self.mBgSize.height-320),
        })
    -- 创建恭喜获得
    ui.newEffect({
            parent = self.mParentLayer,
            effectName = "effect_ui_gongxihuode",
            animation = "gongxihuode",
            loop = false,
            position = cc.p(self.mBgSize.width*0.5, self.mBgSize.height-320),
            endRelease = false,
        })

    -- 创建奖励列表背景
    local bgSprite = ui.newScale9Sprite("mrjl_01.png", cardListSize)
    bgSprite:setPosition(self.mBgSize.width*0.5, self.mBgSize.height-340)
    bgSprite:setAnchorPoint(cc.p(0.5, 1))
    self.mParentLayer:addChild(bgSprite)
    -- 创建点击提示
    local hintLabel = ui.newLabel({
            text = TR("点击空白处继续"),
            color = Enums.Color.eWhite,
            outlineColor = cc.c3b(0x46, 0x22, 0x0d),
        })
    hintLabel:setPosition(self.mBgSize.width*0.5, -40)
    bgSprite:addChild(hintLabel)
    -- 闪烁动作
    hintLabel:runAction(cc.RepeatForever:create(cc.Sequence:create({cc.FadeOut:create(1), cc.FadeIn:create(1)})))
end

-- 创建华山论剑升级弹窗显示
function StepDropLayer.createPvpLvUpBox(baseGetGameResourceList, extraGetGameResource, hintStr)
    local function DIYUiCallback(parent, bgSize, cardListSize, cardListView)
        -- 创建光
        ui.newEffect({
                parent = parent,
                effectName = "effect_ui_gongxihuode",
                animation = "zhuan",
                loop = true,
                position = cc.p(bgSize.width*0.5, bgSize.height-320),
            })
        -- 创建恭喜获得
        ui.newEffect({
                parent = parent,
                effectName = "effect_ui_gongxihuode",
                animation = "paimingtisheng",
                loop = false,
                position = cc.p(bgSize.width*0.5, bgSize.height-320),
                endRelease = false,
            })

        -- 创建奖励列表背景
        local bgSprite = ui.newScale9Sprite("mrjl_01.png", cc.size(cardListSize.width, cardListSize.height+30))
        bgSprite:setPosition(bgSize.width*0.5, bgSize.height-340)
        bgSprite:setAnchorPoint(cc.p(0.5, 1))
        parent:addChild(bgSprite)
        -- 设置奖励列表位置
        cardListView:setPosition(bgSize.width*0.5, bgSize.height-385)
        -- 创建奖励提示
        local tempLabel = ui.newLabel({
                text = hintStr,
                color = Enums.Color.eWhite,
                outlineColor = cc.c3b(0x46, 0x22, 0x0d),
            })
        tempLabel:setPosition(bgSize.width*0.5, bgSprite:getContentSize().height-20)
        bgSprite:addChild(tempLabel)
        -- 创建点击提示
        local hintLabel = ui.newLabel({
                text = TR("点击空白处继续"),
                color = Enums.Color.eWhite,
                outlineColor = cc.c3b(0x46, 0x22, 0x0d),
            })
        hintLabel:setPosition(bgSize.width*0.5, -40)
        bgSprite:addChild(hintLabel)
        -- 闪烁动作
        hintLabel:runAction(cc.RepeatForever:create(cc.Sequence:create({cc.FadeOut:create(1), cc.FadeIn:create(1)})))
    end

    LayerManager.addLayer({
            name = "commonLayer.StepDropLayer",
            data = {
                baseDrop = baseGetGameResourceList,
                extraDrop = extraGetGameResource,
                DIYUiCallback = DIYUiCallback,
            },
            cleanUp = false,
        })
end

return StepDropLayer

