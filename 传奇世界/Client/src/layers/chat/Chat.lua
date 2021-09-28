local ChatView = class("ChatView", function() return cc.Layer:create() end)--require ("src/TabViewLayer"))
local commConst = require("src/config/CommDef")
local personal = 1
local teamup = 2
local faction = 3
local world = 4
local trumpet = 5
local system = 6
local area = 7
local allChannel = 11
local tag_slideChatAction = 789
local comPath = "res/chat/"
local faceW = 70
local bg_size_width_normal = 536
local bg_size_width_private_chat = 826
local scrollView_height_offset_normal = 100
local scrollView_height_offset_private = 20 + (501 - 461)
local scrollView_posY_normal = 5
local scrollView_posY_private = 30 + 22
local rightBg_normalWidth, rightBg_expandedWidth = 375, 668
local arrow_btn_posX_normal, arrow_btn_posX_expanded = 537, 828
local size_editeBg_normal, size_editeBg_expanded = cc.size(270, 58), cc.size(512 + 73 - 15, 58)
local pos_x_voiceSet_btn_normal, pos_x_voiceSet_btn_expanded = 485, 512 + 288 - 25
local pos_x_more_btn_normal, pos_x_more_btn_expanded = 395, 500 + 352 - 161
local pos_x_menu_send_normal, pos_x_menu_send_expanded = 480, 520 + 266 - 18
--local size_microphone_normal, size_microphone_expanded = cc.size(310, 57), cc.size(610, 57)
local size_chatEditCtrl_normal, size_chatEditCtrl_expanded = cc.size(260, 34), cc.size(502 + 73 - 15, 34)

local channelToIdx = { }
    channelToIdx[allChannel] = 1
    channelToIdx[world] = 2
    channelToIdx[area] = 3
    channelToIdx[teamup] = 4
    channelToIdx[faction] = 5
    channelToIdx[system] = 6
    channelToIdx[personal] = 7

local idxToChannel = { }
    idxToChannel[1] = allChannel
    idxToChannel[2] = world
    idxToChannel[3] = area
    idxToChannel[4] = teamup
    idxToChannel[5] = faction
    idxToChannel[6] = system
    idxToChannel[7] = personal

local function editBoxTextEventHandle(strEventName, pSender)			
	if strEventName == "began" then

	elseif strEventName == "ended" then

	elseif strEventName == "return" then

	elseif strEventName == "changed" then
		
	end
end

local channelIdClient2Server = function(id)
	if id == trumpet then
		return commConst.Channel_ID_Bugle
	elseif id == world then
		return commConst.Channel_ID_World
	elseif id == faction then
		return commConst.Channel_ID_Faction
	elseif id == teamup then
		return commConst.Channel_ID_Team
	elseif id == personal then
		return commConst.Channel_ID_Privacy
	elseif id == area then
		return commConst.Channel_ID_Area
	end
end

