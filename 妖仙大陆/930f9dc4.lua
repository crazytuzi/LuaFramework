local _M = {}
_M.__index = _M

local ChatModel = require 'Zeus.Model.Chat'
local Util      = require "Zeus.Logic.Util"
local ChatUtil  = require "Zeus.UI.Chat.ChatUtil"

local self = {
    m_Root = nil,
}

local function ItemShow(index, data)
    
    local datastr = self.retStr[index].content
    
    local sdata = {}
    local msgData = {}
    msgData.Id = data.id
    msgData.TemplateId = data.static.Code
    msgData.Quality = data.static.Qcolor
    msgData.PlayerId = DataMgr.Instance.UserData.RoleID
    msgData.isIdentfied = data.static.isIdentfied
    if (data.equip ~= nil and data.static.isIdentfied == 1) or data.static.Code == "rewardEar" then
        msgData.needQuery = 1
    else
        msgData.needQuery = 0
    end
    print ("--------------- "..msgData.needQuery)
    sdata[1] = ChatUtil.CommonMsgDeal(msgData, data.static.Name, data.static.Qcolor, ChatUtil.LinkType.LinkTypeItem) 
    
    datastr = ChatUtil.HandleString(datastr, sdata)
    return datastr
end

local  function ShowPetCallback(index, str)
    
    
    if ChatModel.mSettingItems[index].OpenLv <= DataMgr.Instance.UserData:TryToGetIntAttribute(UserData.NotiFyStatus.LEVEL, 0) then
        if self.vip >= self.retStr[self.msgIndex].VipLv then
            ChatModel.chatMessageRequest(index, str, "", function (param)
                self = nil
                GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.CHAT, 'show_tips'))
            end)
            return true
        else
            local content = Util.GetText(TextConfig.Type.CHAT, 'need_vip') .. self.retStr[self.msgIndex].VipLv
            GameAlertManager.Instance:ShowNotify(content)
            return false
        end
    else
        GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.CHAT, 'lv_insufficient') .. ChatModel.mSettingItems[index].OpenLv)
    end
end

local function RandomCallBack( ... )
    
    self.msgIndex = self.msgIndex + 1
    if self.msgIndex > self.totalnum then
        self.msgIndex = 1
    end
    return ItemShow(self.msgIndex, self.curdata)
end

function _M.ShowItemClick(data)
    
    self = {}
    
    self.vip = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.VIP)
    self.curdata = data
    self.retStr = GlobalHooks.DB.Find('showMsg',{})
    local node,lua_obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIPetShowMsg, 0)
    lua_obj.callback = ShowPetCallback
    lua_obj.randomCallBack = RandomCallBack
    self.msgIndex = 1
    self.totalnum = #self.retStr
    lua_obj.InitShow(1)
end

return _M
