local quickTest = class("quickTest", import(".panelBase"))
quickTest.ctor = function (self, params)
	self.super.ctor(self)
	self.setMoveable(self, true)

	self.params = params or {}

	return 
end
quickTest.onEnter = function (self)
	self.initPanelUI(self, {
		title = "GM面板",
		bg = "pic/common/black_2.png"
	})
	self.pos(self, display.left, display.cy)
	self.anchor(self, 0, 0.5)
	self.clearContentNode(self)
	self.loadTestUI(self)

	return 
end
quickTest.onCloseWindow = function (self)
	return self.super.onCloseWindow(self)
end
quickTest.clearContentNode = function (self)
	if self.contentNode then
		self.contentNode:removeSelf()
	end

	self.contentNode = display.newNode():addTo(self.bg)
	self.contentNode.controls = {}
	self.contentNode.data = {}

	return 
end
quickTest.loadTestUI = function (self)
	display.newScale9Sprite(res.getframe2("pic/common/black_5.png")):anchor(0, 0):pos(12, 13):size(160, 393):addTo(self.contentNode)
	display.newScale9Sprite(res.getframe2("pic/common/black_5.png")):anchor(0, 0):pos(175, 13):size(455, 393):addTo(self.contentNode)

	local leftScroll = self.newListView(self, 12, 16, 160, 387, 4, {}):add2(self.contentNode)
	self.contentNode.controls.rightScroll = self.newListView(self, 175, 16, 455, 387, 4, {}):add2(self.contentNode)
	local leftItemName = {
		"一键GM",
		"复杂GM",
		"客户端测试"
	}
	local leftItemCb = {
		self.loadOneKeyTest,
		self.loadPutWordTest,
		self.loadLocalTest
	}

	local function onItemSelect(btn)
		for k, v in ipairs(self.contentNode.controls.leftItems) do
			v.unselect(v)
			v.setTouchEnabled(v, true)
		end

		btn.select(btn)
		btn.setTouchEnabled(btn, false)

		if leftItemCb[btn.key] then
			leftItemCb[btn.key](self)
		end

		return 
	end

	self.contentNode.controls.leftItems = {}

	for i, v in ipairs(slot2) do
		local item = an.newBtn(res.gettex2("pic/panels/picIdentify/equipTypeUnselect.png"), function (btn)
			sound.playSound("103")
			onItemSelect(btn)

			return 
		end, {
			support = "scroll",
			select = {
				res.gettex2("pic/panels/picIdentify/equipTypeSelect.png")
			},
			label = {
				v,
				20,
				0,
				{
					color = def.colors.Cf0c896
				}
			}
		})
		item.key = i

		table.insert(self.contentNode.controls.leftItems, slot10)
		self.listViewPushBack(self, leftScroll, item, {
			left = 5
		})
	end

	onItemSelect(self.contentNode.controls.leftItems[1])

	return 
end
quickTest.loadRightBtns = function (self, testData)
	local rightScroll = self.contentNode.controls.rightScroll

	if not rightScroll then
		return 
	end

	rightScroll.removeAllChildren(rightScroll)
	rightScroll.setScrollOffset(rightScroll, 0, 0)

	local num = 0
	local posX = 0
	local posY = 380

	for k, v in ipairs(testData) do
		local btnName = v.name or ""
		local content = v.content or ""

		an.newBtn(res.gettex2("pic/common/btn20.png"), function (btn)
			sound.playSound("103")

			if type(content) == "string" then
				common.say(content)
			elseif type(content) == "function" then
				content()
			end

			return 
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			label = {
				btnName,
				16,
				0,
				{
					color = def.colors.Cf0c896
				}
			}
		}).add2(slot13, rightScroll):anchor(0, 1):pos(num%4*110 + 15, posY)

		num = num + 1

		if num%4 == 0 then
			posY = posY - 50
		end
	end

	return 
end
quickTest.loadOneKeyTest = function (self)
	local test = {
		{
			content = "@cxy",
			name = "程序员"
		},
		{
			content = "@nodieset",
			name = "无敌"
		},
		{
			content = "@power",
			name = "一击必杀"
		},
		{
			content = "@monclear",
			name = "清怪"
		},
		{
			content = "@delselfitem all",
			name = "清背包"
		},
		{
			name = "金币加满",
			content = function ()
				local jbNum = g_data.player.gold - 50000000

				common.say("@addjb " .. jbNum)

				return 
			end
		},
		{
			name = "开服天数",
			content = function ()
				common.say("开服天数：" .. g_data.client.openDay .. "天")

				return 
			end
		},
		{
			name = "服务器阶段",
			content = function ()
				common.say("服务器阶段：" .. g_data.client.serverState)

				return 
			end
		},
		{
			name = "PK值",
			content = function ()
				common.say("PK值：" .. g_data.player.ability.FPkValue)

				return 
			end
		}
	}

	self.loadRightBtns(slot0, test)

	return 
