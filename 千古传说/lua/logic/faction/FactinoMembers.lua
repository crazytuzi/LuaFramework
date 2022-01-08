--[[
******帮派成员信息*******

	-- by quanhuan
	-- 2015/10/26
	
]]

local FactinoMembers = class("FactinoMembers",BaseLayer)

function FactinoMembers:ctor(data)
	self.super.ctor(self, data)
	self:init("lua.uiconfig_mango_new.faction.FactinoMembers")
end

function FactinoMembers:initUI( ui )

	self.super.initUI(self, ui)

	self.txt_times = TFDirector:getChildByPath(ui, "txt_times")
	    
	--创建TabView
    self.TabViewUI = TFDirector:getChildByPath(ui, "Panel_chengyueliebiao")
    self.TabView =  TFTableView:create()
    self.TabView:setTableViewSize(self.TabViewUI:getContentSize())
    self.TabView:setDirection(TFTableView.TFSCROLLVERTICAL)    
    self.TabView:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)
    self.TabView.logic = self
    self.TabViewUI:addChild(self.TabView)
    self.TabView:setPosition(ccp(0,0))

    self.cellModel  = createUIByLuaNew("lua.uiconfig_mango_new.faction.MembersCell")
    self.cellModel:retain()

    self.cellMax = 0

    self.allPanels = {}

end

function FactinoMembers:removeUI()
   	self.super.removeUI(self)
   	if self.cellModel then
   		self.cellModel:release()
   		self.cellModel = nil
   	end
end

function FactinoMembers:onShow()
    self.super.onShow(self)
end

function FactinoMembers:registerEvents()

	if self.registerEventCallFlag then
		return
	end

	self.super.registerEvents(self)

    --注册TabView事件
    self.TabView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, self.cellSizeForTable)
    self.TabView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, self.numberOfCellsInTableView)
    self.TabView:addMEListener(TFTABLEVIEW_SIZEATINDEX, self.tableCellAtIndex)

    self.getCoinUpdateCallBack = function (event)
    	print("coin = ",event.data[1][1])
        local rewardList = TFArray:new();    	
        local reward = {};
        reward.itemId = 0;
        reward.number = event.data[1][1];
        reward.type   = EnumDropType.COIN;
        rewardList:push(BaseDataManager:getReward(reward))
	       
    	RewardManager:showRewardListLayer( rewardList )
		self:refreshData()
		self.TabView:reloadData()       
    end    
    TFDirector:addMEGlobalListener(FactionManager.getCoinUpdate, self.getCoinUpdateCallBack)


    self.registerEventCallFlag = true
    self.tableViewNeedInit = true

end



function FactinoMembers:removeEvents()

    self.TabView:removeMEListener(TFTABLEVIEW_SIZEFORINDEX)
    self.TabView:removeMEListener(TFTABLEVIEW_SIZEATINDEX)
    self.TabView:removeMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW)

    self.super.removeEvents(self)
    TFDirector:removeMEGlobalListener(FactionManager.getCoinUpdate, self.getCoinUpdateCallBack)

    self.registerEventCallFlag = nil
    
end

function FactinoMembers:dispose()
    self.super.dispose(self)
	for k,v in pairs(self.allPanels) do
		if v.btnJjjl then
			v.btnJjjl:removeMEListener(TFWIDGET_CLICK)
			v.btnJjjl = nil
		end
		if v.btnJiejiao then
			v.btnJiejiao:removeMEListener(TFWIDGET_CLICK)
			v.btnJiejiao = nil
		end
		if v.btnAppoint then
			v.btnAppoint:removeMEListener(TFWIDGET_CLICK)
			v.btnAppoint = nil
		end
		if v.btnImpeach then
			v.btnImpeach:removeMEListener(TFWIDGET_CLICK)
			v.btnImpeach = nil
		end
		if v.btnCancelImpeach then
			v.btnCancelImpeach:removeMEListener(TFWIDGET_CLICK)
			v.btnCancelImpeach = nil
		end
		if v.btnImpeachIng then
			v.btnImpeachIng:removeMEListener(TFWIDGET_CLICK)
			v.btnImpeachIng = nil
		end
		
		local panel = v:getChildByTag(10086)
		panel:removeFromParent()
	end	
	self.allPanels = {}
end


function FactinoMembers.cellSizeForTable(table,idx)
    return 137,718
end

function FactinoMembers.numberOfCellsInTableView(table)
	local self = table.logic
    return self.cellMax
end

