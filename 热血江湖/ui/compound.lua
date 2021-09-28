-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_compound = i3k_class("wnd_compound", ui.wnd_base)

local LAYER_TZJLT = "ui/widgets/tzjlt"

function wnd_compound:ctor()
	self._type = 0
	self._itemId = nil
end

function wnd_compound:configure()
	local widgets = self._layout.vars
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
	self.showBtn = self._layout.vars.showBtn
end

function wnd_compound:refresh(itemId)
	self._itemId = itemId
	self:onShowData()
end

function wnd_compound:onShowData()
	local item_cfg = g_i3k_db.i3k_db_get_other_item_cfg(self._itemId)
	local id = item_cfg.args1
	local widget = self._layout.vars
	local needItem = {}
	local needItemId = {}
	local needItemConunt = {}
	for i=1, 6 do
		local item = "item" .. i
		local item_ironBg = "item_ironBg"..i
		local item_name = "item_name"..i
		local item_iron = "item_iron"..i
		local item_count = "item_count"..i
		local item_btn = "item_btn" .. i
		needItem[i] = {
			item 			= widget[item],
			item_ironBg	    = widget[item_ironBg],
			item_name  		= widget[item_name],
			item_iron	    = widget[item_iron],
			item_count	    = widget[item_count],
			item_btn		= widget[item_btn],
		}
		needItemId[i] = i3k_db_compound[id]["needItemId" .. i]
		needItemConunt[i] = i3k_db_compound[id]["needItemConunt" .. i]
	end
	for i,e in ipairs(i3k_db_compound) do
		if e.compoundID == id then
			local cfg = g_i3k_db.i3k_db_get_common_item_cfg(e.getItemID)
			widget.name:setText(cfg.name)
			widget.name:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(e.getItemID)))
			widget.count:setText("x" .. e.getItemCount)
			widget.iron:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(e.getItemID,i3k_game_context:IsFemaleRole()))
			widget.ironBg:setImage(g_i3k_get_icon_frame_path_by_rank(g_i3k_db.i3k_db_get_common_item_rank(e.getItemID)))
			self.showBtn:onClick(self, self.onShowTips, e.getItemID)
		end
	end
	local rewordCount = 0
	local nowCount = 0
	for i=1, 6 do
		needItem[i].item:hide()
		if needItemId[i] ~= 0 then
			needItem[i].item:show()
			local canUseCount = g_i3k_game_context:GetCommonItemCanUseCount(needItemId[i])
			local cfg = g_i3k_db.i3k_db_get_common_item_cfg(needItemId[i])
			needItem[i].item_name:setText(cfg.name)
			needItem[i].item_name:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(needItemId[i])))
			needItem[i].item_iron:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(needItemId[i],i3k_game_context:IsFemaleRole()))
			needItem[i].item_ironBg:setImage(g_i3k_get_icon_frame_path_by_rank(g_i3k_db.i3k_db_get_common_item_rank(needItemId[i])))
			local showtext = canUseCount .. "/" .. needItemConunt[i]
			needItem[i].item_count:setText(showtext)
			needItem[i].item_count:setTextColor(g_i3k_get_cond_color(canUseCount >= needItemConunt[i]))
			needItem[i].item_btn:onClick(self, self.onShowTips, needItemId[i])
			rewordCount = rewordCount + 1
			if canUseCount >= needItemConunt[i] then
				nowCount = nowCount + 1
			end
		end
	end
	if nowCount == rewordCount then
		widget.btn:enableWithChildren()
	else
		widget.btn:disableWithChildren()
	end
	widget.btn:onClick(self, self.compoundBtn, {id = id, count = 1, needItemId = needItemId, needItemConunt = needItemConunt})
end

function wnd_compound:compoundBtn(sender, data)
	-- i3k_sbean.bag_piececompose(data)
	g_i3k_ui_mgr:OpenUI(eUIID_CompoundItems)
	g_i3k_ui_mgr:RefreshUI(eUIID_CompoundItems, self._itemId, data)
end

function wnd_compound:onShowTips(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

function wnd_create(layout)
	local wnd = wnd_compound.new()
	wnd:create(layout)
	return wnd
end
