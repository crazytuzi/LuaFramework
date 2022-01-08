--[[
	跨服个人战入口
	by quanhuan
	2016/4/19
]]

local KuaFuEntrance = class("KuaFuEntrance",BaseLayer)

function KuaFuEntrance:ctor(data)
	self.super.ctor(self, data)
	self:init("lua.uiconfig_mango_new.kuafuwulin.KuaFuEntrance")
	
	MultiServerFightManager:requestPreviousCrossInfo(false)
end

function KuaFuEntrance:initUI( ui )
	self.super.initUI(self, ui)

	self.panel_no_open = TFDirector:getChildByPath(ui,"panel_weikaiqi") --还没有记录战  虚席以待
	self.panel_open = TFDirector:getChildByPath(ui,"panel_kaiqi") --上一届获胜队伍
	self.panel_open_condition = TFDirector:getChildByPath(ui,"img_kaiqi")
	self.btn_apply = TFDirector:getChildByPath(ui,"btn_baoming")
end

function KuaFuEntrance:createTestData()
    self.testData ={}
   
end



function KuaFuEntrance:removeUI()
   	self.super.removeUI(self)
   
end

function KuaFuEntrance:onShow()
    self.super.onShow(self)

    -- if self.requestMsg == nil then
    -- 	self.requestMsg = true
    -- 	self:dataReady()
    -- end
end

function KuaFuEntrance:registerEvents()
	self.super.registerEvents(self)
    
    self.btn_apply:addMEListener(TFWIDGET_CLICK,audioClickfun(self.onBtnApply))

    self.updatePreviousCrossInfoCallBack = function (event)
        self:showDetailsInfo() 
    end
    TFDirector:addMEGlobalListener(MultiServerFightManager.updatePreviousCrossInfo, self.updatePreviousCrossInfoCallBack)
end

function KuaFuEntrance:removeEvents()

    self.btn_apply:removeMEListener(TFWIDGET_CLICK)

    if self.updatePreviousCrossInfoCallBack then
        TFDirector:removeMEGlobalListener(MultiServerFightManager.updatePreviousCrossInfo, self.updatePreviousCrossInfoCallBack)    
        self.updatePreviousCrossInfoCallBack = nil
    end 
    if self.roleAnimId then
        for k,v in pairs(self.roleAnimId) do
            GameResourceManager:deleRoleAniById(v)
        end
        self.roleAnimId = nil
    end

    self.super.removeEvents(self)
end

function KuaFuEntrance:dispose()
    self.super.dispose(self)
end


function KuaFuEntrance.onBtnApply()
    MultiServerFightManager:openCurrLayer()
end

function KuaFuEntrance:dataReady()
	
end

