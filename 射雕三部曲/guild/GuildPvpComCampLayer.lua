--[[
	文件名：GuildPvpComCampLayer.lua
	描述：帮派战斗布阵界面
	创建人：peiyaoqiang
	创建时间： 2018.1.5
--]]

local GuildPvpComCampLayer = class("GuildPvpComCampLayer", function(params)
	return display.newLayer()
end)

-- 控件大小与位置等显示相关变量
local HeroWidth, HeroHeight = 256, 122

--[[
params = {
	FormationData = {
		{
            "HeroModelId" = 12011601,
            "HeroLv" = 1,
            "Step" = 0,
            "Formation" = 4, 	-- 修改布阵后提交给服务器用
        },
        {},
        ...
	}
	titleText 			标题，默认为“布阵”
	playerId 			玩家Id，招募佣兵的时候使用
	playerName 			玩家名字，为了替换主角的名字
	isLookCamp          是否仅为查看布阵，默认为false

	recruitCallBack,	招募回调
	exchangeCallBack,	交换位置回调
	closeCallBack,		对话框关闭的回调
}
--]]
function GuildPvpComCampLayer:ctor(params)
    --dump(params, "params")
    -- 预定义量
    self.mFormationData = {}
    self.OwnHeroesCount = 7    -- 角色栏位数量
    self.layoutSize = cc.size(560, 540)
    self.layoutPos = cc.p(310, 365)

    -- 读取参数
    self.mRecruitCallBack = params.recruitCallBack
    self.mExchangeCallBack = params.exchangeCallBack
    self.mCloseCallBack = params.closeCallBack
    self.mFashionId = params.FormationData.FashionModelId or 0
    
    self.mPlayerId = params.playerId
    self.mPlayerName = params.playerName
    self.isLookCamp = params.isLookCamp or false
	
    -- 计算所有人物位置的列表（竖排出手顺序）
    local bgHeight = 570
	self.mPosList = {
		cc.p(417, 466), cc.p(417, 336), cc.p(417, 206), 
		cc.p(143, 466), cc.p(143, 336), cc.p(143, 206), 
	}
    if not self.isLookCamp then
        table.insert(self.mPosList, cc.p(280, 76))
        bgHeight = 700
    else
        -- 查看布阵时，不显示招募
        self.OwnHeroesCount = 6
        for i,v in ipairs(self.mPosList) do
            v.y = v.y - 130
        end
        self.layoutSize.height = self.layoutSize.height - 130
        self.layoutPos.y = self.layoutPos.y - 70
    end

    -- 按照出手顺序构造数据
    for i = 1, self.OwnHeroesCount do
        self.mFormationData[i] = params.FormationData[tostring(i)] or {}
    end
    
	-- 创建背景框
	local bgLayer = require("commonLayer.PopBgLayer").new({
		title = params.titleText or TR("布阵"),
		bgSize = cc.size(620, bgHeight),
		closeImg = "c_29.png",
		closeAction = function()
			if self.mCloseCallBack then
            	self.mCloseCallBack()
            end
			LayerManager.removeLayer(self)
		end
	})
	self:addChild(bgLayer)

    self.mBgLayer = bgLayer.mBgSprite
    self.mBgSize = self.mBgLayer:getContentSize()

    -- 初始化UI
    self:initUI()
end

-- 刷新显示
function GuildPvpComCampLayer:initUI()
	-- 半透明背景
    local heroBgSprite = ui.newScale9Sprite("c_17.png", self.layoutSize)
	heroBgSprite:setPosition(self.layoutPos)
	self.mBgLayer:addChild(heroBgSprite)

	-- 创建所有侠客
	self.mItemData = {}
	for i = 1, self.OwnHeroesCount do
		local heroData = self.mFormationData[i]
		local layout = self:createEmptyLayout(i)
		heroBgSprite:addChild(layout)

		-- 显示内容
		if (heroData.HeroModelId == nil) or (heroData.HeroModelId == 0) then
			self:addMercenaryView(layout, (heroData.Formation == 7))
		else
			self:addHeroInfoView(layout, heroData)
		end
		self.mItemData[i] = {showIndex = i, pos = self.mPosList[i], nodeSprite = layout, data = heroData}
	end
    -- 非查看布阵可拖动
    if not self.isLookCamp then
	   ui.registerSwallowTouch({
            node = heroBgSprite,
            allowTouch = false,
            beganEvent = function(touch, event)
                local touchPos = heroBgSprite:convertTouchToNodeSpace(touch)
                self:onBeganEvent(touchPos.x, touchPos.y)
                return true
            end,
            movedEvent = function(touch, event)
                local touchPos = heroBgSprite:convertTouchToNodeSpace(touch)
                self:onMovedEvent(touchPos.x, touchPos.y)
            end,
            endedEvent = function(touch, event)
                local touchPos = heroBgSprite:convertTouchToNodeSpace(touch)
                self:onEndedEvent(touchPos.x, touchPos.y)
            end,
        })
    end

	-- 确定按钮
	local button = ui.newButton({
		normalImage = "c_28.png",
    	text = TR("确定"),
        position = cc.p(self.mBgSize.width * 0.5, 55),
        clickAction = function()
            if self.mCloseCallBack then
            	self.mCloseCallBack()
            end
        	LayerManager.removeLayer(self)
        end
    })
    self.mBgLayer:addChild(button)
