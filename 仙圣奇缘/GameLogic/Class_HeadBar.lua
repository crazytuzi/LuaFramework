--------------------------------------------------------------------------------------
-- 文件名:	Class_HeadBar.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	LYP
-- 日  期:	2014-10-28 4:37
-- 版  本:	1.0
-- 描  述:	游戏主界面的状态
-- 应  用:  本例子是用类对象的方式实现
---------------------------------------------------------------------------------------

Class_HeadBar = class("Class_HeadBar")
Class_HeadBar.__index = Class_HeadBar

local  tb_ResourcesCommon = {"Button_TongQian","Button_YuanBao","Button_Energy"}
local  tb_SubInfoDefault = {"Button_TongQian","Button_YuanBao","Button_Energy"}
local  tb_OtherInfoDefault = {"Button_TongQian","Button_YuanBao","Button_Energy"}
local  tb_ResourcesTowMoney = {"Button_TongQian","Button_YuanBao"}
local  tb_ResourcesArena = {"Button_TongQian","Button_Prestige","Button_AreaTimes"}
local  tb_ResourcesAssitant = {"Button_TongQian","Button_YuanBao","Button_ActiveNess"}
local  tb_ResourcesFarmPray = {"Button_YuanBao","Button_XueShi"}
local  tb_ResourcesMailBox = {"Button_FriendPoints","Button_TongQian","Button_YuanBao","Button_Energy"}
local  tb_ResourcesQiShu = {"Button_XueShi","Button_Energy"}
local  tb_ResourcesSocial = {"Button_FriendPoints","Button_TongQian","Button_YuanBao"}
local  tb_ResourcesShangXiang = {"Button_Incense","Button_TongQian","Button_YuanBao"}
local  tb_ResourcesShopPrestige = {"Button_Prestige","Button_TongQian","Button_YuanBao"}
local  tb_ResourcesDragonPray = {"Button_DragonBall","Button_TongQian","Button_YuanBao"}
local  tb_ResourcesShopSecret = {"Button_FriendPoints", "Button_Prestige","Button_TongQian","Button_YuanBao"}
local  tb_ResourcesFarm = {"Button_XueShi","Button_TongQian","Button_YuanBao"}
local  tb_ResourcesSchool = {"Button_Prestige","Button_XueShi","Button_YuanBao"}
local  tb_ResourcesDragonPrayGuild = {"Button_Prestige","Button_XueShi","Button_TongQian"}
local  tb_ResourcesShopJiangHun = {"Button_RefreshToken", "Button_FriendPoints", "Button_JiangHunShi", "Button_TongQian", "Button_YuanBao"}

----加入帮派申请界面
local GroupCreate_View_x = -350
--药园上香
local Game_FarmPray_View_x = -350
--装备界面
local Game_Equip1_View_x = 475
local Game_ActivityFuLuDaoSub_View_x = -310
local Game_Arena_View_x = 190
local Game_Card_View_x = -420
local Game_SelectGameLevel_View_x = -325
local Game_Package1_View_x = -195
local Game_EquipStrengthen_View_x = -270
local Game_EquipRefine_View_x = -290
local Game_EquipRefineStarUp_View_x = -270
local Game_CardLevelUp_View_x = -420
local Game_CardFate1_View_x = 190
local Game_CardSelect_View_x = -420
local Game_CardDuJie_View_x = 190
local Game_MailBox_View_x = -450
local Game_Social1_View_X = 190
local Game_FarmReward_View_X = -220
local Game_ActivityCenter_View_X = 540

-- Game_FarmReward
if g_LggV.LanguageVer == eLanguageVer.LANGUAGE_viet_VIET  then --越南版
	GroupCreate_View_x = -300
	Game_FarmPray_View_x = -260
	Game_Equip1_View_x = 500
	Game_ActivityFuLuDaoSub_View_x = -240
	Game_Arena_View_x = 250
	Game_Card_View_x = -360
	Game_SelectGameLevel_View_x = -310
	Game_Package1_View_x = -230
	Game_EquipStrengthen_View_x = -210
	Game_EquipRefine_View_x = -240
	Game_EquipRefineStarUp_View_x = -230
	Game_CardLevelUp_View_x = -380
	Game_CardFate1_View_x = 200

	Game_CardSelect_View_x = -360
	Game_CardDuJie_View_x = 200

	Game_MailBox_View_x = -495
	Game_Social1_View_X = 205
	Game_FarmReward_View_X = -170
	Game_ActivityCenter_View_X = 545
