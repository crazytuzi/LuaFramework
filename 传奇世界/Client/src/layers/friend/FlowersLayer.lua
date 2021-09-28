local FlowersLayer = class("FlowersLayer", require ("src/TabViewLayer") )
FlowersLayer.reload = nil

function FlowersLayer:ctor(parent)
	self:reloadData()
	local msgids = {RELATION_SC_FLOWERRECORD_RET}
	require("src/MsgHandler").new(self,msgids)
	--local tipSp = --popupBox({isNoSwallow = true,createScale9Sprite = { size = cc.size( 706 , 445 ) } , close = { scale = 0.7 , offX = 28,offY = 15 , callback = function() end } ,  bg = "res/common/5.png" ,  actionType = 5 ,  zorder = 200 } )
    local bg = createSprite(self, "res/common/bg/bg18.png", cc.p(display.cx, display.cy), cc.p(0.5, 0.5))
	createLabel(bg, game.getStrByKey("flowers_record"), cc.p(bg:getContentSize().width/2, bg:getContentSize().height-30), cc.p(0.5, 0.5), 24, true)
	local tipSp = createScale9Frame(
        bg,
        "res/common/scalable/panel_outer_base_1.png",
        "res/common/scalable/panel_outer_frame_scale9_1.png",
        cc.p(32, 15),
        cc.size(792,455),
        5
    )
	--createSprite(bg, "res/common/bg/bg18-2.png", cc.p(bg:getContentSize().width/2, 15), cc.p(0.5, 0))
	local closeFunc = function() 
	   	bg:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 0), cc.CallFunc:create(function() removeFromParent(self) end)))	
	end
	local closeBtn = createTouchItem(bg, "res/component/button/x2.png", cc.p(bg:getContentSize().width-48, bg:getContentSize().height-28), closeFunc)

    self.tipSp = tipSp
    local bgsize = tipSp:getContentSize()
    registerOutsideCloseFunc( bg , function() closeFunc() end,true)
    --createLabel(tipSp, game.getStrByKey("flowers_record"),cc.p(  bgsize.width/2+5 , bgsize.height - 12 ) , cc.p( 0.5 , 1 ), 22, true)
    self.select_cell_index = 0
	self.load_data = {}
	self:createTableView(self.tipSp,cc.size(785, 450), cc.p(3, 1), true)
	if parent then 
		parent:addChild(self,125)
	end
end

function FlowersLayer:reloadData()
	--g_msgHandlerInst:sendNetDataByFmtExEx(RELATION_CS_FLOWERRECORD,"i",G_ROLE_MAIN.obj_id)
	g_msgHandlerInst:sendNetDataByTableExEx(RELATION_CS_FLOWERRECORD, "GetFlowerRecordProtocol", {})
	FlowersLayer.reload = nil
end

function FlowersLayer:tableCellTouched(table,cell)

end

function FlowersLayer:cellSizeForTable(table,idx) 
    return 50,775
end

function FlowersLayer:tableCellAtIndex(table, idx)
	local data = self.load_data[idx+1]
	if not data then 
		return
	end
	local getTimeStr = function(time) 
		local dates = os.date("*t",time)
		return string.format(game.getStrByKey("date_format"),dates.year,dates.month,dates.day,dates.hour,dates.min)
	end
     local cell = table:dequeueCell()
    local flowers = {getConfigItemByKey("FlowerCfg", "q_style", 1, "q_giveflowerNum"), 
	getConfigItemByKey("FlowerCfg", "q_style", 2, "q_giveflowerNum"), 
	getConfigItemByKey("FlowerCfg", "q_style", 3, "q_giveflowerNum"), 
	getConfigItemByKey("FlowerCfg", "q_style", 4, "q_giveflowerNum")} 
    -- if data[4] < 1 or data[4] > 3 then
    -- 	data[4] = 1
    -- end
	if cell then 
		removeFromParent(cell)
	end
    cell = cc.TableViewCell:new()   
    cclog("~~~"..tostring(data[4]))
    local name1 = data[2]
    local name2 = data[3]
    dump(require("src/layers/role/RoleStruct"):getAttr(ROLE_NAME))
    dump(name1)
    dump(name2)
    if name1 == require("src/layers/role/RoleStruct"):getAttr(ROLE_NAME) then
    	name1 = game.getStrByKey("you")
    else
    	name1 = game.getStrByKey("player").."^c(yellow_gray)"..data[2].."^"
    end
    if name2 == require("src/layers/role/RoleStruct"):getAttr(ROLE_NAME) then
    	name2 = game.getStrByKey("you")
    else
    	name2 = game.getStrByKey("player").."^c(yellow_gray)"..data[3].."^"
    end
    local rich_str = "^c(yellow_gray)" .. getTimeStr(data[1]) .."^".. string.format(game.getStrByKey("flowers_msg"),name1,name2,flowers[data[4]])
    if data[4] == 1 then
    	rich_str = "^c(yellow_gray)" .. getTimeStr(data[1]) .."^".. string.format(game.getStrByKey("flowers_ex_msg"),name1,name2,data[5])
    end
    local l_item = createRichText(cell, cc.p(5, 30), cc.size(775, 30), cc.p(0, 0.5), false, 10)
    addRichTextItem(l_item,rich_str,MColor.white,nil,20,255)
    return cell
end

function FlowersLayer:numberOfCellsInTableView(table)
   	return #self.load_data
end

function FlowersLayer:networkHander(buff,msgid)
	local switch = {
		[RELATION_SC_FLOWERRECORD_RET] = function()    
			log("get FACTION_SC_GETMSGRECORD_RET"..msgid)
			local t = g_msgHandlerInst:convertBufferToTable("GetFlowerRecordRetProtocol", buff)
			self.load_data = {} 
			local num =  t.recordCount
			for i,v in ipairs(t.recordInfo) do
				self.load_data[i] = {}
				self.load_data[i][1] = v.timeTick
				self.load_data[i][2] = v.sendName
				self.load_data[i][3] = v.receiveName
				self.load_data[i][4] = v.giveType
				self.load_data[i][5] = v.giveNum
			end	
			dump(self.load_data)
			self:getTableView():reloadData()			
		end,
	}

 	if switch[msgid] then 
 		switch[msgid]()
 	end
end 
return FlowersLayer