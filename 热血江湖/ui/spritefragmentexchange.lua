-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_spriteFragmentExchange = i3k_class("wnd_spriteFragmentExchange", ui.wnd_base)

local WIGETS_FRAG = "ui/widgets/gdyljmt1"
local COST_COUNT = i3k_db_catch_spirit_base.spiritFragment.exchangeConsume
local DAY_CHANGE_TIME = i3k_db_catch_spirit_base.spiritFragment.exchangeDaily

function wnd_spriteFragmentExchange:ctor()
	self._targetID = 0
	self._selfID = 0
	self._isInCD = 0
	self._cdSwitch = false
	self._fastCD = 0
	self._fastClickSwitch = false
end

function wnd_spriteFragmentExchange:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self,self.onCloseUI)
	widgets.targetFragmentDesc:setText(i3k_get_string(18600))--设置您希望交换到的碎片：
	widgets.selfFragmentDesc:setText(i3k_get_string(18601))--设置您希望用于交换的碎片：
	widgets.tipDesc:setText(i3k_get_string(18610))--交换成功，则双方均扣除交换次数
	widgets.useFragNum:setText(string.format(i3k_get_string(18602, i3k_db_catch_spirit_base.spiritFragment.exchangeConsume)))--"交换将消耗%s个碎片",
	widgets.exchangeBtn:onClick(self, self.onExchangeBtn)
	widgets.exchange_count2:setText(i3k_get_string(18699))
	self.exchangeBtn = widgets.exchangeBtn
	self.changeCountDesc = widgets.changeCountDesc
	self.targetScroll = widgets.targetScroll
	self.selfScroll = widgets.selfScroll
	self.exchange_count = widgets.exchange_count
	self.time = widgets.time
	self.exchangeBtnName = widgets.exchangeBtnName
	self.dayChangeTime = 0
end

function wnd_spriteFragmentExchange:onUpdate(dTime)
	self._isInCD = g_i3k_game_context:GetExchangeIsInCD()
	if self._isInCD > 0 then
		self.time:setText(i3k_get_string(18604, g_i3k_get_HourAndMin(self._isInCD)))--交换时间：%s）
		self._cdSwitch = true
	else
		if self._cdSwitch == true then
			self._cdSwitch = false
			self:UpdateExchangeType()		--时间走完 执行一次刷新
		end
	end

	if self._fastClickSwitch then
		self._fastCD = self._fastCD + dTime
		if self._fastCD > i3k_db_catch_spirit_base.spiritFragment.extraItemCount then
			self._fastClickSwitch = false
			self._fastCD = 0
		end
	end
end

function wnd_spriteFragmentExchange:openFastClickCheck()
	self._fastClickSwitch = true
end

function wnd_spriteFragmentExchange:ResetSelectFragmentID()
	self._targetID = 0
	self._selfID = 0
end

function wnd_spriteFragmentExchange:SetExchangeDataDesc()
	local state = g_i3k_game_context:GetSpiritsIsExchangeComplete()
	local text = ""
	if state == g_SPIRIT_STATE_NORMAL then
		text = i3k_get_string(18605)--无交换信息
	elseif state == g_SPIRIT_STATE_COMPLETE then
		text = i3k_get_string(18606)--交换成功
	elseif state == g_SPIRIT_STATE_FAIL then
		text = i3k_get_string(18607)--交换失败
	end
	self.time:setText(i3k_get_string(18604, text))
end

function wnd_spriteFragmentExchange:refresh(data)
	self._targetID = data.targetId
	self._selfID = data.costId
	self:UpdateExchangeType()
end


function wnd_spriteFragmentExchange:UpdateExchangeType()
	self._isInCD = g_i3k_game_context:GetExchangeIsInCD()
	self:updateTargetList()
	self:updateSelfList()
	if self._isInCD > 0 then
		self.exchangeBtnName:setText(i3k_get_string(18609)) --取消
	else
		self.exchangeBtnName:setText(i3k_get_string(18608))	--交换
	end
	--设置交换次数
	self.dayChangeTime = g_i3k_game_context:GetSpiritsData().daySwapTimes
	local textDesc = self.dayChangeTime.."/"..DAY_CHANGE_TIME
	if self.dayChangeTime < DAY_CHANGE_TIME then
		textDesc = "<c=green>"..textDesc.."</c>"
	else
		textDesc = "<c=red>"..textDesc.."</c>"
	end
	self.exchange_count:setText(i3k_get_string(18603, textDesc))
	--设置交换状态
	self:SetExchangeDataDesc(g_i3k_game_context:GetSpiritsIsExchangeComplete())
end


