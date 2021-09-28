------------------------------------------------------
module(..., package.seeall)

local require = require

--师徒系统相关
local e_MASTER_OK	   =  0	--操作成功
local e_MASTER_FAIL	   = -1	--未知错误
local e_MASTER_APPRENTICE_LEVEL	= -2	--徒弟等级不符合条件
local e_MASTER_MASTER_LEVEL	= -3	--师父等级不符合条件
local e_MASTER_MASTER_EXIST	= -4	--已有师父
local e_MASTER_APPRENTICE_EXIST	= -5	--已有徒弟
local e_MASTER_TOO_MANY_APPRENTICE	= -6	--徒弟已满
local e_PROTOCOL_OP_MASTER_TOO_MANY_MSG	= -7	--消息已满
local e_MASTER_DISMISS_COOL = -8	--开除冷却期
local e_MASTER_BETRAY_COOL = -9	--叛师冷却期
local e_MASTER_APPLY_EXIST = -10 --申请已经存在
local e_MASTER_NOT_FOUND = -11 --目标不存在
local e_MASTER_REQ_GRADUATE_COOL = -12	--申请出师冷却期
local e_MASTER_GRADUATE_LEVEL = -13 --出师等级不符合条件
local e_MASTER_MASTER_NOT_EXIST	= -14	-- 没有师父
local e_MASTER_APPRENTICE_NOT_EXIST	= -15	--没有此徒弟
local e_MASTER_OFFER_NOT_EXIST= -16	--邀请已过期
local e_MASTER_INVALID_ANNOUNCE	= -17	--宣言含有非法字符

require("i3k_sbean")
------------------------------------------------------

local err_tips = {
	[e_MASTER_OK]	=  i3k_db_string[5011],
	[e_MASTER_FAIL]	= i3k_db_string[5012],
    [e_MASTER_APPRENTICE_LEVEL]	= i3k_db_string[5013],
	[e_MASTER_MASTER_LEVEL]   	= i3k_db_string[5014],
	[e_MASTER_MASTER_EXIST]	= i3k_db_string[5015],
	[e_MASTER_APPRENTICE_EXIST]	= i3k_db_string[5016],
	[e_MASTER_TOO_MANY_APPRENTICE]	= i3k_db_string[5031],
	[e_PROTOCOL_OP_MASTER_TOO_MANY_MSG]	= i3k_db_string[5017],
	[e_MASTER_DISMISS_COOL] = i3k_db_string[5018],
	[e_MASTER_BETRAY_COOL] = i3k_db_string[5019],
	[e_MASTER_APPLY_EXIST] = i3k_db_string[5032],
	[e_MASTER_NOT_FOUND] = i3k_db_string[5020],
	[e_MASTER_REQ_GRADUATE_COOL] = i3k_db_string[5021],
	[e_MASTER_GRADUATE_LEVEL] = i3k_db_string[5022],
	[e_MASTER_MASTER_NOT_EXIST] = i3k_db_string[5023],
    [e_MASTER_APPRENTICE_NOT_EXIST]	= i3k_db_string[5024],
	[e_MASTER_OFFER_NOT_EXIST] = i3k_db_string[5029],
    [e_MASTER_INVALID_ANNOUNCE]	= i3k_db_string[5030],
}

------------------主动发送的请求---------------------
	-- 获取师徒关系基本信息， reason - 调用原因，“MAIN_UI”主UI调用，“MSG_LIST”, 消息列表调用，“LOGIN“登陆调用
function i3k_sbean.master_req_baseinfo(reason, callbackFunc)
	local data = i3k_sbean.master_info_req.new()
	data.reason = reason
	data.callbackFunc = callbackFunc
	i3k_game_send_str_cmd(data,"master_info_res")
end
	-- 获取收徒宣言
function i3k_sbean.master_req_announce()
	local data = i3k_sbean.master_get_announce_req.new()
	i3k_game_send_str_cmd(data,"master_get_announce_res")
end
	-- 修改平台收徒宣言
function i3k_sbean.master_modify_announce(ann)
	local data = i3k_sbean.master_set_announce_req.new()
	data.content = ann
	i3k_game_send_str_cmd(data,"master_set_announce_res")
