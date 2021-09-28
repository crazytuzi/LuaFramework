--------------------------------------------------------------------------------------
-- 文件名:	Game_FarmReward.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	
-- 日  期:	2014-12-09 10:14
-- 版  本:	1.0
-- 描  述:	--药园收获后的抽奖
-- 应  用:  
---------------------------------------------------------------------------------------
Game_FarmReward = class("Game_FarmReward")
Game_FarmReward.__index = Game_FarmReward

-- function Game_FarmReward:checkData()
-- end

function Game_FarmReward:initWnd()	
	--注册消息
	local order = msgid_pb.MSGID_FARM_HARVEST_RESPONSE
	g_MsgMgr:registerCallBackFunc(order,handler(self,self.requestFarmHarvestResponse))	
	
	--领取前 第一次免费抽奖
	local order = msgid_pb.MSGID_FARM_REWARD_RESPONSE
	g_MsgMgr:registerCallBackFunc(order,handler(self,self.requestFarmRewardResponse))	

	self.plantTypeName = { _T("主角经验"), _T("铜钱"), _T("阅历"), _T("香贡"), _T("神力"), }
	self.color = {
		ccs.COLOR.WHITE,
		ccs.COLOR.BRIGHT_GREEN,
		ccs.COLOR.DARK_SKY_BLUE,
		ccs.COLOR.FUCHSIA,
		ccs.COLOR.GOLD,
	}
	self.tbAtyFarmPlant = g_DataMgr:getCsvConfig("ActivityFarmPlant") --农田信息表
	self.tbAtyFarmLevel = g_DataMgr:getCsvConfig("ActivityFarmLevel") --土地等级表
	self.tbConsume = g_DataMgr:getCsvConfigByOneKey("GlobalCfg",57) --刷新奖励需要的消耗
	local playerExp = g_DataMgr:getCsvConfigByOneKey("PlayerExp",g_Hero:getMasterCardLevel()) --刷新奖励需要的消耗
	self.tbPlayerExp = {
		playerExp.FarmTreeExp,
		playerExp.FarmTreeCoins,
		playerExp.FarmTreeKnowledge,
		playerExp.FarmTreeIncense,
		playerExp.FarmTreeEssence,
	}

	
	self.type = {
		macro_pb.ITEM_TYPE_MASTER_EXP,	--"主角经验"
		macro_pb.ITEM_TYPE_GOLDS,		--"铜钱"
		macro_pb.ITEM_TYPE_KNOWLEDGE,	--"阅历"
		macro_pb.ITEM_TYPE_INCENSE,		--"香贡",
		macro_pb.ITEM_TYPE_ESSENCE,		--"灵力/元素精华",
		
	}
	
end

function Game_FarmReward:openWnd(param)
	if not param then return end

	self.plant_type = param.plantType or 1 --植物类型
	self.farmIndex = param.farmIndex or 1 --农田编号
	
   self.allValue_ = 0

	g_VIPBase:setcurFarmIdx(self.farmIndex)
	
	self:initView()
	
end

function Game_FarmReward:closeWnd() 
	if self.nTimerId then
		g_Timer:destroyTimerByID(self.nTimerId)
		self.nTimerId = nil
	end	

	if self.cBox then 
		self.cBox:setSelectedState(false)
		self.cBox = nil
	end
	-- if self.farmIndex then
		-- self.farmIndex = nil
	-- end	
	if self.plant_type then
		self.plant_type = nil
	end
end

--收获请求
function Game_FarmReward:requestFarmHarvest(idx)
	cclog("收获请求")
	local msg = zone_pb.FarmHarvestRequest() 
	msg.idx = idx
	g_MsgMgr:sendMsg(msgid_pb.MSGID_FARM_HARVEST_REQUEST, msg)
end

