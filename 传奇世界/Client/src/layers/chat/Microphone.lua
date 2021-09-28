local Microphone= class("Microphone", function() return  cc.Node:create() end )

local touchtime1,touchtime2 = 0,0
local touchtime3,touchtime4 = 0,0
local microList = {}

function Microphone:ctor(parent,pos,par,chanle_id,btnfile)
    --¼ÓÈë¸¸½Úµã
	self:setPosition(pos)
    self:setLocalZOrder(20)
   	if parent then
   		parent:addChild(self,8) 
   	end

    self.par = par
    self.chanle_id = chanle_id

   	self.scheduler = cc.Director:getInstance():getScheduler()
   	self.myUpdate_overtime = nil
   	self.myUpdate = nil
   	self.myUpdate_end = nil
    self.has_dowm = false
    self.touchVoice = nil
    self.canTouchVoiceBtn = true
    self.canTouchVoiceBtn_end = true
    self.canMoveHintVoiceBtn = false
    self.canRevcTouch = true
	 	
    if btnfile then
        self.voiceBtn = GraySprite:create(btnfile)
    else
        self.voiceBtn = GraySprite:create("res/chat/voiceinput.png")
        self.label_voice_btn = createLabel(self.voiceBtn, game.getStrByKey("chat_voice_press"),getCenterPos(self.voiceBtn),cc.p(0.5,0.5), 22,nil,nil,nil,MColor.lable_yellow)
    end

   	self.voiceBtn:setPosition(cc.p(0,0))
   	self:addChild(self.voiceBtn)

    local function updateOverTime()
	    self:upFunc(false,1,true)
	    if self.scheduler and self.myUpdate_overtime then
		    self.scheduler:unscheduleScriptEntry(self.myUpdate_overtime)
		    self.myUpdate_overtime = nil
	    end
    end

    local function updateCanTouch()
	    self.canTouchVoiceBtn = true
	    if self.scheduler and self.myUpdate then
		    self.scheduler:unscheduleScriptEntry(self.myUpdate)
		    self.myUpdate = nil
	    end
    end

    local function updateCanTouch_end()
	    self.canTouchVoiceBtn_end = true
	    if self.scheduler and self.myUpdate_end then
		    self.scheduler:unscheduleScriptEntry(self.myUpdate_end)
		    self.myUpdate_end = nil
	    end
    end

    local function onTouchBegan(touch, event)                           
           local touchTemp = touch       
           if self:isVisible() then			                  
                local pt = touch:getLocation()
			    pt = self.voiceBtn:getParent():convertToNodeSpace(pt)
                local rectOrigin = self.voiceBtn:getBoundingBox()
                if cc.rectContainsPoint(rectOrigin,pt) then
                    local function start()
                        self.m_startAction = nil
                        if self.canTouchVoiceBtn and self.canTouchVoiceBtn_end then 
                            local commConst = require("src/config/CommDef")
                            local c_id = self.chanle_id or (self.par and self.par.currSendChannel) or 4
   			                if c_id ~= commConst.Channel_ID_System then
	   			                if getGameSetById(GAME_SET_VOICE_REALVOICE_OPEN) > 0 then
                                     TIPS( { type = 1 , str = game.getStrByKey( "chat_voice_set_tips5" ) }  )
                                     return true
                                end
                
                                touchtime3 = os.time()
				                if touchtime3 - touchtime4 > 2 then
					                touchtime4 = touchtime3
		   			                if self.touchVoice == nil then
		   				                self:downFunc()
		   				                self.touchVoice = touchTemp
		   				                self.canTouchVoiceBtn = false
		   				                self.myUpdate = self.scheduler:scheduleScriptFunc(updateCanTouch, 2.0, false)
		   				                self.myUpdate_overtime = self.scheduler:scheduleScriptFunc(updateOverTime, 8.0, false)
		   			                end
		   		                else
		   			                TIPS( { type = 2 , str = game.getStrByKey("chat_speakTooQuick") }  )
				                end
	   		                end
                        end
                    end

                    if self.canRevcTouch then
                        self.m_startAction = startTimerAction(self, 0.6, false, start)
                    end

                    return true
                end
	        end

		    return false	
    end

    local function onTouchMoved(touch, event)
	    if self.canMoveHintVoiceBtn and self.touchVoice then
	    	local pt = touch:getLocation()
            pt = self.voiceBtn:getParent():convertToNodeSpace(pt)
            local rectOrigin = self.voiceBtn:getBoundingBox()
            if cc.rectContainsPoint(rectOrigin, pt) then
                if self.center_str  then
                	self.center_str:setString(game.getStrByKey("chat_startRec"))
                	self.center_str:setColor(MColor.green)
                end
            else
            	if self.center_str then
                	self.center_str:setString(game.getStrByKey("chat_cancelSend"))
                	self.center_str:setColor(MColor.red)
                end
            end
	    end
    end

    local function onTouchEnded(touch, event)
        local pt = touch:getLocation()
        if self.m_startAction then
            self:stopAction(self.m_startAction)
            self.m_startAction = nil
        end
	    if self.touchVoice and tolua.cast(self.touchVoice, "cc.Touch") then
            local ptVoice = self.touchVoice:getLocation()
		    if pt.x == ptVoice.x and pt.y == ptVoice.y then
                local isSendCanceled = 0
                pt = self.voiceBtn:getParent():convertToNodeSpace(pt)
                local rectOrigin = self.voiceBtn:getBoundingBox()
                if not cc.rectContainsPoint(rectOrigin, pt) then
                    isSendCanceled = 1
                end
                self:upFunc(false, isSendCanceled, false)
                self.touchVoice = nil
                self.canTouchVoiceBtn_end = false
                self.myUpdate_end = self.scheduler:scheduleScriptFunc(updateCanTouch_end, 2.0, false)
            end
        else
            if self.par.onVoiceBtnClick then
                self.par:onVoiceBtnClick(self)
            end
	    end
    end

	local listener1 = cc.EventListenerTouchOneByOne:create()
    listener1:setSwallowTouches(true)
    listener1:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener1:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    listener1:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener1, self.voiceBtn)

    if Device_target ~= cc.PLATFORM_OS_WINDOWS and Device_target ~= cc.PLATFORM_OS_ANDROID then
    	local listenerLockScreen = cc.EventListenerCustom:create("iosLockVoice", function() require("src/layers/chat/Microphone"):onVoiceLock(str) end)
    	eventDispatcher:addEventListenerWithSceneGraphPriority(listenerLockScreen, self)
    end

    self:registerScriptHandler(function(event)
        if event == "enter" then  
            table.insert(microList, self)
        elseif event == "exit" then
            for k, v in pairs(microList) do
                if v == self then
                    table.remove(microList, k)
                    break
                end
            end
        end
    end)
