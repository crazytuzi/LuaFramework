--[[
    文件名：OverallRankZZLayer
    描述：主宰排行页面
    创建人：yuanhuangjing
    修改人：chenqiang
    创建时间：2016.4.28
--]]
local OverallRankZZLayer = class("OverallRankZZLayer", function ()
	return display.newLayer()
end)

function OverallRankZZLayer:ctor()
	--选中的当前名字
	self.mCurrentShow = 0
	--服务器信息
	self.mRankInfo = {}
	--是否已经点过赞
	self.mIsParise = true
	--创建标准容器
	self.mParentLayer = ui.newStdLayer()
	self:addChild(self.mParentLayer)

	--初始化界面
	self:initUI()

	--获取数据信息
	self:requestGetData()
end

--进入响应
function OverallRankZZLayer:onEnterTransitionFinish()
	--添加触摸层
	self:createTouchEventLayer()
end

--添加触摸事件处理
function OverallRankZZLayer:createTouchEventLayer()
	local touchLayer = display.newLayer()
    self:addChild(touchLayer)

	local prev = {x = 0, y = 0}
	local start = {x = 0, y = 0}

	local function onTouchBegan(touch, event)
		prev.x = touch:getLocation().x  prev.y = touch:getLocation().y
		start.x = touch:getLocation().x  start.y = touch:getLocation().y

		return true
	end

	local function onTouchMoved(touch, event)
		local diffx = touch:getLocation().x - prev.x
		prev.x = touch:getLocation().x 
		prev.y = touch:getLocation().y
		if diffx > 0 then 
			self._ellipseLayer:setRadiansOffset(-1) 
		end
		if diffx < 0 then 
			self._ellipseLayer:setRadiansOffset(1) 
		end
	end

	local function onTouchEnded(touch, event)
		local diffx = touch:getLocation().x - start.x
		if diffx > 100 then 
			self._ellipseLayer:moveToPreviousItem() 
			return 
		end
		if diffx < -100 then self._ellipseLayer:moveToNextItem() 
			return 
		end
		self._ellipseLayer:alignTheLayer(true)
	end

	local function onTouchCancel(touch, event)
		local diffx = touch:getLocation().x - start.x
		if diffx > 100 then 
			self._ellipseLayer:moveToPreviousItem() 
			return 
		end
		if diffx < -100 then self._ellipseLayer:moveToNextItem() 
			return 
		end
		self._ellipseLayer:alignTheLayer(true)
	end

    --添加监听
	local  listenner = cc.EventListenerTouchOneByOne:create()
    listenner:setSwallowTouches(true)
    listenner:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listenner:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
    listenner:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
    listenner:registerScriptHandler(onTouchCancel,cc.Handler.EVENT_TOUCH_CANCELLED)
    local eventDispatcher = touchLayer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, self)
end

--初始化
function OverallRankZZLayer:initUI()
	--背景图片
	local bgSprite = ui.newSprite("c_89.png")
	bgSprite:setPosition(320, 1136 / 2)
	self.mParentLayer:addChild(bgSprite)

	local bgSize = bgSprite:getContentSize()
	self.mBgSprite = bgSprite

	--创建遮罩层，用于显示前三
	local clipBg = cc.ClippingNode:create()
	clipBg:setAlphaThreshold(1.0)

	--添加颜色
	local stencilNode = cc.LayerColor:create(Enums.Color.eBlack)
    stencilNode:setContentSize(cc.size(640, 1136))
    clipBg:setStencil(stencilNode)
    clipBg:setPosition(cc.p(0, 0))
    self.mParentLayer:addChild(clipBg)
	self.mBgClip =  clipBg

	--前三UI
	self:setTop3UI()
end

