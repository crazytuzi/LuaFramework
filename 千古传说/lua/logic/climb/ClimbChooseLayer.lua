--[[
/*code is far away from bug with the animal protecting
    *  ┏┓　　　┏┓
    *┏┛┻━━━┛┻┓
    *┃　　　　　　　┃ 　
    *┃　　　━　　　┃
    *┃　┳┛　┗┳　┃
    *┃　　　　　　　┃
    *┃　　　┻　　　┃
    *┃　　　　　　　┃
    *┗━┓　　　┏━┛
    *　　┃　　　┃神兽保佑
    *　　┃　　　┃代码无BUG！
    *　　┃　　　┗━━━┓
    *　　┃　　　　　　　┣┓
    *　　┃　　　　　　　┏┛
    *　　┗┓┓┏━┳┓┏┛
    *　　　┃┫┫　┃┫┫
    *　　　┗┻┛　┗┻┛ 
    *　　　
    */
]]
local ClimbChooseLayer = class("ClimbChooseLayer", BaseLayer);

CREATE_SCENE_FUN(ClimbChooseLayer);
CREATE_PANEL_FUN(ClimbChooseLayer);


function ClimbChooseLayer:ctor(data)
    self.super.ctor(self,data);
    
    self:init("lua.uiconfig_mango_new.climb.ClimbChoose");
end


function ClimbChooseLayer:initUI(ui)
    self.super.initUI(self,ui);

    self.btn_close         = TFDirector:getChildByPath(ui, 'btn_close');
    self.btn_tiaomu = {}
    self.btn_xuanzhong = {}
    self.jinlu_num = {}

    local img_shengli = TFDirector:getChildByPath(ui, 'img_shengli');
    local img_dilu = TFDirector:getChildByPath(img_shengli, 'img_dilu');
    self.jinlu_num[1] = TFDirector:getChildByPath(img_dilu, 'txt_num');
    for i=1,2 do
        self.btn_tiaomu[i]         = TFDirector:getChildByPath(ui, 'btn_tiaomu'..i);
        self.btn_xuanzhong[i]         = TFDirector:getChildByPath(self.btn_tiaomu[i], 'btn_xuanzhong');
        img_dilu = TFDirector:getChildByPath(self.btn_tiaomu[i], 'img_dilu');
        self.jinlu_num[i+1] = TFDirector:getChildByPath(img_dilu, 'txt_num');
    end
    self.btn_qiehuan        = TFDirector:getChildByPath(ui, 'btn_qiehuan');
    self.btn_kaishi         = TFDirector:getChildByPath(ui, 'btn_kaishi');
    self.txt_price          = TFDirector:getChildByPath(ui, 'txt_price');
    self.changPrice = ConstantData:objectByID("North.Cave.Battle.Options.Refresh").value
    self.txt_price:setText(self.changPrice)
end

function ClimbChooseLayer:onShow()
    self.super.onShow(self)
    self:refreshBaseUI()
    self:refreshUI()
end

function ClimbChooseLayer:refreshBaseUI()

end

function ClimbChooseLayer:refreshUI()
    if self.mountainInfo == nil then
        return
    end
    for i=1,2 do
        self:initOptionInfo(i);
        self:refreshOptionChoice(i);
    end

    for i=1,3 do
        local rewardList = NorthClimbManager:getRewardItemListByIndex(self.mountainInfo.sectionId,i)
        local rewardInfo = rewardList:getObjectAt(1)
        if rewardInfo then
            self.jinlu_num[i]:setText("X"..rewardInfo.number)
        end
    end
end



function ClimbChooseLayer:initOptionInfo( index )
    local txt_shuoming = TFDirector:getChildByPath(self.btn_tiaomu[index] , 'txt_shuoming');
    local options =  self.mountainInfo.options[index]
    local battleInfo = BattleLimitedData:objectByID(options)
    if battleInfo == nil then
        print("通关条件信息 == null ， id ==",options)
        return
    end

    txt_shuoming:setText(battleInfo:getDescribe());
end

