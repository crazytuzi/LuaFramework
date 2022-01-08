--[[
]]

local Shanghaitongji = class("Shanghaitongji", BaseLayer)


local fightRoleMgr  = require("lua.logic.fight.FightRoleManager")
function Shanghaitongji:ctor()
    self.super.ctor(self,data)
    self:init("lua.uiconfig_mango_new.fight.Shanghaitongji")
end

function Shanghaitongji:initUI(ui)
    self.super.initUI(self,ui)

    self.panel_role = {}
    for i=1,10 do
        self.panel_role[i] = TFDirector:getChildByPath(ui, 'Panel_role'..i)
    end
    self.btn_close = TFDirector:getChildByPath(ui, 'btn_close')
    self.maxHurt = 0

    self.effectTimer = {}
end

function Shanghaitongji:onShow()
    self.super.onShow(self)
    self:refreshUI()
end

function Shanghaitongji:dispose()
    self.super.dispose(self)
end

function Shanghaitongji:refreshUI()
    if FightManager.lastEndFightMsg == nil then
        return
    end
    local hurtList = FightManager.lastEndFightMsg[7]
    if hurtList == nil then
        return
    end
    self.maxHurt = 0
    for i=1,#hurtList do
        local hurtInfo = hurtList[i]
        self.maxHurt =  math.max(self.maxHurt , hurtInfo[2])
    end

    local ourIndex = 1
    local enemyIndex = 6

    for i=1,#hurtList do
        local hurtInfo = hurtList[i]
        if hurtInfo[1] < 9 then
            self:showInfo(ourIndex , hurtInfo)
            ourIndex = ourIndex + 1
        else
            self:showInfo(enemyIndex , hurtInfo)
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

function Shanghaitongji:getRoleByIndex(index )
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

function Shanghaitongji:showInfo( index , info )
    self.panel_role[index]:setVisible(true)
    local role = self:getRoleByIndex(info[1])
    if role.headPath == nil or role.quality == nil then
        return
    end
    local bg_role = TFDirector:getChildByPath(self.panel_role[index], 'bg_role')
    bg_role:setTexture(GetColorIconByQuality(role.quality))
    local img_roleicon = TFDirector:getChildByPath(self.panel_role[index], 'img_roleicon')
    img_roleicon:setTexture(role.headPath)
    local txt_shanghai = TFDirector:getChildByPath(self.panel_role[index], 'txt_shanghai')
    local shanghai = TFDirector:getChildByPath(self.panel_role[index], 'shanghai')
    txt_shanghai:setText(info[2])
    shanghai:setPercent( 0 )
    local max_percent = math.ceil(info[2]/self.maxHurt*100)
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


function Shanghaitongji:removeUI()
    self.super.removeUI(self)
end

function Shanghaitongji:registerEvents()
	self.super.registerEvents(self)
    ADD_ALERT_CLOSE_LISTENER(self, self.btn_close);
end

function Shanghaitongji:removeEvents()

    for i=1,10 do
        if self.effectTimer[i] then
            TFDirector:removeTimer(self.effectTimer[i])
            self.effectTimer[i] = nil
        end
    end
    self.effectTimer = {}
    self.super.removeEvents(self)
end

return Shanghaitongji
