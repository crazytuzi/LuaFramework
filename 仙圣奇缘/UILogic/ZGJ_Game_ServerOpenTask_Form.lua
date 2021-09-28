Game_ServerOpenTask = class("Game_ServerOpenTask")
Game_ServerOpenTask.__index = Game_ServerOpenTask

--设置掉落物品
function Game_ServerOpenTask:setDropItem(widget, index, tbDropItem)
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

--设置按钮状态
function Game_ServerOpenTask:setButtonState(Button_TaskItem, tbTask, csv_Task, task_Type)
	local Button_GetReward = tolua.cast(Button_TaskItem:getChildByName("Button_GetReward"), "Button")
	local BitmapLabel_FuncName = tolua.cast(Button_GetReward:getChildByName("BitmapLabel_FuncName"), "LabelBMFont")

	local nState = tbTask["nState"]
    if csv_Task["TaskType"] == 18 then
        --每日折扣活动按钮状态设置
        if g_Hero:getYuanBao() - csv_Task["PriceNow"] >= 0 then
            nState = common_pb.SOTS_FINISHED_WAIT_REWARD
        else
            nState = common_pb.SOTS_DOING
        end        
    end
	if common_pb.SOTS_END == nState then --已领奖
        if csv_Task["TaskType"] == 18 then
            BitmapLabel_FuncName:setText(_T("已购买"))
        else
            BitmapLabel_FuncName:setText(_T("已领取"))
        end
		Button_GetReward:setBright(true)
		Button_GetReward:setTouchEnabled(false)
	elseif common_pb.SOTS_DOING == nState then --进行中
        if csv_Task["TaskType"] == 16 then
            BitmapLabel_FuncName:setText(_T("登入"))
        elseif csv_Task["TaskType"] == 17 then
            BitmapLabel_FuncName:setText(_T("前往充值"))
        elseif csv_Task["TaskType"] == 18 then
            BitmapLabel_FuncName:setText(_T("前往充值"))
        else
            BitmapLabel_FuncName:setText(_T("前往"))
        end
		Button_GetReward:setBright(true)
		Button_GetReward:setTouchEnabled(true)
		Button_GetReward:addTouchEventListener(function (widget, eventType)
				if ccs.TouchEventType.ended == eventType then
					g_WndMgr:showWnd(csv_Task["WndName"])
				end
			end)
	elseif common_pb.SOTS_FINISHED_WAIT_REWARD == nState then --可领奖
        if csv_Task["TaskType"] == 18 then
            BitmapLabel_FuncName:setText(_T("购买"))
        else
            BitmapLabel_FuncName:setText(_T("领取"))
        end
        Button_GetReward:setBright(true)
		Button_GetReward:setTouchEnabled(true)
		Button_GetReward:addTouchEventListener(function (widget, eventType)
				if ccs.TouchEventType.ended == eventType then
                    if csv_Task["TaskType"] == 18 and csv_Task["LimitCount"] <= tbTask["nProgress"] then
                        g_ShowSysWarningTips({text = _T("该礼包的购买次数已达上限")})
                    else
					    g_SOTSystem:singleRewardRequest(task_Type, self.curTaskListID, tbTask["nTaskLevel"])
                    end
				end
			end)
    elseif common_pb.SOTS_TIMEOUT == nState then --已过期
        Button_GetReward:setBright(false)
		Button_GetReward:setTouchEnabled(false)
        BitmapLabel_FuncName:setText(_T("已过期"))    
	end

end

