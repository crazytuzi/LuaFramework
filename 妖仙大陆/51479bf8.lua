local Util = require "Zeus.Logic.Util"
local ItemModel = require 'Zeus.Model.Item'
local BloodSoulAPI = require "Zeus.Model.BloodSoul"

local _M = {}

_M.__index = _M

local ui_names = {
    {
        name = "btn_close1",
        click = function(self)
            self:Close()
        end
    },
    { name = "sp_list"},
    { name = "cvs_equiping"},
    { name = "btn_forge",click = function(self)
        GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIItemGetDetail, 0, "blood")
    end},
    { name = "cvs_equip_brief"},
    { name = "cvs_equipicon0"},
    { name = "cvs_equip_list"},
    { name = "lb_tips_equipnone"}
}

function _M:Close()
    self:OnExit()
end

function _M:SetExitCallBack(cb)
    self.ExitCallBack = cb
end

local function ShowBloodDetail(node, itemshow, code)
    node.Enable = true
    local ib_click = node:FindChildByEditName("ib_click",true)
    node.TouchClick = function (sender)
        local detail = ItemModel.GetItemDetailByCode(code)
        local menu,obj = Util.ShowItemDetailTips(itemshow,detail)
        obj:setCloseCallback(function ()
            if ib_click then
                ib_click.Visible = false
            end
        end)
        ib_click.Visible = true
    end
    
        
        
    
end

local function initEquipBloodNodeValue(self,node,itemData)
    if itemData then
        local ctrlIcon = node:FindChildByEditName("cvs_equipicon0",true)
        local itemshow = Util.ShowItemShow(ctrlIcon, itemData.Icon, itemData.Qcolor)
        ShowBloodDetail(node, itemshow, itemData.Code)

        local lb_equipname = node:FindChildByEditName("lb_equipname",true)
        local btn_equip = node:FindChildByEditName("btn_equip",true)
        
        lb_equipname.Text = itemData.Name
        lb_equipname.FontColor = GameUtil.GetQualityColorUnity(itemData.Qcolor)

        local lb_score = node:FindChildByEditName("lb_score",true)
        lb_score.Text = itemData.BScore

        btn_equip.event_PointerClick = function()
            BloodSoulAPI.UnequipBloodRequest(self.selectPos, function()
                self.equipCode = nil
                self:initBloodFilter()
                EventManager.Fire("Event.BloodSoul.EquipSuccess", {})
            end)
        end
    end
end

local function initBloodNodeValue(self,node,index)
    local itemData = self.filter_target:GetItemDataAt(index)
    if itemData then
        local detail = itemData.detail
        local ctrlIcon = node:FindChildByEditName("cvs_equipicon0",true)
        local itemshow = Util.ShowItemShow(ctrlIcon, detail.static.Icon, detail.static.Qcolor)
        ShowBloodDetail(node, itemshow, detail.static.Code)

        local lb_equipname = node:FindChildByEditName("lb_equipname",true)
        local btn_equip = node:FindChildByEditName("btn_equip",true)
        
        lb_equipname.Text = detail.static.Name
        lb_equipname.FontColor = GameUtil.GetQualityColorUnity(detail.static.Qcolor)

        local lb_score = node:FindChildByEditName("lb_score",true)
        lb_score.Text = detail.static.BScore

        btn_equip.event_PointerClick = function()
            
                BloodSoulAPI.EquipBloodRequest(detail.id, function()
                    self.equipCode = detail.static.Code
                    self:initBloodFilter()
                    EventManager.Fire("Event.BloodSoul.EquipSuccess", {})
                end)
            
        end
    end
end


local scores = {}
local function scoresSort (self)
    scores={}
    for i=1, self.Container.Filter.ItemCount do
        local itemData = self.filter_target:GetItemDataAt(i)
        if itemData then
            local scorenum = itemData.detail.static.BScore
            table.insert(scores,{id=i,score=scorenum})
        end
    end
    table.sort(scores,function (a,b) return a.score>b.score end)
end

function _M:initBloodFilter()
    if self.equipCode then
        local info = BloodSoulAPI.GetBloodInfoByCode(self.equipCode)
        local itemData = ItemModel.GetItemStaticDataByCode(self.equipCode)
        itemData.BScore = info.BScore
        initEquipBloodNodeValue(self,self.cvs_equiping, itemData)
        self.cvs_equiping.Visible = true
    else
        self.cvs_equiping.Visible = false
    end


    self.Container = HZItemsContainer.New()
    self.Container.CellSize = HZItemShow.SelectSizeToBodySize(self.cvs_equipicon0.Size2D)
    local rolebag = DataMgr.Instance.UserData.RoleBag
    self.Container.ItemPack = rolebag
    self.filter_target = ItemPack.FilterInfo.New()
    self.filter_target.IsSequence = true
    self.filter_target.Type = ItemData.TYPE_TASK
    self.filter_target.CheckHandle = function(item)
        local detail = item.detail
        if detail then
            local info = BloodSoulAPI.GetBloodInfoByCode(detail.static.Code)
            if info and info.SortID3 == self.selectPos then
                detail.static.BScore = info.BScore
                return true
            else
                return false
            end
        else
            return false
        end
    end

    self.Container.Filter = self.filter_target
    local count = self.Container.Filter.ItemCount

    scoresSort(self)
    self.sp_list.Scrollable:Reset(1,count)

    if(count > 0) then
        self.lb_tips_equipnone.Visible = false
    else
        self.lb_tips_equipnone.Visible = true
    end
end

function _M:InitBloodList(code, pos)
    self.equipCode = code
    self.selectPos = pos
    self:initBloodFilter()
end

function _M:OnEnter()
    self.menu.Visible = true
end

function _M:OnExit()
    self.menu.Visible = false
    if self.ExitCallBack then
        self.ExitCallBack()
    end
end

function _M:OnDispose()
    
end

local function InitComponent(self, tag)
    self.menu = XmdsUISystem.CreateFromFile("xmds_ui/bloodsoul/property_bloodlist.gui.xml")
    for i = 1,#ui_names,1 do
        local ui = ui_names[i]
        local ctrl = self.menu:FindChildByEditName(ui.name,true)
        if(ctrl) then
            self[ui.name] = ctrl
            if(ui.click) then
                ctrl.TouchClick = function()
                    ui.click(self)
                end
            end
        end
    end
    self.cvs_equip_brief.Visible = false

    self.sp_list:Initialize(self.cvs_equip_brief.Width,self.cvs_equip_brief.Height,0,1,self.cvs_equip_brief,
        function(gx, gy, node)
            initBloodNodeValue(self, node, scores[gy + 1].id)
        end , 
        function(cell) 
            cell.Visible = true    
        end
    )
end

function _M.Create(tag,parent)
    local ret = {}
    setmetatable(ret,_M)
    ret.parent = parent
    InitComponent(ret,tag)
    return ret
end

return _M
