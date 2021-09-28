 local LimitHeroCell = class(LimitHeroCell, function()
 	return CCTableViewCell:new()
 end)

 function LimitHeroCell:create(idx,viewSize)
 	self.heroList = LimitHeroModel.getHeroList()
 	self.viewSize = viewSize
 	self.heroSprite = display.newSprite()

 	self:addChild(self.heroSprite)
    local flag = 640/1136
    local curFlag = display.width/display.height

    self.heroSprite:setScale(0.85*(flag/curFlag))   

 	self.heroSprite:setTouchEnabled(true)
 	self.heroSprite:setTouchSwallowEnabled(false)
    self.heroSprite:setAnchorPoint(ccp(0.5,0))
    ResMgr.setNodeEvent({
        node = self.heroSprite,
        touchFunc = function()
            self:createHeroInfo() 
        end
        })

	self:refresh(idx)
 	return self
 end

function LimitHeroCell:createHeroInfo()

    local itemInfo = require("game.Huodong.ItemInformation").new({
                id = self.heroResId,
                type =8                      
                })
    display.getRunningScene():addChild(itemInfo, 100000)
end


 function LimitHeroCell:refresh(idx)


	local heroResId = self.heroList[idx+1]

 	self.heroResId = heroResId
 
 	local cardData = ResMgr.getCardData(heroResId)

 	local heroImg = cardData["arr_body"][1]
    local heroPath = CCFileUtils:sharedFileUtils():fullPathForFilename(ResMgr.getLargeImage(heroImg, ResMgr.HERO))
    self.heroSprite:setDisplayFrame(display.newSprite(heroPath):getDisplayFrame())
    self.heroSprite:setPosition(self.viewSize.width/2,0)--self.viewSize.height/2)



 end



 return LimitHeroCell 