end
	-- 取消平台的收徒宣言
function i3k_sbean.master_cancel_recruit()
	local data = i3k_sbean.master_del_announce_req.new()
	i3k_game_send_str_cmd(data,"master_del_announce_res")
end
	--刷新师傅列表
function i3k_sbean.master_refresh_masters(index)
	local data=i3k_sbean.master_list_req.new()
	data.lastStartIndex = index
	i3k_game_send_str_cmd(data,"master_list_res")
end
	--拜师, reason="BAISHI_UI","HEADICON_UI",....
function i3k_sbean.master_request_master(roleid,reason)
	local data=i3k_sbean.master_apply_req.new()
	data.targetRoleID = roleid
	data.reason = reason
	i3k_game_send_str_cmd(data,"master_apply_res")
end
	--获取消息列表
function i3k_sbean.master_request_msglist()
	local data=i3k_sbean.master_msg_list_req.new()
	i3k_game_send_str_cmd(data,"master_msg_list_res")
end
	--回应是否同意拜师,reason = "MSGLIST_UI","HEADICON_UI"
function i3k_sbean.master_response_apply(apprtcId,bAgree,reason)
	local data = i3k_sbean.master_accept_apply_req.new()
	data.targetRoleID = apprtcId
	data.accept = bAgree
	data.reason = reason
	i3k_game_send_str_cmd(data,"master_accept_apply_res")
end
	--查询徒弟的活跃值
function i3k_sbean.master_get_apprtc_active()
	local data = i3k_sbean.master_list_apprentice_req.new()
	i3k_game_send_str_cmd(data,"master_list_apprentice_res")
end
	--查询徒弟出师进度
function i3k_sbean.master_require_grad_progress()
	local data = i3k_sbean.master_tasks_req.new()
	i3k_game_send_str_cmd(data,"master_tasks_res")
end
	--徒弟叛师
function i3k_sbean.master_apprtc_betray()
	local data = i3k_sbean.master_betray_req.new()
	i3k_game_send_str_cmd(data,"master_betray_res")
end
	--师傅开除徒弟
function i3k_sbean.master_mstr_dismiss(aptId)
	local data = i3k_sbean.master_dismiss_req.new()
	data.targetRoleID = aptId
	i3k_game_send_str_cmd(data,"master_dismiss_res")
end
	--师傅删除叛师消息
function i3k_sbean.master_remove_betray_msg(aptId)
	local data = i3k_sbean.master_remove_betray_msg_req.new()
	data.roleID = aptId
	i3k_game_send_str_cmd(data,"master_remove_betray_msg_res")
end
	--徒弟发送出师申请
function i3k_sbean.master_apprtc_apply_grad()
	local data = i3k_sbean.master_graduate_req.new()
	i3k_game_send_str_cmd(data,"master_graduate_res")
end
	--师傅是否同意徒弟出师
function i3k_sbean.master_agree_apprtc_grad(aptId,bAgree)
	local data = i3k_sbean.master_agree_graduate_req.new()
	data.targetRoleID = aptId
	data.agree = bAgree
	i3k_game_send_str_cmd(data,"master_agree_graduate_res")
end
	--发送师徒商店同步协议
function i3k_sbean.master_send_store_sync()
	local data = i3k_sbean.master_shopsync_req.new()
	i3k_game_send_str_cmd(data,"master_shopsync_res")
end
	--发送商店刷新请求
function i3k_sbean.master_shop_refresh(coinCnt, refreshTime, bUseDiamd, discount)
	local data = i3k_sbean.master_shoprefresh_req.new()
	data.times = refreshTime
	data.isSecondType = bUseDiamd
	data.coinCnt = coinCnt
	data.discount = discount
	i3k_game_send_str_cmd(data,"master_shoprefresh_res")
end
	-- 发送购买协议, idx - 商品在列表中索引， txtSucc - 购买成功的提示
function i3k_sbean.master_shop_buy_item(index, info, discount, discountCfg)
	local data = i3k_sbean.master_shopbuy_req.new()
	data.seq = index
	data.info = info
	data.discount = discount
	data.discountCfg = discountCfg
	i3k_game_send_str_cmd(data,"master_shopbuy_res")
