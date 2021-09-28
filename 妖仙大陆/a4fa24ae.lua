local _M = { }
_M.__index = _M

local Util = require 'Zeus.Logic.Util'
local ActivityUtil = require 'Zeus.UI.XmasterActivity.ActivityUIUtil'
local ActivityModel = require 'Zeus.Model.DailyActivity'
local DisplayUtil = require "Zeus.Logic.DisplayUtil"




local ActivityId = nil

local function GetDegreeInfoById(degreeId,self)
    for i = 1,#self.degreeLst do
        if self.degreeLst[i].id == degreeId then
            return self.degreeLst[i]
        end
    end
    return nil
end

local function GetDailyInfoById(dailyId,self)
    for i = 1,#self.dailyLst do
        if self.dailyLst[i].id == dailyId then
            return self.dailyLst[i]
        end
    end
    return nil
end

local function RefreshBtnGoEffect(btn_go,id)
    if btn_go.Visible == true and ActivityId and id == ActivityId then
        Util.showUIEffect(btn_go,56)
    else
        Util.clearUIEffect(btn_go,56)
    end
end

local function UpdateDailyInfo(dailyList,self)
    local roleLv = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.LEVEL)
    local listCan= {}
    local listNoCan = {}
    for i = 1,#dailyList,1 do
        local a = dailyList[i]
        local dailyData = GlobalHooks.DB.Find('Schedule',a.id)
        local aComplete = (roleLv < a.lvLimit or 
                (dailyData.MaxAttend > 0 and a.cur_num >= dailyData.MaxAttend or false))
        local aOpen = (roleLv >= a.lvLimit)
        if(a.isOver ~= 1) then
            aComplete = true
        end
        
        local aStart = a.isOver == 1
        local aScript = dailyData.Script
        local aSort = dailyData.Sort
        local v = {}
        v.value = a
        v.data = dailyData
        v.param = {isComplete = aComplete,isOpen = aOpen,isStart = aStart}
        if aComplete then
            table.insert(listNoCan,v)
        else
            table.insert(listCan,v)
        end
    end

    table.sort(listNoCan ,function(a,b)
        if a.param.isOpen and b.param.isOpen then
            
        elseif a.param.isOpen then
            return true
        elseif b.param.isOpen then
            return false
        end
        return a.data.Sort < b.data.Sort
    end)
    table.sort(listCan,function(a,b)
        if a.value.cur_num < a.data.MaxCount and b.value.cur_num < b.data.MaxCount then
            
            if a.param.isStart == true and b.param.isStart == true then
                
            elseif a.param.isStart == true then
                return true
            elseif b.param.isStart == true then
                return false
            end
        elseif a.value.cur_num < a.data.MaxCount then
            return true
        elseif b.value.cur_num < b.data.MaxCount then
            return false
        end



































        return a.data.Sort < b.data.Sort
    end)
    self.dailyLst = {}
    for i = 1,#listCan,1 do
        table.insert(self.dailyLst,listCan[i].value)
    end
    for i = 1,#listNoCan,1 do
        table.insert(self.dailyLst,listNoCan[i].value)
    end

    


































































    
    local item_counts = #self.dailyLst
    self.sp_list.Scrollable:ClearGrid()
    if self.sp_list.Rows <= 0 then
        self.sp_list.Visible = true
        local cs = self.size_node
        self.sp_list:Initialize(cs.x,cs.y,item_counts%2 == 0 and item_counts/2 or item_counts/2 +1,2,self.cvs_activity,
        function (gx,gy,node)
            local dailyInfo = self.dailyLst[gy*2 + gx+1]
            if dailyInfo == nil then
                node.Visible = false    
                return
            end
            node.Visible = true
            local dailyData = GlobalHooks.DB.Find('Schedule',dailyInfo.id)
            local cvs_icon =  node:FindChildByEditName('cvs_icon',false)
            Util.ShowItemShow(cvs_icon, dailyData.Icon,-1,1)
            node.Name = dailyData.SchName
            node:FindChildByEditName('lb_name',false).Text = dailyData.SchName
            local lb_times = node:FindChildByEditName('lb_times',false)
            lb_times.Text = (dailyInfo.max_num == 0) and Util.GetText(TextConfig.Type.ACTIVITY, "ACT_NoLimit") or string.format("%d/%d",dailyInfo.cur_num,dailyInfo.max_num)
            if dailyInfo.max_num == 0 or dailyInfo.cur_num < dailyInfo.max_num then
                lb_times.FontColorRGBA = 0xddf2ffff
            else
                lb_times.FontColorRGBA = 0xf17405ff
            end

            node:FindChildByEditName('lb_vitality',false).Text = dailyInfo.perDegree
            node:FindChildByEditName('ib_discount',false).Visible = (dailyData.Script == 1)
            node:FindChildByEditName('ib_discount2',false).Visible = (dailyData.Script == 2)
            node:FindChildByEditName('ib_discount3',false).Visible = (dailyData.Script == 3)
            node:FindChildByEditName('ib_discount4',false).Visible = (dailyData.Script == 4)
            local lb_openlv = node:FindChildByEditName('lb_openlv',false)
            lb_openlv.Text = Util.GetText(TextConfig.Type.ACTIVITY, "ACT_OverLevel",dailyInfo.lvLimit)
            lb_openlv.Visible = roleLv < dailyInfo.lvLimit

            local btn_go = node:FindChildByEditName('btn_go',false)
            btn_go.TouchClick = function()
                ActivityUtil.OnActivityClickGo(dailyData)
            end
            btn_go.Visible = (roleLv >= dailyInfo.lvLimit) and 
            (dailyData.MaxAttend == 0 and true or (dailyInfo.cur_num < dailyData.MaxAttend))  and (dailyInfo.isOver == 1)
            

            local lb_opentime = node:FindChildByEditName('lb_opentime',false)
            lb_opentime.Text = dailyInfo.openPeriod == nil and "" or dailyInfo.openPeriod
            lb_opentime.Visible = not btn_go.Visible


            local ib_complete = node:FindChildByEditName('ib_complete',false)
            ib_complete.Visible = (dailyData.MaxAttend ~= 0 and dailyInfo.cur_num >= dailyData.MaxAttend)

            local ib_over = node:FindChildByEditName('ib_over',false)
            ib_over.Visible = (roleLv >= dailyInfo.lvLimit and dailyInfo.isOver == 2)

            local img_zhezhao = node:FindChildByEditName('img_zhezhao',false)
            img_zhezhao.Visible = (roleLv < dailyInfo.lvLimit or 
                (dailyData.MaxAttend > 0 and dailyInfo.cur_num >= dailyData.MaxAttend or false) or (dailyInfo.isOver == 2)) 

            

            node.TouchClick = function()
              local node,menu = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIActivityDetail, 0) 
                menu.SetActivityInfo(dailyData,dailyInfo)
            end

            RefreshBtnGoEffect(btn_go,dailyInfo.id)
        end,
        function () end)
    else
        self.sp_list.Rows = item_counts
    end
