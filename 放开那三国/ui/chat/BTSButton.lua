-- Filename：	BTStandButton.lua
-- Author：		Cheng Liang
-- Date：		2015-4-1
-- Purpose：		按钮，拥有按下、松开等回调


BTSButton = class("BTSButton", function ()
	return CCLayer:create()
end)

function BTSButton:ctor( ... )
	self.began_callback 	= nil
	self.end_callback 		= nil
	self.cancel_callback 	= nil
	self.moved_callback		= nil
	self.normal_node 		= nil
	self.highlight_node		= nil
end

function BTSButton:createWithNode(btn_node_n, btn_node_h, touch_end_callback, touch_began_callback, touch_cancel_callback, touch_move_callback)
	local b_button = BTSButton:new()
	b_button:initWithNode(btn_node_n, btn_node_h, touch_end_callback, touch_began_callback, touch_cancel_callback, touch_move_callback)
	return b_button
end


function BTSButton:initWithNode(btn_node_n, btn_node_h, touch_end_callback, touch_began_callback,touch_cancel_callback, touch_move_callback)
	self.normal_node 		= btn_node_n
	self.highlight_node		= btn_node_h
	self.began_callback 	= touch_began_callback
	self.end_callback 		= touch_end_callback
	self.cancel_callback 	= touch_cancel_callback
	self.moved_callback		= touch_move_callback

	self:setContentSize(self.normal_node:getContentSize())
	self.normal_node:setAnchorPoint(ccp(0,0))
	self.highlight_node:setAnchorPoint(ccp(0,0))
	self:addChild(self.normal_node)
	self.highlight_node:setVisible(false)
	self:addChild(self.highlight_node)
	

	self:registerScriptHandler(function( event )
		print("event==", event)
		if (event == "enter") then
			self:registerScriptTouchHandler(function ( eventType, x, y )
				if (eventType == "began") then
					print("began:x=, y=,", x, y)
					if(self:isVisible()==false)then
						return false
					end
					if(isPointInNode(ccp(x, y), self.normal_node))then
						if(self.began_callback and type(self.began_callback) == "function")then
							self.began_callback(self)
						end
						self.highlight_node:setVisible(true)
						self.normal_node:setVisible(false)
						return true
					else
						return false
					end
				elseif(eventType == "moved") then
					print("moved---:x=, y=", x, y)
					if(self.moved_callback and type(self.moved_callback) == "function")then
						self.moved_callback(isPointInNode(ccp(x, y), self.normal_node))
					end
				else
					print("end:x=, y=", x, y)

					self.highlight_node:setVisible(false)
					self.normal_node:setVisible(true)
					if(isPointInNode(ccp(x, y), self.normal_node))then
						if(self.end_callback and type(self.end_callback) == "function")then
							self.end_callback(self)
						end
					else
						if(self.cancel_callback and type(self.cancel_callback) == "function")then
							self.cancel_callback(self)
						end
					end
				end
			end, 
			false, -999, true)


			self:setTouchEnabled(true)

		elseif (event == "exit") then
			self:unregisterScriptTouchHandler()
		end
	end
	)
	


end

-- 点是否在node范围
function isPointInNode( p_point, p_node )
	local p_position = p_node:convertToNodeSpace(p_point)
	local n_size = p_node:getContentSize()
	print("p_position,x=, y=", p_position.x, p_position.y)
	if(p_position.x>0 and p_position.y>0 and p_position.x<n_size.width and p_position.y<n_size.height)then
		return true
	else
		return false
	end
end
