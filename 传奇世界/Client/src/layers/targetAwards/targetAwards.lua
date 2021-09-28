local targetAwards = class("targetAwards", require("src/TabViewLayer"))

function targetAwards:ctor(sender,isRed)
	-- local bg,closeBtn = createBgSprite(self,nil,nil,true)
	-- local msgids = {COMMON_SC_GETMAINOBJECTREWARD_RET}
	-- require("src/MsgHandler").new(self,msgids)
	-- self.btnStr = {"targetAward_ling","targetAward_wei","targetAward_yi"}

	-- -- local red = tolua.cast(sender:getChildByTag(11),"cc.Sprite")
	-- -- if red then
	-- -- 	removeFromParent(red)
	-- -- 	red = nil
	-- -- end
	-- if G_MAINSCENE then
	-- 	self.mainLineData = G_MAINSCENE:setOrGetMainLineData(2)
	-- end

	-- -- dump(self.mainLineData,"bbbbbbbbbbbbbbbbbbbbbbbbbbb")
	-- self.data = {}
	-- for k, v in pairs(self.mainLineData[1]) do
 --        self.data[k] = v
 --    end
	-- self.target = {}
	-- self.red = {}
	-- self.oneNotGet = false
	-- self:checkRed(1)
	-- self.targetNum = 6
	-- local title = createLabel(bg,game.getStrByKey("targetAward_title"),cc.p(480,595),nil,26,true,nil,nil,MColor.lable_yellow)
	-- createScale9Frame(
 --        bg,
 --        "res/common/scalable/panel_outer_base.png",
 --        "res/common/scalable/panel_outer_frame_scale9.png",
 --        cc.p(480,288), 
 --        cc.size(890, 504),
 --        5,
 --        cc.p(0.5,0.5)
 --    )

 --    self:createTableView(bg,cc.size(888,500),cc.p(37,38),true)
	-- self:getTableView():setBounceable(false)


	if G_MAINSCENE then
		self.mainLineData = G_MAINSCENE:setOrGetMainLineData(2)
	end
	local closeLock = true
	--dump(self.mainLineData,"0000000000000000000000")
	self.oneNotGet = false
	self.actionPlayOver = true
	self.page = 1
	self.data = {}
	self.red = {}
	self.finishLabel = {}
	for k, v in pairs(self.mainLineData[1]) do
        self.data[k] = v
        self.red[v] = false
    end
    -- dump(self.red,"11111111111111111111")
	-- self.red = false
	self.btnStr = {"targetAward_ling","targetAward_wei","targetAward_yi"}

	local msgids = {COMMON_SC_GETMAINOBJECTREWARD_RET}
	require("src/MsgHandler").new(self,msgids)

	local halfOfZhou = 472
	local zhouAction = cc.MoveBy:create(1.2,cc.p(halfOfZhou*2,0))
	local zhouAction1 = cc.MoveBy:create((halfOfZhou*2-20)/((halfOfZhou*2)/1.2),cc.p(halfOfZhou*2-20,0))
	local clipNode = cc.ClippingNode:create()
	self:addChild(clipNode)

	local rightZhou = createSprite(self,"res/common/bg/bg77.png",cc.p(-halfOfZhou-10,0))

	local stencil1 = cc.Sprite:create("res/common/newbg/base_bg.png")
	stencil1:setAnchorPoint(cc.p(0.5,0.5))
	stencil1:setPosition(cc.p(10,15))
	stencil1:setScaleY(1.1)
	stencil1:runAction(zhouAction)
	clipNode:setStencil(stencil1)
	clipNode:setInverted(true)
	clipNode:setAlphaThreshold(0)

	rightZhou:runAction(cc.Sequence:create(zhouAction1, cc.CallFunc:create(function() rightZhou:setVisible(true) end) ))--cc.RemoveSelf:create()

	local bg = createSprite(clipNode,"res/common/bg/bg76.png",cc.p(0,0))
	self.bg = bg
	local closeFunc = function(how) 
		if how then
			if closeLock then
				closeLock = false
				if self.page == 2 then
					self:move(-1)
				end
				bg:runAction(cc.Sequence:create(
					cc.DelayTime:create(0.1),
					cc.CallFunc:create(
						function()
							local anim = Effects:create(false)
							anim:setPlistNum(-1)
							anim:setRenderMode(1)
							anim:playActionData2("aimopen",100,1,0)
							anim:setScale(1.37)
							anim:setPosition(cc.p(400,190))
							self.base_node:addChild(anim,9,1024)
						end
					),
					cc.DelayTime:create(4.5),
					cc.CallFunc:create(
						function()
							local zhouActionBack = cc.MoveBy:create(1.2,cc.p(-halfOfZhou*2+20,0))
							local zhouActionBack1 = cc.MoveBy:create((halfOfZhou*2-20)/((halfOfZhou*2-20)/1.2),cc.p(-halfOfZhou*2+20,0))
							stencil1:setPosition(cc.p(halfOfZhou*2-10,15))
							rightZhou:runAction(cc.Sequence:create(cc.CallFunc:create(function() rightZhou:setVisible(true) end) ,zhouActionBack1))
							stencil1:runAction(zhouActionBack)						
						end
					)
				))
				performWithDelay(self, function() removeFromParent(self) end , 6 )
			end
		else
			removeFromParent(self)
		end
	end
	self.closeFunc = closeFunc

	-- registerOutsideCloseFunc( bg , function() removeFromParent(self) end ,true)
	local bgSize = bg:getContentSize()
	createSprite(bg,"res/common/bg/bg78.png",cc.p(bgSize.width/2,557))
	createSprite(bg,"res/layers/cszl/title.png",cc.p(bgSize.width/2,557))
	local closeBtn = createTouchItem(bg,"res/component/button/x2.png",cc.p(bgSize.width-100,540),function() closeFunc(false) end )

	self:checkRed(1)

	self:createScorll()

	self:createPic(bgSize)
	if self.data[1] and getLocalRecord("mainLineTarget1") == true and isRed then
		local lv = getConfigItemByKey("GrowUpTarget","q_id",self.data[1],"q_level")
		if MRoleStruct:getAttr(ROLE_LEVEL) >= lv then
			self:showAward(self.data[1],true)
		end
	end
	G_TUTO_NODE:setShowNode(self, SHOW_TARGETAWORD)
	SwallowTouches(bg)
