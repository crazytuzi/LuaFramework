local StoryNode = class("StoryNode", require ("src/layers/story/StoryBase"))

local path = "res/story/"
local storyDebug = false

function StoryNode:ctor()
	self.state = 0
    self.soldier = {}
    self.monsterTab = {}
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

    local outDelayTime = 9
    startTimerAction(self, outDelayTime, false, function()
        local outBtn = createMenuItem(self, "res/component/button/50.png", cc.p(display.width-100, display.height-50), outBtnFun, 99999)
        createLabel(outBtn, game.getStrByKey("story_out"), getCenterPos(outBtn), cc.p(0.5, 0.5), 22, true)
        outBtn:setOpacity(0)
        outBtn:runAction(cc.Sequence:create(cc.FadeIn:create(0.5)))    
        self.m_outBtn = outBtn   
    end) 

    self:registerScriptHandler(function(event)
        if event == "enter" then  
            -- 开启ai更新
            local function updateAI(dt)
                if G_MAINSCENE == nil or self.isEnd then
                    return
                end
                
                for k, v in pairs(self.RolesAI) do
                    v:update(dt)
                end

                -- 更新罗盘提示
                local node = G_MAINSCENE.operate_node:getChildByTag(1)
                if node ~= nil then
                    local eff = node:getChildByTag(123)
                    if eff ~= nil then
                        if node:getScale() > 0.99 then
                            eff:setVisible(false)
                        else
                            eff:setVisible(true)
                        end
                    end
                end

            end

            self.schedulerHandle = cc.Director:getInstance():getScheduler():scheduleScriptFunc(updateAI, 0.2, false)
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

function StoryNode:updateState()  
    log("StoryNode:updateState state = "..self.state)
    --self:stopAllActions()

	self.state = self.state + 1

	local switch = {
        --片头字幕
        function()  
            local strTab = 
            {
                game.getStrByKey("story_text_0_1"),
                game.getStrByKey("story_text_0_2"),
                game.getStrByKey("story_text_0_3"),
                game.getStrByKey("story_text_0_4"),
            }


            self:addBlack(strTab, false, false, 1)

            startTimerAction(self, 7.0, false, function() 
                                  if self.bInitedAfter ~= true then
                                      self.bInitedAfter = true 
                                      self:updateState()                                             
                                  end
                             end)
        end
        ,

        --初始化
        function()
            local entity1 =
            {
                [ROLE_MODEL] = 1116,
                -- [ROLE_HP] = 100,
            }
            self.targetMonster = G_MAINSCENE.map_layer:addMonster(73, 50, 20073, nil, 1, entity1)
            self.targetMonster:initStandStatus(4, 6, 1, 5)
            self.targetMonster:standed()
            self.targetMonster:setScale(1.1)
            self.targetMonster:setNameLabel("")
            startTimerAction(self, 1, false, function() self.targetMonster:setHP(100); self.targetMonster:showNameAndBlood(false, 0) end)

            local entity2 =
            {
                [ROLE_MODEL] = 6007,
                -- [ROLE_HP] = 100,
            }
            self.targetBoss = G_MAINSCENE.map_layer:addMonster(101, 23, 20087, nil, 2, entity2)
            self.targetBoss:initStandStatus(4, 6, 1, 5)
            self.targetBoss:standed()
            self.targetBoss:setNameLabel("")
            startTimerAction(self, 3, false, function() self.targetBoss:setHP(50000); self.targetBoss:showNameAndBlood(false, 0) end)

            self.explodeNode = cc.Node:create()
            self:addChild(self.explodeNode)

            self:addMonster(1)
            self:addMonster(6)
            self:addMonster(7)
            self:addMonster(9)
            self:addSoldier()
            -- self:addAutoFight()
            self:addRole()
            G_ROLE_MAIN:setSpriteDir(2)
            self:changeRoleDress(true)
            G_ROLE_MAIN:setVisible(false)
            game.setAutoStatus(0)
            local startTilePos = cc.p(41, 67)
            G_ROLE_MAIN:setPosition(G_MAINSCENE.map_layer:tile2Space(startTilePos))
            G_MAINSCENE.map_layer:initDataAndFunc(startTilePos)
            G_MAINSCENE.map_layer:setDirectorScale(nil, startTilePos)
            G_MAINSCENE.map_layer:setMapActionFlag(true)
            G_MAINSCENE.map_layer:moveMapByPos(cc.p(41, 68), false)
            AudioEnginer.setIsNoPlayEffects(true)
            self:addSkill()

            startTimerAction(self, 0.01, false, function() self:updateState() end)
            -- self:setFocusBoss()
            --[[             if storyDebug then
                                    startTimerAction(self, 6.5, false, function()
                                                     if self.bInitedAfter ~= true then
                                                         self.bInitedAfter = true
                                                         self:updateState()
                                                     end
                                                 end)
                                    --self:setFocusBoss()
                                else
                                    startTimerAction(self, 6.5, false, function()
                                                     if self.bInitedAfter ~= true then
                                                         self.bInitedAfter = true
                                                         self:updateState()
                                                     end
                                                end)
                                    --self:setFocusBoss()
                                end

                                self.bInited = true]]
                 
            require("src/base/BaseMapScene").full_mode = nil
        end
        ,     

        --小怪冒泡说话
        function()
           startTimerAction(self, 0.4, false, function() 
                                         if self.blackNode then 
                                             local node = self.blackNode:getChildByTag(123)
                                             if node ~= nil then
                                                 node:runAction(cc.FadeOut:create(1))
                                             end

                                             local text = self.blackNode:getChildByTag(124)
                                             if text ~= nil then
                                                 text:setVisible(false)
                                             end

                                             startTimerAction(self, 1.1, false, function() removeFromParent(self.blackNode); self.blackNode = nil end)
                                         end 
                            end)          
           --startTimerAction(self, 0.4, false, function() self:addBubble(self.monsterTab[9][1], require("src/config/MonsterTalk").storyMonster_talk1, 10, -50, 20) end)   
           --startTimerAction(self, 0.9, false, function() self:addBubble(self.monsterTab[9][2], require("src/config/MonsterTalk").storyMonster_talk2, 10, 0, 50) end)   
           --startTimerAction(self, 1.4, false, function() self:addBubble(self.monsterTab[9][3], require("src/config/MonsterTalk").storyMonster_talk3, 10, 0, 20) end)   
           startTimerAction(self, 1.0, false, function() self:updateState() end)   
        end
        ,

        function() 
            self:addTalk(21, nil, 2) 
            startTimerAction(self, 2, false, function() self:updateState() end)   
        end
        ,

        function() 
            startTimerAction(self, 0.1, false, function() self:addBubble(self.monsterTab[9][1], require("src/config/MonsterTalk").storyMonster_talk1, 10, -50, 20) end)   
            startTimerAction(self, 0.6, false, function() self:addBubble(self.monsterTab[9][2], require("src/config/MonsterTalk").storyMonster_talk2, 10, 0, 50) end)   
            startTimerAction(self, 1.1, false, function() self:addBubble(self.monsterTab[9][3], require("src/config/MonsterTalk").storyMonster_talk3, 10, 0, 20) end)   
            startTimerAction(self, 2.0, false, function() self:updateState() end)  
        end
        ,

        function() 
            dump(g_speed_time)  
            G_MAINSCENE.map_layer:resetSpeed(g_speed_time*0.5)
            G_MAINSCENE.map_layer:moveMapByPos(cc.p(41, 82), false)            
            startTimerAction(self, 2.5, false, function() 
                self.zhanshi:standed()
                self.fashi:standed()
                self.daoshi:standed()
                end)
            --startTimerAction(self, 2, false, function() self.daoshi:magicUpToPos(0.3, cc.p(0, 0)) end)
           -- startTimerAction(self, 3., false, function() self.daoshi:standed() end)        
             startTimerAction(self, 9, false, function() 
                G_ROLE_MAIN:setSpriteDir(2) 
                G_ROLE_MAIN:standed()
                end)
            
            startTimerAction(self, 2.5, false, function() 
                AudioEnginer.setIsNoPlayEffects(false)
                self:updateState() 
                end)
        end
        ,
----------------------------------------------------------断后剧情----------------------------------	
	    function() 
            self:addTalk(30)
         end
        ,

        function() 
            local record = getConfigItemByKey("storyTalk", "q_id", 31)
            local str = string.format(record.q_text, require("src/layers/role/RoleStruct"):getAttr(ROLE_NAME))
            self:addTalk(31, nil, nil, str) 
        end
        ,

        function() 
            local record = getConfigItemByKey("storyTalk", "q_id", 32)
            local str = string.format(record.q_text, require("src/layers/role/RoleStruct"):getAttr(ROLE_NAME))
            self:addTalk(32, nil, nil, str) 
        end
        ,

        function() 
            removeFromParent(self.roleEx) 
            G_ROLE_MAIN:setSpriteDir(2) 
            G_ROLE_MAIN:standed()
            G_ROLE_MAIN:setVisible(true) 
            G_MAINSCENE.map_layer:resetSpeed(g_speed_time)
            self:updateState() 
        end        
        ,

        function()
           self.zhanshi:setSpriteDir(1)
           self.fashi:setSpriteDir(1)
           self.daoshi:setSpriteDir(1)
           G_MAINSCENE.map_layer:setBlockRectValue(cc.rect(52,79,1,5), "1")
           startTimerAction(self, 0.1, false, function() self:moveRole(self.zhanshi, 0.26, cc.p(71, 52)) end)
           startTimerAction(self, 0.05, false, function() self:moveRole(self.fashi, 0.26, cc.p(67, 52)) end)
           startTimerAction(self, 0.08, false, function() self:moveRole(self.daoshi, 0.26, cc.p(71, 55)) end)
           --startTimerAction(self, 0.12, false, function() self:moveSoldier(0.3, cc.p(23, -16)) end)
           startTimerAction(self, 0.12, false, function() self:moveSoldierEx(0.3) end)
           startTimerAction(self, 1, false, function() self:updateState() end)
        end
        ,

        --播放移动视频
        function()
           self:playVideo(1)
           self:showTextTips("story_tuto_tip1", "sounds/storyVoice/2.mp3")
        end
        ,

        --移动教学
        function()
           --添加路径点
           --local start = G_MAINSCENE.map_layer:space2Tile(cc.p(G_ROLE_MAIN:getPosition()))
           local endPoint = cc.p(41,72)
           --local paths = G_MAINSCENE.map_layer:getPathByPos(start, endPoint)
           self:addPathPoint(endPoint)

           --打开罗盘
           G_MAINSCENE.operate_node:setLocalZOrder(9999)
           self.m_manualFight = true

           self:setBlock(1)

           startTimerAction(self, 1, false, function() self:showOperateTips() end)

           --判断是否到达
           self.action = startTimerAction(self, 0.1, true, function() 
                local isArriave = false
                local cur = G_MAINSCENE.map_layer:space2Tile(cc.p(G_ROLE_MAIN:getPosition()))
                if math.abs(cur.x - endPoint.x) < 2 and math.abs(cur.y - endPoint.y) < 2 then
                    isArriave = true
                end
                
                if isArriave == true  then
                    --移除路径点
                    self:removePathPoint()

                    G_MAINSCENE.operate_node:setLocalZOrder(6)
                    self.m_manualFight = false
                    startTimerAction(self, 0.2, false, function() self:updateState() end)   
                    self:stopAction(self.action)
                    self.action = nil                                        
                end
            end)
        end
        ,


        --播放攻击视频
        function()         
           self:playVideo(2)
           self:showTextTips("story_skill_tip","sounds/storyVoice/3.mp3")
        end
        ,

        --攻击教学
        function()
            self.m_bCanTouchMonster = true
            self:showSkill() 
            self:showSkillTips()
            self:resetPick(false)
            self:resetSelectRole(false)
            startTimerAction(self, 2, false, function() self:updateState() end)  
            
            --标记一个怪    
            self.m_curLock = self:lockOneMonster(self.monsterTab[9][1], true)
            G_MAINSCENE.map_layer:touchMonsterFunc(self.monsterTab[9][1]) 
        end
        ,

        --开始自由战斗
        function()
            --开启怪物ai
            for i,v in ipairs(self.monsterTab[9]) do
                v.storyai:fight()
            end

            self:enterManualFight()            
            self.canDrop = true
            self:updateState()   
        end
        ,

        --结束自由战斗
        function()
            self.action = startTimerAction(self, 0.1, true, function() 
                if self.m_curLock ~= nil and self.m_curLock:getHP() < 1 then
                    self:lockOneMonster(self.m_curLock, false)
                    G_MAINSCENE.map_layer:touchMonsterFunc(nil)
                    self.m_curLock = nil
                end

                if self.m_curLock == nil then
                    for i,v in ipairs(self.monsterTab[9]) do
                        if v:getHP() >= 1 then
                           self.m_curLock = self:lockOneMonster(v, true)
                           G_MAINSCENE.map_layer:touchMonsterFunc(v)
                           break
                        end
                    end
                end
                
                local isAllDie = true
                for i,v in ipairs(self.monsterTab[9]) do
                    if v:getHP() >= 1 then
                        isAllDie = false
                        break
                    end
                end

                if isAllDie == true  then                                         
                    self.canDrop = false        
                    if self.baobao ~= nil then self.baobao.storyai:idle() end
                    startTimerAction(self, 1, false, function() self:updateState() end)  
                    self:stopAction(self.action)
                    self.action = nil                              
                end
            end)
        end
        ,

        --播放拾取视频
  --[[      function()
           self:exitManualFight()  
           self:playVideo(3)
           self:showTextTips("story_tuto_tip3","sounds/storyVoice/4.mp3")

           local function removeEffect(btn)
                if btn then
                   btn:removeChildByTag(123)
                end
           end
           local center_node = G_MAINSCENE.skill_node:getCenterNode()
           removeEffect(center_node:getChildByTag(2))
           removeEffect(center_node:getChildByTag(3))
           removeEffect(center_node:getChildByTag(4))
           removeEffect(center_node:getChildByTag(5))
        end
        ,

        --拾取教学
        function()
            self:enterManualFight()    
            self:resetPick(true)       
            startTimerAction(self, 0.1, false, function() self:showPickTips() end)  
            self.action = startTimerAction(self, 0.1, true, function() 
                local isPickOver = true
                for k, v in pairs(G_MAINSCENE.map_layer.goods_tab) do
                    isPickOver = false
                    break
                end

                if isPickOver == true  then
                    self:exitManualFight()  
                    local skillItem = G_MAINSCENE.skill_node:getCenterItem() 
                    skillItem:removeChildByTag(123)
                    self:resetPick(false)
                    self:clearBlock(1) 
                    startTimerAction(self, 0.5, false, function() self:updateState() end)  
                    self:stopAction(self.action)
                    self.action = nil         
                    self.m_bCanTouchMonster = false                            
                end
            end)   
            
            --15秒后进入下一步
            startTimerAction(self, 15, false, function() 
                for v,k in pairs(G_MAINSCENE.map_layer.goods_tab) do
                    G_MAINSCENE.map_layer.item_Node:removeChildByTag(v)
                end

                G_MAINSCENE.map_layer.goods_tab = {}
            end)          
        end
        ,   
]]  

        function() 
            self:exitManualFight()
            local function removeEffect(btn)
                if btn then
                    btn:removeChildByTag(123)
                end
            end
            local center_node = G_MAINSCENE.skill_node:getCenterNode()
            removeEffect(center_node:getChildByTag(2))
            removeEffect(center_node:getChildByTag(3))
            removeEffect(center_node:getChildByTag(4))
            removeEffect(center_node:getChildByTag(5))
            self:clearBlock(1)
            self.m_bCanTouchMonster = false 
            startTimerAction(self, 0.5, false, function() self:updateState() end)
        end
        ,
               
        function() 
            G_MAINSCENE.skill_node:removeChildByTag(525) 
            G_MAINSCENE.skill_node:getCenterNode():removeChildByTag(525) 
            G_ROLE_MAIN.base_data.spe_skill = {}
            
            --local record = getConfigItemByKey("storyTalk", "q_id", 33)
            --local str = string.format(record.q_text, require("src/layers/role/RoleStruct"):getAttr(ROLE_NAME))
            --self:addTalk(33, nil, 3, str) 
            startTimerAction(self, 0.1, false, function() self:updateState() end)  
        end
        , 

        --追上三圣王
        function()
           self:setBlock(3)
           --local start = G_MAINSCENE.map_layer:space2Tile(cc.p(G_ROLE_MAIN:getPosition()))
           G_MAINSCENE.map_layer:resetSpeed(g_speed_time*0.5)
           
           local endPoint = cc.p(68,54)
           --local paths = G_MAINSCENE.map_layer:getPathByPos(start, endPoint)
           self:addPathPoint(endPoint)
           G_MAINSCENE.operate_node:setLocalZOrder(9999)
           self.m_manualFight = true
           self:showTextTips("story_tuto_tip4", nil, true)

           --判断是否到达
           local prePos = nil
           local addTime = 0
           self.action = startTimerAction(self, 0.1, true, function() 
                local isArriave = false
                local cur = G_MAINSCENE.map_layer:space2Tile(cc.p(G_ROLE_MAIN:getPosition()))
                if math.abs(cur.x - endPoint.x) < 2 and math.abs(cur.y - endPoint.y) < 2 then
                    isArriave = true
                end

                if prePos == nil then
                    prePos = cur
                else
                    if prePos.x == cur.x and prePos.y == cur.y then
                        addTime = addTime + 0.1
                        if addTime > 0.2 then
                           if self.moveAcel ~= nil then self.moveAcel:setVisible(false) end                         
                        end
                    else
                        if self.moveAcel == nil then
                           self.moveAcel = Effects:create(false)
                           self.moveAcel:playActionData("storyrun", 14, 3, -1, 0)
                           self:addChild(self.moveAcel, 99, 123)
                           self.moveAcel:setAnchorPoint(cc.p(0.5, 0.5))
                           self.moveAcel:setPosition(cc.p(display.cx, display.cy - 100))
                        end

                        self.moveAcel:setVisible(true)
                        addTime = 0
                    end

                    prePos = cur
                end
                
                if isArriave == true  then
                    self:removePathPoint()
                    G_MAINSCENE.operate_node:setLocalZOrder(6)
                    self.m_manualFight = false
                    startTimerAction(self, 0.2, false, function() self:updateState() end)   
                    self:stopAction(self.action)
                    self.action = nil                                        
                end
            end)

            --移动灵兽
           if self.baobao ~= nil then
               self.baobao.storyai:idle()
               startTimerAction(self, 0.1, false, function() self:moveRole(self.baobao, 0.26, cc.p(69, 55)) end)
           end
        end
        ,

        --调整主角位置
        function() 
            --local node = G_MAINSCENE.operate_node:getChildByTag(1)
            --if node ~= nil then node:setVisible(false) end

            G_MAINSCENE.map_layer:resetSpeed(g_speed_time)
            if self.moveAcel ~= nil then
                self.moveAcel:removeFromParent(true)
                self.moveAcel = nil
            end

            G_MAINSCENE.map_layer:cleanAstarPath(true,true)
            --startTimerAction(self, 0.05, false, function() G_MAINSCENE.map_layer:moveMapByPos(cc.p(68, 54), false) end) 
            startTimerAction(self, 1.5, false, function() G_ROLE_MAIN:setSpriteDir(1)end) 
            startTimerAction(self, 0.1, false, function() self:updateState() end) 
        end 
        ,
        

-----------------------------------------------------展示技能剧情---------------------------------------------

 --[[       function() self:addTalk(1) end
        ,

        function() self:addTalk(2) end
        ,

        function() self:addTalk(3) end
        ,
]]
        function() 
            local record = getConfigItemByKey("storyTalk", "q_id", 34)
            local str = string.format(record.q_text, require("src/layers/role/RoleStruct"):getAttr(ROLE_NAME))
            self:addTalk(34, nil, nil, str)
        end
        ,

		function()
            --local node = G_MAINSCENE.operate_node:getChildByTag(1)
           -- if node ~= nil then node:setVisible(true) end
            
            G_MAINSCENE.map_layer:setMapActionFlag(false)
            G_MAINSCENE.map_layer:runAction(cc.Sequence:create(cc.MoveBy:create(0.2, cc.p(-150, -50))))
            self:addTalk(4, nil, 2)
            self.zhanshi:setSpriteDir(1)
            self.zhanshi:collideInTheDir(0.5, G_MAINSCENE.map_layer:tile2Space(cc.p(74, 49)), 1)
            startTimerAction(self, 0.2, false, function() self.targetMonster:runAction(cc.MoveTo:create(0.3, G_MAINSCENE.map_layer:tile2Space(cc.p(75, 48))))  end)--self.targetMonster:walkInTheDir(0.1, G_MAINSCENE.map_layer:tile2Space(cc.p(48, 48)), 5)
            startTimerAction(self, 1, false, function() self.zhanshi:standed() end)
            startTimerAction(self, 0.45, false, function() self.zhanshi:attackOneTime(0.2, cc.p(0, 0)) G_MAINSCENE.map_layer:playSkillEffect(0.1, 1006, self.zhanshi, self.targetMonster, nil, nil) end)
            startTimerAction(self, 1.5, false, function() self.targetMonster:setHP(0) self.targetMonster:gotoDeath(7) end)
            startTimerAction(self, 2.5, false, function() self:updateState() end)
		end
		,

        function() 
            G_MAINSCENE.map_layer:runAction(cc.Sequence:create(cc.MoveBy:create(0.8, cc.p(150, 50))))
            --self:addTalk(16) 
            self.targetMonster:runAction(cc.Sequence:create(cc.DelayTime:create(3), cc.FadeOut:create(2), cc.CallFunc:create(function() self.targetMonster:removeFromParent() end)))
            startTimerAction(self, 1.0, false, function() self:updateState() end)
        end
        ,

        function()
            self:addTalk(5, nil, 2)
            --startTimerAction(self, 0.0, false, function() self.fashi:magicUpToPos(0.3, cc.p(0, 0)) G_MAINSCENE.map_layer:playSkillEffect(0.1, 7000, self.fashi, self.fashi, G_MAINSCENE.map_layer:tile2Space(cc.p(48, 48)), nil) end)
            startTimerAction(self, 0.0, false, function() self.fashi:magicUpToPos(0.3, cc.p(0, 0)) self:addFashiSkillEffect(2, 10, 10) end)
            startTimerAction(self, 1, false, function() self.fashi:standed() end)
            startTimerAction(self, 3, false, function() self:removeMonster(1) end)
            startTimerAction(self, 3, false, function() self:updateState() end)
        end
        ,       

 --[[       function() 
            local record = getConfigItemByKey("storyTalk", "q_id", 6)
            local str = string.format(record.q_text, require("src/layers/role/RoleStruct"):getAttr(ROLE_NAME))
            self:addTalk(6, nil, nil, str)
        end
        ,
]]
        function()
            self:addTalk(17, nil, 2)
            startTimerAction(self, 0.0, false, function() self.daoshi:magicUpToPos(0.3, cc.p(0, 0)) G_MAINSCENE.map_layer:playSkillEffect(0.3, 3006, self.daoshi, self.daoshi, nil, nil) end)--G_MAINSCENE.map_layer:space2Tile(cc.p(self.zhanshi:getPosition()))
            startTimerAction(self, 0.4, false, function() self:addBuff() end)
            startTimerAction(self, 0.5, false, function() self.daoshi:standed() end)
            startTimerAction(self, 2, false, function() self:updateState() end)
        end
        ,

        function()
           self:clearBlock(3) 
           G_MAINSCENE.map_layer:resetSpeed(g_speed_time*1.1)
           startTimerAction(self, 0.1, false, function() self:moveRole(self.zhanshi, 0.31, cc.p(97, 26)) end)
           startTimerAction(self, 0.1, false, function() self:moveRole(self.fashi, 0.3, cc.p(94, 26)) end)
           startTimerAction(self, 0.1, false, function() self:moveRole(self.daoshi, 0.3, cc.p(98, 29)) end)
           if self.baobao ~= nil then
               startTimerAction(self, 0.1, false, function() self:moveRole(self.baobao, 0.3, cc.p(96, 29)) end)
           end
           G_MAINSCENE.map_layer:setMapActionFlag(true)
           startTimerAction(self, 0.2, false, function() G_MAINSCENE.map_layer:moveMapByPos(cc.p(95, 28), false) end)            
           startTimerAction(self, 0.1, false, function() self:moveSoldier(0.3, cc.p(27, -26)) end)
           startTimerAction(self, 8, false, function() self:updateState() end)
        end
        ,
---------------------------------------------------------初次与boss对话----------------------------------
       function() 
            G_MAINSCENE.map_layer:resetSpeed(g_speed_time)
            G_MAINSCENE.map_layer:setMapActionFlag(false)
            G_MAINSCENE.map_layer:runAction(cc.Sequence:create(cc.MoveBy:create(1.5, cc.p(-200, -100))))
            startTimerAction(self, 1.6, false, function() self:updateState() end)
        end
        ,

        function() self:addTalk(8) end
        ,

        function() self:addTalk(9) end
        ,

  --[[      function() 
            G_MAINSCENE.map_layer:resetSpeed(g_speed_time)
            self:addTalk(7) 
            G_MAINSCENE.map_layer:setMapActionFlag(false)
            G_MAINSCENE.map_layer:runAction(cc.Sequence:create(cc.MoveBy:create(2, cc.p(-200, -100))))
        end
        ,

        function()
            --self:setFocusBoss()
            self:moveMonster(self.targetBoss, 1, cc.p(100, 24))
            startTimerAction(self, 1.1, false, function() self.targetBoss:attackOneTime(0.5, cc.p(0, 0)) end)
            startTimerAction(self, 2, false, function() self.targetBoss:standed() end)
            startTimerAction(self, 2, false, function() self:updateState() end)
        end
        ,

        function() self:addTalk(8) end
        ,

        function() self:addTalk(9) end
        ,
        ]]
---------------------------------------------------------三圣攻击boss----------------------------------
        function()
            --self:addTalk(18, 1.5, 2)
            self:moveRole(self.zhanshi, 0.26, cc.p(100, 24))
            startTimerAction(self, 0.5, false, function() 
                self.zhanshiAction = startTimerAction(self, 1.2, true, function() self.zhanshi:attackOneTime(0.35, cc.p(0, 0)) G_MAINSCENE.map_layer:playSkillEffect(0.1, 1102, self.zhanshi, self.targetBoss, nil, nil) end)
            end)

            self.bossAction = startTimerAction(self, 1.2, true, function() self.targetBoss:attackOneTime(0.35, cc.p(0, 0)) end)
            self.bossSkillAction = startTimerAction(self, 1.2, true, function() self:addBossSkillEffect(cc.p(100, 24)) end)

            self.fashiAction = startTimerAction(self, 1.2, true, function() self.fashi:magicUpToPos(0.3, cc.p(0, 0))  CMagicCtrlMgr:getInstance():CreateMagic(2010, 0, self.fashi:getTag(), self.targetBoss:getTag(), 0) end)
            self.daoshiAction = startTimerAction(self, 1.2, true, function() self.daoshi:magicUpToPos(0.3, cc.p(0, 0)) G_MAINSCENE.map_layer:playSkillEffect(0.3, 3011, self.daoshi, self.targetBoss, nil, nil) end)
 
            --startTimerAction(self, 3.3, false, function() 
           --     G_MAINSCENE.map_layer:runAction(cc.Sequence:create(cc.MoveBy:create(0.3, cc.p(200, 100))))
           -- end)

            startTimerAction(self, 0.3, false, function() self:updateState() end)
        end
        ,

 --[[       function() 
            self:addTalk(10, 0.8, 3) 
            self.fashiAction = startTimerAction(self, 1.2, true, function() self.fashi:magicUpToPos(0.3, cc.p(0, 0))  CMagicCtrlMgr:getInstance():CreateMagic(2010, 0, self.fashi:getTag(), self.targetBoss:getTag(), 0) end)
            startTimerAction(self, 4, false, function() self:updateState() end)
        end
        ,

        function() 
            self:addTalk(11, 0.8, 3) 
            self.daoshiAction = startTimerAction(self, 1.2, true, function() self.daoshi:magicUpToPos(0.3, cc.p(0, 0)) G_MAINSCENE.map_layer:playSkillEffect(0.3, 3011, self.daoshi, self.targetBoss, nil, nil) end)
            startTimerAction(self, 2.6, false, function() self:updateState() end)
            startTimerAction(self, 3.3, false, function() 
                G_MAINSCENE.map_layer:runAction(cc.Sequence:create(cc.MoveBy:create(0.3, cc.p(200, 100))))
            end)
        end
        ,
]]
        --小兵战斗
        function()             
            self:addAutoFightEx()
            if self.baobao ~= nil then
               self.baobao.storyai:fight()
            end

            G_MAINSCENE.map_layer:touchMonsterFunc(self.targetBoss)
            game.setAutoStatus(4) 
            self.autoFight = Effects:create(false)
            self.autoFight:playActionData("autoattack", 14, 1, -1, 0)
            self:addChild(self.autoFight, 99, 123)
            self.autoFight:setAnchorPoint(cc.p(0.5, 0.5))
            self.autoFight:setPosition(cc.p(display.cx, display.cy - 100))

            startTimerAction(self, 5, false, function() self:updateState() end)
        end
        ,

        --定住所有角色
--[[        function() 
            self.zhanshi:standed()
            self.fashi:standed()
            self.daoshi:standed()
            self:stopAction(self.zhanshiAction)
            self.zhanshiAction = nil
            self:stopAction(self.fashiAction)
            self.fashiAction = nil
            self:stopAction(self.daoshiAction)
            self.daoshiAction = nil
            
            self:stopAction(self.bossAction)
            self.bossAction = startTimerAction(self, 1.2, true, function() self.targetBoss:attackOneTime(0.35, cc.p(0, 0)) end)
            self:removeBossSkillEffect()
            self:addBossLightningEffect()
            --self:addEarthQuake()
            startTimerAction(self, 0.3, false, function() self:stopInTime() end)
            --startTimerAction(self, 1, false, function() self:updateState() end)

            local record = getConfigItemByKey("storyTalk", "q_id", 35)
            local str = string.format(record.q_text, require("src/layers/role/RoleStruct"):getAttr(ROLE_NAME))
            self:addTalk(35, nil, nil, str)
        end
        ,

        --开放手动战斗
        function() 
            self.m_bCanTouchMonster = true
            G_MAINSCENE.map_layer:setMapActionFlag(true)
            self:enterManualFight()
            self:setBlock(2)

            G_MAINSCENE.map_layer:touchMonsterFunc(self.targetBoss)

            startTimerAction(self, 20, false, function() self:updateState() end)
        end
        ,
]]
        function()
            self:exitManualFight() 
            self:addTalk(15, nil, 3) 
            self:addMonster(3, true)
            if self.monsterTab[3] then
                local tab = self.monsterTab[3]
                for k, v in pairs(tab) do
                    if v:getMonsterId() == 20001 then
                        self:moveMonster(v, 3, cc.p(95, 28))
                    end
                end
            end

            self:stopAction(self.bossAction)
            self.bossAction = startTimerAction(self, 1.2, true, function() self.targetBoss:attackOneTime(0.35, cc.p(0, 0)) end)
            self:removeBossSkillEffect()
            self:addBossLightningEffect()

            startTimerAction(self, 5, false, function() self:updateState() end)
        end
        ,
--[[
--------------------------------------------------------自动战斗----------------------------------
        function()
            self.m_bCanTouchMonster = true
            G_MAINSCENE.map_layer:setMapActionFlag(true)
            --G_MAINSCENE.map_layer:moveMapByPos(cc.p(76, 29), false)
            startTimerAction(self, 2, false, function() 
                                 game.setAutoStatus(4) 
                                self.autoFight = Effects:create(false)
                                self.autoFight:playActionData("autoattack", 14, 1,-1,0)
                                self:addChild(self.autoFight, 99, 123)
                                self.autoFight:setAnchorPoint(cc.p(0.5, 0.5))
                                self.autoFight:setPosition(cc.p( display.cx , display.cy - 100 ))

                                 self.action = startTimerAction(self, 0.01, true, function() 
                                                                   local bOver = false
                                                                   if self.monsterTab[6][5] ~= nil and self.monsterTab[7][5] ~= nil then
                                                                      if self.monsterTab[6][5]:getHP() < 1 and self.monsterTab[7][5]:getHP() < 1 then
                                                                          bOver = true
                                                                      end
                                                                   end

                                                                   if bOver == true then
                                                                       game.setAutoStatus(0)
                                                                       --if self.autoFight ~= nil then
                                                                       --    self.autoFight:removeFromParent(true)
                                                                       --    self.autoFight = nil
                                                                       --end

                                                                       self:stopAction(self.action)
                                                                       self.action = nil 
                                                                   end                                       
                                                                end)
                             end)
            self:addAutoFightEx()
            if self.baobao ~= nil then
               self.baobao.storyai:fight()
            end

            startTimerAction(self, 13, false, function() self:updateState() end)
        end
        ,

---------------------------------------------------------结束自动战斗----------------------------------
        function() 
            if self.action ~= nil then
                self:stopAction(self.action)
                self.action = nil 
            end
            
            if self.autoFight ~= nil then
                self.autoFight:removeFromParent(true)
                self.autoFight = nil
            end

            game.setAutoStatus(0)         
            G_MAINSCENE.map_layer:moveMapByPos(cc.p(95, 28), false)            
            startTimerAction(self, 2.8, false, function() G_ROLE_MAIN:setSpriteDir(1) end)
            self:addTalk(12, 2, 3)
            startTimerAction(self, 4, false, function() self:updateState() end)
        end
        ,

        function()          
            startTimerAction(self, 0, false, function() self.targetBoss:attackOneTime(0.5, cc.p(0, 0)) end)
            G_MAINSCENE.map_layer:setMapActionFlag(false)
            G_MAINSCENE.map_layer:runAction(cc.Sequence:create(cc.MoveBy:create(0.3, cc.p(270,200))))
            startTimerAction(self, 0.5, false, function() self:addMonster(3, true) end)
            startTimerAction(self, 1, false, function() self.targetBoss:standed() end)
            startTimerAction(self, 1, false, function() self:updateState() end)
        end   
        ,
        
        function()
            self:stopAction(self.bossAction)
            self.bossAction = startTimerAction(self, 1.2, true, function() self.targetBoss:attackOneTime(0.35, cc.p(0, 0)) end)
            startTimerAction(self, 2, false, function() self:updateState() end)
        end
        ,
---------------------------------------------------------被怪物包围及对话等----------------------------------
        function() 
            G_MAINSCENE.map_layer:setMapActionFlag(false)
            G_MAINSCENE.map_layer:runAction(cc.Sequence:create(cc.MoveBy:create(3, cc.p(-270,-200))))
            self:addTalk(13, nil, 4) 
            startTimerAction(self, 4.5, false, function() self:updateState() end)
        end
        ,

        function() 
            self:addTalk(14, nil, 3) 
            startTimerAction(self, 3.2, false, function() self:updateState() end)
        end
        ,
--------------------------------------------------------停止所有攻击，怪物准备变身----------------------------------
        function()
            self:addTalk(20, nil, 3)

            startTimerAction(self, 1.5, false, function() 
                    local pos = cc.p(self.targetBoss:getPosition())
                    local effect = Effects:create(false)
                    effect:playActionData("storyBoss", 14, 1.5, 3)
                    G_MAINSCENE.map_layer:addChild(effect)
                    effect:setPosition(pos)
                    effect:setScale(1.2)
                    startTimerAction(self, 5, false, function() removeFromParent(effect) end)

                    self.zhanshi:standed()
                    self.fashi:standed()
                    self.daoshi:standed()
                    self:stopAction(self.zhanshiAction)
                    self.zhanshiAction = nil
                    self:stopAction(self.fashiAction)
                    self.fashiAction = nil
                    self:stopAction(self.daoshiAction)
                    self.daoshiAction = nil
                    self:stopAction(self.bossAction)
                    self.bossAction = nil
                    --self:stopAllActions()

                    self.zhanshi:runAction(cc.MoveTo:create(0.2, G_MAINSCENE.map_layer:tile2Space(cc.p(96, 27))))
                    self.fashi:runAction(cc.MoveTo:create(0.2, G_MAINSCENE.map_layer:tile2Space(cc.p(93, 28))))
                    self.daoshi:runAction(cc.MoveTo:create(0.2, G_MAINSCENE.map_layer:tile2Space(cc.p(97, 31))))
                    G_ROLE_MAIN:runAction(cc.MoveTo:create(0.2, G_MAINSCENE.map_layer:tile2Space(cc.p(93, 30))))

                    startTimerAction(self, 2.5, false, function() self:updateState() end)
                end) 
        end
        ,

---------------------------------------------------------怪物变身---------------------------------
      function()
            --self:setFocusBoss()
            self:removeBossSkillEffect()
            self:addTalk(19, nil, 3)
            game.setAutoStatus(0)
            startTimerAction(self, 0.2, false, function() 
                    G_MAINSCENE.map_layer:setMapActionFlag(false)
                    G_MAINSCENE.map_layer:runAction(cc.Sequence:create(cc.MoveBy:create(0.2, cc.p(-192, -96))))
                end)
            -- startTimerAction(self, 1, false, function() 
            --         self:setFocusBoss()
            --     end)
            startTimerAction(self, 1.5, false, function() 
                    self:bossChange()
                    -- self.zhanshi:runAction(cc.MoveTo:create(0.2, G_MAINSCENE.map_layer:tile2Space(cc.p(70, 26))))
                    -- self.fashi:runAction(cc.MoveTo:create(0.2, G_MAINSCENE.map_layer:tile2Space(cc.p(70, 26))))
                    -- self.daoshi:runAction(cc.MoveTo:create(0.2, G_MAINSCENE.map_layer:tile2Space(cc.p(70, 26))))
                end)
            startTimerAction(self, 1, false, function() 
                    self.targetBoss:setVisible(false)
                    self.targetBoss:setBaseUrl("20079") 
                    self.targetBoss:setPlistsNum(3)
                    self.targetBoss:standed()

                    local effect = Effects:create(false)
                    effect:playActionData("storyBossChange", 7, 1, 1)
                    G_MAINSCENE.map_layer:addChild(effect)
                    effect:setPosition(cc.p(self.targetBoss:getPosition()))
                    startTimerAction(self, 1.1, false, function() removeFromParent(effect) end)

                end)
            startTimerAction(self, 2.1, false, function() 
                    -- self.targetBoss:setBaseUrl("20079") 
                    -- self.targetBoss:setPlistsNum(3)
                    -- self.targetBoss:standed()
                    self.targetBoss:standed()
                    self:moveMonster(self.targetBoss, 0.26, cc.p(99, 25))
                    self.targetBoss:setVisible(true)
                    startTimerAction(self, 0.5, false, function() self.targetBoss:standed() self.targetBoss:setVisible(true) end)
                end)
            startTimerAction(self, 4, false, function() 
                    self:cancelFocusBoss()
                end)
            startTimerAction(self, 4, false, function() self:updateState() end)
        end
        ,

        function()            
            startTimerAction(self, 1, false, function() self:moveMonster(self.targetBoss, 0.26, cc.p(97, 26)) end) 
            startTimerAction(self, 1.2, false, function() self.targetBoss:attackOneTime(0.4, cc.p(0, 0)) end)
            self:addBossLightningEffect()
            self:addEarthQuake()
            startTimerAction(self, 0.3, false, function() self:stopInTime() end)         
            G_MAINSCENE.map_layer:runAction(cc.Sequence:create(cc.MoveBy:create(0.5, cc.p(192+96, 96+64))))
            startTimerAction(self, 3, false, function() self:updateState() end)
        end
        ,
        
---------------------------------------------------------再次开启交互战斗----------------------------------
        --开始自由战斗
        function()
            G_MAINSCENE.map_layer:setMapActionFlag(true)
            G_MAINSCENE.map_layer:scroll2Tile(cc.p(93, 30))

            G_MAINSCENE.map_layer:touchMonsterFunc(self.targetBoss)

            --标记boss
            local select_effect = Effects:create(false)
			select_effect:setAnchorPoint(cc.p(0.5,0.43))
            select_effect:playActionData("redtag2",8,2,-1)
            --select_effect:setOpacity(128) 
            select_effect:setScale(1)
			self.targetBoss:addChild(select_effect, 0, 789)
            addEffectWithMode(select_effect,3)				

            startTimerAction(self, 1.2, true, function() self.targetBoss:attackOneTime(0.4, cc.p(0, 0)) end)
            self:enterManualFight()
            self:setBlock(2)
            self:updateState()
        end
        ,

        --20秒后结束自由战斗
        function()
            startTimerAction(self, 20, false, function() 
                    self:exitManualFight() 
                    self:updateState()                
            end)
        end
        ,
 
        function() 
            self:addTalk(15, nil, 3) 
            --game.setAutoStatus(4)
            startTimerAction(self, 3, false, function() self:updateState() end)
        end
        ,

        function() 
            for i=3,3 do
                if self.monsterTab[i] then
                    local tab = self.monsterTab[i]
                    for k,v in pairs(tab) do
                        if v:getMonsterId() == 20001 then
                            self:moveMonster(v, 3, cc.p(95, 28))
                        end
                    end
                end
            end
            self:updateState()
        end
        ,

        function() 
            --startTimerAction(self, 0, false, function() self:showSkill() end)
            startTimerAction(self, 8, false, function() self:updateState() end)
        end
        ,
]]
        function() 
            --self:hideSkill()
            --game.setAutoStatus(4)
            if self.m_outBtn then
                self.m_outBtn:setVisible(false)
            end
            startTimerAction(self, 1.5, false, function() 
            self:addWhite(false) 
            G_MAINSCENE.map_layer.on_attack = nil 
            if self.autoFight ~= nil then self.autoFight:removeFromParent(true); self.autoFight = nil; end          
            end)
        end
        ,

        function() 
            -- AudioEnginer.stopMusic()
            -- AudioEnginer.setIsNoPlayEffects(true)
            self:stopAction(self.lightAction)
            self.lightAction = nil

            self:addAudioEffect() 
            local schoolStr = 
            {
                game.getStrByKey("zhanshi"),
                game.getStrByKey("fashi"),
                game.getStrByKey("daoshi"),
            }
            local strTab = 
            {
                game.getStrByKey("story_text_1_1"),
                string.format(game.getStrByKey("story_text_1_2"), require("src/layers/role/RoleStruct"):getAttr(ROLE_NAME), schoolStr[require("src/layers/role/RoleStruct"):getAttr(ROLE_SCHOOL)]),
            }
            self:addBlack(strTab, true, true, 2)  
            self:changeRoleDress(false) 
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

function StoryNode:endStroy()
    self.isEnd = true
    game.setAutoStatus(0)

    if self.schedulerHandle then 
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry( self.schedulerHandle ) 
        self.schedulerHandle = nil
    end 

    --移除锁
    if self.selLock ~= nil then
        self.selLock:removeFromParent(true)
        self.selLock = nil
    end

    if self.pickLock ~= nil then
        self.pickLock:removeFromParent(true)
        self.pickLock = nil
    end

    --删除罗盘效果
    local lpNode = G_MAINSCENE.operate_node:getChildByTag(1)
    if lpNode ~= nil then
        lpNode:removeChildByTag(123, true)
    end

    --移除魔法盾效果
    local topNode = G_ROLE_MAIN:getTopNode()
    if topNode ~= nil and topNode:getChildByTag(80) ~= nil then
        topNode:removeChildByTag(80)
    end

    --去除阻挡
    self:clearBlock(1) 
    self:clearBlock(2) 
    self:clearBlock(3) 
    
    self:stopAllActions()
    self:changeRoleDress(false)
    self:removeSkill()
    AudioEnginer.setIsNoPlayEffects(getGameSetById(GAME_SET_ID_CLOSE_VOICE)==0)
    self:removeAudioEffect()
    --为了防止服务器不能正常通过协议初始化新手引导数据
    tutoInitTutoData()

    G_MAINSCENE.map_layer:setMapActionFlag(true)

    --移除闪电特效
    if self.lightAction ~= nil then
        self:stopAction(self.lightAction)
        self.lightAction = nil
    end

    self:removePathPoint()  

    --主角名称颜色切换
    if G_ROLE_MAIN.nameLabel ~= nil and self.mainRoleColor ~= nil then
                
        --local color_map = {cc.c3b(150, 117, 59),cc.c3b(20, 55, 107),cc.c3b(104, 67, 86)}
        G_ROLE_MAIN.nameLabel:setColor(self.mainRoleColor)
    end

    G_ROLE_MAIN.base_data.spe_skill = {}
    G_MAINSCENE.map_layer:resetSpeed(g_speed_time)

    g_msgHandlerInst:sendNetDataByTableExEx(TASK_CS_FINISHSTORY, "FinishStoryProtocol", {})
    --startTimerAction(G_MAINSCENE, 0, false, function() self:removeAudioEffect() end)
    print("end ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")

    --G_MAINSCENE:exitStoryMode()
    if self.m_outBtn and self.m_outBtn:isVisible() then
        if G_MAINSCENE.storyNode then
            removeFromParent(G_MAINSCENE.storyNode)
	        G_MAINSCENE.storyNode = nil  
        end
    end   
end

function StoryNode:addFashiSkillEffect(time, width, height)
    self.fashiSkillEffectPos = 
    {
        cc.p(65, 44),
        cc.p(72, 45),
        cc.p(74, 47),
        cc.p(68, 53),
        cc.p(77, 57),
        cc.p(75, 60),
        cc.p(66, 50),
        cc.p(69, 43),
        cc.p(77, 44),
        cc.p(82, 54),
        cc.p(66, 46),
        cc.p(80, 52),
        --cc.p(71, 60),
        cc.p(62, 48),
        cc.p(62, 51),
        cc.p(81, 48),
        cc.p(73, 61),
        cc.p(72, 56),
    }
 
    self.fashiSkillEffecIndex = 1
    -- for i,v in ipairs(self.fashiSkillEffectPos) do
    --     G_MAINSCENE.map_layer:playSkillEffect(0.2*i, 2011, self.fashi, nil, G_MAINSCENE.map_layer:tile2Space(self.fashiSkillEffectPos[i]), nil)
    -- end
   
    self.fashiSkillEffectAction = startTimerAction(self, 0.1, true, function() 
                if self.fashiSkillEffecIndex <= #self.fashiSkillEffectPos then
                    G_MAINSCENE.map_layer:playSkillEffect(0.1, 2011, self.fashi, nil, G_MAINSCENE.map_layer:tile2Space(self.fashiSkillEffectPos[self.fashiSkillEffecIndex]), nil)
                    self.fashiSkillEffecIndex = self.fashiSkillEffecIndex + 1
                    --if self.fashiSkillEffecIndex % 8 == 1 then
                    --    AudioEnginer.playEffect("sounds/skillMusic/2011.mp3",false)
                    --end
                else
                    self:stopAction(self.fashiSkillEffectAction)
                end
            end)


    -- self.fashiEffectAction = startTimerAction(self, 0.1, true, function() 
    --     math.randomseed(os.clock())
    --     local x = 73 + math.random(-width, width)
    --     local y = 24 + math.random(-height, height)
    --     G_MAINSCENE.map_layer:playSkillEffect(0.1, 2011, self.fashi, nil, G_MAINSCENE.map_layer:tile2Space(cc.p(x, y)), nil) 
    --     end)
    -- startTimerAction(self, time, false, function()
    --     if self.fashiEffectAction then
    --         self:stopAction(self.fashiEffectAction)
    --         self.fashiEffectAction = nil
    --     end
    --  end)
end

function StoryNode:setFocusBoss()
    -- local map = cc.TMXTiledMap:create("res/map/".."xsjq.tmx")
    -- local blockLayer = map:getLayer("blockLayer")
    -- local lockLayerSize = blockLayer:getLayerSize()
    -- local tileSize = blockLayer:getMapTileSize()
    -- local mapSize = cc.size(lockLayerSize.width * tileSize.width, lockLayerSize.height * tileSize.height)
    -- dump(lockLayerSize)
    -- dump(tileSize)
    -- dump(mapSize)

    local scale = G_MAINSCENE.map_layer:getScale()
    self.scale = scale
    dump(scale)
    G_MAINSCENE.map_layer:runAction(cc.Sequence:create(cc.MoveBy:create(0.2, cc.p(-150*scale, -100*scale))))
    --local pos = G_MAINSCENE.map_layer:space2Tile(cc.p(self.targetBoss:getPosition()))
    -- dump(pos)
    --G_MAINSCENE.map_layer:scroll2Tile(pos)
    -- dump(G_MAINSCENE.map_layer:getAnchorPoint())
    -- dump(self.targetBoss:getPosition())
    -- dump(G_MAINSCENE.map_layer:getContentSize())
    -- dump(G_MAINSCENE.map_layer:getScale())
    -- local anchorPoint = cc.p(self.targetBoss:getPositionX()/(G_MAINSCENE.map_layer:getContentSize().width*scale), 
    --     self.targetBoss:getPositionY()/(G_MAINSCENE.map_layer:getContentSize().height*scale))
    -- -- dump(anchorPoint)
    -- G_MAINSCENE.map_layer:setAnchorPoint(anchorPoint)
    -- G_MAINSCENE.map_layer:runAction(cc.Sequence:create(cc.ScaleTo:create(0.5, scale*1.2)))
end

function StoryNode:cancelFocusBoss()
    -- G_MAINSCENE.map_layer:runAction(cc.Sequence:create(cc.ScaleTo:create(0.5, self.scale), cc.CallFunc:create(function() 
    --     G_MAINSCENE.map_layer:setAnchorPoint(cc.p(0.5, 0.5)) 
    --     end)))
end

function StoryNode:bossChange()
    local pos = cc.p(self.targetBoss:getPosition())
    local effect = Effects:create(false)
    effect:playActionData("storyBoss", 14, 1.5, 1)
    G_MAINSCENE.map_layer:addChild(effect)
    effect:setPosition(pos)
    --effect:setScale(2)
    startTimerAction(self, 1.7, false, function() removeFromParent(effect) end)

    -- local pos = cc.p(self.targetBoss:getPosition())
    -- local effect = Effects:create(false)
    -- effect:playActionData("storyBoss1", 5, 0.5, 1)
    -- G_MAINSCENE.map_layer:addChild(effect)
    -- effect:setPosition(pos)
    -- startTimerAction(effect, 0.7, false, function() removeFromParent(effect) end)


    -- startTimerAction(self, 0.7, false, function() 
    --     self.targetBoss:setBaseUrl("20079") 
    --     self.targetBoss:setPlistsNum(3)
    --     self.targetBoss:standed()
    --     self.targetBoss:attackOneTime(0.35, cc.p(0, 0))
    -- end)
end

function StoryNode:addBossSkillEffect(pos)
   
    if self.targetBoss then
        CMagicCtrlMgr:getInstance():CreateMagic(10015, 0, self.targetBoss:getTag(), 0, 0);
--[[
        local effect = Effects:create(false)
        effect:playActionData("10015/shifa", 5, 1, 1)
        self.targetBoss:addChild(effect, -1)
       -- effect:setPosition(getCenterPos(self.targetBoss, 0, 40))
        effect:setPosition(cc.p(0, -100))
        effect:setScale(2)
        --effect:setLocalZOrder(999)
        addEffectWithMode(effect, 3)

        startTimerAction(self, 1.2, false, function() removeFromParent(effect) end)
]]
        local t = math.random(1,2)
        if t == 1 then
            AudioEnginer.playEffect("sounds/storyVoice/70231_01.mp3", false)
        else
            AudioEnginer.playEffect("sounds/storyVoice/70231_02.mp3", false)
        end
        
    end

    -- local pos = G_MAINSCENE.map_layer:tile2Space(pos)
    -- pos = cc.p(pos.x, pos.y+self.targetBoss:getContentSize().height/2)
    -- local effect = Effects:create(false)
    -- effect:playActionData("skill6007", 5, 0.5, 1)
    -- G_MAINSCENE.map_layer:addChild(effect)
    -- effect:setPosition(pos)
    -- effect:setScale(2)

    -- startTimerAction(effect, 1.2, false, function() removeFromParent(effect) end)


    --G_MAINSCENE.map_layer:playSkillEffect(0.1, 6007, self.targetBoss, self.zhanshi, nil, nil)
end

function StoryNode:removeBossSkillEffect()
     if self.bossSkillAction then
        self:stopAction(self.bossSkillAction)
        self.bossSkillAction = nil
    end
end

function StoryNode:addBossLightningEffect()
    self.lightAction = startTimerAction(self, 0.2, true, function() 
        math.randomseed(os.clock()*10000)
        local x = math.random(0, display.width)
        local y = math.random(0, display.height)
        print("x = "..x.." y = "..y)
        local effect = Effects:create(false)
        effect:playActionData("storyBossLightning", 4, 0.7, 1)
        --effect:setScale(0.75)
        --self.explodeNode:addChild(effect)
        --dump(pos)
        G_MAINSCENE.map_layer:addChild(effect, 9000)
        local px, py = G_ROLE_MAIN:getPosition()
        effect:setPosition(cc.p(px + x - display.width/2, py + y - display.height/2))
        startTimerAction(self, 1.2, false, function() removeFromParent(effect) end)
        local tmp = math.random(1,20)
        if math.random(1,10) < 3 then
            startTimerAction(self, 0.7, false, function() 
                G_MAINSCENE.map_layer:showHurtNumer(math.random(1000,2000), cc.p(G_ROLE_MAIN:getPosition()), cc.p(G_ROLE_MAIN:getPosition()), 0.01, nil, false)
            end)
        end

        local t = math.random(1, 2)
        if t == 1 then
            AudioEnginer.playEffect("sounds/storyVoice/70231_01.mp3", false)
        else
            AudioEnginer.playEffect("sounds/storyVoice/70231_02.mp3", false)
        end       

     end)
end

function StoryNode:addEarthQuake()
    startTimerAction(self, 1, true, function() earthQuake(0.3, 1) end)
end

function StoryNode:addBuff()
    local function addBuffEffect(role, isOnRole)
        local pos = cc.p(role:getPosition())
        local effect = Effects:create(false)
        effect:playActionData("3006/hit", 7, 1, 1)
        addEffectWithMode(effect, 3)

        if isOnRole then
            role:addChild(effect)
            dump(pos)
            effect:setPosition(getCenterPos(role))
        else
            -- dump(pos)
            G_MAINSCENE.map_layer:addChild(effect)
            effect:setPosition(pos)
            effect:setLocalZOrder(role:getLocalZOrder()+1)
        end

        startTimerAction(self, 1.2, false, function() removeFromParent(effect) end)
    end

    addBuffEffect(self.zhanshi, true)
    addBuffEffect(self.fashi, true)
    addBuffEffect(self.daoshi, true)
    addBuffEffect(G_ROLE_MAIN, false)

    for i,v in ipairs(self.soldier) do
        addBuffEffect(v)
    end
end

function StoryNode:moveRole(role, time, pos)
    if role and time and pos then
        local paths = G_MAINSCENE.map_layer:moveMonsterByPos(pos, role, 2, false)
        G_MAINSCENE.map_layer:moveByPaths(paths, role, role:getTag(), time)
    end
end

function StoryNode:moveMonster(monster, time, pos)
    if monster and time and pos then
        local paths = G_MAINSCENE.map_layer:moveMonsterByPos(pos, monster, 2, false)
        G_MAINSCENE.map_layer:moveByPaths(paths, monster, monster:getTag(), time)
    end
end

function StoryNode:stopMoveMonster(monster)
    if monster then
        local objid = monster:getTag()
        if objid and G_MAINSCENE.map_layer.role_actions[objid] then
			G_MAINSCENE.map_layer.item_Node:stopAction(G_MAINSCENE.map_layer.role_actions[objid])
			G_MAINSCENE.map_layer.role_actions[objid] = nil
			G_MAINSCENE.map_layer.rock_status[objid] = nil
		end
    end
end

function StoryNode:addRole()
	if G_ROLE_MAIN == nil then
		return
	end

    --假人
    local params = {}
    params[ROLE_SCHOOL] = require("src/layers/role/RoleStruct"):getAttr(ROLE_SCHOOL)
    params[PLAYER_SEX] = require("src/layers/role/RoleStruct"):getAttr(PLAYER_SEX)
    params[ROLE_HP] = 999
    params[ROLE_LEVEL] = 999  
    params[ROLE_MAX_HP] = 999
    params[ROLE_NAME] = require("src/layers/role/RoleStruct"):getAttr(ROLE_NAME)
    params[PLAYER_EQUIP_WEAPON] = nil
    params[PLAYER_EQUIP_UPPERBODY] = nil
    if params[ROLE_SCHOOL] == 1 then
        if params[PLAYER_SEX] == 1 then
            params[PLAYER_EQUIP_WEAPON] = 5110108
            params[PLAYER_EQUIP_UPPERBODY] = 5110508
            params[PLAYER_EQUIP_WING] = 4031
        else
            params[PLAYER_EQUIP_WEAPON] = 5110108
            params[PLAYER_EQUIP_UPPERBODY] = 5111508
            params[PLAYER_EQUIP_WING] = 4031
        end
    elseif params[ROLE_SCHOOL] == 2 then
        if params[PLAYER_SEX] == 1 then
            params[PLAYER_EQUIP_WEAPON] = 5120108
            params[PLAYER_EQUIP_UPPERBODY] = 5120508
            params[PLAYER_EQUIP_WING] = 5031
        else
            params[PLAYER_EQUIP_WEAPON] = 5120108
            params[PLAYER_EQUIP_UPPERBODY] = 5121508
            params[PLAYER_EQUIP_WING] = 5031
        end
    elseif params[ROLE_SCHOOL] == 3 then
        if params[PLAYER_SEX] == 1 then
            params[PLAYER_EQUIP_WEAPON] = 5130108
            params[PLAYER_EQUIP_UPPERBODY] = 5130508
            params[PLAYER_EQUIP_WING] = 6031
        else
            params[PLAYER_EQUIP_WEAPON] = 5130108
            params[PLAYER_EQUIP_UPPERBODY] = 5131508
            params[PLAYER_EQUIP_WING] = 6031
        end
    end    
    local MpropOp = require "src/config/propOp"
    local w_resId = MpropOp.equipResId(params[PLAYER_EQUIP_UPPERBODY])
    if w_resId == 0 then w_resId = g_normal_close_id end
    local w_resId = G_ROLE_MAIN:getRightResID(PLAYER_EQUIP_UPPERBODY,w_resId+params[PLAYER_SEX]*100000)
    local roleEx = G_MAINSCENE.map_layer:makeMainRole(41, 82, "role/".. w_resId, 3, false, 800, params)
    if params[PLAYER_EQUIP_WEAPON] > 0 then
        local w_resId = MpropOp.equipResId(params[PLAYER_EQUIP_WEAPON])
        w_resId = G_ROLE_MAIN:getRightResID(PLAYER_EQUIP_WEAPON ,w_resId)
        local w_path = "weapon/" .. (w_resId)
        G_ROLE_MAIN:setEquipment_ex(roleEx,PLAYER_EQUIP_WEAPON,w_path)
    end
    if params[PLAYER_EQUIP_WING] > 0 then
        local w_resId = getConfigItemByKey("WingCfg","q_ID",params[PLAYER_EQUIP_WING] ,"q_senceSouceID")
        w_resId = G_ROLE_MAIN:getRightResID(PLAYER_EQUIP_WING,w_resId+100000)
        local w_path = "wing/" .. (w_resId)
        G_ROLE_MAIN:setEquipment_ex(roleEx,PLAYER_EQUIP_WING,w_path)
    end
    roleEx:initStandStatus(4, 6, 1, 1)
    roleEx:setSpriteDir(2)
    roleEx:standed()
    roleEx:setOpacity(255)    
    self.roleEx = roleEx
    local select_effect = Effects:create(false)
    select_effect:setPosition(cc.p(0,-20))
    select_effect:setAnchorPoint(cc.p(0.5,0.5))
    self.roleEx:addChild(select_effect,0)
    select_effect:playActionData("roleselect",7,2,-1)
    addEffectWithMode(select_effect,3)
    --设置主角颜色
    if roleEx.nameLabel ~= nil then
        roleEx.nameLabel:setColor(cc.c3b(225, 137, 67))
    end

    if G_ROLE_MAIN.nameLabel ~= nil then
        self.mainRoleColor = G_ROLE_MAIN.nameLabel:getColor()
        G_ROLE_MAIN.nameLabel:setColor(cc.c3b(225, 137, 67))
    end
    

	--战士
	local params = {}
	params[ROLE_SCHOOL] = 1
    params[PLAYER_SEX] = 1
    params[ROLE_HP] = 999
    params[ROLE_LEVEL] = 999  
    params[ROLE_MAX_HP] = 999
    params[ROLE_NAME] = "战神·孟虎"
    params[PLAYER_EQUIP_WEAPON] = 5110107
    params[PLAYER_EQUIP_UPPERBODY] = 5110507
    params[PLAYER_EQUIP_WING] = 4031	
    local MpropOp = require "src/config/propOp"
    local w_resId = MpropOp.equipResId(params[PLAYER_EQUIP_UPPERBODY])
    if w_resId == 0 then w_resId = g_normal_close_id end
    local w_resId = G_ROLE_MAIN:getRightResID(PLAYER_EQUIP_UPPERBODY,w_resId+params[PLAYER_SEX]*100000)
    local zhanshi = G_MAINSCENE.map_layer:makeMainRole(41, 80, "role/".. w_resId, 3, false, 801, params)
    if params[PLAYER_EQUIP_WEAPON] > 0 then
        local w_resId = MpropOp.equipResId(params[PLAYER_EQUIP_WEAPON])
        w_resId = G_ROLE_MAIN:getRightResID(PLAYER_EQUIP_WEAPON ,w_resId)
        local w_path = "weapon/" .. (w_resId)
        G_ROLE_MAIN:setEquipment_ex(zhanshi,PLAYER_EQUIP_WEAPON,w_path)
    end
    if params[PLAYER_EQUIP_WING] > 0 then
        local w_resId = getConfigItemByKey("WingCfg","q_ID",params[PLAYER_EQUIP_WING] ,"q_senceSouceID")
        w_resId = G_ROLE_MAIN:getRightResID(PLAYER_EQUIP_WING,w_resId+100000)
        local w_path = "wing/" .. (w_resId)
        G_ROLE_MAIN:setEquipment_ex(zhanshi,PLAYER_EQUIP_WING,w_path)
    end
    zhanshi:initStandStatus(4, 6, 1, 1)
    zhanshi:setSpriteDir(2)
    zhanshi:standed()   
    zhanshi:showNameAndBlood(false, 0)
    self.zhanshi = zhanshi

   --[[ 
     zhanshi:getNameBatchLabel():setVisible(true)
     if self.zhanshi.nameLabel ~= nil then
        if self.zhanshi.nameLabel.label ~= nil then
            self.zhanshi.nameLabel.label:setSystemFontSize(20)
        end
     end
    ]]

    --法师
	local params = {}
	params[ROLE_SCHOOL] = 2
    params[PLAYER_SEX] = 1
    params[ROLE_HP] = 999
    params[ROLE_LEVEL] = 999  
    params[ROLE_MAX_HP] = 999
    params[ROLE_NAME] = "法神·洪"
    params[PLAYER_EQUIP_WEAPON] = 5120107
    params[PLAYER_EQUIP_UPPERBODY] = 5120507
    params[PLAYER_EQUIP_WING] = 5031	
    local MpropOp = require "src/config/propOp"
    local w_resId = MpropOp.equipResId(params[PLAYER_EQUIP_UPPERBODY])
    if w_resId == 0 then w_resId = g_normal_close_id end
    local w_resId = G_ROLE_MAIN:getRightResID(PLAYER_EQUIP_UPPERBODY,w_resId+params[PLAYER_SEX]*100000)
    local fashi = G_MAINSCENE.map_layer:makeMainRole(39, 80, "role/".. w_resId, 3, false, 802, params)
    if params[PLAYER_EQUIP_WEAPON] > 0 then
        local w_resId = MpropOp.equipResId(params[PLAYER_EQUIP_WEAPON])
        w_resId = G_ROLE_MAIN:getRightResID(PLAYER_EQUIP_WEAPON ,w_resId)
        local w_path = "weapon/" .. (w_resId)
        G_ROLE_MAIN:setEquipment_ex(fashi,PLAYER_EQUIP_WEAPON,w_path)
    end
    if params[PLAYER_EQUIP_WING] > 0 then
        local w_resId = getConfigItemByKey("WingCfg","q_ID",params[PLAYER_EQUIP_WING] ,"q_senceSouceID")
        w_resId = G_ROLE_MAIN:getRightResID(PLAYER_EQUIP_WING,w_resId+100000)
        local w_path = "wing/" .. (w_resId)
        G_ROLE_MAIN:setEquipment_ex(fashi,PLAYER_EQUIP_WING,w_path)
    end
    fashi:initStandStatus(4, 6, 1, 1)
    fashi:setSpriteDir(2)
    fashi:standed()  
    self.fashi = fashi
    fashi:showNameAndBlood(false, 0)
  --[[  fashi:getNameBatchLabel():setVisible(true)
    if self.fashi.nameLabel ~= nil then
        if self.fashi.nameLabel.label ~= nil then
            self.fashi.nameLabel.label:setSystemFontSize(20)
        end
    end
    ]]

    --道士
	local params = {}
	params[ROLE_SCHOOL] = 3
    params[PLAYER_SEX] = 1
    params[ROLE_HP] = 999
    params[ROLE_LEVEL] = 999  
    params[ROLE_MAX_HP] = 999
    params[ROLE_NAME] = "道尊·百谷"
    params[PLAYER_EQUIP_WEAPON] = 5130107
    params[PLAYER_EQUIP_UPPERBODY] = 5130507
    params[PLAYER_EQUIP_WING] = 6031	
    local MpropOp = require "src/config/propOp"
    local w_resId = MpropOp.equipResId(params[PLAYER_EQUIP_UPPERBODY])
    if w_resId == 0 then w_resId = g_normal_close_id end
    local w_resId = G_ROLE_MAIN:getRightResID(PLAYER_EQUIP_UPPERBODY,w_resId+params[PLAYER_SEX]*100000)
    local daoshi = G_MAINSCENE.map_layer:makeMainRole(43, 80, "role/".. w_resId, 3, false, 803, params)
    if params[PLAYER_EQUIP_WEAPON] > 0 then
        local w_resId = MpropOp.equipResId(params[PLAYER_EQUIP_WEAPON])
        w_resId = G_ROLE_MAIN:getRightResID(PLAYER_EQUIP_WEAPON ,w_resId)
        local w_path = "weapon/" .. (w_resId)
        G_ROLE_MAIN:setEquipment_ex(daoshi,PLAYER_EQUIP_WEAPON,w_path)
    end
    if params[PLAYER_EQUIP_WING] > 0 then
        local w_resId = getConfigItemByKey("WingCfg","q_ID",params[PLAYER_EQUIP_WING] ,"q_senceSouceID")
        w_resId = G_ROLE_MAIN:getRightResID(PLAYER_EQUIP_WING,w_resId+100000)
        local w_path = "wing/" .. (w_resId)
        G_ROLE_MAIN:setEquipment_ex(daoshi,PLAYER_EQUIP_WING,w_path)
    end
    daoshi:initStandStatus(4, 6, 1, 1)
    daoshi:setSpriteDir(2)
    daoshi:standed()   
    daoshi:showNameAndBlood(false, 0)
    self.daoshi = daoshi
--[[
    daoshi:getNameBatchLabel():setVisible(true)
    if self.daoshi.nameLabel ~= nil then
        if self.daoshi.nameLabel.label ~= nil then
            self.daoshi.nameLabel.label:setSystemFontSize(20)
        end
    end
    ]]
end

function StoryNode:changeRoleDressEx(role)
end

function StoryNode:changeRoleDress(isOn)
    local MRoleStruct = require("src/layers/role/RoleStruct")
    local school = MRoleStruct:getAttr(ROLE_SCHOOL)
    local sex = MRoleStruct:getAttr(PLAYER_SEX)

    --解决未知异常，首次会获取到sex，下次无法获取
    if sex ~= nil then
        self.mainRoleSex = sex
    elseif sex == nil and self.mainRoleSex ~= nil then
        sex = self.mainRoleSex
    end

    local function dress(sex, dressId, weaponId, wingId)
        local MpropOp = require "src/config/propOp"
        -- local resId = G_ROLE_MAIN:getRightResID(PLAYER_EQUIP_UPPERBODY, dressId+sex*100000)
        -- G_ROLE_MAIN:setEquipment_ex(daoshi,PLAYER_EQUIP_UPPERBODY, w_path)
        if dressId > 0 then
            local w_resId = MpropOp.equipResId(dressId)
            w_resId = G_ROLE_MAIN:getRightResID(PLAYER_EQUIP_UPPERBODY ,w_resId+sex*100000)
            local w_path = "role/" .. (w_resId)
            G_ROLE_MAIN:setBaseUrl(w_path)
        end

        if weaponId > 0 then
            local w_resId = MpropOp.equipResId(weaponId)
            w_resId = G_ROLE_MAIN:getRightResID(PLAYER_EQUIP_WEAPON ,w_resId)
            local w_path = "weapon/" .. (w_resId)
            G_ROLE_MAIN:setEquipment_ex(G_ROLE_MAIN, PLAYER_EQUIP_WEAPON, w_path)
        end

        if wingId > 0 then
            local w_resId = getConfigItemByKey("WingCfg","q_ID",wingId ,"q_senceSouceID")
            w_resId = G_ROLE_MAIN:getRightResID(PLAYER_EQUIP_WING,w_resId+100000)
            local w_path = "wing/" .. (w_resId)
            G_ROLE_MAIN:setEquipment_ex(G_ROLE_MAIN,PLAYER_EQUIP_WING,w_path)
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
        G_ROLE_MAIN:removeActionChildByTag(PLAYER_EQUIP_WING)
    end    
end

function StoryNode:addMonster(order, isWithEffect)
	local tab = getConfigItemByKey("storyMonster", "q_id")
    --dump(tab)

    for k,v in pairs(tab) do
        if v.q_order == order then
            local entity = 
            {
                [ROLE_MODEL] = v.q_monster_model,
                --[ROLE_HP] = getConfigItemByKey("monster", "q_id", v.q_monster_model, "q_maxhp"),
                [ROLE_HP] = 500,
                [ROLE_LEVEL] = getConfigItemByKey("monster", "q_id", v.q_monster_model, "q_lvl"),
            }
            local feature = getConfigItemByKey("monster", "q_id", v.q_monster_model, "q_featureid")
            local monster = G_MAINSCENE.map_layer:addMonster(v.q_center_x, v.q_center_y, feature, nil, v.q_id, entity)
            if isWithEffect then
                local pos = G_MAINSCENE.map_layer:tile2Space(cc.p(v.q_center_x, v.q_center_y))
                local effect = Effects:create(false)
                effect:playActionData("storySummon", 11, 1, 1)
                G_MAINSCENE.map_layer:addChild(effect)
                effect:setPosition(pos)
                startTimerAction(self, 1.2, false, function() removeFromParent(effect) end)
            end

            if monster then
                monster:setNameColor(MColor.red)
                monster:setNameLabel("")
                monster:showNameAndBlood(false, 0)
                if self.monsterTab[order] == nil then
                    self.monsterTab[order] = {}
                end
                table.insert(self.monsterTab[order], monster)
                if  order == 6 or order == 7 or order == 9 then
                    local ai = require("src/layers/story/StoryAIMonster").new(self, monster)
                    monster.storyai = ai
                    table.insert(self.RolesAI, ai)
                end

                if order == 9 then
                    monster:setSpriteDir(6) 
                    monster:standed()         
                end
            end
        end
    end
end

function StoryNode:addSoldier()
    --self.soldier = {}
--[[
    local pos = {cc.p(41, 71),  cc.p(42, 72), cc.p(43, 73), cc.p(44, 74),
                cc.p(39, 73),  cc.p(40, 74), cc.p(41, 75), cc.p(42, 76),}
]]
    local pos = {cc.p(39, 82), cc.p(43, 82),
                 cc.p(38, 84), cc.p(40, 84), cc.p(42, 84), cc.p(44, 84), 
                 cc.p(36, 86), cc.p(38, 86), cc.p(40, 86),  cc.p(42, 86), cc.p(44, 86), cc.p(46, 86), }

    local add =  cc.p(0, 0)            
    for i,v in ipairs(pos) do
        local entity = 
        {
            [ROLE_MODEL] = 9005,
            [ROLE_HP] = 2000,
        }
           
        local soldier = G_MAINSCENE.map_layer:addMonster(v.x + add.x, v.y + add.y, 20036, nil, 1000+i, entity)
        soldier:setSpriteDir(2)
        soldier:standed()
        --startTimerAction(soldier, 1, true, function() soldier:standed() soldier:setSpriteDir(1) end)
        soldier:setNameLabel("")
        soldier:setNameColor(MColor.green)
        table.insert(self.soldier, soldier)
        local ai = require("src/layers/story/StoryAISoldier").new(self, soldier)
        soldier.storyai = ai
        table.insert(self.RolesAI, ai)

        soldier:showNameAndBlood(false, 0)
    end
end

function StoryNode:moveSoldier(time, addPos)
    for i,v in ipairs(self.soldier) do
        if self.baobao ~= nil and v == self.baobao then
        else        
            v:setSpriteDir(1)
            local pos = G_MAINSCENE.map_layer:space2Tile(cc.p(v:getPosition()))
            dump(pos)
            self:moveMonster(v, time, cc.p(pos.x+addPos.x, pos.y+addPos.y))
        end
    end
end

function StoryNode:moveSoldierEx(time)
    local pos = {cc.p(64, 55),  cc.p(65, 56), cc.p(66, 57), cc.p(67, 58),
                 cc.p(62, 57),  cc.p(63, 58), cc.p(64, 59), cc.p(65, 60),
                 cc.p(60, 59),  cc.p(61, 60), cc.p(62, 61), cc.p(63, 62),}

    for i=1, 12 do
        self.soldier[i]:setSpriteDir(1)
        self:moveMonster(self.soldier[i], time, pos[i])
    end
end

function StoryNode:addAutoFight()
    math.randomseed(os.clock()*10000)
    
    local dirPos = 
    {
        {0, cc.p(1, 0)},
        {1, cc.p(1, -2)},
        {2, cc.p(0, -2)},
        {3, cc.p(-1, -2)},
        {4, cc.p(-1, 0)},
        {5, cc.p(-1, 2)},
        {6, cc.p(0, 2)},
        {7, cc.p(1, 2)},
    }

    local order = 0
    local tab = getConfigItemByKey("storyMonster", "q_id")
    --dump(tab)

    local function createSoldier(monster, id)
        local monsterDir = monster:getCurrectDir()
        local soliderDir
        if monsterDir < 4 then
            soliderDir = monsterDir + 4
        else
            soliderDir = monsterDir - 4
        end

        local monsterPos = G_MAINSCENE.map_layer:space2Tile(cc.p(monster:getPosition()))
        local posAdd
        for i,v in ipairs(dirPos) do
            if monsterDir == v[1] then
                posAdd = v[2]
                break
            end
        end
        local soldierPos = cc.p(monsterPos.x+posAdd.x, monsterPos.y+posAdd.y)

        local entity = 
        {
            [ROLE_MODEL] = 9005,
            [ROLE_HP] = 2000,
        }
        -- local feature = getConfigItemByKey("monster", "q_id", 10008, "q_featureid")
        -- dump(soldierPos)
        -- dump(id)
        local soldier = G_MAINSCENE.map_layer:addMonster(soldierPos.x, soldierPos.y, 20036, nil, id, entity)
        --dump(soldier)
        if soldier then
            soldier:setNameLabel(game.getStrByKey("story_soldier"))
            soldier:setSpriteDir(soliderDir)
            soldier:standed()
            soldier:setNameColor(MColor.green)

            local delay = math.random(0, 3) 
            startTimerAction(self, delay, false, function() 
                startTimerAction(self, 1.2, true, function() 
                            if self:checkForSave(soldier) then
                                soldier:attackOneTime(0.5, cc.p(0, 0))
                            end
                        end)
            end)
        end
    end

    for k,v in pairs(tab) do
        if v.q_order == order then
            local entity = 
            {
                [ROLE_MODEL] = v.q_monster_model,
                [ROLE_HP] = 2000,
            }
            local feature = getConfigItemByKey("monster", "q_id", v.q_monster_model, "q_featureid")
            local monster = G_MAINSCENE.map_layer:addMonster(v.q_center_x, v.q_center_y, feature, nil, v.q_id, entity)

            if self.monsterTab[order] == nil then
                self.monsterTab[order] = {}
            end
            table.insert(self.monsterTab[order], monster)
            --local ai = require("src/layers/story/StoryAIMonster").new(self, monster)
            --monster.storyai = ai
            --table.insert(self.RolesAI, ai)

            createSoldier(monster, v.q_id+10000)
            
            local delay = math.random(0, 3) 
            startTimerAction(self, delay, false, function() 
                startTimerAction(self, 1.2, true, function() 
                    -- 有可能为空，校验
                    if monster then
                        monster:attackOneTime(0.5, cc.p(0, 0))
                    end
                end)
            end)
        end
    end
end

function StoryNode:addAutoFightEx()
    self:moveMonster(self.monsterTab[6][1], 0.4, cc.p(100, 32))
    self:moveMonster(self.monsterTab[6][2], 0.4, cc.p(101, 33))
    self:moveMonster(self.monsterTab[6][3], 0.4, cc.p(102, 34)) 
    self:moveMonster(self.monsterTab[6][4], 0.4, cc.p(103, 35))
    self:moveMonster(self.monsterTab[6][5], 0.4, cc.p(104, 36))

    startTimerAction(self, 4.3, false, function() self.monsterTab[6][1].storyai:fight() end)  
    startTimerAction(self, 4.2, false, function() self.monsterTab[6][2].storyai:fight() end)
    startTimerAction(self, 4.1, false, function() self.monsterTab[6][3].storyai:fight() end)
    startTimerAction(self, 4.5, false, function() self.monsterTab[6][4].storyai:fight() end)
    startTimerAction(self, 4, false, function() self.monsterTab[6][5].storyai:fight() end)

    self:moveMonster(self.monsterTab[7][1], 0.4, cc.p(91, 24))
    self:moveMonster(self.monsterTab[7][2], 0.4, cc.p(90, 25))
    self:moveMonster(self.monsterTab[7][3], 0.4, cc.p(89, 26)) 
    self:moveMonster(self.monsterTab[7][4], 0.4, cc.p(88, 27))
    self:moveMonster(self.monsterTab[7][5], 0.4, cc.p(87, 28))

    startTimerAction(self, 4.2, false, function() self.monsterTab[7][1].storyai:fight() end)  
    startTimerAction(self, 4.3, false, function() self.monsterTab[7][2].storyai:fight() end)
    startTimerAction(self, 4.4, false, function() self.monsterTab[7][3].storyai:fight() end)
    startTimerAction(self, 4.5, false, function() self.monsterTab[7][4].storyai:fight() end)
    startTimerAction(self, 4, false, function() self.monsterTab[7][5].storyai:fight() end)

    self:moveMonster(self.soldier[1], 0.4, cc.p(99, 33))
    self:moveMonster(self.soldier[2], 0.4, cc.p(100, 34))
    self:moveMonster(self.soldier[3], 0.4, cc.p(101, 34))
    self:moveMonster(self.soldier[4], 0.4, cc.p(102, 33))
    self:moveMonster(self.soldier[5], 0.4, cc.p(100, 35))
    self:moveMonster(self.soldier[6], 0.4, cc.p(100, 36))
    self:moveMonster(self.soldier[7], 0.4, cc.p(91, 25))
    self:moveMonster(self.soldier[8], 0.4, cc.p(90, 26))
    self:moveMonster(self.soldier[9], 0.4, cc.p(89, 27))
    self:moveMonster(self.soldier[10], 0.4, cc.p(88, 28))
    self:moveMonster(self.soldier[11], 0.4, cc.p(89, 28))
    self:moveMonster(self.soldier[12], 0.4, cc.p(88, 29))

    startTimerAction(self, 3.55, false, function() self.soldier[1].storyai:fight() end)
    startTimerAction(self, 3.55, false, function() self.soldier[2].storyai:fight() end)
    startTimerAction(self, 3.5, false, function() self.soldier[3].storyai:fight() end)
    startTimerAction(self, 3.45, false, function() self.soldier[4].storyai:fight() end)
    startTimerAction(self, 3.7, false, function() self.soldier[5].storyai:fight() end)    
    startTimerAction(self, 3.5, false, function() self.soldier[6].storyai:fight() end)
    startTimerAction(self, 3.3, false, function() self.soldier[7].storyai:fight() end)
    startTimerAction(self, 3.0, false, function() self.soldier[8].storyai:fight() end)   
    startTimerAction(self, 3.05, false, function() self.soldier[9].storyai:fight() end)
    startTimerAction(self, 3.05, false, function() self.soldier[10].storyai:fight() end)
    startTimerAction(self, 3.05, false, function() self.soldier[11].storyai:fight() end)
    startTimerAction(self, 3.05, false, function() self.soldier[12].storyai:fight() end)
end

function StoryNode:removeMonster(order)
    local deathDir = 5
    for k,v in pairs(self.monsterTab[order]) do
        if deathDir == 5 then
            deathDir = 7
        else
            deathDir = 5
        end
        v:setHP(0)
        v:gotoDeath(deathDir)
    end
end

function StoryNode:addTalk(id, delay, delayDestory, text)
	if self.talkNode then
        removeFromParent(self.talkNode)
        self.talkNode = nil
    end

    local record = getConfigItemByKey("storyTalk", "q_id", id)
    dump(record)

    self.talkNode = cc.Node:create()
    self:addChild(self.talkNode)

    local function createTalk(delayDestory)
        dump(delayDestory)
        local bg = createSprite(self.talkNode, path.."bg.png", cc.p(display.cx, 0), cc.p(0.5, 0))
        bg:setOpacity(0)
        bg:runAction(cc.Sequence:create(cc.FadeIn:create(0.2)))
        if record.q_role == 14 then
            createSprite(bg, "res/mainui/npc_big_head/"..record.q_role..".png", cc.p(bg:getContentSize().width/2-display.width/2, bg:getContentSize().height), cc.p(0, 0))
        elseif record.q_role == 0 then
            local sex = require("src/layers/role/RoleStruct"):getAttr(PLAYER_SEX)
            local school = require("src/layers/role/RoleStruct"):getAttr(ROLE_SCHOOL)
            createSprite(bg, "res/mainui/npc_big_head/"..(sex-1)*3+school..".png", cc.p(bg:getContentSize().width/2+display.width/2+15, bg:getContentSize().height), cc.p(1, 0))
        else
            createSprite(bg, "res/mainui/npc_big_head/"..record.q_role..".png", cc.p(bg:getContentSize().width/2+display.width/2+15, bg:getContentSize().height), cc.p(1, 0))
        end

        local richText = require("src/RichText").new(bg, cc.p(bg:getContentSize().width/2-(display.width-200)/2, 140), cc.size(display.width-200, 30), cc.p(0, 1), 30, 24, MColor.lable_yellow)
        if text then
            richText:addText(text)
        else
            richText:addText(record.q_text)
        end
        richText:format()

        if not delayDestory then
            createLabel(bg, game.getStrByKey("story_talk_tip"), cc.p(bg:getContentSize().width/2+display.width/2-120, 30), cc.p(1, 0.5), 22, true, nil, nil, MColor.white)
            local arrow = createSprite(bg, "res/group/arrows/13.png", cc.p(bg:getContentSize().width/2+display.width/2-110, 30), cc.p(0, 0.5), nil, 0.6)
            arrow:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveTo:create(0.3, cc.p(bg:getContentSize().width/2+display.width/2-100, 30)), cc.MoveTo:create(0.3, cc.p(bg:getContentSize().width/2+display.width/2-110, 30)))))

            local  listenner = cc.EventListenerTouchOneByOne:create()
            listenner:setSwallowTouches(false)
            listenner:registerScriptHandler(function(touch, event)
                    return true
                end,cc.Handler.EVENT_TOUCH_BEGAN )
            listenner:registerScriptHandler(function(touch, event)
                    print("StoryNode:addTalk touch end")
                    if self.talkNode then
                        removeFromParent(self.talkNode)
                        self.talkNode = nil
                    end
                    self:updateState()
                end,cc.Handler.EVENT_TOUCH_ENDED )
            local eventDispatcher = self:getEventDispatcher()
            eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, self.talkNode)
        else
            startTimerAction(self, delayDestory, false, function() 
                    if self.talkNode then
                        removeFromParent(self.talkNode)
                        self.talkNode = nil
                    end
                end)

            local  listenner = cc.EventListenerTouchOneByOne:create()
            listenner:setSwallowTouches(false)
            listenner:registerScriptHandler(function(touch, event) return true end,cc.Handler.EVENT_TOUCH_BEGAN )
            listenner:registerScriptHandler(function(touch, event)
                    if self.talkNode then
                        removeFromParent(self.talkNode)
                        self.talkNode = nil
                    end
                end,cc.Handler.EVENT_TOUCH_ENDED )
            local eventDispatcher = self:getEventDispatcher()
            eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, self.talkNode)
        end

        
    end

    startTimerAction(self, delay or 0, false, function() createTalk(delayDestory) end)
