local StoryGongShaHuangGong = class("StoryGongShaHuangGong", require ("src/layers/story/StoryGongSha"))

local path = "res/storygs/"

function StoryGongShaHuangGong:ctor()
	G_STORY_FB_MODE = true
    self.state = 0
    self.playerTab = {{},{}}
    self.RolesAI = {}

    local msgids = {SHAWAR_SC_MONIWAR_STAGE_UPDATE}
	require("src/MsgHandler").new(self,msgids)

	local listenner = cc.EventListenerTouchOneByOne:create()
	listenner:setSwallowTouches(true)
    listenner:registerScriptHandler(function(touch, event)
    		if self.m_manualFight == true then
                return false
            end

            return true
        end,cc.Handler.EVENT_TOUCH_BEGAN )
    listenner:registerScriptHandler(function(touch, event)
    		print("touch end")
        end,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, self)
    

    self:registerScriptHandler(function(event)
        if event == "enter" then  
            local function updateAI(dt)
                if G_MAINSCENE == nil or self.isEnd then
                    return
                end
                
                for k, v in pairs(self.RolesAI) do
                    v:update(dt)
                end
                --[[if self.needAutoAtk == 2 then
                    game.setAutoStatus(4)
                else
                    game.setAutoStatus(0)
                end]]
                self:updateHangNode()
            end

            self.schedulerHandle = cc.Director:getInstance():getScheduler():scheduleScriptFunc(updateAI, 2, false)
        elseif event == "exit" then
            if self.schedulerHandle then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerHandle)
                self.schedulerHandle = nil
            end 

            if self.schedulerArrow ~= nil then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerArrow)
                self.schedulerArrow = nil
            end
        end
    end)

    
end

