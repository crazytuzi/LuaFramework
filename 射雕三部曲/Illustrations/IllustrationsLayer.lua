--[[
	文件名：IllustrationsLayer.lua
	描述：图鉴
	创建人：yanxingrui
	创建时间： 2016.6.4
	修改人：lengjiazhi
    修改时间：2017.3.20
--]]

local IllustrationsLayer = class("IllustrationsLayer", function(params)
	return display.newLayer()
end)

-- 图鉴物品配置数据，游戏运行期间只需要解析一次
local HandBookConfig = {}

--[[
-- 参数 params中的各项为
	{
		subPageType: 初始显示页面，取值为: ModuleSub.eHero、ModuleSub.eEquip、ModuleSub.eZhenjue、ModuleSub.eFashion、ModuleSub.ePet
		heroRace: 人物子页面中默认显示的阵营， 取值为 Enums.lua文件中的 Enums.HeroRace
	}
]]
function IllustrationsLayer:ctor(params)
	params = params or {}
	self.mSubPageType = params.subPageType or ModuleSub.eHero
	self.mHeroRace = params.heroRace or Enums.HeroRace.eRace3
	-- 初始化图鉴配置数据
	self:initBookConfig()
	-- 图鉴服务器数据
	self.mBookServerData = {}
	-- 初始化页面
	self:initUI()
	-- 获取玩家图鉴
	self:requestGetHandbook()
end

-- 初始化图鉴配置数据
function IllustrationsLayer:initBookConfig()
	if next(HandBookConfig) then -- 如果该表不为空，表示已经解析过了
		return 
	end

	-- 解析人物配置数据
	HandBookConfig[ModuleSub.eHero] = {}
	local heroConfig = HandBookConfig[ModuleSub.eHero]
	for key, item in pairs(HeroModel.items) do
		if item.specialType == Enums.HeroType.eNormalHero then
			local tmpQuality = item.quality
			heroConfig[item.raceID] = heroConfig[item.raceID] or {}
			heroConfig[item.raceID][tmpQuality] = heroConfig[item.raceID][tmpQuality] or {}
			table.insert(heroConfig[item.raceID][tmpQuality], item)
		end
	end
	-- 对每种颜色的人物按照资质排序
	for _, raceItemList in pairs(heroConfig) do
		for _, colorList in pairs(raceItemList) do
			table.sort(colorList, function(item1, item2)
				if item1.quality ~= item2.quality then
					return item1.quality > item2.quality
				end
				return item1.ID < item2.ID
			end)
		end
	end

	-- 解析神兵配置数据, 只有与人物有羁绊搭配的神兵才显示在图鉴中
	HandBookConfig[ModuleSub.eEquip] = {}
	local equipConfig = HandBookConfig[ModuleSub.eEquip]
	for key, item in pairs(TreasureModel.items) do
		-- 隐藏红色神兵显示
		if item.quality < 18 then
			if next(item.prHeroModelIds) then
				local colorLv = Utility.getQualityColorLv(item.quality)
				equipConfig[colorLv] = equipConfig[colorLv] or {}
				table.insert(equipConfig[colorLv], item)
			end
		end
	end
	-- 对每种颜色的神兵按照资质排序(顺序排序)
	for _, colorList in pairs(equipConfig) do
		table.sort(colorList, function(item1, item2)
			if item1.quality ~= item2.quality then
				return item1.quality < item2.quality
			end

			return item1.ID > item2.ID
		end)
	end

	-- 解析内功心法的配置数据
	HandBookConfig[ModuleSub.eZhenjue] = {}
	local zhenjueConfig = HandBookConfig[ModuleSub.eZhenjue]
	for _, item in pairs(ZhenjueModel.items) do
		-- 不上的内功
		if item.ID ~= 18016302 and item.ID ~= 18016301 and item.ID ~= 18016202 and item.ID ~= 18016201 and item.ID ~= 18016102 and item.ID ~= 18016101 then
			zhenjueConfig[item.colorLV] = zhenjueConfig[item.colorLV] or {}
			table.insert(zhenjueConfig[item.colorLV], item)
		end
	end

	-- 解析时装配置数据
	--HandBookConfig[ModuleSub.eFashion] = {}
	--local fashionConfig = HandBookConfig[ModuleSub.eFashion]
	--for _, item in pairs(FashionModel.items) do
	--	fashionConfig[item.colorLV] = fashionConfig[item.colorLV] or {}
	--	table.insert(fashionConfig[item.colorLV], item)
	--end

	-- 解析外功秘籍的配置数据
	HandBookConfig[ModuleSub.ePet] = {}
	local petConfig = HandBookConfig[ModuleSub.ePet]
	for _, item in pairs(PetModel.items) do
		local valueLv = Utility.getQualityColorLv(item.quality)
		local changeQtoC = valueLv
		petConfig[changeQtoC] = petConfig[changeQtoC] or {}
		table.insert(petConfig[changeQtoC], item)
	end
