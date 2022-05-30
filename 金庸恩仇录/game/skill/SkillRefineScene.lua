local data_item_nature = require("data.data_item_nature")
local data_card_card = require("data.data_card_card")

local BaseScene = require("game.BaseScene")
local SkillRefineScene = class("SkillRefineScene", BaseScene)

local Item = class("Item", function()
	return CCTableViewCell:new()
end)

function Item:getContentSize()
	return cc.size(98, 91)
end

function Item:create(param)
	local _viewSize = param.viewSize
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("skill/skill_refine_icon.ccbi", proxy, self._rootnode)
	node:setPosition(node:getContentSize().width / 2, _viewSize.height / 2)
	self:addChild(node, 0)
	self:refresh(param)
	return self
end
function Item:refresh(param)
	local _itemData = param.itemData
	self._rootnode.numLabel:setString(string.format("%d/%d", _itemData.n1, _itemData.n2))
	if _itemData.n1 <= _itemData.n2 then
		self._rootnode.numLabel:setColor(cc.c3b(0, 255, 0))
	else
		self._rootnode.numLabel:setColor(cc.c3b(255, 0, 0))
	end
end

local RequestInfo = require("network.RequestInfo")

function SkillRefineScene:onEnter()
	SkillRefineScene.super.onEnter(self)
	PostNotice(NoticeKey.UNLOCK_BOTTOM)
end

function SkillRefineScene:ctor(param)
	SkillRefineScene.super.ctor(self, {
	contentFile = "skill/skill_refine_scene.ccbi",
	adjustSize = cc.size(8, 3)
	})
	
	self._info = param.info
	self._next = param.next
	self._objs = param.objs
	self._cost = param.cost
	self._bAllow = param.bAllow
	self._id = self._info._id
	self:setNodeEventEnabled(true)
	ResMgr.removeBefLayer()
	dump(param)
	if display.widthInPixels / display.heightInPixels > 0.67 then
		self._rootnode.infoNode:setScale(0.8)
		local posX, posY = self._rootnode.infoNode:getPosition()
		self._rootnode.infoNode:setPosition(posX + self._rootnode.infoNode:getContentSize().width * 0.1, posY)
	end
	
	self._rootnode.titleLabel:setString(common:getLanguageString("@wuxuejl"))
	self._rootnode.returnBtn:addHandleOfControlEvent(function()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		pop_scene()
	end,
	CCControlEventTouchDown)
	
	self._rootnode.jinglianBtn:addHandleOfControlEvent(function()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		if self._bAllow == 1 then
			local req = RequestInfo.new({
			modulename = "skill",
			funcname = "refine",
			param = {
			op = 2,
			id = self._id
			},
			oklistener = function(data)
				self._info = data["2"]
				self._bAllow = data["1"]
				self._next = {
				idx = data["3"],
				val = data["4"]
				}
				self._objs = data["5"]
				self._cost = data["6"]
				self:refresh()
			end
			})
			RequestHelperV2.request(req)
		else
			show_tip_label(common:getLanguageString("@suoxuwpbz"))
		end
	end,
	CCControlEventTouchDown)
	
	self._rootnode.card_bg:setDisplayFrame(display.newSprite("#item_card_bg_" .. self._info.star .. ".png"):getDisplayFrame())
	self:refresh()
end

function SkillRefineScene:refresh()
	local baseInfo = data_item_item[self._info.resId]
	self._rootnode.cardName:setString(baseInfo.name)
	self._rootnode.itemNameLabel:setString(baseInfo.name)
	local path = ResMgr.getLargeImage(baseInfo.bicon, ResMgr.EQUIP)
	self._rootnode.skillImage:setDisplayFrame(display.newSprite(path):getDisplayFrame())
	for i = 1, baseInfo.quality do
		self._rootnode[string.format("star%d", i)]:setVisible(true)
	end
	for k, v in ipairs(self._info.prop) do
		local nature = data_item_nature[v.idx]
		self._rootnode[string.format("propLabel_%d", k)]:setString(nature.nature .. "：")
		self._rootnode[string.format("propValueLabel_%d", k)]:setString(tostring(v.val))
	end
	for i = 1, 5 do
		if i == self._next.idx + 1 then
			self._rootnode["prevewValueLabel_" .. tostring(i)]:setString("+ " .. tostring(self._next.val))
		else
			self._rootnode["prevewValueLabel_" .. tostring(i)]:setString("")
		end
	end
	if self._iconList then
		self._iconList:removeFromParentAndCleanup(true)
	end
	self._iconList = require("utility.TableViewExt").new({
	size = self._rootnode.listView:getContentSize(),
	createFunc = function(idx)
		idx = idx + 1
		return Item.new():create({
		viewSize = self._rootnode.listView:getContentSize(),
		itemData = self._objs[idx]
		})
	end,
	refreshFunc = function(cell, idx)
		idx = idx + 1
		cell:refresh({
		itemData = self._objs[idx]
		})
	end,
	cellNum = #self._objs,
	cellSize = Item.new():getContentSize()
	})
	self._iconList:setPosition(0, 0)
	self._rootnode.listView:addChild(self._iconList)
	self._rootnode.costSilverLabel:setString(tostring(self._cost))
end

return SkillRefineScene