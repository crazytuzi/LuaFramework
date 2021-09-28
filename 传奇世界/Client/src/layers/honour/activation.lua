local activation = class("activation",function() return cc.Layer:create() end)

function activation:ctor(honourParams)

	local msgids = {ITEM_SC_EMBLAZONRY_RET}
	require("src/MsgHandler").new(self,msgids)

	local dress = MPackManager:getPack(MPackStruct.eDress)
	local honourGird = dress:getGirdByGirdId(MPackStruct.eMedal)

	-- print("activation")
	createSprite(self,"res/common/bg/infoBg11-2.png",cc.p(360,470))
	createLabel(self,game.getStrByKey("curProp"),cc.p(360,470),nil,22,true,nil,nil,MColor.lable_yellow)
	createSprite(self,"res/common/bg/infoBg11-2.png",cc.p(360,275))
	createLabel(self,game.getStrByKey("nextProp"),cc.p(360,275),nil,22,true,nil,nil,MColor.lable_yellow)
	createLabel(self,game.getStrByKey("texNum"),cc.p(687,185),nil,18,true,nil,nil,MColor.lable_black)
	self.now_item = {}
	self.medalBtn = createTouchItem(self,"res/common/bg/itemBg.png",cc.p(687,315),function() self:input() end)
	local jia = createSprite(self.medalBtn,"res/layers/equipment/jia.png",cc.p(40,40))
	jia:setTag(10)
	self.wen = {}
	-- dump(honourGird,"++++++++++++++++++++")

	self:adjust(honourGird)

	local barBg = createSprite(self,"res/common/progress/jd23-bg.png",cc.p(687,145))
	local progress = cc.ProgressTimer:create(cc.Sprite:create("res/common/progress/jd23-bar.png"))
	progress:setType(cc.PROGRESS_TIMER_TYPE_BAR)
	progress:setBarChangeRate(cc.p(1,0))
	progress:setMidpoint(cc.p(0,1))
	progress:setPercentage(0)
	progress:setPosition(cc.p(687,145))
	self:addChild(progress)
	self.barLab = createLabel(self,"",cc.p(687,145),nil,20,true,nil,nil,MColor.white)
	self.progress = progress

	self.actBtn = createMenuItem(self,"res/component/button/1.png",cc.p(687,90),function() self:active() end)
	createLabel(self.actBtn,game.getStrByKey("activation"),cc.p(69,29),nil,20,true,nil,nil,MColor.lable_yellow)
	self.actBtn:setVisible(false)
	-- self:setProgress()
end

function activation:adjust(honourGird)
	local diwen = MPackStruct.emblazonry1(honourGird)
	local bianwen = MPackStruct.emblazonry2(honourGird)
	local shiwen = MPackStruct.emblazonry3(honourGird)
	-- self.wenTab = {}
	local fenpei = function(wen , kind)		
		if kind ~= -1 then
			self.now_item[kind] = wen
			-- table.insert(self.wenTab,{wen,kind})
			-- self.wenTab[kind] = wen
		end
		-- self:reloadView(kind)
	end

	if diwen and diwen ~= 0 then
		fenpei(diwen,1)
	end
	if bianwen and bianwen ~= 0 then
		fenpei(bianwen,2)
	end
	if shiwen and shiwen ~= 0 then
		fenpei(shiwen,3)
	end
	fenpei(nil,-1)
	-- dump(self.now_item,"000000000000000000" )
	-- dump(self.wenTab,"111111111111111111111")
end