end

-- 获取恢复该页面显示的标签页
function IllustrationsLayer:getRestoreData()
	local retData = {
		subPageType = self.mSubPageType or ModuleSub.eHero,
		heroRace = self.mHeroRace or Enums.HeroRace.eRace1
	}
	return retData
end

-- 初始化页面
function IllustrationsLayer:initUI()
	self.mParentLayer = ui.newStdLayer()
	self:addChild(self.mParentLayer)

	self.mSubLayer = ui.newStdLayer()
	self:addChild(self.mSubLayer)

    -- 背景图片
    local bgSprite = ui.newSprite("c_34.jpg")
    bgSprite:setPosition(320, 568)
    self.mParentLayer:addChild(bgSprite)

    --下方背景
    local bottomBgSprtie = ui.newScale9Sprite("c_19.png", cc.size(640, 990))
    bottomBgSprtie:setAnchorPoint(0.5, 0)
    bottomBgSprtie:setPosition(320, 10)
    self.mParentLayer:addChild(bottomBgSprtie)

    --灰色背景
    self.mGreyBgSprite = ui.newScale9Sprite("c_17.png", cc.size(100, 100))
    self.mGreyBgSprite:setAnchorPoint(0.5, 0)
    self.mGreyBgSprite:setPosition(320, 110)
    self.mParentLayer:addChild(self.mGreyBgSprite)

    -- 创建ListView列表
    self.mListView = ccui.ListView:create()
    self.mListView:setDirection(ccui.ScrollViewDir.vertical)
    self.mListView:setBounceEnabled(true)
    self.mListView:setChildrenActionType(ui.LISTVIEW_ACTION_NONE)    
    self.mListView:setItemsMargin(8)
    self.mListView:setAnchorPoint(cc.p(0.5, 0))
    self.mListView:setPosition(320, 120)
    self.mParentLayer:addChild(self.mListView)

    -- 创建页面切换控件
    self:createTabView()

    -- 创建顶部资源栏和底部导航栏
    local topResource = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        topInfos = {
            ResourcetypeSub.eVIT,  
            ResourcetypeSub.eDiamond, 
            ResourcetypeSub.eGold
        }
    })
    self:addChild(topResource)

    -- 退出按钮
    self.mCloseBtn = ui.newButton({
        normalImage = "c_29.png",
        position = Enums.StardardRootPos.eCloseBtn,
        clickAction = function(pSender)
            LayerManager.removeLayer(self)
        end
    })
    self.mParentLayer:addChild(self.mCloseBtn, 100)
end

