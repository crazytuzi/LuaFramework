local JJCHall = class("JJCHall", function() return cc.Layer:create() end)

local comPath = "res/jjc/"
function JJCHall:ctor(mode)
	local addSprite = createSprite
	local addLabel = createLabel


	local bg = createBgSprite(self,game.getStrByKey("jjc"))
	self.bg = bg
    g_msgHandlerInst:sendNetDataByTableExEx(SINPVP_CS_OPENPVP,"SinpvpOpenProtocol",{single = self.mode, openType = 1})
    addNetLoading(SINPVP_CS_OPENPVP,SINPVP_SC_PVPINFO)
    self.goldNum = 50
    userInfo.lastJJCMode = mode
    self.prizeList = getConfigItemByKey("JJCPrize")
    -- dump(self.prizeList,"111111111111111111111")

    self.mode = (mode==1)
    -- dump(self.mode)
	--顶部
    local bg1 = addSprite(bg,"res/common/bg/bg.png",cc.p(480,285))
    --bg1:setScale(1.15,1)
    --addSprite(bg1,"res/common/bg/bg-6.png",getCenterPos(bg1))
    local listbg = addSprite(bg,"res/common/bg/bg48.png",cc.p(480,285))
    --listbg:setScale(0.99,1.05)
    addLabel(bg, game.getStrByKey("my_rank"),cc.p(105,515), cc.p(0,0.5),22):setColor(MColor.lable_yellow)

    local rankList = function()
        --self.bg:addChild(require("src/layers/jjc/JJCRankList").new(),5)
        local rankLayer = require("src/layers/jjc/JJCRankList").new(self.mode)
        Manimation:transit(
        {
            ref = self.bg,
            node = rankLayer,
            curve = "-",
            sp = cc.p(500,520),
            ep = cc.p(480,320),
            zOrder = 20,
            swallow = true,
        })
    end

	local btnPosX = 420
	local btnPosY = 502
	local btnSpaceX = 170
    local menuitem = createMenuItem(bg,"res/component/button/49.png",cc.p(btnPosX,btnPosY),rankList)
    addLabel(menuitem, game.getStrByKey("rank_list"),getCenterPos(menuitem), cc.p(0.5,0.5),21,true)
    local battleReword = function()
        --self.bg:addChild(require("src/layers/jjc/JJCBattleRecord").new(self.logs),5)
        local battleRewordLayer = require("src/layers/jjc/JJCBattleRecord").new(self.logs)
        Manimation:transit(
        {
            ref = self.bg,
            node = battleRewordLayer,
            curve = "-",
            sp = cc.p(666,520),
            ep = cc.p(480,320),
            zOrder = 20,
            swallow = true,
        })
    end
	btnPosX = btnPosX + btnSpaceX
    menuitem = createMenuItem(bg,"res/component/button/49.png",cc.p(btnPosX,btnPosY),battleReword)
    addLabel(menuitem, game.getStrByKey("battle_record"),getCenterPos(menuitem), cc.p(0.5,0.5),21,true)
    local exchangeReword = function()
        __GotoTarget( {ru = "a59"} )    		
    end
