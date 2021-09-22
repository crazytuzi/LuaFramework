local ContainerCharacter = {}
local var = {}
local pageKeys = {
	--"role","fashion", "title", "innerPower", "reborn", "gem",
	"role","fashion", "title", "gem","hunhuan", "reborn",
}

local equip_info = {
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
	
	
	{pos = GameConst.ITEM_ACHIEVE_MEDAL_POSITION,			},  --44
	--时装
	{pos = GameConst.ITEM_FASHION_WEAPON_POSITION,	etype = 31},
	{pos = GameConst.ITEM_FASHION_CLOTH_POSITION,	etype = 32},
	{pos = GameConst.ITEM_FASHION_WING_POSITION,	etype = 33},
	{pos = GameConst.ITEM_FASHION_WING_SHOUSHI1,	etype = 34},
	{pos = GameConst.ITEM_FASHION_WING_SHOUSHI2,	etype = 35},
	{pos = GameConst.ITEM_FASHION_WING_SHOUSHI3,	etype = 36},
	{pos = GameConst.ITEM_FASHION_WING_SHOUSHI4,	etype = 37},
	{pos = GameConst.ITEM_FASHION_WING_SHOUSHI5,	etype = 38},
	{pos = GameConst.ITEM_FASHION_WING_SHOUSHI6,	etype = 39},
}
local fashionPos = {
	GameConst.ITEM_FASHION_WEAPON_POSITION,
	GameConst.ITEM_FASHION_CLOTH_POSITION,
	GameConst.ITEM_FASHION_WING_POSITION,
}
local attrData = {
	{str = "物理攻击：",x1 = "mDC",x2 = "mDCMax"},
	{str = "魔法攻击：",x1 = "mMC",x2 = "mMCMax"},
	{str = "道术攻击：",x1 = "mSC",x2 = "mSCMax"},
	{str = "物理防御：",x1 = "mAC",x2 = "mACMax"},
	{str = "魔法防御：",x1 = "mMAC",x2 = "mMACMax"},
}
local lblhint = {
	"<font color=#E7BA52 size=18>时装说明</font>",
	'1.	穿戴时装即可获得该时装属性。',
	'2.	限时类同款套装多次使用，剩余时间叠加。',
	'3.	选中时装可预览时装形象，佩戴后可改变场景中角色形象。',
}
local chlblhint = {
	"<font color=#E7BA52 size=18>称号说明</font>",
	'1.	穿戴称号即可获得该称号属性。',
	'2.	一次仅可穿戴一个称号。',
	'3.	选中称号可预览称号形象，佩戴后可改变场景中角色形象。',
}
local function hideAllPages()
	local pageName
	for i,v in ipairs(pageKeys) do
		pageName = "xmlPage"..string.ucfirst(v)
		if var[pageName] then
			var[pageName]:hide()
		end
	end
end
 -- page变量，初始化函数，刷新函数使用字符窜拼接
local function showPanelPage(index)
	if index==5 then
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "container_reborn"})
		return
	end
	if index==6 then
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "container_my_hunhuan"})
		return
	end
	if index==7 then
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "container_my_zuji"})
		return
	end
	if index==8 then
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "main_skill"})
		return
	end
	local key = pageKeys[index]
	if not (key and table.indexof(pageKeys, key))then return end
	var.lastTabIndex = index
	hideAllPages()
	local pageName = "xmlPage"..string.ucfirst(key)
	local initFunc = "initPage"..string.ucfirst(key)
	local openFunc = "openPage"..string.ucfirst(key)
	if not var[pageName] and ContainerCharacter[initFunc] then
		ContainerCharacter[initFunc]()
	end
	if var[pageName] then
		if ContainerCharacter[openFunc] then
			ContainerCharacter[openFunc]()
		end
		var[pageName]:show()
	end
end

function ContainerCharacter.pushTabButtons(sender)
	local opened, level, funcName
	opened = true
	local tag = sender:getTag()
	if pageKeys[tag] == "reborn" then
		opened, level, funcName = GameSocket:checkFuncOpenedByID(10014)
	elseif pageKeys[tag] == "gem" then
		opened, level, funcName = GameSocket:checkFuncOpenedByID(10015)
	end

	if not opened and funcName~="离线挂机" then
		print("zzzzzzzzzzzzzz=================",funcName)
		var.boxTab:setTabSelected(var.lastTabIndex)
		GameSocket:alertLocalMsg(funcName.."功能暂未开放，"..level.."级开放")
		return
	end

	showPanelPage(sender:getTag())
end

---------------------------------------以上为内部函数---------------------------------------
function ContainerCharacter.initView(extend)
	var = {
		boxTab,
		xmlPanel,
		xmlPageGem,
		xmlPageRole,
		xmlPageReborn,
		xmlPageFashion,
		xmlPageInnerPower,

		powerNum,
		powerFashionNum,
		curClothId,
		curWeaponId,

		barHp,
		barMp,
		barPower,

		shopData = {},
		zsLevel,

		fightNum,
		imgEquipSelected,
		curEquipIndex,

		mSelectedEquip,

		mShowMainEquips,
		mShowSXEquips,
		fashion_data={},
		fashion_preview={},
		fashion_list_cells={},
		curFashionListIndex=1,
	}
	
	--加载称号素材
	asyncload_frames("ui/sprite/ContainerTitle",".png")

	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerCharacter.uif")

	if var.xmlPanel then
		var.xmlPanel:getWidgetByName("panel_close"):setLocalZOrder(10)
		var.boxTab = var.xmlPanel:getWidgetByName("box_tab")
		var.boxTab:getParent():setLocalZOrder(10)
		var.boxTab:setItemMargin(3)
		var.boxTab:addTabEventListener(ContainerCharacter.pushTabButtons)
		-- var.boxTab:setSelectedTab(1)
		local hideIndex = {2,4,6,7}
		local opened = GameSocket:checkFuncOpenedByID(10015)
		if not opened then
			table.insert(hideIndex,table.keyof(pageKeys,"gem"))
		end
		local openedReborn = GameSocket:checkFuncOpenedByID(10014)
		if not openedReborn then
			table.insert(hideIndex,table.keyof(pageKeys,"reborn"))
		end
		--暂时不显示时装
		--table.insert(hideIndex,table.keyof(pageKeys,"fashion"))
		var.boxTab:hideTab(hideIndex)
		return var.xmlPanel
	end
end

function ContainerCharacter.onPanelOpen(extend)
	var.panelExtend = extend

	if extend and extend.mParam and extend.mParam.tab then
		 return var.boxTab:setSelectedTab(extend.mParam.tab)
	end

	if extend and extend.tab and GameUtilSenior.isNumber(extend.tab) then
		var.boxTab:setSelectedTab(extend.tab)
	elseif extend and extend.index and GameUtilSenior.isNumber(extend.index) then
		var.boxTab:setSelectedTab(extend.index)
	else
		var.boxTab:setSelectedTab(1)
	end
end

function ContainerCharacter.onPanelClose()

end


--金币刷新函数
function ContainerCharacter:updateGameMoney(panel)
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


