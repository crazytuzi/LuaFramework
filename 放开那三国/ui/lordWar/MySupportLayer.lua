-- FileName: MySupportLayer.lua
-- Author: llp
-- Date: 14-4-21
-- Purpose: 查看报名军团


module("MySupportLayer", package.seeall)

require "script/utils/BaseUI"
require "script/ui/guild/city/CityService"
require "script/ui/guild/GuildImpl"
require "script/ui/lordWar/LordWarService"

local _bgLayer                  = nil
local _backGround 				= nil
local secondSprite  			= nil
local _thisCityID 				= nil
local _listData 				= nil
local _selfData 				= nil
local cellDataCache 			= nil
local cellIndex 				= 0
local cellDataCacheCpy 			= {}

function init( ... )
	_bgLayer                    = nil
	_backGround 				= nil
	secondSprite  				= nil
	_thisCityID 				= nil
	_listData 					= nil
	_selfData 					= nil
	cellDataCache 				= nil
	cellIndex 					= 0
	cellDataCacheCpy 			= {}
end

-- data = {
-- 			{round=8,serverId=30001,serverName="qweqewq",uid=123123,uname="123123",result=true,teamType=1},
-- 			{round=7,serverId=30001,serverName="123444aa",uid=123123,uname="123123",result=false,teamType=2},
-- 			{round=6,serverId=30001,serverName="qweqewq",uid=123123,uname="123123",result=true,teamType=1},
-- 			{round=5,serverId=30001,serverName="qweqewq",uid=123123,uname="123123",result=false,teamType=2},
-- 			{round=4,serverId=30001,serverName="qweqewq",uid=123123,uname="123123",result=true,teamType=1},
-- 		}

-- touch事件处理
local function cardLayerTouch(eventType, x, y)
    return true
end

