-- Filename：    LocalizedUtil.lua
-- Author：      Cheng Liang
-- Date：        2013-5-17
-- Purpose：     国际化方法

-- module("LocalizedUtil",package.seeall)

-- require "script/localized/LocalizedStrings_tw"

-- require "script/localized/LocalizedStrings_cn"
require "script/libs/LuaCCLabel"

local all_localFiles = {
    cn = "script/localized/LocalizedStrings_cn",
    tw = "script/localized/LocalizedStrings_tw",
    th = "script/localized/LocalizedStrings_th",
    en = "script/localized/LocalizedStrings_en",
    vn = "script/localized/LocalizedStrings_vn",
}

local m_language = "cn"

-- 默认cn
local function getAndroidLanguage( sys_lang )
    local m_lang = "cn"
    -- if( sys_lang == "zh_TW")then
    --     m_lang = "tw"
    -- elseif ( sys_lang == "th_TH") then
    --     m_lang = "th"
    -- else
    --     m_lang = "cn"
    -- end
    if(type(Platform.getConfig().getLanguage) == "function")then
        if Platform.getConfig().getLanguage() ~= nil 
            and Platform.getConfig().getLanguage() ~= "" then
            m_lang = Platform.getConfig().getLanguage()
        else
            m_lang = "cn"
        end
    end
    print("m_lang:",m_lang)
    return m_lang
end

-- 默认cn
local function getIOSLanguage( sys_lang )
    local m_lang = "cn"
    -- if( sys_lang == "zh-Hant")then
    --     m_lang = "tw"
    -- elseif( sys_lang == "th")then
    --     m_lang = "th"
    -- else
    --     m_lang = "cn"
    -- end
    if(type(Platform.getConfig().getLanguage) == "function")then
        if Platform.getConfig().getLanguage() ~= nil 
            and Platform.getConfig().getLanguage() ~= "" then
            m_lang = Platform.getConfig().getLanguage()
        else
            m_lang = "cn"
        end
    end
    print("m_lang:",m_lang)
    return m_lang
end


-- 初始化
function InitLocalized( ... )
    -- package.loaded[all_localFiles[m_language]] = nil
    require "script/utils/LuaUtil"
    if(NSBundleInfo)then
        local sys_lang = NSBundleInfo:getSysLanguage()
        if(Platform.getOS() == "ios")then
            m_language = getIOSLanguage(sys_lang)
        else
            m_language = getAndroidLanguage(sys_lang)
        end

    else
        m_language = "cn"
    end
    require (all_localFiles[m_language])
end

InitLocalized()

--[[
  @des:得到本地化的字符串
  @param:一次传入需要的参数，但是第一个参数必须是LocalizedStrings 中的key，第二个及后续的参数都是需要替换的参数
  @return: string 本地化的字符串结果
]]
function GetLocalizeStringBy( local_key,  ... )
    

    local l_strings = GetLocalizedSourceStringsByKey(local_key)
    if( not table.isEmpty({...}) )then
        -- l_strings = replace(l_strings, SplitStrings, args)
        l_strings = string.format(l_strings, ...)
    end

    return l_strings
end

--[[
  @des:本地化的字符串替换
  @param:str 源字符串(string)， 分割字符串(string)， 需要依次替换的变量(table)
  @return: string 本地化的字符串结果
]]
-- function replace(str, split_char, t_replace)
--     local nSepLen = string.len(split_char)

--     local result_str = ""

