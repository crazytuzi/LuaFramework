local ContainerEquipWash = {}
local var = {}


--获取身上可以强化的装备
local roleEquipPos = {
	{pos = GameConst.ITEM_WEAPON_POSITION,	etype = GameConst.EQUIP_TAG.WEAPON},
	{pos = GameConst.ITEM_CLOTH_POSITION,	etype = GameConst.EQUIP_TAG.CLOTH},
	{pos = GameConst.ITEM_GLOVE1_POSITION,	etype = GameConst.EQUIP_TAG.GLOVE},
	{pos = GameConst.ITEM_RING1_POSITION,	etype = GameConst.EQUIP_TAG.RING},
	{pos = GameConst.ITEM_BOOT_POSITION,	etype = GameConst.EQUIP_TAG.BOOT},

	{pos = GameConst.ITEM_HAT_POSITION,		etype = GameConst.EQUIP_TAG.HAT},
	{pos = GameConst.ITEM_NICKLACE_POSITION,etype = GameConst.EQUIP_TAG.NECKLACE},
	{pos = GameConst.ITEM_GLOVE2_POSITION,	etype = GameConst.EQUIP_TAG.GLOVE},
	{pos = GameConst.ITEM_RING2_POSITION,	etype = GameConst.EQUIP_TAG.RING},
	{pos = GameConst.ITEM_BELT_POSITION,	etype = GameConst.EQUIP_TAG.BELT},
	

	--[[
	--{pos = GameConst.ITEM_JADE_PENDANT_POSITION,	noTipsBtn = true},
	{pos = GameConst.ITEM_JADE_PENDANT_POSITION,	},
	--{pos = GameConst.ITEM_SHIELD_POSITION,			noTipsBtn = true},
	{pos = GameConst.ITEM_SHIELD_POSITION,			},
	{pos = GameConst.ITEM_MIRROR_ARMOUR_POSITION,	},
	{pos = GameConst.ITEM_FACE_CLOTH_POSITION,		},
	--{pos = GameConst.ITEM_DRAGON_HEART_POSITION,	noTipsBtn = true},
	{pos = GameConst.ITEM_DRAGON_HEART_POSITION,	},
	--{pos = GameConst.ITEM_WOLFANG_POSITION,			noTipsBtn = true},
	{pos = GameConst.ITEM_WOLFANG_POSITION,	},
	{pos = GameConst.ITEM_DRAGON_BONE_POSITION,		},
	{pos = GameConst.ITEM_CATILLA_POSITION,			},
	
	{pos = GameConst.ITEM_XUEFU_POSITION,	etype = GameConst.EQUIP_TAG.XUEFU},
	{pos = GameConst.ITEM_FABAO_POSITION,	etype = GameConst.EQUIP_TAG.FABAO},
	{pos = GameConst.ITEM_LINGFU_POSITION,	etype = GameConst.EQUIP_TAG.LINGFU},
	{pos = GameConst.ITEM_YINGHUN_POSITION,	etype = GameConst.EQUIP_TAG.YINGHUN},
	{pos = GameConst.ITEM_BAODING_POSITION,	etype = GameConst.EQUIP_TAG.BAODING},
	{pos = GameConst.ITEM_ZHANQI_POSITION,	etype = GameConst.EQUIP_TAG.ZHANQI},
	{pos = GameConst.ITEM_SHOUHU_POSITION,	etype = GameConst.EQUIP_TAG.SHOUHU},
	{pos = GameConst.ITEM_ZHANDUN_POSITION,	etype = GameConst.EQUIP_TAG.ZHANDUN},
	
	{pos = GameConst.ITEM_ZHUZHUANGPLUS1_POSITION,	etype = GameConst.EQUIP_TAG.ZHUZHUANGPLUS1},
	{pos = GameConst.ITEM_ZHUZHUANGPLUS2_POSITION,	etype = GameConst.EQUIP_TAG.ZHUZHUANGPLUS2},
	
	{pos = GameConst.ITEM_FUZHUANGPLUS1_POSITION,	etype = GameConst.EQUIP_TAG.FUZHUANGPLUS1},
	{pos = GameConst.ITEM_FUZHUANGPLUS2_POSITION,	etype = GameConst.EQUIP_TAG.FUZHUANGPLUS2},
	{pos = GameConst.ITEM_FUZHUANGPLUS3_POSITION,	etype = GameConst.EQUIP_TAG.FUZHUANGPLUS3},
	
	{pos = GameConst.ITEM_SRSX1_POSITION,	etype = GameConst.EQUIP_TAG.SRSX1},
	{pos = GameConst.ITEM_SRSX2_POSITION,	etype = GameConst.EQUIP_TAG.SRSX2},
	{pos = GameConst.ITEM_SRSX3_POSITION,	etype = GameConst.EQUIP_TAG.SRSX3},
	{pos = GameConst.ITEM_SRSX4_POSITION,	etype = GameConst.EQUIP_TAG.SRSX4},
	{pos = GameConst.ITEM_SRSX5_POSITION,	etype = GameConst.EQUIP_TAG.SRSX5},
	{pos = GameConst.ITEM_SRSX6_POSITION,	etype = GameConst.EQUIP_TAG.SRSX6},
	{pos = GameConst.ITEM_SRSX7_POSITION,	etype = GameConst.EQUIP_TAG.SRSX7},
	{pos = GameConst.ITEM_SRSX8_POSITION,	etype = GameConst.EQUIP_TAG.SRSX8},
	{pos = GameConst.ITEM_SRSX9_POSITION,	etype = GameConst.EQUIP_TAG.SRSX9},
	{pos = GameConst.ITEM_SRSX10_POSITION,	etype = GameConst.EQUIP_TAG.SRSX10},
	{pos = GameConst.ITEM_SRSX11_POSITION,	etype = GameConst.EQUIP_TAG.SRSX11},
	{pos = GameConst.ITEM_SRSX12_POSITION,	etype = GameConst.EQUIP_TAG.SRSX12},
	]]--

}



