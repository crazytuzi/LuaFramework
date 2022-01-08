--[[
******布阵-对方详情*******

    -- by haidong.gan
    -- 2013/11/27

    -- modify by king
    -- 2014/8/18
]]
local BloodybattleOtherArmyVSLayer = class("BloodybattleOtherArmyVSLayer", BaseLayer);
-- local CardRole = require('lua.gamedata.base.CardRole')
CREATE_SCENE_FUN(BloodybattleOtherArmyVSLayer);
CREATE_PANEL_FUN(BloodybattleOtherArmyVSLayer);

BloodybattleOtherArmyVSLayer.LIST_ITEM_WIDTH = 200; 

function BloodybattleOtherArmyVSLayer:ctor(data)
    self.super.ctor(self,data);
    self:init("lua.uiconfig_mango_new.bloodybattle.BloodybattleOtherArmyVSLayer");
    self.firstShow = true
end

function BloodybattleOtherArmyVSLayer:initUI(ui)
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
    self.txt_guwu1     = TFDirector:getChildByPath(ui, 'txt_guwu1')
    self.txt_times     = TFDirector:getChildByPath(ui, 'txt_times')
    self.txt_guwu2     = TFDirector:getChildByPath(ui, 'txt_guwu2')
    self.txt_effect    = TFDirector:getChildByPath(ui, 'txt_effect')    
    self.txt_inspireNum     = TFDirector:getChildByPath(ui, 'txt_inspireNum')

    self.inspireBtnList = {}
    for i=1,2 do
        self.inspireBtnList[i] = {}
        self.inspireBtnList[i].btn_inspire  = TFDirector:getChildByPath(ui, 'btn_inspire'..i)
        self.inspireBtnList[i].img_money    = TFDirector:getChildByPath(ui, 'img_money'..i)
        self.inspireBtnList[i].txt_num      = TFDirector:getChildByPath(ui, 'txt_num'..i)
        self.inspireBtnList[i].txt_effect   = TFDirector:getChildByPath(ui, 'txt_effect'..i)

        self.inspireBtnList[i].btn_inspire.logic = self
        self.inspireBtnList[i].btn_inspire.tag   = i
        self.inspireBtnList[i].btn_inspire:addMEListener(TFWIDGET_CLICK,audioClickfun(self.onBtnInspireClickHandle))
    end
end

function BloodybattleOtherArmyVSLayer:loadData(userData)
    self.userData = userData

    BloodFightManager:requestRoleList()
end

function BloodybattleOtherArmyVSLayer:onShow()
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

function BloodybattleOtherArmyVSLayer:refreshBaseUI()

end

function BloodybattleOtherArmyVSLayer:refreshUI()
    if not self.isShow then
        return;
    end
    CommonManager:setRedPoint(self.btn_buzhen, AssistFightManager:isCanRedPoint( LineUpType.LineUp_BloodyBattle ),"isHaveCanZhaomu",ccp(0,0))
end

function BloodybattleOtherArmyVSLayer:getRoleBtPos(pos)
    for _,v in pairs(self.userData.roles) do
        local idx = v.index + 1
        if idx == pos then
            local roleId = v.profession
            local cardRole = clone(RoleData:objectByID(roleId));
            -- self.cardRole   = CardRole:new(self.roleid)
            cardRole.level  = v.lv
            cardRole.maxHp  = v.maxHp
            cardRole.currHp = v.currHp
            return cardRole
        end
    end
end
function BloodybattleOtherArmyVSLayer:getRoleInfoBtPos(pos)
    for _,v in pairs(self.userData.roles) do
        local idx = v.index + 1
        if idx == pos then
            return v
        end
    end
end

function BloodybattleOtherArmyVSLayer.cellClickHandle(sender)
    local self = sender.logic;
    local cardRoleId = sender.cardRoleId;
    -- OtherPlayerManager:openRoleInfo(self.userData,cardRoleId);
    -- print("cardRoleId = ", cardRoleId)
    -- local cardRole   = CardRole:new(cardRoleId)
    -- print("sender.role = ", sender.role)
    Public:ShowItemTipLayer(sender.role.id, EnumDropType.ROLE, 1,sender.role.level)
    -- CardRoleManager:openRoleSimpleInfo(sender.role)
