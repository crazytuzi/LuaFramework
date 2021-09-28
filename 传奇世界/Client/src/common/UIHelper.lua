--Author:        bishaoqing
--DateTime:      2016-04-26 16:16:31
--Region:        UI设置管理，统一管理，多用于动态下载图片  
local UIHelper = class("UIHelper")

function UIHelper:ctor( ... )
    -- body
end

--根据key设置文本
function UIHelper:SetStringByKey( uiWidget, strKey, ... )
    -- body
    self:SetString(uiWidget, game.getStrByKey(strKey), ...)
end

--设置文本
function UIHelper:SetString( uiWidget, strContent, bNumber, bOutline, outlineColor, outlineSize, bSystem, bLog )
    -- body
    if not IsNodeValid(uiWidget) then
        return
    end
    local fontName = g_font_path
    local strText = strContent or "";
    bNumber = bNumber or false

    local desc = uiWidget:getDescription();
    if desc ~= nil then
        if desc == "TextBMFont" then
            return ;
        end
        local label;
        local fontSize;
        -- fontName = self:getFontName(bNumber);
        local ttfConfig = {};
        local ttfColor
        if desc == "Label" or desc == "TextAtlas" or desc == "TextField" then
            label = tolua.cast( uiWidget:getVirtualRenderer(), "cc.Label" );
            ttfConfig = label:getTTFConfig() or ttfConfig;
            fontSize = uiWidget:getFontSize();
            ttfColor = label:getTextColor()
        elseif desc == "Button" then
            label = uiWidget:getButtonTextLabel();
            ttfConfig = label:getTTFConfig() or ttfConfig;
            fontSize = uiWidget:getTitleFontSize();
            ttfColor = uiWidget:getTitleColor()
        end
        local function Set()
            -- 是否是系统字体  
            if bSystem then
                label:setSystemFontName(g_font_path)
                label:setSystemFontSize(fontSize)
            else
                ttfConfig.fontFilePath = fontName;
                ttfConfig.fontSize = fontSize;
                label:setTTFConfig(ttfConfig);
            end
            if desc == "Label" or desc == "TextAtlas" or desc == "TextBMFont" or desc == "TextField" then
                uiWidget:setString(strText);
            elseif desc == "Button" then
                uiWidget:setTitleText(strText);
            end
            if bOutline ~= nil and bOutline == true then
                local color = outlineColor or cc.c4b(116,66,4,255);
                local size = outlineSize or 1;
                label:enableOutline(color, size);
            end
            local stSize = label:getContentSize();
            local stOriginSize = uiWidget:getContentSize();
        end
        if not uiWidget:isIgnoreContentAdaptWithSize() and "TextField" ~= desc then
            -- if "Label" == desc and nil ~= CGameFunc.TextScaleChangedWithSize then
            --     CGameFunc:TextScaleChangedWithSize( uiWidget );
            -- end
            local stOriginSize = uiWidget:getContentSize();
            local strName = uiWidget:getName() or "";
            for i=1,10 do
                Set();
                local stSize;
                -- if nil == CGameFunc.GetLabelRealSize then
                    stSize = label:getContentSize();
                -- else
                    -- stSize = CGameFunc:GetLabelRealSize( label );
                -- end
                label:setName( uiWidget:getName() );
                if stSize.width <= stOriginSize.width 
                    and ( stSize.height <= stOriginSize.height or math.abs(stSize.height - stOriginSize.height) <= 10 ) then
                    break;
                end
                fontSize = fontSize - 1;
                if fontSize <= 0 then
                    break;
                end
            end
            Set();
        else
            Set();
        end
    end
end

