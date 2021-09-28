local nearPlayer = class("nearPlayer",require("src/TabViewLayer"))

function nearPlayer:ctor(parent,page)
	self.parent = parent
	self.page = page
	self.lab1 = nil
	self.tipLab = nil
	--createSprite(self, "res/common/bg/bg.png", cc.p(480, 285), cc.p(0.5 , 0.5))
	--createSprite(self,"res/common/bg/bg-6.png",cc.p(480,285))
	local bg = cc.Sprite:create("res/common/scalable/panel_outer_base_1.png",cc.rect(0,0,896,400))
	bg:setAnchorPoint(cc.p(0.5,0))
	bg:setPosition(cc.p(480,100))
	bg:getTexture():setTexParameters(gl.LINEAR, gl.LINEAR, gl.REPEAT, gl.REPEAT)
	self:addChild(bg)
	createScale9Sprite(bg,"res/common/scalable/panel_outer_frame_scale9_1.png",cc.p(448,0),cc.size(896,400),cc.p(0.5,0))	
	self.bg = bg
	self.my_team_view_1 = cc.Node:create()
	self.my_team_view_1:setPosition(cc.p(440,200))
	bg:addChild(self.my_team_view_1)
	self.itemData = {}
	self.itemCount = 0

	self.player_nearby_view = cc.Node:create()
	CreateListTitle(self.player_nearby_view, cc.p(0,170), 888, 43)

	local strs = {game.getStrByKey("fb_team"),game.getStrByKey("team_tt") , game.getStrByKey("team_mn"),game.getStrByKey("faction_top_faction_action")}
	for i=1,#strs do
		createLabel(self.player_nearby_view, strs[i], cc.p(220*i-550 , 170 ), cc.p(0.5,0.5),22 , nil , nil , nil , MColor.lable_yellow )
	end
	
	if G_TEAM_ATUOTURN and G_TEAM_ATUOTURN[1] then 
		createTouchItem(bg,"res/component/checkbox/1.png",cc.p(400,420),function() self:changeSelect(4) end)
		self.allow_spr2 = createSprite(bg,"res/component/checkbox/1-1.png",cc.p(400,420))
		self.allow_spr2:setVisible(getLocalRecord("autoTeam"))
		createLabel(bg, game.getStrByKey("team_autoIn"),cc.p(430,420), cc.p(0,0.5), 18, true, 1, nil,MColor.lable_black)
	end

	createTouchItem(bg,"res/component/checkbox/1.png",cc.p(545,420),function() self:changeSelect(1) end)
	self.allow_spr = createSprite(bg,"res/component/checkbox/1-1.png",cc.p(545,420))
	self.allow_spr:setVisible(getGameSetById(GAME_SET_TEAM_IN) == 1)
	createLabel(bg, game.getStrByKey("team_autoInvite"),cc.p(575,420), cc.p(0,0.5), 18, true, 1, nil,MColor.lable_black)

	createTouchItem(bg,"res/component/checkbox/1.png",cc.p(730,420),function() self:changeSelect(2) end)
	self.allow_spr1 = createSprite(bg,"res/component/checkbox/1-1.png",cc.p(730,420))
	self.allow_spr1:setVisible(getGameSetById(GAME_SET_TEAM) == 1)
	createLabel(bg, game.getStrByKey("team_allowTeam"),cc.p(760,420), cc.p(0,0.5), 18, true, 1, nil,MColor.lable_black)

	self.callGroup = {
						game.getStrByKey("team_all"),game.getStrByKey("team_noT"),game.getStrByKey("team_mainL"),
						game.getStrByKey("team_tcar"),game.getStrByKey("team_tcut"),game.getStrByKey("team_defense"),
						game.getStrByKey("team_defense1"),game.getStrByKey("team_defense2"),game.getStrByKey("team_pk"),
						game.getStrByKey("team_boss"),game.getStrByKey("team_pG"),game.getStrByKey("team_sha"),
					}

	G_TEAM_TARGET = G_TEAM_TARGET or 1

	self:changeMem()

    self:createTableView(self.player_nearby_view,cc.size(900,347),cc.p(-460,-199),true)
	self.player_nearby_view:setPosition(cc.p(448,205))
	bg:addChild(self.player_nearby_view)


	if self.page == 2 then
		self:send(1)
	elseif self.page == 4 then
		self:send(3,G_TEAM_TARGET-1)
	end
	-- g_msgHandlerInst:sendNetDataByTableExEx(TEAM_CS_GET_AOUNDPLAYER, "TeamGetAroundPlayerProtocol", {aroundType = 1})

	-- g_msgHandlerInst:registerMsgHandler(TEAM_SC_GET_AOUNDPLAYER_RET,function(buff)
	-- 	if self.bg then
	-- 	 	self:onAroundPlayer(buff) 
	-- 	end
	-- end)

	self:registerScriptHandler(function(event)
		if event == "enter" then
			g_EventHandler["nearPlayer"] = self
		elseif event == "exit" then
			if G_TEAM_APPLYRED[2] then
				removeFromParent(G_TEAM_APPLYRED[2])
				G_TEAM_APPLYRED[2] = nil
			end
			g_EventHandler["nearPlayer"] = nil
		end
	end)
	local msgids = {CHAT_SC_CALL_RET,TEAM_SC_GET_TEAM_APPLY_RET}
	require("src/MsgHandler").new(self, msgids)	

