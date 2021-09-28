local messageBox = class("messageBox")

table.merge(messageBox, {
	panel,
	view,
	viewSize = {
		w = 370,
		h = 165
	}
})

messageBox.messageBox = function (self, titlePng, btnList, callback, params)
	params = params or {}
	local scene = cc.Director:getInstance():getRunningScene()
	local panel = display.newSprite(res.gettex2("pic/common/msgbox.png")):add2(scene, 999):center()

	panel.enableClick(panel, function ()
		return 
	end, {
		support = "drag"
	})

	local view = an.newScroll(4, 4, self.viewSize.w, self.viewSize.h).anchor(slot7, 0, 1):add2(panel):pos(26, 231)
	local title = display.newSprite(res.gettex2(titlePng)):add2(panel)

	title.pos(title, panel.getw(panel)/2, panel.geth(panel) - title.geth(title)/2 - 5)

	local co = coroutine.running()

	local function onBtn(v)
		sound.playSound("103")

		if v.cb then
			v.cb()
		elseif callback then
			callback(v)
		elseif co then
			coroutine.resume(co, v.evt)
		end

		panel:removeSelf()

		return 
	end

	local btnInterval = params.btnInterval or 20
	local btnBase = display.newNode().add2(slot12, panel):anchor(0.5, 0.5):pos(panel.getw(panel)/2, 20)
	local listWidth = 0
	slot14 = ipairs
	slot15 = btnList or {
		{
			evt = "ok",
			title = "确 定"
		},
		{
			evt = "cancel",
			title = "取 消"
		}
	}

	for k, v in slot14(slot15) do
		local pressImage = (v.image and v.press) or "pic/common/btn21.png"
		local btn = an.newBtn(res.gettex2(v.image or "pic/common/btn20.png"), handler(v, onBtn), {
			pressImage = res.gettex2(pressImage),
			label = {
				v.title,
				18,
				1,
				{
					color = def.colors.btn30
				}
			}
		}):add2(btnBase):anchor(0, 0):pos(listWidth + btnInterval/2, 0)
		listWidth = listWidth + btn.getw(btn) + btnInterval
		v.idx = k
	end

	btnBase.setContentSize(btnBase, listWidth, 20)

	if params.popStyle then
		common.enablePopStyle(panel)
	end

	self.panel = panel
	self.view = view

	return panel, view
end
messageBox.enableScroll = function (self, enable)
	self.view:enableTouch(false)

	return 
end
messageBox.confirm = function (titlePng, text, btnList, callback, params)
	params = params or {}
	local msgbox = messageBox.new()
	local panel, view = msgbox.messageBox(msgbox, titlePng, btnList, callback, params)
	local content = nil

	if params.center then
		content = an.newLabel(text, params.fontSize or 18, 1, {
			color = cc.c3b(228, 219, 193)
		}):pos(0, msgbox.viewSize.h):add2(view):anchor(0.5, 0.5):debug()

		content.pos(content, msgbox.viewSize.w/2, msgbox.viewSize.h/2)
	else
		content = an.newLabelM(msgbox.viewSize.w, params.fontSize or 18, 1):pos(0, msgbox.viewSize.h):add2(view):anchor(0, 1):addLabel(text, cc.c3b(228, 219, 193))

		if content.geth(content) < 160 then
			msgbox.enableScroll(msgbox, false)
		end
	end

	local co = coroutine.running()

	if co and not callback then
		return coroutine.yield("messageBox")
	end

	return panel, view
