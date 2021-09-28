module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_quick_combine = i3k_class("wnd_quick_combine", ui.wnd_base)
function wnd_quick_combine:ctor()
	self.needCombined = {};
	self.isAllCheck = true
end

function wnd_quick_combine:setAllCheckStats(isEnable)
	self.isAllCheck = isEnable;
	self._layout.vars.markImg:setVisible(self.isAllCheck)
end

function wnd_quick_combine:testAllCheck()
	local isAllCheck = true
	for _, v in ipairs(self._layout.vars.content.child) do
		if not v.vars.isUp:isVisible() then
			isAllCheck = false
			break
		end
	end
	self:setAllCheckStats(isAllCheck)
end

function wnd_quick_combine:configure()
	local vars = self._layout.vars
	vars.cancel:onClick(self,function ()
		g_i3k_ui_mgr:CloseUI(eUIID_Quick_Combine)
	end)
	
	vars.ok:onClick(self,function ()
		local choseIds = {}
		local isHaveHighRankItem = false
		for _, v in ipairs(self._layout.vars.content.child) do
			if v.vars.isUp:isVisible() then
				table.insert(choseIds, v.vars.id)
				if g_i3k_db.i3k_db_get_common_item_rank(v.vars.id) >= 4 then
					isHaveHighRankItem = true
				end
			end
		end
		if #choseIds == 0 then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15477))
			return
		end
		
		local doSend = function ()
			i3k_sbean.bag_merge_all(choseIds)
		end
		
		if isHaveHighRankItem then
			g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(15478), function (ok)
				if ok then
					doSend()
				end
			end)
		else
			doSend()
		end		
	end)
	
	vars.markBtn:onClick(self, function ()
		self:setAllCheckStats(not self.isAllCheck);
		for _, v in ipairs(self._layout.vars.content.child) do
			v.vars.isUp:setVisible(self.isAllCheck);
		end
	end)
end

function wnd_quick_combine:refresh(combinedItems)
	local scroll = self._layout.vars.content
	table.sort(combinedItems,function (a,b)
		return g_i3k_db.i3k_db_get_common_item_rank(a.id) > g_i3k_db.i3k_db_get_common_item_rank(b.id)
	end)
	local layer = scroll:addItemAndChild("ui/widgets/djhbt",5,#combinedItems)
	for k, v in ipairs(combinedItems) do
		local item = layer[k].vars
		item.id = v.id
		item.grade_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.id == 0 and 106 or v.id))
		item.item_icon:setImage(v.id == 0 and g_i3k_db.i3k_db_get_icon_path(2396) or g_i3k_db.i3k_db_get_common_item_icon_path(v.id,i3k_game_context:IsFemaleRole()))
		item.item_count:setText(v.count)
		item.bt:onClick(self, function ()
			item.isUp:setVisible(not item.isUp:isVisible());
			self:testAllCheck();
		end);
	end
end

function wnd_create(layout)
	local wnd = wnd_quick_combine.new();
	wnd:create(layout);
	return wnd;
end
