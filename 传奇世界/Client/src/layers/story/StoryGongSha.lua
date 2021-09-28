local StoryGongSha = class("StoryGongSha", require ("src/layers/story/StoryBase"))

local path = "res/storygs/"

function StoryGongSha:ctor()
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

    local function outBtnFun()
        self:endStroy()
    end

    --[[local outBtn = createMenuItem(self, "res/empire/shaWar/btn1.png", cc.p(g_scrSize.width - 60, 420), outBtnFun)
    outBtn:setOpacity(0)
    outBtn:runAction(cc.Sequence:create(cc.FadeIn:create(0.5)))
    outBtn:setLocalZOrder(400)
    outBtn:setVisible(false)
    self.m_outBtn = outBtn
    ]]
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

            self.schedulerHandle = cc.Director:getInstance():getScheduler():scheduleScriptFunc(updateAI, 1.5, false)
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

function StoryGongSha:updateState()  

	self.state = self.state + 1

	local switch = {
        function()
            local masking = cc.LayerColor:create(cc.c4b(0, 0, 0, 255))
            self:addChild(masking, 10000)   
            masking:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.FadeOut:create(0.2))) 
            
            self.m_bHidePlayer = getGameSetById(GAME_SET_ID_SHIELD_PLAYER)                       
            setGameSetById(GAME_SET_ID_SHIELD_PLAYER, 0, true) 
            
            startTimerAction(self, 0.05, false, function() G_ROLE_MAIN:upOrDownRide(false) end ) 
                                         
            startTimerAction(self, 0.4, false, function()
                       self:changeRoleDress(true)                                             
                                              
                       self:setBlock() 
                       --self:setBlock2()                     
                       local name_label = G_ROLE_MAIN:getNameBatchLabel()
                       if name_label then
                           self.mainRoleColor = name_label:getColor()
                           name_label:setColor(MColor.name_blue)
                       end

                       G_ROLE_MAIN:setFactionName_ex(G_ROLE_MAIN, game.getStrByKey("story_gongsha_factionname1"))
                       G_ROLE_MAIN:setTitle_ex(G_ROLE_MAIN, 0)

                       G_ROLE_MAIN:setPosition(G_MAINSCENE.map_layer:tile2Space(cc.p(171,140)))
                       G_MAINSCENE.map_layer:initDataAndFunc(cc.p(171,140))
                       G_MAINSCENE.map_layer:setDirectorScale(nil, cc.p(171,140))
                       G_MAINSCENE.map_layer:moveMapByPos(cc.p(170, 139), false)
                       G_ROLE_MAIN:setSpriteDir(3)                      
                       self:createPlayers(2116,1) 
                       self:createDefender()

                       if self.m_isFBMode then
                           self:createExitBtn()
                       end
                                                    
                       --AudioEnginer.setIsNoPlayEffects(false)           
                   end)

            startTimerAction(self, 2.0, false, function() self:updateState()  end)
        end
        ,

        function()  
            self:addTalk(101)
        end
        ,

        function()  
            local record = getConfigItemByKey("storyTalk", "q_id", 102)
            local str = string.format(record.q_text, require("src/layers/role/RoleStruct"):getAttr(ROLE_NAME))
            self:addTalk(102, nil, nil, str) 
        end
        ,

        function()  
            self:addTalk(103)
        end
        ,

        function()  
            local record = getConfigItemByKey("storyTalk", "q_id", 104)
            local str = string.format(record.q_text, require("src/layers/role/RoleStruct"):getAttr(ROLE_NAME))
            self:addTalk(104, nil, nil, str) 
        end
        ,

        --向复活点移动
        function()                       
            self:addTaskInfo(1)
            G_MAINSCENE:setFullShortNode(false)
            self:addSkill()           
            self:createHangNode() 
            self:showOperPanel()
            self.m_manualFight = true
            StoryGongSha.m_hurtCount = 0
            self.m_needLianZhanEffect = true
                
            self.noPlayerAttackResult = true       
            local endPoint = cc.p(133,106)
            self:addPathPoint(endPoint, true)
            self.pointAction = startTimerAction(self, 0.1, true, function() 
               if self:isInArea(1) then
                    self:removePathPoint() 
                    self:stopAction(self.pointAction)
                    self.pointAction = nil 
                    self.noPlayerAttackResult = false
                    self:addTaskInfo(3)
                    self.m_canPlayerHurt = true
                    AudioEnginer.playEffect("sounds/storyVoice/gs2.mp3",false)
                end
            end)
                               
            for k, v in pairs(self.RolesAI) do
                v:fight()
            end

            AudioEnginer.playEffect("sounds/storyVoice/gs1.mp3",false)

            --杀光复活点的所有对手
            startTimerAction(self, 9, false, function() for k, v in pairs(self.RolesAI) do if v  then v.m_startLockTarget = true end end  end)            
            startTimerAction(self, 3 + 8, false, function() AudioEnginer.playEffect("sounds/storyVoice/gs_bg1.mp3",false) end)
            startTimerAction(self, 8 + 8, false, function() AudioEnginer.playEffect("sounds/storyVoice/gs_bg4.mp3",false) end)
            
            local totalTime = 0
            self.hurtAction = startTimerAction(self, 0.1, true, function() 
                    if not self.noPlayerAttackResult then
                        totalTime = totalTime + 0.1
                    end

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

        --杀光皇宫门前的敌人
        function()                     
            --game.setAutoStatus(0)
            for k, v in pairs(self.RolesAI) do
                v.canRandomMove = true
                v.m_startLockTarget = false
            end

            --构造第二波敌人
            self:createPlayers(2116,2)

            --攻方机器人向目标点2移动
            for k, v in pairs(self.RolesAI) do
                if v.goToDestPos2 then
                    v:goToDestPos2()
                end
            end

            local endPoint = cc.p(119,92)
            self:addPathPoint(endPoint, true)
            self.pointAction2 = startTimerAction(self, 0.1, true, function() 
                if self:isInArea(2) then
                    self:removePathPoint() 
                    self:stopAction(self.pointAction2)
                    self.pointAction2 = nil 
                end
            end)

            --开启攻击
            local function onAttack2()
                self:addTaskInfo(5)
                self.m_canPlayerHurt = true
                AudioEnginer.playEffect("sounds/storyVoice/gs4.mp3", false)
            end
            startTimerAction(self, 1, false, onAttack2)
            startTimerAction(self, 1.0, false, function() for k, v in pairs(self.RolesAI) do if v  then v:fight(); v.m_startLockTarget = true end end  end)           
            startTimerAction(self, 5, false, function() AudioEnginer.playEffect("sounds/storyVoice/gs_bg2.mp3",false) end)

            --修改锁敌范围
            local function onChangeLockRange()
                for k, v in pairs(self.RolesAI) do
                    v.m_lockRange = 50
                end
            end
            startTimerAction(self, 10, false, onChangeLockRange)

            
            local totalTime = 0
            self.hurtAction = startTimerAction(self, 0.1, true, function() 
                    if not self.noPlayerAttackResult then
                        totalTime = totalTime + 0.1
                    end

                    local bAllDie = true
                    for m, n in pairs(self.playerTab[2]) do
                        if n ~= nil and n:isVisible() and n:getHP() > 1 then
                            bAllDie = false
                            break
                        end
                    end

                    if bAllDie or totalTime > 70 then                      
                        self:stopAction(self.hurtAction)
                        self.hurtAction = nil                         
                        self.needAutoAtk = 0 
                        self:removePathPoint()                 
                        self:updateState()
                    end                    
            end)
        end
        ,

        --通关传送门进入皇宫
        function()
            if self.pointAction2 then
                self:stopAction(self.pointAction2)
                self.pointAction2 = nil 
            end
            
            G_ROLE_MAIN.base_data.spe_skill = {}
            self:removeSpecialSkillSelEffect()
            G_MAINSCENE.skill_node:setLocalZOrder(1)
            self:hideHangNode()

            --self:showTextTips("story_tuto_tip12", nil, true)
            AudioEnginer.playEffect("sounds/storyVoice/gs5.mp3",false)
            game.setAutoStatus(0)
            self:addTaskInfo(6)
            --self:hideSkill()

            --其他角色也向传送点移动
            startTimerAction(self, 2, false, function() 
                for m, n in pairs(self.playerTab[1]) do
                    if n ~= nil and n:isVisible() and n:getHP() > 0 and n.storyai then
                        n.storyai.m_dstPos = self.m_defenderPos
                        n.storyai.m_bDisappearAfterMove = true
                    end
                end
            end)
            
            
            --如果主角不在传送点，添加指引路线
            --self:showTextTips("story_tuto_tip8", nil, true)
            self:addPathPoint(self.m_defenderPos,false)
            self.btnAction = startTimerAction(self, 0.1, true, function()                
                local cur = G_MAINSCENE.map_layer:space2Tile(cc.p(G_ROLE_MAIN:getPosition()))
                if math.abs(cur.x - self.m_defenderPos.x) < 2 and math.abs(cur.y - self.m_defenderPos.y) < 2 then
                    if not self.m_outBtn:isVisible() then
                        self.m_outBtn:setVisible(true)
                    end
                else
                    self.m_outBtn:setVisible(false)
                end
            end)                      
        end
        ,
	}

 	if switch[self.state] then 
 		switch[self.state]()
 	end