function ChatView:ctor(index, roleData, tabIndex)
    local msgids = {}
	require("src/MsgHandler").new(self, msgids)

	self.linkTab = {}

	local addSprite = createSprite
	local addLabel = createLabel
	
	local bg = createScale9Sprite(self, "res/common/scalable/12.png", cc.p(0, display.cy), cc.size(bg_size_width_normal, display.height), cc.p(0, 0.5))--createSprite(self, "res/chat/bg2.png", cc.p(0, display.cy), cc.p(0, 0.5))
	self.bg = bg

	local leftBg = createScale9Sprite(bg, "res/common/scalable/13.png", cc.p(20, 100), cc.size(110, bg:getContentSize().height-100-20), cc.p(0, 0))
	self.leftBg = leftBg
	local rightBg = createScale9Sprite(bg, "res/common/scalable/13.png", cc.p(140, 100), cc.size(rightBg_normalWidth, bg:getContentSize().height-100-20), cc.p(0, 0))
	self.rightBg = rightBg

	--self.bg:setOpacity(215)
	if g_scrSize.height > 640 then
		createSprite(bg, "res/mainui/ipad_addbg_top.png", cc.p(bg:getContentSize().width, bg:getContentSize().height), cc.p(1, 0))
		local bottomBg = createSprite(bg, "res/mainui/ipad_addbg_top.png", cc.p(bg:getContentSize().width, 0), cc.p(1, 1))
		bottomBg:setFlippedY(true)
	end

    --关闭按钮处理
	local closeBtn = createMenuItem(bg, "res/chat/1.png", cc.p(arrow_btn_posX_normal, self.bg:getContentSize().height/2), function() self:hide(true) end, 10000)
    self.closeBtn = closeBtn
    local  listennerClose = cc.EventListenerTouchOneByOne:create()
	listennerClose:setSwallowTouches(false)
    listennerClose:registerScriptHandler(function(touch, event)
            local location = self.bg:getParent():convertTouchToNodeSpace(touch)
            if cc.rectContainsPoint(self.bg:getBoundingBox(), cc.p(location.x, location.y)) then
                self.moveBeginX = location.x
                self.moveBeginTime = os.time()
                return true
       		else
                if self.isShow then
                    self:hide(true)
                end
                self.moveBeginX = nil;
                self.moveBeginTime = nil;
       			return false
       		end
        end,cc.Handler.EVENT_TOUCH_BEGAN )
    listennerClose:registerScriptHandler(function(touch, event)
    	    local location = self.bg:getParent():convertTouchToNodeSpace(touch)
            if self.moveBeginX ~= nil and self.moveBeginTime ~= nil then
                if self.moveBeginX - location.x > 200 and os.time() - self.moveBeginTime < 1 then
                    self:hide(true)

                    -- if self.chatTutoSprite then
                    -- 	removeFromParent(self.chatTutoSprite)
                    -- 	self.chatTutoSprite = nil
                    -- end
                    setLocalRecord("chatTuto", true)
                end
            end
        end,cc.Handler.EVENT_TOUCH_MOVED )
    listennerClose:registerScriptHandler(function(touch, event)
     		self.moveBeginX = nil;
            self.moveBeginTime = nil;
        end,cc.Handler.EVENT_TOUCH_ENDED)

    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listennerClose, closeBtn)

	local baseNode = cc.Node:create()
	bg:addChild(baseNode)
	self.baseNode = baseNode

	--local buttonBg4 = createSprite(baseNode, "res/common/bg/buttonBg4.png", cc.p(15, 100), cc.p(0, 0))
    --buttonBg4:setScaleY(1.15);
	--local bg23 = createSprite(baseNode, "res/common/bg/bg23.png", cc.p(135, 100), cc.p(0, 0))
    --bg23:setScaleY(1.15);
	
	self.titles = {
						game.getStrByKey("chat_personal"),
						game.getStrByKey("chat_teamup"),
						game.getStrByKey("chat_faction"),
						game.getStrByKey("chat_world"),
						game.getStrByKey("chat_trumpet"),
						game.getStrByKey("chat_system"),
						game.getStrByKey("chat_area"),
						--game.getStrByKey("chat_send")
					}
	self.colors = {
						MColor.lable_yellow,
						MColor.green,
						MColor.blue,
						MColor.yellow,
						MColor.orange,
						MColor.purple,
						MColor.orange,
						MColor.red,
						MColor.yellow_gray
					}

    --创建左侧按钮
    if G_CHAT_INFO.unReadPrivateRecord ~= nil and G_CHAT_INFO.unReadPrivateRecord > 0 then
        self.currSendChannel = personal
        self.currDisChannel = personal
    else
        self.currSendChannel = area
        self.currDisChannel = allChannel
    end
    
    self:createSelectNode()
	

	--语音文字切换
	-- self.voiceSpr = addSprite(baseNode,"res/chat/voice.png",cc.p(55,53))
	--self.voiceSpr = addSprite(baseNode,"res/chat/voice.png",cc.p(10,45),cc.p(0,0.5))
	--self.wordSpr = addSprite(baseNode,"res/chat/word.png",cc.p(10,50),cc.p(0,0.5))
	--self.voiceBg = addSprite(baseNode,"res/chat/voiceBg1.png",cc.p(315,53))
	--addLabel(self.voiceBg, "按住说话",cc.p(213.5,26.5), cc.p(0.5,0.5),19,true)

	local bagCallBack = function(str)
		local text = self.chatEditCtrl:getText()
		local text = text..str
		self.chatEditCtrl:setText(text)
	end

	--self.chatEditCtrl = G_CHAT_INFO.chatEditCtrl
	local editeBg = createScale9Sprite(baseNode, "res/common/scalable/input_1.png", cc.p(80, 45), size_editeBg_normal, cc.p(0, 0.5))
	if not self.chatEditCtrl then
		self.chatEditCtrl = createEditBox(editeBg, nil ,getCenterPos(editeBg), size_chatEditCtrl_normal, MColor.white)
		self.chatEditCtrl:setAnchorPoint(cc.p(0.5, 0.5))
		self.chatEditCtrl:setPlaceHolder(game.getStrByKey("chat_edit_default"))
	    --self.chatEditCtrl:setPlaceholderFontColor(MColor.gray)
	    self.chatEditCtrl:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    end
    --self.chatEditCtrl:registerScriptEditBoxHandler(editBoxTextEventHandle)
    self.editeBg = editeBg

	self.microphone = require("src/layers/chat/Microphone").new(baseNode,cc.p(260,45),self)

	--self.voiceNode = require("src/layers/chat/Voice").new(baseNode,self)
	--self.bg:addChild(self.voiceNode,100)

	--addLabel(self.micbtn, game.getStrByKey("chat_pressToSpeak"),cc.p(0,0), cc.p(0.5,0.5),19,true)

	-- self.inputMode = 2
 --    self:changeInputStatus()

    local choseFaceCallBack = function(index)
    	local str
    	log("index = "..tostring(index))
    	if index == 1 then
    		local isCanSend = getConfigItemByKey("MapInfo", "q_map_id", G_MAINSCENE.mapId, "q_transmit")
    		if isCanSend and isCanSend == 0 then
	    		--local mapName = require("src/layers/buff/ChangeLineLayer"):getMapName()
	    		local pos = cc.p(G_MAINSCENE.map_layer:space2Tile(cc.p(G_ROLE_MAIN:getPosition())))
	    		local line = require("src/layers/role/RoleStruct"):getAttr(PLAYER_LINE)
	    		--str = self.chatEditCtrl:getText()..string.format(game.getStrByKey("my_map_pos"), line, mapName, pos.x, pos.y)
	    		--str = self.chatEditCtrl:getText().."^a"..string.format(game.getStrByKey("my_map_pos"), mapName, line, pos.x, pos.y).."^"
	    		str = self.chatEditCtrl:getText().."^a("..G_MAINSCENE.mapId..","..line..","..pos.x..","..pos.y..")^"
	    	else
	    		TIPS({type = 1, str = game.getStrByKey("my_map_pos_unable_tip")})
	    	end
    	else
    		str = self.chatEditCtrl:getText().."^i("..index..")^"
    	end
    	
		self.chatEditCtrl:setText(str)
	end

	local choseEquipmentCallBack = function(packId, grid)
		--dump(packId)
		--dump(grid)
		local MPackStruct = require "src/layers/bag/PackStruct"
		local MpropOp = require "src/config/propOp"
		local protoId = MPackStruct.protoIdFromGird(grid)
		local globalGirdId = MPackStruct.girdIdFromGird(grid)
		local isSpecial = MPackStruct.isSpecialFromGird(grid)
		local name = MpropOp.name(protoId)
		local qualityId = MpropOp.quality(protoId)

		--local dataStr = "^l("..qualityId.."~"..name.."~"..tostring(isSpecial).."~"..tostring(protoId).."~"..tostring(posIndex).."~"..tostring(userInfo.currRoleStaticId).."~"..os.time().."~"..packId..")^"
		local str = "<"..name..">"
		--self.linkTab[str] = "^l("..qualityId.."~"..name.."~"..tostring(isSpecial).."~"..tostring(protoId).."~"..tostring(globalGirdId).."~"..tostring(userInfo.currRoleStaticId).."~"..os.time().."~"..packId..")^"
		local record = {name=str, linkInfo="^l("..qualityId.."~"..name.."~"..tostring(isSpecial).."~"..tostring(protoId).."~"..tostring(globalGirdId).."~"..tostring(userInfo.currRoleStaticId).."~"..os.time().."~"..packId..")^"}
		table.insert(self.linkTab, #self.linkTab+1, record)

		local text = self.chatEditCtrl:getText()
		local text = text..str
		self.chatEditCtrl:setText(text)
	end

	local choseShortCallBack = function(str)
    	local text = self.chatEditCtrl:getText()
		local text = text..str
		self.chatEditCtrl:setText(text)
	end

	local choseTrumpetCallBack = function()
		self.chatEditCtrl:setText(game.getStrByKey("chat_trumpet_tag"))
	end
	self.choseTrumpetCallBack = choseTrumpetCallBack

    --表情
	local openFace = function()
		--self:showFacePanel()
		local layer = require("src/layers/chat/ChatFace").new(choseFaceCallBack)
		getRunScene():addChild(layer, 200)
		layer:setPosition(self.btnFace:convertToWorldSpace(getCenterPos(self.btnFace)))
	end
	--self.btnFace = createMenuItem(baseNode,"res/chat/face.png",cc.p(390,45),openFace)

	local function moreBtnFunc()
		local param = {}
		param.choseFaceCallBack = choseFaceCallBack
		param.choseEquipmentCallBack = choseEquipmentCallBack
		param.choseShortCallBack = choseShortCallBack
		param.choseTrumpetCallBack = choseTrumpetCallBack
		
		local layer = require("src/layers/chat/ChatMoreLayer").new(param)
		getRunScene():addChild(layer, 200)
		layer:setPosition(self.moreBtn:convertToWorldSpace(getCenterPos(self.moreBtn)))
	end
	local moreBtn = createMenuItem(baseNode, "res/chat/more.png", cc.p(pos_x_more_btn_normal, 45), moreBtnFunc)
	self.moreBtn = moreBtn

    --语音设置按钮
    local function voiceSetFunc()		       
        --package.loaded["src/layers/chat/ChatVoiceSetLayer"] = nil
        local layer = require("src/layers/chat/ChatVoiceSetLayer").new(param)
		getRunScene():addChild(layer, 200)
		--layer:setPosition(self.voiceSetBtn:convertToWorldSpace(getCenterPos(self.voiceSetBtn)))
		layer:setPosition(cc.p(560, display.height/2-520/2))
	end
	local voiceSetBtn = createMenuItem(baseNode, "res/chat/voiceset.png", cc.p(pos_x_voiceSet_btn_normal, 45), voiceSetFunc)
	self.voiceSetBtn = voiceSetBtn

    --键盘按钮
    local function keyboardFunc()		
        self:setInputShowType(1)
	end
	local keyboardBtn = createMenuItem(baseNode, "res/chat/keyboard.png", cc.p(40, 45), keyboardFunc)
	self.keyboardBtn = keyboardBtn

    --话筒按钮
    local function micorFunc()		
        self:setInputShowType(2)
	end
	local microBtn = createMenuItem(baseNode, "res/chat/voice.png", cc.p(40, 45), micorFunc)
	self.microBtn = microBtn

    --不能发言提示
    self.cannotTalkTips = createLabel(baseNode, "",cc.p(40,45),cc.p(0,0.5), 22,nil,nil,nil,MColor.lable_black)

	--发送
	local sendFunc = function(tag,sender)
		if G_CONTROL:isFuncOn( GAME_SWITCH_ID_CHAT ) == false then
			TIPS({type = 1, str = game.getStrByKey("chat_system_close_tip")})
        	return
		end

		self.isUpdateScrollView = true

		local text = self.chatEditCtrl:getText()
        if text == nil then
            return
        end

        log("utf8len = "..string.utf8len(text))
        if string.utf8len(text) >
            (string.find(text, game.getStrByKey("chat_trumpet_tag")) == 1 and string.utf8len(game.getStrByKey("chat_trumpet_tag")) or 0)    --如果是传音号角，那么显示的最大字数是len("[传音号角]:") + 40
            + 40
            then
        	TIPS({type = 1, str = game.getStrByKey("chat_short_tip_long")})
        	return
        end
        
        ------------------------Debug-------------------------------------
        -- 转换win路径符号为linux路径符号
        local transferPath = function(oldStr, isSpt)
            local tmpStr = oldStr;
            if isSpt then
                if not string.find(oldStr, "%.") then
                    tmpStr = tmpStr .. ".lua";
                end
            end
            if not cc.FileUtils:getInstance():isFileExist(tmpStr) then
                return oldStr, false;
            end

            local str = "";
            for i=1, #oldStr, 1 do
                local c = string.sub(oldStr, i, i);
                if c == "\\" then
                    c = "/";
                end
                str = str .. c;
            end
            return str, true;
        end
        -- reloadspt src\layers\rewardTask\rewardTaskViewLayer or reloadspt src/layers/rewardTask/rewardTaskViewLayer
        -- reloadtex res\common\table\top10.png or res/common/table/top10.png
        if string.sub(text, 1, 9) == "reloadspt" then   -- 重载脚本
            local scriptPath, isExit = transferPath( string.sub(text, 11), true );
            if isExit then
                package.loaded[scriptPath] = nil;
                require(scriptPath);
                print("\n Reload script success.\n");
            else
                print("\n Script not exit. [" .. scriptPath .. "]\n");
            end
            return;
        elseif string.sub(text, 1, 9) == "reloadtex" then   -- 重载图片
            local texPath, isExit = transferPath( string.sub(text, 11), false );

            if isExit then
                TextureCache:reloadTexture(texPath);
                print("\n Reload texture success.\n");
            else
                print("\n Texture not exit. [" .. texPath .. "]\n");
            end
            return
        elseif string.sub(text, 1, 8) == "#showfps" then
        	local subShowFps = string.sub(text, 10)
        	if subShowFps ~= nil and string.len(subShowFps) > 0 then
        		cc.Director:getInstance():setDisplayStats(true)
        		local nShowType = tonumber(subShowFps)
        		if nShowType ~= nil then
        			cc.Director:getInstance():setDisplayType(nShowType)
        		end
        	else
        		local curShowFps = cc.Director:getInstance():isDisplayStats()
        		local newShowFps = not curShowFps
        		cc.Director:getInstance():setDisplayStats(newShowFps)
        	end
	        return
	    elseif string.sub(text, 1, 9) == "#clearnet" then
	        LuaSocket:getInstance():clearNetBytes()
            TIPS({type=1,str="clearnet"})
            return
	    elseif string.sub(text, 1, 10) == "#setbright" then
        	local subShowFps = string.sub(text, 12)
        	if subShowFps ~= nil then
        		local nShowType = tonumber(subShowFps)
        		if nShowType ~= nil then
        			cc.Device:setBrightness(nShowType)
        			TIPS({type=1,str="setBrightness"})
        		end
        	end
	        return
	    elseif string.sub(text, 1, 10) == "#getbright" then
        	local bright = cc.Device:getBrightness()
        	TIPS({type=1,str="getBrightness:" .. bright})
	        return
	    elseif string.sub(text, 1, 10) == "#setkeepon" then
        	local subShowFps = string.sub(text, 12)
        	if subShowFps == "0" then
        		cc.Device:setKeepScreenOn(false)
        		TIPS({type=1,str="setKeepScreenOn fasle"})
        	else
        		cc.Device:setKeepScreenOn(true)
        		TIPS({type=1,str="setKeepScreenOn true"})
        	end
	        return
	    elseif string.sub(text, 1, 9) == "#cleartex" then
	        cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()
            cc.Director:getInstance():getTextureCache():removeUnusedTextures(true)
            cc.SpriteFrameCache:getInstance():removePlistCache()
            TIPS({type=1,str="cleartex"})
            return
        elseif string.sub(text, 1, 10) == "#setmaxtex" then
        	local maxtex = string.sub(text, 12)
        	if maxtex ~= nil then
        		local nMaxTex = tonumber(maxtex)
        		if nMaxTex ~= nil then
        			cc.Director:getInstance():getTextureCache():setMaxCachedTextureMB(nMaxTex)
        		end
        	end
            TIPS({type=1,str="setmaxtex"})
            return
		elseif string.sub(text, 1, 8) == "#showtex" then
	        local cparam = string.sub(text, 10)
			if cparam == nil then
				return
			end

			local testSprite = cc.Director:getInstance():getRunningScene():getChildByName("TestTex")
			if testSprite == nil then
				testSprite = cc.Sprite:create()
				testSprite:setAnchorPoint(cc.p(0,0))
				testSprite:setPosition(cc.p(0,60))
				testSprite:setName("TestTex")
				cc.Director:getInstance():getRunningScene():addChild(testSprite, 60000)
			end

			if cparam == "" then
				testSprite:removeFromParent()
				return
			end

			local texture = cc.Director:getInstance():getTextureCache():getTextureForKey(cparam)
			if texture then
				testSprite:setTexture(texture)

				local texs = texture:getContentSize()
				testSprite:setTextureRect(cc.rect(0,0,texs.width,texs.height))

				if texs.width > g_scrSize.width or texs.height > g_scrSize.height - 60 then
					local scale = math.min(g_scrSize.width / texs.width, (g_scrSize.height - 60) / texs.height)
					testSprite:setScale(scale)
				else
					testSprite:setScale(1)
				end
			end

            TIPS({type=1,str="showtex"})
            return
	    elseif string.sub(text, 1, 15) == "#closechecknode" then
	        cc.Node:setCheckAllocationNode(false)
	        TIPS({type=1,str="Node检测关闭"})
	        return
	    elseif string.sub(text, 1, 15) == "#showmonsterpos" then
	        MapView:setMaxLockNum(6)
	        TIPS({type=1,str="showmonsterpos"})
	        return
	    elseif string.sub(text, 1, 12) == "#showversion" then
	        TIPS({type=1,str="内部号：3"})
	        return
	    elseif string.sub(text, 1, 12) == "#setroleshow" then
	    	if G_ROLE_MAIN ~= nil then
	    		local nShowNum = tonumber(string.sub(text, 14))
	    		if nShowNum ~= nil then
		    		G_ROLE_MAIN:setVirtualOpacityNum(nShowNum)
		    		G_ROLE_MAIN:setOpacity(G_ROLE_MAIN:getOpacity())
		    	end
	    	end
	        TIPS({type=1,str="setroleshow"})
	        return
        elseif string.sub(text, 1, 10) == "#playmusic" then
            local q_music = string.sub(text, 12)
	    	if q_music ~= nil then
		    	AudioEnginer.playMusic("sounds/mapMusic/"..q_music..".mp3",true)
		    end
            return
        elseif string.sub(text, 1, 10) == "#openid" then
            if sdkGetOpenId then
            	TIPS({type=1,str="OpenId:" .. sdkGetOpenId()})
            end
        	return
        elseif string.sub(text, 1, 7) == "#msglog" then
	        local netSim = require("src/net/NetSimulation")
            if netSim.OpenBtn then
   	            __GotoTarget({ru = "a171"} )
   	        end
	        return
        elseif string.sub(text, 1, 9) == "#debuglog" then
	        _G_NO_DEBUG = false
	        return
	    elseif string.sub(text, 1, 12) == "#startrecord" then
	    	print("startrecord")
	    	startRecording()
	        return
        elseif string.sub(text, 1, 11) == "#stoprecord" then
	    	print("stoprecord")
	    	function callbackTab.showDiscardRecordingBtn()
			    print("callbackTab.showDiscardRecordingBtn()")
			    TIPS({type=1,str="停止录像回调"})
			end
			stopRecording()
	        return
	    elseif string.sub(text, 1, 11) == "#showrecord" then
	    	print("showrecord")
	    	displayRecordingContent()
	        return
        end

        ---------------------------------------------------------------------
        if isWindows() then
        	if string.sub(text, 1, 11) == "reloadmagic" then     -- 重载魔法
	            CMagicCtrlMgr:getInstance():LoadFile();
	            TIPS({type=1,str="reloadmagic"})
	            return
	        elseif string.sub(text, 1, 6) == "#@goto" then
	            local q_goto = string.sub(text, 8)
		    	if q_goto ~= nil then
	                __GotoTarget({ ru = q_goto })
	            end
	            return
	        end
        end
        ---------------------------------------------------------------------


		-- if string.utf8len(text) > 1000 then
		-- 	text = string.utf8sub(text,1,1000)
		-- elseif text == "*#8888*#" then
		-- 	require("src/layers/setting/MsgPushLayer").new()
		-- end
		if string.len(text) > 0 then
			--cclog("发送："..text)
            text = DirtyWords:checkAndReplaceDirtyWords(text, "****")

            --私聊需要解析格式@用户名 空格
            local senderName = "";
            if self.currSendChannel == personal then
                if string.sub(text,1,1) ~= "@" then
                    return
                end

                local pos = string.find(text, " ")
                if pos == nil then
                    return
                end

                senderName = string.sub(text, 2, pos-1)
                text = string.sub(text, pos + 1)

                if string.len(text) == 0 then
                    return
                end

                -- if senderName == MRoleStruct:getAttr(ROLE_NAME) then
                --     return
                -- end
            end

			--dump(text)
			-- local luaEventMgr = LuaEventManager:instance()
			-- local buffer
			--dump(text)
			local t = {}
			if string.sub(text,1,1) == "#" then
				--GM instruction
				if text == "#gbyd" then
					G_TUTO_ON = false
					G_TUTO_DATA = {}
				end
				-- buffer = luaEventMgr:getLuaEventExEx(SHELL_CS_SHELL_COMMAND)
				-- buffer:writeByFmt("iS",userInfo.currRoleId,string.sub(text,2,string.len(text)).." "..userInfo.currRoleId)
	            t.cmdText = string.sub(text,2,string.len(text)).." "..userInfo.currRoleId
	            -- dump(t)
	            g_msgHandlerInst:sendNetDataByTableExEx(SHELL_CS_SHELL_COMMAND, "ShellCommandProtocol", t)
	            self.chatEditCtrl:setText("")
	            --LuaSocket:getInstance():sendSocket(buffer)
	            return
			else
				--buffer = luaEventMgr:getLuaEventExEx(CHAT_CS_SENDCHATMSG)
				-- dump(self.currSendChannel)
				log("self.currSendChannel = "..self.currSendChannel)
				--log("1 text = "..tostring(text))
				--dump(self.linkTab)
				--local linkDataTab = serialize(self.linkTab)
				local function changeTextToLink(text)
					for i,v in ipairs(self.linkTab) do
						text = string.gsub(text, v.name, function(str)  
								for i,v in ipairs(self.linkTab) do
					                if v.name == str and v.used ~= true then
					                    -- local resultStr = v.linkInfo
					                    v.used = true
					                    --table.remove(self.linkTab, i)
					                    return v.linkInfo
					                end
					            end
							end)
					end

					self.linkTab = {}

					return text
				end
				text = changeTextToLink(text)
				--log("2 text = "..tostring(text))

				--小喇叭频道处理
	            if string.utf8sub(text,1,7) == game.getStrByKey("chat_trumpet_tag") then
	            	local realText = string.utf8sub(text,8)
	            	dump(realText)
	            	if realText == "" then
	            		--TIPS({str = game.getStrByKey("charm_addBlackToSelf"), type = 1})
	            	else
	            		--buffer:writeByFmt("cSic",trumpet,realText,userInfo.currRoleStaticId,0)
	            		t.channel = trumpet
	            		t.message = realText
	            	end
	            else
	            	--buffer:writeByFmt("cSic",self.currSendChannel,text,userInfo.currRoleStaticId,0)
	            	t.channel = self.currSendChannel
	            	t.message = text
	            end

                if self.currSendChannel == personal then
                    --buffer:writeByFmt("S",senderName)
                    t.targetName = senderName
                end

				--dump(text)
			end
			--LuaSocket:getInstance():sendSocket(buffer)
			dump(t)
			g_msgHandlerInst:sendNetDataByTableExEx(CHAT_CS_SENDCHATMSG, "SendChatProtocol", t)
			self.chatEditCtrl:setText("")
			if not G_CHAT_INFO.sendHistory then
				G_CHAT_INFO.sendHistory = {}
			end
			if #G_CHAT_INFO.sendHistory >= 5 then
				table.remove(G_CHAT_INFO.sendHistory,1)
			end
			G_CHAT_INFO.sendHistory[#G_CHAT_INFO.sendHistory+1] = text

			self:sendLinkNetData(text)

            if senderName ~= nil and self.currSendChannel == personal then
                local str = "@"..senderName.." "
                self.personalName = senderName
                self.chatEditCtrl:setText(str)
            end

            --todo
            --[[
            --如果在接收消息时切换全体模式会导致当前聊天状态被中断，如果在发送时判断聊天目标不是当前列表目标，切换全体模式会需要判断对方是否在线的问题，因此聊天目标切换切换全体模式pending
            if self:getChildByTag(commConst.TAG_CHAT_PRIVATECHATLISTVIEW) then
                local privateChatListView = self:getChildByTag(commConst.TAG_CHAT_PRIVATECHATLISTVIEW)
                cc.Director:getInstance():getOpenGLView():handleTouchBegin(privateChatListView.btn_show_all:getParent():convertToWorldSpace(cc.p(privateChatListView.btn_show_all:getPosition())), 0)
                cc.Director:getInstance():getOpenGLView():handleTouchEnd(privateChatListView.btn_show_all:getParent():convertToWorldSpace(cc.p(privateChatListView.btn_show_all:getPosition())), 0)
            end
            ]]

		end
	end
	self.menuSend = createMenuItem(baseNode,"res/component/button/60.png",cc.p(pos_x_menu_send_normal,45),sendFunc)
	addLabel(self.menuSend, game.getStrByKey("chat_send"), cc.p(self.menuSend:getContentSize().width/2, self.menuSend:getContentSize().height/2), cc.p(0.5,0.5), 21, true)

	self:initTouch()
    self.isShow = true

	local disData = function()
		if self.currDisChannel == personal then
            self:selectTab(0)
	    	self:updateDisplayData(personal)
        else
            self:selectTab(1)
	    	self:updateDisplayData(allChannel)
        end       
	end
	performWithDelay(self,disData,0.25)

	self:registerScriptHandler(function(event)
		if event == "enter" then
			--G_TUTO_NODE:setShowNode(self, SHOW_CHAT)
			Event.Add(EventName.CloseChat, self, self.hide)
		elseif event == "exit" then
			if G_TUTO_NODE then
				G_TUTO_NODE:setShowNode(self, SHOW_MAIN)
			end
			Event.Remove(EventName.CloseChat, self)
		end
	end)

	self.settingArrow = {}
	self.cellContent = {}
	self:createScroll()
	self:createTrumpet()
    self:createPrivateChatListBtn()

    self:updatePrivateBtn()

    self.curInputShowType = 2
    self:setInputShowType(self.curInputShowType)

	local  listenner = cc.EventListenerTouchOneByOne:create()
	listenner:setSwallowTouches(true)
    listenner:registerScriptHandler(function(touch, event)
            local location = self.bg:getParent():convertTouchToNodeSpace(touch)
   			-- log("location.x =".. location.x)
			-- log("location.y =".. location.y)
            local privateChatListView = self:getChildByTag(commConst.TAG_CHAT_PRIVATECHATLISTVIEW)
            if cc.rectContainsPoint(self.bg:getBoundingBox(), cc.p(location.x, location.y)) then
            	-- log("touch true")
       			return true
       		else
       			-- log("touch false")
       			return false
       		end
        end,cc.Handler.EVENT_TOUCH_BEGAN )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, self)
    if G_CHAT_INFO and G_CHAT_INFO.trumpet then
    	self:updateDisplayData(world, true, G_CHAT_INFO.trumpet)
    end
end

function ChatView:createSelectNode()
	self.selTabNode = cc.Node:create()
	self.bg:addChild(self.selTabNode)
       
    local titles = {
						game.getStrByKey("chat_multiple"),
						game.getStrByKey("chat_world"),
						game.getStrByKey("chat_area"),
						game.getStrByKey("chat_teamup"),
						game.getStrByKey("chat_faction"),
						game.getStrByKey("chat_system"),
						game.getStrByKey("chat_personal"),					
					}
    local posTab = {
                       cc.p(75, 582),
                       cc.p(75, 508),
                       cc.p(75, 434),
                       cc.p(75, 360),
                       cc.p(75, 286),
                       cc.p(75, 212),
                       cc.p(75, 138),
                   }
    local x = 75
    local y = self.bg:getContentSize().height - 60
    local addY = -73
    for i,v in ipairs(titles) do
    	posTab[i] = cc.p(x, y)
    	y = y + addY
    end

    for i = 1, #titles do
        local button = createSprite(self.selTabNode, "res/chat/tab.png", posTab[i], cc.p(0.5, 0.5))
        button:setTag(i);
        local label = createLabel(self.selTabNode, titles[i], posTab[i],cc.p(0.5, 0.5), 22, true, nil, nil )
        label:setLocalZOrder(1)
        
        local listennerTab = cc.EventListenerTouchOneByOne:create()
        listennerTab:setSwallowTouches(true)
        listennerTab:registerScriptHandler( function(touch, event)
            local location = button:getParent():convertTouchToNodeSpace(touch)
            if cc.rectContainsPoint(button:getBoundingBox(), cc.p(location.x, location.y)) then
                self.selBeginTime = os.time()
                return true
            else
                self.selBeginTime = nil;
                return false
            end
        end , cc.Handler.EVENT_TOUCH_BEGAN)
        listennerTab:registerScriptHandler( function(touch, event)
            --长按三秒只切换发送，不切换显示
            if self.selBeginTime ~= nil and os.time() - self.selBeginTime > 1 then
                local ch = idxToChannel[i]
                if self.currDisChannel == allChannel and ch ~= allChannel then
                    self.currSendChannel = ch
                    self:resetSelSign()
                    self:setInputShowType()
                end
            else
                self:selectTab(i)   
                AudioEnginer.playTouchPointEffect()             
            end
        end , cc.Handler.EVENT_TOUCH_ENDED)

        local eventDispatcher = self:getEventDispatcher()
        eventDispatcher:addEventListenerWithSceneGraphPriority(listennerTab, button)       
    end
end

function ChatView:resetSelSign()
    if self.selTabNode == nil then
        return
    end   

    -- 背景图切换
    local channelCount = #channelToIdx
    for i = 1, channelCount do
        local tmp = self.selTabNode:getChildByTag(i)
        tmp:setTexture("res/chat/tab.png")
        tmp:removeChildByTag(111); -- 删除箭头
        tmp:removeChildByTag(112);
    end

    if channelToIdx[self.currDisChannel] ~= nil then
        local tmp = self.selTabNode:getChildByTag(channelToIdx[self.currDisChannel])
        if tmp ~= nil then
            tmp:setTexture("res/chat/tab_dis.png")

            --添加箭头
            local arrow = createSprite(tmp, "res/group/arrows/9.png", cc.p(tmp:getContentSize().width, tmp:getContentSize().height/2), cc.p(0, 0.5))
		    arrow:setTag(111)
        end
    end


    if channelToIdx[self.currSendChannel] ~= nil then
        local tmp = self.selTabNode:getChildByTag(channelToIdx[self.currSendChannel])
        if tmp ~= nil then
            --发送选择页特效
            local box = createSprite(tmp, "res/chat/tab_send.png", cc.p(tmp:getContentSize().width/2, tmp:getContentSize().height/2), cc.p(0.5, 0.5))
		    box:setTag(112)
        end
    end
end

function ChatView:getLinkInfo(str)
	if str == nil then
		return
	end

	local linkInfoTab = {}

	local flag = "%^"
	local flagLink = "^l"
	local flagParamBegin = "%("
	local flagParamEnd = "%)"
	local strFound
	local strLeft = str
	local strAdd
	local param
	local strBegin,strEnd
	local tag = 1
	local strflag
	local fontColor

	local addLinkItem = function(linkInfoStr)
		--dump(linkInfoStr)
		local record = require("src/RichText").parseLink(nil, linkInfoStr)
		--dump(record)
		if record then
			table.insert(linkInfoTab, record)
		end
	end

	while true do
		strBegin = string.find(strLeft, flag)
		if strBegin == nil then
			--addTextItem(strLeft, defaultFontColor)
			break
		else
			--log("strBegin:"..strBegin)
			if strBegin > 1 then
				strAdd = string.sub(strLeft, 1, strBegin-1)
				--log("strAdd:"..strAdd)
				--addTextItem(strAdd, defaultFontColor)
			end
			strEnd = string.find(strLeft, flag, strBegin+1)
			if strEnd then
				--log("strEnd:"..strEnd)
				strFound = string.sub(strLeft, strBegin, strEnd)
				--log("strFound:"..strFound)
				strFlag = string.sub(strFound, 1, 2)
				log("strFlag:"..strFlag)
				if strFlag then
					local paramBegin
					local paramEnd
					if strFlag == flagLink then
						paramBegin = string.find(strFound, flagParamBegin)
						log("paramBegin:"..paramBegin)
						paramEnd = string.find(strFound, flagParamEnd)
						log("paramEnd:"..paramEnd)
						if paramBegin and paramEnd then
							param = string.sub(strFound, paramBegin+1, paramEnd-1)
							if strFlag == flagLink then
								--log("link ~~~~~~~~~~~~~~~~~")
								local linkInfoStr = param
								addLinkItem(linkInfoStr)
							end
						end
					else
						break
					end
				else
					break
				end
				strLeft = string.sub(strLeft, strEnd+1, -1)
				--log("strLeft:"..strLeft)
			else
				break
			end
		end
	end
	
	--dump(linkInfoTab)
	return linkInfoTab
end

function ChatView:changeInputStatus()
	self.inputMode = 2
	if self.inputMode==2 then
		self.inputMode = 1
	else
		self.inputMode = 2
	end
end

function ChatView:showFacePanel()
	self.faceNode = cc.Node:create()
	self.faceNode:setLocalZOrder(88)
	self.baseNode:addChild(self.faceNode)

	local temp = createSprite(self.faceNode,"res/chat/bg_left.png",cc.p(870,290),cc.p(1.0,0.5),1)
	temp:setFlippedX(true)
	local mid = createSprite(self.faceNode,"res/chat/bg_mid.png",cc.p(570,290),cc.p(1.0,0.5),1)
	mid:setScaleX((70*9-580)/225)
	local temp2 = createSprite(self.faceNode,"res/chat/bg_left.png",cc.p(520,290),cc.p(1.0,0.5),1)
	createSprite(self.faceNode,"res/chat/arrow.png",cc.p(610,110),cc.p(0.5,1.0),1)
	for i=1,44 do
		local m,n = math.modf((i-1)/9)
		n = n*9
		local faceBg = createSprite(self.faceNode,"res/chat/white.png",cc.p(265+n*70,445-m*70),cc.p(0.5,0.5),1)
		faceBg:setScale(30/39)
		createSprite(self.faceNode,"res/chat/face/"..i..".png",cc.p(265+n*70,445-m*70),cc.p(0.5,0.5),1)
	end

	local  listenner = cc.EventListenerTouchOneByOne:create()
    listenner:setSwallowTouches(true)
    local selIndx = 0
    local isNotIn = false
    listenner:registerScriptHandler(function(touch, event)
		local pt = self.baseNode:convertTouchToNodeSpace(touch)
		if not (cc.rectContainsPoint(temp:getBoundingBox(),pt) or cc.rectContainsPoint(mid:getBoundingBox(),pt) or cc.rectContainsPoint(temp2:getBoundingBox(),pt)) then
			isNotIn = true
		end
		for j=1,44 do
			local m,n = math.modf((j-1)/9)
			n = n*9
			local box = cc.rect(265+n*70-35,445-m*70-35,70,70)
			if cc.rectContainsPoint(box,pt) then
				local o = createSprite(self.faceNode,"res/chat/orange.png",cc.p(265+n*70,445-m*70),cc.p(0.5,0.5),1)
				o:setTag(1)
				o:setScale(30/39)
				selIndx = j
			end
		end
 		return true
    end,cc.Handler.EVENT_TOUCH_BEGAN )

     listenner:registerScriptHandler(function(touch, event)
		local pt = self.baseNode:convertTouchToNodeSpace(touch)
		local orangePic = self.faceNode:getChildByTag(1)
		if orangePic then
			removeFromParent(orangePic)
		end
		if not (cc.rectContainsPoint(temp:getBoundingBox(),pt) or cc.rectContainsPoint(mid:getBoundingBox(),pt) or cc.rectContainsPoint(temp2:getBoundingBox(),pt)) and isNotIn then
			removeFromParent(self.faceNode)
			isNotIn = false
			selIndx = 0
		end
		for j=1,44 do
			local m,n = math.modf((j-1)/9)
			n = n*9
			local box = cc.rect(265+n*70-35,445-m*70-35,70,70)
			if cc.rectContainsPoint(box,pt) and j == selIndx then
				local str = self.chatEditCtrl:getText().."^i("..selIndx..")^"
				self.chatEditCtrl:setText(str)
				selIndx = 0
				removeFromParent(self.faceNode)
			end
		end
    end,cc.Handler.EVENT_TOUCH_ENDED )

    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner,temp)
