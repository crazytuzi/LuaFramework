--[[
******采矿队伍*******
    -- by yao
    -- 2016/2/18
]]

local MiningTeam = class("MiningTeam", BaseLayer)

function MiningTeam:ctor(data)
    self.super.ctor(self,data)
    self.fightType = data
    self:init("lua.uiconfig_mango_new.yongbing.ChooseTeamDetail")
end

function MiningTeam:initUI(ui)
	self.super.initUI(self,ui)

    local  armylist = ZhengbaManager:getFightList( self.fightType )
    --print("armylist =",armylist)

    self.btn_icon = {}
    for i=1,9 do
        self.btn_icon[i] = TFDirector:getChildByPath(ui, 'btn_icon'..i)
    end
    self.rolebg = {}
    for i=1,7 do
        self.rolebg[i] = TFDirector:getChildByPath(ui, 'rolebg'..i)
    end

    for i=1,6 do
        local icon_suo = TFDirector:getChildByPath(ui, 'icon_suo'..i)
        icon_suo:setVisible(true)
        if AssistFightManager.gridState[i] then
            icon_suo:setVisible(false)
        end
    end

    self.txt_zhanlizhi_word= TFDirector:getChildByPath(ui, 'txt_zhanlizhi_word')

    self:showInfo()
end

function MiningTeam:setData()
    self:ShowUIData()
end

function MiningTeam:removeUI()
    self.super.removeUI(self)
end

-----断线重连支持方法
function MiningTeam:onShow()
    self.super.onShow(self)
end

function MiningTeam:registerEvents()
    self.super.registerEvents(self)
end

function MiningTeam:removeEvents()
    self.super.removeEvents(self)
end

function MiningTeam:dispose()
    self.super.dispose(self)
end

function MiningTeam:showInfo()
    for i=1,9 do
        self.btn_icon[i]:setVisible(false)
    end

    local  armylist = ZhengbaManager:getFightList( self.fightType )
    for index in pairs(armylist) do
        local role = ZhengbaManager:getRoleByIndex(self.fightType,index);
        if role then
            self.btn_icon[index]:setVisible(true)
            local img_touxiang = TFDirector:getChildByPath(self.btn_icon[index],"img_touxiang")
            img_touxiang:setTexture(role:getHeadPath())
            local img_zhiye = TFDirector:getChildByPath(self.btn_icon[index],"img_zhiye")
            img_zhiye:setTexture("ui_new/fight/zhiye_".. role.outline ..".png")
            self.btn_icon[index]:setTextureNormal(GetColorRoadIconByQuality(role.quality))
            Public:addLianTiEffect(img_touxiang,role:getMaxLianTiQua(),true)
        end
    end

    for i=1,7 do
        self.rolebg[i]:setVisible(false)
    end


    local roleList = AssistFightManager:getAssistRoleList(self.fightType)
    local gridState = AssistFightManager:getGridList()
    local info = AssistFightManager:getFriendIconInfo()
    print("self.assistFightView = ",roleList)
    print("gridState = ",gridState)
    for i=1,7 do
        local roleInfo = nil
        if i <= #gridState then
            roleInfo = CardRoleManager:getRoleByGmid(roleList[i])
        else
            roleInfo = RoleData:objectByID(info.friendRoleId)
        end

        if roleInfo then
            self.rolebg[i]:setVisible(true)
            self.rolebg[i]:setTexture(GetColorRoadIconByQuality(roleInfo.quality))
            local img_role = TFDirector:getChildByPath(self.rolebg[i],"img_role")
            img_role:setTexture(roleInfo:getHeadPath())
        end
    end

    local power = ZhengbaManager:getPower(self.fightType)
    self.txt_zhanlizhi_word:setText(power)

end

return MiningTeam