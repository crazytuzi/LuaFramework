local StoryWaKuang = class("StoryWaKuang", require ("src/layers/story/StoryGongSha"))

local path = "res/storygs/"

function StoryWaKuang:ctor()
	G_STORY_FB_MODE = true
    self.state = 0
    self.playerTab = {{},{}}
    self.RolesAI = {}

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

  --[[              if self.needAutoAtk == 2 then
                    game.setAutoStatus(AUTO_ATTACK)
                elseif self.needAutoAtk == 5 then
                    
                else
                    game.setAutoStatus(0)
                end
]]
                self:updateHangNode()
            end

            self.schedulerHandle = cc.Director:getInstance():getScheduler():scheduleScriptFunc(updateAI, 1.5, false)
        elseif event == "exit" then
            if self.schedulerHandle then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerHandle)
                self.schedulerHandle = nil
            end 
        end
    end)

    
end

function StoryWaKuang:updateState()  

	self.state = self.state + 1

	local switch = {
        function()
            --给地图添加黑底
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
                       --[[
                       local name_label = G_ROLE_MAIN:getNameBatchLabel()
                       if name_label then
                           self.mainRoleColor = name_label:getColor()
                           name_label:setColor(MColor.name_blue)
                       end

                       G_ROLE_MAIN:setFactionName_ex(G_ROLE_MAIN, game.getStrByKey("story_gongsha_factionname1"))
                       G_ROLE_MAIN:setTitle_ex(G_ROLE_MAIN, 0)
                       ]]

                       G_ROLE_MAIN:setCarry_ex(G_ROLE_MAIN, {})
                       G_MAINSCENE.map_layer:setBlockRectValue(cc.rect(99,38,1,1), "1")

                       G_ROLE_MAIN:setPosition(G_MAINSCENE.map_layer:tile2Space(cc.p(97,54)))
                       G_MAINSCENE.map_layer:initDataAndFunc(cc.p(97,54))
                       G_MAINSCENE.map_layer:setDirectorScale(nil, cc.p(97,54))
                       G_MAINSCENE.map_layer:moveMapByPos(cc.p(97,55), false)
                       G_ROLE_MAIN:setSpriteDir(3) 

                       self:addMonster()
                       self:addMine()
                       self:createExitBtn()
                       --AudioEnginer.setIsNoPlayEffects(false)                                  
                   end)

            startTimerAction(self, 1, false, function() self:updateState()  end)
        end
        ,

        --开场对话
        function()  
            self:addTalk(80)
        end
        ,

        function()  
            local record = getConfigItemByKey("storyTalk", "q_id", 81)
            local str = string.format(record.q_text, require("src/layers/role/RoleStruct"):getAttr(ROLE_NAME))
            self:addTalk(81, nil, nil, str) 
        end
        ,

        function()  
            self:addTaskInfo(1)
            self:addPathPoint(cc.p(97,40), false)
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

        --消灭僵尸
        function()              
            startTimerAction(self, 0.1, false, function() for k, v in pairs(self.RolesAI) do if v  then v:fight() end end end)          
            startTimerAction(self, 0.1, false, function() self.needAutoAtk = 1; self.m_canPlayerHurt = true end)
            self.hurtAction = startTimerAction(self, 0.1, true, function() 
                    local bAllDie = true
                    local bHaveDie = false
                    for m, n in pairs(self.playerTab[2]) do
                        if n ~= nil and n:isVisible() and n:getHP() > 0 then
                            bAllDie = false
                        end

                        if n ~= nil and n:isVisible() and n:getHP() == 0 then
                            bHaveDie = true
                        end
                    end

                    if G_ROLE_MAIN then
                        local pos = G_MAINSCENE.map_layer:space2Tile(cc.p(G_ROLE_MAIN:getPosition()))
                        if pos.x > 94 and pos.x < 100 and pos.y > 37 and pos.y < 43 then
                             self:removePathPoint()
                        end
                    end

                    if bHaveDie then
                        self:removePathPoint()
                    end

                    if bAllDie then                      
                        self:stopAction(self.hurtAction)
                        self.hurtAction = nil                         
                        self.needAutoAtk = 0  
                        self.m_canPlayerHurt = false                                     
                        self:updateState()
                    end                    
            end) 
        end
        ,

        function()            
            self.m_manualFight = false
            self:hideOperPanel()
            game.setAutoStatus(0)  
            startTimerAction(self, 0.3, false, function() self:updateState() end)            
        end
        ,

        function() 
            self:delTaskInfo() 
            local record = getConfigItemByKey("storyTalk", "q_id", 82)
            local str = string.format(record.q_text, require("src/layers/role/RoleStruct"):getAttr(ROLE_NAME))
            self:addTalk(82, nil, nil, str) 
        end
        ,

        --采矿
        function() 
            self.canTouchMine = true 
            self:addFinger() 
            self:addTaskInfo(2)
            self:removeSpecialSkillSelEffect()
            startTimerAction(self, 0.3, false, function() 
                        self.m_manualFight = true
                        G_MAINSCENE.operate_node:setLocalZOrder(199)
                        G_MAINSCENE.bloodNode:setLocalZOrder(199)
                        --G_MAINSCENE.skill_node:setLocalZOrder(199)  
                        --self:showHangNode()                     
                        self:updateState() 
                   end) 
        end
        ,

        --统计采矿数量
        function()
            local mineCount = 0  
            local timeAdd = 0
            self.hurtAction = startTimerAction(self, 0.1, true, function() 
                    if G_ROLE_MAIN:getCurrActionState() == ACTION_STATE_EXCAVATE then
                        timeAdd = timeAdd + 0.1
                        if timeAdd > 3 then
                            timeAdd = 0
                            mineCount = mineCount + 1
                            local mT = {}
                            for i=1,mineCount do
                                local item = {}
                                item.matId = 6200032
                                item.time = os.time() + 50000
                                table.insert(mT,item)
                            end
                            G_ROLE_MAIN:setCarry_ex(G_ROLE_MAIN, mT) 
                            self.m_curMineCount = mineCount
                            self:updateMineCountLabel()                          
                        end
                        self:setAutoMine(true)
                    else
                        self:setAutoMine(false)
                    end                  

                    if mineCount >= 3 then                      
                        self:stopAction(self.hurtAction)
                        self.hurtAction = nil  
                        self:setAutoMine(false)                                                                          
                        self:updateState()
                    end                    
            end) 
        end
        ,

        --红名恶人出现
        function() 
            self.m_manualFight = false 
            self.needAutoAtk = 0  
            game.setAutoStatus(0) 
            self.canTouchMine = false 
            self:addRole()
            G_ROLE_MAIN:standed()
            G_ROLE_MAIN:isChangeToHoe(G_ROLE_MAIN,false)
            self:hideOperPanel()
            self:delTaskInfo()
            self:addTalk(83)
        end
        ,

        --击杀红名恶人
        function()  
            self:addTaskInfo(3)
            startTimerAction(self, 1.0, false, function() self:updateState() end) 
        end
        ,

        function()  
            self.m_manualFight = true
            self:showOperPanel()
            self.eRen.storyai:fight()

            startTimerAction(self, 0.1, false, function() self.needAutoAtk = 1; self.m_canPlayerHurt = true end)
            self.hurtAction = startTimerAction(self, 0.1, true, function() 
                    local bAllDie = true
                    if self.eRen ~= nil and self.eRen:isVisible() and self.eRen:getHP() > 0 then
                         bAllDie = false
                    end

                    if bAllDie then                      
                        self:stopAction(self.hurtAction)
                        self.hurtAction = nil                         
                        self.needAutoAtk = 0  
                        self.m_canPlayerHurt = false               
                        self:updateState()
                    end                    
            end)
        end
        ,

        function()  
            G_MAINSCENE.map_layer:resetTouchTag()
            G_ROLE_MAIN:setCarry_ex(G_ROLE_MAIN, {})
            self.m_manualFight = false 
            self:hideOperPanel()
            game.setAutoStatus(0)
            self:delTaskInfo()
            self:addTalk(84)                
        end
        ,

        function()  
            self:addWinFlg()
            startTimerAction(self, 2, false, function() self:updateState() end)                  
        end
        ,

        function()  
             g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_FINISH_SINGLEINST, "FinishSingleInstProtocol", {instID = 14});
             self:addTaskInfo(4)                      
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

