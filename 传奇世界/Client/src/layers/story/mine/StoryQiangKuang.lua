local StoryQiangKuang = class("StoryQiangKuang", require ("src/layers/story/StoryGongSha"))

local path = "res/storygs/"

function StoryQiangKuang:ctor()
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

    --[[            if self.needAutoAtk == 2 then
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

function StoryQiangKuang:updateState()  

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
                       G_MAINSCENE.map_layer:setBlockRectValue(cc.rect(106,40,1,1), "1")
                       G_MAINSCENE.map_layer:setBlockRectValue(cc.rect(90,40,1,1), "1")
                       G_MAINSCENE.map_layer:setBlockRectValue(cc.rect(95,35,1,1), "1")

                       G_ROLE_MAIN:setPosition(G_MAINSCENE.map_layer:tile2Space(cc.p(97,54)))
                       G_MAINSCENE.map_layer:initDataAndFunc(cc.p(97,54))
                       G_MAINSCENE.map_layer:setDirectorScale(nil, cc.p(97,54))
                       G_MAINSCENE.map_layer:moveMapByPos(cc.p(97,55), false)
                       G_ROLE_MAIN:setSpriteDir(3) 

                       self:addRole()
                       self:addMine()
                       self:createExitBtn()
                       --AudioEnginer.setIsNoPlayEffects(false)                                  
                   end)

            startTimerAction(self, 1.0, false, function() self:updateState()  end)
        end
        ,

        --开场对话
        function()  
            self:addTalk(85)
        end
        ,
        --首次攻击
        function()  
            self:addTaskInfo(1)
            self:addPathPoint(cc.p(97,44), false)
            startTimerAction(self, 1.0, false, function() 
                        self.m_manualFight = true
                        G_MAINSCENE:setFullShortNode(false)                      
                        self:addSkill()   
                        self:createHangNode()  
                        self:showOperPanel()                                        
                   end) 
        end
        ,

        --恶人说话
        function()  
             self:removePathPoint()
             self.m_manualFight = false
             self:hideOperPanel() 
             game.setAutoStatus(0)  
             self:addTalk(86)
        end
        ,

        function()  
            startTimerAction(self, 0.3, false, function() 
                        self.m_manualFight = true 
                        self:showOperPanel() 
                        game.setAutoStatus(AUTO_ATTACK)
                        self:updateState()                                         
                   end)               
        end
        ,

        function() 
            self.eRen.storyai:fight()
            startTimerAction(self, 0.1, false, function() self.m_canPlayerHurt = true end)        
        end
        ,

        --小岩拾取提示说话
        function()  
             self.m_manualFight = false
             self:hideOperPanel() 
             game.setAutoStatus(0)
             self:addTalk(87)
        end
        ,

        function()            
            startTimerAction(self, 0.3, false, function() 
                        self.m_manualFight = true 
                        self:showOperPanel() 
                        game.setAutoStatus(AUTO_ATTACK)
                        self:updateState()                                         
                   end)               
        end
        ,

        --是否已拾取足够的矿石
        function()  
            self:showPickTips()
            self.canTouchMine = true
            local timeAdd = 0
            self.hurtAction = startTimerAction(self, 0.1, true, function() 
                    if G_ROLE_MAIN:getCurrActionState() == ACTION_STATE_EXCAVATE then
                        timeAdd = timeAdd + 0.1
                        if timeAdd > 10 then
                            timeAdd = 0
                            self.m_curMineCount = self.m_curMineCount + 1
                            self:updateMineCountLabel() 
                            local mT = {}
                            for i=1,self.m_curMineCount do
                                local item = {}
                                item.matId = 6200032
                                item.time = os.time() + 50000
                                table.insert(mT,item)
                            end
                            G_ROLE_MAIN:setCarry_ex(G_ROLE_MAIN, mT)                       
                        end
                        self:setAutoMine(true)
                        G_MAINSCENE.skill_node:setLocalZOrder(1)
                        self:hideHangNode()
                    else
                        self:setAutoMine(false)
                        G_MAINSCENE.skill_node:setLocalZOrder(199)
                        self:showHangNode()
                    end 
                    
                    if self.m_curMineCount >= 8 then                      
                        self:stopAction(self.hurtAction)
                        self.hurtAction = nil                         
                        self.needAutoAtk = 0  
                        self.m_canPlayerHurt = false                                     
                        self:updateState()
                    end                    
            end) 
        end
        ,

        --小岩结束说话
        function()  
             self.canTouchMine = false
             self.m_manualFight = false
             game.setAutoStatus(0)
             self:setAutoMine(false)
             G_ROLE_MAIN:standed()
             G_ROLE_MAIN:isChangeToHoe(G_ROLE_MAIN,false)            
             self:hideOperPanel() 
             self:addTalk(88)
        end
        ,

        function()  
            self:addWinFlg()
            startTimerAction(self, 2, false, function() self:updateState() end)                  
        end
        ,

        function()  
             g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_FINISH_SINGLEINST, "FinishSingleInstProtocol", {instID = 15});
             self:addTaskInfo(2)               
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

