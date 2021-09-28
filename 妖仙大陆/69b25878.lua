local _M = {}
_M.__index = _M


local ChatModel = require 'Zeus.Model.Chat'
local Util      = require "Zeus.Logic.Util"
local ChatUtil  = require "Zeus.UI.Chat.ChatUtil"
local PlayerModel           = require 'Zeus.Model.Player'
local PetModel              = require 'Zeus.Model.Pet'
local FubenUtil             = require "Zeus.UI.XmasterFuben.FubenUtil"
local ChatSend              = require "Zeus.UI.Chat.ChatSend"
local InteractiveMenu       = require "Zeus.UI.InteractiveMenu"
local ExchangeUtil          = require "Zeus.UI.ExchangeUtil"
local Team                  = require "Zeus.Model.Team"
local VSAPI                 = require "Zeus.Model.VS"

local function clickActionCbfunction(index, data, self)
    
    if index == 1 or index == 2 or index == 3 or index == 4 then             
        
        ChatModel.interactRequest(index, data.playerId, data.name, function(param)
                
                
                GameUtil.ShowAssertBulider("/res/effect/60000_ui/vfx_ui_huaban.assetbundles")

            end)
    end

    if self.m_SelectFriendBtn ~= nil then
        self.m_SelectFriendBtn.IsChecked = false
    end
end

local function InteractiveMenuCb(id, data, self)
    if id == 12 then
        
        if self.m_curChannel == 0 then
            local lb_tishi = Util.GetText(TextConfig.Type.CHAT, 'message1')
            GameAlertManager.Instance:ShowFloatingTips(lb_tishi)
        else
            local selplayer = {}
            selplayer.s2c_playerId = data.playerId
            selplayer.s2c_name = data.name
            selplayer.s2c_level = data.lv
            selplayer.s2c_pro = data.pro
            ChatSend.MakeAction(self, selplayer)
        end
    elseif id == 23 then
        
        local node,lua_obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIChatGift, 0, 1)
        
        lua_obj.clickActionCb = function(index)
            
            clickActionCbfunction(index, data, self)
        end
    end
    if self.m_SelectFriendBtn ~= nil then
        self.m_SelectFriendBtn.IsChecked = false
    end
end

function _M.HandleClicKPerson(displayNode, data, pos, self)
    local pt = displayNode:LocalToGlobal()
    local player_info1
    local type1
    if data.serverData ~= nil then
         player_info1={
            name=data.serverData.s2c_name, lv=data.serverData.s2c_level,
            playerId = data.s2c_playerId,
            pro = data.serverData.s2c_pro,
            activeMenuCb = function(id, data)
                
                InteractiveMenuCb(id, data, self)
            end,
        }   
    else
        player_info1={
            name=data.s2c_name, lv=data.s2c_level,
            playerId = data.s2c_playerId,
            pro = data.s2c_pro,
            activeMenuCb = function(id, data)
                
                InteractiveMenuCb(id, data, self)
            end,
        }   
    end

    if data.s2c_playerId ~= DataMgr.Instance.UserData.RoleID then
        if self.m_curChannel == ChatModel.ChannelState.Channel_union or self.m_curChannel == ChatModel.ChannelState.Channel_group then
            type1=InteractiveMenu.TYPE_CHAT_AT
        else
            type1=InteractiveMenu.TYPE_CHAT
        end

        local function fireShowInteractive()
            EventManager.Fire("Event.ShowInteractive", {
                type= type1,
                player_info=player_info1,
                x=pt.x,
                y=pt.y
            })
        end

        
        VSAPI.requestPlayerInfo(data.s2c_playerId, function(data)
            player_info1.guildName = data.guildName
            player_info1.upLv = data.upOrder
            fireShowInteractive()
        end,
        function()
            fireShowInteractive()
        end)
    
        
    end

end

local function HandleTeamMsg(data)
    print("-----------link---------------", data)
    FubenUtil.onTeamLinkClick(data)
end

local function HandleSendMapByIDXY(id, x, y, mapId, instanceId)
    
    local ret = GlobalHooks.DB.Find('Map', {MapID = mapId})
    local str 
    if ret ~= nil and #ret > 0 then
        if ret[1].AllowedTransfer == 1 then
            local itemName = ExchangeUtil.GetItemNameByCode(ret[1].CostItem)
            str = ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.MAP, "shifouchuansong")
            local data = {}
            data[1] = ret[1].Name
            str =  ChatUtil.HandleString(str, data)
            
            if itemName ~= nil then
                str = str .. "<br/>" .. ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.MAP, "xiaohao") .. itemName .. "*" .. ret[1].CostItemNum
                local vItem = DataMgr.Instance.UserData.RoleBag:MergerTemplateItem(ret[1].CostItem)
                local cur_num = (vItem and vItem.Num) or 0
                str = str .. Util.GetText(TextConfig.Type.MAP, "have", cur_num) .. ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.MAP, "vipnocost")
            end
        else
            GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.MAP, "nochuansong"))
            return
        end
    else
        str = Util.GetText(TextConfig.Type.FRIEND,'whetherdelivery')
    end
    
    local areaId = tonumber(id)
    
    if areaId ~= DataMgr.Instance.UserData.SceneId then
        GameAlertManager.Instance:ShowAlertDialog(
            AlertDialog.PRIORITY_NORMAL, 
            str,
            nil,
            nil,
            Util.GetText(TextConfig.Type.FRIEND,'delivery'),
            nil,
            function()
                PlayerModel.ChangeAreaXYRequest(mapId, x, y, instanceId, function(params)
                    
                    DataMgr.Instance.UserData:StartSeekAfterChangeScene(areaId, x, y)
                end)
            end,
            nil
        )
    else
        GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.MAP, 'mapxunlu'))
        DataMgr.Instance.UserData:Seek(areaId, x, y)
    end