--------------------------------------角色--------------------------------------
function ContainerCharacter.initPageRole()
	--刷新战力
	local function updateFightPoint()
		var.powerNum:setString(GameSocket.mCharacter.mFightPoint)
	end

	local function updateInnerLooks()
		-- if not var.panelShow then return end

		local img_role = var.xmlPageRole:getChildByName("img_role")
		local img_wing = var.xmlPageRole:getChildByName("img_wing")
		local img_weapon = var.xmlPageRole:getChildByName("img_weapon")

		--设置翅膀内观
		if not img_wing then
			img_wing = cc.Sprite:create()
			img_wing:addTo(var.xmlPageRole):align(display.CENTER, 386, 370):setName("img_wing")
		end
		-- local weaponDef = GameSocket:getItemDefByPos(GameConst.ITEM_WEAPON_POSITION)
		local wing = GameCharacter._mainAvatar:NetAttr(GameConst.net_wing)
		if wing then
			--if wing~=var.curwingId then
				img_wing:removeChildByName("spriteEffect")
				GameUtilSenior.addEffect(img_wing,"spriteEffect",GROUP_TYPE.WING_REVIEW,wing,{x=0,y=-100},false,true)
				--var.curwingId=wing
			---end
		else
			img_wing:setTexture(nil)
			img_wing:setVisible(false)
			var.curwingId=nil
		end
		--设置衣服内观
		if not img_role then
			img_role = cc.Sprite:create()
			img_role:addTo(var.xmlPageRole):align(display.CENTER, 270, 270):setName("img_role")
		end
		local clothDef,clothId
		local isFashion = false

		local fashion = GameCharacter._mainAvatar:NetAttr(GameConst.net_fashion)
		local cloth = GameCharacter._mainAvatar:NetAttr(GameConst.net_cloth)
		if fashion >0 then
			clothId = fashion
			isFashion = true
		else
			clothDef = GameSocket:getItemDefByPos(GameConst.ITEM_CLOTH_POSITION)
			--print(GameUtilSenior.encode(clothDef))
			if clothDef then
				clothId = clothDef.mResMale
			else 
				clothId = cloth
			end
		end
		if not clothId then
			local gender = GameCharacter._mainAvatar:NetAttr(GameConst.net_gender)
			local luoti= gender==200 and  20000 or 20000
			clothId = luoti
		end
		if clothId~=img_role.curClothId then
			img_role:removeChildByName("spriteEffect")
			if isFashion then
				GameUtilSenior.addEffect(img_role,"spriteEffect",GROUP_TYPE.FDRESS_REVIEW,clothId,{x=-122,y=330},false,true)
			else
				GameUtilSenior.addEffect(img_role,"spriteEffect",GROUP_TYPE.CLOTH_REVIEW,clothId,{x=-122,y=330},false,true)
			end
		end

	    --设置武器内观
		if not img_weapon then
			img_weapon = cc.Sprite:create()
			img_weapon:addTo(var.xmlPageRole):setAnchorPoint(cc.p(0.52,0.3)):setPosition(296, 370):setName("img_weapon")
		end
		local weapon = GameCharacter._mainAvatar:NetAttr(GameConst.net_weapon)
		local weaponDef = GameSocket:getItemDefByPos(GameConst.ITEM_WEAPON_POSITION)
		if not isFashion and (weaponDef or weapon>0) then
			local res = weapon
			if weaponDef then
				res = weaponDef.mResMale
			end
			--if weaponDef.mResMale~=var.curWeaponId then
				img_weapon:removeChildByName("spriteEffect")
				GameUtilSenior.addEffect(img_weapon,"spriteEffect",GROUP_TYPE.WEAPON_REVIEW,res,{x=-150,y=241},false,true)
				
				--var.curWeaponId=weaponDef.mResMale
			--end
		else
			img_weapon:stopAllActions()
			img_weapon:setTexture(nil)
			img_weapon:setVisible(false)
			var.curWeaponId=nil
		end
	end
	---刷新属性条
	local function updateHpMp(event)
		local hp = 		GameCharacter._mainAvatar:NetAttr(GameConst.net_hp) or 0
		local maxhp = 	GameCharacter._mainAvatar:NetAttr(GameConst.net_maxhp) or 0
		local mp =		GameCharacter._mainAvatar:NetAttr(GameConst.net_mp) or 0
		local maxmp = 	GameCharacter._mainAvatar:NetAttr(GameConst.net_maxmp) or 0

		if event then
			var.barHp:setPercentWithAnimation(hp, maxhp)
			var.barMp:setPercentWithAnimation(mp, maxmp)
		else
			local power =      GameCharacter._mainAvatar:NetAttr(GameConst.net_power) or 0
			local maxpower =   GameCharacter._mainAvatar:NetAttr(GameConst.net_maxpower) or 0
			var.barHp:setPercent(hp, maxhp):setFontSize( 12 ):enableOutline(GameBaseLogic.getColor(0x000000),1)
			var.barMp:setPercent(mp, maxmp):setFontSize( 12 ):enableOutline(GameBaseLogic.getColor(0x000000),1)
			--var.barPower:setPercent(GameSocket.mCharacter.mCurExperience,GameSocket.mCharacter.mCurrentLevelMaxExp):setFontSize( 12 ):enableOutline(GameBaseLogic.getColor(0x000000),1)
		end
	end

	--刷新右侧属性
	local function updateAvatarAttr()
	
		--
		ContainerCharacter:updateGameMoney(var.xmlPageRole)
		--

		local hp = 		GameCharacter._mainAvatar:NetAttr(GameConst.net_hp) or 0
		local maxhp = 	GameCharacter._mainAvatar:NetAttr(GameConst.net_maxhp) or 0
		local mp =		GameCharacter._mainAvatar:NetAttr(GameConst.net_mp) or 0
		local maxmp = 	GameCharacter._mainAvatar:NetAttr(GameConst.net_maxmp) or 0
		
		local guild_name = GameCharacter._mainAvatar:NetAttr(GameConst.net_guild_name)
		if not guild_name or guild_name == "" then
			guild_name = "暂无行会"
		end
		local lbl_attrs = {
			{key="level_value",    name="等级：", value = ""..GameSocket.mCharacter.mLevel},
			--{key="lbl_zhiye_prob",    name="职业：", value = ""},
			{key="lbl_guild_name", name="行会：", value = ""..guild_name},
			--{key="lbl_hp",    name="生命：", value = ""..hp.."-"..maxhp},
			--{key="lbl_mp",    name="魔法：", value = ""..mp.."-"..maxmp},
			{key="lbl_luck",    name="幸运：", value = ""..GameSocket.mCharacter.mLuck},
			{key="lbl_dc", name="物攻：", value = ""..GameSocket.mCharacter.mDC.."-"..GameSocket.mCharacter.mMaxDC},
			--{key="lbl_mc", name="魔攻：", value = ""..GameSocket.mCharacter.mMC.."-"..GameSocket.mCharacter.mMaxMC},
			--{key="lbl_sc", name="道功：", value = ""..GameSocket.mCharacter.mSC.."-"..GameSocket.mCharacter.mMaxSC},
			{key="lbl_ac", name="物防：", value = ""..GameSocket.mCharacter.mAC.."-"..GameSocket.mCharacter.mMaxAC},
			--{key="lbl_mac", name="魔防：", value = ""..GameSocket.mCharacter.mMAC.."-"..GameSocket.mCharacter.mMaxMAC},
			--{key="lbl_accuracy", name="准确：", value = ""..GameSocket.mCharacter.mAccuracy},
			--{key="lbl_dodge", name="闪避：", value = ""..GameSocket.mCharacter.mDodge},
			--{key="lbl_tenacity",    name="韧性：", value = ""..GameSocket.mCharacter.tenacity},
			{key="pk_value",    name="PK值：", value = ""..GameCharacter._mainAvatar:NetAttr(GameConst.net_pkvalue)},
			{key="lbl_crit_prob",    name="暴击率：", value = ""..(GameSocket.mCharacter.critProb/100).."%"},
			--{key="lbl_crit_point", name="暴 击 力：", value = ""..GameSocket.mCharacter.critPoint},
			{key="labSSSH",  name="切割伤害：", value = ""..GameSocket.mCharacter.holyDam},
			{key="lbl_fbjl_prob",    name="防爆机率：", value = ""..(GameSocket.mCharacter.mDropProtect/100).."%"},
			--{key="lbl_fbjl_prob",    name="怪物爆率加成：", value = ""..(GameSocket.mCharacter.mMonsterDrop/100).."%"},
			--{key="lbl_rwbl_prob",    name="人物爆率：", value = ""..(GameSocket.mCharacter.mPlayDrop/100).."%"},
			--{key="lbl_mffy_prob",    name="魔法防御：", value = ""..(GameSocket.mCharacter.mMACRatio/100).."%"},
			--{key="lbl_gjsh_prob",    name="翻倍伤害：", value = ""..(GameSocket.mCharacter.mBeiShang/100).."%"},
			--{key="lbl_fmjl_prob",    name="防麻几率：", value = ""..(GameSocket.mCharacter.mMabiProtect/100).."%"},
			--{key="lbl_hsfy_prob",    name="忽视防御：", value = ""..(GameSocket.mCharacter.mIgnoreDCRatio/100).."%"},
			--{key="lbl_shxs_prob",    name="伤害吸收：", value = ""..(GameSocket.mCharacter.mXishou/100).."%"},
			{key="lbl_dcrate_prob",    name="攻击加成：", value = ""..(GameSocket.mCharacter.mDCRatio/100).."%"},
			{key="lbl_acrate_prob",    name="防御加成：", value = ""..(GameSocket.mCharacter.mACRatio/100).."%"},
			{key="lbl_maxhppres_prob",    name="血量加成：", value = ""..(GameSocket.mCharacter.mMaxHpPres/100).."%"},
		}
		local lblAttr
		local lblAttrStr = ""
		for i,v in ipairs(lbl_attrs) do
			lblAttr = var.xmlPageRole:getWidgetByName(v.key)
			-- print("updateAvatarAttr", i, v.key, lblAttr)
			if lblAttr then
				lblAttr:setString(v.value or 0)
				--if string.len(v.value)>17 then
					lblAttr:setFontSize(16)
					--print("------------fs12----------")
				--else
				--	lblAttr:setFontSize(16)
					--print("------------fs16----------")
				--end
			else
				lblAttrStr = lblAttrStr.."<font color='#a08763' outline='0,0,0,255,2' size=15>"..v.name.."</font><font color='#836130' outline='255,255,255,255,2' size=15>"..v.value.."</font><br />"
				--lblAttrStr = lblAttrStr.."<td color=#a08763 size=16 width=29 ht=0>"..v.name.."</td><td color=#836130 size=16 width=29 ht=0>"..v.value.."</td><br />"
				--lblAttrStr = lblAttrStr.."<pic color='#FFFF99' res='character_role_attr_bg_3.png' sel='character_role_attr_bg_3.png' vt=1 ht=0 width=360 height=37 fs='13' opa=0.3 color='246|255|143' label='　　"..v.value.."'></pic>"
				--lblAttrStr = lblAttrStr.."<pic color='#FFFF99' res='character_role_attr_bg_4.png' sel='character_role_attr_bg_4.png' vt=1 ht=0 width=250 height=37 fs='12' opa=0.3 label=\"　　"..v.value.."\"></pic>"
			end
		end
		--var.xmlPageRole:getWidgetByName("attr_describe"):setRichLabel("<font color='#FFFF99' size='16'>"..lblAttrStr.."</font>")
		var.xmlPageRole:getWidgetByName("attr_describe"):setRichLabel(lblAttrStr)
		var.xmlPageRole:getWidgetByName("attr_describe_container"):requestDoLayout()
	end

	--刷新装备
	local function updateEquips()
		for i = 1, #equip_info do
			local equip_block = var.xmlPageRole:getWidgetByName("equip_"..i)
			if equip_block then
				equip_block:setLocalZOrder(10)
				-- ccui.Widget:create():setContentSize(equip_block:getContentSize()):setName("guideWidget"):align(display.LEFT_BOTTOM, 0, 0):addTo(equip_block)
				equip_block.etype = equip_info[i].etype
				local param = {
					parent			= equip_block,
					pos				= equip_info[i].pos,--左边的装备tips显示在右边，反之亦然
					tipsPos			= cc.p(display.cx-var.xmlPageRole:getContentSize().width/2+(i<=5 and 290 or 0), display.cy-var.xmlPageRole:getContentSize().height/2),
					tipsAnchor		= cc.p(0,0),
					tipsType = not equip_info[i].noTipsBtn and GameConst.TIPS_TYPE.GENERAL or nil,
				}
				GUIItem.getItem(param)
			end
		end
	end

	local function updateBoxEquips()
		var.xmlPageRole:getWidgetByName("img_equips_type"):loadTexture(var.mShowMainEquips and "word_vice_equips" or "word_main_equips", ccui.TextureResType.plistType)

		-- print("updateBoxEquips", var.mShowMainEquips)
		var.xmlPageRole:getWidgetByName("box_role"):setLocalZOrder(4)
		local boxMainEquips = var.xmlPageRole:getWidgetByName("box_main_equips")
		local boxViceEquips = var.xmlPageRole:getWidgetByName("box_vice_equips")
		local boxSXEquips = var.xmlPageRole:getWidgetByName("box_sx_equips")
		if var.mShowMainEquips then
			boxSXEquips:hide()
			boxMainEquips:show()
			boxViceEquips:hide()
		else
			boxSXEquips:hide()
			boxMainEquips:hide()
			boxViceEquips:show()
		end
	end
	
	

	local function updateBoxEquipsSX()
		--var.xmlPanel:getWidgetByName("img_equips_type"):loadTexture(var.mShowMainEquips and "word_vice_equips" or "word_main_equips", ccui.TextureResType.plistType)
		local boxMainEquips = var.xmlPageRole:getWidgetByName("box_main_equips")
		local boxViceEquips = var.xmlPageRole:getWidgetByName("box_vice_equips")
		local boxSXEquips = var.xmlPageRole:getWidgetByName("box_sx_equips")
		if var.mShowSXEquips then
			boxSXEquips:show()
			boxMainEquips:hide()
			boxViceEquips:hide()
		else
			boxSXEquips:hide()
			boxMainEquips:show()
			boxViceEquips:hide()
		end
	end

	local function updateInnerPower(event)
		-- if not event.srcId == GameCharacter.mID then return end
		local power =      GameCharacter._mainAvatar:NetAttr(GameConst.net_power) or 0
		local maxpower =   GameCharacter._mainAvatar:NetAttr(GameConst.net_maxpower) or 0
		--var.barPower:setPercentWithAnimation(power, maxpower)
		updateFightPoint()
	end

	var.xmlPageRole = GUIAnalysis.load("ui/layout/ContainerCharacter_role.uif")
	if var.xmlPageRole then

		--GameUtilSenior.asyncload(var.xmlPageRole, "page_role_bg", "ui/image/page_role_bg.png")
		var.xmlPageRole:align(display.LEFT_BOTTOM, 0, 0):addTo(var.xmlPanel)

		var.xmlPageRole:getWidgetByName("lbl_role_name"):setString(GameCharacter._mainAvatar:NetAttr(GameConst.net_name))

		var.barHp = var.xmlPageRole:getWidgetByName("bar_hp")
		var.barMp = var.xmlPageRole:getWidgetByName("bar_mp")
		--var.barPower = var.xmlPageRole:getWidgetByName("bar_power")

		local job = GameCharacter._mainAvatar:NetAttr(GameConst.net_job)
		local imgJob = var.xmlPageRole:getWidgetByName("img_Job")
		local jobres = {"img_role_zhan_delete","img_role_fa_delete","img_role_dao_delete"}
		imgJob:loadTexture(jobres[job-99], ccui.TextureResType.plistType)

		var.powerNum = ccui.TextAtlas:create("0123456789", "image/typeface/num_44.png", 20, 32, "0")
			:addTo(var.xmlPageRole:getWidgetByName("Image_2"))
			:align(display.LEFT_BOTTOM, 120,13)
			:setString(0)

		local btnSwitch = var.xmlPageRole:getWidgetByName("btn_switch_equips"):setPressedActionEnabled(true)
		btnSwitch:addClickEventListener( function (sender)
			var.mShowMainEquips = not var.mShowMainEquips
			updateBoxEquips()
		end)
		
		
		local btnSXSwitch = var.xmlPageRole:getWidgetByName("btn_sx_switch"):setPressedActionEnabled(true)
		btnSXSwitch:addClickEventListener( function (sender)
			var.mShowSXEquips = not var.mShowSXEquips
			updateBoxEquipsSX()
		end)
		
		
		local btnNamePre = var.xmlPageRole:getWidgetByName("Image_100"):setPressedActionEnabled(true):setLocalZOrder(99)
		btnNamePre:addClickEventListener( function (sender)
			showPanelPage(6);
		end)
		
		local btn_shenqi = var.xmlPageRole:getWidgetByName("btn_shenqi"):setPressedActionEnabled(true):setLocalZOrder(99)
		btn_shenqi:addClickEventListener( function (sender)
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "V8_ContainerShenQi"})
		end)
		
		local btn_shenyi = var.xmlPageRole:getWidgetByName("btn_shenyi"):setPressedActionEnabled(true):setLocalZOrder(99)
		btn_shenyi:addClickEventListener( function (sender)
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "V8_ContainerShenYi"})
		end)
		
		local btn_tujian = var.xmlPageRole:getWidgetByName("btn_tujian"):setPressedActionEnabled(true):setLocalZOrder(99)
		btn_tujian:addClickEventListener( function (sender)
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "V8_ContainerTuJian"})
		end)
		
		local btn_zhongshen = var.xmlPageRole:getWidgetByName("btn_zhongshen"):setPressedActionEnabled(true):setLocalZOrder(99)
		btn_zhongshen:addClickEventListener( function (sender)
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "V8_ContainerZhongShen"})
		end)
		
		
		local btn_xz = var.xmlPageRole:getWidgetByName("btn_xz"):setPressedActionEnabled(true):setLocalZOrder(99)
		btn_xz:addClickEventListener( function (sender)
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "panel_constellation"})
		end)
		
		local btn_jq = var.xmlPageRole:getWidgetByName("btn_jq"):setPressedActionEnabled(true):setLocalZOrder(99)
		btn_jq:addClickEventListener( function (sender)
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "panel_jianqiao"})
		end)
		
		local btn_fj = var.xmlPageRole:getWidgetByName("btn_fj"):setPressedActionEnabled(true):setLocalZOrder(99)
		btn_fj:addClickEventListener( function (sender)
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "panel_fojing"})
		end)
		
		local btn_xh = var.xmlPageRole:getWidgetByName("btn_xh"):setPressedActionEnabled(true):setLocalZOrder(99)
		btn_xh:addClickEventListener( function (sender)
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "panel_xuanhun"})
		end)
		
		var.mShowMainEquips = true
		var.mShowSXEquips  = false
		updateBoxEquips()

		updateFightPoint()
		updateHpMp()
		updateAvatarAttr()
		updateInnerLooks()
		updateEquips()
		var.xmlPageRole:getWidgetByName("btn_strength"):addClickEventListener(function( ... )
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "extend_strengthen"})
		end)
		cc.EventProxy.new(GameSocket, var.xmlPageRole)
			:addEventListener(GameMessageCode.EVENT_SELF_HPMP_CHANGE, updateHpMp)
			:addEventListener(GameMessageCode.EVENT_ATTRIBUTE_CHANGE, updateAvatarAttr)
			:addEventListener(GameMessageCode.EVENT_AVATAR_CHANGE, updateInnerLooks)
			:addEventListener(GameMessageCode.EVENT_INNERPOWER_CHANGE, updateInnerPower)

		--local skillEff = var.xmlPageRole:getWidgetByName("imgSkill"):getChildByName("skillEff")
		--var.xmlPageRole:getWidgetByName("imgSkill"):setTouchEnabled(true)
		--var.xmlPageRole:getWidgetByName("imgSkill"):addClickEventListener(function ( ... )
		--	GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "main_skill"})
		--end)
		--if not skillEff then
		--	skillEff = cc.Sprite:create()
		--	skillEff:setName("skillEff")
		--	skillEff:setPosition(72,59)
		--			:setTouchEnabled(false)
		--			:addTo(var.xmlPageRole)
		--			:setLocalZOrder(9)
		--	var.xmlPageRole:getWidgetByName("imgSkill11"):setLocalZOrder(10)
		--	local animate = cc.AnimManager:getInstance():getPlistAnimate(4, 50016, 4, 5)
		--	skillEff:runAction(cca.repeatForever(animate))
		--end
		var.xmlPageRole:runAction(cca.seq({
			cca.delay(0.01),
			cca.cb(function()
				if var.xmlPanel:getWidgetByName("tab1"):getChildByName("redPoint") then
					var.xmlPageRole:getChildByName("red"):show()
				end
			end)
		}))
		
	end
end


