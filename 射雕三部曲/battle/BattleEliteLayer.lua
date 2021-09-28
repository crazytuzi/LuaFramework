--[[
    文件名: BattleEliteLayer.lua
    描述: 精英副本页面(武林谱)
    创建人: heguanghui
    创建时间: 2017-04-18
--]]

local BattleEliteLayer = class("BattleEliteLayer", function(params)
	return display.newLayer()
end)

--[[
-- 参数 params 中的各个字段为
    {
        battleInfo: 精英副本战斗信息
        nodeList: 精英副本节点信息
        nodeIdList: 精英副本节点Id列表
        parent: 父Layer
    }
]]
function BattleEliteLayer:ctor(params)
    params = params or {}
    self.parent = params.parent

    -- 大侠之路的任务数据
    local currId, currState, _ = RoadOfHeroObj:getCurrTask()
    local taskConfig = MaintaskNodeRelation.items[currId]
    if (taskConfig ~= nil) and (taskConfig.maintaskID == 3) and (currState == 1) then
        -- 当前有需要挑战的武林谱章节
        self.targetRoadOfHero = taskConfig.condition
    end

    -- 精英副本战斗信息
	self.mBattleInfo = params.battleInfo
	-- 精英副本节点信息
	self.mNodeList = params.nodeList
	-- 精英副本节点Id列表
	self.mNodeIdList = params.nodeIdList

	-- 页面元素父节点
	self.mParentLayer = ui.newStdLayer()
	self:addChild(self.mParentLayer)

	-- 初始化页面控件
	self:initUI()

	-- 获取精英战役信息数据请求
    self:requestGetBattleInfo()
end

-- 初始化页面控件
function BattleEliteLayer:initUI()
    -- 创建背景
    local bgSprite = ui.newSprite("fb_30.jpg")
    bgSprite:setPosition(320, 568)
    self.mParentLayer:addChild(bgSprite, -1000)

    -- 显示挑战次数
    self.mHintNode = ui.createSpriteAndLabel({
        imgName = "c_25.png",
        scale9Size = cc.size(500, 54),
        labelStr = "",
        fontColor = cc.c3b(0xff, 0xff, 0xff),
        outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
        outlineSize = 2,
    })
    self.mHintNode:setPosition(320, 945)
    self.mParentLayer:addChild(self.mHintNode)
    self:refreshHint()

    -- 显示兑换按钮
    -- local btnExchange = ui.newButton({
    --     normalImage = "tb_43.png",
    --     clickAction = function()
    --         -- 跳转到兑换商店，好像还没写，查一下雪鹰
    --         -- 就是效果图的“藏经阁”，独有功能，服务端还没出接口
    --     end
    -- })
    -- btnExchange:setPosition(590, 945)
    -- self.mParentLayer:addChild(btnExchange)

    -- 显示列表背景
    local mBottomBgSprite = ui.newScale9Sprite("c_19.png", cc.size(640, 905))
    mBottomBgSprite:setAnchorPoint(cc.p(0.5, 0))
    mBottomBgSprite:setPosition(320, 0)
    self.mParentLayer:addChild(mBottomBgSprite)

    -- 创建列表并刷新
    self.mListView = ccui.ListView:create()
    self.mListView:setDirection(ccui.ScrollViewDir.vertical)
    self.mListView:setBounceEnabled(true)
    self.mListView:setContentSize(cc.size(640, 750))
    self.mListView:setPosition(cc.p(0, 115))
    mBottomBgSprite:addChild(self.mListView)

    -- 加成
    local attrLabel = ConfigFunc:getMonthAddAttrStr(false)
    if attrLabel then
        attrLabel:setPosition(320, 910)
        self.mParentLayer:addChild(attrLabel)
    end
end

-- 获取恢复数据
function BattleEliteLayer:getRestoreData()
    local retData = {
        battleInfo = self.mBattleInfo,
        nodeList = self.mNodeList,
        nodeIdList = self.mNodeIdList,
    }

    return retData
