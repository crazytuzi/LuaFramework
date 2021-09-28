------------------------------------------------------
module(..., package.seeall)

local require = require

require("i3k_sbean")

--------------------------------------------------------
--历练系统登入时同步信息
function i3k_sbean.role_expcoin.handler(bean, res)
	if bean then
		--self.curExpCoin:		int32	
		--self.books:		map[int32, int32]	
		--self.grasps:		map[int32, GraspInfo]	
		for k,v in pairs(bean.grasps) do
			g_i3k_game_context:SetCanLevelWuInfo(k, v.lvl, v.exp)
		end
		g_i3k_game_context:SetBooks(bean.bagBooks)
		g_i3k_game_context:SetExperienceCurExpCoin(bean.curExpCoin)
		g_i3k_game_context:SetCheatsInfo(bean.books)
		g_i3k_game_context:setQiankunInfo(bean.dmgTransfer)
	end
end

--加历练币
function i3k_sbean.role_add_expcoin.handler(bean, res)
	if bean.expCoin then
		g_i3k_game_context:AddExperienceCurExpCoin(bean.expCoin)
		if not i3k_dataeye_itemtype(bean.reason) then
			DCItem.get(g_BASE_ITEM_EMP, "历练", bean.expCoin, bean.reason)
		end 
	end
end

--已经提炼的次数(打开历练时同步的协议)
function i3k_sbean.goto_expcoin_sync()
	local data = i3k_sbean.expcoin_sync_req.new()
	local lvl = g_i3k_game_context:GetLevel()
	local openLevel = i3k_db_experience_args.args.openLevel
	if lvl < openLevel then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(476, openLevel))
		return
	end
	i3k_game_send_str_cmd(data,"expcoin_sync_res")
end

function i3k_sbean.expcoin_sync_res.handler(bean)
	if bean.dayTakeTimes then
		g_i3k_game_context:SetExperienceDayTakeTimes(i3k_db_experience_args.args.canGetTimes - bean.dayTakeTimes)
		g_i3k_ui_mgr:CloseUI(eUIID_Library)
		g_i3k_ui_mgr:CloseUI(eUIID_CanWu)
		g_i3k_ui_mgr:CloseUI(eUIID_Qiankun)
		g_i3k_ui_mgr:OpenUI(eUIID_Empowerment)
		g_i3k_ui_mgr:RefreshUI(eUIID_Empowerment)
	end
end

--使用历练（满）瓶的道具
function i3k_sbean.goto_bag_useitemexpcoinpool(id, count)
	local data = i3k_sbean.bag_useitemexpcoinpool_req.new()
	data.id = id
	data.count = count
	
	i3k_game_send_str_cmd(data,"bag_useitemexpcoinpool_res")
end

function i3k_sbean.bag_useitemexpcoinpool_res.handler(bean,req)
	if bean.ok == 1 then
		local item_cfg = g_i3k_db.i3k_db_get_other_item_cfg(req.id)
		local needCoin = item_cfg.args1 
		local tmp_items = {}
		local t = {id = g_BASE_ITEM_EMP,count = needCoin * req.count}
		table.insert(tmp_items,t)
		g_i3k_ui_mgr:ShowGainItemInfo(tmp_items)
		--g_i3k_game_context:UseCommonItem(req.id, req.count, AT_USE_ITEM_EXPCOIN_POOL)
		g_i3k_game_context:SetUseItemData(req.id, req.count, nil, AT_USE_ITEM_EXPCOIN_POOL)
	elseif bean.ok == -2 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(2001))	
	end
end

--提取历练
function i3k_sbean.goto_expcoin_extract(callback, times)
	local data = i3k_sbean.expcoin_extract_req.new()
	data.callback = callback
	data.times = times
	i3k_game_send_str_cmd(data,"expcoin_extract_res")
end

function i3k_sbean.expcoin_extract_res.handler(bean,req)
	if bean.ok ~= 0 then
		--提取成功
		if req.callback then
			req.callback()
		end
		local arg = i3k_db_experience_args
		local tmp_items = {}
		local t = {id = arg.experienceCorrelation.fullID,count = arg.experienceCorrelation.fullCount }
		table.insert(tmp_items,t)
		g_i3k_ui_mgr:ShowGainItemInfo(tmp_items)
		g_i3k_game_context:SetExperienceDayTakeTimes(req.times)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_EmpowermentTips, "onShowData")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Empowerment, "onShowData")
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(470))

		DCEvent.onEvent("历练提取")
	end