function activation:input()
	print(index,"放什么？")
	-- AudioEnginer.playTouchPointEffect()
			
	local Mreloading = require "src/layers/honour/medal_select"
	local Manimation = require "src/young/animation"
	Manimation:transit(
	{
		node = Mreloading.new(
		{
			now = self.now_item,		
			-- filtrate = function(packId,grid,now)
			-- 	local MequipOp = require "src/config/equipOp"
			-- 	local MpropOp = require "src/config/propOp"
			-- 	local Mconvertor = require "src/config/convertor"
			-- 	local protoId = MPackStruct.protoIdFromGird(grid)
			-- 	local isMedal = protoId >= 1601 and protoId <= 1609
			-- 	local gridId = MPackStruct.girdIdFromGird(grid)
			-- 	local now_gridId = MPackStruct.girdIdFromGird(now.grid)
			-- 	if packId == now.packId and gridId == now_gridId then 
			-- 		return false 
			-- 	else
			-- 		return isMedal
			-- 	end
			-- end,
			filtrate = function(packId,grid,now)
				local tab = {}
				for k,v in pairs(now) do
					tab[#tab+1] = v
				end
				-- dump({packId,grid,now},"222222222222222222")
				-- dump(table.nums(tab),"2222222222333333333")
				-- for k,v in pairs(tab) do
				-- 	if (self.wen[1] and self.wen[1][1] == v[1]) or v[2] == 1 then
				-- 		table.remove(tab,k)
				-- 	end
				-- end
				for i=#tab,1,-1 do
					if (self.wen[1] and self.wen[1][1][1] == tab[i][1]) or tab[i][2] == 1 then
						table.remove(tab,i)
					end
				end				
				-- dump(tab,"88888888888888888")
				return tab,2
			end,
			handler = function(item,status,opWay)
				-- dump({item,opWay},"3333333333333333333333333")							
				table.insert(self.wen,{item,nil})
				dump(self.wen)
				-- self.tip:setVisible(false)
				self:reloadView(item)
				
			end,
			
			act_src = game.getStrByKey("equip_select_btn_title"),
			title_src = game.getStrByKey("medal_select_title"),
			way = 2
		}),
		sp = g_scrCenter,
		ep = g_scrCenter,
		--trend = "-",
		zOrder = 200,
		curve = "-",
		swallow = true,
	})
end

function activation:setProgress(allNum)
	local bag = MPackManager:getPack(MPackStruct.eBag)
	local wenNum = bag:countByProtoId(1003)
	local bili = math.floor(wenNum*100/allNum)
	self.progress:setPercentage(bili)
	self.barLab:setString(wenNum.."/"..allNum)
end

function activation:reloadView()
	if self.medalBtn then
		if self.srcIcon then
			removeFromParent(self.srcIcon)
			self.srcIcon = nil
		end
		local Mprop = require "src/layers/bag/prop"
		-- local MpropOp = require "src/config/propOp"
		-- local packId = item.packId
		-- local grid = item.grid
		-- local gridId = MPackStruct.girdIdFromGird(grid)
		-- local protoId = MPackStruct.protoIdFromGird(grid)
		local btnSize = self.medalBtn:getContentSize()
		self.srcIcon = Mprop.new(
		{
			protoId = self.wen[1][1][1],
			isActive = self.wen[1][1][2] ,
		})
		-- MpropOp.createColorName(grid, self.medalBtn[index], cc.p(btnSize.width/2, btnSize.height/2), cc.p(0.5,0.5), 22)
		Mnode.addChild(
		{
			parent = self.medalBtn,
			child = self.srcIcon,
			pos = cc.p(btnSize.width/2,  btnSize.height/2),
		})
		if self.medalBtn:getChildByTag(10) then
			self.medalBtn:getChildByTag(10):setVisible(false)
		end
		self.actBtn:setVisible(true)
		self:reloadProp()
	end
end

function activation:reloadProp()
	if self.node then
		removeFromParent(self.node)
		self.node = nil
	end
	local node = cc.Node:create()
	self:addChild(node)
	self.node = node
	local curTab = {}
	local actTab = {}
	local jihuoNum = 0
	local honourData = require("src/layers/honour/honourData")
	local posx,posy1,posy2 = 234,448,253
	honourData:init(self.wen,2)
	curTab,jihuoNum = honourData:getCurProp()
	actTab = honourData:getActProp()
	for k,v in pairs(curTab) do
		for m,n in pairs(v) do
			local text = require("src/RichText").new(node, cc.p(posx,posy1), cc.size(470, 100), cc.p(0.0, 1.0), 22, 20, MColor.lable_black)
			text:addText(n, MColor.lable_black,false)
			text:format()
			posy1 = posy1 - 25
		end
	end
	for k,v in pairs(actTab) do
		for m,n in pairs(v) do
			local text = require("src/RichText").new(node, cc.p(posx,posy2), cc.size(470, 100), cc.p(0.0, 1.0), 22, 20, MColor.lable_black)
			text:addText(n, MColor.lable_black,false)
			text:format()
			posy2 = posy2 - 25
		end

	end
	-- print(jihuoNum,"9999999999999999999999")
	self:setProgress(jihuoNum)


end


function activation:active()
	if self.wen[1] and self.wen[1][1][1] then
		local MpropOp = require "src/config/propOp"
		local emblazonryType = MpropOp.shiwen(self.wen[1][1][1])
		local t = {}
		-- print(self.wen[1][1][1],emblazonryType,"2222222222222222")
		t.id = self.wen[1][1][1]
		t.emblazonryType = emblazonryType
		t.opType = 2
		t.posIndex = 0
		g_msgHandlerInst:sendNetDataByTable(ITEM_CS_EMBLAZONRY, "EmblazonryProtocol", t)
	end
	-- if self.srcIcon then
	-- 	removeFromParent(self.srcIcon)
	-- 	self.srcIcon = nil
	-- end
	-- if self.node then
	-- 	removeFromParent(self.node)
	-- 	self.node = nil
	-- end
	-- if self.medalBtn and self.medalBtn:getChildByTag(10) then
	-- 	self.medalBtn:getChildByTag(10):setVisible(true)
	-- end
	-- self.progress:setPercentage(0)
	-- self.barLab:setString("")
end


function activation:networkHander(buff,msgid)
	local switch = {
		[ITEM_SC_EMBLAZONRY_RET] = function()    
			local t = g_msgHandlerInst:convertBufferToTable("EmblazonryRetProtocol", buff)
			-- dump({t.optype,t.emblazonryType},"((((((((((((((")
			if t.optype == 2 then
				if self.srcIcon then
					removeFromParent(self.srcIcon)
					self.srcIcon = nil
				end
				if self.node then
					removeFromParent(self.node)
					self.node = nil
				end
				if self.medalBtn and self.medalBtn:getChildByTag(10) then
					self.medalBtn:getChildByTag(10):setVisible(true)
				end
				self.progress:setPercentage(0)
				self.barLab:setString("")
				TIPS( { type = 1 , str = game.getStrByKey("activeSuccess") } )
			end

		end
		,
	}

 	if switch[msgid] then 
 		switch[msgid]()
 	end
end


return activation