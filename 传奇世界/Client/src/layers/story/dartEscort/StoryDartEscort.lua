local StoryDartEscort = class("StoryDartEscort", require ("src/layers/story/StoryGongSha"))

function StoryDartEscort:ctor()
    G_STORY_FB_MODE = true
    self.state = 0
    self.playerTab = {{},{}}
    self.RolesAI = {}
    G_ROLE_MAIN:upOrDownRide(false)
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

    local function outBtnFun()
        self:endStroy()
    end
    self.exitConfirm = function()
        MessageBoxYesNo(nil,game.getStrByKey("exit_confirm"),outBtnFun,nil,game.getStrByKey("sure"),game.getStrByKey("cancel"))
    end
    local outBtn = createMenuItem(self,"res/component/button/1.png", cc.p(g_scrSize.width-70, g_scrSize.height-110),self.exitConfirm)
    outBtn:setSmallToBigMode(false)
    self.exitBtn = outBtn
    -- function createLabel(parent, sContent,pos, anchor, fontSize, isOutLine, izorder, fontName, fontColor, tag, specificWidth, outLineColor, outLineWidth)
    self.level_str = createLabel(outBtn, game.getStrByKey("fb_leave"), getCenterPos(outBtn), cc.p(0.5,0.5), 22, true, nil, nil, MColor.lable_yellow, 1);
    --local outBtn = createMenuItem(self, "res/empire/shaWar/btn1.png", cc.p(g_scrSize.width - 60, 420), outBtnFun)
    outBtn:setOpacity(0)
    outBtn:runAction(cc.Sequence:create(cc.FadeIn:create(0.5)))
    outBtn:setLocalZOrder(400)
   -- outBtn:setVisible(false)
    self.m_outBtn = outBtn

    self:registerScriptHandler(function(event)
        if event == "enter" then  
            local function updateAI(dt)
                if G_MAINSCENE == nil or self.isEnd then
                    return
                end
                
                for k, v in pairs(self.RolesAI) do
                    v:update(dt)
                end
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

function StoryDartEscort:updateState()  

    self.state = self.state + 1
    local role_name = MRoleStruct:getAttr(ROLE_NAME)
    local switch = {
        function()
            local masking = cc.LayerColor:create(cc.c4b(0, 0, 0, 255))
            self:addChild(masking, 10000)   
            masking:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.FadeOut:create(0.2))) 
            
            self.m_bHidePlayer = getGameSetById(GAME_SET_ID_SHIELD_PLAYER)                       
            setGameSetById(GAME_SET_ID_SHIELD_PLAYER, 0, true)           
                             
            startTimerAction(self, 0.4, false, function()
                       self:changeRoleDress(true)                                             
                                                                   
                       local name_label = G_ROLE_MAIN:getNameBatchLabel()
                       if name_label then
                           self.mainRoleColor = name_label:getColor()
                           name_label:setColor(MColor.name_blue)
                       end

                       G_ROLE_MAIN:setFactionName_ex(G_ROLE_MAIN, game.getStrByKey("story_gongsha_factionname1"))
                       G_ROLE_MAIN:setTitle_ex(G_ROLE_MAIN, 0)

                       G_ROLE_MAIN:setPosition(G_MAINSCENE.map_layer:tile2Space(cc.p(51,195)))
                       G_MAINSCENE.map_layer:initDataAndFunc(cc.p(51,195))
                       G_MAINSCENE.map_layer:setDirectorScale(nil, cc.p(51,195))
                       G_MAINSCENE.map_layer:moveMapByPos(cc.p(50, 195), false)
                       G_ROLE_MAIN:setSpriteDir(3)                      
                       self:createPlayers(2116,1) 
                       self:createDefender()
                       self:addBaiguPlayerer()
                        self:addSoldier() 
                        self:addDartMonster() 
                                                
                       --AudioEnginer.setIsNoPlayEffects(false)           
                   end)

            startTimerAction(self, 2.0, false, function() self:updateState()  end)
        end
        ,
        function()
            self:addTalk(320)
        end
        ,
        function()  
            self:addTalk(321)
        end
        ,

        function()  
            local record = getConfigItemByKey("storyTalk", "q_id", 322)
            local str = string.format(record.q_text, role_name)
            self:addTalk(322, nil, nil, str) 
        end
        ,
        function()
            for k, v in pairs(self.RolesAI) do
                if not v.cannot_attack then
                    v:fight()
                end
            end
            G_MAINSCENE.hangup_tile = nil
            startTimerAction(self, 1.0, false, function() for k, v in pairs(self.RolesAI) do if v  then v.m_startLockTarget = true end end  end)
            local endPoint = cc.p(58, 185)
            G_MAINSCENE.map_layer:moveMapByPos(endPoint, false)
            self.pointAction = startTimerAction(self, 0.1, true, function() 
                local cur = G_MAINSCENE.map_layer:space2Tile(cc.p(G_ROLE_MAIN:getPosition()))
                if math.abs(cur.x - endPoint.x) < 2 and math.abs(cur.y - endPoint.y) < 2 then
               --if self:isInArea(1) then
                    self:stopAction(self.pointAction)
                    self.pointAction = nil 
                    self:updateState()
                end
            end)
        end
        ,
        function() 
            local record = getConfigItemByKey("storyTalk", "q_id", 323)
            local str = string.format(record.q_text, role_name) 
            self:addTalk(323, nil, nil, str) 
        end
        ,

        function()  
            local record = getConfigItemByKey("storyTalk", "q_id", 324)
            local str = string.format(record.q_text, role_name) 
            self:addTalk(324, nil, nil, str)
        end
        ,
        function()  
            self:addTalk(325)
        end
        ,
        function()
            self:addTaskInfo(1)
            G_MAINSCENE:setFullShortNode(false)
            self:addSkill()
            self:createHangNode() 
            G_MAINSCENE.operate_node:setLocalZOrder(199)
            G_MAINSCENE.skill_node:setLocalZOrder(199)
             G_MAINSCENE.bloodNode:setLocalZOrder(199) 
            self.m_manualFight = true 
            --startTimerAction(self, 1.0, false, function() self:addFocusEff(4) end)
            startTimerAction(self, 3.0, false, function() for k, v in pairs(self.RolesAI) do if v  then v.m_startLockTarget = true end end  end)
            G_MAINSCENE.hangup_tile = nil
            --self:addTaskInfo(3)
            startTimerAction(self, 2, false, function() game.setAutoStatus(AUTO_ATTACK); self.m_canPlayerHurt = true end)
            local has_added = false
            local addPlayer2 = function()
                if not has_added then
                    for k,v in pairs(self.players_tab[2]) do
                        if v.storyai then
                            v.storyai.cannot_attack = nil
                        end
                        v:setVisible(true)
                    end
                    for k, v in pairs(self.RolesAI) do
                        if not v.cannot_attack then
                            v:fight()
                        end
                    end
                    has_added = true
                end
            end
            startTimerAction(self, 15, false, addPlayer2)
            local loop_num = 0
            self.hurtAction = startTimerAction(self, 0.1, true, function() 
                    local bAllDie = true
                    local left_num = 0
                    loop_num = loop_num + 1
                    for m, n in pairs(self.playerTab[2]) do
                        if n ~= nil and n:isVisible() and n:getHP() > 0 then
                            bAllDie = false
                            left_num = left_num + 1
                        end
                    end
                    if self.link_label and loop_num%5 == 0 then
                        local left_number = 10-left_num
                        if not has_added then
                            left_number = 5 - left_num
                        end
                        self.link_label:setString("击退劫镖之敌一："..left_number.."/10")
                    end
                    if bAllDie then
                        if has_added then
                            game.setAutoStatus(0)
                            self:hideHangNode()     
                            self:stopAction(self.hurtAction)
                            self.hurtAction = nil                         
                            self.needAutoAtk = 0  
                            self.m_canPlayerHurt = false
                            self:removeSkill()
                            self.m_manualFight = nil
                            for k, v in pairs(self.RolesAI) do
                                v:idle()
                            end             
                            self:updateState()
                        else
                            addPlayer2()
                        end
                    end                    
            end)
        end
        ,
        -- function()
        --     for k,v in pairs(self.players_tab[2]) do
        --         if v.storyai then
        --             v.storyai.cannot_attack = nil
        --         end
        --         v:setVisible(true)
        --     end
        --     self.needAutoAtk = 0
        --     game.setAutoStatus(0)
        --     for k, v in pairs(self.RolesAI) do
        --         if v.camp and v.camp == 1 then
        --             v:idle()
        --         elseif not v.cannot_attack then
        --             v:fight()
        --         end
        --     end 
        --     for k,v in pairs(self.players_tab[1]) do
        --         v:standed()
        --     end
        --     startTimerAction(self, 1.0, false, function() 
        --             self.needAutoAtk = 2 
        --             for k, v in pairs(self.RolesAI) do
        --                 if not v.cannot_attack then
        --                     v:fight()
        --                 end
        --             end
        --         end)
        --     self.hurtAction = startTimerAction(self, 0.1, true, function() 
        --             local bAllDie = true
        --             for m, n in pairs(self.players_tab[2]) do
        --                 if n ~= nil and n:isVisible() and n:getHP() > 0 then
        --                     bAllDie = false
        --                     break
        --                 end
        --             end
        --             if bAllDie then                      
        --                 self:stopAction(self.hurtAction)
        --                 self.hurtAction = nil                         
        --                 self.needAutoAtk = 0  
        --                 self.m_canPlayerHurt = false
        --                 self:removeSkill()
        --                 self.m_manualFight = nil
        --                 for k, v in pairs(self.RolesAI) do
        --                     v:idle()
        --                 end             
        --                 self:updateState()
        --             end                    
        --     end)
        -- end
        -- ,
        function()  
 			self:addTaskInfo(8)
            local endPoint = cc.p(66, 190)
            self:SoldierMove(endPoint)
            G_MAINSCENE.map_layer:moveMapByPos(endPoint, false)
            self.pointAction = startTimerAction(self, 0.1, true, function() 
                local cur = G_MAINSCENE.map_layer:space2Tile(cc.p(G_ROLE_MAIN:getPosition()))
                if math.abs(cur.x - endPoint.x) < 2 and math.abs(cur.y - endPoint.y) < 2 then
               --if self:isInArea(1) then
                    self:stopAction(self.pointAction)
                    self.pointAction = nil 
                    self:updateState()
                end
            end)
        end
        ,
   
        function()  
            local record = getConfigItemByKey("storyTalk", "q_id", 326)
            local str = string.format(record.q_text, role_name,role_name) 
            self:addTalk(326, nil, nil, str)
        end
        ,
        function()
            for k,v in pairs(self.players_tab[3]) do
                if v.storyai then
                    v.storyai.cannot_attack = nil
                end
                v:setVisible(true)
            end
            G_MAINSCENE.hangup_tile = nil
            local endPoint = cc.p(85, 195)
            self:SoldierMove(endPoint,true)
            G_MAINSCENE.map_layer:moveMapByPos(endPoint, false)
            self:addEscortEffect(true)
            startTimerAction(self, 2.5, false, function() self:PlayerMove() end)
            self.pointAction = startTimerAction(self, 0.1, true, function() 
                local cur = G_MAINSCENE.map_layer:space2Tile(cc.p(G_ROLE_MAIN:getPosition()))
                if math.abs(cur.x - endPoint.x) < 2 and math.abs(cur.y - endPoint.y) < 2 then
               --if self:isInArea(1) then
                    self:addEscortEffect()
                    self:stopAction(self.pointAction)
                    self.pointAction = nil 
                    self:updateState()
                end
            end)
        end
        ,
        function()  
            self:addTalk(327)
        end
        ,

        function()  
            local record = getConfigItemByKey("storyTalk", "q_id", 328)
            local str = string.format(record.q_text, role_name) 
            self:addTalk(328, nil, nil, str) 
        end
        ,
        function()
            self:addTaskInfo(1)
            G_MAINSCENE:setFullShortNode(false)
            self:showHangNode()
            self:addSkill()
            G_MAINSCENE.operate_node:setLocalZOrder(199)
            G_MAINSCENE.skill_node:setLocalZOrder(199)
             G_MAINSCENE.bloodNode:setLocalZOrder(199) 
            self.m_manualFight = true
            for k, v in pairs(self.RolesAI) do
                if not v.cannot_attack then
                    v:fight()
                end
            end
            --startTimerAction(self, 1.0, false, function() self:addFocusEff(4) end)
            startTimerAction(self, 3.0, false, function() for k, v in pairs(self.RolesAI) do if v  then v.m_startLockTarget = true end end  end)
            
            startTimerAction(self, 2, false, function() game.setAutoStatus(AUTO_ATTACK); self.m_canPlayerHurt = true end)
            local has_added = false
            local addPlayer2 = function()
                if not has_added then
                    for k,v in pairs(self.players_tab[4]) do
                        if v.storyai then
                            v.storyai.cannot_attack = nil
                        end
                        v:setVisible(true)
                    end
                    for k, v in pairs(self.RolesAI) do
                        if not v.cannot_attack then
                            v:fight()
                        end
                    end
                    has_added = true
                end
            end
            startTimerAction(self, 5, false, addPlayer2)
            local loop_num = 0
            self.hurtAction = startTimerAction(self, 0.1, true, function() 
                    local bAllDie = true
                    local left_num = 0
                    loop_num = loop_num + 1
                    for m, n in pairs(self.playerTab[2]) do
                        if n ~= nil and n:isVisible() and n:getHP() > 0 then
                            bAllDie = false
                            left_num = left_num + 1
                        end
                    end
                    if self.link_label and loop_num%5 == 0 then
                        local left_number = 10-left_num
                        if not has_added then
                            left_number = 5 - left_num
                        end
                        self.link_label:setString("击退劫镖之敌二："..left_number.."/10")
                    end
                    if bAllDie then
                        if has_added then   
                            self:hideHangNode()
                            game.setAutoStatus(0)              
                            self:stopAction(self.hurtAction)
                            self.hurtAction = nil                         
                            self.needAutoAtk = 0  
                            self.m_canPlayerHurt = false
                            self:removeSkill()
                            self.m_manualFight = nil
                            for k, v in pairs(self.RolesAI) do
                                v:idle()
                            end             
                            self:updateState()
                        else
                            addPlayer2()
                        end
                    end                    
            end)
        end
        ,
        -- function()
        --     for k,v in pairs(self.players_tab[4]) do
        --         if v.storyai then
        --             v.storyai.cannot_attack = nil
        --         end
        --         v:setVisible(true)
        --     end
        --     for k, v in pairs(self.RolesAI) do
        --         if not v.cannot_attack then
        --             v:fight()
        --         end
        --     end
        --     self.needAutoAtk = 0
        --     game.setAutoStatus(0)
        --     G_MAINSCENE.map_layer:moveMapByPos(cc.p(90, 200), false)
        --     startTimerAction(self, 1, false, function() self.needAutoAtk = 2 end)
        --     self.hurtAction = startTimerAction(self, 0.1, true, function() 
        --             local bAllDie = true
        --             for m, n in pairs(self.playerTab[2]) do
        --                 if n ~= nil and n:isVisible() and n:getHP() > 0 then
        --                     bAllDie = false
        --                     break
        --                 end
        --             end
        --             if bAllDie then                      
        --                 self:stopAction(self.hurtAction)
        --                 self.hurtAction = nil                         
        --                 self.needAutoAtk = 0  
        --                 self.m_canPlayerHurt = false
        --                 self:removeSkill()
        --                 self.m_manualFight = nil             
        --                 self:updateState()
        --             end                    
        --     end)
        -- end
        -- ,
        function()
            self:addTaskInfo(8)  
            local endPoint = cc.p(90, 200)
            self:SoldierMove(endPoint)
            G_MAINSCENE.map_layer:moveMapByPos(endPoint, false)
            self.pointAction = startTimerAction(self, 0.1, true, function() 
                local cur = G_MAINSCENE.map_layer:space2Tile(cc.p(G_ROLE_MAIN:getPosition()))
                if math.abs(cur.x - endPoint.x) < 2 and math.abs(cur.y - endPoint.y) < 2 then
               --if self:isInArea(1) then
                    self:stopAction(self.pointAction)
                    self.pointAction = nil 
                    self:updateState()
                end
            end)
        end
        ,
        function()  
            local record = getConfigItemByKey("storyTalk", "q_id", 329)
            local str = string.format(record.q_text, role_name) 
            self:addTalk(329, nil, nil, str)
        end
        ,

        function()  
            local record = getConfigItemByKey("storyTalk", "q_id", 330)
            local str = string.format(record.q_text, role_name) 
            self:addTalk(330, nil, nil, str)
        end
        ,
        function()  
            self:addTalk(331)
        end
        ,

        function()  
            self:addTalk(332) 
        end
        ,
        function()  
            self:addWinFlg()
            startTimerAction(self, 2, false, function() self:updateState() end)                  
        end
        ,
        function()
            --addFBTipsEffect(self, cc.p(display.width/2, display.height/2), "res/fb/win_2.png")
            g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_FINISH_SINGLEINST, "FinishSingleInstProtocol", {instID = 20});
            self:addTaskInfo(10)
            self:SoldierMove(self.m_defenderPos,true) 
            local disappearFunc = function()
                for k,v in pairs(self.playerTab[1])do
                    v:setVisible(false)
                end
                self.dart_monster:setVisible(false)
            end
            startTimerAction(self, 3, false, disappearFunc)  
            G_MAINSCENE:setFullShortNode(false)
            self:addSkill()
            G_MAINSCENE.operate_node:setLocalZOrder(199)
            G_MAINSCENE.skill_node:setLocalZOrder(199)
             G_MAINSCENE.bloodNode:setLocalZOrder(199) 
            self.m_manualFight = true           
        end
        ,
        --通关传送门进入皇宫
        function()
            self:endStroy()                    
        end
        ,
    }

    if switch[self.state] then 
        switch[self.state]()
    end
