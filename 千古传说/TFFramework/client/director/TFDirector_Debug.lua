--
-- Author: MiYu
-- Date: 2014-02-08 10:33:13
--
local moduleName 			= ...

function TFDirector:description(...)

	-- debug params
	TFDirector.bIsShowDebugInfo 		= nil
	TFDirector.bShowLuaMemmory			= nil
	TFDirector.bShowProfile				= nil	
	TFDirector.bShowLog					= nil
	TFDirector.testDebuger 				= nil
	TFDirector.tLuaProfile 				= nil

	-- debug functions
	TFDirector:initDebugEnv()
	TFDirector:initLUAProfile()
	TFDirector:hook()
	TFDirector:getName()
	TFDirector:showProfile(bVisible)
	TFDirector:showLuaMemmory(bVisible)
end

function TFDirector:initDebugEnv()
	print('TFDirector:initDebugEnv()')
	import(".TFDirector_KeyHook", moduleName)

	self.objKeyHookNode = TFPanel:create()
	me.Director:getNotificationNode():addChild(self.objKeyHookNode)
	self.objKeyHookNode:setKeyboardEnabled(true)

	self.objKeyHookNode:addMEListener(TFWIDGET_KEYUP, TFDirector.onKeyUpFunc)
	self.objKeyHookNode:addMEListener(TFWIDGET_KEYDOWN, TFDirector.onKeyDownFunc)

	TFDirector:registerKeyDown(123, {nGap = 500}, function() -- 'F12'
		if not TFDirector.EditorModel then
			TFDirector.bShowLuaMemmory = not TFDirector.bShowLuaMemmory
			TFDirector:showLuaMemmory(TFDirector.bShowLuaMemmory)
		end
	end)

--[[
	TFDirector:registerKeyDown(me.keys['BACK_SPACE'], {nGap = 500}, function() -- 'back'
		print("press BACK_SPACE")
	end)

	TFDirector:registerKeyDown(me.keys['TFNU'], {nGap = 500}, function() -- 'menu'
		print("press TFNU")
	end)
]]

	TFDirector:registerKeyDown(122, {nGap = 500}, function() -- 'F11'
		if not TFDirector.EditorModel then
			TFDirector.bShowProfile = not TFDirector.bShowProfile
			TFDirector:showProfile(TFDirector.bShowProfile)
		end
	end)

	TFDirector:registerKeyDown(120, {nGap = 500}, function() -- 'F9'
		if not TFDirector.EditorModel then
			if TFClientNet then
				TFClientNet:SetNetLogEnable(not TFClientNet.bShowLog)
				TFClientNet.bShowLog = not TFClientNet.bShowLog
			end
		end
	end)
	
	TFDirector:registerKeyDown(118, {nGap = 500}, function() -- 'F7'
		if not TFDirector.EditorModel then
			restartLuaEngine();
		end
	end)

	TFDirector:registerKeyUp(82, {bEnableCtrl = true, nGap = 500}, function() -- 'ctrl+r'
		TFDirector:closeSocket()
		TFResolution:setResolutionRect(1300, 780, 1300, 780)
		TFDirector:changeScene("LuaScript.scene.entry.EntryScene")
	end)

	TFDirector:registerKeyDown(110, {nGap = 500}, function() -- '.'
		TFDirector.bShowKey = not TFDirector.bShowKey 
	end)

	TFDirector:registerKeyDown(116, {nGap = 500}, function() -- 'F5'
		if TFDirector.EditorModel then
			TFDirector.bIsEditorDebug = not TFDirector.bIsEditorDebug
			if TFDirector.bIsEditorDebug then
				print("------------------------------------- open debug model ---------------------------------------")
			else
				print("------------------------------------- close debug model ---------------------------------------")
			end
			return 
		end
		local szFileName = "debugScript.lua"
		local szFullFilePath = me.FileUtils:fullPathForFilename(szFileName)
		if szFullFilePath ~= szFileName then
			dofile(szFullFilePath)
		end
	end)

	TFDirector:initLUAProfile()
end

function TFDirector:purgeDebug()
	TFDirector:removeTimer(self.nDebugUpdateTID)
	TFDirector:removeTimer(self.nDebugFrameTID)
	TFDirector:pause()
end

