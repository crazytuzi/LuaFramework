--[[
	文件名：GGZJFormationLayer.lua
	描述：大罗金库我方阵容页面
	创建人：suntao
	修改人：lengjiazhi
	创建时间：2016.6.7
--]]

local GGZJFormationLayer = class("GGZJFormationLayer", function()
    return display.newLayer()
end)

-- 预定义量
local OwnHeroesCount = 6
local GuildHeroNum = OwnHeroesCount + 1
local SystemHeroNum = OwnHeroesCount + 1

-- 构造函数
--[[
	params:
	{
		(可选参数) 服务器中 GGZJ 模块 GetGGZJInfo 方法返回的数据
		playerInfo
		nodeInfo
	}
--]]
function GGZJFormationLayer:ctor(params)
    params = params or {}
	-- 变量
	self.mHeroesData = {}
	self.mFormation = {}
	self.mPosList = nil

	-- 阵容位置为键值的控件
	self.mHeroNodes = {}
	self.mShadowNodes = {}
	self.mBoxNodes = {}

	-- 创建控件
	self:createLayer()

	--
	self:requestGetGGZJInfo()
end

-- 初始化数据
function GGZJFormationLayer:initData()
	-- 变量
	self.mHasGuildHero = self.mPlayerInfo.ShareType == 1
	self.mHasSystemHero = self.mPlayerInfo.ShareType == 2
	if self.mHasGuildHero and self.mHasSystemHero then
		SystemHeroNum = GuildHeroNum + 1
	end

	-- 生成数据并刷新显示
	if self:getSlotsData(self.mPlayerInfo) then
		self:correspond()
		self:showInfo()
	end
end

-- 初始化界面
function GGZJFormationLayer:createLayer()
	local bgLayer = require("commonLayer.PopBgLayer").new({
		title = TR("布阵"),
		bgSize = cc.size(620, 700),
		closeImg = "c_29.png",
		closeAction = function()
			LayerManager.removeLayer(self)
		end
	})
	self:addChild(bgLayer)

    self.mBgLayer = bgLayer.mBgSprite
    self.mBgSize = self.mBgLayer:getContentSize()
end

--- ==================== 数据相关 =========================
-- 获取卡槽数据
function GGZJFormationLayer:getSlotsData(originalData)
	self.mHeroesData = {}
	-- 普通槽位
	for i=1, OwnHeroesCount do
		if FormationObj:slotIsOpen(i) and not FormationObj:slotIsEmpty(i) then
			local slotInfo = FormationObj:getSlotInfoBySlotId(i)
			local heroData = HeroObj:getHero(slotInfo.HeroId)
			self.mHeroesData[i] = {
				HeroModelId = heroData.ModelId,
				Lv = heroData.Lv,
				Step = heroData.Step,
				IllusionModelId = heroData.IllusionModelId,
                CombatFashionOrder = heroData.CombatFashionOrder,
			}
		end
	end

	-- 系统佣兵
	if self.mHasSystemHero then
		local heroData = XrxsSystemHeroRelation.items[originalData.HeroLv][originalData.HeroModelId]
		self.mHeroesData[SystemHeroNum] = {
			HeroModelId = heroData.heroModelID,
			Lv = heroData.LV,
			Step = heroData.step,
		}
	end

	-- 帮派佣兵
	if self.mHasGuildHero then
		self:requestGetGuildShare(GuildHeroNum, originalData.ShareId)
		return false
	end

	return true
end

-- 卡槽号对应阵容位置
function GGZJFormationLayer:correspond()
	local changeToIndex = {
		[1] = 2, [2] = 4, 
		[3] = 6, [4] = 1, 
		[5] = 3, [6] = 5,
		[7] = 7,
	}
	for i = 1, SystemHeroNum do
		self.mFormation[changeToIndex[i]] = self.mPlayerInfo["Formation"..i]
	end

	-- 取出7号位的坐标,邀请师傅刷新页面使用
	if self.mMarked then
		return
	end

	for index, item in pairs(self.mFormation) do
		if item == 7 then
			self.mIndexMark = index
			self.mMarked = true
			break
		end
	end
end

--- ==================== 显示相关 =======================
-- 控件大小与位置等显示相关变量
local LayoutPosX, LayoutPosY = 310, 365
local LayoutWidth, LayoutHeight = 560, 540
local HeroWidth, HeroHeight = 256, 122
local ColumnMaxCount = 2

local RowCount = math.ceil(OwnHeroesCount / ColumnMaxCount) + 1
local originalPosX, originalPosY = 143, 405
local deltaX, deltaY = 274, 130