function KuaFuEntrance:showDetailsInfo()
	local state = MultiServerFightManager:getActivityState()
	local winner = MultiServerFightManager:getPreviousCrossInfo()
	print('-------------跨服战状态----------------------',state)
	print('-------------跨服战状态----------------------',state)
	print('-------------跨服战状态----------------------',state)

	if state == MultiServerFightManager.ActivityState_0 then
		self.panel_no_open:setVisible(true)
		self.panel_open:setVisible(false)		
		self.btn_apply:setVisible(false)
	elseif winner.name == nil then
		self.panel_no_open:setVisible(true)
		self.panel_open:setVisible(false)		
		self.btn_apply:setVisible(true)
	else
		self.panel_no_open:setVisible(false)
		self.panel_open:setVisible(true)
		self.btn_apply:setVisible(true)

		--跨服冠军
		local panelGjNode = TFDirector:getChildByPath(self.panel_open,"panel_gj")
		local txtServerName = TFDirector:getChildByPath(panelGjNode, "txt_name")
		if winner.serverName then
			txtServerName:setVisible(true)
			txtServerName:setText(winner.serverName)
		else
			txtServerName:setVisible(false)
		end
		local txtPlayerName = TFDirector:getChildByPath(panelGjNode, "txt_servername")
		if winner.name then
			txtPlayerName:setVisible(true)
			txtPlayerName:setText(winner.name)
		else
			txtPlayerName:setVisible(false)
		end
		local txtPower = TFDirector:getChildByPath(panelGjNode, "txt_zhandouli")
		if winner.power then
			txtPower:setVisible(true)
			txtPower:setText(winner.power)
		else
			txtPower:setVisible(false)
		end

		local icon_head = TFDirector:getChildByPath(panelGjNode, "icon_head")
		local RoleIcon = RoleData:objectByID(winner.useCoin)
		if RoleIcon then
			icon_head:setTexture(RoleIcon:getIconPath())
			Public:addFrameImg(icon_head,winner.framId)
		end

		self.roleAnimId = {}
		for i=1,5 do
			local playerNode = TFDirector:getChildByPath(panelGjNode, "role"..i)
			playerNode:setVisible(false)
		end
		if self.roleAnimTbl then
			for k,v in pairs(self.roleAnimTbl) do
				v:removeFromParent()
			end
			self.roleAnimTbl = nil
		end
		
		local roleTable = stringToNumberTable(winner.formation,",")
		for k,v in pairs(roleTable) do
			self:showRoleAnim(panelGjNode, k,v)
		end	

		--本服冠军
		local panelBfNode = TFDirector:getChildByPath(self.panel_open,"panel_bf")
		-- local txtServerName1 = TFDirector:getChildByPath(panelBfNode, "txt_servername")
		-- if winner.serverServerName then
		-- 	txtServerName1:setVisible(true)
		-- 	txtServerName1:setText(winner.serverServerName)
		-- else
		-- 	txtServerName1:setVisible(false)
		-- end
		local txtRank1 = TFDirector:getChildByPath(panelBfNode, "txt_paiming")
		if winner.serverRank then
			txtRank1:setText(stringUtils.format(localizable.multiFight_myRank, winner.serverRank))
			txtRank1:setVisible(true)
		else
			txtRank1:setVisible(false)
		end
		local txtPlayerName1 = TFDirector:getChildByPath(panelBfNode, "txt_name")
		if winner.serverPlayerName then
			txtPlayerName1:setText(winner.serverPlayerName)
			txtPlayerName1:setVisible(true)
		else
			txtPlayerName1:setVisible(false)
		end
		local txtPower1 = TFDirector:getChildByPath(panelBfNode, "txt_zhandouli")
		if winner.serverPower then
			txtPower1:setText(winner.serverPower)
			txtPower1:setVisible(true)
		else
			txtPower1:setVisible(false)
		end
		local txtHeadIcon = TFDirector:getChildByPath(panelBfNode, "icon_head")
		local RoleIcon1 = RoleData:objectByID(winner.serverUseCoin)
		if RoleIcon1 then
			txtHeadIcon:setVisible(true)
			txtHeadIcon:setTexture(RoleIcon1:getIconPath())
			Public:addFrameImg(txtHeadIcon,winner.serverFramId)
		else
			txtHeadIcon:setVisible(false)
		end
	end
end

function KuaFuEntrance:showRoleAnim( node, posIdx, roleId )
	
	local playerNode = TFDirector:getChildByPath(node, "role"..posIdx)   
	playerNode:setVisible(true)

    local idx = #self.roleAnimId + 1
    local roleAnim = GameResourceManager:getRoleAniById(roleId)
    roleAnim:setPosition(ccp(0,0))
    roleAnim:play("stand", -1, -1, 1)                
    playerNode:addChild(roleAnim)

    self.roleAnimTbl = self.roleAnimTbl or {}
    self.roleAnimTbl[#self.roleAnimTbl + 1] = roleAnim
            
    self.roleAnimId[idx] = roleId
        -- 加阴影
    TFResourceHelper:instance():addArmatureFromJsonFile("effect/main_role2.xml")
    local effect2 = TFArmature:create("main_role2_anim")
    if effect2 ~= nil then
        effect2:setAnimationFps(GameConfig.ANIM_FPS)
        effect2:playByIndex(0, -1, -1, 1)
        effect2:setZOrder(-1)
        effect2:setPosition(ccp(0, -20))
        roleAnim:addChild(effect2)
    end	
end

return KuaFuEntrance