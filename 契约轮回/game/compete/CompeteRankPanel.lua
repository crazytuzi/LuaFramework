---
--- Created by  Administrator
--- DateTime: 2019/11/26 17:48
---
CompeteRankPanel = CompeteRankPanel or class("CompeteRankPanel", WindowPanel)
local this = CompeteRankPanel

function CompeteRankPanel:ctor(parent_node, parent_panel)
    self.abName = "compete"
    self.assetName = "CompeteRankPanel"
    self.layer = "UI"
    self.events = {}
    self.rankItems = {}
    self.rewards = {}
    self.use_background = true
    self.click_bg_close = true
    self.panel_type = 3
    self.btns = {}
    self.rankItems = {}
    self.model = CompeteModel:GetInstance()
end

function CompeteRankPanel:dctor()
    self.model:RemoveTabListener(self.events)
    if not table.isempty(self.btns) then
        for i, v in pairs(self.btns) do
            v:destroy(0)
        end
        self.btns = {}
    end
    if not table.isempty(self.rankItems) then
        for i, v in pairs(self.rankItems) do
            v:destroy(0)
        end
        self.rankItems = {}
    end

    if self.roleMode  then
        self.roleMode:destroy()
    end

end

function CompeteRankPanel:LoadCallBack()
    self.nodes = {
        "CompeteRankItem","headObj/title","headObj/nameObj/nameTitle","rankScrollView/Viewport/rankContent","roleModelCon",
        "noObj","headObj/union","powerObj/power","headObj/nameObj/name","CompeteRankBtnItem","buttonParent","headObj",
    }
    self:GetChildren(self.nodes)
    self.titleImg = GetImage(self.title)
    self.nameTitleTex = GetText(self.nameTitle)
    self.nameTex = GetText(self.name)
    self.union = GetText(self.union)
    self.power = GetText(self.power)
    SetVisible(self.headObj,false)
    SetVisible(self.powerObj,false)
    self.text_title_1_outline = self.nameTitle:GetComponent('Outline')
    self:SetTileTextImage("compete_image", "compete_title4")
    self:InitUI()
    self:AddEvent()
    CompeteController:GetInstance():RequstCompeteHistoryInfo()
end

function CompeteRankPanel:InitUI()

end

function CompeteRankPanel:AddEvent()
   -- CompeteHistoryInfo
    self.events[#self.events + 1] = self.model:AddListener(CompeteEvent.CompeteHistoryInfo, handler(self, self.CompeteHistoryInfo))
    self.events[#self.events + 1] = self.model:AddListener(CompeteEvent.CompeteRankBtnClick, handler(self, self.CompeteRankBtnClick))
    self.events[#self.events + 1] = self.model:AddListener(CompeteEvent.CompeteRankItemClick, handler(self, self.CompeteRankItemClick))
end

function CompeteRankPanel:CompeteRankItemClick(rank)
    for i, v in pairs(self.rankItems) do
        if v.data.rank == rank then
            self:InitRoleModel(v.data)
            self:SetTitle(v.data)
            v:SetSelect(true)
        else
            v:SetSelect(false)
        end
    end
end

function CompeteRankPanel:CompeteHistoryInfo(data)
    --logError("往期战报")
   -- data.history
    if table.isempty(data.history) then
        SetVisible(self.noObj,true)
        SetVisible(self.headObj,false)
        return
    end
    for i = 1, #data.history do
        local item = self.btns[i]
        if not item then
            item = CompeteRankBtnItem(self.CompeteRankBtnItem.gameObject,self.buttonParent,"UI")
            self.btns[i] = item
        end
        item:SetData(data.history[i])
    end
    if not table.isempty(self.btns) then
        self:CompeteRankBtnClick(self.btns[1].data)
    end
end

function CompeteRankPanel:CompeteRankBtnClick(data)
    for i, v in pairs(self.btns) do
        if data.season == v.data.season then
          --  self.curSeasonData = data
            self:UpdateRankItems(data)
            v:SetSelect(true)
        else
            v:SetSelect(false)
        end
    end
end

function CompeteRankPanel:UpdateRankItems(data)
    local rankTab = data.ranking

    for i = 1, #rankTab do
        local buyItem =  self.rankItems[i]
        if  not buyItem then
            buyItem = CompeteRankItem(self.CompeteRankItem.gameObject,self.rankContent,"UI")
            self.rankItems[i] = buyItem
        else
            buyItem:SetVisible(true)
        end
        buyItem:SetData(rankTab[i])
    end
    for i = #rankTab + 1,#self.rankItems do
        local buyItem = self.rankItems[i]
        buyItem:SetVisible(false)
    end
    if table.isempty(rankTab) then
        SetVisible(self.noObj,true)
        SetVisible(self.headObj,false)
        SetVisible(self.powerObj,false)
    else
        self:CompeteRankItemClick(1)
        SetVisible(self.noObj,false)
    end
end

function CompeteRankPanel:InitRoleModel(roleData)
    if self.roleMode  then
        self.roleMode:destroy()
    end
    local data = {}
    data.res_id = 11001
    if roleData.base.figure.weapon then
        data.default_weapon = roleData.base.figure.weapon.model
    end
    local config = {}
    config.trans_x = 500
    config.trans_y = 500
    self.roleMode = UIRoleCamera(self.roleModelCon, nil,roleData.base,3,false,1,config,self.layerIndex)
end

function CompeteRankPanel:SetTitle(data)
    SetVisible(self.headObj,true)
    SetVisible(self.powerObj,true)
    local roleBase = data.base
    --  SetVisible(self.title,true)
    SetVisible(self.union,true)
    SetVisible(self.nameTitle,true)
    self.nameTex.text = roleBase.name
    self.power.text = roleBase.power
    self.title_id = roleBase.figure.jobtitle and roleBase.figure.jobtitle.model
    self.title_id = self.title_id or 0
    local cur_config = Config.db_jobtitle[self.title_id]
    if not cur_config then
        self.nameTitleTex.text = ""
        return
    end
    self.nameTitleTex.text = cur_config.name
    local r,g,b,a = HtmlColorStringToColor(cur_config.color)
    SetOutLineColor(self.text_title_1_outline, r,g,b,a)
    self:UpdateTitelPos()
    if roleBase.guild == nil or roleBase.gname == "" then
        self.union.text = "No guild yet"
    else
        self.union.text = roleBase.gname
    end
    if roleBase.figure.title.model == 0 then
        SetVisible(self.title,false)
    else
        lua_resMgr:SetImageTexture(self, self.titleImg, Constant.TITLE_IMG_PATH, tostring(roleBase.figure.title.model), false, nil, false)
        SetVisible(self.title,true)
    end
end

function CompeteRankPanel:UpdateTitelPos()
    local name_width = self.nameTex.preferredWidth
    local job_title_width = self.nameTitleTex.preferredWidth
    local name_x = job_title_width * 0.5
    local job_title_x = -name_width * 0.5 - name_x
    -- SetLocalPositionX(self.name, name_x)
    SetLocalPositionX(self.nameTitle, job_title_x)
end