end

function BloodybattleOtherArmyVSLayer.onArmyClickHandle(sender)
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

function BloodybattleOtherArmyVSLayer:getChangeBtn()
    return self.btn_challenge
end

--注册事件
function BloodybattleOtherArmyVSLayer:registerEvents()
   self.super.registerEvents(self);
   ADD_ALERT_CLOSE_LISTENER(self,self.btn_close);
   self.btn_close:setClickAreaLength(100);
    
   
    self.btn_army.logic = self;
    self.btn_army:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onBtnAttackClickHandle),1);


    local function enterStarge(sender)
        BloodFightManager:openRoleList(self.userData.section)
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
        toastMessage(localizable.bloodBattleMainLayer_up_success)
        self:playInspireEffect()
        self:drawInspire()

    end
    TFDirector:addMEGlobalListener(BloodFightManager.MSG_INSPIRE_RESULT, self.inspireUpdate) ;


    self.requestRoleList = function(event)
        -- BloodFightManager:openRoleList(self.section)
        self:drawLeftArea()
        self:drawInspire()
    end;

    TFDirector:addMEGlobalListener(BloodFightManager.MSG_REQUEST_ROLELIST_RESULT, self.requestRoleList)


    self.updatePosCallBack = function(event)
        self:drawLeftArea()
    end
    TFDirector:addMEGlobalListener(BloodFightManager.UPDATE_STARTEGY_POS ,self.updatePosCallBack )


    self.tryConnectNetAgain = function(event)
        AlertManager:close(AlertManager.TWEEN_NONE)
    end
    TFDirector:addMEGlobalListener(CommonManager.TRY_RECONNECT_NET ,self.tryConnectNetAgain)
    
end

function BloodybattleOtherArmyVSLayer:removeEvents()
    TFDirector:removeMEGlobalListener(BloodFightManager.MSG_INSPIRE_RESULT, self.inspireUpdate);
    self.inspireUpdate = nil;


    TFDirector:removeMEGlobalListener(BloodFightManager.MSG_REQUEST_ROLELIST_RESULT, self.requestRoleList)
    self.requestRoleList = nil;


    TFDirector:removeMEGlobalListener(BloodFightManager.UPDATE_STARTEGY_POS ,self.updatePosCallBack ) 
    self.updatePosCallBack = nil;

    TFDirector:removeMEGlobalListener(CommonManager.TRY_RECONNECT_NET ,self.tryConnectNetAgain)
    self.tryConnectNetAgain = nil

    self.super.removeEvents(self)
     self.firstShow = true
end


