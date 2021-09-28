local RidingInheritNode = class("RidingInheritNode", function() return cc.Node:create() end)

local MPackStruct = require "src/layers/bag/PackStruct"
local MpropOp = require "src/config/propOp"

function RidingInheritNode:ctor(data, packId)
	local msgids = {ITEM_SC_INHERIT}
	require("src/MsgHandler").new(self, msgids)

	self.data = data
	self.packId = packId
	self.selectItem = nil

	local bg = createSprite(self, "res/common/bg/bg18.png", cc.p(display.cx, display.cy), cc.p(0.5, 0.5))
	self.bg = bg

	local closeFunc = function() 
		removeFromParent(self)
	end
	local closeBtn = createTouchItem(bg, "res/component/button/X.png", cc.p(bg:getContentSize().width-40, bg:getContentSize().height-25), closeFunc)

	local helpBtn = __createHelp({parent = bg, str=game.getStrByKey("wr_inherit_help"), pos=cc.p(80, 180)})

	createLabel(bg, game.getStrByKey("wr_inherit"), cc.p(bg:getContentSize().width/2, bg:getContentSize().height-25), cc.p(0.5, 0.5), 22, nil, nil, nil, MColor.white)
	createSprite(bg, "res/common/bg/bg44-6.png", cc.p(bg:getContentSize().width/2, 25), cc.p(0.5, 0))

	local leftBg = createSprite(bg, "res/common/bg/iconBg3.png", cc.p(bg:getContentSize().width/2-250, 350), cc.p(0.5, 0.5))
	local leftIconBg = createSprite(leftBg, "res/common/bg/iconBg3-1.png", getCenterPos(leftBg), cc.p(0.5, 0.5))
	self.leftIconBg = leftIconBg

	local leftBtnFunc = function()
		
	end
	local leftBtn = createMenuItem(leftIconBg, "res/layers/equipment/jia.png", getCenterPos(leftIconBg), leftBtnFunc)

	self.leftNameLabel = createLabel(bg, "", cc.p(bg:getContentSize().width/2-250, 220), cc.p(0.5, 0.5), 20, nil, nil, nil, MColor.white)

	createSprite(bg, "res/group/arrows/17.png", cc.p(bg:getContentSize().width/2, 350), cc.p(0.5, 0.5))

	local rightBg = createSprite(bg, "res/common/bg/iconBg3.png", cc.p(bg:getContentSize().width/2+250, 350), cc.p(0.5, 0.5))
	local rifhtIconBg = createSprite(rightBg, "res/common/bg/iconBg3-1.png", getCenterPos(rightBg), cc.p(0.5, 0.5))
	self.rifhtIconBg = rifhtIconBg

	local rifhtBtnFunc = function()
		log("rifhtBtnFunc")
		local Mreloading = require "src/layers/equipment/equip_select"
		local Manimation = require "src/young/animation"
		Manimation:transit(
		{
			node = Mreloading.new(
			{
				now = {},
				filtrate = function(packId, grid, now)
					local MequipOp = require "src/config/equipOp"
					local Mconvertor = require "src/config/convertor"
					
					local protoId = MPackStruct.protoIdFromGird(grid)
					-- -- 是否是勋章
					-- local isMedal = protoId >= 30004 and protoId <= 30006
					-- if MPackStruct.categoryFromGird(grid) ~= MPackStruct.eEquipment or isMedal then
					-- 	return false
					-- end
					
					-- local gridId = MPackStruct.girdIdFromGird(grid)
					-- local now_gridId = MPackStruct.girdIdFromGird(now.grid)
					-- if packId == now.packId and gridId == now_gridId then return false end
					
					-- local strengthLv = MPackStruct.attrFromGird(grid, MPackStruct.eAttrStrengthLevel)
					-- if strengthLv < 1 then return false end

					-- local quality = MpropOp.quality(protoId)
					-- if quality < 3 then return false end -- 蓝色品质以上才可传承

					-- dump(grid)
					-- dump(self.data)

					if MpropOp.category(protoId)==21 then
						local myQuality = MpropOp.quality(self.data.mPropProtoId)
						local myLevel = self.data.mLevel
						--local quality = MpropOp.quality(grid.mPropProtoId)
						dump(myQuality)
						dump(MpropOp.quality(grid.mPropProtoId))

						if myLevel >= grid.mLevel and myQuality <= MpropOp.quality(grid.mPropProtoId) and self.data.mGuid ~= grid.mGuid then
							return true
						end
					end
					return false
				end,

				handler = function(item)
					dump(item)
					self.selectItem = item
					self:updateData()
				end,
				
				act_src = "放入",
				leftBtns={"all", "ride"},
			}),
			sp = g_scrCenter,
			ep = g_scrCenter,
			--trend = "-",
			zOrder = 200,
			curve = "-",
			swallow = true,
		})
	end
	local rifhtBtn = createMenuItem(rifhtIconBg, "res/layers/equipment/jia.png", getCenterPos(rifhtIconBg), rifhtBtnFunc)

	self.rightNameLabel = createLabel(bg, "", cc.p(bg:getContentSize().width/2+250, 220), cc.p(0.5, 0.5), 20, nil, nil, nil, MColor.white)

	local bottomBg = createSprite(bg, "res/common/bg/bg18-8.png", cc.p(bg:getContentSize().width/2, 90), cc.p(0.5, 0.5))

	local inheritBtnFunc = function()
