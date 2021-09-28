local label = {
	debuginfo = "",
	allLabelCnt = 0,
	queueAddCnt = 0,
	allLabels = {},
	texCaches = {},
	queues = {}
}
local strokeLabel = nil
local scheduler = require("framework.scheduler")
cc.Label.getText = function (self)
	return self.getString(self)
end
cc.Label.setText = function (self, text)
	return self.setString(self, text)
end
cc.Label.addUnderline = function (self, color)
	color = color or self.getColor(self)

	if self.underline then
		self.underline:setColor(cc.c4b(color.r, color.g, color.b, 255))

		return 
	end

	local parent = self.getParent(self)

	if parent == nil then
		print("cc.Label.addUnderline: add underline failed! parent is nil!")

		return self
	end

	local sPos = cc.p(self.getPosition(self))
	local sCon = cc.p(self.getw(self), self.geth(self))
	local sAnchor = self.getAnchorPoint(self)
	sPos.x = sPos.x - sCon.x*sAnchor.x
	sPos.y = sPos.y - sCon.y*sAnchor.y
	self.underline = display.newColorLayer(cc.c4b(color.r, color.g, color.b, 255)):pos(sPos.x, sPos.y):size(math.max(1, self.getw(self)), 1):addto(parent, 1)

	return self
end
local defaultStrokeColor = cc.c4b(0, 0, 0, 255)
cc.Label.setStrokeColor = function (self, color)
	if self.strokeSize then
		self.enableOutline(self, color or self.strokeColor or defaultStrokeColor, self.strokeSize or 2)
	end

	return self
end
local defaultsc = cc.c4b(0, 0, 0, 255)
label.new = function (text, size, strokeSize, params)
	size = size and math.round(size)
	params = params or {}
	params.text = text
	params.size = size

	if size and strokeSize then
		params.size = size - strokeSize
	end

	local label = display.newTTFLabel(params):anchor(0, 0)

	if strokeSize and 0 < strokeSize then
		local sc = params.sc or defaultsc
		sc = cc.c4b(sc.r, sc.g, sc.b, 255)
		label.strokeColor = sc
		label.strokeSize = strokeSize

		label.enableOutline(label, sc, strokeSize)
	end

	return label
end
label.string2size = function (text, font, size, strokeSize)
	if strokeSize == nil or strokeSize == 0 then
		strokeSize = 1
	end

	local tex = ycFunction:createTextTex(text, font, size + strokeSize)
	local strLen = string.len(text)
	local w = tex.getContentSize(tex).width
	local h = tex.getContentSize(tex).height + strokeSize*2

	return w, h
end
label.saveTex = function (text, loadsize, tex)
	if not label.texCaches[loadsize] then
		label.texCaches[loadsize] = {}
	end

	if not label.texCaches[loadsize][text] then
		label.texCaches[loadsize][text] = tex

		tex.retain(tex)
	end

	tex.mark = true

	return 
end
label.getTex = function (text, font, loadsize)
	if label.texCaches[loadsize] then
		local tex = label.texCaches[loadsize][text]

		if tex then
			tex.mark = true

			return tex
		end
	end

	return ycFunction:createTextTex(text, font, loadsize)
