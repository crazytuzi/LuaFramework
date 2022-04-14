---
--- Created by  Administrator
--- DateTime: 2019/5/8 16:38
---
ArenaRankPanel = ArenaRankPanel or class("ArenaRankPanel", WindowPanel)
local this = ArenaRankPanel

function ArenaRankPanel:ctor(parent_node, parent_panel)
    self.abName = "arena";
    self.image_ab = "arena_image";
    self.assetName = "ArenaRankPanel"
    self.layer = "UI"
    self.events = {}
    self.modelEvents = {}
    self.rankItems = {}
    self.use_background = true
    self.click_bg_close = true
    self.panel_type = 3
    self.pageIndex = 1
    --self.is_hide_other_panel = true
    --  self.creepId = 30371001


    self.model = ArenaModel:GetInstance()
end

function ArenaRankPanel:Open()
    ArenaRankPanel.super.Open(self)
end


function ArenaRankPanel:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    self.model:RemoveTabListener(self.modelEvents)
    if self.creep then
        self.creep:destroy()
    end
    if self.roleMode  then
        self.roleMode:destroy()
    end
	for k, v in pairs(self.rankItems) do
		v:destroy()
	end
	self.rankItems = {}

end

function ArenaRankPanel:LoadCallBack()
    self.nodes = {
        "ArenaRankItem","content","pageTex","myRankBg/myRankTex","button/wenhaoBtn","button/lastBtn","button/nextBtn","button/maxBtn","button/minBtn","myObj/moneyTex",
        "roleModelCon","button/lqBtn","headObj/nameObj/name","headObj/union","headObj/nameObj/nameTitle","headObj/title",
        "powerObj/power","myObj/moneyIcon",
    }
    self:GetChildren(self.nodes)
    self.myRankTex = GetText(self.myRankTex)
    self.pageTex = GetText(self.pageTex)
    self.lqBtnImg = GetImage(self.lqBtn)
    self.moneyTex = GetText(self.moneyTex)
    self.titleImg = GetImage(self.title)
    self.nameTitleTex = GetText(self.nameTitle)
    self.nameTex = GetText(self.name)
    self.union = GetText(self.union)
    self.power = GetText(self.power)
	self.moneyIcon = GetImage(self.moneyIcon)
    self.text_title_1_outline = self.nameTitle:GetComponent('Outline')
    self:SetTileTextImage("arena_image", "arena_title3")

    self:InitUI()
    self:AddEvent()
    self.layerIndex = LuaPanelManager:GetInstance():GetPanelInLayerIndex(self.layer, self)
    RankController:GetInstance():RequestRankListInfo(1011,1)
    ArenaController:GetInstance():RequstArenaRank()


    local rankCfg =  RankModel:GetInstance():GetRankById(1011)
    local rankSize = 0
    if rankCfg then
        rankSize = rankCfg.size
    end
    self.maxPage = rankSize/5
	
end

function ArenaRankPanel:InitUI()

	local iconName = Config.db_item[enum.ITEM.ITEM_HONOR].icon
	GoodIconUtil:CreateIcon(self, self.moneyIcon, iconName, true)
end

function ArenaRankPanel:SetTitle(isRole,data)
    if isRole then  --人物
        local roleBase = data.base
      --  SetVisible(self.title,true)
        SetVisible(self.union,true)
        SetVisible(self.nameTitle,true)
        self.nameTex.text = roleBase.name
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
        
    else  --机器人
        SetVisible(self.title,false)
        SetVisible(self.union,false)
        SetVisible(self.nameTitle,false)
        self.nameTex.text = data.base.name
    end

end

function ArenaRankPanel:UpdateTitelPos()
    local name_width = self.nameTex.preferredWidth
    local job_title_width = self.nameTitleTex.preferredWidth
    local name_x = job_title_width * 0.5
    local job_title_x = -name_width * 0.5 - name_x
    -- SetLocalPositionX(self.name, name_x)
    SetLocalPositionX(self.nameTitle, job_title_x)
end

