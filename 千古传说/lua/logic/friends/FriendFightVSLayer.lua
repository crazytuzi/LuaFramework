--[[
******布阵-对方详情*******
    -- modify by king
    -- 2015/10/27
]]
local FriendFightVSLayer = class("BossFightArmyVSLayer", BaseLayer)

CREATE_SCENE_FUN(FriendFightVSLayer)
CREATE_PANEL_FUN(FriendFightVSLayer)

FriendFightVSLayer.LIST_ITEM_WIDTH = 200 

function FriendFightVSLayer:ctor(data)
    self.super.ctor(self,data)
    self:init("lua.uiconfig_mango_new.demond.demondOtherArmyVSLayer")
end

function FriendFightVSLayer:initUI(ui)
    self.super.initUI(self,ui)

    self.panel_left   = TFDirector:getChildByPath(ui, 'panel_buzhen')
    self.panel_right   = TFDirector:getChildByPath(ui, 'panel_buzhen1')

    self.btn_close      = TFDirector:getChildByPath(ui, 'btn_close')
    
    self.btn_army       = TFDirector:getChildByPath(ui, 'btn_challenge')
    self.btn_buzhen     = TFDirector:getChildByPath(ui, 'btn_buzhen')


    self.btn_close      = TFDirector:getChildByPath(ui, 'btn_close')

    self.txt_name       = TFDirector:getChildByPath(ui, 'txt_mingcheng_word')

    self.txt_rank       = TFDirector:getChildByPath(ui, 'txt_paiming_word')
    self.txt_power      = TFDirector:getChildByPath(ui, 'txt_zhandouli_word')
    self.txt_winRate    = TFDirector:getChildByPath(ui, 'txt_shenglv_word')

    self.img_rolebg = {}
    self.img_role = {}
    self.img_role_quility = {}


    local resPath = "effect/arena_attack.xml"
    TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
    local effect = TFArmature:create("arena_attack_anim")

    effect:setAnimationFps(GameConfig.ANIM_FPS)
    effect:setPosition(ccp(self:getSize().width/2 - 15,self:getSize().height/2 - 40))

    self:addChild(effect,20)

    effect:playByIndex(0, -1, -1, 0)

end

function FriendFightVSLayer:setUserData(userData)
    self.userData = userData
    -- layer:setBossId(5)
    -- BossFightManager:getBossFightInfo()
    -- layer:setuserData(5)
    print("self.userData = ", self.userData)
end

function FriendFightVSLayer:onShow()
    self.super.onShow(self)
    self:refreshBaseUI()
    self:refreshUI()
    self:drawLeftArea()
    self:drawRightArea()
end

function FriendFightVSLayer:refreshBaseUI()

end

function FriendFightVSLayer:refreshUI()
    if not self.isShow then
        return
    end

end

function FriendFightVSLayer:getRightRolePos(pos)
    if self.userData == nil then
        return nil
    end
    if self.userData.warside == nil then
        return
    end

    local idx = 0
    for _,v in pairs(self.userData.warside) do
        local cardRole = RoleData:objectByID(v.id)
        -- print("getRightRolePos = ", v)
        local idx = v.warIndex + 1
        if idx == pos then
            cardRole.maxHp  = 100
            cardRole.currHp = 100
            return cardRole
        end
    end
end

function FriendFightVSLayer:getRightRoleInfoByPos(pos)
    if self.userData == nil then
        return nil
    end
    if self.userData.warside == nil then
        return
    end

    local idx = 0
    for _,v in pairs(self.userData.warside) do
        local cardRole = RoleData:objectByID(v.id)
        -- print("getRightRolePos = ", v)
        local idx = v.warIndex + 1
        if idx == pos then
            return v
        end
    end
end

function FriendFightVSLayer.cellClickHandle(sender)
    local self = sender.logic
    local cardRoleId = sender.cardRoleId

    OtherPlayerManager:openRoleInfo(self.userData, cardRoleId)
    -- Public:ShowItemTipLayer(sender.role.id, EnumDropType.ROLE, 1,sender.role.level)
