local panelSize = cc.size(120, 120)
local role = import("..role.role")
local common = import("..common.common")
local minimap = class("minimap", function ()
	return display.newClippingRectangleNode(cc.rect(0, 0, panelSize.width, panelSize.height))
end)

table.merge(slot3, {})

local __position = cc.Node.setPosition
minimap.onExit = function (self)
	if minimap.pointTexture then
		minimap.pointTexture:release()

		minimap.pointTexture = nil
	end

	if main_scene.ui.minimapLoadHandle ~= nil then
		scheduler.unscheduleGlobal(main_scene.ui.minimapLoadHandle)

		main_scene.ui.minimapLoadHandle = nil
	end

	return 
end
minimap.createPointTexture = function (self)
	local dn = cc.DrawNode:create()

	dn.drawPoint(dn, cc.p(0, 0), 8, cc.c4f(1, 1, 1, 1))

	local pointTexture = cc.RenderTexture:create(1, 1)

	pointTexture.begin(pointTexture)
	dn.visit(dn)
	pointTexture.endToLua(pointTexture)
	pointTexture.retain(pointTexture)

	return pointTexture.getSprite(pointTexture):getTexture()
end

local function queryTeamMem()
	local rsb = DefaultClientMessage(CM_QueryGroupMembers)

	MirTcpClient:getInstance():postRsb(rsb)

	return 
end

minimap.ctor = function (self)
	self.setNodeEventEnabled(self, true)
	self.size(self, panelSize.width, panelSize.height):anchor(1, 1):pos(display.width, display.height - 29)
	display.newScale9Sprite(res.getframe2("pic/scale/scale2.png"), 0, 0, cc.size(self.getw(self), self.geth(self))):anchor(0, 0):add2(self, 1)

	self.isTranslucent = true

	display.newNode():size(self.getw(self), self.geth(self)):add2(self):enableClick(function ()
		if self.bg then
			if main_scene.ui.panels.bigmap then
				main_scene.ui:hidePanel("bigmap")
			else
				main_scene.ui:showPanel("bigmap")
			end
		end

		return 
	end)

	if main_scene.ui.panels.heroHead and main_scene.ui.panels.heroHead.isInPos(minimap, "hideMap") then
		main_scene.ui.panels.heroHead:resetPanelPosition("openMap")
	end

	minimap.pointTexture = minimap.pointTexture or self.createPointTexture(self)

	self.reload(self)
	g_data.eventDispatcher:addListener("TEAM_MEM_CHANGE", self, self.onTeamMemChange)
	queryTeamMem()

	if ycAtlasMgr:getInstance().setMapLoadedCallback then
		ycAtlasMgr:getInstance():setMapLoadedCallback(self, self.reload)
	end

	return 
end
minimap.onCleanup = function (self)
	if main_scene.ui.panels.heroHead and main_scene.ui.panels.heroHead:isInPos("openMap") then
		main_scene.ui.panels.heroHead:resetPanelPosition("hideMap")
	end

	return 
end
minimap.reload = function (self)
	if self.bg then
		self.bg:removeSelf()

		self.bg = nil
	end

	if self.pointNode then
		self.pointNode:removeSelf()

		self.pointNode = nil
	end

	self.points = {}
	self.pointDns = {}
	self.percent = nil

	if not main_scene.ground.map then
		return 
	end

	common.getMinimapTexture(main_scene.ground.map.mapid, function (tex)
		if tex and self then
			if self.load then
				self:load(tex)
			end
		else
			print("minimap没有可用的地图：" .. main_scene.ground.map.mapid)
			common.addMsg("没有可用的地图", def.colors.clRed, 256, true)
		end

		return 
	end, true)

	return 
