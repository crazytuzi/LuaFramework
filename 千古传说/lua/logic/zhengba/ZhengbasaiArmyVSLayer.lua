--[[
******布阵-对方详情*******
]]
local ZhengbasaiArmyVSLayer = class("ZhengbasaiArmyVSLayer", BaseLayer);
CREATE_SCENE_FUN(ZhengbasaiArmyVSLayer);
CREATE_PANEL_FUN(ZhengbasaiArmyVSLayer);

ZhengbasaiArmyVSLayer.LIST_ITEM_WIDTH = 200; 

function ZhengbasaiArmyVSLayer:ctor(data)
    self.super.ctor(self,data);
    self:init("lua.uiconfig_mango_new.zhenbashai.ZhengbasaiArmyVSLayer");
    self.firstShow = true
end

function ZhengbasaiArmyVSLayer:initUI(ui)
    self.super.initUI(self,ui);

    self.panel_left   = TFDirector:getChildByPath(ui, 'panel_buzhen')
    self.panel_right   = TFDirector:getChildByPath(ui, 'panel_buzhen1')

    self.btn_close      = TFDirector:getChildByPath(ui, 'btn_close');
    
    self.btn_army       = TFDirector:getChildByPath(ui, 'btn_challenge')
    self.btn_buzhen     = TFDirector:getChildByPath(ui, 'btn_buzhen')


    self.btn_close      = TFDirector:getChildByPath(ui, 'btn_close');

    self.txt_name       = TFDirector:getChildByPath(ui, 'txt_mingcheng_word')

    self.txt_rank       = TFDirector:getChildByPath(ui, 'txt_paiming_word')
    self.txt_power      = TFDirector:getChildByPath(ui, 'txt_zhandouli_word')
    self.txt_winRate    = TFDirector:getChildByPath(ui, 'txt_shenglv_word')

    self.img_rolebg = {}
    self.img_role = {}
    self.img_role_quility = {}


    --鼓舞相关
    local img_guwu  = TFDirector:getChildByPath(ui, 'img_guwu')
    img_guwu:setVisible(false)
    self.txt_effect    = TFDirector:getChildByPath(img_guwu, 'txt_effect')

    self.inspireBtnList = {}
    self.inspireBtnList.btn_inspire  = TFDirector:getChildByPath(ui, 'btn_inspire')
    self.inspireBtnList.img_money    = TFDirector:getChildByPath(self.inspireBtnList.btn_inspire, 'img_money')
    self.inspireBtnList.txt_num      = TFDirector:getChildByPath(self.inspireBtnList.btn_inspire, 'txt_num')
    self.inspireBtnList.txt_effect   = TFDirector:getChildByPath(self.inspireBtnList.btn_inspire, 'txt_effect')
    self.inspireBtnList.btn_inspire:setVisible(false)

end

function ZhengbasaiArmyVSLayer:loadData(userData)
    self.userData = userData
end

function ZhengbasaiArmyVSLayer:onShow()
    self.super.onShow(self)
    self:refreshBaseUI()
    self:refreshUI()
    self:drawLeftArea()
    self:drawRightArea()
    self:drawInspire()
    if self.firstShow == true then
       self.ui:runAnimation("Action0",1);
        self.firstShow = false
    end
end

function ZhengbasaiArmyVSLayer:refreshBaseUI()

end

function ZhengbasaiArmyVSLayer:refreshUI()
    if not self.isShow then
        return;
    end

end

function ZhengbasaiArmyVSLayer:getRoleByPos(pos)
    -- print("self.userData = ",self.userData)
    for _,v in pairs(self.userData.warside) do
        local idx = v.warIndex + 1
        if idx == pos then
            local roleId = v.id
            local cardRole = RoleData:objectByID(roleId);
            cardRole.level  = v.level
            return cardRole
        end
    end
end
function ZhengbasaiArmyVSLayer:getRoleInfoByPos(pos)
    -- print("self.userData = ",self.userData)
    for _,v in pairs(self.userData.warside) do
        local idx = v.warIndex + 1
        if idx == pos then
            return v
        end
    end
