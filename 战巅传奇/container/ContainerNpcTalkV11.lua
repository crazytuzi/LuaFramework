local ContainerNpcTalkV11 = {}
local var = {}


local currentDaLuInfoIndex = 0
local currentDaLuInfo = {}

function ContainerNpcTalkV11.onPanelOpen(event)

end

function ContainerNpcTalkV11.initView(extend)
	var = {
		items={},
		xmlPanel,
		talkInfo,
	}
	var.talkInfo = extend.result.talkInfo
	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerNpcTalkV11.uif")
	if var.xmlPanel then

		ContainerNpcTalkV11.showTitleAnimation()
		
		ContainerNpcTalkV11.showList()
					
		return var.xmlPanel
	end
end

function ContainerNpcTalkV11.showTitleAnimation()
		
	local title_animal = var.xmlPanel:getWidgetByName("title_animal")
	GameUtilSenior.showTitleAnimals(title_animal)
		
end



function ContainerNpcTalkV11.showList()
	ContainerNpcTalkV11.showMapInfo()
end

function ContainerNpcTalkV11.showMapInfo()
	var.xmlPanel:getWidgetByName("descList"):setLocalZOrder(1)
	ContainerNpcTalkV11.updateList( var.xmlPanel:getWidgetByName("descList"),var.talkInfo.str )
end

function ContainerNpcTalkV11.updateList( list,strs )
	local t = {}
	if GameUtilSenior.isString(strs) then
		table.insert(t,strs)
	elseif GameUtilSenior.isTable(strs) then
		t = strs
	end
	list:removeAllItems()
	for i,v in ipairs(t) do
		local richLabel = GUIRichLabel.new({size = cc.size(list:getContentSize().width, 40), space=10,name = "hintMsg"..i})
		richLabel:setRichLabel(v,"panel_npctalk")
		list:pushBackCustomItem(richLabel)
	end
end



function ContainerNpcTalkV11.onPanelOpen(extend)
end

function ContainerNpcTalkV11.onPanelClose()

end

return ContainerNpcTalkV11