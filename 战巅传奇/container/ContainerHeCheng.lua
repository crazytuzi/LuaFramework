local ContainerHeCheng={}
local var = {}

local despTable ={
	[1]="<font color=#E7BA52 size=18>合成说明：</font>",
	[2]="<font color=#f1e8d0>1、合成物可以通过击杀精英怪获得</font>",
    [3]="<font color=#f1e8d0>2、不同的物品所需的合成物的种类和数量不同</font>",
}

local itemTypeData = {"材料","技能","材料","宝石","永久"}

function ContainerHeCheng.initView()
	var = {
		xmlPanel,
		tablistv,
		targetKey=0,
		euipsTable={},
		isPlayMid=false,
		effArrs={false,false,false},

	}
	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerHeCheng.uif");
	if var.xmlPanel then
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, ContainerHeCheng.handlePanelData)
		--GameUtilSenior.asyncload(var.xmlPanel, "imgBg", "ui/image/synthesis.jpg")
		var.tablistv = var.xmlPanel:getWidgetByName("box_tab"):setFontSize(18)
		var.tablistv:addTabEventListener(ContainerHeCheng.pushTabsButton)
		var.hc_num = var.xmlPanel:getWidgetByName("hc_num")
		var.xmlPanel:getWidgetByName("btn_jia"):addClickEventListener(function (sender)
			ContainerHeCheng.jiaNum()
		end)
		var.xmlPanel:getWidgetByName("btn_jian"):addClickEventListener(function (sender)
			ContainerHeCheng.jianNum()
		end)
		var.xmlPanel:getWidgetByName("btn_max"):addClickEventListener(function (sender)
			ContainerHeCheng.maxNum()
		end)

		var.xmlPanel:getWidgetByName("btnHeCheng"):addClickEventListener(function (sender)
			if var.targetKey>0 then
				GameSocket:PushLuaTable("gui.ContainerHeCheng.handlePanelData",GameUtilSenior.encode({actionid="startHeCheng",key=var.targetKey,num = tonumber(var.hc_num:getString())}))
			else
				GameSocket:alertLocalMsg("请先放入需要合成的物品！", "alert")
			end
		end)

		local btnDesp = var.xmlPanel:getWidgetByName("btnDesp")
		btnDesp:setTouchEnabled(true)
		btnDesp:addTouchEventListener(function (pSender, touchType)
			if touchType == ccui.TouchEventType.began then
				btnDesp:setScale(0.88, 0.88)
				ContainerHeCheng.heChengDesp()
			elseif touchType == ccui.TouchEventType.ended or touchType == ccui.TouchEventType.canceled then	
				btnDesp:setScale(1, 1)
				GDivDialog.handleAlertClose()
			end
		end)
	end
	return var.xmlPanel
end

function ContainerHeCheng.onPanelOpen()
	var.tablistv:setSelectedTab(1)
end

function ContainerHeCheng.onPanelClose()
	
end

function ContainerHeCheng.pushTabsButton(tab)
	GameSocket:PushLuaTable("gui.ContainerHeCheng.handlePanelData",GameUtilSenior.encode({actionid="getData",tab=tab:getTag()}))
	var.tabIndex = tab:getTag()
	var.targetKey=0
	ContainerHeCheng.clearHeChengShow()
end

function ContainerHeCheng.handlePanelData(event)
	if event.type ~= "ContainerHeCheng" then return end
	local data = GameUtilSenior.decode(event.data)

	if data.cmd == "getData" then
		ContainerHeCheng.getData(data.data)
	elseif data.cmd == "get_item_data" then
		var.maxNum = data.max_num==0 and 1 or data.max_num
		for i=1,3 do
			if data["num"..i] then
				var.xmlPanel:getWidgetByName("itemNameBg_"..i):show():getChildByName("labName"):setString("拥有:"..data["num"..i])
				if var.itemData["neednum"..i]>data["num"..i] then
					var.xmlPanel:getWidgetByName("itemNameBg_"..i):show():getChildByName("labName"):setColor(GameBaseLogic.getColor(0xFF0000))
				else
					var.xmlPanel:getWidgetByName("itemNameBg_"..i):show():getChildByName("labName"):setColor(GameBaseLogic.getColor(0xfddfae))
				end
			else
				var.xmlPanel:getWidgetByName("itemNameBg_"..i):hide()
			end
		end
	end
