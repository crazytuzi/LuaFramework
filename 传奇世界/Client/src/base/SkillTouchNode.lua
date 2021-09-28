local SkillTouchNode = class("SkillTouchNode",function(parent) return createMainUiNode(parent, 10) end)
local G_SKILL_PAGE = 1
function SkillTouchNode:ctor(parent,skills,callback,paramsPos,isStoryNeed)
	--cc.SpriteFrameCache:getInstance():addSpriteFrames("res/mainui/mainuiskill@0.plist")
	self.max_pagenum = 1
	self.load_data = {}
	if isStoryNeed then
		for k,v in pairs(skills) do
			table.insert(self.load_data,{v[3],1,v[1]})
		end
	else
		for k,v in pairs(paramsPos) do
			if v[1] ~= 0 and v[1] ~= 20 then
				table.insert(self.load_data,v)
			end
		end
	end

    if isInArenaScene then
        self.load_data = TMP_G_SKILLPROP_POS_SHOWN_INBATTLE
    end

	self:addSkillNode(self.load_data,callback)
	--self:setRight(getGameSetById(GAME_SET_ID_RIGHT_HAND) == 1)
	self:setRight()
	self:initTouch()
	self.touchs = {}
	local  listenner = cc.EventListenerTouchOneByOne:create()
    listenner:setSwallowTouches(true)
    listenner:registerScriptHandler(function(touch, event)
    	local lastTouchPos = touch:getLocation()
    	if cc.pGetDistance(lastTouchPos,cc.p(g_scrSize.width,0)) < 260 then
			return true
		end
		return false
        end,cc.Handler.EVENT_TOUCH_BEGAN )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner,self)
end

