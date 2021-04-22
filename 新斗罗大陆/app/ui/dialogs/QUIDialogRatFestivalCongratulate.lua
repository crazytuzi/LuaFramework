--
-- Kumo.Wang
-- 鼠年春节活动——恭喜獲得
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogRatFestivalCongratulate = class("QUIDialogRatFestivalCongratulate", QUIDialog)

local QRichText = import("...utils.QRichText")
local QUIWidgetRatFestival = import("..widgets.QUIWidgetRatFestival")

function QUIDialogRatFestivalCongratulate:ctor(options)
    local ccbFile = "ccb/Dialog_RatFestival_Congratulate.ccbi"
    local callBacks = {}
    QUIDialogRatFestivalCongratulate.super.ctor(self, ccbFile, callBacks, options)
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page:setAllUIVisible(false)
    page:setScalingVisible(true)
    
    CalculateUIBgSize(self._ccbOwner.sp_bg)

    if options then
        self._luckyCardCount = options.luckyCardCount
        self._awardCount = options.awardCount
        self._isGetAllCard = options.isGetAllCard
        self._callback = options.callback
    end

    if self._isGetAllCard then
        QSetDisplayFrameByPath(self._ccbOwner.sp_title_1, "ui/update_ratFestival/sp_words_fuxinggaozhao.png")
        QSetDisplayFrameByPath(self._ccbOwner.sp_title_2, "ui/update_ratFestival/sp_words_fuxinggaozhao.png")
    else
        QSetDisplayFrameByPath(self._ccbOwner.sp_title_1, "ui/update_ratFestival/sp_words_fulushuangquan.png")
        QSetDisplayFrameByPath(self._ccbOwner.sp_title_2, "ui/update_ratFestival/sp_words_fulushuangquan.png")
    end

    self._isPlaying = true
    self._ccbOwner.fca_effect:stopAnimation()
    self._ccbOwner.fca_effect:setVisible(false)
end

function QUIDialogRatFestivalCongratulate:viewDidAppear()
    QUIDialogRatFestivalCongratulate.super.viewDidAppear(self)

    self:_setInfo()
end

function QUIDialogRatFestivalCongratulate:viewWillDisappear()
    QUIDialogRatFestivalCongratulate.super.viewWillDisappear(self)
end

function QUIDialogRatFestivalCongratulate:_setInfo()
    self._ccbOwner.tf_award_count:setString(self._awardCount or 0)
    self._ccbOwner.tf_card_count:setString(self._luckyCardCount or 0)

    scheduler.performWithDelayGlobal(function ()
        local fca = self._ccbOwner.fca_effect
        fca:stopAnimation()
        fca:connectAnimationEventSignal(function(eventType, trackIndex, animationName, loopCount)
                if eventType == SP_ANIMATION_END or eventType == SP_ANIMATION_COMPLETE then
                    fca:disconnectAnimationEventSignal()
                    fca:setVisible(false)
                    self._isPlaying = false
                end
            end)
        fca:setVisible(true)
        fca:playAnimation("animation", false)
    end, 6/30)
end 

function QUIDialogRatFestivalCongratulate:_backClickHandler()
    if self._isPlaying then return end

    local callback = self._callback
    self:popSelf()

    if callback then
        callback()
    end
end

return QUIDialogRatFestivalCongratulate