local CharmRankingLayer = class("CharmRankingLayer", require("src/TabViewLayer"))

local path = "res/ranking/"
local leftCenter = 160
require("src/layers/ranking/RankingDefine")

function CharmRankingLayer:ctor()
	self:initData()
	self.totleNum = 150
	self.WeekTopNum = 0
	self.topData = {}
	--local bg = createSprite(self , "res/common/bg/bg-6.png" , cc.p( 15, 25) , cc.p( 0 , 0 )) 
    local bg = cc.Node:create()
    bg:setPosition(cc.p(15, 25))
    bg:setContentSize(cc.size(930, 535))
    bg:setAnchorPoint(cc.p(0, 0))
    self:addChild(bg)

	self.bg = bg
	local leftNode = createSprite( bg , "res/common/bg/bg45.png" , cc.p( 17 , 17 ) , cc.p( 0 , 0 )) 
	--local rightNode = createSprite( bg ,"res/common/bg/bg47.png" , cc.p( 342 , 17 ) ,  cc.p( 0 , 0 ) ) 
	local rightNode = createScale9Sprite(bg, "res/common/scalable/panel_inside_scale9.png", cc.p(342, 16), cc.size(570, 501), cc.p(0, 0) )
	self.leftNode = leftNode
	self.rightNode = rightNode

	self.mayRanktip = createLabel(leftNode, game.getStrByKey("my_rank") .. "0", cc.p(leftNode:getContentSize().width/2, 58), cc.p(0.5, 0.5), 20, nil, nil, nil, MColor.lable_yellow)

	createSprite(rightNode, path .. "top.png", cc.p(65, 460))
	self.tempTopLab = createLabel(rightNode, game.getStrByKey("charm_NoTop"), cc.p(rightNode:getContentSize().width/2, 460), nil, 20)
	self.tempTopLab:setColor(MColor.lable_yellow)

	self.dataShowTitle = {"rank_title1", "name", "school", "rank_title4"}
	self.dataShowPos = {47 + 14, 200, 360, 500}

	self.title = {}
	local topBg = CreateListTitle(rightNode, cc.p(6, 497 - 70), 564, 43, cc.p(0, 1))
	for i,v in ipairs(self.dataShowTitle) do
		self.title[i] = createLabel(topBg, game.getStrByKey(self.dataShowTitle[i]), cc.p(self.dataShowPos[i], 20), cc.p(0.5, 0.5), 20)
		self.title[i]:setColor(MColor.lable_yellow)
	end

	self:createTableView(rightNode ,cc.size(580 - 15, 390- 13 - 70 + 7), cc.p(6, 90 - 13 - 9), true,true)

	createSprite(rightNode, "res/common/bg/bg51-1.png", cc.p(rightNode:getContentSize().width/2, 60), cc.p(0.5, 0.5))
	local lab = createLabel(rightNode, game.getStrByKey("charm_Tips2"), cc.p(rightNode:getContentSize().width/2, 33), cc.p(0.5, 0.5), 18)
	lab:setColor(MColor.lable_black)
	__createHelp(
    {
        parent = rightNode,
        str = require("src/config/PromptOp"):content(22),
        pos = cc.p(533, 30),
    })
	self:initLeftView()
end

function CharmRankingLayer:initData()
	self.rankType = 9 -- RANK_CHARM --RANK_LEVEL
	self.data = {}
	self.dataShow = {}
	self.selfRankData = {}

	local msgids = {RANK_SC_RET, RELATION_SC_GETRELATIONDATA_RET, RELATION_SC_TOTALFLOWER_RET}
	require("src/MsgHandler").new(self, msgids)
	local t = {}
	t.tab = self.rankType
	t.page = 1
	g_msgHandlerInst:sendNetDataByTableExEx(RANK_CS_REQ, "RankReq", t)
	addNetLoading(RANK_CS_REQ, RANK_SC_RET)

	--g_msgHandlerInst:sendNetDataByFmtExEx(RELATION_CS_GETRELATIONDATA,"ic",G_ROLE_MAIN.obj_id, 1)
	g_msgHandlerInst:sendNetDataByTableExEx(RELATION_CS_GETRELATIONDATA, "GetRelationDataProtocol", {relationKind = 1})
	addNetLoading(RELATION_CS_GETRELATIONDATA, RELATION_SC_GETRELATIONDATA_RET)
	g_msgHandlerInst:sendNetDataByTableExEx(RELATION_CS_TOTALFLOWER,"GetTotalFlowerProtocol",{})
	addNetLoading(RELATION_CS_TOTALFLOWER, RELATION_SC_TOTALFLOWER_RET)		
end

