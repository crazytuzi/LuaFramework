-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_buff_drug_remove = i3k_class("wnd_buff_drug_remove", ui.wnd_base)
local LAYER_BUFFSCT = "ui/widgets/buffsct"

function wnd_buff_drug_remove:ctor()
	self._buffID = 0
	self._buffType = g_NORMAL_BUFF_DRUG  --1普通buff药 2争夺线buff药
end

function wnd_buff_drug_remove:configure()
	self._layout.vars.close_btn:onClick(self, self.onCloseUI)

	self.buff_scroll = self._layout.vars.buff_scroll
	self.des = self._layout.vars.des
	self.remove_btn = self._layout.vars.remove_btn
	self.remove_btn:onClick(self, self.onRemoveBtn)
end

function wnd_buff_drug_remove:refresh()
	local validBuff = self:getAllValidBuffDrug()

	self.buff_scroll:removeAllChildren()
	self.remove_btn:disableWithChildren()

	for i, v in ipairs(validBuff) do
		local buffCfg = i3k_db_buff[v.id]
		local buffName = buffCfg.note

		local widget = require(LAYER_BUFFSCT)()
		widget.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(buffCfg.buffDrugIcon))
		local remainTime = self:getRemainTime(v.endTime)
		widget.vars.des:setText(i3k_get_string(16148, buffName, remainTime))
		widget.vars.selected_img:hide()

		widget.vars.select_btn:onClick(self, self.onSelectBuff, {buffID = v.id, index = i})

		self.buff_scroll:addItem(widget)
	end
end

function wnd_buff_drug_remove:getAllValidBuffDrug()
	local validBuff = {} --vetor
	local allBuffDrug = g_i3k_game_context:GetValidBuffDrugData()
	for _, v in pairs(allBuffDrug) do
		table.insert(validBuff, {id = v.id, endTime = v.endTime})
	end
	table.sort(validBuff, function(a, b)
		return a.id < b.id
	end)
	return validBuff
end

function wnd_buff_drug_remove:getRemainTime(endTime)
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

function wnd_buff_drug_remove:onSelectBuff(sender, data)
	self._buffID = data.buffID

	for i, v in ipairs(self.buff_scroll:getAllChildren()) do
		v.vars.selected_img:setVisible(data.index == i)
	end

	self.remove_btn:enableWithChildren()
end

function wnd_buff_drug_remove:onRemoveBtn(sender)
	if self._buffID == 0 then
		return g_i3k_ui_mgr:PopupTipMessage("尚未选中任何buff")
	end

	local desc = i3k_get_string(16147)
	local fun = (function(ok)
		if ok then
			i3k_sbean.buffdrug_remove_req(self._buffID, self._buffType)
		end
	end)
	g_i3k_ui_mgr:ShowMessageBox2(desc, fun)
end

function wnd_create(layout, ...)
	local wnd = wnd_buff_drug_remove.new()
	wnd:create(layout, ...)
	return wnd;
end