--设置任务和福利listview列表项
function Game_ServerOpenTask:updateTaskListItem(panel, index)
    local csv = g_DataMgr:getCsvConfig_FirstAndSecondKeyData("ActivityTaskGroup", self.curGroup, self.curOption)
    local TaskType = csv["TaskType"]
	local csv_Task
    if TaskType == 1 then
        csv_Task = g_DataMgr:getCsvConfig_FirstAndSecondKeyData("ActivityTask", self.curTaskListID, self.tbTaskList[index]["nTaskLevel"])
    elseif TaskType == 2 then
        csv_Task = g_DataMgr:getCsvConfig_FirstAndSecondKeyData("ActivityTaskEvent", self.curTaskListID, self.tbTaskList[index]["nTaskLevel"])
    else
        return
    end
    
    --标题
	local Button_TaskItem = tolua.cast(panel:getChildAllByName("Button_TaskItem"),"Button")
	local Label_Target = tolua.cast(Button_TaskItem:getChildByName("Label_Target"), "Label")
	if eLanguageVer.LANGUAGE_viet_VIET == g_LggV:getLanguageVer() then 
		Label_Target:setFontSize(19)
	end
	Label_Target:setText(csv_Task["Name"])

    --完成进度
	local Label_Progress = tolua.cast(Button_TaskItem:getChildByName("Label_Progress"), "Label")
	Label_Progress:setText(self.tbTaskList[index]["nProgress"])
	local Label_ProgressMax = tolua.cast(Button_TaskItem:getChildByName("Label_ProgressMax"), "Label")
	Label_ProgressMax:setText("/"..csv_Task["ProgressMax"])

	--设置掉落
	local ListView_DropItem = tolua.cast(Button_TaskItem:getChildByName("ListView_DropItem"), "ListViewEx")
	local Panel_DropItem = ListView_DropItem:getChildByName("Panel_DropItem") 
	local tbDropItemList = g_DataMgr:getCsvConfig_SecondKeyTableData("DropSubPackClient", csv_Task["DropClientID"])--g_DataMgr:getCsvConfigByOneKey("DropSubPackClient", self.tbItemList[index]["DropClientID"])
	local function updateFunc(widget,index)
		return self:setDropItem(widget, index, tbDropItemList[index])
	end

	registerListViewEvent(ListView_DropItem, Panel_DropItem, updateFunc,#tbDropItemList)
	
	if #tbDropItemList <= 5 then
		ListView_DropItem:setBounceEnabled(false)
		ListView_DropItem:setTouchEnabled(false)
	end

	--设置按钮状态
	self:setButtonState(Button_TaskItem, self.tbTaskList[index], csv_Task, TaskType)

end

--设置折扣listview列表项
function Game_ServerOpenTask:updateDiscountListItem(panel, index)
    local csv = g_DataMgr:getCsvConfig_FirstAndSecondKeyData("ActivityTaskGroup", self.curGroup, self.curOption)
    local TaskType = csv["TaskType"]
	local csv_Task = g_DataMgr:getCsvConfig_FirstAndSecondKeyData("ActivityTaskDiscount", self.curTaskListID, self.tbTaskList[index]["nTaskLevel"])
	local Button_DiscountItem = tolua.cast(panel:getChildAllByName("Button_DiscountItem"),"Button")
	
    --标题
    local Label_Target = tolua.cast(Button_DiscountItem:getChildByName("Label_Target"), "Label")
	if eLanguageVer.LANGUAGE_viet_VIET == g_LggV:getLanguageVer() then 
		Label_Target:setFontSize(19)
	end
	Label_Target:setText(csv_Task["Name"])

    --购买限制
	local Label_Limit = tolua.cast(Button_DiscountItem:getChildByName("Label_Limit"), "Label")
	Label_Limit:setText(self.tbTaskList[index]["nProgress"])
	local Label_LimitMax = tolua.cast(Button_DiscountItem:getChildByName("Label_LimitMax"), "Label")
	Label_LimitMax:setText("/"..csv_Task["LimitCount"])

    --折扣显示
    local Image_OldPrice = Button_DiscountItem:getChildByName("Image_OldPrice")
    local Label_OldPrice = tolua.cast(Image_OldPrice:getChildByName("Label_OldPrice"), "Label")
    Label_OldPrice:setText(csv_Task["PriceOld"])
    local Image_Price = Button_DiscountItem:getChildByName("Image_Price")
    local Label_NewPrice = tolua.cast(Image_Price:getChildByName("Label_NewPrice"), "Label")
    Label_NewPrice:setText(csv_Task["PriceNow"])
	
	local BitmapLabel_Discount = tolua.cast(Button_DiscountItem:getChildByName("BitmapLabel_Discount"), "LabelBMFont")
    BitmapLabel_Discount:setText(csv_Task["Discount"])

	--设置掉落
	local ListView_DropItem = tolua.cast(Button_DiscountItem:getChildByName("ListView_DropItem"), "ListViewEx")
	local Panel_DropItem = ListView_DropItem:getChildByName("Panel_DropItem") 
	local tbDropItemList = g_DataMgr:getCsvConfig_SecondKeyTableData("DropSubPackClient", csv_Task["DropClientID"])
	local function updateFunc(widget,index)
		return self:setDropItem(widget, index, tbDropItemList[index])
	end

	registerListViewEvent(ListView_DropItem, Panel_DropItem, updateFunc,#tbDropItemList)
	
	if #tbDropItemList <= 5 then
		ListView_DropItem:setBounceEnabled(false)
		ListView_DropItem:setTouchEnabled(false)
	end

	--设置按钮状态
	self:setButtonState(Button_DiscountItem, self.tbTaskList[index], csv_Task, TaskType)

end

--排序更新listview
function Game_ServerOpenTask:sortAndUpdate()
	local csv = g_DataMgr:getCsvConfig_FirstAndSecondKeyData("ActivityTaskGroup", self.curGroup, self.curOption)
    local TaskType = csv["TaskType"]
	self.curTaskListID = csv["TaskID"]
	self.tbTaskList = g_copyTab(g_SOTSystem:getTask(self.curTaskListID))
	table.sort(self.tbTaskList, function (a, b)
			if a.nState == b.nState then
				return a.nTaskLevel < b.nTaskLevel
			else
				return a.nState > b.nState
			end
		end)
    self.ListView_Task:setVisible(false)
    self.ListView_Discount:setVisible(false)
    if TaskType == 1 or TaskType == 2 then
        if self.ListView_Task and self.ListView_Task:isExsit() then
            self.ListView_Task:setVisible(true)
		    self.ListView_Task:updateItems(#self.tbTaskList)
            if TaskType == 2 then
                --打开界面后，每日福利重新打点
                local bubble_num = 0
                for i, v in pairs(self.tbTaskList) do
                    if common_pb.SOTS_FINISHED_WAIT_REWARD == v.nState then 
			            bubble_num = bubble_num + 1
		            end
                end
                g_SOTSystem:setBubble(self.curTaskListID,bubble_num)
            end
        end
    elseif TaskType == 3 then
        if self.ListView_Discount and self.ListView_Discount:isExsit() then
            --打开界面后，每日折扣重新打点
            g_SOTSystem:setBubble(self.curTaskListID,0)
            self.ListView_Discount:setVisible(true)
		    self.ListView_Discount:updateItems(#self.tbTaskList)
        end    
    end

    --更新打点UI
	self:setBubbleOfOption(self.curButtonOption, self.curOption)
end

--设置选项冒泡
function Game_ServerOpenTask:setBubbleOfOption(widget, nIndex)
	local csv_TaskGroup = g_DataMgr:getCsvConfig_FirstKeyData("ActivityTaskGroup", self.curGroup or 1)
	local nBubble = g_SOTSystem:getBubble(csv_TaskGroup[nIndex]["TaskID"])
	g_SetBubbleNotify(widget, nBubble, 50, 55, 0.8)
end

--设置组冒泡
function Game_ServerOpenTask:setBubbleOfGroup(widget, nIndex)
	local csv_TaskGroup = g_DataMgr:getCsvConfig_FirstKeyData("ActivityTaskGroup", nIndex)
	local nBubble = 0
	for i = 1, 5 do
		nBubble = nBubble + g_SOTSystem:getBubble(csv_TaskGroup[i]["TaskID"])
	end
	g_SetBubbleNotify(widget, nBubble, 235, 25, 0.8)
end

function Game_ServerOpenTask:onClickButtonOption(widget, eventType)
	if ccs.TouchEventType.ended == eventType then
		if self.curOption then
			self.curButtonOption:setBright(true)
			--self:setBubbleOfOption(self.curButtonOption, self.curOption)
		end
		local button = tolua.cast(widget, "Button")
		self.curOption = button:getTag()
		button:setBright(false)
		self.curButtonOption = button
		--g_SetBubbleNotify(self.curButtonOption, 0, 60, 40, 1)
		self:sortAndUpdate()
	end
end

function Game_ServerOpenTask:onClickButtonGroup(widget, eventType)
	if ccs.TouchEventType.ended == eventType then
		if self.curGroup then
			self.curImageView:loadTexture(getImgByPath("Common", "Blank"))
			self.curButton_TaskGroup:loadTextures(getImgByPath("ActivityTask", "BtnNormal"), getImgByPath("ActivityTask", "BtnNormal"), getImgByPath("ActivityTask", "BtnNormal"))
			self:setBubbleOfGroup(self.curButton_TaskGroup, self.curGroup)
		end

		self.curGroup = widget:getTag()
		self.curImageView = widget:getParent()
		self.curImageView:loadTexture(getImgByPath("ActivityTask", "Image_CheckBase"))
		self.curButton_TaskGroup = widget
		self.curButton_TaskGroup:loadTextures(getImgByPath("ActivityTask", "BtnCheck"), getImgByPath("ActivityTask", "BtnCheck_Press"), getImgByPath("ActivityTask", "BtnCheck_Press"))
		g_SetBubbleNotify(self.curButton_TaskGroup, 0, 0, 30, 1)

		--更新选项名
		local csv_TaskGroup = g_DataMgr:getCsvConfig_FirstKeyData("ActivityTaskGroup", self.curGroup)
		for i = 1, 5 do
            self:setBubbleOfOption(self.tbOptionButton[i], i)
			self.tbOptionLabel[i]:setText(csv_TaskGroup[i]["OptionName"])
		end

		self:onClickButtonOption(self.Button_SubOption1, ccs.TouchEventType.ended)
	end
end

function Game_ServerOpenTask:initButtonOption(Button, nIndex)
    self.tbOptionButton[nIndex] = Button
	self.tbOptionLabel[nIndex] = tolua.cast(Button:getChildByName("BitmapLabel_FuncName"), "LabelBMFont")
	Button:addTouchEventListener(handler(self, self.onClickButtonOption))
	Button:setTag(nIndex)
	self:setBubbleOfOption(Button, nIndex)
end

function Game_ServerOpenTask:initButtonGroup(ImageView, nIndex)
	ImageView:loadTexture(getImgByPath("Common", "Blank"))
	local Button_TaskGroup = tolua.cast(ImageView:getChildByName("Button_TaskGroup"), "Button")
	Button_TaskGroup:loadTextures(getImgByPath("ActivityTask", "BtnNormal"), getImgByPath("ActivityTask", "BtnNormal"), getImgByPath("ActivityTask", "BtnNormal"))
	Button_TaskGroup:addTouchEventListener(handler(self, self.onClickButtonGroup))
	Button_TaskGroup:setTag(nIndex)
	self:setBubbleOfGroup(Button_TaskGroup, nIndex)

	--按钮状态
	local Image_Locker = Button_TaskGroup:getChildByName("Image_Locker")
	local Image_Tag = Button_TaskGroup:getChildByName("Image_Tag")
	local Label_OpenDay = tolua.cast(Button_TaskGroup:getChildByName("Label_OpenDay"), "Label")
	if eLanguageVer.LANGUAGE_viet_VIET == g_LggV:getLanguageVer() then
		Label_OpenDay:setFontSize(15)
	end
	local bOpen = g_SOTSystem:isOpen(nIndex)
	Button_TaskGroup:setTouchEnabled(bOpen)
	Image_Locker:setVisible(not bOpen)
	Image_Tag:setVisible(not bOpen)
	Label_OpenDay:setVisible(not bOpen)
	local csv_TaskGroup = g_DataMgr:getCsvConfig_FirstKeyData("ActivityTaskGroup", nIndex)

	--初始化
	if 1 == nIndex then
		self:onClickButtonGroup(Button_TaskGroup, ccs.TouchEventType.ended)
	end
end

--设置剩余时间
function Game_ServerOpenTask:setRemainTime(fDelta, bFirst)
	--不要加这句
	-- if not g_WndMgr:getWnd("Game_ServerOpenTask") then return true end
	
	local nDays, nHours, nMins, nSecs = g_SOTSystem:getRemainTime()
	if not nDays then
		g_Timer:destroyTimerByID(self.nTimerID)
		self.Image_RemainDay:loadTexture(getImgByPath("ActivityTask", "Image_Day0"))
		self.Label_RemainTime:setText("00:00:00")
		return
	end
	if bFirst then
		self.Image_RemainDay:loadTexture(getImgByPath("ActivityTask", "Image_Day"..nDays))
	end
	local szTime = ""
	if nHours < 10 then
		szTime = szTime.."0"
	end
	szTime = szTime..nHours..":"
	if nMins < 10 then
		szTime = szTime.."0"
	end
	szTime = szTime..nMins..":"
	if nSecs < 10 then
		szTime = szTime.."0"
	end
	szTime = szTime..nSecs
	self.Label_RemainTime:setText(szTime)
end

function Game_ServerOpenTask:initWnd()
	local Image_ServerOpenTaskPNL = self.rootWidget:getChildByName("Image_ServerOpenTaskPNL")
	local Image_ContentPNL = Image_ServerOpenTaskPNL:getChildByName("Image_ContentPNL")
	local Image_TaskContentPNL = Image_ContentPNL:getChildByName("Image_TaskContentPNL")

	--注册任务listview
	self.ListView_Task = tolua.cast(Image_TaskContentPNL:getChildByName("ListView_Task"), "ListViewEx")
	local Panel_TaskItem = self.ListView_Task:getChildAllByName("Panel_TaskItem")
	registerListViewEvent(self.ListView_Task, Panel_TaskItem, handler(self, self.updateTaskListItem))

    --注册折扣listview
    self.ListView_Discount = tolua.cast(Image_TaskContentPNL:getChildByName("ListView_Discount"), "ListViewEx")
    local Panel_DiscountItem = self.ListView_Discount:getChildAllByName("Panel_DiscountItem")
	registerListViewEvent(self.ListView_Discount, Panel_DiscountItem, handler(self, self.updateDiscountListItem))

	--选项
    self.tbOptionButton = {}
	self.tbOptionLabel = {}
	for i = 1, 5 do
		local Button_SubOption = tolua.cast(Image_ContentPNL:getChildByName("Button_SubOption"..i), "Button")
		self:initButtonOption(Button_SubOption, i)
		if 1 == i then
			self.Button_SubOption1 = Button_SubOption
		end
	end

	--组
	for i = 1, 5 do
		local Image_TaskGroupCheck = tolua.cast(Image_ContentPNL:getChildByName("Image_TaskGroupCheck"..i), "ImageView")
		self:initButtonGroup(Image_TaskGroupCheck, i)
	end


	--设置剩余时间
	self.Image_RemainDay = tolua.cast(Image_ServerOpenTaskPNL:getChildByName("Image_RemainDay"), "ImageView")
	self.Label_RemainTime = tolua.cast(Image_ServerOpenTaskPNL:getChildByName("Label_RemainTime"), "Label")
	self.nTimerID = g_Timer:pushLoopTimer(1, handler(self, self.setRemainTime))
	self:setRemainTime(nil, true)

	self.Button_FinalReward = tolua.cast(Image_ContentPNL:getChildByName("Button_FinalReward"), "Button")
	self.Button_FinalReward:loadTextureNormal(getImgByPath("ActivityTask", "Image_FinalReward"..g_Hero:getMasterSex()))
	self.Button_FinalReward:loadTexturePressed(getImgByPath("ActivityTask", "Image_FinalReward"..g_Hero:getMasterSex()))
	self.Button_FinalReward:loadTextureDisabled(getImgByPath("ActivityTask", "Image_FinalReward"..g_Hero:getMasterSex()))
	local Image_Check = tolua.cast(self.Button_FinalReward:getChildByName("Image_Check"), "ImageView")
	Image_Check:loadTexture(getImgByPath("ActivityTask", "Image_FinalReward"..g_Hero:getMasterSex()))
	
	local function onClick_Button_FinalReward(pSender, nTag)
		g_WndMgr:showWnd("Game_ServerOpenReward")
	end
	g_SetBtnWithPressImage(self.Button_FinalReward, 1, onClick_Button_FinalReward, true, 1, 150)

	--注册界面消息
	g_FormMsgSystem:RegisterFormMsg(FormMsg_ServerOpenTask_Reward, handler(self, self.sortAndUpdate))
	
	local ImageView_Background1 = tolua.cast(self.rootWidget:getChildByName("ImageView_Background1"), "ImageView")
	ImageView_Background1:loadTexture(getBackgroundJpgImg("Background_Money1"))
	local ImageView_Background2 = tolua.cast(self.rootWidget:getChildByName("ImageView_Background2"), "ImageView")
	ImageView_Background2:loadTexture(getBackgroundPngImg("Background_Money2"))
	local ImageView_Background3 = tolua.cast(self.rootWidget:getChildByName("ImageView_Background3"), "ImageView")
	ImageView_Background3:loadTexture(getBackgroundPngImg("Background_Money3"))
end

function Game_ServerOpenTask:openWnd()
	local nBubble = 0
	if g_SOTSystem:isWholeRewardEnabled() then
		nBubble = 1
	end
	g_SetBubbleNotify(self.Button_FinalReward, nBubble, 115, 120, 1)
    g_FormMsgSystem:PostFormMsg(FormMsg_ServerOpenTask_Reward)
end

function Game_ServerOpenTask:closeWnd()
	g_Timer:destroyTimerByID(self.nTimerID)

	-- 优化因窗口缓存
	self.curButtonOption:setBright(true)
	
	--
	local ImageView_Background1 = tolua.cast(self.rootWidget:getChildByName("ImageView_Background1"), "ImageView")
	ImageView_Background1:loadTexture(getUIImg("Blank"))
	local ImageView_Background2 = tolua.cast(self.rootWidget:getChildByName("ImageView_Background2"), "ImageView")
	ImageView_Background2:loadTexture(getUIImg("Blank"))
	local ImageView_Background3 = tolua.cast(self.rootWidget:getChildByName("ImageView_Background3"), "ImageView")
	ImageView_Background3:loadTexture(getUIImg("Blank"))
end

function Game_ServerOpenTask:releaseWnd()
    --注销界面消息
    g_FormMsgSystem:UnRegistFormMsg(FormMsg_ServerOpenTask_Reward)
end