end

function nearPlayer:send(index,channel)
	if index == 3 then
		g_msgHandlerInst:sendNetDataByTableExEx(TEAM_CS_GET_AOUNDPLAYER, "TeamGetAroundPlayerProtocol", {aroundType = index,aroundValue = channel})
	else
		g_msgHandlerInst:sendNetDataByTableExEx(TEAM_CS_GET_AOUNDPLAYER, "TeamGetAroundPlayerProtocol", {aroundType = index})
	end

	g_msgHandlerInst:registerMsgHandler(TEAM_SC_GET_AOUNDPLAYER_RET,function(buff)
		if self.bg then
		 	self:onAroundPlayer(buff) 
		end
	end)
end

function nearPlayer:changeSelect(chooseOne)
	if self.allow_spr and self.allow_spr1 and chooseOne then
		if chooseOne == 1 then
			local isVisible = self.allow_spr:isVisible()
			self.allow_spr:setVisible(not isVisible)
			setGameSetById(GAME_SET_TEAM_IN,not isVisible and 1 or 0)
			g_msgHandlerInst:sendNetDataByTableExEx(TEAM_CS_CHANGE_AUTOINVITE, "TeamChangeAutoInviteProtocol", { ["inviteValue"] = not isVisible and 2 or 1 ,["inviteType"] = 1 })
		elseif chooseOne == 2 then
			local isVisible = self.allow_spr1:isVisible()
			self.allow_spr1:setVisible(not isVisible)
			setGameSetById(GAME_SET_TEAM,not isVisible and 1 or 0)
			g_msgHandlerInst:sendNetDataByTableExEx(TEAM_CS_CHANGE_AUTOINVITE, "TeamChangeAutoInviteProtocol", { ["inviteValue"] = not isVisible and 2 or 1 ,["inviteType"] = 2 })
		elseif chooseOne == 4 then
			local autoTeamSta = getLocalRecord("autoTeam") 
			local fun = function(checkIsField)
				if checkIsField and G_MAINSCENE.mapId then
					local field = getConfigItemByKey("MapInfo","q_map_id",G_MAINSCENE.mapId,"q_sjlevel")
					local isOutField = string.find(tostring(field),"2") 
					if isOutField then
						g_msgHandlerInst:sendNetDataByTableExEx(TEAM_CS_FAST_ENTER, "TeamFastEnter", {["enterType"] = 2})
					end
				end
				setLocalRecord("autoTeam",not autoTeamSta)
				self.allow_spr2:setVisible(not autoTeamSta)
			end			
			if not autoTeamSta then
				MessageBoxYesNo(nil, game.getStrByKey("team_tip5"), function() fun(true) end  )
			else
				fun()
			end
		end
	end
end