end

function StoryDartEscort:addEscortEffect(is_add)
    if self.escort_effect then
        removeFromParent(self.escort_effect)
        self.escort_effect = nil
    end
    if is_add then
        self.escort_effect = Effects:create(false)
        self.escort_effect:setPosition(cc.p(g_scrSize.width/2,150))
        self:addChild(self.escort_effect, 199)
        self.escort_effect:playActionData("autoescort", 14, 1, -1, 0)
        createSprite( self.escort_effect , "res/mainui/card_flag.png" , cc.p( -35 , 21 ) , cc.p( 0 , 0 ) )
    end
end


function StoryDartEscort:addSoldier()
    --self.soldier = {}
--[[
    local pos = {cc.p(41, 71),  cc.p(42, 72), cc.p(43, 73), cc.p(44, 74),
                cc.p(39, 73),  cc.p(40, 74), cc.p(41, 75), cc.p(42, 76),}
]]
    --self.soldier = {}
    local pos = {cc.p(60, 186), cc.p(61, 185),
                 cc.p(62, 186) }

    local add =  cc.p(0, 0)            
    for i,v in ipairs(pos) do
        local entity = 
        {
            [ROLE_MODEL] = 9005,
            [ROLE_HP] = 20000,
        }
           
        local soldier = G_MAINSCENE.map_layer:addMonster(v.x + add.x, v.y + add.y, 20036, nil, 1000+i, entity)
        if soldier then
            soldier:setSpriteDir(2)
            soldier:standed()
            soldier:setMaxHP(20000)
            --startTimerAction(soldier, 1, true, function() soldier:standed() soldier:setSpriteDir(1) end)
            soldier:setNameLabel("")
            soldier:setNameColor(MColor.green)
            --table.insert(self.soldier, soldier)
            local ai = require("src/layers/story/StoryAISoldier").new(self, soldier)
            ai:onCollide(1.5)
            ai.camp = 1
            soldier.storyai = ai
            table.insert(self.RolesAI, ai)
            table.insert(self.playerTab[1], soldier)
            soldier.camp = 1
            soldier:showNameAndBlood(false, 0)
            soldier:initAttackStatus(6)
        end
        --G_MAINSCENE.map_layer.monster_tab[1000+i] = nil
    end