end

function StoryGongSha:endStroy()
    if not self.m_isFBMode then
        g_msgHandlerInst:sendNetDataByTableExEx(SHAWAR_CS_REQUEST_UPDATE_MONIWAR_STAGE, "ShaWarRequestUpdateMoniWarStage", {stage=1})
    elseif self.m_bExitNow then
        g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_EXITCOPY,"ExitCopyProtocol", {})
    else
        local proto = {}
        proto.copyId = 6007
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

    if self.btnAction then
        self:stopAction(self.btnAction)
        self.btnAction = nil 
    end

                       
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

    --移除魔法盾效果
    local topNode = G_ROLE_MAIN:getTopNode()
    if topNode ~= nil and topNode:getChildByTag(80) ~= nil and self.needClearMFD then
        topNode:removeChildByTag(80)
    end

    --移除中毒效果
    G_ROLE_MAIN:setColor(cc.c3b(255, 255, 255))

    self:clearBlock()
 
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

    

    --记录路径
    --require("src/layers/story/StoryAIPlayer"):writePaths()

    --G_MAINSCENE:exitStoryMode()

    print("end ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
end

function StoryGongSha:changeRoleDress(isOn)
    local MRoleStruct = require("src/layers/role/RoleStruct")
    local school = MRoleStruct:getAttr(ROLE_SCHOOL)
    local sex = MRoleStruct:getAttr(PLAYER_SEX)

    if isOn then
        self.m_oriBody = MRoleStruct:getAttr(PLAYER_EQUIP_UPPERBODY)
        self.m_oriWeapon = MRoleStruct:getAttr(PLAYER_EQUIP_WEAPON)
    end

    local function dress(sex, dressId, weaponId)
        local MpropOp = require "src/config/propOp"
        if dressId and dressId > 0 then
            local w_resId = MpropOp.equipResId(dressId)
            w_resId = G_ROLE_MAIN:getRightResID(PLAYER_EQUIP_UPPERBODY ,w_resId+sex*100000)
            local w_path = "role/" .. (w_resId)
            G_ROLE_MAIN:setBaseUrl(w_path)
        end

        if weaponId and weaponId > 0 then
            local w_resId = MpropOp.equipResId(weaponId)
            w_resId = G_ROLE_MAIN:getRightResID(PLAYER_EQUIP_WEAPON ,w_resId)
            local w_path = "weapon/" .. (w_resId)
            G_ROLE_MAIN:setEquipment_ex(G_ROLE_MAIN, PLAYER_EQUIP_WEAPON, w_path)
        end
    end

    if isOn then
        if school == 1 then
            if sex == 1 then
                dress(sex, 5110508, 5110108, 4031)
            else
                dress(sex, 5111508, 5110108, 4031)
            end
        elseif school == 2 then
             if sex == 1 then
                dress(sex, 5120508, 5120108, 5031)
            else
                dress(sex, 5121508, 5120108, 5031)
            end
        elseif school == 3 then
             if sex == 1 then
                dress(sex, 5130508, 5130108, 6031)
            else
                dress(sex, 5131508, 5130108, 6031)
            end
        end
    else
        G_ROLE_MAIN:setBaseUrl( "role/" .. g_normal_close_id+sex*100000)
        G_ROLE_MAIN:removeActionChildByTag(PLAYER_EQUIP_WEAPON)
        dress(sex, self.m_oriBody, self.m_oriWeapon)
    end
    G_ROLE_MAIN:standed()
    G_ROLE_MAIN:reloadRes()

    --隐藏自己的灵兽
    if isOn then
        self:hideMyPet()
    end
end

--创建角色
function StoryGongSha:createPlayers(mapId, order)    
    local items = require("src/config/storyPlayer")
    for i = 1, #items do   
        if mapId == items[i].q_mapid and order == items[i].q_order then
            local cfg = items[i]
            local params = {}
	        params[ROLE_SCHOOL] = cfg.q_school
            params[PLAYER_SEX] = cfg.q_sex
            params[ROLE_HP] = cfg.q_hp
            params[ROLE_LEVEL] = cfg.q_level  
            params[ROLE_MAX_HP] = cfg.q_hp
            params[ROLE_NAME] = cfg.q_name
            params[PLAYER_EQUIP_WEAPON] = cfg.q_weapon
            params[PLAYER_EQUIP_UPPERBODY] = cfg.q_body
            params[PLAYER_EQUIP_WING] = cfg.q_wing	

            --if cfg.q_camp == 2 then
            --    params[ROLE_HP] = 100
            --    params[ROLE_MAX_HP] = 100
            --end

            local MpropOp = require "src/config/propOp"
            local w_resId = MpropOp.equipResId(params[PLAYER_EQUIP_UPPERBODY])
            if w_resId == 0 then w_resId = g_normal_close_id end
            local w_resId = G_ROLE_MAIN:getRightResID(PLAYER_EQUIP_UPPERBODY,w_resId+params[PLAYER_SEX]*100000)
            local player = G_MAINSCENE.map_layer:makeMainRole(cfg.q_src_x, cfg.q_src_y, "role/".. w_resId, 3, false, cfg.q_id, params)
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

            --封号
            local titleNameNode = player:getTitleNameBatchLabel()
            if titleNameNode and cfg.q_titlename then
                titleNameNode:setString(cfg.q_titlename)
                if cfg.q_titlecolor then
                    titleNameNode:setColor(MColor[cfg.q_titlecolor])
                end
            end
           
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

                player:setFactionName_ex(player, game.getStrByKey("story_gongsha_factionname2").."("..game.getStrByKey("shaWar_name")..")")
            end          

            table.insert(self.playerTab[cfg.q_camp], player)
            player.camp = cfg.q_camp

            --关联AI
            local destPos2 = nil
            if cfg.q_dst_x_2 and cfg.q_dst_y_2 then
                destPos2 = cc.p(cfg.q_dst_x_2,cfg.q_dst_y_2)
            end

            local ai = require("src/layers/story/StoryAIPlayer").new(self, player, cfg.q_school, cc.p(cfg.q_dst_x,cfg.q_dst_y), destPos2, cfg.q_camp, cfg.q_target)
            player.storyai = ai
            table.insert(self.RolesAI, ai)

            if cfg.q_camp == 1 then 
                player.storyai.m_lockRange = 50
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
        end     
    end  
end

function StoryGongSha:createDefender()

    --添加传送点
    self.m_defenderPos = cc.p(114, 77)
    local transforEffect = Effects:create(false)
    transforEffect:setAnchorPoint(cc.p(0.5, 0.5))
    local t_pos = G_MAINSCENE.map_layer:tile2Space(self.m_defenderPos)
    transforEffect:setPosition(t_pos)
    G_MAINSCENE.map_layer:addChild(transforEffect)
    transforEffect:playActionData("transfor", 15, 2, -1)
    transforEffect:setScale(1.1)

    local function outBtnFun()
        self:endStroy()
    end
    local outBtn = createMenuItem(G_MAINSCENE.map_layer, "res/empire/shaWar/btn1.png", cc.p(t_pos.x + 134, t_pos.y + 143), outBtnFun)
    outBtn:setLocalZOrder(9000)
    outBtn:setVisible(false)
    self.m_outBtn = outBtn 

    local tutoFinger = Effects:create(false)
    tutoFinger:playActionData("tutoFinger", 14, 1.2, -1)
    self.m_outBtn:addChild(tutoFinger, 99999)
    tutoFinger:setAnchorPoint(cc.p(0.5, 0.5))
    tutoFinger:setPosition(cc.p(64, 64))

end

function StoryGongSha:addSkill(isWithTip)   
    local MRoleStruct = require("src/layers/role/RoleStruct")
    local school = MRoleStruct:getAttr(ROLE_SCHOOL)

    local skillTab = {}
    if school == 1 then
        table.insert(skillTab, {1000,1,1,0})
        table.insert(skillTab, {1004,1,2,0})
        table.insert(skillTab, {1003,1,3,0})
        table.insert(skillTab, {1006,1,4,0})
        table.insert(skillTab, {1010,1,5,0})
    elseif school == 2 then
        table.insert(skillTab, {2001,1,1,0})
        table.insert(skillTab, {2010,1,2,0})
        table.insert(skillTab, {2005,1,4,0})
        table.insert(skillTab, {2011,1,3,0})
        table.insert(skillTab, {2004,1,5,0})       
    elseif school == 3 then
        table.insert(skillTab, {1001,1,1,0})
        table.insert(skillTab, {3011,1,2,0})
        table.insert(skillTab, {3004,1,3,0})
        table.insert(skillTab, {3009,1,4,0})
        table.insert(skillTab, {3007,1,5,0})
    end

    --先缓存原来的技能
    self.skillTabBak = {}
    for k,v in pairs(G_ROLE_MAIN.skills) do
        table.insert(self.skillTabBak,v)
    end

    for k,v in pairs(G_ROLE_MAIN.wingskills) do
        table.insert(self.skillTabBak,v)
    end

    G_ROLE_MAIN:setSkills(skillTab)
    G_MAINSCENE:reloadSkillConfig(true)

    --skill_node切换父节点
    G_MAINSCENE.skill_node:retain()
    G_MAINSCENE.skill_node:removeFromParent()
    G_MAINSCENE:addChild(G_MAINSCENE.skill_node,1)
    G_MAINSCENE.skill_node:release()

    --自动召唤神兽，自动狮子吼，自动施毒处理
    self.m_autoShenShou = getGameSetById(GAME_SET_ID_AUTO_SUMMON)
    self.m_autoShiDu = getGameSetById(GAME_SET_ID_AUTO_POISON)
    self.m_autoShiZiHou = getGameSetById(GAME_SET_LIONSHOUT)

    setGameSetById(GAME_SET_ID_AUTO_SUMMON, 0, true)
    setGameSetById(GAME_SET_ID_AUTO_POISON, 0, true)
    setGameSetById(GAME_SET_LIONSHOUT, 0, true)
end

function StoryGongSha:removeSkill()
    local MRoleStruct = require("src/layers/role/RoleStruct")
    local school = MRoleStruct:getAttr(ROLE_SCHOOL)

    if self.skillTabBak then
        G_ROLE_MAIN:setSkills(self.skillTabBak)
        G_MAINSCENE:reloadSkillConfig()

        -- 换回父节点
        G_MAINSCENE.skill_node:retain()
        G_MAINSCENE.skill_node:removeFromParent()
        G_MAINSCENE.mainui_node:addChild(G_MAINSCENE.skill_node)
        G_MAINSCENE.skill_node:release()

        G_MAINSCENE.skill_node:setLocalZOrder(1)
        G_MAINSCENE.operate_node:setLocalZOrder(6)
        G_MAINSCENE.bloodNode:setLocalZOrder(20)

        setGameSetById(GAME_SET_ID_AUTO_SUMMON, self.m_autoShenShou, true)
        setGameSetById(GAME_SET_ID_AUTO_POISON, self.m_autoShiDu, true)
        setGameSetById(GAME_SET_LIONSHOUT, self.m_autoShiZiHou, true)
    end 
end

function StoryGongSha:showSkill()
    G_MAINSCENE.skill_node:setLocalZOrder(199)
--G_MAINSCENE.skill_node:setLocalZOrder(9999)
    --G_MAINSCENE.operate_node:setLocalZOrder(9999)
end

function StoryGongSha:hideSkill()
    G_MAINSCENE.skill_node:setLocalZOrder(1)
    --G_MAINSCENE.operate_node:setLocalZOrder(6)
end
--[[
function  StoryGongSha:addPathPoint(endTile, isNeedEnd)
    self.pathPoints = cc.Node:create()
    G_MAINSCENE.map_layer:addChild(self.pathPoints)
    local endPos = G_MAINSCENE.map_layer:tile2Space(endTile)
    
    --终点图标
    if isNeedEnd then
        local effect = Effects:create(false)
        effect:playActionData("storyEndPoint", 11, 2, -1)
        self.pathPoints:addChild(effect)
        effect:setAnchorPoint(cc.p(0.5, 0.47))
        effect:setPosition(endPos)
        addEffectWithMode(effect, 3)
    end

    --箭头集合
    local arrows = cc.Node:create()
    arrows:setPosition(endPos)
    self.pathPoints:addChild(arrows)

    local arrowsTable = {}
    local max = 100
    local dis = 40
    local pTime = 1.0
    for i=1,max do
        local sp = createSprite(arrows, "res/story/point.png", cc.p(dis*i, 0), cc.p(0.5, 0.5))
        sp:setScale(0.5)
        --sp:setOpacity(128)
        local seq = cc.Sequence:create(cc.MoveTo:create(1.0*i, cc.p(0,0)), cc.CallFunc:create( function()
                    local rep = cc.RepeatForever:create(cc.Sequence:create(cc.CallFunc:create( function() sp:setPosition(cc.p(dis*max, 0)) end ), cc.MoveTo:create(pTime*max, cc.p(0,0))))  
                    sp:runAction(rep)
              end ))
        sp:runAction(seq)

        table.insert(arrowsTable, sp)
    end

    local function updateArrows(dt)
        local cur = cc.p(G_ROLE_MAIN:getPosition())     
        local curDis = math.sqrt( (cur.x - endPos.x)*(cur.x - endPos.x) + (cur.y - endPos.y)*(cur.y - endPos.y))
        for i=1,#arrowsTable do
            local x = arrowsTable[i]:getPositionX()
            if x > curDis then
                arrowsTable[i]:setVisible(false)
            else
                arrowsTable[i]:setVisible(true)
            end
        end

        --旋转node
        local rot = math.atan2(cur.y - endPos.y, cur.x - endPos.x)
        arrows:setRotation(-1*rot*180/3.1415926)
    end

    self.schedulerArrow =  cc.Director:getInstance():getScheduler():scheduleScriptFunc(updateArrows, 0.01, false)
end
]]

function  StoryGongSha:addPathPoint(endTile, isNeedEnd)
    self.pathPoints = cc.Node:create()
    G_MAINSCENE.map_layer:addChild(self.pathPoints)
    local endPos = G_MAINSCENE.map_layer:tile2Space(endTile)
    
    --终点图标
    if isNeedEnd then
        local effect = Effects:create(false)
        effect:playActionData("storyEndPoint", 11, 2, -1)
        self.pathPoints:addChild(effect)
        effect:setAnchorPoint(cc.p(0.5, 0.47))
        effect:setPosition(endPos)
        addEffectWithMode(effect, 3)
    end

    local paths = G_MAINSCENE.map_layer:moveMonsterByPos(endTile, G_ROLE_MAIN, 2, false)
    for i = 1, #paths do
        local step = 3
        local t = i%step
        if t == 0 and not (endTile.x == paths[i].x and paths[i].y == endTile.y)then
            local pos = G_MAINSCENE.map_layer:tile2Space(paths[i])
            --local effect = createSprite(self.pathPoints, "res/story/point.png", pos, cc.p(0.5, 0.5))

            local effect = Effects:create(false)
            effect:playActionData("newshot", 3, 1, -1)
            self.pathPoints:addChild(effect)
            effect:setAnchorPoint(cc.p(0.5, 0.5))
            effect:setPosition(pos)

            --effect:setScale(0.5)

            local nextTile = endTile
            if paths[i + step] then
                nextTile = paths[i + step]
            end

            local nextPos = G_MAINSCENE.map_layer:tile2Space(nextTile)
            local rot = math.atan2(pos.y - nextPos.y, pos.x - nextPos.x)
            effect:setRotation(-1*rot*180/3.1415926 + 270)
        end
    end
end

function  StoryGongSha:removePathPoint()
    if self.pathPoints == nil then
        return
    end
    
    self.pathPoints:removeFromParent(true)
    self.pathPoints = nil

    if self.schedulerArrow ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry( self.schedulerArrow ) 
        self.schedulerArrow = nil
    end

end

--主角释放技能
function StoryGongSha:onSkillSend(skillId,targets,targetPos)
    if self.isEnd == true or G_MAINSCENE == nil then
        return
    end

    --解决技能频繁释放问题
    if self.m_lastAttackTime then
        local curTime = os.time()
        if curTime >= self.m_lastAttackTime + 1 then
            self.m_lastAttackTime = curTime
        elseif curTime < self.m_lastAttackTime then
            self.m_lastAttackTime = curTime
        else
            return
        end
    else
        self.m_lastAttackTime = os.time()
    end


    if self.needAutoAtk and self.needAutoAtk == 1 then
        self.needAutoAtk = 2
    end
    
    if skillId == 3009 or skillId == 1010 or skillId == 2005 then
        if targets ~= nil then
            for k,v in pairs(targets) do  
                if v.storyai ~= nil then
                    v.storyai:onCollide()
                end
            end
        end
    end   
    
    if skillId == 2004 then       --魔法盾
        local topNode = G_ROLE_MAIN:getTopNode()
        if topNode ~= nil and not topNode:getChildByTag(80) then
            self.needClearMFD = true
            local skill_effect = Effects:create(false)
            skill_effect:setPosition(cc.p(0, 0))
            skill_effect:playActionData("skill2004/loop", 4, 1, -1)
            addEffectWithMode(skill_effect,3)
            topNode:addChild(skill_effect, 20, 80)
        end
        return
    elseif skillId == 2011 then   --流星火雨
        --计算目标
        targets = {}
        if targetPos ~= nil then
            for m, n in pairs(self.playerTab[2]) do
                if n ~= nil and n:isVisible() and n:getHP() > 0 then
                    local nPos = G_MAINSCENE.map_layer:space2Tile(cc.p(n:getPosition()))
                    local dis =(targetPos.x - nPos.x) *(targetPos.x - nPos.x) +(targetPos.y - nPos.y) *(targetPos.y - nPos.y)
                    if dis < 25 then
                        table.insert(targets, n)
                    end
                end
            end
        end
        
        startTimerAction(self, 1.0, false, function() self:showHurt(skillId,targets) end)
        startTimerAction(self, 4.0, false, function() self:showHurt(skillId,targets) end)
        startTimerAction(self, 7.0, false, function() self:showHurt(skillId,targets) end)
        startTimerAction(self, 10.0, false, function() self:showHurt(skillId,targets) end)  
        startTimerAction(self, 13.0, false, function() self:showHurt(skillId,targets) end)     
        return  
    elseif skillId == 2010 then   --狂龙紫电
        startTimerAction(self, 1.2, false, function() self:showHurt(skillId,targets) end)
        return
    elseif skillId == 2005 then   --抗拒火环 
        --if #targets > 0 then
        --    AudioEnginer.playEffect("sounds/skillMusic/2005.mp3",false)
        --end
        return
    elseif skillId == 1006 then   --烈火剑法
        startTimerAction(self, 0.3, false, function() self:showHurt(skillId,targets) end)
        return
    elseif skillId == 1004 then   --抱月刀
        startTimerAction(self, 0.3, false, function() self:showHurt(skillId,targets) end)
        return
    elseif skillId == 1003 then   --刺杀剑术
        startTimerAction(self, 0.3, false, function() self:showHurt(skillId,targets) end)
        return
    elseif skillId == 1010 then   --突斩
        startTimerAction(self, 0.5, false, function() self:showHurt(skillId,targets) end)
        --if #targets > 0 then
        --    AudioEnginer.playEffect("sounds/skillMusic/1010.mp3",false)
        --end
        return
    elseif skillId == 3011 then   --幽冥火咒
        startTimerAction(self, 0.5, false, function() self:showHurt(skillId,targets) end)
        return
    elseif skillId == 3004 then   --施毒术
        startTimerAction(self, 1.0, false, function() 
            if targets ~= nil then
                -- 添加角色中毒效果
                local hurtTarget = { }
                local bHave = false
                for k, v in pairs(targets) do
                    if v.isSDSBuff ~= true then
                        v.isSDSBuff = true
                        v:setColor(cc.c3b(10, 210, 10))
                        hurtTarget[k] = v
                        bHave = true
                    else
                        bHave = false
                    end
                end
            
                -- 施毒术持续十秒伤害
                if bHave == true then
                    self:showHurt(skillId, hurtTarget)
                    startTimerAction(self, 1, false, function() self:showHurt(skillId, hurtTarget) end)
                    startTimerAction(self, 2, false, function() self:showHurt(skillId, hurtTarget) end)
                    startTimerAction(self, 3, false, function() self:showHurt(skillId, hurtTarget) end)
                    startTimerAction(self, 4, false, function() self:showHurt(skillId, hurtTarget) end)
                    startTimerAction(self, 5, false, function() self:showHurt(skillId, hurtTarget) end)
                    startTimerAction(self, 6, false, function() self:showHurt(skillId, hurtTarget) end)
                    startTimerAction(self, 7, false, function() self:showHurt(skillId, hurtTarget) end)
                    startTimerAction(self, 8, false, function() self:showHurt(skillId, hurtTarget) end)
                    startTimerAction(self, 9, false, function() self:showHurt(skillId, hurtTarget) end)
                    startTimerAction(self, 10, false, function() 
                                                        self:showHurt(skillId, hurtTarget) 
                                                        for k, v in pairs(hurtTarget) do
                                                            v.isSDSBuff = false
                                                            v:setColor(cc.c3b(255, 255, 255))
                                                        end
                                                  end)
                end           
            end          
        end)

        return
    elseif skillId == 3007 then   --召唤神兽
        startTimerAction(self, 1.0, false, function() 
            if G_MAINSCENE == nil then
                return
            end
            
            --添加灵兽
            if self.baobaoID == nil then
                self.baobaoID = 1100
            else
                self.baobaoID = self.baobaoID + 1
            end

            if self.baobao ~= nil then
                self.baobao.storyai:idle()
                self.baobao:setVisible(false)
            end

            local entity = 
            {
                [ROLE_MODEL] = 91000,
                [ROLE_HP] = 10000,
            }

            local posAdd = { cc.p(-1, 0), cc.p(-1, -1), cc.p(-1, 1), cc.p(0, -1), cc.p(0, 1), cc.p(1, -1), cc.p(1, 0), cc.p(1, 1)}
            local myPos = G_MAINSCENE.map_layer:space2Tile(cc.p(G_ROLE_MAIN:getPosition()))
            for k, v in pairs(posAdd) do
                local new = cc.p(myPos.x + v.x, myPos.y + v.y) 
                if not G_MAINSCENE.map_layer:isBlock(new) then
                    myPos = new
                    break
                end
            end
           
            local baobao = G_MAINSCENE.map_layer:addMonster(myPos.x, myPos.y, 20085, nil, self.baobaoID, entity)  
            baobao:initStandStatus(4,4,1.0,6)          
            baobao:setSpriteDir(1)
            baobao:standed()           
            local petName = string.format(game.getStrByKey("story_gongsha_petname"), require("src/layers/role/RoleStruct"):getAttr(ROLE_NAME))
            baobao:setNameLabel(petName)
            baobao:setNameColor(MColor.name_blue)
            local ai = require("src/layers/story/StoryAIPet").new(self, baobao)
            ai.m_needMoveToOwner = true
            baobao.storyai = ai            
            baobao.storyai:fight()
            self.baobao = baobao
            table.insert(self.RolesAI, ai)

            local effect = Effects:create(false)
            effect:playActionData("storySummon", 11, 1, 1)
            G_MAINSCENE.map_layer:addChild(effect)
            effect:setPosition(myPos)
            startTimerAction(self, 1.2, false, function() removeFromParent(effect) end)
        end)
        return
    elseif skillId == 3009 then   --狮子吼
        --if #targets > 0 then
        --    AudioEnginer.playEffect("sounds/skillMusic/70841_2.mp3",false)
        --end
        return
    elseif skillId == 2001 then   --小火球
        startTimerAction(self, 1.0, false, function() self:showHurt(skillId,targets) end)
        return
    end 

    startTimerAction(self, 0.5, false, function() self:showHurt(skillId,targets) end)
end

function StoryGongSha:showHurt(skillId,targets)  
    if targets == nil or G_MAINSCENE == nil or not self.m_canPlayerHurt then
        return
    end

    local hurt_num = self:getHurtNum(skillId)
    for k,v in pairs(targets)do        
        if v == self.baobao or v == G_ROLE_MAIN then
            return
        end
        
        local rr = tolua.cast(v, "SpriteMonster") 
        if rr and rr:getHP() > 0 and hurt_num > 0 then
            G_MAINSCENE.map_layer:showHurtNumer(hurt_num, cc.p(v:getPosition()), cc.p(G_ROLE_MAIN:getPosition()), 0.3, nil, false)
        end
       
        local func = function()
            if G_MAINSCENE == nil or IsNodeValid(G_MAINSCENE) == nil or IsNodeValid(self) == nil then
                return
            end
            
            local hurt_item = tolua.cast(v, "SpriteMonster")
            if hurt_item and hurt_item:getHP() > 0 then
                local cur_hp = hurt_item:getHP() - hurt_num
                if cur_hp < 0 then
                    cur_hp = 0
                end
                hurt_item:setHP(cur_hp)
                --hurt_item:showNameAndBlood(false, 0)
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
                    local select_node = G_MAINSCENE.map_layer.select_role or G_MAINSCENE.map_layer.select_monster
                    if select_node and select_node == hurt_item then
                        G_MAINSCENE.map_layer.select_role = nil
                        G_MAINSCENE.map_layer.select_monster = nil
                        G_MAINSCENE.map_layer:setRockDir(10)
                    end  
                    self:resetTouch(hurt_item)
                    
                    startTimerAction(hurt_item, 2.0, false, function() hurt_item:setVisible(false) end) 
                    
                    if skillId  < 9000 then                       
                        self:addLianZhanEff()
                    end                        
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
                local select_node = G_MAINSCENE.map_layer.select_role or G_MAINSCENE.map_layer.select_monster
                if select_node and select_node == hurt_item then
                    G_MAINSCENE.map_layer.select_role = nil
                    G_MAINSCENE.map_layer.select_monster = nil
                    G_MAINSCENE.map_layer:setRockDir(10)
                end
                startTimerAction(hurt_item, 2.0, false, function() hurt_item:setVisible(false) end) 

            --    if skillId  < 9000 then                       
            --        self:addLianZhanEff()
            --    end 
            end
        end
        performWithDelay(self, func, 0.3 + 0.15)
    end
end

function StoryGongSha:getHurtNum(skillID)
    if self.noPlayerAttackResult then
        return 0
    end
    
    if skillID == 1006 then
        return math.random(2000,3600)
    elseif skillID == 1004 then
        return math.random(1000,2000)
    elseif skillID == 1003 then
        return math.random(800,1500)
    elseif skillID == 1010 then
        return math.random(1000,2000)
    elseif skillID == 2010 then
        return math.random(1000,2000)
    elseif skillID == 2011 then
        return math.random(200,300)
    elseif skillID == 3011 then
        return math.random(900,1800)
    elseif skillID == 3004 then
        return math.random(600,1000)
    elseif skillID == 9999 then   --神兽
        return math.random(100,150)
    elseif skillID == 9998 then   --士兵
        return math.random(10,14)
    elseif skillID == 9997 then   --怪物
        return math.random(8,12)
    else
        return math.random(100,200)
    end
end

--假人释放技能
function StoryGongSha:onPlayerSkill(skillId,player,targets,targetPos)
    if self.isEnd == true then
        return
    end
      
    if skillId == 2011 then   --流星火雨
        --计算目标       
        startTimerAction(self, 1.0, false, function() self:showPlayerHurt(skillId,player,targets,targetPos) end)
        startTimerAction(self, 4.0, false, function() self:showPlayerHurt(skillId,player,targets,targetPos) end)
        startTimerAction(self, 7.0, false, function() self:showPlayerHurt(skillId,player,targets,targetPos) end)
        startTimerAction(self, 10.0, false, function() self:showPlayerHurt(skillId,player,targets,targetPos) end)  
        startTimerAction(self, 13.0, false, function() self:showPlayerHurt(skillId,player,targets,targetPos) end)     
        return  
    elseif skillId == 2010 then   --狂龙紫电
        startTimerAction(self, 1.2, false, function() self:showPlayerHurt(skillId,player,targets) end)
        return
    elseif skillId == 1006 then   --烈火剑法
        startTimerAction(self, 0.3, false, function() self:showPlayerHurt(skillId,player,targets) end)
        return
    elseif skillId == 1003 then   --刺杀剑术
        startTimerAction(self, 0.3, false, function() self:showPlayerHurt(skillId,player,targets) end)
        return
    elseif skillId == 3011 then   --幽冥火咒
        startTimerAction(self, 0.5, false, function() self:showPlayerHurt(skillId,player,targets) end)
        return
    elseif skillId == 3004 then   --施毒术
        startTimerAction(self, 1.0, false, function() 
            if targets ~= nil then
                -- 添加角色中毒效果
                local hurtTarget = { }
                local bHave = false
                for k, v in pairs(targets) do
                    if v.isSDSBuff ~= true then
                        v.isSDSBuff = true
                        v:setColor(cc.c3b(10, 210, 10))
                        hurtTarget[k] = v
                        bHave = true
                    else
                        bHave = false
                    end
                end
            
                -- 施毒术持续十秒伤害
                if bHave == true then
                    self:showPlayerHurt(skillId, hurtTarget)
                    startTimerAction(self, 1, false, function() self:showPlayerHurt(skillId, player,hurtTarget) end)
                    startTimerAction(self, 2, false, function() self:showPlayerHurt(skillId, player,hurtTarget) end)
                    startTimerAction(self, 3, false, function() self:showPlayerHurt(skillId, player,hurtTarget) end)
                    startTimerAction(self, 4, false, function() self:showPlayerHurt(skillId, player,hurtTarget) end)
                    startTimerAction(self, 5, false, function() self:showPlayerHurt(skillId, player,hurtTarget) end)
                    startTimerAction(self, 6, false, function() self:showPlayerHurt(skillId, player,hurtTarget) end)
                    startTimerAction(self, 7, false, function() self:showPlayerHurt(skillId, player,hurtTarget) end)
                    startTimerAction(self, 8, false, function() self:showPlayerHurt(skillId, player,hurtTarget) end)
                    startTimerAction(self, 9, false, function() self:showPlayerHurt(skillId, player,hurtTarget) end)
                    startTimerAction(self, 10, false, function() 
                                                        self:showPlayerHurt(skillId, player,hurtTarget) 
                                                        for k, v in pairs(hurtTarget) do
                                                            v.isSDSBuff = false
                                                            v:setColor(cc.c3b(255, 255, 255))
                                                        end
                                                  end)
                end           
            end          
        end)

        return
    else
        startTimerAction(self, 0.3, false, function() self:showPlayerHurt(skillId,player,targets) end)
    end 
end

function StoryGongSha:showPlayerHurt(skillId,player,targets,targetPos)
    if targets == nil or G_MAINSCENE == nil then
        return
    end

    for k,v in pairs(targets)do 
        if v == G_ROLE_MAIN then
            --流星火雨是否在范围内
            if targetPos then
                local x,y = G_ROLE_MAIN:getPosition()
                if math.abs(x - targetPos.x) > 250 or math.abs(y - targetPos.y) > 200 then
                    return
                end
            end
            
            --抛伤害                                 
            if G_ROLE_MAIN:getHP() > 10 then
                local hurt_num = math.random(1,5)
                local setHpNum = G_ROLE_MAIN:getHP() - hurt_num
                G_ROLE_MAIN:setHP(setHpNum)
                G_MAINSCENE.map_layer:showHurtNumer(hurt_num, cc.p(v:getPosition()), cc.p(player:getPosition()), 0.3, nil, false)
                G_MAINSCENE:updateHeadInfo(setHpNum)
                --更新进度条
            end  
        else                                   
            local func = function()
                -- 异常
                if G_MAINSCENE == nil or IsNodeValid(G_MAINSCENE) == nil or IsNodeValid(self) == nil then
                    return
                end
                
                local hurt_num = self:getHurtNumPlayer(skillId,player) 
                local hurt_item = tolua.cast(v, "SpriteMonster")
                if hurt_item and hurt_item:getHP() > 0 then
                    local cur_hp = hurt_item:getHP() - hurt_num
                    if cur_hp < 0 then
                        cur_hp = 0
                    end
                    hurt_item:setHP(cur_hp)

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

                        startTimerAction(hurt_item, 2.0, false, function() hurt_item:setVisible(false) end)
                    end
                elseif hurt_item and hurt_item:getHP() < 1 and hurt_item:getCurrActionState() == ACTION_STATE_IDLE then
                    local topNode = hurt_item:getTopNode()
                    if topNode ~= nil and topNode:getChildByTag(80) then
                        topNode:removeChildByTag(80)
                    end

                    if target_type == 22 then
                        -- 野蛮冲撞等无法执行死亡动作
                        hurt_item:gotoDeath(6)
                    else
                        hurt_item:gotoDeath(7)
                    end
                    self:resetTouch(hurt_item)

                    startTimerAction(hurt_item, 2.0, false, function() hurt_item:setVisible(false) end)
                end
            end
            performWithDelay(self, func, 0.3 + 0.15)      
        end
    end  
end

function StoryGongSha:getHurtNumPlayer(skillID, player)
    if self.noPlayerAttackResult then
        return 0
    end
    
    local num = 0
    if skillID == 1006 then
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
    elseif skillID == 9999 then   --神兽
        return math.random(100,150)
    elseif skillID == 9998 then   --士兵
        return math.random(10,14)
    elseif skillID == 9997 then   --怪物
        return math.random(50,100)
    else
        num = 100
    end

    if player and player.camp == 1 then
        num = num
    else
        num = num*0.1
    end

    return num

end

function StoryGongSha:resetTouch(player)
    if G_MAINSCENE == nil or G_MAINSCENE.map_layer == nil then
        return
    end

    if G_MAINSCENE.map_layer.select_role == player or G_MAINSCENE.map_layer.select_monster == player then
        G_MAINSCENE.map_layer:resetTouchTag()
    end
end

function StoryGongSha:lockOneMonster(monster, bLock)
    if monster == nil then
        return nil
    end

    if bLock then
        local select_effect = Effects:create(false)
        select_effect:setAnchorPoint(cc.p(0.5, 0.4))
        select_effect:playActionData("redtag", 8, 2, -1)
        select_effect:setOpacity(monster:getOpacity())
        monster:addChild(select_effect, 0, 789)
        addEffectWithMode(select_effect, 3) 
        return monster
    else
        monster:removeChildByTag(789)
        return nil
    end
end

function StoryGongSha:addTalk(id, delay, delayDestory, text)
	if self.talkNode then
        removeFromParent(self.talkNode)
        self.talkNode = nil
    end

    local record = getConfigItemByKey("storyTalk", "q_id", id)

    self.talkNode = cc.Node:create()
    self:addChild(self.talkNode)

    local function createTalk()
        local bg = createSprite(self.talkNode, "res/story/bg.png", cc.p(display.cx, 0), cc.p(0.5, 0))
        bg:setOpacity(0)
        bg:runAction(cc.Sequence:create(cc.FadeIn:create(0.2)))
        if record.q_role == 0 then
            local sex = require("src/layers/role/RoleStruct"):getAttr(PLAYER_SEX)
            local school = require("src/layers/role/RoleStruct"):getAttr(ROLE_SCHOOL)
            createSprite(bg, "res/mainui/npc_big_head/"..(sex-1)*3+school..".png", cc.p(bg:getContentSize().width/2+display.width/2+15, bg:getContentSize().height), cc.p(1, 0))
        elseif record.q_role == 5 then
            createSprite(bg, "res/mainui/npc_big_head/0.png", cc.p(bg:getContentSize().width/2-display.width/2, bg:getContentSize().height), cc.p(0, 0))
        else
            createSprite(bg, "res/mainui/npc_big_head/"..record.q_role..".png", cc.p(bg:getContentSize().width/2-display.width/2, bg:getContentSize().height), cc.p(0, 0))
        end

        local richText = require("src/RichText").new(bg, cc.p(bg:getContentSize().width/2-(display.width-200)/2, 140), cc.size(display.width-200, 30), cc.p(0, 1), 30, 24, MColor.lable_yellow)
        if text then
            richText:addText(text)
        else
            richText:addText(record.q_text)
        end
        richText:format()


        createLabel(bg, game.getStrByKey("story_talk_tip"), cc.p(bg:getContentSize().width / 2 + display.width / 2 - 120, 30), cc.p(1, 0.5), 22, true, nil, nil, MColor.white)
        local arrow = createSprite(bg, "res/group/arrows/13.png", cc.p(bg:getContentSize().width / 2 + display.width / 2 - 110, 30), cc.p(0, 0.5), nil, 0.6)
        arrow:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveTo:create(0.3, cc.p(bg:getContentSize().width / 2 + display.width / 2 - 100, 30)), cc.MoveTo:create(0.3, cc.p(bg:getContentSize().width / 2 + display.width / 2 - 110, 30)))))

        local listenner = cc.EventListenerTouchOneByOne:create()
        listenner:setSwallowTouches(false)
        listenner:registerScriptHandler( function(touch, event)
            return true
        end , cc.Handler.EVENT_TOUCH_BEGAN)
        listenner:registerScriptHandler( function(touch, event)
            if self.talkNode then
                removeFromParent(self.talkNode)
                self.talkNode = nil
            end
            self:updateState()
        end , cc.Handler.EVENT_TOUCH_ENDED)
        local eventDispatcher = self:getEventDispatcher()
        eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, self.talkNode)
    end

    startTimerAction(self, delay or 0, false, function() createTalk() end)