end

function ZhengbasaiArmyVSLayer.cellClickHandle(sender)
    local self = sender.logic;
    local cardRoleId = sender.cardRoleId;
    -- OtherPlayerManager:openRoleInfo(self.userData,cardRoleId);
    -- print("cardRoleId = ", cardRoleId)
    -- local cardRole   = CardRole:new(cardRoleId)
    -- print("sender.role = ", sender.role)
    Public:ShowItemTipLayer(sender.role.id, EnumDropType.ROLE, 1,sender.role.level)
    -- CardRoleManager:openRoleSimpleInfo(sender.role)
end

function ZhengbasaiArmyVSLayer.onArmyClickHandle(sender)
    local self = sender.logic;
    local gmid = sender.gmid

    if sender.isClick == false then
        return
    end

    print("gmid = ", gmid)
    if gmid > 0 then
        -- CardRoleManager:setSortBloodStrategyForQuality()
        -- CardRoleManager:openBloodFightRoleInfo(gmid)
    end
end

function ZhengbasaiArmyVSLayer:getChangeBtn()
    return self.btn_challenge
end

--注册事件
function ZhengbasaiArmyVSLayer:registerEvents()
    self.super.registerEvents(self);
    ADD_ALERT_CLOSE_LISTENER(self,self.btn_close);
    -- self.btn_close:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onBtnCloseClickHandle),1);
    self.btn_close:setClickAreaLength(100);

    self.inspireBtnList.btn_inspire.logic = self
    self.inspireBtnList.btn_inspire:addMEListener(TFWIDGET_CLICK,audioClickfun(self.onBtnInspireClickHandle))
    self.btn_army.logic = self;
    self.btn_army:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onBtnAttackClickHandle),1);


    local function enterStarge(sender)
        ZhengbaManager:openArmyLayer(EnumFightStrategyType.StrategyType_CHAMPIONS_ATK)
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

        bg:addMEListener(TFWIDGET_TOUCHBEGAN, self.cellTouchBeganHandle,1);
        bg:addMEListener(TFWIDGET_TOUCHMOVED, self.cellTouchMovedHandle);
        bg:addMEListener(TFWIDGET_TOUCHENDED, self.cellTouchEndedHandle);   
    end



    self.inspireUpdate = function(event)
        -- toastMessage("鼓舞成功")
        self:playInspireEffect()
        self:drawInspire()

    end
    TFDirector:addMEGlobalListener(ZhengbaManager.ENCOURAGINGSUCESS, self.inspireUpdate) ;




    self.updatePosCallBack = function(event)
        self:drawLeftArea()
    end
    TFDirector:addMEGlobalListener(ZhengbaManager.UPDATEFORMATIONSUCESS ,self.updatePosCallBack ) 
end

function ZhengbasaiArmyVSLayer:removeEvents()
    TFDirector:removeMEGlobalListener(ZhengbaManager.ENCOURAGINGSUCESS, self.inspireUpdate);
    self.inspireUpdate = nil;


    TFDirector:removeMEGlobalListener(ZhengbaManager.UPDATEFORMATIONSUCESS ,self.updatePosCallBack ) 
    self.updatePosCallBack = nil;

    self.super.removeEvents(self)
    self.firstShow = true
end