end

function ContainerHeCheng.getData( data )
	var.xmlPanel:getWidgetByName("list_item"):hide()
	var.xmlPanel:getWidgetByName("skill_btns"):hide()
	var.xmlPanel:getWidgetByName("stone_btns"):hide()
	var.xmlPanel:getWidgetByName("list_item_1"):hide()
	var.xmlPanel:getWidgetByName("list_item_2"):hide()
	var.hechengData = data
	if var.tabIndex==2 then
		var.xmlPanel:getWidgetByName("skill_btns"):show()
		ContainerHeCheng.initSkillBtns()
	elseif var.tabIndex==4 then
		var.xmlPanel:getWidgetByName("stone_btns"):show()
		ContainerHeCheng.initStoneBtns()
	else
		var.xmlPanel:getWidgetByName("list_item"):show()
		ContainerHeCheng.set_item_list(data,"list_item")
		if var.lastStone then
			var.xmlPanel:getWidgetByName("stone_"..var.lastStone):getChildByName("imgFlag"):loadTexture("img_hc_jia",ccui.TextureResType.plistType)
		end
		if var.lastSkill then
			var.xmlPanel:getWidgetByName("skill_"..var.lastSkill):getChildByName("imgFlag"):loadTexture("img_hc_jia",ccui.TextureResType.plistType)
		end	
		var.lastSkill=nil
		var.lastStone=nil
	end
end

function ContainerHeCheng.initSkillBtns()
	local function prsBtnClick(sender)
		if not var.lastSkill or var.lastSkill~=sender.index then
			for i=1,4 do
				if i<=sender.index then
					var.xmlPanel:getWidgetByName("skill_"..i):setPositionY(519-33*(i-1))
				else
					var.xmlPanel:getWidgetByName("skill_"..i):setPositionY(519-33*(i-1)-403)
				end
			end
			if var.lastSkill and var.lastSkill~=sender.index then
				var.xmlPanel:getWidgetByName("skill_"..var.lastSkill):getChildByName("imgFlag"):loadTexture("img_hc_jia",ccui.TextureResType.plistType)
			end	
			var.lastSkill = sender.index
			var.xmlPanel:getWidgetByName("skill_"..sender.index):getChildByName("imgFlag"):loadTexture("img_hc_jian",ccui.TextureResType.plistType)
			var.xmlPanel:getWidgetByName("list_item_1"):setPositionY(33*(4-sender.index)+33/2):show()
			local data = {}
			for i=1,#var.hechengData do
				if tonumber(var.hechengData[i].type2) == sender.index then
					table.insert(data,var.hechengData[i])
				end
			end
			ContainerHeCheng.set_item_list(data,"list_item_1")
		else
			for i=1,4 do
				var.xmlPanel:getWidgetByName("skill_"..i):setPositionY(519-33*(i-1))
			end
			var.lastSkill = sender.index
			var.xmlPanel:getWidgetByName("skill_"..sender.index):getChildByName("imgFlag"):loadTexture("img_hc_jia",ccui.TextureResType.plistType)
			var.xmlPanel:getWidgetByName("list_item_1"):hide()
			var.lastSkill=nil
		end
	end
	for i=1,4 do
		local btn = var.xmlPanel:getWidgetByName("skill_"..i)
		btn.index = i
		GUIFocusPoint.addUIPoint(btn,prsBtnClick)
		var.xmlPanel:getWidgetByName("skill_"..i):setPositionY(519-33*(i-1))
	end
	if var.lastSkill then
		var.xmlPanel:getWidgetByName("skill_"..var.lastSkill):getChildByName("imgFlag"):loadTexture("img_hc_jia",ccui.TextureResType.plistType)
	end
