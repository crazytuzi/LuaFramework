creatRolePage={}

function creatRolePage:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function creatRolePage:init(img,bigIconScale,bigIconH)
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum

    local nowBigIcon=CCSprite:create(img)
    self.bgLayer:addChild(nowBigIcon)
    nowBigIcon:setPosition(self.bgLayer:getContentSize().width/2,bigIconH)
    nowBigIcon:setScale(bigIconScale)

    return self.bgLayer
end


function creatRolePage:dispose()
	self.bgLayer:removeFromParentAndCleanup(true)
	self.bgLayer=nil
    self.layerNum=nil
end