end

function ChatView:sendLinkData(text)
	cclog(text.."@@@")
	-- local buffer = LuaEventManager:instance():getLuaEventExEx(CHAT_CS_SENDCHATMSG)
	-- buffer:writeByFmt("cSic",channelIdClient2Server(self.currSendChannel),text,userInfo.currRoleStaticId,0) 
	-- LuaSocket:getInstance():sendSocket(buffer)
	local t = {}
	t.channel = channelIdClient2Server(self.currSendChannel)
	t.message = text
	g_msgHandlerInst:sendNetDataByTableExEx(CHAT_CS_SENDCHATMSG, "SendChatProtocol", t)	

	self:sendLinkNetData(text)
end

function ChatView:sendLinkNetData(text)
	local linkTab = self:getLinkInfo(text)
	dump(linkTab)
	if linkTab then
		-- local luaEventMgr = LuaEventManager:instance()
		-- local buffer = luaEventMgr:getLuaEventExEx(CHAT_CS_SHARE_ITEM)
		-- buffer:writeByFmt("ii", userInfo.currRoleStaticId, #linkTab)
		-- for k,v in pairs(linkTab) do
		-- 	log("v.protoId = "..v.protoId.." v.posIndex = "..v.posIndex.." v.bagId = "..v.bagId.." v.time = "..v.time)
		-- 	buffer:writeByFmt("issi", v.protoId, v.posIndex, v.bagId, v.time)
		-- end
		-- --dump(buffer)
		-- LuaSocket:getInstance():sendSocket(buffer)
		local t = {}
		t.shareCount = #linkTab
		t.itemInfo = {}
		for k,v in pairs(linkTab) do
			local record = {}
			record.itemID = v.protoId
			record.slot = v.posIndex
			record.bagIndex = v.bagId
			record.timeTick = v.time
			table.insert(t.itemInfo, record)
		end
		g_msgHandlerInst:sendNetDataByTableExEx(CHAT_CS_SHARE_ITEM, "ShareItemProtocol", t)
	end
end

function ChatView:initTouch() 
end

function ChatView:createScroll()
	local scrollView = cc.ScrollView:create()
    if nil ~= scrollView then
        scrollView:setViewSize(cc.size(365, (self.rightBg:getContentSize().height - scrollView_height_offset_normal)))
        scrollView:setPosition(cc.p(3, scrollView_posY_normal))
        scrollView:setScale(1.0)
        scrollView:ignoreAnchorPointForPosition(true)
        local node = cc.Node:create()
        self.node = node
        scrollView:setContainer(node)
        scrollView:setContentSize(cc.size(300,0))
        scrollView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        scrollView:setClippingToBounds(true)
        scrollView:setBounceable(true)
        self.rightBg:addChild(scrollView)
        self.scrollView = scrollView
    end
    
    self.split_line = createTitleLine(self.rightBg, cc.p(self.rightBg:getContentSize().width/2, self.rightBg:getContentSize().height-90), 306, cc.p(0.5,0.5) )
end

function ChatView:createTrumpet()
	self.sprTrumpet = createSprite(self.rightBg, "res/group/itemIcon/1000.png" ,cc.p(0, self.rightBg:getContentSize().height-40), cc.p(0, 0), nil, 0.7)
	self.labTrumpet = createLabel(self.rightBg, "【"..self.titles[5].."】", cc.p(35, self.rightBg:getContentSize().height-33), cc.p(0, 0), 20)
	self.labTrumpet:setColor(self.colors[5])
	self.trumpetNode = cc.Node:create()
	self.trumpetNode:setPosition(10, self.rightBg:getContentSize().height-33)
	self.rightBg:addChild(self.trumpetNode)
	self.labTrumpet:setLocalZOrder(1)
end

function ChatView:setPrivateChatTarget(targetName)
    self.chatEditCtrl:setText("@" .. targetName .. " ")
    self.privateChatTarget = targetName
    self.personalName = targetName--记忆当前私聊对象，用于点击私聊tab时填充回来
    --刷新聊天窗内容
    if G_CHAT_INFO[commConst.Channel_ID_Privacy] == nil then
        return
    end
    self.isUpdateScrollView = true
    self:refreshChatData()
end

function ChatView:setPrivateChatTargetAll()
    self.chatEditCtrl:setText("")
    self.privateChatTarget = nil
    --刷新聊天窗内容
    if G_CHAT_INFO[commConst.Channel_ID_Privacy] == nil then
        return
    end
    self.isUpdateScrollView = true
    self:refreshChatData()
end

local scrollViewPosX_normal, scrollViewPosX_expanded = 3, 299
local privateChatListBtn_posX_normal, privateChatListBtn_posX_expanded = rightBg_normalWidth / 2, rightBg_normalWidth + 100
local tag_privateChatList_btn_title = 12
local tag_privateChatList_btn_arrow = 13
local privateChatList_btn_arrow_pos_x_normal, privateChatList_btn_arrow_pos_x_expanded = 274, 48
local tag_spr_cutLine = 14

function ChatView:privateChatListBtnCallBack()
    local rightBgHeight = self.bg:getContentSize().height - 120
    if self:getChildByTag(commConst.TAG_CHAT_PRIVATECHATLISTVIEW) then
        self.rightBg:setContentSize(cc.size(rightBg_normalWidth, rightBgHeight))
        self.bg:setContentSize(cc.size(bg_size_width_normal, display.height))
        self:removeChildByTag(commConst.TAG_CHAT_PRIVATECHATLISTVIEW)
        self:removeChildByTag(tag_spr_cutLine)
        self.scrollView:setPositionX(scrollViewPosX_normal)
        self.privateChatListBtn:setPositionX(privateChatListBtn_posX_normal)
        self.privateChatListBtn:getChildByTag(tag_privateChatList_btn_title):setString(game.getStrByKey("private_chat_open_private_chat_list_btn_title"))
        self.privateChatListBtn:getChildByTag(tag_privateChatList_btn_arrow):setFlippedX(false)
        self.privateChatListBtn:getChildByTag(tag_privateChatList_btn_arrow):setPositionX(privateChatList_btn_arrow_pos_x_normal)
        self.closeBtn:setPositionX(arrow_btn_posX_normal)
        self.editeBg:setContentSize(size_editeBg_normal)
        self.chatEditCtrl:setContentSize(size_chatEditCtrl_normal)
        self.chatEditCtrl:setPosition(getCenterPos(self.editeBg))
        --[[
        self.microphone.voiceBtn:setContentSize(size_microphone_normal)
        if self.microphone.label_voice_btn then
            self.microphone.label_voice_btn:setPosition(getCenterPos(self.microphone.voiceBtn))
        end
        ]]
        self.menuSend:setPositionX(pos_x_menu_send_normal)
        self.moreBtn:setPositionX(pos_x_more_btn_normal)
        self.voiceSetBtn:setPositionX(pos_x_voiceSet_btn_normal)
        self:setPrivateChatTargetAll()
    else
        self.rightBg:setContentSize(cc.size(rightBg_expandedWidth, rightBgHeight))
        self.bg:setContentSize(cc.size(bg_size_width_private_chat, display.height))
        self.scrollView:setPositionX(scrollViewPosX_expanded)
        local privateChatListView = require("src/layers/chat/privateChatListView").new(self)
        privateChatListView:setPosition(cc.p(136, 105))
        privateChatListView:setTag(commConst.TAG_CHAT_PRIVATECHATLISTVIEW)
        self:addChild(privateChatListView)
        local spr_cutLine = createScale9Sprite(self,"res/common/scalable/cutLine.png", cc.p(620 - 480 + 283, 102), cc.size(47, display.height - 640 + 522 - 6), cc.p(0.5, 0))
        spr_cutLine:setTag(tag_spr_cutLine)
        self.privateChatListBtn:setPositionX(privateChatListBtn_posX_expanded)
        self.privateChatListBtn:getChildByTag(tag_privateChatList_btn_title):setString(game.getStrByKey("private_chat_close_private_chat_list_btn_title"))
        self.privateChatListBtn:getChildByTag(tag_privateChatList_btn_arrow):setFlippedX(true)
        self.privateChatListBtn:getChildByTag(tag_privateChatList_btn_arrow):setPositionX(privateChatList_btn_arrow_pos_x_expanded)
        self.closeBtn:setPositionX(arrow_btn_posX_expanded)
        self.editeBg:setContentSize(size_editeBg_expanded)
        self.chatEditCtrl:setContentSize(size_chatEditCtrl_expanded)
        self.chatEditCtrl:setPosition(getCenterPos(self.editeBg))
        --[[
        self.microphone:setContentSize(size_microphone_expanded)
        if self.microphone.label_voice_btn then
            self.microphone.label_voice_btn:setPosition(getCenterPos(self.microphone.voiceBtn))
        end
        ]]
        self.menuSend:setPositionX(pos_x_menu_send_expanded)
        self.moreBtn:setPositionX(pos_x_more_btn_expanded)
        self.voiceSetBtn:setPositionX(pos_x_voiceSet_btn_expanded)
    end
end

function ChatView:createPrivateChatListBtn()
    self.privateChatListBtn = createTouchItem(self.rightBg, "res/tips/tipsBg.png", cc.p(rightBg_normalWidth / 2, 25), handler(self, self.privateChatListBtnCallBack))
    local privateChatList_btn_title = createLabel(self.privateChatListBtn, game.getStrByKey("private_chat_open_private_chat_list_btn_title"), cc.p(self.privateChatListBtn:getContentSize().width / 2, self.privateChatListBtn:getContentSize().height / 2),cc.p(0.5, 0.5), 22, nil, 20, nil, MColor.lable_yellow)
    privateChatList_btn_title:setTag(tag_privateChatList_btn_title)
    local privateChatList_btn_arrow = createSprite(self.privateChatListBtn, "res/tips/tipsArrow.png", cc.p(privateChatList_btn_arrow_pos_x_normal, self.privateChatListBtn:getContentSize().height / 2), cc.p(0, 0.5))
    privateChatList_btn_arrow:setTag(tag_privateChatList_btn_arrow)
end

function ChatView:scrollEnd()
end

function ChatView:refreshChatData()
	if true then
		self:updateScrollView()
		self:cleanCellContent()
		return
	end
end

function ChatView:updateScrollView()
	if self.isShow == false then
		return
	end

	-- dump(self.isUpdateScrollView)
	-- dump(self.scrollView:getContentOffset().y)
	-- if self.scrollView and self.scrollView:getContentOffset().y < 0 and self.isUpdateScrollView ~= true then
	-- 	--log("reset 11111111111111111111111111111111111111")
	-- 	return
	-- end
	-- self.isUpdateScrollView = false
	if self.isUpdateScrollView == true then
		self.firstNameRichText = nil
	end

	if not self.scale_bg_node then
		self.scale_bg_node = cc.Node:create()
		self.node:addChild(self.scale_bg_node,-2)
		self.scale_bg_node1 = cc.Node:create()
		self.node:addChild(self.scale_bg_node1,-1)
	end
	local lineHeight = 26
	local fontSize = 20
	local paddingX = 10
	local function checkInCellContent(data)
		local richText, spr = nil, nil
		
		if self.cellContent[data.channelId] == nil then
			self.cellContent[data.channelId] = {}
		end

		for k,v in pairs(self.cellContent[data.channelId]) do
			if v.data == data then
				return
			end
		end

		local isCharmRankTop = false
		if data.channelId == 4 and G_CharmRankList and G_CharmRankList.ListData and #G_CharmRankList.ListData > 0 then
			local CharmData = G_CharmRankList.ListData[1]
			if CharmData[2] == data.usrName then
				isCharmRankTop = true
			end
		end
	    
	    local strName = (data.usrName or "").."："
	  	if isCharmRankTop then
	  		strName = (data.usrName or "").."(" ..game.getStrByKey("charm_week_top") ..")："
	  	end

	  	if data.channelId == 1 and data.usrName == MRoleStruct:getAttr(ROLE_NAME) 
	  		and data.targetName and data.targetName ~= "" then
	  		strName = string.format(game.getStrByKey("chat_talk_to"), data.targetName)
	  	end

	  	-- if data.time then
	  	-- 	local timeStr = os.date("%H:%M:%S", data.time)
	  	-- 	strName = timeStr.." "..strName
	  	-- end

		--dump(data)
		local nameRichText = require("src/RichText").new(self.node, cc.p(0, 0), cc.size(300, 30), cc.p(0, 0), lineHeight, fontSize, MColor.white)
		nameRichText:setAutoWidth()
		-- dump(data)
		-- dump(MRoleStruct:getAttr(ROLE_NAME))
		if data.time then
	  		local timeStr = os.date("%H:%M:%S", data.time)
	  		nameRichText:addText(timeStr, MColor.lable_yellow, false)
	  	end 
		nameRichText:addText("【"..self.titles[data.channelId].."】", self.colors[data.channelId], false)
	    nameRichText:addTextItem(strName, MColor.lable_yellow, false, true, true, 
	    	function() 
                if data.isSpecialPrivate then
                    return
                end
	    		if data.channelId == personal then
		    		if data.targetName and data.targetName ~= "" and data.targetName ~= MRoleStruct:getAttr(ROLE_NAME) then
		    			self:showOperationPanel(data.targetName) 
		    		else
		    			self:showOperationPanel(data.usrName)
		    		end
		    	else
		    		if data.usrName and data.usrName ~= MRoleStruct:getAttr(ROLE_NAME) then
		    			self:showOperationPanel(data.usrName) 
		    		end
		    	end
	    	end)
	    nameRichText:addCheckFunc(function()
				--dump(richText:getPositionY())
				--dump(self.scrollView:isNodeVisible(richText))
				dump(self.scrollView:isNodeVisible(nameRichText))
				if self.scrollView and self.scrollView.isNodeVisible and nameRichText then
					return self.scrollView:isNodeVisible(nameRichText)
				else
					return true
				end
			end)
	    nameRichText:format()


	    richText = require("src/RichText").new(self.node, cc.p(0, 0), cc.size(305, 30), cc.p(0, 0), lineHeight, fontSize, MColor.white)
		richText:setAutoWidth()

		if isCharmRankTop then
			richText:setFont(nil, MColor.deep_purple)
		elseif data.usrName == MRoleStruct:getAttr(ROLE_NAME) then
			richText:setFont(nil, MColor.drop_white)
		else
			richText:setFont(nil, MColor.lable_black)
		end
		richText:addCheckFunc(function()
				--dump(richText:getPositionY())
				--dump(self.scrollView:isNodeVisible(richText))
				if self.scrollView and self.scrollView.isNodeVisible and richText then
					return self.scrollView:isNodeVisible(richText)
				else
					return true
				end
			end)
		local textBg, textBg_arrow = nil,nil
	    local parseData = {}
     	if string.sub(data.text, 1, 2) == "*&" then
     		parseData = require("src/RichText").parseLink(data.text)
     	end

     	if data.type ~= 3 then
	   --   	if parseData.isLink then
	   --   		local propOp = require("src/config/propOp")
	   --   		local tNameColor = {
				-- 	[0] = MColor.red,
				-- 	[1] = MColor.white,
				-- 	[2] = MColor.green,
				-- 	[3] = MColor.blue,
				-- 	[4] = MColor.purple,
				-- 	[5] = MColor.orange,
				-- }

				-- local func = function()
				-- 	if parseData.isSpecial == "false" then
				-- 		local Mtips = require "src/layers/bag/tips"
				-- 		Mtips.new(
				-- 		{ 
				-- 			protoId = tonumber(parseData.protoId),
				-- 			--grid = gird,
				-- 			pos = cc.p(0, 0),
				-- 			--actions = actions,
				-- 		})
				-- 	else
				-- 		--g_msgHandlerInst:sendNetDataByFmtExEx(CHAT_CS_CLICKANCHOR,"iiisc",G_ROLE_MAIN.obj_id,tonumber(parseData.ownerId),tonumber(parseData.protoId),tonumber(parseData.posIndex),tonumber(parseData.bagId))
				-- 		local t = {}
				-- 		t.targetRoleSID = parseData.ownerId
				-- 		t.itemID = parseData.protoId
				-- 		t.slot = parseData.posIndex
				-- 		t.bagIndex = parseData.bagId
				-- 		t.timeTick = parseData.time
				-- 		g_msgHandlerInst:sendNetDataByTableExEx(CHAT_CS_CLICKANCHOR, "ClickAnchorProtocol", t)
				-- 	end
				-- end

				-- richText:addTextItem("【"..parseData.name.."】", tNameColor[tonumber(parseData.qualityId)], false, true, true, func)
	   --   		-- local obj,line = createLinkLabel(self.node, "【"..parseData.name.."】", cc.p(x,h), cc.p(0.0,1.0), 24, nil,nil,tNameColor[tonumber(parseData.qualityId)],nil,func,true)
	   --   		-- perH = obj:getContentSize().height+16

	   --   		-- labels[5] = obj
	   --   		-- labels[6] = line
	   --   	else
				-- local ww = 780
				-- local richText = require("src/RichText").new(self.node, cc.p(x, h+addH  ), cc.size(ww-x, 96), cc.p(0.0, 0.0), 28, 24, MColor.white, nil, nil, false)
				-- richText:setAutoWidth()
			    richText:addText(data.text , nil, false)
			    if data.calltype and data.calltype ~= 0 then
			    	richText:addTextItem("【".. game.getStrByKey( "fb_quickJoin" )  .."】", nil, false, true, true, function()  __CallGoto( data ) end )
			    end

			    if data.isSpecialPrivate == true and data.textEx and data.callback then
			    	richText:addTextItem("【".. data.textEx .."】", nil, false, true, true, function() self:hide() data.callback() end )
			    end
			    --richText:format()
			    -- perH = richText:getContentSize().height+12
			-- end
			richText:format()
			--聊天背景
			if data.usrName == MRoleStruct:getAttr(ROLE_NAME) then
				textBg = createScale9Sprite(self.scale_bg_node, "res/common/scalable/2.png", getCenterPos(richText, -paddingX, -(lineHeight-fontSize)/2), cc.size(richText:getContentSize().width+paddingX*2, richText:getContentSize().height+6), cc.p(0.0, 0.0), nil, nil, -1)
				-- dump(textBg:getContentSize())
				textBg_arrow = createSprite(self.scale_bg_node1, "res/group/arrows/11.png", cc.p(textBg:getContentSize().width, textBg:getContentSize().height/2), cc.p(0, 0.5))
			else
				textBg = createScale9Sprite(self.scale_bg_node, "res/common/scalable/1.png", getCenterPos(richText, -paddingX, -(lineHeight-fontSize)/2), cc.size(richText:getContentSize().width+paddingX*2, richText:getContentSize().height+6), cc.p(0.0, 0.0), nil, nil, -1)
				textBg_arrow = createSprite(self.scale_bg_node1, "res/group/arrows/10.png", cc.p(0, textBg:getContentSize().height/2), cc.p(1, 0.5))
				textBg_arrow:setFlippedX(true)
			end
		else
			print("caohaobin   普通语音")
			spr,richText = require("src/layers/chat/Microphone"):createVoiceLabel(self.node, data.text, data.fileid,data.timeLen, cc.p(0,-25), cc.p(0.0,0.0),self.colors[data.channelId],30,data.channelId)
			spr:setAnchorPoint(cc.p(0, 0))	
			--聊天背景
			if data.usrName == MRoleStruct:getAttr(ROLE_NAME) then
				textBg = createScale9Sprite(self.scale_bg_node, "res/common/scalable/2.png", getCenterPos(richText, -paddingX, -(lineHeight-fontSize)/2), cc.size(richText:getContentSize().width+paddingX*2, richText:getContentSize().height+6), cc.p(0.0, 0.0), nil, nil, -1)
				-- dump(textBg:getContentSize())
				textBg_arrow =createSprite(self.scale_bg_node1, "res/group/arrows/11.png", cc.p(textBg:getContentSize().width, textBg:getContentSize().height/2), cc.p(0, 0.5))
			else
				textBg = createScale9Sprite(self.scale_bg_node, "res/common/scalable/1.png", getCenterPos(richText, -paddingX, -(lineHeight-fontSize)/2), cc.size(richText:getContentSize().width+paddingX*2, richText:getContentSize().height+6), cc.p(0.0, 0.0), nil, nil, -1)
				textBg_arrow = createSprite(self.scale_bg_node1, "res/group/arrows/10.png", cc.p(0, textBg:getContentSize().height/2), cc.p(1, 0.5))
				textBg_arrow:setFlippedX(true)
			end		
		end
		
		

	    local record = {}
	    record.data = data
	    record.nameRichText = nameRichText
	    if richText then
	   	 	record.richText = richText
	   	end
	    if spr then
	    	record.spr = spr
	   	end
	   	if textBg then
	   		record.textBg = textBg
	   	end
	   	if textBg then
	   		record.textBg_arrow = textBg_arrow
	   	end
	   

	    table.insert(self.cellContent[data.channelId], #self.cellContent[data.channelId]+1, record)
	end

	local function getFromCellContent(data)
		for k,v in pairs(self.cellContent[data.channelId]) do
			if v.data == data then
				return v
			end
		end
	end
	--log("self.currDisChannel = "..self.currDisChannel
    if G_CHAT_INFO[self.currDisChannel] then
        local chatCount = 0
        local i = table.size(G_CHAT_INFO[self.currDisChannel])
        while chatCount < 30 and i > 0 do
            if G_CHAT_INFO[self.currDisChannel][i] and ((self.privateChatTarget and (self.privateChatTarget == G_CHAT_INFO[self.currDisChannel][i].usrName or self.privateChatTarget == G_CHAT_INFO[self.currDisChannel][i].targetName)) or not self.privateChatTarget) then
                checkInCellContent(G_CHAT_INFO[self.currDisChannel][i])
                chatCount = chatCount + 1
            end
            i = i - 1
        end
    end
	self:hideCellContent()
	local x = 0
	local y = 0
	local contentAddX = 25
	local padding = 10
	local scrollView_size = self.scrollView:getViewSize()
	local offsetY
	local firstNameRichText
	local lastNameRichText
    if G_CHAT_INFO[self.currDisChannel] then
        local chatCount = 0
        local i = table.size(G_CHAT_INFO[self.currDisChannel])
        while chatCount < 30 and i > 0 do
            while true do
                local records =  getFromCellContent(G_CHAT_INFO[self.currDisChannel][i])
                if not records then
                    --因为在私聊状态下，消息有可能被屏蔽，没有出现在cellContent中，因此records有可能为nil
                    break
                end
                if self.privateChatTarget and self.privateChatTarget ~= records.data.usrName and self.privateChatTarget ~= records.data.targetName then
                    break
                end
		        local nameRichText, richText, spr = nil,nil,nil
		        nameRichText, richText, spr = records.nameRichText,records.richText,records.spr
		        richText:setVisible(true)
		        if spr then
			        spr:setVisible(true)
		        end
                local content_size = richText:getContentSize()
		        textBg_size = content_size
		        if records.textBg then
	   		        records.textBg:setVisible(content_size.width > 5)
	   	        end
	   	        if records.textBg_arrow then
	   		        records.textBg_arrow:setVisible(content_size.width > 5)
	   	        end
		        --local content_size = richText:getContentSize()
		        --textBg_size = content_size
		        --本人要右对齐
		        if G_CHAT_INFO[self.currDisChannel][i].usrName == MRoleStruct:getAttr(ROLE_NAME) then
			        if spr and richText then
				        log("2222222222222")
				        richText:setPosition(cc.p(scrollView_size.width-content_size.width-contentAddX, y))
				        if records.textBg then
					        records.textBg:setPosition(scrollView_size.width-content_size.width-contentAddX-paddingX, y-4)
					        textBg_size = records.textBg:getContentSize()
				        end
				        if records.textBg_arrow then
					        records.textBg_arrow:setPosition(scrollView_size.width-content_size.width-contentAddX-paddingX+textBg_size.width-8, y+textBg_size.height/2-4)
				        end
				        y = y + richText:getContentSize().height
				        spr:setPosition(cc.p(scrollView_size.width-spr:getContentSize().width-contentAddX-30, y))
				        y = y + spr:getContentSize().height
			        elseif richText then
				        log("1111111111111")
				        richText:setPosition(cc.p(scrollView_size.width-content_size.width-contentAddX, y))
				        if records.textBg then
					        records.textBg:setPosition(scrollView_size.width-content_size.width-contentAddX-paddingX, y-4)
					        textBg_size = records.textBg:getContentSize()
				        end
				        if records.textBg_arrow then
					        records.textBg_arrow:setPosition(scrollView_size.width-content_size.width-contentAddX-paddingX+textBg_size.width-8, y+textBg_size.height/2-4)
				        end
				        y = y + richText:getContentSize().height
			        end
		        else
			        if spr then
				        richText:setPosition(cc.p(x+contentAddX, y))
				        if records.textBg then
					        records.textBg:setPosition(x+contentAddX-paddingX, y-4)
					        textBg_size = records.textBg:getContentSize()
				        end
				        if records.textBg_arrow then
					        records.textBg_arrow:setPosition(x+contentAddX-paddingX+8, y+textBg_size.height/2-4)
				        end
				        y = y + richText:getContentSize().height
				        spr:setPosition(cc.p(x+contentAddX, y))
				        y = y + spr:getContentSize().height
			        else
				        richText:setPosition(cc.p(x+contentAddX, y))
				        if records.textBg then
					        records.textBg:setPosition(x+contentAddX-paddingX, y-4)
					        textBg_size = records.textBg:getContentSize()
				        end
				        if records.textBg_arrow then
					        records.textBg_arrow:setPosition(x+contentAddX-paddingX+8, y+textBg_size.height/2-4)
				        end
				        y = y + richText:getContentSize().height
			        end
		        end
		        -- if spr then
		        -- 	y = y + padding
		        -- end

		        -- if richText then
		        -- 	y = y + richText:getContentSize().height
		        -- end
		        -- if spr then
		        -- 	y = y + spr:getContentSize().height
		        -- end
		        y = y + padding/2

		        --dump(nameRichText:getContentSize().height)

		        --记录两次刷新直接的偏移值
		        if self.firstNameRichText then
			        --log("test 1")
			        if nameRichText == self.firstNameRichText then
				        --log("test 2")
				        if checkNode(self.firstNameRichText) then
					        --log("test 3")
					        offsetY = self.firstNameRichText:getPositionY() - y
				        end
			        end
		        end

		        nameRichText:setVisible(true)
		        nameRichText:setPosition(cc.p(x, y))

		        --本人要右对齐
		        if G_CHAT_INFO[self.currDisChannel][i].usrName == MRoleStruct:getAttr(ROLE_NAME) then
			        nameRichText:setPosition(cc.p(self.scrollView:getViewSize().width-nameRichText:getContentSize().width, y))
		        end
		        y = y + nameRichText:getContentSize().height
		        --dump(nameRichText:getContentSize().height)

		        y = y + padding


		        if chatCount == 0 then
			        firstNameRichText = nameRichText
		        end
		        lastNameRichText = nameRichText
                chatCount = chatCount + 1
                break
            end
            i = i - 1
        end
    end
    

	self.scrollView:setContentSize(cc.size(360, y))

	if firstNameRichText then
		self.firstNameRichText = firstNameRichText
	end
	-- --如果是锁屏状态
	-- if self.scrollView and self.scrollView:getContentOffset().y < 0 and self.isUpdateScrollView ~= true then
	-- 	--log("reset 11111111111111111111111111111111111111")
	-- 	return
	-- end
	-- self.isUpdateScrollView = false
	local viewSizeHeight = self.scrollView:getViewSize().height
	if y < viewSizeHeight then
	 	self.scrollView:setContentOffset(cc.p(0,viewSizeHeight-y),false)
	else
		--如果是锁屏状态
		if self.scrollView and self.scrollView:getContentOffset().y < 0 and self.isUpdateScrollView ~= true then
			--log("reset 11111111111111111111111111111111111111")
			--dump(offsetY)
			if offsetY and offsetY < 0 then
				offsetY = self.scrollView:getContentOffset().y + offsetY
				--dump(self.scrollView:getContentSize().height + offsetY)
				if self.scrollView:getContentSize().height + offsetY < viewSizeHeight then
					offsetY = offsetY + (viewSizeHeight - (self.scrollView:getContentSize().height + offsetY))
				end

				--dump(offsetY)
				self.scrollView:setContentOffset(cc.p(0,offsetY),false)
				--dump(lastNameRichText:getPositionY())
				--dump(self.scrollView:getContentSize())
			end
			return
		end
		self.isUpdateScrollView = false

		self.scrollView:setContentOffset(cc.p(0,0),false)
	end
end

function ChatView:selectTab(index, roleData) 
	--print("ChatView:selectTab index = "..index)
	self.isUpdateScrollView = true
    if index == 0 or index == 7 then   
        self.currSendChannel = personal
        self.currDisChannel = personal
        if roleData ~= nil then
            self.personalName = roleData.name           
        end

        if self.personalName ~= nil then
            local str = "@"..self.personalName.." "
            self.chatEditCtrl:setText(str)
        end

        G_CHAT_INFO.unReadPrivateRecord = 0
        G_MAINSCENE:updateChatStartBtn()
        self:updatePrivateBtn()
    elseif index == 1 then
        self.currDisChannel = allChannel
        self.currSendChannel = self.currSendChannel
    elseif index == 2 then
        self.currSendChannel = world
        self.currDisChannel = world
        --self.chatEditCtrl:setText("")
    elseif index == 3 then
        self.currSendChannel = area
        self.currDisChannel = area
        --self.chatEditCtrl:setText("")
    elseif index == 4 then
        self.currSendChannel = teamup
        self.currDisChannel = teamup
        --self.chatEditCtrl:setText("")
    elseif index == 5 then
        self.currSendChannel = faction
        self.currDisChannel = faction
        --self.chatEditCtrl:setText("")
    elseif index == 6 then
        self.currSendChannel = system
        self.currDisChannel = system
        --self.chatEditCtrl:setText("")
    end
    if self.currDisChannel ~= personal and self:getChildByTag(commConst.TAG_CHAT_PRIVATECHATLISTVIEW) then
        --如果切换到其他私聊界面并处于私聊窗口展开情况，这里先模拟点击一下收起私聊列表，回到收起状态，再执行切换到其他界面的逻辑
        self:privateChatListBtnCallBack()
    end
    self.privateChatListBtn:setEnable(self.currDisChannel == personal)
    self.sprTrumpet:setVisible(self.currSendChannel ~= personal)
    self.labTrumpet:setVisible(self.currSendChannel ~= personal)
    self.trumpetNode:setVisible(self.currSendChannel ~= personal)
    self.privateChatListBtn:setVisible(self.currSendChannel == personal)
    self.scrollView:setViewSize(cc.size(365, self.currSendChannel == personal and (self.rightBg:getContentSize().height - scrollView_height_offset_private) or (self.rightBg:getContentSize().height - scrollView_height_offset_normal)))
    self.scrollView:setPositionY(self.currSendChannel == personal and scrollView_posY_private or scrollView_posY_normal)
    self.split_line:setVisible(self.currSendChannel ~= personal)
    if self.currSendChannel == personal and self.currDisChannel == allChannel then
        self.chatEditCtrl:setText("")--清除私聊@xxx
    end
    if G_CHAT_INFO[self.currDisChannel] then
        local idx = self.currDisChannel
    end
    self:resetSelSign()
    self:setInputShowType()
    self:refreshChatData()
    local staus = false
    if self.currSendChannel == system then
		self.menuSend:setEnabled(false)
		staus = true
	else
		self.menuSend:setEnabled(true)
	end
end

function ChatView:showChannelSel(isShow)
	if isShow then
		if not self.slctBg then
			self.slctBg = createScale9Sprite(self.baseNode,"res/chat/tips.png",cc.p(105,75),cc.size(152,300),cc.p(0.5,0.0))
			self.slctBg:setLocalZOrder(3)

			local titles = {
						game.getStrByKey("chat_trumpet"),
						game.getStrByKey("chat_world"),
						game.getStrByKey("chat_faction"),
						game.getStrByKey("chat_teamup"),
						--game.getStrByKey("chat_personal"),
					}
			local items={}
			local changeChnlFun = function(sender)
				for i = trumpet, teamup do
					if items[i] == sender then
						self:setCurrChannel(i)
						self:showChannelSel(false)
						break
					end
				end
			end
			for i = trumpet, teamup do
				items[i] = createTouchItem(self.slctBg,"res/component/button/15.png",cc.p(76,300-i*60),changeChnlFun)
				items[i]:setScaleX(130/164)
    			createLabel(items[i], titles[i],cc.p(82,26), cc.p(0.5,0.5),21,true):setScaleX(164/120)
			end

			self.slctBg:setScaleY(0)
			self.slctBg:runAction(cc.ScaleTo:create(0.2, 1))
		end
	else
		if self.slctBg and self.slctBg:getParent() then
			function  removeFunc( )
				removeFromParent(self.slctBg)
				self.slctBg = nil
			end
			self.slctBg:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 1.0, 0.0), cc.CallFunc:create(removeFunc)))
		end
	end
