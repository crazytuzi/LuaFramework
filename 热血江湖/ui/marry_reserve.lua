-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
local NODE_HLYYT = "ui/widgets/hlyyt"
-------------------------------------------------------
wnd_marry_reserve = i3k_class("wnd_marry_reserve", ui.wnd_base)

local timeCount = 60	--进入则刷新

function wnd_marry_reserve:ctor()
	self._lineType = nil
end

function wnd_marry_reserve:configure()
	local widgets = self._layout.vars
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
	for i=1, 4 do
		self._layout.vars["line_btn"..i]:onClick(self, self.updateScroll, i)
		self._layout.vars["line_name"..i]:setText(i3k_get_string(i3k_db_marry_line[i].lineTipsId))
	end
	self.marryDesc = widgets.marryDesc
end

function wnd_marry_reserve:refresh()
	--self:setData()
	self:updateScroll()
	self.marryDesc:setText(i3k_get_string(3031))
end

function wnd_marry_reserve:setData()
	local cout = i3k_db_marry_rules.WenddingDuration + i3k_db_marry_rules.paradeDuration
	local needTime = os.date("%M", cout)
	for i=1, 3 do
		local itemID = {}
		local itemCount = {}
		for k=1, 2 do
			if i3k_db_marry_grade[i].marryUsedMoney ~= 0 then
				itemID[1] = g_BASE_ITEM_COIN
				itemCount[1] = i3k_db_marry_grade[i].marryUsedMoney
			end
			if i3k_db_marry_grade[i].marryUsedWing ~= 0 then
				itemID[1] = g_BASE_ITEM_DIAMOND
				itemCount[1] = i3k_db_marry_grade[i].marryUsedWing
			end
			if i3k_db_marry_grade[i].marryUsedPorpId ~= 0 then
				itemID[2] = i3k_db_marry_grade[i].marryUsedPorpId
				itemCount[2] = i3k_db_marry_grade[i].marryUsedPorpNum
			end
			if itemID[k] and itemID[k] ~= 0 then
				self._layout.vars["icon"..i..k]:show()
				self._layout.vars["icon"..i..k]:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemID[k],i3k_game_context:IsFemaleRole()))
				self._layout.vars["count"..i..k]:setText(itemCount[k])
			else
				self._layout.vars["icon"..i..k]:hide()
			end
		end
		local str = i == 1 and "0分" or (needTime .. "分")
		self._layout.vars["time"..i]:setText(str)
	end
end

function wnd_marry_reserve:onUpdate(dTime)
	timeCount = timeCount + dTime
	if timeCount > 60 then
		timeCount = 1
		self:UpdateLable()
	end
	
end

function wnd_marry_reserve:updateScroll(sender, index)
	self:refreshAllSprite()
	self._lineType = index or 1
	for i=1, 4 do
		if i==self._lineType then
			self._layout.vars["line_btn"..i]:stateToPressed()
		else
			self._layout.vars["line_btn"..i]:stateToNormal()
		end
	end
	self._layout.vars.scroll:removeAllChildren()
	local data = g_i3k_game_context:getMarryReserveData()
	for i,e in ipairs(i3k_db_marry_reserve) do
		local layer = require(NODE_HLYYT)()
		local widget = layer.vars
		local needTime = string.split(e.marryTime, ";")
		widget.moneyIcon:setImage(g_i3k_db.i3k_db_get_base_item_cfg(e.moneyType).icon)
		widget.moneyCount:setText("x"..e.moneyCount)
		widget.time:setText(needTime[1] .. "~" .. needTime[2])
		widget.btn:onClick(self, self.selectBtn, {timeIndex = i, itemId = e.moneyType, itemCount = e.moneyCount})
		self._layout.vars.scroll:addItem(layer)
	end
	self:UpdateLable(true)
end

