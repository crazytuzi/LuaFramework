function c_func(f, ...)
	local args1 = {
	...
	}
	return function ()
		return f(unpack(args1))
	end
end

function readTable(data_table, index, msg)
	local outMsg = msg or ""
	if type(data_table[index]) == "nil" then
		if device.platform == "windows" or device.platform == "mac" then
			CCMessageBox(common:getLanguageString("@dubiaocw") .. index, outMsg)
		end
	else
		return data_table[index]
	end
end

function GameAssert(isAs, str)
	if device.platform == "windows" or device.platform == "mac" then
		assert(isAs, str)
	end
end

function logOut(xxx, dumpData)
	dump(xxx)
	if dumpData ~= nil then
	end
end

function RegNotice(target, listener, key)
	CCNotificationCenter:sharedNotificationCenter():registerScriptObserver(target, listener, key)
end

function UnRegNotice(target, key)
	CCNotificationCenter:sharedNotificationCenter():unregisterScriptObserver(target, key)
end

function PostNotice(key, msg)
	if msg == nil then
		CCNotificationCenter:sharedNotificationCenter():postNotification(key)
	else
		CCNotificationCenter:sharedNotificationCenter():postNotification(key, msg)
	end
end

function setControlBtnEvent(btn, func, soundFunc)
	btn:addHandleOfControlEvent(function (sender, eventName)
		sender:runAction(transition.sequence({
		CCCallFunc:create(function ()
			if soundFunc ~= nil then
				soundFunc()
			else
				GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
			end
			func()
		end)
		}))
	end,
	CCControlEventTouchUpInside)
end

local SEC_OF_MIN = 60
local SEC_OF_HOUR = 3600

function format_time(t)
	local hour = math.floor(t / SEC_OF_HOUR)
	local min = math.floor(t % SEC_OF_HOUR / SEC_OF_MIN)
	local sec = t - hour * SEC_OF_HOUR - min * SEC_OF_MIN
	return string.format("%02d:%02d:%02d", hour, min, sec)
end

function format_time_to_min(t)
	local min = math.floor(t / SEC_OF_MIN)
	local sec = t - min * SEC_OF_MIN
	return string.format("%02d:%02d", min, sec)
end

function format_time_unit(t)
	local hour = math.floor(t / SEC_OF_HOUR)
	local min = math.floor(t % SEC_OF_HOUR / SEC_OF_MIN)
	local sec = t - hour * SEC_OF_HOUR - min * SEC_OF_MIN
	return string.format("%02d小时%02d分%02d秒", hour, min, sec)
end

function arrangeTTF(cells)
	for i = 1, #cells do
		if i ~= 1 then
			cells[i]:setPosition(cells[i - 1]:getPositionX() + cells[i - 1]:getContentSize().width, cells[i - 1]:getPositionY())
		end
	end
end

function arrangeTTFByPosX(cells)
	for i = 1, #cells do
		if i ~= 1 then
			cells[i]:setPositionX(cells[i - 1]:getPositionX() + cells[i - 1]:getContentSize().width)
		end
	end
end

function copyNodePos(nodes)
	local orNode = nodes[1]
	local tarNode = nodes[2]
	local anchor = tarNode:getAnchorPoint()
	orNode:setAnchorPoint(anchor)
	orNode:setPosition(tarNode:getPositionX(), tarNode:getPositionY())
end

function LoadUI(ccbName, rootnode)
	local ccb_proxy = CCBProxy:create()
	local uiclass = CCBuilderReaderLoad(ccbName, ccb_proxy, rootnode)
	if uiclass == nil then
	end
	return uiclass
end

local sharedDirector = CCDirector:sharedDirector()
local sceneLevel = 1

function push_scene(scene)
	assert(scene, "Scene is nil")
	sceneLevel = sceneLevel + 1
	printf("push scene")
	sharedDirector:pushScene(scene)
end

function pop_scene()
	printf("pop scene: " .. tostring(display.getRunningScene().__cname))
	if sceneLevel > 1 then
		sceneLevel = sceneLevel - 1
		sharedDirector:popScene()
	end
