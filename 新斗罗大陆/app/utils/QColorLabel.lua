-- Author: qinyuanji
-- 2015/03/04
-- This class is to allow multiple colors in one text
-- The input colorful string should be in format: ##rtext##wtext\n##btext##ctext

local QColorLabel = class("QColorLabel")
local QMaskWords = import(".QMaskWords")
local QRichText = import(".QRichText")

QColorLabel.COLORSEPARATOR = "##"
QColorLabel.FONT_SIZE = 24

QColorLabel.COLORS = {
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
    t = nil, -- 空位
    u = nil, -- 空位
    v = ccc3(236, 111, 0), -- 传灵塔分享自己暗色地板颜色
    w = COLORS.b,
    x = COLORS.m,
    y = COLORS.G,
    z = nil,             -- 用设定的默认颜色
}
QColorLabel.FACE_NAME = {
    "【#啊】","【#傲娇】","【#呲牙】","【#发奋】","【#害羞】","【#嘿嘿】","【#花痴】","【#滑稽】","【#惊讶】","【#抠鼻】","【#流泪】","【#卖萌】",
    "【#墨镜】","【#目瞪】","【#怒火】","【#去世】","【#示爱】","【#旺柴】","【#吓死】","【#阴险】"
}

-- mask: sensitive words filter
-- size: font size
-- deprecated
function QColorLabel:create(message, width, height, mask, size, color, fontName, isLight, autoCenter)
    local defaultColor = color or QColorLabel.COLORS["w"]
    local output = self:parseMessage(message, mask, defaultColor)

    local txtConfig = {}
    for i = 1, #output do
        if output[i].lineBreak then
            table.insert(txtConfig, {oType = "wrap"})
        else
            local c = output[i].color or defaultColor
            table.insert(txtConfig, {oType = "font", content = output[i].message, size = size, color = c, isLight = isLight})
        end
    end
    local rt = QRichText.new(txtConfig, width, {fontName = fontName or global.font_default, autoCenter = autoCenter})
    rt:setAnchorPoint(ccp(0,1))
    rt.getActualHeight = function ()
        return rt:getContentSize().height
    end
    return rt
end

function QColorLabel:createForChat(message, width, height, mask, size, color, fontName, isLight, autoCenter,btnTipsPath,mastScale)

    local newMessage = message
    local faceTble = QColorLabel.FACE_NAME
    for index, v in ipairs(faceTble) do
        for w in string.gmatch(newMessage, v) do
            newMessage = string.gsub(newMessage or "", w, "#"..index)
        end
    end
    
    local defaultColor = color or QColorLabel.COLORS["w"]
    local output = self:parseMessage(newMessage, mask, defaultColor)
    local faceStr = {}
    local txtConfig = {}
    for i = 1, #output do
        if output[i].lineBreak then
            table.insert(txtConfig, {oType = "wrap"})
        else
            local c = output[i].color or defaultColor
            local pos1,pos2 = string.find(output[i].message,"#[0-9]*") 
            if pos1 ~=nil and pos2 > 0 then
                faceStr = self:parseStringToFace(output[i].message,c,isLight,mastScale)
                for _,v in pairs(faceStr) do
                    table.insert(txtConfig,v)
                end
            else
                table.insert(txtConfig, {oType = "font", content = output[i].message, size = size, color = c, isLight = isLight})
            end
        end
    end
    if btnTipsPath then
        table.insert(txtConfig, {oType = "img",fileName = btnTipsPath})
    end

    local rt = QRichText.new(txtConfig, width, {fontName = fontName or global.font_default, autoCenter = autoCenter})
    rt:setAnchorPoint(ccp(0,1))
    rt.getActualHeight = function ()
        return rt:getContentSize().height
    end
    return rt
end