function FactinoMembers.tableCellAtIndex(table, idx)

	local self = table.logic
	local cell = table:dequeueCell()
	self.allPanels = self.allPanels or {}
	local panel = nil
	if cell == nil then
	    cell = TFTableViewCell:create()
	    local newIndex = #self.allPanels + 1
	    self.allPanels[newIndex] = cell
		panel = self.cellModel:clone()
		panel:setPosition(ccp(0,0))
		cell:addChild(panel)
		panel:setTag(10086)
	else
		panel = cell:getChildByTag(10086)
	end

	idx = idx + 1
	self:cellInfoSet(cell,panel,idx)

    return cell
end

--added by wuqi
function FactinoMembers:addVipEffect(btn, vipLevel)
    if btn.effect then
        btn.effect:removeFromParent()
        btn.effect = nil
    end
    if vipLevel <= 18 then
    --if vipLevel <= 15 or vipLevel > 18 then -- modify by zr 关掉高VIP特效 -- modify by zr 关掉高VIP特效
        return
    end
    local resPath = "effect/ui/vip_" .. vipLevel .. ".xml"
    TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
    local effect = TFArmature:create("vip_" .. vipLevel .. "_anim")
    effect:setAnimationFps(GameConfig.ANIM_FPS)
    effect:setPosition(ccp(btn:getContentSize().width / 2, btn:getContentSize().height / 2))
    effect:setVisible(true)
    --effect:setScale(0.9)
    effect:playByIndex(0, -1, -1, 1)
    btn:addChild(effect, 200)
    btn.effect = effect
end