-- 创建分页
function IllustrationsLayer:createTabView()
	-- 创建分页
    local tabItems = {
        {
            text = TR("侠客"),
            tag = ModuleSub.eHero,
        },
        {
            text = TR("神兵"),
            tag = ModuleSub.eEquip,
        },
    }

	-- 判断内功心法模块是否开启
	if ModuleInfoObj:moduleIsOpen(ModuleSub.eZhenjue, false) then
		table.insert(tabItems, {
            text = TR("内功心法"),
            tag = ModuleSub.eZhenjue,
        })
	end

	--判断外功秘籍模块是否开启
	if ModuleInfoObj:moduleIsOpen(ModuleSub.ePet, false) then
		table.insert(tabItems, {
            text = TR("外功秘籍"),
            tag = ModuleSub.ePet,
        })
	end

    local tableLayer = ui.newTabLayer({
        btnInfos = tabItems,
	    space = 10,
	    -- btnSize = cc.size(120, 56),
	    defaultSelectTag = self.mSubPageType or ModuleSub.eHero,
	    onSelectChange = function (selectBtnTag)
	    	if selectBtnTag == self.mSubPageType then
                return 
            end
            self.mSubPageType = selectBtnTag

            self:changePage()
        end,
    })
    tableLayer:setPosition(Enums.StardardRootPos.eTabView)
    self.mParentLayer:addChild(tableLayer)
end

-- 切换页面
function IllustrationsLayer:changePage()
	self.mListView:setContentSize(cc.size(600, (self.mSubPageType == ModuleSub.eHero) and 730 or 830))
	self.mSubLayer:removeAllChildren()
	self.mListView:removeAllItems()
	self.mGreyBgSprite:setContentSize(cc.size(620, (self.mSubPageType == ModuleSub.eHero) and 750 or 850))

	if self.mSubPageType == ModuleSub.eHero then
		self:showHeroPage()
	elseif self.mSubPageType == ModuleSub.eEquip then
		-- self.mListView:setContentSize(cc.size(600, (self.mSubPageType == ModuleSub.eHero) and 740 or 860))
		self:showTreasurePage()
	elseif self.mSubPageType == ModuleSub.eZhenjue then
		self:showZhenjuePage()
	--elseif self.mSubPageType == ModuleSub.eFashion then	--时装
	--	self:showFashionPage()
	elseif self.mSubPageType == ModuleSub.ePet then		--外功秘籍
		self:showPetPage()
	end
end

-- 创建物品星级标题
--[[
-- 参数
	colorLv:颜色等级
	isHero: 是否是人物，默认为false
]]
function IllustrationsLayer:createStarNode(colorLv, isHero)
	if (isHero == nil) or (isHero == false) then
		return ui.newStarLevel(colorLv)
	end

	-- 人物返回Label
	local nameLabel = ui.newLabel({
        text = Utility.getHeroColorName(colorLv),
        size = 24,
        outlineColor = cc.c3b(0x47, 0x50, 0x54),
        outlineSize = 2
    })
    nameLabel:setAnchorPoint(cc.p(0.5, 0.5))
    return nameLabel
end

