local _M = { }
_M.__index = _M

local Util          = require 'Zeus.Logic.Util'
local AuctionModel = require 'Zeus.Model.Auction'
local ItemModel = require 'Zeus.Model.Item'


local Text = {
Txt_levelDesc    = Util.GetText(TextConfig.Type.ITEM,'levelDesc'),
Txt_upLevelDesc  = Util.GetText(TextConfig.Type.ITEM,'upLevelDesc'),
    
    
    
}

local function setTempFilter(self,ok)
    if ok  then
        if self.select.tempFilter then
            self.select.filter[0] = self.select.tempFilter[0]
            self.select.filter[1] = self.select.tempFilter[1]
            self.select.filter[3] = self.select.tempFilter[3]
        end
    else 
        self.select.tempFilter = self.select.tempFilter or {}

        self.select.tempFilter[0] = self.select.filter[0]
        self.select.tempFilter[1] = self.select.filter[1]
        self.select.tempFilter[3] = self.select.filter[3]
    end
end

local function RefreshList(self)
    
    AuctionModel.RequestAuctionList(self.last_params,function (data)                          
        self.total_page = data.s2c_totalPage
        if self.total_page <=0 then
            self.cvs_page.Visible = false
        else
            self.cvs_page.Visible = true
        end
        self.page_index = self.total_page > 0 and self.last_params.pageIndex or 0
        self.lb_page.Text = self.page_index..'/'..data.s2c_totalPage
        InitList(self,data.s2c_data)
        end)
end

local function getStrItemType(MenuCode)
    
    local typeCodes = string.split(MenuCode)
    local strItemType
    for _,c in ipairs(typeCodes) do 
        local typeInfo = unpack(GlobalHooks.DB.Find('ItemTypeConfig',{ParentCode = c}))
        if not strItemType then
            strItemType = ''
        else
            strItemType = strItemType..','
        end
        strItemType = strItemType..typeInfo.ID
    end

    return strItemType
end

local function RequestList(self,page_index)
    page_index = page_index or 1

    local pro = self.select.filter[0]
    local quality = self.select.filter[1]
    local lv = self.select.filter[3]
    local sort = self.select.filter[2]


    local requestType
    local itemType = self.select_itemType or ''
    if self.select.kind then
        
        local ele = unpack(GlobalHooks.DB.Find('ItemIdConfig',{ItemType = self.select.kind.MenuCode}))
        requestType = ele.TypeID
    end
    
    local params = {
        pro = pro,
        quality = quality,
        sort = sort,
        itemType = itemType,
        secondType = requestType or -1,
        pageIndex = page_index,     
        global = 0,
        level = lv,
    }

    
    self.last_params = params
    RefreshList(self)
end

local function FindTypeTable(self,type)
    for _,v in ipairs(self.types[type]) do
        if v.FilterCode == self.select.tempFilter[type] then
            return v 
        end
    end 
end

local function ResetSortTbt(self)
    self.tbt_job_all.IsChecked = false
    self.tbt_job_all.Text = FindTypeTable(self,0).FilterName
    self.tbt_quality_all.IsChecked = false
    self.tbt_quality_all.Text = FindTypeTable(self,1).FilterName
    self.tbt_level_all.IsChecked = false
    self.tbt_level_all.Text = FindTypeTable(self,3).FilterName

    self.cvs_sort_single.Visible = false
end


local function ResetFilterName(self)
    local  isUseDefault = true

    self.lb_varietyname.Text = ''
    if self.select.filter[0]~= -1 then
        isUseDefault = false
        self.lb_varietyname.Text = self.lb_varietyname.Text .. self.tbt_job_all.Text
    end

    if self.select.filter[1] ~= -1 then
        isUseDefault = false 
        self.lb_varietyname.Text = self.lb_varietyname.Text .. self.tbt_quality_all.Text
    end

    if self.select.filter[3] ~= -1 then
        isUseDefault = false 
        self.lb_varietyname.Text = self.lb_varietyname.Text .. self.tbt_level_all.Text
    end

    if isUseDefault then
        self.lb_varietyname.Text = self.varietynameDefaultText
    end
end

local function ShowSubFilter(self,sender)
if sender.IsChecked == false then
sender.IsChecked = true
do return end
end

self.cvs_sort_single.Visible = true


