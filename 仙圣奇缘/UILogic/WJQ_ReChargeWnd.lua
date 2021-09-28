--------------------------------------------------------------------------------------
-- 文件名:	LYP_ReChargeWnd.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	yupingli
-- 日  期:	2014-11-21 19:37
-- 版  本:	1.0
-- 描  述:	充值界面
-- 应  用:   
---------------------------------------------------------------------------------------
Game_ReCharge = class("Game_ReCharge")
Game_ReCharge.__index = Game_ReCharge

tbFirstChargeType = nil
if eLanguageVer.LANGUAGE_viet_VIET == g_LggV:getLanguageVer() then
	tbFirstChargeType = {
		-- [101] = macro_pb.FirstOpType_Viet_Recharge_1, --第一次充值美元档1
		-- [102] = macro_pb.FirstOpType_Viet_Recharge_2, --第一次充值美元档2
		-- [103] = macro_pb.FirstOpType_Viet_Recharge_3, --第一次充值美元档3
		-- [104] = macro_pb.FirstOpType_Viet_Recharge_4, --第一次充值美元档4
		-- [105] = macro_pb.FirstOpType_Viet_Recharge_5, --第一次充值美元档5
		-- [106] = macro_pb.FirstOpType_Viet_Recharge_6, --第一次充值美元档6
		[201] = macro_pb.FirstOpType_Recharge_1, --第一次充值档1
		[202] = macro_pb.FirstOpType_Recharge_2, --第一次充值档2
		[203] = macro_pb.FirstOpType_Recharge_3, --第一次充值档3
		[204] = macro_pb.FirstOpType_Recharge_4, --第一次充值档4
		[205] = macro_pb.FirstOpType_Recharge_5, --第一次充值档5
		[206] = macro_pb.FirstOpType_Recharge_6, --第一次充值档6
		[207] = macro_pb.FirstOpType_Recharge_7, --第一次充值档7
		[208] = macro_pb.FirstOpType_Recharge_8, --第一次充值档8
		[209] = macro_pb.FirstOpType_Recharge_9, --第一次充值档9
		[210] = 0, --第一次充值档11
		[211] = 0, --第一次充值档11
		[212] = 0, --第一次充值档10
	}
elseif eLanguageVer.LANGUAGE_cht_Taiwan == g_LggV:getLanguageVer() then
	if g_GamePlatformSystem:GetServerPlatformType() == macro_pb.LOGIN_PLATFORM_TAIWANTAIYOU_ANDROID then
		tbFirstChargeType = {
			[302] = macro_pb.FirstOpType_TW_Recharge_2, --第一次充值档1
			[306] = 0, --第一次充值档9
			[307] = 0, --第一次充值档10
			[309] = 0, --第一次充值档11
			[310] = macro_pb.FirstOpType_TW_Recharge_10, --第一次充值档1
			[311] = macro_pb.FirstOpType_TW_Recharge_11, --第一次充值档2
			[312] = macro_pb.FirstOpType_TW_Recharge_12, --第一次充值档3
			[313] = macro_pb.FirstOpType_TW_Recharge_13, --第一次充值档4
			[314] = macro_pb.FirstOpType_TW_Recharge_14, --第一次充值档5
			[315] = macro_pb.FirstOpType_TW_Recharge_15, --第一次充值档5
			[316] = macro_pb.FirstOpType_TW_Recharge_16, --第一次充值档5
			[317] = macro_pb.FirstOpType_TW_Recharge_17, --第一次充值档5
			[318] = macro_pb.FirstOpType_TW_Recharge_18, --第一次充值档5
			[319] = macro_pb.FirstOpType_TW_Recharge_19, --第一次充值档5
			[320] = macro_pb.FirstOpType_TW_Recharge_20, --第一次充值档5
			[321] = macro_pb.FirstOpType_TW_Recharge_21, --第一次充值档5
			[322] = macro_pb.FirstOpType_TW_Recharge_22, --第一次充值档5
			[323] = macro_pb.FirstOpType_TW_Recharge_23, --第一次充值档5
		}
	else
		tbFirstChargeType = {
			[301] = macro_pb.FirstOpType_TW_Recharge_1, --第一次充值档1
			[302] = macro_pb.FirstOpType_TW_Recharge_2, --第一次充值档2
			[303] = macro_pb.FirstOpType_TW_Recharge_3, --第一次充值档3
			[304] = macro_pb.FirstOpType_TW_Recharge_4, --第一次充值档4
			[305] = macro_pb.FirstOpType_TW_Recharge_5, --第一次充值档5
			[306] = 0, --第一次充值档9
			[307] = 0, --高级月卡
			[308] = 0, --开服基金
		}
	end
