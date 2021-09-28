-- Filename：	BagMap.lua
-- Author：		LiuLiPeng
-- Date：		2014-4-18
-- Purpose：		城池大地图

module ("BigMap", package.seeall)


require "script/ui/guild/city/CityReward"
require "script/ui/copy/CityMenuItem"
require "script/ui/guild/city/CityData"
require "script/ui/guild/GuildDataCache"
require "script/ui/item/ItemUtil"

local IMG_PATH = "images/main/"				-- 主城场景图片主路径

local containerLayer				--scrollView的容器

local fortScrollView				--滚动scrollview

local fortMenuBar                   --所有据点都做成menuItem

local bgNode						--背景节点

local absY = 0
local absX = 0
local contribute = 0
local _stepTipSprite  	= nil
local _itemTipSprite	= nil
local _stepTipLabel	  	= nil
local statusMenuBar 	= nil
local city1 = nil
local city2 = nil
local city3 = nil
local city1Contentwidth = 0
local city1Contentheight = 0
local city2Contentwidth = 0
local city2Contentheight = 0
local city3Contentwidth = 0
local city3Contentheight = 0
local isShow = true
local isBattle = true
local signTable = nil


function init()
	containerLayer		= nil 	--scrollView的容器

	fortMenuBar			= nil	--城池Mennu

	fortScrollView		= nil

	bgNode				= nil

	absY 				= 0
	absX 				= 0
	_stepTipSprite 		= nil
	_stepTipLabel	  	= nil
	statusMenuBar 		= nil
	isShow = true
	city1 = nil
	city2 = nil
	city3 = nil

	city1Contentwidth = 0
	city1Contentheight = 0
	city2Contentwidth = 0
	city2Contentheight = 0
	city3Contentwidth = 0
	city3Contentheight = 0
end

--[[
 @desc	 处理touches事件
 @para 	 string event
 @return
--]]
local function onTouchesHandler( eventType, x, y )
	if (eventType == "began") then
        return true
    elseif (eventType == "moved") then
    else
	end
end

--[[
 @desc	 回调onEnter和onExit时间
 @para 	 string event
 @return void
 --]]
local function onNodeEvent( event )
	if (event == "enter") then
		-- print("enter")
		GuildDataCache.setIsInGuildFunc(true)
		containerLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		-- print("exit")
		GuildDataCache.setIsInGuildFunc(false)
		containerLayer:unregisterScriptTouchHandler()
	end
end

local function scrollToPoint( toPoint, isAnimate )
	isAnimate = isAnimate or false
	local centerPointX = containerLayer:getContentSize().width*0.5
	local centerPointY = containerLayer:getContentSize().height*0.5


	local offsetX = toPoint.x*g_fBgScaleRatio - centerPointX
	local offsetY = toPoint.y*g_fBgScaleRatio - centerPointY

	if(offsetX<0)then
		-- 不能超过左边界
		offsetX = 0
	end
	if(offsetY<0)then
		-- 不能超过下边界
		offsetY = 0
	end
	if(offsetX > bgNode:getContentSize().width*g_fBgScaleRatio - centerPointX-g_winSize.width*0.5)then
		-- 不能超过右边界
		print(GetLocalizeStringBy("key_1689"))
		offsetX = bgNode:getContentSize().width*g_fBgScaleRatio - centerPointX-g_winSize.width*0.5
	end
	if(offsetY > bgNode:getContentSize().height*g_fBgScaleRatio - centerPointY-g_winSize.height*0.5)then
		-- 不能超过上边界
		offsetY = bgNode:getContentSize().height*g_fBgScaleRatio - centerPointY-g_winSize.height*0.5
	end

	if(isAnimate == true)then
		fortScrollView:setContentOffsetInDuration(ccp(-offsetX, -offsetY), 0.3)
	else
		fortScrollView:setContentOffset(ccp(-offsetX, -offsetY))
	end
end

-- scroll 到 city
function scrollToCity(cityId)
	cityId = tonumber(cityId)
	local cityPoint = ccp(0,0)
	for k,fortInfo in pairs(GuildCity.models.normal) do
		if(cityId == tonumber(fortInfo.looks.look.armyID))then
			cityPoint = ccp(fortInfo.x, absY -fortInfo.y)
			print("scroll.x==="..fortInfo.x.."scroll.y==="..(absY -fortInfo.y))
			break
		end
	end

	scrollToPoint(cityPoint, true)