end


--添加藏书
--[[
function i3k_sbean.role_add_rarebooks.handler(bean)
	if bean.books then
		g_i3k_game_context:AddBooks(bean.books)
	end
end]]

--同步协议藏书夜协议
function i3k_sbean.goto_rarebook_sync()
	local data = i3k_sbean.rarebook_sync_req.new()
	i3k_game_send_str_cmd(data,"rarebook_sync_res")
end

function i3k_sbean.rarebook_sync_res.handler(bean)
	if bean then
		
		local args = g_i3k_db.i3k_db_experience_args
		local times = g_i3k_game_context:GetExperienceDayTakeTimes() 
		g_i3k_ui_mgr:CloseUI(eUIID_Empowerment)
		g_i3k_ui_mgr:CloseUI(eUIID_CanWu)
		g_i3k_ui_mgr:CloseUI(eUIID_Qiankun)
		g_i3k_ui_mgr:OpenUI(eUIID_Library)
		g_i3k_ui_mgr:RefreshUI(eUIID_Library,args, times)
	end
end

--藏书存入
function i3k_sbean.goto_rarebook_push(tab)
	local data = i3k_sbean.rarebook_push_req.new()
	if tab then
		data.items = tab
	end
	i3k_game_send_str_cmd(data,"rarebook_push_res")
end
function i3k_sbean.rarebook_push_res.handler(bean, req)
	if bean.ok == 1 then
	--	g_i3k_game_context:SetBooksIsLock(req.items)
		for k,v in pairs(req.items) do
			g_i3k_game_context:AddBooks(k, v)
			g_i3k_game_context:UseCommonItem(k, v,AT_RARE_BOOK_PUSH)
		end
		local items = g_i3k_game_context:GetBooksIsLock()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Library, "booksScroll", items)
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(454))
	elseif bean.ok == -2 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(2001))	
	end
end

--藏书取出
function i3k_sbean.goto_rarebook_pop(tab)
	local data = i3k_sbean.rarebook_pop_req.new()
	data.books = tab
	for k,v in pairs(tab) do
		data.bookID = k
		data.bookCount = v
	end
	
	i3k_game_send_str_cmd(data,"rarebook_pop_res")
end
function i3k_sbean.rarebook_pop_res.handler(bean, req)
	if bean.ok == 1 then
		local tmp_items = {}
		local t = {id = req.bookID, count = req.bookCount }
		table.insert(tmp_items,t)
		g_i3k_ui_mgr:ShowGainItemInfo(tmp_items)
		g_i3k_game_context:UseBooksCountForID(req.bookID, req.bookCount)
	--	local items = g_i3k_game_context:GetBooksIsLock()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Library, "refreshBooks")
	end
end

--藏书解锁
function i3k_sbean.goto_rarebook_unlock(info, callback)
	local data = i3k_sbean.rarebook_unlock_req.new()
	if info then
		data.bookID = info.libraryID
		data.info = info
	end
	data.level = 1
	data.callback = callback
	i3k_game_send_str_cmd(data,"rarebook_unlock_res")
end
function i3k_sbean.rarebook_unlock_res.handler(bean,req)
	if bean.ok ~= 0 then
		if req.callback then
			req.callback()
		end
		local newInfo
		local recordCount = 0
		for k,v in ipairs(i3k_db_experience_library) do
			if req.info.libraryID == v[1].libraryID then
				recordCount = k
				newInfo = v[req.info.libraryLvl + 1]
				break
			end
		end
		g_i3k_game_context:SetRecordBooksId(newInfo)
		g_i3k_game_context:isLibraryUnlock(req.bookID,req.level)
		g_i3k_game_context:SetPrePower()
		g_i3k_game_context:RefreshLiLianProps()
		g_i3k_game_context:ShowPowerChange()
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(456))
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Library, "updateScroll", req.info.libraryID)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Library, "libraryUpLevel", newInfo)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_XB, "updateEmpowermentNotice")
		
		local map = {}
		map["藏书".. req.bookID] = 1
		DCEvent.onEvent("藏书升级", map)
		DCEvent.onEvent("藏书解锁", { ["藏书ID"] = tostring(req.bookID)})
	end
end

