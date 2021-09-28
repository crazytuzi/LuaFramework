-- 修改角色名或者修改头像框按钮弹出层

local ChangeFrameOrNameBtnPopupLayer = class("ChangeFrameOrNameBtnPopupLayer", UFCCSNormalLayer)

local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
local FunctionLevelConst = require "app.const.FunctionLevelConst"

ChangeFrameOrNameBtnPopupLayer.OFFSET_X = 50

function ChangeFrameOrNameBtnPopupLayer.create( posX, posY, ... )
	local layer = ChangeFrameOrNameBtnPopupLayer.new("ui_layout/createrole_ChangeNameOrFrameBtnLayer.json", nil, posX, posY, ...)
	return layer
end


function ChangeFrameOrNameBtnPopupLayer:ctor( json, func, posX, posY, ... )
    self:adapterWithScreen()
    self._btnsPosX = posX
    self._btnsPosY = posY

    self:getImageViewByName("Image_Bg"):setPositionXY(self._btnsPosX + ChangeFrameOrNameBtnPopupLayer.OFFSET_X, self._btnsPosY)

    self.super.ctor(self, json)
end


function ChangeFrameOrNameBtnPopupLayer:onLayerEnter( ... )
    EffectSingleMoving.run(self:getImageViewByName("Image_Bg"), "smoving_bounce")
    self:registerTouchEvent(false, true, 0)

    self:registerBtnClickEvent("Button_Change_Name", handler(self, self._changeNameBtnClicked))
    self:registerBtnClickEvent("Button_Change_Frame", handler(self, self._changeFrameBtnClicked))

    if G_moduleUnlock:isModuleUnlock(FunctionLevelConst.SET_AVATAR) then
        local result = G_moduleUnlock:setModuleEntered(FunctionLevelConst.SET_AVATAR)
        if result then
            uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_AVATAR_FRAME_FUNCTION, nil, false)
        end
    end
    
    if G_moduleUnlock:isModuleUnlock(FunctionLevelConst.CHANGE_ROLE_NAME) then
        local result = G_moduleUnlock:setModuleEntered(FunctionLevelConst.CHANGE_ROLE_NAME)
        if result then
            uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_AVATAR_FRAME_FUNCTION, nil, false)
        end
    end
end

function ChangeFrameOrNameBtnPopupLayer:_changeNameBtnClicked(  )
    if not G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.CHANGE_ROLE_NAME) then
        return
    end

	require("app.scenes.changename.ChangeNameLayer").show()
	-- uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_ROLE_INFO_CLOSE_CHANGE_NAMEFRAME_BTN_LAYER, nil, false, nil)
    self:close()
end


function ChangeFrameOrNameBtnPopupLayer:_changeFrameBtnClicked(  )
	if not G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.SET_AVATAR) then
        return
    end

    local layer = require("app.scenes.common.RoleAvatarFrameListLayer").create()    
    uf_sceneManager:getCurScene():addChild(layer)
    -- uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_ROLE_INFO_CLOSE_CHANGE_NAMEFRAME_BTN_LAYER, nil, false, nil)
    self:close()
end


function ChangeFrameOrNameBtnPopupLayer:onTouchBegin( x, y )
	local bgPanel = self:getImageViewByName("Image_Bg")
    local pt = bgPanel:getParent():convertToNodeSpace(ccp(x,y))
    local renderSprite = bgPanel:getVirtualRenderer()
    renderSprite = tolua.cast(renderSprite, SCALE9SPRITE)
    
    -- 计算锚点
    local anchorPoint = bgPanel:getAnchorPoint()
    local size = renderSprite:getPreferredSize()
    local origin = bgPanel:boundingBox().origin
    
    -- 由于锚点位置不在ccp(0,0) 需要重新构建图片的显示区域
    local rect = CCRect(origin.x-size.width*anchorPoint.x, origin.y - size.height*anchorPoint.y, size.width, size.height)

    if not G_WP8.CCRectContainPt(rect, pt) then
        -- uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_ROLE_INFO_CLOSE_CHANGE_NAMEFRAME_BTN_LAYER, nil, false, nil)
        self:close()
    end
end


return ChangeFrameOrNameBtnPopupLayer