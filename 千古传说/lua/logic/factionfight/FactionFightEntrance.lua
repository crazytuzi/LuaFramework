--region 
--帮派争霸赛入口
local FactionFightEntrance = class("FactionFightEntrance",BaseLayer)

function FactionFightEntrance:ctor(data)
	self.super.ctor(self, data)
	self:init("lua.uiconfig_mango_new.faction.FactionFightEntrance")

	FactionFightManager:requestWinnerResult()
end

function FactionFightEntrance:initUI( ui )
	self.super.initUI(self, ui)

	self.panel_no_open = TFDirector:getChildByPath(ui,"panel_weikaiqi") --还没有帮派战  虚席以待
	self.panel_open = TFDirector:getChildByPath(ui,"panel_kaiqi") --上一届获胜队伍

	self.panel_open_condition = TFDirector:getChildByPath(ui,"img_kaiqi1") --开启帮派战条件
	self.panel_join_condition = TFDirector:getChildByPath(ui,"img_kaiqi2") --帮派战开启后，参加条件

	self.icon_battletime1 = TFDirector:getChildByPath(ui, "icon_battletime1")
	self.icon_battletime2 = TFDirector:getChildByPath(ui, "icon_battletime2")

	self.open_condition ={}
	for i=1,3 do
		self.open_condition[i] ={}
		self.open_condition[i].node = TFDirector:getChildByPath(self.panel_open_condition,"img_ditu"..i)
		self.open_condition[i].loadbar =TFDirector:getChildByPath(self.open_condition[i].node,"load_bar")
		self.open_condition[i].loadbar:setPercent(i*10) 
		self.open_condition[i].txt_condition =TFDirector:getChildByPath(self.open_condition[i].node,"txt_tiaojian3") 
		self.open_condition[i].txt_condition:setText("*"..i..")")
		self.open_condition[i].txt_condition_num =TFDirector:getChildByPath(self.open_condition[i].node,"txt_tiaojian3_num") 
		self.open_condition[i].txt_condition_num:setText("0"..i)
		self.open_condition[i].txt_condition_numEx =TFDirector:getChildByPath(self.open_condition[i].node,"txt_tiaojian4_num") 
		self.open_condition[i].txt_condition_numEx:setVisible(false)
	end


	self.btn_apply = TFDirector:getChildByPath(ui,"btn_baoming")
end

function FactionFightEntrance:createTestData()
    self.testData ={}
   
end



function FactionFightEntrance:removeUI()
   	self.super.removeUI(self)
   
end

function FactionFightEntrance:onShow()
    self.super.onShow(self)

    -- if self.requestMsg == nil then
    -- 	self.requestMsg = true
    -- 	self:dataReady()
    -- end
end

function FactionFightEntrance:registerEvents()
	self.super.registerEvents(self)
    
    self.btn_apply:addMEListener(TFWIDGET_CLICK,audioClickfun(self.onBtnApply))

    self.winnerInfoUpdateCallBack = function (event)
        self:showDetailsInfo() 
    end
    TFDirector:addMEGlobalListener(FactionFightManager.winnerInfoUpdate, self.winnerInfoUpdateCallBack)
end

function FactionFightEntrance:removeEvents()

    self.btn_apply:removeMEListener(TFWIDGET_CLICK)

    if self.winnerInfoUpdateCallBack then
        TFDirector:removeMEGlobalListener(FactionFightManager.winnerInfoUpdate, self.winnerInfoUpdateCallBack)    
        self.winnerInfoUpdateCallBack = nil
    end 
    if self.roleAnimId then
        for k,v in pairs(self.roleAnimId) do
            GameResourceManager:deleRoleAniById(v)
        end
        self.roleAnimId = nil
    end

    self.super.removeEvents(self)
end

function FactionFightEntrance:dispose()
    self.super.dispose(self)
end


function FactionFightEntrance.onBtnApply()
     print("onBtnApply")
     FactionFightManager:openCurrLayer()
end

function FactionFightEntrance:dataReady()
	
end