end

function targetAwards:checkRed(kind,objectID)
	if self.mainLineData then
		local tempNum = table.nums(self.mainLineData[2])		
		if kind == 1 then
			local m,n = 1,true
			for k = #self.data,1,-1 do			
				for i,j in pairs(self.mainLineData[2]) do
					-- print(k,self.data[k],j,"5555555555555555555555")
					if self.data[k] == j then
						table.remove(self.data,k)
						break						
					end
				end
			end
		elseif kind == 2 and objectID then
			-- dump({self.data,objectID},"22222222222222222222222222")
			for k, v in pairs(self.data) do
				if v == objectID then
					self.red[objectID] = true
				end
				if v == 1 then
					self.oneNotGet = true
				end
				-- dump(self.red,"3333333333333")
			end
		elseif kind == 3 and objectID then
			-- if self.red[objectID] then
			-- 	self.red[objectID]:setVisible(false)
			-- 	if self.bgRed then
			-- 		self.bgRed:setVisible(false)
			-- 	end
			-- end
			-- print(objectID,"444444444444444444")
			self.red[objectID] = false
			
			if self.in_menuitem then
				local lab = tolua.cast(self.in_menuitem:getChildByTag(12),"cc.Label")
				if lab then
					lab:setString(game.getStrByKey(self.btnStr[3]))					
				end
				self.in_menuitem:setEnabled(false)
			end
			-- dump(self.mainLineData,"??????????????????????")
			if tempNum and tempNum >= 6 then
				if self.closeFunc then
					self.closeFunc(true)
				end
			end
		end
	end
end