end

function show_tip_label(str, delay)
	dump(str)
	local tipLabel = require("utility.TipLabel").new(str, delay)
	display.getRunningScene():addChild(tipLabel, 3000000)
end

function get_table_len(t)
	local i = 0
	for k, v in pairs(t) do
		i = i + 1
	end
	return i
end

function res_path(path)
	if CCFileUtils:sharedFileUtils():isAbsolutePath(path) then
		local pos, _ = string.find(path, "/res/")
		if pos then
			local tmpPath = device.writablePath .. string.sub(path, pos + 1)
			if io.exists(tmpPath) then
				return tmpPath
			else
				return path
			end
		else
			return path
		end
	else
		for _, v in ipairs(SearchPath) do
			local tmpPath = device.writablePath .. v .. path
			if io.exists(tmpPath) then
				return tmpPath
			end
		end
		return CCFileUtils:sharedFileUtils():fullPathForFilename(path)
	end
end

function setNodeSize(node, width, height)
	local tarNode = node
	local orWidth = node:getContentSize().width
	local orHeight = node:getContentSize().height
	if width ~= nil then
		node:setScaleX(width / orWidth)
	end
	if height ~= nil then
		node:setScaleY(height / orHeight)
	end
end

function alignNodesOneByOne(node1, node2, gap)
	local gap = gap or 0
	if node1 ~= nil and node2 ~= nil then
		local AnchorPoint1 = node1:getAnchorPoint().x
		local AnchorPoint2 = node2:getAnchorPoint().x
		local controlGap1 = node1:getContentSize().width * node1:getScaleX() * AnchorPoint1
		local controlGap2 = node2:getContentSize().width * node2:getScaleX() * AnchorPoint2
		node2:setPositionX(node1:getPositionX() + node1:getContentSize().width * node1:getScaleX() - controlGap1 + controlGap2 + gap)
	end
end

function alignNodesOneByOneCenterX(node1, node2, node3)
	if node1 ~= nil and node2 ~= nil and node3 ~= nil then
		local width1 = node1:getContentSize().width
		local width2 = node2:getContentSize().width
		local width3 = node3:getContentSize().width
		local AnchorPoint2 = node2:getAnchorPoint().x
		local posX = width1 / 2 - (width2 + width3) / 2 + AnchorPoint2 * width2
		node2:setPositionX(posX)
		alignNodesOneByOne(node2, node3)
	end
end

function alignNodesOneByAllRightX(nodeTable, gap)
	local n = #nodeTable
	local gap = gap or 0
	for i, v in ipairs(nodeTable) do
		if i ~= n then
			local node1 = nodeTable[n - i + 1]
			local node2 = nodeTable[n - i]
			local AnchorPoint1 = node1:getAnchorPoint().x
			local AnchorPoint2 = node2:getAnchorPoint().x
			local controlGap1 = node1:getContentSize().width * node1:getScaleX() * (1 - AnchorPoint1)
			local controlGap2 = node2:getContentSize().width * node2:getScaleX() * (1 - AnchorPoint2)
			node2:setPositionX(node1:getPositionX() - node1:getContentSize().width * node1:getScaleX() + controlGap1 - controlGap2 - gap)
		end
	end
end

function alignNodesOneByAll(nodeTable, gap)
	local gap = gap or 0
	for i, v in ipairs(nodeTable) do
		if i ~= 1 and v ~= nil then
			local node1 = nodeTable[i - 1]
			local node2 = v
			local AnchorPoint1 = node1:getAnchorPoint().x
			local AnchorPoint2 = node2:getAnchorPoint().x
			local controlGap1 = node1:getContentSize().width * node1:getScaleX() * AnchorPoint1
			local controlGap2 = node2:getContentSize().width * node2:getScaleX() * AnchorPoint2
			node2:setPositionX(node1:getPositionX() + node1:getContentSize().width * node1:getScaleX() - controlGap1 + controlGap2 + gap)
		end
	end
end

