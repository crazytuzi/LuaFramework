--[[
	文件名：CampLayer.lua
	描述：布阵页面
	创建人: peiyaoqiang
	创建时间: 2017.03.08
--]]

local CampLayer = class("CampLayer", function()
	return display.newLayer()
end)

-- ====================显示相关==============================
-- 阵容最大个数
local slotCount = 6

-- 控件位置和大小相关变量
local layoutWidth, layoutHeight = 560, 410
local layoutPosX, layoutPosY = 310, 305

local columnMaxCount = 2
local rowCount = math.ceil(slotCount / columnMaxCount) + 1

local heroWidth, heroHeight = 256, 122
local originalPosX, originalPosY = 143, 338
local deltaX, deltaY = 274, 135



-- 构造函数
function CampLayer:ctor()
	-- 布阵信息
	self.mFormation = {}
	self.mPosList = {}
	-- 布阵信息的容器
	self.mBoxNodes = {}
	self.mHeroNodes = {}

	-- 添加弹出框层
	local bgLayer = require("commonLayer.PopBgLayer").new({
		title = TR("布阵"),
		bgSize = cc.size(620, 585),
		closeImg = "c_29.png",
		closeAction = function()
			LayerManager.removeLayer(self)
		end
	})
	self:addChild(bgLayer)

	-- 保存弹窗控件信息
	self.mBgSprite = bgLayer.mBgSprite
	self.mBgSize = bgLayer.mBgSprite:getContentSize()

	-- 初始化UI
	self:initUI()

	-- 获取阵容数据
	self:initData()

	-- 显示布阵
	self:showFormationInfo()
end

-- 初始化UI
function CampLayer:initUI()
	-- 确定按钮
	local comfirmBtn = ui.newButton({
		normalImage = "c_28.png",
		text = TR("保存并退出"),
		size = cc.size(160, 55),
		clickAction = function ()
			self:requestChange()
		end
	})
	comfirmBtn:setAnchorPoint(cc.p(0.5, 0))
	comfirmBtn:setPosition(self.mBgSize.width * 0.5, 30)
	self.mBgSprite:addChild(comfirmBtn)
end

-- 初始化阵容数据
function CampLayer:initData()
	-- 获取布阵数据
	local originalFomation = FormationObj:getEmbattleInfo()
	local changeToIndex = {
		[1] = 2, [2] = 4, 
		[3] = 6, [4] = 1, 
		[5] = 3, [6] = 5,
	}
	for index = 1, slotCount do
		local tmpIndex = changeToIndex[index]
		self.mFormation[tmpIndex] = originalFomation["Formation"..index]

		-- 计算位置
		local tmpPos = {}
		tmpPos.x = originalPosX + deltaX * math.mod(index-1, columnMaxCount)
		tmpPos.y = originalPosY - deltaY * math.floor((index-1) / columnMaxCount)
		self.mPosList[index] = tmpPos
	end
end

-- 显示布阵信息
function CampLayer:showFormationInfo()
	-- 所有英雄的背景
	local heroBgSprite = ui.newScale9Sprite("c_17.png", cc.size(layoutWidth, layoutHeight))
	heroBgSprite:setPosition(layoutPosX, layoutPosY)
	self.mBgSprite:addChild(heroBgSprite)
	
	-- 所有英雄容器
	local heroesLayout = ccui.ScrollView:create()
	heroesLayout:setContentSize(layoutWidth, layoutHeight)
	heroesLayout:setDirection(ccui.ScrollViewDir.vertical)
	heroesLayout:setAnchorPoint(cc.p(0.5, 0.5))
	heroesLayout:setPosition(layoutPosX, layoutPosY)
	self.mBgSprite:addChild(heroesLayout)

	for i = 1, slotCount do
		-- 创建空框架
		local layout = ccui.Layout:create()
		layout:setContentSize(heroWidth, heroHeight)
		layout:setAnchorPoint(cc.p(0.5, 0.5))
		layout:setPosition(self.mPosList[i])
		heroesLayout:addChild(layout)
		self.mBoxNodes[i] = layout

		local heroNode = self:createHeroInfoView(i)
		heroNode.formationIndex = i
		heroesLayout:addChild(heroNode)	
		self.mHeroNodes[i] = heroNode
		
		-- 注册事件
		self:registerDragTouch(heroNode, heroesLayout)
	end
