local GUIMessageAnimation={}

function GUIMessageAnimation.cleanLastMsg(target)
	if target then
		target:stopAllActions()
		target:runAction(
			cca.seq({
				cc.EaseExponentialOut:create(cca.spawn({cca.fadeOut(1),cca.moveTo(1,cc.p(0,30))})),
				cca.removeSelf()
			})
		)
	end
end
----param{parent,hold,msg,color,pos,fontSize,opacity}
----有消息堆栈
function GUIMessageAnimation.onMessage(param)
	if param.parent then

		if not param.dir then
			param.dir = "v"
		end

		param.parent:show()

		if not param.parent.msgTable then
			param.parent.msgTable ={}
		end

		if param.msg and param.msg ~= nil then
			table.insert(param.parent.msgTable,{msg = param.msg, onClick = param.onClick})
		end

		if not param.parent.mLayout then
			param.parent.size = param.parent:getContentSize()
			param.parent.mLayout = ccui.Layout:create():size(param.parent.size.width,param.parent.size.height):align(display.BOTTOM_LEFT, 0, 0):addTo(param.parent)
			param.parent.mLayout:setClippingEnabled(true)
		end
		if not param.parent.lastMsg and #param.parent.msgTable>0 then
			-- local temp_msg = GameUtilSenior.newUILabel({
			-- 	text = param.parent.msgTable[1].msg,
			-- 	font = "game.ttf",
			-- 	fontSize = param.fontSize,
			-- 	position = param.pos or cc.p(param.parent.size.width * 0.5, -param.parent.size.height * 0.5),
			-- 	anchor = cc.p(0.5,0),
			-- 	color = param.color or cc.c3b(0,255,0),
			-- 	opacity = param.opacity or 0,
			-- })--:addTo(param.parent.mLayout, 1, 9999)
			local msg_label = GUIRichLabel.new({size= cc.size(0, 0), space=2, ignoreSize = true,})
			
			local label = param.parent.msgTable[1].msg
			if param.htmlcolor then
				label =	"<font color='"..param.htmlcolor.."'>"..label.."</font>"
			end

	  		local msgSize = msg_label:setRichLabel(label, "alert", 22)
	  		msg_label:setAnchorPoint(cc.p(0.5, 0.5)):addTo(param.parent.mLayout, 1)
			if param.dir == "h" and not param.pos then
				msg_label:pos(param.parent.size.width + msgSize.width * 0.5, param.parent.size.height * 0.5)
			else  --这个判断是后加的
				msg_label:pos(0, param.parent.size.height * 0.5)
			end

			-- if param.parent:getName() ~= "post_bg" then
			-- 	local labelSize = msg_label:getContentSize()
			-- 	display.newRect(cc.rect(0,0,labelSize.width,labelSize.height), {fillColor = cc.c4f(0, 0, 0, 0.3), borderColor = cc.c4f(1, 1, 1, 0)}):addTo(msg_label,-1):align(display.BOTTOM_CENTER)
			-- end

			if param.parent.msgTable[1].onClick then
				msg_label:setTouchEnabled(true)
				msg_label:addClickEventListener(param.parent.msgTable[1].onClick)
			end
			param.parent.lastMsg = msg_label

			local cleanAction = nil
			local moveInAction, moveOutAction
			local moveTime = 1
			local delayTime = 3
			if not param.hold then
				
				local outPos = cc.p(param.parent.size.width * 0.5, param.parent.size.height*2)
				if param.dir == "h" then
					-- print("/////////////////////", param.parent.size.height)
					outPos = cc.p(- msgSize.width * 0.5, param.parent.size.height * 0.5)
					moveTime = (param.parent.size.width + msgSize.width) / 200
					delayTime = 0
					moveInAction = cca.moveTo(moveTime,cc.p(param.parent.size.width * 0.5, param.parent.size.height * 0.5))
					moveOutAction = cca.moveTo(moveTime, outPos)
				else
					moveInAction = cc.EaseExponentialOut:create(cca.spawn({cca.moveTo(moveTime,cc.p(param.parent.size.width * 0.5, param.parent.size.height*0.5))}))
					moveOutAction = cc.EaseExponentialOut:create(cca.spawn({cca.moveTo(moveTime, outPos)}))
				end
				cleanAction = cca.seq({
					moveOutAction,
					cca.removeSelf(),
					cca.callFunc(function (dx)
						param.parent.lastMsg = nil
					end)
				})
			end
			msg_label:runAction(
				cca.seq({
					moveInAction,
					cca.delay(delayTime),
					cleanAction,
					cca.callFunc(function()
						table.remove(param.parent.msgTable,1)
						if #param.parent.msgTable>0 then
							param.msg = nil
							GUIMessageAnimation.onMessage(param)
						else
							param.parent:hide()
						end
					end)

				})
			)
		end
	end
end

----param{parent,hold,msg,color,pos,fontSize,opacity}
----无消息堆栈,复用消息
----从第三条开始返回上一条消息
function GUIMessageAnimation.bottomMessage(param)
	if param.parent then
		if param.parent.lastMsg then
			param.parent.lastMsg:stopAllActions()
			param.parent.lastMsg:runAction(
				-- cca.seq({
					cc.EaseExponentialOut:create(cca.spawn({cca.fadeOut(1),cca.moveTo(1,cc.p(0,30))}))--,
					-- cca.removeSelf()
				-- })
			)
		end

		if not param.parent.mLayout then
			param.parent.mLayout = ccui.Layout:create()
			param.parent.size = param.parent:getContentSize()
			param.parent.mLayout:setContentSize(cc.size(param.parent.size.width,param.parent.size.height-5))
			param.parent.mLayout:setAnchorPoint(cc.p(0,0))
			param.parent.mLayout:setClippingEnabled(true)
			param.parent.mLayout:setPosition(cc.p(0,5))
			param.parent:addChild(param.parent.mLayout)
		end
		if not param.parent.mLayout:getChildByTag(100) then
			param.richWidget:setTag(100)
			param.parent.mLayout:addChild(param.richWidget)
		elseif not param.parent.mLayout:getChildByTag(101) then
			param.richWidget:setTag(101)
			param.parent.mLayout:addChild(param.richWidget)
		end
		param.richWidget:setPosition(cc.p(0,-50))
		
		param.richWidget:runAction(
			cca.seq({
				cc.EaseExponentialOut:create(cca.spawn({cca.fadeIn(1),cca.moveTo(1,cc.p(0,0))})),
				cca.delay(3)
			})
		)
		param.parent.lastMsg = param.richWidget

		return param.parent.mLayout:getChildByTag(201- param.richWidget:getTag())
	end
end

function GUIMessageAnimation.PanelMoveIn(panel)
	if panel then
		panel:setPosition(cc.p(1000,320))
		panel:setOpacity(0)
		panel:runAction(
			cc.EaseExponentialOut:create(
				cca.spawn({
					cca.fadeIn(1),
					cca.moveTo(1,cc.p(200,320))
				})
			)
		)
	end
	
end

function GUIMessageAnimation.PanelMoveOut(panel)
	if panel then
		panel:runAction(cca.seq({
			cca.spawn({
				cca.fadeOut(1),
				cca.moveTo(1,cc.p(-1000,320))
			}),
			cca.removeSelf()
			})
		)
	end
end

function GUIMessageAnimation.ForceDelPanel(panel)
	if panel then
		panel:stopAllActions()
		panel:removeFromParent()
	end
end

return GUIMessageAnimation