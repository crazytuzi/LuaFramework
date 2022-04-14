FPacketTaskItem = FPacketTaskItem or class("FPacketTaskItem", BaseCloneItem)
local FPacketTaskItem = FPacketTaskItem

function FPacketTaskItem:ctor(parent_node, layer)
    FPacketTaskItem.super.Load(self)
end

function FPacketTaskItem:dctor()
end

function FPacketTaskItem:LoadCallBack()
    self.model = FPacketModel.GetInstance()
    self.nodes = {
        "des", "link",
    }
    self:GetChildren(self.nodes)
    self.des = GetText(self.des)
    self.link = GetLinkText(self.link)

    self:AddEvent()
end

function FPacketTaskItem:AddEvent()

    self.link:AddClickListener(handler(self, self.HandleLinkClick))
end

function FPacketTaskItem:SetData(data)
    self.data = data
    self:UpdateView()
end

function FPacketTaskItem:UpdateView()
    local type_name
    if self.data.link_type == 3 then
        type_name = "topanel"
    elseif self.data.link_type == 6 then
        type_name = "tosend"
    end
    self.des.text = self.data.order .. "：" .. self.data.des
    local str
    local color_name
    --if self.data.order == self.model.task_num then
    --    str = ConfigLanguage.FPacket.GrantFP
    --    color_name = "d23939"
    --else
        str = ConfigLanguage.FPacket.IWantFP
        color_name = "68FC7D"
    --end
    self.link.text = "<color=#" .. color_name .. "><a href=" .. type_name .. '>' .. str .. "</a></color>"
end

function FPacketTaskItem:HandleLinkClick()
    local link_tbl = String2Table(self.data.link)
    if self.data.link_type == 1 then
        --任务
        if self.data.link then
            local link_id = link_tbl[1]
            if link_id == 930000 then
                if RoleInfoModel.GetInstance():GetMainRoleData().guild == "0" then
                    Notify.ShowText("Please join the guild first")
                    return
                end
            end
            TaskModel.GetInstance():DoTask(link_id)
        end
    elseif self.data.link_type == 2 then
        if self.hookData then
            SceneManager:GetInstance():AttackCreepByTypeId(link_tbl[1])
        end
    elseif self.data.link_type == 3 then
        --界面跳转
        if self.data.link ~= "" then
            local pTab = String2Table(self.data.link)
            OpenLink(unpack(pTab[1]))
        end
    elseif self.data.link_type == 4 then
        --挂机
        if self.hookData then
            SceneManager:GetInstance():AttackCreepByTypeId(self.hookData.creep)
        end
    elseif self.data.link_type == 5 then
        --npc
        if self.data.link then
            SceneManager:GetInstance():FindNpc(String2Table(self.data.link)[1])
        end
    elseif self.data.link_type == 6 then
        local vip = RoleInfoModel.GetInstance():GetMainRoleVipLevel()
        if vip < 5 then
            Notify.ShowText(ConfigLanguage.FPacket.VipLevelNotEnough)
        else
            local balan = RoleInfoModel.GetInstance():GetRoleValue(90010003)
            if balan < 1 then
                Notify.ShowText(ConfigLanguage.FPacket.DiamondNotEnough)
            else
                local cf = Config.db_guild_redenvelope[#Config.db_guild_redenvelope]
                lua_panelMgr:GetPanelOrCreate(FPSettlePanel):Open(false, cf)
            end
        end
    end
    --if self.data.link_type ~= 6 then
    --    self.model:Brocast(FPacketEvent.CloseFPanel)
    --end
end