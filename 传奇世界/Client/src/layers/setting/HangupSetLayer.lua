 local HangupSetLayer = class("HangupSetLayer",require("src/layers/setting/BaseLayer"))

function HangupSetLayer:ctor(parent)
	local Mprop = require( "src/layers/bag/prop" )
	local MpropOp = require "src/config/propOp"
	self:addScroll(cc.size(930,520),cc.size(935,520),cc.p(0,30))
	local sub_y = 50
	local bag = MPackManager:getPack(MPackStruct.eBag)
	--createSprite(self,"res/common/bg/bg.png",cc.p(480,290),nil,-1)
	--createSprite(self,"res/common/bg/bg-6.png",cc.p(480,290),nil,-1)

    local bg = self:floor("res/common/scalable/panel_outer_base.png",cc.rect(0, 0, 890,504),cc.p(480,260))
    self.base_node:addChild(bg)
   	createScale9Sprite(self.base_node, "res/common/scalable/panel_outer_frame_scale9.png", cc.p(480,260), cc.size(890, 504), cc.p(0.5, 0.5))
    createScale9Sprite(self.base_node,"res/common/scalable/setbg2.png",cc.p(480,420),cc.size(860,110))
    createScale9Sprite(self.base_node,"res/common/scalable/setbg2.png",cc.p(480,270),cc.size(860,110))
    createScale9Sprite(self.base_node,"res/common/scalable/setbg2.png",cc.p(480,120),cc.size(860,110))
    createSprite(self.base_node,"res/common/scalable/cutLine.png",cc.p(660,420))
    createSprite(self.base_node,"res/common/scalable/cutLine.png",cc.p(660,270))
    createSprite(self.base_node,"res/common/scalable/cutLine.png",cc.p(660,120))

	local defaultSet = {}
	self.spr = {}
	self.spr1 = {}
	self.setIcon = {}
	local btnPos = {cc.p(590,370+sub_y),cc.p(590,220+sub_y),cc.p(590,70+sub_y)}

	createLabel(self.base_node, game.getStrByKey("drugText3"),cc.p(430,400+sub_y),cc.p(0,0.5),20,true,nil,nil,MColor.lable_black)
	createLabel(self.base_node, game.getStrByKey("drugText3"),cc.p(430,250+sub_y),cc.p(0,0.5),20,true,nil,nil,MColor.lable_black)
	createLabel(self.base_node, game.getStrByKey("drugText3"),cc.p(430,100+sub_y),cc.p(0,0.5),20,true,nil,nil,MColor.lable_black)

	createLabel(self.base_node, game.getStrByKey("set_blood_down"),cc.p(70,400+sub_y),cc.p(0,0.5), 20,true,nil,nil,MColor.lable_black)
	-- createLabel(self.base_node, game.getStrByKey("drugText"),cc.p(43,320+sub_y),cc.p(0,0.5), 22,true,nil,nil,MColor.lable_black)
	createLabel(self.base_node, game.getStrByKey("set_blood_down"),cc.p(70,250+sub_y),cc.p(0,0.5), 20,true,nil,nil,MColor.lable_black)
	-- createLabel(self.base_node, game.getStrByKey("drugText1"),cc.p(43,170+sub_y),cc.p(0,0.5), 22,true,nil,nil,MColor.lable_black)
	createLabel(self.base_node, game.getStrByKey("set_magic_down"),cc.p(70,100+sub_y),cc.p(0,0.5), 20,true,nil,nil,MColor.lable_black)
	-- createLabel(self.base_node, game.getStrByKey("drugText2"),cc.p(43,20+sub_y),cc.p(0,0.5), 22,true,nil,nil,MColor.lable_black)
	self:createTouchProgress(cc.p(295,355+sub_y),GAME_SET_ID_USE_RED_HP,"redBar")
	self:createTouchProgress(cc.p(295,205+sub_y),GAME_SET_ID_USE_RED_HP_SHORT,"redBar")
	self:createTouchProgress(cc.p(295,55+sub_y),GAME_SET_ID_USE_RED_MP,"blueBar")

	local drugtab = {{GAME_DEFAULT_DRUG_LONG_HP,25},{GAME_DEFAULT_DRUG_SHORT_HP,35},{GAME_DEFAULT_DRUG_LONG_MP,28}}
	local drugTemp = 0

	createLabel(self.base_node,game.getStrByKey("addBlood"),cc.p(70,445+sub_y),cc.p(0,0.5),20,true,nil,nil,MColor.lable_yellow)
	createLabel(self.base_node,game.getStrByKey("addBlood1"),cc.p(70,295+sub_y),cc.p(0,0.5),20,true,nil,nil,MColor.lable_yellow)
	createLabel(self.base_node,game.getStrByKey("addBlue"),cc.p(70,145+sub_y),cc.p(0,0.5),20,true,nil,nil,MColor.lable_yellow)

	local positions = {
		[GAME_SET_RED1] = cc.p(785,370+sub_y),
		[GAME_SET_RED2] = cc.p(785,220+sub_y),
		[GAME_SET_BLUE] = cc.p(785,70+sub_y),
		[GAME_SET_SNOWLOTUS] = cc.p(83,-10+sub_y),
	}

	local switchs = {
		[GAME_SET_RED1] = {game.getStrByKey("set_open"),game.getStrByKey("set_close")},
		[GAME_SET_RED2] = {game.getStrByKey("set_open"),game.getStrByKey("set_close")},
		[GAME_SET_BLUE] = {game.getStrByKey("set_open"),game.getStrByKey("set_close")},
		[GAME_SET_SNOWLOTUS] = game.getStrByKey("auto_snowlotus"),
	}

	local buttonType = {{"res/component/checkbox/openBtn1.png","res/component/checkbox/closeBtn1.png"},{"res/component/checkbox/1-2.png","res/component/checkbox/1.png"}}
	for k,v in pairs(switchs)do
		local temp = 1
		local indefinePor = {cc.p(-245,0),cc.p(0,0.5),MColor.lable_yellow,20}
		if k == GAME_SET_SNOWLOTUS then
			temp = 2
			indefinePor = {cc.p(30,0),cc.p(0,0.5),MColor.lable_yellow,20}
		end		
		self:createSwitch(self,positions[k],v,getGameSetById(k),k,nil,indefinePor,nil,buttonType[temp][1],buttonType[temp][2])
	end
	local sroll = self:getScroll()
    if sroll then
    	sroll:setContentOffset(cc.p(0, -260))
    end


	if not G_DRUG_TAB then
		haveDrug()
	end
	local function callDefaultDrug(drug,num)
		if drug and (drug == 0 or drug > 99) then
			drug = drugtab[num][2]
		end 
		return drug
	end

	local function setdrug(kind)
		if drugTemp ~= 0 then
			defaultSet[kind] = drugTemp
			if kind == 1 then
				setGameSetById(GAME_DEFAULT_DRUG_LONG_HP,drugTemp)
			elseif kind == 2 then
				setGameSetById(GAME_DEFAULT_DRUG_SHORT_HP,drugTemp)
			elseif kind == 3 then
				setGameSetById(GAME_DEFAULT_DRUG_LONG_MP,drugTemp)
			end	
			if self.setIcon[kind] then
				removeFromParent(self.setIcon[kind])
				self.setIcon[kind] = nil
				self.setIcon[kind] = Mprop.new(
				{
					protoId = defaultSet[kind]+20000,
					--tag = G_DRUG_TAB[num][j][1],
				})
				self.setIcon[kind]:setPosition(btnPos[kind])
				self.base_node:addChild(self.setIcon[kind])
				local c = MColor.white
				local dnum = bag:countByProtoId(defaultSet[kind]+20000)
				if dnum < 1 then
					c = MColor.red
				end
				-- createLabel(self.setIcon[kind],dnum,cc.p(70,7),cc.p(1,0),20,true,20,nil,c,defaultSet[kind]+20000)				
				local lab = Mnode.createLabel(
				{
					parent = self.setIcon[kind],
					src = dnum,
					size = 18,
					color = c,
					anchor = cc.p(1, 0),
					pos = cc.p(70,7),
					tag = defaultSet[kind]+20000,
					zOrder = 20,
					outline = false,
				})
				lab:enableOutline(cc.c4b(0,0,0,255),1)
				----------------------------------------------------
				local tmp_node = cc.Node:create()
				local tmp_func = function(observable, event, pos, pos1, new_grid)
					if event == "-" or event == "+" or event == "=" then
						propNum = bag:countByProtoId(defaultSet[kind]+20000)
						self.setIcon[kind]:getChildByTag(defaultSet[kind]+20000):setString(propNum)
						if propNum < 1 then
							self.setIcon[kind]:getChildByTag(defaultSet[kind]+20000):setColor(MColor.red)
						else
							self.setIcon[kind]:getChildByTag(defaultSet[kind]+20000):setColor(MColor.white)
						end
					end
				end

				tmp_node:registerScriptHandler(function(event)
					if event == "enter" then
						bag:register(tmp_func)
					elseif event == "exit" then
						bag:unregister(tmp_func)
					end
				end)
				self.setIcon[kind]:addChild(tmp_node)
				----------------------------------------------------
			end
		end
	end

	self.drugBtn = {[1] = {},[2] = {},[3] = {}}

	local setFun = function(tag,kind,kind1,num)
		-- defaultSet[kind] = tag-20000
		drugTemp = tag-20000
	end
	
	local setDrugFun = function(kind)
		setdrug(kind)
	end

	local checkdrug = function(num)
		local drug = getGameSetById(drugtab[num][1])
		defaultSet[num] = callDefaultDrug(drug,num)
	end
	local loaddrug = function()
		for i = 1,3 do
			checkdrug(i)
		end
	end

	local chooseDrug = function(num)
		checkdrug(num)
		drugTemp = 0
		local sprTemp,nameStr = 0,""
		local sortfun = function(a,b)
			return a[2] < b[2]
		end
		local dn = #G_DRUG_TAB[num]
		table.sort(G_DRUG_TAB[num],sortfun)

		local retSpr = createSprite(self,"res/common/bg/bg27.png",cc.p(480,300),nil,20)
		local closeFun = function()
			removeFromParent(retSpr)
			retSpr = nil
		end
		local bgsize = retSpr:getContentSize()
		createTouchItem(retSpr,"res/component/button/x2.png",cc.p(retSpr:getContentSize().width-30,retSpr:getContentSize().height-25),closeFun)
		-- SwallowTouches(retSpr)
		registerOutsideCloseFunc(retSpr,closeFun,true)
		-- createSprite(retSpr,"res/common/bg/bg27-1.png",cc.p(bgsize.width/2,285))
		createScale9Frame(retSpr,
			"res/common/scalable/panel_outer_base_1.png",
			"res/common/scalable/panel_outer_frame_scale9_1.png",
	        cc.p(16, 100),
	        cc.size(370,374),
	        5)
		createLabel(retSpr,game.getStrByKey("set_drug"),cc.p(bgsize.width/2,500),cc.p(0.5,0.5),22,true,nil,nil,MColor.lable_yellow)
		local scrollView = cc.ScrollView:create()
		local node = nil
	    if nil ~= scrollView then
	        scrollView:setViewSize(cc.size(370,368))
	        scrollView:setPosition(cc.p(14,104))
	        scrollView:setScale(1.0)
	        scrollView:ignoreAnchorPointForPosition(true)
	        local node = cc.Node:create()
	        self.nodeTemp = node
	        node:setContentSize(cc.size(370,368+110*(dn-3)))
	        scrollView:setContainer(node)
	        scrollView:updateInset()
	        scrollView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL )
	        scrollView:setClippingToBounds(true)
	        scrollView:setBounceable(true)
	        retSpr:addChild(scrollView)
	    end
	    scrollView:setContentOffset( cc.p(  0,  - 110*(dn-3) ) )
	    local posy = 368+110*(dn-3)
	    local lastTouch = {}
		for j = 1 ,dn do
			-- self.spr[j] = createSprite(self.nodeTemp,"res/common/table/cell13.png",cc.p(187,posy),cc.p(0.5,1))
			self.spr[j] = createScale9Sprite(self.nodeTemp,"res/common/scalable/item.png",cc.p(187,posy),cc.size(360,110),cc.p(0.5,1))
			self.spr1[j] = createScale9Sprite(self.spr[j],"res/common/scalable/item_sel.png",cc.p(180,55),cc.size(360,110),cc.p(0.5,0.5))
			self.spr1[j]:setVisible(false)
			local dnum = 0
			--if j < dn+1 then
				local c = MColor.white
				dnum = bag:countByProtoId(G_DRUG_TAB[num][j][1])
			
				nameStr = MpropOp.name(G_DRUG_TAB[num][j][1])
			  	createLabel(self.spr[j], nameStr, cc.p(168,55), cc.p(0, 0.5), 20, nil, 5, nil, MpropOp.nameColor(G_DRUG_TAB[num][j][1]))
				self.drugBtn[num][j] = Mprop.new(
				{
					protoId = G_DRUG_TAB[num][j][1],
					--tag = G_DRUG_TAB[num][j][1],
				})
				self.drugBtn[num][j]:setPosition(cc.p(60,55))
				-- local using = createSprite(self.drugBtn[num][j],"res/layers/bag/using.png",cc.p(24,55),nil,10)
				-- using:setTag(12)
				-- using:setVisible(false)
				if dnum < 1 then
					c = MColor.red
				end
				-- createLabel(self.drugBtn[num][j],dnum,cc.p(70,7),cc.p(1,0),20,true,20,nil,MColor.white,G_DRUG_TAB[num][j][1])				
				
				local lab = Mnode.createLabel(
				{
					parent = self.drugBtn[num][j],
					src = dnum,
					size = 18,
					color = c,
					anchor = cc.p(1, 0),
					pos = cc.p(70,7),
					tag = G_DRUG_TAB[num][j][1],
					zOrder = 20,
					outline = false,
				})
				lab:enableOutline(cc.c4b(0,0,0,255),1)
				----------------------------------------------------
				local tmp_node = cc.Node:create()
				local tmp_func = function(observable, event, pos, pos1, new_grid)
					if event == "-" or event == "+" or event == "=" then
						propNum = bag:countByProtoId(tonumber(G_DRUG_TAB[num][j][1]))
						self.drugBtn[num][j]:getChildByTag(G_DRUG_TAB[num][j][1]):setString(propNum)
						if propNum < 1 then
							self.drugBtn[num][j]:getChildByTag(G_DRUG_TAB[num][j][1]):setColor(MColor.red)
						else
							self.drugBtn[num][j]:getChildByTag(G_DRUG_TAB[num][j][1]):setColor(MColor.white)
						end
					end
				end

				tmp_node:registerScriptHandler(function(event)
					if event == "enter" then
						bag:register(tmp_func)
					elseif event == "exit" then
						bag:unregister(tmp_func)
					end
				end)
				self.drugBtn[num][j]:addChild(tmp_node)
				----------------------------------------------------
				self.spr[j]:addChild(self.drugBtn[num][j],5)
				
				if (20000+defaultSet[num]) == G_DRUG_TAB[num][j][1] then
					-- using:setVisible(true)
					-- self.spr[j]:setTexture("res/common/table/cell13_sel.png")
					self.spr1[j]:setVisible(true)
					sprTemp = j					
				end
			-- else
			-- 	createSprite(self.spr[j],"res/common/bg/itemBg.png",cc.p(60,60))
			-- 	nameStr = game.getStrByKey("set_drugtip")
			-- 	createLabel(self.spr[j], nameStr, cc.p(168,65), cc.p(0, 0.5), 20, nil, nil, nil,MColor.lable_black)		
			-- end

			-- if j == dn+1 and sprTemp == 0 then
			-- 	self.spr[j]:setTexture("res/common/table/cell13_sel.png")
			-- 	sprTemp = j
			-- end
			createTouchItem(retSpr,"res/component/button/50.png",cc.p(bgsize.width/2,50),function() setDrugFun(num) closeFun() end,true)
			createLabel(retSpr,game.getStrByKey("sure"),cc.p(bgsize.width/2,50),cc.p(0.5,0.5),22,true,nil,nil,MColor.lable_yellow)
			local  listenner = cc.EventListenerTouchOneByOne:create()
		    listenner:setSwallowTouches(false)
			listenner:registerScriptHandler(function(touch, event)	
					local pt = touch:getLocation()
					local ptTemp = pt		
					pt = self.nodeTemp:convertToNodeSpace(pt)
					if cc.rectContainsPoint(self.spr[j]:getBoundingBox(),pt) then
						lastTouch = {}
						lastTouch = self.nodeTemp:convertToWorldSpace( ptTemp )		
						return true
					end
		    	end,cc.Handler.EVENT_TOUCH_BEGAN )
			listenner:registerScriptHandler(function(touch,event)
				local pt = touch:getLocation()
				local theTouch = self.nodeTemp:convertToWorldSpace( pt )
				pt = self.spr[j]:getParent():convertToNodeSpace(pt)
					if lastTouch and math.abs(lastTouch.x - theTouch.x) < 30 and math.abs(lastTouch.y - theTouch.y) < 30 then			
						if cc.rectContainsPoint(self.spr[j]:getBoundingBox(),pt) then
							-- if j ~= dn+1 then
								setFun(G_DRUG_TAB[num][j][1],num,j,dnum)
							-- else
							-- 	setFun(0,num)
							-- end
							if sprTemp ~= 0 then
								-- self.spr[sprTemp]:setTexture("res/common/table/cell13.png")
								self.spr1[sprTemp]:setVisible(false)
							end
							-- self.spr[j]:setTexture("res/common/table/cell13_sel.png")
							self.spr1[j]:setVisible(true)
							sprTemp = j
						end
					end
		    end,cc.Handler.EVENT_TOUCH_ENDED)
		    listenner:registerScriptHandler(function(touch,event)
				local pt = touch:getLocation()
				pt = self.spr[j]:getParent():convertToNodeSpace(pt)
					if lastTouch and math.abs(lastTouch.x - theTouch.x) < 30 and math.abs(lastTouch.y - theTouch.y) < 30 then			
						if cc.rectContainsPoint(self.spr[j]:getBoundingBox(),pt) then
							-- if j ~= dn+1 then
								setFun(G_DRUG_TAB[num][j][1],num,j,dnum)
							-- else
							-- 	setFun(0,num)
							-- end
							if sprTemp ~= 0 then
								-- self.spr[sprTemp]:setTexture("res/common/table/cell13.png")
								self.spr1[sprTemp]:setVisible(false)
							end
							-- self.spr[j]:setTexture("res/common/table/cell13_sel.png")
							self.spr1[j]:setVisible(true)
							sprTemp = j
						end
					end
		    end,cc.Handler.EVENT_TOUCH_CANCELLED)
			local eventDispatcher =  self.spr[j]:getEventDispatcher()
			eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, self.spr[j])
			
			posy = posy - 110
		end
	end

	-- createTouchItem(self.base_node,"res/common/bg/itemBg.png",cc.p(800,360+sub_y),function() chooseDrug(1) end)
	-- createTouchItem(self.base_node,"res/common/bg/itemBg.png",cc.p(800,210+sub_y),function() chooseDrug(2) end)
	-- createTouchItem(self.base_node,"res/common/bg/itemBg.png",cc.p(800,60+sub_y),function() chooseDrug(3) end)
	loaddrug()
	for i= 1,3 do
		createTouchItem(self.base_node,"res/common/bg/itemBg.png",btnPos[i],function() chooseDrug(i) end)
		self.setIcon[i] = Mprop.new(
		{
			protoId = defaultSet[i]+20000,
			--tag = G_DRUG_TAB[num][j][1],
		})
		self.setIcon[i]:setPosition(btnPos[i])
		self.base_node:addChild(self.setIcon[i])
		local c = MColor.white
		local dnum = bag:countByProtoId(defaultSet[i]+20000)
		if dnum < 1 then
			c = MColor.red
		end
		-- createLabel(self.setIcon[i],dnum,cc.p(70,7),cc.p(1,0),20,true,20,nil,c,defaultSet[i]+20000)				
		local lab = Mnode.createLabel(
		{
			parent = self.setIcon[i],
			src = dnum,
			size = 18,
			color = c,
			anchor = cc.p(1, 0),
			pos = cc.p(70,7),
			tag = defaultSet[i]+20000,
			zOrder = 20,
			outline = false,
		})
		lab:enableOutline(cc.c4b(0,0,0,255),1)
		----------------------------------------------------
		local tmp_node = cc.Node:create()
		local tmp_func = function(observable, event, pos, pos1, new_grid)
			if event == "-" or event == "+" or event == "=" then
				propNum = bag:countByProtoId(defaultSet[i]+20000)
				self.setIcon[i]:getChildByTag(defaultSet[i]+20000):setString(propNum)
				if propNum < 1 then
					self.setIcon[i]:getChildByTag(defaultSet[i]+20000):setColor(MColor.red)
				else
					self.setIcon[i]:getChildByTag(defaultSet[i]+20000):setColor(MColor.white)
				end
			end
		end

		tmp_node:registerScriptHandler(function(event)
			if event == "enter" then
				bag:register(tmp_func)
			elseif event == "exit" then
				bag:unregister(tmp_func)
			end
		end)
		self.setIcon[i]:addChild(tmp_node)
		----------------------------------------------------
	end

	local sroll = self:getScroll()
    if sroll then
    	sroll:setContentOffset(cc.p(0, -260))
    end
