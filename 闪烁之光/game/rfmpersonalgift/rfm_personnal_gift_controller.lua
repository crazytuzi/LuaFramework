--******** 文件说明 ********
-- @Author:      yuanqi@shiyue.com
-- @description:
-- @DateTime:    2020-03-18
RfmPersonnalGiftController = RfmPersonnalGiftController or BaseClass(BaseController)

function RfmPersonnalGiftController:config()
    self.dispather = GlobalEvent:getInstance()
end

function RfmPersonnalGiftController:registerEvents()
end

function RfmPersonnalGiftController:registerProtocals()
    --RFM个人推送礼包
    self:RegisterProtocal(28900, "handle28900")
    self:RegisterProtocal(28901, "handle28901")
end

function RfmPersonnalGiftController:sender28900()
    self:SendProtocal(28900)
end

function RfmPersonnalGiftController:handle28900(data)
    GlobalEvent:getInstance():Fire(RfmPersonnalGiftEvent.Rfm_Personal_Gift_Event, data)
end

function RfmPersonnalGiftController:handle28901(data)
    if data.flag == 1 then
        delayOnce(function() self:openRfmPersonalGiftView(true) end,0.3)
    end
end

--打开个人推送界面
function RfmPersonnalGiftController:openRfmPersonalGiftView(status)
    if status == true then
        if GuideController:getInstance():isInGuide() then return end -- 在剧情或者在引导中不处理
        if StoryController:getInstance():getModel():isStoryState() then return end
        if not self.rfm_personal_gift_view then
            self.rfm_personal_gift_view = RfmPersonnalGiftWindow.New()
        end
        self.rfm_personal_gift_view:open()
    else
        if self.rfm_personal_gift_view then
            self.rfm_personal_gift_view:close()
            self.rfm_personal_gift_view = nil
        end
    end
end

function RfmPersonnalGiftController:__delete()
end
