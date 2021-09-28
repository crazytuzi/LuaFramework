local m2sprMgr = {
	aniIdCnt = 0,
	texIdCnt = 0,
	debuginfo = "",
	texQueue = {},
	aniQueue = {},
	lasttime = socket.gettime()
}
local m2spr = nil
m2sprMgr.new = function (...)
	return m2spr.new(...)
end
m2sprMgr.playAnimation = function (...)
	return m2spr.playAnimation(...)
end
local syncLoads = {}
local syncMustLoads = {}
local asyncLoads = {}

setmetatable(slot2, {
	__mode = "kv"
})
setmetatable(syncMustLoads, {
	__mode = "kv"
})
setmetatable(asyncLoads, {
	__mode = "kv"
})

m2sprMgr.loop = function (self)
	local nowtime = socket.gettime()
	self.lasttime = nowtime
	local needUpt = m2spr.needUpt
	local upt = m2spr.upt
	local aniUpt = m2spr.aniUpt
	local aniuptStart = ycFunction.getClock()
	local texQueue = self.texQueue

	for v, k in pairs(self.aniQueue) do
		if v.aniNextTime <= nowtime then
			local start = v.aniStartTime
			local delay = aniUpt(v, nowtime - start)
			v.aniNextTime = nowtime + delay
		end
	end

	local aniuptEnd = ycFunction.getClock()
	local texuptStart = aniuptEnd
	syncLoads.num = 0
	syncMustLoads.num = 0
	asyncLoads.num = 0
	local texQueueNums = nil

	if 0 < DEBUG then
		texQueueNums = table.nums(texQueue)
	end

	local insert = table.insert

	for v, k in pairs(texQueue) do
		local info = res.getinfo(v.imgid, v.idx)

		if info then
			if info.loading then
				v.asyncRequested = true
			else
				upt(v, info)

				texQueue[v] = nil
			end
		elseif v.asyncPriority then
			if not v.asyncRequested then
				asyncLoads.num = asyncLoads.num + 1
				asyncLoads[asyncLoads.num] = v
			end
		elseif v.ani and not v.ani.noForever then
			syncLoads.num = syncLoads.num + 1
			syncLoads[syncLoads.num] = v
		else
			syncMustLoads.num = syncMustLoads.num + 1
			syncMustLoads[syncMustLoads.num] = v
		end
	end

	local resGetTex = res.gettex
	local resGetInfo = res.getinfo
	local begin = socket.gettime()

	for k = 1, syncMustLoads.num, 1 do
		local v = syncMustLoads[k]
		local _, info = resGetTex(v.imgid, v.idx)

		upt(v, info)

		texQueue[v] = nil
	end

	for k = 1, syncLoads.num, 1 do
		local v = syncLoads[k]
		local _, info = resGetTex(v.imgid, v.idx)

		upt(v, info)

		texQueue[v] = nil
		syncLoads[k] = nil

		if 0.02 < socket.gettime() - begin then
			break
		end
	end

	for k = 1, syncLoads.num, 1 do
		local v = syncLoads[k]

		if v then
			local info = resGetInfo(v.imgid, v.idx)

			if info then
				upt(v, info)

				texQueue[v] = nil
			end
		end
	end

	for k = 1, asyncLoads.num, 1 do
		local v = asyncLoads[k]
		v.asyncRequested = true
		local _, info = resGetTex(v.imgid, v.idx, v.asyncPriority)

		if not info.loading then
			upt(v, info)

			texQueue[v] = nil
		end
	end

	local texuptEnd = ycFunction.getClock()

	if 0 < DEBUG then
		self.debuginfo = {
			aniuptEnd - aniuptStart,
			texuptEnd - texuptStart
		}
		self.debuginfo = table.concat(self.debuginfo, "-")
	end

	return 
end
m2sprMgr.addTexQueue = function (node)
	m2sprMgr.texQueue[node] = true

	return 
end
m2sprMgr.removeTexQueue = function (node)
	m2sprMgr.texQueue[node] = nil

	return 
