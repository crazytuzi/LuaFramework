--------------------------------------------------------------------------------------
-- 文件名:	XXX.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	周光剑
-- 日  期:	2015-6-9
-- 版  本:	1.0
-- 描  述:	活动模版类
-- 应  用:  
---------------------------------------------------------------------------------------

Act_Template = class("Act_Template")
Act_Template.__index = Act_Template

Act_Template.szImage_RewardStatus = "Image_RewardStatus"

function Act_Template:sortAndUpdate()
	table.sort(self.tbItemList, function (a, b)
		if not self.tbMissions then
			return false
		end
		local state_a = self.tbMissions[a.ID] or ActState.INVALID 
		local state_b = self.tbMissions[b.ID] or ActState.INVALID
        --任务状态相同的情况下排序 
		if state_a == state_b then
			return a.ID < b.ID
		else
            --任务状态不同的情况下排序
            if state_a == ActState.INACTIVATED then --a任务当前不可完成
                state_a = state_a - 2.5
            elseif state_b == ActState.INACTIVATED then --b任务当前不可完成
                state_b = state_b - 2.5
            end
            return  state_a > state_b
		end
	end)

	--防止报错
	if self.listView_BtnItem:isExsit() then
		self.listView_BtnItem:updateItems(#self.tbItemList, g_Act_Template_Index)
	end
end

--领取响应回调
function Act_Template:gainRewardResponseCB()
	self:sortAndUpdate()
	-- self.listView_BtnItem:updateItems(#self.tbItemList)
	-- if self.curButton then
	-- 	self.curButton:setVisible(false)
	-- 	self.curButton:setTouchEnabled(false)
	-- 	local buttonItem = self.curButton:getParent()
	-- 	buttonItem:setBright(false)
	-- 	local Image_RewardStatusYiLing = tolua.cast(buttonItem:getChildByName("Image_RewardStatusYiLing"), "ImageView")
	-- 	Image_RewardStatusYiLing:setVisible(true)
	-- end
end

--领取按钮回调
function Act_Template:onClickGainReward(pSender, eventType)
	if eventType == ccs.TouchEventType.ended then
		if (not pSender) or (not pSender:isExsit()) then return end
		pSender:setTouchEnabled(false)
		-- local msg = zone_pb.AOLRewardRequest()
		-- msg.type = self.nActivetyID
		-- msg.mission_id = pSender:getTag()
		-- g_MsgMgr:sendMsg(msgid_pb.MSGID_AOL_REWARD_REQUEST,msg)
		g_act:rewardRequest(self.nActivetyID, self.tbItemList[pSender:getTag()].ID)
		--self.curButton = pSender
		g_act:setRewardResponseCB(handler(self,self.gainRewardResponseCB))
	end
end

--设置按钮中掉落物品
function Act_Template:setDropItem(widget,index, tbDropItem)
	local itemModel = g_CloneDropItemModel(tbDropItem)
	widget:removeAllChildren()
	if itemModel then
		itemModel:setPositionXY(45,45)
		itemModel:setScale(0.7)
		widget:addChild(itemModel)

		local function onClick(pSender, eventType)
			if eventType == ccs.TouchEventType.ended then
				g_ShowDropItemTip(tbDropItem)
			end
		end
		itemModel:setTouchEnabled(true)
		itemModel:addTouchEventListener(onClick)
	end
end

function Act_Template:setButtonState(buttonItem, state)
	local button_GetReward = tolua.cast(buttonItem:getChildByName("Button_GetReward"), "Button")
	local image_RewardStatus = tolua.cast(button_GetReward:getChildByName("Image_RewardStatus"), "ImageView")
	local Image_RewardStatusYiLing = tolua.cast(buttonItem:getChildByName("Image_RewardStatusYiLing"), "ImageView")

	if ActState.INVALID == state then --已领取
		buttonItem:loadTextureNormal(getActivityTaskImg("ListItem_Task"))
		buttonItem:loadTexturePressed(getActivityTaskImg("ListItem_Task_Press"))
		buttonItem:loadTextureDisabled(getActivityTaskImg("ListItem_Task_Disabled"))
		buttonItem:setTouchEnabled(false)
		buttonItem:setBright(false)
		button_GetReward:setTouchEnabled(false)
		button_GetReward:setBright(false)
		button_GetReward:setVisible(false)
		image_RewardStatus:loadTexture(getActivityCenterImg(self.szImage_RewardStatus.."1"))
		Image_RewardStatusYiLing:setVisible(true)
	elseif ActState.DOING == state then --未领取
		buttonItem:loadTextureNormal(getActivityTaskImg("ListItem_Task"))
		buttonItem:loadTexturePressed(getActivityTaskImg("ListItem_Task_Press"))
		buttonItem:loadTextureDisabled(getActivityTaskImg("ListItem_Task_Disabled"))
		buttonItem:setTouchEnabled(true)
		buttonItem:setBright(true)
		button_GetReward:setTouchEnabled(false)
		button_GetReward:setBright(true)
		button_GetReward:setVisible(true)
		image_RewardStatus:loadTexture(getActivityCenterImg(self.szImage_RewardStatus.."1"))
		Image_RewardStatusYiLing:setVisible(false)
	elseif ActState.FINISHED == state then --可领取
		buttonItem:loadTextureNormal(getActivityTaskImg("ListItem_Task"))
		buttonItem:loadTexturePressed(getActivityTaskImg("ListItem_Task_Press"))
		buttonItem:loadTextureDisabled(getActivityTaskImg("ListItem_Task_Disabled"))
		buttonItem:setTouchEnabled(true)
		buttonItem:setBright(true)
		button_GetReward:setTouchEnabled(true)
		button_GetReward:setBright(true)
		button_GetReward:setVisible(true)
		image_RewardStatus:loadTexture(getActivityCenterImg(self.szImage_RewardStatus.."2"))
		Image_RewardStatusYiLing:setVisible(false)
	end
end

--设置每个按钮列表项
function Act_Template:setPanelItem(widget,index)
	--widget:setTag(index)
	local buttonItem = tolua.cast(widget:getChildByName("Button_Activety"), "Button")
	local image_Tip = buttonItem:getChildByName("Image_Tip")
	local label_Tip = tolua.cast(image_Tip:getChildByName("Label_Tip"), "Label")
	label_Tip:setText(self.tbItemList[index]["Desc"])
	local listView_DropItem = tolua.cast(buttonItem:getChildByName("ListView_DropItem"), "ListViewEx")
	local dropItem = listView_DropItem:getChildByName("Panel_DropItem")
	local tbDropItemList = g_DataMgr:getCsvConfig_SecondKeyTableData("DropSubPackClient", self.tbItemList[index]["DropClientID"])--g_DataMgr:getCsvConfigByOneKey("DropSubPackClient", self.tbItemList[index]["DropClientID"])
	local function updateFunc(widget,index)
		return self:setDropItem(widget, index, tbDropItemList[index])
	end
	registerListViewEvent(listView_DropItem, dropItem, updateFunc, #tbDropItemList)
	
	if #tbDropItemList <= 6 then
		listView_DropItem:setBounceEnabled(false)
		listView_DropItem:setTouchEnabled(false)
	end
	
	local button_GetReward = tolua.cast(buttonItem:getChildByName("Button_GetReward"), "Button")
	if button_GetReward then
		button_GetReward:setTag(index)
		button_GetReward:addTouchEventListener(handler(self,self.onClickGainReward))
		local image_RewardStatus = tolua.cast(button_GetReward:getChildByName("Image_RewardStatus"), "ImageView")
		local Image_RewardStatusYiLing = tolua.cast(buttonItem:getChildByName("Image_RewardStatusYiLing"), "ImageView")
		local state = self.tbMissions[self.tbItemList[index].ID]

		self:setButtonState(buttonItem, state)
	end
	
end


--活动是否有效,在init之前调用
function Act_Template:isEnable(id)
	self.nActivetyID = id
	self.tbMissions = g_act:getMissionsByID(id)
    
	-- 活动测试
	if g_Cfg.Platform == kTargetWindows then
		-- if (
			-- id == 1 or
			-- id == 3 or
			-- id == 5 or
			-- id == 6 or
			-- id == 7 or
			-- id == 8 or
			-- id == 9 or
			-- id == 10 or
			-- id == 11 or
			-- id == 12 or
			-- id == 13 or
			-- id == 14 or
			-- id == 15 or
			-- id == 16 or
			-- id == 17 or
			-- id == 18 or
			-- id == 19 or
			-- id == 20 or
			-- id == 21 or
			-- id == 22 or
			-- id == 23 or
			-- id == 24 or
			-- id == 25 or
			-- id == 26 or
			-- id == 27 or
			-- id == 28
		-- ) then
			-- self.tbMissions = {}
			-- for i = 1, 30 do
				-- table.insert(self.tbMissions, 1)
			-- end
		-- end
    end

	if not self.tbMissions then
		--测试用
		-- self.tbMissions = {}
		-- for i = 1,20 do
		-- 	table.insert(self.tbMissions, 1)
		-- end
		return false
	else
        if not self.tbMissions_old then
            self.tbMissions_old = {}
        end
        for i,v in pairs(self.tbMissions) do
            if not self.tbMissions_old[i] then
                self.tbMissions_old[i] = v
            end
        end
		return true
	end
end

--初始化
function Act_Template:init(panel, tbItemList)
	if not panel then
		return 
	end

 	self.tbItemList = tbItemList
	local listView_BtnItem = tolua.cast(panel:getChildByName("ListView_Activety"), "ListViewEx")
	local item = listView_BtnItem:getChildByName("Panel_Activety")
	local function updateFunc(widget,index)
		return self:setPanelItem(widget, index)
	end
	--registerListViewEvent(listView_BtnItem, item, updateFunc)
    self.listView_BtnItem = Class_LuaListView:new()
    self.listView_BtnItem:setListView(listView_BtnItem)
    self.listView_BtnItem:setModel(item)
    self.listView_BtnItem:setUpdateFunc(updateFunc)
	g_Act_Template_Index = 1
    local function onAdjustListView(widget, nIndex)
		g_Act_Template_Index = nIndex
    end   
	self.listView_BtnItem:setAdjustFunc(onAdjustListView)
	self:sortAndUpdate()
	
	local imgScrollSlider = self.listView_BtnItem:getScrollSlider()
	if not g_tbScrollSliderXY.ListView_Activety_X then
		g_tbScrollSliderXY.ListView_Activety_X = imgScrollSlider:getPositionX()
	end
	imgScrollSlider = imgScrollSlider:setPositionX(g_tbScrollSliderXY.ListView_Activety_X - 3)
    g_act:resetBubbleById(self.nActivetyID) --重置可领取奖励个数
end

--析构
function Act_Template:destroy()
end