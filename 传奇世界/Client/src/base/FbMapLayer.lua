local FbMapLayer = class("FbMapLayer",require("src/base/MainMapLayer.lua"))

local commConst = require("src/config/CommDef");

function FbMapLayer:ctor(strname,parent,r_pos,mapId,isfb)
	
	self:addEvent()
	self.parent = parent
	self.parent.map_layer = self
	self:registerMsgHandler()
	self:initializePre()
	self.updata_time = 0
	self.monster_num = 0
	self.isfb = true
	self:loadMapInfo(strname, mapId,r_pos)
	self.parent:addChild(self,-1)
	self:loadSpritesPre()
	self.exitTimeBegain = false
	self.isOver = false
	self.isSendExit = false --阻止频繁的发送退出消息.
	self.exitTimeLeft = nil
    self.autoGet = nil;
    self.mineState = 0 --滴血挖矿状态
    -- 屠龙传说副本收集进度
    self.m_dragonCollect = 0;
    -- 屠龙传说副本id
    self.m_dragonCarbon = 0;
    -- 屠龙传说副本要求[配置]
    self.m_dragonReq = "";
    -- 屠龙传说副本要求显示label
    self.m_dragonProgressLal = nil;
    -- 屠龙传说boss guid
    self.m_dragonBossGuid = 0;

    -- 屠龙传说倒计时标题
    self.m_dragonCountdownLal = nil;

    -- 屠龙传说允许拾取物品完成后再提示下一波
    self.m_willNext = false;

    -- 多人守卫公主guid
    self.MulityObjId = 0;
    self.timeLeft = 0;
    self.m_noMoreRelive = false;
    -- [0 今天一波都没打过 1~5 今天打过5波]
    self.m_nowPrizeCircle = 0;

    self.m_progBg = nil;
    
	self:fbInit()
	local cb = function()
		self.has_loadmap = true	
	end
	performWithDelay(self.item_Node, cb, 0.0)
    startTimerActionEx(self.item_Node, 1.0, true, function(delTime) self:timer(delTime) end)


    --禁止队伍界面点击
    self.m_stOldTouch = bForbidTeamTouch
    bForbidTeamTouch = true

    self.robMineHasTalkNpc = false 
end

function FbMapLayer:addEvent( ... )
	-- body
	-- Event.Add(EventName.ChangeTeamNode, self, self.refreshTeamInfo)
end

function FbMapLayer:removeEvent( ... )
	-- body
	print("removeEvent!")
	-- Event.Remove(EventName.ChangeTeamNode, self)
end

--析构函数
function FbMapLayer:dispose( ... )
	-- body
	-- 恢复点击
	bForbidTeamTouch = self.m_stOldTouch
	self:removeEvent()
end

