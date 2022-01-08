--	MenuLayer
-- Stephen.tao
-- Date: 2014-03-04 16:07:01
--

local MenuLayer = class("MenuLayer", BaseLayer)

function MenuLayer:ctor(data)
	self.armatureList = {}
	self.posEffList = {}
	self.playerBackBtn = nil
    self.super.ctor(self,data)

    self.checkRedPoint = {}
    self.totalPower = 0

    self:init("lua.uiconfig_mango_new.main.MenuLayer")
    self:AddBgImgEffect()
end

function MenuLayer:initUI(ui)
	self.super.initUI(self,ui)
	self.ui = ui

	local chatNode = TFDirector:getChildByPath(self, 'bg_chat')
	self.bubbleNode = TFDirector:getChildByPath(self, 'bg_chat')
	self.bubblePanel = TFDirector:getChildByPath(self, 'panel_chatclip')
	self.txtBubble = TFDirector:getChildByPath(chatNode, 'txt_chat')
	self.txtBubbleTitle = TFDirector:getChildByPath(chatNode, 'txt_chattitle')

	self.bg 		= TFDirector:getChildByPath(self, 'panel_eff')
	self.rolePanel 	= TFDirector:getChildByPath(self, 'rolePanel')
	self.txt_level 	= TFDirector:getChildByPath(self, 'txt_level')
	self.txt_vip 	= TFDirector:getChildByPath(self, 'txt_vip')
	
	--added by wuqi
	self.img_vip = TFDirector:getChildByPath(self, "img_vip")

	self.btn_head   = TFDirector:getChildByPath(self, 'btn_touxiang')
	self.btn_head.logic = self
	self.headImg	= TFDirector:getChildByPath(self, 'headImg')

	self.btn_chat 	= TFDirector:getChildByPath(self, 'btn_chat')
	self.setingBtn 	= TFDirector:getChildByPath(self, 'setingBtn')

	-- local Particle_SHENGDANxuehua = TFDirector:getChildByPath(ui, "Particle_SHENGDANxuehua")
	-- Particle_SHENGDANxuehua:setVisible(false)

    self.btn_buytime            = TFDirector:getChildByPath(ui, 'btn_add_1')
    self.btn_buycion            = TFDirector:getChildByPath(ui, 'btn_add_2')
    self.btn_buysycee           = TFDirector:getChildByPath(ui, 'btn_add_3')

    self.txt_tilipoint          = TFDirector:getChildByPath(ui, 'txt_number_1')
    self.txt_tongbipoint        = TFDirector:getChildByPath(ui, 'txt_number_2')
    self.txt_yuanbaopoint       = TFDirector:getChildByPath(ui, 'txt_number_3')
    self.txt_power       		= TFDirector:getChildByPath(ui, 'txt_zhanlizhi')
    self.txt_systemtime       		= TFDirector:getChildByPath(ui, 'txt_time')

	self.roleBtn    = TFDirector:getChildByPath(self, 'roleBtn')
	self.equipBtn 	= TFDirector:getChildByPath(self, 'equipBtn')
	self.bagBtn 	= TFDirector:getChildByPath(self, 'bagBtn')
	self.mallBtn 	= TFDirector:getChildByPath(self, 'mallBtn')
	self.zhaomuBtn 	= TFDirector:getChildByPath(self, 'zhaomuBtn')
	self.taskBtn 	= TFDirector:getChildByPath(self, 'taskBtn')
	self.infoBtn	= TFDirector:getChildByPath(self, 'infoBtn')

	self.pvpBtn 	= TFDirector:getChildByPath(self, 'pvpBtn')
	self.pvpBtnPos = self.pvpBtn:getPosition()
	self.pveBtn 	= TFDirector:getChildByPath(self, 'pveBtn')
	self.qiyuBtn	= TFDirector:getChildByPath(self, 'qiyuBtn')
	self.btn_youli  = TFDirector:getChildByPath(self, 'btn_youli')
	self.btnYouliPos=self.btn_youli:getPosition()

	self.btn_pay	= TFDirector:getChildByPath(self, 'btn_pay')
	self.btn_firstpay    = TFDirector:getChildByPath(self, 'btn_firstpay')
	self.btn_weixin    = TFDirector:getChildByPath(self, 'WeixinBtn')
	self.btn_sign	= TFDirector:getChildByPath(self, 'btn_qiandao')
	self.btn_yueka	= TFDirector:getChildByPath(self, 'btn_yueka')
	self.btn_vip	= TFDirector:getChildByPath(self, 'btn_vip')
	self.btn_wulin	= TFDirector:getChildByPath(self, 'btn_wulin')
	self.btn_zhengbasai	= TFDirector:getChildByPath(self, 'btn_zhengbasai')
	self.btn_kfFight	= TFDirector:getChildByPath(self, 'btn_kfFight')
	self.btn_kfFightXY  = self.btn_kfFight:getPosition()
	self.btn_gonglue	= TFDirector:getChildByPath(self, 'btn_gonglue')
	self.btn_youfang	= TFDirector:getChildByPath(self, 'btn_youfang')

	self.btn_tujian = TFDirector:getChildByPath(self, 'btn_tujian')

	self.taskPanel = TFDirector:getChildByPath(self, 'taskPanel')
	self.dailyTaskBtn = TFDirector:getChildByPath(self, 'openBtn')

	self.btn_employ = TFDirector:getChildByPath(self, 'btn_employ')

	self.btn_paihang = TFDirector:getChildByPath(self, 'btn_paihang')
	self.btn_huodong = TFDirector:getChildByPath(self, 'btn_huodong')
	self.btn_zaixian = TFDirector:getChildByPath(self, 'btn_zaixian')
	self.txt_time 	 = TFDirector:getChildByPath(self, 'txt_onlinetime')
	self.btn_friends 	 = TFDirector:getChildByPath(self, 'btn_friends')
	self.btn_faction	= TFDirector:getChildByPath(self, 'btn_faction')
	self.btn_change	= TFDirector:getChildByPath(self, 'btn_change')
	self.panel_rightDown	= TFDirector:getChildByPath(self, 'panel_rightDown')

	self.btn_goldEgg	= TFDirector:getChildByPath(self, 'btn_goldEgg')
	self.btn_xunbao	= TFDirector:getChildByPath(self, 'btn_xunbao')

	self.btn_sevenday = TFDirector:getChildByPath(self, 'sevenday')

	-- self.img_chaungguanling = TFDirector:getChildByPath(self, 'img_res_bg_1')
	-- self.img_tongbi 	 	= TFDirector:getChildByPath(self, 'img_res_bg_2')
	-- self.img_yuanbao 	 	= TFDirector:getChildByPath(self, 'img_res_bg_3')

	-- self:AddResEffect(self.img_chaungguanling, "main_res_effect", 86, 27, 2)
	-- self:AddResEffect(self.img_tongbi, "main_res_effect", 80, 27, 1)
	-- self:AddResEffect(self.img_yuanbao, "main_res_effect", 83, 26, 0)

	-- self:AddResEffect(self.pveBtn, "pveBtn_effect", 0, 0, 0)


	self.btn_chat:setClickAreaLength(100);
	self.setingBtn:setClickAreaLength(100);
	self.infoBtn:setClickAreaLength(100);
	self.btn_buytime:setClickAreaLength(100);
	self.btn_buycion:setClickAreaLength(100);
	self.btn_buysycee:setClickAreaLength(100);

	self:AddButtonEffect(self.txt_vip, "main_vip", 50, 0)
	self:AddButtonEffect(self.btn_pay, "main_pay", 0, 0)
	-- modify by zr 暂时关闭首充
	self:AddButtonEffect(self.btn_firstpay, "main_firstpay", 2, -8)
	-- self:AddButtonEffect(self.qiyuBtn, "main_huodong", 0, -5)
	-- self:AddButtonEffect(self.btn_huodong, "main_huodong", 0, -5)
	self:AddButtonEffect(self.btn_sevenday, "main_huodong", 0, 0)
	-- self:AddButtonEffect(self.btn_zhengbasai, "main_huodong", -5, -5)
	self:AddButtonEffect(self.btn_kfFight, "main_huodong", -5, -5)

	self.btn_list = {}
	self.btn_list[1] = self.btn_pay
	self.btn_list[2] = self.btn_yueka
	self.btn_list[3] = self.btn_firstpay
	self.btn_list[4] = self.btn_weixin
	self.btn_list[5] = self.btn_vip
	self.btn_list[6] = self.btn_goldEgg
	self.btn_list[7] = self.btn_xunbao
	self.btn_list[8] = self.btn_youfang
	self.btn_list[9] = self.btn_gonglue

	-- self.btn_list[1]:setVisible(false)
	self.btn_list[9]:setVisible(false)
	-- local resetPosY = self.btn_list[1]:getPositionY()
	-- for i=1,#self.btn_list do
	-- 	self.btn_list[i]:setPositionY(resetPosY)
	-- end

	print("WeiXin : ",MainPlayer:getServerSwitchStatue(ServerSwitchType.WeiXin))
	self.btn_list[4]:setVisible(MainPlayer:getServerSwitchStatue(ServerSwitchType.WeiXin))
	self.btn_list[9]:setVisible(MainPlayer:getServerSwitchStatue(ServerSwitchType.GongLv))

	local bShowEgg = OperationActivitiesManager:ActivityTypeIsOpen(OperationActivitiesManager.Type_Hit_Egg)
	self.btn_list[6]:setVisible(bShowEgg)
	local bShowXunBao = OperationActivitiesManager:ActivityTypeIsOpen(OperationActivitiesManager.Type_Active_XunBao)
	self.btn_list[7]:setVisible(bShowXunBao)

	-- self.btn_list[4]:setVisible(false)
	self.btn_list_pos = (self.btn_list[1]:getPositionX() -  self.btn_list[1]:getContentSize().width/2)


	self.leftDownBtnList = {
		self.roleBtn,
		self.equipBtn,
		self.bagBtn,
		self.mallBtn,
		self.zhaomuBtn,
		self.taskBtn,
		self.btn_friends,
		self.btn_faction,
		self.btn_paihang,
		self.btn_employ,
	}
	self.leftDownPage = 1
	for i=1,#self.leftDownBtnList do
		self.leftDownBtnList[i]:setAnchorPoint(ccp(0.5,0.5))
		self.leftDownBtnList[i]:setPositionY(self.leftDownBtnList[i]:getPositionY()+self.leftDownBtnList[i]:getContentSize().height/2 )
		self.leftDownBtnList[i].isOpen = true
	end
	self.leftDownBtnList_pos = 40

	self.rightMiddleBtnList = {}
	-- self.rightMiddleBtnList[1] = self.dailyTaskBtn
	self.rightMiddleBtnList[1] = self.qiyuBtn
	self.rightMiddleBtnList[2] = self.btn_huodong
	self.rightMiddleBtnList[3] = self.btn_wulin

	self.rightMiddleBtnList_pos = self.rightMiddleBtnList[1]:getPositionY() + self.rightMiddleBtnList[1]:getContentSize().height/2


	--公告框
	local function update(delta)
		if self.timeId then
			TFDirector:removeTimer(self.timeId)
			self.timeId = nil
		end
		-- JIN TODO 暂时关闭
		-- if PlayerGuideManager:IsGuidePanelVisible() == false then
		-- 	CommonManager:openSecondDayDrawing()
		-- 	CommonManager:openFirstDrawing()
		-- 	CommonManager:openWeixinDrawing()
		-- 	CommonManager:openEverydayNotice()
		-- end
		-- -- if QiyuManager:IsSignToday() and QiyuManager:SignIsOpen() then
		-- -- 	QiyuManager:OpenSignLayer()
		-- -- end

		-- CommonManager:openNoticeLayer()
	end
	-- self.timeId = me.Scheduler:scheduleScriptFunc(update, 0.5, false)
	self.timeId = TFDirector:addTimer(500, -1, nil, update)

	-- update(0)

	self.timeCount = 0
	self.onlineRewardCount = 0
	self.btn_zaixian:setVisible(false)

	-- local function loginOutCallBack()
	-- 	TFSdk:setLoginOutCallBack(nil)

	-- 	SettingManager:gotoLoginLayer()
	-- end

	-- -- 离开游戏 注销 
	-- if not TFSdk:getSdkName() then
	-- 	self.btn_friends:setVisible(false)
	-- else
	-- 	TFSdk:setLoginOutCallBack(loginOutCallBack)
	-- 	TFSdk:setLeavePlatCallBack(nil)
	-- end

	-- self.btn_friends:setVisible(false)
	-- if TFSdk:getSdkName() == "pp" then
	-- 	self.btn_friends:setVisible(true)
	-- end

	-- if TFPlugins.getChannelId() ~= "" and TFPlugins.isLogined() == true then
	if TFPlugins.isPluginExist() and TFPlugins.isLogined() == true then
		TFPlugins.showToolBar(ToolBarPlace.kToolBarBottomLeft)
	end

	if HeitaoSdk then
		HeitaoSdk.ShowFunctionMenu(true)
	end

	--添加玩家回归活动按钮
	self.playerBackBtn = self.btn_sevenday:clone()
	self.btn_sevenday:getParent():addChild(self.playerBackBtn)
	self.playerBackBtn:setPosition(self.btn_sevenday:getPosition())
	self.playerBackBtn:setTextureNormal("ui_new/home/icon_huigui.png")


	self:refreshUIPayBtn()
	-- self:refreshZhengbaBtn()
	self:showChatBubble()
