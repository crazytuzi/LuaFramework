local relive = class("relive", function () return cc.LayerColor:create(cc.c4b(255,255,128,96)) end)
function relive:ctor(attacker)
	-- body
	--cc.LayerColor:create(Color4B_color)
	addEffectWithMode(self,4)
	if getRunScene():getChildByName("npcChat") then
        getRunScene():removeChildByName("npcChat")  
    end--死亡时关闭对话面板
	local s_bg = createSprite(self, "res/common/5.png", cc.p(g_scrSize.width/2, g_scrSize.height/2))
	local sp = s_bg:getContentSize()
	self.sp = sp
	self.bg = s_bg
	self.sendMsgTime = 0
	createLabel(s_bg, game.getStrByKey("relive_text0"), cc.p(sp.width/2 , sp.height - 25),cc.p(0.5, 0.5),20,true)

	local menuItem = createMenuItem(s_bg,"res/component/button/50.png",cc.p(315,45),function() self:callback1() end)
	local str = game.getStrByKey("relive_text1")
	if G_MAINSCENE and G_MAINSCENE.map_layer and G_MAINSCENE.map_layer.mapID == 5104 then
		str = game.getStrByKey("relive_text10")
	end
	createLabel(menuItem, str, getCenterPos(menuItem),nil,18,true)

	local menuItem = createMenuItem(s_bg,"res/component/button/50.png",cc.p(100,45),function() self:callback2() end)
	local menu_size = menuItem:getContentSize()

	local mapID = G_MAINSCENE.map_layer.mapID
	if mapID == 7000 or mapID == 7001 or mapID == 7002 or mapID == 7003 or	   
	   mapID == 6000 or mapID == 6001 or mapID == 6002 or 
	   mapID == 6020 or mapID == 6021 or mapID == 6022 or
	   mapID == 6030 or mapID == 6031 or mapID == 6032 then

		createLabel(menuItem,  game.getStrByKey("relive_text9") ,cc.p(menu_size.width/2-15,menu_size.height/2),nil,18,true)
		menuItem:setEnabled(false)
	elseif G_MAINSCENE.map_layer.mapID == 5104 then
		createLabel(menuItem,  game.getStrByKey("relive_text9") ,cc.p(menu_size.width/2-15,menu_size.height/2),nil,18,true)
	else
		createLabel(menuItem,  game.getStrByKey("relive_text2") ,cc.p(menu_size.width/2-15,menu_size.height/2),nil,18,true)
	end

	str = "[30]"
	if G_MAINSCENE.map_layer.mapID == 5104 then
		menuItem:setEnabled(false)
		str = "[5]"
		performWithDelay(self, function()
			menuItem:setEnabled(true)
		end, 5)
	end
	self.timelabel = createLabel(menuItem, str, cc.p(menu_size.width-32,menu_size.height/2),cc.p(0.5, 0.5),18,true)
	self.time_now = 0
	--schedule(self, function () self:readTime() end, 1.0)
	startTimerActionEx(self, 1, true, function(passTime) self:readTime(passTime) end)
	
	local stoneNum = (G_MAINSCENE and G_MAINSCENE.map_layer and G_MAINSCENE.map_layer.costStoneNum ) and G_MAINSCENE.map_layer.costStoneNum or 1
	local richText = require("src/RichText").new(s_bg, cc.p(sp.width/2, sp.height/2 + 20), cc.size(sp.width - 50, 25), cc.p(0.5, 0.5), 20, 18, MColor.lable_yellow)
	richText:setAutoWidth()
	richText:addText(string.format(game.getStrByKey("relive_text11"), stoneNum, stoneNum * 20))
	richText:format()
	self.costStoneRichText = richText

	local MPackStruct = require "src/layers/bag/PackStruct"
	local MPackManager = require "src/layers/bag/PackManager"
	local pack = MPackManager:getPack(MPackStruct.eBag)
	self.ret_num = pack:countByProtoId(1002)
	local richText = require("src/RichText").new(s_bg, cc.p(sp.width/2, sp.height/2 - 10), cc.size(sp.width - 50, 25), cc.p(0.5, 0.5), 20, 18, MColor.lable_yellow)
	richText:setAutoWidth()
	richText:addText(string.format(game.getStrByKey("relive_text12"), self.ret_num))
	richText:format()
	self.curStoneNumLab = richText	

	local tmp_func = function(observable, event, pos, pos1, new_grid)
		if event == "-" or event == "+" then
			self.ret_num = pack:countByProtoId(1002)

			if self.curStoneNumLab then 
				removeFromParent(self.curStoneNumLab) 
			end
			
			local richText = require("src/RichText").new(s_bg, cc.p(sp.width/2, sp.height/2 - 10), cc.size(sp.width - 50, 25), cc.p(0.5, 0.5), 20, 18, MColor.lable_yellow)
			richText:setAutoWidth()
			richText:addText(string.format(game.getStrByKey("relive_text12"), self.ret_num))
			richText:format()
			self.curStoneNumLab = richText
		end
	end

	self:registerScriptHandler(function(event)
		if event == "enter" then 
			pack:register(tmp_func)

			if G_MAINSCENE then
				G_MAINSCENE.relive_layer = self
			end

			if g_EventHandler then
				g_EventHandler["ReliveNumChange"] = function(num)
						num = num or 1
						removeFromParent(self.costStoneRichText)
						local richText = require("src/RichText").new(s_bg, cc.p(sp.width/2, sp.height/2+20), cc.size(sp.width - 50, 25), cc.p(0.5, 0.5), 20, 18, MColor.lable_yellow)
						richText:setAutoWidth()
						richText:addText(string.format(game.getStrByKey("relive_text11"), num, num * 20))
						richText:format()
						self.costStoneRichText = richText
					end
			end

		elseif event == "exit" then
			pack:unregister(tmp_func)

			if G_MAINSCENE then
				G_MAINSCENE.relive_layer = nil
			end

			if g_EventHandler then
				g_EventHandler["ReliveNumChange"] = nil
			end
		end
	end)
	local Mnode = require "src/young/node"
	Mnode.listenTouchEvent({
	node = self,
	begin = function(touch)
		return true
	end,})
	local str_lab = nil;
    local isExist = false;
    -- 需要校验是否已经失效
    if attacker ~= nil then
        local cplusAttacker = tolua.cast(attacker, "SpriteMonster");
        if cplusAttacker ~= nil then
        	--dump(cplusAttacker:getMonsterId())
            local attackName = cplusAttacker:getTheName()
            if attackName ~= nil then
                local str = "^" .. "^c(yellow)" .. attacker:getTheName().."^".. "^c(red)" 
		        str_lab = "^c(red)" ..string.format(game.getStrByKey("relive_text3"),str).."^"
		        if cplusAttacker:getMonsterId() == 9008 or cplusAttacker:getMonsterId() == 9005 then
		        	str_lab = "^c(red)" ..string.format(game.getStrByKey("relive_text3_ex"),str).."^"
		        end
                isExist = true
            end
        end
    end
	if isExist == false then
		str_lab = "^c(red)" ..game.getStrByKey("relive_text4").."^"
	end

	local richText = require("src/RichText").new(s_bg, cc.p(sp.width/2, sp.height/2+70), cc.size(sp.width - 50, 40), cc.p(0.5, 0.5), 20, 18, MColor.lable_yellow)
	richText:setAutoWidth()
	richText:addText(str_lab)
	richText:format()	