end
	-- 发送收徒信息
function i3k_sbean.master_send_enroll_apt_request(aptId)
	local data = i3k_sbean.master_offer_req.new()
	data.targetRoleID = aptId
	i3k_game_send_str_cmd(data,"master_offer_res")
end
	-- 发送徒弟同意/拒绝师傅收徒邀请的协议
function i3k_sbean.master_apprtc_acccept_offer(masterId)
	local data = i3k_sbean.master_accept_offer_req.new()
	data.targetRoleID = masterId
	i3k_game_send_str_cmd(data,"master_accept_offer_res")
end
------------------处理返回结果-----------------------
-- 处理获取师徒关系基本信息的返回结果
function i3k_sbean.master_info_res.handler(res,req)
	if res.retCode ~=0 then
		local tips = err_tips[res.retCode]
		if tips==nil then
			tips = err_tips[e_MASTER_FAIL]
		end
		g_i3k_ui_mgr:PopupTipMessage(tips)
		return
	end
	g_i3k_game_context:SetMasterInfo(res)
	if req.callbackFunc then 
		req.callbackFunc()
		return 
	end 
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Master_shitu, "updateMasetrCardVisible")
	-- 根据发送协议的不同情形，判断是不是需要打开并更新UI，如果是上线之后同步的，就不要打开UI
	if req.reason==nil then
		print("---------- REASON is nil -------------\n")
		return
	elseif req.reason=="MAIN_UI" then
		-- 需要打开UI界面，不同情况打开不同UI
		local state=g_i3k_game_context:GetMasterRelationState()
		if state==e_State_Master_Unknown then
			return
		elseif state==e_State_BeApptc_NoMaster then
			g_i3k_logic:OpenBaishiUI()
		else
			g_i3k_logic:OpenMasterUI()
			-- 获取消息列表
			i3k_sbean.master_request_msglist()
		end
	elseif req.reason=="MSG_LIST" or req.reason=="DISMISS" or req.reason=="GRADUATE" then
		-- 刷新成员列表就可以了
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Master_shitu,"updateMemberUI")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Master_shitu,"updateRecruitUI") -- 收徒满了，会导致宣言失效
	elseif req.reason=="LOGIN" then
		-- 不用刷新UI
	end
end

-- 处理获得当前收徒宣言的返回结果
function i3k_sbean.master_get_announce_res.handler(res,req)
	if res.retCode ==0 then
		g_i3k_game_context:SetMasterAnnounce(res.content)
	end
end

-- 处理设置自己收徒宣言的返回结果
function i3k_sbean.master_set_announce_res.handler(res,req)
	if res.retCode ~=0 then
		local tips = err_tips[res.retCode]
		if tips==nil then
			tips = err_tips[e_MASTER_FAIL]
		end
		g_i3k_ui_mgr:PopupTipMessage(tips)
		return
	else
		local tips = err_tips[e_MASTER_OK]
		g_i3k_ui_mgr:PopupTipMessage(tips)
		local ann = res.content
		g_i3k_game_context:SetMasterAnnounce(ann)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Master_shitu,"modifyAnnounce",ann)
	end
end

-- 处理删除收徒宣言的返回结果
function i3k_sbean.master_del_announce_res.handler(res,req)
	local tips = err_tips[res.retCode]
	if tips==nil then
		tips = err_tips[e_MASTER_FAIL]
	end
	g_i3k_ui_mgr:PopupTipMessage(tips)	
	if res.retCode==0 then
		g_i3k_game_context:SetMasterAnnounce(nil)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Master_shitu,"modifyAnnounce",nil)
	end
end

-- 处理刷新师傅列表的返回结果
function i3k_sbean.master_list_res.handler(res,req)
	if res.retCode==0 then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Master_baishi,"updateMasterList",res)
	else
		local tips = err_tips[res.retCode]
		if tips==nil then
			tips = err_tips[e_MASTER_FAIL]
		end
		g_i3k_ui_mgr:PopupTipMessage(tips)
	end
end

