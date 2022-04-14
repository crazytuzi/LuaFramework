RoleMenuPanel = RoleMenuPanel or class("RoleMenuPanel", BasePanel)
local RoleMenuPanel = RoleMenuPanel

function RoleMenuPanel:ctor(parent_node, layer)
    self.abName = "rolemenu"
    self.assetName = "RoleMenuPanel"
    self.layer = layer or "UI"

    self.use_background = true
    --self.change_scene_close = true
    self.is_hide_model_effect = false
    self.click_bg_close = true
    self.events = {}
    if parent_node then
        self.parent_node = parent_node.transform
    end
end

function RoleMenuPanel:dctor()
    
end

function RoleMenuPanel:Open(rolebase, role_id, channel)
    local id = role_id
    if rolebase then
        id = rolebase.id or rolebase.uid
    end
    if role_id then
        id = role_id
    end
    if id == RoleInfoModel:GetInstance():GetMainRoleId() then
        return Notify.ShowText("This is yourself")
    end
    RoleMenuPanel.super.Open(self)
    if rolebase then
        self.data = rolebase
        if not self.data.id then
            self.data.id = id
        end
    end
    if role_id then
        self.role_id = role_id
    end
    if channel then
        self.channel = channel or 0
    end
end

function RoleMenuPanel:LoadCallBack()
    self.nodes = {
        "bg/bg2/name", "bg/content/blackbtn", "bg/content/delblackbtn", "bg/bg2/role_bg/level_bg/level", 
        "bg/content/flowerbtn", "bg/content/chatbtn", "bg/bg2/role_bg/role_icon", "bg/content/friendbtn", 
        "bg/content/delfriendbtn", "bg/bg2/roleicon/Camera",
        "bg/content/teaminvite","bg/content/teamapply","bg/content/guildinvite",
        "bg/content/viewbtn","bg/bg2/vip","bg/bg2/gender",
        "bg/content/gOutBtn","bg/content/gDownBtn","bg/content/gUpBtn",
        "bg/content/gUpBtn/gUpBtnText","bg/content/gDownBtn/gDownBtnText",
        "bg/bg2","bg/content", "bg","bg/content/marryBtn","bg/content/kickout",
        "bg/content/transcaptain","bg/bg2/role_bg/level_bg","bg/content/babyBtn",
    }
    self:GetChildren(self.nodes)
    self.name = GetText(self.name)
    self.level = GetText(self.level)
    self.gender = GetImage(self.gender)
    --self.role_icon = GetImage(self.role_icon)
    self.vip = GetText(self.vip)
    self.gUpBtnText = GetText(self.gUpBtnText)
    self.gDownBtnText = GetText(self.gDownBtnText)
    self.level_bg = GetImage(self.level_bg)
    self:AddEvent()
    if not self.data and self.role_id then
        RoleInfoController:GetInstance():RequestRoleQuery(self.role_id)
    end
end