function ZhengbasaiArmyVSLayer:drawLeftArea()
    self.button_self = {}
    self.button = {}
    for i=1,9 do
        local btnName = "panel_item" .. i;
        self.button[i] = TFDirector:getChildByPath(self.panel_left, btnName);

        self.button_self[i] = self.button[i]
        self.button_self[i].posIndex = i;

        btnName = "btn_icon"..i;
        self.button[i].bg = TFDirector:getChildByPath(self.panel_left, btnName);
        self.button[i].bg:setVisible(false);

        self.button[i].icon = TFDirector:getChildByPath(self.button[i].bg ,"img_touxiang");
        self.button[i].icon:setVisible(false);

        self.button[i].img_type     = TFDirector:getChildByPath(self.button[i],"img_zhiye");


        self.button[i].quality = TFDirector:getChildByPath(self.panel_left, btnName);


        -- local role = self:getRoleByPos(i);
        self.button[i].bg.gmid = 0
        local role = ZhengbaManager:getRoleByIndex(EnumFightStrategyType.StrategyType_CHAMPIONS_ATK,i);
        self.button[i].bg.hasRole = false
        self.button[i].bg.gmId = 0
        if  role ~= nil then

            self.button[i].bg.gmId = role.gmId
            self.button[i].bg.hasRole = true
            self.button[i].bg.gmid = role.gmId

            self.button[i].icon:setVisible(true);
            self.button[i].icon:setTexture(role:getHeadPath());

            self.button[i].bg:setVisible(true);
            self.button[i].quality:setTextureNormal(GetColorRoadIconByQualitySmall(role.quality));
            -- self.button[i].quality:setTextureNormal(GetRoleBgByWuXueLevel_circle_small(role.martialLevel));

            self.button[i].bg.cardRoleId = role.id;
            self.button[i].bg.role = role;

            self.button[i].img_type:setVisible(true);
            self.button[i].img_type:setTexture("ui_new/fight/zhiye_".. role.outline ..".png");



            self.button[i].img_type:setVisible(true)
            self.button[i].icon:setVisible(true);
            self.button[i].bg:setVisible(true);

            self.button[i].icon:setFlipX(true)
            Public:addLianTiEffect(self.button[i].icon,role:getMaxLianTiQua(),true)
        else
            self.button[i].icon:setVisible(false);
            self.button[i].bg:setVisible(false);     

            self.button[i].img_type:setVisible(false)
            Public:addLianTiEffect(self.button[i].icon,0,false)
        end
    end

    local txt_name = TFDirector:getChildByPath(self.panel_left, "txt_name")
    local txt_zhanli = TFDirector:getChildByPath(self.panel_left, "txt_zhanli")
    txt_name:setText(MainPlayer:getPlayerName())
    
    local img_headIcon = TFDirector:getChildByPath(self.panel_left, "img_role")         --pck change head icon and head icon frame
    img_headIcon:setTexture(MainPlayer:getIconPath())
    img_headIcon:setFlipX(true)
    Public:addFrameImg(img_headIcon,MainPlayer:getHeadPicFrameId())                     --end
end

function ZhengbasaiArmyVSLayer:drawRightArea()
    self.button = {}
    for i=1,9 do
        local btnName = "panel_item" .. i;
        self.button[i] = TFDirector:getChildByPath(self.panel_right, btnName);

        btnName = "btn_icon"..i;
        self.button[i].bg = TFDirector:getChildByPath(self.panel_right, btnName);
        self.button[i].bg:setVisible(false);

        self.button[i].icon = TFDirector:getChildByPath(self.button[i].bg ,"img_touxiang");
        self.button[i].icon:setVisible(false);

        self.button[i].img_type     = TFDirector:getChildByPath(self.button[i],"img_zhiye");

        self.button[i].quality = TFDirector:getChildByPath(self.panel_right, btnName);


        local role = self:getRoleByPos(i);
        local role_info = self:getRoleInfoByPos(i);
        if  role ~= nil then
            self.button[i].icon:setVisible(true);
            self.button[i].icon:setTexture(role:getHeadPath());

            self.button[i].bg:setVisible(true);
            self.button[i].quality:setTextureNormal(GetColorRoadIconByQualitySmall(role_info.quality));
            -- self.button[i].quality:setTextureNormal(GetRoleBgByWuXueLevel_circle_small(role.martialLevel));

            self.button[i].bg.cardRoleId = role.id;
            self.button[i].bg.role = role;

            self.button[i].img_type:setVisible(true);
            self.button[i].img_type:setTexture("ui_new/fight/zhiye_".. role.outline ..".png");

            Public:addLianTiEffect(self.button[i].icon,role_info.forgingQuality,true)
        else
            self.button[i].icon:setVisible(false);
            self.button[i].bg:setVisible(false);     
        
            self.button[i].img_type:setVisible(false)
            Public:addLianTiEffect(self.button[i].icon,0,false)
        end
    end

    local txt_name = TFDirector:getChildByPath(self.panel_right, "txt_name")
    local txt_zhanli = TFDirector:getChildByPath(self.panel_right, "txt_zhanli")
    txt_name:setText(self.userData.name)
    txt_zhanli:setText(self.userData.power)

    local img_headIcon = TFDirector:getChildByPath(self.panel_right, "img_role")            --pck change head icon and head icon frame
    local roleConfig = RoleData:objectByID(self.userData.icon)
    img_headIcon:setTexture(roleConfig:getIconPath())
    Public:addFrameImg(img_headIcon,self.userData.headPicFrame)                            --end
    Public:addInfoListen(img_headIcon,true,2,self.userData.playerId)
