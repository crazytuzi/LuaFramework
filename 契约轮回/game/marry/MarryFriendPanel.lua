---
--- Created by  Administrator
--- DateTime: 2019/6/3 14:41
---
MarryFriendPanel = MarryFriendPanel or class("MarryFriendPanel", BaseItem)
local this = MarryFriendPanel

function MarryFriendPanel:ctor(parent_node, parent_panel)
    self.abName = "marry";
    self.assetName = "MarryFriendPanel"
    self.layer = "UI"
    self.events = {}
    self.tags = {}
    self.flowers = {}
    self.rightItems = {}
    self.nowPage = 1
    self.isFirst = true
    self.model = MarryModel:GetInstance()
    self.role = RoleInfoModel.GetInstance():GetMainRoleData()
    MarryFriendPanel.super.Load(self)
end

function MarryFriendPanel:dctor()
    self.model:RemoveTabListener(self.events)
    if self.tags then
        for i, v in pairs(self.tags) do
            v:destroy()
        end
        self.tags = {}
    end
    if self.flowers then
        for i, v in pairs(self.flowers) do
            v:destroy()
        end
        self.flowers = {}
    end
    if self.rightItems then
        for i, v in pairs(self.rightItems) do
            v:destroy()
        end
        self.rightItems = {}
    end

    if self.rolemodel then
        self.rolemodel:destroy()
        self.rolemodel = nil
    end

    if self.emodel then
        self.emodel:destroy()
        self.emodel = nil
    end

    if self.role_icon then
        self.role_icon:destroy()
        self.role_icon = nil
    end
end

function MarryFriendPanel:LoadCallBack()
    self.nodes = {
        "firendPanel",
        "firendPanel/rightObj/rightScrollView/Viewport/rightContent","MarryFriendRightItem",
        "firendPanel/leftObj/headObj/changeKuangBtn",
        "firendPanel/leftObj/headObj/changeHeadBtn",
        "firendPanel/leftObj/headObj/firstObj","firendPanel/leftObj/tagsObj/addTagBtn",
        "firendPanel/leftObj/headObj/myHead","firendPanel/leftObj/tagsObj/tagsContent","firendPanel/leftObj/headObj/myHeadKuang",
        "MarryFriendFlowerItem","firendPanel/leftObj/myGif/itemScrollView/Viewport/itemContent",
        "firendPanel/rightObj/rightScrollView",
        "firendPanel/leftObj/tagsObj/titleBg/tagTitel",
        "firendPanel/leftObj/headObj/timesObj/makeFriendtimes",

        "marryPanel",
        "marryPanel/ringNum","marryPanel/marry_my/myName_1","marryPanel/dayNum",
        "marryPanel/divorceBtn","marryPanel/marryBtn",
        "marryPanel/marry_enemy/enemyName_1","marryPanel/intimacyNum",
        "marryPanel/enemyModel","marryPanel/myModel",
        "marryPanel/frendBtn"
    }
    self:GetChildren(self.nodes)
    self.rightScrollView = GetScrollRect(self.rightScrollView)
    self.tagTitel = GetText(self.tagTitel)
    self.ringNum = GetText(self.ringNum)
    self.myName_1 = GetText(self.myName_1)
    self.dayNum = GetText(self.dayNum)
    self.enemyName_1 = GetText(self.enemyName_1)
    self.intimacyNum = GetText(self.intimacyNum)
    self.makeFriendtimes = GetText(self.makeFriendtimes)

    self:InitUI()
    self:AddEvent()
    --dump(self.role)
    MarryController:GetInstance():RequsetDatingInfo(self.nowPage)
    --MarryController:GetInstance():RequsetMarriageInfo()
end

function MarryFriendPanel:InitUI()
    if self.role_icon then
        self.role_icon:destroy()
        self.role_icon = nil
    end
    local param = {}
    local function uploading_cb()
      --  logError("回调")
    end
    param["is_squared"] = true
    param["is_hide_frame"] = true
    param["size"] = 136
    param["uploading_cb"] = uploading_cb
    self.role_icon = RoleIcon(self.myHead)
    self.role_icon:SetData(param)
--    print2(self.role.marry)
    --if self.role.marry == 0 then --没结婚
        --SetVisible(self.firendPanel,true)
       -- SetVisible(self.marryPanel,false)
       -- MarryController:GetInstance():RequsetDatingInfo(self.nowPage)
   -- else
       -- SetVisible(self.firendPanel,false)
       -- SetVisible(self.marryPanel,true)
       -- MarryController:GetInstance():RequsetMarriageInfo()
       -- MarryController:GetInstance():RequsetRingInfo()
   -- end
end

