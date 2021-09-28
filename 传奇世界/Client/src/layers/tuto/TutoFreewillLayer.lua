local TutoFreewillLayer = class("TutoFreewillLayer", function() return cc.Layer:create() end )

require("src/layers/tuto/TutoFunction")

local resPath = "res/tuto/images/"

function TutoFreewillLayer:ctor(tutoInfo, protoId)
	log("TutoFreewillLayer protoId"..protoId)
	local bg = createSprite(self, resPath.."2.png", cc.p(display.width-90, display.height/2+50), cc.p(1, 0.5))
	createMenuItem(bg, resPath.."3.png", cc.p(240, 195), function() tutoSetState(tutoInfo, TUTO_STATE_FINISH) removeFromParent(self) end)

	local getIsEquipment = function(protoId)
		local cate = MPackStruct:getCategoryByPropId(protoId)
		return (cate == MPackStruct.eEquipment)
	end

	local buttonFun = function()
		log("buttonFun")
		local bag = MPackManager:getPack(MPackStruct.eBag)
		local num, girdId = bag:countByProtoId(protoId)
		--local cate = MPackStruct:getCategoryByPropId(protoId)
		if getIsEquipment(protoId) then
			MPackManager:dress(girdId)
		else
			MPackManager:useByProtoId(protoId)
		end
		removeFromParent(self)
		tutoSetState(tutoInfo, TUTO_STATE_FINISH)
	end

	local getFight = function(protoId)
		local bag = MPackManager:getPack(MPackStruct.eBag)
		local num, girdId = bag:countByProtoId(protoId)
		local gird = bag:getGirdByGirdId(girdId)
		return MPackStruct.attrFromGird(gird, MPackStruct.eAttrCombatPower)
	end

	local isEquipment = getIsEquipment(protoId)
	local menuItem
	if isEquipment then
		--立即装备
		menuItem = createMenuItem(bg, "res/common/6.png", cc.p(140, 0), buttonFun)
		createSprite(menuItem, resPath.."6.png", cc.p(94, 23.5), cc.p(0.5, 0.5))
		--战斗力
		local fightBg = createSprite(bg, resPath.."7.png", cc.p(140, 25), cc.p(0.5, 0))
		local  labelAtlas = cc.LabelAtlas:_create(getFight(protoId), "res/component/number/3.png", 35, 51, string.byte('0'))
		fightBg:addChild(labelAtlas)
		labelAtlas:setAnchorPoint(cc.p(0, 0.5))
		labelAtlas:setPosition(130, 18)
		createSprite(bg, resPath.."4.png", cc.p(170, 260), cc.p(0.5, 0.5))
	else
		--立即使用
		menuItem = createMenuItem(bg, "res/common/6.png", cc.p(140, 45), buttonFun)
		createSprite(menuItem, resPath.."9.png", cc.p(94, 23.5), cc.p(0.5, 0.5))
	end

	--特效
	tutoAddAnimation(menuItem, cc.p(94, 23.5), TUTO_ANIMATE_TYPE_BUTTON)
	if protoId then
		-- local MpropOp = require("src/config/propOp")
		-- local path = MpropOp.icon(protoId)
		-- local iconSpr = createSprite(bg, path, cc.p(140, 140), cc.p(0.5, 0.5))
		-- createSprite(iconSpr, "", cc.p(140, 140), cc.p(0.5, 0.5))
		local Mprop = require( "src/layers/bag/prop" )
		local MpropOp = require("src/config/propOp")
  		local iconSpr = Mprop.new({protoId = protoId})
  		bg:addChild(iconSpr)
  		iconSpr:setPosition(cc.p(135, 140))
  		local nameStr = MpropOp.name(protoId)
  		createLabel(bg, nameStr, cc.p(135, 85), cc.p(0.5, 0.5), 24, nil, nil, nil, MpropOp.nameColor(protoId))
	end
end

return TutoFreewillLayer