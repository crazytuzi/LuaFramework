--[[
]]

local BattleHurtCount = class("BattleHurtCount", BaseLayer)


function BattleHurtCount:ctor()
    self.super.ctor(self,data)
    self:init("lua.uiconfig_mango_new.fight.Shanghaitongji")
end

function BattleHurtCount:initUI(ui)
    self.super.initUI(self,ui)

    self.panel_role = {}
    for i=1,10 do
        self.panel_role[i] = TFDirector:getChildByPath(ui, 'Panel_role'..i)
    end
    self.btn_close = TFDirector:getChildByPath(ui, 'btn_close')
    self.maxHurt = 0

    self.effectTimer = {}
end

function BattleHurtCount:onShow()
    self.super.onShow(self)
    self:refreshUI()
end

function BattleHurtCount:dispose()
    self.super.dispose(self)
end

function BattleHurtCount:refreshUI()
    if FightManager.fightBeginInfo == nil then
        return
    end
    local hurtList = FightManager.fightBeginInfo.hurtList
    if hurtList == nil then
        return
    end
    self.maxHurt = 0
    for k,v in pairs(hurtList) do
        self.maxHurt =  math.max(self.maxHurt , v)
    end

    local ourIndex = 1
    local enemyIndex = 6

    for k,v in pairs(hurtList) do
        if k < 9 then
            self:showInfo(ourIndex , k,v)
            ourIndex = ourIndex + 1
        else
            self:showInfo(enemyIndex ,  k,v)
            enemyIndex = enemyIndex + 1
        end
    end
    for i=ourIndex,5 do
        self.panel_role[i]:setVisible(false)
    end
    for i=enemyIndex,10 do
        self.panel_role[i]:setVisible(false)
    end
end

function BattleHurtCount:getRoleByIndex(index )
    local roleInfo = {}
    for k,v in pairs(FightManager.fightBeginInfo.rolelist) do
        if v.posindex == index then
            local roleTableData = nil
            if v.typeid == 2 then
                roleTableData = NPCData:objectByID(v.roleId)
            else
                roleTableData = RoleData:objectByID(v.roleId)
            end
            roleInfo.quality = roleTableData.quality
            roleInfo.headPath = "icon/roleicon/"..roleTableData.image..".png"
            return roleInfo
        end
    end
    return roleInfo
end

function BattleHurtCount:showInfo( index , role_pos , hurt )
    self.panel_role[index]:setVisible(true)
    local role = self:getRoleByIndex(role_pos)
    if role.headPath == nil or role.quality == nil then
        return
    end
    local bg_role = TFDirector:getChildByPath(self.panel_role[index], 'bg_role')
    bg_role:setTexture(GetColorIconByQuality(role.quality))
    local img_roleicon = TFDirector:getChildByPath(self.panel_role[index], 'img_roleicon')
    img_roleicon:setTexture(role.headPath)
    local txt_shanghai = TFDirector:getChildByPath(self.panel_role[index], 'txt_shanghai')
    local shanghai = TFDirector:getChildByPath(self.panel_role[index], 'shanghai')
    txt_shanghai:setText(hurt)
    -- shanghai:setPercent( math.ceil(hurt/self.maxHurt*100) )

    shanghai:setPercent( 0 )
    local max_percent = math.ceil(hurt/self.maxHurt*100)
    local time = 1
    self.effectTimer[index] = TFDirector:addTimer(30,-1,nil,function ()
        shanghai:setPercent( max_percent*time/30 )
        if time == 30 then
            TFDirector:removeTimer(self.effectTimer[index])
            self.effectTimer[index] = nil
            return
        end
        time = time + 1
    end)
end


function BattleHurtCount:removeUI()
    self.super.removeUI(self)
end

function BattleHurtCount:registerEvents()
	self.super.registerEvents(self)
    ADD_ALERT_CLOSE_LISTENER(self, self.btn_close);
end

function BattleHurtCount:removeEvents()

    for i=1,10 do
        if self.effectTimer[i] then
            TFDirector:removeTimer(self.effectTimer[i])
            self.effectTimer[i] = nil
        end
    end
    self.effectTimer = {}
    self.super.removeEvents(self)
end

return BattleHurtCount