function alignNodesOneByAllCenterX(node, nodeTable, gap)
	local gap = gap or 0
	if node ~= nil and #nodeTable >= 1 then
		local allWidth = node:getContentSize().width
		local node0 = nodeTable[1]
		local tmpWidth = 0
		for i, v in ipairs(nodeTable) do
			tmpWidth = tmpWidth + v:getContentSize().width * v:getScaleX()
		end
		local AnchorPoint0 = node0:getAnchorPoint().x
		node0:setPositionX((allWidth - tmpWidth) / 2 + node0:getContentSize().width * node0:getScaleX() * AnchorPoint0)
		for i, v in ipairs(nodeTable) do
			if i ~= 1 and v ~= nil then
				local node1 = nodeTable[i - 1]
				local node2 = v
				local AnchorPoint1 = node1:getAnchorPoint().x
				local AnchorPoint2 = node2:getAnchorPoint().x
				local controlGap1 = node1:getContentSize().width * node1:getScaleX() * AnchorPoint1
				local controlGap2 = node2:getContentSize().width * node2:getScaleX() * AnchorPoint2
				node2:setPositionX(node1:getPositionX() + node1:getContentSize().width * node1:getScaleX() - controlGap1 + controlGap2 + gap)
			end
		end
	end
end

function setExpectSize(param)
	local tarNode = param.node
	local tarWidth = param.width
	local tarHeight = param.height
	local orWidth = tarNode:getContentSize().width
	local orHeight = tarNode:getContentSize().height
	local scaleX = tarWidth / orWidth
	local scaleY = tarHeight / orHeight
	if scaleX > scaleY then
		tarNode:setScale(scaleX)
	else
		tarNode:setScale(scaleY)
	end
end

function safe_call(f, message)
	if type(f) == "function" then
		local err, ret = xpcall(f, function ()
			__G__TRACKBACK__(message or "error:")
		end)
		if err then
			return ret
		end
	else
		show_tip_label(common:getLanguageString("@qingqd"))
	end
end

function resetctrbtnimage(btn, image)
	btn:setBackgroundSpriteForState(display.newScale9Sprite(image), CCControlStateNormal)
	btn:setBackgroundSpriteForState(display.newScale9Sprite(image), CCControlStateHighlighted)
	btn:setBackgroundSpriteForState(display.newScale9Sprite(image), CCControlStateSelected)
	btn:setBackgroundSpriteForState(display.newScale9Sprite(image), CCControlStateDisabled)
end

function resetctrbtnString(btn, btnText)
	btn:setTitleForState(btnText, CCControlStateNormal)
	btn:setTitleForState(btnText, CCControlStateHighlighted)
	btn:setTitleForState(btnText, CCControlStateSelected)
	btn:setTitleForState(btnText, CCControlStateDisabled)
end

function resetbtn(btn, parentNode, zorder)
	local closepos = btn:convertToWorldSpace(ccp(btn:getContentSize().width / 2, btn:getContentSize().height / 2))
	btn:retain()
	btn:removeFromParentAndCleanup(false)
	btn:setPosition(parentNode:convertToNodeSpace(closepos))
	parentNode:addChild(btn, zorder)
	btn:release()
	btn:setTouchEnabled(true)
end

function isrexueproj()
	if device.platform == "android" and (PackName and PackName == "ewan" or TargetPlatForm and TargetPlatForm == "ewan") then
		return true
	end
	return false
end

function debug_print_attr(data, param)
	printf("===============HelloWorld=======================")
	for k, v in ipairs(data) do
		printf("{")
		for a, b in pairs(param) do
			if v[b] ~= nil then
				printf(string.format("  %s = %s", b, tostring(v[b])))
			end
		end
		printf("}")
	end
	printf("================end=====================")
end

if __G__TRACKBACK__ then
	function __G__TRACKBACK__(errorMessage)
		printf("----------------------------------------")
		printf("LUA ERROR: " .. tostring(errorMessage) .. "\n")
		printf(debug.traceback("", 2))
		printf("----------------------------------------")
		if device.platform == "windows" then
			CCMessageBox(errorMessage .. "       " .. debug.traceback("", 2), "Error")
		end
	end
