---
--- Created by  Administrator
--- DateTime: 2019/8/23 17:32
---
SevenDayPetRankLevelView = SevenDayPetRankLevelView or class("SevenDayPetRankLevelView", BasePanel)
local this = SevenDayPetRankLevelView

function SevenDayPetRankLevelView:ctor(parent_node, parent_panel)
    self.abName = "sevenDayActive"
    self.assetName = "SevenDayPetRankLevelView"
    self.layer = "UI"
    self.use_background = true
    self.show_sidebar = falses
    self.model = SevenDayActiveModel:GetInstance()
    self.items = {}
    --  self.actId = actId
    self.events = {}
end



function SevenDayPetRankLevelView:Open(actId, sort)
    self.actId = actId
    self.sort = sort
    WindowPanel.Open(self)

end

function SevenDayPetRankLevelView:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    for _, item in pairs(self.items) do
        item:destroy()
    end
    self.items = {}
end

function SevenDayPetRankLevelView:LoadCallBack()
    self.nodes = {
        "closeBtn", "rightObj/downTitleBG/downTitleTex", "rightObj/btn", "SevenDayPetRankLevelItem", "leftObj/levelDes", "rightObj/des",
        "rightObj/iconbg/icon", "leftObj/levelTex", "rightObj/btn/btnTex", "leftObj/ScrollView/Viewport/Content",
    }
    self:GetChildren(self.nodes)
    self.des = GetText(self.des)
    self.downTitleTex = GetText(self.downTitleTex)
    self.btnTex = GetText(self.btnTex)
    self.icon = GetImage(self.icon)
    self.levelDes = GetText(self.levelDes)
    self.levelTex = GetText(self.levelTex)
    self:InitUI()
    self:AddEvent()
end

function SevenDayPetRankLevelView:InitUI()
    local rankId = OperateModel:GetInstance():GetConfig(self.actId).rank
    local levelTab = self.model:GetLevelRecTab(rankId)
    for i = 1, #levelTab do
        self.items[i] = SevenDayPetRankLevelItem(self.SevenDayPetRankLevelItem.gameObject, self.Content, "UI")
        self.items[i]:SetData(levelTab[i], i)
    end
    --  local rankId = OperateModel:GetInstance():GetConfig(self.actId).rank
    local cfg = RankModel:GetInstance():GetRankById(rankId)
    local des = self.model:GetRankTypeStr(cfg.event, cfg.id)

    self.levelDes.text = "Current" .. cfg.showdata .. "："
    self.levelTex.text = self.sort
    --if rankId == 110502 then
    --    --坐骑
    --    if self.sort ~= 0 then
    --        local cfg = self.model:GetMountNumByID(self.sort)
    --        self.levelTex.text = string.format("%s阶%s星", cfg.order, cfg.level)
    --    else
    --        self.levelTex.text = string.format("%s阶%s星", 0, 0)
    --    end
    --
    --elseif rankId == 110503 then
    --    if self.sort ~= 0 then
    --        local cfg = self.model:GetOffhandNumByID(self.sort)
    --        self.levelTex.text = string.format("%s阶%s星", cfg.order, cfg.level)
    --    else
    --        self.levelTex.text = string.format("%s阶%s星", 0, 0)
    --    end
    --else
    --    self.levelTex.text = self.sort
    --end


    -- self.levelTex.text = des


    self:SevenDayPetRankClickLevelItem(self.items[1].data, 1)
end

function SevenDayPetRankLevelView:AddEvent()
    local function call_back()
        self:Close()
    end
    AddClickEvent(self.closeBtn.gameObject, call_back)

    local function call_back()
        self:Close()
        local link = String2Table(self.data.panel)
        local tab = link[1]
        if #tab > 2 then
            table.remove(tab,1)
            table.remove(tab,1)
        end
        OpenLink(self.linkId,self.linkSubId,unpack(tab))
       -- UnpackLinkConfig(self.linkId .. "@" .. self.linkSubId)
    end
    AddClickEvent(self.btn.gameObject, call_back)
    self.events[#self.events + 1] = GlobalEvent:AddListener(SevenDayActiveEvent.SevenDayPetRankClickLevelItem, handler(self, self.SevenDayPetRankClickLevelItem))
end


function SevenDayPetRankLevelView:SevenDayPetRankClickLevelItem(data, index)
    self:SetSelect(index)
    self:UpdateInfo(data)
end

function SevenDayPetRankLevelView:UpdateInfo(data)
    self.des.text = data.des
    self.downTitleTex.text = data.name
    self.btnTex.text = data.btnname
    self.data = data
    local link = String2Table(data.panel)
    self.linkId = link[1][1]
    self.linkSubId = link[1][2]
    local abName, assetName = GetLinkAbAssetName(link[1][1], link[1][2])
    lua_resMgr:SetImageTexture(self, self.icon, abName, assetName, true, nil, false)
end

function SevenDayPetRankLevelView:SetSelect(index)
    for i = 1, #self.items do
        if index == i then
            self.items[i]:SetSelect(true)
        else
            self.items[i]:SetSelect(false)
        end
    end
end