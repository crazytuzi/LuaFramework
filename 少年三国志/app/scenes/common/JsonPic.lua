
local JsonPic = {}


function JsonPic.createJsonPic( resId, parentWidget, name, hasShadow,functionList )
    if type(resId) ~= "number" or parentWidget == nil then
        return nil 
    end

    local picPath = functionList.getPic(resId)
    local sp = ImageView:create()
    sp:setName(name or "default_image_name")
    sp:loadTexture(picPath, UI_TEX_TYPE_LOCAL)
    local config = decodeJsonFile(functionList.getPicConfig(resId))
    
    if hasShadow then
        local shadow = CCSprite:create(  G_Path.getKnightShadow()  )
        shadow:setPosition(ccp(tonumber(config.shadow_x - config.x),  tonumber(config.shadow_y - config.y)))
        sp:addNode(shadow, -3)    
    end

    sp:setPosition(ccp(tonumber(config.x), tonumber(config.y)))
    parentWidget:addChild(sp)

    return sp
end

function JsonPic.createJsonButton( resId, parentWidget, name, layer, func, hasShadow, hasDisable,functionList )
    if type(resId) ~= "number" or parentWidget == nil then
        return nil 
    end

    local picPath = functionList.getPic(resId)
    local sp = Button:create()
    sp:setName(name or "default_image_name")
    sp:setTouchEnabled(true)

    

    sp:loadTextureNormal(picPath, UI_TEX_TYPE_LOCAL)
    if hasDisable then 
        sp:loadTextureDisabled(picPath, UI_TEX_TYPE_LOCAL)
    end


    local config = decodeJsonFile(functionList.getPicConfig(resId))

    sp:setPosition(ccp(tonumber(config.x), tonumber(config.y)))
    parentWidget:addChild(sp)




    if hasShadow then
        local shadow = CCSprite:create(  G_Path.getKnightShadow()  )
        shadow:setPosition(ccp(tonumber(config.shadow_x - config.x),  tonumber(config.shadow_y - config.y)))
        sp:addNode(shadow, -3)    

    end

    


    if layer and type(func) == "function" then
        layer:registerBtnClickEvent(name or "default_image_name", func)
    end

    return sp
end


function JsonPic.createJsonNode( resId, name, hasShadow,functionList)
    -- todo 先使用ccnode,后面可能要改成widget?
    local node = display.newNode()

    local picPath = functionList.getPic(resId)
    local sp = ImageView:create()
    sp:setName(name or "default_image_name")
    sp:loadTexture(picPath, UI_TEX_TYPE_LOCAL)
    local config = decodeJsonFile(functionList.getPicConfig(resId))
    if hasShadow then
        local shadow = CCSprite:create(  G_Path.getKnightShadow()  )
        shadow:setPosition(ccp(tonumber(config.shadow_x - config.x),  tonumber(config.shadow_y - config.y)))
        sp:addNode(shadow, -3)    
    end
    sp:setPosition(ccp(tonumber(config.x), tonumber(config.y)))
    node.imageNode = sp
    node:addChild(sp)
    return node
end

function JsonPic.createBattleJsonPic( resId, parentWidget, name, hasShadow,functionList )
    if type(resId) ~= "number" or parentWidget == nil then
        return nil 
    end

    local picPath = G_Path.getBattleConfigImage(functionList.dir,resId..".png")
    local sp = ImageView:create()
    sp:setName(name or "default_image_name")
    sp:loadTexture(picPath, UI_TEX_TYPE_LOCAL)
    local config = decodeJsonFile(G_Path.getBattleConfig(functionList.dir,resId.."_fight"))
    
    if hasShadow then
        local shadow = CCSprite:create(  G_Path.getKnightShadow()  )
        shadow:setPosition(ccp(-30,  -100))
        sp:addNode(shadow, -3)    
    end

    sp:setPosition(ccp(tonumber(config.x), tonumber(config.y)))
    parentWidget:addChild(sp)

    return sp
end

function JsonPic.createBattleJsonButton( resId, parentWidget, name, layer, func, hasShadow, hasDisable,functionList )
    if type(resId) ~= "number" or parentWidget == nil then
        return nil 
    end

    local picPath = G_Path.getBattleConfigImage(functionList.dir,resId..".png")
    local sp = Button:create()
    sp:setName(name or "default_image_name")
    sp:setTouchEnabled(true)

    sp:loadTextureNormal(picPath, UI_TEX_TYPE_LOCAL)
    if hasDisable then 
        sp:loadTextureDisabled(picPath, UI_TEX_TYPE_LOCAL)
    end

    local config = decodeJsonFile(G_Path.getBattleConfig(functionList.dir,resId.."_fight"))
    sp:setPosition(ccp(tonumber(config.x), tonumber(config.y)))
    parentWidget:addChild(sp)

    if hasShadow then
        local shadow = CCSprite:create(  G_Path.getKnightShadow()  )
        shadow:setPosition(ccp(tonumber(config.shadow_x - config.x),  tonumber(config.shadow_y - config.y)))
        sp:addNode(shadow, -3)
    end

    if layer and type(func) == "function" then
        layer:registerBtnClickEvent(name or "default_image_name", func)
    end

    return sp