end

function FriendFightVSLayer.onArmyClickHandle(sender)
    local self = sender.logic
    local gmid = sender.gmid

    if sender.isClick == false then
        return
    end

--     print("gmid = ", gmid)
--     if gmid > 0 then
--         -- CardRoleManager:setSortBloodStrategyForQuality()
--         CardRoleManager:openRoleInfo(gmid)
--     end
end

function FriendFightVSLayer:getChangeBtn()
    return self.btn_challenge
end

--注册事件
function FriendFightVSLayer:registerEvents()
   self.super.registerEvents(self)
   ADD_ALERT_CLOSE_LISTENER(self,self.btn_close)
   self.btn_close:setClickAreaLength(100)
    
   
    self.btn_army.logic = self
    self.btn_army:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onBtnAttackClickHandle),1)


    local function enterStarge(sender)
        -- BloodFightManager:openRoleList(self.userData.section)
        CardRoleManager:openRoleList(false)
    end
    self.btn_buzhen:addMEListener(TFWIDGET_CLICK,  audioClickfun(enterStarge),1)

   for i=1,9 do
        local bg = TFDirector:getChildByPath(self.panel_right, "btn_icon"..i)
        bg.logic = self
        bg:addMEListener(TFWIDGET_CLICK, audioClickfun(self.cellClickHandle),1)
    end

    for i=1,9 do
        local bg = TFDirector:getChildByPath(self.panel_left, "btn_icon"..i)
        bg.logic = self
        bg.posIndex = i

        bg:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onArmyClickHandle),1)

        bg:addMEListener(TFWIDGET_TOUCHBEGAN, self.cellTouchBeganHandle,1)
        bg:addMEListener(TFWIDGET_TOUCHMOVED, self.cellTouchMovedHandle)
        bg:addMEListener(TFWIDGET_TOUCHENDED, self.cellTouchEndedHandle)   
    end



    self.requestRoleList = function(event)
        -- BloodFightManager:openRoleList(self.section)
        self:drawLeftArea()
    end

    TFDirector:addMEGlobalListener(BloodFightManager.MSG_REQUEST_ROLELIST_RESULT, self.requestRoleList)


    self.updatePosCallBack = function(event)
        self:drawLeftArea()
    end
    TFDirector:addMEGlobalListener(StrategyManager.UPDATE_STARTEGY_POS ,self.updatePosCallBack ) 
end

function FriendFightVSLayer:removeEvents()
    TFDirector:removeMEGlobalListener(BloodFightManager.MSG_INSPIRE_RESULT, self.inspireUpdate)
    self.inspireUpdate = nil


    TFDirector:removeMEGlobalListener(BloodFightManager.MSG_REQUEST_ROLELIST_RESULT, self.requestRoleList)
    self.requestRoleList = nil


    TFDirector:removeMEGlobalListener(StrategyManager.UPDATE_STARTEGY_POS ,self.updatePosCallBack ) 
    self.updatePosCallBack = nil

    self.super.removeEvents(self)
end


