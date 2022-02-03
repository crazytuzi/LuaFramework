-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      关注公众号
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
SubscriptionWechatPanel = class("SubscriptionWechatPanel", function()
	return ccui.Widget:create()
end) 

function SubscriptionWechatPanel:ctor()
    self.item_list = {}
    self:createRootWnd()
    self:registerEvent()
end

function SubscriptionWechatPanel:createRootWnd()
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("welfare/subscription_wechat_panel"))
	self:addChild(self.root_wnd)
	self:setPosition(-40, -80)
	self:setAnchorPoint(0, 0)

    if WECHAT_SUBSCRIPTION == nil then -- 公众号
        WECHAT_SUBSCRIPTION = "sy_sszg"
    end
    if WECHAT_SUBSCRIPTION_NAME == nil then -- 公众号名字
        WECHAT_SUBSCRIPTION_NAME = "闪烁之光"
    end
    self.wechat_sub_path = PathTool.getWechatSubRes(); -- 公众号二维码资源

    self.main_container = self.root_wnd:getChildByName("main_container")
    self.main_container:getChildByName("txt1"):setString(TI18N("微信搜索:"))
    self.main_container:getChildByName("txt2"):setString(string.format(TI18N("%s (%s)公众号"), WECHAT_SUBSCRIPTION_NAME, WECHAT_SUBSCRIPTION))

    local desc = TI18N("关注点击「福利宝匣」领取礼包码")
    if WECHAT_SUBSCRIPTION_DESC then
        desc = WECHAT_SUBSCRIPTION_DESC
    else
        if PLATFORM_NAME == "9377" or PLATFORM_NAME == "9377ios" then
            desc = TI18N("关注点击【福利补给】领取礼包码")
        elseif PLATFORM_NAME == "icebird" or PLATFORM_NAME == "bingniao" then
            desc = TI18N("关注点击「福利补给」领取礼包码")
        end
    end
    self.main_container:getChildByName("txt3"):setString(desc)

    self.item_container = self.main_container:getChildByName("item_container")

    self.bg = self.main_container:getChildByName("bg")
    self.code_sprite_bg = self.main_container:getChildByName("code_sprite_bg")
    self.code_sprite = self.main_container:getChildByName("code_sprite")
    self.save_btn = self.main_container:getChildByName("save_btn")
    self.save_btn:getChildByName("Text_6"):setString(TI18N("保存至相册"))

    -- 加载背景
    self:loadBackground()
    -- 设置物品展示
    self:setItemList()
    -- 告诉服务端激活了查看公众号
	WelfareController:getInstance():tellServerWechatStatus()
end

function SubscriptionWechatPanel:loadBackground()
    local bg_path = PathTool.getPlistImgForDownLoad("bigbg/welfare", "txt_cn_subscription_wechat") 
    self.loader = loadSpriteTextureFromCDN(self.bg, bg_path, ResourcesType.single)

    loadSpriteTexture(self.code_sprite, self.wechat_sub_path, LOADTEXT_TYPE)
    local size = self.code_sprite_bg:getContentSize()
    local scale = size.width / 275
    self.code_sprite:setScale(scale)
end

function SubscriptionWechatPanel:registerEvent()
    registerButtonEventListener(self.save_btn, function()
        if FINAL_CHANNEL == "syios_smzhs" then
            message(TI18N("暂不支持"))
            return
        end
        self:savePhotoPicture()
    end,true, 1)
end
--保存图片
function SubscriptionWechatPanel:savePhotoPicture()
    if not IS_IOS_PLATFORM and callFunc("checkWrite") == "false" then return end
    if self.poste_picture then return end
    local container = ViewManager:getInstance():getLayerByTag( ViewMgrTag.LOADING_TAG )
    self.poste_picture = createSprite("", SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.5, container, cc.p(0.5, 0.5),LOADTEXT_TYPE)
    self.poste_picture:setScale(display.getMaxScale())
    --保存图片
    self:savePhotoText(self.poste_picture,false)

    local res = PathTool.getPlistImgForDownLoad("bigbg/welfare", "txt_cn_subscription_wechat_1")
    self.sprite_load = createResourcesLoad(res, ResourcesType.single, function()
        if not tolua.isnull(self.poste_picture) then
            loadSpriteTexture(self.poste_picture, res , LOADTEXT_TYPE)
            if self.save_layout then
                self.save_layout:setVisible(true)
            end
            local fileName = cc.FileUtils:getInstance():getWritablePath().."poste_wechat.png"
            delayOnce(function()
                cc.utils:captureScreen(function(succeed)
                    if succeed then
                        saveImageToPhoto(fileName,3)
                    else
                        message(TI18N("保存失败"))
                    end
                    if not tolua.isnull(self.poste_picture) then
                        self.poste_picture:removeFromParent()
                        self.poste_picture = nil
                    end
                end, fileName)
            end, 0.01)
        end
    end,self.sprite_load)
