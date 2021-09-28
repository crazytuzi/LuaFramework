-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_offlinWizardGift = i3k_class("wnd_offlinWizardGift", ui.wnd_base)
local Item = "ui/widgets/liwuqiuqut"
function wnd_offlinWizardGift:ctor()
	self._petID = 0;
	self._chosenItme = {};
end

function wnd_offlinWizardGift:configure()
	local widgets = self._layout.vars;
	self.icon = widgets.icon;
	self.count = widgets.count;
	self.desc = widgets.desc;
	self.scroll = widgets.scroll;
	widgets.resetBtn:onClick(self, self.onResetBtn)
	widgets.okBtn:onClick(self, self.onOkBtn)
	widgets.btnClose:onClick(self, self.onColseBtn)
end

function wnd_offlinWizardGift:refresh(petID, items)
	self:updateData(petID);
	self:updateItemScroll(items)
end

function wnd_offlinWizardGift:updateData(petID)
	self._petID = petID;
	local petData = i3k_db_arder_pet[petID];
	local time = petData.arg3 / 3600;
	self.desc:setText(i3k_get_string(16952, time, petData.arg4));
	self.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(petData.arg1,i3k_game_context:IsFemaleRole()))
	self.count:setText("x"..petData.arg2)
end

function wnd_offlinWizardGift:updateItemScroll(needItems)
	self.scroll:removeAllChildren()
	local itemsData = {}
	for k,v in pairs(needItems) do
		table.insert(itemsData, {id = k, count = v});
	end
	for i, e in ipairs(itemsData) do
		if e.id ~= 0 then
			local node = require(Item)()
			node.vars.chosenIcon:hide();
			if i == 1 then
				self._chosenItme = e;
				node.vars.chosenIcon:show();
			end
			node.vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(e.id, g_i3k_game_context:IsFemaleRole()))
			node.vars.icon_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(e.id))
			node.vars.lock:setVisible(g_i3k_db.i3k_db_get_consume_lock_visible(e.id))
			local itemData = {chosenId = i , item = e}
			node.vars.item_btn:onClick(self, self.onChosenBtn, itemData)
			node.vars.item_name:setText(g_i3k_db.i3k_db_get_common_item_name(e.id))
			node.vars.item_name:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(e.id)))
			node.vars.item_count:setText("x"..e.count)	
			self.scroll:addItem(node)
		end
	end
end

function wnd_offlinWizardGift:onChosenBtn(sender, itemData)
	local children = self.scroll:getAllChildren()
	for k,v in ipairs(children) do
		if k == itemData.chosenId then
			self._chosenItme = itemData.item;
			v.vars.chosenIcon:show();
		else
			v.vars.chosenIcon:hide();
		end
	end
end

function wnd_offlinWizardGift:onOkBtn(sender)
	if next(self._chosenItme) ~= nil then
		local isEnoughTable = { }
		isEnoughTable[self._chosenItme.id] = self._chosenItme.count
		local isEnough = g_i3k_game_context:IsBagEnough(isEnoughTable)
		if isEnough then
			i3k_sbean.wizardWishTake(self._petID, self._chosenItme)
		else
			g_i3k_ui_mgr:PopupTipMessage("背包空间不足")
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("请先选择一个奖品")
	end
end

function wnd_offlinWizardGift:onColseBtn(sender)
	i3k_sbean.wizardWishSync()
	self:onCloseUI()
end

function wnd_offlinWizardGift:isCanReset()
	local petData = i3k_db_arder_pet[self._petID];
	local UseCount = g_i3k_game_context:GetCommonItemCanUseCount(petData.arg1)
	if  UseCount >= petData.arg2 then
		return true;
	end
	return false;
end

function wnd_offlinWizardGift:onResetBtn(sender)
	if self:isCanReset() then
		i3k_sbean.wizardWishOperate(self._petID)
	else
		local fun = (function(ok)
			if ok then
				g_i3k_logic:OpenChannelPayUI()
			end
		end)
		g_i3k_ui_mgr:ShowCustomMessageBox2("去储值", "以后再说", "你的元宝不够哦，需要储值吗", fun)
	end
end

function wnd_create(layout)
	local wnd = wnd_offlinWizardGift.new();
		wnd:create(layout);
	return wnd;
end