end

--[[
	描述：创建布阵英雄信息
	params:
		index:阵容信息表的下标
	return:
		英雄信息
--]]
function CampLayer:createHeroInfoView(index)
	local heroIndex = self.mFormation[index]
	local data = nil
	if FormationObj:slotIsOpen(heroIndex) and not FormationObj:slotIsEmpty(heroIndex) then
		local slotInfo = FormationObj:getSlotInfoBySlotId(heroIndex)
		data = HeroObj:getHero(slotInfo.HeroId)
	end
	
	-- 容器
	local layout = ccui.Layout:create()
	layout:setContentSize(heroWidth, heroHeight)
	layout:setAnchorPoint(cc.p(0.5, 0.5))
	layout:setPosition(self.mPosList[index])

	-- 背景
	local bgSprite = ui.newScale9Sprite("c_18.png", cc.size(heroWidth, heroHeight))
	bgSprite:setPosition(heroWidth * 0.5, heroHeight * 0.5)
	layout:addChild(bgSprite)

	local tmpBgSprite = ui.newSprite("zr_36.png")
	tmpBgSprite:setPosition(heroWidth * 0.5, heroHeight * 0.5)
	bgSprite:addChild(tmpBgSprite)

    -- 头像背景图片
    local heroHeadBgPic = ui.newScale9Sprite("c_83.png", cc.size(140, heroHeight))
    heroHeadBgPic:setPosition(cc.p(70, heroHeight * 0.5))
    bgSprite:addChild(heroHeadBgPic)

    -- 模板
    local stencilNode = cc.LayerColor:create(cc.c4b(255, 0, 0, 128))
    stencilNode:setContentSize(cc.size(heroWidth, heroHeight + 10))
    stencilNode:setIgnoreAnchorPointForPosition(false)
    stencilNode:setAnchorPoint(cc.p(0.5, 0))
    stencilNode:setPosition(cc.p(72, 2))

    -- 创建剪裁
    local clipNode = cc.ClippingNode:create()
    clipNode:setAlphaThreshold(1.0)
    clipNode:setStencil(stencilNode)
    clipNode:setPosition(cc.p(0, 0))
    heroHeadBgPic:addChild(clipNode)

	-- 属性
	if not data then
		-- 显示一个黑色人物
		local figureNode = ui.newSprite("c_36.png")
		figureNode:setPosition(heroWidth * 0.5, 30)
		figureNode:setScale(0.35)
		clipNode:addChild(figureNode)
	else
		-- 显示人物半身照
		local heroBase = HeroModel.items[data.ModelId] or {}
		Figure.newHero({
        	parent = clipNode,
        	heroModelID = data.ModelId,
        	fashionModelID = PlayerAttrObj:getPlayerAttrByName("FashionModelId"),
        	IllusionModelId = data.IllusionModelId,
            heroFashionId = data.CombatFashionOrder,
    		position = cc.p(72, -140),
    		scale = 0.2,
    		async = function (figureNode)
    		end,
    	})
  		
		-- 显示人物名和等级突破
		local strName, tempStep = ConfigFunc:getHeroName(data.ModelId, {heroStep = data.Step, IllusionModelId = data.IllusionModelId, heroFashionId = data.CombatFashionOrder})
		if tempStep > 0 then
			strName = strName .. "+".. tempStep
		end
		local heroName = ui.newLabel({
			text = strName,
			color = Utility.getQualityColor(heroBase.quality, 1),
	        outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
	        outlineSize = 2,
	        size = 20,
		})
		heroName:setAnchorPoint(cc.p(1, 0.5))
		heroName:setPosition(245, heroHeight * 0.5)
		bgSprite:addChild(heroName)
	end

	return layout
end

