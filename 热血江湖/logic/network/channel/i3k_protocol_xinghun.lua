-- 星魂引星
function i3k_sbean.request_star_spirit_operate_req(muti)
    local data = i3k_sbean.star_spirit_operate_req.new()
	data.muti = muti
	i3k_game_send_str_cmd(data,"star_spirit_operate_res")
end

function i3k_sbean.star_spirit_operate_res.handler(bean,req)
    --<field name="ok" type="int32"/>
    --<field name="addExp" type="map[int32, int32]"/>
    if bean.ok == 1 then
        g_i3k_game_context:addXingHunSubsStarExp(bean.addExp)
        local guideStarConfig
        if req.muti == 1 then
            guideStarConfig = i3k_db_chuanjiabao.cfg.continueConsumes
        else
            guideStarConfig = i3k_db_chuanjiabao.cfg.consumes
        end
        for k, v in ipairs(guideStarConfig) do
            g_i3k_game_context:UseCommonItem(v.id,v.count, AT_STAR_SPIRIT_OPERATE)
        end
        g_i3k_ui_mgr:RefreshUI(eUIID_XingHun)
    end
end

-- 星魂升阶
function i3k_sbean.request_star_spirit_uprank_req(rank, consumes)
    local data = i3k_sbean.star_spirit_uprank_req.new()
	data.rank = rank
    data.consumes = consumes
	i3k_game_send_str_cmd(data,"star_spirit_uprank_res")
end

function i3k_sbean.star_spirit_uprank_res.handler(bean, req)
    if bean.ok > 0 then
        for _, v in pairs(req.consumes) do
            g_i3k_game_context:UseCommonItem(v.id, v.count, AT_STAR_SPIRIT_UPRANK)
        end
        --重置星魂红点
        g_i3k_game_context:resetXinghunRedPoint(true)
        g_i3k_ui_mgr:CloseUI(eUIID_XingHunUpStage)
        g_i3k_ui_mgr:PopupTipMessage("升阶成功")
        g_i3k_game_context:addXingHunStage()
        g_i3k_ui_mgr:RefreshUI(eUIID_XingHun)
    else
        g_i3k_ui_mgr:PopupTipMessage("升阶失败")
    end
end

-- 星魂主星属性推送
function i3k_sbean.main_star_prop_push.handler(bean)
    g_i3k_game_context:UpdateXinHunMainStarLvl()
    g_i3k_game_context:SetXinHunMainStarProps(bean.props)
    g_i3k_ui_mgr:RefreshUI(eUIID_OpenArtufact1)
    g_i3k_ui_mgr:InvokeUIFunction(eUIID_XingHun, "playUnlockMainStarAni")
    g_i3k_ui_mgr:RefreshUI(eUIID_XingHun)
end

-- 星魂属性洗练
function i3k_sbean.request_main_star_refresh_req(consumes)
    local data = i3k_sbean.main_star_refresh_req.new()
    data.consumes = consumes
    i3k_game_send_str_cmd(data,"main_star_refresh_res")
end

function i3k_sbean.main_star_refresh_res.handler(bean, req)
    if bean.ok > 0 then
        g_i3k_game_context:SetXinHunMainStarTmpProps(bean.props)

        for _, v in pairs(req.consumes) do
            g_i3k_game_context:UseCommonItem(v.id, v.count, AT_MAIN_STAR_REFRESH)
        end
        g_i3k_ui_mgr:RefreshUI(eUIID_XingHunMainStarPractice)
        g_i3k_ui_mgr:PopupTipMessage("主星洗炼成功")
    else
        g_i3k_ui_mgr:PopupTipMessage("主星洗炼失败")
    end
end

-- 星魂属性保存
function i3k_sbean.request_main_star_save_req(props)
    local data = i3k_sbean.main_star_save_req.new()
    data.props = props
    i3k_game_send_str_cmd(data,"main_star_save_res")
end

function i3k_sbean.main_star_save_res.handler(bean, req)
    if bean.ok > 0 then
        g_i3k_game_context:SetXinHunMainStarTmpProps({})
        g_i3k_game_context:SetXinHunMainStarProps(req.props)
        g_i3k_ui_mgr:RefreshUI(eUIID_XingHunMainStarPractice)
        g_i3k_ui_mgr:RefreshUI(eUIID_OpenArtufact1)
        g_i3k_ui_mgr:PopupTipMessage("洗炼结果保存成功")
    else
        g_i3k_ui_mgr:PopupTipMessage("洗炼结果保存失败")
    end
end