-- 关闭按钮回调
function closeButtonCallback( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
	if(_bgLayer)then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	end
end

function onNodeEvent( event )
	if (event == "enter") then
		print("enter")
		_bgLayer:registerScriptTouchHandler(cardLayerTouch,false,-453,true)
		_bgLayer:setTouchEnabled(true)
		-- 注册删除回调
		GuildImpl.registerCallBackFun("LookApplyLayer",closeButtonCallback)
	elseif (event == "exit") then
		print("exit")
		_bgLayer:unregisterScriptTouchHandler()
		_bgLayer = nil
		GuildImpl.registerCallBackFun("LookApplyLayer",nil)
	end
end

-- 初始化界面
function createLayer( ... )
	init()
	-- print(data.round.."fuck you shit")
	local baseNode = CCNode:create()
	baseNode:setContentSize(CCSizeMake(625,660))

	secondSprite = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	secondSprite:setContentSize(CCSizeMake(565,515))
	secondSprite:setAnchorPoint(ccp(0.5,1))
	secondSprite:setPosition(ccp(baseNode:getContentSize().width/2,baseNode:getContentSize().height - 40))
	baseNode:addChild(secondSprite)
--目录标题
	local fullRect = CCRectMake(0,0,74,63)
	local insetRect = CCRectMake(34,18,4,1)
	local titleListBg = CCScale9Sprite:create("images/guild/city/titleBg.png", fullRect, insetRect)
	titleListBg:setContentSize(CCSizeMake(575,65))
	titleListBg:setAnchorPoint(ccp(0.5,1))
	titleListBg:setPosition(ccp(baseNode:getContentSize().width/2,baseNode:getContentSize().height))
	baseNode:addChild(titleListBg)

	--2条分割线

	local triLineXTable = {165,425}
	local spriteNameTable = {
								[1] = "images/lord_war/battlereport/round.png",
								[2] = "images/lord_war/supportdetail.png",
							}
	local nameXTable = {90,282}
	for i = 1,2 do
		-- if i ~= 2 then
			local lineSprite = CCSprite:create("images/guild/city/fen.png")
			lineSprite:setAnchorPoint(ccp(0.5,1))
			lineSprite:setPosition(ccp(triLineXTable[i],titleListBg:getContentSize().height - 5))
			titleListBg:addChild(lineSprite)
		-- end

		local listNameSprite = CCSprite:create(spriteNameTable[i])
		listNameSprite:setAnchorPoint(ccp(0.5,0.5))
		listNameSprite:setPosition(ccp(nameXTable[i],titleListBg:getContentSize().height/2 + 5))
		titleListBg:addChild(listNameSprite)
	end
	LordWarService.getMySupport(serviceCallFunc)
-- 创建tableView

	return baseNode
end

-- 创建tableView
function createTableView( ... )
	local cellSize = CCSizeMake(565, 100)
	local h = LuaEventHandler:create(function(fn, table, a1, a2) 	--创建
		local r
		if fn == "cellSize" then
			r = cellSize
		elseif fn == "cellAtIndex" then
			r = createCell(cellDataCacheCpy[a1+1])
		elseif fn == "numberOfCells" then
			local index = 0
			for k,v in pairs(cellDataCache)do
				index = index+1
			end
			r =  index
		else
		end
		return r
	end)
	return LuaTableView:createWithHandler(h, CCSizeMake(565,515))
end

-- cell
function createCell(dataCache)
	local cell = CCTableViewCell:create()
	local gameTypeLabel = nil
	-- for k,v in pairs(dataCache)do
		if(tonumber(dataCache.key)>=10)then
			gameTypeLabel = CCRenderLabel:create( GetLocalizeStringBy("llp_91") , g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		else
			gameTypeLabel = CCRenderLabel:create( GetLocalizeStringBy("llp_92") , g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		end
		gameTypeLabel:setColor(ccc3(0xff,0xf6,0x00))
		cell:addChild(gameTypeLabel)
		gameTypeLabel:setAnchorPoint(ccp(0,0.5))
		gameTypeLabel:setPosition(ccp(10,74))

		local resultSprite = nil
		if(dataCache.win~=nil)then
            if(tonumber(dataCache.win)==1)then
                resultSprite = CCSprite:create("images/lord_war/pass.png")
            else
                resultSprite = CCSprite:create("images/lord_war/notpass.png")
            end
		else
			resultSprite = nil
		end
		if(resultSprite~=nil)then
			cell:addChild(resultSprite)
			resultSprite:setAnchorPoint(ccp(1,0.5))
			resultSprite:setPosition(ccp(530,56))
		end

		local labelNode = CCNode:create()
		cell:addChild(labelNode)
		labelNode:setAnchorPoint(ccp(0.5,0.5))

		local supportLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_93"),g_sFontName,20)
		labelNode:addChild(supportLabel)
		supportLabel:setAnchorPoint(ccp(0,0.5))
		supportLabel:setPosition(ccp(0,supportLabel:getContentSize().height*2))

		local nameLabel = CCLabelTTF:create(dataCache.uname,g_sFontName,20)
		labelNode:addChild(nameLabel)
		nameLabel:setAnchorPoint(ccp(0,0.5))
		nameLabel:setPosition(ccp(supportLabel:getContentSize().width,supportLabel:getContentSize().height*2))

		local serverLabel = CCLabelTTF:create("("..dataCache.serverName..")",g_sFontName,20)
		labelNode:addChild(serverLabel)
		serverLabel:setAnchorPoint(ccp(0.5,0.5))
		serverLabel:setPosition(ccp((supportLabel:getContentSize().width+nameLabel:getContentSize().width)*0.5,supportLabel:getContentSize().height))

		labelNode:setContentSize(CCSizeMake(supportLabel:getContentSize().width+nameLabel:getContentSize().width,supportLabel:getContentSize().height*2+10))
		nameLabel:setColor(ccc3(0x00,0xe4,0xff))

		labelNode:setPosition(ccp(300,50))

		local roundSprite = nil
		local roundLabel = nil
		local roundNum = LordWarData.getRoundRank(tonumber(dataCache.key))
		if(tonumber(roundNum)/2>2)then
			roundLabel = CCLabelTTF:create((roundNum/2)..GetLocalizeStringBy("llp_94"),g_sFontPangWa,20)
			gameTypeLabel:addChild(roundLabel)
			roundLabel:setAnchorPoint(ccp(1,1))

			local battleSprite = CCSprite:create("images/lord_war/battlematch.png")
			gameTypeLabel:addChild(battleSprite)
			battleSprite:setAnchorPoint(ccp(0,1))

			roundLabel:setPosition(ccp(gameTypeLabel:getContentSize().width*0.5-((roundLabel:getContentSize().width+battleSprite:getContentSize().width)*0.5-roundLabel:getContentSize().width),0))
			battleSprite:setPosition(ccp(gameTypeLabel:getContentSize().width*0.5-((roundLabel:getContentSize().width+battleSprite:getContentSize().width)*0.5-roundLabel:getContentSize().width),0))
		elseif(tonumber(roundNum)/2==2)then
			local halfSprite = CCSprite:create("images/lord_war/halfbattle.png")
			cell:addChild(halfSprite)
			halfSprite:setAnchorPoint(ccp(0.5,0.5))
			halfSprite:setPosition(ccp(gameTypeLabel:getContentSize().width*0.5,50))
		elseif(tonumber(roundNum)/2==1)then
			local lastMatchSprite = CCSprite:create("images/lord_war/totallastmatch.png")
			cell:addChild(lastMatchSprite)
			lastMatchSprite:setAnchorPoint(ccp(0.5,0.5))
			lastMatchSprite:setPosition(ccp(gameTypeLabel:getContentSize().width*0.5,50))
		end

		-- 分割线
	 	local lineSprite = CCScale9Sprite:create("images/common/line02.png")
		lineSprite:setContentSize(CCSizeMake(534, 4))
		lineSprite:setAnchorPoint(ccp(0.5, 0))
		lineSprite:setPosition(ccp(565*0.5,0))
		cell:addChild(lineSprite)
	-- end

	return cell
end

-- 网络请求回调
function serviceCallFunc()

	cellDataCache = LordWarData.getMySupportInfo()
	for k,v in pairs(cellDataCache)do
		local x = v
		x.key = k
		table.insert(cellDataCacheCpy,x)
	end
	if(cellDataCacheCpy~=nil)then
		local function keySort ( cellDataCacheCpy1, cellDataCacheCpy2 )
			return tonumber(cellDataCacheCpy1.key) > tonumber(cellDataCacheCpy2.key)
		end
		table.sort( cellDataCacheCpy, keySort )
	end

	if(table.isEmpty(cellDataCache))then
		return
	end
	local tableView = createTableView()
	tableView:setBounceable(true)
	tableView:setTouchPriority(-1753)
	tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	tableView:ignoreAnchorPointForPosition(false)
	tableView:setAnchorPoint(ccp(0,0))
	tableView:setPosition(ccp(0,0))
	secondSprite:addChild(tableView)
end
















