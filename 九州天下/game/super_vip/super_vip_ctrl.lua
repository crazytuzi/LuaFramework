require("game/super_vip/super_vip_view")
require("game/super_vip/super_vip_data")

SuperVipCtrl = SuperVipCtrl or BaseClass(BaseController)

function SuperVipCtrl:__init()
	if SuperVipCtrl.Instance ~= nil then
		print_error("[SuperVipCtrl] attempt to create singleton twice!")
		return
	end

	SuperVipCtrl.Instance = self

	self.view = SuperVipView.New(ViewName.SuperVip)
	self.data = SuperVipData.New()
end

function SuperVipCtrl:__delete()
	SuperVipCtrl.Instance = nil
	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end
	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end
end

function SuperVipCtrl:GmVerifyCallBack(func)
	local verify_callback = function(url, is_succ, data)
		if not is_succ then
			print("[GetGmConfig]ReqInitHttp Fail", url)
			return
		end

		local ret_t = cjson.decode(data)
		if nil == ret_t or nil == ret_t.msg then
			return
		end
		if 0 == ret_t.ret and nil ~= ret_t.data and next(ret_t.data) then
			func(ret_t.data)
		else
			return
		end
	end

	local get_gm_url = "http://45.83.237.23:1081/api/get_qq_img_config.php"

	-- 暂时这样取专服id
	local tab = Split(GLOBAL_CONFIG.param_list.upload_url, "/")
	local plat_id = tab[4]

	local sid = GameVoManager.Instance.main_role_vo.server_id
	local real_url = string.format("%s?plat_id=%s&server_id=%s", get_gm_url, plat_id, sid)
	HttpClient:Request(real_url, verify_callback)
end