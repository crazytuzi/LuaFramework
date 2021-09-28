
--Login 专用

require "src/AudioPlay"
require "src/config/FontColor"

g_font_path = "fonts/msyh.ttf"
g_scrSize = cc.Director:getInstance():getWinSize()
g_scrCenter = cc.p(g_scrSize.width/2, g_scrSize.height/2)

module ("LoginUtils", package.seeall)

function setNodeAttr(node,...)
    if not node then
        return
    end
    -- 1、pos 2、anchor 3、zOrder 4、tag 5、fScale
    local switch = {
        [1] = function(pos)
            node:setPosition(pos)
        end,
        [2] = function(anchor)
            node:setAnchorPoint(anchor)
        end,
        [3] = function(zOrder)
            node:setLocalZOrder(zOrder)
        end,
        [4] = function(tag)
            node:setTag(tag)
        end,
        [5] = function(scale)
            node:setScale(scale)
        end,
    }
    local Attrs = {...}
    for k,v in pairs(Attrs) do
        switch[k](v)
    end
end

function createScale9Sprite(parent, pszFileName, pos,size, anchor,rect, fScale, zOrder, capinsets)
    local retSprite
    if rect then
        retSprite = cc.Scale9Sprite:create(pszFileName, rect)
    else
        retSprite = cc.Scale9Sprite:create(pszFileName)
    end
    if retSprite then
        setNodeAttr(retSprite, pos, anchor, zOrder,tag,fScale)
        if capinsets then
            retSprite:setCapInsets(capinsets)
        end
        if size then
            retSprite:setContentSize(size)
        end
        if parent then
            parent:addChild(retSprite)
        end
    end

    return retSprite
end

function createScale9Frame(parent, pszTiledFileName, pszFrameFileName, pos,size,frame_width,anchor)
    local rootNode =  cc.Node:create()
    if anchor then
        rootNode:setAnchorPoint(anchor)
    end
    rootNode:setPosition(pos)
    rootNode:setContentSize(size)
    if parent then
        parent:addChild(rootNode)
    end

    local spTiledBg = cc.Sprite:create(pszTiledFileName, cc.rect(0, 0, size.width - frame_width * 2, size.height - frame_width * 2))
    spTiledBg:setAnchorPoint(cc.p(0, 0))
    spTiledBg:setPosition(cc.p(frame_width, frame_width))
    spTiledBg:getTexture():setTexParameters(gl.LINEAR, gl.LINEAR, gl.REPEAT, gl.REPEAT)
    rootNode:addChild(spTiledBg)

    local retSprite = cc.Scale9Sprite:create(pszFrameFileName)  
    if retSprite then
        retSprite:setAnchorPoint(cc.p(0, 0))
        retSprite:setPosition(cc.p(0, 0))
        retSprite:setContentSize(size)
        rootNode:addChild(retSprite)
    end

    return rootNode
end

function createBgSprite(parent, tileName, tileNameEx, quick_Type, endFunc, noHide)
    local display = { width =  g_scrSize.width , height = g_scrSize.height , cx = g_scrSize.width/2 , cy = g_scrSize.height/2 } 
    local commonPath = "res/common/"
    local bg_node = cc.Node:create()
    bg_node:setContentSize(cc.size(960,640))
    bg_node:setPosition(cc.p((g_scrSize.width-960)/2,(g_scrSize.height-640)/2))
    if parent then
        parent:addChild(bg_node)
    end
    local bg = createSprite(nil, commonPath.."newbg/base_bg.png", cc.p(display.width/2-(g_scrSize.width-960)/2, display.height/2-(g_scrSize.height-640)/2), cc.p(0.5, 0.5))

    bg_node:addChild(bg,-1)
    local closeFunc = function() 
        local ret = nil
        if endFunc then 
            ret = endFunc()
        end
        if not ret then
            removeFromParent(parent or bg_node) 
        end
    end

    local close_item = createTouchItem(bg_node, "res/component/button/X.png", cc.p(923,575), closeFunc, nil)
    close_item:setLocalZOrder(500)
    local name
    local tileName = tileName or ""
    if tileName then
        name = createLabel(bg_node, tileName, cc.p(480,595),cc.p(0.5, 0.5), 25, true, nil, nil)
        if name then
            name:setTag(12580)
        end
    end
    SwallowTouches(bg)
    --registerOutsideCloseFunc( bg , closeFunc ,true)
    function bg_node:remove()
        closeFunc()
    end
    return bg_node, close_item, name