--藏书升级
function i3k_sbean.goto_rarebook_lvlup(info, callback)
	local data = i3k_sbean.rarebook_lvlup_req.new()
	if info then
		data.bookID = info.libraryID
		data.level = info.libraryLvl
		data.info = info
	end
	
	data.callback = callback
	i3k_game_send_str_cmd(data,"rarebook_lvlup_res")
end
function i3k_sbean.rarebook_lvlup_res.handler(bean, req)
	if bean.ok ~= 0 then
		if req.callback then
			req.callback()
		end
		local newInfo
		local recordCount = 0
		for k,v in ipairs(i3k_db_experience_library) do
			if req.info.libraryID == v[1].libraryID then
				recordCount = k
				if req.info.libraryLvl == #v then
					newInfo = v[req.info.libraryLvl]
				else
					newInfo = v[req.info.libraryLvl + 1]
				end
				break
			end
		end
		g_i3k_game_context:SetRecordBooksId(newInfo)
		g_i3k_game_context:SetBookLevel(req.bookID,req.level)
		g_i3k_game_context:SetPrePower()
		g_i3k_game_context:RefreshLiLianProps()
		g_i3k_game_context:ShowPowerChange()
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(457))
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Library, "updateScroll", req.info.libraryID)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Library, "libraryUpLevel", newInfo)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_XB, "updateEmpowermentNotice")
		
		local map = {}
		map["藏书".. req.bookID] = tostring(req.level)
		DCEvent.onEvent("藏书升级", map)
	end
end

--同步参悟次数
function i3k_sbean.grasp_info_onlogin.handler(bean, res)
	if bean then
		g_i3k_game_context:SetCanwuTimes(bean.dayGraspTime)
	end
end

--同步参悟页签
function i3k_sbean.goto_grasp_sync()
	local data = i3k_sbean.grasp_sync_req.new()
	i3k_game_send_str_cmd(data,"grasp_sync_res")
end

function i3k_sbean.grasp_sync_res.handler(bean, req)
	if bean then
		local args = g_i3k_db.i3k_db_experience_args
		local allTime = args.canwuCorrelation.canwuNeedTimes
		local start_time = bean.lastGraspTime
		local serverTime = i3k_game_get_time()
		serverTime = i3k_integer(serverTime)
		if start_time + allTime < serverTime then
			g_i3k_game_context:SetIsCanCanwu(true)
		else
			g_i3k_game_context:SetIsCanCanwu(false)
		end
		g_i3k_game_context:SetCanwuTimes(bean.dayGraspTime)
		g_i3k_game_context:SetBuyTimes(bean.dayBuyGraspTime)
		g_i3k_game_context:SetNowXuanJi(bean.dayFortune)
		g_i3k_game_context:SetLastCanwuTime(bean.lastGraspTime)
		g_i3k_game_context:SetGraspSkill(bean.graspSkillLevel)
		g_i3k_ui_mgr:CloseUI(eUIID_Empowerment)
		g_i3k_ui_mgr:CloseUI(eUIID_Library)
		g_i3k_ui_mgr:CloseUI(eUIID_Qiankun)
		g_i3k_ui_mgr:OpenUI(eUIID_CanWu)
		g_i3k_ui_mgr:RefreshUI(eUIID_CanWu)
	end
end

--通知客户端玄机改变
function i3k_sbean.grasp_dayforture_refresh.handler(bean)
	if bean then
		g_i3k_game_context:SetNowXuanJi(bean.dayFortune)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_CanWu, "leftScrollData")
		if g_i3k_ui_mgr:GetUI(eUIID_CanWu) then
			i3k_sbean.goto_grasp_sync()
		end
	end
end

--通知客户端参悟经验增长
--[[
function i3k_sbean.role_add_graspexp.handler(bean)
	if bean then
		g_i3k_game_context:AddCanWuExp(bean.id, bean.exp)
	end
end]]

--参悟
function i3k_sbean.goto_grasp_impl(wudaoID, item)
	local data = i3k_sbean.grasp_impl_req.new()
	data.graspID = wudaoID
	data.item = item
	i3k_game_send_str_cmd(data,"grasp_impl_res")
end