end

function StoryNode:addBlack(strTab, isAutoUpdate, isWithEffect, index)
    if self.blackNode then
        removeFromParent(self.blackNode)
        self.blackNode = nil
    end 

    self.blackNode = cc.Node:create()
    self:addChild(self.blackNode, 100)

    local masking = cc.LayerColor:create(cc.c4b(0, 0, 0, 255))
    self.blackNode:addChild(masking, 0, 123)    

    local nodeGrid = cc.NodeGrid:create()
    self.blackNode:addChild(nodeGrid, 0, 124)

    --nodeGrid:runAction(cc.Liquid:create(8,cc.size(4,4),10,3))
    --nodeGrid:runAction(cc.Waves3D:create(5, cc.size(25, 20), 6, 30))
    --nodeGrid:runAction(cc.Ripple3D:create(10, cc.size(30, 30), getCenterPos(masking), 240, 4, 160))

    local paddingTime = 1
    local delayTime = 1
    local fadeInTime = 1
    local fadeOutTime = 1
    local fontSize = 26
    local lineHeight = 40
    local lineCount = #strTab
    local labelsT = {}
    for i,v in ipairs(strTab) do
        local label = require("src/RichText").new(nodeGrid, cc.p(display.cx-200, display.cy-(i-lineCount/2)*lineHeight + 20), cc.size(2000, 40), cc.p(0, 0.5), lineHeight, fontSize, cc.c3b(250, 250, 250))
        label:addText(v)
        label:format()
        label:setColor(cc.c3b(0, 0, 0))
        label:setOpacity(1)
        label:setCascadeColorEnabled(true)
        if  label.baseNode ~= nil then
            label.baseNode:setCascadeColorEnabled(true)
        end

        if  label.baseLableNode ~= nil then
            label.baseLableNode:setCascadeColorEnabled(true)
        end

        table.insert(labelsT, label)
        
        label:runAction(cc.Sequence:create(cc.DelayTime:create((i-1)*paddingTime), 
            cc.TintTo:create(fadeInTime, 255, 255, 255), 
            cc.DelayTime:create(delayTime+(lineCount-i-1)*paddingTime+delayTime), 
            cc.CallFunc:create(function()
                    if i == lineCount then
                        if isWithEffect then
                            -- nodeGrid:runAction(cc.Liquid:create(8,cc.size(4,4),10,3))
                            nodeGrid:runAction(cc.Ripple3D:create(10, cc.size(30, 30), getCenterPos(masking), 240, 6, 160))
                            -- nodeGrid:runAction(cc.Waves3D:create(5, cc.size(25, 20), 6, 30))
                            -- nodeGrid:runAction(cc.Ripple3D:create(10, cc.size(32,24), getCenterPos(masking, -80, 10), 240, 6, 160))
                        end
                    end
                end),
            cc.DelayTime:create(delayTime),
            cc.TintTo:create(fadeOutTime, 0, 0, 0),
            cc.CallFunc:create(function() 
                    if i == lineCount then
                        if isAutoUpdate then
                            if self.bAutoUpdate ~= true then
                                self.bAutoUpdate = true
                                startTimerAction(self, 1.0, false, function() self:updateState() end)
                            end
                        end
                    end
                end)))
    end


    local listenner = cc.EventListenerTouchOneByOne:create()
	listenner:setSwallowTouches(true)
    listenner:registerScriptHandler(function(touch, event)
            return true
        end,cc.Handler.EVENT_TOUCH_BEGAN )
    listenner:registerScriptHandler(function(touch, event)
                   
        if index == 1 then
            if self.bInitedAfter ~= true then
                self.bInitedAfter = true 

                --显示所有table                
                for i=1, #labelsT do
                    labelsT[i]:stopAllActions()
                    labelsT[i]:setOpacity(255)
                    labelsT[i]:setColor(cc.c3b(255, 255, 255))
                end
                             
                startTimerAction(self, 0.1, false, function() self:updateState() end)
            end
        else
            if self.bAutoUpdate ~= true then
                -- 显示所有table
                nodeGrid:stopAllActions()
                for i = 1, #labelsT do
                    labelsT[i]:stopAllActions()
                    labelsT[i]:setOpacity(255)
                    labelsT[i]:setColor(cc.c3b(255, 255, 255))
                end

                self.bAutoUpdate = true
                startTimerAction(self, 1.0, false, function() self:updateState() end)
            end
        end  

        end,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, self.blackNode)
