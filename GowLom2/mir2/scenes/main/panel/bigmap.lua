local controlHeight = 110
local common = import("..common.common")
local bigmap = class("bigmap", function ()
	return display.newNode()
end)

table.merge(slot2, {
	texSize,
	mapid,
	mapw,
	maph,
	point,
	bgSprs,
	borderSpr,
	mapScale,
	mapNode,
	mapSpr,
	title,
	titleLabel,
	worldMapScale,
	worldMapNode,
	worldMapSpr,
	worldMode,
	findPathNode,
	findPathPoint,
	dest,
	destPoint,
	inputx,
	inputy,
	likeSpr,
	tabs,
	quickNode,
	npcScroll,
	handler,
	uptFlagTime = 5,
	maxLikeNum = 10,
	flagList = {}
})

local minh = 350
local config = {
	["0"] = {
		res = "biqi",
		y = 397,
		title = "比奇省",
		x = 566,
		spriteOffset = cc.p(0, -40),
		worldpos = cc.p(-563, 1077),
		signpos = {
			x = 570,
			y = 465
		}
	},
	["1"] = {
		res = "woma",
		y = 591,
		title = "沃玛森林",
		x = 453,
		spriteOffset = cc.p(8, 0),
		worldpos = cc.p(-448, 856),
		signpos = {
			x = 472,
			y = 647
		}
	},
	["2"] = {
		res = "dushe",
		y = 463,
		title = "毒蛇山谷",
		x = 766,
		spriteOffset = cc.p(-40, 50),
		worldpos = cc.p(-727, 942),
		signpos = {
			x = 730,
			y = 555
		}
	},
	["3"] = {
		res = "mengzhong",
		y = 576,
		title = "盟重省",
		x = 827,
		spriteOffset = cc.p(-65, 118),
		worldpos = cc.p(-775, 825),
		signpos = {
			x = 764,
			y = 735
		}
	},
	["4"] = {
		res = "fengmo",
		y = 692,
		title = "封魔谷",
		x = 274,
		spriteOffset = cc.p(0, -20),
		worldpos = cc.p(-268, 783),
		signpos = {
			x = 270,
			y = 737
		}
	},
	["5"] = {
		res = "cangyue",
		y = 1015,
		title = "苍月岛",
		x = 442,
		spriteOffset = cc.p(0, -30),
		worldpos = cc.p(-444, 464),
		signpos = {
			x = 445,
			y = 1025
		}
	},
	["6"] = {
		res = "molong",
		y = 435,
		title = "魔龙城",
		x = 1096,
		spriteOffset = cc.p(10, -32),
		worldpos = cc.p(-1104, 1033),
		signpos = {
			x = 1105,
			y = 485
		}
	},
	["11"] = {
		res = "bairi",
		y = 779,
		title = "白日门",
		x = 403,
		spriteOffset = cc.p(20, -25),
		worldpos = cc.p(-417, 694),
		signpos = {
			x = 415,
			y = 825
		}
	}
}
bigmap.canLike = function (self, x, y)
	local curMapLikeNum = g_data.bigmap:getLikesNum(self.mapid)

	if self.maxLikeNum <= curMapLikeNum then
		main_scene.ui:tip("收藏点已满，无法继续收藏", 6)

		return false
	end

	if not x or not y then
		main_scene.ui:tip("无效的坐标", 6)

		return false
	end

	if self.canWalk(self, x, y).block then
		main_scene.ui:tip("目标无法到达，收藏失败", 6)

		return false
	end

	return true
