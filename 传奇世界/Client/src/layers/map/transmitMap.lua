local transmitMap = class("transmitMap",require("src/TabViewLayer"))

function transmitMap:ctor(parent,num,transmits)
	local MRoleStruct = require("src/layers/role/RoleStruct")
	self.playerLv = MRoleStruct:getAttr(ROLE_LEVEL)
	local layer = cc.Layer:create()
	layer:setContentSize(cc.size(730, 516))
	layer:setPosition(cc.p(206, 28))
	self:addChild(layer)
	self.idxTemp = num
	self.load_data = transmits
	local sdata = require("src/layers/spiritring/ringdata")
	local sd = sdata:getServerData()
	self.transmitLevel = 0
	for k,v in pairs(sd) do
		if type(v) == "table" and 1 == v.id then
			self.transmitLevel = v.lvl
			break
		end
	end
	self.parent = parent
	self:createTableView(layer,cc.size(730, 510) , cc.p(0,6),true)
end

function transmitMap:tableCellTouched(table,cell)
	local idx = cell:getIdx()+1
	--print("x = "..cell:getX()..", y = "..cell:getY())
	local touchX, touchY = cell:getX(), cell:getY()
	for i = 1,#self.load_data do
		if cell:getChildByTag(i) then
			local data = self.load_data[i]
			local oldpath = cell:getChildByTag(i)
			if cc.rectContainsPoint(oldpath:getBoundingBox(), cc.p(touchX, touchY)) and self:isVisible() then
				if self.playerLv < self.load_data[i].q_map_min_level then
					TIPS( { type = 1 , str = game.getStrByKey("onlineMine_level_loss") } )
					return
				else
					AudioEnginer.playTouchPointEffect()
					if self.parent and self.parent.tp and self.parent.tp[data.q_map_id] and self.parent.tp[data.q_map_id].x then
						local x,y = self.parent.tp[data.q_map_id].x,self.parent.tp[data.q_map_id].y
						require("src/layers/spiritring/TransmitNode").new(data.q_map_id,x,y)
					end
				end
				break
			end
		end
	end
end

function transmitMap:cellSizeForTable(table,idx)
	return 170,730
end

function transmitMap:tableCellAtIndex(tableView,idx)
	local cell = tableView:dequeueCell()
	if cell == nil then
		cell = cc.TableViewCell:new()
	else
		cell:removeAllChildren()
	end
	local posX,posY = 187,85
	posY = posY - 1*idx
	for i=1+idx*2,(1+idx)*2 do
		if self.load_data[i] then
			local mapBtn = createSprite(cell,"res/mapui/mapName/"..self.load_data[i].q_map_id..".jpg",cc.p(posX,posY))
			if mapBtn then
				mapBtn:setTag(i)
				createSprite(mapBtn,"res/mapui/mapName/"..self.load_data[i].q_map_id..".png",cc.p(10,mapBtn:getContentSize().height-30),cc.p(0,0.5))
				if self.playerLv and self.load_data[i].q_map_min_level and self.playerLv < self.load_data[i].q_map_min_level then
					createSprite(mapBtn,"res/mapui/mapName/close.png",cc.p(mapBtn:getContentSize().width/2,mapBtn:getContentSize().height/2))
					createLabel(mapBtn,string.format(game.getStrByKey("delivery_lanuage"),self.load_data[i].q_map_min_level),cc.p(mapBtn:getContentSize().width/2,15),nil,22,nil,nil,nil,MColor.red)
				else
					createSprite(mapBtn,"res/mapui/mapName/open.png",cc.p(mapBtn:getContentSize().width/2,mapBtn:getContentSize().height/2))
					local lab = createLabel(mapBtn,game.getStrByKey("vip_opened"),cc.p(mapBtn:getContentSize().width/2,15),nil,22,nil,nil,nil,MColor.yellow)
				end
				posX = posX + 362
			end
		end
	end
	return cell
end

function transmitMap:numberOfCellsInTableView(table)
	if #self.load_data % 2 == 0 then
		return #self.load_data/2
	else
		return #self.load_data/2+1
	end
end


return transmitMap