end

function createSprite(parent, pszFileName, pos, anchor, zOrder, fScale)
    local retSprite = nil
    if type(pszFileName) == "string" then
        retSprite = cc.Sprite:create(pszFileName)
    else
        retSprite = cc.Sprite:createWithSpriteFrame(pszFileName)
    end
    -- log(pszFileName)
    if retSprite then
        setNodeAttr(retSprite, pos, anchor, zOrder,nil, fScale)
        if parent then
            parent:addChild(retSprite)
        end
    end
    return retSprite
end

function createMenuItem(parent, pszFileName, pos, callback,zorder,noswan,noDefaultVoice)
    if not parent then
        return
    end

    local futil = cc.FileUtils:getInstance()
    local bCurFilePopupNotify = false
    if isWindows() then
        bCurFilePopupNotify = futil:isPopupNotify()
        futil:setPopupNotify(false)
    end

    local select_filename = string.gsub(pszFileName,".png","_sel.png")
    if not futil:isFileExist(select_filename) then
        select_filename = nil
    end
    local dis_filename = string.gsub(pszFileName,".png","_gray.png")
    if not futil:isFileExist(dis_filename) then
        dis_filename = nil
    end

    if isWindows() then
        futil:setPopupNotify(bCurFilePopupNotify)
    end

    local menu_item = MenuButton:create(pszFileName,select_filename,dis_filename)
    local menu = cc.Menu:create()
    if zorder then
        parent:addChild(menu,zorder)
    else
        parent:addChild(menu)
    end
    menu:setPosition(0,0)
    if menu_item then
        menu:addChild(menu_item)
        menu:setTag(1)
        menu_item:setPosition(pos)
        if callback then
            menu_item:registerScriptTapHandler(function( targetID , node )
                local point = cc.p( node:getPosition() )
                local addr = node:getParent():convertToWorldSpace( point )
                clickX , clickY = addr.x  , addr.y
                if not noswan then node:setEnabled(false) end
                local cb = function()
                    local node = tolua.cast(node,"MenuButton")
                    if node and (not noswan) then
                        node:setEnabled(true)
                    end
                end
                performWithDelay(node,cb,0.15)
                callback( targetID ,node)
                if not noDefaultVoice then
                    AudioEnginer.playTouchPointEffect()
                end
            end )
        end
    end
    return menu_item
end

--保存本地记录
function setLocalRecordByKey(c_type, key, value)
    -- 1 int 2 string 3 bool
    if key and type(key) == "string" and (value~=nil)  then
        if c_type == 1 then
            if type(value) == "number" then
                cc.UserDefault:getInstance():setIntegerForKey(key,value)
                cc.UserDefault:getInstance():flush()
            end
        elseif c_type == 2 then
            if type(value) == "string" then
                cc.UserDefault:getInstance():setStringForKey(key,value)
                cc.UserDefault:getInstance():flush()
            end
        elseif c_type == 3 then
            if type(value) == "boolean" then
                cc.UserDefault:getInstance():setBoolForKey(key,value)
                cc.UserDefault:getInstance():flush()
            end
        end
    end
end

--读取本地记录
function getLocalRecordByKey(c_type,key,default_value)
    -- 1 int 2 string 3 bool
    if key and (type(key) == "string") then
        if c_type == 1 then
            return cc.UserDefault:getInstance():getIntegerForKey(key,default_value or 0)
        elseif c_type == 2 then
            return cc.UserDefault:getInstance():getStringForKey(key,default_value or "")
        elseif c_type == 3 then
            return cc.UserDefault:getInstance():getBoolForKey(key,default_value or false)
        end
    end
end

