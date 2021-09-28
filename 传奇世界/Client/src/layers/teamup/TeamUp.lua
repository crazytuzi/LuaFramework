local TeamUp = class("TeamUp", function() return cc.Layer:create() end)

local comPath = "res/teamup/"
function TeamUp:ctor(parent)
	self.parent = parent
	-- self.selectID = 1
	self.memCnt = 0
	self.team_data = {}
	self.memSpr = {}
	self.isIamcaptain = false
	self.lab1 = nil
	self.callGroup = {
						game.getStrByKey("team_noT"),game.getStrByKey("team_mainL"),game.getStrByKey("team_tcar"),game.getStrByKey("team_tcut"),game.getStrByKey("team_defense"),
						game.getStrByKey("team_defense1"),game.getStrByKey("team_defense2"),game.getStrByKey("team_pk"),game.getStrByKey("team_boss"),game.getStrByKey("team_pG"),game.getStrByKey("team_sha"),
					}

	self.lastTouch = nil
	--createSprite(self, "res/common/bg/bg.png", cc.p(480, 285), cc.p(0.5 , 0.5))
	--createSprite(self,"res/common/bg/bg-6.png",cc.p(480,285))
	-- local bg = createSprite(self,"res/common/bg/bg-7.png",cc.p(480,328))
	local bg = cc.Sprite:create("res/common/scalable/panel_outer_base_1.png",cc.rect(0,0,896,400))
	bg:setAnchorPoint(cc.p(0.5,0))
	bg:setPosition(cc.p(480,100))
	bg:getTexture():setTexParameters(gl.LINEAR, gl.LINEAR, gl.REPEAT, gl.REPEAT)
	self:addChild(bg)
	createScale9Sprite(bg,"res/common/scalable/panel_outer_frame_scale9_1.png",cc.p(448,0),cc.size(896,400),cc.p(0.5,0))
	self.bg = bg

	local scrollView = cc.ScrollView:create()
    if nil == scrollView then
    	return
    end
    self.my_team_view = cc.Node:create()
    self.my_team_view_1 = cc.Node:create()
    self.my_team_view_1:setPosition(cc.p(440,200))
	bg:addChild(self.my_team_view_1,5)
	local width,height = 890,395

	local setFlagShow = function( value )  
    	if self.leftFlag and self.rightFlag then
            self.leftFlag:setVisible( value~=3 )
            self.rightFlag:setVisible( value~=1 )
        end
    end

	local function scrollView1DidScroll() 
        if scrollView:getContentOffset().x == scrollView:maxContainerOffset().x then 
            setFlagShow(3) 
        elseif scrollView:getContentOffset().x == scrollView:minContainerOffset().x then 
            setFlagShow(1)
        else
            setFlagShow(2)
        end 
    end
    scrollView:setViewSize(cc.size(width,height))
    scrollView:setPosition(cc.p(3,3))
    -- scrollView:setScale(1.0)
    scrollView:ignoreAnchorPointForPosition(true)
	
    self.my_team_view:setContentSize(cc.size(890+(10-3)*295,395))
    scrollView:setContainer(self.my_team_view)
    scrollView:updateInset()
    
    scrollView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL )
    scrollView:setClippingToBounds(true)
    scrollView:setBounceable(true)
    scrollView:setDelegate()
    scrollView:registerScriptHandler(scrollView1DidScroll,cc.SCROLLVIEW_SCRIPT_SCROLL)
    bg:addChild(scrollView)
    self.srollView = scrollView
	
	self.srollView:setContentOffset(cc.p(0,0))

	self:changeStatus()
	
	if G_TEAM_ATUOTURN and G_TEAM_ATUOTURN[1] then 
		createTouchItem(bg,"res/component/checkbox/1.png",cc.p(400,420),function() self:changeSelect(4) end)
		self.allow_spr2 = createSprite(bg,"res/component/checkbox/1-1.png",cc.p(400,420))
		self.allow_spr2:setVisible(getLocalRecord("autoTeam"))
		createLabel(bg, game.getStrByKey("team_autoIn"),cc.p(430,420), cc.p(0,0.5), 18, true, 1, nil,MColor.lable_black)
	else
		setLocalRecord("autoTeam",false)
	end

	createTouchItem(bg,"res/component/checkbox/1.png",cc.p(545,420),function() self:changeSelect(1) end)
	self.allow_spr = createSprite(bg,"res/component/checkbox/1-1.png",cc.p(545,420))
	self.allow_spr:setVisible(getGameSetById(GAME_SET_TEAM_IN) == 1)
	createLabel(bg, game.getStrByKey("team_autoInvite"),cc.p(575,420), cc.p(0,0.5), 18, true, 1, nil,MColor.lable_black)

	createTouchItem(bg,"res/component/checkbox/1.png",cc.p(730,420),function() self:changeSelect(2) end)
	self.allow_spr1 = createSprite(bg,"res/component/checkbox/1-1.png",cc.p(730,420))
	self.allow_spr1:setVisible(getGameSetById(GAME_SET_TEAM) == 1)
	createLabel(bg, game.getStrByKey("team_allowTeam"),cc.p(760,420), cc.p(0,0.5), 18, true, 1, nil,MColor.lable_black)

	--self.allow_spr:setVisible(getLocalRecordByKey(3,"allowTeam",true))
	-- self.allow_spr:setVisible(getGameSetById(GAME_SET_TEAM) == 1)



	self:initTouch()

	g_msgHandlerInst:sendNetDataByTableExEx(TEAM_CS_GET_TEAMINFO, "TeamGetTeamInfoProtocol", {})
	self:registerScriptHandler(function(event)
		if event == "enter" then
			G_TUTO_NODE:setShowNode(self, SHOW_TEAM)
			g_EventHandler["teamup"] = self
		elseif event == "exit" then
			if G_TEAM_APPLYRED[2] then
				removeFromParent(G_TEAM_APPLYRED[2])
				G_TEAM_APPLYRED[2] = nil
			end
			g_EventHandler["teamup"] = nil
		end
	end)

	local msgids = {CHAT_SC_CALL_RET,TEAM_SC_GET_TEAM_APPLY_RET}
	require("src/MsgHandler").new(self, msgids)	
