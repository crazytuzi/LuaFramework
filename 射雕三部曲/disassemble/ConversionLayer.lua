--[[
    文件名：ConversionLayer.lua
    描述：转化大侠之魂
    修改人：yanghongsheng
    创建时间： 2018.3.15
--]]

local ConversionLayer = class("ConversionLayer", function(params)
    return display.newLayer()
end)

function ConversionLayer:ctor(params)
    -- 当前选中物品的类型
    self.mResourcetype = params and params.resourcetype
    -- 当前选中的物品数据列表
    self.mSelectList = params and params.selectList or {}

    -- 卡槽的最大数
    self.mSlotMaxCount = 6
    -- 卡槽对应的cardNode的列表
    self.mCardNodeList = {}
    -- 选中角色id列表
    self.mHeroIdList = {}


    -- 每个卡槽的位置
    self.mCardPos = {}

    -- 初始化分解页面
    self:initUI()

    self:refreshSlot()
end

function ConversionLayer:getRestoreData()
    local retData = {}
    retData.selectList = self.mSelectList
    retData.resourcetype = self.mResourcetype

    return retData
end


function ConversionLayer:initUI()
    -- 炉子
    self.BgSprite = ui.newSprite("zl_02.jpg")
    self.BgSprite:setPosition(320, 568)
    self:addChild(self.BgSprite)

    -- 分解待机（特效）
    local refineEffect = ui.newEffect({
            parent = self,
            effectName = "effect_ui_renwufenjie",
            animation = "daiji",
            position = cc.p(315, 525),
            loop = true,
        })

    -- 炉子声音
    self.mAudio = MqAudio.playEffect("luhuo.mp3", true)
    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then
            MqAudio.stopEffect(self.mAudio)
        end
    end)

    -- 转化
    local tempBtn = ui.newButton({
        text = TR("转化"),
        normalImage = "c_28.png",
        position = cc.p(320, 180),
        clickAction = function()
            if not next(self.mSelectList) then
                ui.showFlashView(TR("请选择转化的侠客"))
                return
            end

            self:requestConversion()
        end,
    })
    self:addChild(tempBtn)
    self.mConversionBtn = tempBtn

    -- 创建卡槽
    self:createSlotCard()
end

-- 创建卡槽对应的卡牌
function ConversionLayer:createSlotCard()
    local squareSpace = 150 -- 方形排列时每行之间的距离
    local cardCount = self.mSlotMaxCount
    local startPosY = math.ceil(cardCount / 2) * squareSpace / 2 + 670
    for index = 1, cardCount do
        local tempPosX = (math.mod(index, 2) == 1) and 80 or 560
        local tempIndex = math.ceil(index / 2)
        local tempPosY = startPosY - (tempIndex - 1) * squareSpace - squareSpace / 2

        local tempCard
        tempCard = CardNode:create({
            -- cardShape = Enums.CardShape.eCircle,
            allowClick = true,
            onClickCallback = function()
                local tempData = self.mSelectList[index]
                if tempData and Utility.isEntityId(tempData.Id) then
                    self.mSelectList[index] = nil
                    --table.remove(self.mSelectList, index)
                    tempCard:setEmpty({}, "c_10.png", "c_22.png")
                    self:refreshSlot()
                    return
                end
                local tempData = {
                    selectType = Enums.SelectType.eHeroConversion,
                    oldResourcetype = self.mResourcetype,
                    oldSelList = self.mSelectList or {},
                    callback = function(selectLayer, selectItemList, resourcetype)
                        local tempStr = "disassemble.DisassembleLayer"
                        local tempData = LayerManager.getRestoreData(tempStr)
                        tempData.conversion = tempData.conversion or {}
                        tempData.conversion.resourcetype = resourcetype
                        tempData.conversion.selectList = selectItemList
                        tempData.currTag = Enums.DisassemblePageType.eConversion
                        LayerManager.setRestoreData(tempStr, tempData)

                        -- 删除装备选择页面
                        LayerManager.removeLayer(selectLayer)
                    end
                }
                LayerManager.addLayer({
                    name = "commonLayer.SelectLayer",
                    data = tempData,
                })
            end
        })

        tempCard:setPosition(tempPosX, tempPosY)
        table.insert(self.mCardPos, cc.p(tempPosX, tempPosY))
        self:addChild(tempCard)
        --
        table.insert(self.mCardNodeList, tempCard)
    end