function wnd_marry_reserve:UpdateLable(isFirst)
	local isJump = true
	local data = g_i3k_game_context:getMarryReserveData()
	local allLayer = self._layout.vars.scroll:getAllChildren()
	if next(allLayer) then
		for i,e in ipairs(allLayer) do
			local isShow = true
			e.vars.btnIcon:show()
			e.vars.isShow:hide()
			e.vars.btn:show()
			e.vars.label1:hide()
			e.vars.tHide:hide()
			e.vars.tShow:show()
			e.vars.label2:show()
			e.vars.label3:hide()
			e.vars.mName:hide()
			e.vars.gName:hide()
			local serverTime = i3k_integer(i3k_game_get_time())
			local nowM = os.date("%M", g_i3k_get_GMTtime(serverTime))
			local nowH = os.date("%H", g_i3k_get_GMTtime(serverTime))
			local time = string.split(i3k_db_marry_reserve[i].marryTime, ";")
			local needTime1 = string.split(time[1], ":")
			local needTime2 = string.split(time[2], ":")
			if tonumber(needTime1[1]) < tonumber(nowH)then
				self:hideAllsprite(e)
				e.vars.label1:show()
				e.vars.tHide:show()
				isShow = false
			elseif tonumber(needTime1[1]) == tonumber(nowH) and tonumber(needTime1[2]) < tonumber(nowM) then
				self:hideAllsprite(e)
				e.vars.label1:show()
				e.vars.tHide:show()
				isShow = false
			end
			if tonumber(needTime1[1]) < tonumber(nowH) and tonumber(needTime2[1]) > tonumber(nowH) then
				e.isInTime = true
			elseif tonumber(needTime1[1]) == tonumber(nowH) and tonumber(needTime1[2]) < tonumber(nowM) then
				e.isInTime = true
			end
			if next(data) and isShow then
				for _,v in ipairs(data) do
					if i == v.timeIndex and self._lineType == v.line then
						self:hideAllsprite(e)
						if v.manId == g_i3k_game_context:GetRoleId() or  v.ladyId == g_i3k_game_context:GetRoleId() then
							e.vars.isShow:show()
							e.vars.btnIcon:show()
							e.vars.tShow:show()
						else
							e.vars.tHide:show()
							e.vars.label3:show()
						end
						e.vars.mName:show()
						e.vars.gName:show()
						e.vars.mName:setText(v.manName)
						e.vars.gName:setText(v.ladyName)
						isShow = true
					else
						isShow = false
					end
				end
			end
			for _,v in ipairs(data) do
				if i == v.timeIndex and self._lineType == v.line then
					if e.isInTime then
						e.vars.tShow:show()
						e.vars.label1:hide()
					end
					e.vars.mName:show()
					e.vars.gName:show()
					e.vars.mName:setText(v.manName)
					e.vars.gName:setText(v.ladyName)
				end
			end
			for _,v in ipairs(data) do
				if i == v.timeIndex and (v.manId == g_i3k_game_context:GetRoleId() or  v.ladyId == g_i3k_game_context:GetRoleId()) then
					local str = string.format("我的预约时段：%s~%s",time[1],time[2])
					self._layout.vars.desc:setText(str)
					break
				end
			end
			if isFirst and isShow and isJump then
				self._layout.vars.scroll:jumpToChildWithIndex(i)
				isJump = false
			end
		end
	end
end

function wnd_marry_reserve:hideAllsprite(e)
	e.vars.mName:hide()
	e.vars.gName:hide()
	e.vars.label3:hide()
	e.vars.label2:hide()
	e.vars.label1:hide()
	e.vars.btnIcon:hide()
	e.vars.isShow:hide()
	e.vars.btn:hide()
	e.vars.tShow:hide()
	e.vars.tHide:hide()
end

function wnd_marry_reserve:selectBtn(sender, data)
	local count = g_i3k_game_context:GetCommonItemCanUseCount(data.itemId)
	if count < data.itemCount then
		g_i3k_ui_mgr:PopupTipMessage("元宝所需不足，预约失败")
		return
	end
	local callback = function ()
		g_i3k_game_context:UseCommonItem(data.itemId, data.itemCount)
	end
	local fun = function (isOk)
		if isOk then
			i3k_sbean.add_marriage_bespeak(self._lineType, data.timeIndex, callback)
		end
	end
	local time = string.split(i3k_db_marry_reserve[data.timeIndex].marryTime, ";")
	local s = time[1].."~"..time[2]
	local str = i3k_get_string(842, s, data.itemCount)
	g_i3k_ui_mgr:ShowMessageBox2(str, fun)
end

function wnd_marry_reserve:refreshAllSprite()
	timeCount = 60
end

function wnd_create(layout, ...)
	local wnd = wnd_marry_reserve.new()
	wnd:create(layout, ...)
	return wnd;
end
