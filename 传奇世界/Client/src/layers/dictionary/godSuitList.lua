local GodListLayer = class("GodListLayer", require("src/TabViewLayer"))
function GodListLayer:ctor(idx)
	createSprite(self,"res/common/bg/bg55-1.png",cc.p(578,533),nil,50)
	createSprite(self,"res/common/bg/bg55-2.png",cc.p(578,75),nil,50)
	self.dataShow = {}
	self.dataShow1 = {}
	self.dataShow2 = {}
	self:createTableView(self ,cc.size( 598 , 320 ),cc.p( 284 , 72 ), true, true)
	self:reloadData(idx)
	--self:getTableView():runAction(cc.Sequence:create(cc.DelayTime:create(0.05), cc.MoveTo:create(0.05, cc.p(270, 20))))
end

function GodListLayer:reloadData(idx)
	local sex = G_ROLE_MAIN:getSex()
	local suit_info = getConfigItemByKeys("suitSet", {"q_sex","q_groupID"},{sex,idx})
	local tab = {}
	local tab1 = {}
	for k, v in string.gmatch(suit_info.q_set, "%[(%d+)%]=(%d+)") do
		tab1[tonumber(k)]=tonumber(v)
	end
	tab[1] = suit_info.F3
	tab[2] = suit_info.F7
	self.dataShow = tab
	tab = {}
	for k, v in string.gmatch(suit_info.q_road, "%[(%d+)%]=([^%[,%}]+)") do
		tab[tonumber(k)]=v
	end
	self.dataShow1 = tab1
	self.dataShow2 = tab
	self.gotoTab = {}
	if suit_info.jmtz then
		stringsplit(suit_info.jmtz,",")
	end
	self:getTableView():reloadData()
end

function GodListLayer:tableCellTouched(table, cell)
	local idx = cell:getIdx()
	local touchX, touchY = cell:getX(), cell:getY()
	local select_index = idx*2+1
	if touchX > 340 then
		select_index = select_index + 1
	end
	if self.gotoTab[select_index] then
		__GotoTarget( { ru = self.gotoTab[select_index] } )
		AudioEnginer.playTouchPointEffect()
	end
end

function GodListLayer:cellSizeForTable(table, idx) 
    return 125, 600
end

function GodListLayer:tableCellAtIndex(table, idx)
	local cell = table:dequeueCell()
	if nil == cell then
		cell = cc.TableViewCell:new() 
	else
    	cell:removeAllChildren()
    end
   -- createScale9Sprite(cell, "res/common/unsel.png", cc.p(0,55),cc.size(670,100), cc.p(0.0,0.5))
	local posxs = {0,300}
	for i = 1,2 do
		local tipTemp = nil
		local MPropOp = require "src/config/propOp"
		createSprite(cell, "res/common/table/cell25.png", cc.p(posxs[i], 0), cc.p(0, 0))
		local name_label = createLabel(cell, MPropOp.name(self.dataShow1[idx*2+i]), cc.p(posxs[i]+110, 80), cc.p(0, 0),20,nil,nil,nil,MColor.black)
		-- name_label:setColor(MPropOp.nameColor(self.dataShow[idx*2+i]))
		local from_label = createLabel(cell, self.dataShow2[idx*2+i], cc.p(posxs[i]+110, 75), cc.p(0, 1),20,nil,nil,nil,MColor.deep_brown,nil,165) 
		-- from_label:setColor(MColor.lable_black)
		local get_flag = createSprite(cell ,"res/component/flag/3.png",cc.p(posxs[i]+235, 50))
		local pack = MPackManager:getPack(MPackStruct.eDress)
		local num = pack:countByProtoId(self.dataShow1[idx*2+i])
		if num > 0 then
			get_flag:setVisible(true)
		else
			get_flag:setVisible(false)
		end
		local Mprop = require "src/layers/bag/prop"
		-- tipTemp = "tips"
		local sprite = Mprop.new({ protoId = self.dataShow1[idx*2+i], cb = "tips" })
		if sprite then
			sprite:setPosition(posxs[i]+60,65)
			cell:addChild(sprite)
		end
	end
    return cell
end

function GodListLayer:numberOfCellsInTableView(table)
   	return math.ceil(#self.dataShow1/2)
end



return GodListLayer