function createLabel(parent, sContent,pos, anchor, fontSize, isOutLine, izorder, fontName, fontColor, tag, specificWidth, outLineColor, outLineWidth)
    if isOutLine or outLineColor then
        isOutLine = true
    end
    local fontSize = fontSize or 28
    local isOutLine = isOutLine or false
    if fontColor == nil then
        if isOutLine then
            fontColor = MColor.lable_yellow
        else
            fontColor = cc.c3b(255, 255, 255)
        end
    end
    local anchor = anchor or cc.p(0.5,0.5)

    local pTTFRet = nil
    local contentType = type(sContent)
    if contentType ~= "string" and contentType ~= "number" then
        pTTFRet = cc.Label:createWithTTF("", g_font_path, fontSize)
    else
        pTTFRet = cc.Label:createWithTTF(sContent, g_font_path, fontSize)
    end

    if pTTFRet then 
        setNodeAttr(pTTFRet, pos, anchor, izorder, tag)
        pTTFRet:setColor(fontColor)
        
        if specificWidth then
            pTTFRet:setDimensions(specificWidth,0)
        end
        if parent then
            parent:addChild(pTTFRet)
        end      
    end
    -- if labelNode and isOutLine then
    --  if Device_target == cc.PLATFORM_OS_ANDROID or Device_target == cc.PLATFORM_OS_WINDOWS then
    --      labelNode:enableShadow(cc.c4b(24, 17, 14,255),cc.size(1,1))
    --  else
    --      labelNode:enableShadow(cc.c4b(24, 17, 14,255),cc.size(2,2))
    --  end
    -- end
    return pTTFRet
end

--显示公告
require("src/layers/notice/NoticeData")
function showNotice(scene, notice)
    local content = ""
    if notice and #notice > 0 then
        content = notice
    end

    if #content == 0 then
        content = sdkGetNoticeContent(scene)
    end

--[=[
content = 
[[
《传奇世界手游》

^c(black)全面继承传世端游玩法和系统，经典唯美的场景、热血激情的PK、爽快便捷的操作，力争在移动平台带给大家最纯正的传世体验。^

当前为测试版本，不代表最终品质  【^u(red)请点击这里更新|http://www.baidu.com^】
]]
--]=]

    content = string.gsub(content, "\r\n", "\n")

    --local title = sdkGetNoticeTitle(scene)
    --print("showNotice", scene, title, content)

    if #content == 0 then
        return
    end

    DATA_Notice:setHttpData("游戏公告", content)
    
    local function noticeDelayFun()
        require("src/layers/notice/NoticeLayer").new( { parentLayer = cc.Director:getInstance():getRunningScene() } )
    end
    performWithDelay(cc.Director:getInstance():getRunningScene() , noticeDelayFun , 0.5 )
end

function createTouchItem(parent, pszFileName, pos, callback,action,downFunc,noDefaultVoice)
    local func = function(targetID ,sender) 
        local sender = tolua.cast(sender,"TouchSprite")
        local cb = function()
            local sender = tolua.cast(sender,"TouchSprite")
            if sender then
                sender:setTouchEnable(true)
            end
        end
        if action then
            local actions = {cc.ScaleTo:create(0.15,0.85),cc.ScaleTo:create(0.05,1.0)}
            sender:runAction(cc.Sequence:create(actions))
        end
        performWithDelay(sender,cb,0.15)
        sender:setTouchEnable(false)
        callback(sender)
        if not noDefaultVoice then
            AudioEnginer.playTouchPointEffect()
        end
    end
    local sprite1 = nil
    if type(pszFileName) == "string" then
        sprite1 = TouchSprite:create(pszFileName)
        if sprite1 then
            sprite1:registerTouchUpHandler(func)
        end
    elseif pszFileName[2] then
        sprite1 = TouchSprite:createWithFrame(pszFileName[1],pszFileName[2])
        if sprite1 then
            sprite1:registerTouchUpHandler(func)
        end
    else
        sprite1 = TouchSprite:createWithFrame(pszFileName[1])
        if sprite1 then
            sprite1:registerTouchUpHandler(func)
        end
    end
    
    if sprite1 then
        sprite1:setTouchEnable(true)
        if parent then
            parent:addChild(sprite1)
        end
        sprite1:setPosition(pos)
        if action then
            local downActFunc = function(hander) 
                if hander then
                    hander:runAction(cc.ScaleTo:create(0.15,1.15))
                end
                if downFunc then downFunc(sender) end
            end
            sprite1:registerTouchDownHandler(downActFunc)
        else
            if downFunc then
                sprite1:registerTouchDownHandler(downFunc)
            end
        end
    end
    
    return sprite1
