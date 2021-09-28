local StoryShouHu = class("StoryShouHu", require ("src/layers/story/StoryGongSha"))

local path = "res/storygs/"

function StoryShouHu:ctor()
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
                    game.setAutoStatus(4)
                else
                    game.setAutoStatus(0)
                end
]]            
                self:updateHangNode()
            end

            self.schedulerHandle = cc.Director:getInstance():getScheduler():scheduleScriptFunc(updateAI, 1, false)
        elseif event == "exit" then
            if self.schedulerHandle then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerHandle)
                self.schedulerHandle = nil
            end 
        end
    end)

    
end

function StoryShouHu:updateState()  

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
                             
            startTimerAction(self, 0.1, false, function()                     
                       
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

                       G_ROLE_MAIN:setPosition(G_MAINSCENE.map_layer:tile2Space(cc.p(41,31)))
                       G_MAINSCENE.map_layer:initDataAndFunc(cc.p(41,31))
                       G_MAINSCENE.map_layer:setDirectorScale(nil, cc.p(41,31))
                       G_MAINSCENE.map_layer:moveMapByPos(cc.p(40, 30), false)
                       G_ROLE_MAIN:setSpriteDir(3) 

                       self:addRole()
                       self:createExitBtn()
                       --AudioEnginer.setIsNoPlayEffects(false)                                  
                   end)

            startTimerAction(self, 1, false, function() self:updateState()  end)
        end
        ,

        --开场对话
        function()  
            self:addTalk(70)
        end
        ,

        function()  
            self:addTalk(71)
        end
        ,

        function()  
            self:addTalk(72)
        end
        ,

        --开启战斗
        function()  
            self:addTaskInfo(1)
            startTimerAction(self, 1.0, false, function() 
                        self.m_manualFight = true
                        G_MAINSCENE:setFullShortNode(false)
                        self:addSkill()                       
                        self:updateState() 
                   end) 
        end
        ,

        function()  
            
            --5秒倒计时特效
            self:createTimeInfo()
            startTimerAction(self, 5.0, false, function() self:updateState() end) 
        end
        ,

        function()  
            --第一波怪物
            self:createHangNode() 
            self:showOperPanel()            
            self:addMonster(1)
            self:createPanel()
            startTimerAction(self, 0.5, false, function() self:updateState() end) 
        end
        ,

        --击杀第一波怪物
        function()  
            startTimerAction(self, 0.1, false, function() for k, v in pairs(self.RolesAI) do if v  then v:fight() end end end)          
            startTimerAction(self, 0.1, false, function() self.needAutoAtk = 1; self.m_canPlayerHurt = true end)
            self.hurtAction = startTimerAction(self, 0.1, true, function() 
                    self:updateMonsterInfo(1)
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

        function()  
            startTimerAction(self, 3, false, function() self:updateState() end) 
        end
        ,

        function()  
            --第二波怪物
            self:addMonster(2)
            startTimerAction(self, 0.1, false, function() for k, v in pairs(self.RolesAI) do if v  then v:fight() end end end)          
            startTimerAction(self, 0.1, false, function() self.needAutoAtk = 1; self.m_canPlayerHurt = true end)
            self.hurtAction = startTimerAction(self, 0.1, true, function() 
                    self:updateMonsterInfo(2)
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

        function()  
            startTimerAction(self, 3, false, function() self:updateState() end) 
        end
        ,

        function()  
            --第三波怪物
            self:addMonster(3)
            startTimerAction(self, 0.1, false, function() for k, v in pairs(self.RolesAI) do if v  then v:fight() end end end)          
            startTimerAction(self, 0.1, false, function() self.needAutoAtk = 1; self.m_canPlayerHurt = true end)
            self.hurtAction = startTimerAction(self, 0.1, true, function() 
                    self:updateMonsterInfo(3)
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

        --结束时的对话
        function()  
            self.m_manualFight = false
            self:hideOperPanel() 
            game.setAutoStatus(0)

            self:addTalk(73)
        end
        ,

        function()  
            local record = getConfigItemByKey("storyTalk", "q_id", 74)
            local str = string.format(record.q_text, require("src/layers/role/RoleStruct"):getAttr(ROLE_NAME))
            self:addTalk(108, nil, nil, str) 
        end
        ,

        function()  
            self:addWinFlg()
            startTimerAction(self, 2, false, function() self:updateState() end)                  
        end
        ,

        function() 
            g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_FINISH_SINGLEINST, "FinishSingleInstProtocol", {instID = 10});
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

function StoryShouHu:endStroy()
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

    G_ROLE_MAIN.base_data.spe_skill = {}
    G_MAINSCENE.map_layer:resetSpeed(g_speed_time)
    G_MAINSCENE:removeChildByTag(1256)

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

function StoryShouHu:addRole()
	if G_ROLE_MAIN == nil then
		return
	end

    --公主
    local entity =
    {
        [ROLE_MODEL] = 9002,
        [ROLE_HP] = 2000,
    }
    self.gongzhu = G_MAINSCENE.map_layer:addMonster(42, 32, 10034, nil, 800, entity)
    self.gongzhu:initStandStatus(4, 6, 1, 6)
    self.gongzhu:standed()

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
        if params[PLAYER_EQUIP_WING] > 0 then
            local w_resId = getConfigItemByKey("WingCfg","q_ID",params[PLAYER_EQUIP_WING] ,"q_senceSouceID")
            w_resId = G_ROLE_MAIN:getRightResID(PLAYER_EQUIP_WING,w_resId+100000)
            local w_path = "wing/" .. (w_resId)
            G_ROLE_MAIN:setEquipment_ex(player,PLAYER_EQUIP_WING,w_path)
        end
        player:initStandStatus(4, 6, 1, 1)
        player:setSpriteDir(dir)
        player:standed()  

        table.insert(self.playerTab[1], player)
        player.camp = 1

        local name_label = player:getNameBatchLabel()
        if name_label then
            name_label:setColor(MColor.name_blue)
        end

        player:setFactionName_ex(player, game.getStrByKey("story_shouhu_faction_name"))

        -- 关联AI
        local ai = require("src/layers/story/shouhu/StoryAIPlayerShouHu").new(self, player, params[ROLE_SCHOOL], cc.p(posx,posy))
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
    params[ROLE_NAME] = "战神·孟虎"
    params[PLAYER_EQUIP_WEAPON] = 5110107
    params[PLAYER_EQUIP_UPPERBODY] = 5110507
    params[PLAYER_EQUIP_WING] = 4031	
    self.zhanshi = createRole(params, 801, 40, 35, 3)

    --法师
	params[ROLE_SCHOOL] = 2
    params[ROLE_NAME] = "法神·洪"
    params[PLAYER_EQUIP_WEAPON] = 5120107
    params[PLAYER_EQUIP_UPPERBODY] = 5120507
    params[PLAYER_EQUIP_WING] = 5031	
    self.fashi = createRole(params, 802, 45, 30, 1)

    --道士
	params[ROLE_SCHOOL] = 3
    params[ROLE_NAME] = "道尊·百谷"
    params[PLAYER_EQUIP_WEAPON] = 5130107
    params[PLAYER_EQUIP_UPPERBODY] = 5130507
    params[PLAYER_EQUIP_WING] = 6031	
    self.daoshi = createRole(params, 803, 45, 35, 7)
end

function StoryShouHu:addMonster(order)    
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

        local ai = require("src/layers/story/shouhu/StoryAIMonsterShouHu").new(self, monster)
        monster.storyai = ai
        table.insert(self.RolesAI, ai)

        return monster
    end
     
    --轮次，monster表中id，数量，坐标x，坐标y，同一拨批次
    local mT = {
                  {{1,237,3,68,18,20076},{1,236,4,68,18,20050},},
                  {{2,237,3,68,18,20076},{2,238,3,68,18,20077},{2,239,2,68,18,20050},{2,237,3,20,50,20076},{2,238,1,20,50,20077},{2,239,2,20,50,20050},},
                  {{3,246,1,68,18,20019},}
               }
    self.mT = mT

    local hT = {200,200,10000}
    if self.m_curMonsterID == nil then
        self.m_curMonsterID = 900
    end

    local param = {q_id=900, q_x=27, q_y=41, q_hp=2000, q_monster_model=20001, q_featureid=20071}
    for k, v in pairs(mT[order]) do
        param.q_monster_model = v[2]
        param.q_featureid = v[6]
        param.q_hp = hT[order]
        for i=1, v[3] do
            local x = math.random(1, 8) - 4
            local y = math.random(1, 8) - 4
            param.q_x = v[4] + x
            param.q_y = v[5] + y
            
            param.q_id = self.m_curMonsterID
            self.m_curMonsterID = self.m_curMonsterID + 1

            if G_MAINSCENE and not G_MAINSCENE.map_layer:isBlock(cc.p(param.q_x, param.q_y)) then
                createMonster(param)
            end
        end                   
    end
end

function StoryShouHu:addTaskInfo(idx)  
    self:delTaskInfo()

    local callback = function() end            
    if idx == 1 then
        callback = function() game.setAutoStatus(AUTO_ATTACK) end
    end

    --self.m_tastBg = createSprite(self , "res/common/bg/bg62.png" , cc.p(2, g_scrSize.height-155) , cc.p( 0, 0.5 ) )  
    self.m_tastBg = createTouchItem(self, "res/common/bg/bg62.png",cc.p(142, g_scrSize.height-155) , callback, false) 
    local strTitle = game.getStrByKey("story_gongsha_target_title")
    local bgLabel = createLabel(self.m_tastBg, strTitle, cc.p(38,53),cc.p(0,0.5),20,nil,nil,nil,MColor.yellow)
       
    local strTab = {"story_shouhu_target1","story_shouhu_target2",}
    local str = game.getStrByKey(strTab[idx])
    if idx == 1 then
        createLinkLabel(self.m_tastBg, str, cc.p(38,25),cc.p(0,0.5), 20, false, nil, MColor.lable_yellow, nil, callback, true)
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

function StoryShouHu:createTimeInfo()
    local begainTime = 5
    local timeNode = cc.Node:create()
	self:addChild(timeNode)

    createLabel(timeNode, "刷怪倒计时", cc.p(g_scrSize.width/2, 550/640 * g_scrSize.height), cc.p(0.5,0.5), 26, true):setColor(MColor.yellow)

    local cb = function()
	    begainTime = begainTime - 1
	    if begainTime >= 0 then
		    if timeNode.timeToStartPic then
			    removeFromParent(timeNode.timeToStartPic)
		    end
		
		    local pos = g_scrSize.width / 2
		    if begainTime >= 10 then
			    pos = pos - 15
		    end
		
		    local timeToStartPic = MakeNumbers:create("res/component/number/3.png", begainTime, -2)
		    timeToStartPic:setPosition(cc.p(pos, 500 / 640 * g_scrSize.height))
		    timeToStartPic:setAnchorPoint(cc.p(0.5, 0.5))

		    timeNode:addChild(timeToStartPic)		
		    timeNode.timeToStartPic = timeToStartPic
	    else
            if self.timeAction then
                self.timeAction:stopAllActions()
                self.timeAction = nil
            end

	        removeFromParent(timeNode)
	    end
    end

    self.timeAction = startTimerActionEx(self, 1, true, cb)
end

function StoryShouHu:createPanel()
        local height = display.cy + 120

		local posYOffset = 30
		local bg = createScale9Sprite(self, "res/fb/multiple/bg.png", cc.p(display.width - 10, height), cc.size(230, 132),cc.p(1, 0.5), nil, nil, 101)	
		local switchShowModeFunc = function()
			if self.bgIsShow then
				self.swithShowModeBtn:setTexture("res/mainui/anotherbtns/shrink.png")
				bg:runAction(cc.MoveBy:create(0.2, cc.p(bg:getContentSize().width + 10, 0)))
			else
				bg:runAction(cc.MoveBy:create(0.2, cc.p(-bg:getContentSize().width - 10, 0)))
				self.swithShowModeBtn:setTexture("res/mainui/anotherbtns/spread.png")
			end
			self.bgIsShow = not self.bgIsShow
		end
		self.swithShowModeBtn = createTouchItem(bg, "res/mainui/anotherbtns/spread.png", cc.p( -50, 100), switchShowModeFunc)
		self.swithShowModeBtn:setAnchorPoint(cc.p(0, 1))
		self.bgIsShow = true

		self.longMaiNode = cc.Node:create()
		bg:addChild(self.longMaiNode)
		self.longMaiNode:setPosition(cc.p(0, -90))
		self.circleLab = createLabel(self.longMaiNode, string.format(game.getStrByKey("fb_enemyOrder3"), "1") ,cc.p(125, 200), cc.p(0.5, 0.5), 24, true)
		self.circleLab:setColor(MColor.lable_yellow)
	    
    --[[    function exitConfirm()
            local exit = function()
                g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_EXITCOPY,"ExitCopyProtocol", {})
            end
            
            MessageBoxYesNo(nil,game.getStrByKey("exit_confirm"),exit,nil,game.getStrByKey("sure"),game.getStrByKey("cancel"))
		end
        local item = createMenuItem(self,"res/component/button/1.png", cc.p(g_scrSize.width-70, g_scrSize.height-110),exitConfirm)
	    item:setSmallToBigMode(false)
	    self.exitBtn = item
	    createLabel(item, game.getStrByKey("fb_leave"), getCenterPos(item), cc.p(0.5,0.5), 22, true, nil, nil, MColor.lable_yellow, 1);
]]
		local MidNode = cc.Node:create()
		self:addChild(MidNode)
		--createLabel(MidNode, game.getStrByKey("fb_longmai1"), cc.p(display.cx, display.height - 70 + posYOffset), cc.p(0.5,0.5), 26, true):setColor(MColor.lable_yellow)
		self.m_progBg = createSprite(MidNode, "res/component/progress/4_bg.png",cc.p(display.width - 300 - 110, display.height-34), cc.p(0, 0))
		self.progress = cc.ProgressTimer:create(cc.Sprite:create("res/component/progress/4.png"))  
	    self.progress:setPosition(getCenterPos(self.m_progBg))
	    self.progress:setType(cc.PROGRESS_TIMER_TYPE_BAR)
	    self.progress:setAnchorPoint(cc.p(0.5,0.5))
	    self.progress:setBarChangeRate(cc.p(1, 0))
	    self.progress:setMidpoint(cc.p(0,1))
        
        -- 初始满血
        self.progress:setPercentage(100)
	    self.m_progBg:addChild(self.progress)  

		--self.labProgress = createLabel(self.m_progBg, tostring(self.currBlood.."/"..self.fbData.statuelife) ,getCenterPos(self.m_progBg), nil, 22, true, nil, nil, MColor.white)
        local labPos = getCenterPos(self.m_progBg)
        self.labProgress = createLabel(self.m_progBg, "" ,cc.p(labPos.x + 20, labPos.y), nil, 18, true, nil, nil, MColor.white)
        createLabel(self.m_progBg, game.getStrByKey("fb_longmai1"), cc.p(30, 6), cc.p(0, 0), 18, true, nil, nil, MColor.gold)
end

function StoryShouHu:updateMonsterInfo(order)
    if self.longMaiNode == nil then
        return
    end

    if self.longMaiNode:getChildByTag(500) then
        self.longMaiNode:removeChildByTag(500)
    end

    local LabNode = cc.Node:create()
    self.longMaiNode:addChild(LabNode, 100, 500)

    local tmp = {}
    for i=1,#self.playerTab[2] do
        local monster = self.playerTab[2][i]
        if monster:getHP() > 0 then
            if tmp[monster.model] == nil then
                tmp[monster.model] = 1
            else
                tmp[monster.model] = tmp[monster.model] + 1
            end
        end
    end


    --怪物数量更新
    local count = 0
    for k,v in pairs(tmp) do
        local num = v

        local currM = getConfigItemByKey("monster", "q_id", k)
        local lab = createLabel(LabNode, currM.q_name, cc.p(15, 175 - count * 30), cc.p(0.0, 0.5), 18)
        lab:setColor(MColor.lable_black)
        lab = createLabel(LabNode, game.getStrByKey("fb_numLeft2") .. " " .. num, cc.p(165, 175 - count * 30), cc.p(0.0, 0.5), 18)
        lab:setColor(MColor.lable_black)
        count = count + 1
    end

    --地图提示
    if self.m_lastMonsterUpdate ~= order then      
 --[[       local pT = { {cc.p(68,18),cc.p(20,50)},{cc.p(68,18),cc.p(20,50)},{cc.p(68,18)} }
        local dlta = 0.1
        for i = 1,#pT[order] do
            local actions = { }
            actions[#actions + 1] = cc.DelayTime:create(dlta)
            actions[#actions + 1] = cc.CallFunc:create( function()
                G_MAINSCENE:showArrowPointToMonster(true, pT[order][i], true);
            end )
            actions[#actions + 1] = cc.DelayTime:create(3.0)
            actions[#actions + 1] = cc.CallFunc:create( function()
                G_MAINSCENE:showArrowPointToMonster(false);
            end )
            G_MAINSCENE:runAction(cc.Sequence:create(actions))  
            dlta = dlta + 3.1
        end
     ]]   
        self.m_lastMonsterUpdate = order

        if self.circleLab then
            self.circleLab:setString(string.format(game.getStrByKey("fb_enemyOrder3"),tostring(order)))
        end
    end

    --公主血量更新
    local per = self.gongzhu:getHP()/2000*100
    self.progress:setPercentage(per)
    self.labProgress:setString(tostring(self.gongzhu:getHP().."/2000"))
end

return StoryShouHu