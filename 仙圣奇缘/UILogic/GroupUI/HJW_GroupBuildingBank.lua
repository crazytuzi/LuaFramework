--------------------------------------------------------------------------------------
-- 文件名:	HJW_GroupBuildingBank.lua
-- 版  权:	(C)深圳市美天互动有限公司
-- 创建人:	
-- 日  期:	2016-01-14
-- 版  本:	1.0
-- 描  述:	
-- 应  用:  万宝楼
---------------------------------------------------------------------------------------

Game_GuildBank = class("Game_GuildBank")
Game_GuildBank.__index = Game_GuildBank


function Game_GuildBank:initWnd()

	local chooseType = g_Guild:getLastChooseType(1)
	local chooseTimeat = g_Guild:getLastChooseTimeat(1)
	if chooseTimeat ~= 0 then 
		if SecondsToTable( g_GetServerTime() - (chooseTimeat)  ).hour >= 24 then
			 g_Guild:setLastChooseTimeat(1, 0)
			 g_Guild:setLastChooseType(1, 0)
		end
	end
	
end

function Game_GuildBank:openWnd(param)	
	
	if not param then return end
	local buildName = param.buildName
	local buildType = param.buildType
	
	local rootWidget = self.rootWidget
	if not rootWidget then return end 

	local bankLv = g_Guild:getBuildingLevel(buildType);--万宝楼等级
	
	local bankData = g_DataMgr:getCsvConfigByOneKey("GuildBuildingBankLevel",bankLv)
	if not bankData then return end 

	local maxLevel = g_DataMgr:getCsvConfig("GuildBuildingBankLevel")
	local nextBankLv = bankLv + 1 
	if nextBankLv >= #maxLevel  then nextBankLv = bankLv end

	local bankNextData = g_DataMgr:getCsvConfigByOneKey("GuildBuildingBankLevel",nextBankLv)
	if not bankNextData then return end

	local param = {
		buildLevel = bankLv, 
		buildExp = bankData.BuildingExp,--升级需要的经验
		buildNeedMoney = bankData.BuildNeedMoney, --建设需要的铜钱
		buildReward = bankData.RewardInterest,--客户端显示的利率
		nextBuildReward = bankNextData.RewardInterest,--客户端显示的利率
		buildType = buildType,
	}

	local bankDataReward = g_DataMgr:getCsvConfig("GuildBuildingBankReward")
	if not bankDataReward then return end 
	
	local Image_GuildBankPNL = tolua.cast(rootWidget:getChildByName("Image_GuildBankPNL"), "ImageView")
	g_BuildingElement:setBuildInfoView(Image_GuildBankPNL, buildName, param)

	local Image_GuildBankContentPNL = tolua.cast(Image_GuildBankPNL:getChildByName("Image_GuildBankContentPNL"), "ImageView")
	local ListView_BankRewardList = tolua.cast(Image_GuildBankContentPNL:getChildByName("ListView_BankRewardList"), "ListViewEx")
	local Image_BankRewardRowPNL = tolua.cast(ListView_BankRewardList:getChildByName("Image_BankRewardRowPNL"), "ImageView")
	
	local param = { upItemNum = #bankDataReward, buildType = buildType}
	g_BuildingElement:setListImage(ListView_BankRewardList, Image_BankRewardRowPNL, "Button_BankRewardItem", param)

	
end

function Game_GuildBank:closeWnd()
end

--万宝楼
function Game_GuildBank:buttonBank(objPnl, nIndex, buildType)

	local bankDataReward = g_DataMgr:getCsvConfig("GuildBuildingBankReward")

	local bankLevel =  g_Guild:getBuildingLevel(buildType)
	local itemData = bankDataReward[nIndex]
	local bankLevelItemData = itemData[bankLevel]

	--普通银券 Lv.2
	local Label_BankRewardName = tolua.cast(objPnl:getChildByName("Label_BankRewardName"), "Label")
	Label_BankRewardName:setText(itemData.RewardName.." ".._T("Lv.")..bankLevel)
	
	--认购需要铜钱
	local Label_BankRewardDesc1 = tolua.cast(objPnl:getChildByName("Label_BankRewardDesc1"), "Label")
	Label_BankRewardDesc1:setText(string.format(_T("认购需要%d铜钱"), itemData.CostCoins))
	g_setTextColor(Label_BankRewardDesc1,ccs.COLOR.BRIGHT_GREEN)

	local flag = false
	local btnBuy = false
	local openLevelTip = true
	
	--铜钱不足
	if itemData.CostCoins > g_Hero:getCoins() then
		g_setTextColor(Label_BankRewardDesc1,ccs.COLOR.RED)
		btnBuy = false
	end
	
	--建筑等级
	if bankLevel >= itemData.OpenLevel then
		--已经开启
		openLevelTip = false
		btnBuy = true
		flag = true
	end
	
	local chooseType = g_Guild:getLastChooseType(1)
	local txt = ""
	local buyTxt = _T("已认购")
	if chooseType == 0 then 
		txt = _T("未认购, 认购后可获得铜钱返利")
		buyTxt = _T("认购")
		
	else
		if chooseType == nIndex then 
			txt = string.format(_T("24小时后可获得%d铜钱"), bankLevelItemData.ReturnCoins )
			buyTxt = _T("已认购")
			btnBuy = false
		else
			txt = _T("您今天已认购其他项目")
			buyTxt = _T("未认购")
			btnBuy = false
		end
	end
	
	local Label_BankRewardDesc2 = tolua.cast(objPnl:getChildByName("Label_BankRewardDesc2"), "Label")
	Label_BankRewardDesc2:setText(g_stringSize_insert(txt,"\n",21,310))
	Label_BankRewardDesc2:setVisible(flag)
		
	--万宝楼1级解锁
	local Label_OpenLevelTip = tolua.cast(objPnl:getChildByName("Label_OpenLevelTip"), "Label")
	Label_OpenLevelTip:setText(string.format(_T("万宝楼%d级解锁"), itemData.OpenLevel))
	Label_OpenLevelTip:setVisible(openLevelTip)
	
	local Button_Buy = tolua.cast(objPnl:getChildByName("Button_Buy"), "Button")
	--已认购
	
	if bankLevel < itemData.OpenLevel then
		buyTxt = _T("未解锁")
	end
	local BitmapLabel_FuncName = tolua.cast(Button_Buy:getChildByName("BitmapLabel_FuncName"), "LabelBMFont")
	BitmapLabel_FuncName:setText(buyTxt)
	
	if g_LggV.LanguageVer == eLanguageVer.LANGUAGE_viet_VIET  then --越南版
		Label_BankRewardDesc2:setFontSize(18)
		BitmapLabel_FuncName:setScale(0.8)
	end
	
	local function onClick(pSender,eventType)
		if eventType == ccs.TouchEventType.ended then
			-- echoj("购买=====", pSender:getTag())
			local chooseType = g_Guild:getLastChooseType(1)
			if chooseType == pSender:getTag() then 
				echoj("已经购买了")
				return 
			end
			--建筑等级
			if bankLevel < itemData.OpenLevel then
				echoj("还没有到开启等级")
				return 
			end
			
			if g_Guild:getLastChooseTimeat(1) > 0 then 
				echoj("冷却时间还没有结束")
				return 
			end
			
			-- local ndif = summonInfo.cooldown - g_GetServerTime()

			g_BuildingElement:requestGuildBuildBuyReq(buildType, pSender:getTag())
		end
	end

	Button_Buy:setBright(btnBuy)
	Button_Buy:setTouchEnabled(btnBuy)
	Button_Buy:addTouchEventListener(onClick)
	Button_Buy:setTag(nIndex)
	
	local Button_BankRewardIcon = tolua.cast(objPnl:getChildByName("Button_BankRewardIcon"), "Button")
	local Image_Frame = tolua.cast(Button_BankRewardIcon:getChildByName("Image_Frame"), "ImageView")
	local BitmapLabel_OpenLevel = tolua.cast(Button_BankRewardIcon:getChildByName("BitmapLabel_OpenLevel"), "LabelBMFont")
	local function onClickBank(pSender,eventType)
		if eventType == ccs.TouchEventType.ended then
			echoj("出售物品icon")
			local param = {
				CSV_QiShu = itemData,
				nQiShuID = nIndex,
				nTipType = 3,
				buildType = buildType,
			}
			g_WndMgr:showWnd("Game_TipQiShu", param)
			
		end
	end
	Button_BankRewardIcon:setTouchEnabled(true)
	Button_BankRewardIcon:addTouchEventListener(onClickBank)
	Button_BankRewardIcon:loadTextures(getIconImg(itemData.RewardIcon),getIconImg(itemData.RewardIcon),getIconImg(itemData.RewardIcon))

end