end


function MenuLayer:refreshBtnList()
	local num = 0
	local pos_x = self.btn_list_pos
	for i=1,#self.btn_list do
		if self.btn_list[i]:isVisible() then
			pos_x = pos_x + self.btn_list[i]:getContentSize().width/2
			self.btn_list[i]:setPositionX(pos_x)-- , pos_y + self.btn_list[i]:getContentSize().height/2) )
			pos_x = pos_x + self.btn_list[i]:getContentSize().width/2
			if num >= 6 then
				self.btn_list[i]:setPositionY(self.btn_list[1]:getPositionY()-80)
			else
				self.btn_list[i]:setPositionY(self.btn_list[1]:getPositionY())
			end
			num = num + 1
			if num == 6 then
				pos_x = self.btn_list_pos
			end
		end
	end
end

--added by wuqi
function MenuLayer:addVipEffect(btn)
    if btn.effect then
        btn.effect:removeFromParent()
        btn.effect = nil
    end
    local vipLevel = MainPlayer:getVipLevel()
    if vipLevel <= 18 then  --if vipLevel <= 15 or vipLevel > 18 then -- modify by zr 关掉高VIP特效
        return
    end
    local resPath = "effect/ui/vip_" .. vipLevel .. ".xml"
    TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
    local effect = TFArmature:create("vip_" .. vipLevel .. "_anim")
    effect:setAnimationFps(GameConfig.ANIM_FPS)
    effect:setPosition(ccp(btn:getContentSize().width / 2, btn:getContentSize().height / 2))
    effect:setVisible(true)
    effect:setScale(0.8)
    effect:playByIndex(0, -1, -1, 1)
    btn:addChild(effect, 200)
    btn.effect = effect
end

function MenuLayer:refreshLeftDownBtnList()
	local num = 0
	local pos_x = self.leftDownBtnList_pos
	for i=1,#self.leftDownBtnList do
		if self.leftDownBtnList[i].isOpen == true then
			num = num + 1
			if num > (self.leftDownPage - 1)*5 and num <= self.leftDownPage*5 then
				pos_x = pos_x + self.leftDownBtnList[i]:getContentSize().width/2
				self.leftDownBtnList[i]:setPositionX( pos_x )
				pos_x = pos_x + self.leftDownBtnList[i]:getContentSize().width/2
				self.leftDownBtnList[i]:setVisible(true)
			else
				self.leftDownBtnList[i]:setVisible(false)
			end
		else
			self.leftDownBtnList[i]:setVisible(false)
		end
	end
	local panel = TFDirector:getChildByPath(self.ui, 'Panel_MenuLayer_1')
	if num > 5 then
		self.btn_change:setVisible(true)
		panel:setPositionX(73)
	else
		self.btn_change:setVisible(false)
		panel:setPositionX(-30)
	end
	self:updateChangeBtnRedPoint()
end
function MenuLayer:refreshRightMiddleBtnList()
	local num = 0
	local pos_y = self.rightMiddleBtnList_pos 
	for i=1,#self.rightMiddleBtnList do
		if self.rightMiddleBtnList[i]:isVisible() then
			pos_y = pos_y - self.rightMiddleBtnList[i]:getContentSize().height/2
			self.rightMiddleBtnList[i]:setPositionY( pos_y )
			pos_y = pos_y - self.rightMiddleBtnList[i]:getContentSize().height/2 - 10
			num = num + 1
		end
	end
end

function MenuLayer:refreshUIPayBtn()
	-- 首充暂时关闭，开启时删除setVisible语句，取消之后的注释
	self.btn_firstpay:setVisible(false)
	-- if PayManager:IsUserFirstPay() == true then
	-- 	self.btn_firstpay:setVisible(true)
 --    end

 --    if PayManager:getFirstChargeState() then
 -- 		self.btn_firstpay:setVisible(true)
 --    end

    if PayManager:IsFirstPayMore(198) or PayManager:getTotalRecharge() >= 1000 then
    	print("PayManager:getTotalRecharge() = ",PayManager:getTotalRecharge())
    	self.btn_vip:setVisible(true)
    end

    CommonManager:setRedPoint(self.btn_firstpay, PayManager:getFirstChargeState(),"getFirstChargeState",ccp(0,0))

    self:refreshBtnList()
end

function MenuLayer:onShow()
	self.super.onShow(self)
	if not self.isShow then
        return;
    end
	-- print('---------------------onShow---------------->>>>111')
	if CommonManager:checkLoginCompleteState() == false then
		CardRoleManager:reSortStrategy();
		CommonManager:setLoginCompleteState( true )
	end
	-- print('---------------------onShow---------------->>>>222')
	self.panel_rightDown:setPositionX(0)
    self:refreshBaseUI();
    self:refreshBtnVisible()
    self:refreshUI();
    self:refreshTaskInfo();
    self:refreshUIPayBtn();
    -- self:refreshZhengbaBtn()
    
    hideAllLoading();
end

function MenuLayer:refreshBaseUI(isOnlyResource)
	if isOnlyResource == nil then
		isOnlyResource = false
	end
	local times = MainPlayer:GetChallengeTimesInfo(EnumRecoverableResType.PUSH_MAP);
    self.txt_tilipoint:setText(times:getLeftChallengeTimes()  .. "/" .. times.maxValue);
    self.txt_tongbipoint:setText(MainPlayer:getResValueExpressionByType(EnumDropType.COIN))
    self.txt_yuanbaopoint:setText(MainPlayer:getResValueExpressionByType(EnumDropType.SYCEE))
    if isOnlyResource then
    	return
    end
	self:setInfo()
	self:InitRoleList()
end

function MenuLayer:checkRedPointByKey( key, currTime )
	if self.checkRedPoint[key] == nil then
		self.checkRedPoint[key] = {}
		return true
	end
	-- if self.checkRedPoint[key].flag then
	-- 	return true
	-- end
	if self.checkRedPoint[key].refreshTime > currTime then
		return true
	end
	return false
end