end

-- 创建英雄信息
function GuildPvpComCampLayer:createEmptyLayout(index)
	-- 容器
	local layout = ccui.Layout:create()
	layout:setContentSize(HeroWidth, HeroHeight)
	layout:setAnchorPoint(0.5, 0.5)
	layout:setPosition(self.mPosList[index])

    --背景
    local bgSprite = ui.newScale9Sprite("c_18.png", cc.size(HeroWidth, HeroHeight))
    bgSprite:setPosition(HeroWidth / 2, HeroHeight / 2)
    layout:addChild(bgSprite)
    layout.bgSprite = bgSprite

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
    layout.clipNode = clipNode

    return layout
end

-- 创建英雄信息
function GuildPvpComCampLayer:addHeroInfoView(layout, heroData)
	if heroData then
		-- 显示人物半身照
		local heroBase = HeroModel.items[heroData.HeroModelId] or {}
        local illusionModelId = (type(heroData.IllusionModelId) == type(0)) and heroData.IllusionModelId or ConfigFunc:getIllusionModelId(heroData.IllusionModelId)
        local heroFashionId = heroData.CombatFashionOrder
        Figure.newHero({
            parent = layout.clipNode,
            heroModelID = heroData.HeroModelId,
            fashionModelID = self.mFashionId,
            IllusionModelId = illusionModelId,
            heroFashionId = heroFashionId,
            position = cc.p(72, -140),
            scale = 0.2,
            async = function (figureNode)
            end,
        })
        
        -- 显示人物名和等级突破
		local strName, tempStep = ConfigFunc:getHeroName(heroData.HeroModelId, {heroStep = heroData.Step, IllusionModelId = illusionModelId, heroFashionId = heroFashionId, playerName = self.mPlayerName})
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
		layout.bgSprite:addChild(heroName)

        -- 显示战力
        if (heroData.FAP ~= nil) and (heroData.FAP > 0) then
            local fapLabelWithBg = ui.createLabelWithBg({
                bgFilename = "c_23.png",
                labelStr = Utility.numberFapWithUnit(heroData.FAP),
                fontSize = 18,
                outlineColor = cc.c3b(0x0F, 0x0F, 0x0F),
                alignType = ui.TEXT_ALIGN_CENTER,
            })
            fapLabelWithBg:setPosition(190, HeroHeight * 0.2)
            layout.bgSprite:addChild(fapLabelWithBg, 1)

            local fapSprite = ui.newSprite("c_127.png")
            fapSprite:setPosition(135, HeroHeight * 0.2)
            layout.bgSprite:addChild(fapSprite, 1)
        end
	else
		-- 显示一个黑色人物
		local figureNode = ui.newSprite("c_36.png")
		figureNode:setPosition(HeroWidth * 0.5, 30)
		figureNode:setScale(0.35)
		layout.clipNode:addChild(figureNode)
	end
end

-- 创建空佣兵
function GuildPvpComCampLayer:addMercenaryView(layout, isShareGrid)
	-- 显示一个黑色人物
	local figureNode = ui.newSprite("c_36.png")
	figureNode:setPosition(HeroWidth * 0.5, 30)
	figureNode:setScale(0.35)
	layout.clipNode:addChild(figureNode)

	-- 显示加号按钮
	if isShareGrid then
		local button = ui.newButton({
	    	normalImage = "c_22.png",
	        position = cc.p(HeroWidth * 0.5, HeroHeight * 0.5 + 5),
	        clickAction = function()
	        	if self.mRecruitCallBack then
	        		self.mRecruitCallBack()
	        	end
	        end
	    })
	    layout.bgSprite:addChild(button)
	    
		-- 提示文字
		local label = ui.newLabel({
			text = TR("点击招募佣兵"),
			size = 20,
			outlineColor = Enums.Color.eOutlineColor,
		})
		label:setPosition(HeroWidth * 0.5, HeroHeight * 0.2)
		layout.bgSprite:addChild(label)
	end
end

----------------------------------------------------------------------------------------------------

