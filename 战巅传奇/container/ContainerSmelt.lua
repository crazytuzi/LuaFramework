local ContainerSmelt={}
local var = {}

local despQiangHua ={
	[1] = 	"<font color=#E7BA52 size=18>强化说明：</font>",
	[2] =	"<font color=#f1e8d0>1、强化需消耗金币和强化石</font>",
	[3] =	"<font color=#f1e8d0>2、强化失败不掉级，使用元宝可100%成功</font>",
	[4] =	"<font color=#f1e8d0>3、强化前10级概率提升，后10级以养成方式提升</font>",
}

local despJiCheng ={
	[1] = 	"<font color=#E7BA52 size=18>继承说明：</font>",
	[2] =	"<font color=#f1e8d0>1、目标装备强化等级必须为0，原始装备强化等级需大于0</font>",
	[3] =	"<font color=#f1e8d0>2、强化转移不能转移注灵属性</font>",
	[4] =	"<font color=#f1e8d0>3、转移消耗金币或元宝</font>",
}

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
	]]

}


	-- --玉佩
	-- ITEM_JADE_PENDANT_POSITION = (-11*2),
	-- --护盾
	-- ITEM_SHIELD_POSITION = (-12*2),
	-- --护心镜
	-- ITEM_MIRROR_ARMOUR_POSITION = (-13*2),
	-- --面巾
	-- ITEM_FACE_CLOTH_POSITION = (-14*2),
	-- --龙心
	-- ITEM_DRAGON_HEART_POSITION = (-15*2),
	-- --狼牙
	-- ITEM_WOLFANG_POSITION = (-16*2),
	-- --龙骨
	-- ITEM_DRAGON_BONE_POSITION = (-17*2),
	-- --虎符
	-- ITEM_CATILLA_POSITION = (-18*2),
	

function ContainerSmelt.initView()
	var = {
		xmlPanel,
		xmlQH=nil,
		xmlJC=nil,
		bagEquips,
		roleEquips,
		curEquips,
		openVcion=false,--元宝100%成功
		openStone=false,--强化石不够元宝代替
		curQhPos=-9999,--当前强化装备的pos
		curTab=nil,--记录当前选中的页签

		oldPos=nil,--继承原始装备pos
		oldTypeid=nil,
		newPos=nil,--继承装备pos
		newTypeid=nil,
		shopData=nil,
		tablistv,
		tablisth,
		curEquipName="",
		qhLevel=0,--当前放入的有强化等级装备的强化等级
		fireworks=nil,
		curEquipType=nil,--记录当前选中的是背包装备还是身上装备
	}
	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerSmelt.uif");
	if var.xmlPanel then
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, ContainerSmelt.handlePanelData)
			:addEventListener(GameMessageCode.EVENT_GAME_MONEY_CHANGE, ContainerSmelt.updateGameMoney)
		--ContainerSmelt.updateGameMoney()
		ContainerSmelt.initTabs()
		ContainerSmelt.initEquipList("roleEquips")
		-- GameUtilSenior.asyncload(var.xmlPanel, "panelBg", "ui/image/img_dz_bg.jpg")
		var.xmlPanel:getWidgetByName("imgBg"):setTouchEnabled(true)
				
	end
	ContainerSmelt.initShopInfo()
	return var.xmlPanel
end


function ContainerSmelt.initShopInfo()
	local function prsBtnClick( sender )
		local senderName = sender:getName()
		if senderName == "btnBuyMoney" then
			GameSocket:PushLuaTable("gui.ContainerSmelt.handlePanelData",GameUtilSenior.encode({actionid="reqBuyData",params={}}))
			--var.xmlPanel:getWidgetByName("fastBuyBox"):show()
		elseif senderName == "btnBuyMoneyHide" then
			var.xmlPanel:getWidgetByName("fastBuyBox"):hide()
		end
	end
	GUIFocusPoint.addUIPoint(var.xmlPanel:getWidgetByName("btnBuyMoney"),prsBtnClick)
	GUIFocusPoint.addUIPoint(var.xmlPanel:getWidgetByName("btnBuyMoneyHide"),prsBtnClick)
