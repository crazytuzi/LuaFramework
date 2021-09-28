--

local COMMON_VIEW = 1
local SALE_VIEW = 2
local COLOR_GREEN = ccc3(0, 255, 0) 

local JinJieCell = class("JinJieCell", function (param)
	return CCTableViewCell:new()
end)

function JinJieCell:getContentSize()
	return CCSizeMake(95, 95)
end


function JinJieCell:create(param)
	self.itemIcon = display.newSprite()
	self:addChild(self.itemIcon)
	-- self.itemIcon:setAnchorPoint(ccp(0,0))

	self.hasNum = ui.newTTFLabelWithOutline({
		text = "/99",
		size = 20,
		color = COLOR_GREEN, 
        outlineColor = ccc3(0,0,0),
        font = FONTS_NAME.font_fzcy 
	})
	self:addChild(self.hasNum, 10)

	self.need = ui.newTTFLabelWithOutline({
		text = "88",
		size = 20,
		color = COLOR_GREEN, 
        outlineColor = ccc3(0,0,0),
        font = FONTS_NAME.font_fzcy 
	})
	self:addChild(self.need, 10)
	self.data = param.listData
	self.viewSize = param.viewSize  
	self:refresh(param.id + 1) 
	
	return self
end

function JinJieCell:refresh(id)
	if self.data ~= nil then
		-- dump(self.data)
		self.resId = self.data[id]["id"]
		self.resType = self.data[id]["t"]

		local itemType =ResMgr.ITEM
		if self.resType == 8 then
			itemType = ResMgr.HERO
		elseif self.resType == 4 then
			itemType = ResMgr.EQUIP	
		end


		ResMgr.refreshIcon({id = self.resId,itemBg = self.itemIcon,resType = itemType})
		-- self.itemIcon:setPosition(self.itemIcon:getContentSize().width/2*0.8,self.itemIcon:getContentSize().height/2*0.8)
		-- self.itemIcon:setScale(0.8)
		self.itemIcon:setPosition(self.itemIcon:getContentSize().width / 2, self.viewSize.height / 2) 
		self.itemIcon:setTouchEnabled(true)

		self.itemIcon:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
			local itemInfo = require("game.Huodong.ItemInformation").new({
                        id = self.resId,
                        type = self.resType                        
                        })

            display.getRunningScene():addChild(itemInfo, 100000)
  		
  		end) 

		 

		local needStr = self.data[id]["n1"]
		local hasNumStr = self.data[id]["n2"] 

		self.hasNum:setString(hasNumStr)
		self.need:setString("/" .. needStr)

		if hasNumStr >= needStr then
			self.hasNum:setColor(COLOR_GREEN)
		else
			self.hasNum:setColor(FONT_COLOR.RED)
		end 

		self.need:setPosition(self:getContentSize().width - 15 - self.need:getContentSize().width/2, 
								self.need:getContentSize().height/2 + 7)

		self.hasNum:setPosition(self.need:getPositionX() - self.need:getContentSize().width/2 - self.hasNum:getContentSize().width/2,
		 								self.need:getPositionY())
	end
	

end

function JinJieCell:runEnterAnim(  )
	local delayTime = self.cellIndex*0.15
    local sequence = transition.sequence({
        CCCallFuncN:create(function ( )
            self:setPosition(CCPoint((self:getContentSize().width/2 + display.width/2),self:getPositionY()))
        end),
        CCDelayTime:create(delayTime),CCMoveBy:create(0.3, CCPoint(-(self:getContentSize().width/2 + display.width/2), 0))})
    self:runAction(sequence)
end



return JinJieCell