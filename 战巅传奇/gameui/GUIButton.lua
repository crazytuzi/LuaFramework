local GUIButton = {}

local dir = {
	["left"] = cc.p(-1,0),
	["right"] = cc.p(1,0),
	["top"] = cc.p(0,1),
	["bottom"] = cc.p(0,-1),
}

function GUIButton.showBtn(params)
	if params.needBg then
		local btn_bg = params.parent:getChildByName("btn_bg")
		if not btn_bg then
			local bg_dir = dir[params.btnDir].x == 0 and "Y" or "X"
			local width = (bg_dir == "Y" and 1 or (#params.btnName))*params.btnDis + 6
			local height = (bg_dir == "X" and 1 or (#params.btnName))*params.btnDis + 5
			btn_bg = ccui.ImageView:create("null", ccui.TextureResType.plistType)
			:addTo(params.parent,-1):align(display.LEFT_TOP, -3, 0)
			btn_bg:setScale9Enabled(true)
			btn_bg:size(width, height)
			btn_bg:setName("btn_bg")
			btn_bg.dir = bg_dir
			btn_bg["setScale"..bg_dir](btn_bg, 0.01)
			btn_bg:runAction(cca.scaleTo(0.3, 1, 1))
		else
			btn_bg:stopAllActions()
			local bg_dir = dir[params.btnDir].x == 0 and "Y" or "X"
			local width = (bg_dir == "Y" and 1 or (#params.btnName))*params.btnDis
			local height = (bg_dir == "X" and 1 or (#params.btnName))*params.btnDis
			btn_bg:size(width, height)

			if params.parent.showFlag then
				btn_bg:show()
				btn_bg:runAction(
					cca.sineOut(cca.scaleTo(0.3, 1, 1))
				)
			else
				btn_bg:runAction(
					cca.seq({
						cca.sineOut(cca.scaleTo(0.3, btn_bg.dir=="X" and 0.01 or 1, btn_bg.dir=="Y" and 0.01 or 1)),
						cca.hide()
					})
				)
			end
		end
	end

	for i=1,#params.btnName do
		local child = params.parent:getChildByName(params.btnName[i])
		if not child then
			child = ccui.Button:create(params.btnName[i], params.btnName[i], "", ccui.TextureResType.plistType)
				:addTo(params.parent, -1)
				:setName(params.btnName[i])
				:align(display.LEFT_BOTTOM,0,0)
				:setPressedActionEnabled(true)

			GUIFocusPoint.addUIPoint(child,params.btnFunc)
		end
		local pos = cc.p(0,0)
		child:stopAllActions()
		child:setTouchEnabled(false)
		local offsetY = 0
		if params.btnName[i]=="main_bag" then
			offsetY=5
		end
		if params.parent.showFlag then
			child:setPosition(cc.p(0,0))
			pos = cc.p(dir[params.btnDir].x*params.btnDis*i, dir[params.btnDir].y*params.btnDis*i+offsetY)
		else
			child:setPosition(cc.p(dir[params.btnDir].x*params.btnDis*i, dir[params.btnDir].y*params.btnDis*i+offsetY))
		end
		if params.showAction then
			if not child:getChildByName("anim") then
				local topAnim = cc.Sprite:create()
					:align(display.CENTER, 15, 60)
					:setName("anim")
					:addTo(child)
					:setBlendFunc({src = gl.SRC_ALPHA, dst = gl.ONE})
					if params.btnName[i]~="main_bag" then
						-- cc.AnimManager:getInstance():getBinAnimateAsync(topAnim,4,990014,0,0,true)
					end
			end
		end

		if params.runAction then
			-- local scale=1.0
			-- if not params.parent.showFlag then
			-- 	-- scale=0.5
			-- else
			-- 	child:setVisible(params.parent.showFlag)
			-- end

			child:runAction(cca.seq({
					cca.spawn({
						-- cc.EaseBackOut:create(cc.MoveTo:create(0.4,pos)),
						cca.sineOut(cca.moveTo(0.3,pos)),
						-- cca.scaleTo(0.2,scale)
					}),
					cca.cb(function ()
						child:setTouchEnabled(params.parent.showFlag)
						child:setVisible(params.parent.showFlag)
					end)
				})
			)
		else
			child:setPosition(pos)
		end
		child:setVisible(params.parent.showFlag)
	end

	if params.touchGroup then
		if not params.parent.addListener then
			params.parent.addListener = true
			cc.EventProxy.new(GameSocket, params.parent)
			:addEventListener(GameMessageCode.EVENT_CLOSE_EXTEND_MOREFUNC, function (event)
				if not params.parent.showFlag then return end
				local isTouchChild
				for i,v in ipairs(params.parent:getChildren()) do
					if GameUtilSenior.hitTest(v,event.pos) then
						isTouchChild = true
						break
					end
				end
				if not isTouchChild and GameUtilSenior.hitTest(params.parent,event.pos) then
					isTouchChild = true
				end
				if not isTouchChild then
					params.btnFunc(params.parent)
				end
			end)
		end
	end
end

return GUIButton