TextCode = {}
-- 文本模板 解析器
function TextCode.Handler(label, data, onClick, clickSelf)
    UIUtil.GetComponent(label, "LuaUIEventListener"):RegisterDelegate("OnClick",
        function() TextCode._OnClick(label, data, onClick, clickSelf) end )
--    local test = {"[url=item_301015]#item_301015#[/url]#06##06#"
--        ,"[url=tong_0]#tong_0#[/url]#06##08#"
--        ,"[url=team_20272]#team_20272#[/url]#06##09#"
--        ,"[url=ui_1]#item_301015#[/url]#06##10#"}
--    label.text = test[ math.random (1, #test)]
--    log("TextCode.Handler(" ..label.text)
    label.text = LanguageMgr.ApplyFormat(label.text, nil, true)
--    log("TextCode.Handler(" ..label.text)
end
function TextCode._OnClick(lbl, data, onClick, clickSelf)
    --log("TextCode._OnClick(" .. tostring(lbl.name).. tostring(data))
	if lbl ~= nil then
        local url = lbl:GetUrlAtCharacterIndex(lbl:GetCharacterIndexAtPosition(UICamera.lastWorldPosition, false))
		--local url = lbl:GetUrlAtPosition(UICamera.lastWorldPosition)
        local flg = true
		if url then
            --log("TextCode._OnClick(" .. url)
            local kv = string.split(url, "_")
            if #kv < 4 then flg = TextCode._Handler(kv[1], kv[2], data)
            else flg = TextCode._Handler(kv[1], kv[2], data, kv[3], kv[4])
            end
            
        end
        if flg and onClick then onClick(clickSelf) end
    end
end
function TextCode._Handler(k, v, data, v1, v2)
    --log("TextCode._Handler(" .. k .. "_" .. v)
    data = data or {}
    if k == "pid" then 
        if v == PlayerManager.playerId then return true end
        data.pid = v
        ModuleManager.SendNotification(MainUINotes.OPEN_PLAYER_MSG_PANEL, data)
        --[[if data.k then
            ModuleManager.SendNotification(MainUINotes.OPEN_PLAYER_MSG_PANEL, data)
            return false
        end
        ChatManager.GetPlayerInfo(v, function(data2) 
            data.k = data2.kind
            data.s_name = data2.name
            data.lv = data2.level
            ModuleManager.SendNotification(MainUINotes.OPEN_PLAYER_MSG_PANEL, data)
        end)--]]
    elseif k == "tong" then
        GuildProxy.ReqJoin(v)
    elseif k == "team" then
        local lev = PlayerManager.GetPlayerLevel()
        if (v1 and lev < tonumber(v1)) or (v2 and lev > tonumber(v2)) then
            MsgUtils.ShowTips(nil, nil, nil, LanguageMgr.Get("ChatManager/levNot"));
            return
        end
        FriendProxy.TryJoinTeamAsk(tonumber(v), data.s_name)
    elseif k == "item" then
        ProductCtrl.ShowProductTip(tonumber(v), ProductCtrl.TYPE_FROM_OTHER, 1)
    elseif k == "rpid" then
        GuildProxy.ReqShowHongBao(v)
    elseif k == "ui" then
        if v == '1' then --仙盟任务求助列表界面
            ModuleManager.SendNotification(GuildNotes.OPEN_GUILD_OTHER_PANEL, GuildNotes.OTHER.HELPLIST)
        end
    end
    return false
end