end

function relive:readTime(passTime)
	-- body
	local totalTime = 30
	if G_MAINSCENE and G_MAINSCENE.map_layer and G_MAINSCENE.map_layer.mapID == 5104 then
		totalTime = 5
	end
	-- local MPackStruct = require "src/layers/bag/PackStruct"
	-- local MPackManager = require "src/layers/bag/PackManager"
	-- local pack = MPackManager:getPack(MPackStruct.eBag)
	-- self.ret_num = pack:countByProtoId(1002)
	-- self.labelnum:setString(""..self.ret_num)

	self.time_now = self.time_now + passTime
	local showTime = totalTime - self.time_now
	if showTime < 0 then
		showTime = 0
	end
	self.timelabel:setString("["..showTime.."]")
	if self.time_now >= totalTime then
		self:callback2()
	end
end

function relive:callback1( ... )
	if G_ROLE_MAIN and G_ROLE_MAIN:isAlive() then
		print("I am aliveD")
		removeFromParent(self)
		return
	end	
	if self:checkSendMsgTime() then
		return
	end

	local temp = 0
	local MPackStruct = require "src/layers/bag/PackStruct"
	local MPackManager = require "src/layers/bag/PackManager"
	local pack = MPackManager:getPack(MPackStruct.eBag)
	if ((not G_NO_OPEN_PAY) and G_ROLE_MAIN and G_ROLE_MAIN.currIngot < 20) and self.ret_num  <= 0 then
		self:messageBoxCharge()
		return
	end
	g_msgHandlerInst:sendNetDataByTable(FRAME_CS_RELIVE, "FrameReliveProtocol", {flag=1})
	
	local totalTime = 30
	if G_MAINSCENE and G_MAINSCENE.map_layer and G_MAINSCENE.map_layer.mapID == 5104 then
		totalTime = 5
	end	
	if self.time_now >= totalTime then
		self.sendMsgTime = self.sendMsgTime + 1
	end

    if G_MAINSCENE and G_MAINSCENE.map_layer and G_MAINSCENE.map_layer.mapID == 5104 then
	    removeFromParent(self)
        G_MAINSCENE.relive_layer = nil
    end
end

function relive:checkSendMsgTime()
	if self.sendMsgTime > 10 then
		removeFromParent(self)
		local func = function()
			game.ToLoginScene()
		end
		local text = game.getStrByKey("bad_heart_speed_tip")
		MessageBox(text, game.getStrByKey("sure"),func)
		return true
	end
	return false
end

function relive:callback2( ... )
	if G_ROLE_MAIN and G_ROLE_MAIN:isAlive() then
		print("I am aliveD")
		removeFromParent(self)
		return
	end

	if self:checkSendMsgTime() then
		return
	end
	g_msgHandlerInst:sendNetDataByTable(FRAME_CS_RELIVE, "FrameReliveProtocol", {flag=0})
	--addLoadingNode(1)
    --removeFromParent(self)
    self.sendMsgTime = self.sendMsgTime + 1

    if G_MAINSCENE and G_MAINSCENE.map_layer and G_MAINSCENE.map_layer.mapID == 5104 then
	    removeFromParent(self);
        G_MAINSCENE.relive_layer = nil;
    end
end

function relive:messageBoxCharge()
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
	self.bg:addChild(retSprite, 400)

	retSprite:setPosition(cc.p(self.sp.width/2, self.sp.height/2))
	SwallowTouches(retSprite)
end

return relive