function targetAwards:buttonSta(typeNum,isCanGet)
	local sta = true
	
	for k,v in pairs(self.mainLineData[1]) do
		-- print(v,typeNum,"33334444444444443333333333333")
		if v == typeNum then
			sta = false
			break
		end
	end
	if isCanGet then
		return sta
	elseif self.red[typeNum] then
		local lab = tolua.cast(self.in_menuitem:getChildByTag(12),"cc.Label")
		if lab then
			lab:setString(game.getStrByKey(self.btnStr[1]) )
		end
		self.in_menuitem:setEnabled(true)
	elseif sta then
		local lab = tolua.cast(self.in_menuitem:getChildByTag(12),"cc.Label")
		if lab then
			lab:setString(game.getStrByKey(self.btnStr[2]) )
		end
		self.in_menuitem:setEnabled(false)
	end
end


function targetAwards:createScorll()
	local scrollView = cc.ScrollView:create()
    if nil == scrollView then
    	return
    end
    local viewSize = cc.size(800*2,400)
	scrollView:setViewSize(cc.size(800,400))
    scrollView:setPosition(cc.p(86,112))
    -- scrollView:setScale(1.0)
    scrollView:ignoreAnchorPointForPosition(true)
	local node = cc.Node:create()
    self.base_node = node
    node:setContentSize(viewSize)
    scrollView:setContainer(node)
    scrollView:updateInset()
    
    scrollView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL )
    scrollView:setClippingToBounds(true)
    scrollView:setBounceable(true)
    scrollView:setDelegate()
   	scrollView:setTouchEnabled( false )
    -- scrollView:registerScriptHandler(scrollView1DidScroll,cc.SCROLLVIEW_SCRIPT_SCROLL)
    self.bg:addChild(scrollView)
    self.srollView = scrollView
	
	self.srollView:setContentOffset(cc.p(0,0))
end

