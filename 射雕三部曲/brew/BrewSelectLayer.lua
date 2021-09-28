--[[
	文件名：BrewSelectLayer.lua
	描述：酿酒选择酒材界面
	创建人：yanghongsheng
	创建时间： 2018.5.22
--]]

local BrewSelectLayer = class("BrewSelectLayer", function()
	return display.newLayer()
end)

--[[
	params:
		callback:	选完酒材的回调
		limitExp:	限制选择总经验
]]

function BrewSelectLayer:ctor(params)
	-- 参数
	params = params or {}
	self.mCallback = params.callback
	self.mLimitExp = params.limitExp

	-- 酒材选择列表
	self.mSelectList = {}
	-- 所有酒材列表
	self.mMaterialList = {}
	-- 当前选择了的总经验
	self.mSelectExp = 0

	-- 屏蔽下层触摸
	ui.registerSwallowTouch({node = self})
	-- 创建标准容器
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)
    -- 创建底部导航和顶部玩家信息部分
    local tempLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        currentLayerType = Enums.MainNav.ePractice,
        topInfos = {ResourcetypeSub.eVIT, ResourcetypeSub.eGold, ResourcetypeSub.eDiamond}
    })
    self:addChild(tempLayer)
    self.mCommonLayer_ = tempLayer

    -- 初始化数据
    self:initData()
    -- 初始化
    self:initUI()
end

function BrewSelectLayer:initData()
	-- 遍历配置文件
	for _, materialInfo in pairs(clone(BrewingGoodsExpModel.items)) do
		local num = Utility.getOwnedGoodsCount(ResourcetypeSub.eFunctionProps, materialInfo.ID) or 0
		if num > 0 then
			materialInfo.num =  num
			table.insert(self.mMaterialList, materialInfo)
		end
	end
end

function BrewSelectLayer:initUI()
	-- 背景图
	local bgSprite = ui.newSprite("c_128.jpg")
	bgSprite:setAnchorPoint(cc.p(0.5, 1))
	bgSprite:setPosition(320, 1136)
	self.mParentLayer:addChild(bgSprite)

	-- 子背景
    local subBgSprite = ui.newScale9Sprite("c_19.png", cc.size(640, 950))
    subBgSprite:setAnchorPoint(cc.p(0.5, 1))
    subBgSprite:setPosition(cc.p(self.mParentLayer:getContentSize().width * 0.5, 1000))
    self.mParentLayer:addChild(subBgSprite)

    -- 显示页签
    self:showTabLayer()

    -- 列表背景
    local listBgSize = cc.size(618, 760)
	local listBg = ui.newScale9Sprite("c_17.png", listBgSize)
	listBg:setAnchorPoint(cc.p(0.5, 1))
	listBg:setPosition(320, 970)
	self.mParentLayer:addChild(listBg)

	-- 列表
	self.listViewSize = cc.size(listBgSize.width-20, listBgSize.height-20)
	local listView = ccui.ListView:create()
	listView:setContentSize(self.listViewSize)
    listView:setDirection(ccui.ListViewDirection.vertical)
    listView:setGravity(ccui.ListViewGravity.centerHorizontal)
    listView:setItemsMargin(10)
    listView:setBounceEnabled(true)
    listView:setAnchorPoint(0.5, 0.5)
    listView:setPosition(listBgSize.width*0.5, listBgSize.height*0.5)
    listBg:addChild(listView)

	-- 确认按钮
    local confirmBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("确定"),
        position = cc.p(self.mParentLayer:getContentSize().width * 0.5, 150),
        clickAction = function(pSender)
        	if self.mCallback then
        		self.mCallback(self.mSelectList)
        	end
        	LayerManager.removeLayer(self)
        end
    })
    self.mParentLayer:addChild(confirmBtn)

    --返回按钮
    local closeBtn = ui.newButton({
        normalImage = "c_29.png",
        position = Enums.StardardRootPos.eCloseBtn,
        clickAction = function(pSender)
        	LayerManager.removeLayer(self)
        end
    })
    self.mParentLayer:addChild(closeBtn)

    if self.mMaterialList and next(self.mMaterialList) then
	    for _, itemData in pairs(self.mMaterialList or {}) do
	    	local item = self:createCell(itemData)
	    	listView:pushBackCustomItem(item)
	    end
	else
		local emptyHint = ui.createEmptyHint(TR("您没有可用的酒材"))
		emptyHint:setPosition(320, 568)
		self.mParentLayer:addChild(emptyHint)

		confirmBtn:setVisible(false)
	end
end

