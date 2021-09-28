-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_familyDonate = i3k_class("wnd_familyDonate", ui.wnd_base)

local TYPEITEM = "ui/widgets/bangpaihuzhut1"
local RWEWARDITEM = "ui/widgets/bangpaihuzhut2"

local IMAGE1 = 6832 --正常
local IMAGE2 = 6833 --选中  --6832  6833 6834

local NEIJIADENGJI = 1 --内甲等级
local NEIJIAJIEWEI = 2 --内甲阶位
local FUWENZHIYU = 3 --符文之语阶位
local SHENBINGMANXIN = 4 --神兵满星数量
local QIANNENGDENGJI = 5 --潜能等级
local QILINGJIEWEI = 6 --器灵阶位
local XINGHUNJIEWEI = 7 --星魂阶位
local LIANGJUZHILING = 8 --良驹之灵阶位	

function wnd_familyDonate:ctor()

end

function wnd_familyDonate:configure()
	local weights = self._layout.vars
	weights.close:onClick(self, self.onCloseUI)
	weights.help:onClick(self, self.onHelpBt)	
end

function wnd_familyDonate:onShow()
	
end


function wnd_familyDonate:onHide()

end


function wnd_familyDonate:refresh(familyInfo, roleInfo)
	self:initdonateTypeCondition()
	self:refreshLeftScoll(familyInfo, roleInfo)
end

function wnd_familyDonate:initdonateTypeCondition()
	local baseinfo = i3k_db_basicdonateInfo
	
	self._donateTypeMethod = 
	{
		[NEIJIADENGJI] = function(arg)
			arg = arg == nil and 0 or arg
			local value = g_i3k_game_context:getAllUnderWearMaxLvl()
			return value >= arg, value
		end,
		
		[NEIJIAJIEWEI] = function(arg)
			arg = arg == nil and 0 or arg
			local value = g_i3k_game_context:getAllUnderWearMaxRank()
			return value >= arg, value
		end,
		
		[FUWENZHIYU] = function(arg)
			arg = arg == nil and 0 or arg
			local value = g_i3k_game_context:getruneLangMaxRank()
			return value >= arg, value	
		end,
		
		[SHENBINGMANXIN] = function(arg)
			arg = arg == nil and 0 or arg
			local value = g_i3k_game_context:getMaxStartShenbingNum()
			return value >= arg, value
		end,
		
		[QIANNENGDENGJI] = function(arg)
			arg = arg == nil and 0 or arg
			local value = 0
			
			for _, v in ipairs(baseinfo.potential) do
				local level = g_i3k_game_context:getMeridianPotentialLvl(v)
				
				if value < level then
					value = level
				end
			end
			
			return value >= arg, value	
		end,
		
		[QILINGJIEWEI] = function(arg)
			arg = arg == nil and 0 or arg
			local value = g_i3k_game_context:getMaxQilingLevel()
			return value >= arg, value
		end,
		
		[XINGHUNJIEWEI] = function(arg)
			arg = arg == nil and 0 or arg
			local heriData = g_i3k_game_context:getHeirloomData()
			
			if heriData == nil then
				return false, 0 
			end
			
			local value = heriData.starSpirit.rank
			value = heriData.isOpen == 0 and 0 or value
			return value >= arg, value
		end,
		
		[LIANGJUZHILING] = function(arg)
			arg = arg == nil and 0 or arg
			local value = g_i3k_game_context:getSteedSpiritRank()
			
			if value == nil then
				return false, 0
			end
			
			return value >= arg, value
		end,
	}
end