end

function StoryDartEscort:addDartMonster()
    local entity = 
        {
            [ROLE_MODEL] = 80003,
            [ROLE_HP] = 20000,
            [ROLE_HP] = 20000,
        }
           
    local soldier = G_MAINSCENE.map_layer:addMonster(65 , 185 , 4000002, nil, 2000, entity)
    if soldier then
        soldier:setSpriteDir(2)
        soldier:standed()
        soldier:setMaxHP(20000)
        table.insert(self.playerTab[1], soldier)
        soldier.camp = 1
        soldier:setNameColor(MColor.green)
        soldier:setSpeed(0.45)
        --soldier:showNameAndBlood(true, 0)
        self.dart_monster = soldier
    end
    G_MAINSCENE.map_layer.monster_tab[2000] = nil
end

function StoryDartEscort:addBaiguPlayerer()
    local params = {}
    params[ROLE_SCHOOL] = 3
    params[PLAYER_SEX] = 1
    params[ROLE_HP] = 9999
    params[ROLE_LEVEL] = 999  
    params[ROLE_MAX_HP] = 9999
    params[ROLE_NAME] = "道尊·百谷"
    params[PLAYER_EQUIP_WEAPON] = 5130107
    params[PLAYER_EQUIP_UPPERBODY] = 5130507
    params[PLAYER_EQUIP_WING] = 6031    
    local MpropOp = require "src/config/propOp"
    local w_resId = MpropOp.equipResId(params[PLAYER_EQUIP_UPPERBODY])
    if w_resId == 0 then w_resId = g_normal_close_id end
    local w_resId = G_ROLE_MAIN:getRightResID(PLAYER_EQUIP_UPPERBODY,w_resId+params[PLAYER_SEX]*100000)
    local player = G_MAINSCENE.map_layer:makeMainRole(59, 185, "role/".. w_resId, 3, false, 803, params)
    if params[PLAYER_EQUIP_WEAPON] > 0 then
        local w_resId = MpropOp.equipResId(params[PLAYER_EQUIP_WEAPON])
        w_resId = G_ROLE_MAIN:getRightResID(PLAYER_EQUIP_WEAPON ,w_resId)
        local w_path = "weapon/" .. (w_resId)
        G_ROLE_MAIN:setEquipment_ex(player,PLAYER_EQUIP_WEAPON,w_path)
    end
    if params[PLAYER_EQUIP_WING] > 0 then
        local w_resId = getConfigItemByKey("WingCfg","q_ID",params[PLAYER_EQUIP_WING] ,"q_senceSouceID")
        w_resId = G_ROLE_MAIN:getRightResID(PLAYER_EQUIP_WING,w_resId+100000)
        local w_path = "wing/" .. (w_resId)
        G_ROLE_MAIN:setEquipment_ex(player,PLAYER_EQUIP_WING,w_path)
    end
    local ai = require("src/layers/story/StoryAISoldier").new(self, player)
    ai.camp = 1
    player.storyai = ai
    table.insert(self.RolesAI, ai)
    table.insert(self.playerTab[1], player)
    self.baigu_player = player
    player.camp = 1