function BloodybattleOtherArmyVSLayer:drawLeftArea()
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

        self.button[i].bar_bg       = TFDirector:getChildByPath(self.button[i],"img_xuetiao"..i);
        self.button[i].bar_hp       = TFDirector:getChildByPath(self.button[i],"bar_xuetiao"..i);
        self.button[i].img_type     = TFDirector:getChildByPath(self.button[i],"img_zhiye");
        self.button[i].img_death    = TFDirector:getChildByPath(self.button[i],"img_death"..i);


        self.button[i].quality = TFDirector:getChildByPath(self.panel_left, btnName);

        self.button[i].img_death:setVisible(false)

        -- local role = self:getRoleBtPos(i);
        self.button[i].bg.gmid = 0
        local role , isMercenary= BloodFightManager:getRoleByIndex(i);
        self.button[i].bg.hasRole = false
        self.button[i].bg.gmId = 0
        if  role ~= nil and isMercenary == 1 then
            local roleInfo = RoleData:objectByID(role.roleId)
            if roleInfo then
                self.button[i].bg.gmId = role.instanceId
                self.button[i].bg.hasRole = true
                self.button[i].bg.gmid = role.instanceId
                
                self.button[i].icon:setVisible(true);

                self.button[i].icon:setTexture(roleInfo:getHeadPath());

                self.button[i].bg:setVisible(true);
                self.button[i].quality:setTextureNormal(GetColorRoadIconByQualitySmall(role.quality));
                -- self.button[i].quality:setTextureNormal(GetRoleBgByWuXueLevel_circle_small(role.martialLevel));

                self.button[i].bg.cardRoleId = role.roleId;
                self.button[i].bg.role = role;

                self.button[i].img_type:setVisible(true);
                self.button[i].img_type:setTexture("ui_new/fight/zhiye_".. roleInfo.outline ..".png");
                

                local maxHp = role.blood_maxHp
                local curHp = role.blood_curHp
                if maxHp == nil or curHp == nil then
                    local attributes = GetAttrByString(role.attributes)
                    maxHp = attributes[1]
                    curHp = role.hp
                end
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
                self.button[i].icon:setVisible(true);
                self.button[i].bg:setVisible(true);

                -- self.button[i].icon:setFlipX(true)
                Public:addLianTiEffect(self.button[i].icon,role.forgingQuality,true)
            end
        elseif  role ~= nil and isMercenary == 0 then

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
        
            local maxHp = role.blood_maxHp
            local curHp = role.blood_curHp

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
            self.button[i].icon:setVisible(true);
            self.button[i].bg:setVisible(true);

            -- self.button[i].icon:setFlipX(true)
            Public:addLianTiEffect(self.button[i].icon,role:getMaxLianTiQua(),true)
        else
            self.button[i].icon:setVisible(false);
            self.button[i].bg:setVisible(false);     
        
            self.button[i].bar_bg:setVisible(false)
            self.button[i].img_type:setVisible(false)
            Public:addLianTiEffect(self.button[i].icon,0,false)
        end
    end

    local txt_name = TFDirector:getChildByPath(self.panel_left, "txt_name")
    local txt_zhanli = TFDirector:getChildByPath(self.panel_left, "txt_zhanli")
    txt_name:setText(MainPlayer:getPlayerName())
    
    local img_headIcon = TFDirector:getChildByPath(self.panel_left, "img_role")         --pck change head icon and head icon frame
    img_headIcon:setTexture(MainPlayer:getIconPath())
    -- img_headIcon:setFlipX(true)
    Public:addFrameImg(img_headIcon,MainPlayer:getHeadPicFrameId())                     --end
    -- txt_zhanli:setText(BloodFightManager:getPower())
    -- print("BloodFightManager:getPower() = ", BloodFightManager:getPower())
end

function BloodybattleOtherArmyVSLayer:drawRightArea()
    self.button = {}
    for i=1,9 do
        local btnName = "panel_item" .. i;
        self.button[i] = TFDirector:getChildByPath(self.panel_right, btnName);

        btnName = "btn_icon"..i;
        self.button[i].bg = TFDirector:getChildByPath(self.panel_right, btnName);
        self.button[i].bg:setVisible(false);

        self.button[i].icon = TFDirector:getChildByPath(self.button[i].bg ,"img_touxiang");
        self.button[i].icon:setVisible(false);

        self.button[i].bar_bg       = TFDirector:getChildByPath(self.button[i],"img_xuetiao"..i);
        self.button[i].bar_hp       = TFDirector:getChildByPath(self.button[i],"bar_xuetiao"..i);
        self.button[i].img_type     = TFDirector:getChildByPath(self.button[i],"img_zhiye");
        self.button[i].img_death    = TFDirector:getChildByPath(self.button[i],"img_death"..i);

        self.button[i].quality = TFDirector:getChildByPath(self.panel_right, btnName);

        self.button[i].img_death:setVisible(false)

        local role = self:getRoleBtPos(i);
        local roleInfo = self:getRoleInfoBtPos(i);
        if  role ~= nil then
            self.button[i].icon:setVisible(true);
            self.button[i].icon:setTexture(role:getHeadPath());

            self.button[i].bg:setVisible(true);
            self.button[i].quality:setTextureNormal(GetColorRoadIconByQualitySmall(roleInfo.quality));
            -- self.button[i].quality:setTextureNormal(GetRoleBgByWuXueLevel_circle_small(role.martialLevel));

            self.button[i].bg.cardRoleId = role.id;
            self.button[i].bg.role = role;

            self.button[i].img_type:setVisible(true);
            self.button[i].img_type:setTexture("ui_new/fight/zhiye_".. role.outline ..".png");

            if role.currHp <= 0 then
                self.button[i].img_death:setVisible(true)
                self.button[i].icon:setShaderProgram("GrayShader", true)
            end

            self.button[i].bar_hp:setPercent(role.currHp * 100 / role.maxHp)
            Public:addLianTiEffect(self.button[i].icon,roleInfo.forgingQuality,true)
        else
            self.button[i].icon:setVisible(false);
            self.button[i].bg:setVisible(false);     
        
            self.button[i].bar_bg:setVisible(false)
            self.button[i].img_type:setVisible(false)
            Public:addLianTiEffect(self.button[i].icon,0,false)
        end
    end

    local txt_name = TFDirector:getChildByPath(self.panel_right, "txt_name")
    local txt_zhanli = TFDirector:getChildByPath(self.panel_right, "txt_zhanli")
    txt_name:setText(self.userData.name)
    txt_zhanli:setText(self.userData.power)

    local img_headIcon = TFDirector:getChildByPath(self.panel_right, "img_role")         --pck change head icon and head icon frame
    local roleConfig = RoleData:objectByID(self.userData.icon)
    img_headIcon:setTexture(roleConfig:getIconPath())
    Public:addFrameImg(img_headIcon,self.userData.headPicFrame)                         --end

    Public:addInfoListen(img_headIcon,true,2,self.userData.playerId)
