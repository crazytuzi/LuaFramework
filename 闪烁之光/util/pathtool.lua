PathTool = PathTool or {}

PathTool.DEFAULT_IMAGE = "resource/common/common_miss_image.png"

local string_format = string.format
local sprite_frame = cc.SpriteFrameCache:getInstance() 

-- 检查资源是否存在
_file_exist_list = _file_exist_list or {}

--==============================--
--desc:检测资源是否存在,不存在就判断是否需要从cdn上下载
--time:2017-07-14 01:58:42
--@path:
--@return 
--==============================--
function PathTool.isFileExist(path)
	if type(path) ~= "string" then return false end
	local bool
	if _file_exist_list[path] ~= nil then
		bool = _file_exist_list[path]
	else
		bool = cc.FileUtils:getInstance():isFileExist(path)
		_file_exist_list[path] = bool
	end	
	if IS_REQUIRE_RES_GY == true and not MAKELIFEBETTER and string.find(path, ".atlas") ~= nil then
		if bool then
			path = string.gsub(path, ".atlas", ".png")
			if _file_exist_list[path] ~= nil then
				bool = _file_exist_list[path]
			else
				bool = ResourcesLoadMgr:getInstance():checkDirFull(path)
				_file_exist_list[path] = bool
			end
		end
		if not bool then
			ResourcesLoadMgr:getInstance():checkResouces(path, true)
		end
	end
	return bool
end

--==============================--
--desc:检测资源是否存在,不存在就使用默认资源
--time:2017-07-14 02:03:24
--@path:
--@return 
--==============================--
function PathTool.checkRes(path)
	local isExist = PathTool.isFileExist(path)
	if isExist then
		return path
	else
		if not MAKELIFEBETTER then
			if string.find(path, ".png") ~= nil or string.find(path, ".jpg") ~= nil and IS_REQUIRE_RES_GY == true then
				print(string_format("============> 警告：资源 %s 不存在，尝试去cdn上下载", path))
				ResourcesLoadMgr:getInstance():checkResouces(path, true)
			end
		end
		return PathTool.DEFAULT_IMAGE
	end
end

------------------------------------------全局一些同类型资源获取的唯一接口------------------
-- 获取选中背景,通用
function PathTool.getSelectBg()
	return PathTool.getResFrame("common", "common_90019")
end

-- 获取技能的默认底框
function PathTool.getNormalSkillBg()
	return PathTool.getResFrame("common", "common_1005")
end

-- 基础背景框,用于头像和物品的
function PathTool.getNormalCell()
	return PathTool.getResFrame("common", "common_1005")
end


PathTool.AttrIcon = {
	["atk"] 		= "common_90021", --攻击
	["atk_per"]		= "common_90021", --攻击
	["hp"] 			= "common_90022", --血
	["hp_max"] 		= "common_90022", --血
	["hp_max_per"]  = "common_90022", --血
	["def"] 		= "common_90023", --防御
	["def_per"] 	= "common_90023", --防御
	["speed"] 		= "common_90038", --速度
	["crit_rate"] 	= "common_90043", --暴击率
	["crit_ratio"] 	= "common_90039", --暴伤害
	["hit_magic"] 	= "common_90040", --控制
	["dodge_magic"] = "common_90037", --抗控
	["tenacity"] 	= "common_90021_1", --抗暴
	["hit_rate"] 	= "common_90021_2", --命中
	["res"] 		= "common_90021_3", --免伤
	["dodge_rate"] 	= "common_90021_4", --闪避
	["cure"] 		= "common_90021_5", --治疗
	["be_cure"] 	= "common_90021_6", --被治疗
	["dam"] 		= "common_90021_7", --伤害加成

	["dam_p"]       = "common_90021", --物伤
	["dam_s"]       = "common_90021", --法伤
	["res_p"]       = "common_90021_3", --物免
	["res_s"]       = "common_90021_3", --法免

	--特殊符号
	["random"] 		= "common_90021_8", --问号 随机属性符号
	["skill"] 		= "common_90021_9", --技能专属符号
}
--获取属性图标
function PathTool.getAttrIconByStr(str)
	if PathTool.AttrIcon[str] then
		return  PathTool.AttrIcon[str]
	end
	return "common_90037"
end

-- 获取checkbox背景资源
function PathTool.getCheckBoxRes()
	local bg = PathTool.getResFrame("common", "common_1044")
	local select_bg = PathTool.getResFrame("common", "common_1043")
	return bg, select_bg
