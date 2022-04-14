FactionEscortPanel = FactionEscortPanel or class("FactionEscortPanel", WindowPanel)
local FactionEscortPanel = FactionEscortPanel

function FactionEscortPanel:ctor()
    self.abName = "factionEscort"
    self.assetName = "FactionEscortPanel"
    self.layer = "UI"

    self.events = {}
    self.use_background = true
    self.show_sidebar = false
    self.panel_type = 2
    self.rTime = 0
    self.isModdle = nil   -- 是否是中间使者
    self.isAuto = false
    self.items = {}
    self.showItem = {}

    self.isJump = false
    self.model = FactionEscortModel:GetInstance()
    self.role = RoleInfoModel.GetInstance():GetMainRoleData()
    --self.model.isEscorting
end

function FactionEscortPanel:dctor()
    GlobalEvent.RemoveTabEventListener(self.events)
    for i, v in pairs(self.items) do
        v:destroy()
    end
    if self.showItem then
        for i, v in pairs(self.showItem) do
            v:destroy()
        end
    end

    if self.monster then
        self.monster:destroy();
    end
    if self.refreshSchedule then
        GlobalSchedule:Stop(self.refreshSchedule)
        self.refreshSchedule = nil
    end

    if self.escortTimeDown then
        GlobalSchedule:Stop(self.escortTimeDown)
        self.escortTimeDown = nil
    end
	
	if self.useItem then
		self.useItem:destroy()
	end

    if self.camera_component then
        self.camera_component.targetTexture = nil
    end
    if self.rawImage then
        self.rawImage.texture = nil
    end
    if self.render_texture then
        ReleseRenderTexture(self.render_texture)
        self.render_texture = nil
    end

   -- self.model.itemQua = nil
end

function FactionEscortPanel:CloseCallBack()
    if self.model.isEscorting then
        local db = Config.db_escort_road
        local npcDB = Config.db_npc
        local main_role = SceneManager:GetInstance():GetMainRole()
        local start_pos = main_role:GetPosition()
       -- local sceneID = npcDB[start].scene
        if self.model.progress == 0 then  --未到中间使者
            local second = db[1].second
            local sceneId = npcDB[second].scene
            local endPos =  SceneConfigManager:GetInstance():GetNpcPosition(sceneId,second)
            function callback()
                local npc_object = SceneManager:GetInstance():GetObject(second)
                if npc_object then
                    npc_object:OnClick()
                end
            end
            OperationManager:GetInstance():TryMoveToPosition(sceneId,start_pos,endPos,callback)
        else
            local endId = db[1].end_npc
            local sceneId = npcDB[endId].scene
            local endPos =  SceneConfigManager:GetInstance():GetNpcPosition(sceneId,endId)
            function callback()
                local npc_object = SceneManager:GetInstance():GetObject(endId)
                if npc_object then
                    npc_object:OnClick()
                end
            end
            OperationManager:GetInstance():TryMoveToPosition(sceneId,start_pos,endPos,callback)
        end
    end
end

function FactionEscortPanel:Open()
    OperationManager:GetInstance():StopAStarMove()
    FactionEscortPanel.super.Open(self)
end

