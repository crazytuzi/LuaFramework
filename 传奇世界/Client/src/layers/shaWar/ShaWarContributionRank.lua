local ShaWarContributionRank = class("ShaWarContributionRank", require("src/TabViewLayer"))

local tableWidth = 433
function ShaWarContributionRank:ctor(rankData)
	self.rankData = rankData or {}
	createScale9Sprite(self,"res/common/scalable/scale15.png",cc.p(tableWidth/2, 145 + 61),cc.size(433, 38),cc.p(0.5, 0.5))
	createLabel(self, "申请攻沙排名", cc.p(tableWidth/2, 145 + 65), nil, 22, true)

	local tabText = {"排名", "行会名称", "行会会长", "上交数量"}
	self.pos = {25, 115, 260, 380}
	for i=1,#tabText do
		createLabel(self, tabText[i], cc.p(self.pos[i], 38 + 108 + 21), nil, 20, true)
	end
	self:createTableView(self, cc.size(tableWidth, 110), cc.p(0, 33), true)
	createScale9Sprite(self,"res/common/bg/line9.png",cc.p(tableWidth/2, -2),cc.size(423, 3),cc.p(0.5, 0))
	createScale9Sprite(self,"res/common/bg/line9.png",cc.p(tableWidth/2, 38 + 108),cc.size(423, 3),cc.p(0.5, 0))

	local spec = 0
	local tabMyFactionData = {}
	local MyfacID = require("src/layers/role/RoleStruct"):getAttr(PLAYER_FACTIONID)
	if MyfacID ~= 0 then
		for k,v in pairs(rankData) do
			if MyfacID == v[5] then
				spec = k
			end
		end

		if spec ~= 0 then
			local tempData = rankData[spec]
			if tempData then
				tabMyFactionData = tempData
			end
		end
	else
		tabMyFactionData = {"--","暂未入会","-","0"}
	end

	for i=1,#tabText do
		if tabMyFactionData[i] then
			local lab = createLabel(self, tabMyFactionData[i], cc.p(self.pos[i], 21), nil, 20, true)
			lab:setColor(MColor.blue)
		end
	end
end

function ShaWarContributionRank:cellSizeForTable(table, idx) 
    return 30, tableWidth
end

function ShaWarContributionRank:tableCellAtIndex(table, idx)
	local cell = table:dequeueCell()
	if nil == cell then
		cell = cc.TableViewCell:new() 
	else
    	cell:removeAllChildren()
    end
    local showData = self.rankData[idx+1]
    if showData then
    	if showData[6] then
    		local lab1 = createLabel(cell, showData[1] .. ": " .. showData[2], cc.p(self.pos[1] -20, 15), cc.p(0, 0.5), 20,true)
    		local lab2 = createLabel(cell, "行会会长: " .. showData[3], cc.p(self.pos[1] + 180, 15), cc.p(0, 0.5), 20)
    		lab1:setColor( MColor.lable_black)
    		lab2:setColor( MColor.lable_black)
    	else
	    	for i=1,4 do
	    		local lab = createLabel(cell, showData[i], cc.p(self.pos[i], 15), cc.p(0.5, 0.5), 20)
	    		lab:setColor( MColor.lable_black)
	    	end
	    end
	end
    return cell
end

function ShaWarContributionRank:numberOfCellsInTableView(table)
   	return #self.rankData
end

return ShaWarContributionRank