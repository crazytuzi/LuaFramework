--
-- <DIV> 标签解析
--
local function div_createlabel(self, word, fontname, fontsize, fontcolor)
	if word == "" then return end
	local label = createWithSystemFont(word, fontname, fontsize)
	if not label then 
		self:printf("<div> - create label failed")
		return
	end
	label:setColor(fontcolor)
    label.info = {word, fontname, fontsize, fontcolor}
    label.b_size = label:getBoundingBox()
	return label
end

local function div_parseshadow(self, shadow)
	if not shadow then return end
	-- 标准的格式：shadow=10,10,10,#ff0099
	-- (offset_x, offset_y, blur_radius, shadow_color)
	local params = self:split(shadow, ",")
	if #params~=4 then
		self:printf("parser <div> property shadow error")
		return nil
	end
	local offset_x = tonumber(params[1]) or 0
	local offset_y = tonumber(params[2]) or 0
	params.offset = cc.size(offset_x, offset_y)
	params.blurradius = tonumber(params[3]) or 0
	params.color = self:convertColor(params[4]) or cc.c4b(255,255,255,255)
	return params
end

local function div_parseoutline(self, outline)
	if not outline then return end
	-- 标准格式: outline=1,#ff0099
	-- (outline_size, outline_color)
	
	local params = self:split(outline, ",")
	if #params~=2 then
		self:printf("parser <div> property outline error")
		return nil
	end
	params.size = tonumber(params[1]) or 0
	params.color = self:convertColor(params[2]) or cc.c4b(255,255,255,255)
	return params
end 

local function div_parseglow(self, glow)
	if not glow then return end
	-- 标准格式: glow=#ff0099	
	-- (glow_color)
	local color = self:convertColor(glow) or cc.c4b(255,255,255,255)
	return {["color"]=color}
end

--
-- <div> Parser
--
return function (self, params, default)
	-- 将字符串拆分成一个个字符
	local content = params.content or ""
    params.charlist = self:stringToChars(content)
	-- 获得要设置的属性
	local fontname = params.fontname or default.fontName
	local fontsize = params.fontsize or default.fontSize
	local fontcolor = self:convertColor(params.fontcolor) or default.fontColor
	-- label effect
	local shadow_params = div_parseshadow(self, params.shadow)
	local outline = params.outline
	local outline_params = div_parseoutline(self, outline)
	local glow_params = div_parseglow(self, glow)
    params.create_node = function(str)
		local label = div_createlabel(self, str, fontname, fontsize, fontcolor)
        if label then
            if shadow_params then 
                label:enableShadow(shadow_params.color, shadow_params.offset, shadow_params.blurradius)
            end
            if outline_params then
                label:enableOutline(outline_params.color, outline_params.size)
            end
            if glow_params then
                label:enableGlow(glow_params.color)
            end
        end
        return label
    end
end
