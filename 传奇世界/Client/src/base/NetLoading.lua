local NetLoading = class("NetLoading", function() return cc.Node:create() end)
NetLoading.maxTime = 5
NetLoading.readTime = {2, 4, 6, 8, 10}
NetLoading.curTime = 1

function NetLoading:ctor(isReconnect, time, delaytime)
	local addLabel = createLabel
	local addSprite = createSprite

	self.timeCount = 0
	local defTime = time or 15
	local ndelaytime = delaytime or 0.8
	self.time_max = (isReconnect and NetLoading.readTime[NetLoading.curTime]) and NetLoading.readTime[NetLoading.curTime] or defTime
	local currScene = Director:getRunningScene()
	if not currScene then return end
	if currScene:getChildByTag(999999) then
		--超时定时器重置
		self.timeCount = 0
		cclog("NetLoading exist already")
		return
	end
	cclog("---------------NetLoading---------------- time:" .. defTime .. ", delaytime:" .. ndelaytime)
	currScene:addChild(self)
	self:setLocalZOrder(10000)
	self:setTag(999999)

	local uiFunc = function()
		local colorbg = cc.LayerColor:create(cc.c4b(0, 0, 0, 150))
		self:addChild(colorbg)
		
		local spr = addSprite(self,"res/common/netLoading.png",g_scrCenter)

		self.str = ""--game.getStrByKey("loading")
		if isReconnect == true then
			self.str = game.getStrByKey("reconnecting")
			self.secsLab = createLabel(spr, (self.time_max -self.timeCount)..game.getStrByKey("sec"),cc.p(250,-15),cc.p(0.0,0.5), 22)
			self.lab = createLabel(spr, self.str..". ",cc.p(100,-15),cc.p(0.0,0.5), 22)
		end
		
	    local runeffect = Effects:create(false)
	    runeffect:playActionData("loading", 6, 0.6, -1)
	    runeffect:setAnchorPoint(cc.p(0.5,0.0))
	    spr:addChild(runeffect, 2)
	    runeffect:setPosition(cc.p(150,10))
		schedule(self,function() self:loading() end,1)
	end

	if ndelaytime > 0 then
		performWithDelay(self,uiFunc,ndelaytime)
	else
		uiFunc()
	end

	local  listenner = cc.EventListenerTouchOneByOne:create()
    listenner:setSwallowTouches(true)
    listenner:registerScriptHandler(function(touch, event)
     	return true
        end,cc.Handler.EVENT_TOUCH_BEGAN )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner,self)
end

function NetLoading:loading()
	self.timeCount = self.timeCount+1
	if self.secsLab then

		local backToLogin = function()
			print("loading .. backToLogin")
			NetLoading.curTime = 1
			userInfo.connStatus = RECONNECTFAILED
			globalInit()
			game.ToLoginScene()
		end

		local tryAgain = function()
			print("loading .. tryAgain", NetLoading.curTime)
			NetLoading.curTime = NetLoading.curTime + 1
			addNetLoading(nil,nil,true)
			if userInfo.reconnResponse >= userInfo.reconnRequest then
				if GameSocketLunXun then
					LuaSocket:getInstance():openSocket(2,0,userInfo.gatewayPort, userInfo.gatewayAddr, "180.163.21.23", "223.167.86.53", "183.192.196.158", "182.254.42.61", "203.205.142.194")
				else
					LuaSocket:getInstance():openSocket(0,0,userInfo.gatewayPort, userInfo.gatewayAddr)
				end
		    	userInfo.connStatus = CONNECTING
		    	userInfo.connType = ENTER
		    	userInfo.isReconn = 1
		    	userInfo.reconnRequest = 1
		    	userInfo.reconnResponse = 0
			end 
		end

		if self.timeCount == self.time_max then
			userInfo.connStatus = RECONNECTFAILED
			if NetLoading.curTime >= NetLoading.maxTime then
				TIPS({type = 1 , str = game.getStrByKey("net_tip4")})
				performWithDelay(G_MAINSCENE or Director:getRunningScene(), function ()
					backToLogin()
				end, 2)
				removeNetLoading()
				return
			end

			local ret = MessageBoxYesNoOnTop(nil, game.getStrByKey("net_tip1"), tryAgain, backToLogin)
			removeNetLoading()
			performWithDelay(ret, function() backToLogin() end, 30)
			return
		elseif self.timeCount == 1  then
			if G_MAINSCENE and G_MAINSCENE.map_layer then
				G_MAINSCENE.map_layer:cleanAstarPath(true,true)
				AudioEnginer.stopAllEffects()
				G_MAINSCENE.map_layer.play_step = nil
			end
		end
		self.secsLab:setString((self.time_max-self.timeCount)..game.getStrByKey("sec"))
	end

    if __G_ON_CREATE_ROLE then
	    MessageBox(game.getStrByKey("bad_heart_speed_tip"), game.getStrByKey("sure"), function()
			    globalInit();
			    game.ToLoginScene();
		    end)
        removeFromParent(self);
        return;
	end

	if self.timeCount >= self.time_max then
		removeFromParent(self)
		TIPS({ type = 1 , str = game.getStrByKey("net_tip2") })
		return
	end   

	local strEx = {". . ",". . . ",". "}
	local i = self.timeCount%3+1
	if self.lab then self.lab:setString(self.str..strEx[i]) end
end

return NetLoading