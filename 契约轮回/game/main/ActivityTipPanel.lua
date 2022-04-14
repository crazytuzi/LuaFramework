--
-- @Author: LaoY
-- @Date:   2019-03-30 14:44:12
--
ActivityTipPanel = ActivityTipPanel or class("ActivityTipPanel", BasePanel)

function ActivityTipPanel:ctor()
    self.abName = "system"
    self.assetName = "ActivityTipPanel"

    self.layer = LayerManager.LayerNameList.Bottom

    self.use_background = false
    self.change_scene_close = true
end

function ActivityTipPanel:dctor()
end

function ActivityTipPanel:Open(id, sub_id, ...)
    self.id = id
    self.sub_id = sub_id
    self.params = { ... }
    ActivityTipPanel.super.Open(self)
end

function ActivityTipPanel:LoadCallBack()
    self.nodes = {
        "group/img_icon", "group/btn_close", "group/text_des", "group/btn_go",
    }
    self:GetChildren(self.nodes)

    self.img_icon_component = self.img_icon:GetComponent('Image')
    self.text_des_component = self.text_des:GetComponent('Text')
    self:AddEvent()
end

function ActivityTipPanel:AddEvent()
    local function call_back(target, x, y)
        if table.isempty(self.params) then
            UnpackLinkConfig(self.id .. "@" .. self.sub_id)
        else
            OpenLink(self.id, self.sub_id, unpack(self.params))
        end
        self:Close()
    end
    AddClickEvent(self.btn_go.gameObject, call_back)

    local function call_back(target, x, y)
        self:Close()
    end
    AddClickEvent(self.btn_close.gameObject, call_back)
end

function ActivityTipPanel:OpenCallBack()
    self:UpdateView()
end

function ActivityTipPanel:UpdateView()
    local icon_cf = GetOpenLink(self.id, self.sub_id)
    if icon_cf then
        self:SetImageIcon(icon_cf.icon)
    end
    local key = self.id .. "@" .. self.sub_id
    local cf = Config.db_activity_tip[key]
    if cf then
        self.text_des_component.text = cf.des
    end
end

function ActivityTipPanel:SetImageIcon(res_str)
    local image_res = string.split(res_str, ":")
    local abName = image_res[1]
    local assetName = image_res[2]
    if not abName or not assetName then
        return
    end
    if assetName and self.assetName == assetName then
        return
    end
    self.assetName = assetName
    lua_resMgr:SetImageTexture(self, self.img_icon_component, abName, assetName, true)
end

function ActivityTipPanel:CloseCallBack()

end