end

function createBgLayer( ... )
 	-- body
 	MainScene.setMainSceneViewsVisible(false, false, false)
 	containerLayer = CCLayer:create()
 	containerLayer:registerScriptHandler(onNodeEvent)
	fortScrollView = CCScrollView:create()
	local copyFileLua = "db/city1"
	_G[copyFileLua] = nil
	package.loaded[copyFileLua] = nil
	require (copyFileLua)

	--bgNode 上面有四块sprite
	bgNode = CCNode:create()
	bgNode:setAnchorPoint(ccp(0.5,0.5))
	--sp1
	local sp1 = CCSprite:create("images/citybattle/A.jpg")
	sp1:setAnchorPoint(ccp(0.5,0.5))
	sp1:setPosition(ccp(sp1:getContentSize().width*0.5,sp1:getContentSize().height*1.5))
	bgNode:addChild(sp1)
	CCTextureCache:sharedTextureCache():dumpCachedTextureInfo()
	--sp2
	local sp2 = CCSprite:create("images/citybattle/B.jpg")
	sp2:setAnchorPoint(ccp(0.5,0.5))
	sp2:setPosition(ccp(sp1:getContentSize().width*1.5,sp2:getContentSize().height*1.5))
	bgNode:addChild(sp2)
	--sp3
	local sp3 = CCSprite:create("images/citybattle/C.jpg")
	sp3:setAnchorPoint(ccp(0.5,0.5))
	sp3:setPosition(ccp(sp3:getContentSize().width*0.5,sp3:getContentSize().height*0.5))
	bgNode:addChild(sp3)
	--sp4
	local sp4 = CCSprite:create("images/citybattle/D.jpg")
	sp4:setAnchorPoint(ccp(0.5,0.5))
	sp4:setPosition(ccp(sp4:getContentSize().width*1.5,sp2:getContentSize().height*0.5))
	bgNode:addChild(sp4)
	--bgNode contentsize
	bgNode:setContentSize(CCSizeMake(sp1:getContentSize().width*2,sp1:getContentSize().height*2))
	bgNode:setScale(g_fBgScaleRatio)
	absY = bgNode:getContentSize().height
	absX = bgNode:getContentSize().width
	fortScrollView:setContainer(bgNode)
	fortScrollView:setTouchEnabled(true)
	fortScrollView:setViewSize(containerLayer:getContentSize())
	fortScrollView:setAnchorPoint(ccp(0,0))
	fortScrollView:setBounceable(false)
	containerLayer:addChild(fortScrollView)

	 -- 关闭按钮bar
	local closeMenuBar = CCMenu:create()
	closeMenuBar:setPosition(ccp(0, 0))
	containerLayer:addChild(closeMenuBar,20)
	closeMenuBar:setTouchPriority(-441)

    -- 关闭按钮
	local closeBtn = LuaMenuItem.createItemImage("images/common/close_btn_n.png", "images/common/close_btn_h.png", closeAction )
	closeBtn:setAnchorPoint(ccp(1, 1))
    closeBtn:setPosition(ccp(containerLayer:getContentSize().width*0.99, containerLayer:getContentSize().height*0.94))
    closeBtn:setScale(g_fBgScaleRatio)
	closeMenuBar:addChild(closeBtn,4)

	-- 说明按钮
	local desBtn = LuaMenuItem.createItemImage("images/recycle/btn/btn_explanation_h.png", "images/recycle/btn/btn_explanation_n.png", desAction )
	desBtn:setAnchorPoint(ccp(1, 1))
    desBtn:setPosition(ccp(containerLayer:getContentSize().width*0.99-closeBtn:getContentSize().width*1.2*g_fBgScaleRatio, containerLayer:getContentSize().height*0.95))
    desBtn:setScale(g_fBgScaleRatio)
	closeMenuBar:addChild(desBtn,4)

	-- 默认居中
	scrollToPoint(ccp(bgNode:getContentSize().width*0.5, bgNode:getContentSize().height*0.5))

 end

 function createCityPos( ... )

 	if(fortMenuBar)then
 		fortMenuBar:removeFromParentAndCleanup(true)
 		fortMenuBar = nil
 	end
 	fortMenuBar = CCMenu:create()
 	fortMenuBar:setPosition(ccp(0,0))
 	fortMenuBar:setTouchPriority(-440)
	bgNode:addChild(fortMenuBar)

	for k,fortInfo in pairs(GuildCity.models.normal) do
		local fortMenuItem = CityMenuItem.createItem(fortInfo.looks.look.armyID, CityMenuItem.Type_City_Normal)
		fortMenuItem:setAnchorPoint(ccp(0.5, 0))
		fortMenuItem:registerScriptTapHandler(cityMapAction)
		fortMenuItem:setPosition(ccp(fortInfo.x, absY -fortInfo.y))
		print("citypos.x======"..fortInfo.x)
		print("citypos.y======"..(absY -fortInfo.y))
		fortMenuBar:addChild(fortMenuItem,0,fortInfo.looks.look.armyID)
	end
 end

 function infoCallBack( cbFlag, dictData, bRet )
 	if(dictData.err == "ok")then
		CityData.setCityServiceInfo(dictData)

		local sucArry = CityData.getSucCity()
		local i = 0
		if(sucArry~=nil and not table.isEmpty(sucArry))then
			print("sucArry is not empty"..i)
			i = i + 1
			isShow = false
		end
		contribute = dictData.ret.contri_week
		createCityPos()
		cityStausMenus()

		-- 资源战 阶段提示
		showStepTip()
	end