function SkillTouchNode:addSkillNode(skills,callback)
	local skill_pos = {}
	local MPackManager = require "src/layers/bag/PackManager"
	local pack = MPackManager:getPack(MPackStruct.eBag)
	if skills then
		for i=1,#skills do
			if skills[i][2] == 1 then
				local jnfenlie = getConfigItemByKey("SkillCfg","skillID",skills[i][3],"jnfenlie")
				local useType = getConfigItemByKey("SkillCfg","skillID",skills[i][3],"useType")
				if jnfenlie and jnfenlie == 1 or (useType and useType == 1) then
					skill_pos[skills[i][1]] = {skills[i][3],skills[i][2]}
					if skills[i][1] >= 10 then
						self.max_pagenum = 3
					elseif skills[i][1] >= 6 and self.max_pagenum ~= 3 then
						self.max_pagenum = 2
					end
				end
			elseif skills[i][2] == 2 then
				skill_pos[skills[i][1]] = {skills[i][3],skills[i][2]}
				if skills[i][1] >= 10 then
					self.max_pagenum = 3
				elseif skills[i][1] >= 6 and self.max_pagenum ~= 3 then
					self.max_pagenum = 2
				end
			end
		end
	end

	local addTouchEffect = function(add_node,pos, scale)
		local touch_effect = Effects:create(false)
        if scale then
            touch_effect:setScale(scale)
        else
		    touch_effect:setScale(0.8)
        end
		add_node:addChild(touch_effect , 101)
		touch_effect:setPosition(pos)
		touch_effect:playActionData("toucheffect", 4, 0.25,1)
		local removeFunc = function()
			removeFromParent(touch_effect)
			touch_effect = nil
		end
		performWithDelay(touch_effect,removeFunc,1)
	end

	local centerFunc = function(sender)
		if skill_pos[1] and skill_pos[1][1] and not self.touchs[0] then
			addTouchEffect(self, cc.p(-71,85), 1.0)
			self.touchs[0] = true
	  		local cb = function()
	  			self.touchs[0] = nil
	  		end
	  		performWithDelay(self.center_node,cb,1.0)
	  		if skill_pos[1][2] == 1 then
				callback(0,sender,skill_pos[1][1],skill_pos[1][2] )
			elseif skill_pos[1][2] == 2 then				
				callback(0,sender,skill_pos[1][1],skill_pos[1][2])
				-- MPackManager:useByProtoId(skill_pos[1][1])
			end
		end
	end
	local center_btn = createSprite(self,("res/mainui/skill/ptgjbg.png"),cc.p(10,15),cc.p(0,0.0))
	local dir_sprite = createSprite(self,("res/mainui/skill/6.png"),cc.p(-90,158))
	local dir_sprite2 = createSprite(self,("res/mainui/skill/7.png"),cc.p(-145,90))
    -- 更换了两张箭头的图片，这里就注释
	--dir_sprite2:setFlippedX(true)
	--dir_sprite2:setRotation(-90)
    print("self.max_pagenum=" .. self.max_pagenum .. " G_SKILL_PAGE=" .. G_SKILL_PAGE);
	if self.max_pagenum < G_SKILL_PAGE then G_SKILL_PAGE = self.max_pagenum end
	if self.max_pagenum == 1 then
		dir_sprite:setVisible(false)
		dir_sprite2:setVisible(false)
	elseif self.max_pagenum == 2 then
        -- 更换了两张箭头的图片，这里就注释
		--dir_sprite:setPosition(cc.p(-120,140))
		--dir_sprite:setRotation(-15)
		--dir_sprite2:setPosition(cc.p(-120,140))
		--dir_sprite2:setRotation(-75)
		if G_SKILL_PAGE < 2 then
			dir_sprite:setVisible(false)
		else
			dir_sprite2:setVisible(true)
		end
	end
	-- local dir_sprite = GraySprite:create()
	-- dir_sprite:setSpriteFrame(getSpriteFrame("mainui/skill/cg.png"))
	-- dir_sprite:setPosition(cc.p(-105,150))
	-- self:addChild(dir_sprite)
	-- local dir_sprite2 = GraySprite:create()
	-- dir_sprite2:setSpriteFrame(getSpriteFrame("mainui/skill/cg.png"))
	-- dir_sprite2:setPosition(cc.p(-135,120))
	-- self:addChild(dir_sprite2)
	-- dir_sprite2:setFlippedX(true)
	-- dir_sprite2:setRotation(-90)
	-- if self.max_pagenum < G_SKILL_PAGE then G_SKILL_PAGE = self.max_pagenum end
	-- if self.max_pagenum == 1 then
	-- 	dir_sprite:addColorGray()
	-- 	dir_sprite2:addColorGray()
	-- elseif self.max_pagenum == 2 then
	-- 	if G_SKILL_PAGE < 2 then
	-- 		dir_sprite:addColorGray()
	-- 	else
	-- 		dir_sprite2:addColorGray()
	-- 	end
	-- end
	self.dir_sprites = {dir_sprite,dir_sprite2}


   	local goToShiqu = function()
   	   	if G_MAINSCENE and G_MAINSCENE.map_layer then
   			if G_MAINSCENE.map_layer.isStory then
                if G_MAINSCENE.storyNode:canPick() then
                    G_MAINSCENE.map_layer:autoPickUp(true)
                end
            else
                G_MAINSCENE.map_layer:autoPickUp(true)
            end          
   		end
   	end
    ---------------------------------------------------------------------------------
    local shiquSpan = createScale9SpriteMenu(center_btn, "res/common/scalable/4.png", cc.size(88, 88), cc.p(-99, 206), function()
            print("shiquSpan");
            goToShiqu();
        end);
    shiquSpan:setActionEnable(false);
    shiquSpan:setOpacity(0);
    ---------------------------------------------------------------------------------
   	local shiquBtn = createTouchItem(center_btn,"res/mainui/skill/shiqu.png",cc.p(-99, 206),goToShiqu,true)
    shiquBtn:setTag(121)

   	local goToselectrole = function()
   		if G_MAINSCENE and G_MAINSCENE.map_layer then
            if G_MAINSCENE.map_layer.isStory then
                if G_MAINSCENE.storyNode:canSelectRole() then
                    G_MAINSCENE.map_layer:selectTheRole()
                end
            else
                G_MAINSCENE.map_layer:selectTheRole()
            end  			
   		end
   	end
    ---------------------------------------------------------------------------------
    local selectRoleSpan = createScale9SpriteMenu(center_btn, "res/common/scalable/4.png", cc.size(80, 80), cc.p(-165, 90), function()
            print("selectRoleSpan");
            goToselectrole();
        end);
    selectRoleSpan:setActionEnable(false);
    selectRoleSpan:setOpacity(0);
    ---------------------------------------------------------------------------------
   	local selectRoleNode = createTouchItem(center_btn,"res/mainui/skill/selectrole.png",cc.p(-162, 90),goToselectrole,true)
    selectRoleNode:setTag(122)
    G_TUTO_NODE:setTouchNode(selectRoleNode, TOUCH_MAIN_TARGET)

	self.center_btn = center_btn
	if skill_pos[1] and skill_pos[1][1] then
		local ss = nil
		if skill_pos[1][2] == 1 then
            ---------------------------------------------------------------------------------------------------------------------------
            local menuItemSpanBtn = CIrregularButton:Create("res/mainui/skill/5.png");
            menuItemSpanBtn:SetSwallowByAlpha(true);
            menuItemSpanBtn:setPosition(cc.p(40, 58));
            local function menuItemSpanBtnCallback(sender, eventType)
                print("menuItemSpanBtnCallback");
                if eventType == ccui.TouchEventType.began then
                    print("ccui.TouchEventType.began");
                elseif eventType == ccui.TouchEventType.moved then
                    print("ccui.TouchEventType.moved");
                elseif eventType == ccui.TouchEventType.ended then
                    print("ccui.TouchEventType.ended");
                    if ss and menuItemSpanBtn then
                        centerFunc(ss);
                    end
                elseif eventType == ccui.TouchEventType.canceled then
                    print("ccui.TouchEventType.canceled");
                end
            end
            menuItemSpanBtn:addTouchEventListener(menuItemSpanBtnCallback);
            menuItemSpanBtn:setOpacity(0);
            center_btn:addChild(menuItemSpanBtn);
            ---------------------------------------------------------------------------------------------------------------------------

			local ico = getConfigItemByKey("SkillCfg","skillID",skill_pos[1][1],"ico")
			ss = createTouchItem(center_btn,"res/skillicon/"..ico..".png",cc.p(55,55),centerFunc)
		elseif skill_pos[1][2] == 2 then
            ---------------------------------------------------------------------------------------------------------------------------
            local menuItemSpanBtn = CIrregularButton:Create("res/mainui/skill/5.png");
            menuItemSpanBtn:SetSwallowByAlpha(true);
            menuItemSpanBtn:setPosition(cc.p(40, 58));
            local function menuItemSpanBtnCallback(sender, eventType)
                print("menuItemSpanBtnCallback");
                if eventType == ccui.TouchEventType.began then
                    print("ccui.TouchEventType.began");
                elseif eventType == ccui.TouchEventType.moved then
                    print("ccui.TouchEventType.moved");
                elseif eventType == ccui.TouchEventType.ended then
                    print("ccui.TouchEventType.ended");
                    if ss and menuItemSpanBtn then
                        centerFunc(ss);
                    end
                elseif eventType == ccui.TouchEventType.canceled then
                    print("ccui.TouchEventType.canceled");
                end
            end
            menuItemSpanBtn:addTouchEventListener(menuItemSpanBtnCallback);
            menuItemSpanBtn:setOpacity(0);
            center_btn:addChild(menuItemSpanBtn);
            ---------------------------------------------------------------------------------------------------------------------------

			local icon = getConfigItemByKey("propCfg","q_id",skill_pos[1][1],"q_tiny_icon") or skill_pos[1][1]
			ss = createTouchItem(center_btn,"res/group/itemIcon/"..icon..".png",cc.p(55,55),centerFunc)
			createSprite(center_btn,"res/layers/skill/54.png",cc.p(54,54))
            
			local propNum = pack:countByProtoId(skill_pos[1][1])
			if propNum > 99 then
				propNum = "99+"
			end
			local numShow = createLabel(ss,propNum,cc.p(60,0),cc.p(1,0),22,nil,nil,nil,MColor.yellow)
			-------------------------------------------------
			local tmp_node = cc.Node:create()
			local tmp_func = function(observable, event, pos, pos1, new_grid)
				if event == "-" or event == "+" or event == "=" then
					local newpropNum1 = pack:countByProtoId(skill_pos[1][1])
					if newpropNum1 > 99 then
						newpropNum1 = "99+"
					end
					numShow:setString(newpropNum1)
				end
			end
			tmp_node:registerScriptHandler(function(event)
				if event == "enter" then
					pack:register(tmp_func)
				elseif event == "exit" then
					pack:unregister(tmp_func)
				end
			end)
			ss:addChild(tmp_node)
			---------------------------------------------------
		end
		if ss then
			ss:setScale(1.0)
			ss:setTag(skill_pos[1][1])
		end
	end

	self.center_node = createMainUiNode(self)
	self.center_node:setPosition(cc.p(-35,35))


	--local m_center_node = cc.Menu:create()
	--self:addChild(self.center_node )
	--self.center_node:addChild(m_center_node )
	--m_center_node:setPosition(cc.p(0,0))
	local start_dgree,rotate_dgree = 182,-116
	local r = 160
	local DgreeToN = function(x)
		return x*3.1415926/180
	end
	self.base_time = 25
	local callAction = function(tag,hander)
		if not self.touchs[tag] then
			if self.center_node then
				local pos = cc.p(hander:getPosition())
				addTouchEffect(self.center_node,pos)
			end

			self.touchs[tag] = true
	  		local cb = function()
	  			self.touchs[tag] = nil
	  		end
	  		performWithDelay(self.center_node,cb,1.0)
	  		if skill_pos[tag][2] == 1 then
                --[[for test skill
                if tag == 2 then
                    callback(tag,hander,1050,skill_pos[tag][2])
                elseif tag == 3 then
                    callback(tag,hander,2050,skill_pos[tag][2])
                else
                    callback(tag,hander,3050,skill_pos[tag][2])
                end
                ]]
                
                callback(tag,hander,skill_pos[tag][1],skill_pos[tag][2])
			elseif skill_pos[tag][2] == 2 then				
				callback(tag,hander,skill_pos[tag][1],skill_pos[tag][2])
				--MPackManager:useByProtoId(skill_pos[tag][1])
			end		
		end
	end

    -----------------------------------------------------------------------------------------------------------------------------------------
    local tmpSpanBtnX = {24, 28, 25, 28};
    local tmpSpanBtnY = {38, 38, 35, 36};
    local tmpSpanRotate = {-4.2, -4.2, -4.2, -4.2};
	for i=0,11 do
		if i%4 == 0 then
			--start_dgree = start_dgree - 12
			rotate_dgree = rotate_dgree + 120
		end
		local func = function(hander)
			if skill_pos[i+2] and skill_pos[i+2][1] then			
				callAction(i+2,hander)	
			end
		end
		local pos = cc.p(r*math.cos(DgreeToN(start_dgree-30*i)),r*math.sin(DgreeToN(start_dgree-30*i)))
        
		local menu_item = createTouchItem(self.center_node,"res/mainui/skill/skillbg.png",pos,func)
		menu_item:setTag(i+2)
		menu_item:setLocalZOrder(-1)
		menu_item:setRotation(rotate_dgree)

        -----------------------------------------------该不可见块仅为增大选区------------------------------------------------------------
        local tmpIndex = i%4+1;
        local everySpanBtn = CIrregularButton:Create("res/mainui/skill/" .. tmpIndex .. ".png");
        everySpanBtn:SetSwallowByAlpha(true);
        everySpanBtn:setPosition(cc.p(tmpSpanBtnX[tmpIndex], tmpSpanBtnY[tmpIndex]));
        everySpanBtn:setRotation(tmpSpanRotate[tmpIndex]);
        local function everySpanBtnCallback(sender, eventType)
            print("everySpanBtnCallback");
            if eventType == ccui.TouchEventType.began then
                print("ccui.TouchEventType.began");
            elseif eventType == ccui.TouchEventType.moved then
                print("ccui.TouchEventType.moved");
            elseif eventType == ccui.TouchEventType.ended then
                print("ccui.TouchEventType.ended");
                if menu_item and everySpanBtn then
                    func(menu_item);
                end
            elseif eventType == ccui.TouchEventType.canceled then
                print("ccui.TouchEventType.canceled");
            end
        end
        everySpanBtn:addTouchEventListener(everySpanBtnCallback);
        everySpanBtn:setOpacity(0);
        menu_item:addChild(everySpanBtn);
        ---------------------------------------------------------------------------------------------------------------------------
		

		if skill_pos[i+2] and skill_pos[i+2][1] then
			--menu_item:registerTouchUpHandler(callAction)
			local ss = nil
			if skill_pos[i+2][2] == 1 then
				local ico = getConfigItemByKey("SkillCfg","skillID",skill_pos[i+2][1],"ico")
				ss = cc.Sprite:create("res/skillicon/"..ico..".png") 
			elseif skill_pos[i+2][2] == 2 then
				local icon = getConfigItemByKey("propCfg","q_id",skill_pos[i+2][1],"q_tiny_icon") or skill_pos[i+2][1]
				ss = cc.Sprite:create("res/group/itemIcon/"..icon..".png")
				local propNum1 = pack:countByProtoId(skill_pos[i+2][1])
				if propNum1 > 99 then
					propNum1 = "99+"
				end
				local numShow1 = createLabel(ss,propNum1,cc.p(60,0),cc.p(1,0),22,nil,nil,nil,MColor.yellow)
				-------------------------------------------------
				local tmp_node = cc.Node:create()
				local tmp_func = function(observable, event, pos, pos1, new_grid)
					if event == "-" or event == "+" or event == "=" then
						local newpropNum1 = pack:countByProtoId(skill_pos[i+2][1])
						if newpropNum1 > 99 then
							newpropNum1 = "99+"
						end
						numShow1:setString(newpropNum1)
					end
				end
				tmp_node:registerScriptHandler(function(event)
					if event == "enter" then
						pack:register(tmp_func)
					elseif event == "exit" then
						pack:unregister(tmp_func)
					end
				end)
				ss:addChild(tmp_node)
				---------------------------------------------------
			end
			if ss then
				ss:setScale(0.68)
				ss:setPosition(38,38)
				-- if getGameSetById(GAME_SET_ID_RIGHT_HAND) ~= 1 then
				-- 	ss:setRotation(-85)
				-- else
					ss:setRotation(-5)
				--end
				menu_item:addChild(ss,0,skill_pos[i+2][1])
				createSprite(menu_item,"res/layers/skill/54.png",cc.p(37,37),nil,nil,0.75)
			end
		end
		--m_center_node:addChild(menu_item,0,i+2)
	end
	--self.center_menu = m_center_node
	self.m_rotate_dgree = 0
	-- if Director:isDisplayStats() then
	-- 	self.role_num = createLabel(self, tostring(tablenums(G_MAINSCENE.map_layer.role_tab)),cc.p(-20,15), cc.p(1.0,0.5), 18)
	-- 	local span_near = math.ceil(g_scrSize.width/96)
	-- 	local isPosNear = function(node)
	-- 		local pos = G_MAINSCENE.map_layer:space2Tile(cc.p(node:getPosition()))
	-- 		local rolePos = G_ROLE_MAIN.tile_pos
	-- 		if cc.pGetDistance(pos,rolePos) > span_near then			
	-- 			return false
	-- 		else
	-- 			return true
	-- 		end
	-- 	end
	-- 	local updateNum = function()
	-- 		-- local num = 1
 --   --          -- 脨隆脥脣禄貌脮脽麓贸脥脣露录驴脡脛脺碌录脰脗 G_MAINSCENE == nil
 --   --          if G_MAINSCENE ~= nil and G_MAINSCENE.map_layer ~= nil and G_MAINSCENE.map_layer.role_tab ~= nil then
	-- 		--     for k,v in pairs(G_MAINSCENE.map_layer.role_tab) do
	-- 		-- 	    local role_item = tolua.cast(G_MAINSCENE.map_layer.item_Node:getChildByTag(k), "SpritePlayer")
	-- 		-- 	    if k ~= G_ROLE_MAIN.obj_id and role_item then
	-- 		-- 		    --if isPosNear(role_item) then
	-- 		-- 			    num = num + 1
	-- 		-- 		    --end
	-- 		-- 	    end
	-- 		--     end
 --   --          end
	-- 		self.role_num:setString(tostring(tablenums(G_MAINSCENE.map_layer.role_tab)))
	-- 	end
	-- 	schedule(self.role_num ,updateNum,1)
	-- end