function FriendFightVSLayer:drawLeftArea()
    self.button_self = {}
    self.button = {}
    for i=1,9 do
        local btnName = "panel_item" .. i
        self.button[i] = TFDirector:getChildByPath(self.panel_left, btnName)

        self.button_self[i] = self.button[i]
        self.button_self[i].posIndex = i

        btnName = "btn_icon"..i
        self.button[i].bg = TFDirector:getChildByPath(self.panel_left, btnName)
        self.button[i].bg:setVisible(false)

        self.button[i].icon = TFDirector:getChildByPath(self.button[i].bg ,"img_touxiang")
        self.button[i].icon:setVisible(false)

        self.button[i].bar_bg       = TFDirector:getChildByPath(self.button[i],"img_xuetiao"..i)
        self.button[i].bar_hp       = TFDirector:getChildByPath(self.button[i],"bar_xuetiao"..i)
        self.button[i].img_type     = TFDirector:getChildByPath(self.button[i],"img_zhiye")
        self.button[i].img_death    = TFDirector:getChildByPath(self.button[i],"img_death"..i)


        self.button[i].quality = TFDirector:getChildByPath(self.panel_left, btnName)

        self.button[i].img_death:setVisible(false)

        -- local role = self:getRightRolePos(i)
        self.button[i].bg.gmid = 0
        -- local role = BloodFightManager:getRoleByIndex(i)
        local role = StrategyManager:getRoleByIndex(i)

        self.button[i].bg.hasRole = false
        self.button[i].bg.gmId = 0
        if  role ~= nil then

            self.button[i].bg.gmId = role.gmId
            self.button[i].bg.hasRole = true
            self.button[i].bg.gmid = role.gmId
            
            self.button[i].icon:setVisible(true)
            self.button[i].icon:setTexture(role:getHeadPath())

            self.button[i].bg:setVisible(true)
            self.button[i].quality:setTextureNormal(GetColorRoadIconByQualitySmall(role.quality))
            -- self.button[i].quality:setTextureNormal(GetRoleBgByWuXueLevel_circle_small(role.martialLevel))

            self.button[i].bg.cardRoleId = role.id
            self.button[i].bg.role = role

            self.button[i].img_type:setVisible(true)
            self.button[i].img_type:setTexture("ui_new/fight/zhiye_".. role.outline ..".png")
        
            local maxHp = 100--role.blood_maxHp
            local curHp = 100--role.blood_curHp

            if curHp <= 0 then
                self.button[i].img_death:setVisible(true)
                self.button[i].icon:setShaderProgram("GrayShader", true)
            else
                self.button[i].img_death:setVisible(false)
                self.button[i].icon:setShaderProgramDefault(true)
                -- self.button[i].icon:setShaderProgram("GrayShader", false)
            end

            self.button[i].bar_hp:setPercent(curHp * 100 / maxHp)

            self.button[i].bar_bg:setVisible(true)
            self.button[i].img_type:setVisible(true)            
            self.button[i].icon:setVisible(true)
            self.button[i].bg:setVisible(true)

            self.button[i].icon:setFlipX(true)

            Public:addLianTiEffect(self.button[i].icon,role:getMaxLianTiQua(),true)
        else
            self.button[i].icon:setVisible(false)
            self.button[i].bg:setVisible(false)     
        
            self.button[i].bar_bg:setVisible(false)
            self.button[i].img_type:setVisible(false)
            Public:addLianTiEffect(self.button[i].icon,0,false)
        end
    end

    local txt_name = TFDirector:getChildByPath(self.panel_left, "txt_name")
    local txt_zhanli = TFDirector:getChildByPath(self.panel_left, "txt_zhanli")
    txt_name:setText(MainPlayer:getPlayerName())
    txt_zhanli:setText(StrategyManager:getPower())
end

