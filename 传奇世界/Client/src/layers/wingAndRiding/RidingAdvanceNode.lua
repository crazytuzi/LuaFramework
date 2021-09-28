local RidingAdvanceNode = class("RidingAdvanceNode", function() return cc.Node:create() end )

local pathCommon = "res/wingAndRiding/common/"

local MPackStruct = require "src/layers/bag/PackStruct"
local MpropOp = require "src/config/propOp"

function RidingAdvanceNode:ctor(parent, index)
	local msgids = {ITEM_SC_ADD_EXP
					}
	require("src/MsgHandler").new(self, msgids)

	dump(G_RIDE_INFO)

	self.parent = parent
	self:initdata(index)
	self.choseIndex = 0

	local bg = createSprite(self, "res/common/bg/bg18.png", cc.p(display.cx, display.cy), cc.p(0.5, 0.5))
	self.bg = bg
	createLabel(bg, game.getStrByKey("wr_ride_update"), cc.p(bg:getContentSize().width/2, bg:getContentSize().height-30), cc.p(0.5, 0.5), 24, true)

	local contentBg = createScale9Frame(
        bg,
        "res/common/scalable/panel_outer_base_1.png",
        "res/common/scalable/panel_outer_frame_scale9_1.png",
        cc.p(32, 15),
        cc.size(792,455),
        5
    )

	local closeFunc = function() 
	   	self.bg:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 0), cc.CallFunc:create(function() self:removeFromParent() end)))	
	end
	local closeBtn = createTouchItem(bg, "res/component/button/x2.png", cc.p(bg:getContentSize().width-48, bg:getContentSize().height-28), closeFunc)

	local rightBg = createScale9Sprite(contentBg, "res/common/scalable/setbg.png", cc.p(435, 5), cc.size(345, 440), cc.p(0, 0))
	self.rightBg = rightBg
	local leftBg = createSprite(contentBg, "res/wingAndRiding/1.png", cc.p(5, 5), cc.p(0, 0))
	self.leftBg = leftBg
	
	self:updateData()

	registerOutsideCloseFunc(bg , closeFunc, true)

	self:registerScriptHandler(function(event)
		if event == "enter" then
			G_TUTO_NODE:setShowNode(self, SHOW_WING_ADVANCE)
		elseif event == "exit" then
			-- if G_RIDE_RIGHT_NODE and G_RIDE_RIGHT_NODE.refresh then
			-- 	G_RIDE_RIGHT_NODE:refresh(self.data.mGirdSlot)
			-- end

			-- if G_RIDE_LEFT_NODE and G_RIDE_LEFT_NODE.refresh then
			-- 	G_RIDE_LEFT_NODE:refresh(self.data.mGirdSlot)
			-- end
		end
	end)
end

function RidingAdvanceNode:initdata(index)
	local function getFirstIndex()
		for i=1,10 do
			local rideBag = MPackManager:getPack(MPackStruct.eRide)
	    	local grid = rideBag:getGirdByGirdId(i)
	    	if grid and grid.mPropProtoId then
				return i
			end
		end
	end

	index = index or G_RIDING_INFO.index
	--第一次显示第一个
	if index == nil or index <= 0 then
		index = getFirstIndex()
	end
	local rideBag = MPackManager:getPack(MPackStruct.eRide)
    local grid = rideBag:getGirdByGirdId(index)
  
	self.data = grid
	self.index = index
	-- dump(self.data)
	-- dump(self.index)
end

function RidingAdvanceNode:updateData()
	self:initdata(self.index)
	self:updateUI()
end

function RidingAdvanceNode:updateUI()
	self:updateLeft()
	self:updateRight()
	--startTimerAction(self, 1, true, function() self:updateRight() end)
end

function RidingAdvanceNode:updateLeft()
	self.leftBg:removeAllChildren()

	local protoId = (self.data.mSkinid ~= 0) and self.data.mSkinid or self.data.mPropProtoId
	local rideSpr = createSprite(self.leftBg, "res/showplist/ride/"..MpropOp.avatar(protoId)..".png", cc.p(self.leftBg:getContentSize().width/2+20, 220), cc.p(0.5, 0.5))
	--wingSpr:setScale(1.2)

	local nameBg = createSprite(self.leftBg, "res/layers/role/24.png", cc.p(self.leftBg:getContentSize().width/2, 370), cc.p(0.5, 0)) 
	createLabel(nameBg, MpropOp.name(self.data.mPropProtoId), getCenterPos(nameBg, 0, -9), cc.p(0.5, 0.5), 20, true)
end

