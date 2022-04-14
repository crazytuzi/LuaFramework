---
--- Created by  Administrator
--- DateTime: 2020/4/13 16:52
---
RichManPanel = RichManPanel or class("RichManPanel", BasePanel)
local this = RichManPanel

local cTime = 0.32
function RichManPanel:ctor(parent_node, parent_panel)
    self.abName = "richman"
    self.assetName = "RichManPanel"
    self.image_ab = "richman_image";
    self.layer = "UI"

    self.is_show_money = { Constant.GoldType.Coin, Constant.GoldType.BGold, Constant.GoldType.Gold }
    self.events = {}
    self.mEvents = {}
    self.use_background = true
    self.show_sidebar = false
    --self.click_bg_close = true
    self.countTime = 2
    self.sprite_list = {}
    self.items = {}
    self.luckItems ={}
    self.roundItems = {}
    self.rewardItems = {}
    self.aniState = false
    self.num = 5
    self.touziType = 1 --1普通 2遙控

    self.model = RichManModel:GetInstance()
    self.openData = OperateModel:GetInstance():GetAct(self.model.actId)
    self.data = OperateModel:GetInstance():GetActInfo(self.model.actId)
    --local sTime = self.openData.act_stime
    ----local curTime =
    --self.curDay = TimeManager:GetInstance():GetDifDay(os.time(),sTime)

end

function RichManPanel:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    self.model:RemoveTabListener(self.mEvents)
    self.sprite_list = {}

    if self.action then
        cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.sezi)
        self.action = nil
    end
    if self.aniSchedule1 then
        GlobalSchedule.StopFun(self.aniSchedule1);
    end
    self.aniSchedule1 = nil
    --if self.action1 then
    --    cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.sezi)
    --    self.action1 = nil
    --end
    if self.aniSchedule then
        GlobalSchedule.StopFun(self.aniSchedule);
    end
    self.aniSchedule = nil
    if self.role_icon1 then
        self.role_icon1:destroy()
        self.role_icon1 = nil
    end
    if not table.isempty(self.items) then
        for i, v in pairs(self.items) do
            v:destroy()
        end
    end
    self.items = {}
    if not table.isempty(self.luckItems) then
        for i, v in pairs(self.luckItems) do
            v:destroy()
        end
    end
    self.luckItems = {}


    if not table.isempty(self.roundItems) then
        for i, v in pairs(self.roundItems) do
            v:destroy()
        end
    end
    self.roundItems = {}


    if not table.isempty(self.rewardItems) then
        for i, v in pairs(self.rewardItems) do
            v:destroy()
        end
    end
    self.rewardItems = {}

    self.model.isOpenPanel = true

    if self.eft ~= nil then
        self.eft:destroy()
    end

    if self.eft1 ~= nil then
        self.eft1:destroy()
    end

    self:DestroyRed()
end