end

-- 获取checkbox背景资源
function PathTool.getCheckBoxRes_2()
	local bg = PathTool.getResFrame("mainui", "mainui_caht_box")
	local select_bg = PathTool.getResFrame("mainui", "mainui_caht_box_s")
	return bg, select_bg
end

-- 获取伙伴职业的图标
function PathTool.getCareerIcon(career)
	career = career  or 1
	local career_id = 90045 + career
	return PathTool.getResFrame("common", string_format("common_%s", career_id))
end

-- 获取品质框背景
function PathTool.getQualityBg(quality)
	local quality = quality or 1
	if quality > 5 then
		quality = 5
	end
	quality = 1005 + quality
	local res_id = "common_" .. quality
	return PathTool.getResFrame("common", res_id)
end

-- 获取品质框背景(圆形的)
function PathTool.getRoundQualityBg(quality)
	local quality = quality or 1
	if quality > 5 then
		quality = 5
	end
	quality = 2000 + quality
	local res_id = "mainui_" .. quality
	return PathTool.getResFrame("mainui", res_id)
end

-- 获取进度条背景 根据品质
function PathTool.getBarQualityBg(quality)
	local quality = quality or 0
	if quality == BackPackConst.quality.red then
		return PathTool.getResFrame("common", "common_90006_5")
	elseif quality == BackPackConst.quality.green then
		return PathTool.getResFrame("common", "common_90006")
	elseif quality == BackPackConst.quality.blue then
		return PathTool.getResFrame("common", "common_90006_2")
	elseif quality == BackPackConst.quality.purple then
		return PathTool.getResFrame("common", "common_90006_3")
	elseif quality == BackPackConst.quality.orange then
		return PathTool.getResFrame("common", "common_90006_4")
	else--if quality == 0 then
		return PathTool.getResFrame("common", "common_90006_1") --白色
	end
end
-- 获取装备品质阶数框
function PathTool.getEnchantQualityIcon(quality)
	if quality == nil then
		quality = 1
	elseif quality > 5 then
		quality = 5
	end
	local res_id = "common_9006" .. quality
	return PathTool.getResFrame("common", res_id)
end

--==============================--
--desc:获取游戏logo
--time:2018-08-03 10:14:08
--@type:
--@return 
--==============================--
function PathTool.getLogoRes()
    local logo_res = string.format("resource/login/%s/txt_cn_logo.png", PLATFORM_PNG) 
    if isVestPackage() == true then
        logo_res = ROOT_DIR.."logo_sy.png"
    elseif PathTool.useMainLogo() == true then 		 -- 自家闪烁之光.不管怎么都用
    	logo_res = "resource/login/app/txt_cn_logo.png"
    end
    return logo_res
end

function PathTool.useMainLogo()
	if FINAL_CHANNEL == "syios_symphony" then
		return true
	end
	return false
end

--==============================--
--desc:获取游戏加载页
--time:2018-08-03 10:14:08
--@type:
--@return 
--==============================--
function PathTool.getLoadingRes()
	local loading_res = string.format("resource/login/%s/first_loading_bg.jpg", PLATFORM_PNG)
    if isVestPackage() == true then -- 我们自己的融合包 				
        loading_res = ROOT_DIR.."loading_bg_sy.jpg"
    elseif PathTool.is9377Platform() then
    	loading_res = "resource/login/9377/loading_bg.jpg"
    elseif PathTool.checkSpecialChannel() == true then -- 部分特殊渠道需要用到诗悦的登录页
    	loading_res = "resource/login/app/first_loading_bg.jpg"
    end
	return loading_res
end

function PathTool.is9377Platform()
	-- if IS_IOS_PLATFORM == true and MAKELIFEBETTER == true then
	-- 	return false
	-- elseif PLATFORM_NAME == "9377" or PLATFORM_NAME == "9377ios" then
	-- 	return true
	-- elseif FINAL_CHANNEL and type(FINAL_CHANNEL) == "string" and string.find(FINAL_CHANNEL, "9377") then
	-- 	return true
	-- end
	return false
end

