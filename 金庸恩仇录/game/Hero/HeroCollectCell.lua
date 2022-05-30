local data_field_field = require("data.data_field_field")
local data_battle_battle = require("data.data_battle_battle")
local data_world_world = require("data.data_world_world")

local HeroCollectCell = class("HeroCollectCell", function()
	return CCTableViewCell:new()
end)

function HeroCollectCell:getContentSize()
	return cc.size(display.width, 140)
end

function HeroCollectCell:refresh(id)
	self.lvlIndex = self.data[id]
	local name = data_battle_battle[self.lvlIndex].name
	local fieldName = data_field_field[data_battle_battle[self.lvlIndex].field].name
	self.fieldId = data_battle_battle[self.lvlIndex].field
	self.battleId = self.lvlIndex
	self.bigMapName = data_world_world[data_field_field[self.fieldId].world].name
	self.fubenName:setString("")
	self.submapName:setString(name)
	
	local bigMapTTF = ui.newTTFLabelWithShadow({
	text = self.bigMapName,
	size = 24,
	color = cc.c3b(255, 139, 45),
	shadowColor = FONT_COLOR.BLACK,
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_LEFT
	})
	
	
	ResMgr.replaceKeyLable(bigMapTTF, self.fubenName, 0, 0)
	bigMapTTF:align(display.LEFT_CENTER)
	
	local subMapTTF = ui.newTTFLabelWithShadow({
	text = fieldName,
	size = 24,
	color = cc.c3b(255, 208, 44),
	shadowColor = FONT_COLOR.BLACK,
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_LEFT
	})
	
	ResMgr.replaceKeyLable(subMapTTF, self.fubenName, bigMapTTF:getContentSize().width + 20, 0)
	subMapTTF:align(display.LEFT_CENTER)
	
	
	
	local maxFiledId = MapModel.subMap
	local maxSubId = MapModel.level
	if maxFiledId >= self.fieldId and maxSubId >= self.battleId then
		self.goto_btn:setEnabled(true)
	else
		self.goto_btn:setEnabled(false)
	end
end

function HeroCollectCell:toSubMap()
	GameStateManager:ChangeState(GAME_STATE.STATE_SUBMAP, {
	submapID = self.fieldId,
	subMap = self._subMap,
	battleId = self.battleId
	})
end

function HeroCollectCell:getLvlList()
	local bigMapID = data_field_field[data_battle_battle[self.lvlIndex].field].world
	dump("bigMapID" .. bigMapID)
	local function _callback(errorCode, mapData)
		if errorCode == "" then
			self._curLevel = {
			bigMap = MapModel.bigMap,
			subMap = MapModel.subMap,
			level = MapModel.level
			}
			self._subMap = mapData.subMapStar
			game.player.m_maxLevel = MapModel.level
			game.player:setBattleData({
			cur_bigMapId = MapModel.bigMap,
			cur_subMapId = MapModel.subMap,
			new_subMapId = MapModel.subMap
			})
			local soundName = ResMgr.getSound(data_world_world[bigMapID].bgm)
			GameAudio.playMusic(soundName, true)
			self:toSubMap()
		else
			CCMessageBox(errorCode, "server data error")
		end
	end
	MapModel:requestMapData(bigMapID, _callback)
end

function HeroCollectCell:create(param)
	local _id = param.id
	self.data = param.listData
	self.lvlData = param.lvlData
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("hero/hero_collect_cell.ccbi", proxy, self._rootnode)
	node:setPosition(0, self._rootnode.itemBg:getContentSize().height / 2)
	self:addChild(node)
	self.fubenName = self._rootnode.fuben_name
	self.submapName = self._rootnode.submap_name
	self.goto_btn = self._rootnode.goto_btn
	
	self.goto_btn:addHandleOfControlEvent(function(sender, eventName)
		self:getLvlList()
	end,
	CCControlEventTouchUpInside)
	
	self:refresh(_id + 1)
	return self
end

function HeroCollectCell:beTouched()
end

function HeroCollectCell:onExit()
end

function HeroCollectCell:runEnterAnim()
end

return HeroCollectCell