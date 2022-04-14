---
--- Created by  Administrator
--- DateTime: 2019/11/22 15:28
---
CompeteGuessPanel = CompeteGuessPanel or class("CompeteGuessPanel", WindowPanel)
local this = CompeteGuessPanel

function CompeteGuessPanel:ctor(parent_node, parent_panel)
    self.abName = "compete"
    self.imageAb = "compete_image"
    self.assetName = "CompeteGuessPanel"
    self.layer = "UI"
    self.panel_type = 4
    self.show_sidebar = false
    self.events = {}
    self.selects = {}
    self.btnList = {}
    self.index = 0
    self.openMoreBtn = false;
    self.model = CompeteModel:GetInstance()
end

function CompeteGuessPanel:dctor()
    self.model:RemoveTabListener(self.events)
    self.selects = {}
    if self.role_icon1 then
        self.role_icon1:destroy()
        self.role_icon1 = nil
    end
    if self.role_icon2 then
        self.role_icon2:destroy()
        self.role_icon2 = nil
    end
    if not  table.isempty(self.btnList) then
        for i, v in pairs(self.btnList) do
            v:destroy()
        end
        self.btnList = {}
    end
end

function CompeteGuessPanel:Open(data,type)
    self.data = data
    self.rankType = type
    CompeteGuessPanel.super.Open(self)
end

function CompeteGuessPanel:LoadCallBack()
    self.nodes = {
        "rightRole/rightPower","leftRole/leftRoleIcon",
        "rightRole/rightName","rightRole/rightRoleIcon","okBtn","des","leftRole/leftPower","leftRole/leftName",
        "Dropdown","rightRole/rightSelectBg","leftRole/leftSelectBg/leftSelect","rightRole/rightSelectBg/rightSelect","leftRole/leftSelectBg",
        "CompeteGuessItem","morebtnpanel/bg","moreBtn/moreBtnText","morebtnpanel/moreParent",
        "morebtnpanel","moreBtn",
    }
    self:GetChildren(self.nodes)
    self:SetTileTextImage("compete_image", "compete_title1")
    self.rightPower = GetText(self.rightPower)
    self.rightName = GetText(self.rightName)
    self.des = GetText(self.des)
    self.leftPower = GetText(self.leftPower)
    self.leftName = GetText(self.leftName)
    self.bg = GetImage(self.bg)
    self.moreBtnText = GetText(self.moreBtnText)
    SetVisible(self.morebtnpanel,self.openMoreBtn)
    self.selects[1] = self.leftSelect
    self.selects[2] = self.rightSelect
    self:InitUI()
    self:AddEvent()
    self:UpdateInfo()
    self:BtnClick(1)

end

function CompeteGuessPanel:InitUI()
    self:InitBtns()
end

function CompeteGuessPanel:InitBtns()
    local cfg = Config.db_compete_guess
    local isCross = 1
    if self.model.isCross then
        isCross = 0
    end
    local index = 0
    for i = 1, #cfg do
        if cfg[i].islocal == isCross then
            index = index + 1
            local item = self.btnList[index]
            if not item then
                item = CompeteGuessItem(self.CompeteGuessItem.gameObject,self.moreParent,"UI")
                self.btnList[index] = item
            end
            item:SetData(cfg[i])
        end
    end
    self:CompeteGuessItemClick(self.btnList[1])
end

function CompeteGuessPanel:AddEvent()
    local function call_back()
        self:BtnClick(1)
    end
    AddClickEvent(self.leftSelectBg.gameObject,call_back)

    local function call_back()
        self:BtnClick(2)
    end
    AddClickEvent(self.rightSelectBg.gameObject,call_back)

    local function call_back() --确定
        local role
        if self.index == 1 then --左
            -- self.model.actId
            role = self.leftRoleData.role.id
        else --右
            role = self.rightRoleData.role.id
        end

        --local group = 1000 + self.data.id
        --if self.rankType == enum.COMPETE_BATTLE.COMPETE_BATTLE_RANK2  then
        --    group = 2000 + self.data.id
        --end


        CompeteController:GetInstance():RequstCompeteGuessInfo(self.model.actId,self.data.id,role,self.cfgData.type,self.rankType)
    end
    AddClickEvent(self.okBtn.gameObject,call_back)



    local function call_back()
        self.openMoreBtn = not self.openMoreBtn
        SetVisible(self.morebtnpanel,self.openMoreBtn)
    end
    AddClickEvent(self.moreBtn.gameObject,call_back)
    self.events[#self.events + 1] = self.model:AddListener(CompeteEvent.CompeteGuessItemClick,handler(self,self.CompeteGuessItemClick))
    self.events[#self.events + 1] = self.model:AddListener(CompeteEvent.CompeteGuessInfo,handler(self,self.CompeteGuessInfo))

end

function CompeteGuessPanel:CompeteGuessItemClick(item)
    for i, v in pairs(self.btnList) do
        if v.data.type == item.data.type then
            self.cfgData = item.data
            self.moreBtnText.text = item.costNum..enumName.ITEM[item.costId]
        end
    end
    self.openMoreBtn = false
    SetVisible(self.morebtnpanel,self.openMoreBtn)
    local rightTab = String2Table(self.cfgData.right)
    if not table.isempty(rightTab)  then
        local  rightId = rightTab[1][1]
        local rightNum = rightTab[1][2]
        self.des.text = string.format("A successful quiz will give you %s %s",rightNum,enumName.ITEM[rightId])
    end

end

function CompeteGuessPanel:UpdateInfo()
    self.roleTab = self.data.vs
    self.leftRoleData = self.roleTab[1]
    self.rightRoleData = self.roleTab[2]
    self.leftPower.text = self.leftRoleData.role.power
    self.leftName.text = self.leftRoleData.role.name

    self.rightPower.text = self.rightRoleData.role.power
    self.rightName.text = self.rightRoleData.role.name

    if self.role_icon1 then
        self.role_icon1:destroy()
        self.role_icon1 = nil
    end
    local param = {}
    local function uploading_cb()
        --  logError("回调")
    end
    param["is_squared"] = true
    --param["is_hide_frame"] = true
    param["size"] = 70
    param["uploading_cb"] = uploading_cb
    param["role_data"] = self.leftRoleData.role
    self.role_icon1 = RoleIcon(self.leftRoleIcon)
    self.role_icon1:SetData(param)


    if self.role_icon2 then
        self.role_icon2:destroy()
        self.role_icon2 = nil
    end
    local param = {}
    local function uploading_cb()
        --  logError("回调")
    end
    param["is_squared"] = true
    --param["is_hide_frame"] = true
    param["size"] = 70
    param["uploading_cb"] = uploading_cb
    param["role_data"] = self.rightRoleData.role
    self.role_icon2 = RoleIcon(self.rightRoleIcon)
    self.role_icon2:SetData(param)

end

function CompeteGuessPanel:BtnClick(index)
    for i = 1,#self.selects do
        if index == i then
            self.index = index
            SetVisible(self.selects[i],true)
        else
            SetVisible(self.selects[i],false)
        end
    end
end

function CompeteGuessPanel:CompeteGuessInfo(data)
    --logError("竞猜成功")
    Notify.ShowText("Quiz Successful")
    self:Close()
end