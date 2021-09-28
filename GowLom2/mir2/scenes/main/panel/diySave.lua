local widgetDef = g_data.widgetDef
local detail = import("..console.detail")
local iconFunc = import("..console.iconFunc")
local common = import("..common.common")
local magic = import("..common.magic")
local diySave = class("diySave", function ()
	return display.newNode()
end)
diySave.onEnter = function (self)
	return 
end
diySave.onExit = function (self)
	return 
end
diySave.ctor = function (self, name)
	self._supportMove = true

	self.setNodeEventEnabled(self, true)
	self.size(self, 481, 341):anchor(0.5, 1):pos(display.width*0.5, display.height - 30)

	local bg = res.get2("pic/panels/diy/archivebg.png"):anchor(0.5, 0.5):pos(self.getw(self)*0.5, self.geth(self)*0.5):addto(self)

	an.newLabel("存档", 20, 0, {
		color = def.colors.Cd2b19c
	}):anchor(0.5, 0.5):pos(bg.getw(bg)*0.5, bg.geth(bg) - 24):addto(bg)

	local cel = res.get2("pic/panels/diy/archivecell.png"):pos(self.getw(self)*0.5, self.geth(self)*0.5 + 10):addto(self)

	an.newBtn(res.gettex2("pic/common/close10.png"), function ()
		sound.playSound("103")
		self:hidePanel()

		return 
	end, {
		pressImage = res.gettex2("pic/common/close11.png"),
		size = cc.size(64, 64)
	}).anchor(slot4, 1, 1):pos(self.getw(self) - 8, self.geth(self) - 8):addto(self)

	local heightDefine = 70
	local chatView, curSelectIndex = nil
	local eventCells = {}
	local titleConfig = {}

	local function refushArchive()
		eventCells = {}
		titleConfig = {}
		curSelectIndex = nil

		if chatView then
			chatView:removeSelf()
		end

		chatView = an.newScroll(4, 4, 440, 204):pos(20, 78):add2(self, 100)
		local listInfo = self:getArchive()
		listInfo = listInfo or {}

		table.insert(listInfo, 1, {
			"系统默认",
			color = def.colors.labelYellow
		})
		chatView:setScrollSize(443, math.max(210, #listInfo*heightDefine))

		local index = 1

		for i, v in ipairs(listInfo) do
			titleConfig[index] = v[1]
			local cellindex = index
			local cellback = res.get2("pic/panels/diy/btn0.png")

			cellback.anchor(cellback, 0.5, 0.5):pos(chatView:getw()*0.5, (chatView:getScrollSize().height + 35) - index*heightDefine):add2(chatView)
			an.newLabel(v[1], 20, 1, {
				color = v.color or def.colors.labelGray
			}):anchor(0, 0.5):addto(cellback):pos(30, cellback.geth(cellback)*0.5)

			if v[2] then
				an.newLabel("时间:", 20, 1, {
					color = def.colors.labelGray
				}):anchor(0, 0.5):addto(cellback):pos(170, cellback.geth(cellback)*0.5)
				an.newLabel(v[2], 20, 1, {
					color = def.colors.labelGray
				}):anchor(0, 0.5):addto(cellback):pos(220, cellback.geth(cellback)*0.5)
			end

			cellback.setTouchEnabled(cellback, true)
			cellback.setTouchSwallowEnabled(cellback, false)
			cellback.addNodeEventListener(cellback, cc.NODE_TOUCH_EVENT, function (event)
				if event.name == "began" then
					cellback.offsetBeginX = event.x
					cellback.offsetBeginY = event.y

					return true
				elseif event.name == "ended" then
					local offsetX = event.x - cellback.offsetBeginX
					local offsetY = event.y - cellback.offsetBeginY

					if math.abs(offsetX) < 5 and math.abs(offsetY) < 5 and curSelectIndex ~= cellindex then
						if curSelectIndex then
							eventCells[curSelectIndex]:setTex(res.gettex2("pic/panels/diy/btn0.png"))
						end

						curSelectIndex = cellindex

						eventCells[curSelectIndex]:setTex(res.gettex2("pic/panels/diy/btn1.png"))
					end
				end

				return 
			end)

			eventCells[index] = cellback
			index = index + 1
		end

		return 
	end

	slot9()

	local function clickBtn(idx)
		sound.playSound("103")

		if idx == 1 then
			if curSelectIndex then
				self:reuseArchive(titleConfig[curSelectIndex])
				main_scene.ui:loadConsole()

				if curSelectIndex == 1 then
					main_scene.ui.console.skills:defLayout()
				end

				main_scene.ui.panels.diy:setFocus()
				main_scene.ui.panels.diy:ready()
			else
				main_scene.ui.leftTopTip:show("请选择想应用的配置", 6)
			end
		elseif idx == 2 then
			if curSelectIndex then
				if curSelectIndex == 1 then
					main_scene.ui.leftTopTip:show("系统默认配置不能删除", 6)
				else
					self:delArchive(titleConfig[curSelectIndex])
					refushArchive()
				end
			else
				main_scene.ui.leftTopTip:show("请选择待删除的配置", 6)
			end
		end

		return 
	end

	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		clickBtn(1)

		return 
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		label = {
			"应用",
			20,
			1,
			{
				color = def.colors.Cf0c896
			}
		}
	}).pos(slot11, bg.getw(bg)*0.75, 42):addTo(bg)
	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		clickBtn(2)

		return 
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		label = {
			"删除",
			20,
			1,
			{
				color = def.colors.Cf0c896
			}
		}
	}).pos(slot11, bg.getw(bg)*0.25, 42):addTo(bg)

	return 
end
diySave.getArchive = function (self)
	local datas = cache.getDiy(common.getPlayerName(), "_list")

	return datas
end
diySave.reuseArchive = function (self, key)
	local datas = cache.getDiy(common.getPlayerName(), key)

	if datas then
		cache.removeDiy(common.getPlayerName(), "_current")
		cache.saveDiy(common.getPlayerName(), "_current", datas)
	elseif key == "系统默认" then
		cache.removeDiy(common.getPlayerName(), "_current")
	end

	return 
end
diySave.resetArchive = function (self, key)
	local listDatas = cache.getDiy(common.getPlayerName(), "_list")

	if not listDatas then
		return 
	end

	local canReset = false

	for i, v in ipairs(listDatas) do
		if v[1] == key then
			canReset = true

			break
		end
	end

	if not canReset then
		return 
	end

	cache.removeDiy(common.getPlayerName(), key)
	main_scene.ui.console:saveEdit(key)

	return 
end
diySave.delArchive = function (self, key)
	local listDatas = cache.getDiy(common.getPlayerName(), "_list")
	listDatas = listDatas or {}

	cache.removeDiy(common.getPlayerName(), key)

	for i, v in ipairs(listDatas) do
		if v[1] == key then
			table.remove(listDatas, i)
		end
	end

	cache.saveDiy(common.getPlayerName(), "_list", listDatas)

	return 
end

return diySave
