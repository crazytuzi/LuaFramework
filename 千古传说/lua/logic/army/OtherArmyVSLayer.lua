--[[
******布阵-对方详情*******

    -- by haidong.gan
    -- 2013/11/27
]]
local OtherArmyVSLayer = class("OtherArmyVSLayer", BaseLayer);

CREATE_SCENE_FUN(OtherArmyVSLayer);
CREATE_PANEL_FUN(OtherArmyVSLayer);

OtherArmyVSLayer.LIST_ITEM_WIDTH = 200; 

function OtherArmyVSLayer:ctor(data)
    self.super.ctor(self,data);
    self:init("lua.uiconfig_mango_new.arena.OtherArmyVSLayer");
end

function OtherArmyVSLayer:initUI(ui)
    self.super.initUI(self,ui);

    self.btn_close          = TFDirector:getChildByPath(ui, 'btn_close');

    self.btn_challenge  = TFDirector:getChildByPath(ui, 'btn_challenge')
    self.btn_army       = TFDirector:getChildByPath(ui, 'btn_buzhen')

    self.panel_self     = TFDirector:getChildByPath(ui, 'panel_buzhen')
    self.panel_other    = TFDirector:getChildByPath(ui, 'panel_buzhen1')
        

    self.txt_name_self       = TFDirector:getChildByPath(self.panel_self, 'txt_mingcheng_word')
    self.txt_rank_self      = TFDirector:getChildByPath(self.panel_self, 'txt_paiming_word')
    self.txt_power_self     = TFDirector:getChildByPath(self.panel_self, 'txt_zhandouli_word')
    self.txt_winRate_self   = TFDirector:getChildByPath(self.panel_self, 'txt_shenglv_word')

    self.txt_name_other       = TFDirector:getChildByPath(self.panel_other, 'txt_mingcheng_word')
    self.txt_rank_other       = TFDirector:getChildByPath(self.panel_other, 'txt_paiming_word')
    self.txt_power_other      = TFDirector:getChildByPath(self.panel_other, 'txt_zhandouli_word')
    self.txt_winRate_other    = TFDirector:getChildByPath(self.panel_other, 'txt_shenglv_word')


    self.img_rolebg = {}
    self.img_role = {}
    self.img_role_quility = {}

    self.button_self = {};
    for i=1,9 do
        local btnName = "panel_item" .. i;
        self.button_self[i] = TFDirector:getChildByPath(self.panel_self, btnName);

        btnName = "btn_icon"..i;
        self.button_self[i].bg = TFDirector:getChildByPath(self.panel_self, btnName);
        self.button_self[i].bg:setVisible(false);

        self.button_self[i].icon = TFDirector:getChildByPath(self.button_self[i].bg ,"img_touxiang");
        self.button_self[i].icon:setVisible(false);

        self.button_self[i].img_zhiye = TFDirector:getChildByPath(self.button_self[i], "img_zhiye");
        self.button_self[i].img_zhiye:setVisible(false);
        
        self.button_self[i].quality = TFDirector:getChildByPath(self.panel_self, btnName);

        self.button_self[i].icon:setFlipX(true)

        self.button_self[i].bg.logic = self;
        self.button_self[i].bg.posIndex = i;
        self.button_self[i].bg.hasRole = false;

        self.button_self[i].logic = self;
        self.button_self[i].posIndex = i;
        self.button_self[i].hasRole = false; 
    end

    self.button_other = {};
    for i=1,9 do
        local btnName = "panel_item" .. i;
        self.button_other[i] = TFDirector:getChildByPath(self.panel_other, btnName);

        btnName = "btn_icon"..i;
        self.button_other[i].bg = TFDirector:getChildByPath(self.panel_other, btnName);
        self.button_other[i].bg:setVisible(false);

        self.button_other[i].icon = TFDirector:getChildByPath(self.button_other[i].bg ,"img_touxiang");
        self.button_other[i].icon:setVisible(false);

        self.button_other[i].img_zhiye = TFDirector:getChildByPath(self.button_other[i], "img_zhiye");
        self.button_other[i].img_zhiye:setVisible(false);
        
        self.button_other[i].quality = TFDirector:getChildByPath(self.panel_other, btnName);
    end

    local resPath = "effect/arena_attack.xml"
    TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
    local effect = TFArmature:create("arena_attack_anim")

    effect:setAnimationFps(GameConfig.ANIM_FPS)
    effect:setPosition(ccp(self:getSize().width/2 - 15,self:getSize().height/2 - 40))

    self:addChild(effect,20)

    effect:playByIndex(0, -1, -1, 0)
end

function OtherArmyVSLayer:loadData(userData)
    self.userData = userData;