end


function StoryDartEscort:SoldierMove(pos,move_dart)
    local end_pos = pos or cc.p(100,25)
    for k,v in pairs(self.playerTab[1])do
        local paths = G_MAINSCENE.map_layer:moveMonsterByPos(cc.p(end_pos.x+2-k,end_pos.y-1), v, 2, false)
        local move_time = 0.3
        if v:getType() > 15 then
            move_time = 0.25
        end
        G_MAINSCENE.map_layer:moveByPaths(paths, v, v:getTag(), move_time)
    end
    if self.dart_monster and move_dart then
        local objid = self.dart_monster:getTag()
        G_MAINSCENE.map_layer.monster_tab[2000] = objid
        local paths = G_MAINSCENE.map_layer:moveMonsterByPos(cc.p(end_pos.x,end_pos.y-2), self.dart_monster, 2, false)
        G_MAINSCENE.map_layer:moveByPaths(paths, self.dart_monster, objid, 0.3)
        G_MAINSCENE.map_layer.monster_tab[2000] = nil
    end
end

function StoryDartEscort:PlayerMove()
    for k,v in pairs(self.playerTab[2])do
        if v:isVisible() then
            local start_pos = G_MAINSCENE.map_layer:space2Tile(cc.p(v:getPosition()))
            local paths = G_MAINSCENE.map_layer:moveMonsterByPos(cc.p(start_pos.x-10,start_pos.y), v, 2, false)
            G_MAINSCENE.map_layer:moveByPaths(paths, v, v:getTag(), 0.3)
        end
    end