end
--截图保存的内容
function SubscriptionWechatPanel:savePhotoText(node,visible)
    if not node then return end
    self.save_layout = ccui.Layout:create()
    self.save_layout:setPosition(49,650)
    self.save_layout:setContentSize(cc.size(100,100))
    node:addChild(self.save_layout)
    self.save_layout:setVisible(visible)

    local search = createLabel(24,cc.c4b(0xf7,0xfd,0xff,0xff),cc.c4b(0x14,0x35,0x6c,0xff),7,87,TI18N("微信搜索:"),self.save_layout,2, cc.p(0,0.5))

    local str_wechat = string.format(TI18N("%s (%s)公众号"),WECHAT_SUBSCRIPTION_NAME, WECHAT_SUBSCRIPTION)
    local wechat_text = createLabel(24,cc.c4b(0xf7,0xfd,0xff,0xff),cc.c4b(0x14,0x35,0x6c,0xff),7,47,str_wechat,self.save_layout,2, cc.p(0,0.5))
    local attent_text = createLabel(24,cc.c4b(0xf7,0xfd,0xff,0xff),cc.c4b(0x14,0x35,0x6c,0xff),7,7,TI18N("关注点击「福利补给」领取礼包码"),self.save_layout,2, cc.p(0,0.5))
    --二维码图片
    local erweima_bg = createSprite(self.wechat_sub_path,300,-340,self.save_layout,cc.p(0.5,0.5),LOADTEXT_TYPE)
    --奖励
    local reward_node = ccui.Layout:create()
    reward_node:setPosition(149,475)
    reward_node:setContentSize(cc.size(100,100))
    node:addChild(reward_node)
    self:setCopyItemList(reward_node)
end
function SubscriptionWechatPanel:setCopyItemList(node)
    local data = WelfareController:getInstance():getWechatData()
    if data == nil or data.items == nil then return end
    for i, v in ipairs(data.items) do
        local item = BackPackItem.new(false, true, false, 1, false, true)
        node:addChild(item)
        item:setPosition(77 +(i - 1) * 138, 77)
        item:setBaseData(v.bid, v.num)
    end
end
--==============================--
--desc:创建展示物品
--time:2019-01-28 08:01:48
--@return 
--==============================--
function SubscriptionWechatPanel:setItemList()
    local data = WelfareController:getInstance():getWechatData()
    if data == nil or data.items == nil then return end

	for i, v in ipairs(data.items) do
		if self.item_list[i] == nil then
			self.item_list[i] = BackPackItem.new(false, true, false, 1, false, true)
			self.item_container:addChild(self.item_list[i])
			self.item_list[i]:setPosition(77 +(i - 1) * 138, 77)
		end
		local item = self.item_list[i]
		item:setBaseData(v.bid, v.num)
	end
end

function SubscriptionWechatPanel:setVisibleStatus(status)
	bool = bool or false
	self:setVisible(status)
end

function SubscriptionWechatPanel:DeleteMe()
    if self.loader then
        self.loader:DeleteMe()
    end
    self.loader = nil

    if self.sprite_load then
        self.sprite_load:DeleteMe()
    end
    self.sprite_load = nil
    if not tolua.isnull(self.poste_picture) then
        self.poste_picture:removeFromParent()
        self.poste_picture = nil
    end

    if self.item_list then
        for k,v in pairs(self.item_list) do
            v:DeleteMe()
        end
        self.item_list = nil
    end
end