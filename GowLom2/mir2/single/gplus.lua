local gplus = {
	phone,
	userid,
	ticket,
	appid = "791000255",
	setListenner = function (listenner)
		gplus.listenner = listenner

		return 
	end,
	removeListenner = function ()
		gplus.listenner = nil

		return 
	end,
	call = function (key, ...)
		if gplus.listenner and gplus.listenner[key] then
			gplus.listenner[key](gplus.listenner, ...)
		end

		return 
	end,
	init = function ()
		if device.platform == "ios" then
			slot0, slot1 = luaoc.callStaticMethod("gplusSDK", "call", {
				type = "initSDK:",
				appid = gplus.appid,
				callback = function (dic)
					gplus.call("gplusInitEnd", dic.code, dic.msg)

					return 
				end
			})
		elseif device.platform == "android" then
			luaj.callStaticMethod(platformSdk.getPackageName(slot1) .. "gplusSDK", "initSDK", {
				gplus.appid,
				function (msg)
					local dic = json.decode(msg)

					gplus.call("gplusInitEnd", dic.code, dic.msg)

					return 
				end
			})
		end

		return 
	end,
	login = function ()
		if device.platform == "ios" then
			slot0, slot1 = luaoc.callStaticMethod("gplusSDK", "call", {
				type = "login:",
				callback = function (dic)
					gplus.call("gplusLoginEnd", dic.code, dic.msg, dic.ticket, dic.userid, dic.phone)

					return 
				end
			})
		elseif device.platform == "android" then
			luaj.callStaticMethod(platformSdk.getPackageName(slot1) .. "gplusSDK", "login", {
				function (msg)
					local dic = json.decode(msg)

					gplus.call("gplusLoginEnd", dic.code, dic.msg, dic.ticket, dic.userid, dic.phone)

					return 
				end
			})
		end

		return 
	end,
	logout = function ()
		gplus.phone = nil
		gplus.userid = nil
		gplus.ticket = nil

		if device.platform == "ios" then
			slot0, slot1 = luaoc.callStaticMethod("gplusSDK", "call", {
				type = "loginOut:",
				callback = function (dic)
					gplus.call("gplusLogoutEnd", dic.code, dic.msg)

					return 
				end
			})
		elseif device.platform == "android" then
			luaj.callStaticMethod(platformSdk.getPackageName(slot1) .. "gplusSDK", "logout", {
				function (msg)
					local dic = json.decode(msg)

					gplus.call("gplusLogoutEnd", dic.code, dic.msg)

					return 
				end
			})
		end

		return 
	end,
	getTicket = function ()
		if device.platform == "ios" then
			slot0, slot1 = luaoc.callStaticMethod("gplusSDK", "call", {
				type = "getTicket:",
				appid = gplus.appid,
				areaid = tostring(def.areaID),
				callback = function (dic)
					gplus.call("gplusGetTicketEnd", dic.code, dic.msg, dic.ticket)

					return 
				end
			})
		elseif device.platform == "android" then
			luaj.callStaticMethod(platformSdk.getPackageName(slot1) .. "gplusSDK", "getTicket", {
				gplus.appid,
				tostring(def.areaID),
				function (msg)
					local dic = json.decode(msg)

					dump(dic)
					gplus.call("gplusGetTicketEnd", dic.code, dic.msg, dic.ticket)

					return 
				end
			})
		end

		return 
	end,
	pay = function (productid, gameOrderId, extendInfo)
		if device.platform == "ios" then
			slot3, slot4 = luaoc.callStaticMethod("gplusSDK", "call", {
				type = "pay:",
				appid = gplus.appid,
				areaid = tostring(def.areaID),
				productid = productid,
				gameOrderid = gameOrderId,
				extendInfo = extendInfo,
				callback = function (dic)
					print("IOS 支付结果:", dic.msg, dic.code)
					gplus.call("gplusPayEnd", dic.code, dic.msg)

					return 
				end
			})
		elseif device.platform == "android" then
			luaj.callStaticMethod(platformSdk.getPackageName(slot4) .. "gplusSDK", "pay", {
				tostring(def.areaID),
				tostring(productid),
				tostring(gameOrderId),
				tostring(extendInfo),
				function (msg)
					local dic = json.decode(msg)

					print("android 支付结果", msg)
					gplus.call("gplusPayEnd", dic.code, dic.msg)

					return 
				end
			})
		end

		return 
	end,
	extendFunction = function (func, parameter)
		if device.platform == "ios" then
			slot2, slot3 = luaoc.callStaticMethod("gplusSDK", "call", {
				type = "extendFunction:",
				func = func,
				parameter = parameter,
				callback = function (dic)
					print("IOS 检查结果:")
					dump(dic)
					gplus.call("gplusCheckPaidOrderEnd", dic.code, dic.msg)

					return 
				end
			})
		end

		return 
	end
}

return gplus