end

--[[
function StoryNode:addBlack(strTab, isAutoUpdate, isWithEffect, index)
    if self.blackNode then
        removeFromParent(self.blackNode)
        self.blackNode = nil
    end 

    self.blackNode = cc.Node:create()
    self:addChild(self.blackNode, 100)

    local masking = cc.LayerColor:create(cc.c4b(0, 0, 0, 255))
    self.blackNode:addChild(masking, 0, 123)    

    local nodeGrid = cc.Node:create()
    self.blackNode:addChild(nodeGrid, 0, 124)

    local paddingTime = 1
    local delayTime = 1
    local fadeInTime = 1
    local fadeOutTime = 1
    local fontSize = 26
    local lineHeight = 40
    local lineCount = #strTab
    local labelsT = {}
    for i,v in ipairs(strTab) do
        local label = require("src/RichText").new(nodeGrid, cc.p(display.cx-200, display.cy-(i-lineCount/2)*lineHeight + 20), cc.size(2000, 40), cc.p(0, 0.5), lineHeight, fontSize, cc.c3b(250, 250, 250))
        label:addText(v)
        label:format()
        label:setColor(cc.c3b(0, 0, 0))
        label:setOpacity(1)
        label:setCascadeColorEnabled(true)
        if  label.baseNode ~= nil then
            label.baseNode:setCascadeColorEnabled(true)
        end

        if  label.baseLableNode ~= nil then
            label.baseLableNode:setCascadeColorEnabled(true)
        end

        table.insert(labelsT, label)
        
        label:runAction(cc.Sequence:create(cc.DelayTime:create((i-1)*paddingTime), 
            cc.TintTo:create(fadeInTime, 255, 255, 255), 
            cc.DelayTime:create(delayTime+(lineCount-i-1)*paddingTime+delayTime), 
            cc.DelayTime:create(delayTime),
            cc.TintTo:create(fadeOutTime, 0, 0, 0),
            cc.CallFunc:create(function() 
                    if i == lineCount then
                        if isAutoUpdate then
                            if self.bAutoUpdate ~= true then
                                self.bAutoUpdate = true
                                startTimerAction(self, 1.0, false, function() self:updateState() end)
                            end
                        end
                    end
                end)))
    end


    local listenner = cc.EventListenerTouchOneByOne:create()
	listenner:setSwallowTouches(true)
    listenner:registerScriptHandler(function(touch, event)
            return true
        end,cc.Handler.EVENT_TOUCH_BEGAN )
    listenner:registerScriptHandler(function(touch, event)
                   
        if index == 1 then
            if self.bInitedAfter ~= true then
                self.bInitedAfter = true 

                --显示所有table                
                for i=1, #labelsT do
                    labelsT[i]:stopAllActions()
                    labelsT[i]:setOpacity(255)
                    labelsT[i]:setColor(cc.c3b(255, 255, 255))
                end
                             
                startTimerAction(self, 0.1, false, function() self:updateState() end)
            end
        else
            if self.bAutoUpdate ~= true then
                -- 显示所有table
                --nodeGrid:stopAllActions()
                for i = 1, #labelsT do
                    labelsT[i]:stopAllActions()
                    labelsT[i]:setOpacity(255)
                    labelsT[i]:setColor(cc.c3b(255, 255, 255))
                end

                self.bAutoUpdate = true
                startTimerAction(self, 1.0, false, function() self:updateState() end)
            end
        end  

        end,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, self.blackNode)
end
]]
function StoryNode:addWhite(isRemove)
    if self.whiteNode then
        removeFromParent(self.whiteNode)
        self.whiteNode = nil
    end

    self.whiteNode = cc.Node:create()
    self:addChild(self.whiteNode)

    local masking = cc.LayerColor:create(cc.c4b(255, 255, 255, 0))
    self.whiteNode:addChild(masking)

    local effect = Effects:create(false)
    effect:playActionData("storyThunder", 15, 3, 1)
    effect:setScale(2)
    self.explodeNode:addChild(effect)
    addEffectWithMode(effect,3)
    --dump(pos)
    effect:setPosition(cc.p(display.cx, display.cy))
    startTimerAction(self, 3.2, false, function() removeFromParent(effect) end)

    masking:runAction(cc.Sequence:create(cc.FadeIn:create(2), cc.DelayTime:create(1), cc.TintTo:create(1, 0, 0, 0),
        cc.CallFunc:create(function() 
            self:updateState() 
            if self.whiteNode then
                if isRemove then
                    removeFromParent(self.whiteNode)
                    self.whiteNode = nil
                end
            end
            end)))
