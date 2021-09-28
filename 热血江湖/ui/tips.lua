-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_tips = i3k_class("wnd_tips", ui.wnd_base)

local f_tipWordLabel2 = nil
local f_tipWordLabel3 = nil
local f_tipImg2 = nil
local f_tipImg3 = nil

function wnd_tips:ctor()
	self._timeTick = 0;

	f_tipWordLabel2 = nil
	f_tipImg2 = nil
	f_tipWordLabel3 = nil
	f_tipImg3 = nil
	
	self._isFirst = true
end

function wnd_tips:registerEvent(event, _cb)
	if not self._events then
		self._events = { };
	end
	self._events[event] = _cb;
end

function wnd_tips:configure()
	local pos = self._layout.vars.root1:getPosition()
	self._layout.vars.root2:hide()
	self._layout.vars.root3:hide()
	self._layout.vars.root4:hide()
end

function wnd_tips:onShow()
	self._timeTick = 0;
end

function wnd_tips:onHide()
	f_tipWordLabel2 = nil
	f_tipWordLabel3 = nil
	f_tipImg2 = nil
	f_tipImg3 = nil
end

function wnd_tips:refresh(text)
	local textNode = self._layout.vars.tipWord1
	if self._isFirst then
		textNode:setText(text)
		self._isFirst = false
	else
		self._timeTick = 0
		if text~=textNode:getText() then
			local tipImg = self._layout.vars.root1
			if f_tipWordLabel3 then
				local nodePos = f_tipImg3:getPosition()
				local wordTmp = self._layout.vars.tipWord4
				wordTmp:setText(f_tipWordLabel3:getText())
				local imgTmp = self._layout.vars.root4
				needPosY = nodePos.y+textNode:getContentSize().height*0.7
				
				imgTmp:setPosition(nodePos)
				imgTmp:setOpacity(self._layout.vars.root1:getOpacity())
				imgTmp:show()
				local move2 = cc.MoveTo:create(0.2, {x = nodePos.x, y = needPosY})
				local fadeOut2 = cc.FadeOut:create(0.2)
				local spawn2 = cc.Spawn:create(fadeOut2, move2)
				local seq = cc.Sequence:create(spawn2, cc.CallFunc:create(function ()
					imgTmp:hide()
				end))
				imgTmp:runAction(seq)
				
				
				
				
				local nodePos = self._layout.vars.root1:getPosition()
				local nodePos2 = f_tipImg2:getPosition()
				f_tipWordLabel3.timeTick = 1
				f_tipWordLabel3:setText(f_tipWordLabel2:getText())
				needPosY = nodePos.y+textNode:getContentSize().height*2
				f_tipImg3:stopAllActions()
				f_tipImg3:setPosition(nodePos2)
				local move2 = cc.MoveTo:create(0.3, {x = nodePos2.x, y = needPosY})
				f_tipImg3:runAction(move2)
				
				
				
				
				f_tipWordLabel2.timeTick = 0.5
				f_tipWordLabel2:setText(self._layout.vars.tipWord1:getText())
				needPosY = nodePos.y+textNode:getContentSize().height
				local percent = math.abs(nodePos2.y-needPosY)/textNode:getContentSize().height
				
				f_tipImg2:stopAllActions()
				f_tipImg2:setPosition(nodePos)
				local move2 = cc.MoveTo:create(0.3-0.3*percent, {x = nodePos.x, y = needPosY})
				f_tipImg2:runAction(move2)
				textNode:setText(text)
				
			elseif f_tipWordLabel2 then
				local nodePos = self._layout.vars.root1:getPosition()
				local nodePos2 = f_tipImg2:getPosition()
				f_tipWordLabel3 = self._layout.vars.tipWord3
				f_tipWordLabel3.timeTick = 1
				f_tipWordLabel3:setText(f_tipWordLabel2:getText())
				f_tipImg3 = self._layout.vars.root3
				needPosY = nodePos.y+textNode:getContentSize().height*2
				f_tipImg3:setPosition(nodePos2)
				f_tipImg3:setOpacity(self._layout.vars.root1:getOpacity())
				f_tipImg3:show()
				local move2 = cc.MoveTo:create(0.3, {x = nodePos2.x, y = needPosY})
				f_tipImg3:runAction(move2)
				
				
				f_tipWordLabel2.timeTick = 0.5
				f_tipWordLabel2:setText(self._layout.vars.tipWord1:getText())
				needPosY = nodePos.y+textNode:getContentSize().height
				local percent = math.abs(nodePos2.y-needPosY)/textNode:getContentSize().height
				textNode:setText(text)
				
				f_tipImg2:stopAllActions()
				f_tipImg2:setPosition(nodePos)
				local move2 = cc.MoveTo:create(0.3-0.3*percent, {x = nodePos.x, y = needPosY})
				f_tipImg2:runAction(move2)
			else
				local nodePos = self._layout.vars.root1:getPosition()
				f_tipWordLabel2 = self._layout.vars.tipWord2
				f_tipWordLabel2.timeTick = 0.5
				f_tipWordLabel2:setText(self._layout.vars.tipWord1:getText())
				needPosY = nodePos.y+textNode:getContentSize().height
				textNode:setText(text)
				f_tipImg2 = self._layout.vars.root2
				f_tipImg2:setPosition(nodePos)
				f_tipImg2:setOpacity(self._layout.vars.root1:getOpacity())
				f_tipImg2:show()
				local move = cc.MoveTo:create(0.3, {x = nodePos.x, y = needPosY})
				f_tipImg2:runAction(move)
			end
		end
	end
