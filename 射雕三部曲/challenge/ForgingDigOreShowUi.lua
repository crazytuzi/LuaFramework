--[[
    文件名: ForgingDigOreShowUi.lua
    创建人: lichunsheng
    创建时间: 2017-07-13
    描述: 扫荡页面结果展示页面
--]]

local ForgingDigOreShowUi = class("ForgingDigOreShowUi", function(params)
    return display.newLayer()
end)

--[[
    参数:
    {
        dropBaseInfo,  -- 奖励列表, 网络请求返回的 response
        parentLayer,      --回调，用于删除挖矿layer
        needore,       --已经拥有的矿石
        ctCount，   --发给服务器的采集次数
        pageType  --页面类型（可选）1一键采矿
        name    --矿石名字
        quality --品质外框
    }
--]]
function ForgingDigOreShowUi:ctor(params)

    self.mOreName = params.name
    self.mQuality = params.quality

    self.mOreFrame = ""
    if self.mQuality == 3 then
        self.mOreFrame = "c_05.png"
    elseif self.mQuality == 6 then
        self.mOreFrame = "c_06.png"
    elseif self.mQuality == 8 then
        self.mOreFrame = "c_07.png"
    elseif self.mQuality == 10 then
        self.mOreFrame = "c_07.png"
    elseif self.mQuality == 13 then
        self.mOreFrame = "c_08.png"
    elseif self.mQuality == 16 then
        self.mOreFrame = "c_08.png"
    elseif self.mQuality == 18 then
        self.mOreFrame = "c_09.png"
    end

    -- 获得的物品列表
    self.mDropBaseInfo = params.dropBaseInfo
	self.mRewardInfo = params.dropBaseInfo.RewardInfo
    self.mLayer = params.parentLayer
    self.mNeedore = params.needore
    self.mCtCount = params.ctCount
    self.mPageType = params.pageType or 0
    self.mDropData = {}
    for i,v in pairs(self.mRewardInfo) do
        table.insert(self.mDropData, v)
    end
    self.mBaseRes = params.dropBaseInfo.BaseGetGameResourceList
	-- 列表中每个条目的大小
    self.mListCellSize = cc.size(564, 200)

    -- 添加弹出框层
    local bgLayer = require("commonLayer.PopBgLayer").new({
        title = TR("挖矿报告"),
        bgSize = cc.size(640, 944),
        closeImg = "",
        closeAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self:addChild(bgLayer)

    -- 保存弹窗控件信息
    self.mBgSprite = bgLayer.mBgSprite
    self.mBgSize = bgLayer.mBgSprite:getContentSize()

    -- 显示中间背景
    local tmpBgSprite = ui.newScale9Sprite("c_17.png", cc.size(576, 770))
    tmpBgSprite:setAnchorPoint(cc.p(0.5, 0))
    tmpBgSprite:setPosition(self.mBgSize.width * 0.5, 100)
    self.mBgSprite:addChild(tmpBgSprite)

    -- 动作助手
    -- 初始化页面控件
    self:initUI(params.pageType)
end

-- 初始化页面控件
function ForgingDigOreShowUi:initUI(pageType)
    --创建列表
    self.mListView = ccui.ListView:create()
    self.mListView:setContentSize(cc.size(self.mListCellSize.width, 750))
    self.mListView:setItemsMargin(10)
    self.mListView:setDirection(ccui.ListViewDirection.vertical)
    self.mListView:setBounceEnabled(true)
    self.mListView:setAnchorPoint(cc.p(0.5, 0))
    self.mListView:setPosition(self.mBgSize.width * 0.5, 110)
    self.mBgSprite:addChild(self.mListView)
    self.mListView:setEnabled(false)

    self.mConfirmButton = ui.newButton({
        normalImage = "c_28.png",
        text = TR("完成"),
        position = cc.p(self.mBgSize.width / 2, 60),
        clickAction = function()
            if pageType == 1 then
                LayerManager.removeLayer(self)
            elseif pageType == 0 then
                if self.mOreNum >= self.mNeedore then
                    if self.mLayer then
                        LayerManager.removeLayer(self.mLayer)
                    end
                else
                    LayerManager.removeLayer(self)
                end
            end

        end
    })
    self.mBgSprite:addChild(self.mConfirmButton)

    if self.mPageType == 1 then
        self.mConfirmButton:setVisible(false)
    elseif self.mPageType == 0 then
        self.mConfirmButton:setVisible(false)
    end

    -- 刷新内容
    self:refreshListView()
end

-- 获取恢复数据
function ForgingDigOreShowUi:getRestoreData()
    local retData = {
    	dropBaseInfo = self.mDropBaseInfo,
    }
    return retData
end

-- 刷新
function ForgingDigOreShowUi:refreshListView()
    self.mListView:removeAllChildren()
    self.mOreNum = 0
	for index = 1, table.nums(self.mRewardInfo) do
        local lvItem = ccui.Layout:create()
        lvItem:setAnchorPoint(cc.p(0.5, 0.5))
        lvItem:setIgnoreAnchorPointForPosition(false)
        lvItem:setContentSize(self.mListCellSize)
        self.mListView:pushBackCustomItem(lvItem)

        self:refreshListViewItem(index)

        -- 设置动画效果
        self.mListView:forceDoLayout()
    end


	local innerNode = self.mListView:getInnerContainer()
	local listSize = self.mListView:getContentSize()
	local innerHeight = table.nums(self.mRewardInfo) * (self.mListCellSize.height + 10) - 10
	for index = 1, table.nums(self.mRewardInfo) do
		local tempNode = self.mListView:getItem(index - 1)
		tempNode:setVisible(false)
		tempNode:setScale(1.3)
        local actionList = {
        	cc.DelayTime:create((index - 1) * 0.5),
        	cc.CallFunc:create(function()
        		-- 如果条目没在显示区域内，这需要设置Inner的位置
        		local tempHeight = index * (self.mListCellSize.height + 10) - 10
        		local offSetY = tempHeight - listSize.height
        		if offSetY > 0 then
        			innerNode:setPositionY(listSize.height - innerHeight + offSetY)
        		end

        		tempNode:setVisible(true)
        	end),
            cc.ScaleTo:create(1/30 * 7, 0.9),
            cc.ScaleTo:create(1/30 * 2, 1.0),
            cc.CallFunc:create(function()
                local isNeedUp = index == table.nums(self.mRewardInfo)
                self.mOreNum = self.mOreNum + self.mDropBaseInfo.GetExpInfo[index].GetExp
                if self.mNeedore and self.mOreNum and self.mOreNum >= self.mNeedore
                    or self.mDropBaseInfo.GetExpInfo[index].Count == 10
                    or self.mDropBaseInfo.GetExpInfo[index].Count == self.mCtCount then
                    self.mConfirmButton:setVisible(true)
                end

                if self.mDropBaseInfo.GetExpInfo[index].Count == self.mCtCount then
                    self.mListView:setEnabled(true)
                end
                -- 检查是否升级
                if isNeedUp then
                    PlayerAttrObj:showUpdateLayer()
                end
            end)
        }
        tempNode:runAction(cc.Sequence:create(actionList))
	end
end

-- 刷新扫荡节点信息中的一个条目
function ForgingDigOreShowUi:refreshListViewItem(index)
	local lvItem = self.mListView:getItem(index - 1)
    if not lvItem then
        lvItem = ccui.Layout:create()
        lvItem:setContentSize(self.mListCellSize)
        self.mListView:insertCustomItem(lvItem, index - 1)
    end
    lvItem:removeAllChildren()

    local list = {}
    table.sort(self.mDropData[1], function(item1, item2)
        -- 比较品质
        local colorLv1 = Utility.getColorLvByModelId(item1.modelId, item1.resourceTypeSub)
        local colorLv2 = Utility.getColorLvByModelId(item2.modelId, item2.resourceTypeSub)
        if colorLv1 ~= colorLv2 then
            return colorLv1 > colorLv2
        end

        return (item1.modelId or 0) > (item2.modelId or 0)
    end)

    for key,value in pairs(self.mDropData[1]) do
        if value.ResourceTypeSub ==ResourcetypeSub.eGold or value.ResourceTypeSub ==ResourcetypeSub.eEXP or value.ResourceTypeSub ==ResourcetypeSub.eHeroExp then
            table.insert(list, value)
        end
    end
    table.insert(list, {Count = -2,ResourceTypeSub = 1103,ModelId = 0})


    -- 条目的背景
    local cellBgSprite = ui.newScale9Sprite("c_54.png", self.mListCellSize)
    cellBgSprite:setPosition(self.mListCellSize.width / 2, self.mListCellSize.height / 2)
    lvItem:addChild(cellBgSprite)


    -- 标题
    local titleLabel = ui.newLabel({
        text = TR("第%d次挖矿", index),
        size = 24,
        color = cc.c3b(0xfa, 0xf6, 0xf1),
        outlineColor = cc.c3b(0x8d, 0x4b, 0x3b),
        outlineSize = 2,
    })
    titleLabel:setPosition(self.mListCellSize.width / 2, self.mListCellSize.height - 22)
    cellBgSprite:addChild(titleLabel)

    -- 显示玩家获得属性
    local yPosList = {130, 80, 30}
    for attrIndex, item in ipairs(list) do
        local daibiBgSprite = ui.newScale9Sprite("c_24.png", cc.size(150, 38))
        daibiBgSprite:setAnchorPoint(cc.p(0, 0.5))
        daibiBgSprite:setPosition(cc.p(30, yPosList[attrIndex]))
        cellBgSprite:addChild(daibiBgSprite)

        local tempNode = ui.newSprite(Utility.getResTypeSubImage(item.ResourceTypeSub))
        tempNode:setAnchorPoint(cc.p(0, 0.5))
        tempNode:setPosition(20, yPosList[attrIndex])
        cellBgSprite:addChild(tempNode)

        local retLabel = ui.newLabel({
            text = item.Count,
            size = 22,
            color = cc.c3b(0x46, 0x22, 0x0d),
        })
        retLabel:setAnchorPoint(cc.p(0, 0.5))
        retLabel:setPosition(50, 19)
        daibiBgSprite:addChild(retLabel)
    end


    -- 显示其他掉落物品
    if (self.mRewardInfo ~= nil) and (table.nums(self.mRewardInfo) > 0) then
        --翻牌奖励
        local choiceTable = {}
        local oreData = {
            imgName = self.mOreFrame,
            extraImgName = "dz_16.png",
            num = self.mDropBaseInfo.GetExpInfo[index].GetExp,
            cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum},
            onClickCallback = function()
               LayerManager.addLayer({
                   name = "commonLayer.MsgBoxLayer",
                   cleanUp = false,
                   data = {
                       title = TR("物品详情"),
                       bgSize = cc.size(572, 380),
                       DIYUiCallback = function(root, bgSprite, bgSize)
                           local tips = ui.newLabel({
                               text = TR("用于合成神兵"),
                               align = ui.TEXT_ALIGN_CENTER,
                               dimensions = cc.size(bgSize.width - 50, 200),
                           })
                           tips:setPosition(bgSize.width / 2, bgSize.height / 2 - 35)
                           bgSprite:addChild(tips)

                           local card = CardNode:create({})
                           card:setPosition(bgSize.width / 2, bgSize.height / 2 + 60)
                           card:setCardData({
                               imgName = self.mOreFrame,
                               extraImgName = "dz_16.png",
                               cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eName},
                           })
                           card.mShowAttrControl[CardShowAttr.eName].label:setVisible(false)
                           card:setCardName(TR(Enums.Color.eBlueH .. TR("%s矿石"), self.mOreName))

                           bgSprite:addChild(card)
                       end
                   },
               })
            end
        }
        table.insert(choiceTable, oreData)
        --创建奖励列表
        local resTable = clone(self.mDropBaseInfo.ChoiceGetGameResource[index])
        table.insert(choiceTable, resTable)

        local cardList = ui.createCardList({
            maxViewWidth = 500,     --显示的最大宽度
            viewHeight = 120,       --显示的高度，默认为120
            space = 20,
            cardShowAttrs = {},
            cardDataList = choiceTable,
            allowClick = true,
            isSwallow = true,
        })
        cardList:setAnchorPoint(cc.p(0, 0.5))
        cardList:setPosition(200, cellBgSprite:getContentSize().height / 2 - 30)
        cellBgSprite:addChild(cardList)
        cardList.getCardNodeList()[1]:setCardName(TR(Enums.Color.eBlueH .. TR("%s矿石"), self.mOreName))

        -- 提示文字“翻牌奖励”
        local hintLable = ui.newLabel({
                text = TR("翻牌奖励"),
                color = cc.c3b(0x46, 0x22, 0x0d),
            })
        hintLable:setPosition(400, 145)
        cellBgSprite:addChild(hintLable)
    else
        local infoLabel = ui.newLabel({
            text = TR("本次无物品掉落"),
            size = 24,
            color = Enums.Color.eRed,
            outlineColor = Enums.Color.eBlack,
            outlineSize = 2,
        })
        infoLabel:setPosition(370, 80)
        cellBgSprite:addChild(infoLabel)
    end

end

return ForgingDigOreShowUi
