---
--- Created by  Administrator
--- DateTime: 2019/5/5 14:43
---
ArenaRoleItem = ArenaRoleItem or class("ArenaRoleItem", BaseCloneItem)
local this = ArenaRoleItem

function ArenaRoleItem:ctor(obj, parent_node, parent_panel)
    self.model = ArenaModel:GetInstance()
    self.events = {}
    ArenaRoleItem.super.Load(self)


end

function ArenaRoleItem:dctor()
    self.model:RemoveTabListener(self.events)
    if self.creep then
        self.creep:destroy()
    end
    if self.roleMode then
        self.roleMode:destroy()
    end
end

function ArenaRoleItem:LoadCallBack()
    self.nodes = {
        "name", "rank", "power", "roleModelCon", "headBG/mask/head", "select", "click"
    , "powerUp"
    }
    self:GetChildren(self.nodes)
    self.name = GetText(self.name)
    self.rank = GetText(self.rank)
    self.power = GetText(self.power)
    self.head = GetImage(self.head)
    self:InitUI()
    self:AddEvent()


    --local texture = RenderTexture(Constant.RT.RtWidth, Constant.RT.RtHeight, Constant.RT.RtDepth)
    --self.roleModelCon:GetComponent("RawImage").texture = texture
    --self.roleCamera:GetComponent("Camera").targetTexture = texture

end

function ArenaRoleItem:InitUI()

end

function ArenaRoleItem:AddEvent()


    local function call_back()
        self.model:Brocast(ArenaEvent.ArenaItemClick, self.index)
    end
    AddClickEvent(self.click.gameObject, call_back)

    self.events[#self.events + 1] = self.model:AddListener(ArenaEvent.ArenaIsWing, handler(self, self.ArenaIsWing))
end

function ArenaRoleItem:SetData(data, index)
    self.data = data
    self.index = index

    self:SetPos()
    self:SetInfo()

    if self.data.creep ~= 0 then
        --怪物
        self:InitRoleModel()
    else
        --玩家
        self:InitRoleModel(not self.model.isShowWing)
        --self:ArenaIsWing( self.model.isShowWing)
    end
end

function ArenaRoleItem:SetPos()
    if self.index == 3 then
        SetLocalPosition(self.transform, 555, -4, 0)
    elseif self.index == 1 then
        SetLocalPosition(self.transform, 286, 51, 0)
    elseif self.index == 2 then
            SetLocalPosition(self.transform,-2,-4,0)
    end
end

function ArenaRoleItem:SetInfo()
    self.rank.text = "No." .. self.data.rank
    self.name.text = self.data.name
    local power = GetShowNumber(self.data.power)
    self.power.text = "CP:" .. power
    SetVisible(self.powerUp, self.data.sti_times > 0)
    if self.data.gender == 1 then
        --男
        lua_resMgr:SetImageTexture(self, self.head, "main_image", "img_role_head_1", true, nil, false)
    else
        lua_resMgr:SetImageTexture(self, self.head, "main_image", "img_role_head_2", true, nil, false)
    end
end

function ArenaRoleItem:InitRoleModel(isWing)
    if self.creep then
        self.creep:destroy()
    end
    if self.roleMode then
        self.roleMode:destroy()
    end
    local data = {}
    data.res_id = 11001
    local config = {}
    config.is_show_wing = isWing
    config.trans_x = 450
    config.trans_y = 450
    self.roleMode = UIRoleCamera(self.roleModelCon, nil, self.data, 1, false, self.index, config)
end

function ArenaRoleItem:SetSelect(show)
    SetVisible(self.select, show)
end

function ArenaRoleItem:ArenaIsWing(show)
    local isShow = not show
    if self.data.creep == 0 then
        --  self:InitRoleModel(not show)
        if self.roleMode then
            self.roleMode:SetWingVisible(isShow)
        end
    end
end