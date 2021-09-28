-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
-------------------------------------------------------
wnd_roll_Notice = i3k_class("wnd_roll_Notice", ui.wnd_base)

---滚动广播
local broadcast_timerTask = {}

function wnd_roll_Notice:ctor()
	
	--队列
	self._first =  0;
	self._last 	= -1;
	self._value	= { };
	
	self._timeTick = 0
	self._roll = false
	self._canPop = true
	self._alreadyHave = {}
end

function wnd_roll_Notice:configure()
	
end

function wnd_roll_Notice:sortValueTable()
	local min;
	local valueTable = {}
	for i,v in pairs(self._value) do
		min = min and min<i and min or i
		table.insert(valueTable, v)
	end
	table.sort(valueTable, function (a, b)
		return a.type < b.type
	end)
	self._value = {}
	for i,v in ipairs(valueTable) do
		self._value[min-1+i] = valueTable[i]
	end
end

function wnd_roll_Notice:refresh(value)
	local text = self._layout.vars.text:getText()
	if not text or text=="" then
		self._width =  self._layout.vars.text:getPosition()
	end
	self:push(value)
end

function wnd_roll_Notice:push(value)
	local isHave = false;
	for i,v in pairs(self._value) do
		if v.id==value.id then
			isHave = true;
			break;
		end
	end
	if not isHave then
		self._last = self._last + 1;
		self._value[self._last] = value;
		self:sortValueTable()
	end
end

function wnd_roll_Notice:pop()
	while self._value[self._first]==nil do
		self._first = self._first + 1;
	end
	local value;
	if self._first <= self._last then
		self._canclose = false;
		value = self._value[self._first];
		self._value[self._first] = nil;
		self._first = self._first + 1;
	end
	if value then
		local arg = string.split(value.content, "|")
		if value.type~=0 then
			value.content = g_i3k_db.i3k_db_get_roll_notice_text(value.type, arg)
		end
		if value.freq==0 and not self:checkIsHave(value.id) then
			local title = g_i3k_db.i3k_db_get_roll_notice_title(value.type)
			g_i3k_game_context:ShowSysMessage(value.content,title,0,value.type, arg)
			self._alreadyHave[value.id] = true
		end
		return value.content, value.type
	end
end

function wnd_roll_Notice:checkIsHave(id)
	return self._alreadyHave[id]
end

function wnd_roll_Notice:size()
	return i3k_table_length(self._value);
end

function wnd_roll_Notice:clear()
	self._first =  0;
	self._last	= -1;
	self._value = { };
	self._alreadyHave = {}
end

----设置滚动
function wnd_roll_Notice:setRoll(message)
	local textWidth = self._layout.vars.text:getContentSize()
	local posx, posy = textWidth.width*3/2, self._width.y
	self._layout.vars.text:setPosition(posx, posy)
	
	self._layout.vars.text:setText(message)
	
	--  回调动作
	local tarfinsh = function()
		self._canPop = true
		self._canclose = true
	end
	
	g_i3k_ui_mgr:AddTask(self, {}, function (ui)
		local width = ui._layout.vars.text:getInnerSize().width
		local pAction = ui._layout.vars.text:createMoveTo(15,  - width, ui._layout.vars.text:getPositionY())
		local rep = ui._layout.vars.text:createSequence(pAction, cc.CallFunc:create(tarfinsh))
		ui._layout.vars.text:runAction(rep)
	end)	
end

---移除队列里的信息
function wnd_roll_Notice:delRollMsg(id)
	local valueTable1 = self._value
	local removeTable = {}
	for i,v in pairs(self._value) do
		if v.id==id then
			table.insert(removeTable, i)
		end
	end
	
	--倒序删除
	for i=#removeTable, 1, -1 do
		self._value[removeTable[i]] = nil;
	end
	local valueTable3 = self._value
end


function wnd_roll_Notice:onUpdate(dTime)
	local width =  self._layout.vars.text:getPosition()
	if self._canPop and self:size()>0 then
		--取下一个数据
		self._message, self._messageType = self:pop()
		
		self._canPop = false
		self._roll = true
	end
	
	if self._roll and not self._canPop then
		self._roll = false
		self:setRoll(self._message)
		if self._messageType == 36 and g_i3k_game_context:GetLevel() >= i3k_db_server_limit.breakSealCfg.limitLevel then
			g_i3k_ui_mgr:AddTask(self, {}, function(ui)
				g_i3k_ui_mgr:OpenUI(eUIID_BreakSealEffect)
			end, 1) 
		end
	end

	
	if next(self._value) ==nil and self._canclose then--判断 队列为空时
		self:clear()

		g_i3k_ui_mgr:CloseUI(eUIID_RollNotice)
	end
end

function wnd_create(layout)
	local wnd = wnd_roll_Notice.new();
	wnd:create(layout);
	return wnd;
end
