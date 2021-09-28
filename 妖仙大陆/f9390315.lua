local _M = {}
_M.__index = _M

local Util  = require 'Zeus.Logic.Util'
local ItemModel = require 'Zeus.Model.Item'
local ActivityUtil = require 'Zeus.UI.XmasterActivity.ActivityUIUtil'
local BossFightModel        = require 'Zeus.Model.BossFight'
local self = {}


local function Clear3DAvatar()
    if nil ~= self.Model3DGameObj then
        GameObject.Destroy( self.Model3DGameObj )
        IconGenerator.instance:ReleaseTexture(self.Model3DAssetBundel)
        self.Model3DGameObj = nil;
        self.Model3DAssetBundel = nil;
    end
end

function _M.SetBossInfo(bossInfo,leftSeconds)
    
    self.boss = bossInfo
    local monster = GlobalHooks.DB.Find('Monster',bossInfo.MonsterID)
    self.lb_name.Text = monster and monster.Name or Util.GetText(TextConfig.Type.ACTIVITY, "ACT_NotGetPZ")
    
    local a = self.lb_refresh.UnityObject:GetComponent("DisplayNodeBehaviour");
    local function UpdateRefreshLabel()
        self.lb_refresh.Text = ActivityUtil.GetStrByLeftSecond(leftSeconds)
        a:StartCoroutine(GameGlobal.Instance.WaitForSeconds(1, function()
        UpdateRefreshLabel()
        
        end ))
    end
    UpdateRefreshLabel()
    self.tbx_desc.XmlText = bossInfo.BossDesc
    
    
    local item_counts = 0
    local dropdata
    if string.len(bossInfo.DropPre) > 0 then
        dropdata = string.split(bossInfo.DropPre,';')
        item_counts = #dropdata
    end
    self.sp_fall1.Scrollable:ClearGrid()
    if item_counts > 0 then
        local cs = self.cvs_single.Size2D
        self.sp_fall1:Initialize(cs.x,cs.y,1,item_counts,self.cvs_single,
        function (gx,gy,node)
            local dropName = dropdata[gx+1]
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
        self.sp_fall1.Rows = item_counts
    end 

    
    item_counts = 0
    local dropdata2
    if string.len(bossInfo.PartakeDropPre) > 0 then
        dropdata2 = string.split(bossInfo.PartakeDropPre,';')
        item_counts = #dropdata2
    end
    self.sp_fall2.Scrollable:ClearGrid()
    if item_counts > 0 then
        local cs = self.cvs_single.Size2D
        self.sp_fall2:Initialize(cs.x,cs.y,1,item_counts,self.cvs_single,
        function (gx,gy,node)
            local dropName = string.split(dropdata2[gx+1],':')
            local lb_name = node:FindChildByEditName('lb_name',false)
            local ib_icon = node:FindChildByEditName('ib_icon',false)
            local cvs_icon = node:FindChildByEditName('cvs_icon',false)

            local static_data = ItemModel.GetItemStaticDataByCode(dropName[1])  
            local item = Util.ShowItemShow(cvs_icon, static_data.Icon, static_data.Qcolor, dropName[2])
            Util.NormalItemShowTouchClick(item,dropName[1],false)

            lb_name.Text = static_data.Name
            lb_name.FontColorRGBA = Util.GetQualityColorRGBA(static_data.Qcolor)  
        end,function () end)
    else
        self.sp_fall2.Rows = item_counts
    end 
    
    
    
    
    
    
    
    
    
    
    

    
    
    
    
    
    
    

    
    
    

    
    
    
    
    
    
    
    
    
    

    local avaterstr = "/res/unit/Monster/"..bossInfo.Model..".assetbundles"
    
    self.Model3DGameObj, self.Model3DAssetBundel = GameUtil.Add3DModel(self.cvs_model, avaterstr, nil, "", 0, true)
    self.Model3DGameObj.transform.sizeDelta = UnityEngine.Vector2.New(self.cvs_model.Width, self.cvs_model.Height)
    IconGenerator.instance:SetModelScale(self.Model3DAssetBundel,  Vector3.one*bossInfo.ModelPercent)
    IconGenerator.instance:SetModelPos(self.Model3DAssetBundel, Vector3.New(0, bossInfo.ModelY, 13.3))
    IconGenerator.instance:SetCameraParam(self.Model3DAssetBundel, 0.1, 50, 5)
    IconGenerator.instance:SetRotate(self.Model3DAssetBundel, Vector3.New(0, 180, 0))
    
    
    
    

    self.cvs_model.event_PointerMove = function(displayNode, pos)
        if nil ~= self.Model3DAssetBundel then
            IconGenerator.instance:SetRotate(self.Model3DAssetBundel, -pos.delta.x)
            if pos.delta.x > 10 or pos.delta.x < -10 then
                self.isMove = true
            end
        end
    end

    self.btn_help.TouchClick = function (sender)
        self.cvs_intrduce.Visible = not self.cvs_intrduce.Visible
    end

    self.btn_intrduce.TouchClick = function (sender)
        self.cvs_intrduce.Visible = false
    end
end

local function InitUI()
    local UIName = {
    	"btn_close",
        "lb_name",
        "cvs_model",
        "lb_refresh",
        "lb_open",
        "btn_go",
        "sp_fall1",
        "sp_fall2",
        "tbx_desc",
        "cvs_single",
        "btn_help",
        "cvs_intrduce",
        "btn_intrduce",
        
        
        
        
    }
    for i = 1, #UIName do
        self[UIName[i]] = self.menu:GetComponent(UIName[i])
    end
    self.cvs_single.Visible = false
    
    
    
    
end

local function OnEnter()
    self.cvs_intrduce.Visible = false
end

local function OnExit()
    Clear3DAvatar()
end

local function InitComponent(tag,params)
    self.menu = LuaMenuU.Create('xmds_ui/activity/boss.gui.xml',tag)
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

    self.btn_go.TouchClick = function()
       if DataMgr.Instance.TeamData.HasTeam and not DataMgr.Instance.TeamData:IsLeader() and DataMgr.Instance.TeamData.TeamFollow == 1 then
            GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.TEAM, "followCannotOperateTip"))
            return
        end

        local point = string.split(self.boss.MonPoint)
        if self.boss.MapID == DataMgr.Instance.UserData.MapID then
            DataMgr.Instance.UserData:Seek(self.boss.MapID,point[1],point[2])
            self.menu:Close()
            GlobalHooks.CloseUI(GlobalHooks.UITAG.GameUIActivityHJBoss)
        else
            BossFightModel.EnterLllsionBossRequest(self.boss.ID,function (params)
                EventManager.Fire("Event.Quest.CancelAuto", {});
            end)
        end
    end
    return self.menu
end


local function Create(tag,params)
    self = {}
    setmetatable(self, _M)
    InitComponent(tag, params)
    return self
end

return {Create = Create}
