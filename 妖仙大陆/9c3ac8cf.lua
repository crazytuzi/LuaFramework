local _M = {}
_M.__index = _M

local Util  = require 'Zeus.Logic.Util'
local ItemModel = require 'Zeus.Model.Item'
local ActivityUtil = require 'Zeus.UI.XmasterActivity.ActivityUIUtil'
local self = {}
local prizeItems = {}

function _M.SetActivityInfo(activityInfo,dailyInfo)
    local roleLv = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.LEVEL)

    self.lb_title.Text = activityInfo.SchName
    self.lb_lv.Text = Util.GetText(TextConfig.Type.ACTIVITY, "ACT_OverLevel",activityInfo.LvLimit)
    self.lb_limit.Text = activityInfo.Form
    self.lb_time.Text = activityInfo.TimeDesc
    self.lb_desc.Text = activityInfo.ActivDesc
    self.lb_num.Text = activityInfo.VitBonus

    self.btn_go.TouchClick = function()
        ActivityUtil.OnActivityClickGo(activityInfo)
        if activityInfo.FunID ~= 0 then
            self.menu:Close()
        end
    end
    
    self.btn_go.Visible = (roleLv >= dailyInfo.lvLimit) and 
            ((dailyInfo.max_num == 0 and true or 
            (activityInfo.MaxAttend == 0 and true or dailyInfo.cur_num < activityInfo.MaxAttend))
            and (dailyInfo.isOver == 1)) 

    local activitydata = string.split(activityInfo.RewardPre,';')
    local item_counts = #activitydata
    self.sp_fall.Scrollable:ClearGrid()
    if self.sp_fall.Rows <= 0 then
        local cs = self.cvs_single.Size2D
        self.sp_fall:Initialize(cs.x,cs.y,1,item_counts,self.cvs_single,
        function (gx,gy,node)
            local dropName = activitydata[gx+1]
            local lb_name = node:FindChildByEditName('lb_name',false)
            local ib_icon = node:FindChildByEditName('ib_icon',false)
            local cvs_icon = node:FindChildByEditName('cvs_icon',false)

            local static_data = ItemModel.GetItemStaticDataByCode(dropName)  
            local item = Util.ShowItemShow(cvs_icon, static_data.Icon, static_data.Qcolor, 1)
            Util.NormalItemShowTouchClick(item,dropName,false)

            lb_name.Text = static_data.Name
            lb_name.FontColorRGBA = Util.GetQualityColorRGBA(static_data.Qcolor)  

        end,function () end)
    else
        self.sp_fall.Rows = item_counts
    end 

    
    local tempPos = {}
    if item_counts == 1 then
        tempPos = {217,}
    elseif item_counts == 2 then
        tempPos = {159,275,}
    elseif item_counts == 3 then
        tempPos = {101,217,333,}
    elseif item_counts == 4 then
        tempPos = {43,159,275,391,}
    end

    for i = 1, #prizeItems do
        local showPrize = function(node,pos,index)
            local dropName = activitydata[index]
            local lb_name = node:FindChildByEditName('lb_name',false)
            local ib_icon = node:FindChildByEditName('ib_icon',false)
            local cvs_icon = node:FindChildByEditName('cvs_icon',false)
            node.X = pos

            local static_data = ItemModel.GetItemStaticDataByCode(dropName)  
            local item = Util.ShowItemShow(cvs_icon, static_data.Icon, static_data.Qcolor, 1)
            Util.NormalItemShowTouchClick(item,dropName,false)

            lb_name.Text = static_data.Name
            lb_name.FontColorRGBA = Util.GetQualityColorRGBA(static_data.Qcolor)  
        end
        if i > item_counts then
            prizeItems[i].Visible = false
        else
            prizeItems[i].Visible = true
            showPrize(prizeItems[i],tempPos[i],i)
        end
            
    end

end

local function InitUI()
    local UIName = {
    	"btn_close",
        "lb_title",
        "lb_lv",
        "lb_limit",
        "lb_time",
        "lb_desc",
        "lb_num",
        "sp_fall",
        "cvs_single",
        "cvs_single1",
        "cvs_single2",
        "cvs_single3",
        "cvs_single4",
        "btn_go",
    }
    for i = 1, #UIName do
        self[UIName[i]] = self.menu:GetComponent(UIName[i])
    end
    self.cvs_single.Visible = false
    table.insert(prizeItems,self.cvs_single1)
    table.insert(prizeItems,self.cvs_single2)
    table.insert(prizeItems,self.cvs_single3)
    table.insert(prizeItems,self.cvs_single4)
end

local function OnEnter()

end

local function OnExit()

end

local function InitComponent(tag,params)
    self.menu = LuaMenuU.Create('xmds_ui/activity/introduce.gui.xml',tag)
    self.menu.ShowType = UIShowType.HideBackHud
  
    InitUI()
    self.menu:SubscribOnEnter(OnEnter)
    self.menu:SubscribOnExit(OnExit)

    self.menu:SubscribOnDestory(function()
        
    end)

    self.btn_close.TouchClick = function()
        if self ~= nil and self.menu ~= nil then
        	self.menu:Close()
    	end
    end

    self.menu.mRoot.IsInteractive = true
    self.menu.mRoot.Enable = true
    self.menu.mRoot.EnableChildren = true
    LuaUIBinding.HZPointerEventHandler({node = self.menu.mRoot, 
        click = function()
        if self.menu then
            self.menu:Close()
        end
    end})

    return self.menu
end


local function Create(tag,params)
    self = {}
    setmetatable(self, _M)
    InitComponent(tag, params)
    return self
end

return {Create = Create}
