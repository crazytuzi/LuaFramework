-- 礼包码兑换
local WelfareGiftView = BaseClass(SubView)

function WelfareGiftView:__init()
	self.texture_path_list = {
		'res/xui/welfare.png',
	}
	self.config_tab = {
		{"welfare_ui_cfg", 7, {0}},
	}
end

function WelfareGiftView:__delete()
end

function WelfareGiftView:LoadCallBack(index, loaded_times)
	self.edit_libaoid = self.node_t_list.edit_serial_number.node
	self.btn_libaoget = self.node_t_list.btn_gift_receive.node
	self.edit_libaoid:setPlaceHolder(Language.Welfare.InputLiBaoMa)
	XUI.AddClickEventListener(self.btn_libaoget, BindTool.Bind(self.OnClickGiftHandler, self))
end

function WelfareGiftView:OnClickGiftHandler(sender)
	local card = tostring(self.edit_libaoid:getText())
	Log("WelfareGiftView:OnClickGiftHandler-->>", card)

	if nil == card or "" == card then return end

	if 20 == string.len(card) then
		self:FetchGift(card)
	else
		self:FetchGift2(card)
	end
	-- WelfareCtrl.OnGetSerialNumberRewardsReq(card)
end

function WelfareGiftView:OnFlushGiftView()
	
end

function WelfareGiftView:FetchGift(card)
	local key = "c4c50792bad33bb93b367c4f3247e3fd"

	local params = {}
	params.type = "1"																	--礼包类型   type
	params.card = card or ""															--卡号       card
	params.spid = AgentAdapter:GetSpid()												--平台ID     spid
	params.sid = GameVoManager.Instance:GetUserVo().plat_server_id						--服ID       sid
	params.plat_user_name = AgentAdapter:GetPlatName()      							--平台帐号	 plat_user_name
	params.role_id = GameVoManager.Instance:GetMainRoleVo().role_id		  			    --角色ID     role_id  
	params.role_name = GameVoManager.Instance:GetMainRoleVo().name	  			    	--角色名字   role_name
	params.time = os.time()												    			--时间戳	 time
	params.sign = UtilEx:md5Data(params.type .. params.card .. params.spid .. params.sid .. params.plat_user_name .. params.role_id .. params.time .. key)   --签名
	local url_format = "http://l.cqtest.jianguogame.com:88/usecard.php?type=%s&card=%s&spid=%s&sid=%s&plat_user_name=%s&role_id=%s&role_name=%s&time=%s&sign=%s"

	local url_str = string.format(url_format, params.type, params.card, params.spid, tostring(params.sid), params.plat_user_name, tostring(params.role_id), params.role_name, tostring(params.time), params.sign)

	HttpClient:Request(url_str, "", 
		function(url, arg, data, size)
			self:FetchGiftCallback(url, arg, data, size)
		end)
end

function WelfareGiftView:FetchGiftCallback(url, arg, data, size)
	Log("------------->>data",data)
	--SysMsgCtrl.Instance:ErrorRemind(data)
	if nil == data then
		return
	end

	if data == "0" then
		Log("------------------>>礼包领取成功")
		SysMsgCtrl.Instance:ErrorRemind(Language.Gift.GotSucc)
		return
	end
	
	if data == "1" then
		Log("------------------>>礼包已经领取")
		SysMsgCtrl.Instance:ErrorRemind(Language.Gift.HaveGot)
		return
	end

	if data == "2" then
		Log("------------------>>礼包卡号无效")
		SysMsgCtrl.Instance:ErrorRemind(Language.Gift.CanNoUse)
		return
	end

	if data == "3" then
		Log("------------------>>领取其他错误")
		SysMsgCtrl.Instance:ErrorRemind(Language.Gift.OtherErrors)
		return
	end
end

function WelfareGiftView:FetchGift2(card)
	-- http://cls.cq20.yuguan668.com/api/c2s/use_card.php?spid=xxx&server=x&user=xxx&role=xx&level=xx&card=xxxxx&time=xxxx&sign=xxxxxx
	-- sign=md5(spid . server . user . role . level . card . time . '33cc62b07ae98fffddd923b178aa0a14')
	local key = "33cc62b07ae98fffddd923b178aa0a14"
	local url = GLOBAL_CONFIG.param_list.gift_fetch_url or "l.cqtest.jianguogame.com:88/api/c2s/use_card.php"
	local params = {}
	params.spid = AgentAdapter:GetSpid()											--平台ID
	params.server = GameVoManager.Instance:GetUserVo().plat_server_id				--服ID
	params.user = AgentAdapter:GetPlatName()										--平台帐号
	params.role = GameVoManager.Instance:GetMainRoleVo().role_id		  			--角色ID
	params.level = GameVoManager.Instance:GetMainRoleVo()[OBJ_ATTR.CREATURE_LEVEL] 	--角色等级
	params.card = card or ""														--卡号
	params.time = os.time()												    		--时间戳
	params.sign = UtilEx:md5Data(params.spid .. params.server .. params.user .. params.role .. params.level .. params.card .. params.time .. key)   --签名
	local req_fmt = "%s?spid=%s&server=%s&user=%s&role=%s&level=%s&card=%s&time=%s&sign=%s"
	local req_str = string.format(req_fmt, url, params.spid, tostring(params.server), params.user, tostring(params.role), tostring(params.level), params.card, tostring(params.time), params.sign)

	HttpClient:Request(req_str, "", 
		function(url, arg, data, size)
			self:FetchGiftCallback2(url, arg, data, size)
		end)
end

function WelfareGiftView:FetchGiftCallback2(url, arg, data, size)
	Log("------------->>data", data)
	if nil == data then return end

	local rep = cjson.decode(data)
	if nil == rep or nil == rep.ret then return end

	local ret = tonumber(rep.ret)

	-- 0 成功 1 卡号无效 2 渠道无效 3 区服无效 4 卡号过期 5 等级限制 6 领取次数限制 7 其他错误
	if 0 == ret then
		SysMsgCtrl.Instance:ErrorRemind(Language.Gift.GotSucc)
	elseif ret > 0 and ret < 6 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Gift.CanNoUse)
	elseif 6 == ret then
		SysMsgCtrl.Instance:ErrorRemind(Language.Gift.HaveGot)
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Gift.OtherErrors)
	end
end


return WelfareGiftView