local JJCBattleView = class("JJCBattleView", require("src/base/MapBaseLayer"))

local comPath = "res/jjc/"
local timeToBegin,timeLab,countingTimer

function JJCBattleView:ctor(strname,parent,r_pos,mapId,enemyInfo,isWin,prizeId,newRank)
	local addSprite = createSprite
	local addLabel = createLabel
	local bg = addSprite(self,comPath.."wst.jpg",g_scrCenter)
	self.bg = bg
    self.enemyInfo = enemyInfo
    self.isWin = isWin
    self.prizeId = prizeId
    self.newRank = newRank
    self.item_Node = cc.Node:create()
    self:addChild(self.item_Node)
    --self.hurt_num_count = 0
    local s = bg:getContentSize()
    if g_scrSize.width > s.width or g_scrSize.height > s.height then
        local scale = math.max(g_scrSize.width/s.width, g_scrSize.height/s.height)
        bg:setScale(scale)
    end
    self:addPlayer()
    timeToBegin = 4
    timeLab = addLabel(self, tostring(timeToBegin), cc.p(g_scrSize.width/2,780), cc.p(0.5,0.5),56,true,nil,nil,MColor.red)
    self:timeCounting()
    countingTimer = schedule(self, function () self:timeCounting() end,1.0)


    local MRoleStruct = require("src/layers/role/RoleStruct")
    local myBattle = MRoleStruct:getAttr(PLAYER_BATTLE)
    if isWin then
        local forceScale = myBattle/self.enemyInfo[6]
        local round
        if forceScale <= 1.0 then
            round = 10
        elseif forceScale <= 1.2 then
            round = 9
        elseif forceScale <= 1.4 then
            round = 8
        elseif forceScale <= 1.6 then
            round = 7
        elseif forceScale <= 1.8 then
            round = 6
        elseif forceScale <= 2.4 then
            round = 5
        elseif forceScale <= 2.4 then
            round = 4
        elseif forceScale <= 3.0 then
            round = 3
        elseif forceScale <= 4.0 then
            round = 2
        elseif forceScale > 4.0 then
            round = 1
        end

        self.attackNum = math.ceil(self.enemyInfo[10]/round)
        self.beHurtedNum = math.floor(self.myBlood/15)
    else
        local forceScale = self.enemyInfo[6]/myBattle
        local round
        if forceScale <= 1.0 then
            round = 10
        elseif forceScale <= 1.2 then
            round = 9
        elseif forceScale <= 1.4 then
            round = 8
        elseif forceScale <= 1.6 then
            round = 7
        elseif forceScale <= 1.8 then
            round = 6
        elseif forceScale <= 2.4 then
            round = 5
        elseif forceScale <= 2.4 then
            round = 4
        elseif forceScale <= 3.0 then
            round = 3
        elseif forceScale <= 4.0 then
            round = 2
        elseif forceScale > 4.0 then
            round = 1
        end
        self.attackNum = math.floor(self.enemyInfo[10]/15)
        self.beHurtedNum = math.ceil(self.myBlood/round)
    end
    self:initTouch()
 --    g_msgHandlerInst:sendNetDataByFmtExEx(SINPVP_CS_OPENPVP,"ic",userInfo.currRoleId,1)
	local msgids = {FRAME_SC_PROP_UPDATE}
    require("src/MsgHandler").new(self,msgids)

end

function JJCBattleView:initTouch() 
	local  listenner = cc.EventListenerTouchOneByOne:create()
    listenner:setSwallowTouches(true)
    listenner:registerScriptHandler(function(touch, event)
     		return true
        end,cc.Handler.EVENT_TOUCH_BEGAN)  
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner,self)
end

