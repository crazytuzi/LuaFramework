--[[
******劫矿页*******
    -- by yao
    -- 2016/1/12
]]

local ShaLuArmyVSLayer = class("ShaLuArmyVSLayer", BaseLayer)

function ShaLuArmyVSLayer:ctor(data)
    self.super.ctor(self,data)
    
    self.rolebtn        = {}        --己方人物按钮
    self.rolePanel      = {}        --己方人物的panel
    self.rolePanelPos   = {}        --己方人物的panel位置

    self.armyRolebtn    = {}        --敌方人物按钮    
    self.armyRolePanel  = {}        --敌方人物的panel
    self.armyRolePanelPos  = {}     --敌方人物的panel位置   
    self.armyDetailsInfo = {}          --存储敌方布阵信息

    self.btn_challenge = {}         --挑战按钮

    self:init("lua.uiconfig_mango_new.youli.ShaLuArmyVSLayer")
end

function ShaLuArmyVSLayer:initUI(ui)
	self.super.initUI(self,ui)

    self.btn_close      = TFDirector:getChildByPath(ui, "btn_close")
    self.btn_close:setVisible(false)

    self.generalHead = CommonManager:addGeneralHead(self)
    self.generalHead:setData(ModuleType.youli,{HeadResType.BAOZI,HeadResType.YUELI,HeadResType.SYCEE}) 
    self.generalHead:setVisible(true)

    self.btn_buzhen = {}
    self.btn_qiehuan    = TFDirector:getChildByPath(ui, "btn_qiehuan")
    self.btn_qiehuan.logic = self
    self.btn_qiehuan:setZOrder(10)


    for k=1,4 do
        local panel = TFDirector:getChildByPath(ui, "Panel_" .. k)
        local btn = {}
        for i=1,9 do
            local btnName = "panel_item" .. i;
            btn[i] = TFDirector:getChildByPath(panel, btnName);
            btnName = "btn_icon"..i;
            btn[i].bg = TFDirector:getChildByPath(panel, btnName);
            btn[i].bg:setVisible(false);
            btn[i].icon = TFDirector:getChildByPath(btn[i].bg ,"img_touxiang");
            btn[i].icon:setVisible(false);
            btn[i].img_zhiye = TFDirector:getChildByPath(btn[i], "img_zhiye");
            btn[i].img_zhiye:setVisible(false);
            btn[i].quality = TFDirector:getChildByPath(panel, btnName);

            btn[i].bg.posIndex = i
            btn[i].bg.hasRole = true
        end

        if k <= 2 then
            self.rolePanel[k] = panel
            self.rolebtn[k] = btn
            self.rolePanelPos[k] = panel:getPosition()

            self.btn_buzhen[k]     = TFDirector:getChildByPath(panel, "btn_buzhen")
            self.btn_buzhen[k].logic = self

        else            --护矿
            self.armyRolePanel[k-2] = panel
            self.armyRolebtn[k-2] = btn
            self.armyRolePanelPos[k-2] = panel:getPosition()

            local btn_challenge = TFDirector:getChildByPath(panel, "btn_challenge")
            btn_challenge.logic = self
            btn_challenge:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onChallengeCallBack))
            self.btn_challenge[k-2] = btn_challenge
        end
    end
end

function ShaLuArmyVSLayer:setData(fightTypeList, armyRoleInfo, battleType)
    
    self.fightTypeList = fightTypeList or {}
    self.armyDetailsInfo = armyRoleInfo
    self.currFightIndex = 1
    self.battleType = battleType

    self.powerTotal = 0
    for k,v in pairs(self.fightTypeList) do
        self.powerTotal = self.powerTotal + ZhengbaManager:getPower(v)
    end     

    self.btn_challenge[2]:setVisible(false)
    self.btn_challenge[1]:setVisible(true)
    self.btn_buzhen[2]:setVisible(false)
    self.btn_buzhen[1]:setVisible(true)

    self:showOwnUIData()
    self:showArmyUIData()
end


function ShaLuArmyVSLayer.onChallengeCallBack(sender)
    local self = sender.logic
    local battleType = self.battleType
    local playerId = self.armyDetailsInfo.playerId
    AlertManager:close(AlertManager.TWEEN_NONE)
    AdventureManager:requestBattle( battleType,playerId ) 
end