--     for k, rep_str in pairs(t_replace) do
--         local pos = string.find(str, split_char)
--         if (not pos) then
--             result_str = result_str .. str
--             break
--         end
--         local sub_str = string.sub(str, 1, pos - 1)
--         if(sub_str == nil)then
--             sub_str = ""
--         end
--         result_str = result_str .. sub_str .. rep_str
--         str = string.sub(str, pos + nSepLen, #str)
--     end
--     return result_str
-- end


--[[
    @des:   返回一个贴满Label的Sprite
    @param: local_key(国际化文件中对应的Key) ， 
            local_infos(table, 包括maxWidth/最大宽度, localColor/本地字符串的颜色, localFontSize/本地字符串的大小, localLabelType/本地字符串的Label类型)
            textInfos需要依次替换的变量, 每个变量都是table
    
    @sample: textInfos 的结构
     Table
      (
           [1] => Table
              (
                   [ntype] => strokeLabel
                   [fontSize] => 23
                   [text] => 121007
                   [color] => ccc3( 0x00, 0x00, 0x00)
               )
            ...
       )

    @return: string 本地化, 多个Label构成的Sprite
]]
function GetLocalizeLabelSpriteBy( local_key, local_infos, textInfos )
    if(table.isEmpty(textInfos) == true)then
        return
    end
    if(table.isEmpty(local_infos) == true )then
        local_infos = {}
    end

    localColor      = local_infos.localColor or ccc3(255,255,255)
    localFontSize   = local_infos.localFontSize or 23
    localLabelType  = local_infos.localLabelType or "label"
    localFont       = local_infos.font or g_sFontName

    local multiTextInfo = getMutiTextInfoFromReplaceStr(GetLocalizedSourceStringsByKey(local_key), SplitStrings, textInfos, localColor, localFontSize, localLabelType, localFont)

    return createMultiColorLabelSprite(multiTextInfo, local_infos.maxWidth)
end

-- added by bzx
function GetNewRichInfo(local_key, richInfo)
    local newRichInfo = table.hcopy(richInfo, {})
    newRichInfo.elements = {}
    local format = GetLocalizedSourceStringsByKey(local_key)
    if format == nil then
        format = local_key
    end
    local texts = {}
    local starPos = 1
    local pos = string.find(format, "%" .. SplitStrings)
    while pos ~= nil do
        if pos == starPos then
            table.insert(texts, SplitStrings)
            starPos = pos + 2
        else
            table.insert(texts, string.sub(format, starPos, pos - 1))
            starPos = pos
        end
        pos = string.find(format, "%" .. SplitStrings, starPos)
    end
    if starPos < string.len(format) then
        table.insert(texts, string.sub(format, starPos))
    end
    local index = 1
    for i = 1, #texts do
        local text = texts[i]
        local element = nil
        if text ~= SplitStrings then
            element = {}
            element.text = text
        else
            element = richInfo.elements[index]
            index = index + 1
        end
        table.insert(newRichInfo.elements, element)
    end
    return newRichInfo
end

-- added by bzx
function GetLocalizeLabelSpriteBy_2( local_key, richInfo )
    local newRichInfo = GetNewRichInfo(local_key, richInfo)
    local node = LuaCCLabel.createRichLabel(newRichInfo)
    return node
end

--[[
    @desc: 将本地化字符串分解成多个table
    @return ；返回结构如下
        Table
        (
             [1] => Table
                (
                     [ntype] => strokeLabel
                     [fontSize] => 23
                     [text] => 121007
                     [color] => ccc3( 0x00, 0x00, 0x00)
                 )
              ...
         )
]]
function getMutiTextInfoFromReplaceStr(str, split_char, t_replace, localColor, localFontSize, localLabelType, localFont)
    local nSepLen = string.len(split_char)

    local result_str = ""
    local multiTextInfo = {}
    for k, rep_t in pairs(t_replace) do
        -- %s 转义
        local pos = string.find(str, "%"..split_char)
        if (not pos) then
            if(str ~= nil and str ~= "")then
                local textInfo = {}
                textInfo.color = localColor
                textInfo.fontSize = localFontSize
                textInfo.ntype = localLabelType
                textInfo.text = str
                textInfo.font = localFont
                table.insert(multiTextInfo, textInfo)
            end
            break
        end
        local sub_str = string.sub(str, 1, pos - 1)

        if(sub_str ~= nil and sub_str ~= "")then
            -- 原来的字符
            local textInfo = {}
            textInfo.color = localColor
            textInfo.fontSize = localFontSize
            textInfo.ntype = localLabelType
            textInfo.text = sub_str
            textInfo.font = localFont
            table.insert(multiTextInfo, textInfo)
        end

        -- 替换的字符串
        table.insert(multiTextInfo, rep_t)

        -- 截取的剩下的字符串
        str = string.sub(str, pos + nSepLen, #str)
    end
    -- 最后尾部的字符串
    if(str ~= nil and str ~= "")then
        local textInfo = {}
        textInfo.color = localColor
        textInfo.fontSize = localFontSize
        textInfo.ntype = localLabelType
        textInfo.text = str
        textInfo.font = localFont

        table.insert(multiTextInfo, textInfo)
    end
    return multiTextInfo
end

--创建Label
function createMultiTextNode(nodeInfo)
    local font      = nodeInfo.font or g_sFontName
    local fontSize  = nodeInfo.fontSize or 23
    local color     = nodeInfo.color or ccc3(255,255,255)
    local content   = nodeInfo.text or ""
    local l_type    = nodeInfo.ntype or "label"
    local tag       = nodeInfo.tag or 1

    local resultNode
    if(l_type=="label")then
        resultNode = CCLabelTTF:create(tostring(content),font,fontSize)
        resultNode:setColor(color)
        resultNode:setTag(tag)
        resultNode:setAnchorPoint(ccp(0,0))
    elseif(l_type=="strokeLabel")then
        local strokeSize = nodeInfo.strokeSize or 1
        local strokeColor = nodeInfo.strokeColor or ccc3( 0x00, 0x00, 0x00)
        
        resultNode = CCRenderLabel:create(tostring(content), font, fontSize, strokeSize, strokeColor, type_stroke)
        resultNode:setColor(color)
        resultNode:setTag(tag)
    elseif(l_type == "image")then
        resultNode = CCSprite:create(nodeInfo.image)
    else
        print("error: nodeInfo.ntype is not correct!")
    end
    
    return resultNode
end

--[[
    multiTextInfo的结构
    Table
      (
           [1] => Table
              (
                   [ntype] => strokeLabel
                   [fontSize] => 23
                   [text] => 121007
                   [color] => ccc3( 0x00, 0x00, 0x00)
               )
            ...
       )
    maxWidth: 最大宽度 如果超过最大宽度会变成多行

    @return: string 本地化, 多个Label构成的Sprite
]]
function createMultiColorLabelSprite( multiTextInfo, maxWidth, multiLineTextAlignment )
    
    if(maxWidth == nil)then
        maxWidth = 9999
    end 
    local curRowWidth = 0       -- 当前行的宽度
    local curRowIndex = 1       -- 行数
    local curRowCount = 0       -- 当前行的Label个数
    local rowElements = {}      -- 所有行中得Label

    local realMaxWidth = 0      -- 实际的最大宽度
    local realMaxHeight = 0     -- sprite 的实际高度
    local maxRowHeight = 0      -- 所有label中的最大label高度

    -- 算X坐标
    for k, nodeInfo in pairs(multiTextInfo) do
        local label = createMultiTextNode(nodeInfo)
        label:setAnchorPoint(ccp(0,0.5))
        if(curRowWidth + label:getContentSize().width <= maxWidth)then
            -- 宽度没有超过
        else
            -- 已经超过宽度，换行
            curRowIndex = curRowIndex +1
            curRowCount = 0
            curRowWidth = 0
        end

        label:setPositionX(curRowWidth)
            
        curRowWidth = curRowWidth + label:getContentSize().width

        -- 实际的最大宽度
        realMaxWidth = realMaxWidth > curRowWidth and  realMaxWidth or curRowWidth
        -- 所有label中的最大label高度
        local curLabelHeight = label:getContentSize().height
        maxRowHeight = maxRowHeight > curLabelHeight and maxRowHeight or curLabelHeight

        if( rowElements[curRowIndex] == nil )then
            rowElements[curRowIndex] = {}
        end
        curRowCount = curRowCount + 1
        rowElements[curRowIndex][curRowCount] = label
    end

    -- 算Y坐标
    realMaxHeight = maxRowHeight * curRowIndex
    local m_sprite = CCSprite:create()
    m_sprite:setContentSize(CCSizeMake(realMaxWidth, realMaxHeight))
    for rowIndex, labelArr in pairs(rowElements) do
        local rowY = realMaxHeight - rowIndex * maxRowHeight + maxRowHeight*0.5
        for k, c_label in pairs(labelArr) do
            c_label:setPositionY(rowY)
            m_sprite:addChild(c_label)
        end
    end


    return m_sprite
end