function nearPlayer:changeMem()	
	self.isIamcaptain = false
	self.my_team_view_1:removeAllChildren()	

	local strFun = function(num)
		local n = num == 0 and 0 or (G_TEAM_INFO.memCnt or 0)				
		if self.team_tip1 and self.team_tip2 then
			self.team_tip2:setString(tostring(n).."/"..tostring(num))
		else
			self.team_tip1 = createLabel(self.bg,game.getStrByKey("team_memNum"),cc.p(0,420),cc.p(0,0.5),20,true,nil,nil,MColor.lable_yellow)
			self.team_tip2 = createLabel(self.bg,tostring(n).."/"..tostring(num),cc.p(138,420),cc.p(0,0.5),20,true,nil,nil,MColor.white)
		end
	end
	local CallBack = function()
		if self.parent:getParent() then
			self.parent:getParent():changePage(1)
		end
	end
	if not G_TEAM_INFO.has_team then
		strFun(0)
		local createFunc = function()
			g_msgHandlerInst:sendNetDataByTableExEx(TEAM_CS_CREATE_TEAM, "CreateTeamProtocol", {["teamTarget"] = G_TEAM_TARGET-1})
			CallBack()
		end
		local createFunc1 = function(targetID , node)
			if self.page == 4 then
				g_msgHandlerInst:sendNetDataByTableExEx(TEAM_CS_FAST_ENTER, "TeamFastEnter", {["enterType"] = 1 , ["enterParam"] = G_TEAM_TARGET-1})
			else
				g_msgHandlerInst:sendNetDataByTableExEx(TEAM_CS_FAST_ENTER, "TeamFastEnter", {["enterType"] = 1})
			end
			if not self.isIamcaptain and getGameSetById(GAME_SET_TEAM) == 0 then
				self:changeSelect(2)
			end
			local countDown,actTag = 10,1
			node:setEnabled(false)
			node:getChildByTag(2):setColor(MColor.gray)
			local DelayTime = cc.DelayTime:create(1)
			local CallFunc = cc.CallFunc:create(function()
				countDown = countDown - 1
				if countDown <= 0 then
					node:stopActionByTag(actTag)
					node:setEnabled(true)
					node:getChildByTag(2):setString(game.getStrByKey("team_ingroup"))
					node:getChildByTag(2):setColor(MColor.yellow_gray)
				-- else
					-- node:getChildByTag(2):setString(game.getStrByKey("team_ingroup").."("..tostring(countDown)..")")
					-- node:getChildByTag(2):setColor(MColor.gray)
				end
			end)
			local Sequence = cc.Sequence:create(DelayTime, CallFunc)
			local action = cc.RepeatForever:create(Sequence)
			action:setTag(actTag)
			node:runAction(action)
			CallBack()
		end
		-- if self.page == 2 then
			local menuitem = createMenuItem(self.my_team_view_1,"res/component/button/50.png",cc.p(208,-235),createFunc)
			createLabel(menuitem, game.getStrByKey("create_team"),getCenterPos(menuitem), cc.p(0.5,0.5),24 , true , nil , nil , MColor.yellow_gray )
			local menuitem1 = createMenuItem(self.my_team_view_1,"res/component/button/50.png",cc.p(368,-235),createFunc1,nil,true)
			createLabel(menuitem1,game.getStrByKey("team_ingroup"),getCenterPos(menuitem1),cc.p(0.5,0.5),24 , true , nil , nil , MColor.yellow_gray,2)
		-- end
	else		
		strFun(10)
		local btnFunc = function(tag,sender)
			if sender==self.exit_team_btn then
				--self:changeStatus({false})
				G_TEAM_APPLYRED[1] = false
				if G_TEAM_APPLYRED[2] then			
					removeFromParent(G_TEAM_APPLYRED[2])
					G_TEAM_APPLYRED[2] = nil
				end
				G_MAINSCENE:refreshTeamRedDot(false)
				g_msgHandlerInst:sendNetDataByTableExEx(TEAM_CS_LEAVE_TEAM, "TeamLeaveTeamProtocol", {})
			elseif sender==self.hanren_btn then
	    		local commConst = require("src/config/CommDef")
	    		local str = "team_hanren"..tostring(G_TEAM_INFO.teamTarget+2)
				local text = game.getStrByKey(str)
				local t = {}
				t.channel = commConst.Channel_ID_Team
				t.message = text
				t.area = 1
				t.callType = 2
				t.paramNum = 2
				t.callParams = {tostring(G_ROLE_MAIN:getTheName()),tostring(G_TEAM_INFO.teamID)}
				g_msgHandlerInst:sendNetDataByTableExEx(CHAT_CS_CALL_MSG, "CallMsgProtocol", t)
			end
		end	
		if userInfo.currRoleStaticId == G_TEAM_INFO.team_data[1].roleId then
			self.isIamcaptain = true
		end
		-- if self.page == 2 then
			self.exit_team_btn = createMenuItem(self.my_team_view_1,"res/component/button/50.png",cc.p(368,-235),btnFunc)
			createLabel(self.exit_team_btn, game.getStrByKey("leave_team"),getCenterPos( self.exit_team_btn ), cc.p(0.5,0.5),24,true):setColor(MColor.yellow_gray)
			self.add_mem_btn = createMenuItem(self.my_team_view_1,"res/component/button/50.png",cc.p(48,-235),function() self:applyList(G_TEAM_INFO.teamID) end)
			if not self.isIamcaptain then
				self.add_mem_btn:setEnabled( false  )
			end
			local size =  self.add_mem_btn:getContentSize()
			createLabel( self.add_mem_btn,game.getStrByKey("team_applyList"),cc.p(size.width/2,size.height/2),nil,24,true,nil,nil,MColor.yellow_gray)
			G_TEAM_APPLYRED[2] = createSprite(self.add_mem_btn,"res/component/flag/red.png",cc.p(size.width,size.height-10))
			if not G_TEAM_APPLYRED[1] then
				G_TEAM_APPLYRED[2]:setVisible(false)
			end
			self.hanren_btn = createMenuItem(self.my_team_view_1,"res/component/button/50.png",cc.p(208,-235),btnFunc)
			createLabel(self.hanren_btn, game.getStrByKey("team_hanrenBtn"), getCenterPos( self.exit_team_btn ), cc.p(0.5,0.5),24,true):setColor(MColor.yellow_gray)
		-- end
	end	
	if self.page == 4 then
		local createTB = function()
			local tarBg = createSprite(self.bg,"res/common/bg/bg27.png",cc.p(480,230),nil,10)
			-- createSprite(tarBg,"res/common/bg/bg27-1.png",cc.p(201,285))
			createScale9Frame(tarBg,
				"res/common/scalable/panel_outer_base_1.png",
				"res/common/scalable/panel_outer_frame_scale9_1.png",
		        cc.p(16, 100),
		        cc.size(370,374),
		        5)
			createLabel(tarBg,game.getStrByKey("team_tt"),cc.p(201,502),nil,26,true,nil,nil,MColor.lable_yellow)
			local closeF = function()
				removeFromParent(tarBg)
				tarBg = nil
			end
			createTouchItem(tarBg,"res/component/button/x2.png",cc.p(tarBg:getContentSize().width-30,tarBg:getContentSize().height-25),closeF)
			local choice = function(cn)
				self.lab1:setString(self.callGroup[cn])
				
			end
			registerOutsideCloseFunc(tarBg,closeF,true)
			local dn = math.ceil(#self.callGroup/2)
			local nodeTemp = nil
			local scrollView = cc.ScrollView:create()
			if nil ~= scrollView then
		        scrollView:setViewSize(cc.size(370,368))
		        scrollView:setPosition(cc.p(14,104))
		        scrollView:setScale(1.0)
		        scrollView:ignoreAnchorPointForPosition(true)
		        local node = cc.Node:create()
		        nodeTemp = node
		        node:setContentSize(cc.size(370,365+67*(dn-5)))
		        scrollView:setContainer(node)
		        scrollView:updateInset()
		        scrollView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL )
		        scrollView:setClippingToBounds(true)
		        scrollView:setBounceable(true)
		        tarBg:addChild(scrollView)
		    end
		    scrollView:setContentOffset( cc.p(  0,  - 67*(dn-5) ) )
		    local posx ,posy = 100,365+67*(dn-5)		    
			local lastTouch = {}
			local spr = {}
			for j = 0,#self.callGroup-1,2 do
				for m = 1,2 do
					if self.callGroup[j+m] then
						spr[j+m] = createSprite(nodeTemp,"res/common/table/cell32.png",cc.p(posx,posy),cc.p(0.5,1))
						if j+m == G_TEAM_TARGET then
							spr[j+m]:setTexture("res/common/table/cell32_sel.png")
							G_TEAM_TARGET = j+m
						end
						createLabel(spr[j+m],self.callGroup[j+m],cc.p(87,33.5),nil,24,true,nil,nil,MColor.lable_yellow)
						
						local  listenner = cc.EventListenerTouchOneByOne:create()
					    listenner:setSwallowTouches(false)
						listenner:registerScriptHandler(function(touch, event)	
								local pt = touch:getLocation()
								local ptTemp = pt		
								pt = nodeTemp:convertToNodeSpace(pt)
								if cc.rectContainsPoint(spr[j+m]:getBoundingBox(),pt) then
									lastTouch = {}
									lastTouch = nodeTemp:convertToWorldSpace( ptTemp )		
									return true
								end
					    	end,cc.Handler.EVENT_TOUCH_BEGAN )
						listenner:registerScriptHandler(function(touch,event)
							local pt = touch:getLocation()
							local theTouch = nodeTemp:convertToWorldSpace( pt )
							pt = spr[j+m]:getParent():convertToNodeSpace(pt)
								if lastTouch and math.abs(lastTouch.x - theTouch.x) < 30 and math.abs(lastTouch.y - theTouch.y) < 30 then			
									if cc.rectContainsPoint(spr[j+m]:getBoundingBox(),pt) then
										spr[G_TEAM_TARGET]:setTexture("res/common/table/cell32.png")
										spr[j+m]:setTexture("res/common/table/cell32_sel.png")
										G_TEAM_TARGET = j+m
									end
								end
					    end,cc.Handler.EVENT_TOUCH_ENDED)
					    listenner:registerScriptHandler(function(touch,event)
							local pt = touch:getLocation()
							pt = spr[j+m]:getParent():convertToNodeSpace(pt)
								if lastTouch and math.abs(lastTouch.x - theTouch.x) < 30 and math.abs(lastTouch.y - theTouch.y) < 30 then			
									if cc.rectContainsPoint(spr[j+m]:getBoundingBox(),pt) then
										setFun(G_DRUG_TAB[num][j+m][1],num,j+m,dnum)
										spr[G_TEAM_TARGET]:setTexture("res/common/table/cell32.png")
										spr[j+m]:setTexture("res/common/table/cell32_sel.png")
										G_TEAM_TARGET = j+m
									end
								end
					    end,cc.Handler.EVENT_TOUCH_CANCELLED)
						local eventDispatcher =  spr[j+m]:getEventDispatcher()
						eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, spr[j+m])
						posx = posx + 174
					end
				end
				posx = 100
				posy = posy - 67
			end
			createTouchItem(tarBg,"res/component/button/50.png",cc.p(201,50),
				function() 
					self:send(3,G_TEAM_TARGET-1)  self.lab1:setString(self.callGroup[G_TEAM_TARGET])  closeF() 
				end,true)
			createLabel(tarBg,game.getStrByKey("sure"),cc.p(201,50),cc.p(0.5,0.5),22,true,nil,nil,MColor.lable_yellow)
		end
		local tItem = createTouchItem(self.my_team_view_1,"res/teamup/targetItem.png",cc.p(-300,-235),function() createTB() end)
		createLabel(tItem,game.getStrByKey("team_tt1"),cc.p(10,25),cc.p(0,0.5),20,true,nil,nil,MColor.lable_yellow)
		self.lab1 = createLabel(tItem,self.callGroup[G_TEAM_TARGET],cc.p(110,25),cc.p(0,0.5),20,true,nil,nil,MColor.yellow_gray)
	end