else
	-- 中文
end

local tbWndHeadBar = 
{
	--窗口ID，tbPos, tb_ResourcesList  如果tb_ResourcesList为空则默认是{2,1,3}
	-- nAnchorType 1，描点在右；2，描点在左
	Game_Ectype = {tbPos = {x=18, y=680},tb_ResourcesList = tb_ResourcesCommon, nPlayerInfoType = 2},
	--装备界面
	Game_Equip1 = {tbPos = {x=Game_Equip1_View_x, y=-40},tb_ResourcesList = tb_ResourcesCommon, szParent="Image_TitlePNL"},
	Game_VIP = {tbPos = {x=18, y=680}, nPlayerInfoType = 2,tb_ResourcesList = tb_ResourcesCommon},
	Game_Package1 = {tbPos = {x=Game_Package1_View_x, y=291},tb_ResourcesList = tb_ResourcesTowMoney, szParent="ImageView_PackagePNL"},
	Game_ReCharge = {tbPos = {x=18, y=680}, nPlayerInfoType = 2,tb_ResourcesList = tb_ResourcesCommon},
	Game_ReCharge = {tbPos = {x=18, y=680}, nPlayerInfoType = 2,tb_ResourcesList = tb_ResourcesCommon},
	Game_Assistant = {tbPos = {x=15, y=684}, nPlayerInfoType = 2,tb_ResourcesList = tb_ResourcesAssitant},
	Game_Summon = {tbPos = {x=18, y=680}, nPlayerInfoType = 2,tb_ResourcesList = tb_ResourcesCommon},
	Game_SummonTenTimes = {tbPos = {x=10, y=692}, fScale = 0.8, nPlayerInfoType = 2,tb_ResourcesList = tb_ResourcesTowMoney},
    Game_EquipStrengthen = {tbPos = {x=Game_EquipStrengthen_View_x, y=243},tb_ResourcesList = tb_ResourcesTowMoney,szParent="ImageView_EquipStrengthenPNL"},
	Game_EquipRefineStarUp = {tbPos = {x=Game_EquipRefineStarUp_View_x, y=243},tb_ResourcesList = tb_ResourcesDragonPray,szParent="Image_EquipRefineStarUpPNL"},
	Game_EquipRefine = {tbPos = {x=Game_EquipRefine_View_x, y=303},tb_ResourcesList = tb_ResourcesCommon,szParent="ImageView_EquipRefinePNL"},
	Game_EquipChongZhu = {tbPos = {x=-290, y=303},tb_ResourcesList = tb_ResourcesTowMoney,szParent="ImageView_EquipChongZhuPNL"},
	Game_Arena = {tbPos = {x=Game_Arena_View_x, y=680},tb_ResourcesList = tb_ResourcesArena},
	Game_CardDuJie = {tbPos = {x=Game_CardDuJie_View_x, y=680},tb_ResourcesList = tb_ResourcesCommon},
	Game_CardFate1 = {tbPos = {x=Game_CardFate1_View_x, y=680},tb_ResourcesList = tb_ResourcesCommon},
	Game_Card = {tbPos = {x=Game_Card_View_x, y=303},tb_ResourcesList = tb_ResourcesTowMoney,szParent="ImageView_CardPNL"},
	Game_CardLevelUp = {tbPos = {x=Game_CardLevelUp_View_x, y=303},tb_ResourcesList = tb_ResourcesTowMoney, szParent="ImageView_CardLevelUpPNL"},
	Game_CardSelect = {tbPos = {x=Game_CardSelect_View_x, y=303},tb_ResourcesList = tb_ResourcesTowMoney, szParent="Image_CardSelectPNL"},
	Game_Farm = {tbPos = {x=18, y=680}, nPlayerInfoType = 2,tb_ResourcesList = tb_ResourcesFarm},
	--药园上香
	Game_FarmPray = {tbPos = {x = Game_FarmPray_View_x, y=256},tb_ResourcesList = tb_ResourcesFarmPray, szParent="Image_PrayPNL"},
	Game_FarmReward = {tbPos = {x=Game_FarmReward_View_X, y=223},tb_ResourcesList = tb_ResourcesTowMoney, szParent="Image_FarmRewardPNL"},
	Game_HuntFate1 = {tbPos = {x=18, y = 690}, fScale = 0.9, nPlayerInfoType = 2,tb_ResourcesList = tb_ResourcesTowMoney},
	Game_MailBox = {tbPos = {x=Game_MailBox_View_x, y=320},tb_ResourcesList = tb_ResourcesMailBox, szParent="Image_Background"},
	Game_QiShu = {tbPos = {x=15, y=310},tb_ResourcesList = tb_ResourcesQiShu,szParent="Image_QiShuContentPNL"},
	Game_ZhenXin = {tbPos = {x=-335, y=310},tb_ResourcesList = tb_ResourcesQiShu,szParent="Image_ZhenXinPNL"},
	Game_ZhaoCaiFu = {tbPos = {x=18, y=680}, nPlayerInfoType = 2, tb_ResourcesList = tb_ResourcesTowMoney},
	Game_Social1 = {tbPos = {x=Game_Social1_View_X, y=680}, tb_ResourcesList = tb_ResourcesSocial},
	Game_Turntable = {tbPos = {x=-570, y=300}, fScale = 0.9, nPlayerInfoType = 2,tb_ResourcesList = tb_ResourcesSocial, szParent="Image_TurntablePNL"},
	Game_SelectGameLevel1 = {tbPos = {x=Game_SelectGameLevel_View_x, y=281}, tb_ResourcesList = tb_ResourcesCommon,szParent="Image_ContentPNL"},
	Game_SelectGameLevel2 = {tbPos = {x=Game_SelectGameLevel_View_x, y=311}, tb_ResourcesList = tb_ResourcesCommon,szParent="Image_ContentPNL"},
	Game_SelectGameLevel3 = {tbPos = {x=Game_SelectGameLevel_View_x, y=341}, tb_ResourcesList = tb_ResourcesCommon,szParent="Image_ContentPNL"},
	Game_ShangXiang1 = {tbPos = {x=18, y=680}, fScale = 0.9, nPlayerInfoType = 2,tb_ResourcesList = tb_ResourcesShangXiang},
	Game_ActivityFuLuDaoSub = {tbPos = {x=Game_ActivityFuLuDaoSub_View_x, y=285},tb_ResourcesList = tb_ResourcesCommon, szParent="Image_ActivityFuLuDaoSubPNL"},
	Game_ActivityCenter = {tbPos = {x=Game_ActivityCenter_View_X, y=675}, nPlayerInfoType = 2,tb_ResourcesList = tb_ResourcesCommon},
	Game_ShopPrestige = {tbPos = {x=18, y=680}, nPlayerInfoType = 2,tb_ResourcesList = tb_ResourcesShopPrestige},
	Game_ShopSecret = {tbPos = {x=18, y=680}, nPlayerInfoType = 2,tb_ResourcesList = tb_ResourcesShopJiangHun},
	Game_EctypeJY = {tbPos = {x=18, y=680}, nPlayerInfoType = 2,tb_ResourcesList = tb_ResourcesCommon},
	Game_EctypeJYDetail = {tbPos = {x=-335, y=307}, tb_ResourcesList = tb_ResourcesCommon,szParent="Image_ContentPNL"},
	Game_DragonPray = {tbPos = {x=18, y=680}, fScale = 1.0, nPlayerInfoType = 2,tb_ResourcesList = tb_ResourcesDragonPray,szParent="Image_Background"},
	Game_GanWu = {tbPos = {x=18, y=685}, fScale = 1.0, nPlayerInfoType = 2,tb_ResourcesList = tb_ResourcesShangXiang},
	Game_BaXuanGuoHai = {tbPos = {x=18, y=680}, fScale = 1.0, nPlayerInfoType = 2,tb_ResourcesList = tb_ResourcesShopPrestige},
	Game_JiHuiSuo = {tbPos = {x=18, y=680}, fScale = 1.0, nPlayerInfoType = 2,tb_ResourcesList = tb_ResourcesCommon},
	Game_FirstCharge = {tbPos = {x=18, y=680}, nPlayerInfoType = 2, tb_ResourcesList = tb_ResourcesCommon},
	Game_ServerOpenTask = {tbPos = {x=18, y=685}, nPlayerInfoType = 2, tb_ResourcesList = tb_ResourcesCommon},
	--加入帮派申请界面
	Game_GroupCreate = {tbPos = {x = GroupCreate_View_x, y = 320},tb_ResourcesList = tb_ResourcesCommon, szParent="Image_Background"},
	Game_GuildBank = {tbPos = {x=-463, y=310},tb_ResourcesList = tb_ResourcesShopPrestige, szParent="Image_GuildBankPNL"},
	Game_GuildSchool = {tbPos = {x=-463, y=310},tb_ResourcesList = tb_ResourcesSchool, szParent="Image_GuildSchoolPNL"},
	Game_GuildSkill = {tbPos = {x=-463, y=310},tb_ResourcesList = tb_ResourcesSchool, szParent="Image_GuildSkillPNL"},
	Game_DragonPrayGuild = {tbPos = {x=18, y=680}, fScale = 1.0, nPlayerInfoType = 2,tb_ResourcesList = tb_ResourcesDragonPrayGuild,szParent="Image_Background"},
}

