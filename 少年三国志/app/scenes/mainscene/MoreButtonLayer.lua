local FunctionLevelConst = require "app.const.FunctionLevelConst"

local MoreButtonLayer = class("MoreButtonLayer", UFCCSModelLayer)

function MoreButtonLayer.create()
    return MoreButtonLayer.new("ui_layout/mainscene_MoreButtonLayer.json")
end

function MoreButtonLayer:ctor(...)
    
    self.super.ctor(self, ...)
    
    self:registerTouchEvent(false,true,0)
    self:adapterWithScreen()
    local appstoreVersion = (G_Setting:get("appstore_version") == "1")
    if appstoreVersion then    
--        self:showWidgetByName("ImageView_6586_7",false)
        local tujianBtn = self:getWidgetByName("ImageView_HandBook")
        local settingBtn = self:getWidgetByName("ImageView_Setting")
        if not tujianBtn then
            return
        end
        local x,y = tujianBtn:getPosition()
        tujianBtn:setVisible(false)
        if settingBtn then
            settingBtn:setPositionX(x)
            settingBtn:setPositionY(y)
        end
    end
end

function MoreButtonLayer:onLayerEnter()
    
    -- -- 计算一下size，因为觉醒商店在未开启之前不可见，但是它占了一行所以这个时候该一下高度
    -- if not G_moduleUnlock:isModuleUnlock(FunctionLevelConst.AWAKEN) then
    --     local imgBg = self:getImageViewByName("ImageView_Bg")
    --     local size = imgBg:getSize()
    --     self:getImageViewByName("ImageView_Bg"):setSize(CCSizeMake(size.width, size.height - 105))  -- 105大概是空一行的高度
    --     self:showWidgetByName("ImageView_AwakenShop", false)
    -- end
    
    -- -- TODO:默认是在觉醒之后开放的
    -- if not G_moduleUnlock:isModuleUnlock(FunctionLevelConst.TITLE) then
    --     self:showWidgetByName("Image_View_Title", false)
    -- end

    -- -- 武将变身
    -- if not G_moduleUnlock:isModuleUnlock(FunctionLevelConst.KNIGHT_TRANSFORM) then
    --     self:showWidgetByName("ImageView_KnightTransform", false)
    -- end
end

function MoreButtonLayer:onTouchBegin(x,y)
    local _panel = self:getImageViewByName("ImageView_Bg")
    local pt = _panel:getParent():convertToNodeSpace(ccp(x,y))
    local _rendSprite = _panel:getVirtualRenderer()
    _rendSprite = tolua.cast(_rendSprite,SCALE9SPRITE)
    
    -- 计算锚点
    local anchorPoint = _panel:getAnchorPoint()
    local size = _rendSprite:getPreferredSize()
    local origin = _panel:boundingBox().origin
    
    -- 由于锚点位置不在ccp(0,0) 需要重新构建图片的显示区域
    local rect = CCRect(origin.x-size.width*anchorPoint.x,origin.y,size.width,size.height)

    if not G_WP8.CCRectContainPt(rect, pt) then
    --if  not rect:containsPoint(pt) then
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_MAINSCENE_CLOSEMOREBTN, nil, false,nil)
        --self:hideMoreButton()
    end
end

function MoreButtonLayer:hideMoreButton( ... )
    local _panel = self:getImageViewByName("ImageView_Bg")
    local array = CCArray:create()
    array:addObject(CCScaleTo:create(0.2,0.1))
    array:addObject(CCCallFunc:create(handler(self,self.closeLayer)))
    _panel:runAction(CCSequence:create(array))
end

function MoreButtonLayer:closeLayer()
    self:setVisible(false)
end

function MoreButtonLayer:getButtonPanel()
    return self:getPanelByName("Panel_button")
end

function MoreButtonLayer:setBgHeight(height)
    local imgBg = self:getImageViewByName("ImageView_Bg")
    local size = imgBg:getSize()
    imgBg:setSize(CCSizeMake(size.width, 105*height+53))
end

-- function MoreButtonLayer:showChatMsgDirtyFlag( isDirty )
--     self:showWidgetByName("Image_tip_chat", isDirty)
-- end

return MoreButtonLayer

