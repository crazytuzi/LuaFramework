


local Util = require "Zeus.Logic.Util"
local ItemModel = require "Zeus.Model.Item"
local CDLabelExt = require "Zeus.Logic.CDLabelExt"
local _M = {
    canSubmit = nil,cdLabel = nil
}
_M.__index = _M

local ui_names = {
    {name = "btn_close",click = function(self)
        self:Close()
    end},
    {name = "bt_quit",click = function(self)
        self:submitQuest()
    end},
    {name = "lb_name"},
    {name = "tbn_gou"},
    {name = "lb_time"},
    {name = "cvs_icon"},
    {name = "lb_num"},
    {name = "btn_get"},
}

function _M:Close()
    self.menu:Close()
end

function _M:submitQuest()
    local q = self.quest
    local kind = q:GetIntParam("Kind")
    Pomelo.TaskHandler.submitTaskRequest(q.TemplateID, kind, 0, tostring(0), function(ex, sjson)
        print("提交任务成功  q.TemplateID = " .. q.TemplateID)
        self:Close()
    end )
end

function _M:OnEnter()
    local qID = self.menu.ExtParam
    print("qID = "..qID)

    local quest =  DataMgr.Instance.QuestManager:GetQuest(tonumber(qID))
    self.canSubmit = false
    local targetID = quest:GetStringParam("TargetID")
    local needNum = quest:GetIntParam("Quantity")
    self.quest = quest
    local itemDetail = nil
    if targetID and string.len(targetID) > 0 then
        itemDetail = ItemModel.GetItemDetailByCode(targetID)
        print("itemDetail = "..PrintTable(itemDetail))
        self.lb_name.Text = itemDetail.static.Name .. "*"..needNum
        self.lb_name.FontColor = GameUtil.GetQualityColorUnity(itemDetail.static.Qcolor)
        local bag_data = DataMgr.Instance.UserData.RoleBag
        local vItem = bag_data:MergerTemplateItem(targetID)
        local x =(vItem and vItem.Num) or 0
        self.lb_num.Text = x
        Util.ShowItemShow(self.cvs_icon, itemDetail.static.Icon, itemDetail.static.Qcolor)
        self.canSubmit = (x >= needNum)
    end
    self.bt_quit.Enable = self.canSubmit
    self.bt_quit.IsGray = not self.canSubmit

    self.btn_get.Visible = not self.canSubmit
    if itemDetail ~= nil then
        self.btn_get.TouchClick = function ( )
            
             GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIItemGetDetail, 0, itemDetail.static.Code)
        end
    end

    local function callback(cd,label)
        label.Text = string.format("%2d",cd)
        if cd == 0 then
            if self.canSubmit then
                self:submitQuest()
            end
        end
    end
    self.cdLabel = CDLabelExt.New(self.lb_time,5,callback)
    if self.canSubmit and self.tbn_gou.IsChecked then
        self.cdLabel:start()
    end
end

function _M:OnExit()
    self.cdLabel:stop()
    self.cdLabel = nil
end

function _M:OnDestory()

end

local function InitComponent(self,tag)
    self.menu = LuaMenuU.Create('xmds_ui/common/submit.gui.xml', tag)
    self.menu.ShowType = UIShowType.HideBackMenu + UIShowType.HideBackHud
    Util.CreateHZUICompsTable(self.menu, ui_names, self)
     self.menu:SubscribOnExit( function()
        self:OnExit()
    end )
    self.menu:SubscribOnEnter( function()
        self:OnEnter()
    end )
    self.menu:SubscribOnDestory( function()
        self:OnDestory()
    end )

    local function handler_callback()
        if self.canSubmit then
            self:submitQuest()
        end
    end
    self.tbn_gou.Selected = function(sender)
        if sender.IsChecked then
            print("sdfsdfsdfsfs")
            if self.cdLabel then
                self.cdLabel:start()
            end
        else
            if self.cdLabel then
                self.cdLabel:stop()
            end
        end
    end
end

function _M.Create(tag,param)
    local self = {}
    setmetatable(self,_M)
    InitComponent(self,tag)
    return self
end

return _M

