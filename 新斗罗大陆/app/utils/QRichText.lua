--[[
    create by nie
    主要解决 富文本显示问题(适合小量使用)  
    
    支持类型 
        字符串不支持嵌套
        font: <font config={ lua table }>文本内容</font>
            content --文本内容
            size    -- 字体大小
            color   -- 颜色
            shadowColor shadowOffset --阴影参数
            strokeColor 描边
            isLight -- 是否亮色
        bmfont: <bmfont config={ lua table --注意 字符串类型要加上引号 \" fontName  }></bmfont>
            content --文本内容
            fontName -- 艺术字体
        img: <img config={ lua table }></img>
            plistName --plist文件名字 
            fileName -- 图片名称
            isScale9 --是否是9宫格图片
            opacity  --透明度
            scalexy ccp(0.3,0.3) 缩放
            skewX   --倾斜
            skewY 
        node: 其他类型节点 要求可以获取正确的 boundingBox
    demo:
        local node = QRichText.new({
            {oType = "font", content = "奋斗奋斗奋斗",size = 30,color = ccc3(255,220,0)},
            {oType = "img", plistName = "ui/Pagehome.plist",fileName = "active_jingcai.png",skewX = 30,scalexy = ccp(0.5,0.5)},
            {oType = "font", content = "--奋斗奋斗奋斗--",size = 30,color = ccc3(255,0,0)},
            {oType = "font", content = "aa",size = 20,shadowColor = ccc3(255,0,0),shadowOffset = 3},
            {oType = "bmfont", content = "怒增量",fontName = "font/BlueNumber.fnt"},
            {oType = "font", content = "bb",size = 30,strokeColor = ccc3(255,0,0)},
        },200)
        
        或者
        local node = QRichText.new( "<font config={size = 30,color = ccc3(255,220,0)}>奋斗奋斗奋斗</font><img config={ plistName = \"ui/Pagehome.plist\",fileName = \"active_jingcai.png\",skewX = 30,scalexy = ccp(0.5,0.5)}></img><font config={size = 30,color = ccc3(255,0,0)}>--奋斗奋斗奋斗--</font><font config={size = 20,shadowColor = ccc3(255,0,0),shadowOffset = 3}>aa</font><bmfont config={fontName = \"font/BlueNumber.fnt\"}>怒增量</bmfont><font config={size = 30,strokeColor = ccc3(255,0,0)}>bb</font>",200)
    
    options:
        autoCenter :  每行自动居中 
        lineHeight :  规定行高
        lineSpacing:  行距
        stringType : 支持 qinyuanji richtext格式
        defaultColor: 默认字体颜色
]]

local utf8 = import("...lib.utf8")
local QRichText = class("QRichText",function()
    return display.newNode()
end)

QRichText.FONT_SIZE = 20
QRichText.DEFAULT_COLOR = COLORS.j
QRichText.DEFAULT_FONT_NAME = global.font_default
QRichText.COLORSEPARATOR = "##"
QRichText.BOX_SIZE = 2048

QRichText.COLORS = {
    a = ccc3(7, 101, 178),  -- blue2 0765b2  仅用于聊天敌方玩家名字
    b = COLORS.C, -- blue
    c = COLORS.n,
    d = COLORS.j, -- 同n
    e = COLORS.k,
    f = ccc3(255, 226, 181),
    g = COLORS.l,
    h = ccc3(45, 19, 0), --  dark         描边
    i = ccc3(255, 199,29), --  橙       亮底 
    j = COLORS.a,
    k = ccc3(151, 15, 135), -- purple2       仅用于聊天狩猎信息名字
    l = COLORS.g,
    m = COLORS.G, -- 空位
    n = COLORS.j,
    o = COLORS.E,
    p = COLORS.D,
    q = COLORS.c,
    r = COLORS.e,
    s = COLORS.M, -- 空位
    t = COLORS.B, -- 深色背景 绿
    u = COLORS.F, -- 深色背景 红
    v = ccc3(236, 111, 0), -- 传灵塔分享自己暗色地板颜色
    w = COLORS.b,
    x = COLORS.m,
    y = COLORS.G,
    z = COLORS.f,
    S = ccc3(0xff, 0xea, 0x00),
    N = ccc3(0xff, 0xff, 0xff),
    J = COLORS.J, -- 聊天綠
    K = COLORS.K, -- 聊天藍
    L = COLORS.L, -- 聊天紫
    M = COLORS.M, -- 聊天橙
    N = COLORS.N, -- 聊天紅
    O = COLORS.O, -- 聊天黃
    Y = COLORS.y, -- PVP属性显示淡黄色
    A = COLORS.A, -- 
}

local function getNodeSize( node )
    return (node:boundingBox()).size
end

local function createTTF( content, itemcfg, rt )
    -- body
    local label = CCLabelTTF:create(content, itemcfg.fontName or rt._defaultFontName, itemcfg.size or rt._defaultSize)
    
    if itemcfg.dimensions then
        label:setDimensions(itemcfg.dimensions)
    end

    if itemcfg.hAlignment then
        label:setHorizontalAlignment(itemcfg.hAlignment)
    end
    if itemcfg.vAlignment then
        label:setVerticalAlignment(itemcfg.vAlignment)
    end

    if itemcfg.shadowColor and itemcfg.shadowOffset then
        local contentSize = label:getContentSize()
        contentSize.width = contentSize.width + itemcfg.shadowOffset
        contentSize.height = contentSize.height + itemcfg.shadowOffset
        -- contentSize.height = contentSize.height + itemcfg.shadowOffset
        label = setShadow4(label, itemcfg.shadowOffset, itemcfg.shadowColor)
        if label.label ~= nil then
            label.label:setAnchorPoint(ccp(0,0))
        end
        if label.shadow1 ~= nil then
            label.shadow1:setAnchorPoint(ccp(0,0))
        end
        if label.tf ~= nil then
            label.tf:setAnchorPoint(ccp(0,0))
        end
        label:setContentSize(contentSize)
    elseif itemcfg.strokeColor then
        local contentSize = label:getContentSize()
        contentSize.height = contentSize.height 
        contentSize.width = contentSize.width 
        label:setAnchorPoint(ccp(0,0))
        label = setShadow5(label, itemcfg.strokeColor)
        label:setContentSize(contentSize)
    elseif rt._strokeColor then
        local contentSize = label:getContentSize()
        contentSize.height = contentSize.height 
        contentSize.width = contentSize.width 
        label:setAnchorPoint(ccp(0,0))
        label = setShadow5(label, rt._strokeColor)
        label:setContentSize(contentSize)
    end

    if itemcfg.color then
        if nil ~= itemcfg.isLight then
            itemcfg.color = q.convertColorLightOrGray(itemcfg.color, itemcfg.isLight)
        end
        label:setColor(itemcfg.color)
    else
        label:setColor(rt._defaultColor)
    end

    if itemcfg.offsetX then 
        label:setPositionX(itemcfg.offsetX) 
    end 

    if itemcfg.offsetY then 
        label:setPositionY(itemcfg.offsetY) 
    end 
    return label
end

local function createImg( itemcfg )
    -- body
    local image 
    if itemcfg.plistName then
        CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(itemcfg.plistName)
        local frame  = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(itemcfg.fileName)
        if itemcfg.isScale9 then
            image = CCScale9Sprite:createWithSpriteFrame(frame)
            if itemcfg.contentSize then
                image:setContentSize(itemcfg.contentSize)
            end
        else
            image = CCSprite:createWithSpriteFrame(frame)
        end
    else
        local frame_ = QSpriteFrameByPath(itemcfg.fileName)
        image = CCSprite:createWithSpriteFrame(frame_)
        --image = CCSprite:create(itemcfg.fileName)
    end

    if itemcfg.opacity then
        image:setOpacity(itemcfg.opacity)
    end

    if itemcfg.scale then  
        image:setScale(itemcfg.scale)  
    end

    if itemcfg.skewX then
        image:setSkewX(itemcfg.skewX) 
    end 

    if itemcfg.skewY then 
        image:setSkewY(itemcfg.skewY) 
    end 

    if itemcfg.offsetX then 
        image:setPositionX(itemcfg.offsetX) 
    end 

    if itemcfg.offsetY then 
        image:setPositionY(itemcfg.offsetY) 
    end 
    -- if itemcfg.rotation then 
    --     image:setRotation(itemcfg.rotation) 
    -- end
    return image
end

local function createBmFont( itemcfg )
    local label = CCLabelBMFont:create(itemcfg.content, itemcfg.fontName)
    if itemcfg.scale then  
        label:setScale(itemcfg.scale)  
    end
    if itemcfg.gap then
        label:setGap(itemcfg.gap)  
    end
    return label
end



function QRichText:ctor(strOrTable,widthLimit, options)
    --宽度限制  为了换行
    if type(options) == "table" then
        self._options = options
    else
        self._options = {}
    end

    if self._options.stringType and self._options.stringType == 1 then
        self._colorMap = QRichText.COLORS
        self._colorSeparate = QRichText.COLORSEPARATOR
    end

    self._fontParse = self._options.fontParse or false


    self._defaultColor = self._options.defaultColor or QRichText.DEFAULT_COLOR
    self._defaultSize = self._options.defaultSize or QRichText.FONT_SIZE
    self._defaultFontName = self._options.fontName or QRichText.DEFAULT_FONT_NAME
    self._strokeColor = self._options.strokeColor 
    
    self._realWidth = widthLimit
    self._widthLimit = widthLimit
    self._rows = {}
    self._rowsNode = {}
    self._curLeftSpaceWidth = self._widthLimit

    -- 处理过长的字符串
    self:parseConfigString(strOrTable)
    self:renderString()
end

function QRichText:parseConfigString(strOrTable)
    self._parseConfig = {}

    local parseConfigs = {}
    if type(strOrTable) == "table" then
        if self._fontParse then
            parseConfigs = self:parseTableFontConfig(strOrTable)
        else
            parseConfigs = strOrTable
        end
    elseif type(strOrTable) == "string" then
        parseConfigs = self:parseString(strOrTable)
    end
    for i, parseConfig in ipairs(parseConfigs) do
        if parseConfig.content then
            self:dealWithMessage(parseConfig)
        else
            table.insert(self._parseConfig, parseConfig)
        end
    end
end


function QRichText:parseTableFontConfig(strOrTable)
    local parseConfigs ={}
    for index,itemcfg in ipairs(strOrTable) do
        if itemcfg.oType == "font" then
            local str_configs = self:parseString(itemcfg.content)
            for i, parseConfig in ipairs(str_configs) do
                table.insert(parseConfigs, parseConfig)
            end
        else
            table.insert(parseConfigs, itemcfg)
        end
    end
    return parseConfigs
end

function QRichText:dealWithMessage(parseConfig)
    local tempLabel = createTTF(parseConfig.content, {}, self)
    local tempWidth = tempLabel:getContentSize().width
    if tempWidth >= QRichText.BOX_SIZE then
        local textLength = utf8.len(parseConfig.content)
        local halfPos = math.floor(textLength/2)
        local str1 = utf8.sub(parseConfig.content, 1, halfPos)
        local str2 = utf8.sub(parseConfig.content, halfPos+1, textLength)
        local message1 = clone(parseConfig)
        message1.content = str1
        local message2 = clone(parseConfig)
        message2.content = str2
        self:dealWithMessage(message1)
        self:dealWithMessage(message2)
    else
        table.insert(self._parseConfig, parseConfig)
    end
end

function QRichText:clear(  )
    -- body
    self._rows = {}
    self._parseConfig = {}
    for k, v in pairs( self._rowsNode) do
        v:removeAllChildrenWithCleanup(true)
    end
    self._rowsNode = {}
    self:removeAllChildrenWithCleanup(true);
    self._curLeftSpaceWidth = self._widthLimit
end

--添加节点到新行
function QRichText:addNodetoRow( node )
    -- body
    local size = #self._rows 
    if size < 1 then
        return
    end
    table.insert(self._rows[size],node)
end

function QRichText:addNewRow(  )
    -- body
    self._curLeftSpaceWidth = self._widthLimit
    table.insert(self._rows,{})
end


function QRichText:renderString()
    if not next(self._parseConfig) then
        return
    end
    -- body
    self:addNewRow()
    if not  self._widthLimit then
        for index,itemcfg in ipairs(self._parseConfig) do
            if itemcfg.oType == "font" then
                local label = createTTF(itemcfg.content, itemcfg, self)
                label:setTag(index)
                self:addNodetoRow(label)
            elseif itemcfg.oType == "bmfont" then
                local label = createBmFont(itemcfg)
                label:setTag(index)
                self:addNodetoRow(label)
            elseif itemcfg.oType == "img" then
                local image = createImg(itemcfg)
                image:setTag(index)
                self:addNodetoRow(image)
            elseif itemcfg.oType == "node" then
                itemcfg.node:setTag(index)
                self:addNodetoRow(itemcfg.node)
            elseif itemcfg.oType == "wrap" then
                self:addNewRow()
            else
                printInfo("uiRichText not support this type "..v)
            end
        end
    else
        for index,itemcfg in ipairs(self._parseConfig) do
            -- log4Code("index "..index.." "..v)
            if itemcfg.oType == "font" then
                self:handleFontRender(itemcfg,index)
            elseif itemcfg.oType == "bmfont" then
                local label = createBmFont(itemcfg)
                itemcfg.node = label
                self:handleNodeRender(itemcfg,index) 
            elseif itemcfg.oType == "img" then
                local image = createImg(itemcfg)
                itemcfg.node = image
                self:handleNodeRender(itemcfg,index)  
            elseif itemcfg.oType == "wrap" then
                self:addNewRow();
            elseif itemcfg.oType == "node" then
                self:handleNodeRender(itemcfg,index) 
            else
                printInfo("uiRichText not support this type "..v)
            end
        end
    end
    self:formarRichText()
end

function QRichText:handleFontRender(itemcfg, index, label, width)
    if not itemcfg.content then
        return
    end
    if not width or not label then
        label = createTTF(itemcfg.content, itemcfg, self)
        width = (getNodeSize(label)).width
    end
    
    local oldLeftSpaceWidth = self._curLeftSpaceWidth
    self._curLeftSpaceWidth = self._curLeftSpaceWidth - width;
    if self._curLeftSpaceWidth < 0 then
        local percent = (self._curLeftSpaceWidth/width) * -1
        local textLength = utf8.len(itemcfg.content)
        local tempLabelLength = math.floor(textLength * (1- percent));
        local curLabelLength 
        local nextWidth

        local tempLabelStr = utf8.sub(itemcfg.content, tempLabelLength + 1,textLength)
        local tempLabel = createTTF(tempLabelStr, itemcfg, self)
        local tempWidth = (getNodeSize(tempLabel)).width
        local nextLabelText 
        local nextLabel

        --当前 计算的宽度大于 剩余宽度
        if width - tempWidth > oldLeftSpaceWidth then
            while tempLabelLength >0 do
                tempLabelLength = tempLabelLength - 1;
                tempLabelStr = utf8.sub(itemcfg.content, tempLabelLength + 1, textLength)
                tempLabel = createTTF(tempLabelStr, itemcfg, self)
                tempWidth = (getNodeSize(tempLabel)).width
                if width - tempWidth <= oldLeftSpaceWidth then
                    curLabelLength = tempLabelLength
                    nextWidth = tempWidth
                    nextLabelText = tempLabelStr
                    nextLabel = tempLabel
                    break;
                end
            end
        elseif width - tempWidth < oldLeftSpaceWidth then
            local lastTempWidth =  tempWidth
            local lastTempLabelStr = tempLabelStr
            local lastTempLabel = tempLabel

            while true do
                tempLabelLength = tempLabelLength + 1;
                tempLabelStr = utf8.sub(itemcfg.content, tempLabelLength + 1, textLength)
                tempLabel = createTTF(tempLabelStr, itemcfg, self)
                tempWidth = (getNodeSize(tempLabel)).width

                if width - tempWidth + 1 >= oldLeftSpaceWidth then
                    curLabelLength = tempLabelLength - 1
                    nextWidth = lastTempWidth
                    nextLabelText = lastTempLabelStr
                    nextLabel = lastTempLabel
                    break;
                else
                    lastTempWidth = tempWidth
                    lastTempLabelStr = tempLabelStr
                    lastTempLabel = tempLabel
                end
            end
        else
            curLabelLength = tempLabelLength
            nextLabelText = tempLabelStr
            nextLabel = tempLabel
            nextWidth = tempWidth
        end

        local curLabelText = utf8.sub(itemcfg.content, 1, curLabelLength)
        itemcfg.content = nextLabelText
        local curLabel =  createTTF(curLabelText, itemcfg, self)
        curLabel:setTag(index)
        self:addNodetoRow(curLabel)
        
        self:addNewRow();
        self:handleFontRender(itemcfg, index, nextLabel, nextWidth)
    else
        label:setTag(index)
        self:addNodetoRow(label)
    end
end

function QRichText:handleNodeRender(itemcfg,index)
    itemcfg.node:setTag(index)
    local nodeSize = getNodeSize(itemcfg.node);
    self._curLeftSpaceWidth = self._curLeftSpaceWidth - nodeSize.width;
    itemcfg.node:setTag(index)
    if self._curLeftSpaceWidth < 0 then
        self:addNewRow();
        self:addNodetoRow(itemcfg.node);
        self._curLeftSpaceWidth = self._curLeftSpaceWidth - nodeSize.width;
    else
        self:addNodetoRow(itemcfg.node);
    end
end

--richText 布局
function QRichText:formarRichText(  )
    -- body
    local contentSize = {}
    local contentWidth = 0;
    local contentHeight = 0;

    local lineSpacing = 0
    if self._options.lineSpacing then
        lineSpacing = self._options.lineSpacing
    end

    local heightTable = {}

    if self._options.lineHeight then
        contentHeight = #self._rows * self._options.lineHeight
        for k,row in pairs(self._rows)do
            heightTable[k] = self._options.lineHeight;
        end
    else
        for k,row in pairs(self._rows)do
            local tempHeight = 0
            for _,v in pairs(row)do
               local size = getNodeSize(v)
               tempHeight = math.max(tempHeight,size.height) 
            end
            heightTable[k] = tempHeight;
            contentHeight = contentHeight + tempHeight;
        end
    end
   

    local nextPosY = 0;
    for i=#self._rows,1,-1 do
        local row = self._rows[i]
        local nextPosX = 0

        local rowNode = display.newNode()
        rowNode:setAnchorPoint(0,0)
        rowNode:setPosition(0,nextPosY)
        self._rowsNode[i] = rowNode
        self:addChild(rowNode)

        for _,v in pairs(row)do
            local tag = v:getTag()
            local cfg = self._parseConfig[tag]

            local size = getNodeSize(v);
            v:setAnchorPoint(ccp(0,0));
            local posy = 0
            if size.height < heightTable[i] then
                posy = (heightTable[i]-size.height)/2
            end
            local offsetx = 0
            local offsety = 0
            if cfg.offset then
                offsetx = cfg.offset.x
                offsety = cfg.offset.y
            end
            local offsetPos = ccp(v:getPosition())
            v:setPosition(ccp(nextPosX + offsetx + offsetPos.x, posy + offsety + offsetPos.y))
            rowNode:addChild(v)
            nextPosX = nextPosX + size.width;
        end

        rowNode:setContentSize(nextPosX, heightTable[i])

        if self._options.autoCenter and self._widthLimit then
            if nextPosX < self._widthLimit then
                rowNode:setPositionX((self._widthLimit - nextPosX)/2)
            end
        end

        nextPosY = nextPosY + heightTable[i] + lineSpacing;
    end

    local contentWidth 

    if self._widthLimit then
        contentWidth = self._widthLimit;
    else
        local maxWidth = 0
        for k, v in pairs(self._rowsNode) do
            local tempWidth = v:getContentSize().width
            if maxWidth < tempWidth then
                maxWidth =  tempWidth
            end
        end
        contentWidth = maxWidth
    end

    self:setContentSize(CCSizeMake(contentWidth,contentHeight + lineSpacing * (#self._rows - 1)))
end

function QRichText:getRealWidth( )
    local maxWidth = 0
    for k, v in pairs(self._rowsNode) do
        local tempWidth = v:getContentSize().width
        if maxWidth < tempWidth then
            maxWidth =  tempWidth
        end
    end

    return maxWidth > self._widthLimit and self._widthLimit or maxWidth
end
--strOrTable 格式化字符串  cfg 配置
function QRichText:setString(strOrTable)
    -- body 
    self:clear()
    self:parseConfigString(strOrTable)
    self:renderString()
end


function QRichText:parseString(str )
    -- body
    if self._options.stringType and self._options.stringType == 1 then
        return self:parseString2(str)
    end
   
    if not str or str == "" then
        printInfo("parseString  str is nil or empty")
        return {}
    end
 
    local config = {}
    local startIndex = string.find(str,".-<%s-([%w_]+)%s-.->.-</%1>.-")
    if startIndex then
        string.gsub(str,"(.-)<%s-([%w_]+)%s-%S-%s-=?%s-({.-})%s->(.-)</%2>",function(normalText,tag,param,content)
            -- print(string.format("parseRichText1   1  %s   2  %s 3  %s 4  %s",normalText,tag,param,content))
            if normalText and normalText ~= "" then
                local normalTextTable = string.split(normalText, "\n")
                for k, v in pairs(normalTextTable) do
                    if k >1 then
                        table.insert(config,{oType = "wrap"})
                    end
                    if v then
                        table.insert(config,{oType = "font",content = v})
                    end
                end
            end

            local cfg 
            if tag then
                xpcall(function( )
                    if param then
                        cfg =  loadstring("return".. param)() 
                    else
                        cfg = {}
                    end
                end,debug.traceback)

                if not cfg or type(cfg) ~= "table" then
                    printInfo("error cfg is not a table")
                    cfg = {}
                end
                if tag == "font" or tag == "bmfont" then
                    if content and content ~= "" then
                        local contentTable = string.split(content, "\n")
                        for k, v in pairs(contentTable) do
                            if k >1 then
                                table.insert(config,{oType = "wrap"})
                            end
                            if v then
                                local tempCfg = clone(cfg)
                                tempCfg.content = v
                                tempCfg.oType = tag
                                table.insert(config,tempCfg or {})
                            end
                        end 
                    end
                else
                    cfg.oType = tag
                    table.insert(config,cfg or {})
                end  
            end
        end)
        --</font>aaa  aaa 最后的内容上一个表达式匹配不到 
        string.gsub(str,".*</%S->(.-)$",function(normalText)
            -- printInfo(string.format("parseRichText2  1  %s",normalText))
            if normalText and normalText ~= "" then
                local normalTextTable = string.split(normalText, "\n")
                for k, v in pairs(normalTextTable) do
                    if k >1 then
                        table.insert(config,{oType = "wrap"})
                    end
                    if v then
                        table.insert(config,{oType = "font",content = v})
                    end
                end
            end
        end)
    else
        table.insert(config, {oType = "font",content = str})
    end

    return config
end


function QRichText:parseString2(str)
    -- body
    local returnMsg = string.split(str, "\\n")
    local lastColor = nil
    local config = {}

    for k, v in ipairs(returnMsg) do
        if k > 1 then
           table.insert(config,{oType = "wrap"}) 
        end

        local msg = string.split(v, self._colorSeparate)
        if msg[1] ~= "" then
            local message = msg[1]
            table.insert(config, {oType = "font", content = message, color = lastColor})
        end
        for i = 2, #msg do
            if msg[i] ~= "" then
                local message = nil
                if string.match(msg[i], "^&([%a]*)({.-})$") then
                    string.gsub(msg[i], "^&([%a]*)({.-})$",function ( widgetName, param)
                        -- body
                        if widgetName and param then
                            local paramTbl = {}
                            xpcall(function( )
                                if param then
                                    paramTbl =  loadstring("return".. param)() 
                                else
                                    paramTbl = {}
                                end
                            end,debug.traceback)

                            if type(self["getNode_"..widgetName]) == "function" then
                                self["getNode_"..widgetName](self, config, paramTbl)
                            end
                        end
                    end)
                else
                    local pos1,pos2 = string.find(msg[i],"0x[0-9|(a-f)|(A-F)]*")
                    if pos2 ~= nil and pos2 > 2 then
                        pos2 = math.min(pos2,8)
                        local colorStr = string.sub(msg[i], pos1, pos2)
                        lastColor = self:convertColorWithX(colorStr)
                        message = string.sub(msg[i], pos2+1)
                    else
                        pos1,pos2 = string.find(msg[i],"#[0-9|(a-f)|(A-F)]*")
                        if pos1 ~=nil and pos2 > 2 then
                            local colorStr = string.sub(msg[i], pos1, pos2)
                            lastColor = q.parseColor(colorStr)
                            message = string.sub(msg[i], pos2+1)
                        else
                            lastColor = string.sub(msg[i], 1, 1)
                            if self._colorMap[lastColor] then
                                lastColor = self._colorMap[lastColor]
                            else
                                lastColor = self._defaultColor or QRichText.DEFAULT_COLOR 
                            end
                            message = string.sub(msg[i], 2)
                        end
                    end
                    table.insert(config, {oType = "font", content = message, color = lastColor})
                end
            end
        end
    end

    return config
end

function QRichText:getNode_QUIWidgetHeroTitleBox( config, param )
    -- body
    local QStaticDatabase = import("..controllers.QStaticDatabase")
    local QUIWidgetHeroTitleBox = import( "app.ui.widgets.QUIWidgetHeroTitleBox")
    if QUIWidgetHeroTitleBox then
        if not param.title and  param.rank then
            param.title = QStaticDatabase.sharedDatabase():getGloryArenaChenghaoID(param.rank or 999999)
        end
       
        if param.title and param.title > 0 then
            local defaultOffset 

            local titleBox = QUIWidgetHeroTitleBox.new()
            titleBox:setTitleId(param.title)
            titleBox:setScale(param.scale or 0.5)
            local size = titleBox:boundingBox().size
            defaultOffset = ccp(size.width/2, size.height/2)
            table.insert(config, {oType = "node", node = titleBox, offset = param.offset or defaultOffset} )
        end
    end
end

function QRichText:getNode_QUIWidgetItemsBox( config, param )
    -- body
    if not param then
        return
    end
    if not param.id then
       return
    end

    local QUIWidgetItemsBox = import( "app.ui.widgets.QUIWidgetItemsBox")
    if QUIWidgetItemsBox then
        local defaultOffset 
        local itemBox = QUIWidgetItemsBox.new()
        itemBox:setGoodsInfoByID(param.id)
        itemBox:setScale(param.scale or 0.4)
        local size = itemBox:boundingBox().size
        defaultOffset = ccp(size.width/2, size.height/2 + 3)
        table.insert(config, {oType = "node", node = itemBox, offset = param.offset or defaultOffset} )
    end
end

function QRichText:getNode_BMFont( config, param )
    -- body
    if not param then
        return
    end
    if not param.content or not param.fontName then
       return
    end
    param.fontName = string.format("font/%s.fnt", param.fontName)
    local label = createBmFont(param)
    table.insert(config, {oType = "node", node = label})
end


function QRichText:convertColorWithX(colorStr)
    local color = tonumber(string.format("%d",colorStr))
    local r = 0 
    local g = 0 
    local b = 0
    b = color%16
    color = math.floor(color/16)
    b = b + (color%16) * 16
    color = math.floor(color/16)
    g = color%16
    color = math.floor(color/16)
    g = g + (color%16) * 16
    color = math.floor(color/16)
    r = color%16
    color = math.floor(color/16)
    r = r + (color%16) * 16

    return ccc3(r,g,b)
end

function QRichText:parseHTML(str)
    local htmlTbl = html.parsestr(str)
    return self:convertHTML(htmlTbl)
end

function QRichText:convertHTML(tbl)
    local index = 1
    local richTextCfg = {}
    local attr = tbl._attr or {}
    local tag = tbl._tag
    local color = nil
    if attr.color ~= nil then
        color = self:convertColorWithX(attr.color)
    end
    while true do
        local content = tbl[index]
        if content == nil or type(content) ~= "table" then
            if tag == "img" then
                table.insert(richTextCfg, {oType = "img", plistName = attr.plist, fileName = attr.path, scalexy = ccp((attr.scaleX or 1), (attr.scaleY or 1)) })
            elseif content ~= nil and content ~= "" then
                if tag == "bmfont" then
                    table.insert(richTextCfg, {oType = "bmfont", content = content or "", fontName = attr.font or "font/FontAchievement.fnt", scale = attr.scale or 1, gap = -5})
                else
                    table.insert(richTextCfg, {oType = "font", content = content or "", size = attr.size, color = color})
                end
            end
        end
        if content ~= nil and type(content) == "table" then
            local childTbl = self:convertHTML(content)
            for _,child in ipairs(childTbl) do
                table.insert(richTextCfg, child)
            end
        end
        if content == nil then
            break
        end
        index = index + 1
    end
    return richTextCfg
end

return QRichText