end

local function UpdateDegreeInfo(degreeList,self)
    for i = 1,5 do
        local reward = self["cvs_reward"..i]
        local degreeInfo = GetDegreeInfoById(i,self)
        if degreeInfo == nil then
            reward.Visible = false
        else
            reward.Visible = true
            reward:FindChildByEditName('lb_num',false).Text = degreeInfo.needDegree
            reward:FindChildByEditName('ib_open',false).Visible = (degreeInfo.state == 2)
            reward:FindChildByEditName('ib_close',false).Visible = (degreeInfo.state == 0)
            
            
            
            
            
            reward:FindChildByEditName('ib_dynopen',false).Visible = (degreeInfo.state == 1)
            reward:FindChildByEditName('lb_bj_active',false).Visible = (degreeInfo.state == 1)
            reward.TouchClick = function()
                
                local vitdata = GlobalHooks.DB.Find('VitBonus',i)
                local itemList = {}
                local list = string.split(vitdata.ChestCode, ',')
                for k,v in ipairs(list) do
                    local item = string.split(v, ':')
                    itemList[k] = {code = item[1], groupCount = item[2]}
                end

                if degreeInfo.state == 1 then 
                    ActivityModel.GetDegreeRewardRequest(i,function (params)    
                        
                        
                        DailyActivityUpdate("",params,self)

                        Util.showUIEffect(self.sp_list,53)
                        local a = reward.UnityObject:GetComponent("DisplayNodeBehaviour");
                        a:StartCoroutine(GameGlobal.Instance.WaitForSeconds(1.5, function()
                            EventManager.Fire('Event.OnShowNewItems',{items = itemList})
                            Util.clearUIEffect(self.sp_list,53)
                        end ))
                    end)
                else
                    EventManager.Fire('Event.OnPreviewItems',{items = itemList})
                    
                end
            end
        end
    end
