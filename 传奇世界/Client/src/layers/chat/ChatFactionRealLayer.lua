local ChatFactionRealLayer = class("ChatFactionRealLayer", function() return cc.Layer:create() end)

function ChatFactionRealLayer:ctor(parent, pos)
    parent:addChild(self)
    self:setPosition(pos)
    self.curMode = -1 
    self.bOpen = false

    local openOrCloseRealVoice = function(isHide) 
         self.bOpen = not self.bOpen
         --开启或关闭micro
         if self.bOpen then
             cclog("yuexiaojun OpenMic ")
             VoiceApollo:OpenMic()
             self.voiceBtn:setTexture("res/chat/zhihui_openmic.png")
             local node = self.voiceBtn:getChildByTag(9)
             if node then
                 node:setVisible(true)
             end
         else
             cclog("yuexiaojun CloseMic ")
             VoiceApollo:CloseMic()
             self.voiceBtn:setTexture("res/chat/zhihui_closemic.png")
             local node = self.voiceBtn:getChildByTag(9)
             if node then
                 node:setVisible(false)
             end
         end

         self.voiceBtn:removeChildByTag(8)
    end

    --创建指挥mic按钮
    local createBtn = function() 
        self.voiceBtn = createTouchItem(self,"res/chat/zhihui_openmic.png",cc.p(76,86),openOrCloseRealVoice,true)       
        self.bOpen = true
        VoiceApollo:OpenMic() 
        cclog("yuexiaojun OpenMic ") 

        local eff = createSprite(self.voiceBtn, "res/chat/zhihui_openmic2.png", getCenterPos(self.voiceBtn), cc.p(0.5, 0.5))
        local action = cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(1,0),cc.FadeTo:create(1,255)))
        eff:runAction(action)
        eff:setTag(9)

        self:showTips(2)
    end


    --创建实时语音开关按钮
    local onSwitch = function() 
        if getGameSetById(GAME_SET_VOICE_REALVOICE_OPEN) > 0 then
            setGameSetById(GAME_SET_VOICE_REALVOICE_OPEN, 0, true)
        else
            setGameSetById(GAME_SET_VOICE_REALVOICE_OPEN, 1, true)
        end

        self.switchBtn:removeChildByTag(8)
    end
    self.switchBtn = createTouchItem(self,"res/chat/zhihui_close.png",cc.p(76,26),onSwitch,true) 
    self.switchBtn:setVisible(getGameSetById(GAME_SET_VOICE_V2W) > 0)
    self.switchBtnState = 0

    local update = function(dt) 
         if G_MAINSCENE == nil then
             return
         end
         
         --更新self.switchBtn
         if self.switchBtn:isVisible() then
             if getGameSetById(GAME_SET_VOICE_REALVOICE_OPEN) > 0 and self.switchBtnState == 0 then
                 self.switchBtn:setTexture("res/chat/zhihui_open.png")
                 self.switchBtnState = 1
             elseif getGameSetById(GAME_SET_VOICE_REALVOICE_OPEN) == 0 and self.switchBtnState == 1 then
                 self.switchBtn:setTexture("res/chat/zhihui_close.png")
                 self.switchBtnState = 0
             end
         end
         
         --如果没有验证，不更新
         if Device_target ~= cc.PLATFORM_OS_WINDOWS then
             if not G_FACTION_INFO.isSetAuthKey then                
                return
             end
         end

         --没有了行会，退出语聊，关闭实时语聊开关
         if G_FACTION_INFO.facname == nil then
             if G_FACTION_INFO.isInRealVoiceRoom then
                 sendExitVoiceRoom()
             end

             if getGameSetById(GAME_SET_VOICE_REALVOICE_OPEN) > 0 then
                 setGameSetById(GAME_SET_VOICE_REALVOICE_OPEN, 0)
             end
         end

         --指挥者创建房间
         if getGameSetById(GAME_SET_VOICE_REALVOICE_OPEN) > 0 and not G_FACTION_INFO.isHaveVoiceRoom and G_FACTION_INFO.zhihuiID and G_FACTION_INFO.zhihuiID == userInfo.currRoleStaticId then
             sendCreateVoiceRoom()
         end

         --模式更新
         if self.curMode ~= getGameSetById(GAME_SET_VOICE_REALVOICE_OPEN) then
             self.curMode = getGameSetById(GAME_SET_VOICE_REALVOICE_OPEN)
             if self.curMode > 0 then
                --实时语聊
                cclog("yuexiaojun VoiceApollo:SetMode(0)") 
                VoiceApollo:SetMode(0)
                VoiceApollo:OpenSpeaker()  
                VoiceApollo:OpenMic()     
            else
                --离线语聊
                if G_FACTION_INFO.isInRealVoiceRoom then
                     cclog("yuexiaojun VoiceApollo:sendExitVoiceRoom")
                     sendExitVoiceRoom()
                end

                cclog("yuexiaojun VoiceApollo:SetMode(2)")
                VoiceApollo:SetMode(2)
                cclog("yuexiaojun VoiceApollo:SetMode(2) end")
                --VoiceApollo:CloseSpeaker()
                --VoiceApollo:CloseMic()              
            end
         end  
         
         --实时语聊更新
         if self.curMode == 0 then
             if G_FACTION_INFO.isInRealVoiceRoom then
                 sendExitVoiceRoom()
             end
         else
             --更新网络类型的变化对语聊的影响
             if getNetworkType() ~= "WIFI" and getGameSetById(GAME_SET_VOICE_VOICE) == 0 then
                 if G_FACTION_INFO.isInRealVoiceRoom then
                     sendExitVoiceRoom()
                 end
             else
                 if G_FACTION_INFO.isHaveVoiceRoom and not G_FACTION_INFO.isInRealVoiceRoom then
                     sendJoinVoiceRoom()
                 end
             end
         end         
         
         local bShow = false
         if self.curMode > 0 and G_FACTION_INFO.isInRealVoiceRoom and G_FACTION_INFO.facname ~= nil and G_FACTION_INFO.zhihuiID and G_FACTION_INFO.zhihuiID == userInfo.currRoleStaticId then
             bShow = true
         end

         if bShow then
             if self.voiceBtn == nil then
                createBtn()
                self:startOrStopBgMusic(false)
             end

             --self.voiceBtn:setVisible(not require("src/base/BaseMapScene").full_mode)
             
         else
             if self.voiceBtn ~= nil then
                 removeFromParent(self.voiceBtn)
                 self.voiceBtn = nil 
                 self.bOpen = false
                 self:startOrStopBgMusic(true)
                 
                 --关闭micro