-- 		//ITEM_CS_INHERIT = 5047 //传承
-- message ItemMountInheritProtocol
-- {
-- 	optional uint32 dwSrcBagId = 1;
-- 	optional uint32 dwSrcBagSlot = 2;
-- 	optional uint32 dwDesBagId = 3;
-- 	optional uint32 dwDesBagSlot = 4;
-- 	optional uint32 dwRandPropertyFlag = 5; //(1:传承极品属性)
-- }
		local t = {}
		t.dwSrcBagId = self.packId
		t.dwSrcBagSlot = self.data.mGirdSlot
		t.dwDesBagId = self.selectItem.packId
		t.dwDesBagSlot = self.selectItem.grid.mGirdSlot
		if self.checkFlag:isVisible() then
			t.dwRandPropertyFlag = 1
		else
			t.dwRandPropertyFlag = 0
		end
		dump(t)
		g_msgHandlerInst:sendNetDataByTable(ITEM_CS_INHERIT, "ItemMountInheritProtocol", t)
		addNetLoading(ITEM_CS_INHERIT, ITEM_SC_INHERIT)
	end
	local inheritBtn = createMenuItem(bottomBg, "res/component/button/2.png", cc.p(680, bottomBg:getContentSize().height/2), inheritBtnFunc)
	self.inheritBtn = inheritBtn
	inheritBtn:setEnabled(false)
	createLabel(inheritBtn, game.getStrByKey("wr_inherit_str"), getCenterPos(inheritBtn), cc.p(0.5, 0.5), 22, true)

	local function checkFunc()
		if self.checkFlag:isVisible() then
			self.checkFlag:setVisible(false)
			self:updateData()
		else
			self.checkFlag:setVisible(true)
			self:updateData()
		end
	end
	local checkbox = createTouchItem(bottomBg, "res/component/checkbox/1.png", cc.p(40, bottomBg:getContentSize().height/2+20), checkFunc)
	self.checkFlag = createSprite(checkbox, "res/component/checkbox/1-1.png", getCenterPos(checkbox), cc.p(0.5, 0.5))
	self.checkFlag:setVisible(true)
	createLabel(bottomBg, game.getStrByKey("wr_inherit_check"), cc.p(60, bottomBg:getContentSize().height/2+20), cc.p(0, 0.5), 20, true, nil, nil, MColor.white)

	self.spendNode = cc.Node:create()
	bottomBg:addChild(self.spendNode)
	self.spendNode:setPosition(cc.p(0, 0))

	local function updateSpendInfo()
		self.spendNode:removeAllChildren()

		local spendMoney = 20
		local myMoney = G_ROLE_MAIN.currGold + G_ROLE_MAIN.currBindGold
		local moneyName = game.getStrByKey("ingot")
		local richText = require("src/RichText").new(self.spendNode, cc.p(25, bottomBg:getContentSize().height/2-30), cc.size(360, 20), cc.p(0, 0), 20, 20, MColor.lable_yellow)
		local text = string.format(game.getStrByKey("wr_spend_text"), "^c(white)"..spendMoney..moneyName.."^", "^c(white)"..myMoney..moneyName.."^")
		dump(text)
 		richText:addText(text)
  		richText:format()
	end
	--startTimerAction(self.spendNode, 1, true, function() updateSpendInfo() end)
	updateSpendInfo()

	self:updateData()

	registerOutsideCloseFunc(bg, function() removeFromParent(self) end, true)
end

function RidingInheritNode:updateData()
	self:updateUI()
end

function RidingInheritNode:updateUI()
	--dump(self.data)
	if self.data then
		local Mprop = require "src/layers/bag/prop"
		local srcIcon = Mprop.new(
		{
			grid = self.data,
			strengthLv = MPackStruct.attrFromGird(self.data, MPackStruct.eAttrStrengthLevel),
		})
		self.leftIconBg:removeChildByTag(100)
		self.leftIconBg:addChild(srcIcon)
		srcIcon:setPosition(getCenterPos(self.leftIconBg))
		srcIcon:setTag(100)

		self.leftNameLabel:setString(MpropOp.name(self.data.mPropProtoId))
	end

	if self.selectItem then
		local Mprop = require "src/layers/bag/prop"
		local srcIcon = Mprop.new(
		{
			grid = self.selectItem.grid,
			strengthLv = MPackStruct.attrFromGird(self.selectItem.grid, MPackStruct.eAttrStrengthLevel),
		})
		self.rifhtIconBg:removeChildByTag(100)
		self.rifhtIconBg:addChild(srcIcon)
		srcIcon:setPosition(getCenterPos(self.rifhtIconBg))
		srcIcon:setTag(100)
		-- dump(self.selectItem)
		-- dump(MpropOp.name(self.selectItem.grid.mPropProtoId))
		self.rightNameLabel:setString(MpropOp.name(self.selectItem.grid.mPropProtoId))

		self.inheritBtn:setEnabled(true)
	else
		self.inheritBtn:setEnabled(false)
	end
end

function RidingInheritNode:networkHander(buff, msgid)
	local switch = {
		[ITEM_SC_INHERIT] = function()    
			local t = g_msgHandlerInst:convertBufferToTable("ItemMountInheritRetProtocol", buff)
			
			self:updateData()

			removeFromParent(self)
		end
	}

 	if switch[msgid] then 
 		switch[msgid]()
 	end
end

return RidingInheritNode