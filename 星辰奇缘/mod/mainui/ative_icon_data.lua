-- 动态活动图标数据
-- id 请用大于100的id
-- iconPath 图标图片名，图片需打包入 mainui_textures
-- clickCallBack 点击回调，不可为nil
-- sort 排序优先级 
-- lev 显示等级 
-- text 显示文本， 可传入html格式文本，无则 nil
-- timestamp 计时时间戳，无则 nil
-- timeoutCallBack 计时结束回调，无则 nil

-- createCallBack 创建回调
AtiveIconData = AtiveIconData or BaseClass()

function AtiveIconData:__init()
	self.isAtiveIconIcon = true
	
	self.id = 0
	self.iconPath = ""
	self.clickCallBack = nil
	self.sort = 1
	self.lev = 1
	self.text = nil
	self.timestamp = nil
	self.timeoutCallBack = nil

	self.createCallBack = nil
end