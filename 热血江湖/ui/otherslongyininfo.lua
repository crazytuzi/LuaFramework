module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_othersLongYinInfo = i3k_class("wnd_othersLongYinInfo", ui.wnd_base)

local LAYER_ZBTIPST3 = "ui/widgets/zbtipst3"
local LAYER_ZBTIPST5 = "ui/widgets/zbtipst5"
local LAYER_ZBTIPST = "ui/widgets/zbtipst"
local LAYER_LYL	= "ui/widgets/lyt1"

local base_attribute_desc = "基础属性"
local add_attribute_desc = "洗练属性"
local GRADE_DESC = {"一", "二", "三", "四", "五", "六", "七", "八", "九", "十", "十一", "十二"}

function wnd_othersLongYinInfo:ctor()

end

function wnd_othersLongYinInfo:configure()

	local widgets = self._layout.vars
	widgets.globel_btn:onClick(self, self.onClose)

	self.equip_name = widgets.equip_name
	self.equip_bg = widgets.equip_bg
	self.equip_icon = widgets.equip_icon
	self.power_value = widgets.power_value
	self.level_label = widgets.level_label
	self.scroll = widgets.scroll
	self.get_label = widgets.get_label
end
function wnd_othersLongYinInfo:onShowData(grade, skills, roleType, sealAwaken, fuling)
	local info = g_i3k_db.i3k_db_LongYin_arg
	local UpLvlcfg = g_i3k_db.i3k_db_LongYin_UpLvl
	self.equip_name:setText(info.args.itemName)
	self.equip_icon:setImage(g_i3k_db.i3k_db_get_icon_path(g_i3k_game_context:GetLongYinIronForGrade(grade)))


	local quality = g_i3k_game_context:GetLongYinQuality(grade)
	self.equip_name:setTextColor(g_i3k_get_color_by_rank(quality or 1))
	self.equip_bg:setImage(g_i3k_get_icon_frame_path_by_rank(quality))
	self.level_label:setText(GRADE_DESC[grade] .. "阶")
	local desTips = require(LAYER_ZBTIPST3)()
	desTips.vars.desc:setText(base_attribute_desc)
	self.scroll:addItem(desTips)

	local propertyId = {}
	local propertyCount = {}
	local percent = self:getBanPercent(sealAwaken.rank - 1)
	for i=1, 6 do
		propertyId[i] = UpLvlcfg[grade]["propertyId" .. i]
		propertyCount[i] = UpLvlcfg[grade]["propertyCount" .. i]
	end
	for k=1,#propertyId do
		if propertyId[k] ~= 0 then
			local _layer = require(LAYER_ZBTIPST)()
			local widget = _layer.vars
			local _t = i3k_db_prop_id[propertyId[k]]
			widget.desc:setText(i3k_db_prop_id[propertyId[k]].desc.."：")
			local attr = ""
			if percent ~= 0 then
				attr = " + "..i3k_get_prop_show(propertyId[k], propertyCount[k] * percent)
			end
			widget.value:setText(i3k_get_prop_show(propertyId[k],propertyCount[k])..attr)
			self.scroll:addItem(_layer)
		end
	end
	local allProp = self:addBanPropToScroll(sealAwaken, grade)

	local power = g_i3k_game_context:otherLongyinSkills(roleType, skills)
	local propertyTb = {}
	for i=1,#propertyId do
		propertyTb[propertyId[i]] = propertyCount[i]
	end
	power = power + g_i3k_db.i3k_db_get_battle_power(propertyTb) + g_i3k_db.i3k_db_get_battle_power(allProp)
	local fulingProp = g_i3k_db.i3k_db_get_other_fuling_props(fuling)
	power = power + g_i3k_db.i3k_db_get_battle_power(fulingProp)
	self.power_value:setText(power)
	self.get_label:setText(i3k_get_string(434,i3k_db_LongYin_arg.openNeed.needLvl))

	self:addFulingPropToScroll(fuling)

	if grade < 3 then
		return
	end

	local desTips2 = require(LAYER_ZBTIPST3)()
	desTips2.vars.desc:setText(add_attribute_desc)
	self.scroll:addItem(desTips2)

	for k,v in pairs(skills) do
		local _layer = require(LAYER_ZBTIPST)()
		local widget = _layer.vars

		widget.desc:setText(i3k_db_skills[k].name)
		--widget.desc:setTextColor("ffffd200")
		widget.value:setText("+" .. v .. "级")
		--widget.value:setTextColor("ff3be400")

		self.scroll:addItem(_layer)
	end


end


function wnd_othersLongYinInfo:addBanPropToScroll(sealAwaken, grade)
	local prop, allProp = self:refreshAwakenBanProp(sealAwaken, grade)
	local devide = require(LAYER_ZBTIPST3)()
	devide.vars.desc:setText("禁制解封属性")
	local count = 0
	for k, v in pairs(prop) do
		count = count + 1
	end
	if count > 0 then
		self.scroll:addItem(devide)
	end

	for k, v in pairs(prop)do
		local _layer = require(LAYER_ZBTIPST)()
		local widget = _layer.vars
		widget.desc:setText(i3k_db_prop_id[k].desc..":")
		-- widget.iron:setImage(g_i3k_db.i3k_db_get_property_icon_path(k))
		widget.value:setText(i3k_get_prop_show(k ,v))
		self.scroll:addItem(_layer)
	end
	return allProp