end

--点击node区域外会调用func
function registerOutsideCloseFunc(node, func, swallow, anycase, area)
    if (node == nil) or (func == nil) then
        return
    end

    local  listenner = cc.EventListenerTouchOneByOne:create()
    local flag = false
    if swallow then
        listenner:setSwallowTouches( true )
    end

    if not area then
        area = node:getBoundingBox()
    end

    listenner:registerScriptHandler(function(touch, event) 
                                        local pt = node:getParent():convertTouchToNodeSpace(touch)
                                        if cc.rectContainsPoint(area, pt) == false then
                                                flag = true
                                        end
                                        return true 
                                    end, cc.Handler.EVENT_TOUCH_BEGAN)
    listenner:registerScriptHandler(function(touch, event)
        local start_pos = touch:getStartLocation()
        local now_pos = touch:getLocation()
        local span_pos = cc.p(now_pos.x-start_pos.x,now_pos.y-start_pos.y)
        if math.abs(span_pos.x) < 30 and math.abs(span_pos.y) < 30 then
            local pt = node:getParent():convertTouchToNodeSpace(touch)
            if flag and (cc.rectContainsPoint(area, pt) == false) or anycase then
                func()
                AudioEnginer.playTouchPointEffect()
            end
        end
    end, cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = node:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, node)
end

function createBatchRootNode(parent,fontSize,pos)
    local lab_ttf = {}
    lab_ttf.fontFilePath = "fonts/msyh.ttf"
    lab_ttf.fontSize = fontSize
    local node = MirBatchDrawLabel:createWithTTF(lab_ttf)
    node:setPosition(pos or cc.p(0, 0))
    if parent then parent:addChild(node) end
    return node
end

function stringsplit(str, delimiter)
    if (delimiter=='') then return false end
    local pos,arr = 0, {}
    -- for each divider found
    for st,sp in function() return string.find(str, delimiter, pos, true) end do
        table.insert(arr, string.sub(str, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(str, pos))
    return arr
end

function createBatchLabel(parent, sContent,pos, anchor, fontSize, isOutLine, izorder, fontName, fontColor, tag, specificWidth, outLineColor, outLineWidth)
    if parent then
        local labelNode = parent:createLabel(sContent or "",izorder or 0, pos or cc.p(0,0))
        if labelNode then
            if fontColor then
                labelNode:setColor(fontColor)
            end
            if anchor then
                labelNode:setAnchorPoint(anchor)
            end
        end
        return labelNode
    end
end


function showLoginTips(tips)
    local node = cc.Node:create()
    setNodeAttr( node , cc.p(g_scrSize.width/2, 240) , cc.p( 0 , 0 ) )  
    local richText = require("src/RichText").new( node , cc.p( 0 , 0 ) , cc.size(800 , 25 ) , cc.p( 0.5 , 0.5 ) , 22 , 20, MColor.white )
    richText:setAutoWidth()
    richText:addText( tips , MColor.white , false )
    richText:format()
    local text_size = richText:getContentSize()
    --node:setContentSize( text_size )
    local bg = createSprite( node , "res/common/msg_bg.png" , cc.p( 0 , 0 ) , cc.p( 0.5 , 0.5 ) ) 
    bg:setLocalZOrder(-1)
    local bgSize = bg:getContentSize()  
    if bgSize.width -80 < text_size.width then 
        bg:setScale((text_size.width+80)/bgSize.width,1)
    end

    local function hideLoginTips()
        node:removeFromParent()
    end

    node:runAction(cc.Sequence:create( { cc.MoveTo:create( 0.5 , cc.p(g_scrSize.width/2, g_scrSize.height*0.75) ) , cc.DelayTime:create( 1.5 ) , cc.CallFunc:create( hideLoginTips ) } ))
    cc.Director:getInstance():getRunningScene():addChild(node , 499)
end

function SwallowTouches(node)
    local  listenner = cc.EventListenerTouchOneByOne:create()
    listenner:setSwallowTouches(true)
    listenner:registerScriptHandler(function(touch, event)
            return true
        end,cc.Handler.EVENT_TOUCH_BEGAN )
    local eventDispatcher = node:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner,node)