function MenuLayer:refreshUI()
    if not self.isShow then
        return;
    end
    print(" ------------- MenuLayer:refreshUI")
    local currTime = MainPlayer:getNowtime()
    self.btn_yueka:setVisible(QiyuManager:MonthCardIsOpen())

	self.qiyuBtn:setVisible(QiyuManager:QiyuFuctionIsOpen())

    self.btn_zaixian:setVisible(QiyuManager:ActivityFuctionOnlineReward())
    self.btn_huodong:setVisible(QiyuManager:ActivityFuctionIsOpen())

    -- if QiyuManager:ActivityFuctionOnlineReward() then
    -- 	self.btn_zaixian:setVisible(not OperationActivitiesManager:isGetAllOnlineReward())
    -- end

    -- if OperationActivitiesManager:ActivitgIsOpen(EnumActivitiesType.ONLINE_REWARD_NEW) then
    if OperationActivitiesManager:ActivityOnlineIsOpen() then
		self.btn_zaixian:setVisible(not OperationActivitiesManager:AllOnlineRewardIsReceived())

	else
		self.btn_zaixian:setVisible(false)
	end

	--CommonManager:setRedPoint(self.equipBtn, EquipmentManager:isHaveGemEnough(),"isHaveGemEnough",ccp(0,0),10001)
	--CommonManager:setRedPoint(self.equipBtn, EquipmentManager:isHaveNewRefinStone(),"isHaveNewRefinStone",ccp(0,0),1401)
	if self:checkRedPointByKey("isHaveCanZhaomu",currTime) then
		local redPointState = BagManager:isHaveCanZhaomu()
		self.checkRedPoint["isHaveCanZhaomu"].flag = redPointState
		self.checkRedPoint["isHaveCanZhaomu"].refreshTime = currTime + 5000
		CommonManager:setRedPoint(self.bagBtn, redPointState,"isHaveCanZhaomu",ccp(0,0))
	end
	if self:checkRedPointByKey("isHaveCanEquipPiece",currTime) then
		local redPointState = BagManager:isHaveCanEquipPiece()
		self.checkRedPoint["isHaveCanEquipPiece"].flag = redPointState
		self.checkRedPoint["isHaveCanEquipPiece"].refreshTime = currTime + 5000
		CommonManager:setRedPoint(self.bagBtn, redPointState,"isHaveCanZhaomu",ccp(0,0))
	end	
	-- CommonManager:setRedPoint(self.bagBtn, BagManager:isHaveCanProp(),"isHaveCanProp",ccp(0,0))
	if self:checkRedPointByKey("isHaveCanProp",currTime) then
		local redPointState = BagManager:isHaveCanProp()
		self.checkRedPoint["isHaveCanProp"].flag = redPointState
		self.checkRedPoint["isHaveCanProp"].refreshTime = currTime + 5000
		CommonManager:setRedPoint(self.bagBtn, redPointState,"isHaveCanProp",ccp(0,0))
	end

	-- CommonManager:setRedPoint(self.bagBtn, BagManager:isHaveCanGift(),"isHaveCanGift",ccp(0,0))
	if self:checkRedPointByKey("isHaveCanGift",currTime) then
		local redPointState = BagManager:isHaveCanGift()
		self.checkRedPoint["isHaveCanGift"].flag = redPointState
		self.checkRedPoint["isHaveCanGift"].refreshTime = currTime + 5000
		CommonManager:setRedPoint(self.bagBtn, redPointState,"isHaveCanGift",ccp(0,0))
	end
	-- CommonManager:setRedPoint(self.bagBtn, BagManager:isHaveCanFrame(),"isHaveCanFrame",ccp(0,0))
	if self:checkRedPointByKey("isHaveCanFrame",currTime) then
		local redPointState = BagManager:isHaveCanFrame()
		self.checkRedPoint["isHaveCanFrame"].flag = redPointState
		self.checkRedPoint["isHaveCanFrame"].refreshTime = currTime + 5000
		CommonManager:setRedPoint(self.bagBtn, redPointState,"isHaveCanFrame",ccp(0,0))
	end
	-- CommonManager:setRedPoint(self.taskBtn, TaskManager:isCanGetRewardForType(1),"isCanGetRewardForType",ccp(0,0))
	if self:checkRedPointByKey("isCanGetRewardForType1",currTime) then
		local redPointState = TaskManager:isCanGetRewardForType(1)
		self.checkRedPoint["isCanGetRewardForType1"].flag = redPointState
		self.checkRedPoint["isCanGetRewardForType1"].refreshTime = currTime + 5000
		CommonManager:setRedPoint(self.taskBtn, redPointState,"isCanGetRewardForType1",ccp(0,0))
	end

	-- 日常添加等级判断
	if FunctionOpenConfigure:isFuctionOpen(1001) then
		-- CommonManager:setRedPoint(self.dailyTaskBtn, TaskManager:isCanGetRewardForType(0),"isCanGetRewardForType",ccp(0,0))
		if self:checkRedPointByKey("isCanGetRewardForType0",currTime) then
			local redPointState = TaskManager:isCanGetRewardForType(0)
			self.checkRedPoint["isCanGetRewardForType0"].flag = redPointState
			self.checkRedPoint["isCanGetRewardForType0"].refreshTime = currTime + 5000
			CommonManager:setRedPoint(self.dailyTaskBtn, redPointState,"isCanGetRewardForType0",ccp(0,0))
		end		
	end

	CommonManager:setRedPoint(self.zhaomuBtn, GetCardManager:isHaveGetCardFree(),"isHaveGetCardFree",ccp(0,0))
	CommonManager:setRedPoint(self.zhaomuBtn, QiYuanManager:isHaveQiYuanFree(),"isHaveQiYuanFree",ccp(0,0))
	
	CommonManager:setRedPoint(self.mallBtn, MallManager:isHaveNewGif(),"isHaveNewGif",ccp(0,0))
	CommonManager:setRedPoint(self.mallBtn, MallManager:isHaveNewGoods(),"isHaveNewGoods",ccp(0,0))

	CommonManager:setRedPoint(self.infoBtn, NotifyManager:isHaveUnReadMail(),"isHaveUnReadMail",ccp(0,0))

	CommonManager:setRedPoint(self.btn_chat, ChatManager:isHaveNewChat(),"isHaveNewChat",ccp(0,0))

	-- CommonManager:setRedPoint(self.qiyuBtn, QiyuManager:isCodeCanGetReward(),"isCodeCanGetReward",ccp(0,0))

	CommonManager:setRedPoint(self.btn_sign, QiyuManager:IsSignToday(),"IsSignToday",ccp(-10,-10))
	--CommonManager:setRedPoint(self.btn_yueka, QiyuManager:IsMonthCardCanGet(),"IsMonthCardCanGet",ccp(-10,-10))
	CommonManager:setRedPoint(self.btn_yueka, MonthCardManager:IsMonthCardCanGet(),"IsMonthCardCanGet",ccp(-10,0))


	-- 布阵红点
	if self:checkRedPointByKey("isHaveBook",currTime) then
		local redPointState = CardRoleManager:isHaveBook()
		self.checkRedPoint["isHaveBook"].flag = redPointState
		self.checkRedPoint["isHaveBook"].refreshTime = currTime + 5000
		CommonManager:setRedPoint(self.roleBtn, redPointState,	"isHaveBook",	ccp(0,0))
	end

	-- CommonManager:setRedPoint(self.roleBtn, AssistFightManager:isCanRedPoint( LineUpType.LineUp_Main ),	"isAssistFightManager",	ccp(0,0))



	-- CommonManager:setRedPoint(self.qiyuBtn, QiyuManager:isHaveRedPoint(),"isCodeCanGetReward",ccp(0,0))
	if self:checkRedPointByKey("isCodeCanGetReward",currTime) then
		local redPointState = QiyuManager:isHaveRedPoint()
		self.checkRedPoint["isCodeCanGetReward"].flag = redPointState
		self.checkRedPoint["isCodeCanGetReward"].refreshTime = currTime + 5000
		CommonManager:setRedPoint(self.qiyuBtn, redPointState,"isCodeCanGetReward",ccp(0,0))
	end		
	

	-- CommonManager:setRedPoint(self.btn_huodong, OperationActivitiesManager:isHaveRewardCanGet(),"OperationActivitiesManager",ccp(0,0))
	if self:checkRedPointByKey("OperationActivitiesManager",currTime) then
		local redPointState = OperationActivitiesManager:isHaveRewardCanGet()
		self.checkRedPoint["OperationActivitiesManager"].flag = redPointState
		self.checkRedPoint["OperationActivitiesManager"].refreshTime = currTime + 5000
		CommonManager:setRedPoint(self.btn_huodong, redPointState,"OperationActivitiesManager",ccp(0,0))
	end		
	

	-- CommonManager:setRedPoint(self.btn_sevenday, SevenDaysManager:checkRedPoint(),"isCodeCanGetReward",ccp(0,0))
	if self:checkRedPointByKey("isCodeCanGetReward1",currTime) then
		local redPointState = SevenDaysManager:checkRedPoint()
		self.checkRedPoint["isCodeCanGetReward1"].flag = redPointState
		self.checkRedPoint["isCodeCanGetReward1"].refreshTime = currTime + 5000
		CommonManager:setRedPoint(self.btn_sevenday, redPointState,"isCodeCanGetReward1",ccp(0,0))
	end		

	-- CommonManager:setRedPoint(self.btn_weixin, MainPlayer:getWeixinStatus(),"isCodeCanGetReward",ccp(0,0))
	if self:checkRedPointByKey("btn_weixin",currTime) then
		local redPointState = MainPlayer:getWeixinStatus()
		self.checkRedPoint["btn_weixin"].flag = redPointState
		self.checkRedPoint["btn_weixin"].refreshTime = currTime + 5000
		CommonManager:setRedPoint(self.btn_weixin, redPointState,"btn_weixin",ccp(0,0))
	end		

	-- CommonManager:setRedPoint(self.btn_friends, FriendManager:isShowRedPoint(), "isShowRedPoint", ccp(0,0))
	if self:checkRedPointByKey("btn_friends",currTime) then
		local redPointState = FriendManager:isShowRedPoint()
		self.checkRedPoint["btn_friends"].flag = redPointState
		self.checkRedPoint["btn_friends"].refreshTime = currTime + 5000
		CommonManager:setRedPoint(self.btn_friends, redPointState,"btn_friends",ccp(0,0))
	end		

	-- CommonManager:setRedPoint(self.btn_faction, FactionManager:canViewRedPointInMainLayer(), "isFactionRedPoint", ccp(0,0))
	if self:checkRedPointByKey("btn_faction",currTime) then
		local redPointState = FactionManager:canViewRedPointInMainLayer()
		self.checkRedPoint["btn_faction"].flag = redPointState
		self.checkRedPoint["btn_faction"].refreshTime = currTime + 5000
		CommonManager:setRedPoint(self.btn_faction, redPointState,"btn_faction",ccp(0,0))
	end		

	-- CommonManager:setRedPoint(self.pvpBtn, MiningManager:redPoint(), "MiningManager", ccp(0,0))
	if self:checkRedPointByKey("pvpBtn",currTime) then
		local redPointState = MiningManager:redPoint()
		self.checkRedPoint["pvpBtn"].flag = redPointState
		self.checkRedPoint["pvpBtn"].refreshTime = currTime + 5000
		CommonManager:setRedPoint(self.pvpBtn, redPointState,"pvpBtn",ccp(0,0))
	end		
	
	-- CommonManager:setRedPoint(self.playerBackBtn, PlayBackManager:checkRedPoint(),"isCodeCanGetReward",ccp(0,0))
	if self:checkRedPointByKey("playerBackBtn",currTime) then
		local redPointState = PlayBackManager:checkRedPoint()
		self.checkRedPoint["playerBackBtn"].flag = redPointState
		self.checkRedPoint["playerBackBtn"].refreshTime = currTime + 5000
		CommonManager:setRedPoint(self.playerBackBtn, redPointState,"playerBackBtn",ccp(0,0))
	end		
	self:refreshUIPayBtn()
	self:refreshBtnVisible()

	self.btn_sevenday:setVisible(true)

	if SevenDaysManager:sevenDaysOpenSatus() == 0 then
		self.btn_sevenday:setVisible(false)
	end

	if PlayBackManager:playerBackOpenSatus() == false then
		self.playerBackBtn:setVisible(false)
	else
		self.playerBackBtn:setVisible(true)
	end
	--self.btn_sevenday:setVisible(false)
	--self.playerBackBtn:setVisible(true)

	self:refreshYueCardMonthBuff()

	CommonManager:setRedPoint(self.btn_goldEgg, GoldEggManager:isRedPoint(), "isGoldEggRedPoint", ccp(0,0))
	CommonManager:setRedPoint(self.btn_xunbao, TreasureManager:isRedPoint(), "isGoldEggRedPoint", ccp(0,0))

	-- 打开金蛋icon
	local bShowEgg = OperationActivitiesManager:ActivityTypeIsOpen(OperationActivitiesManager.Type_Hit_Egg)
	-- print("bShowEgg = ", bShowEgg)
	self.btn_list[6]:setVisible(bShowEgg)
	-- print(" ------------- MenuLayer:555555555555")

	local bShowXunBao = OperationActivitiesManager:ActivityTypeIsOpen(OperationActivitiesManager.Type_Active_XunBao)
	self.btn_list[7]:setVisible(bShowXunBao)

	self:refreshBtnList()
end

function MenuLayer.onBuyTimeClickHandle(sender)
	VipRuleManager:showReplyLayer(EnumRecoverableResType.PUSH_MAP)
	-- PayManager:showVipChangeLayer()
end

function MenuLayer.onBuyCionClickHandle(sender)
    local self = sender.logic;
    CommonManager:showNeedCoinComfirmLayer();
end

function MenuLayer.onBuySyceeClickHandle(sender)
    local self = sender.logic;
    PayManager:showPayLayer();
end
function MenuLayer.payBtnClickHandle(sender)
    PayManager:showPayHomeLayer();
end

function MenuLayer.firstPayBtnClickHandle(sender)
    PayManager:showFirstPayLayer();
end

function MenuLayer.weixinBtnClickHandle(sender)

	MainPlayer:WeixinBePressed()

    local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.home.WeixinLayer",AlertManager.BLOCK_AND_GRAY,tween);
    AlertManager:show();
end

function MenuLayer.guibingBtnClickHandle(sender)
	 local layer  = require("lua.logic.pay.VipQQLayer"):new()
    AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1)
    AlertManager:show() 
end

function MenuLayer.zhengbasaiBtnClickHandle(sender)
	if ZhengbaManager:getActivityStatus() ~= 1 and MainPlayer:getLevel() >= 35 then
		ZhengbaManager:openZhengbaMainLayer()
	else
		FactionFightManager:openCurrLayer()
	end
end

function MenuLayer.kfFightClickHandle(sender)
	local state = MultiServerFightManager:getActivityState()
	if state and (state >= 1 and state < 9) then
		MultiServerFightManager:openCurrLayer()
	end
end