function ShaLuArmyVSLayer:removeUI()   
    self.super.removeUI(self)
end

-----断线重连支持方法
function ShaLuArmyVSLayer:onShow()
    self.super.onShow(self)
    self.generalHead:onShow()
end

function ShaLuArmyVSLayer:registerEvents()
    self.super.registerEvents(self)  
    self.btn_close:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onCloseCallBack))
    self.btn_buzhen[1]:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onBuzhenCallBack))
    self.btn_buzhen[2]:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onBuzhenCallBack))
    self.btn_qiehuan:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onQiehuanCallBack))
    if self.generalHead then
        self.generalHead:registerEvents()
    end

    self.updateFormationSucess = function(event)
        print("----------self.updateFormationSucess")
        self:showOwnUIData()
    end;
    TFDirector:addMEGlobalListener(ZhengbaManager.UPDATEFORMATIONSUCESS ,self.updateFormationSucess ) ;

end

function ShaLuArmyVSLayer:removeEvents()
    self.btn_close:removeMEListener(TFWIDGET_CLICK)
    self.btn_buzhen[1]:removeMEListener(TFWIDGET_CLICK)
    self.btn_buzhen[2]:removeMEListener(TFWIDGET_CLICK)
    self.btn_qiehuan:removeMEListener(TFWIDGET_CLICK)

    if self.generalHead then
        self.generalHead:removeEvents()
    end

    if self.updateFormationSucess then
        TFDirector:removeMEGlobalListener(ZhengbaManager.UPDATEFORMATIONSUCESS, self.updateFormationSucess)    
        self.updateFormationSucess = nil
    end

    self.super.removeEvents(self)
end

function ShaLuArmyVSLayer:dispose()
    self.super.dispose(self)
    if self.generalHead then
        self.generalHead:dispose()
        self.generalHead = nil
    end
end

function ShaLuArmyVSLayer.onCloseCallBack(sender)
    AlertManager:close()
end

function ShaLuArmyVSLayer.onBuzhenCallBack(sender)
    local self = sender.logic
    ZhengbaManager:openArmyLayer(self.fightTypeList[self.currFightIndex], false)
end

function ShaLuArmyVSLayer.onQiehuanCallBack(sender)
    local self = sender.logic
    self:qieHuanAction()
end

function ShaLuArmyVSLayer.cellClickHandle(sender) 
    local self = sender.logic;
    local role = sender.role;
    if sender.isClick == false then
        return
    end
    --print("role.level:",role.level)
    Public:ShowItemTipLayer(role.role_id, EnumDropType.ROLE, 1,role.level)
end

function ShaLuArmyVSLayer:showOwnUIData()

    for k=1,2 do

        local btn = self.rolebtn[k]
        local panelNode = self.rolePanel[k]

        for i=1,9 do
            local role = ZhengbaManager:getRoleByIndex( self.fightTypeList[k],i )
            if role ~= nil then
                btn[i].icon:setVisible(true);
                btn[i].icon:setTexture(role:getHeadPath());
                btn[i].icon:setFlipX(true)
                btn[i].bg:setVisible(true);
                btn[i].bg.role = role;
                btn[i].bg.logic = self;
                btn[i].bg.gmId = role.gmId
                btn[i].bg.posIndex = i
                btn[i].bg.hasRole = true
                btn[i].bg:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.cellClickHandle),1);
                btn[i].bg:addMEListener(TFWIDGET_TOUCHBEGAN, self.cellTouchBeganHandle,1);
                btn[i].bg:addMEListener(TFWIDGET_TOUCHMOVED, self.cellTouchMovedHandle);
                btn[i].bg:addMEListener(TFWIDGET_TOUCHENDED, self.cellTouchEndedHandle);
                btn[i].img_zhiye:setVisible(true);
                btn[i].img_zhiye:setTexture("ui_new/fight/zhiye_".. role.outline ..".png");
                btn[i].img_zhiye:setZOrder(2)
                btn[i].img_zhiye:setPosition(ccp(-35,-30))
                btn[i].quality:setTextureNormal(GetColorRoadIconByQualitySmall(role.quality))
                Public:addLianTiEffect(btn[i].icon,role:getMaxLianTiQua(),true)
                role.role_id = role.id
            else
                btn[i].img_zhiye:setVisible(false);  
                btn[i].icon:setVisible(false);
                btn[i].bg:setVisible(false);
                Public:addLianTiEffect(btn[i].icon,0,false)
            end
        end

        local name = TFDirector:getChildByPath(panelNode, "txt_name")
        local zhanli = TFDirector:getChildByPath(panelNode, "txt_zhanli")
        name:setText(MainPlayer:getPlayerName())
        local power = ZhengbaManager:getPower(self.fightTypeList[k]) or 0
        zhanli:setText(power)

        local img_headIcon = TFDirector:getChildByPath(panelNode, "img_role")
        img_headIcon:setFlipX(true)
        img_headIcon:setTexture(MainPlayer:getIconPath())
        Public:addFrameImg(img_headIcon,MainPlayer:getHeadPicFrameId())
    end    