function RichManPanel:LoadCallBack()
    self.nodes = {
        "closeBtn","yktouziNum","touziNum","btnObj/recharBtn","btnObj/getBtn","btnObj/buyBtn","time",
        "sezi","btnObj/startBtn","luckParent",
        "itemParent/n_30","itemParent/n_23","itemParent/n_18","itemParent/n_2","itemParent/n_12",
        "itemParent/n_32","itemParent/n_11","itemParent/n_3","itemParent/n_29","itemParent/n_33",
        "itemParent/n_25","itemParent/n_1","itemParent/n_5","itemParent/n_4","itemParent/n_6",
        "itemParent/n_26","itemParent/n_36","itemParent/n_17","itemParent/n_20","itemParent/n_9",
        "itemParent/n_28","itemParent/n_22","itemParent/n_14","itemParent/n_10","itemParent/n_16",
        "itemParent/n_27","itemParent/n_7","itemParent/n_21","itemParent/n_13","itemParent/n_8","itemParent/n_19",
        "itemParent/n_35", "itemParent/n_34","itemParent/n_15","itemParent/n_31","itemParent/n_24",
        "RichManItem","RichManLuckItem","RichManRoundItem","ScrollView/Viewport/Content","dimIcon",
        "RichManRecharItem","leftScrollView/Viewport/leftContent","btnObj/lqBtn","btnObj/helpBtn",
        "getNum",
    }
    self:GetChildren(self.nodes)
    self.yktouziNum = GetText(self.yktouziNum)
    self.touziNum = GetText(self.touziNum)
    self.getNum = GetText(self.getNum)
    self.time = GetText(self.time)
    self.sezi = GetImage(self.sezi)
    self.dimIcon = GetImage(self.dimIcon)
    SetVisible(self.sezi,false)
    --self:InitHead()
    for i = 1, 36 do
        self["n_"..i] = GetImage(self["n_"..i])
    end
    self:InitUI()
    self:AddEvent()
    self:LoadSprite()
    --GlobalEvent:Brocast(VipEvent.OpenVipPanel, 2)

    RichManController:GetInstance():RequestRichManInfo()
    self.eft1 = UIEffect(self.startBtn, 10201, false, self.layer)
    self.eft1:SetConfig({ is_loop = true,scale = 1.6 })
    self.eft1.is_hide_clean = false
    self.eft1:SetOrderIndex(423)

    self:RichManCheckRedPoint()

end

function RichManPanel:RichManCheckRedPoint()
    if not self.touziRed then
        self.touziRed = RedDot(self.startBtn, nil, RedDot.RedDotType.Nor)
        self.touziRed:SetPosition(40, 43)
    end
    if not self.bqRed then
        self.bqRed = RedDot(self.getBtn, nil, RedDot.RedDotType.Nor)
        self.bqRed:SetPosition(47, 17)
    end
    if not self.lqRed then
        self.lqRed = RedDot(self.lqBtn, nil, RedDot.RedDotType.Nor)
        self.lqRed:SetPosition(47, 17)
    end
    self.touziRed:SetRedDotParam(self.model.redPoints[1])
    self.bqRed:SetRedDotParam(self.model.redPoints[2])
    self.lqRed:SetRedDotParam(self.model.redPoints[4])
  --  SetVisible(self.eft1.transform,self.model.redPoints[1])
end

function RichManPanel:DestroyRed()
    if self.touziRed then
        self.touziRed:destroy()
        self.touziRed = nil
    end
    if self.bqRed then
        self.bqRed:destroy()
        self.bqRed = nil
    end
    if self.lqRed then
        self.lqRed:destroy()
        self.lqRed = nil
    end
end 


function RichManPanel:InitUI()
    local iconName = Config.db_item[enum.ITEM.ITEM_GOLD].icon
    GoodIconUtil:CreateIcon(self, self.dimIcon, iconName, true)
   -- self:InitLuckReward()
    self:InitActTime()
    self:InitRoundReward()

end

function RichManPanel:InitActTime()
    local stime = self:GetActTime(self.openData.act_stime)
    local etime = self:GetActTime(self.openData.act_etime)
    self.time.text = string.format("Event time: %s~%s",stime,etime)
end

function RichManPanel:InitLuckReward()
    local cfg = Config.db_yunying_richman_luck
    local num = 0
    for i = 1, #cfg do
        if self.model.luckyRound == cfg[i].round and cfg[i].actid == self.model.actId then
            num = num + 1
            local item = self.luckItems[num]
            if not item then
                item = RichManLuckItem(self.RichManLuckItem.gameObject,self.luckParent,"UI")
                self.luckItems[num] = item
            end
            item:SetData(cfg[i])
        end
    end
end

function RichManPanel:InitRoundReward()
    local cfg = Config.db_yunying_richman_round
    local index = 0
    for i = 1, #cfg do
        if self.model.actId == cfg[i].actid then
            index = index + 1
            local item = self.roundItems[index]
            if not item then
                item = RichManRoundItem(self.RichManRoundItem.gameObject,self.Content,"UI")
                self.roundItems[index] = item
            end
            item:SetData(cfg[i])
        end

    end
end