function wnd_familyDonate:canDonate(item, familyInfo, roleInfo)
	if not familyInfo or not roleInfo or not item then return false end
	
	local roleDonation = roleInfo.hasDonation
	
	if table.nums(roleDonation) >= i3k_db_basicdonateInfo.playerMonthcount then
		return false
	end
		
	if roleDonation[item.id] then
		return false, true -- 第二个参数为已捐赠
	end

	local items = familyInfo.items
	
	for _, v in pairs(items) do
		if v.id == item.id and table.nums(v.donationRoles) >= i3k_db_donateInfo[v.id].monthCount then
			return false
		end
	end
	
	local isCan, value = self._donateTypeMethod[item.type](item.arg)
	
	if not isCan then 
		return isCan
	end
	
	return value
end

--重构捐献数据用来排序
function wnd_familyDonate:restructureScollDonateData(familyInfo, roleInfo)
	local itemsInfo = clone(i3k_db_donateInfo) 
	
	if familyInfo == nil or roleInfo == nil then return itemsInfo end
	
	local fun = function(a, b)
		return a.sort < b.sort
	end
	
	if table.nums(roleInfo.hasDonation) < i3k_db_basicdonateInfo.playerMonthcount then
		local donateTable = {}
		
		for k, v in ipairs(itemsInfo) do
			local info = familyInfo.items[k]
			
			if info ~= nil and v.monthCount <= table.nums(info.donationRoles) then
				v.sort = v.id + 10000
			else
				if self:canDonate(v, familyInfo, roleInfo) then
					v.sort = v.id + 100
				else
					v.sort = v.id + 1000
				end
			end
			
			table.insert(donateTable, v)
		end
		

		table.sort(donateTable, fun)	
		return donateTable
	end

	return itemsInfo
end

