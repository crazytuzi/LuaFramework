local equipGridPreview = class("equipGridPreview", import(".panelBase"))
local item = import("..common.item")
local barData = g_data.equipGrid
local W_LTBg = 332
local title = {
	"生效范围",
	"强化属性",
	"额外属性"
}
local listTitleCfg = {
	{
		str = {
			"装备级别",
			"生效范围"
		},
		rect = {
			{
				x = 0,
				w = W_LTBg/2
			},
			{
				x = W_LTBg/2,
				w = W_LTBg/2
			}
		}
	},
	{
		str = {
			"强化",
			"属性"
		},
		rect = {
			{
				x = 0,
				w = W_LTBg/2
			},
			{
				x = W_LTBg/2,
				w = W_LTBg/2
			}
		}
	},
	{
		str = {
			"强化",
			"格数",
			"额外属性"
		},
		rect = {
			{
				x = 0,
				w = W_LTBg/4
			},
			{
				x = W_LTBg/4,
				w = W_LTBg/4
			},
			{
				x = W_LTBg/2,
				w = W_LTBg/2
			}
		}
	}
}
local equipBarIdxs = {
	0,
	1,
	3,
	4,
	5,
	6,
	7,
	8,
	10,
	11
}
equipGridPreview.ctor = function (self, param)
	self.super.ctor(self)
	self.setMoveable(self, true)

	self.page = param.page or 1
	self.tabCallbacks = {}

	return 
end
equipGridPreview.onEnter = function (self)
	local tabstr = {}
	local tabcb = {}
	tabstr = {
		"范\n围",
		"属\n性",
		"额\n外"
	}
	tabcb = {
		self.loadRangePage,
		self.loadAttributePage,
		self.loadAdditionPage
	}
	self.tabCallbacks = tabcb

	self.initPanelUI(self, {
		title = "生效范围",
		bg = "pic/common/tabbg.png",
		tab = {
			default = 1,
			lableOffestX = -2,
			leftmargin = 414,
			topmargin = 40,
			fontsize = 18,
			strs = tabstr,
			file = {
				select = "pic/common/btn113.png",
				normal = "pic/common/btn112.png"
			}
		}
	})
	self.pos(self, display.cx - 102, display.cy)

	return 
end
equipGridPreview.clearContentNode = function (self)
	if self.contentNode then
		self.contentNode:removeAllChildren()
	end

	self.contentNode = display.newNode():addTo(self.bg)
	self.contentNode.controls = {}
	self.contentNode.data = {}

	return 
end
equipGridPreview.onTabClick = function (self, idx, btn)
	self.clearContentNode(self)

	self.curTab = self.tabCallbacks[idx]
	self.curIdx = idx

	self.setTitle(self, title[idx])
	self.tabCallbacks[idx](self)

	return 
end
equipGridPreview.loadListView = function (self, idx, data, listViewRect, cellH)
	if not data then
		return 
	end

	local activeNode = display.newScale9Sprite(res.getframe2("pic/common/black_5.png")):anchor(0, 0):pos(15, 15):size(358, 400):addTo(self.contentNode)
	local rollbg = display.newScale9Sprite(res.getframe2("pic/scale/scale9.png"), 350, 14, cc.size(20, 400)):addTo(self.contentNode):anchor(0, 0)
	local rollCeil = res.get2("pic/common/scrollShow.png"):anchor(0.5, 0):pos(rollbg.getw(rollbg)*0.5, rollbg.geth(rollbg) - 42):add2(rollbg)
	local pageList = self.newListView(self, listViewRect.x, listViewRect.y, listViewRect.w, listViewRect.h, 2, {}):add2(activeNode)
	self.scrollHeight = 0
	self.contentNode.controls.pageList = pageList
	self.contentNode.controls.activeNode = activeNode

	pageList.setListenner(pageList, function (event)
		if event.name == "moved" then
			local x, y = pageList:getScrollOffset()
			local scrollHeight = self.scrollHeight
			local maxOffset = scrollHeight - listViewRect.h

			if y < 0 then
				y = 0
			end

			if maxOffset < y then
				y = maxOffset or y
			end

			local s = (rollbg:geth() - 42)*(y/maxOffset - 1)

			rollCeil:setPositionY(s)
		end

		return 
	end)

	local splitImg = "pic/panels/equipGrid/split.png"
	local titlebg = display.newScale9Sprite(res.getframe2("pic/panels/equipGrid/titlebg.png"), 0, 0, cc.size(W_LTBg, 40)).anchor(slot10, 0, 0):pos(2, activeNode.geth(activeNode) - 40):add2(activeNode)
	local titleStr = listTitleCfg[idx].str
	local titleRect = listTitleCfg[idx].rect

	for k, v in pairs(titleStr) do
		local x = titleRect[k].x
		local w = titleRect[k].w

		display.newScale9Sprite(res.getframe2(splitImg), 0, 0, cc.size(4, 40)):anchor(0, 0):pos(x, 0):add2(titlebg)
		an.newLabel(v, 20, 1, {
			color = cc.c3b(220, 210, 190)
		}):anchor(0.5, 0.5):pos(x + w/2, 20):add2(titlebg)
	end

	local cellBg = {
		"pic/scale/scale18.png",
		"pic/scale/scale19.png"
	}

	for k, v in pairs(data) do
		local cell = display.newScale9Sprite(res.getframe2(cellBg[k%2 + 1]), 0, 0, cc.size(W_LTBg, cellH))
		local cfgRect = listTitleCfg[idx].rect

		for k1, v1 in pairs(v) do
			local x = cfgRect[k1].x
			local w = cfgRect[k1].w

			an.newLabel(v1, 20, 1, {
				color = cc.c3b(220, 210, 190)
			}):anchor(0.5, 0.5):pos(x + w/2, cellH/2):add2(cell)
		end

		self.listViewPushBack(self, pageList, cell)

		self.scrollHeight = self.scrollHeight + cell.geth(cell) + 4
	end

	return 
