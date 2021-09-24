allianceCityPreviewDialog=smallDialog:new()

function allianceCityPreviewDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function allianceCityPreviewDialog:showPreviewDialog(layerNum,istouch,isuseami,callBack,titleStr,parent)
	local sd=allianceCityPreviewDialog:new()
    sd:initPreviewDialog(layerNum,istouch,isuseami,callBack,titleStr,parent)
    return sd
end

function allianceCityPreviewDialog:initPreviewDialog(layerNum,istouch,isuseami,pCallBack,titleStr,parent)
	self.isTouch=istouch
    self.isUseAmi=isuseami
    self.layerNum=layerNum
    self.parent=parent
    local nameFontSize=30

    base:addNeedRefresh(self)

    local function tmpFunc()
    end
    local rrect=CCRect(0, 50, 1, 1)
    self.dialogLayer=CCLayer:create()
    self.dialogLayer:setTouchEnabled(true)
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true)

    local function touchLuaSpr()
        PlayEffect(audioCfg.mouseClick)
        self:close()
    end
    local touchDialogBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(255)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1)

    local dialogBg=G_getNewDialogBg2(CCSizeMake(520,420),self.layerNum,tmpFunc,titleStr,25)
    self.dialogLayer:addChild(dialogBg,2)
    dialogBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2)
    self.bgLayer=dialogBg

    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGB565)
    local previewSp=CCSprite:create("scene/acityCreatePreview.jpg")
    previewSp:setPosition(getCenterPoint(dialogBg))
    self.bgLayer:addChild(previewSp,2)
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

    self:show()

    local function closeFunc()
        PlayEffect(audioCfg.mouseClick)
        self:close()
    end
    G_addForbidForSmallDialog(self.dialogLayer,dialogBg,-(layerNum-1)*20-3,closeFunc)

    local dialogSize=dialogBg:getContentSize()

    local dialogBg2=LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg2.png",CCRect(20, 20, 1, 1),function ()end)
    dialogBg2:setContentSize(CCSizeMake(previewSp:getContentSize().width+30,previewSp:getContentSize().height+30))
    dialogBg2:setPosition(getCenterPoint(self.bgLayer))
    self.bgLayer:addChild(dialogBg2)

    G_addArrowPrompt(self.bgLayer,nil,-80)

    sceneGame:addChild(self.dialogLayer,layerNum)

    return self.dialogLayer

end

function allianceCityPreviewDialog:dispose()
    CCTextureCache:sharedTextureCache():removeTextureForKey("scene/acityCreatePreview.jpg")
end