function StoryWaKuang:endStroy()
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

    --self:removePathPoint()  

    G_MAINSCENE.map_layer:setMapActionFlag(true)
    G_MAINSCENE:removeChildByTag(1256)

    G_ROLE_MAIN.base_data.spe_skill = {}
    G_MAINSCENE.map_layer:resetSpeed(g_speed_time)

    G_ROLE_MAIN:setCarry_ex(G_ROLE_MAIN, {})

--[[   local name_label = G_ROLE_MAIN:getNameBatchLabel()
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
]]
    --g_msgHandlerInst:sendNetDataByTableExEx(SHAWAR_CS_REQUEST_UPDATE_MONIWAR_STAGE, "ShaWarRequestUpdateMoniWarStage", {stage=3})

    

    --G_MAINSCENE:exitStoryMode()
end

function StoryWaKuang:addMonster(order)    
    local createMonster = function(param)
        local entity =
        {
            [ROLE_MODEL] = param.q_monster_model,
            [ROLE_HP] = param.q_hp,
            [ROLE_MAX_HP] = param.q_hp,
        }

        local monster = G_MAINSCENE.map_layer:addMonster(param.q_x, param.q_y, param.q_featureid, nil, param.q_id, entity)
        --monster:initStandStatus(4, 6, 1, 5)
        monster:standed()
        startTimerAction(self, 1, false, function() monster:setHP(param.q_hp); monster:showNameAndBlood(true, 0) end)

        table.insert(self.playerTab[2], monster)
        monster.camp = 2
        monster.model = param.q_monster_model

        local name_label = monster:getNameBatchLabel()
        if name_label then
            name_label:setColor(MColor.name_orange)
        end

        local ai = require("src/layers/story/mine/StoryAIMonsterWK").new(self, monster)
        monster.storyai = ai
        table.insert(self.RolesAI, ai)

        return monster
    end

    local param = {q_id=900, q_x=27, q_y=41, q_hp=2000, q_monster_model=357, q_featureid=20103}
    local pT = {cc.p(93, 42),cc.p(103, 41),cc.p(95, 44),cc.p(91, 43),cc.p(99, 45)}
    for i = 1, 5 do
        param.q_x = pT[i].x
        param.q_y = pT[i].y
        param.q_id = param.q_id + 1
        if G_MAINSCENE and not G_MAINSCENE.map_layer:isBlock(cc.p(param.q_x, param.q_y)) then
            createMonster(param)
        end                 
    end   