-- 类型 1:元宝 2钱 3体力 4.暂无  
function Class_HeadBar:initHeadBar(Image_PlayerInfoPNL, tb_ResourcesList, nPlayerInfoType)
	tb_ResourcesList = tb_ResourcesList or tb_ResourcesCommon

	Image_PlayerInfoPNL:removeAllChildrenWithCleanup(false)
	for k,v in ipairs(tb_ResourcesList) do   
	    local Button_ResourceItem = self.Button_ResourceItem:clone()
		Image_PlayerInfoPNL:addChild(Button_ResourceItem)
		local Image_ResourceIcon = tolua.cast(Button_ResourceItem:getChildByName("Image_ResourceIcon"),"ImageView")
		Button_ResourceItem:setName(v)
		g_SetBtnWithPressingEvent(Button_ResourceItem, nil, g_OnShowTip, nil, g_OnCloseTip, true, 0.0)

		if v == "Button_Energy" then
			local Button_AddResource = tolua.cast(Button_ResourceItem:getChildByName("Button_AddResource"),"Button")
			local function onClick(pSender,eventType)
				if eventType == ccs.TouchEventType.ended then
					g_buyEnergy()
				end
			end
			Button_AddResource:addTouchEventListener(onClick)
			Button_AddResource:setTouchEnabled(true)
			Image_ResourceIcon:loadTexture(getUIImg("Icon_PlayerInfo_Energy"))
		elseif v == "Button_YuanBao" then
			local function onClick(pSender,eventType)
				if eventType == ccs.TouchEventType.ended then
					g_WndMgr:openWnd("Game_ReCharge")
				end
			end
			local Button_AddResource = tolua.cast(Button_ResourceItem:getChildByName("Button_AddResource"),"Button")
			Button_AddResource:addTouchEventListener(onClick)
			Button_AddResource:setTouchEnabled(true)
            local armature,animation = g_CreateCoCosAnimation("YuanBaoFlare", nil, 2)
			if armature then
				armature:setPosition(ccp(0, 0))
				animation:playWithIndex(0)
				Image_ResourceIcon:addNode(armature, 2, 0)
			end
			Image_ResourceIcon:loadTexture(getUIImg("Icon_PlayerInfo_YuanBao"))
		elseif v == "Button_TongQian" then
			local function onClick(pSender,eventType)
				if eventType == ccs.TouchEventType.ended then
					g_WndMgr:openWnd("Game_ZhaoCaiFu")
				end
			end
			
			local Button_AddResource = tolua.cast(Button_ResourceItem:getChildByName("Button_AddResource"),"Button")
			Button_AddResource:addTouchEventListener(onClick)
            Button_AddResource:setTouchEnabled(true)
            local armature,animation = g_CreateCoCosAnimation("TongQianFlare", nil, 2)
			if armature then
				armature:setPosition(ccp(0, 0))
				animation:playWithIndex(0)
				Image_ResourceIcon:addNode(armature, 2, 0)
			end
			Image_ResourceIcon:loadTexture(getUIImg("Icon_PlayerInfo_TongQian"))
		elseif v == "Button_Prestige" then
			local Button_AddResource = tolua.cast(Button_ResourceItem:getChildByName("Button_AddResource"),"Button")
			Button_AddResource:removeFromParentAndCleanup(true)
			Image_ResourceIcon:loadTexture(getUIImg("Icon_PlayerInfo_Prestige"))
		elseif v == "Button_XueShi" then
			local Button_AddResource = tolua.cast(Button_ResourceItem:getChildByName("Button_AddResource"),"Button")
			Button_AddResource:removeFromParentAndCleanup(true)
			Image_ResourceIcon:loadTexture(getUIImg("Icon_PlayerInfo_XueShi"))
		elseif v == "Button_Incense" then
			local Button_AddResource = tolua.cast(Button_ResourceItem:getChildByName("Button_AddResource"),"Button")
			Button_AddResource:removeFromParentAndCleanup(true)
			Image_ResourceIcon:loadTexture(getUIImg("Icon_PlayerInfo_Incense"))
		elseif v == "Button_Elements" then
			local Button_AddResource = tolua.cast(Button_ResourceItem:getChildByName("Button_AddResource"),"Button")
			Button_AddResource:removeFromParentAndCleanup(true)
			Image_ResourceIcon:loadTexture(getUIImg("Icon_PlayerInfo_Elements"))
		elseif v == "Button_FriendPoints" then
			local Button_AddResource = tolua.cast(Button_ResourceItem:getChildByName("Button_AddResource"),"Button")
			Button_AddResource:removeFromParentAndCleanup(true)
			Image_ResourceIcon:loadTexture(getUIImg("Icon_PlayerInfo_PriendPoints"))
		elseif v == "Button_AreaTimes" then
			local types = VipType.VipBuyOpType_ArenaChallegeTimes
			local Button_AddResource = tolua.cast(Button_ResourceItem:getChildByName("Button_AddResource"),"Button")
			local function onClickConfirm()
				local function serverResponseCall(times)
					local allNum = g_VIPBase:getVipLevelCntNum(types)
					local function animationEndCall()
						g_ShowSysTips({text = _T("成功购买1次天榜竞技场挑战次数\n您还可购买")..allNum-times.._T("次。")})
					end
					--每次增加一次
					g_Hero:addArenaTimes(1)
                    g_ShowRewardMsgConfrim(macro_pb.ITEM_TYPE_ARENA_TIME, 1, animationEndCall)
					
					local nBuyPrice = g_VIPBase:getVipLevelCntGold(types)
					gTalkingData:onPurchase(TDPurchase_Type.TDP_BuyArena, 1, nBuyPrice)
				end
				g_VIPBase:responseFunc(serverResponseCall)
				g_VIPBase:requestVipBuyTimesRequest(types)
			end
			local function onClick(pSender,eventType)
				if eventType == ccs.TouchEventType.ended then
					local maxTimes = g_VIPBase:getVipLevelCntNum(types)
					--已经购买的次数
					local addNum = g_VIPBase:getAddTableByNum(types)
					if addNum >= maxTimes then 
						g_ShowSysTips({text=_T("您今日天榜竞技场挑战次数的购买次数已用完\n下一VIP等级可以增加购买次数上限")})
						return 
					end
		
					local nBuyPrice = g_VIPBase:getVipLevelCntGold(types)
					if not g_CheckYuanBaoConfirm(nBuyPrice, _T("购买挑战次数需要")..nBuyPrice.._T("元宝, 您的元宝不足是否前往充值")) then
						return
					end
					g_ClientMsgTips:showConfirm(_T("是否花费")..nBuyPrice.._T("元宝购买1次天榜竞技场挑战次数"), onClickConfirm, nil)
				end
			end
			Button_AddResource:addTouchEventListener(onClick)
			Button_AddResource:setTouchEnabled(true)
			Image_ResourceIcon:loadTexture(getUIImg("Icon_PlayerInfo_AreaTimes"))
			
		elseif v == "Button_ActiveNess" then
			local Button_AddResource = tolua.cast(Button_ResourceItem:getChildByName("Button_AddResource"),"Button")
			Button_AddResource:removeFromParentAndCleanup(true)
			Image_ResourceIcon:loadTexture(getUIImg("Icon_PlayerInfo_ActiveNess"))
		elseif v == "Button_XianLing" then
			local Button_AddResource = tolua.cast(Button_ResourceItem:getChildByName("Button_AddResource"),"Button")
			Button_AddResource:removeFromParentAndCleanup(true)
			Image_ResourceIcon:loadTexture(getUIImg("Icon_PlayerInfo_XianLing"))
		elseif v == "Button_DragonBall" then
			local Button_AddResource = tolua.cast(Button_ResourceItem:getChildByName("Button_AddResource"),"Button")
			Button_AddResource:removeFromParentAndCleanup(true)
			Image_ResourceIcon:loadTexture(getUIImg("Icon_PlayerInfo_DragonToken"))
		elseif v == "Button_JiangHunShi" then
			local Button_AddResource = tolua.cast(Button_ResourceItem:getChildByName("Button_AddResource"),"Button")
			Button_AddResource:removeFromParentAndCleanup(true)
			Image_ResourceIcon:loadTexture(getUIImg("Icon_PlayerInfo_JiangHunShi"))
		elseif v == "Button_RefreshToken" then
			local Button_AddResource = tolua.cast(Button_ResourceItem:getChildByName("Button_AddResource"),"Button")
			Button_AddResource:removeFromParentAndCleanup(true)
			Image_ResourceIcon:loadTexture(getUIImg("Icon_PlayerInfo_RefreshToken"))
		end
	end