function FbMapLayer:fbInit()
	local strs = {"FBSingle","FBSingle","FBTower","FBDefense","MultiCopy","NewSingleCopyDB" ,"FBRobMine"}
	local temp = nil;
    if userInfo == nil then
        TIPS{type=1, str=game.getStrByKey("login_dataError")};
        return;
    end
    
    -- 防止保存数据异常，根据服务器返回重新设定
    if self.mapID == 5104 then
        userInfo.lastFbType = commConst.CARBON_MULTI_GUARD;
        local tmpMultiCarbonId = GetMultiPlayerCtr():getRealCopyId();
        if tmpMultiCarbonId == -1 then
            tmpMultiCarbonId = getLocalRecordByKey(1, "MultiCarbonId", 1);
        end
        userInfo.lastFb = tmpMultiCarbonId;
    elseif self.mapID == 5005 then
        userInfo.lastFbType = commConst.CARBON_PRINCESS;
    end
    if self.mapID == 5008 then 
    	 userInfo.lastFbType = commConst.CARBON_MINE
    end
    if self.mapID == 5010 then--3V3副本，增加倒计时和开门操作
    	cc.SpriteFrameCache:getInstance():addSpriteFrames("res/effectsplist/3v3dooropen@0.plist")
        self.eff_door_0 = Effects:create(false)
        self.eff_door_0:setAsyncLoad(false)
        self.eff_door_0:setAnchorPoint(cc.p(0.5, 0.5))
        self.eff_door_0:setSpriteFrame("3v3dooropen/00000.png")
        self.eff_door_0:setPosition(cc.p(self:tile2Space(cc.p(15, 30)).x - 48, self:tile2Space(cc.p(15, 30)).y + 173))
        self:addChild(self.eff_door_0)
        self.eff_door_1 = Effects:create(false)
        self.eff_door_1:setAsyncLoad(false)
        self.eff_door_1:setAnchorPoint(cc.p(0.5, 0.5))
        self.eff_door_1:setSpriteFrame("3v3dooropen/00000.png")
        self.eff_door_1:setPosition(cc.p(self:tile2Space(cc.p(31, 16)).x + 40, self:tile2Space(cc.p(31, 16)).y + 147))
        self:addChild(self.eff_door_1)
        self:setBlockRectValue(cc.rect(14, 29, 0, 0), "1")
        self:setBlockRectValue(cc.rect(15, 30, 0, 0), "1")
        self:setBlockRectValue(cc.rect(13, 29, 0, 0), "1")
        self:setBlockRectValue(cc.rect(14, 30, 0, 0), "1")
        self:setBlockRectValue(cc.rect(15, 31, 0, 0), "1")
        self:setBlockRectValue(cc.rect(32, 16, 0, 0), "1")
        self:setBlockRectValue(cc.rect(33, 17, 0, 0), "1")
        self:setBlockRectValue(cc.rect(31, 16, 0, 0), "1")
        self:setBlockRectValue(cc.rect(32, 17, 0, 0), "1")
        self:setBlockRectValue(cc.rect(33, 18, 0, 0), "1")

        local effect_countDown = Effects:create(false)
        effect_countDown:setAsyncLoad(false)
        G_MAINSCENE:addChild(effect_countDown)
        effect_countDown:setPosition(cc.p(display.cx, display.cy))
        effect_countDown:playActionData("ten_countdown", 10, 10, 1)
        startTimerAction(G_MAINSCENE, 10, false, function() 
            local mapLayer=G_MAINSCENE.map_layer
            --开门
            self.eff_door_0:playActionData("3v3dooropen", 10, 0.6, 1)
            self.eff_door_1:playActionData("3v3dooropen", 10, 0.6, 1)
            self:setBlockRectValue(cc.rect(14, 29, 0, 0), "0")
            self:setBlockRectValue(cc.rect(15, 30, 0, 0), "0")
            self:setBlockRectValue(cc.rect(13, 29, 0, 0), "0")
            self:setBlockRectValue(cc.rect(14, 30, 0, 0), "0")
            self:setBlockRectValue(cc.rect(15, 31, 0, 0), "0")
            self:setBlockRectValue(cc.rect(32, 16, 0, 0), "0")
            self:setBlockRectValue(cc.rect(33, 17, 0, 0), "0")
            self:setBlockRectValue(cc.rect(31, 16, 0, 0), "0")
            self:setBlockRectValue(cc.rect(32, 17, 0, 0), "0")
            self:setBlockRectValue(cc.rect(33, 18, 0, 0), "0")
        end )    
    end
	userInfo.lastFbType = userInfo.lastFbType or tonumber(getLocalRecordByKey(2,"lastFbType")) or 1

	if userInfo.lastFbType == 4 then 
		userInfo.currDefenseFloor = userInfo.currDefenseFloor or tonumber(getLocalRecordByKey(2,"subFbType")) or 1
		temp = require("src/config/"..strs[userInfo.lastFbType].."")[userInfo.currDefenseFloor]
		if not temp then
			temp = require("src/config/"..strs[userInfo.lastFbType].."")[1]
		end
	else
		userInfo.lastFb = userInfo.lastFb or tonumber(getLocalRecordByKey(2,"subFbType")) or 1
		if userInfo.lastFbType == commConst.CARBON_MULTI_GUARD then
			cclog("userInfo.lastFb"..userInfo.lastFb..strs[userInfo.lastFbType])
			self.fbData = getConfigItemByKey(""..strs[userInfo.lastFbType].."","CopyofID",tonumber(userInfo.lastFb))
			dump(self.fbData)

            -- 多人守卫是否达到复活上限了
            self.m_noMoreRelive = false;
        elseif userInfo.lastFbType == commConst.CARBON_PRINCESS then
            self.fbData = getConfigItemByKey("SingleGuardCopyDB","CopyofID", tonumber(userInfo.lastFb))
            -- 是否达到复活上限了
            self.m_noMoreRelive = false;
        elseif userInfo.lastFbType == commConst.CARBON_MINE then 
        	-- xhh do nothing
		else	
			if not userInfo.newFbId then
				userInfo.newFbId = -1
				local fullStr = getLocalRecordByKey(2,"redDotFbId","")
				if fullStr ~= "" then
					local split = string.find(fullStr,"%.")
					if split then
						local m = tonumber(string.sub(fullStr,1,split-1))
						local n = tonumber(string.sub(fullStr,split+1,#fullStr))
			    		if m==userInfo.currRoleStaticId then
			    			userInfo.newFbId = n
			    		end
			    	end
				end
			end
			if userInfo.newFbId ~= -1 and userInfo.newFbId == userInfo.lastFb  then
				userInfo.newFbId = -1
				setLocalRecordByKey(2,"redDotFbId",""..userInfo.currRoleStaticId.."."..userInfo.newFbId)
				DATA_Battle:setRedData("TLCS", false)
			end
            
            if userInfo.lastFbType == commConst.CARBON_DRAGON_SLIAYER then
                resetConfigItems();
                local dragonCfg = getConfigItemByKey("instanceInfolist", "q_ins_id", userInfo.lastFb);
                if dragonCfg ~= nil then
                    -- 保存屠龙传说副本id
                    self.m_dragonCarbon = userInfo.lastFb;
                end
                resetConfigItems();
            end
			temp = getConfigItemByKey(""..strs[userInfo.lastFbType].."","q_mainID", userInfo.lastFb);

			if userInfo.lastFbType == 3 then
				temp = getConfigItemByKey(""..strs[userInfo.lastFbType].."","q_id", userInfo.lastFb);
			end
		end
	end
	if userInfo.lastFbType ~= commConst.CARBON_MULTI_GUARD and userInfo.lastFbType ~= commConst.CARBON_PRINCESS then
		self.totalCircleNum = temp and temp.q_maxCircle or 0;
		self.currCircle = 1
		self.currNum = 0
		self.deadNum = 0
		self.monsterData = temp and stringToTable(temp.q_monster) or {};
		self.timeLeft = 0
		if userInfo.lastFbType == 4 then
			local destStr = stringToTable(temp.dxzb)
			local destPos = cc.p(tonumber(destStr[1][1]),tonumber(destStr[1][2]))
			self.currBlood = temp.qsm
			self.maxBlood = temp.qsm
			--createSprite(self.item_Node,"res/npc/diaoxiang/00000.png",self:tile2Space(destPos),cc.p(0.5,0.5),destPos.y)
		elseif userInfo.lastFbType == 3 then
			self.currLayer = temp.q_copyLayer
			self.currName = temp.fbm
		elseif userInfo.lastFbType == 1 then
			self.time = 0
			self.levelTimes = {tonumber(temp.aping),tonumber(temp.bping),tonumber(temp.cping)}
        elseif userInfo.lastFbType == commConst.CARBON_DRAGON_SLIAYER then
            self.m_dragonCollect = 0;
		end
		
		game.setAutoStatus(0)
		performWithDelay(self.item_Node,function()
            if userInfo and commConst and userInfo.lastFbType == commConst.CARBON_DRAGON_SLIAYER then
                -- 屠龙传说副本初始就会自动寻路，不需要这里挂机
                return;
            end

            if userInfo and userInfo.lastFbType == 3 and userInfo.lastFb then
            	local fbId = userInfo.lastFb
				local itemDate = getConfigItemByKey("FBTower", "q_id", fbId)
				if itemDate and itemDate.q_copyLayer then
					TIPS( { str = string.format("开始挑战通天塔第%d层", tonumber(itemDate.q_copyLayer or 1) ) } )
				end
			elseif userInfo and userInfo.lastFbType== commConst.CARBON_MINE then
				--TIPS({str = game.getStrByKey("fb_robmine_start")})
            end
            if userInfo.lastFbType ~= commConst.CARBON_MINE then 
				game.setAutoStatus(AUTO_ATTACK)
			end
			--self.parent.hang_node:setImages("res/mainui/anotherbtns/stop.png")
		end,1.0)
	end
	self:showTimePanel()

    -- startTimerAction(self, 0.05, false, function() G_ROLE_MAIN:upOrDownRide(false) end ) 
    if userInfo and userInfo.lastFbType== commConst.CARBON_MINE then
		performWithDelay(self.item_Node, function() self:setFbRoleNameColor(G_ROLE_MAIN , MColor.green) end, 0.1 )
    end

	-- self:refreshTeamInfo()
end

function FbMapLayer:removeTeamInfo( ... )
	-- body
	if self.teamNode then 
		if tolua.cast(self.teamNode,"cc.Node") then removeFromParent(self.teamNode) end
		self.teamNode = nil 
	end
end

--显示队伍信息
function FbMapLayer:refreshTeamInfo( bShow )
	-- body
	-- if not IsNodeValid(self) then
	-- 	return
	-- end
	print("refreshTeamInfo")
	local function tmpCallBack(msg)
        print(msg);
    end
    xpcall(handler(self,self.removeTeamInfo), tmpCallBack);
    
	if userInfo.lastFbType ~= commConst.CARBON_MULTI_GUARD then
		return
	end

	self.teamNode = require( "src/layers/teamup/teamNode" ).new( { parent = G_MAINSCENE ,teamMemberNum = (G_TEAM_INFO and G_TEAM_INFO.has_team and G_TEAM_INFO.memCnt) or 0 } )						
	self.teamNode:setSelectMemEnabled(false)
end

function FbMapLayer:timeLabUpdate(delTime)
	if self.autoGetTimeLeft then
		self:autoGetCallBack(delTime)
	end
end

function FbMapLayer:update()
	self.updata_time = self.updata_time + 1
	if self.updata_time >= 10000 then
		self.updata_time = 0
	end
	self:onRoleAttack()
end

function FbMapLayer:timer(delTime)
	self:updateTimeLeft(delTime)
	if self.exitTimeLeft then
		self:UpdateExitTimeLab(delTime)
	end

    self:CheckMultiDead();
end

-- 多人守卫 隐藏死亡过多的其他玩家
function FbMapLayer:CheckMultiDead()
    if self.role_tab and self.item_Node and G_ROLE_MAIN and userInfo and userInfo.lastFbType == commConst.CARBON_MULTI_GUARD then
        for k,v in pairs(self.role_tab) do
            local playerNode = self.item_Node:getChildByTag(v);
            if playerNode then
                local player = tolua.cast(playerNode, "SpritePlayer");
                if player then
                    -- 已死亡
		            if player:getCurrActionState() == ACTION_STATE_DEAD and player ~= G_ROLE_MAIN then
			            player:setVisible(false);
		            end
                end
            end
	    end
    end
end

function FbMapLayer:showTimePanel()
	local addLabel = createLabel
	local addSprite = createSprite
	
	local stop = function()
		cclog("stop")
		game.setAutoStatus(0)
		self.parent.hang_node:setImages("res/mainui/anotherbtns/hangup.png")
        self.parent.m_stopHangSpr:setVisible(false);
	end
	local exit = function()
		cclog("exit")
		if self.goods_tab and tablenums(self.goods_tab) > 0 then
			MessageBoxYesNo(nil, game.getStrByKey("tuto_tip_fb_exit_confirm"), function() self:fbExit() end, nil)
		else
			self:fbExit()
		end
	end
	
	if userInfo.lastFbType == commConst.CARBON_MULTI_GUARD then  -- 多人守卫
		local height = display.cy + 120
        
		local bg = createScale9Sprite(G_MAINSCENE, "res/fb/multiple/bg.png", cc.p(display.width - 10, height), cc.size(230, 132),cc.p(1, 0.5), nil, nil, 101)	
		local switchShowModeFunc = function()
			if self.bgIsShow then
				self.swithShowModeBtn:setTexture("res/mainui/anotherbtns/shrink.png")
				-- bg:runAction(cc.MoveTo:create(0.2, cc.p(- bg:getContentSize().width + 5, height)))
				bg:runAction(cc.MoveBy:create(0.2, cc.p(bg:getContentSize().width + 10, 0)))
			else
				-- bg:runAction(cc.MoveTo:create(0.2, cc.p(0, height)))
				bg:runAction(cc.MoveBy:create(0.2, cc.p(-bg:getContentSize().width - 10, 0)))
				self.swithShowModeBtn:setTexture("res/mainui/anotherbtns/spread.png")
			end
			self.bgIsShow = not self.bgIsShow
		end
		self.swithShowModeBtn = createTouchItem(bg, "res/mainui/anotherbtns/spread.png", cc.p( -50, 100), switchShowModeFunc)
		self.swithShowModeBtn:setAnchorPoint(cc.p(0, 1))
		self.bgIsShow = true
		
		-- local infoTab = createTouchItem(bg, "res/empire/53_sel.png", cc.p( 70, 229), function()
  --           end )
		-- infoTab:setAnchorPoint(cc.p(0, 0))
		-- self.infoTab = infoTab

		self.longMaiNode = cc.Node:create()
		bg:addChild(self.longMaiNode)
		self.longMaiNode:setPosition(cc.p(0, -90))
		self.circleLab = createLabel(self.longMaiNode, string.format(game.getStrByKey("fb_enemyOrder3"), "1") ,cc.p(125, 200), cc.p(0.5, 0.5), 24, true)
		self.circleLab:setColor(MColor.lable_yellow) --self.fbData.shuaguai

		function exitConfirm()
			MessageBoxYesNo(nil,game.getStrByKey("exit_confirm"),exit,nil,game.getStrByKey("sure"),game.getStrByKey("cancel"))
		end
        local item = createMenuItem(G_MAINSCENE,"res/component/button/1.png", cc.p(g_scrSize.width-67, g_scrSize.height-98),exitConfirm)
	    item:setSmallToBigMode(false)
	    self.exitBtn = item
        -- function createLabel(parent, sContent,pos, anchor, fontSize, isOutLine, izorder, fontName, fontColor, tag, specificWidth, outLineColor, outLineWidth)
	    createLabel(item, game.getStrByKey("fb_leave"), getCenterPos(item), cc.p(0.5,0.5), 22, true, nil, nil, MColor.lable_yellow, 1);

		local MidNode = cc.Node:create()
		G_MAINSCENE:addChild(MidNode)
		
        -- function createSprite(parent, pszFileName, pos, anchor, zOrder, fScale)
		self.m_progBg = addSprite(MidNode, "res/component/progress/4_bg.png",cc.p(display.width - 300 - 130, display.height-34), cc.p(0, 0))
		self.progress = cc.ProgressTimer:create(cc.Sprite:create("res/component/progress/4.png"))  
	    self.progress:setPosition(getCenterPos(self.m_progBg))
	    self.progress:setType(cc.PROGRESS_TIMER_TYPE_BAR)
	    self.progress:setAnchorPoint(cc.p(0.5,0.5))
	    self.progress:setBarChangeRate(cc.p(1, 0))
	    self.progress:setMidpoint(cc.p(0,1))
        -- 初始满血
        self.currBlood = tonumber(self.fbData.statuelife);
	    self.progress:setPercentage(self.currBlood*100/tonumber(self.fbData.statuelife))
	    self.m_progBg:addChild(self.progress)  
        -- createLabel(parent, sContent,pos, anchor, fontSize, isOutLine, izorder, fontName, fontColor, tag, specificWidth, outLineColor, outLineWidth)
		self.labProgress = createLabel(self.m_progBg, tostring(self.currBlood.."/"..self.fbData.statuelife) ,getCenterPos(self.m_progBg), nil, 22, true, nil, nil, MColor.white)

        addLabel(self.m_progBg, game.getStrByKey("fb_longmai1"), cc.p(20, 6), cc.p(0, 0), 18, true, nil, nil, MColor.gold)

        self.m_multiCarbonInfoSpr = createScale9Sprite(MidNode,"res/common/scalable/8.png", cc.p(display.width - 300 - 134,display.height-114),cc.size(300, 80),cc.p(0,0))

		local temp = createLabel(self.m_multiCarbonInfoSpr, game.getStrByKey("fb_fbTimeCost"), cc.p(0, 0), cc.p(0, 0), 18, true)
		self.passedTimeLab = createLabel(self.m_multiCarbonInfoSpr, "0"..game.getStrByKey("sec"), cc.p(110, 0), cc.p(0, 0), 18)
    elseif userInfo.lastFbType == commConst.CARBON_PRINCESS then
        local height = display.cy + 120
        
		local bg = createScale9Sprite(G_MAINSCENE, "res/fb/multiple/bg.png", cc.p(display.width - 10, height), cc.size(230, 132),cc.p(1, 0.5), nil, nil, 101)	
		local switchShowModeFunc = function()
			if self.bgIsShow then
				self.swithShowModeBtn:setTexture("res/mainui/anotherbtns/shrink.png")
				-- bg:runAction(cc.MoveTo:create(0.2, cc.p(- bg:getContentSize().width + 5, height)))
				bg:runAction(cc.MoveBy:create(0.2, cc.p(bg:getContentSize().width + 10, 0)))
			else
				-- bg:runAction(cc.MoveTo:create(0.2, cc.p(0, height)))
				bg:runAction(cc.MoveBy:create(0.2, cc.p(-bg:getContentSize().width - 10, 0)))
				self.swithShowModeBtn:setTexture("res/mainui/anotherbtns/spread.png")
			end
			self.bgIsShow = not self.bgIsShow
		end
		self.swithShowModeBtn = createTouchItem(bg, "res/mainui/anotherbtns/spread.png", cc.p( -50, 100), switchShowModeFunc)
		self.swithShowModeBtn:setAnchorPoint(cc.p(0, 1))
		self.bgIsShow = true
		
		-- local infoTab = createTouchItem(bg, "res/empire/53_sel.png", cc.p( 70, 229), function()
  --           end )
		-- infoTab:setAnchorPoint(cc.p(0, 0))
		-- self.infoTab = infoTab

		self.longMaiNode = cc.Node:create()
		bg:addChild(self.longMaiNode)
		self.longMaiNode:setPosition(cc.p(0, -90))
		self.circleLab = createLabel(self.longMaiNode, string.format(game.getStrByKey("fb_enemyOrder3"), "1") ,cc.p(125, 200), cc.p(0.5, 0.5), 24, true)
		self.circleLab:setColor(MColor.lable_yellow) --self.fbData.shuaguai

		function exitConfirm()
			MessageBoxYesNo(nil,game.getStrByKey("exit_confirm"),exit,nil,game.getStrByKey("sure"),game.getStrByKey("cancel"))
		end
        local item = createMenuItem(G_MAINSCENE,"res/component/button/1.png", cc.p(g_scrSize.width-67, g_scrSize.height-98),exitConfirm)
	    item:setSmallToBigMode(false)
	    self.exitBtn = item
        -- function createLabel(parent, sContent,pos, anchor, fontSize, isOutLine, izorder, fontName, fontColor, tag, specificWidth, outLineColor, outLineWidth)
	    createLabel(item, game.getStrByKey("fb_leave"), getCenterPos(item), cc.p(0.5,0.5), 22, true, nil, nil, MColor.lable_yellow, 1);

		local MidNode = cc.Node:create()
		G_MAINSCENE:addChild(MidNode)
		
        -- function createSprite(parent, pszFileName, pos, anchor, zOrder, fScale)
		self.m_progBg = addSprite(MidNode, "res/component/progress/4_bg.png",cc.p(display.width - 300 - 130, display.height-34), cc.p(0, 0))
		self.progress = cc.ProgressTimer:create(cc.Sprite:create("res/component/progress/4.png"))  
	    self.progress:setPosition(getCenterPos(self.m_progBg))
	    self.progress:setType(cc.PROGRESS_TIMER_TYPE_BAR)
	    self.progress:setAnchorPoint(cc.p(0.5,0.5))
	    self.progress:setBarChangeRate(cc.p(1, 0))
	    self.progress:setMidpoint(cc.p(0,1))
        -- 初始满血
        self.currBlood = tonumber(self.fbData.statuelife);
	    self.progress:setPercentage(self.currBlood*100/tonumber(self.fbData.statuelife))
	    self.m_progBg:addChild(self.progress)  
        -- createLabel(parent, sContent,pos, anchor, fontSize, isOutLine, izorder, fontName, fontColor, tag, specificWidth, outLineColor, outLineWidth)
		self.labProgress = createLabel(self.m_progBg, tostring(self.currBlood.."/"..self.fbData.statuelife) ,getCenterPos(self.m_progBg), nil, 22, true, nil, nil, MColor.white)

        addLabel(self.m_progBg, game.getStrByKey("fb_longmai1"), cc.p(20, 6), cc.p(0, 0), 18, true, nil, nil, MColor.gold)

        self.m_multiCarbonInfoSpr = createScale9Sprite(MidNode,"res/common/scalable/8.png", cc.p(display.width - 300 - 134,display.height-114),cc.size(300, 80),cc.p(0,0))

		local temp = createLabel(self.m_multiCarbonInfoSpr, game.getStrByKey("fb_fbTimeCost"), cc.p(0, 0), cc.p(0, 0), 18, true)
		self.passedTimeLab = createLabel(self.m_multiCarbonInfoSpr, "0"..game.getStrByKey("sec"), cc.p(110, 0), cc.p(0, 0), 18)

        performWithDelay(self.item_Node, function()
            -- 添加副本开始效果
            addFBTipsEffect(G_MAINSCENE, cc.p(display.width/2, display.height/2), "res/fb/start.png");
        end, 0.8)
    elseif userInfo.lastFbType == commConst.CARBON_DRAGON_SLIAYER then  --新屠龙传说  6
        -- function createScale9Sprite(parent, pszFileName, pos,size, anchor,rect, fScale, zOrder)
        local bgPanel = createSprite( G_MAINSCENE , "res/common/bg/bg62.png" , cc.p(2, g_scrSize.height-255) , cc.p( 0, 0 ) )
        -- 添加触摸响应
        local listenner = cc.EventListenerTouchOneByOne:create()
        listenner:setSwallowTouches(true);
	    listenner:registerScriptHandler(function(touch, event)
                if bgPanel == nil or tolua.cast(bgPanel, "cc.Sprite") == nil then
                    return false;
                end

                if touch and event then
                    local pt = touch:getLocation();
                    pt = bgPanel:getParent():convertToNodeSpace(pt);
				    if cc.rectContainsPoint(bgPanel:getBoundingBox(), pt) then
					    return true;
				    end	  
                end

				return false;
			end,cc.Handler.EVENT_TOUCH_BEGAN)
	    listenner:registerScriptHandler(function(touch, event)
                if bgPanel == nil or tolua.cast(bgPanel, "cc.Sprite") == nil then
                    return false;
                end

                if touch and event then
				    local pt = touch:getLocation();
                    pt = bgPanel:getParent():convertToNodeSpace(pt);
				    if cc.rectContainsPoint(bgPanel:getBoundingBox(), pt) then
                        if G_MAINSCENE and G_MAINSCENE.map_layer and self.monsterData ~= nil and self.currCircle and self.monsterData[self.currCircle] ~= nil then
                            local tmpNewPos = cc.p(tonumber(self.monsterData[self.currCircle][4]), tonumber(self.monsterData[self.currCircle][5]));
                            -- 自动寻路
                            G_MAINSCENE.map_layer:removeWalkCb();
			                local callback = function()
				                G_MAINSCENE.map_layer:removeWalkCb();
				                game.setAutoStatus(AUTO_ATTACK);
			                end
                            G_MAINSCENE.map_layer:registerWalkCb(callback);
                            local detailMapNodeLua = require("src/layers/map/DetailMapNode");
                            if detailMapNodeLua and self.mapID then
   				                detailMapNodeLua:goToMapPos(self.mapID, tmpNewPos, true);
                            end
                        end
				    end
                    return true;
                end

                return false;
			end,cc.Handler.EVENT_TOUCH_ENDED)
	    local eventDispatcher = bgPanel:getEventDispatcher()
	    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, bgPanel);

        -- function createLabel(parent, sContent,pos, anchor, fontSize, isOutLine, izorder, fontName, fontColor, tag, specificWidth, outLineColor, outLineWidth)
        addLabel(bgPanel, game.getStrByKey("dragonPlotReq") .. ": ", cc.p(14, 45), cc.p(0, 0), 20, false, nil, nil, MColor.gold);

        local cfgReqStr = "";
        resetConfigItems();
        local dragonCfg = getConfigItemByKey("instanceInfolist", "q_ins_id", userInfo.lastFb);
        if dragonCfg ~= nil then
            self.m_dragonReq = dragonCfg.q_txt_win;
            cfgReqStr = self.m_dragonReq;
        end
        resetConfigItems();

        if self.m_dragonCarbon == commConst.DRAGON_BLOOD_CITY then
            self.m_dragonReq = game.getStrByKey("dragonCfgReq1");
            cfgReqStr = self.m_dragonReq .. "  ("  .. self.m_dragonCollect .. "/3)";
        elseif self.m_dragonCarbon == commConst.DRAGON_BABEL then
            -- 分两阶段目标
            self.m_dragonReq = game.getStrByKey("dragonCfgReq2");
            cfgReqStr = self.m_dragonReq .. "  ("  .. self.m_dragonCollect .. "%)";
        elseif self.m_dragonCarbon == commConst.DRAGON_ASURA_SHRINE then
            self.m_dragonReq = game.getStrByKey("dragonAsuraCfgReq3");
            cfgReqStr = self.m_dragonReq .. "  ("  .. self.m_dragonCollect .. "/30)";
        end

        self.m_dragonProgressLal = addLabel(bgPanel, cfgReqStr, cc.p(14, 16), cc.p(0, 0), 20, false, nil, nil, MColor.lable_yellow);
        
        self.m_timePanel = createSprite( G_MAINSCENE , "res/mainui/sideInfo/timeBg.png" , cc.p(display.width-154-171, g_scrSize.height), cc.p(0, 1))
        self.m_dragonCountdownLal = createLabel(self.m_timePanel, game.getStrByKey("battle_countdown"), cc.p(self.m_timePanel:getContentSize().width/2,self.m_timePanel:getContentSize().height-16), cc.p(0.5,0.5),18,true,nil,nil,MColor.lable_yellow)
        self.labTime = createLabel(self.m_timePanel, "", cc.p(self.m_timePanel:getContentSize().width/2, self.m_timePanel:getContentSize().height/2-8), cc.p(0.5,0.5),40,true,nil,nil,MColor.lable_yellow)
        
        function exitConfirm()
		    if self.isfinished then
			    exit()
		    else
			    MessageBoxYesNo(nil,game.getStrByKey("exit_confirm2"),exit,nil,game.getStrByKey("sure"),game.getStrByKey("cancel"))
		    end
	    end
        -- function createMenuItem(parent, pszFileName, pos, callback,zorder,noswan,noDefaultVoice)
	    local item = createMenuItem(G_MAINSCENE,"res/component/button/1.png", cc.p(g_scrSize.width-67, g_scrSize.height-98),exitConfirm)
	    item:setSmallToBigMode(false)
	    self.exitBtn = item
        createLabel(item, game.getStrByKey("fb_leave"), getCenterPos(item), cc.p(0.5,0.5), 22, true, nil, nil, MColor.lable_yellow, 1);
        
	    performWithDelay(self.item_Node, function()
            -- 添加副本开始效果
            addFBTipsEffect(G_MAINSCENE, cc.p(display.width/2, display.height/2), "res/fb/start.png");
        end, 0.8)
        
	elseif userInfo.lastFbType == 3 or userInfo.lastFbType == 4 then
		local bg = createSprite(self.parent,"res/mainui/sideInfo/timeBg.png",cc.p(display.width-154-171,g_scrSize.height),cc.p(0,1))
		local bgSize = bg:getContentSize()
		self.labTimeTitle = createLabel(bg, "战斗倒计时", cc.p(bgSize.width/2, bgSize.height-16), nil, 18, true)
		self.labTime = createLabel(bg, "28", cc.p(bgSize.width/2, bgSize.height/2-8), cc.p(0.5,0.5),40,true,nil,nil,MColor.lable_yellow)
		self.timeBg = bg

		function exitConfirm()
			--print("exitConfirm .. deadNum:"..self.deadNum..".self.currNum" .. self.currNum..".self.totalCircleNum"..self.totalCircleNum..".self.currCircle"..self.currCircle)
			if self.deadNum >= self.currNum and self.totalCircleNum == self.currCircle then
				exit()
			else
				MessageBoxYesNo(nil,game.getStrByKey("exit_confirm2"),exit,nil,game.getStrByKey("sure"),game.getStrByKey("cancel"))
			end
		end						
        local exit_menu = createMenuItem(self.parent,"res/component/button/1.png",cc.p(g_scrSize.width-67, g_scrSize.height-98),exitConfirm)
        createLabel(exit_menu,game.getStrByKey("exit"),cc.p(exit_menu:getContentSize().width/2+4,exit_menu:getContentSize().height/2+3),cc.p(0.5,0.5),22,true,nil,nil,MColor.yellow_gray)
	elseif userInfo.lastFbType == commConst.CARBON_MINE then
		function exitConfirm()
			if self.exitTimeLeft then 
				exit()
			else
				MessageBoxYesNo(nil , game.getStrByKey("exit_confirm2") , exit , nil , game.getStrByKey("sure") , game.getStrByKey("cancel"))
			end
			-- exit()
		end

		local bg = createSprite(self.parent,"res/mainui/sideInfo/timeBg.png",cc.p(display.width-154-171,g_scrSize.height),cc.p(0,1))
		local bgSize = bg:getContentSize()
		self.labTimeTitle = createLabel(bg, "战斗倒计时", cc.p(bgSize.width/2, bgSize.height-16), nil, 18, true)
		self.labTime = createLabel(bg, "28", cc.p(bgSize.width/2, bgSize.height/2-8), cc.p(0.5,0.5),40,true,nil,nil,MColor.lable_yellow)
		self.timeBg = bg

		local exit_menu = createMenuItem(self.parent,"res/component/button/1.png",cc.p(g_scrSize.width-67, g_scrSize.height-98),exitConfirm)
        self.exitLabel = createLabel(exit_menu,game.getStrByKey("fb_leave"),cc.p(exit_menu:getContentSize().width/2+4,exit_menu:getContentSize().height/2+3),cc.p(0.5,0.5),22,true,nil,nil,MColor.yellow_gray)
		--退出倒计时
		-- self.fbLeftTimeLab  = createLabel(exit_menu, "28", cc.p(exit_menu:getContentSize().width/2, exit_menu:getContentSize().height/2-40), cc.p(0.5,0.5),50,true,nil,nil,MColor.lable_yellow)
	    
        performWithDelay(self.item_Node, function()
            -- 添加副本开始效果
            addFBTipsEffect(G_MAINSCENE, cc.p(display.width/2, display.height/2), "res/fb/start.png");
        end, 0.8)
	end
end

function FbMapLayer:UpdateExitTimeLab(delTime)
	self.exitTimeLeft = self.exitTimeLeft - delTime
	if self.exitTimeLeft >= 0 then	
		if self.labTime then
			local str = secondParse(self.exitTimeLeft)
			if userInfo.lastFbType == 3 or userInfo.lastFbType == 4 or userInfo.lastFbType == commConst.CARBON_DRAGON_SLIAYER or userInfo.lastFbType == commConst.CARBON_MINE then
				str = self.exitTimeLeft
			end
			self.labTime:setString(str)
		end

		if self.exitLabel and userInfo.lastFbType == commConst.CARBON_MINE then
			str = game.getStrByKey("fb_leave") .. "[" .. self.exitTimeLeft.. "]"
			self.exitLabel:setString(str)
		end
	end

	if self.exitTimeLeft <= 0 then
		self:fbExit()
	end	
end

function FbMapLayer:exitFbTimeStart()
	if self.mapID ~= 5008 then 

	    -- 屠龙传说副本无需结束倒计时
	    if userInfo and (userInfo.lastFbType == commConst.CARBON_DRAGON_SLIAYER or userInfo.lastFbType == commConst.CARBON_TOWER ) then
			return;
	    end

		if nil == self.exitTimeLeft then
			self.exitTimeLeft = 10
		end
		
		if self.fbLeftTimeLab then
			self.fbLeftTimeLab:setString(game.getStrByKey("fb_exitFb").. game.getStrByKey("countDownTime") .. ":")
		end
		if self.labTime then
	        self.labTime:setString(secondParse(self.exitTimeLeft))
			if userInfo.lastFbType == 3 then
				self.labTime:setPosition(cc.p(150, 140))
			end
		end	
		
	--退出按钮上倒计时 by xuhuihong
	elseif self.mapID == 5008 and self.m_mineData and self.m_mineData.totalProgress == self.m_mineData.progress then 
		if nil == self.exitTimeLeft then
			self.exitTimeLeft = 15
		end
		if self.exitLabel then 
			local str = game.getStrByKey("exit") .. "[" .. self.exitTimeLeft.. "]"
			self.exitLabel:setString(str)
		end

	end
end

function FbMapLayer:fbExit()
	--确认只发一次退出消息
	if self.isSendExit then return end
	dump("FbMapLayer:fbExit")

	self.isSendExit = true
	if userInfo.lastFbType == commConst.CARBON_MINE and self.mapID == 5008 then
		g_msgHandlerInst:sendNetDataByTableExEx(DIGMINE_CS_SIMULATION_QUIT, "DigMineSimulationQuit", {})
		addNetLoading(DIGMINE_CS_SIMULATION_QUIT,FRAME_SC_ENTITY_ENTER)
	--	print("FbMapLayer:fbExit() ,DIGMINE_CS_SIMULATION_QUIT ")
	else
		g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_EXITCOPY,"ExitCopyProtocol", {})
		addNetLoading(COPY_CS_EXITCOPY,FRAME_SC_ENTITY_ENTER)
	--	print("FbMapLayer:fbExit() ,COPY_CS_EXITCOPY ")
		
	end

	game.setAutoStatus(0)
	--self.parent.hang_node:setImages("res/mainui/anotherbtns/hangup.png")
	self:resetTouchTag()
	performWithDelay(self.item_Node, function() self.isSendExit = false end, 0.5)
