local ChatVoiceSimple = class("ChatVoiceSimple", function() return cc.Node:create() end)

local commConst = require("src/config/CommDef")
local files = {}
files[commConst.Channel_ID_World] = "res/chat/voiceBg_world.png"
files[commConst.Channel_ID_Area] = "res/chat/voiceBg_area.png"
files[commConst.Channel_ID_Faction] = "res/chat/voiceBg_faction.png"
files[commConst.Channel_ID_Team] = "res/chat/voiceBg_team.png"
local origX = 26
local origY = 26-268
local disH = 53

function ChatVoiceSimple:ctor(parent, pos)
    parent:addChild(self)

    self.parent = parent
    self:setPosition(pos)

    self.bgTile = createScale9SpriteMenu(self,"res/chat/bg_chat_scale_2.png",cc.size(246, 106),cc.p(126,23.5),function() end)
    self.bgTile:setActionEnable(false)
    self.bgTile:setOpacity(0)

    --拓展按钮
    self.expandBtn = createTouchItem(self,"res/chat/arrow.png",cc.p(25,58-268),function() self:createMoreBtns() end,true)
    self.expandBtn:setRotation(-90)

    --收起按钮
    self.disExpand = createTouchItem(self,"res/chat/arrow.png",cc.p(25,243-288),function() self:createLessBtns() end,true) 
    self.disExpand:setRotation(90)
    self.disExpand:setVisible(false)

    self.worldBtn = require("src/layers/chat/Microphone").new(self,cc.p(26,26),self,commConst.Channel_ID_World,files[commConst.Channel_ID_World])
    self.areaBtn = require("src/layers/chat/Microphone").new(self,cc.p(26,26),self,commConst.Channel_ID_Area,files[commConst.Channel_ID_Area])
    self.teamBtn = require("src/layers/chat/Microphone").new(self,cc.p(26,26),self,commConst.Channel_ID_Team,files[commConst.Channel_ID_Team])
    self.factionBtn = require("src/layers/chat/Microphone").new(self,cc.p(26,26),self,commConst.Channel_ID_Faction,files[commConst.Channel_ID_Faction])

    self.teamBtnIsGray = false
    self.factionBtnIsGray = false

    self.worldBtn:setVisible(false)
    self.areaBtn:setVisible(false)
    self.teamBtn:setVisible(false)
    self.factionBtn:setVisible(false) 

    self.lastBtn = self.worldBtn
    self:createLessBtns()

    self.isGray = false

    self:registerScriptHandler(function(event)
        if event == "enter" then  
            local function update()
                if G_MAINSCENE == nil then
                    return
                end
                
                if getGameSetById(GAME_SET_VOICE_REALVOICE_OPEN) > 0 then
                    if not self.isGray then
                        self.isGray = true
                        self:createLessBtns()

                        self.expandBtn:addColorGray()
                        self.worldBtn.voiceBtn:addColorGray()
                        self.areaBtn.voiceBtn:addColorGray()

                        if not self.factionBtnIsGray then
                             self.factionBtn.voiceBtn:addColorGray()
                             self.factionBtnIsGray = true
                        end

                        if not self.teamBtnIsGray then
                             self.teamBtn.voiceBtn:addColorGray()
                             self.teamBtnIsGray = true
                        end
                    end
                else
                    if self.isGray then
                        self.isGray = false
                        self.expandBtn:removeColorGray()
                        self.worldBtn.voiceBtn:removeColorGray()
                        self.areaBtn.voiceBtn:removeColorGray()
                    end

                    if not G_FACTION_INFO.facname then
                         if not self.factionBtnIsGray then
                             self.factionBtn.voiceBtn:addColorGray()
                             self.factionBtnIsGray = true                             
                         end

                         self.factionBtn.canRevcTouch = false
                    else
                         if self.factionBtnIsGray then
                             self.factionBtn.voiceBtn:removeColorGray()
                             self.factionBtnIsGray = false                             
                         end

                         self.factionBtn.canRevcTouch = true
                    end

                    if not G_TEAM_INFO.has_team then
                         if not self.teamBtnIsGray then
                             self.teamBtn.voiceBtn:addColorGray()
                             self.teamBtnIsGray = true                            
                         end

                         self.teamBtn.canRevcTouch = false
                    else
                         if self.teamBtnIsGray then
                             self.teamBtn.voiceBtn:removeColorGray()
                             self.teamBtnIsGray = false                            
                         end

                         self.teamBtn.canRevcTouch = true
                    end
                end

                
            end
            self.schedulerHandle = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update, 0.3, false)
        elseif event == "exit" then
            if self.schedulerHandle then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerHandle)
                self.schedulerHandle = nil
            end 
        end
    end)
