-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_canwuStart = i3k_class("wnd_canwuStart", ui.wnd_base)

function wnd_canwuStart:ctor()
	--self.typeName = {"武道", "身法", "内力", "防御", "暴击", "韧性"}
	self.needItem ={}
	self.wudaoID = 0
	self.info = nil
end



function wnd_canwuStart:configure(...)
	local widgets = self._layout.vars
	self.itemName = widgets.item_name
	self.wudaoName = widgets.item_count
	self.itemDesc = widgets.item_desc
	self.cancel = widgets.cancel
	self.ok = widgets.ok
	
	
	for i=1, 3 do
		local item = "item"..i
		local item_bg_icon = "item_bg_icon"..i
		local item_icon = "item_icon"..i
		local item_btn = "item_btn"..i
		local item_name = "item_name"..i
		local item_count = "item_count"..i
		--local item_lock  = "item_lock" ..i

		self.needItem[i] = {
			item	    = widgets[item],
			item_bg_icon= widgets[item_bg_icon],
			item_icon	= widgets[item_icon],
			item_btn	= widgets[item_btn],
			item_name	= widgets[item_name],
			item_count	= widgets[item_count],
			--item_lock   = widgets[item_lock],
		}
	end
end
function wnd_canwuStart:onShow()
	
end

function wnd_canwuStart:refresh(wudaoID, info)
	self.wudaoID = wudaoID
	self.info = info
	self:updateLayerData()
end 

function wnd_canwuStart:updateLayerData()
	local wudaoID = self.wudaoID
	local info = self.info
	local typeName = {}
	for k,v in ipairs(i3k_db_experience_canwu) do
		typeName[k] = v[1].name
	end
	local newInfo = info.memberInfo
	self.itemName:setText(newInfo.name)
	local xuanJi = g_i3k_game_context:GetNowXuanJi()
	self.wudaoName:setText(i3k_get_string(472, typeName[xuanJi]))
	local needItemID, needItemCount = g_i3k_game_context:GetCanWuNeedItem(wudaoID);
	for i=1, #needItemID do
		local canUseCount = g_i3k_game_context:GetCommonItemCanUseCount(needItemID[i])
		local ironImage = g_i3k_db.i3k_db_get_common_item_icon_path(needItemID[i],i3k_game_context:IsFemaleRole())
		local cfg = g_i3k_db.i3k_db_get_common_item_cfg(needItemID[i]) 
		self.needItem[i].item_icon:setImage(ironImage)
		self.needItem[i].item_bg_icon:setImage(g_i3k_get_icon_frame_path_by_rank(g_i3k_db.i3k_db_get_common_item_rank(needItemID[i])))
		self.needItem[i].item_name:setText(cfg.name)
		self.needItem[i].item_name:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(needItemID[i])))
		local showtext = canUseCount .. "/" .. needItemCount[i]
		self.needItem[i].item_count:setText(showtext)
		self.needItem[i].item_count:setTextColor(g_i3k_get_cond_color(canUseCount >= needItemCount[i]))
		self.needItem[i].item_btn:onClick(self, self.clickItem, needItemID[i])
	end
	self.ok:onClick(self,self.wudaoBtn, {needItemID = needItemID, needItemCount = needItemCount, id = newInfo.id, wudaoID = wudaoID})
	self.cancel:onClick(self, self.onCloseUI, function ()
		g_i3k_game_context:recordSelectWudao(wudaoID)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_CanWu, "canwuCountData")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_CanWu, "factionMemberInfo")
	end)
end

function wnd_canwuStart:wudaoBtn(sender, item)
	if g_i3k_game_context:IsCanWuItem(item.needItemID, item.needItemCount) then
		local callfunc = function ()
			for i=1,3 do
				g_i3k_game_context:UseCommonItem(item.needItemID[i], item.needItemCount[i],AT_GRASP_IMPL)
			end
		end
		i3k_sbean.goto_grasp_impl(item.id, item.wudaoID, callfunc)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(473))
	end
end

function wnd_canwuStart:closeBtn(sender, wudaoID)
	g_i3k_ui_mgr:CloseUI(eUIID_CanWuStrat)
	g_i3k_game_context:recordSelectWudao(wudaoID)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_CanWu, "canwuCountData")
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_CanWu, "factionMemberInfo")
end

function wnd_canwuStart:clickItem(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

function wnd_create(layout, ...)
	local wnd = wnd_canwuStart.new()
	wnd:create(layout, ...)
	return wnd
end
