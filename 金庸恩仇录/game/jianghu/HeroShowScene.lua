local BaseScene = require("game.BaseSceneExt")
local HeroShowScene = class("HeroShowScene", BaseScene)

local HEROTYPE = {
HAOJIE = 1,
GAOSHO = 2,
XINXIU = 3
}

function HeroShowScene:ctor(param)
	HeroShowScene.super.ctor(self, {
	contentFile = "jianghulu/jianghulu_xiake_scene.ccbi",
	bottomFile = "jianghulu/jianghulu_xiake_bottom.ccbi",
	topFile = "jianghulu/jianghulu_xiake_top.ccbi"
	})
	
	self._listData = param.listData
	self._viewType = param.viewType or HEROTYPE.HAOJIE
	self._listener = param.listener
	local _stars = param.stars or 0
	local _bg = display.newSprite("ui_common/common_bg.png")
	local _bgW = display.width
	local _bgH = display.height - self._rootnode.bottomMenuNode:getContentSize().height - self._rootnode.topFrameNode:getContentSize().height
	_bg:setPosition(_bgW / 2, _bgH / 2 + self._rootnode.bottomMenuNode:getContentSize().height)
	_bg:setScaleX(_bgW / _bg:getContentSize().width)
	_bg:setScaleY(_bgH / _bg:getContentSize().height)
	self:addChild(_bg, 0)
	
	self._rootnode.backBtn:addHandleOfControlEvent(function()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		pop_scene()
	end,
	CCControlEventTouchUpInside)
	
	self._rootnode.allLoveLabel:setString(tostring(_stars))
	local function onTabBtn(tag)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_yeqian))
		self._viewType = tag
		self._scrollView:resetCellNum(#self._listData[self._viewType])
		local num = #self._listData[self._viewType]
		self._scrollView:setContentOffset(cc.p(0, self._rootnode.scrollListView:getContentSize().height - 17 - num * self._cellSize.height))
	end
	local showItem = require("game.jianghu.HeroShowItem").new()
	self._cellSize = showItem:getContentSize()
	self:refresh()
	
	CtrlBtnGroupAsMenu({
	self._rootnode.tab1,
	self._rootnode.tab2,
	self._rootnode.tab3
	}, onTabBtn, self._viewType)
	onTabBtn(self._viewType)
end

function HeroShowScene:refresh()
	self._scrollView = require("utility.TableViewExt").new({
	size = cc.size(self._rootnode.scrollListView:getContentSize().width, self._rootnode.scrollListView:getContentSize().height - 17),
	direction = kCCScrollViewDirectionVertical,
	createFunc = function(idx)
		idx = idx + 1
		local item = require("game.jianghu.HeroShowItem").new()
		return item:create({
		viewSize = self._rootnode.scrollListView:getContentSize(),
		idx = idx,
		itemData = self._listData[self._viewType][idx]
		})
	end,
	refreshFunc = function(cell, idx)
		idx = idx + 1
		cell:refresh({
		idx = idx,
		itemData = self._listData[self._viewType][idx]
		})
	end,
	cellNum = #self._listData[self._viewType],
	cellSize = self._cellSize,
	touchFunc = function(cell, x, y)
		local idx = cell:getIdx() + 1
		local pos = cell:convertToNodeSpace(cc.p(x, y))
		local sz = cell:getContentSize()
		local i = 0
		if pos.x > sz.width * 0.8 and pos.x < sz.width then
			i = 5
		elseif pos.x > sz.width * 0.6 then
			i = 4
		elseif pos.x > sz.width * 0.4 then
			i = 3
		elseif pos.x > sz.width * 0.2 then
			i = 2
		elseif 0 < pos.x then
			i = 1
		end
		if i >= 1 and i <= 5 and self._listData[self._viewType][idx] and self._listData[self._viewType][idx][i] and self._listener then
			self._listener(self._viewType, self._listData[self._viewType][idx][i].resId, {row = idx, col = i})
			pop_scene()
		end
	end
	})
	self._scrollView:setPosition(0, 10)
	self._rootnode.scrollListView:addChild(self._scrollView)
end

return HeroShowScene