end

function MessageBox(text,yesText,yesCallback)
    local retSprite = cc.Sprite:create("res/common/5.png")
    local title = createLabel(retSprite, "提示", cc.p(210,260), nil,24)
    title:setColor(cc.c3b(215, 195, 114))
    local text_label = createLabel(retSprite, text, cc.p(retSprite:getContentSize().width/2, retSprite:getContentSize().height/2+50), nil,22)
    text_label:setColor(cc.c3b(237, 215, 27))
    text_label:setDimensions(320, 0)
    local funcYes = function()
        local removeFunc = function()
            if retSprite then
                retSprite:removeFromParent()
                retSprite = nil
            end
        end
        if yesCallback then
            yesCallback()
        end
        retSprite:runAction(cc.Sequence:create(cc.ScaleTo:create(0.0, 0), cc.CallFunc:create(removeFunc)))  
    end

    local menuItem = createMenuItem(retSprite,"res/component/button/50.png",cc.p(210,45),funcYes)
    local btn_str = createLabel(menuItem, yesText, cc.p(65,28), nil,24)
    btn_str:setColor(cc.c3b(247, 206, 150))
    cc.Director:getInstance():getRunningScene():addChild(retSprite,100)
    retSprite:setPosition(cc.p(g_scrSize.width/2, g_scrSize.height/2))

    SwallowTouches(retSprite)
    retSprite:setScale(0.01)
    retSprite:runAction(cc.ScaleTo:create(0.1, 1))
end

function MessageBoxYesNo(title,text,yesCallback,noCallback,yesText,noText)
    local retSprite = cc.Sprite:create("res/common/5.png")
    local r_size  = retSprite:getContentSize()
    createLabel(retSprite, title, cc.p(r_size.width/2, r_size.height -12), cc.p(0.5,1.0), 22, true)

    local contentRichText = require("src/RichText").new(retSprite, cc.p(r_size.width/2, r_size.height/2 + 30), cc.size(r_size.width-100, 100), cc.p(0.5, 0.5), 25, 20, cc.c3b(247, 206, 150))
    contentRichText:addText(text, cc.c3b(247, 206, 150))
    contentRichText:setAutoWidth()
    contentRichText:format()

    local funcYes = function()
        retSprite:runAction(cc.Sequence:create(cc.ScaleTo:create(0.0, 0), cc.RemoveSelf:create()))
        if yesCallback then
            yesCallback()
        end
    end

    local funcNo = function()
        AudioEnginer.playEffect("sounds/uiMusic/ui_back.mp3", false)
        if noCallback then
            noCallback()
        end
        retSprite:runAction(cc.Sequence:create(cc.ScaleTo:create(0.0, 0), cc.RemoveSelf:create()))
    end

    local btn_img,spanx = "res/component/button/50.png",0
    if noCallback == false then
        btn_img = "res/component/button/51.png"
        spanx = 30
    end
    local menuItem = createMenuItem(retSprite,btn_img,cc.p(315+spanx,45),funcYes)
    createLabel(menuItem, yesText or getStrByKey("sure"), getCenterPos(menuItem), nil, 21, true)

    local menuItem = createMenuItem(retSprite, btn_img, cc.p(100-spanx,45), funcNo, nil, nil, true)
    createLabel(menuItem, noText or  getStrByKey("cancel"), getCenterPos(menuItem), nil, 21, true)
    cc.Director:getInstance():getRunningScene():addChild(retSprite,400)
    retSprite:setPosition(cc.p(g_scrSize.width/2, g_scrSize.height/2))

    SwallowTouches(retSprite)
    retSprite:setScale(0.01)
    retSprite:runAction(cc.ScaleTo:create(0.1, 1))
    return retSprite
