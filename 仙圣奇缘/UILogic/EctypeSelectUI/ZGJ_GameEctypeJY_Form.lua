--------------------------------------------------------------------------------------
-- 文件名:	Class_Fate.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	周光剑
-- 日  期:	2015-6-30
-- 版  本:	1.0
-- 描  述:	精英副本Form
-- 应  用:  
---------------------------------------------------------------------------------------

Game_EctypeJY = class("Game_EctypeJY")
Game_EctypeJY.__index = Game_EctypeJY

function Game_EctypeJY:ctor()
	--深渊副本自己保存自己的spine存
	self.tbJYSpine = {}
end

function Game_EctypeJY:isEnabled(nPage, nIndex, mapID)
	if self.nFinalClearMapID <= mapID then
		return false
	end
	if g_EctypeJY:isPassed(nPage, nIndex) then
		self.bNextEnabled = true
		return true
	elseif self.bNextEnabled then
		self.bNextEnabled = false
		return true
	elseif nPage == 1 and nIndex == 1 and self.bFirstEnabled then
		return true
	end
	return false
end

function Game_EctypeJY:updatePageViewItem(widget, nPage)

	cclog("=======Game_EctypeJY:updatePageViewItem======="..nPage)
	local Image_Background = tolua.cast(widget:getChildByName("Image_Background"), "ImageView")
	Image_Background:loadTexture(getBackgroundJpgImg("JingYingFuBen"))
	
	local total = nil
	if nPage ~= 1 then	
        for i = 3,5 do
            local Button_Ectype = widget:getChildByName("Button_Ectype"..i)
            if i == 3 then
            	Button_Ectype:setPositionX(745)              
            elseif i == 4 then
                Button_Ectype:setPositionX(1015)
            elseif i ==5 then
            	Button_Ectype:setVisible(false)
            end
        end
        total = 4 
	else
		for i = 3,5 do
            local Button_Ectype = widget:getChildByName("Button_Ectype"..i)
            if i == 3 then
            	Button_Ectype:setPositionX(640)              
            elseif i == 4 then
                Button_Ectype:setPositionX(860)
            elseif i ==5 then
            	Button_Ectype:setVisible(true)
            end
        end
        total = 5
    end

	for i=1,total do
		local csv_JY = g_DataMgr:getCsvConfigByTwoKey("MapEctypeJingYing", nPage, i)

		local Button_Ectype = tolua.cast(widget:getChildByName("Button_Ectype"..i),"Button")
		
		local function onClick_Button_Ectype(pSender, nTag)
			if nTag == 0 then
				g_WndMgr:showWnd("Game_EctypeJYDetail",csv_JY)
			elseif csv_JY.Index == 1 or (csv_JY.MapID < 3 and csv_JY.Index == 4) or (csv_JY.MapID >= 3 and csv_JY.Index == 3) then
				local csv_Mapbase = g_DataMgr:getCsvConfigByOneKey("MapBase", nTag)
				g_ShowSysWarningTips({text =_T("请通关了[")..csv_Mapbase.Name.._T("]地图才能解锁")})
			else
				local csv_JY_last = g_DataMgr:getCsvConfigByTwoKey("MapEctypeJingYing", math.ceil(csv_JY.MapID / 2), csv_JY.Index - 1)
				g_ShowSysWarningTips({text =_T("请通关了[")..csv_JY_last.EctypeName.._T("]深渊副本才能解锁")})
			end
		end
		
		g_SetBtnWithPressImage(Button_Ectype, 0, onClick_Button_Ectype, true)

		
		if csv_JY.EctypeID == 0 then --处理最后一页
			Button_Ectype:setVisible(false)
		else
			Button_Ectype:setVisible(true)

			local Label_EctypeName = tolua.cast(Button_Ectype:getChildByName("Label_EctypeName"), "Label")
			Label_EctypeName:setText(csv_JY.EctypeName)

			local Button_Lock = Button_Ectype:getChildByName("Button_Lock")
			local Panel_Card = Button_Ectype:getChildByName("Panel_Card")

			if self:isEnabled(nPage, i, csv_JY.MapID) then --是否可攻打		
				Button_Lock:setVisible(false)
				Panel_Card:setVisible(true)
				Button_Ectype:setTag(0)
				g_EctypeJY:setReward(csv_JY, nPage, i)

				local Image_Card = tolua.cast(Panel_Card:getChildByName("Image_Card"), "ImageView") 
				Image_Card:removeAllNodes()
				Image_Card:loadTexture(getUIImg("Blank"))
				Image_Card:setPositionXY(csv_JY.Pos_X, csv_JY.Pos_Y)

				--android 崩溃
				--g_CocosSpineAnimationAsync(nil, Image_Card, csv_JY.BossPotrait, 1 , "idle")
				local spine = nil
				if self.tbJYSpine[csv_JY.BossPotrait] then
					spine = self.tbJYSpine[csv_JY.BossPotrait]:clone()
				else
				 	spine = g_CocosSpineAnimation(csv_JY.BossPotrait, 1)

				 	
				 	self.tbJYSpine[csv_JY.BossPotrait] = spine
				 	--自己缓存 在closewnd的时候释放
				 	self.tbJYSpine[csv_JY.BossPotrait]:retain()
				end
				if spine then
					Image_Card:addNode(spine)
					g_runSpineAnimation(spine, "idle", true)
				end
			else
				Button_Lock:setVisible(true)
				Button_Lock:setTouchEnabled(false)
				Panel_Card:setVisible(false)
				Button_Ectype:setTag(csv_JY.MapID)
				
				local function onClick_Button_Lock(pSender, nTag)
					if nTag == 0 then
						g_WndMgr:showWnd("Game_EctypeJYDetail",csv_JY)
					elseif csv_JY.Index == 1 or (csv_JY.MapID < 3 and csv_JY.Index == 4) or (csv_JY.MapID >= 3 and csv_JY.Index == 3) then
						local csv_Mapbase = g_DataMgr:getCsvConfigByOneKey("MapBase", nTag)
						g_ShowSysWarningTips({text =_T("请通关了[")..csv_Mapbase.Name.._T("]地图才能解锁")})
					else
						local csv_JY_last = g_DataMgr:getCsvConfigByTwoKey("MapEctypeJingYing", math.ceil(csv_JY.MapID / 2), csv_JY.Index - 1)
						g_ShowSysWarningTips({text =_T("请通关了[")..csv_JY_last.EctypeName.._T("]深渊副本才能解锁")})
					end
				end
				g_SetBtnWithPressImage(Button_Lock,csv_JY.MapID, onClick_Button_Lock, true)
			end

			--设置难度星星
			local AtlasLabel_StarRecord = tolua.cast(Button_Ectype:getChildByName("AtlasLabel_StarRecord"), "LabelAtlas")
			AtlasLabel_StarRecord:setStringValue(EctypeStarString[3][g_EctypeJY:getStarNum(nPage, i)])

			--设置次数
			local Label_FightNums = tolua.cast(Button_Ectype:getChildByName("Label_FightNums"), "Label")
			g_VIPBase:setJYPageIdPageIndex(nPage, i)
			local types = VipType.VIP_TYPE_JY_ENCRYPT
			local addNum = g_VIPBase:getAddTableByNum(types)
			local nFightNum = g_EctypeJY:getAttackNum(nPage, i) 	
			Label_FightNums:setText(nFightNum.."/"..csv_JY.MaxFightNums + addNum)

		end
	end
	
