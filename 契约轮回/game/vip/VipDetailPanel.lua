
-- @Author: lwj
-- @Date:   2018-12-06 10:53:51
-- @Last Modified time: 2019-10-25 10:29:11

VipDetailPanel = VipDetailPanel or class("VipDetailPanel", WindowPanel)
local VipDetailPanel = VipDetailPanel

function VipDetailPanel:ctor()
    self.abName = "vip"
    self.assetName = "VipDetailPanel"
    self.layer = "UI"

    self.use_background = true
    self.panel_type = 3
    self.click_bg_close = true
    --self.change_scene_close = true
    self.model = VipModel.GetInstance()
    self.desItemList = {}
    self.itemSize = 35
    self.bottom = 0
end

function VipDetailPanel:dctor()
end

function VipDetailPanel:Open(page)
    WindowPanel.Open(self)
    self.curPage = page
end

function VipDetailPanel:LoadCallBack()
    self.nodes = {
        "sundries/title",
        "desScrollView",
        "desScrollView/Viewport/Content",
        "DetailItem",
        "btn_last",
        "btn_next",
        "nextText", "lastText",
    }
    self:GetChildren(self.nodes)
    self:SetPanelSize(651.87, 480.22)
    self:SetBgLocalPos(-15,6,0)
    self:SetTitleImgPos(-37.9,7.87)
    self:AddEvent()
    self:UpdateView()
    self:SetTileTextImage("vip_image", "detail_title", true)
end

function VipDetailPanel:AddEvent()
    local function call_back()
        if self.curPage - 1 == 1 then
            SetVisible(self.btn_last, false)
            SetVisible(self.lastText, false)
        end
        self.curPage = self.curPage - 1
        self:UpdateView()
        self.lastText:GetComponent('Text').text = "VIP" .. tostring(self.curPage - 1)
        self.nextText:GetComponent('Text').text = "VIP" .. tostring(self.curPage + 1)
        if self.curPage < table.nums(Config.db_vip_level) - 1 then
            if not self.nextText.gameObject.activeSelf then
                SetVisible(self.nextText, true)
                SetVisible(self.btn_next, true)
            end
        end
    end
    AddButtonEvent(self.btn_last.gameObject, call_back)

    local function call_back()
        if self.curPage + 1 == table.nums(Config.db_vip_level) - 1 then
            SetVisible(self.btn_next, false)
            SetVisible(self.nextText, false)
        end
        self.curPage = self.curPage + 1
        self:UpdateView()
        self.nextText:GetComponent('Text').text = "VIP" .. tostring(self.curPage + 1)
        self.lastText:GetComponent('Text').text = "VIP" .. tostring(self.curPage - 1)
        if self.curPage ~= 1 then
            if not self.lastText.gameObject.activeSelf then
                SetVisible(self.lastText, true)
                SetVisible(self.btn_last, true)
            end
        end
    end
    AddButtonEvent(self.btn_next.gameObject, call_back)
    --
    --local call_back = function(target, x, y)
    --    self.dragX = x
    --end
    --AddDragBeginEvent(self.dragView.gameObject, call_back)
    --
    --local call_back = function(target, x, y)
    --    if x < self.dragX then
    --        if self.curPage ~= table.nums(Config.db_vip_level) then
    --            self.curPage = self.curPage + 1
    --            self:UpdateView()
    --        end
    --    elseif x > self.dragX then
    --        if self.curPage ~= 1 then
    --            self.curPage = self.curPage - 1
    --            self:UpdateView()
    --        end
    --    end
    --end
    --AddDragEndEvent(self.dragView.gameObject, call_back)

end 

function VipDetailPanel:OpenCallBack()
    if self.curPage < table.nums(Config.db_vip_level) - 1 then
        self.nextText:GetComponent('Text').text = "VIP" .. tostring(self.curPage + 1)
    end
    if self.curPage ~= 1 then
        self.lastText:GetComponent('Text').text = "VIP" .. tostring(self.curPage - 1)
    end
    local rect = GetRectTransform(self)
    SetLocalPositionZ(rect, -1000)
end

function VipDetailPanel:UpdateView()
    self.title:GetComponent('Text').text = "V" .. self.curPage
    self:HandleGoodsLoad()
    if self.curPage == 1 then
        SetVisible(self.btn_last, false)
        SetVisible(self.lastText, false)
    elseif self.curPage == table.nums(Config.db_vip_level) - 1 then
        SetVisible(self.nextText, false)
        SetVisible(self.btn_next, false)
    end
end

function VipDetailPanel:HandleGoodsLoad()
    self.willLoadList = {}
    local des = ""
    local final = ""
    local temp = ""
    local value = nil
    local tbl = self.model:GetVipRightsCf()
    --dump(tbl, "<color=#6ce19b>VipDetailPanel   VipDetailPanel  VipDetailPanel  VipDetailPanel</color>")
    -- for i = 1, table.nums(tbl) do
    for i, v in table.pairsByKey(Config.db_vip_rights) do
        local cf
        for idx = 1, #tbl do
            local data = tbl[idx]
            if data.rights == i then
                cf = data
                break
            end
        end
        value = cf["vip" .. self.curPage]
        des = cf.desc
        des = string.gsub(des, "q", "")
        if value ~= "0" then
            if cf.type == 2 then
                final = des
            else
                temp = self.model:GetValueByType(cf.type, value)
                --final = string.gsub(des, "%s", temp)
                final = string.gsub(des, "x", temp)
                
            end
            table.insert(self.willLoadList, final)
        end
    end
    --判断
    self.desItemList = self.desItemList or {}
    local len = #self.willLoadList
    for i = 1, len do
        local item = self.desItemList[i]
        if not item then
            item = DetailItem(self.Content, "UI")
            self.desItemList[i] = item
        else
            item:SetVisible(true)
        end
        item:SetData(self.willLoadList[i])
    end
    for i = len + 1, #self.desItemList do
        local item = self.desItemList[i]
        item:SetVisible(false)
    end

    --if willShowNums <= 6 then
    --    self.bottom = 0
    --else
    --    self.bottom = self.itemSize * 6
    --end
end

function VipDetailPanel:CloseCallBack()
    for i, v in pairs(self.desItemList) do
        if v then
            v:destroy()
        end
    end
    self.desItemList = {}
end