WelfareExchangeView = WelfareExchangeView or BaseClass(BaseRender)

function WelfareExchangeView:__init()
	self.input = self:FindObj("Input")
	self:ListenEvent("OnClickGetReward", BindTool.Bind(self.OnClickGetReward, self))
end

function WelfareExchangeView:__delete()

end

function WelfareExchangeView:OnClickGetReward()
	local card = self.input.input_field.text
	if card == "" then
		SysMsgCtrl.Instance:ErrorRemind(Language.Welfare.NoneGiftDes)
		return
	end

	self:FetchGift(card)
	self.input.input_field.text = ""
end

function WelfareExchangeView:FetchGift(card)
	local key = "33cc62b07ae98fffddd923b178aa0a14"
	local url = GLOBAL_CONFIG.param_list.gift_fetch_url or "cls.xxqt.youyannet.com/api/c2s/use_card.php"

	local user_vo = GameVoManager.Instance:GetUserVo()
	local mainrole_vo = GameVoManager.Instance:GetMainRoleVo()

	local params = {}
	params.spid = tostring(GLOBAL_CONFIG.package_info.config.agent_id)				--平台ID
	params.server = mainrole_vo.server_id											--服ID
	params.user = user_vo.plat_name													--平台帐号
	params.role = mainrole_vo.role_id		  										--角色ID
	params.level = mainrole_vo.level	  				   							 --角色等级
	params.card = card or ""														--卡号
	params.time = os.time()												    		--时间戳
	params.sign = MD5.GetMD5FromString(params.spid .. params.server .. params.user .. params.role .. params.level .. params.card .. params.time .. key) --签名

	local req_fmt = "%s?spid=%s&server=%s&user=%s&role=%s&level=%s&card=%s&time=%s&sign=%s"
	local req_str = string.format(req_fmt, url, params.spid, tostring(params.server), params.user, tostring(params.role), tostring(params.level), params.card, tostring(params.time), params.sign)

	print("[FetchGift] request fetch", req_str)
	HttpClient:Request(req_str, 
		function(url, arg, data, size)
			self:FetchGiftCallback(url, arg, data, size)
		end)
end

function WelfareExchangeView:FetchGiftCallback(url, is_succ, data)
	print_log("[FetchGift] FetchGiftCallback", is_succ, data)
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
