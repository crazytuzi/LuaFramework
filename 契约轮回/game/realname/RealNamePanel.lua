RealNamePanel = RealNamePanel or class("RealNamePanel", WindowPanel)

function RealNamePanel:ctor()
    self.abName = "realname"
    self.assetName = "RealNamePanel"
    self.image_ab = "realname_image";
    self.layer = "UI"
    self.events = {}
    self.use_background = true
    self.show_sidebar = false
    self.panel_type = 3
    self.model = RealNameModel:GetInstance()
end

function RealNamePanel:Reset()

end

function RealNamePanel:dctor()

end

function RealNamePanel:Open()
    WindowPanel.Open(self)
end

function RealNamePanel:LoadCallBack()
    self.nodes =
    {
        "nameIpt","cardIpt","okBtn",
    }
    self:GetChildren(self.nodes)
    SetLocalPosition(self.transform, 0, 0, 0)
    self.nameIpt = GetInputField(self.nameIpt)
    self.cardIpt = GetInputField(self.cardIpt)
    self:AddEvent()
    self:InitUI()
    self:SetTileTextImage("realname_image", "realname_title");
end

function RealNamePanel:OpenCallBack()

end

function RealNamePanel:CloseCallBack()
    GlobalEvent:RemoveTabListener(self.events)
    if not self.model.isRegisterd then --未实名
        RealNameController:GetInstance():RequesNameRealCancel()
        GlobalEvent:Brocast(RealNameEvent.RealNameShowIcon,true)
    end
    self.model = nil
end

function RealNamePanel:InitUI()


end

function RealNamePanel:AddEvent()
    local function call_back()
        if self.nameIpt.text == "" then
            Notify.ShowText("Please enter a valid name")
            return
        end
        if self.cardIpt.text == "" or #self.cardIpt.text ~= 18 then
            Notify.ShowText("Please enter a correct ID number")
            return
        end
        local loginInfo = LoginModel:GetInstance().sdk_login_info.loginInfo
        -- print('--LaoY RealNamePanel.lua,line 69--')
        -- dump(loginInfo,"loginInfo")
        if loginInfo then
            local gameId = tostring(LoginModel:GetInstance():GetGameId())
            local channelid = tostring(loginInfo.channel_id)
            local gameChannelId = tostring(loginInfo.game_channel_id)
            local userId = tostring(loginInfo.uid)
            RealNameController:GetInstance():RequesRealNameRegister(gameId,channelid,gameChannelId,userId,"CN",self.cardIpt.text,self.nameIpt.text)
        else
            RealNameController:GetInstance():RequesRealNameRegister(LoginModel:GetInstance():GetGameId(),LoginModel:GetInstance():GetChannelId(),LoginModel:GetInstance():GetChannelNameById(),0,"CN",self.cardIpt.text,self.nameIpt.text)
        end
        --之后改成Post
    end
    AddButtonEvent(self.okBtn.gameObject,call_back)

    local function call_back(str)
        if string.len(str) < 18 then
            self.cardIpt.text = string.gsub (str, "[A-Za-z]","")
        else
            self.cardIpt.text = string.gsub (str, "[A-Wa-wY-Zy-z]","")
        end
    end
    self.cardIpt.onValueChanged:AddListener(call_back)

    --local function call_back()
    --    print2("1")
    --end
    --self.cardIpt.OnValidateInput = call_back

    self.events[#self.events + 1] =   GlobalEvent:AddListener(RealNameEvent.RealNameRegister, handler(self, self.RealNameRegister))
end

function RealNamePanel:SwitchCallBack(index)

end
function RealNamePanel:RealNameRegister(data)
    if data.succ then --成功
        if data.is_adult then
            Dialog.ShowOne("Verification successful","You have real-name certification, you are an adult player, and you are not limited by the length of online time, I wish you a happy game.","Confirm",handler(self,self.isClose),10)
        else
            Dialog.ShowOne("Verification successful","You have real-name certification, you are a minor player, more than 5 hours, the income will be halved, please pay attention to rest, a reasonable and healthy game!","Confirm",handler(self,self.isClose),10)
           -- RealNameController:GetInstance():RequestRealNameInfo()
        end
        self.model.isRegisterd = true
        --弹窗认证成功
        GlobalEvent:Brocast(RealNameEvent.RealNameShowIcon,false)
    else
        --弹窗认证失败
        local function ok_func()
            
        end
        Dialog.ShowOne("Verification failed",data.msg,"Confirm",ok_func,10)
        GlobalEvent:Brocast(RealNameEvent.RealNameShowIcon,true)
    end
end

function RealNamePanel:isClose()
    self:Close()
end