-- 显示人物页面
function IllustrationsLayer:showHeroPage()
	-- 进度标签
	local progressLabel = ui.newLabel({
		text = TR("%s进度:", Utility.getRaceNameById(self.mHeroRace)),
		color = cc.c3b(0x46, 0x22, 0x0d),
	})
	progressLabel:setPosition(70, 880)
	self.mSubLayer:addChild(progressLabel)

	-- 进度条
	self.progressBar = require("common.ProgressBar"):create({
    	bgImage = "gd_14.png",
    	barImage = "gd_13.png",
    	contentSize = cc.size(476, 25),
		needLabel = true,
    	percentView = true,
    	color = Enums.Color.eWhite,
    })
    self.progressBar:setAnchorPoint(cc.p(0, 1))
    self.progressBar:setPosition(140, 891)
    self.mSubLayer:addChild(self.progressBar)

    -- 阵营切换配置
    local raceTabItems = {
    	{	-- 阵营1
            --titleImage = "gd_3.png",  
            titlePosRateY = 0.6,
            tag = Enums.HeroRace.eRace3,
        },
        {	-- 阵营2
            --titleImage = "gd_4.png",
            titlePosRateY = 0.6,
            tag = Enums.HeroRace.eRace2,
        },
        {	-- 阵营3
            --titleImage = "gd_4.png",
            titlePosRateY = 0.6,
            tag = Enums.HeroRace.eRace1,
        },
	}

	-- 对应的名字
	for _, item in pairs(raceTabItems) do
		item.text = Utility.getRaceNameById(item.tag)
	end
	local tableLayer = ui.newTabLayer({
        btnInfos = raceTabItems,
	    space = 60,
	    btnSize = cc.size(120, 65),
        normalImage = "gd_26.png",
        lightedImage = "gd_25.png",
        needLine = false,
	    defaultSelectTag = self.mHeroRace or Enums.HeroRace.eRace1,
	    viewSize = cc.size(580, 75),
	    onSelectChange = function (selectBtnTag)
	    	if selectBtnTag == self.mHeroRace then
                return 
            end
            self.mHeroRace = selectBtnTag

            local tempStr = TR("%s进度:", Utility.getRaceNameById(self.mHeroRace))
            progressLabel:setString(tempStr)

            -- 刷新选中阵营的图鉴列表
			self:showHeroSubLayer()	
        end,
    })
    tableLayer:setPosition(300, 925)
    self.mSubLayer:addChild(tableLayer)

    --
    self:showHeroSubLayer()
end

-- 显示人物子页面
function IllustrationsLayer:showHeroSubLayer()
	self.mListView:removeAllItems()	

	-- 当前阵营人物图鉴的配置数据
	local heroConfig = HandBookConfig[ModuleSub.eHero][self.mHeroRace]
    -- 对星数等级降序排序
	local qualityLvList = table.keys(heroConfig)
	table.sort(qualityLvList, function(key1, key2)
		return key1 > key2
	end)

	-- 每一个阵营中已拥有的人物的数量
	local num = 0
	-- 每一个阵营中的人物的总人数
	local count = 0
	for _, qualityLv in ipairs(qualityLvList) do
		-- 该颜色等级的人物列表
		local itemList = heroConfig[qualityLv]
		-- 每一个颜色等级中已拥有的人物的数量
		local colorLvnum = 0
		local tempCount = #itemList
		count = count + tempCount

		local colCount = 4 -- 卡牌每行个数
	    local spaceX, spaceY = 140, 130  -- 卡牌排列 x、y方向的行间距
		-- 该条目的大小
		local cellSize = cc.size(600, 200 + math.floor((tempCount - 1) / colCount) * spaceY)
		--
		local layout = ccui.Layout:create()
		layout:setContentSize(cellSize)
		self.mListView:pushBackCustomItem(layout)

		-- 条目的背景图片
	    local bgSprite = ui.newScale9Sprite("c_37.png", cc.size(cellSize.width - 10, cellSize.height))
	    bgSprite:setPosition(cellSize.width / 2, cellSize.height / 2)
	    layout:addChild(bgSprite)

	    -- 创建星星
	    local starPosY = cellSize.height - 20
	    local starNode = self:createStarNode(qualityLv, true)
	    starNode:setPosition(cellSize.width / 2, starPosY)
	    layout:addChild(starNode)
	   
	    -- 创建每一组的拥有的个数和总的个数
	    local numLabel = ui.newLabel({
	    	text = "",
	    	color = Enums.Color.eNormalWhite,
	    	outlineColor = cc.c3b(0x47, 0x50, 0x54),
	    	outlineSize = 2,
	    })
	    numLabel:setPosition(525, starPosY)
	    layout:addChild(numLabel)
	    
	    local startPosX, startPosY = 45, cellSize.height - 60 -- 条目中排列卡牌的开始位置
		for index, model in ipairs(itemList) do
			local tempPosX = startPosX + (index - 1) % colCount * spaceX
			local tempPosY = startPosY - math.floor((index - 1) / colCount) * spaceY

	    	local card = CardNode.createCardNode({
		    	resourceTypeSub = ResourcetypeSub.eHero,
		    	modelId = model.ID,
		    	cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eName}
		    })
		    card:setAnchorPoint(cc.p(0, 1))
		    card:setPosition(tempPosX, tempPosY)
		    layout:addChild(card)

		    -- 如果已拥有这个人物，则这个星数等级总人数＋1，并且已拥有的阵营总人数＋1
			if self.mBookServerData[model.ID] then
				num = num + 1
				colorLvnum = colorLvnum + 1
			else
				card:setGray(true)
			end
		end
		
	    numLabel:setString(TR("数量:%d/%d", colorLvnum, tempCount))
	end

	self.progressBar:setCurrValue(math.ceil(num / count * 100))