end

function SkillTouchNode:getCenterItem()
	return self.center_btn 
end

function SkillTouchNode:getCenterNode()
	return self.center_node
end

function SkillTouchNode:setRight(isright)
	--if isright then
		self.center_btn:setFlippedX(false)
		self.center_btn:setAnchorPoint(cc.p(1,0))
		self.center_btn:setPosition(cc.p(-16,30))	
		if G_SKILL_PAGE and G_SKILL_PAGE~=1 then
			self.center_node:setRotation((1-G_SKILL_PAGE)*120)
			self.m_rotate_dgree = (1-G_SKILL_PAGE)*120
		end
		self.center_node:setPosition(cc.p(-45,65))
		self:setPosition(cc.p(g_scrSize.width,0))
		local new_hide_item = self.center_node:getChildByTag((G_SKILL_PAGE*4+2)%12)
    	new_hide_item:setVisible(false)
    	local new_hide_item = self.center_node:getChildByTag((G_SKILL_PAGE*4+7)%12 + 2)
    	new_hide_item:setVisible(false)
	-- else
	-- 	self.center_btn:setFlippedX(true)
	-- 	self.center_btn:setPosition(cc.p(-10,15))
	-- 	self.center_btn:setAnchorPoint(cc.p(0,0))
	-- 	self.center_node:setRotation(85)
	-- 	self.center_node:setPosition(cc.p(35,35))
	-- 	self:setPosition(cc.p(0,0))
	-- end