function StoryQiangKuang:endStroy()
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

function StoryQiangKuang:addMine()      
    local createMonster = function(param)
        local entity =
        {
            [ROLE_MODEL] = param.q_monster_model,
            [ROLE_HP] = param.q_hp,
            [ROLE_MAX_HP] = param.q_hp,
        }

        local monster = G_MAINSCENE.map_layer:addMonster(param.q_x, param.q_y, param.q_featureid, nil, param.q_id, entity)
        monster:standed()
        return monster
    end

    local param = {q_id=950, q_x=99, q_y=38, q_hp=2000, q_monster_model=21, q_featureid=31134}
    self.mineNode1 = createMonster(param) 
    
    param = {q_id=951, q_x=106, q_y=40, q_hp=2000, q_monster_model=21, q_featureid=31134}
    self.mineNode2 = createMonster(param) 
    
    param = {q_id=952, q_x=90, q_y=40, q_hp=2000, q_monster_model=21, q_featureid=31134}
    self.mineNode3 = createMonster(param) 
    
    param = {q_id=953, q_x=95, q_y=35, q_hp=2000, q_monster_model=21, q_featureid=31134}
    self.mineNode4 = createMonster(param)    
end

function StoryQiangKuang:addRole()
	if G_ROLE_MAIN == nil then
		return
	end

    local createRole = function(params, id, posx, posy, dir, beRen)
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

        if beRen then
            table.insert(self.playerTab[2], player)
        end
        
        player.camp = 2

        local name_label = player:getNameBatchLabel()
        if name_label then
            if params[ROLE_SCHOOL]== 1 then
                name_label:setColor(MColor.name_red)
            else
                name_label:setColor(MColor.name_orange)
            end
        end

        G_ROLE_MAIN:setSpecialTitle(player, params[PLAYER_SPECIAL_TITLE_ID])

        -- 关联AI
        local ai = require("src/layers/story/mine/StoryAIPlayerQK").new(self, player, params[ROLE_SCHOOL])
        player.storyai = ai
        table.insert(self.RolesAI, ai)


        --头顶矿石
        local mT = {}
        for i = 1, 2 do
            local item = { }
            item.matId = 6200032
            item.time = os.time() + 50000
            table.insert(mT, item)
        end
        G_ROLE_MAIN:setCarry_ex(player, mT) 
        
        --做挖矿动作
        G_ROLE_MAIN:isChangeToHoe(player,true)
        player:excavateToTheDir(0.6, dir) 

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
    params[PLAYER_SPECIAL_TITLE_ID] = 11
      
    self.eRen = createRole(params, 801, 99, 41, 2, true)

    params[ROLE_SCHOOL] = 2
    params[PLAYER_SEX] = 1
    params[ROLE_HP] = 9999
    params[ROLE_LEVEL] = 50  
    params[ROLE_MAX_HP] = 9999
    params[ROLE_NAME] = "敌方行会玩家"
    params[PLAYER_EQUIP_WEAPON] = 5120107
    params[PLAYER_EQUIP_UPPERBODY] = 5120507
    params[PLAYER_EQUIP_WING] = 5031
    params[PLAYER_SPECIAL_TITLE_ID] = 81

    self.m_other1 = createRole(params, 802, 104, 40, 0, false)
    self.m_other2 = createRole(params, 803, 90, 38, 6, false)
    self.m_other3 = createRole(params, 804, 98, 35, 4, false)