end

function ShaLuArmyVSLayer:showArmyUIData()

    for k=1,2 do

        local roleList = self.armyDetailsInfo.role_list[k]
        local btn = self.armyRolebtn[k] 
        local panelNode = self.armyRolePanel[k]
        --
        local img_wenhao = TFDirector:getChildByPath(panelNode, "img_wenhao")
        img_wenhao:setVisible(true)
        -- for i=1,9 do

        --     local roleInfo = roleList[i]

        --     if roleInfo ~= nil then
        --         local roleId = roleInfo.id
        --         local quality = roleInfo.quality
        --         local role = RoleData:objectByID(roleId)
        --         btn[i].icon:setVisible(true);
        --         btn[i].icon:setTexture(role:getHeadPath());
        --         btn[i].bg:setVisible(true);
        --         btn[i].bg.role  = role
        --         btn[i].bg.logic = self
        --         btn[i].bg:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.cellClickHandle),1);
        --         btn[i].img_zhiye:setVisible(true);
        --         btn[i].img_zhiye:setTexture("ui_new/fight/zhiye_".. role.outline ..".png");
        --         btn[i].img_zhiye:setZOrder(2)
        --         btn[i].img_zhiye:setPosition(ccp(-35,-30))
        --         btn[i].quality:setTextureNormal(GetColorRoadIconByQualitySmall(quality))
        --         role.role_id = role.id
        --         role.level = roleInfo.level
        --     else
        --         btn[i].img_zhiye:setVisible(false);  
        --         btn[i].icon:setVisible(false);
        --         btn[i].bg:setVisible(false);
        --     end
        -- end

        local name = TFDirector:getChildByPath(panelNode, "txt_name")
        local zhanli = TFDirector:getChildByPath(panelNode, "txt_zhanli")
        name:setText(self.armyDetailsInfo.playerName)
        if k == 1 then
            zhanli:setText(self.armyDetailsInfo.power)
        else
            zhanli:setText(self.armyDetailsInfo.secondPower)
        end

        local img_headIcon = TFDirector:getChildByPath(panelNode, "img_role")
        local roleConfig = RoleData:objectByID(self.armyDetailsInfo.headIconId)
        img_headIcon:setTexture(roleConfig:getIconPath())
        Public:addFrameImg(img_headIcon,self.armyDetailsInfo.HeadFrameId) 
        Public:addInfoListen(img_headIcon,true,2,self.armyDetailsInfo.playerId)
    end
end

--获得人物详细信息
function ShaLuArmyVSLayer:getroleInfoByIndex(roledetailInfo,index)
    local roleInfo = nil
    for m,n in pairs(roledetailInfo.warside) do
        if n.warIndex+1 == index then
            roleInfo = n
        end
    end
    return roleInfo
end

