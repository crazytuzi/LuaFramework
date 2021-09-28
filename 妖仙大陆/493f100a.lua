local _M = {}
_M.__index = _M
local Util                  = require "Zeus.Logic.Util"
local ChatUtil              = require "Zeus.UI.Chat.ChatUtil"
local ExchangeUtil          = require "Zeus.UI.ExchangeUtil"
local MapModel              = require 'Zeus.Model.Map'
local SceneMapUtil          = require "Zeus.UI.XmasterMap.SceneMapUtil"
local TeamModel             = require "Zeus.Model.Team"
local InteractiveMenu       = require "Zeus.UI.InteractiveMenu"

local stateColor = {
    "0xf43a1cff",
    "0xfffd5fff",
    "0x00d600ff",
}

local columns = 2


local function InitItemUI(ui, node)
    
    local UIName = {
        "btn_single",
        "lb_maplistname",
        "lb_zhuangtai",
        "lb_quyu",
    }
    for i = 1, #UIName do
        ui[UIName[i]] = node:FindChildByEditName(UIName[i], true)
    end
end

local function FindSceneAndDeal(sceneId, self, cb)
    
    if self.m_Items ~= nil then
        for i = 1, #self.m_Items do
            local data = self.m_Items[i]
            if data.MapID == sceneId then
                SceneMapUtil.OnMapClick(data.MapID, data, cb)
            end
        end
    end
end

local function ShowPreviewMap(data,self)
    local showGoBtn = true
    if data == nil or data.MapID == DataMgr.Instance.UserData.SceneId then
        showGoBtn = false
    else
        local mapDetail = GlobalHooks.DB.Find("Map", data.MapID)
        if mapDetail and mapDetail.SceneSmallMap ~= nil then
            Util.HZSetImage(self.cvs_newmap, "dynamic_n/map/scenemap/" .. mapDetail.SceneSmallMap .. ".png", false)
        else
            
            GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.MAP, "maperror"))
        end
        self.btn_go.TouchClick = function()
            SceneMapUtil.OnMapClick(data.MapID, data, function(changetype)
                if not GameSceneMgr.Instance.BattleRun.BattleClient == nil then
                    GameSceneMgr.Instance.BattleRun.BattleClient:StopSeek()
                end
                DataMgr.Instance.QuestManager.autoControl.AutoQuest = nil;
                DataMgr.Instance.UserData:StopSeek()
                EventManager.Fire("Event.Delivery.Close", { });
                
                if changetype ~= nil then
                    DataMgr.Instance.UserData:StartSeek(data.MapID, "born", 0, "")
                end
            end )
        end
    end
    self.cvs_newmap.Visible = showGoBtn
end

local function InitItemData(ui, data, self)
    
    ui.lb_maplistname.Text = data.MapName
    ui.lb_quyu.Text = data.MapTag
    
    ui.btn_single.TouchClick = function( ... )
        
        ShowPreviewMap(data,self)
    end
    if data.state == 1 then
        ui.lb_zhuangtai.Text = Util.GetText(TextConfig.Type.MAP,'now_map')   
        ui.lb_zhuangtai.FontColorRGBA = stateColor[2]
    elseif data.state == 2 then
        
        ui.lb_zhuangtai.Text = data.ret[1].ReqLevel .. Util.GetText(TextConfig.Type.MAP,'lv') 
        ui.lb_zhuangtai.FontColorRGBA = stateColor[3]
    elseif data.state == 3 then           
        ui.lb_zhuangtai.Text = data.ret[1].ReqLevel .. Util.GetText(TextConfig.Type.MAP,'lv')  
        ui.lb_zhuangtai.FontColorRGBA = stateColor[1]
    elseif data.state == 4 then
        local search_t = {UpOrder = data.ret[1].ReqUpLevel}
        local ret = GlobalHooks.DB.Find('UpLevel',search_t)
        if ret ~= nil and #ret > 0 then
            ui.lb_zhuangtai.Text = ret[1].UpName
            data.ret[1].UpName = ret[1].UpName
            ui.lb_zhuangtai.FontColorRGBA = stateColor[1]
            ui.lb_zhuangtai.Visible = true
        else
            ui.lb_zhuangtai.Visible = false
        end  
    elseif data.state == 5 then  
        ui.lb_zhuangtai.Text = Util.GetText(TextConfig.Type.MAP,'no_open')  
        ui.lb_zhuangtai.FontColorRGBA = stateColor[1]
    end
