-- @Author: lwj
-- @Date:   2019-12-20 14:19:03
-- @Last Modified by:   win 10
-- @Last Modified time: 2019-12-20 14:19:03

CloundLotRecoItem = CloundLotRecoItem or class("CloundLotRecoItem", BaseItem)
local CloundLotRecoItem = CloundLotRecoItem

function CloundLotRecoItem:ctor(parent_node, layer)
    self.abName = "nation"
    self.assetName = "CloundLotRecoItem"
    self.layer = layer

    self.model = NationModel.GetInstance()
    CloundLotRecoItem.super.Load(self)
end

function CloundLotRecoItem:dctor()

end

function CloundLotRecoItem:LoadCallBack()
    self.nodes = {
        "des",
    }
    self:GetChildren(self.nodes)
    SetLocalPositionXY(self.des.transform, 172.6, -23.5)

    local des_rect = GetRectTransform(self.des)
    self.des = GetText(self.des)
    SetSizeDelta(des_rect, 345.2, 47)

    self:AddEvent()
    self:InitPanel()
end

function CloundLotRecoItem:AddEvent()

end

function CloundLotRecoItem:InitPanel()
    local s_name = RoleInfoModel:GetInstance():GetServerName(self.data.suid)
    local reward_id = self.data.reward_id
    local cf = Config.db_yunying_lottery_rewards[reward_id]
    local name = ""
    local color_str = ""
    if cf then
        local tbl = String2Table(cf.rewards)[1]
        local item_id = tbl[1]
        local item_cf = Config.db_item[item_id]
        name = item_cf.name
        color_str = ColorUtil.GetColor(item_cf.color)
    end
    local str = string.format("<color=#75f0ff>%s</color> <color=#5fff53>%s</color> Can be obtained in cross-server purchase <color=#%s>%s</color>", s_name, self.data.role_name, color_str, name)
    self.des.text = str
end

function CloundLotRecoItem:SetData(data)
    self.data = data
    if self.is_loaded then
        self:InitPanel()
    end
end