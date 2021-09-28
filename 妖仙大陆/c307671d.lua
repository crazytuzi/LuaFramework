local _M = {}
_M.__index = _M

local Item          = require "Zeus.Model.Item"
local Util          = require "Zeus.Logic.Util"
local DisplayUtil   = require "Zeus.Logic.DisplayUtil"
local TitleAPI      = require "Zeus.Model.Title"
local ServerTime    = require "Zeus.Logic.ServerTime"

local self = {
    menu = nil,
}

local function updateCD()
    if self.selectIdx > 0 then
        local data = self.CurSortlist[self.selectIdx]
        if data ~= nil and data.invalidTime > 0 then
            local timeStr = ServerTime.GetCountDownCut(data.invalidTime)
            self.lb_continue_time.Text = Util.GetText(TextConfig.Type.TITLE, "cdFormat", timeStr)

            self.cvs_time.Visible = true
            return
        end
    end
    self.cvs_time.Visible = false
end

local function GetTotalAttr(index)
    for _, v in ipairs(self.titleTotalAttrMap[999]) do
        if _ == index and self.titleTotalAttrMap[v] then
            return self.titleTotalAttrMap[v]
        end
    end
    return nil
end

local function InitAllAttribute()
    local num = #self.titleTotalAttrMap[999]
    self.sp_value:Initialize(self.lb_attValue.Width+40, self.lb_attValue.Height+5, num, 1, self.lb_attValue, 
        function(gx, gy, node)
            local attr = GetTotalAttr(gy+1)
            if attr then
                node.Text = "      " .. Item.AttributeValue2NameValue(attr)
            else
                node.Text = ""
            end
        end, 
        function(node)
            node.Visible = true
        end
    )
end

local function ShowTitleDetail(data)
    if data == nil then
        self.cvs_title_detail.Visible = false
        return
    end
    self.lb_notget.Visible = false
    self.lb_canuse.Visible = false
    self.cvs_title_detail.Visible = true
    
    local statusLabel = self.menu:FindChildByEditName("lb_have_status",true)
    if data.isAward == false then
        statusLabel.FontColor = GameUtil.RGBA2Color(0xFF0000FF)
        statusLabel.Text = Util.GetText(TextConfig.Type.TITLE, "notGeted")
    elseif data.RankID == self.usingTitleId then
        statusLabel.FontColor = GameUtil.RGBA2Color(0x00D600FF)
        statusLabel.Text = Util.GetText(TextConfig.Type.TITLE, "using")
    else
        statusLabel.FontColor = GameUtil.RGBA2Color(0x0098F5FF)
        statusLabel.Text = Util.GetText(TextConfig.Type.TITLE, "geted")
    end

    local nameLabel = self.menu:FindChildByEditName("lb_titlename1",true)
    nameLabel.Text = data.RankName

    local tipLabel = self.menu:FindChildByEditName("lb_get_way1",true)
    tipLabel.XmlText = data.Tips

    for i=1,5 do
        self.attrLabelList[i].Visible = data.attrs[i] ~= nil
        if data.attrs[i] then
            self.attrLabelList[i].Text = Item.AttributeValue2NameValue(data.attrs[i])
        end
    end

    self.btn_use.Visible = data.isAward == true and self.usingTitleId ~= data.RankID
    self.btn_use.TouchClick = function(sender)
        self.usingTitleId = data.RankID
        self.btn_use.Visible = false
        TitleAPI.requestSaveTitle(self.usingTitleId)
    end
end

local function RefreshTitleItem(gx, gy, sender)
    local idx = gy + 1
    local data = self.CurSortlist[idx]
    sender.UserTag = idx
    local infoBtn = sender:FindChildByEditName("tbn_brief", true)
    infoBtn.IsChecked = false
    infoBtn.Enable = true
    infoBtn.UserTag = idx
    
    local nameBox = sender:FindChildByEditName("cvs_title_box",true)
    local lb_titlename = sender:FindChildByEditName("lb_titlename",true)
    
    if data~=nil then
       if data.Show == "-1" then
          nameBox.Visible =false
          lb_titlename.Visible = true
          lb_titlename.Text = data.RankName
          lb_titlename.FontColorRGBA = Util.GetQualityColorRGBA(data.RankQColor)
       else
          nameBox.Visible = true
          lb_titlename.Visible = false
          Util.HZSetImage2(nameBox, "#static_n/title_icon/title_icon.xml|title_icon|"..data.Show, true, LayoutStyle.IMAGE_STYLE_BACK_4_CENTER)
       end
    end

    local ib_owned = sender:FindChildByEditName("ib_owned",true)
    ib_owned.Visible = data.isAward == true

    infoBtn.IsChecked = idx == self.selectIdx
end

local function ItemClick(sender)
    local idx = sender.UserTag
    local oldIndex = self.selectIdx
    self.selectIdx = idx

    if oldIndex > 0 then
        local oldCell = DisplayUtil.getCell(self.sp_main, oldIndex)
        if oldCell then
            RefreshTitleItem(0, oldIndex-1, oldCell)
        end
    end

    local newCell = DisplayUtil.getCell(self.sp_main, self.selectIdx)
    RefreshTitleItem(0, self.selectIdx-1, newCell)
    
    ShowTitleDetail(self.CurSortlist[self.selectIdx])