--ImageView设置纹理
function UIHelper:LoadTexture(imgView, filePath, async)   
    local function _loadTexture(_path, _async)
        if not IsNodeValid(imgView) or not cc.FileUtils:getInstance():isFileExist(_path) then 
            return 
        end

        if not _async then
            imgView:loadTexture(_path);
            return;
        end

        local function addImageAsyncCB()
            if IsNodeValid(imgView) then 
                local virtualRender = imgView:getVirtualRenderer();
                if nil == virtualRender then
                    return;
                end
                local shader = virtualRender:getGLProgram();
                imgView:loadTexture(_path);
                virtualRender = imgView:getVirtualRenderer();
                if nil == virtualRender or nil == shader then
                    return;
                end
                virtualRender:setGLProgram(shader);
            end
        end
        cc.Director:getInstance():getTextureCache():addImageAsync(_path, addImageAsyncCB)
    end
    _loadTexture(filePath, async)
end

--CCSprite设置纹理
function UIHelper:LoadSprTexture(spr, filePath, loadFinishCB)   
    if IsNodeValid(spr) and cc.FileUtils:getInstance():isFileExist(filePath) then
        spr:setTexture(filePath)
    end
end

local eEnumButtonState = 
{
    StateNormal = 1,
    StatePressed = 2,
    StateDisabled = 3,
}

--UIButton设置纹理
function UIHelper:LoadButtonTextures(btn, normal, pressed, dis)
    if not IsNodeValid(btn) then
        return false
    end
    
    local function _loadButtonTexture( filePath, iState )
        -- body
        if not filePath then
            return
        end
        if IsNodeValid(btn) and (filePath == "" or cc.FileUtils:getInstance():isFileExist(filePath)) then
            if iState == eEnumButtonState.StateNormal then
                btn:loadTextureNormal(filePath)
            elseif iState == eEnumButtonState.StatePressed then
                btn:loadTexturePressed(filePath)
            elseif iState == eEnumButtonState.StateDisabled then
                btn:loadTextureDisabled(filePath)
            end
        end
    end

    _loadButtonTexture(normal, eEnumButtonState.StateNormal)
    _loadButtonTexture(pressed, eEnumButtonState.StatePressed)
    _loadButtonTexture(dis, eEnumButtonState.StateDisabled)
end

--替换img(根据大小拓扑img，常用于画类似虚线)(2的指数次方的图片才可以使用)
function UIHelper:RepaceImg( pImage, strImage )
    -- body
    if not IsNodeValid(pImage) then
        return
    end
    if nil == strImage then
        strImage = pImage:getTextureFile();
    end
    local stSize = pImage:getContentSize();
    local stAnchorPoint = pImage:getAnchorPoint();
    local stPoint = cc.p( pImage:getPosition() );
    local fScaleX = pImage:getScaleX();
    local fScaleY = pImage:getScaleY();
    local fAngle = pImage:getRotation();

    local pSprite = cc.Sprite:create();
    self:LoadSprTexture( pSprite, strImage );
    
    self:WrapImg(pSprite, stSize);

    pSprite:setAnchorPoint( stAnchorPoint );
    pSprite:setPosition( stPoint );
    pSprite:setScaleX( fScaleX );
    pSprite:setScaleY( fScaleY );
    pSprite:setRotation( fAngle );

    pSprite:setName( pImage:getName() );
    pImage:getParent():addChild( pSprite, pImage:getLocalZOrder() );
    pImage:removeFromParent();

    return pSprite;
end

--拓扑img(2的指数次方的图片才可以使用)
function UIHelper:WrapImg( pSprite, stSize )
    -- body
    if not IsNodeValid(pSprite) then
        return
    end
    pSprite:getTexture():setTexParameters( gl.LINEAR, gl.LINEAR, gl.REPEAT, gl.REPEAT );
    local oRect = pSprite:getTextureRect();
    oRect.width = stSize.width;
    oRect.height = stSize.height;
    pSprite:setTextureRect( oRect );
    return pSprite
end

--把node列表按照对应配置排列好
function UIHelper:SortNodes(nodeList, startx, starty, diffx, diffy)
    local length = #nodeList
    
    for i = 1, length do
        local node = nodeList[i]
        node:setPosition(startx + diffx * (i - 1), starty + diffy * (i - 1))
    end
