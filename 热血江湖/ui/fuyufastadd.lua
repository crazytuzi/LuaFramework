-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_fuyuFastAdd = i3k_class("wnd_fuyuFastAdd", ui.wnd_base)

function wnd_fuyuFastAdd:ctor()
	self.fuYuId = 0
	self.runeId = 0
	self.curCount = 0
	self.maxCount = 0
	self.logicMaxCount = 0   --最大可用的符文数量
end

function wnd_fuyuFastAdd:configure()
	local widgets = self._layout.vars
	self.jia 		= widgets.jia   				--增加按钮
	self.jian 		= widgets.jian 					--减少按钮
	self.max 		= widgets.max 					--最大按钮
	self.use_count 	= widgets.use_count				--使用数量
	self.title 		= widgets.title  				--标题
	self.use_count:setInputMode(EDITBOX_INPUT_MODE_NUMERIC)
	self.use_count:addEventListener(function(eventType)
		if eventType == "ended" then
		    local str = tonumber(self.use_count:getText()) or 1
		    if  str > self.logicMaxCount then
		     	str = self.logicMaxCount
		    end
			if str > g_edit_box_max then
				str = g_edit_box_max
			end
			if str < 1 then
				str = 1
			end
		    self.use_count:setText(str)
	       	self.curCount = str
	       	self:updateNum()
	    end
	end)
	self.times_desc = widgets.times_desc 			--获得经验文本
	self.ok 		= widgets.ok
	self.cancel 	= widgets.cancel

	self.jia:onClick(self, self.OnAddClick)
	self.jian:onClick(self, self.OnJianClick)
	self.max:onClick(self, self.OnMaxClick)
	self.ok:onClick(self, self.OnOkBtnClick)
	self.cancel:onClick(self, self.onCloseUI)
end

function wnd_fuyuFastAdd:refresh(data)
	self.ruenId = data.runeId
	self.fuYuId = data.fuyuId
	self.curCount = data.curCount
	self.logicMaxCount = data.curCount
	self.maxCount = data.maxCount
	self:updateNum()
	local name = i3k_db_under_wear_rune[self.ruenId].runeName
	self.title:setText(i3k_get_string(18302, name))
end

function wnd_fuyuFastAdd:updateNum()
	self.use_count:setText(self.curCount)
	local addExp = i3k_db_under_wear_rune[self.ruenId].zhuDingExp * self.curCount
	self.times_desc:setText(i3k_get_string(18303, addExp))
end

function wnd_fuyuFastAdd:OnAddClick()
	self:getCurNum()
	self.curCount =  self.curCount + 1
	self.curCount = self.curCount >= self.logicMaxCount and self.logicMaxCount or  self.curCount
	self:updateNum()
end

function wnd_fuyuFastAdd:OnJianClick()
	self:getCurNum()
	self.curCount =  self.curCount - 1
	self.curCount = self.curCount <= 1 and 1 or self.curCount
	self:updateNum()
end

function wnd_fuyuFastAdd:OnMaxClick()
	self.curCount = self.logicMaxCount
	self:updateNum()
end

function wnd_fuyuFastAdd:OnOkBtnClick(sender)
	self:getCurNum()
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_FuYuZhuDing, "FuncByItemPinZhi", self.ruenId, self.curCount)
 	--i3k_sbean.useRuneAddExpReq(self.fuYuId, self.ruenId, self.curCount)
 	g_i3k_ui_mgr:CloseUI(eUIID_FuYuFastAdd)
end

function wnd_fuyuFastAdd:getCurNum()
	local message = self.use_count:getText()
	self.curCount = tonumber(message)
end

function wnd_create(layout)
	local wnd = wnd_fuyuFastAdd.new()
	wnd:create(layout)
	return wnd
end
