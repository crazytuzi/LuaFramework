-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_shen_bing_talent_buy = i3k_class("wnd_shen_bing_talent_buy", ui.wnd_base)

local JNSJT = "ui/widgets/jnsjt1"

function wnd_shen_bing_talent_buy:ctor( )
	self.useIdTbl = {}
	self.useCountTbl = {} 
	self.shenbingId = 1

	self.isCanBuy = true
end

function wnd_shen_bing_talent_buy:configure( )
	local widgets = self._layout.vars
	self.up_btn = widgets.up_btn
	
	self.scroll = widgets.scroll
	self.close_btn = widgets.close_btn
	self.close_btn:onClick(self,self.onCloseUI)
	self.desc1 = widgets.desc1
	self.desc2 = widgets.desc2
end

function wnd_shen_bing_talent_buy:refresh(shenbingId,haveBuyPoint)
	self:SetShenBingTalentBuyData(shenbingId,haveBuyPoint)
	self:updateShenBingTalentBuyItems()
end

function wnd_shen_bing_talent_buy:SetShenBingTalentBuyData(shenbingId,haveBuyPoint)
	self.shenbingId = shenbingId 
	local initPoint = i3k_db_shen_bing_talent_init.init_talentPoint_counts[1]
	local a = #i3k_db_shen_bing_talent_buy[shenbingId]
	local allBuyPoint = a - initPoint
	local canBuyPoint = allBuyPoint - haveBuyPoint 

	local  desc1 = ""
	desc1 = "[1]"
	desc1 = string.format("<c=green>%s</c>", desc1) 
	local desc2 = tostring(canBuyPoint)
	desc2 = string.format("<c=green>%s</c>", desc2) 

	self.desc1:setText(string.format("消耗如下道具，获得%s%s",desc1,"点天赋"))
	self.desc2:setText(string.format("还可以购买%s%s",desc2,"点天赋"))

	local talentBuyDataTbl = i3k_db_shen_bing_talent_buy[shenbingId][haveBuyPoint + initPoint + 1]
	self.useIdTbl = {
	[1] = talentBuyDataTbl.cost_id1,
	[2] = talentBuyDataTbl.cost_id2
}
	self.useCountTbl = {
	[1] = talentBuyDataTbl.cost_count1,
	[2] = talentBuyDataTbl.cost_count2
}

end

function wnd_shen_bing_talent_buy:updateShenBingTalentBuyItems()
	self.scroll:removeAllChildren()
	for k,v in ipairs(self.useIdTbl) do
		if v ~= 0 then 
			local _layer = require(JNSJT)()
			local widgets1 = _layer.vars
			local itemId = self.useIdTbl[k]
			local item_rank = g_i3k_db.i3k_db_get_common_item_rank(itemId)
			local item_count = self.useCountTbl[k]

			widgets1.suo:setVisible(g_i3k_db.i3k_db_get_consume_lock_visible(itemId))
			widgets1.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemId,i3k_game_context:IsFemaleRole()))
			widgets1.item_name:setText(g_i3k_db.i3k_db_get_common_item_name(itemId))
			widgets1.item_name:setTextColor(g_i3k_get_color_by_rank(item_rank))
			if math.abs(itemId) == 2 then
				widgets1.item_count:setText(item_count)
			else
				widgets1.item_count:setText(g_i3k_game_context:GetCommonItemCanUseCount(itemId).."/"..item_count)
			end
			widgets1.item_count:setTextColor(g_i3k_get_cond_color(item_count <= g_i3k_game_context:GetCommonItemCanUseCount(itemId)))
			widgets1.item_BgIcon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemId))
			widgets1.tip_btn:onClick(self, self.itemTips, itemId)
			self.scroll:addItem(_layer)
		end
	end

	self.up_btn:onClick(self,self.onUpBtn)

	local bag_count1 = g_i3k_game_context:GetCommonItemCanUseCount(self.useIdTbl[1])
	local bag_count2 = g_i3k_game_context:GetCommonItemCanUseCount(self.useIdTbl[2])	
	if bag_count1 >= self.useCountTbl[1] then
		if self.useIdTbl[2] == 0 then
			self.isCanBuy = true
		else
			if bag_count2 >= self.useCountTbl[2] then 
				self.isCanBuy = true
			else
				 self.isCanBuy = false
			end
		end
	else
		self.isCanBuy = false
	end	
end

function wnd_shen_bing_talent_buy:onUpBtn()
	if self.isCanBuy then
		i3k_sbean.shen_bing_buyTalent(self.shenbingId,self.useIdTbl[1],self.useCountTbl[1],self.useIdTbl[2],self.useCountTbl[2])

	else
		g_i3k_ui_mgr:PopupTipMessage("材料不足，无法购买")
	end
end

function wnd_shen_bing_talent_buy:itemTips(sender,itemId)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end

function wnd_create(layout)
	local wnd = wnd_shen_bing_talent_buy.new()
	wnd:create(layout)
	return wnd
end