end

function OtherArmyVSLayer:onShow()
    self.super.onShow(self)
    self:refreshBaseUI();
    self:refreshUI();
end

function OtherArmyVSLayer:refreshBaseUI()

end

function OtherArmyVSLayer:refreshUI()
    if not self.isShow then
        return;
    end

    
    self.txt_name_self:setText(MainPlayer:getPlayerName())
    self.txt_power_self:setText(StrategyManager:getPower())

    self.txt_name_other:setText(self.userData.name)
    self.txt_power_other:setText(self.userData.power)

    for index=1,9 do
        local role = StrategyManager:getRoleByIndex(index);
        if  role ~= nil then
            self.button_self[index].icon:setVisible(true);
            self.button_self[index].icon:setTexture(role:getHeadPath());

            self.button_self[index].bg:setVisible(true);
            self.button_self[index].quality:setTextureNormal(GetColorRoadIconByQualitySmall(role.quality));
            -- self.button_self[index].quality:setTextureNormal(GetRoleBgByWuXueLevel_circle_small(role.martialLevel));

            self.button_self[index].img_zhiye:setVisible(true);
            self.button_self[index].img_zhiye:setTexture("ui_new/fight/zhiye_".. role.outline ..".png");

            self.button_self[index].bg.cardRoleId = role.gmId;

            self.button_self[index].bg.gmId  = role.gmId;
            self.button_self[index].bg.hasRole = true;
            Public:addLianTiEffect(self.button_self[index].icon,role:getMaxLianTiQua(),true)
        else
            self.button_self[index].bg.hasRole = false;
            self.button_self[index].img_zhiye:setVisible(false);  
            self.button_self[index].icon:setVisible(false);
            self.button_self[index].bg:setVisible(false);    
            Public:addLianTiEffect(self.button_self[index].icon,0,false) 
        end
    end

    for index=1,9 do
        local role,roleData = self:getRoleBtPos(index);
        if  role ~= nil then
            self.button_other[index].icon:setVisible(true);
            self.button_other[index].icon:setTexture(role:getHeadPath());

            self.button_other[index].bg:setVisible(true);
            self.button_other[index].quality:setTextureNormal(GetColorRoadIconByQualitySmall(roleData.quality));
            -- self.button_other[index].quality:setTextureNormal(GetRoleBgByWuXueLevel_circle_small(roleData.martialLevel));

            self.button_other[index].img_zhiye:setVisible(true);
            self.button_other[index].img_zhiye:setTexture("ui_new/fight/zhiye_".. role.outline ..".png");

            self.button_other[index].bg.cardRoleId = role.id;

            Public:addLianTiEffect(self.button_other[index].icon,roleData.forgingQuality,true)
        else
            self.button_other[index].img_zhiye:setVisible(false);
            self.button_other[index].icon:setVisible(false);
            self.button_other[index].bg:setVisible(false);
            Public:addLianTiEffect(self.button_other[index].icon,0,false)
        end
    end
end

function OtherArmyVSLayer.cellTouchBeganHandle(cell)
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

function OtherArmyVSLayer.cellTouchMovedHandle(cell)
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


function OtherArmyVSLayer.cellTouchEndedHandle(cell)
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

function OtherArmyVSLayer:removeLongTouchTimer()
    if (self.longTouchTimerId) then
        TFDirector:removeTimer(self.longTouchTimerId);
        self.longTouchTimerId = nil;
    end
end

function OtherArmyVSLayer:createSelectCussor(cell,pos)
    play_press();

    cell.isClick = false;

    self.lastPoint = pos;

    local role = CardRoleManager:getRoleByGmid(cell.gmId);
    self.selectCussor = TFImage:create();
    self.selectCussor:setFlipX(true);
    self.selectCussor:setTexture(role:getHeadPath());
    self.selectCussor:setScale(1);
    self.selectCussor:setPosition(ccpAdd(pos,ccp(-0,-0)) );
    self:addChild(self.selectCussor);
    self.selectCussor:setZOrder(100);
   
    self.curIndex = cell.posIndex;
    
end

function OtherArmyVSLayer:moveSelectCussor(cell,pos)
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