end


function StoryGongSha:showTextTips(textid, soundFile, autoRemove)
 --[[   if self.m_top then
        removeFromParent(self.m_top)
        self.m_top = nil
    end
    
    self.m_top = createSprite(self, "res/story/black.png", cc.p( 480 , 320 ), cc.p(0.5, 0.5), -1)
    self.m_top:setScale(150)
    self.m_top:setOpacity(200)
    startTimerAction(self.m_top, 2, false, function() if self.m_top then removeFromParent(self.m_top); self.m_top = nil end end)
  ]]  
    if self.m_textBg ~= nil then
        removeFromParent(self.m_textBg)
        self.m_textBg = nil
    end
    
    local imageBg = createSprite(self, "res/story/bg_text.png", cc.p( display.cx , 50), cc.p(0.5, 0.5))
    imageBg:setOpacity(0)
    imageBg:runAction(cc.Sequence:create(cc.FadeIn:create(0.2)))
    self.m_textBg = imageBg

    local lab = createLabel(imageBg, game.getStrByKey(textid), getCenterPos(imageBg), cc.p(0.5, 0.5), 24)

    if autoRemove == true then
        startTimerAction(self.m_textBg, 2, false, function() if self.m_textBg ~= nil then removeFromParent(self.m_textBg); self.m_textBg = nil end end)
    end

    --播放声音
    if soundFile ~= nil then
         AudioEnginer.playEffect(soundFile,false)
    end
