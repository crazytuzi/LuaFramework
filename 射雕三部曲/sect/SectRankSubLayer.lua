--[[
    文件名：SectRankSubLayer
    描述：战斗力排行页面
    创建人：yuanhuangjing
    修改人：yanghongsheng
    创建时间：2017.8.31
--]]

--[[
	params:
		sectId 		-- 门派id
]]

local SectRankSubLayer = class("SectRankSubLayer", function(params)
	return display.newLayer()
end)

function SectRankSubLayer:ctor(params)
	self.sectId = params.sectId or SectObj:getPlayerSectInfo().SectId

	self.mCurrentShow = 0 --当前选中前三的名字
	self.mRankInfo = SectObj:getRankInfo(self.sectId)

	-- 创建标准容器
	self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

	--初始化UI
	self:initUI()
end

--进入响应
function SectRankSubLayer:onEnterTransitionFinish()
	--添加触摸层
	self:createTouchEventLayer()
end

--添加触摸事件处理
function SectRankSubLayer:createTouchEventLayer()
	local touchLayer = display.newLayer()
    self:addChild(touchLayer)

	local prev = {x = 0, y = 0}
	local start = {x = 0, y = 0}

	local function onTouchBegan(touch, event)
		prev.x = touch:getLocation().x
		prev.y = touch:getLocation().y

		start.x = touch:getLocation().x
		start.y = touch:getLocation().y

		return true
	end

	local function onTouchMoved(touch, event)
		local diffX = touch:getLocation().x - prev.x
		prev.x = touch:getLocation().x
		prev.y = touch:getLocation().y
		if diffX > 0 then
			self._ellipseLayer:setRadiansOffset(-1)
		end
		if diffX < 0 then
			self._ellipseLayer:setRadiansOffset(1)
		end
	end

	local function onTouchEnded(touch, event)
		local diffX = touch:getLocation().x - start.x
		if diffX > 100 then 
			self._ellipseLayer:moveToPreviousItem() 
			return 
		end
		if diffX < -100 then self._ellipseLayer:moveToNextItem() 
			return 
		end
		self._ellipseLayer:alignTheLayer(true)
	end

	local function onTouchCancel(touch, event)
		local diffX = touch:getLocation().x - start.x
		if diffX > 100 then 
			self._ellipseLayer:moveToPreviousItem() 
			return 
		end
		if diffX < -100 then self._ellipseLayer:moveToNextItem() 
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

--初始化UI
function SectRankSubLayer:initUI()
	--创建场景的背景
	local bgSprite = ui.newSprite("gd_29.jpg")
	bgSprite:setAnchorPoint(0.5, 1)
	bgSprite:setPosition(320, 1136)
	self.mParentLayer:addChild(bgSprite)

	local bgSize = bgSprite:getContentSize()
	self.mBgSprite = bgSprite

	--创建遮罩层,用于展示前三
	local clipBg = cc.ClippingNode:create()
	clipBg:setAlphaThreshold(1.0)
	--添加颜色层
	local stencilNode = cc.LayerColor:create(Enums.Color.eBlack)
	stencilNode:setContentSize(cc.size(640,1136))
	clipBg:setStencil(stencilNode)
	clipBg:setPosition(cc.p(0, 0))
	self.mParentLayer:addChild(clipBg)
	self.mClipBg = clipBg
	--前三UI
	self:setTop3UI()
	--创建自己排名信息
	self:createSelfRankInfo()
	--刷新
	self:refreshLayer()
end

--排名前三UI
function SectRankSubLayer:setTop3UI()
	local bgSize = self.mParentLayer:getContentSize()

	--第一名名字背景
	local decBg = ui.newScale9Sprite("c_25.png", cc.size(252, 50))
	decBg:setPosition(cc.p(bgSize.width * 0.5, bgSize.height * 0.5))
	self.mParentLayer:addChild(decBg)
	self.mDecBg = decBg
	--第一名名字
	self.mTop3NameLabel = ui.newLabel({
		text = "--",
		color = Enums.Color.eWhite,
		outlineColor = cc.c3b(0x82, 0x49, 0x36),
		x = decBg:getContentSize().width * 0.5,
		y = decBg:getContentSize().height * 0.5
	})
	self.mDecBg:addChild(self.mTop3NameLabel)

	-- 第一名帮派的背景
	local guildBg = ui.newSprite("c_83.png")
	guildBg:setPosition(cc.p(bgSize.width * 0.5, bgSize.height * 0.5 - 40))
	self.mParentLayer:addChild(guildBg)
	self.mGuildBg = guildBg
	--第一名帮派名
	self.mTop3GuildLabel = ui.newLabel({
		text = "--",
		color = cc.c3b(0xff, 0xed, 0xc9),
		outlineColor = cc.c3b(0x83, 0x45, 0x00),
		x = guildBg:getContentSize().width * 0.5,
		y = guildBg:getContentSize().height * 0.5,
	})
	self.mGuildBg:addChild(self.mTop3GuildLabel)
