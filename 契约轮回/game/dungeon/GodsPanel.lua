--- Created by Admin.
--- DateTime: 2019/10/30 10:17

GodsPanel = GodsPanel or class("GodsPanel", BaseItem)
local this = GodsPanel

function GodsPanel:ctor(parent_node, parent_panel)
    self.abName = "dungeon"
    self.assetName = "GodsPanel"
    self.layer = "UI"
    self.panel_type = 2;
    self.events = {};
    self.gEvents = {}
    self.itemicon = {}
    self.itemList = {}
    self.level = {}
    self.curLevel = 0
    self.maxwave = 0 -- 通过的最大波数
    GodsPanel.super.Load(self);
    self.model = DungeonModel:GetInstance()
    self.dungeon_type = enum.SCENE_STYPE.SCENE_STYPE_DUNGE_GOD
end

function GodsPanel:dctor()
    self.model:RemoveTabListener(self.gEvents)
    GlobalEvent:RemoveTabListener(self.events)

    if self.saodang_btn_reddot then
        self.saodang_btn_reddot:destroy()
    end
    for i = 1, #self.itemList do
         self.itemList[i]:destroy()
    end
    for i = 1, #self.itemicon do
        self.itemicon[i]:destroy()
    end
    if self.my_scroll then
        self.my_scroll:OnDestroy()
        self.my_scroll = nil
    end

    self.itemicon = nil
    self.itemList = nil
    self.saodang_btn_reddot = nil
    self.curView = 1
    self.maxView = 1
    if self.StencilMask then
        destroy(self.StencilMask)
        self.StencilMask = nil
    end
end

function GodsPanel:Open()

end

function GodsPanel:LoadCallBack()
    self.nodes = {
        "bg","godsItem","saodang","saodang/count","enter","des",
        "record","cur","pos","enter/redDot",
        "rankScroll","rankScroll/Viewport","rankScroll/Viewport/rankContent",
    }
    self:GetChildren(self.nodes)
    self.scroll = GetRectTransform(self.rankScroll)
    self.godsImg = GetImage(self.bg)
    self.sdBtn = GetButton(self.saodang)
    self.enterBtn = GetButton(self.enter)
    self.countTex = GetText(self.count)
    self.desTex = GetText(self.des)
    self.curTex = GetText(self.cur)
    self.recordTex = GetText(self.record)
    self.btnImg = GetImage(self.enter)

    local res = "gods_bg"
    lua_resMgr:SetImageTexture(self, self.godsImg, "iconasset/icon_big_bg_" .. res, res, true)

    self.saodang_btn_reddot = RedDot(self.saodang.transform, nil, RedDot.RedDotType.Nor)
    self.saodang_btn_reddot:SetPosition(69, 24)
    SetVisible(self.redDot.gameObject, self.model.isShowRed)
    self:SetMask()
    self:InitPanel()
    self:AddEvent()

end

function GodsPanel:InitPanel()
    self.config = Config.db_dunge[30601]  -- 配置表数据
    self.desTex.text = self.config.des
    self:CreateReward()
    DungeonCtrl:GetInstance():RequestDungeonPanel(self.dungeon_type)
    self:CreateItem2()
end