end
m2sprMgr.addAniQueue = function (node)
	m2sprMgr.aniQueue[node] = true

	return 
end
m2sprMgr.removeAniQueue = function (node)
	m2sprMgr.aniQueue[node] = nil

	return 
end
m2sprMgr.removeAllSchedule = function ()
	if m2sprMgr.loopListener then
		cc.Director:getInstance():getEventDispatcher():removeEventListener(m2sprMgr.loopListener)

		m2sprMgr.loopListener = nil
	end

	return 
end
slot5 = class("m2spr")
m2spr = slot5
local __setVisible = cc.Node.setVisible
local __getIsInsideBounds = ycM2Sprite.getIsInsideBounds
local __setCenterOffset = ycM2Sprite.setCenterOffset
local __setContentSize = cc.Node.setContentSize
local __getContentSize = cc.Node.getContentSize
local __setPosition = cc.Node.setPosition
local __setBlendFunc = cc.Sprite.setBlendFunc
local __setTextureAutoSetRect = ycM2Sprite.setTextureAutoSetRect
local __setFlippedX = cc.Sprite.setFlippedX
local __setAnchorPoint = cc.Node.setAnchorPoint
local __addTextureFrame = ycM2Sprite.addTextureFrame
local __playAniAction = ycM2Sprite.playAniAction
local __setNodeEventEnabled = cc.Node.setNodeEventEnabled
local __setSpriteFrame = cc.Sprite.setSpriteFrame
local __setKeepBlendFunc = ycM2Sprite.setKeepBlendFunc

table.merge(m2spr, {
	imgid,
	idx,
	setOffset,
	blend,
	syncPriority,
	asyncPriority,
	asyncRequested,
	unknowSize,
	texQueueID,
	aniQueueID,
	ani,
	isShow
})

local etcVer = [[
//ver
attribute vec4 a_position;
attribute vec2 a_texCoord;
attribute vec4 a_color;

#ifdef GL_ES
varying lowp vec4 v_fragmentColor;
varying mediump vec2 v_texCoord;
varying mediump vec2 v_alphaCoord;  
#else
varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
varying vec2 v_alphaCoord;  
#endif

void main()
{
    gl_Position = CC_PMatrix * a_position;
    v_fragmentColor = a_color;
    v_texCoord = a_texCoord;
    v_alphaCoord = v_texCoord + vec2(0.0, 0.5);  
}
]]
local etcFrag = [[
//Frag

#ifdef GL_ES
varying lowp vec4 v_fragmentColor;
varying mediump vec2 v_texCoord;
varying mediump vec2 v_alphaCoord;
#else
varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
varying vec2 v_alphaCoord;  
#endif

void main()
{
    if(v_texCoord.y >= 0.5){
    	gl_FragColor = vec4(0,0,0,0);
    	return;
    }
    vec4 texColor = texture2D(CC_Texture0, v_texCoord);
    texColor.a = texture2D(CC_Texture0, v_alphaCoord).r;
    gl_FragColor = texColor * v_fragmentColor;
}
]]
local etcProgram = cc.GLProgram:createWithByteArrays(etcVer, etcFrag)

etcProgram.bindAttribLocation(etcProgram, cc.ATTRIBUTE_NAME_POSITION, 4)
etcProgram.bindAttribLocation(etcProgram, cc.ATTRIBUTE_NAME_COLOR, cc.VERTEX_ATTRIB_COLOR)
etcProgram.bindAttribLocation(etcProgram, cc.ATTRIBUTE_NAME_TEX_COORD, cc.VERTEX_ATTRIB_TEX_COORDS)
etcProgram.link(etcProgram)
etcProgram.updateUniforms(etcProgram)
etcProgram.retain(etcProgram)

m2spr.add2 = function (self, ...)
	self.spr:add2(...)

	return self
end
m2spr.addto = function (self, ...)
	self.spr:add2(...)

	return self
end
m2spr.addTo = function (self, ...)
	self.spr:add2(...)

	return self
