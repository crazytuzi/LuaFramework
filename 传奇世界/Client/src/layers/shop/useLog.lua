local useLog = class("useLog",require("src/TabViewLayer"))



function useLog:ctor(num)
	local bg
	-- local tempPage = nil
	local title = {}

	local base_node = nil
	local res = "res/layers/shop/"
	print(num)
	self.num = num or {}
	self.data = {}
	self.data1 = {}
	self:readFile()
	title = {res.."goldLog1.png",res.."cashGift1.png"}
	if num == 1 then
		bg = createBgSprite(self,game.getStrByKey("shop_goldLog"))
	else
		bg = createBgSprite(self,game.getStrByKey("shop_bindGoldLog"))
	end

	local bg1 = createSprite(bg,"res/common/bg/bg.png",cc.p(480,285))
	-- self.scrollView = cc.ScrollView:create()
	-- self.scrollView:setViewSize(cc.size(930,520))
	-- self.scrollView:setAnchorPoint(cc.p(0,0))
	-- self.scrollView:setPosition(cc.p(10,25))
	-- self.scrollView:setScale(1.0)
	-- self.scrollView:ignoreAnchorPointForPosition(true)

	-- local layer = self:createLayout()
	-- layer:setContentSize(cc.size(930,610))
	-- self.scrollView:setContainer(layer)
	-- self.scrollView:updateInset()
	-- self.scrollView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
	-- --scrollView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)

	-- self.scrollView:setClippingToBounds(true)
	-- self.scrollView:setBounceable(true)
	-- self.scrollView:setDelegate()
 --  	bg:addChild(self.scrollView)
 --  	local layerSize = layer:getContentSize()
 --  	if layerSize.height > 520 then
 --  		self.scrollView:setContentOffset(cc.p(0,520 - layerSize.height))
 --  	end
 	dump(self.data,"11111111111111111111111111")
 	dump(self.data1,"11111111111111111111111111")
 	self:createTableView(bg1,cc.size(920,520) , cc.p(5,8),true)
end

function useLog:tableCellTouched(table,cell)
end

function useLog:cellSizeForTable(table,idx)
	return 30,900
end

function useLog:numberOfCellsInTableView( table )
	if self.num == 1 then
	 	return #self.data
	elseif self.num == 2 then
		return #self.data1
	end

end

