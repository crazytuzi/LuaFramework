--[[
******放置佣兵队伍*******

]]


local EmployTeamInfo = class("EmployTeamInfo", BaseLayer)

function EmployTeamInfo:ctor(data)
    self.super.ctor(self,data)
    self:init("lua.uiconfig_mango_new.yongbing.ChooseTeamDetail")
end

function EmployTeamInfo:initUI(ui)
    self.super.initUI(self,ui)

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

end


function EmployTeamInfo:removeUI()
    self.super.removeUI(self)
end

function EmployTeamInfo:registerEvents()
    self.super.registerEvents(self)

end

function EmployTeamInfo:removeEvents()
    self.super.removeEvents(self)
end

function EmployTeamInfo:dispose()
    self.super.dispose(self)
end


-----断线重连支持方法
function EmployTeamInfo:onShow()
    self.super.onShow(self)
    self:refreshUI()
end


function EmployTeamInfo:refreshUI()
    -- self:showInfo()
end


function EmployTeamInfo:showInfo( teamInfo )
    for i=1,9 do
        self.btn_icon[i]:setVisible(false)
    end

    for i=1,#teamInfo.battleRole do
        local info = teamInfo.battleRole[i]
        local pos = info.position +1
        local roleInfo = RoleData:objectByID(info.roleId)
        if roleInfo then
            self.btn_icon[pos]:setVisible(true)
            local img_touxiang = TFDirector:getChildByPath(self.btn_icon[pos],"img_touxiang")
            img_touxiang:setTexture(roleInfo:getHeadPath())
            local img_zhiye = TFDirector:getChildByPath(self.btn_icon[pos],"img_zhiye")
            img_zhiye:setTexture("ui_new/fight/zhiye_".. roleInfo.outline ..".png")

            self.btn_icon[pos]:setTextureNormal(GetColorRoadIconByQuality(info.quality))
            Public:addLianTiEffect(img_touxiang,info.forgingQuality,true)
        end
    end

    for i=1,7 do
        self.rolebg[i]:setVisible(false)
    end
    if teamInfo.assistant then
        for i=1,#teamInfo.assistant do
            local info = teamInfo.assistant[i]
            local pos = info.position +1
            local roleInfo = RoleData:objectByID(info.roleId)
            if roleInfo then
                self.rolebg[pos]:setVisible(true)
                self.rolebg[pos]:setTexture(GetColorRoadIconByQuality(info.quality))
                local img_role = TFDirector:getChildByPath(self.rolebg[pos],"img_role")
                img_role:setTexture(roleInfo:getHeadPath())
            end
        end
    end

    self.txt_zhanlizhi_word:setText(teamInfo.power)

end


return EmployTeamInfo