function TFDirector:printSceneTree()
	local scene = TFDirector:currentScene()
	if scene then
		local nIndex = 1
		objTreeDict = {}
		print("================================================================")
		print("")
		print("scene")
		local function travelNode(node, tb)
			if not node.getChildren then
				debug.setmetatable(node, CCNode)
			end
			local children = node:getChildren()
			if children then 
				local len = children:count()
				for i = 0, len - 1 do
					local obj = children:objectAtIndex(i)
					if type(obj) == 'userdata' and obj.getName then
						if obj:getDescription() == "TFPanel" then 
							local bbb = obj:isClippingEnabled()
							print(tb .. '├┄┄' .. obj:getName() .. '(' .. tolua.type(obj) .. ')' .. (obj:isVisible() and '+' or '-') .. '  [' .. nIndex .. ']' .. tostring(bbb))
						else 
							print(tb .. '├┄┄' .. obj:getName() .. '(' .. tolua.type(obj) .. ')' .. (obj:isVisible() and '+' or '-') .. '  [' .. nIndex .. ']')
						end
						objTreeDict[nIndex] = obj
						nIndex = nIndex + 1
						if obj.getChildren and obj:getChildren() and obj:getChildren():count() > 0 then
							travelNode(obj, tb .. '    ')
						end
					end
				end
			end
		end
		travelNode(scene, "")
		print("")
		print("Please Use : local obj = objTreeDict[nIndex] to oprand Object.")
		print("================================================================")
	end
end

function TFDirector:initLUAProfile()
	TFDirector.tLuaProfile = TFDirector.tLuaProfile or {}
	local tProfile = TFDirector.tLuaProfile
	tProfile.tCounters = {}
	tProfile.tNames = {}

	function TFDirector.hook()
		local func = debug.getinfo(2, 'f').func
		if tProfile.tNames[func] == nil then
			tProfile.tNames[func] = debug.getinfo(2, 'Sn')
			local szName = TFDirector.getName(func)
			if not szName then return end
			tProfile.tCounters[szName] = 1
			--print(tProfile.tNames[func], szName)
		else
			local szName = TFDirector.getName(func)
			if not szName then return end
			tProfile.tCounters[szName] = tProfile.tCounters[szName] + 1
		end
	end

	function TFDirector.getName(func)
		local tInfo = TFDirector.tLuaProfile.tNames[func]
		if tInfo and tInfo.what == 'C' then
			return tInfo.name
		end
		local szLoc = string.format("[%s:%s]", tInfo.short_src, tInfo.linedefined)
		if tInfo.namewhat ~= '' then 
			do return string.format("%s(%s)", szLoc, tInfo.name) end
		else
			return string.format('%s', szLoc)
		end
	end

end

