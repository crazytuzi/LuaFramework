
local Helper = require 'Zeus.Logic.Helper'
local Util   = require 'Zeus.Logic.Util'
local ItemModel = require 'Zeus.Model.Item'
local FunctionOpen = require 'Zeus.Model.FunctionOpen'
local _M = {}
_M.__index = _M

local function Close(self)
  self.menu:Close()  
end

local function OnEnter(self)

end


local function OnExit(self)

end

local function OnDestory(self)
  
end

local ui_names = 
{
    {name = 'cvs_bg'},
    {name = 'lb_tips'},
    {name = 'cvs_icon'},
    {name = 'sp_show'},
    {name = 'lb_openlv'},
    {name = 'btn_receive'},
    {name = 'btn_close',click = Close},
}



local function InitComponent(self,tag)
    
    self.menu = LuaMenuU.Create('xmds_ui/targetlv/targetlv_main.gui.xml',tag)
    Util.CreateHZUICompsTable(self.menu,ui_names,self)
    self.cvs_icon.Visible = false

  self.menu:SubscribOnExit(function ()
    OnExit(self)
  end)
  self.menu:SubscribOnEnter(function ()
    OnEnter(self)
  end)
  self.menu:SubscribOnDestory(function ()
    OnDestory(self)
  end)
  
  self.menu.mRoot.IsInteractive = true
    self.menu.mRoot.Enable = true
    self.menu.mRoot.EnableChildren = true
    LuaUIBinding.HZPointerEventHandler({node = self.menu.mRoot, click = function() self.menu:Close() end})
  
end


local function Create(tag)
  local ret = {}
  setmetatable(ret, _M)
  InitComponent(ret,tag)
  return ret
end



local function UpdateInfo(self,Id,haveNotGet)
    local lv = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.LEVEL)
    local guideInfo = GlobalHooks.DB.Find('Guide',{ID = Id})[1]
    print(PrintTable(guideInfo))
    self.lb_tips.Text = guideInfo.ShowTips or ""
    self.lb_openlv.Text = Util.GetText(TextConfig.Type.GUILD, "levelopen",guideInfo.CloseLv)

    if haveNotGet == 1 then
        self.lb_openlv.Visible = false
        self.btn_receive.Visible = true
    else
        self.lb_openlv.Visible = (lv ~= guideInfo.CloseLv)
        self.btn_receive.Visible = (lv == guideInfo.CloseLv)
    end
    
    self.btn_receive.event_PointerClick = function()
        FunctionOpen.ReceiveFunctionAwardRequest(guideInfo.ID,function(id)
        EventManager.Fire("Event.TeamQuestHud.GetTargetPrize",{Id = id})
      end)
    end
    
    Util.HZSetImage(self.cvs_bg,guideInfo.Banner,false,LayoutStyle.IMAGE_STYLE_BACK_4)

    local prizeData = string.split(guideInfo.Reward,';')
    local item_counts = #prizeData

    self.sp_show.Scrollable:ClearGrid()
    if self.sp_show.Rows <= 0 then
        self.sp_show.Visible = true
        local cs = self.cvs_icon.Size2D
        self.sp_show:Initialize(cs.x,cs.y,1,item_counts,self.cvs_icon,
        function (gx,gy,node)
            local prizeName = string.split(prizeData[gx+1],':')
            local static_data = ItemModel.GetItemStaticDataByCode(prizeName[1])  
            local item = Util.ShowItemShow(node, static_data.Icon, static_data.Qcolor, prizeName[2])
            Util.NormalItemShowTouchClick(item,prizeName[1],false)

            
            

        end,function () end)
    else
        self.sp_show.Rows = item_counts
    end 

end

local function OnShowGameUILevelTarget(ename,params)
    if params.id == -1 then
      GlobalHooks.CloseUI(GlobalHooks.UITAG.GameUILevelTarget)
      return
    end
    
    local menu,obj = GlobalHooks.FindUI(GlobalHooks.UITAG.GameUILevelTarget)
    if obj == nil then
      menu,obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUILevelTarget,0)
    end
    if params.id then
        UpdateInfo(obj,params.id,params.haveNotGet)
    end
end

local function initial()
    EventManager.Subscribe("Event.ShowGameUILevelTarget",OnShowGameUILevelTarget)
end

_M.initial = initial
_M.Create = Create
_M.Close  = Close


return _M
