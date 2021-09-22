--[[
--世界活动功能
--]]

local ContainerActivityList = {}
local var = {}
local stateTable = {"state_wks.png","state_jxz.png","state_djbz.png","state_jjks.png","state_yjs.png"}

function ContainerActivityList.initView()
	var = {
		xmlPanel,
		curSelectedId=nil,--当前选中的条目id
		curItem=nil,
		allInfo=nil,
		actDesp=nil,
		selectName="",
	}
	local function prsBtnItem(sender)
		GameSocket:PushLuaTable("gui.ContainerActivityList.onPanelData",GameUtilSenior.encode({actionid = "btnGo",nameIndex=var.selectName}))
	end
	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerActivityList.uif")
	if var.xmlPanel then
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, ContainerActivityList.handlePanelData)
			-- ContainerActivityList.initActsList(nil)
			GameSocket:PushLuaTable("gui.ContainerActivityList.onPanelData",GameUtilSenior.encode({actionid = "reqActsAllInfo",params = {}}))

		GUIFocusPoint.addUIPoint(var.xmlPanel:getWidgetByName("btnGoSingle"), prsBtnItem)
		
		return var.xmlPanel
	end
end

function ContainerActivityList.onPanelOpen()
	GameSocket:PushLuaTable("gui.ContainerActivityList.onPanelData",GameUtilSenior.encode({actionid = "reqActsData",params = {}}))
end


function ContainerActivityList.handlePanelData(event)
	if event.type ~= "ContainerActivityList" then return end
	local data = GameUtilSenior.decode(event.data)
	-- print(event.data)
	if data.cmd =="updateClientShow" then
		ContainerActivityList.initActsList(data.actsTable)
	elseif data.cmd=="senderActsInfo" then
		var.allInfo=data.actsInfo
	end

end

--初始化活动列表
function ContainerActivityList.initActsList(data)
	local function updateList(item)
		local function prsBtnItem(sender)
			--if sender.name then
			--	-- print(sender.name)
			--	GameSocket:PushLuaTable("gui.ContainerActivityList.onPanelData",GameUtilSenior.encode({actionid = "btnGo",nameIndex=sender.name}))
			--else
				if var.curItem then
					var.curItem:getWidgetByName("imgSelected"):setVisible(false)
				end
				var.selectName = sender.name
				sender:getWidgetByName("imgSelected"):setVisible(true)
				var.curItem = sender
				var.curSelectedId=sender.tag
				ContainerActivityList.updateSelectedInfo(data[item.tag])
			--end
		end 
		if var.curSelectedId==item.tag then
			item:getWidgetByName("imgSelected"):setVisible(true)
			var.curItem = item
		else
			item:getWidgetByName("imgSelected"):setVisible(false)
		end
		item:setTouchEnabled(true)
		GUIFocusPoint.addUIPoint(item, prsBtnItem)

		if not var.curItem and item.tag==1 then prsBtnItem(item) end

		local itemData = data[item.tag]
		item.name=itemData.name
		local time = string.format("%s-%s", ContainerActivityList.formatTime(itemData.startTime), ContainerActivityList.formatTime(itemData.endTime))
		local btnGo = item:getWidgetByName("btnGo"):setVisible(false)
		--local stateBox = item:getWidgetByName("stateBox"):setVisible(true)
		item:getWidgetByName("renderBg"):loadTexture("act_"..itemData.listbg..".png",ccui.TextureResType.plistType)
		item:getWidgetByName("imgState"):setRotation(50)
		if itemData.openState==2 then--进行中
			btnGo.name=itemData.name
			GUIFocusPoint.addUIPoint(btnGo, prsBtnItem)
			btnGo:setVisible(false)
			item:getWidgetByName("imgState"):setVisible(true)
			item:getWidgetByName("imgState"):setVisible(true):loadTexture("state_jxz.png", ccui.TextureResType.plistType)
			item:getWidgetByName("lanTime"):setString(time):setColor(GameBaseLogic.getColor(0xff7800)):enableOutline(GameBaseLogic.getColor(0x0000000),1)
			item:getWidgetByName("labName"):setString(itemData.name):setColor(GameBaseLogic.getColor(0xff7800)):enableOutline(GameBaseLogic.getColor(0x0000000),1)
			item:getWidgetByName("labLimit"):setString(itemData.levelLimit.."级"):setColor(GameBaseLogic.getColor(0xff7800)):enableOutline(GameBaseLogic.getColor(0x0000000),1)
			if itemData.name=="双倍经验" then
				btnGo:setVisible(false)
				item:getWidgetByName("imgState"):setVisible(true)
				item:getWidgetByName("imgState"):setVisible(true):loadTexture("state_jxz.png", ccui.TextureResType.plistType)
			end
		else
			btnGo:setVisible(false)
			item:getWidgetByName("imgState"):setVisible(true)
			item:getWidgetByName("imgState"):loadTexture(stateTable[itemData.openState], ccui.TextureResType.plistType)
			item:getWidgetByName("lanTime"):setString(time):setColor(GameBaseLogic.getColor(0xfddfae)):enableOutline(GameBaseLogic.getColor(0x0000000),1)
			item:getWidgetByName("labName"):setString(itemData.name):setColor(GameBaseLogic.getColor(0xfddfae)):enableOutline(GameBaseLogic.getColor(0x0000000),1)
			item:getWidgetByName("labLimit"):setString(itemData.levelLimit.."级"):setColor(GameBaseLogic.getColor(0xfddfae)):enableOutline(GameBaseLogic.getColor(0x0000000),1)
		end
	end

	local actsList = var.xmlPanel:getWidgetByName("actsList")
	actsList:reloadData(#data,updateList)
end

function ContainerActivityList.formatTime(time)
	local hour = math.floor(time/100)
	local min = time%100
	return string.format("%02d:%02d", hour, min) 
end

--刷新当前选中的活动信息
function ContainerActivityList.updateSelectedInfo(itemData)
	if not itemData or not var.allInfo then return end
	local curData = var.allInfo[itemData.name]
	if not curData then return end
	print("z")
	-- print(GameUtilSenior.encode(var.allInfo))
	local time = string.format("%s-%s", ContainerActivityList.formatTime(itemData.startTime), ContainerActivityList.formatTime(itemData.endTime))
	var.xmlPanel:getWidgetByName("labTime"):setString(time)
	var.xmlPanel:getWidgetByName("labLimit"):setString(itemData.levelLimit.."级")

	var.xmlPanel:getWidgetByName("labDesp"):setRichLabel("<font color=#FDDFAE>"..curData.explain.."</font>","ContainerActivityList",18)

	var.xmlPanel:getWidgetByName("list_base_attr"):requestDoLayout()

	--var.xmlPanel:getWidgetByName("activity_name"):setString(itemData.name)
	for i=1,6 do
		local x = 1
		local awardItem = var.xmlPanel:getWidgetByName("icon"..i)
		local param={parent=awardItem,typeId=nil}
		awardItem:setVisible(false)
		if curData.awards and curData.awards[i] then
			param={parent=awardItem,typeId=curData.awards[i].id,num=curData.awards[i].num}
			awardItem:setVisible(true)
		end
		GUIItem.getItem(param)
	end
end






return ContainerActivityList