end

function StoryNode:addExplode()
    startTimerAction(self, 0.2, true, function() 
        math.randomseed(os.clock()*10000)
        local x = math.random(0, display.width)
        local y = math.random(0, display.height)
        print("x = "..x.." y = "..y)
        local effect = Effects:create(false)
        effect:playActionData("storyExplode", 12, 1, 1)
        effect:setScale(0.75)
        self.explodeNode:addChild(effect)
        --dump(pos)
        effect:setPosition(cc.p(x, y))
        startTimerAction(self, 1.2, false, function() removeFromParent(effect) end)
     end)
end

function StoryNode:addSkill(isWithTip)
    local MRoleStruct = require("src/layers/role/RoleStruct")
    local school = MRoleStruct:getAttr(ROLE_SCHOOL)

    local skillTab = {}
    if school == 1 then
        table.insert(skillTab, {1000,1,1,0})
        table.insert(skillTab, {1102,1,2,0})
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

    G_ROLE_MAIN:setSkills(skillTab)
    G_MAINSCENE:reloadSkillConfig(true)

    --skill_node切换父节点
    G_MAINSCENE.skill_node:retain()
    G_MAINSCENE.skill_node:removeFromParent()
    G_MAINSCENE:addChild(G_MAINSCENE.skill_node,1)
    G_MAINSCENE.skill_node:release()

    --G_MAINSCENE.skill_node:setVisible(true)
    --G_MAINSCENE.skill_node:setLocalZOrder(9999)
    --G_MAINSCENE.operate_node:setLocalZOrder(9999)

