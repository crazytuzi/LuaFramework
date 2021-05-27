LoginActCodePop = LoginActCodePop or BaseClass(XuiBaseView)

function LoginActCodePop:__init()
	if LoginActCodePop.Instance then
		ErrorLog("[LoginActCodePop]:Attempt to create singleton twice!")
	end
	LoginActCodePop.Instance = self
	self.config_tab = {
		{"login_ui_cfg", 4, {0}},
	}
	self.zorder = COMMON_CONSTS.ZORDER_MAX
	self.is_any_click_close = true
	self.ok_fun = nil
end

function LoginActCodePop:__delete()

end

function LoginActCodePop:OpenCallBack()

end

function LoginActCodePop:SetOkFun(fun)
	self.ok_fun = fun
	self:Open()
end

function LoginActCodePop:LoadCallBack()
	self.edit_CDK = self.node_t_list.edit_CDK.node
	self.btn_OK = self.node_t_list.btn_OK.node
	XUI.AddClickEventListener(self.btn_OK, BindTool.Bind1(self.OnClickEnterHandler, self))
end

function LoginActCodePop:OnClickEnterHandler(sender)
	local cur_CKD = tostring(self.edit_CDK:getText())

	if nil == cur_CKD or "" == cur_CKD then return end

	self:SendCDK(cur_CKD)
end

function LoginActCodePop:CloseCallBack()
	self.edit_CDK:setText("")
end

function LoginActCodePop:SendCDK(cdk)
	-- http://api.game.com/api/c2s/use_card.php?spid=xxx&server=x&user=xxx&role=xx&level=xx&card=xxxxx&time=xxxx&sign=xxxxxx
	-- sign=md5(spid . server . user . role . level . card . time . '33cc62b07ae98fffddd923b178aa0a14')
	local key = "33cc62b07ae98fffddd923b178aa0a14"
	local url = GLOBAL_CONFIG.param_list.gift_fetch_url or "cls.xxqt.youyannet.com/api/c2s/use_card.php"

	local params = {}
	params.spid = AgentAdapter:GetSpid()											--平台ID
	params.server = GameVoManager.Instance:GetUserVo().plat_server_id				--服ID
	params.user = AgentAdapter:GetPlatName()										--平台帐号
	params.role = "activecode"		  														--角色ID
	params.level = 1	  				    										--角色等级
	params.card = cdk or ""															--卡号
	params.time = os.time()												    		--时间戳
	params.sign = UtilEx:md5Data(params.spid .. params.server .. params.user .. params.role .. params.level .. params.card .. params.time .. key)   --签名

	local req_fmt = "%s?spid=%s&server=%s&user=%s&role=%s&level=%s&card=%s&time=%s&sign=%s"
	local req_str = string.format(req_fmt, url, params.spid, tostring(params.server), params.user, tostring(params.role), tostring(params.level), params.card, tostring(params.time), params.sign)
	HttpClient:Request(req_str, "", 
		function(url, arg, data, size)
			self:SendCDKCallBack(url, arg, data, size)
		end)
end

function LoginActCodePop:SendCDKCallBack(url, arg, data, size)
	Log("------------->>data", data)
	if nil == data then return end

	local rep = cjson.decode(data)
	if nil == rep or nil == rep.ret then return end

	local ret = tonumber(rep.ret)

	-- 0 成功 1 卡号无效 2 渠道无效 3 区服无效 4 卡号过期 5 等级限制 6 领取次数限制 7 其他错误
	if 0 == ret then
		if self.ok_fun then
			self.ok_fun()
			self:Close()
		end
	elseif ret > 0 and ret < 6 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Login.CDKCanNoUse, true)
	elseif 6 == ret then
		SysMsgCtrl.Instance:ErrorRemind(Language.Login.CDKHaveGot, true)
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Login.CDKOtherErrors, true)
	end
end