-- 拜师申请回应信息
function i3k_sbean.master_apply_res.handler(res,req)
	local tips = err_tips[res.retCode]
	if tips==nil then
		tips = err_tips[e_MASTER_FAIL]
	end
	if res.retCode==0 then
		g_i3k_game_context:ApprtcApplyEnrollCoolDown(req.targetRoleID) --开始冷却
	end
	if req.reason=="BAISHI_UI" then
		g_i3k_ui_mgr:PopupTipMessage(tips)
		g_i3k_ui_mgr:CloseUI(eUIID_Master_mstrInfo)
	elseif req.reason=="HEADICON_UI" then
		if res.retCode==0 then
			g_i3k_ui_mgr:PopupTipMessage("已经成功发出拜师申请，请耐心等待回应。")
		else
			g_i3k_ui_mgr:PopupTipMessage(tips)
		end
	end
end

-- 师傅消息列表
function i3k_sbean.master_msg_list_res.handler(res,req)
	if res.retCode~=0 then
		local tips = err_tips[res.retCode]
		if tips==nil then
			tips = err_tips[e_MASTER_FAIL]
		end
		g_i3k_ui_mgr:PopupTipMessage(tips)
		return
	end
	g_i3k_game_context:SetMasterMsgList(res)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Master_shitu,"updateMasterMsgUI")
end

-- 师傅处理拜师消息的回应
function i3k_sbean.master_accept_apply_res.handler(res,req)
	local tips = err_tips[res.retCode]
	if tips==nil then
		tips = err_tips[e_MASTER_FAIL]
	end
	if req.reason=="MSGLIST_UI" then
		g_i3k_ui_mgr:PopupTipMessage(tips)
		if req.accept and res.retCode==0 then
			--更新成员列表
			i3k_sbean.master_req_baseinfo("MSG_LIST")
		end
	elseif req.reason=="HEADICON_UI" then
		if res.retCode==0 then
			if req.accept then
				g_i3k_ui_mgr:PopupTipMessage("成功接受徒弟的拜师申请。")
			else
				g_i3k_ui_mgr:PopupTipMessage("成功拒绝徒弟的拜师申请。")
			end
		end
	end
end

-- 处理查看徒弟活跃值的返回结果
function i3k_sbean.master_list_apprentice_res.handler(res,req)
	if res.retCode~=0 then
		local tips = err_tips[res.retCode]
		if tips==nil then
			tips = err_tips[e_MASTER_FAIL]
		end
		g_i3k_ui_mgr:PopupTipMessage(tips)
		return
	end
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Master_apprtcActv,"updateActivity",res.apprentices)
end

-- 处理徒弟出师进度的查询结果
function i3k_sbean.master_tasks_res.handler(res,req)
	if res.retCode~=0 then
		local tips = err_tips[res.retCode]
		if tips==nil then
			tips = err_tips[e_MASTER_FAIL]
		end
		g_i3k_ui_mgr:PopupTipMessage(tips)
		return
	end
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Master_chushi,"updateUI",res.tasks)
end

-- 处理徒弟叛师结果
function i3k_sbean.master_betray_res.handler(res,req)
	local tips = err_tips[res.retCode]
	if tips==nil then
		tips = err_tips[e_MASTER_FAIL]
	end
	g_i3k_ui_mgr:PopupTipMessage(tips)

	if res.retCode==0 then
		-- 更新UI
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Master_shitu,"onApprtcBetraySuccess")
		g_i3k_game_context:ApprtcBetrayCoolDown()
	end
end

-- 处理师傅开除徒弟的结果
function i3k_sbean.master_dismiss_res.handler(res,req)
	local tips = err_tips[res.retCode]
	if tips==nil then
		tips = err_tips[e_MASTER_FAIL]
	end
	g_i3k_ui_mgr:PopupTipMessage(tips)

	if res.retCode==0 then
		--更新成员列表
		i3k_sbean.master_req_baseinfo("DISMISS")
	end
end

-- 处理师傅删除叛师消息的返回结果
function i3k_sbean.master_remove_betray_msg_res.handler(res,req)
	local tips = err_tips[res.retCode]
	if tips==nil then
		tips = err_tips[e_MASTER_FAIL]
	end
	g_i3k_ui_mgr:PopupTipMessage(tips)
