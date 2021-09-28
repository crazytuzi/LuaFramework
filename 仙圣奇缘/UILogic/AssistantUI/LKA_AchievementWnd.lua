
-- local bubbleAchievementNum = 0
achievementCfg = {}
-- local SPECIAL_TYPE = 1 
local CSV_ActivityChengJiu = g_DataMgr:getCsvConfig("ActivityChengJiu")
local function onUpdateListViewRew(Panel_ChengJiuItem, nIndex)
	
	local config = achievementCfg[nIndex]
	
	local key1 = config.key1
	local key2 = config.key2
	
	local rewardState = config.reward_state
	local targetNum = config.target_num
	local cvsValue = CSV_ActivityChengJiu[key1][key2]

	local Button_ChengJiuItem = tolua.cast(Panel_ChengJiuItem:getChildByName("Button_ChengJiuItem"), "Button")
	--成就名称
	local Label_Name = tolua.cast(Button_ChengJiuItem:getChildByName("Label_Name"), "Label")
	Label_Name:setText(cvsValue.AffairsName)

	--成就达成条件
	local Label_Desc = tolua.cast(Button_ChengJiuItem:getChildByName("Label_Desc"), "Label")
	Label_Desc:setText(cvsValue.RewardDesc)

	local obj_value = cvsValue.ValueMax
	local percent = math.floor((targetNum / obj_value)*100)
	if rewardState == macro_pb.ACHIEVEMENT_REWARD_STATE_CAN_RECV then 
		percent = 100
	end
	
	local Image_Progress = tolua.cast(Button_ChengJiuItem:getChildByName("Image_Progress"), "ImageView")
	local LoadingBar_Progress = tolua.cast(Image_Progress:getChildByName("LoadingBar_Progress"), "LoadingBar")
	LoadingBar_Progress:setPercent(percent)

	--同一类型成就完成进度
	local Label_Progress = tolua.cast(LoadingBar_Progress:getChildByName("Label_Progress"), "Label")
	local progressText = percent

	if progressText > 100 then progressText = 100 end

	Label_Progress:setText( progressText.."%")
	
	local Image_RewardValueIcon = tolua.cast(Button_ChengJiuItem:getChildByName("Image_RewardValueIcon"), "ImageView")
	Image_RewardValueIcon:removeAllChildren()

	local itemModel, tbCsvBase = g_CloneDropRewardModel(cvsValue)
	itemModel:setPositionXY(0, 0)
	itemModel:setScale(0.5)
	Image_RewardValueIcon:addChild(itemModel)
	
	local Label_RewardValue = tolua.cast(Button_ChengJiuItem:getChildByName("Label_RewardValue"), "Label")
	Label_RewardValue:setText("×"..cvsValue.DropItemNum)
	
	local Button_Get = tolua.cast(Button_ChengJiuItem:getChildByName("Button_Get"), "Button")
	local BitmapLabel_FuncName = tolua.cast(Button_Get:getChildByName("BitmapLabel_FuncName"), "LabelBMFont")

	local status = false
	if rewardState == macro_pb.ACHIEVEMENT_REWARD_STATE_INIT then --
		--初始状态，不可领
		BitmapLabel_FuncName:setText(_T("进行中"))
	elseif rewardState == macro_pb.ACHIEVEMENT_REWARD_STATE_CAN_RECV then --
		--可领取
		status = true
		BitmapLabel_FuncName:setText(_T("可领取"))
	elseif rewardState == macro_pb.ACHIEVEMENT_REWARD_STATE_ALREADY_RECV then --
		--已经领取
		BitmapLabel_FuncName:setText(_T("已领取"))
	end

	local function onPressed_Button_Get()
		--预加载窗口缓存防止卡顿
		g_WndMgr:getFormtbRootWidget("Game_RewardMsgConfirm")
		g_AssistantData:requestAchievementRecvRewardRequest(key1,key2)
	end
	g_SetBtnWithEvent(Button_Get, nIndex, onPressed_Button_Get, status and not rewarded)
end

