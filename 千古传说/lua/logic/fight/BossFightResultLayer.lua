
local BossFightResultLayer = class("BossFightResultLayer", BaseLayer)

TipsList    = require("lua.table.t_s_help_tips")

function BossFightResultLayer:ctor(data)
    self.super.ctor(self,data)
    self:init("lua.uiconfig_mango_new.demond.Fightresult")
end

function GetRoleMaxHp(posindex)
	for k,v in pairs(FightManager.fightBeginInfo.rolelist) do
		if v.posindex == posindex then
			return v.attr[1]
		end
	end
	return 0
end

function BossFightResultLayer:initUI(ui)
	self.super.initUI(self,ui)

	self.fightResultInfo = FightManager.fightResultInfo

	self.replayBtn = TFDirector:getChildByPath(ui, 'replayBtn')
	self.leaveBtn = TFDirector:getChildByPath(ui, 'leaveBtn')
	self.btn_shtj = TFDirector:getChildByPath(ui, 'btn_shtj')
	self.panel_shtj = TFDirector:getChildByPath(ui, 'panel_shtj')
	self:ShowButton(false)

	self.rewardPanel = TFDirector:getChildByPath(self.ui, 'rewardPanel')
	-- self.rewardPanel:setVisible(false)

	self.txt_hurt = TFDirector:getChildByPath(ui, 'txt_hurt')
	self.img_boss = TFDirector:getChildByPath(ui, 'img_boss')
	self.panel_boss = TFDirector:getChildByPath(ui, 'Panel_boss')
	self.boss_say = TFDirector:getChildByPath(ui, 'txt')

	self.btnPos = {}
	self.btnPos[1] = {}
	self.btnPos[2] = {}
	self.btnPos[1].x =  self.replayBtn:getPosition().x
	self.btnPos[1].y =  self.replayBtn:getPosition().y
	self.btnPos[2].x =  self.leaveBtn:getPosition().x
	self.btnPos[2].y =  self.leaveBtn:getPosition().y

	self.panel_shtj_pos = {}
	self.panel_shtj_pos.x =  self.panel_shtj:getPosition().x
	self.panel_shtj_pos.y =  self.panel_shtj:getPosition().y
	self:PlaySoundEffect()

	self:ShowRewardPanel()

	local fightType = FightManager.fightBeginInfo.fighttype
	if fightType == 10 then
		local liveList = FightManager.lastEndFightMsg[4]
		print("liveList = ",liveList)
		local hurt_total = 0
		for i=1,#liveList do
			local liveInfo = liveList[i]
			if liveInfo[1] >= 9  then
				local maxHp = GetRoleMaxHp(liveInfo[1])
				local currhp = liveInfo[2]
				hurt_total = hurt_total + maxHp - currhp
			end
		end
		-- print("fuck dwk",hurt_total)
		self.txt_hurt:setText(hurt_total)

		local dayIndexOfWeek = os.date("%w",MainPlayer:getNowtime())
		local bossData = BossFightManager:findBossWithDayIndex(dayIndexOfWeek)
		if bossData then
			self.img_boss:setVisible(true)
			self.img_boss:setTexture("ui_new/demond/".. bossData.fightresult)
			-- local armatureID = bossData.fightresult
			-- self:addArmature(armatureID)

			self.boss_say:setText(bossData.result_talk)
		end
		self.replayBtn:setVisible(false)
	elseif fightType == 17 then
		-- local chapterInfo = HoushanManager:getHoushanChapterAndBossId()
		local data = GuildZoneCheckPointData:GetInfoByZoneIdAndPoint(HoushanManager.chapter ,HoushanManager.bossIndex)
		if data == nil then
			print("boss 信息有误===",HoushanManager.chapter ,HoushanManager.bossIndex)
			return
		end
		-- self.img_boss:setTexture("icon/rolebig/".. data.rolebig..".png")
		local armatureID = data.rolebig
		self:addArmature(armatureID)

		local winType = self.fightResultInfo.rank
		if winType == 1 or winType == 2 then
			self.boss_say:setText(data.win)
		else
			self.boss_say:setText(data.lost)
		end
		self.txt_hurt:setText(self.fightResultInfo.climblev)
		self.replayBtn:setVisible(false)
		self.leaveTimer = TFDirector:addTimer(20000,1,nil,function ()
			if self.leaveTimer then
				TFDirector:removeTimer(self.leaveTimer)
				self.leaveTimer = nil	
			end
			FightManager:LeaveFight()
			TFDirector:dispatchGlobalEventWith(FightManager.FactionBossFightLeave,{});
		end)

		TFDirector:dispatchGlobalEventWith(FightManager.FactionBossFightResult,{});
	end
end

function BossFightResultLayer:addArmature(armatureID)
    if self.armature then
        self.armature:removeFromParent()
    end
    print("------------------------->", armatureID)
    ModelManager:addResourceFromFile(1, armatureID, 1)
    self.armature = ModelManager:createResource(1, armatureID)
    self.panel_boss:addChild(self.armature)
    ModelManager:playWithNameAndIndex(self.armature, "stand", -1, 1, -1, -1)
