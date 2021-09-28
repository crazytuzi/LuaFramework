local ChatVoiceSetLayer = class("ChatVoiceSetLayer", function() return cc.Layer:create() end)

local path = "res/chat/"
local commConst = require("src/config/CommDef")

function ChatVoiceSetLayer:ctor(param)
	local bg = createScale9Sprite(self, "res/common/scalable/12.png", cc.p(0, 0), cc.size(400, 520), cc.p(0, 0))
	local closeFunc = function()
		removeFromParent(self)
	end

    registerOutsideCloseFunc(bg, closeFunc, true)

    --自动播放语音
    local labelColor = MColor.lable_yellow
    if getGameSetById(GAME_SET_VOICE_REALVOICE_OPEN) > 0 then labelColor = MColor.gray end
    self.labelTips1 = createLabel(bg, game.getStrByKey("chat_voice_set_auto"),cc.p(20,484),cc.p(0,0.5), 22,nil,nil,nil,labelColor)

    --createSprite(bg, "/res/chat/spearate_line.png", cc.p(200, 470), cc.p(0.5, 0.5))

    self.item1, self.label1 = self:createSwitch(bg, cc.p(100, 430), game.getStrByKey("chat_world"), GAME_SET_VOICE_WORLD, true)
    self.item2, self.label2 = self:createSwitch(bg, cc.p(220, 430), game.getStrByKey("chat_faction"), GAME_SET_VOICE_FACTION, true)
    self.item3, self.label3 = self:createSwitch(bg, cc.p(350, 430), game.getStrByKey("chat_area"), GAME_SET_VOICE_AREA, true)

    self.item4, self.label4 = self:createSwitch(bg, cc.p(100, 370), game.getStrByKey("chat_personal"), GAME_SET_VOICE_PRIVATE, true)
    self.item5, self.label5 = self:createSwitch(bg, cc.p(220, 370), game.getStrByKey("chat_teamup"), GAME_SET_VOICE_TEAM, true)

    createSprite(bg, "res/chat/spearate_line.png", cc.p(200, 336), cc.p(0.5, 0.5))

    --行会指挥频道
    createLabel(bg, game.getStrByKey("chat_voice_set_faction"),cc.p(20,306),cc.p(0,0.5), 22,nil,nil,nil,MColor.lable_yellow)  
    if G_FACTION_INFO.facname ~= nil and G_FACTION_INFO.zhihuiID and G_FACTION_INFO.zhihuiID == userInfo.currRoleStaticId then
        self:createSwitch(bg, cc.p(320, 254), game.getStrByKey("chat_voice_set_show_f"), GAME_SET_VOICE_REALVOICE_OPEN) 
    else 
        self:createSwitch(bg, cc.p(320, 254), game.getStrByKey("chat_voice_set_recv_f"), GAME_SET_VOICE_REALVOICE_OPEN)     
    end

    createLabel(bg, game.getStrByKey("chat_voice_set_tips1"),cc.p(20,200),cc.p(0,0.5), 16,nil,nil,nil,MColor.lable_black)
    createLabel(bg, game.getStrByKey("chat_voice_set_tips2"),cc.p(20,175),cc.p(0,0.5), 16,nil,nil,nil,MColor.lable_black)
    
    --非wifi时
    createSprite(bg, "res/chat/spearate_line.png", cc.p(200, 144), cc.p(0.5, 0.5))
    createLabel(bg, game.getStrByKey("chat_voice_set_wifi"),cc.p(20,110),cc.p(0,0.5), 22,nil,nil,nil,MColor.lable_yellow)
   -- self:createSwitch(bg, cc.p(140, 50), game.getStrByKey("chat_voice_set_v2w"), GAME_SET_VOICE_V2W)
    self:createSwitch(bg, cc.p(140, 50), game.getStrByKey("chat_voice_set_yuyin"), GAME_SET_VOICE_VOICE)

    createTouchItem(bg, "res/component/button/X.png", cc.p(380,500), function() removeFromParent(self) end, nil)
end

