--[[
文件名：MsgBoxLayer.lua
描述：提示信息弹窗, 创建该提示窗体优先使用 MsgBoxLayer.addXXX 相关的辅助函数，
    如果这些函数不满足要求，可以直接使用 LayerManager.addLayer(...)
创建人：peiyaoqiang
创建时间：2017.06.10
--]]

-- 构造函数参数说明
--[[
-- 构造函数参数表中的各项为:
    {
        bgImage:        可选参数，背景图片文件名, 默认为 "c_48.png"
        bgSize:         可选参数，提示信息窗体的大小, 默认为背景图片的原始大小
        title:          可选参数，标题，可以是图片文件名，也可以是普通文字，默认为普通文字：“提示”
        msgText:        可选参数，提示内容文字，默认为 “”
        needTouchClose: 可选参数，是否需要触摸窗体以外的区域关闭窗体，默认为false
        closeBtnInfo:   可选参数，关闭按钮的信息，其中每项为 ui.newButton(...) 函数的参数注释，默认不显示关闭按钮，如果要显示默认的关闭按钮，该参数可以为: {}
        btnInfos:       可选参数，底部按钮的信息列表，其中每项为 ui.newButton(...) 函数的参数注释， 默认只有确定按钮
        DIYUiCallback:  可选参数，调用者DIY页面的回调，回调参数为 (self, mBgSprite, mBgSize), 默认为 nil
        notNeedBlack:   可选参数，判断是否需要黑色背景框（默认创建黑色背景框）
        isNoShowTitle:  可选参数，判断是否不显示标题title(默认显示)
        closeAction:    可选参数，needTouchClose为true且没有关闭按钮时有效
    }
]]
MsgBoxLayer = class("MsgBoxLayer", function(params)
    return display.newLayer(cc.c4b(0, 0, 0, 128))
end)