-- 刷新显示
function GGZJFormationLayer:showInfo()
	-- 计算控件参数
	self.mPosList = self:heroPos()

	-- 半透明背景
    local heroBgSprite = ui.newScale9Sprite("c_17.png", cc.size(LayoutWidth - 10, LayoutHeight))
	heroBgSprite:setPosition(LayoutPosX, LayoutPosY)
	self.mBgLayer:addChild(heroBgSprite)

	-- 所有英雄容器
    local heroesLayout = ccui.ScrollView:create()
	heroesLayout:setContentSize(LayoutWidth, LayoutHeight)
	heroesLayout:setDirection(ccui.ScrollViewDir.vertical)
	heroesLayout:setAnchorPoint(cc.p(0.5, 0.5))
	heroesLayout:setPosition(LayoutPosX, LayoutPosY)
	self.mBgLayer:addChild(heroesLayout)
	self.mHeroesLayout_ = heroesLayout

    local HeroNum
    if self.mHasSystemHero or self.mHasGuildHero then
    	HeroNum = 7
	else
		HeroNum = 6
    end

	for i = 1, HeroNum do
		-- 新建英雄
		local layout = self:createHeroInfoView(i)
		if layout ~= nil then
			heroesLayout:addChild(layout)
			self.mHeroNodes[i] = layout
			layout.formationIndex = i

			-- 注册触摸事件
			self:registerDragTouch(layout, heroesLayout)
		end
        self.mBoxNodes[i] = layout
	end

	-- 如果没有佣兵
	if not self.mHasGuildHero and not self.mHasSystemHero then
		for num = GuildHeroNum, SystemHeroNum do
			local layout = self:createEmptyMercenaryView(num)
			heroesLayout:addChild(layout)
			self.mHeroNodes[7] = layout
			layout.formationIndex = 7
			self.mBoxNodes[7] = layout
		end
	end

	-- 确定按钮
	local button = ui.newButton({
    	text = TR("确定"),
    	fontSize = 27,
    	textColor = Enums.Color.eWhite,
        normalImage = "c_28.png",
        size = cc.size(140, 60),
        position = cc.p(self.mBgSize.width * 0.72, 55),
        clickAction = function()
            -- 通知父结点的引导继续
            Notification:postNotification(EventsName.eGameLayerPrefix .. "challenge.GGZJLayer")
        	LayerManager.removeLayer(self)
        end
    })
    self.mBgLayer:addChild(button)
    button:setVisible(false)
    self.mOkBtn = button

	-- 更多佣兵按钮
	self.mMoreBtn = ui.newButton({
		text = TR("更多佣兵"),
		textColor = Enums.Color.eWhite,
		normalImage = "c_28.png",
			size = cc.size(140, 60),
			position = cc.p(self.mBgSize.width * 0.25, 55),
			clickAction = function ()
				LayerManager.addLayer({
	            name = "challenge.GGZJRecruitLayer",
	            cleanUp = true,
	    	})
			end
	})
	self.mBgLayer:addChild(self.mMoreBtn)
	self.mMoreBtn:setVisible(false)

	-- 调整确定按钮位置
	if self.mHasGuildHero or self.mHasSystemHero then
		self.mMoreBtn:setVisible(true)
		self.mOkBtn:setVisible(true)
		self.mOkBtn:setPositionX(self.mBgSize.width * 0.72)
	else
		self.mMoreBtn:setVisible(false)
		self.mOkBtn:setVisible(true)
		self.mOkBtn:setPositionX(self.mBgSize.width * 0.5)
	end
end

-- 位置计算
function GGZJFormationLayer:heroPos()
	local formationPos = {}

	--拥有的武将位置
	for num = 1, OwnHeroesCount do
		formationPos[num] = {}
		formationPos[num].x = originalPosX + deltaX * math.mod(num-1, ColumnMaxCount)
		formationPos[num].y = originalPosY - deltaY * math.floor((num-1) / ColumnMaxCount)
	end

	--招募的佣兵位置
	local num = OwnHeroesCount + 1
	formationPos[num] = {}
	formationPos[num].x = 280
	formationPos[num].y = 15
	return formationPos
end