end

-- 显示神兵页面
function IllustrationsLayer:showTreasurePage()
    -- 神兵图鉴的配置数据
	local treasureConfig = HandBookConfig[ModuleSub.eEquip]
    -- 对星数等级降序排序
	local colorLvList = table.keys(treasureConfig)
	table.sort(colorLvList, function(key1, key2)
		return key1 > key2
	end)

	-- 主角人物信息
	local mainHero = HeroObj:getMainHero()

	-- 显示羁绊人物卡牌的间距
	local heroSpaceX, heroSpaceY = 110, 130
	-- 显示羁绊人物每行的个数
	local heroColCount = 4
	for _, colorLv in ipairs(colorLvList) do
		local itemList = treasureConfig[colorLv]
		-- 该cell的父对象和cell的背景大小需要把上面的内容创建完后再设置
		local layout = ccui.Layout:create()
		
		local cellWidth, cellHeight = 600, 5

		for index, item in ipairs(itemList) do
			local prModelList = {}
			for _, modelId in pairs(item.prHeroModelIds) do
				local tempModel = HeroModel.items[modelId]
                if (tempModel.specialType == Enums.HeroType.eNormalHero) then
                    table.insert(prModelList, tempModel)
                elseif (tempModel.specialType == Enums.HeroType.eMainHero) and (mainHero.ModelId == modelId) then
                    table.insert(prModelList, 1, tempModel)
                end
			end

			-- 显示该神兵信息的高度
			local itemHeight = 210 + math.floor((#prModelList - 1) / heroColCount) * heroSpaceY
			
			local itemSize = cc.size(600, itemHeight)

			-- 创建该条目的背景
	    	local itemBgSprite = ui.newScale9Sprite("gd_24.png", itemSize)
	    	itemBgSprite:setAnchorPoint(cc.p(0.5, 0))
	    	itemBgSprite:setPosition(300, cellHeight)
	    	layout:addChild(itemBgSprite)

	    	local tempNode = ui.newLabel({
	    		text = TR("缘分侠客"),
	        	color = Enums.Color.eBlack,
	    	})
	    	tempNode:setAnchorPoint(cc.p(0, 1))
	    	tempNode:setPosition(355, itemHeight - 12)
	    	itemBgSprite:addChild(tempNode)

	    	-- 创建神兵头像
	    	local treasureCard = CardNode.createCardNode({
		    	resourceTypeSub = Resourcetype.eTreasure,
		    	modelId = item.ID,
		    	cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eName}
		    })
	    	treasureCard:setPosition(80, cellHeight + itemHeight / 2)
	    	layout:addChild(treasureCard)
	    	-- 没有拥有过就显示灰色
			if not self.mBookServerData[item.ID] then
				treasureCard:setGray(true)
			end

	    	-- 创建缘分人物头像
		    for num, heroModel in ipairs(prModelList) do
		    	local tempPosX = 160 + (num - 1) % heroColCount * heroSpaceX
		    	local tempPosY = cellHeight + itemHeight - math.floor((num - 1) / heroColCount) * heroSpaceY - 70

		    	local tempCard = CardNode.createCardNode({
			    	resourceTypeSub = ResourcetypeSub.eHero,
			    	modelId = heroModel.ID,
			    	cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eName}
			    })
			    tempCard:setAnchorPoint(cc.p(0, 1))
			    tempCard:setPosition(tempPosX, tempPosY)
			    layout:addChild(tempCard)
			    -- 没有拥有过就显示灰色
				if not self.mBookServerData[heroModel.ID] then
					tempCard:setGray(true)
				end
		    end

	    	cellHeight = cellHeight + itemHeight + 10
		end

		-- 该条目显示神兵的颜色等级描述
		local titleSprite = ui.newScale9Sprite("c_25.png", cc.size(578, 60))
		layout:addChild(titleSprite)

	    local title = ui.newLabel({
	    	text = TR("%s神兵", Utility.getColorName(colorLv)),
	    	color = Utility.getColorValue(colorLv, 1),
            outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
	    })
	    layout:addChild(title)

	    layout:setContentSize(630, cellHeight + 50)
	    layout:setPosition(5, cellHeight + 50)

	    title:setPosition(315, cellHeight + 20)
	    titleSprite:setPosition(315, cellHeight + 20)


		-- 重新设置cell和cell背景图片的大小
		cellHeight = cellHeight + 50
		layout:setContentSize(cc.size(cellWidth, cellHeight))
		self.mListView:pushBackCustomItem(layout)
	end
