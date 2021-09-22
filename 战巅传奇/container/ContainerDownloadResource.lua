--部分资源下载界面， 下载完成获取奖励， 现在不需要了， 

local ContainerDownloadResource = {}
local var ={}

function ContainerDownloadResource.initView(extend)
	var = {
		xmlPanel,
	}
	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerDownloadResource.uif")

	if var.xmlPanel then
		local btnget = var.xmlPanel:getWidgetByName("btnget")

		local function stopDownload()
			cc.DownManager:getInstance():clearDown()
			GameBaseLogic.isDownloadAllState = false
			btnget:setTitleText("开始下载")
		end
		local function startLoadAllRes()

			cc.DownManager:getInstance():clearDown()
			for i,v in ipairs(GameBaseLogic.needLoadRes) do
				cc.DownManager:getInstance():requestAdd(v)
			end
			GameBaseLogic.isDownloadAllState=true
			btnget:setTitleText("暂停下载")
		end		
		local function pushbtns( sender )
			local text = sender:getTitleText()
			if text =="领取奖励" then
				if GameBaseLogic.downloadAll or GameBaseLogic.isGetLoadAwarded == 1 then
					GameSocket:PushLuaTable("gui.ContainerDownloadResource.handlePanelData","get")
				else
					GameSocket:alertLocalMsg("下载未完成，无法领取奖励！", "alert")
				end
			elseif text =="暂停下载" then
				stopDownload()
			elseif text =="立即下载" or text =="开始下载" then
				startLoadAllRes()
			end
		end

		if GameBaseLogic.totalLoadNum <=0 and not GameBaseLogic.downloadAll and GameBaseLogic.isGetLoadAwarded <=0 then
			GameBaseLogic.needLoadRes,GameBaseLogic.totalLoadNum = FileList.getList()
			GameBaseLogic.needLoadNum = #GameBaseLogic.needLoadRes
		end

		if GameBaseLogic.needLoadNum<=0 then
			GameBaseLogic.downloadAll=true
		end

		if GameBaseLogic.isGetLoadAwarded >1 then
			btnget:setEnabled(false)
			ContainerDownloadResource.setProgressBar(100,100)
		elseif GameBaseLogic.downloadAll or GameBaseLogic.isGetLoadAwarded >0 then
			ContainerDownloadResource.setProgressBar(100,100)
		elseif GameBaseLogic.totalLoadNum >0 then
			local hasDownNum = GameBaseLogic.totalLoadNum - GameBaseLogic.needLoadNum
			ContainerDownloadResource.setProgressBar(hasDownNum,GameBaseLogic.totalLoadNum)
		end
		if GameBaseLogic.downloadAll or GameBaseLogic.isGetLoadAwarded == 1 then
			btnget:setTitleText("领取奖励")
			GameUtilSenior.addHaloToButton(btnget, "btn_normal_light3")
		else
			if GameBaseLogic.totalLoadNum >0 and not GameBaseLogic.isDownloadAllState then
				btnget:setTitleText(GameBaseLogic.totalLoadNum == GameBaseLogic.needLoadNum and "立即下载" or "开始下载")
			else
				btnget:setTitleText("暂停下载")
			end
			if btnget:getChildByName("img_bln") then
				btnget:removeChildByName("img_bln")
			end
		end
		btnget:addClickEventListener(pushbtns)

		var.xmlPanel:getWidgetByName("loadingbar"):setFormatString(""):setFormat2String("%.02f%%"):setFontSize(16):enableOutline(GameBaseLogic.getColor4(0x000000), 1)
		GameUtilSenior.asyncload(var.xmlPanel, "imgBg", "ui/image/download_bg.jpg")

		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, ContainerDownloadResource.handlePanelData)
			:addEventListener(GameMessageCode.EVENT_DOWNLOAD_SUCCESS, ContainerDownloadResource.downFileSuccess)
		return var.xmlPanel
	end
end

function ContainerDownloadResource.handlePanelData( event )
	if event and event.type =="ContainerDownloadResource" then
		local data = GameUtilSenior.decode(event.data)
		if data then
			if data.cmd =="close" then
				GameSocket:dispatchEvent({name=GameMessageCode.EVENT_CLOSE_PANEL ,str="extend_download"})
			else
				GameBaseLogic.isGetLoadAwarded = tonumber(data.con)
				local award = data.award
				local function updateAward(subItem)
					local index = subItem.tag
					if award[index] then
						GUIItem.getItem({
							parent = subItem:getWidgetByName("icon"),
							typeId = award[index].id,
							num = award[index].num,
						});
					end
				end
				local awardlist = var.xmlPanel:getWidgetByName("awardList")
				awardlist:reloadData(#award,updateAward,0,false)
				awardlist.tableview:setTouchEnabled(false)

				if GameBaseLogic.isGetLoadAwarded > 0 then
					ContainerDownloadResource.setProgressBar(100,100)
				end
				local btnget = var.xmlPanel:getWidgetByName("btnget")
				if GameBaseLogic.downloadAll or GameBaseLogic.isGetLoadAwarded == 1 then
					btnget:setTitleText("领取奖励")
					GameUtilSenior.addHaloToButton(btnget, "btn_normal_light3")
				end
			end
		end
	end
end

function ContainerDownloadResource.onPanelOpen(extend)

	-- 变量为1表示服务器已知
	if GameBaseLogic.downloadAll and GameBaseLogic.isGetLoadAwarded <=0 then
		GameSocket:PushLuaTable("gui.ContainerDownloadResource.handlePanelData","downall")
	end

	GameSocket:PushLuaTable("gui.ContainerDownloadResource.handlePanelData","fresh")

end

function ContainerDownloadResource.downFileSuccess(event)
	if event then
		if GameBaseLogic.needLoadNum>0 and GameBaseLogic.isDownloadAllState then
			local hasDownNum = GameBaseLogic.totalLoadNum - GameBaseLogic.needLoadNum
			ContainerDownloadResource.setProgressBar(hasDownNum,GameBaseLogic.totalLoadNum)

		elseif GameBaseLogic.isGetLoadAwarded <= 0 then

			ContainerDownloadResource.setProgressBar(100,100)
			GameBaseLogic.downloadAll=true
			local btnget = var.xmlPanel:getWidgetByName("btnget"):setTitleText("领取奖励")
			GameUtilSenior.addHaloToButton(btnget, "btn_normal_light3")

			GameSocket:alertLocalMsg("资源包下载完成!", "alert")
		end
	end
end

function ContainerDownloadResource.setProgressBar(factor,total)
	var.xmlPanel:getWidgetByName("loadingbar"):setPercent(factor,total)
end

function ContainerDownloadResource.onPanelClose()
end

return ContainerDownloadResource