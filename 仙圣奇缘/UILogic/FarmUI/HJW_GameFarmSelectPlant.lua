--------------------------------------------------------------------------------------
-- 文件名:	Game_FarmSelectPlant.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	
-- 日  期:	2014-12-08 11:53
-- 版  本:	1.0
-- 描  述:	种植
-- 应  用:  
---------------------------------------------------------------------------------------
Game_FarmSelectPlant = class("Game_FarmSelectPlant")
Game_FarmSelectPlant.__index = Game_FarmSelectPlant

local ITEM_TYPE ={
	Exp = 1,
}

-- function Game_FarmSelectPlant:checkData()

-- end
function Game_FarmSelectPlant:initWnd(layerMarket)	
	--注册消息
	--种植响应
	local order = msgid_pb.MSGID_FARM_PLANT_RESPONSE
	g_MsgMgr:registerCallBackFunc(order,handler(self,self.requestFarmPlantResponse))
	local order = msgid_pb.MSGID_FARM_AUTO_PLANT_RESPONSE
	g_MsgMgr:registerCallBackFunc(order,handler(self,self.requestFarmAutoPlantResponse))
end

function Game_FarmSelectPlant:openWnd(param)
	if not param then return end 
	self.farmIndex = param.framIdx or 1
	--是否为批量种
	self.plantType = param.plantType
	
	self:initView()
end

function Game_FarmSelectPlant:closeWnd() 

end
--药园种植请求
function Game_FarmSelectPlant:requestFarmPlant(idx,plantType)
	cclog("---------requestFarmPlant-------------")
	cclog("---------药园种植请求-------------")
	local msg = zone_pb.FarmPlantRequest() 
	msg.idx = idx
	msg.plant_type = plantType
	g_MsgMgr:sendMsg(msgid_pb.MSGID_FARM_PLANT_REQUEST, msg)
end

--药园种植响应
function Game_FarmSelectPlant:requestFarmPlantResponse(tbMsg)
	cclog("---------requestFarmPlantResponse-------------")
	cclog("---------药园种植响应-------------")
	local msgDetail = zone_pb.FarmPlantResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))
	
	local idx = msgDetail.idx
	local plant_type = msgDetail.field_info.plant_type
	
	if plant_type == ITEM_TYPE.Exp then 
		g_FarmData:setExpTimes(1)
	end
	
	g_FarmData:setFarmDataStatus(idx,2,nil,plant_type,nil)
	g_WndMgr:closeWnd("Game_FarmSelectPlant")
end

--药园批量种植请求
function Game_FarmSelectPlant:requestFarmAutoPlant(plantType)
	cclog("---------药园批量种植请求-------------")
	local msg = zone_pb.FarmAutoPlantRequest() 
	msg.plant_type = plantType
	g_MsgMgr:sendMsg(msgid_pb.MSGID_FARM_AUTO_PLANT_REQUEST, msg)
end

--药园批量种植响应
function Game_FarmSelectPlant:requestFarmAutoPlantResponse(tbMsg)
	cclog("---------requestFarmAutoPlantResponse-------------")
	cclog("---------药园批量种植响应-------------")
	local msgDetail = zone_pb.FarmAutoPlantResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))
	
	-- nIndex,status,deadline,plant_type,reward_lv
	local msg = msgDetail.auto_plant_info
	for i = 1,#msg do
		local idx = msg[i].field_idx
		local status = msg[i].field_info.status
		local deadline = msg[i].field_info.deadline
		local plant_type = msg[i].field_info.plant_type
		local reward_lv = msg[i].field_info.reward_lv
		g_FarmData:setFarmDataStatus(idx,status,deadline,plant_type,reward_lv)
		if plant_type == ITEM_TYPE.Exp then 
			g_FarmData:setExpTimes(1)
		end
	end
	g_WndMgr:closeWnd("Game_FarmSelectPlant")
end