--- 特殊专服渠道要设置跟我们一样的登录页
function PathTool.checkSpecialChannel()
	if IS_NOT_USE_SY_LOGIN == true then  -- 如果冰鸟或者9377一些渠道直接不用我们自己的
		return false
	else
		if not IS_IOS_PLATFORM then
			if FINAL_CHANNEL == "bingniaoysjx" or FINAL_CHANNEL == "9377mtzx" then
				return false
			else
				if PLATFORM_NAME == "9377" or PLATFORM_NAME == "icebird" or PLATFORM_NAME == "bingniao" then
					return true
				elseif FINAL_CHANNEL and type(FINAL_CHANNEL) == "string" then
					if FINAL_CHANNEL == "tanwan" then
						return true
					elseif string.find(FINAL_CHANNEL, "9377") ~= nil then
						return true
					elseif string.find(FINAL_CHANNEL, "bingniao") ~= nil then
						return true
					end
				end
			end
		else
			if MAKELIFEBETTER == true then
				return false
			else
				if FINAL_CHANNEL == "syios_symphony" then
					return true
				elseif FINAL_CHANNEL == "syios_fzyz" or FINAL_CHANNEL == "syios_djsdmm" or FINAL_CHANNEL == "syios_gmzhs" or FINAL_CHANNEL == "ssgc_D1" or FINAL_CHANNEL == "9377_wiseInfo" then -- ios的放置勇者 大祭司秘密和光明召唤师
					return true
				elseif PLATFORM_NAME == "9377ios" then
					return true
				end
			end
		end
	end
	return false
end

--==============================--
--desc:获取游戏登录页
--time:2018-08-03 10:14:08
--@type:
--@return 
--==============================--
function PathTool.getLoginRes()
	local login_res = string.format("resource/login/%s/loading_bg.jpg", PLATFORM_PNG)
    if isVestPackage() == true then
        login_res = ROOT_DIR.."loading_bg1_sy.jpg"
    elseif PathTool.is9377Platform() then
    	login_res = "resource/login/9377/loading_bg.jpg"
    elseif PathTool.checkSpecialChannel() == true then
    	login_res = "resource/login/app/loading_bg.jpg"
    end
	return login_res
end

--==============================--
--desc:获取游戏闪屏页
--time:2018-08-03 10:14:08
--@type:
--@return 
--==============================--
function PathTool.getFlashRes()
	local flash_res = string.format("resource/login/%s/flash.jpg", PLATFORM_PNG)
    if isVestPackage() == true then
        flash_res = ROOT_DIR.."flash.jpg"
    end
    if PathTool.isFileExist(flash_res) == false then
        flash_res = "resource/login/app/flash.jpg"
    end
	return flash_res
end

--==============================--
--desc:获取微信公众号的路径
--time:2019-06-15 04:06:07
--@return 
--==============================--
function PathTool.getWechatSubRes()
	if WECHAT_SUBSCRIPTION_IMG == nil then
		WECHAT_SUBSCRIPTION_IMG = "wechat_subscription_sszg"
	end
	local wechat_res = string.format("resource/platform/%s.png", WECHAT_SUBSCRIPTION_IMG)
	return wechat_res
end

--==============================--
--desc:获取伙伴类型的
--time:2018-08-03 10:14:08
--@type:
--@return 
--==============================--
function PathTool.getPartnerTypeIcon(_type)
	_type = _type or 1
	local _index = 45 + _type
	return PathTool.getResFrame("common", "common_900".._index) 
end

--==============================--
--desc:获取伙伴阵营图标路径 --by lwc
--time:2018年11月19日
--@type: 阵营类型 参考 HeroConst.CampType
--@return 
--==============================--
function PathTool.getHeroCampTypeIcon(_type)
	_type = _type or 1
	if _type == HeroConst.CampType.eWater then --水
		return PathTool.getResFrame("common", "common_90067")
	elseif _type == HeroConst.CampType.eFire then
		return PathTool.getResFrame("common", "common_90068")
	elseif _type == HeroConst.CampType.eWind then
		return PathTool.getResFrame("common", "common_90069")
	elseif _type == HeroConst.CampType.eLight then
		return PathTool.getResFrame("common", "common_90070")
	elseif _type == HeroConst.CampType.eLingtDark then
		return PathTool.getResFrame("common", "common_90079")
	else--if _type == HeroConst.CampType.eDark then
		return PathTool.getResFrame("common", "common_90071")
	end
end

-- 获取阵营组合图标
function PathTool.getCampGroupIcon( res_id )
	if res_id == 0 then res_id = 1000 end
	return PathTool.checkRes(string_format("resource/campicon/campicon_%s.png", res_id))
end

-- 获取物品图标资源
function PathTool.getItemRes(res_id, bool)
	return PathTool.checkRes(string_format("resource/item/%s.png", res_id))