end

function wnd_tips:hideTip2()
	f_tipImg2:hide()
	f_tipWordLabel2 = nil
	f_tipImg2 = nil
end

function wnd_tips:hideTip3()
	f_tipImg3:hide()
	f_tipWordLabel3 = nil
	f_tipImg3 = nil
end


function wnd_tips:onUpdate(dTime)
	self._timeTick = self._timeTick + dTime;
	
	if f_tipWordLabel2 then
		f_tipWordLabel2.timeTick = f_tipWordLabel2.timeTick + dTime 
		if f_tipWordLabel2.timeTick>3 then
			local fadeOut = cc.FadeOut:create(0.2)
			local seq = cc.Sequence:create(cc.CallFunc:create(function ()
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_Tips, "hideTip2")
			end), fadeOut)
			f_tipImg2:runAction(seq)
		end
	end
	if f_tipWordLabel3 then
		f_tipWordLabel3.timeTick = f_tipWordLabel3.timeTick + dTime 
		if f_tipWordLabel3.timeTick>3 then
			local fadeOut = cc.FadeOut:create(0.2)
			local seq = cc.Sequence:create(cc.CallFunc:create(function ()
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_Tips, "hideTip3")
			end), fadeOut)
			f_tipImg3:runAction(seq)
		end
	end
	if self._timeTick > 4 then
		g_i3k_ui_mgr:CloseUI(eUIID_Tips);
	end
end

function wnd_tips:refreshStarDishText(actStar)
	local widgets = self._layout.vars

	local root = widgets.root1
	local height = root:getContentSize().height/1.4
	local orginY = (root:getPosition()).y
	for i = 1 , 4 do
		root = widgets["root"..i]
		if actStar[i] then
			root:show()
			widgets["tipWord"..i]:setText(i3k_db_star_soul[actStar[i]].name.."启动<t=1>[点击查看]</t>"):onRichTextClick(self, self.updateStarDishInfo, actStar[i])
			
			local nodePos = root:getPosition()
			nodePos.y = nodePos.y+(i-1)*height
			root:setPosition(nodePos)
		else
			root:hide()
		end
	end
	self._timeTick = 0
end

function wnd_tips:updateStarDishInfo(send, tag, starId)
	g_i3k_ui_mgr:OpenUI(eUIID_StarFlare)
	g_i3k_ui_mgr:RefreshUI(eUIID_StarFlare, starId)
end

function wnd_create(layout)
	local wnd = wnd_tips.new();
	wnd:create(layout);
	return wnd;
end

