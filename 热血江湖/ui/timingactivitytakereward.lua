------------------------------------------------------
module(...,package.seeall)

local require = require

local ui = require('ui/base')
------------------------------------------------------
wnd_timing_activity_result = i3k_class("wnd_timing_activity_result",ui.wnd_base)

function wnd_timing_activity_result:ctor()
	self.preEffectDuring = 5 --抽卡前动画时长
	self.totalTime = 1.5 --播放爆炸动画时长
	self.nextBeginTime = 0.8 --播放多久后开始下个动画
end
function wnd_timing_activity_result:configure()
	local widgets = self._layout.vars
	widgets.okBtn:onClick(self, self.onCloseUI)
	self.itemOpacityRecord = {}
	for i = 1, 10 do
		self.itemOpacityRecord[i] = 0
	end
end

function wnd_timing_activity_result:refresh(mustItems, mayItems)
	self.mustItems = mustItems
	self.mayItems = mayItems
	if mustItems then
	local id,cnt = next(mustItems)
	table.insert(self.mayItems, math.random(1,9), {id = id, count = cnt})
	self.mayItems[id] = cnt
	end
	local widgets = self._layout.vars
	for i =1, 10 do
		widgets['bg'..i]:setOpacityWithChildren(0)
	end
	local times = self:caculateData(self.mayItems, mustItems ~= nil)
	local index = 0
	widgets.okBtn:hide()
	if mustItems then
	self:doDelayTask(times[0], function()
		widgets.effectRoot:show()
		local modelIds = {1330, 1332, 1333}
		for i = 1, 3 do
			local ui = widgets["effectModel"..i]
			ui_set_hero_model(ui, modelIds[i])
			ui:pushActionList("stand", 1)
			ui:playActionList()
		end
	end)
	self:doDelayTask(times[1], function()
		widgets.effectRoot:hide()
	end)
	end
	for i,v in ipairs(self.mayItems) do--此时mayItems已经是全部的了
		self:DoItemAnimation(i, times[i], {id = v.id,count = v.count})
	end
	self:doDelayTask(times[#times], function()
		widgets.okBtn:show()
	end)
end

--计算时间
function wnd_timing_activity_result:caculateData(items, isShowAnis)
	local times = {}
	local timer = isShowAnis and self.preEffectDuring or 0
	local index = 0
	times[0] = timer--加上抽卡前的特效
	for i,v in ipairs(items) do
		times[i] = timer--开始时间
		timer = timer + self.nextBeginTime
	end
	table.insert(times, timer)--最后播放完毕 恢复按钮的时间
	return times
end

function wnd_timing_activity_result:setItem(index, cfg, cnt)
	local widgets = self._layout.vars
	widgets["name"..index]:setText(cfg.name..'x'..cnt)
	widgets["bg"..index]:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(cfg.id))
	widgets["icon"..index]:setImage(g_i3k_db.i3k_db_get_icon_path(cfg.icon))
	widgets["lock" .. index]:setVisible(cfg.id > 0)
end

function wnd_timing_activity_result:playAnimation(index)
	local widgets = self._layout.vars
	local bg = widgets['bg'..index]
	local effect = widgets.effect
	local pos = bg:getPosition()
	local ani = self._layout.anis.c_1
	ani.stop()
	effect:setPosition(pos.x, pos.y)
	ani.play()
end

local emptyFunc = cc.CallFunc:create(function() end)
function wnd_timing_activity_result:doDelayTask(delay, cb)--延迟任务
	local delay = cc.DelayTime:create(delay)
	local seq = cc.Sequence:create(emptyFunc, delay, cc.CallFunc:create(cb))
	self._layout.vars.okBtn:runAction(seq)
end

function wnd_timing_activity_result:DoItemAnimation(index, delay, item)--每个物品的动画流程
	local func = function()
		local cfg = g_i3k_db.i3k_db_get_common_item_cfg(item.id)
		self:setItem(index, cfg, item.count)
		self:BeginIncreaseOpacity(index)
		self:playAnimation(index)
	end
	self:doDelayTask(delay, func)
end

--开始增加透明度的动画
function wnd_timing_activity_result:BeginIncreaseOpacity(index)
	self.itemOpacityRecord[index] = 1
end

function wnd_timing_activity_result:onUpdate(dTime)
	for i,v in ipairs(self.itemOpacityRecord) do
		local bg = self._layout.vars['bg'..i]
		if v > 0 and v < 255 then
			self.itemOpacityRecord[i] = math.min(255, v + 255/(self.totalTime / dTime))
			bg:setOpacityWithChildren(self.itemOpacityRecord[i])
		end
	end
end
---------------------------------------------------------
function wnd_create(layout,...)
	local wnd = wnd_timing_activity_result.new()
	wnd:create(layout,...)
	return wnd
end
