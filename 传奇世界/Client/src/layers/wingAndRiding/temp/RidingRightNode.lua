local RidingRightNode = class("RidingRightNode", function() return cc.Node:create() end)

local PoundLayer = class("PoundLayer", function() return cc.Layer:create() end)

local MPackStruct = require "src/layers/bag/PackStruct"
local MpropOp = require "src/config/propOp"

function RidingRightNode:ctor(parent, otherRoleData)
	-- dump(G_RIDING_INFO)
	-- dump(otherRoleData)
	self:initdata()

	--当有该数据时表明是查看被人的资料
	self.isOtherRole = false
	if otherRoleData then
		self.data = otherRoleData.ridingInfo
		self.isOtherRole = true
	end

	self:createNode()

	self:registerScriptHandler(function(event)
		if event == "enter" then
			G_TUTO_NODE:setShowNode(self, SHOW_RIDE)
			G_RIDE_RIGHT_NODE = self
		elseif event == "exit" then
			G_RIDE_RIGHT_NODE = nil
		end
	end)
end

function RidingRightNode:initdata(index)
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
	self.rideDress = (MPackStruct.eRideDress1 - 1) + self.index
	-- dump(self.data)
	-- dump(self.index)
end

function RidingRightNode:createNode()
	-- local msgids = {WOMAN_SC_GET_POTENCY_DATA_RET}
	-- require("src/MsgHandler").new(self,msgids)

	self:removeAllChildren()

	local bg = createSprite(self, "res/common/bg/bg63.jpg", cc.p(0, 0), cc.p(0, 0.5)) 
	self.bg = bg
	self.centerX = 253

	self.equipmentNode = cc.Node:create()
	bg:addChild(self.equipmentNode)
	self.equipmentNode:setPosition(cc.p(0, 0))

	local switchFunc = function() 
	   	log("switchFunc")
		local t = {}
		t.dwBagSlot = self.index
		dump(t)
		g_msgHandlerInst:sendNetDataByTable(EMOUNT_CS_USE_MOUNT, "MountUseMountProtocol", t)
		dump(EMOUNT_CS_USE_MOUNT)
	end
	local switchBtn = createMenuItem(bg,"res/component/button/50.png",cc.p(self.centerX, 40), switchFunc)
	self.switchBtn = switchBtn
	local switchLabel = createLabel(switchBtn, game.getStrByKey("wr_equip"), getCenterPos(switchBtn), cc.p(0.5, 0.5), 22, true)
	self.switchLabel = switchLabel
	G_TUTO_NODE:setTouchNode(switchBtn, TOUCH_RIDE_SWITCH)

	local nameBg = createSprite(bg, "res/layers/role/24.png", cc.p(self.centerX-7, 440), cc.p(0.5, 0)) 
	self.nameLabel = createLabel(nameBg, MpropOp.name(self.data.mPropProtoId), getCenterPos(nameBg, 0, -9), cc.p(0.5, 0.5), 20, true)

	local poundBtnFunc = function()
		local poundLayer = PoundLayer.new(self)
		self.bg:addChild(poundLayer)
		poundLayer:setPosition(cc.p(self.centerX-5, 310))
	end
	local poundBtn = createMenuItem(bg, "res/component/button/48.png", cc.p(self.centerX-190, 440), poundBtnFunc)
	createLabel(poundBtn, game.getStrByKey("wr_pound"), getCenterPos(poundBtn), cc.p(0.5, 0.5), 22, true)
	self.poundBtn = poundBtn

	local changeBtnFunc = function()
		log("changeBtnFunc")
		local node = require("src/layers/wingAndRiding/RidingChangeNode").new(self, self.index)
		getRunScene():addChild(node, 200)
	end
	local changeBtn = createMenuItem(bg, "res/component/button/48.png", cc.p(self.centerX+190, 440), changeBtnFunc)
	self.changeLabel = createLabel(changeBtn, game.getStrByKey("wr_skin"), getCenterPos(changeBtn), cc.p(0.5, 0.5), 22, true)
	self.changeBtn = changeBtn

	local moreBtnFunc = function()
		self:showOperationPanel()	
	end
	local moreBtn = createMenuItem(bg, "res/component/button/50.png", cc.p(self.centerX-170, 40), moreBtnFunc)
	createLabel(moreBtn, game.getStrByKey("more"), getCenterPos(moreBtn), cc.p(0.5, 0.5), 22, true)
	self.moreBtn = moreBtn

	local leaveBtnFunc = function()
		log("leaveBtnFunc")
		local t = {}
		t.dwBagSlot = self.index
		g_msgHandlerInst:sendNetDataByTable(ITEM_CS_FREE, "ItemMountFreeProtocol", t)
	end
	local leaveBtn = createMenuItem(bg, "res/component/button/50.png", cc.p(self.centerX+170, 40), leaveBtnFunc)
	createLabel(leaveBtn, game.getStrByKey("wr_leave"), getCenterPos(leaveBtn), cc.p(0.5, 0.5), 22, true)
	self.leaveBtn = leaveBtn

	createLabel(bg, game.getStrByKey("wr_ride_on_off_tip"), cc.p(20, 80), cc.p(0, 0), 20, true, 10, nil, MColor.white)

	
	-- dump(self.data.mPropProtoId)
	-- dump(getConfigItemByKey("MountDB", "mountId", self.data.mPropProtoId, "isold"))
	-- local isOld = (getConfigItemByKey("MountDB", "mountId", self.data.mPropProtoId, "isold") == 1)
	-- dump(isOld)

	-- if isOld then
	-- 	log("111111111111111111111111111111111111")
	-- 	removeFromParent(poundBtn)
	-- 	removeFromParent(changeBtn)
	-- 	removeFromParent(moreBtn)
	-- 	removeFromParent(leaveBtn)
	-- end

	local dressNode = require("src/layers/wingAndRiding/RidingDressNode").new(bg, self.index)
	bg:addChild(dressNode, 10)
	dressNode:setPosition(cc.p(0, 0))

	--查看别的玩家资料时去掉不必要的按钮
	if self.isOtherRole then
		removeFromParent(switchBtn)
		self.switchLabel = nil
	end

	self:updateUI()
