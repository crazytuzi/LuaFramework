--------------------------------------------------------------------------------------
-- 文件名:	XXX.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	周光剑
-- 日  期:	2015-6-4
-- 版  本:	1.0
-- 描  述:	运营活动Form
-- 应  用:  
---------------------------------------------------------------------------------------
Game_ActivityCenter = class("Game_ActivityCenter")
Game_ActivityCenter.__index = Game_ActivityCenter

function Game_ActivityCenter:onClickActiveItem(pSender, eventType)
	if eventType == ccs.TouchEventType.ended then
		self.ListView_ActivityPage:scrollToTop()--ByWidget(pSender:getParent())
	end
end

function Game_ActivityCenter:adjustOverFunc(Panel_ActivityPageItem, index)
	if not self.endActivetyIndex or 
	   not self.tbActivityList or 
	   not self.tbActivityList[self.endActivetyIndex] or 
	   not self.tbActivityList[self.endActivetyIndex]["panel"] then
	   return 
	end
	self.tbActivityList[self.endActivetyIndex]["panel"]:setVisible(false)
    self.tbActivityList[index]["panel"]:setVisible(true)
    self.endActivetyIndex = index
    self.endPanel_ActivityPageItem = Panel_ActivityPageItem
	if not self.tbActivityList[index].bInitOk then
		local tbItemList = g_DataMgr:getCsvConfig(self.tbActivityList[index]["Desc3"])
		local activety = self.tbActivityList[index]["class"]
		activety:init(self.tbActivityList[index]["panel"], tbItemList)
		self.tbActivityList[index].bInitOk = true
	end

    local activety = self.tbActivityList[index]["class"]
    if activety and activety.updateStatus then
        activety:updateStatus()
    end
    --重新打点当前可领取奖励个数
    local nBubble = g_act:getBubbleByID(self.tbActivityList[index]["ActivityOnlineID"])
	g_SetBubbleNotify(self.curButton_ActivityItem, nBubble, 130, 40, 1)
    --刷新活动倒计时时间
    self:setRefreshTime()
end

function Game_ActivityCenter:adjustActivityItem(Panel_ActivityPageItem, index)
	if self.curButton_ActivityItem and self.curButton_ActivityItem:isExsit() then
		self.curButton_ActivityItem:loadTextures(getActivityCenterImg("ListItem_Activity"),getActivityCenterImg("ListItem_Activity_Press"),getActivityCenterImg("ListItem_Activity"))
		Image_Arrow = self.curButton_ActivityItem:getChildByName("Image_Arrow")
		Image_Arrow:setVisible(false)
	end
	local Button_ActivityItem = tolua.cast(Panel_ActivityPageItem:getChildByName("Button_ActivityItem"), "Button")
	Button_ActivityItem:loadTextures(getActivityCenterImg("ListItem_Activity_Check"),getActivityCenterImg("ListItem_Activity_Check_Press"),getActivityCenterImg("ListItem_Activity_Check"))
	Image_Arrow = Button_ActivityItem:getChildByName("Image_Arrow")
	Image_Arrow:setVisible(true)
	self.curButton_ActivityItem = Button_ActivityItem
end

ENUM_ActivityOnline_ID = {
	MonthlyCard = 15,
	DuiHuanMa = 6,
	KaiFuJiJin = 7,
	KaiFuJiJinFuli = 8,
}