end
-- 处理徒弟拜师申请的返回结果
function i3k_sbean.master_graduate_res.handler(res,req)
	if res.retCode~=0 then
		local tips = err_tips[res.retCode]
		if tips==nil then
			tips = err_tips[e_MASTER_FAIL]
		end
		g_i3k_ui_mgr:PopupTipMessage(tips)
	else
		g_i3k_ui_mgr:PopupTipMessage("成功：出师申请已经发出，请耐心等待师傅批准。")
		g_i3k_game_context:ApprtcApplyGradCoolDown()
	end
end
-- 处理师傅是否同意徒弟出师的返回结果
function i3k_sbean.master_agree_graduate_res.handler(res,req)
	local tips = err_tips[res.retCode]
	if tips==nil then
		tips = err_tips[e_MASTER_FAIL]
	end
	g_i3k_ui_mgr:PopupTipMessage(tips)
	if res.retCode==0 and req.agree then
		-- 刷新成员列表
		i3k_sbean.master_req_baseinfo("GRADUATE")
	end
end
-- 处理师徒商店同步协议的返回结果
function i3k_sbean.master_shopsync_res.handler(res,req)
	g_i3k_game_context:SetMasterPoint(res.currency)
	if res.info == nil then
		return
	end
	g_i3k_ui_mgr:OpenUI(eUIID_PersonShop)
	g_i3k_ui_mgr:RefreshUI(eUIID_PersonShop, res.info, g_SHOP_TYPE_MASTER, res.discount)
end
-- 处理师徒商店刷新的返回结果
function i3k_sbean.master_shoprefresh_res.handler(res,req)
	local shopinfo = res.info
	if shopinfo then
		if req.isSecondType > 0 then
			moneytype = g_BASE_ITEM_DIAMOND
		else
			moneytype = g_BASE_ITEM_MASTER_POINT
		end
		g_i3k_game_context:UseCommonItem(moneytype, req.coinCnt, AT_USER_REFRESH_SHOP)
		-- 更新界面
		g_i3k_ui_mgr:RefreshUI(eUIID_PersonShop, res.info, g_SHOP_TYPE_MASTER, req.discount)
	else
		local tips = string.format("%s", "刷新失败，请重试")
		g_i3k_ui_mgr:PopupTipMessage(tips)
	end
end
-- 出师师徒商店购买的返回结果
function i3k_sbean.master_shopbuy_res.handler(res, req)
	-- 提示结果
	if res.ok > 0 then
		local info = req.info
		local index = req.seq
		local shopItem = i3k_db_master_store.item_data[info.goods[index].id]
		local tips = i3k_get_string(189, shopItem.itemName.."*"..shopItem.itemCount)
		info.goods[index].buyTimes = 1
		local count = req.discount > 0 and (shopItem.moneyCount * req.discount / 10) or shopItem.moneyCount
		g_i3k_game_context:UseBaseItem(g_BASE_ITEM_MASTER_POINT, math.ceil(count), AT_BUY_SHOP_GOOGS)
		g_i3k_ui_mgr:RefreshUI(eUIID_PersonShop, info, g_SHOP_TYPE_MASTER, req.discountCfg)
		g_i3k_ui_mgr:PopupTipMessage(tips)
		DCItem.buy(shopItem.itemId,g_i3k_db.i3k_db_get_common_item_is_free_type(shopItem.itemId),shopItem.itemCount, shopItem.moneyCount * req.discount, shopItem.moneyType, AT_BUY_SHOP_GOOGS)
	elseif res.ok == -1 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(50065))
	else
		g_i3k_ui_mgr:PopupTipMessage("购买失败")
	end
end
-- 处理服务器推送来的师徒摘要信息，摘要信息仅用于判断头像菜单当面拜师
function i3k_sbean.master_brief_info_notice.handler(res,req)
	g_i3k_game_context:SetMasterBriefInfo(res)