end
--[[
function StoryGongSha:addTaskInfo(idx)
    self:delTaskInfo()

    self.m_tastBg = createSprite(self , "res/common/bg/bg62.png" , cc.p(2, g_scrSize.height-155) , cc.p( 0, 0.5 ) )  
    local strTitle = game.getStrByKey("story_gongsha_target_title")
    createLabel(self.m_tastBg, strTitle, cc.p(38,53),cc.p(0,0.5),20,nil,nil,nil,MColor.yellow)
       
    local strTab = {"story_gongsha_target1","story_gongsha_target2","story_gongsha_target3","story_gongsha_target4","story_gongsha_target5","story_gongsha_target6","story_gongsha_target7","story_gongsha_target8"}
    local str = game.getStrByKey(strTab[idx])
    if idx == 2 then
        self.m_hurtText = require("src/RichText").new(self.m_tastBg, cc.p(38, 25), cc.size(200, 24), cc.p(0, 0.5), 24, 20, MColor.lable_yellow)
        local text = string.format(str, 0)        
        self.m_hurtText:addText(text)
        self.m_hurtText:format()
    elseif idx == 8 then
        self.timeCount = 10   
        local text = string.format(str, self.timeCount)   
        local label = createLabel(self.m_tastBg, text, cc.p(38,25),cc.p(0,0.5),20,nil,nil,nil,MColor.lable_yellow)
        self.timeAction = startTimerAction(self, 1, true, function()           
            self.timeCount = self.timeCount - 1
            local text = string.format(str, self.timeCount) 
            label:setString(text)
            if self.timeCount <= 0 then
                self:stopAction(self.timeAction)
                self.timeAction = nil
                self:updateState()
            end
        end )

        self.m_taskBtn:setVisible(false)
        self.m_tastBg:setPosition(cc.p(-280, g_scrSize.height-155))
        self.m_tastBg:runAction(cc.Sequence:create(cc.MoveTo:create(0.5, cc.p(2, g_scrSize.height-155)),cc.DelayTime:create(20)))
        return
    else
        createLabel(self.m_tastBg, str, cc.p(38,25),cc.p(0,0.5),20,nil,nil,nil,MColor.lable_yellow)
    end

    self.m_tastBg:setPosition(cc.p(-280, g_scrSize.height-155))
    self.m_tastBg:runAction(cc.Sequence:create(cc.MoveTo:create(0.5, cc.p(2, g_scrSize.height-155)),cc.DelayTime:create(3), cc.MoveTo:create(0.5, cc.p(-280, g_scrSize.height-155)),cc.CallFunc:create( function() if self.m_taskBtn then self.m_taskBtn:setVisible(true) end end )))

    if self.m_taskBtn == nil then
         local showTask = function()
             if self.m_tastBg then
                 self.m_tastBg:stopAllActions()
                 self.m_taskBtn:setVisible(false)
                 self.m_tastBg:runAction(cc.Sequence:create(cc.MoveTo:create(0.5, cc.p(2, g_scrSize.height-155)),cc.DelayTime:create(3), cc.MoveTo:create(0.5, cc.p(-280, g_scrSize.height-155)), cc.CallFunc:create( function() if self.m_taskBtn then self.m_taskBtn:setVisible(true) end end )))
             end
         end

         self.m_taskBtn = createMenuItem(self, "res/group/arrows/13.png", cc.p(11, g_scrSize.height-155), showTask, 10)
         self.m_taskBtn:setScale(0.6)         
    end

    self.m_taskBtn:setVisible(false)


   -- local effectLoop = Effects:create(false)
   -- effectLoop:playActionData("tutoButton", 12, 1.8, -1)
   -- effectLoop:setAnchorPoint(cc.p(0.5, 0.5))
   -- effectLoop:setPosition( cc.p(140, 39))
   -- effectLoop:setScale(1.5)
   -- self.m_tastBg:addChild(effectLoop)
   -- startTimerAction(self.m_tastBg, 3, false, function() removeFromParent(effectLoop) end)
    
end
]]