end

function StoryWaKuang:addMine()      
    local createMonster = function(param)
        local entity =
        {
            [ROLE_MODEL] = param.q_monster_model,
            [ROLE_HP] = param.q_hp,
            [ROLE_MAX_HP] = param.q_hp,
        }

        local monster = G_MAINSCENE.map_layer:addMonster(param.q_x, param.q_y, param.q_featureid, nil, param.q_id, entity)
        --monster:initStandStatus(4, 6, 1, 5)
        monster:standed()
        --startTimerAction(self, 1, false, function() monster:setHP(param.q_hp); monster:showNameAndBlood(true, 0) end)
        return monster
    end

    self.minePos = cc.p(99,38)
    local param = {q_id=950, q_x=self.minePos.x, q_y=self.minePos.y, q_hp=2000, q_monster_model=21, q_featureid=31134}
    self.mineNode = createMonster(param)    
end

function StoryWaKuang:addRole()
	if G_ROLE_MAIN == nil then
		return
	end

    local createRole = function(params, id, posx, posy, dir)
        local MpropOp = require "src/config/propOp"
        local w_resId = MpropOp.equipResId(params[PLAYER_EQUIP_UPPERBODY])
        if w_resId == 0 then w_resId = g_normal_close_id end
        local w_resId = G_ROLE_MAIN:getRightResID(PLAYER_EQUIP_UPPERBODY,w_resId+params[PLAYER_SEX]*100000)
        local player = G_MAINSCENE.map_layer:makeMainRole(posx, posy, "role/".. w_resId, 3, false, id, params)
        if params[PLAYER_EQUIP_WEAPON] > 0 then
            local w_resId = MpropOp.equipResId(params[PLAYER_EQUIP_WEAPON])
            w_resId = G_ROLE_MAIN:getRightResID(PLAYER_EQUIP_WEAPON ,w_resId)
            local w_path = "weapon/" .. (w_resId)
            G_ROLE_MAIN:setEquipment_ex(player,PLAYER_EQUIP_WEAPON,w_path)
        end

        player:initStandStatus(4, 6, 1, 1)
        player:setSpriteDir(dir)
        player:standed() 
        
        G_ROLE_MAIN:setSpecialTitle(player, 11) 

        table.insert(self.playerTab[2], player)
        player.camp = 2

        local name_label = player:getNameBatchLabel()
        if name_label then
            name_label:setColor(MColor.name_red)
        end

        -- 关联AI
        local ai = require("src/layers/story/mine/StoryAIPlayerWK").new(self, player, params[ROLE_SCHOOL])
        player.storyai = ai
        table.insert(self.RolesAI, ai)

        return player
    end

	--战士
	local params = {}
	params[ROLE_SCHOOL] = 1
    params[PLAYER_SEX] = 1
    params[ROLE_HP] = 9999
    params[ROLE_LEVEL] = 50  
    params[ROLE_MAX_HP] = 9999
    params[ROLE_NAME] = "恶人"
    params[PLAYER_EQUIP_WEAPON] = 5110107
    params[PLAYER_EQUIP_UPPERBODY] = 5110507
    params[PLAYER_EQUIP_WING] = 4031
    
    local getPos = function()
        local curPos = G_MAINSCENE.map_layer:space2Tile(cc.p(G_ROLE_MAIN:getPositionX(), G_ROLE_MAIN:getPositionY()))
        local pT = { cc.p(-1, 0), cc.p(-1, 1), cc.p(0, 1), cc.p(1, 1), cc.p(1, 0), cc.p(1, - 1), cc.p(0, - 1), cc.p(-1, - 1), }
       
        for j = 6, 1, -1 do 
            for i = 1, #pT do  
                local n = math.random(1, 8)       
                local new = cc.p(curPos.x + pT[n].x*j, curPos.y + pT[n].y*j)
                if not G_MAINSCENE.map_layer:isBlock(new) then
                    return new
                end
            end
        end

        return curPos
    end	


    local rolePos = getPos()
    self.eRen = createRole(params, 801, rolePos.x, rolePos.y, 6)
