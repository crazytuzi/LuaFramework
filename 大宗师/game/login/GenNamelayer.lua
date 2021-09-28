 --[[
 --
 -- @authors shan 
 -- @date    2014-06-18 13:31:43
 -- @version 
 --
 --]]

local data_playername_first_name = require("data.data_playername_first_name")
local data_playername_male = require("data.data_playername_male")
local data_playername_female = require("data.data_playername_female")


local GenNamelayer = class("GenName", function ( ... )
	display.addSpriteFramesWithFile("ui/ui_login.plist", "ui/ui_login.png")
	display.addSpriteFramesWithFile("ui/ui_common_button.plist", "ui/ui_common_button.png")
	return display.newLayer("GenNamelayer")
end)


function GenNamelayer:ctor( ... )
	
	local bg = display.newScale9Sprite("#login_bg.png", 0, 0, CCSize(display.width*0.9, display.height*0.35) )
	bg:setPosition(display.width/2, display.height*0.6)
	self:addChild(bg)

	local title = display.newSprite("#login_input_title.png")
	title:setPosition(bg:getContentSize().width/2, bg:getContentSize().height - title:getContentSize().height*1.5)
	bg:addChild(title)

	local inputBg = display.newScale9Sprite("#login_input_bg.png")
	inputBg:setPreferredSize(CCSize(bg:getContentSize().width*0.5, inputBg:getContentSize().height))
	inputBg:setPosition(bg:getContentSize().width/2, bg:getContentSize().height/2)
	bg:addChild(inputBg)

	self.playerName = ui.newTTFLabel({
		text = "",
		x = inputBg:getContentSize().width/2,
		y = inputBg:getContentSize().height/2,
		size = 32,
		font = FONTS_NAME.font_haibao,
		color = display.COLOR_BLACK,
		align = ui.TEXT_ALIGN_CENTER
		})
	inputBg:addChild(self.playerName)

	local dice = require("utility.CommonButton").new({
		img = "#login_shaizi.png",
		listener = function ( ... )
			self.playerName:setString(self:genName() )
		end
		})
	dice:setPosition(inputBg:getPositionX() + inputBg:getContentSize().width/2 , bg:getContentSize().height/2 - dice:getContentSize().height/2)
	bg:addChild(dice)

	local okBtn = require("utility.CommonButton").new({
		img = "#com_btn_red.png",
		listener = function ( ... )
			if(self.playerName:getString() ~= "") then
				CCUserDefault:sharedUserDefault():setStringForKey("playerName", self.playerName:getString())
				CCUserDefault:sharedUserDefault():setStringForKey("accid", os.time())
				CCUserDefault:sharedUserDefault():flush()
				
			    local scene = require("app.scenes.LoginScene").new()
			    display.replaceScene(scene)

			    self:removeSelf()
		    end 
		end
		})
	okBtn:setPosition(bg:getContentSize().width - okBtn:getContentSize().width*1.5, okBtn:getContentSize().height/2)
	bg:addChild(okBtn)
end

function GenNamelayer:init( ... )

end

--[[
	名字要根据性别生成
]]
function GenNamelayer:genName( ... )
	-- local middleName = BaseData_names_2[math.random(1,BaseData_names_2)].name
	local prefixName = ""
	local postfixName = ""

	math.randomseed(tostring(os.time()):reverse():sub(1, 6))  

	prefixName = data_playername_first_name[math.random(1,#data_playername_first_name)].name
	

	if(math.random(0,1) == 1) then
		postfixName = data_playername_male[math.random(1,#data_playername_male)].name
	else
		postfixName = data_playername_female[math.random(1,#data_playername_female)].name
	end



	print(prefixName  .. postfixName)

	return (prefixName  .. postfixName)
end


return GenNamelayer