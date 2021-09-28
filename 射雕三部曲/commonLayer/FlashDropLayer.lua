--[[
    文件名：FlashDropLayer.lua
	描述：飘窗展示获得物品资源
	创建人：liaoyuangang
	创建时间：2016.04.18
-- ]]

local FlashDropLayer = class("FlashDropLayer", function()
    return display.newLayer()
end)

--[[
-- 参数params 中的字段为：
    {
        baseDrop: 基础掉落物品列表，在网络请求返回的 Value.BaseGetGameResourceList
        extraDrop: 额外掉落物品列表，在网络请求返回的 Value.ExtraGetGameResource
        resourceList: 自定义物品列表
        isTouchEnable: 是否点击任意地方消失 默认为 true
        endCallBack: 动作执行完毕后的回调
        stayTime: 动作执行停顿时间
        fadeInTime: 渐变出现时间
        fadeOutTime: 渐变消失时间
        customAdd: 自定义添加
        {
            [1] = {
                node:需要自定义添加的节点, 例如 ui.sprite, ui.label 或者其他
                position: (cc.p)添加节点的位置
            }
            ...
        }
    }
]]
function FlashDropLayer:ctor(params)
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
    
    --
    local lines = math.ceil(#self.mResourceList / 4)
    self.mBgSize = cc.size(640, 120 * lines + 30)
    self.mCustomAdd = params.customAdd or {}
    self.mEndCallBack = params.endCallBack or false
    -- 初始化页面控件
    self:initUI()
    -- 显示窗体出现和消失的特效
    self:showEffect(params.stayTime, params.fadeInTime, params.fadeOutTime)
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(false)
    listener:registerScriptHandler(function()
        return true
    end, cc.Handler.EVENT_TOUCH_BEGAN)

    listener:registerScriptHandler(function()
        if params.isTouchEnable ~= false then
            --完毕回调
            if self.mEndCallBack then
                self.mEndCallBack()
            end
            LayerManager.removeLayer(self)
        end

    end, cc.Handler.EVENT_TOUCH_ENDED)

    local dispatcher = self:getEventDispatcher()
    dispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

-- 初始化页面控件
function FlashDropLayer:initUI()
    -- 创建背景图片
    self.mBgSprite = ui.newScale9Sprite("mrjl_01.png", self.mBgSize)
    self.mBgSprite:setScale(Adapter.MinScale)
    self.mBgSprite:setPosition(display.cx, display.cy)
    self:addChild(self.mBgSprite)
    self.mBgSprite:setOpacity(0)

    -- 创建物品
    self.mCardNodeList = {}
    local startPosY = self.mBgSize.height - 60
    local tempPosX = self.mBgSize.width / 2

    for index, item in ipairs(self.mResourceList) do
        local currLine = math.ceil(index / 4)
        local tempIndex = index - (currLine - 1) * 4
        local currLineCount = math.min(#self.mResourceList - (currLine - 1) * 4, 4)
        local tempPosX = (tempPosX - (currLineCount - 1) * 70) + (tempIndex - 1) * 140
        local tempPosY = startPosY - (currLine - 1) * 120

        item.allowClick = false
        item.cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eName, CardShowAttr.eNum, CardShowAttr.eLevel or 0}

        local tempCard = CardNode.createCardNode(item)
        tempCard:setPosition(tempPosX, tempPosY)
        self.mBgSprite:addChild(tempCard)
        tempCard:setOpacity(0)

        table.insert(self.mCardNodeList, tempCard)
    end

    --创建自定义添加
    for k, v in ipairs(self.mCustomAdd) do
        self.mBgSprite:addChild(v.node)
        v.node:setPosition(v.position)
    end
end

-- 显示窗体出现和消失的特效
--[[
prams:
    stayTime: 动作停顿时间
    fadeInTime: 渐变进入时间
    fadeOutTime: 渐变小时时间
--]]
function FlashDropLayer:showEffect(stayTime, fadeInTime, fadeOutTime)
    stayTime = stayTime or math.min(3, #self.mResourceList * 0.2 + 1.6)
    local bgActList = {
        cc.Spawn:create({
            cc.FadeTo:create(fadeInTime or 0.5, 255),
            cc.CallFunc:create(function()
                for _, cardNode in ipairs(self.mCardNodeList) do
                    cardNode:runAction(cc.FadeTo:create(0.5, 255))
                end
            end
        )}),
        cc.DelayTime:create(stayTime),
        cc.Spawn:create({
            cc.JumpBy:create(fadeOutTime or 0.5, cc.p(0, 200 * Adapter.MinScale), 0, 1),
            cc.CallFunc:create(function()
                for _, cardNode in ipairs(self.mCardNodeList) do
                    cardNode:runAction(cc.FadeTo:create(fadeOutTime or 0.5, 0))
                end
            end
        )}),
        cc.CallFunc:create(function()
            --完毕回调
            if self.mEndCallBack then
                self.mEndCallBack()
            end
            LayerManager.removeLayer(self)
        end)
    }
    self.mBgSprite:runAction(cc.Sequence:create(bgActList))
    -- 播放获得奖励音效
    MqAudio.playEffect("reward_flash.mp3")
end

return FlashDropLayer