end

--点赞序列动画
function SectRankSubLayer:dianZanDongHua(zanNum)
	--设置序列动作
	local actionArray = {}
	table.insert(actionArray, cc.CallFunc:create(function ()
		self.mDianZanSprite = ui.newSprite("gd_10.png")
		self.mDianZanSprite:setPosition(cc.p(550, 540))
		self.mParentLayer:addChild(self.mDianZanSprite)
		self.mDianZanSprite:runAction(cc.MoveTo:create(0.8, cc.p(60, 935)))
	end))
	table.insert(actionArray, cc.DelayTime:create(0.8))
	table.insert(actionArray, cc.CallFunc:create(function ()
		self.mZanNum:setString(zanNum)
		self:refreshTopInfo(self.mCurrentShow)
		if self.mDianZanSprite then
			self.mDianZanSprite:removeFromParent()
		end
	end))

	self:runAction(cc.Sequence:create(actionArray))
end

function SectRankSubLayer:createSelfRankInfo()
	--创建自己排位栏
	self.mSelfRankSprite = ui.newScale9Sprite("gd_10.png", cc.size(620, 58))
	self.mSelfRankSprite:setAnchorPoint(0.5, 0)
	self.mSelfRankSprite:setPosition(320, 113)
	self.mParentLayer:addChild(self.mSelfRankSprite)
	self.selfRankSize = self.mSelfRankSprite:getContentSize()
	--排名信息
	self.mSelfRankNode = cc.Node:create()
	self.mSelfRankNode:setContentSize(self.selfRankSize)
	self.mSelfRankNode:setAnchorPoint(0, 0)
	self.mSelfRankSprite:addChild(self.mSelfRankNode)
	--我的名次
	self.mSelfRankLabel = ui.newLabel({
		text = "--",
		color = Enums.Color.eNormalYellow,
		anchorPoint = cc.p(0, 0.5),
		x = 50,
		y = self.selfRankSize.height * 0.5
	})
	self.mSelfRankNode:addChild(self.mSelfRankLabel)
	--我的名字
	self.mSelfNameLabel = ui.newLabel({
		text = "--",
		color = Enums.Color.eNormalYellow,
		anchorPoint = cc.p(0, 0.5),
		x = 100,
		y = self.selfRankSize.height * 0.5
	})
	self.mSelfRankNode:addChild(self.mSelfNameLabel)
	--我的战斗力
	self.mSelfRankTitel = ui.newLabel({
		text = "--",
		color = Enums.Color.eNormalYellow,
		anchorPoint = cc.p(0, 0.5),
		x = 275,
		y = self.selfRankSize.height * 0.5
	})
	self.mSelfRankNode:addChild(self.mSelfRankTitel)
	--我的服务器
	self.mSelfPresetige = ui.newLabel({
		text = "--",
		color = Enums.Color.eNormalYellow,
		anchorPoint = cc.p(0, 0.5),
		x = 395,
		y = self.selfRankSize.height * 0.5
	})
	self.mSelfRankNode:addChild(self.mSelfPresetige)
end

--刷新页面
function SectRankSubLayer:refreshLayer()
    -- 刷新前三信息
    self:refreshTopInfo(1)

    --展示前三
    self:showTop3()

    --本人是否进榜
    local myRankInfo = nil
    local playerId = PlayerAttrObj:getPlayerAttrByName("PlayerId")
    for _, info in ipairs(self.mRankInfo) do
    	if info.PlayerId == playerId then
    		myRankInfo = nil  -- info 暂时屏蔽自己的排名显示
    		break
    	end
    end
    if myRankInfo == nil then
    	self.mSelfRankSprite:setVisible(false)
    	-- 创建榜单信息
    	self:createRankTableView(2)
    else
    	-- 我的名次
    	self.mSelfRankLabel:setString(myRankInfo.Rank)
    	-- 我的名字
    	self.mSelfNameLabel:setString(myRankInfo.Name)
    	-- 我的职介
    	self.mSelfRankTitel:setString(myRankInfo.SectRank.Names)
    	-- 我的声望
    	self.mSelfPresetige:setString(TR("声望: %d", myRankInfo.TotalSectCoin))
  --   	-- 名次是否有变化
  --   	if myRankInfo.RankAdd == 1 then
  --   		local rankUpSprite = ui.newSprite("c_78.png")
  --   		rankUpSprite:setAnchorPoint(0, 0.5)
  --   		rankUpSprite:setPosition(575, self.selfRankSize.height * 0.5)
  --   		self.mSelfRankNode:addChild(rankUpSprite)
		-- elseif myRankInfo.RankAdd == -1 then
		-- 	local rankDownSprite = ui.newSprite("c_77.png")
  --   		rankDownSprite:setAnchorPoint(0, 0.5)
  --   		rankDownSprite:setPosition(575, self.selfRankSize.height * 0.5)
  --   		self.mSelfRankNode:addChild(rankDownSprite)
		-- end
	 	-- 创建榜单信息
    	self:createRankTableView(1)
    end