function ClimbChooseLayer:refreshOptionChoice( index )
    local txt_shuoming = TFDirector:getChildByPath(self.btn_tiaomu[index] , 'txt_shuoming');
    local img_shitou = TFDirector:getChildByPath(self.btn_tiaomu[index] , 'img_shitou');
    local txt_shitou_num = TFDirector:getChildByPath(img_shitou , 'txt_num');

    local img_dilu = TFDirector:getChildByPath(self.btn_tiaomu[index] , 'img_dilu');
    local txt_dilu_num = TFDirector:getChildByPath(img_dilu , 'txt_num');

    local choice = bit_and(self.mountainInfo.choice,2^(index-1))
    if choice == 0 then
        txt_shuoming:setColor(ccc3(0,0,0))
        txt_shitou_num:setColor(ccc3(0,0,0))
        txt_dilu_num:setColor(ccc3(0,0,0))
        self.btn_xuanzhong[index]:setSelectedState(false)
        self.btn_tiaomu[index]:setTextureNormal("ui_new/climb/btn_tiaozhan.png")
    else
        self.btn_xuanzhong[index]:setSelectedState(true)
        self.btn_tiaomu[index]:setTextureNormal("ui_new/climb/btn_tiaozhan_press.png")
        txt_shuoming:setColor(ccc3(255,255,255))
        txt_shitou_num:setColor(ccc3(255,255,255))
        txt_dilu_num:setColor(ccc3(255,255,255))
    end
end

--填充主页信息
function ClimbChooseLayer:loadMissionInfo(mountainInfo)
    self.mountainInfo = mountainInfo
end


function ClimbChooseLayer.onClickOption(sender)
    local self = sender.logic;
    local index = sender.tag
    local state = sender:getSelectedState();
    if state == true then
        self.mountainInfo.choice = bit_or(self.mountainInfo.choice,2^(index-1))
    else
        self.mountainInfo.choice = bit_xor(self.mountainInfo.choice,2^(index-1))
    end
    self:refreshOptionChoice(index);
end


function ClimbChooseLayer.onBtnClickOption(sender)
    local self = sender.logic;
    local index = sender.tag
    local state = self.btn_xuanzhong[index]:getSelectedState();

    if state == true then
        self.mountainInfo.choice = bit_xor(self.mountainInfo.choice,2^(index-1))
        self.btn_xuanzhong[index]:setSelectedState(false)
    else
        self.mountainInfo.choice = bit_or(self.mountainInfo.choice,2^(index-1))
        self.btn_xuanzhong[index]:setSelectedState(true)
    end

    self:refreshOptionChoice(index);
end

function ClimbChooseLayer.onBtnClickBegin(sender)
    local self = sender.logic;
    NorthClimbManager:ChallengeNorthCave(self.mountainInfo.sectionId,self.mountainInfo.choice)
end

function ClimbChooseLayer.onBtnClickChangOption(sender)
    local self = sender.logic;
    if MainPlayer:isEnough(EnumDropType.SYCEE,self.changPrice) then
        NorthClimbManager:RequestChangeCaveOption(self.mountainInfo.sectionId)
    end
end

function ClimbChooseLayer:removeUI()
    self.super.removeUI(self);

end

function ClimbChooseLayer:registerEvents()
    self.super.registerEvents(self);
    ADD_ALERT_CLOSE_LISTENER(self,self.btn_close)

    for i=1,2 do
        self.btn_xuanzhong[i].logic    = self;
        self.btn_xuanzhong[i].tag = i
        self.btn_xuanzhong[i]:addMEListener(TFWIDGET_TOUCHENDED,  audioClickfun(self.onClickOption),1);
        -- self.btn_xuanzhong[i]:addUnSelectEvent(TFWIDGET_CLICK,  audioClickfun(self.onUnSelectOption),1);

        self.btn_tiaomu[i].logic    = self;
        self.btn_tiaomu[i].tag = i
        self.btn_tiaomu[i]:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onBtnClickOption),1);
    end

    self.btn_kaishi.logic    = self;
    self.btn_kaishi:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onBtnClickBegin),1);
    self.btn_qiehuan.logic    = self;
    self.btn_qiehuan:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onBtnClickChangOption),1);


    self.onReceivNorthCaveChangeOptionSuccess = function(event)
        self.ui:setAnimationCallBack("Action0", TFANIMATION_END, function()
            self:refreshUI()
            self.ui:runAnimation("Action1",1);
        end)
        self.ui:runAnimation("Action0",1);
    end;
    TFDirector:addMEGlobalListener(NorthClimbManager.NORTH_CAVE_CHANGE_OPTION_SUCCESS ,self.onReceivNorthCaveChangeOptionSuccess ) ;
end

function ClimbChooseLayer:removeEvents()
    self.super.removeEvents(self);

    TFDirector:removeMEGlobalListener(NorthClimbManager.NORTH_CAVE_CHANGE_OPTION_SUCCESS,self.onReceivNorthCaveChangeOptionSuccess);
end

return ClimbChooseLayer;
