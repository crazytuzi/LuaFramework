-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------

wnd_findMooncake = i3k_class("wnd_findMooncake", ui.wnd_base)

local ALLWIDGETS = {"ui/widgets/zhaochat", "ui/widgets/zhaochat2"}
local DELAYTIME = 4
local TOTALBTN = 47
local TIMEPOINT = 10

function wnd_findMooncake:ctor() 
	--math.randomseed(tostring(os.time()):reverse():sub(1, 6))
end

function wnd_findMooncake:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onClose)
end

function wnd_findMooncake:refresh(info)
	self._id = info.id
	self._lefttimes = i3k_db_findMooncake[self._id].dayTimes - info.useTimes
	self._layout.vars.left_times:setText("剩余次数："..self._lefttimes)
	
	for i = 1, 3 do
		self["_leftMooncakeCount"..i] = i3k_db_findMooncake[self._id].cakeInfo[i].count
		self["_foundCount"..i] = 0
	end
	
	self._leftWidgetCount = #ALLWIDGETS
	self._limitTime = i3k_db_findMooncake[self._id].limitTime - DELAYTIME
	self._timeTick = 0
	self._timeFlag = false
	
	self._moveOneStepTimerFlag = false
	self._moveTimeCounter = 0
	
	self._layout.vars.image_scroll:hide()
	
	self:showAllImage()
	self:showCount()
end

---用于计时以及一些实时操作
function wnd_findMooncake:onUpdate(dTime)
	local timeLabel = self._layout.vars.limit_time
	local autoCloseTime = self._limitTime
	if self._timeFlag then
		self._timeTick = self._timeTick+dTime
	end
	local time = math.floor(autoCloseTime-self._timeTick)
	time = time>0 and time or 0
	timeLabel:setText("剩余时间：" .. math.floor(time))
	timeLabel:setTextColor(g_i3k_get_cond_color(time > TIMEPOINT))
	
	if time == 0 then
		self._timeTick = 0
		self._timeFlag = false
		
		g_i3k_ui_mgr:AddTask(self, {}, function(ui)
			if g_i3k_ui_mgr:GetUI(eUIID_MessageBox2) then
				g_i3k_ui_mgr:CloseUI(eUIID_MessageBox2)
			end 
				g_i3k_ui_mgr:OpenUI(eUIID_FindFail)
			end, 1) 
	end
	if self._moveOneStepTimerFlag then
		self:moveOneStepTimer(dTime)
	end
end

---随机生成月饼
function wnd_findMooncake:setMooncake(widget)
	local chosenBtn = {}
	for index ,v in ipairs(i3k_db_findMooncake[self._id].cakeInfo) do
		local count = nil
		if self._leftWidgetCount > 1 then
			if self["_leftMooncakeCount"..index] <= 1 then
				count = self["_leftMooncakeCount"..index]
			else
			    count = math.random(self["_leftMooncakeCount"..index] - self._leftWidgetCount + 1)
			end
		else
			count = self["_leftMooncakeCount"..index]
		end
		if count > 0 then
			for i = 1, count do
				local btn = math.random(TOTALBTN)
				while self:isInTable(btn, chosenBtn) 
				do
					btn = math.random(TOTALBTN)
				end	
				table.insert(chosenBtn, btn)
				widget.vars["btn"..btn]:setImage(g_i3k_db.i3k_db_get_icon_path(v.id))
				widget.vars["btn"..btn]:onClick(self, self.choseRight, index)
			end
			self["_leftMooncakeCount"..index] = self["_leftMooncakeCount"..index] - count
		end
	end
	self._leftWidgetCount = self._leftWidgetCount - 1
end