end

function RidingRightNode:refresh(index)
	self:initdata(index)
	self:createNode()
end

function RidingRightNode:updateUI()
	if self.showNode then
		removeFromParent(self.showNode)
		self.showNode = nil
	end

	local protoId = (self.data.mSkinid ~= 0) and self.data.mSkinid or self.data.mPropProtoId
	local showNode = createSprite(self.bg, "res/showplist/ride/"..MpropOp.avatar(protoId)..".png", cc.p(self.centerX, 240), cc.p(0.5, 0.5), nil, 1)
	self.showNode = showNode

	if self.nameLabel then
		self.nameLabel:setString(MpropOp.name(self.data.mPropProtoId))
	end

	if self.switchLabel then
		if self.index == G_RIDING_INFO.index then
			self.switchBtn:setEnabled(false)
		else
			self.switchBtn:setEnabled(true)
		end
	end

	local isOld = (getConfigItemByKey("MountDB", "mountId", self.data.mPropProtoId, "isold") == 1)
	if isOld then
		self.poundBtn:setVisible(false)
		self.changeBtn:setVisible(false)
		self.moreBtn:setVisible(false)
		self.leaveBtn:setVisible(false)
	else
		self.poundBtn:setVisible(true)
		self.changeBtn:setVisible(true)
		self.moreBtn:setVisible(true)
		self.leaveBtn:setVisible(true)
	end

	self:updateEquipment()

	if G_RIDE_LEFT_NODE and G_RIDE_LEFT_NODE.refresh then
		G_RIDE_LEFT_NODE:refresh(self.index)
	end
end

function RidingRightNode:updateEquipment()
	self.equipmentNode:removeAllChildren()
end

function RidingRightNode:getCfgData(key)	
end

function RidingRightNode:change(id)
	local t = {}
	t.dwBagSlot = self.index
	t.dwSkinId = id
	dump(t)
	g_msgHandlerInst:sendNetDataByTable(ITEM_CS_CHANGE_SKIN, "ItemMountChnageSkinProtocol", t)
end