--收获响应
function Game_FarmReward:requestFarmHarvestResponse(tbMsg)
	cclog("---------requestFarmHarvestResponse-------------")
	cclog("---------收获响应-------------")
	local msgDetail = zone_pb.FarmHarvestResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	local msgInfo = tostring(msgDetail)
	cclog(msgInfo)
	
	local idx = msgDetail.idx --植物序号
	local deadline = msgDetail.deadline --冷却时间
	local plant_type = msgDetail.plant_type --种植类型
	local updated_data = msgDetail.updated_data --更新数值
	local nMasterCardLevel = msgDetail.lv --更新玩家等级
	local nMasterCardExp = msgDetail.exp --更新玩家经验
	-- (nIndex,status,deadline,plant_type,reward_lv)
	--领取后土地冷却 common_pb.FFS_COOLINGDOWN 3
	g_FarmData:setFarmDataStatus(idx,common_pb.FFS_COOLINGDOWN,deadline,0,0)
	--消耗祝福次数
	g_FarmData:setIncenseCount()
	
	--收获的时候重置。刷新次数
	g_VIPBase:setFarmAwardUpdateIdxTimes(idx, 0)
	
	local types = self.type[plant_type]
	--领取奖励时，调用显示奖励
	if not self.allValue_ then self.allValue_ = 0 end
	
	if types == macro_pb.ITEM_TYPE_MASTER_EXP then	--主角经验
		--待调整
		local function updateHeroResourceInfo()
			g_Hero:addMasterCardExp(0, nMasterCardLevel, nMasterCardExp)
		end
		g_ShowRewardMsgConfrim(types, self.allValue_, updateHeroResourceInfo)
	elseif types == macro_pb.ITEM_TYPE_GOLDS then	--铜钱
		g_Hero:setCoins(updated_data)
		g_ShowRewardMsgConfrim(types, self.allValue_)
	elseif types == macro_pb.ITEM_TYPE_KNOWLEDGE then	--阅历
		g_Hero:setKnowledge(updated_data)
		g_ShowRewardMsgConfrim(types, self.allValue_)
	elseif types == macro_pb.ITEM_TYPE_INCENSE then	--香贡
		g_Hero:setIncense(updated_data)
		g_ShowRewardMsgConfrim(types, self.allValue_)
	elseif types == macro_pb.ITEM_TYPE_ESSENCE then	--灵力/元素精华
		g_Hero:setKnowledge(updated_data)
		g_ShowRewardMsgConfrim(types, self.allValue_)
	end
	g_WndMgr:closeWnd("Game_FarmReward")
end

--领取前第一次免费抽奖请求
function Game_FarmReward:requestFarmRewardRequest(idx)
	local msg = zone_pb.FarmRewardRequest() 
	msg.idx = idx
	g_MsgMgr:sendMsg(msgid_pb.MSGID_FARM_REWARD_REQUEST, msg)
end
--领取前第一次免费抽奖响应
function Game_FarmReward:requestFarmRewardResponse(tbMsg)
	cclog("---------requestFarmHarvestResponse------领取前第一次免费抽奖响应-------")
	local msgDetail = zone_pb.FarmRewardResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	local msgInfo = tostring(msgDetail)
	cclog(msgInfo)
	
	local reward_lv = msgDetail.reward_lv;--奖励类型
	local idx = msgDetail.idx
	local updatedCoupons = msgDetail.updated_coupons
	g_Hero:setYuanBao(updatedCoupons)
	
	
	local wndInstance = g_WndMgr:getWnd("Game_FarmReward")
	if wndInstance then
		local param = wndInstance:widgetAll()
		
		local Label_NeedYuanBao = tolua.cast(param["Button_Refresh"]:getChildByName("Label_NeedYuanBao"),"Label")	
		
		local function objAction(count)
			local Image_RewardType = tolua.cast(param["Image_Background"]:getChildByName("Image_RewardType"..count),"ImageView")	
			local CheckBox_RewardType = tolua.cast(Image_RewardType:getChildByName("CheckBox_RewardType"),"CheckBox")	
			wndInstance:awardAction(CheckBox_RewardType)
			CheckBox_RewardType:setTouchEnabled(false)
			wndInstance:RewardShow(count,param["Label_Name"],param["Label_RewardValue"])
		end
		
		local Image_FarmRewardPNL = tolua.cast(wndInstance.rootWidget:getChildByName("Image_FarmRewardPNL"),"ImageView")
		local Button_Return = tolua.cast(Image_FarmRewardPNL:getChildByName("Button_Return"),"Button")
		Button_Return:setTouchEnabled(false)
		local function actionEnded()
			param["Button_Refresh"]:setTouchEnabled(true)
			param["Button_Confirm"]:setTouchEnabled(true)
			param["Button_Refresh"]:setBright(true)
			param["Button_Confirm"]:setBright(true)
			Button_Return:setTouchEnabled(true)
			if g_PlayerGuide:checkCurrentGuideSequenceNode("ActionEventEnd", "Game_FarmReward") then
				g_PlayerGuide:showCurrentGuideSequenceNode()
			end
		end

		local params = {
			rewardLev =reward_lv,--"品质等级 动画最终停止的地方"
			func = objAction,--回调函数带 count 每累加到numAward后重置为1 
			endFunc =actionEnded,--动画结束后的回调函数
		}
		wndInstance.nTimerId = g_AnimationAward(params)
		
		g_FarmData:setFarmDataStatus(idx, nil, nil, wndInstance.plant_type, reward_lv)
		
		local times = msgDetail.times --刷新次数
		if times > 0 then
			g_VIPBase:setFarmAwardUpdateIdxTimes(idx, times)
			--刷新奖励需要的消耗 根据刷新次数获取当前需要消耗多少
			local coupons = g_VIPBase:getVipLevelCntGold(VipType.VipBuyOpType_FarmRefresh)
			Label_NeedYuanBao:setText(coupons)
			--植物品种刷新 付费点
			gTalkingData:onPurchase(TDPurchase_Type.TDP_FarmQuality ,1, coupons)
		end
	end