-- 创建项
function BrewSelectLayer:createCell(itemData)
	local cellSize = cc.size(self.listViewSize.width, 130)
	local goodsInfo = GoodsModel.items[itemData.ID]

	local layout = ccui.Layout:create()
	layout:setContentSize(cellSize)

	local bgSprite = ui.newScale9Sprite("c_18.png", cellSize)
	bgSprite:setPosition(cellSize.width*0.5, cellSize.height*0.5)
	layout:addChild(bgSprite)

	local morenNum = 1 -- 默认初始数量
	local morenAdd = 1 -- 默认增量
	-- 点击复选框的回调
	layout.checkCallBack = function (newState)
		-- if newState then
		-- 	if self.curNeedNum <= 0 then
		-- 		layout.checkBox:setCheckState(not newState)
		-- 		ui.showFlashView({text = TR("已有足够药材")})
		-- 		return
		-- 	elseif self.mQuality and self.mQuality ~= GoodsModel.items[itemData.ID].quality then
		-- 		layout.checkBox:setCheckState(not newState)
		-- 		ui.showFlashView({text = TR("需要相同品质的药材")})
		-- 		return
		-- 	elseif itemData.num < morenNum then
		-- 		layout.checkBox:setCheckState(not newState)
		-- 		ui.showFlashView({text = TR("药材数量不足")})
		-- 		return
		-- 	end
		-- 	self.mQuality = GoodsModel.items[itemData.ID].quality
		-- 	self.mSelectList[itemData.ID] = morenNum
		-- 	self.curNeedNum = self.curNeedNum - morenNum
		-- 	layout.numSelectParent:setVisible(true)
		-- 	layout.numSelectParent.numLabel:setString(self.mSelectList[itemData.ID])
		-- else
		-- 	self.curNeedNum = self.curNeedNum + self.mSelectList[itemData.ID]
		-- 	self.mSelectList[itemData.ID] = nil
		-- 	layout.numSelectParent:setVisible(false)
		-- 	if self.curNeedNum == self.mNeedHerbsNum then
		-- 		self.mQuality = nil
		-- 	end
		-- end
		-- layout.checkBox:setCheckState(newState)
		self.mSelectList = {}
		self.mSelectExp = 0
		if self.beforeLayout then
			self.beforeLayout.checkBox:setCheckState(false)
			self.beforeLayout.numSelectParent:setVisible(false)
		end

		if not self.beforeLayout or self.beforeLayout ~= layout then
			self.beforeLayout = layout
			layout.checkBox:setCheckState(true)
			self.mSelectList[itemData.ID] = morenNum
			self.mSelectExp = morenNum * itemData.exp
			layout.numSelectParent:setVisible(true)
			layout.numSelectParent.numLabel:setString(morenNum)

			-- 循环调用将药材加大最大
			repeat
				local isComplete = layout.addCallBack(true)
			until(isComplete == false)
		elseif self.beforeLayout == layout then
			self.beforeLayout = nil
			layout.checkBox:setCheckState(false)
			self.mSelectList[itemData.ID] = nil
			self.mSelectExp = 0
			layout.numSelectParent:setVisible(false)
		end
	end

	layout.addCallBack = function (isAdd)
		if isAdd and self.mSelectExp >= self.mLimitExp then
			ui.showFlashView(TR("需要酒材数量已足够"))
			return false
		end

		local curNum = self.mSelectList[itemData.ID]
		if (not isAdd and curNum <= morenNum) or (isAdd and curNum >= itemData.num) then
			return false
		end
		
		local addNum = isAdd and morenAdd or -morenAdd
		local addExp = addNum*itemData.exp

		self.mSelectExp = self.mSelectExp + addExp
		self.mSelectList[itemData.ID] = curNum+addNum
		layout.numSelectParent.numLabel:setString(tostring(self.mSelectList[itemData.ID]))

		return true
	end

	-- 复选框
	local checkBox = ui.newCheckbox({
			callback = function (state)
				layout.checkCallBack(state)
			end,
		})
	checkBox:setPosition(cellSize.width * 0.65, cellSize.height * 0.5)
	layout:addChild(checkBox)
	layout.checkBox = checkBox

	-- 透明按钮（点击选项空白也可以改变复选状态）
	local itemBtn = ui.newButton({
			normalImage = "c_83.png",
			size = cellSize,
			clickAction = function ()
				layout.checkCallBack(not layout.checkBox:getCheckState())
			end
		})
	itemBtn:setPosition(cellSize.width*0.5, cellSize.height*0.5)
	layout:addChild(itemBtn)

	-- 数量选择
	local numSelectParent = cc.Node:create()
	numSelectParent:setPosition(cellSize.width * 0.7, cellSize.height * 0.5)
	layout:addChild(numSelectParent)
	numSelectParent:setVisible(false)
	layout.numSelectParent = numSelectParent

	-- 数量显示
	local numLabel = ui.newLabel({
			text = tostring(morenNum),
			color = cc.c3b(0x46, 0x22, 0x0d),
			size = 22,
		})
	numLabel:setPosition(70, 0)
	numSelectParent:addChild(numLabel)
	numSelectParent.numLabel = numLabel

	-- 减按钮
	local subtractBtn = ui.newButton({
			normalImage = "gd_28.png",
			clickAction = function ()
				layout.addCallBack(false)
			end
		})
	subtractBtn:setPosition(30, 0)
	numSelectParent:addChild(subtractBtn)

	-- 注册定时调用减
	self.registerPressTouch(subtractBtn, function ()
		layout.addCallBack(false)
	end)

	-- 加按钮
	local addBtn = ui.newButton({
			normalImage = "c_21.png",
			clickAction = function ()
				layout.addCallBack(true)
			end
		})
	addBtn:setPosition(120, 0)
	numSelectParent:addChild(addBtn)

	-- 注册定时调用加
	self.registerPressTouch(addBtn, function ()
		layout.addCallBack(true)
	end)

	-- 药材头像卡牌
	local card = CardNode.createCardNode({
			resourceTypeSub = ResourcetypeSub.eFunctionProps,
			modelId = itemData.ID,
			num = itemData.num,
			cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum},
		})
	card:setPosition(cellSize.width*0.15, cellSize.height*0.5)
	layout:addChild(card)

	-- 药材品质等级
	local colorLv = Utility.getQualityColorLv(goodsInfo.quality)

	-- 药材名字
	local nameLabel = ui.newLabel({
			text = goodsInfo.name,
			color = Utility.getColorValue(colorLv, 1),
			outlineColor = Enums.Color.eOutlineColor,
		})
	nameLabel:setAnchorPoint(cc.p(0, 0.5))
	nameLabel:setPosition(160, cellSize.height * 0.75)
	layout:addChild(nameLabel)

	-- 药材资质
	local qualityLabel = ui.newLabel({
			text = TR("资质:%s%d", Enums.Color.eBlackH, goodsInfo.quality),
			color = Enums.Color.eBrown,
		})
	qualityLabel:setAnchorPoint(cc.p(0, 0.5))
	qualityLabel:setPosition(160, cellSize.height * 0.5)
	layout:addChild(qualityLabel)

	-- 星数
	local starNode = ui.newStarLevel(colorLv)
	starNode:setAnchorPoint(cc.p(0, 0.5))
	starNode:setPosition(160, cellSize.height * 0.25)
	layout:addChild(starNode)

	return layout
