--
-- @Author: chk
-- @Date:   2018-12-05 11:48:04
--
FactionInfoView = FactionInfoView or class("FactionInfoView", BaseItem)
local FactionInfoView = FactionInfoView

function FactionInfoView:ctor(parent_node, layer)
    self.abName = "faction"
    self.assetName = "FactionInfoView"
    self.layer = layer

    self.careerItems = {}
    self.events = {}
    self.model = FactionModel:GetInstance()
    FactionInfoView.super.Load(self)
end

function FactionInfoView:dctor()
    for i, v in pairs(self.events) do
        self.model:RemoveListener(v)
    end

    for i, v in pairs(self.careerItems) do
        v:destroy()
    end

    if self.UIRole ~= nil then
        self.UIRole:destroy()
    end

    if self.app_red_point then
        self.app_red_point:destroy()
        self.app_red_point = nil
    end

    if self.welf_red_point then
        self.welf_red_point:destroy()
        self.welf_red_point = nil
    end

    if self.hongbao_red_dot then
        self.hongbao_red_dot:destroy()
        self.hongbao_red_dot = nil
    end
	
	
	if self.crossBtn_red_dot then
		self.crossBtn_red_dot:destroy()
		self.crossBtn_red_dot = nil
	end
	
	

    self:DealCloseOperateView()
end

function FactionInfoView:LoadCallBack()
    self.nodes = {
        "leftInfo/chenghao",
        "leftInfo/nameContain/job_title",
        "leftInfo/nameContain/name",
        "leftInfo/roleContain",
        "leftInfo/careerCon",
        "leftInfo/operateCon",
        "leftInfo/btns/welfBtn",
        "leftInfo/btns/operateBtn",
        "leftInfo/btns/fightBtn",
        "leftInfo/btns/hongBaoBtn",
        "leftInfo/btns/crossBtn",
        "rightInfo/notice/Scroll View/Viewport/Content/notice_value",
        "rightInfo/notice/Scroll View/Viewport/Content",
        "rightInfo/notice/modifyNoticeBtn",
        "rightInfo/FactionInfo/bg/factionName/Image/factionName",
        "rightInfo/FactionInfo/bg/factionName/EditorFactionNameBtn",
        "rightInfo/FactionInfo/bg/factionRank/Image/rank",
        "rightInfo/FactionInfo/bg/factionNumber/Image/number",
        "rightInfo/FactionInfo/bg/factionPower/Image/power",
        "rightInfo/FactionInfo/bg/factionLv/Image/lv",
        "rightInfo/FactionInfo/bg/factionMoney/Image/money",
    }
    self:GetChildren(self.nodes)
    self.chenghaoImg = GetImage(self.chenghao)
    self.nameTxt = GetText(self.name)
    self.job_titleTxt = GetText(self.job_title)

    self:AddEvent()

    self.notice_value_txt = self.notice_value:GetComponent('Text')

    self.app_red_point = RedDot(self.operateBtn, nil, RedDot.RedDotType.Nor)
    self.app_red_point:SetPosition(25, 28)

    self.welf_red_point = RedDot(self.welfBtn, nil, RedDot.RedDotType.Nor)
    self.welf_red_point:SetPosition(25, 28)

    self.hongbao_red_dot = RedDot(self.hongBaoBtn, nil, RedDot.RedDotType.Nor)
    self.hongbao_red_dot:SetPosition(25, 28)
	
	self.crossBtn_red_dot = RedDot(self.crossBtn, nil, RedDot.RedDotType.Nor)
	self.crossBtn_red_dot:SetPosition(25, 28)

    self:UpdateRedDot()

    --FactionController:GetInstance():R
end

