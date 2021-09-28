local NetSimulation = class("NetSimulation", require("src/TabViewLayer"))
NetSimulation.OpenBtn = false
NetSimulation.isRecvMsg = false
NetSimulation.MaxNum = 50
local COMMONPATH = "res/common/"

function NetSimulation:ctor()
	G_MSGINFO = G_MSGINFO or {}
	--createReloadBtn("src/net/NetSimulation")
    require("src/tools")
    require "src/AudioPlay"
    require "src/config/Debug"
    require "src/config/FontColor"
    require "src/MultiHandler"
    require "src/CommonFunc"
    require "src/CommonDefine"

	self.showData = {}
	local bg = createSprite( self , "res/chat/bg2.png", cc.p(0, 0), cc.p(0,0))
	local bgSize = bg:getContentSize()
	local closeFunc = function()
		removeFromParent(self)
	end

	createTouchItem(bg, "res/component/button/x3.png", cc.p(bgSize.width-15, 625), closeFunc, nil)
	self.bg = bg
	self.bg:setOpacity(200)
	
	self:leftUI()
	self:rightUI()
    self:turnOnOffCutOut()
    --self:recvMsgInfo()
end

function NetSimulation:rightUI()
	--local bg = createSprite( self , "res/chat/bg2.png" , cc.p( 480 , 18 ), cc.p( 0, 0 ))
	self:createTableView(self.bg, cc.size(435, 520), cc.p(140, 103), true)

	local func = function ()
		if self.touchedFlg then
			removeFromParent(self.touchedFlg)
			self.touchedFlg = nil
		end
		self.showData = {}
		self.showData = copyTable(G_MSGINFO)
		self:getTableView():reloadData()
		if #self.showData*30 > 520 then
			--local offsetY = #G_MSGINFO*30 - 520
			self:getTableView():setContentOffset(cc.p(0, 0))
		end
	end

	func()
	startTimerAction(self, 5, true, func)
end

function NetSimulation:leftUI()
	local bg = self.bg
	local leftNode = cc.Node:create()
	self:addChild(leftNode)
	self.leftNode = leftNode

	local leftSetX,lieOffSetX = 25, 120
	local topSetY,lineOffSetY = 510 + 60, 50

	local id = (G_ROLE_MAIN and G_ROLE_MAIN.obj_id) and G_ROLE_MAIN.obj_id or 0
	--createLabel(leftNode, "发送协议", cc.p(240, topSetY + 35), cc.p(0.5, 0.5), 24, true)
	createLabel(leftNode, "角色动态id:\n" .. id , cc.p(leftSetX, topSetY), cc.p(0, 0.5), 20, true)
	
	topSetY = topSetY - 70
	local staticId = (userInfo and userInfo.currRoleStaticId) and userInfo.currRoleStaticId or 0
	createLabel(leftNode, "角色静态id:\n" .. staticId, cc.p(leftSetX, topSetY), cc.p(0, 0.5), 20, true)

	topSetY = topSetY - 402 - 24
	createLabel(leftNode, "协议ID:", cc.p(leftSetX, topSetY), cc.p(0, 0.5), 20, true)
	local editDeskBg = createSprite(bg, COMMONPATH.."bg/inputBg4.png",cc.p(leftSetX + lieOffSetX, topSetY), cc.p(0, 0.5))
    local editDesk = createEditBox(editDeskBg , nil, cc.p(5, 25), cc.size(234, 30), nil, 20)
    editDesk:setAnchorPoint(cc.p(0,0.5))
    editDesk:setPlaceHolder("输入协议ID")
    --editDesk:setText("32125")
    editDesk:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self.netIdEDT = editDesk

    topSetY = topSetY - lineOffSetY
	createLabel(leftNode, "消息内容:", cc.p(leftSetX, topSetY), cc.p(0, 0.5), 20, true)
	local editDeskBg = createSprite(bg, COMMONPATH.."bg/inputBg4.png",cc.p(leftSetX + lieOffSetX, topSetY), cc.p(0, 0.5))
    local editDesk = createEditBox(editDeskBg , nil, cc.p(5, 25), cc.size(234, 30), nil, 20)
    editDesk:setAnchorPoint(cc.p(0,0.5))
    editDesk:setPlaceHolder("输入协议内容")
    --editDesk:setText("ii:39850317&1")
    editDesk:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)	
    self.netIdcontent = editDesk

    topSetY = topSetY - lineOffSetY - 30
    local itemMenu = createMenuItem(bg, "res/component/button/50.png", cc.p(460, 50), function() self:analysisInput() end)
    createLabel(itemMenu, "模拟发送", getCenterPos(itemMenu), nil, 22, true)