function TFDirector:showProfile(bVisible)
	if bVisible then
		print("=============Start show Profile=============")
		debug.sethook(TFDirector.hook, 'c')
		TFDirector.tLuaProfile.nShowTid = TFDirector.tLuaProfile.nShowTid or TFDirector:addTimer(10000, -1, nil, function ( ... )
			
			local tInfos = {}
			for k, v in pairs(TFDirector.tLuaProfile.tCounters) do
				tInfos[#tInfos + 1] = {key = k, val = v}
			end
			table.sort(tInfos, function (a, b)
				return a.val > b.val
			end)
			for k, v in pairs(tInfos) do
				print(v.key, ':', v.val)
			end
		end)
		TFDirector:startTimer(TFDirector.tLuaProfile.nShowTid)
	else
		print("==============Stop show Profile=============")
		debug.sethook()
		TFDirector:stopTimer(TFDirector.tLuaProfile.nShowTid)
	end
end

function TFDirector:showLuaMemmory(bVisible)
	if bVisible then
		print("=============Start show LUA Memmory=============")
		TFDirector.nSlmTid1 = TFDirector.nSlmTid1 or TFDirector:addTimer(2000, -1, nil, function ( ... )
			print('[Memory] ', collectgarbage("count"), '\t\tat time:(' .. tostring(os.clock()) .. ')')
		end)
		TFDirector.nSlmTid2 = TFDirector.nSlmTid2 or TFDirector:addTimer(10000, -1, nil, function ( ... )
			collectgarbage("collect")
		end)

		TFDirector:startTimer(TFDirector.nSlmTid1)
		TFDirector:startTimer(TFDirector.nSlmTid2)
	else
		print("=============Stop show LUA Memmory=============")
		TFDirector:stopTimer(TFDirector.nSlmTid1)
		TFDirector:stopTimer(TFDirector.nSlmTid2)
	end
end

local function createDebugUI(panel)
	local SwitchNode = class('SwitchNode', function(size) return TFPanel:create({backColor=ccc3(0, 0, 0), size = size}) end)
	function SwitchNode:ctor(size, callback, isOn)
		self:setBackGroundColorOpacity(50)

		local onLabel = TFLabel:create()
		onLabel:setText('ON')
		onLabel:setPosition(ccp(size.width / 4, size.height / 2))
		self:addChild(onLabel, 1)

		local offLabel = TFLabel:create()
		offLabel:setText('OFF')
		offLabel:setPosition(ccp(size.width / 4 * 3, size.height / 2))
		self:addChild(offLabel, 1)

		size.width = size.width / 2
		self.block = TFPanel:create({backColor=ccc3(0, 255, 255), size = size})
		self.block:setOpacity(160)
		self:addChild(self.block)
		self:setTouchEnabled(true)

		self.isOn = (isOn ~= false)
		self.curState = self.isOn
		self.canTouch = true
		self:addMEListener(TFWIDGET_CLICK, function(sender)
			if self.canTouch then 
				self.canTouch = false
				self:changeState()
			end
		end)
		if not self.isOn then 
			self.block:setPosition(ccp(size.width, 0))
		end
		self.callback = callback
		if self.callback then self.callback(self.isOn) end
	end

	function SwitchNode:work()
		if self.curState ~= self.isOn then 
			self.curState = self.isOn
			local seek = self:getSize().width / 2
			local xBy = 0
			if self.isOn then 
				xBy = -seek
			else 
				xBy = seek
			end
			local tween = {
				target = self.block,
				{
					duration = 0.25,
					xBy = xBy,
					yBy = 0,
				},
				onComplete = function()
					self.canTouch = true
				end
			}
			TFDirector:toTween(tween)
			if self.callback then self.callback(self.isOn) end
		end
	end

	function SwitchNode:changeState()
		self.isOn = not self.isOn
		self:work()
	end

	function SwitchNode:on()
		self.isOn = true
		self:work()
	end

	function SwitchNode:off()
		self.isOn = false
		self:work()
	end

	local nWidth = 0

	local isWriteFile = CCLog_isDebugFileEnabled() == 1 or CCLog_isDebugFileEnabled() == 3
	local txtSwitch = SwitchNode:new(ccs(70, 25), function (isOn)
		if isOn then 
			CCLog_setDebugFileEnabled(1) 
			print("Open write log in file.")
		else 
			CCLog_setDebugFileDisabled(1)
			print("Close write log in file.")
		end
	end, isWriteFile)
	local txtLabel = TFLabel:create()
	txtLabel:setText("文件写入:")
	txtLabel:setAnchorPoint(ccp(0, 0))
	txtLabel:addChild(txtSwitch)
	txtSwitch:setPosition(ccp(txtLabel:getSize().width + 2, -4))
	panel:addChild(txtLabel, 2)
	txtLabel:setPosition(ccp(nWidth + 5, 8))
	nWidth = nWidth + txtLabel:getSize().width + txtSwitch:getSize().width + 5

	local isWriteNSLog = CCLog_isDebugFileEnabled() == 2 or CCLog_isDebugFileEnabled() == 3
	local NSSwitch = SwitchNode:new(ccs(70, 25), function (isOn)
		if isOn then 
			CCLog_setDebugFileEnabled(2) 
			print("Open write log in NSLog.")
		else 
			CCLog_setDebugFileDisabled(2)
			print("Close write log in NSLog.")
		end
	end, isWriteNSLog)
	local nsLabel = TFLabel:create()
	nsLabel:setText("NSLog:")
	nsLabel:setAnchorPoint(ccp(0, 0))
	nsLabel:addChild(NSSwitch)
	NSSwitch:setPosition(ccp(nsLabel:getSize().width + 2, -4))
	panel:addChild(nsLabel, 2)
	nsLabel:setPosition(ccp(nWidth + 5, 8))
	nWidth = nWidth + nsLabel:getSize().width + NSSwitch:getSize().width + 5

	local netSwitch = SwitchNode:new(ccs(70, 25), function (isOn)
		if isOn then 
			TFDirector:getNetWork():SetNetLogEnable(true)
			print("Open log for Network.")
		else 
			TFDirector:getNetWork():SetNetLogEnable(false)
			print("Close log for Network.")
		end
	end, false)
	local netLabel = TFLabel:create()
	netLabel:setText("NetLog:")
	netLabel:setAnchorPoint(ccp(0, 0))
	netLabel:addChild(netSwitch)
	netSwitch:setPosition(ccp(netLabel:getSize().width + 2, -4))
	panel:addChild(netLabel, 2)
	netLabel:setPosition(ccp(nWidth + 5, 8))
end

function TFDirector:createDebugerLayer(objScene)
	if self.testDebuger then
	else
        print("Debug Panel inited...")
		local nFPS = 0
		local testDebuger = {}
		self.testDebuger = testDebuger
		testDebuger.debugPanel = TFDirector:createMEModule("TFFramework.res.uiConfig.Debug")
		testDebuger.debugPanel:setVisible(false)
		createDebugUI(testDebuger.debugPanel)

		local function __open()
			testDebuger.debugPanel:setVisible(true)
			me.Director:setDebugModel(1)
			TFDirector:startTimer(self.nDebugFrameTID)
			TFDirector:startTimer(self.nDebugUpdateTID)
		end

		local function __close()
			testDebuger.debugPanel:setVisible(false)
			me.Director:setDebugModel(0)
			TFDirector:stopTimer(self.nDebugFrameTID)
			TFDirector:stopTimer(self.nDebugUpdateTID)
		end

		testDebuger.exitBtn = TFDirector:getChildByPath(testDebuger.debugPanel, "exitBtn")
		testDebuger.exitBtn:addMEListener(TFWIDGET_CLICK, __close)

		testDebuger.fpsLabel 			= TFDirector:getChildByPath(testDebuger.debugPanel, "fpsLabel")
		testDebuger.textureCacheLabel 	= TFDirector:getChildByPath(testDebuger.debugPanel, "textureCacheLabel")
		testDebuger.textureCountLabel 	= TFDirector:getChildByPath(testDebuger.debugPanel, "textureCountLabel")
		testDebuger.batchCountLabel 	= TFDirector:getChildByPath(testDebuger.debugPanel, "batchCountLabel")
		testDebuger.imgCountLabel 		= TFDirector:getChildByPath(testDebuger.debugPanel, "imgCountLabel")
		testDebuger.labelCountLabel 	= TFDirector:getChildByPath(testDebuger.debugPanel, "labelCountLabel")
		testDebuger.armatureCountLabel 	= TFDirector:getChildByPath(testDebuger.debugPanel, "ArmatureCountLabel")
		testDebuger.boneCountLabel 		= TFDirector:getChildByPath(testDebuger.debugPanel, "BoneCountLabel")
		testDebuger.netRecvLabel 		= TFDirector:getChildByPath(testDebuger.debugPanel, "netRecvLabel")
		testDebuger.netSendLabel 		= TFDirector:getChildByPath(testDebuger.debugPanel, "netSendLabel")
		testDebuger.partCountLabel 		= TFDirector:getChildByPath(testDebuger.debugPanel, "particleCountLabel")
		testDebuger.partNumLabel 		= TFDirector:getChildByPath(testDebuger.debugPanel, "particleNumLabel")
		testDebuger.memCountLabel 		= TFDirector:getChildByPath(testDebuger.debugPanel, "memLabel")
		testDebuger.luaMemLabel 		= TFDirector:getChildByPath(testDebuger.debugPanel, "luaMemLabel")

		testDebuger.touchPanel = TFPanel:create()

		testDebuger.touchPanel:setSize(CCSizeMake(100, 100))
		testDebuger.touchPanel:setTouchEnabled(true)
		testDebuger.touchPanel:setDoubleClickEnabled(true)
		testDebuger.touchPanel:setDoubleClickGap(0.2)
		testDebuger.touchPanel:setSwallowTouch(false)
		testDebuger.touchPanel:addMEListener(TFWIDGET_DOUBLECLICK, __open)
		testDebuger.touchPanel:addChild(testDebuger.debugPanel)

		local node = me.Director:getNotificationNode()
		if node then 
			node:addChild(testDebuger.touchPanel)
		else 
			me.Director:setNotificationNode(testDebuger.touchPanel)	
		end

		testDebuger.touchPanel:addMEListener(TFWIDGET_ENTER, function() print("debug enter") end)
		testDebuger.touchPanel:addMEListener(TFWIDGET_CLEANUP, function() print("debug clean") end)
		testDebuger.touchPanel:addMEListener(TFWIDGET_EXIT, function() print("debug exit") end)

		local function updateNetFlow()
			local insTance  = TFDirector:getNetWorkInstance()
			nRecvFlow = insTance:getRecvFlow()
			nSendFlow = insTance:getSendFlow()
			self.testDebuger.netRecvLabel:setText('RecvFlow: ' .. nRecvFlow .. ' bytes')
			self.testDebuger.netSendLabel:setText('SendFlow: ' .. nSendFlow .. ' bytes')
		end

		local function checkStringNum(str)
			if type(str) == 'string' and (str[#str] == 'K' or str[#str] == 'k') then 
				str = str[{1, #str-1}]
			end
			return str
		end

		local function updateCounters()
			local info = loadstring(me.Director:getDebugInfo())()
			if not info then return end
			local imageCnt = info[1]
			local labelCnt = info[2]
			local batchCnt = info[3]
			local armatCnt = info[4]
			local boneCnt = info[5]
			local drawCnt = info[6]
			local vertCnt = info[7]
			local mpfCnt = info[8]
			local partCnt = info[9]
			local partNum = info[10]

			local allMem = checkStringNum(TFDeviceInfo.getTotalMem())
			local freeMem = checkStringNum(TFDeviceInfo.getFreeMem())

			testDebuger.batchCountLabel 	:setText('Batch Count: ' .. batchCnt)
			testDebuger.imgCountLabel 		:setText('Image Count: ' .. (imageCnt - 9))
			testDebuger.labelCountLabel 	:setText('Label Count: ' .. (labelCnt - 15))
			testDebuger.armatureCountLabel 	:setText('Armature Count: ' .. armatCnt)
			testDebuger.boneCountLabel 		:setText('Bone Count: ' .. boneCnt)

			testDebuger.fpsLabel			:setText(string.format('FPS: %.1f/%.3f | DRW: %d | VERT: %d', nFPS, mpfCnt, drawCnt, vertCnt))
			testDebuger.partCountLabel 		:setText(string.format('Particle Count: %d', partCnt))
			testDebuger.partNumLabel 		:setText(string.format('Particle Num: %d', partNum))
			testDebuger.memCountLabel 		:setText(string.format('Device Mem: %dM/%dM (free/tot)', freeMem/1024, allMem/1024))
			testDebuger.luaMemLabel 		:setText(string.format('Lua Mem: %.2fM', collectgarbage("count")/1024))	
		end

		local function updateTexture()
			local tmap = me.TextureCache:getTexturesMap()
			local nLen = tmap:size()
			local keys = tmap:keys()

			local nUsed = 0
			local nMem = 0
			local nUsedMem = 0

			for i = 0, nLen - 1 do 
				local name = keys:at(i)
				local tex = tmap:objectForKey(name:getCString())
				local bpp = tex:bitsPerPixelForFormat()
        		local bytes = tex:getPixelsWide() * tex:getPixelsHigh() * bpp / 8 / 1024
        		nMem = nMem + bytes
        		if tex:retainCount() > 1 then 
        			nUsed = nUsed + 1 
        			nUsedMem = nUsedMem + bytes
        		end
			end

			testDebuger.textureCacheLabel:setText(string.format("TextureCache: %.2fM / %.2fM", nUsedMem/1024, nMem/1024))
			testDebuger.textureCountLabel:setText(string.format('TextureCount: %d/%d   Use Rate: %d%%', nUsed, nLen, nUsed/nLen*100))
		end

		local nFrameRate = 0
		self.nDebugUpdateTID = TFDirector:addTimer(1000, -1, nil, function(dt)
			if testDebuger.debugPanel:isVisible() then 
				updateNetFlow()
				updateCounters()
				updateTexture()
			end
		end)

		local nFrameRate = 0
		local nFrameDelta = 0
		self.nDebugFrameTID = TFDirector:addTimer(0, -1, nil, function(dt)
			nFrameRate = nFrameRate + 1
			nFrameDelta = nFrameDelta + dt
			if nFrameDelta > 0.2 then 
				nFPS = nFrameRate / nFrameDelta
				nFrameRate = 0
				nFrameDelta = 0
			end
		end)

		updateNetFlow()
		updateCounters()
		updateTexture()

		__close()
	end
end

function TFDirector:writeToDebugerLayer(...)
end

function TFDirector:startRemoteDebug(host)
	print('Try to start remote debug...')
	host = host or 'localhost'
	return meStartDebug(host)
end

return TFDirector