end

--按钮回弹效果
function UIHelper:ButtonEffect(sender, eventType, oScale)
    if eventType == ccui.TouchEventType.began then
        sender:setScale(0.9 * (oScale or 1))
    elseif eventType ~= ccui.TouchEventType.moved then
        sender:setScale(1.0 * (oScale or 1))
    end
end

---------------------------start-------------------------------------
--自动排列UI:scrollview中子控件位置(按照addchild的顺序)(默认垂直排序，如果是水平排序，bHorizontal填true)
function UIHelper:FixUIScrollView( uiScroll, nPadding, bHorizontal )
    -- body
    --默认垂直方向

    self:SetScrollViewInnerContainerSize( uiScroll, nPadding, bHorizontal );
    self:SortWidgetChildren(uiScroll, nPadding, bHorizontal)
end

--设置UI:scrollview的innersize(默认垂直排序，如果是水平排序，bHorizontal填true)
function UIHelper:SetScrollViewInnerContainerSize(scrollView, nPadding, bHorizontal, extraSpace)
    local scrollViewSize = scrollView:getContentSize()
    nPadding = nPadding or 0
    extraSpace = extraSpace or 0
    local vAllChildren = scrollView:getChildren()

    if bHorizontal then
        local width = 0
        for i,uiCol in ipairs(vAllChildren) do
            local rowSize = uiCol:getContentSize()
            width = width + (rowSize.width + nPadding)
        end
        width = math.max(scrollViewSize.width, width - nPadding + extraSpace)
        scrollView:setInnerContainerSize( cc.size(width, scrollViewSize.height) )
    else
        local height = 0
        for i,uiRow in ipairs(vAllChildren) do
            local rowSize = uiRow:getContentSize()
            height = height + (rowSize.height + nPadding)
        end
        height = math.max(scrollViewSize.height, height - nPadding + extraSpace)
        scrollView:setInnerContainerSize( cc.size(scrollViewSize.width, height) )
    end
end

function UIHelper:SortWidgetChildren( uiScroll, nPadding, bHorizontal )
    -- body
    local arrChild = uiScroll:getChildren();
    
    if bHorizontal then
        local fTotalWidth = uiScroll:getInnerContainerSize().width;
        local fCurWidth = 0;
        for i,uiCol in ipairs(arrChild) do
            local fColWidth = uiCol:getContentSize().width;
            local stOldAnchor = uiCol:getAnchorPoint()
            uiCol:setAnchorPoint(cc.p(0, 0))
            uiCol:setPositionX( fCurWidth );
            uiCol:setAnchorPoint(stOldAnchor)
            fCurWidth = fCurWidth + fColWidth + nPadding;
        end
    else
        local fTotalHeight = uiScroll:getInnerContainerSize().height;
        local fCurHeight = 0
        for i,uiRow in ipairs(arrChild) do
            local fRowHeight = uiRow:getContentSize().height;
            local stOldAnchor = uiRow:getAnchorPoint()
            uiRow:setAnchorPoint(cc.p(0, 1))
            uiRow:setPositionY( fTotalHeight - fCurHeight );
            uiRow:setAnchorPoint(stOldAnchor)
            fCurHeight = fCurHeight + fRowHeight + nPadding
        end
    end
end
-----------------------------end---------------------------------------


---------------------------start-------------------------------------
--自动排列CC:scrollview中子控件位置
function UIHelper:FixScrollView( uiScroll, nPadding, bHorizontal, nFirstPadding )
    -- body
    nPadding = nPadding or 0
    nFirstPadding = nFirstPadding or 0
    self:SetScrollContainerSize(uiScroll, nPadding, bHorizontal, nFirstPadding)
    self:SortChildren(uiScroll, nPadding, bHorizontal, nFirstPadding)
end

