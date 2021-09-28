local JjcMapLayer = class("JjcMapLayer",require("src/base/MainMapLayer.lua"))

function JjcMapLayer:ctor(strname,parent,r_pos,mapId)    
	self.parent = parent
	--self.isMineMap = true
--	if self.parent.head_redPoint then
--		self.parent.head_redPoint:setVisible(false)
--	end
	if self.parent.mapName then
		self.parent.mapName:setString(getConfigItemByKey("MapInfo","q_map_id",mapId,"q_map_name"))
	end    
    self.scheduler = cc.Director:getInstance():getScheduler()
    self.schedulerHandle = self.scheduler:scheduleScriptFunc(function() self:jjcUpdate() end,1,false)
	self.parent:setFullShortNode(false)
	userInfo.lastFBScene = nil
	self.roleflag = {}
	self:initializePre()
	self.updata_time = 0
    self.isJjc = true
	self.remain_skill_times = 0	
	self.hasLoadEnemy = false
    self.isover = false
	self:loadMapInfo(strname, mapId,r_pos)
	self.parent:addChild(self,-1)
	self:loadSpritesPre()
	self.has_loadmap = true
	if G_ROLE_MAIN then
        G_ROLE_MAIN:upOrDownRide(false,true)
		self:makeMainRole(r_pos.x,r_pos.y,nil,3,true,G_ROLE_MAIN.obj_id)
		G_ROLE_MAIN:setSpriteDir(1)
		G_ROLE_MAIN:standed()
	end
    self:showScoreBoard()
	self.npc_tab = {}
	self:setSkillMap()
    self.timeToBegin = 5
    --self.timeLab = createLabel(self.parent, tostring(self.timeToBegin), cc.p(g_scrSize.width/2,500), cc.p(0.0,0.5),40,true,nil,nil,MColor.red)
    self.blackLayer = cc.LayerColor:create(cc.c4b(14, 9, 0, 100))       -- modified by michael from 200 to 100
    SwallowTouches(self.blackLayer)
    self.parent:addChild(self.blackLayer,190)
    self.timeLab = createSprite(self.parent,"res/component/number/"..20+self.timeToBegin..".png",cc.p(g_scrSize.width/2,580), cc.p(0.5,0.5),191,0.7)
    
    self:registerMsgHandler()

end

function JjcMapLayer:showScoreBoard()
    self.scoreBoard = createSprite(self.parent,"res/mainui/sideInfo/timeBg.png", cc.p(display.width-154-171, g_scrSize.height), cc.p(0.5,1))
    local scoreBoardSize = self.scoreBoard:getContentSize()
	self.timeLab1 = createLabel(self.scoreBoard, game.getStrByKey("battle_countdown"), cc.p(scoreBoardSize.width/2,scoreBoardSize.height - 16), cc.p(0.5,0.5), 18, true)
    self.timeLab2 = createLabel(self.scoreBoard, "60", cc.p(scoreBoardSize.width/2, scoreBoardSize.height/2-10), cc.p(0.5,0.5), 50, true)

    local exitJJC = function()
        if self.isover then
            self:exit()
        else
            MessageBoxYesNo(nil, game.getStrByKey("jjc_tip_exit_confirm"), function() self:exit() end, nil)
        end
    end
    local exit_menu = createMenuItem(self.parent,"res/component/button/1.png",cc.p(g_scrSize.width-70,g_scrSize.height-110),exitJJC)
    self.exitButtonTxt = createLabel(exit_menu,game.getStrByKey("exit"),cc.p(exit_menu:getContentSize().width/2,exit_menu:getContentSize().height/2),cc.p(0.5,0.5),22,true,nil,nil,MColor.yellow_gray)
    self.exit_menu = exit_menu
end

