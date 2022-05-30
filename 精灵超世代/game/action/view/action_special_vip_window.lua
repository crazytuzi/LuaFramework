--******** 文件说明 ********
-- @Author:      hyxing 
-- @description: 
-- @DateTime:    2019-08-29 10:55:47
-- *******************************
ActionSpecialVipWindow = ActionSpecialVipWindow or BaseClass(BaseView)

local controaller = ActionController:getInstance()
function ActionSpecialVipWindow:__init()
    self.is_full_screen = true
    self.win_type = WinType.Big  
    self.view_tag = ViewMgrTag.DIALOGUE_TAG  
    self.layout_name = "action/action_special_vip_window"
    self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("bigbg/specialvip", "txt_cn_specialvip_1_bg"), type = ResourcesType.single},
        {path = PathTool.getPlistImgForDownLoad("bigbg/specialvip", "txt_cn_specialvip_2_bg"), type = ResourcesType.single},
		{path = PathTool.getPlistImgForDownLoad("bigbg/specialvip", "txt_cn_specialvip_2"), type = ResourcesType.single},
	}
end
function ActionSpecialVipWindow:open_callback()
	self.backgroud = self.root_wnd:getChildByName("backgroud")
    if self.backgroud ~= nil then
        self.backgroud:setScale(display.getMaxScale())
    end

	local main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container, 2)
	local image_bg = main_container:getChildByName("image_bg")

    --底图
    local res_bg = "txt_cn_specialvip_2_bg" --诗悦
    if PLATFORM_NAME == "9377" or PLATFORM_NAME == "9377ios" then
        res_bg = "txt_cn_specialvip_1_bg" --9377
    elseif PLATFORM_NAME == "icebird" or PLATFORM_NAME == "bingniao" then
        res_bg = "txt_cn_specialvip_3_bg" --冰鸟
    end
	local res = PathTool.getPlistImgForDownLoad("bigbg/specialvip", res_bg)
    if not self.image_bg_load then
        self.image_bg_load = loadSpriteTextureFromCDN(image_bg, res, ResourcesType.single, self.image_bg_load)
    end

    --前往认证
    local goto_res = "txt_cn_specialvip_2"
    if PLATFORM_NAME == "icebird" or PLATFORM_NAME == "bingniao" then
        goto_res = "txt_cn_specialvip_1"
    end
    local res_1 = PathTool.getPlistImgForDownLoad("bigbg/specialvip", goto_res)
    self.goto_verifi = createImage(main_container, res_1, 200, 275, cc.p(0.5,0.5), false)
    self.goto_verifi:setTouchEnabled(true)
end
function ActionSpecialVipWindow:openRootWnd()
end

function ActionSpecialVipWindow:register_event()
	registerButtonEventListener(self.backgroud, function()
    	controaller:openActionSpecialVIPWindow(false)    
    end,false,2)
	registerButtonEventListener(self.goto_verifi, function()
        self:jumpPlatfrom()
    end,true,1)
end
function ActionSpecialVipWindow:jumpPlatfrom()
    local role_vo = RoleController:getInstance():getRoleVo()
    if role_vo == nil then return end
    local platform, sid = unpack(Split(role_vo.srv_id, "_"))

    if PLATFORM_NAME == "9377" then
        sdkCallFunc("openUrl", string.format("https://wvw.9377.cn/api/getVipLink.php?type=1&sid=%s", sid))
    elseif PLATFORM_NAME == "9377ios" then
        sdkCallFunc("openSyW", string.format("https://wvw.9377.cn/api/getVipLink.php?type=2&sid=%s", sid))
    elseif PLATFORM_NAME == "icebird" or PLATFORM_NAME == "bingniao" then
        local url = string.format("https://oauth.aiyinghun.com/static/slqykf.html?sid=%s",sid)
        if IS_IOS_PLATFORM == true then
            sdkCallFunc("openSyW", url)
        else
            sdkCallFunc("openUrl", url)
        end
    else
        if IS_IOS_PLATFORM == true then
            sdkCallFunc("openSyW", "http://q.url.cn/cdCkXl?_type=wpa&qidian=true")
        else
            sdkCallFunc("openUrl", "http://q.url.cn/cdCkXl?_type=wpa&qidian=true")
        end
    end
end
function ActionSpecialVipWindow:close_callback()
	if self.image_bg_load then
		self.image_bg_load:DeleteMe()
		self.image_bg_load = nil
	end
	controaller:openActionSpecialVIPWindow(false)
end