end

function FbMapLayer:showNextCircleMonsterWay()
    if userInfo == nil then
        return;
    end

	local Circle = self.currCircle
	if userInfo.lastFbType == 3 then
		local monsterID = {1605, 1606, 1612}
		if monsterID[Circle] then
			local recode = getConfigItemByKey("monsterUpdate", "q_id", monsterID[Circle])
			if recode and G_MAINSCENE and recode.q_center_x and recode.q_center_y then
				G_MAINSCENE:showArrowPointToMonster(true, cc.p(recode.q_center_x, recode.q_center_y), true)
				G_MAINSCENE.map_layer:removeWalkCb()
				local callback = function()
					G_MAINSCENE.map_layer:removeWalkCb()
					game.setAutoStatus(AUTO_ATTACK)
				end
				G_MAINSCENE.map_layer:registerWalkCb(callback)   						
				local detailMapNode = require("src/layers/map/DetailMapNode")
   				detailMapNode:goToMapPos(self.mapID, cc.p(recode.q_center_x, recode.q_center_y), true)
			end
		end
    elseif userInfo.lastFbType == commConst.CARBON_DRAGON_SLIAYER then
        if G_MAINSCENE and G_MAINSCENE.map_layer and self.monsterData ~= nil and self.currCircle and self.monsterData[self.currCircle] ~= nil then
            local tmpNewPos = cc.p(tonumber(self.monsterData[self.currCircle][4]), tonumber(self.monsterData[self.currCircle][5]));
            -- 指向箭头
            G_MAINSCENE:showArrowPointToMonster(true, tmpNewPos, true);

            -- 自动寻路
            G_MAINSCENE.map_layer:removeWalkCb();
			local callback = function()
				G_MAINSCENE.map_layer:removeWalkCb()
				game.setAutoStatus(AUTO_ATTACK)
			end
            G_MAINSCENE.map_layer:registerWalkCb(callback);
            local detailMapNode = require("src/layers/map/DetailMapNode");
            if detailMapNode and self.mapID then
   				detailMapNode:goToMapPos(self.mapID, tmpNewPos, true);
            end
        end
	end
