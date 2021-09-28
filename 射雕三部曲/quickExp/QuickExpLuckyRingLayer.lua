--[[
    文件名: QuickExpLuckyRingLayer
    描述: 闯荡江湖 -- 幸运套圈
    创建人: chenzhong
    创建时间: 2017.04.08
-- ]]

local QuickExpLuckyRingLayer = class("QuickExpLuckyRingLayer",function()
    return display.newLayer()
end)

function QuickExpLuckyRingLayer:ctor(params)
    ui.registerSwallowTouch({node = self})

    -- 达成奖励的次数Id
    self.mRewardMaxNum = 30
    -- 回调
    self.mCallBack = params.callback

    -- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)
    --卡片表
    self.mCardDataTable = {}
    --奖励列表
    self.mReardTable = {}

    local cellSize = cc.size(640, 1136)
    self.mAllPosInfo = {
        [1] = {scale = 1, pos = cc.p(cellSize.width*0.20, cellSize.height*0.4)},
        [2] = {scale = 1, pos = cc.p(cellSize.width*0.5, cellSize.height*0.4)},
        [3] = {scale = 1, pos = cc.p(cellSize.width*0.8, cellSize.height*0.4)},
        [4] = {scale = 0.85, pos = cc.p(cellSize.width*0.20, cellSize.height*0.58)},
        [5] = {scale = 0.85, pos = cc.p(cellSize.width*0.5, cellSize.height*0.58)},
        [6] = {scale = 0.85, pos = cc.p(cellSize.width*0.8, cellSize.height*0.58)},
        [7] = {scale = 0.75, pos = cc.p(cellSize.width*0.20, cellSize.height*0.7)},
        [8] = {scale = 0.75, pos = cc.p(cellSize.width*0.5, cellSize.height*0.7)},
        [9] = {scale = 0.75, pos = cc.p(cellSize.width*0.8, cellSize.height*0.7)},
    }

    --初始化页面控件
    self:requestGetMaxNumRewardInfo()
    --self:initUI()
end

