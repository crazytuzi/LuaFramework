local Story3V3Practice = class("Story3V3Practice",  require ("src/layers/story/StoryGongSha"))

local path = "res/storygs/"

function Story3V3Practice:ctor()
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

    self.exitConfirm = function()
        MessageBoxYesNo(nil,game.getStrByKey("exit_confirm"),outBtnFun,nil,game.getStrByKey("sure"),game.getStrByKey("cancel"))
    end
    local outBtn = createMenuItem(self,"res/component/button/1.png", cc.p(g_scrSize.width-70, g_scrSize.height-110),self.exitConfirm)
    outBtn:setSmallToBigMode(false)
    self.exit_btn = outBtn
    self.level_str = createLabel(outBtn, game.getStrByKey("fb_leave"), getCenterPos(outBtn), cc.p(0.5,0.5), 22, true, nil, nil, MColor.lable_yellow, 1);

    outBtn:setVisible(false)
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

            if self.schedulerArrow ~= nil then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerArrow)
                self.schedulerArrow = nil
            end
        end
    end)

    
end
function Story3V3Practice:updateState()  

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
                             
            startTimerAction(self, 0.4, false, function()
                       self:changeRoleDress(true)                                             
                                              
                       self:setBlock()                      
                       local name_label = G_ROLE_MAIN:getNameBatchLabel()
                       if name_label then
                           self.mainRoleColor = name_label:getColor()
                           name_label:setColor(MColor.name_blue)
                       end

                       G_ROLE_MAIN:setFactionName_ex(G_ROLE_MAIN, game.getStrByKey("story_shouhu_faction_name"))
                       G_ROLE_MAIN:setTitle_ex(G_ROLE_MAIN, 0)

                       G_ROLE_MAIN:setPosition(G_MAINSCENE.map_layer:tile2Space(cc.p(10,33)))
                       G_MAINSCENE.map_layer:initDataAndFunc(cc.p(10,33))
                       G_MAINSCENE.map_layer:setDirectorScale(nil, cc.p(10,33))
                       G_MAINSCENE.map_layer:moveMapByPos(cc.p(10,33), false)
                       G_MAINSCENE.map_layer:scroll2Tile(cc.p(10,33))
                       G_ROLE_MAIN:setSpriteDir(1)                      
                       self:createPlayers(2116,1) 
                       --self:createDefender()
                                                    
                       --AudioEnginer.setIsNoPlayEffects(false)           
                   end)
            self:addTaskInfo(1)
            startTimerAction(self, 2.0, false, function() self:updateState()  end)


            local mapLayer=G_MAINSCENE.map_layer
            cc.SpriteFrameCache:getInstance():addSpriteFrames("res/effectsplist/3v3dooropen@0.plist")
            self.eff_door_0 = Effects:create(false)
            self.eff_door_0:setAsyncLoad(false)
            self.eff_door_0:setAnchorPoint(cc.p(0.5, 0.5))
            self.eff_door_0:setSpriteFrame("3v3dooropen/00000.png")
            self.eff_door_0:setPosition(cc.p(mapLayer:tile2Space(cc.p(15, 30)).x - 48, mapLayer:tile2Space(cc.p(15, 30)).y + 173))
            mapLayer:addChild(self.eff_door_0)
            self.eff_door_0:setVisible(true)
            self.eff_door_1 = Effects:create(false)
            self.eff_door_1:setAsyncLoad(false)
            self.eff_door_1:setAnchorPoint(cc.p(0.5, 0.5))
            self.eff_door_1:setSpriteFrame("3v3dooropen/00000.png")
            self.eff_door_1:setPosition(cc.p(mapLayer:tile2Space(cc.p(31, 16)).x + 40, mapLayer:tile2Space(cc.p(31, 16)).y + 147))
            mapLayer:addChild(self.eff_door_1)
            mapLayer:setBlockRectValue(cc.rect(14, 29, 0, 0), "1")
            mapLayer:setBlockRectValue(cc.rect(15, 30, 0, 0), "1")
            mapLayer:setBlockRectValue(cc.rect(13, 29, 0, 0), "1")
            mapLayer:setBlockRectValue(cc.rect(14, 30, 0, 0), "1")
            mapLayer:setBlockRectValue(cc.rect(15, 31, 0, 0), "1")
            mapLayer:setBlockRectValue(cc.rect(32, 16, 0, 0), "1")
            mapLayer:setBlockRectValue(cc.rect(33, 17, 0, 0), "1")
            mapLayer:setBlockRectValue(cc.rect(31, 16, 0, 0), "1")
            mapLayer:setBlockRectValue(cc.rect(32, 17, 0, 0), "1")
            mapLayer:setBlockRectValue(cc.rect(33, 18, 0, 0), "1")
        end
        ,

        

        function()  
            local record = getConfigItemByKey("storyTalk", "q_id", 102)
            local str = string.format("%s：^c(lable_black)\n      这个地方好，可以放开了热身！小心，不要落单！^", require("src/layers/role/RoleStruct"):getAttr(ROLE_NAME))
            self:addTalk(102, nil, nil, str) 
        end
        ,

        function ( ... )--倒计时，完了后开门


            local effect_countDown = Effects:create(false)
            effect_countDown:setAsyncLoad(false)
            self:addChild(effect_countDown)
            effect_countDown:setPosition(cc.p(display.cx, display.cy))
            effect_countDown:playActionData("ten_countdown", 10, 10, 1)
            startTimerAction(self, 10, false, function() 
                local mapLayer=G_MAINSCENE.map_layer
                --开门
                self.eff_door_0:playActionData("3v3dooropen", 10, 0.6, 1)
                self.eff_door_1:playActionData("3v3dooropen", 10, 0.6, 1)
                mapLayer:setBlockRectValue(cc.rect(14, 29, 0, 0), "0")
                mapLayer:setBlockRectValue(cc.rect(15, 30, 0, 0), "0")
                mapLayer:setBlockRectValue(cc.rect(13, 29, 0, 0), "0")
                mapLayer:setBlockRectValue(cc.rect(14, 30, 0, 0), "0")
                mapLayer:setBlockRectValue(cc.rect(15, 31, 0, 0), "0")
                mapLayer:setBlockRectValue(cc.rect(32, 16, 0, 0), "0")
                mapLayer:setBlockRectValue(cc.rect(33, 17, 0, 0), "0")
                mapLayer:setBlockRectValue(cc.rect(31, 16, 0, 0), "0")
                mapLayer:setBlockRectValue(cc.rect(32, 17, 0, 0), "0")
                mapLayer:setBlockRectValue(cc.rect(33, 18, 0, 0), "0")
                self:updateState()
            end )    
            
            self.m_manualFight = true                      
            self.exit_btn:setVisible(true)
            G_MAINSCENE:setFullShortNode(false)
            self:addSkill()          
            self:createHangNode()  
            self:showOperPanel()  
            
        end
        ,
        function() 
                    
            
                               
            for k, v in pairs(self.RolesAI) do
                v:fight()
            end
            self:updateState()

        end
        
        ,
        --开始战斗
        function()
            --startTimerAction(self, 1.0, false, function() self:addFocusEff(4) end)
            startTimerAction(self,0.1, false, function() for k, v in pairs(self.RolesAI) do if v  then v.m_startLockTarget = true end end  end)
            
            --self:addTaskInfo(3)
            startTimerAction(self, 0.1, false, function() self.needAutoAtk = 1; self.m_canPlayerHurt = true end)
            self.hurtAction = startTimerAction(self, 0.1, true, function() 
                    local bAllDie = true
                    for m, n in pairs(self.playerTab[2]) do
                        if n ~= nil and n:isVisible() and n:getHP() > 0 then
                            bAllDie = false
                            break
                        end
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

        --结束
        function()    
            print("结束xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx")                 
            --杀光敌人后添加随机移动
            for k, v in pairs(self.RolesAI) do
                v.canRandomMove = true
                v.m_startLockTarget = false
            end
            self:hideOperPanel() 
            self:updateState()
        end
        ,
        function() 
            self:hideHangNode() 
            game.setAutoStatus(0) 
            local record = getConfigItemByKey("storyTalk", "q_id", 102)
            local str = string.format("%s：^c(lable_black)\n      干得漂亮！^", require("src/layers/role/RoleStruct"):getAttr(ROLE_NAME))
            self:addTalk(102, nil, nil, str) 
        end
        ,
         function()  
            self:addWinFlg()
            startTimerAction(self, 2, false, function() self:updateState() end)                  
        end
        ,
        --退出来！
        function()
            print("退出来！")
            g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_FINISH_SINGLEINST, "FinishSingleInstProtocol", {instID = 24});
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