function FactinoMembers:cellInfoSet( cell, panel, idx )
	if cell.boundData == nil then
		cell.boundData = true

		cell.headBtn = TFDirector:getChildByPath(panel, "bg")
		cell.imgHead = TFDirector:getChildByPath(panel, "Image_MembersCell_1")
		cell.level = TFDirector:getChildByPath(panel, "txt_level")
		cell.post = TFDirector:getChildByPath(panel, "icon_zhiwei")
		cell.name = TFDirector:getChildByPath(panel, "txt_name")
		cell.vip = TFDirector:getChildByPath(panel, "txt_vip")
		cell.power = TFDirector:getChildByPath(panel, "txt_zhandouli")

		cell.totleDedication = TFDirector:getChildByPath(panel, "txt_leijigongxian")
		cell.todayDedication = TFDirector:getChildByPath(panel, "txt_jinrigongxian")
		cell.offLineTime = TFDirector:getChildByPath(panel, "txt_offlinetime")
		
		cell.btnJjjl = TFDirector:getChildByPath(panel, "Btn_jjjl")
		cell.btnJiejiao = TFDirector:getChildByPath(panel, "Btn_jiejiao")
		cell.btnAppoint = TFDirector:getChildByPath(panel, "Btn_renming")
		cell.btnImpeach = TFDirector:getChildByPath(panel, "Btn_tanghe")
		cell.btnCancelImpeach = TFDirector:getChildByPath(panel, "Btn_quxiaotanghe")
		cell.CancelImpeachTime = TFDirector:getChildByPath(cell.btnCancelImpeach, "txt_time")
		cell.btnImpeachIng = TFDirector:getChildByPath(panel, "Btn_tanghezhong")
		cell.ImpeachIngTime = TFDirector:getChildByPath(cell.btnImpeachIng, "txt_time")
		cell.btnCancelSR = TFDirector:getChildByPath(panel, "Btn_quxiaorenming")
		cell.btnCancelSRTime = TFDirector:getChildByPath(cell.btnCancelSR, "txt_time")

		cell.imgFrame = TFDirector:getChildByPath(panel, "bg_touxiang")
		
		--added by wuqi
		cell.img_vip = TFDirector:getChildByPath(panel, "img_vip")

		cell.btnJjjl:addMEListener(TFWIDGET_CLICK, audioClickfun(self.jjjlButtonClick))		
		cell.btnJiejiao:addMEListener(TFWIDGET_CLICK, audioClickfun(self.jiejiaoButtonClick))
		cell.btnAppoint:addMEListener(TFWIDGET_CLICK, audioClickfun(self.appointButtonClick))
		cell.btnImpeach:addMEListener(TFWIDGET_CLICK, audioClickfun(self.impeachButtonClick))
		cell.btnCancelImpeach:addMEListener(TFWIDGET_CLICK, audioClickfun(self.cancelImpeachButtonClick))
		cell.btnImpeachIng:addMEListener(TFWIDGET_CLICK, audioClickfun(self.btnImpeachIngButtonClick))
		cell.btnCancelSR:addMEListener(TFWIDGET_CLICK, audioClickfun(self.cancelSrButtonClick))

		cell.rightPoint = cell.btnJiejiao:getPosition()
		cell.leftPoint = cell.btnAppoint:getPosition()

		cell.headBtn:setTouchEnabled(true)
		cell.headBtn:addMEListener(TFWIDGET_CLICK,audioClickfun(self.headButtonClick))
		cell.headBtn.logic = self
		cell.btnImpeachIng:setTouchEnabled(false)

		cell.btnJjjl.logic = self
		cell.btnJiejiao.logic = self
		cell.btnAppoint.logic = self
		cell.btnImpeach.logic = self
		cell.btnCancelImpeach.logic = self
		cell.btnImpeachIng.logic = self
		cell.btnCancelSR.logic = self
	end


	cell.btnJjjl.idx = idx
	cell.btnJiejiao.idx = idx
	cell.btnAppoint.idx = idx
	cell.btnImpeach.idx = idx
	cell.btnCancelImpeach.idx = idx
	cell.btnImpeachIng.idx = idx
	cell.btnCancelSR.idx = idx
	cell.headBtn.idx = idx

	cell.btnJjjl:setVisible(false)
	cell.btnJiejiao:setVisible(false)
	cell.btnAppoint:setVisible(false)
	cell.btnImpeach:setVisible(false)
	cell.btnCancelImpeach:setVisible(false)
	cell.btnImpeachIng:setVisible(false)
	cell.btnCancelSR:setVisible(false)

	
	local cellItem = self.memberInfo[idx]
	--print("cellItem = ",cellItem)
	if cellItem == nil then
		return
	end

	if cellItem.playerId == MainPlayer:getPlayerId() then
		--只显示结交奖励按钮
		if self.myInfo.coin > 0 then
			cell.btnJjjl:setVisible(true)
		end
	elseif self.myPost == FactionManager.Leader then
		--我的职位是帮主 需要显示[结交按钮、任命按钮]
		cell.btnJiejiao:setVisible(true)
		cell.btnAppoint:setVisible(true)
		if self.currState == 1 and cellItem.playerId == self.operateId then
			--禅让中
			cell.btnAppoint:setVisible(false)
			cell.btnCancelSR:setVisible(true)
			local currTime = math.floor(self.operateTime/1000) - MainPlayer:getNowtime()
			local timeStr = FactionManager:getTimeString( currTime, 2 )
			cell.btnCancelSRTime:setText(timeStr)
		end
	elseif cellItem.competence == FactionManager.Leader then
		--当前cell显示的为帮主
		cell.btnJiejiao:setVisible(true)		
		if self.canImpeach then
			cell.btnImpeach:setVisible(true)
		else
			cell.btnImpeach:setVisible(false)
		end

		if self.currState == 3 then
			--弹劾中
			cell.btnImpeach:setVisible(false)

			local currTime = math.floor(self.operateTime/1000) - MainPlayer:getNowtime()
			local timeStr = FactionManager:getTimeString( currTime, 2 )
			cell.CancelImpeachTime:setText(timeStr)
			cell.ImpeachIngTime:setText(timeStr)

			if MainPlayer:getPlayerId() == self.operateId then
				cell.btnCancelImpeach:setVisible(true)
			else
				cell.btnImpeachIng:setVisible(true)
			end
		end
	else
		cell.btnJiejiao:setVisible(true)
	end

	--结交按钮处理
	if cell.btnJiejiao:isVisible() then
		if cellItem.level <= MainPlayer:getLevel() then
			cell.btnJiejiao:setVisible(false)
		elseif self.canMakePlayer == false then
			cell.btnJiejiao:setVisible(false)
		elseif FactionManager:isMakePlayerDoneWithID(cellItem.playerId) then
			cell.btnJiejiao:setVisible(false)
		elseif (FactionManager:getMemberMakePlayerTimes(cellItem.playerId) <= 0) then
			cell.btnJiejiao:setVisible(false)
		end
	end
	--自己不能查看自己
	if cellItem.playerId == MainPlayer:getPlayerId() then
		cell.headBtn:setTouchEnabled(false)
		cell.name:setColor(ccc3(145,60,41))
	else
		cell.headBtn:setTouchEnabled(true)
		cell.name:setColor(ccc3(61,61,61))
	end

	local RoleIcon = RoleData:objectByID(cellItem.icon)						--pck change head icon and head icon frame
	cell.imgHead:setTexture(RoleIcon:getIconPath())
	Public:addFrameImg(cell.imgHead,cellItem.headPicFrame)					--end

    cell.vip:setVisible(true)
    cell.img_vip:setVisible(false)

	cell.level:setText(cellItem.level..'d')
	cell.post:setTexture("ui_new/faction/img_cy"..cellItem.competence..".png")
	cell.name:setText(cellItem.name)
	cell.vip:setText("o"..cellItem.vip)
	cell.power:setText(cellItem.power)
	cell.totleDedication:setText(cellItem.totleDedication)
	cell.todayDedication:setText(cellItem.todayDedication)
	
	--added by wuqi
    --local vipLevel = MainPlayer:getVipLevel()
    if cellItem.vip > 15 and cellItem.vip <= 18 then
        cell.vip:setVisible(false)
        cell.img_vip:setVisible(true)
        --self.img_vip:setTexture(self.path_new_vip[vipLevel - 15])
        self:addVipEffect(cell.img_vip, cellItem.vip)
    end

	if cellItem.online then
		--cell.offLineTime:setText('玩家在线')
		cell.offLineTime:setText(localizable.factionInfo_play_online)
	else
		local dTime = MainPlayer:getNowtime() - math.floor(cellItem.lastLoginTime/1000)
		local txtTime = FriendManager:formatTimeToString(dTime)
		cell.offLineTime:setText(txtTime)
	end
	--重新排列按钮位置
	if cell.btnJiejiao:isVisible() then
		cell.btnJiejiao:setPosition(cell.rightPoint)
		cell.btnAppoint:setPosition(cell.leftPoint)
		cell.btnImpeach:setPosition(cell.leftPoint)
		cell.btnCancelImpeach:setPosition(cell.leftPoint)
		cell.btnImpeachIng:setPosition(cell.leftPoint)
		cell.btnCancelSR:setPosition(cell.leftPoint)
	else
		cell.btnAppoint:setPosition(cell.rightPoint)
		cell.btnImpeach:setPosition(cell.rightPoint)
		cell.btnCancelImpeach:setPosition(cell.rightPoint)
		cell.btnImpeachIng:setPosition(cell.rightPoint)
		cell.btnCancelSR:setPosition(cell.rightPoint)
	end

    --added by wuqi
    --vip隐藏
    if SettingManager.TAG_VIP_YINCANG == tonumber(cellItem.vip) then
        cell.vip:setVisible(false)
        cell.img_vip:setVisible(false)
    end
