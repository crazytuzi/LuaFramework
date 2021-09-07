CampaignInquiryModel = CampaignInquiryModel or BaseClass(BaseModel)

function CampaignInquiryModel:__init()
end

function CampaignInquiryModel:__delete()
end

function CampaignInquiryModel:OpenWindow(args)
     if self.mainWin == nil then
        self.mainWin = CampaignInquiryWindow.New(self)
    end
    self.mainWin:Open(args)
end

function CampaignInquiryModel:OpenSelectWindow(args)
     if self.selectWin == nil then
        self.selectWin = CampaignInquirySelectWindow.New(self)
    end
    self.selectWin:Open(args)
end



function CampaignInquiryModel:CloseWindow()
    if self.mainWin ~= nil then
        WindowManager.Instance:CloseWindowById(WindowConfig.WinID.campaign_uniwin)
        WindowManager.Instance:CloseWindow(self.mainWin)
    end
end


function CampaignInquiryModel:CloseSelectWindow()
    if self.selectWin ~= nil then
        WindowManager.Instance:CloseWindow(self.selectWin)
    end
end