end

 function getData( ... )
 	-- body
 	local data = GuildDataCache.getMineSigleGuildInfo()
    local tempArgs = CCArray:create()
	tempArgs:addObject(CCInteger:create(data.guild_id))
	RequestCenter.GuildSignUpInfo(infoCallBack, tempArgs)
 end
--[[
 @desc	创建据点的布局
 @para  table fortsData
 @return
 --]]
function createFortsLayout()
	init()
	createBgLayer()
	getData()


	return containerLayer
end

function cityAction( tag,item )
	require "script/ui/guild/city/CityInfoLayer"
	CityInfoLayer.showCityInfoLayer(tag,true)
	scrollToCity(tag)

end

function cityMapAction( tag,item )
	-- body
	require "script/ui/guild/city/CityInfoLayer"
	CityData.setId(tag)
	CityInfoLayer.showCityInfoLayer(tag,false)
end

function closeAction( ... )
	require "script/ui/guild/GuildMainLayer"
    local guildMainLayer = GuildMainLayer.createLayer(false)
  	MainScene.changeLayer(guildMainLayer, "guildMainLayer")
end

function desAction( ... )
	require "script/ui/copy/DesLayer"
    local desLayer = DesLayer.show()
end

-- add by chengliang
-- 刷新
function refreshMapUI()
	--
	createCityPos()
	-- 创建相关城池的快速入口
	cityStausMenus()
end