function i3k_sbean.grasp_impl_res.handler(bean, req)
	if bean.ok > 0 then
		if req then
			for _, v in ipairs(req.item) do
				g_i3k_game_context:UseCommonItem(v.id, v.count, AT_GRASP_IMPL)
			end
			--刷新左边列表，和上面经验
			local serverTime = i3k_game_get_time()
			serverTime = i3k_integer(serverTime)
			g_i3k_game_context:SetLastCanwuTime(serverTime)
			local times = g_i3k_game_context:GetCanwuTimes()
			g_i3k_game_context:SetCanwuTimes(times + 1)
			g_i3k_game_context:SetIsCanCanwu(false)
			g_i3k_ui_mgr:OpenUI(eUIID_CanWuEnd)
			g_i3k_ui_mgr:RefreshUI(eUIID_CanWuEnd, req.graspID, bean.add)
			g_i3k_game_context:SetPrePower()
			g_i3k_game_context:RefreshLiLianProps()
			g_i3k_game_context:ShowPowerChange()
			local count = g_i3k_game_context:GetSelectWudao()
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_CanWu, "leftScrollData", count)
			
			DCEvent.onEvent("历练参悟", { ["参悟ID"] = tostring(req.graspID)})
		end
	elseif bean.ok == -1 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(458))
		g_i3k_ui_mgr:RefreshUI(eUIID_CanWu)
	elseif bean.ok == -2 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(459))
		g_i3k_ui_mgr:RefreshUI(eUIID_CanWu)
	elseif bean.ok == -3 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(460))
		g_i3k_ui_mgr:RefreshUI(eUIID_CanWu)
	else
		g_i3k_ui_mgr:PopupTipMessage("参悟失败")
	end
end

--参悟cd时间重置
function i3k_sbean.goto_grasp_reset(money)
	local data = i3k_sbean.grasp_reset_req.new()
	data.money = money

	i3k_game_send_str_cmd(data,"grasp_reset_res")
end
function i3k_sbean.grasp_reset_res.handler(bean, req)
	if bean.ok ~= 0 then
		g_i3k_game_context:UseDiamond(req.money, false,AT_GRASP_RESET)
		g_i3k_game_context:SetIsCanCanwu(true)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_CanWu, "canwuCountData")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_CanWu, "factionMemberInfo")
	end
end

--参悟次数购买
function i3k_sbean.grasp_time_buy(time, needDiamond)
	local data = i3k_sbean.grasp_time_buy_req.new()
	data.time = time
	data.needDiamond = needDiamond
	i3k_game_send_str_cmd(data, "grasp_time_buy_res")
end

function i3k_sbean.grasp_time_buy_res.handler(bean, req)
	if bean.ok > 0 then
		g_i3k_game_context:UseDiamond(req.needDiamond, false, AT_GRASP_IMPL)
		g_i3k_game_context:SetBuyTimes(req.time)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_CanWu, "addCanwuCount", 1)
	else
		g_i3k_ui_mgr:PopupTipMessage("购买失败")
	end
end

-- 乾坤升级
function i3k_sbean.dmgtransfer_lvlup(id, needItems, needPoint)
	local data = i3k_sbean.dmgtransfer_lvlup_req.new()
	data.id = id
	data.needItems = needItems
	data.needPoint = needPoint
	i3k_game_send_str_cmd(data, "dmgtransfer_lvlup_res")
end

function i3k_sbean.dmgtransfer_lvlup_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_game_context:setQianhuaUpLvl(req.needPoint, req.id, req.needItems)
	end
end

--乾坤重置点
function i3k_sbean.dmgtransfer_reset()
	local data = i3k_sbean.dmgtransfer_reset_req.new()
	i3k_game_send_str_cmd(data,"dmgtransfer_reset_res")
end

function i3k_sbean.dmgtransfer_reset_res.handler(bean, req)
	if bean.ok > 0 then
		g_i3k_game_context:setQiankunReset()
	else
		g_i3k_ui_mgr:PopupTipMessage("重置失败")
	end
end

--乾坤购买
function i3k_sbean.dmgtransfer_buypoint(discount, point, items)
	local data = i3k_sbean.dmgtransfer_buypoint_req.new()
	data.discount = discount
	data.point = point
	data.items = items
	i3k_game_send_str_cmd(data,"dmgtransfer_buypoint_res")
end

function i3k_sbean.dmgtransfer_buypoint_res.handler(bean, req)
	if bean.ok > 0 then
		g_i3k_game_context:setQiankunBuyInfo(req.discount, req.point, req.items)
	else
		g_i3k_ui_mgr:PopupTipMessage("购买失败")
	end
end