function FactionEscortPanel:LoadCallBack()
    self.nodes =
    {
        "startEsc/Pathfind","helpBtn","startEsc","startEsc/times","UnEsc/goBtn","UnEsc/RefBtn","FactionEscortItem","itemContent","UnEsc","UnEsc/refreshTimes","UnEsc/todayTimes",
        "UnEsc/buyBox/buyBoxTex","UnEsc/buyBox","UnEsc/lvBox","UnEsc/lvBox/lvBoxTex","bossCon","startEsc/slider/slider","doubleTime/doubleTitle","doubleTime/doubleTimeTex",
        "awards/awardsContent","startEsc/iconParent/icon2","startEsc/iconParent/icon1","UnEsc/useItems/iocnParent","UnEsc/useItems/useItemsTex","UnEsc/useItems",
        "bossCon/Camera",
    }
    self:GetChildren(self.nodes)
    SetLocalPosition(self.transform, 0, 0, 0)
    self.times = GetText(self.times)
    self.refreshTimes = GetText(self.refreshTimes)
    self.todayTimes = GetText(self.todayTimes)
    self.buyBox = GetToggle(self.buyBox)
    self.lvBox = GetToggle(self.lvBox)
    self.buyBoxTex = GetText(self.buyBoxTex)
    self.lvBoxTex = GetText(self.lvBoxTex)
    self.mSlider = GetImage(self.slider)
    self.doubleTimeTex = GetText(self.doubleTimeTex)
    self.icon1 = GetImage(self.icon1)
    self.icon2 = GetImage(self.icon2)
    self.useItemsTex = GetText(self.useItemsTex)

    self.rawImage = self.bossCon:GetComponent("RawImage")
    self.camera_component = self.Camera:GetComponent("Camera")

    self:SetLvBox(false)
    self:SetBuyBox(false)
    self:AddEvent()
    self:InitUI()
   -- if self.model.isEscorting then  --护送进行中
        FactionEscortController:GetInstance():RequestEscortInfo()  --请求护送信息
   -- end
    --print2(self.model.itemQua,"品质")

    if self.model.itemQua == 0 then
        FactionEscortController:GetInstance():RequestRefersh()
    else
        self:UpdateItems()
    end
    self:SetTileTextImage("factionEscort_image", "escort_title");

    --FactionEscortController:GetInstance():RequestEscortInfo()
   -- print2(TimeManager.GetServerTime())
end
function FactionEscortPanel:OpenCallBack()
    local texture = CreateRenderTexture()
    self.camera_component.targetTexture = texture
    self.rawImage.texture = texture
    self.render_texture = texture
end

function FactionEscortPanel:InitUI()
    if self.model.isEscorting then   --护送进行中
        SetVisible(self.UnEsc,false)
        SetVisible(self.startEsc,true)
       -- SetVisible(self.PathfindSelect,false)
        self:SetSdule()
       -- self:SetAuto()
       -- SetVisible(self.goBtn,false)
    else
        SetVisible(self.startEsc,false)
        SetVisible(self.UnEsc,true)
        self:SetBuyItems()
        self:SetTimes()
        --self.todayTimes.text = "今天次数："..self.model.escortCount
        --self.refreshTimes.text = "免费刷新次数："..self.model.refreshCount
    end
   -- self:ShowCountDown()
    self:SetDouble()
end

function FactionEscortPanel:SetSdule()
    if self.model.progress == 1 then
        SetSizeDelta(self.slider.transform, 400, 14);
        ShaderManager.GetInstance():SetImageGray(self.icon2)
    elseif self.model.progress == 0 then
        SetSizeDelta(self.slider.transform, 142, 14);
        ShaderManager.GetInstance():SetImageGray(self.icon2)
        ShaderManager.GetInstance():SetImageGray(self.icon1)
    else
        SetSizeDelta(self.slider.transform, 300, 14);
        ShaderManager.GetInstance():SetImageGray(self.icon2)
        ShaderManager.GetInstance():SetImageGray(self.icon1)
    end
end

function FactionEscortPanel:SetDouble()
    local startTime1,startTime2,startTime3,startTime4 = self.model:DoubleStartText()
    local endTime1,endTime2,endTime3,endTime4 = self.model:DoubleEndText()
    self.doubleTimeTex.text  = string.format("%s:%s-%s:%s\n%s:%s-%s:%s",startTime1,startTime2,endTime1,endTime2,startTime3,startTime4,endTime3,endTime4)

    SetVisible(self.doubleTitle,self.model:CheckIsDouble())
end
function FactionEscortPanel:SetBuyItems()
    local level =  self.role.level
    local key = "4".."@"..level
    local proDb = Config.db_escort_product[key]
    local dbStr = Config.db_escort[1].price
    local tab = String2Table(dbStr)
    self.itemId = tab[1][1]
    self.itemNum = tab[1][2]
    if Config.db_item[self.itemId ] ~= nil then
        local str = string.format("<color=#%s>%s</color>", ColorUtil.GetColor(Config.db_item[self.itemId].color), Config.db_item[self.itemId].name)
        self.buyBoxTex.text = "Auto buy"..str
    else
        print2("物品表没有道具")
    end

    if proDb ~= nil then
        self.lvBoxTex.text = "Improve to"..proDb.name
    end
    -- self.buyBoxTex