end

local function RefreshItem(x, y, node, self)
    local index = y * columns + x
    local ui = {}
    if index >= #self.m_Items then
        node.Visible = false
        return
    end
    node.Visible = true
    local data = self.m_Items[index + 1]
    node.UserTag = index
    InitItemUI(ui, node)
    InitItemData(ui, data, self)
end

local function InitItem(node, self)
    
end

local function InitRankList(self)
    local rows = 1
    if self.m_Items == nil then
        self.m_Items = {}
        rows = 0
    else
        if (#self.m_Items % columns) ~= 0 then
            rows = math.ceil(#self.m_Items/columns) + 1
        else
            rows = math.ceil(#self.m_Items/columns)
        end
    end

    self.sp_namelist:Initialize(self.cvs_single.Width, self.cvs_single.Height + 10,  rows, columns, self.cvs_single, 
        LuaUIBinding.HZScrollPanUpdateHandler(function(x, y, node)
            
            
            RefreshItem(x, y, node, self)
        end), 
        LuaUIBinding.HZTrusteeshipChildInit(function(node)
            
            InitItem(node, self)
        end))
end

local function InitData(self)
    self.m_Items = GlobalHooks.DB.Find('WorldZone',{Chirdmap = 0})
    self.level = tonumber(DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.LEVEL) or 0)
    self.upLv = tonumber(DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.UPLEVEL) or 0)
    for i = 1, #self.m_Items do
        local search_t = {MapID= tonumber(self.m_Items[i].MapID)}
        self.m_Items[i].ret = GlobalHooks.DB.Find('Map.NormalMap',search_t)
        if self.m_Items[i].ret ~= nil and #self.m_Items[i].ret > 0 and self.m_Items[i].ret[1].AllowedTransfer == 1 then
            if DataMgr.Instance.UserData.SceneId == tonumber(self.m_Items[i].MapID) then
                self.m_Items[i].state = 1 
            else
                
                
                if self.level < self.m_Items[i].ret[1].ReqLevel then
                    self.m_Items[i].state = 3   
                elseif self.upLv < self.m_Items[i].ret[1].ReqUpLevel then
                    self.m_Items[i].state = 4   
                else
                    self.m_Items[i].state = 2   
                end
            end
        else
            self.m_Items[i].state = 5   
        end
    end

    table.sort( self.m_Items, function(aa, bb)
        
        if aa.MapList < bb.MapList then
            return true
        else
            return false
        end
    end)
end

local function RefreshNearPlayerItem(x, y, node, self)
    local index = y + x
    local ui = {}
    if index >= #self.m_NearPlayerItems then
        node.Visible = false
        return
    end
    node.Visible = true
    local data = self.m_NearPlayerItems[index + 1]
    node.UserTag = index
    local proColor = GameUtil.GetProColor(data.pro)
    MenuBaseU.SetLabelText(node, "lb_name", data.name, proColor, 0)

    local lvText = Util.GetText(TextConfig.Type.PUBLICCFG, 'Lv.n', data.level) 
    MenuBaseU.SetLabelText(node, "lb_lv", lvText, 0, 0)
    
    
    
    
    
    
    

    MenuBaseU.SetLabelText(node, "lb_pro", PublicConst.GetProName(data.pro), proColor, 0)
    MenuBaseU.SetLabelText(node, "lb_line", tostring(GameSceneMgr.Instance.SceneLineIndex)..Util.GetText(TextConfig.Type.ATTRIBUTE, 144), 0, 0)
end

local function InitNearPlayerList(self)
    if self.m_NearPlayerItems == nil then
        self.m_NearPlayerItems = {}
    end

    if #self.m_NearPlayerItems == 0 then 
        self.ib_noman.Visible = true
    end
    self.sp_namelist:Initialize(self.cvs_details.Width, self.cvs_details.Height + 10,  #self.m_NearPlayerItems, 1, self.cvs_details, 
        LuaUIBinding.HZScrollPanUpdateHandler(function(x, y, node)
            
            
            RefreshNearPlayerItem(x, y, node, self)
            
        end), 
        LuaUIBinding.HZTrusteeshipChildInit(function(node)
            
            
            local btn_single = node:FindChildByEditName("btn_single", true)
            btn_single.TouchClick = function ( ... )
                
                local index = node.UserTag
                local data = self.m_NearPlayerItems[index + 1]
                local fromType = InteractiveMenu.SOCIAL_COMMON
                local job = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.GUILDJOB)
                if job == 1 or job == 2 then
                    fromType = InteractiveMenu.SOCIAL_COMMON_GUILDMASTER
                end
                
                EventManager.Fire("Event.ShowInteractive", {
                    type=fromType,
                    player_info={
                    name=data.name, lv=data.level,
                    upLv = data.upLevel,
                    guildName = data.guildName,
                    playerId = data.id,
                    pro = data.pro,
                    activeMenuCb = nil,
                    },
                })
            end
        end))