function FriendFightVSLayer:drawRightArea()
    self.button = {}
    for i=1,9 do
        local btnName = "panel_item" .. i
        self.button[i] = TFDirector:getChildByPath(self.panel_right, btnName)

        btnName = "btn_icon"..i
        self.button[i].bg = TFDirector:getChildByPath(self.panel_right, btnName)
        self.button[i].bg:setVisible(false)

        self.button[i].icon = TFDirector:getChildByPath(self.button[i].bg ,"img_touxiang")
        self.button[i].icon:setVisible(false)

        self.button[i].bar_bg       = TFDirector:getChildByPath(self.button[i],"img_xuetiao"..i)
        self.button[i].bar_hp       = TFDirector:getChildByPath(self.button[i],"bar_xuetiao"..i)
        self.button[i].img_type     = TFDirector:getChildByPath(self.button[i],"img_zhiye")
        self.button[i].img_death    = TFDirector:getChildByPath(self.button[i],"img_death"..i)

        self.button[i].quality = TFDirector:getChildByPath(self.panel_right, btnName)

        self.button[i].img_death:setVisible(false)

        local role = self:getRightRolePos(i)
        local role_info = self:getRightRoleInfoByPos(i)
        if  role ~= nil then
            self.button[i].icon:setVisible(true)
            self.button[i].icon:setTexture(role:getHeadPath())

            self.button[i].bg:setVisible(true)
            self.button[i].quality:setTextureNormal(GetColorRoadIconByQualitySmall(role_info.quality))
            -- self.button[i].quality:setTextureNormal(GetRoleBgByWuXueLevel_circle_small(role.martialLevel))

            self.button[i].bg.cardRoleId = role.id
            self.button[i].bg.role = role

            self.button[i].img_type:setVisible(true)
            self.button[i].img_type:setTexture("ui_new/fight/zhiye_".. role.outline ..".png")

            if role.currHp <= 0 then
                self.button[i].img_death:setVisible(true)
                self.button[i].icon:setShaderProgram("GrayShader", true)
            end

            self.button[i].bar_hp:setPercent(role.currHp * 100 / role.maxHp)
            Public:addLianTiEffect(self.button[i].icon,role_info.forgingQuality,true)
        else
            self.button[i].icon:setVisible(false)
            self.button[i].bg:setVisible(false)     
        
            self.button[i].bar_bg:setVisible(false)
            self.button[i].img_type:setVisible(false)
            Public:addLianTiEffect(self.button[i].icon,0,false)
        end
    end

    local txt_name = TFDirector:getChildByPath(self.panel_right, "txt_name")
    local txt_zhanli = TFDirector:getChildByPath(self.panel_right, "txt_zhanli")
    local txt_weizhizhandouli = TFDirector:getChildByPath(self.panel_right, "txt_weizhizhandouli")

    txt_zhanli:setVisible(true)
    txt_weizhizhandouli:setVisible(false)

    txt_name:setText(self.userData.name)
    txt_zhanli:setText(self.userData.power)
end


function FriendFightVSLayer.onBtnAttackClickHandle(sender)
    local self      = sender.logic
    -- local section   = self.userData.section

    -- if BloodFightManager:CheckAllRuleReachBeforeAttack() == false then
    --     return
    -- end
    
    -- AlertManager:close(AlertManager.TWEEN_NONE)
    -- BloodFightManager:Attack(section)
    self:Attack()
end

function FriendFightVSLayer:Attack()
    local bossId   = self.userData.playerId

    FriendManager:friendChallenge(bossId)
end


function FriendFightVSLayer.cellTouchBeganHandle(cell)
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

function FriendFightVSLayer.cellTouchMovedHandle(cell)
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


function FriendFightVSLayer.cellTouchEndedHandle(cell)
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

function FriendFightVSLayer:removeLongTouchTimer()
    if (self.longTouchTimerId) then
        TFDirector:removeTimer(self.longTouchTimerId)
        self.longTouchTimerId = nil
    end
end

function FriendFightVSLayer:createSelectCussor(cell,pos)
    play_press()

    cell.isClick = false

    self.lastPoint = pos

    local role = CardRoleManager:getRoleByGmid(cell.gmId)
    self.selectCussor = TFImage:create()
    self.selectCussor:setFlipX(true)
    self.selectCussor:setTexture(role:getHeadPath())
    self.selectCussor:setScale(1)
    self.selectCussor:setPosition(ccpAdd(pos,ccp(-80,-0)) )
    self:addChild(self.selectCussor)
    self.selectCussor:setZOrder(100)
   
    self.curIndex = cell.posIndex
    
end

