-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------

wnd_sign_in_solar_term = i3k_class("wnd_sign_in_solar_term",ui.wnd_base)

local LAYER_BONUSITEM = "ui/widgets/qdjqjlt"

function wnd_sign_in_solar_term:ctor()
	
end
function wnd_sign_in_solar_term:configure()
	local widgets = self._layout.vars
	widgets.SureBtn:onClick(self,self.onCloseUI)
	self.bonusScroll = widgets.bonusScroll--[[
	self.item_icon1 = widgets.itemicon1
	self.item_count1 = widgets.count1
	self.awardItem2 = widgets.awardItem2
	self.item_icon2 = widgets.itemicon2
	self.item_count2 = widgets.count2--]]
end

function wnd_sign_in_solar_term:refresh(dayAward, solarCfg, extraSign)
	local widgets = self._layout.vars
	local itemid = dayAward.itemId
	local needVipLvl = dayAward.needVipLvl
	local vipLvl = g_i3k_game_context:GetVipLevel()
	local count1 = dayAward.itemCount
	if needVipLvl ~= 0 and vipLvl >= needVipLvl then 
		count1 = count1 * 2
	end
	
	local nodeSignIn = require(LAYER_BONUSITEM)()
	nodeSignIn.vars.awardItem:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemid))
	nodeSignIn.vars.itemicon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemid,i3k_game_context:IsFemaleRole()))
	nodeSignIn.vars.count:setText(string.format("x%s", count1))
	nodeSignIn.vars.itemDesc:onClick(self,self.showItemInfo,itemid)
	self.bonusScroll:addItem(nodeSignIn)
	
	local nodeSignInSolarTerm = require(LAYER_BONUSITEM)()
	nodeSignInSolarTerm.vars.awardItem:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(solarCfg.solartermPackID))
	nodeSignInSolarTerm.vars.itemicon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(solarCfg.solartermPackID,i3k_game_context:IsFemaleRole()))
	nodeSignInSolarTerm.vars.count:setText(string.format("x%s", solarCfg.solartermPackCount))
	nodeSignInSolarTerm.vars.itemDesc:onClick(self,self.showItemInfo,solarCfg.solartermPackID)
	self.bonusScroll:addItem(nodeSignInSolarTerm)
	
	if extraSign then
		local nodeSignInChannelExtra = require(LAYER_BONUSITEM)()
		nodeSignInChannelExtra.vars.awardItem:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(extraSign.itemId))
		nodeSignInChannelExtra.vars.itemicon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(extraSign.itemId,i3k_game_context:IsFemaleRole()))
		nodeSignInChannelExtra.vars.count:setText(string.format("x%s", extraSign.itemCount))
		nodeSignInChannelExtra.vars.itemDesc:onClick(self,self.showItemInfo,extraSign.itemId)
		self.bonusScroll:addItem(nodeSignInChannelExtra)
	end
	
	
	--[[
	
	self.awardItem1:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemid))
	self.item_icon1:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemid,i3k_game_context:IsFemaleRole()))
	self.item_count1:setText(string.format("x%s", count1))
	
	self.awardItem2:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(solarCfg.solartermPackID))
	self.item_icon2:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(solarCfg.solartermPackID,i3k_game_context:IsFemaleRole()))
	self.item_count2:setText(string.format("x%s", 1))--]]
	
	widgets.descTxt:setText(solarCfg.solartermDesc)
	widgets.descTxt:setTextColor(solarCfg.solartermDescColor)
	widgets.descTxt:enableOutline(solarCfg.solartermDescFrameColor)
	widgets.solarTermIcon:setImage(g_i3k_db.i3k_db_get_icon_path(solarCfg.solartermMark))
	widgets.background:setImage(g_i3k_db.i3k_db_get_icon_path(solarCfg.solartermBgID))
	
end

function wnd_sign_in_solar_term:showItemInfo(sender,itemID)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemID)
end

function wnd_create(layout)
	local wnd = wnd_sign_in_solar_term.new()
	wnd:create(layout)
	return wnd
end