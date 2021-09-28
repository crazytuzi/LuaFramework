--------------------------------------------------------------------------------------
-- 文件名:	XXX.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	张齐
-- 日  期:	2016-3-23
-- 版  本:	2.0.19
-- 描  述:  节日活动天降元宝
-- 应  用:  
---------------------------------------------------------------------------------------

Act_TianJiangYBJR = class("Act_TianJiangYBJR",Act_Template2)
Act_TianJiangYBJR.__index = Act_Template2


--override
function Act_TianJiangYBJR:gainRewardResponseCB()
	--留空
end

function Act_TianJiangYBJR:setResult(info)
	for i =1, 6 do
		if self.tbItemList[self.nRound][i].RewardValue == info.drop_item_num then
			self.nResult = i
			break
		end
	end
	--旋转动画
	local count = 0
	math.randomseed(os.time())
	local nTurn = math.random(2,3)
	local nResult = nTurn*12 + (self.nResult-1)*2
	local function turnAction()
		count = count + 1
		local param = 8 + count - nResult
		local nTime = param < 0 and 0.03 or 0.03 + param*param*0.001
		local rotateBy = CCRotateBy:create(nTime, 30)
		local arrAct = CCArray:create()
		arrAct:addObject(rotateBy)
		arrAct:addObject(CCCallFuncN:create(function ()
				if count%2 ~= 0 then
					self.tbButton[self.nCurIndex]:setBright(true)
					self.nCurIndex = (self.nCurIndex + 1) % 6
					if self.nCurIndex == 0 then
						self.nCurIndex = 6
					end
					self.tbButton[self.nCurIndex]:setBright(false)
				end
				if count == nResult then
					local function updateHeroResourceInfo()
						--下一轮奖励
						self.nRound = self.nRound + 1
						self:refreshTurntable()
					end
					g_Hero.tbMasterBase.nYuanBao = g_Hero.tbMasterBase.nYuanBao - info.drop_item_num --防止元宝频繁更新
					g_Hero:addYuanBao(info.drop_item_num)
					g_ShowRewardMsgConfrim(info.drop_item_type, info.drop_item_num, updateHeroResourceInfo)
					return
				end
				turnAction()
			end))
		local action = CCSequence:create(arrAct)
		self.Image_PointArrow:runAction(action)
	end
	turnAction()
end

function Act_TianJiangYBJR:onClickStart(widget, eventType)
	if ccs.TouchEventType.ended == eventType and self.touchEnable then
		local nVPIID = g_Hero:getVIPLevelID()
		if nVPIID < self.tbItemList[self.nRound]["NeedVIPLevel"] then
			g_ShowSysTips({text=_T("当前祈福需要VIP等级达到VIP")..self.tbItemList[self.nRound]["NeedVIPLevel"]})
			return
		end
		
		local cost = self.tbItemList[self.nRound]["NeedValue"]
		if not g_CheckYuanBaoConfirm(cost, _T("天降元宝需要消耗")..cost.._T("元宝, 您的元宝不足是否前往充值")) then
			return
		end
		self.nCurYuanBao = cost
		
		--不用确认框了
		self.super.onClickGainReward(self, widget, self.nRound)
		g_Hero:delYuanBao(cost)
        self.touchEnable = false
		self.panel:setTouchEnabled(false)
		self.Button_Start:setBright(false)
		self.Button_Start:setTouchEnabled(false)
	end
end

function Act_TianJiangYBJR:onClickPanel(widget, eventType)
	if ccs.TouchEventType.began == eventType then
		self.Button_Start:setBrightStyle(BRIGHT_HIGHLIGHT)
	elseif ccs.TouchEventType.ended == eventType or ccs.TouchEventType.canceled == eventType then
		self.Button_Start:setBrightStyle(BRIGHT_NORMAL)
	end
end

--重置
function Act_TianJiangYBJR:refreshTurntable()
    self.touchEnable = true
	self.panel:setTouchEnabled(true)
	self.Button_Start:setBright(true)
	self.Button_Start:setTouchEnabled(true)
	if self.nRound > 6 then
		self.Label_NeedYuanBaoLB:setText(_T("已完成所有奖励"))
		self.Label_NeedYuanBao:setText("")
		self.panel:setTouchEnabled(false)
		self.Button_Start:setBright(false)
		self.Button_Start:setTouchEnabled(false)
		
		local nWidth1 = self.Label_NeedYuanBaoLB:getSize().width
		local nWidth2 = self.Label_NeedYuanBao:getSize().width
		self.Label_NeedYuanBaoLB:setPositionX(-(nWidth1+nWidth2)/2)
		self.Label_NeedYuanBao:setPositionX(nWidth1)
		return
	end
	self.nCurIndex = 1
	self.Image_PointArrow:setRotation(0)
	self.Label_NeedYuanBao:setText(tonumber(self.tbItemList[self.nRound].NeedValue))
	if g_Hero:getYuanBao() < tonumber(self.tbItemList[self.nRound].NeedValue) then
		self.Label_NeedYuanBao:setColor(ccc3(255,0,0))
	else
		self.Label_NeedYuanBao:setColor(ccc3(0,255,0))
	end
	for i = 1,6 do
		self.tbButton[i]:setBright(true)
		self.tbLable[i]:setText(self.tbItemList[self.nRound][i].RewardValue)
	end
	self.tbButton[1]:setBright(false)
	
	local nWidth1 = self.Label_NeedYuanBaoLB:getSize().width
	local nWidth2 = self.Label_NeedYuanBao:getSize().width
	self.Label_NeedYuanBaoLB:setPositionX(-(nWidth1+nWidth2)/2)
	self.Label_NeedYuanBao:setPositionX(nWidth1)
end

function Act_TianJiangYBJR:init(panel, tbItemList)
	if not panel then
		return 
	end
	self.panel = panel
	panel:addTouchEventListener(handler(self, self.onClickPanel))
	self.Image_LotteryNum = panel:getChildByName("Image_LotteryNum")
	self.Label_NeedYuanBaoLB = tolua.cast(self.Image_LotteryNum:getChildByName("Label_NeedYuanBaoLB"), "Label")
	self.Label_NeedYuanBao = tolua.cast(self.Label_NeedYuanBaoLB:getChildByName("Label_NeedYuanBao"), "Label")


	self.Image_PointArrow = panel:getChildByName("Image_PointArrow")
	self.Button_Start = tolua.cast(panel:getChildByName("Button_Start"), "Button")
	self.Button_Start:addTouchEventListener(handler(self, self.onClickStart))


	self.tbItemList = tbItemList
    self.touchEnable = true
	
	self.tbButton = {}
	self.tbLable = {}
	for i = 1,6 do
		self.tbButton[i] = tolua.cast(panel:getChildByName("Button_Item"..i), "Button")
		self.tbButton[i]:setTouchEnabled(false)
		self.tbLable[i] = tolua.cast(self.tbButton[i]:getChildByName("BitmapLabel_Value"), "LabelBMFont")
	end

	self.nRound = 7
	for k,v in ipairs(self.tbMissions) do
		if ActState.FINISHED == v then
			self.nRound = k
			break
		end
	end
	self:refreshTurntable()
end
