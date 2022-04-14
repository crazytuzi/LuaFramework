---
--- Created by  Administrator
--- DateTime: 2019/5/8 15:33
---
ArenaBuyPanel = ArenaBuyPanel or class("ArenaBuyPanel", WindowPanel)
local this = ArenaBuyPanel

function ArenaBuyPanel:ctor(parent_node, parent_panel)
    self.abName = "arena";
    self.image_ab = "arena_image";
    self.assetName = "ArenaBuyPanel"
    self.layer = "UI"
    self.events = {}
    self.use_background = true
    self.click_bg_close = true
    self.panel_type = 4
    self.curTimes = 1
    self.model = ArenaModel:GetInstance()
   -- ArenaBuyPanel.super.Load(self)
end

function ArenaBuyPanel:Open(buy_times)
    self.buy_times = buy_times
    ArenaBuyPanel.super.Open(self)
end


function ArenaBuyPanel:dctor()
    self.model:RemoveTabListener(self.events)
end

function ArenaBuyPanel:LoadCallBack()
    self.nodes = {
        "timesObj/reduceBtn","rightObj/nextVip","rightObj/nextDes","leftObj/curVip","des","timesObj/times",
        "buyBtn","leftObj/curDes","timesObj/addBtn","timesObj/maxBtn","arrow","rightObj","leftObj","buyBtn/Text",
        "icon","price",
    }
    self:GetChildren(self.nodes)
    self.btnTxt = GetText(self.Text)
    self.des = GetText(self.des)
    self.curDes = GetText(self.curDes)
    self.nextDes = GetText(self.nextDes)
    self.curVip = GetText(self.curVip)
    self.nextVip = GetText(self.nextVip)
    self.times = GetText(self.times)
    self.reduceBtnImg = GetImage(self.reduceBtn)
    self.icon = GetImage(self.icon)
    self.price = GetText(self.price)
    ShaderManager.GetInstance():SetImageGray(self.reduceBtnImg)
    self.addBtnImg = GetImage(self.addBtn)
    self:SetTileTextImage("arena_image", "arena_title2")
    self:InitUI()
    self:AddEvent()

    if self.rTimes <= 1 then
        ShaderManager.GetInstance():SetImageGray(self.addBtnImg)
        ShaderManager.GetInstance():SetImageGray(self.reduceBtnImg)
        return
    end

end

function ArenaBuyPanel:InitUI()
   local vipLv = RoleInfoModel:GetInstance():GetMainRoleVipLevel()
   -- local cfg = Config.db_vip_rights[30]
   local times =  self.model:GetVipTimes()
    self.rTimes = times - self.buy_times
    local color = "27C31F"
    if self.rTimes <= 0 then
        color  = "FF0000"
    end
    if vipLv == 12 then
        SetVisible(self.rightObj,false)
        SetVisible(self.arrow,false)
        SetLocalPosition(self.leftObj,120,0,0)
    else
        SetVisible(self.rightObj,true)
        local nextTimes = self.model:GetNextVipTimes()


        self.nextDes.text = string.format("Daily Quota: <color=#27C31F>%s</color>",nextTimes)
        self.nextVip.text = RoleInfoModel:GetInstance():GetMainRoleVipLevel() + 1
    end
    local tab = String2Table(Config.db_dunge[30371].enter_buy)
    local id = tab[1]
    self.priceNum = tab[2]
    --self.des.text = string.format("每次购买<color=#27C31F>%s</color>钻石(您今日还可以购买<color=#%s>%s</color>次)",num,color,self.rTimes)
    self.des.text = string.format("Daily Left: <color=#%s>%s</color> (Upgrade your VIP for more purchases)",color,self.rTimes)
    self.curDes.text = string.format("Daily Quota: <color=#%s>%s/%s</color>",color,self.rTimes,times)
    self.curVip.text = RoleInfoModel:GetInstance():GetMainRoleVipLevel()
    GoodIconUtil:CreateIcon(self, self.icon, id, true)
    self:UpdaterPrice()
    if self.rTimes > 0 then
        self.btnTxt.text = "Buy"
    else
        self.btnTxt.text = "Upgrade VIP"
    end
end

function ArenaBuyPanel:SetTimes(num)
    self.times.text = num
end

function ArenaBuyPanel:UpdaterPrice()
    self.price.text = self.priceNum  * self.curTimes
end

function ArenaBuyPanel:AddEvent()

    local function call_back()  --加
        --if self.rTimes <= 1 then
        --  --  ShaderManager.GetInstance():SetImageGray(self.addBtnImg)
        --    return
        --end
        --
        self.curTimes = self.curTimes + 1
        if self.curTimes >= self.rTimes then
            self.curTimes = self.rTimes
            ShaderManager.GetInstance():SetImageGray(self.addBtnImg)
        else
            ShaderManager.GetInstance():SetImageNormal(self.reduceBtnImg)
        end
        self.times.text = self.curTimes
        self:UpdaterPrice()
    end
    AddClickEvent(self.addBtn.gameObject,call_back)

    local function call_back()  --减
        --if self.rTimes <= 1 then
        --  --  ShaderManager.GetInstance():SetImageGray(self.reduceBtnImg)
        --    return
        --end
        self.curTimes = self.curTimes - 1
        if self.curTimes <= 1 then
            self.curTimes = 1
            ShaderManager.GetInstance():SetImageGray(self.reduceBtnImg)
        else
            ShaderManager.GetInstance():SetImageNormal(self.addBtnImg)
        end
        self.times.text = self.curTimes
        self:UpdaterPrice()
    end
    AddClickEvent(self.reduceBtn.gameObject,call_back)

    local function call_back()  --最大
        --if self.rTimes <= 1 then
        --    --  ShaderManager.GetInstance():SetImageGray(self.reduceBtnImg)
        --    return
        --end
        self.curTimes = self.rTimes
        self.times.text = self.curTimes
        ShaderManager.GetInstance():SetImageGray(self.addBtnImg)
        ShaderManager.GetInstance():SetImageNormal(self.reduceBtnImg)
        self:UpdaterPrice()
    end
    AddClickEvent(self.maxBtn.gameObject,call_back)


    local function call_back()
        if self.rTimes > 0 then
            ArenaController:GetInstance():RequstAddChallenge(tonumber(self.times.text))
        else
            lua_panelMgr:GetPanelOrCreate(VipPanel):Open();
            self:Close()
        end

    end
    AddClickEvent(self.buyBtn.gameObject,call_back)

    self.events[#self.events + 1] = self.model:AddListener(ArenaEvent.ArenaAddChallenge, handler(self, self.ArenaAddChallenge))
end

function ArenaBuyPanel:ArenaAddChallenge(data)
    print2("返回购买次数")
    print2(data.challenge)
    local times =  self.model:GetVipTimes()
    self.rTimes = self.rTimes - data.buy_times
    local color = "27C31F"
    if self.rTimes <= 0 then
        color  = "FF0000"
    end
    self.des.text = string.format("Daily Left: <color=#%s>%s</color> (Upgrade your VIP for more purchases)",color,self.rTimes)
    self.curDes.text = string.format("Daily Quota: <color=#%s>%s/%s</color>",color,self.rTimes,times)
    if self.rTimes > 0 then
        self.btnTxt.text = "Buy"
    else
        self.btnTxt.text = "Upgrade VIP"
    end
    ArenaController:GetInstance():RequstArenaInfo()  -- 用于主界面刷新不及时
end

