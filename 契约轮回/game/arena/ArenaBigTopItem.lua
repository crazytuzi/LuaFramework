---
--- Created by  Administrator
--- DateTime: 2019/5/7 14:48
---
ArenaBigTopItem = ArenaBigTopItem or class("ArenaBigTopItem", BaseCloneItem)
local this = ArenaBigTopItem

function ArenaBigTopItem:ctor(obj, parent_node, parent_panel)
    self.events = {}
    self.model = ArenaModel:GetInstance()
    ArenaBigTopItem.super.Load(self)

end

function ArenaBigTopItem:dctor()
    -- GlobalEvent:RemoveTabListener(self.events)
    self.model:RemoveTabListener(self.events)
    if self.creep then
        self.creep:destroy()
    end
    if self.roleMode then
        self.roleMode:destroy()
    end
end

function ArenaBigTopItem:LoadCallBack()
    self.nodes = {
        "rank", "select", "click", "name", "power", "headBG/mask/head", "roleModelCon",
        "powerUp"
    }
    self:GetChildren(self.nodes)
    self.name = GetText(self.name)
    self.power = GetText(self.power)
    self.head = GetImage(self.head)
    self.rank = GetText(self.rank)
    self:InitUI()
    self:AddEvent()


    --local texture = RenderTexture(Constant.RT.RtWidth, Constant.RT.RtHeight, Constant.RT.RtDepth)
    --self.roleModelCon:GetComponent("RawImage").texture = texture
    --self.roleCamera:GetComponent("Camera").targetTexture = texture

end

function ArenaBigTopItem:InitUI()

end

function ArenaBigTopItem:AddEvent()

    local function call_back()
        self.model:Brocast(ArenaEvent.ArenaBigItemClick, self.index)
    end
    AddClickEvent(self.click.gameObject, call_back)

    self.events[#self.events + 1] = self.model:AddListener(ArenaEvent.ArenaBigIsWing, handler(self, self.ArenaBigIsWing))
end

function ArenaBigTopItem:SetData(data, index)
    self.data = data
    self.index = index
    self:SetPos()
    self:SetInfo()
    if self.data.creep ~= 0 then
        --怪物
        self:InitRoleModel()
    else
        self:InitRoleModel(not self.model.isShowWing)
    end
end

function ArenaBigTopItem:SetPos()
    if self.data.rank == 1 then
        SetLocalPosition(self.transform, 285, 94, 0)
    elseif self.data.rank == 2 then
        SetLocalPosition(self.transform, 0, 0, 0)
        --   SetLocalPosition(self.roleCamera.transform,2100,-165,0)
    elseif self.data.rank == 3 then
        SetLocalPosition(self.transform, 580, 0, 0)
    end
end

function ArenaBigTopItem:SetInfo()
    self.name.text = self.data.name
    self.power.text = "CP:" .. self.data.power
    self.rank.text = "No." .. self.data.rank .. "No. X"
    local power = GetShowNumber(self.data.power)
    self.power.text = "CP:" .. power
    --if self.data.sti_times > 0  then
    --    local power =  self.model:GetPower(self.data.sti_times,self.data.power)
    --    self.power.text =  "战力："..power
    --else
    --    local power = GetShowNumber(self.data.power)
    --    self.power.text =  "战力："..power
    --end
    SetVisible(self.powerUp, self.data.sti_times > 0)
    if self.data.gender == 1 then
        --男
        lua_resMgr:SetImageTexture(self, self.head, "main_image", "img_role_head_1", true, nil, false)
    else
        lua_resMgr:SetImageTexture(self, self.head, "main_image", "img_role_head_2", true, nil, false)

    end
end

function ArenaBigTopItem:InitRoleModel(isWing)
    SetVisible(self.creepModelCon, false)
    SetVisible(self.roleModelCon, true)
    if self.creep then
        self.creep:destroy()
    end
    if self.roleMode then
        self.roleMode:destroy()
    end
    local data = {}
    data.res_id = 11001
    if self.data.figure.weapon then
        data.default_weapon = self.data.figure.weapon.model
    end
    if isWing then
        if self.data.figure.wing then
            data.wing_res_id = self.data.figure.wing.model
        end
    end
    -- self.roleMode = UIRoleModel(self.roleModelCon, handler(self, self.LoadModelCallBack), data)
    local config = {}
    config.trans_x = 450
    config.trans_y = 450
    config.trans_offset = {y=4.2}
    config.is_show_wing = isWing
    self.roleMode = UIRoleCamera(self.roleModelCon, nil, self.data, 1, false, self.index, config)
    --  self.roleMode:SetWingVisible(isWing)
end

function ArenaBigTopItem:ArenaBigIsWing(show)
    if self.data.creep == 0 then
        --  self:InitRoleModel(not show)
        if self.roleMode then
            self.roleMode:SetWingVisible(not show)
        end
    end
end

function ArenaBigTopItem:SetShow(isShow)
    SetVisible(self.select, isShow)
end