-- 创建英雄信息
function GGZJFormationLayer:createHeroInfoView(index)
	local heroIndex = self.mFormation[index]
	local data = self.mHeroesData[heroIndex]

	-- 作为玩家和师傅头像区分的依据
	if heroIndex == 1 then
		data.IsSelf = true
	end

	-- 容器
	local layout = ccui.Layout:create()
	layout:setContentSize(HeroWidth, HeroHeight)
	layout:setAnchorPoint(0.5, 0)
	layout:setPosition(self.mPosList[index])

    --背景
    local bgSprite = ui.newScale9Sprite("c_18.png", cc.size(HeroWidth, HeroHeight))
    bgSprite:setPosition(HeroWidth / 2, HeroHeight / 2)
    layout.bgSprite = bgSprite
    layout:addChild(bgSprite)

    local tmpBgSprite = ui.newSprite("zr_36.png")
	tmpBgSprite:setPosition(HeroWidth * 0.5, HeroHeight * 0.5)
	bgSprite:addChild(tmpBgSprite)

	-- 头像背景图片
    local heroHeadBgPic = ui.newScale9Sprite("c_83.png", cc.size(140, HeroHeight))
    heroHeadBgPic:setPosition(cc.p(70, HeroHeight * 0.5))
    bgSprite:addChild(heroHeadBgPic)

    -- 模板
    local stencilNode = cc.LayerColor:create(cc.c4b(255, 0, 0, 0))
    stencilNode:setContentSize(cc.size(HeroWidth, HeroHeight + 10))
    stencilNode:setIgnoreAnchorPointForPosition(false)
    stencilNode:setAnchorPoint(cc.p(0.5, 0))
    stencilNode:setPosition(cc.p(72, 2))

    -- 创建剪裁
    local clipNode = cc.ClippingNode:create()
    clipNode:setAlphaThreshold(1.0)
    clipNode:setStencil(stencilNode)
    clipNode:setPosition(cc.p(0, 0))
    heroHeadBgPic:addChild(clipNode)

    -- 显示人物
    local function showFigureNode(heroData)
    	if heroData then
    		-- 显示人物半身照
			local heroBase = HeroModel.items[heroData.HeroModelId] or {}
			Figure.newHero({
	        	parent = clipNode,
	        	heroModelID = heroData.HeroModelId,
	        	fashionModelID = PlayerAttrObj:getPlayerAttrByName("FashionModelId"),
	        	IllusionModelId = heroData.IllusionModelId,
                heroFashionId = heroData.CombatFashionOrder,
	    		position = cc.p(72, -140),
	    		scale = 0.2,
	    		async = function (figureNode)
	    		end,
	    	})
	  		
			-- 显示人物名和等级突破
			local strName, tempStep = ConfigFunc:getHeroName(heroData.HeroModelId, {heroStep = heroData.Step, IllusionModelId = heroData.IllusionModelId, heroFashionId = heroData.CombatFashionOrder})
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
			heroName:setPosition(245, HeroHeight * 0.5)
			bgSprite:addChild(heroName)
    	else
    		-- 显示一个黑色人物
			local figureNode = nil
			figureNode = ui.newSprite("c_36.png")
			figureNode:setPosition(HeroWidth * 0.5, 30)
			figureNode:setScale(0.35)
			clipNode:addChild(figureNode)
    	end
    end
    showFigureNode(data)
 
    return layout
end

-- 创建空佣兵
function GGZJFormationLayer:createEmptyMercenaryView(index)
	-- 容器
	local layout = ccui.Layout:create()
	layout:setAnchorPoint(0.5, 0)
	layout:setContentSize(HeroWidth, HeroHeight)
	layout:setPosition(self.mPosList[index])

	--卡牌背景
	local bgSprite = ui.newScale9Sprite("c_18.png", cc.size(HeroWidth, HeroHeight))
    bgSprite:setPosition(HeroWidth / 2, HeroHeight / 2)
    layout.bgSprite = bgSprite
    layout:addChild(bgSprite)

    local tmpBgSprite = ui.newSprite("zr_36.png")
	tmpBgSprite:setPosition(HeroWidth * 0.5, HeroHeight * 0.5)
	bgSprite:addChild(tmpBgSprite)

	-- 头像背景图片
    local heroHeadBgPic = ui.newScale9Sprite("c_83.png", cc.size(140, HeroHeight))
    heroHeadBgPic:setPosition(cc.p(70, HeroHeight * 0.5))
    bgSprite:addChild(heroHeadBgPic)

    -- 模板
    local stencilNode = cc.LayerColor:create(cc.c4b(255, 0, 0, 0))
    stencilNode:setContentSize(cc.size(HeroWidth, HeroHeight + 10))
    stencilNode:setIgnoreAnchorPointForPosition(false)
    stencilNode:setAnchorPoint(cc.p(0.5, 0))
    stencilNode:setPosition(cc.p(72, 2))

    -- 创建剪裁
    local clipNode = cc.ClippingNode:create()
    clipNode:setAlphaThreshold(1.0)
    clipNode:setStencil(stencilNode)
    clipNode:setPosition(cc.p(0, 0))
    heroHeadBgPic:addChild(clipNode)

    -- 显示一个黑色人物
	local figureNode = nil
	figureNode = ui.newSprite("c_36.png")
	figureNode:setPosition(HeroWidth * 0.5, 30)
	figureNode:setScale(0.35)
	clipNode:addChild(figureNode)

	-- 显示加号按钮
	local button = ui.newButton({
    	normalImage = "c_22.png",
        position = cc.p(HeroWidth * 0.5, HeroHeight * 0.5 + 5),
        clickAction = function()
        	LayerManager.addLayer({name = "challenge.GGZJRecruitLayer",})
        end
    })
    bgSprite:addChild(button)
    self.newRecruitBtn = button
    
	-- 提示文字
	local label = ui.newLabel({
		text = TR("点击招募佣兵"),
		size = 20,
		outlineColor = Enums.Color.eOutlineColor,
		})
	label:setPosition(HeroWidth * 0.5, HeroHeight * 0.2)
	bgSprite:addChild(label)
	
	return layout