function JJCBattleView:addPlayer()
    local params={}
    local myStruct = require("src/layers/role/RoleStruct")
    self.myBlood = myStruct:getAttr(ROLE_MAX_HP)
    params[ROLE_SCHOOL] = myStruct:getAttr(ROLE_SCHOOL)
    self.mySchool = params[ROLE_SCHOOL]
    params[PLAYER_SEX] = myStruct:getAttr(PLAYER_SEX)
    self.mySex = params[PLAYER_SEX]
    params[ROLE_HP] = self.myBlood
    params[ROLE_MAX_HP] = self.myBlood
    params[ROLE_NAME] = myStruct:getAttr(ROLE_NAME)
    params[PLAYER_EQUIP_WING] = myStruct:getAttr(PLAYER_EQUIP_WING)

    local MPackStruct = require "src/layers/bag/PackStruct"
    local MPackManager = require "src/layers/bag/PackManager"
    local dress = MPackManager:getPack(MPackStruct.eDress)
    local grid = dress:getGirdByGirdId(MPackStruct.eWeapon)

    if grid then
        params[PLAYER_EQUIP_WEAPON] =  MPackStruct.protoIdFromGird(grid)
    end
    grid = dress:getGirdByGirdId(MPackStruct.eClothing)
    if grid then
        params[PLAYER_EQUIP_UPPERBODY] =  MPackStruct.protoIdFromGird(grid)
    end
    self.h = 290/640*g_scrSize.height
    self.me = createSceneRoleNode(params)
    self.me:initStandStatus(4,6,1.0,0)
    self.me:standed()
    self.me:showNameAndBlood(true,100)
    self.me:setPosition(cc.p(g_scrSize.width/2-230,self.h))
    self.me:setScale(1.3)
    self.item_Node:addChild(self.me)
    self.me:walkToPos(0.8,cc.p(g_scrSize.width/2-70,self.h))


    params={}
    params[ROLE_SCHOOL] = self.enemyInfo[4]
    params[PLAYER_SEX] = self.enemyInfo[5]
    --if self.enemyInfo[4] == 2 then params[PLAYER_SEX] = 2 end
    self.enemyBlood = self.enemyInfo[10]
    params[ROLE_HP] = self.enemyInfo[10]
    params[ROLE_MAX_HP] = self.enemyInfo[10]
    params[ROLE_NAME] = self.enemyInfo[3]
    params[PLAYER_EQUIP_WEAPON] = self.enemyInfo[7]
    params[PLAYER_EQUIP_UPPERBODY] = self.enemyInfo[8]
    params[PLAYER_EQUIP_WING] = self.enemyInfo[9]
    self.enemy = createSceneRoleNode(params)
    self.enemy:initStandStatus(4,6,1.0,4)
    self.enemy:standed()
    self.enemy:showNameAndBlood(true,100)
    self.enemy:setPosition(cc.p(g_scrSize.width/2+230,self.h))
    self.enemy:setScale(1.3)
    self.item_Node:addChild(self.enemy)
    self.enemy:walkToPos(0.8,cc.p(g_scrSize.width/2+70,self.h))
end

function JJCBattleView:attack()
    local skills= {
                    {1006,1003},
                    {2004,2002},
                    {3004,3002},
                }
    local myPos,enemyPos = nil,nil
    if self.me and self.enemy then
        myPos = cc.p(self.me:getPosition())
        enemyPos = cc.p(self.enemy:getPosition())
    end
    local attackIndex = 2
    if timeToBegin==-1 then
        attackIndex = 1
    end


    --被攻击
     local effectTargetPos = myPos
    if self.enemyInfo[4] == 1 then
        self.enemy:attackToPos(0.4,myPos)
    else
        if self.enemyInfo[4] == 3 then
            effectTargetPos.y = effectTargetPos.y + 40
        end
        self.enemy:magicUpToPos(0.4,myPos)
    end
    self:playSkillEffect(0.4,skills[self.enemyInfo[4]][attackIndex],self.enemy,self.me,nil,true)

    if skills[self.enemyInfo[4]][attackIndex] then
        local temp1 = skills[self.enemyInfo[4]][attackIndex]
        AudioEnginer.randSkillMusic(temp1,true)
    end

    if skills[self.enemyInfo[4]][attackIndex] ~= 2004 then
        self:showHurtNumer(self.beHurtedNum,myPos,enemyPos,0.5,3)
        self.me:subBlood(self.beHurtedNum)
        self.myBlood = self.myBlood-self.beHurtedNum
    else 
        local skill_effect = Effects:create(false)
        skill_effect:playActionData("skill2004",5,1,-1)
        self.enemy:addChild(skill_effect,20,80)
    end

     --主动攻击
    effectTargetPos = enemyPos
    if self.mySchool == 1 then
        self.me:attackToPos(0.4,enemyPos)
    else
        if self.mySchool == 3 then
            effectTargetPos.y = effectTargetPos.y + 40
        end
        self.me:magicUpToPos(0.4,enemyPos)
    end
    self:playSkillEffect(0.4,skills[self.mySchool][attackIndex],self.me,self.enemy,nil,true)

    if skills[self.mySchool][attackIndex] then
        local  temp2 = skills[self.mySchool][attackIndex]
        AudioEnginer.randSkillMusic(temp2,true)
    end

    if skills[self.mySchool][attackIndex] ~= 2004 then
        self:showHurtNumer(self.attackNum,enemyPos,myPos,0.5,3)
        self.enemy:subBlood(self.attackNum)
        self.enemyBlood = self.enemyBlood-self.attackNum
    else 
        local skill_effect = Effects:create(false)
        skill_effect:playActionData("skill2004",5,1,-1)
        self.me:addChild(skill_effect,20,80)
    end
    if self.myBlood <= 0 or self.enemyBlood <= 0 then
        local MRoleStruct = require("src/layers/role/RoleStruct")
        local my_sex = MRoleStruct:getAttr(PLAYER_SEX)
        performWithDelay(self,function() self:over() end,0.5)
        if self.enemyBlood <= 0 then
            if self.enemyInfo[5] and self.enemyInfo[5] == 2 then
                AudioEnginer.playEffect("sounds/actionMusic/103.mp3",false)
            elseif self.enemyInfo[5] and self.enemyInfo[5] == 1 then
                AudioEnginer.playEffect("sounds/actionMusic/3.mp3",false)
            end
        elseif self.myBlood <= 0 then
            if my_sex == 2 then
                AudioEnginer.playEffect("sounds/actionMusic/103.mp3",false)
            elseif my_sex == 1 then
                AudioEnginer.playEffect("sounds/actionMusic/3.mp3",false)
            end
        end
    end
