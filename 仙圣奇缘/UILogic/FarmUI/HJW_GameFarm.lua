--------------------------------------------------------------------------------------
-- 文件名:	Game_Farm.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	
-- 日  期:	2014-12-08 11:53
-- 版  本:	1.0
-- 描  述:	药园
-- 应  用:  
---------------------------------------------------------------------------------------
Game_Farm = class("Game_Farm")
Game_Farm.__index = Game_Farm

function Game_Farm:initWnd(layerMarket)	
	--注册消息
	--解锁响应
	local order = msgid_pb.MSGID_FARM_UNLOCK_RESPONSE
	g_MsgMgr:registerCallBackFunc(order,handler(self,self.requestFarmUnlockResponse))
	
	--土地冷却响应
	local order = msgid_pb.MSGID_FARM_COOLDOWN_RESPONSE
	g_MsgMgr:registerCallBackFunc(order,handler(self,self.requestFarmCooldownResponse))
	
	self.tbAtyFarmPlant = g_DataMgr:getCsvConfig("ActivityFarmPlant")
	
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	Image_Background:loadTexture(getBackgroundJpgImg("Farm"))
end


function Game_Farm:openWnd() 
	self.nTimerID = g_Timer:pushLoopTimer(1,function()
		if not g_WndMgr:getWnd("Game_Farm") then return true end
		self:countDown()
	end)

	self:initView()
	self:batchPlantAndUpLand()	
end

function Game_Farm:closeWnd() 
	if self.nTimerID then
		g_Timer:destroyTimerByID(self.nTimerID)
		self.nTimerID = nil
	end
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	Image_Background:loadTexture(getUIImg("Blank"))
end

--药田解锁请求
function Game_Farm:requestFarmUnlock(idx)
	cclog("---------requestFarmUnlock-------------")
	cclog("---------药田解锁请求-------------")
	local msg = zone_pb.FarmUnlockRequest() 
	msg.idx = idx
	g_MsgMgr:sendMsg(msgid_pb.MSGID_FARM_UNLOCK_REQUEST, msg)
end

--药田解锁响应
function Game_Farm:requestFarmUnlockResponse(tbMsg)
	cclog("---------requestFarmUnlockResponse-------------")
	cclog("---------药田解锁响应-------------")
	local msgDetail = zone_pb.FarmUnlockResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	local msgInfo = tostring(msgDetail)
	cclog(msgInfo)
	
	local idx = msgDetail.idx;--第几块土地
	local updatedCoupon = msgDetail.updated_coupon;--剩余元宝
	
	local yuanBao = g_Hero:getYuanBao() - updatedCoupon
	if yuanBao > 0 then 
		--土地解锁 付费点
		gTalkingData:onPurchase(TDPurchase_Type.TDP_FarmFieldExtend,1,yuanBao)
	end
	
	g_Hero:setYuanBao(updatedCoupon)
	
	--土地状态 4:空闲 common_pb.FFS_OPENED
	-- nIndex,status,deadline,plant_type,reward_lv
	g_FarmData:setFarmDataStatus(idx,common_pb.FFS_OPENED,nil,nil,nil)
	g_WndMgr:openWnd("Game_Farm")
end

--土地冷却请求
function Game_Farm:requestFarmCooldown(idx)
	cclog("土地冷却请求")
	local msg = zone_pb.FarmCooldownRequest()
	msg.idx = idx
	g_MsgMgr:sendMsg(msgid_pb.MSGID_FARM_COOLDOWN_REQUEST, msg)
end
--消除土地冷却响应
function Game_Farm:requestFarmCooldownResponse(tbMsg)
	cclog("---------requestFarmCooldownResponse-------------")
	cclog("---------土地冷却响应-------------")
	local msgDetail = zone_pb.FarmCooldownResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))
	local idx = msgDetail.idx;
	local updatedCoupon = msgDetail.updated_coupon
	
	--土地状态 4:common_pb.FFS_OPENED 空闲
	-- nIndex,status,deadline,plant_type,reward_lv
	g_FarmData:setFarmDataStatus(idx,common_pb.FFS_OPENED,nil,nil,nil)
	
	local yuanBao = g_Hero:getYuanBao() - updatedCoupon
	if yuanBao > 0 then
		--土地冷却响应 付费点
		gTalkingData:onPurchase(TDPurchase_Type.TDP_FarmRemoveCooling , 1,  yuanBao)
	end
	g_Hero:setYuanBao(updatedCoupon)
	
	g_WndMgr:openWnd("Game_Farm")
end