end

function StoryQiangKuang:addTaskInfo(idx)  
    self:delTaskInfo()

    local callback = function() end
    if idx == 1 then
        callback = function() 
            game.setAutoStatus(AUTO_ATTACK) 
            self:removeSpecialSkillSelEffect()
            G_ROLE_MAIN:isChangeToHoe(G_ROLE_MAIN,false)
        end
    end  

    --self.m_tastBg = createSprite(self , "res/common/bg/bg62.png" , cc.p(2, g_scrSize.height-155) , cc.p( 0, 0.5 ) )  
    self.m_tastBg = createTouchItem(self, "res/common/bg/bg62.png",cc.p(142, g_scrSize.height-155) , callback, false) 
    local strTitle = game.getStrByKey("story_gongsha_target_title")
    local bgLabel = createLabel(self.m_tastBg, strTitle, cc.p(38,53),cc.p(0,0.5),20,nil,nil,nil,MColor.yellow)
       
    local strTab = {"story_qingkuang_target1","story_qingkuang_target2",}
    local str = game.getStrByKey(strTab[idx])
    if idx == 1 then       
        if self.m_curMineCount == nil then self.m_curMineCount = 0 end
        local text = string.format(str, self.m_curMineCount)
        self.m_MineCountLabel = createLinkLabel(self.m_tastBg, text, cc.p(38,25),cc.p(0,0.5), 20, false, nil, MColor.lable_yellow, nil, callback, true)
        --self.m_MineCountLabel = createLabel(self.m_tastBg, text, cc.p(38,25),cc.p(0,0.5),20,nil,nil,nil,MColor.lable_yellow)

    elseif idx == 2 then
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

function StoryQiangKuang:updateMineCountLabel() 
    if self.m_MineCountLabel then
        removeFromParent(self.m_MineCountLabel)
        self.m_MineCountLabel = nil
    end
    
    local function callback()       
        game.setAutoStatus(AUTO_ATTACK)
        G_ROLE_MAIN:isChangeToHoe(G_ROLE_MAIN,false)
    end
        
    if self.m_curMineCount == nil then self.m_curMineCount = 0 end
    local text = string.format(game.getStrByKey("story_qingkuang_target1"), self.m_curMineCount)
    self.m_MineCountLabel = createLinkLabel(self.m_tastBg, text, cc.p(38, 25), cc.p(0, 0.5), 20, false, nil, MColor.lable_yellow, nil, go, true)
    --self.m_MineCountLabel = createLabel(self.m_tastBg, text, cc.p(38,25),cc.p(0,0.5),20,nil,nil,nil,MColor.lable_yellow)
end