--[[    local function addEffect(btn)
        if btn then
            local effect = Effects:create(false)
            -- effect:setCleanCache()
            effect:playActionData("newFunctionExSmall", 19, 2, -1)
            btn:addChild(effect)
            effect:setAnchorPoint(cc.p(0.5, 0.5))
            effect:setPosition(getCenterPos(btn))
            -- effect:setScale(1)
            effect:setTag(123)
        end
    end
    local center_node = G_MAINSCENE.skill_node:getCenterNode()
    addEffect(center_node:getChildByTag(2))
    addEffect(center_node:getChildByTag(3))

    if isWithTip then
        local node = center_node:getChildByTag(3)
        local nodePos = node:convertToWorldSpace(getCenterPos(node))
        -- tutoAddTipEx(self.targetBoss, game.getStrByKey("story_skill_tip"), nil, nil, 399, 50)

        local arrow = createSprite(self, "res/group/arrows/16.png", cc.p(nodePos.x, nodePos.y+50), cc.p(0.5, 0))
        local richTextBg = createScale9Sprite(arrow, "res/common/scalable/bg2.png", cc.p(arrow:getContentSize().width/2, arrow:getContentSize().height), cc.size(220, 100), cc.p(0.5, 0))--createSprite(arrow, "res/tuto/images/smallBg.png", cc.p(arrow:getContentSize().width/2, arrow:getContentSize().height), cc.p(0.5, 0))--createScale9Sprite(arrow, "res/common/scalable/bg2.png", cc.p(arrow:getContentSize().width/2, arrow:getContentSize().height), cc.size(220, 100), cc.p(0.5, 0))
        local richText = require("src/RichText").new(richTextBg, cc.p(richTextBg:getContentSize().width/2, richTextBg:getContentSize().height/2), cc.size(richTextBg:getContentSize().width-30, richTextBg:getContentSize().height-30), cc.p(0.5, 0.5), 30, 24, MColor.white)
        richText:addText(game.getStrByKey("story_skill_tip"))
        richText:format()
        local action = cc.Sequence:create(cc.CallFunc:create(function() richTextBg:setOpacity(0) end), cc.FadeIn:create(1))
        richTextBg:runAction(action)
        richTextBg:runAction(cc.Sequence:create(cc.DelayTime:create(8), cc.CallFunc:create(function() 
                if arrow then
                    removeFromParent(arrow)
                    arrow = nil
                end

                if richTextBg then
                    removeFromParent(richTextBg)
                    richTextBg = nil
                end
            end)))
        
        local listenner = cc.EventListenerTouchOneByOne:create()
        listenner:registerScriptHandler(function(touch, event) 
            return true 
        end, cc.Handler.EVENT_TOUCH_BEGAN)
        listenner:registerScriptHandler(function(touch, event)
                location = node:getParent():convertTouchToNodeSpace(touch)
                log("location.x =".. location.x)
                log("location.y =".. location.y)
                if cc.rectContainsPoint(node:getBoundingBox(), cc.p(location.x, location.y))then
                    if arrow then
                        removeFromParent(arrow)
                        arrow = nil
                    end

                    if richTextBg then
                        removeFromParent(richTextBg)
                        richTextBg = nil
                    end
                end
            end,cc.Handler.EVENT_TOUCH_ENDED)
        local eventDispatcher = node:getEventDispatcher()
        eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, node)
    end
    ]]