end

--==============================--
--desc:获得红钻消耗展示图标,特殊处理是红蓝钻样子
--time:2018-01-02 11:54:15
--@icon_id:item_data中配置的icon,因为有一些引用是根据配置表的处处理
--@return 
--==============================--
function PathTool.getRedGoldRes(icon_id)
	return PathTool.getItemRes(icon_id)
end
--==============================--
--desc:获取提示图标
--time:2017-12-20 11:04:20
--@id:
--@return 
--==============================--
function PathTool.getPromptRes(res_id)
	return PathTool.checkRes(string_format("resource/prompt/prompt_%s.png", res_id))
end

--==============================--
--desc:获取部分场景需要的缩略图
--time:2017-12-20 02:34:19
--@scene_id:
--@return 
--==============================--
function PathTool.getPreviewBg(scene_id)
	return PathTool.checkRes(string_format("scene/preview/%s.jpg", scene_id))
end

-- 获取联盟等级图标
function PathTool.getGuildLevIcon(lev, bool)
	return PathTool.checkRes(string_format("resource/guild/icon/guild_lev_%s.png", lev))
end

--==============================--
--desc:聊天用的半身像
--time:2018-01-16 08:53:32
--@res_id:
--@return 
--==============================--
function PathTool.getTalkNpcImg(res_id)
	return PathTool.checkRes(string_format("resource/talknpc/talknpc_%s.png", res_id))
end

--==============================--
--desc:获取配置表中的资源id吧
--time:2017-08-13 01:42:34
--@id:
--@return 
--==============================--
function PathTool.getEffectRes(id)
	return Config.EffectData.data_effect_info[id] or "E88888"
end

--==============================--
--desc:获取活动相关的资源
--time:2017-08-08 08:09:03
--@res_id:
--@bool:是否是jpg
--@return 
--==============================--
function PathTool.getActionRes(res_id, bool)
	if bool then
		return PathTool.checkRes(string_format("resource/action/%s.jpg", res_id))
	else
		return PathTool.checkRes(string_format("resource/action/%s.png", res_id))
	end
end
--==============================--
--desc:获取活动top_banner的资源
--time:2017-08-08 08:09:03
--@res_id:
--@bool:是否是jpg
--@return 
--==============================--
function PathTool.getActionTopBannerRes(res_id, bool)
	if bool then
		return PathTool.checkRes(string_format("resource/action/top_banner/%s.jpg", res_id))
	else
		return PathTool.checkRes(string_format("resource/action/top_banner/%s.png", res_id))
	end
end

--获取超值活动资源
function PathTool.getActionZeroGiftRes(res_id, bool)
	if bool then
		return PathTool.checkRes(string_format("resource/action_zero_gift/zero_gift/%s.jpg", res_id))
	else
		return PathTool.checkRes(string_format("resource/action_zero_gift/zero_gift/%s.png", res_id))
	end
end

--获取伙伴散文件接口
function PathTool.getPartnerIconRes(res_id, bool)
	if bool then
		return PathTool.checkRes(string_format("resource/partner_icon/%s.jpg", res_id))
	else
		return PathTool.checkRes(string_format("resource/partner_icon/%s.png", res_id))
	end
end

--获取精英段位赛排名图标
function PathTool.getEliteIconRes(res_id)
	return PathTool.checkRes(string_format("resource/elitematch/elitematch_icon/%s.png", res_id))
end
--==============================--
--desc:空白内容的地图
--time:2017-07-27 10:18:02
--@return 
--==============================--
function PathTool.getEmptyMark()
	return PathTool.checkRes(string_format("resource/bigbg/bigbg_3.png"))
end

--==============================--
--desc:获取游戏图标的接口
--time:2017-07-26 09:10:59
--@res_id:
--@return 
--==============================--
function PathTool.getFunctionRes(res_id)
	return PathTool.checkRes(string_format("resource/functionicon/%s.png", res_id))
end

-- 获取世界地图的板块地图资源路径
function PathTool.getWorldMapRes(id)
	return PathTool.checkRes(string_format("resource/worldmap/worldmap_mainland_%s.png", id))
end

-- 获取头像的资源
function PathTool.getHeadIcon(res)
	if res == nil or res == 0 or res == 30000 then
		res = 1001
	end
	return PathTool.checkRes(string_format("resource/headicon/%s.png", res))
end