--------------------------------------时装--------------------------------------
function ContainerCharacter.initPageFashion()

	local function updateInnerLooks()
		ContainerCharacter.tryOnFashion()
	end
	

	--刷新装备
	local function updateEquips()
		for i = 1, #equip_info do
			local equip_block = var.xmlPageFashion:getWidgetByName("equip_"..i)
			if equip_block then
				equip_block:setLocalZOrder(10)
				-- ccui.Widget:create():setContentSize(equip_block:getContentSize()):setName("guideWidget"):align(display.LEFT_BOTTOM, 0, 0):addTo(equip_block)
				local needShowInnerLook= false
				if i==22 or i==24 or i==25 or i==26 or i==28 then  --这些位置的装备显示动态内观
					needShowInnerLook = false
				end
				equip_block.etype = equip_info[i].etype
				local param = {
					parent			= equip_block,
					pos				= equip_info[i].pos,--左边的装备tips显示在右边，反之亦然
					tipsPos			= cc.p(display.cx-var.xmlPageFashion:getContentSize().width/2+(i<=5 and 290 or 0), display.cy-var.xmlPageFashion:getContentSize().height/2),
					tipsAnchor		= cc.p(0,0),
					mShowEquipFlag  = true,
					tipsType = not equip_info[i].noTipsBtn and GameConst.TIPS_TYPE.GENERAL or nil,
					showInnerLook = needShowInnerLook,   --格子里显示内观
				}
				GUIItem.getItem(param)
			end
		end
	end
	
	--刷新战力
	local function updateFightPoint()
		var.powerFashionNum:setString(GameSocket.mCharacter.mFightPoint)
	end
	
	---刷新属性条
	local function updateHpMp(event)
		local hp = 		GameCharacter._mainAvatar:NetAttr(GameConst.net_hp) or 0
		local maxhp = 	GameCharacter._mainAvatar:NetAttr(GameConst.net_maxhp) or 0
		local mp =		GameCharacter._mainAvatar:NetAttr(GameConst.net_mp) or 0
		local maxmp = 	GameCharacter._mainAvatar:NetAttr(GameConst.net_maxmp) or 0
		if event then
			var.xmlPageFashion:getWidgetByName("bar_hp"):setPercentWithAnimation(hp, maxhp)
			var.xmlPageFashion:getWidgetByName("bar_mp"):setPercentWithAnimation(mp, maxmp)
		else
			local power =      GameCharacter._mainAvatar:NetAttr(GameConst.net_power) or 0
			local maxpower =   GameCharacter._mainAvatar:NetAttr(GameConst.net_maxpower) or 0
			var.xmlPageFashion:getWidgetByName("bar_hp"):setPercent(hp, maxhp):setFontSize( 12 ):enableOutline(GameBaseLogic.getColor(0x000000),1)
			var.xmlPageFashion:getWidgetByName("bar_mp"):setPercent(mp, maxmp):setFontSize( 12 ):enableOutline(GameBaseLogic.getColor(0x000000),1)
			--var.xmlPageFashion:getWidgetByName("bar_power"):setPercent(GameSocket.mCharacter.mCurExperience,GameSocket.mCharacter.mCurrentLevelMaxExp):setFontSize( 12 ):enableOutline(GameBaseLogic.getColor(0x000000),1)
		end
	end

	--刷新右侧属性
	local function updateAvatarAttr()

		--
		ContainerCharacter:updateGameMoney(var.xmlPageFashion)
		--
		
		local hp = 		GameCharacter._mainAvatar:NetAttr(GameConst.net_hp) or 0
		local maxhp = 	GameCharacter._mainAvatar:NetAttr(GameConst.net_maxhp) or 0
		local mp =		GameCharacter._mainAvatar:NetAttr(GameConst.net_mp) or 0
		local maxmp = 	GameCharacter._mainAvatar:NetAttr(GameConst.net_maxmp) or 0

		local guild_name = GameCharacter._mainAvatar:NetAttr(GameConst.net_guild_name)
		if not guild_name or guild_name == "" then
			guild_name = "暂无行会"
		end
		local lbl_attrs = {
			{key="level_value",    name="等级：", value = ""..GameSocket.mCharacter.mLevel},
			--{key="lbl_zhiye_prob",    name="职业：", value = ""},
			{key="lbl_guild_name", name="行会：", value = ""..guild_name},
			--{key="lbl_hp",    name="生命：", value = ""..hp.."-"..maxhp},
			--{key="lbl_mp",    name="魔法：", value = ""..mp.."-"..maxmp},
			{key="lbl_dc", name="物攻：", value = ""..GameSocket.mCharacter.mDC.."-"..GameSocket.mCharacter.mMaxDC},
			--{key="lbl_mc", name="魔攻：", value = ""..GameSocket.mCharacter.mMC.."-"..GameSocket.mCharacter.mMaxMC},
			--{key="lbl_sc", name="道功：", value = ""..GameSocket.mCharacter.mSC.."-"..GameSocket.mCharacter.mMaxSC},
			{key="lbl_ac", name="物防：", value = ""..GameSocket.mCharacter.mAC.."-"..GameSocket.mCharacter.mMaxAC},
			--{key="lbl_mac", name="魔防：", value = ""..GameSocket.mCharacter.mMAC.."-"..GameSocket.mCharacter.mMaxMAC},
			--{key="lbl_accuracy", name="准确：", value = ""..GameSocket.mCharacter.mAccuracy},
			--{key="lbl_dodge", name="闪避：", value = ""..GameSocket.mCharacter.mDodge},
			--{key="lbl_tenacity",    name="韧性：", value = ""..GameSocket.mCharacter.tenacity},
			--{key="lbl_luck",    name="幸运：", value = ""..GameSocket.mCharacter.mLuck},
			{key="pk_value",    name="PK值：", value = ""..GameCharacter._mainAvatar:NetAttr(GameConst.net_pkvalue)},
			{key="lbl_crit_prob",    name="暴击率：", value = ""..(GameSocket.mCharacter.critProb/100).."%"},
			--{key="lbl_crit_point", name="暴 击 力：", value = ""..GameSocket.mCharacter.critPoint},
			{key="labSSSH",  name="切割伤害：", value = ""..GameSocket.mCharacter.holyDam},
			{key="lbl_fbjl_prob",    name="防爆机率：", value = ""..(GameSocket.mCharacter.mDropProtect/100).."%"},
			--{key="lbl_rwbl_prob",    name="人物爆率：", value = ""..(GameSocket.mCharacter.mPlayDrop/100).."%"},
			--{key="lbl_mffy_prob",    name="魔法防御：", value = ""..(GameSocket.mCharacter.mMACRatio/100).."%"},
			--{key="lbl_gjsh_prob",    name="翻倍伤害：", value = ""..(GameSocket.mCharacter.mBeiShang/100).."%"},
			--{key="lbl_fmjl_prob",    name="防麻几率：", value = ""..(GameSocket.mCharacter.mMabiProtect/100).."%"},
			--{key="lbl_hsfy_prob",    name="忽视防御：", value = ""..(GameSocket.mCharacter.mIgnoreDCRatio/100).."%"},
			--{key="lbl_shxs_prob",    name="伤害吸收：", value = ""..(GameSocket.mCharacter.mXishou/100).."%"},
			{key="lbl_dcrate_prob",    name="攻击加成：", value = ""..(GameSocket.mCharacter.mDCRatio/100).."%"},
			{key="lbl_acrate_prob",    name="防御加成：", value = ""..(GameSocket.mCharacter.mACRatio/100).."%"},
			{key="lbl_maxhppres_prob",    name="血量加成：", value = ""..(GameSocket.mCharacter.mMaxHpPres/100).."%"},
		}
		local lblAttr
		local lblAttrStr = ""
		for i,v in ipairs(lbl_attrs) do
			lblAttr = var.xmlPageFashion:getWidgetByName(v.key)
			-- print("updateAvatarAttr", i, v.key, lblAttr)
			if lblAttr then
				lblAttr:setString(v.value or 0)
				--if string.len(v.value)>17 then
					lblAttr:setFontSize(16)
				--	print("------------fs12----------")
				--else
				--	lblAttr:setFontSize(16)
				--	print("------------fs16----------")
				--end
			else
				lblAttrStr = lblAttrStr.."<font color='#a08763' outline='0,0,0,255,2' size=15>"..v.name.."</font><font color='#836130' outline='255,255,255,255,2' size=15>"..v.value.."</font><br />"
				--lblAttrStr = lblAttrStr.."<pic color='#FFFF99' res='character_role_attr_bg_3.png' sel='character_role_attr_bg_3.png' vt=1 ht=0 width=360 height=37 fs='13' opa=0.3 color='246|255|143' label='　　"..v.value.."'></pic>"
				--lblAttrStr = lblAttrStr.."<pic color='#FFFF99' res='character_role_attr_bg_4.png' sel='character_role_attr_bg_4.png' vt=1 ht=0 width=360 height=37 fs='12' opa=0.3 label=\"　　"..v.value.."\"></pic>"
			end
		end
		--var.xmlPageFashion:getWidgetByName("attr_describe"):setRichLabel("<font color='#FFFF99' size='16'>"..lblAttrStr.."</font>")
		var.xmlPageFashion:getWidgetByName("attr_describe"):setRichLabel(lblAttrStr)
		var.xmlPageFashion:getWidgetByName("attr_describe_container"):requestDoLayout()
	end

	local function updateInnerPower(event)
		-- if not event.srcId == GameCharacter.mID then return end
		local power =      GameCharacter._mainAvatar:NetAttr(GameConst.net_power) or 0
		local maxpower =   GameCharacter._mainAvatar:NetAttr(GameConst.net_maxpower) or 0
		--var.xmlPageFashion:getWidgetByName("bar_power"):setPercentWithAnimation(power, maxpower)
		updateFightPoint()
	end
	
	
	--新版时装列表
	local function newFashionList()
		--新版列表
		local itemData = {}
		local itemDataPos = {}
		for i=0,(GameConst.ITEM_BAG_SIZE+GameSocket.mBagSlotAdd) do
			local nItem = GameSocket:getNetItem(i)
			if nItem then
				local itemDef = GameSocket:getItemDefByID(nItem.mTypeID)
				if itemDef then
					if tonumber(itemDef.mEquipType)==32 then
						table.insert(itemData,itemDef)
						table.insert(itemDataPos,i)
					end
				end
			end
		end
		local function updateList(item)
			local tag = item.tag
			if #itemData>=tag then
				local param = {
					parent = item,
					pos = itemDataPos[tag],
					typeId=itemData[tag].mTypeID, 
					iconType = GameConst.ICONTYPE.BAG,
					tipsType = GameConst.TIPS_TYPE.BAG,
					tipsPos	= cc.p(display.cx-var.xmlPanel:getContentSize().width/2+25, display.cy-var.xmlPanel:getContentSize().height/2+2),
					tipsAnchor = cc.p(0,0),
					hitTest = function(sender)
						return GameUtilSenior.hitTest(var.xmlPageFashion:getWidgetByName("listBag"), sender);
					end,
					compare = true
				}
				GUIItem.getItem(param)
			end
		end
		local listBag = var.xmlPageFashion:getWidgetByName("listBag")
		listBag:reloadData(9,updateList)--:setSliderVisible(false)	
		--新版列表结束	
	end

	
	var.xmlPageFashion = GUIAnalysis.load("ui/layout/ContainerCharacter_fashion.uif")
	if var.xmlPageFashion then
		--GameUtilSenior.asyncload(var.xmlPageFashion, "page_role_bg", "ui/image/page_fashion_bg.png")
		--GameUtilSenior.asyncload(var.xmlPageFashion, "page_fashion_right_bg", "ui/image/page_fashion_right_bg.png")
		--GameUtilSenior.asyncload(var.xmlPageFashion, "page_fashion_bg", "ui/image/img_fashion_bg.jpg")
		var.xmlPageFashion:align(display.LEFT_BOTTOM, 0, 0):addTo(var.xmlPanel)

		var.xmlPageFashion:getWidgetByName("lbl_role_name"):setString(GameCharacter._mainAvatar:NetAttr(GameConst.net_name))

		var.powerFashionNum = ccui.TextAtlas:create("0123456789", "image/typeface/num_44.png", 20, 32, "0")
			:addTo(var.xmlPageFashion:getWidgetByName("Image_2"))
			:align(display.LEFT_BOTTOM, 120,13)
			:setString(0)
			
		local job = GameCharacter._mainAvatar:NetAttr(GameConst.net_job)
		local imgJob = var.xmlPageFashion:getWidgetByName("img_Job")
		local jobres = {"img_role_zhan_delete","img_role_fa_delete","img_role_dao_delete"}
		--imgJob:loadTexture(jobres[job-99], ccui.TextureResType.plistType)

		--local tabhfashion = var.xmlPageFashion:getWidgetByName("tabhfashion")
		--tabhfashion:setItemMargin(0):setTabColor(GameBaseLogic.getColor4(0xefddca),GameBaseLogic.getColor4(0xefddca))
		--tabhfashion:addTabEventListener(ContainerCharacter.ckickFashionTab)

		--local btn_info = var.xmlPageFashion:getWidgetByName("btn_info")
		--btn_info:setTouchEnabled(true):addTouchEventListener(function(sender,eventType)
		--	if eventType == ccui.TouchEventType.began then
		--		GameSocket:dispatchEvent({
		--			name = GameMessageCode.EVENT_PANEL_ON_ALERT, panel = "tips", visible = true, infoTable = lblhint,
		--		})
		--	elseif eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled  then
		--		GameSocket:dispatchEvent({
		--			name = GameMessageCode.EVENT_PANEL_ON_ALERT, panel = "all", visible = false })
		--	end
		--end)
		GameSocket:PushLuaTable("gui.PanelFashion.onOpenPanel",GameUtilSenior.encode({actionid = "fresh"}))
		updateInnerLooks()
		updateEquips()
		updateFightPoint()
		updateHpMp()
		updateAvatarAttr()
		newFashionList()
		cc.EventProxy.new(GameSocket, var.xmlPageFashion)
			:addEventListener(GameMessageCode.EVENT_SELF_HPMP_CHANGE, updateHpMp)
			:addEventListener(GameMessageCode.EVENT_ATTRIBUTE_CHANGE, updateAvatarAttr)
			:addEventListener(GameMessageCode.EVENT_ITEM_CHANGE, ContainerCharacter.freshFashionPage)
			:addEventListener(GameMessageCode.EVENT_AVATAR_CHANGE, updateInnerLooks)
			:addEventListener(GameMessageCode.EVENT_INNERPOWER_CHANGE, updateInnerPower)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA,ContainerCharacter.setFashiondata)

	end
	
	
end
function ContainerCharacter.setFashiondata(event)
	if event.type == "Fashion" then
		local pData = GameUtilSenior.decode(event.data)
		if pData then
			if pData.cmd == "dress_fashion" then
				var.fashion_data= pData.data
			end
		end
	elseif event.type == "PanelFashion" then
		local data = GameUtilSenior.decode(event.data)
		if data.cmd == "getFashionPreview" then
			var.fashion_preview = data.Data;
		end
	end
end
function ContainerCharacter.freshFashionPage(event)
	local tabhfashion = var.xmlPageFashion:getWidgetByName("tabhfashion")
	if pageKeys[var.boxTab:getCurIndex()] == "fashion" then
		-- if tabhfashion:getCurIndex() == table.indexof(fashionPos,event.pos) then
		--	ContainerCharacter.ckickFashionTab(tabhfashion:getItemByIndex(tabhfashion:getCurIndex()))
		-- end
		if table.indexof(fashionPos,event.pos)  then
			--ContainerCharacter.freshFashionAttr(event)
		end
	end
end
--显示已装备时装属性
function ContainerCharacter.freshFashionAttr(event)
	local attrList = var.xmlPageFashion:getWidgetByName("attrList"):removeAllItems()
	local model = var.xmlPageFashion:getWidgetByName("model")
	local fashionItems = {}
	for k,v in pairs(fashionPos) do
		local netItem = GameSocket:getNetItem(v)
		if netItem then
			local itemDef = GameSocket:getItemDefByID(netItem.mTypeID)
			if itemDef then
				table.insert(fashionItems,itemDef)
			end
		end
	end
	for i=1,5 do
		local modeli = model:clone()
		modeli:getWidgetByName("attrName"):setString(attrData[i].str)
		local a1,a2 = 0,0
		for k,v in pairs(fashionItems) do
			a1 = a1 + v[attrData[i].x1]
			a2 = a2 + v[attrData[i].x2]
		end
		modeli:getWidgetByName("attrValue"):setString(string.format("%d-%d",a1,a2))
		attrList:pushBackCustomItem(modeli)
	end
end
function ContainerCharacter.tryOnFashion(typeId)
		--翅膀
		local img_wing = var.xmlPageFashion:getChildByName("img_wing")


		--设置翅膀内观
		if not img_wing then
			img_wing = cc.Sprite:create()
			img_wing:addTo(var.xmlPageFashion):align(display.CENTER, 386, 370):setName("img_wing")
		end
		-- local weaponDef = GameSocket:getItemDefByPos(GameConst.ITEM_WEAPON_POSITION)
		local wing = GameCharacter._mainAvatar:NetAttr(GameConst.net_wing)
		if wing then
			--if wing~=var.curwingId then
				img_wing:removeChildByName("spriteEffect")
				GameUtilSenior.addEffect(img_wing,"spriteEffect",GROUP_TYPE.WING_REVIEW,wing,{x=0,y=-100},false,true)
				--var.curwingId=wing
			---end
		else
			img_wing:setTexture(nil)
			img_wing:setVisible(false)
		end
		
		--武器
		local img_weapon = var.xmlPageFashion:getChildByName("img_weapon")
	    --设置武器内观
		if not img_weapon then
			img_weapon = cc.Sprite:create()
			img_weapon:addTo(var.xmlPageFashion):setAnchorPoint(cc.p(0.52,0.3)):setPosition(296, 370):setName("img_weapon"):setLocalZOrder(3)
		end
		local weaponDef
		--if not typeId and not GameSocket:getItemDefByPos(GameConst.ITEM_FASHION_CLOTH_POSITION) then
			weaponDef = GameSocket:getItemDefByPos(GameConst.ITEM_WEAPON_POSITION)
		--end
		if weaponDef then
			--if weaponDef.mResMale~=img_weapon.curWeaponId then
				
				img_weapon:removeChildByName("spriteEffect")
				GameUtilSenior.addEffect(img_weapon,"spriteEffect",GROUP_TYPE.WEAPON_REVIEW,weaponDef.mResMale,{x=-150,y=241},false,true)
				
				
				img_weapon.curWeaponId=weaponDef.mResMale
			--end
		else
			img_weapon:stopAllActions()
			img_weapon:setTexture(nil)
			img_weapon:setVisible(false)
			img_weapon.curWeaponId=nil
		end
		--衣服
		local img_role = var.xmlPageFashion:getChildByName("img_role")
		--设置衣服内观
		if not img_role then
			img_role = cc.Sprite:create()
			img_role:addTo(var.xmlPageFashion):align(display.CENTER, 270, 270):setName("img_role"):setLocalZOrder(2)
		end
		local clothDef,clothId
		local isFashion = false
		if typeId then
			--试穿
			clothDef = GameSocket:getItemDefByID(typeId)
			if clothDef then
				isFashion = true
				clothId = clothDef.mResMale
			end
		else
			local fashion = GameCharacter._mainAvatar:NetAttr(GameConst.net_fashion)
			local cloth = GameCharacter._mainAvatar:NetAttr(GameConst.net_cloth)
			if fashion >0 then
				clothId = fashion
				isFashion = true
			else
				clothDef = GameSocket:getItemDefByPos(GameConst.ITEM_CLOTH_POSITION)
				if clothDef then
					clothId = clothDef.mResMale
				else
					clothId = cloth
				end
			end
		end
		if not clothId then
			local gender = GameCharacter._mainAvatar:NetAttr(GameConst.net_gender)
			local luoti= gender==200 and  20000 or 20000
			clothId = luoti
		end

		if typeId and var.fashion_data then
			local gender = GameCharacter._mainAvatar:NetAttr(GameConst.net_gender)
			for i=1,#var.fashion_data do
				if typeId==var.fashion_data[i].id then
					if gender == 200 then
						clothId =var.fashion_data[i].male
					else
						clothId =var.fashion_data[i].female
					end
					break
				end
			end

		end
		if clothId~=img_role.curClothId then
			
			img_role:removeChildByName("spriteEffect")
			if isFashion then
				GameUtilSenior.addEffect(img_role,"spriteEffect",GROUP_TYPE.FDRESS_REVIEW,clothId,{x=-122,y=330},false,true)
			else
				GameUtilSenior.addEffect(img_role,"spriteEffect",GROUP_TYPE.CLOTH_REVIEW,clothId,{x=-122,y=330},false,true)
			end			
			
			img_role.curClothId = clothId
		end