function RichManPanel:UpdateRechargeRewards(tab)
    local rewards = tab
    local lqNum = 0
   -- self.idTabs  = self.idTabs or {}
    for i = 1, #rewards do
        local item = self.rewardItems[i]
        if not item then
            item  =   RichManRecharItem(self.RichManRecharItem.gameObject,self.leftContent,"UI")
            self.rewardItems[i] = item
        else
            item:SetVisible(true)
        end
        item:SetData(rewards[i],self.model.actId+1)
        if rewards[i].state == enum.YY_TASK_STATE.YY_TASK_STATE_REWARD then --已完成
            lqNum = lqNum + 1
        end
    end
    for i = #tab + 1,#self.rewardItems do
        local Item = self.rewardItems[i]
        Item:SetVisible(false)
    end
    local sTime = self.openData.act_stime
    --local curTime =
    self.curDay = TimeManager:GetInstance():GetDifDay(os.time(),sTime)
    local num = self.model:GetTouZiNum(self.curDay + 1)
    local dayNum = lqNum
    self.getNum.text = string.format("Still can claim <color=#3CFF00>%s</color> today",num - dayNum)
end

function RichManPanel:LoadSprite()
    local arr_spirite = {"saizi_1_2","saizi_2_2","saizi_3_2","saizi_4_2",
                         "saizi_5_2","saizi_6_2","saizi_7_2","saizi_8_2","saizi_9_2",
                         "saizi_1","saizi_2","saizi_3","saizi_4","saizi_5","saizi_6"}

    for i=1, #arr_spirite do
        local function call_back(objs)
            self.sprite_list[i] = objs[0]
        end
        lua_resMgr:LoadSprite(self, 'saizi_image', arr_spirite[i], call_back)
    end
end