end

--展示前三
function SectRankSubLayer:showTop3()
	self._ellipseLayer = require("common.EllipseLayer3D").new({
		longAxias = 250,
		shortAxias = 250,
		fixAngle = 90,
		totalItemNum = 3,
		itemContentCallback = function(parrent, index)
			self:showHeroDetails(parrent, index)
		end,
		alignCallback = function (index)
			self:refreshTopInfo(index)
		end
	})
	self._ellipseLayer:setPosition(cc.p(320, 700))
	self.mClipBg:addChild(self._ellipseLayer)
end

--刷新前三人的信息
function SectRankSubLayer:refreshTopInfo(index)
	if index and index == self.mCurrentShow then
		return
	end
	local info = {}
	for k,v in ipairs(self.mRankInfo) do
		if v.Rank == index then
			info = v
			break
		end
	end

    if info.Name == nil then
       self.mDecBg:setVisible(false)
       self.mGuildBg:setVisible(false)
    else
        self.mDecBg:setVisible(true)
        self.mGuildBg:setVisible(true)
        self.mTop3NameLabel:setString(info.Name)
        if info.GuildName ~= "" then
        	self.mTop3GuildLabel:setString(TR("帮派【%s】", info.GuildName))
    	else
    		self.mTop3GuildLabel:setString(TR("无帮派"))
        end
        
    end

    self.mCurrentShow = index
end

--展示人物信息
function SectRankSubLayer:showHeroDetails(parrent, index)
	local info = {}
	for k,v in ipairs(self.mRankInfo) do
		if v.Rank == index then
			info = v
		end
	end
	if info.Name ~= nil and info.HeadImageId ~= nil then
		local hero = Figure.newHero({
            heroModelID = info.HeadImageId,
            fashionModelID = info.FashionModelId,
            IllusionModelId = info.IllusionModelId,
            parent = parrent,
            position = cc.p(0, -80),
            scale = 0.175,
            buttonAction = function()
                Utility.showPlayerTeam(info.PlayerId)
        	end
        })

		if index ==1 or index ==2 or index ==3 then
			if hero then
				local rankImage = {"diyi", "dier", "disan"}
				ui.newEffect({
					parent = hero,
					effectName = "effect_ui_longfengtian",
					animation = rankImage[index],
					position = cc.p(hero:getContentSize().width / 2, -20),
                    scale = 3,
                    loop = true,
                    endRelease = true,
                })
			end
		end
	else
		-- 排行榜数据为空时，不显示玩家信息
		-- local hero = ui.newSprite("gh_35.png")
  --       hero:setPosition(cc.p(0, -150))
  --       hero:setScale(0.5)
  --       hero:setAnchorPoint(cc.p(0.5, 0))
  --       parrent:addChild(hero)
	end
end

