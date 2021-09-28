local teamNode = class("teamNode",function() return cc.Node:create() end)
 
function teamNode:ctor(params)	
	self:setSelectMemEnabled(true)
	local parent = params.parent
	self.bar = {}
    parent:addChild( self,107)
    local offY = 70+15
    local width  = 250
    local height  =  106
    self.countDown = 0
    self.batchNum = (params.teamMemberNum > 0) and params.teamMemberNum or 2
    self.noTeamText = {game.getStrByKey("team_lookup"),game.getStrByKey("team_create")}
    local sizeHeight = 51*self.batchNum
    local size = cc.size(246,sizeHeight)

    local scrollView1 = cc.ScrollView:create()
    self.scrollView1 = scrollView1
    -- local function scrollView1DidScroll() if __TASK and __TASK.startRecordOffPos  then __TASK.startRecordOffPos = scrollView1:getContentOffset() end end
    -- local function scrollView1DidZoom() end
    scrollView1:setViewSize(cc.size( width , height ))
    scrollView1:setPosition( cc.p( 0 ,  display.cy - 26 + offY ) )    
    scrollView1:ignoreAnchorPointForPosition(true)
    scrollView1:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL )
    scrollView1:setClippingToBounds(true)
    scrollView1:setBounceable(true)
    scrollView1:setDelegate()

    -- scrollView1:registerScriptHandler(scrollView1DidScroll,cc.SCROLLVIEW_SCRIPT_SCROLL)
    -- scrollView1:registerScriptHandler(scrollView1DidZoom,cc.SCROLLVIEW_SCRIPT_ZOOM)
   
    self:addChild(scrollView1)    
    if self.mainFlag then
        removeFromParent(self.mainFlag)
    end
    self.mainFlag = self:createMainIcon(size)
    scrollView1:setContainer( self.mainFlag )
    scrollView1:setContentSize(size)
    self.scrollView1:setContentOffset(cc.p(0,height-sizeHeight))
    scrollView1:addSlider("res/common/slider1.png",false)
    g_EventHandler["teamNode"] = self
    self:registerScriptHandler(function(event)
		if event == "enter" then		
		elseif event == "exit" then			
			self:removeEvent()
			g_EventHandler["teamNode"] = nil
			if self.timer then
				self.timer:stopAllActions()
        		self.timer = nil
			end
		end
	end)
    self:addEvent()

    print("self:forbidTouch", bForbidTeamTouch)
    self:forbidTouch(bForbidTeamTouch)
end

function teamNode:addEvent( ... )
	-- body

end

function teamNode:removeEvent( ... )
	-- body

end

function teamNode:forbidTouch( bForbid )
	-- body
	print("teamNode:forbidTouch", bForbid)
	self:setSelectMemEnabled(not bForbid)
end

function teamNode:setForbidLabel( bForbid )
	-- body
	self.m_bForbidLabel = bForbid
end