function QColorLabel:parseStringToFace(str,color,isLight,mastScale)
    local facePath = nil
    local config = {}
    local faceScale = false
    local haveFace = false
    local msg = string.split(str, "#")
    if msg[1] ~= "" then
        local message = msg[1]
        faceScale = true
        table.insert(config, {oType = "font", content = message, color = color,isLight = isLight})
    end
    for i = 2, #msg do
        if msg[i] ~= "" then
            local message = nil
            -- local pos1,pos2 = string.find(msg[i],"#[0-9]*")
            local pos1,pos2 = string.find(msg[i],"[0-9]*")
            if pos1 ~=nil and pos2 > 0 then
                local pathPos = string.sub(msg[i], pos1, pos2)
                message = string.sub(msg[i], pos2+1)
                facePath = QResPath("chat_face_path")[tonumber(pathPos)]
            else
                facePath = nil
                message = string.sub(msg[i], pos2)
            end
            if facePath then
                haveFace = true
                table.insert(config, {oType = "img",fileName = facePath,offsetY = 3,scale = (mastScale == true and 0.5 or 0.6)})
            end
            if message ~= "" then
                faceScale = true
                table.insert(config, {oType = "font", content = message, color = color,isLight = isLight})
            end
        end
    end
    
    if q.isEmpty(config) then
        table.insert(config, {oType = "font", content = str, color = color,isLight = isLight})
    end
    
    return config,faceScale,haveFace
end
function QColorLabel:parseMessage(rawMessage, mask, defaultColor)
    local returnMsg = string.split(rawMessage, "\n")
    local lastColor, colorStr = nil, nil
    local output = {}

    for k, v in ipairs(returnMsg) do
        local msg = string.split(v, QColorLabel.COLORSEPARATOR)
        if msg[1] ~= "" then
            local message = msg[1]
            if mask then
                message = QMaskWords:process(message, "***")
            end
            table.insert(output, {message = message, color = lastColor})
        end

        for i = 2, #msg do
            if msg[i] ~= "" then
                local message = nil
                local pos1,pos2 = string.find(msg[i],"0x[0-9|(a-f)|(A-F)]*")
                if pos2 ~= nil and pos2 > 2 then
                    pos2 = math.min(pos2, pos1+7)
                    colorStr = string.sub(msg[i], pos1, pos2)
                    lastColor = self:convertColorWithX(colorStr) or defaultColor
                    message = string.sub(msg[i], pos2+1)
                else
                    lastColor = string.sub(msg[i], 1, 1)
                    lastColor = QColorLabel.COLORS[lastColor] or defaultColor
                    message = string.sub(msg[i], 2)
                end
                if mask then
                    message = QMaskWords:process(message, "***")
                end
                table.insert(output, {message = message, color = lastColor})
            end
        end
        table.insert(output, {lineBreak = true})
    end

    return output
end

function QColorLabel:convertColorWithX(colorStr)
    local color = tonumber(colorStr)
    if color == nil then
        return nil
    end
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

--[[
    去除一段话中的颜色标识
]]
function QColorLabel.removeColorSign(str)
    if str == nil then return "" end
    local str = string.gsub(str, QColorLabel.COLORSEPARATOR.."%a", "")
    return str
end

-- 根据暗底 亮底替换强调色和普通色
function QColorLabel.replaceColorSign(str, isDark)
    local newStr = str
    if isDark then
        newStr = string.gsub(newStr or "", "##S", "##w")
        newStr = string.gsub(newStr or "", "##o", "##w")
        newStr = string.gsub(newStr or "", "##e", "##w")
        newStr = string.gsub(newStr or "", "##z", "##j")
        newStr = string.gsub(newStr or "", "##N", "##j")
        newStr = string.gsub(newStr or "", "##d", "##j")
        newStr = string.gsub(newStr or "", "##n", "##j")
    else
        newStr = string.gsub(newStr or "", "##S", "##e")
        newStr = string.gsub(newStr or "", "##o", "##e")
        newStr = string.gsub(newStr or "", "##e", "##e")
        newStr = string.gsub(newStr or "", "##N", "##n")
        newStr = string.gsub(newStr or "", "##z", "##n")
        newStr = string.gsub(newStr or "", "##d", "##n")
    end
    return newStr
end

-- 传灵塔分享 根据亮暗底替换npc颜色
function QColorLabel.blackRockReplaceColorSign(str,isDark)
    local newStr = str
    if isDark then
        newStr = string.gsub(newStr or "", "##o", "##v")
    else
        newStr = string.gsub(newStr or "", "##k", "##o")
    end
    return newStr
end

-- 没有激活将颜色标识替换为##c
function QColorLabel.replaceColorNotActive(str)
    local newStr = str
    newStr = string.gsub(newStr or "", "##S", "##c")
    newStr = string.gsub(newStr or "", "##N", "##c")
    return newStr
end
return QColorLabel