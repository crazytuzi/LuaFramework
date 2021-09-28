local UiSetLayer = class("UiSetLayer",function() return cc.Layer:create() end )

function UiSetLayer:ctor(parent)
	--createSprite(self,"res/common/bg/bg.png",cc.p(self:getContentSize().width/2-60,290),nil,-1)
	createSprite(self, "res/layers/setting/6.png",cc.p(130,260))
	self.a_node = createSprite(self, "res/layers/setting/7.png",cc.p(85,260))
	self.scale = getGameSetById(GAME_SET_ID_SCALE_RATE)/100
	local posy = 8 + (self.scale-1)*367*5
	local p_num1 = math.floor((posy*0.2/389+1)*100)/100
	self.a_progress = createSprite(self.a_node, "res/layers/setting/7-1.png",cc.p(25,posy),nil,99,0.9)
	self.progressNum = createLabel(self.a_progress, p_num1,cc.p(0,130),cc.p(0.5,0.5),20,true)
	createLabel(self.a_node,"1.0",cc.p(100,19),cc.p(0.5,0.5),20,true,nil,nil)
	createLabel(self.a_node,"1.2",cc.p(100,370),cc.p(0.5,0.5),20,true)
	createSprite(self, "res/layers/setting/42.png",cc.p(160,260))
	self:progressOfGreen(posy/4.1)

	local touchFunc = function() 
		self.operate_config = not self.operate_config
		local set_value = 1
		if self.operate_config then
			set_value = 0
			self.skill_node:setRotation(90)
			self.operate_node:setPosition(cc.p(810,180))
			self.skill_node:setPosition(cc.p(250,110))
		else 
			self.skill_node:setRotation(0)
			self.operate_node:setPosition(cc.p(300,180))
			self.skill_node:setPosition(cc.p(870,110))
		end
	end
	createSprite(self, "res/layers/setting/3.png",cc.p(480,500))
	createSprite(self, "res/layers/setting/8.png",cc.p(480,475))
	local touch_item = createTouchItem(self,"res/layers/setting/4.png",cc.p(560,255),touchFunc)
	local skill_node = createSprite(self, "res/mainui/ptgjbg.png",cc.p(870,100),cc.p(1.0,0.0))
	createSprite(skill_node, "res/mainui/skillbg.png",cc.p(-58,28),nil,nil,0.83)
	createSprite(skill_node, "res/mainui/skillbg.png",cc.p(-47,128),nil,nil,0.83)
	createSprite(skill_node, "res/mainui/skillbg.png",cc.p(23,210),nil,nil,0.83)
	createSprite(skill_node, "res/mainui/skillbg.png",cc.p(127,222),nil,nil,0.83)
	self.skill_node = skill_node
	createSprite(self, "res/layers/setting/1.png",cc.p(750,400))
	createSprite(self, "res/layers/setting/5.png",cc.p(770,400))
	self.operate_node = createSprite(self, "res/mainui/joystick_bg.png",cc.p(300,180),nil,nil,0.85)
	createSprite(self.operate_node, "res/mainui/joystick.png",cc.p(87.5,116))
	if getGameSetById(GAME_SET_ID_RIGHT_HAND) ~= 1 then
		touchFunc()
	end

	local  listenner = cc.EventListenerTouchOneByOne:create()
    listenner:setSwallowTouches(true)
        listenner:registerScriptHandler(function(touch, event)
        	if self:isVisible() then
		    	local a_pos =  self.a_node:convertTouchToNodeSpace(touch)
				local aabb = self.a_node:getContentSize()
				if a_pos.x >= 0 and a_pos.x < aabb.width and
				   a_pos.y >= 0 and a_pos.y < aabb.height then
					return true
	    		end
	    	end
       		return false
        end,cc.Handler.EVENT_TOUCH_BEGAN )
    listenner:registerScriptHandler(function(touch, event)
	    	local a_pos =  self.a_node:convertTouchToNodeSpace(touch)
			local aabb = self.a_node:getContentSize()
			if a_pos.x >= 0 and a_pos.x < aabb.width and
			   a_pos.y >= 0 and a_pos.y < aabb.height then
			   	if a_pos.y < 18  then a_pos.y = 18 end
			   	if a_pos.y> aabb.height-20  then a_pos.y = aabb.height-20 end
				self.a_progress:setPosition(cc.p(25,a_pos.y))
				local p_num1 = math.floor((a_pos.y*0.2/367+1)*100)/100
				self.progressNum:setString(p_num1)
				--self.progressNum:setPosition(cc.p(50,a_pos.y))

				self.scale = p_num1
				self:progressOfGreen(math.floor((a_pos.y-20)*100/(aabb.height-40)))
    		end
        end,cc.Handler.EVENT_TOUCH_MOVED )
    listenner:registerScriptHandler(function(touch, event)	
    		local set_value = math.floor(self.scale*100)
    		g_msgHandlerInst:sendNetDataByTableExEx(GAMECONFIG_CS_CHANGE, "GameConfigChangeProtocol", {["gameSetID"] = GAME_SET_ID_SCALE_RATE , ["gameSetValue"] = set_value })
			setGameSetById(GAME_SET_ID_SCALE_RATE,set_value)

        end,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner,self)
	--createScale9SpriteMenu(self,"layers/setting/4.png",cc.size(120,48),cc.p(posx,posy),func,"common/10.png")
end

function  UiSetLayer:progressOfGreen(length)
	if self.progress == nil then
		self.progress = cc.ProgressTimer:create(cc.Sprite:create("res/common/progress/pp.png"))  
	    self.progress:setPosition(cc.p(11, 26))
	    self.progress:setType(cc.PROGRESS_TIMER_TYPE_BAR)
	    self.progress:setAnchorPoint(cc.p(0, 0))
	    self.progress:setBarChangeRate(cc.p(0, 1))
	    self.progress:setMidpoint(cc.p(1, 0))
	    self.a_node:addChild(self.progress)
	end
	self.progress:setScaleY(2.38)
	self.progress:setPercentage(length)
end 

return UiSetLayer