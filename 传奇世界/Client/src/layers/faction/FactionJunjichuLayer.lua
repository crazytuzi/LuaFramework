local FactionJunjichuLayer =class("FactionJunjichuLayer", function() return cc.Layer:create() end )

function FactionJunjichuLayer:ctor(factionData)
	local msgids = {FACTION_SC_GET_EVENT_RD_RET}
	require("src/MsgHandler").new(self,msgids)

	local infoBg =createScale9Frame(
		self,
		"res/common/scalable/panel_outer_base_1.png",
		"res/common/scalable/panel_outer_frame_scale9_1.png",
		cc.p(0, 0),
		cc.size(710, 501),
		4
	)
	self.data = {}
	g_msgHandlerInst:sendNetDataByTableExEx(FACTION_CS_GET_EVENT_RD, "FactionGetEventRd", {})
    addNetLoading(FACTION_CS_GET_EVENT_RD, FACTION_SC_GET_EVENT_RD_RET)

    -- self:createTableView(self, cc.size(715, 500), cc.p(0, 0), true, true)
    self:createScroll()
end
function FactionJunjichuLayer:createScroll()
	local scrollView = cc.ScrollView:create()
    if nil ~= scrollView then
        scrollView:setViewSize(cc.size(715, 500))
        -- scrollView:setPosition(cc.p(15, 15))
        --scrollView:setScale(1.0)
        --scrollView:ignoreAnchorPointForPosition(true)
        local node = cc.Node:create()
        self.node = node
        scrollView:setContainer(node)
        scrollView:setContentSize(cc.size(715, 500))

        scrollView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        scrollView:setClippingToBounds(true)
        scrollView:setBounceable(true)
        self:addChild(scrollView)
        self.scrollView = scrollView
    end
end

function FactionJunjichuLayer:updateScrollView()
	local getTimeStr = function(time) 
		local dates = os.date("*t",time)
		return string.format(game.getStrByKey("date_format"),dates.year,dates.month,dates.day,dates.hour,dates.min)
	end
	local cellHeight = 25
	local x = 0
	local y = 0
	local index = 0
	local padding = 2
	for i,v in ipairs(self.data) do
		local data = self.data[i]

		local timeStr = getTimeStr(data.time)
		local timeStr1 = createLabel(self.node,  timeStr .. ": ", cc.p(5, 0), cc.p(0,0), 22, true, nil, nil, MColor.yellow)
		timeStr1:setZOrder(1)
		local str = getConfigItemByKeys("clientmsg",{"sth","mid"},{7000,data.id})
		local richText = require("src/RichText").new(self.node, cc.p(5+timeStr1:getContentSize().width, 0), cc.size(700-timeStr1:getContentSize().width, cellHeight*2), cc.p(0, 0), cellHeight, 20, MColor.Lable_yellow)
    	-- richText:addText(data[3])
    	richText:addText(string.format(str.msg,data.params[1],data.params[2]))
    	richText:format()
    	richText:setZOrder(1)
    	local offy = 0
    	local curIndex = index
    	if richText:getContentSize().height > cellHeight then --有两行
    		offy = cellHeight
    		index = index + 2
    	else
    		index = index + 1
    	end

		richText:setPositionY(y)
		timeStr1:setPositionY(y + offy)
		
		if index%2 == 1 or (index - curIndex) >1 then
			local bg = createScale9Sprite(self.node,"res/faction/cellbg.png",cc.p(2,y-1),cc.size(702,cellHeight),cc.p(0,0))
	   		bg:setZOrder(0)
	   		if (index - curIndex) >1  then
	   			bg:setPositionY(y-1 + (curIndex%2) * cellHeight )
	   		end
		end

		y = y + richText:getContentSize().height
		y = y + padding
	end
	self.scrollView:setContentSize(cc.size(780, y))
	-- dump(y)
	--if y < 510 then
	self.scrollView:setContentOffset(cc.p(0, 500-y), false)
	--else
	--	self.scrollView:setContentOffset(cc.p(0, 0), false)
	--end
end

-- function FactionJunjichuLayer:updateFactionInfo()
-- 	self:updatUI()
-- end

-- function FactionJunjichuLayer:updateData()    
-- 	self:updatUI()
-- end
-- function FactionJunjichuLayer:reloadData()

-- end

-- function FactionJunjichuLayer:tableCellTouched(table,cell)

-- end

-- function FactionJunjichuLayer:cellSizeForTable(table,idx) 
--     return 30, 715
-- end

-- function FactionJunjichuLayer:tableCellAtIndex(table, idx)
-- 	local data = self.data[#self.data-idx]
-- 	if not data then 
-- 		return
-- 	end

--     local cell = table:dequeueCell()
--     local function createCell(cell)
--     	local dates = os.date("*t",data.time)
--         local dateStr = string.format(game.getStrByKey("date_format1"),dates.year,dates.month,dates.day,dates.hour,dates.min)
--     	local timeStr1 = createLabel(cell,  "[".. dateStr .. "]:", cc.p(5, 0), cc.p(0,0), 22, true, nil, nil, MColor.yellow)
--     	timeStr1:setZOrder(1)
--     	local str = getConfigItemByKeys("clientmsg",{"sth","mid"},{7000,data.id})
--     	local label = require("src/RichText").new(cell, cc.p(5+timeStr1:getContentSize().width, 0), cc.size(498, 20), cc.p(0, 0), 22, 22, MColor.white)
--     	label:addText(string.format(str.msg,data.params[1],data.params[2]))
-- 	   	label:format()
-- 	   	label:setZOrder(1)

-- 		if idx%2 == 1 then
-- 			local bg = createScale9Sprite(cell,"res/faction/cellbg.png",cc.p(350,12.5),cc.size(715,30))
-- 	   		bg:setZOrder(0)
-- 		end
--    end

--     if nil == cell then
--         cell = cc.TableViewCell:new()   
--         createCell(cell)
--     else
--     	cell:removeAllChildren()
--     	createCell(cell)
--     end

--     return cell
-- end

-- function FactionJunjichuLayer:numberOfCellsInTableView(table)
--    	return #self.data
-- end


function FactionJunjichuLayer:networkHander(buff, msgid)
	local switch = {
		[FACTION_SC_GET_EVENT_RD_RET] = function()    
			local t = g_msgHandlerInst:convertBufferToTable("FactionGetEventRdRet", buff)
            self.data = t.records
            -- self.factionData.shopLv = t.storeLv
			-- self.factionData.myMoney = t.contribution
            
			-- self:updateData()
			local seq = function(a,b)
    			return a.time < b.time
			end
			table.sort(self.data,seq)
			self:updateScrollView()	
		end,
	}

 	if switch[msgid] then 
 		switch[msgid]()
 	end
end

return FactionJunjichuLayer