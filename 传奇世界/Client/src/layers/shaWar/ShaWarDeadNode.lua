local ShaWarDeadNode = class("ShaWarDeadNode", function() return cc.LayerColor:create(cc.c4b(255,255,128,96)) end)

function ShaWarDeadNode:ctor(data)
	self.data = data

	local s_bg = createSprite(self, "res/common/5.png", cc.p(g_scrSize.width/2 , g_scrSize.height/2))
	local sp = s_bg:getContentSize()
	local centPos = getCenterPos(s_bg)
	local midPos = centPos.x
	addEffectWithMode(self, 4)
	createLabel(s_bg, game.getStrByKey("relive_text0"), cc.p(sp.width/2 , sp.height - 25), cc.p(0.5, 0.5), 20, true)
    if data.killerName then        
        if data.killerName == "" then
            data.killerName = game.getStrByKey("monster")
        end
        local str = string.format(game.getStrByKey("empire_dead_info_killer1"), data.killerName)
		local richText = require("src/RichText").new(s_bg, cc.p(midPos, 220), cc.size(320, 30), cc.p(0.5,0.5), 20, 20, MColor.yellow)
		richText:setAutoWidth()
		richText:addText(str)
		richText:format()
	end

	local MPackStruct = require "src/layers/bag/PackStruct"
	local MPackManager = require "src/layers/bag/PackManager"
	local pack = MPackManager:getPack(MPackStruct.eBag)
	local Num = pack:countByProtoId(1002)
		
	local str = string.format(game.getStrByKey("relive_text11"), self.data.needStoneNum, self.data.needStoneNum * 20)
	local richText = require("src/RichText").new(s_bg, cc.p(sp.width/2, sp.height/2 + 20), cc.size(sp.width - 50, 30), cc.p(0.5, 0.5), 20, 18, MColor.lable_yellow)
	richText:setAutoWidth()
	richText:addText(str)
	richText:format()

	local str = string.format(game.getStrByKey("relive_text12"), Num)
	local richText = require("src/RichText").new(s_bg, cc.p(sp.width/2, sp.height/2 - 10), cc.size(sp.width - 60, 30), cc.p(0.5, 0.5), 20, 18, MColor.lable_yellow)
	richText:setAutoWidth()
	richText:addText(str)
	richText:format()	

	local item = createMenuItem(s_bg, "res/component/button/50.png", cc.p(100, 45), function() self:relieveCallBack1() end)
	local lab = createLabel(item, "回城复活[" .. data.aliveTimeLeft .."]", getCenterPos(item), nil, 22, true)
	self.reliveBtn1 = item
	self.reliveBtnLab = lab
	item:setEnabled(false)

	local item = createMenuItem(s_bg, "res/component/button/50.png", cc.p(315, 45), function() self:relieveCallBack2() end)
	createLabel(item, "原地复活", getCenterPos(item), nil, 22, true)
	self.reliveBtn2 = item
	if G_MAINSCENE and G_MAINSCENE.map_layer and G_MAINSCENE.map_layer.mapID == G_SHAWAR_DATA.mapId1 then
		self.reliveBtn2:setEnabled(false)
	end

	self:readTime()

	game.setAutoStatus(0)

	registerOutsideCloseFunc(self, function() end, true)

    self:registerScriptHandler(function(event)
        if event == "enter" then
        elseif event == "exit" then
        	if G_MAINSCENE and G_MAINSCENE.shaWarDeadLayer then
        		G_MAINSCENE.shaWarDeadLayer = nil
        	end
        end
    end)
end

function ShaWarDeadNode:readTime()
	local time = self.data.aliveTimeLeft
	startTimerAction(self, 1, true, function()
		if time > 1 then
			time = time - 1
			self.reliveBtn1:setEnabled(false)
			if self.reliveBtnLab and time >= 0 then
				self.reliveBtnLab:setString("回城复活[" .. time .."]")
			end
		else
			removeFromParent(self)
		end
	end)
end

function ShaWarDeadNode:relieveCallBack1()

end

function ShaWarDeadNode:relieveCallBack2()
	local MPackStruct = require "src/layers/bag/PackStruct"
	local MPackManager = require "src/layers/bag/PackManager"
	local pack = MPackManager:getPack(MPackStruct.eBag)
	local Num = pack:countByProtoId(1002)
	if Num < self.data.needStoneNum and (G_ROLE_MAIN and G_ROLE_MAIN.currIngot < self.data.needStoneNum * 20) and not G_NO_OPEN_PAY then
		self:messageBoxCharge()
		return
	end

	g_msgHandlerInst:sendNetDataByTableExEx(SHAWAR_CS_NEED_RELIVE, "ShaNeedReliveProtocol", {})
end

function ShaWarDeadNode:messageBoxCharge()
	local retSprite = cc.Sprite:create("res/common/5.png")
	local r_size  = retSprite:getContentSize()
	createLabel(retSprite, game.getStrByKey("tip"), cc.p(r_size.width/2, r_size.height -12), cc.p(0.5,1.0), 22, true)

	local contentRichText = require("src/RichText").new(retSprite, cc.p(r_size.width/2, r_size.height/2 + 30), cc.size(r_size.width-100, 100), cc.p(0.5, 0.5), 25, 20, MColor.white)
	contentRichText:addText(game.getStrByKey("noGold"), MColor.white)
	contentRichText:setAutoWidth()
	contentRichText:format()

	local removeFunc = function()
	    if retSprite then
	        removeFromParent(retSprite)
	    end
	end	

	local funcYes = function()
		removeFunc()
		if G_NO_OPEN_PAY then
            TIPS( { type = 1 , str = game.getStrByKey( "fun_not_open_tips" ) } )
        else
			local sub_node = require("src/layers/pay/PayView").new()
			if sub_node and G_MAINSCENE then
				G_MAINSCENE:addChild(sub_node, 410)
			end
        end
	end

	local funcNo = function()
		removeFunc()
	end

	local btn_img,spanx = "res/component/button/50.png",0
	if noCallback == false then
		btn_img = "res/component/button/51.png"
		spanx = 30
	end
	local menuItem = createMenuItem(retSprite, btn_img, cc.p(315+spanx, 45), funcYes)
	createLabel(menuItem, game.getStrByKey("sure") , getCenterPos(menuItem), nil, 22, true)

	local menuItem = createMenuItem(retSprite, btn_img, cc.p(100-spanx, 45), funcNo )
	createLabel(menuItem, game.getStrByKey("cancel"), getCenterPos(menuItem), nil, 22, true)
	self:addChild(retSprite, 400)

	retSprite:setPosition(cc.p(g_scrSize.width/2, g_scrSize.height/2))
	SwallowTouches(retSprite)
end

return ShaWarDeadNode