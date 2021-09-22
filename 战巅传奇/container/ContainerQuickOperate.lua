local ContainerQuickOperate={}
local var = {}

local function pushToSelectContent(sender)
	print("pushToSelectContent", sender.tag)
	if var.imgSelected then var.imgSelected:hide() end
	var.imgSelected=sender:getWidgetByName("imgSelected"):show()
	var.curSelected = sender.tag
end

local function getSelectedSkillId()
	local shortCut = GameSocket.mShortCut[var.curSelected]
	if shortCut and shortCut.param > 0 then
		return shortCut.param
	end
end

function ContainerQuickOperate.initView(extend)
	var = {
		xmlPanel,
		curSelected=nil,--当前选中的需要设置快捷栏
		imgSelected=nil,
		curType=1,--默认是技能
	}
	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerQuickOperate.uif");
	if var.xmlPanel then
		var.imgSelected=var.xmlPanel:getWidgetByName("imgSelect")
		ContainerQuickOperate.initSkillList()
		ContainerQuickOperate.initBtnClick()
		ContainerQuickOperate.initBagItems()	
		ContainerQuickOperate.skillSelect()
		ContainerQuickOperate.updateRightSkill()
		ContainerQuickOperate.initYaoList()


		--local richtext=GUIRichLabel.new({size=cc.size(350,0), space=3, name="richWidget"})
		--richtext:addTo(var.xmlPanel):pos(74,125)
		--local text = "<font color=#b2a58b>点击</font><font color=#39d45a>物品</font><font color=#b2a58b>或</font><font color=#39d45a>技能</font><font color=#b2a58b>将其放入右侧快捷栏</font>"
		--richtext:setRichLabel(text,"ContainerQuickOperate",16)
		
		
		ContainerQuickOperate.updateGameMoney()
		var.xmlPanel:getWidgetByName("box_tab"):addTabEventListener(ContainerQuickOperate.pushTabButtons)
		
	end
	return var.xmlPanel
end


function ContainerQuickOperate.pushTabButtons(sender)
	local opened, level, funcName
	opened = true
	local tag = sender:getTag()
	if tag==1 then
		ContainerQuickOperate.changeDaoJu("skill")
		var.curType=1
	elseif tag==2 then
		ContainerQuickOperate.changeDaoJu(nil)
		var.curType=2
	end
end

--金币刷新函数
function ContainerQuickOperate:updateGameMoney()
	local panel = var.xmlPanel
	if panel then
		local mainrole = GameSocket.mCharacter
		local moneyLabel = {
			{name="big_title_yb_text",btn="big_title_yb_btn",	pre=GameConst.str_vcoin,	value =	mainrole.mVCoin or 0	,	icon = "icon_coin"},
			{name="big_title_hmb_text",btn="big_title_hmb_btn",	pre=GameConst.str_vcoinb,	value =	mainrole.mVCoinBind or 0,	icon = "icon_coin_bind"},
			{name="big_title_jb_text",btn="big_title_jb_btn",	pre=GameConst.str_money,	value =	mainrole.mGameMoney or 0,	icon = "icon_money"},
			{name="lblBMoney",	pre=GameConst.str_moneyb,	value =	mainrole.mGameMoneyBind or 0,	icon = "icon_money"},
		}
		--建临时表遍历设属性
		for _,v in ipairs(moneyLabel) do
			if panel:getWidgetByName(v.name) then
				panel:getWidgetByName(v.name):setString(v.value)
				panel:getWidgetByName(v.btn):addClickEventListener( function (sender)
					GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str="panel_charge"})
				end)
			end
		end
	end
end

function ContainerQuickOperate.onPanelData(event)
	
end

--extend.mParam.type=1:打开技能设置 extend.mParam.type=2：打开药品设置
function ContainerQuickOperate.onPanelOpen(extend)
	if extend and extend.mParam and extend.mParam.type==2 then
		ContainerQuickOperate.changeDaoJu(nil)
		var.curType=2
		var.xmlPanel:getWidgetByName("box_tab"):setSelectedTab(2)
	else
		ContainerQuickOperate.changeDaoJu("skill")
		var.xmlPanel:getWidgetByName("box_tab"):setSelectedTab(1)
	end
