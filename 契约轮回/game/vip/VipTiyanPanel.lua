VipTiyanPanel = VipTiyanPanel or class("VipTiyanPanel", BasePanel)
local VipTiyanPanel = VipTiyanPanel

function VipTiyanPanel:ctor()
    self.abName = "vip"
    self.assetName = "VipTiyanPanel"
    self.layer = "UI"

    self.panel_type = 2
    self.use_background = true
    self.change_scene_close = true
    --self.model = 2222222222222end:GetInstance()
end

function VipTiyanPanel:dctor()
end

function VipTiyanPanel:Open()
    VipTiyanPanel.super.Open(self)
end

function VipTiyanPanel:LoadCallBack()
    self.nodes = {
        "title",
        "btn_close", "btn_use", "countdown", "open_vip", "model", "bg", "right_scroll/Viewport/right_con", "right_scroll/Viewport/right_con/VFourRightItem",
    }
    self:GetChildren(self.nodes)

    self.big_bg = GetImage(self.bg)
    self.right_obj = self.VFourRightItem.gameObject

    self:AddEvent()

    SetLocalPosition(self.model, -385, 15.3, 0)
    LayerManager.GetInstance():AddOrderIndexByCls(self, self.title.transform, nil, true, nil, false, 2)

    local res = "vip_taste_bg"
    lua_resMgr:SetImageTexture(self, self.big_bg, "iconasset/icon_big_bg_" .. res, res)
end

function VipTiyanPanel:AddEvent()

    local function call_back(target, x, y)
        if BagModel:GetInstance():GetItemNumByItemID(11110) > 0 then
            self:UseVipCard()
        end
        self:Close()
    end
    AddClickEvent(self.btn_close.gameObject, call_back)

    local function call_back(target, x, y)
        self:UseVipCard()
        self:Close()
    end
    AddClickEvent(self.btn_use.gameObject, call_back)

    local function call_back(target, x, y)
        lua_panelMgr:GetPanelOrCreate(VipDetailPanel):Open(4)
    end
    AddClickEvent(self.open_vip.gameObject, call_back)
end

function VipTiyanPanel:OpenCallBack()
    self:UpdateView()
end

function VipTiyanPanel:UpdateView()
    if self.eft ~= nil then
        self.eft:destroy()
        self.eft = nil
    end
    self.eft = UIEffect(self.btn_use, 10121, false, self.layer)
    self.eft:SetConfig({ scale = 1.6 })
    self:LoadRightsItem()
    if not self.coundownitem then
        local param = {
            isShowMin = false,
            duration = 0.033,
            formatText = "(Trial starts in %s sec)",
            formatTime = "%d",
        }
        self.coundownitem = CountDownText(self.countdown, param)
    end
    local function finish()
        self:UseVipCard()
        self:Close()
    end
    self.coundownitem:StartSechudle(os.time() + 9, finish)
    if self.role_model then
        self.role_model:destroy()
    end
    -- self.role_model = UIPetCamera(self.model, nil, 20005, 2, nil, nil, 10312)
    self.role_model = UIPetCamera(self.model, nil, 20005, 8, nil, nil)
end

function VipTiyanPanel:LoadRightsItem()
    local cf = VipModel.GetInstance():GetVipRightsCf()
    self.right_list = {}
    for i = 1, #cf do
        local data = cf[i]
        local value = data["vip" .. 4]
        if value ~= "0" then
            local des = data.desc
            local final
            local temp
            des = string.gsub(des, "q", "")
            if data.type == 2 then
                final = des
            else
                temp = VipModel.GetInstance():GetValueByType(data.type, value)
                final = string.gsub(des, "x", temp)
            end
            local item = VFourRightItem(self.right_obj, self.right_con)
            item:SetData(final)
            self.right_list[#self.right_list + 1] = item
        end
    end
end

function VipTiyanPanel:CloseCallBack()
    if self.eft ~= nil then
        self.eft:destroy()
        self.eft = nil
    end
    if self.coundownitem then
        self.coundownitem:destroy()
    end
    if self.role_model then
        self.role_model:destroy()
    end
    for i, v in pairs(self.right_list) do
        if v then
            v:destroy()
        end
    end
    self.right_list = {}
end

function VipTiyanPanel:UseVipCard()
    local uid = BagModel:GetInstance():GetUidByItemID(11110)
    if uid then
        GoodsController:GetInstance():RequestUseGoods(uid, 1)
    end
end