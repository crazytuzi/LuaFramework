--[[
	文件名：QuenchAlchemyLayer.lua
	描述：炼丹主界面
	创建人：yanghongsheng
	创建时间： 2017.12.5
--]]

local QuenchAlchemyLayer = class("QuenchAlchemyLayer", function(params)
	return display.newLayer()
end)

function QuenchAlchemyLayer:ctor(params)
    params = params or {}
    -- 药材丹药列表
    self.mPelletList = GoodsObj:getQuenchList(true)
    -- 选中药材列表
    self.mSelectPelletList = params.selectPelletList or {}
    -- 需要药材数量
    self.mNeedHerbsNum = 3
    -- 当前选择药材状态辅助表
    self.mStateAncillaryList = {}
	-- 屏蔽下层触摸
	ui.registerSwallowTouch({node = self})
	-- 创建标准容器
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)
    -- 创建底部导航和顶部玩家信息部分
    local tempLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        currentLayerType = Enums.MainNav.eChallenge,
        topInfos = {ResourcetypeSub.eMedicineCoin, ResourcetypeSub.eGold, ResourcetypeSub.eDiamond}
    })
    self:addChild(tempLayer)
    self.mCommonLayer_ = tempLayer

    -- 初始化数据
    self:collatingData()

    -- 初始化
    self:initUI()
end

function QuenchAlchemyLayer:getRestoreData()
    local layerParams = {
        selectPelletList = self.mSelectPelletList
    }

    return layerParams
end

function QuenchAlchemyLayer:collatingData()
    -- 序列化药材列表
    local tempList = {}
    for _, pelletInfo in pairs(self.mPelletList) do
        table.insert(tempList, pelletInfo)
    end
    self.mPelletList = tempList
    -- 对药材列表排序（按品质从小到大排序，同品质按模型id顺序排）
    table.sort(self.mPelletList, function (item1, item2)
        local goodsInfo1 = GoodsModel.items[item1.ModelId]
        local goodsInfo2 = GoodsModel.items[item2.ModelId]

        if goodsInfo1.quality ~= goodsInfo2.quality then
            return goodsInfo1.quality < goodsInfo2.quality
        end

        return goodsInfo1.ID < goodsInfo2.ID
    end)

    -- 更新选择药材状态辅助表
    self:refreshStateList()
end

function QuenchAlchemyLayer:initUI()
	-- 创建背景
    local spriteBg = ui.newSprite("cuiti_08.jpg")
    spriteBg:setPosition(320, 568)
    self.mParentLayer:addChild(spriteBg, -2)

    -- 炼丹阁名字
    local nameSprite = ui.createSpriteAndLabel({
            imgName = "zdfb_10.png",
            labelStr = TR("炼丹阁"),
            fontColor = cc.c3b(0x46, 0x22, 0x0d),
        })
    nameSprite:setPosition(320, 1050)
    self.mParentLayer:addChild(nameSprite, -2)

    -- 丹炉
    local danluSprite = ui.newSprite("cuiti_10.png")
    danluSprite:setPosition(320, 640)
    self.mParentLayer:addChild(danluSprite)

    -- 丹炉特效
    self.danluEffect = ui.newEffect({
            parent = self.mParentLayer,
            position = cc.p(330, 594),
            effectName = "effect_ui_liandange",
        })
    self.danluEffect:setAnimation(0, "baguazhuandong", true)

    -- 创建选中药材展示框
    self:herbsPlace()

    -- 创建界面功能按钮
    self:createBtnList()
	
	--返回按钮
    local closeBtn = ui.newButton({
        normalImage = "c_29.png",
        position = Enums.StardardRootPos.eCloseBtn,
        clickAction = function(pSender)
            LayerManager.removeLayer(self)
        end
    })
    self.mParentLayer:addChild(closeBtn)
end

