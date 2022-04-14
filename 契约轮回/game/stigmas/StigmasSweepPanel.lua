---
--- Created by  Administrator
--- DateTime: 2019/9/26 19:37
---
StigmasSweepPanel = StigmasSweepPanel or class("StigmasSweepPanel", WindowPanel)
local this = StigmasSweepPanel

function StigmasSweepPanel:ctor(parent_node, parent_panel)

    self.abName = "stigmas"
    self.assetName = "StigmasSweepPanel"
    self.image_ab = "stigmas_image";
    self.layer = "UI"
    self.panel_type = 4
    self.events = {}
    self.curBossNum = 1
    self.model = StigmasModel:GetInstance()
end

function StigmasSweepPanel:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    if self.itemIcon then
        self.itemIcon:destroy()
    end
    self.itemIcon = nil
end

function StigmasSweepPanel:LoadCallBack()
    self.nodes = {
        "numObj/num","box/buyBoxTex","iconParent","numObj/addBtn","numObj/reduceBtn","box",
        "okBtn","qxBtn",
    }
    self:GetChildren(self.nodes)
    self.num = GetText(self.num)
    self.buyBoxTex = GetText(self.buyBoxTex)
    self.box = GetToggle(self.box)
    self.addImg = GetImage(self.addBtn)
    self.reduceImg = GetImage(self.reduceBtn)
    self:SetTimesBox(false)
    self.num.text = self.curBossNum
    ShaderManager.GetInstance():SetImageGray(self.reduceImg)
    self.maxBossNum = 6 --暂时写死
    self:InitUI()
    self:AddEvent()
    self:SetTileTextImage("stigmas_image", "stigmas_title_tex2");
end

function StigmasSweepPanel:SetTimesBox(bool)
    bool = bool and true or false;
    self.box.isOn = bool
end

function StigmasSweepPanel:InitUI()
    local costCfg = String2Table(Config.db_dunge_soul["summon_cost"].val) --召唤BOSS消耗
    local sweepCost = String2Table(Config.db_dunge[30501].sweep_cost)
    local costId = costCfg[1][1]
    self.costNum = costCfg[1][2]
    self.buyBoxTex.text = string.format("Use <color=#07A227>%s</color> bound diamonds to summon",self.costNum)
    local sweepID = sweepCost[1]
    local sweepNum = sweepCost[2]
    self:CreateIcon(sweepID,sweepNum)
end

function StigmasSweepPanel:CreateIcon(id,num)
    local mNum = BagModel:GetInstance():GetItemNumByItemID(id);
    local color = "00FF1A"
    if mNum < (num or 1) then
        color = "FF1200"
    end
    if self.itemIcon == nil  then
        self.itemIcon = GoodsIconSettorTwo(self.iconParent)
    end
    local param = {}
    param["model"] = self.model
    param["item_id"] = id
    param["num"] = string.format("<color=#%s>%s/%s</color>",color,mNum,num or 1)
    param["can_click"] = true
    param["show_num"] = true
    self.itemIcon:SetIcon(param)
end

function StigmasSweepPanel:AddEvent()
    local function call_back()
        self.curBossNum = self.curBossNum + 1
        if self.curBossNum  > self.maxBossNum then
            self.curBossNum = self.maxBossNum
        end
        self:SetBtnState()
    end
    AddButtonEvent(self.addBtn.gameObject,call_back)
    local function call_back()
        self.curBossNum = self.curBossNum - 1
        if self.curBossNum < 1 then
            self.curBossNum = 1
        end
        self:SetBtnState()
    end
    AddButtonEvent(self.reduceBtn.gameObject,call_back)


    local function call_back()
        self:Close()
    end
    AddButtonEvent(self.qxBtn.gameObject,call_back)



    local function call_back()
        local data = {}
        data["boss"] = self.curBossNum
        if self.box.isOn then
            DungeonCtrl:GetInstance():RequestSweep(enum.SCENE_STYPE.SCENE_STYPE_DUNGE_SOUL,nil,data)
        else
            DungeonCtrl:GetInstance():RequestSweep(enum.SCENE_STYPE.SCENE_STYPE_DUNGE_SOUL)
        end

    end
    AddButtonEvent(self.okBtn.gameObject,call_back)

    self.events[#self.events + 1] = GlobalEvent:AddListener(DungeonEvent.DUNGEON_SWEEP_REFRESH, handler(self, self.HandleSweep))

end

function StigmasSweepPanel:HandleSweep(data)
   -- logError("返回扫荡")
    local sweepCost = String2Table(Config.db_dunge[30501].sweep_cost)
    local sweepID = sweepCost[1]
    local sweepNum = sweepCost[2]
    self:CreateIcon(sweepID,sweepNum)
end

function StigmasSweepPanel:SetBtnState()
    self.num.text = self.curBossNum
    if self.curBossNum == 1 then
        ShaderManager.GetInstance():SetImageGray(self.reduceImg)
        ShaderManager.GetInstance():SetImageNormal(self.addImg)
    elseif self.curBossNum == self.maxBossNum  then
        ShaderManager.GetInstance():SetImageGray(self.addImg)
        ShaderManager.GetInstance():SetImageNormal(self.reduceImg)
    else
        ShaderManager.GetInstance():SetImageNormal(self.addImg)
        ShaderManager.GetInstance():SetImageNormal(self.reduceImg)
    end
    self.buyBoxTex.text = string.format("Use <color=#07A227>%s</color> bound diamonds to summon",self.costNum *  self.curBossNum )
end