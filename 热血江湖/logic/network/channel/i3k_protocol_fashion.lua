------------------------------------------------------
module(..., package.seeall)

local require = require

require("i3k_sbean")

--放入衣橱
function i3k_sbean.fashion_putwardrobe(fashionID)
	local data = i3k_sbean.fashion_putwardrobe_req.new()
	data.fashionID = fashionID
	i3k_game_send_str_cmd(data, i3k_sbean.fashion_putwardrobe_res.getName())
end

function i3k_sbean.fashion_putwardrobe_res.handler(res, req)
	if res.ok > 0 then
		local fashionID = req.fashionID

		g_i3k_game_context:PutFashionInWardrobe(fashionID)

		g_i3k_game_context:RefreshFashionProps()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_FashionDress, "updateRolePower")

		g_i3k_ui_mgr:RefreshUI(eUIID_FashionDress)

		g_i3k_ui_mgr:CloseUI(eUIID_FashionDressTips)
		g_i3k_ui_mgr:PopupTipMessage("您已将时装放入衣橱")
	else
		g_i3k_ui_mgr:PopupTipMessage("放入衣橱失败")
	end
end

--从衣橱取出
function i3k_sbean.fashion_getwardrobe(fashionID)
	local data = i3k_sbean.fashion_getwardrobe_req.new()
	data.fashionID = fashionID
	i3k_game_send_str_cmd(data, i3k_sbean.fashion_getwardrobe_res.getName())
end

function i3k_sbean.fashion_getwardrobe_res.handler(res, req)
	if res.ok > 0 then
		local fashionID = req.fashionID
		g_i3k_game_context:TakeFashionFromWardrobe(fashionID)

		g_i3k_game_context:RefreshFashionProps()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_FashionDress, "updateRolePower")

		g_i3k_ui_mgr:InvokeUIFunction(eUIID_FashionDress,"updateStorageScroll")
	else
		g_i3k_ui_mgr:PopupTipMessage("从衣橱取出失败")
	end
end

--精纺时装
function i3k_sbean.fashion_worsted(fashionID, consumeItems, isRefresh)
	local data = i3k_sbean.fashion_worsted_req.new()
	data.fashionID = fashionID
	data.consumeItems = consumeItems
	data.isRefresh = isRefresh
	i3k_game_send_str_cmd(data, i3k_sbean.fashion_worsted_res.getName())
end

function i3k_sbean.fashion_worsted_res.handler(res, req)
	if res.ok > 0 then
		for k, v in pairs(req.consumeItems) do
			g_i3k_game_context:UseCommonItem(v.id, v.count, AT_FASHION_ENHANCE)
		end

		g_i3k_game_context:SetFashionSpinningTimes(req.fashionID)  --精纺成功后增加精纺的次数

		g_i3k_ui_mgr:InvokeUIFunction(eUIID_FashionSpinning, "updateConsumeScroll")  --刷新界面道具显示

		--再次精纺就不打开属性界面了，只做刷新
		if not req.isRefresh then
			g_i3k_ui_mgr:OpenUI(eUIID_FashionSpinningProperty)
		end
		
		g_i3k_ui_mgr:RefreshUI(eUIID_FashionSpinningProperty, req.fashionID, res.enhanceProps1, res.enhanceProps2)
	else
		g_i3k_ui_mgr:PopupTipMessage("精纺时装失败")
	end
end

-- 保存精纺时装属性
function i3k_sbean.fashion_save_worsted(fashionID, propGroupId, prop, oldPower, newPower)
	local data = i3k_sbean.fashion_save_worsted_req.new()
	data.fashionID = fashionID
	data.propGroupId = propGroupId
	data.prop = prop
	data.oldPower = oldPower
	data.newPower = newPower
	i3k_game_send_str_cmd(data, i3k_sbean.fashion_save_worsted_res.getName())
end

function i3k_sbean.fashion_save_worsted_res.handler(res, req)
	if res.ok > 0 then
		local fashionID = req.fashionID
		g_i3k_ui_mgr:CloseUI(eUIID_FashionSpinningProperty)

		local oldPower = req.oldPower
		local newPower = req.newPower
		if newPower > oldPower then
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_FashionSpinning, "playUpdateAnim")
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_FashionSpinning, "showPowerChange", oldPower, newPower)
		end

		g_i3k_game_context:SaveFashionEnhanceProps(fashionID, req.prop)

		g_i3k_ui_mgr:RefreshUI(eUIID_FashionDress)
		g_i3k_ui_mgr:RefreshUI(eUIID_FashionSpinning, fashionID)

		g_i3k_game_context:RefreshFashionProps()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_FashionDress, "updateRolePower")

		g_i3k_ui_mgr:PopupTipMessage("保存时装精纺属性成功")
	else
		g_i3k_ui_mgr:PopupTipMessage("保存时装精纺属性失败")
	end
end