function Game_ActivityCenter:initActivetyList()
	local Image_ActivityCenterPNL = tolua.cast(self.rootWidget:getChildByName("Image_ActivityCenterPNL"), "ImageView")
	local Image_ActivityListPNL = tolua.cast(Image_ActivityCenterPNL:getChildByName("Image_ActivityListPNL"), "ImageView")
	
	self.ListView_ActivityPage = tolua.cast(Image_ActivityListPNL:getChildByName("ListView_ActivityPage"), "ListViewEx")
	local Panel_ActivityPageItem = tolua.cast(self.ListView_ActivityPage:getChildByName("Panel_ActivityPageItem"), "Button")
	local function updateFunc(Panel_ActivityPageItem,index)
		local Button_ActivityItem = tolua.cast(Panel_ActivityPageItem:getChildByName("Button_ActivityItem"), "Button")
		local Image_NPC = tolua.cast(Button_ActivityItem:getChildByName("Image_NPC"), "ImageView")
		local Label_ActivityName = tolua.cast(Button_ActivityItem:getChildByName("Label_ActivityName"), "Label")
		local Label_ActivityDesc = tolua.cast(Button_ActivityItem:getChildByName("Label_ActivityDesc"), "Label")
		Image_NPC:loadTexture(getActivityCenterImg(self.tbActivityList[index]["NpcPic"]))
		Label_ActivityName:setText(self.tbActivityList[index]["ActivityName"])
		Label_ActivityDesc:setText(self.tbActivityList[index]["ActivityDesc"])
		if eLanguageVer.LANGUAGE_viet_VIET == g_LggV:getLanguageVer() then
			Label_ActivityName:setFontSize(18)
			Label_ActivityDesc:setFontSize(18)
		end
		--20151118
		Image_Arrow = Button_ActivityItem:getChildByName("Image_Arrow")
		Image_Arrow:setVisible(false)
		--

		Button_ActivityItem:loadTextures(getActivityCenterImg("ListItem_Activity"), getActivityCenterImg("ListItem_Activity_Press"), getActivityCenterImg("ListItem_Activity"))
		Button_ActivityItem:setTag(index)
		Button_ActivityItem:addTouchEventListener(handler(self, self.onClickActiveItem))

		Panel_ActivityPageItem:setTag(self.tbActivityList[index]["ActivityOnlineID"])
		local nBubble = g_act:getBubbleByID(self.tbActivityList[index]["ActivityOnlineID"])
		g_SetBubbleNotify(Button_ActivityItem, nBubble, 130, 40, 1)

		--
		self.tbActivityList[index]["Panel_ActivityPageItem"] = Panel_ActivityPageItem
	end
	local function adjustFunc(Panel_ActivityPageItem, index)
		self:adjustActivityItem(Panel_ActivityPageItem, index)
	end
	self.tbActivityList = {}
	local csvConfig = g_DataMgr:getCsvConfig("ActivityOnline")
	local tbExsit = {}
	for k,v in ipairs(csvConfig) do
		--初始化各活动面板
		if not tbExsit[v.FunctionType] then --节日活动与普通活动（相同的）只存在一个  20151231可同时存在
			local activety = loadstring("return "..v.FunctionType)()
			v.panel = Image_ActivityCenterPNL:getChildByName(v["Desc2"])
			v.panel:setVisible(false)
			if activety then
				activety.tbItemList = g_DataMgr:getCsvConfig(v["Desc3"])
				if activety:isEnable(v.ActivityOnlineID) and g_Hero:getMasterCardLevel() >= v.OpenLevel then
					if g_bVersionTS_0_0_ ~= nil and g_bVersionTS_0_0_ == g_NeelDisableVersion then
						if k == ENUM_ActivityOnline_ID.MonthlyCard then
							--donothing
						elseif k == ENUM_ActivityOnline_ID.DuiHuanMa then
							--donothing
						elseif k == ENUM_ActivityOnline_ID.KaiFuJiJin then
							--donothing
						elseif k == ENUM_ActivityOnline_ID.KaiFuJiJinFuli then
							--donothing
						else
							tbExsit[v.FunctionType] = true					
							v.class = activety
							v.bInitOk = false
							table.insert(self.tbActivityList,v)
						end
					else
						tbExsit[v.FunctionType] = true					
						v.class = activety
						v.bInitOk = false
						table.insert(self.tbActivityList,v)
					end
				end
			end 
		end
	end

	table.sort(self.tbActivityList, function (a, b)
		local nBubbleA = g_act:getBubbleByID(a.ActivityOnlineID)
		local nBubbleB = g_act:getBubbleByID(b.ActivityOnlineID)
		if nBubbleA > 0 and nBubbleB > 0 or nBubbleA == 0 and nBubbleB == 0 then
			return a.SortIndex < b.SortIndex
		elseif nBubbleA > 0 then
			return true
		else
			return false
		end
	end)

	--self.curActivetyIndex = 1
	self.endActivetyIndex = 1
	self.LuaListView_ActivityPage = registerListViewEvent(self.ListView_ActivityPage, Panel_ActivityPageItem, updateFunc, nil, adjustFunc)
	self.LuaListView_ActivityPage:setAdjustOverFunc(handler(self, self.adjustOverFunc))
  --  LuaListView_ActivityPage:updateItems(#self.tbActivityList)
	--self:adjustOverFunc(self.ListView_ActivityPage:getChildByIndex(0), 1)
	
	local imgScrollSlider = self.LuaListView_ActivityPage:getScrollSlider()
	if not g_tbScrollSliderXY.LuaListView_ActivityPage_X then
		g_tbScrollSliderXY.LuaListView_ActivityPage_X = imgScrollSlider:getPositionX()
	end
	imgScrollSlider = imgScrollSlider:setPositionX(g_tbScrollSliderXY.LuaListView_ActivityPage_X - 2)

    --活动倒计时更新
    self:setRefreshTime()
	self.nTimerID_Game_Act = g_Timer:pushLoopTimer(1, handler(self, self.setRefreshTime))
end

function Game_ActivityCenter:setRefreshTime()
    local cur_time_server = g_GetServerTime()
    local cur_act_endTime = g_act:getActEndTimeByID(self.tbActivityList[self.endActivetyIndex]["ActivityOnlineID"])
    if cur_act_endTime and cur_act_endTime ~= 0 then
        local left_time = os.date("%m-%d 00:00", cur_act_endTime)
        self.label_RemainTime:setText(left_time)     
    else
        self.label_RemainTime:setText(_T("永久")) 
    end
end

function Game_ActivityCenter:initWnd()
	local Image_ActivityCenterPNL = tolua.cast(self.rootWidget:getChildByName("Image_ActivityCenterPNL"), "ImageView")
	local Image_ActivityListPNL = Image_ActivityCenterPNL:getChildByName("Image_ActivityListPNL")
	Image_ActivityListPNL:setVisible(true)
    self.label_RemainTime = tolua.cast(Image_ActivityCenterPNL:getChildByName("Label_RemainTime"), "Label")
	self:initActivetyList()
	
	local ImageView_Background1 = tolua.cast(self.rootWidget:getChildByName("ImageView_Background1"), "ImageView")
	ImageView_Background1:loadTexture(getBackgroundJpgImg("Background_Money1"))
	local ImageView_Background2 = tolua.cast(self.rootWidget:getChildByName("ImageView_Background2"), "ImageView")
	ImageView_Background2:loadTexture(getBackgroundPngImg("Background_Money2"))
	local ImageView_Background3 = tolua.cast(self.rootWidget:getChildByName("ImageView_Background3"), "ImageView")
	ImageView_Background3:loadTexture(getBackgroundPngImg("Background_Money3"))

    --获取战斗力排行榜
    g_act:fightRankListRequest()
end

function Game_ActivityCenter:openWnd(ActivityOnlineID)
	if self.endPanel_ActivityPageItem then
		cclog("aaaaaaaaaa "..self.endPanel_ActivityPageItem:getTag())
		local nBubble = g_act:getBubbleByID(self.endPanel_ActivityPageItem:getTag())
		local Button_ActivityItem = tolua.cast(self.endPanel_ActivityPageItem:getChildByName("Button_ActivityItem"), "Button")
		g_SetBubbleNotify(Button_ActivityItem, nBubble, 130, 40, 1)
	end
	if ActivityOnlineID then
		self.bFirstInit = true
		local tb
		for k, v in ipairs(self.tbActivityList) do
			if v.ActivityOnlineID == ActivityOnlineID then
				tb = v
				break
			end
		end
		self.tbActivityList = {tb}
		self.LuaListView_ActivityPage:updateItems(#self.tbActivityList)
		if 0 ~= #self.tbActivityList then
			self:adjustOverFunc(self.ListView_ActivityPage:getChildByIndex(0), 1)
		end
	elseif not self.bFirstInit then
		self.bFirstInit = true
		self.LuaListView_ActivityPage:updateItems(#self.tbActivityList)
		if 0 ~= #self.tbActivityList then
        	self:adjustOverFunc(self.ListView_ActivityPage:getChildByIndex(0), 1)
        end
	end

    if self.endActivetyIndex and self.tbActivityList[self.endActivetyIndex] then
        --更新当前页活动的状态
        local activety = self.tbActivityList[self.endActivetyIndex]["class"]
        if activety and activety.updateStatus then
            activety:updateStatus()
        end
    end

end

function Game_ActivityCenter:closeWnd()
	for i=1, #self.tbActivityList do
		local activety = self.tbActivityList[i]["class"]
		activety:destroy()
	end
	local ImageView_Background1 = tolua.cast(self.rootWidget:getChildByName("ImageView_Background1"), "ImageView")
	ImageView_Background1:loadTexture(getUIImg("Blank"))
	local ImageView_Background2 = tolua.cast(self.rootWidget:getChildByName("ImageView_Background2"), "ImageView")
	ImageView_Background2:loadTexture(getUIImg("Blank"))
	local ImageView_Background3 = tolua.cast(self.rootWidget:getChildByName("ImageView_Background3"), "ImageView")
	ImageView_Background3:loadTexture(getUIImg("Blank"))

    g_Timer:destroyTimerByID(self.nTimerID_Game_Act)
	self.nTimerID_Game_Act = nil
end

function Game_ActivityCenter:ModifyWnd_viet_VIET()
	local Image_ActivityPagePNL7 = self.rootWidget:getChildAllByName("Image_ActivityPagePNL7")
	local Image_Char1 = Image_ActivityPagePNL7:getChildAllByName("Image_Char1")
	Image_Char1:setPositionX(-200)
end