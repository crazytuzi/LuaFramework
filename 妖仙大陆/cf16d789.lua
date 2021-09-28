local _M = { }
_M.__index = _M

local Util          = require 'Zeus.Logic.Util'
local AuctionModel = require 'Zeus.Model.Auction'
local ItemModel = require 'Zeus.Model.Item'
local ServerTime   = require 'Zeus.Logic.ServerTime'


local Text = {
    Txt_levelDesc    = Util.GetText(TextConfig.Type.ITEM,'levelDesc'),
    Txt_upLevelDesc  = Util.GetText(TextConfig.Type.ITEM,'upLevelDesc'),
    noMyAuction = Util.GetText(TextConfig.Type.ITEM,'noMyAuction')
}

local function ToCountDownSecond(endTime)
    local passTime = math.floor(endTime/1000-ServerTime.GetServerUnixTime())
    return passTime
end

local function LateWait( price )
    if price <=100 then
        return 10
    elseif price <= 500 then
        return 15 
    elseif price <=1000 then
        return 25 
    else
        return 30
    end
end

local function InitList(self,data)
    self.data = data
    
    
    
    
    local self_lv = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.LEVEL)
    local self_uplv = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.UPLEVEL)
    local function OnUpdateItem(node,index,ele)
        node.Visible = true
        
        local lb_equip_name = node:FindChildByEditName('lb_equip_name',false)
        local lb_equip_level = node:FindChildByEditName('lb_equip_level',false)
        
        local lb_spend_num = node:FindChildByEditName('lb_spend_num',false)
        local lb_last_times = node:FindChildByEditName('lb_last_times',false)
        
        local ib_player_icon1 = node:FindChildByEditName('ib_player_icon1',false)

        local detail = ItemModel.GetItemDetailByCode(ele.detail.code)

        ItemModel.SetDynamicAttrToItemDetail(detail,ele.detail)
        ib_player_icon1.Enable = false
        local itshow = Util.ShowItemShow(ib_player_icon1,detail.static.Icon,detail.static.Qcolor,ele.groupCount)
        
        print(ele.publishTimes)
        detail.publishTimes = ele.publishTimes
        detail.index = index
        Util.ItemshowExt(itshow,detail,detail.equip ~= nil)

        
        
        
        lb_equip_name.Text = detail.static.Name
        lb_equip_name.FontColorRGBA = Util.GetQualityColorRGBA(detail.static.Qcolor)

        local params = {
            num = ele.groupCount,
            name = ele.consignmentPlayerName,
            pro = ele.consignmentPlayerPro,
            diamond = ele.consignmentPrice 
        }
        node.TouchClick = function(sender)
            self.selectIndex = index
            local ui,obj = GlobalHooks.FindUI(GlobalHooks.UITAG.GameUIConsignmentItemDetail)
            if not ui then
                ui,obj = GlobalHooks.CreateUI(GlobalHooks.UITAG.GameUIConsignmentItemDetail,0)
                local uiParent,_ = GlobalHooks.FindUI(GlobalHooks.UITAG.GameUIConsignmentMain)

                uiParent:AddSubMenu(ui)
            end
            detail.publishTimes = ele.publishTimes
            if ToCountDownSecond(ele.consignmentTime) >= 86400 then
                obj:Set(detail,params,2)
            elseif ToCountDownSecond(ele.consignmentTime) <= 0 then
                obj:Set(detail,params,3)
            else
                obj:Set(detail,params,1)
            end
            
        end

        local level = detail.static.LevelReq
        local uplevel = detail.static.UpReq


        if level == 0 and uplevel > 0 then
            local ret = unpack(GlobalHooks.DB.Find('UpLevelExp',{UpLevel=uplevel,Pro=detail.static.Pro}))
            if ret then
                if self_uplv < uplevel then
                    lb_equip_level.Text = Text.Txt_upLevelDesc..ret.UpName
                    lb_equip_level.FontColorRGBA = Util.GetQualityColorRGBA(GameUtil.Quality_Red)
                else
                    lb_equip_level.SupportRichtext = true
                    local rgba = Util.GetQualityColorRGBAStr(ret.Qcolor)
                    lb_equip_level.Text = string.format('%s<color=#%s>%s</color>',Text.Txt_upLevelDesc,rgba,ret.UpName)
                end 
            else
                lb_equip_level.Text = Text.Txt_levelDesc..level
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
        if ToCountDownSecond(ele.consignmentTime) >= 86400 then
            lb_last_times.Text = Util.GetText(TextConfig.Type.ITEM,'shangjia',LateWait(ele.consignmentPrice))
        elseif ToCountDownSecond(ele.consignmentTime) <= 0 then
            lb_last_times.Text = Util.GetText(TextConfig.Type.ITEM,'guoqi')
        else
            lb_last_times.Text = GameUtil.GetTimeToString(ToCountDownSecond(ele.consignmentTime))
        end

        
        node.UserTag = index
    end
    
    local function UpdateListItem(gx,gy,node)
        OnUpdateItem(node,gy+1, self.data[gy+1])
    end
    

    if self.data and #self.data > 0 then
        if self.sp_auction_detail.Rows <= 0 then
            local s = self.cvs_equip_single.Size2D
            self.sp_auction_detail:Initialize(s.x,s.y,#self.data,1,self.cvs_equip_single,UpdateListItem,function() end)
        else
            self.sp_auction_detail.Rows = #self.data
        end
        self.lb_nothing.Visible = false
    else
        self.lb_nothing.Visible = true
        self.sp_auction_detail.Scrollable:ClearGrid()
    end

    
end

local function UpdateCountDown(self)
    if not self.data or #self.data == 0 then
        return 
    end
    local len = #self.data
    for i=len,1,-1 do
        local v = self.data[i]
        v.countDownSecond = ToCountDownSecond(v.consignmentTime)
        
        
        
    end

    
    if len < #self.data then
        
        InitList(self,self.data)
    else
        
        Util.ForEachChild(self.sp_auction_detail.Scrollable.Container,function (node)
            local lb_last_times = node:FindChildByEditName('lb_last_times',false)
            local ele = self.data[node.UserTag]
            if ele and lb_last_times then
                
                if ele.countDownSecond >= 86400 then
                    lb_last_times.Text = Util.GetText(TextConfig.Type.ITEM,'shangjia',LateWait(ele.consignmentPrice)) 
                elseif ele.countDownSecond <= 0 then
                    table.remove(self.data,node.UserTag) 
                    lb_last_times.Text = Util.GetText(TextConfig.Type.ITEM,'guoqi')
                else
                    lb_last_times.Text = GameUtil.GetTimeToString(ele.countDownSecond)
                end
            end
        end)
    end
end

function _M:OnEnter()
    AuctionModel.RequestMyAuction({global = 0},function (data,sell_num)
        InitList(self,data)
        self.lb_shelf_num.Text =  (self.data and #self.data or 0).. "/" .. tostring(sell_num)
    end)

    local passTime = 0
    self.need_refresh = nil
    AddUpdateEvent("Event.UI.AuctionUI.Update", function(deltatime)
        passTime = passTime + deltatime
        if passTime >= 1 then
        
        passTime = 0
        UpdateCountDown(self)
    end
   end)

    local function PublistimesAdd(evtName,param)
        self.data[param.index].publishTimes = self.data[param.index].publishTimes + 1
    end

    local function refreshAuction( ... )
    AuctionModel.RequestMyAuction({global = 0},function (data,sell_num)
            InitList(self,data)
            self.lb_shelf_num.Text =  (self.data and #self.data or 0) .. "/" .. tostring(sell_num)
        end)
    end
    self.refreshAuction = refreshAuction
    self.PublistimesAdd = PublistimesAdd
    EventManager.Subscribe("Event.UI.ConsignmentUIMain.RefreshAuction",self.refreshAuction)
    EventManager.Subscribe("Event.PublistimesAdd", self.PublistimesAdd)
end

function _M:OnExit()
    RemoveUpdateEvent("Event.UI.AuctionUI.Update", true)
    if self.need_refresh then
        EventManager.Fire('Event.UI.ConsignmentUIMain.RefreshBuy',{})
    end
    EventManager.Unsubscribe("Event.UI.ConsignmentUIMain.RefreshAuction",self.refreshAuction)
    EventManager.Unsubscribe("Event.PublistimesAdd", self.PublistimesAdd)
end


local ui_names = 
{
    {name = 'btn_sell',click = function (self)
        EventManager.Fire("Event.UI.ConsignmentUIMain.Sell",{})
    end},
    {name = 'cvs_equip_single'},
    {name = 'lb_nothing'},
    {name = 'sp_auction_detail'},
    {name = 'cvs_equip_single'},
    {name = 'lb_shelf_num'}
}

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


local function InitComponent(self, tag, parent)
    
    self.menu = XmdsUISystem.CreateFromFile('xmds_ui/consignment/auction.gui.xml')
    initControls(self.menu,ui_names,self)

    self.parent = parent
    if (parent) then
        parent:AddChild(self.menu)
    end

    self.cvs_equip_single.Visible = false
    self.lb_nothing.Visible = false

end

function _M.Create(tag,parent)
    local ret = {}
    setmetatable(ret,_M)
    InitComponent(ret,tag,parent)
    return ret
end

return _M
