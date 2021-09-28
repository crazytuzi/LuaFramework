local StoryShouShaHG = class("StoryShouShaHG", require ("src/layers/story/shousha/StoryShouSha"))

local path = "res/storygs/"

function StoryShouShaHG:ctor()
    require ("src/layers/story/shousha/StoryShouSha").ctor(self) 
    self.RolesAI = {}
    self.playerTab = {{},{},{}}
end

function StoryShouShaHG:updateState()  
    print("[StoryShouShaHG:updateState] ..... state = " .. self.state)
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
            
            startTimerAction(self, 0.4, false, function()                   
                    self:changeRoleDress(true)                         

                    local name_label = G_ROLE_MAIN:getNameBatchLabel()
                    if name_label then
                       self.mainRoleColor = name_label:getColor()
                       name_label:setColor(MColor.name_blue)
                    end

                    G_ROLE_MAIN:setFactionName_ex(G_ROLE_MAIN, game.getStrByKey("story_gongsha_factionname2"), true)
                    G_ROLE_MAIN:setTitle_ex(G_ROLE_MAIN, 0)
                    local pos = cc.p(22, 23) -- 22, 23
                    G_ROLE_MAIN:setPosition(G_MAINSCENE.map_layer:tile2Space(pos))
                    G_MAINSCENE.map_layer:initDataAndFunc(pos)
                    G_MAINSCENE.map_layer:setDirectorScale(nil, pos)
                    G_MAINSCENE.map_layer:moveMapByPos(cc.p(pos.x, pos.y), false)
                    G_ROLE_MAIN:setSpriteDir(7)
                    G_ROLE_MAIN:standed()

                    -- self.haveTsxlEffect = G_MAINSCENE.tslx_effect and true or false
                    -- G_MAINSCENE:addTsxlEffect(1)
                    -- G_MAINSCENE.tslx_effect:setLocalZOrder(199)
                    self:createExitBtn()
                    self:createDefender()
                    for k,v in pairs(self.RolesAI) do 
                        v:setState(1)
                    end
                    --AudioEnginer.setIsNoPlayEffects(false)
                   end)

            startTimerAction(self, 2, false, function() self:updateState()  end)
        end
        ,

        function()  
            self:addTalk(201)
        end
        ,
        function()
            self:addTaskInfo(1)
            self.m_manualFight = true
            G_MAINSCENE:shaWarTimeStart(5)            
            startTimerAction(self, 0.0, false, function() 
                    self.needAutoAtk = 1 
                    self.m_canPlayerHurt = true
                    for k,v in pairs(self.RolesAI) do 
                        v:setState(1)
                    end
                end)
            startTimerAction(self, 5, false, function() self:updateState() end)
        end
        ,

        function()
            G_MAINSCENE:setFullShortNode(false)
            self:addSkill()
            G_MAINSCENE.operate_node:setLocalZOrder(199)
            G_MAINSCENE.skill_node:setLocalZOrder(199)
            G_MAINSCENE.bloodNode:setLocalZOrder(199)
            self:createHangNode()

            self:createAttacker(1)
            self:addFocusEff(4)
            startTimerAction(self, 0.2, false, function() for k,v in pairs(self.RolesAI) do v:fight() v.m_startLockTarget = true end end)
            --startTimerAction(self, 2, false, function() self.needAutoAtk = 1 self.m_canPlayerHurt = true end)

            AudioEnginer.playEffect("sounds/storyVoice/gs6.mp3",false)
            self.hurtAction = startTimerAction(self, 0.1, true, function() 
                    local bAllDie = true
                    for m, n in pairs(self.playerTab[self.hositleTeam]) do
                        if n ~= nil and n:isVisible() and n:getHP() > 0 then
                            bAllDie = false
                            break
                        end
                    end

                    if bAllDie then                      
                        self:stopAction(self.hurtAction)
                        self.hurtAction = nil                             
                        self:updateState()
                    end                    
            end)         
        end
        ,

        function()  
            self:createAttacker(2)
            startTimerAction(self, 0.1, false, function() for k,v in pairs(self.RolesAI) do v:fight() end end)
            self.hurtAction = startTimerAction(self, 0.1, true, function() 
                    local bAllDie = true
                    for m, n in pairs(self.playerTab[self.hositleTeam]) do
                        if n ~= nil and n:isVisible() and n:getHP() > 0 then
                            bAllDie = false
                            break
                        end
                    end

                    if bAllDie then                      
                        self:stopAction(self.hurtAction)
                        self.hurtAction = nil                             
                        self:updateState()
                    end                    
            end)                 
        end
        ,

        function()  
            self:createAttacker(3)
            startTimerAction(self, 0.1, false, function() for k,v in pairs(self.RolesAI) do v:fight() end end)
            self.hurtAction = startTimerAction(self, 0.1, true, function()
                    if G_ROLE_MAIN:getHP() <= 10 then
                        
                        self:stopAction(self.hurtAction)
                        self.hurtAction = nil

                        game.setAutoStatus(0)                             
                        if self.exitBtn then
                            self.exitBtn:setVisible(false)
                        end
                        G_MAINSCENE.skill_node:setLocalZOrder(1)
                        G_MAINSCENE.operate_node:setLocalZOrder(6)
                        G_MAINSCENE.bloodNode:setLocalZOrder(6)
                        self:hideHangNode()

                        self.m_manualFight = false
                        local target_type = G_ROLE_MAIN:getType()
                        if target_type == 22 then
                            G_ROLE_MAIN:gotoDeath(6)
                        else
                            G_ROLE_MAIN:gotoDeath(7)
                        end 
                        
                        self:showTextTips("story_shousha_tip1", nil, true)
                        --移除魔法盾效果
                        local topNode = G_ROLE_MAIN:getTopNode()
                        if topNode ~= nil and topNode:getChildByTag(80) ~= nil then
                            topNode:removeChildByTag(80)
                        end                        

                        G_ROLE_MAIN:showNameAndBlood(false)
                        startTimerAction(self, 2, false, function() self:updateState() end)
                    end 
            end)  
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

