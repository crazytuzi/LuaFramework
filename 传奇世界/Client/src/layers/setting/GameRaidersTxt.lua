local txt = class("GameRaidersTxt",function() return cc.Layer:create() end )
	
	function txt:ctor(num)
		self.tempOfPage = 10
		self:checkAgain(num)
		self.scrollView = cc.ScrollView:create()

		self.scrollView:setViewSize(cc.size(730,500))
		self.scrollView:setPosition(cc.p(210,35))
		self.scrollView:setScale(1.0)
		self.scrollView:ignoreAnchorPointForPosition(true)
		

		local layer = self:createLayout(num)
		--layer:setContentSize(cc.size(868,self.highTemp[num]))
		self.scrollView:setContainer(layer)
		self.scrollView:updateInset()
		self.scrollView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)

		self.scrollView:setClippingToBounds(true)
		self.scrollView:setBounceable(true)
		self.scrollView:setDelegate()
	  	self:addChild(self.scrollView)

	  	
	  	local layerSize = layer:getContentSize()
	  	
	  	if layerSize.height > 500 then
	  		self.scrollView:setContentOffset(cc.p(0,500 - layerSize.height))
	  	end
	 end

	function txt:checkAgain(num)
		self.titleTable1 = {}
		local cfg = require("src/config/GameRaidersCfg")
	  	for k,v in pairs(cfg) do
	  		if v.q_id == num then
	  			if v.q_Raiderssubtitle then
	  				table.insert(self.titleTable1,v.q_Raiderssubtitle)
	  			end
	  		end
	  	end
	end

	function txt:createLayout(num)
		local highTemp = {800,50,200,50,600,100}
		self:checkAgain(num)
		--local highTemp1 = {-650,0,-150,0,-550,0,0}
	  	if self.tempOfPage ~= num then
			self.scrollView:setContentOffset(cc.p(0,500-highTemp[num]))
		end

	  	self.tempOfPage = num
		local res = "res/layers/GameRaiders/"
		
		if self.temp == nil then
			self.temp = cc.Layer:create()
		else
			self.temp:removeAllChildren()
		end
		self.temp:setContentSize(cc.size(840,highTemp[num]))
		local GR_Txt = require("src/config/GameRaidersCfg")

				if num > 6 then 
					return self.temp
				end
				local i = 1
				local tt = 40
				if num == 6 then
					tt = 99
				elseif num == 5 then 
					tt = 89
				elseif num == 4 then
					tt = 79
				elseif num == 3 then
					tt = 69
				elseif num == 2 then
					tt = 59
				end
				local tempOfLine = 1
				for k,v in pairs(GR_Txt) do
					
					if v.q_id == num then
						local first = v.q_Raiderssubtitle
						local second = v.q_Thestrategycontent
				 		if first then
				 			if i > 1 then
								createSprite(self.temp,"res/common/bg/bg-1.png",cc.p(370,highTemp[num]-(tempOfLine)*58+40),cc.p(0.5,0.5))
							end
							createLabel(self.temp,self.titleTable1[i],cc.p(370,highTemp[num]-(tempOfLine)*58),cc.p(0.5,0.5),24,true,nil,nil,MColor.yellow)
							i = i + 1
				 			--createLabel(self.temp,second,cc.p(10,highTemp[num]-(tempOfLine+1)*57),cc.p(0,1),nil,nil,10)
				 			local contentRichText = require("src/RichText").new(self.temp, cc.p(10,highTemp[num]-(tempOfLine+1)*57+30), cc.size(710, 30), cc.p(0, 1), 24, 22, MColor.white)
							contentRichText:addText(second, MColor.white)
							contentRichText:format()
							if contentRichText then
								tempOfLine = tempOfLine + math.ceil(contentRichText:getContentSize().height/40) + 1
							end
				 		end
				 	-- 	local aend = string.gmatch(second, "%c+")
				 	-- 	for a in aend do
						-- 	if a == '\n' then
						-- 		tempOfLine = tempOfLine + 1
						-- 	end
						-- end
			 		end
				end
		return self.temp
	end

return txt