end

function BossFightResultLayer:removeUI()
	if self.updateTimerID ~= nil then
		TFDirector:removeTimer(self.updateTimerID)
	end

	self.super.removeUI(self)
end

function BossFightResultLayer:registerEvents()	
	self.super.registerEvents(self)

	self.replayBtn:addMEListener(TFWIDGET_CLICK, audioClickfun(self.relayClickHandle),1)
	self.leaveBtn.logic = self
	self.leaveBtn:addMEListener(TFWIDGET_CLICK, audioClickfun(self.leaveBtnHandle),1)


	self.btn_shtj:addMEListener(TFWIDGET_CLICK, audioClickfun(self.hurtCountClickHandle),1)
	
	self.ui:setTouchEnabled(true)
	self.ui:addMEListener(TFWIDGET_CLICK, audioClickfun(function() self:uiClickHandle() end))

	ADD_KEYBOARD_CLOSE_LISTENER(self, self.ui)
end

function BossFightResultLayer:removeEvents()	
	self.super.removeEvents(self)
	if self.leaveTimer then
		TFDirector:removeTimer(self.leaveTimer)
		self.leaveTimer = nil	
	end

end

function BossFightResultLayer:PlaySoundEffect()
	local nResult = self.fightResultInfo.result
	if nResult == 0 then
		TFAudio.playEffect("sound/effect/fight_fail.mp3", false)
	else
		TFAudio.playEffect("sound/effect/fight_win.mp3", false)
	end
end


function BossFightResultLayer:ShowButton(bVisible)
	-- print("BossFightResultLayer:ShowButton(bVisible) ========")
	if not bVisible then
		self.replayBtn:setVisible(false)
		self.leaveBtn:setVisible(false)
		self.panel_shtj:setVisible(false)
	else
		if not self.leaveBtn:isVisible() then
			local btnList = {self.replayBtn, self.leaveBtn}
			for i=1,2 do
				local btn = btnList[i]
				btn:setVisible(true)
				btn:setOpacity(50)
				local btnPos = btn:getPosition()
				btn:setPosition(ccp(self.btnPos[i].x, self.btnPos[i].y-80))
				local btnTween = 
				{
					target = btn,
					{
						duration = 0.3,
						x = self.btnPos[i].x,
						y = self.btnPos[i].y,
						alpha = 255,

						onComplete =  function ()
							btn:setTouchEnabled(true)
						end
					},
				}
				btn:setTouchEnabled(false)
				TFDirector:toTween(btnTween)
			end
		end
		if not self.panel_shtj:isVisible() then
			local btn = self.panel_shtj
			btn:setVisible(true)
			btn:setOpacity(50)
			local btnPos = btn:getPosition()
			btn:setPosition(ccp(self.panel_shtj_pos.x - 160, self.panel_shtj_pos.y))
			local btnTween = 
			{
				target = btn,
				{
					duration = 0.3,
					x = self.panel_shtj_pos.x,
					y = self.panel_shtj_pos.y,
					alpha = 255,

					onComplete =  function ()
						btn:setTouchEnabled(true)
					end
				},
			}
			btn:setTouchEnabled(false)
			TFDirector:toTween(btnTween)
		end
	end
end


function BossFightResultLayer:ShowRewardPanel()
	for i=1,5 do
		local itemQualityImg = TFDirector:getChildByPath(self.ui, "itemImg"..i)
		itemQualityImg:setVisible(false)
	end
	
	local itemRewardBg = TFDirector:getChildByPath(self.ui, "itemRewardBg")
	if itemRewardBg == nil then
		return
	end

	local resCount = self:ShowRewardRes()
	local itemCount = self:ShowRewardItem()
	if itemCount > 0 then
		self:PlayItemEffect(1)
	end

	if resCount == 0 and itemCount == 0 then
		itemRewardBg:setVisible(false)
	else
		itemRewardBg:setVisible(true)
	end

	self:ShowButton(true)
end

function BossFightResultLayer:PlayItemEffect(itemIndex)
	local itemQualityImg = TFDirector:getChildByPath(self.ui, "itemImg"..itemIndex)
	if itemQualityImg == nil or itemQualityImg:isVisible() == false then
		return
	end

	local effectName = "fightitem"
	TFResourceHelper:instance():addArmatureFromJsonFile("effect/"..effectName..".xml")
	local effect = TFArmature:create(effectName.."_anim")
	effect:setAnimationFps(GameConfig.ANIM_FPS)
	effect:playByIndex(0, -1, -1, 0)
	effect:setZOrder(100)
	effect:setPosition(ccp(40, 40))
	itemQualityImg:addChild(effect)

	effect:addMEListener(TFARMATURE_COMPLETE, function()
		self:PlayItemEffect(itemIndex+1)
		effect:removeFromParent()
	end)
