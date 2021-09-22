local ContainerBossMonster={}
local var = {}

function ContainerBossMonster.initView(extend)
	var = {
		xmlPanel,
		tabData={},
		preButton,
		tabIndex=nil,
		curTypeSelected=nil,
		fireworks=nil,
		page_tab,
		pageIndex,
		bossName={},
		txtLev=nil,
		txtMate=nil,
		selectTab =1,
		needIndex = nil,
		tabName = {
			"tab_1","tab_2","btn_personal_boss"
		},
	}
	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerBossMonster.uif");
	if var.xmlPanel then
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, ContainerBossMonster.handlePanelData)
		ContainerBossMonster.initBtns()
		-- var.page_tab = var.xmlPanel:getWidgetByName("page_tab")
		-- var.page_tab:addTabEventListener(ContainerBossMonster.pushTab)
		-- var.page_tab:setTabRes("tab_v4","tab_v4_sel", ccui.TextureResType.plistType)
		-- ContainerBossMonster.initTabList()
		-- GameUtilSenior.asyncload(var.xmlPanel, "panelinnerBg", "ui/image/img_boss_bg.jpg")

		-- -- local btnPersonalBoss = var.page_tab:getItemByIndex(3)
		-- if btnPersonalBoss then
		-- 	btnPersonalBoss:setName("btn_personal_boss")
		-- end

		for i,v in ipairs(var.tabName) do
			var.xmlPanel:getWidgetByName(var.tabName[i]):setTag(i)
			GUIFocusPoint.addUIPoint(var.xmlPanel:getWidgetByName(var.tabName[i]),ContainerBossMonster.pushTab)
		end
		var.xmlPanel:getWidgetByName("Text_5"):setRotation(90)
		var.xmlPanel:getWidgetByName("Text_3"):setRotation(90)
	end
	return var.xmlPanel
end

function ContainerBossMonster.onPanelOpen(event)
	if event.mParam and tonumber(event.mParam.tab) then
		var.selectTab = event.mParam.tab
	end
	if event.mParam and tonumber(event.mParam.needIndex) then
		var.needIndex = event.mParam.needIndex
	end
	ContainerBossMonster.pushTab(var.xmlPanel:getWidgetByName(var.tabName[var.selectTab]))
end

function ContainerBossMonster.onPanelClose()
	var.selectTab = 1
	-- var.page_tab:setSelectedTab(1)
	ContainerBossMonster.pushTab(var.xmlPanel:getWidgetByName(var.tabName[1]))
end

function ContainerBossMonster.pushTab(sender)
	var.tabIndex=nil
	sender:setTouchEnabled(true)
	var.pageIndex = sender:getTag();
	var.xmlPanel:getWidgetByName("labTime"):setVisible(var.pageIndex<3)
	-- var.tabName
	for i,v in ipairs(var.tabName) do
		if i == var.pageIndex then
			var.xmlPanel:getWidgetByName(var.tabName[i]):setBrightStyle(1)
		else
			var.xmlPanel:getWidgetByName(var.tabName[i]):setBrightStyle(0)
		end
	end
	if var.pageIndex ~= 3 then
		ContainerBossMonster.setEnterCondition(nil)
	end
	--暂时只显示野外
	var.pageIndex=2
	if var.pageIndex == 1 then
		var.xmlPanel:getWidgetByName("btnlayer"):show()
		var.xmlPanel:getWidgetByName("btnFuBen"):hide()
		GameSocket:PushLuaTable("gui.ContainerBossMonster.onPanelData",GameUtilSenior.encode({actionid = "btnKill",params = {1}}))
	elseif var.pageIndex == 2 then
		var.xmlPanel:getWidgetByName("btnlayer"):show()
		var.xmlPanel:getWidgetByName("btnFuBen"):hide()
		GameSocket:PushLuaTable("gui.ContainerBossMonster.onPanelData",GameUtilSenior.encode({actionid = "btnYeWai",params = {1}}))
	elseif var.pageIndex == 3 then
		var.xmlPanel:getWidgetByName("btnlayer"):hide()
		var.xmlPanel:getWidgetByName("btnFuBen"):show()
		GameSocket:PushLuaTable("gui.ContainerBossMonster.onPanelData",GameUtilSenior.encode({actionid = "btnGeRen",params = {1}}))
	end