end

-- 类型 1:元宝 2钱 3体力 4.声望
function Class_HeadBar:adjustHeadBar(Image_PlayerInfoPNL, tb_ResourcesList, tbData)
	tb_ResourcesList = tb_ResourcesList or tb_ResourcesCommon
	if not tbData then return end
	
	local nResourceIconSpace = 50
	local nResourceItemSpace = 10
	local nPlayerInfoPNLWidth = 0
	for k,v in ipairs(tb_ResourcesList) do
		local nSpace = 0
		local Button_ResourceItem = tolua.cast(Image_PlayerInfoPNL:getChildByName(v), "Button")
		local Image_ResourceIcon = tolua.cast(Button_ResourceItem:getChildByName("Image_ResourceIcon"), "ImageView")
		local Label_ResourceValue = tolua.cast(Button_ResourceItem:getChildByName("Label_ResourceValue"), "Label")
		local Button_AddResourceSize = 0
		local Label_ResourceValueSize = 0
		local Image_ResourceIconSize = 0

		if v == "Button_Energy" then
			nSpace = nSpace + 10
			local Button_AddResource = tolua.cast(Button_ResourceItem:getChildByName("Button_AddResource"),"Button")
			Button_AddResource:setPositionX(30)
			Button_AddResourceSize = Button_AddResource:getSize().width - 60
			-- local physicalMaxNum = g_VIPBase:getVipValue("PhysicalMaxNum")
			Label_ResourceValue:setText(tostring(g_Hero:getEnergyString()).."/"..tostring(g_Hero:getMaxEnergy()))
			Label_ResourceValue:setPositionX(0 - Button_AddResourceSize - nSpace)
		elseif v == "Button_YuanBao" then
			nSpace = nSpace + 10
			local Button_AddResource = tolua.cast(Button_ResourceItem:getChildByName("Button_AddResource"),"Button")
			Button_AddResource:setPositionX(30)
			Button_AddResourceSize = Button_AddResource:getSize().width - 60
			Label_ResourceValue:setText(g_Hero:getYuanBaoString())
			Label_ResourceValue:setPositionX(0 - Button_AddResourceSize - nSpace)
		elseif v == "Button_TongQian" then
			nSpace = nSpace + 10
			local Button_AddResource = tolua.cast(Button_ResourceItem:getChildByName("Button_AddResource"),"Button")
			Button_AddResource:setPositionX(30)
			Button_AddResourceSize = Button_AddResource:getSize().width - 60
			Label_ResourceValue:setText(g_Hero:getCoinsString())
			Label_ResourceValue:setPositionX(0 - Button_AddResourceSize - nSpace)
		elseif v == "Button_Prestige" then
			Label_ResourceValue:setText(g_Hero:getPrestigeString())
			Label_ResourceValue:setPositionX(0)
		elseif v == "Button_XueShi" then
			Label_ResourceValue:setText(g_Hero:getKnowledgeString())
			Label_ResourceValue:setPositionX(0)
		elseif v == "Button_Incense" then
			Label_ResourceValue:setText(g_Hero:getIncenseString())
			Label_ResourceValue:setPositionX(0)
		elseif v == "Button_Elements" then
			Label_ResourceValue:setText(g_Hero:getEssenceString())
			Label_ResourceValue:setPositionX(0)
		elseif v == "Button_FriendPoints" then
			Label_ResourceValue:setText(g_Hero:getFriendPointsString())
			Label_ResourceValue:setPositionX(0)
		elseif v == "Button_AreaTimes" then
			Label_ResourceValue:setText(g_Hero:getArenaTimesString())
			nSpace = nSpace + 10
			local Button_AddResource = tolua.cast(Button_ResourceItem:getChildByName("Button_AddResource"),"Button")
			Button_AddResource:setPositionX(30)
			Button_AddResourceSize = Button_AddResource:getSize().width - 60
			Label_ResourceValue:setPositionX(0 - Button_AddResourceSize - nSpace)
		elseif v == "Button_ActiveNess" then
			Label_ResourceValue:setText(g_Hero:getActivenessInfo().activeness)
			Label_ResourceValue:setPositionX(0)
		elseif v == "Button_XianLing" then
			Label_ResourceValue:setText(g_Hero:getXianLingString())
			Label_ResourceValue:setPositionX(0)
		elseif v == "Button_DragonBall" then
			Label_ResourceValue:setText(g_Hero:getDragonBallString())
			Label_ResourceValue:setPositionX(0)
		elseif v == "Button_JiangHunShi" then
			Label_ResourceValue:setText(g_Hero:getJiangHunShi())
			Label_ResourceValue:setPositionX(0)
		elseif v == "Button_RefreshToken" then
			Label_ResourceValue:setText(g_Hero:getRefreshToken())
			Label_ResourceValue:setPositionX(0)
		else
			Label_ResourceValue:setText("Type is nil")
			Label_ResourceValue:setPositionX(0)
		end
		
		Label_ResourceValueSize = Label_ResourceValue:getSize().width
		Image_ResourceIconSize = Image_ResourceIcon:getSize().width
		Image_ResourceIcon:setPositionX(0 - Button_AddResourceSize - Label_ResourceValueSize - nSpace - nResourceIconSpace/2)
		Button_ResourceItem:setSize(CCSizeMake(Button_AddResourceSize + Label_ResourceValueSize + nSpace + nResourceIconSpace, 46))
		Button_ResourceItem:setPositionX(0 - nPlayerInfoPNLWidth - nResourceItemSpace - 12)
		nPlayerInfoPNLWidth = nPlayerInfoPNLWidth + Button_ResourceItem:getSize().width + nResourceItemSpace

	end
	Image_PlayerInfoPNL:setSize(CCSizeMake(nPlayerInfoPNLWidth + nResourceItemSpace + 15,50))
	local fScale = tbData.fScale or 1
	if tbData.tbPos.nAnchorType == 1 then
		Image_PlayerInfoPNL:setScale(fScale)
		Image_PlayerInfoPNL:setPositionXY(tbData.tbPos.x + Image_PlayerInfoPNL:getSize().width*fScale, tbData.tbPos.y)
	elseif tbData.tbPos.nAnchorType == 2 then
		Image_PlayerInfoPNL:setScale(fScale)
		Image_PlayerInfoPNL:setPositionXY(tbData.tbPos.x, tbData.tbPos.y)
	else
		Image_PlayerInfoPNL:setScale(fScale)
		Image_PlayerInfoPNL:setPositionXY(tbData.tbPos.x + Image_PlayerInfoPNL:getSize().width*fScale, tbData.tbPos.y)
	end