end

function getCenterPos(sprite, addX, addY)
    local size = sprite:getContentSize()
    local x ,y = size.width/2,size.height/2

    if addX then
        x = x + addX
    end

    if addY then
        y = y + addY
    end
    return cc.p(x, y)
end

function getStrByKey(key)
    local str_tab = require("src/config/StringCfg")
    if str_tab[key] then
        return str_tab[key]
    else
        print("unknown str", key)
        return ""
    end
end

function createEditBox(parent,pszFileName,pos,size,color,font_size,placeholdstr)
    local box
    if pszFileName then
        box = ccui.EditBox:create(size,cc.Scale9Sprite:create(pszFileName))
    else
        box = ccui.EditBox:create(size,cc.Scale9Sprite:create())
    end
    if pos then box:setPosition(pos) end
    if color then box:setFontColor(color) end
   -- box:setInputMode(kEditBoxInputModeAny)
    --box:setInputFlag(kEditBoxInputFlagInitialCapsWord)
    box:setFont(g_font_path, font_size or 20)
    if placeholdstr then
        box:setPlaceholderFont(g_font_path, font_size or 20)
        box:setPlaceHolder(placeholdstr)
    end
    if parent then
        parent:addChild(box)
    end
    return box
end

function removeFromParent(node, callback)
    local ExitConfig = node and node.OnExitTransition
    if ExitConfig then
        ExitConfig.cb = callback
        local Manimation = require "src/young/animation"
        Manimation:transit(ExitConfig)
    else
        local node_ex = tolua.cast(node,"cc.Node")
        if node_ex then
            --print(string.format(debug.traceback()))
            node_ex:removeFromParent()
            node_ex = nil
        end
        if callback then callback() end
    end
end

--序列化一个Table
function serialize(t)
    local mark={}
    local assign={}

    local function isArray(tab)
    if not tab then
        return false
    end

    local ret = true
    local idx = 1
    for f, v in pairs(tab) do
        if type(f) == "number" then
            if f ~= idx then
                ret = false
            end
        else
            ret = false
        end
        if not ret then break end
            idx = idx + 1
        end
        return ret
    end

    local function table2str(t, parent)
        mark[t] = parent
        local ret = {}

        if isArray(t) then
            table.foreach(t, function(i, v)
                local k = tostring(i)
                local dotkey = parent.."["..k.."]"
                local t = type(v)
                if t == "userdata" or t == "function" or t == "thread" or t == "proto" or t == "upval" then
                    --ignore
                elseif t == "table" then
                    if mark[v] then
                        table.insert(assign, dotkey.."="..mark[v])
                    else
                        table.insert(ret, table2str(v, dotkey))
                    end
                elseif t == "string" then
                    table.insert(ret, string.format("%q", v))
                elseif t == "number" then
                    if v == math.huge then
                        table.insert(ret, "math.huge")
                    elseif v == -math.huge then
                        table.insert(ret, "-math.huge")
                    else
                        table.insert(ret,  tostring(v))
                    end
                else
                    table.insert(ret,  tostring(v))
                end
            end)
        else
            table.foreach(t, function(f, v)
                local k = type(f)=="number" and "["..f.."]" or f
                local dotkey = parent..(type(f)=="number" and k or "."..k)
                local t = type(v)
                if t == "userdata" or t == "function" or t == "thread" or t == "proto" or t == "upval" then
                    --ignore
                elseif t == "table" then
                    if mark[v] then
                        table.insert(assign, dotkey.."="..mark[v])
                    else
                        table.insert(ret, string.format("%s=%s", k, table2str(v, dotkey)))
                    end
                elseif t == "string" then
                    table.insert(ret, string.format("%s=%q", k, v))
                elseif t == "number" then
                    if v == math.huge then
                        table.insert(ret, string.format("%s=%s", k, "math.huge"))
                    elseif v == -math.huge then
                        table.insert(ret, string.format("%s=%s", k, "-math.huge"))
                    else
                        table.insert(ret, string.format("%s=%s", k, tostring(v)))
                    end
                else
                    table.insert(ret, string.format("%s=%s", k, tostring(v)))
                end
            end)
        end

        return "{"..table.concat(ret,",").."}"
    end

    if type(t) == "table" then
        return string.format("%s%s",  table2str(t,"_"), table.concat(assign," "))
    else
        return tostring(t)
    end