function RoleMenuPanel:AddEvent()
    local function call_back(target, x, y)
        FriendController:GetInstance():RequestDelBlack(self.data.id)
        self:Close()
    end
    AddClickEvent(self.delblackbtn.gameObject, call_back)

    local function call_back(target, x, y)
        local function ok_fun()
            FriendController:GetInstance():RequestAddBlack(self.data.id)
            self:Close()
        end
        local message = string.format(ConfigLanguage.Mail.AddBlackTips, self.data.name)
        Dialog.ShowTwo(ConfigLanguage.Mail.TipsTitle, message, nil, ok_fun)
    end
    AddClickEvent(self.blackbtn.gameObject, call_back)

    local function call_back(target, x, y)
        if self.data.id == RoleInfoModel:GetInstance():GetMainRoleId() then
            Notify.ShowText("You can't send flower to yourself")
        else
            GlobalEvent:Brocast(FriendEvent.OpenSendGiftPanel, self.data)
        end
        self:Close()
    end
    AddClickEvent(self.flowerbtn.gameObject, call_back)

    local function call_back(target, x, y)
        if faker.GetInstance():is_fake(self.data.id) then
            return Notify.ShowText("Unable to send PM due to privacy settings")
        end
        if OpenTipModel:GetInstance():IsOpenSystem(580, 1) then
            FriendController:GetInstance():AddContact(self.data.id)
        else
            local level = GetSysOpenDataById("580@1")
            Notify.ShowText(string.format("Unlocks at Lv.%s", level))
        end
        self:Close()
    end
    AddClickEvent(self.chatbtn.gameObject, call_back)

    local function call_back(target, x, y)
        if faker.GetInstance():is_fake(self.data.id) then
            return Notify.ShowText("The player declines all friend requests")
        end
        if OpenTipModel:GetInstance():IsOpenSystem(580, 1) then
            FriendController:GetInstance():RequestAddFriend(self.data.id)
        else
            local level = GetSysOpenDataById("580@1")
            Notify.ShowText(string.format("Unlocks at Lv.%s", level))
        end
        self:Close()
    end
    AddClickEvent(self.friendbtn.gameObject, call_back)

    local function call_back(target, x, y)
        local function ok_fun()
            local role_ids = {}
            role_ids[1] = self.data.id
            FriendController:GetInstance():RequestDeleteFriend(role_ids)
            self:Close()
        end
        Dialog.ShowTwo(ConfigLanguage.Mail.TipsTitle, ConfigLanguage.Mail.DeleteFriendTips, nil, ok_fun)
    end
    AddClickEvent(self.delfriendbtn.gameObject, call_back)

    local function call_back(target,x,y)
        local team_info =  TeamModel:GetInstance():GetTeamInfo()
        if not team_info then
            GlobalEvent:Brocast(TeamEvent.CreateTeamView, nil, self.data.id)
        else
            TeamController:GetInstance():RequestInvite(self.data.id)
        end
        self:Close()
    end
    AddClickEvent(self.teaminvite.gameObject,call_back)

    local function call_back(target,x,y)
        TeamController:GetInstance():RequestApply(self.data.id or self.data.uid, 1)
        self:Close()
    end
    AddClickEvent(self.teamapply.gameObject,call_back)

    local function call_back(target,x,y)
        if faker.GetInstance():is_fake(self.data.id) then
            return Notify.ShowText("Unable to view due to privacy settings")
        end
        GlobalEvent:Brocast(RoleInfoEvent.OpenOtherInfoPanel, self.data.id or self.data.uid)
        self:Close()
    end
    AddClickEvent(self.viewbtn.gameObject,call_back)

    local function call_back(target,x,y)
        TeamController:GetInstance():RequestKickout(self.data.id)
        self:Close()
    end
    AddClickEvent(self.kickout.gameObject,call_back)

    local function call_back(role_base)
        self.data = role_base
        self:UpdateView()
    end
    self.events[#self.events + 1] = GlobalEvent:AddListener(RoleInfoEvent.QueryOtherRoleGlobal, call_back)


    --公会相关  
    local function call_back()
		if self.upIndex == enum.GUILD_POST.GUILD_POST_CHIEF  then --转让会长
			FactionController:GetInstance():RequestDemis(self.data.id)
		else
			FactionController:GetInstance():RequestAppointment(self.data.id,self.upIndex)
		end
       
        self:Close()
    end
    AddClickEvent(self.gUpBtn.gameObject,call_back)
    
    local function call_back()
        if  self.downIndex == enum.GUILD_POST.GUILD_POST_MEMB then
            FactionController:GetInstance():RequestDisCareer(self.data.id)
            return
        end
        FactionController:GetInstance():RequestAppointment(self.data.id,self.downIndex)
        self:Close()
    end
    AddClickEvent(self.gDownBtn.gameObject,call_back)
    
    local function call_back()
       FactionController:GetInstance():RequestKitOut(self.data.id)
       self:Close()
    end
    AddClickEvent(self.gOutBtn.gameObject,call_back)
    
    local function call_back()
        lua_panelMgr:GetPanelOrCreate(MarryPropPanel):Open(self.data)
        self:Close()
    end
    AddClickEvent(self.marryBtn.gameObject,call_back)

    local function call_back(target,x,y)
        if TeamModel.GetInstance():IsCaptain(RoleInfoModel:GetInstance():GetMainRoleId()) then
            TeamController:GetInstance():RequestTransCaptain(self.data.id)
        else
            Notify.ShowText("You're not the team leader")
        end
        self:Close()
    end
    AddClickEvent(self.transcaptain.gameObject,call_back)
    
    local function call_back()
        BabyController:GetInstance():RequstBabyLikeInfo(self.data.id)
    end

    AddClickEvent(self.babyBtn.gameObject,call_back)


    local function call_back()
        self:Close()
    end
    self.events[#self.events + 1] = GlobalEvent:AddListener(FactionEvent.KitOut, call_back)
    self.events[#self.events + 1] = GlobalEvent:AddListener(FactionEvent.AppointmentSucess, call_back)
    self.events[#self.events + 1] = GlobalEvent:AddListener(FactionEvent.DisCareerSucess, call_back)

end

function RoleMenuPanel:OpenCallBack()
    self:UpdateView()
end

function RoleMenuPanel:UpdateView()
    if self.data then
        local gender = "sex_icon_1"
        if self.data.gender == 2 then
            gender = "sex_icon_2"
        end
        lua_resMgr:SetImageTexture(self,self.gender, 'common_image', gender,true)
        local param = {}
        param['is_can_click'] = false
        param["is_squared"] = true
        param["is_hide_frame"] = true
        param["size"] = 65
        param["role_data"] = self.data
        self.roleicon = RoleIcon(self.role_icon)
        self.roleicon:SetData(param)

        self.name.text = self.data.name
        if FriendModel:GetInstance():IsInBlack(self.data.id) then
            SetVisible(self.blackbtn, false)
            SetVisible(self.delblackbtn, true)
        else
            SetVisible(self.blackbtn, true)
            SetVisible(self.delblackbtn, false)
        end
        if FriendModel:GetInstance():IsFriend(self.data.id) then
            SetVisible(self.delfriendbtn, true)
            SetVisible(self.friendbtn, false)
        else
            SetVisible(self.delfriendbtn, false)
            SetVisible(self.friendbtn, true)
        end
        local team_info = TeamModel:GetInstance():GetTeamInfo()
        local other_team_id = self.data.team
        --[[if self.data.figure.team and self.data.figure.team.model > 0 and self.data.figure.team.show then
            other_team_id = self.data.figure.team.model
        end--]]
        --[[if team_info and team_info.id ~= other_team_id then
            SetVisible(self.teaminvite, true)
        else
            SetVisible(self.teaminvite, false)
        end
        if other_team_id > 0 and 
            (not team_info or (team_info and team_info.id ~= other_team_id)) then
            SetVisible(self.teamapply, true)
        else
            SetVisible(self.teamapply, false)
        end--]]
        if TeamModel:GetInstance():IsCaptain(RoleInfoModel:GetInstance():GetMainRoleId())
         and TeamController:GetInstance():IsSameTeam(other_team_id) then
            SetVisible(self.kickout, true)
            SetVisible(self.transcaptain, true)
        else
            SetVisible(self.kickout, false)
            SetVisible(self.transcaptain, false)
        end

        local level = self.data.level
        local top_level = String2Table(Config.db_game.level_max.val)[1]
        level = (level > top_level and level-top_level or level)
        self.level.text = level
        self.vip.text = string.format(ConfigLanguage.Common.Vip, self.data.viplv)
        SetTopLevelImg(self.data.level, self.level_bg, self)
      
        local role = RoleInfoModel:GetInstance():GetMainRoleData()
        local marryLv = MarryModel:GetInstance():GetMarryLevel()
        local isFriend =  FriendModel:GetInstance():IsFriend(self.data.id)
        local is_online = false
        local intimacy = 0
        if isFriend then
            is_online = isFriend.is_online
            intimacy = isFriend.intimacy
        end
        if (self.data.gender ~= role.gender and self.data.marry == 0 and role.marry == 0
                and self.data.level >= marryLv and MarryModel:GetInstance():IsCharm(intimacy) and isFriend and is_online)
			or self.data.name == role.mname then
            SetVisible(self.marryBtn,true)
        else
            SetVisible(self.marryBtn,false)
        end


        if FactionModel:GetInstance().isMemberPanel or self.channel == enum.CHAT_CHANNEL.CHAT_CHANNEL_GUILD then
            local post = FactionModel:GetInstance():GetMemberByUdi(self.data.id).post
            local myPost = FactionModel:GetInstance():SetSelfCadre()
            SetVisible(self.gDownBtn,false)
            SetVisible(self.gUpBtn,false)
            SetVisible(self.gOutBtn,false)
            self.upIndex = 0
            self.downIndex = 0
            if myPost == enum.GUILD_POST.GUILD_POST_VICE or myPost == enum.GUILD_POST.GUILD_POST_CHIEF then
                if post == enum.GUILD_POST.GUILD_POST_MEMB  then --成员
                    SetVisible(self.gOutBtn,true)
                    SetVisible(self.gUpBtn,true)
                    if self.data.gender == 2 then --女的
                        if FactionModel:GetInstance():IsHaveBaby() then
                            self.gUpBtnText.text = "Promote to elder"
                            self.upIndex = enum.GUILD_POST.GUILD_POST_ELDER
                        else
                            self.gUpBtnText.text = "Promote to mascot"
                            self.upIndex = enum.GUILD_POST.GUILD_POST_BABY
                        end
                    else
                        self.gUpBtnText.text = "Promote to elder"
                        self.upIndex = enum.GUILD_POST.GUILD_POST_ELDER
                    end
                elseif post == enum.GUILD_POST.GUILD_POST_BABY then --宝贝
                    self.gUpBtnText.text = "Promote to elder"
                    self.upIndex = enum.GUILD_POST.GUILD_POST_ELDER
                    self.gDownBtnText.text = "Demote as member"  --降为成员
                    self.downIndex = enum.GUILD_POST.GUILD_POST_MEMB
                    SetVisible(self.gUpBtn,true)
                    SetVisible(self.gDownBtn,true)
                elseif post == enum.GUILD_POST.GUILD_POST_ELDER  then --长老
                    self.gDownBtnText.text = "Demote as member"  --降为成员
                    self.downIndex = enum.GUILD_POST.GUILD_POST_MEMB
                    SetVisible(self.gDownBtn,true)
                    if myPost == enum.GUILD_POST.GUILD_POST_CHIEF then
                        SetVisible(self.gUpBtn,true)
                        self.gUpBtnText.text = "Promote to deputy"
                        self.upIndex = enum.GUILD_POST.GUILD_POST_VICE
                    end

                elseif post == enum.GUILD_POST.GUILD_POST_VICE  then --副会长
                    if myPost == enum.GUILD_POST.GUILD_POST_CHIEF then
                        self.gDownBtnText.text = "Demote as elder" --降为长老
                        self.downIndex = enum.GUILD_POST.GUILD_POST_ELDER
						
						self.gUpBtnText.text = "Transfer leadership"
						self.upIndex = enum.GUILD_POST.GUILD_POST_CHIEF
                        SetVisible(self.gDownBtn,true)
						SetVisible(self.gUpBtn,true)
                    end
                else --会长

                end
            end
        else
            SetVisible(self.gDownBtn,false)
            SetVisible(self.gUpBtn,false)
            SetVisible(self.gOutBtn,false)
        end
        self:ShowFakerMenu()
        self:ShowCrossMenu()
        self:Relayout()
    end
    if BabyModel:GetInstance():IsBirth(1) or BabyModel:GetInstance():IsBirth(2) then
        SetVisible(self.babyBtn,true)
    else
        SetVisible(self.babyBtn,false)
    end
    
    if self.parent_node then
        SetSizeDelta(self.background_transform, 3000, 3000)
        SetColor(self.background_img, 0, 0, 0, 0)
        self.viewRectTra = self.transform:GetComponent('RectTransform')
        self.parentRectTra = self.parent_node:GetComponent('RectTransform')
        self:SetPos()
    end
    
end

function RoleMenuPanel:ShowCrossMenu()
    -- local mysuid = RoleInfoModel:GetInstance():GetRoleValue("suid")
    local bo = RoleInfoModel:GetInstance():IsSameServer(self.data.suid)
    -- logError("======ShowCrossMenu=======",mysuid,self.data.suid,bo,Table2String(RoleInfoModel:GetInstance().suids))
    -- if mysuid ~= self.data.suid then
    if not bo then
        SetVisible(self.chatbtn, false)
        SetVisible(self.flowerbtn, false)
        SetVisible(self.teamapply, false)
        SetVisible(self.gDownBtn, false)
        SetVisible(self.gOutBtn, false)
        SetVisible(self.gUpBtn, false)
        SetVisible(self.friendbtn, false)
        SetVisible(self.delfriendbtn, false)
        SetVisible(self.blackbtn, false)
        SetVisible(self.delblackbtn, false)
        SetVisible(self.teaminvite, false)
        SetVisible(self.guildinvite, false)
        SetVisible(self.marryBtn, false)
        SetVisible(self.kickout, false)
        SetVisible(self.transcaptain, false)
    end
end

function RoleMenuPanel:CloseCallBack()
    if self.role_model then
        self.role_model:destroy()
    end
    if self.events then
        GlobalEvent:RemoveTabListener(self.events)
        self.events = nil
    end
    if self.roleicon then
        self.roleicon:destroy()
    end
end

--data:p_role
function RoleMenuPanel:SetData(data)
    if data then
        self.data = data
    end
    if self.is_loaded then
        self:UpdateView( )
    end
end

--[[function RoleMenuPanel:LoadModelCallBack()
    SetLocalPosition(self.role_model.transform, -5012, -473, 950)
    local v3 = self.role_model.transform.localScale;
    SetLocalScale(self.role_model.transform, 500, 500, 500);
    SetLocalRotation(self.role_model.transform, 0, 182, 0);
end--]]

function RoleMenuPanel:Relayout()
    local count = self.content.transform.childCount
    local num = 0
    for i=0, count-1 do
        local child = self.content.transform:GetChild(i)
        if child.gameObject.activeSelf then
            num = num + 1
        end
    end
    local height = math.ceil(num/2)*57.2
    SetSizeDeltaY(self.content.transform, height)
    local y1 = GetSizeDeltaY(self.bg2.transform)
    SetSizeDeltaY(self.bg.transform, y1+height+10)
    SetSizeDeltaY(self.transform, y1+height+10)
end

--机器人时显示的菜单
function RoleMenuPanel:ShowFakerMenu()
    if faker.GetInstance():is_fake(self.data.id) then
        SetVisible(self.gOutBtn, false)
        SetVisible(self.gUpBtn, false)
        SetVisible(self.gDownBtn, false)
        SetVisible(self.blackbtn, false)
        SetVisible(self.delblackbtn, false)
        SetVisible(self.flowerbtn, false)
        SetVisible(self.delfriendbtn, false)
        SetVisible(self.teaminvite, false)
        SetVisible(self.guildinvite, false)
        SetVisible(self.teamapply, false)
        SetVisible(self.marryBtn, false)
        SetVisible(self.transcaptain, false)
        SetVisible(self.kickout, true)
        SetVisible(self.viewbtn, true)
        SetVisible(self.friendbtn, true)
        SetVisible(self.chatbtn, true)
    end
end

function RoleMenuPanel:SetPos()
    local parentWidth = 0
    local parentHeight = 0
    local spanX = 0
    local spanY = 0
    if self.parentRectTra.anchorMin.x == 0.5 then
        spanX = 10
        parentWidth = self.parentRectTra.sizeDelta.x / 2
        parentHeight = self.parentRectTra.sizeDelta.y / 2
    else
        parentWidth = self.parentRectTra.sizeDelta.x
        parentHeight = self.parentRectTra.sizeDelta.y
    end

    local myx = self.viewRectTra.sizeDelta.x
    local myy = self.viewRectTra.sizeDelta.y

    local pos = self.parent_node.position
    local x = pos.x * 100 + parentWidth + myx/2
    local y = pos.y * 100 - parentHeight - myy/2
    local UITransform = LayerManager.Instance:GetLayerByName(self.layer)
    self.transform:SetParent(UITransform)
    SetLocalScale(self.transform, 1, 1, 1)

    --判断是否超出右边界
    if x + parentWidth + myx > ScreenWidth/2 - 10 then
        if self.parentRectTra.anchorMin.x == 0.5 then
            x = x - self.viewRectTra.sizeDelta.x - parentWidth * 2 - 20
        else
            x = ScreenWidth/2 - parentWidth - myx - 10
        end
    end

    if y - myy/2 < -ScreenHeight/2 + 10 then
        spanY = ScreenHeight/2 + y - myy/2 - 10
    end

    self.viewRectTra.anchoredPosition = Vector2(x + spanX, y - spanY)
end