---设置随机图片
function wnd_findMooncake:setImages(widget)
	local imageId = {}
	local totalCount = self:imageTotalCount()
	for i = 1, TOTALBTN do
		widget.vars["btn"..i]:setRotation(math.random(-120, 120))
		if #imageId == totalCount then
			imageId = {}
		end
		local section = math.random(#i3k_db_findMooncake[self._id].imageTotal)
		local Id = math.random(i3k_db_findMooncake[self._id].imageTotal[section][1], i3k_db_findMooncake[self._id].imageTotal[section][2])
		while self:isInTable(Id, imageId) 
		do  
		    section = math.random(#i3k_db_findMooncake[self._id].imageTotal)
			Id = math.random(i3k_db_findMooncake[self._id].imageTotal[section][1], i3k_db_findMooncake[self._id].imageTotal[section][2])
		end
		table.insert(imageId, Id)	
		widget.vars["btn"..i]:setImage(g_i3k_db.i3k_db_get_icon_path(Id))
		widget.vars["btn"..i]:onClick(self, self.choseFalse, 0)
	end
end

---显示图片和月饼
function wnd_findMooncake:showAllImage()
	local widgets = self._layout.vars
	for i, v in ipairs(i3k_db_findMooncake[self._id].cakeInfo) do
		widgets["cake_icon"..i]:setImage(g_i3k_db.i3k_db_get_icon_path(v.id))
	end 
	local scroll = widgets.image_scroll
	scroll:removeAllChildren()
	for i, v in ipairs(ALLWIDGETS) do
		local widget = require(v)()
		self:setImages(widget)
		self:setMooncake(widget)
	    scroll:addItem(widget)
	end
end

---显示数量信息
function wnd_findMooncake:showCount()
	local widgets = self._layout.vars
	for i, v in ipairs(i3k_db_findMooncake[self._id].cakeInfo) do
		widgets["count"..i]:setText(self["_foundCount"..i] .. "/"..v.count)
	end 
end

--选对
function wnd_findMooncake:choseRight(btn, index)
	i3k_sbean.findMooncake_click(self._id, i3k_db_findMooncake[self._id].cakeInfo[index].id, 1, btn, index)
end

--选错
function wnd_findMooncake:choseFalse(btn)
	i3k_sbean.findMooncake_click(self._id, 0, 0, btn)
end

---选错之后的操作
function wnd_findMooncake:afterChoseFalse(btn)
    --self._layout.vars.false_icon:setPosition(btn:getPosition())
	self._layout.vars.punishTime:setText("-"..i3k_db_findMooncake[self._id].punishTime.."秒")
	self._layout.anis.c_cuo.play()
	self._timeTick = self._timeTick + i3k_db_findMooncake[self._id].punishTime
end


---选对之后的操作
function wnd_findMooncake:afterChoseRight(index,btn)
	local isDone = true
	self["_foundCount"..index] = self["_foundCount"..index] + 1
	btn:hide()
	self:showCount()
	
	self._layout.vars.fly_icon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_findMooncake[self._id].cakeInfo[index].id))
	self._startPos = btn:getPosition()
	self._endPos = self._layout.vars["cake_icon"..index]:getPosition()
	self._moveOneStepTimerFlag = true
	
	for i, v in ipairs(i3k_db_findMooncake[self._id].cakeInfo) do
		if self["_foundCount"..i] ~= v.count then
			isDone = false
		end
	end
	if isDone then
		i3k_sbean.findMooncake_getItems(self._id)
		self._timeFlag = false
	end
end

---是否离开
function wnd_findMooncake:onClose(sender)
	--self._timeFlag = false
	local callback = function(ok)
			if ok then
				self:onCloseUI()
			--else
			  --self._timeFlag = true 
			end 
		end
	 g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(16501), callback)
end

--是否再次尝试
function wnd_findMooncake:ifCountine()
	local callback = function(ok)
			if ok then	
				i3k_sbean.findMooncake_start(self._id)
			else
			    self:onCloseUI()
			end 
		end
	if g_i3k_ui_mgr:GetUI(eUIID_MessageBox2) then
		g_i3k_ui_mgr:CloseUI(eUIID_MessageBox2)
	end 
	g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(16503), callback)
end

---开始计时
function wnd_findMooncake:countDown()
	self._timeFlag = true
	self._layout.vars.image_scroll:show()
end

--月饼移动动画
function wnd_findMooncake:moveOneStepTimer(dTime)
	local deltX = - (self._startPos.x - self._endPos.x)
	local deltY = - (self._startPos.y - self._endPos.y)
	local duringTime = 0.3 -- 持续时间
	local speedX = deltX / duringTime
	local speedY = deltY / duringTime

	self._moveTimeCounter = self._moveTimeCounter + dTime
	local posX = speedX * self._moveTimeCounter
	local posY = speedY * self._moveTimeCounter

	local pos = {x = posX + self._startPos.x, y = posY + self._startPos.y}
	local model = self._layout.vars.fly_icon
	model:show()
	model:setPosition(pos)
	if self._moveTimeCounter > duringTime then
		model:hide()
		self._moveTimeCounter = 0
		self._moveOneStepTimerFlag = false
	end
end

---判断元素是否在一个表内
function wnd_findMooncake:isInTable(value, tbl)
	for k,v in ipairs(tbl) do
	  if v == value then
	  return true;
	  end
	end
	return false;
end

--计算图片库的数量
function wnd_findMooncake:imageTotalCount()
	local count = 0
	for i,v in ipairs(i3k_db_findMooncake[self._id].imageTotal) do
		count = count + (v[2] - v[1] + 1)
	end
	return count
end

function wnd_create(layout)
	local wnd = wnd_findMooncake.new()
	wnd:create(layout)
	return wnd
end