function wnd_spriteFragmentExchange:updateTargetList()
	self.targetScroll:removeAllChildren()
	local sList = self:outSpecialFragment(g_i3k_db.i3k_db_get_spiritsFragment_all_List()) 
	self.targetScroll:addItemAndChild(WIGETS_FRAG, 6, #sList)
	for i,v in ipairs(sList) do
		local node = self.targetScroll.child[i]
		node.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(v.iconId))
		local _,_,bagDic = g_i3k_game_context:GetSpiritsBagData()
		local count = bagDic[v.id] and bagDic[v.id] or 0
		node.vars.num:setText("x"..count)
		node.vars.select2:setVisible(v.id == self._targetID)
		node.vars.bg:setImage("djk#ktong")
		if self._isInCD > 0 then
			if v.id ~= self._targetID then
				node.vars.icon:disable()
				node.vars.btn:disable()
			end
		else
			node.vars.btn:onClick(self,self.onTargetClick, v.id)
		end
		node.id = v.id
	end
end

--筛选目标碎片列表（剔除稀有）
function wnd_spriteFragmentExchange:outSpecialFragment(list)
	local clist = {}
	for i,v in ipairs(list) do
		if i3k_db_catch_spirit_fragment[v.id].fragmentType ~= g_SPIRIT_FRAGMENT_RARE then
			local _,_,bagDic = g_i3k_game_context:GetSpiritsBagData()
			v.count = bagDic[v.id] and bagDic[v.id] or 0
			table.insert(clist, v)
		end
	end
	table.sort(clist, function(a, b)
			if a.count ~= b.count then
				return a.count > b.count
			end
			return a.id < b.id
		end
		)
	return clist
end

function wnd_spriteFragmentExchange:onTargetClick(sender, id)
	self._targetID = id
	for i,v in ipairs(self.selfScroll.child) do
		if v.id == id then
			v.vars.icon:disable()
			v.vars.btn:disable()
		else
			v.vars.icon:enable()
			v.vars.btn:enable()
		end
	end
	for _,target in ipairs(self.targetScroll.child) do
		target.vars.select2:setVisible(target.id == id)
	end
end

function wnd_spriteFragmentExchange:updateSelfList()
	self.selfScroll:removeAllChildren()
	local bagData, _, bagDic = g_i3k_game_context:GetSpiritsBagData()
	local showData = {}
	for i,v in ipairs(bagData) do
		if v.count >= COST_COUNT and i3k_db_catch_spirit_fragment[v.id].fragmentType ~= g_SPIRIT_FRAGMENT_RARE then
			table.insert(showData, v)
		end
	end
	self.selfScroll:addItemAndChild(WIGETS_FRAG, 6, #showData)
	for i,v in ipairs(showData) do
		local node = self.selfScroll.child[i]
		local cfg = i3k_db_catch_spirit_fragment[v.id]
		node.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(cfg.iconId))
		node.vars.num:setText("x"..v.count)
		node.vars.select2:setVisible(v.id == self._selfID)
		node.vars.bg:setImage("djk#ktong")
		if self._isInCD > 0 then
			if v.id ~= self._selfID then
				node.vars.icon:disable()
				node.vars.btn:disable()
			end
		else
			node.vars.btn:onClick(self,self.onSelfClick, v.id)
		end
		node.id = v.id
	end
end

function wnd_spriteFragmentExchange:onSelfClick(sender, id)
	self._selfID = id
	for i,v in ipairs(self.targetScroll.child) do
		if v.id == id then
			v.vars.icon:disable()
			v.vars.btn:disable()
		else
			v.vars.icon:enable()
			v.vars.btn:enable()
		end
	end
	for _,target in ipairs(self.selfScroll.child) do
		target.vars.select2:setVisible(target.id == id)
	end
end

function wnd_spriteFragmentExchange:onExchangeBtn(sender)
	if self._targetID > 0 and self._selfID > 0 then
		if self._isInCD > 0 then
			if self._fastClickSwitch then
				return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18612))
			end
			i3k_sbean.ghost_island_exchange_cancle()
		elseif self.dayChangeTime < DAY_CHANGE_TIME then
			if self._fastClickSwitch then
				return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18612))
			end
			i3k_sbean.ghost_island_exchange(self._selfID, COST_COUNT, self._targetID)
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18620)) --您当前可交换次数已用尽，无法交换
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18611))--尚未完成交换选择设置，无法提交请求
	end
end

--异步协议成功
function wnd_spriteFragmentExchange:onAsyncNetCome()
	g_i3k_ui_mgr:PopupTipMessage("非同步交换成功")
	--[[
	local data = { costId =  self._selfID, targetId = self._targetID, costCount = COST_COUNT}
	g_i3k_game_context:UpdateSpiritsFragmentExchangeComplete(data)
	self._isFinish = true
	self.time:setText(string.format("（交换时间：%s）", "交换成功") )
	self:UpdateExchangeType()
	]]
end


function wnd_create(layout)
	local wnd = wnd_spriteFragmentExchange.new()
	wnd:create(layout)
	return wnd
end
