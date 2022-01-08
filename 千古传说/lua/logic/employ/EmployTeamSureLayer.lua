--[[
******放置佣兵队伍*******

]]


local EmployTeamSureLayer = class("EmployTeamSureLayer", BaseLayer)

function EmployTeamSureLayer:ctor(data)
    self.super.ctor(self,data)
    self.useType = data
    self:init("lua.uiconfig_mango_new.yongbing.EmployTeam")
end

function EmployTeamSureLayer:initUI(ui)
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
        icon_suo:setVisible(false)
    end

    local txt_shouru = TFDirector:getChildByPath(ui, 'txt_shouru');
    self.txt_coin = TFDirector:getChildByPath(txt_shouru, 'txt_num');


    self.txt_miaoshu= TFDirector:getChildByPath(ui, 'txt_miaoshu')
    self.txt_miaoshu2= TFDirector:getChildByPath(ui, 'txt_miaoshu2')

    self.txt_zhanlizhi_word= TFDirector:getChildByPath(ui, 'txt_zhanlizhi_word')
    self.btn_queding= TFDirector:getChildByPath(ui, 'btn_queding')

    self.btn_close= TFDirector:getChildByPath(ui, 'btn_close')

end


function EmployTeamSureLayer:removeUI()
    self.super.removeUI(self)
end

function EmployTeamSureLayer:registerEvents()
    self.super.registerEvents(self)

    ADD_ALERT_CLOSE_LISTENER(self, self.btn_close);

    self.btn_queding.logic = self

    self.btn_queding:addMEListener(TFWIDGET_CLICK, audioClickfun(self.hireTeamButtonClick))



    for i=1,9 do
        self.btn_icon[i].logic = self
        self.btn_icon[i].posIndex = i


        self.btn_icon[i]:addMEListener(TFWIDGET_TOUCHBEGAN, self.cellTouchBeganHandle,1)
        self.btn_icon[i]:addMEListener(TFWIDGET_TOUCHMOVED, self.cellTouchMovedHandle)
        self.btn_icon[i]:addMEListener(TFWIDGET_TOUCHENDED, self.cellTouchEndedHandle)
    end

    self.EmployTeamSuccessNoticeCallBack = function(event)
        self:modifyEmployTeamFormation()
    end
    TFDirector:addMEGlobalListener(EmployManager.EmployTeamSuccessNotice, self.EmployTeamSuccessNoticeCallBack)

    self.EmployTeamFormationSuccessNoticeCallBack = function(event)
        self:modifyEmployTeamFormationSuccess()
        AlertManager:close();
        AlertManager:close();
    end
    TFDirector:addMEGlobalListener(EmployManager.EmployTeamFormationSuccessNotice, self.EmployTeamFormationSuccessNoticeCallBack)
end

function EmployTeamSureLayer:removeEvents()

    TFDirector:removeMEGlobalListener(EmployManager.EmployTeamSuccessNotice, self.EmployTeamSuccessNoticeCallBack)
    self.EmployTeamSuccessNoticeCallBack = nil
    TFDirector:removeMEGlobalListener(EmployManager.EmployTeamFormationSuccessNotice, self.EmployTeamFormationSuccessNoticeCallBack)
    self.EmployTeamFormationSuccessNoticeCallBack = nil

    self.super.removeEvents(self)
end

function EmployTeamSureLayer:dispose()
    self.super.dispose(self)
end


-----断线重连支持方法
function EmployTeamSureLayer:onShow()
    self.super.onShow(self)
    self:refreshUI()

end

function EmployTeamSureLayer:initTeamInfo( teamInfo )
    self.teamInfo = clone(teamInfo)
end

function EmployTeamSureLayer:refreshUI()

    self:showInfo()
end