function MenuLayer.wulinBtnClickHandle(sender)
	WulinManager:showLayer(WulinManager.TAP_ZhengBaSai)
end

function MenuLayer:refreshStamina()
	local times = MainPlayer:GetChallengeTimesInfo(EnumRecoverableResType.PUSH_MAP);
    self.txt_tilipoint:setText(times:getLeftChallengeTimes()  .. "/" .. times.maxValue);
end

function MenuLayer:registerEvents()
    self.super.registerEvents(self)

    AssistFightManager:refreshRoleQiheAttr()

    self.btn_buytime.logic = self;
    self.btn_buytime:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onBuyTimeClickHandle),1);
    self.btn_buycion.logic = self;
    self.btn_buycion:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onBuyCionClickHandle),1);
    self.btn_buysycee.logic = self;
    self.btn_buysycee:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onBuySyceeClickHandle),1);

    --

	self.btn_head:addMEListener(TFWIDGET_CLICK, audioClickfun(self.headClickHandle));
	self.btn_chat:addMEListener(TFWIDGET_CLICK, audioClickfun(self.chatClickHandle),1);
	self.btn_chat.logic = self

    self.setingBtn:addMEListener(TFWIDGET_CLICK, audioClickfun(self.shezhiClickHandle),1);
    self.infoBtn:addMEListener(TFWIDGET_CLICK, audioClickfun(self.infoBtnClickHandle),1);

    self.roleBtn:addMEListener(TFWIDGET_CLICK, audioClickfun(self.roleBtnClickHandle),1);
    self.roleBtn.logic = self
	self.equipBtn:addMEListener(TFWIDGET_CLICK, audioClickfun(self.equipBtnClickHandle),1);
    self.bagBtn:addMEListener(TFWIDGET_CLICK, audioClickfun(self.bagBtnClickHandle),1);
    self.bagBtn.logic = self
    self.btn_employ :addMEListener(TFWIDGET_CLICK, audioClickfun(self.employBtnClickHandle),1);
    self.mallBtn:addMEListener(TFWIDGET_CLICK, audioClickfun(self.mallBtnClickHandle),1);
    self.zhaomuBtn:addMEListener(TFWIDGET_CLICK, audioClickfun(self.zhaomuBtnClickHandle),1);
    self.taskBtn:addMEListener(TFWIDGET_CLICK, audioClickfun(self.taskBtnClickHandle),1);
    self.dailyTaskBtn:addMEListener(TFWIDGET_CLICK, audioClickfun(self.dailyTaskBtnClickHandle),1);

    self.btn_youli:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onBtnYouliClick),1);
    self.pvpBtn:addMEListener(TFWIDGET_CLICK, audioClickfun(self.pvpBtnClickHandle),1);
    self.pveBtn:addMEListener(TFWIDGET_CLICK, audioClickfun(self.pveBtnClickHandle),1);
    self.qiyuBtn:addMEListener(TFWIDGET_CLICK, audioClickfun(self.qiyuBtnClickHandle),1);
    self.btn_pay:addMEListener(TFWIDGET_CLICK, audioClickfun(self.payBtnClickHandle),1);
    self.btn_firstpay:addMEListener(TFWIDGET_CLICK, audioClickfun(self.firstPayBtnClickHandle),1);
    self.btn_weixin:addMEListener(TFWIDGET_CLICK, audioClickfun(self.weixinBtnClickHandle),1);
    self.btn_yueka:addMEListener(TFWIDGET_CLICK, audioClickfun(self.yuekaBtnClickHandle),1);
    self.btn_sign:addMEListener(TFWIDGET_CLICK, audioClickfun(self.signBtnClickHandle),1);
    self.btn_tujian:addMEListener(TFWIDGET_CLICK, audioClickfun(self.tujianBtnClickHandle),1);
    self.btn_gonglue:addMEListener(TFWIDGET_CLICK, audioClickfun(self.gonglueBtnClickHandle),1);
    self.btn_youfang:addMEListener(TFWIDGET_CLICK, audioClickfun(self.youfangMallBtnClickHandle),1);
    self.btn_vip:addMEListener(TFWIDGET_CLICK, audioClickfun(self.guibingBtnClickHandle),1);
    self.btn_zhengbasai:addMEListener(TFWIDGET_CLICK, audioClickfun(self.zhengbasaiBtnClickHandle),1);
    self.btn_kfFight:addMEListener(TFWIDGET_CLICK, audioClickfun(self.kfFightClickHandle),1);
    self.btn_wulin:addMEListener(TFWIDGET_CLICK, audioClickfun(self.wulinBtnClickHandle),1);
    self.btn_goldEgg:addMEListener(TFWIDGET_CLICK, audioClickfun(self.goldEggBtnClickHandle),1);
    self.btn_xunbao:addMEListener(TFWIDGET_CLICK, audioClickfun(self.xunBaoBtnClickHandle),1);

    self.btn_paihang:addMEListener(TFWIDGET_CLICK, audioClickfun(self.paihangBtnClickHandle),1);
	self.btn_huodong:addMEListener(TFWIDGET_CLICK, audioClickfun(self.huodongBtnClickHandle),1);
	self.btn_zaixian.logic = self
	self.btn_zaixian:addMEListener(TFWIDGET_CLICK, audioClickfun(self.OnlineBtnClickHandle),1);

	self.btn_sevenday.logic = self
	self.btn_sevenday:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onclickSevenDay),1);
	-- self.btn_sevenday:setVisible(false)
	-- pp
	self.btn_friends.logic = self
	self.btn_friends:addMEListener(TFWIDGET_CLICK, audioClickfun(self.friendBtnClickHandle),1);

	self.btn_faction.logic = self
	self.btn_faction:addMEListener(TFWIDGET_CLICK, audioClickfun(self.factionBtnClickHandle),1);
	self.btn_change.logic = self
	self.btn_change:addMEListener(TFWIDGET_CLICK, audioClickfun(self.changeBtnClickHandle),1);

	self.playerBackBtn:addMEListener(TFWIDGET_CLICK, audioClickfun(self.playBackBtnClickHandle),1);

		-- pp
	-- self.btn_huodong:addMEListener(TFWIDGET_CLICK, audioClickfun(self.PlatformBtnClickHandle),1);

	self.updateUserDataCallBack = function(event)
        self:refreshBaseUI(true)
    end

	TFDirector:addMEGlobalListener(MainPlayer.ResourceUpdateNotifyBatch ,self.updateUserDataCallBack)
	TFDirector:addMEGlobalListener(MainPlayer.ChallengeTimesChange ,self.updateUserDataCallBack)

	self.updateActivityStateCB = function(event)
        -- self:refreshZhengbaBtn()
    end
	TFDirector:addMEGlobalListener(MultiServerFightManager.updateActivityState ,self.updateActivityStateCB)

	self.upadteChampionsStatus = function(event)
        -- self:refreshZhengbaBtn()
    end
	TFDirector:addMEGlobalListener(ZhengbaManager.UPADTECHAMPIONSSTATUS ,self.upadteChampionsStatus)
	
	self.activityStateChangeCB = function(event)
        -- self:refreshZhengbaBtn()
    end
	TFDirector:addMEGlobalListener(FactionFightManager.activityStateChange ,self.activityStateChangeCB)

	self.levelVhangeCallBack = function(event)
        self:refreshBtnVisibleWithLevel()
        -- self:refreshZhengbaBtn()
    end
	TFDirector:addMEGlobalListener(MainPlayer.LevelChange ,self.levelVhangeCallBack)

	self.chatNewMarkChange = function(event)
        CommonManager:setRedPoint(self.btn_chat, ChatManager:isHaveNewChat(),"isHaveNewChat",ccp(0,0))
    end

	TFDirector:addMEGlobalListener(ChatManager.NewMarkChange  ,self.chatNewMarkChange)

	-- 在线倒计时奖励
	local function onlineReWard(event)
		-- self:getOnlineRewardUpdate(event.data[1])
	end
	TFDirector:addMEGlobalListener(OperationActivitiesManager.GET_ACITIVTY_REWARD_SUCCESS, 	onlineReWard)
	TFDirector:addMEGlobalListener(OperationActivitiesManager.ACITIVTY_REWARD_RECORD, 		onlineReWard)
	
	local function onlineRewardTimer(sender)
		-- print("desc = ", sender.desc)
		if self.txt_time == nil then
			return
		end
		
		self.txt_time:setText(sender.desc)
		self.btn_zaixian:setVisible(true)
		-- 开启在线奖励特效
		if sender.bPrize == true and sender.timeCount == 0 then
			self.txt_time:setVisible(false)
			self:playOnlineEffect()
		-- 结束
		else
			self.txt_time:setVisible(true)
			self:stopOnlineEffect()
		end
		-- v.timeCount	= self.timeCount
		-- v.bPrize	= self.bOnlineRewardOnTime  --当前的在线奖励是否可领
	end

	-- -- if QiyuManager:ActivityFuctionOnlineReward() then 
	-- 	OperationActivitiesManager:setOnlineRewardTimer(self, 1001, onlineRewardTimer)
	-- -- end

	OperationActivitiesManager:addOnlineRewardListener(self, 1001, onlineRewardTimer)

	self.onSdkPlatformLogout = function (event)
		-- self:timeOut(function()

  --       	TFLOGERROR("self.onSdkPlatformLogout")
		-- 	-- toastMessage("---------MenuLayer.onSdkPlatformLogout ")
		-- 	SettingManager:gotoLoginLayer()
		-- end, 1000)
		-- print('MenuLayer.onSdkPlatformLogout call')
			--刷新体力
		self.LoginOutFunction = function()
			TFLOGERROR("self.onSdkPlatformLogout")
			SettingManager:gotoLoginLayer()
		end

		if not self.nTimerLoginOut then

        	self.nTimerLoginOut = TFDirector:addTimer(1000, -1, nil, self.LoginOutFunction); 
    	end
	end

	self.onSdkPlatformLeave = function (event)
		-- toastMessage("---------MenuLayer.onSdkPlatformLeave ")
		print('MenuLayer.onSdkPlatformLeave call')
	end

	-- TFDirector:addMEGlobalListener("onSdkPlatformLogout", self.onSdkPlatformLogout)
	-- TFDirector:addMEGlobalListener("onSdkPlatformLeave", self.onSdkPlatformLeave)
	
	if HeitaoSdk then
		self.onSdkPlatformLogout = function()
			self:timeOut(function()
	        	print("self.onSdkPlatformLogout")
				SettingManager:gotoLoginLayer()
			end, 0)
		end
		-- HeitaoSdk.setLoginOutCallBack(self.onSdkPlatformLogout)
	end

	ADD_KEYBOARD_CLOSE_LISTENER(self, self.ui)

	--刷新体力
	self.onUpdated = function()
		
		self:refreshStamina()

		--超级牛逼的运营说要加个服务器时间
		local date = os.date("*t", MainPlayer:getNowtime())
		local timeStr =  string.format("%.2d:%.2d",date.hour,date.min) --..":"..date.sec
		self.txt_systemtime:setText(timeStr)
		

		if MallManager.travelBusiness and MallManager.travelBusiness.info and MallManager.travelBusiness.beginTime and MallManager.travelBusiness.endTime then
			local nowTime = MainPlayer:getNowtime()
			if nowTime >= MallManager.travelBusiness.beginTime and nowTime <= MallManager.travelBusiness.endTime then
				if self.btn_list[8]:isVisible() == false then
					self.btn_list[8]:setVisible(true)
					self:refreshBtnList()
				end
			else
				if self.btn_list[8]:isVisible() then
					self.btn_list[8]:setVisible(false)
					self:refreshBtnList()
				end
			end
		else
			if self.btn_list[8]:isVisible() then
				self.btn_list[8]:setVisible(false)
				self:refreshBtnList()
			end
		end
		-- -- local armature = TFDirector:getChildByPath(self.ui, "armature1")
		-- local skillopenLevel = FunctionOpenConfigure:getOpenLevel(201)
  --       if MainPlayer:getLevel() < skillopenLevel then
		-- 	CommonManager:setRedPoint(self.rolePanel, false,"isSkillFull",ccp(85,-55))
  --       else
		-- 	CommonManager:setRedPoint(self.rolePanel, MainPlayer:isChallengeTimesFull(EnumRecoverableResType.SKILL_POINT),"isSkillFull",ccp(85,-55))
  --       end
	end

	if not  self.nTimerId then
        self.nTimerId = TFDirector:addTimer(1000, -1, nil, self.onUpdated); 
    end

      --监听VIP等级更改
    self.totalRechargeChangeCallback = function(event)
    	self:refreshUIPayBtn()
	end
	TFDirector:addMEGlobalListener(MainPlayer.TotalRechargeChange, self.totalRechargeChangeCallback)


      --服务器开关变更
    self.serverSwitchChange = function(event)
		if event.data[1] == ServerSwitchType.WeiXin then
			self.btn_list[4]:setVisible(MainPlayer:getServerSwitchStatue(ServerSwitchType.WeiXin))
			self:refreshBtnList()
			return
		elseif event.data[1] == ServerSwitchType.GongLv then
			self.btn_list[9]:setVisible(MainPlayer:getServerSwitchStatue(ServerSwitchType.GongLv))
			self:refreshBtnList()
			return
		elseif event.data[1] == ServerSwitchType.MonthCard then
			self.btn_yueka:setVisible(QiyuManager:MonthCardIsOpen())
			self:refreshBtnList()
			return
		end
		self.qiyuBtn:setVisible(QiyuManager:QiyuFuctionIsOpen())
	end
	TFDirector:addMEGlobalListener(MainPlayer.ServerSwitchChange, self.serverSwitchChange)



    self.activityUpdateCallBack = function(event)
        OperationActivitiesManager:addOnlineRewardListener(self, 1001, onlineRewardTimer)

		-- 砸蛋活动
		local bShowEgg = OperationActivitiesManager:ActivityTypeIsOpen(OperationActivitiesManager.Type_Hit_Egg)
		-- local bShowEgg = OperationActivitiesManager:bShowGoldEgg()

		print("bShowEgg = ", bShowEgg)
		self.btn_list[6]:setVisible(bShowEgg)

		local bShowXunBao = OperationActivitiesManager:ActivityTypeIsOpen(OperationActivitiesManager.Type_Active_XunBao)
		self.btn_list[7]:setVisible(bShowXunBao)

		self:refreshBtnList()
    end

    TFDirector:addMEGlobalListener(OperationActivitiesManager.MSG_ACTIVITY_UPDATE, self.activityUpdateCallBack) 



    self.playerGuideButtonOpen = function(event)
		local widget = event.data[1]
		if widget:isVisible() then
			return
		end
		if self:showLeftDownButtonOpenAni(widget) == false then
			self:showRightMiddeleButtonOpenAni(widget)
		end
    end

	TFDirector:addMEGlobalListener(PlayerGuideManager.BUTTON_OPEN  ,self.playerGuideButtonOpen)



	local function sevenDayTimerEvent(sender)
		-- print("sender = ", sender)

	end

	SevenDaysManager:addSevenDaysEvent(self, 1001, sevenDayTimerEvent)


	self.Game_12_oClock_reset = function(event)
		self:refreshUI()
    end

	TFDirector:addMEGlobalListener(MainPlayer.GAME_RESET, self.Game_12_oClock_reset)

	self.newGuildApplyCallBack = function(event)
		CommonManager:setRedPoint(self.btn_faction, FactionManager:canViewRedPointInMainLayer(), "isFactionRedPoint", ccp(0,0))
	end
	TFDirector:addMEGlobalListener(FactionManager.newGuildApply, self.newGuildApplyCallBack)


	-- 请求帮派邀请
	FactionManager:gainGuildInvitation()

	self.newChatMsgCallBack = function(event)
		-- if ChatManager:checkInChatLayer() then
		-- 	return
		-- end
		self:showChatBubble()
	end
	TFDirector:addMEGlobalListener(ChatManager.ShowBubbleMsg, self.newChatMsgCallBack)
    TFDirector:addMEGlobalListener(PayManager.updateRecordList ,self.totalRechargeChangeCallback ) ;