function useLog:tableCellAtIndex(tableView,idx)
	print("444444444444444444444444")
	local cell = tableView:dequeueCell()
  	if cell == nil then
    	cell = cc.TableViewCell:new()
  	else
    	cell:removeAllChildren()
  	end
  	local idex = idx + 1
  	if self.num == 1 then
		if self.data then
			local getTimeStr = function(time)
				local dates = os.date("*t",time)
				return string.format(game.getStrByKey("date_format"),dates.year,dates.month,dates.day,dates.hour,dates.min)
			end
			createLabel(cell,getTimeStr(self.data[idex][2]),cc.p(30,15),cc.p(0,0.5),20,true,nil,nil,MColor.yellow)
			if tonumber(self.data[idex][4]) < 0 then
				local tempTime = numToFatString(math.abs(tonumber(self.data[idex][4])))
				createLabel(cell,game.getStrByKey("youConsume")..tempTime..game.getStrByKey("ingot"),cc.p(250,15),cc.p(0,0.5),20,true,nil,nil,MColor.white)
			elseif tonumber(self.data[idex][4]) > 0 then
				local tempTime = numToFatString(tonumber(self.data[idex][4]))
				createLabel(cell,game.getStrByKey("youGet")..tempTime..game.getStrByKey("ingot"),cc.p(250,15),cc.p(0,0.5),20,true,nil,nil,MColor.white)
			end
			local sentence = getConfigItemByKey("tradeLog","q_operationID",tonumber(self.data[idex][3]),"q_operation")
			createLabel(cell,"("..sentence..")",cc.p(440,15),cc.p(0,0.5),20,true,nil,nil,MColor.yellow_gray)
			if tonumber(self.data[idex][5]) ~= -1 then
				if tonumber(self.data[idex][5]) == 0 then
					createLabel(cell,game.getStrByKey("no_ingot"),cc.p(595,15),cc.p(0,0.5),20,true,nil,nil,MColor.white)
				elseif tonumber(self.data[idex][5]) > 0 then
					local tempTime1 = numToFatString(tonumber(self.data[idex][5]))
					createLabel(cell,game.getStrByKey("youHave")..tempTime1..game.getStrByKey("ingot"),cc.p(595,15),cc.p(0,0.5),20,true,nil,nil,MColor.white)
				end
			end
		end
	elseif self.num == 2 then
		if self.data1 then
			local getTimeStr = function(time)
				local dates = os.date("*t",time)
				return string.format(game.getStrByKey("date_format"),dates.year,dates.month,dates.day,dates.hour,dates.min)
			end
			createLabel(cell,getTimeStr(self.data1[idex][2]),cc.p(30,15),cc.p(0,0.5),20,true,nil,nil,MColor.yellow)
			if tonumber(self.data1[idex][4]) < 0 then
				local tempTime = numToFatString(math.abs(tonumber(self.data1[idex][4])))
				createLabel(cell,game.getStrByKey("youConsume")..tempTime..game.getStrByKey("bind_ingot"),cc.p(250,15),cc.p(0,0.5),20,true,nil,nil,MColor.white)
			elseif tonumber(self.data1[idex][4]) > 0 then
				local tempTime = numToFatString(tonumber(self.data1[idex][4]))
				createLabel(cell,game.getStrByKey("youGet")..tempTime..game.getStrByKey("bind_ingot"),cc.p(250,15),cc.p(0,0.5),20,true,nil,nil,MColor.white)
			end
			local sentence = getConfigItemByKey("tradeLog","q_operationID",tonumber(self.data1[idex][3]),"q_operation")
			createLabel(cell,"("..sentence..")",cc.p(440,15),cc.p(0,0.5),20,true,nil,nil,MColor.yellow_gray)
			if tonumber(self.data1[idex][5]) ~= -1 then
				if tonumber(self.data1[idex][5]) == 0 then
					createLabel(cell,game.getStrByKey("no_bindIngot"),cc.p(595,15),cc.p(0,0.5),20,true,nil,nil,MColor.white)
				elseif tonumber(self.data1[idex][5]) > 0 then
					local tempTime1 = numToFatString(tonumber(self.data1[idex][5]))
					createLabel(cell,game.getStrByKey("youHave")..tempTime1..game.getStrByKey("bind_ingot"),cc.p(595,15),cc.p(0,0.5),20,true,nil,nil,MColor.white)
				end
			end
		end
	end
  	return cell
end


-- function  useLog:createLayout()
-- 	if self.tempPage == nil then
-- 		self.tempPage = cc.Layer:create()
-- 	else
-- 		removeFromParent(self.tempPage)
-- 		self.tempPage = nil
-- 	end
-- 	return self.tempPage
-- end

