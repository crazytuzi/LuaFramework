--[[
 --
 -- add by vicky
 -- 2014.08.20
 --
 --]]

 -- 招募侠客
 Broad_getHeroData = {
 	heroName = "",
    type = 0, 
    star = 0  -- 品质
 }

 -- 侠客升级
 Broad_heroLevelUpData = {
 	heroName = "", 
 	type = 0,
 	class = 0,  -- 阶数
 	star = 0 	-- 品质 
 }

 


 local c = cc 

 local Broadcast = class("Broadcast", function()
 		return display.newNode()
 	end)


 -- 请求广播列表
 function Broadcast:getBroadList()
 	GameRequest.Broadcast.getBroadcastList({
 		callback = function(data)

	 		self._hasGetList = true
 			-- dump(data)
 			if string.len(data["0"]) > 0 then 
 				dump(data["0"]) 
 				local data_guangbo_guangbo = require("data.data_guangbo_guangbo")
 				self._allBroadcastList = data_guangbo_guangbo
 			else 
 				self._allBroadcastList = data["1"]
 			end

 			self:createRandomBroadList()
 			self:setNextBroadcast()
 			self:reqCurBList()



 		end
 		})
 end

  -- 请求服务器端当前广播
 function Broadcast:reqCurBList()
 	GameRequest.Broadcast.updateList({
 		callback = function(data)
			print("请求服务器端当前广播")
 			dump(data)
 			GameModel.updateData(data["5"])
 			if data["0"] ~= "" then 
 				dump(data["0"]) 
 			else
 				-- 编辑当前的广播内容
 				game.urgencyBroadcast:addToUrgencyBroadcast(data["2"]) 
 				self:addBroadStrFromSever(data)

 				local mailTip = data["4"]
				if(mailTip ~= nil) then
					game.player:setMailTip(mailTip)
					PostNotice(NoticeKey.MAIL_TIP_UPDATE)
				end
 			end 
		end
 		})
 end


 function Broadcast:getColorByType(param) 
 	local color
 	if param.color ~= nil then 
 		if type(param.color) == "table" then
	 		color = ccc3(param.color[1], param.color[2], param.color[3])
	 	else
	 		color = ccc3(0, 0, 0)
	 	end
	else 
		if param.type == -1 then 
			-- 主角名字颜色
			local star = ResMgr.getCardData(1).star[param.star + 1] or 1
	 		color = QUALITY_COLOR[star]
	 	else 
	 		-- 卡牌阶数对应的颜色 阶数从0开始  
	 		color = NAME_COLOR[param.star]
	 	end 
 	end

 	return color
 end


 function Broadcast:createBroadStrByParam(param)
 	self._broadLbl:removeAllChildrenWithCleanup(true)
 	self._broadLbl:setContentSize(CCSizeMake(0, 0))
 	for _, v in ipairs(param) do
 		-- local lbl = CCLabelTTF:create(v.str, "Microsoft Yahei", 19) 
 		local lbl = CCLabelTTF:create(v.str, FONTS_NAME.font_fzcy, 19) 
 		lbl:setColor(v.color)
 		lbl:setAnchorPoint(ccp(0, 0.58))
 		lbl:setPosition(self._broadLbl:getContentSize().width, 0)
 		self._broadLbl:addChild(lbl)
 		self._broadLbl:setContentSize(CCSizeMake(self._broadLbl:getContentSize().width + lbl:getContentSize().width, lbl:getContentSize().height))
 	end
 end


 -- 根据参数创建广播字符串的参数（颜色，字符串内容）
 function Broadcast:createBroadParamByData(param)
 	-- just for test
 	if param.color == nil then 
 		dump(param)
 	end

 	local data = param.data
 	local contentStr = {}

 	local broadItem = self:getBroadItemById(param.id) 
    local strList = string.split(broadItem.Content, "%s") 

	for i, v in ipairs(data) do
		if i < #data then 
			table.insert(strList, i * 2, data[i].value)
		end
	end

	if #strList > #data + 1 then 
		table.insert(strList, #strList, data[#data].value)
	elseif #data > 0 then 
		table.insert(strList, data[#data].value)
	end

	for i, v in ipairs(strList) do
		if i % 2 == 0 then 
			local color = self:getColorByType(data[i/2]) or ccc3(0, 0, 0) 
			table.insert(contentStr, {
				str = v, 
				color = color
				})
		else
			local color = ccc3(0, 0, 0)
			if param.color ~= nil then
				color = ccc3(param.color[1], param.color[2], param.color[3])
			end
			table.insert(contentStr, {
				str = v, 
				color = color
				})
		end
	end

    return contentStr 
 end


 -- 根据服务器端返回的数据生成广播
 function Broadcast:addBroadStrFromSever(data)
 	if self._bufferBStr == nil then 
 		self._bufferBStr = {}
 	end	

 	if self._waitBroadcastList == nil then 
 		self._waitBroadcastList = {}
 	end

    for i, v in ipairs(data["1"]) do 
    	if data["1"][i].time > 0 then 
    		table.insert(self._waitBroadcastList, data["1"][i])
    	else 
    		-- dump(data["1"][i])
		    local contentStr = self:createBroadParamByData(data["1"][i])
		    if contentStr ~= nil then 
		    	table.insert(self._bufferBStr, contentStr) 
		    end
		end
    end 
 end 


 -- 创建可以随机播放的广播
 function Broadcast:createRandomBroadList()
 	self._canRandomBroadList = {}
 	for _, v in ipairs(self._allBroadcastList) do
 		if v.type == 3 then 
 			local strParam = {}
 			local color = ccc3(0, 0, 0)
 			if v.color ~= nil then 
		 		if type(v.color) == "table" then
			 		color = ccc3(v.color[1], v.color[2], v.color[3])
			 	end
		 	end

 			table.insert(strParam, {
 				str = v.Content, 
 				color = color
 				})

 			table.insert(self._canRandomBroadList, strParam)
 		end
 	end
 end


 -- 随机获取广播
 function Broadcast:getRandomBroadcast()
 	local index = math.random(1, #self._canRandomBroadList)
 	return self._canRandomBroadList[index]
 end


 -- 获取下一个广播
 function Broadcast:setNextBroadcast()
 	local strParam = {}
 	if self._bufferBStr ~= nil and #self._bufferBStr > 0 then 
 		strParam = self._bufferBStr[1]
 		table.remove(self._bufferBStr, 1)
 	else
 		strParam = self:getRandomBroadcast()
 	end

 	if self._broadLbl == nil then 
 		self:initBroadcastLbl()
 	end

 	self:createBroadStrByParam(strParam)
 end


 -- 更新广播
 function Broadcast:initBroadcastLbl() 
	-- 创建裁剪区域  
	local clippingNode = CCClippingNode:create() 
	clippingNode:setContentSize(self._viewSize) 
	clippingNode:setAnchorPoint(ccp(0.5, 0)) 
	clippingNode:setPosition(self._viewSize.width/2, 0) 

	-- 创建裁剪模板，裁剪节点将按照这个模板来裁剪区域  
	local stencil = display.newDrawNode()
	stencil:drawRect({
		x = 0, 
		y = 0, 
		w = clippingNode:getContentSize().width, 
		h = clippingNode:getContentSize().height
		})

	clippingNode:setStencil(stencil)
	clippingNode:setInverted(false)
	self:addChild(clippingNode)

	self._broadLbl = display.newNode()
	self._broadLbl:setPosition(clippingNode:getContentSize().width, clippingNode:getContentSize().height/2)
	clippingNode:addChild(self._broadLbl)
 end


 function Broadcast:initTimeSchedule()
 	-- 更新广播位置
 	local function updateLblPos()
 		if self._broadLbl ~= nil then
	 		local posX = self._broadLbl:getPositionX()
	 		local posY = self._broadLbl:getPositionY()
	 		self._broadLbl:setPosition(posX - 1.0, posY)

	 		if posX < -self._broadLbl:getContentSize().width then 
	 			self._broadLbl:setPosition(self._viewSize.width, posY)
	 			self:setNextBroadcast()
	 		end
	 	end
 	end
 	self.scheduler = require("framework.scheduler")
    self._schedule = self.scheduler.scheduleGlobal(updateLblPos, 0.01, false ) 

    -- 从服务器端获取的广播，判断时间间隔大于0s的，需要倒计时
    local function checkBroadcast()
    	if (self._waitBroadcastList ~= nil) and (#self._waitBroadcastList > 0) then 
    		local needRemove = {}
    		for i, v in ipairs(self._waitBroadcastList) do
    			if v.time > 0 then 
	    			v.time = v.time - 1
    			end

    			if v.time <= 0 then
    				table.insert(needRemove, i)
    				local contentStr = self:createBroadParamByData(v)
    				if contentStr ~= nil then 
    					table.insert(self._bufferBStr, contentStr)
    				end
    			end
    		end

    		for i, v in ipairs(needRemove) do 
    			table.remove(self._waitBroadcastList, i)
    		end
    	end
    end

    self._checkSchedule = self.scheduler.scheduleGlobal(checkBroadcast, 1, false)
 end


 function Broadcast:getBroadItemById(id)
 	local item 
 	for _, v in ipairs(self._allBroadcastList) do 
 		if v.id == id then 
 			item = v 
 			break 
 		end 
 	end 

 	return item 
 end 


 function Broadcast:showPlayerGetHero() 

 	local item = self:getBroadItemById(1) 

 	local data = {}
 	table.insert(data, {
 		value = game.player:getPlayerName(), 
 		type = -1, 
 		star = game.player.m_class 
 		})

 	table.insert(data, {
 		value = Broad_getHeroData.heroName, 
 		type = Broad_getHeroData.type, 
 		star = Broad_getHeroData.star 
 		})

 	local paramData = {
 		color = item.color, 
 		data = data, 
 		id = item.id, 
 		string = item.Content, 
 		type = item.type
 		}

 	local contentStr = self:createBroadParamByData(paramData) 

 	if #self._bufferBStr > 0 then 
	 	table.insert(self._bufferBStr, 1, contentStr)
	else
		table.insert(self._bufferBStr, contentStr)
	end
 end


 function Broadcast:showHeroLevelUp()

 	local item = self:getBroadItemById(2) 

 	local data = {}
 	table.insert(data, {
 		value = game.player:getPlayerName(), 
 		type = -1, 
 		star = game.player.m_class 
 		})

 	table.insert(data, {
 		value = Broad_heroLevelUpData.heroName, 
 		type = Broad_heroLevelUpData.type, 
 		star = Broad_heroLevelUpData.star 
 		})

 	table.insert(data, {
 		value = Broad_heroLevelUpData.class, 
 		color =  {item.arr_color[1] or 153, item.arr_color[2] or 255, item.arr_color[3] or 0}
 		})

 	local paramData = {
 		color = item.color, 
 		data = data, 
 		id = item.id, 
 		string = item.Content, 
 		type = item.type
	 }

 	local contentStr = self:createBroadParamByData(paramData)

 	if #self._bufferBStr > 0 then 
	 	table.insert(self._bufferBStr, 1, contentStr)
	else
		table.insert(self._bufferBStr, contentStr)
	end
 end


 function Broadcast:ctor()
 	-- node需注册，否则onEnter()和onExit()不走
 	self:setNodeEventEnabled(true)
 	
 	self._viewSize = CCSizeMake(display.width * 0.798, 30)
 	self._bufferBStr = {}
 	self._waitBroadcastList = {}

 	self._hasGetList = false

 	self:setAnchorPoint(ccp(0.5, 0))
 end


 function Broadcast:onEnter()
 	if not self._hasGetList then
	 	self:getBroadList()
 	end

 	self:initTimeSchedule()
 end


 function Broadcast:onExit() 
 	if self._schedule ~= nil then 
        self.scheduler.unscheduleGlobal(self._schedule) 
    end 

    if self._checkSchedule ~= nil then 
    	self.scheduler.unscheduleGlobal(self._checkSchedule)
    end
 end



 return Broadcast
