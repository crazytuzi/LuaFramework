CampaignAutumnModel = CampaignAutumnModel or BaseClass(BaseModel)

function CampaignAutumnModel:__init()
    self.helpWin = nil
    self.friendWin = nil

    self.replyList = {
    [1] =  "<color='#00ff00'>%s</color>英勇举起大刀，成功砍掉了<color='#b031d5'>%s</color>钻"
    ,[2] = "咔擦一声，<color='#00ff00'>%s</color>成功砍掉了<color='#b031d5'>%s</color>钻！"
    ,[3] = "<color='#00ff00'>%s</color>成功砍了<color='#b031d5'>%s</color>钻，离礼包最低价又靠近了一步！"
    ,[4] = "价高也不怕，<color='#00ff00'>%s</color>成功挥起大刀砍掉了<color='#b031d5'>%s</color>钻~"
    ,[5] = "<color='#00ff00'>%s</color>拿起斧子，勇往直前，成功砍下了<color='#b031d5'>%s</color>钻，赞！"
    ,[6] = "<color='#00ff00'>%s</color>成功砍掉了<color='#b031d5'>%s</color>钻"
    ,[7] = "<color='#00ff00'>%s</color>，小手一出，成功帮忙砍掉<color='#b031d5'>%s</color>钻吧"
    }


      self.replyFriendList = {
    [1] =  "<color='#b031d5'>%s</color>英勇举起大刀，成功砍掉了<color='#ffff00'>%s</color>钻"
    ,[2] = "咔擦一声，<color='#b031d5'>%s</color>成功砍掉了<color='#ffff00'>%s</color>钻！"
    ,[3] = "<color='#b031d5'>%s</color>成功砍了<color='#ffff00'>%s</color>钻，离礼包最低价又靠近了一步！"
    ,[4] = "价高也不怕，<color='#b031d5'>%s</color>成功挥起大刀砍掉了<color='#ffff00'>%s</color>钻~"
    ,[5] = "<color='#b031d5'>%s</color>拿起斧子，勇往直前，成功砍下了<color='#ffff00'>%s</color>钻，赞！"
    ,[6] = "<color='#b031d5'>%s</color>成功砍掉了<color='#ffff00'>%s</color>钻"
    ,[7] = "<color='#b031d5'>%s</color>，小手一出，成功帮忙砍掉<color='#ffff00'>%s</color>钻吧"
    }
end

function CampaignAutumnModel:__delete()
    if self.helpWin ~= nil then
        self.helpWin:DeleteMe()
        self.helpWin = nil
    end

    if self.friendWin == nil then
        self.friendWin:DeleteMe()
        self.friendWin = nil
    end
end

function CampaignAutumnModel:OpenHelpWindow(args)
    if self.helpWin == nil then
        self.helpWin = CampaignAutumnHelpWindow.New(self)
    end
    self.helpWin:Open(args)
end


function CampaignAutumnModel:OpenFriendWindow(args)
    if self.friendWin == nil then
        self.friendWin = CampaignAutumnFriendWindow.New(self)
    end
    self.friendWin:Open(args)
end
