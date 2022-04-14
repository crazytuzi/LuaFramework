---
--- Created by  Administrator
--- DateTime: 2020/3/14 11:06
---
MergeSerRankPanel = MergeSerRankPanel or class("MergeSerRankPanel", SevenDayRankPanel)
local this = MergeSerRankPanel

function MergeSerRankPanel:ctor(parent_node, parent_panel,actID)
    self.abName = "sevenDayActive"
    self.assetName = "MergeSerRankPanel"
    self.layer = "UI"
    self.parentPanel = parent_panel
    self.events = {}
    self.actID = actID
    --print2(actID)
    --print2(actID)
    --print2(actID)
    self.model = SevenDayActiveModel:GetInstance()
    self.openData = OperateModel:GetInstance():GetAct(self.actID)
    self.data = OperateModel:GetInstance():GetActInfo(self.actID)
    self.rewardItems = {}
    self.rankItems = {}
    MergeSerRankPanel.super.Load(self)
end

function MergeSerRankPanel:dctor()
    MergeSerRankPanel.super.dctor(self)
    if self.UIRole then
        self.UIRole:destroy()
    end
    self.UIRole = nil

    if self.eft then
        self.eft:destroy()
    end
    self.eft = nil
end

function MergeSerRankPanel:BeforeLoad()

end

function MergeSerRankPanel:LoadCallBack()
    self.nodes = {
        "roleContainer","eft_con",
    }
    self:GetChildren(self.nodes)
    MergeSerRankPanel.super.LoadCallBack(self)
end

function MergeSerRankPanel:InitTextPic()

    --local function call_back()
    --    LayerManager:GetInstance():AddOrderIndexByCls(self,self.leftzi.transform,nil,true,nil,nil,4)
    --end
    lua_resMgr:SetImageTexture(self,self.leftzi,"iconasset/icon_mergeser",self.actID, false,handler(self,self.TextureCallBack))
end


function MergeSerRankPanel:InitModel()
    local cfg =   OperateModel:GetInstance():GetConfig(self.actID)
    local tab = String2Table(cfg.reqs)
    local type = tab[2]
    if tab[1] == "model" then --模型
        local name = tab[3]
        if type == 1 then
            if self.monster then
                self.monster:destroy()
            end
            self.monster = UIModelCommonCamera(self.modelCon, nil, name);--data.icon
            SetVisible(self.eft_con.gameObject, false)
            SetVisible(self.effParent,true)
             local config = {};
            if self.actID == 180503 then
                config.scale = { x = 60, y = 60, z = 60};
                config.pos = {x = -1989, y = -149, z = 200}
            elseif self.actID == 180505  then
                config.pos = {x = -1991, y = -110, z = 200}
                config.rotate = {x = 9,y=138,z = -2}
            end

             self.monster:SetConfig(config)
            
        else
            if self.monster then
                self.monster:destroy()
            end
            if self.eft then
                self.eft:destroy()
            end
            self.eft = UIEffect(self.eft_con, tonumber(name), false, self.layer)
            self.eft:SetConfig({ is_loop = true ,scale = 80})

            SetVisible(self.eft_con.gameObject, true)
            SetVisible(self.effParent,false)
            local roleInfoModel = RoleInfoModel:GetInstance():GetMainRoleData()

            local config = {}
            config.trans_x = 500
            config.trans_y = 500
            config.trans_offset = {y=7.3}
            --config.scale = { x = 60, y = 60, z = 60};
            config.is_show_magic=true
            self.monster = UIRoleCamera(self.roleContainer, nil, roleInfoModel,nil,nil,nil,config)

        end

    else --图标
        if self.monster then
            self.monster:destroy()
        end
        SetVisible(self.effParent,true)
        SetVisible(self.eft_con.gameObject, false)
        lua_resMgr:SetImageTexture(self,self.leftTex,"iconasset/icon_mergeser",type, false)
    end
    --dump(tab)
end
