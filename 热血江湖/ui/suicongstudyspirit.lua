-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------

wnd_suicongStudySpirit= i3k_class("wnd_suicongStudySpirit",ui.wnd_base)
local LAYER_XINFA = "ui/widgets/suicongxinfat"
local LAYER_ITEMT = "ui/widgets/scwkt"

function wnd_suicongStudySpirit:ctor()
	self._id = 0
	self._index = 0
	self._spiritID = 0
	self._info = 0
	self._recordPresent = nil
end

function wnd_suicongStudySpirit:configure()
	local widgets = self._layout.vars
	self.scroll = widgets.scroll
	self._layout.vars.close_btn:onClick(self,self.onCloseUI, function ()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SuiCong, "updatePetXinfa")
	end)
end

function wnd_suicongStudySpirit:refresh(id, index, spiritID)
	self._id = id
	self._index = index
	self._spiritID = spiritID
	self:updateScrollData(spiritID) 
end

function wnd_suicongStudySpirit:updateScrollData(spiritID)
	local item = g_i3k_game_context:getCanStudySpirits(self._id, self._spiritID)
	self.scroll:removeAllChildren()
	for i,e in ipairs(item) do
		local layer = require(LAYER_XINFA)()
		local widget = layer.vars
		widget.level:setText("Lv." .. e.level)
		widget.icon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_suicong_spirits[e.id][1].icon))
		widget.name:setText(i3k_db_suicong_spirits[e.id][1].name)
		widget.btn:onClick(self, self.selectSpiritsData, {info = e, cSelect = widget.select})
		if spiritID  then
			if spiritID == e.id then
				local tab = {info = e, cSelect = widget.select}
				self:selectSpiritsData(nil, tab)
			end
		else 
			if i==1 then
				local tab = {info = e, cSelect = widget.select}
				self:selectSpiritsData(nil, tab)
			end
		end
		self.scroll:addItem(layer)
	end
	if self._recordPresent then
		self.scroll:jumpToListPercent(self._recordPresent)
	end
end

function wnd_suicongStudySpirit:selectSpiritsData(sender, data)
	self:updateSelect()
	data.cSelect:setImage(g_i3k_db.i3k_db_get_icon_path(2988))
	self._info = data.info
	self._recordPresent = self.scroll:getListPercent()
	self:showSpiritsData()
end

function wnd_suicongStudySpirit:showSpiritsData()
	local info = self._info
	local cfg = i3k_db_mercenaries
	self._layout.vars.level:setText(info.level)
	local str
	if info.tips1 == "" then
		str = info.desc
	else
		local tip1 = string.format(info.tips1, 1)
		local tip2 = string.format(info.tips2, 1)
		str = info.desc .. tip1 .. tip2
		
		local petLevel = g_i3k_game_context:getPetLevel(self._id)
		local temp1 = g_i3k_game_context:GetPetAttributeValue(self._id, petLevel, info.effectArgs1)
		local temp2 = g_i3k_game_context:GetPetAttributeValue(self._id, i3k_db_server_limit.sealLevel, info.effectArgs1)
		local AddTips1 = temp1[info.effectArgs1].value * (1 + info.effectArgs3/10000) - temp1[info.effectArgs1].value
		local AddTips2 = temp2[info.effectArgs1].value * (1 + info.effectArgs3/10000) - temp2[info.effectArgs1].value
		local tip1 = string.format(info.tips1, math.modf(AddTips1))
		local tip2 = string.format(info.tips2, math.modf(AddTips2))
		str = info.desc .."\n" .. tip1 .."\n" .. tip2
	end
	self._layout.vars.desc:setText(str)
	if info.level == 1 then
		self._layout.vars.tips:hide()
	else
		self._layout.vars.tips:show()
		self._layout.vars.tips:setText(string.format("修习后，等级在[1~%s]之间随机",info.level))
	end
	self._layout.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_suicong_spirits[info.id][1].icon))
	self._layout.vars.name:setText(i3k_db_suicong_spirits[info.id][1].name)
	local widgets = self._layout.vars
	local secondTextNode, secondItemCount, secondItemNeedCount
	for i=1, 3 do
		local itemId
		if i < 3 then
			itemId = cfg[self._id]["studySpiritID" .. i]
		else
			itemId = cfg[self._id].learnSkillReplaceItem2Id
		end
		if itemId ~= 0 then
			widgets["name"..i]:setText(g_i3k_db.i3k_db_get_common_item_name(itemId))
			widgets["name"..i]:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(itemId)))
			widgets["icon"..i]:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemId,i3k_game_context:IsFemaleRole()))
			widgets["bg"..i]:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemId))
			-- widget.suo:setVisible(g_i3k_db.i3k_db_get_consume_lock_visible(itemId))
			local haveCount = g_i3k_game_context:GetCommonItemCanUseCount(itemId)
			if i == 2 then
				secondTextNode = widgets["count"..i]
				secondItemCount = haveCount
				secondItemNeedCount = cfg[self._id]["studySpiritCount" .. i]
			end
			if i == 3 then
				local color = g_i3k_get_cond_color(haveCount + secondItemCount >= secondItemNeedCount)
				widgets["count"..i]:setText(haveCount)
				widgets["count"..i]:setTextColor(color)
				secondTextNode:setTextColor(color)
			else
				widgets["count"..i]:setTextColor(g_i3k_get_cond_color(haveCount >= cfg[self._id]["studySpiritCount" .. i]))
				widgets["count"..i]:setText(haveCount .. "/" .. cfg[self._id]["studySpiritCount" .. i])
			end
			widgets["bt"..i]:onClick(self, self.onTips, itemId)
		end
	end
	self._layout.vars.up_btn:onClick(self, self.toStudyBtn, {id = info.id, level = info.level})