function EmployTeamSureLayer:showInfo()
    for i=1,9 do
        self.btn_icon[i]:setVisible(false)

        self.btn_icon[i].roleId = 0
        self.btn_icon[i].hasRole = false
    end

    for i=1,#self.teamInfo.battleRole do
        local info = self.teamInfo.battleRole[i]
        local pos = info.position +1
        local roleInfo = RoleData:objectByID(info.roleId);
        if roleInfo then
            self.btn_icon[pos]:setVisible(true)
            local img_touxiang = TFDirector:getChildByPath(self.btn_icon[pos],"img_touxiang")
            img_touxiang:setTexture(roleInfo:getHeadPath())
            local img_zhiye = TFDirector:getChildByPath(self.btn_icon[pos],"img_zhiye")
            img_zhiye:setTexture("ui_new/fight/zhiye_".. roleInfo.outline ..".png")

            self.btn_icon[pos]:setTextureNormal(GetColorRoadIconByQuality(info.quality))

            self.btn_icon[pos].roleId = info.roleId
            self.btn_icon[pos].hasRole = true
        end
    end

    for i=1,7 do
        self.rolebg[i]:setVisible(false)
    end
    if self.teamInfo.assistant then
        for i=1,#self.teamInfo.assistant do
            local info = self.teamInfo.assistant[i]
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

    self.txt_zhanlizhi_word:setText(self.teamInfo.power)

    local str_miaoshu = stringUtils.format(localizable.EmTeamSureLayer_text1,self.teamInfo.playerName)
    self.txt_miaoshu:setText(str_miaoshu)
    local str_miaoshu2 = stringUtils.format(localizable.EmTeamSureLayer_text2,self.teamInfo.playerName)
    self.txt_miaoshu2:setText(str_miaoshu2)

    self.txt_coin:setText(math.floor(self.teamInfo.power*0.1+1000))

end


function EmployTeamSureLayer.hireTeamButtonClick(sender)
    local self = sender.logic
    if self.clickCallBack then
        TFFunction.call(self.clickCallBack,{playerId = self.teamInfo.playerId,useType = self.useType })
    end

    -- EmployManager:employTeamRequest(self.teamInfo.playerId,self.useType)
end