function targetAwards:createPic(bgSize)
	if self.base_node then
		local showBtn = false
		if getLocalRecord("mainLineTarget1") ~= true then
			showBtn = true
	    	setLocalRecord("mainLineTarget1",true)
	    	self.actionPlayOver = false
	    end
	    -- self.actionPlayOver = false
	    if showBtn then
	    	local anim = Effects:create(false)
			anim:setPlistNum(-1)
			anim:setRenderMode(1)
			anim:playActionData2("aimopen",100,1,0)
			anim:setScale(1.37)
			anim:setPosition(cc.p(400,190))
			self.base_node:addChild(anim,9,1024)
		end
	    
		local offX,offY = -87,-110
		local sprPos = {cc.p(201+offX,bgSize.height/2+offY),cc.p(401+offX,405+offY),cc.p(391+offX,222+offY),cc.p(608+offX,402+offY),cc.p(787+offX,399+offY),cc.p(701+offX,217+offY)}
		local textPos = {cc.p(99+offX,bgSize.height/2+offY+178),cc.p(305+offX,356+offY),cc.p(275+offX,160+offY),cc.p(515+offX,bgSize.height/2+offY+178),cc.p(694+offX,340+offY),cc.p(531+offX,300+offY)}	
		local labPos = {cc.p(142+offX,bgSize.height/2+offY+152),cc.p(365+offX,465+offY),cc.p(335+offX,280+offY),cc.p(558+offX,bgSize.height/2+offY+152),cc.p(766+offX,466+offY),cc.p(574+offX,272+offY)}	
		for i=1,#sprPos do
			local btn = createTouchItem(self.base_node,"res/layers/cszl/"..i..".png",sprPos[i],function() self:showAward(i) end)
			self.finishLabel[i] = createSprite(self.base_node,"res/component/flag/2.png",labPos[i],nil,5)
			self.finishLabel[i]:setVisible(false)
			local targetCfg = getConfigItemByKey("GrowUpTarget","q_id",i)			
			
			local textLab = createLabel(self.base_node,string.format(game.getStrByKey("targetAward_page"),game.getStrByKey("num_"..tostring(targetCfg.q_type))).." "..targetCfg.q_name,textPos[i],cc.p(0,1),18,true,nil,nil,MColor.yellow)
			textLab:enableOutline(cc.c4b(0, 0, 0, 255), 2)
			local lab = createLabel(self.base_node,"Lv. "..tostring(targetCfg.q_level),cc.p(textPos[i].x+135,textPos[i].y),cc.p(0,1),18,true,nil,nil,MColor.white)
			lab:enableOutline(cc.c4b(0, 0, 0, 255), 2)
			if i == 1 then
				G_TUTO_NODE:setTouchNode(btn, TOUCH_TARGET_BTN1)
			end

			if showBtn then
				lab:setOpacity(0)
				textLab:setOpacity(0)
				btn:setOpacity(0)
				local action = cc.Sequence:create(cc.DelayTime:create(i*0.5),cc.FadeIn:create(i*0.2))
				btn:runAction(action)
				lab:runAction(action:clone())
				textLab:runAction(action:clone())
			end
			if targetCfg.q_level <= MRoleStruct:getAttr(ROLE_LEVEL) then
				if i >= #sprPos then self.actionPlayOver = true self:showFlag() end
				lab:setVisible(false)
			else
				textLab:setColor(MColor.gray)
				lab:setColor(MColor.white)
				if showBtn then
					-- local lock = createSprite(self.base_node,"res/component/checkbox/5.png",sprPos[i])				
					-- lock:setVisible(false)
					btn:runAction(cc.Sequence:create(cc.DelayTime:create(4.5),cc.CallFunc:create(function() btn:setEnable(false) end),cc.DelayTime:create(0.5),cc.CallFunc:create(function() if i >= #sprPos then self.actionPlayOver = true self:showFlag()  end  end)))
				else
					-- createSprite(self.base_node,"res/component/checkbox/5.png",sprPos[i])
					if i >= #sprPos then self.actionPlayOver = true self:showFlag()  end
					btn:setEnable(false)
				end
			end
		end
	end

end

function targetAwards:showFlag()
	if self.actionPlayOver then
		for k,v in pairs(self.mainLineData[2]) do
			self.finishLabel[v]:setVisible(true)
		end
					
		-- performWithDelay(self, function() registerOutsideCloseFunc( self.bg , function() removeFromParent(self) end ,true) end , 2 )
	end
end

function targetAwards:showAward(num,changeQuick)
	if self.actionPlayOver and self.page == 1 then
		if self.secondNode then
			self.secondNode:removeAllChildren()
		end
		local node = cc.Node:create()
		local distance = 870
		node:setPosition(cc.p(distance+400,0))
		self.base_node:addChild(node)
		self.secondNode = node
		local picNum = num
		if num == 1 then
			local job = MRoleStruct:getAttr(ROLE_SCHOOL)
			picNum = "1_"..job
		end
		createSprite(node,"res/layers/cszl/pic/"..picNum..".jpg",cc.p(0,256))
		if self.arrow then
			self.arrow:setVisible(true)
		else
			self.arrow = createTouchItem(self.bg,"res/group/arrows/17-1.png",cc.p(70,300),function() self:move(-1) end)
			self.arrow:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(0.5,cc.p(-10,0)),cc.MoveBy:create(0.5,cc.p(10,0)))))
		end
		local targetCfg = getConfigItemByKey("GrowUpTarget","q_id",num)
		local place = targetCfg.q_link or ""
	    local text = targetCfg.q_depict or ""
	    local name = targetCfg.q_name or ""
	    local awardsTab = unserialize(targetCfg.q_reward)
	    local info = targetCfg.q_info or ""
		local btn = createMenuItem(node,"res/component/button/1.png",cc.p(315,60),function() removeFromParent(self)  __GotoTarget({ru = place})  end)
		if num == 1 then
			G_TUTO_NODE:setTouchNode(btn, TOUCH_TARGET_BTN2)
		end
	    createLabel(node, text ,cc.p(-310,70), cc.p(0.5,0.5),22,true,nil,nil,MColor.black,nil,140,MColor.black,2)   
	    -- local lab = createLabel(node, name ,cc.p(358,310),nil,22,true,nil,nil,MColor.lable_yellow,nil,5,MColor.black,5)
	    -- lab:enableOutline(cc.c4b(0, 0, 0, 255), 2)
	    local lab = Mnode.createLabel(
		{
			src = tostring(name),
			color = MColor.lable_yellow,
			size = 22,
		})
		lab:setMaxLineWidth(5)
		lab:setLineSpacing(-7)
		lab:setPosition(358,310)
		lab:enableOutline(cc.c4b(0, 0, 0, 255), 2)
		node:addChild(lab)
	    local lab1 = createLabel(node, info ,cc.p(0,150),nil,20,true,nil,nil,MColor.white)
	    lab1:enableOutline(cc.c4b(0, 0, 0, 255), 1) 
	    createLabel(btn,game.getStrByKey("goto_activity_now"),cc.p(69,29),nil,22,true,nil,nil,MColor.lable_yellow)
	    local awardsTab1 = {}
	    local awardNode = cc.Node:create()
		local Mprop = require( "src/layers/bag/prop" )
		local temp = 1
		local ling = function()
			if num then
				g_msgHandlerInst:sendNetDataByTableExEx(COMMON_CS_GETMAINOBJECTREWARD, "GetMainObjectRewardProtocol", {["objectID"] = num } )
			end
		end
		-- dump(awardsTab,"999999999999999999999999")
	    for k,v in pairs(awardsTab) do                
	        local icon = Mprop.new(
			{
				protoId = v["itemID"],
				num = v["count"] ,
				cb = "tips",
				showBind = true,
                isBind = v["bind"],

			})
			awardNode:addChild(icon)
	        iconSize = icon:getContentSize()
	        setNodeAttr(icon,cc.p((iconSize.width+10)*temp-295,60),cc.p(0.5,0.5))
	        temp = temp + 1
	        table.insert(awardsTab1,{["id"] = v["itemID"] , ["showBind"] = true, ["isBind"] = v["bind"], ["num"] = v["count"]})
	    end
	    awardNode:setContentSize((iconSize.width+20)*(temp+1),iconSize.height+10)
	    setNodeAttr( awardNode , cc.p( 10 , 50 ) , cc.p( 0 , 0.5 ) )
	    node:addChild(awardNode)

	    self.in_menuitem = createMenuItem(node,"res/component/button/1.png" ,cc.p( 150 , 60 ) , function() 
			-- if self.red and self.red[typeNum]:isVisible() then
				Awards_Panel( { awards = awardsTab1 , award_tip = game.getStrByKey("get_awards") , getCallBack = ling })
			-- end
		end ) 

		local lab = createLabel( self.in_menuitem , game.getStrByKey(self.btnStr[3])  ,getCenterPos( self.in_menuitem ) , cc.p( 0.5 , 0.5 ) , 22 , true , nil , nil , MColor.lable_yellow , 12 , nil , MColor.black , 3 )                             
		self.in_menuitem:setEnabled(false)
		self:checkRed(2,num)
		self:buttonSta(num)
		self:move(1,changeQuick)
	end