end

--- ==================== 触摸相关 =======================
-- 为拖动注册触摸事件
function GGZJFormationLayer:registerDragTouch(node, parent)
	local posOffset = {}
    node:addTouchEventListener(function(sender, eventType)
    	local index = node.formationIndex

        if eventType == ccui.TouchEventType.moved then
        	-- 正在拖动
        	local touchPos = sender:getTouchMovePosition()
        	touchPos = parent:convertToNodeSpace(touchPos)
        	node:setPosition(touchPos.x - posOffset.x, touchPos.y - posOffset.y)
        elseif eventType == ccui.TouchEventType.began then
        	-- 开始拖动
        	local touchPos = sender:getTouchBeganPosition()
        	touchPos = parent:convertToNodeSpace(touchPos)
            posOffset.x = touchPos.x - self.mPosList[index].x
            posOffset.y = touchPos.y - self.mPosList[index].y

           	node:setLocalZOrder(1)
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
        	local boxNum
        	if self.mHasGuildHero or self.mHasSystemHero then
        		boxNum = 7
    		else
    			boxNum = 6
    		end
        	for i = 1, boxNum do
        		local boundingBox = self.mBoxNodes[i]:getBoundingBox()
        		if cc.rectContainsPoint(boundingBox, heroCenterPos) then
        			-- 进行交换
        			if self:exchangeFormation(index, i) then
        				self:requestFormationChang()
        				return
        			else
        				break
        			end
        		end
        	end

        	self:moveTo(node, self.mPosList[index].x, self.mPosList[index].y)
        	node:setLocalZOrder(0)
        end
    end)
    node:setTouchEnabled(true)
end

-- 位置互换
function GGZJFormationLayer:exchangeFormation(index1, index2)
	-- body
	if index1 == index2 then return false end

	local ret = false

	local node1 = self.mHeroNodes[index1]
	local node2 = self.mHeroNodes[index2]
	local heroIndex1 = self.mFormation[index1]
	local heroIndex2 = self.mFormation[index2]

	-- 主角不能换到佣兵阵位
	if self.mHeroesData[heroIndex1] ~= nil then
		local heroModelID = self.mHeroesData[heroIndex1].HeroModelId
		if HeroModel.items[heroModelID].specialType == Enums.HeroType.eMainHero and index2 > OwnHeroesCount
			and self.mHeroesData[heroIndex1].IsSelf then
			ui.showFlashView(TR("主角不能换到佣兵阵位!!!"))
			return false
		end
	end

	if self.mHeroesData[heroIndex2] ~= nil then
		local heroModelID = self.mHeroesData[heroIndex2].HeroModelId
		if HeroModel.items[heroModelID].specialType == Enums.HeroType.eMainHero and index1 > OwnHeroesCount
			and self.mHeroesData[heroIndex2].IsSelf then
			ui.showFlashView(TR("主角不能换到佣兵阵位!!!"))
			return false
		end
	end

	-- 当可以进行交换时
	if node2 ~= nil or index2 <= OwnHeroesCount
			or (index2 == GuildHeroNum and self.mHasGuildHero)
			or (index2 == SystemHeroNum and self.mHasSystemHero) then
		self:moveTo(node1, self.mPosList[index2].x, self.mPosList[index2].y)
        node1:setLocalZOrder(0)
        node1.formationIndex = index2

        self.mFormation[index2] = heroIndex1
        self.mHeroNodes[index2] = node1

        self.mFormation[index1] = heroIndex2
        self.mHeroNodes[index1] = node2

        -- 当2不为空时
        if node2 ~= nil then
			self:moveTo(node2, self.mPosList[index1].x, self.mPosList[index1].y)
	        node2:setLocalZOrder(0)
	        node2.formationIndex = index1
		end

		-- formation7 位置index标记
		if index1 == 7 then
			self.mIndexMark = index2
		elseif index2 == 7 then
			self.mIndexMark = index1
		end

        return true
	end

	return false