function StoryGongSha:addTaskInfo(idx)  
    self:delTaskInfo()

    --self.m_tastBg = createSprite(self , "res/common/bg/bg62.png" , cc.p(2, g_scrSize.height-155) , cc.p( 0, 0.5 ) ) 
    local callback = function() end
    if idx == 1 then
        callback = function() G_MAINSCENE.map_layer:moveMapByPos(cc.p(133,106), false) end
    elseif idx == 3 then
        callback = function() G_MAINSCENE.map_layer:moveMapByPos(cc.p(133,106), false); game.setAutoStatus(AUTO_ATTACK) end
    elseif idx == 4 then 
        callback = function() G_MAINSCENE.map_layer:moveMapByPos(cc.p(119,92), false) end
    elseif idx == 5 then
        callback = function() G_MAINSCENE.map_layer:moveMapByPos(cc.p(119,92), false); game.setAutoStatus(AUTO_ATTACK) end
    elseif idx == 6 then
        callback = function() G_MAINSCENE.map_layer:moveMapByPos(self.m_defenderPos, false) end
    elseif idx == 7 then
        callback = function() game.setAutoStatus(AUTO_ATTACK) end
    end    

    self.m_tastBg = createTouchItem(self, "res/common/bg/bg62.png",cc.p(142, g_scrSize.height-155) , callback, false)  
    local strTitle = game.getStrByKey("story_gongsha_target_title")
    local bgLabel = createLabel(self.m_tastBg, strTitle, cc.p(38,53),cc.p(0,0.5),20,nil,nil,nil,MColor.yellow)
       
    local strTab = {"story_gongsha_target1","story_gongsha_target2","story_gongsha_target3","story_gongsha_target4","story_gongsha_target5","story_gongsha_target6","story_gongsha_target7","story_gongsha_target8","story_gongsha_target9","story_gongsha_target10"}
    local str = game.getStrByKey(strTab[idx])
    if idx == 1 then             
        createLinkLabel(self.m_tastBg, str, cc.p(38,25),cc.p(0,0.5), 20, false, nil, MColor.lable_yellow, nil, callback, true)
    elseif idx == 2 then
        self.m_hurtText = require("src/RichText").new(self.m_tastBg, cc.p(38, 25), cc.size(200, 24), cc.p(0, 0.5), 24, 20, MColor.lable_yellow)
        local text = string.format(str, 0)        
        self.m_hurtText:addText(text)
        self.m_hurtText:format()
    elseif idx == 3 then       
        createLinkLabel(self.m_tastBg, str, cc.p(38,25),cc.p(0,0.5), 20, false, nil, MColor.lable_yellow, nil, callback, true)
    elseif idx == 4 then       
        createLinkLabel(self.m_tastBg, str, cc.p(38,25),cc.p(0,0.5), 20, false, nil, MColor.lable_yellow, nil, callback, true)
    elseif idx == 5 then       
        createLinkLabel(self.m_tastBg, str, cc.p(38,25),cc.p(0,0.5), 20, false, nil, MColor.lable_yellow, nil, callback, true)
    elseif idx == 6 then      
        createLinkLabel(self.m_tastBg, str, cc.p(38,25),cc.p(0,0.5), 20, false, nil, MColor.lable_yellow, nil, callback, true)   
    elseif idx == 7 then      
        createLinkLabel(self.m_tastBg, str, cc.p(38,25),cc.p(0,0.5), 20, false, nil, MColor.lable_yellow, nil, callback, true) 
    elseif idx == 10 then
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