end

--[[
	初始界面上的控件元素
	@return param 保存了 控件元素对象 local param["Button_Refresh"]
]]
function Game_FarmReward:widgetAll()
	local wndInstance = g_WndMgr:getWnd("Game_FarmReward")
	if wndInstance and wndInstance.rootWidget then
		local Image_FarmRewardPNL = tolua.cast(wndInstance.rootWidget:getChildByName("Image_FarmRewardPNL"),"ImageView")
		--刷新按钮
		local Button_Refresh = tolua.cast(Image_FarmRewardPNL:getChildByName("Button_Refresh"),"Button")
		--领取按钮
		local Button_Confirm = tolua.cast(Image_FarmRewardPNL:getChildByName("Button_Confirm"),"Button")
		--收获按钮
		local Button_Harvest = tolua.cast(Image_FarmRewardPNL:getChildByName("Button_Harvest"),"Button")
		local Image_ContentPNL = tolua.cast(Image_FarmRewardPNL:getChildByName("Image_ContentPNL"),"ImageView")
		--物品展示区
		local Image_Background = tolua.cast(Image_ContentPNL:getChildByName("Image_Background"),"ImageView")
		--收益展示区
		local Image_MoneyBase = tolua.cast(Image_ContentPNL:getChildByName("Image_MoneyBase"),"ImageView")
		--物品名称 与相关字体颜色设置
		local Label_Name = tolua.cast(Image_ContentPNL:getChildByName("Label_Name"),"Label")
		--收益名称 与相关字体颜色设置
		local Label_RewardValue = tolua.cast(Image_ContentPNL:getChildByName("Label_RewardValue"),"Label")
		
		local param ={
			["Button_Refresh"] = Button_Refresh,
			["Button_Confirm"] = Button_Confirm,
			["Button_Harvest"] = Button_Harvest,
			["Label_Name"] = Label_Name,
			["Label_RewardValue"] = Label_RewardValue,
			["Image_Background"] = Image_Background,
			["Image_MoneyBase"] = Image_MoneyBase,
			["Image_ContentPNL"] = Image_ContentPNL,
		}
		return param
	end
end

