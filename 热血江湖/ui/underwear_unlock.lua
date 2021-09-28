-------------------------------------------------------
module(..., package.seeall)

local require = require;

require("ui/ui_funcs")
local ui = require("ui/base");

-------------------------------------------------------
wnd_underwear_unlock = i3k_class("wnd_underwear_unlock", ui.wnd_base)
--内甲解锁

function wnd_underwear_unlock:ctor()
	self.canOpen1 = true --用来记录前提条件
	self.canOpen2 = {} --用来记录道具
	self.canOpenable = true
end
function wnd_underwear_unlock:configure()
	local widgets = self._layout.vars
	widgets.close_btn2:onClick(self, self.onCloseUI)
	--widgets.tipsBtn:onClick(self, self.onTipsClick)
	widgets.up_btn2:onClick(self, self.unlock)
	widgets.tips:onClick(self, self.onTipsClick)
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
	--[[self.PropTab = {}
	for i =1 ,4 do 
		local item = string.format("item%s",i)
		local itemAll = widgets[item]	
		local item_name = string.format("item_name%s",i)
		local nameLabel = widgets[item_name]		
		local item_count = string.format("item_count%s",i)
		local countLabel = widgets[item_count]
		local item_bgicon = string.format("item_bg_icon%s",i)
		local item_bg_icon = widgets[item_bgicon]
		local itemIcon = string.format("item_icon%s",i)
		local item_icon = widgets[itemIcon]		
		local itemBtn = string.format("item_btn%s",i)
		local item_btn = widgets[itemBtn]	
		local item_lock= string.format("item_lock%s",i)
		local item_lock_Icon = widgets[item_lock]	
		local needItem ={itemAll = itemAll ,nameLabel = nameLabel ,countLabel = countLabel ,item_bg_icon = item_bg_icon ,item_icon = item_icon,item_btn = item_btn,item_lock_Icon = item_lock_Icon}
		table.insert(self.PropTab , i,needItem)
	end	--]]
	self.widgets = root
end

function wnd_underwear_unlock:onTipsClick(sender)
	local widgets = self._layout.vars
	widgets.tipsRoot:setVisible(not widgets.tipsRoot:isVisible())
	widgets.tipsTxt:setText(i3k_get_string(18067))
end

function wnd_underwear_unlock:refresh(index)
	self.index = index
	local cur_level = g_i3k_game_context:GetLevel()
	local feat =  g_i3k_game_context:getForceWarAddFeat()
	local heroPower = i3k_game_get_player_hero():Appraise()

	self.widgets.levelLabel:setText(i3k_db_under_wear_cfg[index].lockLevel)
	self.widgets.levelCan:show()
	self.widgets.powerCan:show()
	self.widgets.wuxunCan:show()
	self.widgets.levelLabel:setTextColor(g_i3k_get_green_color())
	if  cur_level<i3k_db_under_wear_cfg[index].lockLevel then
		self.widgets.levelLabel:setTextColor(g_i3k_get_red_color())--红色
		self.widgets.levelCan:hide()
		self.widgets.levelNo:show()
		self.canOpen1 =false 
	end
	self.widgets.powerLabel:setTextColor(g_i3k_get_green_color())
	self.widgets.powerLabel:setText(heroPower.."/"..i3k_db_under_wear_cfg[index].lockFightNum)
	if  heroPower<i3k_db_under_wear_cfg[index].lockFightNum then
		self.widgets.powerLabel:setTextColor(g_i3k_get_red_color())--红色
		self.widgets.powerCan:hide()
		self.widgets.powerNo:show()
		self.canOpen1 =false
	end
	self.widgets.wuxunLabel:setText(feat.."/"..i3k_db_under_wear_cfg[index].lockWuXunNum)
	self.widgets.wuxunLabel:setTextColor(g_i3k_get_green_color())
	if  feat < i3k_db_under_wear_cfg[index].lockWuXunNum then
		self.widgets.wuxunLabel:setTextColor(g_i3k_get_red_color())--红色
		self.widgets.wuxunCan:hide()
		self.widgets.wuxunNo:show()
		self.canOpen1 =false
	end
	self.widgets.title:setText(i3k_get_string(18147, i3k_db_under_wear_cfg[index].name))
	self:setPropData()
end
function wnd_underwear_unlock:setPropData()
	self._itemItem = {}  --消耗的道具集合
	local scroll = self._layout.vars.scroll
	scroll:removeAllChildren()
	local i = 1
	while true do
		local lockNeed = string.format("lockNeedId%d", i) 
		local needid = i3k_db_under_wear_cfg[self.index][lockNeed]
		local node
		if needid and needid ~=0 then
			node = require("ui/widgets/njfwt1")()
			local weights = node.vars
			local itemCount1 = g_i3k_game_context:GetCommonItemCanUseCount(needid)
			local NeedCount = string.format("lockNeedCount%d", i) 
			local needCount1 = i3k_db_under_wear_cfg[self.index][NeedCount]
			local name_colour = g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(needid))
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
			break
		
		end
		i = i + 1
	end
end
function wnd_underwear_unlock:unlock(sender)
	--6.3	点击解锁按钮，若前提条件不足，则弹出浮字提示：“前提条件不足，无法解锁”
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
		i3k_sbean.undweWear_unlock(self.index,self._itemItem)
		self:onCloseUI()
	end
end

function wnd_underwear_unlock:onCloseUI(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_Under_Wear_Unlock)
end


function wnd_create(layout)
	local wnd = wnd_underwear_unlock.new();
	wnd:create(layout);
	return wnd;
end