--                 if self.curMode == 0 then
--                     VoiceApollo:CloseMic()
--                 end
             end
         end   
         
         if not require("src/base/BaseMapScene").full_mode then
             if self.voiceBtn then self.voiceBtn:setPosition(cc.p(76, 86)) end
             self.switchBtn:setPosition(cc.p(76, 26))
            
         else
             if self.voiceBtn then self.voiceBtn:setPosition(cc.p(-1000, 86)) end
             self.switchBtn:setPosition(cc.p(-1000, 26))
         end  
    end
	
    self:registerScriptHandler(function(event)
        if event == "enter" then   
            self.schedulerHandle = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update, 0.3, false)
        elseif event == "exit" then
            if self.schedulerHandle then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerHandle)
                self.schedulerHandle = nil                
            end 
        end
    end)
    
end

function ChatFactionRealLayer:showTips(tipsType)
    local setID = nil
    local tips = nil
    local par = nil
    local offY = 0
    
    if tipsType == 1 then
        setID = GAME_SET_VOICE_RECVFACTION
        par = self.switchBtn
        tips = game.getStrByKey( "chat_voice_set_tips8" )
        offY = 4
    else
        setID = GAME_SET_VOICE_SHOWFACTION
        par = self.voiceBtn
        tips = game.getStrByKey( "chat_voice_set_tips9" )
        offY = 8
    end

    if getGameSetById(setID) > 0 or par == nil then
        return
    end

    setGameSetById(setID, 1)
    local tipsNode = nil
    local cb = function()
        removeFromParent(tipsNode)
        tipsNode = nil
    end

    tipsNode = createTouchItem(par,"res/chat/tips.png",cc.p(150,30+offY),cb,false)  
    tipsNode:setTag(8)
    local richText = require("src/RichText").new(tipsNode, cc.p(20, 30), cc.size(140, 24), cc.p(0, 0.5), 22, 18, MColor.lable_yellow)       
    richText:addText(tips)
    richText:format()  

    startTimerAction(tipsNode, 15, false, cb)
end

function ChatFactionRealLayer:startOrStopBgMusic(start)
	if start then
		if G_MAINSCENE and getGameSetById(GAME_SET_ID_CLOSE_MUSIC) == 1 then
			AudioEnginer.setIsNoPlayMusic(false)
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
            AudioEnginer.setIsNoPlayMusic(true)
		end
		if getGameSetById(GAME_SET_ID_CLOSE_VOICE) == 1 then
			AudioEnginer.setIsNoPlayEffects(true)
		end
	end
end

return ChatFactionRealLayer