end
quickTest.loadLocalTest = function (self)
	local test = {}

	local function addTest(name, content)
		test[#test + 1] = {
			name = name,
			content = content
		}

		return 
	end

	slot2("微端下载", function ()
		if main_scene and main_scene.ui then
			main_scene.ui:togglePanel("miniResDownload")
		end

		return 
	end)
	slot2("截图", function ()
		if main_scene and main_scene.ui then
			if m2debug.node and m2debug.node.content then
				m2debug.node.content:removeSelf()

				m2debug.node.content = nil
			end

			self:hide()
			main_scene.ui:togglePanel("screenshot", main_scene)
		end

		return 
	end)
	slot2("5v5训练赛", function ()
		main_scene.ui:togglePanel("teamCompetition", {
			page = 1
		})

		return 
	end)
	slot2("5v5锦标赛", function ()
		main_scene.ui:togglePanel("teamCompetition", {
			page = 2
		})

		return 
	end)
	slot2("勋章铭刻", function ()
		main_scene.ui:togglePanel("medalImpress")

		return 
	end)
	self.loadRightBtns(slot0, test)

	return 
end
quickTest.pvpTest = function (self)
	local FAList = {
		{
			Fuserlifeleft = 2,
			Fusername = "名字最多七个字",
			Fuserdie = false,
			Fuserjob = 0
		},
		{
			Fuserlifeleft = 0,
			Fusername = "名字最多七个",
			Fuserdie = true,
			Fuserjob = 2
		},
		{
			Fuserlifeleft = 2,
			Fusername = "名字最多七",
			Fuserdie = false,
			Fuserjob = 2
		},
		{
			Fuserlifeleft = 1,
			Fusername = "名字最多",
			Fuserdie = false,
			Fuserjob = 1
		},
		{
			Fuserlifeleft = 2,
			Fusername = "名字最",
			Fuserdie = false,
			Fuserjob = 0
		}
	}
	local FBList = {
		{
			Fuserlifeleft = 2,
			Fusername = "名字最多七个字",
			Fuserdie = false,
			Fuserjob = 1
		},
		{
			Fuserlifeleft = 2,
			Fusername = "名字最多七个",
			Fuserdie = false,
			Fuserjob = 1
		},
		{
			Fuserlifeleft = 1,
			Fusername = "名字最多七",
			Fuserdie = false,
			Fuserjob = 0
		},
		{
			Fuserlifeleft = 2,
			Fusername = "名字最多",
			Fuserdie = false,
			Fuserjob = 0
		},
		{
			Fuserlifeleft = 0,
			Fusername = "名字最",
			Fuserdie = true,
			Fuserjob = 2
		}
	}

	main_scene.ui.leftTopTip:showPVP(FAList, FBList, false)

	return 
end
quickTest.loadPutWordTest = function (self)
	local rightScroll = self.contentNode.controls.rightScroll

	if not rightScroll then
		return 
	end

	rightScroll.removeAllChildren(rightScroll)
	rightScroll.setScrollOffset(rightScroll, 0, 0)

	local testCommond = g_data.testCommond:get()
	self.testCommondInputs = {}
	local posX = 0
	local posY = 380

	for i = 1, #testCommond + 5, 1 do
		local input = cc.ui.UIInput.new({
			image = "pic/panels/bigmap/input.png",
			UIInputType = 1,
			size = cc.size(300, 30),
			listener = function (type)
				if type == "return" then
					local commondText = {}

					for k, v in ipairs(self.testCommondInputs) do
						if v.getText(v) and v.getText(v) ~= "" then
							commondText[#commondText + 1] = v.getText(v)
						end
					end

					g_data.testCommond:set(commondText)
				end

				return 
			end
		}).anchor(slot9, 0, 1):pos(20, posY):addto(rightScroll)

		if testCommond[i] then
			input.setText(input, testCommond[i] or "")
		end

		self.testCommondInputs[#self.testCommondInputs + 1] = input

		an.newBtn(res.gettex2("pic/common/btn20.png"), function (btn)
			sound.playSound("103")
			common.say(input:getText() or "")

			return 
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			label = {
				"Go !",
				16,
				0,
				{
					color = def.colors.Cf0c896
				}
			}
		}).add2(slot10, rightScroll):anchor(0, 1):pos(input.getw(input) + 30, posY + 5)

		posY = posY - 50
	end

	return 
end

return quickTest