function ArenaRankPanel:AddEvent()
    local function call_back()  --问号
        ShowHelpTip(HelpConfig.Arena.rank,true);
    end
    AddClickEvent(self.wenhaoBtn.gameObject,call_back)


    local function call_back()  --上一页
        local page = self.pageIndex - 1
        if page <= 0 then
            Notify.ShowText("You are on the first page")
            return
        end
        RankController:GetInstance():RequestRankListInfo(1011,page)

    end
    AddClickEvent(self.lastBtn.gameObject,call_back)

    local function call_back()  --下一页
        local page = self.pageIndex + 1
        if page > self.maxPage  then
            Notify.ShowText("You are on the last page")
            return
        end
        RankController:GetInstance():RequestRankListInfo(1011,page)
    end
    AddClickEvent(self.nextBtn.gameObject,call_back)


    local function call_back()  --最大页数
        RankController:GetInstance():RequestRankListInfo(1011,self.maxPage)
    end
    AddClickEvent(self.maxBtn.gameObject,call_back)


    local function call_back()  --最小页数
        RankController:GetInstance():RequestRankListInfo(1011,1)
    end
    AddClickEvent(self.minBtn.gameObject,call_back)

    local function call_back()
        if self.model.isRankReward then
            Notify.ShowText("You have already claimed today's rewards")
            return
        end
        ArenaController:GetInstance():RequstRankfetch()
    end
    AddClickEvent(self.lqBtn.gameObject,call_back)

    self.events[#self.events + 1] = GlobalEvent:AddListener(RankEvent.RankReturnList, handler(self, self.RankReturnList))
    self.modelEvents[#self.modelEvents+ 1] = self.model:AddListener(ArenaEvent.ArenaRankItemClick, handler(self, self.ArenaRankItemClick))
    self.modelEvents[#self.modelEvents+ 1] = self.model:AddListener(ArenaEvent.ArenaRankFetch, handler(self, self.ArenaRankFetch))
    self.modelEvents[#self.modelEvents+ 1] = self.model:AddListener(ArenaEvent.ArenaLqRankFetch, handler(self, self.ArenaLqRankFetch))

end

function ArenaRankPanel:RankReturnList(data)
    self.data = data
    self.pageIndex = data.page
    self:UpdateRankItems(data.list)
    self:SetInfo(data)
    self:SetPageText(data.page)
    self:ArenaRankItemClick(1)
end

function ArenaRankPanel:ArenaRankFetch()
    if self.model.isRankReward then --已领取
        ShaderManager.GetInstance():SetImageGray(self.lqBtnImg)
    else
        if self.data.mine.rank == 0 then
            ShaderManager.GetInstance():SetImageGray(self.lqBtnImg)
        else
            ShaderManager.GetInstance():SetImageNormal(self.lqBtnImg)
        end
    end
end

function ArenaRankPanel:ArenaLqRankFetch()
    if self.model.isRankReward then --已领取
        ShaderManager.GetInstance():SetImageGray(self.lqBtnImg)
    else
        ShaderManager.GetInstance():SetImageNormal(self.lqBtnImg)
    end
end

function ArenaRankPanel:SetPageText(page)
    --local rankCfg =  RankModel:GetInstance():GetRankById(1011)
    --local rankSize = 0
    --if rankCfg then
    --    rankSize = rankCfg.size
    --end
    --local maxPage = rankSize/5
    self.pageTex.text = string.format("Page %s/%s",page,self.maxPage)
end

function ArenaRankPanel:SetInfo(data)
    if data.mine.rank == 0 then
        self.myRankTex.text = "Rank: unranked"
        self.moneyTex.text = "0"
       -- ShaderManager.GetInstance():SetImageGray(self.lqBtnImg)
    else
        self.myRankTex.text = "My Ranking:"..data.mine.rank
        --if not self.model.isRankReward  then
        --    ShaderManager.GetInstance():SetImageNormal(self.lqBtnImg)
        --end
        local money =  self.model:GetRankHonerReward(data.mine.rank)
        self.moneyTex.text = money

    end
    --local money =  RoleInfoModel:GetInstance():GetRoleValue(Constant.GoldType.Honor)
    --self.moneyTex.text = money
end

function ArenaRankPanel:UpdateRankItems(tab)
    for i = 1, #tab do
        local item = self.rankItems[i]
        if not item then
            item = ArenaRankItem(self.ArenaRankItem.gameObject,self.content,"UI")
            self.rankItems[i] = item
            item:SetData(tab[i],i)
        else
            item:SetData(tab[i],i)
        end
    end
end

function ArenaRankPanel:ArenaRankItemClick(index)
    for i = 1, #self.rankItems do
        if i == index then
            self.rankItems[i]:SetSelect(true)
            if  tonumber(self.rankItems[i].data.base.id) < 3000 then  --机器人
                self:InitRoleModel(self.rankItems[i].data)
                self:SetTitle(false,self.rankItems[i].data)
            else
                self:InitRoleModel(self.rankItems[i].data)
                self:SetTitle(true,self.rankItems[i].data)
            end
            self.power.text = self.rankItems[i].data.base.power
        else
            self.rankItems[i]:SetSelect(false)
        end
    end
end


function ArenaRankPanel:InitRoleModel(roleData)
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
    config.trans_offset = {y=18.98}
    self.roleMode = UIRoleCamera(self.roleModelCon, nil,roleData.base,1,false,1,config,self.layerIndex)
   -- self.roleMode = UIRoleModel(self.roleModelCon, handler(self, self.LoadModelCallBack), data)
end


