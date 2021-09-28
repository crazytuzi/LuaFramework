--[[
 --
 -- add by vicky
 -- 2014.09.15
 --
 --]]


 local data_open_open = require("data.data_open_open") 


 local OpenLayer = class("OpenLayer", function()
 		return require("utility.ShadeLayer").new()
 	end)
 
 function OpenLayer:onEnter()
 	TutoMgr.active()

 end

 function OpenLayer:onExit()
 	TutoMgr.removeBtn("gongnengkaifang_btn_confirm")
 end
 
 function OpenLayer:ctor(param) 
 	ResMgr.removeMaskLayer()
 	local systemId = param.systemId
 	self._confirmFunc = param.confirmFunc -- 确定走的函数
 	self._goFunc = param.goFunc 	--前往查看
 	-- local isTuto = param.isTuto or false
 	self:setNodeEventEnabled(true)


 	self._rootnode = {}
	local proxy = CCBProxy:create()

	local node = CCBuilderReaderLoad("shengji/open_layer.ccbi", proxy, self._rootnode)
	node:setPosition(display.width/2, display.height/2)
	self:addChild(node)

	-- 确定按钮
	local confirmBtn = self._rootnode["confirmBtn"]
	GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
	confirmBtn:addHandleOfControlEvent(function(eventName,sender)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
		PostNotice(NoticeKey.REMOVE_TUTOLAYER)
		if self._confirmFunc ~= nil then 
			self._confirmFunc()
		end
        self:removeFromParentAndCleanup(true)
    end, CCControlEventTouchUpInside)

    -- 教学期间，隐藏确定按钮，否则隐藏查看按钮
	-- 前往查看
	local goBtn = self._rootnode["goBtn"]
	local layer = self._rootnode["tag_bg"]
	TutoMgr.addBtn("gongnengkaifang_btn_confirm",layer)

	goBtn:addHandleOfControlEvent(function(eventName,sender)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
		PostNotice(NoticeKey.REMOVE_TUTOLAYER)
		if self._goFunc ~= nil then 
			self._goFunc()
		else
			GameStateManager:ChangeState(GAME_STATE.STATE_MAIN_MENU)
		end
		
        self:removeFromParentAndCleanup(true)
    end, CCControlEventTouchUpInside)

	--判断是否是
	local isTuto = TutoMgr.checkActive()
	if isTuto then 
		confirmBtn:setVisible(false)
	else
		goBtn:setVisible(false)
	end
	

	local item 
	for i, v in ipairs(data_open_open) do 
		if v.system == systemId then
			item = v 
			break 
		end
	end 

	if item ~= nil and item.prama_num == 1 or item.prama_num == 4 then 
		self._rootnode["lbl_node_" .. item.prama_num]:setVisible(true)
		local lbl_1 = self._rootnode["lbl_" .. item.prama_num .. "_1"] 
		lbl_1:setString(item.prama1) 

		if item.prama_num == 4 then 
			local lbl_2 = self._rootnode["lbl_4_2"]
			local lbl_3 = self._rootnode["lbl_4_3"]
			local lbl_4 = self._rootnode["lbl_4_4"]
			if item.prama2 ~= nil then 
				lbl_2:setString(tostring(item.prama2))
			end 
			if item.prama3 ~= nil then 
				lbl_3:setString(tostring(item.prama3))
			end 
			if item.prama4 ~= nil then 
				lbl_4:setString(tostring(item.prama4))
			end 
			if item.prama2 ~= nil then 
				local len = string.utf8len(item.prama2) 
				if len == 5 or len == 6 then 
					lbl_1:setPosition(lbl_1:getPositionX() - 30, lbl_1:getPositionY())
					lbl_2:setPosition(lbl_2:getPositionX() - 30, lbl_2:getPositionY())
					if len == 6 then 
						lbl_3:setPosition(lbl_3:getPositionX() + 30, lbl_3:getPositionY())
					end
				end
			end 
		end 	
	end

	-- 图标
	-- dump(systemId)
	local checkIcon = OPENCHECK_ICON_NAME[systemId]
	if checkIcon[1] == 1 then 
		display.addSpriteFramesWithFile("ui/ui_toplayer.plist", "ui/ui_toplayer.pvr.ccz")
	elseif checkIcon[1] == 2 then
		display.addSpriteFramesWithFile("ui/ui_bottom2.plist", "ui/ui_bottom2.pvr.ccz")
	elseif checkIcon[1] == 3 then
		display.addSpriteFramesWithFile("ui/ui_bottom_layer.plist", "ui/ui_bottom_layer.pvr.ccz")
	elseif checkIcon[1] == 4 then 
		display.addSpriteFramesWithFile("ui/ui_nbhuodong_icons.plist", "ui/ui_nbhuodong_icons.png") 
	end
	
	-- dump(checkIcon)

	local icon = self._rootnode["open_icon"]
	icon:setDisplayFrame(display.newSprite(checkIcon[2]):getDisplayFrame()) 
	
	if checkIcon[1] == 10 then 
		icon:setScaleX(0.6)
		icon:setScaleY(0.6)
		local topSp = display.newScale9Sprite("ui/ui_huodong/ui_huodong_cover.png",
					 0, 0, CCSize(icon:getContentSize().width * 1.05, icon:getContentSize().height * 1.1))
		topSp:setPosition(icon:getContentSize().width/2, icon:getContentSize().height/2) 
		icon:addChild(topSp)

	else
		icon:setDisplayFrame(display.newSprite(checkIcon[2]):getDisplayFrame()) 
	end

 end


 return OpenLayer 