end

-- 显示阵决页面
function IllustrationsLayer:showZhenjuePage()
    -- 阵决图鉴的配置数据
	local zhenjueConfig = HandBookConfig[ModuleSub.eZhenjue]
	-- 对星数等级降序排序
	local colorLvList = table.keys(zhenjueConfig)
		table.sort(colorLvList, function(key1, key2)
			return key1 > key2
	end)

	for _, colorLv in ipairs(colorLvList) do
		local tempCount = #zhenjueConfig[colorLv]

		local colCount = 4 -- 卡牌每行个数
	    local spaceX, spaceY = 140, 130  -- 卡牌排列 x、y方向的行间距
		-- 该条目的大小
		local cellSize = cc.size(600, 200 + math.floor((tempCount - 1) / colCount) * spaceY)
		--
		local layout = ccui.Layout:create()
		layout:setContentSize(cellSize)
		self.mListView:pushBackCustomItem(layout)

		-- 条目的背景图片
	    local bgSprite = ui.newScale9Sprite("c_37.png", cc.size(cellSize.width - 10, cellSize.height))
	    bgSprite:setPosition(cellSize.width / 2, cellSize.height / 2)
	    layout:addChild(bgSprite)

	    -- 创建星星
	    local starPosY = cellSize.height - 20
	    local starNode = self:createStarNode(colorLv)
	    starNode:setPosition(cellSize.width / 2, starPosY)
	    layout:addChild(starNode)

	    -- 循环显示每一个colorlv所有的阵决
	    local startPosX, startPosY = 45, cellSize.height - 60 -- 条目中排列卡牌的开始位置
	    for index, model in ipairs(zhenjueConfig[colorLv]) do
	    	local tempPosX = startPosX + (index - 1) % colCount * spaceX
			local tempPosY = startPosY - math.floor((index - 1) / colCount) * spaceY

			-- 
	    	local tempCard = CardNode.createCardNode({
		    	resourceTypeSub = ResourcetypeSub.eNewZhenJue,
		    	modelId = model.ID,
		    	cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eName}
		    })
		    tempCard:setAnchorPoint(cc.p(0, 1))
		    tempCard:setPosition(tempPosX, tempPosY)
		    layout:addChild(tempCard)

		    -- 没有拥有过就显示灰色
			if not self.mBookServerData[model.ID] then
				tempCard:setGray(true)
			end
	    end
	end
end

-- 显示时装页面
--function IllustrationsLayer:showFashionPage()
	-- Todo
--end