end
m2spr.hide = function (self)
	self.setVisible(self, false)

	return self
end
m2spr.show = function (self)
	self.setVisible(self, true)

	return self
end
m2spr.anchor = function (self, ...)
	__setAnchorPoint(self.spr, ...)

	return self
end
m2spr.runs = function (self, ...)
	self.spr:runs(...)

	return self
end
m2spr.pos = function (self, x, y)
	__setPosition(self.spr, x, y)

	return self
end
m2spr.flipX = function (self, ...)
	__setFlippedX(self.spr, ...)

	return self
end
m2spr.flipY = function (self, ...)
	__setFlippedY(self.spr, ...)

	return self
end
m2spr.run = function (self, ...)
	self.spr:run(...)

	return self
end
m2spr.runs = function (self, ...)
	self.spr:runs(...)

	return self
end
m2spr.setScaleX = function (self, ...)
	self.spr:setScaleX(...)

	return self
end
m2spr.setScaleY = function (self, ...)
	self.spr:setScaleY(...)

	return self
end
m2spr.setFilter = function (self, ...)
	self.spr:setFilter(...)

	return self
end
m2spr.removeSelf = function (self)
	self.spr:removeSelf()

	return 
end
m2spr.setColor = function (self, c)
	self.spr:setColor(c)

	return self
end

local function __m2spr_setFixArtifactsByStrechingTexel(p, f)
	local pu_ret, pu = pcall(function ()
		p:setFixArtifactsByStrechingTexel(f)

		return true
	end)

	return 
end

m2spr.setFixArtifactsByStrechingTexel = function (self, f)
	__m2spr_setFixArtifactsByStrechingTexel(self.spr, f)

	return self
end
m2spr.ctor = function (self, imgid, idx, params)
	local inst = ycM2Sprite:create(res.default2(), params and params.setOffset, params and params.blend)
	inst.onCleanup = function ()
		self:onCleanup()

		return 
	end
	self.spr = inst
	params = params or {}
	self.imgid = imgid
	self.idx = idx
	self.setOffset = params.setOffset
	self.blend = params.blend
	self.asyncPriority = params.asyncPriority
	self.isShow = true

	__setNodeEventEnabled(slot4, true)

	self.onctor = true

	self.texChanged(self)

	return 
end
m2spr.onCleanup = function (self)
	m2sprMgr.removeTexQueue(self)
	m2sprMgr.removeAniQueue(self)

	return 
end
m2spr.needUpt = function (self)
	return __getIsInsideBounds(self.spr)
end
m2spr.setVisible = function (self, b)
	__setVisible(self.spr, b)

	self.isShow = b

	if b then
		if self.ani then
			m2sprMgr.addAniQueue(self)
		else
			self.texChanged(self)
		end
	end

	return 
end
m2spr.getContentSize = function (self)
	if self.unknowSize then
		self.unknowSize = nil
		local info = res.getinfo(self.imgid, self.idx, true)

		if info and not info.err then
			__setContentSize(self.spr, info.w, info.h)
		else
			__setContentSize(self.spr, 0, 0)
		end
	end

	return __getContentSize(self.spr)
end
m2spr.setBlend = function (self, blend)
	if self.blend ~= blend then
		self.blend = blend

		self.updateBlendFunc(self)
	end

	return 
end
m2spr.updateBlendFunc = function (self)
	if self.blend then
		__setBlendFunc(self.spr, gl.SRC_ALPHA, gl.ONE)
		__setKeepBlendFunc(self.spr, true)
	else
		__setBlendFunc(self.spr, gl.ONE, gl.ONE_MINUS_SRC_ALPHA)
		__setKeepBlendFunc(self.spr, false)
	end

	return 
end
m2spr.texChanged = function (self)
	if self.imgid and self.idx then
		self.unknowSize = true
		self.asyncRequested = nil

		m2sprMgr.addTexQueue(self)
	end

	return 