function teamNode:createMainIcon(size)
	-- body
	local  function clickFun(num)
   --      local curData = gatherData[key]
   --      if curData then

   --          local _tempData = {} 
   --          for key , v in pairs( curData ) do 
   --              _tempData[ key ] = v 
   --          end 
   --          _tempData.isClick = true 
   --          local isFinish = false
   --          if curData then
   --              if curData.finished and ( curData.finished == 6 ) then
   --                  isFinish = true
   --              else
   --                  if curData.targetData and curData.targetData.cur_num then
   --                      if curData.targetData.cur_num >= ( curData.targetData.count or 0 ) then
   --                          isFinish = true
   --                      end
   --                  end
   --              end
   --          end

   --          if key == "every" and  isFinish  then
   --              __GotoTarget( {ru = "a1"} )
			-- elseif key == "share" then
			-- 	require("src/layers/teamTreasureTask/teamTreasureTaskLayer"):onClickTaskPanel(curData)
			-- elseif key == "dart" then
   --              local dartData = DATA_Mission.DART_STATIC
   --              if dartData.hasReward then
   --                  __GotoTarget( { ru = "a19" } )
   --              else
   --                  game.setAutoStatus(AUTO_MATIC)
   --                  if G_MAINSCENE then G_MAINSCENE.dart_pos = nil end
   --              end
   --          else
   --              self:findPath( _tempData ) 
   --          end
   --      end
   		if self:isVisible() then
   			if not G_TEAM_INFO.has_team then
	   			if num == 2 then
	   				__GotoTarget({ ru = "a29",index = 1})
	   				g_msgHandlerInst:sendNetDataByTableExEx(TEAM_CS_CREATE_TEAM, "CreateTeamProtocol", {["teamTarget"] = 1})
	   			elseif num == 1 then
	   				__GotoTarget({ ru = "a29",index = 2})
	   			end
	   		else
	   			local tabTemp = G_TEAM_INFO.team_data[num]
	   			local is_leader = userInfo.currRoleStaticId ==  G_TEAM_INFO.team_data[1].roleId
	   			self:selectMember(tabTemp,is_leader)
	   		end
   		end
    end
    local function regHandler( root ,num)
        Mnode.listenTouchEvent(
        {
            node = root,
            swallow = true ,
            begin = function(touch, event)
                -- if DATA_Mission then DATA_Mission:setFindPath( true ) end --有点击操作，就一定是登陆就绪，可以支持密令自动寻路了
                
                local point = self.scrollView1:convertTouchToNodeSpace(touch)
                -- if __TASK then __TASK.startRecordOffPos = cc.p( 0 , 0 )  end
                if not Mnode.isPointInNodeAABB(self.scrollView1, point, self.scrollView1:getViewSize()) then
                    return false 
                else
                    local node = event:getCurrentTarget()
                    node.isMove = false
                    local inside = Mnode.isTouchInNodeAABB(node, touch) and node:isVisible()
                    if inside and self.mainFlag and self.mainFlag:isVisible() then
                        node:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.ScaleTo:create(0.05,0.98)))
                        return true
                    end          
                end
                return false 
            end,

            moved = function(touch, event)
                local node = event:getCurrentTarget()
                if node.recovered then return end
                local startPos = touch:getStartLocation()
                local currPos  = touch:getLocation()
                if cc.pGetDistance(startPos,currPos) > 5 then
                    node.isMove = true
                    node:stopAllActions()
                    node:runAction(cc.ScaleTo:create(0.05,1.0))
                end
            end,

            ended = function(touch, event)
              local node = event:getCurrentTarget()
              if Mnode.isTouchInNodeAABB(node, touch) and not node.isMove then
                AudioEnginer.playTouchPointEffect()
                node:stopAllActions()
                node:runAction(cc.Sequence:create(cc.ScaleTo:create(0.08,1.1),cc.ScaleTo:create(0.08,1.0)))
                clickFun(num)
              end
            end,
        })
    end

	local node = cc.Node:create()
	node:setLocalZOrder(-1)
	local ySub = 51
	local sHeight = size.height
	for i=1,self.batchNum do
		-- local falgBg = createSprite( node,  "res/layers/mission/task_info_bg.png" , cc.p( 0 , sHeight ), cc.p( 0 , 1 )) 
		local falgBg = cc.Node:create()
		falgBg:setContentSize(cc.size(246,51))
		falgBg:setPosition(cc.p(0,sHeight))
		falgBg:setAnchorPoint(cc.p(0,1))
		node:addChild(falgBg)
		if i > 1 then
			createSprite(falgBg,"res/common/split-2.png",cc.p(125,51))
		end
		if not G_TEAM_INFO.has_team then
			createSprite(falgBg,"res/teamup/s"..i..".png",cc.p(20,25),cc.p(0,0.5),nil,0.8)
			createLabel(falgBg,self.noTeamText[i],cc.p(70,25),cc.p(0,0.5),20,true,nil,nil,MColor.yellow_gray,nil,nil,MColor.lable_outLine,3)
		else			
			if G_TEAM_INFO.team_data[i] then
				local tabTemp = G_TEAM_INFO.team_data[i]
				local str1 = {game.getStrByKey("zhanshi"),game.getStrByKey("fashi"),game.getStrByKey("daoshi")}
				local name = tabTemp.name
				local lv = tabTemp.roleLevel
				local school = str1[tabTemp.school]
				if i == 1 then
					createSprite(falgBg,"res/teamup/2.png",cc.p(5,30),cc.p(0,0.5))
				end
				createLabel(falgBg,name,cc.p(45,30),cc.p(0,0.5),18,true,nil,nil,MColor.name_yellow)
				createLabel(falgBg,"Lv"..lv,cc.p(158,30),cc.p(0,0.5),18,true,nil,nil,MColor.lable_black)
				createLabel(falgBg,school,cc.p(240,30),cc.p(1,0.5),18,true,nil,nil,MColor.white)	
				self.bar[i] = createBar( {
					bg = "res/common/progress/jd22-bg.png" ,
					front = {path = "res/common/progress/jd22-bar.png", offX = 0,offY = 0} ,
					parent = falgBg,
					pos = cc.p(50,10) ,
					anchor = cc.p(0,0.5) ,
					percentage = tabTemp.curHP,
				})			
			end
			local send = function(detime)
				if self.countDown%10 == 0 then
					g_msgHandlerInst:sendNetDataByTableExEx(TEAM_CS_GET_MEM_HP, "TeamGetMemHP", {})						
				end
				self.countDown = self.countDown + detime	
    		end
    		if not self.timer then
    			self.timer = startTimerActionEx(self, 1, true, send)
    		end
    		-- g_msgHandlerInst:sendNetDataByTableExEx(TEAM_CS_GET_MEM_HP, "TeamGetMemHP", {})	
		end
		regHandler( falgBg ,i)
		sHeight = sHeight - ySub
	end
	return node