end

function StoryNode:removeSkill()
    local MRoleStruct = require("src/layers/role/RoleStruct")
    local school = MRoleStruct:getAttr(ROLE_SCHOOL)

    local skillTab = {}
    if school == 1 then
        table.insert(skillTab, {1000,1,1,0})
        G_ROLE_MAIN.open_cs = nil
        G_ROLE_MAIN.open_by = nil
    elseif school == 2 then
        table.insert(skillTab, {2001,1,1,0})
    elseif school == 3 then
        table.insert(skillTab, {1001,1,1,0})
    end

    G_ROLE_MAIN:setSkills(skillTab)
    G_MAINSCENE:reloadSkillConfig()

    local function removeEffect(btn)
        if btn then
           btn:removeChildByTag(123)
        end
    end
    local center_node = G_MAINSCENE.skill_node:getCenterNode()
    removeEffect(center_node:getChildByTag(2))
    removeEffect(center_node:getChildByTag(3))
    removeEffect(center_node:getChildByTag(4))
    removeEffect(center_node:getChildByTag(5))

    local skillItem = G_MAINSCENE.skill_node:getCenterItem() 
    removeEffect(skillItem) 

    --换回父节点
    G_MAINSCENE.skill_node:retain()
    G_MAINSCENE.skill_node:removeFromParent()
    G_MAINSCENE.mainui_node:addChild(G_MAINSCENE.skill_node)
    G_MAINSCENE.skill_node:release()

    G_MAINSCENE.skill_node:setLocalZOrder(1)
    G_MAINSCENE.operate_node:setLocalZOrder(6)