local  filterType = -1
if sender == self.tbt_job_all then
self.tbt_quality_all.IsChecked = false
self.tbt_level_all.IsChecked = false
filterType = 0                
elseif sender == self.tbt_quality_all then
self.tbt_job_all.IsChecked = false
self.tbt_level_all.IsChecked = false
filterType = 1
else
    self.tbt_job_all.IsChecked = false
    self.tbt_quality_all.IsChecked = false
    filterType = 3
end

self.sp_sort_single.Scrollable.Container:RemoveAllChildren(true)
self.sp_sort_single.Scrollable.Container.Y = 0
for i,v in ipairs(self.types[filterType]) do
    local node
    if i == 1 then
        node = self.btn_all_class
    else
        node = self.btn_level_single:Clone()
        node.Visible = true
        node.Y = (i - 2)*(node.Height +5)
        self.sp_sort_single.Scrollable.Container:AddChild(node)
    end
    node.Text = v.FilterName
    node.TouchClick = function (sender)
    
    self.select.tempFilter[filterType] = v.FilterCode
    ResetSortTbt(self)
end
end

end



local function SetDefaultFilter(self)
    self.select = self.select or {}
    self.select.filter = {
        [0] = -1,
        [1] = -1,
        [2] =  0, 
        [3] = -1, 
    }

    setTempFilter(self)
    self.lb_conditionname.Text = self.btn_time_near.Text
    ResetSortTbt(self)

    ResetFilterName(self)

    
    
    

    
    
    

    
    
    

    RequestList(self,1)
end

local function SelectFilter(self,sender,checkkind)
    local tbt = (self.tbt_pro.IsChecked and self.tbt_pro) or
    (self.tbt_quality.IsChecked and self.tbt_quality) or
    (self.tbt_price.IsChecked and self.tbt_price)

    tbt.Text = sender.Text
    tbt.FontColor = sender.FontColor
    tbt.FocuseFontColor = sender.FontColor
    VisibleFilter(self,nil)

    local filter = map_filter[sender.EditName]
    self.select = self.select or {}
    self.select.filter = self.select.filter or {}
    self.select.filter[filter.FilterType] = filter
    if checkkind then
        if not self.select_itemType then
            GameAlertManager.Instance:ShowNotify(Text.noSorting)
            return
        end
    end
    RequestList(self,1)
end


local function VisibleFilter(self,sender)
    self.cvs_sort_single.Visible = false

    

    self.cvs_sort.Visible = sender == self.cvs_variety and not self.tbt_variety.IsChecked
    self.cvs_sorting.Visible = sender == self.cvs_condition and not self.tbt_condition.IsChecked 

    self.tbt_variety.IsChecked = self.cvs_sort.Visible
    self.tbt_condition.IsChecked = self.cvs_sorting.Visible

    self.tbt_quality_all.IsChecked = false
    self.tbt_job_all.IsChecked = false
    self.tbt_level_all.IsChecked = false

    if self.cvs_sort.Visible then 
        ResetSortTbt(self)
    end
end

local function SelectSubKinds(self,sender,kind)
    if self.select and self.select.node then
        local  tbt_open = self.select.node:FindChildByEditName('tbt_open',false)
        if tbt_open == nil then
            self.select.node.IsChecked = false
        else 
            tbt_open.IsChecked = true
        end
        self.select.node = nil
    end
    self.select = self.select or {}
    self.select.node = sender
    self.select.kind = kind
    self.ib_equip_type.Text = kind.MenuName
    self.select_itemType = nil

    RequestList(self)
end

local function ResetKindPos(self)
    local y = 0
    for i,v in ipairs(self.kinds) do
        local cvs_subtype = v.node:FindChildByEditName('cvs_subtype',false)
        local cvs_typename = v.node:FindChildByEditName('cvs_typename',false)
        if cvs_subtype.Visible then
            v.node.Height = cvs_subtype.Y + cvs_subtype.Height + 10
        else
            v.node.Height = cvs_typename.Y + cvs_typename.Height + 6
        end
        v.node.Y = y
        y = v.node.Y + v.node.Height + 5
    end
end

