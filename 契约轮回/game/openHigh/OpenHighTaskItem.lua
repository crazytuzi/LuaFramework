-- @Author: lwj
-- @Date:   2019-07-19 20:28:33 
-- @Last Modified time: 2019-07-19 20:28:35

OpenHighTaskItem = OpenHighTaskItem or class("OpenHighTaskItem", BaseCloneItem)
local OpenHighTaskItem = OpenHighTaskItem

function OpenHighTaskItem:ctor(parent_node, layer)
    OpenHighTaskItem.super.Load(self)
end

function OpenHighTaskItem:dctor()
end

function OpenHighTaskItem:LoadCallBack()
    self.model = OperateModel.GetInstance()
    self.nodes = {
        "btn_go", "des", "icon", "pro", "fin_img",
    }
    self:GetChildren(self.nodes)
    self.des = GetText(self.des)
    self.icon = GetImage(self.icon)
    self.pro = GetText(self.pro)

    self:AddEvent()
end

function OpenHighTaskItem:AddEvent()
    local function callback()
        if self.show_tbl[2] then
            local jump_tbl = self.show_tbl[2][2]
            OpenLink(unpack(jump_tbl))
        else
            logError(self.data.cf.id .. "没有配置跳转")
        end
    end
    AddButtonEvent(self.btn_go.gameObject, callback)
end

function OpenHighTaskItem:SetData(data)
    self.data = data
    self:UpdateView()
end

function OpenHighTaskItem:UpdateView()
    --dump(String2Table(self.data.cf.trigger), "<color=#6ce19b>OpenHighTaskItem   OpenHighTaskItem  OpenHighTaskItem  OpenHighTaskItem</color>")
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