end

function ContainerBossMonster.handlePanelData(event)
	if event.type ~= "ContainerBossMonster" then return end
	local data = GameUtilSenior.decode(event.data)
	-- print(event.data)
	if data.cmd =="updateKeKill" then
		ContainerBossMonster.initBossNameList(data.monTable)
	elseif data.cmd=="updateWorldBoss" then
		ContainerBossMonster.initBossNameList(data.monTable)
	elseif data.cmd=="senderWorldBossDesp" then
		ContainerBossMonster.updateBossDesp(data.monTable)
		ContainerBossMonster.updateBtnShow(data.monTable)
		
	elseif data.cmd=="updatePersonalBossName" then
		-- ContainerBossMonster.initTabList(data.monTable)
		ContainerBossMonster.initBossNameList(data.monTable,"Personal")
	elseif data.cmd=="senderPersonalBossDesp" then
		ContainerBossMonster.updateBossDesp(data.monTable)
		ContainerBossMonster.setEnterCondition(data.needDesp)
	end
end

--个人BOSS副本寻找默认显示页签
function ContainerBossMonster.getSelectTab(data)
	if data then
		for i=1,#data do
			local itemData = data[i]
			if itemData and itemData.useTimes and itemData.allTimes and itemData.useTimes<itemData.allTimes then
				return i
			end
		end
	end
	return 1
end