end

function ContainerQuickOperate.onPanelClose()
	var.curSelected = nil
end

function ContainerQuickOperate.initBtnClick()
	--local btnArr = {"btnSkill","btnDaoJu","btnClearSet","btnFanHui"}
	local btnArr = {"btnClearSet","btnFanHui"}
	local function prsBtnClick(sender)
		local btnName = sender:getName()
		if btnName=="btnSkill" then
			ContainerQuickOperate.changeDaoJu("skill")
			var.curType=1
		elseif btnName=="btnDaoJu" then
			ContainerQuickOperate.changeDaoJu(nil)
			var.curType=2
		elseif btnName=="btnClearSet" then
			ContainerQuickOperate.clearAllSet(type)
		elseif btnName=="btnFanHui" then
			local skillId = getSelectedSkillId()
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "main_skill",  skillId = skillId})
		end
	end
	for i=1,#btnArr do
		local btn = var.xmlPanel:getWidgetByName(btnArr[i]):setPressedActionEnabled(true)
		GUIFocusPoint.addUIPoint(btn,prsBtnClick)
	end
end

--初始化左侧道具列表
function ContainerQuickOperate.initYaoList()
	local function prsContentClick(sender)
		if var.imgSelected then var.imgSelected:hide() end
		var.imgSelected=sender:getWidgetByName("imgSelected"):show()
		var.curSelected = sender.tag
	end
	local function updatePropList(item)
		item:setTouchEnabled(true)
		GUIFocusPoint.addUIPoint(item, pushToSelectContent)
		local skillIcon = item:getWidgetByName("skillIcon"):show()
		local shortCut = GameSocket.mShortCut[item.tag + GameConst.SHORT_SKILL_END]
		if shortCut and shortCut.param > 0 then
			--skillIcon:loadTexture("image/icon/"..shortCut.param..".png")
			
			local path = "image/icon/"..shortCut.param..".png"
			asyncload_callback(path, skillIcon, function(path, texture)
				skillIcon:loadTexture(path)
			end)
		else
			--skillIcon:hide()
		end
		item:getWidgetByName("imgNum"):loadTexture((5-item.tag),ccui.TextureResType.plistType)
		item:setName("item_quick"..item.tag)
	end
	local listYao = var.xmlPanel:getWidgetByName("listYao"):setSliderVisible(false):setTouchEnabled(false)
	listYao:reloadData(4,updatePropList)
end

