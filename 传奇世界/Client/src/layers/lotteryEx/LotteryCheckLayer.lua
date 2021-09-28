local LotteryCheckLayer = class("LotteryCheckLayer", require("src/TabViewLayer"))

local path = "res/lotteryEx/"

function LotteryCheckLayer:ctor(isNormal, data)
	self.data = data
	self.rowNum = 4
	self.rowWidth = 460
	self.rowHeight = 90
	self.isNormal = isNormal
	self.rowSprite = {}

	--local masking = cc.LayerColor:create(cc.c4b(0, 0, 0, 255*0.7))
	--self:addChild(masking)

	local bg = createSprite(self, "res/common/bg/bg27.png", cc.p(display.cx, display.cy), cc.p(0.5, 0.5))
	local bgContent = createSprite(bg, "res/common/bg/bg27-4.png", getCenterPos(bg, 0, -20), cc.p(0.5, 0.5))
	local closeFunc = function()
		removeFromParent(self)
	end
	local closeBtn = createTouchItem(bg, "res/component/button/x3.png", cc.p(bg:getContentSize().width-20, bg:getContentSize().height-25), closeFunc)
	closeBtn:setScale(0.8)

	--local titleBg = createSprite(bg, "res/common/1.png", cc.p(bg:getContentSize().width/2, bg:getContentSize().height), cc.p(0.5, 0.5))
	if isNormal then
		--createSprite(bg, path.."3.png", cc.p(bg:getContentSize().width/2, bg:getContentSize().height-2), cc.p(0.5, 1))
		createLabel(bg, game.getStrByKey("lotteryEx_normal_include"), cc.p(bg:getContentSize().width/2, bg:getContentSize().height-27), cc.p(0.5, 0.5), 22, true, nil, nil, MColor.lable_black)
	else
		--createSprite(bg, path.."2.png", cc.p(bg:getContentSize().width/2, bg:getContentSize().height-2), cc.p(0.5, 1))
		createLabel(bg, game.getStrByKey("lotteryEx_special_include"), cc.p(bg:getContentSize().width/2, bg:getContentSize().height-27), cc.p(0.5, 0.5), 22, true, nil, nil, MColor.lable_black)
	end

	--local tabelBg = createSprite(bg, path.."13.png", cc.p(bg:getContentSize().width/2, 105), cc.p(0.5, 0))
	dump(bg:getContentSize().width)
	self:createTableView(bg ,cc.size(self.rowWidth, 440), cc.p((bg:getContentSize().width-self.rowWidth)/2, 30), true)

	--SwallowTouches(self)

	self:reloadData()
	registerOutsideCloseFunc(bg, closeFunc, true)
end

function LotteryCheckLayer:reloadData()
	self:getTableView():reloadData()
end

function LotteryCheckLayer:tableCellTouched(table, cell)
	local idx = cell:getIdx()
	--print("x = "..cell:getX()..", y = "..cell:getY())
	local touchX, touchY = cell:getX(), cell:getY()
	if self.rowSprite[idx] then
		for i,v in ipairs(self.rowSprite[idx]) do
			if cc.rectContainsPoint(v:getBoundingBox(), cc.p(touchX, touchY)) then
				AudioEnginer.playTouchPointEffect()
				local Mtips = require "src/layers/bag/tips"
				Mtips.new(
				{
					protoId = self.data[idx*self.rowNum + i],
					pos = v:getParent():convertToWorldSpace(cc.p(v:getPosition())),
					--actions = actions,
					contrast = true,
				})
				break
			end
		end
	end
end

function LotteryCheckLayer:cellSizeForTable(table, idx) 
    return self.rowHeight, self.rowWidth
end

function LotteryCheckLayer:tableCellAtIndex(table, idx)
	function createItem(node)
	    local addX = self.rowWidth / (self.rowNum + 1)
	    -- local bg
	    -- if self.isNormal then
	    -- 	bg = createSprite(node, "res/common/shadow.png", cc.p(self.rowWidth/2, -10), cc.p(0.5, 0))
	    -- 	 bg:setScale(2.3, 2)
	    -- else
	    -- 	bg = createSprite(node, "res/common/shadow1.png", cc.p(self.rowWidth/2, -10), cc.p(0.5, 0))
	    -- 	 bg:setScale(2.3, 1.7)
	    -- end
	    -- bg:setOpacity(255 * 0.3)

	    self.rowSprite[idx] = {}
	    for i=1,self.rowNum do
	    	if self.data[idx*self.rowNum + i] then
		    	local Mprop = require("src/layers/bag/prop")
				local iconNode = Mprop.new({cb = nil, protoId = self.data[idx*self.rowNum + i], hasRandomAttr=true})
				node:addChild(iconNode)
				iconNode:setAnchorPoint(cc.p(0.5, 0))
		        --iconNode:setScale(0.7)
		        iconNode:setPosition(cc.p(addX * i, 0))

		        self.rowSprite[idx][i] = iconNode
		    end
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

function LotteryCheckLayer:numberOfCellsInTableView(table)
   	return math.ceil(#self.data / self.rowNum)
end

return LotteryCheckLayer