end

local function InitTitleItem(node)
    node.Visible = true
    
    node.TouchClick = function(sender)
        ItemClick(sender)
    end
end

local function SelectSort(sortId)
    self.selectIdx = 1
    self.CurSortlist = {}
    for i,v in ipairs(self.titleList) do
        if v.SortID == sortId then
            table.insert(self.CurSortlist,v)
            if v.RankID == self.usingTitleId then
                self.selectIdx = #self.CurSortlist
            end
        end
    end

    local num = #self.CurSortlist
    self.sp_main:Initialize(self.cvs_item.Width, self.cvs_item.Height, num, 1, self.cvs_item, 
        LuaUIBinding.HZScrollPanUpdateHandler(RefreshTitleItem), 
        LuaUIBinding.HZTrusteeshipChildInit(InitTitleItem)
    )
    
    if num > 0 and self.selectIdx > 1 then
        DisplayUtil.lookAt(self.sp_main, self.selectIdx)
    end
    
    ShowTitleDetail(self.CurSortlist[self.selectIdx])
end

local function InitTitleList()
    self.usingTitleId = TitleAPI.GetTitleInfo().usingTitleId
    self.hasTitle = TitleAPI.GetTitleInfo().hasTitle
    self.hasCDTitle = TitleAPI.GetTitleInfo().hasCDTitle
    self.titleList = TitleAPI.GetTitleList()


    self.lb_type_num.Text = "("..self.hasTitle.."/"..#self.titleList..")"

    self.lb_notget.Visible = self.hasTitle == 0
    self.lb_canuse.Visible = self.hasTitle > 0 and self.usingTitleId <= 0

    RemoveUpdateEvent(self, true)

    if self.hasCDTitle then
        AddUpdateEvent(self, function() updateCD() end)
    end

    self.titleTotalAttrMap = TitleAPI.GetTotalAttMap()
    InitAllAttribute()

    self.cvs_time.Visible = false

    local sortId = TitleAPI.getsortId(self.usingTitleId)
    self.sortBtnList[sortId].IsChecked = true
end

local function OnExit()
    RemoveUpdateEvent(self, true)
end

local function OnEnter()
    self.selectIdx = 0
    self.usingTitleId = 0
    self.CurSortlist = {}

    self.cvs_item.Visible = false
    self.cvs_value.Visible = false
    self.cvs_title_detail.Visible = false

    InitTitleList()
end

local function InitUI()
    local UIName = {
        "btn_closet",
        "sp_main",
        "cvs_item",
        "lb_type_num",
        "sp_sort",
        "sp_value",
        "lb_attValue",
        "tb_single",

        "cvs_title_detail",
        "lb_have_status",
        "lb_titlename1",
        "lb_get_way",
        "cvs_time",
        "lb_continue_time",
        "cvs_value",
        "btn_use",
        "btn_shuxing",
        "lb_notget",
        "lb_canuse",
    }

    for i = 1, #UIName do
        self[UIName[i]] = self.menu:GetComponent(UIName[i])
    end

    self.lb_attValue.Visible = false
    self.tb_single.Visible = false

    self.sortBtnList = {}
    local sortList = GlobalHooks.DB.Find("RankSort",{})
    self.sp_sort:Initialize(self.tb_single.Width, self.tb_single.Height, #sortList, 1, self.tb_single, 
        function(gx, gy, node)
            local idx = gy + 1
            local data = sortList[idx]
            node.Text = data.Sort
            node.UserTag = data.SortID
        end, 
        function(node)
            table.insert(self.sortBtnList,node)
        end
    )
    Util.InitMultiToggleButton(function (sender)
        SelectSort(sender.UserTag)
    end,
    nil,self.sortBtnList)

    self.attrLabelList = {}
    for i=1,5 do
        self.attrLabelList[i] = self.menu:GetComponent("lb_attValue"..i)
        self.attrLabelList[i].Visible = false
    end

    self.btn_shuxing.TouchClick = function(sender)
        self.cvs_value.Visible = true
    end

    self.cvs_value.TouchClick = function(sender)
        self.cvs_value.Visible = false
    end

    self.btn_closet.TouchClick = function(sender)
        self.menu:Close()
    end
end

local function InitCompnent(params)
    InitUI()

    self.menu:SubscribOnEnter(OnEnter)
    self.menu:SubscribOnExit(OnExit)
    self.menu:SubscribOnDestory(function()
        self = nil
    end)
end

local function Init(params)
    self.menu = LuaMenuU.Create("xmds_ui/title/title_main.gui.xml", GlobalHooks.UITAG.GameUIRoleTitleList)
    self.menu.Enable = true
    
    self.menu.mRoot.IsInteractive = true
    self.menu.mRoot.Enable = true
    self.menu.mRoot.EnableChildren = true
    LuaUIBinding.HZPointerEventHandler({node = self.menu.mRoot, click = function (sender)
        self.menu:Close()
    end})

    InitCompnent(params)
    return self.menu
end

local function Create(params)
    setmetatable(self, _M)
    local node = Init(params)
    return self
end

local function initial()
    
end

return {Create = Create, initial = initial}