end

-- 给节点注册按下定时调用回调
function BrewSelectLayer.registerPressTouch(node, callback)
	local isRunning = false

	local function start()
		isRunning = true
		node.delayCallback = Utility.performWithDelay(node, function()
			node.autoCallback = Utility.schedule(node, function ()
				callback()
			end, 0.1)
		end, 0.6)

		-- 首选回调一次
		callback()
	end

	local function stop()
		isRunning = false
		if node.delayCallback and not tolua.isnull(node.delayCallback) then
			node:stopAction(node.delayCallback)
			node.delayCallback = nil
		end

		if node.autoCallback and not tolua.isnull(node.autoCallback) then
			node:stopAction(node.autoCallback)
			node.autoCallback = nil
		end
	end

	local boundingBox = node:getBoundingBox()
	node:addTouchEventListener(function(sender, eventType)
	    if eventType == ccui.TouchEventType.moved then
	        if not isRunning then return end

	        -- 当触点还在控件内部时
	        local touchPos = sender:getTouchMovePosition()
	        touchPos = node:getParent():convertToNodeSpace(touchPos)
	        if cc.rectContainsPoint(boundingBox, touchPos) == true then return end
	    elseif eventType == ccui.TouchEventType.began then
	        start()
	        return
	    end
	    stop()
	end)
end

-- 显示页签
function BrewSelectLayer:showTabLayer()
    -- 创建分页
    local buttonInfos = {
        {
            text = TR("酒材"),
            tag = 1,
        },
    }
    -- 创建分页
    local tabLayer = ui.newTabLayer({
        btnInfos = buttonInfos,
    })

    tabLayer:setPosition(Enums.StardardRootPos.eTabView)
    self.mParentLayer:addChild(tabLayer)
end

return BrewSelectLayer
