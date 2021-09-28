local platformSdk = {
	bundleid = function (self)
		local curBundleid = "sdsj.fgcq.sjhycq"
		local pu_ret, pu = pcall(function ()
			return PlatformUtils:getInstance()
		end)

		if pu_ret and pu ~= nil then
			local pu_bundleId = pu.getBundleId(slot3)

			if pu_bundleId ~= "" then
				curBundleid = pu_bundleId
			end
		end

		return curBundleid
	end,
	channelid = function (self)
		return device.platform .. "." .. platformSdk:bundleid()
	end,
	sdkChannelId = function (self)
		return MirSDKAgent:getChannelID()
	end,
	getUserID = function (self)
		return MirSDKAgent:callUserPluginFuncString("getJuheUserId") or MirSDKAgent:callUserPluginFuncString("getUserId")
	end,
	openid = function (self)
		return MirSDKAgent:getUserID()
	end,
	bundleversion = function (self)
		local curBundleVersion = ""
		local pu_ret, pu = pcall(function ()
			return PlatformUtils:getInstance()
		end)

		if pu_ret and pu ~= nil then
			pu_ret, slot5 = pcall(function ()
				return pu:getBundleVersion()
			end)
			curBundleVersion = slot5

			if pu_ret == false then
				curBundleVersion = ""
			end
		end

		return curBundleVersion
	end,
	getLoginSdk = function (self)
		local curLoginSdk = 1
		local pu_ret, pu = pcall(function ()
			return PlatformUtils:getInstance()
		end)

		if pu_ret and pu ~= nil then
			pu_ret, slot5 = pcall(function ()
				return pu:getLoginSdk()
			end)
			curLoginSdk = slot5

			if pu_ret == false then
				curLoginSdk = 1
			end
		end

		return curLoginSdk
	end,
	getPackageName = function (self)
		if self.curPackageName == nil then
			local curBundleId = self.bundleid(self)
			self.curPackageName = string.gsub(curBundleId, "%.", "/") .. "/"
		end

		return self.curPackageName
	end,
	getiOSDeviceType = function (self)
		local device_type = {
			["iPhone10,3"] = "iPhoneX",
			x86_64 = "Simulator",
			i386 = "Simulator",
			["iPhone10,6"] = "iPhoneX"
		}
		local deviceType = "unknown"

		if MirDevices ~= nil and MirDevices.getInstance ~= nil and MirDevices:getInstance().getDevicesModel ~= nil then
			deviceName = MirDevices:getInstance():getDevicesModel()
			deviceType = device_type[deviceName] or deviceName
		end

		return deviceType
	end,
	getUIFixSize = function (self)
		local fixSize, deviceName = nil

		if MirDevices and MirDevices.getInstance and MirDevices:getInstance().getDevicesModel then
			deviceName = MirDevices:getInstance():getDevicesModel()

			print("deviceName = ", deviceName)

			local config_json = io.readfile(cc.FileUtils:getInstance():fullPathForFilename("public/modelFixSize.json"))
			local jsonParse = require("cjson")
			local config = jsonParse.decode(config_json)

			for k, v in pairs(config) do
				if v.model == deviceName then
					fixSize = {
						x = v.x,
						y = v.y
					}

					break
				end
			end
		end

		return fixSize
	end
}

return platformSdk