function StoryGongShaHuangGong:updateState()  

	self.state = self.state + 1

	local switch = {
        function()
            local blackGround = cc.LayerColor:create(cc.c4b(0, 0, 0, 255))
            G_MAINSCENE:addChild(blackGround, 196, 1256) 

            local masking = cc.LayerColor:create(cc.c4b(0, 0, 0, 255))
            self:addChild(masking, 10000)   
            masking:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.FadeOut:create(0.2)))

            self.m_bHidePlayer = getGameSetById(GAME_SET_ID_SHIELD_PLAYER)                       
            setGameSetById(GAME_SET_ID_SHIELD_PLAYER, 0, true)

            startTimerAction(self, 0.05, false, function() G_ROLE_MAIN:upOrDownRide(false) end )
                             
            startTimerAction(self, 0.2, false, function()                     
                       self:changeRoleDress(true)  
                       
                       local name_label = G_ROLE_MAIN:getNameBatchLabel()
                       if name_label then
                           self.mainRoleColor = name_label:getColor()
                           name_label:setColor(MColor.name_blue)
                       end

                       G_ROLE_MAIN:setFactionName_ex(G_ROLE_MAIN, game.getStrByKey("story_gongsha_factionname1"))
                       G_ROLE_MAIN:setTitle_ex(G_ROLE_MAIN, 0)

                       G_ROLE_MAIN:setPosition(G_MAINSCENE.map_layer:tile2Space(cc.p(24,25)))
                       G_MAINSCENE.map_layer:initDataAndFunc(cc.p(24,25))
                       G_MAINSCENE.map_layer:setDirectorScale(nil, cc.p(24,25))
                       G_MAINSCENE.map_layer:moveMapByPos(cc.p(23, 24), false)
                       G_ROLE_MAIN:setSpriteDir(3) 

                       self:createPlayers(2117,1) 

                       if self.m_isFBMode then
                           self:createExitBtn()
                       end

                       --AudioEnginer.setIsNoPlayEffects(false)
                                  
                   end)

            startTimerAction(self, 2, false, function() self:updateState()  end)
        end
        ,

        function()  
            self:addTalk(105)
        end
        ,

        function()  
            local record = getConfigItemByKey("storyTalk", "q_id", 106)
            local str = string.format(record.q_text, require("src/layers/role/RoleStruct"):getAttr(ROLE_NAME))
            self:addTalk(106, nil, nil, str) 
        end
        ,

        function()  
            self:addTalk(107)
        end
        ,

        function()  
            local record = getConfigItemByKey("storyTalk", "q_id", 108)
            local str = string.format(record.q_text, require("src/layers/role/RoleStruct"):getAttr(ROLE_NAME))
            self:addTalk(108, nil, nil, str) 
        end
        ,

        function()                                
            AudioEnginer.playEffect("sounds/storyVoice/gs6.mp3",false)
            self:addTaskInfo(7)
            startTimerAction(self, 1.0, false, function() 
                        self.m_manualFight = true
                        G_MAINSCENE:setFullShortNode(false)
                        self:addSkill()
                        self:createHangNode() 
                        self:showOperPanel() 
                        self:updateState() 
                   end)
        end
        ,

        --杀光所有对手
        function()
            self.m_needLianZhanEffect = true
            startTimerAction(self, 3, false, function() AudioEnginer.playEffect("sounds/storyVoice/gs_bg1.mp3",false) end)
            --startTimerAction(self, 6, false, function() AudioEnginer.playEffect("sounds/storyVoice/gs_bg2.mp3",false) end)
            startTimerAction(self, 8, false, function() AudioEnginer.playEffect("sounds/storyVoice/gs_bg3.mp3",false) end)
            --startTimerAction(self, 9, false, function() AudioEnginer.playEffect("sounds/storyVoice/gs_bg4.mp3",false) end)
            
            startTimerAction(self, 0.1, false, function() for k, v in pairs(self.RolesAI) do if v  then v:fight(); v.m_startLockTarget = true end end  end)          
            startTimerAction(self, 0.1, false, function() self.needAutoAtk = 1; self.m_canPlayerHurt = true end)
            local totalTime = 0
            self.hurtAction = startTimerAction(self, 0.1, true, function() 
                    totalTime = totalTime + 0.1
                    local bAllDie = true
                    for m, n in pairs(self.playerTab[2]) do
                        if n ~= nil and n:isVisible() and n:getHP() > 1 then
                            bAllDie = false
                            break
                        end
                    end

                    if bAllDie or totalTime > 60 then                      
                        self:stopAction(self.hurtAction)
                        self.hurtAction = nil                         
                        self.needAutoAtk = 0  
                        self.m_canPlayerHurt = false               
                        self:updateState()
                    end                    
            end)        
        end
        ,

        --占领皇宫
        function()
            self:addTaskInfo(9)
            AudioEnginer.playEffect("sounds/storyVoice/gs7.mp3",false)

            --占领倒计时
            local timeCoutLayer = require("src/layers/shaWar/shaWarLayer").new()
		    G_MAINSCENE:addChild(timeCoutLayer, 400)
		    timeCoutLayer:setPosition(cc.p(0, 0))
		    timeCoutLayer:update(5)        

            startTimerAction(self, 5, false, function() self:updateState()  end)
        end
        ,

        --结束特效，并退出倒计时
        function()  
            --if self.m_isFBMode then
                g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_FINISH_SINGLEINST, "FinishSingleInstProtocol", {instID = 8});
            --end

            game.setAutoStatus(0)
            self:addWinFlg()           
            self:addTaskInfo(10)  
            
            --切换角色行会名称   
            local name = game.getStrByKey("story_gongsha_factionname1").."("..game.getStrByKey("shaWar_name")..")"
            G_ROLE_MAIN:setFactionName_ex(G_ROLE_MAIN, name)
            for m, n in pairs(self.playerTab[1]) do
                if n ~= nil and n:isVisible() and n:getHP() > 0 then                  
                    n:setFactionName_ex(n, name)
                end
            end    
        end
        ,
        function()  
            self:endStroy()         
        end
        ,
    }

 	if switch[self.state] then 
 		switch[self.state]()
 	end
end