function RidingRightNode:showOperationPanel()
	local func = function(tag)
		local switch = {
			[1] = function() 
				sub_node = require("src/layers/wingAndRiding/RidingInheritNode").new(self.data, MPackStruct.eRide)
				getRunScene():addChild(sub_node, 200)
			end,
		}
		if switch[tag] then 
			switch[tag]() 
		end
		removeFromParent(self.operateLayer)
		self.operateLayer = nil
	end
	local menus = {
		{game.getStrByKey("wr_inherit_str"), 1, func},
	}

    self.operateLayer = require("src/OperationLayer").new(self.bg, 1, menus, "res/component/button/2","res/common/scalable/6.png")
    self.operateLayer:setPosition(cc.p(self.moreBtn:getPositionX() - display.cx, self.moreBtn:getPositionY()+80-display.cy))
    -- dump(self.moreBtn:getPosition())
    -- self.operateLayer:setBg(cc.p(self.moreBtn:getPositionX(), self.moreBtn:getPositionY()+50), cc.p(0.5, 0))
end

function RidingRightNode:networkHander(buff,msgid)
	-- local switch = {
	-- 	[EMOUNT_SC_MOUNT_SKIN_LIST] = function()
	-- 		log("get EMOUNT_SC_MOUNT_SKIN_LIST")
	-- 		local t = g_msgHandlerInst:convertBufferToTable("MountSkinlistRetProtocol", buff)
	-- 		self.skinTab = {}
	-- 		dump(t.vecSkinId)
	-- 		for i,v in ipairs(t.vecSkinId) do
	-- 			table.insert(self.skinTab, v)
	-- 		end
	-- 		dump(self.skinTab)
	-- 	end
	-- 	,
	-- 	[ITEM_SC_CHANGE_SKIN] = function()
	-- 		log("get ITEM_SC_CHANGE_SKIN")
	-- 		self:refresh(self.index)
	-- 	end
	-- }
	

 -- 	if switch[msgid] then 
 -- 		switch[msgid]()
 -- 	end
end

------------------------------------------------------------------------------------------
function PoundLayer:ctor(mainLayer)
	self.mainLayer = mainLayer

	local bg = createScale9Sprite(self, "res/common/scalable/12.png", cc.p(0, 0), cc.size(480, 230), cc.p(0.5, 0.5))

	local MPackStruct = require "src/layers/bag/PackStruct"
	local refSize = TextureCache:addImage("res/common/21.png"):getContentSize()
	local MPackView = require "src/layers/bag/PackView"
	local girdViewBag = MPackView.new(
	{
		--bg = "res/common/68.png",
		packId = MPackStruct.eRide,
		layout = { row = 2.2, col = 5, },
		marginLR = 5,
		marginUD = 5,
		girdSize = cc.size(95, 98),
		--mode = "access",
	})

	girdViewBag.onCellTouched = function(gv, cell, grid)
		-- dump(grid)
		-- -- local protoId = MPackStruct.protoIdFromGird(grid)
		-- -- local MpropOp = require "src/config/propOp"
		-- -- AudioEnginer.playEffect(MpropOp.soundEffect(protoId), false)
		-- -- local Mtips = require "src/layers/bag/tips"
		-- -- Mtips.new(
		-- -- {
		-- -- 	packId = MPackStruct.eBag,
		-- -- 	grid = grid,
		-- -- 	--pos = cell:getParent():convertToWorldSpace( cc.p(cell:getPosition()) ),
		-- -- 	--contrast = true,
		-- -- })
		-- dump(cell:getIdx())

		dump(grid)

		if self.mainLayer and self.mainLayer.refresh then
			--self.mainLayer:refresh(grid.mGirdSlot)
			startTimerAction(self, 0.1, false, function() self.mainLayer:refresh(grid.mGirdSlot) end)
		end
	end

	Mnode.addChild(
	{
		parent = bg,
		child = girdViewBag:getRootNode(),
		anchor = cc.p(0, 0),
		pos = cc.p(-2 , 0),
	})

	girdViewBag:refresh()

	--girdViewBag:setTouchEnabled(false)

	for i=0,9 do
		local cell = girdViewBag:cellAtIndex(i)
		dump(i)
		-- dump(cell)
		-- dump(cell:getContentSize())
		local rideBag = MPackManager:getPack(MPackStruct.eRide)
    	local grid = rideBag:getGirdByGirdId(i+1)
    	dump(grid)
    	if grid and grid.mPropProtoId then
			createLabel(cell, MpropOp.name(grid.mPropProtoId), cc.p(cell:getContentSize().width/2, 13), cc.p(0.5, 1), 18, true)
		end
	end

	registerOutsideCloseFunc(bg, function() removeFromParent(self) end, true)
end

----------------------------------------------------------------------------------------------------

return RidingRightNode