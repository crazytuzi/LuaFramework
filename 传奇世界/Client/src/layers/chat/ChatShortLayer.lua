local ChatShortLayer = class("ChatShortLayer", require("src/TabViewLayer"))

local InputNode = class("InputNode", function() return cc.Node:create() end)

local path = "res/chat/"

function ChatShortLayer:ctor(callback)
	local msgids = {CHAT_SC_GET_PHRASE_RET}
	require("src/MsgHandler").new(self, msgids)

	--g_msgHandlerInst:sendNetDataByFmtExEx(CHAT_CS_GET_PHRASE, "i", userInfo.currRoleStaticId)
	g_msgHandlerInst:sendNetDataByTableExEx(CHAT_CS_GET_PHRASE, "GetPhraseProtocol", {})
	addNetLoading(CHAT_CS_GET_PHRASE, CHAT_SC_GET_PHRASE_RET)

	self.callback = callback

	self.data = {}

	local bg = createScale9Sprite(self, "res/common/scalable/6.png", cc.p(0, 0), cc.size(400, 530), cc.p(0, 0.5))
	self.bg = bg
	local closeFunc = function()
		removeFromParent(self)
	end

	local titleBg = createSprite(bg, path.."title.png", cc.p(bg:getContentSize().width/2, 505), cc.p(0.5, 0))
	createLabel(titleBg, game.getStrByKey("chat_short_title"), getCenterPos(titleBg), cc.p(0.5, 0.5), 20, false, nil, nil, MColor.lable_yellow)

	local tipBg = createSprite(bg, "res/common/bg/titleLine4.png", cc.p(bg:getContentSize().width/2, 10), cc.p(0.5, 0))
	createLabel(tipBg, game.getStrByKey("chat_short_send"), getCenterPos(tipBg), cc.p(0.5, 0.5), 20, false, nil, nil, MColor.lable_black)

	self:createTableView(bg, cc.size(395, 440), cc.p(10, 50), true)
	self:updateData()
	
	registerOutsideCloseFunc(bg, closeFunc, true)
end

function ChatShortLayer:updateData()
	self:updateUI()
end

function ChatShortLayer:updateUI()
	self:getTableView():reloadData()
end

function ChatShortLayer:tableCellTouched(table, cell)
	local idx = cell:getIdx()
	local x, y = cell:getX(), cell:getY()
	local bg = cell:getChildByTag(10)

	if bg then
		local touch = cc.p(x, y)
	    if cc.rectContainsPoint(bg:getBoundingBox(), cc.p(touch.x, touch.y)) then
			if self.callback and self.data[idx+1] then
				self.callback(self.data[idx+1])
				--removeFromParent(self)
				startTimerAction(self, 0.1, false, function() removeFromParent(self) end)
			end
		end
	end
end

function ChatShortLayer:cellSizeForTable(table, idx) 
    return 73, 395
end

function ChatShortLayer:tableCellAtIndex(table, idx)
	local editBoxEventHandle = function(strEventName,pSender)
        local edit = tolua.cast(pSender,"ccui.EditBox") 

        if strEventName == "began" then --编辑框开始编辑时调用
        	log("began")
        	if self.data[idx+1] then
        		edit:setText(self.data[idx+1])
        		edit:setPosition(cc.p(display.width*2, edit:getPositionY()))
        	end
        elseif strEventName == "ended" then --编辑框完成时调用
        	edit:setPosition(cc.p(345, edit:getPositionY()))
        	log("ended")
        elseif strEventName == "return" then --编辑框return时调用
        	log("return")
        	local str = edit:getText()
        	log(str)
        	if string.utf8len(str) <= 40 then
        		--log("test 1")
        		self.data[idx+1] = str
        		local cell = table:cellAtIndex(idx)
        		local label = cell:getChildByTag(20)
        		--dump(label)
        		if label then
        			--log("test 2")
        			--label:setString(str)
        			--g_msgHandlerInst:sendNetDataByFmtExEx(CHAT_CS_SET_PHRASE, "isS", userInfo.currRoleStaticId, idx+1, str)
        			local t = {}
					t.index = idx+1
					t.phrase = str
					g_msgHandlerInst:sendNetDataByTableExEx(CHAT_CS_SET_PHRASE, "SetPhraseProtocol", t)
        			addNetLoading(CHAT_CS_SET_PHRASE, CHAT_SC_GET_PHRASE_RET)
        		end
        	else
        		TIPS({type = 1, str = game.getStrByKey("chat_short_tip_long")})
        	end
        	edit:setText("")
        	edit:setPosition(cc.p(345, edit:getPositionY()))
        elseif strEventName == "changed" then --编辑框内容改变时调用
        	log("changed")

        end
	end

	local function createItem(cell)
		local bg = createSprite(cell, "res/component/button/63.png", cc.p(0, 73/2), cc.p(0, 0.5))
		bg:setTag(10)
		if self.data[idx+1] then
			local str = self.data[idx+1]
			if string.utf8len(str) > 10 then
				str = string.utf8sub(str, 1, 10).."……"
			end
			local label = createLabel(cell, str, cc.p(50, 73/2), cc.p(0, 0.5), 20, false, nil, nil, MColor.lable_yellow)
			label:setTag(20)
		end

		local function editFunc()
			local function callback(str)
				--g_msgHandlerInst:sendNetDataByFmtExEx(CHAT_CS_SET_PHRASE, "isS", userInfo.currRoleStaticId, idx+1, str)
				local t = {}
				t.index = idx+1
				t.phrase = str
				g_msgHandlerInst:sendNetDataByTableExEx(CHAT_CS_SET_PHRASE, "SetPhraseProtocol", t)
        		addNetLoading(CHAT_CS_SET_PHRASE, CHAT_SC_GET_PHRASE_RET)
			end
			local inputNode = InputNode.new(self.data[idx+1], callback)	
		    self.bg:addChild(inputNode)
		    inputNode:setPosition(self.bg:convertToNodeSpace(cc.p(display.cx, display.cy)))
		end
		createTouchItem(bg, path.."edit.png", cc.p(345, bg:getContentSize().height/2), editFunc)
		--createSprite(bg, path.."edit.png", cc.p(345, bg:getContentSize().height/2), cc.p(0.5, 0.5))

		-- local editBox = createEditBox(bg , nil ,cc.p(345, bg:getContentSize().height/2) ,cc.size(34, 34))
		-- editBox:setAnchorPoint(cc.p(0.5, 0.5))
		-- editBox:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
		-- editBox:registerScriptEditBoxHandler(editBoxEventHandle)

	end

	local cell = table:dequeueCell()
	if nil == cell then
		cell = cc.TableViewCell:new() 
		createItem(cell)
	else
    	cell:removeAllChildren()
    	createItem(cell)
    end
	
    return cell
