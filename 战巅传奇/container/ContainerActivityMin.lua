local ContainerActivityMin = {}
local var = {}

function ContainerActivityMin.initView()
	var = {
		xmlPanel,
		curData=nil,
	}
	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerActivityMin.uif")
	if var.xmlPanel then
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, ContainerActivityMin.handlePanelData)
		GameUtilSenior.asyncload(var.xmlPanel, "imgBg", "ui/image/activity_bg.jpg")
		ContainerActivityMin.initBtns()
		return var.xmlPanel
	end
end

function ContainerActivityMin.onPanelOpen()
	if GameSocket.tipsMsg["tip_activity"] then 
		local data=GameSocket.tipsMsg["tip_activity"]
		if GameSocket.tipsMsg["tip_activity"] and #GameSocket.tipsMsg["tip_activity"]>0 then
			var.curData=GameSocket.tipsMsg["tip_activity"][1]
			ContainerActivityMin.updatePanel(var.curData)
		end
	end
end

function ContainerActivityMin.onPanelClose()
	if var.curData and GameSocket.tipsMsg["tip_activity"] then
		for i=1,#GameSocket.tipsMsg["tip_activity"] do
			local itemData = GameSocket.tipsMsg["tip_activity"][i]
			if itemData and itemData.name==var.curData.name then
				table.remove(GameSocket.tipsMsg["tip_activity"],i)
				var.curData=nil
				break
			end
		end
	end
end


function ContainerActivityMin.handlePanelData(event)
	if event.type ~= "ContainerActivityMin" then return end
	local data = GameUtilSenior.decode(event.data)
	-- print(event.data)
	if data.cmd =="" then

	elseif data.cmd=="" then

	end

end

--刷新当前选中的活动信息
function ContainerActivityMin.updatePanel(itemData)
	-- var.xmlPanel:getWidgetByName("labDesp"):setString(itemData.explain) 
	var.xmlPanel:getWidgetByName("labDesp"):setRichLabel("<font color=#fddfae>"..itemData.explain.."</font>","ContainerActivityList",20)
	var.xmlPanel:getWidgetByName("labName"):setString(itemData.name)
	for i=1,6 do
		local x = 1
		local awardItem = var.xmlPanel:getWidgetByName("icon"..i)
		local param={parent=awardItem,typeId=nil}
		if itemData.awards and itemData.awards[i] then
			param={parent=awardItem,typeId=itemData.awards[i].id,num=itemData.awards[i].num}
		end
		GUIItem.getItem(param)
	end
end

-----------------------------------------按钮操作-----------------------------------------------
local btnArrs = {"btnGo"}
function ContainerActivityMin.initBtns()
	local function prsBtnClick(sender)
		local senderName = sender:getName()
		if senderName=="btnGo" then
			if var.curData then
				GameSocket:PushLuaTable("gui.ContainerActivityList.onPanelData",GameUtilSenior.encode({actionid = "btnGo",nameIndex=var.curData.name}))
			end
		elseif senderName=="btnGet" then

		end
	end
	for i=1,#btnArrs do
		local btn = var.xmlPanel:getWidgetByName(btnArrs[i])
		GUIFocusPoint.addUIPoint(btn,prsBtnClick)
	end
end




return ContainerActivityMin