else
	tbFirstChargeType = {
		[1] = macro_pb.FirstOpType_Recharge_1, --第一次充值档1
		[2] = macro_pb.FirstOpType_Recharge_2, --第一次充值档2
		[3] = macro_pb.FirstOpType_Recharge_3, --第一次充值档3
		[4] = macro_pb.FirstOpType_Recharge_4, --第一次充值档4
		[5] = macro_pb.FirstOpType_Recharge_5, --第一次充值档5
		[6] = macro_pb.FirstOpType_Recharge_6, --第一次充值档6
		[7] = macro_pb.FirstOpType_Recharge_7, --第一次充值档7
		[8] = macro_pb.FirstOpType_Recharge_8, --第一次充值档8
		[9] = 0, --普通月卡
		[10] = 0, --高级月卡
		[11] = 0, --开服基金
	}
end

FunctionType = {
	[1] = "ChargeOption", --初级月卡
	[2] = "MonthlyCard_Primary", --初级月卡
	[3] = "MonthlyCard_Senior", --高级月卡
	[4] = "ServerFund", --开服基金
}

g_CurReChargeListIndex = 1

local function onClick_Button_ShowVIP()
    g_WndMgr:openWnd("Game_VIP")
end

function Game_ReCharge:initWnd()
	local Image_ReChargePNL = tolua.cast(self.rootWidget:getChildByName("Image_ReChargePNL"),"ImageView")
	local Image_ContentPNL = tolua.cast(Image_ReChargePNL:getChildByName("Image_ContentPNL"),"ImageView")
	
	local ListView_ChargeList = tolua.cast(Image_ContentPNL:getChildByName("ListView_ChargeList"),"ListViewEx")
    local LuaListView_ReChargeList = Class_LuaListView:new()
    LuaListView_ReChargeList:setListView(ListView_ChargeList)
    local Image_ChargeRowPNL = ListView_ChargeList:getChildByName("Image_ChargeRowPNL")
    LuaListView_ReChargeList:setModel(Image_ChargeRowPNL)
    LuaListView_ReChargeList:setUpdateFunc(handler(self, self.onUpdate_Image_ChargeRowPNL)) 
    LuaListView_ReChargeList:setAdjustFunc(handler(self, self.adjustListViewItem)) 
    self.LuaListView_ReChargeList = LuaListView_ReChargeList 
	
	local imgScrollSlider = LuaListView_ReChargeList:getScrollSlider()
	if not g_tbScrollSliderXY.LuaListView_ReChargeList_Y then
		g_tbScrollSliderXY.LuaListView_ReChargeList_Y = imgScrollSlider:getPositionY()
	end
	imgScrollSlider = imgScrollSlider:setPositionY(g_tbScrollSliderXY.LuaListView_ReChargeList_Y + 8)
	
	local Button_ShowVIP = tolua.cast(Image_ReChargePNL:getChildByName("Button_ShowVIP"), "Button")
	g_SetBtnWithEvent(Button_ShowVIP, 1, onClick_Button_ShowVIP, true)
	
	local Image_Check = tolua.cast(Button_ShowVIP:getChildByName("Image_Check"), "ImageView")
	local ccSpriteCheck = tolua.cast(Image_Check:getVirtualRenderer(),"CCSprite")
	g_SetBlendFuncSprite(ccSpriteCheck, 4)
	g_CreateFadeInOutAction(Image_Check, 0, 100, 0.5)
	
	local ImageView_Background1 = tolua.cast(self.rootWidget:getChildByName("ImageView_Background1"), "ImageView")
	ImageView_Background1:loadTexture(getBackgroundJpgImg("Background_Money1"))
	local ImageView_Background2 = tolua.cast(self.rootWidget:getChildByName("ImageView_Background2"), "ImageView")
	ImageView_Background2:loadTexture(getBackgroundPngImg("Background_Money2"))
	local ImageView_Background3 = tolua.cast(self.rootWidget:getChildByName("ImageView_Background3"), "ImageView")
	ImageView_Background3:loadTexture(getBackgroundPngImg("Background_Money3"))
	
	self:initShopRechargeCsvInSort()
	
    g_FormMsgSystem:RegisterFormMsg(FormMsg_ReCharge_UpdataWnd, handler(self, self.updataWnd))
