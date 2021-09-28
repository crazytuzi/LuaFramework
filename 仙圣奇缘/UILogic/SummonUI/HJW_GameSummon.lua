--------------------------------------------------------------------------------------
-- 文件名:	Game_Summon.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:
-- 日  期:	2014-11-20 15:07
-- 版  本:	1.0
-- 描  述:	十连抽伙伴奖励
-- 应  用:
---------------------------------------------------------------------------------------
Game_Summon = class("Game_Summon")
Game_Summon.__index = Game_Summon

--向后端发送请求  如果有冷却时间 在登录的时候已经发下
-- function Game_Summon:checkData()
-- end

local tbCooldownTiem = true
local SUMMON_COUNT = 2

function Game_Summon:initWnd()
	local ImageView_Background = tolua.cast(self.rootWidget:getChildByName("ImageView_Background"), "ImageView")
	ImageView_Background:loadTexture(getBackgroundPngImg("Buzhen_Main"))
	local ImageView_Prospect1 = tolua.cast(ImageView_Background:getChildByName("ImageView_Prospect1"), "ImageView")
	ImageView_Prospect1:loadTexture(getBackgroundJpgImg("Buzhen_Prospect1"))
	local ImageView_Prospect2 = tolua.cast(ImageView_Background:getChildByName("ImageView_Prospect2"), "ImageView")
	ImageView_Prospect2:loadTexture(getBackgroundJpgImg("Buzhen_Prospect2"))
	
	g_FormMsgSystem:RegisterFormMsg(FormMsg_Summon_updateData, handler(self, self.updateLogData))
	
end

local function GetKeZhanData()
	local t = {}
	for nIndex , v in pairs(g_Hero.tabSummonCardInfo) do 
		local nTable = {}
		local summonInfo = g_Hero.tabSummonCardInfo[nIndex]
		nTable.free_times = summonInfo.free_times
		--消耗数值
		local CSV_MarketSummon = g_DataMgr:getCsvConfigByOneKey("MarketSummon", nIndex)
		nTable.need_coupon = CSV_MarketSummon.NeedCoupon
		nTable.need_tenExtractCost = CSV_MarketSummon.TenExtractCost
        nTable.need_TokenID = CSV_MarketSummon.TokenID
        nTable.need_TokenLevel = CSV_MarketSummon.TokenLevel
        nTable.need_TokenNumOnce = CSV_MarketSummon.TokenNumOnce
        nTable.need_TokenNumTen = CSV_MarketSummon.TokenNumTen
		local ndif = summonInfo.cooldown - g_GetServerTime()
		if ndif > 0 and summonInfo.cdown > 0--[[剩余时间，这个时间会为0]]  then
			local cooldown = SecondsToTable(ndif)
			nTable.status = _T("免费召唤冷却时间").." "..TimeTableToStr(cooldown,":")
			nTable.btn_type = 1
		elseif not tostring(nTable.free_times) and tonumber(nTable.free_times) == 0 then
			nTable.status = _T("本天免费次数已使用完")
			nTable.btn_type = 1
		else
			if nTable.free_times == 0 then 
				nTable.status = _T("本天免费次数已使用完")
				nTable.btn_type = 1
			else
				nTable.status = string.format(_T("可免费召唤%s次"), tostring(nTable.free_times))
				nTable.btn_type = 2
			end
		end
		table.insert(t,nTable)
	end
	return t