function RichManPanel:AddEvent()


    local function call_back()
        --lua_panelMgr:GetPanelOrCreate(RichManBuyPanel):Open()
        if not OperateModel:GetInstance():IsActOpenByTime(self.model.actId) then
            Notify.ShowText("Event is over")
            return
        end
            local isCanReward = false
            local tab = {}
            for i = 1, #self.rewardItems do
                if self.rewardItems[i].data.state == enum.YY_TASK_STATE.YY_TASK_STATE_FINISH then
                    isCanReward = true
                    table.insert(tab,self.rewardItems[i].data)

                end
            end
            if not isCanReward then
                Notify.ShowText("No dices can be claimed")
                return
            end

            for i = 1, #tab do
                OperateController:GetInstance():Request1700004(self.model.actId + 1,tab[i].id,tab[i].level)
            end
            --OperateController:GetInstance():Request1700004(self.model.actId self.data.id, self.data.level)
    end
    AddButtonEvent(self.lqBtn.gameObject,call_back)



    local function call_back()
        --lua_panelMgr:GetPanelOrCreate(RichManBuyPanel):Open()
        ShowHelpTip(HelpConfig.richMan.des,true)
    end
    AddButtonEvent(self.helpBtn.gameObject,call_back)


    local function call_back()
        if   self.aniState then
            Notify.ShowText("Rolling, please wait")
            return
        end
        self:Close()
    end
    AddButtonEvent(self.closeBtn.gameObject,call_back)
    local function call_back()
       -- self:UpdateSezi(true)
        GlobalEvent:Brocast(VipEvent.OpenVipPanel, 2)
    end
    AddButtonEvent(self.recharBtn.gameObject,call_back)


    local function call_back()
        if   self.aniState then
            Notify.ShowText("Rolling, please wait")
            return
        end
        if not OperateModel:GetInstance():IsActOpenByTime(self.model.actId) then
            Notify.ShowText("Event is over")
            return
        end
        local type = 1
        local ykTouziNum = BagModel:GetInstance():GetItemNumByItemID(self.model.ykTouzi) or 0
        local touziNum = BagModel:GetInstance():GetItemNumByItemID(self.model.touzi) or 0
        if ykTouziNum == 0 and touziNum == 0 then
            Notify.ShowText("Insufficient items")
            return
        end
        if ykTouziNum > 0 then --遥控骰子逻辑
            --self.touziType = 2
            lua_panelMgr:GetPanelOrCreate(RichManSelectPanel):Open()
            return
        end
        if touziNum > 0 then
            self.touziType = 1
            RichManController:GetInstance():RequestRichManDiceInfo(3)
        else
            Notify.ShowText("Insufficient items")
        end

    end
    AddButtonEvent(self.startBtn.gameObject,call_back)


    
    local function call_back()
        --local sTime = self.openData.act_stime
        ----local curTime =
        --local day = TimeManager:GetInstance():GetDifDay(os.time(),sTime)
        --if day == 0 then
        --    return
        --end
        --logError(day)
        if not OperateModel:GetInstance():IsActOpenByTime(self.model.actId) then
            Notify.ShowText("Event is over")
            return
        end
        if not self.model.isOpenPanel then
            self.model.isOpenPanel = true
            --if self.bqRed then
            --    self.bqRed:SetRedDotParam(false)
            --end
            self.model:CheckRedPoint()
        end
        local sTime = self.openData.act_stime
        --local curTime =
        self.curDay = TimeManager:GetInstance():GetDifDay(os.time(),sTime)
        if   self.curDay == 0 then
            Notify.ShowText("The first day of the event, can't re-sign in")
            return
        end
        
        --self.model.diceMend + 1
        local needNum = self.model:GetNeedMendNum()
        logError("需要补签的数量：",needNum)
        if needNum > 0 then
            local price = self.model:GetTouZiPrice(self.model.diceMend + 1)
            local str = string.format("Cost <color=#0DAB18>%s diamonds</color> to re-sign in 1 dice",price)
            local function call_back()
                if  RoleInfoModel:GetInstance():CheckGold(price) then
                    RichManController:GetInstance():RequestRichManMendInfo()
                end
            end
            Dialog.ShowTwo("Tip", str, "Confirm", call_back, nil, "Cancel", nil, nil)
        else
            Notify.ShowText("No dices available")
        end
        
        --local num = 0
        --local dayNum = 0
        --for i = 1, self.curDay do
        --    num = num + self.model:GetTouZiNum(i)
        --    local index = self.model.diceGain[i] or  0
        --    dayNum = dayNum + (self.model:GetTouZiNum(i) - index )
        --end
        --if dayNum == 0 then
        --    Notify.ShowText("当前没有可以补签的骰子")
        --    return
        --end
        --local price = self.model:GetTouZiPrice(dayNum)
        --local str = string.format("是否花费<color=#0DAB18>%s钻石</color>补签%s枚骰子。",price, dayNum )
        --local function call_back()
        --    RichManController:GetInstance():RequestRichManMendInfo()
        --end
       -- Dialog.ShowTwo("提示", str, "确定", call_back, nil, "取消", nil, nil)

    end
    AddButtonEvent(self.getBtn.gameObject,call_back)




    local function call_back(type)
        self.touziType = type
        if self.touziType == 2 then
            lua_panelMgr:GetPanelOrCreate(RichManPointPanel):Open()
        else
            local touziNum = BagModel:GetInstance():GetItemNumByItemID(self.model.touzi) or 0
            if touziNum <= 0 then
                Notify.ShowText("Insufficient items")
                return
            end
            RichManController:GetInstance():RequestRichManDiceInfo(3)
        end
    end
    self.mEvents[#self.mEvents + 1] = self.model:AddListener(RichManEvent.RichManTouZiSelect,call_back)




    
    local function call_back(point)
        RichManController:GetInstance():RequestRichManDiceInfo(3,point)
    end
    self.mEvents[#self.mEvents + 1] = self.model:AddListener(RichManEvent.RichManTouZiClick,call_back)
    self.mEvents[#self.mEvents + 1] = self.model:AddListener(RichManEvent.RichManInfo,handler(self,self.RichManInfo))
    self.mEvents[#self.mEvents + 1] = self.model:AddListener(RichManEvent.RichManFetchInfo,handler(self,self.RichManFetchInfo))
    self.mEvents[#self.mEvents + 1] = self.model:AddListener(RichManEvent.RichManDiceInfo,handler(self,self.RichManDiceInfo))
    self.mEvents[#self.mEvents + 1] = self.model:AddListener(RichManEvent.RichManReadyDiceInfo,handler(self,self.RichManReadyDiceInfo))
    self.mEvents[#self.mEvents + 1] = self.model:AddListener(RichManEvent.RichManReadyDiceLuckInfo,handler(self,self.RichManReadyDiceLuckInfo))
    self.mEvents[#self.mEvents + 1] = self.model:AddListener(RichManEvent.RichManMendInfo,handler(self,self.RichManMendInfo))
    self.mEvents[#self.mEvents + 1] = self.model:AddListener(RichManEvent.RichManCheckRedPoint,handler(self,self.RichManCheckRedPoint))

    local function call_back(data)
        if data.act_id == self.model.actId + 1 then
            Notify.ShowText("Claimed")
            self.data = OperateModel:GetInstance():GetActInfo(self.model.actId + 1)
            self:UpdateRechargeRewards(self.data.tasks)
            self:UpdateTouziNums()
        end
    end
    self.events[#self.events + 1] = GlobalEvent:AddListener(OperateEvent.SUCCESS_GET_REWARD, call_back)

    local function call_back(data)
        if data.id == self.model.actId + 1 then
            self:UpdateRechargeRewards(data.tasks)
        end
    end
    self.events[#self.events + 1] = GlobalEvent:AddListener(OperateEvent.DLIVER_YY_INFO, call_back)

    local function call_back()
        self.data = OperateModel:GetInstance():GetActInfo(self.model.actId + 1)
        self:UpdateRechargeRewards(self.data.tasks)
    end
    self.events[#self.events + 1] = GlobalEvent:AddListener(EventName.PaySucc, call_back)


    local function call_back()
        self:UpdateTouziNums()
       -- self:RichManCheckRedPoint()
    end

    self.events[#self.events + 1] =  GlobalEvent:AddListener(BagEvent.UpdateGoods, call_back)
end


function RichManPanel:UpdateSezi(is_animation)
    if is_animation then
        self:PlaySeziAnimate(self.num)
    else
        local num = (self.num == 0 and 6 or self.num)
        local res = string.format("saizi_%s", num)
        lua_resMgr:SetImageTexture(self,self.sezi, 'saizi_image', res)
    end
end

function RichManPanel:PlaySeziAnimate(num)
    local time = 1
    local last_sprite_index = num+9
    local delayperunit = 0.1
    local loop_count = 9
    local function start_action()
        SetVisible(self.sezi,true)
        self.aniState = true
        if self.action then
            cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.sezi)
            self.action = nil
        end
        local action = cc.Animate(self.sprite_list, time, self.sezi, last_sprite_index, delayperunit, loop_count)
        cc.ActionManager:GetInstance():addAction(action, self.sezi)
        self.action = action
    end

    start_action()
    local function call_back()
        local res = string.format("saizi_%s", num)
        lua_resMgr:SetImageTexture(self,self.sezi, 'saizi_image', res)
       -- SetVisible(self.sezi,false)
        self:PlayMoveAni(self.num)

    end
    GlobalSchedule:StartOnce(call_back, 1.1)
end

function RichManPanel:UpdateHead(parent)
    local param = {}
    local function uploading_cb()
        --  logError("回调")
    end
    param["is_squared"] = true
    --param["is_hide_frame"] = true
    param["size"] = 70
    param["uploading_cb"] = uploading_cb
    param["role_data"] = RoleInfoModel.GetInstance():GetMainRoleData()
   -- param["is_can_click"] = true
    --local function Click_fun()
    --    local panel = lua_panelMgr:GetPanelOrCreate(RoleMenuPanel, self.roleIconParent)
    --    panel:Open(roleData.role)
    --end
    --param["click_fun"] = Click_fun
    if not self.role_icon1  then
        self.role_icon1 = RoleIcon(parent)
    else
        self.role_icon1.transform:SetParent(parent)
        SetLocalPosition(self.role_icon1.transform,0,0,0)
    end
    self.role_icon1:SetData(param)

    --if self.eft ~= nil then
    --    self.eft:destroy()
    --end
    if not self.eft then
        self.eft = UIEffect(parent, 45001, false, self.layer)
        self.eft:SetConfig({ is_loop = true })
        self.eft.is_hide_clean = false
        self.eft:SetOrderIndex(423)
    else
        self.eft.transform:SetParent(parent)
        SetLocalPosition(self.eft.transform,0,0,0)
    end
end


function RichManPanel:InitGridInfo(tab)
    local num = 0
    for i = 1, #tab do
       -- if tab[i].type~= 8 then
        --    num = num + 1
            local item = self.items[i]
            if not item then
                item = RichManItem(self.RichManItem.gameObject,self["n_"..i].transform,"UI")
                self.items[i] = item
            else
                item:SetVisible(true)
            end
            item:SetData(tab[i],i)
        if tab[i].type == 4 then
            lua_resMgr:SetImageTexture(self,self["n_"..i], 'richman_image', "RichMan_type_4_1",false)
        end
      --  end
    end

end

function RichManPanel:UpdateTouziNums()
    --BagModel:GetInstance():GetItemNumByItemID(self.model.ykTouzi) or 0
    self.yktouziNum.text = BagModel:GetInstance():GetItemNumByItemID(self.model.ykTouzi) or 0
    self.touziNum.text = BagModel:GetInstance():GetItemNumByItemID(self.model.touzi) or 0
end


function RichManPanel:UpdateUIInfo()
    local round = self.model.curRound
    local tab = self.model:GetGridInfo(round)
    self:InitGridInfo(tab)
    self:UpdateHead(self["n_"..self.model.curGrid].transform)
    self:UpdateTouziNums()
end

function RichManPanel:PlayMoveAni(point)
    self.targePoint = self.model.curGrid + point
    if self.targePoint > 36 then
        self.targePoint = 36
    end
    --self.countTime = point
    self.curPoint = self.model.curGrid
    if self.aniSchedule then
        GlobalSchedule.StopFun(self.aniSchedule);
    end
    self.aniSchedule = GlobalSchedule.StartFun(handler(self,self.StartAni), cTime, -1);
end

function RichManPanel:StartAni()
   -- logError(targePoint)
    self.curPoint = self.curPoint + 1
    if self.curPoint > self.targePoint then
        if self.aniSchedule then
            GlobalSchedule.StopFun(self.aniSchedule);
        end
        self.aniState = false
        --self.targePoint
        local key = self.model.actId.."@"..self.model.curRound.."@"..self.targePoint
        local cfg = Config.db_yunying_richman[key]
        if cfg and cfg.actid == self.model.actId and cfg.type == 5 then
            self.aniState = true
            local index = tonumber(cfg.reward)
            self.curPoint = self.targePoint
            self.targePoint = self.targePoint - index
           -- self.curPoint = self.model.curGrid
            if self.aniSchedule1 then
                GlobalSchedule.StopFun(self.aniSchedule1);
            end
            self.aniSchedule1 = GlobalSchedule.StartFun(handler(self,self.StartAni2,index), cTime, -1);
        end

        if self.targePoint == 36 then
            if self.role_icon1 then
                self.role_icon1.transform:SetParent(self["n_"..1].transform)
                SetLocalPosition(self.role_icon1.transform,0,0,0)
            end

            if self.eft then
                self.eft.transform:SetParent(self["n_"..1].transform)
                SetLocalPosition(self.eft.transform,0,0,0)
            end
        end
        

        SetVisible(self.sezi,false)
        if self.touziType == 1 then
            RichManController:GetInstance():RequestRichManDiceInfo(1)
        else
            RichManController:GetInstance():RequestRichManDiceInfo(2,self.ykPoint)
        end
        return
    end
    if self.role_icon1 then
        self.role_icon1.transform:SetParent(self["n_"..self.curPoint].transform)
        SetLocalPosition(self.role_icon1.transform,0,0,0)
    end

    if self.eft then
        self.eft.transform:SetParent(self["n_"..self.curPoint].transform)
        SetLocalPosition(self.eft.transform,0,0,0)
    end
end

function RichManPanel:StartAni2(index)
    self.curPoint = self.curPoint - 1
    if   self.curPoint < self.targePoint then
        if self.aniSchedule1 then
            GlobalSchedule.StopFun(self.aniSchedule1);
        end
        self.aniState = false
        return
    end

    if self.role_icon1 then
        self.role_icon1.transform:SetParent(self["n_"..self.curPoint].transform)
        SetLocalPosition(self.role_icon1.transform,0,0,0)
    end

    if self.eft then
        self.eft.transform:SetParent(self["n_"..self.curPoint].transform)
        SetLocalPosition(self.eft.transform,0,0,0)
    end
end


function RichManPanel:UpdateLuckInfo(data)
    local tab = data.lucky_fetch
    local idTab = {}
    if not table.isempty(tab) then
        for i = 1, #tab do
            local id = tab[i]
            idTab[id] = true
        end
    end
    for i, v in pairs(self.luckItems) do
        if idTab[v.data.id] then
            v:ShowEff(true)
        else
            v:ShowEff(false)
        end
    end
end

function RichManPanel:UpdateRoundInfo(data)
    local tab = data.round_fetch
    local round = data.curr_round
    local idTab = {}
    if not table.isempty(tab) then
        for i = 1, #tab do
            local id = tab[i]
            idTab[id] = true
        end
    end
    for i, v in pairs(self.roundItems) do
        if round <= v.data.round then
            v:SetRewardInfo(2)  --未达成
        else
            if idTab[v.data.round] then
                v:SetRewardInfo(3) --已领取
            else
                v:SetRewardInfo(1) --可领取
            end
        end
    end

end



function RichManPanel:RichManInfo(data)
  --  logError(Table2String(data))

    OperateController:GetInstance():Request1700006(self.model.actId + 1)
   -- logError("信息")
    self:UpdateUIInfo()
    self:InitLuckReward()
    self:UpdateLuckInfo(data)
    self:UpdateRoundInfo(data)
   -- self:UpdateRechargeRewards(self.data.tasks)


end

function RichManPanel:RichManDiceInfo(data)
    self:UpdateTouziNums()
end

function RichManPanel:RichManReadyDiceInfo(data)
    local point = data.point
   -- logError("--ready",point)
    --self:PlayMoveAni(point)
    self.num = point
    self:UpdateSezi(true)
end

function RichManPanel:RichManReadyDiceLuckInfo(data)
    local reward = data.reward
    local itemID = 0
    for id, v in pairs(reward) do
        itemID = id
    end
   -- logError("幸运卡")
   -- logError(Table2String(reward))
    for i, v in pairs(self.luckItems) do
        if v.itemId ==  itemID then
            --self.curLuckItem = v
            v:ShowEff(true)
        end
    end
end

function RichManPanel:RichManFetchInfo(data)

    for i, v in pairs(self.roundItems) do
        if v.data.round ==  data.round then
            v:SetRewardInfo(3)
        end
    end
end

function RichManPanel:RichManMendInfo(data)
    
end

function RichManPanel:GetActTime(time)
    local timeTab = TimeManager:GetTimeDate(time)
    local timestr = "";
    if timeTab.month then
        timestr = timestr .. string.format("%02d", timeTab.month) .. "Month";
    end
    if timeTab.day then
        timestr = timestr .. string.format("%d", timeTab.day) .. "Day ";
    end
    if timeTab.hour then
        timestr = timestr .. string.format("%02d", timeTab.hour) .. ":";
    end
    if timeTab.min then
        timestr = timestr .. string.format("%02d", timeTab.min) .. "";
    end
    return timestr
end
