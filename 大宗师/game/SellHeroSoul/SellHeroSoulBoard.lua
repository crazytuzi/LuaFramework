 --[[
 --
 -- @authors shan 
 -- @date    2014-05-22 14:56:33
 -- @version 
 --
 --]]

local SellHeroSoulBoard = class("SellHeroSoulBoard", function (setBgVisible,typeIndex)
	return display.newNode()
end)


function SellHeroSoulBoard:ctor(setBgVisible,typeIndex)

	self:setNodeEventEnabled(true)


	display.addSpriteFramesWithFile("ui/ui_herolist.plist", "ui/ui_herolist.png")

	display.addSpriteFramesWithFile("ui/ui_submap.plist", "ui/ui_submap.png")
    display.addSpriteFramesWithFile("ui/ui_common_button.plist", "ui/ui_common_button.png")

	-- bg	
	local boardBg = require("utility.BaseBoard").new()
	local boardWidth = boardBg:getContentSize().width
	local boardHeight =boardBg:getContentSize().height

	boardBg:setPosition(display.width/2, display.height*0.45)
	self:addChild(boardBg)

	local choiceDetailNode = display.newNode()
	choiceDetailNode:setPosition(boardWidth*-0.17,boardHeight*-0.13)
    self:addChild(choiceDetailNode)

    local choiceDetailBg = display.newSprite("#submap_text_bg.png", x, y)
    choiceDetailBg:setPosition(boardWidth*0.6,boardHeight*0.4)
    choiceDetailBg:setScaleX(1.2)
    choiceDetailNode:addChild(choiceDetailBg)

    local choiceDetailLable = ui.newTTFLabel({
    	text = "已选择侠客:",
    	size = 18,
    	color = FONT_COLOR.LIGHT_ORANGE
    	})
   	choiceDetailLable:setAnchorPoint(ccp(0, 0.5))
    choiceDetailLable:setPosition(choiceDetailBg:getPositionX()-boardWidth*0.33,choiceDetailBg:getPositionY()) 
    choiceDetailNode:addChild(choiceDetailLable)

    local choiceDetailNum = ui.newTTFLabel({
    	text = 0,
    	size = 18,
    	color = FONT_COLOR.RED
    	})
    choiceDetailNum:setAnchorPoint(ccp(0, 0.5))
    choiceDetailNum:setPosition(choiceDetailLable:getPositionX()+choiceDetailLable:getContentSize().width,choiceDetailLable:getPositionY())
    choiceDetailNode:addChild(choiceDetailNum)

     local zongjiLable = ui.newTTFLabel({
        text = "总计出售:",
        size = 18,
        color = FONT_COLOR.LIGHT_ORANGE
        })
    zongjiLable:setPosition(choiceDetailBg:getPositionX(),choiceDetailBg:getPositionY())
    choiceDetailNode:addChild(zongjiLable)

    local yinbiLable = ui.newTTFLabel({
        text = "银币",
        size = 18,
        })
    yinbiLable:setPosition(zongjiLable:getPositionX()+zongjiLable:getContentSize().width*0.75 , choiceDetailBg:getPositionY())
    choiceDetailNode:addChild(yinbiLable)

    local priceNum = ui.newTTFLabel({
        text = 0,
        size = 18,
        color = FONT_COLOR.ORANGE
        })
    priceNum:setAnchorPoint(ccp(0, 0.5))
    priceNum:setPosition(yinbiLable:getPositionX()+yinbiLable:getContentSize().width*0.75,choiceDetailBg:getPositionY())
    choiceDetailNode:addChild(priceNum)

    local sellHeroNum = 0
    function changeXiakeNum(num)
    	if sellHeroNum+num >= 0 then 
    		sellHeroNum = sellHeroNum + num
    		choiceDetailNum:setString(sellHeroNum)
            priceNum:setString(sellHeroNum*99999)
    	end
    end

   

    local sellFont = ui.newBMFontLabel({
        text = "出 售",
        font = "fonts/font_buttons.fnt",
        })
    sellFont:setScale(0.6)


    local chushouBtn = require("utility.CommonButton").new({
        img = "#com_btn_red.png",
        font = sellFont,
        listener = function ( ... )

            
        end
        })
    chushouBtn:setPosition(choiceDetailBg:getPositionX()+choiceDetailBg:getContentSize().width*0.6, choiceDetailBg:getPositionY() + boardHeight*-0.055)
    choiceDetailNode:addChild(chushouBtn)


	local scrollLayerNode = display.newNode()
	boardBg:addChild(scrollLayerNode)


	-- 侠客列表 
    local nodes = {}
    local heroes = {}
    for index = 1 ,15 do
    	local heroData = {
    		name = "东方不败",
    		lv = 20,
    		star = index % 5 + 1,
    		heroIndex =index,
    		changeSellHeroNum = changeXiakeNum

	    }
        local subCell = require("game.SellHeroSoul.SellHeroCell").new(heroData) 
        heroes[#heroes + 1] = subCell           
        local subNode = require("app.ui.CScrollCell").new(subCell)        
        nodes[#nodes + 1] =  subNode
    end

    function choseHeroByStars(starTable)
    	for i =1 ,#starTable do
    		if starTable[i] == 1 then
    			for heroID = 1,#heroes do 
    				-- print("sta num"..heroes[heroID]:getStarNum())
    				if heroes[heroID]:getStarNum() == i then 

    					heroes[heroID]:setSeled()
                        changeXiakeNum(1)
    				end 
    			end

    		end
    	end

    end

    local sellByStarFont = ui.newBMFontLabel({
        text = "按星级出售",
        font = "fonts/font_buttons.fnt",
        })
    sellByStarFont:setScale(0.5)

    local sellByStars = require("utility.CommonButton").new({
    img = "#com_btn_large_red.png",
    font = sellByStarFont,
    listener = function ( ... )
    	local sellByStarBoard = require("game.SellHeroSoul.ChoseStarLvlLayer").new({
    		selStarsListener = choseHeroByStars})
    	sellByStarBoard:setPosition(display.width/2, display.height*0.45)
    	self:addChild(sellByStarBoard)
        
    end
    })
	sellByStars:setPosition(boardWidth*0.05, boardHeight*0.48)
	boardBg:addChild(sellByStars)


    local heroScrollLayer = require("app.ui.CScrollLayer").new({
            x = display.width*-0.25 ,
            y = -(boardBg:getPositionY() - boardBg:getContentSize().height*0.91/2) + nodes[1]:getContentSize().height*0.37-5,
            width = display.width ,
            height = boardBg:getContentSize().height *0.81 ,
            pageSize = 5,

            rowSize = 1,
            nodes = nodes,            
            bVertical = true,
            
        })
    scrollLayerNode:removeAllChildren()
    scrollLayerNode:addChild(heroScrollLayer)
	
	
	
	-- back
	local backBtn = require("utility.CommonButton").new({
		img = "#f_win_back.png",
		listener = function ( ... )
			
			setBgVisible()
			self:removeSelf()
		end
		})
	backBtn:setPosition(boardBg:getContentSize().width*0.3,boardBg:getContentSize().height/2 - backBtn:getContentSize().height/5)
	boardBg:addChild(backBtn)

	

end




function SellHeroSoulBoard:onExit()
	-- body
	-- display.removeSpriteFramesWithFile("ui/ui_herolist.plist", "ui/ui_herolist.png")

end

return SellHeroSoulBoard