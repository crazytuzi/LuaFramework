---
--- Created by  Administrator
--- DateTime: 2019/6/29 14:55
---
WeddingAppointmentPanel = WeddingAppointmentPanel or class("WeddingAppointmentPanel", BasePanel)
local this = WeddingAppointmentPanel

function WeddingAppointmentPanel:ctor(parent_node, parent_panel)
    self.abName = "marry"
    self.assetName = "WeddingAppointmentPanel"
    self.layer = LayerManager.LayerNameList.UI
    self.use_background = true
    self.change_scene_close = true
    self.events = {}
    self.items = {}
    self.icons = {}
    self.model = MarryModel:GetInstance()
    self.role = RoleInfoModel.GetInstance():GetMainRoleData()
end

function WeddingAppointmentPanel:dctor()
    self.model:RemoveTabListener(self.events)
    for i, v in pairs(self.items) do
        v:destroy()
    end
    self.items = {}

    if self.rolemodel then
        self.rolemodel:destroy()
    end

    if self.emodel then
        self.emodel:destroy()
    end

    for i, v in pairs(self.icons) do
        v:destroy()
    end
    self.icons = {}

end

function WeddingAppointmentPanel:LoadCallBack()
    self.nodes = {
        "enemyName","rightObj/ScrollView/Viewport/itemContent",
        "closeBtn","times","WeddingAppointmentItem","myName","rightObj/okBtn",
        "myModel","enemyModel",
        "downObj/downIconParent","wenhaoBtn",
    }
    self:GetChildren(self.nodes)
    self.btnImg = GetImage(self.okBtn)
    self.times = GetText(self.times)
    self.enemyName = GetText(self.enemyName)
    self.myName = GetText(self.myName)
    SetVisible(self.okBtn,false)
    self:InitUI()
    self:AddEvent()

    MarryController:GetInstance():RequsetAppointmentInfo()
end

function WeddingAppointmentPanel:InitUI()
    self:CreatIcons()
end

function WeddingAppointmentPanel:InitItems(tab)
    --local cfg = Config.db_marriage["appointment"]
    --if not cfg then
    --    return
    --end
    --local tab = String2Table(cfg.val)
    --local list= tab[1]
    local list = tab
    for i = 1, #list do
        local item = self.items[i]
        if not item then
            item = WeddingAppointmentItem(self.WeddingAppointmentItem.gameObject,self.itemContent,"UI")
            self.items[i] = item
        end
        item:SetData(list[i],i)
    end
    local index = self.model:GetAppointmentSelect()
    if index ~= 0 then
        self:WeddingAppointmentItemClick(index)
    else
        self:SetMarryModel(self.role,self.model.withMarry)
        self:SetInfo(self.role.name,self.role.mname)
    end


end