end

function ChatVoiceSimple:createVoiceBtn(channel)    
    require("src/layers/chat/Microphone").new(self,cc.p(26,26),self,channel,files[channel])
end

function ChatVoiceSimple:onLastSend(lastBtn) 
    self.lastBtn = lastBtn
    if not self.expandBtn:isVisible() then
        self:createLessBtns()
    end
end

function ChatVoiceSimple:onVoiceBtnClick(lastBtn) 
    if self.expandBtn:isVisible() then
        self:createMoreBtns()
    else
        self.lastBtn = lastBtn
        self:createLessBtns()
    end
end

function ChatVoiceSimple:createMoreBtns()    
    if self.isGray then
        TIPS( { type = 1 , str = game.getStrByKey( "chat_voice_set_tips5" ) }  )
        return
    end
    -- 去掉语音按钮和聊天信息的联动
    --self.bgTile:setVisible(true)
    self.bgTile:setVisible(false)
    self.worldBtn:setVisible(false)
    self.areaBtn:setVisible(false)
    self.teamBtn:setVisible(false)
    self.factionBtn:setVisible(false)
    if self.lastBtn == self.factionBtn and not G_FACTION_INFO.facname then
        self.lastBtn = self.worldBtn
    elseif self.lastBtn == self.teamBtn and not G_TEAM_INFO.has_team then
        self.lastBtn = self.worldBtn
    end

    self.lastBtn:setVisible(true)
    self.lastBtn:setPosition(cc.p(origX,origY))

    local Y = origY
    if self.worldBtn ~= self.lastBtn then
        Y = Y + disH
        self.worldBtn:setVisible(true)
        self.worldBtn:setPosition(cc.p(origX, Y))
    end

    if self.areaBtn ~= self.lastBtn then
        Y = Y + disH
        self.areaBtn:setVisible(true)
        self.areaBtn:setPosition(cc.p(origX, Y))
    end

    if self.teamBtn ~= self.lastBtn then
        Y = Y + disH
        self.teamBtn:setVisible(true)
        self.teamBtn:setPosition(cc.p(origX, Y))
    end

    if self.factionBtn ~= self.lastBtn then
        Y = Y + disH
        self.factionBtn:setVisible(true)
        self.factionBtn:setPosition(cc.p(origX, Y))
    end

    self.disExpand:setVisible(true)
    self.expandBtn:setVisible(false)

    --移动实时语聊按钮位置
    --if G_MAINSCENE.factionRealVoice and G_MAINSCENE.factionRealVoice.switchBtn then
    --     G_MAINSCENE.factionRealVoice.switchBtn:setPositionX(-100)
    --end

    self.parent:onSimpleVoiceAction(false)
end

function ChatVoiceSimple:createLessBtns()         
    self.bgTile:setVisible(false)
    self.worldBtn:setVisible(false)
    self.areaBtn:setVisible(false)
    self.teamBtn:setVisible(false)
    self.factionBtn:setVisible(false)
    if self.lastBtn == self.factionBtn and not G_FACTION_INFO.facname then
        self.lastBtn = self.worldBtn
    elseif self.lastBtn == self.teamBtn and not G_TEAM_INFO.has_team then
        self.lastBtn = self.worldBtn
    end

    self.lastBtn:setVisible(true)
    self.lastBtn:setPosition(cc.p(origX,origY))
    
    self.disExpand:setVisible(false)
    self.expandBtn:setVisible(true)

    self.parent:onSimpleVoiceAction(true)

    --移动实时语聊按钮位置
    --if G_MAINSCENE.factionRealVoice and G_MAINSCENE.factionRealVoice.switchBtn then
    --     G_MAINSCENE.factionRealVoice.switchBtn:setPositionX(26)
    --end
end

return ChatVoiceSimple



