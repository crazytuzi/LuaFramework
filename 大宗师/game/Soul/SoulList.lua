 --[[
 --
 -- @authors shan 
 -- @date    2014-05-22 14:56:33
 -- @version 
 --
 --]]

local SoulList = class("SoulList", function ( fadein, fadeout )
	return display.newNode()
end)


function SoulList:ctor( fadein, fadeout )
	self.fadein = fadein
	self.fadeout = fadeout

	self.fadein()

	self:setNodeEventEnabled(true)

	display.addSpriteFramesWithFile("ui/ui_heroList.plist", "ui/ui_heroList.png")
	display.addSpriteFramesWithFile("ui/ui_submap.plist", "ui/ui_submap.png")

	-- bg	
	local boardBg = require("utility.BaseBoard").new()
	local boardWidth = boardBg:getContentSize().width
	local boardHeight =boardBg:getContentSize().height

	boardBg:setPosition(display.width/2, display.height/2)
	self:addChild(boardBg)

	local scrollLayerNode = display.newNode()
	boardBg:addChild(scrollLayerNode)

	display.addSpriteFramesWithFile("")

	local function touchTab(index)
		
		if index == 1 then
			-- 侠客列表 
		    local nodes = {}
		    for index = 1 ,15 do
		    	local heroData = {
		    		name = "hero",
		    		lv = 20,
		    		star = 5,
			    }
		        local subCell = require("game.Soul.SoulListCell").new(index, heroData)            
		        local subNode = require("app.ui.CScrollCell").new(subCell)        
		        nodes[#nodes + 1] =  subNode
		    end

		    local scrollLayer = require("app.ui.CScrollLayer").new({
		            x = display.width*-0.25 ,
		            y = -(boardBg:getPositionY() - boardBg:getContentSize().height*0.91/2) + nodes[1]:getContentSize().height/2,
		            width = display.width ,
		            height = boardBg:getContentSize().height *0.91 ,
		            pageSize = 5,

		            rowSize = 1,
		            nodes = nodes,            
		            bVertical = true,
		            
		        })
		    scrollLayerNode:removeAllChildren()
		    scrollLayerNode:addChild(scrollLayer)
		elseif index == 2 then
			-- 残魂列表 
		    local nodes = {}
		    for index = 1 ,15 do
		    	local heroData = {
		    		name = "hero",
		    		lv = 20,
		    		star = 5,
			    }
		        local subCell = require("game.Soul.SoulListCell").new(index, heroData)            
		        local subNode = require("app.ui.CScrollCell").new(subCell)        
		        nodes[#nodes + 1] =  subNode
		    end

		    local scrollLayer = require("app.ui.CScrollLayer").new({
		            x = display.width*-0.25 ,
		            y = -(boardBg:getPositionY() - boardBg:getContentSize().height*0.91/2) + nodes[1]:getContentSize().height/2,
		            width = display.width ,
		            height = boardBg:getContentSize().height *0.91 ,
		            pageSize = 5,

		            rowSize = 1,
		            nodes = nodes,            
		            bVertical = true,
		            
		        })
		    scrollLayerNode:removeAllChildren()
		    scrollLayerNode:addChild(scrollLayer)
				
		end
	end
	touchTab(1)
	local tab = require("utility.BaseTab").new({
		tabs = {"#SoulList_hero.png","#SoulList_soul.png"},
		tabListener = touchTab
		})
	tab:setPosition(boardWidth*-0.3 ,boardHeight*0.49)
	boardBg:addChild(tab,100)
	
    -- 出售
	local sellBtn = require("utility.CommonButton").new({
		img = "#SoulList_sell.png",
		listener = function ( ... )
			
		end
		})
	sellBtn:setPosition(boardBg:getContentSize().width/3-sellBtn:getContentSize().width, boardBg:getContentSize().height/2 - sellBtn:getContentSize().height/5)
	boardBg:addChild(sellBtn)

	-- 扩展
	local extendBtn = require("utility.CommonButton").new({
		img = "#SoulList_extend.png",
		listener = function ( ... )
			
		end
		})
	extendBtn:setPosition(boardBg:getContentSize().width/3, boardBg:getContentSize().height/2 - extendBtn:getContentSize().height/5)
	boardBg:addChild(extendBtn)


	-- back
	local backBtn = require("utility.CommonButton").new({
		img = "#f_win_back.png",
		listener = function ( ... )
			self:removeSelf()
		end
		})
	backBtn:setPosition(-boardBg:getContentSize().width/2, boardBg:getContentSize().height/2 - backBtn:getContentSize().height/5)
	boardBg:addChild(backBtn)




end




function SoulList:onExit()
	-- body
	self.fadeout()
	display.removeSpriteFramesWithFile("ui/ui_herolist.plist", "ui/ui_herolist.png")
	display.removeSpriteFramesWithFile("ui/ui_submap.plist", "ui/ui_submap.png")
end

return SoulList