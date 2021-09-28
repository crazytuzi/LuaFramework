local _M = { }
_M.__index = _M

local Util = require 'Zeus.Logic.Util'
local ActivityUtil = require 'Zeus.UI.XmasterActivity.ActivityUIUtil'
local BossFightModel        = require 'Zeus.Model.BossFight'
local indexTag = 0
local function GetLeftReflashTime(self,id)
    local leftTime = nil
    for _,v in pairs(self.illsionBossInfos) do
        if v.id == id then
            leftTime = v.nextRefreshTime
            break
        end
    end

    return leftTime
end

local function OnClickType(self)
    local bossData = self.datas[self.select_bossType.Type]
    local item_counts = #bossData
    self.sp_right.Scrollable:ClearGrid()
    if self.sp_right.Rows <= 0 then
        self.sp_right.Visible = true
        local cs = self.cvs_right.Size2D
        self.sp_right:Initialize(cs.x,cs.y,item_counts,1,self.cvs_right,
        function (gx,gy,node)
            local bossInfo = bossData[gy+1]
            local lb_name = node:FindChildByEditName('lb_name',false)
            local lb_level = node:FindChildByEditName('lb_level',false)
            local lb_llusion_name = node:FindChildByEditName('lb_llusion_name',false)
            local lb_refresh = node:FindChildByEditName('lb_refresh',false)
            local btn_go = node:FindChildByEditName('btn_go',false)
            local cvs_mappic = node:FindChildByEditName('cvs_mappic',false)
            local cvs_bosspic = node:FindChildByEditName('cvs_bosspic',false)

            lb_level.Text = self.select_bossType.Name
            lb_llusion_name.Text = bossInfo.MapName
            local monster = GlobalHooks.DB.Find('Monster',bossInfo.MonsterID)
            lb_name.Text = monster and monster.Name or Util.GetText(TextConfig.Type.ACTIVITY, "ACT_NotGetPZ")
            Util.HZSetImage(cvs_mappic, bossInfo.MapPicture,false,LayoutStyle.IMAGE_STYLE_BACK_4)
            Util.HZSetImage(cvs_bosspic, bossInfo.BossPicture,false,LayoutStyle.IMAGE_STYLE_BACK_4)
            
            local a = self.sp_right.UnityObject:GetComponent("DisplayNodeBehaviour");
            local function UpdateRefreshLabel()
                lb_refresh.Text = ActivityUtil.GetStrByLeftSecond(GetLeftReflashTime(self,bossInfo.ID))
                XmdsUISystem.Instance:StartCoroutine(GameGlobal.Instance.WaitForSeconds(1, function()
                UpdateRefreshLabel()
                
                end ))
            end
            UpdateRefreshLabel()

            btn_go.TouchClick = function ()
                if DataMgr.Instance.TeamData.HasTeam and not DataMgr.Instance.TeamData:IsLeader() and DataMgr.Instance.TeamData.TeamFollow == 1 then
                    GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.TEAM, "followCannotOperateTip"))
                    return
                end
                local point = string.split(bossInfo.MonPoint)
                if bossInfo.MapID == DataMgr.Instance.UserData.MapID then
                    DataMgr.Instance.UserData:Seek(bossInfo.MapID,point[1],point[2])
                    self.menu:Close()
                else
                    BossFightModel.EnterLllsionBossRequest(bossInfo.ID,function (params)
                        EventManager.Fire("Event.Quest.CancelAuto", {});
                    end)
                end
            end

            node.TouchClick = function ()
                
                local node,menu = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIActivityBossDetail, 0) 
                menu.SetBossInfo(bossInfo,GetLeftReflashTime(self,bossInfo.ID))
            end

        end,function () end)
    else
        self.sp_right.Rows = item_counts
    end 
end

local function FindTypeListItem(self,equip_id)
    local child_list = self.sp_left.Scrollable.Container:GetAllChild()
    local children = Util.List2Luatable(child_list)
    for _,v in ipairs(children) do
        if v.Name == tostring(equip_id) then
            return v
        end
    end
    return nil