end

function nearPlayer:applyList(teamId)
	self.theTeamId = teamId
	g_msgHandlerInst:sendNetDataByTableExEx(TEAM_CS_GET_TEAM_APPLY, "TeamGetTeamApplyProtocol", {["teamId"] = teamId})
end

function nearPlayer:showApplyList(params)
	if self.smallBg then
		removeFromParent(self.smallBg)
		self.smallBg = nil
	end
	local smallBg = createSprite(self.bg,"res/common/bg/bg18.png",cc.p(440,220),nil,10)
	local rootSize = smallBg:getContentSize()
	-- 背景图
	createScale9Frame(
        smallBg,
        "res/common/scalable/panel_outer_base.png",
        "res/common/scalable/panel_outer_frame_scale9.png",
        cc.p(33, 17),
       	cc.size(rootSize.width-60, rootSize.height-74),
        5
    )
	-- createSprite(smallBg,"res/common/bg/bg44-2.png",cc.p(430,246))
	createLabel(smallBg,game.getStrByKey("team_applyList"),cc.p(smallBg:getContentSize().width/2,smallBg:getContentSize().height-25),nil,22,true,nil,nil,MColor.yellow_gray)
	--createScale9Sprite(smallBg,"res/common/bg/bg44-1.png",cc.p(415,230),cc.size(770,400))
	createScale9Frame(
            smallBg,
            "res/common/scalable/panel_outer_base_1.png",
            "res/common/scalable/panel_outer_frame_scale9_1.png",
            cc.p(41,30),
            cc.size(770,400),
            4
        )
	self.smallBg = smallBg
	local function closeFun()
		removeFromParent(self.smallBg)
		self.smallBg = nil
	end
	createTouchItem(smallBg,"res/component/button/x2.png",cc.p(smallBg:getContentSize().width-35,smallBg:getContentSize().height-25),closeFun)
	registerOutsideCloseFunc(smallBg,closeFun)
	SwallowTouches(smallBg)
	local str = {{game.getStrByKey("combat_power"),80},{game.getStrByKey("name"),200},{game.getStrByKey("school"),320},{game.getStrByKey("level"),440},{game.getStrByKey("team_operator"),600}}
	for i = 1, #str do
		createLabel(smallBg,str[i][1],cc.p(str[i][2],450),nil,22,true,nil,nil,MColor.yellow_gray)
	end
	if params.isApply then
		local scrollView = cc.ScrollView:create()
		if nil ~= scrollView then
			scrollView:setViewSize(cc.size(770,380))
	        scrollView:setPosition(cc.p(20,40))
	        scrollView:ignoreAnchorPointForPosition(true)
	        local node = cc.Node:create()
	        local sizeY = 60*params.applyNum
	        node:setContentSize(cc.size(770,sizeY))
	        scrollView:setContainer(node)
	        scrollView:updateInset()
	        scrollView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL )
	        scrollView:setClippingToBounds(true)
	        scrollView:setBounceable(true)
	        smallBg:addChild(scrollView)
	        local posy = 60*params.applyNum-28


	        for j = 1,params.applyNum do
	        	local str1 = {game.getStrByKey("zhanshi"),game.getStrByKey("fashi"),game.getStrByKey("daoshi")}
	        	createScale9Sprite(node,"res/common/scalable/1.png",cc.p(400,posy),cc.size(760,55))        	
	        	createLabel(node,params.applyInfo[j].battle,cc.p(65,posy),nil,22,true,nil,nil,MColor.lable_black)
	        	createLabel(node,params.applyInfo[j].name,cc.p(185,posy),nil,22,true,nil,nil,MColor.lable_black)
	        	createLabel(node,str1[params.applyInfo[j].school],cc.p(299,posy),nil,22,true,nil,nil,MColor.lable_black)
	        	createLabel(node,params.applyInfo[j].level,cc.p(420,posy),nil,22,true,nil,nil,MColor.lable_black)
	        	
	        	local agree = createTouchItem(node,"res/component/button/48.png",cc.p(550,posy),function() self:isAgree(1,params,j) end)
	        	createLabel(agree,game.getStrByKey("pass"),getCenterPos(agree),nil,22,true,nil,nil,MColor.lable_yellow)
	        	local refuse = createTouchItem(node,"res/component/button/48.png",cc.p(650,posy),function() self:isAgree(2,params,j) end)
	        	createLabel(refuse,game.getStrByKey("refuse"),getCenterPos(refuse),nil,22,true,nil,nil,MColor.lable_yellow)
	        	posy = posy - 60        	
	        end
	        scrollView:setContentOffset(cc.p(0,380-sizeY))
		end
	else
		createLabel(smallBg,game.getStrByKey("team_tip4"),cc.p(410,260),nil,22,true,nil,nil,MColor.white)
	end