end

function MenuLayer:getLeftDownWidgetShowNum()
	local num = 0
	for i=1,#self.leftDownBtnList do
		if self.leftDownBtnList[i].isOpen == true then
			num = num + 1
		end
	end
	return num
end

function MenuLayer:getWidgetInLeftDownPageIndex( widget )
	local num = 1
	for i=1,#self.leftDownBtnList do
		if self.leftDownBtnList[i] == widget then
			return num
		end
		if self.leftDownBtnList[i].isOpen == true then
			num = num + 1
		end
	end
	return 0
end

function MenuLayer:showLeftDownButtonOpenAni( widget )
	local widget_index = self:getWidgetInLeftDownPageIndex( widget )
	if widget_index == 0 then
		return false
	end
	local page = math.ceil(widget_index/5)
	if self.leftDownPage == page then
		self:_showLeftDownButtonOpenAni( widget )
	else
		self:turnChangeToIndex( page)
		self:_showLeftDownButtonOpenAni( widget )
	end
	return true
end

function MenuLayer:_showLeftDownButtonOpenAni( widget )
	local index = 0
	local num = 0
	local pos_x = self.leftDownBtnList_pos

	for i=1,#self.leftDownBtnList do
		if self.leftDownBtnList[i] == widget then
			num = num + 1
			index = i
			pos_x = pos_x + self.leftDownBtnList[i]:getContentSize().width/2
			self.leftDownBtnList[i]:setPositionX(pos_x)
			pos_x = pos_x + self.leftDownBtnList[i]:getContentSize().width/2 + 10
			widget.isOpen = true
		else
			if self.leftDownBtnList[i].isOpen == true and index == 0 then
				num = num + 1
				if num > (self.leftDownPage - 1)*5 and num <= self.leftDownPage*5 then
					pos_x = pos_x + self.leftDownBtnList[i]:getContentSize().width + 10
				end
			end
			if self.leftDownBtnList[i].isOpen == true and index ~= 0 then
				num = num + 1
				if num > (self.leftDownPage - 1)*5 and num <= self.leftDownPage*5 then
					pos_x = pos_x + self.leftDownBtnList[i]:getContentSize().width/2
					local tween = {
						target = self.leftDownBtnList[i],
						{
								duration = 1,
								x = pos_x,
						}
					}
					TFDirector:toTween(tween)
					pos_x = pos_x + self.leftDownBtnList[i]:getContentSize().width/2 + 10
				else
					self.leftDownBtnList[i]:setVisible(false)
				end
			end
		end
	end
	-- return index
end

function MenuLayer:showRightMiddeleButtonOpenAni( widget )
	local index = 0
	local pos_y = self.rightMiddleBtnList_pos
	for i=1,#self.rightMiddleBtnList do
		if self.rightMiddleBtnList[i] == widget then
			index = i
			pos_y = pos_y - self.rightMiddleBtnList[i]:getContentSize().height/2
			self.rightMiddleBtnList[i]:setPositionY(pos_y)
			pos_y = pos_y - self.rightMiddleBtnList[i]:getContentSize().height/2 - 10
			-- TFDirector:addTimer(1000,1,nil,function ()
			-- 			self.rightMiddleBtnList[i]:setVisible(true)
			-- 			self:refreshrightMiddleBtnList()
			-- 		end)
		else
			if self.rightMiddleBtnList[i]:isVisible() and index == 0 then
				pos_y = pos_y - self.rightMiddleBtnList[i]:getContentSize().height - 10
			end
			if self.rightMiddleBtnList[i]:isVisible() and index ~= 0 then
				pos_y = pos_y - self.rightMiddleBtnList[i]:getContentSize().height/2
				local tween = {
					target = self.rightMiddleBtnList[i],
					{
							duration = 1,
							y = pos_y,
					}
				}
				TFDirector:toTween(tween)
				pos_y = pos_y - self.rightMiddleBtnList[i]:getContentSize().height/2 - 10
			end
		end
	end
	return index
end
function MenuLayer:removeEvents()
    self.super.removeEvents(self)

	TFDirector:removeMEGlobalListener(MainPlayer.ResourceUpdateNotifyBatch ,self.updateUserDataCallBack)
	TFDirector:removeMEGlobalListener(MainPlayer.LevelChange ,self.levelVhangeCallBack)
	self.levelVhangeCallBack = nil
	TFDirector:removeMEGlobalListener(ZhengbaManager.UPADTECHAMPIONSSTATUS ,self.upadteChampionsStatus)
	self.upadteChampionsStatus = nil
	TFDirector:removeMEGlobalListener(FactionFightManager.activityStateChange ,self.activityStateChangeCB)
	self.upadteChampionsStatus = nil
	TFDirector:removeMEGlobalListener(MultiServerFightManager.updateActivityState ,self.updateActivityStateCB)
	self.updateActivityStateCB = nil

	TFDirector:removeMEGlobalListener(MainPlayer.ChallengeTimesChange ,self.updateUserDataCallBack)

	TFDirector:removeMEGlobalListener(OperationActivitiesManager.GET_ACITIVTY_REWARD_SUCCESS)
	TFDirector:removeMEGlobalListener(OperationActivitiesManager.ACITIVTY_REWARD_RECORD)

	-- OperationActivitiesManager:stopOnlineRewardTimer(1001)
	OperationActivitiesManager:removeOnlineRewardTimer(1001)

	TFDirector:removeMEGlobalListener("onSdkPlatformLogout", self.onSdkPlatformLogout)
	TFDirector:removeMEGlobalListener("onSdkPlatformLeave", self.onSdkPlatformLeave)


	TFDirector:removeMEGlobalListener(ChatManager.NewMarkChange  ,self.chatNewMarkChange)
	self.chatNewMarkChange = nil


    TFDirector:removeMEGlobalListener(MainPlayer.TotalRechargeChange, self.totalRechargeChangeCallback)
    TFDirector:removeMEGlobalListener(PayManager.updateRecordList, self.totalRechargeChangeCallback)
    self.totalRechargeChangeCallback = nil

    TFDirector:removeMEGlobalListener(MainPlayer.ServerSwitchChange, self.serverSwitchChange)
    self.serverSwitchChange = nil

	if self.timeId then
        TFDirector:removeTimer(self.timeId)
        self.timeId = nil
    end

    if self.nTimerId then
        TFDirector:removeTimer(self.nTimerId)
        self.nTimerId = nil
        self.onUpdated = nil
    end

    if self.nTimerLoginOut then
    	TFDirector:removeTimer(self.nTimerLoginOut)
        self.nTimerLoginOut = nil
    end

    if HeitaoSdk then
		-- HeitaoSdk.setLoginOutCallBack(nil)
	end

	
    TFDirector:removeMEGlobalListener(OperationActivitiesManager.MSG_ACTIVITY_UPDATE, self.activityUpdateCallBack)
    TFDirector:removeMEGlobalListener(PlayerGuideManager.BUTTON_OPEN  ,self.playerGuideButtonOpen)
    self.activityUpdateCallBack = nil

    SevenDaysManager:removeOnlineRewardTimer(1001)

    TFDirector:removeMEGlobalListener(MainPlayer.GAME_RESET, self.Game_12_oClock_reset)
    self.Game_12_oClock_reset = nil

    TFDirector:removeMEGlobalListener(FactionManager.newGuildApply, self.newGuildApplyCallBack)
    self.newGuildApplyCallBack = nil


	if self.bubbleDelayTime then
        TFDirector:removeTimer(self.bubbleDelayTime)
        self.bubbleDelayTime = nil
    end
    if self.bubbleMoveTime then
        TFDirector:removeTimer(self.bubbleMoveTime)
        self.bubbleMoveTime = nil
    end
	TFDirector:removeMEGlobalListener(ChatManager.ShowBubbleMsg, self.newChatMsgCallBack)
	self.newChatMsgCallBack = nil
