local cfg = {
	 --公告标题
	
		[1]={
	size=22, color="2e3341", x=40, w=810, --y轴偏移量
	s = [[
			欢迎！								
	]]
	},
}

return cfg

-- 里面内容支持UBB格式或html一般的文字 连接 图片标签
-- 如：
-- [size=50]欢迎来到xxx:[/size]  改变字号
-- [url=http://url.com]xxxx[/url]
-- [img=100,100]http://xxxx.png[/img]
-- [img=100,100]res/icon/xxx.png[/img]
-- [color=#fff000]xxx[/color]
-- \n换行\t表格
-- 或者
-- lua中写的
-- [[
-- 内容
-- xxxxxxx
-- xxxxxxxx
   -- xxxxxxxxxx
-- ]]
-- 这样子天然支持换行格式