--收益展示
function Game_FarmReward:RewardShow(count, Label_Name, Label_RewardValue)
	local wndInstance = g_WndMgr:getWnd("Game_FarmReward")
	if wndInstance then 
		local plant = wndInstance.tbAtyFarmPlant[wndInstance.plant_type][count]
		Label_Name:setText(plant.Name)
		g_setTextColor(Label_Name, wndInstance.color[count])
		local tbFarm = g_FarmData:getFarmRefresh()
		--农场土地等级
		local farmPlantLev = g_DataMgr:getActivityFarmLevelByExp(tbFarm.field_exp)
		--祝福次数
		-- local incense = tbFarm.incense_times

		local userLevel = g_Hero:getMasterCardLevel()
		-- 最后收获经验=(种植经验 + 增加的系数1*（玩家当前等级-农田开启等级))*(农田等级对应加成/g_BasePercent) * 增加的系数2
		local globalCfg = g_DataMgr:getCsvConfigByOneKey("GlobalCfg", 65)
		local addValue = math.floor(
				( 
					plant.AddResourceValue + plant.AddResourceParam1 * (userLevel - globalCfg.Data) 
				) 
				* ( 
					wndInstance.tbAtyFarmLevel[farmPlantLev].IncreasePercent 
					* (plant.AddResourceParam2 / g_BasePercent) / g_BasePercent 
				) 
			) 
		wndInstance.allValue_ =  addValue
		local nIncreasePercent = (wndInstance.tbAtyFarmLevel[farmPlantLev].IncreasePercent-10000)/100
		Label_RewardValue:setText(_T("收获")..wndInstance.plantTypeName[wndInstance.plant_type].." "..addValue.."(+"..nIncreasePercent.."%)")
		g_setTextColor(Label_RewardValue, wndInstance.color[count])
	end
end

--保存只有一个品质选择框亮起
function Game_FarmReward:awardAction(checkBox)
	if self.cBox then 
		self.cBox:setSelectedState(false)
	end
	checkBox:setSelectedState(true)
	self.cBox = checkBox
end


