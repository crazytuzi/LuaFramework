local StoryShouSha = class("StoryShouSha", require ("src/layers/story/StoryGongSha"))

local path = "res/storygs/"

function StoryShouSha:ctor()
    G_STORY_FB_MODE = true
    self.state = 0
    self.playerTab = {{},{},{}}
    self.RolesAI = {}
    self.randomAI = {}
    self.isExitBtnCall = false
    
    self.factionTeam = 1
    self.hositleTeam = 2
    self.greenTeam = 3

    self.myTeam = 1

    startTimerAction(self, 0.1, false, function() 
            if G_ROLE_MAIN then 
                G_ROLE_MAIN:upOrDownRide(false)
            end 
        end )

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

function StoryShouSha:createExitBtn()
    function exitConfirm()
        local exit = function()
            self.isExitBtnCall = true
            self:endStroy()
        end

        if self.m_bFinishedCopy then
            self.isExitBtnCall = true
            self:endStroy()
        else
            MessageBoxYesNo(nil, game.getStrByKey("exit_confirm"), exit, nil, game.getStrByKey("sure"), game.getStrByKey("cancel"))
        end
    end
    local item = createMenuItem(self, "res/component/button/1.png", cc.p(g_scrSize.width - 70, g_scrSize.height - 110), exitConfirm)
    item:setSmallToBigMode(false)
    item:setLocalZOrder(100)
    self.exitBtn = item
    self.exitLab =createLabel(item, game.getStrByKey("fb_leave"), getCenterPos(item), cc.p(0.5, 0.5), 22, true, nil, nil, MColor.lable_yellow, 1);
end


function StoryShouSha:createPlayerBycfg(cfg)
    if not cfg then return nil end
        
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

    player:initStandStatus(4, 6, 1, 1)
    player:setSpriteDir(cfg.q_dir)
    player:standed()  
    local titleName = getConfigItemByKey("SpecialTitleDB", "q_id")
    for k,v in pairs(titleName) do
        if v.q_lv == params[ROLE_LEVEL] and v.q_school == params[ROLE_SCHOOL] then
            player:setSpecialTitle(player, v.q_id)
        end
    end
   -- player:showNameAndBlood(false, 0)

    local name_label = player:getNameBatchLabel()
    if name_label then
        if cfg.teamId == self.factionTeam then
            name_label:setColor(MColor.name_blue)
        elseif cfg.teamId == self.hositleTeam then
            name_label:setColor(MColor.name_orange)
        elseif cfg.teamId == self.greenTeam then
            name_label:setColor(MColor.green)
        end
    end
    player.teamId = cfg.teamId

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

    return player
end

--[[
function StoryShouSha:addSkill(isWithTip)   
    local MRoleStruct = require("src/layers/role/RoleStruct")
    local school = MRoleStruct:getAttr(ROLE_SCHOOL)

    local skillTab = {}
    if school == 1 then
        table.insert(skillTab, {1004,1,2,0})
        table.insert(skillTab, {1003,1,3,0})
        table.insert(skillTab, {1006,1,4,0})
        table.insert(skillTab, {1010,1,5,0})
    elseif school == 2 then
        table.insert(skillTab, {2010,1,2,0})
        table.insert(skillTab, {2005,1,4,0})
        table.insert(skillTab, {2011,1,3,0})
        table.insert(skillTab, {2004,1,5,0})       
    elseif school == 3 then
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
end

function StoryShouSha:removeSkill()
    if self.skillTabBak then
        local MRoleStruct = require("src/layers/role/RoleStruct")
        local school = MRoleStruct:getAttr(ROLE_SCHOOL)

        G_ROLE_MAIN:setSkills(self.skillTabBak)
        G_MAINSCENE:reloadSkillConfig()

        --换回父节点
        G_MAINSCENE.skill_node:retain()
        G_MAINSCENE.skill_node:removeFromParent()
        G_MAINSCENE.mainui_node:addChild(G_MAINSCENE.skill_node)
        G_MAINSCENE.skill_node:release()

        G_MAINSCENE.skill_node:setLocalZOrder(1)
        G_MAINSCENE.operate_node:setLocalZOrder(6)
        G_MAINSCENE.bloodNode:setLocalZOrder(6)
    end
end
]]--

function  StoryShouSha:addPathPoint(endTile, isNeedEnd)
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

function  StoryShouSha:removePathPoint()
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
function StoryShouSha:onSkillSend(skillId,targets,targetPos)
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
            for m, n in pairs(self.playerTab[self.hositleTeam]) do
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
            baobao:setSpriteDir(1)
            baobao:standed()
           -- baobao:setNameLabel("")
            baobao:setNameColor(MColor.name_blue)
            local petName = string.format(game.getStrByKey("story_gongsha_petname"), require("src/layers/role/RoleStruct"):getAttr(ROLE_NAME))
            baobao:setNameLabel(petName)
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
    end 

    startTimerAction(self, 0.2, false, function() self:showHurt(skillId,targets) end)