--    menuitem = createMenuItem(bg,"res/component/button/49.png",cc.p(695,502),exchangeReword)
--    addLabel(menuitem, game.getStrByKey("exchange_reword"),getCenterPos(menuitem), cc.p(0.5,0.5),21,true)
	local cleanTime = function()
        if self.btnFunction:getString() == game.getStrByKey("refresh_enemy") then
            g_msgHandlerInst:sendNetDataByTableExEx(SINPVP_CS_OPENPVP,"SinpvpOpenProtocol",{single = self.mode, openType = 2})
            addNetLoading(SINPVP_CS_OPENPVP,SINPVP_SC_OPENPVP)
        -- elseif self.btnFunction:getString() == game.getStrByKey("clean_time") then
        --     g_msgHandlerInst:sendNetDataByFmtExEx(SINPVP_CS_CLEARCD,"bic",self.mode,userInfo.currRoleId)
        --     addNetLoading(SINPVP_CS_CLEARCD,SINPVP_SC_PVPINFO)
        elseif self.btnFunction:getString() == game.getStrByKey("buy_times") then
            local buy = function()
                g_msgHandlerInst:sendNetDataByTableExEx(SINPVP_CS_BUYCOUNT,"SinpvpBuyCountProtocol",{})
                addNetLoading(SINPVP_CS_BUYCOUNT,SINPVP_SC_PVPINFO)
            end
            MessageBoxYesNo(nil,string.format(game.getStrByKey("jjc_buy"),50*self.goldNum+50),buy )
        end
    end
	btnPosX = btnPosX + btnSpaceX
    menuitem = createMenuItem(bg,"res/component/button/49.png",cc.p(btnPosX,btnPosY),cleanTime)
    self.btnFunction = addLabel(menuitem, game.getStrByKey("refresh_enemy"),getCenterPos(menuitem), cc.p(0.5,0.5),21,true)
    --self.btnFunction:setColor(MColor.yellow_gray)
    local combat_power = addLabel(bg, game.getStrByKey("combat_power")..":",cc.p(105,485), cc.p(0,0.5),22)
    combat_power:setColor(MColor.lable_yellow)
    local combat_power_num = addLabel(bg, MRoleStruct:getAttr(PLAYER_BATTLE),cc.p(190,485), cc.p(0.0,0.5),24)
    combat_power_num:setColor(MColor.white)
    
    addLabel(bg, game.getStrByKey("times_left"),cc.p(100,600), cc.p(0.5,0.5),24,true,nil,nil,MColor.lable_yellow)
    self.labTimesLeft = addLabel(bg, "5/5",cc.p(160,600), cc.p(0.0,0.5),26,true,nil,nil,MColor.white)

    self.enemyName={}
    self.enemyPower={}
    self.enemyBtn={}
    self.enemyRank={}
    self.playerNode={}
    self.rankbg = {}
    self.fightPos = {cc.p(710,130),cc.p(390,130),cc.p(70,130)}

    local strs= {game.getStrByKey("high_enemy"),game.getStrByKey("mid_enemy"),game.getStrByKey("low_enemy")}
    local tempColors = {MColor.orange,MColor.blue,MColor.green}
    local challenge = function(tag,sender)
        cclog("challenge")
        for i=1,3 do
            if sender==self.enemyBtn[i] then
                if self.othersInfo and self.othersInfo[i] and self.othersInfo[i][2] then
                    if G_JJC_INFO then
                        G_JJC_INFO = {}
                        table.insert(G_JJC_INFO,{self.rankOfMine,self.othersInfo[i][3],self.othersInfo[i][6]})
                    end
                    self.currSelEnemyIdx = i
                    userInfo.jjcData = self.othersInfo[i]
					local t = {}
					t.targetSID = self.othersInfo[i][2]
					t.targetRank = self.othersInfo[i][1]
                    g_msgHandlerInst:sendNetDataByTableExEx(SINPVP_CS_FIGHTPVP,"SinpvpFightProtocol",t)
                    addNetLoading(SINPVP_CS_FIGHTPVP,SINPVP_SC_FIGHTRESULT)
                    break
                end
            end
        end
    end
    for i=1,3 do
        self.rankbg[i] = addSprite(bg,comPath.."infoBg.png",cc.p(800-(i-1)*320,430),nil,1)
        self.enemyName[i] = addLabel(bg, "",cc.p(800-(i-1)*320,407), cc.p(0.5,0.5),20,true,2)
        self.enemyName[i]:setColor(MColor.lable_yellow)
        self.enemyRank[i] = addLabel(bg,"",cc.p(800-(i-1)*320,433),cc.p(0.5,0.5),20,true,2,nil,MColor.yellow)
        self.enemyPower[i] = self:fightInfo(self.fightPos[i],0)
        self.enemyBtn[i] = createMenuItem(bg,"res/component/button/1.png",cc.p(800-(i-1)*320,75),challenge,1)
        addLabel(self.enemyBtn[i], game.getStrByKey("fb_challege"),getCenterPos(self.enemyBtn[i]), cc.p(0.5,0.5),22,true)--:setColor(MColor.yellow_gray)

        if i==3 then
            G_TUTO_NODE:setTouchNode(self.enemyBtn[i], TOUCH_BATTLE_WEAK)
        end
    end

	local msgids = {SINPVP_SC_PVPINFO,SINPVP_SC_OPENPVP,SINPVP_SC_RANKWRONG}
    require("src/MsgHandler").new(self,msgids)

    self:registerScriptHandler(function(eventType)
        if eventType == "enter" then
            G_TUTO_NODE:setShowNode(self, SHOW_BATTLE)
        elseif eventType == "exit" then
           
        end
    end)
