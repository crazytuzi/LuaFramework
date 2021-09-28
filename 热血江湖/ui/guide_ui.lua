-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_guide_ui = i3k_class("wnd_guide_ui", ui.wnd_base)

local MODEL_ID = 323

function wnd_guide_ui:ctor()
	
end

function wnd_guide_ui:configure()
	local widget = self._layout.vars
	local allWidget = {}
	local left = {}
	left.root = widget.leftRoot
	left.bgImg = widget.bgImgLeft
	left.textLabel = widget.leftText
	local right = {}
	right.root = widget.rightRoot
	right.bgImg = widget.bgImgRight
	right.textLabel = widget.rightText
	allWidget.left = left
	allWidget.right = right
	allWidget.model = widget.model
	self._widgets = allWidget
end

function wnd_guide_ui:onShow()
	
end

function wnd_guide_ui:refresh(pos, radius, text)
	local winSize = cc.Director:getInstance():getWinSize()
	self._widgets.left.root:setVisible(pos.x>=winSize.width/2)
	self._widgets.right.root:setVisible(not self._widgets.left.root:isVisible())
	local model = self._widgets.model
	local root = self._layout.vars.root
	local textWidget
	model:setSprite(g_i3k_db.i3k_db_get_model_path(MODEL_ID))
	local modelSize = model:getContentSize()
	local needPos
	if pos.y>=winSize.height/3 then
		if pos.x>=winSize.width/2 then--右上
			model:playAction("you")
			needPos = {x = pos.x-radius-modelSize.width/2, y = pos.y-30}
			textWidget = self._widgets.left
		else
			model:playAction("zuo")--左上
			needPos = {x = pos.x+radius+modelSize.width/2, y = pos.y-30}
			textWidget = self._widgets.right
		end
	else
		if pos.x>=winSize.width/2 then--右下
			model:playAction("youxia")
			needPos = {x = pos.x-radius-modelSize.width/2, y = pos.y+30}
			textWidget = self._widgets.left
		else
			model:playAction("zuoxia")--左下
			needPos = {x = pos.x+radius+modelSize.width/2, y = pos.y+30}
			textWidget = self._widgets.right
		end
	end
	root:setPosition(needPos)
	if text and textWidget then
		textWidget.textLabel:setText(text)
		--[[g_i3k_ui_mgr:AddTask(self, {textWidget}, function (ui)
			local imgSize = textWidget.root:getContentSize()
			local textSize = textWidget.textLabel:getInnerSize()
			local needHeight = imgSize.height>textSize.height+20 and imgSize.height or textSize.height+20
			textWidget.bgImg:setContentSize(imgSize.width, needHeight)
		end, 1)--]]
	end
end


function wnd_create(layout, ...)
	local wnd = wnd_guide_ui.new()
	wnd:create(layout, ...)
	return wnd;
end