end

function targetAwards:move(way,changeQuick)
	if self.actionPlayOver and ((way < 0 and self.page == 2) or (way > 0 and self.page == 1)) then
		local moveDistance = 870
		self.page = way>0 and 2 or 1
		if changeQuick then
			self.base_node:setPosition(cc.p(-moveDistance*way,0))
		else			
			-- dump(self.page,"44444444444444444")
			if way < 0 and self.arrow then
				self.arrow:setVisible(false)
			end
			
			local move = cc.MoveBy:create(0.5,cc.p(-moveDistance*way,0))
			self.base_node:runAction(cc.Sequence:create(cc.EaseExponentialOut:create(move)))
		end
	end
end

function targetAwards:networkHander(buff,msgid)
	local switch = {
		[COMMON_SC_GETMAINOBJECTREWARD_RET] = function()
			local t = g_msgHandlerInst:convertBufferToTable("GetMainObjectRewardRetProtocol", buff)
			local objectID = t.objectID
			-- print(objectID,"objectIDddddddddddddddddddddddd")
			if G_MAINSCENE then
				G_MAINSCENE:setOrGetMainLineData(3,nil,objectID)
				G_MAINSCENE:setOrGetMainLineData(4)
				for k,v in pairs(self.data) do
					if v == objectID then
						if self.finishLabel[objectID] then
							self.finishLabel[objectID]:setVisible(true)
						end
						table.remove(self.data,k)
						break
					end
				end
				self:checkRed(3,objectID)
			end
		end,
	}

 	if switch[msgid] then
 		switch[msgid]()
 	end
end

return targetAwards