end

function FactinoMembers:refreshData()
	self.myInfo = FactionManager:getPersonalInfo()
	self.memberInfo = FactionManager:getMemberInfo()
	self.myPost = FactionManager:getPostInFaction()
	local factionInfo = FactionManager:getFactionInfo()
	self.currState = factionInfo.state
	self.operateTime = factionInfo.operateTime
	self.operateId = factionInfo.operateId
	self.canImpeach = FactionManager:isCanImpeach()

	print("self.currState = ",self.currState)

	--self.canMakePlayer = FactionManager:isTimesToMakePlayer()
	self.cellMax = #self.memberInfo
	
	local maxTimes = FactionManager:getTotalMakePlayerTimes()
	local currTimes = FactionManager:getCurrMakePlayerTimes()
	currTimes = maxTimes - currTimes
	--self.txt_times:setText(currTimes.."次")
	self.txt_times:setText(stringUtils.format(localizable.common_times,currTimes))
	if currTimes > 0 then
		self.canMakePlayer = true
	else
		self.canMakePlayer = false
	end
end

function FactinoMembers.jjjlButtonClick( btn )
	FactionManager:requestCoin()
end
function FactinoMembers.jiejiaoButtonClick( btn )
	local item = btn.logic.memberInfo[btn.idx]
	FactionManager:makePlayerIdSet( item.playerId )
end

function FactinoMembers.appointButtonClick( btn )
	local item = btn.logic.memberInfo[btn.idx]
	FactionManager:AppointPlayerIdSet( item.playerId )
end

