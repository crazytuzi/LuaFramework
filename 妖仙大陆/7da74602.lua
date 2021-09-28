

function start(api,...)
	
	
	
	
	
	
	
	
	local types = {
		'主手','副手','头部','上衣','腿部','腰部','手套','鞋子','勋章','项链','戒指'
	}
	local pros = {
		'狂战士','刺客','魔法师','猎人','牧师'
	}
	local player_info = api.GetUserInfo()

	local pro_ele = api.CallGlobalFunc('GlobalHooks.DB.Find','Character',player_info.pro)

	local codes = {}
	for _,v in ipairs(types) do
		local search = {
			Pro = function (p)
				return p == pro_ele.ProName or p == '通用'
			end,
			Qcolor = function (q)
				return q == 3
			end,
			LevelReq = function (l)
				return l >= 20 and l <= 30
			end,
			Type = v,
		}
		local ret = api.CallGlobalFunc('GlobalHooks.DB.Find','Items',search)
		table.sort(ret,function (i1,i2)
			return i1.Code < i2.Code
		end)
		local ele = ret[#ret-1]
		if ele then
			api.SendChatMsg('@gm add '..ele.Code..' 1')
		end
		
		api.Sleep(1)
		table.insert(codes,ele.Code)
	end
	do return end
	api.SendChatMsg('@gm add diamond 9999999999')
	for _,v in ipairs(codes) do
		local it = api.FindBagItemByCode(v)
		if it then
			api.CallGlobalFunc('Pomelo.EquipHandler.equipRequest',it.index)
			
			
			
		end
	end


	api.UI.CloseAllMenu()


end