--设置CC:scrollview的containner size(默认垂直排序，如果是水平排序，bHorizontal填true)
function UIHelper:SetScrollContainerSize(scrollView, nPadding, bHorizontal, extraSpace)
    local scrollViewSize = scrollView:getViewSize()
    local scrollContainnerContentSize = scrollView:getContainer():getContentSize()
    nPadding = nPadding or 0
    extraSpace = extraSpace or 0
    local vAllChildren = scrollView:getContainer():getChildren()

    if bHorizontal then
        local width = 0
        for i,uiCol in ipairs(vAllChildren) do
            local rowSize = uiCol:getContentSize()
            width = width + (rowSize.width + nPadding)
        end
        width = math.max(scrollViewSize.width, width - nPadding + extraSpace)
        scrollView:getContainer():setContentSize( cc.size(width, scrollContainnerContentSize.height) )
    else
        local height = 0
        for i,uiRow in ipairs(vAllChildren) do
            local rowSize = uiRow:getContentSize()
            height = height + (rowSize.height + nPadding)
        end
        height = math.max(scrollViewSize.height, height - nPadding + extraSpace)
        scrollView:getContainer():setContentSize( cc.size(scrollContainnerContentSize.width, height) )
        scrollView:setContentOffset(cc.p(0, scrollViewSize.height - height))
    end

    scrollView:updateInset()
end

function UIHelper:SortChildren( uiScroll, nPadding, bHorizontal, nFirstPadding )
    -- body
    local arrChild = uiScroll:getContainer():getChildren();
    
    if bHorizontal then
        local fTotalWidth = uiScroll:getContainer():getContentSize().width;
        local fCurWidth = nFirstPadding or 0;
        for i,uiCol in ipairs(arrChild) do
            local fColWidth = uiCol:getContentSize().width;
            -- local stOldAnchor = uiCol:getAnchorPoint()
            uiCol:setAnchorPoint(cc.p(0, 0))
            uiCol:setPositionX( fCurWidth );
            -- uiCol:setAnchorPoint(stOldAnchor)
            fCurWidth = fCurWidth + fColWidth + nPadding;
        end
    else
        local fTotalHeight = uiScroll:getContainer():getContentSize().height;
        local fCurHeight = nFirstPadding or 0
        for i,uiRow in ipairs(arrChild) do
            local fRowHeight = uiRow:getContentSize().height;
            -- local stOldAnchor = uiRow:getAnchorPoint()
            uiRow:setAnchorPoint(cc.p(0, 1))
            uiRow:setPositionY( fTotalHeight - fCurHeight );
            -- uiRow:setAnchorPoint(stOldAnchor)
            fCurHeight = fCurHeight + fRowHeight + nPadding
        end
    end
end
-----------------------------end---------------------------------------


---------------------------start-------------------------------------
--将某个节点下的孩子按指定方向排序
function UIHelper:FixNode( uiNode, nPadding, bHorizontal, extraSpace, bNetive )
    -- body
    if not nPadding then
        nPadding = 0;
    end
    self:SetNodeContentSize(uiNode, nPadding, bHorizontal, extraSpace)
    self:SortNodeChildren(uiNode, nPadding, bHorizontal, bNetive)
end

function UIHelper:SetNodeContentSize(uiNode, nPadding, bHorizontal, extraSpace)
    local stContentSize = uiNode:getContentSize()
    nPadding = nPadding or 0
    extraSpace = extraSpace or 0
    local vAllChildren = uiNode:getChildren()
    local nMaxHeight = stContentSize.height
    local nMaxWidth = stContentSize.width
    if bHorizontal then
        local width = 0
        for i,uiCol in ipairs(vAllChildren) do
            local rowSize = uiCol:getContentSize()
            width = width + (rowSize.width + nPadding)
            local height = rowSize.height
            if height > nMaxHeight then
                nMaxHeight = height
            end
        end
        width = math.max(stContentSize.width, width - nPadding + extraSpace)
        uiNode:setContentSize( cc.size(width, nMaxHeight) )
    else
        local height = 0
        for i,uiRow in ipairs(vAllChildren) do
            local rowSize = uiRow:getContentSize()
            height = height + (rowSize.height + nPadding)
            local width = rowSize.width
            if width > nMaxWidth then
                nMaxWidth = width
            end
        end
        height = math.max(stContentSize.height, height - nPadding + extraSpace)
        uiNode:setContentSize( cc.size(nMaxWidth, height) )
    end