end


function FbMapLayer:updateProgress(isfinished)
	--cclog("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~self.deadNum"..self.deadNum..self.currNum..self.currCircle..self.totalCircleNum)
	local progScale
	if isfinished then
		progScale = 100
		self.isfinished = true
	else
	 	progScale = math.floor((self.deadNum/self.currNum+self.currCircle-1)/self.totalCircleNum*100)
	end
	if self.progress then
		if userInfo.lastFbType == 4 then
			self.progress:setPercentage(self.currBlood*100/self.maxBlood)
			self.labProgress:setString(tostring(self.currBlood))
			-- if self.currBlood <= 0 then
			-- 	self:showOverView(false)
			-- end
		else
			self.progress:setPercentage(progScale)
			self.labProgress:setString(""..progScale.."%")
		end
	end

	if userInfo.lastFbType == 4 and self.deadNum >= self.currNum then
		userInfo.currDefenseFloor = userInfo.currDefenseFloor+1
		setLocalRecordByKey(2,"subFbType",""..userInfo.currDefenseFloor)
	end
end

function FbMapLayer:updateTimeLeft(delTime)
	if userInfo.lastFbType ~= commConst.CARBON_MULTI_GUARD and userInfo.lastFbType ~= commConst.CARBON_PRINCESS then
		--因为 self.mineBegin = true 重新计数
		if self.mineBegin and userInfo.lastFbType == commConst.CARBON_MINE then
			delTime = 1
			self.mineBegin =false
		end
		self.timeLeft = self.timeLeft - delTime
		if self.timeLeft >= 0 and not self.isOver then
			local str = secondParse(self.timeLeft)
			if userInfo.lastFbType == 3 or userInfo.lastFbType == 4 or userInfo.lastFbType == commConst.CARBON_DRAGON_SLIAYER or userInfo.lastFbType == commConst.CARBON_MINE then
				str = self.timeLeft;
			end

			if self.labTime then
				self.labTime:setString(str)
			end
		end
	elseif not self.isOver then
		self.timeLeft = self.timeLeft + 1
		self.passedTimeLab:setString(secondParse(self.timeLeft))
	end

    -- 屠龙传说倒计时处理
    if self.timeLeft and userInfo and userInfo.lastFbType == commConst.CARBON_DRAGON_SLIAYER then
                    
        if self.timeLeft <= 10 then
            self.m_willNext = false;
        else
            -- 是否需要拾取物品
            local isCanNext = true;
            if self.goods_tab and tablenums(self.goods_tab) > 0 then
                if game.getAutoStatus() == AUTO_ATTACK and self.on_pickup then
                    isCanNext = false;
                end
            end
                    
            -- 是否需要提示下一波
            if isCanNext and self.m_willNext == true then
                TIPS({str = string.format(game.getStrByKey("fb_monsterComm"), self.currCircle) })
                self:showNextCircleMonsterWay();

                self.m_willNext = false;
            end
        end
    elseif self.timeLeft and userInfo and userInfo.lastFbType == commConst.CARBON_MINE and not self.isOver and self.robMine then
    
    	if self.timeLeft <= 0 and (not self.m_mineData or self.m_mineData.totalProgress ~= self.m_mineData.progress) then 
    		local robMineEndData = {}
      		robMineEndData.isWin = false
    		self:showRobMineResult(robMineEndData, 0)
    	end              
    end