end

-- 刷新页面提示信息
function BattleEliteLayer:refreshHint()
    local white, green = "#FFFFFF", "#9DFF8A"
    local count = 0
    if self.mBattleInfo and self.mBattleInfo.FightCount then
        count = self.mBattleInfo.FightCount
    end
    self.mHintNode:setString(TR("剩余挑战次数: %s%d%s     每日%s18点%s、%s0点%s重置", green, count, white, green, white, green, white))
end

function BattleEliteLayer:refreshList()
    self.mListView:removeAllItems()

    -- 添加显示
    table.sort(self.mNodeIdList, function(nodeId1, nodeId2)
            return nodeId1 > nodeId2
        end)
    for i, nodeId in ipairs(self.mNodeIdList) do
        local lvItem = ccui.Layout:create()
        lvItem:setContentSize(cc.size(640, 214))
        self.mListView:pushBackCustomItem(lvItem)

        -- 读取章节信息
        local nodeItem = self.mNodeList[nodeId]
        local nodeBase = ElitebattleNodeModel.items[nodeId]
        local strPropFap = TR("推荐战力: %s", nodeBase.proposeFAP)

        -- 节点背景图
        if (nodeItem.NodeStatus ~= Enums.BattleNodeStatus.eLocked) then
            local nodeBgImg = nodeBase.pic .. ".jpg"
            local nodeBgSprite = ui.newSprite(nodeBgImg)
            nodeBgSprite:setAnchorPoint(cc.p(0, 0.5))
            nodeBgSprite:setPosition(cc.p(80, 107))
            lvItem:addChild(nodeBgSprite)
        end

        -- 子条目背景
        local cellBgSprite =  ui.newButton({
            normalImage = (nodeItem.NodeStatus == Enums.BattleNodeStatus.eLocked) and "fb_23.png" or "fb_24.png",
            clickAction = function ()
                if (nodeItem.NodeStatus == Enums.BattleNodeStatus.eLocked) then
                    ui.showFlashView(strPropFap)
                else
                    self:showFightDlg(nodeItem, nodeBase)

                    -- 继续下一步引导
                    local _, _, eventID = Guide.manager:getGuideInfo()
                    if eventID == 10801 then
                        -- 不删除引导界面，后续还在此界面引导
                        Guide.manager:nextStep(eventID)
                        -- 有弹出动画，所以延迟到对话框弹出之后
                        Utility.performWithDelay(self.mListView, handler(self, self.executeGuide), 0.25)
                    end
                end
            end
            })
        cellBgSprite:setPressedActionEnabled(false)
        cellBgSprite:setPosition(317, 107)
        lvItem:addChild(cellBgSprite)
        -- 保存按钮为引导所用
        if nodeId == 11 then
            self.guideCellBtn = cellBgSprite
        end

        -- 显示章节名
        local nodeNameLabel = ui.newLabel({
            text = nodeBase.name,
            dimensions = cc.size(15, 0),
            size = 20,
            color = cc.c3b(0xf3, 0xf1, 0xda),
            outlineColor = cc.c3b(0x74, 0x3b, 0x1c),
            outlineSize = 2,
        })
        nodeNameLabel:setAnchorPoint(cc.p(0.5, 0.5))
        nodeNameLabel:setPosition(15, 102)
        cellBgSprite:addChild(nodeNameLabel)

        -- 显示星星
        if (nodeItem.MaxStars ~= nil) and (nodeItem.MaxStars > 0) then
            local starNode = ui.newStarLevel(nodeItem.MaxStars)
            starNode:setAnchorPoint(cc.p(0.5, 1))
            starNode:setPosition(314, 180)
            cellBgSprite:addChild(starNode)
        end

        -- 显示推荐战力或挑战需求
        local propBgImg, propOutlineColor = "fb_28.png", cc.c3b(0x72, 0x1f, 0x19)
        if (nodeItem.NodeStatus == Enums.BattleNodeStatus.eLocked) then
            propBgImg, propOutlineColor = "fb_29.png", cc.c3b(0x72, 0x2e, 0x19)
            if (nodeItem.NeedNodeModelId ~= nil) and (nodeItem.NeedNodeModelId > 0) then
                -- 精英副本
                strPropFap = TR("需通关武林谱: %s", ElitebattleNodeModel.items[nodeItem.NeedNodeModelId].name)
            else
                -- 普通副本
                local tmpNodeModel = BattleNodeModel.items[nodeBase.needBattleNodeModelID]
                local strNodeKey = nodeBase.needBattleNodeModelID - math.floor(nodeBase.needBattleNodeModelID/100)*100 - 10
                local nodeNameList = {
                    [1] = TR("一"), [2] = TR("二"), [3] = TR("三"), [4] = TR("四"), [5] = TR("五"),
                    [6] = TR("六"), [7] = TR("七"), [8] = TR("八"), [9] = TR("九"), [10] = TR("十"),
                }
                strPropFap = TR("需解锁江湖: 第%d章 第%s节", (tmpNodeModel.chapterModelID - 10), nodeNameList[strNodeKey])
            end
            -- 等级需求
            if (PlayerAttrObj:getPlayerInfo().Lv < nodeBase.needLV) then
                strPropFap = TR("达到%d级后可挑战", nodeBase.needLV)
            end
        end
        local propBgSprite = ui.newScale9Sprite(propBgImg, cc.size(300, 42))
        propBgSprite:setPosition(314, 45)
        cellBgSprite:addChild(propBgSprite)

        local propFapLabel = ui.newLabel({
            text = strPropFap,
            size = 22,
            color = cc.c3b(0xff, 0xf4, 0xf4),
            outlineColor = propOutlineColor,
            outlineSize = 2,
        })
        propFapLabel:setPosition(150, 20)
        propBgSprite:addChild(propFapLabel)

		-- 显示完美通关的提示
        local maxStars = self:getMaxStars(nodeId)
		if nodeItem.IsPass and nodeItem.MaxStars >= maxStars then
			local passSprite = ui.newSprite("fb_27.png")
			passSprite:setPosition(cc.p(100, 105))
			cellBgSprite:addChild(passSprite)
		end

        if (nodeItem.NodeStatus == Enums.BattleNodeStatus.eLocked) or ((nodeItem.MaxStars >= maxStars) and (not nodeItem.IsReward)) then
            -- 这两种状态下不显示：当前关卡不能挑战、已经6星通关且已领取了奖励
        else
            local chestBtn = ui.newButton({
                normalImage = "fb_14.png",
                clickAction = function(btnObj)
                    self:showFirstRewardDlg(nodeItem, nodeBase)

                    --[[--------新手引导--------]]--
                    local _, _, eventID = Guide.manager:getGuideInfo()
                    if eventID == 10804 then
                        -- 不删除引导界面，后续还在此界面引导
                        Guide.manager:nextStep(eventID)
                        Utility.performWithDelay(propFapLabel, handler(self, self.executeGuide), 0.25)
                    end
                end
            })
            chestBtn:setPosition(cc.p(510, 105))
            cellBgSprite:addChild(chestBtn)
            -- 引导需要首通奖励
            self.chestBtn = chestBtn

            -- 有奖励可以领取的时候显示小红点
            if nodeItem.IsReward then
                local buttonSize = chestBtn:getContentSize()
                local redDotSprite = ui.createBubble({position = cc.p(buttonSize.width - 15, buttonSize.height - 15)})
                chestBtn:addChild(redDotSprite)
            end
        end

        -- 是否有大侠之路的任务
        if (self.targetRoadOfHero ~= nil) and (self.targetRoadOfHero == nodeId) then
            local tmpSprite = ui.createFloatSprite("dxzl_02.png", cc.p(314, 130))
            cellBgSprite:addChild(tmpSprite, 1)
        end
    end