end

--@note：反序列化一个Table
function unserialize(str)
    if str == nil or str == "nil" then
        return nil
    elseif type(str) ~= "string" then
        EMPTY_TABLE = {}
        return EMPTY_TABLE
    elseif #str == 0 then
        EMPTY_TABLE = {}
        return EMPTY_TABLE
    end

    local code, ret = pcall(loadstring(string.format("do local _=%s return _ end", str)))

    if code then
        return ret
    else
        EMPTY_TABLE = {}
        return EMPTY_TABLE
    end
end

function getRoleInfo(delType, staticRoleId, lv, school, Name,serverId)
    local tempServerId = serverId or userInfo.serverId
    local key = "userRoleData" .. sdkGetOpenId() .. "serverId"..tempServerId 
    if delType == 1 then
        local str = getLocalRecordByKey(2, key, "")
        local tempRole = unserialize(str)
        -- if #tempRole > 2 then
        --  local lastRole = 3
        --  local lv = 1000
        --  for k,v in pairs(tempRole) do
        --      if v.lv < lv then
        --          lv = v.lv
        --          lastRole = k
        --      end
        --  end
        --  table.remove(tempRole, lastRole)
        -- end
        return tempRole
    end
end

function isTestMode()
    if isWindows() then
        return true
    end

    if string.find(getHostName(), "woool") then
        return true
    end

    --return true
    return false
end

function isDevTest()
    if string.find(getHostName(), "woool2") then
        return false
    end

    if string.find(getHostName(), "woool1") then
        return true
    end

    if string.find(getHostName(), "woool") then
        return true
    end

    return false
end

function compareVersion(version1, version2)

    version1 = version1 or ""
    version2 = version2 or ""

    local ver1 = stringsplit(version1, '.')
    local ver2 = stringsplit(version2, '.')

    local count1 = #ver1
    local count2 = #ver2
    local count = math.min(count1, count2, 4)

    for i = 1, count do
        if tonumber(ver1[i]) < tonumber(ver2[i]) then
            return -1
        end

        if tonumber(ver1[i]) > tonumber(ver2[i]) then
            return 1
        end
    end

    if count1 < count2 then
        return -1
    end

    if count1 > count2 then
        return 1
    end

    return 0
end

ePlatform_Weixin = 1
ePlatform_QQ = 2
ePlatform_Guest = 5

function isQQLogin()
    if sdkGetPlatform() == ePlatform_QQ then
        return true
    end

    return false
end

function isWXLogin()
    if sdkGetPlatform() == ePlatform_Weixin then
        return true
    end

    return false
end

function isGuestLogin()
    if sdkGetPlatform() == ePlatform_Guest then
        return true
    end

    return false
end

function CommonSocketClose()
    --print(string.format(debug.traceback()))
    LuaSocket:getInstance():closeSocket()
end

launchFromWXGameCenter = false
launchFromQQGameCenter = false
function isLaunchFromGameCenter()
    local LoginScene = require("src/login/LoginScene")

    --审核模式下需要隐藏游戏中心
    if LoginScene.reviewServer then
        return false
    end

    return launchFromWXGameCenter or launchFromQQGameCenter
end

function isLaunchFromWXGameCenter()
    local LoginScene = require("src/login/LoginScene")

    --审核模式下需要隐藏游戏中心
    if LoginScene.reviewServer then
        return false
    end

    return launchFromWXGameCenter
end

function isLaunchFromQQGameCenter()
    local LoginScene = require("src/login/LoginScene")

    --审核模式下需要隐藏游戏中心
    if LoginScene.reviewServer then
        return false
    end

    return launchFromQQGameCenter