function ContainerEquipWash.onPanelOpen(event)

end

function ContainerEquipWash.initView(extend)
	var = {
		items={},
		xmlPanel,
		tablisth,
		curEquipType=nil,--记录当前选中的是背包装备还是身上装备
		curEquipName="",
		curWashPos=-9999,--当前强化装备的pos
	}
	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerEquipWash.uif")
	if var.xmlPanel then
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, ContainerEquipWash.handlePanelData)

		--ContainerEquipWash.showTitleAnimation()
		
		
		--ContainerEquipWash.showList()
		ContainerEquipWash.initTabs()
		ContainerEquipWash.initEquipList("roleEquips")
		ContainerEquipWash:updateGameMoney(var.xmlPanel)

		var.xmlPanel:getWidgetByName("btnWash"):addClickEventListener( function (sender)
			if var.curWashPos~=-9999 then
				GameSocket:PushLuaTable("gui.ContainerEquipWash.handlePanelData",GameUtilSenior.encode({actionid="startWash",params={pos=var.curWashPos}}))
			else
				GameSocket:alertLocalMsg("请先放入需要洗炼的装备", "alert")
			end
		end)
					
		return var.xmlPanel
	end
end


--金币刷新函数
function ContainerEquipWash:updateGameMoney(panel)
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
				print(v.btn)
				panel:getWidgetByName(v.btn):addClickEventListener( function (sender)
					GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str="panel_charge"})
				end)
			end
		end
	end
end

function ContainerEquipWash.initTabs()
	local function pressTabV(sender)
		local tag = sender:getTag()
		if tag==1 then
			
		elseif tag==2 then
		end
		ContainerEquipWash.initEquipList(var.curEquipType)
	end
	local function pressTabH(sender)
		local tag = sender:getTag()
		if tag==1 then
			ContainerEquipWash.initEquipList("roleEquips")
		elseif tag==2 then
			ContainerEquipWash.initEquipList("bagEquips")
		end
	end
	var.tablistv = var.xmlPanel:getWidgetByName("tablistv")
	var.tablistv:addTabEventListener(pressTabV)
	var.tablistv:setSelectedTab(1)
	var.tablisth = var.xmlPanel:getWidgetByName("tablisth")
	var.tablisth:addTabEventListener(pressTabH)
	var.tablisth:setItemMargin(30)
	var.tablisth:setTabColor(GameBaseLogic.getColor(0xdce910),GameBaseLogic.getColor(0xf1e8d0))
	var.tablisth:setTabRes("ContainerSmelt_btn_switch.png","ContainerSmelt_btn_switch_sel.png")
end


--初始化背包装备或身上装备
function ContainerEquipWash.initEquipList(type)
	if type=="bagEquips" then
		var.curEquips=ContainerEquipWash.getQiangHuaEquips()
		var.curEquipType="bagEquips"
	elseif type=="roleEquips" then
		var.curEquips=ContainerEquipWash.getRoleEquips()
		var.curEquipType="roleEquips"
	end
	local equipList = var.xmlPanel:getWidgetByName("equipList")
	equipList:reloadData(76,ContainerEquipWash.updateList):setSliderVisible(false)