end

-- ===================== 辅助函数 ==========================

-- 返回最大通关星数
function BattleEliteLayer:getMaxStars(nodeId)
    local maxStars = 0
    if nodeId == 11 then
        maxStars = 3
    elseif nodeId == 12 then
        maxStars = 5
    else
        maxStars = 6
    end
    return maxStars
end

-- 判断是否可以挑战
function BattleEliteLayer:isCanFight(count)
    -- 判断剩余次数
    if (self.mBattleInfo == nil) or (self.mBattleInfo.FightCount == nil) or (self.mBattleInfo.FightCount == 0) then
        ui.showFlashView(TR("挑战次数已经用完"))
        return false
    end

    -- 判断体力
    local nVit = (count or 1) * ElitebattleConfig.items[1].fightVITSuccessful
    if not Utility.isResourceEnough(ResourcetypeSub.eVIT, nVit, true) then
        return false
    end

    return true
end

-- 弹出首通奖励的对话框
function BattleEliteLayer:showFirstRewardDlg(nodeItem, nodeBase)
    -- 添加弹出框层
    local parentLayer = LayerManager.addLayer({
            name = "commonLayer.PopBgLayer",
            data = {
                bgSize = cc.size(600, 664),
                title = TR("首通奖励"),
            },
            cleanUp = false,
        })

    -- 保存弹框控件信息
    local mBgSprite = parentLayer.mBgSprite
    local mBgSize = mBgSprite:getContentSize()

    -- 显示灰色背景
    local grayBgSprite = ui.newScale9Sprite("c_17.png", cc.size(520, 490))
    grayBgSprite:setAnchorPoint(cc.p(0.5, 0))
    grayBgSprite:setPosition(cc.p(mBgSize.width * 0.5, 100))
    mBgSprite:addChild(grayBgSprite)

    -- 处理掉落列表
    local tempDropList = {}
    for _,v in pairs(ElitebattleFirstDropRelation.items[nodeItem.NodeID]) do
        table.insert(tempDropList, clone(v))
    end
    table.sort(tempDropList, function(item1, item2)
        return item1.stars < item2.stars
    end)

    -- 显示掉落列表
	self.mHaveMan = 0

    for i,v in ipairs(tempDropList) do
        -- 显示背景图
        local cellBgSize = cc.size(500, 150)
        local cellBgSprite = ui.newScale9Sprite("c_18.png", cellBgSize)
        cellBgSprite:setAnchorPoint(cc.p(0.5, 1))
        cellBgSprite:setPosition(cc.p(260, 480 - (i - 1) * (cellBgSize.height + 10)))
        grayBgSprite:addChild(cellBgSprite)

        -- 显示达成目标
        local destLabel = ui.newLabel({
            text = TR("达到:"),
            color = cc.c3b(0x46, 0x22, 0x0d),
        })
        destLabel:setAnchorPoint(cc.p(1, 0.5))
        destLabel:setPosition(70, cellBgSize.height - 25)
        cellBgSprite:addChild(destLabel)

		-- 显示达成目标
		local plusMan = 0
		if nodeItem.NodeID == 11 or nodeItem.NodeID == 12 then
			plusMan = 1
		elseif nodeItem.NodeID >= 13 then
			plusMan = 2
		end

		local tageLabel = ui.newLabel({
			--text = TR("需要%d人存活", self.mHaveMan + plusMan),
			text = TR("需要%d人存活",  v.stars),
			color = cc.c3b(0x46, 0x22, 0x0d),
		})
		self.mHaveMan = self.mHaveMan + plusMan
		tageLabel:setAnchorPoint(cc.p(0, 0.5))
		tageLabel:setPosition(280, cellBgSize.height - 25)
		cellBgSprite:addChild(tageLabel)

        --local mStarNode = ui.newStarLevel(v.stars, "c_98.png")
        local mStarNode = ui.newStarLevel(v.stars)
        mStarNode:setAnchorPoint(cc.p(0, 0.5))
        mStarNode:setPosition(80, cellBgSize.height - 25)
        cellBgSprite:addChild(mStarNode)

        -- 显示奖励列表
        local rewardList = {}
        for _, reward in pairs(string.split(v.firstReward, "||")) do
            local tempList = string.split(reward, ",")
            local tempItem = {}
            tempItem.resourceTypeSub = tonumber(tempList[1])
            tempItem.modelId = tonumber(tempList[2])
            tempItem.num = tonumber(tempList[3])
            table.insert(rewardList, tempItem)
        end
        local mCardlist = ui.createCardList({
            maxViewWidth = 370,
            viewHeight = 120,
            cardDataList = rewardList,
            allowClick = true,
        })
        mCardlist:setAnchorPoint(cc.p(0, 0))
        mCardlist:setPosition(20, 5)
        mCardlist:setScale(0.85)
        cellBgSprite:addChild(mCardlist)

        -- 显示领取状态，默认是未达到状态，什么都不显示
        local statusText = nil
        if (nodeItem.MaxStars >= v.stars) then
            statusText = TR("已完成")
            for _,vStar in ipairs(nodeItem.RewardStars) do
                if (tonumber(vStar) == v.stars) then
                    statusText = TR("可领取")
                    break
                end
            end
        end
        if (statusText ~= nil) then
            local statusSprite = ui.newSprite("c_74.png")
            local statusSize = statusSprite:getContentSize()
            statusSprite:setAnchorPoint(0.5, 0.5)
            statusSprite:setPosition(cellBgSize.width - 55, cellBgSize.height * 0.5)
            cellBgSprite:addChild(statusSprite)

            local statusLabel = ui.newLabel({
                text = statusText,
                color = cc.c3b(0x46, 0x22, 0x0d),
                anchorPoint = cc.p(0.5, 0.5),
                x = statusSize.width * 0.5,
                y = statusSize.height * 0.5
            })
            statusSprite:addChild(statusLabel)
            statusLabel:setRotation(-17)
        end
    end

    -- 显示按钮
    local btnReward = ui.newButton({
        normalImage = "c_28.png",
        text = TR("领取"),
        position = cc.p(mBgSize.width * 0.5, 60),
        clickAction = function()
            if (not nodeItem.IsReward) then
                ui.showFlashView(TR("暂时没有可领取的奖励"))
                return
            end
            self:requestDrawFirstReward(nodeBase.ID, function (rewardList)
                    -- 显示奖励信息
                    ui.ShowRewardGoods(rewardList, true)
                    LayerManager.removeLayer(parentLayer)
                    self:refreshList()
                end)
        end
    })
    mBgSprite:addChild(btnReward)
    -- 保存按钮，新手引导使用
    self.btnReward = btnReward
