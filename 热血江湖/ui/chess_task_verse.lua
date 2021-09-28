-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_chess_task_verse = i3k_class("wnd_chess_task_verse", ui.wnd_base)

local VERSE = "ui/widgets/zhenlongqijusjt"

function wnd_chess_task_verse:ctor()
	self._verseId = {}
	self._sortId = {}
	self._id = 1
	self.time = 0
	self.taskType = 0
	self._arg1 = 0 --节日限时任务需要把此参数传给服务器
	self._state = nil
end

function wnd_chess_task_verse:configure()
	self._layout.vars.close:onClick(self, self.onCloseUI)
end

function wnd_chess_task_verse:refresh(verseId, state, taskType, taskCfg)
	self._arg1 = verseId
	if verseId == 0 then
		self._id = math.random(1, #i3k_db_verse)
	else
		self._id = verseId
	end
	self._state = state
	self.taskType = taskType
	
	if state == g_TASK_VERSE_STATE_REGULAR then
		self._layout.vars.moveRoot:hide()
		self._layout.vars.leftTime:hide()
	elseif state == g_TASK_VERSE_STATE_CHESS then
		self.time = taskCfg.arg2
		self._layout.vars.moveRoot:hide()
	elseif state == g_TASK_VERSE_STATE_FESTIVAL then
		self.time = taskCfg.arg2
		self._layout.vars.moveRoot:hide()
	end
		self:sortVerse()
		self:setVerseScroll()
		self:setBg()
end

--设置背景图
function wnd_chess_task_verse:setBg()
	local widgets = self._layout.vars
	if self._state then
		local image = TASK_VERSE_ICON[self._state]
		widgets.title:setImage(g_i3k_db.i3k_db_get_icon_path(image.title))
	end
end

function wnd_chess_task_verse:sortVerse()
	local verse = i3k_db_verse[self._id]
	local content = verse.contentId
	self._verseId = content
	self._sortId = i3k_clone(content)
	math.randomseed(tostring(os.time()):reverse():sub(1, 7))
	for i = 1, #content do
		if i + 1 < #content then
			local num = math.random(i + 1, #content)
			self._sortId[i], self._sortId[num] = self._sortId[num], self._sortId[i]
		else
			if self._sortId[i] == content[i] then
				local num = math.random(1, i - 1)
				self._sortId[i], self._sortId[num] = self._sortId[num], self._sortId[i]
			end
		end
	end
end

function wnd_chess_task_verse:setVerseScroll()
	local verse = i3k_db_verse[self._id]
	local content = verse.contentId
	self._layout.vars.verseTitle:setText(verse.verseName)
	self._layout.vars.verseAuthor:setText(verse.verseAuthor)
	self._layout.vars.scroll:removeAllChildren()
	local trueCount = 0
	for i = 1, #content do
		local node = require(VERSE)()
		node.vars.text:setText(i3k_db_verse_content[self._sortId[i]])
		if self._sortId[i] == content[i] then
			node.vars.trueIcon:show()
			node.vars.text:setTextColor("FF7D5814")
			trueCount = trueCount + 1
		else
			node.vars.trueIcon:hide()
			node.vars.btn:onTouchEvent(self, self.moveVerse, {node = node, id = i})
			node.vars.text:setTextColor("FF412349")
		end
		node.vars.id = i
		self._layout.vars.scroll:addItem(node)
	end
	if trueCount == #content then
		self:finishVerse()
	end
end

function wnd_chess_task_verse:moveVerse(sender, eventType, moveBtn)
	local parent = self._layout.vars.moveRoot:getParent()
	local touchPos = g_i3k_ui_mgr:GetMousePos()
	local pos = {}
	if parent then
		pos = parent:convertToNodeSpace(cc.p(touchPos.x,touchPos.y))
	end
	if eventType == ccui.TouchEventType.began then
		moveBtn.node.vars.btn:stateToPressed()
	elseif eventType == ccui.TouchEventType.moved then
		self._layout.vars.moveRoot:show()
		self._layout.vars.moveRoot:setPosition(pos)
		self._layout.vars.text:setText(i3k_db_verse_content[self._sortId[moveBtn.id]])
	else
		self._layout.vars.moveRoot:hide()
		self:exchangeVerse(moveBtn)
	end
end

--[[function wnd_chess_task_verse:exchangeVerse(moveBtn, pos)
	local children = self._layout.vars.scroll:getAllChildren()
	local final = children[#children].rootVar:getPositionInScroll(self._layout.vars.scroll)
	local first = children[1].rootVar:getPositionInScroll(self._layout.vars.scroll)
	local len = (final.x - first.x) / (#children - 1) / 2
	for k, v in ipairs(children) do
		local newPos = v.rootVar:getPositionInScroll(self._layout.vars.scroll)
		local scrollPos = self._layout.vars.scroll:getPosition()
		local scrollNodePos = self._layout.vars.scroll:getParent():convertToNodeSpace(cc.p(scrollPos.x, scrollPos.y))
		--if math.abs(pos.x - 414 - newPos.x) < len then
		if math.abs(pos.x - scrollNodePos.x - newPos.x) < len then
			self._sortId[k], self._sortId[moveBtn.id] = self._sortId[moveBtn.id], self._sortId[k]
			self:setVerseScroll()
			break
		end
	end
end--]]
function wnd_chess_task_verse:exchangeVerse(moveBtn)
	local touchPos = g_i3k_ui_mgr:GetMousePos()
	local children = self._layout.vars.scroll:getAllChildren()
	local final = children[#children].vars.btn:getParent():convertToWorldSpace(children[#children].vars.btn:getPosition())
	local first = children[1].vars.btn:getParent():convertToWorldSpace(children[1].vars.btn:getPosition())
	local len = (final.x - first.x) / (#children - 1) / 2
	for k, v in ipairs(children) do
		local newPos = v.vars.btn:getParent():convertToWorldSpace(v.vars.btn:getPosition())
		--if math.abs(pos.x - 414 - newPos.x) < len then
		if math.abs(touchPos.x - newPos.x) < len then
			self._sortId[k], self._sortId[moveBtn.id] = self._sortId[moveBtn.id], self._sortId[k]
			self:setVerseScroll()
			break
		end
	end
end

function wnd_chess_task_verse:onUpdate(dTime)
	if self._state ~= g_TASK_VERSE_STATE_REGULAR then
		self.time = self.time - dTime
		self:showTimeLabel(self.time)
		if self.time < 0 then
			g_i3k_ui_mgr:AddTask(self, {}, function(ui)
				local callback = function()
					g_i3k_ui_mgr:CloseUI(eUIID_ChessTaskVerse)
				end
				g_i3k_ui_mgr:OpenUI(eUIID_ChessTaskDiffAnimate)
				g_i3k_ui_mgr:RefreshUI(eUIID_ChessTaskDiffAnimate, 0, callback)
			end, 1)
		end
	end
end

function wnd_chess_task_verse:showTimeLabel(time)
	time = time >= 0 and time or 0
	self._layout.vars.leftTime:setText(string.format("剩余%d秒", math.floor(time)))
end

function wnd_chess_task_verse:finishVerse()
	local callback = nil
	if self._state == g_TASK_VERSE_STATE_REGULAR then
		i3k_sbean.regular_game_notice_task_finished(self.taskType, 1)
		callback = function()
			g_i3k_logic:OpenTimingActivity()
			g_i3k_ui_mgr:CloseUI(eUIID_ChessTaskVerse)
		end
	elseif self._state == g_TASK_VERSE_STATE_CHESS then
		g_i3k_game_context:tellSeverChessTaskFinished(0, g_TASK_SORT_VERSE, 0)
		callback = function()
		g_i3k_ui_mgr:CloseUI(eUIID_ChessTaskVerse)
		end
	elseif self._state == g_TASK_VERSE_STATE_FESTIVAL then
		g_i3k_game_context:tellSeverFestivalFinish(g_TASK_SORT_VERSE, self._arg1, 0, 1)
		callback = function()
		g_i3k_ui_mgr:CloseUI(eUIID_ChessTaskVerse)
		end
	end

	g_i3k_ui_mgr:OpenUI(eUIID_ChessTaskDiffAnimate)
	g_i3k_ui_mgr:RefreshUI(eUIID_ChessTaskDiffAnimate, 1, callback)

	--self:onCloseUI()
end

function wnd_create(layout)
	local wnd = wnd_chess_task_verse.new()
	wnd:create(layout)
	return wnd
end
