local ChatFace = class("TitleListLayer", require("src/TabViewLayer"))

local path = "res/chat/"

function ChatFace:ctor(callBack)
	self.rowNum = 7
	self.rowWidth = 360
	self.rowHeight = 70
	self.faceCount = 44
	self.callBack = callBack

	self.rowSprite = {}

	local bg = createScale9Sprite(self, "res/common/scalable/6.png", cc.p(0, 0), cc.size(400, 530), cc.p(0, 0.5))--createSprite(self, "res/common/bg/bg36.png", cc.p(0, 0), cc.p(0, 0))
	local closeFunc = function()
		removeFromParent(self)
	end
	-- local closeBtn = createTouchItem(bg, "res/component/button/6.png", cc.p(bg:getContentSize().width-30, bg:getContentSize().height-30), closeFunc)
	-- closeBtn:setScale(0.8)

	self:createTableView(bg, cc.size(360, 490), cc.p(20, 20), true)

	self:reloadData()
	registerOutsideCloseFunc(bg, closeFunc, true)
end

function ChatFace:reloadData()
	self:getTableView():reloadData()
end

function ChatFace:tableCellTouched(table, cell)
	local idx = cell:getIdx()
	print("x = "..cell:getX()..", y = "..cell:getY())
	local touchX, touchY = cell:getX(), cell:getY()

	local selectIndex
	if self.rowSprite[idx] then
		for i,v in ipairs(self.rowSprite[idx]) do
			if cc.rectContainsPoint(v:getBoundingBox(), cc.p(touchX, touchY)) then
				AudioEnginer.playTouchPointEffect()
				selectIndex = idx*self.rowNum+i
				break
			end
		end
	end

	if selectIndex and self.callBack then
		self.callBack(selectIndex)
		startTimerAction(self, 0.1, false, function() removeFromParent(self) end)
	end		
end

function ChatFace:cellSizeForTable(table, idx) 
    return self.rowHeight, self.rowWidth
end

function ChatFace:tableCellAtIndex(table, idx)
	function createItem(cell)
		local startX = self.rowWidth / self.rowNum / 2
	    local addX = self.rowWidth / self.rowNum

	    self.rowSprite[idx] = {}
	    for i=1,self.rowNum do
	    	local faceSpr = createSprite(cell, path.."face/"..((idx*self.rowNum)+i)..".png", cc.p(startX+(i-1)*addX, self.rowHeight/2), cc.p(0.5, 0.5))
		    self.rowSprite[idx][i] = faceSpr
	    end
	end

	local cell = table:dequeueCell()
	if nil == cell then
		cell = cc.TableViewCell:new() 
		createItem(cell)
	else
    	cell:removeAllChildren()
    	createItem(cell)
    end
	
    return cell
end

function ChatFace:numberOfCellsInTableView(table)
   	return math.ceil(self.faceCount / self.rowNum)
end

return ChatFace