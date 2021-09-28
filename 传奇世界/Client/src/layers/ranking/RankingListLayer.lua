local RankingListLayer = class("RankingListLayer", require("src/TabViewLayer"))

local path = "res/ranking/"

require("src/layers/ranking/RankingDefine")

function RankingListLayer:ctor(callBack)
	self.data = {} --缓存排行数据
	self.selfRankData = {} --缓存自己的排行
	self.rankAllNum = {}
	self.dataShow = {}
	self.callBack = callBack
	self.totleNum = 100

	local msgids = {RANK_SC_RET,RANK_SC_BHRT}
	require("src/MsgHandler").new(self, msgids)

	self.dataShowTitle = {{"rank_title1"}, {"name"}, {"school", "level"},{"level","combat_power","faction_top_faction_fight","rank_title3","rank_title2","rank_title2","rank_title2","rank_title2"}}
	self.dataShowPos = {100, 300, 464, 620}

	self.titleText = {}
	local bg2 = CreateListTitle(self, cc.p(9, 518), 720, 46, cc.p(0, 1))
	for i,v in ipairs(self.dataShowTitle) do
		self.titleText[i] = createLabel(bg2, game.getStrByKey(self.dataShowTitle[i][1]), cc.p(self.dataShowPos[i], 20), cc.p(0.5, 0.5), 20 , true)
		self.titleText[i]:setColor(MColor.lable_yellow)
	end
	self:createTableView(self ,cc.size(730, 382), cc.p(10, 90), true)
	--self:getTableView():runAction(cc.Sequence:create(cc.DelayTime:create(0.3), cc.MoveTo:create(0.5, cc.p(10, 90))))
end

function RankingListLayer:setDataShow(dataShow, isSelfServer)
	self.dataShowType = dataShow
	self:changeTitle(dataShow)
	if self.data[self.dataShowType] == nil then
		self:getData(isSelfServer, 1)
	else
		self:reloadData()
	end
end

function RankingListLayer:changeTitle(dataShow)
	self.titleText[4]:setString(game.getStrByKey(self.dataShowTitle[4][dataShow]))
	if dataShow == RANK_FACTION then
		self.titleText[3]:setString(game.getStrByKey(self.dataShowTitle[3][2]))
	else
		self.titleText[3]:setString(game.getStrByKey(self.dataShowTitle[3][1]))
	end
end

function RankingListLayer:getSelected()
	local name = nil
	if self.selectIndex then
		name = self.dataShow[self.selectIndex][2] --"[" .. self.dataShow[self.selectIndex][5] .. "]" .. self.dataShow[self.selectIndex][2]
	end
	return name
end

function RankingListLayer:setHasSelect(has)
	if self.callBack then
		self.callBack(has)
	end
end

function RankingListLayer:getData(isSelfServer, page)
	print(page)
	if self.dataShowType == RANK_FACTION then
		g_msgHandlerInst:sendNetDataByTableExEx(RANK_CS_REQ, "RankReq", {tab = self.dataShowType, page = page, factionID = require("src/layers/role/RoleStruct"):getAttr(PLAYER_FACTIONID) or 0})
	else
		g_msgHandlerInst:sendNetDataByTableExEx(RANK_CS_REQ, "RankReq", {tab = self.dataShowType, page = page})
	end
	if page == 1 then
		addNetLoading(RANK_CS_REQ, RANK_SC_RET)
	end
end

function RankingListLayer:reloadData()
	self.dataShow = self.data[self.dataShowType]
	self.totleNum = self.rankAllNum[self.dataShowType]
	self.selfRank = self.selfRankData[self.dataShowType]
	if g_EventHandler["setSelfRank"] then  g_EventHandler["setSelfRank"](self.selfRank, self.dataShowType) end
	self:clearSelected()
	self:getTableView():reloadData()
end

function RankingListLayer:clearSelected()
	--取消选择
	self.selectIndex = nil
	if self.selectedRect then
		removeFromParent(self.selectedRect)
		self.selectedRect = nil
	end
	self:setHasSelect(false)
end

function RankingListLayer:tableCellTouched(table, cell)
	if cell:getIdx() + 1 == self.selfRank then
		--return
	end

	local x, y = cell:getPosition()
	if self.selectedRect == nil then
		self.selectedRect = createScale9Sprite(table, "res/common/scalable/selected.png", cc.p(0, 0), cc.size(726, 82), cc.p(0, 0), nil, nil, 2)
	end
	self.selectedRect:setPosition(cc.p(x - 2, y))

	self.selectIndex = cell:getIdx() + 1
	self:setHasSelect(true)