function FriendFightVSLayer:moveSelectCussor(cell,pos)
    local v = ccpSub(pos, self.lastPoint)
    self.lastPoint = pos
    local scp = ccpAdd(self.selectCussor:getPosition(), v)
    self.selectCussor:setPosition(scp)
    self.selectCussor:setVisible(true)

    self.curIndex = nil

    for i=1,9 do
        if  self.button_self[i]:hitTest(pos) then
            self.curIndex = self.button_self[i].posIndex
            break
        end
    end

end

function FriendFightVSLayer:releaseSelectCussor(cell,pos)
    print("FriendFightVSLayer:releaseSelectCussor")
    if cell.isClick == false  then
        print("111111111111111111111111FriendFightVSLayer:releaseSelectCussor = ", self.curIndex)
        if (self.curIndex == nil) then
            return
        end
        print("2222222222FriendFightVSLayer:releaseSelectCussor")
        local dargRole      = CardRoleManager:getRoleByGmid(cell.gmId)
        local toReplaceRole =  StrategyManager:getRoleByIndex(self.curIndex)


        --在阵中释放
        if (self.curIndex ~= -1) then 

            --从列表中拖到阵中
            if (cell.posIndex == -1) then

                --本来已经在阵中
                if dargRole.pos and dargRole.pos ~= 0 then

                    --且不是本角色目前所在的位置，做位置变更
                    if (toReplaceRole == nil or (toReplaceRole and toReplaceRole.gmId ~= dargRole.gmId)) then
                        local sendMsg = {              
                        dargRole.pos - 1,
                        self.curIndex - 1,   
                        }
                        showLoading()
                        TFDirector:send(c2s.CHANGE_INDEX,sendMsg)

                        -- BloodFightManager:ChangePos(dargRole.pos - 1, self.curIndex - 1)

                        play_buzhenyidong()

                    end
                --要上阵，但是已经到达上限
                elseif (toReplaceRole == nil and not StrategyManager:canAddFightRole()) then
                    if StrategyManager.maxNum == 5 then
                        --toastMessage("上阵人数已满")
                        toastMessage(localizable.common_function_number_out);  

                    else
                        local needLevel = FunctionOpenConfigure:getOpenLevel(700 + (StrategyManager.maxNum + 1))
                        if MainPlayer:getLevel() < needLevel then
                            --toastMessage("团队等级" .. needLevel .. "级可上阵" .. (StrategyManager.maxNum + 1) .."人")
                            toastMessage(stringUtils.format(localizable.common_function_up_number,needLevel, (StrategyManager.maxNum + 1)))                            
                        end
                    end 

                --要替换，但是替换对象是主角
                --elseif (toReplaceRole and  toReplaceRole.gmId == MainPlayer:getPlayerId()) then
                --    toastMessage("主角不能下阵")

                --上阵，如果目标存在角色，将其下阵
                else
                    local battle = {cell.gmId,( self.curIndex - 1)}
                    showLoading()
                    TFDirector:send(c2s.TO_BATTLE,{battle})
                    -- BloodFightManager:OnBattle(cell.gmId, self.curIndex - 1)
                    play_buzhenyidong()

                end

            --阵中操作，更换位置   
            else
                local sendMsg = {              
                cell.posIndex - 1,
                self.curIndex - 1,   
                }
                showLoading()
                TFDirector:send(c2s.CHANGE_INDEX,sendMsg)

                -- BloodFightManager:ChangePos(cell.posIndex - 1, self.curIndex - 1)

                play_buzhenyidong()
            end

            return
        end

        --在右边列表释放
        if (self.curIndex == -1) then

            if (cell.posIndex == -1 ) then
                --放弃上阵，不做操作

            else
                --下阵
                --if (dargRole.gmId == MainPlayer:getPlayerId()) then
                --    toastMessage("主角不能下阵")
                --else
                    print("下阵:",dargRole.name)
                    -- BloodFightManager:OutBattle(cell.gmId)
                    showLoading()
                    TFDirector:send(c2s.OUT_BATTLE,{cell.gmId})
                    play_buzhenluoxia()
                --end
            end
        end
    end


end

return FriendFightVSLayer