-- 获取头像的资源
function PathTool.getElfinHeadIcon(res)
	if res == nil or res == 0 then
		res = 113001
	end
	return PathTool.checkRes(string_format("resource/elfin/elfinicon/%s.png", res))
end


--==============================--
--desc:获取头像框
--time:2017-10-16 07:45:31
--@res:
--@return 
--==============================--
function PathTool.getHeadcircle(id)
	id = id or 0
	return PathTool.checkRes(string_format("resource/headcircle/txt_cn_headcircle_%s.png", id))
end

-- 获取技能图标资源
function PathTool.getSkillRes(res_id)
	res_id = res_id or 20003
	return PathTool.checkRes(string_format("resource/skillicon/%s.png", res_id))
end

-- 获取英雄图标资源
--==============================--
--desc:
--time:2017-12-14 09:26:11
--@res_id:
--@set_id:时装id，不填默认为0
--@return 
--==============================--
function PathTool.getPokedexRes(res_id, set_id)
	set_id = set_id or 0
	res_id = res_id or 30009
	return PathTool.checkRes(string_format("resource/partnerpaint/%s/partnerpaint_%s.png", set_id, res_id))
end

--获取图鉴套装图片
function PathTool.getSuitRes(res_id)
	return PathTool.checkRes(string_format("resource/hero/holy_eqm_icon/%s_icon.png",res_id))
end

-- 获取buff图标资源
function PathTool.getBuffRes(res_id, bool)
	return PathTool.checkRes(string_format("resource/bufficon/%s.png", res_id))
end

-- 获取大的buff图标资源（buff总览界面）
function PathTool.getBigBuffRes( res_id )
	return PathTool.checkRes(string_format("resource/bigbufficon/%s.png", res_id))
end

-- 获取shader.fsh路径
function PathTool.getShaderRes(res_id)
	local path = string_format("shaders/%s.fsh", res_id)
	if PathTool.isFileExist(path) == false then
		path = ""
	end
	return path
end

-- 用于从cdn下载战斗资源的接口
function PathTool.getBattleSceneRes(resName, is_jpg)
	if is_jpg == true then
		return string_format("resource/bigbg/battle_bg/%s.jpg", resName)
	else
		return string_format("resource/bigbg/battle_bg/%s.png", resName)
	end
end

--- 战斗里面需要用到的图片icon
function PathTool.getBattleDramaIconRes(resName)
	return PathTool.checkRes(string_format("resource/battle/icon/%s.png", resName))
end

--获取七天登录资源
function PathTool.getSevenLoginRes(res_id, bool)
	if bool then
		return PathTool.checkRes(string_format("resource/action/seven_login/%s.jpg", res_id))
	else
		return PathTool.checkRes(string_format("resource/action/seven_login/%s.png", res_id))
	end
end
------------------------------------------------------------------------------
--热点英雄获取英雄资源
function PathTool.getActionTreasureHeroRes(res_id, bool)
	if bool then
		return PathTool.checkRes(string_format("resource/actiontreasure/hero/%s.jpg", res_id))
	else
		return PathTool.checkRes(string_format("resource/actiontreasure/hero/%s.png", res_id))
	end
end

--热点英雄获取top_icon资源
function PathTool.getActionTreasureTopIconRes(res_id, bool)
	if bool then
		return PathTool.checkRes(string_format("resource/actiontreasure/top_banner/%s.jpg", res_id))
	else
		return PathTool.checkRes(string_format("resource/actiontreasure/top_banner/%s.png", res_id))
	end
end

-- 获取神器图标资源
function PathTool.getArtifactItemRes(res_id, bool)
	return PathTool.checkRes(string_format("resource/artifacticon/%s.png", res_id))
end

--[[	统一接口,获取制定资源
	@param packageName: resource目录下文件夹名字; 例:common,也可以是common/btn
	@param resName: 具体资源名称
	@param is_plist: 是否是plist文件,如果是,则返回的是plist和prv.ccz文件,
	@param is_jpg: 是否是jpg格式,实际游戏中,尽量少使用jpg文件,
]]
function PathTool.getTargetRes(packageName, resName, is_plist, is_jpg)
	is_plist = is_plist and true
	if is_plist then
		local plist = string_format("resource/%s/%s.plist", packageName, resName)
		local texture = PathTool.checkRes(string_format("resource/%s/%s.png", packageName, resName))
		return plist, texture
	else
		if is_jpg then
			return PathTool.checkRes(string_format("resource/%s/%s.jpg", packageName, resName))
		else
			return PathTool.checkRes(string_format("resource/%s/%s.png", packageName, resName))
		end
	end
