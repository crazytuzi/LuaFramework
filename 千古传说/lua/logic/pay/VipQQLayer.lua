--[[
******VIP特权列表*******

    -- by haidong.gan
    -- 2013/11/27
]]
local VipQQLayer = class("VipQQLayer", BaseLayer);

CREATE_SCENE_FUN(VipQQLayer);
CREATE_PANEL_FUN(VipQQLayer);

local beautyQQ = "800103310"

function VipQQLayer:ctor(data)
    self.super.ctor(self,data);
    self:init("lua.uiconfig_mango_new.pay.GuiBing");
end

function VipQQLayer:initUI(ui)
    self.super.initUI(self,ui);

    self.img_input_bg  = TFDirector:getChildByPath(ui, 'bg')
    self.btn_close   = TFDirector:getChildByPath(ui, 'btn_close')
    self.btn_djfz    = TFDirector:getChildByPath(ui, 'btn_djfz')
    self.btn_tj    = TFDirector:getChildByPath(ui, 'btn_tj')

    self.input_qq    = TFDirector:getChildByPath(ui, 'input_qq')
    self.input_qq:setCursorEnabled(true)
    self.input_qq:setMaxLength(12)

    self.txt_qq     = TFDirector:getChildByPath(ui, 'txt_qq')
    self.txt_tishi  = TFDirector:getChildByPath(ui, 'txt_tishi')
    
    self.rightList = {}
    for i=1,4 do
        self.rightList[i] = {}
        local right = TFDirector:getChildByPath(ui, '0'..i)
        self.rightList[i].txt_title         = TFDirector:getChildByPath(right, 'biaoti')
        self.rightList[i].txt_content       = TFDirector:getChildByPath(right, 'shuoming')
    end

    self.input_pos_mark = self.img_input_bg:getPosition()
end

function VipQQLayer:onShow()
    self.super.onShow(self)
    self:refreshUI();
end


function VipQQLayer:refreshBaseUI()

end

function VipQQLayer:refreshUI()
    -- if not self.isShow then
    --     return;
    -- end
    
    self.txt_qq:setText(beautyQQ)

    --self.rightList[1].txt_title:setText("专属通道")
    --self.rightList[1].txt_content:setText("这里有贴心的专属美女客服服务哦~")
    self.rightList[1].txt_title:setText(localizable.vipQQLayer_title1)
    self.rightList[1].txt_content:setText(localizable.vipQQLayer_content1)

    --self.rightList[2].txt_title:setText("优先权")
    --self.rightList[2].txt_content:setText("不管是什么活动都能第一时间知晓呢~")
    self.rightList[2].txt_title:setText(localizable.vipQQLayer_title2)
    self.rightList[2].txt_content:setText(localizable.vipQQLayer_content2)

    --self.rightList[3].txt_title:setText("福利")
    --self.rightList[3].txt_content:setText("还有随时可以领的专属礼包和超值福利")
    self.rightList[3].txt_title:setText(localizable.vipQQLayer_title3)
    self.rightList[3].txt_content:setText(localizable.vipQQLayer_content3)

    --self.rightList[4].txt_title:setText("终身制")
    --self.rightList[4].txt_content:setText("终身享受哦~")
    self.rightList[4].txt_title:setText(localizable.vipQQLayer_title4)
    self.rightList[4].txt_content:setText(localizable.vipQQLayer_content4)
    if MainPlayer.qq then
        self.input_qq:setPlaceHolder(MainPlayer.qq)
    else
        --self.input_qq:setPlaceHolder("点击输入QQ号")
        self.input_qq:setPlaceHolder(localizable.vipQQLayer_title1)
    end
end





function VipQQLayer:removeUI()
   self.super.removeUI(self);
end

function VipQQLayer.onPayClickHandle(sender)

end

function VipQQLayer.onGetReardClickHandle(sender)

end

--注册事件
function VipQQLayer:registerEvents()
    self.super.registerEvents(self);

    ADD_ALERT_CLOSE_LISTENER(self,self.btn_close)
    self.btn_djfz.logic = self
    self.btn_djfz:addMEListener(TFWIDGET_CLICK, audioClickfun(self.copQQHandle),1)

    self.btn_tj.logic = self
    self.btn_tj:addMEListener(TFWIDGET_CLICK, audioClickfun(self.submitQQ),1)

    local function onTextFieldChangedHandle(input)
        self.img_input_bg:setPosition(ccp(self.input_pos_mark.x,self.input_pos_mark.y+300))
    end

    --add by david.dai
    --添加输入账号时输入框上移逻辑
    local function onTextFieldAttachHandle(input)
        self.img_input_bg:setPosition(ccp(self.input_pos_mark.x,self.input_pos_mark.y+300))
        self.input_qq:addMEListener(TFTEXTFIELD_TEXTCHANGE, onTextFieldChangedHandle)
    end
    self.input_qq:addMEListener(TFTEXTFIELD_ATTACH, onTextFieldAttachHandle)

    local function onTextFieldDetachHandle(input)
        self.img_input_bg:setPosition(ccp(self.input_pos_mark.x,self.input_pos_mark.y))
        self.input_qq:removeMEListener(TFTEXTFIELD_TEXTCHANGE)
    end

    self.input_qq:addMEListener(TFTEXTFIELD_DETACH, onTextFieldDetachHandle)

    TFDirector:addProto(s2c.VIPINFOMATION, self, self.submitQQCallBack)
end

function VipQQLayer:removeEvents()
    -- TFDirector:removeMEGlobalListener(PayManager.GET_VIP_REWARD_RESULT ,self.getRewardResultCallBack);
    -- TFDirector:removeMEGlobalListener(PayManager.updateVipRewardList ,self.updateRewardListCallBack);

    TFDirector:removeProto(s2c.VIPINFOMATION, self, self.submitQQCallBack)
end

function VipQQLayer.copQQHandle(sender)
    print("拷贝的QQ：", beautyQQ)
    TFDeviceInfo:copyToPasteBord(beautyQQ)
    --toastMessage("复制成功")
    toastMessage(localizable.vipQQLayer_copy_suc)
end

function VipQQLayer.submitQQ(sender)
    local self = sender.logic

    local qq = self.input_qq:getText()

    print("输入的QQ：", qq)
    if string.len(qq) < 1 then
        --toastMessage("请输入qq号码")
        toastMessage(localizable.vipQQLayer_please_input)
        return
    end
    local tel = "NULL"
    showLoading()
    TFDirector:send(c2s.UPGRADE_VIPINFO, {qq,tel})
end

function VipQQLayer:submitQQCallBack( event )
    hideLoading()

    --toastMessage("大侠，已成功提交QQ号")
    toastMessage(localizable.vipQQLayer_submit)
end
-- c2s.UPGRADE_VIPINFO = 0x1a20
-- s2c.VIPINFOMATION = 0x1a20

return VipQQLayer;