function WeddingAppointmentPanel:AddEvent()
    local function call_back()
        self:Close()
    end
    AddClickEvent(self.closeBtn.gameObject,call_back)

    local function call_back()
        if self.state == 1 then
            Notify.ShowText("Reserved")
            return
        end
        local sTime = self.selectItem.data.start_time
        local eTime = self.selectItem.data.end_time

        local startTimeTab = TimeManager:GetTimeDate(sTime)
        local sTimestr = "";
        if startTimeTab.hour then
            sTimestr = sTimestr .. string.format("%02d", startTimeTab.hour) .. ":";
        end
        if startTimeTab.min then
            sTimestr = sTimestr .. string.format("%02d", startTimeTab.min) .. "";
        end

        local endTimeTab = TimeManager:GetTimeDate(eTime)
        local eTimestr = "";
        if endTimeTab.hour then
            eTimestr = eTimestr .. string.format("%02d", endTimeTab.hour) .. ":";
        end
        if endTimeTab.min then
            eTimestr = eTimestr .. string.format("%02d", endTimeTab.min) .. "";
        end

        local des = string.format("You will reserve the wedding of<color=#008909>%s-%s</color>\nAttention：You can't cancel reserved wedding,and the attempts of both sides will be deducted.",sTimestr,eTimestr)
        Dialog.ShowTwo("Tip", des, "Confirm", handler(self, self.OkFun))
    end
    AddClickEvent(self.okBtn.gameObject,call_back)

    local function call_back()
        ShowHelpTip(HelpConfig.MARRY.APPOINTMENT)
    end
    AddButtonEvent(self.wenhaoBtn.gameObject,call_back)

    self.events[#self.events + 1] =self.model:AddListener(MarryEvent.AppointmentInfo,handler(self,self.AppointmentInfo))
    self.events[#self.events + 1] =self.model:AddListener(MarryEvent.AppointmentBook,handler(self,self.AppointmentBook))
    self.events[#self.events + 1] =self.model:AddListener(MarryEvent.WeddingAppointmentItemClick,handler(self,self.WeddingAppointmentItemClick))
end

function WeddingAppointmentPanel:OkFun()
    --print2(self.selectItem.startHMS,self.selectItem.endHMS)
    MarryController:GetInstance():RequsetAppointmentBook(self.selectItem.data.start_time,self.selectItem.data.end_time)
end

function WeddingAppointmentPanel:WeddingAppointmentItemClick(index)
    for i = 1, #self.items do
        if i == index  then
            self.items[i]:SetSelect(true)
            self.selectItem = self.items[i]
            self:SetState(self.items[i])
        else
            self.items[i]:SetSelect(false)
        end
    end
    
end

function WeddingAppointmentPanel:SetState(item)
    self.state = item.state
    if self.state  == 1 then  --被预约了
        ShaderManager:GetInstance():SetImageGray(self.btnImg)
        --if item.wedData then
            local role1 = item.data.couple[1] or self.role
            local role2 = item.data.couple[2] or self.model.withMarry
            self:SetMarryModel(role1,role2)
            self:SetInfo(role1.name,role2.name)
      --  end
    elseif self.state  == 2  then --可预约
        self:SetMarryModel(self.role,self.model.withMarry)
        self:SetInfo(self.role.name,self.role.mname)
        ShaderManager:GetInstance():SetImageNormal(self.btnImg)
        SetVisible(self.okBtn,true)
    end

end

function WeddingAppointmentPanel:SetMarryModel(mine,marryWith)
    if self.rolemodel then
        self.rolemodel:destroy()
    end
    if self.emodel then
        self.emodel:destroy()
    end
    self.rolemodel = UIRoleCamera(self.myModel, nil, mine,2,nil,1)
    self.emodel = UIRoleCamera(self.enemyModel, nil, marryWith,2,nil,2)
end

function WeddingAppointmentPanel:SetInfo(name,enemyName)
    self.myName.text = name
    self.enemyName.text = enemyName
end

--function WeddingAppointmentPanel:SetOtherMarryModel()
--    self.emodel = UIRoleCamera(self.enemyModel, nil, self.model.withMarry)
--end

function WeddingAppointmentPanel:AppointmentInfo(data)
    self:InitItems(data.appointments)
    self.rtime = data.remain_times
    self.times.text = "Reservation attempts left:"..data.remain_times
    
end

function WeddingAppointmentPanel:AppointmentBook()
    self.selectItem:SetApping()
    self.rtime = self.rtime - 1
    self.times.text = "Reservation attempts left:"..self.rtime
    lua_panelMgr:GetPanelOrCreate(WeddingInvitationPanel):Open()
end

function WeddingAppointmentPanel:CreatIcons()
    local cfg = Config.db_marriage["appointment_show"]
    if not cfg then
        return
    end
    local tab = String2Table(cfg.val)
    dump(tab[1])
    local list = tab[1]
    for i = 1, #list do
        local id = list[i][1]
        local num = list[i][2]
        if self.icons[i] == nil then
            self.icons[i] = GoodsIconSettorTwo(self.downIconParent)
        end
        local param = {}
        param["model"] = self.model
        param["item_id"] = id
        param["num"] = num
        param["bind"] = 1
        param["can_click"] = true
        self.icons[i]:SetIcon(param)

    end
end