end

function  HangupSetLayer:createTouchProgress(pos,flag,color)
	-- local a_node = createSprite(self.base_node,"res/common/progress/jd21_bar.png",pos,nil,10)
	local a_node = createScale9Sprite(self.base_node,"res/component/progress/barBg.png",pos,cc.size(450,23))
	local aabb = a_node:getContentSize()
	local posx = (aabb.width-40)*getGameSetById(flag)/100 +20
	local a_progress = createSprite(a_node, "res/common/progress/jdButton.png",cc.p(posx,10),nil,1,1.2)
	if flag == GAME_SET_ID_USE_RED_HP then
		G_TUTO_NODE:setTouchNode(a_progress, TOUCH_SET_HP)
	end
	local a_lable = createLabel(self.base_node,""..getGameSetById(flag).."%",cc.p(pos.x-100,pos.y+44),nil,20,true,nil,nil,MColor.lable_black)
	if flag == GAME_SET_ID_USE_RED_HP then
		G_TUTO_NODE:setTouchNode(a_lable, TOUCH_SET_HP_PROGRESS_LABEL)
	end
	-- local res_p = "res/common/progress/jd21_red.png"
	-- if flag == GAME_SET_ID_USE_RED_MP then res_p = "res/common/progress/jd21_blue.png" end
	-- local progress = cc.ProgressTimer:create(cc.Sprite:create(res_p))  
	-- progress:setPosition(cc.p(2, 3))
	-- progress:setType(cc.PROGRESS_TIMER_TYPE_BAR)
	-- progress:setAnchorPoint(cc.p(0, 0))
	-- progress:setBarChangeRate(cc.p(1, 0))
	-- progress:setMidpoint(cc.p(0, 1))
	-- a_node:addChild(progress)    
	local res = "res/component/progress/"..color..".png"
	local progress = createLoadingBar(false,{
			parent = a_node,
			res = res,
			dir = true,
			size = cc.size(450,18),
			pos = cc.p(3,12),	
			percentage = 0,
		})
	if flag == GAME_SET_ID_USE_RED_HP then
		G_TUTO_NODE:setTouchNode(progress, TOUCH_SET_HP_PROGRESS)
	end

	--progress:setScaleX(3.0)
	progress:setPercent(getGameSetById(flag))

	local inRect = function(a_pos,rect)
		local rect = rect or aabb
		if a_pos.x >= 0 and a_pos.x < rect.width and
		   a_pos.y >= -15 and a_pos.y < rect.height+15 then
		   return true
		end
		return false
	end
	local listenner = cc.EventListenerTouchOneByOne:create()
    listenner:setSwallowTouches(true)
    listenner:registerScriptHandler(function(touch, event)
    		if self:isVisible() then
    			local a_pos =  a_progress:convertTouchToNodeSpace(touch)
    			local aabb = a_progress:getContentSize()
    			if inRect(a_pos,aabb) then
    				return true
    			end
    		end
       		return false
        end,cc.Handler.EVENT_TOUCH_BEGAN )
    listenner:registerScriptHandler(function(touch, event)
    	local a_pos =  a_node:convertTouchToNodeSpace(touch)
    	if inRect(a_pos) then
	    	if a_pos.x < 20  then a_pos.x = 20 end
			if a_pos.x > aabb.width-30  then a_pos.x = aabb.width-30 end
			a_progress:setPosition(cc.p(a_pos.x,10))
			local set_value = math.floor((a_pos.x-20)*100/(aabb.width-40))
			a_lable:setString(""..set_value.."%")
			print(set_value,"5555555555555555555555")
			progress:setPercent(set_value)
			setGameSetById(flag,set_value)
		end	
     	end,cc.Handler.EVENT_TOUCH_MOVED )

    listenner:registerScriptHandler(function(touch, event)
    	local a_pos =  a_node:convertTouchToNodeSpace(touch)
    	if inRect(a_pos) then
	    	if a_pos.x < 20  then a_pos.x = 20 end
			if a_pos.x > aabb.width-30  then a_pos.x = aabb.width-30 end
			a_progress:setPosition(cc.p(a_pos.x,10))
			local set_value = math.floor((a_pos.x-20)*100/(aabb.width-40))
			a_lable:setString(""..set_value.."%")
			progress:setPercent(set_value)
			setGameSetById(flag,set_value)
		end	
    	end,cc.Handler.EVENT_TOUCH_ENDED )

    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner,a_node)
end

return HangupSetLayer