end

function RankingListLayer:cellSizeForTable(table, idx) 
    return 82, 730
end

function RankingListLayer:tableCellAtIndex(table, idx)
	local nowNum = #self.dataShow
	-- if idx + 1 == nowNum and nowNum < self.totleNum then
	-- 	print("table num ... nowNum = " .. nowNum)
	-- 	self:getData(self.dataShowType, math.floor(nowNum/20) + 1)
	-- end

	local cell = table:dequeueCell()
	if nil == cell then
		cell = cc.TableViewCell:new() 
	else
    	cell:removeAllChildren()
    end

	local bg = createSprite(cell, "res/common/table/cell4.png", cc.p(0, 2), cc.p(0, 0)) 
	local record = self.dataShow[idx + 1]
	if record then
		for i,v in ipairs(record) do
			if self.dataShowType == RANK_WING and i == 4 then
				local num2,num3 = math.floor(v/5),math.floor(v%5)
				if num3 == 0 then
					num3 = 5
					num2 = num2 - 1
				end
				local str = game.getStrByKey("num_" .. num2) .. game.getStrByKey("grade")
				str = str .. game.getStrByKey("num_" .. num3) .. game.getStrByKey("task_d_x")
				local label = createLabel(bg, str, cc.p(self.dataShowPos[i], 42), cc.p(0.5, 0.5), 20, nil)
				label:setColor( MColor.lable_black)
			elseif i == 1 then
				if idx + 1 <= 3 then
					createSprite(bg, path .. "no_" .. (idx + 1) .. ".png", cc.p(self.dataShowPos[i], 42))
				else
					local label = createLabel(bg, v, cc.p(self.dataShowPos[i], 42), cc.p(0.5, 0.5), 20, nil)--, nil, nil, nil, nil, nil, MColor.lable_outLine, 1)
					label:setColor( MColor.lable_black)	
				end
			elseif i == 3 or i == 4 then
				local label = createLabel(bg, v, cc.p(self.dataShowPos[i], 42), cc.p(0.5, 0.5), 20, nil)--, nil, nil, nil, nil, nil, MColor.lable_outLine, 1)
				label:setColor( MColor.lable_black)
			elseif i == 2 then
				local label = createLabel(bg, v, cc.p(self.dataShowPos[i]+5, 42), cc.p(0.5, 0.5), 20, nil) -- , nil , nil, nil, nil, nil, MColor.lable_outLine, 1)
				label:setColor( MColor.lable_black)
			end
		end
	end

    return cell
end

function RankingListLayer:numberOfCellsInTableView(table)
   	return #self.dataShow
end

function RankingListLayer:networkHander(buff,msgid)
	local switch = {
		[RANK_SC_RET] = function()
			log("get RANK_SC_RET"..msgid)
			local retTable = g_msgHandlerInst:convertBufferToTable("RankReqRet", buff)

			local rankType = retTable.tab

			self.rankAllNum[rankType] = retTable.size
			self.selfRank = retTable.selfRank

			self.rankType = rankType
			self.data[rankType] = self.data[rankType] or {}
			self.selfRankData[rankType] = self.selfRank

			local tempData = retTable.rankData
			local count = tempData and tablenums(tempData) or 0

			if rankType ~= RANK_FACTION then
				for i=1,count do
					local record = {}
					record[1] = tempData[i].rank
					record[2] = tempData[i].name
					record[3] = getSchoolByName(tempData[i].school)
					record[4] = tempData[i].value
					record[5] = tempData[i].roleSID
					table.insert(self.data[rankType], record)
				end
			else
				tempData = retTable.factionData
				count = tempData and tablenums(tempData) or 0
				for i=1, count do
					local record = {}
					record[1] = tempData[i].rank
					record[2] = tempData[i].name
					record[3] = tempData[i].level
					record[4] = tempData[i].battle
					record[5] = tempData[i].factionID
					table.insert(self.data[rankType], record)
				end
			end
			
			--dump(self.data)
            local offset =  self:getTableView():getContentOffset()
            self:reloadData()
            if #self.data[rankType] > 20 then
                self:getTableView():setContentOffset(cc.p(offset.x, offset.y - 82 * count)) 
            end			
		end,
	}

 	if switch[msgid] then 
 		switch[msgid]()
 	end
end

return RankingListLayer