end

function MenuLayer:setInfo()
	self.txt_vip:setVisible(true)
	self.img_vip:setVisible(false)

	-- self.txt_level:setText(MainPlayer:getLevel() .. "d")
	self.txt_level:setText(MainPlayer:getLevel())
	self.txt_vip:setText("o"..MainPlayer:getVipLevel())
	local totalPower = StrategyManager:getPower()
	if self.totalPower ~= totalPower then
		self.totalPower = totalPower
		CardRoleManager:reSortStrategy();
	end
	self.txt_power:setText(self.totalPower)
	self.headImg:setTexture(MainPlayer:getIconPath())

	-- or ( CommonManager:isTuhao() and CommonManager:getTuhaoFreeTimes() > 0 )
	CommonManager:setRedPoint(self.headImg, HeadPicFrameManager:haveFirstGetFrame() or ( CommonManager:isTuhao() and CommonManager:getTuhaoFreeTimes() > 0 and MainPlayer:getFirstLogin() == true ),"isFirstGet",ccp(15,-5))
	local vipLevel = MainPlayer:getVipLevel()
	--modify by zr VIP等级显示
	--[[
	if vipLevel > 15 then
		self.txt_vip:setVisible(false)
		self.img_vip:setVisible(true)
		self:addVipEffect(self.img_vip)
	end
	]]--
end

function MenuLayer:refreshTaskInfo()
	local firstDailyTask = TaskManager:GetFirstDailyTask()

	if firstDailyTask == nil then
		local textImg = TFDirector:getChildByPath(self.taskPanel, 'textImg')
		textImg:setVisible(false)
	else
		local textImg = TFDirector:getChildByPath(self.taskPanel, 'textImg')
		textImg:setVisible(true)

		local nameLabel = TFDirector:getChildByPath(self.taskPanel, 'nameLabel')
		nameLabel:setText(firstDailyTask.desc)

		local goBtn = TFDirector:getChildByPath(self.taskPanel, 'goBtn')
		if TaskManager:CanGoToLayer(firstDailyTask, false) then
			goBtn:setVisible(true)
			goBtn:addMEListener(TFWIDGET_CLICK, function() TaskManager:CanGoToLayer(firstDailyTask, true) end)
		else
			goBtn:setVisible(false)
		end
	end
end

function MenuLayer:AddButtonEffect(button, effName, posX, posY)
	-- TFResourceHelper:instance():addArmatureFromJsonFile("effect/"..effName..".xml")
	-- local effect = TFArmature:create(effName.."_anim")
	-- if effect == nil then
	-- 	return
	-- end

	-- effect:setAnimationFps(GameConfig.ANIM_FPS)
	-- effect:playByIndex(0, -1, -1, 1)
	-- effect:setPosition(ccp(posX, posY))
	-- button:addChild(effect)
	Public:addEffect(effName, button, posX, posY, 1, 1)
end

function MenuLayer:AddResEffect(button, effName, posX, posY, index)
	TFResourceHelper:instance():addArmatureFromJsonFile("effect/"..effName..".xml")
	local effect = TFArmature:create(effName.."_anim")
	if effect == nil then
		return
	end

	-- effect:setAnimationFps(GameConfig.ANIM_FPS)
	effect:playByIndex(index, -1, -1, 1)
	effect:setPosition(ccp(posX, posY))
	button:addChild(effect)
end

function MenuLayer:InitRoleList()
	local roleList = CardRoleManager:getUsedCardList()
	local roleNum = roleList:length()
	for i=1,roleNum do
		local cardRole = roleList:getObjectAt(i)
		self:AddRole(cardRole, i)
	end

	self:RemoveNoUseArmature()
	self:AddRolePosEffect()
end

function MenuLayer:CreateArmature(roleID)
	local roleTableData = RoleData:objectByID(roleID)
	if roleTableData == nil then
		return nil
	end

	local resID = roleTableData.image
	-- modify by jin 20170322 --[
	-- local resPath = "armature/"..resID..".xml"
	-- if not TFFileUtil:existFile(resPath) then
	-- 	resID = 10006
	-- 	resPath = "armature/"..resID..".xml"
	-- end
	
	-- TFResourceHelper:instance():addArmatureFromJsonFile(resPath)


	-- local armature = TFArmature:create(resID.."_anim")
	-- if armature == nil then
	-- 	return nil
	-- end
 --    GameResourceManager:addRole( roleID, armature)
    --]--

    if not ModelManager:existResourceFile(1, resID) then 
    	resID = 10006 
    end
	ModelManager:addResourceFromFile(1, resID, 1)

	local armature = ModelManager:createResource(1, resID)
	if armature == nil then
		return nil
	end
    GameResourceManager:addRole( roleID, armature)

	self.armatureList[roleID] = armature

	self.rolePanel:addChild(armature)

	return armature
end

function MenuLayer:RemoveNoUseArmature()
	local needRemove = false
	for roleID, armature in pairs(self.armatureList) do
		if not self:IsUsedArmature(roleID) then
			armature:removeFromParent()
			self.armatureList[roleID] = nil
			GameResourceManager:removeRole( roleID )
			needRemove = true
		end
	end
	if needRemove then
		me.ArmatureDataManager:removeUnusedArmatureInfo()
	end
end

function MenuLayer:IsUsedArmature(roleID)
	local roleList = CardRoleManager:getUsedCardList()
	local roleNum = roleList:length()
	for i=1,roleNum do
		local cardRole = roleList:getObjectAt(i)
		if cardRole ~= nil and cardRole.id == roleID then
			return true
		end
	end

	return false
end

function MenuLayer:AddRole(roleInfo, pos)
	if pos > 5 then
		return
	end

	local newRole = false
	local armature = nil
	if self.armatureList[roleInfo.id] ~= nil then
		armature = self.armatureList[roleInfo.id]
	else
		armature = self:CreateArmature(roleInfo.id)
		newRole = true
	end

	if armature == nil then
		return
	end

	local posX = {-250, -380, -135, 104, 317}
	local posY = {-170, -60, -35, -42, -112}
	local scale = {0.65, 0.55, 0.55, 0.55, 0.65}

	local armaturePos = armature:getPosition()
	if armaturePos.x == posX[pos] and armaturePos.y == posY[pos] then
		return
	end

	armature:setPosition(ccp(posX[pos], posY[pos]))
	armature:setScale(scale[pos])
	armature:setZOrder(10-pos)
	armature:setName("armature"..pos)

	ModelManager:playWithNameAndIndex(armature, "stand", -1, 1, -1, -1)
	
	if newRole then  
		self:AddRoleFootEffect(armature)
		armature:setTouchEnabled(true)
		local gmId = roleInfo.gmId
		armature:addMEListener(TFWIDGET_CLICK, audioClickfun(function() 
			self.rolePanel:setZOrder(0) 
			CardRoleManager:openRoleInfo(gmId)
			 end))
	end
end

function MenuLayer:AddRoleFootEffect(roleArmature)
	TFResourceHelper:instance():addArmatureFromJsonFile("effect/main_role.xml")
	local effect = TFArmature:create("main_role_anim")
	if effect ~= nil then
		effect:setAnimationFps(GameConfig.ANIM_FPS)
		effect:playByIndex(0, -1, -1, 1)
		roleArmature:addChild(effect)
	end

	TFResourceHelper:instance():addArmatureFromJsonFile("effect/main_role2.xml")
	local effect2 = TFArmature:create("main_role2_anim")
	if effect2 ~= nil then
		effect2:setAnimationFps(GameConfig.ANIM_FPS)
		effect2:playByIndex(0, -1, -1, 1)
		effect2:setZOrder(-1)
		effect2:setPosition(ccp(0, -10))
		roleArmature:addChild(effect2)
	end
end

function MenuLayer:AddRolePosEffect()
	local posX = {-270, -385, -135, 94, 317}
	local posY = {-90, -40, -26, -33, -90}

	local fightRoleNum = StrategyManager:getFightRoleNum() 
	local maxNum = StrategyManager:getMaxNum()

	for i=1, 5 do
		local posEffect = self.posEffList[i]
		if i <= fightRoleNum then
			if posEffect ~= nil then
				posEffect:removeFromParent()
				self.posEffList[i] = nil
			end
		elseif i > fightRoleNum and i <= maxNum then
			if posEffect ~= nil and posEffect.index ~= 0 then
				-- posEffect:playByIndex(0, -1, -1, 1)
				ModelManager:playWithNameAndIndex(posEffect, "", 0, 1, -1, -1)
				posEffect.index = 0
				posEffect:addMEListener(TFWIDGET_CLICK, audioClickfun(function() CardRoleManager:openRoleList() end))
			end
			if posEffect == nil then
				posEffect = self:CreatePosEffect(i, "main_effect",0)
				posEffect:setPosition(ccp(posX[i], posY[i]))
			end
		else
			if posEffect ~= nil and posEffect.index ~= 1 then
				-- posEffect:playByIndex(1, -1, -1, 1)
				ModelManager:playWithNameAndIndex(posEffect, "", 0, 1, -1, -1)
				posEffect.index = 1
				local needLevel = FunctionOpenConfigure:getOpenLevel(700 + i)
				
				--posEffect:addMEListener(TFWIDGET_CLICK, audioClickfun(function() toastMessage("团队等级达到"..needLevel.."级开启该阵位") end))
				posEffect:addMEListener(TFWIDGET_CLICK, audioClickfun(function() toastMessage(stringUtils.format(localizable.common_open_position,needLevel) ) end))
			elseif posEffect == nil then
				posEffect = self:CreatePosEffect(i, "main_effect",1)
				posEffect:setPosition(ccp(posX[i], posY[i]))
			end
		end
	end
end

function MenuLayer:CreatePosEffect(pos, effName,index)
	print("CreatePosEffect ",pos, effName,index)
	ModelManager:addResourceFromFile(2, effName, 1)
	local effect = ModelManager:createResource(2, effName)
	if effect == nil then
		print("CreatePosEffect == nil ",pos, effName,index)
		return nil
	end

	effect:setName("armature"..pos)
	-- effect:setAnimationFps(GameConfig.ANIM_FPS)
	ModelManager:playWithNameAndIndex(effect, "", 0, 1, -1, -1)
	effect.index = index
	self.posEffList[pos] = effect
	self.rolePanel:addChild(effect)

	effect:setTouchEnabled(true)
	if index == 0 then
		effect:addMEListener(TFWIDGET_CLICK, audioClickfun(function() CardRoleManager:openRoleList() end))
	else
		-- local posLev = {1, 1, 1, 4, 9}
		local needLevel = FunctionOpenConfigure:getOpenLevel(700 + pos)
		--effect:addMEListener(TFWIDGET_CLICK, audioClickfun(function() toastMessage("团队等级达到"..needLevel.."级开启该阵位") end))
		effect:addMEListener(TFWIDGET_CLICK, audioClickfun(function() toastMessage(stringUtils.format(localizable.common_open_position,needLevel)) end))
	end

	return effect
