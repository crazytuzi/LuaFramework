-- @Author: lwj
-- @Date:   2019-09-20 19:42:59 
-- @Last Modified time: 2019-09-20 19:43:01

NationHighTaskItem = NationHighTaskItem or class("NationHighTaskItem", BaseCloneItem)
local NationHighTaskItem = NationHighTaskItem

function NationHighTaskItem:ctor(parent_node, layer)
    NationHighTaskItem.super.Load(self)
end

function NationHighTaskItem:dctor()
end

function NationHighTaskItem:LoadCallBack()
    self.model = NationModel.GetInstance()
    self.nodes = {
        "btn_go", "des", "icon", "pro", "fin_img",
    }
    self:GetChildren(self.nodes)
    self.des = GetText(self.des)
    self.icon = GetImage(self.icon)
    self.pro = GetText(self.pro)

    self:AddEvent()
end

function NationHighTaskItem:AddEvent()
    local function callback()
        if self.show_tbl[2] then
            local jump_tbl = self.show_tbl[2][2]
            OpenLink(unpack(jump_tbl))
            if jump_tbl[1] ~= 890 then
                self.model:Brocast(NationEvent.CloseNationPanel)
            end
        else
            logError(self.data.cf.id .. "没有配置跳转")
        end
    end
    AddButtonEvent(self.btn_go.gameObject, callback)
end

function NationHighTaskItem:SetData(data)
    self.data = data
    self:UpdateView()
end

function NationHighTaskItem:UpdateView()
    --dump(String2Table(self.data.cf.trigger), "<color=#6ce19b>NationHighTaskItem   NationHighTaskItem  NationHighTaskItem  NationHighTaskItem</color>")
    local sin_pro = String2Table(self.data.cf.trigger)[2][2]
    local sum_count = String2Table(self.data.cf.task)[2]
    self.des.text = string.format(ConfigLanguage.OpenHigh.FinAnyTaskToGetPro, self.data.cf.desc, sin_pro)
    local color = "<color=#FFFFFF>"
    local is_run_out = self.data.ser_info.count == sum_count
    if is_run_out then
        color = "<color=#FF0000>"
    end
    SetVisible(self.btn_go, not is_run_out)
    SetVisible(self.fin_img, is_run_out)
    self.pro.text = color .. self.data.ser_info.count .. "/" .. sum_count .. '</color>'
    self.show_tbl = String2Table(self.data.cf.sundries)
    lua_resMgr:SetImageTexture(self, self.icon, "main_image", self.show_tbl[1][2], true, nil, false)
end