end

function wnd_suicongStudySpirit:toStudyBtn(sender, data)
	local cfg = i3k_db_mercenaries[self._id]
	local isEnough = true
	local tmp = {}
	local part2Items = {}
	for i=1, 2 do
		local itemId = cfg["studySpiritID" .. i]
		local needCount =  cfg["studySpiritCount" .. i]
		if itemId ~= 0 then
			local haveCount = 0
			if g_i3k_db.i3k_db_get_common_item_cfg(itemId).type == UseItemPetBook then
				haveCount = g_i3k_game_context:getPetBooksWithId(itemId)
			else
				haveCount = g_i3k_game_context:GetCommonItemCanUseCount(itemId)
			end
			if i == 1 then
				if haveCount >= needCount then
					tmp[itemId] = needCount
				else
					isEnough = false
					break
				end
			elseif i == 2 then
				local commonId = i3k_db_mercenaries[self._id].learnSkillReplaceItem2Id
				local commonHave = g_i3k_game_context:GetCommonItemCanUseCount(commonId)
				if haveCount + commonHave < needCount then
					isEnough = false
					break
				else
					tmp[itemId] = math.min(haveCount, needCount)
					part2Items[itemId] = tmp[itemId] ~= 0 and tmp[itemId] or nil
					tmp[commonId] = math.max(0, needCount - haveCount)
					part2Items[commonId] = tmp[commonId] ~= 0 and tmp[commonId] or nil
				end
			end
		end
	end
	if isEnough then
		local fun = function ()
			for k,v in pairs(tmp) do
				if g_i3k_db.i3k_db_get_common_item_cfg(k).type == UseItemPetBook then
					g_i3k_game_context:subPetBook(k, v)
				else
					g_i3k_game_context:UseCommonItem(k, v)
				end
			end
		end
		i3k_sbean.petspirit_learn(self._id, self._index, data.id, data.level, fun, self._spiritID, part2Items)
	else
		g_i3k_ui_mgr:PopupTipMessage(string.format("材料不足，修习失败"))
	end
end

function wnd_suicongStudySpirit:updateSelect()
	local allRoot = self.scroll:getAllChildren()
	for i, e in pairs(allRoot) do
		e.vars.select:setImage(g_i3k_db.i3k_db_get_icon_path(2987))
	end
end

function wnd_suicongStudySpirit:onTips(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

function wnd_create(layout)
	local wnd = wnd_suicongStudySpirit.new()
		wnd:create(layout)
	return wnd
end