end

function NetSimulation:analysisInput()
	local text = self.netIdcontent:getText()
	local id = self.netIdEDT:getText()
	print("analysisInput", tonumber(id) or "no id", text or "no content")
	if string.len(text) <= 0  then
		TIPS({str = "协议内容有误！"})
	elseif string.len(id) <= 0 or tonumber(id) <= 0 then
		TIPS({str = "协议ID有误！"})
	else
		local data = {}
		local strTab = stringsplit(text, ":")
		if #strTab ~= 2 then
			TIPS({str = "协议参数格式有误！{ii:1&1}  "})
			return
		end

		local strParameName = strTab[1]
		local strContent = strTab[2]
		local msgID = tonumber(id)

		g_msgHandlerInst:sendNetDataByTableExEx(msgID, strParameName, unserialize(strContent) )
		--print("NetSimulation sendmsg id=".. (tonumber(id) or "no id") ..",content="..text)
	end
end

function NetSimulation:recvBySelf()
	local text = self.recvNetsMsg:getText()
	if string.len(text) <= 0 then
		TIPS({str = "模拟接收参数为空！"})
	else
		local tabStr = stringsplit(text, ":")
		if #tabStr ~= 3 then
			TIPS({str = "模拟接收参数段不为3个！ msgID:iii:20&30&50"})
			return
		end
		local msgID = tabStr[1]
		local strType = tabStr[2]
		local strContent = tabStr[3]

		local buffer = LuaMsgBuffer:new()
		self:getLuaMsgBuff(buffer, msgID, strType, strContent)
		NetMsgDispacher(tonumber(msgID), buffer)
	end
end

