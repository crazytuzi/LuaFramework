-- Filename：	BulletServices.lua
-- Author：		llp
-- Date：		2015-4-22
-- Purpose：		弹幕网络

module ("BulletServices", package.seeall)

function sendMessage( pCallBack,pArgs )
	-- body
	RequestCenter.newSendMessageCommond(pCallBack, pArgs)
end