function MarryFriendPanel:AddEvent()

    function DragEnd_Call_Back()
        if self.rightScrollView.verticalNormalizedPosition <= 0 then
            self.nowPage = self.nowPage + 1
            MarryController:GetInstance():RequsetDatingInfo(self.nowPage)
        end
    end
    AddDragEndEvent(self.rightScrollView.gameObject,DragEnd_Call_Back)

    local function call_back()
        lua_panelMgr:GetPanelOrCreate(MarryTagsPanel):Open()
    end
    AddClickEvent(self.addTagBtn.gameObject,call_back)


    local function call_back() -- 交友大厅
        SetVisible(self.firendPanel,true)
        SetVisible(self.marryPanel,false)

        if self.isFirst == true then
            MarryController:GetInstance():RequsetDatingInfo(self.nowPage)
            self.isFirst = false
        end

    end
    AddClickEvent(self.frendBtn.gameObject,call_back)


    local function call_back()
        lua_panelMgr:GetPanelOrCreate(MarryChangeHeadPanel):Open(self.role_icon)
    end
    AddButtonEvent(self.changeHeadBtn.gameObject,call_back)
    --local function call_back()  --前往结婚
    --    self.model:GoNpc()
    --    --self:Close()
    --    local  panel = lua_panelMgr:GetPanel(MarryPanel)
    --    if panel then
    --        panel:Close()
    --    end
    --end
    --AddClickEvent(self.marryBtn.gameObject,call_back)
    --
    --local function call_back()  --离婚
    --    lua_panelMgr:GetPanelOrCreate(MarryDivorcePanel):Open()
    --end
    --AddClickEvent(self.divorceBtn.gameObject,call_back)
    self.events[#self.events + 1] = self.model:AddListener(MarryEvent.DatingInfo, handler(self, self.DatingInfo))
    self.events[#self.events + 1] = self.model:AddListener(MarryEvent.MarryTagsInfo, handler(self, self.MarryTagsInfo))
   -- self.events[#self.events + 1] = self.model:AddListener(MarryEvent.MarriageInfo, handler(self, self.MarriageInfo))
    self.events[#self.events + 1] = self.model:AddListener(MarryEvent.DivorceSuscc,handler(self,self.DivorceSuscc))
   -- self.events[#self.events + 1] = self.model:AddListener(MarryEvent.RingInfo,handler(self,self.RingInfo))

    --self.role:BindData("marry",call_back)
end

--设置自己的标签
function MarryFriendPanel:SetMyTagsInfo(tags)
    local len = #tags
    if len < 3 then
        SetVisible(self.addTagBtn,true)
        self:SetTagsBtnPos(len)
    else
        SetVisible(self.addTagBtn,false)
    end
    for i = 1, len do
        local tag =  self.tags[i]
        if not tag then
            tag = MarryFriendTagItem(self.tagsContent,"UI")
            self.tags[i] = tag
        else
            tag:SetVisible(true)
        end
        tag:SetData(tags[i],1)
    end

    for i = #tags + 1,#self.tags do
        local item = self.tags[i]
        item:SetVisible(false)
    end
    self.tagTitel.text = string.format("My Tags                           %s/3",len)
    --按钮坐标

end

function MarryFriendPanel:SetTagsBtnPos(index)
    SetLocalPositionX(self.addTagBtn,-455 + (85*index) )
end

function MarryFriendPanel:SetMyFlower()
    local cfg = table.pairsByKey(Config.db_flower)
    for i, v in cfg do
        local item =  self.flowers[i]
        if not item then
            item = MarryFriendFlowerItem(self.MarryFriendFlowerItem.gameObject,self.itemContent,"UI")
            self.flowers[i] = item
        end
        item:SetData(v)
    end
end

function MarryFriendPanel:UpdateItems(list)
    for i = 1, #list do
        local item = self.rightItems[(self.nowPage - 1) * 30 + i]
        if not item then
            item = MarryFriendRightItem(self.MarryFriendRightItem.gameObject,self.rightContent,"UI")
            self.rightItems[(self.nowPage - 1)* 30 + i] = item
        else
            item:SetVisible(true)
        end
        item:SetData(list[i])
    end

   -- if #self.rightItems > #list then
   --     for i = #list+ 1, #self.rightItems do
   --         local item = self.rightItems[i]
   --         item:SetVisible(false)
   --     end
   -- end

end



--返回交友大廳信息
function MarryFriendPanel:DatingInfo(data)
    if #data.list == 0  then --下一页没有数据
       -- Notify.ShowText("到底啦！没有数据")
        self.nowPage = self.nowPage - 1
        return
    end
    self:SetMyTagsInfo(data.mine.tags)
    self:SetMyFlower()
    self:UpdateItems(data.list)
    self.makeFriendtimes.text = "Be flirted for+"..data.mine.flirted
end
--设置标签返回
function MarryFriendPanel:MarryTagsInfo(data)
    self:SetMyTagsInfo(data.tags)
end

function MarryFriendPanel:MarriageInfo(data)
    self.myName_1.text = self.role.name
    self.enemyName_1.text = data.marry_with.name
    self.intimacyNum.text = data.intimacy
    self.dayNum.text = string.format("Married: %s days",data.day)
    self:InitMyModel()
    self:InitEnemyModel(data)
end

function MarryFriendPanel:InitMyModel()
    self.rolemodel = UIRoleCamera(self.myModel, nil, self.role)
end
function MarryFriendPanel:InitEnemyModel(data)
    self.emodel = UIRoleCamera(self.enemyModel, nil, data.marry_with)
end

function MarryFriendPanel:DivorceSuscc()
    --self:Close()
end

function MarryFriendPanel:RingInfo(data)
    local ring = data.ring
    self.ringNum.text = ring.grade.."Stage"..ring.level.."Level"
end