end

function BossFightResultLayer:ShowRewardRes()
	local resCount = 0
	if self.fightResultInfo.reslist ~= nil then
		resCount = #self.fightResultInfo.reslist
	end

	self.itemIndex = 1

	for i=1,resCount do
		local resInfo = self.fightResultInfo.reslist[i]
		local itemQualityImg = TFDirector:getChildByPath(self.ui, "itemImg"..i)
		local itemIcon = TFDirector:getChildByPath(itemQualityImg, "itemIcon")

		itemQualityImg:setTexture(GetResourceQualityBG82(resInfo.type))
		itemQualityImg:setVisible(true)
		local resIconImg = GetResourceIcon(resInfo.type)
		itemIcon:setTexture(resIconImg)
		itemIcon:setScale(1.2)
		itemQualityImg:setVisible(true)
		itemIcon:setTouchEnabled(true)
		itemIcon:addMEListener(TFWIDGET_CLICK,
		audioClickfun(function()
			Public:ShowItemTipLayer(resInfo.itemid, resInfo.type, resInfo.num)
		end))

		local numLabel = TFLabelBMFont:create()
        numLabel:setFntFile("font/new/num_lv.fnt")
        numLabel:setScale(0.7)
        numLabel:setPosition(ccp(0, -50))
        itemQualityImg:addChild(numLabel)
        numLabel:setText("X"..resInfo.num)

        self.itemIndex = self.itemIndex + 1

	end

	return resCount
end

function BossFightResultLayer:ShowRewardItem()
	local itemCount = 0
	if self.fightResultInfo.itemlist ~= nil then
		itemCount = #self.fightResultInfo.itemlist
	end

	for i=1,itemCount do
		local itemQualityImg = TFDirector:getChildByPath(self.ui, "itemImg"..self.itemIndex)
		itemQualityImg:setVisible(true)
		self.itemIndex = self.itemIndex + 1

		local itemIcon = TFDirector:getChildByPath(itemQualityImg, "itemIcon")
		itemIcon:setScale(0.7)

		local itemInfo = self.fightResultInfo.itemlist[i]
		if itemInfo.type == 1 then
			local itemData = ItemData:objectByID(itemInfo.itemid)
			if itemData ~= nil then
				itemQualityImg:setTexture(GetColorIconByQuality_82(itemData.quality))
				itemIcon:setTexture(itemData:GetPath())
				itemIcon:setTouchEnabled(true)
				itemIcon:addMEListener(TFWIDGET_CLICK,
			    audioClickfun(function()
			        Public:ShowItemTipLayer(itemInfo.itemid, itemInfo.type)
			    end))

			    local numLabel = TFLabelBMFont:create()
			    numLabel:setFntFile("font/new/num_lv.fnt")
			    numLabel:setScale(0.7)
			    numLabel:setPosition(ccp(0, -50))
			    itemQualityImg:addChild(numLabel)
			    numLabel:setText("X"..itemInfo.num)
			end

			Public:addPieceImg(itemIcon, itemInfo)
			
		elseif itemInfo.type == 2 then
			local cardData = RoleData:objectByID(itemInfo.itemid)
			if cardData ~= nil then
				itemQualityImg:setTexture(GetColorIconByQuality_82(cardData.quality))
				itemIcon:setTexture(cardData:getIconPath())
				itemIcon:setTouchEnabled(true)
				itemIcon:addMEListener(TFWIDGET_CLICK,
			    audioClickfun(function()
			        Public:ShowItemTipLayer(itemInfo.itemid, itemInfo.type)
			    end))

			    local numLabel = TFLabelBMFont:create()
			    numLabel:setFntFile("font/new/num_lv.fnt")
			    numLabel:setScale(0.7)
			    numLabel:setPosition(ccp(0, -50))
			    itemQualityImg:addChild(numLabel)
			    numLabel:setText("X"..itemInfo.num)
			end
		end


        --秘籍添加红点 king
    	CommonManager:setRedPoint(itemIcon, MartialManager:dropRewardRedPoint(itemInfo), "dropRewardRedPoint", ccp(10,10))
	end

	return itemCount
end

function BossFightResultLayer:uiClickHandle()
	self:ShowRewardPanel()
end

function BossFightResultLayer.relayClickHandle(btn)
	FightManager:ReplayFight()
end

function BossFightResultLayer.leaveBtnHandle(btn)
	local self = btn.logic

	local winType	 = self.fightResultInfo.rank
	local fightType  = FightManager.fightBeginInfo.fighttype

	-- if fightType == 17 and winType == 0 then
	if fightType == 17 then
		TFDirector:dispatchGlobalEventWith(FightManager.FactionBossFightWin,{win = winType});
	end

	FightManager:LeaveFight()
end

function BossFightResultLayer.hurtCountClickHandle(btn)
	FightManager:openHurtCount()
end

return BossFightResultLayer
