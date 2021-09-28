local info = {
	show = function (infoName, tItems, scenePos)
		local maxWidth = 300
		local layer = display.newNode():size(display.width, display.height):addto(display.getRunningScene(), an.z.max)

		layer.setTouchEnabled(layer, true)
		layer.setTouchSwallowEnabled(layer, false)
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

		add("°üº¬:", display.COLOR_WHITE)

		for i, v in ipairs(slot1) do
			add(v.name .. "*" .. v.num, display.COLOR_WHITE)
		end

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

		content.addLabel(content, infoName, cc.c3b(255, 255, 0))

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
}

return info