end
-- 处理服务器推送来的拜师申请消息
function i3k_sbean.master_apply_notice.handler(bean)
	--TODO: 判断当前界面，是否适合弹出消息
	-- 弹出界面
	local role = bean.apprentice.overview
	local desc = i3k_get_string(5001,role.name)
	local callback = function(bOK)
		if bOK then
			-- 同意拜师
			--i3k_sbean.master_response_apply(role.id,true,"HEADICON_UI")
			i3k_sbean.master_response_apply(role.id,true,"MSGLIST_UI") -- 师徒界面有可能开着，所以按照msglist_ui逻辑处理
		else
			-- 拒绝拜师
			i3k_sbean.master_response_apply(role.id,false,"HEADICON_UI")
		end
	end
	g_i3k_ui_mgr:ShowCustomMessageBox2("接受","拒绝",desc, callback)
end
--- 处理师傅发送的当面收徒申请的回应
function i3k_sbean.master_offer_res.handler(res,req)
	if res.retCode==0 then
		g_i3k_ui_mgr:PopupTipMessage("成功向徒弟发送收徒邀请。")
	else
		local tips = err_tips[res.retCode]
		if tips==nil then
			tips = err_tips[e_MASTER_FAIL]
		end
		g_i3k_ui_mgr:PopupTipMessage(tips)
	end
end
-- 徒弟处理师傅发来的当面收徒申请
function i3k_sbean.master_offer_notice.handler(bean)
	--弹出消息
	local master = bean.master.overview
	local desc = string.format("%s想收您为徒，是否同意？",master.name)
	local callback = function(bOK)
		if bOK then
			-- 同意当徒弟
			i3k_sbean.master_apprtc_acccept_offer(master.id)
		else
			-- 拒绝当徒弟
		end
	end
	g_i3k_ui_mgr:ShowCustomMessageBox2("同意","拒绝",desc, callback)

end
-- 师徒收到徒弟接受邀请的通知
function i3k_sbean.master_accept_offer_notice.handler(bean)
	-- 弹出消息
	local str=string.format("%s接受了您的收徒邀请。",bean.appName)
	g_i3k_ui_mgr:PopupTipMessage(str)
end
-- 处理徒弟接受师傅收徒邀请的返回结果
function i3k_sbean.master_accept_offer_res.handler(res,req)
	local tips = err_tips[res.retCode]
	if tips==nil then
		tips = err_tips[e_MASTER_FAIL]
	end
	g_i3k_ui_mgr:PopupTipMessage(tips)
end
--桃李证修改宣言
function i3k_sbean.master_card_change_declaration(declaration)
	local data = i3k_sbean.master_card_change_declaration_req.new()
	data.declaration = declaration
	i3k_game_send_str_cmd(data, "master_card_change_declaration_res")
end
function i3k_sbean.master_card_change_declaration_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_MasterCard, "setDeclaration", req.declaration)
		local consume = i3k_db_master_cfg.cfg.modify_announce
		g_i3k_game_context:UseCommonItem(consume.id, consume.count)
		g_i3k_ui_mgr:CloseUI(eUIID_MasterCardEdit)
	elseif res.ok == -404 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1566))
	elseif res.ok == -100 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17191))
	end
end
--桃李证点赞
function i3k_sbean.master_card_sign(masterId)
	local data = i3k_sbean.master_card_sign_req.new()
	data.masterId = masterId
	i3k_game_send_str_cmd(data, "master_card_sign_res")
end
function i3k_sbean.master_card_sign_res.handler(res, req)
	if res.ok > 0 then
		local consume = i3k_db_master_cfg.cfg.likeConsume
		g_i3k_game_context:UseCommonItem(consume.id, consume.count)
		i3k_sbean.master_card_sync(req.masterId, true)
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16908))
	end
end
--桃李证同步
function i3k_sbean.master_card_sync(masterId, fromShare)
	local data = i3k_sbean.master_card_sync_req.new()
	data.masterId = masterId
	data.fromShare = fromShare
	i3k_game_send_str_cmd(data, "master_card_sync_res")
end
function i3k_sbean.master_card_sync_res.handler(res, req)
	--res.overview
	g_i3k_ui_mgr:OpenUI(eUIID_MasterCard)
	g_i3k_ui_mgr:RefreshUI(eUIID_MasterCard, res.overview, req.fromShare)
end