function StoryQiangKuang:showHurt(skillId,targets) 
    if targets == nil or G_MAINSCENE == nil then
        return
    end
    
    if not self.m_bFirstAttack then
        self.m_bFirstAttack = true
        G_ROLE_MAIN:isChangeToHoe(self.eRen,false)
        self.eRen:standed()
        self:updateState() 
        return
    end

    if not self.m_canPlayerHurt then
        return
    end

    local hurt_num = self:getHurtNum(skillId)
    for k,v in pairs(targets)do        
        if v == self.baobao or v == G_ROLE_MAIN then
            return
        end
        
        if v.storyai and v.storyai.m_state == 0 then v.storyai:fight() end
        
        local rr = tolua.cast(v, "SpriteMonster") 
        if rr and rr:getHP() > 0 and hurt_num > 0 then
            G_MAINSCENE.map_layer:showHurtNumer(hurt_num, cc.p(v:getPosition()), cc.p(G_ROLE_MAIN:getPosition()), 0.3, nil, false)
        end

        local dropGoods = function(hurt_item)
            if hurt_item == self.eRen and not self.m_ERenDead then
                self.m_ERenDead = true
                table.insert(self.playerTab[2], self.m_other1)
                table.insert(self.playerTab[2], self.m_other2)
                table.insert(self.playerTab[2], self.m_other3)
                startTimerAction(self, 0.01, false, function() self:updateState() end) 
            end
                       
            if self.dropIdx == nil then
                self.dropIdx = 1120
            end
                       
            for j=1,2 do
                local posAdd = { cc.p(-1, 1), cc.p(-1, 0), cc.p(-1, - 1), cc.p(0, - 1), cc.p(0, 1), cc.p(1, 1), cc.p(1, 0), cc.p(1, - 1) }
                local myPos = G_MAINSCENE.map_layer:space2Tile(cc.p(hurt_item:getPosition()))
                local n = math.random(1,8)%8
                for i =1, #posAdd do
                    local new = cc.p(myPos.x + posAdd[n+1].x*j, myPos.y + posAdd[n+1].y*j)
                    if not G_MAINSCENE.map_layer:isBlock(new) then
                        myPos = new
                        break
                    end
                    
                    n = (n + 1)%8
                end


                local entity =
                {
                    [ROLE_MODEL] = 6200032,
                    [ROLE_HP] = 2000,
                }

                self.dropIdx = self.dropIdx + 1
                G_MAINSCENE.map_layer:addDropOut(myPos.x, myPos.y, self.dropIdx, entity)
            end
        end
       
        local func = function()
            if G_MAINSCENE == nil then
                return
            end
            
            local hurt_item = tolua.cast(v, "SpriteMonster")
            if hurt_item and hurt_item:getHP() > 0 then
                local cur_hp = hurt_item:getHP() - hurt_num
                if cur_hp < 0 then
                    cur_hp = 0
                end
                hurt_item:setHP(cur_hp)
                if G_MAINSCENE.map_layer.monster_head and tolua.cast(G_MAINSCENE.map_layer.monster_head, "cc.Node") then
                    G_MAINSCENE.map_layer.monster_head:updateInfo(hurt_item)
                end
                if cur_hp <= 0 then
                    local topNode = hurt_item:getTopNode()
                    if topNode ~= nil and topNode:getChildByTag(80) then
                        topNode:removeChildByTag(80)
                    end 
                    
                    local target_type = hurt_item:getType()
                    if target_type == 22 then
                        hurt_item:gotoDeath(6)
                    else
                        hurt_item:gotoDeath(7)
                    end  
                    self:resetTouch(hurt_item)

                    dropGoods(hurt_item)
                    G_ROLE_MAIN:setCarry_ex(hurt_item, {}) 
                    
                    startTimerAction(hurt_item, 2.0, false, function() hurt_item:setVisible(false) end)                                          
                end
            elseif hurt_item and hurt_item:getHP() < 1 and hurt_item:getCurrActionState() == ACTION_STATE_IDLE then
                local topNode = hurt_item:getTopNode()
                if topNode ~= nil and topNode:getChildByTag(80) then
                    topNode:removeChildByTag(80)
                end 
                
                if target_type == 22 then   --野蛮冲撞等无法执行死亡动作
                    hurt_item:gotoDeath(6)
                else
                    hurt_item:gotoDeath(7)
                end
                self:resetTouch(hurt_item)

                dropGoods(hurt_item)
                G_ROLE_MAIN:setCarry_ex(hurt_item, {}) 

                startTimerAction(hurt_item, 2.0, false, function() hurt_item:setVisible(false) end) 
            end
        end
        performWithDelay(G_MAINSCENE.map_layer.item_Node, func, 0.3 + 0.15)
    end   