function ChatVoiceSetLayer:createSwitch(parent,pos,str,flag, bCheck)
    local node = cc.Node:create()
	node:setPosition(pos)
    if parent then
		parent:addChild(node)
	end
   
    local loadstr1 = "res/component/checkbox/openBtn2.png"
    local loadstr2 = "res/component/checkbox/closeBtn2.png"
    if bCheck then
        loadstr1 = "res/component/checkbox/1-2.png"
        loadstr2 = "res/component/checkbox/1.png"
    end
	local touchFunc = function(sender) 
        if flag == GAME_SET_VOICE_REALVOICE_OPEN then
            if G_FACTION_INFO.facname == nil then
                TIPS( { type = 1 , str = game.getStrByKey( "chat_voice_set_tips4" ) }  )
                return
            end
        end

        if getGameSetById(GAME_SET_VOICE_REALVOICE_OPEN) > 0 and flag >=GAME_SET_VOICE_WORLD and flag <= GAME_SET_VOICE_TEAM then 
           TIPS( { type = 1 , str = game.getStrByKey( "chat_voice_set_tips5" ) }  )
           return
        end
        
        local oldValue = getGameSetById(flag)
        local newValue = 0
		if oldValue < 1 then newValue = 1 end

        --禁止加入房间太频繁        
        if flag == GAME_SET_VOICE_REALVOICE_OPEN and newValue > 0 then
            local curTime = os.time()
            if self.lastJoinRoomOperTime and curTime < self.lastJoinRoomOperTime + 3 then
                TIPS( { type = 1 , str = game.getStrByKey( "chat_voice_set_tips6" ) }  )
                return
            else
                self.lastJoinRoomOperTime = curTime
            end
        end
        
        if GAME_SET_VOICE_REALVOICE_OPEN == flag then
            setGameSetById(flag, newValue, true)
            if G_MAINSCENE.factionRealVoice and G_MAINSCENE.factionRealVoice.switchBtn then
                G_MAINSCENE.factionRealVoice.switchBtn:setVisible(newValue > 0)
                setGameSetById(GAME_SET_VOICE_V2W, newValue, true)
                if newValue > 0 then
                    G_MAINSCENE.factionRealVoice:showTips(1)
                end
            end
        else
            setGameSetById(flag, newValue)
        end      

        local item = node:getChildByTag(1)
		if newValue > 0 then
			item:setTexture(loadstr1)
		else
			item:setTexture(loadstr2)
		end

        if flag == GAME_SET_VOICE_REALVOICE_OPEN then
            if newValue > 0 then              
                self.labelTips1:setColor(MColor.gray)
                self.item1:addColorGray()
                self.item2:addColorGray()
                self.item3:addColorGray()
                self.item4:addColorGray()
                self.item5:addColorGray()
                self.label1:setColor(MColor.gray)
                self.label2:setColor(MColor.gray)
                self.label3:setColor(MColor.gray)
                self.label4:setColor(MColor.gray)
                self.label5:setColor(MColor.gray)

                self:hideRealOpenEff()
            else
                self.labelTips1:setColor(MColor.lable_yellow)
                self.item1:removeColorGray()
                self.item2:removeColorGray()
                self.item3:removeColorGray()
                self.item4:removeColorGray()
                self.item5:removeColorGray()
                self.label1:setColor(MColor.lable_yellow)
                self.label2:setColor(MColor.lable_yellow)
                self.label3:setColor(MColor.lable_yellow)
                self.label4:setColor(MColor.lable_yellow)
                self.label5:setColor(MColor.lable_yellow)
            end
        end

        --if flag == GAME_SET_VOICE_REALVOICE_OPEN then
        --    if newValue > 0 and not G_FACTION_INFO.isHaveVoiceRoom and G_FACTION_INFO.facname ~= nil and G_FACTION_INFO.zhihuiID and G_FACTION_INFO.zhihuiID == userInfo.currRoleStaticId then
        --        sendCreateVoiceRoom()
        --    end
        --end
	end

	local item = createTouchItem(node,loadstr1,cc.p(0,0),touchFunc)
    item:setTag(1)
    if getGameSetById(flag) < 1 then
        item:setTexture(loadstr2) 
    end

    if flag == GAME_SET_VOICE_REALVOICE_OPEN then
        self.m_realOpen = item
    end

    local label = nil
    local labelColor = MColor.lable_yellow
    if getGameSetById(GAME_SET_VOICE_REALVOICE_OPEN) > 0 and flag >=GAME_SET_VOICE_WORLD and flag <= GAME_SET_VOICE_TEAM then 
       labelColor = MColor.gray 
       item:addColorGray()
    end

    if bCheck then
	    label = createLabel(node, str,cc.p(-20,0),cc.p(1,0.5), 22,nil,nil,nil,labelColor)
    else
        label = createLabel(node, str,cc.p(-60,0),cc.p(1,0.5), 22,nil,nil,nil,labelColor)
    end

	return item, label
end

function ChatVoiceSetLayer:showRealOpenEff()
    if not self.m_realOpen or getGameSetById(GAME_SET_VOICE_REALVOICE_OPEN) > 0 then
        return
    end

    local effectLoop = Effects:create(false)
    effectLoop:playActionData("guildspshow", 4, 1, -1)
    self.m_realOpen:addChild(effectLoop)
    effectLoop:setAnchorPoint(cc.p(0.5, 0.5))
    effectLoop:setPosition(cc.p(54, 29))
    self.realOpenEff = effectLoop
end

function ChatVoiceSetLayer:hideRealOpenEff()
    if not self.realOpenEff then
        return
    end

    removeFromParent(self.realOpenEff)
    self.realOpenEff = nil
end

return ChatVoiceSetLayer