end
--打开窗口的时候使用
function Game_Summon:initView(bRefreshAgain)
	local rootWidget = self.rootWidget 
	if not rootWidget then 
		return 
	end 
	
	local Image_SummonPNL = tolua.cast(self.rootWidget:getChildByName("Image_SummonPNL"), "ImageView")
	--铜钱购买
	local Image_CoinsSummonPNL = tolua.cast(Image_SummonPNL:getChildByName("Image_CoinsSummonPNL"), "ImageView")
	local Image_ContentPNL_Coins = tolua.cast(Image_CoinsSummonPNL:getChildByName("Image_ContentPNL"), "ImageView")
	
	--元宝购买
	local Image_YuanBaoSummonPNL = tolua.cast(Image_SummonPNL:getChildByName("Image_YuanBaoSummonPNL"), "ImageView")
	local Image_ContentPNL_YuanBao = tolua.cast(Image_YuanBaoSummonPNL:getChildByName("Image_ContentPNL"), "ImageView")
	
	local image = {
		Image_ContentPNL_Coins,
		Image_ContentPNL_YuanBao
	}

	local function substitutionTips(costNum)
		if not g_CheckYuanBaoConfirm(costNum, string.format(_T("召唤需要花费%d元宝, 您的元宝不足是否前往充值"), costNum)) then
			return false
		end
		return true
	end
	local times = 0
	local btnFalg = false
	local summonData = GetKeZhanData()
	for typeIndex = 1,SUMMON_COUNT do
		
		local data = summonData[typeIndex]
		local Label_CoolDown = tolua.cast(image[typeIndex]:getChildByName("Label_CoolDown"), "Label")
		Label_CoolDown:setText(data.status)
		local Button_SummonOneChance = tolua.cast(image[typeIndex]:getChildByName("Button_SummonOneChance"), "Button")
		local Image_Label = tolua.cast(Button_SummonOneChance:getChildByName("Image_Label"), "ImageView")
		local Label_Free = tolua.cast(Image_Label:getChildByName("Label_Free"), "Label")--免费
		Label_Free:setVisible(true)
		local Image_Icon = tolua.cast(Image_Label:getChildByName("Image_Icon"), "ImageView")--铜钱图标
		local Label_Price = tolua.cast(Image_Label:getChildByName("Label_Price"), "Label")--消耗数值
		Image_Icon:setVisible(false)
		Label_Price:setVisible(false)

        local nTokenNum = 0
        local strTokenName = "无"
        local strTokenIcon = "无"
        local objItemToken = g_Hero:getItemByCsv(data.need_TokenID, data.need_TokenLevel)  --玩家代币
        if objItemToken ~= "无此道具" then
            nTokenNum = objItemToken:getNum()     --代币数量
            strTokenName = objItemToken:getName() --代币昵称
            strTokenIcon = "Icon_SummonToken"..typeIndex --代币Icon
        end

		--消耗铜钱或元宝召唤伙伴
		if data.btn_type - 1 == 0 then
			Label_Free:setVisible(false)
			Image_Icon:setVisible(true)
			Label_Price:setVisible(true)
            if nTokenNum >= data.need_TokenNumOnce then
                Image_Icon:loadTexture(getUIImg(strTokenIcon))
                Label_Price:setText(data.need_TokenNumOnce)
                g_SetLabelRed(Label_Price, data.need_TokenNumOnce > nTokenNum)    
            else
                Image_Icon:loadTexture(getUIImg("Icon_PlayerInfo_YuanBao"))
			    Label_Price:setText(data.need_coupon)
			    g_SetLabelRed(Label_Price,data.need_coupon > g_Hero:getYuanBao())
            end
		end
		
		local function onExecute(pSender, eventType)
			if eventType == ccs.TouchEventType.ended then
				if data.btn_type - 1 == 0 then
					local flag
                    local msg
                    if nTokenNum >= data.need_TokenNumOnce then
                        local strSummon = "是否消耗%d个%s进行普通召唤？"
                        if typeIndex == SUMMON_COUNT then
                            strSummon = "是否消耗%d个%s进行高级召唤？"
                        end
                        msg = string.format(_T(strSummon), data.need_TokenNumOnce, strTokenName)
                    else 
                        flag = substitutionTips(data.need_coupon,typeIndex)
                        msg = string.format(_T("是否花费%d元宝召唤？"), data.need_coupon)
                        if not flag then return end
                    end
					g_ClientMsgTips:showConfirm(msg, function()
						--预加载窗口缓存防止卡顿
						g_WndMgr:getFormtbRootWidget("Game_SummonAnimation")
						g_MsgMgr:requestSummonCard(typeIndex, false,false)
					end)
					
				else
					--免费召唤伙伴 1次
					--预加载窗口缓存防止卡顿
					g_WndMgr:getFormtbRootWidget("Game_SummonAnimation")
					g_MsgMgr:requestSummonCard(typeIndex,true,false)
				end
			end
		end
		Button_SummonOneChance:setTouchEnabled(true)
		Button_SummonOneChance:addTouchEventListener(onExecute)

		--购买10次 按钮 
		local Button_SummonTenChance = tolua.cast(image[typeIndex]:getChildByName("Button_SummonTenChance"), "Button")
		local Image_Label = tolua.cast(Button_SummonTenChance:getChildByName("Image_Label"), "ImageView")
        local Image_Icon = tolua.cast(Image_Label:getChildByName("Image_Icon"), "ImageView")--铜钱图标
		local Label_Price = tolua.cast(Image_Label:getChildByName("Label_Price"), "Label")
		Label_Price:setVisible(true)
		Label_Price:setText(data.need_tenExtractCost)
        if nTokenNum >= data.need_TokenNumTen then
            Image_Icon:loadTexture(getUIImg(strTokenIcon))
            Label_Price:setText(data.need_TokenNumTen)
            g_SetLabelRed(Label_Price,data.need_TokenNumTen > nTokenNum)    
        else
            Image_Icon:loadTexture(getUIImg("Icon_PlayerInfo_YuanBao"))
		    Label_Price:setText(data.need_tenExtractCost)
            g_SetLabelRed(Label_Price,data.need_tenExtractCost > g_Hero:getYuanBao())
        end
		
		local Image_Label1 = tolua.cast(image[typeIndex]:getChildByName("Image_Label1"), "ImageView")
		local Image_Desc = tolua.cast(Image_Label1:getChildByName("Image_Desc"), "ImageView")
		if typeIndex == 2 then
			if not bRefreshAgain then
				g_CreateScaleInOutAction(Image_Desc)
			end
		end

		local function onSummonTen(pSender, eventType)
			if eventType == ccs.TouchEventType.ended then
	            local flag
                local msg
                if nTokenNum >= data.need_TokenNumTen then
                    local strSummon = "是否消耗%d个%s进行普通十连召唤？"
                    if typeIndex == SUMMON_COUNT then
                        strSummon = "是否消耗%d个%s进行高级十连召唤？"
                    end
                    msg = string.format(_T(strSummon), data.need_TokenNumTen, strTokenName)
                else 
                    if not substitutionTips(data.need_tenExtractCost,typeIndex) then return end
				    msg = string.format(_T("是否花费%d元宝召唤？"), data.need_tenExtractCost)
                end
				
				g_ClientMsgTips:showConfirm(msg, function()
					--预加载窗口缓存防止卡顿
					g_WndMgr:getFormtbRootWidget("Game_SummonAnimation")
					g_WndMgr:openWnd("Game_SummonTenTimes",{callType = typeIndex, tabNeed = GetKeZhanData(),func = function()					
						g_MsgMgr:requestSummonCard(typeIndex, false,true)
					end})
				end)
				
			end
		end
		Button_SummonTenChance:setTouchEnabled(true)
		Button_SummonTenChance:addTouchEventListener(onSummonTen)
	end

	local Button_SummonGuide1 = tolua.cast(Image_SummonPNL:getChildByName("Button_SummonGuide1"), "Button")
	g_RegisterGuideTipButtonWithoutAni(Button_SummonGuide1)
	local Button_SummonGuide2 = tolua.cast(Image_SummonPNL:getChildByName("Button_SummonGuide2"), "Button")
	g_RegisterGuideTipButtonWithoutAni(Button_SummonGuide2)