end

function JJCHall:fightInfo(pos,number)
    createSprite(self.bg,comPath.."fightBg.png",cc.p(pos.x,pos.y-5),cc.p(0,0.5),8)
    createSprite(self.bg,"res/common/misc/power_b.png",pos,cc.p(0,0.5),9,0.5)
    local num = number or 0
    local force = MakeNumbers:create("res/component/number/10.png",num,-5)
    local posx1,scale = pos.x+130,0.75
    if num < 1000 then
    elseif num < 10000 then
        posx1 = pos.x+115
    elseif num < 100000 then 
        posx1 = pos.x+115
    elseif num < 1000000 then 
        posx1 = pos.x+115 scale=0.6 
    else
        posx1 = pos.x+115 scale=0.6 
    end
    if force then
        force:setScale(scale)
        force:setPosition(cc.p(posx1-30,pos.y))
        force:setLocalZOrder(10)
        self.bg:addChild(force)
    end
    return force
end


function JJCHall:initTouch() 
    local  listenner = cc.EventListenerTouchOneByOne:create()
    listenner:setSwallowTouches(true)
    listenner:registerScriptHandler(function(touch, event)
        local pt = self.bg:convertTouchToNodeSpace(touch)
        -- print("pt",pt.x)
        for i=1,3 do
            local x,y = self.playerNode[i]:getPosition()
            if math.abs(pt.x-x) <=100 and (pt.y-y) > 0 and (pt.y-y) < 300 then
                self:selectMember(i)
                return true
            end
        end
        return false
        end,cc.Handler.EVENT_TOUCH_BEGAN )
    local eventDispatcher = self.bg:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner,self.bg)
end

function JJCHall:selectMember(index)
    local func = function(tag)
      local switch = {
        [1] = function() 
          LookupInfo(self.othersInfo[index][3])
        end,
        [2] = function()
          AddFriends(self.othersInfo[index][3])
        end,
        [3] = function() 
          AddBlackList(self.othersInfo[index][3])
        end,
        }
    if switch[tag] then switch[tag]() end
      removeFromParent(self.operate)
      self.operate = nil
    end
    local menus = {
      {game.getStrByKey("look_info"),1,func},
      {game.getStrByKey("addas_friend"),2,func},
      {game.getStrByKey("add_blackList"),3,func},
    }
    self.operate =  require("src/OperationLayer").new(G_MAINSCENE,1,menus)
    self.operate:setPosition(cc.p(250*(3-index)-display.cx+350,0))
end

function JJCHall:updateMyInfo(myInfo)
    self.labTimesLeft:setString(""..myInfo[1].."/5")

    if myInfo[1] <= 0 and myInfo[2] < 1 then
        self.btnFunction:setString(game.getStrByKey("buy_times"))

    else
        self.btnFunction:setString(game.getStrByKey("refresh_enemy"))
    end
end