end

function FbMapLayer:updateMonsterInfo(flushRoad1, flushRoad2, flushRoad3, flushRoad4)
	if userInfo.lastFbType ~= commConst.CARBON_MULTI_GUARD and userInfo.lastFbType ~= commConst.CARBON_PRINCESS then

		self.labCurrFloor:setString(string.format(game.getStrByKey("fb_enemyOrder2"),tostring(userInfo.currDefenseFloor)))
		local temp = require("src/config/FBDefense")[userInfo.currDefenseFloor]
		self.monsterData = stringToTable(temp.q_monster)
		local monsterName = getConfigItemByKey("monster","q_id",tonumber(self.monsterData[1][2]),"q_name")
		if monsterName then
			self.labCurrMonster:setString(monsterName)
		end
	else
        if self.longMaiNode:getChildByTag(500) then
			self.longMaiNode:removeChildByTag(500)
		end
		local LabNode = cc.Node:create()
		self.longMaiNode:addChild(LabNode, 100, 500)
        ------------------------------------------------------------------------------------------------

		self.monsterStatics = {}

        local function getMonsterCfgByRoad(road)
            if road == 1 then
                return self.fbData.q_monster1;
            elseif road == 2 then
                return self.fbData.q_monster2;
            elseif road == 3 then
                return self.fbData.q_monster3;
            else
                return self.fbData.q_monster4;
            end
        end
		

        local ARROW_LAST_TIME = 10;
        local tmpPer = 0;
        ------------------------------- 第一个刷怪点[第一个参数一定存在，必须刷出一路怪来]        
		if flushRoad1 and flushRoad1 > 0 then
            local monsterStartPos1 = nil;

            local monsterData = stringToTable(getMonsterCfgByRoad(flushRoad1),"}")
            local k = 0
		    for i=1, #monsterData do
			    if tonumber(monsterData[i][1]) == self.currCircle then
				    local num = tonumber(monsterData[i][3]);

                    if monsterStartPos1 == nil then
                        monsterStartPos1 = cc.p(tonumber(monsterData[i][4]), tonumber(monsterData[i][5]));
                    end
				
				    local currM = getConfigItemByKey("monster", "q_id", tonumber(monsterData[i][2]))
				    local lab = createLabel(LabNode, currM.q_name , cc.p(15, 175 - k * 30), cc.p(0.0, 0.5), 18)
				    lab:setColor(MColor.lable_black)
				    lab = createLabel(LabNode, game.getStrByKey("fb_numLeft2") .. " " .. num, cc.p(165, 175 - k * 30), cc.p(0.0, 0.5), 18)
				    lab:setColor(MColor.lable_black)
				    table.insert(self.monsterStatics,{tonumber(monsterData[i][2]), num, lab})
				    k = k + 1
			    end
		    end

            if monsterStartPos1 then
                tmpPer = tmpPer+ARROW_LAST_TIME;
                local actions = {}
			    actions[#actions+1] = cc.CallFunc:create(function() 
					    G_MAINSCENE:showArrowPointToMonster(true, monsterStartPos1, true);
				    end)
                actions[#actions+1] = cc.DelayTime:create(ARROW_LAST_TIME)
                actions[#actions+1] = cc.CallFunc:create(function() 
					    G_MAINSCENE:showArrowPointToMonster(false);
				    end)
			    G_MAINSCENE:runAction(cc.Sequence:create(actions))    
            end    
        end

        local function udpateSecondRoadInfo(flushRoad2, per)
            local monsterStartPos2 = nil;

            local tmpStatics = {};
            local monsterData = stringToTable(getMonsterCfgByRoad(flushRoad2),"}")
            local k = 0
		    for i=1, #monsterData do
			    if tonumber(monsterData[i][1]) == self.currCircle then
				    local num = tonumber(monsterData[i][3]);

                    if monsterStartPos2 == nil then
                        monsterStartPos2 = cc.p(tonumber(monsterData[i][4]), tonumber(monsterData[i][5]));
                    end

                    local tmpMonsterId = tonumber(monsterData[i][2]);
                    if tmpStatics[tmpMonsterId] then
                        tmpStatics[tmpMonsterId] = tmpStatics[tmpMonsterId] + num;
                    else
                        tmpStatics[tmpMonsterId] = num;
                    end
				    
				    k = k + 1
			    end
		    end

            -- 汇总到第一刷怪点
            for k,v in pairs(self.monsterStatics) do
       			if tmpStatics[v[1]] then
                    v[2] = v[2] + tmpStatics[v[1]];
                    v[3]:setString(game.getStrByKey("fb_numLeft2") .. " " .. v[2]);
       			end
       		end

            if monsterStartPos2 then
                local actions = {}
                actions[#actions+1] = cc.DelayTime:create(per + 0.01)
			    actions[#actions+1] = cc.CallFunc:create(function() 
					    G_MAINSCENE:showArrowPointToMonster(true, monsterStartPos2, true);
				    end)
                actions[#actions+1] = cc.DelayTime:create(ARROW_LAST_TIME)
                actions[#actions+1] = cc.CallFunc:create(function() 
					    G_MAINSCENE:showArrowPointToMonster(false);
				    end)
			    G_MAINSCENE:runAction(cc.Sequence:create(actions))  
            end
        end
        ------------------------------- 第二个刷怪点
        if flushRoad2 and flushRoad2 > 0 then
            udpateSecondRoadInfo(flushRoad2, tmpPer);
            tmpPer = tmpPer+ARROW_LAST_TIME;
        end

        ------------------------------- 第三个刷怪点
        if flushRoad3 and flushRoad3 > 0 then
            udpateSecondRoadInfo(flushRoad3, tmpPer);
            tmpPer = tmpPer+ARROW_LAST_TIME;
        end

        ------------------------------- 第四个刷怪点
        if flushRoad4 and flushRoad4 > 0 then
            udpateSecondRoadInfo(flushRoad4, tmpPer);
            tmpPer = tmpPer+ARROW_LAST_TIME;
        end
        
		self.circleLab:setString(string.format(game.getStrByKey("fb_enemyOrder3"),tostring(self.currCircle)))
	end
end

-- self.m_nowPrizeCircle [0 今天一波都没打过 1~5 今天打过5波]
function FbMapLayer:UpdateMultiCarbonInfo()
    if userInfo.lastFbType ~= commConst.CARBON_MULTI_GUARD or self.fbData == nil then
        return;
    end

    if self.m_multiScrollView then
        self.m_multiScrollView:removeFromParent();
        self.m_multiScrollView = nil;
    end

    local circelNum = 5;--MColor.lable_yellow
    local rewardCfg = stringToTable(self.fbData.reward, "}")
    if rewardCfg and rewardCfg[1] then
        -- 奖励
        local awards = {}
        local DropOp = require("src/config/DropAwardOp")

        local carbonStr = "";
        -- 声望数目
        local prestigeNum = 0;
        
        for i=1, circelNum do
            prestigeNum = 0;
            local awardsConfig = DropOp:dropItem_ex(tonumber(rewardCfg[1][i]));
            if awardsConfig then
                for i=1, #(awardsConfig) do
                    ---------------------------------------------------------------------------------------------
                    if awardsConfig[i].q_item == commConst.ITEM_ID_PRESTIGE then
                        prestigeNum = prestigeNum + tonumber(awardsConfig[i].q_count);
                    end
                    ---------------------------------------------------------------------------------------------
                end
            end
            carbonStr = carbonStr .. "^c(lable_black)" .. game.getStrByKey("fb_circle" .. i) .. game.getStrByKey("sheng_wang") .. game.getStrByKey("award") .. ": " .. prestigeNum .. game.getStrByKey("achievement_reate_point") .. "(^";
            if i <= self.m_nowPrizeCircle then
                carbonStr = carbonStr .. "^c(green)" .. game.getStrByKey("achievement_title_complete") .. "^^c(lable_black))^";
            else
                carbonStr = carbonStr .. "^c(red)" .. game.getStrByKey("achievement_title_not_complete") .. "^^c(lable_black))^";
            end

            if i ~= circelNum then
                carbonStr = carbonStr .. "\n";
            end
        end
        
        self.m_multiScrollView = cc.ScrollView:create()  
           
        local function createTextNode()
            local tempNode = cc.Node:create()

            -- function RichText:ctor(parent, pos, size, anchor, lineHeight, fontSize, fontColor, tag, zOrder, isIgnoreHeight)
            local multiCarbonText = require("src/RichText").new(tempNode, cc.p( 0, 0 ) , cc.size( 280 , 0 ) , cc.p( 0 , 0 ) , 20 , 18 , MColor.white );
            multiCarbonText:setAutoWidth();
            multiCarbonText:addText(carbonStr);
	        multiCarbonText:format();

            tempNode:setContentSize( cc.size( 300 , math.abs( multiCarbonText:getContentSize().height )  ) )
                
            return tempNode
        end

        -- 仅根据当前波数显示3行
        self.m_multiScrollView:setViewSize(cc.size( 300, 60) )
        self.m_multiScrollView:setPosition( cc.p( 0 , 20  ) )
        self.m_multiScrollView:ignoreAnchorPointForPosition(true)
        self.m_multiScrollView:setContainer( createTextNode() )
        self.m_multiScrollView:updateInset()
        self.m_multiScrollView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL )
        self.m_multiScrollView:setClippingToBounds(true)
        self.m_multiScrollView:setBounceable(true)
        self.m_multiScrollView:setDelegate()
        local tmpScrollH = 0;
        if self.currCircle <= (circelNum-3) then
            tmpScrollH = (-1) * (3 - self.currCircle) * 20;
        end
        self.m_multiScrollView:setContentOffset(cc.p(self.m_multiScrollView:getContentOffset().x, tmpScrollH))
        self.m_multiCarbonInfoSpr:addChild(self.m_multiScrollView)
    end
end

function FbMapLayer:autoGetCallBack(delTime)
	self.autoGetTimeLeft = self.autoGetTimeLeft - delTime
	if self.autoGetTimeLeft >= 0 then
		if self.autoGet then
			self.autoGet:setString(""..self.autoGetTimeLeft)
		end

        if userInfo ~= nil and (userInfo.lastFbType == commConst.CARBON_DRAGON_SLIAYER) then
            if self.exitBtn then
                local exitBtnLabel = self.exitBtn:getChildByTag(1);
                if exitBtnLabel then
                    exitBtnLabel:setString(game.getStrByKey("fb_leave") .. "(" .. self.autoGetTimeLeft .. ")");
                end
            end
        end
	end

	if self.autoGetTimeLeft <= 0 then
        if userInfo ~= nil and (userInfo.lastFbType == commConst.CARBON_DRAGON_SLIAYER or userInfo.lastFbType == commConst.CARBON_MULTI_GUARD) then
            self:fbExit();
        else
		    self:closeOverView()
        end
		self.autoGetTimeLeft = nil
	end
end

function FbMapLayer:closeOverView()
	--log("FbMapLayer:closeOverView")
	if self.overView then
		removeFromParent(self.overView)
		self.overView = nil
		self.autoGet = nil
	end
	if self.fbSettlementcolorbg then
		removeFromParent(self.fbSettlementcolorbg)
		self.fbSettlementcolorbg = nil
	end
	if self.isWin then
		--新手引导副本退出
	else
		self:fbExit()
	end
end

-- 屠龙传说-铁血魔城最后一波修改剧情要求
function FbMapLayer:ChangeDragonPlotReq()
    if self.m_dragonCarbon ~= nil and self.m_dragonCarbon == commConst.DRAGON_BLOOD_CITY then
        self.m_dragonCollect = self.m_dragonCollect + 1;

        local cfgReqStr = "";
        if self.m_dragonReq then
            cfgReqStr = self.m_dragonReq .. "  ("  .. self.m_dragonCollect .. "/3)";
        end
        if self.m_dragonProgressLal then
            self.m_dragonProgressLal:setString(cfgReqStr);
        end
    end
end

-- 屠龙传说- -- 去除教主雷电特效特效
function FbMapLayer:RemoveMasterThunderEff(isWin)
    if G_MAINSCENE ~= nil then
        G_MAINSCENE:showArrowPointToMonster(false);
    end

    if self.m_dragonBossGuid ~= nil and self.m_dragonCarbon == commConst.DRAGON_BABEL and self.item_Node ~= nil then
        local babelBoss = self.item_Node:getChildByTag(self.m_dragonBossGuid);
        if babelBoss then
            babelBoss = tolua.cast(babelBoss,"SpriteMonster");
            if babelBoss then
                local topNode = babelBoss:getTopNode();
                if topNode ~= nil and topNode:getChildByTag(123) then
                    topNode:removeChildByTag(123);

                    local msgItem = getConfigItemByKeys("clientmsg",{"sth","mid"},{EVENT_COPY_SETS,18});
                    if msgItem then
                        TIPS( { type = msgItem.tswz , str = msgItem.msg } );
                    end
                end
            end
        end
    end

    -- 弹出结束界面
    self:showOverView(isWin);
    
    self.m_willNext = false;
end

function FbMapLayer:showOverView(isWin)
	self.isOver = true
	self.isWin = isWin
	if self.isWin then
		AudioEnginer.playEffect("sounds/fbWin.mp3", false)
	end

    -- 屠龙传说 统一发奖界面
    if userInfo ~= nil then
        if userInfo.lastFbType==commConst.CARBON_MULTI_GUARD then
            if (not isWin) then
                if self.MulityObjId then
                    local monster = self.item_Node:getChildByTag(self.MulityObjId);
                    if monster ~= nil then
			            local m = tolua.cast(monster,"SpriteMonster")
			            if m then
				            m:gotoDeath(7)
			            end
                    end
		        end                
            end
        elseif userInfo.lastFbType == commConst.CARBON_DRAGON_SLIAYER then
            if isWin then
                
                self.autoGetTimeLeft = self.timeLeft - 2;

                if self.exitBtn then
                    local exitBtnLabel = self.exitBtn:getChildByTag(1);
                    if exitBtnLabel then
                        exitBtnLabel:setString(game.getStrByKey("fb_leave") .. "(" .. self.autoGetTimeLeft .. ")");
                    end
                end

                startTimerActionEx(self.item_Node, 1, true, function(delTime) self:timeLabUpdate(delTime) end)

                return;
            end
        elseif userInfo.lastFbType == commConst.CARBON_MINE then
        	if isWin then
        		return 
        	end
        elseif userInfo.lastFbType == commConst.CARBON_PRINCESS then
        	if isWin then
        		return 
        	end
        end

    end
    

	local str,str2 = nil,nil
	if isWin then
        str = "win"
		str2 = game.getStrByKey("lotteryEx_sure")
	else
        str = "fail"
		str2 = game.getStrByKey("lotteryEx_sure")
	end
	local colorbg = cc.LayerColor:create(cc.c4b(0, 0, 0, 175))
	G_MAINSCENE.base_node:addChild(colorbg)
	colorbg:setLocalZOrder(200)
	self.fbSettlementcolorbg = colorbg

	self.overView = cc.Layer:create()
	self.overView:setContentSize(cc.size(960, 640))
	self.overView:setPosition(cc.p(g_scrSize.width/2, g_scrSize.height/2))
	self.overView:ignoreAnchorPointForPosition(false)
	self.overView:setAnchorPoint(cc.p(0.5, 0.5))
	G_MAINSCENE.base_node:addChild(self.overView, 200)
	local passLvl = "B"
	local xp = 0
	local temp = nil

	local addTitle = function ()
		local TitleNode = cc.Node:create()
		self.overView:addChild(TitleNode)
		local addLight = function()
			if not isWin then return end
			local node = cc.Node:create()
			local light = createSprite(node, "res/fb/light.png", cc.p(400, -12), cc.p(0.5, 0.5), 200)
			node:setContentSize(light:getContentSize())
			local rotate = cc.RotateBy:create(0.1, 6)
			local forever = cc.RepeatForever:create(rotate)		
			light:runAction(forever)

		    local scrollView1 = cc.ScrollView:create()
		    local width , height = 800 , 200
		    scrollView1:setViewSize(cc.size( width , height ))
		    scrollView1:setPosition(cc.p(480, 510))
		    scrollView1:setAnchorPoint(cc.p(0.5, 0))
		    scrollView1:ignoreAnchorPointForPosition(false)
		    scrollView1:setContainer( node )
		    scrollView1:updateInset()

		    scrollView1:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL )
		    scrollView1:setClippingToBounds(true)
		    scrollView1:setBounceable(true)
		    scrollView1:setDelegate()
			scrollView1:setTouchEnabled(false)
			TitleNode:addChild(scrollView1)
		end			
        local titlePath = "res/fb/"..str..".png";
        local tmpZorder = 200;
        if userInfo ~= nil and (userInfo.lastFbType == commConst.CARBON_DRAGON_SLIAYER or userInfo.lastFbType == commConst.CARBON_MULTI_GUARD) then
            if isWin then
                titlePath = "res/fb/win_1.png";
            else
                titlePath = "res/fb/fail_1.png";
            end
            tmpZorder = 201;
        end

		createSprite(TitleNode, titlePath, cc.p(480,550), cc.p(0.5, 0.5), tmpZorder)
		local bgLine = createSprite(TitleNode, "res/fb/"..str.."Bg.png", cc.p(480,510), cc.p(0.5, 1), 200)
		TitleNode:setOpacity(0)
		bgLine:setVisible(false)
		TitleNode:setPosition(cc.p(0, display.cy - 550))
		TitleNode:runAction(cc.FadeIn:create(0.3))
		TitleNode:runAction(cc.Sequence:create(cc.DelayTime:create(0.6),
											   cc.MoveTo:create(0.4, cc.p(0, 0)),
											   cc.DelayTime:create(0.1),
											   cc.CallFunc:create(function() bgLine:setVisible(true) end) ,
											   cc.CallFunc:create(addLight) 
											  )
							)
		return 1.8
	end

	local addPassInfo = function ()
		if not isWin then return 0 end
		local InfoNode = cc.Node:create()
		self.overView:addChild(InfoNode)
		if userInfo.lastFbType ~= commConst.CARBON_MULTI_GUARD then
			if userInfo.lastFbType == 1 or userInfo.lastFbType == 3 then
				local passTime = createSprite(InfoNode, "res/fb/passTime.png", cc.p(304, 464), nil)
				if self.time == nil then self.time = 0 end
				createLabel(passTime, secondParse(self.time), 
				  cc.p(passTime:getContentSize().width + 20, passTime:getContentSize().height/2), cc.p(0, 0.5), 32):setColor(MColor.lable_yellow)
				createSprite(InfoNode, "res/fb/textbg.png", cc.p(480, 408), cc.p(0.5, 0.5))
				createLabel(InfoNode, game.getStrByKey("fb_myShortestTime1"), cc.p(passTime:getPositionX() + passTime:getContentSize().width/2 + 15, 408), cc.p(1, 0.5), 24, true):setColor(MColor.yellow)
				local myBestTime = createLabel(InfoNode, "", cc.p( 399, 408), cc.p(0, 0.5), 24)
				if userInfo.fbMyBestTime == 0 then
					--userInfo.fbMyBestTime = self.time
					--myBestTime:setString(game.getStrByKey("fb_youNotPass"))
					--myBestTime:setColor(MColor.red)
					myBestTime:setString(secondParse(self.time))
				elseif userInfo.fbMyBestTime then
					myBestTime:setString(secondParse(userInfo.fbMyBestTime))
				end
				
				createSprite(InfoNode, "res/fb/textbg.png", cc.p(480, 348), cc.p(0.5, 0.5))
				createLabel(InfoNode, game.getStrByKey("fb_serverBestTime"), cc.p(passTime:getPositionX() + passTime:getContentSize().width/2 + 15, 348), cc.p(1, 0.5), 24, true):setColor(MColor.yellow)
				local serverBestTime = createLabel(InfoNode, "", cc.p( 399, 348), cc.p(0, 0.5), 24)
				if userInfo.currbestTime ~= 0 and userInfo.currbestTime < self.time then
					serverBestTime:setString(userInfo.fbBestName.. "   " .. secondParse(userInfo.currbestTime))
				else
					-- serverBestTime:setString(game.getStrByKey("fb_noOnePass"))
					-- serverBestTime:setColor(MColor.red)
					serverBestTime:setString(G_ROLE_MAIN:getTheName().. "   " .. secondParse(self.time))
				end
			end
		else
			local passTime = createSprite(InfoNode, "res/fb/passTime.png", cc.p(304, 400), nil)
			createLabel(passTime, secondParse(self.timeLeft), 
                cc.p(passTime:getContentSize().width + 20, passTime:getContentSize().height/2), cc.p(0, 0.5), 32)--:setColor(MColor.purple)
		end
		return 0.5
	end

	local addAward = function()
		local AwardNode = cc.Node:create()
		self.overView:addChild(AwardNode)

        local function addLostBtn()
		    createLabel(AwardNode, game.getStrByKey("dragon_tip"), cc.p(480, 425), nil, 22):setColor(MColor.lable_yellow)
		    createLabel(AwardNode, game.getStrByKey("fail_text"), cc.p(480, 170), nil, 22):setColor(MColor.lable_yellow)
		    local func = function (num)
			    if num == 1 then
				    __GotoTarget({ru = "a137", index = 2})
			    elseif num == 2 then
				    __GotoTarget({ru = "a136", index = 1})
			    else
				    __GotoTarget({ru = "a136", index = 1})
			    end
		    end

            -- 注册全局退出事件名称
            local globalEventName = "";
            if userInfo.lastFbType == commConst.CARBON_DRAGON_SLIAYER then
                globalEventName = "FbDragonFailCallBack";
            else
                globalEventName = "FbMultiFailCallBack";
            end

		    local menuText = {game.getStrByKey("tiSheng") .. game.getStrByKey("faction_top_level")
						 ,game.getStrByKey("wr_advance_start") .. game.getStrByKey("equipment") 
						 ,game.getStrByKey("wing") .. game.getStrByKey("wr_advance_start")
						 }
		    for i=1,3 do
			    local spr = createMenuItem(AwardNode, "res/fb/tower/btn"..i..".png", cc.p(480 - (2-i)* 170, 330), function()
				    g_EventHandler[globalEventName] = function() func(i) end 
                    self:fbExit();
				 end)
			    spr:setScale(0.5)

			    local item = createMenuItem(AwardNode, "res/component/button/39.png", cc.p(480 - (2-i)* 170, 220), function()
				    g_EventHandler[globalEventName] = function() func(i) end 
                    self:fbExit();
                end)
			    createLabel(item, menuText[i], getCenterPos(item), nil,22, true)
		    end
        end
        
        if not isWin then
            if userInfo ~= nil and (userInfo.lastFbType == commConst.CARBON_DRAGON_SLIAYER or userInfo.lastFbType == commConst.CARBON_MULTI_GUARD) then
                addLostBtn();
            end
            return 0.6
        else
            if userInfo ~= nil and userInfo.lastFbType == commConst.CARBON_MULTI_GUARD and self.reward.Num <= 0 then
                createLabel(AwardNode,  game.getStrByKey("multiReward"), cc.p(304, 270), cc.p(0, 0), 34, true, nil, nil, MColor.lable_yellow);
                return 0.6;
            end
        end

        local sprPos = cc.p( 304, 270);
		local pos = cc.p( 304, 270);
		if userInfo.lastFbType == 1 or userInfo.lastFbType == 3 then
            sprPos = cc.p( 304, 270)
			pos = cc.p( 304, 270)
        elseif userInfo.lastFbType == commConst.CARBON_MULTI_GUARD then
            sprPos = cc.p( 304, 270)
            pos = cc.p( 304, 270 + 80)
		else
            sprPos = cc.p( 304, 270 + 140)
			pos = cc.p( 304, 270 + 140)
		end

		local award = createSprite(self.overView, "res/fb/passAward.png", sprPos, nil)
		local rewordIcons = {}
		local ids = {999999, 999998, 888888, 222222, 444444, 777777}
		dump(self.reward.Num)

        -- 声望、经验数目
        local expNum = 0;
        local prestigeNum = 0;
        ---------------------------------------------------------------------------------------------
		for i=1, self.reward.Num do

            ---------------------------------------------------------------------------------------------
            if userInfo and userInfo.lastFbType == commConst.CARBON_MULTI_GUARD then
                if self.reward.item[i][1] == commConst.ITEM_ID_PRESTIGE then
                    prestigeNum = prestigeNum + tonumber(self.reward.item[i][2]);
                elseif self.reward.item[i][1] == commConst.ITEM_ID_EXP then
                    expNum = expNum + tonumber(self.reward.item[i][2]);
                end
            end
            ---------------------------------------------------------------------------------------------

			local Mprop = require "src/layers/bag/prop"
            local propPic = Mprop.new(
            {
                protoId = self.reward.item[i][1],
                num = tonumber(self.reward.item[i][2]),
                swallow = true,
                showBind = true,
                isBind = tonumber(self.reward.item[i][3] or 0) == 1, 
                cb = "tips",
            })
            local flg = false
            for j=1,#ids do
            	if self.reward.item[i][1] == ids[j] then
            		table.insert(rewordIcons, 1, propPic)
            		flg = true
            		break
            	end
            end
            if not flg then
            	table.insert(rewordIcons, propPic)
            end
		end
		local countNum = 1
		local Num = #rewordIcons
		dump(Num)
		for k,v in pairs(rewordIcons) do
			local x = 400 - Num / 2 * 80 + countNum * 80
			v:setPosition(cc.p(x, pos.y - 80 + 5))
			v:setAnchorPoint(cc.p(0, 0.5))
			AwardNode:addChild(v)
			countNum = countNum + 1
		end
		AwardNode:setPosition(cc.p(0, 0))
		-- AwardNode:runAction(cc.Sequence:create(cc.MoveTo:create(0.2, cc.p(0, 0))
		-- 									  )
		-- 					)

        if userInfo and userInfo.lastFbType == commConst.CARBON_MULTI_GUARD then
            if expNum > 0 then
                -- 经验展示
		        self:showExpNumer(expNum, nil, 0.1, "res/mainui/number/4.png" , commConst.ePickUp_XP )
            end
	        if prestigeNum > 0 then
		        -- 声望展示
		        self:showExpNumer(prestigeNum, nil, 0.1, "res/mainui/number/5.png" , commConst.ePickUp_Prestige)
            end
        end

		return 0.6
	end

	local addLev = function ()
		if not isWin then return 0 end
		local LevNode = cc.Node:create()
		self.overView:addChild(LevNode)
		local sprLev = nil
		local lvl = nil
		if userInfo.lastFbType == 1 then
		    if self.time > self.levelTimes[1] and self.time <= self.levelTimes[2] then
	    		lvl = "A"
	    	elseif self.time > self.levelTimes[2] and self.time <= self.levelTimes[3] then
	    		lvl = "B"
	    	elseif self.time<= self.levelTimes[1] then
	    		lvl = "S"
	    	end
	    	if lvl then
	    		sprLev = createSprite(LevNode,"res/fb/"..lvl..".png",cc.p(755, 370),cc.p(0.5,0.5))
	    	end
		elseif userInfo.lastFbType == commConst.CARBON_MULTI_GUARD then
			local pp = self.currBlood/self.timeLeft
			if pp > tonumber(self.fbData.aping) and pp < tonumber(self.fbData.bping) then
				passLvl = "A"
			elseif pp > tonumber(self.fbData.bping) then
				passLvl = "S"
			end
			sprLev = createSprite(LevNode,"res/fb/"..passLvl..".png",cc.p(755, 370),cc.p(0.5,0.5))
		end

		if sprLev then
			LevNode:setPosition(cc.p(0, 0))
			LevNode:setOpacity(0)
			sprLev:setScale(2)
			LevNode:runAction(cc.Sequence:create(cc.FadeIn:create(0.05),
												 cc.MoveTo:create(0.12, cc.p(0, 0))
												 )
							 )
			sprLev:runAction(cc.ScaleTo:create(0.15, 1))
			return 0.2
		end
		return 0
	end

	local addNewCode = function ()
		if not isWin then return 0 end
		if userInfo.lastFbType == 1 or userInfo.lastFbType == 3 then
			local newCode = cc.Node:create()
			self.overView:addChild(newCode)
			local new99Spr = createSprite(newCode, "res/fb/99.png", cc.p(145, 370), nil)
			local newSpr = nil
			if 0 == userInfo.fbMyBestTime or (userInfo.fbMyBestTime > self.time ) then
				newSpr = createSprite(newCode, "res/fb/newCode.png", cc.p(160, 470), nil)
			end
			new99Spr:setScale(3)
			new99Spr:setOpacity(0)
			new99Spr:runAction(cc.FadeIn:create(0.12))
			new99Spr:runAction(cc.ScaleTo:create(0.15, 1))			
			if newSpr then
				newSpr:setPosition(cc.p( 145, 470))
				newSpr:setScale(3)
				newSpr:setVisible(false)
				newSpr:runAction(cc.Sequence:create(cc.DelayTime:create(0.3)
													,cc.Show:create()
													,cc.ScaleTo:create(0.15, 1)
													-- ,cc.TintTo:create(0.2, 10, 220, 0)
													-- ,cc.TintTo:create(0.2, 6, 110, 220)
													)
								)	
				return 0.6
			end
			return 0.3
		end
		return 0
	end

	local addBtn = function ()
		if not isWin and userInfo ~= nil and userInfo.lastFbType ~= commConst.CARBON_DRAGON_SLIAYER and userInfo.lastFbType ~= commConst.CARBON_MULTI_GUARD then
			createLabel(self.overView, game.getStrByKey("fail_tip"), cc.p(480,350), nil, 30)
		end
		self.autoGetTimeLeft = 10
        if  userInfo ~= nil and userInfo.lastFbType == commConst.CARBON_MULTI_GUARD then
            self.autoGetTimeLeft = 5;
        end
		local str = game.getStrByKey("fb_secsToGetPrize")
		if not isWin then
			str = game.getStrByKey("fb_secsToGetOut")
		end
		local lab = createLabel(self.overView, str, cc.p(480 + 20, 45), nil, 20)
		lab:setColor(MColor.green)
		self.autoGet = createLabel(self.overView, "" .. self.autoGetTimeLeft , cc.p(lab:getPositionX() - lab:getContentSize().width/2, 45), cc.p(1, 0.5), 20)
		self.autoGet:setColor(MColor.red)

		local func = function()
            if userInfo ~= nil and (userInfo.lastFbType == commConst.CARBON_DRAGON_SLIAYER or userInfo.lastFbType == commConst.CARBON_MULTI_GUARD) then
                self:fbExit();
            else
			    self:closeOverView()
            end
		end
		local item = createMenuItem(self.overView, "res/component/button/50.png", cc.p(480, 100), func)
		createLabel(item, str2, getCenterPos(item), nil, 22, true):setColor(MColor.lable_yellow)
		return 0
	end

	local index = 1
	local actions = {}
	local funcTab = {addTitle, addPassInfo, addNewCode, addAward, addLev, addBtn}

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
			self.overView:runAction(cc.Sequence:create(actions))
		end
	end
	self.overView:runAction(cc.CallFunc:create(loopFunc))
	startTimerActionEx(self.item_Node, 1, true, function(delTime) self:timeLabUpdate(delTime) end)

	local  listenner = cc.EventListenerTouchOneByOne:create()
    listenner:setSwallowTouches(true)
    listenner:registerScriptHandler(function(touch, event)
    									return true 
    								end,cc.Handler.EVENT_TOUCH_BEGAN)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, self.overView)