function StoryGongSha:delTaskInfo()
    if self.m_tastBg then
        removeFromParent(self.m_tastBg)
        self.m_tastBg = nil
    end

    self.m_hurtText = nil
end

function StoryGongSha:refreshHurtInfo()
    if self.m_hurtCount == nil or self.m_hurtText == nil then
        return
    end

    removeFromParent(self.m_hurtText)
    self.m_hurtText = nil

    local str = game.getStrByKey("story_gongsha_target2")
    self.m_hurtText = require("src/RichText").new(self.m_tastBg, cc.p(38, 25), cc.size(200, 24), cc.p(0, 0.5), 24, 20, MColor.lable_yellow)
    local text = string.format(game.getStrByKey("story_gongsha_target2"), self.m_hurtCount)
    self.m_hurtText:addText(text)
    self.m_hurtText:format()  
end

function StoryGongSha:addFocusEff(idx)
    local par = nil
    local textid = nil
    local offx, offy
    if idx == 1 then
        --选角色引导
        local skillItem = G_MAINSCENE.skill_node:getCenterItem()
        if skillItem == nil then
            return
        end

        par = skillItem:getChildByTag(122)
        textid = "story_tuto_tip7"
        offx = 12
        offy = -4
    elseif idx == 2 then
        --进入皇宫引导
        par = self.m_outBtn
        textid = "story_tuto_tip8"
        offx = 2
        offy = -4
    elseif idx == 3 then
        --拾取道具引导
        local skillItem = G_MAINSCENE.skill_node:getCenterItem()
        if skillItem == nil then
            return
        end

        par = skillItem:getChildByTag(121)
        textid = "story_tuto_tip9"
        offx = 12
        offy = -4
    elseif idx == 4 then
        --放技能引导
        local center_node = G_MAINSCENE.skill_node:getCenterNode()
        if center_node == nil then
            return
        end

        par = center_node:getChildByTag(2)
        textid = "story_tuto_tip10"
        offx = 4
        offy = 2
    end

    if par == nil then
        return
    end

    if par:getChildByTag(66) then
        return
    end

    local effectLoop = Effects:create(false)
    effectLoop:playActionData("story_focus", 10, 1, -1)
    effectLoop:setAnchorPoint(cc.p(0.5, 0.5))
    local pos = getCenterPos(par) 
    effectLoop:setPosition( cc.p(pos.x + offx, pos.y + offy))
    addEffectWithMode(effectLoop, 3)
    par:addChild(effectLoop, 99, 66)
    startTimerAction(par, 2, false, function() removeFromParent(effectLoop) end)  

    self:showTextTips(textid, nil, true)