--前三显示
function OverallRankZZLayer:setTop3UI()
	local bgSize = self.mBgSprite:getContentSize()

	--第一名名字背景
	local decBg = ui.newSprite("c_58.png")
	decBg:setPosition(bgSize.width * 0.5, bgSize.height * 0.5)
	self.mParentLayer:addChild(decBg)
	self.mDecBg = decBg

	--第一名名字
	self.mTop3NameLabel = ui.newLabel({
		text = "--",
		color = Enums.Color.eYellow,
		x = decBg:getContentSize().width * 0.5,
		y = decBg:getContentSize().height * 0.5,
	})
	self.mDecBg:addChild(self.mTop3NameLabel)

	-- 第一名帮派的背景
	local guildBg = ui.newSprite("c_58.png")
	guildBg:setPosition(cc.p(bgSize.width * 0.5, bgSize.height * 0.5 - 40))
	self.mParentLayer:addChild(guildBg)
	self.mGuildBg = guildBg

	--第一名帮派名字
	self.mTop3GuildLabel = ui.newLabel({
		text = "--",
		color = Enums.Color.eWhite,
		x = guildBg:getContentSize().width * 0.5,
		y = guildBg:getContentSize().height * 0.5,
	})
	self.mGuildBg:addChild(self.mTop3GuildLabel)
end

function OverallRankZZLayer:refreshLayer()
	--刷新前三信息
	self:refreshTopInfo(1)
	--创建榜单信息
	self:createRankTableView(2)
	--展示前三	 
	self:showTop3()
end

--展示前三
function OverallRankZZLayer:showTop3()
	self._ellipseLayer = require("common.EllipseLayer3D").new({
		longAxias = 250,
		shortAxias = 250,
		fixAngle = 90,
		totalItemNum = 3,
		itemContentCallback = function(parrent, index)
			self:showHeroDetails(parrent, index)
		end,
		alignCallback = function(index)
			self:refreshTopInfo(index)
		end
	})
	self._ellipseLayer:setPosition(cc.p(320, 700))
	self.mBgClip:addChild(self._ellipseLayer)
end

--刷新前三人的信息
function OverallRankZZLayer:refreshTopInfo(index)
	if index and index == self.mCurrentShow then
		return
	end
	local info = {}
	for k,v in ipairs(self.mRankInfo) do
		if v.Rank == index then
			info = v
		end
	end

    if info.Name == nil then
       self.mDecBg:setVisible(false)
       self.mGuildBg:setVisible(false)
    else
        self.mDecBg:setVisible(true)
        self.mGuildBg:setVisible(true)
        self.mTop3NameLabel:setString(info.Name)
        self.mTop3GuildLabel:setString(TR("帮派【%s】", info.GuildName))
    end

    self.mCurrentShow = index
end

--人物展示
function OverallRankZZLayer:showHeroDetails(parrent, index)
	local info = {}
	for k,v in ipairs(self.mRankInfo) do
		if v.Rank == index then
			info = v
		end
	end
	if info.Name and info.HeadImageId then
		local hero = Figure.newHero({
            heroModelID = info.HeadImageId,
            fashionModelID = info.FashionModelId,
            IllusionModelId = info.IllusionModelId,
            parent = parrent,
            position = cc.p(0, -150),
            scale = 0.225,
            buttonAction = function()
            	--todo
            	--self:requestKuaFu()
        	end
        })

		if index == 1 or index == 2 or index == 3 then
			if hero then
				local rankImage = {"diyi", "dier", "disan"}
				ui.newEffect({
					parent = hero,
					effectName = "effect_ui_longfengtian",
					animation = rankImage[index],
					position = cc.p(hero:getContentSize().width / 2, 150),
                    scale = 1/0.45,
                    loop = true,
                    endRelease = true,
                })
			end
		end
	else
		-- 排行榜数据为空时，不显示玩家信息
		-- local hero = ui.newSprite("gh_35.png")
		-- hero:setScale(0.5)
  --       hero:setPosition(cc.p(0, -150))
  --       hero:setAnchorPoint(cc.p(0.5, 0))
  --       parrent:addChild(hero)
	end
end