end


function BloodybattleOtherArmyVSLayer.onBtnAttackClickHandle(sender)
    local self      = sender.logic
    local section   = self.userData.section

    if BloodFightManager:CheckAllRuleReachBeforeAttack() == false then
        return
    end
    
    AlertManager:close(AlertManager.TWEEN_NONE)
    BloodFightManager:Attack(section)
end

function BloodybattleOtherArmyVSLayer:Attack()
    local section   = self.userData.section

    print("开始挑战")
    
    BloodFightManager:Attack(section)
end

function BloodybattleOtherArmyVSLayer:drawInspire()


    self.inspireList1 = BloodFightManager.inspireList1
    self.inspireList2 = BloodFightManager.inspireList2

    -- 铜币鼓舞的次数
    local inspireListNum = self.inspireList1:length()
    local inspireNum     = BloodFightManager.coinInspireCount + 1

    if inspireNum > inspireListNum then
        inspireNum = inspireListNum
    end

    local coinInspireInfo1 = self.inspireList1:getObjectAt(inspireNum)

   
    -- 元宝鼓舞的次数
    inspireListNum = self.inspireList2:length()
    inspireNum     = BloodFightManager.sysceeInspireCount + 1

    if inspireNum > inspireListNum then
        inspireNum = inspireListNum
    end

    local coinInspireInfo2 = self.inspireList2:getObjectAt(inspireNum)

    for i=1,2 do
        local num       = 0
        local inspire   = 0
        if i == 1 then
            num     = coinInspireInfo1.need_res_num
            inspire = coinInspireInfo1.add_attribute_percent
        elseif i == 2 then
            num     = coinInspireInfo2.need_res_num
            inspire = coinInspireInfo2.add_attribute_percent
        end
        self.inspireBtnList[i].txt_num:setText(num)
        self.inspireBtnList[i].txt_effect:setText("+"..inspire.."%")
    end

    --总的鼓舞次数
    inspireNum = BloodFightManager.coinInspireCount + BloodFightManager.sysceeInspireCount
    self.txt_times:setText(inspireNum)

    --总的鼓舞效果
    -- { id = 1, inspire_count = 1, need_res_type = 3, need_res_num = 100, add_attribute_percent = 30, need_vip_level = 1}
    local totalEffect = 0
    for v in self.inspireList1:iterator() do
        if v.inspire_count <= BloodFightManager.coinInspireCount then --BloodFightManager.coinInspireCount
            totalEffect = totalEffect + v.add_attribute_percent
        end
    end
    
    for v in self.inspireList2:iterator() do
        if v.inspire_count <= BloodFightManager.sysceeInspireCount  then
            totalEffect = totalEffect + v.add_attribute_percent
        end
    end
    totalEffect = totalEffect + VipRuleManager:addInspireEffect()

    self.txt_effect:setText("+"..totalEffect.."%")

    local inspireRemainNum = 0
    -- self.txt_inspireNum
    local CurVip        = MainPlayer:getVipLevel()
    local curVipInfo    = VipData:getVipItemByTypeAndVip(2050, CurVip)
    if curVipInfo then
        local benefit_value = curVipInfo.benefit_value
        inspireRemainNum = benefit_value - inspireNum
        if inspireRemainNum < 0 then
            inspireRemainNum = 0
        end
    end
    self.txt_inspireNum:setText(inspireRemainNum)

    local totalPower = BloodFightManager:getPower()
    print("====totalPower1 = ", totalPower)
    print("totalEffect = ", totalEffect)
    totalPower = totalPower * (100 + totalEffect) / 100
    totalPower = math.ceil(totalPower)
    print("====totalPower2 = ",totalPower)
    local txt_zhanli = TFDirector:getChildByPath(self.panel_left, "txt_zhanli")
    txt_zhanli:setText(totalPower)