end
function ContainerCharacter.ckickDressFashionButton( sender )
	if sender.position<0 then
		GameSocket:UndressItem(sender.position)
	else
		GameSocket:BagUseItem(sender.position,sender.mTypeID)
	end
end

--刷新时装列表
function ContainerCharacter.ckickFashionTab(tab)
	ContainerCharacter.tryOnFashion();
	local function pushSelectItem(item)
		if item and item.tagFashionId > 0 then
			--ContainerCharacter.tryOnFashion(item.tagFashionId)
			ContainerCharacter.TryFashionShow(item.tagFashionId,item.tag);
		end
	end
	local tag = tab:getTag()
	var.fashion_list_cells={};
	var.curFashionListIndex = 0;
	if tag == 1 then
		local data = {}
		for k,v in pairs(GameSocket.mItems) do
			if k>=GameConst.ITEM_FASHIONDEPOT_BEGIN and k<=GameConst.ITEM_FASHIONDEPOT_BEGIN+GameConst.ITEM_FASHIONSIZEE then
				if GameBaseLogic.IsSameFashion(v.mTypeID,fashionPos[tag]) then
					table.insert(data,v)
				end
			end
		end
		local DressItem = GameSocket:getNetItem(fashionPos[tag])
		local lbllefttime = var.xmlPageFashion:getWidgetByName("lbllefttime"):hide():stopAllActions()
		local lblleftstr = var.xmlPageFashion:getWidgetByName("lblleftstr"):hide()
		if DressItem then
			lblleftstr:show()
			lbllefttime:show()
			table.insert(data,1,DressItem)
			-- local itemDef = GameSocket:getItemDefByID(DressItem.mTypeID)
			local sec = 0
			-- if itemDef then
				sec = DressItem.mLastTime - os.time() + DressItem.mCreateTime
			-- end
			if DressItem.mLastTime == 0 then
				lbllefttime:setString("永久")
			else
				GameUtilSenior.runCountDown(lbllefttime,sec,function(target,count)
					target:setString(GameUtilSenior.setTimeFormat(count*1000,6))
				end)
			end
		end

		local fashionList = var.xmlPageFashion:getWidgetByName("fashionList")
		fashionList:reloadData(#data,function(subItem)
			local d = data[subItem.tag]
			local itemDef = GameSocket:getItemDefByID(d.mTypeID)
			GUIItem.getItem({
				parent = subItem:getWidgetByName("icon"),
				typeId = d.mTypeID,
				iconType = GameConst.ICONTYPE.NOTIP,
				callBack = function()
					--ContainerCharacter.tryOnFashion(d.mTypeID)--点击icon
					ContainerCharacter.TryFashionShow(d.mTypeID,subItem.tag);
				end
			});

			subItem:getWidgetByName("itemname"):setString(itemDef.mName)
			local btn_dress = subItem:getWidgetByName("btn_dress")
			btn_dress.mTypeID = d.mTypeID
			btn_dress.position = d.position
			btn_dress:addClickEventListener(ContainerCharacter.ckickDressFashionButton)
			btn_dress:setTitleText(d.position<0 and "卸下" or "穿戴"):setVisible(true)
			local hasDress = subItem:getWidgetByName("hasDress")
			hasDress:setVisible(d.position<0)
			subItem:getWidgetByName("img_selected"):setVisible(false);
			subItem:getWidgetByName("lbl_fashion_remark"):setVisible(false)
			subItem.tagFashionId = d.mTypeID;
			subItem:setTouchEnabled(true)
			GUIFocusPoint.addUIPoint(subItem, pushSelectItem)

			local needCell = var.fashion_list_cells[subItem.tag];
			if not needCell then
				needCell = subItem;
				needCell:setName(subItem:getName()..subItem.tag);
			end
			var.fashion_list_cells[subItem.tag] = needCell;

		end)
	elseif tag == 2 then
		var.xmlPageFashion:getWidgetByName("fashionList"):reloadData(#var.fashion_preview,function(subItem)

			local previewdata = var.fashion_preview[subItem.tag]
			GUIItem.getItem({
				parent = subItem:getWidgetByName("icon"),
				typeId = previewdata.id,
				iconType = GameConst.ICONTYPE.NOTIP,
				callBack = function()
					--ContainerCharacter.tryOnFashion(previewdata.id)--点击icon
					ContainerCharacter.TryFashionShow(d.mTypeID,subItem.tag);
				end
			});
			subItem:getWidgetByName("img_selected"):setVisible(false);
			subItem:getWidgetByName("itemname"):setString(previewdata.name)
			subItem:getWidgetByName("btn_dress"):setVisible(false)
			subItem:getWidgetByName("hasDress"):setVisible(false)
			subItem:getWidgetByName("lbl_fashion_remark"):setVisible(true):setString(previewdata.accessway)
			subItem.tagFashionId = previewdata.id;
			subItem:setTouchEnabled(true)
			GUIFocusPoint.addUIPoint(subItem, pushSelectItem)

			local needCellpre = var.fashion_list_cells[subItem.tag];
			if not needCellpre then
				needCellpre = subItem;
				needCellpre:setName(subItem:getName()..subItem.tag);
			end
			var.fashion_list_cells[subItem.tag] = needCellpre;

		end)
	end
end

function ContainerCharacter.TryFashionShow(fashionid,listindex)
	ContainerCharacter.tryOnFashion(fashionid);
	if var.curFashionListIndex > 0 and var.fashion_list_cells[var.curFashionListIndex] then
		var.fashion_list_cells[var.curFashionListIndex]:getWidgetByName("img_selected"):setVisible(false)
	end
	var.fashion_list_cells[listindex]:getWidgetByName("img_selected"):setVisible(true)
	var.curFashionListIndex = listindex;
end

function ContainerCharacter.openPageFashion()
	--local tabhfashion = var.xmlPageFashion:getWidgetByName("tabhfashion")
	--tabhfashion:setSelectedTab(1)
	local guild_name = GameCharacter._mainAvatar:NetAttr(GameConst.net_guild_name)
	if not guild_name or guild_name == "" then
		guild_name = "暂无行会"
	end
	--var.xmlPageFashion:getWidgetByName("lbl_guild_name"):setString(guild_name)

	--ContainerCharacter.freshFashionAttr()
	GameSocket:PushLuaTable("item.chufa.getfashionlook",GameUtilSenior.encode({actionid = "reqfashionData",params={}}))

end



--------------------------------------称号--------------------------------------
function ContainerCharacter.initPageTitle()

	local function updateInnerLooks()
		ContainerCharacter.tryOnTitle()
	end
	var.xmlPageTitle = GUIAnalysis.load("ui/layout/ContainerCharacter_title.uif")
	if var.xmlPageTitle then
		--GameUtilSenior.asyncload(var.xmlPageTitle, "page_role_bg", "ui/image/page_title_bg.png")
		--GameUtilSenior.asyncload(var.xmlPageTitle, "page_title_right_bg", "ui/image/page_fashion_right_bg.png")
		--GameUtilSenior.asyncload(var.xmlPageTitle, "page_fashion_bg", "ui/image/img_fashion_bg.jpg")
		var.xmlPageTitle:align(display.LEFT_BOTTOM, 0, 0):addTo(var.xmlPanel)

		var.xmlPageTitle:getWidgetByName("lbl_role_name"):setString(GameCharacter._mainAvatar:NetAttr(GameConst.net_name))

		local job = GameCharacter._mainAvatar:NetAttr(GameConst.net_job)
		local imgJob = var.xmlPageTitle:getWidgetByName("img_Job")
		local jobres = {"img_role_zhan_delete","img_role_fa_delete","img_role_dao_delete"}
		imgJob:loadTexture(jobres[job-99], ccui.TextureResType.plistType)

		local tabhtitle = var.xmlPageTitle:getWidgetByName("tabhtitle")
		tabhtitle:setItemMargin(0):setTabColor(GameBaseLogic.getColor4(0xefddca),GameBaseLogic.getColor4(0xefddca)):setTabRes("btn_title", "btn_title_sel", ccui.TextureResType.plistType)
		tabhtitle:addTabEventListener(ContainerCharacter.ckickTitleTab)
		
		var.xmlPageTitle:getWidgetByName("title_wear"):addClickEventListener(ContainerCharacter.ckickDressTitleButton)
		

		local btn_info = var.xmlPageTitle:getWidgetByName("btn_info")
		btn_info:setTouchEnabled(true):addTouchEventListener(function(sender,eventType)
			if eventType == ccui.TouchEventType.began then
				GameSocket:dispatchEvent({
					name = GameMessageCode.EVENT_PANEL_ON_ALERT, panel = "tips", visible = true, infoTable = chlblhint,
				})
			elseif eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled  then
				GameSocket:dispatchEvent({
					name = GameMessageCode.EVENT_PANEL_ON_ALERT, panel = "all", visible = false })
			end
		end)
		GameSocket:PushLuaTable("gui.ContainerTitle.onOpenPanel",GameUtilSenior.encode({actionid = "alltitlelist_1"}))
		GameSocket:PushLuaTable("gui.ContainerTitle.onOpenPanel",GameUtilSenior.encode({actionid = "mycurrenttitle"}))
		GameSocket:PushLuaTable("gui.ContainerTitle.onOpenPanel",GameUtilSenior.encode({actionid = "mytitlelist"}))
		updateInnerLooks()
		cc.EventProxy.new(GameSocket, var.xmlPageTitle)
			:addEventListener(GameMessageCode.EVENT_ITEM_CHANGE, ContainerCharacter.freshTitlePage)
			:addEventListener(GameMessageCode.EVENT_AVATAR_CHANGE, updateInnerLooks)

			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA,ContainerCharacter.setTitledata)

	end