local imagePos = {-160,0,160}
function Game_FarmSelectPlant:initView()
	local rootWidget = self.rootWidget
	local selectPlant = 0
	local Image_FarmSelectPlantPNL = tolua.cast(rootWidget:getChildByName("Image_FarmSelectPlantPNL"),"ImageView")
	
	local Image_ContentPNL = tolua.cast(Image_FarmSelectPlantPNL:getChildByName("Image_ContentPNL"),"ImageView")
	local Image_Background = tolua.cast(Image_ContentPNL:getChildByName("Image_Background"),"ImageView")
	
	local Label_RemainTimesLB =  tolua.cast(Image_ContentPNL:getChildByName("Label_RemainTimesLB"), "Label")
	
	local Button_Confirm = tolua.cast(Image_FarmSelectPlantPNL:getChildByName("Button_Confirm"),"Button")
	
	local expTimes = g_FarmData:getExpTimes()
	local expMaxNum = g_VIPBase:getVipValue("FarmPlantExpMaxNum")
	
	local cbgrp = CheckBoxGroup:New()
	--客户端暂时隐藏掉灵力的奖励kakiwang
	for i = 1, 4 do 
		local Image_PlantType = tolua.cast(Image_Background:getChildByName("Image_PlantType"..i),"ImageView")	
		local CheckBox_PlantType = tolua.cast(Image_PlantType:getChildByName("CheckBox_PlantType"),"CheckBox")	
		local Label_FuncName = tolua.cast(CheckBox_PlantType:getChildByName("Label_FuncName"),"Label")	
		
		if g_LggV.LanguageVer == eLanguageVer.LANGUAGE_viet_VIET  then --越南版
			Label_FuncName:setFontSize(18)
		end
		
		local Image_RewardBack = tolua.cast(Image_Background:getChildByName("Image_RewardBack"..i),"ImageView")	
		if i ~= 4 then 
			Image_PlantType:setPositionX(imagePos[i])
			Image_RewardBack:setPositionX(imagePos[i])
			cbgrp:PushBack(CheckBox_PlantType, function()
				selectPlant = i
				if selectPlant == ITEM_TYPE.Exp then 
					Label_RemainTimesLB:setVisible(true)
				else
					Label_RemainTimesLB:setVisible(false)
				end
				
				local enabled = true
				if selectPlant == ITEM_TYPE.Exp and expTimes >= expMaxNum then
					enabled = false
				end
				Button_Confirm:setBright(enabled)
				Button_Confirm:setTouchEnabled(enabled)
				
			end)
		else
			Image_RewardBack:setVisible(false)
			Image_PlantType:setVisible(false)
		
		end
		if selectPlant == 0 then cbgrp:Check(1) end 
	end
	

	
	local Label_RemainTimes =  tolua.cast(Label_RemainTimesLB:getChildByName("Label_RemainTimes"), "Label")
	Label_RemainTimes:setText(expTimes)
	local Label_RemainTimesMax =  tolua.cast(Label_RemainTimesLB:getChildByName("Label_RemainTimesMax"), "Label")
	Label_RemainTimesMax:setText("/"..expMaxNum)
	
	-- if g_LggV.LanguageVer == eLanguageVer.LANGUAGE_viet_VIET  then --越南版
	Label_RemainTimesLB:setPositionX(-(Label_RemainTimesLB:getSize().width+Label_RemainTimes:getSize().width+Label_RemainTimesMax:getSize().width)/2)
	Label_RemainTimes:setPositionX( Label_RemainTimesLB:getSize().width + 2 )
	Label_RemainTimesMax:setPositionX(  Label_RemainTimesLB:getSize().width / 2 + Label_RemainTimes:getSize().width + Label_RemainTimes:getPositionX() /2 )
	-- else
		-- 中文
		-- g_AdjustWidgetsPosition({Label_RemainTimes,Label_RemainTimesMax})
	-- end
	-- g_AdjustWidgetsPosition({Label_RemainTimes,Label_RemainTimesMax})
	
	if expTimes >= expMaxNum  then 
		Label_RemainTimes:setColor(ccc3(255, 0, 0))
	else
		Label_RemainTimes:setColor(ccc3(35, 220, 55))
	end
	if selectPlant == ITEM_TYPE.Exp then 
		Label_RemainTimesLB:setVisible(true)
	else
		Label_RemainTimesLB:setVisible(false)
	end


	
	local function onTouch(pSender, eventType)
		if eventType == ccs.TouchEventType.ended then
			if selectPlant == 0 then selectPlant = 1 end
			
			if selectPlant == ITEM_TYPE.Exp and expTimes >= expMaxNum then
				g_ClientMsgTips:showMsgConfirm(_T("经验树今天的种植次数已经使用完了！"))
				return 
			end
				
			if not self.plantType then 
				--种植
				if not self.farmIndex then return end 
				self:requestFarmPlant(self.farmIndex,selectPlant)
			else
				local count = 0
				local farmData = g_FarmData:getFarmRefresh()
				local data = farmData.fields 
				for k = 1,#data do 
					if data[k].status - common_pb.FFS_OPENED == 0 then 
						count = count + 1
					end 
				end
			
				if count <= 0 then return  end
				--批量种植
				self:requestFarmAutoPlant(selectPlant)
			
			end
		end
	end
	local enabled = true
	if selectPlant == ITEM_TYPE.Exp and expTimes >= expMaxNum then
		enabled = false
	end
	Button_Confirm:setBright(enabled)
	Button_Confirm:setTouchEnabled(enabled)
	Button_Confirm:addTouchEventListener(onTouch)	
end

function Game_FarmSelectPlant:showWndOpenAnimation(funcWndOpenAniCall)
	
	local Image_FarmSelectPlantPNL = tolua.cast(self.rootWidget:getChildByName("Image_FarmSelectPlantPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(Image_FarmSelectPlantPNL, funcWndOpenAniCall, 1.05, 0.2, Image_Background)
end

function Game_FarmSelectPlant:showWndCloseAnimation(funcWndCloseAniCall)
	local Image_FarmSelectPlantPNL = tolua.cast(self.rootWidget:getChildByName("Image_FarmSelectPlantPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIDisappearAnimation_Scale(Image_FarmSelectPlantPNL, funcWndCloseAniCall, 1.05, 0.2, Image_Background)
end