end

local function UpdateActivityInfo(param,self)
    
    self.dailyLst = {}
    UpdateDailyInfo(param.s2c_dailyLs,self)
    
    self.degreeLst = param.s2c_degreeLs
    UpdateDegreeInfo(param.s2c_degreeLs,self)
    self.lb_active_num.Text = param.s2c_totalDegree
    if param.s2c_weekIndex then
        ActivityModel.TodayWeekIndex = param.s2c_weekIndex
    end
end

function _M:OnEnter()
    local function DailyActivityPush(eventname,param)
        ActivityModel.DailyActivityRequest(function (params)
            UpdateActivityInfo(params,self)
        end)
    end
    self.DailyActivityPush = DailyActivityPush
    
    
    
    DailyActivityPush()
    EventManager.Subscribe("Event.Activity.dailyActivityPush", self.DailyActivityPush)

    local function SetActivityEffectId(eventname,params)
        ActivityId = tonumber(params.ActivityId)
        if self.dailyLst then
            local index = 1
            for i,v in ipairs(self.dailyLst) do
                if v.id == ActivityId then
                    index = i
                    break
                end
            end
            if index > 8 then
                DisplayUtil.lookAt(self.sp_list,index,true)
            end
        end
    end
    self.SetActivityEffectId = SetActivityEffectId
    EventManager.Subscribe('Event.Activity.PushEffectEvent',SetActivityEffectId)
end

function _M:OnExit()
    EventManager.Unsubscribe("Event.Activity.dailyActivityPush", self.DailyActivityPush)
    EventManager.Unsubscribe('Event.Activity.PushEffectEvent',self.SetActivityEffectId)
    ActivityId = nil
end

local ui_names = 
{
	{name = 'sp_list'},
    {name = 'cvs_activity'},
    {name = 'lb_active_num'},
    
    {name = 'btn_calendar'},
    {name = 'cvs_reward1'},
    {name = 'cvs_reward2'},
    {name = 'cvs_reward3'},
    {name = 'cvs_reward4'},
    {name = 'cvs_reward5'},
}

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
 
function DailyActivityUpdate(eventname,param,self)
    local node = self["cvs_reward"..param.id]
    node:FindChildByEditName('ib_open',false).Visible = (param.s2c_state == 2)
    node:FindChildByEditName('ib_close',false).Visible = (param.s2c_state == 0)
    
    
    
    
    
    
    node:FindChildByEditName('ib_dynopen',false).Visible = (param.s2c_state == 1)
    node:FindChildByEditName('lb_bj_active',false).Visible = (param.s2c_state == 1)

end

local function InitComponent(self)
    
    self.menu = XmdsUISystem.CreateFromFile('xmds_ui/activity/activity.gui.xml')
    initControls(self.menu,ui_names,self)
    self.size_node = self.cvs_activity.Size2D
    self.cvs_activity.Visible = false
    self.btn_calendar.TouchClick = function()
        local node,menu = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIActivityCalendar, 0) 
    end








    

    return self.menu
end

function _M.Create()
    local ret = {}
    setmetatable(ret,_M)
    local node = InitComponent(ret)
    return ret,node
end

return _M