end

--创建角色
function StoryDartEscort:createPlayers(mapId, order)    
    local items = require("src/config/storyPlayer")
    local item_count = 0
    self.players_tab = {}
    self.players_tab[1] = {}
    self.players_tab[2] = {}
    self.players_tab[3] = {}
    self.players_tab[4] = {}
    local pos = {cc.p(60, 181),  cc.p(61, 182), cc.p(62, 183), cc.p(64, 184),cc.p(63, 185),
                cc.p(75, 180),  cc.p(75, 181), cc.p(75, 182), cc.p(74, 181),cc.p(74, 180), 
                cc.p(101, 191),  cc.p(100, 192), cc.p(102, 193), cc.p(101, 194),cc.p(102, 195),  
                cc.p(91, 210),  cc.p(92, 209), cc.p(93, 210), cc.p(94, 208),cc.p(95, 209), }
    for i = 1, #items do   
        if mapId == items[i].q_mapid and order == items[i].q_order and items[i].q_camp == 2 then
            local cfg = items[i]
            local params = {}
            params[ROLE_SCHOOL] = cfg.q_school
            params[PLAYER_SEX] = cfg.q_sex
            params[ROLE_HP] = cfg.q_hp*2
            params[ROLE_LEVEL] = cfg.q_level  
            params[ROLE_MAX_HP] = cfg.q_hp*2
            params[ROLE_NAME] = cfg.q_name
            params[PLAYER_EQUIP_WEAPON] = cfg.q_weapon
            params[PLAYER_EQUIP_UPPERBODY] = cfg.q_body
            params[PLAYER_EQUIP_WING] = cfg.q_wing  
            local MpropOp = require "src/config/propOp"
            local w_resId = MpropOp.equipResId(params[PLAYER_EQUIP_UPPERBODY])
            if w_resId == 0 then w_resId = g_normal_close_id end
            local w_resId = G_ROLE_MAIN:getRightResID(PLAYER_EQUIP_UPPERBODY,w_resId+params[PLAYER_SEX]*100000)
            local player = G_MAINSCENE.map_layer:makeMainRole(pos[item_count+1].x,pos[item_count+1].y, "role/".. w_resId, 3, false, cfg.q_id, params)
            if params[PLAYER_EQUIP_WEAPON] > 0 then
                local w_resId = MpropOp.equipResId(params[PLAYER_EQUIP_WEAPON])
                w_resId = G_ROLE_MAIN:getRightResID(PLAYER_EQUIP_WEAPON ,w_resId)
                if w_resId and w_resId > 0 then
                    local w_path = "weapon/" .. (w_resId)
                    G_ROLE_MAIN:setEquipment_ex(player,PLAYER_EQUIP_WEAPON,w_path)
                end
            end
      --[[      if params[PLAYER_EQUIP_WING] > 0 then
                local w_resId = getConfigItemByKey("WingCfg","q_ID",params[PLAYER_EQUIP_WING] ,"q_senceSouceID")
                w_resId = G_ROLE_MAIN:getRightResID(PLAYER_EQUIP_WING,w_resId+100000)
                local w_path = "wing/" .. (w_resId)
                G_ROLE_MAIN:setEquipment_ex(player,PLAYER_EQUIP_WING,w_path)
            end
    ]]        
            player:initStandStatus(4, 6, 1, 1)
            player:setSpriteDir(cfg.q_dir)
            player:standed()   
           -- player:showNameAndBlood(false, 0)
            if cfg.q_camp == 1 then
                --player:setNameColor(MColor.blue)
                local name_label = player:getNameBatchLabel()
                if name_label then
                    name_label:setColor(MColor.name_blue)
                end

                player:setFactionName_ex(player, game.getStrByKey("story_gongsha_factionname1"))
            else
                --player:setNameColor(MColor.orange)
                local name_label = player:getNameBatchLabel()
                if name_label then
                    name_label:setColor(MColor.name_orange)
                end

                player:setFactionName_ex(player, game.getStrByKey("story_gongsha_factionname2"))
            end
            table.insert(self.players_tab[math.floor(item_count/5)+1], player)
            player.camp = cfg.q_camp

            --关联AI
            local destPos2 = pos[item_count+1]
            if item_count >= 5 and item_count < 10 then
                destPos2 = cc.p(pos[item_count+1].x-math.ceil(math.random(1,5)),pos[item_count+1].y)
            elseif item_count >= 10  and item_count < 15 then
                destPos2 = cc.p(pos[item_count+1].x-10,pos[item_count+1].y)
            elseif item_count >= 15 then
                destPos2 = cc.p(pos[item_count+1].x-10,pos[item_count+1].y-math.ceil(math.random(1,8)))
            end
            table.insert(self.playerTab[2], player)
            local ai = require("src/layers/story/StoryAIPlayer").new(self, player, cfg.q_school, destPos2, destPos2, cfg.q_camp, cfg.q_target)
            ai:onCollide(1.5)
            player.storyai = ai
            table.insert(self.RolesAI, ai)
            if item_count >= 5 then
                ai.cannot_attack = true
                player:setVisible(false)
            end
            --法师添加魔法盾效果
            if cfg.q_school == 2 then
                local topNode = player:getTopNode()
                if topNode ~= nil and not topNode:getChildByTag(80) then
                    local skill_effect = Effects:create(false)
                    skill_effect:setPosition(cc.p(0, 0))
                    skill_effect:playActionData("skill2004/loop", 4, 1, -1)
                    addEffectWithMode(skill_effect,3)
                    topNode:addChild(skill_effect, 20, 80)
                end
            end
            item_count = item_count + 1 
            if item_count >= 20 then
                break
            end 
        end     
    end  