--切换动作
function ShaLuArmyVSLayer:qieHuanAction()
    if self.ismoveEnd then
        return
    end
    self.ismoveEnd = true
    local move1 = CCMoveTo:create(0.2,ccp(self.armyRolePanelPos[2].x-50,self.armyRolePanelPos[2].y))
    local move2 = CCMoveTo:create(0.2,ccp(self.armyRolePanelPos[1].x+50,self.armyRolePanelPos[1].y))
    local move3 = CCMoveTo:create(0.2,ccp(self.armyRolePanelPos[2].x,self.armyRolePanelPos[2].y))
    local move4 = CCMoveTo:create(0.2,ccp(self.armyRolePanelPos[1].x,self.armyRolePanelPos[1].y))
 
    local move11 = CCMoveTo:create(0.2,ccp(self.rolePanelPos[2].x+50,self.rolePanelPos[2].y))
    local move21 = CCMoveTo:create(0.2,ccp(self.rolePanelPos[1].x-50,self.rolePanelPos[1].y))
    local move31 = CCMoveTo:create(0.2,ccp(self.rolePanelPos[2].x,self.rolePanelPos[2].y))
    local move41 = CCMoveTo:create(0.2,ccp(self.rolePanelPos[1].x,self.rolePanelPos[1].y))

    local function changeOrder()
        self.armyRolePanel[1]:setZOrder(1)
        self.armyRolePanel[2]:setZOrder(2)
        self.rolePanel[1]:setZOrder(1)
        self.rolePanel[2]:setZOrder(2)

        self.btn_challenge[1]:setVisible(false)
        self.btn_challenge[2]:setVisible(true)
        self.btn_buzhen[1]:setVisible(false)
        self.btn_buzhen[2]:setVisible(true)
    end
    local function changeOrder2()
        self.armyRolePanel[1]:setZOrder(2)
        self.armyRolePanel[2]:setZOrder(1)
        self.rolePanel[1]:setZOrder(2)
        self.rolePanel[2]:setZOrder(1)

        self.btn_challenge[2]:setVisible(false)
        self.btn_challenge[1]:setVisible(true)
        self.btn_buzhen[2]:setVisible(false)
        self.btn_buzhen[1]:setVisible(true)
    end
    local function moveEnd()
        self.ismoveEnd = false
    end
    if self.currFightIndex == 1 then
        self.currFightIndex = 2

        local act1 = CCSequence:createWithTwoActions(move1,move4)
        self.armyRolePanel[2]:runAction(act1)
        local act2 = CCSequence:createWithTwoActions(move2,CCCallFunc:create(changeOrder))
        local act3 = CCSequence:createWithTwoActions(act2,move3)
        self.armyRolePanel[1]:runAction(CCSequence:createWithTwoActions(act3,CCCallFunc:create(moveEnd)))

        local act11 = CCSequence:createWithTwoActions(move11,move41)
        self.rolePanel[2]:runAction(act11)
        local act21 = CCSequence:createWithTwoActions(move21,CCCallFunc:create(changeOrder))
        local act31 = CCSequence:createWithTwoActions(act21,move31)
        self.rolePanel[1]:runAction(CCSequence:createWithTwoActions(act31,CCCallFunc:create(moveEnd)))
    else
        self.currFightIndex = 1

        local act1 = CCSequence:createWithTwoActions(move2,move3)
        self.armyRolePanel[2]:runAction(act1)
        local act2 = CCSequence:createWithTwoActions(move1,CCCallFunc:create(changeOrder2))
        local act3 = CCSequence:createWithTwoActions(act2,move4)
        self.armyRolePanel[1]:runAction(CCSequence:createWithTwoActions(act3,CCCallFunc:create(moveEnd)))

        local act11 = CCSequence:createWithTwoActions(move21,move31)
        self.rolePanel[2]:runAction(act11)
        local act21 = CCSequence:createWithTwoActions(move11,CCCallFunc:create(changeOrder2))
        local act31 = CCSequence:createWithTwoActions(act21,move41)
        self.rolePanel[1]:runAction(CCSequence:createWithTwoActions(act31,CCCallFunc:create(moveEnd)))
    end  
end

function ShaLuArmyVSLayer.cellTouchBeganHandle(cell)
    local self = cell.logic;
    if cell.hasRole ~= true then
        return;
    end

    cell.isClick = true;
    cell.isDrag  = false;
    self.isMove = false;

    self.onLongTouch = function(event)
        if self.isMove == false then
            return;
        end
        local pos = cell:getTouchMovePos();         
        local v = ccpSub(cell:getTouchStartPos(), cell:getTouchMovePos());   
        if (v.x < 30 and v.y < 30 )  then
            -- if (v.x < 0 or v.y < 0 ) then
            --     self:removeLongTouchTimer();  
            --     cell.isDrag  = false;
            -- end
            -- self:removeLongTouchTimer();
            -- self.longTouchTimerId = TFDirector:addTimer(0.001, 1, nil, self.onLongTouch); 

        else 
            self:removeLongTouchTimer();    
            if (v.x - v.y > -10) then
                cell.isDrag  = true;         
            else
                cell.isDrag  = false;
            end
        end
    end;

    if (cell.posIndex == -1) then
        self:removeLongTouchTimer();
        self.longTouchTimerId = TFDirector:addTimer(0.001, -1, nil, self.onLongTouch); 
    end