end

--==============================--
--desc:获取模块的图集图片
--time:2018-04-24 08:31:25
--@packageName:
--@resName:
--@return 
--==============================--
function PathTool.getPlistImgForDownLoad(packageName, resName, is_jpg)
	if is_jpg == true then
		return string_format("resource/%s/%s.jpg", packageName, resName)
	else
		return string_format("resource/%s/%s.png", packageName, resName)
	end
end

--==============================--
--desc:获得UI里面的资源
--time:2017-11-01 05:57:36
--@res:
--@is_jpg:
--@return 
--==============================--
function PathTool.getUiRes(res, is_jpg)
	if is_jpg == true then
		return PathTool.checkRes(string_format("resource/ui/%s.jpg", res))
	else
		return PathTool.checkRes(string_format("resource/ui/%s.png", res))
	end
end

--[[    获取csb面板数据
]]
function PathTool.getTargetCSB(resName)
	return PathTool.checkRes(string_format("csb/%s.csb", resName))
end

--[[    获取图集图片
]]
function PathTool.getTargetPng(packageName, resName)
	return PathTool.checkRes(string_format("resource/%s/%s.png", packageName, resName))
end

--==============================--
--desc:查找是否存在该精灵对象,如果没有,则使用默认资源
--time:2018-09-11 02:07:38
--@packageName:文件夹名,其实对精灵对象没有意义
--@resName:精灵名,保证全局唯一
--@is_jpg:是否是jpeg
--@plist_file:指定的plist名,暂时废弃,查找不到太精灵名字,就直接认为没有
--@call_back:回调,废弃
--@return 
--==============================--
function PathTool.getResFrame(packageName, resName, is_jpg, plist_file, call_back)
	if is_jpg == true then
		resName = string.format("%s.jpg", resName)
	else
		resName = string.format("%s.png", resName)
	end
	plist_file = plist_file or packageName
	local function loading_callback(dataFilename, imageFilename)
		if not cc.SpriteFrameCache:getInstance():getSpriteFrame(resName) then
			resName = string_format("%s.png", "common_99999") 
		end
		if not call_back then
		else
			call_back(resName)
		end
	end
	
	local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(resName)
	if not frame then
		local plist, prvCcz = PathTool.getTargetRes(packageName, plist_file, true)
		if display.isSpriteFramesWithFileLoaded(plist) then
			resName = string_format("%s.png", "common_99999") 
			return resName
		else
			display.loadSpriteFrames(plist, prvCcz, loading_callback)
			resName = string_format("%s.png", "common_99999")
			return resName
		end
	else
		return resName
	end
end 

--获取地图
function PathTool.getMapRes(id, isjpeg)
	local subfix = ".png"
	if isjpeg then
		subfix = ".jpg"
	end
	return PathTool.checkRes(string_format("scene/preview/%s%s", id, subfix))
end

--获取小地图
function PathTool.getLittleMapRes(id, isjpeg)
	local subfix = ".png"
	if isjpeg then
		subfix = ".jpg"
	end
	return PathTool.checkRes(string_format("scene/map/%s%s", id, subfix))
end

--==============================--
--desc:音效设置
--time:2018-04-24 02:41:32
--@sound_type:
--@sound_name:
--@return 
--==============================--
function PathTool.getSound(sound_type, sound_name)
	local path = string_format("sound/%s/%s.mp3", "scene", "s_001")
	if sound_type == AudioManager.AUDIO_TYPE.COMMON then
		path = string_format("sound/%s/%s.mp3", sound_type, sound_name)
	elseif sound_type == AudioManager.AUDIO_TYPE.SCENE then
		path = string_format("sound/%s/%s.mp3", sound_type, sound_name)
	elseif sound_type == AudioManager.AUDIO_TYPE.BATTLE then
		path = string_format("sound/%s/%s.mp3", sound_type, sound_name)
	elseif sound_type == AudioManager.AUDIO_TYPE.DUBBING then
		path = string_format("sound/%s/%s.mp3", sound_type, sound_name)
	elseif sound_type == AudioManager.AUDIO_TYPE.Recruit then
    	path = string_format("sound/%s/%s.mp3", sound_type, sound_name)
    elseif sound_type == AudioManager.AUDIO_TYPE.Drama then
    	path = string_format("sound/%s/%s.mp3", sound_type, sound_name)
	end
	return path	