end


function Game_Summon:openWnd()
	
	g_SummonLogData:requestSummonLogRefresh()
	
	self:initView()
	self.nTimerID_Game_Summon_1 = g_Timer:pushLoopTimer(1,function()
		if not g_WndMgr:getWnd("Game_Summon") then return true end
		self:initView(true)
	end)
	self:showAction()
	
	self:showSummonLog()
	
end


function Game_Summon:closeWnd()
	g_Timer:destroyTimerByID(self.nTimerID_Game_Summon_1)
	self.nTimerID_Game_Summon_1 = nil
	
	local ImageView_Background = tolua.cast(self.rootWidget:getChildByName("ImageView_Background"), "ImageView")
	ImageView_Background:loadTexture(getUIImg("Blank"))
	local ImageView_Prospect1 = tolua.cast(ImageView_Background:getChildByName("ImageView_Prospect1"), "ImageView")
	ImageView_Prospect1:loadTexture(getUIImg("Blank"))
	local ImageView_Prospect2 = tolua.cast(ImageView_Background:getChildByName("ImageView_Prospect2"), "ImageView")
	ImageView_Prospect2:loadTexture(getUIImg("Blank"))
	
	g_FormMsgSystem:UnRegistFormMsg(FormMsg_Summon_updateData)
end