end

function nearPlayer:isAgree(how,params,j)
	if how == 1 then
		-- g_msgHandlerInst:sendNetDataByFmtExEx(TEAM_CS_ANSWER_APPLY,"iiib",userInfo.currRoleStaticId, params.applyInfo[j].roleId, params.teamId, true)
		g_msgHandlerInst:sendNetDataByTableExEx(TEAM_CS_ANSWER_APPLY, "TeamAnswerApplyProtocol", {["tRoleId"] = params.applyInfo[j].roleId, ["teamId"] = params.teamId, ["bAnswer"] = true})
	elseif how == 2 then
		-- g_msgHandlerInst:sendNetDataByFmtExEx(TEAM_CS_ANSWER_APPLY,"iiib",userInfo.currRoleStaticId, params.applyInfo[j].roleId, params.teamId, false)
		g_msgHandlerInst:sendNetDataByTableExEx(TEAM_CS_ANSWER_APPLY, "TeamAnswerApplyProtocol", {["tRoleId"] = params.applyInfo[j].roleId, ["teamId"] = params.teamId, ["bAnswer"] = false})
	end
	local callFun = function()
		self:applyList(self.theTeamId)
	end
	performWithDelay( self , callFun , 0.0 )
end

function nearPlayer:onAroundPlayer(luabuffer)
	local t = g_msgHandlerInst:convertBufferToTable("TeamGetArroundPlayerRetProtocol", luabuffer)
	-- self.noTeamCnt = t.noTeamCnt
	-- for i=0,self.noTeamCnt-1 do
	-- 	self.itemData[i] = { t.noTeaminfos[i+1].roleId, t.noTeaminfos[i+1].name, t.noTeaminfos[i+1].level, t.noTeaminfos[i+1].factionName, t.noTeaminfos[i+1].school , 0 }
	-- end
	-- self.teamCnt = t.withTeamCnt
	-- for j=0,self.teamCnt-1 do
	-- 	self.itemData[self.noTeamCnt+j] = { t.withTeaminfos[j+1].roleId, t.withTeaminfos[j+1].name, t.withTeaminfos[j+1].level, t.withTeaminfos[j+1].factionName, t.withTeaminfos[j+1].school ,t.withTeaminfos[j+1].curNum,t.withTeaminfos[j+1].maxNum}
	-- 	-- local maxMem = t.withTeaminfos[j+1].maxNum
	-- 	local teamId = t.withTeaminfos[j+1].teamId
	-- end
	-- self.itemCount = self.noTeamCnt+self.teamCnt
	local isSameFaction = 2	
	if t.aroundType == 1 or t.aroundType == 3 then
		self.itemData = {}
		self.itemCount = t.withTeamCnt
		for j = 1,self.itemCount do
			isSameFaction = 2
			if t.teamInfos[j].leaderFaction ~= "" and t.teamInfos[j].leaderFaction == MRoleStruct:getAttr(PLAYER_FACTIONNAME) then
				isSameFaction = 1
			end
			self.itemData[j] = {t.teamInfos[j].teamID,t.teamInfos[j].leaderName,t.teamInfos[j].leaderFaction,t.teamInfos[j].teamTarget,t.teamInfos[j].teamMaxNum,t.teamInfos[j].teamCurNum,isSameFaction}
		end
		table.sort(self.itemData,function(a, b) return a[7] < b[7] end)
	end
	-- self.activityID = 0
	if table.nums(self.itemData) <= 0 then		
		if self.page == 2 then
			self.tipLab = createLabel(self.bg,game.getStrByKey("team_tip9"),cc.p(450,180),nil,22,true,nil,nil,MColor.white)
		elseif self.page == 4 then
			self.tipLab = createLabel(self.bg,game.getStrByKey("team_tip11"),cc.p(450,180),nil,22,true,nil,nil,MColor.white)
		end
	else
		if self.tipLab then
			removeFromParent(self.tipLab)
			self.tipLab = nil
		end
	end
	self:getTableView():reloadData()
