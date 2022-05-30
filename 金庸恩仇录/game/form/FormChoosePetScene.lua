local Item = class("Item", function ()
	return CCTableViewCell:new()
end)

function Item:getContentSize()
	return cc.size(display.width, 155)
end

function Item:ctor()
end

function Item:create(param)
	local _viewSize = param.viewSize
	local _listener = param.listener
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("formation/formation_hero_item.ccbi", proxy, self._rootnode)
	node:setPosition(_viewSize.width / 2, self._rootnode.itemBg:getContentSize().height / 2)
	self:addChild(node)
	self._rootnode.jobSprite:setVisible(false)
	self.petName = ui.newTTFLabelWithShadow({
	text = "",
	font = FONTS_NAME.font_haibao,
	size = 30,
	shadowColor = FONT_COLOR.BLACK
	})
	self._rootnode.itemNameLabel:addChild(self.petName)
	self.pzLabel = ui.newTTFLabelWithShadow({
	text = "",
	font = FONTS_NAME.font_haibao,
	size = 20,
	x = 0,
	y = self._rootnode.hjSprite:getContentSize().height / 2,
	align = ui.TEXT_ALIGN_CENTER,
	shadowColor = FONT_COLOR.BLACK
	})
	self._rootnode.hjSprite:addChild(self.pzLabel)
	self._rootnode.equipBtn:addHandleOfControlEvent(function (eventName, sender)
		self._rootnode.equipBtn:setEnabled(false)
		if _listener then
			_listener(self:getIdx())
		end
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
	end,
	CCControlEventTouchDown)
	self:refresh(param)
	return self
end

function Item:refreshLabel(itemData)
	self.petName:setString(itemData.baseData.name)
	self.petName:setColor(NAME_COLOR[itemData.data.star])
	self._rootnode.lvLabel:setString("LV." .. tostring(itemData.data.level))
	self._rootnode.clsLabel:setString("+" .. tostring(itemData.data.cls))
	self.petName:setPosition(self.petName:getContentSize().width / 2, 0)
	if itemData.data.cls > 0 then
		self._rootnode.clsLabel:setVisible(true)
	else
		self._rootnode.clsLabel:setVisible(false)
	end
	if 0 < itemData.data.cid then
		self._rootnode.wearAtHero:setVisible(true)
		local heroName = HeroModel.getHeroNameByResId(itemData.data.cid)
		self._rootnode.wearAtHero:setString(common:getLanguageString("@zhuangbeiyu") .. heroName)
	else
		self._rootnode.wearAtHero:setVisible(false)
	end
end

function Item:refresh(param)
	local _itemData = param.itemData
	for i = 1, 5 do
		if i <= _itemData.baseData.star then
			self._rootnode["star" .. tostring(i)]:setVisible(true)
		else
			self._rootnode["star" .. tostring(i)]:setVisible(false)
		end
	end
	ResMgr.refreshIcon({
	itemBg = self._rootnode.headIcon,
	id = _itemData.data.resId,
	resType = ResMgr.PET,
	cls = _itemData.data.cls
	})
	self.pzLabel:setString(common:getLanguageString("@Aptitudes", _itemData.baseData.arr_zizhi))
	self.pzLabel:setPositionX(10 + self.pzLabel:getContentSize().width / 2)
	self:refreshLabel(_itemData)
end

local BaseScene = require("game.BaseScene")
local FormChoosePetScene = class("FormChoosePetScene", BaseScene)

--[[
local FormChoosePetScene = class("FormChoosePetScene", function ()
	return require("game.BaseScene").new({
	contentFile = "public/window_content_scene.ccbi",
	subTopFile = "formation/formation_hero_sub_top.ccbi",
	bgImage = "ui_common/common_bg.png"
	})
end)
]]

local itemCellSize
function FormChoosePetScene:ctor(param)
	game.runningScene = self
	FormChoosePetScene.super.ctor(self, {
	contentFile = "public/window_content_scene.ccbi",
	subTopFile = "formation/formation_hero_sub_top.ccbi",
	bgImage = "ui_common/common_bg.png"
	})
	
	
	
	local _index = param.index or -1
	local _cid = param.cid or 0
	local _callback = param.callback
	local _closelistener = param.closelistener
	ResMgr.createBefTutoMask(self)
	if not itemCellSize then
		itemCellSize = Item.new():getContentSize()
	end
	local _sz = self._rootnode.listView:getContentSize()
	self._rootnode.backBtn:addHandleOfControlEvent(function (eventName, sender)
		self._rootnode.backBtn:setEnabled(false)
		pop_scene()
		if _closelistener then
			_closelistener()
		end
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
	end,
	CCControlEventTouchDown)
	local _data = {}
	local petList = PetModel.getPetTable()
	for i = 1, #petList do
		if petList[i].pos ~= _index then
			_data[#_data + 1] = {
			baseData = ResMgr.getPetData(petList[i].resId),
			data = petList[i]
			}
		end
	end
	local function getPos()
		if _index and _index > 0 then
			return tostring(_index)
		end
		return nil
	end
	local function onEquip(cellIdx)
		printf("========== hello")
		RequestHelper.formation.putOnPet({
		pos = getPos(),
		id = _data[cellIdx + 1].data._id,
		callback = function (data)
			PostNotice(NoticeKey.REMOVE_TUTOLAYER)
			if string.len(data["0"]) > 0 then
				CCMessageBox(data["0"], "Tip")
			else
				for k, pet in ipairs(petList) do
					if pet.pos == _index and pet.cid == _cid then
						pet.pos = 0
						pet.cid = 0
						break
					end
				end
				if _callback then
					_data[cellIdx + 1].data.pos = _index
					_data[cellIdx + 1].data.cid = _cid
					_callback(data)
				end
				pop_scene()
			end
		end
		})
	end
	self._scrollItemList = require("utility.TableViewExt").new({
	size = cc.size(_sz.width, _sz.height),
	direction = kCCScrollViewDirectionVertical,
	createFunc = function (idx)
		local item = Item.new()
		idx = idx + 1
		return item:create({
		viewSize = _sz,
		itemData = _data[idx],
		idx = idx,
		listener = onEquip
		})
	end,
	refreshFunc = function (cell, idx)
		idx = idx + 1
		cell:refresh({
		idx = idx,
		itemData = _data[idx]
		})
	end,
	cellNum = #_data,
	cellSize = itemCellSize
	})
	self._scrollItemList:setPosition(0, 0)
	self._rootnode.listView:addChild(self._scrollItemList)
	self._rootnode.select_hero:setString(common:getLanguageString("@SelectPet"))
	local cell = self._scrollItemList:cellAtIndex(0)
	if cell ~= nil then
		local btn = cell._rootnode.equipBtn
		TutoMgr.addBtn("zhenrong_btn_xuanzexiake_shangzhen", btn)
	end
	TutoMgr.active()
end

function FormChoosePetScene:onEnter()
	game.runningScene = self
	FormChoosePetScene.super.onEnter(self)
end

function FormChoosePetScene:onExit()
	FormChoosePetScene.super.onExit(self)
	TutoMgr.removeBtn("zhenrong_btn_xuanzexiake_shangzhen")
	TutoMgr.active()
end

return FormChoosePetScene