end

-- [音频] 检测是否存在
function PathTool.checkSound(file_name)
	return cc.FileUtils:getInstance():isFileExist(PathTool.getVoicePath(file_name))
end

function PathTool.getVoicePath(file_name)
	local dir = string_format("%svoice", cc.FileUtils:getInstance():getWritablePath())
	if not cc.FileUtils:getInstance():isDirectoryExist(dir) then
		cc.FileUtils:getInstance():createDirectory(dir)
	end
	return string_format("%svoice/%s", cc.FileUtils:getInstance():getWritablePath(), file_name)
end

function PathTool.getVerificationcodePath(file_name)
	local dir = string_format("%sverificationcode", cc.FileUtils:getInstance():getWritablePath())
	if not cc.FileUtils:getInstance():isDirectoryExist(dir) then
		cc.FileUtils:getInstance():createDirectory(dir)
	end
	return string_format("%sverificationcode/%s.png", cc.FileUtils:getInstance():getWritablePath(), file_name)
end
--------------------------------------骨骼相关----------------------------------------
-- 这里跟RoleVo.restype 要一直
SpineTypeByFristLetter =
{
	['R'] = "role",       -- 主角
	['W'] = "role",       -- 武器
	['M'] = "mon",        -- 怪物
	['N'] = "mon",        -- NPC
	['H'] = "hero",       -- 伙伴
	['S'] = "hero",       -- 伙伴饰品
	['E'] = "ele",        -- 特效类
}

--==============================--
--desc:获取spine路径的接口
--time:2018-01-06 09:36:27
--@spine_name:spine名称,对应的文件夹名字
--@action_name:动作名,对应文件下文件名字
--@return: skel:二进制文件 atlas:配置文件 png:spine图集, spine_path:真实路径, spine_name:可能经过替代资源转换的
--==============================--
function PathTool.getSpineByName(spine_name, action_name)
	local spine_path = ""
	if action_name == nil then
		spine_path = string_format("spine/%s/action", spine_name)
	else
		spine_path = string_format("spine/%s/%s", spine_name, action_name)
	end
	local skel = string_format("%s.skel", spine_path)
	local atlas = string_format("%s.atlas", spine_path)
	local png = string_format("%s.png", spine_path)
	if not PathTool.isFileExist(atlas) then
		print(spine_path .. "    不存在")
		if not force then
			skel, atlas, png, spine_path, spine_name = PathTool.defaultSpine(spine_name, action_name, true)
		end
	end
	return skel, atlas, png, spine_path, spine_name
end

--==============================--
--desc:替代资源,没有资源的时候,直接给一个空资源做替代,免得报错
--time:2017-06-19 09:01:12
--@spine_name:
--@action_name:
--@force:
--@return 
--==============================--
function PathTool.defaultSpine(spine_name, action_name)
	local default_spine_name = "E88888"
	if spine_name ~= nil then
		local frist_letter = string.sub(spine_name, 1, 1)
		if frist_letter == "H" then
			default_spine_name = "H99999"
		end
	end
	
	local spine_path = ""
	if action_name == nil then
		spine_path = string_format("spine/%s/action", default_spine_name)
	else
		spine_path = string_format("spine/%s/%s", default_spine_name, action_name)
	end
	local skel = string_format("%s.skel", spine_path)
	local atlas = string_format("%s.atlas", spine_path)
	local png = string_format("%s.png", spine_path)
	
	return skel, atlas, png, spine_path, default_spine_name
end

--==============================--
--desc:这类单位是没有show动作的,所以要特殊处理
--time:2017-11-08 12:05:35
--@id:
--@return 
--==============================--
function PathTool.specialBSModel(id)
	return id == 37300 or id == 37301 or id == 37302
end

--==============================--
--desc:这里是判断图片资源是否存在的，不同于
--time:2018-04-20 05:33:34
--@path:
--@return 
--==============================--
function PathTool.checkResourcesExist(path)
	if _file_exist_list[path] then
		return true
	elseif cc.FileUtils:getInstance():isFileExist(path) then
		_file_exist_list[path] = true
		return true
	else
		return false
	end
end

--==============================--
--desc:开始下载资源，data包含了资源路径，和类型，
--time:2018-04-23 12:18:28
--@data:
--@return 
--==============================--
function PathTool.downloadResources(data, callback)
	if data == nil or data.path == nil or MAKELIFEBETTER == true then
		callback(data)
		return
	end
	if _file_exist_list[path] == true then
		if callback ~= nil then
			callback(data)
		end
	else
		ResourcesLoadMgr:getInstance():checkResouces(data.path, true, callback, data)
	end