end

function StoryWaKuang:addTaskInfo(idx)  
    self:delTaskInfo()

    local callback = function() end
    if idx == 1 then
        callback = function()        
            local dstPos = cc.p(97,40)
            local curPos = G_MAINSCENE.map_layer:space2Tile(cc.p(G_ROLE_MAIN:getPositionX(), G_ROLE_MAIN:getPositionY()))
            if curPos.x ~= dstPos.x or curPos.y ~= dstPos.y then
                G_MAINSCENE.map_layer:registerWalkCb(function() game.setAutoStatus(AUTO_ATTACK) end)
                G_MAINSCENE.map_layer:moveMapByPos(dstPos, false)
            else
                game.setAutoStatus(AUTO_ATTACK)
            end       
        end              
    elseif idx == 2 then
        callback = function() self:onTouchMine() end
    elseif idx == 3 then
        callback = function() game.setAutoStatus(AUTO_ATTACK) end
    end  

    self.m_tastBg = createTouchItem(self, "res/common/bg/bg62.png",cc.p(142, g_scrSize.height-155) , callback, false) 
    local strTitle = game.getStrByKey("story_gongsha_target_title")
    local bgLabel = createLabel(self.m_tastBg, strTitle, cc.p(38,53),cc.p(0,0.5),20,nil,nil,nil,MColor.yellow)
       
    local strTab = {"story_wakuang_target1","story_wakuang_target2","story_wakuang_target3","story_wakuang_target4"}
    local str = game.getStrByKey(strTab[idx])
    if idx == 1 then
        createLinkLabel(self.m_tastBg, str, cc.p(38,25),cc.p(0,0.5), 20, false, nil, MColor.lable_yellow, nil, callback, true)
    elseif idx == 2 then
        if self.m_curMineCount == nil then self.m_curMineCount = 0 end
        local text = string.format(game.getStrByKey("story_wakuang_target2"), self.m_curMineCount)
        self.m_MineCountLabel = createLinkLabel(self.m_tastBg, text, cc.p(38,25),cc.p(0,0.5), 20, false, nil, MColor.lable_yellow, nil, callback, true) 
    elseif idx == 3 then  
        createLinkLabel(self.m_tastBg, str, cc.p(38,25),cc.p(0,0.5), 20, false, nil, MColor.lable_yellow, nil, callback, true)     
    elseif idx == 4 then
        self.timeCount = 5
        self.m_bFinishedCopy = true
        bgLabel:setVisible(false)   
        createLabel(self.m_tastBg, "完成", cc.p(38,38),cc.p(0,0.5),20,nil,nil,nil,MColor.lable_yellow)

        self.timeAction = startTimerAction(self, 1, true, function()           
            self.timeCount = self.timeCount - 1
            if self.exitBtnLabel then
                self.exitBtnLabel:setString(game.getStrByKey("fb_leave").."("..self.timeCount..")")
            end
            if self.timeCount <= 0 then
                self:stopAction(self.timeAction)
                self.timeAction = nil
                self:updateState()
            end
        end )
    else
        createLabel(self.m_tastBg, str, cc.p(38,25),cc.p(0,0.5),20,nil,nil,nil,MColor.lable_yellow)
    end

    self.m_tastBg:setPosition(cc.p(-140, g_scrSize.height-155))
    self.m_tastBg:runAction(cc.MoveTo:create(1, cc.p(142, g_scrSize.height-155)))
