-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_exposeLetter = i3k_class("wnd_exposeLetter", ui.wnd_base)

function wnd_exposeLetter:ctor()
	self._cfg = nil
	self._result = {}
	self._arg1 = 0
	self._time = 0
	self._finish = false
	--self._posTable = nil
	--self._dragTable = nil
end

function wnd_exposeLetter:configure()
	local widgets = self._layout.vars
	widgets.closeBtn:onClick(self, self.onCloseUI)	
end

function wnd_exposeLetter:refresh(index)	
	local widgets = self._layout.vars
	self._cfg = i3k_db_expose_letter[index]
	self._arg1 = index
	--self._posTable = {width = widgets.check:getContentSize().width / 2, height = widgets.check:getContentSize().height / 2,
	--pos = widgets.image:getParent():convertToNodeSpace(widgets.check:getParent():convertToWorldSpace(widgets.check:getPosition()))}
	--self._dragTable = {width = widgets.image:getContentSize().width / 2, height = widgets.image:getContentSize().height / 2}
	
	if self._cfg then
		for	k, v in ipairs(self._cfg.dragImageId) do
			widgets["icon" .. k]:setImage(g_i3k_db.i3k_db_get_icon_path(v))
			widgets["bt" .. k]:onTouchEvent(self, self.onMove, {index = k})
		end
		
		if self._cfg.showTextId ~= 0 then
			widgets.showText:setText(i3k_get_string(self._cfg.showTextId))
		end		
	end
	
	widgets.des:setText(i3k_get_string(50090))
	g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(50078))
end


function wnd_exposeLetter:rectIntersectsRect(pos)
	local x = math.sqrt(math.pow(pos.x - self._posTable.pos.x, 2))
	local y = math.sqrt(math.pow(pos.y - self._posTable.pos.y, 2))

	if x <= self._posTable.width + self._dragTable.width and y <= self._posTable.height + self._dragTable.height then
		return true
	end
	
	return false
end

function wnd_exposeLetter:onMove(sender, eventType, info)
	local widgets = self._layout.vars
	local pos = widgets.image:getParent():convertToNodeSpace(g_i3k_ui_mgr:GetMousePos())
	local image = widgets.image
	local cfg = self._cfg
	local imageId = cfg.dragImageId[info.index]
	
	if eventType == ccui.TouchEventType.began then
		image:show()
		image:setPosition(pos)
		image:setImage(g_i3k_db.i3k_db_get_icon_path(imageId))
		widgets["icon" .. info.index]:hide()
		--self._scroll:stateToNoSlip()
	elseif eventType == ccui.TouchEventType.moved then
		image:setPosition(pos)
	else
		--local distance = math.sqrt(math.pow(pos.x - self._posTable.pos.x, 2) + math.pow(pos.y - self._posTable.pos.y, 2))
		
		--if not self:rectIntersectsRect(pos) then
			--image:hide()
			--return			
		--end
		
		if cfg.tipsId[info.index] then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(cfg.tipsId[info.index]))
		end
		
		local anis = self._layout.anis
		if cfg.effectName[info.index] and anis[cfg.effectName[info.index]] then
			anis[cfg.effectName[info.index]].stop()
			anis[cfg.effectName[info.index]].play()
		end
		
		self._result[imageId] = true
		
		if self:isFinish() then
			self._finish = true
			
			for	k, v in ipairs(self._cfg.dragImageId) do
				widgets["root" .. k]:setVisible(false)
			end
		else
			widgets["icon" .. info.index]:show()
		end
		
		image:hide()		
		--self._scroll:stateToSlip()
	end
end

function wnd_exposeLetter:isFinish()
	for k, v in ipairs(self._cfg.resuleId) do
		if not self._result[v] then
			return false
		end
	end
	
	return true
end 


function wnd_exposeLetter:onUpdate(dTime)
	if self._finish then
		self._time = self._time + dTime
		
		if self._time >= self._cfg.closeTime then
			self._time = 0
			g_i3k_ui_mgr:AddTask(self, {}, function(ui)
				self:onCloseUI()
			end, 1)	
		end
	end
end

function wnd_exposeLetter:onHide()
	if self._finish then
		i3k_sbean.task_complete_notice_gs(g_TASK_EXPOSE_LETTER, self._arg1)
	end
end

function wnd_create(layout,...)
	local wnd = wnd_exposeLetter.new();
	wnd:create(layout,...)
	return wnd;
end
