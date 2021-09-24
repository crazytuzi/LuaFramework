--成就系统分享页面
achievementShareSmallDialog=smallDialog:new()

function achievementShareSmallDialog:new()
	local nc={
        avtLayer=nil,
	}
	setmetatable(nc,self)
	self.__index=self

	return nc
end

function achievementShareSmallDialog:initLayer(share,layerNum)
   	self.isUseAmi=true
    self.isTouch=true
	local scale=0.8
    self.dialogLayer=CCLayer:create()
    self.dialogLayer:setBSwallowsTouches(true)
    self.dialogLayer:setPosition(0,0)

    self.bgLayer=CCLayer:create()

    local function close()
    	self:close()
    end
    local bgSize=CCSizeMake(G_VisibleSize.width*scale,G_VisibleSize.height*scale)
	local dialog=G_getNewDialogBg(bgSize,getlocal("google_achievement"),30,nil,layerNum,true,close)
	dialog:setPosition(getCenterPoint(self.bgLayer))
    self.bgLayer:addChild(dialog)

    self.bgLayer:setAnchorPoint(ccp(0.5,0.5))
    self.bgLayer:ignoreAnchorPointForPosition(false)
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,1)
    
    G_requireLua("game/scene/gamedialog/playerDialog/achievementLayer")
    self.avtLayer=achievementLayer:new()
    local detailLayer=self.avtLayer:initLayer(layerNum,share)
    detailLayer:setScale(scale)
    self.bgLayer:addChild(detailLayer)
    self:show()

    local function touchLuaSpr()
    end
    local touchDialogBg=LuaCCScale9Sprite:createWithSpriteFrameName("newBlackBg.png",CCRect(4,4,1,1),touchLuaSpr)
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(0.7*255)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg)

    sceneGame:addChild(self.dialogLayer,layerNum)
end

function achievementShareSmallDialog:dispose()
    if self.avtLayer and self.avtLayer.dispose then
        self.avtLayer:dispose()
        self.avtLayer=nil
    end
end