end

function StoryQiangKuang:onPickGoods()
    self.m_curMineCount = self.m_curMineCount + 1
    self:updateMineCountLabel() 

    local mT = { }
    for i = 1, self.m_curMineCount do
        local item = { }
        item.matId = 6200032
        item.time = os.time() + 50000
        table.insert(mT, item)
    end
    G_ROLE_MAIN:setCarry_ex(G_ROLE_MAIN, mT)  
end

function StoryQiangKuang:canPick()
    return true
end

function StoryQiangKuang:setAutoMine(show)
    if self.autoMine == nil and not show then
        return
    end

    if self.autoMine == nil then
        self.autoMine = Effects:create(false)
        self.autoMine:playActionData("automine", 14, 1, -1, 0)
        self:addChild(self.autoMine, 99, 123)
        self.autoMine:setAnchorPoint(cc.p(0.5, 0.5))
        self.autoMine:setPosition(cc.p(display.cx, display.cy - 100))
    end
    
    self.autoMine:setVisible(show)
end

function StoryQiangKuang:onTouchMine(mine_node)
     --先杀掉挖矿的敌方角色
    if G_MAINSCENE == nil or G_ROLE_MAIN == nil then
        return
    end
    
    if (mine_node == self.mineNode1 and self.eRen:getHP() > 0) or (mine_node == self.mineNode2 and self.m_other1:getHP() > 0) or
       (mine_node == self.mineNode3 and self.m_other2:getHP() > 0) or (mine_node == self.mineNode4 and self.m_other3:getHP() > 0) then
        
        self.m_canShowTips = true
        TIPS( { type = 1 , str = game.getStrByKey( "story_qingkuang_tips" ) } )
        self.m_canShowTips = false 
        return
    end
    
    if not self.canTouchMine then
        return
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
        local pos = G_MAINSCENE.map_layer:space2Tile(cc.p(mine_node:getPositionX(), mine_node:getPositionY()))
        local pT = {cc.p(-2, 0),cc.p(-2, 2),cc.p(0, 2),cc.p(2, 2),cc.p(2, 0),cc.p(2, -2),cc.p(0, -2),cc.p(-2, -2),}
        local dir = getDirOfTarget(mine_node)
        pos.x = pos.x + pT[dir + 1].x
        pos.y = pos.y + pT[dir + 1].y

        return pos
    end

    --采集动作  
    local WalkCb = function()
        self:removeSpecialSkillSelEffect()
        self.needAutoAtk = 5
        game.setAutoStatus(AUTO_MINE)
       
        --面向矿
        local dir = getDirOfTarget(mine_node)
        G_ROLE_MAIN:setSpriteDir(dir)
    end

    local dstPos = getPos()
    local curPos = G_MAINSCENE.map_layer:space2Tile(cc.p(G_ROLE_MAIN:getPositionX(), G_ROLE_MAIN:getPositionY()))
    if curPos.x ~= dstPos.x or curPos.y ~= dstPos.y then
        G_MAINSCENE.map_layer:registerWalkCb(WalkCb)
        G_MAINSCENE.map_layer:moveMapByPos(dstPos, false)
    else
        WalkCb()
    end
end

function StoryQiangKuang:showPickTips()
    --给技能按钮添加特效
    local function addEffect(btn)
        if btn then
            local effect = Effects:create(false)
            effect:playActionData("newFunctionExSmall", 19, 2, -1)
            btn:addChild(effect)
            effect:setAnchorPoint(cc.p(0.5, 0.5))
            effect:setPosition(cc.p(-97, 208))
            effect:setScale(0.8)
            effect:setTag(123)

            startTimerAction(effect, 3, false, function() removeFromParent(effect) end)
        end
    end

    --添加提示
    local node = G_MAINSCENE.skill_node:getCenterItem()  
    addEffect(node)  
end

function StoryQiangKuang:isCanShowTips()
    return self.m_canShowTips
end

return StoryQiangKuang