end
messageBox.prompt = function (titlePng, placeholder, btnList, callback, params)
	params = params or {}
	local msgbox = messageBox.new()
	local input = nil
	local co = coroutine.running()
	local panel, view = msgbox.messageBox(msgbox, titlePng, btnList, function (event)
		if callback then
			callback(event, input:getString())
		elseif co then
			coroutine.resume(co, event.evt, input:getString())
		end

		return 
	end, slot4)

	msgbox.enableScroll(msgbox, false)

	local base = display.newScale9Sprite(res.getframe2("pic/scale/edit.png"), 0, 0, cc.size(view.getw(view) - 20, 40)):anchor(0.5, 0.5):pos(msgbox.viewSize.w/2, msgbox.viewSize.h/2 + 10):add2(view, 2)
	input = an.newInput(10, base.geth(base)/2, view.getw(view) - 40, 40, params.max, {
		label = {
			"",
			20
		},
		tip = {
			placeholder or "",
			20,
			1
		},
		checkCLen = params.max
	}):addTo(base):anchor(0, 0.5)

	if params.tip then
		an.newLabel(params.tip, params.fontSize or 18, 1, {
			color = cc.c3b(228, 219, 193)
		}):pos(-10, 50):anchor(0, 0):add2(input)
	end

	if co and not callback then
		return coroutine.yield("messageBox")
	end

	return panel, view
end
messageBox.test = function ()
	local i = 1
	local testList = {}

	function nextTest()
		if testList[i] then
			testList[i]()

			i = i + 1
		end

		return 
	end

	local function testWithCoroutine()
		local function test()
			print(messageBox.confirm("pic/panels/friend/add.PNG", "基于协程实现的messagebox，当前线程是协程的情况下，直到按钮列表被触发时返回", {
				{
					evt = "应当在按下返回按钮后,在控制台看到这个文本",
					title = "点击返回"
				}
			}))
			print(messageBox.prompt("pic/panels/friend/add.PNG", "测试输入", {
				{
					evt = "应当在按下返回按钮后,在控制台看到这个文本,以及你输入的内容",
					title = "点击返回"
				}
			}))
			nextTest()

			return 
		end

		local co = coroutine.create(function ()
			print(xpcall(test, __G__TRACKBACK__))

			return 
		end)

		coroutine.resume(slot1)

		return 
	end

	table.insert(slot1, testWithCoroutine)

	local function btnCB(btnData)
		print(btnData.evt)
		nextTest()

		return 
	end

	local function testScroll()
		print(messageBox.confirm("pic/panels/friend/add.PNG", [[
测试自动滚动===\n
			巴拉巴拉巴拉快乐圣诞节疯狂就类似的恢复高考加
			对方会尽快收到回复即可收到回复即可收到后房价快速
			的恢复健康是的话拉巴拉巴拉拉巴拉阿拉巴拉拉比拉力赛
			的法律会计师的罚款了坚实的快乐分手的房价快速贷款结
			尾我开了房间为科技凤凰网科技而恢复客户看完就二婚中文
			中文中文中文中文中文中文中文中文中文中文中文中文中文
			中文中文中文中文中文中文中文中文中文中文中文中文中文中文]], nil, btnCB))

		return 
	end

	table.insert(slot1, testScroll)

	local function testCenterAlign()
		print(messageBox.confirm("pic/panels/friend/add.PNG", "测试居中", nil, btnCB, {
			center = true,
			fontSize = 25
		}))

		return 
	end

	table.insert(slot1, testCenterAlign)

	local function testBtnList()
		print(messageBox.confirm("pic/panels/friend/add.PNG", "测试按钮列表", {
			{
				evt = "btn1",
				title = "按钮1"
			},
			{
				evt = "btn2",
				title = "按钮2"
			},
			{
				evt = "btn3",
				title = "按钮3"
			}
		}, btnCB, {
			center = true
		}))

		return 
	end

	table.insert(slot1, testBtnList)

	local function testBtnInterval()
		print(messageBox.confirm("pic/panels/friend/add.PNG", "测试按钮间隙,间隔0", {
			{
				evt = "btn1",
				title = "按钮1"
			},
			{
				evt = "btn2",
				title = "按钮2"
			}
		}, btnCB, {
			btnInterval = 0
		}))

		return 
	end

	table.insert(slot1, testBtnInterval)

	local function testBtnInterval2()
		print(messageBox.confirm("pic/panels/friend/add.PNG", "测试按钮间隙,间隔100", {
			{
				evt = "btn1",
				title = "按钮1"
			},
			{
				evt = "btn2",
				title = "按钮2"
			}
		}, btnCB, {
			btnInterval = 100
		}))

		return 
	end

	table.insert(slot1, testBtnInterval2)

	messageBox = import(".messageBox")

	nextTest()

	return 
end

return messageBox