end

--- ==================== 特效相关 =========================
-- 移动动画
function GGZJFormationLayer:moveTo(node, x, y)
	local moveAction = cc.MoveTo:create(0.2, cc.p(x, y))
    node:runAction(cc.EaseBackOut:create(moveAction))
end

--- ==================== 服务器数据请求相关 =======================
-- 获取共享英雄数据
function GGZJFormationLayer:requestGetGuildShare(heroIndex, id)
	HttpClient:request({
		moduleName = "Guild",
		methodName = "GetGuildShare",
		callback = function(response)
		    if response.Status ~= 0 then return end

	        -- 添加帮派雇佣兵信息
	        local infos = response.Value.GuildShareInfo
	        for _, item in pairs(infos) do
	        	if item.ShareId == id then
	        		local shareHeroName = HeroModel.items[item.ModelId].name
	        		self.mHeroesData[heroIndex] = {
	        			HeroModelId = item.ModelId,
                        IllusionModelId = item.IllusionModelId,
	        			Lv = item.Lv,
	        			Step = item.Step,
                        CombatFashionOrder = item.CombatFashionOrder,
	        			specialHeroName = shareHeroName or TR("帮派佣兵"),
	        		}
	        		break
	        	end
	        end
	        -- 调用刷新
	        self:correspond()
	        self:showInfo()
		end
	})
end

-- 获取总信息
function GGZJFormationLayer:requestGetGGZJInfo()
	HttpClient:request({
    	moduleName = "XrxsInfo",
    	methodName = "GetInfo",
    	callback = function(response)
    	    if response.Status == 0 then
    	        self.mPlayerInfo = response.Value.Info
    	        self.mNodeInfo = response.Value.NodeInfo
                
                self:initData()

                Utility.performWithDelay(self.mBgLayer, handler(self, self.executeGuide), 0.25)
    	    end
    	end
	})
end

-- 阵型调整
function GGZJFormationLayer:requestFormationChang()
	local changeToIndex = {
		[1] = 2, [2] = 4, 
		[3] = 6, [4] = 1, 
		[5] = 3, [6] = 5,
		[7] = 7,
	}
	local tmpFormation = {}
	for i=1,SystemHeroNum do
		tmpFormation[i] = self.mFormation[changeToIndex[i]]
	end

	HttpClient:request({
    	moduleName = "XrxsInfo",
    	methodName = "FormationChang",
    	svrMethodData = tmpFormation,
        guideInfo = Guide.helper:tryGetGuideSaveInfo(4007),
    	callback = function(response)
    	    if response.Status == 0 then
    	        print("------------------ requestFormationChang success")
                --[[--------新手引导--------]]--
                local _, _, eventID = Guide.manager:getGuideInfo()
                if eventID == 4007 then
                    Guide.manager:nextStep(eventID)
                    self:executeGuide()
                end
    	    end
    	end
	})
end

-- 执行新手引导
function GGZJFormationLayer:executeGuide()
    local _, _, eventID = Guide.manager:getGuideInfo()
    if eventID == 4004 and (self.mHasSystemHero or self.mHasGuildHero) then
        -- 已上阵佣兵，引导取消
        Guide.helper:guideError(eventID, -1)
    end
    Guide.helper:executeGuide({
        -- 获取佣兵令
        [4003] = {nextStep = function(eventID, isGot)
            if isGot then
                -- 领取服务器物品成功执行下一步
                Guide.manager:nextStep(4003)
            end
            self:executeGuide()
        end},
        -- 点击+号
        [4004] = {clickNode = self.newRecruitBtn},
        -- 指引滑动布阵
        [4007] = {clickNode = self.mBoxNodes[7] and self.mBoxNodes[7].bgSprite, dragToNode = self.mBoxNodes[5] and self.mBoxNodes[5].bgSprite, hintPos = cc.p(display.cx, 820 * Adapter.MinScale)},
        -- 点击确定关闭
        [4008] = {clickNode = self.mOkBtn},
    })
end

return GGZJFormationLayer