--弹出提示对话框
--[[
-- 参数 params 中的每项参考文件头处的“构造函数参数说明”
--]]
function MsgBoxLayer:ctor(params)
    local defaultImage, btnPosY = "mrjl_02.png", 65
    if params.closeBtnInfo then
        defaultImage, btnPosY = "c_30.png", 55
    end
    local mBgImage, mBgSize = defaultImage, cc.size(572, 337)
    if params.bgImage then
        mBgImage, mBgSize = params.bgImage, ui.getImageSize(params.bgImage)
    end
    if params.bgSize then
        mBgSize = params.bgSize
    end

    -- 创建背景图片
    local mBgSprite = ui.newScale9Sprite(mBgImage, mBgSize)
    mBgSprite:setScale(Adapter.MinScale)
    mBgSprite:setPosition(display.cx, display.cy)
    self:addChild(mBgSprite)
    -- 判断是否需要黑色背景框（默认创建黑色背景框）
    if not params.notNeedBlack then
        -- 黑色背景框
        local blackSize = cc.size(mBgSize.width*0.9, (mBgSize.height-170))
        local blackBg = ui.newScale9Sprite("c_17.png", blackSize)
        blackBg:setAnchorPoint(0.5, 0)
        blackBg:setPosition(mBgSize.width/2, 100)
        mBgSprite:addChild(blackBg)
    end

    -- 创建弹窗的标题
    local titlePos = cc.p(mBgSize.width / 2, mBgSize.height - 36)
    -- 标题的锚点
    local  titleAnchorPoint = cc.p(0.5, 0.5)
    if string.isImageFile(params.title) then  -- 是图片
        local mTitleNode = ui.newSprite(params.title)
        mTitleNode:setAnchorPoint(titleAnchorPoint)
        mTitleNode:setPosition(titlePos)
        mBgSprite:addChild(mTitleNode)
        mTitleNode:setVisible(not params.isNoShowTitle)
    else
        local mTitleNode = ui.newLabel({
            text = params.title or TR("提示"),
            size = Enums.Fontsize.eTitleDefault,
            color = cc.c3b(0xff, 0xee, 0xd0),
            outlineColor = cc.c3b(0x3a, 0x24, 0x18),
        })
        mTitleNode:setAnchorPoint(titleAnchorPoint)
        mTitleNode:setPosition(titlePos)
        mBgSprite:addChild(mTitleNode)
        mTitleNode:setVisible(not params.isNoShowTitle)
    end

    -- 默认关闭窗体的函数
    local function defCloseFun(layerObj, btnObj)
        LayerManager.removeLayer(layerObj)
    end

    -- 创建关闭按钮
    if params.closeBtnInfo then
        local btnInfo = clone(params.closeBtnInfo)
        local btnClickAction = btnInfo.clickAction or defCloseFun
        btnInfo.fixedSize = btnInfo.fixedSize ~= false
        btnInfo.normalImage = btnInfo.normalImage or "c_29.png"
        btnInfo.position = btnInfo.position or cc.p(mBgSize.width - 38, mBgSize.height - 35)
        btnInfo.clickAction = function(btnObj)
            btnClickAction(self, btnObj)
        end

        self.mCloseBtn = ui.newButton(btnInfo)
        mBgSprite:addChild(self.mCloseBtn)
    end

    -- 底部按钮列表
    self.mBottomBtns = {}
    -- 创建底部的按钮
    local btnInfos = params.btnInfos and clone(params.btnInfos) or {{text = TR("确定"),}}
    for index, btnInfo in ipairs(btnInfos) do
        local tempPosX = (mBgSize.width / 2 - (#btnInfos - 1) * 110) + (index - 1) * 220
        local btnClickAction = btnInfo.clickAction or defCloseFun
        btnInfo.normalImage = btnInfo.normalImage or "c_28.png"
        btnInfo.position = btnInfo.position or cc.p(tempPosX, btnPosY)
        btnInfo.clickAction = function(btnObj)
            btnClickAction(self, btnObj)
        end

        local tempBtn = ui.newButton(btnInfo)
        mBgSprite:addChild(tempBtn)
        -- 保存底部按钮到列表中,方便外部调用各个按钮
        table.insert(self.mBottomBtns, tempBtn)
    end

    -- 创建提示内容
    local mMsgLabel = ui.newLabel({
        text = params.msgText or "",
        color = Enums.Color.eNormalWhite,
        outlineColor = cc.c3b(0x46, 0x22, 0x0d),
        align = ui.TEXT_ALIGN_CENTER,
        dimensions = cc.size(mBgSize.width*0.85 - 10, 0)
    })
    mMsgLabel:setAnchorPoint(cc.p(0.5, 0.5))
    mMsgLabel:setPosition(mBgSize.width / 2, mBgSize.height*0.5+15)
    mBgSprite:addChild(mMsgLabel, 1)
    self.mMsgLabel = mMsgLabel

    -- 让用户DIY自己的部分
    if params.DIYUiCallback then
        params.DIYUiCallback(self, mBgSprite, mBgSize)
    end

    -- 判断是否需要触摸窗体以外的区域关闭窗体
    if params.needTouchClose then
        ui.registerSwallowTouch({
            node = self,
            allowTouch = true,
            beganEvent = function(touch, event)
                return self:isVisible()
            end,
            endedEvent = function (touch, event)
                -- 点击弹窗以外区域关闭窗体必须模拟关闭按钮或确定按钮的点击事件，否则会造成部分模块的逻辑错误
                if not ui.touchInNode(touch, mBgSprite) then
                    -- 优先查找关闭按钮的点击事件
                    if params.closeBtnInfo then -- 说明有关闭按钮
                        local closeBtnCb = params.closeBtnInfo.clickAction or defCloseFun
                        closeBtnCb(self, self.mCloseBtn)
                    elseif #self.mBottomBtns > 0 then -- 没有关闭按钮时，默认点击底部左边第一个按钮
                        local tempBtn = self.mBottomBtns[1]
                        local tempBtnCb = defCloseFun
                        if params.btnInfos and params.btnInfos[1] and params.btnInfos[1].clickAction then
                            tempBtnCb = params.btnInfos[1].clickAction
                        end
                        tempBtnCb(self, tempBtn)
                    elseif params.closeAction then
                        params.closeAction(self)
                    else
                        -- 其他情况不能随便自动关闭窗体
                    end
                end
            end,
        })
    else
        ui.registerSwallowTouch({node = self})
    end

    -- 添加动作助手
    ui.showPopAction(mBgSprite)
end

-- 获取提示信息控件
function MsgBoxLayer:getMsgLabel()
    return self.mMsgLabel
end

-- 返回底部按钮列表
function MsgBoxLayer:getBottomBtns()
    return self.mBottomBtns
end

----------------------------------------------------------------------------------------------------
-- 以下是封装好的一些针对特定场景使用的专门对话框

--- 创建 DIY 提示窗体
--[[
-- 参数 params 中的每项参考文件头处的“构造函数参数说明”
]]
function MsgBoxLayer.addDIYLayer(params)
    return LayerManager.addLayer({
        name = "commonLayer.MsgBoxLayer",
        data = params,
        cleanUp = false,
    })
end

--- 创建确定提示窗体
--[[
-- 参数
    msgText:        可选参数，提示内容文字，默认为 “”
    title:          可选参数，标题，可以是图片文件名，也可以是普通文字，默认为普通文字：“提示”
    closeBtnInfo:   可选参数，关闭按钮的信息，其中每项为 ui.newButton(...) 函数的参数注释，默认不显示关闭按钮，如果要显示默认的关闭按钮，该参数可以为: {}
    btnInfos:       可选参数，底部按钮的信息列表，其中每项为 ui.newButton(...) 函数的参数注释， 默认只有确定按钮
]]
function MsgBoxLayer.addOKLayer(msgText, title, btnInfos, closeBtnInfo)
    local tempData = {
        title = title,
        msgText = msgText,
        btnInfos = next(btnInfos or {}) and btnInfos or {{text = TR("确定"),}, },
        closeBtnInfo = closeBtnInfo,
    }
     -- 避免出现在升级界面之上的情况, 所以设置zOder
    return LayerManager.addLayer({name = "commonLayer.MsgBoxLayer", data = tempData, 
        cleanUp = false, zOrder = Enums.ZOrderType.eMessageBox})
end

--- 创建确定取消提示窗体
--[[
-- 参数
    msgText: 提示内容文字
    title: 提示窗体的标题，默认为：TR("提示")
    needCloseBtn: 是否需要关闭按钮，默认为需要
    okBtnInfo: 确定按钮信息，其中每项为 ui.newButton(...) 函数的参数注释
    cancelBtnInfo: 取消按钮信息，其中每项为 ui.newButton(...) 函数的参数注释
    closeBtnInfo: 关闭按钮信息，其中每项为 ui.newButton(...) 函数的参数注释
]]
function MsgBoxLayer.addOKCancelLayer(msgText, title, okBtnInfo, cancelBtnInfo, closeBtnInfo, needCloseBtn)
    local tempData = {
        title = title,
        msgText = msgText,
        btnInfos = {
            okBtnInfo or {text = TR("确定"),},
            cancelBtnInfo or {text = TR("取消"),}
        },
        closeBtnInfo = needCloseBtn ~= false and (closeBtnInfo or {}),
    }
    return LayerManager.addLayer({name = "commonLayer.MsgBoxLayer", data = tempData, cleanUp = false})
end

--- 物品掉落提示窗体
--[[
-- 参数
    baseDrop:       必传参数，基础掉落物品列表，在网络请求返回的 Value.BaseGetGameResourceList
    extraDrop:      可选参数，额外掉落物品列表，在网络请求返回的 Value.ExtraGetGameResource
    msgText:        可选参数，提示内容文字，默认为：“获得以下物品”
    title:          可选参数，标题，默认为：“奖励”
    closeBtnInfo:   可选参数，关闭按钮的信息，其中每项为 ui.newButton(...) 函数的参数注释，默认不显示关闭按钮，如果要显示默认的关闭按钮，该参数可以为: {}
    btnInfos:       可选参数，底部按钮的信息列表，其中每项为 ui.newButton(...) 函数的参数注释， 默认只有确定按钮
]]
function MsgBoxLayer.addGameDropLayer(baseDrop, extraDrop, msgText, title, btnInfos, closeBtnInfo)
    -- 物品掉落提示窗体的DIY函数
    local function DIYFuncion(layerObj, bgSprite, bgSize)
        -- 重新设置提示信息的位置
        local tempLabel = layerObj:getMsgLabel()
        tempLabel:setAnchorPoint(cc.p(0.5, 1))
        tempLabel:setPosition(bgSize.width / 2, bgSize.height - 90)

        -- 需要展示的物品列表
        local resourceList = Utility.analysisGameDrop(baseDrop, extraDrop)
        -- 创建奖励物品列表
        local cardListNode = ui.createCardList({
            maxViewWidth = bgSize.width - 60,
            space = 15,
            cardDataList = resourceList,
            allowClick = true,
            needArrows = true,
        })
        cardListNode:setAnchorPoint(cc.p(0.5, 0))
        cardListNode:setPosition(bgSize.width / 2 , 120)
        bgSprite:addChild(cardListNode)
    end

    local tempData = {
        bgSize = cc.size(572, 400),
        title = title ~= "" and title or TR("奖励"),
        msgText = msgText ~= "" and msgText or TR("获得以下物品"),
        btnInfos = next(btnInfos or {}) and btnInfos or {{text = TR("确定"),}, },
        closeBtnInfo = closeBtnInfo,
        DIYUiCallback = DIYFuncion,
    }
    return LayerManager.addLayer({
        name = "commonLayer.MsgBoxLayer",
        data = tempData,
        cleanUp = false,
        needRestore = true
    })
end

-- 物品掉落预览窗体
--[[
-- 参数
    msgText:        可选参数，提示内容文字，默认为：“可获得以下物品”
    title:          可选参数，标题，默认为：“奖励预览”
    closeBtnInfo:   可选参数，关闭按钮的信息，其中每项为 ui.newButton(...) 函数的参数注释，默认不显示关闭按钮，如果要显示默认的关闭按钮，该参数可以为: {}
    btnInfos:       可选参数，底部按钮的信息列表，其中每项为 ui.newButton(...) 函数的参数注释， 默认只有确定按钮
    previewList:    必传参数，预览的物品列表，其中每项为：
    {
        {
            resourceTypeSub = 1111, -- 资源子类型，相关枚举在 EnumsConfig.lua文件的 ResourcetypeSub 中定义。
            modelId = 0, -- 模型Id，如果是玩家属性资源，模型Id为0
            num = 20,  -- 数量
        }
        ...
    }
]]
function MsgBoxLayer.addPreviewDropLayer(previewList, msgText, title, btnInfos, closeBtnInfo)
    -- 创建掉落预览提示的DIY函数
    local function DIYFuncion(layerObj, bgSprite, bgSize)
        -- 重新设置提示信息的位置
        local tempLabel = layerObj:getMsgLabel()
        tempLabel:setAnchorPoint(cc.p(0.5, 1))
        tempLabel:setPosition(bgSize.width / 2, bgSize.height * 0.8)
        -- 创建物品栏背景
        local resourceBgSprite = ui.newScale9Sprite("c_17.png", cc.size(460,144))
        resourceBgSprite:setPosition(bgSize.width / 2, bgSize.height * 0.45 + 10)
        bgSprite:addChild(resourceBgSprite)
        local resBgSize = resourceBgSprite:getContentSize()
        -- 创建奖励物品列表
        local cardListNode = ui.createCardList({
            maxViewWidth = bgSize.width - 70,
            space = 15,
            cardDataList = previewList,
            allowClick = true,
            needArrows = true,
        })
        cardListNode:setAnchorPoint(cc.p(0.5, 0.5))
        cardListNode:setPosition(resourceBgSprite:getContentSize().width * 0.5 , resourceBgSprite:getContentSize().height * 0.5)
        resourceBgSprite:addChild(cardListNode)
    end

    local tempData = {
        bgSize = cc.size(514, 360),
        title = title ~= "" and title or TR("奖励预览"),
        msgText = msgText ~= "" and msgText or TR("可获得以下物品"),
        btnInfos = next(btnInfos or {}) and btnInfos or {{text = TR("确定"),}, },
        closeBtnInfo = closeBtnInfo,
        DIYUiCallback = DIYFuncion,
        notNeedBlack = true,
    }

    return LayerManager.addLayer({
        name = "commonLayer.MsgBoxLayer",
        data = tempData,
        cleanUp = false,
        needRestore = true
    })
end

-- 一键分解选择提示框
--[[
-- 参数
    refineInfoList：必传参数，分解选择信息，其中每项为：
    {
        {
            hintStr: 提示信息
            btnInfo: 按钮信息，相信信息为ui.newButton(...) 函数的参数注释
        },
        ...
    }
    title: 可选参数，提示窗体的标题，默认为：TR("提示")
    closeBtnInfo: 可选参数，关闭按钮的信息，其中每项为 ui.newButton(...) 函数的参数注释，默认不显示关闭按钮，如果要显示默认的关闭按钮，该参数可以为: {}
]]
function MsgBoxLayer.addOneKeyRefineChoiceLayer(refineInfoList, title, closeBtnInfo)
    if not refineInfoList then
        return
    end

    local cellSize = cc.size(572, 100)
    local function DIYFuncion(layer, layerBgSprite, layerSize)
        local startPosY = layerSize.height - 80
        for index, item in pairs(refineInfoList) do
            local tempSprite = ui.newScale9Sprite("c_83.png", cc.size(cellSize.width - 40, cellSize.height))
            tempSprite:setAnchorPoint(cc.p(0.5, 1))
            tempSprite:setPosition(layerSize.width / 2, startPosY - (index - 1) * (cellSize.height + 20))
            layerBgSprite:addChild(tempSprite)

            -- 提示信息
            local tempLabel = ui.newLabel({
                text = item.hintStr or "",
                dimensions = cc.size(cellSize.width - 150, 0),
                color = Enums.Color.eNormalWhite,
                outlineColor = cc.c3b(0x46, 0x22, 0x0d),
                outlineSize = 2,   
            })
            tempLabel:setAnchorPoint(display.LEFT_CENTER)
            tempLabel:setPosition(20, cellSize.height / 2)
            tempSprite:addChild(tempLabel)

            -- 按钮
            if item.btnInfo then
                local tempBtnInfo = item.btnInfo
                local btnClickAction = tempBtnInfo.clickAction or function(layerObj, btnObj)
                    LayerManager.removeLayer(layerObj)
                end
                tempBtnInfo.normalImage = tempBtnInfo.normalImage or "c_28.png"
                tempBtnInfo.position = tempBtnInfo.position or cc.p(cellSize.width - 150, cellSize.height / 2)
                tempBtnInfo.clickAction = function(layerObj, btnObj)
                    btnClickAction(layerObj, btnObj)
                end

                local tempBtn = ui.newButton(tempBtnInfo)
                tempSprite:addChild(tempBtn)
            end
        end
    end

    return MsgBoxLayer.addDIYLayer({
        title = title,
        closeBtnInfo = closeBtnInfo,
        DIYUiCallback = DIYFuncion,
        bgSize = cc.size(cellSize.width, #refineInfoList * (cellSize.height + 30) + 160)
    })
end

-- 神兵碎片信息提示框
--[[
-- 参数
    title: 提示窗体的标题，默认为：TR("碎片详情")
    treasureDebrisModelId: 道具的模型Id
]]
function MsgBoxLayer.addTreasureDebrisInfoLayer(treasureDebrisModelId, title)
    local tempModel = TreasureDebrisModel.items[treasureDebrisModelId]
    -- 碎片信息DIY函数
    local function DIYDebrisInfoLayer(layer, layerBgSprite, layerSize)
        -- 创建物品的头像
        local tempCard = CardNode.createCardNode({
            resourceTypeSub = tempModel.typeID, -- 资源类型
            modelId = treasureDebrisModelId,  -- 模型Id
            num = nil, -- 资源数量
            allowClick = false, --
        })
        tempCard:setPosition(layerSize.width / 2, layerSize.height - 130)
        layerBgSprite:addChild(tempCard)

        -- 创建碎片的简介
        local tempLabel = ui.newLabel({
            text = tempModel.intro == "" and TR("神秘碎片，暂无介绍") or tempModel.intro,
            color = Enums.Color.eNormalWhite,
            outlineColor = cc.c3b(0x46, 0x22, 0x0d),
            align = ui.TEXT_ALIGN_CENTER,
            valign = ui.TEXT_VALIGN_TOP,
            dimensions = cc.size(layerSize.width - 80, 0)
        })
        tempLabel:setAnchorPoint(cc.p(0.5, 1))
        tempLabel:setPosition(layerSize.width / 2, layerSize.height - 215)
        layerBgSprite:addChild(tempLabel)
    end

    local btnInfos = {
        {
            text = TR("详情"),
            clickAction = function(layerObj, btnObj)
                LayerManager.addLayer({
                    name = "equip.TreasureInfoLayer",
                    data = {
                        treasureModelID = tempModel.treasureModelID,
                    },
                    cleanUp = false
                })
                LayerManager.removeLayer(layerObj)
            end
        },
        {
            text = TR("确定")
        },
    }

    local tempData = {
        title = title or TR("碎片信息"),
        msgText = "",
        bgSize = cc.size(572, 380),
        btnInfos = btnInfos,
        closeBtnInfo = {},
        DIYUiCallback = DIYDebrisInfoLayer,
    }
    return LayerManager.addLayer({
        name = "commonLayer.MsgBoxLayer",
        data = tempData,
        cleanUp = false,
    })
end

-- 道具信息提示框
--[[
-- 参数
    title: 提示窗体的标题，默认为：TR("物品详情")
    goodsModelId: 道具的模型Id
]]
function MsgBoxLayer.addGoodsInfoLayer(goodsModelId, title)
    local tempModel = GoodsModel.items[goodsModelId]

    -- 固定箱包类道具信息DIY函数
    local function DIYBoxFixedFuncion(layer, layerBgSprite, layerSize)
        -- 创建物品的头像
        local tempCard = CardNode.createCardNode({
            resourceTypeSub = tempModel.typeID, -- 资源类型
            modelId = goodsModelId,  -- 模型Id
            num = nil, -- 资源数量
            allowClick = false,
        })
        layerBgSprite:addChild(tempCard)
        tempCard:setPosition(layerSize.width / 2, layerSize.height - 120)

        -- 可获得物品列表数据
        local outputList = GoodsOutputRelation.items[tempModel.goodsOutputOddsCode]
        local cardData = {}
        for index, item in pairs(outputList) do
            table.insert(cardData, {
                resourceTypeSub = item.outputTypeID, -- 资源类型
                modelId = item.outputModelID,  -- 模型Id
                num = item.outputNum, -- 资源数量
            })
        end

        -- 可获得物品列表的背景
        local tempSize = cc.size(layerSize.width - 50, 150)
        local tempSprite = ui.newScale9Sprite("c_51.png", tempSize)
        tempSprite:setPosition(layerSize.width / 2, layerSize.height - 260)
        layerBgSprite:addChild(tempSprite)
        tempSprite:setOpacity(0)    -- 设置背景为透明
        -- 可获得物品列表卡牌
        local cardListNode = ui.createCardList({
            maxViewWidth = tempSize.width - 20,
            space = 10,
            cardDataList = cardData,
            allowClick = true,
        })
        cardListNode:setAnchorPoint(cc.p(0.5, 0.5))
        cardListNode:setPosition(tempSize.width / 2, tempSize.height / 2)
        tempSprite:addChild(cardListNode)
        local cardNodeList = cardListNode.getCardNodeList()
        for i,v in ipairs(cardNodeList) do
            local tempItem = cardData[i]
            -- 羁绊状态
            local relationStatus
            if Utility.isTresureDebris(tempItem.resourceTypeSub) then
                local tresureDebrisOut = TreasureDebrisModel.items[tempItem.modelId]
                relationStatus = FormationObj:getRelationStatus(tresureDebrisOut.treasureModelID, tresureDebrisOut.typeID)
            elseif Utility.isHeroDebris(tempItem.resourceTypeSub) then
                local heroDebrisOut = GoodsModel.items[tempItem.modelId].outputModelID
                local heroModelItem = HeroModel.items[heroDebrisOut]
                relationStatus = FormationObj:getRelationStatus(heroModelItem.ID, ResourcetypeSub.eHero)
            else
                relationStatus = FormationObj:getRelationStatus(tempItem.modelId, tempItem.resourceTypeSub)
            end
            if relationStatus ~= Enums.RelationStatus.eNone then
                local relationStr = {
                    [Enums.RelationStatus.eIsMember] = TR("缘份"),  -- 推荐
                    [Enums.RelationStatus.eTriggerPr] = TR("可激活"),  -- 缘分
                    [Enums.RelationStatus.eSame] = TR("已上阵")   -- 已上阵
                }
                local relationPic = {
                    [Enums.RelationStatus.eIsMember] = "c_57.png",  -- 推荐
                    [Enums.RelationStatus.eTriggerPr] = "c_58.png",  -- 缘分
                    [Enums.RelationStatus.eSame] = "c_62.png"  -- 已上阵
                }
                v:createStrImgMark(relationPic[relationStatus], relationStr[relationStatus])
            end
        end
    end

    -- 概率类箱包道具信息DIY函数
    local function DIYBoxOddsFunction(layer, layerBgSprite, layerSize)
        layer.mMsgLabel:setPosition(layerSize.width / 2, layerSize.height - 100)
        layer.mMsgLabel:setString(TR("使用后可随机获得以下物品"))

        local outputList = GoodsOutputRelation.items[tempModel.goodsOutputOddsCode]
        table.sort(outputList, function(a, b)
            local tempModelA 
            local tempModelB 
            local relationa 
            local relationb
            if Utility.isTresureDebris(a.outputTypeID)then
                tempModelA = TreasureDebrisModel.items[a.outputModelID]
                relationa = FormationObj:getRelationStatus(tempModelA.treasureModelID, tempModelA.typeID)
            elseif Utility.isHeroDebris(a.outputTypeID) then
                tempModelA = HeroModel.items[GoodsModel.items[a.outputModelID].outputModelID]
                relationa = FormationObj:getRelationStatus(tempModelA.ID, ResourcetypeSub.eHero)
            else
                relationa = FormationObj:getRelationStatus(a.outputModelID, a.outputTypeID)
            end

            if Utility.isTresureDebris(b.outputTypeID)then
                tempModelB = TreasureDebrisModel.items[b.outputModelID]
                relationb = FormationObj:getRelationStatus(tempModelB.treasureModelID, tempModelB.typeID)
            elseif Utility.isHeroDebris(b.outputTypeID) then
                tempModelB = HeroModel.items[GoodsModel.items[b.outputModelID].outputModelID]
                relationb = FormationObj:getRelationStatus(tempModelB.ID, ResourcetypeSub.eHero)
            else
                relationb = FormationObj:getRelationStatus(b.outputModelID, b.outputTypeID)
            end


            -- 根据羁绊类型排序
            if relationa ~= relationb then
                return relationa > relationb
            end

            -- 根据品质排序
            local aBaseModel = ConfigFunc:getItemBaseModel(a.outputModelID) or {}
            local bBaseModel = ConfigFunc:getItemBaseModel(b.outputModelID) or {}
            local qualitya = aBaseModel.quality or 0
            local qualityb = bBaseModel.quality or 0
            if (qualitya ~= qualityb) then
                return qualitya > qualityb
            end

            -- 特殊需求，在上阵的人物中，小伙伴排后面
            if Utility.isHeroDebris(a.outputTypeID) or Utility.isHero(a.outputTypeID) then
                if Utility.isHeroDebris(a.outputTypeID) then
                    if relationa == relationb and relationa == Enums.RelationStatus.eSame then
                        local isMateA = Utility.isHeroInMate(tempModelA.ID)
                        local isMateB = Utility.isHeroInMate(tempModelB.ID)
                        if isMateA ~= isMateB then
                            return not isMateA
                        end
                    end
                else
                    if relationa == relationb and relationa == Enums.RelationStatus.eSame then
                        local isMateA = Utility.isHeroInMate(a.outputModelID)
                        local isMateB = Utility.isHeroInMate(b.outputModelID)
                        if isMateA ~= isMateB then
                            return not isMateA
                        end
                    end
                end
            end

            -- 根据模型ID排序
            return a.outputModelID < b.outputModelID
        end)

        local viewSize = cc.size(layerSize.width - 50, 240)
        local sliderTableView = ui.newSliderTableView({
            width = viewSize.width,
            height = viewSize.height,
            isVertical = false,
            selItemOnMiddle = true,
            itemCountOfSlider = function(sliderView)
                return math.ceil(#outputList / 6)
            end,
            itemSizeOfSlider = function(sliderView)
                return viewSize.width, viewSize.height
            end,
            sliderItemAtIndex = function(sliderView, itemNode, index)
                for i = 1, 6 do
                    local tempIndex = index * 6 + i
                    if tempIndex > #outputList then
                        break
                    end
                    local tempItem = outputList[tempIndex]

                    local tempCard = CardNode.createCardNode({
                        resourceTypeSub = tempItem.outputTypeID, -- 资源类型
                        modelId = tempItem.outputModelID,  -- 模型Id
                        num = tempItem.outputNum, -- 资源数量
                    })
                    tempCard:setScale(0.9)
                    tempCard:setPosition(math.mod(i - 1, 3) * 140 + 120, viewSize.height - math.floor((i - 1) / 3) * 110 - 50)
                    itemNode:addChild(tempCard)

                    -- 羁绊状态
                    local relationStatus
                    if Utility.isTresureDebris(tempItem.outputTypeID) then
                        local tresureDebrisOut = TreasureDebrisModel.items[tempItem.outputModelID]
                        relationStatus = FormationObj:getRelationStatus(tresureDebrisOut.treasureModelID, tresureDebrisOut.typeID)
                    elseif Utility.isHeroDebris(tempItem.outputTypeID) then
                        local heroDebrisOut = GoodsModel.items[tempItem.outputModelID].outputModelID
                        local heroModelItem = HeroModel.items[heroDebrisOut]
                        relationStatus = FormationObj:getRelationStatus(heroModelItem.ID, ResourcetypeSub.eHero)
                    else
                        relationStatus = FormationObj:getRelationStatus(tempItem.outputModelID, tempItem.outputTypeID)
                    end
                    if relationStatus ~= Enums.RelationStatus.eNone then
                        local relationStr = {
                            [Enums.RelationStatus.eIsMember] = TR("缘份"),  -- 推荐
                            [Enums.RelationStatus.eTriggerPr] = TR("可激活"),  -- 缘分
                            [Enums.RelationStatus.eSame] = TR("已上阵")   -- 已上阵
                        }
                        local relationPic = {
                            [Enums.RelationStatus.eIsMember] = "c_57.png",  -- 推荐
                            [Enums.RelationStatus.eTriggerPr] = "c_58.png",  -- 缘分
                            [Enums.RelationStatus.eSame] = "c_62.png"  -- 已上阵
                        }
                        tempCard:createStrImgMark(relationPic[relationStatus], relationStr[relationStatus])
                    end
                end
            end,
            selectItemChanged = function()
                -- Todo
            end
        })
        sliderTableView:setAnchorPoint(cc.p(0.5, 0))
        sliderTableView:setPosition(layerSize.width * 0.5, 90)
        layerBgSprite:addChild(sliderTableView)
    end

    -- 可选择道具信息DIY函数
    local function DIYBoxChoiceFunction(layer, layerBgSprite, layerSize)
        layer.mMsgLabel:setPosition(layerSize.width / 2, layerSize.height - 100)
        layer.mMsgLabel:setString(TR("使用后可以从下列物品中任选其一"))

        local outputList = GoodsOutputRelation.items[tempModel.goodsOutputOddsCode]
        table.sort(outputList, function(a, b)
            local tempModelA 
            local tempModelB 
            local relationa 
            local relationb
            if Utility.isTresureDebris(a.outputTypeID)then
                tempModelA = TreasureDebrisModel.items[a.outputModelID]
                tempModelB = TreasureDebrisModel.items[b.outputModelID]
                relationa = FormationObj:getRelationStatus(tempModelA.treasureModelID, tempModelA.typeID)
                relationb = FormationObj:getRelationStatus(tempModelB.treasureModelID, tempModelB.typeID)
            elseif Utility.isHeroDebris(a.outputTypeID) then
                tempModelA = HeroModel.items[GoodsModel.items[a.outputModelID].outputModelID]
                tempModelB = HeroModel.items[GoodsModel.items[b.outputModelID].outputModelID]
                relationa = FormationObj:getRelationStatus(tempModelA.ID, ResourcetypeSub.eHero)
                relationb = FormationObj:getRelationStatus(tempModelB.ID, ResourcetypeSub.eHero)
            else
                relationa = FormationObj:getRelationStatus(a.outputModelID, a.outputTypeID)
                relationb = FormationObj:getRelationStatus(b.outputModelID, b.outputTypeID)
            end

            -- 根据羁绊类型排序
            if relationa ~= relationb then
                return relationa > relationb
            end

            -- 根据品质排序
            local qualitya = ConfigFunc:getItemBaseModel(a.outputModelID).quality
            local qualityb = ConfigFunc:getItemBaseModel(b.outputModelID).quality
            if qualitya ~= qualityb then
                return qualitya > qualityb
            end

            -- 特殊需求，在上阵的人物中，小伙伴排后面
            if Utility.isHeroDebris(a.outputTypeID) or Utility.isHero(a.outputTypeID) then
                if Utility.isHeroDebris(a.outputTypeID) then
                    if relationa == relationb and relationa == Enums.RelationStatus.eSame then
                        local isMateA = Utility.isHeroInMate(tempModelA.ID)
                        local isMateB = Utility.isHeroInMate(tempModelB.ID)
                        if isMateA ~= isMateB then
                            return not isMateA
                        end
                    end
                else
                    if relationa == relationb and relationa == Enums.RelationStatus.eSame then
                        local isMateA = Utility.isHeroInMate(a.outputModelID)
                        local isMateB = Utility.isHeroInMate(b.outputModelID)
                        if isMateA ~= isMateB then
                            return not isMateA
                        end
                    end
                end
            end

            -- 根据模型ID排序
            return a.outputModelID < b.outputModelID
        end)
        if #outputList > 4 then
            local viewSize = cc.size(layerSize.width - 50, 240)
            local sliderTableView = ui.newSliderTableView({
                width = viewSize.width,
                height = viewSize.height,
                isVertical = false,
                selItemOnMiddle = true,
                itemCountOfSlider = function(sliderView)
                    return math.ceil(#outputList / 6)
                end,
                itemSizeOfSlider = function(sliderView)
                    return viewSize.width, viewSize.height
                end,
                sliderItemAtIndex = function(sliderView, itemNode, index)
                    for i = 1, 6 do
                        local tempIndex = index * 6 + i
                        if tempIndex > #outputList then
                            break
                        end
                        local tempItem = outputList[tempIndex]

                        local tempCard = CardNode.createCardNode({
                            resourceTypeSub = tempItem.outputTypeID, -- 资源类型
                            modelId = tempItem.outputModelID,  -- 模型Id
                            num = tempItem.outputNum, -- 资源数量
                        })
                        tempCard:setScale(0.9)
                        tempCard:setPosition(math.mod(i - 1, 3) * 140 + 120, viewSize.height - math.floor((i - 1) / 3) * 110 - 50)
                        itemNode:addChild(tempCard)

                        -- 羁绊状态
                        local relationStatus
                        if Utility.isTresureDebris(tempItem.outputTypeID) then
                            local tresureDebrisOut = TreasureDebrisModel.items[tempItem.outputModelID]
                            relationStatus = FormationObj:getRelationStatus(tresureDebrisOut.treasureModelID, tresureDebrisOut.typeID)
                        elseif Utility.isHeroDebris(tempItem.outputTypeID) then
                            local heroDebrisOut = GoodsModel.items[tempItem.outputModelID].outputModelID
                            local heroModelItem = HeroModel.items[heroDebrisOut]
                            relationStatus = FormationObj:getRelationStatus(heroModelItem.ID, ResourcetypeSub.eHero)
                        else
                            relationStatus = FormationObj:getRelationStatus(tempItem.outputModelID, tempItem.outputTypeID)
                        end
                        if relationStatus ~= Enums.RelationStatus.eNone then
                            local relationStr = {
                                [Enums.RelationStatus.eIsMember] = TR("缘份"),  -- 推荐
                                [Enums.RelationStatus.eTriggerPr] = TR("可激活"),  -- 缘分
                                [Enums.RelationStatus.eSame] = TR("已上阵")   -- 已上阵
                            }
                            local relationPic = {
                                [Enums.RelationStatus.eIsMember] = "c_57.png",  -- 推荐
                                [Enums.RelationStatus.eTriggerPr] = "c_58.png",  -- 缘分
                                [Enums.RelationStatus.eSame] = "c_62.png"  -- 已上阵
                            }
                            tempCard:createStrImgMark(relationPic[relationStatus], relationStr[relationStatus])
                        end
                    end
                end,
                selectItemChanged = function()
                    -- Todo
                end
            })
            sliderTableView:setAnchorPoint(cc.p(0.5, 0))
            sliderTableView:setPosition(layerSize.width * 0.5, 90)
            layerBgSprite:addChild(sliderTableView)
        else
            local tempList = {}
            for _, item in ipairs(outputList) do
                local tempItem = {
                    resourceTypeSub = item.outputTypeID, -- 资源类型
                    modelId = item.outputModelID,  -- 模型Id
                    num = item.outputNum, -- 资源数量
                }
                table.insert(tempList, tempItem)
            end
            local tempNode = ui.createCardList({
                maxViewWidth = layerSize.width - 50,
                cardDataList = tempList,
            })
            tempNode:setAnchorPoint(cc.p(0.5, 0.5))
            tempNode:setPosition(layerSize.width * 0.5, 210)
            layerBgSprite:addChild(tempNode)

            local cardNodeList = tempNode.getCardNodeList()
            for i,v in ipairs(cardNodeList) do
                local tempItem = tempList[i]
                -- 羁绊状态
                local relationStatus
                if Utility.isTresureDebris(tempItem.resourceTypeSub) then
                    local tresureDebrisOut = TreasureDebrisModel.items[tempItem.modelId]
                    relationStatus = FormationObj:getRelationStatus(tresureDebrisOut.treasureModelID, tresureDebrisOut.typeID)
                elseif Utility.isHeroDebris(tempItem.resourceTypeSub) then
                    local heroDebrisOut = GoodsModel.items[tempItem.modelId].outputModelID
                    local heroModelItem = HeroModel.items[heroDebrisOut]
                    relationStatus = FormationObj:getRelationStatus(heroModelItem.ID, ResourcetypeSub.eHero)
                else
                    relationStatus = FormationObj:getRelationStatus(tempItem.modelId, tempItem.resourceTypeSub)
                end
                if relationStatus ~= Enums.RelationStatus.eNone then
                    local relationStr = {
                        [Enums.RelationStatus.eIsMember] = TR("缘份"),  -- 推荐
                        [Enums.RelationStatus.eTriggerPr] = TR("可激活"),  -- 缘分
                        [Enums.RelationStatus.eSame] = TR("已上阵")   -- 已上阵
                    }
                    local relationPic = {
                        [Enums.RelationStatus.eIsMember] = "c_57.png",  -- 推荐
                        [Enums.RelationStatus.eTriggerPr] = "c_58.png",  -- 缘分
                        [Enums.RelationStatus.eSame] = "c_62.png"  -- 已上阵
                    }
                    v:createStrImgMark(relationPic[relationStatus], relationStr[relationStatus])
                end
            end
        end
    end

    -- 时装选择包道具信息DIY函数
    local function DIYFashionChoiceFunction(layer, layerBgSprite, layerSize)
        -- body
    end

    -- 其他道具信息DIY函数
    local function DIYNormalFunction(layer, layerBgSprite, layerSize)
        -- 创建物品的头像
        local tempCard = CardNode.createCardNode({
            resourceTypeSub = tempModel.typeID, -- 资源类型
            modelId = goodsModelId,  -- 模型Id
            num = nil, -- 资源数量
            allowClick = false,
        })
        tempCard:setPosition(layerSize.width / 2, layerSize.height - 130)
        layerBgSprite:addChild(tempCard)

        -- 创建碎片的简介
        local tempLabel = ui.newLabel({
            text = tempModel.intro == "" and TR("神秘物品，暂无介绍") or tempModel.intro,
            color = Enums.Color.eNormalWhite,
            outlineColor = cc.c3b(0x46, 0x22, 0x0d),
            align = ui.TEXT_ALIGN_CENTER,
            valign = ui.TEXT_VALIGN_TOP,
            size = (goodsModelId == 16050065) and 20 or Enums.Fontsize.eDefault,
            dimensions = cc.size(layerSize.width - 80, 0)
        })
        tempLabel:setAnchorPoint(cc.p(0.5, 1))
        tempLabel:setPosition(layerSize.width / 2, layerSize.height - 210)
        layerBgSprite:addChild(tempLabel)
    end

    title = title or TR("物品详情")
    if tempModel.typeID == ResourcetypeSub.eBoxFixed then    -- "固定箱包类"
        return MsgBoxLayer.addDIYLayer({
            title = title,
            bgSize = cc.size(572, 420),
            DIYUiCallback = DIYBoxFixedFuncion
        })
    elseif tempModel.typeID == ResourcetypeSub.eBoxOdds then    -- "概率箱包类"
        return MsgBoxLayer.addDIYLayer({
            title = title,
            bgSize = cc.size(572, 450),
            DIYUiCallback = DIYBoxOddsFunction
        })
    elseif tempModel.typeID == ResourcetypeSub.eBoxChoice then    -- "可选择礼包"
        return MsgBoxLayer.addDIYLayer({
            title = title,
            bgSize = cc.size(572, 450),
            DIYUiCallback = DIYBoxChoiceFunction
        })
    elseif tempModel.typeID == ResourcetypeSub.eFashionChoice then    -- "时装选择包"
        return MsgBoxLayer.addDIYLayer({
            title = title,
            bgSize = cc.size(572, 450),
            DIYUiCallback = DIYFashionChoiceFunction
        })
    else -- 其他
        return MsgBoxLayer.addDIYLayer({
            title = title,
            bgSize = cc.size(572, 380),
            DIYUiCallback = DIYNormalFunction
        })
    end
end

----------------------------------------------------------------------------------------------------

-- 道具数量选择DIY函数
--[[
-- 参数
    params:
    {
        layer: 提示窗体对象
        layerBgSprite: 提示窗体的背景图
        layerSize: 提示窗体的大小
        resourcetypeSub: 资源类型
        modelId: 提示窗体显示资源的模型Id
        cardPosition: 根据显示要求调整物品头像显示位置
        maxNum: 提示窗体可以选择的最大数，如果为nil 或 小于等于 0 ，则表示无限大
        countChangeCallback: 选择数改变后的回调函数
        getHintCallback: 选择数改变后，获取变化提示信息的回调函数，如果该参数为nil，表面没有因数量改变而变化的提示信息
        extraNum: 额外倍数显示
        introStr:真元兑换的时候的提示语
        isAddMaxBtn:按键10变为最大
        isHint: 是否显示简介或提示
    }
]]
local function selectGoodsCountDIY(params)
    params = params or {}
    local tempModel = GoodsModel.items[params.modelId] or nil
    if not params.resourcetypeSub and not tempModel then
        return
    end

    -- 道具卡牌显示
    local positionCard = params.cardPosition or cc.p(params.layerSize.width * 0.5, params.layerSize.height - 135)
    local goodsCard, attrControl = CardNode.createCardNode({
        resourceTypeSub = params.resourcetypeSub or tempModel.typeID, -- 资源类型
        modelId = params.modelId,  -- 模型Id
        cardShowAttrs = {CardShowAttr.eBorder}
    })
    goodsCard:setPosition(positionCard)
    params.layerBgSprite:addChild(goodsCard)
    -- 道具名称
    local positionName = nil
    if params.cardPosition then
        positionName = cc.p(params.cardPosition.x , params.cardPosition.y - 70)
    else
        positionName = cc.p(params.layerSize.width * 0.5, params.layerSize.height - 205)
    end
    local goodsName = Utility.getGoodsName(params.resourcetypeSub, params.modelId or 0)
    local nameLabel = ui.newLabel({
        text =  (goodsName ~= "") and goodsName or tempModel and tempModel.name or TR("神秘物品"),
        color = Enums.Color.eBrown,
    })
    nameLabel:setAnchorPoint(cc.p(0.5, 0.5))
    nameLabel:setPosition(positionName)
    params.layerBgSprite:addChild(nameLabel)

    -- 出售或购买价格显示
    local positionPrice = nil
    if params.cardPosition then
        positionPrice = cc.p(params.cardPosition.x , params.cardPosition.y - 105)
    else
        positionPrice = cc.p(params.layerSize.width * 0.5, params.layerSize.height - 240)
    end 
    local praceLabel = ui.newLabel({
        text = TR("出售价格：{%s}%d", "db_1112.png", 1000),
        color = Enums.Color.eNormalWhite,
        outlineColor = cc.c3b(0x46, 0x22, 0x0d),
        align = cc.TEXT_ALIGNMENT_CENTER,
    })
    praceLabel:setPosition(positionPrice)
    praceLabel:setString("")
    params.layerBgSprite:addChild(praceLabel)

    -- 重新设置道具的提示信息和其位置
    local tempLabel = params.layer.mMsgLabel
    tempLabel:setAnchorPoint(cc.p(0.5, 1))
    tempLabel:setPosition(params.layerSize.width * 0.5, params.layerSize.height - 260)
    if not Utility.isZhenyuan(params.resourcetypeSub) then 
        tempLabel:setString(Utility.getGoodsIntro(params.resourcetypeSub, params.modelId) or tempModel.intro)
    else 
        tempLabel:setString(params.introStr or "")  
    end     
    if params.isHint == false then
        tempLabel:setString("")
    end

    -- 数量选择控件
    local tempView = require("common.SelectCountView"):create({
        maxCount = params.maxNum,
        viewSize = cc.size(500, 200),
        extraNum = params.extraNum,
        isAddMaxBtn = params.isAddMaxBtn,
        changeCallback = function(count)
            if params.countChangeCallback then
                params.countChangeCallback(count)
            end
            if params.getHintCallback then
                local text = params.getHintCallback(count)
                if text then
                    praceLabel:setString(text)
                else
                    return false
                end
            end
            return true
        end
    })
    tempView:setPosition(params.layerSize.width / 2, 150)
    params.layerBgSprite:addChild(tempView)
end

-- 道具使用数量选择提示框
--[[
-- 参数
    title: 提示窗体的标题，默认为：TR("使用") 或 TR("出售")
    goodsModelId: 道具的模型Id
    maxNum: 拥有该物品的数量, 如果为nil 或 小于等于 0 ，则表示无限大
    OkCallback: 选择确认的回调函数，回调参数为: OkCallback(selCount, layerObj, btnObj)
    extraNum: 额外倍数显示
    resourcetypeSub:资源类型
    isHint: 是否显示简介或提示

]]
function MsgBoxLayer.addUseGoodsCountLayer(title, goodsModelId, maxNum, OkCallback, extraNum, resourcetypeSub, isHint)
    local selCount = 1 -- 当前选择的数量

    -- 提示窗体自定义控件函数
    local function DIYFuncion(layer, layerBgSprite, layerSize)
        -- 数量改变的回调
        local function changeCallback(count)
            selCount = count
        end

        -- 物品信息的背景
        local tempSprite = ui.newScale9Sprite("c_17.png", cc.size(546, 280))
        tempSprite:setAnchorPoint(cc.p(0.5, 1))
        tempSprite:setPosition(layerSize.width / 2, layerSize.height - 85)
        layerBgSprite:addChild(tempSprite)

        selectGoodsCountDIY({
            layer = layer,
            layerBgSprite = layerBgSprite,
            layerSize = layerSize,
            resourcetypeSub = resourcetypeSub,
            modelId = goodsModelId,
            maxNum = maxNum,
            extraNum = extraNum,
            cardPosition = cc.p(layerSize.width * 0.5, layerSize.height - 165),
            countChangeCallback = changeCallback,
            isHint = isHint,
        })
    end

    local okBtnInfo = {
        text = TR("确定"),
        clickAction = function(layerObj, btnObj)
            OkCallback(selCount, layerObj, btnObj)
        end,
    }
    return MsgBoxLayer.addDIYLayer({
        msgText = TR("提示信息"),
        title = title or TR("选择"),
        bgSize = cc.size(598, 474),
        btnInfos = {okBtnInfo},
        closeBtnInfo = {},
        DIYUiCallback = DIYFuncion,
        notNeedBlack = true,
    })
end

-- 道具碎片合成数量选择提示框
--[[
-- 参数
    title: 提示窗体的标题，默认为：TR("合成") 
    goodsModelId: 道具的模型Id
    maxNum: 合成产出的最多数量, 如果为nil 或 小于等于 0 ，则表示无限大
    OkCallback: 选择确认的回调函数，回调参数为: OkCallback(selCount, layerObj, btnObj)
    extraNum: 额外倍数显示
]]
function MsgBoxLayer.addMixGoodsCountLayer(title, goodsModelId, maxNum, OkCallback, extraNum)
    local selCount = 1 -- 当前选择的数量

    -- 提示窗体自定义控件函数
    local function DIYFuncion(layer, layerBgSprite, layerSize)
        -- 数量改变的回调
        local function changeCallback(count)
            selCount = count
        end

        -- 物品信息的背景
        local tempSprite = ui.newScale9Sprite("c_17.png", cc.size(546, 280))
        tempSprite:setAnchorPoint(cc.p(0.5, 1))
        tempSprite:setPosition(layerSize.width / 2, layerSize.height - 85)
        layerBgSprite:addChild(tempSprite)

        -- 当前拥有
        local ownNum = Utility.getOwnedGoodsCount(GoodsModel.items[goodsModelId].typeID, goodsModelId)
        local needNum = GoodsSpModel.items[goodsModelId].needsNumber
        local hadNumLabel = ui.newLabel({
                text = TR("当前拥有: %s/%s", Utility.numberWithUnit(ownNum), Utility.numberWithUnit(needNum)),
                outlineColor = cc.c3b(0x46, 0x22, 0x0d),
            })
        hadNumLabel:setPosition(layerSize.width / 2, layerSize.height - 275)
        layerBgSprite:addChild(hadNumLabel)

        selectGoodsCountDIY({
            layer = layer,
            layerBgSprite = layerBgSprite,
            layerSize = layerSize,
            modelId = goodsModelId,
            maxNum = maxNum,
            extraNum = extraNum,
            cardPosition = cc.p(layerSize.width * 0.5, layerSize.height - 165),
            countChangeCallback = changeCallback
        })
    end

    local okBtnInfo = {
        text = TR("确定"),
        clickAction = function(layerObj, btnObj)
            OkCallback(selCount, layerObj, btnObj)
        end,
    }
    return MsgBoxLayer.addDIYLayer({
        msgText = TR("提示信息"),
        title = title or TR("合成"),
        bgSize = cc.size(598, 474),
        btnInfos = {okBtnInfo},
        closeBtnInfo = {},
        DIYUiCallback = DIYFuncion,
        notNeedBlack = true,
    })
end

-- 道具兑换选择提示框(多代币)
--[[
-- 参数
    params:  -- 均为必选参数
    {
        title:           提示窗体的标题，默认为：TR("兑换")
        modelID          道具商品模型ID   -- 从道具模型中获得
        typeID           道具资源类型ID   -- 从道具模型中获得
        coinList         需要的代币列表
        [{
            resourceTypeSub 代币类型
            modelId         如果类型不是玩家属性，则需要传入模型Id
            num             道具兑换价格     -- 从道具模型中获得
        }]
        maxNum: 可兑换的最大数量, 如果为nil 或 小于等于 0, 则表示无限大
        oKCallBack: 选择确认的回调函数, 回调参数为OKCallback(exchangeCount, layerObj, btnObj)
        boxSize             弹窗大小
        isAddMaxBtn         添加一键最大按钮
    }
]]
function MsgBoxLayer.addExchangeGoodsListCountLayer(params)
    local exchangeCount = 1     -- 当前选择数量
    local goodsModelId = params.modelID -- 商品模型ID
    local typeId = params.typeID -- 资源类型ID
    local oKCallBack = params.oKCallBack
    local coinList = params.coinList    -- 需要的代币列表

    -- 提示窗体自定义控件函数
    local function DIYFuncion(layer, layerBgSprite, layerSize)
        -- 数量改变的回调
        local function changeCallback(count)
            exchangeCount = count
        end

        -- 数量改变后展示信息改变的的回调
        local function getHintCallback(count)
            local coinStr = ""
            for i,v in ipairs(coinList) do
                if v.resourceTypeSub == Enums.ExchangeGoodsID.eZhenyuan then -- 真元兑换
                    local tempCount = v.num * count
                    coinStr = coinStr .. TR("修炼值: %d", tempCount)
                    if i ~= #coinList then
                        coinStr = coinStr .. "    "
                    end
                elseif v.resourceTypeSub == Enums.ExchangeGoodsID.eJHKVoucher then -- 江湖杀兑换
                    local tempCount = v.num * count
                    coinStr = coinStr .. TR("荣誉点: %d", tempCount)
                    if i ~= #coinList then
                        coinStr = coinStr .. "    "
                    end
                else
                    local tempImg = Utility.getDaibiImage(v.resourceTypeSub, v.modelId)
                    local tempCount = v.num * count
                    coinStr = coinStr .. string.format("{%s}%d", tempImg, tempCount)
                    if i ~= #coinList then
                        coinStr = coinStr .. "    "
                    end
                end     
            end
            return coinStr
        end

        local function getIntro( )
            local intro = ""
            for i,v in ipairs(coinList) do
                if v.resourceTypeSub == Enums.ExchangeGoodsID.eZhenyuan then -- 真元兑换
                    local goodsName = Utility.getGoodsName(typeId, goodsModelId or 0)
                    intro = TR("集齐%d修炼值可以兑换%s", v.num, goodsName)
                    if i ~= #coinList then
                        intro = intro .. "    "
                    end
                end     
            end
            return intro
        end

        -- 物品信息的背景
        local tempSprite = ui.newScale9Sprite("c_17.png", cc.size(546, 300))
        tempSprite:setAnchorPoint(cc.p(0.5, 1))
        tempSprite:setPosition(layerSize.width / 2, layerSize.height - 75)
        layerBgSprite:addChild(tempSprite)

        selectGoodsCountDIY({layer = layer,
            layerBgSprite = layerBgSprite,
            layerSize = layerSize,
            resourcetypeSub = typeId,
            modelId = goodsModelId,
            maxNum = params.maxNum,
            countChangeCallback = changeCallback,
            getHintCallback = getHintCallback,
            introStr = getIntro(), -- 只对真元兑换有效
            isAddMaxBtn = params.isAddMaxBtn,
        })
    end

    local okBtnInfo = {
        text = TR("确定"),
        clickAction = function(layerObj, btnObj)
            oKCallBack(exchangeCount, layerObj, btnObj)
        end,
    }

    return MsgBoxLayer.addDIYLayer({
        msgText = TR("提示信息"),
        title = params.title or TR("选择"),
        bgSize = params.boxSize or cc.size(598, 485),
        btnInfos = {okBtnInfo},
        closeBtnInfo = {},
        DIYUiCallback = DIYFuncion,
        notNeedBlack = true,
    })
end

-- 道具兑换选择提示框(参见“addExchangeGoodsListCountLayer”)
--[[ 参数
    params:  -- 均为必选参数
    {
        resourcetypeCoin 代币类型
        modelIdCoin     如果类型不是玩家属性，则需要传入模型Id
        exchangePrice   道具兑换价格     -- 从道具模型中获得
    }
--]]
function MsgBoxLayer.addExchangeGoodsCountLayer(params)
    params.coinList = {{resourceTypeSub = params.resourcetypeCoin, 
        modelId = params.modelIdCoin, num = params.exchangePrice}}
    return MsgBoxLayer.addExchangeGoodsListCountLayer(params)
end

-- 道具出售数量选择提示框
--[[
-- 参数
    title: 提示窗体的标题，默认为：TR("使用") 或 TR("出售")
    goodsModelId: 道具的模型Id
    maxNum: 拥有该物品的数量, 如果为nil 或 小于等于 0 ，则表示无限大
    OkCallback: 选择确认的回调函数，回调参数为: OkCallback(selCount, layerObj, btnObj)
    isAddMaxBtn         添加一键最大按钮
]]
function MsgBoxLayer.addSellGoodsCountLayer(title, goodsModelId, maxNum, OkCallback, price, priceName, isAddMaxBtn)
    local selCount = 1 -- 当前选择的数量
    local tempModel = GoodsModel.items[goodsModelId]

    -- 提示窗体自定义控件函数
    local function DIYFuncion(layer, layerBgSprite, layerSize)
        -- 数量改变的回调
        local function changeCallback(count)
            selCount = count
        end
        -- 数量改变后展示信息改变的的回调
        local function getHintCallback(count)
            local tempImg = Utility.getResTypeSubImage(tempModel.sellTypeID)
            local tempCount = price and price * count or tempModel.sellNum * count
            return price and TR("出售价格：%d%s", tempCount, priceName) or TR("出售价格：{%s}%d", tempImg, tempCount)
        end

        -- 物品信息的背景
        local tempSprite = ui.newScale9Sprite("c_17.png", cc.size(546, 280))
        tempSprite:setAnchorPoint(cc.p(0.5, 1))
        tempSprite:setPosition(layerSize.width / 2, layerSize.height - 85)
        layerBgSprite:addChild(tempSprite)

        selectGoodsCountDIY({
            layer = layer,
            layerBgSprite = layerBgSprite,
            layerSize = layerSize,
            modelId = goodsModelId,
            maxNum = maxNum,
            countChangeCallback = changeCallback,
            getHintCallback = getHintCallback,
            cardPosition = cc.p(layerSize.width * 0.5, layerSize.height - 165),
            isAddMaxBtn = isAddMaxBtn
        })
    end

    local okBtnInfo = {
        text = TR("确定"),
        clickAction = function(layerObj, btnObj)
            OkCallback(selCount, layerObj, btnObj)
        end,
    }

    return MsgBoxLayer.addDIYLayer({
        msgText = TR("提示信息"),
        title = title or TR("选择"),
        bgSize = cc.size(598, 474),
        btnInfos = {okBtnInfo},
        closeBtnInfo = {},
        DIYUiCallback = DIYFuncion,
        notNeedBlack = true,
    })
end

-- 购买道具数量选择提示框
--[[
-- 参数
    title：提示窗体的标题，默认为：TR("购买")
    goodBuyInfo: 购买道具的信息，由 服务器 "ShopGoods"模块的"ShopGoodsList"接口返回列表中的条目，具体数据内容如下
        {
            InitPrice" = 0,
            "Num" = 0,
            "DynamicPrice" = {
                1 = {
                    "NewPrice" = 20,
                    "Num" = 1,
                },
                2 = {
                    "NewPrice" = 20,
                    "Num" = 2,
                },
                ...
            },
            "MaxNum" = 28,
            "GoodsModelId" = 16030006,
            "CurrPrice" = 20,
            "NeedLv" = 1,
            "SellTypeId" = 1111,
        }
    OkCallback: 选择确认的回调函数，回调参数为: OkCallback(selCount, layerObj, btnObj)
]]
function MsgBoxLayer.addBuyGoodsCountLayer(title, goodBuyInfo, OkCallback)
    local selCount = 1 -- 当前选择的数量
    local selPrice = 0
    -- 提示窗体自定义控件函数
    local function DIYFuncion(layer, layerBgSprite, layerSize)
        -- 数量改变的回调
        local function changeCallback(count)
            selCount = count
        end
        -- 数量改变后展示信息改变的的回调
        local function getHintCallback(count)
            local tempImg = Utility.getResTypeSubImage(goodBuyInfo.SellTypeId)
            local tempCount = 0
            if goodBuyInfo.DynamicPrice then
                local max = table.maxn(goodBuyInfo.DynamicPrice)
                local index = goodBuyInfo.Num + 1
                for k = 1, selCount do
                    local curIndex = (k - 1) + index
                    local item = goodBuyInfo.DynamicPrice[curIndex] or goodBuyInfo.DynamicPrice[max]
                    if item then
                        tempCount = tempCount + item.NewPrice
                    end
                end
            else
                tempCount = selCount * goodBuyInfo.CurrPrice
            end
            selPrice = tempCount

            return string.format("{%s}%d", tempImg, tempCount)
        end

        selectGoodsCountDIY({
            layer = layer,
            layerBgSprite = layerBgSprite,
            layerSize = layerSize,
            modelId = goodBuyInfo.ModelId,
            maxNum = goodBuyInfo.MaxNum,
            countChangeCallback = changeCallback,
            getHintCallback = getHintCallback
        })
    end

    local okBtnInfo = {
        text = TR("确定"),
        clickAction = function(layerObj, btnObj)
            OkCallback(selCount, layerObj, btnObj, selPrice)
        end,
    }

    return MsgBoxLayer.addDIYLayer({
        msgText = TR("提示信息"),
        title = title or TR("购买"),
        bgSize = cc.size(574, 446),
        btnInfos = {okBtnInfo},
        closeBtnInfo = {},
        DIYUiCallback = DIYFuncion,
    })
end

-- 使用可选择礼包，产出选择提示框
--[[
-- 参数
    title: 提示窗体的标题，默认为：TR("选择物品")
    goodsModelId: 道具的模型Id
    maxNum: 拥有该物品的数量
]]
function MsgBoxLayer.addChoiceGoodsOutLayer(title, goodsModelId, maxNum, OkCallback)

    local model = GoodsOutputRelation.items[goodsModelId]
    if not model then
        return
    end
    table.sort(model, function(a, b)
        local tempModelA 
        local tempModelB 
        local relationa 
        local relationb
        if Utility.isTresureDebris(a.outputTypeID)then
            tempModelA = TreasureDebrisModel.items[a.outputModelID]
            tempModelB = TreasureDebrisModel.items[b.outputModelID]
            relationa = FormationObj:getRelationStatus(tempModelA.treasureModelID, tempModelA.typeID)
            relationb = FormationObj:getRelationStatus(tempModelB.treasureModelID, tempModelB.typeID)
        elseif Utility.isHeroDebris(a.outputTypeID) then
            tempModelA = HeroModel.items[GoodsModel.items[a.outputModelID].outputModelID]
            tempModelB = HeroModel.items[GoodsModel.items[b.outputModelID].outputModelID]
            relationa = FormationObj:getRelationStatus(tempModelA.ID, ResourcetypeSub.eHero)
            relationb = FormationObj:getRelationStatus(tempModelB.ID, ResourcetypeSub.eHero)
        else
            relationa = FormationObj:getRelationStatus(a.outputModelID, a.outputTypeID)
            relationb = FormationObj:getRelationStatus(b.outputModelID, b.outputTypeID)
        end

        -- 根据羁绊类型排序
        if relationa ~= relationb then
            return relationa > relationb
        end

        -- 根据品质排序
        local qualitya = ConfigFunc:getItemBaseModel(a.outputModelID).quality
        local qualityb = ConfigFunc:getItemBaseModel(b.outputModelID).quality
        if qualitya ~= qualityb then
            return qualitya > qualityb
        end

        -- 特殊需求，在上阵的人物中，小伙伴排后面
        if Utility.isHeroDebris(a.outputTypeID) or Utility.isHero(a.outputTypeID) then
            if Utility.isHeroDebris(a.outputTypeID) then
                if relationa == relationb and relationa == Enums.RelationStatus.eSame then
                    local isMateA = Utility.isHeroInMate(tempModelA.ID)
                    local isMateB = Utility.isHeroInMate(tempModelB.ID)
                    if isMateA ~= isMateB then
                        return not isMateA
                    end
                end
            else
                if relationa == relationb and relationa == Enums.RelationStatus.eSame then
                    local isMateA = Utility.isHeroInMate(a.outputModelID)
                    local isMateB = Utility.isHeroInMate(b.outputModelID)
                    if isMateA ~= isMateB then
                        return not isMateA
                    end
                end
            end
        end

        -- 根据模型ID排序
        return a.outputModelID < b.outputModelID
    end)

    local result = {}
    for _, value in ipairs(model) do
        table.insert(result,{
            resourceTypeSub = math.floor(value.outputModelID / 10000),
            type   = value.outputTypeID,
            modelId = value.outputModelID,
            num  = value.outputNum,
            isRace = true,
            ID = value.ID,
        })
    end

    local selectid = 1
    local selectNum = 1
    local function DIYUiCallback(layer, layerBgSprite, layerSize)
        local msgtext = ui.newLabel({
            text = TR("请选择一件物品"),
            color = Enums.Color.eNormalWhite,
            outlineColor = cc.c3b(0x46, 0x22, 0x0d),
        })
        msgtext:setPosition(#model > 4 and cc.p(layerSize.width / 2, 420) or cc.p(layerSize.width / 2, 320))
        layerBgSprite:addChild(msgtext)
        layer.mGridView = require("common.GridView"):create({
            viewSize = #model > 4 and cc.size(500, 250) or cc.size(500, 130),
            colCount = 4,
            celHeight = 130,
            selectIndex = selectid,
            getCountCb = function()
                return #result
            end,
            createColCb = function(itemParent, colIndex, isSelected)
                local attrs = {CardShowAttr.eBorder, CardShowAttr.eName}
                if isSelected then
                    table.insert(attrs, CardShowAttr.eSelected)
                end
                -- 卡牌对应的数据
                local itemData = result[colIndex]

                if Utility.isZhenjue(itemData.resourceTypeSub) then
                    table.insert(attrs, CardShowAttr.eZhenjueType)
                end
                -- 创建显示图片
                local cardNode, Attr = CardNode.createCardNode({
                    resourceTypeSub = itemData.resourceTypeSub,
                    allowClick = true,
                    modelId = itemData.modelId,
                    num = itemData.num,
                    cardShowAttrs = attrs,
                    onClickCallback = function()
                        layer.mGridView:setSelect(colIndex)
                        if selectid == colIndex then
                            CardNode.defaultCardClick(itemData)
                        end
                        selectid = colIndex
                    end,
                })
                local xPos = #model > 4 and 65 or (245 - (#model - 1) * 60)
                cardNode:setPosition(xPos, 78)
                itemParent:addChild(cardNode)

                -- 羁绊状态
                local relationStatus
                if Utility.isTresureDebris(itemData.resourceTypeSub) then
                    local tresureDebrisOut = TreasureDebrisModel.items[itemData.modelId]
                    relationStatus = FormationObj:getRelationStatus(tresureDebrisOut.treasureModelID, tresureDebrisOut.typeID)
                elseif Utility.isHeroDebris(itemData.resourceTypeSub) then
                    local heroDebrisOut = GoodsModel.items[itemData.modelId].outputModelID
                    local heroModelItem = HeroModel.items[heroDebrisOut]
                    relationStatus = FormationObj:getRelationStatus(heroModelItem.ID, ResourcetypeSub.eHero)
                else
                    relationStatus = FormationObj:getRelationStatus(itemData.modelId, itemData.resourceTypeSub)
                end
                if relationStatus ~= Enums.RelationStatus.eNone then
                    local relationStr = {
                        [Enums.RelationStatus.eIsMember] = TR("缘份"),  -- 推荐
                        [Enums.RelationStatus.eTriggerPr] = TR("可激活"),  -- 缘分
                        [Enums.RelationStatus.eSame] = TR("已上阵")   -- 已上阵
                    }
                    local relationPic = {
                        [Enums.RelationStatus.eIsMember] = "c_57.png",  -- 推荐
                        [Enums.RelationStatus.eTriggerPr] = "c_58.png",  -- 缘分
                        [Enums.RelationStatus.eSame] = "c_62.png"  -- 已上阵
                    }
                    cardNode:createStrImgMark(relationPic[relationStatus], relationStr[relationStatus])
                end
            end,
        })
        layer.mGridView:setAnchorPoint(0, 1)
        layer.mGridView:setPosition(#model > 4 and cc.p(40, 405) or cc.p(40, 290))
        layer.mGridView:setSelect(selectid)
        layerBgSprite:addChild(layer.mGridView)



        local tempView = require("common.SelectCountView"):create({
            maxCount = maxNum,
            viewSize = cc.size(500, 200),
            changeCallback = function(count)
                selectNum = count
            end
        })
        tempView:setPosition(#model > 4 and cc.p(286, 125) or cc.p(286, 130))
        layerBgSprite:addChild(tempView)

    end

    local tempData = {
        title = title or TR("选择物品"),
        bgSize = cc.size(572, #model > 4 and 510 or 437),
        btnInfos = {
            {
                text = TR("确定"),
                clickAction = function()
                    OkCallback(selectNum, result[selectid].modelId) 
                end
            },
            {text = TR("取消"),}
        },
        DIYUiCallback = DIYUiCallback,
    }

    return LayerManager.addLayer({name = "commonLayer.MsgBoxLayer", data = tempData, cleanUp = false, needRestore = true,})
end

-- 竞拍购买提示框
--[[
-- 参数
    goodBuyInfo: 具体数据内容如下
        {
            auctionName = "xxx",   -- 购买名称
            auctionNum = 20,       -- 购买数量
            dbType = ,             -- 代币类型
            dbModelId = ,          -- 代币的moduleId
            curPrice = 100,        -- 当前价
            topCount = 100,        -- 最高次数
            perPrice = 10,         -- 单次加价量
        }
    OkCallback: 选择确认的回调函数，回调参数为: OkCallback(auctionCount, layerObj, btnObj)
]]
function MsgBoxLayer.addAuctionLayer(goodBuyInfo, OkCallback)
    local selCount = 1 -- 当前选择的数量
    local msgSize = cc.size(574, 446)
    local goodImage =  Utility.getDaibiImage(goodBuyInfo.dbType, goodBuyInfo.dbModelId)
    function getMsgContent(count)
        return TR("是否以{%s}%s%d%s拍下%s%s*%d", 
            goodImage, 
            Enums.Color.eGreenH, goodBuyInfo.curPrice + selCount * goodBuyInfo.perPrice, Enums.Color.eNormalWhiteH,
            Enums.Color.eGreenH, goodBuyInfo.auctionName, goodBuyInfo.auctionNum)
    end
    -- 提示窗体自定义控件函数
    local function DIYFuncion(layer, layerBgSprite, layerSize)
        layer.mMsgLabel:setPosition(msgSize.width/2, 300)
        -- 倒计时文字
        local perLabel = ui.newLabel({
            text = TR("最小加价:{%s}#80100E%d", goodImage, goodBuyInfo.perPrice),
            color = cc.c3b(0x46, 0x22, 0x0d),
            x = msgSize.width/2,
            y = 150,
        })
        layerBgSprite:addChild(perLabel)
        -- 数量选择控件
        local tempView = require("common.SelectCountView"):create({
            maxCount = goodBuyInfo.topCount,
            viewSize = cc.size(500, 200),
            changeCallback = function(count)
                selCount = count
                layer.mMsgLabel:setString(getMsgContent(selCount))
                return true
            end
        })
        tempView:setPosition(msgSize.width / 2, 230)
        layerBgSprite:addChild(tempView)
    end

    local btnInfo = {{
        text = TR("确定"),
        clickAction = function(layerObj, btnObj)
            OkCallback(selCount, layerObj, btnObj)
        end,
        },
        {
            text = TR("取消"),
        },
    }
    return MsgBoxLayer.addDIYLayer({
        msgText = getMsgContent(selCount),
        title = title or TR("参与竞拍"),
        bgSize = msgSize,
        btnInfos = btnInfo,
        closeBtnInfo = {},
        DIYUiCallback = DIYFuncion,
    })
end

----------------------------------------------------------------------------------------------------

-- 获取元宝提示框
function MsgBoxLayer.addGetDiamondHintLayer()
    -- 如果VIP模块为开启，则不显示
    if not ModuleInfoObj:moduleIsOpenInServer(ModuleSub.eVIP) then
        return
    end

    -- 玩家当前的VIP信息
    local playerInfo = PlayerAttrObj:getPlayerInfo()
    local currVip, currVipExp = playerInfo.Vip, playerInfo.VipEXP

    -- 整理提示信息
    local hintStr = TR("元宝不足, 充值可获得大量元宝！多买多送哟！")

    -- 整理充值提升VIP等级后的奖励
    local vipPropsList = {}
    if currVipExp == 0 then -- 显示首充礼包奖励
        vipPropsList = Utility.analysisStrResList(ChargeFirstModel.items[1].rewardResouceList)
    else -- 显示VIP礼包奖励
        local tempModel = VipModel.items[currVip + 1]
        local vipGoodsModelID = tempModel and tempModel.vipGoodsModelID or 0
        local tempList = GoodsOutputRelation.items[vipGoodsModelID] or {}
        for _, item in pairs(tempList) do
            local tempItem = {
                resourceTypeSub = item.outputTypeID,
                modelId = item.outputModelID,
                num = item.outputNum,
            }
            table.insert(vipPropsList, tempItem)
        end
    end
    local function DIYFuncion(layer, layerBgSprite, layerSize)
        local grayUnderbg = ui.newScale9Sprite("c_17.png", cc.size(428, 160))
        grayUnderbg:setPosition(layerSize.width / 2 + 5, layerSize.height / 2 + 20)
        layerBgSprite:addChild(grayUnderbg)

        local tipSprite = ui.newSprite("cz_18.png")
        tipSprite:setPosition(layerSize.width / 2 + 5, layerSize.height / 2 + 45)
        layerBgSprite:addChild(tipSprite)
    end

    local tempData = {
        title = TR("提示"),
        -- msgText = hintStr,
        bgSize = cc.size(480, 350),
        resourceList = vipPropsList,
        btnInfos = {
            {
                normalImage = "c_28.png",
                text = TR("去充值"),
                position = cc.p(240, 65),
                clickAction = function()
                    LayerManager.showSubModule(ModuleSub.eCharge)
                end
            },
        },
        closeBtnInfo = {},
        notNeedBlack = true,
        DIYUiCallback = DIYFuncion,
    }
    return LayerManager.addLayer({name = "commonLayer.MsgBoxLayer", data = tempData, cleanUp = false})
end

-- 铜币不足的提示框
function MsgBoxLayer.addGetGoldHintLayer()
    -- 显示提示文字和按钮
    local btnInfoList = {
        {
            text = TR("江湖悬赏"),
            hintStr = TR("每通一关都有海量铜钱"),
            clickAction = function ()
                if not ModuleInfoObj:modulePlayerIsOpen(ModuleSub.eXrxs, true) then
                    return
                end
                LayerManager.showSubModule(ModuleSub.eXrxs)
            end
        },
        {
            text = TR("钱庄"),
            hintStr = TR("使用元宝换取大量铜钱"),
            clickAction = function ()
                if not ModuleInfoObj:modulePlayerIsOpen(ModuleSub.eLuckySymbol, true) then
                    return
                end
                LayerManager.showSubModule(ModuleSub.eLuckySymbol)
            end
        },
    }
    local function DIYFuncion(layer, layerBgSprite, layerSize)
        -- 重新设置提示内容的位置
        layer.mMsgLabel:setPosition(layerSize.width / 2, layerSize.height - 100)
        local startPosY = layerSize.height - 180
        for index, btnInfo in ipairs(btnInfoList) do
            local tempPosY = startPosY - (index - 1) * 85
            -- 提示信息
            local tempLabel = ui.newLabel({
                text = btnInfo.hintStr,
                color = cc.c3b(0x46, 0x22, 0x0d),
            })
            tempLabel:setAnchorPoint(cc.p(0, 0.5))
            tempLabel:setPosition(35, tempPosY)
            layerBgSprite:addChild(tempLabel)

            -- 按钮
            btnInfo.normalImage = "c_28.png"
            btnInfo.position = cc.p(layerSize.width - 35, tempPosY)
            btnInfo.anchorPoint = cc.p(1, 0.5)

            local tempBtn = ui.newButton(btnInfo)
            layerBgSprite:addChild(tempBtn)
        end
    end

    local hintStr = TR("出来跑江湖，没有%s铜钱%s是万万不行的哦！", Enums.Color.eOrangeH, Enums.Color.eNormalWhiteH)
    return MsgBoxLayer.addDIYLayer({
        msgText = hintStr,
        bgSize = cc.size(572, 337 + 85 * (#btnInfoList - 1)),
        title = TR("获取铜钱"),
        DIYUiCallback = DIYFuncion,
        closeBtnInfo = {},
    })
end

-- 体力或耐力不足的提示框
--[[
-- 参数
    resourceTypeSub：资源类型，取值在 EnumsConfig.lua 文件中 ResourcetypeSub 的定义
    needCount: 需要的数量
]]
function MsgBoxLayer.addGetStaOrVitHintLayer(resourceTypeSub, needCount, callback)
    local viewInfos = {
        -- 体力
        [ResourcetypeSub.eVIT] = {
            title = TR("体力不足"),
            hint = TR("体力不足，食用叫花鸡可恢复体力"),
            goodsModelId = 16030006,
        },
        -- 耐力
        [ResourcetypeSub.eSTA] = {
            title = TR("气力不足"),
            hint = TR("气力不足，服用正气丸可恢复气力"),
            goodsModelId = 16030008,
        },
        -- ...
    }
    local currViewInfo = viewInfos[resourceTypeSub] or {}

    local msgLayer, priceLable, haveLabel, price, buyNum = nil, nil, nil, 1000, 0
    local goodsCount = GoodsObj:getCountByModelId(currViewInfo.goodsModelId or 0)
    local priceListInfo = {}
    local selectCount = 1
    local maxBuyNum = 0
    local tempSelectView = nil
    local selectPrice = 0

    local function DIYUiCallback(layer, layerBgSprite, layerSize)
        local hint = ui.newLabel({
            text = currViewInfo.hint,
            color = cc.c3b(0x46, 0x22, 0x0d),
        })
        hint:setPosition(layerSize.width * 0.5, layerSize.height * 0.52)
        layerBgSprite:addChild(hint)

        local nowLabel = ui.newLabel({
            text = TR("当前%s:%d", ResourcetypeSubName[resourceTypeSub], PlayerAttrObj:getPlayerAttr(resourceTypeSub)),
            color = cc.c3b(0x46, 0x22, 0x0d),
        })
        nowLabel:setAnchorPoint(0, 0.5)
        nowLabel:setPosition(layerSize.width * 0.21, layerSize.height * 0.45)
        layerBgSprite:addChild(nowLabel)

        -- 重新设置提示信息的位置
        layer.mMsgLabel:setPosition(layerSize.width * 0.5, layerSize.height * 0.5)
        layer.mMsgLabel:setAnchorPoint(cc.p(0.5, 1))

        -- 物品卡牌
        local tempCard = CardNode.createCardNode({
            resourceTypeSub = ResourcetypeSub.eFunctionProps,
            modelId = currViewInfo.goodsModelId,
        })
        tempCard:setPosition(cc.p(layerSize.width * 0.5, layerSize.height * 0.72))
        layerBgSprite:addChild(tempCard)

        -- 需要消耗的元宝
        local tempNode
        tempNode, priceLable = ui.createDaibiView({
            resourceTypeSub = ResourcetypeSub.eDiamond,
            number = needCount,
            fontColor = cc.c3b(0x46, 0x22, 0x0d),
        })
        tempNode:setAnchorPoint(cc.p(0, 0.5))
        tempNode:setPosition(layerSize.width * 0.21, layerSize.height * 0.28)
        layerBgSprite:addChild(tempNode)

        -- 拥有数量
        local haveCard
        haveCard, haveLabel = ui.createDaibiView({
            resourceTypeSub = ResourcetypeSub.eFunctionProps,
            number = 0,
            goodsModelId = currViewInfo.goodsModelId,
            fontColor = cc.c3b(0x46, 0x22, 0x0d),
        })
        haveCard:setAnchorPoint(cc.p(0, 0.5))
        haveCard:setPosition(cc.p(layerSize.width * 0.64, layerSize.height * 0.28))
        layerBgSprite:addChild(haveCard)

        local function setLabelStr()
            nowLabel:setString(TR("当前%s:%d", ResourcetypeSubName[resourceTypeSub],
                PlayerAttrObj:getPlayerAttr(resourceTypeSub)))
        end
        -- 自动刷新注册
        local eventName = EventsName.getNameByResType(resourceTypeSub)
        if eventName then
            Notification:registerAutoObserver(nowLabel, setLabelStr, {eventName})
        end

        local function createSelectView()
            local maxCount
            if goodsCount <= 0 then
                maxCount = maxBuyNum - buyNum
                if maxBuyNum - buyNum == 0 then
                    maxCount = 1
                end
            else
                maxCount = goodsCount
            end
            tempSelectView = require("common.SelectCountView"):create({
                maxCount = maxCount,
                viewSize = cc.size(layerSize.width - 50, 200),
                changeCallback = function(count)
                    selectCount = count
                    selectPrice = 0
                    if goodsCount <= 0 then
                        for i = buyNum+1, buyNum+selectCount do
                            local curIndexPrice = priceListInfo[i] and priceListInfo[i].NewPrice or priceListInfo[#priceListInfo].NewPrice
                            selectPrice = selectPrice + curIndexPrice
                        end
                        priceLable:setString(selectPrice)
                    end
                end
            })
            tempSelectView:setPosition(layerSize.width / 2, layerSize.height * 0.37)
            layerBgSprite:addChild(tempSelectView)
        end

        -- 请求购买信息
        HttpClient:request({
            svrType = HttpSvrType.eGame,
            moduleName = "ShopGoods",
            methodName = "GetShopGoodsInfo",
            svrMethodData = {currViewInfo.goodsModelId},
            callbackNode = layer,
            callback = function(response)
                if not response or response.Status ~= 0 then
                    return
                end
                price = response.Value[1].CurrPrice
                buyNum = response.Value[1].Num
                maxBuyNum = response.Value[1].MaxNum
                priceListInfo = response.Value[1].DynamicPrice

                local tempCount = GoodsObj:getCountByModelId(currViewInfo.goodsModelId)
                haveLabel:setString(string.format(TR("%d"), tempCount))
                priceLable:setString(tostring(price))

                createSelectView()
            end,
        })

        local buyBtn = ui.newButton({
            text = TR("使用"),
            normalImage = "c_28.png",
            clickAction = function ()
                local goodsCount = GoodsObj:getCountByModelId(currViewInfo.goodsModelId or 0)
                if goodsCount < selectCount then
                    ui.showFlashView(TR("数量不足！"))
                    return
                end
                local goodsItem = GoodsObj:findByModelId(currViewInfo.goodsModelId)[1]
                HttpClient:request({
                    svrType = HttpSvrType.eGame,
                    moduleName = "Goods",
                    methodName = "GoodsUse",
                    svrMethodData = {goodsItem.Id, goodsItem.ModelId, selectCount},
                    callbackNode = msgLayer,
                    callback = function(response)
                        if not response or response.Status ~= 0 then
                            return
                        end

                        ui.showFlashView(TR("使用成功"))
                        -- local tempCount = GoodsObj:getCountByModelId(currViewInfo.goodsModelId)
                        -- haveLabel:setString(string.format(TR("%d"), tempCount))
                        -- priceLable:setString(tostring(price))

                        if callback then 
                            callback()
                        end     
                        LayerManager.removeLayer(layer)
                    end,
                })
            end
        })
        buyBtn:setPosition(layerSize.width / 2, 60)
        layerBgSprite:addChild(buyBtn)

        if goodsCount <= 0 then
            buyBtn:setTitleText(TR("购买"))
            buyBtn:setClickAction(function()
                local playerInfo = PlayerAttrObj:getPlayerInfo()
                local vipLimitModel = VipBuyLimitModel.items[playerInfo.Vip][1603][currViewInfo.goodsModelId]  -- Todo 这个表是不是该优化一下
                -- 达到当日购买次数上限
                if vipLimitModel and vipLimitModel.buyMaxNum and buyNum+selectCount > vipLimitModel.buyMaxNum then
                    ui.showFlashView(TR("今天购买数量已达到上限，请明日再来！"))
                    return
                end
                -- 元宝不足
                if not Utility.isResourceEnough(ResourcetypeSub.eDiamond, selectPrice) then
                    return
                end

                HttpClient:request({
                    svrType = HttpSvrType.eGame,
                    moduleName = "ShopGoods",
                    methodName = "BuyGoods",
                    svrMethodData = {currViewInfo.goodsModelId, selectCount},
                    callbackNode = msgLayer,
                    callback = function(response)
                        if not response or response.Status ~= 0 then
                            return
                        end
                        -- buyNum = response.Value.Num
                        -- price = response.Value.CurrPrice

                        ui.showFlashView(TR("购买成功"))
                        -- local tempCount = GoodsObj:getCountByModelId(currViewInfo.goodsModelId)
                        -- haveLabel:setString(string.format(TR("%d"), tempCount))
                        -- priceLable:setString(tostring(price))

                        LayerManager.removeLayer(layer)
                    end,
                })
                -- tempSelectView.mSelCountLabel:setString(1)
                -- tempSelectView.mCurrSelCount = 1
                -- selectCount = 1
                -- selectPrice = price
            end)
        end
    end

    local tempData = {
        bgSize = cc.size(572, 460),
        title = currViewInfo.title or TR("提示"),
        -- msgText = currViewInfo.hint,
        btnInfos = {},
        closeBtnInfo = callback and {clickAction = callback} or {},
        DIYUiCallback = DIYUiCallback,
    }
    msgLayer = LayerManager.addLayer({name = "commonLayer.MsgBoxLayer", data = tempData, cleanUp = false})

    return msgLayer
end

-- 扩展背包到提示
--[[
-- 参数
    bagType: 背包到类型，在 EnumsConfig.lua 文件的 BagType 中定义
    callback: 扩展成功后的回调  callback(layerObj)
]]
function MsgBoxLayer.addExpandBagLayer(bagType, callback)
    -- 自定义显示控件
    local function DIYFuncion(layer, layerBgSprite, layerSize)
        -- 拥有元宝数量显示
        local diamondImg = Utility.getDaibiImage(ResourcetypeSub.eDiamond)
        -- local tempLabel = ui.newLabel{
        --     text = TR("拥有:{%s}%s%d" , diamondImg, Enums.Color.eWineRedH, diamondCount),
        --     color = cc.c3b(0x46, 0x22, 0x0d),
        -- }
        -- tempLabel:setPosition(layerSize.width * 0.15, layerSize.height - 120)
        -- tempLabel:setAnchorPoint(cc.p(0, 0.5))
        -- layerBgSprite:addChild(tempLabel)
        local boxNum = 5

        -- 消耗元宝扩展背包的提示
        local tempModel = BagModel.items[bagType]
        local curExpandTimes = BagInfoObj:getBagInfo(bagType).ExpandNum
        local maxExpand = BagExpandUseRelation.items_count
        local canExpandTimes = maxExpand - curExpandTimes
        local tempLabel = ui.newLabel{
            text = tempStr,
            color = cc.c3b(0x46, 0x22, 0x0d),
            align = cc.TEXT_ALIGNMENT_LEFT,
            valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
            dimensions = cc.size(layerSize.width * 0.7, 200)
        }
        tempLabel:setPosition(layerSize.width * 0.15, layerSize.height - 100)
        tempLabel:setAnchorPoint(cc.p(0, 1))
        layerBgSprite:addChild(tempLabel)

        local tempSprite = ui.newScale9Sprite("c_24.png",cc.size(100, 32))
        tempSprite:setPosition(layerSize.width * 0.5, layerSize.height * 0.42)
        layerBgSprite:addChild(tempSprite)

        local numLabel = ui.newLabel({
                text = "",
                size = 20,
                color = Enums.Color.eYellow,
            })
        numLabel:setPosition(layerSize.width * 0.5, layerSize.height * 0.42)
        layerBgSprite:addChild(numLabel)

        local function refreshExpanNum()
            if curExpandTimes >= maxExpand then
                tempLabel:setString(TR("背包已经扩展到最大了"))
                tempLabel:setPosition(layerSize.width * 0.3, layerSize.height - 100)
                numLabel:setString(5)

                layer.isMaxExpan = true
            else
                local price = 0
            local tempTimes = math.ceil(boxNum / 5)
            local start = curExpandTimes + 1
            local endP = curExpandTimes + tempTimes
            for i = curExpandTimes + 1, curExpandTimes + tempTimes do
                price = price + BagExpandUseRelation.items[i].useDiamondNum
            end
            numLabel:setString(boxNum)
            tempLabel:setString(TR("你确定要花费%s%d{%s}%s增加%s%d%s个%s背包位置吗?",
            Enums.Color.eWineRedH, price, diamondImg, "#46220D",
            Enums.Color.eWineRedH,
            boxNum, "#46220D",
            tempModel.name))
            layer.number = tempTimes
            layer.isMaxExpan = false
            layer.price = price
            end
        end

        local addBtn = ui.newButton({
            normalImage = "bg_05.png",
            text = "+5",
            -- fontSize = 18,
            clickAction = function ()
                boxNum = boxNum + 5
                if boxNum > canExpandTimes*5 then
                    boxNum = canExpandTimes*5
                end
                refreshExpanNum()
            end
            })
        addBtn:setPosition(layerSize.width * 0.70, layerSize.height * 0.42)
        layerBgSprite:addChild(addBtn)

        local subBtn = ui.newButton({
            normalImage = "bg_05.png",
            text = "-5",
            clickAction = function ()
                boxNum = boxNum - 5
                if boxNum < 5 then
                    boxNum = 5
                end
                refreshExpanNum()
            end
            })
        subBtn:setPosition(layerSize.width * 0.30, layerSize.height * 0.42)
        layerBgSprite:addChild(subBtn)

        refreshExpanNum()
    end

    -- 背包扩展的网络请求
    local function requestBagExpand(layerObj, btnObj)
        if layerObj.isMaxExpan then
            ui.showFlashView(TR("背包已经扩展到最大了"))
            LayerManager.removeLayer(layerObj)
            return
        end
        local diamondCount = PlayerAttrObj:getPlayerAttr(ResourcetypeSub.eDiamond)
        if diamondCount < layerObj.price then
            MsgBoxLayer.addGetDiamondHintLayer()
            return
        end
        HttpClient:request({
            svrType = HttpSvrType.eGame,
            moduleName = "Bag",
            methodName = "BagExpand",
            svrMethodData = {bagType, layerObj.number},
            callback = function(response)
                if not response or response.Status ~= 0 then
                    return
                end
                BagInfoObj:modifyBagInfo(response.Value)

                ui.showFlashView(TR("背包扩展成功"))
                LayerManager.removeLayer(layerObj)
                if callback then
                    callback(layerObj)
                end
            end,
        })
    end

    local tempData = {
        title = TR("背包扩展"),
        btnInfos = {
            {
                normalImage = "c_33.png",
                text = TR("扩充"),
                clickAction = function(layerObj, btnObj)
                    requestBagExpand(layerObj, btnObj)
                end
            },
            -- {text = TR("取消"),},
        },
        closeBtnInfo = {},
        DIYUiCallback = DIYFuncion,
    }
    LayerManager.addLayer({name = "commonLayer.MsgBoxLayer", data = tempData, cleanUp = false})
    return retLayer
end

----------------------------------------------------------------------------------------------------

-- 规则提示框
--[[
-- 参数
    title：提示窗体的标题，默认为：TR("规则")
    contentList: 规则类容列表，格式如下
        {
            [1] = TR("规则1"),
            [2] = TR("规则2")
        }
    bgSize: (可选参数)背景框的大小，默认为：cc.size(572, 420)
]]
function MsgBoxLayer.addRuleHintLayer(title, contentList, bgSize, closeBtnInfo, btnInfos)
    -- 规则窗体的 DIY 函数
    local function DIYFuncion(layer, layerBgSprite, layerSize)
        -- 滑动控件
        local listSize = cc.size(layerSize.width-120, layerSize.height-180)
        local listView = ccui.ListView:create()
        listView:setItemsMargin(5)
        listView:setDirection(ccui.ListViewDirection.vertical)
        listView:setBounceEnabled(true)
        listView:setAnchorPoint(cc.p(0.5, 0.5))
        listView:setPosition(layerSize.width / 2, layerSize.height*0.52)
        layerBgSprite:addChild(listView)

        local maxHeight = 0
        for index, item in ipairs(contentList or {}) do
            local lvItem = ccui.Layout:create()
            local tempLabel = ui.newLabel({
                text = item,
                color = cc.c3b(0x46, 0x22, 0x0d),
                dimensions = cc.size(listSize.width, 0)
            })
            tempLabel:setAnchorPoint(cc.p(0, 0.5))
            local cellSize = tempLabel:getContentSize()
            tempLabel:setPosition(0, cellSize.height / 2)
            lvItem:addChild(tempLabel)

            lvItem:setContentSize(cellSize)
            listView:pushBackCustomItem(lvItem)

            maxHeight = maxHeight + cellSize.height + 5
        end

        if maxHeight < listSize.height then
            listView:setTouchEnabled(false)
        end
        listView:setContentSize(cc.size(listSize.width, math.min(maxHeight, listSize.height)))
    end

    local tempData = {
        bgSize = bgSize or cc.size(572, 420),
        title = title or TR("规则"),
        closeBtnInfo = closeBtnInfo or {},
        btnInfos = btnInfos or {{text = TR("确定"),}},
        DIYUiCallback = DIYFuncion,
    }

    return LayerManager.addLayer({
        name = "commonLayer.MsgBoxLayer",
        data = tempData,
        cleanUp = false,
    })
end

-- 显示多页签规则提示框
--[[
-- 参数
    title：提示窗体的标题，默认为：TR("规则")
    contentList: 内容列表，格式如下 
        [1] = { 
            tabName = TR("规则")
            list = {
                [1] = TR("规则1"),
                [2] = TR("规则2")
                ...  
            },
        [2] = { 
            tabName = TR("概率")
            list = {
                [1] = {
                    {customCb = function () end},
                    {customCb = function () end},
                    {customCb = function () end},
                },
                [2] = TR("规则2")
                ...  
            },
        },
        ...
        },
    bgSize: (可选参数)背景框的大小，默认为：cc.size(572, 620)
]]
function MsgBoxLayer.addTabTextLayer(title, contentList, bgSize)
    if (not contentList) or (not next(contentList)) then
        return
    end

    local tabList = {}
    for i, content in ipairs(contentList) do
        local tempItem = {}
        tempItem.text = content.tabName
        tempItem.tag = i

        table.insert(tabList, tempItem)
    end

    if #tabList > 1 then
        -- 规则窗体的 DIY 函数
        local function DIYFuncion(layer, layerBgSprite, layerSize)
            -- 黑背景
            local blackBg = ui.newScale9Sprite("c_17.png", cc.size(layerSize.width*0.9, layerSize.height-220))
            blackBg:setAnchorPoint(cc.p(0.5, 1))
            blackBg:setPosition(layerSize.width*0.5, layerSize.height-120)
            layerBgSprite:addChild(blackBg)
            -- 滑动控件
            local listSize = cc.size(layerSize.width-120, layerSize.height-240)
            local listView = ccui.ListView:create()
            listView:setItemsMargin(5)
            listView:setDirection(ccui.ListViewDirection.vertical)
            listView:setBounceEnabled(true)
            listView:setAnchorPoint(cc.p(0.5, 1))
            listView:setContentSize(listSize)
            listView:setPosition(layerSize.width / 2, layerSize.height-130)
            layerBgSprite:addChild(listView)

            local function refreshListView(tag)
                listView:removeAllChildren()
                local textList = contentList[tag].list

                local maxHeight = 0
                for index, item in ipairs(textList or {}) do
                    local tempLabel = nil
                    print("type(item)", type(item))
                    if type(item) == type({}) then
                        tempLabel = ui.newLabel({
                            text = "",
                        })
                        tempLabel:setContent(item)
                    else
                        tempLabel = ui.newLabel({
                            text = item,
                            color = cc.c3b(0x46, 0x22, 0x0d),
                            dimensions = cc.size(listSize.width, 0)
                        })
                    end
                    local lvItem = ccui.Layout:create()
                    tempLabel:setAnchorPoint(cc.p(0, 0.5))
                    local cellSize = tempLabel:getContentSize()
                    tempLabel:setPosition(0, cellSize.height / 2)
                    lvItem:addChild(tempLabel)

                    lvItem:setContentSize(cellSize)
                    listView:pushBackCustomItem(lvItem)

                    maxHeight = maxHeight + cellSize.height + 5
                end

                if maxHeight < listSize.height then
                    listView:setTouchEnabled(false)
                else
                    listView:setTouchEnabled(true)
                end
            end

            local subPageType = 1
            local tabView = ui.newTabLayer({
                btnInfos = tabList,
                needLine = false,
                defaultSelectTag = subPageType,
                viewSize = cc.size(layerSize.width-20, 80),
                allowChangeCallback = function(btnTag)
                    return true
                end,
                onSelectChange = function(selectBtnTag)
                    if subPageType == selectBtnTag then
                        return
                    end

                    subPageType = selectBtnTag
                    -- 刷新列表
                    refreshListView(selectBtnTag)
                end
            })
            tabView:setAnchorPoint(cc.p(0, 0))
            tabView:setPosition(cc.p(20, layerSize.height-130))
            layerBgSprite:addChild(tabView)
            refreshListView(subPageType)
        end

        local tempData = {
            bgSize = bgSize or cc.size(572, 500),
            title = title or TR("规则"),
            notNeedBlack = true,
            closeBtnInfo = closeBtnInfo or {},
            btnInfos = btnInfos or {{text = TR("确定"),}},
            DIYUiCallback = DIYFuncion,
        }

        return LayerManager.addLayer({
            name = "commonLayer.MsgBoxLayer",
            data = tempData,
            cleanUp = false,
        })
    else
        return MsgBoxLayer.addRuleHintLayer(title, contentList[1].list, bgSize)
    end
end

-- 新年活动规则提示框特殊处理
--[[
-- 参数
    title：提示窗体的标题，默认为：TR("规则")
    contentList: 规则类容列表，格式如下
        {
            [1] = TR("规则1"),
            [2] = TR("规则2")
        }
    bgSize: (可选参数)背景框的大小，默认为：cc.size(572, 420)
]]
function MsgBoxLayer.addXinNianRuleHintLayer(title, contentList, bgSize, closeBtnInfo, btnInfos)
    -- 规则窗体的 DIY 函数
    local function DIYFuncion(layer, layerBgSprite, layerSize)
        -- 滑动控件
        local listSize = cc.size(layerSize.width * 0.75, layerSize.height*0.6)
        local listView = ccui.ListView:create()
        listView:setItemsMargin(5)
        listView:setDirection(ccui.ListViewDirection.vertical)
        listView:setBounceEnabled(true)
        listView:setAnchorPoint(cc.p(0.5, 0.5))
        listView:setPosition(layerSize.width / 2, layerSize.height*0.5)
        layerBgSprite:addChild(listView)

        local maxHeight = 0
        for index, item in ipairs(contentList or {}) do
            local lvItem = ccui.Layout:create()
            local tempLabel = ui.newLabel({
                text = item,
                color = cc.c3b(0x46, 0x22, 0x0d),
                dimensions = cc.size(listSize.width, 0)
            })
            tempLabel:setAnchorPoint(cc.p(0, 0.5))
            local cellSize = tempLabel:getContentSize()
            tempLabel:setPosition(0, cellSize.height / 2)
            lvItem:addChild(tempLabel)

            lvItem:setContentSize(cellSize)
            listView:pushBackCustomItem(lvItem)

            maxHeight = maxHeight + cellSize.height + 5
        end

        if maxHeight < listSize.height then
            listView:setTouchEnabled(false)
        end
        listView:setContentSize(cc.size(listSize.width, math.min(maxHeight, listSize.height)))
    end

    local tempData = {
        bgImage = "xn_72.png",
        bgSize = bgSize or cc.size(579, 221),
        title = title or TR("规则"),
        closeBtnInfo = closeBtnInfo or {},
        btnInfos = {},
        DIYUiCallback = DIYFuncion,
        notNeedBlack = true,
        isNoShowTitle = true,
    }

    return LayerManager.addLayer({
        name = "commonLayer.MsgBoxLayer",
        data = tempData,
        cleanUp = false,
    })
end

-- 显示概率弹窗页面(如果需要显示规则也可以加)
--[[
-- 参数
    title：提示窗体的标题，默认为：TR("概率详情")
    contentList: 内容列表，格式如下 
        [1] = { -- 物品概率(必传)
            [1] = {
                resourceTypeSub = 1111, -- 资源子类型，相关枚举在 EnumsConfig.lua文件的 ResourcetypeSub 中定义。
                modelId = 0, -- 模型Id，如果是玩家属性资源，模型Id为0
                num = 1,  -- 数量默认1
                OddsTips = 0, -- 概率默认是0（统一用百分数:50%就传50）
            }  
            ...  
        },
        [2] = { --规则（可不传）
            [1] = TR("规则1"),
            [2] = TR("规则2")
            ...
        },
    bgSize: (可选参数)背景框的大小，默认为：cc.size(572, 620)
]]
function MsgBoxLayer.addprobabilityLayer(title, contentList, bgSize, closeBtnInfo, btnInfos)
    -- 概率详情窗体的 DIY 函数
    local function DIYFuncion(layer, layerBgSprite, layerSize)
        local blackHeight = #contentList <= 1 and (layerSize.height-170) or (layerSize.height-220)
        local subPageType = 1
        -- 黑色背景框
        local blackSize = cc.size(layerSize.width*0.9, blackHeight)
        local blackBg = ui.newScale9Sprite("c_17.png", blackSize)
        blackBg:setAnchorPoint(0.5, 0)
        blackBg:setPosition(layerSize.width/2, 100)
        layerBgSprite:addChild(blackBg)

        -- 滑动控件
        local listSize = cc.size(layerSize.width * 0.85, blackHeight-15)
        local listView = ccui.ListView:create()
        listView:setItemsMargin(5)
        listView:setDirection(ccui.ListViewDirection.vertical)
        listView:setBounceEnabled(true)
        listView:setContentSize(listSize)
        listView:setAnchorPoint(cc.p(0.5, 0))
        listView:setPosition(layerSize.width / 2, 105)
        layerBgSprite:addChild(listView)
        -- 创建概率单个cell
        local function addProElementsToCell(cell, item)
            local cellBgSprite = ui.newScale9Sprite("c_18.png", cc.size(listSize.width, 120))
            cellBgSprite:setPosition(listSize.width * 0.5, 60)
            local cellSize = cellBgSprite:getContentSize()
            cell:setContentSize(cellSize)
            cell:addChild(cellBgSprite)
            local tempLabel = ui.newLabel({
                text = TR("掉落概率：%s%%",item.OddsTips),
                color = cc.c3b(0x46, 0x22, 0x0d),
            })
            tempLabel:setAnchorPoint(0, 0.5)
            tempLabel:setPosition(185, cellSize.height/2)
            cellBgSprite:addChild(tempLabel)

            local tempCard = nil
            if item.header and header ~= "" then 
                tempCard = ui.newSprite(item.header)
            else 
                tempCard = CardNode.createCardNode({
                    resourceTypeSub = item.resourceTypeSub,
                    modelId = item.modelId,
                    num = item.num or 1,
                    cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum, CardShowAttr.eName},
                })
            end   
            if tempCard ~= nil then 
                tempCard:setAnchorPoint(cc.p(0, 0.5))
                tempCard:setScale(0.8)
                tempCard:setPosition(20, cellSize.height/2+10)
                cellBgSprite:addChild(tempCard)  
            end 
        end

        local function addRuleElementsToCell(cell, item)
            local tempLabel = ui.newLabel({
                text = item,
                color = cc.c3b(0x46, 0x22, 0x0d),
                dimensions = cc.size(listSize.width, 0)
            })
            tempLabel:setAnchorPoint(cc.p(0, 0.5))
            local cellSize = tempLabel:getContentSize()
            tempLabel:setPosition(0, cellSize.height / 2)
            cell:setContentSize(cellSize)
            cell:addChild(tempLabel)
        end

        -- 显示内容
        local function showContent(index)
            listView:removeAllItems()
            local viewInfos = contentList[index] or {}
             for _, item in ipairs(viewInfos) do
                local customCell = ccui.Layout:create()
                if index == 1 then 
                    addProElementsToCell(customCell, item)
                else 
                    addRuleElementsToCell(customCell, item)
                end 
                listView:pushBackCustomItem(customCell)
            end
        end 
        -- 创建分页
        local function createTabLayer()
            local buttonInfos = {}
            for i,v in ipairs(contentList) do
                table.insert(buttonInfos, {
                    text = i==1 and TR("概率") or TR("规则"),
                    tag = i,
                    position = cc.p(i==1 and 130 or 250, (layerSize.height-170))
                })
            end
            -- -- 创建分页
            local tabLayer = ui.newTabLayer({
                btnInfos = buttonInfos,
                needLine = false,
                defaultSelectTag = subPageType,
                allowChangeCallback = function(btnTag)
                    return true
                end,
                onSelectChange = function(selectBtnTag)
                    if subPageType == selectBtnTag then
                        return
                    end

                    subPageType = selectBtnTag
                    -- 切换子页面
                    showContent(subPageType)
                end
            })
            tabLayer:setAnchorPoint(0.5, 1)
            tabLayer:setPosition(cc.p(layerSize.width*0.5, (layerSize.height-48)))
            layerBgSprite:addChild(tabLayer)
        end
        
        if #contentList > 1 then 
            -- 先创建一个默认的页面
            showContent(subPageType)
            -- 创建分页
            createTabLayer()
        else 
            -- 说明只需要展示概率
            showContent(subPageType)    
        end   
        
    end

    local tempData = {
        bgSize = bgSize or cc.size(572, 620),
        title = title or TR("概率详情"),
        closeBtnInfo = closeBtnInfo or {},
        btnInfos = btnInfos or {{text = TR("确定"),}},
        DIYUiCallback = DIYFuncion,
        notNeedBlack = true,
    }

    return LayerManager.addLayer({
        name = "commonLayer.MsgBoxLayer",
        data = tempData,
        cleanUp = false,
    })
end

-- 显示长文本内容提示框
function MsgBoxLayer.addLongTextLayer(longText, title, bgSize)
    -- 规则窗体的 DIY 函数
    local function DIYFuncion(layer, layerBgSprite, layerSize)
        -- 滑动控件
        local viewSize = cc.size(layerSize.width - 15, layerSize.height - 160)
        local tempView = ccui.ScrollView:create()
        tempView:setContentSize(viewSize)
        tempView:setDirection(ccui.ScrollViewDir.vertical)
        tempView:setAnchorPoint(cc.p(0, 0))
        tempView:setPosition((layerSize.width - viewSize.width) / 2, 95)
        layerBgSprite:addChild(tempView)

        local tempLabel = ui.newLabel({
            text = longText or "",
            color = cc.c3b(0x46, 0x22, 0x0d),
            align = ui.TEXT_ALIGN_CENTER,
            dimensions = cc.size(viewSize.width - 80, 0)
        })
        tempLabel:setAnchorPoint(cc.p(0.5, 0.5))
        local innerlSize = cc.size(viewSize.width, math.max(viewSize.height, tempLabel:getContentSize().height))
        tempView:setInnerContainerSize(innerlSize)
        tempLabel:setPosition(innerlSize.width / 2, innerlSize.height / 2)
        tempView:addChild(tempLabel)
    end

    local tempData = {
        bgSize = bgSize or cc.size(572, 800),
        title = title ~= "" and title or TR("提示"),
        closeBtnInfo = {},
        btnInfos = {{text = TR("确定"),}},
        DIYUiCallback = DIYFuncion,
    }

    return LayerManager.addLayer({
        name = "commonLayer.MsgBoxLayer",
        data = tempData,
        cleanUp = false,
    })
end

-- 重置普通副本节点的提示
--[[
-- 参数
    resetFightCount: 已重置的次数
    callback: 重置完成后的回调 callback(battleFightUse)
]]
function MsgBoxLayer.resetNodeHintLayer(resetFightCount, callback)
    resetFightCount = resetFightCount or 0
    -- 挑战次数是否足够
    local resetUseItem = BattleResetUseRelation.items[resetFightCount + 1]
    if not resetUseItem then
        ui.showFlashView(TR("今天的重置次数已达到上限！"))
        return
    end

    local useDiamond = true
    local hintStr = TR("副本挑战次数不足，是否花费%s%d元宝%s重置副本？", Enums.Color.eGreenH, resetUseItem.nodeUseDiamond, Enums.Color.eNormalWhiteH)
    local resdata = Utility.analysisStrResList(resetUseItem.nodeUseResource)
    if resdata and #resdata > 0 then
        local tempItem = resdata[1]
        local freeCount = Utility.getOwnedGoodsCount(tempItem.resourceTypeSub, tempItem.modelId, true)
        if freeCount >= tempItem.num then
            hintStr = TR("副本挑战次数不足，是否花费%s%d个重置符%s重置副本？当前拥有副本重置符:%s%d", Enums.Color.eGreenH, tempItem.num, Enums.Color.eNormalWhiteH, Enums.Color.eGreenH, freeCount)
            useDiamond = false
        end
    end

    --提示框
    local okBtnInfo = {
        text = TR("确定"),
        clickAction = function(layerObj, btnObj)
            LayerManager.removeLayer(layerObj)

            if useDiamond then
                if not Utility.isResourceEnough(ResourcetypeSub.eDiamond, resetUseItem.nodeUseDiamond) then
                    return
                end
            end

            if callback then
                callback(useDiamond and Enums.BattleFightUse.eUseDiamond or Enums.BattleFightUse.eUseGoods)
            end
        end
    }
    local cencelInfo = {
        text = TR("取消"),
        clickAction = function(layerObj, btnObj)
            LayerManager.removeLayer(layerObj)
        end
    }
    MsgBoxLayer.addOKLayer(hintStr, TR("提示"), {okBtnInfo, cencelInfo})
end

-- 购买挑战妖王次数提示
--[[
-- 参数
    oldBuyCount: 已经购买次数
    maxCount: 最大购买次数
    callback: 确定后的回调函数
]]
function MsgBoxLayer.buyBossCountHintLayer(oldBuyCount, maxCount, callback)
    -- 购买次数
    local buyCount = 1
    local price = 0
    -- 购买次数弹窗DIY函数
    local function buyBoxDIYFunc(layer, layerBgSprite, layerSize)
        local tempHeight = 400
        layer:getMsgLabel():setPosition(layerSize.width / 2, tempHeight - 100)

        -- 数量选中框到背景
        local tempSize = cc.size(layerSize.width - 30, 200)
        local tempSprite = ui.newScale9Sprite("c_83.png", tempSize)
        tempSprite:setAnchorPoint(cc.p(0.5, 1))
        tempSprite:setPosition(layerSize.width / 2, tempHeight - 120)
        layerBgSprite:addChild(tempSprite)

        -- 选择数量提示文字
        local tempLabel = ui.newLabel({
            text = TR("请选择需要购买的挑战次数"),
            color = cc.c3b(0x46, 0x22, 0x0d)
        })
        tempLabel:setAnchorPoint(cc.p(0.5, 0.5))
        tempLabel:setPosition(tempSize.width / 2, tempSize.height - 40)
        tempSprite:addChild(tempLabel)
        -- 购买的价格
        local priceLabel = ui.newLabel({
            text = TR("价格:"),
            color = cc.c3b(0x46, 0x22, 0x0d)
        })
        priceLabel:setAnchorPoint(cc.p(1, 0.5))
        priceLabel:setPosition(tempSize.width / 2, 45)
        tempSprite:addChild(priceLabel)
        --
        local priceNode = ui.createDaibiView({
            resourceTypeSub = ResourcetypeSub.eDiamond,
            number = 10,
            fontColor = cc.c3b(0xd1, 0x7b, 0x00),
        })
        priceNode:setAnchorPoint(cc.p(0, 0.5))
        priceNode:setPosition(tempSize.width / 2, 45)
        tempSprite:addChild(priceNode)

        -- 数量选择控件
        local buyAttackNumBaseUseNum = LuckbossConfig.items[1].buyAttackNumBaseUseNum
        local tempView = require("common.SelectCountView"):create({
            maxCount = maxCount,
            viewSize = cc.size(tempSize.width, 200),
            changeCallback = function(count)
                buyCount = count

                local totalPrice = 0
                for i = oldBuyCount + 1, oldBuyCount + count do
                    totalPrice = totalPrice + (math.ceil(i / 2) * buyAttackNumBaseUseNum)
                end
                priceNode.setNumber(totalPrice)
                price = totalPrice
            end
        })
        tempView:setPosition(tempSize.width / 2, 100)
        tempSprite:addChild(tempView)
    end

    -- 购买按钮信息
    local okBtnInfo = {
        normalImage = "c_28.png",
        text = TR("购买"),
        clickAction = function(layerObj, btnObj)
            LayerManager.removeLayer(layerObj)
            if Utility.isResourceEnough(ResourcetypeSub.eDiamond, price) then
                if callback then
                    callback(buyCount)
                end
            end
        end
    }

    MsgBoxLayer.addDIYLayer({
        bgSize = cc.size(572, 400),
        msgText = TR("花费元宝进行购买行侠仗义挑战次数"),
        title = TR("购买次数"),
        btnInfos = {okBtnInfo},
        closeBtnInfo = {},
        DIYUiCallback = buyBoxDIYFunc,
    })
end

-- 购买武林大会次数提示
--[[
-- 参数
    oldBuyCount: 已经购买次数
    maxCount: 最大购买次数
    callback: 确定后的回调函数
]]
function MsgBoxLayer.buyGDDHCountHintLayer(oldBuyCount, maxCount, callback)
    -- 购买次数
    local buyCount = 1
    local price = 0
    -- 购买次数弹窗DIY函数
    local function buyBoxDIYFunc(layer, layerBgSprite, layerSize)
        local tempHeight = 400
        layer:getMsgLabel():setPosition(layerSize.width / 2, tempHeight - 130)

        -- 数量选中框到背景
        local tempSize = cc.size(layerSize.width - 60, 140)
        local tempSprite = ui.newScale9Sprite("c_17.png", tempSize)
        tempSprite:setAnchorPoint(cc.p(0.5, 1))
        tempSprite:setPosition(layerSize.width / 2, tempHeight - 170)
        layerBgSprite:addChild(tempSprite)

        -- 选择数量提示文字
        -- local tempLabel = ui.newLabel({
        --     text = TR("请选择需要购买的挑战次数"),
        --     color = cc.c3b(0x46, 0x22, 0x0d)
        -- })
        -- tempLabel:setAnchorPoint(cc.p(0.5, 0.5))
        -- tempLabel:setPosition(tempSize.width / 2, tempSize.height - 40)
        -- tempSprite:addChild(tempLabel)
        -- 购买的价格
        local priceLabel = ui.newLabel({
            text = TR("价格:"),
            color = cc.c3b(0x46, 0x22, 0x0d)
        })
        priceLabel:setAnchorPoint(cc.p(1, 0.5))
        priceLabel:setPosition(tempSize.width / 2, 105)
        tempSprite:addChild(priceLabel)
        --
        local priceNode = ui.createDaibiView({
            resourceTypeSub = ResourcetypeSub.eDiamond,
            number = 10,
            fontColor = Enums.Color.eNormalGreen,
        })
        priceNode:setAnchorPoint(cc.p(0, 0.5))
        priceNode:setPosition(tempSize.width / 2, 105)
        tempSprite:addChild(priceNode)

        -- 数量选择控件
        local tempView = require("common.SelectCountView"):create({
            maxCount = maxCount - oldBuyCount,
            viewSize = cc.size(tempSize.width, 200),
            changeCallback = function(count)
                buyCount = count

                local totalPrice = 0
                for i = oldBuyCount + 1, oldBuyCount + count do
                    totalPrice = totalPrice + GddhBuynumRelation.items[i].price
                end
                priceNode.setNumber(totalPrice)
                price = totalPrice
            end
        })
        tempView:setPosition(tempSize.width / 2, 50)
        tempSprite:addChild(tempView)
    end

    -- 购买按钮信息
    local okBtnInfo = {
        normalImage = "c_28.png",
        text = TR("购买"),
        clickAction = function(layerObj, btnObj)
            LayerManager.removeLayer(layerObj)
            if Utility.isResourceEnough(ResourcetypeSub.eDiamond, price) then
                if callback then
                    callback(buyCount)
                end
            end
        end
    }

    MsgBoxLayer.addDIYLayer({
        bgSize = cc.size(572, 360),
        msgText = TR("武林大会挑战次数购买"),
        title = TR("购买次数"),
        btnInfos = {okBtnInfo},
        closeBtnInfo = {},
        DIYUiCallback = buyBoxDIYFunc,
        notNeedBlack = true,
    })
end

-- 购买珍兽精英挑战次数提示
--[[
-- 参数
    oldBuyCount: 已经购买次数
    maxCount: 最大购买次数
    callback: 确定后的回调函数
]]
function MsgBoxLayer.buyZslyCountHintLayer(oldBuyCount, maxCount, callback)
    -- 购买次数
    local buyCount = 1
    local price = 0
    -- 购买次数弹窗DIY函数
    local function buyBoxDIYFunc(layer, layerBgSprite, layerSize)
        local tempHeight = 400
        layer:getMsgLabel():setPosition(layerSize.width / 2, tempHeight - 130)

        -- 数量选中框到背景
        local tempSize = cc.size(layerSize.width - 60, 140)
        local tempSprite = ui.newScale9Sprite("c_17.png", tempSize)
        tempSprite:setAnchorPoint(cc.p(0.5, 1))
        tempSprite:setPosition(layerSize.width / 2, tempHeight - 170)
        layerBgSprite:addChild(tempSprite)

        -- 购买的价格
        local priceLabel = ui.newLabel({
            text = TR("价格:"),
            color = cc.c3b(0x46, 0x22, 0x0d)
        })
        priceLabel:setAnchorPoint(cc.p(1, 0.5))
        priceLabel:setPosition(tempSize.width / 2, 105)
        tempSprite:addChild(priceLabel)
        --
        local priceNode = ui.createDaibiView({
            resourceTypeSub = ResourcetypeSub.eDiamond,
            number = 10,
            fontColor = Enums.Color.eNormalGreen,
        })
        priceNode:setAnchorPoint(cc.p(0, 0.5))
        priceNode:setPosition(tempSize.width / 2, 105)
        tempSprite:addChild(priceNode)

        -- 数量选择控件
        local tempView = require("common.SelectCountView"):create({
            maxCount = maxCount - oldBuyCount,
            viewSize = cc.size(tempSize.width, 200),
            changeCallback = function(count)
                buyCount = count

                local totalPrice = 0
                for i = oldBuyCount + 1, oldBuyCount + count do
                    local resInfo = Utility.analysisStrResList(ZslyEliteFightnumBuyModel.items[i].buyNeed)[1]
                    totalPrice = totalPrice + resInfo.num
                end
                priceNode.setNumber(totalPrice)
                price = totalPrice
            end
        })
        tempView:setPosition(tempSize.width / 2, 50)
        tempSprite:addChild(tempView)
    end

    -- 购买按钮信息
    local okBtnInfo = {
        normalImage = "c_28.png",
        text = TR("购买"),
        clickAction = function(layerObj, btnObj)
            LayerManager.removeLayer(layerObj)
            if Utility.isResourceEnough(ResourcetypeSub.eDiamond, price) then
                if callback then
                    callback(buyCount)
                end
            end
        end
    }

    MsgBoxLayer.addDIYLayer({
        bgSize = cc.size(572, 360),
        msgText = TR("精英挑战次数购买"),
        title = TR("购买次数"),
        btnInfos = {okBtnInfo},
        closeBtnInfo = {},
        DIYUiCallback = buyBoxDIYFunc,
        notNeedBlack = true,
    })
end

-- 购买江湖杀粮草精神提示
--[[
-- 参数
    oldBuyCount: 已经购买次数
    maxCount: 购买上限
    extraNum: 倍数
    attrName: 购买属性名字（精神，粮草，功力）
    callback: 确定后的回调函数
]]
function MsgBoxLayer.buyJHSCountHintLayer(oldBuyCount, maxCount, extraNum, attrName, callback)
    -- 购买次数
    local buyCount = 1
    local price = 0
    local daibiRes = Utility.analysisStrResList(JianghukilBuyRelation.items[1].buyNeed)[1]
    local allCount = VipModel.items[PlayerAttrObj:getPlayerAttrByName("Vip")].jianghukillBuyNum
    -- 购买次数弹窗DIY函数
    local function buyBoxDIYFunc(layer, layerBgSprite, layerSize)
        local tempHeight = 400
        layer:getMsgLabel():setPosition(layerSize.width / 2, tempHeight - 130)

        -- 数量选中框到背景
        local tempSize = cc.size(layerSize.width - 60, 160)
        local tempSprite = ui.newScale9Sprite("c_17.png", tempSize)
        tempSprite:setAnchorPoint(cc.p(0.5, 1))
        tempSprite:setPosition(layerSize.width / 2, tempHeight - 150)
        layerBgSprite:addChild(tempSprite)

        -- 购买的价格
        local priceLabel = ui.newLabel({
            text = TR("价格:"),
            color = cc.c3b(0x46, 0x22, 0x0d)
        })
        priceLabel:setAnchorPoint(cc.p(1, 0.5))
        priceLabel:setPosition(tempSize.width / 2, 125)
        tempSprite:addChild(priceLabel)
        --
        local priceNode = ui.createDaibiView({
            resourceTypeSub = daibiRes.resourceTypeSub,
            number = 10,
            fontColor = Enums.Color.eNormalGreen,
        })
        priceNode:setAnchorPoint(cc.p(0, 0.5))
        priceNode:setPosition(tempSize.width / 2, 125)
        tempSprite:addChild(priceNode)

        -- 剩余可购买次数
        local remainderLabel = ui.newLabel({
                text = TR("剩余可购买次数：#c0494b%d", allCount - oldBuyCount),
                color = cc.c3b(0x46, 0x22, 0x0d),
                size = 20,
            })
        remainderLabel:setAnchorPoint(cc.p(0, 0))
        remainderLabel:setPosition(10, 5)
        tempSprite:addChild(remainderLabel)

        -- 数量选择控件
        local tempView = require("common.SelectCountView"):create({
            maxCount = maxCount,
            viewSize = cc.size(tempSize.width, 200),
            extraNum = extraNum > 1 and extraNum or nil,
            changeCallback = function(count)
                buyCount = count

                local totalPrice = 0
                for i = oldBuyCount + 1, oldBuyCount + count do
                    local priceNum = Utility.analysisStrResList(JianghukilBuyRelation.items[i].buyNeed)[1].num
                    totalPrice = totalPrice + priceNum
                end
                priceNode.setNumber(totalPrice)
                price = totalPrice
            end
        })
        tempView:setPosition(tempSize.width / 2, 70)
        tempSprite:addChild(tempView)
    end

    -- 购买按钮信息
    local okBtnInfo = {
        normalImage = "c_28.png",
        text = TR("购买"),
        clickAction = function(layerObj, btnObj)
            LayerManager.removeLayer(layerObj)
            if Utility.isResourceEnough(ResourcetypeSub.eDiamond, price) then
                if callback then
                    callback(buyCount)
                end
            end
        end
    }

    MsgBoxLayer.addDIYLayer({
        bgSize = cc.size(572, 360),
        msgText = TR("江湖杀%s购买", attrName),
        title = TR("购买%s", attrName),
        btnInfos = {okBtnInfo},
        closeBtnInfo = {},
        DIYUiCallback = buyBoxDIYFunc,
        notNeedBlack = true,
    })
end


-- 阵容卡槽未开启跳转仙脉模块的提示的提示
function MsgBoxLayer.gotoLightenStarHintLayer(slotId, isMate, formationObj)
    local tempObj = formationObj or FormationObj
    if tempObj:slotIsOpen(slotId, isMate) then -- 该卡槽已开启则不用提示
        return
    end
    local starCount = tempObj:getSlotOpenStar(slotId, isMate)
    local isVipOpen = isMate and tempObj:mateSlotIsVipOpen(slotId)
    if not tempObj:isMyself() or isVipOpen then  -- 其它玩家只需要飘窗提示
        if isVipOpen then
            local tempItem = VipSlotRelation.items[slotId]
            ui.showFlashView(TR("VIP%d开启", tempItem and tempItem.LV or 20))
        else
            ui.showFlashView(TR("拼酒达到%s次开启", starCount))
        end
        return
    end

    -- 如果是玩家自己，则需要挑战到仙脉的提示
    local whiteStr = Enums.Color.eNormalWhiteH
    local greenStr = Enums.Color.eNormalGreenH
    local tempStr = TR("%s拼酒%s达到%s%s%s后才能开启该卡槽,是否前往？", greenStr, whiteStr, greenStr, starCount, whiteStr)
    local okBtnInfo = {
        text = TR("前往"),
        clickAction = function(layerObj, btnObj)
            LayerManager.removeLayer(layerObj)
            LayerManager.showSubModule(ModuleSub.ePracticeLightenStar)
        end,
    }
    MsgBoxLayer.addOKLayer(tempStr, TR("提示"), {okBtnInfo}, {})
end

function MsgBoxLayer.conFightCountLayer(nodeId, callback)
    local fightCount = 0

    local function confightDIYFunc(layer, layerBgSprite, layerSize)
        local nodeModel = BattleNodeModel.items[nodeId]
        local nodeInfo = BattleObj:getNodeInfo(nodeModel.chapterModelID, nodeModel.ID)
        local nodeIdNum = math.ceil(nodeModel.ID % 100) - 10
        local nodeInfoLabel = ui.newLabel({
            text = TR("第%s章第%s小节 %s%s", (nodeModel.chapterModelID-10), nodeIdNum, "#d17b00", nodeModel.name),
            color = cc.c3b(0x44, 0x1f, 0x0a),
            size = 24,
            })
        nodeInfoLabel:setPosition(314, 395)
        layerBgSprite:addChild(nodeInfoLabel)

        --灰色底板
        local grayUnderBg = ui.newScale9Sprite("c_17.png", cc.size(578, 274))
        grayUnderBg:setPosition(314, 235)
        layerBgSprite:addChild(grayUnderBg)

        --掉落背景板
        local dropBgSize = cc.size(570, 198)
        local dropBgSprite = ui.newScale9Sprite("c_54.png", dropBgSize)
        dropBgSprite:setPosition(cc.p(314, 260))
        layerBgSprite:addChild(dropBgSprite)

        -- 显示标题
        local tempTitleLabel = ui.newLabel({
            text = TR("几率掉落"),
            size = 24,
            color = cc.c3b(0xfa, 0xf6, 0xf1),
            outlineColor = cc.c3b(0x8d, 0x4b, 0x3b),
            outlineSize = 2,
        })
        tempTitleLabel:setPosition(dropBgSize.width / 2, dropBgSize.height - 22)
        dropBgSprite:addChild(tempTitleLabel)

        -- 显示掉落列表
        local tempList = ConfigFunc:getBattleNodeDrop(nodeId)
        local propsList = {}
        for _, item in pairs(tempList) do   -- 去掉重复的
            local tempKey = item.modelId ~= 0 and item.modelId or item.resourceTypeSub
            propsList[tempKey] = item
        end

        -- 整理需要显示卡牌的数据
        local viewDataList = {}
        for _, item in pairs(propsList) do
            item.cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eName, CardShowAttr.eNum}
            table.insert(viewDataList, item)
        end

        table.sort(viewDataList, function(item1, item2)
            local colorLv1 = Utility.getColorLvByModelId(item1.modelId, item1.resourceTypeSub)
            local colorLv2 = Utility.getColorLvByModelId(item2.modelId, item2.resourceTypeSub)
            if colorLv1 ~= colorLv2 then
                return colorLv1 > colorLv2
            end
            return (item1.modelId or 0) > (item2.modelId or 0)
        end)    

        local cardListNode = ui.createCardList({
            maxViewWidth = dropBgSize.width * 0.9, 
            space = -10, 
            cardDataList = viewDataList,
            cardShape = Enums.CardShape.eCircle, 
            allowClick = true, 
            needArrows = true
        })
        cardListNode:setAnchorPoint(cc.p(0.5, 0.5))
        cardListNode:setPosition(dropBgSize.width / 2, 90)
        dropBgSprite:addChild(cardListNode)

        --数量选择控件
        local maxFightCount = nodeModel.fightNumMax - nodeInfo.FightCount
        local tempView = require("common.SelectCountView"):create({
            maxCount = maxFightCount,
            viewSize = cc.size(500, 200),
            changeCallback = function(count)
                fightCount = count
            end
        })
        tempView:setPosition(314, 130)
        layerBgSprite:addChild(tempView)
    end

    local okBtnInfo = {
        text = TR("扫荡"),
        clickAction = function(layerObj, btnObj)
            LayerManager.removeLayer(layerObj)
            if callback then
                callback(fightCount)
            end
            -- LayerManager.showSubModule(ModuleSub.ePracticeLightenStar)
        end,
    }

     MsgBoxLayer.addDIYLayer({
        bgSize = cc.size(628, 482),
        title = TR("扫荡"),     
        btnInfos = {okBtnInfo},
        closeBtnInfo = {},
        DIYUiCallback = confightDIYFunc,
        notNeedBlack = true,
    })
end

-- 门派声望进阶弹窗
--[[
    sectId  门派id
    rankId  职阶id
]]
function MsgBoxLayer.sectRankAdvanced(sectId, rankId)
    local popLayer = nil
    -- 弹窗回掉函数
    local function DIYfunc(boxRoot, bgSprite, bgSize)
        -- 提示文字
        local hintLabel = ui.newLabel({
                text = TR("您在%s的称号进阶为", SectModel.items[sectId].name),
                size = 26,
                color = Enums.Color.eBlack,
            })
        hintLabel:setPosition(bgSize.width*0.5, bgSize.height*0.6)
        bgSprite:addChild(hintLabel)
        popLayer = bgSprite
        -- 阶位图标
        local sectSprite = ui.newSprite(SectRankModel.items[rankId].pic..".png")
        sectSprite:setPosition(bgSize.width*0.5, bgSize.height*0.45)
        bgSprite:addChild(sectSprite)
    end

    local boxSize = cc.size(400, 300)

    local rankLayer = MsgBoxLayer.addDIYLayer({
        bgImage = "mp_87.png",
        bgSize = boxSize,
        title = "",
        DIYUiCallback = DIYfunc,
        notNeedBlack = true,
    })
        -- 弹窗动画
    -- 背面图
    local backSprite = ui.newScale9Sprite("sy_25.png", boxSize)
    backSprite:setPosition(popLayer:getContentSize().width*0.5, popLayer:getContentSize().height*0.5)
    popLayer:addChild(backSprite)
    -- 旋转圈数
    local rotateCount = 1
    -- 循环次数
    local loopCount = rotateCount*2
    -- 当前背面
    local isCurBeimian = false
    -- 先隐藏背面显示
    backSprite:setVisible(isCurBeimian)
    -- 动作总时间
    local allTime = 0.2
    -- x最小Scale
    local minScaleX = 0.05
    -- 动作列表
    local actionList = {}
    -- 循环创建动作
    for i = 1, loopCount do
        local curScale = Adapter.MinScale * (i / loopCount )
        local actionTime = allTime / (loopCount*2)

        local scaleAction = cc.ScaleTo:create(actionTime, minScaleX, curScale)

        local callAction = cc.CallFunc:create(function (node)
            isCurBeimian = not isCurBeimian
            backSprite:setVisible(isCurBeimian)
        end)
        local scaleAction2 = cc.ScaleTo:create(actionTime, curScale, curScale)

        table.insert(actionList, scaleAction)
        table.insert(actionList, callAction)
        table.insert(actionList, scaleAction2)
    end
    -- 创建序列动作
    local seqAction = cc.Sequence:create(actionList)
    popLayer:runAction(seqAction)
end

-- 丹方炼丹数量选择框
--[[
    title               丹方名字
    danInfo             成丹信息
    materialList        丹材列表
    maxNum              最大数量
    OkCallback          回调
]]
function MsgBoxLayer.addAlchemyCount(title, danInfo, materialList, maxNum, OkCallback)
    local selCount = 1 -- 当前选择的数量

    -- 提示窗体自定义控件函数
    local function DIYFuncion(layer, layerBgSprite, layerSize)
        -- 数量改变的回调
        local function changeCallback(count)
            selCount = count
        end

        -- 物品信息的背景
        local tempSprite = ui.newScale9Sprite("c_17.png", cc.size(546, 370))
        tempSprite:setAnchorPoint(cc.p(0.5, 1))
        tempSprite:setPosition(layerSize.width / 2, layerSize.height - 70)
        layerBgSprite:addChild(tempSprite)

        -- 药材列表
        local cardList = ui.createCardList({
                maxViewWidth = layerSize.width*0.7,
                cardDataList = materialList,
                isSwallow = false,
            })
        cardList:setAnchorPoint(cc.p(0.5, 0.5))
        cardList:setPosition(layerSize.width*0.5, layerSize.height*0.5)
        layerBgSprite:addChild(cardList)

        selectGoodsCountDIY({
            layer = layer,
            layerBgSprite = layerBgSprite,
            layerSize = layerSize,
            modelId = danInfo.modelId,
            maxNum = maxNum,
            countChangeCallback = changeCallback,
            cardPosition = cc.p(layerSize.width * 0.5, layerSize.height - 130),
        })
    end

    local okBtnInfo = {
        text = TR("确定"),
        clickAction = function(layerObj, btnObj)
            OkCallback(selCount, layerObj, btnObj)
        end,
    }

    return MsgBoxLayer.addDIYLayer({
        title = title or TR("选择"),
        bgSize = cc.size(600, 550),
        btnInfos = {okBtnInfo},
        closeBtnInfo = {},
        DIYUiCallback = DIYFuncion,
        notNeedBlack = true,
    })
end

-- 装备商店购买弹窗
--[[
-- 参数
    params:  -- 均为必选参数
    {
        title:           提示窗体的标题，默认为：TR("兑换")
        modelID          道具商品模型ID   -- 从道具模型中获得
        typeID           道具资源类型ID   -- 从道具模型中获得
        coinList         需要的代币列表
        [{
            resourceTypeSub 代币类型
            modelId         如果类型不是玩家属性，则需要传入模型Id
            num             道具兑换价格     -- 从道具模型中获得
        }]
        maxNum: 可兑换的最大数量, 如果为nil 或 小于等于 0, 则表示无限大
        oKCallBack: 选择确认的回调函数, 回调参数为OKCallback(exchangeCount, layerObj, btnObj)
        boxSize             弹窗大小
        isAddMaxBtn         添加一键最大按钮
    }
]]
function MsgBoxLayer.addEquipExchangeLayer(params)
    params.isAddMaxBtn = true
    MsgBoxLayer.addExchangeGoodsListCountLayer(params)
end

-- 提示选择次数
--[[
-- 参数
    params:  -- 均为必选参数
    {
        title               提示窗体的标题,默认为 “选选”
        msgtext             可选参数，提示内容文字，默认为 “”
        maxNum              最大上限
        OkCallback          回调
        bgSize              可选参数，弹窗大小
    }
]]
function MsgBoxLayer.selectCountLayer(params)
    local selCount = 1 -- 当前选择的数量

    -- 提示窗体自定义控件函数
    local function DIYFuncion(layer, layerBgSprite, layerSize)
        -- 提示
        if params.msgtext then
            local hintLabel = ui.newLabel({
                text = params.msgtext,
                color = Enums.Color.eNormalWhite,
                outlineColor = cc.c3b(0x46, 0x22, 0x0d),
                align = ui.TEXT_ALIGN_CENTER,
                dimensions = cc.size(layerSize.width*0.85 - 10, 0)
            })
            hintLabel:setAnchorPoint(cc.p(0.5, 1))
            hintLabel:setPosition(layerSize.width / 2, layerSize.height-90)
            layerBgSprite:addChild(hintLabel, 1)
        end

        -- 数量选择控件
        local tempView = require("common.SelectCountView"):create({
            maxCount = params.maxNum,
            viewSize = cc.size(500, 200),
            extraNum = params.extraNum,
            isAddMaxBtn = params.isAddMaxBtn,
            changeCallback = function(count)
                selCount = count

                return true
            end
        })
        tempView:setPosition(layerSize.width / 2, 150)
        layerBgSprite:addChild(tempView)
    end

    local okBtnInfo = {
        text = TR("确定"),
        clickAction = function(layerObj, btnObj)
            params.OkCallback(selCount, layerObj, btnObj)
        end,
    }

    return MsgBoxLayer.addDIYLayer({
        title = params.title or TR("选择"),
        -- msgText = params.msgText,
        bgSize = params.bgSize or cc.size(600, 350),
        btnInfos = {okBtnInfo},
        closeBtnInfo = {},
        DIYUiCallback = DIYFuncion,
    })
end

-- 选择无道具购买次数
--[[
-- 参数
    params:  -- 均为必选参数
    {
        title               提示窗体的标题,默认为 “选选”
        msgtext             可选参数，提示内容文字，默认为 “”
        maxNum              最大上限
        price               单价价格（{{resourceTypeSub = 1111, modelId = 0, num = 20}, ...})
        okCallback          回调
        bgSize              可选参数，弹窗大小
    }
]]
function MsgBoxLayer.selectBuyCountLayer(params)
    local selCount = 1 -- 当前选择的数量

    local function getUseResStr(num)
        local textStrList = {}
        for _, res in pairs(params.price or {}) do
            local textStr = string.format("{%s}%d", Utility.getDaibiImage(res.resourceTypeSub), res.num*num)
            table.insert(textStrList, textStr)
        end
        return table.concat(textStrList, "  ") or ""
    end
    -- 提示窗体自定义控件函数
    local function DIYFuncion(layer, layerBgSprite, layerSize)
        -- 提示
        if params.msgtext then
            local hintLabel = ui.newLabel({
                text = params.msgtext,
                color = Enums.Color.eNormalWhite,
                outlineColor = cc.c3b(0x46, 0x22, 0x0d),
                align = ui.TEXT_ALIGN_CENTER,
                dimensions = cc.size(layerSize.width*0.85 - 10, 0)
            })
            hintLabel:setAnchorPoint(cc.p(0.5, 1))
            hintLabel:setPosition(layerSize.width / 2, layerSize.height-90)
            layerBgSprite:addChild(hintLabel, 1)
        end

        -- 消耗资源
        local useLabel = nil
        if params.price then
            useLabel = ui.newLabel({
                text = TR("花费：%s",getUseResStr(selCount)),
                color = Enums.Color.eNormalWhite,
                outlineColor = cc.c3b(0x46, 0x22, 0x0d),
            })
            useLabel:setAnchorPoint(cc.p(0.5, 1))
            useLabel:setPosition(layerSize.width / 2, layerSize.height-130)
            layerBgSprite:addChild(useLabel, 1)
        end

        -- 数量选择控件
        local tempView = require("common.SelectCountView"):create({
            maxCount = params.maxNum,
            viewSize = cc.size(500, 200),
            extraNum = params.extraNum,
            isAddMaxBtn = params.isAddMaxBtn,
            changeCallback = function(count)
                selCount = count

                if useLabel then
                    useLabel:setString(TR("花费：%s",getUseResStr(selCount)))
                end
                return true
            end
        })
        tempView:setPosition(layerSize.width / 2, 150)
        layerBgSprite:addChild(tempView)
    end

    local okBtnInfo = {
        text = TR("确定"),
        clickAction = function(layerObj, btnObj)
            params.OkCallback(selCount, layerObj, btnObj)
        end,
    }

    return MsgBoxLayer.addDIYLayer({
        title = params.title or TR("选择"),
        -- msgText = params.msgText,
        bgSize = params.bgSize or cc.size(600, 350),
        btnInfos = {okBtnInfo},
        closeBtnInfo = {},
        DIYUiCallback = DIYFuncion,
    })
end

-- 宝石详情弹窗
--[[
-- 参数
    params:
    {
        imprintId: 宝石实例Id
        imprintModelId: 宝石模型Id, 如果 imprintId 为有效值，该参数失效
        slotId: 卡槽id（某卡槽宝石激活情况）(可选)
        btnInfos:  按钮（可选）
        title:     题目(可选)
        lockCallback: 锁定回调(可选)
    }
]]
function MsgBoxLayer.showImprintIntroLayer(params)
    local imprintModelId = params.imprintModelId
    local imprintInfo = nil
    if params.imprintId and Utility.isEntityId(params.imprintId) then
        imprintInfo = ImprintObj:getImprint(params.imprintId)
        imprintModelId = imprintInfo.ModelId
    end

    -- 模块信息
    local imprintModel = ImprintModel.items[imprintModelId]
    -- 属性信息
    local baseAttrList, extraAttrList = ImprintObj:getImprintAttrList(params.imprintId, imprintModelId)
    -- 套装信息
    local suitInfo = ImprintObj:getImprintSuitIntro(imprintModelId)
    -- 已上阵同类宝石数量
    local combatNum = ImprintObj:getImprintCombatNum(params.imprintId, params.slotId)

    local nameLabel = nil
    -- 提示窗体自定义控件函数
    local function DIYFuncion(layer, layerBgSprite, layerSize)
        -- 宝石卡牌
        local card = CardNode.createCardNode({
            resourceTypeSub = ResourcetypeSub.eImprint,
            modelId = imprintModelId,
            instanceData = imprintInfo,
            allowClick = false,
            cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eLevel},
        })
        card:setPosition(100, layerSize.height-115)
        layerBgSprite:addChild(card)
        -- 宝石名字
        local color = Utility.getQualityColor(imprintModel.quality, 1)
        nameLabel = ui.newLabel({
            text = imprintModel.name..(imprintInfo and imprintInfo.IsLock and TR("（已锁定）") or ""),
            color = color,
            outlineColor = cc.c3b(0x46, 0x22, 0x0d),
        })
        nameLabel:setAnchorPoint(cc.p(0, 0))
        nameLabel:setPosition(170, layerSize.height-105)
        layerBgSprite:addChild(nameLabel)
        -- 星数
        local starStr = ""
        for i = 1, imprintModel.stars do
            starStr = starStr .. "{c_75.png}"
        end
        local starLabel = ui.newLabel({
            text = starStr,
        })
        starLabel:setAnchorPoint(cc.p(0, 0))
        starLabel:setPosition(170, layerSize.height-145)
        layerBgSprite:addChild(starLabel)
        -- 黑背景
        local blackSize = cc.size(layerSize.width-60, layerSize.height-265)
        local blackBg = ui.newScale9Sprite("c_17.png", blackSize)
        blackBg:setAnchorPoint(cc.p(0.5, 1))
        blackBg:setPosition(layerSize.width*0.5, layerSize.height-170)
        layerBgSprite:addChild(blackBg)
        -- 列表
        local listView = ccui.ListView:create()
        listView:setDirection(ccui.ScrollViewDir.vertical)
        listView:setBounceEnabled(true)
        listView:setContentSize(cc.size(blackSize.width, blackSize.height-20))
        listView:setGravity(ccui.ListViewGravity.centerHorizontal)
        listView:setAnchorPoint(cc.p(0.5, 0.5))
        listView:setPosition(blackSize.width*0.5, blackSize.height*0.5)
        blackBg:addChild(listView)
        -- 属性
        local function addAttrItem(title, attrList, color, outlineColor)
            local itemWidth = listView:getContentSize().width
            local itemHight = 30

            local itemLayout = ccui.Layout:create()
            itemLayout:setContentSize(itemWidth, itemHight)
            listView:pushBackCustomItem(itemLayout)


            local titleLabel = ui.newLabel({
                text = title,
                color = color,
                outlineColor = outlineColor,
                size = 20,
            })
            titleLabel:setAnchorPoint(cc.p(0, 0))
            local titleSize = titleLabel:getContentSize()
            itemLayout:addChild(titleLabel)

            local space = 185
            local col = 2
            local labelSpace = 30
            for i, attrInfo in pairs(attrList) do
                local x = (i-1)%col
                local y = math.floor((i-1)/col)
                local posX = x*space+titleSize.width+20
                local posY = y*labelSpace+5
                itemHight = posY

                local attrStr = FightattrName[attrInfo.fightattr]..Utility.getAttrViewStr(attrInfo.fightattr, attrInfo.value, true)
                local attrLabel = ui.newLabel({
                    text = attrStr,
                    color = color,
                    outlineColor = outlineColor,
                    size = 20,
                })
                attrLabel:setAnchorPoint(cc.p(0, 0))
                attrLabel:setPosition(posX, posY)
                itemLayout:addChild(attrLabel)
            end

            titleLabel:setPosition(10, itemHight)

            itemHight = itemHight+labelSpace

            itemLayout:setContentSize(itemWidth, itemHight)
        end
        addAttrItem(TR("基础属性："), baseAttrList, cc.c3b(0x45, 0x22, 0x0d))
        if extraAttrList and next(extraAttrList) then
            local qualityColor = Utility.getQualityColor(imprintModel.quality, 1)
            addAttrItem(TR("额外属性："), extraAttrList, qualityColor, cc.c3b(0x46, 0x22, 0x0d))
        end

        -- 横线
        local lineItemSize = cc.size(listView:getContentSize().width, 20)
        local itemLayout = ccui.Layout:create()
        itemLayout:setContentSize(lineItemSize)
        listView:pushBackCustomItem(itemLayout)
        local lineSprite = ui.newScale9Sprite("mpdg_1.png", cc.size(lineItemSize.width, 4))
        lineSprite:setPosition(lineItemSize.width*0.5, lineItemSize.height*0.5)
        itemLayout:addChild(lineSprite)

        -- 套装信息
        local itemLayout = ccui.Layout:create()
        listView:pushBackCustomItem(itemLayout)

        local itemWidth = listView:getContentSize().width
        local itemHight = 5

        for i = (#suitInfo), 1, -1 do
            local attrInfo = suitInfo[i]
            local color = attrInfo.wearNum <= combatNum and cc.c3b(0x45, 0x22, 0x0d) or cc.c3b(0x5f, 0x5f, 0x5f)
            local tempLabel = ui.newLabel({
                text = TR("%s：%s", attrInfo.suitName, TalModel.items[attrInfo.talId].intro),
                color = color,
                size = 20,
                dimensions = cc.size(itemWidth-10, 0)
            })
            tempLabel:setAnchorPoint(cc.p(0, 0))
            tempLabel:setPosition(5, itemHight)
            itemLayout:addChild(tempLabel)
            itemHight = itemHight + tempLabel:getContentSize().height+5
        end
        itemLayout:setContentSize(cc.size(itemWidth, itemHight))
    end

    local okBtnInfo = {
        text = TR("确定"),
        clickAction = function(layerObj, btnObj)
            LayerManager.removeLayer(layerObj)
        end,
    }

    local btnInfos = params.btnInfos or {okBtnInfo}

    if imprintInfo then
        local lockBtnInfo = {
            text = imprintInfo.IsLock and TR("解锁") or TR("锁定"),
            clickAction = function(layerObj, btnObj)
                ImprintObj:setImprintLock(imprintInfo.Id, function ()
                    imprintInfo = ImprintObj:getImprint(imprintInfo.Id)
                    nameLabel:setString(imprintModel.name..(imprintInfo and imprintInfo.IsLock and TR("（已锁定）") or ""))
                    btnObj:setTitleText(imprintInfo.IsLock and TR("解锁") or TR("锁定"))
                    if params.lockCallback then
                        params.lockCallback()
                    end
                end)
            end,
        }
        table.insert(btnInfos, lockBtnInfo)
    end

    return MsgBoxLayer.addDIYLayer({
        title = params.title or TR("宝石详情"),
        bgSize = cc.size(580, 460),
        notNeedBlack = true,
        btnInfos = btnInfos,
        closeBtnInfo = {},
        DIYUiCallback = DIYFuncion,
    })
end

return MsgBoxLayer