end


function ZhengbasaiArmyVSLayer.onBtnAttackClickHandle(sender)
    AlertManager:close()
    ZhengbaManager:beginFight()
end

function ZhengbasaiArmyVSLayer.onBtnCloseClickHandle(sender)
    CommonManager:showOperateSureLayer(
        function()
            AlertManager:close()
        end,
        nil,
        {
            --msg = "本次退出对战，将会在接下来的30秒内不能再进行对战，是否退出？" ,
            msg = localizable.zhengba_ZhengbasaiArmyVSLayer_tishi,
            showtype = AlertManager.BLOCK_AND_GRAY
        }
    )
end


function ZhengbasaiArmyVSLayer:drawInspire()

    -- if ZhengbaManager.inspireNum == 1 then
    --     self.inspireBtnList.btn_inspire:setGrayEnabled(true)
    --     self.inspireBtnList.btn_inspire:setClickMoveEnabled(true)
    --     self.inspireBtnList.btn_inspire:setTouchEnabled(false)
    -- else
    --     self.inspireBtnList.btn_inspire:setGrayEnabled(false)
    --     self.inspireBtnList.btn_inspire:setClickMoveEnabled(false)
    --     self.inspireBtnList.btn_inspire:setTouchEnabled(true)
    -- end
    -- self.inspireBtnList.txt_num:setText(5)
    -- local totalEffect = ZhengbaManager.inspireNum * 10
    -- self.txt_effect:setText("+"..totalEffect.."%")
    local totalPower = ZhengbaManager:getPower(EnumFightStrategyType.StrategyType_CHAMPIONS_ATK)

    -- totalPower = totalPower * (100 + totalEffect) / 100
    -- totalPower = math.ceil(totalPower)
    print("====totalPower2 = ",totalPower)
    local txt_zhanli = TFDirector:getChildByPath(self.panel_left, "txt_zhanli")
    txt_zhanli:setText(totalPower)
end


function ZhengbasaiArmyVSLayer.onBtnInspireClickHandle(sender)
    ZhengbaManager:Encouraging()
end


function ZhengbasaiArmyVSLayer.cellTouchBeganHandle(cell)
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

function ZhengbasaiArmyVSLayer.cellTouchMovedHandle(cell)
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

    if cell.isClick == true then
        return;
    end

    self:moveSelectCussor(cell,pos);
end


function ZhengbasaiArmyVSLayer.cellTouchEndedHandle(cell)
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

function ZhengbasaiArmyVSLayer:removeLongTouchTimer()
    if (self.longTouchTimerId) then
        TFDirector:removeTimer(self.longTouchTimerId);
        self.longTouchTimerId = nil;
    end
end

function ZhengbasaiArmyVSLayer:createSelectCussor(cell,pos)
    play_press();

    cell.isClick = false;

    self.lastPoint = pos;

    local role = CardRoleManager:getRoleByGmid(cell.gmId);
    self.selectCussor = TFImage:create();
    self.selectCussor:setFlipX(true);
    self.selectCussor:setTexture(role:getHeadPath());
    self.selectCussor:setScale(1);
    self.selectCussor:setPosition(ccpAdd(pos,ccp(0,-0)) );
    self:addChild(self.selectCussor);
    self.selectCussor:setZOrder(100);
   
    self.curIndex = cell.posIndex;
    
end

