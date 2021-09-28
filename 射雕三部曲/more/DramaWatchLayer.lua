--[[
    文件名：DramaWatchLayer
    描述：观看剧情场景页面
    创建人：chenzhong
    创建时间：2017.12.5
-- ]]

local DramaWatchLayer = class("DramaWatchLayer",function ()
    return cc.LayerColor:create(cc.c4b(0, 0, 0, 192))
end)

--主界面初始化
--[[
    params: 参数列表
    {
        nodeInfo: 可选参数，第几章
        callback
    }
--]]
function DramaWatchLayer:ctor(params)
    --变量
    self.mNodeInfo = params.nodeInfo or {}
    self.mCallBack = params.callback
    self.mWatchNum = params.watchNum or 0
    dump(self.mNodeInfo,"self.mNodeInfo")
    ui.registerSwallowTouch({node = self})
    -- 创建标准容器
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    self.mChaildLayer = ui.newStdLayer()
    self:addChild(self.mChaildLayer)

    -- 初始化UI
    self:initUI()

    -- 显示奖励还有观看按钮状态
    self:showRewardAndBtn()
end

--初始化UI
function DramaWatchLayer:initUI()
    -- 背景
    local bgSprite = ui.newSprite("jq_8.png")
    bgSprite:setPosition(320, 568)
    self.mParentLayer:addChild(bgSprite)
    local bgSize = bgSprite:getContentSize()
    self.bgSprite = bgSprite

    -- 退出按钮
    local closeBtn = ui.newButton({
        normalImage = "c_29.png",
        clickAction = function()
            if self.mCallBack then 
                self.mCallBack(self.mDramaInfo)
            end     
            LayerManager.removeLayer(self)
        end     
    })
    closeBtn:setPosition(594, 906)
    self.mParentLayer:addChild(closeBtn)

    -- 显示名字
    local nameLabel = ui.newLabel({
        text = self.mNodeInfo.name,
        -- color = cc.c3b(0x46, 0x22, 0x0d),
        size = 30,
        outlineColor = Enums.Color.eBlack,
        outlineSize = 2,
    })
    nameLabel:setPosition(bgSize.width/2, bgSize.height-100)
    bgSprite:addChild(nameLabel)

    -- 介绍语
    local introLabel = ui.newLabel({
        text = self.mNodeInfo.intro,
        color = cc.c3b(0x63, 0x08, 0x08),
        size = 22,
        dimensions = cc.size(450, 0),
    })
    introLabel:setAnchorPoint(0, 0.5)
    introLabel:setPosition(20, 285)
    bgSprite:addChild(introLabel)
end

function DramaWatchLayer:showRewardAndBtn()
    self.mChaildLayer:removeAllChildren()
    -- 显示奖励
    local rewardList = Utility.analysisStrResList(self.mNodeInfo.nodeReward)
    local cardList = ui.createCardList({
        cardDataList = rewardList,
        allowClick = true,
        maxViewWidth = 450,
        space = 15,
    })
    cardList:setAnchorPoint(cc.p(0, 0))
    cardList:setPosition(20, 400)
    cardList:setScale(0.85)
    self.mChaildLayer:addChild(cardList)
    cardList:setVisible(self.mNodeInfo.rewardStatus == 0)

    -- 已领取图标
    local isLearnLabel = ui.createSpriteAndLabel({
        imgName = "c_156.png",
        labelStr = TR("已领取"),
        fontSize = 24,
    })
    isLearnLabel:setAnchorPoint(cc.p(0, 0))
    isLearnLabel:setPosition(cc.p(40, 430))
    self.mChaildLayer:addChild(isLearnLabel)
    isLearnLabel:setVisible(self.mNodeInfo.rewardStatus ~= 0)

    local btnStr = ""
    if not self.mNodeInfo.isWatch then 
        btnStr = TR("观看") 
    else 
        if self.mNodeInfo.rewardStatus == 0 then
            btnStr = TR("领取")
        else 
            btnStr = TR("再次观看") 
            -- 加一句提示
            local watchLabel = ui.newLabel({
                text = TR("再次观看没有奖励"),
                color = cc.c3b(0x46, 0x22, 0x0d),
                size = 18,
            })
            watchLabel:setAnchorPoint(1, 0.5)
            watchLabel:setPosition(603, 430)
            self.mChaildLayer:addChild(watchLabel)
        end     
    end     

    local function watchDarma(isFirst)
        self.mapIDList = string.splitBySep(self.mNodeInfo.fileName, ",")
        self.mBaseNode = ccui.Widget:create()
        self.mBaseNode:setPosition(cc.p(0, 0))
        self:addChild(self.mBaseNode)
        self.bgLayer = ui.newSprite("jq_13.jpg")
        self.bgLayer:setPosition(320, 568)
        self.mChaildLayer:addChild(self.bgLayer)
        self.curMapIndex = 1
        self:playTalk(function ()
            self.mBaseNode:removeFromParent()
            self.bgLayer:removeFromParent()
            self.bgLayer = nil
            self.mBaseNode = nil
            -- 第一次观看需要通知服务端修改观看次数
            if isFirst then
                -- 通知服务端已经播放
                self:look()
            end     
        end)
    end  

    local watchBtn = ui.newButton({
        normalImage = "c_28.png",
        text = btnStr,
        clickAction = function()
            if not self.mNodeInfo.isWatch then 
                if self.mWatchNum > 0 then 
                    -- 播放
                    watchDarma(true) 
                else 
                    ui.showFlashView(TR("今日观看次数已用完"))
                end     
            else 
                if self.mNodeInfo.rewardStatus == 0 then
                    self:DrawNodeReward()
                else 
                    -- 播放
                    watchDarma(false) 
                end     
            end       
        end
    })
    watchBtn:setPosition(590, 470)
    watchBtn:setAnchorPoint(1, 0.5)
    self.mChaildLayer:addChild(watchBtn)
end

-- 播放场景
function DramaWatchLayer:playTalk(callBack)
    if self.curMapIndex > #self.mapIDList then
        return callBack()
    else
        local layer = require("Guide.TalkView.TalkLayer").new{
            map      = tostring(self.mapIDList[self.curMapIndex]),
            closedCB = function(isSkip)
                return self:playTalk(callBack)
            end,
            canSkip = false,
        }
        self.mBaseNode:addChild(layer, Enums.ZOrderType.eWeakPop)
        self.curMapIndex = self.curMapIndex + 1
    end
end

-- 领取节点奖励
function DramaWatchLayer:DrawNodeReward()
    HttpClient:request({
        moduleName = "DramaInfo",
        methodName = "DrawReward",
        svrMethodData = {self.mNodeInfo.ID},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            -- 飘窗奖励
            ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)

            -- self.mNodeInfo.rewardStatus = 1 -- 手动刷新领取状态
            -- self:showRewardAndBtn()
            -- 领取奖励之后直接关闭当前页面
            self.mDramaInfo = response.Value.DramaInfo or {}
            if self.mCallBack then 
                self.mCallBack(self.mDramaInfo)
            end 
            LayerManager.removeLayer(self) 
        end,
    })
end

function DramaWatchLayer:look()
    HttpClient:request({
        moduleName = "DramaInfo",
        methodName = "Look",
        svrMethodData = {self.mNodeInfo.ID},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            dump(response,"response")
            self.mNodeInfo.isWatch = true -- 手动刷新观看状态
            self.mWatchNum = response.Value.DramaInfo.TotalNum or 0
            self:showRewardAndBtn()
            -- 刷新数据
            self.mDramaInfo = response.Value.DramaInfo or {}
        end,
    })
end

return DramaWatchLayer