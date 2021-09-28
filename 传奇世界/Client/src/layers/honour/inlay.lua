local inlay = class("inlay",function() return cc.Layer:create() end)

function inlay:ctor( honourParams )

	local msgids = {ITEM_SC_EMBLAZONRY_RET}
	require("src/MsgHandler").new(self,msgids)


	local dress = MPackManager:getPack(MPackStruct.eDress)
	local honourGird = dress:getGirdByGirdId(MPackStruct.eMedal)

	dump(honourGird,"inlay")


	createSprite(self,"res/common/bg/infoBg11-2.png",cc.p(360,470))
	createLabel(self,game.getStrByKey("inlayLook"),cc.p(360,470),nil,22,true,nil,nil,MColor.lable_yellow)
	createSprite(self,"res/common/bg/infoBg11-2.png",cc.p(360,275))
	createLabel(self,game.getStrByKey("suitProp"),cc.p(360,275),nil,22,true,nil,nil,MColor.lable_yellow)

	local pos = {{cc.p(595,220),cc.p(595,170)},{cc.p(775,220),cc.p(775,170)},{cc.p(685,421),cc.p(685,471)}}
	local str = {game.getStrByKey("bottomTex"),game.getStrByKey("barTex"),game.getStrByKey("texture")}


	-- dump({diwen,bianwen,shiwen},"222222222222222222222222")

	self.medalBtn = {}
	--{packId=params.packId, grid=params.grid} 需读取是否已带上纹饰
	self.srcIcon = {}
	for i=1 , #pos do
		self.medalBtn[i] = createTouchItem(self,"res/common/bg/itemBg.png",pos[i][1],function() self:input(i) end)
		local jia = createSprite(self.medalBtn[i],"res/layers/equipment/jia.png",cc.p(self.medalBtn[i]:getContentSize().width/2,self.medalBtn[i]:getContentSize().height/2))
		jia:setTag(10)
		createLabel(self,str[i],pos[i][2],nil,18,true,nil,nil,MColor.lable_black)
	end

	self.tip = createLabel(self,game.getStrByKey("texTip"),cc.p(683,90),nil,17,true,nil,nil,MColor.name_gray)

	self.now_item = {{},{},{}}

	self:adjust(honourGird)

end

function inlay:adjust(honourGird,isReturn)
	local diwen = MPackStruct.emblazonry1(honourGird)
	local bianwen = MPackStruct.emblazonry2(honourGird)
	local shiwen = MPackStruct.emblazonry3(honourGird)
	self.wenTab = {}
	local fenpei = function(wen , kind)		
		if kind ~= -1 then
			if not isReturn then
				self.now_item[kind] = wen
			end
			-- table.insert(self.wenTab,{wen,kind})
			self.wenTab[kind] = {wen,kind}
		end
		if not isReturn then
			self:reloadView(kind)
		end
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
	-- dump(self.now_item,"1111111111111111111")
	-- dump(self.wenTab,"4444444444444444444444")
	if isReturn then
		return self.wenTab
	end
end



