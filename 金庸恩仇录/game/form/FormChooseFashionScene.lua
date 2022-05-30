local paramStrs = {
common:getLanguageString("@Physique"),
common:getLanguageString("@Strength"),
common:getLanguageString("@Comprehension"),
common:getLanguageString("@Life"),
common:getLanguageString("@Attack")
}
--local data_fashion_fashion = require("data.data_fashion_fashion")
local itemCellSize

local BaseScene = require("game.BaseScene")
local FormChooseFashionScene = class("FormChooseFashionScene", BaseScene)

function FormChooseFashionScene:ctor(param)
	game.runningScene = self
	FormChooseFashionScene.super.ctor(self, {
	contentFile = "public/window_content_scene.ccbi",
	subTopFile = "formation/formation_hero_sub_top.ccbi",
	bgImage = "ui_common/common_bg.png"
	})
	
	local _callback = param.callback
	ResMgr.createBefTutoMask(self)
	if not itemCellSize then
		itemCellSize = require("game.Equip.EquipV2.EquipSZListCellVTwo").new():getContentSize()
	end
	local _sz = self._rootnode.listView:getContentSize()
	self._rootnode.backBtn:addHandleOfControlEvent(function (eventName, sender)
		self._rootnode.backBtn:setEnabled(false)
		pop_scene()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
	end,
	CCControlEventTouchDown)
	
	local _data = {}
	local fashionList = FashionModel.getFashionList()
	self.wareFashionData = nil
	for i = 1, #fashionList do
		if fashionList[i].pos == 0 then
			_data[#_data + 1] = fashionList[i]
		else
			self.wareFashionData = fashionList[i]
		end
	end
	dump(_data)
	local getPos = function ()
		if _index and _index > 0 then
			return tostring(_index)
		end
		return nil
	end
	local function onEquip(idx)
		local fashionData = _data[idx]
		local equipType = 1
		if game.player:getFashionId() > 0 then
			equipType = 2
		end
		local function callbackFunc(data)
			local heroData = data
			pop_scene()
			_callback(data)
		end
		FashionModel.fashionInstall(1, fashionData._id, fashionData.resId, callbackFunc)
	end
	self._scrollItemList = require("utility.TableViewExt").new({
	size = cc.size(_sz.width, _sz.height),
	direction = kCCScrollViewDirectionVertical,
	createFunc = function (idx)
		local item = require("game.Equip.EquipV2.EquipSZListCellVTwo").new()
		idx = idx + 1
		return item:create({
		viewType = 2,
		data = _data[idx],
		idx = idx,
		callBack = onEquip
		})
	end,
	refreshFunc = function (cell, idx)
		idx = idx + 1
		cell:refresh({
		idx = idx,
		data = _data[idx]
		})
	end,
	cellNum = #_data,
	cellSize = itemCellSize
	})
	self._scrollItemList:setPosition(0, 0)
	self._rootnode.listView:addChild(self._scrollItemList)
	self._rootnode.select_hero:setString(common:getLanguageString("@SelectFashion"))
	TutoMgr.active()
end

function FormChooseFashionScene:onEnter()
	game.runningScene = self
	FormChooseFashionScene.super.onEnter(self)
end

function FormChooseFashionScene:onExit()
	FormChooseFashionScene.super.onExit(self)
end

return FormChooseFashionScene