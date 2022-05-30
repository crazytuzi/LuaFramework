--递归改变颜色
function setAllChildColorScale( root, scale )
    local cur_col = root:getColor()
    root:setColor(cc.c3b(scale*cur_col.r, scale*cur_col.g, scale*cur_col.b))
    for i, v in pairs(root:getChildren()) do
        cur_col = v:getColor()
        v:setColor(cc.c3b(scale*cur_col.r, scale*cur_col.g, scale*cur_col.b))
        --v:setColor(col)
        setAllChildColorScale(v, scale)
    end
end

--递归设置颜色滤镜
function setAllChildFilter(root, enable, path, color)
    if tolua.isnull(root) then return end
    color = color or Config.ColorData.data_new_color4[1]
    path = path or ""
    if root.setFilterStatus then
    	root:setFilterStatus(enable, path, color)
    end
	for i, v in pairs(root:getChildren()) do
		setAllChildFilter(v, enable, path, color)
	end
end

CustomTool = CustomTool or {}

--[[
@功能:创建label
@参数:
]]
function CustomTool.createLabel(color,color1,font_size,anchor)
    local label = createWithSystemFont("", DEFAULT_FONT, font_size)
    label:setTextColor(color)
    if color1 then
        label:enableOutline(color1,1)
    end

    if anchor then
        label:setAnchorPoint(anchor)
    end
    return label
end 

--[[
@功能:label换行
@参数:
]]
function CustomTool.calculation(label,width)
    if width ~= nil then
        local label_width = label:getContentSize().width
        local label_height = label:getContentSize().height
        if label_width > width then
            local line_num = math.ceil(label_width/width)
            label:setContentSize(cc.size(width, label_height*line_num))
            label:setWidth(width)
            label:setHeight(label_height*line_num)
        end
    end
    return label
end

-- 
function extend(target)
    local t = tolua.getpeer(target)
    if not t then
        t = {}
        tolua.setpeer(target, t)
    end
    setmetatable(t, DebugScene)
    return target
end