end

function MenuLayer.headClickHandle(sender)	
	local self = sender.logic
	self:requestFirstLogin()
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.main.MainPlayerLayer",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1)
	-- local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.main.MainPlayerLayer2",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1)
    AlertManager:show();
end

function MenuLayer:requestFirstLogin()
	if MainPlayer:getFirstLogin() then
		TFDirector:send(c2s.FIRST_ONLINE_PROMPT_REQUEST, {})
		MainPlayer:setFirstLogin(false)
	end
end

function MenuLayer.roleBtnClickHandle(sender)
	CardRoleManager:openRoleList()
    -- local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.mission.MissionSkipNewLayer",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1);        
    -- layer:loadData(19, 1);     
    -- AlertManager:show();  
end

function MenuLayer.equipBtnClickHandle(sender)
	EquipmentManager:OpenSmithyMainLaye()
end
function MenuLayer.bagBtnClickHandle(sender)
	BagManager:ShowBagLayer(0, 1)
end

function MenuLayer.employBtnClickHandle(sender)
	-- EmployManager:openHireTeamLayer(1)
	EmployManager:openEmployLayer()
end

function MenuLayer.shezhiClickHandle(sender)
	local layer = require("lua.logic.setting.SettingLayer"):new()
    AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1)
    AlertManager:show()
end

function MenuLayer.infoBtnClickHandle(sender)
	NotifyManager:ShowNotifyInfoLayer()
end

function MenuLayer.mallBtnClickHandle(sender)
	MallManager:openMallLayer()
end
function MenuLayer.zhaomuBtnClickHandle(sender)
	MallManager:openRecruitLayer()
end

function MenuLayer.chatClickHandle(sender)
	-- local self = sender.logic
	-- if self.bubbleDelayTime then
 --        TFDirector:removeTimer(self.bubbleDelayTime)
 --        self.bubbleDelayTime = nil
 --    end
 --    if self.bubbleMoveTime then
 --        TFDirector:removeTimer(self.bubbleMoveTime)
 --        self.bubbleMoveTime = nil
 --    end   
 --    self.bubbleNode:setVisible(false)

	ChatManager:showChatLayer()
end

function MenuLayer.taskBtnClickHandle(sender)
	TaskManager:ShowTaskLayer(1)
end

function MenuLayer.dailyTaskBtnClickHandle(sender)
	local teamLev   = MainPlayer:getLevel()
    local openLevel = FunctionOpenConfigure:getOpenLevel(1001)
    --  等级开发之后奇遇才会有红点
    if openLevel > teamLev then
    	--toastMessage("团队等级达到"..openLevel.."级开启")
		toastMessage(stringUtils.format(localizable.common_function_openlevel,openLevel))

        return
    end

	TaskManager:ShowTaskLayer(0)
end

function MenuLayer.pvpBtnClickHandle(sender)
	ActivityManager:showLayer(ActivityManager.TAP_Arena);
end

function MenuLayer.onBtnYouliClick( sender )
	AdventureManager:openHomeLayer()
end

function MenuLayer.pveBtnClickHandle(sender)
 	MissionManager:showHomeLayer()
end

function MenuLayer.qiyuBtnClickHandle(sender)
	QiyuManager:OpenHomeLayer()
end

function MenuLayer.goldEggBtnClickHandle(sender)
	GoldEggManager:openGoldEggMainLayer()
end

function MenuLayer.xunBaoBtnClickHandle(sender)
    TreasureManager:requestConfigMessage()
end

function MenuLayer.signBtnClickHandle(sender)
    local layer  = require("lua.logic.qiyu.SignLayer"):new()
    AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1)
    AlertManager:show()
end

function MenuLayer.yuekaBtnClickHandle(sender)
	MonthCardManager:openMonthCardLayer()	
end

function MenuLayer.tujianBtnClickHandle(sender)
	IllustrationManager:openIllustrationLayer()
end
function MenuLayer.youfangMallBtnClickHandle(sender)
	MallManager:openYouFangLayer()
end

function MenuLayer.gonglueBtnClickHandle(sender)
	local platformid = nil
	local userId 	 = nil

	if HeitaoSdk then
		platformid = HeitaoSdk.getplatformId()
		userId 	   = HeitaoSdk.getuserid()
	else
		platformid = "win2015"
		userId 	   = TFPlugins.getUserID()
	end
	local url = "http://smi.heitao.com/mhqx/curinfo/index"--?pfid="..platformid.."&psid=222&uid=333"
	if platformid then
		url = url.."?pfid="..platformid
	end
	local userInfo = SaveManager:getUserInfo()
    if userInfo.currentServer then
        psid = tonumber(userInfo.currentServer)
        url = url.."&psid="..psid
    end
	if userId then
		url = url.."&uid="..userId
	end
	TFDeviceInfo:openHeitaoWebUrl(url)
	-- 
end

function MenuLayer.onclickSevenDay(sender)
	SevenDaysManager:showSevenDaysLayer()
end



function MenuLayer.paihangBtnClickHandle(sender)
	-- OperationActivitiesManager:openleaderBoard()
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.leaderboard.Leaderboard.lua")
	layer:setIndex(1)
    AlertManager:show();
end

function MenuLayer.huodongBtnClickHandle(sender)
	print("-------------MenuLayer.huodongBtnClickHandle")
	OperationActivitiesManager:openHomeLayer()
end

function MenuLayer.OnlineBtnClickHandle(sender)

	-- OperationActivitiesManager:getOnlineReward()
	OperationActivitiesManager:requestReceiveOnlineReward()
end

-- 在线奖励
function MenuLayer:getOnlineRewardUpdate(data)
	if data and data.onlineRewardCount then
		self.onlineRewardCount = data.onlineRewardCount + 1
		self.timeCount = 45
	end
	-- self.timeCount = 45
end

function MenuLayer:AddBgImgEffect()
	-- 落花
	TFResourceHelper:instance():addArmatureFromJsonFile("effect/main_bg1.xml")
	local eff2 = TFArmature:create("main_bg1_anim")
	eff2:setAnimationFps(GameConfig.ANIM_FPS)
	eff2:playByIndex(0, -1, -1, 1)
	eff2:setZOrder(1000)
	self.rolePanel:addChild(eff2)

	-- 背景动画
	ModelManager:addResourceFromFile(2, "main_tx1", 1)
	local mainEff = ModelManager:createResource(2, "main_tx1")
	local frameSize = GameConfig.WS
	mainEff:setPosition(ccp(self.bg:getContentSize().width / 2, self.bg:getContentSize().height / 2))
	self.bg:addChild(mainEff)
	ModelManager:playWithNameAndIndex(mainEff, "", 0, 1, -1, -1)
	mainEff:setScale(1.04)
end

function MenuLayer:playOnlineEffect()
	
	if self.OnlineEffect == nil  then
        ModelManager:addResourceFromFile(2, "onlinereward", 1)
        local effect = ModelManager:createResource(2, "onlinereward")
        local node   = self.btn_zaixian --:getParent() --node:getPosition()

        -- effect:setAnimationFps(GameConfig.ANIM_FPS)

        node:addChild(effect,2)
        -- effect:setPosition(ccp(0,-36))
        effect:setPosition(ccp(-7,-9))

        effect:setAnchorPoint(ccp(0.5, 0.5))
        self.OnlineEffect = effect
    

    	-- self.OnlineEffect:playByIndex(0, -1, -1, 1)
    	ModelManager:playWithNameAndIndex(self.OnlineEffect, "", 0, 1, -1, -1)
	end
end

-- 结束
function MenuLayer:stopOnlineEffect()
	if self.OnlineEffect then
		self.OnlineEffect:removeFromParent()
        self.OnlineEffect = nil
	end

	-- if OperationActivitiesManager:isGetAllOnlineReward() then
	if OperationActivitiesManager:AllOnlineRewardIsReceived() then
		self.btn_zaixian:setVisible(false)
	end
end

-- pp
function MenuLayer.PlatformBtnClickHandle(sender)
	-- if TFPlugins.getChannelId() ~= "" then
	if TFPlugins.isPluginExist() then
		TFPlugins.EnterPlatform()
		return
	else

	end
end
function MenuLayer.friendBtnClickHandle(sender)
	FriendManager:openFriendMainLayer()
end
function MenuLayer.factionBtnClickHandle(btn)
	FactionManager:openFactionFromHomeIcon()
end

function MenuLayer.changeBtnClickHandle(sender)
	local self = sender.logic
	if self:getLeftDownWidgetShowNum() <= 5 then
		return
	end
	sender.logic:turnChange()
end

function MenuLayer.playBackBtnClickHandle(sender)
	PlayBackManager:showPlayerBackMainLayer()
end

function MenuLayer:turnChangeToIndex( index)
	self.leftDownPage = index
    self:refreshLeftDownBtnList()
    self.ischang = false
    local pic = TFDirector:getChildByPath(self, 'img_change')
	local ratato = (2 - self.leftDownPage )*45
	pic:setRotation(ratato)
end
function MenuLayer:turnChangeTowidget( widget)
	local widget_index = self:getWidgetInLeftDownPageIndex( widget )
	if widget_index == 0 then
		return
	end
	local page = math.ceil(widget_index/5)
	if self.leftDownPage == page then
	else
		self:turnChangeToIndex( page)
	end
end

function MenuLayer:turnChange(func)
	if self.ischang == true then
		-- if func then
		-- 	func()
		-- end
		return
	end
	self.btn_change:setVisible(true)
	self.ischang = true
	local tween = {
		target = self.panel_rightDown,
		{
			duration = 0.3,
			x = -560,
			onComplete = function()
                self.leftDownPage = 3 - self.leftDownPage
                self:refreshLeftDownBtnList()
                self.btn_change:setVisible(true)
            end
		},
		{
			duration = 0.3,
			x = 0,
			onComplete = function()
                self.ischang = false
                if func then
					func()
                end
            end
		}
	}
	TFDirector:toTween(tween)

	local pic = TFDirector:getChildByPath(self, 'img_change')
	local ratato = (2 - self.leftDownPage )*45
	local pic_tween = {
		target = pic,
		{
			duration = 0.6,
			rotate = ratato,
			onComplete = function()
                pic:setRotation(ratato)
            end
		},
	}
	TFDirector:toTween(pic_tween)
end

function MenuLayer:gotoLayerByType( layer_type )
	AlertManager:closeAll()
	if layer_type == 1 then  			--酒馆
		MallManager:openRecruitLayer()		
	elseif layer_type == 2 then  			--侠客属性面板
		CardRoleManager:openRoleInfo(CardRoleManager:getRoleById(MainPlayer:getProfession()).gmId)
	elseif layer_type == 3 then  			--布阵
		CardRoleManager:openRoleList()
	elseif layer_type == 4 then  			--装备强化界面
		EquipmentManager:OpenSmithyMainLaye()		
	end
end

function MenuLayer:isButtonOpen( info )
	if info.level then
		local level = MainPlayer:getLevel()
		if level < info.level then
			return false
		end
	end
	if info.guide then
		if PlayerGuideManager:isFunctionOpen(info.guide) == false then
			return false
		end
	end
	return true
end