-- 创建界面功能按钮
function QuenchAlchemyLayer:createBtnList()
    local btnConfig = {
        -- 丹方
        {
            normalImage = "cuiti_01.png",
            position = cc.p(590, 950),
            clickAction = function ()
                self:lookFormula()
            end,
        },
        -- 去服丹
        {
            normalImage = "cuiti_03.png",
            position = cc.p(590, 850),
            clickAction = function ()
                LayerManager.addLayer({name = "quench.QuenchEatMedicineLayer", cleanUp = true})
            end,
        },
        -- 药材丹药包裹
        {
            normalImage = "cuiti_02.png",
            position = cc.p(50, 950),
            clickAction = function ()
                LayerManager.addLayer({name = "quench.QuenchBagLayer", cleanUp = true})
            end,
        },
        -- 规则
        {
            normalImage = "tb_127.png",
            position = cc.p(50, 850),
            isGuide = true,
            clickAction = function ()
                MsgBoxLayer.addRuleHintLayer(TR("规则"), {
                    TR("1.不同品质的药材可炼制不同品质的丹药。"),
                    TR("2.药材只能炼制与其品质相同的丹药。"),
                    TR("3.通过手动炼制可以触发丹方，通过丹方炼制能获得您想要的丹药。"),
                    TR("4.丹药可以通过服丹直接食用。"),
                    TR("5.特殊的丹药是淬体必不可少的道具，可以通过普通丹药二次炼制获得。"),
                    TR("6.一键炼丹只能炼制药材。"),
                    TR("7.药材可以通过守卫光明顶获得，也可以在帮派商店和丹药商店直接购买。"),
                })

                -- 结束引导
                local _, _, eventID = Guide.manager:getGuideInfo()
                if eventID == 10016 then
                    Guide.manager:nextStep(eventID, true)
                    Guide.manager:removeGuideLayer()
                end
            end,
        },
        -- 丹药商店
        {
            normalImage = "tb_228.png",
            position = cc.p(50, 750),
            clickAction = function ()
                LayerManager.addLayer({
                        name = "quench.QuenchShopLayer",
                        cleanUp = false,
                    })
            end,
        },
        -- 一键添加
        {
            normalImage = "cuiti_06.png",
            position = cc.p(550, 280),
            clickAction = function ()
                self:oneKeyAdd()
            end,
        },
        -- 炼丹
        {
            normalImage = "c_33.png",
            text = TR("炼丹"),
            position = cc.p(220, 170),
            clickAction = function ()
                if self:getListSize(self.mSelectPelletList) < self.mNeedHerbsNum then
                    ui.showFlashView({text = TR("炼丹药材不足")})
                    return
                end
                -- 获取丹药模型id
                local modelList = {}
                for _, selectData in pairs(self.mSelectPelletList) do
                    table.insert(modelList, selectData.ModelId)
                end
                self:requestAlchemy(modelList, function (response)
                    -- 播放特效
                    self:playerEffect()
                    -- 如果触发丹方
                    if response.Value.PrescriptionId and response.Value.PrescriptionId ~= 0 then
                        -- 激活丹方动作
                        self:activateFormulation(response.Value.PrescriptionId)
                    -- 正常
                    else
                        ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)
                    end
                end)
            end,
        },
        -- 一键炼丹
        {
            normalImage = "c_28.png",
            text = TR("一键炼丹"),
            position = cc.p(450, 170),
            clickAction = function ()
                self:oneKeyBox()
            end,
        },
    }

    for _, btnInfo in pairs(btnConfig) do
        local tempBtn = ui.newButton(btnInfo)
        self.mParentLayer:addChild(tempBtn)
        -- 保存引导使用
        if btnInfo.isGuide then
            self.mRuleBtn = tempBtn
        end
    end
end

-- 更新选择药材状态辅助表
function QuenchAlchemyLayer:refreshStateList()
    local count = 0
    local hadSelectModelList = {}
    local tempPelletModel = 0
    for _, pelletInfo in pairs(self.mSelectPelletList) do
        if pelletInfo then
           local modelCount = hadSelectModelList[pelletInfo.ModelId] or 0
            modelCount = modelCount + 1
            hadSelectModelList[pelletInfo.ModelId] = modelCount

            count = count + 1

            tempPelletModel = pelletInfo.ModelId
        end
    end

    -- 药材选择表中的数量
    self.mStateAncillaryList.count = count
    -- 药材选择表中modelId及对应数量
    self.mStateAncillaryList.modelIdList = hadSelectModelList
    -- 药材选择表中的药材品质
    if count > 0 then
        self.mStateAncillaryList.qualityLv = Utility.getQualityColorLv(GoodsModel.items[tempPelletModel].quality)
    else
        self.mStateAncillaryList.qualityLv = nil
    end