end
function ContainerSmelt.handlePanelData(event)
	if event.type ~= "ContainerSmelt" then return end
	local data = GameUtilSenior.decode(event.data)
	-- print(event.data)
	if data.cmd =="updateQiangHua" then
		ContainerSmelt.updateQiangHua(data.dataTable)
	elseif data.cmd=="updateTransfer" then
		ContainerSmelt.updateJiCheng(data.dataTable)
	elseif data.cmd=="successTransfer" then
		ContainerSmelt.setYuanEquip(nil)
		local fireworks = cc.Sprite:create():addTo(var.xmlPanel):pos(322, 320)
		local animate = cc.AnimManager:getInstance():getPlistAnimate(4,50021,4,4,false,false,0,function(animate,shouldDownload)
							-- print(animate:getAnimation():setDelayPerUnit(36/40))
							fireworks:runAction(cca.seq({
								cca.rep(animate, 1),
								cca.cb(function ()
									
								end),
								cca.removeSelf()
							}))
							if shouldDownload==true then
								fireworks:release()
							end
						end,
						function(animate)
							fireworks:retain()
						end)
						
	elseif data.cmd=="senderShopData" then	
		var.shopData={}
		var.shopData = data.data
		ContainerSmelt.initShop()
	elseif data.cmd=="qiangHuaSucceed" then
		ContainerSmelt.successAnimate(60050)
	elseif data.cmd=="qiangHuaFailed" then
		ContainerSmelt.successAnimate(60051)
	elseif data.cmd=="updateNewValue" then
		ContainerSmelt.updateTransfered(data)
	end
end

function ContainerSmelt.onPanelOpen()
	ContainerSmelt.getRoleEquips()
end

function ContainerSmelt.onPanelClose()
	
end

--金币刷新函数
--[[
function ContainerSmelt.updateGameMoney(event)
	if var.xmlPanel then
		local mainrole = GameSocket.mCharacter
		local moneyLabel = {
			{name="lblVcoin",	pre=GameConst.str_vcoin,	value =	mainrole.mVCoin or 0	,	icon = "icon_coin"},
			{name="lblBVcoin",	pre=GameConst.str_vcoinb,	value =	mainrole.mVCoinBind or 0,	icon = "icon_coin_bind"},
			{name="lblMoney",	pre=GameConst.str_money,	value =	mainrole.mGameMoney or 0,	icon = "icon_money"},
			{name="lblBMoney",	pre=GameConst.str_money,	value =	mainrole.mGameMoneyBind or 0,	icon = "icon_money"},
		}
		--建临时表遍历设属性
		for _,v in ipairs(moneyLabel) do
			local curNum = tonumber(var.xmlPanel:getWidgetByName(v.name):getString()) or 0
			var.xmlPanel:getWidgetByName(v.name):setString(v.value)
		end
	end
end
--]]

-----------------------------------------------------背包操作部分---------------------------------------------------
--技能根据操作显示背包和身上的装备（强化装备锁定后只显示未强化装备；为强化装备选定后只显示强化装备，二者都选中显示全部，二者都没没选显示已强化的）
function ContainerSmelt.initJcEquipList()
	var.oldPos=nil
	var.newPos=nil	
end

--初始化背包装备或身上装备
function ContainerSmelt.initEquipList(type)
	if type=="bagEquips" then
		var.curEquips=ContainerSmelt.getQiangHuaEquips()
		var.curEquipType="bagEquips"
	elseif type=="roleEquips" then
		var.curEquips=ContainerSmelt.getRoleEquips()
		var.curEquipType="roleEquips"
	end
	local equipList = var.xmlPanel:getWidgetByName("equipList")
	equipList:reloadData(76,ContainerSmelt.updateList):setSliderVisible(false)
end