end

function nearPlayer:cellSizeForTable(table,idx) 
    return 70,870
end

function nearPlayer:inviteTo(tName,tID)
	if tName and tID then
		g_msgHandlerInst:sendNetDataByTableExEx(TEAM_CS_INVITE_TEAM, "InviteTeamProtocol", {["tName"] = tName,["isApply"] = true,["iTeamID"] = tID})
	end
end

function nearPlayer:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
	local index = idx + 1 
    if cell == nil  then
        cell = cc.TableViewCell:new()
    else
        cell:removeAllChildren()
    end
    	
	cell.bg = createSprite(cell,"res/faction/cell_list.png",cc.p(460.5,0),cc.p(0.5,0.0))

	local curData = self.itemData[index]
	if curData then
		local zhiye={game.getStrByKey("zhanshi"),game.getStrByKey("fashi"),game.getStrByKey("daoshi")}
		local target = {
							game.getStrByKey("team_noT"),game.getStrByKey("team_mainL"),game.getStrByKey("team_tcar"),game.getStrByKey("team_tcut"),game.getStrByKey("team_defense"),
							game.getStrByKey("team_defense1"),game.getStrByKey("team_defense2"),game.getStrByKey("team_pk"),game.getStrByKey("team_boss"),game.getStrByKey("team_pG"),game.getStrByKey("team_sha"),
						}

		local c = MColor.green
		if curData[6] >= 10 and curData == curData[5] then
			c = MColor.red
		end				
		local strs = { 
						{ str = curData[2] , str1 = game.getStrByKey("team_team") , color = MColor.lable_yellow , color1 = MColor.yellow_gray } , 
						{ str = target[curData[4]] , color = MColor.yellow_gray },
						{ str = curData[6].."/"..curData[5] , color = c },
						--{ str = zhiye[ curData[5] or 1 ] , color = MColor.white } , 
						-- { str = curData[3] .. game.getStrByKey("ji") , color = MColor.white } , 
						-- { str = curData[6] ~= 0 and ( "["..game.getStrByKey("have_team").."] " .. self.itemData[idx][6].."/"..self.itemData[idx][7] ) or game.getStrByKey("no_team")   , MColor.white , color = curData[5] ~= 0 and MColor.green or MColor.white } , 
						-- { str = self.itemData[idx][4] , color = MColor.white } , 
					} 
		for i = 1 , #strs do --130 + 220 * ( i - 1 ) + (3-i)*10  210*i-155
			-- createLabel( cell , strs[i].str , cc.p( 120 + 190 * ( i - 1 ) , 35 ) , cc.p( 0.5 , 0.5 ) , 20 , nil , nil, nil, strs[i].color )		
			-- if strs[i].str1 then

			-- end
			-- createSprite(cell,"res/teamup/faction.png",cc.p())
			local strr = require("src/RichText").new(cell, cc.p( 130 + 220 * ( i - 1 ) , 35 ), cc.size(190, 25), cc.p(0.5, 0.5), 22, 20, MColor.white)
			strr:setAutoWidth()
			strr:addText(strs[i].str,strs[i].color,true)
			if strs[i].str1 then
				strr:addText(strs[i].str1,strs[i].color1,true)
			end
			strr:format()
			if i == 1 then
				if curData[7] and curData[7] == 1 then
					createSprite(cell,"res/teamup/faction.png",cc.p(245,35))
				end
			end
		end
	    local applyBtn = createMenuItem(cell,"res/component/button/50.png", cc.p( 790 , 32 ),function() self:inviteTo(curData[2],curData[1]) end)
	    createLabel(applyBtn,game.getStrByKey("apply_join"),cc.p(69,29),nil,24,true)
    --if index == self.activityID then self:changeBgState( cell , true )  end
	end
    return cell