function StoryShouShaHG:endStroy()
    if self.isExitBtnCall then
        g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_EXITCOPY,"ExitCopyProtocol", {})
        addNetLoading(COPY_CS_EXITCOPY,FRAME_SC_ENTITY_ENTER)
    else
        local proto = {}
        proto.copyId = 6008
        proto.isInCopy = 1
        g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_ENTERCOPY, "EnterCopyProtocol", proto);
    end
    
    self.isEnd = true
    game.setAutoStatus(0)
    self:hideHangNode()

    if self.schedulerHandle then 
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry( self.schedulerHandle ) 
        self.schedulerHandle = nil
    end 

    --移除魔法盾效果
    setGameSetById(GAME_SET_ID_SHIELD_PLAYER, self.m_bHidePlayer, true)
    for m, n in pairs(self.playerTab[1]) do
        if n ~= nil and n:getHP() == 0 and n ~= G_ROLE_MAIN then
            n:setVisible(false)
        end
    end

    --移除中毒效果
    G_ROLE_MAIN:setColor(cc.c3b(255, 255, 255))

    for m, n in pairs(self.playerTab[2]) do
        if n ~= nil and n:getHP() == 0 then
            n:setVisible(false)
        end
    end

    for m, n in pairs(self.playerTab[3]) do
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

    --G_MAINSCENE:addTsxlEffect(self.haveTsxlEffect)
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

    
    --g_msgHandlerInst:sendNetDataByTableExEx(SHAWAR_CS_REQUEST_UPDATE_MONIWAR_STAGE, "ShaWarRequestUpdateMoniWarStage", {stage=3})

    --G_MAINSCENE:exitStoryMode()
end

function StoryShouShaHG:createDefender()
    --战神孟虎
    local cfg = {}
    cfg.q_id = 10000
    cfg.q_school = 1
    cfg.q_sex = 1
    cfg.q_level = 999
    cfg.q_hp = 999
    cfg.q_name = "战神·孟虎"
    cfg.q_weapon = 5110107
    cfg.q_body = 5110507
    cfg.q_wing = 4031
    cfg.q_src_x = 23
    cfg.q_src_y = 22
    cfg.q_dir = 7
    cfg.teamId = self.factionTeam
    local zhanshi = self:createPlayerBycfg(cfg)
    self.zhanshi = zhanshi
    zhanshi:setFactionName_ex(zhanshi, game.getStrByKey("story_gongsha_factionname2"), true)
    local ai = require("src/layers/story/shousha/StoryShouShaPlayer").new(self, zhanshi, cfg.q_school,self.factionTeam)
    zhanshi.storyai = ai
    table.insert(self.RolesAI, ai)    

    local num = 20
    local startIndex = math.random(5, 30)
    local items = require("src/config/storyPlayer")
    for i=1,num do
        local cfg = copyTable(items[i + startIndex])
        cfg.q_src_x = math.random(14, 20)
        cfg.q_src_y = math.random(18, 23)
        cfg.teamId = self.factionTeam
        local player = self:createPlayerBycfg(cfg, true)
        table.insert(self.playerTab[self.factionTeam], player)
        player:setFactionName_ex(player, game.getStrByKey("story_gongsha_factionname2"), true)

        --关联AI
        local ai = require("src/layers/story/shousha/StoryShouShaPlayer").new(self, player, cfg.q_school,self.factionTeam)
        player.storyai = ai
        table.insert(self.RolesAI, ai)
    end
    table.insert(self.playerTab[self.factionTeam], G_ROLE_MAIN)