end

function StoryGongSha:addLianZhanEff(num)
    if not self.m_needLianZhanEffect then
        return
    end

    if self.m_lastLianZhanTime ~= nil and os.time() - self.m_lastLianZhanTime <= 1 then
        return
    end

    self.m_lastLianZhanTime = os.time()
    
    --当前存在特效的
    if self.m_lzEff then
        removeFromParent(self.m_lzEff)
        self.m_lzEff = nil
    end

    StoryGongSha.m_hurtCount = StoryGongSha.m_hurtCount + 1
    num = StoryGongSha.m_hurtCount

    local KillSpr = createSprite(self, "res/mainui/killNum/bg.png")
    KillSpr:setLocalZOrder(600)
    KillSpr:setPosition(cc.p(g_scrSize.width * 700 / 960, g_scrSize.height * 490 / 640))

    local shiNum = math.floor(num/10)
    if shiNum >= 1 then        
        createSprite(KillSpr, "res/mainui/killNum/" .. shiNum .. ".png", cc.p(-23, 40), cc.p(0, 0.5))
        num = num - shiNum*10
    end
    
    createSprite(KillSpr, "res/mainui/killNum/" .. num .. ".png", cc.p(17, 40), cc.p(0, 0.5))
    createSprite(KillSpr, "res/mainui/killNum/title.png", cc.p(60, 40), cc.p(0, 0.5))  

    KillSpr:setScale(0.1)
	KillSpr:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 1)))
	performWithDelay(KillSpr, function() removeFromParent(KillSpr); self.m_lzEff = nil end, 5)

    self.m_lzEff = KillSpr
end