--[[
function targetAwards:checkRed(kind,objectID)
	if self.mainLineData then
		local tempNum = table.nums(self.mainLineData[2])		
		if kind == 1 then
			local m,n = 1,true
			for k = #self.data,1,-1 do			
				for i,j in pairs(self.mainLineData[2]) do
					-- print(k,self.data[k],j,"5555555555555555555555")
					if self.data[k] == j then
						table.remove(self.data,k)
						break						
					end
				end
			end
			-- dump(self.data,"ggggggggggggggggggggggg")
		elseif kind == 2 then
			for k, v in pairs(self.data) do
				if self.target[v] and self.red[v] then
					self.red[v]:setVisible(true)
				end
				if v == 1 then
					self.oneNotGet = true
				end
			end
		elseif kind == 3 and objectID then
			if self.red[objectID] then
				self.red[objectID]:setVisible(false)
				if self.bgRed then
					self.bgRed:setVisible(false)
				end
			end
			if self.in_menuitem then
				local lab = tolua.cast(self.in_menuitem:getChildByTag(12),"cc.Label")
				if lab then
					lab:setString(game.getStrByKey(self.btnStr[3]))					
				end
				self.in_menuitem:setEnabled(false)
			end
		end
	end
end

function targetAwards:buttonSta(typeNum,isCanGet)
	local sta = true
	
	for k,v in pairs(self.mainLineData[1]) do
		-- print(v,typeNum,"33334444444444443333333333333")
		if v == typeNum then
			sta = false
			break
		end
	end
	if isCanGet then
		return sta
	elseif self.red[typeNum]:isVisible() then
		local lab = tolua.cast(self.in_menuitem:getChildByTag(12),"cc.Label")
		if lab then
			lab:setString(game.getStrByKey(self.btnStr[1]) )
		end
		self.in_menuitem:setEnabled(true)
	elseif sta then
		local lab = tolua.cast(self.in_menuitem:getChildByTag(12),"cc.Label")
		if lab then
			lab:setString(game.getStrByKey(self.btnStr[2]) )
		end
		self.in_menuitem:setEnabled(false)
	end
end

function targetAwards:showAward(kind,bg,awardsTab,typeNum)
	-- if typeNum then
	-- 	setLocalRecord("mainLineTarget1",true)
	-- end
	
	local ling = function()
		if typeNum then
			g_msgHandlerInst:sendNetDataByTableExEx(COMMON_CS_GETMAINOBJECTREWARD, "GetMainObjectRewardProtocol", {["objectID"] = typeNum } )
		end
	end

	if self.in_menuitem then
		removeFromParent(self.in_menuitem)
		self.in_menuitem = nil
	end
	if self.smallbg then
        removeFromParent(self.smallbg)
        self.smallbg = nil
    end

	if kind == 1 then
		local closeBtn1 = function()
            removeFromParent(self.smallbg)
            self.smallbg = nil
        end
        
        self.smallbg = createSprite(bg,"res/common/bg/bg35.png",cc.p(bg:getContentSize().width/2,bg:getContentSize().height/2),nil,100)
        createLabel(self.smallbg,game.getStrByKey("week_boxgift"),cc.p(203,290),nil,22,true,nil,nil,MColor.lable_yellow)
        registerOutsideCloseFunc(self.smallbg,closeBtn1,true)
        createTouchItem(self.smallbg,"res/component/button/X.png",cc.p(375,290),closeBtn1)
        if awardsTab then
        	local Mprop = require( "src/layers/bag/prop" )
        	local node = cc.Node:create()
        	local temp = 1
        	local iconSize
        	local awardsTab1 = {}
        	-- dump(awardsTab,"2222222222222222222")
            for k,v in pairs(awardsTab) do                
                local icon = Mprop.new(
				{
					protoId = v["itemID"],
					num = v["count"] ,
					cb = "tips",
				})
				node:addChild(icon)
                iconSize = icon:getContentSize()
                setNodeAttr(icon,cc.p((iconSize.width+20)*temp,0),cc.p(0.5,0.5))
                temp = temp + 1
                table.insert(awardsTab1,{["id"] = v["itemID"] , ["isBind"] = false, ["num"] = v["count"]})
            end
            -- {id isBind num showBind streng time }
            node:setContentSize((iconSize.width+20)*(temp+1),iconSize.height+10)
            setNodeAttr( node , cc.p( 250 , 220 ) , cc.p( 0.5 , 0.5 ) )
            self.smallbg:addChild(node)
            self.in_menuitem = createMenuItem(self.smallbg,"res/component/button/2.png" ,cc.p( 203 , 50 ) , function() 
            		if self.red and self.red[typeNum]:isVisible() then
            			Awards_Panel( { awards = awardsTab1 , award_tip = game.getStrByKey("get_awards") , getCallBack = ling })
            		end
            	  	-- self:ling(typeNum)             	  	
            	end ) 
            local lab = createLabel( self.in_menuitem , game.getStrByKey(self.btnStr[3])  ,getCenterPos( self.in_menuitem ) , cc.p( 0.5 , 0.5 ) , 22 , true , nil , nil , MColor.yellow_gray , 12 , nil , MColor.black , 3 )                             
        	self.in_menuitem:setEnabled(false)
        	self:buttonSta(typeNum)
        end
	elseif kind == 2 then
		local isCantGet = self:buttonSta(typeNum,true)
		if isCantGet then
			-- TIPS({type=1, str=game.getStrByKey("targetAward_tip")})
			local Mtips = require "src/layers/bag/tips"
            Mtips.new(
            {
                protoId = awardsTab["itemID"],
				pos = cc.p(0, 0),
            })
		else
			if self.red and self.red[typeNum]:isVisible() then
		    	Awards_Panel( { awards = {{["id"] = awardsTab["itemID"] , ["isBind"] = false, ["num"] = awardsTab["count"]}} , award_tip = game.getStrByKey("get_awards") , getCallBack = ling } )		  
		    else
		    	local Mtips = require "src/layers/bag/tips"
	            Mtips.new(
	            {
	                protoId = awardsTab["itemID"],
					pos = cc.p(0, 0),
	            })
		    end
		end
	end
end

function targetAwards:getAward(targetCfg)
	local place = targetCfg.q_link
    local typeNum = targetCfg.q_type
    local text = targetCfg.q_depict
    local name = targetCfg.q_name

	local bg = createSprite(self,"res/common/bg/bg18.png",cc.p(g_scrSize.width/2,g_scrSize.height/2))
	self.theBg = bg
	local bgsize = bg:getContentSize()
	local closeFunc = function()   
        bg:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 0), cc.CallFunc:create(function() removeFromParent(bg) bg = nil end)))    
    end
    -- if getLocalRecord("mainLineTarget1") ~= true and typeNum == 1 and not self.oneNotGet then
    -- 	self.red[typeNum]:setVisible(false)
    -- 	setLocalRecord("mainLineTarget1",true)
    -- end

	registerOutsideCloseFunc(bg,closeFunc,true)

	createScale9Frame(
        bg,
        "res/common/scalable/panel_outer_base.png",
        "res/common/scalable/panel_outer_frame_scale9.png",
        cc.p(33, 15),
        cc.size(790,454),
        5
    )
    createScale9Frame(
        bg,
        "res/common/scalable/panel_outer_base_1.png",
        "res/common/scalable/panel_outer_frame_scale9_1.png",
        cc.p(42, 125),
        cc.size(772,337),
        5
    )

    createSprite(bg,"res/group/arrows/17-1.png",cc.p(230,70))
    
    createMenuItem(bg,"res/component/button/x2.png",cc.p(bgsize.width - 35,bgsize.height - 23),closeFunc)        
    local tab = unserialize(targetCfg.q_reward)
    local touchBtn = nil
    if #tab > 1 then
    	touchBtn = createTouchItem(bg,"res/fb/defense/boxCan.png",cc.p(130,70),function() self:showAward(1,bg,tab,typeNum) end)
    elseif #tab == 1 then
    	local Mprop = require( "src/layers/bag/prop" )
    	touchBtn = createTouchItem(bg,"res/common/bg/itemBg.png",cc.p(130,70),function() self:showAward(2,nil,tab[1],typeNum) end)
		local propIcon = Mprop.new(
		{
			protoId = tab[1]["itemID"],
			num = tab[1]["count"],
		})
		propIcon:setPosition(40,40)--(130,70)
		touchBtn:addChild(propIcon)    	
    end
    for i,j in pairs(self.mainLineData[2]) do
		-- print(j,"5555555555555555555555")
		if typeNum == j then
			createSprite(bg,"res/component/flag/18.png",cc.p(130,70))
			break						
		end
	end
    self.touchBtn = touchBtn
    local red = createSprite(touchBtn,"res/component/flag/red.png",cc.p(80,75),nil,3)
    red:setVisible(false)    
    if self.red[typeNum]:isVisible() then
    	red:setVisible(true)
    end
    self.bgRed = red
    local btn = createMenuItem(bg,"res/component/button/1.png",cc.p(700,70),function() closeFunc() removeFromParent(self)  __GotoTarget({ru = place})  end)
    createLabel(bg, text ,cc.p(260,70), cc.p(0,0.5),20,true,nil,nil,MColor.lable_yellow,nil,340)   
    createLabel(bg, name ,cc.p(425,502),nil,26,true,nil,nil,MColor.lable_yellow)
    createLabel(btn,game.getStrByKey("goto_activity_now"),cc.p(69,29),nil,22,true,nil,nil,MColor.lable_yellow)
    