-- 辅助函数：返回点击位置所处的node
function GuildPvpComCampLayer:getClickItem(posX, posY)
    local retItem = nil
    local nodeHalfW, nodeHalfH = HeroWidth/2, HeroHeight/2
    for _,v in ipairs(self.mItemData) do
        local pos = v.pos
        if ((posX >= (pos.x - nodeHalfW)) and (posX <= (pos.x + nodeHalfW)) and (posY >= pos.y - nodeHalfH) and (posY <= (pos.y + nodeHalfH))) then
            retItem = v
            break
        end
    end

    return retItem
end

function GuildPvpComCampLayer:onBeganEvent(posX, posY)
    -- 找到被点击的node，并记录当前位置
    self.lastClickPos = nil     -- 记录移动位置
    self.lastNodePos = nil      -- 记录node位置
    self.clickItem = self:getClickItem(posX, posY)
    if (self.clickItem ~= nil) then
        self.clickItem.nodeSprite:setLocalZOrder(2)
        self.lastNodePos = self.clickItem.pos
    else
        self.clickItem = nil
    end
end

function GuildPvpComCampLayer:onMovedEvent(posX, posY)
    -- 和上个位置距离超过3才移动
    if (self.lastClickPos == nil) then
        self.lastClickPos = cc.p(posX, posY)
    else
        local xOffset = posX - self.lastClickPos.x
        local yOffset = posY - self.lastClickPos.y
        if ((math.abs(xOffset) >= 3) or (math.abs(yOffset) >= 3)) then
            if ((self.clickItem ~= nil) and (self.lastNodePos ~= nil)) then
                self.lastNodePos = cc.p(self.lastNodePos.x + xOffset, self.lastNodePos.y + yOffset)
                self.clickItem.nodeSprite:setPosition(self.lastNodePos)
            end
            self.lastClickPos = cc.p(posX, posY)
        end
    end
end

function GuildPvpComCampLayer:onEndedEvent(posX, posY)
    if ((self.clickItem == nil) or (self.lastClickPos == nil)) then
        return
    end
    
    -- 计算落点的位置，判断是否可以交换
    local endItem = self:getClickItem(posX, posY)
    local function filterExchange()
    	if (endItem == nil) or (endItem.showIndex == self.clickItem.showIndex) then
    		return false
    	end
        if (self.clickItem.showIndex == 7) and (self.clickItem.data.HeroModelId == 0) then
            ui.showFlashView(TR("您尚未招募佣兵!!!"))
            return false
        end
    	if (endItem.showIndex == 7) and (endItem.data.HeroModelId == 0) then
    		ui.showFlashView(TR("您尚未招募佣兵!!!"))
    		return false
    	end
    	-- 起点是主角，终点是佣兵
    	local clickHeroModel = HeroModel.items[self.clickItem.data.HeroModelId] or {}
    	if (endItem.showIndex == 7) and (clickHeroModel.specialType ~= nil) and (clickHeroModel.specialType == Enums.HeroType.eMainHero) then
    		ui.showFlashView(TR("主角不能换到佣兵阵位!!!"))
    		return false
    	end
    	-- 起点是佣兵，终点是主角
    	local endHeroModel = HeroModel.items[endItem.data.HeroModelId] or {}
    	if (self.clickItem.showIndex == 7) and (endHeroModel.specialType ~= nil) and (endHeroModel.specialType == Enums.HeroType.eMainHero) then
    		ui.showFlashView(TR("主角不能换到佣兵阵位!!!"))
    		return false
    	end
    	return true
    end
    if (filterExchange() == true) then
        self.clickItem.nodeSprite:setLocalZOrder(0)
        self.clickItem.nodeSprite:runAction(cc.MoveTo:create(0.1, endItem.pos))
        endItem.nodeSprite:runAction(cc.MoveTo:create(0.1, self.clickItem.pos))

        -- 交换数据
        for k,v in pairs(self.clickItem) do
            if (k ~= "showIndex") and (k ~= "pos") then
                local oldValue = clone(v)
                self.clickItem[k] = endItem[k]
                endItem[k] = oldValue
            end
        end

        -- 执行回调
        local retFormationList = {}
        for _,v in ipairs(self.mItemData) do
        	table.insert(retFormationList, v.data)
        end
        if self.mExchangeCallBack then
            self.mExchangeCallBack(retFormationList)
        end
    else
        -- 落在其他范围
        self.clickItem.nodeSprite:runAction(cc.MoveTo:create(0.1, self.clickItem.pos))
    end

    self.clickItem = nil
    self.lastClickPos = nil
    self.lastNodePos = nil
end

----------------------------------------------------------------------------------------------------

return GuildPvpComCampLayer