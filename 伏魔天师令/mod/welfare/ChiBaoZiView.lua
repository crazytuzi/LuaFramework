local ChiBaoZiView = classGc(view, function(self)
    self.playerlv = _G.GPropertyProxy : getMainPlay() : getLv()
end)

local FONTSIZE    = 20

function ChiBaoZiView.create(self)
    self.m_container = cc.Node : create()

    self.BaoZiBg = cc.Sprite:create("ui/bg/chibaozi.png")
    self.BaoZiBg : setScale(1.02)
    self.BaoZiBg : setPosition(110, -42)
    self.m_container : addChild(self.BaoZiBg)
    local bgSize=self.BaoZiBg:getContentSize()

    local wucanLab = _G.Util:createLabel("在线领取体力时间：", FONTSIZE)
    -- wucanLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GOLD))   
    wucanLab : setPosition(bgSize.width/2-50, 162)
    self.BaoZiBg : addChild(wucanLab)

    local wufanLab = _G.Util:createLabel("18:00-20:00", FONTSIZE)
    wufanLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GOLD))   
    wufanLab : setPosition(bgSize.width/2+100, 162)
    self.BaoZiBg : addChild(wufanLab)

    -- local wancanLab = _G.Util:createLabel("晚餐", FONTSIZE)
    -- wancanLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GOLD))   
    -- wancanLab : setPosition(bgSize.width/2+45, 160)
    -- self.BaoZiBg : addChild(wancanLab)

    -- local wanfanLab = _G.Util:createLabel("17:30-20:00", FONTSIZE)
    -- -- wanfanLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_DARKPURPLE))   
    -- wanfanLab : setPosition(bgSize.width/2+125, 160)
    -- self.BaoZiBg : addChild(wanfanLab)

    local function onButtonCallBack(sender, eventType)
        self : onBtnCallBack(sender, eventType)
    end
    self.RewardBtn = gc.CButton : create("general_btn_gold.png")
    self.RewardBtn : setTitleText("领取体力")
    self.RewardBtn : setTitleFontName(_G.FontName.Heiti)
    self.RewardBtn : setTitleFontSize(FONTSIZE+2)
    self.RewardBtn : setPosition(cc.p(bgSize.width/2, 85))
    self.RewardBtn : addTouchEventListener(onButtonCallBack)
    self.BaoZiBg  : addChild(self.RewardBtn)

    local canTake=false
    local _buffData=_G.GOpenProxy:getEnergyBuffActivityInfo()
    if _buffData ~= nil then
        local id=_buffData.id
        if id~=nil and _buffData.state~=nil and id==_G.Const.CONST_FUNC_OPEN_ENARGY then
            if _buffData.state~=1 then
                -- 可以领取
                canTake=true
            end
        end
    end
    if canTake then
        self.RewardBtn : setEnabled(true)
        self.RewardBtn : setBright(true)
    else
        self.RewardBtn : setEnabled(false)
        self.RewardBtn : setBright(false)
    end

    return self.m_container
end

function ChiBaoZiView.Success(self)
    _G.Util:playAudioEffect("ui_receive_awards")
end

function ChiBaoZiView.onBtnCallBack(self,sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        print("chibaozi")
        self.RewardBtn : setEnabled(false)
        self.RewardBtn : setBright(false)
        local msg=REQ_ROLE_BUFF_REQUEST()
        _G.Network:send(msg)
    end 
end

return ChiBaoZiView