end

function StoryWaKuang:updateMineCountLabel() 
    if self.m_MineCountLabel then
        removeFromParent(self.m_MineCountLabel)
        self.m_MineCountLabel = nil
    end

    local function go() 
        self:onTouchMine()
    end
        
    if self.m_curMineCount == nil then self.m_curMineCount = 0 end
    local text = string.format(game.getStrByKey("story_wakuang_target2"), self.m_curMineCount)
    self.m_MineCountLabel = createLinkLabel(self.m_tastBg, text, cc.p(38,25),cc.p(0,0.5), 20, false, nil, MColor.lable_yellow, nil, go, true) 
end

function StoryWaKuang:onTouchMine()
    if not self.canTouchMine or G_MAINSCENE == nil or G_ROLE_MAIN == nil then
        return
    end

    if self.tutoFinger then
        removeFromParent(self.tutoFinger)
        self.tutoFinger = nil
    end

    local getDirOfTarget = function(role)
        if role == nil then
            return 0
        end

        local dx =(role:getPositionX() - G_ROLE_MAIN:getPositionX())
        local dy =(role:getPositionY() - G_ROLE_MAIN:getPositionY())
        if (math.abs(dx) / math.abs(dy)) > 5 then
            if dx < 0 then
                return 4
            else
                return 0
            end
        elseif (math.abs(dx) / math.abs(dy)) < 0.2 then
            if dy < 0 then
                return 6
            else
                return 2
            end
        else
            if dx > 0 and dy > 0 then
                return 1
            elseif dx < 0 and dy > 0 then
                return 3
            elseif dx < 0 and dy < 0 then
                return 5
            else
                return 7
            end
        end

        return 0
    end

    local getPos = function()      
        local pos = cc.p(self.minePos.x, self.minePos.y)
        local pT = {cc.p(-2, 0),cc.p(-2, 2),cc.p(0, 2),cc.p(2, 2),cc.p(2, 0),cc.p(2, -2),cc.p(0, -2),cc.p(-2, -2),}
        local dir = getDirOfTarget(self.mineNode)
        pos.x = pos.x + pT[dir + 1].x
        pos.y = pos.y + pT[dir + 1].y

        return pos
    end

    --采集动作  
    local WalkCb = function()
        self.needAutoAtk = 5
        game.setAutoStatus(AUTO_MINE)
       
        --面向矿
        local dir = getDirOfTarget(self.mineNode)
        G_ROLE_MAIN:setSpriteDir(dir)
    end

    local dstPos = getPos(self.mineNode)
    local curPos = G_MAINSCENE.map_layer:space2Tile(cc.p(G_ROLE_MAIN:getPositionX(), G_ROLE_MAIN:getPositionY()))
    if curPos.x ~= dstPos.x or curPos.y ~= dstPos.y then
        G_MAINSCENE.map_layer:registerWalkCb(WalkCb)
        G_MAINSCENE.map_layer:moveMapByPos(dstPos, false)
    else
        WalkCb()
    end
end

function StoryWaKuang:setAutoMine(show)
    if self.autoMine == nil then
        self.autoMine = Effects:create(false)
        self.autoMine:playActionData("automine", 14, 1, -1, 0)
        self:addChild(self.autoMine, 99, 123)
        self.autoMine:setAnchorPoint(cc.p(0.5, 0.5))
        self.autoMine:setPosition(cc.p(display.cx, display.cy - 100))
    end
    
    self.autoMine:setVisible(show)
end

function StoryWaKuang:addFinger()
    local topNode = self.mineNode:getTopNode()
    if self.tutoFinger == nil and topNode then
        self.tutoFinger = Effects:create(false)
        self.tutoFinger:playActionData("tutoFinger", 14, 1.2, -1)
        topNode:addChild(self.tutoFinger, 99999)
        self.tutoFinger:setAnchorPoint(cc.p(0.5, 0.5))
        self.tutoFinger:setPosition(cc.p(0, 0))
    end
end

return StoryWaKuang