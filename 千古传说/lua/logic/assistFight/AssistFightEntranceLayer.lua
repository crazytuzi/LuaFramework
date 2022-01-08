--[[
******助战入口*******

	-- by quanhuan
	-- 2015/11/25
]]

local AssistFightEntranceLayer = class("AssistFightEntranceLayer",BaseLayer)

function AssistFightEntranceLayer:ctor(data)
	self.super.ctor(self, data)
	self:init("lua.uiconfig_mango_new.ZhuZhan.ZhuzhanRukou")
end

function AssistFightEntranceLayer:initUI( ui )
	self.super.initUI(self, ui)

    self.bg = TFDirector:getChildByPath(ui, "bg")
    self.bg:setTouchEnabled(true)
    self.bgSize = self.bg:getContentSize()

    self.IconTable = {}
    self.originalPost = {}
    for i=1,6 do
        local uiNode = TFDirector:getChildByPath(ui, "rolebg"..i)
        self.IconTable[i] = {}
        self.IconTable[i].Frame = uiNode
        self.IconTable[i].Head = TFDirector:getChildByPath(uiNode, "img_role")
        self.IconTable[i].Lock = TFDirector:getChildByPath(ui, "icon_suo"..i)

        TFResourceHelper:instance():addArmatureFromJsonFile("effect/assistSmalllock.xml")
        local effect = TFArmature:create("assistSmalllock_anim")
        effect:setVisible(true)
        effect:playByIndex(0, -1, -1, 1)
        self.bg:addChild(effect)
        effect:setPosition(ccp(0,0)) 
        self.IconTable[i].effect = effect

        self.originalPost[i] = uiNode:getPosition()
    end

    self.friendIcon = TFDirector:getChildByPath(ui, 'rolebg7')
    self.friendIcon:setVisible(false)

    self.bg_tips = TFDirector:getChildByPath(ui, 'bg_tips')
    self.bg_tips:setVisible(false)

    self.unLockData = require('lua.table.t_s_assistant_rule')
    
end

function AssistFightEntranceLayer:removeUI()
   	self.super.removeUI(self)    
end

function AssistFightEntranceLayer:onShow()
    self.super.onShow(self)    

    self:refreshGridInfo()
end

function AssistFightEntranceLayer:registerEvents()

	if self.registerEventCallFlag then
		return
	end
	self.super.registerEvents(self)

    self.bg:addMEListener(TFWIDGET_CLICK, audioClickfun(self.iconTableBtnClick))
    self.bg.logic = self

   	self.registerEventCallFlag = true

    local openLevel = FunctionOpenConfigure:getOpenLevel(1203)
    if MainPlayer:getLevel() >= openLevel then
        self.bg:setVisible(true)
        self.bg_tips:setVisible(false)
    else
        self.bg_tips:setVisible(true)
        self.bg:setVisible(false)
    end
end

function AssistFightEntranceLayer:removeEvents()

    self.bg:removeMEListener(TFWIDGET_CLICK)

    self.super.removeEvents(self)
    self.registerEventCallFlag = nil
end

function AssistFightEntranceLayer:dispose()
    self.super.dispose(self)
end

function AssistFightEntranceLayer.iconTableBtnClick(btn)
    local self = btn.logic  
    if self.LineUpCallBack then
        self.LineUpCallBack()
        return
    end
    AssistFightManager:openAssistWithType(self.LineUpType) 
end

function AssistFightEntranceLayer:refreshGridInfo()
    local gridState = AssistFightManager:getGridList()
    local roleList = AssistFightManager:getAssistRoleList( self.LineUpType )

    print("roleList = ", roleList)
    print("gridState = ", gridState)
    -- gridState = {false,false,false,false,false,false}

    local gridIdx = 1
    for k,v in pairs(gridState) do
        self.IconTable[k].Frame:setVisible(v)
        self.IconTable[k].Head:setVisible(v)
        self.IconTable[k].Lock:setVisible(not v)
        self.IconTable[k].effect:setVisible(false)
        if v then
            self.IconTable[k].Frame:setPosition(self.originalPost[k])
            self.IconTable[k].Lock:setPosition(self.originalPost[k])           
            
            gridIdx = gridIdx + 1


            if roleList[k] and roleList[k] > 0 then
                local cardRole = CardRoleManager:getRoleByGmid( roleList[k] )
                if cardRole then
                    self.IconTable[k].Frame:setTexture(GetColorRoadIconByQuality(cardRole.quality))
                    self.IconTable[k].Head:setTexture(cardRole:getHeadPath())
                else
                    self.IconTable[k].Frame:setVisible(false)
                end
            else
                self.IconTable[k].Frame:setVisible(false)
            end        
        end        
    end  

    for k,v in pairs(gridState) do
        if v == false then            
            self.IconTable[k].Frame:setPosition(self.originalPost[k])
            self.IconTable[k].Lock:setPosition(self.originalPost[k])
            local unLockState = self.unLockData:getObjectAt(k)
            if k == 4 then   
                if ClimbManager:getClimbFloorNum() >= unLockState.val then             
                    self.IconTable[k].effect:setVisible(true)
                    local x = self.originalPost[k].x + self.bgSize.width/2
                    local y = self.originalPost[k].y + self.bgSize.height/2
                    self.IconTable[k].effect:setPosition(ccp(x,y))
                    -- self.IconTable[k].effect:setZOrder(1)                        
                    self.IconTable[k].Lock:setVisible(false)
                end
            elseif k == 5 then
                self.IconTable[k].effect:setVisible(false)
                -- self.IconTable[k].Lock:setVisible(false)
            elseif k == 6 then
                if MainPlayer:getVipLevel() >= unLockState.val then
                    self.IconTable[k].effect:setVisible(true)
                    local x = self.originalPost[k].x + self.bgSize.width/2
                    local y = self.originalPost[k].y + self.bgSize.height/2
                    self.IconTable[k].effect:setPosition(ccp(x,y))                    
                    self.IconTable[k].Lock:setVisible(false)
                end
            else
                if MainPlayer:getLevel() >= unLockState.val then
                    self.IconTable[k].effect:setVisible(true)
                    local x = self.originalPost[k].x + self.bgSize.width/2
                    local y = self.originalPost[k].y + self.bgSize.height/2
                    self.IconTable[k].effect:setPosition(ccp(x,y))                    
                    self.IconTable[k].Lock:setVisible(false)
                end
            end
            gridIdx = gridIdx + 1
        end
    end    

    for i=1,#AssistFightManager.CloseFriendType do
        if self.LineUpType == AssistFightManager.CloseFriendType[i] then
            self.friendIcon:setVisible(false)
            return
        end
    end

    local info = AssistFightManager:getFriendIconInfo()
    local cardRole = RoleData:objectByID(info.friendRoleId)
    if cardRole then
        self.friendIcon:setVisible(true)
        self.friendIcon:setTexture(GetColorRoadIconByQuality(cardRole.quality))
        local head = TFDirector:getChildByPath(self.friendIcon, "img_role")
        head:setTexture(cardRole:getHeadPath())
    else
        self.friendIcon:setVisible(false)
    end
end

function AssistFightEntranceLayer:setLineUpType( Type,callBack )
    self.LineUpType = Type   
    AssistFightManager:refreshAssistRoleList( Type )
    self.LineUpCallBack = callBack
end

return AssistFightEntranceLayer