end
    
function TeamUp:showArrow()
	local leftFlag = Effects:create(false)
	leftFlag:playActionData2("ActivePage",200,-1,0)
	-- setNodeAttr(leftFlag,cc.p(200 , -200) , cc.p( 0.5 , 0.5 ))
	leftFlag:setPosition(cc.p(-430,25))
	addEffectWithMode( leftFlag , 1 )
	leftFlag:setRotation(90)
	self.leftFlag = leftFlag

	local rightFlag = Effects:create(false)
    rightFlag:playActionData2("ActivePage", 200 , -1 , 0 )
    -- setNodeAttr( rightFlag , cc.p( 300 , -200) , cc.p( 0.5 , 0.5 ) )
    rightFlag:setPosition(cc.p(445,25))
    addEffectWithMode( rightFlag , 1 )
    rightFlag:setRotation(-90)
    self.rightFlag = rightFlag

    self.my_team_view_1:addChild(leftFlag,10)
    self.my_team_view_1:addChild(rightFlag,10)
    local delayFun = function()
    	leftFlag:setVisible(false)
    end
    performWithDelay( leftFlag , delayFun , 0.0 )
end

function TeamUp:initTouch() 
	local  listenner = cc.EventListenerTouchOneByOne:create()
    listenner:setSwallowTouches(false)
    listenner:registerScriptHandler(function(touch, event)
    		self.lastTouch = self.my_team_view:convertToWorldSpace( touch:getLocation() )
    		return true
        end,cc.Handler.EVENT_TOUCH_BEGAN )
    listenner:registerScriptHandler(function(touch, event)
    	for i=1,self.memCnt do
    		if self.memSpr[i] then
    			local theTouch = self.my_team_view:convertToWorldSpace( touch:getLocation() )
	    		local pt = self.my_team_view:convertTouchToNodeSpace(touch)
	    		local x,y = self.memSpr[i]:getPosition()
				if (math.abs(pt.x-x) <=100 and (pt.y-y) > -100 and (pt.y-y) < 200) and math.abs(self.lastTouch.x - theTouch.x) < 30 and math.abs(self.lastTouch.y - theTouch.y) < 30 then
					local pos = touch:getLocation().x
					if touch:getLocation().x < 40 then
						pos =  40
					elseif touch:getLocation().x > 710 then
						pos = 710
					end
					self:selectMember(i,pos)
				end
			end
		end
	end, cc.Handler.EVENT_TOUCH_ENDED)

    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner,self.bg)
end


function TeamUp:applyList(teamId)
	self.theTeamId = teamId
	-- g_msgHandlerInst:sendNetDataByFmtExEx(TEAM_CS_GET_TEAM_APPLY,"ii",captainId,teamId)
	g_msgHandlerInst:sendNetDataByTableExEx(TEAM_CS_GET_TEAM_APPLY, "TeamGetTeamApplyProtocol", {["teamId"] = teamId})
end

function TeamUp:isAgree(how,params,j)
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