function FactionInfoView:AddEvent()
    local function call_back(target, x, y)
        lua_panelMgr:GetPanelOrCreate(FactionWelfarePanel):Open()
    end
    AddClickEvent(self.welfBtn.gameObject, call_back)
    -- SetVisible(self.welfBtn,false)

    local function call_back(target, x, y)
        if self.operateView == nil then
            self.operateView = FactionOperateView(self.operateCon)
        else
            self.operateView:UpdateView()
        end
        SetVisible(self.operateView.gameObject, true)

    end
    AddClickEvent(self.operateBtn.gameObject, call_back)

    local function call_back(target, x, y)
        -- Notify.ShowText(ConfigLanguage.Mix.NotOpen)
        OpenLink(550, 1, 1, true)

    end
    AddClickEvent(self.fightBtn.gameObject, call_back)

    local function call_back(target, x, y)
        GlobalEvent:Brocast(FPacketEvent.OpenPacketPaenl)
    end
    AddClickEvent(self.hongBaoBtn.gameObject, call_back)

    local function call_back(target, x, y)
        --Notify.ShowText(ConfigLanguage.Mix.NotOpen)
        --SceneControler:GetInstance():RequestSceneChange(30361, enum.SCENE_CHANGE.SCENE_CHANGE_ACT ,nil,nil,10211)
        GlobalEvent:Brocast(FactionEvent.Faction_EnterGuildHouseEvent)
    end
    AddClickEvent(self.crossBtn.gameObject, call_back)

    local function call_back(target, x, y)
        if self.model.selfCareer > enum.GUILD_POST.GUILD_POST_VICE then
            --会长才可以改名
            if BagModel:GetInstance():GetItemNumByItemID(11003) < 1 then
                --公会改名卡
                local itemCfg = Config.db_item[11003]
                local color = itemCfg.color
                local name = itemCfg.name
                Dialog.ShowTwo("Tip", string.format("Changing guild name will cost <color=#%s>%sx1</color>.Go and buy some?", ColorUtil.GetColor(color), name), "Confirm", handler(self, self.GotoShop), nil, "Cancel", nil, nil)
                return
            end
            lua_panelMgr:GetPanelOrCreate(FactionRenamePanel):Open()
        else
            Notify.ShowText("You don't have the access to change guild name")
        end

    end
    AddClickEvent(self.EditorFactionNameBtn.gameObject, call_back)

    self.events[#self.events + 1] = self.model:AddListener(FactionEvent.SelectCadre, handler(self, self.LoadModel))
    self.events[#self.events + 1] = self.model:AddListener(FactionEvent.SelfFactionInfo, handler(self, self.UpdateView))
    self.events[#self.events + 1] = self.model:AddListener(FactionEvent.ModifyNoticeSucess, handler(self, self.DealModifyNoticeSucess))
    self.events[#self.events + 1] = self.model:AddListener(FactionEvent.CloseOperateView, handler(self, self.DealCloseOperateView))
    self.events[#self.events + 1] = self.model:AddListener(FactionEvent.AgreeApplyCareer, handler(self, self.DealAgreeApplyCareer))
    self.events[#self.events + 1] = self.model:AddListener(FactionEvent.AppointmentSucess, handler(self, self.DealAppointment))
    self.events[#self.events + 1] = self.model:AddListener(FactionEvent.Demise, handler(self, self.DealDemise))

    self.events[#self.events + 1] = self.model:AddListener(FactionEvent.FactionRename, handler(self, self.FactionRename))
    self.events[#self.events + 1] = self.model:AddListener(FactionEvent.UpdateRedDot, handler(self, self.UpdateRedDot))
    self.events[#self.events + 1] = self.model:AddListener(FactionEvent.UpLV, handler(self, self.UpLV))
    self.roleData = RoleInfoModel.GetInstance():GetMainRoleData()
    --if self.model.faction_id ~= 0 then
    --	FactionController.GetInstance():RequestFactionInfo(self.model.faction_id)
    --else
    FactionController.GetInstance():RequestSelfFactionInfo(self.roleData.guild)
    --end
end

function FactionInfoView:SetData(data)

end

function FactionInfoView:UpdateRedDot()
	--logError(self.model.redPoints[6])
    self.app_red_point:SetRedDotParam(self.model.redPoints[1])
    self.welf_red_point:SetRedDotParam(self.model.redPoints[3])
    self.hongbao_red_dot:SetRedDotParam(self.model.redPoints[5])
	self.crossBtn_red_dot:SetRedDotParam(self.model.redPoints[6])
end

function FactionInfoView:UpLV(level)
    self.lv:GetComponent('Text').text = level .. ""
end

function FactionInfoView:GotoShop()
    OpenLink(180, 1, 2, 1, 2110)
end

function FactionInfoView:UpdateView()
    self.factionName:GetComponent('Text').text = self.model.selfFactionInfo.name
    self.rank:GetComponent('Text').text = self.model.selfFactionInfo.rank .. ""
    self.number:GetComponent('Text').text = table.nums(self.model.selfFactionInfo.members) .. "/" .. Config.db_guild[self.model.selfFactionInfo.level].memb
    self.power:GetComponent('Text').text = self.model.selfFactionInfo.power .. ""
    -- self.power:GetComponent('Text').text = GetShowNumber(self.model.selfFactionInfo.power) .. ""
    self.lv:GetComponent('Text').text = self.model.selfFactionInfo.level .. ""
    self.money:GetComponent('Text').text = self.model.selfFactionInfo.fund .. ""

    self.notice_value_txt.text = self.model.selfFactionInfo.notice
    self.model.modifyNotice = self.model.selfFactionInfo.notice

    local guildPermCfg = self.model:GetPermCfg(enum.GUILD_PERM.GUILD_PERM_NOTICE)
    if self.model.selfCareer >= guildPermCfg.post then
        local function call_back(target, x, y)
            lua_panelMgr:GetPanelOrCreate(FactionModifyNoticePanel):Open()
        end
        AddClickEvent(self.modifyNoticeBtn.gameObject, call_back)
    else
        SetVisible(self.modifyNoticeBtn.gameObject, false)
    end

    self:CreateCadreItems()
    self:SetHeight()
end

function FactionInfoView:CreateCadreItems()
    for i = 1, 10 do
        local careerItem = nil
        if i > 5 then
            careerItem = FactionInfoCareerItemSettor2(self.careerCon, "UI", i)
        else
            careerItem = FactionInfoCareerItemSettor(self.careerCon, "UI", i)
        end

        careerItem:InitItem()
        table.insert(self.careerItems, table.nums(self.careerItems) + 1, careerItem)
    end

    for i, v in pairs(self.model.Cadremember) do
        for ii, vv in pairs(self.careerItems) do
            if vv.career == v.post and vv.data == nil then
                vv:SetData(v)
                break
            end
        end
    end
end

function FactionInfoView:DealModifyNoticeSucess()
    self.notice_value_txt.text = self.model.modifyNotice
    self:SetHeight()
end

function FactionInfoView:SetHeight()
    local h = self.notice_value_txt.preferredHeight
    SetSizeDeltaY(self.Content.transform, h)
end

function FactionInfoView:DealDemise(data)
    for i, v in pairs(self.careerItems) do
        if v.career == enum.GUILD_POST.GUILD_POST_CHIEF then
            local _data = self.model:GetMemberByUdi(data.to)
            v:SetData(_data)
        end
        if v.data ~= nil and v.data.base.id == data.to and v.career == enum.GUILD_POST.GUILD_POST_VICE  then
            v:InitItem()
        end
    end

    if self.operateView then
        SetVisible(self.operateView,false)
    end
end

function FactionInfoView:DealAppointment(data)
    for i, v in pairs(self.careerItems) do
        if v.career == data.post and v.data == nil then
            local _data = self.model:GetMemberByUdi(data.role_id)
            v:SetData(_data)
            break
        end
    end

    for i, v in pairs(self.careerItems) do
        if v.data ~= nil and v.data.base.id == data.role_id and v.career ~= nil and v.career ~= data.post then
            v:InitItem()
        end
    end
    --if self.career == post then
    --	if self.is_operateAppoint then
    --		self.data = self.model:GetMemberByUdi(role_id)
    --		self:UpdateItem()
    --	elseif self.data ~= nil then
    --		self.data = nil
    --		self:InitItem()
    --	end
    --end
end


--处理接受职位申请
function FactionInfoView:DealAgreeApplyCareer(role_id, post)
    for i, v in pairs(self.careerItems) do
        if v.data ~= nil and v.data.base.id == role_id then
            v:DealDisCareer(role_id)
            break
        end
    end

    for i, v in pairs(self.careerItems) do
        if v.career == post and v.data == nil then
            v:LoadItem(role_id)
            break
        end
    end
end

function FactionInfoView:DealCloseOperateView()
    if self.operateView ~= nil then
        self.operateView:destroy()
        self.operateView = nil
    end

end

function FactionInfoView:LoadModel(data)
    --if self.ui_role_model ~= nil then
    --    self.ui_role_model:destroy()
    --end
    local roleData = data.base
    --if self.UIRole == nil then
    --    self.UIRole = UIRoleCamera(self.roleContain, nil, roleData)
    --end
    if self.UIRole then
        self.UIRole:destroy()
    end

    self.UIRole = UIRoleCamera(self.roleContain, nil, roleData)
    --self.UIRole:LoadRoleModel(self.roleInfoModel)
    --local role_res_id = 12001
    --if roleData.gender == 2 then
    --	role_res_id = 12001
    --else
    --
    --	role_res_id = 11001
    --end
    --
    --if self.UIRole == nil then
    --	self.UIRole = UIRoleModel(self.roleContain , handler(self , self.LoadModelCallBack),{res_id = role_res_id})
    --else
    --	self.UIRole:ReLoadData({res_id = role_res_id},handler(self , self.LoadModelCallBack))
    --end

    local jobCfg = Config.db_jobtitle[roleData.figure.jobtitle]
    local jobName = ""
    if jobCfg ~= nil then
        jobName = jobCfg.name
    end
    self.job_titleTxt.text = jobName
    local gpost = data.post
    local gpostName = enumName.GUILD_POST[gpost]
    self.nameTxt.text = gpostName .. " " .. roleData.name
    lua_resMgr:SetImageTexture(self, self.chenghaoImg, Constant.TITLE_IMG_PATH, tostring(roleData.title), true, nil, false)
end

function FactionInfoView:LoadModelCallBack()
    SetLocalPosition(self.UIRole.transform, -2000, 0, -100);--172.2
    SetLocalRotation(self.UIRole.transform, 16, 180, 0);
end

function FactionInfoView:FactionRename(data)
    self.factionName:GetComponent('Text').text = data.name
end