--显示外功秘籍页面
function IllustrationsLayer:showPetPage()
    -- 外功秘籍图鉴的配置数据
	local petConfig = HandBookConfig[ModuleSub.ePet]

	-- 对星数等级降序排序
	local colorLvList = table.keys(petConfig)

	table.sort(colorLvList, function(key1, key2)
		return key1 > key2
	end)

	for _, colorLv in ipairs(colorLvList) do
		local tempCount = #petConfig[colorLv]

		local colCount = 4 -- 卡牌每行个数
	    local spaceX, spaceY = 140, 130  -- 卡牌排列 x、y方向的行间距
		-- 该条目的大小
		local cellSize = cc.size(600, 200 + math.floor((tempCount - 1) / colCount) * spaceY)
		--
		local layout = ccui.Layout:create()
		layout:setContentSize(cellSize)
		self.mListView:pushBackCustomItem(layout)

		-- 条目的背景图片
	    local bgSprite = ui.newScale9Sprite("c_37.png", cc.size(cellSize.width - 10, cellSize.height))
	    bgSprite:setPosition(cellSize.width / 2, cellSize.height / 2)
	    layout:addChild(bgSprite)

	    -- 创建星星
	    local starPosY = cellSize.height - 20
	    local starNode = self:createStarNode(colorLv)
	    starNode:setPosition(cellSize.width / 2, starPosY)
	    layout:addChild(starNode)

	    -- 循环显示每一个colorlv所有的内功心法
	    local startPosX, startPosY = 45, cellSize.height - 60 -- 条目中排列卡牌的开始位置
	    -- 未开放外功id
	    local closePetList = {23010615, 23010614, 23010613}
	    -- 是否是未开放外功
	    function isClosePet(modelId)
	    	for _, v in pairs(closePetList) do
	    		if v == modelId then
	    			return true
	    		end
	    	end
	    	return false
	    end
	    -- 对相同品质排序
	    table.sort(petConfig[colorLv], function (item1, item2)
	    	-- 特殊处理没有开放的外功排前面
	    	local isClosePet1 = isClosePet(item1.ID)
	    	local isClosePet2 = isClosePet(item2.ID)
	    	if isClosePet1 ~= isClosePet2 then
	    		return isClosePet1
	    	end

	    	if item1.valueLv ~= item2.valueLv then
	    		return item1.valueLv > item2.valueLv
	    	end

	    	return item1.ID > item2.ID
	    end)
	    for index, model in ipairs(petConfig[colorLv]) do
	    	local tempPosX = startPosX + (index - 1) % colCount * spaceX
			local tempPosY = startPosY - math.floor((index - 1) / colCount) * spaceY

			-- 
	    	local tempCard = CardNode.createCardNode({
		    	resourceTypeSub = ResourcetypeSub.ePet,
		    	modelId = model.ID,
		    	cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eName}
		    })
		    tempCard:setAnchorPoint(cc.p(0, 1))
		    tempCard:setPosition(tempPosX, tempPosY)
		    layout:addChild(tempCard)

		    -- 没有拥有过就显示灰色
			if not self.mBookServerData[model.ID] then
				tempCard:setGray(true)
			end
	    end
	end
end

-- ====================== 网络请求 =======================
-- 请求图鉴信息
--[[
-- 服务器的返回值为：
	{
	    [
	        HandBookType:图鉴类型(装备:1 神兵:2 学员:3 阵诀:4 时装:5 宠物:6)
	        HandBookList:模型Id的List
	    ]
	}
]]
function IllustrationsLayer:requestGetHandbook()
	HttpClient:request({
        moduleName = "Handbook",
        methodName = "GetHandbook",
        svrMethodData = {},
        callbackNode = self,
        callback = function(response)
			local mainHero = HeroObj:getMainHero()
            self.mBookServerData = {[mainHero.ModelId] = true}
        	for _, item in pairs(response and response.Value or {}) do
        		for _, modelId in pairs(item.HandBookList or {}) do
        			self.mBookServerData[modelId] = true
        		end
        	end
			-- 切换页面
			self:changePage()
    	end
    })
end

return IllustrationsLayer