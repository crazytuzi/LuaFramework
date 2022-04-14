---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by win 10.
--- DateTime: 18/11/15 0:28
---
RevivePanel = RevivePanel or class("RevivePanel", BasePanel)
local this = RevivePanel
--您已经被<color=#43f673>陈镇火(Lv.0)<color=#93572c>击败!!!!</color></color>
function RevivePanel:ctor()
    self.abName = "system"
    self.assetName = "RevivePanel"
    self.layer = "UI"
    self.events = {}
    self.use_background = true
    self.change_scene_close = false
    self.is_singleton = true
    self.isCanClick = true
    self.isHelpClick = true
    self.is_hide_model_effect = false
end

function RevivePanel:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    if self.lua_link_text then
        self.lua_link_text:destroy()
        self.lua_link_text = nil
    end
    if self.schedule then
        GlobalSchedule:Stop(self.schedule)
        self.schedule = nil
    end
end

function RevivePanel:Open(data)
    self.data = data
    if not data then
        return
    end
    RevivePanel.super.Open(self)
end

function RevivePanel:Close()
    self.isShow = false
    self:StopTime()
    self:SetVisible(false)

end

function RevivePanel:LoadCallBack()
    self.nodes = {
        --"title", "content", "sure_btn", "sure_btn/sure_text", "cancel_btn", "cancel_btn/cancel_text", "auto_text", "btn_close",
        --"saveTog", "saveTog/Label", --"saveTog/Background/Checkmark","saveTog/Background",
        "btnIcon/sure_btn/sure_text", "btnIcon/sure_btn", "btnIcon/cancel_btn", "content", "wayCon/mount", "tips",
        "title", "auto_text", "btn_close", "btnIcon/cancel_btn/cancel_text", "way_title", "wayCon", "wayCon/equip",
        "btnIcon/help_btn","btnIcon/help_btn/help_text","iconParent/icon_2","iconParent/icon_3","iconParent/icon_4","iconParent/icon_1",
    }
    self:GetChildren(self.nodes)
    self:InitUI();
    self:AddEvent()
end

function RevivePanel:InitUI()
    --self.title = GetText(self.title);
    self.content = GetText(self.content);
    self.sure_text = GetText(self.sure_text);
    self.cancel_text = GetText(self.cancel_text);
    self.auto_text = GetText(self.auto_text);
    self.auto_text.gameObject:SetActive(false);
    self.content_rect = GetRectTransform(self.content);
    self.help_btn_img = GetImage(self.help_btn)
    self.link_text = GetLinkText(self.tips)
    self.lua_link_text = LuaLinkImageText(self, self.link_text, nil, nil)
    self.help_text = GetText(self.help_text)
    self.icon_1 = GetImage(self.icon_1)
    self.icon_2 = GetImage(self.icon_2)
    self.icon_3 = GetImage(self.icon_3)
    self.icon_4 = GetImage(self.icon_4)

    local cf = SceneConfigManager:GetInstance():GetDBSceneConfig()
    cost_str = ""
    if cf then
        local revive_cost = String2Table(cf.revive_cost)
        if not table.isempty(revive_cost) then
            local iconId = revive_cost[1]
            self.cost_id = iconId
            self.cost_count = revive_cost[2]
            local abName = GoodIconUtil:GetABNameById(iconId)
            abName = "iconasset/" .. abName
            cost_str = string.format("%s<quad name=%s:%s size=30 width=1 />(Use bound diamond first)",self.cost_count,abName,iconId)
        end

        if cf.rescue == 1 then
            SetVisible(self.help_btn,true)
            local role  = RoleInfoModel.GetInstance():GetMainRoleData();
            if role.guild == "0" or role.guild == 0  then
                ShaderManager:GetInstance():SetImageGray(self.help_btn_img)
            else
                ShaderManager:GetInstance():SetImageNormal(self.help_btn_img)
            end
        else
            SetVisible(self.help_btn,false)
        end

    end
    self.link_text.text = cost_str;
    if self.data and  self.data.hideClose then
        SetGameObjectActive(self.btn_close , false);
    end

end