function JjcMapLayer:exit()
    if self.scheduler and self.schedulerHandle then
        self.scheduler:unscheduleScriptEntry(self.schedulerHandle)
         self.scheduler = nil
    end
    if self.isJjc then
    	g_msgHandlerInst:sendNetDataByTableExEx(SINPVP_CS_EXITPVP,"SinpvpExitPvpProtocol",{})
        addNetLoading(DIGMINE_CS_EXITMINE,FRAME_SC_ENTITY_ENTER)
    end
    self.has_loadmap = nil
end

function JjcMapLayer:addMonster_ex(px,py,filepath,maxcut,objid,entity)
	local params={}
	self.enemyInfo = userInfo.jjcData
    params[ROLE_SCHOOL] = self.enemyInfo[4]
    params[PLAYER_SEX] = self.enemyInfo[5]
    --if self.enemyInfo[4] == 2 then params[PLAYER_SEX] = 2 end
    self.enemyBlood = self.enemyInfo[10]
    params[ROLE_HP] = self.enemyInfo[10]
    params[ROLE_LEVEL] = self.enemyInfo[11] 
    if params[ROLE_LEVEL] <= 0 then 
        params[ROLE_LEVEL] = 1 
    end
    --print("self.enemyInfo[10]"..self.enemyInfo[11])
    params[ROLE_MAX_HP] = self.enemyInfo[10]
    params[ROLE_NAME] = self.enemyInfo[3]
    params[PLAYER_EQUIP_WEAPON] = self.enemyInfo[7]
    params[PLAYER_EQUIP_UPPERBODY] = self.enemyInfo[8]
    params[PLAYER_EQUIP_WING] = self.enemyInfo[9]	
    local MpropOp = require "src/config/propOp"
    local w_resId = MpropOp.equipResId(params[PLAYER_EQUIP_UPPERBODY])
    if w_resId == 0 then w_resId = g_normal_close_id end
    local w_resId = G_ROLE_MAIN:getRightResID(PLAYER_EQUIP_UPPERBODY,w_resId+params[PLAYER_SEX]*100000)
    self.enemyBody = self:makeMainRole(px,py,"role/".. w_resId,3,false,objid,params)
    self.enemyBody_objid = objid
    if params[PLAYER_EQUIP_WEAPON] > 0 then
        local w_resId = MpropOp.equipResId(params[PLAYER_EQUIP_WEAPON])
        w_resId = G_ROLE_MAIN:getRightResID(PLAYER_EQUIP_WEAPON ,w_resId)
        local w_path = "weapon/" .. (w_resId)
        G_ROLE_MAIN:setEquipment_ex(self.enemyBody,PLAYER_EQUIP_WEAPON,w_path)
    end
    if params[PLAYER_EQUIP_WING] > 0 then
        local w_resId = getConfigItemByKey("WingCfg","q_ID",params[PLAYER_EQUIP_WING] ,"q_senceSouceID")
        if w_resId then
            w_resId = G_ROLE_MAIN:getRightResID(PLAYER_EQUIP_WING,w_resId+100000)
            local w_path = "wing/" .. (w_resId)
            G_ROLE_MAIN:setEquipment_ex(self.enemyBody,PLAYER_EQUIP_WING,w_path)
        end
    end
    if entity[ROLE_MOVE_SPEED] then
        self.enemyBody:setSpeed(0.45/(entity[ROLE_MOVE_SPEED]/100))
    else
        self.enemyBody:setSpeed(0.45)
    end
    self.enemyBody:standed()

end

