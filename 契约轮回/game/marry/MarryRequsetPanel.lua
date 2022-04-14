---
--- Created by  Administrator
--- DateTime: 2019/6/12 10:30
---
MarryRequsetPanel = MarryRequsetPanel or class("MarryRequsetPanel", BasePanel)
local this = MarryRequsetPanel

function MarryRequsetPanel:ctor(parent_node, parent_panel)
    self.abName = "marry"
    self.assetName = "MarryRequsetPanel"
    self.image_ab = "marry_image";
    self.layer = "UI"
    self.events = {}
    self.itemicon = {}
    self.use_background = true
    self.model = MarryModel:GetInstance()
    self.role =  RoleInfoModel.GetInstance():GetMainRoleData()
end

function MarryRequsetPanel:Open(data)
    self.data = data
    WindowPanel.Open(self)
end

function MarryRequsetPanel:dctor()
    self.model:RemoveTabListener(self.events)
    for i, v in pairs(self.itemicon) do
        v:destroy()
    end
    self.itemicon = {}
    if self.role_icon1 then
        self.role_icon1:destroy()
        self.role_icon1 = nil
    end

    if self.role_icon2 then
        self.role_icon2:destroy()
        self.role_icon2 = nil
    end
end

function MarryRequsetPanel:LoadCallBack()
    self.nodes = {
        "refBtn","okBtn","myObj/role_bg/role_icon","myObj/role_bg/level_bg/level","myObj/name","enemyObj/enemy_bg/enemy_icon",
        "enemyObj/enemy_bg/level_bg/enemy_level","enemyObj/enemy_name",
        "desObj/des","closeBtn","downObj/titleImg","iconParent"
    }
    self:GetChildren(self.nodes)
  --  self.role_icon = GetImage(self.role_icon)
    self.name = GetText(self.name)
    self.level = GetText(self.level)
   -- self.enemy_icon = GetImage(self.enemy_icon)
    self.enemy_name = GetText(self.enemy_name)
    self.enemy_level = GetText(self.enemy_level)
    self.des = GetText(self.des)
    self.titleImg = GetImage(self.titleImg)
    self:InitUI()
    self:AddEvent()
end

function MarryRequsetPanel:InitUI()
    self:SetMyInfo()
    self:SetEnemyInfo()
    local type = self.data.type
    local cfg = Config.db_marriage_type[type]
    if  not cfg then
        return
    end
    local marryName = cfg.name
    if self.data.is_aa then
        self.des.text = string.format("%s wants to have %s with you and cost will be split evenly",self.data.role.name,marryName)
    else
        self.des.text = string.format("%s wants to have %s with you and cost will be paid by the fiance!",self.data.role.name,marryName)
    end

    lua_resMgr:SetImageTexture(self, self.titleImg, Constant.TITLE_IMG_PATH, cfg.title, false, nil, false)
    self:CreartIcon()
end

function MarryRequsetPanel:AddEvent()
    
    local function call_back()  --拒绝
        MarryController:GetInstance():RequsetProposalRefuse(self.data.role.id)
    end
    AddClickEvent(self.refBtn.gameObject,call_back)

    local function call_back()  --同意
        MarryController:GetInstance():RequsetProposalAccept(self.data.role.id)
    end
    AddClickEvent(self.okBtn.gameObject,call_back)
    
    local function call_back()
        self:Close()
    end
    AddClickEvent(self.closeBtn.gameObject,call_back)
    self.events[#self.events + 1] = self.model:AddListener(MarryEvent.ProposalRefuse,call_back)
    self.events[#self.events + 1] = self.model:AddListener(MarryEvent.ProposalAccept,call_back)
end

function MarryRequsetPanel:SetMarryInfo()
    
end

function MarryRequsetPanel:SetMyInfo()
    self.name.text = self.role.name
    self.level.text = self.role.level
    if self.role_icon1 then
        self.role_icon1:destroy()
        self.role_icon1 = nil
    end
    local param = {}
    local function uploading_cb()
        --  logError("回调")
    end
    param["is_squared"] = true
    param["is_hide_frame"] = true
    param["size"] = 72
    param["uploading_cb"] = uploading_cb
    param["role_data"] = self.role
    self.role_icon1 = RoleIcon(self.role_icon)
    self.role_icon1:SetData(param)
    --local icon = "img_role_head_1"
    --if self.role.gender == 2 then
    --    icon = "img_role_head_2"
    --end
    --lua_resMgr:SetImageTexture(self,self.role_icon, 'main_image', icon, true)
end


function MarryRequsetPanel:SetEnemyInfo()
    local role = self.data.role
    self.enemy_name.text = role.name
    self.enemy_level.text = role.level
    --local icon = "img_role_head_1"
    --if role.gender == 2 then
    --    icon = "img_role_head_2"
    --end
    --lua_resMgr:SetImageTexture(self,self.enemy_icon, 'main_image', icon, true)
    if self.role_icon2 then
        self.role_icon2:destroy()
        self.role_icon2 = nil
    end
    local param = {}
    local function uploading_cb()
        --  logError("回调")
    end
    param["is_squared"] = true
    param["is_hide_frame"] = true
    param["size"] = 72
    param["uploading_cb"] = uploading_cb
    param["role_data"] = self.data.role
    self.role_icon2 = RoleIcon(self.enemy_icon)
    self.role_icon2:SetData(param)

end

function MarryRequsetPanel:CreartIcon()
    local type = self.data.type
    local cfg = Config.db_marriage_type[type]
    local  tab = String2Table(cfg.reward)
    dump(tab)
    for i = 1, #tab do
        --self:CreateIcon(rewardTab[i][1],rewardTab[i][2])
        if self.itemicon[i] == nil then
            self.itemicon[i] = GoodsIconSettorTwo(self.iconParent)
        else
            return
        end
        local param = {}
        param["model"] = self.model
        param["item_id"] = tab[i][1]
        param["num"] = tab[i][2]
        param["can_click"] = true
        --  param["size"] = {x = 72,y = 72}
        self.itemicon[i]:SetIcon(param)
    end
end