--=======================触摸事件相关==============================
--[[
	描述: 注册触摸拖动事件
	params:
		node:注册事件的节点
		parent:该节点的父节点
--]]
function CampLayer:registerDragTouch(node, parent)
	local posOffset = {}

	node:addTouchEventListener(function(sender, eventType)
		local index = node.formationIndex

		if eventType == ccui.TouchEventType.moved then
			--正在拖动
			local touchPos = sender:getTouchMovePosition()
			touchPos = parent:convertToNodeSpace(touchPos)
			node:setPosition(touchPos.x - posOffset.x, touchPos.y - posOffset.y)
		elseif eventType == ccui.TouchEventType.began then
			-- 开始拖动
			local touchPos = sender:getTouchBeganPosition()
			touchPos = parent:convertToNodeSpace(touchPos)
			posOffset.x = touchPos.x - self.mPosList[index].x
			posOffset.y = touchPos.y - self.mPosList[index].y

			node:setLocalZOrder(rowCount + 1)
		else
			-- 拖动结束
			local touchPos = sender:getTouchEndPosition()
			touchPos = parent:convertToNodeSpace(touchPos)
			-- 生成英雄中心点
        	local heroCenterPos = {
        		x = touchPos.x - posOffset.x,
        		y = touchPos.y - posOffset.y,
        	}
        	-- 判断当前阵型中的位置
        	for i, config in ipairs(self.mPosList) do
        		local boundingBox = self.mBoxNodes[i]:getBoundingBox()
        		if cc.rectContainsPoint(boundingBox, heroCenterPos) then
        			-- 进行交换
        			if self:exchangeFormation(index, i) then
        				return
        			else
        				break
        			end
        		end
        	end
        	self:moveTo(node, self.mPosList[index].x, self.mPosList[index].y)
        	node:setLocalZOrder(rowCount)
		end
	end)
	node:setTouchEnabled(true)
end

-- 位置交换
--[[
	描述：位置交换
	params
		index1:交换位置的第一个英雄的下标
		index2:交换位置的第二个英雄的下标
--]]
function CampLayer:exchangeFormation(index1, index2)
	if index1 == index2 then return false end

	local node1 = self.mHeroNodes[index1]
	local node2 = self.mHeroNodes[index2]
	local heroIndex1 = self.mFormation[index1]
	local heroIndex2 = self.mFormation[index2]

	-- 当可以进行交换时
	self:moveTo(node1, self.mPosList[index2].x, self.mPosList[index2].y)
    node1:setLocalZOrder(rowCount)
    node1.formationIndex = index2

    self.mFormation[index2] = heroIndex1
    self.mHeroNodes[index2] = node1

    self.mFormation[index1] = heroIndex2
    self.mHeroNodes[index1] = node2

    -- 当2不为空时
    if node2 ~= nil then
		self:moveTo(node2, self.mPosList[index1].x, self.mPosList[index1].y)
        node2:setLocalZOrder(rowCount)
        node2.formationIndex = index1
	end

    return true
end

--- ==================== 特效动作相关 =========================
-- 移动动画
function CampLayer:moveTo(node, x, y)
	local moveAction = cc.MoveTo:create(0.2, cc.p(x, y))
    node:runAction(cc.EaseBackOut:create(moveAction))
end

--- ==================== 服务器数据请求相关 =======================
-- 阵型调整
function CampLayer:requestChange()
	local changeToIndex = {
		[1] = 2, [2] = 4, 
		[3] = 6, [4] = 1, 
		[5] = 3, [6] = 5,
	}
	local tmpFormation = {}
	for i=1,slotCount do
		tmpFormation[i] = self.mFormation[changeToIndex[i]]
	end

	HttpClient:request({
    	moduleName = "SlotFormation",
    	methodName = "Change",
    	svrMethodData = tmpFormation,
    	callback = function(response)
    	    if response.Status == 0 then
    	        -- 修改缓存数据
    	        local formation = {}
    	        for i = 1, slotCount do
    	        	formation["Formation"..i] = tmpFormation[i]
    	        end
    	        FormationObj:updateEmbattleInfo(formation)

    	        ui.showFlashView(TR("保存布阵成功"))
    	        LayerManager.removeLayer(self)
    	    end
    	end
	})
end

return CampLayer