end

function StoryShouSha:showHurt(skillId,targets)  
    if targets == nil or G_MAINSCENE == nil or not self.m_canPlayerHurt then
        return
    end

    for k,v in pairs(targets)do        
        local hurt_num = self:getHurtNum(skillId, v)
        if v == self.baobao or v == G_ROLE_MAIN or hurt_num == 0 then
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
                    
                    startTimerAction(hurt_item, 2, false, function() hurt_item:setVisible(false) end)
                    
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

                startTimerAction(hurt_item, 2, false, function() hurt_item:setVisible(false) end)

                if skillId  < 9000 then
                    self:addLianZhanEff()
                end
            end
        end
        performWithDelay(self, func, 0.3 + 0.15)
    end
end

--假人释放技能
function StoryShouSha:onPlayerSkill(skillId,player,targets,targetPos)
    if self.isEnd == true then
        return
    end
    
    -- local maxMp = MRoleStruct:getAttr(ROLE_MAX_MP) or G_ROLE_MAIN:getMP()
    -- local mp = G_ROLE_MAIN:getMP() - maxMp* 0.01
    -- if mp < maxMp* 0.1 then
    --     mp = maxMp *0.1
    -- end
    -- G_MAINSCENE:updateHeadInfo(G_ROLE_MAIN:getHP(), mp)
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
    end 
end

function StoryShouSha:showPlayerHurt(skillId,player,targets,targetPos)
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
                local hurt_num = self:getHurtNumPlayer(skillId, player, v)
                local setHpNum = G_ROLE_MAIN:getHP() - hurt_num
                --setHpNum = (setHpNum <= 8) and 5 or setHpNum
                setHpNum = setHpNum < 0 and 0 or setHpNum
                G_ROLE_MAIN:setHP(setHpNum)
                G_MAINSCENE.map_layer:showHurtNumer(hurt_num, cc.p(v:getPosition()), cc.p(player:getPosition()), 0.3, nil, false)
                G_MAINSCENE:updateHeadInfo(setHpNum)
            end  
        else                                             
            local func = function()
                -- 异常
                if G_MAINSCENE == nil or IsNodeValid(G_MAINSCENE) == nil or IsNodeValid(self) == nil then
                    return
                end
                
                local hurt_num = self:getHurtNumPlayer(skillId, player, v) 
                local hurt_item = tolua.cast(v, "SpriteMonster")
                if hurt_item and hurt_item:getHP() > 0 and hurt_num > 0 then
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

                        startTimerAction(hurt_item, 2, false, function() hurt_item:setVisible(false) end)
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

                    startTimerAction(hurt_item, 2, false, function() hurt_item:setVisible(false) end)
                    
                end
            end
            performWithDelay(self, func, 0.3 + 0.15)      
        end
    end  
end

function StoryShouSha:addTalk(id, delay, delayDestory, text)
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
        if not record.q_role or record.q_role == 0 then
            local sex = require("src/layers/role/RoleStruct"):getAttr(PLAYER_SEX)
            local school = require("src/layers/role/RoleStruct"):getAttr(ROLE_SCHOOL)
            createSprite(bg, "res/mainui/npc_big_head/"..(sex-1)*3+school..".png", cc.p(bg:getContentSize().width/2+display.width/2+15, bg:getContentSize().height), cc.p(1, 0))
        else
            createSprite(bg, "res/mainui/npc_big_head/"..record.q_role .. ".png", cc.p(bg:getContentSize().width/2-display.width/2, bg:getContentSize().height), cc.p(0, 0))
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

function StoryShouSha:showTextTips(textid, soundFile, autoRemove)
    if self.m_top then
        removeFromParent(self.m_top)
        self.m_top = nil
    end
    
    G_MAINSCENE.bloodNode:setLocalZOrder(6)
    self.m_top = createSprite(self, "res/story/black.png", cc.p( 480 , 320 ), cc.p(0.5, 0.5), -1)
    self.m_top:setScale(150)
    self.m_top:setOpacity(200)
    startTimerAction(self.m_top, 2, false, function() if self.m_top then removeFromParent(self.m_top); self.m_top = nil end end)
    
    if self.m_textBg ~= nil then
        removeFromParent(self.m_textBg)
        self.m_textBg = nil
    end
    
    local imageBg = createSprite(self, "res/story/bg_text.png", cc.p( display.cx , 50), cc.p(0.5, 0.5),200)
    imageBg:setOpacity(0)
    imageBg:runAction(cc.Sequence:create(cc.FadeIn:create(0.2)))
    self.m_textBg = imageBg

    local lab = createLabel(imageBg, game.getStrByKey(textid), getCenterPos(imageBg), cc.p(0.5, 0.5), 24)

    if autoRemove == true then
        startTimerAction(self.m_textBg, 2, false, function() if self.m_textBg ~= nil then removeFromParent(self.m_textBg); self.m_textBg = nil G_MAINSCENE.bloodNode:setLocalZOrder(199) end end)
    end

    --播放声音
    if soundFile ~= nil then
         AudioEnginer.playEffect(soundFile,false)
    end