end

function ContainerHeCheng.initStoneBtns()
	local function prsBtnClick(sender)
		if not var.lastStone or var.lastStone~=sender.index then
			for i=1,8 do
				if i<=sender.index then
					var.xmlPanel:getWidgetByName("stone_"..i):setPositionY(519-33*(i-1))
				else
					var.xmlPanel:getWidgetByName("stone_"..i):setPositionY(519-33*(i-1)-271)
				end
			end
			if var.lastStone and var.lastStone~=sender.index then
				var.xmlPanel:getWidgetByName("stone_"..var.lastStone):getChildByName("imgFlag"):loadTexture("img_hc_jia",ccui.TextureResType.plistType)
			end	
			var.lastStone = sender.index
			var.xmlPanel:getWidgetByName("stone_"..sender.index):getChildByName("imgFlag"):loadTexture("img_hc_jian",ccui.TextureResType.plistType)
			var.xmlPanel:getWidgetByName("list_item_2"):setPositionY(33*(8-sender.index)+33/2):show()
			local data = {}
			for i=1,#var.hechengData do
				if tonumber(var.hechengData[i].type2) == sender.index then
					table.insert(data,var.hechengData[i])
				end
			end
			ContainerHeCheng.set_item_list(data,"list_item_2")
		else
			for i=1,8 do
				var.xmlPanel:getWidgetByName("stone_"..i):setPositionY(519-33*(i-1))
			end
			var.lastStone = sender.index
			var.xmlPanel:getWidgetByName("stone_"..sender.index):getChildByName("imgFlag"):loadTexture("img_hc_jia",ccui.TextureResType.plistType)
			var.xmlPanel:getWidgetByName("list_item_2"):hide()
			var.lastStone=nil
		end
	end
	for i=1,8 do
		local btn = var.xmlPanel:getWidgetByName("stone_"..i)
		btn.index = i
		GUIFocusPoint.addUIPoint(btn,prsBtnClick)
		var.xmlPanel:getWidgetByName("stone_"..i):setPositionY(519-33*(i-1))
	end
	if var.lastStone then
		var.xmlPanel:getWidgetByName("stone_"..var.lastStone):getChildByName("imgFlag"):loadTexture("img_hc_jia",ccui.TextureResType.plistType)
	end
end

