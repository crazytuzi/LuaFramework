local ChoseStarLvlLayer = class("ChoseStarLvlLayer", function (param)
	return display.newNode()
end)



function ChoseStarLvlLayer:ctor(param)
	local selStarsListener = param.selStarsListener
	display.addSpriteFramesWithFile("ui/ui_common_button.plist", "ui/ui_common_button.png")

	display.addSpriteFramesWithFile("ui/ui_submap.plist", "ui/ui_submap.png")
	local boardWidth = display.width * 0.7
	local boardHeight = display.height * 0.68
	local boardBg = require("utility.BasePopUpLayer").new({
		boardSize = CCSize(boardWidth, boardHeight)})
	self:addChild(boardBg)

	local curX = boardWidth*0.01
	local curY = boardHeight*0.33
	local offsetY = 0
	local starTable = {0,0,0,0,0}
	local unSels ={}
	local sels = {}

	for index =  1 ,5 do
		local barBg = display.newSprite("#herolist_board.png")
		barBg:setScaleX(0.6)
		barBg:setScaleY(0.7)
		barBg:setPosition(curX,curY)
		boardBg:addChild(barBg)

		local starsNum = ui.newTTFLabel({
			text = index,
			size = 32
			})
		starsNum:setPosition(boardWidth*-0.3,curY)
		boardBg:addChild(starsNum)

		local stars = display.newSprite("#f_win_star.png")
		stars:setPosition(boardWidth*-0.2,curY)
		boardBg:addChild(stars)

		local selBtn = nil 
	    local unselBtn = nil 

	    selBtn = ui.newImageMenuItem({
	        image = "#herolist_selected.png",
	        listener = function ()
	            selBtn:setVisible(false)
	            unselBtn:setVisible(true)
	            starTable[index] = 0          
	        end
	        })
		selBtn:registerScriptTapHandler(function (tag)			
			selBtn:setVisible(false)
	        unselBtn:setVisible(true)			
			starTable[index] = 0 
		end)
	    selBtn:setVisible(false)
	    selBtn:setPosition(boardWidth*0.2,curY)
	    self:addChild(ui.newMenu({selBtn}))
	    sels[#sels + 1] =selBtn


	    unselBtn = ui.newImageMenuItem({
	        image = "#herolist_select_bg.png",
	        listener = function ()
	            selBtn:setVisible(true)
	            unselBtn:setVisible(false)
	            starTable[index] = 1
	        end
	        })
	    unselBtn:setPosition(boardWidth*0.2,curY)
	    self:addChild(ui.newMenu({unselBtn}))
	    unSels[#unSels + 1] = unselBtn

		offsetY = barBg:getContentSize().height*0.7
		curY = curY - offsetY
	end

	local backBtn = require("utility.CommonButton").new({
		img = "#herolist_close.png",

		listener = function ( ... )
			self:removeSelf()
		end
		})
	backBtn:setPosition(boardWidth*0.3,boardHeight*0.35)
	boardBg:addChild(backBtn)

	local choseTTF = ui.newBMFontLabel({
        text = "选择全部",
        font = "fonts/font_buttons.fnt",
        })
	choseTTF:setScale(0.6)

	local choseAllBtn = require("utility.CommonButton").new({
		img = "#com_btn_large_red.png",
		font = choseTTF,
		listener = function ()
			for i=1,#unSels do
				unSels[i]:setVisible(false)
				sels[i]:setVisible(true)
				starTable[i]=1
			end
			
			
		end
		})
	choseAllBtn:setPosition(-boardWidth*0.41,-boardHeight*0.44)
	boardBg:addChild(choseAllBtn)

	local confirmTTF = ui.newBMFontLabel({
        text = "确定",
        font = "fonts/font_buttons.fnt",
        })
	confirmTTF:setScale(0.6)

	local confirmBtn = require("utility.CommonButton").new({
		img = "#com_btn_large_red.png",
		font = confirmTTF,
		listener = function ()
			selStarsListener(starTable)
			self:removeSelf()
		end
		})
	confirmBtn:setPosition(boardWidth*0.03,-boardHeight*0.44)
	boardBg:addChild(confirmBtn)
	



	
	

end
return ChoseStarLvlLayer