end

-- 刷新卡槽
function ConversionLayer:refreshSlot()
    if self.mPerviewBg then
        self.mPerviewBg:removeFromParent()
        self.mPerviewBg = nil
    end

    for index, cardNode in pairs(self.mCardNodeList) do
        local tempData = self.mSelectList[index]
        if tempData and Utility.isEntityId(tempData.Id) then
            -- dump(tempData,"测试装备数据")
            cardNode:setHero(tempData, {CardShowAttr.eBorder, CardShowAttr.eName, CardShowAttr.eMedicine})

        else
            cardNode:setEmpty({}, "c_10.png", "c_22.png")
            local tempSize = cardNode:getContentSize()
            local tempSprite = ui.createGlitterSprite({
                filename = "c_22.png",
                parent = cardNode,
                position = cc.p(tempSize.width / 2, tempSize.height / 2),
                actionScale = 1.2,
            })
        end
    end
    self:perview()
end

-- 转化预览
function ConversionLayer:perview()
    self.mPerviewBg = ui.newScale9Sprite("c_69.png",cc.size(620, 210))
    self.mPerviewBg:setPosition(320, 370)
    self:addChild(self.mPerviewBg)
    local perviewLabel = ui.newLabel({
        text = TR("转化预览"),
        size = 28,
        color = cc.c3b(0x46, 0x22, 0x0d),
    })
    perviewLabel:setPosition(310, 165)
    self.mPerviewBg:addChild(perviewLabel)

    if self.mSelectList and next(self.mSelectList) then
        local count = 0 -- 计算红将数量
        self.mHeroIdList = {}
        for _, heroInfo in pairs(self.mSelectList) do
            count = count + 1
            table.insert(self.mHeroIdList, heroInfo.Id)
        end
        -- 显示大侠之魂
        local card = CardNode.createCardNode({
                resourceTypeSub = 1605,
                modelId = 16050304,
                num = count,
                cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eName, CardShowAttr.eNum},
            })
        card:setScale(0.9)
        card:setPosition(self.mPerviewBg:getContentSize().width*0.5, self.mPerviewBg:getContentSize().height*0.45+2)
        self.mPerviewBg:addChild(card)
    else
        local label = ui.newLabel({
            text = TR("传说侠客可转化为大侠之魂，大侠之魂可用于幻化侠客突破"),
            size = 22,
            color = cc.c3b(0x46, 0x22, 0x0d),
            x = 60,
            y = 100,
            anchorPoint = cc.p(0,0.5),
            dimensions = cc.size(520, 0),
        })
        self.mPerviewBg:addChild(label)
    end
end

-- 播发特效
function ConversionLayer:playEffect(callback)
    -- 播放音效
    MqAudio.playEffect("renwu_shengji.mp3")

    -- 播放格子特效
    for index, item in pairs(self.mSelectList)  do
        if item and Utility.isEntityId(item.Id) then
            self.mSelectList[index] = nil
            ui.newEffect({
                parent = self,
                effectName = "effect_ui_fenjie",
                position = self.mCardPos[index],
                loop = false,
                endRelease = true,
            })
        end
    end

    -- 播放炉子特效
    ui.newEffect({
        parent = self,
        effectName = "effect_ui_renwufenjie",
        animation = "fenji",
        position = cc.p(320, 568),
        loop = false,
        endRelease = true,
        endListener = function()
            if callback then callback() end
        end
    })
end

--=====================网络相关=================
-- 请求转化大侠之魂
function ConversionLayer:requestConversion()
    if not next(self.mHeroIdList) then
        ui.showFlashView(TR("请选择转化的侠客"))
        return
    end

    HttpClient:request({
        moduleName = "Hero",
        methodName = "HeroConversion",
        svrMethodData = {self.mHeroIdList},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            -- 删除缓存
            HeroObj:deleteHeroItems(self.mSelectList)

            -- 置灰按钮
            self.mConversionBtn:setEnabled(false)

            self:playEffect(function ()
                -- 显示奖励
                MsgBoxLayer.addGameDropLayer(response.Value.BaseGetGameResourceList, nil, nil, TR("转化"))
                -- 刷新界面
                self.mHeroIdList = {}
                self.mSelectList = {}
                self:refreshSlot()
                -- 恢复按钮
                self.mConversionBtn:setEnabled(true)
            end)
            
        end
    })
end

return ConversionLayer