end

local function HandleMonster(data)
    
    
    
end

local function HandlePetMsg(data)
    
    
    PetModel.getPetInfoRequest(data.id, data.roleid, function(params)
        local menu, ui = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIPetInfoDes, 0)
        ui.setPetInfo(params)
    end)
end

local function HandleSkillMsg(data, pos)
    
    
    local menu, ui = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIPetSkillInfo, 0)
    ui.SetPetInfo(data)
    ui.SetPetPos(pos)
end

function _M.HandleOnLinkClick(link, info, text, displayNode, playerId, pos, self, parenttype)
    if link == nil or link == "" then
        return
    end
    CommonUI.Sound.SoundManager.GetInstance():PlaySoundByKey("buttonClick")
    
    local msg = cjson.decode(link)
    if(msg.MsgType == nil) then
        msg.MsgType = msg.msgtype
    end
    if msg.MsgType == ChatUtil.LinkType.LinkTypeItem then
        local ItemModel = require 'Zeus.Model.Item'
        local detail = ItemModel.GetItemDetailByCode(msg.TemplateId) 
        if msg.needQuery == 1 then
            ItemModel.ChatEquipDetailRequest(msg.Id, function(params)
                
                
                if params ~= nil and params.s2c_data ~= nil then
                    ItemModel.SetDynamicAttrToItemDetail(detail,params.s2c_data)
                end
                if params ~= nil and params.s2c_data ~= nil and params.s2c_data.earDetail then
                    ItemModel.IsEar(detail,params.s2c_data)
                end
                EventManager.Fire('Event.ShowItemDetail',{data=detail}) 
            end)
        else
            EventManager.Fire('Event.ShowItemDetail',{data=detail}) 
        end
       
    elseif msg.MsgType == ChatUtil.LinkType.LinkTypePerson then    
        
        
        if parenttype == "baozang" then
            GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIVSPlayer, 0, msg.s2c_playerId)
        else
            _M.HandleClicKPerson(displayNode, msg, pos, self)
        end
    elseif msg.MsgType == ChatUtil.LinkType.LinkTypeSendPlace then
        
        local ok = ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.DEMUTATION, "ok_lua");
        local cancle = ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.DEMUTATION, "cancel_lua")  
        GameAlertManager.Instance:ShowAlertDialog(
            AlertDialog.PRIORITY_NORMAL, 
            Util.GetText(TextConfig.Type.FRIEND,'transfer_confirm'),
            ok,
            cancle,
            nil,
            function()
                FriendModel.changeAreaByPlayerIdRequest(msg.id, 1, function(data)
                
                end)
            end,
            nil
        )
    elseif msg.MsgType == ChatUtil.LinkType.LinkTypeTeamMsg then
        
        HandleTeamMsg(msg.data)
    elseif msg.MsgType == ChatUtil.LinkType.LinkTypeMapMsg then
        
        
        HandleSendMapByIDXY(msg.data.areaId, msg.data.targetX, msg.data.targetY, msg.data.mapId, msg.data.instanceId)
    elseif msg.MsgType == ChatUtil.LinkType.LinkTypeMonster then
        
        HandleMonster(msg.data)
    elseif msg.MsgType == ChatUtil.LinkType.LinkTypePet then
        
        HandlePetMsg(msg.data)
    elseif msg.MsgType == ChatUtil.LinkType.LinkTypeSkill then
        
        local curpos = displayNode:ScreenToLocalPoint2D(pos)
        
        HandleSkillMsg(msg.data, displayNode.UnityObject.transform.parent:TransformPoint(Vector3.New(displayNode.Transform.localPosition.x + curpos.x, displayNode.Transform.localPosition.y - curpos.y, displayNode.Transform.localPosition.z)))
    elseif msg.MsgType == ChatUtil.LinkType.LinkTypeRecruit then
        
        
        Team.RequestApplyTeamByTeamId(msg.data.teamId, function () end)

    elseif msg.MsgType == ChatUtil.LinkType.LinkType5v5Battle then
        print("LinkType5v5Battle", link)
        local node, luaobj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUI5V5Result, -1, msg.BattleId)
    else
        print("-----------link---------------", link)
    end
end

return _M
