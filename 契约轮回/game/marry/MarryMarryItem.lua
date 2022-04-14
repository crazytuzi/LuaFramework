---
--- Created by  Administrator
--- DateTime: 2019/6/10 11:52
---
MarryMarryItem = MarryMarryItem or class("MarryMarryItem", BaseCloneItem)
local this = MarryMarryItem

function MarryMarryItem:ctor(obj, parent_node, parent_panel)
    MarryMarryItem.super.Load(self)
    self.events = {}
    self.itemicon = nil
    self.model = MarryModel:GetInstance()
    self.role =  RoleInfoModel.GetInstance():GetMainRoleData()
end

function MarryMarryItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    if self.itemicon then
        self.itemicon:destroy()
        self.itemicon = nil
    end
    if self.red then
        self.red:destroy()
        self.red = nil
    end
end

function MarryMarryItem:LoadCallBack()
    self.nodes = {
        "title/bg/title","des","btn","iconParent","showImg","lastObj",
        "openTips","line","select","desPro"
    }
    self:GetChildren(self.nodes)
    self.title = GetText(self.title)
    self.des = GetText(self.des)
    self.desPro = GetText(self.desPro)
    --self.btnTex = GetText(self.btnTex)
    self.btnImg = GetImage(self.btn)
    self.showImg = GetImage(self.showImg)
    self:InitUI()
    self:AddEvent()
    self.red = RedDot(self.btn, nil, RedDot.RedDotType.Nor)
    self.red:SetPosition(72, 20)

end

function MarryMarryItem:InitUI()

end

function MarryMarryItem:AddEvent()
    local function  call_back()
        if   self.state == 3  then
            Notify.ShowText("Rewards have been claimed")
        elseif   self.state == 2 then --已完成 可以领奖
            MarryController:GetInstance():RequsetMarriageStepReward(self.data.id)
        elseif self.state == 1  then --立即前往
            if self.data.id == 1 then  --前往交友
                self.model:Brocast(MarryEvent.ClickMarryPageItem,1)
            elseif self.data.id == 2 then --送花界面
                GlobalEvent:Brocast(FriendEvent.OpenSendGiftPanel)
            else --寻路到NPC
                local cfg = String2Table(Config.db_marriage["level"].val)
                local nLv = cfg[1]
                if self.role.level < nLv then
                    Notify.ShowText(nLv.."You can make proposal at Lv.X")
                    return
                end
                self.model:GoNpc()
                local  panel = lua_panelMgr:GetPanel(MarryPanel)
                if panel then
                    panel:Close()
                end
            end
        end
    end
    AddClickEvent(self.btn.gameObject,call_back)
end

function MarryMarryItem:SetData(data)
    self.data = data
    self:SetInfo()
end

function MarryMarryItem:SetInfo()
    
    if self.data.id == 1 then

    elseif self.data.id == 2 then
        SetVisible(self.line,true)
    else
        SetVisible(self.openTips,true)
    end
   -- self:SetDes(1)
    self.title.text = string.format("Step %s: %s",self.data.id,self.data.step)
    lua_resMgr:SetImageTexture(self,self.showImg, 'marry_image', "marry_show"..self.data.id, false)
    self:SetBtnState()
    self:CreateIcon()
end

function MarryMarryItem:SetBtnState()
    self.state = self.model:GetThreeActState(self.data.id)
    SetVisible(self.select,self.model:GetCurThree() == self.data.id )

    if   self.state == 1 then --未完成
       -- self.btnTex.text = "立即前往"
        SetVisible(self.btn,true)
        SetVisible(self.lastObj,false)
       -- SetVisible(self.select,true)
        self:SetDes(1)
        lua_resMgr:SetImageTexture(self,self.btnImg, 'marry_image', "marry_goBtn", true)
       -- ShaderManager.GetInstance():SetImageNormal(self.btnImg)
        self.red:SetRedDotParam(false)
    elseif   self.state == 2 then -- 已完成
        --self.btnTex.text = "领奖"
        SetVisible(self.btn,true)
        SetVisible(self.lastObj,false)
       -- SetVisible(self.select,false)
        self:SetDes(2)
        self.red:SetRedDotParam(true)
        lua_resMgr:SetImageTexture(self,self.btnImg, 'marry_image', "marry_lqbtn", true)
       -- ShaderManager.GetInstance():SetImageNormal(self.btnImg)
    elseif   self.state == 3 then --已领奖
       -- self.btnTex.text = "已完成"
        SetVisible(self.btn,true)
        SetVisible(self.lastObj,false)
     --   SetVisible(self.select,false)
       -- ShaderManager.GetInstance():SetImageGray(self.btnImg)
        self.red:SetRedDotParam(false)
        lua_resMgr:SetImageTexture(self,self.btnImg, 'marry_image', "marry_wcBtn", true)
        self:SetDes(2)
    elseif   self.state == 4 then
        SetVisible(self.btn,false)
        SetVisible(self.lastObj,true)
      --  SetVisible(self.select,false)
        self:SetDes(1)
        self.red:SetRedDotParam(false)
    end
end

function MarryMarryItem:CreateIcon()
    local  tab = String2Table(self.data.reward)
    local id = tab[1][1]
    local num = tab[1][2]
    if self.itemicon then
        self.itemicon:destroy()
        self.itemicon = nil
    end
    if self.itemicon == nil then
        self.itemicon = GoodsIconSettorTwo(self.iconParent)
    end
    local param = {}
    param["model"] = self.model
    param["item_id"] = id
    param["num"] = num
    param["can_click"] = true
    self.itemicon:SetIcon(param)
end

function MarryMarryItem:SetDes(state)
    if state == 1 then
        if self.data.id == 1 then
            self.des.text ="Add a friend"
            self.desPro.text = "<color=#C32B2B>(0/1)</color>"
            SetVisible(self.desPro,true)
        elseif self.data.id == 2 then
            self.des.text ="Send gift once"
            self.desPro.text = "<color=#C32B2B>(0/1)</color>"
            SetVisible(self.desPro,true)
        else
            self.des.text ="Proposal with token once"
            SetVisible(self.desPro,false)
        end
    else
        if self.data.id == 1 then
            self.des.text ="Add a friend"
            self.desPro.text = "<color=#08ac10>(1/1)</color>"
            SetVisible(self.desPro,true)
        elseif self.data.id == 2 then
            self.des.text ="Send gift once"
            self.desPro.text = "<color=#08ac10>(1/1)</color>"
            SetVisible(self.desPro,true)
        else
            self.des.text ="Proposal with token once"
            SetVisible(self.desPro,false)
        end
    end
end