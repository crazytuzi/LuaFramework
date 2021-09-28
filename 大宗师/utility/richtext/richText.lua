--
-- Author: zhouhongjie@apowo.com
-- Date: 2014-07-08 15:27:57
--
require("utility.richtext.globalFunction")
local nodeType = {startTag = 0, text = 1, endTag = 2}

local function parseHtml(htmlText)
    local nodeList, node = {}, {}
    local char, charByte = nil, nil
    local isParseTaging = false

    local l = string.len(htmlText)
    for i = 1, l do
        char = string.sub(htmlText, i, i)
        charByte = string.byte(char)
        if charByte == 60 then
            -- <
            isParseTaging = true
            if node.type then
                nodeList[#nodeList + 1] = node
                node = {}
            end
            if string.byte(string.sub(htmlText, i + 1, i + 1)) == 47 then
                -- </ 这是闭合的标签
                node = {type = nodeType.endTag, text = ''}
            else
                -- 这是非闭合的标签
                node = {type = nodeType.startTag, text = ''}
            end
        elseif charByte == 62 then
            -- >
            isParseTaging = false
            if node.type then
                nodeList[#nodeList + 1] = node
                node = {}
            end
        elseif charByte ~= 47 then
            if isParseTaging then
                node.text = node.text .. char
            else
                if not node.type then
                    node.type = nodeType.text
                    node.text = ''
                end
                node.text = node.text .. char
            end
        end
    end

    for i, v in ipairs(nodeList) do
        if v.type == nodeType.startTag then
            local ary = string.split(v.text, ' ')
            v.tag = ary[1]
            -- 标签属性
            v.props = {}
            for i = 2, #ary do
                v.props[#v.props + 1] = string.split(ary[i], '=')
            end
            v.text = nil
        elseif v.type == nodeType.endTag then
            v.tag = string.split(v.text, ' ')[1]
            v.text = nil
        end
    end
    return nodeList
end

function getRichText(htmlText, lineWidth, hrefHandler)

    function createLabel(props, node, x, y, a)
        local label = ui.newTTFLabel(props):addTo(node):pos(x, y)
        label:setAnchorPoint(display.ANCHOR_POINTS[display.LEFT_BOTTOM])
        if a.href then
            label._href = a.href

            -- 加个下划线
            local str = '_'
            props.text = str
            local t = ui.newTTFLabel(props)
            for i = 1, checkint(label:getContentSize().width / t:getContentSize().width) - 1 do
                str = str .. '_'
            end
            t:setString(str)
            t:pos(x, y):addTo(node)
            t:setAnchorPoint(display.ANCHOR_POINTS[display.LEFT_BOTTOM])

            -- 注册点击事件
            label:setTouchEnabled(true)
            label:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
                if event.name == 'began' then
                    return true
                elseif event.name == 'ended' then
                    -- print('打开连接:' .. label._href)
                    if type(hrefHandler) == "function" then
                        hrefHandler(label._href)
                    end
                end
            end)
        end
        return label
    end

    lineWidth = lineWidth or 400
    local node = display.newNode()

    local nodeList = parseHtml(htmlText)
    -- 默认的字体属性
    local fontProps = {x = 0, y = 0, size = ui.DEFAULT_TTF_FONT_SIZE, font = ui.DEFAULT_TTF_FONT, align = ui.TEXT_ALIGN_LEFT}
    -- a属性
    local a = { }
    local label = nil
    local leftWidth, leftStr, lineHeight = lineWidth, nil, 0
    local x, y = 0, 0
    -- 当前行数
    local curLine = 1
    local labelList = {}
    local totalHeight = lineHeight
    for i, v in ipairs(nodeList) do
        if v.type == nodeType.startTag then
            local props = v.props
            if v.tag == 'font' then
                fontProps.size = ui.DEFAULT_TTF_FONT_SIZE
--                fontProps.font = ui.DEFAULT_TTF_FONT
                fontProps.font = FONTS_NAME.font_fzcy
                fontProps.color = display.COLOR_WHITE
                for ii, vv in ipairs(props) do
                    if vv[1] == 'size' then
                        fontProps.size = checkint(string.gsub(vv[2], "\"", ""))
                    elseif vv[1] == 'color' then
                        -- 因为颜色Str为“#ff00ff”,所以要从第三个算起
                        local colorStr = string.sub(vv[2], 3)
                        fontProps.color = ccc3(
                                                checkint(string.format("%d", '0x' .. string.sub(colorStr, 1, 2))), 
                                                checkint(string.format("%d", '0x' .. string.sub(colorStr, 3, 4))), 
                                                checkint(string.format("%d", '0x' .. string.sub(colorStr, 5, 6)))
                                            )
                    end
                end
            elseif v.tag == 'a' then
                for ii, vv in ipairs(props) do
                    if vv[1] == 'href' then
                        a.href = vv[2]
                    end
                end
            end   
        elseif v.type == nodeType.endTag then
           if v.tag == 'a' then
               a.href = nil
           end
        else
            -- 文本内容
            fontProps.text, leftStr, lineHeight = getSubStrByWidth(v.text, fontProps.font, fontProps.size, leftWidth)
            if fontProps.text then
                label = createLabel(fontProps, node, x, y, a)
                label._line = curLine
                labelList[#labelList + 1] = label
            end
            y = y - lineHeight
            curLine = curLine + 1
            -- 算出这一行还剩下多少宽度
            leftWidth = leftWidth - label:getContentSize().width
            totalHeight = lineHeight
            while leftStr and leftStr ~= '' do
                -- 如果有leftStr吗，说明这一段文字的宽度超过了一行中的剩下的宽度
                -- 那就转到下一行，继续进行截取
                x = 0
                fontProps.text, leftStr, lineHeight = getSubStrByWidth(leftStr, fontProps.font, fontProps.size, lineWidth)
                if fontProps.text then
                    label = createLabel(fontProps, node, x, y, a)
                    label._line = curLine
                    labelList[#labelList + 1] = label
                end
                y = y - lineHeight
                curLine = curLine + 1
                totalHeight = totalHeight + lineHeight
            end
            -- 截取完毕，剩下的宽度是总宽度减去当前行中其他label宽度的总和
            local totalWidth = 0
            for i, v in ipairs(labelList) do
                if v._line == curLine - 1 then
                    totalWidth = totalWidth + v:getContentSize().width
                end
            end
            leftWidth = lineWidth - totalWidth

            if leftWidth < fontProps.size then
                leftWidth = lineWidth
            end
            if leftWidth < lineWidth then
                x = x + label:getContentSize().width
                y = y + lineHeight
                curLine = curLine - 1
            else
                x = 0
            end
        end
    end
    node:setContentSize(CCSizeMake(lineWidth, totalHeight))
--    local layer = display.newColorLayer(ccc4(255, 0, 0, 170))
--    layer:setContentSize(CCSizeMake(lineWidth, totalHeight))
--    node:addChild(layer, 0)

    return node
end