end

local stepStart = math.random(40, 80)
function StoryShouShaHG:createAttacker(step)
    local num = 8
    if step == 1 then
        num = 8
    elseif step == 2 then
        num = 15
    elseif step == 3 then
        num = 20
    end
    
    local posCfg = {{cc.p(10, 22), cc.p(15, 26)},
                    {cc.p(21, 15), cc.p(26, 19)},}
    self.step = step or 1
    
    local items = require("src/config/storyPlayer")
    for i=1,num do
        local cfg = copyTable(items[i + step * 20 + stepStart])
        local randIndex = math.random(1, 2)
        local tempindex = (i > num/ 2) and 1 or 2
        local pos = posCfg[tempindex][randIndex]
        cfg.q_src_x = math.random(1, 3) + pos.x
        cfg.q_src_y = math.random(1, 3) + pos.y        
        
        cfg.teamId = self.hositleTeam
        local player = self:createPlayerBycfg(cfg)
        table.insert(self.playerTab[self.hositleTeam], player)
        player:setFactionName_ex(player, game.getStrByKey("story_gongsha_factionname1"))

        --关联AI
        local ai = require("src/layers/story/shousha/StoryShouShaPlayer").new(self, player, cfg.q_school,self.hositleTeam)
        player.storyai = ai
        table.insert(self.RolesAI, ai)

        if step == 3 and i == 1 then
            self.specPlayer = player
            ai:setTargetID(G_ROLE_MAIN:getTag())
        end
    end
end

function StoryShouShaHG:getHurtNum(skillID, target)
    if target == self.specPlayer or target == self.zhanshi then
        return 0 
    elseif skillID == 1006 then
        return math.random(2000,3600)
    elseif skillID == 1004 then
        return math.random(500,1000)
    elseif skillID == 1003 then
        return math.random(800,1500)
    elseif skillID == 1010 then
        return math.random(1000,2000)
    elseif skillID == 2010 then
        return math.random(1000,2000)
    elseif skillID == 2011 then
        return math.random(400,600)
    elseif skillID == 3011 then
        return math.random(900,1800)
    elseif skillID == 3004 then
        return math.random(60,100)
    elseif skillID == 9999 then   --神兽
        return math.random(100,150)
    elseif skillID == 9998 then   --士兵
        return math.random(10,14)
    elseif skillID == 9997 then   --怪物
        return math.random(8,12)
    else
        return 100
    end
end

function StoryShouShaHG:getHurtNumPlayer(skillID, player, target)
    local num = 0
    if target == G_ROLE_MAIN then
        num = math.random(1, 3)
        if self.step == 3 and player == self.specPlayer then
            if self.exitBtn then
                self.exitBtn:setVisible(false)
            end
            self.notAddHp = true
            num = math.random(target:getMaxHP()/3, target:getMaxHP()/2)
        end
    elseif target == self.specPlayer then
        num = 0
    elseif skillID == 1006 then
        num = math.random(600,800)
    elseif skillID == 1003 then
        num = math.random(600,800)
    elseif skillID == 2010 then
        num = math.random(600,800)
    elseif skillID == 2011 then
        num = math.random(200,300)
    elseif skillID == 3011 then
        num = math.random(600,800)
    elseif skillID == 3004 then
        num = math.random(100,150)
    else
        num = 100
    end     

    if player and player.teamId == self.factionTeam then
        if self.step ~= 3 then
            num = num * 5
        else
            num = num
        end
    end

    return num
end

return StoryShouShaHG