end


--开始护送倒计时
function FactionEscortPanel:ShowCountDown()
    GlobalSchedule.StartFun(self.StartConutDown,1,-1)
end
function FactionEscortPanel:StartConutDown()

end

function FactionEscortPanel:AddEvent()

    local function call_back()
        --self.isAuto = not self.isAuto
        --SetVisible(self.PathfindSelect,self.isAuto)
        --self:StartAstar(self.isAuto)
       -- Notify.ShowText("开始自动寻路")
        self:Close()
        
    end
    AddClickEvent(self.Pathfind.gameObject,call_back)
    local call_back = function(target, bool)
        self.model.buyBox = bool
    end
    AddValueChange(self.buyBox.gameObject, call_back);

    local call_back = function(target, bool)
        self.model.lvBox = bool
    end
    AddValueChange(self.lvBox.gameObject, call_back);



    function call_back()  --寻求帮助
        lua_panelMgr:GetPanelOrCreate(FactionEscortHelpPanel):Open()
    end
    AddClickEvent(self.helpBtn.gameObject,call_back)
    function call_back() --开始护送

        if not self.model:IsMaxLv() then  --未达到最高级
          --  if self.model.isLong then
                --if not self.model.isDouble  then  --不在双倍时间内
                --    local startTime1,startTime2,startTime3,startTime4 = self.model:DoubleStartText()
                --    local endTime1,endTime2,endTime3,endTime4 = self.model:DoubleEndText()
                --    local message  = string.format("护送双倍时间为%s:%s-%s:%s和%s:%s-%s:%s现在护送无法获得双倍奖励，是否继续。",startTime1,startTime2,endTime1,endTime2,startTime3,startTime4,endTime3,endTime4)
                --    function ok_func()
                --        FactionEscortController:GetInstance():RequestEscortStart()
                --        self.model.isLong = true
                --    end
                --    Dialog.ShowTwo('提示',message,'确定',ok_func,nil,'取消',nil,nil,"今日不再提示",true,false,self.__cname..2)
                --else
                --    --在双倍时间直接出发
                --    FactionEscortController:GetInstance():RequestEscortStart()
                --    self.model.isLong = true
                --end
               -- return
          ---  end
            local message = "Current traveling level is not at the max, aeepect?"
            function ok_func1()
                self.model.isLong = true
                if not self.model:CheckIsDouble()then  --不在双倍时间内
                    local startTime1,startTime2,startTime3,startTime4 = self.model:DoubleStartText()
                    local endTime1,endTime2,endTime3,endTime4 = self.model:DoubleEndText()
                    local message  = string.format("Double Time: %s:%s-%s:%s and %s:%s-%s:%s, there is no double reward time, continue?",startTime1,startTime2,endTime1,endTime2,startTime3,startTime4,endTime3,endTime4)
                    function ok_func2()
                        FactionEscortController:GetInstance():RequestEscortStart()
                        self.model.isLong = true
                    end
                    Dialog.ShowTwo('Tip',message,'Confirm',ok_func2,nil,'Cancel',nil,nil,"Don't notice me again today",true,false,self.__cname..2)
                else
                    --在双倍时间直接出发
                    FactionEscortController:GetInstance():RequestEscortStart()
                    self.model.isLong = true
                end
            end
            Dialog.ShowTwo('Tip',message,'Confirm',ok_func1,nil,'Cancel',nil,nil,"Don't notice me again today",true,false,self.__cname..1)
        else --已达到最高级
            if not self.model:CheckIsDouble()  then  --不在双倍时间内
                local startTime1,startTime2,startTime3,startTime4 = self.model:DoubleStartText()
                local endTime1,endTime2,endTime3,endTime4 = self.model:DoubleEndText()
                local message  = string.format("Double Time: %s:%s-%s:%s and %s:%s-%s:%s, there is no double reward time, continue?",startTime1,startTime2,endTime1,endTime2,startTime3,startTime4,endTime3,endTime4)
                function ok_func()
                    FactionEscortController:GetInstance():RequestEscortStart()
                    self.model.isLong = true
                end
                Dialog.ShowTwo('Tip',message,'Confirm',ok_func,nil,'Cancel',nil,nil,"Don't notice me again today",true,false,self.__cname..2)
            else
                --在双倍时间直接出发
                FactionEscortController:GetInstance():RequestEscortStart()
                self.model.isLong = true
            end
        end
        

    end
    AddClickEvent(self.goBtn.gameObject,call_back)
    function call_back() --刷新
        local db = Config.db_escort[1]
        local rTimes = db.refresh
        local times = rTimes - self.model.refreshCount,rTimes
        local price = Config.db_voucher[self.itemId].price
        if self.model.lvBox  then  --勾选了最高级
            if  not self.isAuto then
                self.isAuto = true
                if self.refreshSchedule then
                    GlobalSchedule:Stop(self.refreshSchedule)
                    self.refreshSchedule = nil
                end
                self.refreshSchedule = GlobalSchedule:Start(handler(self, self.StartRefreshSchedule),0.5)
            end
            return
        else
            if not self.model.buyBox then --没有勾选自动购买
                if times <=  0 then  --没有免费次数
                    if BagModel:GetInstance():GetItemNumByItemID(self.itemId) < self.itemNum then --道具不足
                        -- Notify.ShowText(string.format("%s不足",Config.db_item[self.itemId].name))
                        self:ShowTips()
                        return
                    end
                    
                    
                    
                else --不消耗道具

                end
            else
                if not RoleInfoModel:GetInstance():CheckGold(price * self.itemNum,Constant.GoldType.BGold) then
                    return
                end
            end

        end
        --BagModel:GetInstance():GetItemNumByItemID(50000)
        --if true then
        --
        --end
       -- self.refreshSchedule = GlobalSchedule:Start(handler(self, self.StartRefreshSchedule),1.0)
        FactionEscortController:GetInstance():RequestRefersh()
    end
    AddClickEvent(self.RefBtn.gameObject,call_back)
    self.events[#self.events + 1] = GlobalEvent.AddEventListener(FactionEscortEvent.FactionEscortRefresh, handler(self, self.FactionEscortRefresh))  --刷新
    self.events[#self.events + 1] = GlobalEvent.AddEventListener(FactionEscortEvent.FactionEscortInfo, handler(self, self.FactionEscortInfo)) --护送信息
    self.events[#self.events + 1] = GlobalEvent.AddEventListener(FactionEscortEvent.FactionEscortStart, handler(self, self.FactionEscortStart))  --开始护送

end

function FactionEscortPanel:StartRefreshSchedule()
    self.isAuto = false
    local db = Config.db_escort[1]
    local rTimes = db.refresh
    local times = rTimes - self.model.refreshCount,rTimes

    if not  self.model.lvBox  then
        if self.refreshSchedule then
            GlobalSchedule:Stop(self.refreshSchedule)
            self.refreshSchedule = nil
        end
        return
    end
    if self.model.itemQua == 4  then --到达最高级
        if self.refreshSchedule then
            GlobalSchedule:Stop(self.refreshSchedule)
            self.refreshSchedule = nil
        end
        Notify.ShowText("Max level reached")
        return
    end
   -- if not self.model.buyBox then
        if times <= 0 then  --没有免费次数
            if not self.model.buyBox then
                if BagModel:GetInstance():GetItemNumByItemID(self.itemId) < self.itemNum  then --道具不足

                    if self.refreshSchedule then
                        GlobalSchedule:Stop(self.refreshSchedule)
                        self.refreshSchedule = nil
                    end
                    self:ShowTips()
                    --Dialog.ShowOne("提示","所需要的道具不足","确定",nil)
                    return
                end
            else
                local price = Config.db_voucher[self.itemId].price
                if not RoleInfoModel:GetInstance():CheckGold(price * self.itemNum,Constant.GoldType.BGold) then
                    if self.refreshSchedule then
                        GlobalSchedule:Stop(self.refreshSchedule)
                        self.refreshSchedule = nil
                    end
                end
            end

    end

    FactionEscortController:GetInstance():RequestRefersh()
end


--刷新模型
function FactionEscortPanel:InitModel()
    local modelId = Config.db_escort_product[self.key].modelid
    if self.monster then
        self.monster:destroy();
    end
    self.monster = UIMountModel(self.bossCon, "model_mount_" .. modelId, handler(self, self.HandleMonsterLoaded));
end

function FactionEscortPanel:HandleMonsterLoaded()
    SetLocalPosition(self.monster.transform, -1901, 29, 893)
    SetLocalRotation(self.monster.transform,162,53,200)
    --self.monster:AddAnimation({ "idle" }, false, nil, 0)
end

--更新物品
function FactionEscortPanel:UpdateItems(items)
    local curQua = self.model.itemQua
    local level = self.role.level
    self.key = curQua.."@"..level
   -- local key = curQua.."@"..level
    --print2(key)
   -- dump(Config.db_escort_product)
   -- print2(Config.db_escort_product[tostring(key)])
   -- dump(Config.db_escort_product[key])
    for i = 1, 4 do
        local key = i.."@"..level
        if not self.items[i] then
            self.items[i] = FactionEscortItem(self.FactionEscortItem.gameObject,self.itemContent,"UI")
        end
        self.items[i]:SetData(Config.db_escort_product[key],i)
    end
    self:SetSelect()
    self:InitModel()
    self:SetItem()
end

function FactionEscortPanel:SetItem()
    local itemStr = Config.db_escort_product[self.key].complete
    local itemTab = String2Table(itemStr)
    for i, v in pairs(self.showItem) do
        v:destroy()
        v = nil
    end
    self.showItem = {}
    for i = 1, #itemTab do
        local id = itemTab[i][1]
        local num = itemTab[i][2]
        if self.showItem[i] == nil then
            self.showItem[i] = GoodsIconSettorTwo(self.awardsContent)
        end
        if self.model:CheckIsDouble() then
            num = num * 2
        end

        local param = {}
        param["model"] = self.model
        param["item_id"] = id
        param["num"] = num
        param["can_click"] = true
        --  param["size"] = {x = 72,y = 72}
        self.showItem[i]:SetIcon(param)

       -- self.showItem[i]:UpdateIconByItemIdClick(id,num)
        --self.showItem[i] = GoodsAttrItemSettor()
    end
end

function FactionEscortPanel:SetSelect()
    for i = 1, #self.items do
        if self.model.itemQua == i then
            self.items[i]:SetSelect(true)
        else
            self.items[i]:SetSelect(false)
        end
    end
end

--刷新品质返回
function FactionEscortPanel:FactionEscortRefresh(data)
    self:SetTimes()
    self:UpdateItems()
end

function FactionEscortPanel:SetTimes()
    local db = Config.db_escort[1]
    local rTimes = db.refresh
    local aTimes = db.attend

    self.todayTimes.text = string.format("Daily attempts: <color=#%s>%s/%s</color>","2E870F",aTimes - self.model.escortCount,aTimes)
    local times = rTimes - self.model.refreshCount
  --  local color = "2E870F" "e63232"
    if times <= 0 then
        times = 0
        SetVisible(self.refreshTimes,false)
        SetVisible(self.useItems,true)
        local color = "e63232"
        if BagModel:GetInstance():GetItemNumByItemID(self.itemId) >= self.itemNum  then
            color = "2E870F"
        end
        if self.useItem == nil then
            self.useItem = GoodsIconSettor(self.iocnParent)
        end
        self.useItem:UpdateIconByItemIdClick(self.itemId,self.itemNum)


        self.useItemsTex.text = string.format("<color=#%s>%s/%s</color>",color,BagModel:GetInstance():GetItemNumByItemID(self.itemId),self.itemNum)
    else
        SetVisible(self.refreshTimes,true)
        SetVisible(self.useItems,false)
        self.refreshTimes.text = string.format("Free refreshes: <color=#2E870F>%s/%s</color>",times,rTimes)
    end

end




function FactionEscortPanel:SetLvBox(bool)
    bool = bool and true or false;
    self.model.lvBox = false
    self.lvBox.isOn = bool
end
function FactionEscortPanel:SetBuyBox(bool)
    bool = bool and true or false;
    self.model.buyBox = false
    self.buyBox.isOn = bool
end
function FactionEscortPanel:FactionEscortStart()
   -- SetVisible(self.UnEsc,false)
   -- SetVisible(self.startEsc,true)
    self:Close()
end

--是否开始寻路
function FactionEscortPanel:StartAstar(isAuto)

end

function FactionEscortPanel:FactionEscortInfo(data)
    self.escortEndTime = data.end_time
    self.rTime = data.end_time - TimeManager.GetServerTime()  --剩余时间
    if self.escortTimeDown then
        GlobalSchedule:Stop(self.escortTimeDown)
        self.escortTimeDown = nil
    end
    if self.rTime > 0 then
        local timeTab = TimeManager:GetLastTimeData(TimeManager.Instance:GetServerTime(), self.escortEndTime)
        if timeTab then
            minStr = string.format("%02d", timeTab.min or 0)
            secStr = string.format("%02d", timeTab.sec or 0)
            self.times.text = string.format("%sf%s", minStr, secStr)
        end
        self.escortTimeDown = GlobalSchedule:Start(handler(self, self.StartEscortTimeDown),1.0)
    end

end
function FactionEscortPanel:StartEscortTimeDown()
    local timeTab = TimeManager:GetLastTimeData(TimeManager.Instance:GetServerTime(), self.escortEndTime)
    if timeTab then
        minStr = string.format("%02d", timeTab.min or 0)
        secStr = string.format("%02d", timeTab.sec or 0)
        self.times.text = string.format("%sf%s", minStr, secStr)
    else
            if self.escortTimeDown then
                GlobalSchedule:Stop(self.escortTimeDown)
                self.escortTimeDown = nil
            end

    end
    --if self.rTime  <= 0 then
    --    if self.escortTimeDown then
    --        GlobalSchedule:Stop(self.escortTimeDown)
    --        self.escortTimeDown = nil
    --    end
    --end
    --self.times.text = self.rTime
end

function FactionEscortPanel:ShowTips()
    local db = Config.db_voucher[self.itemId]
    local pic = 0
    if db then
        pic = db.price * self.itemNum
    end
    local color = Config.db_item[self.itemId].color
  --  local message =string.format("是否购买并使用<color=#ffcc00>%s</color>钻石购买<color=#%s>%s</color>x%s,刷新一次品质",pic,ColorUtil.GetColor(color),Config.db_item[self.itemId].name,self.itemNum)

    local message = string.format("Buy and use <color=#43f673>%s</color> <color=#%s>%s</color>？\nTip: Cost <color=#43f673>%s</color> bound diamonds\nDiamonds will be used if you don't have enough bound diamonds",self.itemNum,ColorUtil.GetColor(color),Config.db_item[self.itemId].name,pic)

    local function ok_func()
        if not RoleInfoModel:GetInstance():CheckGold(pic * self.itemNum,Constant.GoldType.BGold) then
            if self.refreshSchedule then
                GlobalSchedule:Stop(self.refreshSchedule)
                self.refreshSchedule = nil
            end
            return
        end
        FactionEscortController:GetInstance():RequestRefersh()
        if self.refreshSchedule then
            GlobalSchedule:Stop(self.refreshSchedule)
            self.refreshSchedule = nil
        end
       -- self.isJump = true
    end
    local function no_func()
        if self.refreshSchedule then
            GlobalSchedule:Stop(self.refreshSchedule)
            self.refreshSchedule = nil
        end
    end

    --Dialog.ShowOne("提示",message,"确定",ok_func)
    Dialog.ShowTwo('Tip',message,'Confirm',ok_func,nil,'Cancel',no_func,nil,"Don't notice me again today",true,false,self.__cname..3)
end

