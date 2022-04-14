-- @Author: lwj
-- @Date:   2019-05-14 21:53:01
-- @Last Modified by:   win 10
-- @Last Modified time: 2019-05-14 21:53:05

FPRecoPanel = FPRecoPanel or class("FPRecoPanel", BasePanel)
local FPRecoPanel = FPRecoPanel

function FPRecoPanel:ctor()
    self.abName = "factionPacket"
    self.assetName = "FPRecoPanel"
    self.layer = "UI"

    self.model = FPacketModel.GetInstance()
    self.use_background = true
    self.max_list = {}
    self.is_contain_self = false
    self.got_data = nil
end

function FPRecoPanel:dctor()

end

function FPRecoPanel:Open(uid, is_hole_data)
    if is_hole_data then
        self.ser_data = uid
    else
        self.ser_data = self.model:GetRPDataByUid(uid)
    end
    FPRecoPanel.super.Open(self)
end

function FPRecoPanel:OpenCallBack()
end

function FPRecoPanel:LoadCallBack()
    self.nodes = {
        "mask/icon", "from", "Reco_Scroll/Viewport/reco_con/FPRecoItem", "desc", "Reco_Scroll/Viewport/reco_con",
        "btn_close",
        "no_rest", "rushed", "rushed/money", "rushed/money_icon",
    }
    self:GetChildren(self.nodes)
    self.money_icon = GetImage(self.money_icon)
    self.icon = GetImage(self.icon)
    self.from = GetText(self.from)
    self.reco_obj = self.FPRecoItem.gameObject
    self.desc = GetText(self.desc)
    self.money = GetText(self.money)

    self:AddEvent()
    self:InitPanel()
end

function FPRecoPanel:AddEvent()
    AddButtonEvent(self.btn_close.gameObject, handler(self, self.Close))
end

function FPRecoPanel:InitPanel()
    self.from.text = string.format(ConfigLanguage.FPacket.FPSender, self.ser_data.role.name)
    self.gold_type = nil
    local gold_num
    for i, v in pairs(self.ser_data.money) do
        gold_num = v
        self.gold_type = i
        break
    end
    GoodIconUtil.GetInstance():CreateIcon(self, self.money_icon, tostring(self.gold_type), true)
    self:LoadRecoItem()
    if self.is_contain_self then
        SetVisible(self.rushed, true)
        SetVisible(self.no_rest, false)
        self.money.text = self.got_data.money
    end
    local gender = self.ser_data.role.gender
    lua_resMgr:SetImageTexture(self, self.icon, "main_image", "img_role_head_" .. gender, true, nil, false)
    local cur_num = #self.ser_data.gots
    local sum = self.ser_data.num
    local value = gold_num
    local val_name = FreeGiftModel.GetInstance():GetMoneyTypeNameByItemId(self.gold_type)
    self.desc.text = string.format(ConfigLanguage.FPacket.RecoDes, cur_num, sum, value, val_name)
end

function FPRecoPanel:SortReco()
    local list = self.ser_data.gots
    local function SortFunc(a, b)
        return a.time < b.time
    end
    table.sort(list, SortFunc)

    for i = 1, #list do
        local data = list[i]
        if #self.max_list == 0 then
            self.max_list[1] = data
        elseif data.money == self.max_list[1].money then
            self.max_list[#self.max_list + 1] = data
        elseif data.money > self.max_list[1].money then
            self.max_list = {}
            self.max_list[1] = data
        end
    end
    return list
end

function FPRecoPanel:LoadRecoItem()
    local my_id = RoleInfoModel.GetInstance():GetMainRoleId()
    local list = self:SortReco()
    self.reco_item_list = self.reco_item_list or {}
    local len = #list
    for i = 1, len do
        local item = self.reco_item_list[i]
        if not item then
            item = FPRecoItem(self.reco_obj, self.reco_con)
            self.reco_item_list[i] = item
        else
            item:SetVisible(true)
        end
        list[i].is_european = self:IsEuropean(list[i].role.id)
        list[i].gold_type = self.gold_type
        list[i].index = i
        item:SetData(list[i])
        if list[i].role.id == my_id then
            self.is_contain_self = true
            self.got_data = list[i]
        end
    end
    for i = len + 1, #self.reco_item_list do
        local item = self.reco_item_list[i]
        item:SetVisible(false)
    end
end

--是不是手气最佳
function FPRecoPanel:IsEuropean(role_id)
    local is_white_bitch = false
    for i = 1, #self.max_list do
        local data = self.max_list[i]
        if data.role.id == role_id then
            is_white_bitch = true
            break
        end
    end
    return is_white_bitch
end

function FPRecoPanel:CloseCallBack()

end