require("scripts/platform/platform_adapter")

-- 移动文件, return是否成功
function PlatformAdapter.MoveFile(srcpath, dstpath)
	print("PlatformAdapter.MoveFile " .. srcpath .. " -> " .. dstpath)

	return UtilEx:copyFile(srcpath, dstpath)
end
