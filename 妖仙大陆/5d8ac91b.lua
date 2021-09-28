local _M = {}
_M.__index = _M


local cjson                 = require "cjson"
local Util                  = require 'Zeus.Logic.Util'
local PlayerModel           = require 'Zeus.Model.Player'
local ChatUtil              = require "Zeus.UI.Chat.ChatUtil"

local self = {
    menu = nil,
    culindex = nil,
}











local function DealMsgTip(index)
    
    local msg = Util.GetText(TextConfig.Type.PK,'changeNotice')
    local sdata = {}
    sdata[1] = Util.GetText(TextConfig.Type.PK,'pkModel' .. index)
    msg = ChatUtil.HandleString(msg, sdata)
    
    return msg
end

local function OnClickClose(displayNode)
    
    if self.mParentIndex ~= (self.mLastIndex - 1) then
        local index = self.mLastIndex
        PlayerModel.ChangePkModelRequest(self.mLastIndex  - 1, function(params)
            
            
            GameAlertManager.Instance:ShowFloatingTips(DealMsgTip(index))
        end)
    end
    self.menu:Close()
    EventManager.Fire("Event.Menu.ClosePKSelectMenu",{closetype = "2"})
end

local function SetSelectIndex(index)
    
    if self.mLastIndex ~= nil then
        self[self.UIName2[self.mLastIndex]].Visible = false 
    end

    self.mLastIndex = index
    self[self.UIName2[index]].Visible = true 
    
end

local function SelectPKMenu(index)
    
    local allToTeam = false
    if index == 7 and DataMgr.Instance.TeamData.HasTeam then
        index = 5
        allToTeam = true
    end
    SetSelectIndex(index)
    OnClickClose(nil)
    if allToTeam then
        GameAlertManager.Instance:ShowFloatingTips(Util.GetText(TextConfig.Type.PK,'onlyTeam'))
    end
end

local function InitUI()
    
    local UIName = {
        "cvs_heping",
        "cvs_shane",
        "cvs_zhenying",
        "cvs_gonghui",
        "cvs_duiwu",
        "cvs_benfu", 
        "cvs_quanti",
    }

    self.UIName2 = {
        "ib_hpxuanzhong",
        "ib_sexuanzhong",
        "ib_zyxuanzhong",
        "ib_ghxuanzhong",
        "ib_dwxuanzhong",
        "ib_bfxuanzhong",
        "ib_qtxuanzhong",
    }

    local UIName3 = {
        "cvs_pkframe", 
    }

    for i = 1, #UIName3 do
        self[UIName3[i]] = self.menu:GetComponent(UIName3[i])
    end

    for i = 1, #UIName do
        self[self.UIName2[i]] = self.menu:GetComponent(self.UIName2[i])
        self[UIName[i]] = self.menu:GetComponent(UIName[i])
        self[UIName[i]].TouchClick = function( ... )
            
            SelectPKMenu(i)
        end
    end
end

local function OnEnter()
    
    local index = tonumber(self.menu.ExtParam)
    self.mParentIndex = index
    if index then
        SetSelectIndex(index + 1)
    end
end

local function InitCompnent()
    
    InitUI()

    HudManagerU.Instance:InitAnchorWithNode(self.cvs_pkframe, bit.bor(HudManagerU.HUD_LEFT, HudManagerU.HUD_TOP))
    LuaUIBinding.HZPointerEventHandler({node = self.menu, click = OnClickClose})

    self.menu:SubscribOnEnter(OnEnter)
    self.menu:SubscribOnDestory(function()
        self = nil
    end)
end

local function Init(tag,params)
	self.menu = LuaMenuU.Create("xmds_ui/hud/hud_pk.gui.xml", GlobalHooks.UITAG.GameUIPKSelectMenu)
    InitCompnent()
    self.menu.ShowType = UIShowType.Cover

	return self.menu
end

function _M.Create(tag,params)
	self = {}
	setmetatable(self, _M)
	local node = Init(tag, params)
	return self
end

return _M