end
minimap.load = function (self, tex)
	self.cameraPow = 1

	if main_scene.ground.map then
		self.cameraPow = math.max(main_scene.ground.map.w/tex.getContentSize(tex).width*2, 0.6)
	end

	self.bg = display.newSprite(tex):anchor(0, 0):add2(self):scale(self.cameraPow)
	self.pointNode = display.newNode():size(self.bg:getContentSize()):add2(self):scale(self.cameraPow)

	self.scroll(self, main_scene.ground.map, main_scene.ground.player)

	if main_scene.ground.map then
		local roles = {}

		table.merge(roles, main_scene.ground.map.heros)
		table.merge(roles, main_scene.ground.map.mons)
		table.merge(roles, main_scene.ground.map.npcs)

		for k, v in pairs(roles) do
			self.pointUpt(self, main_scene.ground.map, v)
		end
	end

	if main_scene.ui.panels.bigmap then
		main_scene.ui:hidePanel("bigmap")
		main_scene.ui:showPanel("bigmap")
	end

	return 
end
minimap.setTranslucent = function (self, isTranslucent)
	self.isTranslucent = isTranslucent

	if self.bg then
		self.bg:opacity((isTranslucent and 128) or 255)
	end

	return 
end
minimap.computePercent = function (self, map)
	if not self.percent and self.bg then
		local size = self.bg:getTexture():getContentSize()
		self.percent = {
			x = size.width/map.w,
			y = size.height/map.h
		}
	end

	return 
end
minimap.scroll = function (self, map, player)
	if not self.bg or not map or not player then
		return 
	end

	self.computePercent(self, map)

	local x = math.max(0, player.x*self.percent.x - self.getw(self)/2/self.cameraPow)
	local y = math.max(0, player.y*self.percent.y - self.geth(self)/2/self.cameraPow)

	self.bg:setTextureRect(cc.rect(x, y, self.getw(self)/self.cameraPow, self.geth(self)/self.cameraPow))

	local size = self.bg:getTexture():getContentSize()
	x = math.max(0, player.x*self.percent.x*self.cameraPow - self.getw(self)/2)
	y = math.max(0, player.y*self.percent.y*self.cameraPow - self.geth(self)/2)

	self.pointNode:pos(-x, (y + self.geth(self)) - size.height*self.cameraPow)

	return 
end
minimap.addPoint = function (self, role)
	if not self.bg or role.die then
		return 
	end

	local pointsSz = self.cameraPow/8
	local point = display.newSprite(minimap.pointTexture):add2(self.pointNode):scale(self.cameraPow/3)
	self.points[role.roleid] = point

	self.uptPointColor(self, role)

	return point
end
minimap.removePoint = function (self, roleid)
	if self.points[roleid] then
		self.points[roleid]:removeSelf()

		self.points[roleid] = nil
	end

	return 
end

local function isColorEqual(a, b)
	if not a or not b then
		return false
	end

	if type(a) ~= "table" or type(b) ~= "table" then
		return false
	end

	if a.r == b.r and a.g == b.g and a.b == b.b then
		return true
	end

	return false
end

minimap.uptPointColor = function (self, role)
	if not role then
		return 
	end

	local point = self.points[role.roleid] or nil

	if not point then
		return 
	end

	local c = role.info:getNameColor()
	local color = nil
	local race = role.getRace(role)

	if checkExist(race, 50, 12) then
		color = 215
	elseif checkExist(race, 0, 150) then
		if g_data.player.roleid == role.roleid then
			color = 255
		else
			color = c
		end
	else
		color = 249
	end

	if color then
		if type(color) == "number" then
			color = def.colors.get(color)
		end

		point.setColor(point, color)
	end

	return 
end
minimap.onTeamMemChange = function (self, roleid)
	if type(roleid) == "table" then
		for i, v in pairs(roleid) do
			local point = self.points[v] or nil
			local role = main_scene.ground.map:findRole(v)

			if role and point then
				self.uptPointColor(self, role)
			end
		end
	else
		local point = self.points[roleid] or nil

		if not point then
			return 
		end

		local role = main_scene.ground.map:findRole(roleid)

		if not role then
			return 
		end

		self.uptPointColor(self, role)
	end

	return 
end
minimap.pointUpt = function (self, map, role)
	if not self.bg then
		return 
	end

	if role.die then
		self.removePoint(self, role.roleid)
	else
		local point = self.points[role.roleid]
		point = point or self.addPoint(self, role)

		self.computePercent(self, map)
		__position(point, role.x*self.percent.x - point.getw(point)/2, (map.h - role.y - 1)*self.percent.y - point.geth(point)/2)
	end

	return 
end

return minimap
