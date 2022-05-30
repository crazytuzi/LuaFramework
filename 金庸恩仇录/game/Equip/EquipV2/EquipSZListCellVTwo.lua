local data_fashion_fashion = require("data.data_fashion_fashion")
local data_item_item = require("data.data_item_item")

local EquipSZListCellVTwo = class("EquipSZListCellVTwo", function(param)
	return CCTableViewCell:new()
end)

local List_VIEW = 1
local Form_VIEW = 2

local paramStrs = {
common:getLanguageString("@Physique"),
common:getLanguageString("@Strength"),
common:getLanguageString("@Comprehension"),
common:getLanguageString("@Life"),
common:getLanguageString("@Attack")
}

function EquipSZListCellVTwo:getContentSize()
	return cc.size(display.width, 154)
end

function EquipSZListCellVTwo:create(param)
	local proxy = CCBProxy:create()
	self._rootnode = {}
	self.viewType = param.viewType
	local node = CCBuilderReaderLoad("equip/equip_list_shizhuang_item.ccbi", proxy, self._rootnode)
	node:setPosition(display.width * 0.5, self._rootnode.itemBg:getContentSize().height / 2)
	self:addChild(node)
	
	self.shiZhuangName = ui.newTTFLabelWithShadow({
	text = "",
	font = FONTS_NAME.font_fzcy,
	size = 24,
	color = FONT_COLOR.WHITE,
	shadowColor = FONT_COLOR.BLACK,
	})
	self.shiZhuangTime = ui.newTTFLabel({
	text = "",
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_LEFT,
	size = 22,
	color = cc.c3b(77, 77, 77)
	})
	
	ResMgr.replaceKeyLable(self.shiZhuangName, self._rootnode.kongfuName, 0, 0)
	self.shiZhuangName:align(display.LEFT_CENTER)
	
	ResMgr.replaceKeyLable(self.shiZhuangTime, self._rootnode.kongfuName, 0, 0)
	self.shiZhuangTime:align(display.LEFT_CENTER)
	
	self.timeNode = display.newNode()
	self:addChild(self.timeNode)
	
	if self.viewType == Form_VIEW then
		resetctrbtnString(self._rootnode.checkBtn, common:getLanguageString("@Equit"))
	end
	
	local _callBack = param.callBack
	self:refresh(param)
	
	ResMgr.setControlBtnEvent(self._rootnode.checkBtn, function()
		local data = self.param.data
		if data.lastOverTime > -1 and data.endTime <= 0 then
			show_tip_label(common:getLanguageString("@sz_timeout"))
			return
		end
		if _callBack then
			_callBack(self.param.idx)
		end
	end)
	return self
end

function EquipSZListCellVTwo:refresh(param)
	self.param = param
	local idx = param.idx
	local data = param.data
	data.lastOverTime = -1
	local staticdata = data_item_item[data.resId]
	for k, v in ipairs(paramStrs) do
		self._rootnode["stateValue" .. k]:setString(paramStrs[k] ..(staticdata.arr_value[k] + staticdata.arr_addition[k] * data.level))
		--dump(data.props)
		--self._rootnode["stateValue" .. k]:setString(paramStrs[k] .. staticdata.arr_value[k])
	end
	self.shiZhuangName:setString(staticdata.name)
	self.shiZhuangName:setColor(NAME_COLOR[staticdata.quality])
	if data.pos == 0 then
		self._rootnode.equipSZState:setVisible(false)
	else
		self._rootnode.equipSZState:setVisible(true)
	end
	self._rootnode.lvNum:setString("LV." .. data.level)
	self._rootnode.starNumSprite:setDisplayFrame(display.newSpriteFrame(string.format("item_board_num_%d.png", staticdata.quality)))
	
	--[[
	ResMgr.refreshIcon({
	itemBg = self._rootnode.headIcon,
	id = data.fashionId,
	resType = ResMgr.FASHION
	})
	]]
	ResMgr.refreshIcon({
	itemBg = self._rootnode.headIcon,
	id = data.resId,
	resType = ResMgr.EQUIP,
	})
	
	if self.viewType == List_VIEW then
		if staticdata.lvlup == 1 then
			self._rootnode.checkBtn:setVisible(true)
		else
			self._rootnode.checkBtn:setVisible(false)
		end
	end
	self:refreshTimeLabel()
end

function EquipSZListCellVTwo:refreshTimeLabel()
	self.timeNode:stopAllActions()
	local data = self.param.data
	local function update(dt)
		data.endTime = data.endTime - 1
		if data.endTime <= 0 then
			self.shiZhuangTime:setString(common:getLanguageString("@sz_timeout"))
			self.timeNode:stopAllActions()
		else
			dump(data.endTime, "endTime is: ")
			local times = format_time(data.endTime)
			local label = "(" .. common:getLanguageString("@LeftTime") .. ":" .. times .. ")"
			self.shiZhuangTime:setString(label)
		end
	end
	if data.lastOverTime == -1 then
		self.shiZhuangTime:setVisible(false)
		return
	else
		self.shiZhuangTime:setVisible(true)
		self.shiZhuangTime:setPositionX(self.shiZhuangName.getPositionX() + self.shiZhuangName:getContentSize().width)
		data.endTime = GameModel.getRestTimeInSec(data.lastOverTime) + 1
		update()
		self.timeNode:schedule(update, 1)
	end
end

function EquipSZListCellVTwo:createFashionInfoLayer()
	local fashionInfo = self.param.data
	local layer = require("game.shizhuang.FashionInfoLayer").new({
	info = fashionInfo,
	changeListener = function()
		self:refresh(self.param)
	end,
	removeListener = function(hasChange)
	end
	}, 2)
	game.runningScene:addChild(layer, 10)
end

function EquipSZListCellVTwo:tableCellTouched(x, y)
	if self.viewType ~= Form_VIEW then
		local icon = self._rootnode.head_touch_node
		local bound = icon:getContentSize()
		if cc.rectContainsPoint(cc.rect(0,0, bound.width, bound.height), icon:convertToNodeSpace(cc.p(x, y))) then
			GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
			self:createFashionInfoLayer()
		end
	end
end

return EquipSZListCellVTwo