end


function BloodybattleOtherArmyVSLayer.onBtnInspireClickHandle(sender)
    local self = sender.logic
    local tag  = sender.tag

    local function showVipDiag(openVip, times)
        CommonManager:showOperateSureLayer(
            function()
                PayManager:showPayLayer();
            end,
            nil,
            {
                title       = localizable.bloodBattleMainLayer_up_vip,
                msg         = stringUtils.format(localizable.bloodBattleMainLayer_up_count,openVip,times),            
                uiconfig    = "lua.uiconfig_mango_new.common.NeedTpPayLayer"
            }
        )
    end


    local inspireNumTotal       = BloodFightManager.coinInspireCount + BloodFightManager.sysceeInspireCount
    local inspireNumWithVip     = 1
 

    local benefit_value = 0
    local CurVip        = MainPlayer:getVipLevel()



    local curVipInfo    = VipData:getVipItemByTypeAndVip(2050, CurVip)

    if curVipInfo then
        benefit_value = curVipInfo.benefit_value
        if inspireNumTotal >= benefit_value then
            local nextVipInfo  = VipData:getVipNextAddValueVip(2050, CurVip)
            if nextVipInfo then
                -- toastMessage("达到Vip"..nextVipInfo.vip_level.."每天可鼓舞"..nextVipInfo.benefit_value.."次")
                showVipDiag(nextVipInfo.vip_level, nextVipInfo.benefit_value)
            else
                toastMessage(localizable.bloodBattleMainLayer_no_times)
            end
            return
        end
    end


    local num       = 0
    local inspire   = 0
    -- 铜币鼓舞
    if tag == 1 then
        -- 铜币鼓舞的次数
        local inspireListNum = self.inspireList1:length()
        local inspireNum     = BloodFightManager.coinInspireCount + 1

        if inspireNum > inspireListNum then
            inspireNum = inspireListNum
        end

        local coinInspireInfo1 = self.inspireList1:getObjectAt(inspireNum)
        num     = coinInspireInfo1.need_res_num
        inspire = coinInspireInfo1.add_attribute_percent
        
        -- 判断资源是否足够刷新
        if MainPlayer:isEnoughCoin(num, true) then
            BloodFightManager:inspireUpgrade(EnumDropType.COIN)
        end
        
    -- 元宝鼓舞
    elseif tag == 2 then

        -- 元宝鼓舞的次数
        inspireListNum = self.inspireList2:length()
        inspireNum     = BloodFightManager.sysceeInspireCount + 1

        if inspireNum > inspireListNum then
            inspireNum = inspireListNum
        end
        local coinInspireInfo2 = self.inspireList2:getObjectAt(inspireNum)
        num     = coinInspireInfo2.need_res_num
        inspire = coinInspireInfo2.add_attribute_percent

        
        if MainPlayer:isEnoughSycee(num, true) then
            BloodFightManager:inspireUpgrade(EnumDropType.SYCEE)
        end
    end

end


