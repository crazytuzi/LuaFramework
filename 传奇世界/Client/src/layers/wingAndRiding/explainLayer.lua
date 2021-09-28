local ExplainLayer = class("ExplainLayer", function() return cc.Layer:create() end )

function ExplainLayer:ctor(type)
	local pathCommon = "res/wingAndRiding/common/"
	local pathWing = "res/wingAndRiding/wing/"
	local pathRiding = "res/wingAndRiding/riding/"
	local path

	local addSprite = createSprite
	self.type = type

	if self.type == wingAndRidingType.WR_TYPE_WING then
		path = pathWing
	elseif self.type == wingAndRidingType.WR_TYPE_RIDING then
		path = pathRiding
	elseif self.type == wingAndRidingType.WR_TYPE_ZHJ then
		path = "res/layers/beautywoman/zhj/"
	elseif self.type == wingAndRidingType.WR_TYPE_ZHR then 
		path = "res/layers/beautywoman/zhr/"
	end 

	--local masking = cc.LayerColor:create(cc.c4b(0, 0, 0, 100))
	--self:addChild(masking)

	local bg = addSprite(self, "res/common/38.png", cc.p(g_scrSize.width/2, g_scrSize.height/2))
	local titleBg1 = addSprite(bg, pathCommon.."2.png", cc.p(bg:getContentSize().width/2, 380), cc.p(0.5, 0))
	addSprite(titleBg1, path.."2.png", cc.p(titleBg1:getContentSize().width/2, titleBg1:getContentSize().height/2), cc.p(0.5, 0.5))
	local titleBg2 = addSprite(bg, pathCommon.."2.png", cc.p(bg:getContentSize().width/2, 215), cc.p(0.5, 0))
	addSprite(titleBg2, pathCommon.."1.png", cc.p(titleBg2:getContentSize().width/2, titleBg2:getContentSize().height/2), cc.p(0.5, 0.5))

	local x, y = 40, 377
	local fontColor = MColor.white
	if self.type == wingAndRidingType.WR_TYPE_WING then
		createLabel(bg, game.getStrByKey("wr_explain_wing_line_1"), cc.p(40, 375), cc.p(0, 1), 20, nil, nil, nil, MColor.yellow, nil, nil, MColor.black)
		createLabel(bg, game.getStrByKey("wr_explain_wing_line_2"), cc.p(40, 350), cc.p(0, 1), 20, nil, nil, nil, MColor.white, nil, nil, MColor.black)
		createLabel(bg, game.getStrByKey("wr_explain_wing_line_3"), cc.p(40, 320), cc.p(0, 1), 20, nil, nil, nil, MColor.yellow, nil, nil, MColor.black)
		createLabel(bg, game.getStrByKey("wr_explain_wing_line_4"), cc.p(40, 295), cc.p(0, 1), 20, nil, nil, nil, MColor.white, nil, nil, MColor.black)
	elseif self.type == wingAndRidingType.WR_TYPE_RIDING then
		createLabel(bg, game.getStrByKey("wr_explain_ride_line_1"), cc.p(40, 375), cc.p(0, 1), 20, nil, nil, nil, MColor.yellow, nil, nil, MColor.black)
		createLabel(bg, game.getStrByKey("wr_explain_ride_line_2"), cc.p(40, 350), cc.p(0, 1), 20, nil, nil, nil, MColor.white, nil, nil, MColor.black)
		createLabel(bg, game.getStrByKey("wr_explain_ride_line_3"), cc.p(40, 320), cc.p(0, 1), 20, nil, nil, nil, MColor.yellow, nil, nil, MColor.black)
		createLabel(bg, game.getStrByKey("wr_explain_ride_line_4"), cc.p(40, 295), cc.p(0, 1), 20, nil, nil, nil, MColor.white, nil, nil, MColor.black)
	elseif self.type == wingAndRidingType.WR_TYPE_ZHJ then
		createLabel(bg, game.getStrByKey("wr_explain_zhj_line_1"), cc.p(40, 375), cc.p(0, 1), 20, nil, nil, nil, MColor.yellow, nil, nil, MColor.black)
		createLabel(bg, game.getStrByKey("wr_explain_zhj_line_2"), cc.p(40, 350), cc.p(0, 1), 20, nil, nil, nil, MColor.white, nil, nil, MColor.black)
		createLabel(bg, game.getStrByKey("wr_explain_zhj_line_3"), cc.p(40, 320), cc.p(0, 1), 20, nil, nil, nil, MColor.yellow, nil, nil, MColor.black)
		createLabel(bg, game.getStrByKey("wr_explain_zhj_line_4"), cc.p(40, 295), cc.p(0, 1), 20, nil, nil, nil, MColor.white, nil, nil, MColor.black)
	elseif self.type == wingAndRidingType.WR_TYPE_ZHR then
		createLabel(bg, game.getStrByKey("wr_explain_zhr_line_1"), cc.p(40, 375), cc.p(0, 1), 20, nil, nil, nil, MColor.yellow, nil, nil, MColor.black)
		createLabel(bg, game.getStrByKey("wr_explain_zhr_line_2"), cc.p(40, 350), cc.p(0, 1), 20, nil, nil, nil, MColor.white, nil, nil, MColor.black)
		createLabel(bg, game.getStrByKey("wr_explain_zhr_line_3"), cc.p(40, 320), cc.p(0, 1), 20, nil, nil, nil, MColor.yellow, nil, nil, MColor.black)
		createLabel(bg, game.getStrByKey("wr_explain_zhr_line_4"), cc.p(40, 295), cc.p(0, 1), 20, nil, nil, nil, MColor.white, nil, nil, MColor.black)

	end
	createLabel(bg, game.getStrByKey("wr_explain_common_line_1"), cc.p(40, 215), cc.p(0, 1), 20, nil, nil, nil, MColor.yellow, nil, nil, MColor.black)
	createLabel(bg, game.getStrByKey("wr_explain_common_line_2"), cc.p(40, 190), cc.p(0, 1), 20, nil, nil, nil, MColor.white, nil, nil, MColor.black)
	createLabel(bg, game.getStrByKey("wr_explain_common_line_3"), cc.p(40, 160), cc.p(0, 1), 20, nil, nil, nil, MColor.yellow, nil, nil, MColor.black)--
	createLabel(bg, game.getStrByKey("wr_explain_common_line_4"), cc.p(40, 135), cc.p(0, 1), 20, nil, nil, nil, MColor.white, nil, nil, MColor.black)
	createLabel(bg, game.getStrByKey("wr_explain_common_line_5"), cc.p(40, 80), cc.p(0, 1), 20, nil, nil, nil, MColor.yellow, nil, nil, MColor.black)--
	createLabel(bg, game.getStrByKey("wr_explain_common_line_6"), cc.p(40, 55), cc.p(0, 1), 20, nil, nil, nil, MColor.white, nil, nil, MColor.black)
	
	local closeFunc = function() 
	   	self:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 0), cc.CallFunc:create(function() removeFromParent(self) end)))	
	end

	createMenuItem(bg, "res/common/13.png", cc.p(660, 400), closeFunc)

	SwallowTouches(self)
	self:setScale(0.01)
    self:runAction(cc.ScaleTo:create(0.2, 1))
end

return ExplainLayer