end

function SkillTouchNode:getNowPage()
	return G_SKILL_PAGE
end

function SkillTouchNode:setMaxPage(max_pagenum)
	self.max_pagenum = max_pagenum
end

function SkillTouchNode:initTouch()
	local touch_node = cc.Node:create()
	self:addChild(touch_node,200,200)
	local  listenner = cc.EventListenerTouchOneByOne:create()
    listenner:setSwallowTouches(false)
    listenner:registerScriptHandler(function(touch, event)
    	self.move_touch = nil
    	self.lastTouchPos = touch:getLocation()
    	if cc.pGetDistance(self.lastTouchPos,cc.p(g_scrSize.width,0)) < 260 then
			return true
		end
		self.lastTouchPos = nil
		return false
		end,cc.Handler.EVENT_TOUCH_BEGAN)

    listenner:registerScriptHandler(function(touch, event)
    	local touchPos = touch:getLocation()
		if self.lastTouchPos == nil then
			self.lastTouchPos = touchPos
		else
			if touchPos.x - self.lastTouchPos.x > 20 and touchPos.y - self.lastTouchPos.y > 20 then
				self.move_touch = 1
			elseif self.lastTouchPos.x - touchPos.x > 20 and self.lastTouchPos.y - touchPos.y > 20  then
				self.move_touch = -1
			end
			if self.move_touch then
				local page_num = (G_SKILL_PAGE - self.move_touch -1)%3 + 1
				if self.max_pagenum < 3 and page_num > self.max_pagenum then
					self.move_touch = false
				end
			end
		end
		end,cc.Handler.EVENT_TOUCH_MOVED)

    listenner:registerScriptHandler(function(touch, event)
    	if self.move_touch then
    		local old_hide_item = self.center_node:getChildByTag((G_SKILL_PAGE*4+2)%12)
    		old_hide_item:setVisible(true)
    		local new_hide_item = self.center_node:getChildByTag((G_SKILL_PAGE*4+7)%12 + 2)
    		new_hide_item:setVisible(true)
    		G_SKILL_PAGE = (G_SKILL_PAGE - self.move_touch -1)%3 + 1
    		local new_hide_item = self.center_node:getChildByTag((G_SKILL_PAGE*4+2)%12)
    		new_hide_item:setVisible(false)
    		local new_hide_item = self.center_node:getChildByTag((G_SKILL_PAGE*4+7)%12 + 2)
    		new_hide_item:setVisible(false)
	    	self.m_rotate_dgree = (self.m_rotate_dgree + 120*self.move_touch)%360
	    	self.center_node:runAction(cc.RotateTo:create(0.3,self.m_rotate_dgree))
	    	if self.max_pagenum == 2 then
	    		if G_SKILL_PAGE < 2 then
					self.dir_sprites[1]:setVisible(false)
	    			self.dir_sprites[2]:setVisible(true)
				else
					self.dir_sprites[2]:setVisible(false)
	    			self.dir_sprites[1]:setVisible(true)
				end
	    	end
	    elseif self.move_touch == false then
	    	TIPS( { type = 1 , str = game.getStrByKey("skill_config_tips") } )
	    end
		end,cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = touch_node:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, touch_node)
end

return SkillTouchNode