function RidingAdvanceNode:updateRight()
	self.rightBg:removeAllChildren()
	
	local baseInfo = require("src/RichText").new(self.rightBg, cc.p(15, 430), cc.size(240, 30), cc.p(0, 1), 30, 20, MColor.lable_yellow)
    baseInfo:addText(game.getStrByKey("wr_name").."：".."^c(white)"..MpropOp.name(self.data.mPropProtoId).."^".."\n")
    baseInfo:addText(game.getStrByKey("wr_level").."：".."^c(white)"..self.data.mLevel.."^".."\n")
    local expMax = getConfigItemByKey("MountExp", "q_level", self.data.mLevel, "exp")
    baseInfo:addText(game.getStrByKey("wr_exp").."：")
    baseInfo:format()

    --local progressNode = cc.Node:create()
    local progressBg = createSprite(self.rightBg, "res/component/progress/2_bg.png", cc.p(75, 340), cc.p(0, 0))
	local progress = cc.ProgressTimer:create(cc.Sprite:create("res/component/progress/2_green.png"))  
	progressBg:addChild(progress)
    progress:setPosition(getCenterPos(progressBg))
    progress:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    progress:setAnchorPoint(cc.p(0.5, 0.5))
    progress:setBarChangeRate(cc.p(1, 0))
    progress:setMidpoint(cc.p(0, 1))
    progress:setPercentage(self.data.mExp * 100 / expMax)
	createLabel(progressBg, self.data.mExp.."/"..expMax, getCenterPos(progressBg), cc.p(0.5, 0.5), 16, true, nil, nil, MColor.white)

	local useBtnFunc = function()
		log("useBtn")
		local t = {}
		t.dwBagId = MPackStruct.eRide
		t.dwBagSlot = self.data.mGirdSlot
		t.dwItemId = getConfigItemByKey("RideExp")[self.choseIndex].q_id
		dump(t)
		g_msgHandlerInst:sendNetDataByTable(ITEM_CS_ADD_EXP, "ItemMountAddExpProtocol", t)
	end
	local useBtn = createMenuItem(self.rightBg, "res/component/button/48.png", cc.p(self.rightBg:getContentSize().width/2, 40), useBtnFunc)
	useBtn:setEnabled(false)
	if self.choseIndex > 0 then
		useBtn:setEnabled(true)
	end
	useBtn:setLongTouchCallBack(useBtnFunc)
	self.useBtn = useBtn
	createLabel(useBtn, game.getStrByKey("wr_btn_use"), getCenterPos(useBtn), cc.p(0.5, 0.5), 22, true)

	self:updateNeedsLabel()
end 

function RidingAdvanceNode:updateNeedsLabel()
	local expTab = getConfigItemByKey("RideExp")
	self.iconTab = {}

	local showBg = createScale9Sprite(self.rightBg, "res/common/scalable/11.png", cc.p(self.rightBg:getContentSize().width/2, 200), cc.size(320, 130), cc.p(0.5, 0))
	createLabel(showBg, game.getStrByKey("wr_ride_chose_item"), cc.p(showBg:getContentSize().width/2, 97), cc.p(0.5, 0), 20, true)

	local function getMaterialNumber(id)
		local num = 0
		local MPackStruct = require "src/layers/bag/PackStruct"
		local MPackManager = require "src/layers/bag/PackManager"
		local pack = MPackManager:getPack(MPackStruct.eBag)
		num = pack:countByProtoId(id)

		return num
	end

	local function choseItem(node, index)
		local selectSpr = createScale9Sprite(node, "res/common/scalable/selected.png", getCenterPos(node), cc.size(node:getContentSize().width+20, node:getContentSize().height+20), cc.p(0.5, 0.5))
		selectSpr:setTag(123)
		self.choseIndex = index
		if self.choseIndex > 0 then
			self.contentBg:removeAllChildren()
			createLabel(self.contentBg, MpropOp.name(expTab[self.choseIndex].q_id), cc.p(15, 40), cc.p(0, 0), 20, true)
			createLabel(self.contentBg, string.format(game.getStrByKey("wr_ride_item_tip"), expTab[self.choseIndex].exp), cc.p(15, 10), cc.p(0, 0), 20, true)
			self.useBtn:setEnabled(true)
		end
	end

	local function choseFunc(touch, event)
		log("choseFunc")
		local node = event:getCurrentTarget()
		dump(node:getPosition())
		dump(node:getTag())
		for i,v in ipairs(self.iconTab) do
			v:removeChildByTag(123)
			if v == node then
				choseItem(v, i)
			end
		end
	end
	local addX = showBg:getContentSize().width/#expTab
	local x = addX/2
	local y = 50
	for i,v in ipairs(expTab) do
		local icon = createPropIcon(showBg, v.q_id, false, true, choseFunc)
		icon:setPosition(cc.p(x + (i-1)*addX, y))
		icon:setTag(i)
		self.iconTab[i] = icon

		createLabel(icon, getMaterialNumber(v.q_id), cc.p(icon:getContentSize().width, 0), cc.p(1, 0), 20, true, nil, nil, MColor.white)
	end
	
	local contentBg = createScale9Sprite(self.rightBg, "res/common/scalable/11.png", cc.p(self.rightBg:getContentSize().width/2, 110), cc.size(320, 80), cc.p(0.5, 0))
	self.contentBg = contentBg

	if self.choseIndex > 0 then
		choseItem(self.iconTab[self.choseIndex], self.choseIndex)
	end
end

function RidingAdvanceNode:networkHander(buff,msgid)
	local switch = {
		[ITEM_SC_ADD_EXP] = function()
			log("ITEM_SC_ADD_EXP")
			local t = g_msgHandlerInst:convertBufferToTable("ItemMountAddExpRetProtocol", buff)
			if t.isUpgrade == 1 then
				if G_RIDE_RIGHT_NODE and G_RIDE_RIGHT_NODE.refresh then
					G_RIDE_RIGHT_NODE:refresh(self.data.mGirdSlot)
				end

				if G_RIDE_LEFT_NODE and G_RIDE_LEFT_NODE.refresh then
					G_RIDE_LEFT_NODE:refresh(self.data.mGirdSlot)
				end
				removeFromParent(self)
			else
				self:updateData()
			end
		end
		,
	}

 	if switch[msgid] then 
 		switch[msgid]()
 	end
end

return RidingAdvanceNode