end

-- 弹出挑战扫荡的对话框
function BattleEliteLayer:showFightDlg(nodeItem, nodeBase)
    local nodeInfo = ElitebattleNodeModel.items[nodeItem.NodeID]
    -- 添加弹出框层
    local parentLayer = LayerManager.addLayer({
            name = "commonLayer.PopBgLayer",
            data = {
                bgSize = cc.size(600, 590),
                title = TR("%s·掉落预览", nodeInfo.name),
            },
            cleanUp = false,
        })

    -- 保存弹框控件信息
    local mBgSprite = parentLayer.mBgSprite
    local mBgSize = mBgSprite:getContentSize()

    -- 显示挑战消耗
    local fightLabel = ui.newLabel({
        text = TR("挑战消耗:"),
        color = cc.c3b(0x46, 0x22, 0x0d),
    })
    fightLabel:setAnchorPoint(cc.p(1, 0.5))
    fightLabel:setPosition(mBgSize.width * 0.5 - 10, mBgSize.height - 88)
    mBgSprite:addChild(fightLabel)

    local fightBgSprite = ui.newScale9Sprite("c_24.png", cc.size(100, 34))
    fightBgSprite:setAnchorPoint(cc.p(0, 0.5))
    fightBgSprite:setPosition(cc.p(mBgSize.width * 0.5 + 10, mBgSize.height - 88))
    mBgSprite:addChild(fightBgSprite)

    local fightNeedVIT = ui.createDaibiView({
        resourceTypeSub = ResourcetypeSub.eVIT,
        number = ElitebattleConfig.items[1].fightVITSuccessful,
        fontColor = cc.c3b(0xbd, 0x6e, 0x00),
    })
    fightNeedVIT:setAnchorPoint(cc.p(0, 0.5))
    fightNeedVIT:setPosition(cc.p(mBgSize.width * 0.5 + 5, mBgSize.height - 88))
    mBgSprite:addChild(fightNeedVIT)

    -- 显示灰色背景
    local grayBgSprite = ui.newScale9Sprite("c_17.png", cc.size(520, 376))
    grayBgSprite:setAnchorPoint(cc.p(0.5, 0))
    grayBgSprite:setPosition(cc.p(mBgSize.width * 0.5, 100))
    mBgSprite:addChild(grayBgSprite)

    -- 处理掉落列表
    local tempDropList = {}
    for _,item in ipairs(ElitebattleNodeDropRelation.items) do
        if item.nodeID == nodeItem.NodeID then
            --卡牌边框，卡牌名字
            local tempCardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum, CardShowAttr.eName}
            local tempItem = {
                resourceTypeSub = item.typeID,
                modelId = item.modelID,
                num = item.num,
                cardShowAttrs = tempCardShowAttrs,
            }
            local tempKey = (item.modelID ~= 0) and item.modelID or item.typeID
            tempDropList[tempKey] = tempItem
        end
    end

    local showDropList = table.values(tempDropList)
    table.sort(showDropList, function(item1, item2)
        if item1.resourceTypeSub ~= item2.resourceTypeSub then
            return item1.resourceTypeSub < item2.resourceTypeSub
        end

        -- 比较品质
        local colorLv1 = Utility.getColorLvByModelId(item1.modelId, item1.resourceTypeSub)
        local colorLv2 = Utility.getColorLvByModelId(item2.modelId, item2.resourceTypeSub)
        if colorLv1 ~= colorLv2 then
            return colorLv1 > colorLv2
        end

        return item1.modelId > item2.modelId
    end)

    -- 显示掉落列表
    local mGridView = require("common.GridView"):create({
        viewSize = cc.size(500, 356),
        colCount = 4,
        celHeight = 130,
        getCountCb = function()
            return #showDropList
        end,
        createColCb = function(itemParent, colIndex, isSelected)
            local currItem = showDropList[colIndex]
            local tempCard = CardNode:create({
                allowClick = true,
            })
            tempCard:setCardData(currItem)
            tempCard:setPosition(cc.p(64, 80))
            itemParent:addChild(tempCard)
        end,
    })
    mGridView:setAnchorPoint(cc.p(0.5, 0))
    mGridView:setPosition(mBgSize.width * 0.5, 110)
    mBgSprite:addChild(mGridView)

    -- 显示按钮
    local maxStars = self:getMaxStars(nodeItem.NodeID)
    local btnImg, btnTitle = "c_28.png", TR("挑战")
    if (nodeItem.NodeStatus == Enums.BattleNodeStatus.ePass) and (nodeItem.MaxStars == maxStars) then
        btnImg, btnTitle = "c_33.png", TR("扫荡")
    end
    local btnFight = ui.newButton({
        normalImage = btnImg,
        text = btnTitle,
        position = cc.p(mBgSize.width * 0.5, 60),
        clickAction = function()
            local _, _, eventID = Guide.manager:getGuideInfo()
            
            if (nodeItem.NodeStatus == Enums.BattleNodeStatus.ePass) and (nodeItem.MaxStars == maxStars) then
				local count = self.mBattleInfo.FightCount
				local sendCount = 0
				--添加扫荡次数
				if count == 0 then
					ui.showFlashView(TR("扫荡次数已用完"))
				else
                    local usedMsgLayer = nil
					usedMsgLayer = self:addUseGoodsCountLayer(
						TR("扫荡次数"),
						count,
						function(selCount)
							if selCount > count then
								ui.showFlashView(TR("最多可以扫荡3次"))
							end
							sendCount = selCount
						end,
						function()
                            usedMsgLayer:removeFromParent()
							if not Utility.checkBagSpace() then
								return
							end
							self:requestOnekeySweep(nodeBase.ID, sendCount, function (rewardList)
									-- 显示扫荡结果
									LayerManager.addLayer({
										name = "battle.ConFightResultLayer",
										data = {dropBaseInfo = rewardList},
										cleanUp = false,
									})
									LayerManager.removeLayer(parentLayer)
								end)
						end
					)
				end

                -- 扫荡，无法挑战，跳过引导
                if eventID == 10802 then
                    Guide.helper:guideError(eventID, -1)
                    return
                end
            else
				-- 背包空间是否充足
				if Utility.checkBagSpace() then
					self:requestFight(nodeBase.ID, function ()
							LayerManager.removeLayer(parentLayer)
						end)
                else
                    -- 背包不足，跳过引导
                    if eventID == 10802 then
                        Guide.helper:guideError(eventID, -1)
                        return
                    end
				end
            end
        end
    })
    mBgSprite:addChild(btnFight)
    -- 保存挑战按钮，引导使用
    self.fightBtn = btnFight
