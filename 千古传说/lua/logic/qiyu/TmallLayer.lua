
local TmallLayer = class("TmallLayer", BaseLayer)

local tmallUrl = "https://pages.tmall.com/wow/portal/act/app-download?type=web&key=https%3A%2F%2Fpages.tmall.com%2Fwow%2Fmit%2Fact%2Fxhxkl&mmstat=jhxiakeling&src=jhxiakeling"

function TmallLayer:ctor()
    self.super.ctor(self)
    self:init("lua.uiconfig_mango_new.qiyu.Tianmao")
    -- QiyuManager:SengQueryEatPigMsg()
end

function TmallLayer:onShow()
    print("TmallLayer onShow")
    self.super.onShow(self)
end

function TmallLayer:initUI(ui)
    self.super.initUI(self,ui)
    self.btn_go = TFDirector:getChildByPath(ui, 'btn_go')
    self.btn_help = TFDirector:getChildByPath(ui, 'btn_help')
end

function TmallLayer:registerEvents(ui)
    self.super.registerEvents(self)
    self.btn_go:addMEListener(TFWIDGET_CLICK, audioClickfun(self.goBtnClickHandle),1)
    self.btn_help:addMEListener(TFWIDGET_CLICK, audioClickfun(self.helpBtnClickHandle),1)
end

function TmallLayer:removeEvents()
    self.super.removeEvents(self)
end

function TmallLayer.goBtnClickHandle(sender)
    -- -- CommonManager:openTmall()
    if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID then
        
        TFDirector:unRequire('TFFramework.utils.TFDeviceInfo')
        require('TFFramework.utils.TFDeviceInfo')

        local ret = TFDeviceInfo:openUrl(tmallUrl)
        
        -- 没有打开网页的接口
        if ret == false then
            CommonManager:openTmall(tmallUrl)
        end
    else
        CommonManager:openTmall(tmallUrl)
    end

end

function TmallLayer.helpBtnClickHandle(sender)
    CommonManager:showRuleLyaer("tianmaojianianhua")
end

return TmallLayer