function inlay:input(index)
	print(index,"放什么？")
	-- AudioEnginer.playTouchPointEffect()
			
	local Mreloading = require "src/layers/honour/medal_select"
	local Manimation = require "src/young/animation"
	Manimation:transit(
	{
		node = Mreloading.new(
		{
			now = self.now_item[index],
			-- filtrate = function(packId, grid, now)
			-- 	local MequipOp = require "src/config/equipOp"
			-- 	local MpropOp = require "src/config/propOp"
			-- 	local Mconvertor = require "src/config/convertor"
				
			-- 	local protoId = MPackStruct.protoIdFromGird(grid)
			-- 	-- 是否是勋章
			-- 	-- local isMedal = protoId >= 30004 and protoId <= 30006
			-- 	-- if MPackStruct.categoryFromGird(grid) ~= MPackStruct.eEquipment then --or isMedal then
			-- 	-- 	return false
			-- 	-- end
			-- 	print(protoId,"protoId11111111111111111111")
			-- 	local gridId = MPackStruct.girdIdFromGird(grid)
			-- 	local now_gridId = MPackStruct.girdIdFromGird(now.grid)
				
			-- 	if packId == now.packId and gridId == now_gridId then return false end
				
			-- 	local maxLayer = MequipOp.specialAttrMaxLayer(protoId)
			-- 	local specialAttr = MPackStruct.specialAttrFromGird(grid) or 0
				
			-- 	return specialAttr < maxLayer
			-- end,
			filtrate = function(packId,grid,now,isDress)
				local MequipOp = require "src/config/equipOp"
				local MpropOp = require "src/config/propOp"
				local Mconvertor = require "src/config/convertor"
				local protoId = MPackStruct.protoIdFromGird(grid)
				-- dump(isDress,"oooooooooooooooooooooo")
				if isDress then
					-- dump({grid,packId,now},"ppppppppppppppppppppppppppppp")
					-- -- local isMedal = protoId >= 30004 and protoId <= 30006
					-- -- if isMedal then
					-- -- 	for i=1,3 do  --检测勋章3个纹是否有

					-- -- 	end
					-- -- end
					-- local wen = {}
					-- if index == 1 then
					-- 	wen = MPackStruct.emblazonry1(grid)
					-- elseif index == 2 then
					-- 	wen = MPackStruct.emblazonry2(grid)
					-- elseif index == 3 then
					-- 	wen = MPackStruct.emblazonry3(grid)
					-- end
					-- dump(wen,"wenwenwnewnewenwenwen")

					return now,4
				else
					local isWen
					if index == 1 then
						isWen = MpropOp.shiwen(protoId) == index
					elseif index == 2 then
						isWen = MpropOp.shiwen(protoId) == index
					elseif index == 3 then
						isWen = MpropOp.shiwen(protoId) == index
					end
					local gridId = MPackStruct.girdIdFromGird(grid)
					local now_gridId = MPackStruct.girdIdFromGird(now.grid)
					if packId == now.packId and gridId == now_gridId then 
						return false 
					else
						return isWen,1
					end
				end
			end,
			handler = function(item,status,opWay)	
				-- dump({item,opWay},"7777777777777777777777777")	

				if opWay == 4 then
					local MpropOp = require "src/config/propOp"
					local num = MpropOp.shiwen(item[1])
					self:inlay(item[1],num,0,opWay)


					
				elseif opWay == 1 then

					local protoId = MPackStruct.protoIdFromGird(item.grid)
					local isActive = MPackStruct.active(item.grid)				
					self.now_item[index] = {protoId,isActive}
					-- self.tip:setVisible(false)
					-- dump(self.now_item[index],"5555555555555555555555555555")
					local pack = MPackManager:getPack(MPackStruct.eBag)
					local gridId = MPackStruct.girdIdFromGird(item.grid)
					-- print(protoId,isActive,gridId,"6666666666666666666666")
					self:inlay(protoId,index,gridId,opWay)
				end
				
				-- self:reloadView(index)				
			end,
			
			act_src = table.nums(self.now_item[index]) > 0 and game.getStrByKey("disinlay") or game.getStrByKey("inlay"),
			title_src = game.getStrByKey("medal_select_title"),
			way = table.nums(self.now_item[index]) > 0 and 2 or 1
		}),
		sp = g_scrCenter,
		ep = g_scrCenter,
		--trend = "-",
		zOrder = 200,
		curve = "-",
		swallow = true,
	})
end

function inlay:inlay(protoId,index,gridId,opType)
	local t = {}
	-- print(protoId,index,gridId,opType,"2222222222222222")
	t.id = protoId
	t.emblazonryType = index
	t.opType = opType
	t.posIndex = gridId
	g_msgHandlerInst:sendNetDataByTable(ITEM_CS_EMBLAZONRY, "EmblazonryProtocol", t)

end