end


function BattleEliteLayer:addUseGoodsCountLayer(title, maxNum, countChangeCallback, OkCallback)
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

	    -- 数量选择控件
    local tempView = require("common.SelectCountView"):create({
	        maxCount = maxNum,
	        viewSize = cc.size(500, 200),
	        changeCallback = function(count)
	            if countChangeCallback then
	                countChangeCallback(count)
	            end
	            if getHintCallback then
	            end
	            return true
	        end
	    })
	    tempView:setPosition(layerSize.width / 2, layerSize.height / 2)
	    layerBgSprite:addChild(tempView)
    end

    local okBtnInfo = {
        text = TR("确定"),
        clickAction = function(layerObj, btnObj)
            OkCallback(selCount, layerObj, btnObj)
        end,
    }
    return MsgBoxLayer.addDIYLayer({
        msgText = TR(""),
        title = title or TR("选择"),
        bgSize = cc.size(598, 474),
        btnInfos = {okBtnInfo},
        closeBtnInfo = {},
        DIYUiCallback = DIYFuncion,
        notNeedBlack = true,
    })
end


-- ===================== 网络请求相关函数 ==========================

-- 获取精英战役信息
function BattleEliteLayer:requestGetBattleInfo()
	HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "Elitebattle",
        methodName = "GetBattleInfo",
        svrMethodData = {1, 1},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end

            -- 更新战役信息
            self.mBattleInfo = response.Value.BattleInfo

            -- 更新节点信息
            self.mNodeList = {}
            for _, item in pairs(response.Value.NodeList) do
                self.mNodeList[item.NodeID] = item
            end
            self.mNodeIdList = table.keys(self.mNodeList)

            -- 刷新页面
    		self:refreshHint()
            self:refreshList()

            -- 执行引导
            Utility.performWithDelay(self.mListView, handler(self, self.executeGuide), 0.25)
        end,
    })