function FactinoMembers.impeachButtonClick( btn )
	local info = FactionManager:getFactionInfo()
	if info.state == 1 then
		--toastMessage("帮主正在禅让")
		toastMessage(localizable.factionInfo_text1)
	elseif info.state == 2 then
		--toastMessage("帮派正在解散")
		toastMessage(localizable.factionInfo_text1)
	elseif info.state == 3 then	
		--toastMessage("帮主正在被弹劾")	
		toastMessage(localizable.factionInfo_text1)	
	elseif FactionManager:isCanImpeach() then

	    --local msg = "弹劾需要24小时,成功后将成为帮主,是否消耗500元宝进行弹劾？\n（失败后会全额返还）"
	    local msg = localizable.factionMembers_taihe
	    CommonManager:showOperateSureLayer(
	        function()
	        	if MainPlayer:getSycee() < 500 then
	        		--toastMessage("元宝不够")
	        		toastMessage(localizable.common_no_yuanbao)
	        	else
	            	FactionManager:requestAppoint(OperateType.Impeach, MainPlayer:getPlayerId())
	            end
	        end,
	        function()
	            AlertManager:close()
	        end,
	        {
	        --title = "弹劾",
	        title = localizable.factionMembers_taihe_title,
	        msg = msg,
	        }
	    )
		
	else
		--toastMessage("帮主离线不足7天")
		toastMessage(localizable.factionMembers_taihe_conditidon)
	end
end

function FactinoMembers.cancelImpeachButtonClick( btn )
    --local msg = "是否中断弹劾？\n(强制中断会扣除一半元宝)"
    local msg = localizable.factionMembers_taihe_stop
    CommonManager:showOperateSureLayer(
        function()
			local info = FactionManager:getFactionInfo()
			local delayTime = math.floor(info.operateTime/1000) - MainPlayer:getNowtime()
			if info.state == 0 then
				toastMessage(localizable.factionMembers_taihe_suc)
				--toastMessage("你已经弹劾成功")
			elseif delayTime <= 0 then
				--toastMessage("弹劾时间已过期")
				toastMessage(localizable.factionMembers_taihe_timeout)
				FactionManager:requestMemberInfo()
			else
				FactionManager:requestAppoint(OperateType.cancelImpeach, MainPlayer:getPlayerId())
			end        	
        end,
        function()
            AlertManager:close()
        end,
        {
        --title = "终止弹劾",
        title = localizable.factionMembers_stop,
        msg = msg,
        }
    )
end
function FactinoMembers.btnImpeachIngButtonClick( btn )
end
function FactinoMembers.cancelSrButtonClick( btn )
	local info = FactionManager:getFactionInfo()
    local currTime = math.floor(info.operateTime/1000) - MainPlayer:getNowtime()

    local subText = FactionManager:getTimeStringChinese( currTime )

    --local msg = "帮主之位将在"..subText.."后\n禅让，是否终止？"
    local msg = stringUtils.format(localizable.factionMembers_chanrang_tips,subText)
    CommonManager:showOperateSureLayer(
        function()
			local info = FactionManager:getFactionInfo()
			local delayTime = math.floor(info.operateTime/1000) - MainPlayer:getNowtime()
			if info.state == 0 then
				--toastMessage("你已经禅让成功")
				toastMessage(localizable.factionMembers_chanrang_suc)
			elseif delayTime <= 0 then
				--toastMessage("禅让时间已过期")
				toastMessage(localizable.factionMembers_chanrang_timeout)
				FactionManager:requestMemberInfo()
			else        	
	        	local item = btn.logic.memberInfo[btn.idx]
				FactionManager:requestAppoint(OperateType.cancelDemise, item.playerId)
			end
        end,
        function()
            AlertManager:close()
        end,
        {
        --title = "取消禅让",
        title = localizable.factionMembers_chanrang_stop,
        msg = msg,
        }
    )
end
function FactinoMembers.headButtonClick(btn)
	local player = btn.logic.memberInfo[btn.idx]

    local info = {}
    info.profession = player.profession
    info.level = player.level
    info.name = player.name
    info.vip = player.vip
    info.power = player.power
    info.lastLoginTime = player.lastLoginTime
    info.playerId = player.playerId
    info.online = player.online
    info.icon = player.icon 						--pck change head icon and head icon frame
    info.headPicFrame = player.headPicFrame			--end

	local layer = require("lua.logic.friends.FriendInfoLayer"):new(1)
	AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY_CLOSE, AlertManager.TWEEN_1)
	layer:setInfo(info)
	AlertManager:show()
	    
	-- local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.friends.FriendInfoLayer", AlertManager.BLOCK_AND_GRAY_CLOSE, AlertManager.TWEEN_1)
 --    layer:setInfo(info)
 --    AlertManager:show();

	--OtherPlayerManager:showOtherPlayerdetails(player.playerId, "overview")
end

function FactinoMembers:refreshWindow()
	self:refreshData()
	self.TabView:reloadData()
	if self.tableViewNeedInit then
		self.tableViewNeedInit = false
		self.TabView:setScrollToBegin()
	end
end
function FactinoMembers:refreshWindowAndClose()
	
end

return FactinoMembers