end


function ShaLuArmyVSLayer.cellTouchMovedHandle(cell)
    local self = cell.logic;
    self.isMove = true;
           
    if cell.hasRole ~= true then
        return;
    end

    local v = ccpSub(cell:getTouchStartPos(), cell:getTouchMovePos());
    local pos = cell:getTouchMovePos();

    if self.selectCussor == nil then
        if (cell.posIndex ~= -1) then
            if (v.y < 30 and v.y > -30) and  (v.x < 30 and v.x > -30)  then
               return;
            end
        end

        if (cell.posIndex ~= -1 or cell.isDrag == true ) then
            self:createSelectCussor(cell,pos);
        end
    end

    self:moveSelectCussor(cell,pos);
end

function ShaLuArmyVSLayer.cellTouchEndedHandle(cell)
    local self = cell.logic;
    if self.selectCussor then
        self.selectCussor:removeFromParentAndCleanup(true);
        self.selectCussor = nil;
    end
    if cell.hasRole ~= true then
        return;
    end

    self:removeLongTouchTimer();
    local pos = cell:getTouchEndPos();

    self:releaseSelectCussor(cell,pos);
end

function ShaLuArmyVSLayer:moveSelectCussor(cell,pos)
    local self = cell.logic;
    local v = ccpSub(pos, self.lastPoint);
    self.lastPoint = pos;
    local scp = ccpAdd(self.selectCussor:getPosition(), v);
    self.selectCussor:setPosition(scp);
    self.selectCussor:setVisible(true);

    self.curIndex = nil;
    for i=1,9 do
        if  self.rolebtn[self.currFightIndex][i].bg:hitTest(pos) then
            --print("i:",i)
            --print("self.curIndex:",self.curIndex)
            self.curIndex = self.rolebtn[self.currFightIndex][i].bg.posIndex;
            break;
        end
    end
end

function ShaLuArmyVSLayer:createSelectCussor(cell,pos)
    play_press();

    cell.isClick = false;

    self.lastPoint = pos;

    local role = CardRoleManager:getRoleByGmid(cell.gmId);
    self.selectCussor = TFImage:create();
    self.selectCussor:setFlipX(true);
    self.selectCussor:setTexture(role:getHeadPath());
    self.selectCussor:setScale(20 / 15.0);
    self.selectCussor:setPosition(pos);
    self:addChild(self.selectCussor);
    self.selectCussor:setZOrder(100);
   
    self.curIndex = cell.posIndex;  
end

function ShaLuArmyVSLayer:releaseSelectCussor(cell,pos) 
    if cell.isClick == false  then
        if (self.curIndex == nil) then
            return;
        end

        local dargRole      = CardRoleManager:getRoleByGmid(cell.gmId);
        local toReplaceRole =  ZhengbaManager:getRoleByIndex( self.fightTypeList[self.currFightIndex], self.curIndex)

        if dargRole == nil then
            return
        end

        local role_pos = ZhengbaManager:getIndexByRole(self.fightTypeList[self.currFightIndex],cell.gmId )
        --在阵中释放
        if (self.curIndex ~= -1) then 
            --从列表中拖到阵中
            if (cell.posIndex == -1) then
                --本来已经在阵中
                if role_pos and role_pos ~= 0 then
                    --且不是本角色目前所在的位置，做位置变更
                    if (toReplaceRole == nil or (toReplaceRole and toReplaceRole.gmId ~= dargRole.gmId)) then
                        ZhengbaManager:ChangePos(self.fightTypeList[self.currFightIndex],role_pos, self.curIndex)
                        play_buzhenyidong()
                    end               
                end
            --阵中操作，更换位置   
            else
                ZhengbaManager:ChangePos(self.fightTypeList[self.currFightIndex],role_pos, self.curIndex)
                play_buzhenyidong()
            end

            return;
        end
    end
end

function ShaLuArmyVSLayer:removeLongTouchTimer()
    if (self.longTouchTimerId) then
        TFDirector:removeTimer(self.longTouchTimerId);
        self.longTouchTimerId = nil;
    end
end

return ShaLuArmyVSLayer