end

-- 领取首通奖励
function BattleEliteLayer:requestDrawFirstReward(nodeId, callFunc)
	HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "Elitebattle",
        methodName = "DrawFirstReward",
        guideInfo = Guide.helper:tryGetGuideSaveInfo(108041),
        svrMethodData = {nodeId},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            --[[--------新手引导--------]]--
            local _, _, eventID = Guide.manager:getGuideInfo()
            if eventID == 108041 then
                -- 不删除引导界面，后续还在此界面引导
                Guide.manager:nextStep(eventID)
                self:executeGuide()
            end

            -- 刷新节点缓存信息
            local nodeInfo = self.mNodeList[nodeId]
            for key, value in pairs(response.Value.NodeInfo or {}) do
                nodeInfo[key] = value
            end

            -- 执行回调
            callFunc(response.Value.BaseGetGameResourceList)
        end,
    })
end

-- 挑战关卡
function BattleEliteLayer:requestFight(nodeId, callFunc)
    if not self:isCanFight() then
        -- 引导时如遇体力不足，则停止引导
        local _, _, eventID = Guide.manager:getGuideInfo()
        if eventID == 10802 then
            Guide.helper:guideError(eventID, -1)
        end
        return
    end
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "Elitebattle",
        methodName = "GetFightInfo",
        guideInfo = Guide.helper:tryGetGuideSaveInfo(10802),
        svrMethodData = {nodeId},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            --[[--------新手引导--------]]--
            local _, _, eventID = Guide.manager:getGuideInfo()
            if eventID == 10802 then
                -- 不删除引导界面，后续还在此界面引导
                Guide.manager:nextStep(eventID)
                Guide.manager:removeGuideLayer()
            end

            callFunc()
            -- 进入战斗页面
            local value = response.Value
            -- 战斗控制参数
            local controlParams = Utility.getBattleControl(ModuleSub.eBattleElite)
            LayerManager.addLayer({
                name = "ComBattle.BattleLayer",
                data = {
                    data = value.FightInfo,
                    skip = controlParams.skip,
                    trustee = controlParams.trustee,
                    map = Utility.getBattleBgFile(ModuleSub.eBattleElite, {fightNodeId = nodeId}),
                    callback = function(ret)
                        CheckPve.BattleElite(nodeId, ret)

                        if controlParams.trustee and controlParams.trustee.changeTrusteeState then
                            controlParams.trustee.changeTrusteeState(ret.trustee)
                        end
                    end
                },
            })
        end,
    })