--获取背包可以强化的装备
function ContainerSmelt.getQiangHuaEquips()
	local maxNum = GameConst.ITEM_BAG_SIZE+GameSocket.mBagSlotAdd 
	local result = {}
	local maxLev = 20
	if var.curTab==2 then maxLev=21 end
	for i=0,maxNum-1 do
		local netItem = GameSocket:getNetItem(i)
		if netItem and GameBaseLogic.IsEquipment(netItem.mTypeID) and netItem.mLevel<maxLev then 
			if var.curTab and var.curTab==2 then
				if not var.oldPos then
					if netItem.mLevel>0 then
						table.insert(result, netItem.position)
					end
				else
					-- if not var.newPos then
						if netItem.mLevel<=0 then
							table.insert(result, netItem.position)
						end
					-- else
						-- table.insert(result, netItem.position)
					-- end
				end
			else
				table.insert(result, netItem.position)
			end
		end
	end
	return result
end

function ContainerSmelt.getRoleEquips()
	local maxLev = 20
	if var.curTab==2 then maxLev=21 end
	local result = {}
	for i=1,#roleEquipPos do
		local netItem = GameSocket:getNetItem(roleEquipPos[i].pos)
		if netItem and netItem.mLevel<maxLev then 
			if var.curTab and var.curTab==2 then
				if not var.oldPos then
					if netItem.mLevel>0 then
						table.insert(result, netItem.position)
					end
				else
					-- if not var.newPos then
						if netItem.mLevel<=0 then
							table.insert(result, netItem.position)
						end
					-- else
						-- table.insert(result, netItem.position)
					-- end
				end
			else
				table.insert(result, netItem.position)
			end
		end
	end
	return result
end

