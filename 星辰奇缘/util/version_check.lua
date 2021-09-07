-- ----------------------------------
-- 关于版本检查的集中接口
-- 这样不用到处都是版本判断的东西
-- hosr
-- ----------------------------------
VersionCheck = VersionCheck or {}

-- 检查该版本是否存在 = 字库是否包含指定字符接口
function VersionCheck.FontContainChar()
	if BaseUtils.IsIPhonePlayer() then
		if BaseUtils.GetLocation() == KvData.localtion_type.cn then
			if BaseUtils.GetPlatform() == "ios" then
				if BaseUtils.CSVersionToNum() > 20402 then
					return true
				end
			end
		end
	end
	return false
end