function JjcMapLayer:jjcUpdate()
    if not self.has_loadmap then return end
	self.updata_time = self.updata_time + 1
	if self.updata_time >= 10000 then
		self.updata_time = 0
	end
	self.timeToBegin = self.timeToBegin - 1
    
    if self.timeToBegin > 0 then
        self.timeLab:setTexture("res/component/number/"..20+self.timeToBegin..".png")
        self.timeLab:setScale(0.7)
      --  timeLab:setScale(4.0)
        local actions = {}
        --actions[#actions+1] = cc.Show:create()
        actions[#actions+1] = cc.MoveTo:create(0.1,cc.p(g_scrSize.width/2,400))
        actions[#actions+1] = cc.ScaleTo:create(0.2,1)
        actions[#actions+1] = cc.FadeOut:create(0.1)--cc.DelayTime:create(0.5)
        --actions[#actions+1] = cc.Hide:create()
        actions[#actions+1] = cc.MoveTo:create(0.0,cc.p(g_scrSize.width/2,780))
        actions[#actions+1] = cc.FadeIn:create(0.1)
        actions[#actions+1] = cc.ScaleTo:create(0.0,0.7)
        self.timeLab:runAction(cc.Sequence:create(actions))
    elseif self.timeToBegin == 0 then
        if self.blackLayer then
            removeFromParent(self.blackLayer)
            self.blackLayer = nil
        end
        self.timeLab:setPosition(cc.p(g_scrSize.width/2,780))
        AudioEnginer.playEffect("sounds/uiMusic/ui_pk.mp3", false)
        self.timeLab:setTexture("res/jjc/toFight.png")
        self.timeLab:setScale(0.7)
        self.timeLab:runAction(cc.Sequence:create(cc.MoveTo:create(0.1,cc.p(g_scrSize.width/2,400)),cc.ScaleTo:create(0.2,1),cc.FadeOut:create(0.1)))
    else
    	if self.timeToBegin == -1 then
            if self.timeLab then
                removeFromParent(self.timeLab)
                self.timeLab = nil
            end
    		game.setAutoStatus(AUTO_ATTACK)
            --self.timeLab1:setPosition(cc.p(g_scrSize.width-400,g_scrSize.height - 90 ))
    	end
        if 60+self.timeToBegin >= 0 and not self.isover then
            if self.timeLab2 then
                -- removeFromParent(self.timeLab2)
                -- self.timeLab2 = nil
                self.timeLab2:setString(tostring(60+self.timeToBegin))
            end
            -- self.timeLab2 = MakeNumbers:create("res/component/number/13.png",28+self.timeToBegin,-1)
            -- if 28 + self.timeToBegin < 10 then
            --     self.timeLab2:setPosition(cc.p(115,125))
            -- else
            --     self.timeLab2:setPosition(cc.p(100,125))
            -- end
            -- self.timeLab2:setScale(1.3)
            -- self.scoreBoard:addChild(self.timeLab2)
            if 60+self.timeToBegin == 0 then
            ----    g_msgHandlerInst:sendNetDataByFmtExEx(SINPVP_CS_TIMEOVER, "i", G_ROLE_MAIN.obj_id)
            end
        else
             -- self.timeLab1:setVisible(false)
             -- self.timeLab2:setVisible(false)
             self.timeLab2:setString(game.getStrByKey("jjc_over"))
             self.timeLab2:setScale(0.6)    
             if self.scheduler and self.schedulerHandle then
                self.scheduler:unscheduleScriptEntry(self.schedulerHandle)
                self.scheduler = nil
            end         
             -- self.timeLab1:setPosition(cc.p(cc.p(117,150)))
        end
        if not self.isover then
    		if self.updata_time  > 2 then
    			self:onRoleAttack()
    		end
        end

        if G_ROLE_MAIN then
            local a_state = G_ROLE_MAIN:getCurrActionState()
            if a_state == ACTION_STATE_IDLE then
                G_ROLE_MAIN:standed()
            end
        end
	end
end

function JjcMapLayer:isInSafeArea()
	return false
end

function JjcMapLayer:showOverView()
    self.isover = true
    self.timeDown = 10
    self.enemyBody = nil
	self.result_node = cc.Node:create()
	self.parent:addChild(self.result_node,190)
    local str,str2 = "win",game.getStrByKey("sure")
    if not self.isWin then
        str = "fail"
        AudioEnginer.playEffect("sounds/uiMusic/ui_lose.mp3", false)
    else
        AudioEnginer.playEffect("sounds/uiMusic/ui_win.mp3", false) 
    end
    -- self.timeLab2:setVisible(false)
    self.timeLab2:setString(game.getStrByKey("jjc_over"))
    self.timeLab2:setScale(0.6)
    -- self.timeLab1:setPosition(cc.p(cc.p(117,150)))
    local colorbg = cc.LayerColor:create(cc.c4b(0, 0, 0, 200))
    self.result_node:addChild(colorbg)
    colorbg:setLocalZOrder(10000)
    
    local overView = cc.Layer:create()
    overView:setContentSize(cc.size(960, 640))
    overView:setPosition(cc.p(g_scrSize.width/2, g_scrSize.height/2))
    overView:ignoreAnchorPointForPosition(false)
    overView:setAnchorPoint(cc.p(0.5, 0.5))
    self.result_node:addChild(overView, 10000)

    local resultTitle = function()
        local resultBg = cc.Node:create()
        overView:addChild(resultBg)
        self.resultBg = resultBg
        --local result = createSprite(resultBg,"res/fb/"..str..".png",cc.p(490,300),cc.p(0.5,0.5))
        if not self.isWin then
            --result:runAction(cc.MoveTo:create(0.3,cc.p(490,550)))            
            local anim = Effects:create(false)
            anim:playActionData("jjcFail",15,2,1)
            anim:setPosition(cc.p(490,550))
            resultBg:addChild(anim) 
            performWithDelay(anim,function() removeFromParent(anim) anim = nil end,2)           
        else
            --result:runAction(cc.Sequence:create(cc.EaseElasticOut:create(cc.MoveTo:create(0.6,cc.p(490,550)))))
            local anim = Effects:create(false)
            anim:playActionData("jjcWin",13,2,1)
            anim:setPosition(cc.p(490,559))
            resultBg:addChild(anim)
            performWithDelay(anim,function() removeFromParent(anim) anim = nil end,2)
        end
        return 0.6
    end
    local smallBg = function()
        createSprite(overView,"res/jjc/"..str.."Bg.png",cc.p(485,330),cc.p(0.5,0.5))
        return 0.5
    end
    local mark = function()
        --createLabel(overView, game.getStrByKey("get_prize"), cc.p(380,200), nil, 30):setColor(MColor.yellow)
        local markBg = cc.Node:create()
        overView:addChild(markBg)
        createSprite(markBg,"res/jjc/getAward.png",cc.p(380,200))
        local DropOp = require("src/config/DropAwardOp")
        local awardsConfig = DropOp:dropItem_ex(self.prizeId)
        --local awardsConfig = getConfigItemByKeys("DropAward", {"q_id", "q_item", })[self.prizeId]
        local startX = 540
        local i = 1
        for k , v in pairs( awardsConfig ) do
            -- local iconBtn = iconCell( { parent = overView , isTip = true , num = { value = 1 } , tag = index , iconID = tonumber( v.q_item ) } )
            -- local iconBtnSize = iconBtn:getContentSize()
            -- setNodeAttr( iconBtn , cc.p( startX + ( i - 1 ) * 85   , 180 + iconBtnSize.height/2 ) , cc.p( 0.5 , 0.5 ) )
            local Mprop = require "src/layers/bag/prop"
            local icon = Mprop.new(
            {
                protoId = tonumber(v.q_item),
                num = tonumber(v.q_count),
                swallow = true,
                cb = "tips",
                showBind = true,
                isBind = tonumber(v.bdlx or 0) == 1,                
            })
            icon:setPosition(cc.p(startX +(i-1)*80,200))
            markBg:addChild(icon)
            i = i+1
        end
        if not self.isWin then
            local failPic = cc.Sprite:createWithSpriteFrameName("jjcFail/00015.png")
            if failPic then
                failPic:setAnchorPoint(cc.p(0.5,0.5))
                failPic:setPosition(cc.p(490,550))
                self.resultBg:addChild(failPic)
            end
            createLabel(markBg,game.getStrByKey("jjc_tip"),cc.p(500,410),cc.p(0.5,0.5),26,true,nil,nil,MColor.label_gray)        
            local lab = createSprite(markBg,"res/jjc/currArr.png",cc.p(380,300))
            createLabel(markBg,G_JJC_INFO[1][1],cc.p(350+lab:getContentSize().width,280),cc.p(0,0),40,true,nil,nil,MColor.yellow)        
            return 1
        end
        if self.historyRank > self.newRank then
                        --createSprite(overView,"res/group/currency/4.png",cc.p(360,95)):setScale(0.66)
            local prizeNum = 0
                local m=0
                local n=0
                local prizeData = require("src/config/JJCPrize")
                for x=1,#prizeData do
                    if m~=0 and n~=0 then
                        break
                    end
                    if prizeData[x] then
                        if (m==0) and (self.newRank >= tonumber(prizeData[x].q_pmmin)) and (self.newRank <= tonumber(prizeData[x].q_pmmax)) then
                            m=x
                        end
                        if (n==0) and (self.historyRank >= tonumber(prizeData[x].q_pmmin)) and (self.historyRank <= tonumber(prizeData[x].q_pmmax)) then
                            n=x
                        end
                    end
                end
                if m==0 then m=9 end
                if n==0 then n=9 end
                local old,new = self.historyRank,self.newRank
                cclog("m"..m.."n"..n)
                if m==n then
                    prizeNum = (old-new)*tonumber(prizeData[m].q_tsjl)
                else
                    for x=m,n do
                        if prizeData[x] then
                            if x ~= m and x ~= n then
                                prizeNum = prizeNum+(tonumber(prizeData[x].q_pmmax)-tonumber(prizeData[x].q_pmmin))*tonumber(prizeData[x].q_tsjl)
                            elseif x == m then
                                prizeNum = prizeNum+(tonumber(prizeData[x].q_pmmax)-new)*tonumber(prizeData[x].q_tsjl)
                            elseif x == n then
                                prizeNum = prizeNum+(old-tonumber(prizeData[x].q_pmmin))*tonumber(prizeData[x].q_tsjl)
                            end
                        end
                    end
                end

            prizeNum = math.ceil(prizeNum)
            --lab = createLabel(overView, tostring(prizeNum), cc.p(390,95), cc.p(0.0,0.5), 20)
            local Mprop = require "src/layers/bag/prop"
            local icon = Mprop.new(
            {
                protoId = tonumber(888888),
                num = tonumber(prizeNum),
                swallow = true,
                cb = "tips",
            })
            icon:setPosition(cc.p(startX +(i-1)*80,200))
            if prizeNum ~= 0 then
                markBg:addChild(icon)
            end
            i = i+1
            --lab:setColor(MColor.brown)
        end
        local anim1 = Effects:create(false)
        anim1:playActionData("jjcWinLoop",8,2,-1,1)
        anim1:setPosition(cc.p(490,583))
        self.resultBg:addChild(anim1)
        createLabel(markBg,tostring(MRoleStruct:getAttr(ROLE_NAME)).."         "..game.getStrByKey("combat_power").."："..tostring(MRoleStruct:getAttr(PLAYER_BATTLE)),cc.p(650,460),cc.p(1,0.5),24,true,nil,nil,MColor.yellow)
        createSprite(markBg,"res/jjc/vs.png",cc.p(490,410))
        createLabel(markBg,tostring(G_JJC_INFO[1][2]).."         "..game.getStrByKey("combat_power").."："..tostring(G_JJC_INFO[1][3]),cc.p(650,360),cc.p(1,0.5),24,true,nil,nil,MColor.yellow)

        local lab = createSprite(markBg,"res/jjc/currArr.png",cc.p(380,300))

        local num = createLabel(markBg,self.newRank,cc.p(350+lab:getContentSize().width,280),cc.p(0,0),40,true,nil,nil,MColor.yellow)
        
        if self.historyRank - self.newRank > 0 then
            createSprite(markBg,"res/jjc/up.png",cc.p(400+lab:getContentSize().width+num:getContentSize().width,305),cc.p(0.5,0.5))
            createLabel(markBg, ""..(self.historyRank - self.newRank) , cc.p(420+lab:getContentSize().width+num:getContentSize().width,300), cc.p(0.0,0.5), 25,true)
        end
        return 1
    end
    local btn = function()
        local btnBg = cc.Node:create()
        overView:addChild(btnBg)
        local item = createMenuItem(btnBg, "res/component/button/50.png", cc.p(490,80), function() removeFromParent(colorbg) removeFromParent(self.result_node) self:readyToLeave() end)
        local countDownLabel = createLabel(item,string.format(game.getStrByKey("jjc_countdown"),self.timeDown),cc.p(item:getContentSize().width/2+5,-20),cc.p(0.5,0.5),22,true,5,nil,MColor.yellow_gray)
        local function countDownFunc()
            self.timeDown = self.timeDown - 1
            if self.timeDown <= 0 then
                removeFromParent(colorbg)
                removeFromParent(self.result_node)
                self:readyToLeave()
            else
                countDownLabel:setString(string.format(game.getStrByKey("jjc_countdown"),self.timeDown))
            end
        end
        startTimerAction(btnBg, 1, true, countDownFunc)
        createLabel(item, str2, cc.p(item:getContentSize().width/2,item:getContentSize().height/2), nil, 23,true)
        return 0.5
    end
    local view1 = function()
        if self.isWin then--and self.historyRank > self.newRank then
            local view1Bg = cc.Node:create()
            overView:addChild(view1Bg)
            local newCode = createSprite(view1Bg,"res/jjc/newCode.png",cc.p(300,450),nil,20,6)
            newCode:runAction(cc.ScaleTo:create(0.2,1)) 
        end
        
        return 0.5
    end

    local index = 1
    local actions = {}
    local funcTab = {smallBg,resultTitle, mark, btn, view1}

    local loopFunc = nil
    loopFunc = function()
        if funcTab[index] ~= nil then
            local time = funcTab[index]()
            index = index + 1
            actions = {}
            if time ~= 0 then
                actions[#actions + 1] = cc.DelayTime:create(time)
            end
            actions[#actions + 1] = cc.CallFunc:create(loopFunc)
            overView:runAction(cc.Sequence:create(actions))
        end
    end
    overView:runAction(cc.CallFunc:create(loopFunc))

    local  listenner = cc.EventListenerTouchOneByOne:create()
    listenner:setSwallowTouches(true)
    listenner:registerScriptHandler(function(touch, event)
                                         return true 
                                     end,cc.Handler.EVENT_TOUCH_BEGAN)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, self.result_node)

    --self:historyHigh(overView)
end

function JjcMapLayer:readyToLeave()
    if self.exitButtonTxt then
        local time = 6
        local function countDownFunc()
            time = time - 1
            if time <= 0 then
                self:exit()
            else
                self.exitButtonTxt:setString(game.getStrByKey("exit").."  ("..time..")")
            end
        end
        if self.isWin then
            startTimerAction(self.exit_menu, 1, true, countDownFunc)
        else
            self:exit()
        end
    end
end

function JjcMapLayer:historyHigh()
    -- userInfo.jjcData.historyRank = 9999
    -- self.newRank = 1
    --if userInfo.jjcData.historyRank > 2000 then userInfo.jjcData.historyRank = 2000 end
    
    if self.historyRank > self.newRank then

        local colorbg = cc.LayerColor:create(cc.c4b(0, 0, 0, 150))
        self.result_node:addChild(colorbg)
        colorbg:setLocalZOrder(10001)
        local historyBg = createSprite(self.result_node,"res/jjc/history.png",cc.p(g_scrSize.width/2, g_scrSize.height/2+40),cc.p(0.5,0.5),10001)
        local lab = createLabel(historyBg, game.getStrByKey("history_rank"), cc.p(240,275), cc.p(0.0,0.5), 20)
        lab:setColor(MColor.yellow)
        --lab = createLabel(historyBg, tostring(userInfo.jjcData.historyRank) , cc.p(245+lab:getContentSize().width,275), cc.p(0.0,0.5), 20)
        local num = MakeNumbers:create("res/component/number/1.png",self.historyRank,-2)
        num:setPosition(cc.p(245+lab:getContentSize().width,275))
        historyBg:addChild(num)

        lab = createLabel(historyBg, game.getStrByKey("curr_rank"), cc.p(240,235), cc.p(0.0,0.5), 20)
        lab:setColor(MColor.yellow)
        local num = MakeNumbers:create("res/component/number/1.png",self.newRank,-2)
        num:setPosition(cc.p(245+lab:getContentSize().width,235))
        historyBg:addChild(num)
        createSprite(historyBg,"res/jjc/up.png",cc.p(430,235),cc.p(0.5,0.5))
        lab = createLabel(historyBg, ""..(self.historyRank - self.newRank) , cc.p(445,235), cc.p(0.0,0.5), 20)

        lab = createLabel(historyBg, game.getStrByKey("get_prize"), cc.p(240,195), cc.p(0.0,0.5), 20)
        lab:setColor(MColor.yellow)
        --createSprite(historyBg,"res/jjc/prizeIcon.png",cc.p(360,195),cc.p(0.5,0.5))
        createSprite(historyBg,"res/group/currency/4.png",cc.p(360,195)):setScale(0.66)

        local prizeNum = 0
        --local calc = function()
            local m=0
            local n=0
            local prizeData = require("src/config/JJCPrize")
            for x=1,#prizeData do
                if m~=0 and n~=0 then
                    break
                end
                if prizeData[x] then
                    if (m==0) and (self.newRank >= tonumber(prizeData[x].q_pmmin)) and (self.newRank <= tonumber(prizeData[x].q_pmmax)) then
                        m=x
                    end
                    if (n==0) and (self.historyRank >= tonumber(prizeData[x].q_pmmin)) and (self.historyRank <= tonumber(prizeData[x].q_pmmax)) then
                        n=x
                    end
                end
            end
            if m==0 then m=9 end
            if n==0 then n=9 end
            local old,new = self.historyRank,self.newRank
            cclog("m"..m.."n"..n)
            if m==n then
                prizeNum = (old-new)*tonumber(prizeData[m].q_tsjl)
            else
                for x=m,n do
                    if prizeData[x] then
                        if x ~= m and x ~= n then
                            prizeNum = prizeNum+(tonumber(prizeData[x].q_pmmax)-tonumber(prizeData[x].q_pmmin))*tonumber(prizeData[x].q_tsjl)
                        elseif x == m then
                            prizeNum = prizeNum+(tonumber(prizeData[x].q_pmmax)-new)*tonumber(prizeData[x].q_tsjl)
                        elseif x == n then
                            prizeNum = prizeNum+(old-tonumber(prizeData[x].q_pmmin))*tonumber(prizeData[x].q_tsjl)
                        end
                    end
                end
            end
        --end

        prizeNum = math.ceil(prizeNum)
        lab = createLabel(historyBg, tostring(prizeNum), cc.p(390,195), cc.p(0.0,0.5), 20)
        lab:setColor(MColor.brown)
        createLabel(historyBg, game.getStrByKey("prize_send_by_mail"), cc.p(364,140), cc.p(0.5,0.5), 20)

        local item = createMenuItem(historyBg, "res/component/button/50.png", cc.p(364,80), function() removeFromParent(historyBg) removeFromParent(colorbg) end)
        createLabel(item, game.getStrByKey("sure"), cc.p(61.5,29.5), nil, 20,true)--:setColor(MColor.lable_yellow)
    end
end

return JjcMapLayer