local function SetDefaultKind(self)
    for i,v in ipairs(self.kinds) do
        local cvs_subtype = v.node:FindChildByEditName('cvs_subtype',false)
        local cvs_typename = v.node:FindChildByEditName('cvs_typename',false)
        cvs_typename:FindChildByEditName('tbt_open',false).IsChecked = false
        cvs_subtype.Visible = false
        Util.ForEachChild(cvs_subtype,function (child)
            child.IsChecked = false
            end)
    end 
    ResetKindPos(self)
end


InitList =  function(self,listdata)
self.listdata = listdata

local self_lv = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.LEVEL)
local self_uplv = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.UPLEVEL)

local function OnUpdateItem(node,index,ele)
    
    local lb_equip_name = node:FindChildByEditName('lb_equip_name',false)
    local lb_equip_level = node:FindChildByEditName('lb_equip_level',false)
    local lb_number = node:FindChildByEditName('lb_number',false)
    local lb_spend_num = node:FindChildByEditName('lb_spend_num',false)
    lb_number.Visible = false
    local ib_player_icon1 = node:FindChildByEditName('ib_player_icon1',false)

    local detail = ItemModel.GetItemDetailByCode(ele.detail.code)

    ItemModel.SetDynamicAttrToItemDetail(detail,ele.detail)

    local function OnPopDetail()
    local params = {
        num = ele.groupCount,
        name = ele.consignmentPlayerName,
        pro = ele.consignmentPlayerPro,
        diamond = ele.consignmentPrice 
    }
    local ui,obj = GlobalHooks.FindUI(GlobalHooks.UITAG.GameUIConsignmentItemDetail)
    if not ui then
        ui,obj = GlobalHooks.CreateUI(GlobalHooks.UITAG.GameUIConsignmentItemDetail,0)
        local uiParent,_ = GlobalHooks.FindUI(GlobalHooks.UITAG.GameUIConsignmentMain)

        uiParent:AddSubMenu(ui)
    end

    obj:Set(detail,params,0)

