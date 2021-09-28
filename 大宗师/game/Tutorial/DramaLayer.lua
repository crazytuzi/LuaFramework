 -- 剧情表 等松鹏那边完事后 可生成
local data_drama_drama = require("data.data_drama_drama")

local CUR_IMAGE = 1
local FUR_IMAGE = 2


local DramaLayer = class("DramaLayer", function (data)
	return require("utility.ShadeLayer").new()
end)
function DramaLayer:ctor(id,endFunc)

	self:setNodeEventEnabled(true)
	display.addSpriteFramesWithFile("ui/ui_tutorial.plist", "ui/ui_tutorial.png")
	self:initPos()
	local dramaData = data_drama_drama[id]
	local dramaType = dramaData.drama_type

	local dramaSkip = dramaData.isSkip

	local opacity = dramaData.opacity
	if opacity ~= nil then
		self:setOpacity(opacity)
	end

	self.isTouch = false

	if dramaSkip == 1 then
		self:setTouchEnabled(true)
		self:setTouchFunc(function() 
			self.isTouch = true
		    endFunc()
        	self:removeSelf()
		end)
	end	

	if dramaType == 1 then --等于1 则是动画剧情

		local animName = dramaData.anim

		local dramaAnim = ResMgr.createArma({
        resType = ResMgr.UI_EFFECT,
        armaName = animName,
        finishFunc = function()
        -- 动画播放完毕特效
        	if self.isTouch ~= true then
	        	endFunc()
	        	self:removeSelf()        
	        end  
        end,
        isRetain = false
    	})
    	dramaAnim:setPosition(display.width/2, display.height/2)
    	self:addChild(dramaAnim)
	else
		--否则  则是普通的对话剧情
		local chatStr = dramaData.intro


		local cur_large = dramaData.cur_large
		local cur_posId = dramaData.cur_pos or 1
		local cur_offsetX = dramaData.cur_offsetX or 0
		local cur_offsetY = dramaData.cur_offsetY or 0 
		local cur_over = dramaData.cur_over
		local cur_scale = dramaData.cur_scale or 1000
		local cur_opacity = dramaData.cur_opacity or 100	

		local fur_large = dramaData.fur_large
		local fur_posId = dramaData.fur_pos
		local fur_offsetX = dramaData.fur_offsetX or 0
		local fur_offsetY = dramaData.fur_offsetY or 0
		local fur_over = dramaData.fur_over
		local fur_scale = dramaData.fur_scale or 1000
		local fur_opacity = dramaData.fur_opacity or 100
		


		local speakerName = dramaData.cur_name or "无名氏"
		if speakerName == 1 then
			speakerName = game.player.m_name
		end
		

		self.chatBox = display.newScale9Sprite("#chat_box.png",0,0, CCSize(display.width,208)) 
		self:addChild(self.chatBox,100)
		self.chatBox:setPosition(display.width/2,  display.height*0.3)
		-- setNodeSize(self.chatBox, display.width)

		self:addHeroImage(cur_large,cur_posId,cur_over,cur_offsetX,cur_offsetY,cur_scale,cur_opacity,CUR_IMAGE)	
		self:addHeroImage(fur_large,fur_posId,fur_over,fur_offsetX,fur_offsetY,fur_scale,fur_opacity,FUR_IMAGE)

		--内容
		local dim = CCSize(display.width-30, self.chatBox:getContentSize().height-30)


		if chatStr ~= nil then 

			local dramaTTF = ui.newTTFLabel({
				text = chatStr,
				color = ccc3(54,4,5),--FONT_COLOR.DARK_RED,
				align = ui.TEXT_ALIGN_LEFT ,
				valign = ui.TEXT_VALIGN_TOP,
				size = 32,
				font = FONTS_NAME.font_fzcy,
				dimensions =dim
				})
			-- dramaTTF:setAnchorPoint(0.5,1)
			dramaTTF:setPosition(self.chatBox:getPositionX(),self.chatBox:getPositionY()-20)
			self:addChild(dramaTTF,105)
		end

		local nameBg = display.newSprite("#chat_name.png")
		nameBg:setPosition(self.imageX[cur_posId],self.chatBox:getPositionY() - 7 + self.chatBox:getContentSize().height/2 + nameBg:getContentSize().height/2)
		self:addChild(nameBg,95)

		if speakerName ~= nil then
			local charName = ui.newTTFLabel({
		            text = speakerName,
		            size = 32,
		            color = ccc3(254,205,102),
		            outlineColor = ccc3(255,204,106),
		            font = FONTS_NAME.font_haibao,
		            align = ui.TEXT_ALIGN_CENTER
		            })
			charName:setPosition(nameBg:getContentSize().width/2,nameBg:getContentSize().height*0.4)
			nameBg:addChild(charName)
		end

		self:setTouchFunc(function()
			
			endFunc()
			self:removeSelf()
			end)
	end
	
end

function DramaLayer:addHeroImage(large,pos,over,offsetX,offsetY,scale,opacity,isCur)

	local data_card_card = require("data.data_card_card")

	local speakerImage = large

	local imageOffsetX = display.width  * offsetX/100000
	local imageOffsetY = display.height * offsetY/100000
	
	if speakerImage == 1 then
		local cls = game.player.m_class or 0
		
		if  game.player.m_gender == 1 then
			--男主角
			speakerImage = data_card_card[1]["arr_body"][cls+1]  ---"nanzhujue"
		else
			--女主角
			speakerImage = data_card_card[2]["arr_body"][cls+1] 
		end
	end

	local isFlip = false
	if over == 1 then
		isFlip = true
	end

	if speakerImage ~= nil and speakerImage ~= "" then
		local imagePath = "hero/large/"..speakerImage..".png"
		local heroImage = display.newSprite(imagePath)
		if isCur ~= 1 then 		
			heroImage:setOpacity(opacity)
		end
		heroImage:setScale(scale/1000)
		heroImage:setFlipX(isFlip)
		heroImage:setPosition(self.imageX[pos] + imageOffsetX ,imageOffsetY + self.chatBox:getPositionY() + self.chatBox:getContentSize().height/2+40)
		heroImage:setAnchorPoint(ccp(0.5,0.33))
		self:addChild(heroImage,90)
	end

end


function DramaLayer:onExit()
	
end

function DramaLayer:initPos()
	local heightRate = 0.3
	self.imageX = {0.2*display.width,0.5*display.width,0.8*display.width}


end

return DramaLayer