end

local function InitNpcUI(ui, node)
    
    local UIName = {
        "lb_name",
        "lb_gongneng",
        "btn_single",
    }
    for i = 1, #UIName do
        ui[UIName[i]] = node:FindChildByEditName(UIName[i], true)
    end
end


local function InitNpcList(self)
    local rows = 1
    self.npcData = GlobalHooks.DB.Find('NpcList', {MapID = DataMgr.Instance.UserData.SceneId})

    rows = #self.npcData
    self.sp_namelist:Initialize(self.cvs_npc.Width, self.cvs_npc.Height + 10,  rows, 1, self.cvs_npc, 
        function(x, y, node)
            
            local index = y + x
            
            local ui = {}
            if index >= #self.npcData then
                node.Visible = false
                return
            end
            node.Visible = true
            local data = self.npcData[index + 1]
            InitNpcUI(ui, node)
            ui.lb_name.Text = data.Name
            ui.lb_gongneng.Text = data.Title
            ui.btn_single.TouchClick = function( ... )
                DataMgr.Instance.UserData:StartSeek(DataMgr.Instance.UserData.SceneId, data.NpcID, 0, "")
            end
        end, 
        nil)
end


local function OnSwitch(sender, self)
    ShowPreviewMap(nil,self)
    self.ib_noman.Visible = false
    if self.UIName[1] == sender.EditName then
        InitRankList(self)
    elseif self.UIName[2] == sender.EditName then
        TeamModel.RequestNearPlayers(function(data)
            
            self.m_NearPlayerItems = data.s2c_players
            InitNearPlayerList(self)
        end)
    else
        InitNpcList(self)
    end

end

local function InitShow(opentype, self)
    Util.InitMultiToggleButton(function (sender)
      OnSwitch(sender, self)
    end,self[self.UIName[opentype]],{self[self.UIName[1]],self[self.UIName[2]],self[self.UIName[3]]})
end

local function InitCompontent(self)
    self.cvs_single.Visible = false
    self.cvs_details.Visible = false
    self.cvs_npc.Visible = false
end

local function InitUI(ui, node)
    local UIName = {
        "cvs_single",
        "sp_namelist",
        "cvs_npc",
        "tbt_kuaijiechuansong",
        "tbt_fujinwanjia",
        "tbt_fujinnpc",
        "cvs_details",
        "ib_noman",
        "cvs_newmap",
        "btn_go",
    }

    ui.UIName = {
        "tbt_kuaijiechuansong",
        "tbt_fujinwanjia",
        "tbt_fujinnpc",
    }

    for i = 1, #UIName do
        ui[UIName[i]] = node:FindChildByEditName(UIName[i], true)
    end
end

function _M.OnClickByScene(sceneId, self, cb)
    
    FindSceneAndDeal(sceneId, self.sceneMapQuickdelivery, cb)
end

function _M.SetNpcData(self, data)
    
    
    if self.sceneMapQuickdelivery ~= nil then
        self.sceneMapQuickdelivery.npcData = data
    end
end

function _M.Init(self, node)
    self.sceneMapQuickdelivery = {}
    InitUI(self.sceneMapQuickdelivery, node)
    InitCompontent(self.sceneMapQuickdelivery)
end

function _M.OnEnter(self)
    
    
    
    
    
    
    InitData(self.sceneMapQuickdelivery)
    InitShow(1, self.sceneMapQuickdelivery)
end

function _M.OnExit(self)
    
    
end

return _M