--初始化BOSS名字列表
function ContainerBossMonster.initBossNameList(data,tabType)
	var.bossName=data
	if var.needIndex then
		var.tabIndex = var.needIndex
		var.needIndex = nil
	end
	local function prsBtnClick(sender,touchType)
	-- print(var.pageIndex,"=============")
		if var.pageIndex==3 then
			GameSocket:PushLuaTable("gui.ContainerBossMonster.onPanelData",GameUtilSenior.encode({actionid = "reqGeRenBossOne",params = {index=sender.tag}}))--请求个人BOSS当前选中数据
		elseif var.pageIndex==2 or var.pageIndex==1 then
			GameSocket:PushLuaTable("gui.ContainerBossMonster.onPanelData",GameUtilSenior.encode({actionid = "reqYeWaiBossOne",params = {index=sender.tag}}))--请求个人BOSS当前选中数据
		end
		var.tabIndex=sender.tag
		if var.preButton then
			var.preButton:setBrightStyle(0)
		end
		sender:setBrightStyle(1)
		var.preButton=sender
	end
	local function updateBossName(item)
		local btnBoss = item:getWidgetByName("btnBoss"):setTouchSwallowEnabled(false):setTouchEnabled(true)
		local itemData = var.bossName[item.tag]
		--btnBoss:setTitleText(itemData.monName)
		btnBoss.tag=itemData.index
		if var.tabIndex and var.tabIndex==item.tag then
			btnBoss:setBrightStyle(1)
			btnBoss:loadTextureNormal("mon_list_btn_"..itemData.monImg..".png",ccui.TextureResType.plistType)
			btnBoss:loadTexturePressed("mon_list_btn_sel_"..itemData.monImg..".png",ccui.TextureResType.plistType)
			prsBtnClick(btnBoss)
		else
			btnBoss:setBrightStyle(0)			
			btnBoss:loadTextureNormal("mon_list_btn_"..itemData.monImg..".png",ccui.TextureResType.plistType)
			btnBoss:loadTexturePressed("mon_list_btn_sel_"..itemData.monImg..".png",ccui.TextureResType.plistType)
		end
		GUIAnalysis.attachEffect(btnBoss,"outline(0e0600,1)")
		GUIFocusPoint.addUIPoint(btnBoss,prsBtnClick)
		if tabType then
			if not var.tabIndex and item.tag==ContainerBossMonster.getSelectTab(data) then
				prsBtnClick(btnBoss)
			end
		else
			if not var.tabIndex and item.tag==1 then
				prsBtnClick(btnBoss)
			end
		end
		item:setName("item_boss"..item.tag)
		btnBoss:setSwallowTouches(false)
	end
	local listBoss = var.xmlPanel:getWidgetByName("listBoss")
	listBoss:reloadData(#var.bossName,updateBossName)
	if var.tabIndex then
		listBoss:autoMoveToIndex(var.tabIndex)
	end
end

--刷新右侧boss详细信息
function ContainerBossMonster.updateBossDesp(data)
	ContainerBossMonster.showMonInfo(data)
end

--野外的化刷新3个按钮信息
function ContainerBossMonster.updateBtnShow(data)
	if data then
		local btnYeWai = var.xmlPanel:getWidgetByName("btnYeWai")
		if (data.map1 and data.map1[2]==1) or (data.map2 and data.map2[2]==1) or (data.map3 and data.map3[2]==1) then
			btnYeWai.index=data.index
			if var.pageIndex==1 and data.map1[2]==0 then
				btnYeWai:setVisible(false)
			else
				btnYeWai:setVisible(true)
			end
			if data.map1[3] then
				--btnYeWai:setTitleText(data.map1[3]..3)
			end
			var.xmlPanel:getWidgetByName("monsterStat"):loadTexture("refresh.png",ccui.TextureResType.plistType)
		else
			btnYeWai:setVisible(false)
			var.xmlPanel:getWidgetByName("monsterStat"):loadTexture("kill.png",ccui.TextureResType.plistType)
		end
		--[[
		local btnZhiJia = var.xmlPanel:getWidgetByName("btnZhiJia")
		if data.map2 and data.map2[1] then
			btnZhiJia.index=data.index
			if var.pageIndex==1 and data.map2[2]==0 then
				btnZhiJia:setVisible(false)
			else
				btnZhiJia:setVisible(true)
			end
		else
			btnZhiJia:setVisible(false)
		end
		local btnMaYa = var.xmlPanel:getWidgetByName("btnMaYa")
		if data.map3 and data.map3[1] then
			btnMaYa.index=data.index
			if var.pageIndex==1 and data.map3[2]==0 then
				btnMaYa:setVisible(false)
			else
				btnMaYa:setVisible(true)
			end
		else
			btnMaYa:setVisible(false)
		end
		-- if var.pageIndex==2 then
		-- 	btnYeWai:setVisible(true)
		-- 	btnZhiJia:setVisible(true)
		-- 	btnMaYa:setVisible(true)
		-- end
		]]--
	end
end

--个人副本进入条件
function ContainerBossMonster.setEnterCondition(data)
	if not var.txtLev or not var.txtMate then
		var.txtLev = GUIRichLabel.new({size=cc.size(300,25),space=2})
		var.txtLev:addTo(var.xmlPanel):align(display.LEFT_CENTER,353,58)		
		var.txtMate = GUIRichLabel.new({size=cc.size(300,25),space=2})
		var.txtMate:addTo(var.xmlPanel):align(display.LEFT_CENTER,353,30)
	end
	if not data then
		var.txtLev:setRichLabel("",20,19)
		var.txtMate:setRichLabel("",20,19)
		return
	end
	if #data>=2 then
		var.txtLev:setRichLabel(data[1],20,19)
		var.txtLev:setPositionY(53)
		var.txtMate:setRichLabel(data[2],20,19)
	else
		var.txtLev:setRichLabel(data[1],20,19)
		var.txtLev:setPositionY(39)
		var.txtMate:setRichLabel("",20,19)
	end

end

--刷新右侧怪物信息
function ContainerBossMonster.showMonInfo(monData)
	if monData.monName then
		var.xmlPanel:getWidgetByName("labBossName"):setString("BOSS名称："..monData.monName)
	end
	if monData.monLev then
		var.xmlPanel:getWidgetByName("labBossLevel"):setString("BOSS等级："..monData.monLev.."级")
	end
	if monData.freshTime then
		var.xmlPanel:getWidgetByName("labTime"):setString("复活："..(monData.freshTime/60).."分钟"):setVisible(true)
	else
		var.xmlPanel:getWidgetByName("labTime"):setVisible(false)
	end
	if monData.drop then
		for i=1,6 do
			if monData.drop[i] then
				local awardItem=var.xmlPanel:getWidgetByName("icon"..i)
				local param={parent=awardItem, typeId=tonumber(monData.drop[i]), num=1}
				GUIItem.getItem(param)
				-- 
				local itemdef = GameSocket.mItemDesp[param.typeId]
				local effectID = 65078
				if itemdef then
					if itemdef.mItemBg > 0 then
						effectID = itemdef.mItemBg + effectID - 3
					end
				end
				local lowSprite = awardItem:getChildByName("spriteEffect")
				if lowSprite then
					lowSprite:stopAllActions()
					lowSprite:removeFromParent()
					lowSprite = nil
				end
				if itemdef and itemdef.mItemBg >=3 then
					if not lowSprite then
						lowSprite = cc.Sprite:create()
						lowSprite:setPosition(33,32)
						awardItem:addChild(lowSprite)
						lowSprite:setName("spriteEffect")
						local animate = cc.AnimManager:getInstance():getPlistAnimate(4, effectID, 4, 3,false,false,0,function(animate,shouldDownload)
							lowSprite:runAction(cca.repeatForever(animate))
							if shouldDownload==true then
								lowSprite:release()
							end
						end,
						function(animate)
							lowSprite:retain()
						end)
						
					end
				end
			end
		end
	end
	if monData.monImg then
		ContainerBossMonster.successAnimate(monData.monImg)
	end
end

--加载怪物动画
function ContainerBossMonster.successAnimate(id)
	if id=="" then return end
	if not var.fireworks then
		var.fireworks = cc.Sprite:create():addTo(var.xmlPanel):pos(461,179)
	end
	local animate = cc.AnimManager:getInstance():getPlistAnimate(0,id,4,12,false,false,0,function(animate,shouldDownload)
							if animate then
								var.fireworks:stopAllActions()
								var.fireworks:runAction(cca.seq({
									cca.rep(animate,10000),
									cca.removeSelf()
								}))
							end
							if shouldDownload==true then
								var.fireworks:release()
							end
						end,
						function(animate)
							var.fireworks:retain()
						end)
	
end

---------------------------------------------------------按钮操作----------------------------------------------------------
local btnArrs = {"btnYeWai","btnZhiJia","btnMaYa","btnFuBen"}
function ContainerBossMonster.initBtns()
	local function prsBtnClick(sender)
		local senderName = sender:getName()
		-- print(sender.index)
		if senderName=="btnYeWai" then
			GameSocket:PushLuaTable("gui.ContainerBossMonster.onPanelData",GameUtilSenior.encode({actionid = "enterYeWai",params = {index=sender.index}}))
		elseif senderName=="btnZhiJia" then
			GameSocket:PushLuaTable("gui.ContainerBossMonster.onPanelData",GameUtilSenior.encode({actionid = "enterZhiJia",params = {index=sender.index}}))
		elseif senderName=="btnMaYa" then 
			GameSocket:PushLuaTable("gui.ContainerBossMonster.onPanelData",GameUtilSenior.encode({actionid = "enterMaYa",params = {index=sender.index}}))
		elseif senderName=="btnFuBen" then
			if var.pageIndex==3 then
				GameSocket:PushLuaTable("gui.ContainerBossMonster.onPanelData",GameUtilSenior.encode({actionid = "reqEnterBossFuBen",params = {index=var.tabIndex}}))
			end
		end
	end
	for i=1,#btnArrs do
		local btn = var.xmlPanel:getWidgetByName(btnArrs[i])
		if btn then
			GUIFocusPoint.addUIPoint(btn,prsBtnClick) 
		end
	end
end


return ContainerBossMonster