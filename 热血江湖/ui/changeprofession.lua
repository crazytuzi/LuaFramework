
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_changeProfession = i3k_class("wnd_changeProfession",ui.wnd_base)

function wnd_changeProfession:ctor()
	self._titleName = ""
	self.bwType = 0
	self.classType = 0
	self._isBiography = nil
end

function wnd_changeProfession:configure()
	local widgets = self._layout.vars
	widgets.clostBtn:onClick(self, self.onCloseUI)
	widgets.okBtn:onClick(self, self.onStart)
	self.condition = {
		widgets.condition1,
		widgets.condition2,
		widgets.condition3,
		widgets.condition4
	}
	self.scroll = widgets.scroll
	widgets.tipTxt:setText(i3k_get_string(1041))
	self.canChange = true
end

function wnd_changeProfession:refresh(lastChangeTime, titleName, bwType, classType, isBiography)
	self._isBiography = isBiography
	local wdg = self._layout.vars
	wdg.title:setText(titleName)
	self._titleName = titleName
	self.bwType = bwType
	self.classType = classType
	local cfg = i3k_db_common.changeProfession
	local haveSubTask = false

	for _,tid in ipairs(cfg.transforTasks) do
		for k,v in pairs(g_i3k_game_context:getSubLineTask()) do
			if tid == k and v.id > 0 then
				haveSubTask = true
				break
			end
		end
		if haveSubTask then
			break
		end
	end
	local str = {}
	local condition = {}
	if not self._isBiography then
	if g_i3k_game_context:GetTransformLvl() < cfg.transformLvl then
		condition[1] = true
	end
	if haveSubTask then
		condition[2] = true
	end
		str = {i3k_get_string(1035), i3k_get_string(1036), i3k_get_string(1037, cfg.coolTime/86400)}
	local ltime = i3k_game_get_time() - lastChangeTime
	if cfg.coolTime > ltime then
		local ltime = cfg.coolTime - ltime
		local day = math.modf(ltime/86400)
		local hours = math.modf((ltime%86400)/3600)
		local sec = math.modf(math.modf(ltime%3600)/60)
		--local timestr = (day == 0 and "" or day.."天") .. (day > 0 and "" or hours.."时") .. (hours > 0 and "" or sec.."分")
		local timestr = "1分"
		if day > 0 then
			timestr = day.."天"
		elseif hours > 0 then
			timestr = hours.."时"
		elseif sec > 0 then
			timestr = sec.."分"
		end
		str[#str] = str[#str] .. i3k_get_string(1038, timestr)
		condition[3] = true
	end
	if g_i3k_get_GMTtime(i3k_game_get_time()) < cfg.opendate then
		str[#str + 1] = i3k_get_string(1039, cfg.opendatestr)
		condition[4] = true
	end
		for k, v in pairs(cfg.cost) do
			local item= require("ui/widgets/zybgt")()
			wdg.scroll:addItem(item)
			item.vars.item_bg:setImage(g_i3k_get_icon_frame_path_by_rank(g_i3k_db.i3k_db_get_common_item_rank(v.id)))
			item.vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.id, g_i3k_game_context:IsFemaleRole()))
			item.vars.itemName_label:setText(g_i3k_db.i3k_db_get_common_item_name(v.id))
			local ItemRank = g_i3k_db.i3k_db_get_common_item_rank(v.id)
			item.vars.itemName_label:setTextColor(g_i3k_get_color_by_rank(ItemRank))
			item.vars.btn:onClick(self,self.onProItemdetail, v.id)
			item.vars.lockImg:setVisible(v.id > 0)
		end
		self:updateItemsCount()
	elseif self._isBiography == g_BIOGRAPHY_TRANSFORM_FORWARD then
		if g_i3k_game_context:GetTransformLvl() < i3k_db_wzClassLand[classType].needChangeLevel then
			condition[1] = true
		end
		if haveSubTask then
			condition[2] = true
		end
		str = {i3k_get_string(1035), i3k_get_string(1036)}
		self:updateBiographyText(i3k_get_string(18524))
	elseif self._isBiography == g_BIOGRAPHY_TRANSFORM_REGRET then
		if haveSubTask then
			condition[1] = true
		end
		local state, time = g_i3k_game_context:isCanTransformBack(g_i3k_game_context:GetRoleType())
		table.insert(str, i3k_get_string(1036))
		if time then
			local regret = i3k_db_wzClassLand[g_i3k_game_context:GetRoleType()].backTime / 86400
			if time >= 3600 * 24 then
				table.insert(str, i3k_get_string(18526, regret, math.ceil(time / 86400)))
			elseif time >= 3600 then
				table.insert(str, i3k_get_string(18527, regret, math.ceil(time / 3600)))
			else
				table.insert(str, i3k_get_string(18528, regret, math.ceil(time / 60)))
			end
		else
			condition[2] = true
		end
		self:updateBiographyText(i3k_get_string(18525))
	end
	if table.nums(condition) ~= 0 then
		wdg.okBtn:disable()
	end
	for i,node in ipairs(self.condition) do
		if str[i] then
			node:setText(str[i])
			node:setTextColor(g_i3k_get_cond_color(not condition[i]))
		else
			node:hide()
		end
	end


end

function wnd_changeProfession:updateItemsCount()
	if not self._isBiography then
	self.canChange = true
	for i,v in ipairs(i3k_db_common.changeProfession.cost) do
		local item = self.scroll:getChildAtIndex(i)
		local itemCount = g_i3k_game_context:GetCommonItemCanUseCount(v.id)
		item.vars.count:setText(itemCount.."/"..v.value)

		if v.value>itemCount and self.canChange then
			self.canChange = false
		end
		item.vars.count:setTextColor(g_i3k_get_cond_color(v.value<=itemCount))
		end
	end
end
function wnd_changeProfession:updateBiographyText(text)
	self._layout.vars.scroll:removeAllChildren()
	local node = require("ui/widgets/zybgt1")()
	node.vars.text:setText(text)
	g_i3k_ui_mgr:AddTask(self, {node}, function(ui)
		local size = node.rootVar:getContentSize()
		local height = node.vars.text:getInnerSize().height
		local width = size.width
		height = size.height > height and size.height or height
		node.rootVar:changeSizeInScroll(ui._layout.vars.scroll, width, height, true)
	end, 1)
	self._layout.vars.scroll:addItem(node)
end

function wnd_changeProfession:onStart()
	if not self.canChange then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1044))
	end
	local t = {}
	local count = 0
	for k,v in pairs(g_i3k_game_context:GetWearEquips()) do
		if v.equip then
			t[v.equip.equip_id] = 1
			count = count + 1
		end
	end
	if count > 0 and not g_i3k_game_context:IsBagEnough(t) then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1046, count))
	end
	g_i3k_ui_mgr:OpenUI(eUIID_ChangeProfessionConfirm)
	g_i3k_ui_mgr:RefreshUI(eUIID_ChangeProfessionConfirm, self._titleName, self.bwType, self.classType, self._isBiography)
end

function wnd_changeProfession:onProItemdetail(sender, itemId)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end

function wnd_create(layout, ...)
	local wnd = wnd_changeProfession.new()
	wnd:create(layout, ...)
	return wnd;
end