end

local function onrelease(code, event)
	if code == cc.KeyCode.KEY_BACK or code == cc.KeyCode.KEY_BACKSPACE then
		device.showAlert("", "您是否要退出游戏?", {"确定", "取消"}, function(index)
			if index.buttonIndex == 1 then
				cc.Director:getInstance():endToLua()
			end
		end)
	end
end

function addbackevent(target)
	device.cancelAlert()
	local listener = cc.EventListenerKeyboard:create()
	listener:registerScriptHandler(onrelease, cc.Handler.EVENT_KEYBOARD_RELEASED)
	cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, target)
end

--[[系统时间]]
function GetSystemTime(...)
	local curTime = os.date("%H:%M", os.time())
	return curTime
end

function isCnChar(str)
	local len = string.len(str)
	local left = len
	local cnt = 0
	for i = 1, len do
		local curByte = string.byte(str, i)
		if curByte > 127 then
			dump(curByte)
			return true
		end
	end
	return false
end

--[[字符串是否含有非法字符]]
function hasIllegalChar(str)
	local illegalStr = ""
	local len = string.len(illegalStr)
	local curByte
	for i = 1, len do
		curByte = string.sub(str, i)
		printf(curByte)
		contain = string.find(str, curByte)
		printf(contain)
		if contain ~= nil then
			printf("hasIllegalChar")
			return true
		end
	end
	return false
end

function CtrlBtnGroupAsMenu(tab, func, tag)
	local index = #tab
	local _index = tag or 1
	local function btnStateChange(idx)
		for i, v in ipairs(tab) do
			if v ~= nil then
				if i == idx then
					v:setEnabled(false)
					v:setZOrder(index + 1)
				else
					v:setEnabled(true)
					if idx == index then
						v:setZOrder(i)
					elseif idx == 1 then
						v:setZOrder(index - i)
					end
				end
			end
		end
	end
	for i, v in ipairs(tab) do
		if v ~= nil then
			v:addHandleOfControlEvent(function ()
				if func ~= nil then
					func(i)
				end
				btnStateChange(i)
			end,
			CCControlEventTouchUpInside)
		end
	end
	btnStateChange(_index)
end

function setTTFLabelOutline(params)
	local g = params.label
	if not g then
		return
	end
	local outlineColor = params.outlineColor or display.COLOR_BLACK
	params.text = g:getString()
	params.size = params.size or g:getFontSize()
	params.color = outlineColor
	params.font = g:getFontName()
	params.align = g:getHorizontalAlignment()
	local y = g:getContentSize().height * 0.5
	g.setSuperString = g.setString
	if not params.shadowOffset then
		local shadowOffset = {
		{1, 0},
		{-1, 0},
		{0, -1},
		{0, 1}
		}
	end
	for i = 1, 4 do
		g["shadow" .. i] = ui.newTTFLabel(params)
		g["shadow" .. i]:realign(shadowOffset[i][1], y + shadowOffset[i][2])
		g:addChild(g["shadow" .. i], -1)
	end
	function g:setString(text)
		g:setSuperString(text)
		local y = g:getContentSize().height * 0.5
		for i = 1, 4 do
			g["shadow" .. i]:setString(text)
			g["shadow" .. i]:realign(shadowOffset[i][1], y + shadowOffset[i][2])
		end
	end
	function g:setOutlineColor(...)
		g.shadow1:setColor(...)
		g.shadow2:setColor(...)
		g.shadow3:setColor(...)
		g.shadow4:setColor(...)
	end
	return g
end

function timeFormat(timeAll)
	local basehour = 60 * 60
	local basemin  = 60
	local hour = math.floor(timeAll / basehour)
	local time = timeAll - hour * basehour
	local min  = math.floor(time / basemin)
	local time = time - basemin * min
	local sec  = math.floor(time)
	hour = hour < 10 and "0"..hour or hour
	min = min < 10 and "0"..min or min
	sec = sec < 10 and "0"..sec or sec
	local nowTimeStr = hour.."时"..min.."分"..sec.."秒"
	return nowTimeStr
end