function ContainerHeCheng.set_item_list(data,id)
	local curSelected = nil
	local init = true
	local function prsBtnClick(sender)
		local senderName = sender:getName()
		if curSelected then
			curSelected:getWidgetByName("imgSelected"):setVisible(false)
		end
		sender:getWidgetByName("imgSelected"):setVisible(true)
		curSelected=sender
		init=false
		GameSocket:PushLuaTable("gui.ContainerHeCheng.handlePanelData",GameUtilSenior.encode({actionid="get_item_data",id=sender.key}))
		ContainerHeCheng.updateHeChengShow(data[sender.tag])
	end
	local function updateHeChengList(item)
		local itemData = data[item.tag]
		local icon = item:getWidgetByName("icon")
		local param={parent=icon, typeId=itemData.targetid}
		GUIItem.getItem(param)
		local itemdef = GameSocket:getItemDefByID(itemData.targetid)
  	 	if itemdef then
  	 		item:getWidgetByName("itemName"):setString(itemdef.mName)
  	 	end
		item:getWidgetByName("itemType"):setString(itemTypeData[var.tabIndex])
		item:setTouchEnabled(true)
		item.key=itemData.id
		GUIFocusPoint.addUIPoint(item,prsBtnClick)
		if init then
			item:getWidgetByName("imgSelected"):setVisible(false)
		end
	end
	local list = var.xmlPanel:getWidgetByName(id)
	list:reloadData(#data,updateHeChengList)
end

--清空右侧显示
function ContainerHeCheng.clearHeChengShow()
	for i=1,3 do
		--var.xmlPanel:getWidgetByName("item"..i):setVisible(false)
		var.xmlPanel:getWidgetByName("imgLock"..i):setVisible(true)
		var.xmlPanel:getWidgetByName("itemNameBg_"..i):hide()
	end
	--var.xmlPanel:getWidgetByName("itemTarget"):setVisible(false)
	var.xmlPanel:getWidgetByName("labName"):setString("")
	var.effArrs={false,false,false}
end

--刷新右侧显示
function ContainerHeCheng.updateHeChengShow(itemData)
	if not itemData then
		return ContainerHeCheng.clearHeChengShow()
	end
	local item1 = var.xmlPanel:getWidgetByName("item1")
	local imgLock1 = var.xmlPanel:getWidgetByName("imgLock1")
	if itemData.needid1>0 then
		local param={parent=item1, typeId=itemData.needid1, num=itemData.neednum1}
		GUIItem.getItem(param)
		item1:setVisible(true)
		imgLock1:setVisible(false)
		var.effArrs[1]=true
	else
		item1:setVisible(false)
		imgLock1:setVisible(true)
		var.effArrs[1]=false
	end
	local item2 = var.xmlPanel:getWidgetByName("item2")
	local imgLock2 = var.xmlPanel:getWidgetByName("imgLock2")
	if itemData.needid2>0 then
		local param={parent=item2, typeId=itemData.needid2, num=itemData.neednum2}
		GUIItem.getItem(param)
		item2:setVisible(true)
		imgLock2:setVisible(false)
		var.effArrs[2]=true
	else
		item2:setVisible(false)
		imgLock2:setVisible(true)
		var.effArrs[2]=false
	end
	local item3 = var.xmlPanel:getWidgetByName("item3")
	local imgLock3 = var.xmlPanel:getWidgetByName("imgLock3")
	if itemData.needid3>0 then
		local param={parent=item3, typeId=itemData.needid3, num=itemData.neednum3}
		GUIItem.getItem(param)
		item3:setVisible(true)
		imgLock3:setVisible(false)
		var.effArrs[3]=true
	else
		item3:setVisible(false)
		imgLock3:setVisible(true)
		var.effArrs[3]=false
	end
	local itemTarget = var.xmlPanel:getWidgetByName("itemTarget"):setVisible(true)
	local param={parent=itemTarget, typeId=itemData.targetid}
	GUIItem.getItem(param)
	local itemdef = GameSocket:getItemDefByID(itemData.targetid)
 	if itemdef then
 		var.xmlPanel:getWidgetByName("labName"):setString(itemdef.mName)
 	end
 	var.itemData = itemData
	var.targetKey=itemData.id
end
function ContainerHeCheng.heChengDesp()
	local mParam = {
	name = GameMessageCode.EVENT_PANEL_ON_ALERT,
	panel = "tips", 
	infoTable = despTable,
	visible = true, 
	}
	GameSocket:dispatchEvent(mParam)
end

function ContainerHeCheng.jiaNum()
	if var.targetKey>0 then
		local num = var.hc_num:getString()
		num = tonumber(num)+1
		if num>var.maxNum then
			GameSocket:alertLocalMsg("已达到最大值", "alert")
		else
			var.hc_num:setString(num)
		end
	else
		GameSocket:alertLocalMsg("请先放入需要合成的物品！", "alert")
	end
end

function ContainerHeCheng.jianNum()
	if var.targetKey>0 then
		local num = var.hc_num:getString()
		if tonumber(num)==1 then
			GameSocket:alertLocalMsg("已达到最小值", "alert")
		else
			var.hc_num:setString(num-1)
		end
	else
		GameSocket:alertLocalMsg("请先放入需要合成的物品！", "alert")
	end
end

function ContainerHeCheng.maxNum()
	if var.targetKey>0 then
		var.hc_num:setString(var.maxNum)
	else
		GameSocket:alertLocalMsg("请先放入需要合成的物品！", "alert")
	end
end

return ContainerHeCheng