function Game_Summon:showAction()
	local Image_SummonPNL = tolua.cast(self.rootWidget:getChildByName("Image_SummonPNL"), "ImageView")
	--铜钱购买
	local Image_CoinsSummonPNL = tolua.cast(Image_SummonPNL:getChildByName("Image_CoinsSummonPNL"), "ImageView")
	local Image_ContentPNL = tolua.cast(Image_CoinsSummonPNL:getChildByName("Image_ContentPNL"), "ImageView")

	local Image_SymbolBlueLight = tolua.cast(Image_ContentPNL:getChildByName("Image_SymbolBlueLight"), "ImageView")
	Image_SymbolBlueLight:setOpacity(175)
	local ccSprite = tolua.cast(Image_SymbolBlueLight:getVirtualRenderer(),"CCSprite")
	g_SetBlendFuncSprite(ccSprite,4)

	local Image_SymbolOutside = tolua.cast(Image_ContentPNL:getChildByName("Image_SymbolOutside"), "ImageView")
	local actionRotateTo_SymbolOutside = CCRotateBy:create(45, 360)
	local actionForever_SymbolOutside = CCRepeatForever:create(actionRotateTo_SymbolOutside)
	Image_SymbolOutside:runAction(actionForever_SymbolOutside)

	local Image_SymbolInside = tolua.cast(Image_ContentPNL:getChildByName("Image_SymbolInside"), "ImageView")
	local actionRotateTo_SymbolInside = CCRotateBy:create(45, -360)
	local actionForever_SymbolInsidet = CCRepeatForever:create(actionRotateTo_SymbolInside)
	Image_SymbolInside:runAction(actionForever_SymbolInsidet)

	local Image_SummonShow = tolua.cast(Image_ContentPNL:getChildByName("Image_SummonShow"), "ImageView")
	local Panel_Card = Image_SummonShow:getChildByName("Panel_Card")
	local Image_Card = tolua.cast(Panel_Card:getChildByName("Image_Card"),"ImageView")
	local CCNode_Skeleton = g_CocosSpineAnimation("XieZiHei", 1, true)
	Image_Card:removeAllNodes()
	Image_Card:loadTexture(getUIImg("Blank"))
	Image_Card:addNode(CCNode_Skeleton)
	g_runSpineAnimation(CCNode_Skeleton, "idle", true)
	
	--再抽5次必得三星伙伴 
	local Label_RemainCount = tolua.cast(Image_ContentPNL:getChildByName("Label_RemainCount"), "Label")
	Label_RemainCount:setText(string.format(_T("再抽%d次必得三星魂魄"), g_Hero.tabSummonCardInfo[1].times))
	if eLanguageVer.LANGUAGE_viet_VIET == g_LggV:getLanguageVer() then
		Label_RemainCount:setFontSize(16)
	else
		Label_RemainCount:setFontSize(22)
	end
	
	--元宝购买
	local Image_YuanBaoSummonPNL = tolua.cast(Image_SummonPNL:getChildByName("Image_YuanBaoSummonPNL"), "ImageView")
	local Image_ContentPNL = tolua.cast(Image_YuanBaoSummonPNL:getChildByName("Image_ContentPNL"), "ImageView")

	local Image_SymbolBlueLight = tolua.cast(Image_ContentPNL:getChildByName("Image_SymbolBlueLight"), "ImageView")
	Image_SymbolBlueLight:setOpacity(175)
	local ccSprite = tolua.cast(Image_SymbolBlueLight:getVirtualRenderer(),"CCSprite")
	g_SetBlendFuncSprite(ccSprite,4)

	local Image_SymbolOutside = tolua.cast(Image_ContentPNL:getChildByName("Image_SymbolOutside"), "ImageView")
	local actionRotateTo_SymbolOutside = CCRotateBy:create(45, -360)
	local actionForever_SymbolOutside = CCRepeatForever:create(actionRotateTo_SymbolOutside)
	Image_SymbolOutside:runAction(actionForever_SymbolOutside)

	local Image_SymbolInside = tolua.cast(Image_ContentPNL:getChildByName("Image_SymbolInside"), "ImageView")
	local actionRotateTo_SymbolInside = CCRotateBy:create(45, 360)
	local actionForever_SymbolInsidet = CCRepeatForever:create(actionRotateTo_SymbolInside)
	Image_SymbolInside:runAction(actionForever_SymbolInsidet)

	local Image_SummonShow = tolua.cast(Image_ContentPNL:getChildByName("Image_SummonShow"), "ImageView")
	local Panel_Card = Image_SummonShow:getChildByName("Panel_Card")
	local Image_Card = tolua.cast(Panel_Card:getChildByName("Image_Card"),"ImageView")
	local CCNode_Skeleton = g_CocosSpineAnimation("HuXiMei", 1, true)
	Image_Card:removeAllNodes()
	Image_Card:loadTexture(getUIImg("Blank"))
	Image_Card:addNode(CCNode_Skeleton)
	g_runSpineAnimation(CCNode_Skeleton, "idle", true)

	--再抽5次必得三星伙伴
	local Label_RemainCount = tolua.cast(Image_ContentPNL:getChildByName("Label_RemainCount"), "Label")
	Label_RemainCount:setText(string.format(_T("再抽%d次必得三星伙伴"), g_Hero.tabSummonCardInfo[2].times))
	
	if eLanguageVer.LANGUAGE_viet_VIET == g_LggV:getLanguageVer() then
		Label_RemainCount:setFontSize(16)
	else
		Label_RemainCount:setFontSize(22)
	end