end

function StoryDartEscort:createDefender()
    --添加传送点
    self.m_defenderPos = cc.p(100, 195)
    local transforEffect = Effects:create(false)
    transforEffect:setAnchorPoint(cc.p(0.5, 0.5))
    local t_pos = G_MAINSCENE.map_layer:tile2Space(self.m_defenderPos)
    transforEffect:setPosition(t_pos)
    G_MAINSCENE.map_layer:addChild(transforEffect)
    transforEffect:playActionData("transfor", 15, 2, -1)
    transforEffect:setScale(1.1)
    transforEffect:setColor(MColor.green)
    createSprite(G_MAINSCENE.map_layer,"res/mapui/transfor/2500.png",t_pos,cc.p(0.5,0.0),3)
end

function StoryDartEscort:addTaskInfo(idx)  
    self:delTaskInfo()
    self.link_label = nil
    if idx <= 3 then
        local function go() 
            game.setAutoStatus(AUTO_ATTACK)
        end
        self.m_tastBg = createTouchItem(self, "res/common/bg/bg62.png",cc.p(142, g_scrSize.height-155) , go, false)   
        local strTitle = game.getStrByKey("story_gongsha_target_title")
        createLabel(self.m_tastBg, strTitle, cc.p(38,53),cc.p(0,0.5),20,nil,nil,nil,MColor.yellow)
        local link_str = {"一：","二："}
        self.link_label = createLinkLabel(self.m_tastBg, "击退劫镖之敌"..link_str[idx].."0/10", cc.p(38,25),cc.p(0,0.5), 20, false, nil, MColor.lable_yellow, nil, go, true)

        self.m_tastBg:setPosition(cc.p(-140, g_scrSize.height-155))
        self.m_tastBg:runAction(cc.MoveTo:create(1, cc.p(142, g_scrSize.height-155)))
    elseif idx == 10 then
        self.timeCount = 5
        self.m_tastBg = createSprite(self , "res/common/bg/bg62.png" , cc.p(2, g_scrSize.height-155) , cc.p( 0, 0.5 ) ) 
        -- self.m_tastBg = createTouchItem(self, "res/common/bg/bg62.png",cc.p(142, g_scrSize.height-155) , function() end, false)   
        local label = createLabel(self.m_tastBg, "完成", cc.p(38,38),cc.p(0,0.5),20,nil,nil,nil,MColor.lable_yellow)
        self.exitConfirm = function()
            self:endStroy()
        end
        self.exitConfirm = function()
            self:endStroy()
        end
        self.timeAction = startTimerAction(self, 1, true, function()           
            self.timeCount = self.timeCount - 1
            --local text = string.format(str, self.timeCount) 
            self.level_str:setString(game.getStrByKey("fb_leave").."("..self.timeCount..")")
            if self.timeCount <= 0 then
                self:stopAction(self.timeAction)
                self.timeAction = nil
                self:updateState()
            end
        end )
    end
end

function StoryDartEscort:endStroy()
    g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_EXITCOPY,"ExitCopyProtocol", {})

    self.isEnd = true
    game.setAutoStatus(0)

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

    

    --G_MAINSCENE:exitStoryMode()
end

return StoryDartEscort