end

function ChatView:setCurrChannel(channel)
	local picName = {"curr_trumpet","curr_world","curr_faction","curr_teamup","curr_personal"}
	self.currSendChannel = channel
	if self.currChannelSpr and self.currChannelSpr:getParent() then
		self.currChannelSpr:setTexture("res/chat/"..picName[channel]..".png")
	else
		self.currChannelSpr = createSprite(self.baseNode,"res/chat/"..picName[channel]..".png",cc.p(95,55))
	end
end

function ChatView:showSettingView(startPos)
	-- local settingBg = cc.Sprite:create("res/common/4-1.png")
	local settingBg = cc.Sprite:create("res/common/5.png")
	local bgSize = settingBg:getContentSize()
	local titleBg = createSprite( settingBg , "res/common/1.png" , cc.p( bgSize.width/2  , bgSize.height-38))
	titleBg:setScaleX( 1.06 )
	createLabel(settingBg, game.getStrByKey("chat_setting"), cc.p(bgSize.width/2 , bgSize.height-24), cc.p(0.5,1), 22):setColor(self.colors[8])

	local closeFunc = function ()
		local settingToSave = ""
		for i=1,5 do
			if self.settingArrow[i]:isVisible() then
				settingToSave = settingToSave.."1"
			else
				settingToSave = settingToSave.."0"
				if G_CHAT_INFO[11] then
					for j=1,#G_CHAT_INFO[11] do
						if G_CHAT_INFO[11][j] then
							if G_CHAT_INFO[11][j].channelId == i+1 then
								table.remove(G_CHAT_INFO[11],j)
							end
						end
					end
				end
			end
		end
		G_CHAT_INFO.chatSetting = settingToSave
		setLocalRecordByKey(2,"chat_setting",settingToSave)
		self:updateDisplayData(1)
		removeFromParent(settingBg)
	end
	local closeBtn = createTouchItem(settingBg,"res/common/13.png",cc.p(settingBg:getContentSize().width- 35 ,settingBg:getContentSize().height - 35 ),closeFunc)
	closeBtn:setScale( 0.8 )

	local addLabel = createLabel
	local addSprite = createSprite
	addLabel(settingBg, game.getStrByKey("chat_settingPrompt"), cc.p(bgSize.width/2,bgSize.height-80), cc.p(0.5,1), 23)
	
	if not G_CHAT_INFO.chatSetting then
		G_CHAT_INFO.chatSetting = getLocalRecordByKey(2,"chat_setting","11111")
		if string.len(G_CHAT_INFO.chatSetting) ~= 5 then
			G_CHAT_INFO.chatSetting = "11111"
		end
	end

	for i=0,4 do
		local y,x = math.modf(i/3)
		x = x*3
		local addr = cc.p(110+x*150,140-y*70)
		local label = addLabel(settingBg, self.titles[i+2], addr , cc.p(0.5,0.5), 25)
		label:setColor(MColor.green)
		addSprite(settingBg,"res/teamup/5.png",cc.p(addr.x-65,addr.y))
		self.settingArrow[i+1] = addSprite(settingBg,"res/teamup/6.png",cc.p(addr.x-65,addr.y) )
		--读取上次配置
		local subStr = string.sub(G_CHAT_INFO.chatSetting,i+1,i+1)
		if subStr=="0" then
			self.settingArrow[i+1]:setVisible(false)
		end
	end

	Manimation:transit(
	{
		ref = self,
		node = settingBg,
		curve = "-",
		sp = startPos,
		zOrder = 1,
		swallow = true,
	})
	
	local flag = false
	local  listenner = cc.EventListenerTouchOneByOne:create()
    listenner:setSwallowTouches(true)
    listenner:registerScriptHandler(function(touch, event)
    									if not cc.rectContainsPoint(settingBg:getBoundingBox(),touch:getLocation()) then
    										flag = true
    									else
    										local pt = settingBg:convertTouchToNodeSpace(touch)
    										for i=1,5 do
    											if cc.rectContainsPoint(self.settingArrow[i]:getBoundingBox(),pt) then
    												self.settingArrow[i]:setVisible(not self.settingArrow[i]:isVisible())
    												break
    											end
    										end
    									end
    									return true 
    								end,cc.Handler.EVENT_TOUCH_BEGAN)
     listenner:registerScriptHandler(function(touch, event)
     									if not cc.rectContainsPoint(settingBg:getBoundingBox(),touch:getLocation()) and flag == true then
     										removeFromParent(settingBg)
     									end 
     								end,cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, settingBg)  