end

-- 创建药材放置框
function QuenchAlchemyLayer:herbsPlace()
    local space = 25
    local cardSize = ui.getImageSize("c_04.png")
    local parentSize = cc.size((cardSize.width+space)*self.mNeedHerbsNum, cardSize.height)
    if not self.cardParentNode then
        self.cardParentNode = cc.Node:create()
        self.cardParentNode:setAnchorPoint(cc.p(0.5, 0.5))
        self.cardParentNode:setContentSize(parentSize)
        self.cardParentNode:setPosition(320, 230)
        self.mParentLayer:addChild(self.cardParentNode)
    end
    self.cardParentNode:removeAllChildren()
    
    for i = 1, self.mNeedHerbsNum do
        local card = CardNode:create({
                allowClick = true,
                onClickCallback = function(sender)
                    if self.mSelectPelletList[i] then
                        self.mSelectPelletList[i] = nil
                        self:refreshStateList()
                        sender:setEmpty({}, "c_04.png")
                        sender:showGlitterAddMark()
                    else
                        self:tranHerbsLayer(i)
                    end
                end,
            })
        local cardSpace = space+cardSize.width
        card:setAnchorPoint(cc.p(0.5, 0.5))
        card:setPosition((i-1)*cardSpace+cardSize.width*0.5, parentSize.height)
        self.cardParentNode:addChild(card)

        if self.mSelectPelletList[i] then
            local pelletInfo = GoodsObj:findByModelId(self.mSelectPelletList[i].ModelId)
            if pelletInfo and pelletInfo[1].Num > 0 then
                card:setCardData({
                    resourceTypeSub = ResourcetypeSub.eQuench,
                    modelId = self.mSelectPelletList[i].ModelId,
                    num = pelletInfo[1].Num,
                })
            else
                self.mSelectPelletList[i] = nil
                -- 创建空槽
                card:setEmpty({}, "c_04.png")
                card:showGlitterAddMark()
            end
        else
            -- 创建空槽
            card:setEmpty({}, "c_04.png")
            card:showGlitterAddMark()
        end
    end
end

-- 浏览丹方
function QuenchAlchemyLayer:lookFormula()
    if not self.PrescriptionInfo then
        self:requestPrescriptionInfo()
        return
    end
    -- 排序
    table.sort(self.PrescriptionInfo, function (a, b)
        return a < b
    end)
    LayerManager.addLayer({
            name = "quench.QuenchPrescriptionLayer",
            cleanUp = false,
            data = {
                prescriptionList = self.PrescriptionInfo,
                callback = function ()
                    self:herbsPlace()
                end,
            },
        })
end

-- 获取列表大小
function QuenchAlchemyLayer:getListSize(list)
    local count = 0
    for _, v in pairs(list or {}) do
        if v then
            count = count + 1
        end
    end

    return count
end

-- 跳转药材界面
function QuenchAlchemyLayer:tranHerbsLayer(index)
    -- 筛选药材列表
    local function screenPelletList()
        -- 若还没开始选择
        if self.mStateAncillaryList.count == 0 then return self.mPelletList end
        -- 已经选择过药材
        local screenList = {}
        for _, pelletInfo in ipairs(self.mPelletList) do
            if Utility.getQualityColorLv(GoodsModel.items[pelletInfo.ModelId].quality) == self.mStateAncillaryList.qualityLv then
                if self.mStateAncillaryList.modelIdList[pelletInfo.ModelId] then
                    pelletInfo.Num = pelletInfo.Num - self.mStateAncillaryList.modelIdList[pelletInfo.ModelId]
                    if pelletInfo.Num > 0 then table.insert(screenList, pelletInfo) end
                else
                    table.insert(screenList, pelletInfo)
                end
            end
        end

        return screenList
    end
    LayerManager.addLayer({
            name = "quench.QuenchMedicineLayer",
            data = {
                pelletList = screenPelletList(),
                selectPelletList = self.mSelectPelletList,
                needHerbsNum = self.mNeedHerbsNum,
            },
        })