function ContainerSmelt.updateList(item)
	local itemPos=var.curEquips[item.tag] or -9999
	local param = {
		parent = item,
		pos = itemPos,
		iconType = GameConst.ICONTYPE.DEPOT,
		-- tipsType = GameConst.TIPS_TYPE.BAG,
		callBack = function ()
			if var.curTab==1 then
				ContainerSmelt.changQiangHuaEquip(itemPos)
			elseif var.curTab==2 then
				ContainerSmelt.setYuanEquip(itemPos)
			end
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

-------------------------------------------------------强化部分-----------------------------------------------------
--左侧强化装备显示
function ContainerSmelt.changQiangHuaEquip(pos)
	local netItem = GameSocket:getNetItem(pos)
	if not netItem then return end
	local itemdef = GameSocket:getItemDefByID(netItem.mTypeID)
	-- print(GameUtilSenior.encode(item_define))
	-- print(netItem.mLevel)
	if itemdef then 
		-- var.xmlQH:getWidgetByName("labEquipName"):setString(itemdef.mName.." +"..netItem.mLevel)
		var.curEquipName=itemdef.mName
	end
	local param = {
		parent = var.xmlQH:getWidgetByName("iconEquip"),
		pos = pos,
		-- iconType = GameConst.ICONTYPE.DEPOT,
		iconType = GameConst.ICONTYPE.BAG,
		tipsType = GameConst.TIPS_TYPE.BAG,
		callBack = function ()

		end,
	}
	GUIItem.getItem(param)
	if pos==-9999 then
		-- local param={parent=var.xmlQH:getWidgetByName("iconClip"), typeId=nil}
		-- GUIItem.getItem(param)
		var.xmlQH:getWidgetByName("labNeedStone"):setString("0个"):setColor(cc.c3b(247,186,52))
	else
		GameSocket:PushLuaTable("gui.ContainerSmelt.handlePanelData",GameUtilSenior.encode({actionid = "curQiangHuaEquip",params={pos=pos}}))
	end
	var.curQhPos = pos
end

--强化成功特效
function ContainerSmelt.successAnimate(effectid)
	if not var.fireworks then
		var.fireworks = cc.Sprite:create():addTo(var.xmlQH):pos(322, 320)
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

--强化数据刷新
function ContainerSmelt.updateQiangHua(data)
	-- ContainerSmelt.successAnimate()
	if not data or not var.xmlQH then return end
	local imgIcon1 = var.xmlQH:getWidgetByName("icon1"):setOpacity(0):setVisible(true)
	local param={parent=imgIcon1, typeId=data.chipTypeId, num=1,}
	GUIItem.getItem(param)
	imgIcon1:getWidgetByName("item_icon"):setVisible(false)
	local imgIcon2 = var.xmlQH:getWidgetByName("icon2"):setOpacity(0):setVisible(true)
	local param={parent=imgIcon2, typeId=40000003, num=1,}
	GUIItem.getItem(param)
	imgIcon2:getWidgetByName("item_icon"):setVisible(false)
	if data.ownNum>=data.chipNum then
		var.xmlQH:getWidgetByName("labNeedStone"):setString(data.ownNum.."/"..data.chipNum):setColor(cc.c3b(247,186,52))
	else
		var.xmlQH:getWidgetByName("labNeedStone"):setString(data.ownNum.."/"..data.chipNum):setColor(cc.c3b(255,0,0))
	end
	local curMoney = GameSocket.mCharacter.mGameMoney + GameSocket.mCharacter.mGameMoneyBind
	--var.xmlQH:getWidgetByName("labNeedStone"):setString(data.winPro.."%"):setColor(cc.c3b(247,186,52))
	if curMoney>=data.needMoney then
		var.xmlQH:getWidgetByName("labNeedMoney"):setString(data.needMoney):setColor(cc.c3b(247,186,52))
	else
		var.xmlQH:getWidgetByName("labNeedMoney"):setString(data.needMoney):setColor(cc.c3b(255,0,0))
	end
	--var.xmlQH:getWidgetByName("oneKeyDesp"):setString("使用"..data.needVcion.."元宝100%成功率")
	-- var.xmlQH:getWidgetByName("labEquipName"):setString(var.curEquipName.." +"..data.level)

	--var.xmlQH:getWidgetByName("labOwnStone"):setString("背包拥有 "..data.ownNum.."个")

	for i=1,10 do
		local maxStar = data.level%10
		if data.level==10 or data.level==20 then
			maxStar=10
		end
		if i<=maxStar then
			if data.level<=10 then
				var.xmlQH:getWidgetByName("star"..i):loadTexture("ContainerSmelt_star_light.png", ccui.TextureResType.plistType)
			else
				var.xmlQH:getWidgetByName("star"..i):loadTexture("img_yang_light", ccui.TextureResType.plistType)
			end
		else
			if data.level<=10 then
				var.xmlQH:getWidgetByName("star"..i):loadTexture("ContainerSmelt_star_grey.png", ccui.TextureResType.plistType)
			else
				var.xmlQH:getWidgetByName("star"..i):loadTexture("img_yang_gray", ccui.TextureResType.plistType)
			end
		end
	end
	local resName = "stone_1"
	if (data.level+1)>15 then
		resName = "stone_4"
	elseif (data.level+1)>10 then
		resName = "stone_3"
	elseif (data.level+1)>5 then
		resName = "stone_2"
	end
	var.xmlQH:getWidgetByName("imgStone"):loadTexture(resName, ccui.TextureResType.plistType)

	if data.level>=10 then
		--var.xmlQH:getWidgetByName("btnOneKey"):setVisible(false)
		--var.xmlQH:getWidgetByName("oneKeyDesp"):setVisible(false)
	else
		--var.xmlQH:getWidgetByName("btnOneKey"):setVisible(true)
		--var.xmlQH:getWidgetByName("oneKeyDesp"):setVisible(true)
	end

	for j=1,3 do
		if data.curValues and data.curValues[j] then
			var.xmlQH:getWidgetByName("labCurValue"..j):setString(data.curValues[j]):setVisible(true)
		else
			var.xmlQH:getWidgetByName("labCurValue"..j):setString(""):setVisible(false)
		end
		if data.nextValues and data.nextValues[j] then
			var.xmlQH:getWidgetByName("labNextValue"..j):setString(data.nextValues[j]):setVisible(true)
		else
			var.xmlQH:getWidgetByName("labNextValue"..j):setString(""):setVisible(false)
		end
	end
	var.xmlQH:getWidgetByName("btnQh"):setVisible(true)
	--local bar = var.xmlQH:getWidgetByName("bar")
	--if data.level>=10 then
	if data.level>=10000000 then
		--bar:setFormat2String("")
		--bar:setFormatString(data.yangLev*data.chipNum.."/"..data.maxUp)
		--bar:setPercent(data.yangLev*data.chipNum,data.maxUp)
		if data.level>=20 then--满级显示
			--bar:setFormatString("")
			--bar:setFormat2String("Max")
			--bar:setPercent(100,100)
			var.xmlQH:getWidgetByName("labNeedStone"):setString("0个"):setColor(cc.c3b(247,186,52))
			--var.xmlQH:getWidgetByName("labNeedStone"):setString("100%"):setColor(cc.c3b(247,186,52))
			var.xmlQH:getWidgetByName("labNeedMoney"):setString(0):setColor(cc.c3b(247,186,52))
			var.xmlQH:getWidgetByName("btnQh"):setVisible(false)
		end
	else
		--bar:setFormatString("")
		--bar:setFormat2String("成功率:%d%%")
		--bar:setPercent(data.winPro*100,100)
	end
	--bar:setFontSize(15):enableOutline(GameBaseLogic.getColor(0x000049),1)
	--bar:setTextColor(GameBaseLogic.getColor(0x30ff00))

	-- bar:resetLabelFormat( "成功率：%d/%d" )
end

--切换页签时清空强化面板数据
function ContainerSmelt.clearQiangHuaData()
	var.curQhPos = -9999
	var.openVcion=false
	var.openStone=false
	var.xmlQH:removeFromParent()
	var.xmlQH=nil
end

--强化按钮操作
local checkBtns = {"btnOneKey","btnAutoVcion","btnQhDesp","btnQh"}
function ContainerSmelt.initCheckBtn()
	local function prsBtnClick(sender)
		local senderName = sender:getName()
		if senderName=="btnOneKey" then
			if var.openVcion then
				var.openVcion=false
				sender:setBrightStyle(0)
			else
				var.openVcion=true
				sender:setBrightStyle(1)
			end
		elseif senderName=="btnAutoVcion" then
			if var.openStone then
				var.openStone=false
				sender:setBrightStyle(0)
			else
				var.openStone=true
				sender:setBrightStyle(1)
			end
		elseif senderName=="btnQhDesp" then

		elseif senderName=="btnQh" then
			if var.curQhPos~=-9999 then
				GameSocket:PushLuaTable("gui.ContainerSmelt.handlePanelData",GameUtilSenior.encode({actionid="startQiangHua",params={pos=var.curQhPos,flag1=var.openVcion,flag2=var.openStone}}))
			else
				GameSocket:alertLocalMsg("请先放入需要强化的装备", "alert")
			end
		-- elseif senderName=="btnBuyMoney" then
		-- 	local buyList =  var.xmlPanel:getWidgetByName("fastBuyBox")
		-- 	-- local imgBg = var.xmlPanel:getWidgetByName("imgBg")
		-- 	if buyList:isVisible() then
		-- 		buyList:hide()
		-- 		-- imgBg:hide()
		-- 	else
		-- 		buyList:show()
		-- 		-- imgBg:show()
		-- 		GameSocket:PushLuaTable("gui.ContainerSmelt.handlePanelData",GameUtilSenior.encode({actionid="reqBuyData",params={}}))
		-- 	end
		end
	end
	for i=1,#checkBtns do
		local btn = var.xmlQH:getWidgetByName(checkBtns[i])
		GUIFocusPoint.addUIPoint(btn,prsBtnClick)
	end
end

function ContainerSmelt.initShop()
	local listShop = var.xmlPanel:getWidgetByName("listShop")
	listShop:reloadData(#var.shopData,ContainerSmelt.updateShop):setSliderVisible(false)
end

function ContainerSmelt.updateShop(item)
	local itemData = var.shopData[item.tag]
	item:getWidgetByName("labName"):setString(itemData.name)
	item:getWidgetByName("labPrice"):setString(itemData.vcion)
	local awardItem=item:getWidgetByName("icon")
	local param={parent=awardItem , typeId=itemData.id}
	GUIItem.getItem(param)

	local function prsBtnItem(sender)
		GameSocket:PushLuaTable("gui.ContainerSmelt.handlePanelData",GameUtilSenior.encode({actionid = "shopBuy",params={index=sender.index}}))
	end 
	local btnBuy = item:getWidgetByName("btnBuy")
	btnBuy.index=item.tag
	GUIFocusPoint.addUIPoint(btnBuy , prsBtnItem)
end

-----------------------------------------------------继承部分---------------------------------------------------
--设置原始装备
function ContainerSmelt.setYuanEquip(pos)
	local netItem = GameSocket:getNetItem(pos)
	if netItem then
		if netItem.mLevel>0 then
			-- local param = {
			-- 	parent   = var.xmlJC:getWidgetByName("iconEquip"),
			-- 	pos      = pos,
			-- 	iconType = GameConst.ICONTYPE.BAG,
			-- 	tipsType = GameConst.TIPS_TYPE.BAG,
			-- 	callBack = function ()

			-- 	end,
			-- }
			-- GUIItem.getItem(param)

			local param = {
				parent = var.xmlJC:getWidgetByName("iconEquip"),
				pos      = pos,
				tipsType = GameConst.TIPS_TYPE.UPGRADE,
				enmuPos = 6,
				customCallFunc = function()
					ContainerSmelt.setYuanEquip(nil)
					ContainerSmelt.initEquipList(var.curEquipType)
				end,
				-- showBetter = true,
			}
			GUIItem.getItem(param)

			var.oldPos=pos
			var.oldTypeid=netItem.mTypeID
			var.qhLevel=netItem.mLevel
			GameSocket:PushLuaTable("gui.ContainerSmelt.handlePanelData",GameUtilSenior.encode({actionid = "curJiChengEquip",params={pos=pos}}))
			if var.newPos then
				GameSocket:PushLuaTable("gui.ContainerSmelt.handlePanelData",GameUtilSenior.encode({actionid = "reqNewLevelShow",params={pos=var.newPos,level=var.qhLevel}}))
			end
		else
			-- GameSocket:alertLocalMsg("强化等级大于0方可放入原始装备槽", "alert")
			local param = {
				parent = var.xmlJC:getWidgetByName("targetEquip"),
				pos = pos,
				iconType = GameConst.ICONTYPE.BAG,
				tipsType = GameConst.TIPS_TYPE.BAG,
				callBack = function ()

				end,
			}
			GUIItem.getItem(param)
			var.newPos=pos
			var.newTypeid=netItem.mTypeID
			GameSocket:PushLuaTable("gui.ContainerSmelt.handlePanelData",GameUtilSenior.encode({actionid = "reqNewLevelShow",params={pos=pos,level=var.qhLevel}}))
		end
		ContainerSmelt.initEquipList(var.curEquipType)
	end
	if not pos then
		local param={parent=var.xmlJC:getWidgetByName("iconEquip"), typeId=nil}
		GUIItem.getItem(param)
		local param={parent=var.xmlJC:getWidgetByName("targetEquip"), typeId=nil}
		GUIItem.getItem(param)
		var.oldPos=nil
		var.oldTypeid=nil
		var.newPos=nil
		var.newTypeid=nil
		var.xmlJC:getWidgetByName("labNeedMoney"):setString(0):setColor(cc.c3b(247,186,52))
		ContainerSmelt.clearLabel()
	end
end

--刷新被继承者即将获得的强化属性
function ContainerSmelt.updateTransfered(data)
	for j=1,3 do
		if data.newTable and data.newTable[j] then
			var.xmlJC:getWidgetByName("labNextValue"..j):setString(data.newTable[j]):setVisible(true)
		else
			var.xmlJC:getWidgetByName("labNextValue"..j):setString(""):setVisible(false)
		end
	end
end

--转移成功清理文本属性
function ContainerSmelt.clearLabel()
	for j=1,3 do
		var.xmlJC:getWidgetByName("labNextValue"..j):setString("")
		var.xmlJC:getWidgetByName("labCurValue"..j):setString("")
	end
end

function ContainerSmelt.updateJiCheng(data)
	if not var.xmlJC then return end
	local curMoney = GameSocket.mCharacter.mGameMoney + GameSocket.mCharacter.mGameMoneyBind
	if data.needMoney>0 and curMoney>=data.needMoney then
		var.xmlJC:getWidgetByName("labNeedMoney"):setString(data.needMoney):setColor(cc.c3b(247,186,52))
	else
		var.xmlJC:getWidgetByName("labNeedMoney"):setString(data.needMoney):setColor(cc.c3b(255,0,0))
	end
	if data.needVcion>0 then
		var.xmlJC:getWidgetByName("Image_23"):loadTexture("vcoin", ccui.TextureResType.plistType)
		var.xmlJC:getWidgetByName("Text_9"):setString("消耗钻石"):setVisible(true)
		if data.vcion>=data.needVcion then
			var.xmlJC:getWidgetByName("labNeedMoney"):setString(data.needVcion):setColor(cc.c3b(247,186,52))
		else
			var.xmlJC:getWidgetByName("labNeedMoney"):setString(data.needVcion):setColor(cc.c3b(255,0,0))
		end
	elseif data.needBindVcion>0 then
		var.xmlJC:getWidgetByName("Image_23"):loadTexture("vcoin", ccui.TextureResType.plistType)
		var.xmlJC:getWidgetByName("Text_9"):setString("消耗邦定钻石"):setVisible(true)
		if data.bindvcion>=data.needBindVcion then
			var.xmlJC:getWidgetByName("labNeedMoney"):setString(data.needBindVcion):setColor(cc.c3b(247,186,52))
		else
			var.xmlJC:getWidgetByName("labNeedMoney"):setString(data.needBindVcion):setColor(cc.c3b(255,0,0))
		end
	else
		var.xmlJC:getWidgetByName("Image_23"):loadTexture("coin", ccui.TextureResType.plistType)
		var.xmlJC:getWidgetByName("Text_9"):setString("消耗元宝"):setVisible(true)
	end
	for j=1,3 do
		if data.oldValues and data.oldValues[j] then
			var.xmlJC:getWidgetByName("labCurValue"..j):setString(data.oldValues[j]):setVisible(true)
		else
			var.xmlJC:getWidgetByName("labCurValue"..j):setString(""):setVisible(false)
		end
	end
end

--Tip取出操作回调
function ContainerSmelt.quChuOperate()
	var.oldPos=nil
	var.newPos=nil
	
end

--切换页签清理继承慢板数据
function ContainerSmelt.clearJiChengData()
	var.oldPos=nil
	var.newPos=nil
	if var.xmlJC then
		var.xmlJC:removeFromParent()
		var.xmlJC=nil
	end
end

--继承按钮操作
local jcBtns = {"btnJC","btnJZDesp"}
function ContainerSmelt.initJiChengBtn()
	local function prsBtnClick(sender)
		local senderName = sender:getName()
		-- print(senderName)
		if senderName=="btnJC" then
			ContainerSmelt.startJiCheng()
		elseif senderName=="btnJZDesp" then

		end
	end
	for i=1,#jcBtns do
		local btn = var.xmlJC:getWidgetByName(jcBtns[i])
		GUIFocusPoint.addUIPoint(btn,prsBtnClick)
	end
end

--继承操作
function ContainerSmelt.startJiCheng()
	local result = {}
	result.oldPos=var.oldPos
	result.oldTypeid=var.oldTypeid
	result.newPos=var.newPos
	result.newTypeid=var.newTypeid
	if not var.oldPos then
		GameSocket:alertLocalMsg("请放入原始装备", "alert")
		return
	end
	if not var.newPos then
		GameSocket:alertLocalMsg("请放入新装备", "alert")
		return
	end
	GameSocket:PushLuaTable("gui.ContainerSmelt.handlePanelData",GameUtilSenior.encode({actionid = "startJiCheng",params=result}))
end

----------------------------------------页签操作-----------------------------------------------
local btnArrs = {"tabQH","tabJC","btnSH","btnBag"}
function ContainerSmelt.initTabs()
	local function pressTabV(sender)
		local tag = sender:getTag()
		if tag==1 then
			ContainerSmelt.initXmlContent("qianghua")
			var.curTab=1
			ContainerSmelt.clearJiChengData()
		elseif tag==2 then
			ContainerSmelt.initXmlContent("jicheng")
			var.curTab=2
			ContainerSmelt.clearQiangHuaData()
		end
		ContainerSmelt.initEquipList(var.curEquipType)
	end
	local function pressTabH(sender)
		local tag = sender:getTag()
		if tag==1 then
			ContainerSmelt.initEquipList("roleEquips")
		elseif tag==2 then
			ContainerSmelt.initEquipList("bagEquips")
		end
	end
	var.tablistv = var.xmlPanel:getWidgetByName("tablistv")
	var.tablistv:addTabEventListener(pressTabV)
	var.tablistv:setSelectedTab(1)
	var.tablisth = var.xmlPanel:getWidgetByName("tablisth")
	var.tablisth:addTabEventListener(pressTabH)
	var.tablisth:setSelectedTab(1)
	var.tablisth:setItemMargin(30)
	var.tablisth:setTabColor(GameBaseLogic.getColor(0xdce910),GameBaseLogic.getColor(0xf1e8d0))
	var.tablisth:setTabRes("ContainerSmelt_btn_switch.png","ContainerSmelt_btn_switch_sel.png")
end

--初始化页签模块
function ContainerSmelt.initXmlContent(type)
	local contentRight = var.xmlPanel:getWidgetByName("contentRight")
	contentRight:setVisible(var.tablistv:getCurIndex()<3)
	if var.xmlQH then var.xmlQH:hide() end
	if var.xmlJC then var.xmlJC:hide() end
	if var.xmlHC then var.xmlHC:hide() end
	if var.xmlSZ then var.xmlSZ:hide() end
	if type=="qianghua" then
		if not var.xmlQH then
			var.xmlQH = GUIAnalysis.load("ui/layout/ContainerSmelt_qiangHua.uif")
			if var.xmlQH then
				var.xmlQH:addTo(var.xmlPanel:getWidgetByName("tabContent")):align(display.LEFT_BOTTOM, 0, 0):show()
			end
			ContainerSmelt.initCheckBtn()
			-- ContainerSmelt.changQiangHuaEquip(-2)--打开强化默认放武器
			--GameUtilSenior.asyncload(var.xmlQH, "img_dz_qh_bg", "ui/image/qh_bg.jpg")
			--var.xmlQH:getWidgetByName("bar"):setFontSize(15):enableOutline(GameBaseLogic.getColor(0x000049),1)
		else
			var.xmlQH:show()
		end
		var.xmlQH:getWidgetByName("btnQhDesp"):setTouchEnabled(true)
		ContainerSmelt.initDesp(var.xmlQH,"btnQhDesp",despQiangHua)
	elseif type=="jicheng" then
		if not var.xmlJC then
			var.xmlJC = GUIAnalysis.load("ui/layout/ContainerSmelt_JiCheng.uif")
			if var.xmlJC then
				var.xmlJC:addTo(var.xmlPanel:getWidgetByName("tabContent")):align(display.LEFT_BOTTOM, 0, 0):show()
			end
			ContainerSmelt.initJiChengBtn()
			-- GameUtilSenior.asyncload(var.xmlPanel, "img_jc_bg", "ui/image/img_jc_bg.jpg")
		else
			var.xmlJC:show()
		end
		var.xmlJC:getWidgetByName("btnJZDesp"):setTouchEnabled(true)
		ContainerSmelt.initDesp(var.xmlJC,"btnJZDesp",despJiCheng)
		if var.xmlPanel:getWidgetByName("fastBuyBox") then
			var.xmlPanel:getWidgetByName("fastBuyBox"):hide()
		end
	end
end

function ContainerSmelt.initDesp(xmlPanel,btnName,despTable)
	local btnDesp=xmlPanel:getWidgetByName(btnName)
	btnDesp:addTouchEventListener(function (pSender, touchType)
		if touchType == ccui.TouchEventType.began then
			ContainerSmelt.duanZaoDesp(despTable)
		elseif touchType == ccui.TouchEventType.ended or touchType == ccui.TouchEventType.canceled then	
			GDivDialog.handleAlertClose()
		end
	end)
end

function ContainerSmelt.duanZaoDesp(despTable)
	local mParam = {
	name = GameMessageCode.EVENT_PANEL_ON_ALERT,
	panel = "tips", 
	infoTable = despTable,
	visible = true, 
	}
	GameSocket:dispatchEvent(mParam)

end

return ContainerSmelt