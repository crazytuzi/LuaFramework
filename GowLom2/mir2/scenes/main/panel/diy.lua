local widgetDef = g_data.widgetDef
local detail = import("..console.detail")
local iconFunc = import("..console.iconFunc")
local common = import("..common.common")
local magic = import("..common.magic")
local diyBtn = import("..common.diyBtn")
local diy = class("diy", function ()
	return display.newNode()
end)

table.merge(slot6, {
	content,
	icons
})

diy.onCleanup = function (self)
	main_scene.ui.console:showEditBg(false)
	main_scene.ui.console:hideAllRect()
	main_scene.ui.console:endEdit()

	return 
end
diy.ready = function (self)
	for k, v in pairs(main_scene.ui.panels) do
		if k ~= "diy" and k ~= "heroHead" and k ~= "minimap" then
			main_scene.ui:hidePanel(k)
		end
	end

	if main_scene.ui.panels.minimap then
		main_scene.ui:hidePanel("minimap")
		main_scene.ui:showPanel("minimap")
	end

	main_scene.ui.console:showEditBg(true)
	main_scene.ui.console:startEdit()

	return 
end
diy.ctor = function (self, name)
	self._supportMove = true

	self.setNodeEventEnabled(self, true)

	local bg = res.get2("pic/panels/diy/bg.png"):anchor(0, 0):add2(self)

	self.size(self, bg.getw(bg), bg.geth(bg)):anchor(0, 1):pos(90, display.height - 30)
	an.newLabel("自定义界面", 20, 0, {
		color = def.colors.Cd2b19c
	}):add2(self):anchor(0.5, 0.5):pos(self.getw(self)/2, self.geth(self) - 24)
	an.newBtn(res.gettex2("pic/common/close10.png"), function ()
		sound.playSound("103")
		main_scene.ui:hidePanel("diySave")
		self:hidePanel()

		return 
	end, {
		pressImage = res.gettex2("pic/common/close11.png"),
		size = cc.size(64, 64)
	}).anchor(slot3, 1, 1):pos(self.getw(self) - 8, self.geth(self) - 8):addto(self):setName("diy_close")

	local hideBtn = nil
	hideBtn = an.newBtn(res.gettex2("pic/panels/diy/hide.png"), function ()
		if hideBtn.lock then
			return 
		end

		hideBtn.lock = true

		self.content:hide()
		self:runs({
			cc.ScaleTo:create(0.2, 0.01),
			cc.CallFunc:create(function ()
				hideBtn.lock = false

				diyBtn.new()
				self:hide()

				return 
			end)
		})

		return 
	end, {
		pressImage = res.gettex2("pic/panels/diy/hide.png"),
		spriteOffset = {
			x = -13,
			y = 17
		}
	}).anchor(slot4, 0.5, 0.5):pos(20, self.geth(self) - 25):add2(self, 1)

	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		local text = "所有主界面的控件/均可编辑/, /拖动/面板上的/图标/可拖至主界面, /红色区域/代表按钮会/自动对齐/, /其他区域/均可/任意摆放/, /单击/主界面控件可以/编辑详情/, /拖动/可以/摆放位置/, 熟练使用该系统将有助于让你在玛法大陆/叱诧风云/！"
		local array = string.split(text, "/")
		local texts = {}

		for i, v in ipairs(array) do
			if i%2 == 1 then
				texts[#texts + 1] = {
					v
				}
			else
				texts[#texts + 1] = {
					v,
					cc.c3b(255, 255, 0)
				}
			end
		end

		an.newMsgbox(texts, nil, {
			fontSize = 16
		})

		return 
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		label = {
			"帮助",
			20,
			1,
			{
				color = def.colors.Cf0c896
			}
		}
	}).anchor(slot4, 0, 0.5):pos(20, 42):add2(self, 1)
	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		local msgbox = nil
		slot1 = an.newMsgbox("请输入想要保存的文件名", function (idx)
			if idx == 2 then
				local fileName = msgbox.input:getString()

				if 16 < string.len(fileName) or string.len(fileName) < 1 then
					main_scene.ui.leftTopTip:show("请输入1-16位名字", 6)
				else
					self:saveArchive(msgbox.input:getString())
				end
			end

			return 
		end, {
			disableScroll = true,
			input = 20,
			btnTexts = {
				"关闭",
				"保存"
			}
		})
		msgbox = slot1

		return 
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		label = {
			"存档",
			20,
			1,
			{
				color = def.colors.Cf0c896
			}
		}
	}).anchor(slot4, 1, 0.5):pos(self.getw(self) - 220, 42):add2(self, 1)
	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		main_scene.ui:togglePanel("diySave")

		return 
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		label = {
			"读取",
			20,
			1,
			{
				color = def.colors.Cf0c896
			}
		}
	}).anchor(slot4, 1, 0.5):pos(self.getw(self) - 120, 42):add2(self, 1)
	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		sound.playSound("103")
		main_scene.ui:hidePanel("diySave")
		self:hidePanel()

		return 
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		label = {
			"确定",
			20,
			1,
			{
				color = def.colors.Cf0c896
			}
		}
	}).anchor(slot4, 1, 0.5):pos(self.getw(self) - 20, 42):add2(self, 1)

	local maxW = 300
	local color = def.colors.labelGray
	local desc_content = an.newLabelM(maxW, 18, 1, {
		manual = false
	}):anchor(0.5, 0.5):pos(self.getw(self)*0.435, 42):add2(self, 1)

	desc_content.addLabel(desc_content, " 点击按钮可查看介绍", color):nextLine():addLabel("拖动按钮至主界面布局", color)
	self.ready(self)
	self.loadContent(self)

	return 
