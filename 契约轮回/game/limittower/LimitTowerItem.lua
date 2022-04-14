---
--- Created by  Administrator
--- DateTime: 2019/11/1 11:07
---
LimitTowerItem = LimitTowerItem or class("LimitTowerItem", BaseCloneItem)
local this = LimitTowerItem

function LimitTowerItem:ctor(obj, parent_node, parent_panel)
    LimitTowerItem.super.Load(self)
    self.events = {}
    self.itemicon = {}
    self.model = LimitTowerModel:GetInstance()
end

function LimitTowerItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    for i, v in pairs(self.itemicon) do
        v:destroy()
    end
    self.itemicon = {}
end

function LimitTowerItem:LoadCallBack()
    self.nodes = {
        "flag","select","crossImg","iconParent","power","floorTex","bg","mask"
    }
    self:GetChildren(self.nodes)
    self.power = GetText(self.power)
    self.floorTex = GetText(self.floorTex)
    self.crossImg = GetImage(self.crossImg)
    self:InitUI()
    self:AddEvent()
end

function LimitTowerItem:InitUI()

end

function LimitTowerItem:AddEvent()

    local function call_back()
        if self.crossState == 2 then
            Notify.ShowText("Clear the previous stage to unlock it")
            return
        end
        self.model:Brocast(LimitTowerEvent.LimitTowerItemClick,self.floor)
    end
    AddClickEvent(self.bg.gameObject,call_back)
end

function LimitTowerItem:SetData(data)
    self.data = data
    self.floor = self.data.floor
    self.floorTex.text = "d"..self.floor.."c"
    self.dungenId = self.data.dunge
    self.assist = self.data.assist
    self.power.text = self.data.power
    SetVisible(self.flag,self.assist == 1)
    local dungeCfg = Config.db_dunge[self.dungenId]
    if  dungeCfg then
        local tab = String2Table(dungeCfg.reward_show)
        self:CreateIcon(tab)
    end
   -- self:UpdateCrossInfo()
end
--0已通关  1 当前层数  2 未解锁
function LimitTowerItem:UpdateCrossInfo()
    self.crossState = self.model:GetCrossState(self.floor)
    if self.crossState  == 0 then
        lua_resMgr:SetImageTexture(self, self.crossImg, "common_image", "img_have_clear_2", false)
        SetVisible(self.crossImg,true)
        SetVisible(self.mask,false)
    elseif self.crossState  == 1 then
        SetVisible(self.crossImg,false)
        SetVisible(self.mask,false)
    else

        --ShaderManager:GetInstance():SetImageGray(self.bg)
        --ShaderManager:GetInstance():SetImageGray(self.flag)
        --ShaderManager:GetInstance():SetImageGray(self.floorTex)
        --ShaderManager:GetInstance():SetImageGray(self.crossImg)

        lua_resMgr:SetImageTexture(self, self.crossImg, "common_image", "img_have_notReached2", false)
        SetVisible(self.crossImg,true)
        SetVisible(self.mask,true)
    end
end

function LimitTowerItem:SetSelect(isShow)
    SetVisible(self.select,isShow)
end

function LimitTowerItem:CreateIcon(tab)
    for i = 1, #tab do
        local param = {}
        param["item_id"] = tab[i][1]
        param["num"] = tab[i][2]
        param["model"] = BagModel
        param["can_click"] = true
        param["show_num"] = true
        if self.itemicon[i] == nil then
            self.itemicon[i] = GoodsIconSettorTwo(self.iconParent)
        end
        self.itemicon[i]:SetIcon(param)
    end
end