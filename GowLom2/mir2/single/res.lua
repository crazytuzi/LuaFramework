local res = {
	defaultPackName = "rs",
	maps = {},
	packs = {},
	caches_m2texs = {},
	caches_m2texs_fbo = {},
	caches_animation = {},
	caches_filters = {},
	defaults = {}
}
local NoOffset = {
	objects = true,
	objects30 = true,
	objects8 = true,
	objects23 = true,
	smtiles6 = true,
	objects21 = true,
	objects7 = true,
	objects25 = true,
	tiles4 = true,
	objects6 = true,
	smtiles = true,
	objects32 = true,
	dnitems = true,
	objects4 = true,
	tiles = true,
	objects24 = true,
	smtiles3 = true,
	objects3 = true,
	objects20 = true,
	objects18 = true,
	smtiles7 = true,
	stateitem = true,
	objects14 = true,
	items = true,
	prguse = true,
	objects9 = true,
	objects10 = true,
	tiles5 = true,
	objects2 = true,
	objects13 = true,
	smtiles5 = true,
	objects5 = true,
	smtiles4 = true,
	prguse3 = true
}
local isAsynAtlas = {
	objects = true,
	tiles4 = true,
	objects8 = true,
	objects7 = true,
	smtiles6 = true,
	objects14 = true,
	objects21 = true,
	objects23 = true,
	objects25 = true,
	objects6 = true,
	objects30 = true,
	objects32 = true,
	objects9 = true,
	objects4 = true,
	tiles5 = true,
	tiles = true,
	objects37 = true,
	objects2 = true,
	smtiles = true,
	objects13 = true,
	objects24 = true,
	smtiles3 = true,
	smtiles5 = true,
	objects5 = true,
	smtiles4 = true,
	objects10 = true,
	smtiles7 = true,
	objects3 = true,
	objects20 = true,
	objects18 = true
}
local __setOffset = cc.SpriteFrame.setOffset
local __setTexture = cc.SpriteFrame.setTexture
local __getReferenceCount = cc.Ref.getReferenceCount
local __release = cc.Ref.release
res.perload = function ()
	if IS_PLAYER_DEBUG then
		return 
	end

	if res.perloaded then
		return 
	end

	res.perloaded = true

	for i, v in ipairs(def.perload) do
		local frame = v[3] or 1
		local is8 = v[4]

		if is8 then
			local skip = v[5] or 0

			for j = 0, 7, 1 do
				for k = 1, frame, 1 do
					local tex, info = res.gettex(v[1], (v[2] + j*(frame + skip) + k) - 1, 1)

					if info.loading then
						info.loading[#info.loading + 1] = {
							call = function (tex)
								if tex then
									tex.retain(tex)
								end

								return 
							end
						}
					end
				end
			end
		else
			for j = 1, slot5, 1 do
				local tex, info = res.gettex(v[1], (v[2] + j) - 1, 1)

				if info.loading then
					info.loading[#info.loading + 1] = {
						call = function (tex)
							if tex then
								tex.retain(tex)
							end

							return 
						end
					}
				end
			end
		end
	end

	return 