function TeamUp:showApplyList(params)
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
			scrollView:setViewSize(cc.size(770,390))
	        scrollView:setPosition(cc.p(38,35))
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
	        	createScale9Sprite(node,"res/common/scalable/1.png",cc.p(388,posy),cc.size(760,55))        	
	        	createLabel(node,params.applyInfo[j].battle,cc.p(12,posy),cc.p(0,0.5),22,true,nil,nil,MColor.lable_black)
	        	createLabel(node,params.applyInfo[j].name,cc.p(166,posy),nil,22,true,nil,nil,MColor.lable_black)
	        	createLabel(node,str1[params.applyInfo[j].school],cc.p(284,posy),nil,22,true,nil,nil,MColor.lable_black)
	        	createLabel(node,params.applyInfo[j].level,cc.p(402,posy),nil,22,true,nil,nil,MColor.lable_black)
	        	
	        	local agree = createTouchItem(node,"res/component/button/48.png",cc.p(550,posy),function() self:isAgree(1,params,j) end)
	        	createLabel(agree,game.getStrByKey("pass"),getCenterPos(agree),nil,22,true,nil,nil,MColor.lable_yellow)
	        	local refuse = createTouchItem(node,"res/component/button/48.png",cc.p(650,posy),function() self:isAgree(2,params,j) end)
	        	createLabel(refuse,game.getStrByKey("refuse"),getCenterPos(refuse),nil,22,true,nil,nil,MColor.lable_yellow)
	        	posy = posy - 60        	
	        end
	        scrollView:setContentOffset(cc.p(0,390-sizeY))
		end
	else
		createLabel(smallBg,game.getStrByKey("team_tip4"),cc.p(410,260),nil,22,true,nil,nil,MColor.white)
	end
end

