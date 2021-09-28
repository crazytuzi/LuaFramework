function i3k_sbean.request_light_secret_sync_req()
    local data = i3k_sbean.light_secret_sync_req.new()
	i3k_game_send_str_cmd(data, "light_secret_sync_res")
end

function i3k_sbean.light_secret_sync_res.handler(bean)
    g_i3k_ui_mgr:OpenUI(eUIID_Dengmi)
	g_i3k_ui_mgr:RefreshUI(eUIID_Dengmi,bean)
end

function i3k_sbean.request_light_secret_answer_req(id,answer,callback)
    local data = i3k_sbean.light_secret_answer_req.new()
    data.id = id
    data.answer = answer
    data.callback = callback
	i3k_game_send_str_cmd(data, "light_secret_answer_res")
end

function i3k_sbean.light_secret_answer_res.handler(bean,req)
    if bean.ok > 0 then
        req.callback()
    else
        i3k_sbean.request_light_secret_sync_req()
    end
end

function i3k_sbean.request_light_secret_role_take_req(score,callback)
    local data = i3k_sbean.light_secret_role_take_req.new()
    data.score = score
    data.callback = callback
	i3k_game_send_str_cmd(data, "light_secret_role_take_res")
end

function i3k_sbean.light_secret_role_take_res.handler(bean,req)
    req.callback(bean)
end

function i3k_sbean.request_light_secret_world_take_req(score,callback)
    local data = i3k_sbean.light_secret_world_take_req.new()
    data.score = score
    data.callback = callback
	i3k_game_send_str_cmd(data, "light_secret_world_take_res")
end

function i3k_sbean.light_secret_world_take_res.handler(bean,req)
    req.callback(bean.ok)
end