function CharmRankingLayer:initLeftView()
	local lab = createLabel(self.leftNode, G_ROLE_MAIN:getTheName(), cc.p(leftCenter, 470), cc.p(0.5, 0.5), 24)
	lab:setColor(MColor.yellow)
	self.recvNum = createLabel(self.leftNode, game.getStrByKey("charm_recv") .. "0", cc.p(leftCenter, 30), cc.p(0.5, 0.5), 20, true)
	self.recvNum:setColor(MColor.red)
	local temp = {}
	temp.school = MRoleStruct:getAttr(ROLE_SCHOOL)
	temp.clothes = MRoleStruct:getAttr(PLAYER_EQUIP_UPPERBODY)
	temp.weaponId = MRoleStruct:getAttr(PLAYER_EQUIP_WEAPON)
	temp.wing = MRoleStruct:getAttr(PLAYER_EQUIP_WING)
	temp.sex = MRoleStruct:getAttr(PLAYER_SEX)


	local roleNode = createRoleNode(temp.school, temp.clothes, temp.weaponId, temp.wing, 1.0, temp.sex)
	if roleNode then
		self.bg:addChild(roleNode,5,100)
		roleNode:setPosition(cc.p(leftCenter + 16, 260))	
	end
end

function CharmRankingLayer:updateFlowNum(nums)
	if not nums then nums = 0 end
	self.dataShow[self.selectIndex][4] = self.dataShow[self.selectIndex][4] + nums

	local cell = self:getTableView():cellAtIndex(self.selectIndex - 1)
	if cell and cell.flowNum then
		cell.flowNum:setString(self.dataShow[self.selectIndex][4])
	end
end

function CharmRankingLayer:setSelfRank(rank )
	if rank ~= 0 then
		self.mayRanktip:setString(game.getStrByKey("my_rank").." "..rank)
	else
		self.mayRanktip:setString(game.getStrByKey("my_rank").." "..game.getStrByKey("ranking_no_rank"))
	end
end

function CharmRankingLayer:reloadData()
	self.dataShow = self.data
	self:getTableView():reloadData()
	if #self.dataShow > 0 then
		--默认选中
	-- 	local index = self.WeekTopNum + 1
	-- 	if self:getServerNameByIndex(index) == MRoleStruct:getAttr(ROLE_NAME) and #self.dataShow > index then
	-- 		index = index + 1
	-- 	end
		
	-- 	local cell = self:getTableView():cellAtIndex(index - 1)
	-- 	if cell then
	-- 		self:selectTableCell(cell)
	-- 	end
	else
		MessageBox(game.getStrByKey("charm_Tips"), nil, function()
			removeFromParent(self:getParent())
		end)
	end
end

function CharmRankingLayer:tableCellTouched(table, cell)
	AudioEnginer.playTouchPointEffect()
	self:selectTableCell(cell, true)
end

function CharmRankingLayer:getServerNameByIndex( index )
	if index <= #self.dataShow then
		return self.dataShow[index][2]
	end
	return ""
end