function EmployTeamSureLayer:modifyEmployTeamFormation()
    local formation = {}
    for i=1,#self.teamInfo.battleRole do
        local battleRole = self.teamInfo.battleRole[i]
        -- local role = {}
        -- role.instanceId = battleRole.instanceId
        -- role.position = battleRole.position
        formation[#formation+1] = {battleRole.instanceId,battleRole.position}
    end
    EmployManager:modifyEmployTeamFormation(self.teamInfo.playerId,self.useType,formation)
end

function EmployTeamSureLayer:getMyTeamRoleById(instanceId)
    for i=1,#self.teamInfo.battleRole do
        local battleRole = self.teamInfo.battleRole[i]
        if battleRole.instanceId == instanceId then
            return battleRole
        end
    end
end

function EmployTeamSureLayer:modifyEmployTeamFormationSuccess()
    local formation = EmployManager.myHireTeamDetalis[self.useType]
    if formation == nil then
        return
    end

    if formation.roleDetails then
        for i=1,#formation.roleDetails do
            local roleDetails = formation.roleDetails[i]
            local teamInfo = self:getMyTeamRoleById(roleDetails.instanceId)
            if teamInfo then
                roleDetails.position = teamInfo.position
            end
        end
    end
end


function EmployTeamSureLayer.cellTouchBeganHandle(cell)
    local self = cell.logic
    if cell.hasRole ~= true then
        return
    end

    cell.isClick = true
    cell.isDrag  = false
    self.isMove = false


    self.onLongTouch = function(event)
        if self.isMove == false then
            return
        end

        local pos = cell:getTouchMovePos()
          
        local v = ccpSub(cell:getTouchStartPos(), cell:getTouchMovePos())
       
        if (v.x < 30 and v.y < 30 )  then
            -- if (v.x < 0 or v.y < 0 ) then
            --     self:removeLongTouchTimer()  
            --     cell.isDrag  = false
            -- end
            -- self:removeLongTouchTimer()
            -- self.longTouchTimerId = TFDirector:addTimer(0.001, 1, nil, self.onLongTouch) 

        else 
            self:removeLongTouchTimer()    
            if (v.x - v.y > -10) then
                cell.isDrag  = true
            else
                cell.isDrag  = false
            end
        end
    end

    if (cell.posIndex == -1) then
        self:removeLongTouchTimer()
        self.longTouchTimerId = TFDirector:addTimer(0.001, -1, nil, self.onLongTouch) 
    end

end

function EmployTeamSureLayer.cellTouchMovedHandle(cell)
    local self = cell.logic
    self.isMove = true

    if cell.hasRole ~= true then
        return
    end

           
    local v = ccpSub(cell:getTouchStartPos(), cell:getTouchMovePos())



    local pos = cell:getTouchMovePos()

    if self.selectCussor == nil then

        if (cell.posIndex ~= -1) then
            if (v.y < 30 and v.y > -30) and  (v.x < 30 and v.x > -30)  then
               return
            end
        end

        if (cell.posIndex ~= -1 or cell.isDrag == true ) then
            self:createSelectCussor(cell,pos)
        end
    end

    if cell.isClick == true then
        return
    end

    self:moveSelectCussor(cell,pos)
end


function EmployTeamSureLayer.cellTouchEndedHandle(cell)
    local self = cell.logic
    if self.selectCussor then
        self.selectCussor:removeFromParentAndCleanup(true)
        self.selectCussor = nil
    end

    if cell.hasRole ~= true then
        return
    end

    self:removeLongTouchTimer()

    local pos = cell:getTouchEndPos()

    self:releaseSelectCussor(cell,pos)

end

function EmployTeamSureLayer:removeLongTouchTimer()
    if (self.longTouchTimerId) then
        TFDirector:removeTimer(self.longTouchTimerId)
        self.longTouchTimerId = nil
    end
end

function EmployTeamSureLayer:createSelectCussor(cell,pos)
    play_press()

    cell.isClick = false

    self.lastPoint = pos

    local role = RoleData:objectByID(cell.roleId)
    self.selectCussor = TFImage:create()
    self.selectCussor:setFlipX(true)
    self.selectCussor:setTexture(role:getHeadPath())
    self.selectCussor:setScale(1)
    self.selectCussor:setPosition(ccpAdd(pos,ccp(-80,-0)) )
    self:addChild(self.selectCussor)
    self.selectCussor:setZOrder(100)
   
    self.curIndex = cell.posIndex
    
end

function EmployTeamSureLayer:moveSelectCussor(cell,pos)
    local v = ccpSub(pos, self.lastPoint)
    self.lastPoint = pos
    local scp = ccpAdd(self.selectCussor:getPosition(), v)
    self.selectCussor:setPosition(scp)
    self.selectCussor:setVisible(true)

    self.curIndex = nil

    for i=1,9 do
        if  self.btn_icon[i]:hitTest(pos) then
            self.curIndex = self.btn_icon[i].posIndex
            break
        end
    end

end

function EmployTeamSureLayer:releaseSelectCussor(cell,pos)
    if cell.isClick == false  then
        if (self.curIndex == nil) then
            return
        end

        --在阵中释放
        if (self.curIndex ~= -1) and (cell.posIndex ~= -1) then 
            self:changePos(cell.posIndex,self.curIndex)
            play_buzhenyidong()
        end

    end
end
function EmployTeamSureLayer:getRoleInfoByPos( pos )
    for i=1,#self.teamInfo.battleRole do
        local info = self.teamInfo.battleRole[i]
        local position = info.position +1
        if position == pos then
            return info
        end
    end
    return nil
end


function EmployTeamSureLayer:setHireBtnClick( clickCallBack )
    self.clickCallBack = clickCallBack
end


function EmployTeamSureLayer:changePos(oldPos,newPos)
    local oldPosRole = self:getRoleInfoByPos(oldPos)
    local newPosRole = self:getRoleInfoByPos(newPos)
    if oldPosRole == nil then
        return
    end

    oldPosRole.position = newPos - 1
    if newPosRole ~= nil then
        newPosRole.position = oldPos - 1
    end
    self:setBtnIconInfo(oldPos,newPosRole)
    -- local roleInfo = RoleData:objectByID(oldPosRole.roleId);
    self:setBtnIconInfo(newPos,oldPosRole)
end

function EmployTeamSureLayer:setBtnIconInfo( pos ,info  )
    local roleInfo = nil
    if info then
        roleInfo = RoleData:objectByID(info.roleId);
    end
    if info and roleInfo then
        self.btn_icon[pos]:setVisible(true)
        local img_touxiang = TFDirector:getChildByPath(self.btn_icon[pos],"img_touxiang")
        img_touxiang:setTexture(roleInfo:getHeadPath())
        local img_zhiye = TFDirector:getChildByPath(self.btn_icon[pos],"img_zhiye")
        img_zhiye:setTexture("ui_new/fight/zhiye_".. roleInfo.outline ..".png")

        self.btn_icon[pos]:setTextureNormal(GetColorRoadIconByQuality(roleInfo.quality))

        self.btn_icon[pos].roleId = info.roleId
        self.btn_icon[pos].hasRole = true
    else
        self.btn_icon[pos]:setVisible(false)

        self.btn_icon[pos].roleId = 0
        self.btn_icon[pos].hasRole = false
    end
end


return EmployTeamSureLayer