function ZhengbasaiArmyVSLayer:moveSelectCussor(cell,pos)
    local v = ccpSub(pos, self.lastPoint);
    self.lastPoint = pos;
    local scp = ccpAdd(self.selectCussor:getPosition(), v);
    self.selectCussor:setPosition(scp);
    self.selectCussor:setVisible(true);

    self.curIndex = nil;

    for i=1,9 do
        if  self.button_self[i]:hitTest(pos) then
            self.curIndex = self.button_self[i].posIndex;
            break;
        end
    end

end

function ZhengbasaiArmyVSLayer:releaseSelectCussor(cell,pos)
    if cell.isClick == false  then
        if (self.curIndex == nil) then
            return;
        end
        local dargRole      = CardRoleManager:getRoleByGmid(cell.gmId);
        local toReplaceRole =  ZhengbaManager:getRoleByIndex( EnumFightStrategyType.StrategyType_CHAMPIONS_ATK,self.curIndex);


        --在阵中释放
        if (self.curIndex ~= -1) then 

            --从列表中拖到阵中
            if (cell.posIndex == -1) then
                local role_pos = ZhengbaManager:getIndexByRole(EnumFightStrategyType.StrategyType_CHAMPIONS_ATK,cell.gmId)
                --本来已经在阵中
                if role_pos and role_pos ~= 0 then

                    --且不是本角色目前所在的位置，做位置变更
                    if (toReplaceRole == nil or (toReplaceRole and toReplaceRole.gmId ~= dargRole.gmId)) then

                        ZhengbaManager:ChangePos(EnumFightStrategyType.StrategyType_CHAMPIONS_ATK,role_pos, self.curIndex )

                        play_buzhenyidong()

                    end
                --要上阵，但是已经到达上限
                elseif (toReplaceRole == nil and not ZhengbaManager:canAddFightRole(EnumFightStrategyType.StrategyType_CHAMPIONS_ATK)) then
                    if ZhengbaManager:getMaxNum() == 5 then
                        -- toastMessage("上阵人数已满");
                        toastMessage(localizable.common_function_number_out)
                    else
                        local needLevel = FunctionOpenConfigure:getOpenLevel(700 + (ZhengbaManager:getMaxNum() + 1))
                        if MainPlayer:getLevel() < needLevel then
                            -- toastMessage("团队等级" .. needLevel .. "级可上阵" .. (ZhengbaManager:getMaxNum() + 1) .."人");
                            toastMessage(stringUtils.format(localizable.common_function_up_number, needLevel, ZhengbaManager:getMaxNum() + 1 ))
                        end
                    end
                else
                    ZhengbaManager:OnBattle(EnumFightStrategyType.StrategyType_CHAMPIONS_ATK,cell.gmId, self.curIndex)
                    play_buzhenyidong()

                end

            --阵中操作，更换位置   
            else

                ZhengbaManager:ChangePos(EnumFightStrategyType.StrategyType_CHAMPIONS_ATK,cell.posIndex, self.curIndex)

                play_buzhenyidong()
            end

            return;
        end

        --在右边列表释放
        if (self.curIndex == -1) then

            if (cell.posIndex == -1 ) then

            else
                print("下阵:",dargRole.name);
                ZhengbaManager:OutBattle(EnumFightStrategyType.StrategyType_CHAMPIONS_ATK,cell.gmId)
            end
        end
    end


end

function ZhengbasaiArmyVSLayer:playInspireEffect()
    -- effect_ymg_inspire
    local effect = self.effect
    if effect == nil then
        local resPath = "effect/effect_ymg_inspire.xml"
        TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
        effect = TFArmature:create("effect_ymg_inspire_anim")

        self.panel_left:addChild(effect,2)
        effect:setPosition(ccp(222+70, 310))

        self.effect = effect

        self.effectCompelte = false
        effect:addMEListener(TFARMATURE_COMPLETE,function()
            if self.effect then
                self.effect:setVisible(false)
            end
        end)
    end

    effect:setVisible(true)
    effect:playByIndex(0, -1, -1, 0)
end

return ZhengbasaiArmyVSLayer;
