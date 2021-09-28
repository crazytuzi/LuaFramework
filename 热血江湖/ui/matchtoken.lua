
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_matchToken = i3k_class("wnd_matchToken",ui.wnd_base)

function wnd_matchToken:ctor()
	self._cfg = nil
	self._arg1 = 0
	self._posTable = {}
	self._dragPos = nil
	self._btnPos = nil

	self._co = nil

	self._screenWidth = cc.Director:getInstance():getWinSize().width
end

function wnd_matchToken:configure()
	local widgets = self._layout.vars
	widgets.closeBtn:onClick(self, self.onCloseUI)
	widgets.btn:onTouchEvent(self, self.onMove)
end

function wnd_matchToken:refresh(arg1)
	self._arg1 = arg1
	self._cfg = i3k_db_match_token[arg1]

	local widgets = self._layout.vars
	widgets.desc:setText(i3k_get_string(50088))
		
	self._dragPos = widgets.dragModel:getPosition()
	self._btnPos = widgets.btn:getPosition()

	--拖拽的模型
	self:setModel(widgets.dragModel, self._cfg.dragModelID)
	--需要匹配的模型
	for i, modelID in ipairs(self._cfg.matchModelID) do
		self:setModel(widgets["model"..i], modelID)
	end

	self:initModelPos()
end

function wnd_matchToken:initModelPos()
	local widgets = self._layout.vars
	self._posTable = {
		[1] = {radius = widgets.root1:getContentSize().width/2, pos = widgets.dragModel:getParent():convertToNodeSpace(widgets.root1:getParent():convertToWorldSpace(widgets.root1:getPosition()))},
		[2] = {radius = widgets.root2:getContentSize().width/2, pos = widgets.dragModel:getParent():convertToNodeSpace(widgets.root2:getParent():convertToWorldSpace(widgets.root2:getPosition()))},
		[3] = {radius = widgets.root3:getContentSize().width/2, pos = widgets.dragModel:getParent():convertToNodeSpace(widgets.root3:getParent():convertToWorldSpace(widgets.root3:getPosition()))},
	}
end

function wnd_matchToken:onMove(sender, eventType)
	local widgets = self._layout.vars
	local mousePos = g_i3k_ui_mgr:GetMousePos()

	local pos = widgets.dragModel:getParent():convertToNodeSpace(mousePos)

	if eventType == ccui.TouchEventType.began then

	elseif eventType == ccui.TouchEventType.moved then
		widgets.btn:setPosition(pos)
		widgets.dragModel:setPosition(pos.x, pos.y - 180)
	else
		local disTable = {
			[1] = math.sqrt(math.pow(pos.x - self._posTable[1].pos.x, 2) + math.pow(pos.y - self._posTable[1].pos.y, 2)),
			[2] = math.sqrt(math.pow(pos.x - self._posTable[2].pos.x, 2) + math.pow(pos.y - self._posTable[2].pos.y, 2)),
			[3] = math.sqrt(math.pow(pos.x - self._posTable[3].pos.x, 2) + math.pow(pos.y - self._posTable[3].pos.y, 2)),
		}
		for i, v in ipairs(disTable) do
			if v <= self._posTable[i].radius then
				if self._cfg.matchModelID[i] == self._cfg.correctModelID then
					self:hideModel()
					self._co = g_i3k_coroutine_mgr:StartCoroutine(function()
						g_i3k_ui_mgr:InvokeUIFunction(eUIID_MatchToken, "showResultModel")
						g_i3k_coroutine_mgr.WaitForSeconds(3.5) --展示动作
						g_i3k_ui_mgr:InvokeUIFunction(eUIID_MatchToken, "finishTask")
						g_i3k_coroutine_mgr:StopCoroutine(self._co)
						self._co = nil
					end)
				else
					self:resetDragModel()
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(50079))
				end
				return
			end
		end
		if mousePos.x > self._screenWidth / 2 or mousePos.x < self._screenWidth / 2  then
			self:resetDragModel()
		end
	end
end

function wnd_matchToken:resetDragModel()
	local widgets = self._layout.vars
	widgets.dragModel:setPosition(self._dragPos)
	widgets.btn:setPosition(self._btnPos)
end

function wnd_matchToken:hideModel()
	local widgets = self._layout.vars
	widgets.dragModel:hide()
	for i, modelID in ipairs(self._cfg.matchModelID) do
		widgets["model"..i]:hide()
	end
end

function wnd_matchToken:showResultModel()
	local widgets = self._layout.vars
	self:setModel(widgets.resultModel, self._cfg.resultModelID, "finish")
	widgets.resultModel:show()
end

function wnd_matchToken:setModel(model, id, actionName)
	if not actionName then
		actionName = "stand"
	end
	local path = i3k_db_models[id].path
	local uiscale = i3k_db_models[id].uiscale
	model:setSprite(path)
	model:setSprSize(uiscale)
	model:playAction(actionName)
end

function wnd_matchToken:finishTask()
	local function callback()
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(50089))
		g_i3k_ui_mgr:CloseUI(eUIID_MatchToken)
	end
	i3k_sbean.task_complete_notice_gs(g_TASK_MATCH_TOKEN, self._arg1, callback)
end

function wnd_matchToken:hide()
	if self._co then
		g_i3k_coroutine_mgr:StopCoroutine(self._co)
		self._co = nil
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_matchToken.new()
	wnd:create(layout, ...)
	return wnd;
end