function StoryGongSha:setBlock()
    G_MAINSCENE.map_layer:setBlockRectValue(cc.rect(103,93,1,11), "1")
    G_MAINSCENE.map_layer:setBlockRectValue(cc.rect(107,112,1,7), "1")
    G_MAINSCENE.map_layer:setBlockRectValue(cc.rect(107,118,11,1), "1")
    G_MAINSCENE.map_layer:setBlockRectValue(cc.rect(123,129,26,1), "1")
    G_MAINSCENE.map_layer:setBlockRectValue(cc.rect(124,78,11,1), "1")
    G_MAINSCENE.map_layer:setBlockRectValue(cc.rect(142,84,6,1), "1")
    G_MAINSCENE.map_layer:setBlockRectValue(cc.rect(147,84,1,5), "1")
    G_MAINSCENE.map_layer:setBlockRectValue(cc.rect(147,88,6,1), "1")
    G_MAINSCENE.map_layer:setBlockRectValue(cc.rect(152,88,1,6), "1")
    G_MAINSCENE.map_layer:setBlockRectValue(cc.rect(152,93,8,1), "1")
    G_MAINSCENE.map_layer:setBlockRectValue(cc.rect(164,103,1,15), "1")
    G_MAINSCENE.map_layer:setBlockRectValue(cc.rect(187,120,14,1), "1")
    G_MAINSCENE.map_layer:setBlockRectValue(cc.rect(200,120,1,46), "1")
    G_MAINSCENE.map_layer:setBlockRectValue(cc.rect(147,165,54,1), "1")
    G_MAINSCENE.map_layer:setBlockRectValue(cc.rect(147,149,1,17), "1")
end

function StoryGongSha:clearBlock()
    G_MAINSCENE.map_layer:setBlockRectValue(cc.rect(103,93,1,11), "0")
    G_MAINSCENE.map_layer:setBlockRectValue(cc.rect(107,112,1,7), "0")
    G_MAINSCENE.map_layer:setBlockRectValue(cc.rect(107,118,11,1), "0")
    G_MAINSCENE.map_layer:setBlockRectValue(cc.rect(123,129,26,1), "0")
    G_MAINSCENE.map_layer:setBlockRectValue(cc.rect(124,78,11,1), "0")
    G_MAINSCENE.map_layer:setBlockRectValue(cc.rect(142,84,6,1), "0")
    G_MAINSCENE.map_layer:setBlockRectValue(cc.rect(147,84,1,5), "0")
    G_MAINSCENE.map_layer:setBlockRectValue(cc.rect(147,88,6,1), "0")
    G_MAINSCENE.map_layer:setBlockRectValue(cc.rect(152,88,1,6), "0")
    G_MAINSCENE.map_layer:setBlockRectValue(cc.rect(152,93,8,1), "0")
    G_MAINSCENE.map_layer:setBlockRectValue(cc.rect(164,103,1,15), "0")
    G_MAINSCENE.map_layer:setBlockRectValue(cc.rect(187,120,14,1), "0")
    G_MAINSCENE.map_layer:setBlockRectValue(cc.rect(200,120,1,46), "0")
    G_MAINSCENE.map_layer:setBlockRectValue(cc.rect(147,165,54,1), "0")
    G_MAINSCENE.map_layer:setBlockRectValue(cc.rect(147,149,1,17), "0")
end

function StoryGongSha:setBlock2()
    for i=1, 28 do
        G_MAINSCENE.map_layer:setBlockRectValue(cc.rect(134-i+1,78+i-1,1,2), "1")
    end 
end

function StoryGongSha:clearBlock2()
    for i=1, 28 do
        G_MAINSCENE.map_layer:setBlockRectValue(cc.rect(134-i+1,78+i-1,1,2), "0")
    end 
end

function StoryGongSha:isInArea(idx)
    if G_MAINSCENE == nil then
        return false
    end
    
    local x,y = 0,0
    if idx == 1 then
        x, y = 170,98 
    elseif idx == 2 then
        x, y = 146,69             
    end

    local cur = G_MAINSCENE.map_layer:space2Tile(cc.p(G_ROLE_MAIN:getPosition())) 
    for i = 1, 50 do
        if cur.x == x - i and cur.y < y + i then
            return true
        end
    end 
    
    return false   
end

function StoryGongSha:addWinFlg()
 --[[   local posX_text_success, posY_text_success = display.width/2, display.height * 4 / 6
    local sprite_text_success = cc.Sprite:create("res/fb/winFlg.png")
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
]]
    addFBTipsEffect(self, cc.p(display.width/2, display.height/2), "res/fb/win_2.png")
end

function StoryGongSha:createExitBtn()
    function exitConfirm()
        local exit = function()
            self.m_bExitNow = true
            self:endStroy()
        end

        if self.m_bFinishedCopy then
             self.m_bExitNow = true
             self:endStroy()
        else
             MessageBoxYesNo(nil, game.getStrByKey("exit_confirm2"), exit, nil, game.getStrByKey("sure"), game.getStrByKey("cancel"))
        end
    end
    local item = createMenuItem(self, "res/component/button/1.png", cc.p(g_scrSize.width - 70, g_scrSize.height - 110), exitConfirm)
    item:setSmallToBigMode(false)
    item:setLocalZOrder(100)
    self.exitBtn = item
    self.exitBtnLabel = createLabel(item, game.getStrByKey("fb_leave"), getCenterPos(item), cc.p(0.5, 0.5), 22, true, nil, nil, MColor.lable_yellow, 1);

end

function StoryGongSha:createHangNode()
	local func = function(tag,sender)
		AudioEnginer.playEffect("sounds/uiMusic/ui_click2.mp3",false)
		if game.getAutoStatus() == AUTO_ATTACK then
			game.setAutoStatus(0)
            self.hang_node:setOpacity(255)
		else
			game.setAutoStatus(AUTO_ATTACK)
            self.hang_node:setOpacity(0)
		end
	end

	self.hang_node = createTouchItem(self,{"mainui/anotherbtns/hangup.png"},cc.p(g_scrSize.width-40 ,312),func,true)
	createSprite( self.hang_node , getSpriteFrame("mainui/anotherbtns/stop.png")  , cc.p(0 , 0 ) , cc.p( 0.0 , 0.0 ) , -1 );
end

function StoryGongSha:updateHangNode()
    if not self.hang_node then
        return
    end

    if game.getAutoStatus() == AUTO_ATTACK then
        self.hang_node:setOpacity(0)       
        if self.autoFightEff == nil then
            self.autoFightEff = Effects:create(false)
            self.autoFightEff:playActionData("autoattack", 14, 1, -1, 0)
            self:addChild(self.autoFightEff, 99, 123)
            self.autoFightEff:setAnchorPoint(cc.p(0.5, 0.5))
            self.autoFightEff:setPosition(cc.p(display.cx, display.cy - 130))
        else
            self.autoFightEff:setVisible(true)
        end

        if self.notClearSpecialEff then
            self:removeSpecialSkillSelEffect()
            self.notClearSpecialEff = false
        end
    else
        self.notClearSpecialEff = true
        self.hang_node:setOpacity(255)
        if  self.autoFightEff then
            self.autoFightEff:setVisible(false)
        end
    end
end

function StoryGongSha:hideHangNode()
    if not self.hang_node then
        return
    end

    self.hang_node:setVisible(false)
end

function StoryGongSha:showHangNode()
    if not self.hang_node then
        return
    end

    self.hang_node:setVisible(true)
end

function StoryGongSha:removeSpecialSkillSelEffect()    
    if G_ROLE_MAIN and G_ROLE_MAIN.base_data then
        G_ROLE_MAIN.base_data.spe_skill = {}
    end
    
    if G_MAINSCENE and G_MAINSCENE.skill_node then
        local center_node = G_MAINSCENE.skill_node:getCenterNode()
        if center_node then
            center_node:removeChildByTag(525)
        end
    end  
end

function StoryGongSha:showOperPanel()
    G_MAINSCENE.bloodNode:setLocalZOrder(199) 
    G_MAINSCENE.skill_node:setLocalZOrder(199)
    G_MAINSCENE.operate_node:setLocalZOrder(199)  
    self:showHangNode()  
end

function StoryGongSha:hideOperPanel() 
    G_MAINSCENE.bloodNode:setLocalZOrder(20)
    G_MAINSCENE.skill_node:setLocalZOrder(1)
    G_MAINSCENE.operate_node:setLocalZOrder(6)    
    self:hideHangNode()
end

--隐藏主角的灵兽
function StoryGongSha:hideMyPet() 
    if G_MAINSCENE and G_MAINSCENE.map_layer and G_MAINSCENE.map_layer.pet then
        for k,v in pairs(G_MAINSCENE.map_layer.pet )do
		    if v then v:setVisible(false) end
	    end
    end
end

function StoryGongSha:isCanMove(monster) 
    if self.isEnd == true then
        return false
    end

    return true
end

function StoryGongSha:isMonster(monster)
    if monster == nil then
        return false
    end
    
    --地方阵营返回true
    for k, v in pairs(self.playerTab[2]) do
        if v == monster then
            return true
        end
    end
    
    return false
end

function StoryGongSha:canPick()
    return false
end

function StoryGongSha:canSelectRole()
    if self.isEnd == true then
        return false
    end
    
    return true
end

function  StoryGongSha:getNearestMonsterForCollide()
    
    return nil
end

function StoryGongSha:showSkillActiveTips(skill_id)
    
end

function StoryGongSha:isCanTouchMonster()
    return true
end

return StoryGongSha