local QUIWidgetTalkController = class("QUIWidgetTalkController")

function QUIWidgetTalkController:ctor(options)
	self._words = options.words
	self:init()
end

function QUIWidgetTalkController:init()
	self._avatarWord = {}
	self:removeTalkHandler()
end

--增加气泡对象
function QUIWidgetTalkController:addAvatarTalk(widget)
	table.insert(self._avatarWord, {widget = widget, istalk = false})
end

--删除气泡的定时器
function QUIWidgetTalkController:removeTalkHandler()
	if self._talkSchedulerHandler ~= nil then 
		scheduler.unscheduleGlobal(self._talkSchedulerHandler)
	end
end

function QUIWidgetTalkController:getWord()
	if self._words ~= nil then
		local index = math.random(1, #self._words)
		return self._words[index].description
	end
	return nil
end

--开始气泡
function QUIWidgetTalkController:avatarTalkTime()
	local totalCount = #self._avatarWord
	if totalCount <= 0 then return end
	local count = math.random(1, totalCount)
	self:startAvatarTalk(self._avatarWord[count].widget, self:getWord())
end

--指定的avatar开始冒气泡
function QUIWidgetTalkController:startAvatarTalk(widget, word)
	self:stopAvatarTalk()
	if word ~= nil then 
		for index,value in ipairs(self._avatarWord) do
			if value.widget == widget then
				widget:showWord(word)
				value.istalk = true
				break
			end
		end
	else
		print("talk word is nil")
		return
	end
	self._talkSchedulerHandler = scheduler.performWithDelayGlobal(handler(self, self.avatarTalkTime), 8)
end

--停止冒气泡
function QUIWidgetTalkController:stopAvatarTalk()
	self:removeTalkHandler()
	if self._avatarWord ~= nil then
		for index,value in ipairs(self._avatarWord) do
			if value.istalk == true then
				value.widget:removeWord()
				value.istalk = false
			end
		end
	end
end

--从队列中删除指定的avatar
function QUIWidgetTalkController:removeAvatarTalk(widget)
	for index,value in ipairs(self._avatarWord) do
		if value.widget == widget then
			if value.istalk == true then
				self:stopAvatarTalk()
				self._talkSchedulerHandler = scheduler.performWithDelayGlobal(handler(self, self.avatarTalkTime), 2)
			end
			table.remove(self._avatarWord, index)
			return
		end
	end
end

--删除所有的avatar气泡
function QUIWidgetTalkController:removeAllAvatarTalk()
	self:stopAvatarTalk()
	self._avatarWord = {}
end

return QUIWidgetTalkController