module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_equip_seven_tips2 = i3k_class("wnd_equip_seven_tips2", ui.wnd_base)

local LAYER_LYTIPS2 = "ui/widgets/lytips2"

function wnd_equip_seven_tips2:ctor()
	self.needItem = {}   
	self.needArgsItemID = {}   --合成道具id
	self.needArgsItemCount = {}  --合成道具Count
end

function wnd_equip_seven_tips2:configure()
	local widgets = self._layout.vars
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
	self.LongYinIron   = widgets.item_icon
	self.LongYinIronBg = widgets.item_bg
	self.LongYinName   = widgets.item_name
	self.LongYinDesc   = widgets.item_desc
	self.LongYinType   = widgets.item_count
	self.buy        = widgets.cancel
	self.ok            = widgets.ok
	
	for i=1, 3 do
		local item = "item"..i
		local item_bg_icon = "item_bg_icon"..i
		local item_icon = "item_icon"..i
		local item_btn = "item_btn"..i
		local item_name = "item_name"..i
		local item_count = "item_count"..i
		local item_lock  = "item_lock" ..i

		self.needItem[i] = {
			item	    = widgets[item],
			item_bg_icon= widgets[item_bg_icon],
			item_icon	= widgets[item_icon],
			item_btn	= widgets[item_btn],
			item_name	= widgets[item_name],
			item_count	= widgets[item_count],
			item_lock   = widgets[item_lock],
		}
	end
end


function wnd_equip_seven_tips2:refresh(argData)
	local iron = argData.args.openItemIronID
	local name = argData.args.itemName
	self.LongYinIron:setImage(g_i3k_db.i3k_db_get_icon_path(iron))
	local isOpen = g_i3k_game_context:GetIsHeChengLongYin()
	if isOpen ~= 0 then
		local quality = g_i3k_game_context:GetLongYinQuality(isOpen)
		self.LongYinIronBg:setImage(g_i3k_get_icon_frame_path_by_rank(quality))
	else
		local quality = g_i3k_game_context:GetLongYinQuality(isOpen)
		self.LongYinIronBg:setImage(g_i3k_get_icon_frame_path_by_rank(1))
	end
	--local cfgLY = g_i3k_db.i3k_db_get_common_item_cfg(iron)
	self.LongYinName:setText(argData.args.itemName)
	self.LongYinName:setTextColor(g_i3k_get_white_color())
	self.LongYinDesc:setText(i3k_get_string(411))
	self.LongYinType:hide()

	for i=1, 4 do
		self.needArgsItemID[i] = argData.compose["needItem" .. i .."ID"]
		self.needArgsItemCount[i] = argData.compose["needItem" .. i .."Count"]
	end
	self.buy:onClick(self,self.buyItem, argData.compose)
	self.ok:onClick(self,self.isHaveItem, argData.compose)
	self:refreshData()
end

function wnd_equip_seven_tips2:refreshData()
	for i=1,3 do
		local ironImage = g_i3k_db.i3k_db_get_common_item_icon_path(self.needArgsItemID[i],i3k_game_context:IsFemaleRole())
		local canUseCount = g_i3k_game_context:GetCommonItemCanUseCount(self.needArgsItemID[i])
		local cfg = g_i3k_db.i3k_db_get_common_item_cfg(self.needArgsItemID[i]) 
		self.needItem[i].item_icon:setImage(ironImage)
		self.needItem[i].item_bg_icon:setImage(g_i3k_get_icon_frame_path_by_rank(g_i3k_db.i3k_db_get_common_item_rank(self.needArgsItemID[i])))
		self.needItem[i].item_name:setText(cfg.name)
		self.needItem[i].item_lock:setVisible(g_i3k_db.i3k_db_get_consume_lock_visible(self.needArgsItemID[i]))
		self.needItem[i].item_name:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(self.needArgsItemID[i])))
		local showtext = canUseCount .. "/" .. self.needArgsItemCount[i]
		self.needItem[i].item_count:setText(showtext)
		self.needItem[i].item_count:setTextColor(g_i3k_get_cond_color(canUseCount >= self.needArgsItemCount[i]))
		self.needItem[i].item_btn:onClick(self, self.clickItem, self.needArgsItemID[i])
	end
end

function wnd_equip_seven_tips2:clickItem(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end
function wnd_equip_seven_tips2:buyItem(sender, compose)
	local descText = i3k_get_string(414, compose.composeNeedMoney)
	local function callback(isOk)
		if isOk then
			if g_i3k_game_context:GetDiamondCanUse(false) >= compose.composeNeedMoney then
				local callfunc = function ()
					g_i3k_game_context:UseDiamond(compose.composeNeedMoney,false,AT_SEAL_DIAMOND_MAKE)
					local tips = i3k_get_string(412)
					g_i3k_ui_mgr:PopupTipMessage(tips)
				end
				i3k_sbean.goto_seal_make(2,callfunc)
				return true
			else
				local tips = i3k_get_string(415)
				g_i3k_ui_mgr:PopupTipMessage(tips)
				return false
			end
		end
	end
	g_i3k_ui_mgr:ShowMessageBox2(descText, callback)
end
function wnd_equip_seven_tips2:isHaveItem(sender, compose)
	local count = 0
	for i=1,3 do
		local canUseCount = g_i3k_game_context:GetCommonItemCanUseCount(self.needArgsItemID[i])
		if self.needArgsItemCount[i] <= canUseCount then
			count = count + 1
		end
	end
	if count == 3 then
		local callfunc = function ()
			for i=1,3 do
				g_i3k_game_context:UseCommonItem(self.needArgsItemID[i], self.needArgsItemCount[i],AT_SEAL_NORMAL_MAKE)
			end
			local tips = i3k_get_string(412) 
			g_i3k_ui_mgr:PopupTipMessage(tips)
		end
		i3k_sbean.goto_seal_make(1, callfunc)
	else
		local tips = i3k_get_string(413)
		g_i3k_ui_mgr:PopupTipMessage(tips)
	end
end
--[[function wnd_equip_seven_tips2:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_EquipSevenTips2)
end--]]

function wnd_create(layout)
	local wnd = wnd_equip_seven_tips2.new();
		wnd:create(layout);

	return wnd;
end
