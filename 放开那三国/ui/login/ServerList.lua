-- Filename: ServerList.lua
-- Author: 李晨阳
-- Date: 2013-08-15
-- Purpose: 服务器列表


module ("ServerList", package.seeall)

require "script/ui/rewardCenter/AdaptTool"
require "script/libs/LuaCC"

serverListData = nil
_serverRecentServer = nil
local maskLayer = nil
local selectServer = nil


function init( )
	background          = nil
	selectServer        = nil
	maskLayer           = nil
end

function create()
	init()
	require "script/utils/BaseUI"
	maskLayer = BaseUI.createMaskLayer(-1000)

	local background = CCSprite:create("images/login/server_list_bg.png")
	background:setPosition(ccps(0.5, 0.5))
	background:setAnchorPoint(ccp(0.5, 0.5))
	maskLayer:addChild(background)

	local scrollView = CCScrollView:create()
	scrollView:setViewSize(CCSizeMake(background:getContentSize().width - 14, background:getContentSize().height -20))
	scrollView:setPosition(ccp(0, 10))
	background:addChild(scrollView)
	--计算scrollview 的contentSize
	local recentServerList = getRecentServerList()
	local s_widht = background:getContentSize().width - 14
	local s_height = 85 * table.count(serverListData)/2 + 60
	if(recentServerList ~= nil) then
		s_height = s_height + 85 * #recentServerList/2 + 60
	end
	print("scrollView contentSize")
	print(s_widht, s_height)

	scrollView:setContentSize(CCSizeMake(s_widht, s_height))
	scrollView:setContentOffset(ccp(0, scrollView:getViewSize().height - s_height))
	scrollView:setDirection(kCCScrollViewDirectionVertical)
	scrollView:setTouchPriority(-1100)
	local menu = CCMenu:create()
	menu:setPosition(ccp(0, 0))
	menu:setAnchorPoint(ccp(0, 0))
	menu:setTouchPriority(-1200)
	scrollView:addChild(menu)

	local startY = scrollView:getContentSize().height - 50
	require "script/libs/LuaCC"
	if(recentServerList ~= nil) then
		local recentServerLabel = CCLabelTTF:create(GetLocalizeStringBy("key_3006"), g_sFontName, 24)
		recentServerLabel:setAnchorPoint(ccp(0, 1))
		local x = scrollView:getContentSize().width*0.5 - recentServerLabel:getContentSize().width*0.5
		recentServerLabel:setPosition(x, startY)
		scrollView:addChild(recentServerLabel)
		
		startY = startY - 40
		local tempNum = 0
		local ox, oy = scrollView:getContentSize().width*0.25, startY
		local ow, oh = scrollView:getContentSize().width*0.52 , 80

		for k,v in pairs(recentServerList) do

			local serverButton = createServerButton(v)
		    serverButton:setAnchorPoint(ccp(0.5, 0.5))
		    serverButton:setPosition(ox + tempNum%2 * ow, oy - math.floor(tempNum/2) * oh)
			menu:addChild(serverButton,1,1000+tonumber(k))

			if(tempNum%2 == 0) then
				startY = startY - 80
			end
			tempNum = tempNum + 1
		end
	end
	local allServerLabel = CCLabelTTF:create(GetLocalizeStringBy("key_2481"), g_sFontName, 24)
	allServerLabel:setAnchorPoint(ccp(0.5, 1))
	local x = scrollView:getContentSize().width*0.5 - allServerLabel:getContentSize().width*0.5
	allServerLabel:setPosition(x, startY )
	scrollView:addChild(allServerLabel)

	local tempNum = 0
	local ox, oy = scrollView:getContentSize().width*0.25, startY - 40
	local ow, oh = scrollView:getContentSize().width*0.52 , 80

	--modify by lichenyang 服务器列表倒序排列修改
	local newServerListData = {}
	for k,v in pairs(serverListData) do
		local serverDic = {}
		serverDic.key 	= k
		serverDic.value	= v
		table.insert(newServerListData, serverDic)
	end

	for i=#newServerListData,1,-1 do
		local serverButton = createServerButton(newServerListData[i].value)
	    serverButton:setAnchorPoint(ccp(0.5, 0.5))
	    serverButton:setPosition(ox + tempNum%2 * ow, oy - math.floor(tempNum/2) * oh)
		menu:addChild(serverButton,1,2000+tonumber(newServerListData[i].key))
		tempNum = tempNum + 1		
	end
	
	require "script/ui/rewardCenter/AdaptTool"
	AdaptTool.setAdaptNode(background)

	return maskLayer
end

function serverButtonCallback( tag,sender )
	
	local tempTag = sender:getTag()
	print(tempTag)
	if(tempTag < 2000 ) then
		local recentServerList = getRecentServerList()
		selectServer = recentServerList[sender:getTag() -1000]
	else
		selectServer = serverListData[sender:getTag() -2000]
	end

	print_t(selectServer)
	require "script/ui/login/LoginScene"
	LoginScene.setSelectInfo(selectServer)
	maskLayer:removeFromParentAndCleanup(true)
	maskLayer = nil
end