end
local __position = cc.Node.setPosition
res.makeTexForFBO = function (imgid, idxbegin, frame)
	if res.caches_m2texs_fbo[imgid] and res.caches_m2texs_fbo[imgid][idxbegin] then
		return 
	end

	local texs = {}
	local wcnt = 0
	local hmax = 0

	for i = 1, frame, 1 do
		local tex, info = res.gettex(imgid, (idxbegin + i) - 1)
		local detail = clone(info)
		texs[#texs + 1] = detail

		if not info.err then
			detail.pos = wcnt
			wcnt = wcnt + info.w
			hmax = math.max(hmax, info.h)
		end

		res.removeinfo(imgid, (idxbegin + i) - 1)
	end

	if wcnt == 0 or hmax == 0 then
		return 
	end

	local canvas = cc.RenderTexture:create(wcnt, hmax, cc.TEXTURE2D_PIXEL_FORMAT_RGBA4444)

	canvas.begin(canvas)

	for i, v in ipairs(texs) do
		if not v.err then
			local spr = display.newSprite(v.tex):flipY(true)

			__position(spr, v.pos + spr.getw(spr)/2, hmax - spr.geth(spr)/2)
			spr.visit(spr)
		end
	end

	canvas.endToLua(canvas)

	local tex = canvas.getSprite(canvas):getTexture()

	tex.retain(tex)

	if not res.caches_m2texs_fbo[imgid] then
		res.caches_m2texs_fbo[imgid] = {}
	end

	res.caches_m2texs_fbo[imgid][idxbegin] = {
		tex = tex,
		frame = frame,
		details = texs
	}

	for i, v in ipairs(texs) do
		v.tex:release()

		v.tex = nil
	end

	return 
end
res.getFBO = function (imgid, idxbegin, frame)
	local fbos = res.caches_m2texs_fbo[imgid]

	if fbos then
		local fbo = fbos[idxbegin]

		return fbo and fbo.frame == frame and fbo
	end

	return 
end
res.clearTexCache = function ()
	for k, v in pairs(res.caches_animation) do
		if not v.mark and v.ani:getReferenceCount() == 1 then
			v.ani:release()

			res.caches_animation[k] = nil
		end

		v.mark = nil
	end

	for imgid, v in pairs(res.caches_m2texs) do
		for idx, texinfo in pairs(v) do
			if not texinfo.loading and not texinfo.err then
				if texinfo.mark then
					texinfo.mark = nil
				elseif texinfo.tex then
					ycAtlasMgr:getInstance():releaseFrame(texinfo.tex)

					v[idx] = nil
				end
			end
		end
	end

	if 0 < DEBUG then
		local bytesCnt = 0
		local cnt = 0

		for imgid, v in pairs(res.caches_m2texs) do
			for idx, texinfo in pairs(v) do
				if not texinfo.loading and not texinfo.err and texinfo.tex:getTexture() then
					bytesCnt = bytesCnt + (texinfo.tex:getRectInPixels().width*texinfo.tex:getRectInPixels().height*texinfo.tex:getTexture():getBitsPerPixelForFormat())/8
				end

				cnt = cnt + 1
			end
		end
	end

	return 
end

scheduler.scheduleGlobal(res.clearTexCache, 10)

res.purgeCachedData = function ()
	for imgid, v in pairs(res.caches_m2texs) do
		for idx, texinfo in pairs(v) do
			if not texinfo.loading and not texinfo.err and texinfo.tex then
				ycAtlasMgr:getInstance():releaseFrame(texinfo.tex)

				v[idx] = nil
			end
		end
	end

	if MirAtlasMgr and MirAtlasMgr.getInstance then
		MirAtlasMgr:getInstance():removeUnusedTexture(true)
	end

	cc.Director:getInstance():getTextureCache():removeUnusedTextures()

	for k, v in pairs(res.caches_animation) do
		v.ani:release()
	end

	res.caches_animation = {}

	for k, v in pairs(res.packs) do
		ycRes:release(v)
	end

	res.packs = {}

	for k, v in pairs(res.maps) do
		mir2map:release(v)
		p2("res", "res.purgeCachedData: 地图数据清理")
	end

	res.maps = {}

	return 
end

function res_loadEndForAsync(imgid, idx, tex)
	local infos = res.caches_m2texs[imgid]
	local info = nil

	if infos then
		info = infos[idx]
	end

	if not info then
		p2("res", "res_loadEndForAsync -> info not found!", key)

		if tex then
			tex.release(tex)
		end

		return 
	end

	info.tex = tex
	info.err = tex == nil

	for i, v in ipairs(info.loading) do
		v.call(tex)
	end

	info.loading = nil

	return 
end

res.getMir2TexCount = function ()
	local cnt = 0

	for imgid, v in pairs(res.caches_m2texs) do
		for idx, texinfo in pairs(v) do
			if not texinfo.loading and not texinfo.err and texinfo.tex then
				cnt = cnt + 1
			end
		end
	end

	return cnt
end
res.tex2Key = function (filename, packname)
	return filename .. "-" .. packname
end
res.frameKey = function (imgid, idx, setOffset)
	return imgid .. "-" .. idx .. "-" .. ((setOffset and "1") or "0")
end
res.animationKey = function (imgid, beginidx, endidx, delay)
	return imgid .. "-" .. beginidx .. "-" .. endidx .. "-" .. delay .. "-" .. ((setOffset and "1") or "0")
end
res.default = function ()
	if not res.defaults.tex1 then
		res.defaults.tex1 = cc.Director:getInstance():getTextureCache():addImage("public/default.png")

		res.defaults.tex1:retain()
	end

	return res.defaults.tex1
end
res.default2 = function ()
	if not res.defaults.tex2 then
		res.defaults.tex2 = cc.Director:getInstance():getTextureCache():addImage("public/empty.png")

		res.defaults.tex2:retain()
	end

	return res.defaults.tex2
end
res.defaultFrame = function ()
	if not res.defaults.frame then
		res.defaults.frame = cc.SpriteFrame:createWithTexture(res.default2(), cc.rect(0, 0, 32, 32))

		res.defaults.frame:retain()
	end

	return res.defaults.frame
end
res.getinfo = function (imgid, idx, needLoad)
	local infos = res.caches_m2texs[imgid]
	local info = nil

	if infos then
		info = infos[idx]

		if info then
			return info
		end
	end

	if needLoad then
		local x, y, w, h = ycAtlasMgr:getInstance():getSpriteFrameInfo(imgid, idx)

		if x then
			return {
				x = x,
				y = y,
				w = w,
				h = h
			}
		end
	end

	return 
end
res.removeinfo = function (imgid, idx)
	local infos = res.caches_m2texs[imgid]

	if infos then
		infos[idx] = nil
	end

	return 
end
res.get = function (imgid, idx, setOffset, asyncPriority, blend, class)
	local spriteClass = class or cc.Sprite
	local sprite = nil
	local tex, info = res.gettex(imgid, idx, asyncPriority)

	if info.err then
		sprite = spriteClass.createWithTexture(spriteClass, res.default2(), cc.rect(0, 0, 2, 2))
	elseif info.loading then
		sprite = spriteClass.createWithTexture(spriteClass, res.default(), cc.rect(0, 0, info.w, info.h))
	elseif tolua.type(tex) == "cc.Texture2D" then
		sprite = spriteClass.createWithTexture(spriteClass, tex)

		if setOffset then
			sprite.anchor(sprite, 0, -1)
			__position(sprite, info.x, -info.y)
		end
	elseif tolua.type(tex) == "cc.SpriteFrame" then
		if tex.isDownloading and tex.isDownloading(tex) then
			sprite = ycM2Sprite:create(res.default2(), false, false)

			sprite.setSpriteFrame(sprite, tex)

			if main_scene then
			end
		else
			sprite = spriteClass.createWithSpriteFrame(spriteClass, tex)
		end

		if setOffset and tex.isMiz then
			sprite.anchor(sprite, 0, 0)
		end
	else
		printError("param[%s] must be 'cc.Texture2D' or 'cc.SpriteFrame' Type. ", tex)
	end

	if asyncPriority and info.loading then
		sprite.setNodeEventEnabled(sprite, true)

		sprite.onCleanup = function ()
			for i, v in ipairs(info.loading) do
				if v.sprite == sprite then
					table.remove(info.loading, i)

					break
				end
			end

			return 
		end
		info.loading[#info.loading + 1] = {
			sprite = sprite,
			call = function (tex)
				sprite:setNodeEventEnabled(false)

				if tex then
					sprite:setTex(tex)
				end

				return 
			end
		}
	end

	return sprite
end
res.gettex = function (imgid, idx, asyncPriority)
	return res.getSpriteFrame(imgid, idx, asyncPriority)
end
res.getSpriteFrame = function (imgid, idx, asyncPriority)
	if idx ~= idx then
		print("res.getSpriteFrame: idx is NaN!")

		return nil, nil
	end

	local infos = res.caches_m2texs[imgid]

	if not infos then
		infos = {}
		res.caches_m2texs[imgid] = infos
	end

	local info = infos[idx]

	if not isAsynAtlas[imgid] then
		asyncPriority = 0
	end

	if not info then
		local texFrame = nil
		local x = 0
		local y = 0
		local w = 0
		local h = 0
		texFrame, x, y, w, h = ycAtlasMgr:getInstance():getFrame(imgid, idx, asyncPriority or 0, NoOffset[imgid])

		if texFrame then
			texFrame.isMiz = true
			local specialOffset = w == 100 and h == 100 and imgid == "objects"

			if specialOffset then
				__setOffset(texFrame, cc.p(x, y))
			end
		end

		if texFrame then
			info = {
				tex = texFrame,
				x = x,
				y = y,
				w = w,
				h = h
			}
		else
			p2("res", "res.getSpriteFrame faild!", imgid, idx)

			info = {
				err = true
			}
		end

		infos[idx] = info
	end

	info.mark = true

	return info.tex, info
end
res.getui = function (uiidx, idx)
	local imgid = "prguse"

	if 1 < uiidx then
		imgid = imgid .. uiidx
	end

	return res.get(imgid, idx)
end
res.getuitex = function (uiidx, idx)
	local imgid = "prguse"

	if 1 < uiidx then
		imgid = imgid .. uiidx
	end

	return res.gettex(imgid, idx)
end
res.getframe = function (imgid, idx, setOffset, asyncPriority, blend)
	local tex, info = res.gettex(imgid, idx, asyncPriority, blend)

	return tex
end
res.getani = function (imgid, beginidx, endidx, delay, setOffset, isReversed, asyncPriority, blend)
	local step = 1

	if isReversed then
		beginidx = endidx
		endidx = beginidx
		step = -1
	end

	local key = res.animationKey(imgid, beginidx, endidx, delay, setOffset)
	local animationInfo = res.caches_animation[key]

	if animationInfo then
		animationInfo.mark = true

		return animationInfo.ani
	end

	local frames = {}

	for index = beginidx, endidx, step do
		local frame = res.getframe(imgid, index, setOffset, asyncPriority, blend)

		if frame then
			frames[#frames + 1] = frame
		else
			break
		end
	end

	if 0 < #frames then
		local animation = cc.Animation:createWithSpriteFrames(frames, delay)

		animation.retain(animation)

		res.caches_animation[key] = {
			mark = true,
			ani = animation
		}

		return animation
	end

	return 
end
res.loadmap = function (mapid)
	local map = res.maps[mapid]

	if not map then
		cache.unzipMapFile(mapid)

		local fullpath = cache.getMapFilePath(mapid)
		map = mir2map:create(fullpath)
		res.maps[mapid] = map
	end

	return map
end
res.unLoadmap = function (mapid)
	for k, v in pairs(res.maps) do
		if mapid == k then
			p2("res", "res.unLoadmap: 大地图界面释放了一个mir2map")
			mir2map:release(v)

			res.maps[mapid] = nil

			break
		end
	end

	return 
end
res.getpack = function (packname)
	local pack = res.packs[packname]

	if not pack then
		pack = ycRes:create(1, packname, packname .. ".zip", "")
		res.packs[packname] = pack
	end

	return pack
end
res.getfile = function (filename, packname)
	local content = res.getpack(packname or res.defaultPackName):getFileData(filename)

	if not content or content == "" then
		content = ycFunction:getFileData(filename, false)
	end

	return content
end
res.get2_helper = function (filename, x, y, params, packname)
	if 0 < DEBUG and not IS_PLAYER_DEBUG then
		local tex = cc.Director:getInstance():getTextureCache():addImage(filename)
		tex = tex or res.gettex2(filename, packname)

		return display.newSprite(tex, x, y, params)
	else
		return res.get2(filename, x, y, params, packname)
	end

	return 
end
res.get2 = function (filename, x, y, params, packname)
	return display.newSprite(res.gettex2(filename, packname), x, y, params)
end
res.gettex2 = function (filename, packname)
	local textureCache = cc.Director:getInstance():getTextureCache()
	packname = packname or res.defaultPackName
	local key = res.tex2Key(filename, packname)
	local tex = textureCache.getTextureForKey(textureCache, key)
	local err = nil

	if not tex then
		local pack = res.getpack(packname)

		if pack then
			local image = pack.makeImageWithFilename(pack, filename)

			if image then
				tex = cc.Director:getInstance():getTextureCache():addImage(image, key)

				image.release(image)
			end
		end

		tex = tex or textureCache.addImage(textureCache, filename)

		if not tex then
			tex = res.default2()
			err = true
		end
	end

	return tex, err
end
res.getframe2 = function (filename, packname)
	local tex = res.gettex2(filename, packname)

	if tex then
		return cc.SpriteFrame:createWithTexture(tex, cc.rect(0, 0, tex.getContentSize(tex).width, tex.getContentSize(tex).height))
	end

	return 
end
res.getani2 = function (filenameformat, beginidx, endidx, delay)
	local key = res.animationKey(filenameformat, beginidx, endidx, delay, setOffset)
	local animationInfo = res.caches_animation[key]

	if animationInfo then
		animationInfo.mark = true

		return animationInfo.ani
	end

	local frames = {}

	for i = beginidx, endidx, 1 do
		local tex = res.gettex2(string.format(filenameformat, i))
		local frame = cc.SpriteFrame:createWithTexture(tex, cc.rect(0, 0, tex.getContentSize(tex).width, tex.getContentSize(tex).height))
		frames[#frames + 1] = frame
	end

	if 0 < #frames then
		local animation = cc.Animation:createWithSpriteFrames(frames, delay)

		animation.retain(animation)

		res.caches_animation[key] = {
			mark = true,
			ani = animation
		}

		return animation
	end

	return 
end
res.getFilter = function (key)
	local f = res.caches_filters[key]

	if f then
		return f
	end

	if key == "gray" then
		local params = {
			0.2,
			0.3,
			0.5,
			0.1
		}
		f = filter.newFilter("GRAY", params)
	elseif key == "outline_skill" then
		local params = {
			shaderName = "outline_skill",
			u_radius = 0.02,
			frag = "public/tex_outline.fsh",
			u_threshold = 0.75,
			u_outlineColor = {
				1,
				0,
				1
			}
		}
		f = filter.newFilter("CUSTOM", json.encode(params))
	elseif key == "outline_role" then
		local params = {
			shaderName = "outline_role",
			u_radius = 0.01,
			frag = "public/tex_outline.fsh",
			u_threshold = 0.75,
			u_outlineColor = {
				1,
				0.2,
				0.2
			}
		}
		f = filter.newFilter("CUSTOM", json.encode(params))
	elseif key == "high_light" then
		local params = {
			shaderName = "high_light",
			frag = "public/tex_hightlight.fsh"
		}
		f = filter.newFilter("CUSTOM", json.encode(params))
	end

	f.retain(f)

	res.caches_filters[key] = f

	return f
end
local _newSprite = display.newSprite
display.newSprite = function (filename, x, y, params)
	local t = type(filename)

	if t == "string" and string.find(filename, "pic/") == 1 then
		filename = res.gettex2(filename)
	end

	return _newSprite(filename, x, y, params)
end
local _newScale9Sprite = display.newScale9Sprite
display.newScale9Sprite = function (filename, x, y, size, capInsets)
	local t = type(filename)

	if t == "string" and string.find(filename, "pic/") == 1 then
		filename = res.getframe2(filename)
	end

	return _newScale9Sprite(filename, x, y, size, capInsets)
end

return res