function JJCHall:updateOthersInfo(my_rank)
    for i=1,3 do
        if self.playerNode[i] then
            removeFromParent(self.playerNode[i])
            self.playerNode[i] = nil
        end

        self.enemyName[i]:setString("")
        if self.othersInfo[i] then
            self.enemyName[i]:setString(self.othersInfo[i][3])
            if self.enemyPower[i] then
                removeFromParent(self.enemyPower[i])
                self.enemyPower[i] = nil
                self.enemyPower[i] = self:fightInfo(self.fightPos[i],self.othersInfo[i][6])
            end
            self.enemyRank[i]:setString(string.format(game.getStrByKey("jjc_rank"),self.othersInfo[i][1]))
            self.playerNode[i] = createRoleNode(self.othersInfo[i][4],self.othersInfo[i][8],self.othersInfo[i][7],self.othersInfo[i][9],0.85,self.othersInfo[i][5])
            self.bg:addChild(self.playerNode[i])
            self.playerNode[i]:setPosition(cc.p(800-(i-1)*320,250))
            
        end
    end
    if my_rank then
        if self.myRank then
            removeFromParent(self.myRank)
            self.myRank = nil
        end
        self.myRank = createLabel(self.bg,tostring(my_rank),cc.p(210,515), cc.p(0.0,0.5),24)
        self.myRank:setColor(MColor.white)
        if self.help_prompt then
            removeFromParent(self.help_prompt)
            self.help_prompt = nil
        end
        local str2 = game.getStrByKey("jjc_awardTip").."\n"
        for k,v in pairs(self.prizeList) do
            if v.q_pmmin <= my_rank and v.q_pmmax >= my_rank then
                local award = getConfigItemByKey("JJCPrize","q_pmd",v.q_pmd,"q_award")
                if award then
                    str2 = award.."\n"
                end
                break
            end
        end
        local str1 = str2..game.getStrByKey("jjc_rolecontent")
        self.help_prompt = __createHelp(
        {
            parent = self.bg,
            str = str1,
            pos = cc.p(70, 503),
            title = game.getStrByKey("jjc_role"),
        })
    end
end

function JJCHall:networkHander(luabuffer,msgid)
	cclog("JJCHall:networkHander")
    local switch = {
        [SINPVP_SC_PVPINFO] = function() 
            cclog("SINPVP_SC_PVPINFO")
			local t = g_msgHandlerInst:convertBufferToTable("SinpvpInfoRetProtocol", luabuffer)
            --排名 剩余次数 购买次数 CD iscding 挑战日志
            local myInfo={}
			myInfo[1] = t.fightCnt
			myInfo[2] = t.buyCnt
			myInfo[3] = t.coolTime
			myInfo[4] = t.isCDing
			myInfo[5] = t.fightLog
            self:updateMyInfo(myInfo)
            self.goldNum = myInfo[2]
            local code, logs = pcall(loadstring(string.format("do local _=%s return _ end", myInfo[5])))
            cclog("#"..#logs)
            self.logs = logs
        end,

        [SINPVP_SC_OPENPVP] = function() 
            cclog("SINPVP_SC_OPENPVP")
			local t = g_msgHandlerInst:convertBufferToTable("SinpvpOpenRetProtocol", luabuffer)
            -- dump(G_TIME_INFO,"来的时间时间时间时间时间时间")
            local my_rank = t.curRank
            local otherNum = t.targetNum
            cclog("otherNum"..otherNum)

            self.othersInfo = {}
            for i=1,otherNum do
                --排名 静态ID 名字 职业 性别 战斗力 武器 衣服 翅膀 血量 等级
           --     self.othersInfo[i]={luabuffer:readByFmt("siScciiiiis")}
 				local info = {}
				local j = 1
				for k,v in pairs(t.targetInfo[i]) do
					info[j] = v
					j = j + 1
				end
				self.othersInfo[i] = info
           end
            table.sort( self.othersInfo ,function( a , b ) return a[1] < b[1] end  )
            self.rankOfMine = my_rank
            self:updateOthersInfo(my_rank)
        end,

        [SINPVP_SC_RANKWRONG] = function()
            cclog("SINPVP_SC_RANKWRONG")
			local t = g_msgHandlerInst:convertBufferToTable("SinpvpRankWrongProtocol", luabuffer)
			local info = {}
			local i = 1
			for k,v in pairs(t.targetNewInfo) do
				info[i] = v
				i = i + 1
			end
			self.othersInfo[self.currSelEnemyIdx] = info
            self:updateOthersInfo()
            local yesCb = function()
                -- addNetLoading(SINPVP_CS_FIGHTPVP,SINPVP_SC_FIGHTRESULT)
                g_msgHandlerInst:sendNetDataByTableExEx(SINPVP_CS_OPENPVP,"SinpvpOpenProtocol",{single = self.mode, openType = 2})
                addNetLoading(SINPVP_CS_OPENPVP,SINPVP_SC_OPENPVP)
            end
            MessageBoxYesNo("",game.getStrByKey("jjc_rank_change"),yesCb)
        end,  
    }

    if switch[msgid] then 
        switch[msgid]()
    end
end

return JJCHall