end

function Game_EctypeJY:showTitleAnimation()
	self.Image_NameLabel:setScale(2)
	self.Image_NameLabel:setOpacity(0)
	self.Image_NameLabel:stopAllActions()
	
	local arryAct  = CCArray:create()
	local action_FadeTo1 = CCFadeTo:create(0.25, 255)
	local action_ScaleTo1 = CCScaleTo:create(0.25, 1)
	local action_FadeTo2 = CCFadeTo:create(0.4, 0)
	local action_Spawn1 = CCSpawn:createWithTwoActions(action_FadeTo1, action_ScaleTo1)
	arryAct:addObject(action_Spawn1)
	arryAct:addObject(CCDelayTime:create(1))
	arryAct:addObject(action_FadeTo2)
	local actionSquence = CCSequence:create(arryAct)
	self.Image_NameLabel:runAction(actionSquence)
end

function Game_EctypeJY:onSwitch_LuaPageView_EctypeJY(widget, nCurpage)
	local strValue = string.rep("1",nCurpage)..string.rep("2",self.nTotalPages - nCurpage)
	self.AtlasLabel_PageIndex:setStringValue(strValue)
	self:showTitleAnimation()
end

function Game_EctypeJY:initWnd()
	local nFinalClearMapID = g_Hero:getFinalClearMapID()
	local tbEctype = g_DataMgr:getEctypeListByMapBaseID(nFinalClearMapID)
    local nCurEctypeID = g_Hero:getFinalClearEctypeID()
	if(tbEctype )then
		local nMax = #tbEctype
		local CSV_MapEctype = g_DataMgr:getMapEctypeCsv(tbEctype[nMax] )
		if( nCurEctypeID == tbEctype[nMax] or g_Hero:getEctypePassStar(CSV_MapEctype.EctypeID) )then --说明已经是最后一关了
			nFinalClearMapID = nFinalClearMapID + 1
		end
	end
    if nFinalClearMapID > 1 then
    	self.bNextEnabled = true
    	self.bFirstEnabled = true
    else
    	self.bNextEnabled = false
    end
    self.nFinalClearMapID = nFinalClearMapID
	

	self.AtlasLabel_PageIndex = tolua.cast(self.rootWidget:getChildByName("AtlasLabel_PageIndex"), "LabelAtlas")
	self.Image_NameLabel = tolua.cast(self.rootWidget:getChildByName("Image_NameLabel"), "ImageView")
	self.Image_NameLabel:setCascadeOpacityEnabled(true)
	
	local Button_ForwardPage = tolua.cast(self.rootWidget:getChildByName("Button_ForwardPage"), "Button")
	local Button_NextPage = tolua.cast(self.rootWidget:getChildByName("Button_NextPage"), "Button")

	local PageView_EctypeJY = tolua.cast(self.rootWidget:getChildByName("PageView_EctypeJY"), "PageView")
	PageView_EctypeJY:setClippingEnabled(true)
	self.pageView = PageView_EctypeJY
	local Panel_EctypeJYPage1 = PageView_EctypeJY:getChildByName("Panel_EctypeJYPage1")
	Panel_EctypeJYPage1:retain()
	self.LuaPageView_EctypeJY = Class_LuaPageView:new()
	self.LuaPageView_EctypeJY:setModel(Panel_EctypeJYPage1, Button_ForwardPage, Button_NextPage, 0.80, 0.80)
	self.LuaPageView_EctypeJY:setPageView(PageView_EctypeJY)

	self.LuaPageView_EctypeJY:registerUpdateFunction(handler(self,self.updatePageViewItem))
	self.LuaPageView_EctypeJY:registerClickEvent(handler(self,self.onSwitch_LuaPageView_EctypeJY))
	self.LuaPageView_EctypeJY:setCurPageIndex(g_EctypeJY:getMaxAttackPage())
	self.nTotalPages = g_EctypeJY:getTotalPages()
	self.LuaPageView_EctypeJY:updatePageView(self.nTotalPages)
	g_EctypeJY:setDirty(false)
end

function Game_EctypeJY:openWnd()
	if g_EctypeJY:getDirty() then	
		local nCurPage_C = self.pageView:getCurPageIndex()
		local nCurPage_Lua = g_EctypeJY:getCurAttackJY()
		local curWidget = self.pageView:getPage(nCurPage_C)
		self:updatePageViewItem(curWidget, nCurPage_Lua)
		local nextWidget = self.pageView:getPage(nCurPage_C + 1)
		if nextWidget then
			self:updatePageViewItem(nextWidget, nCurPage_Lua + 1)
		end
		g_EctypeJY:setDirty(false)
	end
end

function Game_EctypeJY:closeWnd()
	-- body
	cclog("==========Game_EctypeJY:closeWnd=======begin")
	for k, v in pairs(self.tbJYSpine) do
        -- cclog("cont ==================== " .. v:retainCount())
        v:release()
    end
    self.tbJYSpine = {}
    cclog("==========Game_EctypeJY:closeWnd=======end")
end