end
bigmap.ctor = function (self, tex)
	self._supportMove = true

	self.setNodeEventEnabled(self, true)

	self.onCleanup = function ()
		self:unloadMapFile()
		self:unscheduleHandle()

		return 
	end
	local b1 = res.get2("pic/panels/bigmap/bg1.png").anchor(slot2, 0, 1):addTo(self, -1)
	local b2 = res.get2("pic/panels/bigmap/bg2.png"):anchor(0, 0):addTo(self, -1)
	local b3 = res.get2("pic/panels/bigmap/bg3.png"):anchor(0, 0):addTo(self, -1)
	self.bgSprs = {
		b1,
		b2,
		b3
	}

	an.newLabel("世界地图", 20, 0, {
		color = def.colors.Cd2b19c
	}):addTo(b1):pos(b1.getw(b1)/2, b1.geth(b1)/2 + 12):anchor(0.5, 0.5)

	local strs = {
		"世\n界",
		"区\n域"
	}
	self.tabs = common.tabs(b1, {
		ox = 4,
		size = 20,
		strokeSize = 1,
		oy = 8,
		strs = strs,
		lc = {
			normal = def.colors.Ca6a197,
			select = def.colors.Cf0c896
		}
	}, function (idx, btn)
		if idx == 1 then
			self:change2WorldMap()
		elseif idx == 2 then
			self:change2LocalMap()
		end

		return 
	end, {
		tabTp = 1,
		pos = {
			offset = 70,
			x = 1,
			y = b1.geth(slot2) - 82,
			anchor = cc.p(1, 0.5)
		},
		default = {
			var = 2,
			manual = true
		}
	})
	self.controlNode = display.newNode():addTo(b3):pos(0, 0)

	an.newLabel("横:", 20, 1, {
		color = cc.c3b(255, 255, 0)
	}):anchor(0, 0.5):pos(27, b3.geth(b3)/2 - 2):addTo(self.controlNode)

	self.inputx = an.newInput(62, b3.geth(b3)/2 - 7, 86, 32, 4, {
		label = {
			"",
			20,
			1
		},
		bg = {
			h = 32,
			tex = res.gettex2("pic/scale/edit.png"),
			offset = {
				-3,
				4
			}
		},
		stop_call = function ()
			local num = tonumber(self.inputx:getText()) or 0
			local w, h = self:mapSize()

			if num < 0 then
				num = 0
			end

			if w < num then
				num = w or num
			end

			self:setDestPoint(num)

			return 
		end
	}).addTo(slot6, self.controlNode):anchor(0, 0.5)

	an.newLabel("纵:", 20, 1, {
		color = cc.c3b(255, 255, 0)
	}):anchor(0, 0.5):pos(150, b3.geth(b3)/2 - 2):addTo(self.controlNode)

	self.inputy = an.newInput(185, b3.geth(b3)/2 - 7, 86, 32, 4, {
		label = {
			"",
			20,
			1
		},
		bg = {
			h = 32,
			tex = res.gettex2("pic/scale/edit.png"),
			offset = {
				-3,
				4
			}
		},
		stop_call = function ()
			local num = tonumber(self.inputy:getText()) or 0
			local w, h = self:mapSize()

			if num < 0 then
				num = 0
			end

			if h < num then
				num = h or num
			end

			self:setDestPoint(nil, num)

			return 
		end
	}).addTo(slot6, self.controlNode):anchor(0, 0.5)
	self.likeSpr = res.get2("pic/panels/bigmap/start_n.png"):enableClick(function (x, y)
		sound.playSound("103")

		local x = tonumber(self.inputx:getText())
		local y = tonumber(self.inputy:getText())

		if self.likeSpr.state then
			g_data.bigmap:removeLike(self.mapid, x, y)
			self:setLikeSprState(false)
			main_scene.ui:tip("移除收藏坐标成功", 6)

			self.curLikePos = nil
		else
			if not self:canLike(x, y) then
				return 
			end

			local edit = nil
			local box, bg = common.msgbox("", {
				okFunc = function ()
					local str = edit:getText()

					if string.len(str) == 0 or not def.wordfilter.check(str) then
						main_scene.ui:tip("名字为空或无效，请重新输入", 6)
						edit:clear()
					elseif g_data.bigmap:isExistLikeName(self.mapid, str) then
						main_scene.ui:tip("收藏点重名，请重新命名", 6)
						edit:clear()
					else
						g_data.bigmap:addLike(self.mapid, str, x, y)
						self:setLikeSprState(true)
						main_scene.ui:tip("收藏坐标点成功", 6)

						self.curLikePos = {
							x = x,
							y = y,
							id = self.mapid
						}
					end

					return 
				end,
				title = res.gettex2("pic/panels/bigmap/quick.png")
			})

			an.newLabel("给收藏的地点加一个名字", 20, 1, {
				color = def.colors.labelYellow
			}).addTo(slot7, bg):pos(bg.getw(bg)/2, 210):anchor(0.5, 0.5)

			edit = an.newInput(0, 0, 200, 45, 4, {
				bg = {
					h = 36,
					tex = res.gettex2("pic/scale/edit.png"),
					offset = {
						-20,
						5
					}
				}
			}):addTo(bg):pos(bg.getw(bg)/2 + 20, bg.geth(bg)/2 + 15):anchor(0.5, 0.5)

			an.newLabel("您可以在快捷寻路中找到您收藏的坐标", 16, 1, {
				color = def.colors.btn20
			}):addTo(bg):pos(bg.getw(bg)/2, 100):anchor(0.5, 0.5)
		end
	end).addTo(slot6, self.controlNode):pos(280, b3.geth(b3)/2 - 2):anchor(0, 0.5)

	local function autopath()
		sound.playSound("103")

		local x = tonumber(self.inputx:getText())
		local y = tonumber(self.inputy:getText())

		if not x or not y then
			main_scene.ui:tip("目标已是寻路点或已到达", 6)

			return 
		end

		if self.mapid == main_scene.ground.map.mapid and self.dest.from == "npc" then
			y = y + 1
		end

		if self:canWalk(x, y).block then
			main_scene.ui:tip("目标是阻挡, 无法到达", 6)

			return 
		end

		main_scene.ui.console.controller.autoFindPath:searching(x, y, self.mapid)

		return 
	end

	local function sdgo()
		sound.playSound("103")

		local x = tonumber(self.inputx:getText())
		local y = tonumber(self.inputy:getText())

		if not x or not y then
			main_scene.ui:tip("目标已是寻路点或已到达", 6)

			return 
		end

		if self.mapid ~= main_scene.ground.map.mapid then
			main_scene.ui:tip("无法在不同地图间传送", 6)

			return 
		end

		if self.dest.from == "npc" then
			y = y + 1
		end

		if main_scene.ground.map:canWalk(x, y).block then
			main_scene.ui:tip("目标是阻挡, 无法传送", 6)

			return 
		end

		if (not g_data.equip.items[7] or g_data.equip.items[7].getVar("name") ~= "传送戒指") and (not g_data.equip.items[8] or g_data.equip.items[8].getVar("name") ~= "传送戒指") then
			an.newMsgbox("需要佩戴传送戒指！", nil, {
				center = true
			})

			return 
		end

		return 
	end

	local function quickpath()
		sound.playSound("103")
		self:loadQuickPath()

		return 
	end

	local posX = 350
	local xSpace = 150
	local btns = {
		{
			lb = "快捷寻路",
			click = quickpath,
			posx = posX
		},
		{
			lb = "自动寻路",
			click = autopath,
			posx = posX + xSpace
		}
	}

	for i, v in ipairs(slot11) do
		an.newBtn(res.gettex2("pic/common/btn20.png"), v.click, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			label = {
				v.lb,
				20,
				0,
				{
					color = cc.c3b(240, 200, 150)
				}
			}
		}):anchor(0, 0.5):pos(v.posx, b3.geth(b3)/2 - 2):addTo(self.controlNode)
	end

	an.newBtn(res.gettex2("pic/common/close10.png"), function ()
		sound.playSound("103")
		self:hidePanel()

		return 
	end, {
		pressImage = res.gettex2("pic/common/close11.png"),
		size = cc.size(64, 64)
	}).anchor(slot12, 1, 1):pos(b1.getw(b1) - 9, b1.geth(b1) - 9):addTo(b1)
	self.tabs.click(2, true)
	self.loadLocalMap(self)

	local autoFindPath = main_scene.ui.console.controller.autoFindPath
	local pathDestX = autoFindPath.destx
	local pathDestY = autoFindPath.desty

	self.schedule(self, function ()
		if autoFindPath.points and (pathDestX ~= autoFindPath.destx or pathDestY ~= autoFindPath.desty) then
			self:loadFindPath()
		end

		return 
	end, 0.1)

	local rsb = DefaultClientMessage(CM_MapQueryWarFlag)

	MirTcpClient.getInstance(slot16):postRsb(rsb)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_MapQueryWarFlag, self, self.onSM_MapQueryWarFlag)

	return 