-- 创建相关城池的快速入口
function cityStausMenus( )
	local contributeNode = CCNode:create()

	containerLayer:addChild(contributeNode)

	local contributeSprite = CCSprite:create("images/citybattle/contribute.png")
	contributeSprite:setAnchorPoint(ccp(0,0.5))
	contributeNode:addChild(contributeSprite)

	local donataStr = GuildDataCache.getGuildDonate()
	local contributeLabel = CCRenderLabel:create(tostring(contribute),g_sFontPangWa,23,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	contributeLabel:setAnchorPoint(ccp(0,0.5))
	contributeLabel:setPosition(ccp(contributeSprite:getContentSize().width,contributeLabel:getContentSize().height*0.5))
	contributeSprite:addChild(contributeLabel)

	contributeNode:setContentSize(CCSizeMake(contributeSprite:getContentSize().width+contributeLabel:getContentSize().width,contributeSprite:getContentSize().height))
	contributeNode:setAnchorPoint(ccp(1,0.5))
	contributeNode:setPosition(ccp(containerLayer:getContentSize().width-10,containerLayer:getContentSize().height*0.86))
	contributeNode:setScale(g_fElementScaleRatio)

	if(statusMenuBar)then
		statusMenuBar:removeFromParentAndCleanup(true)
		statusMenuBar = nil
	end

	statusMenuBar = CCMenu:create()
	statusMenuBar:setPosition(ccp(0, 0))
	containerLayer:addChild(statusMenuBar)
	statusMenuBar:setTouchPriority(-442)
	local posIndex = 1

	-- 已报名的城市
	local signCity = CityData.getSignCity()
	local sucCity = CityData.getSucCity()

	-- 已占领的城市
	local occupyCity = CityData.getOcupyCityInfos()
	local rewardCity = CityData.getRewardCity()

	local occupyCityTable = {}
	if( not table.isEmpty(occupyCity)) then
		for k,guildInfo in pairs(occupyCity) do
			if( tonumber(guildInfo.guild_id) ==  GuildDataCache.getGuildId())then
				table.insert(occupyCityTable,tonumber(k))
			end
		end
	end
	if( not table.isEmpty(signCity)) then
		if(sucCity == nil or table.isEmpty(sucCity))then
			for k, cityid in pairs(signCity) do
				if( not table.isEmpty(occupyCityTable)) then
					for k,v in pairs(occupyCityTable) do
						if(tonumber(cityid)~=v)then
							print(GetLocalizeStringBy("key_2533"))
							local cityItem = CityMenuItem.createItem(cityid, CityMenuItem.Type_City_Quick)
							-- cityItem:setScale(0.7)
							cityItem:setScale(g_fBgScaleRatio*0.7)
							local statusSprite = CCSprite:create("images/citybattle/sign.png")
							city1 = cityItem
							cityItem:setAnchorPoint(ccp(0.5, 0.5))
							if(posIndex == 1)then
								cityItem:setPosition(ccp(cityItem:getContentSize().width*g_fBgScaleRatio*0.5, (containerLayer:getContentSize().height)*0.85))
							else
								cityItem:setPosition(ccp(containerLayer:getContentSize().width*( 0.2 * posIndex), (containerLayer:getContentSize().height)*0.85))
							end

							statusMenuBar:addChild(cityItem, 1, cityid)
							cityItem:registerScriptTapHandler(scrollToCity)--scrollToCity
							statusSprite:setAnchorPoint(ccp(0.5, 1))
							statusSprite:setPosition(ccp(cityItem:getContentSize().width*0.5, -20))
							cityItem:addChild(statusSprite,0,110)
							local _itemTipSprite = CCScale9Sprite:create("images/common/bg/bg_9s_2.png")
							_itemTipSprite:setContentSize(CCSizeMake(cityItem:getContentSize().width-20, cityItem:getContentSize().height))
							_itemTipSprite:setAnchorPoint(ccp(0.5, 0.5))
							_itemTipSprite:setPosition(ccp(cityItem:getContentSize().width*0.5, cityItem:getContentSize().height*0.5))
							-- cityItem:addChild(_itemTipSprite, 0)
							-- cityItem:reorderChild(_itemTipSprite,-1)
							posIndex = posIndex + 1
						end
					end
				else
					print(GetLocalizeStringBy("key_2533"))
					local cityItem = CityMenuItem.createItem(cityid, CityMenuItem.Type_City_Quick)
					-- cityItem:setScale(0.7)
					cityItem:setScale(g_fBgScaleRatio*0.7)
					local statusSprite = CCSprite:create("images/citybattle/sign.png")
					city1 = cityItem
					cityItem:setAnchorPoint(ccp(0.5, 0.5))
					if(posIndex == 1)then
						cityItem:setPosition(ccp(cityItem:getContentSize().width*g_fBgScaleRatio*0.5, (containerLayer:getContentSize().height)*0.85))
					else
						cityItem:setPosition(ccp(containerLayer:getContentSize().width*( 0.2 * posIndex), (containerLayer:getContentSize().height)*0.85))
					end

					statusMenuBar:addChild(cityItem, 1, cityid)
					cityItem:registerScriptTapHandler(scrollToCity)--scrollToCity
					statusSprite:setAnchorPoint(ccp(0.5, 1))
					statusSprite:setPosition(ccp(cityItem:getContentSize().width*0.5, -20))
					cityItem:addChild(statusSprite,0,110)
					local _itemTipSprite = CCScale9Sprite:create("images/common/bg/bg_9s_2.png")
					_itemTipSprite:setContentSize(CCSizeMake(cityItem:getContentSize().width-20, cityItem:getContentSize().height))
					_itemTipSprite:setAnchorPoint(ccp(0.5, 0.5))
					_itemTipSprite:setPosition(ccp(cityItem:getContentSize().width*0.5, cityItem:getContentSize().height*0.5))
					-- cityItem:addChild(_itemTipSprite, 0)
					-- cityItem:reorderChild(_itemTipSprite,-1)
					posIndex = posIndex + 1
				end
			end
		else
			-- for k, cityid in pairs(signCity) do
				for i=1,table.count(sucCity) do
					print(GetLocalizeStringBy("key_2790"))
					-- if(tonumber(sucCity[i])~=tonumber(cityid))then
						local cityItem = CityMenuItem.createItem(sucCity[i], CityMenuItem.Type_City_Quick)
						-- cityItem:setScale(0.7)
						cityItem:setScale(g_fBgScaleRatio*0.7)
						local statusSprite = CCSprite:create("images/citybattle/battle.png")
						city1 = cityItem
						cityItem:setAnchorPoint(ccp(0.5, 0.5))
						if(posIndex == 1)then
							cityItem:setPosition(ccp(cityItem:getContentSize().width*g_fBgScaleRatio*0.5, (containerLayer:getContentSize().height)*0.85))
						else
							cityItem:setPosition(ccp(containerLayer:getContentSize().width*( 0.2 * posIndex), (containerLayer:getContentSize().height)*0.85))
						end

						statusMenuBar:addChild(cityItem, 1, sucCity[i])
						cityItem:registerScriptTapHandler(cityAction)--scrollToCity
						statusSprite:setAnchorPoint(ccp(0.5, 1))
						statusSprite:setPosition(ccp(cityItem:getContentSize().width*0.5, -20))
						cityItem:addChild(statusSprite,0,110)
						local _itemTipSprite = CCScale9Sprite:create("images/common/bg/bg_9s_2.png")
						_itemTipSprite:setContentSize(CCSizeMake(cityItem:getContentSize().width-20, cityItem:getContentSize().height))
						_itemTipSprite:setAnchorPoint(ccp(0.5, 0.5))
						_itemTipSprite:setPosition(ccp(cityItem:getContentSize().width*0.5, cityItem:getContentSize().height*0.5))
						-- cityItem:addChild(_itemTipSprite, 0)
						-- cityItem:reorderChild(_itemTipSprite,-1)
						posIndex = posIndex + 1
					-- end
				end
			-- end
		end
	end


	if( not table.isEmpty(occupyCity)) then
		-- 可领奖的城市
		local rewardCity = CityData.getRewardCity()
		if(rewardCity ~= nil and tonumber(rewardCity)>0)then
			print(GetLocalizeStringBy("key_2233"))
			local cityItem = CityMenuItem.createItem(rewardCity,  CityMenuItem.Type_City_Quick)
			local statusSprite = CCSprite:create("images/citybattle/reward.png")
			-- cityItem:setScale(0.7)
			cityItem:setScale(g_fBgScaleRatio*0.7)
			city3 = cityItem
			cityItem:setAnchorPoint(ccp(0.5, 0.5))
			if(posIndex == 1)then
				cityItem:setPosition(ccp(cityItem:getContentSize().width*g_fBgScaleRatio*0.5, (containerLayer:getContentSize().height)*0.85))
			else
				cityItem:setPosition(ccp(containerLayer:getContentSize().width*( 0.2 * posIndex), (containerLayer:getContentSize().height)*0.85))
			end
			statusMenuBar:addChild(cityItem, 1, rewardCity)
			cityItem:registerScriptTapHandler(scrollToCity)

			statusSprite:setAnchorPoint(ccp(0.5, 1))
			statusSprite:setPosition(ccp(cityItem:getContentSize().width*0.5, -20))
			cityItem:addChild(statusSprite)
			local _itemTipSprite = CCScale9Sprite:create("images/common/bg/bg_9s_2.png")
			_itemTipSprite:setContentSize(CCSizeMake(cityItem:getContentSize().width*1.3, cityItem:getContentSize().height))
			_itemTipSprite:setAnchorPoint(ccp(0.5, 0.5))
			_itemTipSprite:setPosition(ccp(cityItem:getContentSize().width*0.5, cityItem:getContentSize().height*0.5))
			-- cityItem:addChild(_itemTipSprite, 0)
			-- cityItem:reorderChild(_itemTipSprite,-1)
			posIndex = posIndex + 1

		else
			for cityid, guildInfo in pairs(occupyCity) do
			if( tonumber(guildInfo.guild_id) ==  GuildDataCache.getGuildId())then
				print(GetLocalizeStringBy("key_3409"))
				local cityItem = CityMenuItem.createItem(cityid,  CityMenuItem.Type_City_Quick)
				local statusSprite = CCSprite:create("images/citybattle/occupy.png")
				-- cityItem:setScale(0.7)
				cityItem:setScale(g_fBgScaleRatio*0.7)
				city2 = cityItem
				cityItem:setAnchorPoint(ccp(0.5, 0.5))
				if(posIndex == 1)then
					cityItem:setPosition(ccp(cityItem:getContentSize().width*g_fBgScaleRatio*0.5, (containerLayer:getContentSize().height)*0.85))
				else
					cityItem:setPosition(ccp(containerLayer:getContentSize().width*( 0.2 * posIndex), (containerLayer:getContentSize().height)*0.85))
				end
				statusMenuBar:addChild(cityItem, 1, cityid)
				cityItem:registerScriptTapHandler(scrollToCity)

				statusSprite:setAnchorPoint(ccp(0.5, 1))
				statusSprite:setPosition(ccp(cityItem:getContentSize().width*0.5, -20))
				cityItem:addChild(statusSprite)
				local _itemTipSprite = CCScale9Sprite:create("images/common/bg/bg_9s_2.png")
				_itemTipSprite:setContentSize(CCSizeMake(cityItem:getContentSize().width-20, cityItem:getContentSize().height))
				_itemTipSprite:setAnchorPoint(ccp(0.5, 0.5))
				_itemTipSprite:setPosition(ccp(cityItem:getContentSize().width*0.5, cityItem:getContentSize().height*0.5))
				-- cityItem:addChild(_itemTipSprite, 0)
				-- cityItem:reorderChild(_itemTipSprite,-1)
				posIndex = posIndex + 1
			end
		end

	end
	end

	-- if(_itemTipSprite ~= nil)then
	-- 	_itemTipSprite:setVisible(false)
	-- 	_itemTipSprite:removeFromParentAndCleanup(true)
	-- 	_itemTipSprite=nil
	-- end
	-- -- _itemTipSprite = CCScale9Sprite:create("images/common/bg/bg_9s_2.png")
	-- if(city1~=nil)then
	-- 	city1Contentwidth = city1:getContentSize().width
	-- 	city1Contentheight = city1:getContentSize().height
	-- else
	-- 	city1Contentwidth = 0
	-- 	city1Contentheight = 0
	-- end

	-- if(city2~=nil)then
	-- 	city2Contentwidth = city2:getContentSize().width
	-- 	city2Contentheight = city2:getContentSize().height
	-- else
	-- 	city2Contentwidth = 0
	-- 	city2Contentheight = 0
	-- end

	-- if(city3~=nil)then
	-- 	city3Contentwidth = city3:getContentSize().width
	-- 	city3Contentheight = city3:getContentSize().height
	-- else
	-- 	city3Contentwidth = 0
	-- 	city3Contentheight = 0
	-- end

	-- local maxHeight = 0
	-- if(city1Contentheight>=city2Contentheight)then
	-- 	if(city1Contentheight>=city3Contentheight)then
	-- 		maxHeight = city1Contentheight
	-- 		print(GetLocalizeStringBy("key_2564"))
	-- 	else
	-- 		maxHeight = city3Contentheight
	-- 		print(GetLocalizeStringBy("key_2521"))
	-- 	end
	-- else
	-- 	if(city2Contentheight>=city3Contentheight)then
	-- 		maxHeight = city2Contentheight
	-- 		print(GetLocalizeStringBy("key_2589"))
	-- 	else
	-- 		maxHeight = city3Contentheight
	-- 		print(GetLocalizeStringBy("key_2521"))
	-- 	end
	-- end
	-- _itemTipSprite = CCScale9Sprite:create("images/common/bg/bg_9s_2.png")
	-- _itemTipSprite:setContentSize(CCSizeMake(city1Contentwidth+city2Contentwidth+city3Contentwidth, maxHeight))
	-- _itemTipSprite:setAnchorPoint(ccp(1, 0.5))
	-- _itemTipSprite:setPosition(ccp(containerLayer:getContentSize().width, _itemTipSprite:getContentSize().height*0.5))
	-- containerLayer:addChild(_itemTipSprite, 19)
	-- containerLayer:addChild(statusMenuBar)

end



function signUpCallBack( cbFlag, dictData, bRet )
	-- body
	CityData.setCityServiceInfo(dictData)
	signTable = CityData.getSignCity()
	local sucArry = CityData.getSucCity()
	local tipStrArry = {}
	local tipStr = ""
	if(sucArry~=nil and not table.isEmpty(sucArry))then
		-- isShow = true
		for j=1,table.count(signTable) do
			for i=1,table.count(sucArry) do
				if(tonumber(signTable[j])~=tonumber(sucArry[i]))then
					local failCityId = signTable[j]
					local cityDesc  = DB_City.getDataById(failCityId)
					-- local nameLabel = CCRenderLabel:create( cityDesc.name , g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
					table.insert(tipStrArry, cityDesc.name)
					if(table.count(tipStrArry)==1)then
						tipStr = tipStr..cityDesc.name
					elseif(table.count(tipStrArry)>1)then
						tipStr = tipStr.."、"..cityDesc.name
					end
				else
					-- local statusSpriteCpy = statusMenuBar:getChildByTag(sucArry[i]):getChildByTag(110)
					-- if(statusSpriteCpy~=nil)then
					-- 	statusSpriteCpy:setVisible(false)
					-- 	statusSpriteCpy:removeFromParentAndCleanup(true)
					-- 	statusSpriteCpy = nil
					-- 	statusSpriteCpy = CCSprite:create("images/citybattle/battle.png")
					-- 	statusMenuBar:getChildByTag(sucArry[i]):addChild(statusSpriteCpy,0,110)
					-- 	statusSpriteCpy:setAnchorPoint(ccp(0.5, 1))
					-- 	statusSpriteCpy:setPosition(ccp(statusMenuBar:getChildByTag(sucArry[i]):getContentSize().width*0.5, 0))
					-- end
					refreshMapUI()
				end
			end
			if(string.len(tipStr) ~= 0)then
				AnimationTip.showTip(GetLocalizeStringBy("key_2634")..tipStr..GetLocalizeStringBy("key_1970"))
			end
		end
	else
		if( not table.isEmpty(signTable)) then
			for k, cityid in pairs(signTable) do
				local cityDesc  = DB_City.getDataById(cityid)
				table.insert(tipStrArry, cityDesc.name)
				if(table.count(tipStrArry)==1)then
					tipStr = tipStr..cityDesc.name
				elseif(table.count(tipStrArry)>1)then
					tipStr = tipStr.."、"..cityDesc.name
				end
			end
			AnimationTip.showTip(GetLocalizeStringBy("key_2634")..tipStr..GetLocalizeStringBy("key_1970"))
		end
	end
end

-- 资源战 阶段提示
function showStepTip()
	local timesInfo = CityData.getTimeTable()

	if( TimeUtil.getSvrTimeByOffset()>= timesInfo.signupStart and TimeUtil.getSvrTimeByOffset() <= tonumber(timesInfo.arrAttack[2][1] ) )then
		if(_stepTipSprite == nil)then
			-- 背景
			_stepTipSprite = CCScale9Sprite:create("images/common/bg/bg_9s_2.png")
			_stepTipSprite:setContentSize(CCSizeMake(640, 50))
			_stepTipSprite:setAnchorPoint(ccp(0.5, 1))
			_stepTipSprite:setPosition(ccp(containerLayer:getContentSize().width*0.5, containerLayer:getContentSize().height))
			containerLayer:addChild(_stepTipSprite, 19)
			_stepTipSprite:setScale(g_fScaleX)
			-- 喇叭
			local labaSprite = CCSprite:create("images/citybattle/laba.png")
			labaSprite:setAnchorPoint(ccp(0, 0.5))
			labaSprite:setPosition(ccp(_stepTipSprite:getContentSize().width*0.01, _stepTipSprite:getContentSize().height*0.5))
			_stepTipSprite:addChild(labaSprite)

			-- 文字
			_stepTipLabel = CCLabelTTF:create( "00:00:00", g_sFontPangWa,21)
			_stepTipLabel:setAnchorPoint(ccp(0.5, 0.5))
			_stepTipLabel:setColor(ccc3(0xff,0xf6,0x00))
			_stepTipLabel:setPosition(ccp(_stepTipSprite:getContentSize().width*0.5, _stepTipSprite:getContentSize().height*0.5))
			_stepTipSprite:addChild(_stepTipLabel)
		end
	else
		if(_stepTipSprite)then
			_stepTipSprite:removeFromParentAndCleanup(true)
			_stepTipSprite = nil
		end
		return
	end

	if( TimeUtil.getSvrTimeByOffset() >= timesInfo.signupStart and TimeUtil.getSvrTimeByOffset() <= timesInfo.signupEnd )then
		-- 报名阶段
		_stepTipLabel:setString(GetLocalizeStringBy("key_1548") .. TimeUtil.getTimeString(timesInfo.signupEnd - TimeUtil.getSvrTimeByOffset()))

	elseif(TimeUtil.getSvrTimeByOffset() > timesInfo.signupEnd and TimeUtil.getSvrTimeByOffset() < tonumber(timesInfo.arrAttack[1][1]) - timesInfo.prepare)then
		-- 间歇期间
		_stepTipLabel:setString(GetLocalizeStringBy("key_2192") .. CityData.getTimeStrByNum(tonumber(timesInfo.arrAttack[1][1]) ) .. GetLocalizeStringBy("key_2813") )

	elseif(TimeUtil.getSvrTimeByOffset() >= tonumber(timesInfo.arrAttack[1][1]) - timesInfo.prepare and TimeUtil.getSvrTimeByOffset() < tonumber(timesInfo.arrAttack[1][1]) )then
		-- 第一场准备时间
		_stepTipLabel:setString(GetLocalizeStringBy("key_1306") .. TimeUtil.getTimeString(tonumber(timesInfo.arrAttack[1][1]) - TimeUtil.getSvrTimeByOffset()))

		if(isShow==true)then
			isShow = false
			local seq = CCSequence:createWithTwoActions(CCDelayTime:create(2),CCCallFunc:create(function ( ... )
	    		getSuc()
			end))
			_stepTipLabel:runAction(seq)
		end

	elseif(TimeUtil.getSvrTimeByOffset() >= tonumber(timesInfo.arrAttack[1][1]) and TimeUtil.getSvrTimeByOffset() < tonumber(timesInfo.arrAttack[1][2]) )then
		-- 第一场 战斗中
		_stepTipLabel:setString(GetLocalizeStringBy("key_3120"))
		if(isBattle == true)then
			isBattle = false
			refreshMapUI()
		end
	elseif(TimeUtil.getSvrTimeByOffset() >= tonumber(timesInfo.arrAttack[1][2]) - timesInfo.prepare and TimeUtil.getSvrTimeByOffset() < tonumber(timesInfo.arrAttack[2][1]) )then
		-- 第二场准备时间
		_stepTipLabel:setString(GetLocalizeStringBy("key_1631") .. TimeUtil.getTimeString(tonumber(timesInfo.arrAttack[2][1]) - TimeUtil.getSvrTimeByOffset()))
	end

	local actionArray = CCArray:create()
	actionArray:addObject(CCDelayTime:create(1))
	actionArray:addObject(CCCallFunc:create(showStepTip))
	_stepTipSprite:runAction(CCSequence:create(actionArray))

end

function getSuc(...)
	-- body
	local signCity = CityData.getSignCity()
	signTable = signCity
	--报名结束后拉一次数据 是否报名成功
	local data = GuildDataCache.getMineSigleGuildInfo()
    local tempArgs = CCArray:create()
	tempArgs:addObject(CCInteger:create(data.guild_id))
	RequestCenter.GuildSignUpInfo(signUpCallBack, tempArgs)
end


