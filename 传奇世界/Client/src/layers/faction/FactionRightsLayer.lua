local FactionRightLayer = class("FactionRightLayer", function() return cc.Layer:create() end )

function FactionRightLayer:ctor(factionData)
	self.level = factionData.facLv

    local bg = createSprite(self, "res/common/bg/bg18.png", cc.p(display.cx, display.cy), cc.p(0.5, 0.5))
	self.bg = bg

    createLabel(bg, game.getStrByKey("faction_rights"), cc.p(bg:getContentSize().width/2, bg:getContentSize().height-27), cc.p(0.5, 0.5), 24, true)
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

	local imgBg = createSprite(contentBg, "res/faction/rights.jpg", getCenterPos(contentBg, 0, 0), cc.p(0.5, 0.5))
	self.imgBg = imgBg

	local preBtnFunc = function()
		self.level = self.level - 1
		if self.level <= 1 then
			self.preBtn:setVisible(false)
		end
		self:updateData()
	end
	local preBtn = createMenuItem(imgBg, "res/group/arrows/17-1.png", cc.p(imgBg:getContentSize().width/2-330, imgBg:getContentSize().height/2), preBtnFunc)
	self.preBtn = preBtn
	--preBtn:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveTo:create(0.3, cc.p(display.cx-400-5, 300)), cc.MoveTo:create(0.3, cc.p(display.cx-400, 300)))))
	--preBtn:setOpacity(255*0.5)

	local nextBtnFunc = function()
		self.level = self.level + 1
		if self.level >= 9 then
			self.nextBtn:setVisible(false)
		end
		self:updateData()
	end
	local nextBtn = createMenuItem(imgBg, "res/group/arrows/17.png", cc.p(imgBg:getContentSize().width/2+330, imgBg:getContentSize().height/2), nextBtnFunc)
	self.nextBtn = nextBtn
	--nextBtn:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveTo:create(0.3, cc.p(display.cx+400+5, 300)), cc.MoveTo:create(0.3, cc.p(display.cx+400, 300)))))
	--nextBtn:setOpacity(255*0.5)

	local infoNode = cc.Node:create()
	imgBg:addChild(infoNode)
	infoNode:setPosition(cc.p(0, 0))
	self.infoNode = infoNode

	self:updateData()
end

function FactionRightLayer:updateData()
	self:updateUI()
end

function FactionRightLayer:updateUI()
	self.infoNode:removeAllChildren()

	createLabel(self.infoNode, string.format(game.getStrByKey("faction_level_title"), self.level), cc.p(self.imgBg:getContentSize().width/2, 365), cc.p(0.5, 0.5), 28, false, nil, nil, MColor.lable_yellow)

	local info = getConfigItemByKey("FactionUpdate", "FacLevel", self.level, "root")

	local richText = require("src/RichText").new(self.infoNode, cc.p(300, 310), cc.size(420, 30), cc.p(0, 1), 35, 22, MColor.lable_yellow)
	richText:addText(info, MColor.yellow_gray, false)
	richText:format()

	self.preBtn:setVisible(true)
	self.nextBtn:setVisible(true)

	if self.level <= 1 then
		self.preBtn:setVisible(false)
	end

	if self.level >= 9 then
		self.nextBtn:setVisible(false)
	end
end

return FactionRightLayer