local function sortTable(GameObjAchievementA, GameObjAchievementB)
	local nRewardStateA = GameObjAchievementA.reward_state
	local nRewardStateB = GameObjAchievementB.reward_state
	if nRewardStateA == nRewardStateB then
		local nDropItemTypeA = CSV_ActivityChengJiu[GameObjAchievementA.key1][GameObjAchievementA.key2].DropItemType
		local nDropItemTypeB = CSV_ActivityChengJiu[GameObjAchievementB.key1][GameObjAchievementB.key2].DropItemType
		
		if nDropItemTypeA == macro_pb.ITEM_TYPE_COUPONS then -- 元宝修正掉落类型置顶
			nDropItemTypeA = 0
		end
		
		if nDropItemTypeB == macro_pb.ITEM_TYPE_COUPONS then -- 元宝修正掉落类型置顶
			nDropItemTypeB = 0
		end
		
		if nDropItemTypeA == nDropItemTypeB then
			local nObjValueA = CSV_ActivityChengJiu[GameObjAchievementA.key1][GameObjAchievementA.key2].ValueMax
			local nObjValueB = CSV_ActivityChengJiu[GameObjAchievementB.key1][GameObjAchievementB.key2].ValueMax
			local nPercentA = math.floor((GameObjAchievementA.target_num/nObjValueA)*100)
			local nPercentB = math.floor((GameObjAchievementB.target_num/nObjValueB)*100)
			if nPercentA == nPercentB then
				if GameObjAchievementA.key1 == GameObjAchievementB.key2 then
					return GameObjAchievementA.key2 < GameObjAchievementB.key2
				else
					return GameObjAchievementA.key1 < GameObjAchievementB.key1
				end
			else
				return nPercentA > nPercentB
			end
		else
			return nDropItemTypeA < nDropItemTypeB
		end
	else
		if nRewardStateA == macro_pb.ACHIEVEMENT_REWARD_STATE_CAN_RECV then -- 服务端状态修正成正序
			nRewardStateA = 1
		elseif nRewardStateA == macro_pb.ACHIEVEMENT_REWARD_STATE_INIT then -- 服务端状态修正成正序
			nRewardStateA = 2
		elseif nRewardStateA == macro_pb.ACHIEVEMENT_REWARD_STATE_ALREADY_RECV then -- 服务端状态修正成正序
			nRewardStateA = 3
		end
		
		if nRewardStateB == macro_pb.ACHIEVEMENT_REWARD_STATE_CAN_RECV then -- 服务端状态修正成正序
			nRewardStateB = 1
		elseif nRewardStateB == macro_pb.ACHIEVEMENT_REWARD_STATE_INIT then -- 服务端状态修正成正序
			nRewardStateB = 2
		elseif nRewardStateB == macro_pb.ACHIEVEMENT_REWARD_STATE_ALREADY_RECV then -- 服务端状态修正成正序
			nRewardStateB = 3
		end
		
		return nRewardStateA < nRewardStateB
	end
end


function setAchievementData()
	achievementCfg = {}
	achievementCfg = g_AssistantData:getRecordList()
	if not achievementCfg then return end 

	table.sort(achievementCfg, sortTable)	
	
	local wnd = g_WndMgr:getWnd("Game_Home")
	if not wnd then return end
	wnd.isAchievementRespon = true
	local wnd = g_WndMgr:getWnd("Game_Assistant")
	if not wnd then return end
	g_SetBubbleNotify(wnd.Button_ChengJiu, g_GetNoticeNum_Assistant_Achievement(), 60, 50)
	wnd.ListView_ChengJiuList:updateItems(#achievementCfg)
end

function Game_Assistant:initAchievementWnd()
	local ImageView_AssistantPNL = tolua.cast(self.rootWidget:getChildByName("ImageView_AssistantPNL"), "ImageView")
	local Image_ChengJiuPNL = tolua.cast(ImageView_AssistantPNL:getChildByName("Image_ChengJiuPNL"), "ImageView")
	local ListView_ChengJiuList = tolua.cast(Image_ChengJiuPNL:getChildByName("ListView_ChengJiuList"), "ListViewEx")
	local Panel_ChengJiuItem = tolua.cast(ListView_ChengJiuList:getChildByName("Panel_ChengJiuItem"), "Layout")
	self.ListView_ChengJiuList = registerListViewEvent(ListView_ChengJiuList, Panel_ChengJiuItem, onUpdateListViewRew, 0, nil, 0, 4)
	
	local imgScrollSlider = ListView_ChengJiuList:getScrollSlider()
	if not g_tbScrollSliderXY.ListView_ChengJiuList_X then
		g_tbScrollSliderXY.ListView_ChengJiuList_X = imgScrollSlider:getPositionX()
	end
	imgScrollSlider = imgScrollSlider:setPositionX(g_tbScrollSliderXY.ListView_ChengJiuList_X - 2)
end