end

function UIHelper:SortNodeChildren( uiNode, nPadding, bHorizontal, bNetive )
    -- body
    local arrChild = uiNode:getChildren();
    nPadding = nPadding or 0
    if bHorizontal then
        local fTotalWidth = uiNode:getContentSize().width;
        local fCurWidth = 0;
        for i,uiCol in ipairs(arrChild) do
            local fColWidth = uiCol:getContentSize().width;
            local stOldAnchor = uiCol:getAnchorPoint()
            uiCol:setAnchorPoint(cc.p(0, 0))
            uiCol:setPositionX( fCurWidth );
            uiCol:setAnchorPoint(stOldAnchor)
            if bNetive then
                fCurWidth = fCurWidth - fColWidth - nPadding;
            else
                fCurWidth = fCurWidth + fColWidth + nPadding;
            end
        end
    else
        local fTotalHeight = uiNode:getContentSize().height;
        local fCurHeight = 0
        for i,uiRow in ipairs(arrChild) do
            local fRowHeight = uiRow:getContentSize().height;
            local stOldAnchor = uiRow:getAnchorPoint()
            uiRow:setAnchorPoint(cc.p(0, 1))
            uiRow:setPositionY( fTotalHeight - fCurHeight );
            uiRow:setAnchorPoint(stOldAnchor)
            if bNetive then
                fCurHeight = fCurHeight - fRowHeight - nPadding
            else
                fCurHeight = fCurHeight + fRowHeight + nPadding
            end
        end
    end
end
-----------------------------end---------------------------------------

