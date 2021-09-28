-------------------------------------------------------
module(..., package.seeall)

local require = require;
require("ui/ui_funcs")
local ui = require("ui/base");

-------------------------------------------------------
wnd_demonhole_dialogue = i3k_class("wnd_demonhole_dialogue", ui.wnd_base)

local LAYER_DB7T = "ui/widgets/db7t"

function wnd_demonhole_dialogue:ctor()
	self._needKey = 0
end

function wnd_demonhole_dialogue:configure()
	local widgets = self._layout.vars
	
	self.dialogue = widgets.dialogue
	self.npcName = widgets.npcName
	self.keyNum = widgets.keyNum
	self.npcmodule = widgets.npcmodule
	
	self.nextBtn = widgets.nextBtn
	self.upBtn = widgets.upBtn
	self.functionBtn = widgets.functionBtn
	self.itemDesc = widgets.itemDesc
	self.itemScroll = widgets.itemScroll
	
	self.nextBtn:onClick(self, self.onNextFloor)
	self.upBtn:onClick(self, self.onUpFloor)
	widgets.close_btn:onClick(self, self.onCloseUI)
	widgets.closebtn:onClick(self, self.onCloseUI)
end

function wnd_demonhole_dialogue:refresh(npcId)
	self:updateData(npcId)
end

function wnd_demonhole_dialogue:updateData(npcId)
	local data = i3k_db_npc[npcId]
	local _id = data.monsterID
	local _data = i3k_db_monsters[_id]
	local modelId = _data.modelID
	ui_set_hero_model(self.npcmodule, modelId)
	self.npcName:setText(data.remarkName)
	self.dialogue:setText(data.desc0)

	self.functionBtn:onClick(self, self.onFunction,data.exchangeId[1])

	local curFloor, grade = g_i3k_game_context:GetDemonHoleFloorGrade()
	local dbCfg = i3k_db_demonhole_fb[grade]
	if curFloor >= #dbCfg then
		self.nextBtn:disableWithChildren()
		self.dialogue:hide()
		self.keyNum:hide()
	elseif curFloor == 1 then
		self.upBtn:disableWithChildren()
	end
	if curFloor < #dbCfg then
		self._needKey = dbCfg[curFloor+1].needKeyNum
		local havaKeyNum = g_i3k_game_context:GetCommonItemCanUseCount(i3k_db_demonhole_base.keyId)
		local str = string.format("当前：%s/%s", havaKeyNum, self._needKey)
		self.keyNum:setText(str)
		self.keyNum:setTextColor(g_i3k_get_cond_color(havaKeyNum >= self._needKey))
	end
	
	self:loadItemScorll()
end

function wnd_demonhole_dialogue:loadItemScorll()
	self.itemScroll:removeAllChildren()
	local curFloor, grade = g_i3k_game_context:GetDemonHoleFloorGrade()
	local dbCfg = i3k_db_demonhole_fb[grade]
	local cfg = {}
	if curFloor < #dbCfg then
		cfg = dbCfg[curFloor +1]
	else
		self.itemScroll:hide()
		self.itemDesc:hide()
		return
	end
	
	local items = cfg.reward
	local itemsNum = cfg.rewardNum
	local count = 0
	for i, e in ipairs(items) do
		if e ~= 0 then
			count = count + 1
		end
	end

	local children = self.itemScroll:addChildWithCount(LAYER_DB7T, 6, count)
	for i, e in ipairs(items) do
		if e ~= 0 then
			local widget = children[i].vars
			widget.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(e))
			widget.suo:setVisible(e>0)
			widget.grade_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(e))
			widget.num:setText(itemsNum[i])
			widget.bt:onClick(self, self.onItemTips, e)
		end
	end
	self.itemScroll:stateToNoSlip()
end

function wnd_demonhole_dialogue:onUpFloor(sender)
	local curFloor = g_i3k_game_context:GetDemonHoleFloorGrade()
	i3k_sbean.demonhole_changefloor(curFloor - 1)
end

function wnd_demonhole_dialogue:onNextFloor(sender)
	local havaKeyNum = g_i3k_game_context:GetCommonItemCanUseCount(i3k_db_demonhole_base.keyId)
	local curFloor = g_i3k_game_context:GetDemonHoleFloorGrade()
	if havaKeyNum >= self._needKey then
		i3k_sbean.demonhole_changefloor(curFloor + 1, self._needKey)
	else
		g_i3k_ui_mgr:PopupTipMessage("钥匙不足")
	end
end

function wnd_demonhole_dialogue:onFunction(sender,gid)
	g_i3k_logic:OpenCommonStoreUI(gid)
	self:onCloseUI()
end

function wnd_demonhole_dialogue:onItemTips(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

function wnd_create(layout, ...)
	local wnd = wnd_demonhole_dialogue.new()
	wnd:create(layout, ...)
	return wnd
end
