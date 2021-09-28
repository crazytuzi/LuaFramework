module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_artifactStrengthSelect = i3k_class("wnd_artifactStrengthSelect", ui.wnd_base)
local ConsumeVit = 0;
local ConsumeItem = 1;
function wnd_artifactStrengthSelect:ctor()

end
function wnd_artifactStrengthSelect:configure()
    local widgets = self._layout.vars
	self.name1 = widgets.name1;
	self.name2 = widgets.name2;
	self.level1 = widgets.level1;
	self.level2 = widgets.level2;
	self.loseBtn = widgets.loseBtn;
	self.saveBtn1 = widgets.saveBtn;
	self.itemIcon1 = widgets.itemIcon1;
	self.itemIcon2 = widgets.itemIcon2;
	self.itemNum1 = widgets.itemNum1;
	self.itemNum2 = widgets.itemNum2;
	self.itemBtn1 = widgets.itemBtn1;
	self.itemBtn2 = widgets.itemBtn2;
	widgets.close:onClick(self, self.onCloseUI)
end

function wnd_artifactStrengthSelect:refresh(curindex)
	local Strength = g_i3k_game_context:getHeirloomStrengthData();
	local consume = i3k_db_chuanjiabao_strength.consume[Strength.curStrengthIndex];
	local percent = i3k_db_chuanjiabao_strength.cfg.percent;
	self:updateStrengthText(Strength, percent)
	self.itemIcon1:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(g_BASE_ITEM_VIT,i3k_game_context:IsFemaleRole()))
	self.itemNum1:setText("x "..i3k_db_chuanjiabao_strength.cfg.needVit);
	self.itemIcon2:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(consume.id,i3k_game_context:IsFemaleRole()))
	self.itemNum2:setText("x "..consume.count);
	self.itemBtn1:onClick(self, self.onItemTips, g_BASE_ITEM_VIT)
	self.itemBtn2:onClick(self, self.onItemTips, consume.id)
	self.loseBtn:onClick(self, self.onSaveBtn)
	self.saveBtn1:onClick(self, self.onSaveBtn1, consume)
	local vit = g_i3k_game_context:GetVit();
	if vit < i3k_db_chuanjiabao_strength.cfg.needVit then
		self.itemNum1:setTextColor(g_i3k_get_red_color())
	end
	if g_i3k_game_context:GetCommonItemCount(consume.id) < consume.count then
		self.itemNum2:setTextColor(g_i3k_get_red_color())
	end
end

function wnd_artifactStrengthSelect:updateStrengthText(Strength, percent)
	local colorBet = i3k_db_chuanjiabao_strength.colorBet[Strength.curStrengthIndex].rate
	local value = i3k_db_chuanjiabao_strength.pros[Strength.PropIndex].value;
	self.name1:setText("精炼强化x 1");
	self.name2:setText("精炼强化x"..percent);
	value = value * colorBet;
	if Strength.PropIndex == g_ATK then
		self.level1:setText("攻击 +"..value);
		self.level2:setText("攻击 +"..value * percent);
	elseif Strength.PropIndex == g_DEF then
		self.level1:setText("防御 +"..value);
		self.level2:setText("防御 +"..value * percent);
	elseif Strength.PropIndex == g_HP then
		self.level1:setText("气血 +"..value);
		self.level2:setText("气血 +"..value * percent);
	end
end

function wnd_artifactStrengthSelect:onItemTips(sender, itemId)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end

function wnd_artifactStrengthSelect:onSaveBtn(sender)
	local vit = g_i3k_game_context:GetVit();
	if vit < i3k_db_chuanjiabao_strength.cfg.needVit then
		g_i3k_ui_mgr:PopupTipMessage("体力不足，请点击购买体力")
	else
		i3k_sbean.strengthHeirloom(ConsumeVit)
	end
end

function wnd_artifactStrengthSelect:onSaveBtn1(sender, consume)
	if g_i3k_game_context:GetCommonItemCount(consume.id) < consume.count then
		g_i3k_ui_mgr:PopupTipMessage("道具不足，请点击购买道具")
	else
		local percent = i3k_db_chuanjiabao_strength.cfg.percent;
		i3k_sbean.strengthHeirloom(ConsumeItem, percent, consume)
	end
end
----------------------------------------
function wnd_create(layout)
	local wnd = wnd_artifactStrengthSelect.new();
		wnd:create(layout);
	return wnd;
end