--[[
    [show] => 1
    [new] => 1
    [openDateTime] => 1380088800
    [host] => 117.121.21.10
    [server_id] => 1
    [group] => 40000001
    [hot] => 0
    [Status] => 1
    [name] => 首次封测服
    [port] => 8001
]]--
--得到默认选择的服务器
function getSelectServerInfo( ... )
	if(selectServer == nil) then
		if(getLastLoginServer() ~= nil) then
			return getLastLoginServer()
		else
			if(serverListData == nil or #serverListData == 0) then
				return nil
			end
			if(serverListData[#serverListData] ~= nil) then
				return serverListData[#serverListData]
			else
				return nil
			end
		end
	else
		return selectServer
	end
end

--得到最近选择的服务器
function getRecentServerList()
	local recentServerGroup = CCUserDefault:sharedUserDefault():getStringForKey("recentServerGroup")
	print("recentServerGroup = ", recentServerGroup)
	local recentServer = nil
	local recentGroupTable = nil
	if(recentServerGroup == nil or recentServerGroup == "") then
		return recentServer
	else
		recentServer = {}
		recentGroupTable = string.split(recentServerGroup, ",")
		for k1,groupId in pairs(recentGroupTable) do
			for k2,v in pairs(serverListData) do
				print("v.group = ",v.group, "recentServerGroup = ", groupId)
				if(v.group and v.group == groupId) then
					table.insert(recentServer, v)
				end
			end			
		end
	end
	_serverRecentServer = _serverRecentServer or {}
	for k,v in pairs(_serverRecentServer) do
		local isFind = false
		for key,value in pairs(recentServer) do
			if v.group == value.group then
				isFind = true
				break
			end
		end
		if not isFind then
			table.insert(recentServer, v)
		end
	end
	return recentServer
end


function addRecentServerGroup(server_group)
	local recentServerGroup = CCUserDefault:sharedUserDefault():getStringForKey("recentServerGroup")
	if(recentServerGroup == nil or recentServerGroup == "") then
		--第一次添加
		CCUserDefault:sharedUserDefault():setStringForKey("recentServerGroup",server_group)
		CCUserDefault:sharedUserDefault():flush()
	else
		local recentGroupTable = string.split(recentServerGroup, ",")
		for k,v in pairs(recentGroupTable) do
			if(server_group == v) then
				return
			end
		end
		CCUserDefault:sharedUserDefault():setStringForKey("recentServerGroup",recentServerGroup .. "," .. server_group)
		CCUserDefault:sharedUserDefault():flush()
	end
end

function getLastLoginServer( )
	local lastLoginGroup = CCUserDefault:sharedUserDefault():getStringForKey("lastLoginGroup")
	if(serverListData == nil) then
		return nil
	end

	for k,v in pairs(serverListData) do
		if(lastLoginGroup == v.group) then
			return v
		end
	end
	return nil
end

--[[
	@:des	根据serverlist 中单个item 创建一个服务器按钮
]]
function createServerButton( serverInfo )

	local norSprite = CCScale9Sprite:create("images/login/ng_button_n.png")
	norSprite:setContentSize(CCSizeMake(210,55))
	local higSprite = CCScale9Sprite:create("images/login/ng_button_n.png")
	higSprite:setContentSize(CCSizeMake(210,55))

	local serverButton = CCMenuItemSprite:create(norSprite,higSprite)
	local labelArray = {}
	local label1 = CCLabelTTF:create(serverInfo.name, g_sFontName, serverButton:getContentSize().height * 0.45)
	table.insert(labelArray, label1)

	if(tonumber(serverInfo.hot) == 1) then
		local hotSprite = CCSprite:create("images/login/hot.png")
		hotSprite:setAnchorPoint(ccp(1, 1))
		hotSprite:setPosition(ccpsprite(1, 1, serverButton))
		serverButton:addChild(hotSprite)	
	end

	if(tonumber(serverInfo.new) == 1) then
		local newSprite = CCSprite:create("images/login/new.png")
		newSprite:setAnchorPoint(ccp(1, 1))
		newSprite:setPosition(ccpsprite(1, 1, serverButton))
		serverButton:addChild(newSprite)
	end

	if(tonumber(serverInfo.status) ~= 1) then
		local newSprite = CCSprite:create("images/login/stop.png")
		newSprite:setAnchorPoint(ccp(1, 1))
		newSprite:setPosition(ccpsprite(1, 1, serverButton))
		serverButton:addChild(newSprite)
		-- serverButton:setEnabled(false)
	end

	require "script/utils/BaseUI"
	local serverLabelNode = BaseUI.createHorizontalNode(labelArray)
	serverLabelNode:setAnchorPoint(ccp(0, 0.5))
	serverLabelNode:setPosition(ccp(serverButton:getContentSize().width*0.04, serverButton:getContentSize().height/2))
	serverButton:addChild(serverLabelNode)
	serverButton.info = serverInfo
	serverButton:registerScriptTapHandler(serverButtonCallback)

	return serverButton
end

--[[
	@des : 通过GroupId算出区号
	@parm: groupId
--]]
function getServerNumByGroupId( p_groupId )
	return tonumber(p_groupId)%10000
end

--[[
	@des : 设置服务端保存的已登录过得服务器
--]]
function setRecentServerItem( pServertItemArray )
	_serverRecentServer = pServertItemArray
end


