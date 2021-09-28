local shaWarLogLayer = class("shaWarLogLayer", require("src/TabViewLayer"))

function shaWarLogLayer:ctor()
	self.data = {}
	local msgids = {SHAWAR_SC_GETRECORD_RET}
	require("src/MsgHandler").new(self, msgids)

	local ruleBg = createSprite(self,"res/common/bg/bg18.png",cc.p(0, 0))
    local root_size = ruleBg:getContentSize()
	createScale9Frame(
        ruleBg,
        "res/common/scalable/panel_outer_base_1.png",
        "res/common/scalable/panel_outer_frame_scale9_1.png",
        cc.p(32, 15),
        cc.size(792,455),
        5
    )    
    local title = createLabel(ruleBg, game.getStrByKey("shaWar_title3"),cc.p(root_size.width/2,root_size.height-30), nil, 24, true)
    local closeFunc = function() 
		ruleBg:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1, 0), cc.CallFunc:create(function() removeFromParent(self) end)))  
    end
    local closeBtn = createTouchItem(ruleBg, "res/component/button/x2.png",cc.p(root_size.width - 40 ,root_size.height - 25),closeFunc)
    registerOutsideCloseFunc(ruleBg, function() removeFromParent(self) end, true)

	self:createTableView(ruleBg, cc.size(750, 436 ), cc.p(20, 24), true)
	
	-- self.data[1] = {tp = 1, time = os.time(), facName1 = "天下第一"}
	-- self.data[2] = {tp = 2, time = os.time(), facName1 = "天下第一"}
	-- self.data[3] = {tp = 2, time = os.time(), facName1 = "天下第一"}
	-- self.data[4] = {tp = 1, time = os.time(), facName1 = "天下第一"}
	-- self.data[5] = {tp = 3, time = os.time(), facName1 = "天下第一", facName2 = "你来打我呀"}
	-- self.data[#self.data + 1] = self.data[5]
	-- self.data[#self.data + 1] = self.data[5]
	-- self.data[#self.data + 1] = self.data[5]
	-- self.data[#self.data + 1] = self.data[5]
	-- self.data[#self.data + 1] = self.data[5]
	-- self.data[#self.data + 1] = self.data[5]
	-- self.data[#self.data + 1] = self.data[5]
	-- self.data[#self.data + 1] = self.data[5]
	-- self.data[#self.data + 1] = self.data[5]
	-- self.data[#self.data + 1] = self.data[5]
	-- self.data[#self.data + 1] = self.data[5]
	self:getTableView():reloadData()	

	g_msgHandlerInst:sendNetDataByTableExEx(SHAWAR_CS_GETRECORD, "ShaGetRecordProtocol", {})
end

function shaWarLogLayer:cellSizeForTable(table, idx) 
    return 35, 750
end

function shaWarLogLayer:tableCellAtIndex(table, idx)
	local cell = table:dequeueCell()
	if nil == cell then
		cell = cc.TableViewCell:new() 
	else
    	cell:removeAllChildren()
    end

    local curData = self.data[idx + 1]
    local timeStr  = os.date("%Y-%m-%d %H:%M", curData.time)
    local rich_str = ""
    if curData.tp == 2 then
    	rich_str = string.format(game.getStrByKey("shaWar_logType2"), timeStr, curData.facName1)
    elseif curData.tp == 3 then
    	rich_str = string.format(game.getStrByKey("shaWar_logType3"), timeStr, curData.facName1, curData.facName2)
    else
    	rich_str = string.format(game.getStrByKey("shaWar_logType1"), timeStr, curData.facName1)
    end
    
    local l_item = createRichText(cell, cc.p(18, 20), cc.size(775, 30), cc.p(0, 0.5), false, 10)
    addRichTextItem(l_item, rich_str, MColor.lable_black, nil, 20, 720)	

    return cell
end

function shaWarLogLayer:numberOfCellsInTableView(table)
   	return #self.data
end

function shaWarLogLayer:networkHander(buff,msgid)
	local switch = {
		[SHAWAR_SC_GETRECORD_RET] = function()
			self.data = {}
			local retTab = g_msgHandlerInst:convertBufferToTable("ShaGetRecordRetProtocol", buff)			
			local tempInfo = retTab.info
			
			local num = tempInfo and tablenums(tempInfo) or 0
			for i=1,num do
				local tp = tempInfo[i].rdStyle
				local time = tempInfo[i].time
				local facName1 = tempInfo[i].factionName1
				local facName2 = tempInfo[i].factionName2
				self.data[i] = {tp = tp, time = time, facName1 = facName1, facName2 = facName2}
			end
			table.sort( self.data, function (a,b) return a.time > b.time end )
			--dump(self.data)
			self:getTableView():reloadData()
		end,
	}

 	if switch[msgid] then 
 		switch[msgid]()
 	end
end

return shaWarLogLayer