end

function Microphone:addStartFunc()
    self.start_bg = createSprite(G_MAINSCENE, "res/chat/mk/bg2.png", g_scrCenter, nil, 300)
    self.center_str = createLabel(self.start_bg, game.getStrByKey("chat_startRec"), cc.p(95, 39), nil, 15)
    self.center_str:setColor(MColor.green)
    self.circle = createSprite(self.start_bg, "res/chat/mk/circle.png", cc.p(95, 95), cc.p(0.5, 0.5))
    self.circle:runAction(cc.RotateBy:create(8, 360))
    self:startOrStopBgMusic(false)
end

function Microphone:addEndFunc(iscancel,isOverTime)
    if self.center_str then
        if not isOverTime then
            if iscancel == 0 then
                self.center_str:setString(game.getStrByKey("chat_recEnd"))
                self.center_str:setColor(MColor.green)
            else
                self.center_str:setString(game.getStrByKey("chat_cancelRec"))
                self.center_str:setColor(MColor.red)
            end
        else
            self.center_str:setString(game.getStrByKey("chat_recOverTime"))
            self.center_str:setColor(MColor.red)
        end
    end

    local endFunc = function()
        if self.start_bg then
            removeFromParent(self.start_bg)
            self.start_bg = nil
            self.center_str = nil
            self.circle = nil
        end
        self:startOrStopBgMusic(true)
    end
    performWithDelay(self, endFunc, 1.0)