--触摸监听
function UIHelper:AddTouchEventListener( bSwallow, uiRoot, funTouchBegan, funcTouchEnd, funcTouchMoved, funcTouchCancel )
    -- body
    if not IsNodeValid(uiRoot) then
        return
    end
    if bSwallow == nil or bSwallow == false then
        bSwallow = false
    else
        bSwallow = true
    end
    local eventListener = cc.EventListenerTouchOneByOne:create()
    eventListener:setSwallowTouches(bSwallow)

    --只有点中才会触发事件
    local funBegan = function( touch, event )
        -- body
        local t = touch
        if type(touch) == "table" then
            t = touch[#touch]
        end
        local stWorldPos = t:getLocation()
        return self:HitTest(uiRoot, stWorldPos, funTouchBegan)
    end

    local funEnded = function( touch, event )
        -- body
        local t = touch
        if type(touch) == "table" then
            t = touch[#touch]
        end
        local stWorldPos = t:getLocation()
        return self:HitTest(uiRoot, stWorldPos, funcTouchEnd)
    end

    eventListener:registerScriptHandler(funBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    if funcTouchMoved then
        eventListener:registerScriptHandler(funcTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    end
    if funcTouchCancel then
        eventListener:registerScriptHandler(funcTouchCancel,cc.Handler.EVENT_TOUCH_CANCELLED )
    end

    eventListener:registerScriptHandler(funEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = uiRoot:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(eventListener, uiRoot)
    return eventListener
end

function UIHelper:HitTest( uiRoot, stWorldPos, funcCallBack )
    -- body
    if not IsNodeValid(uiRoot) then
        return
    end
    if not uiRoot:getParent() then
        return false
    end
    if not uiRoot:isVisible() then
        return false
    end
    local stLocaPos = uiRoot:getParent():convertToNodeSpace(stWorldPos)
    local stBoundBox = uiRoot:getBoundingBox()
    local bInRect = (cc.rectContainsPoint(stBoundBox, stLocaPos))
    if bInRect then
        if funcCallBack then
            funcCallBack(touch, event)
        end
    end
    return bInRect
end

--画线
function UIHelper:drawLine( uiParent, stOrigine, stDest, stAnchor, stPosition, stLineColor, nLineSize )
    -- body
    local glNode = gl.glNodeCreate();
    if uiParent then
        uiParent:addChild(glNode);
    end
    local function primitivesDraw( transform, transformUpdated )
        -- body
        kmGLPushMatrix();
        kmGLLoadMatrix(transform);

        if nLineSize then
            gl.lineWidth(nLineSize);
        end
        if stLineColor then
            cc.DrawPrimitives.drawColor4B(stLineColor.r, stLineColor.g, stLineColor.b, stLineColor.a);
        end
        cc.DrawPrimitives.drawLine(stOrigine, stDest);

        kmGLPopMatrix();
    end

    glNode:registerScriptDrawHandler(primitivesDraw);
    if stAnchor then
        glNode:setAnchorPoint(stAnchor);
    end
    if stPosition then
        glNode:setPosition(stPosition);
    end
    return glNode;
end

--在控件下面加下划线(uiRoot需要有contentsize) []代表可选参数   参数：[父节点]，[线的粗细], [线的颜色], [线的起始点偏移], [线的终点偏移], [线的y位置偏移]
function UIHelper:underLine( uiRoot, nLineSize, stLineColor, nStartOffsetX, nEndOffsetX, nOffsetY )
    -- body
    if not uiRoot then
        return;
    end
    local stAnchor = uiRoot:getAnchorPoint();
    local stPos = uiRoot:getPosition();
    local stSize = uiRoot:getContentSize();
    

    if not stLineColor then
        stLineColor = cc.c4b(0,0,0,255);
    else
        --兼容cc.c3b
        stLineColor = cc.c4b(stLineColor.r, stLineColor.g, stLineColor.b, stLineColor.a or 255);
    end

    if not nStartOffsetX then
        nStartOffsetX = 0;
    end

    if not nEndOffsetX then
        nEndOffsetX = 0;
    end

    if not nOffsetY then
        nOffsetY = 0;
    end



    local stOrigine = cc.p(nStartOffsetX, nOffsetY);
    local stDest = cc.p(stSize.width - nEndOffsetX, nOffsetY);
    if not nLineSize then
        nLineSize = 2;
    end

    --uiParent, stOrigine, stDest, stAnchor, stPosition, stLineColor, nLineSize
    return self:drawLine(uiRoot, stOrigine, stDest, nil, nil, stLineColor, nLineSize);

end

--战斗力框
function UIHelper:createBattleLabel( uiParent, nBattle, stPos, stAnchor, nScale )
    -- body
    local power_bg = cc.Sprite:create("res/common/misc/powerbg_1.png")
    local power_bg_size = power_bg:getContentSize()
    local Mnumber = require "src/component/number/view"
    local NumberBuilder = Mnumber.new("res/component/number/10.png")
    local power = Mnode.createKVP(
    {
        k = cc.Sprite:create("res/common/misc/power_b.png"),
        v = NumberBuilder:create(nBattle or 0, -5),
        margin = 15,
    })

    power:setScale(nScale or 0.6)
    power_bg.refresh = function(self)
        power:setValue( NumberBuilder:create(nBattle or 0, 5) )
    end

    Mnode.addChild(
    {
        parent = power_bg,
        child = power,
        anchor = cc.p(0, 0.5),
        pos = cc.p(10, power_bg_size.height/2),
    })
    if uiParent then
        uiParent:addChild(power_bg)
    end
    if stAnchor then
        power_bg:setAnchorPoint(stAnchor)
    end
    if stPos then
        power_bg:setPosition(stPos)
    end
    return power_bg
end

function UIHelper:createBattleLabel_2( uiParent, nBattle, stPos, stAnchor, nScale )
    -- body
    local battleBg = createSprite(uiParent, "res/common/misc/powerbg_s.png", stPos, stAnchor)
    battleBg:setScale(nScale or 0.7)
    createSprite(battleBg, "res/common/misc/power_b.png", cc.p(20, battleBg:getContentSize().height/2), cc.p(0, 0.5), nil, 0.8)
    createSprite(battleBg, "res/component/number/9_inc.png", cc.p(140, battleBg:getContentSize().height/2), cc.p(0, 0.5))
    local  labelAtlas = cc.LabelAtlas:_create(nBattle or 0, "res/component/number/9.png", 29, 40, string.byte('0'))
    battleBg:addChild(labelAtlas)
    labelAtlas:setAnchorPoint(cc.p(0, 0.5))
    labelAtlas:setPosition(170, battleBg:getContentSize().height/2)
    return battleBg
end

--上下浮动动画
function UIHelper:actionFloor( uiRoot, bLoop, nSec, nHori, nVertical )
    -- body
    if not IsNodeValid(uiRoot) then
        return
    end
    -- local stPos = uiRoot:getPosition()
    local actMoveBy = cc.MoveBy:create(nSec or 1, cc.p(nHori or 0, nVertical or 0))
    local actOneLoop = cc.Sequence:create(actMoveBy, actMoveBy:reverse())
    if bLoop then
        actOneLoop = cc.RepeatForever:create(actOneLoop)
    end
    uiRoot:runAction(actOneLoop)
end

--创建气泡对话
function UIHelper:createBubble( uiParent, stPos, stAnchor, stPadding, strContent, stFontSize, isOutLine, fontName, fontColor, bRunAction, bReverse )
    -- body
    stPadding = stPadding or cc.size(10, 10)
    stFontSize = stFontSize or 20
    if bRunAction == nil then
        bRunAction = true
    end
    --parent, sContent,pos, anchor, fontSize, isOutLine, izorder, fontName, fontColor
    local uiLabel = createLabel(nil, strContent, nil, cc.p(0.5, 0), stFontSize, isOutLine, nil, fontName, fontColor)
    local stLabelSize = uiLabel:getContentSize()
    local stSize = cc.size(math.max(stLabelSize.width + stPadding.width * 2, 220), math.max(stLabelSize.height + stPadding.height * 2, 48))
    local uiBg = createScale9Sprite(uiParent, "res/bubble/bubble_bg.png", stPos, stSize, stAnchor, nil, nil, nil, cc.rect(9, 8, 205, 21) )
    
    -- local uiBlack = createScale9Sprite(uiBg, "res/bubble/bubble_black.png", cc.p(stSize.width/2, stSize.height/2), stLabelSize)
    uiBg:addChild(uiLabel)
    uiLabel:setPosition(cc.p(stSize.width/2, 10 + stPadding.height))

    if bRunAction then
        self:actionFloor(uiBg, true, 0.5, 0, 10)
    end

    if bReverse then
        uiBg:setRotation(180)
        uiLabel:setAnchorPoint(cc.p(0.5, 1))
        uiLabel:setRotation(180)
    end

    return uiBg
end

--富文本
function UIHelper:createRichText( uiParent, strContent, pos, size, anchor, lineHeight, fontSize, fontColor, tag, zOrder, isIgnoreHeight)
    fontSize = fontSize or 18
    if not lineHeight then
        --防止lineHeight不合适, 在anchor point y 为 0.5 或 1的时候产生与label的对齐问题
        lineHeight = getLineHeightByFontSize(fontSize)
    end
    -- body
    local rich = require("src/RichText").new(uiParent, pos or cc.p( 0, 0 ) , size or cc.size( 300 , 0 ) , anchor or cc.p( 0 , 0 ) , lineHeight , fontSize , fontColor or MColor.white, tag, zOrder, isIgnoreHeight );
    rich:setAutoWidth();
    rich:addText(strContent);
    rich:format();

    return rich
end
return UIHelper