end

function FbMapLayer:updateMineState()

	if  self.m_mineData then
		local mineState = 0
		if self.m_mineData.totalProgress ~= self.m_mineData.progress then
			mineState =1 
		else
			mineState = 2 
		end
		if self.mineState ~= mineState then
			self.mineState = mineState
			self:addTaskInfo(self.mineState)
		end

		if mineState ==1 and self.m_MineCountLabel then
			self:updateMineCountLabel()
		end
		self.robMine = true
		self.mineBegin = true
		self.timeLeft = self.m_mineData.timeout
		local mineItems = {}
		-- print("FbMapLayer:updateMineState mineCount" ,self.m_mineData.mineCount)
		for i=1,self.m_mineData.mineCount do
			local mine = {}
			mine.matId = 6200032
			mine.time = os.time() + 50000
			table.insert(mineItems , mine)
			-- print("FbMapLayer:updateMineState mineCount add")
		end
		G_ROLE_MAIN:setCarry_ex(G_ROLE_MAIN , mineItems)
		--进度完成 把倒计时隐藏
		if self.m_mineData.totalProgress == self.m_mineData.progress and self.timeBg and not self.exitTimeLeft then
			self.timeBg:setVisible(false)
		end
	end
end




function FbMapLayer:addTaskInfo(idx)  
    self:delTaskInfo()
	-- local bgPanel = createSprite( G_MAINSCENE , "res/common/bg/bg62.png" , cc.p(2, g_scrSize.height-255) , cc.p( 0, 0 ) )
    self.m_tastBg = createSprite(G_MAINSCENE , "res/common/bg/bg62.png" , cc.p(2, g_scrSize.height/2) , cc.p( 0, 0.5 )  )  
    local strTitle = game.getStrByKey("story_gongsha_target_title")
    createLabel(self.m_tastBg, strTitle, cc.p(25,53),cc.p(0,0.5),20,nil,nil,nil,MColor.yellow)
    local strTab = {"story_robmine_target1","story_robmine_target2",}
    local str = game.getStrByKey(strTab[idx])
    if idx == 1 then
        local function go() 
          -- self:onTouchMine(self.mineNode4)
            -- G_MAINSCENE.map_layer:moveMapByPos(cc.p(97, 44), false)
        end
        -- self.m_mineData.totalProgress = proto.totalProgress
        -- self.m_mineData.progress = proto.progress
        -- self.m_mineData.mineCount = proto.mineCount
        -- self.m_mineData.timeout = proto.timeout


        if self.m_mineData.progress == nil then self.m_mineData.progress = 0 end
        local text = string.format(str, self.m_mineData.progress ,self.m_mineData.totalProgress )
        -- self.m_MineCountLabel = createLinkLabel(self.m_tastBg, text, cc.p(25,25),cc.p(0,0.5), 20, false, nil, MColor.lable_yellow, nil, go, true)
  		self.m_MineCountLabel= createLabel( self.m_tastBg , text , cc.p(25,25),cc.p(0,0.5) , 20 , false , nil , nil , MColor.lable_yellow )
			   
    elseif idx ==2 then
        local function gotoNpc()
            if G_MAINSCENE and G_MAINSCENE.map_layer and G_MAINSCENE.map_layer.npc_tab then 
                local touchNpc = nil 
                for k,v in pairs(G_MAINSCENE.map_layer.npc_tab )do
                        --找到npc
                        if k ==11103 then
                            touchNpc = v
                            break 
                        end
                end
                if G_MAINSCENE.map_layer.touchNpcFunc and touchNpc then
                    G_MAINSCENE.map_layer:touchNpcFunc(touchNpc,true)
                end
            end
        end
        local text = string.format(str , self.m_mineData.progress ,self.m_mineData.totalProgress)
        self.m_MineCountLabel = createLinkLabel(self.m_tastBg, text, cc.p(25,25),cc.p(0,0.5), 20, false, nil, MColor.lable_yellow, nil, gotoNpc, true)

    else
        createLabel(self.m_tastBg, str, cc.p(25,25),cc.p(0,0.5),20,nil,nil,nil,MColor.lable_yellow)
    end
    self.m_tastBg:setPosition(cc.p(-280, g_scrSize.height-155))
    self.m_tastBg:runAction(cc.MoveTo:create(1, cc.p(2, g_scrSize.height-155)))
