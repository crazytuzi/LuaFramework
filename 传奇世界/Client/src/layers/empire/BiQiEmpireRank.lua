local BiQiEmpireRank = class("BiQiEmpireRank", require("src/TabViewLayer"))

local tableWidth = 433
function BiQiEmpireRank:ctor(rankData)
	self.rankData = rankData or {}
	createScale9Sprite(self,"res/common/scalable/scale15.png",cc.p(tableWidth/2, 281),cc.size(433, 38),cc.p(0.5, 0.5))
	createLabel(self, "参战行会", cc.p(tableWidth/2, 281 ), nil, 22, true)

	local tabText = {"领地名称", "归属行会", "行会会长"}
	self.pos = {75, 215, 350}
	for i=1,#tabText do
		createLabel(self, tabText[i], cc.p(self.pos[i], 245), nil, 20, true)
	end
	createScale9Sprite(self,"res/common/bg/line9.png",cc.p(tableWidth/2, 223),cc.size(423, 3),cc.p(0.5, 0))

	local cfgData = getConfigItemByKey("AreaFlag", "mapID")
	for m,n in pairs(cfgData) do
		local manorID = n.manorID
		if not rankData[manorID] then
			rankData[manorID] = {n.name, "暂无归属", ""}
		else
			rankData[manorID][1] = n.name
		end
	end	
	
	self:createTableView(self, cc.size(tableWidth, 215), cc.p(0, 3), true)
end

function BiQiEmpireRank:cellSizeForTable(table, idx) 
    return 30, tableWidth
end

function BiQiEmpireRank:tableCellAtIndex(table, idx)
	local cell = table:dequeueCell()
	if nil == cell then
		cell = cc.TableViewCell:new() 
	else
    	cell:removeAllChildren()
    end
    local showData = self:getRankDataByIdx(idx+1)
    if showData then
    	for i=1,3 do
    		local lab = createLabel(cell, showData[i], cc.p(self.pos[i], 15), cc.p(0.5, 0.5), 20)
    		lab:setColor( MColor.lable_black)
    	end
	end
    return cell
end

function BiQiEmpireRank:getRankDataByIdx(idx)
	local count = 1
	for k,v in pairs(self.rankData) do
		if count == idx then
			return v
		end
		count = count + 1
	end
end

function BiQiEmpireRank:numberOfCellsInTableView(table)
   	return tablenums(self.rankData)
end

return BiQiEmpireRank