end

function teamNode:setSelectMemEnabled( bEnabled )
	-- body
	self.m_bSelectMemEnabled = bEnabled
end

function teamNode:selectMember(tabTemp,is_lead)
	if not self.m_bSelectMemEnabled then
		return
	end
	local menus = {}
	if userInfo.currRoleStaticId == tabTemp.roleId then
		menus = {
				{ text = game.getStrByKey("leave_team"),tag = 1},
			}

	else
		menus = {
				{ text = game.getStrByKey("look_info"),tag = 1},
				{ text = game.getStrByKey("addas_friend"),tag = 2},
				{ text = game.getStrByKey("add_blackList"),tag = 3},
				{ text = game.getStrByKey("up_captain"),tag = 4},
				--{ game.getStrByKey("kickout_team"),5,func},
			}
		if not is_lead then
			menus[#menus] = nil
		end
	end
	--local operate = createSprite(self, "res/common/scalable/5.png", cc.p(150, 464), cc.p(0, 1),5)
	local height = 20+50*#menus
	--if height < 111 then height = 111 end
	local operate = createScale9Sprite(self, "res/common/scalable/1.png", cc.p(180, 400), cc.size(158,height), cc.p(0, 0.5))
	local  listenner = cc.EventListenerTouchOneByOne:create()
	local flag = false
	listenner:setSwallowTouches(true)
    listenner:registerScriptHandler(function(touch, event) 
								    	local pt = operate:getParent():convertTouchToNodeSpace(touch)
										if cc.rectContainsPoint(operate:getBoundingBox(), pt) == false then
												flag = true
										end
    									return true 
    								end, cc.Handler.EVENT_TOUCH_BEGAN)
    listenner:registerScriptHandler(function(touch, event)
    	local start_pos = touch:getStartLocation()
		local now_pos = touch:getLocation()
		local span_pos = cc.p(now_pos.x-start_pos.x,now_pos.y-start_pos.y)
		local pt = operate:getParent():convertTouchToNodeSpace(touch)
		if flag and (cc.rectContainsPoint(operate:getBoundingBox(), pt) == false) then
			if operate then removeFromParent(operate) operate = nil end
			AudioEnginer.playTouchPointEffect()
		end
	end, cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = operate:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, operate)

	local func = function(tag)
		local switch = {
	        [1] = function() 
	        	if userInfo.currRoleStaticId == tabTemp.roleId then
	        		G_MAINSCENE:refreshTeamRedDot(false)
					g_msgHandlerInst:sendNetDataByTableExEx(TEAM_CS_LEAVE_TEAM, "TeamLeaveTeamProtocol", {})
	        	else
					LookupInfo(tabTemp.name)
				end
	        end,
	        [2] = function() 
				AddFriends(tabTemp.name)
	        end,
		    [3] = function() 
				AddBlackList(tabTemp.name)
			end,
	        [4] = function() 
				g_msgHandlerInst:sendNetDataByTableExEx(TEAM_CS_CHANGE_LEADER, "TeamChangeLeaderProtocol", {["tRoleId"] = tabTemp.roleId})
	        end,
	        [5] = function() 
				g_msgHandlerInst:sendNetDataByTableExEx(TEAM_CS_REMOVE_MEMBER, "TeamRemoveMemberProtocol", {["tRoleId"] = tabTemp.roleId})
	        end,
	        }
		if switch[tag] then switch[tag]() end
		    removeFromParent(operate)
		    operate = nil		    
	end

	for i=1, #menus do
		local item = createMenuItem(operate, "res/component/button/49.png", cc.p(79, height - 35 - (i-1) * 50), function() func(menus[i].tag) end)
		createLabel(item, menus[i].text, getCenterPos(item), nil, 20, true):setColor(MColor.lable_yellow)
	end

end

-- function teamNode:changeRed(hpTab)

-- 	for i = 1,#G_TEAM_INFO.team_data do
-- 		for j = 1,#hpTab do
-- 			if G_TEAM_INFO.team_data[i] and hpTab[j] and G_TEAM_INFO.team_data[i].roleId == hpTab[j][1] then
-- 				g_EventHandler["teamNode"].bar[i]:setPercentage(hpTab[j][2])
-- 				G_TEAM_INFO.team_data[i].curHP = hpTab[j][2]
-- 				break
-- 			end
-- 		end
-- 	end
-- end


return teamNode