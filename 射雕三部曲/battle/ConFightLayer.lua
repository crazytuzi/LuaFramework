--[[
    文件名: ConFightLayer.lua
    创建人: liaoyuangang
    创建时间: 2016-06-14
    描述: 扫荡页面（包括碎片扫荡和节点扫荡）
--]]

local ConFightLayer = class("AutoFightLayer", function()
    return display.newLayer()
end)

-- 扫荡类型
local ConFightType = {
    eDebris = 1, -- 碎片扫荡
    eNode = 2, -- 关卡扫荡
}

--[[
-- 参数 params 中的各项为
	{
		debrisModelId: 碎片扫荡选中的碎片模型Id
		conFightType: 扫荡类型，主要用于恢复页面使用，一般调用者不需要传入该参数
	}
]]
function ConFightLayer:ctor(params)
	-- 当前显示的页面
	self.mConFightType = params.conFightType or ConFightType.eDebris
	-- 如果是碎片扫荡，当前选中的碎片模型Id
	self.mDebrisModelId = params.debrisModelId

	-- 屏蔽下层触摸事件
    ui.registerSwallowTouch({node = self})

	-- 节点场景列表的Parent
    self.mParentNode = ui.newStdLayer()
    self:addChild(self.mParentNode)

    -- 章节缓存信息
    self.mChapterList = {}
    -- 战役信息
    self.mBattleInfo = {}

    -- 可扫荡的碎片模型Id列表
    self.mDebrisIdList = {}
    -- 可扫荡的节点模型Id列表
    self.mNodeIdList = {}
    -- 玩家可扫荡的所有节点
    self.mAllowConNodeIdList = {}
    -- 扫荡节点列表中每个条目的显示大小
    self.mListCellSize = cc.size(640, 130)

    -- 初始化UI数据
    self:initUiData()

	-- 初始化页面控件
	self:initUI()

    -- 创建底部导航和顶部玩家信息部分
    local tempLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true, 
        topInfos = {ResourcetypeSub.eVIT, ResourcetypeSub.eGold, ResourcetypeSub.eDiamond}
    })
    self:addChild(tempLayer)

    -- 获取章节列表数据
    BattleObj:getAllChapterInfo(function(chapterList)  -- 获取
        self.mChapterList = chapterList or {}
        -- 获取战役信息
        self.mBattleInfo = BattleObj:getBattleInfo() or {}

        -- 整理可扫荡的所有节点
	    local tempList = ConfigFunc:getDropNodeByType({ResourcetypeSub.eHeroDebris})
	    local nodeIdList = {}
	    for _, item in pairs(tempList) do
	    	local tempModel = GoodsModel.items[item.modelID]
	    	local colorLv = Utility.getQualityColorLv(tempModel.quality)
	    	if colorLv > 3 then  -- 只提供扫荡橙色及以上的碎片
	    		local nodeModel = BattleNodeModel.items[item.nodeModelID]
	    		local chapterId = nodeModel.chapterModelID
	    		local nodeInfo = self.mChapterList[chapterId] and self.mChapterList[chapterId].NodeList[item.nodeModelID]
	    		local starCount = nodeInfo and nodeInfo.StarCount or 0
	    		if starCount >= nodeModel.starCount then  -- 可以扫荡了
	    			nodeIdList[item.nodeModelID] = true
	    		end
	    	end
	    end

        local tempList = table.keys(nodeIdList)
	    table.sort(tempList, function(nodeId1, nodeId2)
	    	return nodeId1 > nodeId2
	    end)

        for index = 1, math.min(10, #tempList) do
            table.insert(self.mAllowConNodeIdList, tempList[index])
        end

        -- 切换页面
        self:changePage()
    end)
end

-- 初始化页面控件
function ConFightLayer:initUI()
	-- 创建背景
	local bgSprite = ui.newSprite("c_34.jpg")
	bgSprite:setPosition(320, 568)
	self.mParentNode:addChild(bgSprite)

    local tempBgSprite = ui.newScale9Sprite("c_19.png", cc.size(640, 1000))
    tempBgSprite:setAnchorPoint(cc.p(0.5, 1))
    tempBgSprite:setPosition(320, 1000)
    self.mParentNode:addChild(tempBgSprite, 1)

    -- 碎片背景
    local debrisBgSprite = ui.newScale9Sprite("c_17.png", cc.size(632, 450))
    debrisBgSprite:setAnchorPoint(cc.p(0.5, 0))
    debrisBgSprite:setPosition(320, 115)
    self.mParentNode:addChild(debrisBgSprite, 1)
    self.mDebrisBgSprite = debrisBgSprite

	-- 显示可扫荡碎片的列表
	self.mDebrisGrid = require("common.GridView"):create({
		viewSize = cc.size(632, 390),
        colCount = 4,
		celHeight = 130,
		selectIndex = 1,
		getCountCb = function()
			return #self.mDebrisIdList
		end,
		createColCb = function(itemParent, colIndex, isSelected)
			local parentSize = itemParent:getContentSize()
			local modelId = self.mDebrisIdList[colIndex].modelId
			local tempCount = GoodsObj:getCountByModelId(modelId)
			local maxCount = GoodsModel.items[modelId].maxNum

			-- 创建卡牌
			local tempCard = CardNode:create({
				allowClick = true, 
        		onClickCallback = function()
        			self.mDebrisGrid:setSelect(colIndex)
        			-- 
        			self.mDebrisModelId = self.mDebrisIdList[colIndex].modelId
        			self:refreshListView()
        		end
			})
            local showAttr = {CardShowAttr.eBorder, CardShowAttr.eName, CardShowAttr.eNum}
            if isSelected then
                table.insert(showAttr, CardShowAttr.eSelected)
            end
			local cardAttr = tempCard:setGoods({GoodsModelId = modelId, Num = tempCount}, showAttr)
			tempCard:setPosition(parentSize.width / 2, parentSize.height / 2 + 10)
			itemParent:addChild(tempCard)
            tempCard:setGray(not self.mDebrisIdList[colIndex].isPass)

			local tempLabel = cardAttr[CardShowAttr.eNum] and cardAttr[CardShowAttr.eNum].label
			tempLabel:setString(string.format("%d/%d", tempCount, maxCount))
		end
	})
	self.mDebrisGrid:setAnchorPoint(cc.p(0.5, 1))
	self.mDebrisGrid:setPosition(320, 970)
	self.mParentNode:addChild(self.mDebrisGrid, 1)

	-- 创建显示扫荡节点的列表控件
	self.mListView = ccui.ListView:create()
    self.mListView:setContentSize(cc.size(640, 430))
    self.mListView:setItemsMargin(5)
    self.mListView:setDirection(ccui.ListViewDirection.vertical)
    self.mListView:setBounceEnabled(true)
    self.mListView:setAnchorPoint(cc.p(0.5, 0))
    self.mListView:setPosition(320, 125)
    self.mParentNode:addChild(self.mListView, 1)

    -- 空列表的提示
    self.mEmptyHintSprite = ui.createEmptyHint(TR("无扫荡节点信息"))
    self.mEmptyHintSprite:setPosition(320, 340)
    self.mParentNode:addChild(self.mEmptyHintSprite, 1)

	-- 创建导航按钮
	local tabBtnInfos = {
        {
            text = TR("碎片扫荡"),
            tag = ConFightType.eDebris,
        },
        {
            text = TR("关卡扫荡"),
            tag = ConFightType.eNode,
        },
    }
    local tabView = require("common.TabView"):create({
        btnInfos = tabBtnInfos,
        needLine = false,
        defaultSelectTag = self.mConFightType,
        viewSize = cc.size(640, 80),
        onSelectChange = function(selBtnTag)
            if self.mConFightType == selBtnTag then
                return
            end

            self.mConFightType = selBtnTag
            -- 切换页面
            self:changePage()
        end
    })
    tabView:setPosition(Enums.StardardRootPos.eTabView)
    self.mParentNode:addChild(tabView)

    -- 创建返回按钮
	self.mCloseBtn = ui.newButton({
		normalImage = "c_29.png",
		clickAction = function()
			LayerManager.removeLayer(self)
		end 
	})
	self.mCloseBtn:setPosition(Enums.StardardRootPos.eCloseBtn)
	self.mParentNode:addChild(self.mCloseBtn, 1)

    -- 加成
    local attrLabel = ConfigFunc:getMonthAddAttrStr(false)
    if attrLabel then
        attrLabel:setPosition(420, 1010)
        self.mParentNode:addChild(attrLabel)
    end
end

-- 获取恢复数据
function ConFightLayer:getRestoreData()
    local retData = {
    	debrisModelId = self.mDebrisModelId,
        conFightType = self.mConFightType,
    }

    return retData
end

-- 初始化UI数据
function ConFightLayer:initUiData()
	-- 整理可以扫荡的碎片模型Id列表
    local tempList = ConfigFunc:getDropNodeByType({ResourcetypeSub.eHeroDebris})
    local modelIdList = {}
    for _, item in pairs(tempList) do
    	local tempModel = GoodsModel.items[item.modelID]
    	local colorLv = Utility.getQualityColorLv(tempModel.quality)
    	if colorLv > 4 then  -- 只提供扫荡橙色及以上的碎片
    		modelIdList[item.modelID] = true
    	end
    end
    tempModelList = table.keys(modelIdList) --整理数据加入排序条件
    for i,v in ipairs(tempModelList) do
        self.mDebrisIdList[i] = {}
        self.mDebrisIdList[i].modelId = v
    end
    self.mCardList = {}

    BattleObj:getAllChapterInfo(function (chapterList)
        self.mChapterList = chapterList or {}
    end)

    for _, item in ipairs(self.mDebrisIdList) do
        item.isPass = false

        local tempList = ConfigFunc:getDropNodeByModelId(item.modelId)
        local nodeIdList = {}
        for _, item in pairs(tempList) do
            nodeIdList[item.nodeModelID] = true
        end
        local tempNodeList = table.keys(nodeIdList)

        for i,v in ipairs(tempNodeList) do
            local nodeModel = BattleNodeModel.items[v]
            local nodeInfo = self.mChapterList[nodeModel.chapterModelID] and self.mChapterList[nodeModel.chapterModelID].NodeList[v] or {}
            local nodeIsPass = nodeInfo.StarCount and nodeInfo.StarCount >= nodeModel.starCount
            if nodeIsPass == true then
                item.isPass = true
                break
            end
        end
    end
    table.sort(self.mDebrisIdList, function (a, b)
        if a.isPass ~= b.isPass then
            return a.isPass
        end
        return a.modelId < b.modelId
    end)
end

-- 切换页面
function ConFightLayer:changePage()
	local isDebris = self.mConFightType == ConFightType.eDebris
	-- 设置碎片列表是否显示
	self.mDebrisGrid:setVisible(isDebris)
    -- 设置碎片列表背景是否显示
    self.mDebrisBgSprite:setContentSize(cc.size(632, isDebris and 450 or 850))
	-- 设置节点信息列表的大小
	self.mListView:setContentSize(cc.size(640, isDebris and 430 or 830))
    -- 重置空列表提示的位置
    self.mEmptyHintSprite:setPosition(320, isDebris and 340 or 560)

	-- 刷新碎片列表信息
	if isDebris then
		self.mDebrisGrid:reloadData()
	end
	-- 刷新扫荡节点信息列表
	self:refreshListView()
end

-- 刷新扫荡节点信息列表
function ConFightLayer:refreshListView()
	-- 可扫荡的节点模型Id列表
    self.mNodeIdList = {}
    if self.mConFightType == ConFightType.eDebris then
    	self.mDebrisModelId = self.mDebrisModelId or self.mDebrisIdList[1].modelId
    	local tempList = ConfigFunc:getDropNodeByModelId(self.mDebrisModelId)
    	local nodeIdList = {}
    	for _, item in pairs(tempList) do
    		nodeIdList[item.nodeModelID] = true
    	end
    	self.mNodeIdList = table.keys(nodeIdList)
        table.sort(self.mNodeIdList, function(a, b)
            local InfoA = BattleNodeModel.items[a]
            local InfoB = BattleNodeModel.items[b]
            if InfoA.ID ~= InfoB.ID then
                return InfoA.ID < InfoB.ID
            end
        end)
    else
    	self.mNodeIdList = self.mAllowConNodeIdList
    end
    
    self.mListView:removeAllChildren()
	for index = 1, #self.mNodeIdList do
        local lvItem = ccui.Layout:create()
        lvItem:setContentSize(self.mListCellSize)
        self.mListView:pushBackCustomItem(lvItem)

        self:refreshListViewItem(index)
    end
    -- 设置提示信息是否需要显示
    self.mEmptyHintSprite:setVisible(#self.mNodeIdList == 0)
end

-- 刷新扫荡节点信息中的一个条目
function ConFightLayer:refreshListViewItem(index)
	local lvItem = self.mListView:getItem(index - 1)
    if not lvItem then
        lvItem = ccui.Layout:create()
        lvItem:setContentSize(self.mListCellSize)
        self.mListView:insertCustomItem(lvItem, index - 1)
    end
    lvItem:removeAllChildren()

    -- 条目的背景
    local cellBgSprite = ui.newScale9Sprite("c_18.png", cc.size(620, 128))
    cellBgSprite:setPosition(self.mListCellSize.width / 2, self.mListCellSize.height / 2)
    lvItem:addChild(cellBgSprite)

    local nodeId = self.mNodeIdList[index]
    local nodeModel = BattleNodeModel.items[nodeId]
    local chapterId = nodeModel.chapterModelID
    local chapterModel = BattleChapterModel.items[chapterId]
    local nodeInfo = self.mChapterList[chapterId] and self.mChapterList[chapterId].NodeList[nodeId] or {}

    -- 创建节点的头像
    local tempCard = CardNode:create({
    	allowClick = false
    })
    tempCard:setPosition(70, self.mListCellSize.height / 2)
    tempCard:setHero({ModelId = tonumber(nodeModel.pic)}, {CardShowAttr.eBorder})
    lvItem:addChild(tempCard)

    -- 创建节点所属章节和名称
    local nodeTypeName = {
        [Enums.BattleNodeType.eNormal] = TR("普通关卡"),
        [Enums.BattleNodeType.eElite] = TR("精英关卡"),
        [Enums.BattleNodeType.eBoss] = TR("BOSS关卡"),
    }
    local tempStr = ConfigFunc:getFormatNodeInfo({nodeId = nodeId})
    local tempLabel = ui.newLabel({
    	-- text = string.format("%s: %s%s", tempStr, "#D17B00", nodeTypeName[nodeModel.rimType] or ""),
        text = string.format("%s: %s%s", tempStr, "#D17B00", nodeModel.name or ""),
    	color = cc.c3b(0x46, 0x22, 0x0d),
    })
    tempLabel:setAnchorPoint(cc.p(0, 0.5))
    tempLabel:setPosition(130, self.mListCellSize.height / 2 + 32)
    lvItem:addChild(tempLabel)

    -- 挑战次数
    local freeCount = nodeModel.fightNumMax - (nodeInfo.FightCount or 0)
    local tempLabel = ui.newLabel({
    	text = TR("挑战次数: %s%d/%d", "#D17B00", freeCount, nodeModel.fightNumMax),  
    	color = cc.c3b(0x46, 0x22, 0x0d),
    })
    tempLabel:setAnchorPoint(cc.p(0, 0.5))
    tempLabel:setPosition(130, self.mListCellSize.height / 2)
    lvItem:addChild(tempLabel)

    -- 节点掉落
    local tempLabel = ui.newLabel({
    	text = TR("掉落:"),
    	color = cc.c3b(0x46, 0x22, 0x0d),
    })
    tempLabel:setAnchorPoint(cc.p(0, 0.5))
    tempLabel:setPosition(130, self.mListCellSize.height / 2 - 32)
    lvItem:addChild(tempLabel)
    -- 掉落铜钱
    local goldNode = ui.createDaibiView({
        resourceTypeSub = ResourcetypeSub.eGold,
        number = nodeModel.dropGold,
        fontColor = cc.c3b(0x44, 0x78, 0x19),
    })
    lvItem:addChild(goldNode)
    -- 掉落阅历
    local heroExpNode = ui.createDaibiView({
        resourceTypeSub = ResourcetypeSub.eHeroExp,
        number = nodeModel.dropHeroExp,
        fontColor = cc.c3b(0x44, 0x78, 0x19),
    })
    lvItem:addChild(heroExpNode)
    for index, node in pairs({goldNode, heroExpNode}) do
        node:setAnchorPoint(cc.p(0, 0.5))
        node:setPosition(200 + (index - 1) * 100, self.mListCellSize.height / 2 - 32)
    end

    -- 扫荡按钮
    local nodeIsPass = nodeInfo.StarCount and nodeInfo.StarCount >= nodeModel.starCount
    local tempBtn = ui.newButton({
    	normalImage = "c_28.png",
        text = TR("扫荡"),
        clickAction = function()
            if not nodeIsPass then
                ui.showFlashView(TR("达成%d壶酒条件后开启扫荡！", nodeModel.starCount))
                return
            end

            -- 刷新列表数据
            local function refreshViewItem()
                -- 如果是碎片扫荡，需要刷新碎片列表中对应的Item
                if self.mConFightType == ConFightType.eDebris then
                    local debrisIndex
                    for i,v in ipairs(self.mDebrisIdList) do
                        if v.modelId == self.mDebrisModelId then
                            debrisIndex = i
                            break
                        end 
                    end
                    -- local debrisIndex = table.indexof(self.mDebrisIdList, self.mDebrisModelId)
                    self.mDebrisGrid:refreshCell(debrisIndex)
                end
                -- 刷新列表中的该条目
                self:refreshListViewItem(index)
            end
            
            -- 提示是否扫荡
            local function confightUseHintFunc()
                local conFightCount = math.min(nodeModel.fightNumMax - nodeInfo.FightCount, 10)
                if not Utility.isResourceEnough(ResourcetypeSub.eVIT, VitConfig.items[1].perUseNum * conFightCount, true) then
                    return
                end
                if Utility.checkBagSpace() then
                    -- 剩余可以挑战次数
                    BattleObj:requestConFight(chapterId, nodeId, nodeModel.starCount, conFightCount, 3, function(response)
                        if not response or response.Status ~= 0 then 
                            return
                        end

                        -- 刷新列表数据
                        refreshViewItem()

                        -- 展示扫荡结果
                        LayerManager.addLayer({
                            name = "battle.ConFightResultLayer",
                            data = {
                                dropBaseInfo = response.Value.BaseGetGameResourceList
                            },
                            cleanUp = false,
                        })
                        -- 升级检查放到了扫荡结果展示页面后
                    end)
                end
            end 

            -- 判断挑战次数是否足够
            local conFightCount = math.min(nodeModel.fightNumMax - nodeInfo.FightCount, 10)
            if conFightCount <= 0 then
		        MsgBoxLayer.resetNodeHintLayer(nodeInfo.ResetFightCount, function(useType)
			        BattleObj:requestResetCount(chapterId, nodeId, useType, function(response)
				        if not response or response.Status ~= 0 then 
				            return
				        end

                        -- 刷新列表数据
                        refreshViewItem()
				   		confightUseHintFunc()
				    end)
			    end)
			    return 
		    end

           confightUseHintFunc()     
        end,
    })
    tempBtn:setPosition(self.mListCellSize.width - 110, self.mListCellSize.height / 2)
    tempBtn:setBright(nodeIsPass)
    lvItem:addChild(tempBtn)
end

return ConFightLayer