end

function StoryShouSha:addTaskInfo(idx)  
    self:delTaskInfo()

    local callback = function() end
    if idx == 1 or idx == 3 or idx == 5 then
        callback = function() game.setAutoStatus(4) end
    elseif idx == 2 then 
        callback = function() G_MAINSCENE.map_layer:moveMapByPos(self.m_defenderPos, false) end
    elseif idx == 4 then
        callback = function() G_MAINSCENE.map_layer:moveMapByPos(self.outPos, false) end
    end      
    self.m_tastBg = createTouchItem(self, "res/common/bg/bg62.png",cc.p(142, g_scrSize.height-155) , callback, false)  
    local strTitle = game.getStrByKey("story_gongsha_target_title")
    createLabel(self.m_tastBg, strTitle, cc.p(38,53),cc.p(0,0.5),20,nil,nil,nil,MColor.yellow)
       
    local strTab = {"story_shousha_target1",
                    "story_shousha_target2",
                    "story_shousha_target3",
                    "story_shousha_target4",
                    "story_shousha_target5",
                    "story_gongsha_target10",}
    local str = game.getStrByKey(strTab[idx])
    if idx == 1 or idx == 2 or idx == 3 or idx == 4 or idx == 5 then
        createLinkLabel(self.m_tastBg, str, cc.p(38,25),cc.p(0,0.5), 20, false, nil, MColor.lable_yellow, nil, callback, true)
    elseif idx == 6 then
        self.timeCount = 5   
        local text = string.format(str, self.timeCount)   
        local label = createLabel(self.m_tastBg, "完成", cc.p(38,25),cc.p(0,0.5),20,nil,nil,nil,MColor.lable_yellow)
        self.timeAction = startTimerAction(self, 1, true, function()           
            self.timeCount = self.timeCount - 1
            self.exitLab:setString(game.getStrByKey("fb_leave") .. "(" .. self.timeCount.. ")") 
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

function StoryShouSha:delTaskInfo()
    if self.m_tastBg then
        removeFromParent(self.m_tastBg)
        self.m_tastBg = nil
    end

    self.m_hurtText = nil
end

function StoryShouSha:addRoleHp(role, type)
    if not role then return end

    if self.notAddHp then return end
    local HpNum = math.random(100, 200)
    if type == 1 then
        HpNum = math.random(100, 200) 
    end

    local roleItem = tolua.cast(role, "SpriteMonster")
    if roleItem then
        local num = roleItem:getHP()
        local maxHP = roleItem:getMaxHP()
        if num < maxHP then
            roleItem:setHP( (num + HpNum > maxHP) and maxHP or (num + HpNum))
            G_MAINSCENE.map_layer:showHurtNumer(HpNum, cc.p(roleItem:getPosition()), cc.p(roleItem:getPosition()), 0.3, 2, false)
        end
    end
end

function StoryShouSha:addFocusEff(idx)
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

function StoryShouSha:isCanMove(monster) 
    if self.isEnd == true then
        return false
    end

    if monster == self.m_defender then
        return false
    end

    return true
end

function StoryShouSha:isMonster(monster)
    if monster == nil then
        return false
    end
    
    --地方阵营返回true
    for k, v in pairs(self.playerTab[self.hositleTeam]) do
        if v == monster then
            return true
        end
    end
    
    return false
end

function StoryShouSha:changeRoleDress(isOn)
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
        G_ROLE_MAIN:setBaseUrl( "role/".. g_normal_close_id+sex*100000)
        G_ROLE_MAIN:removeActionChildByTag(PLAYER_EQUIP_WEAPON)
        dress(sex, self.m_oriBody, self.m_oriWeapon)
    end
    G_ROLE_MAIN:standed()
    G_ROLE_MAIN:reloadRes()
end

function StoryShouSha:addTSXLEff()
    self.haveTsxlEffect = G_MAINSCENE.tslx_effect and true or false
    G_MAINSCENE:addTsxlEffect(1)
    G_MAINSCENE.tslx_effect:setLocalZOrder(199)
    startTimerAction(self, 1, true, function() self.notAddHp = false self:addRoleHp(G_ROLE_MAIN, 1) end)
end

function StoryShouSha:outBaseStroy()
    G_MAINSCENE:addTsxlEffect(self.haveTsxlEffect)
end

function StoryShouSha:canPick()
    return false
end

function StoryShouSha:canSelectRole()
    if self.isEnd == true then
        return false
    end
    
    return true
end

function  StoryShouSha:getNearestMonsterForCollide()
    
    return nil
end

function StoryShouSha:showSkillActiveTips(skill_id)
    
end

function StoryShouSha:isCanTouchMonster()
    return true
end

return StoryShouSha