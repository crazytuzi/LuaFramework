--[[
军团旗帜属性总览

@author JNK
]]

allianceFlagAttrAllDialog = smallDialog:new()

function allianceFlagAttrAllDialog:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self

    return nc
end

function allianceFlagAttrAllDialog:showFlagAttrAllDialog(layerNum)
    local sd = allianceFlagAttrAllDialog:new()
    sd:initFlagAttrAllDialog(layerNum)
end
    
function allianceFlagAttrAllDialog:initFlagAttrAllDialog(layerNum)
    self.layerNum = layerNum
    
    self.dialogLayer = CCLayer:create()
    self.dialogLayer:setBSwallowsTouches(true)
    local size = CCSizeMake(G_VisibleSizeWidth - 90, 500)
    self.bgSize = size
    local dialogBg = G_getNewDialogBg2(size, layerNum, nil, getlocal("allianceFlagAttrTitle"), 28)
    self.bgLayer = dialogBg
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer, 2)
    self.dialogLayer:setTouchPriority(-(layerNum - 1) * 20 - 1)

    -- 显示属性
    local descArr = allianceVoApi:getFlagUnLockAttr()

    local index = 0
    for k,v in pairs(descArr) do
        local desc = getlocal(buffEffectCfg[tonumber(k)].name)
        local attrNameLb = GetTTFLabel(desc, 22, true)
        attrNameLb:setAnchorPoint(ccp(1, 0.5))
        attrNameLb:setColor(G_ColorWhite)
        attrNameLb:setPosition(self.bgSize.width / 2 - 15, self.bgSize.height - 100 - index * 50)
        self.bgLayer:addChild(attrNameLb, 6)

        desc = "+" .. v .. "%"
        local attrValueLb = GetTTFLabel(desc, 22, true)
        attrValueLb:setAnchorPoint(ccp(0, 0.5))
        attrValueLb:setColor(G_ColorWhite)
        attrValueLb:setPosition(self.bgSize.width / 2 + 15, attrNameLb:getPositionY())
        self.bgLayer:addChild(attrValueLb, 6)

        index = index + 1
    end
    
    self:show()
    
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

     local function closeFunc()
        self:close()
    end
    G_addForbidForSmallDialog(self.dialogLayer,self.bgLayer,-(self.layerNum-1)*20-3,closeFunc)
    
    G_addArrowPrompt(self.bgLayer, nil, -70)
    
    self.dialogLayer:setPosition(ccp(0, 0))
end

function allianceFlagAttrAllDialog:dispose()
end