function StoryGongShaHuangGong:endStroy()
    if not self.m_isFBMode then
        g_msgHandlerInst:sendNetDataByTableExEx(SHAWAR_CS_REQUEST_UPDATE_MONIWAR_STAGE, "ShaWarRequestUpdateMoniWarStage", {stage=3})
    else
        g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_EXITCOPY,"ExitCopyProtocol", {})
    end
    
    self.isEnd = true
    game.setAutoStatus(0)
    self:hideHangNode()

    if self.schedulerHandle then 
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry( self.schedulerHandle ) 
        self.schedulerHandle = nil
    end 

    --移除魔法盾效果
    local topNode = G_ROLE_MAIN:getTopNode()
    if topNode ~= nil and topNode:getChildByTag(80) ~= nil then
        topNode:removeChildByTag(80)
    end

    --移除中毒效果
    G_ROLE_MAIN:setColor(cc.c3b(255, 255, 255))

    setGameSetById(GAME_SET_ID_SHIELD_PLAYER, self.m_bHidePlayer, true)
    for m, n in pairs(self.playerTab[1]) do
        if n ~= nil and n:getHP() == 0 then
            n:setVisible(false)
        end
    end

    for m, n in pairs(self.playerTab[2]) do
        if n ~= nil and n:getHP() == 0 then
            n:setVisible(false)
        end
    end
 
    self:stopAllActions()
    self:changeRoleDress(false)

    self:removeSkill()
    --AudioEnginer.setIsNoPlayEffects(getGameSetById(GAME_SET_ID_CLOSE_VOICE)==0)
    --self:removeAudioEffect()

    self:removePathPoint()  

    G_MAINSCENE.map_layer:setMapActionFlag(true)
    G_MAINSCENE:removeChildByTag(1256)

    G_ROLE_MAIN.base_data.spe_skill = {}
    G_MAINSCENE.map_layer:resetSpeed(g_speed_time)

    local name_label = G_ROLE_MAIN:getNameBatchLabel()
    if name_label then
        name_label:setColor(self.mainRoleColor)
    end

    local FactinName = require("src/layers/role/RoleStruct"):getAttr(PLAYER_FACTIONNAME)
    if FactinName then
        G_ROLE_MAIN:setFactionName_ex(G_ROLE_MAIN, FactinName)
    else
        G_ROLE_MAIN:setFactionName_ex(G_ROLE_MAIN, "")
    end
    local titleId = require("src/layers/role/RoleStruct"):getAttr(PLAYER_TITLE)
    if titleId then
        G_ROLE_MAIN:setTitle_ex(G_ROLE_MAIN, titleId)
    end

    --require("src/layers/pkmode/PkModeLayer"):setCurMode(self.m_curMode)
    --g_msgHandlerInst:sendNetDataByTable(FRAME_CS_CHANGE_MODE, "FrameChangeModeProtocol", {mode=self.m_curMode})
    

    --G_MAINSCENE:exitStoryMode()
end

function StoryGongShaHuangGong:networkHander(buff,msgid) 
    local switch = {
        [SHAWAR_SC_MONIWAR_STAGE_UPDATE] = function()    
            --local t = g_msgHandlerInst:convertBufferToTable("ShaWarMoniWarStageUpdate", buff)
            --self.m_curStage = t.stage
            --self:updateState() 
		end,
	}

 	if switch[msgid] then 
 		switch[msgid]()
 	end
end

function StoryGongShaHuangGong:addWinFlg()
    local posX_text_success, posY_text_success = display.width/2, display.height * 4 / 6
    local sprite_text_success = cc.Sprite:create("res/fb/win_shawar.png")
    sprite_text_success:setVisible(false)
    sprite_text_success:setAnchorPoint(0.5, 0.5)
    sprite_text_success:setPosition(cc.p(posX_text_success, posY_text_success))
    sprite_text_success:runAction(cc.Sequence:create(
    	 cc.DelayTime:create(0.25)
        , cc.Show:create()
        , cc.DelayTime:create(1)
        , cc.FadeOut:create(1)
        , cc.RemoveSelf:create()
    ))
    self:addChild(sprite_text_success, 3)

    local animateSpr = Effects:create(false)
    animateSpr:setAnchorPoint(.5, .5)
    animateSpr:setPosition(cc.p(posX_text_success, posY_text_success))
    animateSpr:runAction(cc.Sequence:create(
         cc.CallFunc:create(function()
            animateSpr:playActionData("operationsuccess", 11, 1.9, 1)
        end)
        , cc.DelayTime:create(1.9)
        , cc.RemoveSelf:create()
    ))
    addEffectWithMode(animateSpr, 1)
    self:addChild(animateSpr, 3)
end

return StoryGongShaHuangGong