function RevivePanel:AddEvent()
    local function call_back(target, x, y)
        if self.cost_id and self.cost_count then
            local cur_value = RoleInfoModel:GetInstance():GetRoleValue(self.cost_id)
            if self.cost_id == enum.ITEM.ITEM_BGOLD then
                cur_value = cur_value + RoleInfoModel:GetInstance():GetRoleValue(enum.ITEM.ITEM_GOLD)
            end
            if cur_value >= self.cost_count then
                self:SureCallBack()
            else
                local cost_name = Constant.GoldName[Constant.GoldIDMap[self.cost_id]]
                if cost_name then
                    Notify.ShowText(string.format("%s is less than %s, fail to %s",cost_name,self.cost_count,self.data.ok_str))
                end
            end
        else
            self:SureCallBack()
        end
    end
    AddClickEvent(self.sure_btn.gameObject, call_back)

    local function call_back(target, x, y)
        if  self.isCanClick then
            self:CancelCallBack()
        else
            Notify.ShowText("Resurrect when countdown ends")
        end
    end
    AddClickEvent(self.cancel_btn.gameObject, call_back)

    local function call_back(target, x, y)
        -- self:Close()
        if  self.isCanClick then
            self:CancelCallBack()
        else
            self:Close()
        end
       -- self:CancelCallBack()
    end
    AddClickEvent(self.btn_close.gameObject, call_back)
    
    
    local function call_back()
        local role  = RoleInfoModel.GetInstance():GetMainRoleData();
        if role.guild == "0" or role.guild == 0  then
            Notify.ShowText("You didn't join any guild yet, join a guild first")
            return
        end
        if  not self.isHelpClick then
            Notify.ShowText("You asked for help too frequently, please try later")
            return
        end
        self.isHelpClick = false
        if self.schedule then
            GlobalSchedule:Stop(self.schedule)
            self.schedule = nil
        end
        self.HelpTime = 5
        ShaderManager:GetInstance():SetImageGray(self.help_btn_img)
        self:CountDown()
        self.schedule = GlobalSchedule.StartFun(handler(self,self.CountDown), 1, -1)
        DungeonCtrl:GetInstance():RequestSoSInfo()
    end
    AddClickEvent(self.help_btn.gameObject,call_back)


    self.events[#self.events + 1] = GlobalEvent:AddListener(DungeonEvent.SoSInfo,handler(self,self.HandleSosInfo))


    --DungeonEvent.SoSInfo
end

function RevivePanel:CountDown()
    self.HelpTime = self.HelpTime - 1
    self.help_text.text = string.format("Seek for Help (%s)",self.HelpTime)
    if self.HelpTime <= 0 then
        self.help_text.text = "Seek for Help"
        self.isHelpClick = true
        ShaderManager:GetInstance():SetImageNormal(self.help_btn_img)
        if self.schedule then
            GlobalSchedule:Stop(self.schedule)
            self.schedule = nil
        end
    end
end

function RevivePanel:InitIcon()
    local cfg = Config.db_revive_help
    local roleLv = RoleInfoModel:GetInstance():GetMainRoleLevel();
    local cfgItem
    for i, v in pairs(cfg) do
        if roleLv >= v.id and roleLv <= v.order then
            cfgItem = v
        end
    end
    if not cfgItem then
        logError("db_revive_help没有当前等级段 ："..roleLv)
        return
    end

    local tab = String2Table(cfgItem.jump_id)
    self.iconTab = {}
    for i = 1, 4 do
        if i <= #tab then
            local abName,assetName =  GetLinkAbAssetName(tab[i][1],tab[i][2])
            self.iconTab[i] = tab[i]
            lua_resMgr:SetImageTexture(self, self["icon_"..i], abName, assetName, true, nil, false)
            SetVisible(self["icon_"..i].transform,true)
            local function call_back()
                OpenLink(unpack(tab[i]))
            end
            AddClickEvent(self["icon_"..i].gameObject,call_back)
        else
            SetVisible(self["icon_"..i].transform,false)
        end
    end

end

function RevivePanel:HandleSosInfo(data)

end

function RevivePanel:SureCallBack()
    if self.data.message_lst then
        local msg = table.remove(self.data.message_lst, 1)
        if msg ~= nil then
            self.content.text = msg

            self.title_text_component.text = table.remove(self.data.title_str_lst, 1) or ConfigLanguage.Mix.Tips
            return
        else
            self.data.ok_func()
            self:Close()
        end
    elseif self.data.ok_func then
        if self.data and self.data.isCheck then
            self.data.ok_func()
        else
            self.data.ok_func()
        end

        self:Close()
    end
end

function RevivePanel:CancelCallBack()
    self:Close();
    if self.data.cancel_func then
        self.data.cancel_func(self)
    end
    --self:Close()
end

function RevivePanel:OpenCallBack()
    self:UpdateView()
end

function RevivePanel:UpdateView()
    if not self.data then
        self:Close()
        return
    end
    self:StopTime()
    self:InitIcon()
    if WarriorModel:GetInstance():IsWarriorScene() then
        self.isCanClick = false
    end
    if self.data.dialog_type == Dialog.Type.One then
        SetLocalPositionX(self.sure_btn, 0)
        SetVisible(self.cancel_btn, false)
    elseif self.data.dialog_type == Dialog.Type.Two then
        SetLocalPositionX(self.sure_btn, 157)
        SetLocalPositionX(self.cancel_btn, -157)
        SetVisible(self.cancel_btn, true)
    end
    if self.data.title_str then
        --self.title.text = self.data.title_str
    end
    if self.data.message then
        self.content.text = self.data.message
    elseif self.data.message_lst then
        self.content.text = table.remove(self.data.message_lst, 1)
        self.title_text.text = table.remove(self.data.title_str_lst, 1)
    end
    if self.data.ok_str then
        self.sure_text.text = self.data.ok_str
    end
    if self.data.cancel_str then
        self.cancel_text.text = self.data.cancel_str
    end
    local cf = SceneConfigManager:GetInstance():GetDBSceneConfig()
    cost_str = ""
    if cf then
        if cf.rescue == 1 then
            SetVisible(self.help_btn,true)
            local role  = RoleInfoModel.GetInstance():GetMainRoleData();
            if role.guild == "0" or role.guild == 0  then
                ShaderManager:GetInstance():SetImageGray(self.help_btn_img)
            else
                ShaderManager:GetInstance():SetImageNormal(self.help_btn_img)
            end
        else
            SetVisible(self.help_btn,false)
        end
    end


    SetVisible(self.auto_text, false)
    if not self.time_id and self.data.ok_time then
       -- SetVisible(self.auto_text, true)
        local function func()
            local last_time = self.data.ok_time - os.time()
            local str = "";
            if self.data.reviveText then
                str = string.format(self.data.reviveText, last_time)
            else
                str = string.format("In %s sec, auto %s", last_time, self.data.ok_str or "Confirm")
            end
            self.cancel_text.text = self.data.cancel_str.."("..last_time..")"
            self.auto_text.text = str
            if last_time <= 0 then
                self:StopTime()
                self:SureCallBack()
            end
        end
        self.time_id = GlobalSchedule:Start(func, 1)
        func()
    end

    if not self.time_id and self.data.cancel_time then
        --SetVisible(self.auto_text, true)
        local function func()
            local last_time = self.data.cancel_time - os.time();
            local str = "";
            if self.data.reviveText then
                str = string.format(self.data.reviveText, last_time)
            else
                str = string.format("In %s sec, auto %s", last_time, self.data.cancel_str or "Cancel")
            end
            self.auto_text.text = str
            self.cancel_text.text = self.data.cancel_str.."("..last_time..")"
            if last_time <= 0 then
                self:StopTime()
                self:CancelCallBack()
            end
        end
        self.time_id = GlobalSchedule:Start(func, 1)
        func()
    end
end

function RevivePanel:StopTime()
    if self.time_id then
        GlobalSchedule:Stop(self.time_id)
        self.time_id = nil
        self.isCanClick = true
    end
end

function RevivePanel:CloseCallBack()

end

RevivePanel2 = RevivePanel2 or class("RevivePanel2", BasePanel)
local this1 = RevivePanel2
--您已经被<color=#43f673>陈镇火(Lv.0)<color=#93572c>击败!!!!</color></color>
function RevivePanel2:ctor()
    self.abName = "system"
    self.assetName = "RevivePanel2"
    self.layer = "Top"

    self.use_background = true
    self.change_scene_close = false
    self.is_singleton = true
end

function RevivePanel2:dctor()
end

function RevivePanel2:Open(data)
    self.data = data
    if not data then
        return
    end
    RevivePanel2.super.Open(self)
end

function RevivePanel2:Close()
    self.isShow = false
    self:StopTime()
    self:SetVisible(false)
end

function RevivePanel2:LoadCallBack()
    self.nodes = {
        --"title", "content", "sure_btn", "sure_btn/sure_text", "cancel_btn", "cancel_btn/cancel_text", "auto_text", "btn_close",
        --"saveTog", "saveTog/Label", --"saveTog/Background/Checkmark","saveTog/Background",
        "sure_btn/sure_text", "sure_btn", "cancel_btn", "content", "wayCon/mount", "tips",
        "title", "auto_text", "btn_close", "cancel_btn/cancel_text",
    }
    self:GetChildren(self.nodes)
    self:InitUI();
    self:AddEvent()
    --self:SetOrderByParentAuto();
    self:SetOrderByParentMax();
end

function RevivePanel2:InitUI()
    self.title = GetText(self.title);
    self.content = GetText(self.content);
    self.sure_text = GetText(self.sure_text);
    self.cancel_text = GetText(self.cancel_text);
    self.auto_text = GetText(self.auto_text);
    self.auto_text.gameObject:SetActive(false);
    self.content_rect = GetRectTransform(self.content);

    self.link_text = GetLinkText(self.tips)
    self.lua_link_text = LuaLinkImageText(self, self.link_text, nil, nil)
    
    local cf = SceneConfigManager:GetInstance():GetDBSceneConfig()
    cost_str = ""
    if cf then
        local revive_cost = String2Table(cf.revive_cost)
        if not table.isempty(revive_cost) then
            local iconId = revive_cost[1]
            self.cost_id = iconId
            self.cost_count = revive_cost[2]
            local abName = GoodIconUtil:GetABNameById(iconId)
            abName = "iconasset/" .. abName
            cost_str = string.format("%s<quad name=%s:%s size=30 width=1 />(Use bound diamond first)",self.cost_count,abName,iconId)
        end
    end
    self.link_text.text = cost_str
end

function RevivePanel2:AddEvent()
    local function call_back(target, x, y)
        if self.cost_id and self.cost_count then
            local cur_value = RoleInfoModel:GetInstance():GetRoleValue(self.cost_id)
            if self.cost_id == enum.ITEM.ITEM_BGOLD then
                cur_value = cur_value + RoleInfoModel:GetInstance():GetRoleValue(enum.ITEM.ITEM_GOLD)
            end
            if cur_value >= self.cost_count then
                self:SureCallBack()
            else
                local cost_name = Constant.GoldName[Constant.GoldIDMap[self.cost_id]]
                if cost_name then
                    Notify.ShowText(string.format("%s is less than %s, fail to %s",cost_name,self.cost_count,self.data.ok_str))
                end
            end
        else
            self:SureCallBack()
        end
    end
    AddClickEvent(self.sure_btn.gameObject, call_back)

    local function call_back(target, x, y)
        self:CancelCallBack()
    end
    AddClickEvent(self.cancel_btn.gameObject, call_back)

    local function call_back(target, x, y)
        self:Close()
    end
    AddClickEvent(self.btn_close.gameObject, call_back)
end

function RevivePanel2:SureCallBack()
    if self.data.message_lst then
        local msg = table.remove(self.data.message_lst, 1)
        if msg ~= nil then
            self.content.text = msg

            self.title_text_component.text = table.remove(self.data.title_str_lst, 1) or ConfigLanguage.Mix.Tips
            return
        else
            self:Close()
            self.data.ok_func()
        end
    elseif self.data.ok_func then
        self:Close()
        if self.data and self.data.isCheck then
            self.data.ok_func()
        else
            self.data.ok_func()
        end

    end
end

function RevivePanel2:CancelCallBack()
    if self.data.cancel_func then
        self.data.cancel_func()
    end
    self:Close()
end

function RevivePanel2:OpenCallBack()
    self:UpdateView()
    self:SetOrderByParentMax();
end

function RevivePanel2:UpdateView()
    if not self.data then
        self:Close()
        return
    end
    self:StopTime()

    if self.data.dialog_type == Dialog.Type.One then
        SetLocalPositionX(self.sure_btn, 0)
        SetVisible(self.cancel_btn, false)
    elseif self.data.dialog_type == Dialog.Type.Two then
        SetLocalPositionX(self.sure_btn, 100)
        SetLocalPositionX(self.cancel_btn, -100)
        SetVisible(self.cancel_btn, true)
    end
    if self.data.title_str then
        --self.title.text = self.data.title_str
    end
    if self.data.message then
        self.content.text = self.data.message
    elseif self.data.message_lst then
        self.content.text = table.remove(self.data.message_lst, 1)
        self.title_text.text = table.remove(self.data.title_str_lst, 1)
    end
    if self.data.ok_str then
        self.sure_text.text = self.data.ok_str
    end
    if self.data.cancel_str then
        self.cancel_text.text = self.data.cancel_str
    end

    SetVisible(self.auto_text, false)
    if not self.time_id and self.data.ok_time then
        SetVisible(self.auto_text, true)
        local function func()
            local last_time = self.data.ok_time - os.time()
            local str = "";
            if self.data.reviveText then
                str = string.format(self.data.reviveText, last_time)
            else
                str = string.format("In %s sec, auto %s", last_time, self.data.ok_str or "Confirm")
            end

            self.auto_text.text = str
            if last_time <= 0 then
                self:StopTime()
                self:SureCallBack()
            end
        end
        self.time_id = GlobalSchedule:Start(func, 1)
        func()
    end

    if not self.time_id and self.data.cancel_time then
        SetVisible(self.auto_text, true)
        local function func()
            local last_time = self.data.cancel_time - os.time();
            local str = "";
            if self.data.reviveText then
                str = string.format(self.data.reviveText, last_time)
            else
                str = string.format("In %s sec, auto %s", last_time, self.data.cancel_str or "Cancel")

            end
            self.cancel_text.text = self.data.cancel_str.."("..last_time..")"
            self.auto_text.text = str

            if last_time <= 0 then
                self:StopTime()
                self:CancelCallBack()
            end
        end
        self.time_id = GlobalSchedule:Start(func, 1)
        func()
    end
end

function RevivePanel2:StopTime()
    if self.time_id then
        GlobalSchedule:Stop(self.time_id)
        self.time_id = nil
    end
end

function RevivePanel2:CloseCallBack()

end