function CharmRankingLayer:selectTableCell(cell, popBox)
	--if self.selectIndex and cell:getIdx() + 1 == self.selectIndex then return end

	--取消原选中项的选中效果
	if self.selectIndex then
		local cell = self:getTableView():cellAtIndex(self.selectIndex - 1)
		if cell then
			cell.changeStatus(true)
		end
	end
	cell.changeStatus(false)
	self.selectIndex = cell:getIdx() + 1
	
	if popBox then
		local offset = self:getTableView():getContentOffset()
		local cellHight, cellWidth = self:cellSizeForTable()
		local hight = (self:numberOfCellsInTableView() - cell:getIdx()) * cellHight - (-offset.y)
		hight = hight + self.rightNode:getPositionY() + self:getTableView():getPositionY()
		if hight < 172 then
			hight = 172
		end
		hight = hight + 100
		local box = createSprite(self.bg, "res/common/scalable/5.png", cc.p(755, hight), cc.p(0, 1))
		local  listenner = cc.EventListenerTouchOneByOne:create()
		local flag = false
		listenner:setSwallowTouches(true)
	    listenner:registerScriptHandler(function(touch, event) 
									    	local pt = box:getParent():convertTouchToNodeSpace(touch)
											if cc.rectContainsPoint(box:getBoundingBox(), pt) == false then
													flag = true
											end
	    									return true 
	    								end, cc.Handler.EVENT_TOUCH_BEGAN)
	    listenner:registerScriptHandler(function(touch, event)
	    	local start_pos = touch:getStartLocation()
			local now_pos = touch:getLocation()
			local span_pos = cc.p(now_pos.x-start_pos.x,now_pos.y-start_pos.y)
			local pt = box:getParent():convertTouchToNodeSpace(touch)
			if flag and (cc.rectContainsPoint(box:getBoundingBox(), pt) == false) then
				if box then removeFromParent(box) box = nil end
				AudioEnginer.playTouchPointEffect()
			end
		end, cc.Handler.EVENT_TOUCH_ENDED)
	    local eventDispatcher = box:getEventDispatcher()
	    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, box)

		local name = self:getServerNameByIndex(self.selectIndex)
		local func = function(tag)
			local switch = {
				[1] = function() 
				  	local layer = require("src/layers/friend/SendFlowerLayer").new({[1]=0, [2]=name}, function(nums) self:updateFlowNum(nums) end)
					Manimation:transit(
					{
						ref = G_MAINSCENE.base_node,
						node = layer,
						sp = g_scrCenter,
						ep = g_scrCenter,
						zOrder = 200,
						curve = "-",
						swallow = true,
					})
				end,
				[2] = function() 
					AddFriends(name)
				end,
				[3] = function() 
				  	AddBlackList(name)
				end,
				[4] = function() 
				  	LookupInfo(name)
				end,
			}
			if switch[tag] then
				if name == MRoleStruct:getAttr(ROLE_NAME) then
					local strList = {"charm_sendFlowerToSelf", "charm_addFriendToSelf", "charm_addBlackToSelf", "charm_CheckSelf" }
					TIPS({str = game.getStrByKey(strList[tag]), type = 1})
					return
				end			 	
				switch[tag]() 
			end
			if box then removeFromParent(box) box = nil end
		end

		local menus = {  {text = game.getStrByKey("send_flower_text"), tag = 1},
						 {text = game.getStrByKey("addas_friend"), tag = 2},
						 {text = game.getStrByKey("add_blackList"), tag = 3},
						 {text = game.getStrByKey("look_up"), tag = 4},
						  }

		if G_CONTROL:isFuncOn( GAME_SWITCH_ID_FLOWER ) == false then
			table.remove(menus, 1)
		end

		for i=1, #menus do
			local item = createMenuItem(box, "res/component/button/49.png", cc.p(79, 187 - (i-1) * 50), function() func(menus[i].tag) end)
			createLabel(item, menus[i].text, getCenterPos(item), nil, 20, true):setColor(MColor.lable_yellow)
		end
	end

end

function CharmRankingLayer:cellSizeForTable(table, idx) 
    return 70, 580
end

function CharmRankingLayer:tableCellAtIndex(table, idx)
	local createVip = function(node, vip)
		if vip and vip>0 and vip<=10 then
			local vipBg = createSprite(node, "res/layers/vip/vipTitle/bg.png", cc.p(0, node:getContentSize().height/2), cc.p(1, 0.5), nil, 1)
	        createSprite(vipBg, "res/layers/vip/vipTitle/v.png", cc.p(vipBg:getContentSize().width/2, vipBg:getContentSize().height/2), cc.p(1, 0.5), nil, 1)
	        createSprite(vipBg, "res/layers/vip/vipTitle/"..vip..".png", cc.p(vipBg:getContentSize().width/2, vipBg:getContentSize().height/2), cc.p(0.3, 0.5), nil, 1)
	    end    
	end

	--排行榜分页拉取
	local nowNum = #self.dataShow
	if idx + 1 == nowNum and nowNum < self.totleNum  then
		g_msgHandlerInst:sendNetDataByTableExEx(RANK_CS_REQ, "RankReq", {tab = self.rankType, page = math.floor(nowNum/20) + 1})
	end	

	local cell = table:dequeueCell()
	if nil == cell then
		cell = cc.TableViewCell:new() 
	else
    	cell:removeAllChildren()
    end

	local bg = createSprite(cell, "res/common/table/cell8.png", cc.p(0, 2), cc.p(0, 0)) 
	local bg2 = createSprite(cell, "res/common/table/cell8_1.png", cc.p(0, 2), cc.p(0, 0))
	local flg = (not self.selectIndex or self.selectIndex ~= idx + 1) and true or false
	cell.changeStatus = function(flg)
		bg:setVisible(flg)
		bg2:setVisible(not flg)
	end
	cell.changeStatus(flg)
	
	local tableInfoNode = cc.Node:create()
	cell:addChild(tableInfoNode)

	local record = self.dataShow[idx + 1]
	if record then
		for i,v in ipairs(record) do
			if i == 1 then
				if idx + 1 <=  3 then
					createSprite(tableInfoNode, path .. "no_" .. (idx + 1) .. ".png", cc.p(self.dataShowPos[i], 35))
				else
					local label = createLabel(tableInfoNode, v, cc.p(self.dataShowPos[i], 42), cc.p(0.5, 0.5), 20)
					label:setColor( MColor.lable_black)
				end
			elseif i == 2 then
				local label = createLabel(tableInfoNode, v, cc.p(self.dataShowPos[i], 42), cc.p(0.5, 0.5), 20)
				label:setColor( MColor.lable_black)
				--createVip(label, record[0])
			elseif i > 1 and i <= 4 then
				local label = createLabel(tableInfoNode, v, cc.p(self.dataShowPos[i], 42), cc.p(0.5, 0.5), 20)
				label:setColor( MColor.lable_black)
				if i == 4 then
					cell.flowNum = label
				end				
			end
		end
	end

    return cell
