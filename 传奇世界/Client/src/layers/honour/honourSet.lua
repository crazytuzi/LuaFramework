local honourSet = class( "honourSet", function() return cc.Layer:create() end)

function honourSet:ctor(honourParams)
	local bg = createSprite(self,"res/common/bg/bg18.png",g_scrCenter)
	local closeFunc = function() 
      	removeFromParent(self)
  	end
  	createLabel(bg,game.getStrByKey("texturePic"),cc.p(bg:getContentSize().width/2,bg:getContentSize().height-25),nil,25,true,nil,nil,MColor.lable_yellow)
	local closeBtn = createTouchItem(bg,"res/component/button/x2.png",cc.p(bg:getContentSize().width - 40 ,bg:getContentSize().height - 25),closeFunc)
  	registerOutsideCloseFunc(bg, closeFunc,true)

  	local bg_left_transparent_padding = 17
	local frame_width = 6
	local padding_outer = 25
	local titleList = {game.getStrByKey("inlay"),game.getStrByKey("activation"),game.getStrByKey("discompose")}
	local bg1 = cc.Sprite:create("res/common/scalable/panel_outer_base.png", cc.rect(0, 0, 790 - frame_width * 2, 454 - frame_width * 2))
	bg1:setAnchorPoint(cc.p(0, 0))
	bg1:setPosition(cc.p(bg_left_transparent_padding + 16 + frame_width, 17 + frame_width))
	bg1:getTexture():setTexParameters(gl.LINEAR, gl.LINEAR, gl.REPEAT, gl.REPEAT)
	bg:addChild(bg1)
  	createScale9Sprite(bg, "res/common/scalable/panel_outer_frame_scale9.png", cc.p(bg_left_transparent_padding + 16, 17), cc.size(790, 454), cc.p(0, 0))

	createScale9Sprite(
	    bg,
	    "res/common/scalable/panel_inside_scale9.png",
	    cc.p(bg_left_transparent_padding + padding_outer, padding_outer),
	    cc.size(112, 436),
	    cc.p(0, 0)
	)

	-- createSprite(bg, "res/layers/equipSelect/equip_select_frame.png", cc.p(160, 24), cc.p(0, 0))
	-- createSprite(bg, "res/layers/equipSelect/equip_select_info_bg.png", cc.p(468, 37), cc.p(0, 0))
	createSprite(bg, "res/common/bg/bg68.png",cc.p(162, 24), cc.p(0, 0))
	local choose = 0
	self.select_index = choose
	self.select_layers = {}
	local tabReq = {require("src/layers/honour/inlay"),require("src/layers/honour/activation"),require("src/layers/honour/decompose")}
	
  	local callback = function(idx)
    	print(idx,"555555") 
    	if self.select_index == idx then
			return
		end
		self.select_index = idx
		for k,v in pairs(self.select_layers) do
			if idx ~= k and v then
				removeFromParent(v)
			else
				self.select_layers[idx] = tabReq[idx].new(honourParams)
				self.select_layers[idx]:setPosition(-49,-30)
				bg:addChild(self.select_layers[idx],125)				
			end
		end
		if not self.select_layers[idx] then
			self.select_layers[idx] = tabReq[idx].new(honourParams)
			self.select_layers[idx]:setPosition(-49,-30)
			bg:addChild(self.select_layers[idx],125)
		end
  	end

  	callback(self.select_index+1)

	local btnGroup = {def = "res/component/button/43.png",sel = "res/component/button/43_sel.png"}
	local node = require("src/LeftSelectNode").new(bg,titleList,cc.size(125, 430),cc.p(42,29),callback,btnGroup,nil,choose)
	node:setLocalZOrder(130)
end




return honourSet