end
bigmap.reset = function (self, size)
	self.size(self, self.bgSprs[1]:getw(), size.height + controlHeight):anchor(0.5, 0.5):center()
	self.bgSprs[1]:pos(0, self.geth(self))
	self.bgSprs[2]:pos(0, self.bgSprs[3]:geth()):scaleY((self.geth(self) - self.bgSprs[1]:geth() - self.bgSprs[3]:geth())/self.bgSprs[2]:geth())

	if self._touchFrames and self._touchFrames.main then
		local rect = cc.rect(0, 0, self.getw(self), self.geth(self))

		self.addTouchFrame(self, rect, "main")
	end

	return 
end
bigmap.loadFindPath = function (self)
	self.loadFindPathPoint(self, main_scene.ui.console.controller.autoFindPath.points)

	local point = main_scene.ui.console.controller.autoFindPath.points[#main_scene.ui.console.controller.autoFindPath.points]

	if not main_scene.ui.console.autoRat.enableRat then
		self.loadDestPoint(self, point.x, point.y, {
			noAction = true
		})
	end

	return 
end
bigmap.loadLocalMap = function (self, param)
	self.controlNode:show()
	self.unloadMapFile(self)

	if param and param.switch then
		self.mapid = param.id
		self.title = param.title
		local mapFile = res.loadmap(self.mapid)
		self.maph = mapFile.geth(mapFile)
		self.mapw = mapFile.getw(mapFile)
	else
		self.mapid = main_scene.ground.map.mapid
		self.title = g_data.map.mapTitle
		self.maph = main_scene.ground.map.h
		self.mapw = main_scene.ground.map.w
	end

	common.getMinimapTexture(self.mapid, function (tex)
		local maxw = 615
		local maxh = 450
		self.texSize = tex.getContentSize(tex)
		self.mapScale = math.min(maxw/self.texSize.width, maxh/self.texSize.height)
		local mapSize = cc.size(self.texSize.width*self.mapScale, self.texSize.height*self.mapScale)
		local resetSize = cc.size(mapSize.width, mapSize.height)
		local offsetX = 0
		local offsetY = 0

		if maxh <= mapSize.height and mapSize.width < maxw then
			offsetX = (self.bgSprs[1]:getw() - 26 - mapSize.width)/2
		elseif maxw <= mapSize.width and mapSize.height < minh then
			resetSize.height = minh
			offsetY = (minh - mapSize.height)/2
		end

		self:reset(resetSize)

		self.mapNode = display.newNode():pos(offsetX + 13, offsetY + 60):size(mapSize):addTo(self, 1)
		self.mapSpr = display.newSprite(tex):scale(self.mapScale):anchor(0, 0):addTo(self.mapNode)

		display.newScale9Sprite(res.getframe2("pic/scale/scale27.png"), 0, 0, mapSize):anchor(0, 0):addTo(self.mapNode)

		self.titleLabel = an.newLabel(self.title, 20, 1, {
			color = display.COLOR_WHITE
		}):addTo(self.mapNode):pos(5, 5):anchor(0, 0)

		self:loadEntryInfo()
		self:pointUpt(main_scene.ground.map, main_scene.ground.player)

		if main_scene.ui.console.controller.autoFindPath.points then
			self:loadFindPath()
		end

		local hasMove, handler = nil
		local doubleClick = false

		local function click(event)
			if tolua.isnull(self) or tolua.isnull(self.mapNode) then
				return 
			end

			local rect1 = self:getBoundingBox()
			local rect2 = self.mapNode:getBoundingBox()
			local x, y = self:gamePos(event.x - rect1.x - rect2.x, event.y - rect1.y - rect2.y)
			local point = self:canWalk(x, y)

			if doubleClick then
				if not point.block then
					main_scene.ui.console.controller.autoFindPath:searching(x, y, self.mapid)
				else
					main_scene.ui:tip("目标是阻挡, 无法到达！")
				end
			end

			handler = nil
			doubleClick = nil

			return 
		end

		local touchNode = display.newNode().size(slot11, self.mapNode:getContentSize()):addto(self.mapNode)

		touchNode.setTouchEnabled(touchNode, true)
		touchNode.addNodeEventListener(touchNode, cc.NODE_TOUCH_EVENT, function (event)
			local rect1 = self:getBoundingBox()
			local rect2 = self.mapNode:getBoundingBox()
			local x = event.x - rect1.x - rect2.x
			local y = event.y - rect1.y - rect2.y

			if event.name == "began" then
				if handler then
					doubleClick = true

					return false
				end

				return true
			elseif event.name == "moved" then
				hasMove = true
			elseif event.name == "ended" then
				local pos = self:convertToNodeSpace(cc.p(event.x, event.y))

				if cc.rectContainsPoint(self.mapNode:getBoundingBox(), cc.p(pos.x, pos.y)) then
					self:setDestPoint(self:gamePos(x, y))

					if not hasMove then
						handler = scheduler.performWithDelayGlobal(function ()
							click(event)

							return 
						end, 0.25)
					end
				end

				hasMove = false
			end

			return 
		end)

		return 
	end)

	return 
end
bigmap.loadWorldMap = function (self)
	self.controlNode:hide()

	local localh = self.texSize.height*self.mapScale
	local worldMapSize = cc.size(615, (localh < minh and minh - 2) or localh)
	self.worldMapScale = 0.75
	self.worldMapNode = an.newScroll(14, 61, worldMapSize.width, worldMapSize.height, {
		dir = 0
	}):addTo(self, 1)

	self.worldMapNode.scrollView:setBounceable(false)

	self.worldMapSpr = res.get2("pic/panels/bigmap/bg4.png"):addTo(self.worldMapNode):scale(self.worldMapScale):anchor(0, 1):pos(0, worldMapSize.height)
	self.borderSpr = display.newScale9Sprite(res.getframe2("pic/scale/scale27.png"), 13, 60, cc.size(worldMapSize.width + 2, worldMapSize.height + 2)):anchor(0, 0):addTo(self, 2)

	local function checkScrollPos(pos)
		local x = pos.x*self.worldMapScale
		local y = pos.y*self.worldMapScale
		x = x + worldMapSize.width/2

		if 0 < x then
			x = 0
		end

		if self.worldMapSpr:getw()*self.worldMapScale < math.abs(x - worldMapSize.width) then
			x = worldMapSize.width - self.worldMapSpr:getw()*self.worldMapScale or x
		end

		y = y + worldMapSize.height/2

		if y < worldMapSize.height then
			y = worldMapSize.height or y
		end

		if self.worldMapSpr:geth()*self.worldMapScale < y then
			y = self.worldMapSpr:geth()*self.worldMapScale or y
		end

		return x, y
	end

	local scrollpos = nil

	if config[self.mapid] then
		res.get2("pic/panels/bigmap/p-blue.png").addTo(slot5, self.worldMapSpr, 1):pos(config[self.mapid].signpos.x, config[self.mapid].signpos.y)
		self.worldMapNode.scrollView:scrollTo(checkScrollPos(config[self.mapid].worldpos))
	else
		self.worldMapNode.scrollView:scrollTo(checkScrollPos(config.0.worldpos))
	end

	for k, v in pairs(config) do
		local exactTouchInst = exactTouch:create(res.getfile("pic/panels/bigmap/btn-" .. v.res .. ".png"))
		local area = nil
		area = an.newBtn(res.gettex2("pic/panels/bigmap/btn-" .. v.res .. ".png"), function ()
			area.sprite:setTex(res.gettex2("pic/panels/bigmap/labeln-" .. v.res .. ".png"))
			self.tabs.click(2, true)
			self:change2LocalMap({
				switch = true,
				id = k,
				title = v.title
			})

			return 
		end, {
			support = "scroll",
			pressBig = 1.001,
			pressShow = true,
			sprite = res.gettex2("pic/panels/bigmap/labeln-" .. v.res .. ".png"),
			spriteOffset = v.spriteOffset,
			customTouchCheck = function (x, y)
				local p = area:convertToNodeSpace(cc.p(x, y))

				return exactTouchInst:containsPoint(p.x, p.y)
			end,
			call_remove = function ()
				exactTouchInst:release()

				return 
			end
		}).addTo(slot12, self.worldMapSpr):pos(v.x, v.y):anchor(0.5, 0.5)
	end

	return 
end
bigmap.loadQuickPath = function (self)
	local sizeW = self.getContentSize(self).width
	local sizeH = self.getContentSize(self).height
	local node = display.newNode():addTo(self, 999):size(display.width, display.height):anchor(0.5, 0.5):pos(sizeH/2, sizeW/2)
	self.quickNode = node
	local bg = res.get2("pic/panels/bigmap/quick-bg.png"):addTo(node):pos(node.getw(node)/2 + 60, node.geth(node)/2 - 60):anchor(0.5, 0.5)

	an.newLabel("快捷寻路", 20, 0, {
		color = def.colors.Cd2b19c
	}):addTo(bg):pos(bg.getw(bg)/2, bg.geth(bg) - 18):anchor(0.5, 0.5)
	an.newBtn(res.gettex2("pic/common/close10.png"), function ()
		sound.playSound("103")
		node:removeSelf()

		node = nil

		return 
	end, {
		pressImage = res.gettex2("pic/common/close11.png"),
		size = cc.size(64, 64)
	}).anchor(slot5, 1, 1):pos(bg.getw(bg) - 4, bg.geth(bg) - 3):addTo(bg)
	display.newScale9Sprite(res.getframe2("pic/scale/edit.png"), 0, 0, cc.size(165, 260)):addTo(bg):pos(112, 15):anchor(0, 0)

	local isFromNpc = false
	local list = display.newNode():addTo(bg)

	local function createList(key)
		list:removeAllChildren()

		local scroll = an.newScroll(115, 17, 160, 255):addTo(list):anchor(0, 0)
		local data = {}

		if key == "NPC" then
			self.npcScroll = scroll

			scroll.setNodeEventEnabled(scroll, true)

			scroll.onCleanup = function ()
				self.npcScroll = nil

				return 
			end
			local npcs = g_data.bigmap.getNpcs(slot3, self.title)

			if not npcs then
				g_data.client:setLastNpcMap({
					title = self.title,
					id = self.mapid
				})

				local rsb = DefaultClientMessage(CM_QUERY_MAP_NPC)

				if self.mapid == main_scene.ground.map.mapid then
					rsb.FMode = 0
				else
					rsb.FMode = 1
					rsb.FMapName = tostring(self.mapid)
				end

				MirTcpClient:getInstance():postRsb(rsb)
			else
				isFromNpc = true
			end

			data = npcs or {}
		elseif key == "transform" then
			for i, v in pairs(def.map.transferPositions) do
				local var = string.split(i, "-")

				if var[1] == self.mapid then
					data[#data + 1] = {
						id = var[1],
						name = v.name,
						x = v.x,
						y = v.y,
						destMapid = var[2]
					}
				end
			end
		else
			local likes = g_data.bigmap:getLikes(self.mapid)

			if likes then
				if self.mapid == main_scene.ground.map.mapid then
					data = likes
				else
					for i, v in ipairs(likes) do
						data[#data + 1] = {
							dataType = "pos",
							name = v.name,
							x = v.x,
							y = v.y,
							destMapid = self.mapid
						}
					end
				end
			end
		end

		self:createCell(data, scroll, isFromNpc)

		return 
	end

	local tabInfo = {
		"角色",
		"传送点",
		"收藏"
	}

	common.tabs(slot4, {
		ox = 0,
		size = 20,
		strokeSize = 1,
		oy = 0,
		strs = tabInfo,
		lc = {
			normal = def.colors.Cf0c896,
			select = def.colors.Cf0c896
		}
	}, function (idx, btn)
		createList(({
			"NPC",
			"transform",
			"like"
		})[idx])

		return 
	end, {
		tabTp = 2,
		scale = 0.8,
		pos = {
			offset = 45,
			x = 15,
			y = 230,
			anchor = cc.p(0, 0)
		}
	})
	node.setTouchEnabled(slot3, true)
	node.setTouchSwallowEnabled(node, true)
	node.addNodeEventListener(node, cc.NODE_TOUCH_EVENT, function (event)
		if event.name == "began" and not cc.rectContainsPoint(bg:getBoundingBox(), cc.p(event.x, event.y)) then
			node:removeSelf()

			node = nil
		end

		return 
	end)

	return 
end
bigmap.createCell = function (self, data, scroll, fromNpc)
	scroll.removeAllChildren(scroll)

	for i, v in ipairs(data) do
		local y = (i - 1)*44 - 260 - 30
		local lbl = an.newBtn(res.gettex2("pic/panels/bigmap/label_n.png"), function (btn)
			sound.playSound("103")
			main_scene.ui.console.controller.autoFindPath:searching(v.x, (fromNpc and v.y + 1) or v.y, v.destMapid)
			self.quickNode:removeSelf()

			return 
		end, {
			support = "scroll",
			pressImage = res.gettex2("pic/panels/bigmap/label_s.png"),
			label = {
				v.name,
				20,
				1,
				{
					color = def.colors.btn30
				}
			}
		}).addTo(slot10, scroll):pos(80, y):anchor(0.5, 0.5)

		local function removeData(data, x, y)
			for i, v in ipairs(data) do
				if v.x == x and v.y == y then
					table.removebyvalue(data, v)
				end
			end

			return data
		end

		local function removeCallback(sender)
			sound.playSound("103")

			if sender and sender.getParent(sender) then
				if self.curLikePos and self.curLikePos.x == v.x and self.curLikePos.y == v.y then
					self:setLikeSprState(false)

					self.curLikePos = nil
				end

				sender.getParent(sender):removeFromParent()
				g_data.bigmap:removeLike(v.destMapid or self.mapid, v.x, v.y)
				main_scene.ui:tip("移除收藏坐标成功", 6)
				removeData(data, x, y)
				self:createCell(data, scroll, fromNpc)
			end

			return 
		end

		if v.dataType and v.dataType == "pos" then
			local closeBtn = an.newBtn(res.gettex2("pic/common/close10.png"), slot12, {
				pressImage = res.gettex2("pic/common/close11.png")
			}):addTo(lbl)
			local posx = lbl.getw(lbl) - closeBtn.getw(closeBtn)/2
			local posy = lbl.geth(lbl)/2

			closeBtn.pos(closeBtn, posx, posy):anchor(0.5, 0.5)

			closeBtn.x = v.x
			closeBtn.y = v.y
		end
	end

	return 
end
bigmap.uptNpcCell = function (self)
	if self.npcScroll then
		local data = g_data.bigmap:getNpcs(self.title)

		if data then
			self.createCell(self, data, self.npcScroll, true)
		end
	end

	return 
end
bigmap.loadEntryInfo = function (self)
	local info = def.bigmap[tostring(self.mapid)]

	if info then
		for i, v in ipairs(info) do
			an.newLabel(v[2], 16, 2, {
				color = def.colors.text
			}):addTo(self.mapNode):pos(self.mapPos(self, v[3], v[4])):anchor(0.5, 0.5)
		end
	end

	return 
end
bigmap.loadDestPoint = function (self, x, y, params)
	if not self.mapNode then
		return 
	end

	if not self.dest then
		self.dest = {}
	end

	local form = params.from
	local noAction = params.noAction
	self.dest.x = x or self.dest.x or 0
	self.dest.y = y or self.dest.y or 0
	self.dest.from = from
	x, y = self.mapPos(self, self.dest.x, self.dest.y)

	if not self.destPoint then
		self.destPoint = res.get2("pic/panels/bigmap/p-blue.png"):anchor(0.5, 0):addTo(self.mapNode, 1)
	end

	if self.canWalk(self, self.dest.x, self.dest.y).block then
		self.destPoint:setTex(res.gettex2("pic/panels/bigmap/p-red.png"))
		self.setLikeSprState(self, false)
	else
		self.destPoint:setTex(res.gettex2("pic/panels/bigmap/p-blue.png"))

		if g_data.bigmap:isExistLike(self.mapid, self.dest.x, self.dest.y) then
			self.setLikeSprState(self, true)
		else
			self.setLikeSprState(self, false)
		end
	end

	self.destPoint:stopAllActions()

	if noAction then
		self.destPoint:pos(x, y):show()
	else
		self.destPoint:pos(x, self.mapNode:geth()):show()
		self.destPoint:moveTo(0.1, x, y)
	end

	return 
end
bigmap.mapSize = function (self)
	local w, h = nil

	if self.mapid ~= main_scene.ground.map.mapid then
		h = self.maph
		w = self.mapw
	else
		h = main_scene.ground.map.h
		w = main_scene.ground.map.w
	end

	return w, h
end
bigmap.mapPos = function (self, x, y)
	local w, h = self.mapSize(self)
	local percent = {
		x = self.texSize.width/w*self.mapScale,
		y = self.texSize.height/h*self.mapScale
	}

	return x*percent.x, (h - y - 1)*percent.y
end
bigmap.gamePos = function (self, x, y)
	local w, h = self.mapSize(self)
	local percent = {
		x = self.texSize.width/w*self.mapScale,
		y = self.texSize.height/h*self.mapScale
	}

	return math.modf(x/percent.x), math.modf(h - y/percent.y - 1)
end
bigmap.setDestPoint = function (self, x, y, from)
	self.loadDestPoint(self, x, y, {
		from = from
	})
	self.inputx:setString(self.dest.x .. "")
	self.inputy:setString(self.dest.y .. "")
	main_scene.ui.console.controller.autoFindPath:multiMapPathStop()

	return 
end
bigmap.canWalk = function (self, gamex, gamey)
	local ret = nil

	if self.mapid ~= main_scene.ground.map.mapid then
		ret = {}
		local mapFile = res.loadmap(self.mapid)
		local data = mapFile.gettile(mapFile, gamex, gamey)

		if data then
			if 0 < ycFunction:band(data.doorIndex, 128) and not data.doorOpen then
				ret.block = "door"
				ret.data = data
			elseif not data.canWalk then
				ret.block = "map"
			end
		end
	else
		ret = main_scene.ground.map:canWalk(gamex, gamey)
	end

	return ret
end
bigmap.removeAllFindPath = function (self)
	if self.worldMode or not self.mapNode then
		return 
	end

	if self.findPathNode then
		self.findPathNode:removeSelf()

		self.findPathNode = nil
	end

	self.findPathPoint = nil

	return 
end
bigmap.removePoint = function (self, key)
	if self.worldMode or not self.mapNode then
		return 
	end

	if self.findPathPoint and self.findPathPoint[key] then
		self.findPathPoint[key]:removeSelf()

		self.findPathPoint[key] = nil
	end

	return 
end

if 0 < DEBUG then
	bigmap.loadFlagPoints = function (self, type, points, color)
		if self.worldMode or self.mapid ~= main_scene.ground.map.mapid then
			return 
		end

		self.flagPoints = self.flagPoints or {}

		if not tolua.isnull(self.flagPoints[type]) then
			self.flagPoints[type]:removeSelf()
		end

		self.flagPoints[type] = display.newNode():size(self.mapNode:getContentSize()):addTo(self.mapNode)
		local findPathNode = self.flagPoints[type]
		local autoFindPath = main_scene.ui.console.controller.autoFindPath

		for i, v in ipairs(points) do
			local point = display.newColorLayer(color or cc.c4b(0, 0, 255, 255)):size(4, 4):addTo(findPathNode)
			local x, y = self.mapPos(self, v.x, v.y)

			point.pos(point, x - self.point:getw()/2, y - self.point:geth()/2)
		end

		return findPathNode
	end
end

bigmap.loadFindPathPoint = function (self, points)
	if self.worldMode or self.mapid ~= main_scene.ground.map.mapid then
		return 
	end

	if not self.mapNode then
		return 
	end

	self.removeAllFindPath(self)

	self.findPathNode = display.newNode():size(self.mapNode:getContentSize()):addTo(self.mapNode)
	self.findPathPoint = {}
	local autoFindPath = main_scene.ui.console.controller.autoFindPath

	for i, v in ipairs(points) do
		local point = display.newColorLayer(cc.c4b(0, 255, 255, 255)):size(4, 4):addTo(self.findPathNode)
		local x, y = self.mapPos(self, v.x, v.y)

		point.pos(point, x - self.point:getw()/2, y - self.point:geth()/2)

		self.findPathPoint[autoFindPath.key(autoFindPath, v.x, v.y)] = point
	end

	return 
end
bigmap.pointUpt = function (self, map, player)
	if self.worldMode or self.mapid ~= main_scene.ground.map.mapid then
		return 
	end

	if not self.mapNode then
		return 
	end

	if not self.point then
		self.point = display.newColorLayer(def.colors.get(251, true)):addTo(self.mapNode, 1):size(6, 6)
	end

	local x, y = self.mapPos(self, player.x, player.y)

	self.point:pos(x - self.point:getw()/2, y - self.point:geth()/2)

	return 
end
bigmap.resetInput = function (self)
	self.inputx:setString("")
	self.inputy:setString("")

	return 
end
bigmap.loadMapFile = function (self)
	return 
end
bigmap.unloadMapFile = function (self)
	if self.mapid and self.mapid ~= main_scene.ground.map.mapid then
		res.unLoadmap(self.mapid)
	end

	return 
end
bigmap.removeLocalMap = function (self)
	if self.mapNode then
		self.mapNode:removeSelf()

		self.mapNode = nil
		self.findPathNode = nil
		self.point = nil
		self.findPathPoint = nil
		self.destPoint = nil
		self.titleLabel = nil

		self.unscheduleHandle(self)
	end

	return 
end
bigmap.removeWorldMap = function (self)
	if self.worldMapNode then
		self.worldMapNode:removeSelf()

		self.worldMapNode = nil

		self.borderSpr:removeSelf()

		self.borderSpr = nil
	end

	return 
end
bigmap.change2WorldMap = function (self)
	if self.worldMode then
		return 
	end

	self.worldMode = true

	self.resetInput(self)
	self.removeLocalMap(self)
	self.loadWorldMap(self)

	return 
end
bigmap.change2LocalMap = function (self, param)
	if not self.worldMode then
		return 
	end

	self.worldMode = false

	self.resetInput(self)
	self.removeWorldMap(self)
	self.loadLocalMap(self, param)

	return 
end
bigmap.change2CurMap = function (self)
	self.resetInput(self)
	self.removeLocalMap(self)
	self.loadLocalMap(self)

	return 
end
bigmap.setLikeSprState = function (self, state)
	self.likeSpr:setTex(res.gettex2((state and "pic/panels/bigmap/start_s.png") or "pic/panels/bigmap/start_n.png"))

	self.likeSpr.state = state

	return 
end
bigmap.updateTitle = function (self)
	if self.worldMode or not self.titleLabel then
		return 
	end

	self.title = g_data.map.mapTitle

	self.titleLabel:setString(g_data.map.mapTitle)

	return 
end
bigmap.unscheduleHandle = function (self)
	if self.handler then
		scheduler.unscheduleGlobal(self.handler)

		self.handler = nil
	end

	return 
end
bigmap.update = function (self, dt)
	if self.uptFlagTime <= 0 then
		self.uptFlagTime = 5
		local rsb = DefaultClientMessage(CM_MapQueryWarFlag)

		MirTcpClient:getInstance():postRsb(rsb)
	end

	self.uptFlagTime = self.uptFlagTime - dt

	return 
end
bigmap.onSM_MapQueryWarFlag = function (self, result)
	if not result and not result.FWarFlagInfoList then
		return 
	end

	for id, it in pairs(self.flagList) do
		if self.flagList[id] then
			self.flagList[id]:removeSelf()

			self.flagList[id] = nil
		end
	end

	for k, v in pairs(result.FWarFlagInfoList) do
		local x, y = self.mapPos(self, v.FCurr_X, v.FCurr_Y)
		local flag = nil

		if v.FState == 0 then
			flag = res.get2("pic/panels/militaryEquip/red.png")
		elseif v.FState == 1 then
			flag = res.get2("pic/panels/militaryEquip/blue.png")
		elseif v.FState == 2 then
			flag = res.get2("pic/panels/militaryEquip/blue.png")
		end

		if flag then
			flag.scale(flag, 0.4):anchor(0.5, 0):add2(self.mapNode, 1):pos(x, y)

			self.flagList[v.FFlagId] = flag
		end
	end

	return 
end

return bigmap
