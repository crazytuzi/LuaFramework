--[[
    文件名: SlotDetailPrLayer.lua
    描述：队伍卡槽人物羁绊详细信息展示页面
    创建人: peiyaoqiang
    创建时间: 2017.03.08
--]]

local SlotDetailPrLayer = class("SlotDetailPrLayer", function(params)
	return display.newLayer()
end)

--[[
-- 参数 params 中的各项为：
	{
		showSlotId: 当前显示的阵容卡槽Id
	    formationObj: 阵容数据对象
	}
]]
function SlotDetailPrLayer:ctor(params)
    -- 当前显示的阵容卡槽Id
    self.mShowSlotId = params.showSlotId or 1
    -- 阵容数据对象
    self.mFormationObj = params.formationObj
    -- 获取卡槽信息
    self.mCurrentSlotInfo = self.mFormationObj:getSlotInfoBySlotId(self.mShowSlotId)
    self.mCurrentHeroData = HeroObj:getHero(self.mCurrentSlotInfo.HeroId)
    -- 获取当前卡槽的羁绊信息
    self.mSlotPrInfo = self.mFormationObj:getSlotPrInfo(self.mShowSlotId, false)
    
    -- 添加弹出框层
    local bgLayer = require("commonLayer.PopBgLayer").new({
        title = TR("缘分羁绊"),
        bgSize = cc.size(594, 868),
        closeAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self:addChild(bgLayer)

    -- 保存弹框控件信息
    self.mBgSprite = bgLayer.mBgSprite
    self.mBgSize = bgLayer.mBgSprite:getContentSize()
    self.mCloseButton = bgLayer.mCloseButton
    self.mCloseButton:setLocalZOrder(1)
    -- 保存缘分按钮
    self.mCellBtn = {}
    -- 当前选中缘分,初始为第一个
    self.mCurrentIndex = 1 
    -- 当前缘分获取途径，初始为第一个缘分的途径
    self.mAccessInfo = {}
    for _, info in pairs(self.mSlotPrInfo[1].memberList) do
        table.insert(self.mAccessInfo, info)
    end
    -- 初始化页面控件
    self:initUI()
end

-- 初始化页面控件
function SlotDetailPrLayer:initUI()
    -- 人物头像
    local headSprite = require("common.CardNode").new({allowClick = false})
    local showAttrs = {CardShowAttr.eBorder}
    headSprite:setHero({ModelId = self.mCurrentSlotInfo.ModelId, FashionModelID = PlayerAttrObj:getPlayerAttrByName("FashionModelId"), IllusionModelId = self.mCurrentHeroData.IllusionModelId}, showAttrs)
    headSprite:setAnchorPoint(0.5, 1)
    headSprite:setPosition(self.mBgSize.width * 0.5, self.mBgSize.height - 80)
    self.mBgSprite:addChild(headSprite)
    
    -- 人物名字
    local tmpName, _ = ConfigFunc:getHeroName(self.mCurrentSlotInfo.ModelId, {IllusionModelId = self.mCurrentHeroData.IllusionModelId, heroFashionId = self.mCurrentHeroData.CombatFashionOrder})
    local nameLabel = ui.newLabel({
        text = TR("%s的缘分羁绊", tmpName),
        size = 24, 
        color = cc.c3b(0x46, 0x22, 0x0d),
        anchorPoint = cc.p(0.5, 1),
        x = self.mBgSize.width * 0.5,
        y = self.mBgSize.height - 185,
    })
    self.mBgSprite:addChild(nameLabel)

    -- 列表背景
    local imageBgSize = cc.size(518 , 356)
    local imageBgSprite = ui.newScale9Sprite("c_17.png", imageBgSize)
    imageBgSprite:setAnchorPoint(0.5, 1)
    imageBgSprite:setPosition(self.mBgSize.width * 0.5, self.mBgSize.height - 220)
    self.mBgSprite:addChild(imageBgSprite)

    -- 获取途径背景
    local accessBgSize = cc.size(518, 240)
    local accessBgSprite = ui.newScale9Sprite("c_37.png", accessBgSize)
    accessBgSprite:setAnchorPoint(0.5, 0)
    accessBgSprite:setPosition(self.mBgSize.width * 0.5, 40)
    self.mBgSprite:addChild(accessBgSprite)

    local imageBgSprite1 = ui.newScale9Sprite("c_17.png", cc.size(500, 190))
    imageBgSprite1:setPosition(259, 105)
    accessBgSprite:addChild(imageBgSprite1)

    local accessLabel = ui.newLabel({
        text = TR("获取途径"),
        size = 24,
        color = Enums.Color.eWhite,
        outlineColor = cc.c3b(0x47, 0x50, 0x54),
        outlineSize = 2,
    })
    accessLabel:setPosition(accessBgSize.width / 2, accessBgSize.height - 20)
    accessBgSprite:addChild(accessLabel)

    -- 创建羁绊信息表
    self.mSlotPrListView = ccui.ListView:create()
    self.mSlotPrListView:setContentSize(cc.size(imageBgSize.width - 10, imageBgSize.height - 10))
    self.mSlotPrListView:setItemsMargin(10)
    self.mSlotPrListView:setDirection(ccui.ListViewDirection.vertical)
    self.mSlotPrListView:setGravity(ccui.ListViewGravity.centerHorizontal)
    self.mSlotPrListView:setBounceEnabled(true)
    self.mSlotPrListView:setAnchorPoint(cc.p(0.5, 0))
    self.mSlotPrListView:setPosition(cc.p(imageBgSize.width * 0.5, 5))
    self.mSlotPrListView:setChildrenActionType(ui.LISTVIEW_ACTION_NONE)
    imageBgSprite:addChild(self.mSlotPrListView)
    -- 单个条目的大小
    self.mCellSize = cc.size(imageBgSize.width - 20, 130)
    -- 刷新listView
    self:refreshPrListView()

    -- 创建获取途径表
    self.mAccessListView = ccui.ListView:create()
    self.mAccessListView:setContentSize(cc.size(accessBgSize.width - 10, accessBgSize.height - 60))
    self.mAccessListView:setItemsMargin(10)
    self.mAccessListView:setDirection(ccui.ListViewDirection.vertical)
    self.mAccessListView:setGravity(ccui.ListViewGravity.centerHorizontal)
    self.mAccessListView:setBounceEnabled(true)
    self.mAccessListView:setAnchorPoint(cc.p(0.5, 0))
    self.mAccessListView:setPosition(cc.p(imageBgSize.width * 0.5, 15))
    self.mAccessListView:setChildrenActionType(ui.LISTVIEW_ACTION_NONE)
    accessBgSprite:addChild(self.mAccessListView)
    -- 单个条目大小
    local cellSize = cc.size(accessBgSize.width - 30, 130)
    self.mAccessCellSize = cellSize
    self:refreshAccessListView(cellSize)
end

function SlotDetailPrLayer:refreshPrListView()
    for index = 1, math.ceil(#self.mSlotPrInfo / 2) do
        local lvItem = ccui.Layout:create()
        lvItem:setContentSize(self.mCellSize)
        self.mSlotPrListView:pushBackCustomItem(lvItem)

        self:refreshPrListItem(index)
    end
end

function SlotDetailPrLayer:refreshPrListItem(index)
    local lvItem = self.mSlotPrListView:getItem(index - 1)
    local cellSize = self.mCellSize

    if nil == lvItem then
        lvItem = ccui.Layout:create()
        lvItem:setContentSize(cellSize)
        self.mSlotPrListView:insertCustomItem(lvItem, index - 1)
    end  
    lvItem:removeAllChildren()

    -- 创建lvItem的子结点 
    for idx = index * 2 - 1, index * 2 do
        if idx > #self.mSlotPrInfo then
            return
        end 

        local tmpItem = self.mSlotPrInfo[idx]
        -- 是否是奇数
        local isOdd = (idx % 2 == 1) 

        local cellBgSpritePath = nil
        local haveSlotPrPath = nil
        if tmpItem.havePr then
            cellBgSpritePath = "c_54.png"
            haveSlotPrPath = "c_58.png"
        else
            cellBgSpritePath = "c_37.png"
        end

        local cellBgSize = cc.size(250, 130)
        -- 背景按钮
        local cellBgSprite = ui.newButton({
            normalImage = cellBgSpritePath,
            size = cellBgSize,
            clickAction = function()
                for i, obj in ipairs(self.mCellBtn) do 
                    if idx == i then
                        if self.mCurrentIndex == idx then
                            return
                        end
                        self.mCurrentIndex = idx
                        self.mCellBtn[i]:getChildByName("select"):setVisible(true)
                        -- 更新获取途径表
                        self.mAccessInfo = {}
                        for _, info in pairs(tmpItem.memberList) do
                            table.insert(self.mAccessInfo, info)
                        end
                        -- 刷新获取途径ListView
                        self:refreshAccessListView(self.mAccessCellSize)
                    else
                        self.mCellBtn[i]:getChildByName("select"):setVisible(false)
                    end
                end
            end
        })
        cellBgSprite:setPressedActionEnabled(false)
        -- 保存缘分按钮
        table.insert(self.mCellBtn, cellBgSprite)

        if isOdd then
            cellBgSprite:setAnchorPoint(1, 0.5)
            cellBgSprite:setPosition(cellSize.width * 0.5 - 2, cellSize.height * 0.5)
        else
            cellBgSprite:setAnchorPoint(0, 0.5)
            cellBgSprite:setPosition(cellSize.width * 0.5 + 2, cellSize.height * 0.5)
        end

        -- 已羁绊标识
        if haveSlotPrPath then
            local tempSprite = ui.createStrImgMark(haveSlotPrPath, TR("已羁绊"), Enums.Color.eWhite)
            tempSprite:setAnchorPoint(cc.p(0, 1))
            tempSprite:setPosition(2, cellSize.height - 5)
            cellBgSprite:addChild(tempSprite, 1)
        end

        -- 选中框
        local selectedBox = ui.newScale9Sprite("c_31.png", cc.size(cellBgSize.width * 1.05, cellBgSize.height * 1.1))
        selectedBox:setPosition(cellBgSize.width * 0.5, cellBgSize.height * 0.5)
        cellBgSprite:addChild(selectedBox)
        selectedBox:setVisible(false)
        selectedBox:setName("select")
        if idx == self.mCurrentIndex then
            selectedBox:setVisible(true)
        end

        -- 羁绊名称
        local prName = ui.newLabel({
            text = tmpItem.prName,
            color = Enums.Color.eWhite,
            size = 22,
            outlineColor = cc.c3b(0x8d, 0x4b, 0x3b),
            outlineSize = 2,
        })
        prName:setAnchorPoint(cc.p(0.5, 1))
        prName:setPosition(cellBgSize.width * 0.5, cellBgSize.height - 6)
        cellBgSprite:addChild(prName)

        -- 羁绊描述
        local strIntro = tmpItem.prIntro
        local prTips = ui.newLabel({
            text = strIntro,
            color = Enums.Color.ePrColor,
            size = string.utf8len(strIntro) > 60 and 19 or 20,
            anchorPoint = cc.p(0, 1),
            x = 10,
            y = cellBgSize.height - 50,
            dimensions = cc.size(cellBgSize.width - 30, 0),
            valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP
        })
        cellBgSprite:addChild(prTips)

        lvItem:addChild(cellBgSprite)
    end
end

function SlotDetailPrLayer:refreshAccessListView(size)
    self.mAccessListView:removeAllItems()
    for index = 1, #self.mAccessInfo do
        local lvItem = ccui.Layout:create()
        lvItem:setContentSize(size)
        self.mAccessListView:pushBackCustomItem(lvItem)

        self:refreshAccessListItem(index, size)
    end
end

function SlotDetailPrLayer:refreshAccessListItem(index, size)
    local lvItem = self.mAccessListView:getItem(index - 1)
    local cellSize = size

    if nil == lvItem then
        lvItem = ccui.Layout:create()
        lvItem:setContentSize(cellSize)
        self.mAccessListView:insertCustomItem(lvItem, index - 1)
    end  
    lvItem:removeAllChildren()
  
    local resType = self.mAccessInfo[index].resourcetypeSub
    local modelId = self.mAccessInfo[index].modelId

    -- 显示背景
    local backBgSprite = ui.newScale9Sprite("c_18.png", cc.size(cellSize.width, cellSize.height))
    backBgSprite:setAnchorPoint(cc.p(0.5, 0.5))
    backBgSprite:setPosition(cellSize.width * 0.5, cellSize.height * 0.5)
    lvItem:addChild(backBgSprite)

    -- 创建Item的子结点
    local showAttrs = {CardShowAttr.eBorder, CardShowAttr.eName}
    local accessNode = require("common.CardNode").new()
    accessNode:setCardData({resourceTypeSub = resType, modelId = modelId, cardShowAttrs = showAttrs})
    accessNode:setAnchorPoint(0, 0.5)
    accessNode:setPosition(30, cellSize.height * 0.5 + 12)
    lvItem:addChild(accessNode)

    -- 是否拥有
    if self.mAccessInfo[index].palyerHave then
        local haveSprite = ui.newSprite("c_74.png")
        haveSprite:setAnchorPoint(0.5, 0.5)
        haveSprite:setPosition(440, cellSize.height * 0.5)
        lvItem:addChild(haveSprite)

        local haveLabel = ui.newLabel({
            text = Utility.isHero(resType) and TR("已上阵") or TR("已装备"),
            color = cc.c3b(0x46, 0x22, 0x0d),
            anchorPoint = cc.p(0.5, 0.5),
            x = haveSprite:getContentSize().width * 0.5,
            y = haveSprite:getContentSize().height * 0.5
        })
        haveSprite:addChild(haveLabel)
        haveLabel:setRotation(-17)
    else
        -- 获取
        local getSprite = ui.newSprite("c_67.png")
        getSprite:setAnchorPoint(0.5, 0.5)
        getSprite:setPosition(cellSize.width * 0.35, cellSize.height * 0.5 + 10)
        lvItem:addChild(getSprite)

        -- 获取途径信息表
        local function refreshAccess(dropWaysData)
            if #dropWaysData >= 2 then
                local posY = 35
                for i = 1, 2 do
                    if i == 2 then
                        posY = -25
                    end
                    local nameLabel = ui.newLabel({
                        text = dropWaysData[i].moduleName,
                        color = cc.c3b(0x46, 0x22, 0x0d),
                        size = 24,
                        anchorPoint = cc.p(0, 0.5),
                        x = 230,
                        y = cellSize.height * 0.5 + posY
                    })
                    lvItem:addChild(nameLabel)

                    --前往按钮
                    local playerGoBtn = ui.newButton({
                        normalImage = "c_28.png",
                        text = TR("前往"),
                        anchorPoint = cc.p(1, 0.5),
                        position = cc.p(cellSize.width - 5, cellSize.height * 0.5 + posY),
                        clickAction = function()
                            LayerManager.showSubModule(dropWaysData[i].moduleID)
                        end,
                    })
                    lvItem:addChild(playerGoBtn)                
                end
            elseif #dropWaysData == 1 then    
                local nameLabel = ui.newLabel({
                    text = dropWaysData[1].moduleName,
                    color = cc.c3b(0x46, 0x22, 0x0d),
                    size = 24,
                    anchorPoint = cc.p(0, 0.5),
                    x = 230,
                    y = cellSize.height * 0.5 + 5
                })
                lvItem:addChild(nameLabel)

                --前往按钮
                local playerGoBtn = ui.newButton({
                    normalImage = "c_28.png",
                    text = TR("前往"),
                    anchorPoint = cc.p(1, 0.5),
                    position = cc.p(cellSize.width - 5, cellSize.height * 0.5 + 5),
                    clickAction = function()
                        LayerManager.showSubModule(dropWaysData[1].moduleID)
                    end,
                })
                lvItem:addChild(playerGoBtn)
            elseif #dropWaysData <= 0 then 
                local tipsLabel = ui.newLabel({
                    text = TR("活动产出"),
                   color = cc.c3b(0x46, 0x22, 0x0d),
                    size = 24,
                    anchorPoint = cc.p(0, 0.5),
                    x = 280,
                    y = cellSize.height * 0.5 + 5,
                })
                lvItem:addChild(tipsLabel)
            end
        end

        Utility.getResourceDropWay(resType, modelId, function(info)
            refreshAccess(info)
        end)
    end
end

return SlotDetailPrLayer