end

function wnd_othersLongYinInfo:refreshAwakenBanProp(sealAwaken, grade)
	self:clearAwakenBanProp()
	local awaken = sealAwaken
	local curRank = awaken.rank - 1
	-- 先加上前面解封过的层的属性
	for i = 1, curRank do
		-- 每层禁制属性
		local cfg = g_i3k_db.i3k_db_get_longyin_ban(i)
		for k , v in ipairs(cfg.items) do
			local fengyinCfg = g_i3k_db.i3k_db_get_longyin_lock(v)
			if fengyinCfg.propValue ~= 0 then
				self:addAwakenBanProp(fengyinCfg.propID, fengyinCfg.propValue)
			end
		end
		-- 每层祝福属性
		for k, v in ipairs(cfg.wish) do
			if v.value ~= 0 then
				self:addAwakenBanProp(v.type, v.value)
			end
		end
	end
	-- 再加上当前层已经的属性
	for k, v in pairs(awaken.awaken) do
		local fengyinCfg = g_i3k_db.i3k_db_get_longyin_lock(k)
		if fengyinCfg.propValue ~= 0 then
			self:addAwakenBanProp(fengyinCfg.propID, fengyinCfg.propValue)
		end
	end
	local allProp = self:refreshAwakenProp(sealAwaken, grade)
	return self:getAwakenBanProp(), allProp
end

function wnd_othersLongYinInfo:clearAwakenBanProp()
	self.clientBanProp = nil
end
function wnd_othersLongYinInfo:addAwakenBanProp(key, value)
	if not self.clientBanProp then
		self.clientBanProp = {}
	end
	if not self.clientBanProp[key] then
		self.clientBanProp[key] = value
	else
		self.clientBanProp[key] = self.clientBanProp[key] + value
	end
end
function wnd_othersLongYinInfo:getAwakenBanProp()
	return self.clientBanProp or {}
end

------总属性  实际增加的属性----
function wnd_othersLongYinInfo:refreshAwakenProp(sealAwaken, grade)
	self:clearAwakenProp()
	local prop = self:getAwakenBanProp()
	for k, v in pairs(prop) do
		self:addAwakenProp(k, v)
	end
	-- 在加上百分比的属性
	local lvl = grade -- g_i3k_game_context:GetIsHeChengLongYin()
	local rank = sealAwaken.rank - 1
	local totalPercent = 0
	for i = 1, rank do
		local cfg = g_i3k_db.i3k_db_get_longyin_ban(i)
		if cfg then
			totalPercent = totalPercent + cfg.propPercent
		end
	end
	if totalPercent > 0 then
		if lvl ~= 0 then
			for k=1, 6 do
				local propertyId	 = i3k_db_LongYin_UpLvl[lvl]["propertyId" .. k]
				local propertyCount = i3k_db_LongYin_UpLvl[lvl]["propertyCount" .. k]
				if propertyCount ~= 0 then
					self:addAwakenProp(propertyId, propertyCount * totalPercent / 10000)
				end
			end
		end
	end
	return self:getAwakenProp()
end
function wnd_othersLongYinInfo:clearAwakenProp()
	self.clientProp = nil
end
function wnd_othersLongYinInfo:addAwakenProp(key, value)
	if not self.clientProp then
		self.clientProp = {}
	end
	if not self.clientProp[key] then
		self.clientProp[key] = value
	else
		self.clientProp[key] = self.clientProp[key] + value
	end
end
-- 获取属性
function wnd_othersLongYinInfo:getAwakenProp()
	return self.clientProp or {}
end

---------------

function wnd_othersLongYinInfo:getBanPercent(rank)
	local percent = 0
	if i3k_db_LongYin_ban[rank] then
		for i = 1, rank do
			percent = i3k_db_LongYin_ban[i].propPercent / 10000 + percent
		end
	end
	return percent
end

-- TODO
function wnd_othersLongYinInfo:addFulingPropToScroll(fuling)
	local prop = g_i3k_db.i3k_db_get_other_fuling_props(fuling)
	local devide = require(LAYER_ZBTIPST3)()
	devide.vars.desc:setText("附灵属性")
	local count = 0
	for k, v in pairs(prop) do
		count = count + 1
	end
	if count > 0 then
		self.scroll:addItem(devide)
	end
	local sortProps = g_i3k_db.i3k_db_sort_props(prop)

	for k, v in ipairs(sortProps)do
		if v.value ~= 0 then
			local _layer = require(LAYER_LYL)()
			local widget = _layer.vars
			widget.iron:setImage(g_i3k_db.i3k_db_get_property_icon_path(v.id)) -- 属性图标
			widget.nameLabel1:setText(i3k_db_prop_id[v.id].desc..":")
			widget.attrLabel1:setText(i3k_get_prop_show(v.id, v.value))
			self.scroll:addItem(_layer)
		end
	end
end

function wnd_othersLongYinInfo:refresh(data)
	local grade = data.grade
	local skills = data.skills
	local roleType = data.roleType
	local sealAwaken = data.sealAwaken
	local fuling = data.fuling
	self:onShowData(grade, skills, roleType, sealAwaken, fuling)
end

function wnd_othersLongYinInfo:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_OtherLongYinInfo)
end

function wnd_create(layout)
	local wnd = wnd_othersLongYinInfo.new();
		wnd:create(layout);
	return wnd;
end