end

function Microphone:downFunc()
    self.has_dowm = true
    if Device_target == cc.PLATFORM_OS_ANDROID then
        local args = { true }
        local sigs = "(Z)V"
        local luaj = require "kuniu/cocos/cocos2d/luaj"
        luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "setVoiceLockStatus", args, sigs)

        cclog("yuexiaojun StartRecord")
        VoiceApollo:StartRecord()
    elseif Device_target ~= cc.PLATFORM_OS_WINDOWS then
        VoiceApollo:StartRecord()
    end

    self.canMoveHintVoiceBtn = true

    self:addStartFunc()
end

function Microphone:upFunc(isLocked, isCanceled, isOverTime)
    if self.myUpdate_overtime and self.scheduler then
        self.scheduler:unscheduleScriptEntry(self.myUpdate_overtime)
        self.myUpdate_overtime = nil
    end

    if not self.has_dowm then
        return
    end
    self.has_dowm = false
    self.canMoveHintVoiceBtn = false

    if self.circle then
    	self.circle:stopAllActions()
    end

    if isLocked == false then
        self:addEndFunc(isCanceled, isOverTime)
    end

    if Device_target == cc.PLATFORM_OS_ANDROID then
        local args = { false }
        local sigs = "(Z)V"
        local luaj = require "kuniu/cocos/cocos2d/luaj"
        luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "setVoiceLockStatus", args, sigs)

        local onEnd = function(fileid, timeLen)
            if isCanceled < 1 then
                cclog("yuexiaojun StopRecord onEnd fileid=%s, timeLen=%d", fileid, timeLen)
                self:sendFunc(fileid, timeLen)
            end
        end

         cclog("yuexiaojun StopRecord")

        VoiceApollo:SetUploadDoneCallback(onEnd)
        VoiceApollo:StopRecord()
    elseif Device_target ~= cc.PLATFORM_OS_WINDOWS then
        local onEnd = function(fileid, timeLen)
            if isCanceled < 1 then
                self:sendFunc(fileid, timeLen)
            end
        end

        VoiceApollo:SetUploadDoneCallback(onEnd)
        VoiceApollo:StopRecord()
    else
        if isCanceled < 1 then
            self:sendFunc("voice")
        end
    end
end

--·¢ËÍº¯Êý
function Microphone:sendFunc(fileid, timeLen)
    local commConst = require("src/config/CommDef")
    local c_id = self.chanle_id or(self.par and self.par.currSendChannel) or 4
    if c_id ~= commConst.Channel_ID_System then
        local name_str = nil
        if c_id == commConst.Channel_ID_Privacy then
            local text = self.par.chatEditCtrl:getText()
            if string.sub(text, 1, 1) ~= "@" then
                return
            end

            local pos = string.find(text, " ")
            if pos == nil then
                return
            end

            name_str = string.sub(text, 2, pos - 1)
        end

        local t = { }
        t.channel = c_id
        t.message = ""
        t.fileid = fileid
        t.targetName = name_str
        t.voicelen = timeLen
        g_msgHandlerInst:sendNetDataByTableExEx(CHAT_CS_SENDCHATMSG, "SendChatProtocol", t)

        if self.par.onLastSend then
            self.par:onLastSend(self)
        end
    end
end

function Microphone:onVoiceLock(args)
    --ÒÀ´Îµ÷ÓÃ¸÷ÊµÀýµÄvoiceBtnEvent
    for k, v in pairs(microList) do
        v:voiceBtnEvent(args)
    end
end

function Microphone:voiceBtnEvent(args)

	if self.touchVoice ~= nil then
		self.touchVoice = nil
	end
	
	if self.center_str then
		removeFromParent(self.center_str)
		self.center_str = nil
	end
	
	if self.start_bg then
		removeFromParent(self.start_bg)
		self.start_bg = nil
        self.circle = nil
        self.center_str = nil
	end

	self:upFunc(true,1,false)
