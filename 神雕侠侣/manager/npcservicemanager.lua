NpcServiceManager = {}

function NpcServiceManager.DispatchHandler(npckey, serviceid)
	LogInsane("NpcService DispatchHandler, npcid: " .. npckey)
	if serviceid == 1850 then
		local dlg = require "ui.faction.factionxiulian":GetSingletonDialogAndShowIt()
        dlg.npckey = npckey
        dlg:RequestAttri(2)
        CNpcDialog:OnExit()

		local p = require "protocoldef.knight.gsp.faction.creqassistskillmaxlevel":new()
		require "manager.luaprotocolmanager":send(p)

		return 1
	elseif serviceid == 1905 then
		require "ui.legend.entrance":GetSingletonDialogAndShowIt()
	elseif serviceid == 1963 then
		local PetExchangeDlg = require "ui.pet.petexchangedlg"
		PetExchangeDlg.getInstanceAndShow()

	--buy dingqingxinwu
	elseif serviceid == 2267 then
		require "ui.marry.dingqingxinwudlg".getInstanceAndShow()
		return 0
	--comfirm use dingqingxinwu
	elseif serviceid == 2297 or serviceid == 2298 or serviceid == 2299 or serviceid == 2307 or serviceid == 2308 then
		local functable = {}
		function functable.acceptCallback()
			print("functable.acceptCallback serviceid=" .. serviceid)
			GetMessageManager():CloseConfirmBox(eConfirmNormal,false)
			require "protocoldef.knight.gsp.marry.cweddingchoose"
			local p = CWeddingChoose.Create()
			p.serviceid = serviceid
			require "manager.luaprotocolmanager":send(p)
		end

		local msg=""
		if serviceid == 2297 then
			msg = knight.gsp.message.GetCMessageTipTableInstance():getRecorder(146094).msg
		elseif serviceid == 2298 or serviceid == 2307 then
			local config = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.cmarryconfig"):getRecorder(2)
			local formatstr = knight.gsp.message.GetCMessageTipTableInstance():getRecorder(146095).msg
			local sb = require "utils.stringbuilder":new()
			sb:Set("parameter1", config.yinliang or "??")
			msg = sb:GetString(formatstr)
            sb:delete()
		elseif serviceid == 2299 or serviceid == 2308 then
			local config = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.cmarryconfig"):getRecorder(3)
			local formatstr = knight.gsp.message.GetCMessageTipTableInstance():getRecorder(146096).msg
			local sb = require "utils.stringbuilder":new()
			sb:Set("parameter1", config.yinliang or "??")
			sb:Set("parameter2", config.yuanbao or "??")
			msg = sb:GetString(formatstr)
            sb:delete()
		end

		GetMessageManager():AddConfirmBox(eConfirmNormal,
		msg,
		functable.acceptCallback,
	  	functable,
	  	CMessageManager.HandleDefaultCancelEvent,
	  	CMessageManager)
	  	return 0
	elseif serviceid == 2058 then
	 local p = knight.gsp.item.CGetBagInfo()-- require "protocoldef.knight.gsp.item.cgetbaginfo":new()
	 p.bagid = knight.gsp.item.BagTypes.DEPOT
	 p.npcid = npckey
	 GetNetConnection():send(p)
	 local dlg = require "ui.item.depot":getInstance()
	 dlg.m_npckey = npckey
	 dlg:SetVisible(false)
	 --require "ui.item.depot":GetSingletonDialogAndShowIt()
	 return 0

	-- 阵法元素熔炼
	elseif serviceid == 2578 then
		local YuanSuRongLianDlg = require "ui.team.yuansurongliandlg"
		YuanSuRongLianDlg.OnNpcService()
		CNpcDialog:OnExit()
		return 1
	end
	--[[
	if serviceid > 0 then
		
	end
	--]]
	return 0
end

return NpcServiceManager
