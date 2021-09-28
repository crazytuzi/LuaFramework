-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_buff_drug_tips = i3k_class("wnd_buff_drug_tips", ui.wnd_base)
local LAYER_BUFFTIPS3T = "ui/widgets/bufftips3t"

function wnd_buff_drug_tips:ctor()
	self._sc = nil
	self._timeTick = 0
end

function wnd_buff_drug_tips:configure()
	self.scroll = self._layout.vars.scroll
	self.bg = self._layout.vars.bg
	self.root = self._layout.vars.root
end

function wnd_buff_drug_tips:onShow()
	
end

function wnd_buff_drug_tips:refresh(isOther, pos, buffType)
	if self._sc then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._sc)
		self._sc = nil
		self._timeTick = 0
	end

	local posX = pos.x - 20
	local posY = isOther and pos.y - 20 or pos.y + 20
	self.root:setPosition(posX, posY)

	self.scroll:stateToNoSlip()
	self.scroll:removeAllChildren()
	
	if buffType == g_NORMAL_BUFF_DRUG then
		self:setNormalScrollData(isOther)
	elseif buffType == g_FIGHT_LINE_BUFF_DRUG then
		self:setFightLineScrollData()
	end

	local totalHeight = 0  --scroll的长度
	local offset = 17
	for _, v in ipairs(self.scroll:getAllChildren()) do
		local childHeight = v.rootVar:getSizeInScroll(self.scroll).height
		totalHeight = totalHeight + childHeight

		local scrollContainerSize = self.scroll:getContainerSize()
		local width = scrollContainerSize.width / 2
		local height = scrollContainerSize.height
		local nheight = isOther and height - (totalHeight - offset) or totalHeight - offset
		v.vars.root:setPositionInScroll(self.scroll, width, nheight)
	end

	local bgwidth = self.bg:getContentSize().width
	local bgheight = self.bg:getContentSize().height

	totalHeight = totalHeight + 10 < bgheight and totalHeight + 10 or bgheight
	self.bg:setContentSize(bgwidth, totalHeight)

	self._sc = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(dTime)
		self._timeTick = self._timeTick + dTime
		if self._timeTick >= 3.0 then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._sc)
			if isOther then
				g_i3k_ui_mgr:CloseUI(eUIID_OtherBuffDrugTips)
			else
				g_i3k_ui_mgr:CloseUI(eUIID_BuffDrugTips)
			end
			
		end
	end, 0.1, false)
end

function wnd_buff_drug_tips:setNormalScrollData(isOther)
	local buffDrug = self:GetMyBuffDrugData(isOther)
	for _, v in ipairs(buffDrug) do
		local buffCfg = i3k_db_buff[v.id]
		local buffName = buffCfg.note

		local widget = require(LAYER_BUFFTIPS3T)()
		widget.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(buffCfg.buffDrugIcon))
		if isOther then
			widget.vars.des:setText(string.format("<c=FFE9B86D>%s</c>", buffName))
		else
			local remainTime = self:getRemainTime(v.endTime)
			widget.vars.des:setText(i3k_get_string(16145, buffName, remainTime))
		end

		self.scroll:addItem(widget)
	end
end

function wnd_buff_drug_tips:setFightLineScrollData()
	local buffDrug = self:GetMyFightLineBuffDrugData()
	for _, v in ipairs(buffDrug) do
		local buffCfg = i3k_db_fight_line_buff[v.id]
		local buffName = buffCfg.note
		local affectType = buffCfg.affectType
		local myAffectValue = v.affectValue

		local widget = require(LAYER_BUFFTIPS3T)()

		widget.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(buffCfg.validIcon))
		if g_i3k_game_context:GetCurrentLine() ~= g_WORLD_KILL_LINE then
			widget.vars.icon:disableWithChildren()
		end

		if affectType == g_FIGHT_LINE_CONTINUE_TIME then
			local remainTime = self:getRemainTime(v.endTime)
			widget.vars.des:setText(i3k_get_string(16145, string.format("%s%s%%", buffName, myAffectValue*0.01), remainTime))
		elseif affectType == g_FIGHT_LINE_KILL_MOSNTER_COUNT then
			widget.vars.des:setText(i3k_get_string(16145, string.format("%s%s%%", buffName, myAffectValue*0.01), "剩余"..v.value.."只"))
		end

		self.scroll:addItem(widget)
	end
end

function wnd_buff_drug_tips:GetMyBuffDrugData(isOther)
	local sortedBuff = {}  --排序过后的buff药
	local validBuffDrug = g_i3k_game_context:GetValidBuffDrugData(isOther)	--当前有效buff药
	
	for _, v in pairs(validBuffDrug) do
		table.insert(sortedBuff, {id = v.id, endTime = v.endTime})
	end
	table.sort(sortedBuff, function(a, b)
		if isOther then
			return a.id < b.id
		else
			return a.id > b.id
		end
	end)

	return sortedBuff
end

function wnd_buff_drug_tips:GetMyFightLineBuffDrugData()
	local sortedBuff = {}  --排序过后的buff药
	local validBuffDrug = g_i3k_game_context:GetFightLineValidBuffDrugData()	--当前有效buff药
	
	for _, v in pairs(validBuffDrug) do
		table.insert(sortedBuff, {id = v.id, endTime = v.endTime, value = v.value, affectValue = v.affectValue})
	end
	table.sort(sortedBuff, function(a, b)
		return a.id > b.id
	end)

	return sortedBuff
end

function wnd_buff_drug_tips:getRemainTime(endTime)
	local timeNow = i3k_game_get_time()
	local remainTime = endTime - timeNow
	if remainTime <= 0 then
		return string.format("%d秒", 0)
	end
	if remainTime < 60 then --小于1分钟
		local sec = remainTime
		return string.format("%d秒", sec)
	elseif remainTime < 60*60 then --小于1小时
		local min =  math.floor(remainTime/60)
		return string.format("%d分", min)
	elseif remainTime < 60*60*24 then --小于1天
		local hour =  math.floor(remainTime/60/60)
		local min =  math.floor(remainTime/60) - hour * 60
		return string.format("%d小时%d分", hour, min)
	else
		local day =  math.floor(remainTime/60/60/24)
		return string.format("%d天", day)
	end
end

function wnd_buff_drug_tips:onHide()
	if self._sc then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._sc)
		self._sc = nil
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_buff_drug_tips.new()
	wnd:create(layout, ...)
	return wnd;
end