end

function nearPlayer:numberOfCellsInTableView(table)
   	return self.itemCount
end

-- function nearPlayer:changeBgState( cell , _b )
--     if _b then
--         self.curItem = cell 
--         cell.bg:setTexture("res/faction/cell_list_sel.png") 
--     else
--         self.curItem.bg:setTexture("res/faction/cell_list.png") 
--     end
-- end


function nearPlayer:tableCellTouched(table,cell)
    -- AudioEnginer.playTouchPointEffect()

    -- if (not self.activityID) or (self.activityID and self.activityID == 0) then 
    -- 	self.activityID = cell:getIdx() + 1 
    -- 	self.curItem = cell
    -- 	self:changeBgState( cell , true )
    -- else
    -- 	self:changeBgState( cell , false )
	   --  self.activityID = cell:getIdx() + 1
    -- 	self:changeBgState( cell , true )
    -- end
    


	-- local idx = cell:getIdx()
	-- if self.itemData[idx] and self.itemData[idx][6] and self.itemData[idx][6] ~= 0 then
	-- 	self.inviteOrApply:setString(game.getStrByKey("apply_join"))
	-- else
	-- 	self.inviteOrApply:setString(game.getStrByKey("invite_join"))
	-- end
end

function nearPlayer:networkHander(buff, msgid)
	local switch = {
		[CHAT_SC_CALL_RET] = function()
			--喊话返回
			local ret = buff:popBool()
			if ret then
				TIPS({ str =  game.getStrByKey("team_hanren1") })
			end
		end,
		[TEAM_SC_GET_TEAM_APPLY_RET] = function()
			local t = g_msgHandlerInst:convertBufferToTable("TeamGetTeamApplyRetProtocol", buff)
			local applyList = {}
			applyList.isApply = t.hasApply
			if applyList.isApply then				
				applyList.teamId = t.teamId
				local applyNum = t.applyCnt
				applyList.applyNum = applyNum
				applyList.applyInfo = {}		
				for i = 1 ,applyNum do
					local temp = {}
					temp.roleId = t.infos[i].roleSid
					temp.battle = t.infos[i].battle
					temp.name = t.infos[i].name
					temp.school = t.infos[i].school
					temp.level = t.infos[i].level
					applyList.applyInfo[i] = temp
				end
			else
				--TIPS({type = 1,str = game.getStrByKey("team_tip")})
				G_TEAM_APPLYRED[1] = false
				if G_TEAM_APPLYRED and G_TEAM_APPLYRED[2] then					
					G_TEAM_APPLYRED[2]:setVisible(false)
				end
				G_MAINSCENE:refreshTeamRedDot(false)
			end
			self:showApplyList(applyList)
		end,
	}

 	if switch[msgid] then 
 		switch[msgid]()
 	end
end

return nearPlayer