end


function targetAwards:tableCellTouched(table,cell)

end

function targetAwards:tableCellAtIndex(tableView,idx)
	local idex = idx + 1
	local cell = tableView:dequeueCell()
    if cell == nil then
        cell = cc.TableViewCell:new()
    else
        cell:removeAllChildren()
    end
    local posx = 148
    for i = 1 , 3 do
    	if (idx*3+i) <= self.targetNum then
		    local targetCfg = getConfigItemByKey("GrowUpTarget","q_id",idx*3+i)
			self.target[idx*3+i] = createMenuItem(cell,"res/common/bg/bg72.png",cc.p(posx,125),function() self:getAward(targetCfg) end)			
			self.red[idx*3+i] = createSprite(self.target[idx*3+i],"res/component/flag/red.png",cc.p(275,225))
			self.red[idx*3+i]:setVisible(false)
			-- if getLocalRecord("mainLineTarget1") ~= true then
			-- 	self.red[1]:setVisible(true)
			-- end
			-- local spr = createSprite(self.target[idx*3+i],"res/common/bg/titleLine.png",cc.p(143.5,50))			
			local spr = createScale9Sprite(self.target[idx*3+i], "res/common/scalable/14_1.png", cc.p(143.5,50),cc.size(236, 41))
			createLabel(spr,string.format(game.getStrByKey("targetAward_page"),game.getStrByKey("num_"..tostring(targetCfg.q_type))).." "..targetCfg.q_name,cc.p(118,20),nil,20,true,nil,nil,MColor.lable_yellow)			
			if targetCfg.q_level <= MRoleStruct:getAttr(ROLE_LEVEL) then

			else
				createLabel(self.target[idx*3+i],"Lv. "..tostring(targetCfg.q_level),cc.p(255,205),cc.p(1,0.5),20,true,nil,nil,cc.c3b(250,247,211))
				createSprite(self.target[idx*3+i],"res/component/checkbox/5.png",cc.p(143.5,130))
				self.target[idx*3+i]:setEnabled(false)
			end
			posx = posx + 295
		end
	end
	self:checkRed(2)

    return cell
end

function targetAwards:numberOfCellsInTableView(table)
	return math.ceil(self.targetNum/3)
end

function targetAwards:cellSizeForTable(table,idx)
	return 250,885
end

function targetAwards:networkHander(buff,msgid)
	local switch = {
		[COMMON_SC_GETMAINOBJECTREWARD_RET] = function()
			local t = g_msgHandlerInst:convertBufferToTable("GetMainObjectRewardRetProtocol", buff)
			local objectID = t.objectID
			-- print(objectID,"objectIDddddddddddddddddddddddd")
			if G_MAINSCENE then
				G_MAINSCENE:setOrGetMainLineData(3,nil,objectID)
				G_MAINSCENE:setOrGetMainLineData(4)
				self:checkRed(3,objectID)
				if self.theBg then
					createSprite(self.theBg,"res/component/flag/18.png",cc.p(130,70))
				end
			end
		end,
	}

 	if switch[msgid] then
 		switch[msgid]()
 	end
end
]]
