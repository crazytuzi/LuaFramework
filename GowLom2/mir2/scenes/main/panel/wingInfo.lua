local info = {
	show = function (data, scenePos, params)
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

		for i, v in ipairs(info) do
			add(v[1], v[2])
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

		w = w + 20
		h = h + 10

		bg.size(bg, w, h)

		local rect = cc.rect(params.minx or 0, params.miny or 0, params.maxx or display.width, params.maxy or display.height)
		local p = scenePos

		if p.x < rect.x then
			p.x = rect.x
		end

		if rect.width < p.x + w then
			p.x = p.x - w
		end

		if params.showType == "up" then
			if rect.height < p.y + h then
				p.y = rect.height - h
			end

			if p.y < rect.y then
				p.y = p.y
			end

			bg.pos(bg, p.x, p.y + h)
		else
			if rect.height < p.y then
				p.y = rect.height
			end

			if p.y - h < rect.y then
				p.y = p.y + h

				if rect.height < p.y then
					p.y = rect.height
				end
			end

			bg.pos(bg, p.x, p.y)
		end

		return layer
	end,
	close = function ()
		if info.layer then
			g_data.player.showTips = false

			info.layer:runs({
				cc.DelayTime:create(0.01),
				cc.RemoveSelf:create(true)
			})

			info.layer = nil
		end

		return 
	end,
	clear = function ()
		info.layer = nil

		return 
	end,
	numToGBK = function (num)
		local TXT_NUM = {
			"一",
			"二",
			"三",
			"四",
			"五",
			"六",
			"七",
			"八",
			"九",
			"十"
		}

		if TXT_NUM[num] then
			return TXT_NUM[num]
		else
			return TXT_NUM[1]
		end

		return 
	end
}

return info