--左侧技能列表
function ContainerQuickOperate.initSkillList()
	local function prsContentClick(sender)
		ContainerQuickOperate.setShortCutSkill(sender.skill_id)
	end

	local skillsDesp = {}

	for k,v in pairs(GameSocket.m_skillsDesp) do
		if v.skill_id ~= GameConst.SKILL_TYPE_YiBanGongJi then
			table.insert(skillsDesp, v)
		end
	end
	
	local function sortF(nsd1, nsd2)
		return nsd1.mOrderID < nsd2.mOrderID
	end
	table.sort(skillsDesp, sortF)

	local netSkill, path
	local function updateSkillList(item)
		if item.tag>#skillsDesp then
			item:hide()
			return
		else
			item:show()
		end
		local skillIcon = item:getWidgetByName("skillIcon")
		local nsd=skillsDesp[item.tag]
		netSkill = GameSocket.m_netSkill[nsd.skill_id]

		path = "image/icon/skill"..nsd.skill_id..".png"
		if netSkill and netSkill.mLevel > 10 then
			path = "image/icon/skill"..nsd.skill_id.."_angry.png"
		end
		
		
		--skillIcon:loadTexture(path)
		
		asyncload_callback(path, skillIcon, function(path, texture)
			skillIcon:loadTexture(path)
			skillIcon:setScale((item:getWidgetByName("skillBg"):getContentSize().width-9)/(skillIcon:getContentSize().width-18),(item:getWidgetByName("skillBg"):getContentSize().height-9)/(skillIcon:getContentSize().height-18))
		end)
		
		item:getWidgetByName("skillName"):setString(nsd.mName)
		item.skill_id = nsd.skill_id
		item:setTouchEnabled(true)
		GUIFocusPoint.addUIPoint(item,prsContentClick)
	end
	local listSkill = var.xmlPanel:getWidgetByName("listSkill")--:setSliderVisible(false):setTouchEnabled(false)
	listSkill:reloadData(#skillsDesp,updateSkillList)


end

--点击左侧技能时的设置操作
function ContainerQuickOperate.setShortCutSkill(value)
	if var.curSelected and var.curSelected >= 1 and var.curSelected <= 8 then
		if GameBaseLogic.IsPassiveSkill(value) then
			return GameSocket:alertLocalMsg("被动技能不可设置", "alert")
		end

		-- ContainerQuickOperate.checkSameKey(value)
		local shortCut
		-- 去重
		for i=1,GameConst.SHORT_SKILL_END do
			shortCut = GameSocket.mShortCut[i]
			if shortCut and shortCut.param == value then
				GameSocket.mShortCut[i] = nil
			end
		end
		--设置
		shortCut = {}
		shortCut.cut_id = var.curSelected
		shortCut.type = 2
		shortCut.param = value
		shortCut.itemnum = 1
		GameSocket.mShortCut[shortCut.cut_id] = shortCut
		-- print(var.curSelected,value,shortCut,"===========00000=============")
		-- 保存
		GameSocket:SaveShortcut()
		ContainerQuickOperate.updateRightSkill()
	else
		GameSocket:alertLocalMsg("请先选中右侧需要设置的位置！", "alert")
	end
end

--刷新右侧技能显示
function ContainerQuickOperate.updateRightSkill()
	local netSkill, nsd
	for i=1,GameConst.SHORT_SKILL_END do
		local path = "image/icon/null.png"
		local shortCut = GameSocket.mShortCut[i]
		local contentSkill = var.xmlPanel:getWidgetByName("content"..i)
		local skillIcon = contentSkill:getWidgetByName("skillIcon")
		if GameSocket.mShortCut[i] then

			netSkill = GameSocket.m_netSkill[shortCut.param]
			path = "image/icon/skill"..shortCut.param..".png"
			if netSkill and netSkill.mLevel > 10 then
				path = "image/icon/skill"..shortCut.param.."_angry.png"
			end
		end
		--skillIcon:loadTexture(path)
		
		asyncload_callback(path, skillIcon, function(path, texture)
			skillIcon:loadTexture(path)
		end)
	end
end

--背包内可设置的物品
function ContainerQuickOperate.initBagItems()
	local result = ContainerQuickOperate.getNeedItems()
	local function updateBagList(item)
		local itemPos = result[item.tag]
		local netItem = GameSocket:getNetItem(itemPos)
		local subItem = item:getWidgetByName("imgIcon")
		if item.tag>GameConst.ITEM_BAG_SIZE+GameSocket.mBagSlotAdd then
			subItem:hide()
		else
			subItem:show()
		end
		local param = {
			parent = item,
			pos = itemPos,
			iconType = GameConst.ICONTYPE.NOTIP,
			-- iconType = GameConst.ICONTYPE.BAG,
			callBack = function ()
				ContainerQuickOperate.setShortCutProp(netItem.mTypeID)
			end,
			doubleCall = function ()
				-- ContainerQuickOperate.setShortCutProp(netItem.mTypeID)
			end,
		}
		GUIItem.getItem(param)

		if item.tag == 1 then
			item:setName("item_drug");
		else
			item:setName("");
		end

	end
	local geNum = 25
	if #result>25 then geNum=#result end
	local listBag = var.xmlPanel:getWidgetByName("listBag")
	-- listBag:reloadData(math.ceil((geNum)/5)*5,updateBagList)
	listBag:reloadData(120,updateBagList)
end

--筛选能设置到快捷栏的物品
function ContainerQuickOperate.getNeedItems()
	-- local maxNum = GameConst.ITEM_BAG_SIZE+GameSocket.mBagSlotAdd 
	local maxNum=120
	local result = {}
	for i=0,maxNum-1 do
		local netItem = GameSocket:getNetItem(i)
		if netItem and GameBaseLogic.checkShortCutItem(netItem.mTypeID) then
			table.insert(result, netItem.position)
		end
	end
	return result
end

--点击道具切花操作
function ContainerQuickOperate.changeDaoJu(type)
	local listBag = var.xmlPanel:getWidgetByName("listBag")
	local listSkill = var.xmlPanel:getWidgetByName("listSkill")
	local listYao = var.xmlPanel:getWidgetByName("listYao")
	local contentSkill = var.xmlPanel:getWidgetByName("contentSkill")
	local btnClearSet = var.xmlPanel:getWidgetByName("btnClearSet")
	local btnFanHui = var.xmlPanel:getWidgetByName("btnFanHui")

	if type=="skill" then
		listBag:hide() listYao:hide() listSkill:show() contentSkill:show()
		btnClearSet:setPositionX(565)
		btnFanHui:show()
		local skillBg = var.xmlPanel:getWidgetByName("content1")
		pushToSelectContent(skillBg)
	else
		listBag:show() listYao:show() listSkill:hide() contentSkill:hide()
		btnClearSet:setPositionX(660)
		btnFanHui:hide()
		local listYao = var.xmlPanel:getWidgetByName("listYao")
		local itemModel = listYao:getModelByIndex(4)
		pushToSelectContent(itemModel)
	end
end

--选中需要设置的技能快捷栏
function ContainerQuickOperate.skillSelect()
	local function prsContentClick(sender)
		if var.imgSelected then var.imgSelected:hide() end
		var.imgSelected=sender:getWidgetByName("imgSelected"):show()
		var.curSelected = sender.key
	end
	for i=1,8 do
		local skillBg = var.xmlPanel:getWidgetByName("content"..i)
		skillBg:setTouchEnabled(true)
		skillBg.tag = i--对应本地保存的键
		GUIFocusPoint.addUIPoint(skillBg, pushToSelectContent)
	end
end

--点击左侧药品或者技能时的设置操作
function ContainerQuickOperate.setShortCutProp(value)
	-- print("setShortCutProp",var.curSelected,value)
	if var.curSelected and var.curSelected >= 1 and var.curSelected <= 4 then
		-- ContainerQuickOperate.checkSameKey(value)
		local shortCut
		-- 去重
		for i=1,4 do
			shortCut = GameSocket.mShortCut[GameConst.SHORT_SKILL_END + i]
			if shortCut and shortCut.param == value then
				GameSocket.mShortCut[GameConst.SHORT_SKILL_END + i] = nil
			end
		end
		--设置
		shortCut = {}
		shortCut.cut_id = GameConst.SHORT_SKILL_END + var.curSelected
		shortCut.type = 1
		shortCut.param = value
		shortCut.itemnum = 1
		GameSocket.mShortCut[shortCut.cut_id] = shortCut
		-- 保存
		GameSocket:SaveShortcut()
		ContainerQuickOperate.initYaoList()
	else
		GameSocket:alertLocalMsg("请先选中右侧需要设置的位置！", "alert")
	end
end

--清空设置type==1：清空技能设置  type==2：清空药品设置
function ContainerQuickOperate.clearAllSet()
	if var.curType==1 then
		for i=1,GameConst.SHORT_SKILL_END do
			GameSocket.mShortCut[i] = nil
		end
		GameSocket:SaveShortcut()
		ContainerQuickOperate.updateRightSkill()
	else
		for i=1,4 do
			GameSocket.mShortCut[GameConst.SHORT_SKILL_END + i] = nil
		end
		GameSocket:SaveShortcut()
		ContainerQuickOperate.initYaoList()
	end
end

return ContainerQuickOperate