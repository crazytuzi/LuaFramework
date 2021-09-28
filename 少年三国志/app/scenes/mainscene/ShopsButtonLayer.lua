-- 主界面点击商店按钮展开的带有各种商店按钮的界面

local FunctionLevelConst = require "app.const.FunctionLevelConst"

local ShopsButtonLayer = class("ShopsButtonLayer", UFCCSModelLayer)

function ShopsButtonLayer.create()
    return ShopsButtonLayer.new("ui_layout/mainscene_ShopsButtonLayer.json")
end

function ShopsButtonLayer:ctor(...)
    
    self.super.ctor(self, ...)
    
    self:registerTouchEvent(false,true,0)
    self:adapterWithScreen()    
end

function ShopsButtonLayer:onLayerEnter()
    
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

function ShopsButtonLayer:onTouchBegin(x,y)
    local _panel = self:getImageViewByName("ImageView_Bg")
    local pt = _panel:getParent():convertToNodeSpace(ccp(x,y))
    local _rendSprite = _panel:getVirtualRenderer()
    _rendSprite = tolua.cast(_rendSprite,SCALE9SPRITE)
    
    -- 计算锚点
    local anchorPoint = _panel:getAnchorPoint()
    local size = _rendSprite:getPreferredSize()
    local origin = _panel:boundingBox().origin
    
    -- 由于锚点位置不在ccp(0,0) 需要重新构建图片的显示区域
    local rect = CCRect(origin.x-size.width*anchorPoint.x,origin.y - size.height, size.width, size.height)

    if not G_WP8.CCRectContainPt(rect, pt) then
    --if  not rect:containsPoint(pt) then
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_MAINSCENE_CLOSESHOPSBTN, nil, false,nil)
        --self:hideMoreButton()
    end
end

function ShopsButtonLayer:hideShopsButton( ... )
    local _panel = self:getImageViewByName("ImageView_Bg")
    local array = CCArray:create()
    array:addObject(CCScaleTo:create(0.2,0.1))
    array:addObject(CCCallFunc:create(handler(self,self.closeLayer)))
    _panel:runAction(CCSequence:create(array))
end

function ShopsButtonLayer:closeLayer()
    self:setVisible(false)
end

function ShopsButtonLayer:getButtonPanel()
    return self:getPanelByName("Panel_Shop_Buttons")
end

function ShopsButtonLayer:setBgHeight(height)
    local imgBg = self:getImageViewByName("ImageView_Bg")
    local size = imgBg:getSize()
    imgBg:setSize(CCSizeMake(size.width, 105*height+53))
end

function ShopsButtonLayer:setBgWidth(width)
    __Log("ShopsButtonLayer:setBgWidth width = %d", width)
    local imgBg = self:getImageViewByName("ImageView_Bg")
    local size = imgBg:getSize()
    -- 65   icon中心到所在panel左边的距离
    -- 53   icon宽度的二分之一
    -- 110  相邻两个icon之间的中心距离
    -- 12   最左或最右icon边缘到所在panel边缘的距离 
    local width = 65 + 53 + 110 * (width - 1) + 12

    -- 需要重新设置锚点
    -- 350   panel中有3个icon时，panel的宽度
    -- 0.2  panel中有3个icon时，x轴上锚点
    local anchorX = 348 * 0.2 / width
    imgBg:setAnchorPoint(ccp(anchorX, 1))

    imgBg:setSize(CCSizeMake(width, size.height))
end

-- function ShopsButtonLayer:showChatMsgDirtyFlag( isDirty )
--     self:showWidgetByName("Image_tip_chat", isDirty)
-- end

return ShopsButtonLayer