--创建榜单信息
function SectRankSubLayer:createRankTableView(type)
    --榜背景大小
    local tableViewBgSize = nil
    --榜大小
    local tableViewSize = {}
    --榜位置
    local tableViewPosition = nil
    if type == 1 then
        tableViewSize.width = 640
        tableViewSize.height = 315
        tableViewPosition = cc.p(320, 170)
        tableViewBgSize = cc.size(640, 330)
    elseif type == 2 then
        tableViewSize.width = 640
        tableViewSize.height = 370
        tableViewPosition = cc.p(320, 70)
        tableViewBgSize = cc.size(640, 430)
    end

    local tableViewBg = ui.newScale9Sprite("c_19.png", tableViewBgSize)
    tableViewBg:setAnchorPoint(0.5, 0)
    tableViewBg:setPosition(tableViewPosition)
    self.mParentLayer:addChild(tableViewBg)

	if #self.mRankInfo == 0 then
		local kongSprite = ui.createEmptyHint(TR("暂无声望榜数据,敬请期待"))
		kongSprite:setAnchorPoint(0.5, 0.5)
		kongSprite:setPosition(350, 310)
		self.mParentLayer:addChild(kongSprite)

		return
	end

	local sliderTableView = ui.newSliderTableView({
		width = tableViewSize.width,
		height = tableViewSize.height - 20,
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
			local rankCell = ui.newScale9Sprite("gd_10.png", cc.size(620, 58))
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
				rankNumber = ui.newSprite("c_44.png")
				rankNumber:setScale(0.7)
				rankNumber:setAnchorPoint(0.5, 0.5)
				rankNumber:setPosition(50, rankCell:getContentSize().height * 0.5)
			elseif index == 1 then
				rankNumber = ui.newSprite("c_45.png")
				rankNumber:setScale(0.7)
				rankNumber:setAnchorPoint(0.5, 0.5)
				rankNumber:setPosition(50, rankCell:getContentSize().height * 0.5)
			elseif index == 2 then
				rankNumber = ui.newSprite("c_46.png")
				rankNumber:setScale(0.7)
				rankNumber:setAnchorPoint(0.5, 0.5)
				rankNumber:setPosition(50, rankCell:getContentSize().height * 0.5)
			else
                rankNumber = ui.createSpriteAndLabel({
                    imgName = "c_47.png",
                    labelStr = info.Rank,
                    fontColor = Enums.Color.eNormalWhite,
                    outlineColor = Enums.Color.eOutlineColor,
                    fontSize = 36
                })
                rankNumber:setScale(0.7)
                rankNumber:setPosition(cc.p(52, rankCell:getContentSize().height * 0.5))
			end
			rankLabelNode:addChild(rankNumber)

			--名字
			local nameLabel = ui.newLabel({
				text = info.Name,
				color = cc.c3b(0x59, 0x28, 0x17),
				anchorPoint = cc.p(0, 0.5),
				x = 100,
				y = rankCell:getContentSize().height * 0.5,
			})
			rankLabelNode:addChild(nameLabel)

			--职介
			local rankTitleLabel = ui.newLabel({
				text = info.SectRank.Name,
				color = Enums.Color.eNormalGreen,
				anchorPoint = cc.p(0, 0.5),
				x = 275,
				y = rankCell:getContentSize().height * 0.5,
			})
			rankLabelNode:addChild(rankTitleLabel)

			--声望
			local presetigeLabel = ui.newLabel({
				text = TR("声望:  %d", info.TotalSectCoin),
				color = Enums.Color.eNormalGreen,
				anchorPoint = cc.p(0, 0.5),
				x = 390,
				y = rankCell:getContentSize().height * 0.5,
			})
			rankLabelNode:addChild(presetigeLabel)

			-- -- 名次是否有变化
	  --   	if info.RankAdd == 1 then
	  --   		local rankUpSprite = ui.newSprite("c_78.png")
	  --   		rankUpSprite:setAnchorPoint(0, 0.5)
	  --   		rankUpSprite:setPosition(575, self.selfRankSize.height * 0.5)
	  --   		rankLabelNode:addChild(rankUpSprite)
			-- elseif info.RankAdd == -1 then
			-- 	local rankDownSprite = ui.newSprite("c_77.png")
	  --   		rankDownSprite:setAnchorPoint(0, 0.5)
	  --   		rankDownSprite:setPosition(575, self.selfRankSize.height * 0.5)
	  --   		rankLabelNode:addChild(rankDownSprite)
			-- end
		end,

		selectItemChanged = function(sliderView, selectIndex)
		end,
	})
	sliderTableView:setAnchorPoint(cc.p(0.5, 0))
	sliderTableView:setPosition(tableViewPosition.x, tableViewPosition.y + 40)
	self.mParentLayer:addChild(sliderTableView)
end

--==================服务器相关====================
-- 获取该玩家阵容
function SectRankSubLayer:requestShowPlayerTeam(index)
	HttpClient:request({
        moduleName = "LeaderBoard",
        methodName = "Formation",
        svrMethodData = {1, index},
        callback = function (data)
        	if data.Status ~= 0 then return end

    	    local tempObj = require("data.CacheFormation"):create()
            tempObj:setFormation(data.Value.Formation.SlotInfos, data.Value.Formation.MateInfos)
            tempObj:setOtherPlayerInfo(data.Value.Formation.PlayerInfo)
            LayerManager.addLayer({
                name = "team.OtherTeamLayer",
                cleanUp = false,
                data = {
                    formationObj = tempObj,
                },
            })
        end,
    })
end

return SectRankSubLayer