end
label.uptTextures = function (self)
	local nowtime, queueCnt = nil

	if 0 < DEBUG then
		nowtime = socket.gettime()
		queueCnt = table.nums(self.queues)
	end

	local nowLoads = {}
	local normalLoads = {}
	local channelLoads = {}

	for k, v in pairs(self.queues) do
		if v.isVisible(v) then
			if not v.bufferChannel then
				nowLoads[#nowLoads + 1] = v
			elseif v.bufferChannel == 0 then
				normalLoads[#normalLoads + 1] = v
			else
				channelLoads[#channelLoads + 1] = v
			end

			self.queues[k] = nil
		end
	end

	table.sort(channelLoads, function (a, b)
		return a.bufferChannel < b.bufferChannel
	end)

	local function visit2canvas(canvas, tex, fontSize, strokeSize, x, y, x2, y2, w, h)
		local strokeSize = strokeSize*2

		for i = 1, 360, 8 do
			local r = i*0.01745329252

			cc.Sprite:createWithTexture(tex):pos(x + w*0.5 + math.sin(r)*strokeSize, y + h*0.5 + math.cos(r)*strokeSize):flipY(true):visit()
		end

		for i = 1, 3, 1 do
			cc.Sprite:createWithTexture(tex):pos(x2 + w*0.5, y2 + h*0.5):flipY(true):visit()
		end

		return 
	end

	local texs = {}

	local function addTex(node)
		local text = node.text
		local font = node.font
		local loadsize = node.loadsize
		local needSave = node.needSave
		local tex = nil

		if texs[loadsize] then
			tex = texs[loadsize][text]
		end

		tex = tex or label.getTex(text, font, loadsize)

		if needSave then
			label.saveTex(text, loadsize, tex)
		end

		if not texs[loadsize] then
			texs[loadsize] = {}
		end

		if not texs[loadsize][text] then
			texs[loadsize][text] = tex
		end

		return tex
	end

	local storkeTexs = {}

	local function getStrokeTex(node)
		local loadsize = node.loadsize
		local strokeSize = node.strokeSize
		local text = node.text
		local fontSize = node.fontSize
		local ret = nil

		if storkeTexs[loadsize] and storkeTexs[loadsize][strokeSize] then
			ret = storkeTexs[loadsize][strokeSize][text]
		end

		if ret then
			return ret
		end

		local tex = texs[loadsize][text]
		local size = cc.size(tex.getContentSize(tex).width + (strokeSize or 0)*2, tex.getContentSize(tex).height + (strokeSize or 0)*2)
		local canvas = cc.RenderTexture:create(size.width*2, size.height, cc.TEXTURE2D_PIXEL_FORMAT_RGBA4444)

		canvas.begin(canvas)
		visit2canvas(canvas, tex, loadsize, strokeSize, 0, 0, size.width, 0, size.width, size.height)
		canvas.endToLua(canvas)

		if not storkeTexs[loadsize] then
			storkeTexs[loadsize] = {}
		end

		if not storkeTexs[loadsize][strokeSize] then
			storkeTexs[loadsize][strokeSize] = {}
		end

		local ret = canvas.getSprite(canvas):getTexture()
		storkeTexs[loadsize][strokeSize][text] = ret

		return ret
	end

	nowLoads = nowLoads or {}

	for i, node in ipairs(slot3) do
		node.queueID = nil

		addTex(node)
		node.upt(node, getStrokeTex(node))
	end

	local begin = socket.gettime()

	for i, node in ipairs(normalLoads) do
		node.queueID = nil

		addTex(node)
		node.upt(node, getStrokeTex(node))

		if 0.01 < socket.gettime() - begin then
			for j = i + 1, #normalLoads, 1 do
				local node = normalLoads[j]
				self.queues[node.queueID] = node
			end

			break
		end
	end

	local channels = {}
	local begin = socket.gettime()

	for i, node in ipairs(channelLoads) do
		node.queueID = nil
		local tex = addTex(node)
		local nodes = channels[node.bufferChannel]

		if not nodes then
			nodes = {}
			channels[node.bufferChannel] = nodes
		end

		nodes[#nodes + 1] = {
			node,
			tex
		}

		if 0.02 < socket.gettime() - begin then
			for j = i + 1, #channelLoads, 1 do
				local node = channelLoads[j]
				self.queues[node.queueID] = node
			end

			break
		end
	end

	local function uptBigTex(nodes)
		local maxh = 0

		for i, v in ipairs(nodes) do
			v[3] = cc.size(v[2]:getContentSize().width + (v[1].strokeSize or 0)*2, v[2]:getContentSize().height + (v[1].strokeSize or 0)*2)
			maxh = math.max(maxh, v[3].height)
		end

		local maxw = 0
		local wcnt = 0
		local linew = 1024
		local linecnt = 1
		local linemax = math.floor(maxh/1024)

		local function add(w, h)
			if linew < wcnt + w then
				if linemax < linecnt + 1 then
					return false
				end

				wcnt = 0
				linecnt = linecnt + 1
			end

			return true
		end

		local function cancel(i)
			local nodeCount = #nodes

			while i <= nodeCount do
				local node = nodes[i][1]

				node.upt(node, getStrokeTex(node))

				nodes[i] = nil
				i = i + 1
			end

			return 
		end

		for i, v in ipairs(getStrokeTex) do
			local wcnt_tmp = 0

			if add(v[3].width) then
				v[4] = cc.p(wcnt, (linecnt - 1)*maxh)
				wcnt = wcnt + v[3].width
				wcnt_tmp = wcnt
			else
				cancel(i)

				break
			end

			if add(v[3].width) then
				v[5] = cc.p(wcnt, (linecnt - 1)*maxh)
				wcnt = wcnt + v[3].width
			else
				cancel(i)

				break
			end

			maxw = math.max(maxw, wcnt, wcnt_tmp)
		end

		local canvas = cc.RenderTexture:create(maxw, maxh*linecnt, cc.TEXTURE2D_PIXEL_FORMAT_RGBA4444)

		canvas.begin(canvas)

		for i, v in ipairs(nodes) do
			local node, tex, size, p1, p2 = unpack(v)

			visit2canvas(canvas, tex, node.loadsize, node.strokeSize, p1.x, p1.y, p2.x, p2.y, size.width, size.height)
		end

		canvas.endToLua(canvas)

		local bigtex = canvas.getSprite(canvas):getTexture()

		for i, v in ipairs(nodes) do
			local node, tex, size, p1, p2 = unpack(v)

			node.upt(node, bigtex, cc.rect(p1.x, p1.y, size.width, size.height), cc.rect(p2.x, p2.y, size.width, size.height))
		end

		return 
	end

	for k, v in pairs(slot12) do
		uptBigTex(v)
	end

	label.cleanCheck(self)

	if 0 < DEBUG then
		self.debuginfo = {
			table.nums(self.queues) .. "/" .. queueCnt,
			label.getTexCount(),
			string.format("%.4f", socket.gettime() - nowtime)
		}
		self.debuginfo = table.concat(self.debuginfo, "-")
	end

	return 
end
local lasttime = nil
label.cleanCheck = function (self)
	if not lasttime or socket.gettime() - lasttime < 120 then
		return 
	end

	lasttime = socket.gettime()

	for k, v in pairs(self.texCaches) do
		for k2, v2 in pairs(v) do
			if not v2.mark and v2.getReferenceCount(v2) == 1 then
				v2.release(v2)

				v[k2] = nil
			end

			v2.mark = nil
		end
	end

	if 0 < DEBUG then
		local cnt = 0

		for k, v in pairs(self.texCaches) do
			cnt = cnt + table.nums(v)
		end

		print("an.label normal texture saveed: ", cnt)
	end

	return 
end
label.getTexCount = function ()
	local cnt = 0

	for k, v in pairs(label.texCaches) do
		cnt = cnt + table.nums(v)
	end

	return cnt
end
label.addQueue = function (node)
	label.queueAddCnt = label.queueAddCnt + 1
	node.queueID = label.queueAddCnt
	label.queues[label.queueAddCnt] = node

	return 
end
label.removeQueue = function (node)
	local queueID = node.queueID

	if queueID then
		label.queues[queueID] = nil
		node.queueID = nil
	end

	return 
end
label.addLabel = function (node)
	label.allLabelCnt = label.allLabelCnt + 1
	node.labelID = label.allLabelCnt
	label.allLabels[label.allLabelCnt] = node

	return 
end
label.removeLabel = function (node)
	local labelID = node.labelID

	if labelID then
		label.allLabels[labelID] = nil
		node.labelID = nil
	end

	return 
end
label.reloadAll = function ()
	for k, v in pairs(label.allLabels) do
		if v.sprEdge then
			v.sprEdge:removeSelf()

			v.sprEdge = nil
		end

		if v.sprText then
			v.sprText:removeSelf()

			v.sprText = nil
		end

		if v.underline then
			v.underline:removeSelf()

			v.underline = nil
		end

		v.texChanged(v)
	end

	return 
end
label.removeAllSchedule = function ()
	if label.loopListener then
		cc.Director:getInstance():getEventDispatcher():removeEventListener(label.loopListener)

		label.loopListener = nil
	end

	return 
end
slot6 = class("an.label", function ()
	return display.newNode()
end)
strokeLabel = slot6

table.merge(strokeLabel, {
	text,
	font,
	fontSize,
	loadSize,
	color,
	strokeSize,
	strokeColor,
	underline,
	sprs_edge,
	sprs_text,
	needSave,
	queueID,
	bufferChannel
})

strokeLabel.ctor = function (self, text, size, strokeSize, params)
	params = params or {}
	self.text = tostring(text) or ""
	self.fontSize = size or display.DEFAULT_TTF_FONT_SIZE
	self.font = params.font or display.DEFAULT_TTF_FONT
	self.color = params.color or display.COLOR_WHITE
	self.strokeSize = strokeSize or 0
	self.strokeColor = params.sc or display.COLOR_BLACK
	self.needSave = params.needSave
	self.bufferChannel = params.bufferChannel
	self.loadsize = (params.sd and self.fontSize) or math.min(self.fontSize*2, 30)
	self.sprEdge = nil
	self.sprText = nil

	self.setNodeEventEnabled(self, true)
	self.texChanged(self)

	if device.platform == "android" then
		label.addLabel(self)
	end

	return 
end
strokeLabel.onCleanup = function (self)
	label.removeQueue(self)

	if device.platform == "android" then
		label.removeLabel(self)
	end

	return 
end
strokeLabel.texChanged = function (self)
	if self.text == "" then
		if self.sprEdge then
			self.sprEdge:removeSelf()

			self.sprEdge = nil
		end

		if self.sprText then
			self.sprText:removeSelf()

			self.sprText = nil
		end

		if self.underline then
			self.underline:removeSelf()

			self.underline = nil
		end

		self.size(self, self.strokeSize*2, self.strokeSize*2)

		return 
	end

	self.size(self, label.string2size(self.text, self.font, self.fontSize, self.strokeSize))
	label.removeQueue(self)
	label.addQueue(self)

	return 
end
strokeLabel.upt = function (self, tex, r1, r2)
	if self.sprEdge then
		self.sprEdge:removeSelf()

		self.sprEdge = nil
	end

	if self.sprText then
		self.sprText:removeSelf()

		self.sprText = nil
	end

	r1 = r1 or cc.rect(0, 0, tex.getContentSize(tex).width*0.5, tex.getContentSize(tex).height)
	r2 = r2 or cc.rect(tex.getContentSize(tex).width*0.5, 0, tex.getContentSize(tex).width*0.5, tex.getContentSize(tex).height)
	local scale = self.fontSize/self.loadsize

	self.size(self, r1.width*scale, r1.height*scale)

	if 0 < self.strokeSize then
		self.sprEdge = cc.Sprite:createWithTexture(tex, r1):scale(scale):pos(self.getw(self)*0.5, self.geth(self)*0.5):add2(self)

		self.sprEdge:setColor(self.strokeColor)
	end

	self.sprText = cc.Sprite:createWithTexture(tex, r2):scale(scale):pos(self.getw(self)*0.5, self.geth(self)*0.5):add2(self)

	self.sprText:setColor(self.color)

	if self.underline then
		self.underline:size(self.getw(self), 1)
	end

	return 
end
strokeLabel.setString = function (self, text)
	if self.text ~= text then
		self.text = text

		self.texChanged(self)
	end

	return 
end
strokeLabel.getString = function (self)
	return self.text
end
strokeLabel.setText = function (self, text)
	self.setString(self, text)

	return 
end
strokeLabel.getText = function (self)
	return self.getString(self)
end
strokeLabel.setColor = function (self, color)
	if self.color.r ~= color.r or self.color.g ~= color.g or self.color.b ~= color.b then
		self.color = color

		if self.sprText then
			self.sprText:setColor(color)
		end
	end

	return 
end
strokeLabel.setStrokeColor = function (self, color)
	if self.strokeColor.r ~= color.r or self.strokeColor.g ~= color.g or self.strokeColor.b ~= color.b then
		self.strokeColor = color

		if self.sprEdge then
			self.sprEdge:setColor(color)
		end
	end

	return 
end
strokeLabel.addUnderline = function (self, color)
	color = color or self.color

	if self.underline then
		self.underline:setColor(cc.c4b(color.r, color.g, color.b, 255))

		return 
	end

	self.underline = display.newColorLayer(cc.c4b(color.r, color.g, color.b, 255)):pos(0, 1):size(math.max(1, self.getw(self)), 1):addto(self, 1)

	return self
end
local listener = cc.EventListenerCustom.create(slot6, "director_after_update", handler(label, label.uptTextures))

cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(listener, 1)

label.loopListener = listener

return label
