---
--- Created by  Administrator
--- DateTime: 2019/4/19 11:10
---
SevenDayRankLevelView = SevenDayRankLevelView or class("SevenDayRankLevelView", BasePanel)
local this = SevenDayRankLevelView

function SevenDayRankLevelView:ctor()
    self.abName = "sevenDayActive"
    self.assetName = "SevenDayRankLevelView"
    self.layer = "UI"
    self.use_background = true
    self.show_sidebar = falses
    self.model = SevenDayActiveModel:GetInstance()
    self.items = {}
    --  self.actId = actId
    self.events = {}
    --    SevenDayRankLevelView.super.Load(self)
end

function SevenDayRankLevelView:Open(actId, sort)
    self.actId = actId
    self.sort = sort
    WindowPanel.Open(self)

end

function SevenDayRankLevelView:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    for _, item in pairs(self.items) do
        item:destroy()
    end
    self.items = {}
end

function SevenDayRankLevelView:LoadCallBack()
    self.nodes = {
        "closeBtn", "rightObj/downTitleBG/downTitleTex", "rightObj/btn", "SevenDayRankLevelItem", "leftObj/levelDes", "rightObj/des",
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

function SevenDayRankLevelView:InitUI()
    -- local rankActCfg = Config.db_rank_active[self.actId]
    --  print2(self.actId)
    local rankId = OperateModel:GetInstance():GetConfig(self.actId).rank
    local levelTab = self.model:GetLevelRecTab(rankId)
    for i = 1, #levelTab do
        self.items[i] = SevenDayRankLevelItem(self.SevenDayRankLevelItem.gameObject, self.Content, "UI")
        self.items[i]:SetData(levelTab[i], i)
    end
    --  local rankId = OperateModel:GetInstance():GetConfig(self.actId).rank
    local cfg = RankModel:GetInstance():GetRankById(rankId)
    local des = self.model:GetRankTypeStr(cfg.event, cfg.id)

    self.levelDes.text = "Current" .. cfg.showdata .. "："

    if rankId == 110502 then
        --坐骑
        if self.sort ~= 0 then
            local cfg = self.model:GetMountNumByID(self.sort)
            self.levelTex.text = string.format("T%sS%s", cfg.order, cfg.level)
        else
            self.levelTex.text = string.format("T%sS%s", 0, 0)
        end

    elseif rankId == 110503 then
        if self.sort ~= 0 then
            local cfg = self.model:GetOffhandNumByID(self.sort)
            self.levelTex.text = string.format("T%sS%s", cfg.order, cfg.level)
        else
            self.levelTex.text = string.format("T%sS%s", 0, 0)
        end
    else
        self.levelTex.text = self.sort
    end


    -- self.levelTex.text = des


    self:SevenDayRankClickLevelItem(self.items[1].data, 1)
    --dump(levelTab)
end

function SevenDayRankLevelView:AddEvent()

    local function call_back()
        self:Close()
    end
    AddClickEvent(self.closeBtn.gameObject, call_back)

    local function call_back()
        --UnpackLinkConfig(self.data.panel)
        local linkTab = String2Table(self.data.panel)
        local tab = linkTab[1]
        OpenLink(unpack(tab))
        self:Close()
    end
    AddClickEvent(self.btn.gameObject, call_back)
    self.events[#self.events + 1] = GlobalEvent:AddListener(SevenDayActiveEvent.SevenDayRankClickLevelItem, handler(self, self.SevenDayRankClickLevelItem))
end

function SevenDayRankLevelView:SevenDayRankClickLevelItem(data, index)
    self:SetSelect(index)
    self:UpdateInfo(data)
end

function SevenDayRankLevelView:UpdateInfo(data)
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

function SevenDayRankLevelView:SetSelect(index)
    for i = 1, #self.items do
        if index == i then
            self.items[i]:SetSelect(true)
        else
            self.items[i]:SetSelect(false)
        end
    end
end