function Game_Farm:initView()
	local rootWidget = self.rootWidget
	if not rootWidget then return end
	
	local Image_ReleaseTipPNL = tolua.cast(rootWidget:getChildByName("Image_ReleaseTipPNL"),"ImageView")
	local Label_Tip1 = tolua.cast(Image_ReleaseTipPNL:getChildByName("Label_Tip1"),"Label")
	local Label_Tip2 = tolua.cast(Image_ReleaseTipPNL:getChildByName("Label_Tip2"),"Label")
	
	local Label_FarmLevelLB = tolua.cast(rootWidget:getChildByName("Label_FarmLevelLB"),"Label")
	local Label_FarmLevel = tolua.cast(Label_FarmLevelLB:getChildByName("Label_FarmLevel"),"Label")
		
    local tbFarm = g_FarmData:getFarmRefresh()
    local nLevel = g_DataMgr:getActivityFarmLevelByExp(tbFarm.field_exp)
	Label_FarmLevel:setText(nLevel.._T("级"))
	g_AdjustWidgetsPosition({Label_FarmLevelLB, Label_FarmLevel},2)
	
	local tbFarmConfig = g_DataMgr:getCsvConfigByOneKey("ActivityFarmLevel", nLevel)
		
	local Label_CoolDownLB = tolua.cast(rootWidget:getChildByName("Label_CoolDownLB"),"Label")
	local Label_CoolDown = tolua.cast(Label_CoolDownLB:getChildByName("Label_CoolDown"),"Label")
	Label_CoolDown:setText(tbFarmConfig.CoolDown.._T("分钟"))
	Label_CoolDown:setPositionX(Label_CoolDownLB:getSize().width)
	
	local Label_IncreasePercentLB = tolua.cast(rootWidget:getChildByName("Label_IncreasePercentLB"),"Label")
	local Label_IncreasePercent = tolua.cast(Label_IncreasePercentLB:getChildByName("Label_IncreasePercent"),"Label")
	Label_IncreasePercent:setText("+"..(tbFarmConfig.IncreasePercent/100-100).."%")
	g_AdjustWidgetsPosition({Label_IncreasePercentLB, Label_IncreasePercent})
	
	local nNextFieldNum, nNextOpenLev = g_DataMgr:getActivityFarmFieldOpenCsvNextOpenLevel()
	if nNextFieldNum == 0 then
		Label_Tip1:setText( _T("药田已全部扩建完毕！"))
		Label_Tip2:setText( _T("药田已全部扩建完毕！"))
	else
		-- local nHasExpandCount = 0 --给个接口，当前实际开垦了多少块田,包括元宝开垦的。
		local nHasExpandCount = g_FarmData:getOpenFarmNum() --给个接口，当前实际开垦了多少块田,包括元宝开垦的。
		if nHasExpandCount >= 9 then
			Label_Tip1:setText( _T("药田已全部扩建完毕！"))
			Label_Tip2:setText( _T("药田已全部扩建完毕！"))
		else
			
			if nNextFieldNum >= (nHasExpandCount + 1) then
				local CSV_ActivityFarmFieldOpen = g_DataMgr:getCsvConfigByOneKey("ActivityFarmFieldOpen", nNextFieldNum)
				local txt = string.format( _T("下一块药田将在%d级自动扩建"),CSV_ActivityFarmFieldOpen.AutoOpenLev)
				Label_Tip1:setText(txt)
				Label_Tip2:setVisible(true)
				Label_Tip2:setText(string.format( _T("您也可花费%d元宝直接扩建"),CSV_ActivityFarmFieldOpen.NextFieldOpenCoupons))
			else
				local CSV_ActivityFarmFieldOpen = g_DataMgr:getCsvConfigByOneKey("ActivityFarmFieldOpen", nHasExpandCount + 1)
				local txt = string.format( _T("下一块药田将在%d级自动扩建"),CSV_ActivityFarmFieldOpen.AutoOpenLev)
				Label_Tip1:setText(txt)
				Label_Tip2:setVisible(true)
				Label_Tip2:setText(string.format( _T("您也可花费%d元宝直接扩建"),CSV_ActivityFarmFieldOpen.NextFieldOpenCoupons))
			end
		end
	end
	

	local farmData = g_FarmData:getFarmRefresh()
	if not farmData then return end 
	local data = farmData.fields
	if not data then return end
	local Image_FarmL = tolua.cast(rootWidget:getChildByName("Image_FarmL"),"ImageView")
	local count = 1
	for i = 1, #data do
		--地皮
		local Button_Field1 = tolua.cast(Image_FarmL:getChildByName("Button_Field"..i),"Button")
		--植物
		local Button_Plant = tolua.cast(Button_Field1:getChildByName("Button_Plant"),"Button")
		--可收获 需要上下悬浮的动画
		local Image_HarvestArrow = tolua.cast(Button_Plant:getChildByName("Image_HarvestArrow"),"ImageView")
		--时间
		local Image_CD = tolua.cast(Button_Field1:getChildByName("Image_CD"),"ImageView")
		Image_CD:setVisible(false)
		
		local Image_Tip = tolua.cast(Image_CD:getChildByName("Image_Tip"),"ImageView")
		local Label_CD = tolua.cast(Image_CD:getChildByName("Label_CD"),"Label")

		local btn = Button_Plant
		local falgHarves = false --收获图案 
		
		local str = getFarmImg("FieldOpen")
		local str2 = getFarmImg("FieldOpen_Click")
		local param = {normal=str,pressed=str2}
		local flag = true
		--锁住
		local function ffsLocked(statsType)
			if data[i - statsType].status > statsType then
				--扩建图案
				local str = getFarmImg("Tree_Expand") 
				local str2 = getFarmImg("Tree_Expand")
				param = {normal = str,pressed = str2}
				Button_Plant:setVisible(true)
			else
				flag = false
			end
		end		
		--已种植 sotpAction()
		local function ffsPlanted(statsType)
			param = {normal = str,pressed = str2}
			self:setLoadTexture(Button_Field1,param)
			
			local plantType = data[i].plant_type
			local tbAFP = self.tbAtyFarmPlant[plantType][1].PlantPic
			str = getFarmImg(tbAFP)
			str2 = getFarmImg(tbAFP)
			param = {normal = str,pressed = str2}
			falgHarves = true 
			Button_Plant:setVisible(true)
			
			Image_HarvestArrow:stopAllActions()
			Image_HarvestArrow:setPositionY(150)
			g_CreateUpAndDownAnimation(Image_HarvestArrow)
			
		end		
		--冷却中
		local function ffsCoolingdown(statsType)
			if data[i].deadline > g_GetServerTime() then
				Image_CD:setVisible(true)
			else
				Image_CD:setVisible(false)
				g_FarmData:setFarmDataStatus(i,common_pb.FFS_OPENED,nil,nil,nil)
			end
			local times = data[i].deadline  - g_GetServerTime()
			local cooldown = SecondsToTable( times )
			local strTimes = TimeTableToStr(cooldown,":")
			Label_CD:setText(strTimes)
			btn:setVisible(false) --这个时候是 植物图案 或 扩建图案 要隐藏
			btn = Button_Field1 --重新赋予对象--地皮
		end		
		--空闲
		local function ffsOpened(statsType)
			Button_Plant:setVisible(false)
			btn = Button_Field1
		end		
		local tbFunc={ffsLocked,ffsPlanted,ffsCoolingdown,ffsOpened}
		self:status(data[i].status,tbFunc)
		self:setLoadTexture(btn,param)
		Image_HarvestArrow:setVisible(falgHarves)
		
		local function onTouch(pSender, eventType)
			if eventType == ccs.TouchEventType.ended then
				--锁住
				local function ffsLocked(statsType)
					if data[i - statsType].status > statsType then
						--扩建
						local CSV_ActivityFarmFieldOpen = g_DataMgr:getCsvConfig("ActivityFarmFieldOpen")
						local nBuyPrice = CSV_ActivityFarmFieldOpen[i].NextFieldOpenCoupons
						
						if not g_CheckYuanBaoConfirm(nBuyPrice, string.format( _T("扩建药田需要%d元宝, 您的元宝不足是否前往充值"),nBuyPrice)) then
							return
						end
						
						local function onClickConfirm()
							self.coupons = CSV_ActivityFarmFieldOpen[i].NextFieldOpenCoupons
							self:requestFarmUnlock(i)
						end
						
						g_ClientMsgTips:showConfirm(string.format( _T("是否花费%d元宝扩建一块药田"),nBuyPrice), onClickConfirm, nil)
					end
				end	
				
				--已种植
				local function ffsPlanted(statsType)
					--"收获:"..i
					local param ={
						farmIndex =  i,--农场下标
						plantType = data[i].plant_type --植物类型
					}
					g_WndMgr:showWnd("Game_FarmReward",param)
				end		
				
				--冷却中
				local function ffsCoolingdown(statsType)
					if data[i].status - statsType == 0 then --冷却中
						local deadlineTime = (data[i].deadline  - g_GetServerTime())/240
						if math.floor(deadlineTime) > g_Hero:getYuanBao() then 
							local tips = _T("元宝不足，是否前往充值？")
							g_ClientMsgTips:showConfirm(tips, function() 
								g_WndMgr:showWnd("Game_ReCharge")
							end)
							return 
						end
						local tips = string.format(_T("消除冷却时间需要消耗%d元宝"),math.floor(deadlineTime))
						g_ClientMsgTips:showConfirm(tips, function() self:requestFarmCooldown(i) end)
					end
				end	
				
				--空闲
				local function ffsOpened(statsType)
					--("种植:"
					local param = {framIdx = i,plantType = false }
					g_WndMgr:showWnd("Game_FarmSelectPlant",param)
				end		
				local tbFunc={ffsLocked,ffsPlanted,ffsCoolingdown,ffsOpened}
				self:status(data[i].status,tbFunc)
			end
		end
		Button_Field1:setTouchEnabled(flag)
		Button_Field1:addTouchEventListener(onTouch)		
		Button_Field1:setAlphaTouchEnable(true);		
	end
end

function Game_Farm:countDown()
	local rootWidget = self.rootWidget
	if not rootWidget then return end
	local farmData = g_FarmData:getFarmRefresh()
	if not farmData then return end 
	local data = farmData.fields
	if not data then return end 
	local Image_FarmL = tolua.cast(rootWidget:getChildByName("Image_FarmL"),"ImageView")
	for i = 1,#data do
		--冷却中
		if data[i].status - common_pb.FFS_COOLINGDOWN == 0 and data[i].deadline > g_GetServerTime()   then 
			local cooldown = SecondsToTable( data[i].deadline - g_GetServerTime() )
			local times = TimeTableToStr(cooldown,":")
			local Button_Field1 = tolua.cast(Image_FarmL:getChildByName("Button_Field"..i),"Button")
			--时间
			local Image_CD = tolua.cast(Button_Field1:getChildByName("Image_CD"),"ImageView")
			local Image_Tip = tolua.cast(Image_CD:getChildByName("Image_Tip"),"ImageView")
			local Label_CD = tolua.cast(Image_CD:getChildByName("Label_CD"),"Label")
			Label_CD:setText(times)
		else
			--冷却中
			if data[i].status - common_pb.FFS_COOLINGDOWN == 0 then
				g_FarmData:setFarmDataStatus(i,common_pb.FFS_OPENED,nil,nil,nil)
				g_WndMgr:openWnd("Game_Farm")
			end
		end
	
	end
end

--批量种植和升级土地的按钮和回调函数
function Game_Farm:batchPlantAndUpLand()
	local rootWidget = self.rootWidget
	local Button_BatchExpTree = tolua.cast(rootWidget:getChildByName("Button_BatchExpTree"),"Button")
	local Button_LevelUp = tolua.cast(rootWidget:getChildByName("Button_LevelUp"),"Button")
		
	local function onbatchPlant(pSender, nTag)
	
		local count = 0
		local farmData = g_FarmData:getFarmRefresh()
		if not farmData then return end
		local data = farmData.fields 
		if not data then return end
		for k = 1,#data do 
			if data[k].status - common_pb.FFS_OPENED == 0 then 
				count = count + 1
			end 
		end
	
		if count <= 0 then
			g_ClientMsgTips:showMsgConfirm(_T("没有空地种植了"))
			return 
		end
	
		local param = {plantType = true }
		g_WndMgr:showWnd("Game_FarmSelectPlant",param)
		
	end
	g_SetBtnWithPressImage(Button_BatchExpTree, 1, onbatchPlant, true, 1)
	
	local function onUpLand(pSender, nTag)
		g_WndMgr:showWnd("Game_FarmPray")
	end
	g_SetBtnWithPressImage(Button_LevelUp, 1, onUpLand, true, 1)
	g_SetBubbleNotify(Button_LevelUp,g_CheckFarmByIncenseNum(),50,50)
end

--[[
	渲染不同状态先的图案
	@param object 传入要改变的对象
	@param param = {normal="正常状态",pressed="点击下状态",disabled="禁用状态"}
]]
function Game_Farm:setLoadTexture(object,param)
	if not object then return end 
	
	local normal = param.normal
	local pressed = param.pressed
	local disabled = param.disabled
	local imageType = param.imageType;--图案加载类型
	if normal then 
		--正常状态
		object:loadTextureNormal(normal)
	end
	
	if pressed then 
		--点击下状态
		object:loadTexturePressed(pressed)
	end
	
	if disabled then
		--禁用状态
		object:loadTextureDisabled(disabled)
	end
end

-- function Game_Farm:incenseCount()
	-- local farmData = g_FarmData:getFarmRefresh()
-- end

function Game_Farm:status(statusType,func)
	local statusTable = {
		common_pb.FFS_LOCKED,		--锁住
		common_pb.FFS_PLANTED,		--已种植
		common_pb.FFS_COOLINGDOWN,	--冷却中
		common_pb.FFS_OPENED,		--空闲
	}
	for key,value in pairs(func) do
		if key - statusTable[statusType] == 0 then 
			value(statusType)
		end
	end

end