function FactionFightEntrance:showDetailsInfo()
	local state = FactionFightManager:getActivityState()
	local winner = FactionFightManager:getWinnerInfo()
	-- print('winner = ',winner)
	-- winner.maxGuildLevel = 2
	-- winner.guildSize = 10
	-- winner.openTime = MainPlayer:getNowtime()*1000
	-- state = FactionFightManager.ActivityState_0

	if state == FactionFightManager.ActivityState_1 then
		self.icon_battletime1:setVisible(true)
	else
		self.icon_battletime1:setVisible(false)
	end

	if state == FactionFightManager.ActivityState_3 then
		self.icon_battletime2:setVisible(true)
	else
		self.icon_battletime2:setVisible(false)
	end
	
	if state == FactionFightManager.ActivityState_0 then
		self.panel_open_condition:setVisible(true)
		self.panel_no_open:setVisible(true)
		self.panel_open:setVisible(false)
		self.panel_join_condition:setVisible(false)
		
		local openTime = MainPlayer:getNowtime() - math.floor(winner.openTime/1000)
		openTime = math.floor(openTime/(24*60*60))
		local minCondition = {winner.maxGuildLevel, winner.guildSize, openTime}
		local maxCondition = {4, 16, 30}
		for k,v in pairs(self.open_condition) do
			local percent = math.floor(minCondition[k]*100/maxCondition[k])
			if percent > 100 then
				percent = 100
			end
			v.loadbar:setPercent(percent)
			v.txt_condition_num:setText(minCondition[k])
			v.txt_condition:setText("/"..maxCondition[k]..")")
			v.txt_condition_numEx:setText(minCondition[k])

			if percent >= 100 then
				v.txt_condition_numEx:setVisible(true)				
				v.txt_condition_num:setVisible(false)
			else
				v.txt_condition_numEx:setVisible(false)
				v.txt_condition_num:setVisible(true)
			end

		end
		self.btn_apply:setVisible(false)
	elseif winner.guildId == 0 then
		self.panel_no_open:setVisible(true)
		self.panel_open:setVisible(false)
		self.panel_open_condition:setVisible(false)
		self.panel_join_condition:setVisible(true)
		self.btn_apply:setVisible(true)
	else
		self.panel_no_open:setVisible(false)
		self.panel_open:setVisible(true)
		self.panel_open_condition:setVisible(false)
		self.panel_join_condition:setVisible(true)
		self.btn_apply:setVisible(true)

		--panel_open
		local Img_nobody = TFDirector:getChildByPath(self.panel_open,"Img_nobody")
		Img_nobody:setVisible(false)

		local bannerBg = TFDirector:getChildByPath(self.panel_open,"img_qizhi")
		bannerBg:setTexture(FactionManager:getGuildBannerBgPath(winner.bannerId))

		local bannerIcon = TFDirector:getChildByPath(self.panel_open,"img_biaozhi")
		bannerIcon:setTexture(FactionManager:getGuildBannerIconPath(winner.bannerId))

		local guildNode = TFDirector:getChildByPath(self.panel_open,"bg_name4")
		local guildName = TFDirector:getChildByPath(guildNode,"txt_name")
		guildName:setText(winner.guildName)

		self.roleAnimId = {}
		for i=1,3 do
			local playerNode = TFDirector:getChildByPath(self.panel_open, "rolePos"..i)
			local playerName = TFDirector:getChildByPath(playerNode, "txt_name")
			playerNode:setVisible(false)
		end
		if self.roleAnimTbl then
			for k,v in pairs(self.roleAnimTbl) do
				v:removeFromParent()
			end
			self.roleAnimTbl = nil
		end
		
		if winner.professions then
			if #winner.professions == 1 then
				self:showRoleAnim(2,winner.professions[1],winner.names[1])
			elseif #winner.professions == 2 then
				self:showRoleAnim(1,winner.professions[1],winner.names[1])
				self:showRoleAnim(3,winner.professions[2],winner.names[2])
			else
				self:showRoleAnim(1,winner.professions[1],winner.names[1])
				self:showRoleAnim(2,winner.professions[2],winner.names[2])
				self:showRoleAnim(3,winner.professions[3],winner.names[3])
			end
		end
	end
end

function FactionFightEntrance:showRoleAnim( posIdx, professions, name )
	
	local playerNode = TFDirector:getChildByPath(self.panel_open, "rolePos"..posIdx)
	local playerName = TFDirector:getChildByPath(playerNode, "txt_name")
    if posIdx == 2 then
		playerNode:setZOrder(100)
    end

	playerName:setText(name)
	playerNode:setVisible(true)

    local idx = #self.roleAnimId + 1
    local roleAnim = GameResourceManager:getRoleAniById(professions)
    roleAnim:setPosition(ccp(0,0))
    roleAnim:play("stand", -1, -1, 1)                
    playerNode:addChild(roleAnim)

    self.roleAnimTbl = self.roleAnimTbl or {}
    self.roleAnimTbl[#self.roleAnimTbl + 1] = roleAnim
            
    self.roleAnimId[idx] = professions
        -- 加阴影
    TFResourceHelper:instance():addArmatureFromJsonFile("effect/main_role2.xml")
    local effect2 = TFArmature:create("main_role2_anim")
    if effect2 ~= nil then
        effect2:setAnimationFps(GameConfig.ANIM_FPS)
        effect2:playByIndex(0, -1, -1, 1)
        effect2:setZOrder(-1)
        effect2:setPosition(ccp(0, -10))
        roleAnim:addChild(effect2)
    end	
end

return FactionFightEntrance