end

function StoryNode:showSkill()
    G_MAINSCENE.skill_node:setLocalZOrder(9999)
    G_MAINSCENE.operate_node:setLocalZOrder(9999)
end

function StoryNode:hideSkill()
    G_MAINSCENE.skill_node:setLocalZOrder(1)
    G_MAINSCENE.operate_node:setLocalZOrder(6)
end

function StoryNode:addAudioEffect()
    self.musicVolume = AudioEnginer.getMusicVolume()
    self.effectVolume = AudioEnginer.getEffectsVolume()

    self.audioEffectAction = startTimerAction(self, 0.3, true, function() 
        local musicVolume = AudioEnginer.getMusicVolume()
        local effectVolume = AudioEnginer.getEffectsVolume()
        log("1 musicVolume = "..musicVolume)
        log("1 effectVolume = "..effectVolume)
        if musicVolume > 0 then
            musicVolume = musicVolume - 0.1
        end
        if effectVolume > 0 then
            effectVolume = effectVolume - 0.1
        end
        log("2 musicVolume = "..musicVolume)
        log("2 effectVolume = "..effectVolume)
        AudioEnginer.setMusicVolume(musicVolume)
        AudioEnginer.setEffectsVolume(effectVolume)
     end)
end

function StoryNode:removeAudioEffect()
    if self.audioEffectAction then
        self:stopAction(self.audioEffectAction)
        self.audioEffectAction = nil
    end

    if self.musicVolume then
        AudioEnginer.setMusicVolume(self.musicVolume)
    end

    if self.effectVolume then
        AudioEnginer.setEffectsVolume(self.effectVolume)
    end
end

function StoryNode:checkForSave(monster)
    return tolua.cast(monster, "MonsterSprite")
end

--所有角色ai暂停
function StoryNode:AIIdle()
    for k,v in pairs(self.RolesAI) do
        v:idle()
    end
end

--所有角色AI进入战斗状态
function StoryNode:AIFight()
    for k,v in pairs(self.RolesAI) do
        v:fight()
    end
end

function StoryNode:setBlock(idx)
    if idx == 1 then
        -- 开启阻挡
        --G_MAINSCENE.map_layer:setBlock(1, 28, 30, 25, 31);
        --G_MAINSCENE.map_layer:setBlock(2, 52, 30, 13, 36);
        --G_MAINSCENE.map_layer:setBlock(3, 64, 19, 27, 70);
        G_MAINSCENE.map_layer:setBlockRectValue(cc.rect(36,58,8,1), "1")
        G_MAINSCENE.map_layer:setBlockRectValue(cc.rect(48,63,1,10), "1")
        G_MAINSCENE.map_layer:setBlockRectValue(cc.rect(52,79,1,5), "1")
    elseif idx == 2 then
        --G_MAINSCENE.map_layer:setBlock(1, 67, 36, 36, 30);
        G_MAINSCENE.map_layer:setBlockRectValue(cc.rect(82,35,10,4), "1")
    elseif idx == 3 then
        G_MAINSCENE.map_layer:setBlockRectValue(cc.rect(76,41,1,4), "1")
        G_MAINSCENE.map_layer:setBlockRectValue(cc.rect(77,44,12,1), "1")
    end
end

function StoryNode:clearBlock(idx)
    if idx == 1 then
        --G_MAINSCENE.map_layer:clearBlock(1);
        --G_MAINSCENE.map_layer:clearBlock(2);
        --G_MAINSCENE.map_layer:clearBlock(3);
        G_MAINSCENE.map_layer:setBlockRectValue(cc.rect(36,58,8,1), "0")
        G_MAINSCENE.map_layer:setBlockRectValue(cc.rect(48,63,1,10), "0")
        G_MAINSCENE.map_layer:setBlockRectValue(cc.rect(52,79,1,5), "0")
    elseif idx == 2 then
        --G_MAINSCENE.map_layer:clearBlock(1);
        G_MAINSCENE.map_layer:setBlockRectValue(cc.rect(82,35,10,4), "0")
    elseif idx == 3 then
        G_MAINSCENE.map_layer:setBlockRectValue(cc.rect(76,41,1,4), "0")
        G_MAINSCENE.map_layer:setBlockRectValue(cc.rect(77,44,12,1), "0")
    end
end

function StoryNode:enterManualFight()
    self.m_manualFight = true
    --显示罗盘和技能操作界面 
    self:showSkill()  
end

function StoryNode:exitManualFight()
    self.m_manualFight = false
    --隐藏罗盘和技能操作界面    
    self:hideSkill()
end

--释放技能函数
function StoryNode:onSkillSend(skillId,targets,targetPos)
    if self.isEnd == true or G_MAINSCENE == nil then
        return
    end
   
    local center_node = G_MAINSCENE.skill_node:getCenterNode()
    local function removeEffect(btn)
        if btn then
           btn:removeChildByTag(123)
        end
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
        removeEffect(center_node:getChildByTag(5))

        local topNode = G_ROLE_MAIN:getTopNode()
        if topNode ~= nil and not topNode:getChildByTag(80) then
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
            for k, v in pairs(self.monsterTab) do
                for m, n in pairs(v) do
                    if n ~= nil and n:isVisible() and n:getHP() > 0 then
                        local nPos = G_MAINSCENE.map_layer:space2Tile(cc.p(n:getPosition()))
                        local dis =(targetPos.x - nPos.x) *(targetPos.x - nPos.x) +(targetPos.y - nPos.y) *(targetPos.y - nPos.y)
                        if dis < 25 then
                            table.insert(targets,n)
                        end
                    end
                end
            end
        end
        
       -- G_MAINSCENE.skill_node:removeChildByTag(525) 
       -- center_node:removeChildByTag(525) 
       -- G_ROLE_MAIN.base_data.spe_skill = {}
        removeEffect(center_node:getChildByTag(3))
        startTimerAction(self, 1.0, false, function() self:showHurt(skillId,targets) end)
        startTimerAction(self, 4.0, false, function() self:showHurt(skillId,targets) end)
        startTimerAction(self, 7.0, false, function() self:showHurt(skillId,targets) end)
        startTimerAction(self, 10.0, false, function() self:showHurt(skillId,targets) end)  
        startTimerAction(self, 13.0, false, function() self:showHurt(skillId,targets) end)     
        return  
    elseif skillId == 2010 then   --狂龙紫电
        removeEffect(center_node:getChildByTag(2))
        startTimerAction(self, 1.2, false, function() self:showHurt(skillId,targets) end)
        return
    elseif skillId == 2005 then   --抗拒火环 
        removeEffect(center_node:getChildByTag(4))
        if #targets > 0 then
            AudioEnginer.playEffect("sounds/skillMusic/70841.mp3",false)
        end
        return
    elseif skillId == 1006 then   --烈火剑法
        removeEffect(center_node:getChildByTag(4))
        startTimerAction(self, 0.5, false, function() self:showHurt(skillId,targets) end)
        return
    elseif skillId == 1004 then   --抱月刀
        removeEffect(center_node:getChildByTag(2))
        startTimerAction(self, 0.5, false, function() self:showHurt(skillId,targets) end)
        return
    elseif skillId == 1003 then   --刺杀剑术
        removeEffect(center_node:getChildByTag(3))
        startTimerAction(self, 0.5, false, function() self:showHurt(skillId,targets) end)
        return
    elseif skillId == 1010 then   --突斩
        removeEffect(center_node:getChildByTag(5))
        startTimerAction(self, 0.5, false, function() self:showHurt(skillId,targets) end)
        if #targets > 0 then
            AudioEnginer.playEffect("sounds/skillMusic/70591.mp3",false)
        end
        return
    elseif skillId == 1102 then   --强化攻杀
        removeEffect(center_node:getChildByTag(2))
        startTimerAction(self, 0.5, false, function() self:showHurt(skillId,targets) end)
        return
    elseif skillId == 3011 then   --幽冥火咒
        removeEffect(center_node:getChildByTag(2))
        startTimerAction(self, 0.8, false, function() self:showHurt(skillId,targets) end)
        return
    elseif skillId == 3004 then   --施毒术
        removeEffect(center_node:getChildByTag(3))
        startTimerAction(self, 1.3, false, function() 
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
        removeEffect(center_node:getChildByTag(5))
        startTimerAction(self, 1.0, false, function() 
            --添加灵兽
            if self.baobao ~= nil then
                return
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
           
            local baobao = G_MAINSCENE.map_layer:addMonster(myPos.x, myPos.y, 20085, nil, 1100, entity)            
            baobao:setSpriteDir(1)
            baobao:standed()
            baobao:setNameLabel("")
            baobao:setNameColor(MColor.green)
            table.insert(self.soldier, baobao)
            local ai = require("src/layers/story/StoryAIPet").new(self, baobao)
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
        removeEffect(center_node:getChildByTag(4))
        if #targets > 0 then
            AudioEnginer.playEffect("sounds/skillMusic/70841_2.mp3",false)
        end
        return
    elseif skillId == 2001 then   --小火球
        startTimerAction(self, 1.0, false, function() self:showHurt(skillId,targets) end)
        return
    end

    

    startTimerAction(self, 0.5, false, function() self:showHurt(skillId,targets) end)
end

--显示伤害
function StoryNode:showHurt(skillId,targets)  
    if targets == nil or G_MAINSCENE == nil then
        return
    end

    local hurt_num = self:getHurtNum(skillId)
    for k,v in pairs(targets)do        
        if v == self.baobao or v == G_ROLE_MAIN then
            return
        end

        if skillId < 9000 then
            if v== self.fashi or v== self.daoshi or v== self.zhanshi then
                return
            end
        end      
        
        local rr = tolua.cast(v, "SpriteMonster") 
        if rr and rr:getHP() > 0 and hurt_num > 0 and G_ROLE_MAIN then
            G_MAINSCENE.map_layer:showHurtNumer(hurt_num, cc.p(v:getPosition()), cc.p(G_ROLE_MAIN:getPosition()), 0.3, nil, false)
        end
       
        --G_MAINSCENE.map_layer:showHurtNumer(hurt_num, cc.p(v:getPosition()), cc.p(G_ROLE_MAIN:getPosition()), 0.3, nil, false)
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
                hurt_item:showNameAndBlood(false, 0)
                if G_MAINSCENE.map_layer.monster_head and tolua.cast(G_MAINSCENE.map_layer.monster_head, "cc.Node") then
                    G_MAINSCENE.map_layer.monster_head:updateInfo(hurt_item)
                end
                if cur_hp <= 0 then
                    local target_type = hurt_item:getType()
                    if target_type == 22 then
                        hurt_item:gotoDeath(6)
                    else
                        hurt_item:gotoDeath(7)
                    end

                    --删除标记
                    hurt_item:removeChildByTag(789)                    

                    --掉了物品
       --[[             if self.canDrop == true then
                        if self.dropIdx == nil then
                            self.dropIdx = 1120
                        else
                            self.dropIdx = self.dropIdx + 1
                        end
                       
                        if self.dropIdx == 1122 then
                            local posAdd = { cc.p(-1, 1), cc.p(-1, 0), cc.p(-1, -1), cc.p(0, - 1), cc.p(0, 1), cc.p(1, 1), cc.p(1, 0), cc.p(1, -1) }
                            local myPos = G_MAINSCENE.map_layer:space2Tile(cc.p(hurt_item:getPosition()))
                            for k, v in pairs(posAdd) do
                                local new = cc.p(myPos.x + v.x, myPos.y + v.y)
                                if not G_MAINSCENE.map_layer:isBlock(new) then
                                    myPos = new
                                    break
                                end
                            end
                        
                            local entity =
                            {
                                [ROLE_MODEL] = 6200026,
                                [ROLE_HP] = 2000,
                            }

                            --if self.dropIdx == 1120 then
                            --    entity[ROLE_MODEL] = 6200026
                            --end

                            G_MAINSCENE.map_layer:addDropOut(myPos.x, myPos.y, self.dropIdx, entity)
                            self.dropIdx = self.dropIdx + 1

                            self:showTextTips("story_tuto_tip2", nil, true)
                        end                     
                    end
]]
                    startTimerAction(self, 1, false, function() hurt_item:setVisible(false) end)
                end
            elseif hurt_item:getHP() < 1 and hurt_item:getCurrActionState() == ACTION_STATE_IDLE then
                if target_type == 22 then   --野蛮冲撞等无法执行死亡动作
                    hurt_item:gotoDeath(6)
                else
                    hurt_item:gotoDeath(7)
                end
            end
        end
        performWithDelay(self, func, 0.3 + 0.15)
    end
end

function StoryNode:getHurtNum(skillID)
    if skillID == 1006 then
        return math.random(2000,3600)
    elseif skillID == 1004 then
        return math.random(500,1000)
    elseif skillID == 1003 then
        return math.random(800,1500)
    elseif skillID == 1010 then
        return math.random(1000,2000)
    elseif skillID == 1102 then
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
        return math.random(100,200)
    end
end

function StoryNode:isCanMove(monster)
    if self.isEnd == true then
        return false
    end
    
    if self.targetBoss ~= monster then
        return true
    end

    return false
end

function StoryNode:isMonster(monster)
    for k,v in pairs(self.monsterTab) do       
        for m,n in pairs(v) do 
            if n ~= nil and n == monster then
                return true
            end
        end
    end

    return false
end

--所有角色定住
function StoryNode:stopInTime()
--[[   self:AIIdle()
     
    for k,v in pairs(self.monsterTab) do
        if k ~= 3 then
            for m, n in pairs(v) do
                if n ~= nil and n:getHP() > 0 and n:getCurrActionState() < ACTION_STATE_DEAD then
                    n:stopInTheTime()
                    self:addKmz(n)
                end
            end
        end
    end
]]
    for m, n in pairs(self.soldier) do
        if n ~= nil and n:getHP() > 0 and n:getCurrActionState() < ACTION_STATE_DEAD then
            if n.storyai ~= nil then
                n.storyai:idle()
            end
            n:stopInTheTime()
            self:addKmz(n)
        end
    end

    self.zhanshi:stopInTheTime()
    self:addKmz(self.zhanshi)
    self.fashi:stopInTheTime()
    self:addKmz(self.fashi)
    self.daoshi:stopInTheTime()
    self:addKmz(self.daoshi)

    if self.baobao ~= nil then
        self.baobao:stopInTheTime()
        self:addKmz(self.baobao)
    end
    
end

--播放视频
function StoryNode:playVideo(index)

    local fileName = "res/story/tips.png"
    if index == 3 then
        fileName = "res/story/tips1.png"
    end
   
    local imageBg = createSprite(self, fileName, cc.p( display.cx , display.cy ), cc.p(0.5, 0.5))
    imageBg:setOpacity(0)
    imageBg:runAction(cc.Sequence:create(cc.FadeIn:create(0.2)))

    --手势特效
    local centerPos = nil
    if index == 1 then
        local effectLoop = Effects:create(false)
        effectLoop:playActionData("story_handmove", 2, 1.5, -1)
        imageBg:addChild(effectLoop, 99, 123)
        effectLoop:setAnchorPoint(cc.p(0.5, 0.5))
        effectLoop:setPosition(cc.p(28, 18))
        centerPos = cc.p(118, 81)

        local hand = createSprite(imageBg, "res/story/hand.png", cc.p( 438 , 10 ), cc.p(0.5, 0.5))
        hand:setFlippedX(true)
    elseif index == 2 then
        local effectLoop = Effects:create(false)
        effectLoop:playActionData("story_handskill", 2, 1.5, -1)
        imageBg:addChild(effectLoop, 99, 123)
        effectLoop:setAnchorPoint(cc.p(0.5, 0.5))
        effectLoop:setPosition(cc.p(452, 17))
        centerPos = cc.p(342, 63)

        local hand = createSprite(imageBg, "res/story/hand.png", cc.p( 24 , 10 ), cc.p(0.5, 0.5))
    elseif index == 3 then
        local effectLoop = Effects:create(false)
        effectLoop:playActionData("story_handpick", 4, 1.5, -1)
        imageBg:addChild(effectLoop, 99, 123)
        effectLoop:setAnchorPoint(cc.p(0.5, 0.5))
        effectLoop:setPosition(cc.p(441, 18))
        centerPos = cc.p(380, 65)

        local hand = createSprite(imageBg, "res/story/hand.png", cc.p( 24 , 10 ), cc.p(0.5, 0.5))
    end

    --聚焦特效
    local effectLoop = Effects:create(false)
    effectLoop:playActionData("story_focus", 10, 1, -1)
    imageBg:addChild(effectLoop, 99, 123)
    effectLoop:setAnchorPoint(cc.p(0.5, 0.5))
    effectLoop:setPosition(centerPos)
    addEffectWithMode(effectLoop, 3)
        
    local bot = createSprite(self, "res/story/black.png", cc.p( display.cx , 0 ), cc.p(0.5, 0))
    bot:setScaleX(50)
    bot:setScaleY(3)
    bot:setOpacity(0)
    bot:runAction(cc.Sequence:create(cc.FadeIn:create(0.5)))

    local top = createSprite(self, "res/story/black.png", cc.p( display.cx , display.height ), cc.p(0.5, 1))
    top:setScaleX(50)
    top:setScaleY(3)
    top:setOpacity(0)
    top:runAction(cc.Sequence:create(cc.FadeIn:create(0.5)))

    --点击继续提示
    local tips = createLabel(self, game.getStrByKey("story_talk_tip"), cc.p(display.width-220, display.height - 45), cc.p(1, 0.5), 22, true, nil, nil, MColor.white)
    local arrow = createSprite(self, "res/group/arrows/13.png", cc.p(display.width-110, display.height - 45), cc.p(0, 0.5), nil, 0.6)
    arrow:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveTo:create(0.3, cc.p(display.width-100, display.height - 45)), cc.MoveTo:create(0.3, cc.p(display.width-110, display.height - 45)))))


 --[[   startTimerAction(self, 3, false, function() 
                                               removeFromParent(imageBg)
                                               removeFromParent(top)
                                               removeFromParent(bot)
                                               self:updateState()
                                           end)  
]]
    local function removeVideo()
        removeFromParent(imageBg)
        removeFromParent(top)
        removeFromParent(bot)
        removeFromParent(tips)
         removeFromParent(arrow)

        if self.m_textBg ~= nil then
            removeFromParent(self.m_textBg)
            self.m_textBg = nil
        end

        self:updateState()
    end

    local listenner = cc.EventListenerTouchOneByOne:create()
	listenner:setSwallowTouches(true)
    listenner:registerScriptHandler(function(touch, event) return true end,cc.Handler.EVENT_TOUCH_BEGAN )
    listenner:registerScriptHandler(function(touch, event) removeVideo()  end,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, imageBg)