function wnd_familyDonate:refreshLeftScoll(familyInfo, roleInfo)
	if not familyInfo or not roleInfo then return end
	local scoll = self._layout.vars.emailScroll	
	local itemsInfo = self:restructureScollDonateData(familyInfo, roleInfo)
	scoll:addChildWithCount(TYPEITEM, 1, #itemsInfo, true)
		
	for i = 1 , #itemsInfo do
		local item = scoll:getChildAtIndex(i)
		local weight = item.vars
		local info = itemsInfo[i]
		weight.name:setText(info.name)
		local value = self:canDonate(itemsInfo[i], familyInfo, roleInfo)
		
		if value then
			weight.red_point:setVisible(true)
		else
			weight.red_point:setVisible(false)
		end
		
		weight.btImage:setImage(g_i3k_db.i3k_db_get_icon_path(IMAGE1))
		weight.select1_btn:onClick(self, self.refreshRightInfo, {iteminfo = itemsInfo[i], fInfo = familyInfo, rInfo = roleInfo, node = item})
	end
	
	self:refreshRightInfo(nil, {iteminfo = itemsInfo[1], fInfo = familyInfo, rInfo = roleInfo, node = scoll:getChildAtIndex(1)})
end

function wnd_familyDonate:refreshRightInfo(sender, info)
	local refreshInfo = info.iteminfo
	local familyinfo = info.fInfo
	local roleinfo = info.rInfo
	local node = info.node
	local weights = self._layout.vars
	weights.honor:setText(roleinfo.honor)
	local arg = refreshInfo.arg
	local isCan, hasDonated = self:canDonate(refreshInfo, familyinfo, roleinfo)
	local falg, value = self._donateTypeMethod[refreshInfo.type](arg)
	local str = string.format(refreshInfo.des, arg)
	local items = familyinfo.items[refreshInfo.id]
	local num = items == nil and 0 or table.nums(items.donationRoles)
	weights.familyDes:setText(string.format("%d/%d", num, refreshInfo.monthCount))
	weights.playerDes:setText(string.format("%d/%d", table.nums(roleinfo.hasDonation), i3k_db_basicdonateInfo.playerMonthcount))
	self:updateButtonState(node)
	self:updateRightScollByInfo(weights.family, refreshInfo.familyreward)
	self:updateRightScollByInfo(weights.player, refreshInfo.donatereward)
	weights.detail:onClick(self, self.onDonateDetail, info)
	weights.getAdditional:onClick(self, self.onDonateBt, info)
	local str2
	
	if not isCan then
		weights.getAdditional:disableWithChildren()
		
		if hasDonated then
			weights.additionalWord:setTextColor(g_i3k_get_green_color())
			str2 = i3k_get_string(1445)
		else
			weights.additionalWord:setTextColor(g_i3k_get_red_color())
			str2 = string.format("(%d/%d)", value, arg)
		end
	else
		weights.getAdditional:enableWithChildren()
		weights.additionalWord:setTextColor(g_i3k_get_green_color())
		str2 = string.format("(%d/%d)", value, arg)
	end
	
	str = str .. str2
	weights.additionalWord:setText(str)
end

function wnd_familyDonate:updateRightScollByInfo(scoll, reward)
	scoll:removeAllChildren(true)
	
	for i = 1, #reward do
		local v = reward[i]
		local node = require(RWEWARDITEM)()		
		local weight = node.vars
		scoll:addItem(node)
		
		if v.id ~= 0 then						
			local itemInfo = g_i3k_db.i3k_db_get_common_item_cfg(v.id)
			
			if itemInfo then
				local grade = itemInfo.rank
				weight.reward:setImage(g_i3k_get_icon_frame_path_by_rank(grade))
				weight.icon:setImage(i3k_db_icons[itemInfo.icon].path)
				weight.iconbt:onClick(self, self.showItemTips, v.id)
				local shwoNum = math.abs(v.id) == g_BASE_ITEM_COIN and i3k_get_num_to_show(v.count) or v.count
				weight.num:setText("x"..shwoNum)
				weight.suo:setVisible(v.id > 0)
				
			end
		else
			weight.root:hide()
		end	
	end	
end

function wnd_familyDonate:updateButtonState(item)
	if not item then return end
	local weight = item.vars
	local scoll = self._layout.vars.emailScroll	
	local items = scoll:getAllChildren()
	
	if self._current_bt and self._current_bt_Original_Image then
		for _,v in ipairs(items) do
			if v == self._current_bt then
				self._current_bt.vars.btImage:setImage(self._current_bt_Original_Image)
			end
		end
	end
	
	self._current_bt_Original_Image = weight.btImage:getImage()
	weight.btImage:setImage(g_i3k_db.i3k_db_get_icon_path(IMAGE2))
	self._current_bt = item
end

function wnd_familyDonate:onDonateDetail(sender, info)
	if not info then return end
	local iteminfo = info.iteminfo
	local familyInfo = info.fInfo
	local donateData = familyInfo.items[iteminfo.id]
	
	if donateData == nil or donateData.donationRoles == nil or table.nums(donateData.donationRoles) == 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1446))
		return
	end
	
	i3k_sbean.sect_donate_roles(iteminfo.id)
end

function wnd_familyDonate:onDonateBt(sender, info)
	if not info then return end
	
	local reward = info.iteminfo.donatereward
	local items = {}
	
	for _, v in ipairs(reward) do
		local id = v.id
		
		if items[id] ~= nil then
			items[id] = items[id] + v.count
		else
			items[id] = v.count
		end
	end
	
	local isEnough = g_i3k_game_context:IsBagEnough(items)
	
	if not isEnough then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1447))
		return

	end
	
	local fun = (function(ok)
		if ok then
			i3k_sbean.sect_donate_help(info)
		end
	end)
		
	g_i3k_ui_mgr:ShowMidMessageBox2(i3k_get_string(1448), fun)--i3k_get_string(15199, needDiamond)
end

function wnd_familyDonate:showItemTips(sender, itemID)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemID)
end

function wnd_familyDonate:onHelpBt()
	g_i3k_ui_mgr:ShowHelp(i3k_get_string(1443))
end

function wnd_create(layout, ...)
	local wnd = wnd_familyDonate.new();
	wnd:create(layout, ...)

	return wnd
end
