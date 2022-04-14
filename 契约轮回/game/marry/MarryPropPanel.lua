---
--- Created by  Administrator
--- DateTime: 2019/6/10 19:48
---
MarryPropPanel = MarryPropPanel or class("MarryPropPanel", BasePanel)
local this = MarryPropPanel

function MarryPropPanel:ctor(parent_node, parent_panel)
    self.abName = "marry"
    self.assetName = "MarryPropPanel"
    self.layer = LayerManager.LayerNameList.UI

    self.use_background = true
    self.change_scene_close = true
    self.click_bg_close = true
    self.is_hide_other_panel = true
    self.events = {}
    self.items = {}
    self.model = MarryModel:GetInstance()
    self.role =  RoleInfoModel.GetInstance():GetMainRoleData()
   -- self.roleList = FriendModel:GetInstance():GetFriendList()
end
function MarryPropPanel:Open(role)
    self.sRole = role
    MarryPropPanel.super.Open(self)

end

function MarryPropPanel:dctor()

    self.model:RemoveTabListener(self.events)
    for i, v in pairs(self.items) do
        v:destroy()
    end
    self.items = {}

    if self.role_icon1 then
        self.role_icon1:destroy()
        self.role_icon1 = nil
    end

    if self.role_icon2 then
        self.role_icon2:destroy()
        self.role_icon2 = nil
    end
end

function MarryPropPanel:LoadCallBack()
    self.nodes = {
        "enemyObj/enemy_bg/enemy_icon","content","myObj/role_bg/role_icon","closeBtn","myObj/name","myObj/role_bg",
        "myObj/role_bg/level_bg/level","MarryPropItem","enemyObj/enemy_bg/level_bg/enemy_level","enemyObj/enemy_bg",
        "enemyObj/enemy_name","priceBox","okBtn","friendObj","friendClick","enemyObj"
    }
    self:GetChildren(self.nodes)
    self.name = GetText(self.name)
    self.level = GetText(self.level)
  --  self.role_icon = GetImage(self.role_icon)
   -- self.enemy_icon = GetImage(self.enemy_icon)
    self.enemy_name = GetText(self.enemy_name)
    self.enemy_level = GetText(self.enemy_level)
    self.priceBox = GetToggle(self.priceBox)
    self:InitUI()
    self:AddEvent()
    self:SetProceBox(false)
  --  MarryController:GetInstance():RequsetMarriageInfo()
end

function MarryPropPanel:SetProceBox()
    bool = bool and true or false;
    --  self.model.lvBox = false
    self.priceBox.isOn = bool
end

function MarryPropPanel:InitUI()
    local cfg = Config.db_marriage_type
    for i = 1, #cfg do
        local item = self.items[i]
        if not item then
            item = MarryPropItem(self.MarryPropItem.gameObject,self.content,"UI")
            self.items[i] = item
        end
        item:SetData(cfg[i])
    end

    self:ClickMarryPropItem(3)
    self:SetMyInfo()
    self:SetMarryInfo()

    if self.role.marry ~= 0 then
        self:UpdateEnemyInfo(self.model.withMarry)
        SetVisible(self.friendClick,false)
    else
        if self.sRole then
            self:UpdateEnemyInfo(self.sRole)
            SetVisible(self.friendClick,false)
        end
    end

    --if self.model.withMarry.marry ~= 0  then
    --    self:UpdateEnemyInfo(self.model.withMarry)
    --    SetVisible(self.friendClick,false)
    --end
end

function MarryPropPanel:AddEvent()

    local function call_back()  --确定提亲
        if not self.selectRole  then
            Notify.ShowText("Please select the player to make proposal")
            return
        end
        local cfg = Config.db_marriage_type[self.selectItem.type]
        local costTab = String2Table(cfg.cost)
        local money = costTab[1][1]
        local num = costTab[1][2]
		local type = Constant.GoldType.Gold
		if money == enum.ITEM.ITEM_BGOLD then
			type = Constant.GoldType.BGold
			
		end
        if self.priceBox.isOn then
            if   RoleInfoModel:GetInstance():CheckGold(math.floor(num/2),type) then
                MarryController:GetInstance():RequsetProposalInfo(self.selectRole.id,self.selectItem.type,self.priceBox.isOn)
            end
        else
            if   RoleInfoModel:GetInstance():CheckGold(num,type) then
                MarryController:GetInstance():RequsetProposalInfo(self.selectRole.id,self.selectItem.type,self.priceBox.isOn)
            end
        end


       -- print2(self.selectRole.id,self.selectItem.level,self.priceBox.isOn)

    end
    AddClickEvent(self.okBtn.gameObject,call_back)

    local function call_back() --好友列表
        lua_panelMgr:GetPanelOrCreate(MarryPropFriendPanel):Open()
    end
    AddClickEvent(self.friendClick.gameObject,call_back)

    local function call_back()
        self:Close()
    end
    AddClickEvent(self.closeBtn.gameObject,call_back)

    local function call_back()
        
    end
    AddValueChange(self.priceBox.gameObject,call_back)
    self.events[#self.events + 1] = self.model:AddListener(MarryEvent.MarriagePanelInfo,handler(self,self.MarriagePanelInfo))
    self.events[#self.events + 1] = self.model:AddListener(MarryEvent.ClickPropFriendItem,handler(self,self.ClickPropFriendItem))
    self.events[#self.events + 1] = self.model:AddListener(MarryEvent.ClickMarryPropItem,handler(self,self.ClickMarryPropItem))
end

function MarryPropPanel:SetMarryInfo()

end


function MarryPropPanel:SetMyInfo()
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
    param["size"] = 71
    param["uploading_cb"] = uploading_cb
    self.role_icon1 = RoleIcon(self.role_icon)
    self.role_icon1:SetData(param)
    --local icon = "img_role_head_1"
    --if self.role.gender == 2 then
    --    icon = "img_role_head_2"
    --end
    --lua_resMgr:SetImageTexture(self,self.role_icon, 'main_image', icon, true)
end



--更新选中玩家的信息
function MarryPropPanel:UpdateEnemyInfo(role)
    dump(role.base)
    SetVisible(self.friendObj,false)
    SetVisible(self.enemyObj,true)
    self.selectRole = role
    self.enemy_name.text = role.name
    self.enemy_level.text = role.level
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
    param["size"] = 71
    param["uploading_cb"] = uploading_cb
    param["role_data"] = role
    self.role_icon2 = RoleIcon(self.enemy_icon)
    self.role_icon2:SetData(param)
    --local icon = "img_role_head_1"
    --if role.gender == 2 then
    --    icon = "img_role_head_2"
    --end
    --lua_resMgr:SetImageTexture(self,self.enemy_icon, 'main_image', icon, true)
    MarryController:GetInstance():RequsetProposalPanelInfo(role.id)
end


function MarryPropPanel:MarriagePanelInfo(data)
    --dump(data)
    --local tab = data.types
    --for i, v in pairs(tab) do
    --    self.items[i]:SetTimes(v)
    --end
end

function MarryPropPanel:ClickPropFriendItem(data)
    --self.selectRole = data.base
    dump(data.base)
    self:UpdateEnemyInfo(data.base)
end

function MarryPropPanel:ClickMarryPropItem(type)
    for i = 1, #self.items do
        if type == self.items[i].data.type then
            self.items[i]:SetSelect(true)
            self.selectItem = self.items[i].data
        else
            self.items[i]:SetSelect(false)
        end
    end
end

