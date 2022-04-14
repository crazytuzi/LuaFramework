---
--- Created by  Administrator
--- DateTime: 2020/4/14 14:39
---
RichManItem = RichManItem or class("RichManItem", BaseCloneItem)
local this = RichManItem

function RichManItem:ctor(obj, parent_node, parent_panel)
    RichManItem.super.Load(self)
    self.events = {}
end

function RichManItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    if self.action then
        cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.itemImg.transform)
        self.action = nil
    end
    if self.eft then
        self.eft:destroy()
    end
    self.eft = nil
end

function RichManItem:LoadCallBack()
    self.nodes = {
        "itemImg","effParent"
    }
    self:GetChildren(self.nodes)
    self.itemImg = GetImage(self.itemImg)
    self:InitUI()
    self:AddEvent()

    self.eft = UIEffect(self.effParent, 45001, false, self.layer)
    self.eft:SetConfig({ is_loop = true })
    self.eft.is_hide_clean = false
    self.eft:SetOrderIndex(423)
end

function RichManItem:InitUI()

end

function RichManItem:AddEvent()
    local function call_back()
        if self.data.type ~= 3 then
            return
        end
        local tab = String2Table(self.data.reward)
        local param = {}
        param["item_id"] = tab[1][3][1][1]
        param["model"] = BagModel.Instance
       -- param["p_item"] = goodsInfo
        local tipView = GoodsTipView(self.itemImg.transform)
        tipView:ShowTip(param)
    end
    AddClickEvent(self.itemImg.gameObject,call_back)

end

function RichManItem:SetData(data,index)
    self.data = data
    self.index = index
    self:UpdateInfo()
end

function RichManItem:UpdateInfo()
    local type = self.data.type
    SetLocalRotation(self.itemImg.transform,0,0,0)
    if type == 8 then
        SetVisible(self.itemImg,false)
        return
    end
    SetVisible(self.effParent.transform,type == 4)
    SetVisible(self.itemImg,true)
    if  type == 7 or type == 6 or type == 4 then

        local function call_back(sp)
            self.itemImg.sprite = sp
            if not self.action then
                self:PlayAni()
            end
        end
        lua_resMgr:SetImageTexture(self,self.itemImg, 'richman_image', "RichMan_type_"..type,false,call_back)
    else
        if type == 3 then
            lua_resMgr:SetImageTexture(self,self.itemImg, 'richman_image', self.data.icon,false)
        else
            if type == 5  then
                if self.data.grid >= 12 and  self.data.grid <= 17 then
                    SetLocalRotation(self.itemImg.transform,0,0,-90)
                elseif self.data.grid >= 18 and  self.data.grid <= 29 then
                    SetLocalRotation(self.itemImg.transform,0,0,180)
                elseif self.data.grid >= 30 and  self.data.grid <= 35  then
                    SetLocalRotation(self.itemImg.transform,0,0,90)
                end
            end
            lua_resMgr:SetImageTexture(self,self.itemImg, 'richman_image', "RichMan_type_"..type,false)
        end


    end
end


function RichManItem:PlayAni()
    self.action = cc.MoveTo(0.5, 0,0,0)
    self.action = cc.Sequence(self.action, cc.MoveTo(1.5, 0,20,0))
    self.action = cc.Repeat(self.action, 4)
    self.action = cc.RepeatForever(self.action)
    cc.ActionManager:GetInstance():addAction(self.action, self.itemImg.transform)
end