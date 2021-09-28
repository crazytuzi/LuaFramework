local info = {}
local drumCfg = def.drumCfg
local drumStrengthenCfg = def.drumStrengthenCfg
info.show = function (drumLevel, drumStrengthenLevel, job, scenePos, params)
	local curStrengthenPropertyName = {}
	local curStrengthenPropertyValue = {}
	local strCurrentProperty = drumCfg[drumLevel].PropertyStr
	local propertyItems = string.split(strCurrentProperty, ";")
	local selfJobProperty = {
		propertyItems[job*2 + 1],
		propertyItems[job*2 + 2],
		propertyItems[job + 7],
		propertyItems[job + 10],
		propertyItems[job + 13]
	}
	local drumPropertyName = {}
	local drumPropertyValue = {}

	for i, v in ipairs(selfJobProperty) do
		local itemNameAndValue = string.split(v, "=")
		drumPropertyName[#drumPropertyName + 1] = itemNameAndValue[1]
		drumPropertyValue[#drumPropertyValue + 1] = itemNameAndValue[2]
	end

	if 1 <= drumStrengthenLevel then
		local strCurStrengthenProperty = drumStrengthenCfg[drumStrengthenLevel].PropertyStr
		local propertyItems = string.split(strCurStrengthenProperty, ";")
		local selfJobProperty = {
			propertyItems[job + 1],
			propertyItems[job + 4],
			propertyItems[job + 7],
			propertyItems[job + 10],
			propertyItems[job + 13],
			propertyItems[job + 16],
			propertyItems[job + 19]
		}

		for i, v in ipairs(selfJobProperty) do
			local itemNameAndValue = string.split(v, "=")
			curStrengthenPropertyName[#curStrengthenPropertyName + 1] = itemNameAndValue[1]
			curStrengthenPropertyValue[#curStrengthenPropertyValue + 1] = itemNameAndValue[2]
		end
	end

	local maxWidth = 300
	local layer = display.newNode():size(display.width, display.height):addto(params.parent or display.getRunningScene(), params.z or an.z.max)

	layer.setTouchEnabled(layer, true)
	layer.setTouchSwallowEnabled(layer, false)

	if not params.fromSmelting then
		layer.addNodeEventListener(layer, cc.NODE_TOUCH_CAPTURE_EVENT, function (event)
			if event.name == "ended" then
				g_data.player.showTips = false

				layer:runs({
					cc.DelayTime:create(0.01),
					cc.RemoveSelf:create(true)
				})

				info.layer = nil
			end

			return true
		end)
	end

	info.layer = layer
	local labels = {}

	function add(text, color, fontSize)
		text = text or ""
		labels[#labels + 1] = an.newLabel(text, fontSize or 20, 1, {
			color = color
		})

		if maxWidth < labels[#labels]:getw() then
			labels[#labels]:setWidth(maxWidth)
			labels[#labels]:setLineBreakWithoutSpace(true)
			labels[#labels]:updateContent()
		end

		return 
	end

	local attackName = {
		"攻击",
		"魔法",
		"道术"
	}
	local myAttackName = attackName[job + 1]

	add(slot16 .. ": " .. drumPropertyValue[1] .. "-" .. drumPropertyValue[2], display.COLOR_WHITE)
	add("生命值: +" .. drumPropertyValue[3], display.COLOR_WHITE)

	if curStrengthenPropertyName and 0 < #curStrengthenPropertyName then
		add("\n启封属性:", cc.c3b(0, 176, 240))

		for i, v in ipairs(curStrengthenPropertyName) do
			propertyName = string.sub(curStrengthenPropertyName[i], 7, #curStrengthenPropertyName[i])

			add(propertyName .. ": +" .. curStrengthenPropertyValue[i], display.COLOR_WHITE)
		end
	end

	add("\n需要等级: " .. common.getLevelText(drumCfg[drumLevel].UpNeedPlayerLevel) .. "级", display.COLOR_WHITE)
	add(drumCfg[drumLevel].Desc, display.COLOR_WHITE)

	local bg = display.newScale9Sprite(res.getframe2("pic/scale/scale24.png")):addto(layer):anchor(0, 1)
	local w = 0
	local h = 7
	local space = -2

	for i = #labels, 1, -1 do
		local lh = 0
		w = math.max(w, labels[i]:getw())
		lh = labels[i]:geth()

		labels[i]:addto(bg, 99):pos(10, h):anchor(0, 0)

		local words = utf8strs(labels[i]:getString())
		h = h + lh + space
	end

	local content = an.newLabelM(maxWidth, 20, 1):anchor(0, 0):addto(bg, 99):pos(10, h):anchor(0, 0)
	local textJob = {
		"(战)",
		"(法)",
		"(道)"
	}
	local drumName = drumLevel .. "级军鼓" .. textJob[job + 1]

	content.addLabel(content, drumName, cc.c3b(255, 255, 0))

	local lineNode = content.getCurLabel(content)
	h = h + lineNode.geth(lineNode) + space
	w = math.max(w, content.widthCnt)
	w = w + 20
	h = h + 10

	bg.size(bg, w, h)

	local rect = cc.rect(0, 0, display.width, display.height)
	local p = scenePos

	if p.x < rect.x then
		p.x = rect.x
	end

	if rect.width < p.x + w then
		p.x = p.x - w + 5
	end

	if rect.height < p.y then
		p.y = rect.height
	end

	if p.y - h < rect.y then
		p.y = p.y + h
	end

	bg.pos(bg, p.x, p.y)

	return layer
end

return info
