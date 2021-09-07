-- ----------------------------
-- 分享推广枚举
-- hosr
-- ----------------------------
ShareEumn = ShareEumn or {}

-- 是否开启分享,现仅开放IOS平台
-- 不开启不对SDK进行初始化
ShareEumn.IsOpen = 1

-- 分享SDK应用id
ShareEumn.SDKAppId = "16dfe5e013918"

-- 微信应用参数
ShareEumn.WeChatAppId = "wxc0d292d7bf417dd3"
ShareEumn.WeChatAppSecret = "3ba47d6132dff0afb281c4b6a028bbf4"

-- qq应用参数
ShareEumn.QQAppId = "1105608727"
ShareEumn.QQAppKey = "gZrcVz8r5CjfvyUd"

-- 微博应用参数
ShareEumn.WeiboAppKey = "2050013913"
ShareEumn.WeiboAppSecret = "bb01c34eabf4235cb631fafb6268b70f"
-- 微博重定向链接
ShareEumn.WeiboRedirectUri = "http://xcqy.kkk5.com/"

-- 分享SDK授权方式
ShareEumn.SDKAuthType = {
	Both = 0, -- 结合SSO和Web授权方式
	SSO = 1, -- SSO授权方式
	Web = 2, -- 网页授权方式
}

-- ------------------
-- 分享内容设置
-- -----------
ShareEumn.TitleList = {
    TI18N("精灵、巨龙、萌妹子，我来了，我征服"),
    TI18N("有可爱萌宠，还有酷炫坐骑，快来开启冒险之旅"),
    TI18N("不花钱也能当大神，绝对良心游戏哦"),
    TI18N("高颜值！手游界的小鲜肉，全新幻想风回合制"),
    TI18N("终于有不是西游背景的回合制啦，快来魔法世界冒险吧"),
}

ShareEumn.ContentList = {
    TI18N("2016回合制巨作《星辰奇缘》倾情巨献"),
    TI18N("《星辰奇缘》燃情公测，好礼送不停"),
    TI18N("顶级画质，好玩不累，《星辰奇缘》等你来玩"),
}

-- 标题
function ShareEumn.Title()
    return ShareEumn.TitleList[math.random(1, #ShareEumn.TitleList)]
end

-- 描述内容
function ShareEumn.Content()
    return ShareEumn.ContentList[math.random(1, #ShareEumn.ContentList)]
end

-- 回调地址
ShareEumn.CallbackUrl = "http://a.app.qq.com/o/simple.jsp?pkgname=com.tencent.tmgp.xcqykkk5"
-- 图片路径
-- （注意：图片必须要在Xcode左边目录里面，名称必须要传正确，如果要分享网络图片，可以这样传iamge参数 images:@[@"http://mob.com/Assets/images/logo.png?v=20150320"]）
-- ShareEumn.ImagePath = "file:///" .. Application.streamingAssetsPath .. "/ShareIcon.png"
ShareEumn.ImagePath = "ShareIcon.png"
-- 官网地址
ShareEumn.OfficialWeb = "http://xcqy.kkk5.com/"

-- 分享类型
ShareEumn.ShareType = {
    -- 自动适配类型，视传入的参数来决定
    SSDKContentTypeAuto  = 0,
    -- 文本
    SSDKContentTypeText = 1,
    -- 图片
    SSDKContentTypeImage = 2,
    -- 网页
    SSDKContentTypeWebPage = 3,
    -- 应用
    SSDKContentTypeApp = 4,
    -- 音频
    SSDKContentTypeAudio = 5,
    -- 视频
    SSDKContentTypeVideo = 6,
    -- 文件类型(暂时仅微信可用)
    SSDKContentTypeFile = 7
}

-- 分享平台类型
ShareEumn.PlatformType = {
	Weibo = 1,
	WeChatFrient = 2,
	WeChatTimeline = 3,
	QQFrient = 4,
	QQZone = 5,
}

