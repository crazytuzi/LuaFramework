GUINumToast = {}

local ACTION = {
	RUN_BOTTOM = 1,
	RUN_BOTTOM_STACK = 2,
}
local curString = ""
function GUINumToast.handleAttrPlus(parent, param)
	if parent.msgMidMax == nil then parent.msgMidMax = 3 end						--控制最大存在个数
	if parent.msgMargin == nil then parent.msgMargin = 40 end						--控制控件尺寸

	-- if parent.movingHintTags == nil then parent.movingHintTags = {} end
	-- if parent.curMovingHintAmount == nil then parent.curMovingHintAmount = 0 end
	if parent.disapperIntarval == nil then parent.disapperIntarval = 3 end			--控制存在时间
	
	parent.movingHints = parent.movingHints or {}

	local msgTable = param.msgTable
	
	--重新设置位置
	local function updateMsgList()
		for i,v in ipairs(parent.movingHints) do
			if i <= parent.msgMidMax then
				if GameUtilSenior.isObjectExist(v) then
					v:setPositionY(parent.msgMargin * (i - 1))
				end
			else
				if GameUtilSenior.isObjectExist(v) then
					v:removeFromParent()
				end
				table.remove(parent.movingHints, #parent.movingHints)
			end
		end
	end

	local function addNewMsg(msgInfo)
		local movingHint, label
		local anchor = parent.anchor or display.BOTTOM_CENTER
		if param.richlabel then
			local fontSize = param.fontSize or 15
			local width = (fontSize + 2) * GameUtilSenior.getColorJsonLength(msgInfo)

			movingHint = GUIRichLabel.new({size = cc.size(width, fontSize), outline = param.outline})
				:align(anchor or display.CENTER)
				:addTo(parent)


			label = GameUtilSenior.clearJsonColor(msgInfo)
			if param.htmlcolor then
				label =	"<font color='"..param.htmlcolor.."'>"..label.."</font>"
			end

			local pSize = movingHint:setRichLabel(label, "", fontSize)
			-- 增加底图资源
			if param.resBg then
				local imgResBg = ccui.ImageView:create(param.resBg, ccui.TextureResType.plistType)
					:align(display.CENTER, pSize.width * 0.5, pSize.height * 0.5)
					:addTo(movingHint, -1)
				local mSize = imgResBg:getContentSize()
				if pSize.width > mSize.width then
					imgResBg:setScale9Enabled(true):setCapInsets(cc.rect(mSize.width * 0.5, mSize.height * 0.5, 1, 1)):setContentSize(cc.size(pSize.width + 20, mSize.height))
				end
			end
			
			movingHint:runAction(cca.seq({cca.delay(parent.disapperIntarval), cca.fadeOut(1), cca.cb(function ()
				--清理配置表
				table.remove(parent.movingHints, #parent.movingHints)
			end), cca.removeSelf()}))
			table.insert(parent.movingHints, 1, movingHint)
			updateMsgList()
		end
	end
	addNewMsg(msgTable[#msgTable])
end


function GUINumToast.handleValueChange(parent, param)
	if parent.msgMidMax == nil then parent.msgMidMax = 3 end						--控制最大存在个数
	if parent.msgMargin == nil then parent.msgMargin = 40 end						--控制控件尺寸
	if parent.movingHintTags == nil then parent.movingHintTags = {} end
	if parent.curMovingHintAmount == nil then parent.curMovingHintAmount = 0 end
	if parent.disapperIntarval == nil then parent.disapperIntarval = 3 end			--控制存在时间

	local msgTable = param.msgTable or GameSocket.msgMid
	local flyIntoBottomAni
	local flyOutBottomAni
	local updateMsgBottom
	local updateBottomList
	local timerAnimationBottom

	function flyIntoBottomAni (text_info)
		-- if curString==text_info then return end
		curString=text_info
		local num = #msgTable - 1
		if num > parent.msgMidMax - 1 then num = parent.msgMidMax - 1 end
		local movingHint,movingHintInfo,imgTitle,imgSymbol,pSpawnWidge,valueBg
		local msgM = parent.msgMargin * (parent.msgMidMax-num)

		if msgTable == GameSocket.msgMid then
			local temp1 = string.find(text_info,":")
			local movingHintInfoText = string.sub(text_info,temp1+1)
			local imgType = string.sub(text_info,2,temp1-1)

			-- print(text_info)
			
			local fntRes = "16"
			local award = "green_plus"
			if string.sub(text_info,1,1) == "-" then
				award = "red_sub"
				fntRes = "17"
			end

			-- print(imgType,award,"=================")

			imgSymbol = ccui.ImageView:create()
				:loadTexture("img_attribute_"..award, ccui.TextureResType.plistType)
			imgTitle = ccui.ImageView:create()
				:loadTexture("img_"..imgType.."_green_plus", ccui.TextureResType.plistType)
			movingHintInfo = ccui.TextAtlas:create("0123456789:","image/typeface/num_"..fntRes..".png", 18, 22,"0")
				:setString(movingHintInfoText)
			valueBg = ccui.ImageView:create()
				:loadTexture("valuebg", ccui.TextureResType.plistType)

			local imgSymbolSize = imgSymbol:getContentSize()
			local imgTitleSize = imgTitle:getContentSize()
			local movingHintInfoSize = movingHintInfo:getContentSize()

			movingHint = ccui.Layout:create()
				:setContentSize(cc.size(imgSymbolSize.width+imgTitleSize.width + movingHintInfoSize.width,imgTitleSize.height))
				:align(display.CENTER_LEFT, 180, display.cy * 1.2 - parent.msgMargin * parent.msgMidMax)
				:addTo(parent)

			valueBg:align(display.LEFT_CENTER, 20, 0)
				:addTo(movingHint)
			imgSymbol:align(display.LEFT_CENTER, 0, 0)
				:addTo(movingHint)
			imgTitle:align(display.LEFT_CENTER, imgSymbolSize.width, 0)
				:addTo(movingHint)
			movingHintInfo:align(display.LEFT_CENTER, imgSymbolSize.width + imgTitleSize.width, 0)
				:addTo(movingHint)

			movingHint:setOpacity(0)
			pSpawnWidge = -50
		else
			if param.parent.type then
				if string.find(param.parent.type,"center") then
					local msg = GameUtilSenior.decode(text_info)[1][1]
					if not string.find(msg,":") then return end
					local textInfo,coordinateY
					textInfo = ":"..string.sub(msg,(string.find(msg,":"))+1)
					local anchor = parent.anchor
					movingHint = display.newBMFontLabel({
						text = textInfo,
						font = "image/typeface/img_"..param.parent.type..".fnt"
					})

					movingHint:align(parent.anchor, display.cx * 1.05, display.cy)
						:scale(1)
						:addTo(parent)
					movingHint:setOpacity(0)
					msgM = 0
					pSpawnWidge = 0
				end
			else
				if string.find(text_info,"内功") then return end
				local anchor = display.BOTTOM_CENTER
				if parent.anchor ~= nil then
					anchor = parent.anchor
				end
				if param.richlabel then
					local fontSize = param.fontSize or 15
					local width = fontSize * GameUtilSenior.getColorJsonLength(text_info) + 10
					movingHint = GUIRichLabel.new({size = cc.size(width, fontSize)})
					movingHint:setRichLabel(GameUtilSenior.analyseColorJson(text_info), "", fontSize)
					if param and param.type == "right" then
						movingHint:align(anchor, 0, 30+parent.msgMargin * parent.msgMidMax)
					else
						-- print("RTV",parent:getName(),text_info)
						movingHint:align(display.CENTER)
					end
					movingHint:addTo(parent)
				elseif param.inmapInfo then
					local imgMapTitle = ccui.ImageView:create()
						:loadTexture("img_entertheMap", ccui.TextureResType.plistType)
					local imgMapBG = ccui.ImageView:create()
						:loadTexture("img_entertheMapBG", ccui.TextureResType.plistType)
						:setScale9Enabled(true)
					local inMapWord = GameUtilSenior.newUILabel({
						text = text_info,
						font = "image/typeface/game.ttf",
						fontSize = 20,
						color = GameBaseLogic.getColor("0x00C800"),
					})
					local imgMapTitlelSize = imgMapTitle:getContentSize()
					local imgMapBGSize = imgMapBG:getContentSize()
					local inMapWordSize = inMapWord:getContentSize()

					movingHint = ccui.Layout:create()
						:align(display.CENTER, 0, display.cy*1.5)

					imgMapTitle:align(display.CENTER_LEFT,20, imgMapBGSize.height/2):addTo(imgMapBG)
					inMapWord:align(display.CENTER_LEFT,25 + imgMapTitlelSize.width, imgMapBGSize.height/2+3):addTo(imgMapBG)
					imgMapBG:setContentSize(cc.size(25 + imgMapTitlelSize.width + inMapWordSize.width+25,imgMapBGSize.height))
						:align(display.CENTER)
						:addTo(movingHint)

					movingHint:addTo(parent)
				else
					movingHint = GameUtilSenior.newUILabel({
						text = text_info,
						font = "image/typeface/game.ttf",
						fontSize = param.fontSize or 20,
						color = param.color or cc.c3b(0,255,0),
						opacity = param.opacity or 0
					})
				
					movingHint:align(anchor, 0,0):addTo(parent)
				end
				pSpawnWidge = 0
			end
		end
		parent.curMovingHintAmount = parent.curMovingHintAmount + 1
		movingHint:setTag(parent.curMovingHintAmount)
		table.insert(parent.movingHintTags, parent.curMovingHintAmount)
		local pSpawn
		local delayTime = 0.1
		if param.richlabel then
			delayTime = 0
		end
		if param.scaleAction then
			movingHint:scale(0.5)
			pSpawn = cca.seq({cca.scaleTo(0.25, 2),cca.scaleTo(0.25, 1), cca.spawn({cca.moveBy(0.5, pSpawnWidge, msgM), cca.fadeIn(0.5)})})
		else
			pSpawn = cca.spawn({cca.moveBy(0.5, pSpawnWidge, msgM), cca.fadeIn(0.5)})
		end

		movingHint:runAction(cca.seq({cca.delay(delayTime), pSpawn}))
	end

	flyOutBottomAni = function(isRemoveAtOnce)
		table.remove(msgTable, 1)

		local tag = parent.movingHintTags[1]
		if not tag then return end

		local movingHint = parent:getChildByTag(tag)
		if movingHint then
			table.remove(parent.movingHintTags, 1)
			if param.richlabel then
				if param.parent.type and string.find(param.parent.type ,"center") then
					movingHint:runAction(cca.seq({cca.moveBy(0.8, parent.msgMargin*1.5,0),cca.removeSelf()}))
				-- elseif param.parent.type and param.parent.type == "进入" then
				-- 	movingHint:runAction(cca.seq({cca.moveBy(0.5, 0, parent.msgMargin),cca.removeSelf()}))
				else
					movingHint:runAction(cca.seq({cca.moveBy(0.5, 0, parent.msgMargin),cca.removeSelf()}))
				end
			elseif param.inmapInfo then
				movingHint:runAction(cca.seq({cca.moveBy(1,0,parent.msgMargin*(display.cy/display.cx/0.75)),cca.removeSelf()}))
			else	
				movingHint:runAction(cca.seq({cca.fadeOut(0.5), cca.removeSelf()}))
			end
		else
			table.remove(parent.movingHintTags, 1)
		end
	end

	updateMsgBottom = function (isWithOutTail)
		flyOutBottomAni()

		local length = #parent.movingHintTags
		if isWithOutTail then length = length - 1 end

		for i = 1, length do
			local movingHint = parent:getChildByTag(parent.movingHintTags[i])
			if movingHint then
				movingHint:runAction(cc.MoveBy:create(0.5,cc.p(0, parent.msgMargin)))
			end
		end
	end

	updateBottomList = function ()
		if msgTable[parent.msgMidMax + 1] ~= nil then
			flyIntoBottomAni(msgTable[parent.msgMidMax + 1])
			if #msgTable > parent.msgMidMax then
				updateMsgBottom(true)
			elseif #msgTable > 0 then
				if parent:getActionByTag(ACTION.RUN_BOTTOM_STACK) then
					parent:stopActionByTag(ACTION.RUN_BOTTOM_STACK)
				end

				if not parent:getActionByTag(ACTION.RUN_BOTTOM) then
					local actionRunBottom = cca.repeatForever(cca.seq({cca.delay(parent.disapperIntarval), cca.callFunc(function() timerAnimationBottom() end)}))
					actionRunBottom:setTag(ACTION.RUN_BOTTOM)
					parent:runAction(actionRunBottom)
				end
			end
		end

		if not parent:getActionByTag(ACTION.RUN_BOTTOM) and #msgTable <= parent.msgMidMax +1 then
			local actionRunBottom = cca.repeatForever(cca.seq({cca.delay(parent.disapperIntarval), cca.callFunc(function() timerAnimationBottom() end)}))
			actionRunBottom:setTag(ACTION.RUN_BOTTOM)
			parent:runAction(actionRunBottom)
		end
	end

	timerAnimationBottom = function ()
		if parent:getActionByTag(ACTION.RUN_BOTTOM) then
			parent:stopActionByTag(ACTION.RUN_BOTTOM)
		end
				
		if #msgTable > parent.msgMidMax then
			if not parent:getActionByTag(ACTION.RUN_BOTTOM_STACK) then
				local actionRunBottomStack = cca.repeatForever(cca.seq({cca.delay(0.5), cca.callFunc(function() updateBottomList() end)}))
				actionRunBottomStack:setTag(ACTION.RUN_BOTTOM_STACK)
				parent:runAction(actionRunBottomStack)
			end
		elseif #msgTable > 0 then
			if parent:getActionByTag(ACTION.RUN_BOTTOM_STACK) then
				parent:stopActionByTag(ACTION.RUN_BOTTOM_STACK)
			end
			for i = 1, #msgTable do
				flyOutBottomAni()
			end
		else
			if parent:getActionByTag(ACTION.RUN_BOTTOM) then
				parent:stopActionByTag(ACTION.RUN_BOTTOM)
			end
		end
	end

	if param and param.firstInQueue then
		for i = 1, #msgTable - 1 do--因为下一波的第一条已经在msgTable中，所以只需要移除前面的n-1条
			flyOutBottomAni()
		end
	end
	if parent:getActionByTag(ACTION.RUN_BOTTOM) then
		parent:stopActionByTag(ACTION.RUN_BOTTOM)
	end

	if #msgTable > parent.msgMidMax then
		timerAnimationBottom()
	else
		flyIntoBottomAni(msgTable[#msgTable])
	end

	if not parent:getActionByTag(ACTION.RUN_BOTTOM) then
		local actionRunBottom = cca.repeatForever( cca.seq( {cca.delay(parent.disapperIntarval) , cca.callFunc(function() timerAnimationBottom() end)}) )
		actionRunBottom:setTag(ACTION.RUN_BOTTOM)
		parent:runAction(actionRunBottom)
	end
end

return GUINumToast