function BloodybattleOtherArmyVSLayer.cellTouchBeganHandle(cell)
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

function BloodybattleOtherArmyVSLayer.cellTouchMovedHandle(cell)
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


function BloodybattleOtherArmyVSLayer.cellTouchEndedHandle(cell)
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

function BloodybattleOtherArmyVSLayer:removeLongTouchTimer()
    if (self.longTouchTimerId) then
        TFDirector:removeTimer(self.longTouchTimerId);
        self.longTouchTimerId = nil;
    end
end

function BloodybattleOtherArmyVSLayer:createSelectCussor(cell,pos)
    play_press();

    cell.isClick = false;

    self.lastPoint = pos;

    -- local role = CardRoleManager:getRoleByGmid(cell.gmId);
    local role = RoleData:objectByID(cell.cardRoleId);
    print("cell.cardRoleId=",cell.cardRoleId)
    self.selectCussor = TFImage:create();
    -- self.selectCussor:setFlipX(true);
    self.selectCussor:setTexture(role:getHeadPath());
    self.selectCussor:setScale(1);
    self.selectCussor:setPosition(ccpAdd(pos,ccp(0,-0)) );
    self:addChild(self.selectCussor);
    self.selectCussor:setZOrder(100);
   
    self.curIndex = cell.posIndex;
    
end

function BloodybattleOtherArmyVSLayer:moveSelectCussor(cell,pos)
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

function BloodybattleOtherArmyVSLayer:releaseSelectCussor(cell,pos)
    print("BloodybattleOtherArmyVSLayer:releaseSelectCussor")
    if cell.isClick == false  then
        print("111111111111111111111111BloodybattleOtherArmyVSLayer:releaseSelectCussor = ", self.curIndex)
        if (self.curIndex == nil) then
            return;
        end
        print("2222222222BloodybattleOtherArmyVSLayer:releaseSelectCussor")
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
                        -- local sendMsg = {              
                        -- dargRole.pos - 1,
                        -- self.curIndex - 1,   
                        -- };
                        -- showLoading();
                        -- TFDirector:send(c2s.CHANGE_INDEX,sendMsg);

                        BloodFightManager:ChangePos(dargRole.pos - 1, self.curIndex - 1)

                        play_buzhenyidong()

                    end
                --要上阵，但是已经到达上限
                elseif (toReplaceRole == nil and not StrategyManager:canAddFightRole()) then
                    if StrategyManager.maxNum == 5 then
                        toastMessage(localizable.common_function_number_out);  
                    else
                        local needLevel = FunctionOpenConfigure:getOpenLevel(700 + (StrategyManager.maxNum + 1))
                        if MainPlayer:getLevel() < needLevel then
                           toastMessage(stringUtils.format(localizable.common_function_up_number,needLevel, (StrategyManager.maxNum + 1)) )
                        end
                    end 

                --要替换，但是替换对象是主角
                --elseif (toReplaceRole and  toReplaceRole.gmId == MainPlayer:getPlayerId()) then
                --    toastMessage("主角不能下阵");

                --上阵，如果目标存在角色，将其下阵
                else
                    -- local battle = {cell.gmId,( self.curIndex - 1)}
                    -- showLoading();
                    -- TFDirector:send(c2s.TO_BATTLE,{battle})
                    BloodFightManager:OnBattle(cell.gmId, self.curIndex - 1)
                    play_buzhenyidong()

                end

            --阵中操作，更换位置   
            else
                -- local sendMsg = {              
                -- cell.posIndex - 1,
                -- self.curIndex - 1,   
                -- };
                -- showLoading();
                -- TFDirector:send(c2s.CHANGE_INDEX,sendMsg);

                BloodFightManager:ChangePos(cell.posIndex - 1, self.curIndex - 1)

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
                    BloodFightManager:OutBattle(cell.gmId)
                    -- showLoading();
                    -- TFDirector:send(c2s.OUT_BATTLE,{cell.gmId});
                    -- play_buzhenluoxia();
                --end
            end
        end
    end


end

function BloodybattleOtherArmyVSLayer:playInspireEffect()
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

return BloodybattleOtherArmyVSLayer;