-- function useLog:showLog()
-- 	if self.num == 1 then
-- 		if self.data then
-- 			local getTimeStr = function(time)
-- 				local dates = os.date("*t",time)
-- 				return string.format(game.getStrByKey("date_format"),dates.year,dates.month,dates.day,dates.hour,dates.min)
-- 			end
-- 			for i=1,#self.data do
-- 				createLabel(self.tempPage,getTimeStr(self.data[i][2]),cc.p(30,620-i*30),cc.p(0,0.5),20,true,nil,nil,MColor.yellow)
-- 				if tonumber(self.data[i][4]) < 0 then
-- 					local tempTime = numToFatString(math.abs(tonumber(self.data[i][4])))
-- 					createLabel(self.tempPage,game.getStrByKey("youConsume")..tempTime..game.getStrByKey("ingot"),cc.p(250,620-i*30),cc.p(0,0.5),20,true,nil,nil,MColor.white)
-- 				elseif tonumber(self.data[i][4]) > 0 then
-- 					local tempTime = numToFatString(tonumber(self.data[i][4]))
-- 					createLabel(self.tempPage,game.getStrByKey("youGet")..tempTime..game.getStrByKey("ingot"),cc.p(250,620-i*30),cc.p(0,0.5),20,true,nil,nil,MColor.white)
-- 				end
-- 				local sentence = getConfigItemByKey("tradeLog","q_operationID",tonumber(self.data[i][3]),"q_operation")
-- 				createLabel(self.tempPage,"("..sentence..")",cc.p(440,620-i*30),cc.p(0,0.5),20,true,nil,nil,MColor.yellow_gray)
-- 				if tonumber(self.data[i][5]) ~= -1 then
-- 					if tonumber(self.data[i][5]) == 0 then
-- 						createLabel(self.tempPage,game.getStrByKey("no_ingot"),cc.p(595,620-i*30),cc.p(0,0.5),20,true,nil,nil,MColor.white)
-- 					elseif tonumber(self.data[i][5]) > 0 then
-- 						local tempTime1 = numToFatString(tonumber(self.data[i][5]))
-- 						createLabel(self.tempPage,game.getStrByKey("youHave")..tempTime1..game.getStrByKey("ingot"),cc.p(595,620-i*30),cc.p(0,0.5),20,true,nil,nil,MColor.white)
-- 					end
-- 				end
-- 			end
-- 		end
-- 	elseif self.num == 2 then
-- 		if self.data1 then
-- 			local getTimeStr = function(time)
-- 				local dates = os.date("*t",time)
-- 				return string.format(game.getStrByKey("date_format"),dates.year,dates.month,dates.day,dates.hour,dates.min)
-- 			end
-- 			for i=1,#self.data1 do
-- 				createLabel(self.tempPage,getTimeStr(self.data1[i][2]),cc.p(30,620-i*30),cc.p(0,0.5),20,true,nil,nil,MColor.yellow)
-- 				if tonumber(self.data1[i][4]) < 0 then
-- 					local tempTime = numToFatString(math.abs(tonumber(self.data1[i][4])))
-- 					createLabel(self.tempPage,game.getStrByKey("youConsume")..tempTime..game.getStrByKey("bind_ingot"),cc.p(250,620-i*30),cc.p(0,0.5),20,true,nil,nil,MColor.white)
-- 				elseif tonumber(self.data1[i][4]) > 0 then
-- 					local tempTime = numToFatString(tonumber(self.data1[i][4]))
-- 					createLabel(self.tempPage,game.getStrByKey("youGet")..tempTime..game.getStrByKey("bind_ingot"),cc.p(250,620-i*30),cc.p(0,0.5),20,true,nil,nil,MColor.white)
-- 				end
-- 				local sentence = getConfigItemByKey("tradeLog","q_operationID",tonumber(self.data1[i][3]),"q_operation")
-- 				createLabel(self.tempPage,"("..sentence..")",cc.p(440,620-i*30),cc.p(0,0.5),20,true,nil,nil,MColor.yellow_gray)
-- 				if tonumber(self.data1[i][5]) ~= -1 then
-- 					if tonumber(self.data1[i][5]) == 0 then
-- 						createLabel(self.tempPage,game.getStrByKey("no_bindIngot"),cc.p(595,620-i*30),cc.p(0,0.5),20,true,nil,nil,MColor.white)
-- 					elseif tonumber(self.data1[i][5]) > 0 then
-- 						local tempTime1 = numToFatString(tonumber(self.data1[i][5]))
-- 						createLabel(self.tempPage,game.getStrByKey("youHave")..tempTime1..game.getStrByKey("bind_ingot"),cc.p(595,620-i*30),cc.p(0,0.5),20,true,nil,nil,MColor.white)
-- 					end
-- 				end
-- 			end
-- 		end
-- 	end
-- end

function useLog:readFile()
	self.temp = 0
	local useKeep = {}
	local setfile = getDownloadDir().."consume"..tostring(userInfo.currRoleStaticId)..".cfg"
	local file = io.open(setfile,"r")
	if file then
		local line = file:read()
		while line do
			self.temp = self.temp + 1
			table.insert(useKeep,line)
			line = file:read()
		end
		local useTable = {}
		for i=#useKeep,1,-1 do
			useTable = stringsplit(useKeep[i],",")
			if tonumber(useTable[1]) == 1 then
				table.insert(self.data,useTable)
			elseif tonumber(useTable[1]) == 2 then
				table.insert(self.data1,useTable)
			end
		end
		file:close()
	end
	-- self:getTableView():reloadData()
	
end

return useLog