end

-- 扫荡关卡
function BattleEliteLayer:requestOnekeySweep(nodeId, count, callFunc)
    if not self:isCanFight(count) then
        return
    end
    BattleObj:requestEliteSweep(nodeId, count, function(response)
        if not response or response.Status ~= 0 then
            return
        end
		callFunc(response.Value.BaseGetGameResourceList)
        -- 刷新挑战次数
        self.mBattleInfo.FightCount = self.mBattleInfo.FightCount - count
        self:refreshHint()
    end)
end

-- ========================== 新手引导 ===========================
-- 执行新手引导
function BattleEliteLayer:executeGuide()
    local _, _, eventID = Guide.manager:getGuideInfo()
    if eventID == 10804 and self.mNodeList[11] and not self.mNodeList[11].IsReward then
        -- 不能领取首通奖励，引导取消
        Guide.helper:guideError(eventID, -1)
        return
    end
    local exeRet = Guide.helper:executeGuide({
        -- 指向第一关精英副本
        [10801]  = {clickNode = self.guideCellBtn},
        -- 指向挑战
        [10802]  = {clickNode = self.fightBtn},
        -- 首通奖励
        [10804]  = {clickNode = self.chestBtn},
        -- 领取奖励
        [108041] = {clickNode = self.btnReward},
        -- 指向挑战
        [113051] = {clickNode = self.parent.mCommonLayer_:getNavBtnObj(Enums.MainNav.eChallenge)},
    })
    if exeRet then
        self.mListView:setTouchEnabled(false)
    end
end

return BattleEliteLayer
