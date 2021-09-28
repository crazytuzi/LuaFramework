local NewEquipmentLayer = class("NewEquipmentLayer", function() return cc.Layer:create() end)

require("src/layers/tuto/TutoFunction")

local resPath = "res/tuto/images/"

NewEquipmentLayer.showList = {}

function NewEquipmentLayer:ctor(gird, replaceGirdId, battle)
	log("NewEquipmentLayer")
	self.autoActionTime = 6

	local bg = createSprite(self, resPath.."2.png", cc.p(display.width-90, display.height/2+50), cc.p(1, 0.5))
	createMenuItem(bg, resPath.."3.png", cc.p(240, 195), function() removeFromParent(self) end)

	local buttonFun = function()
		log("buttonFun")
		local girdId = MPackStruct.girdIdFromGird(gird)
		MPackManager:dress(girdId, replaceGirdId)
		
		NewEquipmentLayer.showList = {}
		removeFromParent(self)
	end

	--立即装备
	local menuItem = createMenuItem(bg, "res/component/button/50.png", cc.p(140, 0), buttonFun)
	local labelSpr = createSprite(menuItem, resPath.."6.png", cc.p(menuItem:getContentSize().width/2, menuItem:getContentSize().height/2), cc.p(0.5, 0.5))
	self.countDownLabel = createLabel(labelSpr, "("..self.autoActionTime..")", cc.p(labelSpr:getContentSize().width-5, 0), cc.p(0, 0), 18, true, nil, nil, MColor.green)
	menuItem:blink()
	--战斗力
	local fightBg = createSprite(bg, resPath.."7.png", cc.p(140, 25), cc.p(0.5, 0))
	local  labelAtlas = cc.LabelAtlas:_create(battle, "res/component/number/10.png", 20, 26, string.byte('0'))
	fightBg:addChild(labelAtlas)
	labelAtlas:setAnchorPoint(cc.p(0, 0.5))
	labelAtlas:setPosition(130, 18)
	createSprite(bg, resPath.."4.png", cc.p(170, 260), cc.p(0.5, 0.5))
	
	createSprite(labelAtlas, "res/group/arrows/1.png", cc.p(labelAtlas:getContentSize().width+5, 3), cc.p(0, 0))

	--特效
	---local animate = tutoAddAnimation(menuItem, cc.p(menuItem:getContentSize().width/2, menuItem:getContentSize().height/2), TUTO_ANIMATE_TYPE_BUTTON)
	--animate:setContentSize(cc.size(200, 65))
	--scaleToTarget(animate, menuItem)

	local protoId = MPackStruct.protoIdFromGird(gird)
	if protoId then
		local Mprop = require( "src/layers/bag/prop")
		local MpropOp = require("src/config/propOp")
  		local iconSpr = Mprop.new({protoId = protoId})
  		bg:addChild(iconSpr)
  		iconSpr:setPosition(cc.p(135, 140))
  		local nameStr = MpropOp.name(protoId)
  		createLabel(bg, nameStr, cc.p(135, 85), cc.p(0.5, 0.5), 24, nil, nil, nil, MpropOp.nameColor(protoId))
	end

	local function countDownFunc()
		self.autoActionTime = self.autoActionTime - 1
		if self.autoActionTime <= 0 then
			buttonFun()
		else
			self.countDownLabel:setString("("..self.autoActionTime..")")
		end
	end

	startTimerAction(self, 1, true, countDownFunc)

	if self:isOnList(protoId) then
		startTimerAction(self, 0.1, false, function() removeFromParent(self) end)
	else
		self:addToShowList(protoId)
	end
end

function NewEquipmentLayer:addToShowList(protoId)
	NewEquipmentLayer.showList[protoId] = true
	--dump(G_NEW_EQUIPMENT_LIST)
end

function NewEquipmentLayer:isOnList(protoId)
	--dump(G_NEW_EQUIPMENT_LIST)
	if NewEquipmentLayer.showList[protoId] == true then
		return true
	else
		return false
	end
end

return NewEquipmentLayer