function TeamUp:changeStatus()
	self.isIamcaptain = false
	-- if self.team_tip then
	-- 	self.team_tip:setString(game.getStrByKey("team_allowTeam"))
	-- end	
	local countDown ,actTag = 10,1
	local params = {G_TEAM_INFO.has_team,G_TEAM_INFO.teamID,G_TEAM_INFO.memCnt,G_TEAM_INFO.team_data,G_TEAM_INFO.hurtAdd,G_TEAM_INFO.expAdd,G_TEAM_INFO.teamTarget}
	removeFromParent(self.leftFlag)
	self.target = params[7]
	self.leftFlag = nil
	removeFromParent(self.rightFlag)
	self.rightFlag = nil
	if self.srollView and params[1] then
		self.sroloff = self.srollView:getContentOffset()
	end
	self.my_team_view:removeAllChildren()
	self.my_team_view_1:removeAllChildren()	
	if not params[1] then
		if self.srollView then
			self.srollView:setTouchEnabled(false)
		end
		self.memCnt = 0
		self.team_data = {}
		local countDown , actTag = 10,1
		createScale9Sprite(self.my_team_view_1,"res/teamup/1.png",cc.p(7.5, -200 ),cc.size(896,400),cc.p(0.5,0))
		createLabel(self.my_team_view_1,game.getStrByKey("team_tip8"),cc.p(0,0),nil,22,true,nil,nil,MColor.white)
		-- createScale9Sprite(self.my_team_view,"res/common/bg/bg15.png",cc.p(0,-200),cc.size(),cc.p(0.5,0.5),nil,nil,-1)
		local lab = createLabel( self.my_team_view_1 , game.getStrByKey( "team_my2" ) , cc.p( 0 , -170 ) , cc.p(0.5,0.5) , 22 , nil , 1 , nil , MColor.yellow_gray )
		-- createScale9Sprite(self.my_team_view_1,"res/common/56.png",cc.p(0,-170),cc.size(lab:getContentSize().width+20,lab:getContentSize().height),cc.p(0.5,0.5))

		local createFunc = function()
			--g_msgHandlerInst:sendNetDataByFmtExEx(TEAM_CS_CREATE_TEAM,"i",userInfo.currRoleId)
			g_msgHandlerInst:sendNetDataByTableExEx(TEAM_CS_CREATE_TEAM, "CreateTeamProtocol", {["teamTarget"] = 1})
		end
		local createFunc1 = function(targetID , node)
			g_msgHandlerInst:sendNetDataByTableExEx(TEAM_CS_FAST_ENTER, "TeamFastEnter", {["enterType"] = 1})
			if not self.isIamcaptain and getGameSetById(GAME_SET_TEAM) == 0 then
				self:changeSelect(2)
			end
			countDown = 10
			node:setEnabled(false)
			local DelayTime = cc.DelayTime:create(1)
			local CallFunc = cc.CallFunc:create(function()
				countDown = countDown - 1
				if countDown <= 0 then
					node:stopActionByTag(actTag)
					node:setEnabled(true)
					node:getChildByTag(2):setString(game.getStrByKey("team_ingroup"))
					node:getChildByTag(2):setColor(MColor.yellow_gray)
				else
					-- node:getChildByTag(2):setString(game.getStrByKey("team_ingroup").."("..tostring(countDown)..")")
					node:getChildByTag(2):setColor(MColor.gray)
				end
			end)
			local Sequence = cc.Sequence:create(DelayTime, CallFunc)
			local action = cc.RepeatForever:create(Sequence)
			action:setTag(actTag)
			node:runAction(action)
		end

		local menuitem = createMenuItem(self.my_team_view_1,"res/component/button/50.png",cc.p(208,-235),createFunc)
    	createLabel(menuitem, game.getStrByKey("create_team"),getCenterPos(menuitem), cc.p(0.5,0.5),24 , true , nil , nil , MColor.yellow_gray )
    	local menuitem1 = createMenuItem(self.my_team_view_1,"res/component/button/50.png",cc.p(368,-235),createFunc1,nil,true)
    	createLabel(menuitem1,game.getStrByKey("team_ingroup"),getCenterPos(menuitem1),cc.p(0.5,0.5),24 , true , nil , nil , MColor.yellow_gray,2)
    	-- menuitem1:setEnabled(false)
   --  	if self.team_tip then
			-- self.team_tip:setPosition(cc.p(80,-50))
			-- self.allow_spr:setPosition(cc.p(50,-50))
			-- self.touchBtn:setPosition(cc.p(50,-50))
			-- if self.team_tip1 then
			-- 	removeFromParent(self.team_tip1)
			-- 	self.team_tip1 = nil
			-- end
			-- if self.team_tip2 then
			-- 	removeFromParent(self.team_tip2)
			-- 	self.team_tip2 = nil
			-- end
		-- end
		if self.team_tip1 and self.team_tip2 then
			self.team_tip2:setString("0/0")
		else
			self.team_tip1 = createLabel(self.bg,game.getStrByKey("team_memNum"),cc.p(0,420),cc.p(0,0.5),20,true,nil,nil,MColor.lable_yellow)
			self.team_tip2 = createLabel(self.bg,"0/0",cc.p(138,420),cc.p(0,0.5),20,true,nil,nil,MColor.white)
		end
    	G_TUTO_NODE:setTouchNode(menuitem, TOUCH_TEAM_CREATE)
	else
		if self.srollView then
			if self.sroloff then
				self.srollView:setContentOffset(self.sroloff)
			else
				self.srollView:setContentOffset(cc.p(0,0))				
			end
			self.srollView:setTouchEnabled(true)
		end
		self:showArrow()
		for i=1,10 do
			createSprite(self.my_team_view,"res/teamup/membg.png",cc.p(-145+i*295 ,197 ),cc.p(0.5,0.5))
		end
		-- local bg2 = createSprite(self.my_team_view, "res/common/bg/bg-2.png", cc.p(15 - 15 , - 252), cc.p(0.5 , 0.5))
		-- bg2:setScaleY( 0.8 )
		self.memCnt = params[3]
		self.team_data = params[4]
		if self.team_tip1 and self.team_tip2 then
			self.team_tip2:setString(tostring(self.memCnt).."/10")
		else
			self.team_tip1 = createLabel(self.bg,game.getStrByKey("team_memNum"),cc.p(0,420),cc.p(0,0.5),20,true,nil,nil,MColor.lable_yellow)
			self.team_tip2 = createLabel(self.bg,tostring(self.memCnt).."/10",cc.p(138,420),cc.p(0,0.5),20,true,nil,nil,MColor.white)
		end
		for j=1,10 do--params[3] do
			if j <= params[3] then
				self.memSpr[j] = createRoleNode(params[4][j].school,params[4][j].closeId,params[4][j].weaponId,params[4][j].windId,nil,params[4][j].sex)
				self.memSpr[j]:setScale(0.85)
				self.my_team_view:addChild(self.memSpr[j])
				self.memSpr[j]:setPosition(cc.p(-153+j*295+8,169))
				if params[4][j].isFactionSame then
					createSprite(self.my_team_view,"res/teamup/faction.png",cc.p(-90+j*295+40,345))
				end

				if j == 1 then
					local btnFunc = function(tag,sender)
						if sender==self.exit_team_btn then
							--self:changeStatus({false})
							G_TEAM_APPLYRED[1] = false
							if G_TEAM_APPLYRED[2] then			
								removeFromParent(G_TEAM_APPLYRED[2])
								G_TEAM_APPLYRED[2] = nil
							end
							G_MAINSCENE:refreshTeamRedDot(false)
							-- g_msgHandlerInst:sendNetDataByFmtExEx(TEAM_CS_LEAVE_TEAM,"i",userInfo.currRoleId)
							g_msgHandlerInst:sendNetDataByTableExEx(TEAM_CS_LEAVE_TEAM, "TeamLeaveTeamProtocol", {})
							-- self:changeSelect(2)
						elseif sender==self.hanren_btn then
				    		local commConst = require("src/config/CommDef")
				    		local str = "team_hanren"..tostring(self.target+2)
							local text = game.getStrByKey(str)
							local t = {}
							t.channel = commConst.Channel_ID_Team
							t.message = text
							t.area = 1
							t.callType = 2
							t.paramNum = 2
							t.callParams = {tostring(G_ROLE_MAIN:getTheName()),tostring(params[2])}
							g_msgHandlerInst:sendNetDataByTableExEx(CHAT_CS_CALL_MSG, "CallMsgProtocol", t)
						end
					end
					-- local recruitGroup = function(targetID , node)
					-- 	g_msgHandlerInst:sendNetDataByTableExEx(TEAM_CS_FAST_RECRUIT, "TeamFastRecruit", {})
					-- 	if self.isIamcaptain and G_TEAM_CAPTAIN and not G_TEAM_CAPTAIN.isAutoAdd then
					-- 		self:changeSelect(1)
					-- 	end
					-- 	countDown = 10
					-- 	node:setEnabled(false)
					-- 	local DelayTime = cc.DelayTime:create(1)
					-- 	local CallFunc = cc.CallFunc:create(function()
					-- 		countDown = countDown - 1
					-- 		if countDown <= 0 then
					-- 			node:stopActionByTag(actTag)
					-- 			node:setEnabled(true)
					-- 			node:getChildByTag(2):setString(game.getStrByKey("team_recruit"))
					-- 			node:getChildByTag(2):setColor(MColor.yellow_gray)
					-- 		else
					-- 			-- node:getChildByTag(2):setString(game.getStrByKey("team_recruit").."("..tostring(countDown)..")")
					-- 			node:getChildByTag(2):setColor(MColor.gray)
					-- 		end
					-- 	end)
					-- 	local Sequence = cc.Sequence:create(DelayTime, CallFunc)
					-- 	local action = cc.RepeatForever:create(Sequence)
					-- 	action:setTag(actTag)
					-- 	node:runAction(action)
					-- end

					-- self.recruit = createMenuItem(self.my_team_view_1,"res/component/button/50.png",cc.p(208,-235),recruitGroup,nil,true)
		   --  		createLabel(self.recruit, game.getStrByKey("team_recruit"),getCenterPos( self.recruit ), cc.p(0.5,0.5),24,true,nil,nil,MColor.yellow_gray,2)	    		
					self.exit_team_btn = createMenuItem(self.my_team_view_1,"res/component/button/50.png",cc.p(368,-235),btnFunc)
		    		createLabel(self.exit_team_btn, game.getStrByKey("leave_team"),getCenterPos( self.exit_team_btn ), cc.p(0.5,0.5),24,true):setColor(MColor.yellow_gray)
		    		-- self.add_mem_btn = createMenuItem(self.my_team_view,"res/component/button/50.png",cc.p(180,-250),btnFunc)
		    		-- createLabel(self.add_mem_btn, game.getStrByKey("add_member"), getCenterPos( self.add_mem_btn ), cc.p(0.5,0.5),24,true):setColor(MColor.yellow_gray)
		    		self.add_mem_btn = createMenuItem(self.my_team_view_1,"res/component/button/50.png",cc.p(48,-235),function() self:applyList(params[2]) end)
					local size =  self.add_mem_btn:getContentSize()
					createLabel( self.add_mem_btn,game.getStrByKey("team_applyList"),cc.p(size.width/2,size.height/2),nil,24,true,nil,nil,MColor.yellow_gray)
					G_TEAM_APPLYRED[2] = createSprite(self.add_mem_btn,"res/component/flag/red.png",cc.p(size.width,size.height-10))
					if not G_TEAM_APPLYRED[1] then
						G_TEAM_APPLYRED[2]:setVisible(false)
					end
					self.hanren_btn = createMenuItem(self.my_team_view_1,"res/component/button/50.png",cc.p(208,-235),btnFunc)
		    		createLabel(self.hanren_btn, game.getStrByKey("team_hanrenBtn"), getCenterPos( self.exit_team_btn ), cc.p(0.5,0.5),24,true):setColor(MColor.yellow_gray)
		    		createLabel(self.my_team_view_1,game.getStrByKey("team_expAdd"),cc.p(-220,220),cc.p(0,0.5),20, true,nil,nil,MColor.lable_yellow)
					createLabel(self.my_team_view_1,""..(params[6]).."%",cc.p(-120,220),cc.p(0,0.5),20,true,nil,nil,MColor.name_yellow)				
		    	end    		


				if j==1 then--队长
					createSprite(self.my_team_view,"res/teamup/2.png",cc.p(25,370),cc.p(0.5,0.5))
					---------建立队长申请列表----------
					if userInfo.currRoleStaticId == params[4][j].roleId then									
						-- local applyListBtn = createTouchItem(self.my_team_view,"res/component/button/50.png",cc.p(-340,-162),function() self:applyList(userInfo.currRoleStaticId,params[2]) end)
						-- local size = applyListBtn:getContentSize()
						-- createLabel(applyListBtn,game.getStrByKey("team_applyList"),cc.p(size.width/2,size.height/2),nil,24,true,nil,nil,MColor.yellow_gray)
						-- createSprite(applyListBtn,"res/component/flag/red.png",cc.p(size.width,size.height))
						-- self.add_mem_btn:setVisible(true)
						self.add_mem_btn:setEnabled( true  )
						-- self.add_mem_btn:setVisible(true)
						-- self.recruit:setEnabled( true  )
						-- if self.team_tip then
						-- 	self.team_tip:setString(game.getStrByKey("team_autoInvite"))
						-- end
						self.isIamcaptain = true
						-- if G_TEAM_CAPTAIN and G_TEAM_CAPTAIN.teamID == G_TEAM_INFO.teamID and self.allow_spr then							
						-- 	self.allow_spr:setVisible(G_TEAM_CAPTAIN.isAutoAdd)
						-- end
					end
					-------------------
				else					
					if self.isIamcaptain then
						local callFun = function()
							-- g_msgHandlerInst:sendNetDataByFmtExEx(TEAM_CS_REMOVE_MEMBER,"ii", userInfo.currRoleId, params[4][j].roleId)
							g_msgHandlerInst:sendNetDataByTableExEx(TEAM_CS_REMOVE_MEMBER, "TeamRemoveMemberProtocol", {["tRoleId"] = params[4][j].roleId})
						end
						local btn = createTouchItem(self.my_team_view,"res/component/button/39.png",cc.p(-153+j*295+ 8,47),callFun)
						createLabel(btn,game.getStrByKey("kickout_team"),getCenterPos(btn),nil,24,true,nil,nil,MColor.yellow_gray)
					else						
						self.add_mem_btn:setEnabled( false  )	
						-- self.add_mem_btn:setVisible( false )				
						-- self.recruit:setEnabled( false  )
						if G_TEAM_APPLYRED and G_TEAM_APPLYRED[2] then
							G_TEAM_APPLYRED[2]:setVisible(false)
						end
						G_MAINSCENE:refreshTeamRedDot(false)
					end
					-- if userInfo.currRoleStaticId == params[4][j].roleId then
						-- self:changeSelect(2)
					-- end
				end
				-- if self.team_tip then
				-- 	self.team_tip:setPosition(cc.p(80,-25))
					-- self.allow_spr:setPosition(cc.p(50,-25))
					-- self.touchBtn:setPosition(cc.p(50,-25))
				-- end
				local lab = createLabel(self.my_team_view,params[4][j].name,cc.p(-153+j*295+9,360),nil,20)--cc.p(171,370)
				lab:setColor(MColor.yellow)
				lab = createLabel(self.my_team_view,""..params[4][j].roleLevel.."级",cc.p(-153+j*295-25,330),nil,18)--cc.p(135,340)
				lab:setColor(MColor.lable_yellow)
				local zhiye={game.getStrByKey("zhanshi"),game.getStrByKey("fashi"),game.getStrByKey("daoshi")}
				-- lab = createLabel(self.my_team_view,zhiye[params[4][j].school],cc.p(-153+j*220+ 89,344),nil,18)--cc.p(205,340)
				-- lab:setColor(MColor.lable_yellow)
				-- createSprite(self.my_team_view,"res/teamup/"..zhiye[params[4][j].school]..".png",cc.p(-153+j*220+ 46,344))
				lab = createLabel(self.my_team_view,zhiye[params[4][j].school],cc.p(-153+j*295+ 47,330),nil,18,true,nil,nil,MColor.lable_yellow)
			else
				if self.isIamcaptain then
					local callFun = function()
						-- self.selectID = 2
						-- self:selectTab(self.selectID)
						if self.parent:getParent() then
							self.parent:getParent():changePage(3)
						end
					end
					createSprite(self.my_team_view,"res/teamup/someone.png",cc.p(-148+j*295+ 8,174),nil,nil,0.82)
					local btn = createTouchItem(self.my_team_view,"res/component/button/39.png",cc.p(-153+j*295+ 8,47),callFun)
					createLabel(btn,game.getStrByKey("add_member"),getCenterPos(btn),nil,24,true,nil,nil,MColor.yellow_gray)
				end
			end
		end
		local createTB = function()
			if not self.isIamcaptain then
				TIPS({type = 1,str = "只有队长可以设置队伍目标。"})
				return
			end	
			local sprTemp = 0		
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
				self:changeSelect(3,cn)
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
					if j+m <= #self.callGroup then
						spr[j+m] = createSprite(nodeTemp,"res/common/table/cell32.png",cc.p(posx,posy),cc.p(0.5,1))
						if j+m == self.target then
							spr[j+m]:setTexture("res/common/table/cell32_sel.png")
							sprTemp = j+m
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
										if sprTemp ~= 0 then
											spr[sprTemp]:setTexture("res/common/table/cell32.png")
										end
										spr[j+m]:setTexture("res/common/table/cell32_sel.png")
										sprTemp = j+m
									end
								end
					    end,cc.Handler.EVENT_TOUCH_ENDED)
					    listenner:registerScriptHandler(function(touch,event)
							local pt = touch:getLocation()
							pt = spr[j+m]:getParent():convertToNodeSpace(pt)
								if lastTouch and math.abs(lastTouch.x - theTouch.x) < 30 and math.abs(lastTouch.y - theTouch.y) < 30 then			
									if cc.rectContainsPoint(spr[j+m]:getBoundingBox(),pt) then
										setFun(G_DRUG_TAB[num][j+m][1],num,j+m,dnum)
										if sprTemp ~= 0 then
											spr[sprTemp]:setTexture("res/common/table/cell32.png")
										end
										spr[j+m]:setTexture("res/common/table/cell32_sel.png")
										sprTemp = j+m
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
			createTouchItem(tarBg,"res/component/button/50.png",cc.p(201,50),function() choice(sprTemp) closeF() end,true)
			createLabel(tarBg,game.getStrByKey("sure"),cc.p(201,50),cc.p(0.5,0.5),22,true,nil,nil,MColor.lable_yellow)
		end
		
		local tItem = createTouchItem(self.my_team_view_1,"res/teamup/targetItem.png",cc.p(-300,-235),function() createTB() end)
		createLabel(tItem,game.getStrByKey("team_tt1"),cc.p(10,25),cc.p(0,0.5),20,true,nil,nil,MColor.lable_yellow)
		self.lab1 = createLabel(tItem,self.callGroup[self.target],cc.p(110,25),cc.p(0,0.5),20,true,nil,nil,MColor.yellow_gray)
	end
end

function TeamUp:changeSelect(chooseOne,cn)
	if self.allow_spr and self.allow_spr1 and chooseOne then
		-- if how and how == 1 then
		-- 	if self.isIamcaptain then
		-- 		local isVisible =  self.allow_spr:isVisible()
		-- 		self.allow_spr:setVisible(not isVisible)
		-- 		G_TEAM_CAPTAIN.isAutoAdd = not isVisible
		-- 		-- g_msgHandlerInst:sendNetDataByFmtExEx(TEAM_CS_CHANGE_AUTOINVITE,"ib",userInfo.currRoleId,not isVisible)
		-- 		g_msgHandlerInst:sendNetDataByTableExEx(TEAM_CS_CHANGE_AUTOINVITE, "TeamChangeAutoInviteProtocol", { ["autoInvite"] = not isVisible})
		-- 	else
		-- 		local isVisible =  self.allow_spr:isVisible() 
		-- 		self.allow_spr:setVisible(not isVisible)
		-- 		--setLocalRecordByKey(3,"allowTeam",not isVisible)
		-- 		setGameSetById(GAME_SET_TEAM, isVisible and 0 or 1)
		-- 		-- g_msgHandlerInst:sendNetDataByFmtExEx(TEAM_CS_CHANGE_AUTOINVITE,"ib",userInfo.currRoleId,not isVisible)
		-- 		g_msgHandlerInst:sendNetDataByTableExEx(TEAM_CS_CHANGE_AUTOINVITE, "TeamChangeAutoInviteProtocol", {["autoInvite"] = not isVisible})
		-- 	end
		-- elseif how and how == 2 then
		-- 	self.allow_spr:setVisible(getGameSetById(GAME_SET_TEAM) == 1)
		-- else
		-- 	self.allow_spr:setVisible(G_TEAM_CAPTAIN.isAutoAdd)
		-- end
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
		elseif chooseOne == 3 and cn then
			g_msgHandlerInst:sendNetDataByTableExEx(TEAM_CS_CHANGE_AUTOINVITE, "TeamChangeAutoInviteProtocol", { ["inviteValue"] = cn ,["inviteType"] = 3 })
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
				if not autoTeamSta and G_TEAM_ATUOTURN then
					G_TEAM_ATUOTURN[2] = false
				end
			end			
			if not autoTeamSta then
				MessageBoxYesNo(nil, game.getStrByKey("team_tip5"), function() fun(true) end  )
			else
				fun()
			end
			
		end
	end
end

function TeamUp:selectMember(index,touchPos)
	
	-- if self.selectID == 2 then return end
	--自己
	if self.team_data[index].roleId == userInfo.currRoleStaticId then
		return 
	end

	self.operate = createSprite(self.bg, "res/common/scalable/5.png", cc.p(130, 464), cc.p(0, 1),254)
	local pos = cc.p(120,430)
    if index > 1 then
    	pos = cc.p(touchPos,430)
    end
    self.operate:setPosition(pos)
	local  listenner = cc.EventListenerTouchOneByOne:create()
	local flag = false
	listenner:setSwallowTouches(true)
    listenner:registerScriptHandler(function(touch, event) 
								    	local pt = self.operate:getParent():convertTouchToNodeSpace(touch)
										if cc.rectContainsPoint(self.operate:getBoundingBox(), pt) == false then
												flag = true
										end
    									return true 
    								end, cc.Handler.EVENT_TOUCH_BEGAN)
    listenner:registerScriptHandler(function(touch, event)
    	local start_pos = touch:getStartLocation()
		local now_pos = touch:getLocation()
		local span_pos = cc.p(now_pos.x-start_pos.x,now_pos.y-start_pos.y)
		local pt = self.operate:getParent():convertTouchToNodeSpace(touch)
		if flag and (cc.rectContainsPoint(self.operate:getBoundingBox(), pt) == false) then
			if self.operate then removeFromParent(self.operate) self.operate = nil end
			AudioEnginer.playTouchPointEffect()
		end
	end, cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = self.operate:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, self.operate)

	local func = function(tag)
		local switch = {
	        [1] = function() 
				LookupInfo(self.team_data[index].name)
	        end,
	        [2] = function() 
				AddFriends(self.team_data[index].name)
	        end,
		    [3] = function() 
				AddBlackList(self.team_data[index].name)
			end,
	        [4] = function() 
				-- g_msgHandlerInst:sendNetDataByFmtExEx(TEAM_CS_CHANGE_LEADER,"ii", userInfo.currRoleId, self.team_data[index].roleId)
				g_msgHandlerInst:sendNetDataByTableExEx(TEAM_CS_CHANGE_LEADER, "TeamChangeLeaderProtocol", {["tRoleId"] = self.team_data[index].roleId})
	        end,
	        [5] = function() 
				-- g_msgHandlerInst:sendNetDataByFmtExEx(TEAM_CS_REMOVE_MEMBER,"ii", userInfo.currRoleId, self.team_data[index].roleId)
				g_msgHandlerInst:sendNetDataByTableExEx(TEAM_CS_REMOVE_MEMBER, "TeamRemoveMemberProtocol", {["tRoleId"] = self.team_data[index].roleId})
	        end,
	        }
		if switch[tag] then switch[tag]() end
		    removeFromParent(self.operate)
		    self.operate = nil		    
	end

	local menus = {
				{ text = game.getStrByKey("look_info"),tag = 1},
				{ text = game.getStrByKey("addas_friend"),tag = 2},
				{ text = game.getStrByKey("add_blackList"),tag = 3},
				{ text = game.getStrByKey("up_captain"),tag = 4},
				--{ game.getStrByKey("kickout_team"),5,func},
			}


	for i=1, #menus do
		local item = createMenuItem(self.operate, "res/component/button/49.png", cc.p(79, 187 - (i-1) * 50), function() func(menus[i].tag) end)
		createLabel(item, menus[i].text, getCenterPos(item), nil, 20, true):setColor(MColor.lable_yellow)
	end

end

function TeamUp:changeT(target)
	self.target = target
	G_TEAM_INFO.teamTarget = target
	if self.lab1 then
		self.lab1:setString(self.callGroup[target])
	end
end

function TeamUp:networkHander(buff, msgid)
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

return TeamUp