end

function ChatShortLayer:numberOfCellsInTableView(table)
   	return 6
end

function InputNode:ctor(str, callback)
	self.str = str or ""
	self.callback = callback

	local function setTeach(str)
		if self.richText then
			removeFromParent(self.richText)
			self.richText = nil
		end

		self.richText = require("src/RichText").new(self.bg, cc.p(self.bg:getContentSize().width/2, 170), cc.size(320, 100), cc.p(0.5, 0.5), 25, 20, MColor.lable_yellow)
	 	self.richText:addText(str)
	 	self.richText:format()
	end

	local editBoxHandler = function(strEventName,pSender)
        local edit = tolua.cast(pSender,"ccui.EditBox") 

        if strEventName == "began" then --编辑框开始编辑时调用
        	log("began")
        	setTeach("")
        	self.editBox:setText(self.str)
        elseif strEventName == "ended" then --编辑框完成时调用
        	log("ended")
        elseif strEventName == "return" then --编辑框return时调用
        	log("return")
     		local str = self.editBox:getText()
     		dump(str)
	    	--if string.len(str) > 0 then
	    		if string.utf8len(str) > 40 then
	    			str = string.utf8sub(str, 1, 40)
					TIPS({type =1 ,str = game.getStrByKey("chat_short_tip_long")})
					self.str = str
					setTeach(self.str)
				else
					self.str = str
					setTeach(self.str)
	    		end	
			--end
			self.editBox:setText("")
			if self.teachStr == "" then
        		--self.editBox:setPlaceHolder(game.getStrByKey("master_tip_input_teach"))
        	else
        		--self.editBox:setPlaceHolder("")
        	end
        elseif strEventName == "changed" then --编辑框内容改变时调用
        	log("changed")
        end
	end
	
	local bg = createSprite(self, "res/common/bg/bg31.png", cc.p(0, 0), cc.p(0.5, 0.5))
	self.bg = bg
	createLabel(bg, game.getStrByKey("chat_short_title"), cc.p(bg:getContentSize().width/2, 260), cc.p(0.5, 0.5), 22, true)
	createLabel(bg, game.getStrByKey("chat_short_input_tip"), cc.p(bg:getContentSize().width/2, 100), cc.p(0.5, 0), 18, true, nil, nil, MColor.red)

	local editBox = createEditBox(bg, nil, cc.p(bg:getContentSize().width/2, 160), cc.size(350, 160), MColor.lable_yellow, 20)
	self.editBox = editBox
	editBox:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
	--editBox:setPlaceHolder(game.getStrByKey("master_tip_input_teach"))
	editBox:setPlaceholderFontSize(20)
	editBox:registerScriptEditBoxHandler(editBoxHandler)
	--editBox:setText(self.teachStr)
	if self.str ~= "" then
		editBox:setPlaceHolder("")
	end
	
	local function closeFunc()
		removeFromParent(self)
	end
	createMenuItem(bg, "res/component/button/x2.png", cc.p(bg:getContentSize().width-30, bg:getContentSize().height-30), closeFunc)

	local function sureFunc()
		dump(self.str)
		if string.utf8len(self.str) > 40 then
			TIPS({type =1 ,str = game.getStrByKey("chat_short_tip_long")})
		else
			if self.callback then
				self.callback(self.str)
			end 
			removeFromParent(self)
		end	
	end
	local sureBtn = createMenuItem(bg, "res/component/button/50.png", cc.p(bg:getContentSize().width/2, 45), sureFunc)
	createLabel(sureBtn, game.getStrByKey("sure"), getCenterPos(sureBtn), cc.p(0.5, 0.5), 22, true)

	setTeach(self.str)

	registerOutsideCloseFunc(bg, closeFunc, true)
end

function ChatShortLayer:networkHander(buff,msgid)
	local switch = {
		[CHAT_SC_GET_PHRASE_RET] = function()
			log("get CHAT_SC_GET_PHRASE_RET")
			self.data = {}
			local t = g_msgHandlerInst:convertBufferToTable("GetPhraseRetProtocol", buff)
			local num = t.phraseCount
			for i,v in ipairs(t.phraseInfo) do
				self.data[i] = v
			end
			self:updateData()
		end
		,
	}

 	if switch[msgid] then 
 		switch[msgid]()
 	end
end

return ChatShortLayer