end
local __setGLProgram = cc.Node.setGLProgram
local upt_result = {
	success = 0,
	textureErr = 1,
	sprErr = 2
}
m2spr.upt = function (self, info)
	if not info or info.err then
		__setTextureAutoSetRect(self.spr, res.default2())

		return upt_result.textureErr
	end

	local tex = info.tex
	local x = info.x
	local y = info.y
	local w = info.w
	local h = info.h

	if not tolua.isnull(self.spr) then
		__setSpriteFrame(self.spr, tex)
	else
		return upt_result.sprErr
	end

	slot7 = tex.isDownloading and tex.isDownloading(tex) and main_scene and main_scene.ui and slot7
	self.unknowSize = nil

	return upt_result.success
end
m2spr.setImg = function (self, imgid, idx)
	if self.imgid ~= imgid or self.idx ~= idx then
		self.imgid = imgid
		self.idx = idx

		self.texChanged(self)
	end

	return 
end
m2spr.setDelay = function (self, delay)
	self.ani.delay = delay

	return 
end
m2spr.resetAndPlay = function (self)
	local nt = game.loopBegin or socket.gettime()
	self.aniStartTime = nt
	self.aniNextTime = nt

	m2sprMgr.addAniQueue(self)

	return 
end
_G.useLuaAni = true
m2spr.playAni = function (self, img, begin, frame, delay, blend, autoRemove, noForever, callback, asyncPriority, nextIdxSpace)
	self.asyncPriority = asyncPriority

	if _G.useLuaAni then
		self.ani = {
			dt = 0,
			img = img,
			begin = begin,
			frame = frame,
			delay = delay or 0.1,
			noForever = noForever,
			callback = callback or (noForever and autoRemove and handler(self, self.removeSelf)),
			nextIdxSpace = nextIdxSpace or 1
		}

		m2sprMgr.removeTexQueue(self)

		local nt = game.loopBegin or socket.gettime()
		self.aniStartTime = nt
		self.aniNextTime = nt

		self.setBlend(self, blend)
		m2sprMgr.addAniQueue(self)
	else
		nextIdxSpace = nextIdxSpace or 1
		delay = delay or 0.1

		for idx = begin, begin + frame*nextIdxSpace, 1 do
			local frame = res.getframe(img, idx, self.setOffset, 1)

			__addTextureFrame(self.spr, frame, idx)
		end

		__playAniAction(self.spr, begin, frame, delay, false, nextIdxSpace, not noForever, autoRemove, callback and cc.CallFunc:create(callback))
	end

	return self
end
m2spr.playAnimation = function (img, begin, frame, delay, blend, autoRemove, noForever, callback, noSetOffset, asyncPriority, nextIdxSpace)
	local ani = m2spr.new(nil, nil, {
		setOffset = not noSetOffset,
		blend = blend
	}):playAni(img, begin, frame, delay, blend, autoRemove, noForever, callback, asyncPriority, nextIdxSpace)

	return ani.spr, ani
end
m2spr.stopAnimation = function (self)
	m2sprMgr.removeAniQueue(self)

	return 
end
m2spr.aniUpt = function (self, dt)
	local data = self.ani
	local delay = data.delay
	local idx = math.floor(dt/delay)

	if data.frame - 1 < idx then
		if data.noForever then
			self.stopAnimation(self)

			if data.callback then
				data.callback(self)
			end

			return 0
		else
			idx = idx%data.frame
			local nt = game.loopBegin or socket.gettime()
			self.aniStartTime = nt
			self.aniNextTime = nt
		end
	end

	if self.isShow then
		if data.lastIdx == idx then
			return delay - dt%delay
		end

		data.lastIdx = idx
		local imgIdx = data.begin + idx*data.nextIdxSpace

		self.setImg(self, data.img, imgIdx)
	end

	return delay - dt%delay
end
local listener = cc.EventListenerCustom.create(slot26, "director_after_update", handler(m2sprMgr, m2sprMgr.loop))

cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(listener, 1)

m2sprMgr.loopListener = listener

return m2sprMgr