end


function ContainerEquipWash.updateList(item)
	local itemPos=var.curEquips[item.tag] or -9999
	local param = {
		parent = item,
		pos = itemPos,
		iconType = GameConst.ICONTYPE.DEPOT,
		-- tipsType = GameConst.TIPS_TYPE.BAG,
		callBack = function ()
			ContainerEquipWash.changQiangHuaEquip(itemPos)
		end,
		doubleCall = function ()
		
		end,
	}
	GUIItem.getItem(param)
	if item.tag == 1 then
		item:setName("item_upgrade")
	else
		item:setName("")
	end
end



--获取背包可以强化的装备
function ContainerEquipWash.getQiangHuaEquips()
	local maxNum = GameConst.ITEM_BAG_SIZE+GameSocket.mBagSlotAdd 
	local result = {}
	for i=0,maxNum-1 do
		local netItem = GameSocket:getNetItem(i)
		if netItem and GameBaseLogic.IsEquipment(netItem.mTypeID) then 
			table.insert(result, netItem.position)
		end
	end
	return result
end

function ContainerEquipWash.getRoleEquips()
	local result = {}
	for i=1,#roleEquipPos do
		local netItem = GameSocket:getNetItem(roleEquipPos[i].pos)
		if netItem and GameBaseLogic.IsEquipment(netItem.mTypeID) then 
				table.insert(result, netItem.position)
		end
	end
	return result
end

--左侧强化装备显示
function ContainerEquipWash.changQiangHuaEquip(pos)
	local netItem = GameSocket:getNetItem(pos)
	if not netItem then return end
	local itemdef = GameSocket:getItemDefByID(netItem.mTypeID)
	-- print(GameUtilSenior.encode(item_define))
	-- print(netItem.mLevel)
	if itemdef then 
		-- var.xmlPanel:getWidgetByName("labEquipName"):setString(itemdef.mName.." +"..netItem.mLevel)
		var.curEquipName=itemdef.mName
	end
	local param = {
		parent = var.xmlPanel:getWidgetByName("iconEquip"),
		pos = pos,
		-- iconType = GameConst.ICONTYPE.DEPOT,
		iconType = GameConst.ICONTYPE.BAG,
		tipsType = GameConst.TIPS_TYPE.BAG,
		callBack = function ()

		end,
	}
	GUIItem.getItem(param)
	if pos==-9999 then
		-- local param={parent=var.xmlPanel:getWidgetByName("iconClip"), typeId=nil}
		-- GUIItem.getItem(param)
		--var.xmlPanel:getWidgetByName("labNeedStone"):setString("0个"):setColor(cc.c3b(247,186,52))
	else
		GameSocket:PushLuaTable("gui.ContainerEquipWash.handlePanelData",GameUtilSenior.encode({actionid = "curWashEquip",params={pos=pos}}))
	end
	var.curWashPos = pos
end

--强化成功特效
function ContainerEquipWash.successAnimate(effectid)
	if not var.fireworks then
		var.fireworks = cc.Sprite:create():addTo(var.xmlPanel):pos(350, 360)
	end
	local animate = cc.AnimManager:getInstance():getPlistAnimate(4,effectid,4,4,false,false,0,function(animate,shouldDownload)
							if animate then
								var.fireworks:stopAllActions()
								var.fireworks:runAction(cca.seq({
									cca.rep(animate,1),
									cca.removeSelf(),
									cca.cb(function ()
										var.fireworks=nil
									end),
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

function ContainerEquipWash.updateDescList( list,strs )
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


function ContainerEquipWash.handlePanelData(event)
	if event.type == "ContainerEquipWash" then
		local data = GameUtilSenior.decode(event.data)
		if data.cmd =="getMessage" then
			ContainerEquipWash.updateDescList( var.xmlPanel:getWidgetByName("priceDesc"),data.priceDesc )
			ContainerEquipWash.updateDescList( var.xmlPanel:getWidgetByName("descList"),data.desc )
		end
		if data.cmd =="success" then
			ContainerEquipWash.successAnimate(60030)
		end
		if data.cmd =="fail" then
			ContainerEquipWash.successAnimate(60051)
		end
	end
end


function ContainerEquipWash.onPanelOpen(extend)
	GameSocket:PushLuaTable("gui.ContainerEquipWash.handlePanelData",GameUtilSenior.encode({actionid = "getMessage"}))
end

function ContainerEquipWash.onPanelClose()

end

return ContainerEquipWash