end 

function Game_ReCharge:releaseWnd()
    g_FormMsgSystem:UnRegistFormMsg(FormMsg_ReCharge_UpdataWnd)
end

---更新充值界面数据，在充值后会调用
function Game_ReCharge:updataWnd(nGetValue)
	local function updateHeroResourceInfo()
		local wndInstance = g_WndMgr:getWnd("Game_ReCharge")
		if wndInstance then
			wndInstance:initShopRechargeCsvInSort()
			wndInstance:updateReCharge()
			local nRowCount = math.ceil(#wndInstance.tbShopRechargeCsvInSort/3)
			wndInstance.LuaListView_ReChargeList:updateItems(nRowCount, g_CurReChargeListIndex or 1)
		end
	end
	
	--这个动画改成了先update主角的数值在弹出动画，以免出现动画出错导致前后台数值不匹配
	g_ShowRewardMsgConfrim(macro_pb.ITEM_TYPE_COUPONS, nGetValue, updateHeroResourceInfo)
end

function Game_ReCharge:closeWnd()
    self.LuaListView_ReChargeList:updateItems(0)
	local ImageView_Background1 = tolua.cast(self.rootWidget:getChildByName("ImageView_Background1"), "ImageView")
	ImageView_Background1:loadTexture(getUIImg("Blank"))
	local ImageView_Background2 = tolua.cast(self.rootWidget:getChildByName("ImageView_Background2"), "ImageView")
	ImageView_Background2:loadTexture(getUIImg("Blank"))
	local ImageView_Background3 = tolua.cast(self.rootWidget:getChildByName("ImageView_Background3"), "ImageView")
	ImageView_Background3:loadTexture(getUIImg("Blank"))
	
	self.rootWidget:removeAllNodes()
end

function Game_ReCharge:updateReCharge()
	local Image_ReChargePNL = tolua.cast(self.rootWidget:getChildByName("Image_ReChargePNL"),"ImageView")
	
    local Label_Tip1 = tolua.cast(Image_ReChargePNL:getChildByName("Label_Tip1"), "Label")
	local CCNode_Tip1 = tolua.cast(Label_Tip1:getVirtualRenderer(), "CCLabelTTF")
	CCNode_Tip1:disableShadow(true)
	
    local Image_YuanBao = Image_ReChargePNL:getChildByName("Image_YuanBao")
    local Label_NeedCharge = tolua.cast(Image_ReChargePNL:getChildByName("Label_NeedCharge"), "Label")
	local CCNode_NeedCharge = tolua.cast(Label_NeedCharge:getVirtualRenderer(), "CCLabelTTF")
	CCNode_NeedCharge:disableShadow(true)
	
	local Label_Tip2 = tolua.cast(Image_ReChargePNL:getChildByName("Label_Tip2"), "Label")
	local CCNode_Tip2 = tolua.cast(Label_Tip2:getVirtualRenderer(), "CCLabelTTF")
	CCNode_Tip2:disableShadow(true)
	
    local Image_VIPLevel = tolua.cast(Image_ReChargePNL:getChildByName("Image_VIPLevel"),"ImageView")
    local tbWidget = {Label_Tip1, Image_YuanBao, Label_NeedCharge, Label_Tip2}

    local nVipLev = g_VIPBase:getVIPLevelId()
    local strTip, strNeedMoney = nil,nil
    if nVipLev <= 0 then
        strTip = _T("您还未拥有vip卡, 充值")
		local CSV_VipLevelRight = g_DataMgr:getCsvConfig_FirstKeyData("VipLevelRight",1)
        strNeedMoney = string.format("%d",CSV_VipLevelRight.ExpMax- g_Hero.tbMasterBase.nTotalChargeYuanBao)
        nVipLev = nVipLev + 1
    else
		local nMaxLevel = #g_DataMgr:getCsvConfig("VipLevel") - 1
        if nVipLev >= nMaxLevel then
           local strTip = _T("恭喜，您VIP等级已达到最高级")
           for i=2, #tbWidget do
               tbWidget[i]:setVisible(false)
           end
		   Label_Tip1:setText(strTip)
		   Image_VIPLevel:loadTexture(getShopMallImg("VIP"..nVipLev))
           g_AdjustWidgetsPosition({Label_Tip1, Image_VIPLevel}, 0)
           return
        end

        strTip = string.format(_T("您现在是VIP%d, 充值"), nVipLev)
        nVipLev = nVipLev + 1
		local CSV_VipLevelRight = g_DataMgr:getCsvConfig_FirstKeyData("VipLevelRight", nVipLev)
        local dif = CSV_VipLevelRight.ExpMax - g_Hero.tbMasterBase.nTotalChargeYuanBao
        strNeedMoney = string.format("%d",dif)
    end
	
    for i = 2, #tbWidget do
        tbWidget[i]:setVisible(true)
    end
    Label_Tip1:setText(strTip)
    Label_NeedCharge:setText(strNeedMoney)
    Image_VIPLevel:loadTexture(getShopMallImg("VIP"..nVipLev))
	
	Label_Tip1:setPositionX(-310)
    g_AdjustWidgetsPosition({Label_Tip1,Image_YuanBao,Label_NeedCharge,Label_Tip2,Image_VIPLevel},4)
end

--商城数据排序

local function sortShopRechargeCsv(CSV_ShopRechargeA, CSV_ShopRechargeB)
	return CSV_ShopRechargeA.SortRank > CSV_ShopRechargeB.SortRank
end

function Game_ReCharge:initShopRechargeCsvInSort()
	self.tbShopRechargeCsvInSort = {}
	for k, v in pairs (tbFirstChargeType) do
		cclog("=============tbFirstChargeType============="..k)
		local CSV_ShopRecharge = g_DataMgr:getCsvConfigByOneKey("ShopRecharge", k)
		if CSV_ShopRecharge.ID > 0 then
			cclog("=============充值ID============="..CSV_ShopRecharge.ID)
			if FunctionType[CSV_ShopRecharge.FunctionType] == "MonthlyCard_Primary" then -- 普通月卡
				if not isYuekaEnabled(common_pb.RewardType_MonthYuanbao1) then
					CSV_ShopRecharge.SortRank = 31
				else
					CSV_ShopRecharge.SortRank = 1
				end
			elseif FunctionType[CSV_ShopRecharge.FunctionType] == "MonthlyCard_Senior" then -- 高级月卡
				if not isYuekaEnabled(common_pb.RewardType_MonthYuanbao2) then
					CSV_ShopRecharge.SortRank = 32
				else
					CSV_ShopRecharge.SortRank = 2
				end
			elseif FunctionType[CSV_ShopRecharge.FunctionType] == "ServerFund" then -- 开服基金
				if not Act_KaiFuJiJin:isBuy() then
					CSV_ShopRecharge.SortRank = 33
				else
					CSV_ShopRecharge.SortRank = 3
				end
			end
			table.insert(self.tbShopRechargeCsvInSort, CSV_ShopRecharge)
		end
	end
	table.sort(self.tbShopRechargeCsvInSort, sortShopRechargeCsv)
end

function Game_ReCharge:getShopRechargeCsvInSort(nSortRank)
	local nSortRank = nSortRank or 0
	
    local tbCsv = self.tbShopRechargeCsvInSort[nSortRank]
    if not tbCsv then
		return ConfigMgr.ShopRecharge_[0]
	end
	return tbCsv
end

function Game_ReCharge:adjustListViewItem(Image_ChargeRowPNL, nIndex)
    self.nAdjustIndex = nIndex
	g_CurReChargeListIndex = nIndex
end

local function onClick_Button_ReChargeItem(pSender, nSortRank)
	if g_LggV:getLanguageVer() ==  eLanguageVer.LANGUAGE_zh_AUDIT then
		g_ClientMsgTips:showMsgConfirm(_T("...游戏处于测试中暂未开放充值..."))
		return
	end
	
	local wndInstance = g_WndMgr:getWnd("Game_ReCharge")
	if wndInstance then
		local CSV_ShopRecharge = wndInstance:getShopRechargeCsvInSort(nSortRank)
		if FunctionType[CSV_ShopRecharge.FunctionType] == "MonthlyCard_Primary" then
			g_GamePlatformSystem:RequestBillNum(CSV_ShopRecharge.ID)
		elseif FunctionType[CSV_ShopRecharge.FunctionType] == "MonthlyCard_Senior" then
			g_GamePlatformSystem:RequestBillNum(CSV_ShopRecharge.ID)
		elseif FunctionType[CSV_ShopRecharge.FunctionType] == "ServerFund" then
			if Act_KaiFuJiJin:isBuy() then
				g_ShowSysWarningTips({text =_T("您的已购买了开服基金")})
				return
			end
			g_GamePlatformSystem:RequestBillNum(CSV_ShopRecharge.ID)
		else
			g_GamePlatformSystem:RequestBillNum(CSV_ShopRecharge.ID)
		end
	end
end

function Game_ReCharge:onUpdate_Button_ChargeColumn(Button_ChargeColumn, nSortRank, nColumn)
	if not Button_ChargeColumn then return end
	if not nSortRank then return end
	
	Button_ChargeColumn:setTag(nSortRank)
	
	local CSV_ShopRecharge = self:getShopRechargeCsvInSort(nSortRank)
	if not CSV_ShopRecharge or CSV_ShopRecharge.ID == 0 then
		Button_ChargeColumn:setVisible(false)
		return
	end
	
	local Image_Icon = tolua.cast(Button_ChargeColumn:getChildByName("Image_Icon"),"ImageView")
	Image_Icon:loadTexture(getShopMallImg(CSV_ShopRecharge.Icon))
	Image_Icon:setPositionY(CSV_ShopRecharge.IconPosY)
	
	local Image_Title = tolua.cast(Button_ChargeColumn:getChildByName("Image_Title"),"ImageView")
	Image_Title:loadTexture(getShopMallImg(CSV_ShopRecharge.Title))
	
	local Image_FuncIcon = tolua.cast(Button_ChargeColumn:getChildByName("Image_FuncIcon"),"ImageView")
    local BitmapLabel_SellNum = tolua.cast(Image_FuncIcon:getChildByName("BitmapLabel_SellNum"),"LabelBMFont")
	BitmapLabel_SellNum:setText(CSV_ShopRecharge.SellNum)
	Image_FuncIcon:setPositionX(CSV_ShopRecharge.ValuePosX)
	
	local Image_Tag = tolua.cast(Button_ChargeColumn:getChildByName("Image_Tag"),"ImageView")
	local Image_ReturnYuanBao = tolua.cast(Button_ChargeColumn:getChildByName("Image_ReturnYuanBao"),"ImageView")
	local Label_FirstChargeReturn = tolua.cast(Image_ReturnYuanBao:getChildByName("Label_FirstChargeReturn"), "Label")
	Label_FirstChargeReturn:setText(CSV_ShopRecharge.Desc)
	
	if g_LggV.LanguageVer == eLanguageVer.LANGUAGE_viet_VIET  then --越南版
		Label_FirstChargeReturn:setFontSize(18)
	end
	
	local CCNode_FirstChargeReturn = tolua.cast(Label_FirstChargeReturn:getVirtualRenderer(), "CCLabelTTF")
	CCNode_FirstChargeReturn:disableShadow(true)
	
	g_SetBtnWithPressImage(Button_ChargeColumn, nSortRank, onClick_Button_ReChargeItem, true, 1)
	
	local Image_XianGou = tolua.cast(Button_ChargeColumn:getChildByName("Image_XianGou"),"ImageView")

	local Label_Tip = tolua.cast(Image_Tag:getChildByName("Label_Tip"),"Label")
	local Image_Check = tolua.cast(Button_ChargeColumn:getChildByName("Image_Check"),"ImageView")
	if CSV_ShopRecharge.FirstChargeReturn > 0 then
		if g_Hero:GetFirstOpState(tbFirstChargeType[CSV_ShopRecharge.ID]) then
			Image_Tag:setVisible(true)
			Image_ReturnYuanBao:setVisible(true)
			Image_XianGou:setVisible(true)
			Image_XianGou:loadTexture(getShopMallImg("Char_XianGou"))
			Label_Tip:setText(_T("首充"))
		else
			if CSV_ShopRecharge.Recommend == 1 then
				if FunctionType[CSV_ShopRecharge.FunctionType] == "MonthlyCard_Primary" then
					if not isYuekaEnabled(common_pb.RewardType_MonthYuanbao1) then
						if g_bVersionTS_0_0_ ~= nil and g_bVersionTS_0_0_ == g_NeelDisableVersion then
							Label_Tip:setText(_T("推荐"))
							Image_ReturnYuanBao:setVisible(false)
							Image_XianGou:setVisible(false)
							Image_XianGou:loadTexture(getShopMallImg("Char_LiJiHuoDe"))
						else
							Label_Tip:setText(_T("推荐"))
							Image_ReturnYuanBao:setVisible(true)
							Image_XianGou:setVisible(true)
							Image_XianGou:loadTexture(getShopMallImg("Char_LiJiHuoDe"))
						end
					else
						Label_Tip:setText(_T("已购"))
						Image_ReturnYuanBao:setVisible(false)
						Image_XianGou:setVisible(false)
					end
				elseif FunctionType[CSV_ShopRecharge.FunctionType] == "MonthlyCard_Senior" then
					if not isYuekaEnabled(common_pb.RewardType_MonthYuanbao2) then
						if g_bVersionTS_0_0_ ~= nil and g_bVersionTS_0_0_ == g_NeelDisableVersion then
							Label_Tip:setText(_T("推荐"))
							Image_ReturnYuanBao:setVisible(false)
							Image_XianGou:setVisible(false)
							Image_XianGou:loadTexture(getShopMallImg("Char_LiJiHuoDe"))
						else
							Label_Tip:setText(_T("推荐"))
							Image_ReturnYuanBao:setVisible(true)
							Image_XianGou:setVisible(true)
							Image_XianGou:loadTexture(getShopMallImg("Char_LiJiHuoDe"))
						end
					else
						Label_Tip:setText(_T("已购"))
						Image_ReturnYuanBao:setVisible(false)
						Image_XianGou:setVisible(false)
					end
				elseif FunctionType[CSV_ShopRecharge.FunctionType] == "ServerFund" then
					if not Act_KaiFuJiJin:isBuy() then
						if g_bVersionTS_0_0_ ~= nil and g_bVersionTS_0_0_ == g_NeelDisableVersion then
							Label_Tip:setText(_T("推荐"))
							Image_ReturnYuanBao:setVisible(false)
							Image_XianGou:setVisible(false)
							Image_XianGou:loadTexture(getShopMallImg("Char_LiJiHuoDe"))
						else
							Label_Tip:setText(_T("推荐"))
							Image_ReturnYuanBao:setVisible(true)
							Image_XianGou:setVisible(true)
							Image_XianGou:loadTexture(getShopMallImg("Char_LiJiHuoDe"))
						end
					else
						Label_Tip:setText(_T("已购"))
						Image_ReturnYuanBao:setVisible(false)
						Image_XianGou:setVisible(false)
						Button_ChargeColumn:setBright(false)
						Button_ChargeColumn:setTouchEnabled(false)
						Image_Check:setVisible(false)
						g_setImgShader(Image_Icon, pszGreyFragSource)
					end
				else
					Label_Tip:setText(_T("推荐"))
					Image_ReturnYuanBao:setVisible(false)
					Image_XianGou:setVisible(false)
				end
				
				Image_Tag:setVisible(true)
			else
				Image_Tag:setVisible(false)
				Image_ReturnYuanBao:setVisible(false)
				Image_XianGou:setVisible(false)
			end
		end
	else
		if CSV_ShopRecharge.Recommend == 1 then
			if FunctionType[CSV_ShopRecharge.FunctionType] == "MonthlyCard_Primary" then
				if not isYuekaEnabled(common_pb.RewardType_MonthYuanbao1) then
					if g_bVersionTS_0_0_ ~= nil and g_bVersionTS_0_0_ == g_NeelDisableVersion then
						Label_Tip:setText(_T("推荐"))
						Image_ReturnYuanBao:setVisible(false)
						Image_XianGou:setVisible(false)
						Image_XianGou:loadTexture(getShopMallImg("Char_LiJiHuoDe"))
					else
						Label_Tip:setText(_T("推荐"))
						Image_ReturnYuanBao:setVisible(true)
						Image_XianGou:setVisible(true)
						Image_XianGou:loadTexture(getShopMallImg("Char_LiJiHuoDe"))
					end
				else
					Label_Tip:setText(_T("已购"))
					Image_ReturnYuanBao:setVisible(false)
					Image_XianGou:setVisible(false)
				end
			elseif FunctionType[CSV_ShopRecharge.FunctionType] == "MonthlyCard_Senior" then
				if not isYuekaEnabled(common_pb.RewardType_MonthYuanbao2) then
					if g_bVersionTS_0_0_ ~= nil and g_bVersionTS_0_0_ == g_NeelDisableVersion then
						Label_Tip:setText(_T("推荐"))
						Image_ReturnYuanBao:setVisible(false)
						Image_XianGou:setVisible(false)
						Image_XianGou:loadTexture(getShopMallImg("Char_LiJiHuoDe"))
					else
						Label_Tip:setText(_T("推荐"))
						Image_ReturnYuanBao:setVisible(true)
						Image_XianGou:setVisible(true)
						Image_XianGou:loadTexture(getShopMallImg("Char_LiJiHuoDe"))
					end
				else
					Label_Tip:setText(_T("已购"))
					Image_ReturnYuanBao:setVisible(false)
					Image_XianGou:setVisible(false)
				end
			elseif FunctionType[CSV_ShopRecharge.FunctionType] == "ServerFund" then
				if not Act_KaiFuJiJin:isBuy() then
					if g_bVersionTS_0_0_ ~= nil and g_bVersionTS_0_0_ == g_NeelDisableVersion then
						Label_Tip:setText(_T("推荐"))
						Image_ReturnYuanBao:setVisible(false)
						Image_XianGou:setVisible(false)
						Image_XianGou:loadTexture(getShopMallImg("Char_LiJiHuoDe"))
					else
						Label_Tip:setText(_T("推荐"))
						Image_ReturnYuanBao:setVisible(true)
						Image_XianGou:setVisible(true)
						Image_XianGou:loadTexture(getShopMallImg("Char_LiJiHuoDe"))
					end
				else
					Label_Tip:setText(_T("已购"))
					Image_ReturnYuanBao:setVisible(false)
					Image_XianGou:setVisible(false)
					Button_ChargeColumn:setBright(false)
					Button_ChargeColumn:setTouchEnabled(false)
					Image_Check:setVisible(false)
					g_setImgShader(Image_Icon, pszGreyFragSource)
				end
			else
				Label_Tip:setText(_T("推荐"))
				Image_ReturnYuanBao:setVisible(false)
				Image_XianGou:setVisible(false)
			end
			
			Image_Tag:setVisible(true)
		else
			Image_Tag:setVisible(false)
			Image_ReturnYuanBao:setVisible(false)
			Image_XianGou:setVisible(false)
		end
	end
	
		
	if g_LggV.LanguageVer == eLanguageVer.LANGUAGE_viet_VIET  then --越南版
		Label_Tip:setFontSize(18)
	end
end

function Game_ReCharge:onUpdate_Image_ChargeRowPNL(Image_ChargeRowPNL, nRow)
	Image_ChargeRowPNL:setTag(nRow)
	local nCurBeginColumn = (nRow - 1) * 3
	for nColumn = 1, 3 do
		local nSortRank = nCurBeginColumn + nColumn
		local Button_ChargeColumn = tolua.cast(Image_ChargeRowPNL:getChildByName("Button_ChargeColumn"..nColumn), "Button")
		self:onUpdate_Button_ChargeColumn(Button_ChargeColumn, nSortRank, nColumn)
	end
end 

--显示主界面的伙伴详细介绍界面
function Game_ReCharge:openWnd(tbParam)
	if g_bReturn then return end
	self:updateReCharge()
	if tbParam and tbParam.ListViewIndex then
		g_CurReChargeListIndex = tbParam.ListViewIndex or 1
	else
		g_CurReChargeListIndex = 1
	end
	local nRowCount = math.ceil(#self.tbShopRechargeCsvInSort/3)
	self.LuaListView_ReChargeList:updateItems(nRowCount, g_CurReChargeListIndex)
	
	self.rootWidget:removeAllNodes()
	if tbParam then
		if tbParam.OpenType == "KaiFuJiJin" then
			if not Act_KaiFuJiJin:isBuy() then
				local nCurIndex = 1
				for nIndex = 1, #self.tbShopRechargeCsvInSort do
					local CSV_ShopRecharge = self.tbShopRechargeCsvInSort[nIndex]
					if FunctionType[CSV_ShopRecharge.FunctionType] == "ServerFund" then
						nCurIndex = nIndex
						break
					end
				end
				local Image_ReChargePNL = tolua.cast(self.rootWidget:getChildByName("Image_ReChargePNL"),"ImageView")
				local Image_ContentPNL = tolua.cast(Image_ReChargePNL:getChildByName("Image_ContentPNL"),"ImageView")
				local ListView_ChargeList = tolua.cast(Image_ContentPNL:getChildByName("ListView_ChargeList"),"ListViewEx")
				
				local nRow = math.ceil(nCurIndex/3)
				local nColumn = math.mod(nCurIndex-1, 3) + 1
				local Image_ChargeRowPNL = ListView_ChargeList:getChildByTag(nRow)
				if Image_ChargeRowPNL then
					local Button_ChargeColumn = tolua.cast(Image_ChargeRowPNL:getChildByName("Button_ChargeColumn"..nColumn), "Button")
					local armature, userAnimation = g_CreateCoCosAnimation("OnTouchGuide", nil, 2)
					userAnimation:playWithIndex(0)
					Button_ChargeColumn:addNode(armature, INT_MAX)
				end
			end
		elseif tbParam.OpenType == "PuTongYueKa" then
			if not isYuekaEnabled(common_pb.RewardType_MonthYuanbao1) then
				local nCurIndex = 1
				for nIndex = 1, #self.tbShopRechargeCsvInSort do
					local CSV_ShopRecharge = self.tbShopRechargeCsvInSort[nIndex]
					if FunctionType[CSV_ShopRecharge.FunctionType] == "MonthlyCard_Primary" then
						nCurIndex = nIndex
						break
					end
				end
				local Image_ReChargePNL = tolua.cast(self.rootWidget:getChildByName("Image_ReChargePNL"),"ImageView")
				local Image_ContentPNL = tolua.cast(Image_ReChargePNL:getChildByName("Image_ContentPNL"),"ImageView")
				local ListView_ChargeList = tolua.cast(Image_ContentPNL:getChildByName("ListView_ChargeList"),"ListViewEx")
				
				local nRow = math.ceil(nCurIndex/3)
				local nColumn = math.mod(nCurIndex-1, 3) + 1
				local Image_ChargeRowPNL = ListView_ChargeList:getChildByTag(nRow)
				if Image_ChargeRowPNL then
					local Button_ChargeColumn = tolua.cast(Image_ChargeRowPNL:getChildByName("Button_ChargeColumn"..nColumn), "Button")
					if Button_ChargeColumn then
						local armature, userAnimation = g_CreateCoCosAnimation("OnTouchGuide", nil, 2)
						userAnimation:playWithIndex(0)
						Button_ChargeColumn:addNode(armature, INT_MAX)
					end
				end
			end
		elseif tbParam.OpenType == "GaoJiYueKa" then
			if not isYuekaEnabled(common_pb.RewardType_MonthYuanbao2) then
				local nCurIndex = 1
				for nIndex = 1, #self.tbShopRechargeCsvInSort do
					local CSV_ShopRecharge = self.tbShopRechargeCsvInSort[nIndex]
					if FunctionType[CSV_ShopRecharge.FunctionType] == "MonthlyCard_Senior" then
						nCurIndex = nIndex
						break
					end
				end
				local Image_ReChargePNL = tolua.cast(self.rootWidget:getChildByName("Image_ReChargePNL"),"ImageView")
				local Image_ContentPNL = tolua.cast(Image_ReChargePNL:getChildByName("Image_ContentPNL"),"ImageView")
				local ListView_ChargeList = tolua.cast(Image_ContentPNL:getChildByName("ListView_ChargeList"),"ListViewEx")
				
				local nRow = math.ceil(nCurIndex/3)
				local nColumn = math.mod(nCurIndex-1, 3) + 1
				local Image_ChargeRowPNL = ListView_ChargeList:getChildByTag(nRow)
				if Image_ChargeRowPNL then
					local Button_ChargeColumn = tolua.cast(Image_ChargeRowPNL:getChildByName("Button_ChargeColumn"..nColumn), "Button")
					if Button_ChargeColumn then
						local armature, userAnimation = g_CreateCoCosAnimation("OnTouchGuide", nil, 2)
						userAnimation:playWithIndex(0)
						Button_ChargeColumn:addNode(armature, INT_MAX)
					end
				end
			end
		end
	end
end

function Game_ReCharge:ModifyWnd_viet_VIET()
    local Label_Tip1 = tolua.cast(self.rootWidget:getChildAllByName("Label_Tip1"),"Label")
    Label_Tip1:setPositionX(-325)
    local Image_YuanBao = tolua.cast(self.rootWidget:getChildAllByName("Image_YuanBao"), "ImageView")
    local Label_NeedCharge = tolua.cast(self.rootWidget:getChildAllByName("Label_NeedCharge"), "Label")
    local Label_Tip2 = tolua.cast(self.rootWidget:getChildAllByName("Label_Tip2"), "Label")
    local Image_VIPLevel = tolua.cast(self.rootWidget:getChildAllByName("Image_VIPLevel"), "ImageView")
    g_AdjustWidgetsPosition({Label_Tip1, Image_YuanBao, Label_NeedCharge, Label_Tip2, Image_VIPLevel},1)

end