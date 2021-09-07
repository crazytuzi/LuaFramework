-- @author ###
-- @date 2018年4月28日,星期六

AnniversaryTyModel = AnniversaryTyModel or BaseClass(BaseModel)

function AnniversaryTyModel:__init()

    self.IsInit = true --是否第一次打开面板
    self.LanternList = { }

    self.initLanternList = {
        TI18N("星辰奇缘2周年快乐！成长的路上，感谢有你的陪伴；往后的故事，还想继续与你书写！{face_1,3}{face_1,3}{face_1,3}")
        ,TI18N("发送朋友圈，晒出在星辰奇缘遇到的关于<color='#ffff00'>友情</color>或<color='#ffff00'>爱情</color>的小故事，传达你的心意吧！{face_1,56}")
        ,TI18N("分享在绯月大陆上遇到的<color='#ffff00'>冒险故事</color>与<color='#ffff00'>荣耀时刻</color>，让大家见证你的过去与辉煌！{face_1,25}")
    }

    self.IsFirstLantern = true
end

function AnniversaryTyModel:__delete()
end

function AnniversaryTyModel:OpenWindow(args)
    if self.mainWin == nil then
    end
    self.mainWin:Open(args)
end

function AnniversaryTyModel:CloseWindow()
end

function AnniversaryTyModel:OpenSendStatusWindow(args)
    if self.Statuspanel == nil then
        self.Statuspanel = StatusSendTwoYearPanel.New(self)
    end
    self.Statuspanel:Show(args)
end

function AnniversaryTyModel:CloseSendStatusWindow()
    if self.Statuspanel ~= nil then
        self.Statuspanel:DeleteMe()
        self.Statuspanel = nil
    end
end



function AnniversaryTyModel:OpenGiftPanel(args)
    if self.giftpanel == nil then
        self.giftpanel = AnniversaryTyGiftPanel.New(self)
    end
    self.giftpanel:Show(args)
end

function AnniversaryTyModel:CloseGiftPanel()
    if self.giftpanel ~= nil then
        self.giftpanel:DeleteMe()
        self.giftpanel = nil
    end
end




function AnniversaryTyModel:OpenGiftShow(args)
    if self.giftShow ~= nil then
        self.giftShow:Close()
    end
    if self.giftShow == nil then
        self.giftShow = BackpackGiftShow.New(self)
    end
    self.giftShow:Show(args)
end

function AnniversaryTyModel:CloseGiftShow()
    if self.giftShow ~= nil then
        self.giftShow:DeleteMe()
        self.giftShow = nil
    end
end