end

function CharmRankingLayer:numberOfCellsInTableView(table)
   	return #self.dataShow
end

function CharmRankingLayer:showTopInfo()

	if #self.topData ~= 0 and self.topData[1] then
		local record = self.topData[1]
		if record and record[2] and record[2] ~= "" then
			if self.tempTopLab then
				self.tempTopLab:setVisible(false)
			end
			if self.topTitleLab then
				removeFromParent(self.topTitleLab)
				self.topTitleLab = nil
			end

			if self.topNameLab then
				removeFromParent(self.topNameLab)
				self.topNameLab = nil
			end

			local lab = createLabel(self.rightNode, game.getStrByKey("charm_FirstWeekTop") .. ":", cc.p(175, 460), cc.p(0, 0.5), 22)
			lab:setColor(MColor.lable_yellow)
			--local lab2 = createLabel(self.rightNode, record[2], cc.p(lab:getContentSize().width + 175, 460), cc.p(0,0.5), 22):setColor(MColor.yellow)

	        local lab2 = createLinkLabel(self.rightNode, record[2], cc.p(lab:getContentSize().width + 175, 460),  cc.p(0,0.5), 22, true, nil, MColor.yellow, nil, function() 
	            LookupInfo(record[2])
	        end, true)

			self.topTitleLab = lab
			self.topNameLab = lab2
		end
	end
end

function CharmRankingLayer:networkHander(buff,msgid)
	local switch = {
	[RANK_SC_RET] = function()    
		log("get RANK_SC_RET"..msgid)
		local retTable = g_msgHandlerInst:convertBufferToTable("RankReqRet", buff)

		self.rankType = retTable.tab
		self.totleNum = retTable.size
		dump(self.totleNum)
		self.selfRank = retTable.selfRank
		if #self.data == 0 then
			self.topData = {}
			
			local tempData = retTable.glamour
			if tempData then
				local record = {}
				record[1] = game.getStrByKey("charm_week_top")
				record[2] = tempData.name    --名称
				record[3] = getSchoolByName(tempData.school) --职业
				record[4] = tempData.value   --魅力值
				record[6] = tempData.roleSID --玩家ID

				table.insert(self.topData, record)
			end
		end

		local tempData = retTable.rankData
		--dump(tempData)
		local count = tempData and tablenums(tempData) or 0
		log("count .." .. count)
		for i=1, count do
			local record = {}
			record[1] = tempData[i].rank
			record[2] = tempData[i].name
			record[3] = getSchoolByName(tempData[i].school)
			record[4] = tempData[i].value
			record[6] = tempData[i].roleSID --玩家ID
			table.insert(self.data, record)
		end

		local offset =  self:getTableView():getContentOffset()
		self:reloadData()
		self:setSelfRank(self.selfRank)
		if #self.data > count then
            self:getTableView():setContentOffset(cc.p(offset.x, offset.y - 82 * count)) 
        end

        self:showTopInfo()
	end,
	[RELATION_SC_GETRELATIONDATA_RET] = function() 
		-- --log("get RELATION_SC_GETRELATIONDATA_RET"..msgid)
		-- local type_data = buff:readByFmt("c") 
		-- -- currect_layer.load_data = {}
		-- local left_time,gold_time,friend_num = buff:readByFmt("cic") 
		-- --print ("FriendsLayer:networkHander left_time,gold_time",left_time,gold_time)
		-- require("src/layers/friend/SendFlowerLayer").left_time = left_time
		-- require("src/layers/friend/SendFlowerLayer").goldTime  = gold_time
	end,
	[RELATION_SC_TOTALFLOWER_RET] = function()
		local retTable = g_msgHandlerInst:convertBufferToTable("TotalFlowerRetProtocol", buff)
		local num = retTable.totalFlower
		dump(num)
		self.recvNum:setString(game.getStrByKey("charm_recv") .. num)
	end,
	}

	if switch[msgid] then
		switch[msgid]()
	end
end

return CharmRankingLayer