function Game_FarmReward:initView()
	local param =self:widgetAll()
	param["Button_Refresh"]:setVisible(false)
	
	-- local coupons = g_DataMgr:getGlobalCfgCsv("farm_reward_cost_coupons")

    --概率文本设置
    local Label_RefreshTip = tolua.cast(self.rootWidget:getChildAllByName("Label_RefreshTip"), "Label")
    local text = string.format(_T("%d次内必出最高品质奖励"), g_DataMgr:getGlobalCfgCsv("farm_refresh_max_count"))
    Label_RefreshTip:setText(text)
	
	--刷新奖励需要的消耗 根据刷新次数获取当前需要消耗多少
	local coupons = g_VIPBase:getVipLevelCntGold(VipType.VipBuyOpType_FarmRefresh)
	
	local Label_NeedYuanBao = tolua.cast(param["Button_Refresh"]:getChildByName("Label_NeedYuanBao"),"Label")	
	Label_NeedYuanBao:setText(coupons)
	
	param["Button_Confirm"]:setVisible(false)
	param["Button_Harvest"]:setVisible(true)
	--初始植物品质禁止点击
	for i = 1,5 do
		local Image_RewardType = tolua.cast(param["Image_Background"]:getChildByName("Image_RewardType"..i),"ImageView")	
		
		local tbAFP = self.tbAtyFarmPlant[self.plant_type][i].PlantIcon
		local str = getIconImg(tbAFP)
		Image_RewardType:loadTexture(str)
		
		local CheckBox_RewardType = tolua.cast(Image_RewardType:getChildByName("CheckBox_RewardType"),"CheckBox")	
		CheckBox_RewardType:setTouchEnabled(false)
	end
	
	local function onRefesh(pSender, eventType)
		if eventType == ccs.TouchEventType.ended then
            local farmData = g_FarmData:getFarmRefresh()
            local data = farmData.fields
            if not data then return end
            if not self.farmIndex then return end 
            local reward_lv = data[self.farmIndex].reward_lv
            if reward_lv == 5 then--5是最好品质
                 g_ShowSysTips({text=_T("当前已经是最高品质了")})
                 return
            end

            local coupons = g_VIPBase:getVipLevelCntGold(VipType.VipBuyOpType_FarmRefresh)
			local txt = string.format(_T("刷新奖励需要%d元宝, 您的元宝不足是否前往充值"), coupons)
			if not g_CheckYuanBaoConfirm(coupons, txt) then
				return
			end
			
			local function onClickConfirm()
			
				param["Button_Refresh"]:setTouchEnabled(false)
				param["Button_Confirm"]:setTouchEnabled(false)			
				param["Button_Refresh"]:setBright(false)
				param["Button_Confirm"]:setBright(false)
				if not self.farmIndex then return end 
				self:requestFarmRewardRequest(self.farmIndex)
			
			end
			
			local couponss = g_VIPBase:getVipLevelCntGold(VipType.VipBuyOpType_FarmRefresh)
			local txt = string.format(_T("是否花费%d元宝,刷新奖励?"), couponss)
			g_ClientMsgTips:showConfirm(txt, onClickConfirm, nil)
				
		end
		
	end
	param["Button_Refresh"]:setTouchEnabled(false)
	param["Button_Refresh"]:addTouchEventListener(onRefesh)	
	
	local function onConfirm(pSender, eventType)
		if eventType == ccs.TouchEventType.ended then
			local nDailyType = macro_pb.Incense_Times 
			local bTimesFull = g_Hero:IsDailyNoticeFull(nDailyType)
			if not bTimesFull then 
				g_ClientMsgTips:showConfirm(_T("您今天没有祭拜土地，是否先祭拜土地获得收益加成？"), function()
					g_WndMgr:openWnd("Game_FarmPray")
				end) 
				return 
			end
			g_WndMgr:getFormtbRootWidget("Game_RewardMsgConfirm")
			g_WndMgr:getFormtbRootWidget("Game_HeroLevelUpAnimation")
			if not self.farmIndex then return end 
			self:requestFarmHarvest(self.farmIndex)
		end
	end
	param["Button_Confirm"]:setTouchEnabled(false)
	param["Button_Confirm"]:addTouchEventListener(onConfirm)
	
	local function onHarvest(pSender, nTag)
		param["Button_Harvest"]:setVisible(false)
		param["Button_Refresh"]:setVisible(true)
		param["Button_Confirm"]:setVisible(true)
		param["Button_Refresh"]:setBright(false)
		param["Button_Confirm"]:setBright(false)
		if not self.farmIndex then return end 
		self:requestFarmRewardRequest(self.farmIndex)
	end
	g_SetBtnWithGuideCheck(param["Button_Harvest"], 1, onHarvest, true)
	
	
	local farmData = g_FarmData:getFarmRefresh()
	local data = farmData.fields
	if not data then return end
	if not self.farmIndex then return end 
	local reward_lv = data[self.farmIndex].reward_lv
	if reward_lv > 0 and data[self.farmIndex].status - common_pb.FFS_PLANTED--[[已种植]] == 0 then
		self:RewardShow(reward_lv,param["Label_Name"],param["Label_RewardValue"])
		param["Button_Harvest"]:setVisible(false)
		param["Button_Refresh"]:setVisible(true)
		param["Button_Confirm"]:setVisible(true)
		param["Button_Harvest"]:setTouchEnabled(false)
		param["Button_Confirm"]:setTouchEnabled(true)
		param["Button_Refresh"]:setTouchEnabled(true)
		local Image_RewardType = tolua.cast(param["Image_Background"]:getChildByName("Image_RewardType"..reward_lv),"ImageView")	
		local CheckBox_RewardType = tolua.cast(Image_RewardType:getChildByName("CheckBox_RewardType"),"CheckBox")	
		self:awardAction(CheckBox_RewardType)
		CheckBox_RewardType:setTouchEnabled(false)
	else	
		--默认为 第一种植物 1
		self:RewardShow(1,param["Label_Name"],param["Label_RewardValue"])
	end
	
end

function Game_FarmReward:showWndOpenAnimation(funcWndOpenAniCall)
	local Image_FarmRewardPNL = tolua.cast(self.rootWidget:getChildByName("Image_FarmRewardPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(Image_FarmRewardPNL, funcWndOpenAniCall, 1.05, 0.2, Image_Background)
end

function Game_FarmReward:showWndCloseAnimation(funcWndCloseAniCall)
	local Image_FarmRewardPNL = tolua.cast(self.rootWidget:getChildByName("Image_FarmRewardPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIDisappearAnimation_Scale(Image_FarmRewardPNL, funcWndCloseAniCall, 1.05, 0.2, Image_Background)
end