function NetSimulation:getLuaMsgBuff(buffer, msgid, strType, strContent)
	local len = string.len(strType)
	local tabContent = stringsplit(strContent, "&")
	--print("analysisInput .. 2..",#tabContent, len)
	--dump(tabContent, "tabContent")
	if #tabContent ~= len then
		TIPS({str = "协议参数个数有误！"})
		return nil
	end

	--dump(strType)
	local tabType = self:strTypeToTable(strType)
	--dump(tabType)
	for i=1,len do
		local curType = tabType[i]
		if curType == "b" then
			buffer:pushBool( (tabContent[i] == "true") and true or false )
		elseif curType == "i" then
			buffer:pushInt(tonumber(tabContent[i]))
		elseif curType == "c" then
			buffer:pushChar(tonumber(tabContent[i]))
		elseif curType == "s" then
			buffer:pushShort(tonumber(tabContent[i]))
		elseif curType == "d" then
			buffer:pushDouble(tonumber(tabContent[i]))
		elseif curType == "S" then
			buffer:pushString(tabContent[i])
		else 
			TIPS({str = string.format("协议参数第%d个类型有误！%s", i, curType)})
			return nil
		end
	end
	return buffer
end

function NetSimulation:strTypeToTable(strType)
	local rec = {}
	if not strType then return end
	local len = string.len(strType)
	if len <= 0 then return end

	--dump(strType)
	local tempStrType = strType
	for i=1,len do
		local curPosType = string.sub(tempStrType, i, i)
		--dump(curPosType)
		rec[i] = curPosType
	end
	--dump(rec)
	return rec
end

function NetSimulation:turnOnOffCutOut()
	local switchFunc = function()
		NetSimulation.isRecvMsg = not NetSimulation.isRecvMsg
		self.flgTrue:setVisible(NetSimulation.isRecvMsg)
	end
	local item = createMenuItem(self.bg, "res/component/checkbox/1.png", cc.p(35, 120), switchFunc)
	createLabel(self.bg, "记录开关", cc.p(50, 120), cc.p(0, 0.5), 20, true)
	self.flgTrue = createSprite(item, "res/component/checkbox/1-1.png", getCenterPos(item))
	self.flgTrue:setVisible(NetSimulation.isRecvMsg)
end

function NetSimulation:tableCellTouched(table, cell)
	local idx = cell:getIdx() + 1
	local data = self.showData[idx]
	--dump(data,"data")
	if data then
		if data.type == 1 then
			self.netIdEDT:setText(data.msgID or "")
			self.netIdcontent:setText(data.content)
		elseif data.type == 0 then
			-- local str = "" .. data.msgID or ""
			-- str = str .. ":"
			-- str = str .. self:AniContent(data.content)
			-- self.recvNetsMsg:setText(str)
		end
	end

	if not self.touchedFlg then
		self.touchedFlg = createSprite(self:getTableView(), "res/component/checkbox/2-1.png", cc.p( 17, 18))
	end
	self.touchedFlg:setPosition(cc.p(17, 20 + cell:getPositionY()))
end

function NetSimulation:AniContent(content)
	if not content then return "" end
	local tabContent = stringsplit(content, "$")

	local strType = ""
	local tabParam = {}
	for i=1,#tabContent do
		local tabOneParam = stringsplit(tabContent[i],":")
		local oneType = tabOneParam[1] or "E"
		local value = tabOneParam[2] or ""
		if oneType ~= "" then
			local k = #tabParam + 1
			strType = strType .. oneType

			if oneType == "b" then
				tabParam[k] = (value == 1 and "true" or "false")
			elseif oneType == "c" then
				tabParam[k] = tonumber(value)
			elseif oneType == "s" then
				tabParam[k] = tonumber(value)
			elseif oneType == "i" then
				tabParam[k] = tonumber(value)
			elseif oneType == "d" then
				tabParam[k] = tonumber(value)
			elseif oneType == "S" then
				tabParam[k] = value
			end
		end
	end
	local ret = strType .. ":"
	for i=1,#tabParam do
		if i == 1 then
			ret = ret .. "" .. tabParam[i]
		else
			ret = ret .. "&" .. tabParam[i]
		end
	end
	return ret
end

function NetSimulation:cellSizeForTable(table, idx) 
    return 36, 520
end

function NetSimulation:tableCellAtIndex(table, idx)
	local cell = table:dequeueCell()
	if nil == cell then
		cell = cc.TableViewCell:new() 
	else
    	cell:removeAllChildren()
    end

	createLabel(cell, self:getMsgStrByIndex(idx + 1), cc.p(35, 18), cc.p(0, 0.5), 18, true)
	
    return cell
end

function NetSimulation:numberOfCellsInTableView(table)
   	return #self.showData
end

function NetSimulation:getMsgStrByIndex(index)
	if self.showData then
		local data = self.showData[index]
		if data then
			--dump(data)
			local str = os.date("%H:%M:%S ",data.Time)
			str = str .. ((data.type == 1) and "Send" or "Recv")
		    str = str .. ": msgID = " .. data.msgID .. " "
		    if data.content then
		    	str = str .. ",content"-- .. data.content
		    end
		    return str
		end
	end
	return ""
end

function NetSimulation:logSendMsgInfo(msgID, type, protoMsgName, tabValue)
	G_MSGINFO = G_MSGINFO or {}
	if not msgID or msgID == 0 
		or FRAME_CG_HEART_BEAT == msgID
		or FRAME_GW_HEART_BEAT == msgID
		or TARGETREWARD_SC_CHECK_RET ==  msgID
		or not G_MSGINFO then 
		return 
	end

	if tablenums(G_MSGINFO) >= NetSimulation.MaxNum then
		table.remove(G_MSGINFO, 1)
	end
	G_MSGINFO[#G_MSGINFO + 1] = {}
	G_MSGINFO[#G_MSGINFO].msgID = msgID
	G_MSGINFO[#G_MSGINFO].Time = os.time()
	G_MSGINFO[#G_MSGINFO].type = (not type or type == 1) and 1 or 0

	if protoMsgName and tabValue then
		G_MSGINFO[#G_MSGINFO].content = "" .. protoMsgName ..":".. serialize(tabValue)
	end

	return #G_MSGINFO
end

return NetSimulation