function inlay:reloadView(index)
	-- dump(,"333333333333333")
	print(index)
	if self.medalBtn[index] then
		if self.srcIcon[index] then
			removeFromParent(self.srcIcon[index])
			self.srcIcon[index] = nil
		end
		local Mprop = require "src/layers/bag/prop"
		local MpropOp = require "src/config/propOp"
		-- local packId = item.packId
		-- local grid = item.grid
		-- local gridId = MPackStruct.girdIdFromGird(grid)
		-- local protoId = MPackStruct.protoIdFromGird(grid)
		local btnSize = self.medalBtn[index]:getContentSize()
		self.srcIcon[index] = Mprop.new(
		{
			protoId = self.now_item[index][1],
			isActive = self.now_item[index][2] ,
			-- grid = grid,
			-- strengthLv = strengthLv,

		})
		-- MpropOp.createColorName(grid, self.medalBtn[index], cc.p(btnSize.width/2, btnSize.height/2), cc.p(0.5,0.5), 22)
		Mnode.addChild(
		{
			parent = self.medalBtn[index],
			child = self.srcIcon[index],
			pos = cc.p(btnSize.width/2,  btnSize.height/2),
		})
		if self.medalBtn[index]:getChildByTag(10) then
			self.medalBtn[index]:getChildByTag(10):setVisible(false)
		end
		-- dump(self.now_item,"))))))))))))))))))))")
		if self.now_item[index] ~= {} then
			self.wenTab[index] = {self.now_item[index],index}	
		end
		-- index = -1	
	end
	if index == -1 then
		self:reloadProp()
	end

end

function inlay:reloadProp(isReturn,wenshiTab)
	if self.node then
		removeFromParent(self.node)
		self.node = nil
	end

	local goodTab = {}
	local suitTab = {}

	local honourData = require("src/layers/honour/honourData")

	local posx ,posy1,posy2 = 234,448,253

	local node = cc.Node:create()
	if not isReturn then
		self:addChild(node)
	end
	self.node = node

	if isReturn and wenshiTab then
		self.wenTab = wenshiTab		
		posy1 = 0
		posx = 0
		createLabel(node,game.getStrByKey("wenshiInlay"),cc.p(posx,posy1),cc.p(0,1),20,true,nil,nil,MColor.lable_yellow)
		posy1 = posy1 -35
	end

	honourData:init(self.wenTab)
	goodTab = honourData:getGoodProp()
	suitTab = honourData:getSuitProp()
	local tempY = 0
	for k,v in pairs(goodTab) do
		for m,n in pairs(v) do
			local text = require("src/RichText").new(node, cc.p(posx,posy1), cc.size(470, 100), cc.p(0.0, 1.0), 22, 20, MColor.lable_black)
			text:addText(n, MColor.lable_black,false)
			text:format()
			posy1 = posy1 - 25
			tempY = tempY + 1
		end
	end
	if isReturn then
		posy2 = posy1
	end
	for k,v in pairs(suitTab) do
		for m,n in pairs(v) do
			local text = require("src/RichText").new(node, cc.p(posx,posy2), cc.size(470, 100), cc.p(0.0, 1.0), 22, 20, MColor.lable_black)
			text:addText(n, MColor.lable_black,false)
			text:format()
			posy2 = posy2 - 25
			tempY = tempY + 1
		end
	end

	if isReturn then
		return node,tempY+1
	end
end


function inlay:networkHander(buff,msgid)
	local switch = {
		[ITEM_SC_EMBLAZONRY_RET] = function()    
			local t = g_msgHandlerInst:convertBufferToTable("EmblazonryRetProtocol", buff)
			-- dump({t.optype,t.emblazonryType},"((((((((((((((")
			if t.optype == 1 then
				self:reloadView(t.emblazonryType)	
				self:reloadView(-1)
			elseif t.optype == 4 then
				-- print(t.emblazonryType,"nnnnnnnnnnnnnnnnnnnnn")
				self.now_item[t.emblazonryType] = {}
				self:reloadView(t.emblazonryType)
				self:reloadView(-1)
				if self.medalBtn[t.emblazonryType] and self.medalBtn[t.emblazonryType]:getChildByTag(10) then
					self.medalBtn[t.emblazonryType]:getChildByTag(10):setVisible(true)
				end
			end

		end
		,
	}

 	if switch[msgid] then 
 		switch[msgid]()
 	end
end


return inlay