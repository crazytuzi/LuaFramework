module(..., package.seeall)

--GS2C--

function GS2CImages(pbdata)
	local keys = pbdata.keys --图片路径列表
	--todo
end


--C2GS--

function C2GSGetImages()
	local t = {
	}
	g_NetCtrl:Send("image", "C2GSGetImages", t)
end

function C2GSAddImage(key)
	local t = {
		key = key,
	}
	g_NetCtrl:Send("image", "C2GSAddImage", t)
end