end
function ContainerCharacter.setTitledata(event)
	--GameUtilSenior.print_table(event)
	if event.type == "Title" then
		local pData = GameUtilSenior.decode(event.data)
		if pData then
			if pData.cmd == "dress_title" then
				var.title_data= pData.data
			end
		end
	elseif event.type == "ContainerTitle" then
		--print(event.data)
		local data = GameUtilSenior.decode(event.data)
		if data.cmd == "alltitlelist_1" then
			var.title_preview = data.Data;
			GameSocket:PushLuaTable("gui.ContainerTitle.onOpenPanel",GameUtilSenior.encode({actionid = "alltitlelist_2"}))
		end
		if data.cmd == "alltitlelist_2" then
			local data = data.Data
			for i=1,#data,1 do
				var.title_preview[#var.title_preview+1] = data[i]
			end
			GameSocket:PushLuaTable("gui.ContainerTitle.onOpenPanel",GameUtilSenior.encode({actionid = "alltitlelist_3"}))
		end
		if data.cmd == "alltitlelist_3" then
			local data = data.Data
			for i=1,#data,1 do
				var.title_preview[#var.title_preview+1] = data[i]
			end
			GameSocket:PushLuaTable("gui.ContainerTitle.onOpenPanel",GameUtilSenior.encode({actionid = "alltitlelist_4"}))
		end
		if data.cmd == "alltitlelist_4" then
			local data = data.Data
			for i=1,#data,1 do
				var.title_preview[#var.title_preview+1] = data[i]
			end
			GameSocket:PushLuaTable("gui.ContainerTitle.onOpenPanel",GameUtilSenior.encode({actionid = "alltitlelist_5"}))
		end
		if data.cmd == "alltitlelist_5" then
			local data = data.Data
			for i=1,#data,1 do
				var.title_preview[#var.title_preview+1] = data[i]
			end
		end
		if data.cmd == "mytitlelist" then
			var.my_title_preview = data.Data;
			ContainerCharacter.freshTitleAttr()
			ContainerCharacter.ckickTitleTab(var.xmlPageTitle:getWidgetByName("tabhtitle"):getItemByIndex(1))
		end
		if data.cmd == "mycurrenttitle" then
			var.mycurrenttitle = data.Data;
			ContainerCharacter.freshTitleAttr()
			ContainerCharacter.ckickTitleTab(var.xmlPageTitle:getWidgetByName("tabhtitle"):getItemByIndex(1))
		end
		if data.cmd == "titleAttr" then

			ContainerCharacter.showTitleAttr(data.Data)
			--ContainerCharacter.freshTitleAttr()
			
		end
		
	end
end
function ContainerCharacter.freshTitlePage(event)
	local tabhtitle = var.xmlPageTitle:getWidgetByName("tabhtitle")
	--if pageKeys[var.boxTab:getCurIndex()] == "title" then
		-- if tabhtitle:getCurIndex() == table.indexof(titlePos,event.pos) then
			ContainerCharacter.ckickTitleTab(tabhtitle:getItemByIndex(tabhtitle:getCurIndex()))
		-- end
		if table.indexof(titlePos,event.pos)  then
			ContainerCharacter.freshTitleAttr(event)
		end
	--end
end
--显示已装备称号属性
function ContainerCharacter.freshTitleAttr(selectID)
	var.xmlPageTitle:getWidgetByName("image_title"):stopAllActions():setVisible(false)
	if ((selectID~=nil and selectID~="") or (var.mycurrenttitle ~= nil and var.mycurrenttitle ~="")) and var.my_title_preview~=nil and var.my_title_preview~="" then
		for k,val in ipairs(var.my_title_preview) do
			if val.id==var.mycurrenttitle or val.id==selectID then
				local image_title = var.xmlPageTitle:getWidgetByName("image_title")
				
				GameUtilSenior.addEffect(image_title,"spriteEffect",GROUP_TYPE.TITLE,val.res,{x=0,y=-70},false,true)
				image_title:setVisible(true)
			
				--ContainerCharacter.showTitleAttr(val.detail)
				GameSocket:PushLuaTable("gui.ContainerTitle.onOpenPanel",GameUtilSenior.encode({actionid = "titleAttr",typeID=val.type_id}))
				local lbllefttime = var.xmlPageTitle:getWidgetByName("lbllefttime"):hide():stopAllActions()
				local lblleftstr = var.xmlPageTitle:getWidgetByName("lblleftstr"):hide()
				lblleftstr:show()
				lbllefttime:show()
				local sec = val.expire - os.time()
				if val.expire == 0 then
					lbllefttime:setString("永久")
				else
					GameUtilSenior.runCountDown(lbllefttime,sec,function(target,count)
						target:setString(GameUtilSenior.setTimeFormat(count*1000,6))
					end)
				end
			end
		end
	end
end

function ContainerCharacter.showTitleAttr(val)
	local attrList = var.xmlPageTitle:getWidgetByName("attrList"):removeAllItems()
	local model = var.xmlPageTitle:getWidgetByName("model")
	--GameUtilSenior.print_table(val)
	local baseAttrs = {
		{key = "物理攻击：", value = {min = val.dc, max = val.dc2}, color=""},
		{key = "魔法攻击：", value = {min = val.mc, max = val.mc2}, color=""},
		{key = "道士攻击：", value = {min = val.sc, max = val.sc2}, color=""},
		{key = "物理防御：", value = {min = val.ac, max = val.ac2}, color=""},
		{key = "魔法防御：", value = {min = val.mac, max = val.mac2}, color=""},
		{key = "生命上限：", value = val.max_hp, color=""},
		{key = "生命增加比例：", value = val.max_hp_pres, color=""},
		{key = "暴击率：", value = val.special_attr.baoji_prob, color=""},
		{key = "暴击：", value = val.special_attr.baoji_pres, color=""},
		{key = "内功：", value = val.add_power, color=""},
		{key = "幸运值：", value = val.luck, color=""},
		{key = "反弹比例：", value = val.special_attr.fantan_prob, color="#8a059d"},
		{key = "反弹概率：", value = val.special_attr.fantan_pres, color="#3d16d0"},
		{key = "吸血比例：", value = val.special_attr.xixue_prob, color="#36deb8"},
		{key = "吸血概率：", value = val.special_attr.xixue_pres, color="#476986"},
		{key = "麻痹时间：", value = val.special_attr.mabi_dura, color="#57a065"},
		{key = "麻痹概率：", value = val.special_attr.mabi_prob, color="#a8c87a"},
		{key = "护身概率：", value = val.special_attr.dixiao_pres, color="#8c3936"},
		{key = "复原CD时间：", value = val.special_attr.fuyuan_cd, color="#faa74c"},
		{key = "复原概率：", value = val.special_attr.fuyuan_pres, color="#d2ee64"},
		{key = "倍伤倍数：", value = val.special_attr.beishang, color="#38d4b9"},
		{key = "免伤倍数：", value = val.special_attr.mianshang, color="#3537c5"},
		{key = "吸收伤害比例：", value = val.special_attr.xishou_prob, color="#15da88"},
		{key = "吸收伤害概率：", value = val.special_attr.xishou_pres, color="#c43e75"},
		{key = "总体物防比例：", value = val.special_attr.mACRatio, color="#18a335"},
		{key = "总体魔防比例：", value = val.special_attr.mMCRatio, color="#f8a14a"},
		{key = "总体物攻比例：", value = val.special_attr.mDCRatio, color="#9c44a6"},
		{key = "忽视防御比例：", value = val.special_attr.mIgnoreDCRatio, color="#8addf9"},
		{key = "杀人爆率提升：", value = val.special_attr.mPlayDrop, color="#f9f2b6"},
		{key = "怪物爆率提升：", value = val.special_attr.mMonsterDrop, color="#29ed8e"},
		{key = "死亡爆率下降：", value = val.special_attr.mDropProtect, color="#1952a1"},
		{key = "防止麻痹概率：", value = val.special_attr.mMabiProtect, color="#bda134"},
	}
	--print(GameUtilSenior.encode(baseAttrs))
	--GameUtilSenior.print_table(baseAttrs)

	for i,v in ipairs(baseAttrs) do
		if GameUtilSenior.isTable(v.value) then
			if v.value.max > 0 then
				local modeli = model:clone()
				modeli:getWidgetByName("attrName"):setString(v.key)
				modeli:getWidgetByName("attrValue"):setString(v.value.min.."-"..v.value.max)
				attrList:pushBackCustomItem(modeli)
			end
		elseif v.value > 0 then
			if string.find(v.key,"率") ~= nil or string.find(v.key,"例") ~= nil or string.find(v.key,"倍") ~= nil then
				v.value = (v.value / 100).."%"
			end
			local modeli = model:clone()
			if v.color~= nil and v.color~= "" and false then
				--str = str.."<font color="..v.color..">"..v.key..v.value.."</font><br>"
				modeli:getWidgetByName("attrName"):setString("<font color="..v.color..">"..v.key.."</font>")
				modeli:getWidgetByName("attrValue"):setString("<font color="..v.color..">"..v.value.."</font>")
			else
				--str = str..v.key..v.value.."<br>"
				modeli:getWidgetByName("attrName"):setString(v.key)
				modeli:getWidgetByName("attrValue"):setString(v.value)
			end
			attrList:pushBackCustomItem(modeli)
		end
	end
end

function ContainerCharacter.tryOnTitle(titleId)
		--武器
		local img_weapon = var.xmlPageTitle:getChildByName("img_weapon")
	    --设置武器内观
		if not img_weapon then
			img_weapon = cc.Sprite:create()
			img_weapon:addTo(var.xmlPageTitle):setAnchorPoint(cc.p(0.52,0.3)):setPosition(296, 370):setName("img_weapon"):setLocalZOrder(3)
		end
		local weaponDef
		if not GameSocket:getItemDefByPos(GameConst.ITEM_FASHION_CLOTH_POSITION) then
			weaponDef = GameSocket:getItemDefByPos(GameConst.ITEM_WEAPON_POSITION)
		end
		if weaponDef then
			if weaponDef.mResMale~=img_weapon.curWeaponId then				
				img_weapon.curWeaponId=weaponDef.mResMale
			end
		else
			img_weapon:stopAllActions()
			img_weapon:setTexture(nil)
			img_weapon:setVisible(false)
			img_weapon.curWeaponId=nil
		end
		--衣服
		local img_role = var.xmlPageTitle:getChildByName("img_role")
		--设置衣服内观
		if not img_role then
			img_role = cc.Sprite:create()
			img_role:addTo(var.xmlPageTitle):align(display.CENTER, 270, 270):setName("img_role"):setLocalZOrder(2):setVisible(false)
		end
		local clothDef,clothId
		local isFashion = false
		--if GameSocket:getItemDefByPos(GameConst.ITEM_FASHION_CLOTH_POSITION) then
			local fashion = GameCharacter._mainAvatar:NetAttr(GameConst.net_fashion)
			local cloth = GameCharacter._mainAvatar:NetAttr(GameConst.net_cloth)
			if fashion >0 then
				clothId = fashion
				isFashion = true
			else
				clothDef = GameSocket:getItemDefByPos(GameConst.ITEM_CLOTH_POSITION)
				if clothDef then
					clothId = clothDef.mResMale
				else 
					clothId = cloth
				end
			end
		--end
		if not clothId then
			local gender = GameCharacter._mainAvatar:NetAttr(GameConst.net_gender)
			local luoti= gender==200 and  20000 or 20000
			clothId = luoti
		end
		
		if titleId then
			for k,v in ipairs(var.title_preview) do
			
				if tonumber(v.type_id)==tonumber(titleId) then
				
					local image_title = var.xmlPageTitle:getWidgetByName("image_title")
					
					image_title:removeChildByName("spriteEffect")
					GameUtilSenior.addEffect(image_title,"spriteEffect",GROUP_TYPE.TITLE,v.res,{x=0,y=-70},false,true)
					image_title:setVisible(true)
					
					GameSocket:PushLuaTable("gui.ContainerTitle.onOpenPanel",GameUtilSenior.encode({actionid = "titleAttr",typeID=v.type_id}))
					--ContainerCharacter.showTitleAttr(v)
				end
			end
			for k,v in ipairs(var.my_title_preview) do
				if tonumber(v.id)==tonumber(titleId) then

					local image_title = var.xmlPageTitle:getWidgetByName("image_title")
					
					print("=================",v.res)
					image_title:removeChildByName("spriteEffect")
					GameUtilSenior.addEffect(image_title,"spriteEffect",GROUP_TYPE.TITLE,v.res,false,false,true)
					image_title:setVisible(true)
					
					GameSocket:PushLuaTable("gui.ContainerTitle.onOpenPanel",GameUtilSenior.encode({actionid = "titleAttr",typeID=v.type_id}))
					--ContainerCharacter.showTitleAttr(v)
					
					local lbllefttime = var.xmlPageTitle:getWidgetByName("lbllefttime"):hide():stopAllActions()
					local lblleftstr = var.xmlPageTitle:getWidgetByName("lblleftstr"):hide()
					lblleftstr:show()
					lbllefttime:show()
					local sec = v.expire - os.time()
					if v.expire == 0 then
						lbllefttime:setString("永久")
					else
						GameUtilSenior.runCountDown(lbllefttime,sec,function(target,count)
							target:setString(GameUtilSenior.setTimeFormat(count*1000,6))
						end)
					end
				end
			end
			
		end
		if clothId~=img_role.curClothId then
			
			img_role:removeChildByName("spriteEffect")
			if isFashion then
				GameUtilSenior.addEffect(img_role,"spriteEffect",GROUP_TYPE.FDRESS_REVIEW,clothId,{x=-122,y=330},false,true)
			else
				GameUtilSenior.addEffect(img_role,"spriteEffect",GROUP_TYPE.CLOTH_REVIEW,clothId,{x=-122,y=330},false,true)
			end
			
			img_role.curClothId = clothId
		end

	--注释翅膀
	-- elseif typ == 3 then
	-- 	local img_wing = var.xmlPageTitle:getChildByName("img_wing")
	-- 	--设置翅膀内观
	-- 	if not img_wing then
	-- 		img_wing = cc.Sprite:create()
	-- 		img_wing:addTo(var.xmlPageTitle):align(display.CENTER, 306, 370):setName("img_wing"):setLocalZOrder(1)
	-- 	end
	-- 	local wingDef
	-- 	if typeId then
	-- 		wingDef = GameSocket:getItemDefByID(typeId)
	-- 	else
	-- 		wingDef = {mIconID = GameCharacter._mainAvatar:NetAttr(GameConst.net_wing)}
	-- 	end
	-- 	if wingDef then
	-- 		if wingDef.mIconID ~= img_wing.curwingId then
	-- 			local filepath = "image/wing/"..wingDef.mIconID..".png"
	-- 			asyncload_callback(filepath, img_wing, function(filepath, texture)
	-- 				img_wing:setVisible(true)
	-- 				img_wing:setTexture(filepath)
	-- 			end)
	-- 			img_wing.curwingId = wingDef.mIconID
	-- 		end
	-- 	else
	-- 		img_wing:setTexture(nil)
	-- 		img_wing:setVisible(false)
	-- 		img_wing.curwingId=nil
	-- 	end
	-- end
end
--function ContainerCharacter.ckickDressTitleButton( sender )
function ContainerCharacter.ckickDressTitleButton(  )
	--GameSocket:PushLuaTable("gui.ContainerTitle.onOpenPanel",GameUtilSenior.encode({actionid = "settitle",titleid = sender.titleid}))
	if var.curTitleListIndex~=nil and tonumber(var.curTitleListIndex)>0 then
		GameSocket:PushLuaTable("gui.ContainerTitle.onOpenPanel",GameUtilSenior.encode({actionid = "settitle",titleid = var.my_title_preview[var.curTitleListIndex].id}))
	else
		GameSocket:PushLuaTable("gui.ContainerTitle.onOpenPanel",GameUtilSenior.encode({actionid = "settitle",titleid = 0}))
		ContainerCharacter.ckickTitleTab(var.xmlPageTitle:getWidgetByName("tabhtitle"):getItemByIndex(1))
	end
end

--刷新称号列表
function ContainerCharacter.ckickTitleTab(tab)
	--if var.mycurrenttitle == nil or var.title_preview==nil then
	--	return
	--end
	ContainerCharacter.tryOnTitle();
	local function pushSelectItem(item)
		if item and item.tagTitleOnlyId ~=nil and item.tagTitleOnlyId ~="" and item.tagTitleOnlyId~=0 then
			ContainerCharacter.TryTitleShow(item.tagTitleOnlyId,item.tag);
		elseif item and item.tagTitleId ~=nil and item.tagTitleId ~="" then
			--ContainerCharacter.tryOnTitle(item.tagTitleId)
			--print(item.tagTitleId)
			ContainerCharacter.TryTitleShow(item.tagTitleOnlyId,item.tag);
		end
	end
	local tag = tab:getTag()
	var.title_list_cells={};
	var.curTitleListIndex = 0;
	if tag == 1 then
		--local data = {}
		--for k,v in pairs(GameSocket.mItems) do
		--	if k>=GameConst.ITEM_FASHIONDEPOT_BEGIN and k<=GameConst.ITEM_FASHIONDEPOT_BEGIN+GameConst.ITEM_FASHIONSIZEE then
		--	print("v.mTypeID",v.mTypeID)
		--		if GameBaseLogic.IsSameTitle(v.mTypeID,titlePos[tag]) then
		--			table.insert(data,v)
		--		end
		--	end
		--end
		--local DressItem = GameSocket:getNetItem(titlePos[tag])
		--local lbllefttime = var.xmlPageTitle:getWidgetByName("lbllefttime"):hide():stopAllActions()
		--local lblleftstr = var.xmlPageTitle:getWidgetByName("lblleftstr"):hide()
		--if DressItem then
		--	lblleftstr:show()
		--	lbllefttime:show()
		--	table.insert(data,1,DressItem)
		--	-- local itemDef = GameSocket:getItemDefByID(DressItem.mTypeID)
		--	local sec = 0
		--	-- if itemDef then
		--		sec = DressItem.mLastTime - os.time() + DressItem.mCreateTime
		--	-- end
		--	if DressItem.mLastTime == 0 then
		--		lbllefttime:setString("永久")
		--	else
		--		GameUtilSenior.runCountDown(lbllefttime,sec,function(target,count)
		--			target:setString(GameUtilSenior.setTimeFormat(count*1000,6))
		--		end)
		--	end
		--end

		--新版本称号列表开始
		if var.my_title_preview ==nil then
			var.my_title_preview = {}
		end
		
		local currentIndex = 1
		
		if var.mycurrenttitle~=0 and var.mycurrenttitle~="" and var.mycurrenttitle~=nil then
			currentIndex = tonumber(var.mycurrenttitle)
		end
		
		if currentIndex==1 then
			if #var.my_title_preview>0 then
				currentIndex = var.my_title_preview[1].id
			end
		end
		
		local items={}
		local list_btn = var.xmlPageTitle:getWidgetByName("list_btn"):setVisible(true)
		list_btn:reloadData(#var.my_title_preview,function( subItem )
			table.insert(items,subItem)
			local function  showMapDetail( sender )
				for i,v in ipairs(items) do
					v:getWidgetByName("title_btn_font"):loadTexture(string.format("ContainerTitle_left_btn_%d_1.png",(tonumber(v:getWidgetByName("title_btn_font").titleTypeid)-60000000)),ccui.TextureResType.plistType)
					--v:getWidgetByName("title_btn_font"):loadTexturePressed(string.format("ContainerTitle_left_btn_%d_3.png",(tonumber(v:getWidgetByName("title_btn_font").titleTypeid)-60000000)),ccui.TextureResType.plistType)
					v:getWidgetByName("title_btn"):loadTexture("ContainerTitle_2.png",ccui.TextureResType.plistType)
					v:getWidgetByName("title_btn_animal"):setVisible(false)
				end
				subItem:getWidgetByName("title_btn"):loadTexture("ContainerTitle_3.png",ccui.TextureResType.plistType)
				subItem:getWidgetByName("title_btn_font"):loadTexture(string.format("ContainerTitle_left_btn_%d_2.png",(tonumber(var.my_title_preview[subItem.tag].type_id)-60000000)),ccui.TextureResType.plistType)
				--subItem:getWidgetByName("title_btn_font"):loadTexturePressed(string.format("ContainerTitle_left_btn_%d_2.png",(tonumber(var.my_title_preview[subItem.tag].type_id)-60000000)),ccui.TextureResType.plistType)
				subItem:getWidgetByName("title_btn_animal"):setVisible(true)
				var.xmlPageTitle:getWidgetByName("title_wear"):loadTextureNormal("title_wear.png",ccui.TextureResType.plistType)
				pushSelectItem(sender:getWidgetByName("title_btn_font"))
				if var.mycurrenttitle==var.my_title_preview[subItem.tag].id then
					var.xmlPageTitle:getWidgetByName("title_wear"):loadTextureNormal("title_undress.png",ccui.TextureResType.plistType)
					var.curTitleListIndex = 0
				end
			end
			subItem:getWidgetByName("title_btn_font"):loadTexture(string.format("ContainerTitle_left_btn_%d_1.png",(tonumber(var.my_title_preview[subItem.tag].type_id)-60000000)),ccui.TextureResType.plistType)
			subItem:getWidgetByName("title_btn"):loadTexture("ContainerTitle_2.png",ccui.TextureResType.plistType)
			subItem:getWidgetByName("title_btn_animal"):setVisible(false)
			--subItem:getWidgetByName("title_btn_font"):loadTexturePressed(string.format("ContainerTitle_left_btn_%d_3.png",(tonumber(var.my_title_preview[subItem.tag].type_id)-60000000)),ccui.TextureResType.plistType)
			subItem:getWidgetByName("title_btn_font").titleid = var.my_title_preview[subItem.tag].id
			subItem:getWidgetByName("title_btn_font").tagTitleOnlyId = var.my_title_preview[subItem.tag].id
			subItem:getWidgetByName("title_btn_font").titleTypeid = var.my_title_preview[subItem.tag].type_id
			subItem:getWidgetByName("title_btn_font").tagTitleId = var.my_title_preview[subItem.tag].type_id
			subItem:getWidgetByName("title_btn_font").tag = subItem.tag
			--GUIFocusPoint.addUIPoint(subItem:getWidgetByName("title_btn_font"), showMapDetail)
			
			subItem:setTouchEnabled(true)
			subItem:addClickEventListener(function ( sender )
				currentIndex = sender:getWidgetByName("title_btn_font").tagTitleOnlyId
				showMapDetail(sender)
			end)
			
			--动画
			local title_animal = subItem:getWidgetByName("title_btn_animal")
			local startNum = 50
			local function startShowTitleBg()
				
				title_animal:loadTexture(string.format("ContainerTitle_%d.png",startNum), ccui.TextureResType.plistType)
				
				startNum= startNum+1
				if startNum ==112 then
					startNum =50
				end
			end
			title_animal:stopAllActions()
			title_animal:runAction(cca.repeatForever(cca.seq({cca.delay(0.01),cca.cb(startShowTitleBg)}),tonumber(63)))
			
			if tonumber(subItem:getWidgetByName("title_btn_font").tagTitleOnlyId)==tonumber(currentIndex) then
				showMapDetail(subItem)
			end
		end)
		
		
		--[[
		local titleList = var.xmlPageTitle:getWidgetByName("titleList")
		if var.my_title_preview ==nil then
			var.my_title_preview = {}
		end
		titleList:reloadData(#var.my_title_preview,function(subItem)
			local d = var.my_title_preview[subItem.tag]
			--local itemDef = GameSocket:getItemDefByID(d.mTypeID)
			--GUIItem.getItem({
			--	parent = subItem:getWidgetByName("icon"),
			--	typeId = d.mTypeID,
			--	iconType = GameConst.ICONTYPE.NOTIP,
			--	callBack = function()
			--		--ContainerCharacter.tryOnTitle(d.mTypeID)--点击icon
			--		ContainerCharacter.TryTitleShow(d.mTypeID,subItem.tag);
			--	end
			--});
			
			
			local icon = subItem:getWidgetByName("icon")
			local icon_img = icon:getChildByName("icon_img")
			if not icon_img then
				local pSize = icon:getContentSize()
				icon_img = cc.Sprite:create()
				icon_img:addTo(icon):align(display.CENTER, pSize.width * 0.5, pSize.height * 0.5):setName("icon_img"):setLocalZOrder(2)
			end
			local filepath = "image/icon/"..d.icon_id..".png"
			asyncload_callback(filepath, icon_img, function(filepath, texture)
				icon_img:setVisible(true)
				icon_img:setTexture(filepath)
			end)

			subItem:getWidgetByName("itemname"):setString(d.name)
			local btn_dress = subItem:getWidgetByName("btn_dress")
			if d.id~=var.mycurrenttitle then
				btn_dress.titleid = d.id
			else
				btn_dress.titleid = ""
			end
			btn_dress:addClickEventListener(ContainerCharacter.ckickDressTitleButton)
			btn_dress:setTitleText(d.id==var.mycurrenttitle and "卸下" or "穿戴"):setVisible(true)
			local hasDress = subItem:getWidgetByName("hasDress")
			hasDress:setVisible(d.id==var.mycurrenttitle)
			subItem:getWidgetByName("img_selected"):setVisible(false);
			subItem:getWidgetByName("lbl_title_remark"):setVisible(false)
			subItem.tagTitleId = d.type_id;
			subItem.tagTitleOnlyId = d.id;
			subItem:setTouchEnabled(true)
			GUIFocusPoint.addUIPoint(subItem, pushSelectItem)

			local needCell = var.title_list_cells[subItem.tag];
			if not needCell then
				needCell = subItem;
				needCell:setName(subItem:getName()..subItem.tag);
			end
			var.title_list_cells[subItem.tag] = needCell;

		end)
		]]--
	elseif tag == 2 then
		--GameUtilSenior.print_table(#var.title_preview)
		var.xmlPageTitle:getWidgetByName("titleList"):reloadData(#var.title_preview,function(subItem)
			--GameUtilSenior.print_table(subItem)
		
			local previewdata = var.title_preview[subItem.tag]
			
			local icon = subItem:getWidgetByName("icon")
			local icon_img = icon:getChildByName("icon_img")
			if not icon_img then
				local pSize = icon:getContentSize()
				icon_img = cc.Sprite:create()
				icon_img:addTo(icon):align(display.CENTER, pSize.width * 0.5, pSize.height * 0.5):setName("icon_img"):setLocalZOrder(2)
			end
			local filepath = "image/icon/"..previewdata.icon_id..".png"
			asyncload_callback(filepath, icon_img, function(filepath, texture)
				icon_img:setVisible(true)
				icon_img:setTexture(filepath)
			end)
			
			subItem:getWidgetByName("img_selected"):setVisible(false);
			subItem:getWidgetByName("itemname"):setString(previewdata.name)
			subItem:getWidgetByName("btn_dress"):setVisible(false)
			subItem:getWidgetByName("hasDress"):setVisible(false)
			subItem:getWidgetByName("lbl_title_remark"):setVisible(true):setString(previewdata.source)
			subItem.tagTitleId = previewdata.type_id;
			subItem.tagTitleOnlyId = 0;
			subItem:setTouchEnabled(true)
			GUIFocusPoint.addUIPoint(subItem, pushSelectItem)

			local needCellpre = var.title_list_cells[subItem.tag];
			if not needCellpre then
				needCellpre = subItem;
				needCellpre:setName(subItem:getName()..subItem.tag);
			end
			var.title_list_cells[subItem.tag] = needCellpre;

		end)
	end
end

function ContainerCharacter.TryTitleShow(titleid,listindex)
	ContainerCharacter.tryOnTitle(titleid);
	--[[
	if var.curTitleListIndex > 0 and var.title_list_cells[var.curTitleListIndex] then
		var.title_list_cells[var.curTitleListIndex]:getWidgetByName("img_selected"):setVisible(false)
	end
	var.title_list_cells[listindex]:getWidgetByName("img_selected"):setVisible(true)
	]]--
	var.curTitleListIndex = listindex;
end

function ContainerCharacter.openPageTitle()
	local tabhtitle = var.xmlPageTitle:getWidgetByName("tabhtitle")
	tabhtitle:setSelectedTab(1)
	local guild_name = GameCharacter._mainAvatar:NetAttr(GameConst.net_guild_name)
	if not guild_name or guild_name == "" then
		guild_name = "暂无行会"
	end
	
	
	--
	ContainerCharacter:updateGameMoney(var.xmlPageTitle)
	--
	
	--var.xmlPageTitle:getWidgetByName("lbl_guild_name"):setString(guild_name)

	ContainerCharacter.freshTitleAttr()
	GameSocket:PushLuaTable("item.chufa.gettitlelook",GameUtilSenior.encode({actionid = "reqtitleData",params={}}))

end

--------------------------------------转生--------------------------------------
function ContainerCharacter.openPageReborn()
	GameSocket:PushLuaTable("gui.PanelZhuanSheng.handlePanelData",GameUtilSenior.encode({actionid = "reqZsData",params={}}))
end
function ContainerCharacter.initPageReborn()
	--刷新转生属性
	local function updateRebornAttr(data)
		-- print("//////////////updateRebornAttr////////////////", data)
		local btnUp = var.xmlPageReborn:getWidgetByName("btn_reborn")
		if not data then return end
		--var.xmlPageReborn:getWidgetByName("lbl_need_exp"):setString(data.needExp)
		var.xmlPageReborn:getWidgetByName("lbl_need_exp"):setString(data.needItem)
		if data.ownExp>=data.needExp then
			var.xmlPageReborn:getWidgetByName("lbl_cur_exp"):setString(data.ownExp):setColor(GameBaseLogic.getColor(0xB2A58B))
			GameUtilSenior.addHaloToButton(btnUp, "btn_normal_light13")
		else
			var.xmlPageReborn:getWidgetByName("lbl_cur_exp"):setString(data.ownExp):setColor(GameBaseLogic.getColor(0xEF2F00))
			btnUp:removeChildByName("img_bln")
		end
		var.xmlPageReborn:getWidgetByName("lbl_cur_level"):setString(data.level)
		var.xmlPageReborn:getWidgetByName("lbl_next_level"):setString(data.level-1)
		var.xmlPageReborn:getWidgetByName("lbl_get_exp"):setString(data.exchangeExp)
		var.xmlPageReborn:getWidgetByName("lbl_need_money"):setString(data.needMoney)
		var.xmlPageReborn:getWidgetByName("lbl_times_remain"):setString(data.yuTimes)

		var.xmlPageReborn:getWidgetByName("lbl_cur_dc"):setString(data.curData.dc.."-"..data.curData.dcmax)
		var.xmlPageReborn:getWidgetByName("lbl_cur_ac"):setString(data.curData.ac.."-"..data.curData.acmax)
		var.xmlPageReborn:getWidgetByName("lbl_cur_sc"):setString(data.curData.sc.."-"..data.curData.scmax)
		var.xmlPageReborn:getWidgetByName("lbl_cur_mc"):setString(data.curData.mc.."-"..data.curData.mcmax)
		var.xmlPageReborn:getWidgetByName("lbl_cur_mac"):setString(data.curData.mac.."-"..data.curData.macmax)
		local mBeiShang = 0
		if data.curData.mBeiShang~=nil and tonumber(data.curData.mBeiShang)~=0 then
			mBeiShang = data.curData.mBeiShang/10000.0
		end
		var.xmlPageReborn:getWidgetByName("lbl_cur_mbeishang"):setString(mBeiShang)


		var.xmlPageReborn:getWidgetByName("lbl_next_dc"):setString(data.nextData.dc.."-"..data.nextData.dcmax)
		var.xmlPageReborn:getWidgetByName("lbl_next_ac"):setString(data.nextData.ac.."-"..data.nextData.acmax)
		var.xmlPageReborn:getWidgetByName("lbl_next_sc"):setString(data.nextData.sc.."-"..data.nextData.scmax)
		var.xmlPageReborn:getWidgetByName("lbl_next_mc"):setString(data.nextData.mc.."-"..data.nextData.mcmax)
		var.xmlPageReborn:getWidgetByName("lbl_next_mac"):setString(data.nextData.mac.."-"..data.nextData.macmax)
		local nmBeiShang = 0
		if data.nextData.mBeiShang~=nil and tonumber(data.nextData.mBeiShang)~=0 then
			nmBeiShang = data.nextData.mBeiShang/10000.0
		end
		var.xmlPageReborn:getWidgetByName("lbl_next_mbeishang"):setString(nmBeiShang)

		local job = GameCharacter._mainAvatar:NetAttr(GameConst.net_job)
		if  job== GameConst.JOB_ZS then
			var.xmlPageReborn:getWidgetByName("lbl_cur_maxhp"):setString(data.curData.zHp)
			var.xmlPageReborn:getWidgetByName("lbl_next_maxhp"):setString(data.nextData.zHp)
		elseif job== GameConst.JOB_FS then
			var.xmlPageReborn:getWidgetByName("lbl_cur_maxhp"):setString(data.curData.fHp)
			var.xmlPageReborn:getWidgetByName("lbl_next_maxhp"):setString(data.nextData.fHp)
		else
			var.xmlPageReborn:getWidgetByName("lbl_cur_maxhp"):setString(data.curData.dHp)
			var.xmlPageReborn:getWidgetByName("lbl_next_maxhp"):setString(data.nextData.dHp)
		end

		var.zsLevel:setString(data.curLevel)

		if data.up then
		--刷新动画对象
			local fireworks = cc.Sprite:create():addTo(var.xmlPanel):pos(278.83, 485)
			--local animate = cc.AnimManager:getInstance():getPlistAnimateAsync(fireworks,4,50015,4,1)
			GameUtilSenior.addEffect(fireworks,"spriteEffect",GROUP_TYPE.EFFECT,50015,false,false,true)
		end
	end
	--刷新转生商店
	local function updateRebornShop()
		local function pushBuyButton(sender)
			GameSocket:PushLuaTable("gui.PanelZhuanSheng.handlePanelData", GameUtilSenior.encode({actionid = "danBuy", params={index=sender.storeId}}))
		end

		local function updateShop(item)
			local itemData = var.shopData[item.tag]
			item:getWidgetByName("lbl_name"):setString(itemData.name)
			item:getWidgetByName("lbl_price"):setString(itemData.money)
			local awardItem=item:getWidgetByName("icon")
			local param={parent=awardItem , typeId=itemData.id}
			GUIItem.getItem(param)

			local btnBuy = item:getWidgetByName("btn_buy")
			btnBuy.storeId=itemData.storeId
			GUIFocusPoint.addUIPoint(btnBuy , pushBuyButton)
			GUIAnalysis.attachEffect(btnBuy,"outline(0e0600,1)")
		end
		local listBuy = var.xmlPageReborn:getWidgetByName("list_buy")
		listBuy:reloadData(#var.shopData, updateShop)
	end

	local function onPanelData(event)
		if event.type == "PanelZhuanSheng" then
			local data = GameUtilSenior.decode(event.data)
			if data.cmd =="senderShopData" then
				var.shopData={}
				var.shopData = data.data
				updateRebornShop()
			elseif data.cmd=="updateZhuanSheng" then
				updateRebornAttr(data)
			end
		end
	end

	local function initRebornButtons()
		local rebornButtons = {"btn_reborn","btn_convert"}
		local function pushRebornButtons(sender)
			local senderName = sender:getName()
			if senderName=="btn_reborn" then
				GameSocket:PushLuaTable("gui.PanelZhuanSheng.handlePanelData",GameUtilSenior.encode({actionid = "reqZhuanSheng",params={}}))
			elseif senderName=="btn_convert" then
				GameSocket:PushLuaTable("gui.PanelZhuanSheng.handlePanelData",GameUtilSenior.encode({actionid = "exchangeExp",params={}}))
			end
		end
		local btnReborn
		for _,v in ipairs(rebornButtons) do
			btnReborn = var.xmlPageReborn:getWidgetByName(v)
			if btnReborn then
				GUIFocusPoint.addUIPoint(btnReborn, pushRebornButtons)
			end
		end
	end

	var.xmlPageReborn = GUIAnalysis.load("ui/layout/ContainerCharacter_reborn.uif")
	if var.xmlPageReborn then
		GameUtilSenior.asyncload(var.xmlPageReborn, "page_reborn_bg", "ui/image/page_reborn_bg.jpg")
		var.xmlPageReborn:align(display.LEFT_BOTTOM, 0, 0):addTo(var.xmlPanel)
		var.zsLevel= display.newBMFontLabel({font = "image/typeface/num_23.fnt",})
			:addTo(var.xmlPageReborn)
			:align(display.LEFT_BOTTOM, 340,463)
			:setString("0")

		initRebornButtons()
		cc.EventProxy.new(GameSocket,var.xmlPageReborn)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, onPanelData)

		GameSocket:PushLuaTable("gui.PanelZhuanSheng.handlePanelData",GameUtilSenior.encode({actionid = "reqDanData",params={}}))
	end
end

--------------------------------------内功--------------------------------------
function ContainerCharacter.initPageInnerPower()

	local function runAmination(params)
		local target = params.target
		local animateId = params.animateId
		local times = checknumber(params.times)
		local callBack = params.callBack
		local pos = params.pos or cc.p(0,0)
		local scale = params.scale or 1
		local anchor = params.anchor or cc.p(0.5,0.5)

		local sprite = target:getChildByName(animateId)
		if not sprite then
			sprite = cc.Sprite:create():addTo(target)
			:setName(animateId)
		end
		sprite:setPosition(pos):setScale(scale):setAnchorPoint(anchor)
		sprite:stopAllActions()
		local animate = cc.AnimManager:getInstance():getPlistAnimate(4,animateId,4,4,false,false,0,function(animate,shouldDownload)
							if times ==0 then
								sprite:runAction(cca.repeatForever(animate))
							else
								sprite:runAction(cca.seq({
									cca.rep(animate,times),
									cca.cb(function()
										if type(callBack) == "function" then callBack() end
									end),
									cca.removeSelf()
								}))
							end
							if shouldDownload==true then
								sprite:release()
							end
						end,
						function(animate)
							sprite:retain()
						end)
		
	end

	local function updateInnerPowerPage(pData)
		local Data = pData.Data
		local level = pData.level
		local expPool =pData.expPool
		local job = GameCharacter._mainAvatar:NetAttr(GameConst.net_job)
		local val = {"valWarrior","valMage","valPriests"}
		var.xmlPageInnerPower:getWidgetByName("lbl_power_value"):setString(Data[val[job-99]])
		-- print("updateInnerPower", var.xmlPageInnerPower:getWidgetByName("lbl_reduce_injury"), Data.percent)
		var.xmlPageInnerPower:getWidgetByName("lbl_reduce_injury"):setString((Data.dtr/100).."%")
		local lbl_min = var.xmlPageInnerPower:getWidgetByName("lbl_min"):setString(expPool)
		local lbl_max = var.xmlPageInnerPower:getWidgetByName("lbl_max"):setString(Data.exp)

		local progressBar = var.xmlPageInnerPower:getWidgetByName("progressBar")
		var.xmlPageInnerPower.runanimate = false

		if var.xmlPageInnerPower.init then
			progressBar:setPercent(expPool,Data.exp)
			if expPool>=Data.exp and not pData.up then
				runAmination({target = progressBar, animateId = 60014, scale = 1.2 }) -- 可以升级特效
			end
		elseif pData.up then
			if progressBar:getChildByName("60014") then
				progressBar:getChildByName("60014"):removeFromParent()
			end
			progressBar:stopAllActions():setPercent(0,Data.exp):setLabelVisible(false)
			local barwidth = progressBar:getContentSize().width
			runAmination({
				target = progressBar,
				animateId = 60016,
				pos = cc.p(90-barwidth/2,2),
				times = 100,
				anchor = cc.p(0.5,0.5)
			}) -- 升级特效
			local animate60016 = progressBar:getChildByName("60016"):hide()

			progressBar:setPerUnitCallBack(function(bar)
				var.xmlPageInnerPower.runanimate = true
				animate60016 = progressBar:getChildByName("60016")
				if animate60016 then
					local layoutwidth = progressBar:getChildByName("layout"):getContentSize().width
					local posX = GameUtilSenior.bound(-barwidth/2, layoutwidth-barwidth/2+3, barwidth/2-20)
					animate60016:setPosition(cc.p(posX,2)):setVisible(posX>90-barwidth/2)
				end
			end)
			local animateFather = var.xmlPageInnerPower:getWidgetByName("animateFather")
			runAmination({target = animateFather,animateId = 60015,times=1});--球上面特效
			progressBar:setPercentWithAnimation(Data.exp,Data.exp,function()
				if expPool>=Data.exp then
					GameSocket:PushLuaTable("gui.ContainerInnerPower.onOpenPanel",GameUtilSenior.encode({actionid = "upgrade"}))
				else
					progressBar:setPercent(0, Data.exp)
					local animate60016 = progressBar:getChildByName("60016")
					if animate60016 then
						animate60016:removeFromParent()
					end
					progressBar:setPercentWithAnimation(expPool,Data.exp,function()
					end)
				end
			end)
		else
			if not progressBar:isRunning() then
				progressBar:setPercent(expPool,Data.exp)
				local animate60016 = progressBar:getChildByName("60016")
				if animate60016 then
					animate60016:removeFromParent()
				end
				if expPool>=Data.exp and not pData.up then
					runAmination({target = progressBar, animateId = 60014, scale = 1.2 }) -- 可以升级特效
				end
			end
		end
		local btn_upgrade = var.xmlPageInnerPower:getWidgetByName("btn_upgrade")
		if expPool>=Data.exp then
			GameUtilSenior.addHaloToButton(btn_upgrade, "btn_normal_light3")
		elseif btn_upgrade:getWidgetByName(("img_bln")) then
			btn_upgrade:removeChildByName("img_bln")
		end
		var.xmlPageInnerPower.init = false
		var.xmlPageInnerPower.lbl_level:setString(level)

	end

	local function onPanelData(event)
		if event.type =="ContainerInnerPower" then
			local pData = GameUtilSenior.decode(event.data)
			if pData and pData.cmd =="update" then
				if not var.xmlPageInnerPower then return end
				updateInnerPowerPage(pData)
			end
		end
	end

	var.xmlPageInnerPower = GUIAnalysis.load("ui/layout/ContainerCharacter_innerPower.uif")
	if var.xmlPageInnerPower then
		var.xmlPageInnerPower:align(display.LEFT_BOTTOM, 0, 0):addTo(var.xmlPanel)

		var.xmlPageInnerPower.init = true

		GameSocket:PushLuaTable("gui.ContainerInnerPower.onOpenPanel",GameUtilSenior.encode({actionid = "fresh"}))
		var.xmlPageInnerPower:getWidgetByName("progressBar"):getLabel():setPositionY(13)

		local btnUpgrade = var.xmlPageInnerPower:getWidgetByName("btn_upgrade")
		var.xmlPageInnerPower.runanimate = false
		btnUpgrade:addClickEventListener(function(sender)
			if not var.xmlPageInnerPower.runanimate then
				GameSocket:PushLuaTable("gui.ContainerInnerPower.onOpenPanel",GameUtilSenior.encode({actionid = "upgrade"}))
			end
		end)

		if not var.xmlPageInnerPower.lbl_level then
			var.xmlPageInnerPower.lbl_level = display.newBMFontLabel({font = "image/typeface/num_24.fnt",}):addTo(var.xmlPageInnerPower):align(display.CENTER_LEFT,330, 118):setName("lbl_level"):setString("0")
		end

		var.xmlPageInnerPower:getWidgetByName("progressBar"):setLabelVisible(false)
		local animateFather = var.xmlPageInnerPower:getWidgetByName("animateFather"):setScale(0.75)
		if not animateFather:getChildByName("animate50013") then
			runAmination({target = animateFather,animateId = 50013});--球上面特效
		end


		cc.EventProxy.new(GameSocket,var.xmlPageInnerPower)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, onPanelData)

	end
end

--------------------------------------宝石--------------------------------------
local tableShop = {
	[1]={id=25010001,name="攻击宝石",vcoin=100},
	[2]={id=25020001,name="物防宝石",vcoin=100},
	[3]={id=25030001,name="魔防宝石",vcoin=100},
	[4]={id=25040001,name="生命宝石",vcoin=100},
	[5]={id=25050001,name="魔法宝石",vcoin=100},
}
-- GEM_TYPE_HOLY = 1,
-- GEM_TYPE_CRI_PROB = 2,
-- GEM_TYPE_CRI = 3,
-- GEM_TYPE_ATTACK = 4,
-- GEM_TYPE_AC = 5,
-- GEM_TYPE_MAC = 6,
-- GEM_TYPE_HP = 7,
-- GEM_TYPE_MP = 8,
local gemConf = {
	{offSet = GameConst.GEM_ATTACK_OFFSET_POSITION, 	gemType = GameConst.GEM_TYPE_ATTACK},
	{offSet = GameConst.GEM_HP_OFFSET_POSITION,		gemType = GameConst.GEM_TYPE_HP},
	{offSet = GameConst.GEM_MP_OFFSET_POSITION,		gemType = GameConst.GEM_TYPE_MP},
	{offSet = GameConst.GEM_AC_OFFSET_POSITION,		gemType = GameConst.GEM_TYPE_AC},
	{offSet = GameConst.GEM_MAC_OFFSET_POSITION,		gemType = GameConst.GEM_TYPE_MAC},
	{offSet = GameConst.GEM_SPECIAL_OFFSET_POSITION,	gemType = {GameConst.GEM_TYPE_HOLY, GameConst.GEM_TYPE_CRI_PROB, GameConst.GEM_TYPE_CRI}},
}

--对应部位需要的女神重数
local openNeed = {}
local nSLevel = 0--女神重数
local noShowTip=false

local gemDespTable ={
	[1]="<font color=#E7BA52 size=18>宝石总属性：</font>",
}

function ContainerCharacter.initPageGem()
	--刷新战力
	local function updateFightNum()
		var.fightNum:setString(GameSocket.mCharacter.mFightPoint)
	end

	local function updateCheckAutoVcoin()
		local btnAutoVcoin = var.xmlPageGem:getWidgetByName("btn_auto_vcoin")

		btnAutoVcoin:addClickEventListener(function (sender)
			sender:loadTextureNormal( (var.gemAutoVcoin and "btn_checkbox_s_has_bg") or "btn_checkbox", ccui.TextureResType.plistType)
		end)
		btnAutoVcoin:loadTextureNormal( (var.gemAutoVcoin and "btn_checkbox_s_has_bg") or "btn_checkbox", ccui.TextureResType.plistType)
	end

	-- 宝石镶嵌
	local function insetGem(gem_pos)
		-- print("////////////////insetGem////////////////", gem_pos)
		GameSocket:PushLuaTable("gui.ContainerDiamond.onPanelData", GameUtilSenior.encode({actionid = "insetGem", equipPos = var.mSelectedEquip, gemPos = gem_pos}))
	end

	local function undressGem(gem_pos)
		-- print("////////////////undressGem////////////////", gem_pos)
		GameSocket:PushLuaTable("gui.ContainerDiamond.onPanelData", GameUtilSenior.encode({actionid = "undressGem", gemPos = gem_pos}))
	end

	local function gemDesp(data)
		gemDespTable={
			[1]="<font color=#E7BA52 size=18>宝石总属性：</font>",
		}
		if data then
			if data[3].wgmax>0 then
				local str = "<font color=#f1e8d0>物理攻击："..data[3].wgmin.."-"..data[3].wgmax.."</font>"
				table.insert(gemDespTable,str)
			end
			if data[4].mgmax>0 then
				local str = "<font color=#f1e8d0>魔法攻击："..data[4].mgmin.."-"..data[4].mgmax.."</font>"
				table.insert(gemDespTable,str)
			end
			if data[5].dgmax>0 then
				local str = "<font color=#f1e8d0>道术攻击："..data[5].dgmin.."-"..data[5].dgmax.."</font>"
				table.insert(gemDespTable,str)
			end
			if data[1].wfmax>0 then
				local str = "<font color=#f1e8d0>物理防御："..data[1].wfmin.."-"..data[1].wfmax.."</font>"
				table.insert(gemDespTable,str)
			end
			if data[2].mfmax>0 then
				local str = "<font color=#f1e8d0>魔法防御："..data[2].mfmin.."-"..data[2].mfmax.."</font>"
				table.insert(gemDespTable,str)
			end
			if data[6].value>0 then
				local str = "<font color=#f1e8d0>血量上限："..(data[6].value/100).."%</font>"
				table.insert(gemDespTable,str)
			end
			if data[7].value>0 then
				local str = "<font color=#f1e8d0>魔法上限："..(data[7].value/100).."%</font>"
				table.insert(gemDespTable,str)
			end
			if data[8].value>0 then
				local str = "<font color=#f1e8d0>神圣攻击："..data[8].value.."</font>"
				table.insert(gemDespTable,str)
			end
			if data[9].value>0 then
				local str = "<font color=#f1e8d0>暴击几率："..(data[9].value/10000).."%</font>"
				table.insert(gemDespTable,str)
			end
			if data[10].value>0 then
				local str = "<font color=#f1e8d0>暴击伤害："..data[10].value.."</font>"
				table.insert(gemDespTable,str)
			end
		end
		
		local mParam = {
		name = GameMessageCode.EVENT_PANEL_ON_ALERT,
		panel = "tips",
		infoTable = gemDespTable,
		visible = true,
		}
		GameSocket:dispatchEvent(mParam)
	end

	local function updateUpgradeGemBox(data)
		-- print("updateUpgradeGem//////////////////////", GameUtilSenior.encode(data))
		local imgNeedGem = var.xmlPageGem:getWidgetByName("img_need_gem")
		imgNeedGem:loadTexture("null", ccui.TextureResType.plistType)
		local imgCurGem = var.xmlPageGem:getWidgetByName("img_need_gem_bg")
		GUIItem.getItem({parent=imgCurGem , typeId=nil})
		local lblNeedNum = var.xmlPageGem:getWidgetByName("lbl_need_num"):setString("")
		local imgUpdGemBg = var.xmlPageGem:getWidgetByName("img_upd_gem_bg")
		GUIItem.getItem({parent=imgUpdGemBg , typeId=-999})
		local lblUpdGemName = var.xmlPageGem:getWidgetByName("lbl_upd_gem_name")
		--local lblGemAttr = var.xmlPageGem:getWidgetByName("lbl_gem_attr"):setString("")
		--local lblGemFrom = var.xmlPageGem:getWidgetByName("lbl_attr_from"):setString("")
		--local lblGemTo = var.xmlPageGem:getWidgetByName("lbl_attr_to"):setString("")
		local lblNeedVcoin = var.xmlPageGem:getWidgetByName("lbl_need_vcoin"):setString("")
		-- local lblReplaceVcion = var.xmlPageGem:getWidgetByName("lbl_lack_material_tips"):setString("")
		print(data.nextGem)
		if not data.nextGem then
			var.xmlPageGem:getWidgetByName("box_upgrade_gem"):hide()
			return
		end
		
		local lowSprite = cc.Sprite:create()
		lowSprite:setPosition(35,35)
		imgUpdGemBg:addChild(lowSprite)
		cc.AnimManager:getInstance():getPlistAnimate(4, 73004, 4, 3,false,false,0,function(animate,shouldDownload)
			lowSprite:runAction(cca.repeatForever(animate))
			if shouldDownload==true then
				lowSprite:release()
			end
		end,
		function(animate)
			lowSprite:retain()
		end)
		
		
		if data.needId then
			local itemDef = GameSocket:getItemDefByID(data.needId)
			if itemDef then
				-- imgNeedGem:loadTexture("image/icon/"..itemDef.mIconID..".png")
				GUIItem.getItem({parent=imgCurGem , typeId=data.needId})
				if tonumber(data.needId)%1000==299 then
					var.xmlPageGem:getWidgetByName("box_upgrade_gem"):hide()
				end
			end
			if data.curGem>=data.needGem then
				lblNeedNum:setString(data.curGem.."/"..data.needGem):setColor(GameBaseLogic.getColor(0x2F9701))
			else
				lblNeedNum:setString(data.curGem.."/"..data.needGem):setColor(GameBaseLogic.getColor(0xEF2F00))
			end
			
			--暂时不用元宝升级
			lblNeedNum:setString("")

			if data.nextGem then
				var.xmlPageGem:getWidgetByName("lbl_now_gem_name"):setString(itemDef.mName)
				lblUpdGemName:setString(data.nextGem.name)
				GUIItem.getItem({parent=imgUpdGemBg , typeId=data.nextGem.typeId})
			end
			-- lblNeedVcoin:setString(data.needVcoin)
			-- lblNeedVcoin:setString("消耗元宝：0")

			--[[
			if data.upgradeAttr then
				lblGemAttr:setString(data.upgradeAttr.attr)
				lblGemFrom:setString(data.upgradeAttr.from)
				lblGemTo:setString(data.upgradeAttr.to)
				if string.find(data.upgradeAttr.attr,"攻击") then
					for i=1,2 do
						var.xmlPageGem:getWidgetByName("lbl_gem_attr_"..i):show()
						var.xmlPageGem:getWidgetByName("lbl_attr_from_"..i):show():setString(data.upgradeAttr.from)
						var.xmlPageGem:getWidgetByName("lbl_attr_to_"..i):show():setString(data.upgradeAttr.to)
						var.xmlPageGem:getWidgetByName("img_upgrade_arrow2_"..i):show()
					end
				else
					for i=1,2 do
						var.xmlPageGem:getWidgetByName("lbl_gem_attr_"..i):hide()
						var.xmlPageGem:getWidgetByName("lbl_attr_from_"..i):hide()
						var.xmlPageGem:getWidgetByName("lbl_attr_to_"..i):hide()
						var.xmlPageGem:getWidgetByName("img_upgrade_arrow2_"..i):hide()
					end
				end
			end
			]]
			if data.replaceVcion and data.replaceVcion>0 then
				-- lblReplaceVcion:setString("材料不足需"..data.replaceVcion.."元宝代替")
				var.replaceVcion=data.replaceVcion
			else
				-- lblReplaceVcion:setString("材料不足元宝代替")
				var.replaceVcion=0
			end
			var.curentGemValue = data.curentGemValue
			if data.replaceGem and data.replaceGem>0 then
				-- lblReplaceVcion:setString("材料不足需"..data.replaceVcion.."元宝代替")
				var.replaceGem=data.replaceGem
			else
				-- lblReplaceVcion:setString("材料不足元宝代替")
				var.replaceGem=0
			end
			
			if math.floor(data.needId/10000)==2505 then
				--玄级宝石只能使用舍利升级
				if data.needId==25050010 then
					var.xmlPageGem:getWidgetByName("lbl_need_vcoin"):setString("消耗舍利：200个")
					var.xmlPageGem:getWidgetByName("upgrade_tips"):setString("10%成功概率,失败扣除舍利并降1级,最低降到1级"):show()				
				else
					var.xmlPageGem:getWidgetByName("lbl_need_vcoin"):setString("消耗舍利：100个")
					var.xmlPageGem:getWidgetByName("upgrade_tips"):setString("50%成功概率,失败扣除舍利并降1级,最低降到1级"):show()
				end
			else
				if var.gemAutoVcoin or true then  --暂时只用钻石
					var.xmlPageGem:getWidgetByName("lbl_need_vcoin"):setString("消耗钻石："..var.replaceVcion)
					var.xmlPageGem:getWidgetByName("upgrade_tips"):setString(""):show()
				else
					var.xmlPageGem:getWidgetByName("lbl_need_vcoin"):setString("消耗宝石值："..var.curentGemValue.."/"..var.replaceGem.."")
				end
			end
		end
	end

	local function showUpgradeGemBox(gemPos)
		local btnUpgradeGem = var.xmlPageGem:getWidgetByName("btn_upgrade_gem")
		btnUpgradeGem.gemPos = gemPos
		local netGem = GameSocket:getNetItem(gemPos)
		-- print("showUpgradeGemBox", gemPos, netGem)
		if netGem then
			btnUpgradeGem.gemPos = gemPos
			var.xmlPageGem:getWidgetByName("box_upgrade_gem"):show()
			GameSocket:PushLuaTable("gui.ContainerDiamond.onPanelData", GameUtilSenior.encode({actionid = "updateUpgrade", gemPos = gemPos}))
		end
		-- var.gemAutoVcoin = false
		updateCheckAutoVcoin()
	end

	local function hideUpgradeGemBox()
		var.gemAutoVcoin = false
		var.xmlPageGem:getWidgetByName("box_upgrade_gem"):hide()
	end

	-- 宝石升级按钮
	local function pushUpgradeButtons(sender)
		var.curUpgradeGem = sender.gemPos
		showUpgradeGemBox(sender.gemPos)
	end


	-- 宝石背包刷新
	local function updateBagGem(item)
		local mPos, netItem = -999
		if var.gemTable[item.tag] then
			netItem = GameSocket:getNetItem(var.gemTable[item.tag])
			if netItem then
				mPos = netItem.position
			end
		end

		local param = {
			-- iconType = GameConst.ICONTYPE.DEPOT,
			parent = item,
			tipsType = GameConst.TIPS_TYPE.GEM,
			pos = mPos,
			customCallFunc = function()
				-- print("callBack", mPos)
				if mPos then
					insetGem(mPos)
				end
			end,
		}

		GUIItem.getItem(param)
	end

	-- 刷新背包
	local function updateBagList(gemType)
		var.curGemType = gemType
		var.gemTable = GameBaseLogic.getGemsAndSort(gemType)
		local listBag = var.xmlPageGem:getWidgetByName("list_bag")
		listBag:setSliderVisible(false)
		listBag:reloadData(GameConst.ITEM_BAG_MAX, updateBagGem, nil, false)
	end

	local function canGemUpgraded(gemPos)
		local netItem = GameSocket:getNetItem(gemPos)
		if netItem then
			local num = GameSocket:getTypeItemNum(netItem.mTypeID)
			if num >= 3 then
				return true
			end
		end
		return false
	end

	local function handleUpgradeGemButton(btnUpgrade, gemPos)
		if btnUpgrade then
			--print("///////////////////handleUpgradeGemButton///////////////////", btnUpgrade:getName(), gemPos)
			local netGem = GameSocket:getNetItem(gemPos)
			if netGem and tonumber(netGem.mTypeID)%100>=1 and tonumber(netGem.mTypeID)%100<11 then
				btnUpgrade:setVisible(true)
			else
				btnUpgrade:setVisible(false)
				if netGem and tonumber(netGem.mTypeID)%1000==299 then

				end
			end
		end
	end

	--更新选中装备的宝石信息
	local function updateGemInfo()
		local item, netGem
		for i,v in ipairs(gemConf) do
			local mPos = var.mSelectedEquip - v.offSet
			local btnUpgrade = var.xmlPageGem:getWidgetByName("btn_upgrade_"..i)
			item = var.xmlPageGem:getWidgetByName("gem_"..i)
			if item then
				-- print("updateGemInfo", item, mPos, GameSocket:getNetItem(mPos))
				local param = {
					-- iconType = GameConst.ICONTYPE.BAG,
					-- tipsType = GameConst.TIPS_TYPE.BAG,
					parent = item,
					pos = mPos,
					tipsType = GameConst.TIPS_TYPE.UPGRADE,
					enmuPos = 4,
					customCallFunc = function()
						undressGem(mPos)
					end,
					callBack = function()
						-- undressGem(mPos)
						-- updateBagList(v.gemType)
					end,
					doubleCall = function()
						undressGem(mPos)
						-- updateBagList(v.gemType)
					end,
					updateFunc = function (itemPos)
						--宝石暂时禁止升级
						handleUpgradeGemButton(btnUpgrade, itemPos)
					end
				}
				GUIItem.getItem(param)
			end
			if btnUpgrade then
				btnUpgrade.gemPos = mPos
			end
		end
	end

	local function onSelectEquip(index)
		var.curEquipIndex = index
		var.mSelectedEquip = equip_info[index].pos
		local equipBg = var.xmlPageGem:getWidgetByName("equip_"..index)
		var.imgEquipSelected:setPosition(equipBg:getPosition()):show():setLocalZOrder(100)
		updateGemInfo()
	end

	--刷新装备
	local function updateEquips()
		for i = 1, 10 do
			local equipBg = var.xmlPageGem:getWidgetByName("equip_"..i)
			local equipLock = var.xmlPageGem:getWidgetByName("equipLock_"..i)
			if #openNeed>0 then
				if equipLock and tonumber(nSLevel)>=tonumber(openNeed[i]) then
					equipLock:setVisible(false)
				else
					equipLock:setVisible(true)
				end
			end
			if equipBg then
				equipBg:setLocalZOrder(10)
				-- ccui.Widget:create():setContentSize(equipBg:getContentSize()):setName("guideWidget"):align(display.LEFT_BOTTOM, 0, 0):addTo(equipBg)
				equipBg.etype = equip_info[i].etype
				local param = {
					parent			= equipBg,
					pos				= equip_info[i].pos,--左边的装备tips显示在右边，反之亦然
					mShowEquipFlag  = true,
					iconType = GameConst.ICONTYPE.DEPOT,
					tipsType = GameConst.TIPS_TYPE.GENERAL,
					--物品框点击回调
					callBack = function ()
						--获取物品信息
						if tonumber(nSLevel)>=tonumber(openNeed[i]) then
							onSelectEquip(i)
						else
							GameSocket:alertLocalMsg("女神重数达到"..openNeed[i].."方可开启！", "alert")
						end

					end,
				}
				GUIItem.getItem(param)
			end
		end
	end

	local function pushBuyGemButton(sender)
		if sender.index and var.gemShopData[sender.index] then
			local itemData = var.gemShopData[sender.index]
			local param = {
				name = GameMessageCode.EVENT_SHOW_TIPS,
				str = "quickBuy",
				itemId = itemData.id,
				itemPrice = itemData.vcoin,
				commitCallFunc = function (buyNum)
					GameSocket:PushLuaTable("gui.ContainerDiamond.onPanelData", GameUtilSenior.encode({actionid = "buyGem", index = sender.index, num = buyNum}))
				end
			}
			GameSocket:dispatchEvent(param)
		end
	end

	-- 刷新宝石商店
	local function updateGemShop(item)
		local idx = item.tag
		local itemData = var.gemShopData[idx]

		item:getWidgetByName("lbl_item_name"):setString(itemData.name)
		item:getWidgetByName("lbl_item_price"):setString(itemData.vcoin)
		local awardItem=item:getWidgetByName("item_bg")
		local param={
			-- iconType = GameConst.ICONTYPE.DEPOT,
			parent = awardItem,
			typeId = itemData.id,
		}
		GUIItem.getItem(param)

		local btnBuy = item:getWidgetByName("btn_buy")
		btnBuy.index = idx
		GUIFocusPoint.addUIPoint(btnBuy, pushBuyGemButton)
	end

	local function initGemShop()
		local listShop = var.xmlPageGem:getWidgetByName("list_shop")
		listShop:setSliderVisible(false)
		listShop:reloadData(#var.gemShopData, updateGemShop)
	end

	local function onPanelData(event)
		if event.type ~= "ContainerDiamond" then return end
		local data=GameUtilSenior.decode(event.data)
		-- print(event.data)
		if data then
			if data.actionid == "updateGemBag" then

			elseif data.actionid == "updateUpgradeGem" then
				updateUpgradeGemBox(data)
			elseif data.actionid == "upgradeSucceed" then
				showUpgradeGemBox(var.curUpgradeGem)
			elseif data.actionid == "updateGemShop" then
				var.gemShopData = data.gemShop
				initGemShop()
			elseif data.actionid == "updateGemOpenState" then
				openNeed=data.openData
				nSLevel =data.nsLevel
				updateEquips()
			elseif data.actionid=="updateTipsValue" then
				if noShowTip then
					gemDesp(data.tipsData)
				end
			end
		end
	end

	local function handleItemChange(event)
		local refresh = false
		if event.oldType and GameBaseLogic.IsGem(event.oldType) then
			refresh = true
		elseif GameBaseLogic.IsPosInBag(event.pos) then
			local netItem = GameSocket:getNetItem(event.pos)
			if netItem and GameBaseLogic.IsGem(netItem.mTypeID) then
				refresh = true
			end
		end
		if refresh then
			updateBagList(var.curGemType)
		end
	end

	local function pushGemGroove(sender)
		local conf = gemConf[sender.tag]
		if conf then
			updateBagList(conf.gemType)
		end
	end

	--宝石槽添加点击回调
	local function initGemGroove()
		for i,v in ipairs(gemConf) do
			local item = var.xmlPageGem:getWidgetByName("gem_"..i):setTouchEnabled(true)
			item.tag = i
			GUIFocusPoint.addUIPoint(item, pushGemGroove)
		end
	end

	--升级按钮初始化
	local function initUpgradeButtons()
		for i=1,6 do
			local btnUpgrade = var.xmlPageGem:getWidgetByName("btn_upgrade_"..i):setTouchEnabled(true)
			GUIFocusPoint.addUIPoint(btnUpgrade, pushUpgradeButtons)
		end
	end

	var.xmlPageGem = GUIAnalysis.load("ui/layout/ContainerCharacter_gem.uif")
	if var.xmlPageGem then
		--GameUtilSenior.asyncload(var.xmlPageGem, "page_gem_bg", "ui/image/page_gem_bg.jpg")
		var.xmlPageGem:align(display.LEFT_BOTTOM, 0, 0):addTo(var.xmlPanel)

		var.imgEquipSelected = var.xmlPageGem:getWidgetByName("img_equip_selected")

		--var.fightNum = ccui.TextAtlas:create("0123456789", "image/typeface/num_21.png", 27, 36, "0")
		--	:addTo(var.xmlPageGem)
		--	:align(display.LEFT_CENTER, 255, 48)
		--	:setString(0)
		var.fightNum = ccui.TextAtlas:create("0123456789", "image/typeface/num_44.png", 20, 32, "0")
			:addTo(var.xmlPageGem:getWidgetByName("Image_10"))
			:align(display.LEFT_CENTER, 240,45)
			:setString(0)

		local btnUpgradeGem = var.xmlPageGem:getWidgetByName("btn_upgrade_gem")
		GUIFocusPoint.addUIPoint(btnUpgradeGem, function (sender)
			GameSocket:PushLuaTable("gui.ContainerDiamond.onPanelData",GameUtilSenior.encode({actionid = "upgradeGem", gemPos = sender.gemPos, autoVcoin = true--[[var.gemAutoVcoin]]}))
		end)

		local boxUpgradeGem = var.xmlPageGem:getWidgetByName("box_upgrade_gem"):setTouchEnabled(true)
		GUIFocusPoint.addUIPoint(boxUpgradeGem, function (sender)
			hideUpgradeGemBox()
		end)

		local btnAutoVcoin = var.xmlPageGem:getWidgetByName("btn_auto_vcoin"):setTouchEnabled(true)
		GUIFocusPoint.addUIPoint(btnAutoVcoin, function (sender)
			var.gemAutoVcoin = not var.gemAutoVcoin
			if var.gemAutoVcoin or true then  --暂时只用钻石
				var.xmlPageGem:getWidgetByName("lbl_need_vcoin"):setString("消耗钻石："..var.replaceVcion)
			else
				var.xmlPageGem:getWidgetByName("lbl_need_vcoin"):setString("消耗宝石值："..var.curentGemValue.."/"..var.replaceGem)
			end
			updateCheckAutoVcoin()
		end)

		--var.xmlPageGem:getWidgetByName("btn_gem_tips"):setTouchEnabled(false)
		--local btn_gem_tips = var.xmlPageGem:getWidgetByName("btn_gem_tips"):setTouchEnabled(true)
		--btn_gem_tips:addTouchEventListener(function (pSender, touchType)
		--	if touchType == ccui.TouchEventType.began then
		--		noShowTip=true
		--		GameSocket:PushLuaTable("gui.ContainerDiamond.onPanelData", GameUtilSenior.encode({actionid = "reqGemTipsAll"}))
		--	elseif touchType == ccui.TouchEventType.ended or touchType == ccui.TouchEventType.canceled then
		--		noShowTip=false
		--		GDivDialog.handleAlertClose()
		--	end
		--end)

		var.xmlPageGem:getWidgetByName("img_upgrade_gem_bg"):setTouchEnabled(true)

		hideUpgradeGemBox()

		initGemGroove()
		initUpgradeButtons()
		updateFightNum()
		updateEquips()
		-- initGemShop()
		updateBagList()

		-- 默认选中装备
		onSelectEquip(1)
		
		
		--显示宝石圈子
		local startNum = 0
		local function startShowBg()
			var.xmlPageGem:getWidgetByName("gem_quan_1"):loadTexture("gem_bg_1_"..startNum..".png",ccui.TextureResType.plistType)
			
			startNum= startNum+1
			if startNum ==11 then
				startNum =0
			end
		end
		var.xmlPageGem:getWidgetByName("gem_quan_1"):stopAllActions()
		var.xmlPageGem:getWidgetByName("gem_quan_1"):runAction(cca.repeatForever(cca.seq({cca.delay(0.1),cca.cb(startShowBg)}),tonumber(11)))
		
		
		local startNum = 0
		local function startShowBg2()
			var.xmlPageGem:getWidgetByName("gem_quan_2"):loadTexture("gem_bg_2_"..startNum..".png",ccui.TextureResType.plistType)
			
			startNum= startNum+1
			if startNum ==11 then
				startNum =0
			end
		end
		var.xmlPageGem:getWidgetByName("gem_quan_2"):stopAllActions()
		var.xmlPageGem:getWidgetByName("gem_quan_2"):runAction(cca.repeatForever(cca.seq({cca.delay(0.1),cca.cb(startShowBg2)}),tonumber(11)))
		--显示宝石圈子

		GameSocket:PushLuaTable("gui.ContainerDiamond.onPanelData", GameUtilSenior.encode({actionid = "reqGemShop"}))
		GameSocket:PushLuaTable("gui.ContainerDiamond.handlePanelData", GameUtilSenior.encode({actionid = "reqGemOpenState"}))
		cc.EventProxy.new(GameSocket,var.xmlPageGem)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, onPanelData)
			:addEventListener(GameMessageCode.EVENT_ITEM_CHANGE, handleItemChange)
	end
end

return ContainerCharacter