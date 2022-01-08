--[[
******操作确定层*******

    -- by Stephen.tao
    -- 2014/2/27
]]

local ReplyLayer = class("ReplyLayer", BaseLayer)

--CREATE_SCENE_FUN(ReplyLayer)
CREATE_PANEL_FUN(ReplyLayer)


function ReplyLayer:ctor(data)
    self.super.ctor(self,data)

    self:init("lua.uiconfig_mango_new.common.ReplyLayer")
end

function ReplyLayer:setType(type,isadd)
    self.type = type;

    local timesInfo = MainPlayer:GetChallengeTimesInfo(self.type);
   
    --self.need = 0;
    local resConfig = PlayerResConfigure:objectByID(type)
    local maxBuyTime = resConfig:getMaxBuyTime(MainPlayer:getVipLevel())
    self.need = resConfig:getPrice(timesInfo.todayBuyTime + 1)
    if self.need == nil then
        self.need = 400
    end
    local amount = resConfig.amount
    if self.type == EnumRecoverableResType.PUSH_MAP then
        --self.txt_title:setText(isadd and "购买体力" or "体力不足" );
        self.txt_title:setText(isadd and localizable.replayLayer_buy_tili or localizable.replayLayer_no_tili );
        --self.txt_content:setText("是否花费" .. self.need .. "元宝购买" .. amount .. "点体力？" );
        self.txt_content:setText(stringUtils.format(localizable.replayLayer_buy_tili_tips,self.need,amount))
        --self.txt_des:setText("(今日还可以购买" .. maxBuyTime - timesInfo.todayBuyTime .. "次)");
        self.txt_des:setText(stringUtils.format(localizable.replayLayer_today_left_times,maxBuyTime - timesInfo.todayBuyTime))
        self.txt_des:setColor(ccc3(0,   0,   0));
    end

    if self.type == EnumRecoverableResType.CLIMB then
        --self.txt_title:setText(isadd and "购买无量山石" or "无量山石不足" );
        self.txt_title:setText(isadd and localizable.replayLayer_buy_climb or localizable.replayLayer_no_climb )
        --self.txt_content:setText("是否花费" .. self.need .. "元宝补充" .. amount .. "次挑战机会？")
        self.txt_content:setText(stringUtils.format(localizable.replayLayer_buy_climb_tips,self.need,amount))
        --self.txt_des:setText("(今日还可以购买" .. maxBuyTime - timesInfo.todayBuyTime .. "次)");
        self.txt_des:setText(stringUtils.format(localizable.replayLayer_today_left_times,maxBuyTime - timesInfo.todayBuyTime))
        self.txt_des:setColor(ccc3(0,   0,   0));
    end

    if self.type == EnumRecoverableResType.QUNHAO then
        --self.txt_title:setText(isadd and "购买挑战令" or "挑战令不足" );
        self.txt_title:setText(isadd and localizable.replayLayer_buy_fight or localizable.replayLayer_no_fight );
       -- self.txt_content:setText("是否花费" .. self.need .. "元宝购买" .. amount .. "个挑战令?" );
        self.txt_content:setText(stringUtils.format(localizable.replayLayer_buy_fight_tips ,self.need ,amount) );
        --self.txt_des:setText("(今日还可以购买" .. maxBuyTime - timesInfo.todayBuyTime .. "次)");
        self.txt_des:setText(stringUtils.format(localizable.replayLayer_today_left_times,maxBuyTime - timesInfo.todayBuyTime));
        self.txt_des:setColor(ccc3(0,   0,   0));
    end

    if self.type == EnumRecoverableResType.SKILL_POINT then
       -- self.txt_title:setText(isadd and "补满技能点" or "技能点不足" );
	self.txt_title:setText(isadd and localizable.replayLayer_buy_skill or localizable.replayLayer_no_skill )
        --self.txt_content:setText("是否花费" .. self.need .. "元宝购买10点技能点？" );
	self.txt_content:setText(stringUtils.format(localizable.replayLayer_buy_skill_tips,self.need))
        --self.txt_des:setText("(今日还可以购买" .. maxBuyTime - timesInfo.todayBuyTime .. "次)");
	self.txt_des:setText(stringUtils.format(localizable.replayLayer_today_left_times,maxBuyTime - timesInfo.todayBuyTime))
        self.txt_des:setColor(ccc3(0,   0,   0));
    end

    if self.type == EnumRecoverableResType.BAOZI then
        self.txt_title:setText(isadd and localizable.youli_text4 or localizable.youli_text5 );
        self.txt_content:setText(stringUtils.format(localizable.youli_text6, self.need))

        self.txt_des:setText(stringUtils.format(localizable.youli_text7, maxBuyTime - timesInfo.todayBuyTime))
        self.txt_des:setColor(ccc3(0,   0,   0));
    end

    if self.type == EnumRecoverableResType.SHALU_COUNT then
        self.txt_title:setText(isadd and localizable.youli_text16 or localizable.youli_text17 );
        self.txt_content:setText(stringUtils.format(localizable.youli_text18, self.need))

        self.txt_des:setText(stringUtils.format(localizable.youli_text7, maxBuyTime - timesInfo.todayBuyTime))
        self.txt_des:setColor(ccc3(0,   0,   0));
    end
end

function ReplyLayer:initUI(ui)
	self.super.initUI(self,ui)

    self.btn_ok             = TFDirector:getChildByPath(ui, 'btn_ok')
    self.btn_cancel         = TFDirector:getChildByPath(ui, 'btn_cancel')
    self.txt_content        = TFDirector:getChildByPath(ui, 'txt_content')
    self.txt_des            = TFDirector:getChildByPath(ui, 'txt_des')
    self.txt_title          = TFDirector:getChildByPath(ui, 'txt_title')

end

function ReplyLayer:removeUI()
	self.super.removeUI(self)
end


function ReplyLayer.onOkClickHandle(sender)
    local self = sender.logic;
    local replytype = self.type;

    if not MainPlayer:isEnoughSycee( self.need , true) then
        return;
    end

    CommonManager:reply(replytype);
end


function ReplyLayer:registerEvents()
    self.super.registerEvents(self)
    ADD_ALERT_CLOSE_LISTENER(self,self.btn_cancel);

    self.btn_ok.logic = self;
    self.btn_ok:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onOkClickHandle),1)
end


return ReplyLayer