end

--在召喚日誌中選擇最新的一條顯示
function Game_Summon:showSummonLog()

	local Image_SummonLogPNL = tolua.cast(self.rootWidget:getChildByName("Image_SummonLogPNL"), "ImageView")
	-- Image_SummonLogPNL:setVisible(false)
	local Label_Log = tolua.cast(Image_SummonLogPNL:getChildByName("Label_Log"), "Label")
	Label_Log:setText("")
	-- self:updateLogData()
	
	local Image_ListViewLight = tolua.cast(Image_SummonLogPNL:getChildByName("Image_ListViewLight"), "ImageView")
	g_CreateFadeInOutAction(Image_ListViewLight, 0, 150, 0.85)
	
	local function showLog(pSender, eventType)
		if eventType == ccs.TouchEventType.ended then
			g_WndMgr:showWnd("Game_SummonLog")			
		end
	end
	Image_SummonLogPNL:setTouchEnabled(true)
	Image_SummonLogPNL:addTouchEventListener(showLog)
	
end


function Game_Summon:updateLogData()
	local txt = ""
	local tbCurTime = g_GetServerTime()
	local tbLog = g_SummonLogData:getSummonLogData()[1]
	
	if tbLog then 
		local nTime = tbCurTime - tbLog.time
		txt = string.format(_T("%s#04%s#00召唤出了三星伙伴[#05%s#00]"),getPrayTime(nTime),tbLog.role_name ,_T(tbLog.card_name) )	
	end
	local Image_SummonLogPNL = tolua.cast(self.rootWidget:getChildByName("Image_SummonLogPNL"), "ImageView")
	local Label_Log = tolua.cast(Image_SummonLogPNL:getChildByName("Label_Log"), "Label")	
	Label_Log:removeAllChildren()
	
	local labelLogWidth = gCreateColorLable(Label_Log, txt)	
	Label_Log:setPositionX(-labelLogWidth/2)
	Label_Log:setPositionY(-50)
end