end

function StoryNode:showTextTips(textid, soundFile, autoRemove)
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
        startTimerAction(self, 3, false, function() if self.m_textBg ~= nil then removeFromParent(self.m_textBg); self.m_textBg = nil end end)
    end

    --播放声音
    if soundFile ~= nil then
         AudioEnginer.playEffect(soundFile,false)
    end
end

function StoryNode:showOperateTips()
    local function addEffect(btn)
        if btn then
            local effect = Effects:create(false)
            effect:playActionData("operateTips", 10, 2, 10000)
            addEffectWithMode(effect,3)
            btn:addChild(effect)
            effect:setAnchorPoint(cc.p(0.5, 0.5))
            effect:setPosition(getCenterPos(btn))
            effect:setTag(123)
           -- btn:runAction(cc.Sequence:create(cc.DelayTime:create(4), cc.CallFunc:create( function() if effect then removeFromParent(effect) end end )))
        end
    end

    local  node = G_MAINSCENE.operate_node:getChildByTag(1)
    addEffect(node)
end

function StoryNode:showSkillTips()
    --给技能按钮添加特效
    local function addEffect(btn)
        if btn then
            local effect = Effects:create(false)
            effect:playActionData("newFunctionExSmall", 19, 2, -1)
            btn:addChild(effect)
            effect:setAnchorPoint(cc.p(0.5, 0.5))
            effect:setPosition(getCenterPos(btn))
            -- effect:setScale(1)
            effect:setTag(123)
        end
    end
    local center_node = G_MAINSCENE.skill_node:getCenterNode()
    addEffect(center_node:getChildByTag(2))
    addEffect(center_node:getChildByTag(3))
    addEffect(center_node:getChildByTag(4))
    addEffect(center_node:getChildByTag(5))

    --添加提示
--[[
    local node = center_node:getChildByTag(3)
    local nodePos = node:convertToWorldSpace(getCenterPos(node))
    local arrow = createSprite(self, "res/group/arrows/16.png", cc.p(nodePos.x, nodePos.y + 50), cc.p(0.5, 0))
    local richTextBg = createScale9Sprite(arrow, "res/common/scalable/bg2.png", cc.p(arrow:getContentSize().width / 2, arrow:getContentSize().height), cc.size(220, 100), cc.p(0.5, 0))
    local richText = require("src/RichText").new(richTextBg, cc.p(richTextBg:getContentSize().width / 2, richTextBg:getContentSize().height / 2), cc.size(richTextBg:getContentSize().width - 30, richTextBg:getContentSize().height - 30), cc.p(0.5, 0.5), 30, 24, MColor.white)
    richText:addText(game.getStrByKey("story_skill_tip"))
    richText:format()
    local action = cc.Sequence:create(cc.CallFunc:create( function() richTextBg:setOpacity(0) end), cc.FadeIn:create(1))
    richTextBg:runAction(action)
    richTextBg:runAction(cc.Sequence:create(cc.DelayTime:create(2), cc.CallFunc:create( function()
        if arrow then
            removeFromParent(arrow)
            arrow = nil
        end
    end )))
]]
end

function StoryNode:showPickTips()
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
        end
    end

    --添加提示
    local node = G_MAINSCENE.skill_node:getCenterItem()  
    addEffect(node)  

--[[    local arrow = createSprite(node, "res/group/arrows/16.png", cc.p(130, 260), cc.p(0.5, 1))
    arrow:setGlobalZOrder(10000)
    local richTextBg = createScale9Sprite(arrow, "res/common/scalable/bg2.png", cc.p(-20, 100), cc.size(220, 100), cc.p(0.5, 0))
    local richText = require("src/RichText").new(richTextBg, cc.p(richTextBg:getContentSize().width / 2, richTextBg:getContentSize().height / 2), cc.size(richTextBg:getContentSize().width - 30, richTextBg:getContentSize().height - 30), cc.p(0.5, 0.5), 30, 24, MColor.white)
    richText:addText(game.getStrByKey("story_tuto_tip5"))
    richText:format()
    --local action = cc.Sequence:create(cc.CallFunc:create( function() richTextBg:setOpacity(0) end), cc.FadeIn:create(1))
    --richTextBg:runAction(action)
    richTextBg:runAction(cc.Sequence:create(cc.DelayTime:create(2), cc.CallFunc:create( function()
        if arrow then
            removeFromParent(arrow)
            arrow = nil
        end
    end )))
]]
end

function StoryNode:canPick()
    if self.isEnd == true then
        return false
    end
    
    return self.canAutoPick
end

function StoryNode:canSelectRole()
    if self.isEnd == true then
        return false
    end
    
    return self.canAutoSelectRole
end

function StoryNode:resetPick(bPick)
    self.canAutoPick = bPick

    if self.pickLock ~= nil then
        self.pickLock:removeFromParent(true)
        self.pickLock = nil
    end

    local center_item = G_MAINSCENE.skill_node:getCenterItem()
    if not bPick then
        self.pickLock = createSprite(center_item, "res/story/lock.png", cc.p(-99, 213), cc.p(0.5, 0.5))
    end
end

function StoryNode:resetSelectRole(bSel)
    self.canAutoSelectRole = bSel

    if self.selLock ~= nil then
        self.selLock:removeFromParent(true)
        self.selLock = nil
    end

    local center_item = G_MAINSCENE.skill_node:getCenterItem()
    if not bSel then
        self.selLock = createSprite(center_item, "res/story/lock.png", cc.p(-163, 98), cc.p(0.5, 0.5))
    end
end
--[[
function  StoryNode:addPathPoint(endTile)
    self.pathPoints = cc.Node:create()
    G_MAINSCENE.map_layer:addChild(self.pathPoints)
    local endPos = G_MAINSCENE.map_layer:tile2Space(endTile)
    
    --终点图标
    local effect = Effects:create(false)
    effect:playActionData("storyEndPoint", 11, 2, -1)
    self.pathPoints:addChild(effect)
    effect:setAnchorPoint(cc.p(0.5, 0.47))
    effect:setPosition(endPos)
    addEffectWithMode(effect, 3)

    --箭头集合
    local arrows = cc.Node:create()
    arrows:setPosition(endPos)
    self.pathPoints:addChild(arrows)

    local arrowsTable = {}
    local max = 60
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
function  StoryNode:addPathPoint(endTile)
    self.pathPoints = cc.Node:create()
    G_MAINSCENE.map_layer:addChild(self.pathPoints)
    local endPos = G_MAINSCENE.map_layer:tile2Space(endTile)
    
    --终点图标
    local effect = Effects:create(false)
    effect:playActionData("storyEndPoint", 11, 2, -1)
    self.pathPoints:addChild(effect)
    effect:setAnchorPoint(cc.p(0.5, 0.47))
    effect:setPosition(endPos)
    addEffectWithMode(effect, 3)

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
            effect:setScale(0.7)
        end
    end
end

function  StoryNode:removePathPoint()
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

function  StoryNode:getNearestMonsterForCollide()
    local sel = nil
    local minDis = 999999999
    local myPos = G_MAINSCENE.map_layer:space2Tile(cc.p(G_ROLE_MAIN:getPosition()))
    for k,v in pairs(self.monsterTab) do       
        for m,n in pairs(v) do 
            if n ~= nil and n:isVisible() and n:getHP() > 0 then
                local nPos = G_MAINSCENE.map_layer:space2Tile(cc.p(n:getPosition()))
                local dis = (myPos.x - nPos.x)*(myPos.x - nPos.x)+(myPos.y - nPos.y)*(myPos.y - nPos.y)
                if dis < minDis then
                    minDis = dis
                    sel = n
                end
            end
        end
    end

    return sel
end

function  StoryNode:addKmz(role)
    if role == nil then
        return
    end

    local effectLoop = Effects:create(false)
    effectLoop:playActionData("kmz_loop", 8, 1, -1)   
    effectLoop:setAnchorPoint(cc.p(0.5, 0.4))
    -- effectLoop:setPosition(endPos)
    addEffectWithMode(effectLoop, 3)

    local topNode = role:getTopNode()
    if topNode ~= nil then
        topNode:addChild(effectLoop, 9999, 123)
    end

    --[[
    local effect = Effects:create(false)
    effect:playActionData("kmz_start", 12, 1, 1)
    role:addChild(effect)
    effect:setAnchorPoint(cc.p(0.5, 0.3))
    --effect:setPosition(endPos)
    addEffectWithMode(effect, 3)
    startTimerAction(self, 1, false, function() 
                        removeFromParent(effect)
                        local effectLoop = Effects:create(false)
                        effectLoop:playActionData("kmz_loop", 8, 1, -1)
                        role:addChild(effectLoop, 99, 123)
                        effectLoop:setAnchorPoint(cc.p(0.5, 0.4))
                        -- effectLoop:setPosition(endPos)
                        addEffectWithMode(effectLoop, 3)
                    end)  
    ]]
end

function StoryNode:showSkillActiveTips(skill_id)
    if skill_id ~= 2011 then
        return
    end

    self:showTextTips("story_tuto_tip6")
end

function StoryNode:lockOneMonster(monster, bLock)
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

function StoryNode:isCanTouchMonster()
    return self.m_bCanTouchMonster
end

function StoryNode:isFirstStory()
    return true
end

function StoryNode:addBubble(monster, textkey, showTime, posx, posy)
	local charNode = tolua.cast(monster, "SpriteMonster")
	if not charNode then
		return
	end

	local charTopNode = charNode:getTopNode()
	if charTopNode then
		local charBubble = charTopNode:getChildByTag(444)
		if charBubble then
			charBubble:removeFromParent()
		end
	end

	-------------------------------------------------------

	local textval = GetTalkByKey(textkey)
	if textval == "" then
		textval = textkey
	end

	local textPos = cc.p(posx, posy)
	local charBubbleNew = require("src/base/MonsterBubble").new(textval, textPos, 20)
	local charTopNode = charNode:getTopNode()
	if charTopNode then
		charTopNode:addChild(charBubbleNew)
	end
	charBubbleNew:setTag(444)

	-------------------------------------------------------

	local funcRemove = function()
        charBubbleNew:removeFromParent(true)
	end

    if showTime == nil then
        showTime = 3
    end
	performWithDelay(self, funcRemove, showTime)

end

return StoryNode