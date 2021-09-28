-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_sign_in_award = i3k_class("wnd_sign_in_award", ui.wnd_base)

function wnd_sign_in_award:ctor()

end

function wnd_sign_in_award:configure()
	local widgets = self._layout.vars
	
	widgets.ok:onClick(self, self.okButton)	
	self.awardItem1 = widgets.awardItem1
	self.item_bg1 = widgets.item_bg1
	self.item_icon1 = widgets.item_icon1
	self.item_desc1 = widgets.item_desc1
	self.awardItem2 = widgets.awardItem2
	self.item_bg2 = widgets.item_bg2
	self.item_name2 = widgets.item_name2
	self.item_icon2 = widgets.item_icon2 
	self.item_desc2 = widgets.item_desc2
	self.dt = widgets.dt
	self.awardItem3 = widgets.awardItem3
	self.item_bg3 = widgets.item_bg3
	self.item_icon3 = widgets.item_icon3
	self.item_desc3 = widgets.item_desc3
end

function wnd_sign_in_award:refresh(dayAward, extraSign)
	local itemid = dayAward.itemId
	local name = string.format("%sx%s", g_i3k_db.i3k_db_get_common_item_name(itemid), dayAward.itemCount) 
	local needVipLvl = dayAward.needVipLvl
	local vipLvl = g_i3k_game_context:GetVipLevel()
	
	self.awardItem1:show()
	self.item_bg1:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemid))
	self.item_icon1:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemid,i3k_game_context:IsFemaleRole()))
	self.item_desc1:setText(name)
	if extraSign or (needVipLvl ~= 0 and vipLvl >= needVipLvl) then
		self.awardItem2:show();
	end
	if extraSign and needVipLvl ~= 0 and vipLvl >= needVipLvl then 
		local extraSignName = string.format("%sx%s", g_i3k_db.i3k_db_get_common_item_name(extraSign.itemId), extraSign.itemCount) 
		self.awardItem3:show()
		self.item_bg3:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(extraSign.itemId))
		self.item_icon3:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(extraSign.itemId,i3k_game_context:IsFemaleRole()))
		self.item_desc3:setText(extraSignName)
		self:SetAwardItem2(itemid, name)	
		self:SetAwardItemPos()
	elseif extraSign then
		local extraSignName = string.format("%sx%s", g_i3k_db.i3k_db_get_common_item_name(extraSign.itemId), extraSign.itemCount) 
		self.item_name2:setText("额外奖励");
		self:SetAwardItem2(extraSign.itemId, extraSignName)
	elseif  needVipLvl ~= 0 and vipLvl >= needVipLvl then
		self:SetAwardItem2(itemid, name)	
	else
		self.awardItem2:hide();
		self.awardItem1:setPositionPercent(0.5, 0.5)
	end
end

function wnd_sign_in_award:SetAwardItem2(itemid, name)
	self.item_bg2:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemid))
	self.item_icon2:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemid,i3k_game_context:IsFemaleRole()))
	self.item_desc2:setText(name)	
end

function wnd_sign_in_award:SetAwardItemPos()
	self.awardItem1:setPositionPercent(0.25, 0.5)
	self.awardItem2:setPositionPercent(0.5, 0.5)
	self.awardItem3:setPositionPercent(0.75, 0.5)
end

function wnd_sign_in_award:okButton(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_SignInAward)
end

function wnd_create(layout)
	local wnd = wnd_sign_in_award.new()
		wnd:create(layout)
	return wnd
end