function Story3V3Practice:endStroy()
    g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_EXITCOPY,"ExitCopyProtocol", {})
    
    self.isEnd = true
    game.setAutoStatus(0)

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
    G_MAINSCENE:removeChildByTag(1256)
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

    --g_msgHandlerInst:sendNetDataByTableExEx(SHAWAR_CS_REQUEST_UPDATE_MONIWAR_STAGE, "ShaWarRequestUpdateMoniWarStage", {stage=1})
    
    --记录路径
    --require("src/layers/story/StoryAIPlayer"):writePaths()

    --G_MAINSCENE:exitStoryMode()

    print("end ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
end



--创建角色
function Story3V3Practice:createPlayers(mapId, order)    
    local items =getConfigItemByKey("storyPlayer", "q_id") 
    local x=53
    local y=131
    local function getSpecialTitle( school,lv )
        for k,v in pairs(getConfigItemByKey("SpecialTitleDB", "q_id")) do
            if v.q_school==school and v.q_lv==lv then
                return v.q_id
            end
        end
    end
    --local pos={cc.p(19,23),cc.p(23,27),cc.p(25,18),cc.p(27,20),cc.p(29,22)}
    local dir={1,1,5,5,5}
    local pos={cc.p(9,32),cc.p(11,34),cc.p(35,12),cc.p(36,13),cc.p(37,14)}
    local index=1
    for i = 301, 306 do   
        local cfg = items[i]
        if not (MRoleStruct:getAttr(ROLE_SCHOOL)==cfg.q_school and i<=303)  then
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
            local player = G_MAINSCENE.map_layer:makeMainRole(pos[index].x, pos[index].y, "role/".. w_resId, 3, false, cfg.q_id, params)
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
    ]]      if cfg.q_level>=getConfigItemByKey("SpecialTitleDB", "q_id",1,"q_lv") then
                G_ROLE_MAIN:setSpecialTitle(player, getSpecialTitle(cfg.q_school,cfg.q_level))
            end
            player:initStandStatus(4, 6, 1, 1)
            player:setSpriteDir(dir[index])
            player:standed()   
           -- player:showNameAndBlood(false, 0)
            if index<=2 then
                cfg.q_camp=1
            else
                cfg.q_camp=2
            end
            if cfg.q_camp == 1 then
                --player:setNameColor(MColor.blue)
                local name_label = player:getNameBatchLabel()
                if name_label then
                    name_label:setColor(MColor.name_blue)
                end

                player:setFactionName_ex(player, game.getStrByKey("story_shouhu_faction_name"))
            else
                --player:setNameColor(MColor.orange)
                local name_label = player:getNameBatchLabel()
                if name_label then
                    name_label:setColor(MColor.name_orange)
                end

                player:setFactionName_ex(player, game.getStrByKey("story_gongsha_factionname2"))
            end
            table.insert(self.playerTab[cfg.q_camp], player)
            player.camp = cfg.q_camp

            --关联AI
            local destPos2 = nil
            if cfg.q_dst_x_2 and cfg.q_dst_y_2 then
                destPos2 = cc.p(cfg.q_dst_x_2,cfg.q_dst_y_2)
            end
            local destPos=cc.p(pos[index].x+13,pos[index].y-8)
            if cfg.q_camp==2 then
                destPos=cc.p(pos[index].x-13,pos[index].y+8)
            end
            local ai = require("src/layers/story/StoryAIPlayer").new(self, player, cfg.q_school, destPos, destPos2, cfg.q_camp, cfg.q_target)
            ai.m_lockRange=50
            player.storyai = ai
            table.insert(self.RolesAI, ai)

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
            index=index+1   
        end  
        
    end  