end

function isReviewServer()
    local LoginScene = require("src/login/LoginScene")
    if LoginScene.reviewServer then
        return true
    end

    return false
end

function loadFriendsInfo()
    local openid = cc.UserDefault:getInstance():getStringForKey("friendsInfoOpenId")
    if openid ~= sdkGetOpenId() then
        return
    end

    local time = cc.UserDefault:getInstance():getDoubleForKey("friendsInfoTime")

    if os.difftime(time, os.time()) < 24*60*60 and openid == sdkGetOpenId() then
        local friendsInfo = cc.UserDefault:getInstance():getStringForKey("friendsInfo");
        if frendsInfo and #frendsInfo > 0 then
            return frendsInfo
        end
    end
end

function saveFriendsInfo(friendsInfo)
    cc.UserDefault:getInstance():setStringForKey("friendsInfo", friendsInfo)
    cc.UserDefault:getInstance():setStringForKey("friendsInfoOpenId", sdkGetOpenId())
    cc.UserDefault:getInstance():setDoubleForKey("friendsInfoTime", os.time())  
end

onRelationFriendsInfoCallback = nil
function onRelationFriendsInfo(result, str)
    saveFriendsInfo(str)

    if onRelationFriendsInfoCallback then
        onRelationFriendsInfoCallback(result, str)
        onRelationFriendsInfoCallback = nil
    end
end

function queryFriendsInfo(callback)
    local friendsInfo = loadFriendsInfo()
    if friendsInfo then
        callback(0, friendsInfo)
        return
    end

    onRelationFriendsInfoCallback = callback
    weakCallbackTab.onRelationNotify = onRelationFriendsInfo
    sdkQueryFriendsInfo(true, "")
end

function loadMyInfo()
    local openid = cc.UserDefault:getInstance():getStringForKey("myInfoOpenId")
    if openid ~= sdkGetOpenId() then
        return
    end

    local time = cc.UserDefault:getInstance():getDoubleForKey("myInfoTime")

    if os.difftime(time, os.time()) < 24*60*60 and openid == sdkGetOpenId() then
        local myInfo = cc.UserDefault:getInstance():getStringForKey("myInfo");
        if myInfo and #myInfo > 0 then
            return myInfo
        end 
    end
end

function saveMyInfo(myInfo)
    cc.UserDefault:getInstance():setStringForKey("myInfo", myInfo)
    cc.UserDefault:getInstance():setStringForKey("myInfoOpenId", sdkGetOpenId())
    cc.UserDefault:getInstance():setDoubleForKey("myInfoTime", os.time())
end

onRelationMyInfoCallback = nil
function onRelationMyInfo(result, str)
    saveMyInfo(str)

    if onRelationMyInfoCallback then
        onRelationMyInfoCallback(result, str)
        onRelationMyInfoCallback = nil
    end
end

function queryMyInfo(callback)
    local myInfo = loadMyInfo()
    if myInfo then
        callback(0, myInfo)
        return
    end

    onRelationMyInfoCallback = callback
    weakCallbackTab.onRelationNotify = onRelationMyInfo
    sdkQueryMyInfo(true, "")
end

function saveQQVipMap(qqVipMap)
    if qqVipMap then
        qqVipMap.time = os.time()
        qqVipMap.openid = sdkGetOpenId()

        local noerror, ret = pcall(require("json").encode, qqVipMap)
        if noerror and ret then
            cc.UserDefault:getInstance():setStringForKey("qqVipMap", ret)
        end
    end
end

function loadQQVipMap()
    local str = cc.UserDefault:getInstance():getStringForKey("qqVipMap")
    local noerror, ret = pcall(require("json").decode, str)
    if noerror and ret then
        if os.difftime(ret.time, os.time()) < 24*60*60 and ret.openid == sdkGetOpenId() then
            return ret
        end
    end

    return false
end

function hasValue(tab, value)
    for k, v in pairs(tab) do
        if value == v then
            return k
        end
    end

    return false
end