end 


function PathTool.getWelfareBannerRes(res_id, bool)
	if bool then
		return PathTool.checkRes(string_format("resource/welfare/welfare_banner/%s.jpg", res_id))
	else
		return PathTool.checkRes(string_format("resource/welfare/welfare_banner/%s.png", res_id))
	end
end

--回归活动banner
function PathTool.getReturnWelfareBannerRes(res_str)
	return string_format("resource/welfare/welfare_return/%s.png", res_str)
end

-- 获取伙伴半身像资源
function PathTool.getPartnerBustRes(bust_id)
	bust_id = bust_id or 10000
	return string_format("resource/partner/%d.png", tonumber(bust_id))
end

-- 获取伙伴半身像资源2(小的，且伙伴类型不多，目前仅用于天界副本)
function PathTool.getPartnerBustRes_2( bust_id )
	bust_id = bust_id or 10090
	return string_format("resource/partnerbust/%d.png", tonumber(bust_id))
end

-- 获取变强的图标资源
function PathTool.getStrongerIconRes( icon_id )
	icon_id = icon_id or 1001
	return PathTool.checkRes(string_format("resource/strongericon/stronger_%d.png", tonumber(icon_id)))
end

-- 获取天界副本关卡图标
function PathTool.getHeavenCustomsIconRes( res_id )
	res_id = res_id or 1
	return string_format("resource/heavencustoms/heavencustoms_%d.png", tonumber(res_id))
end

-- 获取回归活动资源
function PathTool.getReturnActionRes(res_id, bool)
	if bool then
		return PathTool.checkRes(string_format("resource/bigbg/returnaction/%s.jpg", res_id))
	else
		return PathTool.checkRes(string_format("resource/bigbg/returnaction/%s.png", res_id))
	end
end

-- 获取家园建筑资源(time_type: 1白天 2晚上)
function PathTool.getHomeBuildRes( time_type, res_id )
	time_type = time_type or 1
	res_id = res_id or "build_1"
	return string_format("resource/homeworld/background/%d/%s.png", time_type, res_id)
end

-- 获取家园家具资源(场景中显示)
function PathTool.getFurnitureSceneRes( res_id )
	if not res_id or res_id == "" then return end
	return string_format("resource/homeworld/unit/%s.png", res_id)
end

-- 获取家园家具资源(商店、仓库等中显示)
function PathTool.getFurnitureNormalRes( res_id )
	if not res_id or res_id == "" then return end
	return PathTool.checkRes(string_format("resource/homeworld/furniture/%s.png", res_id))
end

-- 获取家园形象icon的资源
function PathTool.getFigureIconRes( res_id )
	if not res_id or res_id == "" then return end
	return string_format("resource/homeworld/figureicon/%s.png", res_id)
end

-- 获取家园家具套装icon的资源
function PathTool.getSuitIconRes( res_id )
	if not res_id or res_id == "" then return end
	return string_format("resource/homeworld/cover/%s.png", res_id)
end

-- 获取精灵蛋的资源
function PathTool.getElfinEggRes( res_id )
	res_id = res_id or 1
	return string_format("resource/elfin/eggicon/eggicon_%d.png", res_id)
end

-- 获取精灵古树的背景
function PathTool.getElfinTreeBgRes( res_id )
	res_id = res_id or 1
	return string_format("resource/elfin/elfin_tree_bg/elfin_tree_bg_%d.png", res_id)
end

-- 最终的头像保存路径
function PathTool.getHeadPath(free_res)
	return string.format("%sassets/src/photo/%s.jpg", cc.FileUtils:getInstance():getWritablePath(), free_res)
	-- return string.format("%sphoto/%s.jpg", cc.FileUtils:getInstance():getWritablePath(), free_res)
end

function PathTool.getHeadSavePath(free_res)
	return string.format("photo/%s.jpg", free_res)
end

-- 选择头像的目录
function PathTool.getPhotoPath()
	local path = string.format("%sassets/src/photo/", cc.FileUtils:getInstance():getWritablePath())
	-- local path = string.format("%sphoto/", cc.FileUtils:getInstance():getWritablePath())
	if not cc.FileUtils:getInstance():isDirectoryExist(path) then
		cc.FileUtils:getInstance():createDirectory(path)
	end
	return path
end