end




function Story3V3Practice:addTaskInfo(idx)  
    self:delTaskInfo()

    --self.m_tastBg = createSprite(self , "res/common/bg/bg62.png" , cc.p(2, g_scrSize.height-155) , cc.p( 0, 0.5 ) )  
    self.m_tastBg = createTouchItem(self, "res/common/bg/bg62.png",cc.p(142, g_scrSize.height-155) , function() end, false) 
    
       
    local strTab = {}
    local str = game.getStrByKey(strTab[idx])
    if idx == 1 then
        local strTitle = game.getStrByKey("story_gongsha_target_title")
        local goldStr=
        createLabel(self.m_tastBg, strTitle, cc.p(38,53),cc.p(0,0.5),20,nil,nil,nil,MColor.yellow)
        local function go() 
            --G_MAINSCENE.map_layer:moveMapByPos(cc.p(132, 112), false)
            game.setAutoStatus(AUTO_ATTACK)
        end
        
        createLinkLabel(self.m_tastBg, "战胜挑战者", cc.p(38,25),cc.p(0,0.5), 20, false, nil, MColor.lable_yellow, nil, go, true)
    elseif idx == 2 then
        self.timeCount = 5 
        local label = createLabel(self.m_tastBg, "完成", cc.p(38,38),cc.p(0,0.5),20,nil,nil,nil,MColor.lable_yellow)
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

    self.m_tastBg:setPosition(cc.p(-140, g_scrSize.height-155))
    self.m_tastBg:runAction(cc.MoveTo:create(1, cc.p(142, g_scrSize.height-155)))
end



return Story3V3Practice