end

-- tb_ResourcesList = {}
-- 类型 1:元宝 2钱 3体力 4.暂无  
function Class_HeadBar:addHeadBar(rootWidget, strWndName)
	local tbData = tbWndHeadBar[strWndName]
	if not strWndName or not tbData then
		return
	end
	self.strWndName = strWndName
	if not self.Image_PlayerInfoPNL then
		self.Image_PlayerInfoPNL = tolua.cast(g_WidgetModel.Image_PlayerInfoPNL:clone(), "ImageView")
		self.Image_PlayerInfoPNL:retain()
		self.Button_ResourceItem = tolua.cast(self.Image_PlayerInfoPNL:getChildByName("Button_ResourceItem"),"Button")
        self.Button_ResourceItem:retain()
        self.Button_ResourceItem:removeFromParent()
	end
	self:initHeadBar(self.Image_PlayerInfoPNL, tbData.tb_ResourcesList) 
	self.Image_PlayerInfoPNL:removeFromParent()
	
	-- 窗口关闭会把所有Child的透明度设置为0，所以刷新的时候要归位
	self.Image_PlayerInfoPNL:setOpacity(255)
	if tbData.szParent then
		rootWidget = rootWidget:getChildAllByName(tbData.szParent) 
		rootWidget:addChild(self.Image_PlayerInfoPNL, INT_MAX)
		local widgetBack = tolua.cast(self.Image_PlayerInfoPNL, "ImageView")
		if tbData.nPlayerInfoType == 1 then
			widgetBack:loadTexture(getUIImg("Frame_Common_InfoBack"))
		elseif tbData.nPlayerInfoType == 2 then
			widgetBack:loadTexture(getUIImg("Frame_Common_InfoBack1"))
		else
			widgetBack:loadTexture(getUIImg("Frame_Common_InfoBack"))
		end
		self:adjustHeadBar(self.Image_PlayerInfoPNL, tbData.tb_ResourcesList, tbData)
	else
		rootWidget:addChild(self.Image_PlayerInfoPNL, INT_MAX)
		local widgetBack = tolua.cast(self.Image_PlayerInfoPNL, "ImageView")
		if tbData.nPlayerInfoType == 1 then
			widgetBack:loadTexture(getUIImg("Frame_Common_InfoBack"))
		elseif tbData.nPlayerInfoType == 2 then
			widgetBack:loadTexture(getUIImg("Frame_Common_InfoBack1"))
		else
			widgetBack:loadTexture(getUIImg("Frame_Common_InfoBack"))
		end
		self:adjustHeadBar(self.Image_PlayerInfoPNL, tbData.tb_ResourcesList, tbData)
	end
end

function Class_HeadBar:refreshHeadBar(tbData)
    if self.Image_PlayerInfoPNL then
		
		local instance = g_WndMgr:getCurWnd()
        if not instance then return end

        if tbData then
			cclog("刷新了吗===========================================================")
			-- local rootWidget = instance.rootWidget
			-- local rootWidget = g_WndMgr:getTopWndName(strWndName)
			-- self:addHeadBar(rootWidget, strWndName)
        else
			local rootWidget = instance.rootWidget
			local strWndName = g_WndMgr:getTopWndName()
			self:addHeadBar(rootWidget, strWndName)
			local tbData = tbWndHeadBar[strWndName]
        end
    end
end

function Class_HeadBar:setHeadBarPositionX(nOffsetX)
    if self.Image_PlayerInfoPNL then
		self.Image_PlayerInfoPNL:setPositionX(self.Image_PlayerInfoPNL:getPositionX() + nOffsetX)
    end
end

function Class_HeadBar:destroy()
    if self.Button_ResourceItem then
	    self.Button_ResourceItem:release()
        self.Image_PlayerInfoPNL:release()
    end
end

g_HeadBar = Class_HeadBar:new()