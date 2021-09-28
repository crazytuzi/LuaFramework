--[[
    文件名：BddExchangeLayer.lua
    描述：神装塔-兑换界面
    创建人：yanghongsheng
    创建时间：2017.4.21
-- ]]


local BddExchangeLayer = class("BddExchangeLayer",function()
    return display.newLayer()
end)

local enumsType = {
    eExchange = 1, --兑换
    eBlue = 2,         -- 蓝
    eViolet = 3,        -- 紫
    eGreen = 4,        -- 橙
    eRed = 5,        -- 红
    eGod = 6,        -- 金
}

--[[
    参数注释
    params{
        historyMaxNum 历史最高星数
    }
]]
function BddExchangeLayer:ctor(params)
	self.historyMaxNum = params.historyMaxNum
    self.mTag = params.mTag or 1
	-- 父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- 装备数据
    self.equipShopInfo = {}
    -- 显示列表数据
    self.useEquipList = {}
    -- 请求比武招亲数据（最高星数）并初始化界面
    self:requestBddData()

    self.equipData = clone(BddEquipExchangeRelation.items)
    self:dataHandle()
end

function BddExchangeLayer:initUI()
    ui.registerSwallowTouch({node = self})
	-- 包含顶部底部的公共layer
    self.mCommonLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        topInfos = {ResourcetypeSub.eMerit, ResourcetypeSub.eTaoZhuangCoin, ResourcetypeSub.eDiamond}
    })
    self:addChild(self.mCommonLayer)

    -- 背景
    local bgSprite = ui.newSprite("c_128.jpg")
    bgSprite:setPosition(320, 568)
    self.mParentLayer:addChild(bgSprite)

    -- 创建美女
    local womenSprite = ui.newSprite("bwzq_13.png")
    womenSprite:setAnchorPoint(1, 1)
    womenSprite:setPosition(640, 1050)
    self.mParentLayer:addChild(womenSprite)

    -- 欢迎光临sprite
    local welcomeSprite = ui.newSprite("bwzq_02.png")
    welcomeSprite:setAnchorPoint(0, 1)
    welcomeSprite:setPosition(0, 980)
    self.mParentLayer:addChild(welcomeSprite)

    -- 提示Bg
    local lableBg = ui.newScale9Sprite("c_145.png", cc.size(420, 100))
    lableBg:setAnchorPoint(0, 0.5)
    lableBg:setPosition(10, 800)
    self.mParentLayer:addChild(lableBg)

    -- 提示label
    self.mHintLabel = ui.newLabel({
            anchorPoint = cc.p(0, 1),
            text = "",
            color = Enums.Color.eNormalWhite,
            size = 20,
            outlineColor = cc.c3b(0x30, 0x30, 0x30),
            outlineSize = 2,
            dimensions = cc.size(370, 40),
        })
    self.mHintLabel:setPosition(10, 70)
    lableBg:addChild(self.mHintLabel)

    -- 添加黑底
    local decBgSize = cc.size(640, 147)
    local decBg = ui.newScale9Sprite("c_73.png", decBgSize)
    decBg:setPosition(cc.p(320, 1068))
    self.mParentLayer:addChild(decBg)

    -- 添加分页控件
    self:addTabLayer()

    -- 关闭按钮
    self.mCloseBtn = ui.newButton({
        normalImage = "c_29.png",
        position = cc.p(594, 1025),
        clickAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self.mParentLayer:addChild(self.mCloseBtn)
end

function BddExchangeLayer:addTabLayer()
    -- 兑换按钮配置
    local btnInfoTble = {
        [1] = {
            text = TR("兑换"),
            tag = enumsType.eExchange,
        },
        [2] =
        {
            text = TR("蓝色装备"),
            tag = enumsType.eBlue
        },
        [3] =
        {
            text = TR("紫色装备"),
            tag = enumsType.eViolet
        },
        [4] =
        {
            text = TR("橙色装备"),
            tag = enumsType.eGreen
        }
    }
    local tabSpace = nil
    -- 超过一定值时才显示红色装备
    if self.historyMaxNum > 204 then
        table.insert(btnInfoTble, {
            text = TR("红色装备"),
            tag = enumsType.eRed
        })
        tabSpace = 5
    end

     -- 超过一定值时才显示金色装备
    if self.historyMaxNum > 300 then
        table.insert(btnInfoTble, {
            text = TR("金色装备"),
            tag = enumsType.eGod
        })
        tabSpace = 5
    end

    self.mPlayerLV = PlayerAttrObj:getPlayerAttrByName("Lv")
    -- 创建分页
    local tabLayer = ui.newTabLayer({
        btnInfos = btnInfoTble,
        space = tabSpace,
        needLine = false,
        defaultSelectTag = self.mTag,
        viewSize = cc.size(550, 80),
        onSelectChange = function(selectBtnTag)
            if selectBtnTag == 1 then
                self.mHintLabel:setString(TR("     历史星数越高，可兑换的道具越多。加油少年，我看好你哟！"))
                self:refreshTab()
            else
                self:refreshEqList(selectBtnTag)

                local exchangeConfig = {
                    [2] = {needLv = 15, colorName = TR("蓝色")},
                    [3] = {needLv = 30, colorName = TR("紫色")},
                    [4] = {needLv = 35, colorName = TR("橙色")},
                    [5] = {needLv = 60, colorName = TR("红色")},
                    [6] = {needLv = 90, colorName = TR("金色")},
                }
                local tagConfig = exchangeConfig[selectBtnTag]
                if (tagConfig ~= nil) then
                    if selectBtnTag > 3 then
                        self.mHintLabel:setString(TR("1.分解普通装备可获得玄金，分解套装可获得玄金、天玉\n2.%d级开放%s装备兑换", tagConfig.needLv, tagConfig.colorName))
                    else
                        self.mHintLabel:setString(TR("1.分解普通装备可获得玄金，分解套装可获得玄金、天玉"))
                    end
                end
            end

        end
    })
    tabLayer:setAnchorPoint(cc.p(0, 0.5))
    tabLayer:setPosition(0, 1025)
    self.mParentLayer:addChild(tabLayer)
    -- 添加黑线
    local lineSprite = ui.newScale9Sprite("c_20.png", cc.size(640, 15))
    lineSprite:setPosition(320, 997)
    self.mParentLayer:addChild(lineSprite)
end

function BddExchangeLayer:refreshTab()
	-- 下面总节点
    if self.bottomNode then
        self.bottomNode:removeFromParent()
        self.bottomNode = nil
    end
    self.bottomNode = cc.Node:create()
    self.mParentLayer:addChild(self.bottomNode)
    
    -- 下半部分背景图
    local bottomBgSize = cc.size(640, 750)
	local bottomBg = ui.newScale9Sprite("c_19.png", bottomBgSize)
	bottomBg:setAnchorPoint(cc.p(0.5, 0))
	bottomBg:setPosition(320, 0)
	self.bottomNode:addChild(bottomBg)

    -- 星背景
    local starBg = ui.newScale9Sprite("c_24.png", cc.size(120, 40))
    starBg:setPosition(190, 683)
    bottomBg:addChild(starBg)

    -- 历史最高label
    local historyMaxLable = ui.newLabel({
            text = TR("历史最高：{c_75.png}  #bd6e00%d", self.historyMaxNum),
            size = 24,
            color = Enums.Color.eBlack,
        })
    historyMaxLable:setAnchorPoint(cc.p(0, 0))
    historyMaxLable:setPosition(20, 670)
    bottomBg:addChild(historyMaxLable)

	-- 列表背景
    local listviewBgSize = cc.size(620, 545)
	local listviewBg = ui.newScale9Sprite("c_17.png", listviewBgSize)
	listviewBg:setPosition(bottomBgSize.width*0.5, bottomBgSize.height*0.5)
	bottomBg:addChild(listviewBg)
	-- 兑换列表
	self.listViewSize = cc.size(620, 535)
	self.mListView = ccui.ListView:create()
	self.mListView:setItemsMargin(5)
    self.mListView:setDirection(ccui.ScrollViewDir.vertical)
    self.mListView:setBounceEnabled(true)
    self.mListView:setContentSize(self.listViewSize)
    self.mListView:setPosition(listviewBgSize.width*0.5, listviewBgSize.height*0.5)
    self.mListView:setAnchorPoint(cc.p(0.5, 0.5))
    self.mListView:setChildrenActionType(0)
    listviewBg:addChild(self.mListView)

    -- 刷新列表
    self:requestInfo()
end


--数据处理
function BddExchangeLayer:dataHandle()
    self.mGryTable = {}
    self.mVioletTable = {}
    self.mGreenTable = {}
    self.mRedTable = {}
    self.mGoodTable = {}
    for key,value in ipairs(self.equipData) do
        if value.tabOrder == 1 then
            table.insert(self.mGryTable, value)
        elseif value.tabOrder == 2 then
            table.insert(self.mVioletTable, value)
        elseif value.tabOrder == 3 then
            table.insert(self.mGreenTable, value)
        elseif value.tabOrder == 4 then
            table.insert(self.mRedTable, value)
        elseif value.tabOrder == 5 then
            table.insert(self.mGoodTable, value)
        end
    end
end

-- 刷新兑换列表列表
function BddExchangeLayer:refreshEqList(tag)
    -- 下面总节点
    if self.bottomNode then
        self.bottomNode:removeFromParent()
        self.bottomNode = nil
    end
    self.bottomNode = cc.Node:create()
    self.mParentLayer:addChild(self.bottomNode)
    -- 下半部分背景图
    local bottomBgSize = cc.size(640, 750)
    local bottomBg = ui.newScale9Sprite("c_19.png", bottomBgSize)
    bottomBg:setAnchorPoint(cc.p(0.5, 0))
    bottomBg:setPosition(320, 0)
    self.bottomNode:addChild(bottomBg)

    -- 青云令背景
    local qingyunBg = ui.newScale9Sprite("c_24.png", cc.size(150, 40))
    qingyunBg:setAnchorPoint(cc.p(0, 0.5))
    qingyunBg:setPosition(150, 683)
    bottomBg:addChild(qingyunBg)

    local resBg = ui.newScale9Sprite("c_24.png", cc.size(150, 40))
    resBg:setAnchorPoint(cc.p(0, 0.5))
    resBg:setPosition(430, 683)
    bottomBg:addChild(resBg)

    local qingyunLable = self:createRes(1124, 0)
    qingyunLable:setAnchorPoint(cc.p(0, 0.5))
    qingyunLable:setPosition(cc.p(-140, qingyunBg:getContentSize().height / 2))
    qingyunBg:addChild(qingyunLable)
    --res
    local resLable = self:createRes(1133, 0)
    resLable:setAnchorPoint(cc.p(0, 0.5))
    resLable:setPosition(cc.p(-140, resBg:getContentSize().height / 2))
    resBg:addChild(resLable)

    -- 列表背景
    local listviewBgSize = cc.size(620, 545)
    local listviewBg = ui.newScale9Sprite("c_17.png", listviewBgSize)
    listviewBg:setPosition(bottomBgSize.width*0.5, bottomBgSize.height*0.5)
    bottomBg:addChild(listviewBg)
    -- 兑换列表
    self.listViewSize = cc.size(620, 535)
    self.mListView = ccui.ListView:create()
    self.mListView:setItemsMargin(5)
    self.mListView:setDirection(ccui.ScrollViewDir.vertical)
    self.mListView:setBounceEnabled(true)
    self.mListView:setContentSize(self.listViewSize)
    self.mListView:setPosition(listviewBgSize.width*0.5, listviewBgSize.height*0.5)
    self.mListView:setAnchorPoint(cc.p(0.5, 0.5))
    self.mListView:setChildrenActionType(0)
    listviewBg:addChild(self.mListView)

    self.mListView:removeAllItems()

    local  itemData = {}
    if tag == 2 then
        itemData = self.mGryTable
    elseif tag == 3 then
        itemData = self.mVioletTable
    elseif tag == 4 then
        itemData = self.mGreenTable
    elseif tag == 5 then
        itemData = self.mRedTable
    elseif tag == 6 then
        itemData = self.mGoodTable
    end

    for i=1, #itemData do
        local item = self:refreshCellEq(i, tag)
        self.mListView:pushBackCustomItem(item)
    end
end

function BddExchangeLayer:createRes(resourcetypeSub, modelId)
    local bgSize = ui.getImageSize("c_24.png")
    -- 用于返回的node
    local retNode = cc.Node:create()
    retNode:setContentSize(bgSize)
    retNode:setIgnoreAnchorPointForPosition(false)
    retNode:setAnchorPoint(cc.p(0.5, 0.5))

    -- 物品图片标识
    local tempStr = Utility.getDaibiImage(resourcetypeSub, modelId)

    -- 物品数量的label
    local textStr = TR("当前%s：{%s}", Utility.getGoodsName(resourcetypeSub, modelId), tempStr)
    local tempLabel = ui.newLabel({
        text = textStr.."0",
        size = 22,
        color = Enums.Color.eBlack,
    })
    tempLabel:setAnchorPoint(cc.p(0, 0.5))
    tempLabel:setPosition(30, bgSize.height / 2)
    retNode:addChild(tempLabel)
    retNode.Label = tempLabel
    local function setLabelStr()
        local tempCount = PlayerAttrObj:getPlayerAttr(resourcetypeSub)
         tempLabel:setString(textStr..Utility.numberWithUnit(tempCount))
    end
    setLabelStr()
    --通知刷新
    local eventName = EventsName.getNameByResType(resourcetypeSub)
    if eventName then
        Notification:registerAutoObserver(tempLabel, setLabelStr, {eventName})
    end

    return retNode
end

-- 找出最少资源
local function getMaxCostInfo(costList)
    -- 获取资源消耗列表中第一项
    local costInfo = clone(costList[1])
    -- 获取玩家拥有的该项资源数量
    local playerCoinNum = Utility.getOwnedGoodsCount(costInfo.resourceTypeSub, costInfo.modelId)
    -- 获取该项资源最多可兑换的道具的数量
    local min = math.floor(playerCoinNum / costInfo.num)
    -- 遍历资源消耗列表获取最多可兑换的道具的数量
    for _, v in pairs(costList) do
        playerCoinNum = Utility.getOwnedGoodsCount(v.resourceTypeSub, v.modelId)
        local tempMin = math.floor(playerCoinNum / v.num)
        if min > tempMin then
            min = tempMin
            costInfo = v
        end
    end
    costInfo.Max = min
    -- 返回可兑换道具数量最少的资源
    return costInfo
end

-- 创建createCellEq
function BddExchangeLayer:refreshCellEq(i, tag)
    local  listData = {}
    if tag == 2 then
        listData = self.mGryTable
    elseif tag == 3 then
        listData = self.mVioletTable
    elseif tag == 4 then
        listData = self.mGreenTable
    elseif tag == 5 then
        listData = self.mRedTable
    elseif tag == 6 then
        listData = self.mGoodTable
    end

    local itemData = listData[i]

    if not itemData then
        return
    end

	-- 创建cell
	local cellSize = cc.size(620, 140)
	local cellItem = self.mListView:getItem(i-1)
    if not cellItem then
        cellItem = ccui.Layout:create()
    end
	cellItem:setContentSize(cellSize)
    cellItem:removeAllChildren()

	-- 背景
	local bgSprite = ui.newScale9Sprite("c_18.png", cc.size(610, 140))
	bgSprite:setPosition(cellSize.width / 2, cellSize.height / 2)
	cellItem:addChild(bgSprite)

    -- 资源消耗列表
    local costModelInfo = Utility.analysisStrResList(itemData.price)
	-- 兑换按钮
	local exchangeBtn = ui.newButton({
			normalImage = "c_28.png",
			text = TR("兑换"),
			fontSize = 24,
			clickAction = function ()
                local id = itemData.ID
                -- 获取可兑换道具数量最少的资源
                local costInfo = getMaxCostInfo(costModelInfo)
                -- 需要兑换的道具
                local goodsInfo = Utility.analysisStrResList(itemData.sellResource)[1]

                local params = {
                    title = TR("兑换"),
                    modelID = goodsInfo.modelId,
                    typeID = goodsInfo.resourceTypeSub,
                    coinList = costModelInfo,
                    maxNum = costInfo.Max == 0 and 1 or costInfo.Max,
                    oKCallBack = function(exchangeCount, layerObj, btnObj)
                        LayerManager.removeLayer(layerObj)
                        local costMerit = exchangeCount * costModelInfo[1].num
                        local costTaoZhuangCoin
                        if #costModelInfo > 1 then
                            costTaoZhuangCoin = exchangeCount*costModelInfo[2].num
                        end
                        if Utility.isResourceEnough(costModelInfo[1].resourceTypeSub, costMerit, true) then
                            if costTaoZhuangCoin then
                                if Utility.isResourceEnough(costModelInfo[2].resourceTypeSub, costTaoZhuangCoin, true) then
                                    self:requestBddEquipExchange(id, exchangeCount, tag)
                                end
                            else
                                self:requestBddEquipExchange(id, exchangeCount, tag)
                            end
                        end
                    end,
                }
                MsgBoxLayer.addEquipExchangeLayer(params)
			end
		})
	exchangeBtn:setPosition(cellSize.width*0.85, cellSize.height*0.4)
	cellItem:addChild(exchangeBtn)

    -- 消耗资源显示的位置
    local costResPosY = cellSize.height - 70
    -- 解析要兑换的道具
    local goodsInfo = Utility.analysisStrResList(itemData.sellResource)[1]
    -- 若该道具是碎片则显示当前拥有数量
    if goodsInfo.resourceTypeSub == ResourcetypeSub.eEquipmentDebris then
        -- 获取现拥有道具数量
        local haveCount = GoodsObj:getCountByModelId(goodsInfo.modelId)
        -- 合成需要的数量
        local needNum = GoodsModel.items[goodsInfo.modelId].maxNum
        -- 显示数量颜色
        local numColor = haveCount < needNum and Enums.Color.eRedH or Enums.Color.eBlackH
        -- 创建拥有数量label
        local haveLabel = ui.newLabel({
            text = string.format("%s%d%s/%d", numColor, haveCount, Enums.Color.eBlackH, needNum),
            color = Enums.Color.eBlack,
            size = 20,
        })
        haveLabel:setAnchorPoint(cc.p(0, 0.5))
        haveLabel:setPosition(150, costResPosY)
        cellItem:addChild(haveLabel)
        -- 消耗资源显示的位置下移
        costResPosY = costResPosY - 30
    end

    costResPosY = costResPosY - 20
    local spaceX, spaceY = 180, 40
    -- 纵坐标是否越界
    if (costResPosY - (#costModelInfo-1)*spaceY) > 0 then
        spaceX = 0
    else
        spaceY = 0
    end

    -- 消耗资源显示
    for i, costInfo in pairs(costModelInfo) do
        -- 获取玩家拥有的该资源
        local playResCoin = Utility.getOwnedGoodsCount(costInfo.resourceTypeSub, costInfo.modelId)
        -- 资源字体颜色
        local resFontColor = playResCoin < costInfo.num and Enums.Color.eRedH or Enums.Color.eBlackH
        -- 获取资源图
        local imageStr = Utility.getDaibiImage(costInfo.resourceTypeSub, costInfo.modelId)
        -- 创建该资源字符串
        local resLable = ui.newLabel({
            text = string.format("{%s} %s%s%s/%d", imageStr,
                resFontColor,
                Utility.numberWithUnit(playResCoin or 0), 
                Enums.Color.eBlackH,
                costInfo.num),
            color = Enums.Color.eBlack,
            size = 22,
        })
        resLable:setAnchorPoint(cc.p(0, 0))
        resLable:setPosition(150+(i-1)*spaceX, costResPosY - (i-1)*spaceY)
        cellItem:addChild(resLable)
        resLable:setScale(0.8)
    end

	-- 条件lable
	local conditionLabel = ui.newLabel({
	      text = TR("需达到：%d级", itemData.needLv),
		  size = 20,
		})
	conditionLabel:setPosition(cellSize.width*0.85, cellSize.height*0.8)
	cellItem:addChild(conditionLabel)
    if self.mPlayerLV >= itemData.needLv then
        conditionLabel:setVisible(false)
    else
        conditionLabel:setVisible(true)
    end

    -- 添加奖励列表
    self:addIndex(cellItem, itemData)
	return cellItem
end


function BddExchangeLayer:addIndex(node, data)
    local propList = Utility.analysisStrResList(data.sellResource)
    --创建奖励列表
    local tempCard = ui.createCardList({
        maxViewWidth = 420,     --显示的最大宽度
        viewHeight = 120,       --显示的高度，默认为120
        space = -20,
        cardShowAttrs = {},
        cardDataList = propList,
        allowClick = true,
        isSwallow = false,
    })

    tempCard:setAnchorPoint(cc.p(0 ,0.5))
    tempCard:setPosition(cc.p(20, node:getContentSize().height / 2 - 10))
    node:addChild(tempCard)

    local cardList = tempCard.getCardNodeList()
    for _, item in ipairs(cardList) do
        local colorLv = Utility.getColorLvByModelId(propList[1].modelId, propList[1].resourceTypeSub)
        local quality = Utility.getQualityByModelId(propList[1].modelId, propList[1].resourceTypeSub)
        local  color = Utility.getQualityColor(quality, colorLv)
        item.mShowAttrControl[CardShowAttr.eName].label:setVisible(false)
        local nameLabel = ui.newLabel({
            text = string.format(" %s%s", color, item.mShowAttrControl[CardShowAttr.eName].label:getString()),
            size = 20,
            outlineColor = Enums.Color.eBlack,
            outlineSize = 2,
            x = item:getContentSize().width + 15,
            y = item:getContentSize().height - 15,
            anchorPoint = cc.p(0, 0.5),

        })
        item:addChild(nameLabel)
        --item:setSwallowTouches(false)
        -- item.mShowAttrControl[CardShowAttr.eName].label:setAnchorPoint(cc.p(0, 0.5))
        -- item.mShowAttrControl[CardShowAttr.eName].label:setPosition(cc.p(tempCard:getContentSize().width, tempCard:getContentSize().height - 40))
    end
end

-- 判断是否达到兑换要求
function BddExchangeLayer:judgeEqCondition(data, tag)
    local needLv = data.needLv
    self.mPlayerLV = PlayerAttrObj:getPlayerAttrByName("Lv")
    if self.mPlayerLV < needLv then
        ui.showFlashView(TR("等级不够"))
        return false
    end
    return true
end

-- 创建cell
--[[
	装备id
	兑换冷却时间
	拥有该兑换装备的数量
]]
function BddExchangeLayer:createCell(id, cdTime, num)
	-- 获取项数据
	local cellData = BddEquipShopRelation.items[id]
	if not cellData then
         return
    end
	-- 创建cell
	local cellSize = cc.size(self.listViewSize.width, 140)
	local cellItem = ccui.Layout:create()
	cellItem:setContentSize(cellSize)

	-- 背景
	local bgSprite = ui.newScale9Sprite("c_18.png", cc.size(610, 140))
	bgSprite:setPosition(cellSize.width*0.5, cellSize.height*0.5)
	cellItem:addChild(bgSprite)

    -- 滑动窗体
    local listSize = cc.size(cellSize.width * 0.62, cellSize.height)
    local listView = ccui.ListView:create()
    listView:setDirection(ccui.ScrollViewDir.horizontal)
    listView:setContentSize(listSize)
    listView:setItemsMargin(5)
    listView:setChildrenActionType(ui.LISTVIEW_ACTION_NONE)
    listView:setSwallowTouches(false)
    listView:setAnchorPoint(cc.p(0, 0.5))
    listView:setPosition(cellSize.width * 0.02, cellSize.height * 0.6)
    cellItem:addChild(listView)

	-- 需要消耗资源
    local function addUseRes(data)
        -- 创建cell
        local item = ccui.Layout:create()
        local itemSize = cc.size(110, listSize.height * 0.9)
        item:setContentSize(itemSize)

        -- 若是装备
        if math.floor(data.resourceTypeSub / 100) == Resourcetype.eEquipment then
            data.needGray = not self:isHaveEquip(data.modelId)
        end
        -- 创建卡片
        local useEquipCard = CardNode.createCardNode(data)
        useEquipCard:setAnchorPoint(cc.p(0.5, 0.5))
        useEquipCard:setPosition(itemSize.width*0.5, itemSize.height*0.5)

        item:addChild(useEquipCard)

        return item
    end
    -- 中间的箭头
    local function addArrowItem()
        local width, height = 20, listSize.height * 0.9

        local layout = ccui.Layout:create()
        layout:setContentSize(cc.size(width, height))

        local arrow = ui.newSprite("jc_15.png")
        arrow:setPosition(width * 0.5, height * 0.5)
        layout:addChild(arrow)

        return layout
    end
    -- 兑换的装备
    local function addGetRes(data)
        -- 创建cell
        local item = ccui.Layout:create()
        local itemSize = cc.size(110, listSize.height * 0.9)
        item:setContentSize(itemSize)
        -- 创建卡片
        local useEquipCard = CardNode.createCardNode(data)
        useEquipCard:setAnchorPoint(cc.p(0.5, 0.5))
        useEquipCard:setPosition(itemSize.width*0.5, itemSize.height*0.5)

        item:addChild(useEquipCard)

        return item
    end

	local useList = Utility.analysisStrResList(cellData.useEquip)
    for i=1,#useList do
        listView:pushBackCustomItem(addUseRes(useList[i]))
    end
	-- 消耗存入数组
	self.useEquipList[id] = useList

    listView:pushBackCustomItem(addArrowItem())

	-- 装备
	resourceList = Utility.analysisStrResList(cellData.outResource)
    for i = 1, #resourceList do
	   listView:pushBackCustomItem(addGetRes(resourceList[i]))
    end

	-- 兑换按钮
	local exchangeBtn = ui.newButton({
			normalImage = "c_28.png",
			text = TR("兑换"),
			fontSize = 24,
			clickAction = function ()
				self:requestExchange(id, num)
			end
		})
	exchangeBtn:setPosition(cellSize.width*0.82, cellSize.height*0.5)
	cellItem:addChild(exchangeBtn)

	-- 等级条件lable
    local playLv = PlayerAttrObj:getPlayerAttrByName("Lv")
    local temText = TR("需达到:等级%d", cellData.needLv)
    if playLv < cellData.needLv then
        temText = TR("需达到:等级%s%d", Enums.Color.eRedH, cellData.needLv)
    end
	local lvConditionLabel = ui.newLabel({
			text = temText,
            color = cc.c3b(0x46, 0x22, 0x0d),
			size = 20,
		})
    lvConditionLabel:setAnchorPoint(cc.p(0, 0.5))
	lvConditionLabel:setPosition(cellSize.width*0.66, cellSize.height*0.8+5)
	cellItem:addChild(lvConditionLabel)
    -- 星数条件
    local temText = string.format("{c_75.png}%d", cellData.highStarsNum)
    if self.historyMaxNum < cellData.highStarsNum then
        temText = string.format("{c_75.png}%s%d", Enums.Color.eRedH, cellData.highStarsNum)
    end
    local starNumCondition = ui.newLabel({
            text = temText,
            color = cc.c3b(0x46, 0x22, 0x0d),
            size = 20,
        })
    starNumCondition:setAnchorPoint(cc.p(0, 0.5))
    starNumCondition:setPosition(cellSize.width*0.88, cellSize.height*0.8+5)
    cellItem:addChild(starNumCondition)

	-- 冷却时间
	local cdTimeLable = ui.newLabel({
			text = "",
			color = cc.c3b(0x46, 0x22, 0x0d),
			size = 20
		})
	cdTimeLable:setPosition(cellSize.width*0.82, cellSize.height*0.2)
	cellItem:addChild(cdTimeLable)
	--定时更新倒计时
    Utility.schedule(cdTimeLable, function()
        local lastTime = cdTime - Player:getCurrentTime()
        if lastTime > 0 then
            cdTimeLable:setString(TR("冷却时间：%s", MqTime.formatAsHour(lastTime)))
            exchangeBtn:setEnabled(false)
        else
        	exchangeBtn:setEnabled(true)
        end
    end, 1.0)

	return cellItem
end

-- 获取玩家是否有该装备
function BddExchangeLayer:isHaveEquip(modelId)
    local haveEquipList = EquipObj:findByModelId(modelId)
    if next(haveEquipList) then
        return true
    end
    return false
end

-- 刷新兑换列表列表
function BddExchangeLayer:refreshList()
    -- 移除所有项
    self.mListView:removeAllItems()

	-- 填入
	for _,v in pairs(self.equipShopInfo) do
        local equipInfo = BddEquipShopRelation.items[v.Id]
		if v.Num < equipInfo.totalMaxNum and (equipInfo.highStarsNum < 204 or (equipInfo.highStarsNum > 204 and self.historyMaxNum >= 204)) then
			local item = self:createCell(v.Id, v.CdTime, v.Num)
			if item then
				self.mListView:pushBackCustomItem(item)
			end
		end
	end
end

-----------------服务器相关----------------
-- 请求当前兑换信息
function BddExchangeLayer:requestInfo()
	HttpClient:request({
        moduleName = "BddInfo",
        methodName = "EquipShopInfo",
        svrMethodData = {},
        callback = function(response)
            if response.Status ~= 0 then return end

            self.equipShopInfo = response.Value.EquipShopInfo
            -- 刷新兑换列表列表
            self:refreshList()
        end
    })
end

-- 判断是否达到兑换要求
function BddExchangeLayer:judgeCondition(equipId, num)

	local equipData = BddEquipShopRelation.items[equipId]

	if self.historyMaxNum < equipData.highStarsNum then
		return TR("你的最高星数还未达到要求")
	elseif PlayerAttrObj:getPlayerAttrByName("Lv") < equipData.needLv then
		return TR("你的等级还未达到要求")
	elseif num >= equipData.totalMaxNum then
		return TR("你已达到最大限购量")
	end

	return nil
end

-- 获取消耗列表
function BddExchangeLayer:getUseEquip(equipId)
    -- 消耗装备实体ID列表
    local useEquipList = {}
    -- 消耗列表
    local useList = self.useEquipList[equipId]
    --
    for _, value in pairs(useList) do
        local modelId = value.modelId
        local equipStarNum = BddEquipShopRelation.items[equipId].equipStarNum

        if modelId ~= 0 then
            local equipRealId = nil
            local equipList = EquipObj:getEquipList({notInFormation = true})
            for _, v in pairs(equipList) do
                if v.ModelId == modelId and v.Lv == 0 then
                    equipRealId = v.Id
                    break
                end
            end
            if equipRealId then
                table.insert(useEquipList, equipRealId)
            else
                ui.showFlashView(TR("需要非上阵0级的%s", EquipModel.items[modelId].name))
                return nil
            end
        else
            local resNum = Utility.getOwnedGoodsCount(value.resourceTypeSub, value.modelId)
            local resName = Utility.getGoodsName(value.resourceTypeSub, value.modelId)
            if not Utility.isResourceEnough(value.resourceTypeSub, value.num) then
                -- ui.showFlashView(TR("需要%d%s", value.num, resName))
                return nil
            end
        end
    end

	return useEquipList
end

-----------------服务器相关----------------
-- 请求比武招亲数据（最高星数）
function BddExchangeLayer:requestBddData()
	HttpClient:request({
        moduleName = "BddInfo",
        methodName = "Info",
        svrMethodData = {},
        callback = function(response)
            if response.Status ~= 0 then
                LayerManager.removeLayer(self)
                return
            end
            -- 更新数据
            self.mFloorData = response.Value
            -- 最高星数
            self.historyMaxNum = self.mFloorData.Info.MaxStarCount

            -- 初始化界面
			self:initUI()
        end
    })
end

-- 兑换
--[[
	装备id
	玩家拥有的装备实体id列表
	拥有该兑换装备的数量
]]
function BddExchangeLayer:requestExchange(equipId, num)
	local condition = self:judgeCondition(equipId, num)
	if condition ~= nil then
		ui.showFlashView({text = condition})
		return
	end
	-- 获取消耗列表
	local useList = self:getUseEquip(equipId)
	if useList == nil then
		return
	end

	HttpClient:request({
        moduleName = "BddInfo",
        methodName = "EquipShopExchange",
        svrMethodData = {equipId, useList},
        callback = function(response)
            if response.Status ~= 0 then return end
            self.equipShopInfo = response.Value.EquipShopInfo
            self.mFloorData.Info = response.Value.Info
            -- 刷新兑换列表列表
            self:refreshList()
            -- 显示兑换奖励
            ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)
            -- 删除消耗的装备
            EquipObj:deleteEquipById(useList[1])
        end
    })
end


-- 请求当前兑换信息
function BddExchangeLayer:requestBddEquipExchange(moldId, propNum, tag)
	HttpClient:request({
        moduleName = "BddEquipExchangeInfo",
        methodName = "Exchange",
        svrMethodData = {moldId, propNum},
        callback = function(response)
            if not response or response.Status ~= 0 then
                 return
            end
            ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)

            for i, _ in ipairs(self.mListView:getItems()) do
                self:refreshCellEq(i, tag)
            end
        end
    })
end



return BddExchangeLayer