end

-- 一键添加功能函数
function QuenchAlchemyLayer:oneKeyAdd()
    if self:getListSize(self.mSelectPelletList) >= self.mNeedHerbsNum then
        ui.showFlashView({text = TR("已有足够的炼丹药材")})
        return
    end
    -- 淬体丹药列表，需要在一键添加中排出
    local cuitiTable = {
        [16110305] = true,
        [16110306] = true,
        [16110605] = true,
        [16110606] = true,
        [16111005] = true,
        [16111006] = true,
        [16111305] = true,
        [16111306] = true,
        [16112005] = true,
        [16112006] = true,
        [16112505] = true,
        [16112506] = true,
    }
    -- 保存最初的选择状态
    local saveStartSelect = clone(self.mSelectPelletList)

    -- 一键功能品质上限
    local qualityLimit = 3 -- 蓝色
    -- 备选表
    local primaryList = {}
    -- 序列化选择表
    local tempList = {}
    for _, selectData in pairs(self.mSelectPelletList) do
        table.insert(tempList, selectData)
    end
    self.mSelectPelletList = tempList
    -- 加入相同项进入列表
    local function addListItem(list, modelId, num)
        while (#list < self.mNeedHerbsNum) and (num > 0) do
            table.insert(list, {ModelId = modelId})
            num = num - 1
        end
    end

    -- 循环整个药材列表，从中找出符合要求的药材加入选择列表
    for _, herbsInfo in ipairs(self.mPelletList) do
        local herbsData = GoodsModel.items[herbsInfo.ModelId]
        local herbsQualityLv = Utility.getQualityColorLv(herbsData.quality)
        -- 设定循环跳出条件 1:药材选择表已达到数量要求 2:药材品质已经超出限定品质（因为已对药材表按由低到高的品质排过序，所以可以直接在这里作为判断条件）
        if (#self.mSelectPelletList >= self.mNeedHerbsNum) or (herbsQualityLv > qualityLimit) then
            break
        end
        -- 排除淬体丹药
        if not cuitiTable[herbsInfo.ModelId] then
            -- 选择表中已有药材，且品质与当前药材品质相同
            if self.mStateAncillaryList.qualityLv and self.mStateAncillaryList.qualityLv == herbsQualityLv then
                local hadUseNum =  self.mStateAncillaryList.modelIdList[herbsInfo.ModelId] or 0
                addListItem(self.mSelectPelletList, herbsInfo.ModelId, herbsInfo.Num-hadUseNum)
                self:refreshStateList()
            -- 选择表中已有药材，但品质与当前药材品质不同
            elseif self.mStateAncillaryList.qualityLv then
                -- 创建备选表
                primaryList[herbsQualityLv] = primaryList[herbsQualityLv] or {}
                addListItem(primaryList[herbsQualityLv], herbsInfo.ModelId, herbsInfo.Num)
            -- 选择表中还没有药材，直接将当前药材加入选择表
            else
                addListItem(self.mSelectPelletList, herbsInfo.ModelId, herbsInfo.Num)
                self:refreshStateList()
            end
        end
    end

    -- 选择表数量不足时，将从备选表中选出数量符合的
    if #self.mSelectPelletList < self.mNeedHerbsNum then
        for i = 1, qualityLimit do
            if primaryList[i] and #primaryList[i] >= self.mNeedHerbsNum then
                self.mSelectPelletList = primaryList[i]
                self:refreshStateList()
                break
            end
        end
    end

    -- 若还是不足，提示药材不足
    if #self.mSelectPelletList < self.mNeedHerbsNum then
        self.mSelectPelletList = saveStartSelect
        self:refreshStateList()
        ui.showFlashView({text = TR("没有足够的%s品质及以下药材", Utility.getColorName(qualityLimit))})
    else
        self:herbsPlace()
    end
end

-- 创建品质选择盒
function QuenchAlchemyLayer:oneKeyBox()
    --保存菜单选择状态
    self.mSelectStatus = {
        -- [1] = false, -- 白色
        [2] = false,    -- 绿色
        [3] = false,    -- 蓝色
        [4] = false,    -- 紫色
        [5] = false,    -- 橙色
        [6] = false,    -- 红色
        [7] = false,    -- 金色
    }
    -- 是否已打开选择盒
    if self.isOpenBox then return end
    self.isOpenBox = true
    -- 添加一个当前最上层的层
    local touchLayer = ui.newStdLayer()
    self:addChild(touchLayer, 999)
    -- 添加选择盒背景
    local selBgSprite = ui.newScale9Sprite("gd_01.png", cc.size(100, 100))
    selBgSprite:setAnchorPoint(0.5, 0)
    selBgSprite:setPosition(450, 200)
    selBgSprite:setScale(0.1)
    touchLayer:addChild(selBgSprite)
    -- 播放变大动画
    local scale = cc.ScaleTo:create(0.3, 1)
    selBgSprite:runAction(scale)
    -- 关闭选择盒
    local function closeBox()
        local callfunDelete = cc.CallFunc:create(function()
            touchLayer:removeFromParent()
            self.isOpenBox = false
        end)
        local scale = cc.ScaleTo:create(0.3, 0.1)
        selBgSprite:runAction(cc.Sequence:create(scale, callfunDelete))
    end
    -- 注册触摸监听关闭选择盒
    ui.registerSwallowTouch({
        node = touchLayer,
        allowTouch = true,
        endedEvent = function(touch, event)
            closeBox()
        end
    })
    -- 创建选择列表
    local function createCheckBoxList(cellSize)
        -- 列表view
        local selectList = ccui.ListView:create()
        selectList:setDirection(ccui.ScrollViewDir.vertical)
        -- 列表高度计数
        local listHight = 0

        for key, _ in pairs(self.mSelectStatus) do
            local layout = ccui.Layout:create()
            layout:setContentSize(cellSize)

            local cellSprite = ui.newScale9Sprite("zl_09.png", cc.size(cellSize.width, cellSize.height-5))
            cellSprite:setPosition(cellSize.width*0.5, cellSize.height*0.5)
            layout:addChild(cellSprite)

            local color = Utility.getColorValue(key, 1)
            local checkBtn = ui.newCheckbox({
                text = TR("%s品质",Utility.getColorName(key)),
                isRevert = true,
                textColor = color,
                outlineColor = Enums.Color.eBlack,
                outlineSize = 2,
                callback = function(pSenderC)
                    self.mSelectStatus[key] = not self.mSelectStatus[key]
                end
                })
            checkBtn:setPosition(cellSize.width*0.5, cellSize.height*0.5)
            layout:addChild(checkBtn)
            checkBtn:setCheckState(self.mSelectStatus[key])
            
            -- 透明按钮（点击列表项改变复选框状态）
            local touchBtn = ui.newButton({
                normalImage = "c_83.png",
                size = cellSize,
                clickAction = function()
                    self.mSelectStatus[key] = not self.mSelectStatus[key]
                    checkBtn:setCheckState(self.mSelectStatus[key])
                end
            })
            touchBtn:setPosition(cellSize.width*0.5, cellSize.height*0.5)
            cellSprite:addChild(touchBtn)
            
            -- 加入列表
            selectList:pushBackCustomItem(layout)
            -- 列表长度计数
            listHight = listHight + cellSize.height
        end
        -- 设置列表大小
        selectList:setContentSize(cellSize.width, listHight+10)

        return selectList
    end
    -- 创建列表
    local selectListView = createCheckBoxList(cc.size(200, 50))
    local listSize = selectListView:getContentSize()
    -- 重设背景图大小
    local bgSize = cc.size(listSize.width+40, listSize.height+100)
    selBgSprite:setContentSize(bgSize)
    -- 设置列表位置
    selectListView:setAnchorPoint(cc.p(0.5, 0))
    selectListView:setPosition(bgSize.width*0.5, 60)
    selBgSprite:addChild(selectListView)

    -- 关闭按钮
    local closeButton = ui.newButton({
        normalImage = "zl_10.png",
        clickAction = function()
            touchLayer:removeFromParent()
            self.isOpenBox = false
        end
    })
    closeButton:setPosition(bgSize.width * 0.87, bgSize.height-25)
    selBgSprite:addChild(closeButton)

    -- 确定按钮
    local confirmButton = ui.newButton({
        normalImage = "c_28.png",
        text = TR("确认"),
        clickAction = function()
            -- 是否有选择品质
            local isSelect = false
            for _, state in pairs(self.mSelectStatus) do
                if state then
                    isSelect = true
                    break
                end
            end
            -- 若没选
            if not isSelect then
                ui.showFlashView({text = TR("请选择炼丹品质")})
                return
            end
            -- 请求一键炼丹
            self:requestOnekey(self.mSelectStatus)
            -- 关闭选择盒
            closeBox()
        end
    })
    confirmButton:setScale(0.9)
    confirmButton:setPosition(bgSize.width * 0.5, 40)
    selBgSprite:addChild(confirmButton)
end

-- 播放炼丹特效
function QuenchAlchemyLayer:playerEffect(callback)
    -- 移除之前没播放完多余的特性
    if next(self.effectGroup or {}) then
        for _, effect in pairs(self.effectGroup) do
            if not tolua.isnull(effect) then
                effect:removeFromParent()
            end
        end
    end
    self.effectGroup = {}

    -- 播放开门特性
    self.danluEffect:setToSetupPose()
    SkeletonAnimation.action({
            skeleton = self.danluEffect,
            action = "baguakaimen",
            loop = false,
            completeListener = function ()
                -- 播放火特性
                self.danluEffect:setAnimation(0, "bagua_huo", true)
                local yanEffect = ui.newEffect({
                        parent = self.mParentLayer,
                        effectName = "effect_ui_liandange",
                        animation = "yan",
                        position = cc.p(330, 750),
                        loop = false,
                        endListener = function ()
                            self.danluEffect:setToSetupPose()
                            self.danluEffect:setAnimation(0, "baguazhuandong", true)
                        end,
                    })
                table.insert(self.effectGroup, yanEffect)

                -- 调用回调
                if callback then
                    callback()
                end
            end,
        })
    -- 播放光圈
    local quanEffect = ui.newEffect({
            parent = self.mParentLayer,
            zorder = -1,
            effectName = "effect_ui_liandange",
            animation = "baguakaimen_quan",
            position = cc.p(330, 570),
            loop = false,
        })
    table.insert(self.effectGroup, quanEffect)
end

-- 激活丹方
function QuenchAlchemyLayer:activateFormulation(id)
    -- 丹方信息
    local formulaInfo = MedicinePrescriptionRelation.items[id]
    local pelletInfo = Utility.analysisStrResList(formulaInfo.getGoods)[1]
    local herbsModelList = string.splitBySep(formulaInfo.needGoodsA, ",")

    -- 创建触摸弹窗
    local touchBgSprite = self:createTouchLayer()
    local bgSize = cc.size(500, 370)
    touchBgSprite:setTexture("mrjl_02.png")
    touchBgSprite:setContentSize(bgSize)

    -- 题目
    local titleLabel = ui.newLabel({
            text = TR("%s丹方", Utility.getGoodsName(pelletInfo.resourceTypeSub, pelletInfo.modelId)),
            size = Enums.Fontsize.eTitleDefault,
            color = cc.c3b(0xff, 0xee, 0xd0),
            outlineColor = cc.c3b(0x3a, 0x24, 0x18),
        })
    titleLabel:setPosition(bgSize.width*0.5, bgSize.height-40)
    touchBgSprite:addChild(titleLabel)

    -- 炼出的丹药卡
    pelletInfo.cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eName}
    local pelletCard = CardNode.createCardNode(pelletInfo)
    pelletCard:setPosition(bgSize.width*0.5, bgSize.height*0.65)
    touchBgSprite:addChild(pelletCard)

    -- 材料信息
    local herbsInfoList = {}
    for _, modelId in pairs(herbsModelList) do
        local cardData = {}
        cardData.resourceTypeSub = ResourcetypeSub.eQuench
        cardData.modelId = tonumber(modelId)
        cardData.cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eName}

        table.insert(herbsInfoList, cardData)
    end

    -- 材料卡
    local cardList = ui.createCardList({
            maxViewWidth = bgSize.width*0.8,
            cardDataList = herbsInfoList,
        })
    cardList:setAnchorPoint(cc.p(0.5, 0.5))
    cardList:setPosition(bgSize.width*0.5, bgSize.height*0.25)
    touchBgSprite:addChild(cardList)
