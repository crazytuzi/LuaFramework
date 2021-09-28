local info = {
	show = function (labels, scenePos, params)
		params = params or {}
		local node = display.newNode():size(display.width, display.height):addto(main_scene.ui, main_scene.ui.z.textInfo)

		node.setTouchEnabled(node, true)
		node.setTouchSwallowEnabled(node, false)
		node.addNodeEventListener(node, cc.NODE_TOUCH_EVENT, function (event)
			if event.name == "ended" then
				node:removeSelf()
			end

			return true
		end)

		local bg = display.newScale9Sprite(res.getframe2("pic/scale/scale4.png")).addto(slot4, node):anchor(0, 1)
		local w = 0
		local h = 7
		local space = params.space or -2

		for i = #labels, 1, -1 do
			local v = labels[i]:addto(bg, 99):anchor(0, 0):pos(10, h)
			w = math.max(w, v.getw(v))
			h = h + v.geth(v) + space
		end

		w = w + 20
		h = h + 10
		local p = scenePos

		if p.x < 0 then
			p.x = 0
		end

		if display.width < p.x + w then
			p.x = display.width - w
		end

		if display.height < p.y then
			p.y = display.height
		end

		if p.y - h < 0 then
			p.y = h
		end

		bg.size(bg, w, h):pos(p.x, p.y)

		return node
	end
}

return info