function OtherArmyVSLayer:releaseSelectCussor(cell,pos)
    if cell.isClick == false  then

        if (self.curIndex == nil) then
            return;
        end

        local dargRole      = CardRoleManager:getRoleByGmid(cell.gmId);
        local toReplaceRole =  StrategyManager:getRoleByIndex(self.curIndex);


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
                        };
                        showLoading();
                        TFDirector:send(c2s.CHANGE_INDEX,sendMsg);
                        play_buzhenyidong()

                    end
                --要上阵，但是已经到达上限
                elseif (toReplaceRole == nil and not StrategyManager:canAddFightRole()) then
                    if StrategyManager.maxNum == 5 then
                        toastMessage(localizable.common_function_number_out);
                    else
                        local needLevel = FunctionOpenConfigure:getOpenLevel(700 + (StrategyManager.maxNum + 1))
                        if MainPlayer:getLevel() < needLevel then
			    local str = stringUtils.format(localizable.common_function_up_number,needLevel, StrategyManager.maxNum + 1)
                            toastMessage(str);
                        end
                    end 

                --要替换，但是替换对象是主角
                --elseif (toReplaceRole and  toReplaceRole.gmId == MainPlayer:getPlayerId()) then
                --    toastMessage("主角不能下阵");

                --上阵，如果目标存在角色，将其下阵
                else
                    local battle = {cell.gmId,( self.curIndex - 1)}
                    showLoading();
                    TFDirector:send(c2s.TO_BATTLE,{battle})

                    play_buzhenyidong()

                end

            --阵中操作，更换位置   
            else
                local sendMsg = {              
                cell.posIndex - 1,
                self.curIndex - 1,   
                };
                showLoading();
                TFDirector:send(c2s.CHANGE_INDEX,sendMsg);

                play_buzhenyidong()
            end

            return;
        end

        --在右边列表释放
        if (self.curIndex == -1) then

            if (cell.posIndex == -1 ) then
                --放弃上阵，不做操作

            else
                --下阵
                --if (dargRole.gmId == MainPlayer:getPlayerId()) then
                --    toastMessage("主角不能下阵");
                --else
                    print("下阵:",dargRole.name);
                    showLoading();
                    TFDirector:send(c2s.OUT_BATTLE,{cell.gmId});
                    play_buzhenluoxia();
                --end
            end
        end
    end

    if cell:hitTest(pos) then     
        -- OtherArmyVSLayer.cellClickHandle(cell);
    end
end

function OtherArmyVSLayer:getRoleBtPos(pos)
    for _,v in pairs(self.userData.warside) do
        local idx = v.warIndex + 1
        if idx == pos then
            return RoleData:objectByID(v.id),OtherPlayerManager.cardRoleDic[v.id];
        end
    end
end

function OtherArmyVSLayer.openOtherRoleInfo(sender)
    local self = sender.logic;
    local cardRoleId = sender.cardRoleId;
    OtherPlayerManager:openRoleInfo(self.userData,cardRoleId);
end

function OtherArmyVSLayer.openRoleInfo(sender)
    local self = sender.logic;
    if sender.isClick == true then
        local cardRoleId = sender.cardRoleId;
        CardRoleManager:openRoleInfo(cardRoleId);
    end
end

function OtherArmyVSLayer.onArmyClickHandle(sender)
    local self = sender.logic;
    CardRoleManager:openRoleList();
end

function OtherArmyVSLayer:getChangeBtn()
    return self.btn_challenge
end

--注册事件
function OtherArmyVSLayer:registerEvents()
   self.super.registerEvents(self);
   ADD_ALERT_CLOSE_LISTENER(self,self.btn_close);
   self.btn_close:setClickAreaLength(100);

    self.updatePosCallBack = function(event)
        self:refreshUI()
    end;
    TFDirector:addMEGlobalListener(StrategyManager.UPDATE_STARTEGY_POS ,self.updatePosCallBack ) ;



    self.btn_army.logic = self;
    self.btn_army:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onArmyClickHandle),1);

    for i=1,9 do
        self.button_self[i].bg.logic = self;
        self.button_self[i].bg:addMEListener(TFWIDGET_CLICK, audioClickfun(self.openRoleInfo),1);

        self.button_self[i].bg:addMEListener(TFWIDGET_TOUCHBEGAN, self.cellTouchBeganHandle,1);
        self.button_self[i].bg:addMEListener(TFWIDGET_TOUCHMOVED, self.cellTouchMovedHandle);
        self.button_self[i].bg:addMEListener(TFWIDGET_TOUCHENDED, self.cellTouchEndedHandle);    
    end

    for i=1,9 do
        self.button_other[i].bg.logic = self;
        self.button_other[i].bg:addMEListener(TFWIDGET_CLICK, audioClickfun(self.openOtherRoleInfo),1);
    end
    
   self.btn_challenge.logic = self;
end

function OtherArmyVSLayer:removeEvents()
    TFDirector:removeMEGlobalListener(StrategyManager.UPDATE_STARTEGY_POS, self.updatePosCallBack );
    self.updatePosCallBack = nil;
end

return OtherArmyVSLayer;