--榜单信息
function OverallRankZZLayer:createRankTableView(type)
	if #self.mRankInfo == 0  then
		local kongSprite = ui.createEmptyHint(TR("暂无主宰榜数据，敬请期待"))
		kongSprite:setAnchorPoint(0.5, 0.5)
		kongSprite:setPosition(320, 568)
		self.mParentLayer:addChild(kongSprite)

		return
	end

	--榜背景大小
	local tableViewBgSize = cc.size(630, 390)
	--榜大小
	local tableViewSize = {}
	--榜位置
	local tableViewPosition
	if type == 1 then
		tableViewSize.width = 640
		tableViewSize.height = 340
		tableViewPosition = cc.p(320, 170)
	elseif type == 2 then
		tableViewSize.width = 640
		tableViewSize.height = 370
		tableViewPosition = cc.p(320, 110)
	end

	local tableViewBg = ui.newScale9Sprite("c_79.png", tableViewBgSize)
	tableViewBg:setAnchorPoint(0.5, 0)
	tableViewBg:setPosition(tableViewPosition)
	self.mParentLayer:addChild(tableViewBg)

	local sliderTableView = ui.newSliderTableView({
		width = tableViewSize.width,
		height = tableViewSize.height,
		isVertical = true,
		selItemOnMiddle = false,
		itemCountOfSlider = function(sliderView)
			return #self.mRankInfo
		end,
		itemSizeOfSlider = function(sliderView)
			return 640, 60
		end,
		sliderItemAtIndex = function(sliderView, itemNode, index)
			local info = self.mRankInfo[index+1]

			--排名栏
			local rankCell = ui.newScale9Sprite("ldtl_07.png", cc.size(620, 60))
			rankCell:setPosition(cc.p(320, 30))
			itemNode:addChild(rankCell)

			--排名信息
			local rankLabelNode = cc.Node:create()
			rankLabelNode:setContentSize(rankCell:getContentSize())
			rankLabelNode:setAnchorPoint(cc.p(0, 0))
			rankCell:addChild(rankLabelNode)

			--first,second,third
			local rankNumber = nil
			if index == 0 then
				rankNumber = ui.newSprite("c_75.png")
				rankNumber:setAnchorPoint(0.5, 0.5)
				rankNumber:setPosition(50, rankCell:getContentSize().height * 0.5)
			elseif index == 1 then
				rankNumber = ui.newSprite("c_76.png")
				rankNumber:setAnchorPoint(0.5, 0.5)
				rankNumber:setPosition(50, rankCell:getContentSize().height * 0.5)
			elseif index == 2 then
				rankNumber = ui.newSprite("c_77.png")
				rankNumber:setAnchorPoint(0.5, 0.5)
				rankNumber:setPosition(50, rankCell:getContentSize().height * 0.5)
			else
				rankNumber = ui.newLabel({
					text = info.Rank,
					color = Enums.Color.eNormalWhite,
					anchorPoint = cc.p(0.5, 0.5),
					x = 52,
					y = rankCell:getContentSize().height * 0.5
				})
			end
			rankLabelNode:addChild(rankNumber)

			--名字
			local nameLabel = ui.newLabel({
				text = info.Name,
				color = Enums.Color.eNormalWhite,
				anchorPoint = cc.p(0, 0.5),
				x = 100,
				y = rankCell:getContentSize().height * 0.5,
			})
			rankLabelNode:addChild(nameLabel)

			--战斗力
			local fapLabel = ui.newLabel({
				text = Utility.numberFapWithUnit(info.FAP),
				color = Enums.Color.eNormalGreen,
				anchorPoint = cc.p(0, 0.5),
				x = 275,
				y = rankCell:getContentSize().height * 0.5,
			})
			rankLabelNode:addChild(fapLabel)

			--服务器
			local serverLabel = ui.newLabel({
				text = TR("服务器:  %s%s", Enums.Color.eNormalGreenH, info.Zone),
				color = Enums.Color.eNormalWhite,
				anchorPoint = cc.p(0, 0.5),
				x = 390,
				y = rankCell:getContentSize().height * 0.5,
			})
			rankLabelNode:addChild(serverLabel)
		end,

		selectItemChanged = function(sliderView, selectIndex)
		end,
    })
	local bgSize = self.mBgSprite:getContentSize()
    sliderTableView:setAnchorPoint(cc.p(0.5, 0))
    sliderTableView:setPosition(tableViewPosition)
    self.mBgSprite:addChild(sliderTableView)
end

--==================网络请求相关=========================
function OverallRankZZLayer:requestGetData()
	HttpClient:request({
		moduleName = "PVPinter",
		methodName = "GetPVPInterTopRankForNoPage",
		callback = function(response)
			if not response or response.Status ~= 0 then
				return 
			end

			self.mRankInfo = response.Value and response.Value.PVPinterTopRank or {}
			self:refreshLayer()
		end,
	})
end
return OverallRankZZLayer