end
equipGridPreview.loadRangePage = function (self)
	local data = barData:getEquipLvlToRange()
	local listViewRect = {
		h = 360,
		x = 2,
		y = 2,
		w = W_LTBg
	}

	self.loadListView(self, 1, data, listViewRect, 40)

	return 
end
equipGridPreview.loadAttributePage = function (self, selIdx)
	local listViewRect = {
		h = 320,
		x = 2,
		y = 42,
		w = W_LTBg
	}
	selIdx = selIdx or 1
	local idx = equipBarIdxs[selIdx]
	local data = barData:getEquipGridToAttr(idx)

	self.loadListView(self, 2, data, listViewRect, 80)

	local activeNode = self.contentNode.controls.activeNode
	local selectbg = display.newScale9Sprite(res.getframe2("pic/panels/equipGrid/titlebg.png"), 0, 0, cc.size(W_LTBg - 1, 40)):anchor(0, 0):pos(3, 2):add2(activeNode)

	display.newScale9Sprite(res.getframe2("pic/common/scrollBg5.png"), 0, 0, cc.size(120, 36)):anchor(0.5, 0.5):pos(selectbg.getw(selectbg)/2, selectbg.geth(selectbg)/2):addto(selectbg)
	display.newScale9Sprite(res.getframe2("pic/scale/scale19.png"), 0, 0, cc.size(100, 30)):anchor(0.5, 0.5):pos(selectbg.getw(selectbg)/2, selectbg.geth(selectbg)/2):add2(selectbg)

	local gridLabel = an.newLabel(barData:getCfgName(idx), 20, 1, {
		color = cc.c3b(220, 210, 190)
	}):anchor(0.5, 0.5):pos(selectbg.getw(selectbg)/2, selectbg.geth(selectbg)/2):add2(selectbg)
	local selLeft = display.newSprite(res.getframe2("pic/panels/equipGrid/_.png")):anchor(0, 0.5):pos(78, selectbg.geth(selectbg)/2):addto(selectbg)
	local selRight = display.newSprite(res.getframe2("pic/panels/equipGrid/_.png")):anchor(0, 0.5):pos(255, selectbg.geth(selectbg)/2):addto(selectbg)

	selRight.setRotation(selRight, 180)
	selLeft.setTouchEnabled(selLeft, true)
	selLeft.addNodeEventListener(selLeft, cc.NODE_TOUCH_EVENT, function (event)
		if event.name == "began" and 1 < selIdx then
			selIdx = selIdx - 1

			self:clearContentNode()
			self:loadAttributePage(selIdx)
		end

		return 
	end)
	selRight.setTouchEnabled(slot9, true)
	selRight.addNodeEventListener(selRight, cc.NODE_TOUCH_EVENT, function (event)
		if event.name == "began" and selIdx < #equipBarIdxs then
			selIdx = selIdx + 1

			self:clearContentNode()
			self:loadAttributePage(selIdx)
		end

		return 
	end)

	return 
end
equipGridPreview.loadAdditionPage = function (self)
	local data = barData:getAdditionAttr()
	local listViewRect = {
		h = 360,
		x = 2,
		y = 2,
		w = W_LTBg
	}

	self.loadListView(self, 3, data, listViewRect, 40)

	return 
end

return equipGridPreview