end

function FbMapLayer:delTaskInfo()
    if self.m_tastBg then
        removeFromParent(self.m_tastBg)
        self.m_tastBg = nil
    end
end

function FbMapLayer:updateMineCountLabel()

    local function go() 
        -- self:onTouchMine(self.mineNode4)
    end


    if self.m_MineCountLabel ~= nil then 
        removeFromParent(self.m_MineCountLabel)
        self.m_MineCountLabel = nil 
    end 
    if self.m_mineData.progress == nil then self.m_mineData.progress = 0 end
    local str = game.getStrByKey("story_robmine_target1")
    local text = string.format(str, self.m_mineData.progress ,self.m_mineData.totalProgress )
    -- self.m_MineCountLabel = createLinkLabel(self.m_tastBg, text, cc.p(25,25),cc.p(0,0.5), 20, false, nil, MColor.lable_yellow, nil, go, true)
    self.m_MineCountLabel= createLabel( self.m_tastBg , text , cc.p(25,25),cc.p(0,0.5) , 20 , false , nil , nil , MColor.lable_yellow )
		
end

--副本如果对名字颜色有要求时盖面颜色
function FbMapLayer:setFbRoleNameColor(role , color)
	if not role then return end
	local name_label = role:getNameBatchLabel()
	if role == G_ROLE_MAIN then
		--local hp = role:getHP()
		-- print("-----------------FbMapLayer:setFbRoleNameColor 4 hp" ,hp)

        if name_label then
           self.mainRoleColor = name_label:getColor()
        end
	end
		-- print("-----------------FbMapLayer:setFbRoleNameColor 4" ,name_label)
	
	if name_label then 
	    name_label:setColor(color)
	    G_ROLE_MAIN:changeFactionNameColor(role)
	end
end

return FbMapLayer