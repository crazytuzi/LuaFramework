championshipWarCheckTroopDialog = smallDialog:new()

function championshipWarCheckTroopDialog:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    return nc
end

function championshipWarCheckTroopDialog:showTroopDialog(troopsInfo, titleStr, layerNum)
    local sd = championshipWarCheckTroopDialog:new()
    sd:initTroopDialog(troopsInfo, titleStr, layerNum)
end

function championshipWarCheckTroopDialog:initTroopDialog(troopsInfo, titleStr, layerNum)
    self.isTouch = false
    self.isUseAmi = true
    self.layerNum = layerNum
    self.dialogLayer = CCLayer:create()
    self.dialogLayer:setBSwallowsTouches(true)
    
    local function close()
        self:close()
    end
    self.bgSize = CCSizeMake(616, 750)
    local dialogBg = G_getNewDialogBg(self.bgSize, titleStr, 28, nil, layerNum, true, close)
    self.bgLayer = dialogBg
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer, 2)
    self.dialogLayer:setTouchPriority(-(layerNum - 1) * 20 - 1)
    
    require "luascript/script/componet/checkTroopsLayer"
    local sd = checkTroopsLayer:new()
    local troopsLayer = sd:createTroopsLayer(nil, troopsInfo, layerNum)
    troopsLayer:setAnchorPoint(ccp(0.5,1))
    troopsLayer:setPosition(self.bgSize.width/2,self.bgSize.height-70)
    self.bgLayer:addChild(troopsLayer)
    
    self:show()
    
    --确定
    local btnScale, priority = 0.8, -(layerNum - 1) * 20 - 4
    G_createBotton(dialogBg, ccp(self.bgSize.width / 2, 60), {getlocal("ok")}, "newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", close, btnScale, priority)
    
    local function touchLuaSpr()
        
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), touchLuaSpr)
    touchDialogBg:setTouchPriority(-(layerNum - 1) * 20 - 1)
    local rect = CCSizeMake(640, G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(250)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg, 1)
    
    sceneGame:addChild(self.dialogLayer, layerNum)
    self.dialogLayer:setPosition(ccp(0, 0))
end

function championshipWarCheckTroopDialog:dispose()
    if G_editLayer[self.type] and G_editLayer[self.type].dispose then
        G_editLayer[self.type]:dispose()
    end
    self.type = nil
    self.bgSize = nil
    self = nil
end
