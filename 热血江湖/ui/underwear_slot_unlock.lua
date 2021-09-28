-------------------------------------------------------
module(..., package.seeall)

local require = require;

require("ui/ui_funcs")
local ui = require("ui/base");

-------------------------------------------------------
wnd_underwear_slot_unlock = i3k_class("wnd_underwear_slot_unlock", ui.wnd_base)
--内甲解锁

function wnd_underwear_slot_unlock:ctor()
	self.canOpen1 = true --用来记录前提条件
	self.canOpen2 = {} --用来记录道具
	self.canOpenable = true
end
function wnd_underwear_slot_unlock:configure()
	local widgets = self._layout.vars
	widgets.close_btn2:onClick(self, self.onCloseUI)
	
	widgets.up_btn2:onClick(self, self.unlock)
	local root = {}
	root.levelLabel = widgets.levelLabel
	root.powerLabel = widgets.powerLabel
	root.wuxunLabel = widgets.wuxunLabel
	root.levelCan   = widgets.levelCan
	root.powerCan   = widgets.powerCan
	root.wuxunCan   = widgets.wuxunCan
	root.levelNo   = widgets.levelNo
	root.powerNo   = widgets.powerNo
	root.wuxunNo   = widgets.wuxunNo
	root.title 	    = widgets.title
	self.widgets = root
	widgets.tips:hide()
end


function wnd_underwear_slot_unlock:refresh(index,slotTag)
	self.index = index
	self.slotTag = slotTag
	local cur_level = g_i3k_game_context:GetLevel()
	local totalFeats = g_i3k_game_context:getForceWarAddFeat()
	local heroPower = i3k_game_get_player_hero():Appraise()

	--需要的数据
	local needLvl = i3k_db_under_wear_slot[index][self.slotTag].unlockNeedLvl
	local needPower = i3k_db_under_wear_slot[index][self.slotTag].unlockNeedPower
	local wunXunNums = i3k_db_under_wear_slot[index][self.slotTag].unlockNeedWuXun
	self.widgets.levelLabel:setText(needLvl)
	self.widgets.levelCan:show()
	self.widgets.powerCan:show()
	self.widgets.wuxunCan:show()
	self.widgets.levelLabel:setTextColor(g_i3k_get_green_color())--红色
	if  cur_level < needLvl then
		self.widgets.levelLabel:setTextColor(g_i3k_get_red_color())--红色
		self.widgets.levelCan:hide()
		self.widgets.levelNo:show()
		self.canOpen1 =false 
	end
	self.widgets.powerLabel:setText(needPower)
	self.widgets.powerLabel:setTextColor(g_i3k_get_green_color())
	if  heroPower < needPower then
		self.widgets.powerLabel:setTextColor(g_i3k_get_red_color())--红色
		self.widgets.powerCan:hide()
		self.widgets.powerNo:show()
		self.canOpen1 =false
	end
	self.widgets.wuxunLabel:setText(wunXunNums)
	self.widgets.wuxunLabel:setTextColor(g_i3k_get_green_color())
	if totalFeats < wunXunNums then
		self.widgets.wuxunLabel:setTextColor(g_i3k_get_red_color())--红色
		self.widgets.wuxunCan:hide()
		self.widgets.wuxunNo:show()
		self.canOpen1 =false
	end
	self.widgets.title:setText(i3k_get_string(18146, self.slotTag))
	self:setPropData()
	local widgets = self._layout.vars
	widgets.ok_word:setText(i3k_get_string(451))
end

function wnd_underwear_slot_unlock:setPropData()
	self._itemItem = {}  --消耗的道具集合
	local scroll = self._layout.vars.scroll
	scroll:removeAllChildren()
	local i = 1
	while true do
		local lockNeed = string.format("unlockNeedItemId%d", i) 
		local needid = i3k_db_under_wear_slot[self.index][self.slotTag][lockNeed]
		local node
		if needid and needid ~=0 then
			node = require("ui/widgets/njfwt1")()
			local weights = node.vars
			local itemCount1 = g_i3k_game_context:GetCommonItemCanUseCount(needid)
			local NeedCount = string.format("unlockNeedItemCount%d", i)  --unlockNeedItemCount1
			local needCount1 =i3k_db_under_wear_slot[self.index][self.slotTag][NeedCount]
			--local name_colour = g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(needid))
			--weights.nameLabel:setText(g_i3k_db.i3k_db_get_common_item_name(needid))
			--weights.nameLabel:setTextColor(name_colour)
			if g_BASE_ITEM_COIN == needid or -g_BASE_ITEM_COIN == needid then
				weights.countLabel:setText(needCount1)
			else
				weights.countLabel:setText(itemCount1.."/"..needCount1)
			end
			weights.countLabel:setTextColor(g_i3k_get_cond_color(needCount1<=itemCount1))
			weights.item_bg_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(needid))
			self.canOpen2[i] =needCount1<=itemCount1
			weights.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(needid,i3k_game_context:IsFemaleRole()))
			weights.item_btn:onClick(self, function ()
				g_i3k_ui_mgr:ShowCommonItemInfo(needid)
			end)
			weights.item_lock_Icon:setVisible(g_i3k_db.i3k_db_get_consume_lock_visible(needid))
			local tempTab = {itemid =needid, itemCount = needCount1}
			table.insert(self._itemItem ,tempTab )
			scroll:addItem(node)
		else
			--weights.itemAll:hide()
			break;
		end
		i = i + 1
	end
end
function wnd_underwear_slot_unlock:unlock(sender)
	local index = 0
	for i,v in ipairs (self.canOpen2) do 
		if v then
			index = index +1
		end
	end
	if index ==#self.canOpen2 then
		self.canOpenable = true
	else
		self.canOpenable = false
	end

	if not self.canOpen1 then
		g_i3k_ui_mgr:PopupTipMessage("前提条件不足，无法解锁")
	elseif not self.canOpenable then
		g_i3k_ui_mgr:PopupTipMessage("材料不足，无法解锁")
	else
		--去解锁
		i3k_sbean.runeSoltUnlock(self.index,self.slotTag,self._itemItem)
		self:onCloseUI()
	end
end

function wnd_underwear_slot_unlock:onCloseUI(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_Under_Wear_Slot_Unlock)
end


function wnd_create(layout)
	local wnd = wnd_underwear_slot_unlock.new();
	wnd:create(layout);
	return wnd;
end