end

-- 丹方触摸层
function QuenchAlchemyLayer:createTouchLayer()
    -- 触摸层
    local touchLayer = ui.newStdLayer()
    self:addChild(touchLayer)

    -- 显示背景
    local bgSize = ui.getImageSize("mrjl_02.png")
    local bgSprite = ui.newScale9Sprite("mrjl_02.png", bgSize)
    bgSprite:setPosition(320, 568)
    touchLayer:addChild(bgSprite)

    -- 弹窗弹出动画
    ui.showPopAction(bgSprite)

    -- 注册点击关闭事件
    ui.registerSwallowTouch({
            node = touchLayer,
            endedEvent = function (touch, event)
                local move = cc.MoveTo:create(0.3, cc.p(590, 950))
                local scale = cc.ScaleTo:create(0.3, 0)
                local spawn = cc.Spawn:create(move, scale)
                local callfunc = cc.CallFunc:create(function ()
                    touchLayer:removeFromParent()
                    touchLayer = nil
                end)
                bgSprite:runAction(cc.Sequence:create(spawn, callfunc))
            end
        })
    return bgSprite
end

--=========================服务器相关============================
-- 丹方信息
function QuenchAlchemyLayer:requestPrescriptionInfo()
	HttpClient:request({
        moduleName = "QuenchInfo",
        methodName = "GetInfo",
        svrMethodData = {},
        callback = function(response)
            if response and response.Status ~= 0 then
                return
            end
            self.PrescriptionInfo = response.Value.PrescriptionInfo or {}
            self:lookFormula()
        end
    })
