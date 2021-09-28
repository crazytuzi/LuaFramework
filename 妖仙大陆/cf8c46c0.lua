local _M = {}
_M.__index = _M

local Util  = require 'Zeus.Logic.Util'
local ItemModel = require 'Zeus.Model.Item'
local self = {}

local function InitUI()
    local UIName = {
        "ib_box1",
        "ib_box2",
        "lb_tips1",
        "lb_tips2",
        "ib_box2_effect",

        "lb_money",
        "cvs_icon1",
        "cvs_icon2",
        "cvs_icon3"
    }

    for i = 1, #UIName do
        self[UIName[i]] = self.menu:GetComponent(UIName[i])
    end

end


local function OnEnter()
    

end

local function InitComponent(self, tag,params)
    self.menu = LuaMenuU.Create('xmds_ui/solo/solo_box.gui.xml',tag)
    InitUI()

    if params == "view" then
        self.lb_tips1.Visible = true
        self.lb_tips2.Visible = false

        self.ib_box1.Visible = true
        self.ib_box2.Visible = false
        self.ib_box2_effect.Visible = false

    elseif params == "get" then
        self.lb_tips1.Visible = false
        self.lb_tips2.Visible = true

        self.ib_box1.Visible = false
        self.ib_box2.Visible = true
        self.ib_box2_effect.Visible = true
    end

    self.menu:SubscribOnEnter(OnEnter)


    self.menu.mRoot.IsInteractive = true
    self.menu.mRoot.Enable = true
    self.menu.mRoot.EnableChildren = true
    LuaUIBinding.HZPointerEventHandler({node = self.menu.mRoot, click = function(sender)
        self.menu:Close()
    end})


    return self.menu
end

function _M:setRewardData(data)
    for i,v in ipairs(data) do
        if i < 4 then
            local item = GlobalHooks.DB.Find("Items", v.itemCode)
            self.itemShow = Util.ShowItemShow(self["cvs_icon" .. i], item.Icon, item.Qcolor,v.itemNum)
            self.itemShow.EnableTouch = true
            self.itemShow.TouchClick = function (sender)
                local detail = ItemModel.GetItemDetailByCode(v.itemCode)
                EventManager.Fire('Event.ShowItemDetail',{data=detail}) 
            end
        end
    end

end

function _M:setViewRewardData(data)
    for i,v in ipairs(data) do
        if i < 4 then
            local item = GlobalHooks.DB.Find("Items", v)
            self.itemShow = Util.ShowItemShow(self["cvs_icon" .. i], item.Icon, item.Qcolor,1)
            self.itemShow.EnableTouch = true
            self.itemShow.TouchClick = function (sender)
                local detail = ItemModel.GetItemDetailByCode(v)
                EventManager.Fire('Event.ShowItemDetail',{data=detail}) 
            end
        end
    end
end


local function Create(tag,params)
    setmetatable(self, _M)
    InitComponent(self,tag, params)
    return self
end

return {Create = Create}