end

function Microphone:startOrStopBgMusic(start)
	if start then
		if G_MAINSCENE and getGameSetById(GAME_SET_ID_CLOSE_MUSIC) == 1 then
			local q_music = getConfigItemByKey("MapInfo","q_map_id",G_MAINSCENE.mapId,"q_music")
			if q_music then
				AudioEnginer.playMusic("sounds/mapMusic/"..q_music..".mp3",true)
			end
		end
		if getGameSetById(GAME_SET_ID_CLOSE_VOICE) == 1 then
			AudioEnginer.setIsNoPlayEffects(false)
		end
	else
		if getGameSetById(GAME_SET_ID_CLOSE_MUSIC) == 1 then
			AudioEnginer.stopMusic()
		end
		if getGameSetById(GAME_SET_ID_CLOSE_VOICE) == 1 then
			AudioEnginer.setIsNoPlayEffects(true)
		end
	end
end

function Microphone:getShieldMean(mean)
    mean = DirtyWords:checkAndReplaceDirtyWords(mean, "****")
	return mean
end

function Microphone:createVoiceLabel(parent, text, fileid,timeLen, pos, anchor,color,maxwidth,channel)
	local spr,lab
	if fileid then
        if timeLen == nil then timeLen = 0 end
		local width = 50 + timeLen*6
        if width > 120 then width = 120 end
		local callback = function()
			touchtime1 = os.time()
			if touchtime1 - touchtime2 > 2 then
				touchtime2 = touchtime1
			else
				return
			end

			if not (g_Channel_tab and g_Channel_tab.voice) then
				TIPS( { type = 1 , str = game.getStrByKey("chat_currVerNotSupport") }  )
				return
			elseif channel and channel == 6 then
				TIPS( { type = 1 , str = game.getStrByKey("chat_warn") }  )
				return
			end

		    
            local eff = Effects:create(false)
			eff:playActionData("mkplayeffect", 2 , 0.3 , 100 )
	        eff:setPosition(cc.p(-10000,17))        
			spr:addChild( eff )

            local onBegin = function()
                eff:setPosition(cc.p(width/2,17)) 
            end

            local onEnd = function()
                removeFromParent(eff)
            end

		   	if Device_target == cc.PLATFORM_OS_ANDROID then               
                cclog("yuexiaojun G_MAINSCENE.ChatAutoPlayLayer:addPlayMsg ") 
                G_MAINSCENE.ChatAutoPlayLayer:addPlayMsg({type=3,fileid=fileid, onBegin=onBegin, onEnd=onEnd, timeLen=timeLen}, true) 
		    elseif Device_target ~= cc.PLATFORM_OS_WINDOWS then
                G_MAINSCENE.ChatAutoPlayLayer:addPlayMsg({type=3,fileid=fileid, onBegin=onBegin, onEnd=onEnd, timeLen=timeLen}, true)
			else
				TIPS( { type = 1 , str = game.getStrByKey("chat_voicePlay") }  )
		    end            
		end

		spr = createScale9SpriteMenu(parent, "res/chat/voiceBubble.png", cc.size(width,33),pos, callback)
		spr:setAnchorPoint(anchor or cc.p(0.5,0.5))	
        if timeLen then
			if timeLen < 1 then
				timeLen = 1
			end
			local m_time = "" .. timeLen .."s"
			local lab1 = createLabel(spr,m_time,cc.p(width+2,8),cc.p(0.0,0.0),15)
			if color then
				lab1:setColor(color)
			end
		end

		if text then
			local str = self:getShieldMean(text)
			local wth = maxwidth or 40
			--local sub_height = -50
			if string.utf8len(str) > wth then
				str = string.utf8sub(str,1,wth).."..."
				--if not color then 
					--str = "\n\n"..str
					--width = -20
				--end
			end
            
			lab = require("src/RichText").new(parent ,cc.p(0, 0), cc.size(300, 30), anchor, 26, 20, color)
			lab:setAutoWidth()
			lab:addText(str, color)
			lab:format()
		end
	end
	return spr,lab
end

return Microphone