end

-- 炼丹
function QuenchAlchemyLayer:requestAlchemy(modelList, callback)
    HttpClient:request({
        moduleName = "QuenchInfo",
        methodName = "Alchemy",
        svrMethodData = {modelList},
        callback = function(response)
            if response and response.Status ~= 0 then
                return
            end
            -- 更新数据
            self.PrescriptionInfo = response.Value.PrescriptionInfo or {}
            self.mPelletList = GoodsObj:getQuenchList(true)
            -- 初始化数据
            self:herbsPlace()
            self:collatingData()
            -- 调用回调
            if callback then
                callback(response)
            end
        end
    })
    
end

-- 一键炼丹
function QuenchAlchemyLayer:requestOnekey(qualityList)
    -- 整理颜色品质
    local qualityLvList = {}
    for qualityLv, isSelect in pairs(qualityList) do
        if isSelect then table.insert(qualityLvList, qualityLv) end
    end
    -- 请求服务器
    HttpClient:request({
        moduleName = "QuenchInfo",
        methodName = "AlchemyForOneKey",
        svrMethodData = {qualityLvList},
        callback = function(response)
            if response and response.Status ~= 0 then
                return
            end
            -- 更新数据
            self.PrescriptionInfo = response.Value.PrescriptionInfo or {}
            self.mPelletList = GoodsObj:getQuenchList(true)
            -- 初始化数据
            self:herbsPlace()
            self:collatingData()
            -- 播放特效，并弹出炼的丹药
            self:playerEffect(function ()
                MsgBoxLayer.addGameDropLayer(response.Value.BaseGetGameResourceList, {}, TR("获得以下物品"), TR("炼丹成功"), {{text = TR("确定")}}, {})
            end)
        end
    })
end

----------------- 新手引导 -------------------
function QuenchAlchemyLayer:onEnterTransitionFinish()
    self:executeGuide()
end
-- 执行新手引导
function QuenchAlchemyLayer:executeGuide()
    Guide.helper:executeGuide({
        -- 指向炼丹规则
        [10016] = {clickNode = self.mRuleBtn},
    })
end

return QuenchAlchemyLayer