end

local function InitTypeList(self)
    local select_tbt = nil
    local select_fun = nil
    local item_counts = #self.datas
    self.sp_left.Scrollable:ClearGrid()
    if self.sp_left.Rows <= 0 then
        self.sp_left.Visible = true
        local cs = self.cvs_left.Size2D
        self.sp_left:Initialize(cs.x,cs.y,item_counts,1,self.cvs_left,
        function (gx,gy,node)
            local typeNameMap = GlobalHooks.DB.Find('TypeName',gy + 1)
            
            if typeNameMap == nil then
                node.Visible = false
                return
            else
                node.Visible = true
            end

            local ib_choose = node:FindChildByEditName('ib_choose',false)
            local lb_infor = node:FindChildByEditName('lb_infor',false)
            lb_infor.Text = typeNameMap.Name

            local tbt_main = node:FindChildByEditName('tbt_deatil',false)
            tbt_main:SetBtnLockState(HZToggleButton.LockState.eLockSelect)  
            tbt_main.IsChecked = (self.select_bossType ~= nil and self.select_bossType.Type == typeNameMap.Type)
            local touchClick = function (sender)
                if sender.IsChecked then
                    if not typeNameMap then return end
                    if self.select_bossType then
                        local item_node = FindTypeListItem(self,self.select_bossType.Type)
                        if item_node then
                            tbt_main = item_node:FindChildByEditName('tbt_deatil',false)
                            tbt_main.IsChecked = false
                        end
                    end
                    self.select_bossType = typeNameMap  
                    OnClickType(self)
                end
            end
            tbt_main.TouchClick = touchClick
            node.Name = tostring(typeNameMap.Type)

            if self.select_bossType == nil then 
                if typeNameMap.Type == indexTag then
                    
                     select_tbt = tbt_main 
                    select_fun = touchClick
                    return
                end
                if gy ==  0 then
                    
                    select_tbt = tbt_main 
                    select_fun = touchClick
                end
            
            
            
            end

        end,function () end)
    else
        self.sp_left.Rows = item_counts
    end

    if select_tbt ~= nil then
        select_tbt:SetBtnLockState(HZToggleButton.LockState.eLockSelect)
        select_tbt.IsChecked = true
        select_fun(select_tbt)  
    end
    indexTag = nil
end

local function OnChangeTags( eventname, params)
    indexTag = params.tag
    
end

function _M:OnEnter()
    EventManager.Subscribe("Event.GoToYaoZu",OnChangeTags)
    if self.select_bossType == nil then
           BossFightModel.GetLllsionBossInfoRequest(function (params)
            self.illsionBossInfos = params.bossInfos 
            InitTypeList(self)
        end)
    else
        
    end
end

function _M:OnExit()
    EventManager.Unsubscribe("Event.GoToYaoZu",OnChangeTags)
end

local ui_names = 
{
	{name = 'sp_left'},
	{name = 'cvs_left'},
    {name = 'sp_right'},
    {name = 'cvs_right'},
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
 
local function InitComponent(self)
    
    self.menu = XmdsUISystem.CreateFromFile('xmds_ui/activity/lords.gui.xml')
    initControls(self.menu,ui_names,self)
    self.cvs_left.Visible = false
    self.cvs_right.Visible = false
    self.datas = {}

    local refreshMap = GlobalHooks.DB.Find('MonsterRefresh',{})
    self.datas = {}
    for i = 1,#refreshMap do
        if self.datas[refreshMap[i].Type] == nil  then
            self.datas[refreshMap[i].Type] = {}
            table.insert(self.datas[refreshMap[i].Type],refreshMap[i])
        else
            table.insert(self.datas[refreshMap[i].Type],refreshMap[i])
        end
    end
    for k,v in pairs(self.datas) do
        table.sort(v,function (a,b )
            return a.Sort < b.Sort
        end)
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