--初始化页面控件
function QuickExpLuckyRingLayer:initUI(rewardId)

    -- 创建背景
    self.mBgSprite = ui.newSprite("cdjh_16.jpg")
    self.mBgSprite:setPosition(cc.p(320, 568))
    self.mParentLayer:addChild(self.mBgSprite)

    -- 创建底部导航和顶部玩家信息部分
    local tempLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        topInfos = {ResourcetypeSub.eVIT, ResourcetypeSub.eGold, ResourcetypeSub.eDiamond}
    })
    self:addChild(tempLayer)

    -- 帮助按钮
    local helpBtn = ui.newButton({
        normalImage = "c_72.png",
        clickAction = function (pSender)
            MsgBoxLayer.addRuleHintLayer(
                TR("抽奖规则"),
                {
                    [1] = TR("1.每完成30次闯荡江湖后即可获得一次套圈的机会"),
                    [2] = TR("2.套圈次数不能累加，触发套圈后必须完成套圈否则不能进行闯荡江湖操作"),
                }
            )
        end
    })
    helpBtn:setPosition(60, 1040)
    self.mParentLayer:addChild(helpBtn)

    self.effectQian = ui.newEffect({
        parent = self.mParentLayer,
        effectName = "effect_ui_taohuan",
        scale = 1,
        loop = true,
        speed = 0.5,
        startListener = function()
        end,
        endListener = function()
        end,
        completeListener = function()
        end,
    })

    self.effectHou = ui.newEffect({
        parent = self.mParentLayer,
        effectName = "effect_ui_taohuan",
        scale = 1,
        loop = true,
        speed = 0.5,
        --animation = "hou",
        startListener = function()
        end,
        endListener = function()
        end,
        completeListener = function()
        end,
    })

    -- 添加9个礼品
    self:addGiftBag(rewardId)

    -- 添加一只手
    local handSprite = ui.newSprite("cdjh_7.png")
    handSprite:setAnchorPoint(cc.p(1, 0))
    handSprite:setPosition(cc.p(640, -60))
    self.mParentLayer:addChild(handSprite)
    self.mHandSprite = handSprite
    local handSpriteSize = handSprite:getContentSize()

    -- 添加光环
    self.mRingSprite = ui.newSprite("cdjh_17.png")
    self.mRingSprite:setAnchorPoint(0.5, 0.5)
    self.mRingSprite:setPosition(10, handSpriteSize.height - 20)
    self.mHandSprite:addChild(self.mRingSprite)
    self.mRingSprite:setVisible(false)

    -- 添加一个移动的手环
    self.moveRingSprite = ui.newSprite("cdjh_17.png")
    self.moveRingSprite:setAnchorPoint(0.5, 0.5)
    self.moveRingSprite:setPosition(520, 286)
    self.mParentLayer:addChild(self.moveRingSprite)
    self.moveRingSprite:setVisible(false)


    self:handRunAction()

    local startbtn = ui.newButton({
        normalImage = "cdjh_18.png",
        position = cc.p(320, 200),
        clickAction = function(pSender)
            self:getReward(pSender)
        end
    })
    self.mParentLayer:addChild(startbtn)




    -- 关闭按钮
    self.mCloseBtn = ui.newButton({
        normalImage = "c_29.png",
        clickAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self.mCloseBtn:setPosition(Enums.StardardRootPos.eCloseBtn)
    self.mParentLayer:addChild(self.mCloseBtn)
end

-- 动作
function QuickExpLuckyRingLayer:handRunAction()
    -- 让手上的光环可见
    self.mRingSprite:setVisible(true)
    -- 获取一个随机数
    local randomNum = math.random(1,9)
    -- 获取取得的这个礼包
    local gitSprite = self.mReardTable[randomNum]
    local gitX ,gitY = gitSprite:getPosition()
    -- tan值
    local tanNum = gitY/(640 - gitX)
    -- 根据获得的哪个礼包，得到最后光环出手的角度
    local angle = math.deg(math.atan(tanNum))

    -- 执行动作
    local actionArray = {}
    table.insert(actionArray, cc.EaseSineIn:create(cc.RotateTo:create(1, -15)))
    table.insert(actionArray, cc.EaseSineOut:create(cc.RotateTo:create(1, 10)))
    table.insert(actionArray, cc.EaseSineIn:create(cc.RotateTo:create(1, -10)))
    table.insert(actionArray, cc.EaseSineOut:create(cc.RotateTo:create(1, 10)))

    self.mHandSprite:runAction(cc.RepeatForever:create(cc.Sequence:create(actionArray)))
end


function QuickExpLuckyRingLayer:rollMove(obj)
    local gitX ,gitY = obj:getPosition()
    local delayTime = 0
    if gitY <= 455 then
        delayTime = 0.4
    else
        delayTime = 0.7
    end

    self.effectQian:setPosition(cc.p(gitX ,gitY - 70))
    self.effectQian:setAnimation(0, "qian", false)

    self.effectHou:setPosition(cc.p(gitX ,gitY - 70))
    self.effectHou:setAnimation(0, "hou", false)

        -- 让手消失
    self.mHandSprite:setVisible(false)
    --self.moveRingSprite:setVisible(true)
    -- 让光环移动到礼包位置
    self.moveRingSprite:runAction(cc.Sequence:create({
        --cc.MoveTo:create(delayTime, cc.p(gitX ,gitY)),
        -- cc.CallFunc:create(function ()
        --     self.moveRingSprite:setVisible(false)
        -- end),
        cc.DelayTime:create(1.0),
        cc.CallFunc:create(function ()
            -- 领取奖励之后关闭页面
            LayerManager.removeLayer(self)
        end)
    }))
    -- 动作完成后设置开始按钮
    -- btnObj:setEnabled(true)
end

-- 添加9个礼品
function QuickExpLuckyRingLayer:addGiftBag(rewardId)
    --获取当前玩家等级
    local playerLv = PlayerAttrObj:getPlayerInfo().Lv
    local rewardNum = 9 --奖励数量
    local startTag = 0
    --根据玩家等级统计可以奖励的信息
    local lvTable1 = {}
    local lvTable2 = {}
    local lvTable3 = {}
    local lvTable4 = {}
    for i=1,QuickexpRewardMaxnumRelation.items_count do
        local needLv = QuickexpRewardMaxnumRelation.items[i].needLv
        if needLv == 1 then
            table.insert(lvTable1, QuickexpRewardMaxnumRelation.items[i])
        elseif needLv == 25 then
            table.insert(lvTable2, QuickexpRewardMaxnumRelation.items[i])
        elseif needLv == 40 then
            table.insert(lvTable3, QuickexpRewardMaxnumRelation.items[i])
        elseif needLv == 50 then
            table.insert(lvTable4, QuickexpRewardMaxnumRelation.items[i])
        end
    end

    local useTable = {}
    if playerLv < 25 then
        useTable = lvTable1
    end

    if (25 < playerLv and playerLv < 40) or playerLv == 25 then
        useTable = lvTable2
    end

    if (40 < playerLv and playerLv < 50) or playerLv == 40 then
        useTable = lvTable3
    end

    if playerLv >= 50 then
        useTable = lvTable4
    end

    --绘制奖励
    function RandomIndex(tabNum,indexNum)
        indexNum = indexNum or tabNum
        local t = {}
        local rt = {}
        for i = 1,indexNum do
            local ri = math.random(1,tabNum + 1 - i)
            local v = ri
            for j = 1,tabNum do
                if not t[j] then
                    ri = ri - 1
                    if ri == 0 then
                        table.insert(rt,j)
                        t[j] = true
                    end
                end
            end
        end
        return rt
    end


    local dataIdTable = RandomIndex(9, 9)
    local sertTable = {}
    local tagTable = {}

    local tempCount = table.nums(useTable)
    local tempIndex1 = RandomIndex(tempCount, tempCount)
    for index, item in pairs(tempIndex1) do
        sertTable[index] = clone(useTable[item])
    end

    local tempList = {}
    for index, item in pairs(sertTable) do
        if table.nums(tempList) >= 9 then
            break
        end

        if not tempList[item.listID] then
            table.insert(tagTable, item)
            tempList[item.listID] = true
        end
    end

    for index, item in pairs(tagTable) do
        if item.listID == QuickexpRewardMaxnumRelation.items[rewardId].listID then
            tagTable[index] = clone(QuickexpRewardMaxnumRelation.items[rewardId])
            break
        end
    end


    local rewardIndex = 1
    local roundData = RandomIndex(9, 9)
    for i = 1, 9 do
        local tempList = Utility.analysisStrResList(tagTable[i].outputResource)
        -- 创建图标
        local card = CardNode.createCardNode(tempList[1])
        card:setTag(tagTable[i].ID)
        self.mReardTable[rewardIndex] = card
        card.mShowAttrControl[CardShowAttr.eName].label:setVisible(false)
        rewardIndex = rewardIndex + 1
    end

    for i=1, #self.mReardTable do
        local underSprite = ui.newSprite("cdjh_65.png")
        underSprite:setScale(self.mAllPosInfo[i].scale)
        local posY = 70
        if self.mAllPosInfo[i].scale == 0.75 then
            posY = 50
        elseif self.mAllPosInfo[i].scale == 0.85 then
            posY = 60
        end
        underSprite:setPosition(self.mAllPosInfo[i].pos.x, self.mAllPosInfo[i].pos.y - posY)
        self.mParentLayer:addChild(underSprite)

        self.mReardTable[i]:setPosition(self.mAllPosInfo[i].pos)
        self.mReardTable[i]:setScale(self.mAllPosInfo[i].scale)
        self.mParentLayer:addChild(self.mReardTable[i])
    end
end

--领取奖励
function QuickExpLuckyRingLayer:getReward(pSender)
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "QuickExp",
        methodName = "DrawSearchReward",
        svrMethodData = {self.mRewardMaxNum},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end

            local rewardId = response.Value.Id

            local oreObg = nil
            for i=1, #self.mReardTable do
                if self.mReardTable[i]:getTag() == rewardId then
                    oreObg = self.mReardTable[i]
                    self.mHandSprite:stopAllActions()
                    pSender:setEnabled(false)
                    self:rollMove(oreObg)
                    -- 飘窗显示奖励
                    ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)
                    if self.mCallBack then
                        self.mCallBack(response.Value.QuickExpInfo)
                    end
                    break
                end
            end
        end,
    })
end

function QuickExpLuckyRingLayer:requestGetMaxNumRewardInfo()
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "QuickExp",
        methodName = "GetMaxNumRewardInfo",
        svrMethodData = {},
        callbackNode = self,
        autoModifyCache = false,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            self:initUI(response.Value.MaxNumRewardId)
        end
    })
end

return QuickExpLuckyRingLayer