end
diy.setShow = function (self, x, y)
	self.runs(self, {
		cc.Place:create(cc.p(x, y)),
		cc.Show:create(),
		cc.ScaleTo:create(0.2, 1),
		cc.CallFunc:create(function ()
			self.content:show()

			return 
		end)
	})

	return 
end
diy.loadContent = function (self)
	self.icons = {}

	if self.content then
		self.content:removeSelf()
	end

	self.content = res.get2("pic/panels/diy/bg2.png"):anchor(0.5, 0):pos(self.getw(self)*0.5, 78):add2(self)
	local scroll = an.newScroll(4, 4, self.content:getw() - 8, self.content:geth() - 8):addTo(self.content)

	scroll.setName(scroll, "diyPanel_ScrollView")

	local config = {
		widget = {
			title = "普通按钮",
			icons = {}
		},
		base = {
			title = "基础技能",
			icons = {}
		},
		skill = {
			title = "职业技能",
			icons = {}
		},
		prop = {
			title = "道具-快捷键",
			icons = {}
		},
		panel = {
			title = "面板-快捷键",
			icons = {}
		}
	}
	local keys = {
		"rocker",
		"chat",
		"btnChat",
		"btnVoice",
		"btnTask",
		"btnAutoRat",
		"btnAutoRat2",
		"btnPet",
		"btnHorse",
		"btnHide",
		"btnGroup",
		"btnFlyShoe",
		"btnHostility",
		"btnFlag"
	}

	if 2 <= g_data.client.serverState then
		table.insert(keys, #keys, "btnPet2")
	end

	for i, v in ipairs(keys) do
		local c = widgetDef.getConfig({
			key = v
		})

		if c then
			config.widget.icons[#config.widget.icons + 1] = c
		end
	end

	for i, v in pairs(widgetDef.config) do
		if type(v) == "table" and v.class == "btnMove" and v.btntype == "base" then
			config.base.icons[#config.base.icons + 1] = v
		end
	end

	local keys = def.magic.getMagicIds(g_data.player.job)

	for i, v in ipairs(keys) do
		if v ~= 66 and v ~= 67 then
			local skillLvl = g_data.player:getMagicLvl(v)
			local data = def.magic.getMagicConfigByUid(v, skillLvl)

			if data then
				local dic = clone(widgetDef.getConfig({
					key = "btnSkillTemp"
				}))
				dic._data = {
					key2 = "btnSkillTemp",
					key = "skill" .. v,
					magicId = v
				}
				config.skill.icons[#config.skill.icons + 1] = dic
			end
		end
	end

	for i, v in pairs(widgetDef.config) do
		if type(v) == "table" and v.class == "btnMove" and v.btntype == "prop" then
			config.prop.icons[#config.prop.icons + 1] = v
		end
	end

	local notShowRecharge = g_data.login:showShopAndRechargeBtn() == false

	for i, v in pairs(widgetDef.config) do
		if type(v) == "table" and v.class == "btnMove" and v.btntype == "panel" and (v.key ~= "btnPanelTop" or not g_data.serConfig or g_data.serConfig.rankClose ~= 1 or false) and (v.key ~= "btnPanelShop" or not notShowRecharge or false) and (v.key ~= "btnRecharge" or not notShowRecharge or false) and (v.key ~= "btnArena" or g_data.client.openDay >= 40 or false) then
			config.panel.icons[#config.panel.icons + 1] = v
		end
	end

	local titleSpace = 40
	local iconSpace = 80
	local begin = 12
	local iconLineNum = math.modf((self.content:getw() - begin)/iconSpace)

	local function getH()
		local h = 0

		for k, v in pairs(config) do
			print(k, #v.icons)

			h = h + titleSpace + math.ceil(#v.icons/iconLineNum)*iconSpace
		end

		return h
	end

	local h = slot10()

	scroll.setScrollSize(scroll, scroll.getw(scroll), h)

	local wNumCount = 0
	local hCount = 0

	local function addTitle(text)
		an.newLabel(text, 18, 1, {
			color = cc.c3b(255, 255, 0)
		}):anchor(0, 0.5):pos(begin + 10, h - hCount - titleSpace/2):add2(scroll)

		hCount = hCount + titleSpace

		return 
	end

	local function addIcon(config, hasNext)
		local data = {
			key = config.key
		}

		if config._data then
			table.merge(data, config._data)
		end

		local files = iconFunc:getFilenames(config, data)
		local filter = nil

		if config.class == "btnMove" and config.btntype == "skill" and not g_data.player:getMagic(tonumber(data.magicId)) then
			filter = res.getFilter("gray")
		end

		local support = "drag"

		if data.key == "btnHorse" and g_data.client.openDay < def.horse.openDay then
			support = "easy"
			filter = res.getFilter("gray")
		end

		if data.key == "btnFlag" and g_data.player:getMilitaryEquipListById(2).FLevel < 20 then
			support = "easy"
			filter = res.getFilter("gray")
		end

		local tmpIcon = nil
		local x = begin + wNumCount*iconSpace + iconSpace/2
		local y = h - hCount - iconSpace/2

		res.get2("pic/console/iconUnder.png"):pos(x, y):add2(scroll)

		local btn = nil
		btn = an.newBtn(res.gettex2(files.bg), function ()
			main_scene.ui.console:showRect(nil, data.key)

			local p = btn:convertToWorldSpace(cc.p(btn:centerPos()))

			detail.new(config, data, p.x, p.y, btn:getw(), btn:geth(), "diy")

			return 
		end, {
			pressBig = true,
			sprite = files.sprite and res.gettex2(files.sprite),
			filter = filter,
			filterOpen = filter ~= nil,
			support = support,
			call_drag_moving = function (btn, event)
				if not tmpIcon then
					btn.hide(btn)

					tmpIcon = res.get2(files.bg):scale(1.5):add2(self)

					res.get2(files.sprite):add2(tmpIcon):pos(tmpIcon:centerPos())

					if files.text then
						res.get2(files.text):add2(tmpIcon):pos(tmpIcon:getw()/2, 10)
					end

					tmpIcon:setName("diy_tmpIcon")
				end

				local p = btn.convertToWorldSpace(btn, cc.p(btn.centerPos(btn)))
				local rect = self:getBoundingBox()

				tmpIcon:pos(p.x - rect.x, p.y - rect.y)

				if config.class == "btnMove" then
					main_scene.ui.console:checkBtnAreaShow(cc.p(tmpIcon:getPositionX() + rect.x, tmpIcon:getPositionY() + rect.y))
				end

				return 
			end,
			call_drag_end = function (btn, event)
				local rect = cc.rect(0, 0, self:getw(), self:geth())

				if not cc.rectContainsPoint(rect, cc.p(tmpIcon:getPosition())) then
					if filter == nil then
						local rect = self:getBoundingBox()
						data.x = rect.x + tmpIcon:getPositionX()
						data.y = rect.y + tmpIcon:getPositionY()

						if main_scene.ui.console:addWidgetByPanel(data, "diy") == "exist" then
							an.newMsgbox("控件已存在!", nil, {
								center = true
							})
						end
					end

					btn.show(btn):pos(x, y):scale(0.01):scaleTo(0.1, 1)
				else
					btn.show(btn):moveTo(0.1, x, y)
				end

				main_scene.ui.console:checkBtnAreaShow(nil, true)
				tmpIcon:removeSelf()

				tmpIcon = nil

				return 
			end
		}).pos(slot10, x, y):add2(scroll)

		if config.key == "btnSkillTemp" then
			btn.setName(btn, "diyPanel_" .. config._data.key)
		else
			btn.setName(btn, "diyPanel_" .. config.key)
		end

		if files.text then
			res.get2(files.text):pos(btn.getw(btn)/2, 10):add2(btn)
		end

		wNumCount = wNumCount + 1

		if iconLineNum <= wNumCount and hasNext then
			wNumCount = 0
			hCount = hCount + iconSpace
		end

		self.icons[data.key] = btn

		self:checkSelect(data.key)

		return 
	end

	local orders = {
		config.widget,
		config.base,
		config.skill,
		config.prop,
		config.panel
	}

	for i, v in ipairs(slot16) do
		addTitle(v.title)

		for i2, v2 in ipairs(v.icons) do
			if not v2.timeLimit then
				addIcon(v2, i2 < #v.icons)
			end
		end

		hCount = hCount + iconSpace
		wNumCount = 0
	end

	return 
end
diy.checkSelect = function (self, key, console)
	local btn = self.icons[key]

	if not btn then
		return 
	end

	if not btn.selectMark then
		btn.selectMark = res.get2("pic/common/selectMark.png"):anchor(1, 1):pos(btn.getw(btn) - 20, btn.geth(btn) + 20):add2(btn)
	end

	console = console or main_scene.ui.console

	btn.selectMark:setVisible(console.get(console, key) ~= nil)

	return 
end
diy.saveArchive = function (self, key)
	local listDatas = cache.getDiy(common.getPlayerName(), key)

	if listDatas then
		main_scene.ui.leftTopTip:show("不能与现有配置表重名", 6)

		return 
	end

	listDatas = cache.getDiy(common.getPlayerName(), "_list")
	listDatas = listDatas or {}

	if 7 <= #listDatas then
		main_scene.ui.leftTopTip:show("最多只能保存七个配置表", 6)

		return 
	end

	local timeValue = os.date("%Y-%m-%d")
	listDatas[#listDatas + 1] = {
		key,
		timeValue
	}

	cache.removeDiy(common.getPlayerName(), "_list")
	cache.saveDiy(common.getPlayerName(), "_list", listDatas)
	cache.removeDiy(common.getPlayerName(), key)
	main_scene.ui.console:saveEdit(key)
	main_scene.ui.leftTopTip:show("配置保存成功", 6)

	return 
end

return diy