end

function JJCBattleView:exit()
    g_msgHandlerInst:sendNetDataByTableExEx(SINPVP_CS_EXITPVP,"SinpvpExitPvpProtocol",{})
    addNetLoading(SINPVP_CS_EXITPVP,FRAME_SC_ENTITY_ENTER)                                                                                                                                                                                                                                             
end

function JJCBattleView:showOverView()
    local str,str2,str3 = "win",game.getStrByKey("exit"),game.getStrByKey("jjc_rank_new")
    if not self.isWin then
        str = "fail"
        str3 = game.getStrByKey("jjc_rank_old")
    end
    local colorbg = cc.LayerColor:create(cc.c4b(0, 0, 0, 150))
    self:addChild(colorbg)
    colorbg:setLocalZOrder(10000)
    local overView = createSprite(self,"res/fb/"..str.."Bg.png",g_scrCenter,cc.p(0.5,0.5),10000)
    createSprite(overView,"res/fb/"..str..".png",cc.p(480,550),cc.p(0.5,0.5),10000)
    local item = createMenuItem(overView, "res/component/button/50.png", cc.p(480,45), function() self:exit() end)
    createLabel(item, str2, cc.p(61.5,29.5), nil, 20,true)
    createLabel(overView, str3..":"..self.newRank, cc.p(480,340), nil, 20):setColor(MColor.yellow)
    createLabel(overView, game.getStrByKey("get_prize"), cc.p(280,270), nil, 18):setColor(MColor.yellow)
    local DropOp = require("src/config/DropAwardOp")
    local awardsConfig = DropOp:dropItem_ex(self.prizeId)
    --local awardsConfig = getConfigItemByKeys("DropAward", {"q_id", "q_item", })[self.prizeId]
    local startX = 480-42.5*tablenums(awardsConfig)+42.5
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
        icon:setPosition(cc.p(startX +(i-1)*80,220))
        overView:addChild(icon)
        i = i+1
    end

    -- local  listenner = cc.EventListenerTouchOneByOne:create()
    -- listenner:setSwallowTouches(true)
    -- listenner:registerScriptHandler(function(touch, event)
    --                                     return true 
    --                                 end,cc.Handler.EVENT_TOUCH_BEGAN)
    -- local eventDispatcher = self:getEventDispatcher()
    -- eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, self.overView)

    self:historyHigh(overView)
end