function GodsPanel:AddEvent()
    local function call_back()
        if self.model.godsSDCount > 0 then
            if self:IsSaoDang() then
                self:SaoDangClick()
            else
                Notify.ShowText("No need to raid");
            end
        else
            Notify.ShowText("Not enough farm attempts");
        end
    end
    AddClickEvent(self.sdBtn.gameObject, call_back)

    local function call_back()
        if self.model.godsIsAll then
            Notify.ShowText("All cleared")
            return
        end
        if  self.model.godsSDCount > 0 and self:IsSaoDang() then
            local data = {}
            data.type = 2
            data.saodang_call = handler(self, self.SaoDangClick)
            data.enter_call = handler(self, self.EnterClick)
            lua_panelMgr:GetPanelOrCreate(DungeonGodTipPanel):Open(data)
        else
            self:EnterClick()
        end
    end
    AddClickEvent(self.enterBtn.gameObject, call_back)

    local function call_back(dungeon_type, data)
        if dungeon_type == self.dungeon_type then
            self:UpdateData(data)
        end
    end
    self.events[#self.events + 1] = GlobalEvent:AddListener(DungeonEvent.UpdateDungeonData, call_back)

    AddEventListenerInTab(DungeonEvent.UpdateReddot, handler(self, self.UpdateReddot), self.events);
    -- 扫荡刷新
    local function call_back()
        DungeonCtrl:GetInstance():RequestDungeonPanel(self.dungeon_type)
    end
    AddEventListenerInTab(DungeonEvent.DUNGEON_SWEEP_REFRESH, call_back, self.events);
   -- GlobalEvent.AddEventListenerInTab(DungeonEvent.DUNGEON_SWEEP_REFRESH, handler(self, self.UpdateTimes), self.events);
    -- 领取返回
    local function call_back(type, data)
        if type == self.dungeon_type then
            DungeonCtrl:GetInstance():RequestDungeonPanel(self.dungeon_type) --请求最新数据 来开关红点  部请求model里不是最新数据
        end
     end
    self.gEvents[#self.gEvents + 1] = self.model:AddListener(DungeonEvent.FetchResult, call_back)

end

--   更新 数据
function GodsPanel:UpdateData(data)
    self.level = data.level or {}
    local info  = data.info
    if info then
        self.model.godsSDCount = 1 - info.sweep_times
        if self.model.godsSDCount == 0 then
            self.countTex.text = string.format("Farm（<color=#eb0000>0</color>/1）")
        else
            self.countTex.text = string.format("Raid (1/1)")
        end

        self.model.godsIsAll = info.max_wave == self.model.maxWave
        self.model.curWave = info.cur_wave
        self.maxwave = info.max_wave
        self.model.godsMaxReword = info.max_wave - (info.max_wave % 4)

        if self.model.godsIsAll then
            SetGray(self.btnImg,true)
            SetVisible(self.redDot.gameObject, false)
            self.model.isShowRed = false
			CacheManager:GetInstance():SetBool("GodsPanel2225", false)
        end

        self.curTex.text = string.format("Wave %s", info.cur_wave)
        self.recordTex.text = string.format("Wave %s", self.model.godsMaxReword)

        SetVisible(self.saodang_btn_reddot.gameObject, self:IsSaoDang())

        self:UpdateItemState()
        local index = self:GetPosIndex()
        self.my_scroll:SetIndexPos(index)
		local function call_back() -- 有临界问题  拖动下刷新 
			local x = GetLocalPositionX(self.rankContent)
			SetLocalPositionX(self.rankContent, x + 50)
			GlobalSchedule.StopFun(self.iid)
		end
       self.iid =  GlobalSchedule.StartFunOnce(call_back, 0.2)
    end

end

--  生成奖励和 生成 item
function GodsPanel:CreateReward()
    --30601
    local reward = String2Table(self.config.reward_show)
    for i = 1, #reward do
        local id = reward[i][1]
        local num = reward[i][2]
        local bind = reward[i][3]
        if self.itemicon[i] == nil then
            self.itemicon[i] = GoodsIconSettorTwo(self.pos)
        end
        local param = {}
        param["model"] = self.model
        param["item_id"] = id
        param["num"] = num
        param["bind"] = bind
        param["can_click"] = true
        self.itemicon[i]:SetIcon(param)
    end
--[[
    local i = 1  -- 获取有多少波数
    while Config.db_dunge_wave[30601 .."@".. i] do
        i = i +1
    end
   self.model.maxWave = i - 1
--]]
end

-- 扫荡 点击
function GodsPanel:SaoDangClick()
    DungeonCtrl:GetInstance():RequestSweep(self.dungeon_type);
end

--  进入 副本
function GodsPanel:EnterClick()
    DungeonCtrl:GetInstance():RequestEnterDungeon(self.dungeon_type)
    if self.model.isShowRed then
        SetVisible(self.redDot.gameObject, false)
        self.model.isShowRed = false
        CacheManager:GetInstance():SetBool("GodsPanel2225", false)
        self.model:UpdateReddot() --  刷新tog 上的红点
    end
end


function GodsPanel:UpdateReddot()
    if  self:IsSaoDang() then
        self.saodang_btn_reddot:SetRedDotParam(true);
    else
        self.saodang_btn_reddot:SetRedDotParam(false);
    end
end



-- 是否可以扫荡
function GodsPanel:IsSaoDang()
    local n = DungeonModel:GetInstance().curWave
    local m = DungeonModel:GetInstance().godsMaxReword

    if m - n < 1 then
        return false
    end

    for i = n, m do
        if Config.db_dunge_god[i].record == 1 then
            return true
        end
    end
    return false
end


function GodsPanel:SetMask()
    self.StencilId = GetFreeStencilId()
    self.StencilMask = AddRectMask3D(self.Viewport.gameObject)
    self.StencilMask.id = self.StencilId
end

function GodsPanel:CreateItem2()
    local param = {}
    local cellSize = {width = 80,height = 190}
    param["scrollViewTra"] = self.scroll
    param["cellParent"] = self.rankContent
    param["cellSize"] = cellSize
    param["cellClass"] = GodsItem
    param["begPos"] = Vector2(0,0)
    param["spanX"] = 20
    param["spanY"] = 0
    param["createCellCB"] = handler(self,self.SetItemData)
    param["updateCellCB"] = handler(self,self.SetItemData)
    param["cellCount"] = self.model.maxWave
    self.my_scroll = ScrollViewUtil.CreateItems(param)
end

function GodsPanel:SetItemData(itemCls)
    local index = itemCls.__item_index
    local config = Config.db_dunge_wave[30601 .."@".. index]
    if config then
        itemCls:SetData(self.StencilId, config, index, self.maxwave, self.level[index])
    end
end


function GodsPanel:UpdateItemState()
     self.my_scroll:ForceUpdate()
end

function GodsPanel:GetPosIndex()
    local max = self.maxwave or 1

    for i = 1, max do
        if not self.level[i] then
            return i
        end
    end
    return max
end