end
        
        local itshow = Util.ShowItemShow(ib_player_icon1,detail.static.Icon,detail.static.Qcolor,ele.groupCount)
        Util.ItemshowExt(itshow,detail,detail.equip ~= nil)
        
        
        node.TouchClick = OnPopDetail
        
        
        
        lb_equip_name.Text = detail.static.Name
        lb_equip_name.FontColorRGBA = Util.GetQualityColorRGBA(detail.static.Qcolor)

        local level = detail.static.LevelReq
        local uplevel = detail.static.UpReq

        if level == 0 and uplevel > 0 then
            local ret = unpack(GlobalHooks.DB.Find('UpLevelExp',{UpLevel=uplevel,Pro=detail.static.Pro}))
            
            if ret == nil then
                lb_equip_level.Text = Text.Txt_levelDesc..level
            else
                if self_uplv < uplevel then
                    lb_equip_level.Text = Text.Txt_upLevelDesc..ret.UpName
                    lb_equip_level.FontColorRGBA = Util.GetQualityColorRGBA(GameUtil.Quality_Red)
                else
                    lb_equip_level.SupportRichtext = true
                    local rgba = Util.GetQualityColorRGBAStr(ret.Qcolor)
                    lb_equip_level.Text = string.format('%s<color=#%s>%s</color>',Text.Txt_upLevelDesc,rgba,ret.UpName)
                end 
            end
        else
            lb_equip_level.Text = Text.Txt_levelDesc..level
            if self_lv < level then
                lb_equip_level.FontColorRGBA = Util.GetQualityColorRGBA(GameUtil.Quality_Red)
            else
                lb_equip_level.FontColorRGBA = Util.GetQualityColorRGBA(GameUtil.Quality_Default)
            end     
        end
        

        lb_spend_num.Text = GameUtil.FormatMoney(ele.consignmentPrice)

        local diamond = ItemModel.GetDiamond()
        if diamond < ele.consignmentPrice then
            lb_spend_num.FontColorRGBA = Util.GetQualityColorRGBA(GameUtil.Quality_Red)
        else
            lb_spend_num.FontColorRGBA = Util.GetQualityColorRGBA(GameUtil.Quality_Default)
        end

        
        
        
        node.UserTag = index
    end

    local function UpdateListItem(gx,gy,node)
        
        local  index = gy*2+gx+1
        if index > #self.listdata then
            node.Visible = false 
        else
            node.Visible = true
            OnUpdateItem(node,index,self.listdata[index])
        end

    end

    if self.total_page <=0 then
        self.cvs_page.Visible = false
    else
        self.cvs_page.Visible = true
    end
    if listdata and #listdata > 0 then
        self.lb_nothing.Visible = false
        self.ib_bg.Visible = true
        if self.sp_equip_detail.Rows <= 0 then
            local s = self.cvs_equip_single.Size2D
            self.sp_equip_detail:Initialize(s.x,s.y,math.ceil(#listdata/2),2,self.cvs_equip_single,UpdateListItem,function() end)
        else
            self.sp_equip_detail.Rows = math.ceil(#listdata/2)
        end
    else
        self.sp_equip_detail.Scrollable:ClearGrid()
        self.ib_bg.Visible = false
        self.lb_nothing.Visible = true
    end
end


local function InitKind(self)
    
    local kinds = GlobalHooks.DB.Find('StoreMenu',{IsShow = 1,ParentsID=0})

    self.kinds = {}

    for i,v in ipairs(kinds) do
        local node = self.cvs_item:Clone()
        node.Visible = true
        self.sp_type.Scrollable.Container:AddChild(node)

        
        local strItemType = getStrItemType(v.MenuCode)

        local sub_kinds = GlobalHooks.DB.Find('StoreMenu',{IsShow = 1,ParentsID=v.MenuID})

        local cvs_subtype = node:FindChildByEditName('cvs_subtype',false)
        local tbt_subtype = cvs_subtype:FindChildByEditName('tbt_subtype',false)
        local cvs_typename = node:FindChildByEditName('cvs_typename',false)
        cvs_typename:FindChildByEditName('lb_typename',false).Text = v.MenuName
        local tbt_open = cvs_typename:FindChildByEditName('tbt_open',false)
        tbt_open.Enable = false
        tbt_open.IsChecked = false

        local p = tbt_subtype.Position2D
        local s1 = tbt_subtype.Size2D
        local constraint = UnityEngine.UI.GridLayoutGroup.Constraint.FixedColumnCount
        local rectoffset = UnityEngine.RectOffset.New(0,0,0,0)

        cvs_subtype:SetGridLayout(s1,Vector2.zero,rectoffset,constraint,1)


        for ii,vv in ipairs(sub_kinds) do
            local tbt
            if ii == 1 then
                tbt = tbt_subtype
            else
                tbt = tbt_subtype:Clone()
                cvs_subtype:AddChild(tbt)
            end
            tbt.Text = vv.MenuName
            tbt:SetBtnLockState(HZToggleButton.LockState.eLockSelect)
            tbt.UserTag = ii
            tbt.IsChecked = false
            tbt.TouchClick = function (sender)
                VisibleFilter(self,nil)
                if sender.IsChecked then
                    SelectSubKinds(self,sender,vv)
                end
            end
        end
        cvs_subtype.Height = s1.y * #sub_kinds
        cvs_subtype.Visible = false



        cvs_typename.TouchClick = function (sender)
            local  tbt_open = sender:FindChildByEditName('tbt_open',false)
            local isChecked = not tbt_open.IsChecked
            tbt_open.IsChecked =  isChecked
            XmdsSoundManager.GetXmdsInstance():PlaySoundByKey('zuobiaoqian')
            if self.select and self.select.node then
                local  tbt_open = self.select.node:FindChildByEditName('tbt_open',false)
                if tbt_open == nil then
                    self.select.node.IsChecked = false
                else 
                    tbt_open.IsChecked = false
                end
                self.select.node = nil
            end

            if isChecked then
                        
                for _,kind in ipairs(self.kinds) do
                        local cvs_comp = kind.node:FindChildByEditName('cvs_typename',false)
                    if cvs_comp ~= sender then
                        local cvs_sub = kind.node:FindChildByEditName('cvs_subtype',false)
                        cvs_comp:FindChildByEditName('tbt_open',false).IsChecked = false
                        kind.isChecked = false
                        cvs_sub.Visible = false
                    else
                        kind.isChecked = true
                        self.select_itemType = kind.itemType
                        self.ib_equip_type.Text = v.MenuName
                        if self.select then
                            self.select.kind = nil
                            self.select.node = nil
                        end
                    end
                end
            else
                self.select_itemType = nil
                self.ib_equip_type.Text = ''
                if self.select then
                    self.select.kind = nil
                    self.select.node = nil
                end
            end


            RequestList(self)
            cvs_subtype.Visible = isChecked
            VisibleFilter(self,nil)
            ResetKindPos(self)
        end

        table.insert(self.kinds,{node=node,itemType = strItemType,sub_kinds=sub_kinds})
    end
    ResetKindPos(self)

    self.types = self.types or {}
    self.types[0] = GlobalHooks.DB.Find('StoreFilter',{FilterType=0})
    self.types[1] = GlobalHooks.DB.Find('StoreFilter',{FilterType=1})
    self.types[3] = GlobalHooks.DB.Find('StoreFilter',{FilterType=3})

    self.varietynameDefaultText = self.lb_varietyname.Text
end

local function resetAllDefault(self)
    self.select.filter[0] = -1
    self.select.filter[1] = -1
    self.select.filter[2] = 0
    self.select.filter[3] = -1
    ResetFilterName(self)

    self.lb_conditionname.Text = self.btn_time_near.Text
    VisibleFilter(self,nil)
    
    
    
    for i,v in ipairs(self.kinds) do
        local cvs_subtype = v.node:FindChildByEditName('cvs_subtype',false)
        local cvs_typename = v.node:FindChildByEditName('cvs_typename',false)

        if cvs_subtype.Visible then
            cvs_typename:FindChildByEditName('tbt_open',false).IsChecked = false

            if self.select and self.select.node then
                local  tbt_open = self.select.node:FindChildByEditName('tbt_open',false)
                if tbt_open == nil then
                    self.select.node.IsChecked = false
                else 
                    tbt_open.IsChecked = false
                end
                self.select.node = nil
            end

            cvs_subtype.Visible = false
            v.isChecked = true
            self.select_itemType = nil
            self.ib_equip_type.Text = ''
            if self.select then
                self.select.kind = nil
                self.select.node = nil
            end
            break
        end
    end
    ResetKindPos(self)
end


function _M:setVisible(visible)
    self.menu.Visible = visible

end

local function initControls(view, names, tbl)
    for i = 1, #names, 1 do
        local ui = names[i]
        local ctrl = view:FindChildByEditName(ui.name, true)
        if (ctrl) then
            tbl[ui.name] = ctrl
            if (ui.click) then
                ctrl.event_PointerClick = function()
                ui.click(tbl)
            end
        end
    end
end
end

local function refreshBuy( ... )
    local ui,obj = GlobalHooks.FindUI(GlobalHooks.UITAG.GameUIConsignmentMain)
    if ui then  
        if obj.buy.last_params then
            RefreshList(obj.buy)
        end
    end
end


function _M:OnEnter()
    
    self.select_itemType = nil
    self.ti_content.Input.Text = '' 
    self.ib_equip_type.Text = ''
    SetDefaultKind(self)
    SetDefaultFilter(self)

    EventManager.Subscribe("Event.UI.ConsignmentUIMain.RefreshBuy", refreshBuy)
end

function _M:OnExit()
    EventManager.Unsubscribe("Event.UI.ConsignmentUIMain.RefreshBuy", refreshBuy)
end

local ui_names = 
{
    {name = 'cvs_sorting'},
    {name = 'cvs_sort'},
    {name = 'cvs_sort_single'},
    {name = 'ti_content'},
    {name = 'cvs_item'},
    {name = 'sp_type'},
    {name = 'cvs_subtype'},
    {name = 'ib_equip_type'},
    {name = 'tbt_job_all',click = function(self)
    ShowSubFilter(self,self.tbt_job_all)
    end},
    {name = 'tbt_quality_all',click = function(self)
    ShowSubFilter(self,self.tbt_quality_all)
    end},
    {name = 'tbt_level_all',click = function(self)
    ShowSubFilter(self,self.tbt_level_all)
    end},
    {name = 'btn_reset',click = function(self)
        self.select.filter[0] = -1
        self.select.filter[1] = -1
        self.select.filter[3] = -1
        setTempFilter(self)
        ResetSortTbt(self)
    end},
    {name = 'btn_complete',click = function(self)
        setTempFilter(self,true)
        ResetFilterName(self)
        VisibleFilter(self,nil)
        RequestList(self)
    end},
    {name = 'btn_all_class'},
    {name = 'sp_sort_single'},
    {name = 'cvs_variety',click = function (self)
        setTempFilter(self)
        XmdsSoundManager.GetXmdsInstance():PlaySoundByKey('zuobiaoqian')
        VisibleFilter(self,self.cvs_variety)
    end},
    {name = 'cvs_condition',click = function(self)
        VisibleFilter(self,self.cvs_condition)
        XmdsSoundManager.GetXmdsInstance():PlaySoundByKey('zuobiaoqian')
    end},
    {name = 'tbt_variety'},
    {name = 'tbt_condition'},
    {name = 'lb_varietyname'},
    {name = 'lb_conditionname'},
    {name = 'btn_all_class'},
    {name = 'btn_level_single'},
    {name = 'sp_sort_single'},
    {name = 'btn_time_near',click = function(self)
        self.select.filter[2] = 0
        self.lb_conditionname.Text = self.btn_time_near.Text
        VisibleFilter(self,nil)
        RequestList(self)
    end},
    {name = 'btn_time_far',click = function(self)
        self.select.filter[2] = 1
        self.lb_conditionname.Text = self.btn_time_far.Text
        VisibleFilter(self,nil)
        RequestList(self)
    end},
    {name = 'btn_price_max',click = function(self)
        self.select.filter[2] = 2
        self.lb_conditionname.Text = self.btn_price_max.Text
        VisibleFilter(self,nil)
        RequestList(self)
    end},
    {name = 'btn_price_least',click = function(self)
        self.select.filter[2] = 3
        self.lb_conditionname.Text = self.btn_price_least.Text
        VisibleFilter(self,nil)
        RequestList(self)
    end},
    {name = 'lb_nothing'},
    {name = 'sp_equip_detail'},
    {name = 'cvs_equip_single'},
    {name = 'btn_left',click = function (self)
        VisibleFilter(self,nil)
        if self.page_index > 1 then
            RequestList(self,self.page_index - 1)
        else            
            
        end
    end},
    {name = 'btn_right',click = function (self)
        VisibleFilter(self,nil)
        if self.page_index < self.total_page then
            RequestList(self,self.page_index + 1)
        else
            
        end     
    end},
    {name = 'lb_page'},
    {name = 'ib_bg'},
    {name = 'cvs_page'},
    {name = 'btn_find',click = function (self)
        resetAllDefault(self)

        if self.ti_content.Input.Text ~= '' then
            self.lastSeach = self.lastSeach or {}
            if #self.lastSeach >= 3 then
                table.remove(self.lastSeach, 3)
            end
            table.insert(self.lastSeach,1,self.ti_content.Input.Text)
            local params = {condition = self.ti_content.Input.Text, global = 0}
            AuctionModel.RequestAuctionSearch(params,function (data)
                InitList(self, data)
                if self.total_page <=0 then
                    self.cvs_page.Visible = false
                else
                    self.cvs_page.Visible = true
                end
            end)
        else
            
            GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.ITEM,'inputText'))
        end
        VisibleFilter(self,nil)
    end},
    

}

local function InitComponent(self, tag, parent)
    
    self.menu = XmdsUISystem.CreateFromFile('xmds_ui/consignment/buy.gui.xml')
    initControls(self.menu,ui_names,self)

    self.parent = parent
    if (parent) then
        parent:AddChild(self.menu)
    end

    self.cvs_sorting.Visible = false
    self.cvs_sort.Visible = false
    self.cvs_sort_single.Visible = false
    self.cvs_item.Visible = false
    self.btn_level_single.Visible = false
    self.cvs_equip_single.Visible = false
    self.tbt_variety.Enable = false
    self.tbt_condition.Enable = false
    self.tbt_variety.IsChecked = false
    self.tbt_condition.IsChecked = false
    self.ti_content.TextSprite.Anchor = TextAnchor.C_C
    self.cvs_page.Enable = false
    
    InitKind(self)

    self.ti_content.event_endEdit = function (sender,txt)
        if txt == '' then
            RequestList(self)
        end
    end
end

function _M.Create(tag,parent)
    local ret = {}
    setmetatable(ret,_M)
    InitComponent(ret,tag,parent)
    return ret
end

return _M