end

function ChatView:updateDisplayData(channel, isTrumpet, trumpetItem)
	--dump(channel)
	--dump(isTrumpet)
	if channel == world or channel == allChannel then
		--小喇叭更新
		if isTrumpet then
			self.trumpetNode:removeAllChildren()
			self.trumpetId = nil

			local x = 130
			local item = G_CHAT_INFO[world][#G_CHAT_INFO[world]]

			if trumpetItem then
				item = trumpetItem
			end
			
			-- if item.vipLvl and item.vipLvl > 0 then
			-- 	local vipIcon = createSprite(self.trumpetNode,"res/layers/vip/"..item.vipLvl..".png",cc.p(x, 0),cc.p(0, 0))
			-- 	x = x + vipIcon:getContentSize().width
			-- end

			-- cclog("~~~~~~~~~~~~~~~~~~~~~~~"..tostring(item.factionType))
			-- if item.factionType and item.factionType > 0 then
			-- 	local cs = {MColor.purple,MColor.purple,MColor.red,MColor.red}
			-- 	local titleStr = game.getStrByKey("chat_factionType"..item.factionType)
			-- 	local titleLab = createLabel(self.trumpetNode, titleStr, cc.p(x,0), cc.p(0,0.5), 20)
			-- 	titleLab:setColor(cs[item.factionType])
			-- 	x = titleLab:getContentSize().width+x+2
			-- end

			G_CHAT_INFO.trumpet = item
			self.trumpetId = item.usrId

			--万人迷
			local isCharmRankTop = false
			if G_CharmRankList and G_CharmRankList.ListData and #G_CharmRankList.ListData > 0 then
				local data = G_CharmRankList.ListData[1]
				if data[2] == item.usrName then
					isCharmRankTop = true
				end
			end
		    local strName = "【"..item.usrName.."】".."："
		    local textColor = MColor.white
		  	if isCharmRankTop then
		  		strName = "【".. (item.usrName or "" ).."】" .. "(" ..game.getStrByKey("charm_week_top") ..")："
		  		textColor = MColor.deep_purple
		  	end

	 		local richText = require("src/RichText").new(self.trumpetNode, cc.p(x, 0), cc.size(230, 30), cc.p(0, 0), 20, 20, MColor.lable_yellow)
		    richText:setAutoWidth()
		    --richText:addText("【"..item.usrName.."】", self.colors[6], true)
		    
		    richText:addTextItem(strName, MColor.lable_yellow, true, true, true, 
		    	function() 
			    		print("item.usrName = "..item.usrName) 
			    		if item.usrName and item.usrName ~= MRoleStruct:getAttr(ROLE_NAME) then
			    			self:showOperationPanel(item.usrName) 
			    		end
		    		end)
		    richText:format()
		    richText:setPosition(cc.p(x, 0))

     		if item.type ~= 3 then 
				-- local parseData = {}
		  --    	if string.sub(item.text,1,2) == "*&" then
		  --    		parseData = require("src/RichText").parseLink(G_CHAT_INFO[7].text)
		  --    	end

		  --    	if parseData.isLink then
		     		
		  --    		local propOp = require("src/config/propOp")
		  --    		local tNameColor = {
				-- 		[0] = MColor.red,
				-- 		[1] = MColor.white,
				-- 		[2] = MColor.green,
				-- 		[3] = MColor.blue,
				-- 		[4] = MColor.purple,
				-- 		[5] = MColor.orange,
				-- 	}

				-- 	local func = function()
				-- 		cclog(tostring(parseData.isSpecial))
				-- 		if parseData.isSpecial == "false" then
				-- 			local Mtips = require "src/layers/bag/tips"
				-- 			Mtips.new(
				-- 			{ 
				-- 				protoId = tonumber(parseData.protoId),
				-- 				--grid = gird,
				-- 				pos = cc.p(0, 0),
				-- 				--actions = actions,
				-- 			})
				-- 		else
				-- 			g_msgHandlerInst:sendNetDataByFmtExEx(CHAT_CS_CLICKANCHOR,"iiisc",G_ROLE_MAIN.obj_id,tonumber(parseData.ownerId),tonumber(parseData.protoId),tonumber(parseData.posIndex),tonumber(parseData.bagId))
				-- 		end
				-- 	end
				-- 	local richText = require("src/RichText").new(self.trumpetNode, cc.p(0,-30), cc.size(350, 30), cc.p(0.0, 1.0), 22, 20, MColor.white)
				-- 	richText:addTextItem("【"..parseData.name.."】", tNameColor[tonumber(parseData.qualityId)], true, true, true, func)
				-- 	richText:format()
		  --    		-- local obj,line = createLinkLabel(self.trumpetNode, "【"..parseData.name.."】", pos, cc.p(0.0,0.5), 20, nil,nil,tNameColor[tonumber(parseData.qualityId)],nil,func,true)
	   --   			-- obj:setLocalZOrder(1)
	   --   			-- --obj:setTag(1001)
	   --   			-- line:setLocalZOrder(1)
	   --   			--line:setTag(1001)
	   --   		else
					local richText = require("src/RichText").new(self.trumpetNode, cc.p(0, 0), cc.size(350, 30), cc.p(0, 1), 22, 18, MColor.white)
				    richText:addText(item.text, textColor, false)
				    richText:format()
	     		-- end
	     	else
	     		print("caohaobin        传音号角 语音")
	     		local spr, richText = require("src/layers/chat/Microphone"):createVoiceLabel(self.trumpetNode, item.text, item.fileid, item.timeLen, cc.p(0, 0), cc.p(0.0,1),self.colors[6],30,channel)
                removeFromParent(richText)
	     		-- self.trptVoice:setLocalZOrder(1)
	     	end
		end
	end

	--很多行为会同时带来系统消息 防止系统消息阻止当前频道刷新
	if channel ~= system then
		self.isUpdateView = false
	end

	if self.currDisChannel == allChannel or channel == self.currDisChannel then
		self.isUpdateView = true 		
	end

	if self.updateViewTimer == nil then
		self.updateViewTimer = startTimerAction(self, 0.5, true, 
			function() 
				if self.isUpdateView then
					self:refreshChatData() 
				end
				self.isUpdateView = false
			end)
	end
end

function ChatView:deleteChatById(userId)
	log("ChatView:deleteChatById userId = "..tostring(userId))
	for i=1,11 do
		if G_CHAT_INFO[i] then
			local tab = G_CHAT_INFO[i]
			local removeTab = {}
			for i,v in ipairs(tab) do
				dump(v.usrId)
				if v.usrId and v.usrId == userId then
					-- log("table.remove(tab, i) 1111111111111111111111")
					-- dump(table.remove(tab, i))
					-- dump(G_CHAT_INFO)
					removeTab[i] = true
				end
			end

			for i=#tab,1,-1 do
				if removeTab[i] then
					table.remove(tab, i)
				end
			end

			dump(G_CHAT_INFO)
		end
	end
	self:cleanCellContent()
	self:updateDisplayData(self.currDisChannel)

	if self.trumpetId and self.trumpetId == userId then
		self.trumpetNode:removeAllChildren()
	end
end

function ChatView:updateUpDownNum(id,upNum,downNum)
	local upTag = id+100000000
	local downTag = id+200000000
	local upLab = self.node:getChildByTag(upTag)
	local temp = {}
	while upLab do
		table.insert(temp,upLab)
		upLab:setString(tostring(math.min(upNum,99)))
		upLab:setTag(0)
		upLab = self.node:getChildByTag(upTag)
	end
	for k,v in pairs(temp) do
		v:setTag(upTag)
	end
	local downLab = self.node:getChildByTag(downTag)
	temp = {}
	while downLab do
		table.insert(temp,downLab)
		downLab:setString(tostring(math.min(downNum,99)))
		downLab:setTag(0)
		downLab = self.node:getChildByTag(downTag)
	end
	for k,v in pairs(temp) do
		v:setTag(downTag)
	end
end

function ChatView:showOperationPanel(name)
	local func = function(tag)
		local switch = {
			[1] = function() 
				PrivateChat(name)
			end,
			[2] = function() 
				LookupInfo(name)
			end,
			[3] = function() 
			  	InviteTeamUp(name)
			end,
			[4] = function()
				AddFriends(name)
			end,
			[5] = function() 
			  	AddBlackList(name)
			end,
			[6] = function() 
				SendFlower(name)
			end,
            [7] = function() 
			  	--发送邀请入会协议
                g_msgHandlerInst:sendNetDataByTableExEx(FACTION_CS_INVITE_JONE, "FactionInviteJoin", {opRoleName=name})
			end,
			
			-- [6] = function()
			--   	local relation = 1
			-- 	if self.showData.roleData.killMe then
			-- 		relation = 2
			-- 	end
			--   	g_msgHandlerInst:sendNetDataByFmtExEx(RELATION_CS_REMOVERELATION, "iic", G_ROLE_MAIN.obj_id, self.showData.roleData.roleId, relation)
			--   	addNetLoading(RELATION_CS_REMOVERELATION, RELATION_SC_REMOVERELATION_RET)
			-- end,
		}
		if switch[tag] then 
			switch[tag]() 
		end
		removeFromParent(self.operateLayer)
		self.operateLayer = nil
	end
	local menus = {
		{game.getStrByKey("chat_personal"), 1, func},
		{game.getStrByKey("look_info"), 2, func},
		{game.getStrByKey("re_team"), 3, func},
		{game.getStrByKey("addas_friend"), 4, func},
		{game.getStrByKey("add_blackList"), 5,func},
		{game.getStrByKey("send_flower_text"), 6, func},
        {game.getStrByKey("faction_invite_member"), 7, func},
		
		--{game.getStrByKey("shield"), 5, func},
	}

	if G_CONTROL:isFuncOn( GAME_SWITCH_ID_FLOWER ) == false then
		table.remove(menus, 6)
	end

    if G_FACTION_INFO == nil or G_FACTION_INFO.job == nil or G_FACTION_INFO.job < 3 then
		table.remove(menus, 7)
	end
    self.operateLayer = require("src/OperationLayer").new(G_MAINSCENE, 1, menus, "res/component/button/49", "res/common/scalable/7.png")
end

function ChatView:createChatTuto()
	 --添加滑动引导
    if getLocalRecord("chatTuto") ~= true and G_CHAT_INFO and G_CHAT_INFO.showTuto ~= false then
    	self.chatTutoSprite = createSprite(self, "res/chat/tuto.png", cc.p(self.bg:getContentSize().width/2+50, self.bg:getContentSize().height/2), cc.p(0.5, 0.5))
    	if self.chatTutoSprite then
	    	createLabel(self.chatTutoSprite, game.getStrByKey("chat_tuto_tip"), getCenterPos(self.chatTutoSprite), cc.p(0.5, 0.5), 20, true, nil, nil, MColor.black)

	    	self.chatTutoSprite:setOpacity(0.1)

	    	self.chatTutoSprite:runAction(cc.Sequence:create(
	    		cc.FadeIn:create(0.5),
	    		cc.DelayTime:create(1),
	    		cc.FadeOut:create(0.2),
	    		cc.RemoveSelf:create()
	    		))
	    end

	    G_CHAT_INFO.showTuto = false

    	--self.chatTutoSprite:setOpacity(255*0.7)
    end
end

function ChatView:show()
	if self.isShow == true then 
		return
	end
	self.isUpdateScrollView = true

	self.isShow = true

	self:setLocalZOrder(201)
	self:setLocalZOrder(200)

	self:updateScrollView()

    local action_show = cc.Sequence:create(cc.CallFunc:create(function() self:setVisible(true) end), cc.MoveTo:create(0.25, cc.p(0, 0)))
    action_show:setTag(tag_slideChatAction)
	self:runAction(action_show)

    self:updatePrivateBtn()

   	self:createChatTuto()
    self:setInputShowType()
    if self:getChildByTag(commConst.TAG_CHAT_PRIVATECHATLISTVIEW) then
        --每次重新打开都会收起私聊列表
        self:privateChatListBtnCallBack()
    end
-------------------------------------------------------这里不需要了----------------------------------
--[[	if self.socialNode and self.socialNode.reloadNetData then
		self.socialNode:reloadNetData()
	end]]
end

function ChatView:hide(isWithAction)
	--self:cleanCellContent()
	
	self.isShow = false

	if isWithAction then
        local action_hide = cc.Sequence:create(cc.MoveTo:create(0.1, cc.p(-display.width, 0)), cc.CallFunc:create(function() self:setVisible(false) end))
        action_hide:setTag(tag_slideChatAction)
        self:stopActionByTag(tag_slideChatAction)
	    self:runAction(action_hide)
	else
		self:setPosition(cc.p(-display.width, 0))
		self:setVisible(false)
	end
end

function ChatView:clearCellContent() 
	for k,v in pairs(self.cellContent) do
		log("k = "..k)
		--v:release()
	end
	self.cellContent = {}
end

function ChatView:hideCellContent() 
	for k,v in pairs(self.cellContent) do
		if type(v) == "table" then
			local tab = v
			for k,v in pairs(tab) do
				if v.nameRichText then
					v.nameRichText:setVisible(false)
				end
				if v.richText then
					v.richText:setVisible(false)
				end

				if v.spr then
					v.spr:setVisible(false)
				end
				if v.textBg then
			   		v.textBg:setVisible(false)
			   	end
			   	if v.textBg_arrow then
			   		v.textBg_arrow:setVisible(false)
			   	end
			end
		end
	end
end

function ChatView:cleanCellContent() 
	local function isDataExist(data)
		-- dump(data,"清理聊天信息")
        if G_CHAT_INFO[data.channelId] then
            --为了保证每个私聊对象都能显示最多30条聊天消息，需要对私聊频道根据人名做区分，任何一个私聊对象都能保存最多30条
            if data.channelId == personal then
                local usrNameAnotherOne = (data.usrName == MRoleStruct:getAttr(ROLE_NAME) and data.targetName or data.usrName)
                local chatCount = 0
                local i = table.size(G_CHAT_INFO[data.channelId])
                while chatCount < 30 and i > 0 do
                    if G_CHAT_INFO[data.channelId][i] and (G_CHAT_INFO[data.channelId][i].usrName == usrNameAnotherOne or G_CHAT_INFO[data.channelId][i].targetName == usrNameAnotherOne) then
                        chatCount = chatCount + 1
                    end
                    if G_CHAT_INFO[data.channelId][i] == data then
                        return true
                    end
                    i = i - 1
                end
                return false
            end
            local chatCount = 0
            local i = table.size(G_CHAT_INFO[data.channelId])
            while chatCount < 30 and i > 0 do
                if G_CHAT_INFO[data.channelId][i] then
                    chatCount = chatCount + 1
                end
                if G_CHAT_INFO[data.channelId][i] == data then
                    return true
                end
                i = i - 1
            end
        end
		return false
	end
	-- dump(self.cellContent,"111111111111111111111")
	for k,v in pairs(self.cellContent) do
		if type(v) == "table" then
			local tab = v
			for i,v in pairs(tab) do
				if v.data and isDataExist(v.data) == false then
					if v.nameRichText then
						removeFromParent(v.nameRichText)
					end
					if v.richText then
						removeFromParent(v.richText)
					end
					if v.spr then
						removeFromParent(v.spr)
					end
					if v.textBg then
				   		removeFromParent(v.textBg)
				   	end
				   	if v.textBg_arrow then
				   		removeFromParent(v.textBg_arrow)
				   	end
					table.remove(tab, i)
				end
			end
		end
	end
end

function ChatView:updatePrivateBtn()	
    if self.selTabNode == nil or G_CHAT_INFO.unReadPrivateRecord == nil then
        return
    end

    if self.isShow == true and ( self.currDisChannel == personal or self.currDisChannel == allChannel) then
        G_CHAT_INFO.unReadPrivateRecord = 0;
        G_MAINSCENE:updateChatStartBtn();
    end 

    local perTab = self.selTabNode:getChildByTag(7)
    if perTab == nil then
        return
    end

    local numNode = perTab:getChildByTag(99)
    if numNode == nil then 
        numNode = cc.Node:create()
        numNode:setPosition(90,60)
        numNode:setTag(99)
	    perTab:addChild(numNode, 1)
        
        local la = createLabel(numNode, " " ,cc.p(-1,-2), nil, 16, true,nil,nil,MColor.yellow)
        la:setTag(1)
        la:setAnchorPoint(cc.p(0.5,0.5))

        createSprite(numNode, "res/component/flag/red.png", cc.p(0, -5), cc.p(0.5, 0.5), -1)
    end

    if G_CHAT_INFO.unReadPrivateRecord == 0 then
        numNode:setVisible(false)
        return;
    else
        numNode:setVisible(true)
    end

    local str = tonumber(G_CHAT_INFO.unReadPrivateRecord)
    if G_CHAT_INFO.unReadPrivateRecord > 9 then
        str = "9+";
    end
    numNode:getChildByTag(1):setString(str)
end

function ChatView:networkHander(buff,msgid)
end

function ChatView:setInputShowType(showType)
    if showType == nil then
        if self.currSendChannel == system then
            showType = 3
        elseif self.currSendChannel == teamup then
            if G_TEAM_INFO.has_team then
                showType = self.curInputShowType
            else
                showType = 4
            end
        elseif self.currSendChannel == faction then
            if G_FACTION_INFO.facname then
                showType = self.curInputShowType
            else
                showType = 5
            end
        else
            showType = self.curInputShowType
        end
    end
    
    if showType == 1 then
        self.editeBg:setVisible(true)
        --self.voiceBtn:setVisible(false)
        self.moreBtn:setVisible(true)
        self.voiceSetBtn:setVisible(false)
        self.keyboardBtn:setVisible(false)
        self.microBtn:setVisible(true)
        self.menuSend:setVisible(true)
        self.microphone:setVisible(false)
        self.cannotTalkTips:setVisible(false)
        self.curInputShowType = 1
    elseif showType == 2 then
        self.editeBg:setVisible(false)
        --self.voiceBtn:setVisible(true)
        self.moreBtn:setVisible(false)
        self.voiceSetBtn:setVisible(true)
        self.keyboardBtn:setVisible(true)
        self.microBtn:setVisible(false)
        self.menuSend:setVisible(false)
        self.microphone:setVisible(true)
        self.cannotTalkTips:setVisible(false)
        self.curInputShowType = 2
    else
        self.editeBg:setVisible(false)
        --self.voiceBtn:setVisible(false)
        self.moreBtn:setVisible(false)
        self.voiceSetBtn:setVisible(false)
        self.keyboardBtn:setVisible(false)
        self.microBtn:setVisible(false)
        self.menuSend:setVisible(false)
        self.microphone:setVisible(false)
        self.cannotTalkTips:setVisible(true)
        --[[if showType == 3 then
            self.cannotTalkTips:setString(game.getStrByKey("chat_cannot_talk_tops1"))
        elseif showType == 4 then
            self.cannotTalkTips:setString(game.getStrByKey("chat_cannot_talk_tops2"))
        elseif showType == 5 then
            self.cannotTalkTips:setString(game.getStrByKey("chat_cannot_talk_tops3"))
        end
        ]]
    end
end

return ChatView