end

--cutBottom为底部裁剪比例, 默认为0 , 表现不裁剪, 取值范围[0,1] ,比如0.2 表示裁剪底部20%
--wholeBody 默认为false, 如果为true,表示 只裁剪卡牌下面部分, 上面,左边,右边不裁剪
-- function KnightPic.getHalfNode( resId, cutBottom, wholeBody)
--     local node = CCClippingNode:create()

--     local picPath = G_Path.getKnightPic(resId)
--     local config = decodeJsonFile(G_Path.getKnightPicConfig(resId))

--     --设置遮罩大小
--     local maskNode = CCDrawNode:create()
--     local pointarr1 = CCPointArray:create(4)
--     local halfh = config.half_h
--     local halfw = config.half_w
--     local halfx = config.half_x
--     local halfy = config.half_y

--     if cutBottom == nil then
--         cutBottom = 0
--     end

--     if cutBottom < 0 then
--         cutBottom = 0
--     end

--     if cutBottom > 1 then
--         cutBottom = 1
--     end

--     halfy = halfy + cutBottom*halfh/2
--     halfh = halfh * (1-cutBottom)


--     pointarr1:add(ccp(-halfw/2, -halfh/2))
--     pointarr1:add(ccp(-halfw/2, halfh/2))
--     pointarr1:add(ccp(halfw/2, halfh/2))
--     pointarr1:add(ccp(halfw/2, -halfh/2))
--     maskNode:drawPolygon(pointarr1:fetchPoints(), 4, ccc4f(1.0, 1.0, 0, 0.5), 1, ccc4f(0.1, 1, 0.1, 1) )
--     node:setStencil(maskNode)



--     local sp = ImageView:create()
--     sp:loadTexture(picPath, UI_TEX_TYPE_LOCAL)

--     sp:setPosition(ccp(tonumber(config.x-halfx), tonumber(config.y-halfy)))
--     node:addChild(sp)


--     local wrapperNode = display.newNode()
--     wrapperNode:addChild(node)

--     return wrapperNode
-- end


--cutBottom为底部裁剪比例, 默认为0 , 表现不裁剪, 取值范围[0,1] ,比如0.2 表示裁剪底部20%
--wholeBody 默认为false, 如果为true,表示 只裁剪卡牌下面部分, 上面,左边,右边不裁剪
function JsonPic.getHalfNode( resId, cutBottom, wholeBody,functionList)
    local picPath = functionList.getPic(resId)
    local config = decodeJsonFile(functionList.getPicConfig(resId))

    local sp = CCSprite:create(picPath)
    local size = sp:getContentSize()

--先校对halfw halfh, halfy, halfx
    local halfh = config.half_h
    local halfw = config.half_w
    local halfx = config.half_x
    local halfy = config.half_y
    if cutBottom == nil then
        cutBottom = 0
    end

    if cutBottom < 0 then
        cutBottom = 0
    end

    if cutBottom > 1 then
        cutBottom = 1
    end

    halfy = halfy + cutBottom*halfh/2
    halfh = halfh * (1-cutBottom)

-- 再根据wholeBody 判断是否不裁剪上面,左边,右边
    if wholeBody then
        local x = 0
        local y = 0 
        local w = size.width
        local h = size.height- (size.height/2 + (halfy - config.y - halfh/2))
        -- print("halfy=" .. halfy)
        -- print("halfh=" .. halfh)

        -- print("height=" .. size.height)

        -- print("h=" .. h)

        --裁剪后的图片中心点在全局坐标系的位置
        local cx = config.x
        local cy = config.y + (size.height - h )/2


        sp:setTextureRect(CCRectMake(x, y, w, h))
    

        sp:setPosition(ccp(  cx - halfx,  cy - halfy ))

    else 
        --判断矩形是否有超过本身图片尺寸, 做一定的调整
        local x = halfx - halfw/2 - config.x + size.width/2
        local y = size.height/2 - (halfy + halfh/2 - config.y)
        local w = halfw
        local h = halfh
        if  x + w > size.width then
            w = size.width - x  
        end
        if  y + h > size.height then
            h = size.height - y  
        end
        -- print("h2=" .. h)

        sp:setTextureRect(CCRectMake(x, y, w, h))

        sp:setPosition(ccp( (w -halfw)/2,  (halfh -h)/2 ))
      
    end

    local wrapperNode = display.newNode()

    wrapperNode:addChild(sp,1,1)

    return wrapperNode
   
end


return JsonPic