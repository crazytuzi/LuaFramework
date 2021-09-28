local SellHeroCell = class("SellHeroCell", function (data)	
	-- display.addSpriteFramesWithFile("ui/ui_herolist.plist", "ui/ui_herolist.png")
	return display.newSprite("#herolist_board.png")
end)

function SellHeroCell:ctor(data)

    self.starNum = data.star
    print("st num".. self.starNum)
	display.addSpriteFramesWithFile("ui/ui_submap.plist", "ui/ui_submap.png")
	local bgWidth = self:getContentSize().width 
	local bgHeight = self:getContentSize().height
    local changeSellHeroNum = data.changeSellHeroNum

	self.cellIndex = data.heroIndex
	self:setPosition(display.right + 227,0)

    local headIcon = display.newSprite("#submap_icon.png")
    headIcon:setPosition(headIcon:getContentSize().width/2, self:getContentSize().height*0.6)
    headIcon:setScale(0.8)
    self:addChild(headIcon)


    -- hero name
    local heroName = ui.newTTFLabel({
        x = headIcon:getContentSize().width*1,
        y = self:getContentSize().height/2,
        align = ui.TEXT_ALIGN_LEFT,
        text = data.name,
        font = "Baoli",
        color = FONT_COLOR.PURPLE,
        size = 34

    })

    self:addChild(heroName)

    -- hero lv
    local heroLv = ui.newTTFLabel({
        x = headIcon:getPositionX() - headIcon:getContentSize().width*0.4,
        y = headIcon:getPositionY() - headIcon:getContentSize().height/2,
        align = ui.TEXT_ALIGN_LEFT,
        text = "Lv:" .. data.lv,
        font = "Baoli",
        color = FONT_COLOR.LIGHT_ORANGE,
        size = 26

    })
    self:addChild(heroLv)

    local priceBg = display.newSprite("#submap_text_bg.png", x, y)
    priceBg:setPosition(bgWidth*0.65,bgHeight*0.4)
    priceBg:setScaleX(0.5)
    self:addChild(priceBg)

    local priceTTF = ui.newTTFLabel({
        text = "银币",
        size = 26,
        -- color = FONT_COLOR.YELLOW,
        x = bgWidth*0.45,
        y = bgHeight*0.4
        })
    priceTTF:setAnchorPoint(ccp(0, 0.5))
    self:addChild(priceTTF)

    local priceNum = ui.newTTFLabel({
        text = 99999,
        size = 26,
        color = FONT_COLOR.ORANGE,
        x = priceTTF:getPositionX()+priceTTF:getContentSize().width*0.4,
        y = priceTTF:getPositionY()
        })
    priceNum:setAnchorPoint(ccp(0, 0.5))
    self:addChild(priceNum)
    

	for i=1,data.star do
		local stars = display.newSprite("#f_win_star.png")
		stars:setPosition(self:getContentSize().width*0.52 + 0.8*(i-1)*stars:getContentSize().width, self:getContentSize().height*0.8)
		stars:setScale(0.8) 
		self:addChild(stars)
	end

    self.selBtn = nil 
    self.unseleBtn = nil 

    self.selBtn = ui.newImageMenuItem({
        image = "#herolist_selected.png",
        listener = function ( )
            self.selBtn:setVisible(false)
            self.unseleBtn:setVisible(true)
            changeSellHeroNum(-1)            
        end
        })
    self.selBtn:setVisible(false)
    self.selBtn:setPosition(bgWidth*0.9,bgHeight*0.45)
    self:addChild(ui.newMenu({self.selBtn}))


    self.unseleBtn = ui.newImageMenuItem({
        image = "#herolist_select_bg.png",
        listener = function ()
            self.selBtn:setVisible(true)
            self.unseleBtn:setVisible(false)
            changeSellHeroNum(1)
        end
        })
    self.unseleBtn:setPosition(bgWidth*0.9,bgHeight*0.45)
    self:addChild(ui.newMenu({self.unseleBtn}))

	self:runEnterAnim()

end

function SellHeroCell:beTouched()
	print(self.cellIndex)
	
end

function SellHeroCell:onExit()
	-- display.removeSpriteFramesWithFile("submap/submap.plist", "submap/submap.png")
	-- display.removeSpriteFramesWithFile("ui/ui_herolist.plist", "ui/ui_herolist.png")
end

function SellHeroCell:runEnterAnim(  )
	local delayTime = self.cellIndex*0.15
    local sequence = transition.sequence({
        CCCallFuncN:create(function ( )
            self:setPosition(CCPoint((self:getContentSize().width/2 + display.width/2),self:getPositionY()))
        end),
        CCDelayTime:create(delayTime),CCMoveBy:create(0.3, CCPoint(-(self:getContentSize().width/2 + display.width/2), 0))})
    self:runAction(sequence)
end

function SellHeroCell:getStarNum()
    return self.starNum
end

function SellHeroCell:setSeled()
    self.selBtn:setVisible(true)
    self.unseleBtn:setVisible(false)
end



return SellHeroCell