function JJCBattleView:historyHigh()
    -- userInfo.jjcData.historyRank = 9999
    -- self.newRank = 1
    --if userInfo.jjcData.historyRank > 2000 then userInfo.jjcData.historyRank = 2000 end
    
    if userInfo.jjcData.historyRank > self.newRank then

        local colorbg = cc.LayerColor:create(cc.c4b(0, 0, 0, 150))
        self:addChild(colorbg)
        colorbg:setLocalZOrder(10001)
        local historyBg = createSprite(self,"res/jjc/history.png",cc.p(g_scrSize.width/2, g_scrSize.height/2+40),cc.p(0.5,0.5),10001)
        local lab = createLabel(historyBg, game.getStrByKey("history_rank"), cc.p(240,275), cc.p(0.0,0.5), 20)
        lab:setColor(MColor.yellow)
        --lab = createLabel(historyBg, tostring(userInfo.jjcData.historyRank) , cc.p(245+lab:getContentSize().width,275), cc.p(0.0,0.5), 20)
        local num = MakeNumbers:create("res/component/number/1.png",userInfo.jjcData.historyRank,-2)
        num:setPosition(cc.p(245+lab:getContentSize().width,275))
        historyBg:addChild(num)

        lab = createLabel(historyBg, game.getStrByKey("curr_rank"), cc.p(240,235), cc.p(0.0,0.5), 20)
        lab:setColor(MColor.yellow)
        local num = MakeNumbers:create("res/component/number/1.png",self.newRank,-2)
        num:setPosition(cc.p(245+lab:getContentSize().width,235))
        historyBg:addChild(num)
        createSprite(historyBg,"res/jjc/up.png",cc.p(430,235),cc.p(0.5,0.5))
        lab = createLabel(historyBg, ""..(userInfo.jjcData.historyRank - self.newRank) , cc.p(445,235), cc.p(0.0,0.5), 20)

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
                    if (n==0) and (userInfo.jjcData.historyRank >= tonumber(prizeData[x].q_pmmin)) and (userInfo.jjcData.historyRank <= tonumber(prizeData[x].q_pmmax)) then
                        n=x
                    end
                end
            end
            if m==0 then m=9 end
            if n==0 then n=9 end
            local old,new = userInfo.jjcData.historyRank,self.newRank
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

function JJCBattleView:over()
   -- cc.Director:getInstance():getScheduler():unscheduleScriptEntry(countingTimer)
    if countingTimer then
        self:stopAction(countingTimer)
        countingTimer = nil
    end
    local dir = 7
    if self.isWin then
        if self.enemyInfo[5]==2 then
            dir = 6
            self.enemy:removeChildByTag(80)
            --self:playSkillEffect(0.0,2004,self.enemy,cc.p(0,0),false)
        end
        self.enemy:gotoDeath(dir)
    else
        if self.mySex==2 then
            dir = 6
            self.me:removeChildByTag(80)
            --self:playSkillEffect(0.0,2004,self.me,cc.p(0,0),false)
        end
        self.me:gotoDeath(dir)
    end
    performWithDelay(self,function() self:showOverView() end,0.5)
    
end

function JJCBattleView:timeCounting()
    timeToBegin = timeToBegin - 1
    cclog("timeToBegin"..timeToBegin)
    if timeToBegin >= 0 then
        timeLab:setString(tostring(timeToBegin))
      --  timeLab:setScale(4.0)
      local actions = {}
      actions[#actions+1] = cc.Show:create()
      actions[#actions+1] = cc.MoveTo:create(0.2,cc.p(g_scrSize.width/2,580))
      actions[#actions+1] = cc.DelayTime:create(0.5)
      actions[#actions+1] = cc.Hide:create()
      actions[#actions+1] = cc.MoveTo:create(0.0,cc.p(g_scrSize.width/2,780))
      timeLab:runAction(cc.Sequence:create(actions))
    elseif timeToBegin < 0 then
        self:attack()
    end

end

function JJCBattleView:networkHander(luabuffer,msgid)
	cclog("JJCBattleView:networkHander")
    local switch = {
        [FRAME_SC_PROP_UPDATE] = function() 
            local objId,attrNum = luabuffer:readByFmt("is")
            local MRoleStruct = require("src/layers/role/RoleStruct")
            for i=1,attrNum do
                local id = luabuffer:popChar()
                cclog("prop id:"..id)
                cclog("PLAYER_HONOUR"..PLAYER_HONOUR)
                cclog("PLAYER_MERITORIOUS"..PLAYER_MERITORIOUS)
                MRoleStruct:setAttr(id, objId, luabuffer, objId == userInfo.currRoleId, nil)
            end
        end,        
    }

    if switch[msgid] then 
        switch[msgid]()
    end
end

return JJCBattleView