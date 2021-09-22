local ContainerTableYX = {}
local var = {}

function ContainerTableYX.initView(extend)	
	var = {
		xmlPanel,
		list_chart,
	}
	local data= extend.mParam
	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerTableYX.uif")
	if var.xmlPanel then
		--GameUtilSenior.asyncload(var.xmlPanel, "inner_bg", "")
		
		var.list_chart = var.xmlPanel:getWidgetByName("list_chart")
		local btn_back = var.xmlPanel:getWidgetByName("btn_back")
		btn_back:setTouchEnabled(true)
		btn_back:addClickEventListener(function (pSender, touchType)
   			GameSocket:PushLuaTable(data.callFunc, GameUtilSenior.encode(data.book))
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_CLOSE_PANEL,str="panel_chart_yx"})
		end)
		local chartColor = {0xffd800,0xfddfae}
		var.list_chart:reloadData(#data.scoreChart, function(subItem)
			local d = data.scoreChart[subItem.tag]
			local color = chartColor[subItem.tag] or chartColor[2]
			local lbl_listItem1 = subItem:getWidgetByName("Text_list1")
			lbl_listItem1:setString(subItem.tag):setVisible(subItem.tag>3):setColor(GameBaseLogic.getColor(color))
			local lbl_listItem2 = subItem:getWidgetByName("Text_list2")
			lbl_listItem2:setString(d.name):setColor(GameBaseLogic.getColor(color))
			local lbl_listItem3 = subItem:getWidgetByName("Text_list3")
			lbl_listItem3:setString(d.level):setColor(GameBaseLogic.getColor(color))
			local lbl_listItem4 = subItem:getWidgetByName("Text_list4")
			lbl_listItem4:setString(GameUtilSenior.getJobName(d.job)):setColor(GameBaseLogic.getColor(color))
			local lbl_listItem5 = subItem:getWidgetByName("Text_list5")
			lbl_listItem5:setString(d.score):setColor(GameBaseLogic.getColor(color))
			local img_rank = subItem:getWidgetByName("img_rank")
			if subItem.tag<=3 then
				img_rank:show():loadTexture("chart_"..subItem.tag,ccui.TextureResType.plistType)
			else
				img_rank:hide()
			end
		end, 0, false)
		
		var.xmlPanel:getWidgetByName("lbl_selfRank"):setString(data.mychart>0 and data.mychart or "未入榜")
		var.xmlPanel:getWidgetByName("Text_worldLv"):setString(data.score)
		local time = data.time or 60
		var.xmlPanel:getWidgetByName("Text_time"):runAction(cca.rep(cca.seq({cca.cb(function(target)
			time = time -1
			target:setString(string.format("00:%02d",time))
			if time<=0 then
   				GameSocket:PushLuaTable(data.callFunc, GameUtilSenior.encode(data.book))
				GameSocket:dispatchEvent({name = GameMessageCode.EVENT_CLOSE_PANEL,str="panel_chart_yx"})
			end
		end),cca.delay(1)}),60))		
		GUIMain["m_lcPartUI"]:getWidgetByName("yxbiqiLayer"):getWidgetByName("lbllefttime"):stopAllActions():setString("")		
		return var.xmlPanel
	end	
end

function ContainerTableYX.onPanelClose(extend)

end

return ContainerTableYX
