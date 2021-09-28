local ChatAutoPlayLayer = class("ChatAutoPlayLayer", function() return cc.Layer:create() end)

function ChatAutoPlayLayer:ctor(parent, pos)
    parent:addChild(self)
    self:setPosition(pos)

    self.list = {}
    self.curTimeLen = 0
    self.bPlaying = false

    self:registerScriptHandler(function(event)
        if event == "enter" then   
            self.schedulerHandle = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function() self:update() end, 0.3, false)
        elseif event == "exit" then
            if self.schedulerHandle then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerHandle)
                self.schedulerHandle = nil                
            end 
        end
    end)  
end

function ChatAutoPlayLayer:addPlayMsg(record, first)
    if record.type ~= 3 then
        return
    end

    --cclog("yuexiaojun  addPlayMsg fileid=%s, text=%s, timeLen=%d", record.fileid, record.text, record.timeLen)

    --未验证or模式不对
    if Device_target ~= cc.PLATFORM_OS_WINDOWS then
        if not G_FACTION_INFO.isSetAuthKey or getGameSetById(GAME_SET_VOICE_REALVOICE_OPEN) > 0 then
            return
        end
    end 

    if first == true then
        if #self.list == 0 then
            self.list[1] = record
        else
            self.list[2] = record
        end

        return
    end

    if record.usrId == userInfo.currRoleStaticId then
        return
    end

    if getNetworkType() ~= "WIFI" and getGameSetById(GAME_SET_VOICE_VOICE) == 0 then
        return
    end

    local commConst = require("src/config/CommDef")
    if record.channelId == commConst.Channel_ID_Privacy and getGameSetById(GAME_SET_VOICE_PRIVATE) < 1 then
        return
    end

    if record.channelId == commConst.Channel_ID_World and getGameSetById(GAME_SET_VOICE_WORLD) < 1 then
        return
    end

    if record.channelId == commConst.Channel_ID_Faction and getGameSetById(GAME_SET_VOICE_FACTION) < 1 then
        return
    end

    if record.channelId == commConst.Channel_ID_Area and getGameSetById(GAME_SET_VOICE_AREA) < 1 then
        return
    end

    if record.channelId == commConst.Channel_ID_Team and getGameSetById(GAME_SET_VOICE_TEAM) < 1 then
        return
    end

    if #self.list < 20 then
        self.list[#self.list + 1] = record
    end
end

function ChatAutoPlayLayer:update(dt)
    if G_MAINSCENE == nil then
         return
    end
    
    if #self.list == 0 then
        self.bPlaying = false
        self.curTimeLen = 0
        return
    end    
    
    if Device_target ~= cc.PLATFORM_OS_WINDOWS then
        if not G_FACTION_INFO.isSetAuthKey or getGameSetById(GAME_SET_VOICE_REALVOICE_OPEN) > 0 then
            if #self.list > 0 then
                if self.list[1].onEnd ~= nil then
                    self.list[1].onEnd()
                end

                self.bPlaying = false
                self.curTimeLen = 0
                self.list = {}

                cclog("yuexiaojun self.list = {} ") 
                return
            end
        end
    end

    if self.bPlaying then
        self.curTimeLen = self.curTimeLen + 0.3            
        if self.curTimeLen > self.list[1].timeLen then
            self.bPlaying = false
            self.curTimeLen = 0
            if self.list[1].onEnd ~= nil then
                self.list[1].onEnd()
            end
            table.remove(self.list, 1)
            cclog("yuexiaojun PlayFile onEnd ") 
        else
            return
        end
    end

    if #self.list == 0 then
        return
    end

    cclog("yuexiaojun PlayFile start fileid=%s", self.list[1].fileid) 
    VoiceApollo:PlayFile(self.list[1].fileid)
    if self.list[1].onBegin ~= nil then
        self.list[1].onBegin()
    end

    self.bPlaying = true
    self.curTimeLen = 0
end

return ChatAutoPlayLayer