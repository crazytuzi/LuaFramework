--
-- @Author: chk
-- @Date:   2018-09-14 17:00:26
--

ClickGoodsIconEvent = {
	Click = {
		NONE = 0,         --没效果
		REQUEST_INFO = 1,     --向服务端请求查看物品信息
		DIRECT_SHOW = 2,      --直接查看(服务器发过来的信息)
		DIRECT_SHOW_CFG = 3,  --直接查看表中的数据
        BEAST_SHOW = 4,  --和requestinfo差不多,神兽专用
	},
}