function MenuLayer:refreshBtnVisible()
	for info in MenuBtnOpenData:iterator() do
		local widget = TFDirector:getChildByPath(self, info.btnName)
		if widget then
			if self:isButtonOpen(info) then
				widget:setVisible(true)
				if widget == self.qiyuBtn and QiyuManager:QiyuFuctionIsOpen() == false then
					widget:setVisible(false)
				elseif widget == self.btn_sevenday and SevenDaysManager:sevenDaysOpenSatus() == 0 then
					widget:setVisible(false)
				end
				widget.isOpen = true
			else
				widget:setVisible(false)
				widget.isOpen = false
			end
		else
			print("widget == nil btnName == ",info.btnName)
		end
	end
	self:refreshYouliButton()
	self:refreshLeftDownBtnList()
	self:refreshRightMiddleBtnList()

end

function MenuLayer:refreshBtnVisibleWithLevel()
	local level = MainPlayer:getLevel()
	for info in MenuBtnOpenData:iterator() do
		local widget = TFDirector:getChildByPath(self, info.btnName)
		if widget then
			if info.level and info.level == level then
				widget:setVisible(true)
			end
		else
			print("widget == nil btnName == ",info.btnName)
		end
	end
end
function MenuLayer:refreshZhengbaBtn()
	
	self.btn_zhengbasai:setVisible(false)
	if ZhengbaManager:getActivityStatus() ~= 1 and MainPlayer:getLevel() >= 35 then
		self.btn_zhengbasai:setTextureNormal("ui_new/home/main_wldh_btn.png")
		self.btn_zhengbasai:setVisible(true)
	elseif FactionFightManager:getActivityState() == FactionFightManager.ActivityState_3 then
		local nowDate = os.date("*t",MainPlayer:getNowtime())
		local sec = nowDate.hour*60*60 + nowDate.min*60
		local desSec = 19*60*60 + 30*60
		if nowDate.wday == 6 and (sec < desSec) then
			self.btn_zhengbasai:setTextureNormal("ui_new/home/main_bpzf_btn.png")
			self.btn_zhengbasai:setVisible(true)
		end
    end
    self:refreshKfFightBtn()
end

function MenuLayer:refreshKfFightBtn()
	
	self.btn_kfFight:setVisible(false)
	if self.btn_zhengbasai:isVisible() then
		self.btn_kfFight:setPosition(self.btn_kfFightXY)
	else
		self.btn_kfFight:setPosition(self.btn_zhengbasai:getPosition())
	end
	local state = MultiServerFightManager:getActivityState()
	if state and (state >= 1 and state < 9) then
		self.btn_kfFight:setVisible(true)
    end
end

function MenuLayer:refreshYueCardMonthBuff()
	local bOwnMonth = MonthCardManager:isExistMonthCard(MonthCardManager.CARD_TYPE_2)

	print("------MonthCard status= ", bOwnMonth)
	if self.MonthCardBuffEffect == nil then
		-- MonthCardManager:isExistMonthCard(MonthCardManager.CARD_TYPE_2)
		-- 有月卡 创建
		print("111111111111111")
		if bOwnMonth == true then
			local resPath = "effect/effect_main_role_buf.xml"
			TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
			local effect = TFArmature:create("effect_main_role_buf_anim")
			if effect == nil then
				return nil
			end

			effect:setAnimationFps(GameConfig.ANIM_FPS)
			effect:setZOrder(10)
			effect:playByIndex(0, -1, -1, 1)
			effect:setPosition(ccp(-40,220))
			self.rolePanel:addChild(effect)

			effect:setTouchEnabled(true)
			effect:addMEListener(TFWIDGET_CLICK, audioClickfun(function() self:openMonthCardTips() end))

			self.MonthCardBuffEffect = effect
		end
	else

		print("222222222")
		if bOwnMonth == false then
			self.MonthCardBuffEffect:removeFromParent()
			self.MonthCardBuffEffect = nil
		end
	end
end

function MenuLayer:openMonthCardTips()
-- 	-- toastMessage("12")
-- 	月卡TIPS调整：
-- 您是尊贵的豪侠月卡会员，月卡持续时间内主角 武力、内力+500 每级额外+5点
-- 武力 =  500 + 团队等级*5
-- 内力 =  500 + 团队等级*5
	local layer =  AlertManager:addLayerByFile("lua.logic.common.TipsMessage", AlertManager.BLOCK_AND_GRAY_CLOSE)
	--local title = "豪侠月卡"
	local title = localizable.menuLayer_monthcard
	--local content = "您是尊贵的豪侠月卡会员，月卡持续时间内主角额外获得：\n武力 =  500 + 团队等级*5\n内力 =  500 + 团队等级*5"
	local content = localizable.menuLayer_monthcard_addattr
    layer:setText(title, content)

    AlertManager:show()
end

-- function MenuLayer.onSdkPlatformLogout(event)
-- 	-- toastMessage("---------MenuLayer.onSdkPlatformLogout ")
-- 	SettingManager:gotoLoginLayer()
-- end

-- function MenuLayer.onSdkPlatformLeave(event)
-- 	toastMessage("---------MenuLayer.onSdkPlatformLeave ")
-- 	-- toastMessage("---------MenuLayer.onSdkPlatformLeave ")
-- end
--[[
self.leftDownBtnList = {
		self.roleBtn,
		self.equipBtn,
		self.bagBtn,
		self.taskBtn,
		self.mallBtn,
		self.zhaomuBtn,
		self.btn_friends,
		self.btn_faction,
	}
]]
function MenuLayer:updateChangeBtnRedPoint()
	CommonManager:removeRedPoint(self.btn_change)
	local index = 3-self.leftDownPage
	local num = 0
	for i=1,#self.leftDownBtnList do
		if self.leftDownBtnList[i].isOpen == true then
			num = num + 1
			if num > (index - 1)*5 and num <= index*5 then
				if self.leftDownBtnList[i] == self.roleBtn then
					CommonManager:setRedPoint(self.btn_change, CardRoleManager:isHaveBook(),	"isHaveBook",	ccp(-25,50))
				elseif self.leftDownBtnList[i] == self.bagBtn then
					CommonManager:setRedPoint(self.btn_change, BagManager:isHaveCanZhaomu(),"isHaveCanZhaomu",ccp(-25,50))
					CommonManager:setRedPoint(self.btn_change, BagManager:isHaveCanPiece(3),"isHaveCanPiece",ccp(-25,50))
					CommonManager:setRedPoint(self.btn_change, BagManager:isHaveCanProp(),"isHaveCanProp",ccp(-25,50))
					CommonManager:setRedPoint(self.btn_change, BagManager:isHaveCanGift(),"isHaveCanGift",ccp(-25,50))
				elseif self.leftDownBtnList[i] == self.taskBtn then
					CommonManager:setRedPoint(self.btn_change, TaskManager:isCanGetRewardForType(1),"isCanGetRewardForType",ccp(-25,50))
				elseif self.leftDownBtnList[i] == self.mallBtn then
					CommonManager:setRedPoint(self.btn_change, MallManager:isHaveNewGif(),"isHaveNewGif",ccp(-25,50))
					CommonManager:setRedPoint(self.btn_change, MallManager:isHaveNewGoods(),"isHaveNewGoods",ccp(-25,50))
				elseif self.leftDownBtnList[i] == self.zhaomuBtn then
					CommonManager:setRedPoint(self.btn_change, GetCardManager:isHaveGetCardFree(),"isHaveGetCardFree",ccp(-25,50))
				elseif self.leftDownBtnList[i] == self.btn_faction then
					CommonManager:setRedPoint(self.btn_change, FactionManager:canViewRedPointInMainLayer(), "isFactionRedPoint", ccp(-25,50))
				elseif self.leftDownBtnList[i] == self.btn_friends then
					CommonManager:setRedPoint(self.btn_change, FriendManager:isShowRedPoint(), "isShowRedPoint", ccp(-25,50))
				end
			end
		end
	end
end
--[[
message ChatInfo
{
	required int32 chatType = 1;	// 聊天类型；1、公共，2、私聊；3、帮派； 
	required string message = 2;	//消息;
	required int32 playerId = 3;	//说话人的id 
	required string name = 4;		//说话人的名字 
}
]]
function MenuLayer:showChatBubble()
	local newMsg = ChatManager:getLatestMsg()
	
	if newMsg == nil then
		self.bubbleNode:setVisible(false)
		return
	end
	if newMsg.playerId == nil or  newMsg.playerId == 0 then
        self.bubbleNode:setVisible(false)
		return
	end

	--整理
	local msgTemplete = '%s:%s'
	--local preFixStr = '[江湖]'
	local preFixStr = localizable.menuLayer_chat1
	if newMsg.chatType == EnumChatType.Public then
		--preFixStr = '[江湖]'
		preFixStr = localizable.menuLayer_chat1
	elseif newMsg.chatType == EnumChatType.Gang then
		--preFixStr = '[帮派]'
		preFixStr = localizable.menuLayer_chat2
	elseif newMsg.chatType == EnumChatType.PrivateChat then
		--preFixStr = '[好友]'		
		preFixStr = localizable.menuLayer_chat3		
	else
        self.bubbleNode:setVisible(false)
		return
	end
	local str = string.format(msgTemplete, newMsg.name, newMsg.content)
	self.txtBubbleTitle:setText(preFixStr)	

	if self.bubbleDelayTime then
        TFDirector:removeTimer(self.bubbleDelayTime)
        self.bubbleDelayTime = nil
    end
    if self.bubbleMoveTime then
        TFDirector:removeTimer(self.bubbleMoveTime)
        self.bubbleMoveTime = nil
    end

    self.txtBubble:setPosition(ccp(0,0))
    self.txtBubble:setText(str)
    self.bubbleNode:setVisible(true)

    self.bubbleDelayTime = TFDirector:addTimer(30000, 1, function () 
		 	if self.bubbleDelayTime then
		        TFDirector:removeTimer(self.bubbleDelayTime)
		        self.bubbleDelayTime = nil
		    end
		    if self.bubbleMoveTime then
		        TFDirector:removeTimer(self.bubbleMoveTime)
		        self.bubbleMoveTime = nil
		    end
		    self.bubbleNode:setVisible(false)
		   	print('font move end ----------------------')
        end)

    local clipWidth = self.bubblePanel:getContentSize().width
    local fontWidth = self.txtBubble:getContentSize().width

    if clipWidth < fontWidth then
        local moveX = 10
        local times = math.ceil((fontWidth - clipWidth)/10)

        local function fontMove()
        	local moveTimes = 0
            self.txtBubble:setPosition(ccp(0,0))           
            self.bubbleMoveTime = TFDirector:addTimer(300, times+8, 
                function()
                   fontMove()
                end,
                function()
                    --每次进来
                    moveTimes = moveTimes + 1
                    if moveTimes < 4 then
                    	self.txtBubble:setPosition(ccp(0,0))
                    elseif moveTimes <= (times+4) then                    	
	                    local currX = self.txtBubble:getPositionX()
	                    currX = currX - 10
	                    self.txtBubble:setPositionX(currX)
	                end
                end)
        end
        fontMove()
    end
end

function MenuLayer:refreshYouliButton()

	local openLevel = FunctionOpenConfigure:getOpenLevel(2203)
	local currLevel = MainPlayer:getLevel()

	if currLevel >= openLevel then
		self.btn_youli:setVisible(true)
		self.btn_youli:setPosition(self.btnYouliPos)
		self.pvpBtn:setPosition(self.pvpBtnPos)
	else
		self.btn_youli:setVisible(false)
		self.pvpBtn:setPosition(self.btnYouliPos)
	end
end

return MenuLayer
