--
-- @Author: chk
-- @Date:   2018-08-23 16:33:15
--
GoodIconUtil = GoodIconUtil or class("GoodIconUtil",BaseManager)
local this = GoodIconUtil

function GoodIconUtil:ctor()
	GoodIconUtil.Instance = self
	self:Reset()
end

function GoodIconUtil:Reset()

end

function GoodIconUtil.GetInstance()
	if GoodIconUtil.Instance == nil then
		GoodIconUtil()
	end
	return GoodIconUtil.Instance
end


function GoodIconUtil:GetResNameByItemID(item_id)
	local cf = Config.db_item[item_id]
	if not cf then
		return
	end
	return "iconasset/" .. GoodIconUtil:GetABNameById(cf.icon),cf.icon
end

function GoodIconUtil:GetABNameById(iconId)
	local temp = Util.GetGoodsAssetBundleName(iconId)
    local abName = "icon_goods_" .. temp
    return abName
end

function GoodIconUtil:CreateIcon(cls,iconImg,iconId,is_fixed)
	local abName = self:GetABNameById(iconId)
	abName = "iconasset/" .. abName
	lua_resMgr:SetImageTexture(cls, iconImg, abName, tostring(iconId), is_fixed,nil,false)
end

--根据性别创建icon
function GoodIconUtil:CreateIconBySex(cls,iconImg,item_id,is_fixed,sex,custom_icon_id)

	local iconId = Config.db_item[item_id].icon
	if custom_icon_id then
		iconId = custom_icon_id
	end

	local iconTbl = LuaString2Table("{" .. iconId .. "}")

	if type(iconTbl) == "table" then
		local _sex = sex
		if _sex == nil then
			local roleData = RoleInfoModel.Instance:GetMainRoleData()
			_sex = roleData.gender
			sex = _sex
		end

		if iconTbl[sex] ~= nil then
			iconId = iconTbl[sex]
		else
			for i, v in pairs(iconTbl) do
				iconId = v
				break
			end
		end
	end

	self:CreateIcon(cls,iconImg,iconId,is_fixed)
end

function GoodIconUtil:GetGoodsName(item_id,need_color)
	local config = Config.db_item[item_id]
	if need_color then
		local color = ColorUtil.GetColor(config.color)
		return string.format("<color=#%s>%s</color>",color,config.name),color
	else
		return config.name,nil
	end
end

function GoodIconUtil:GetGoodsIconHtml(item_id,size)
	local abName,assetName = GoodIconUtil:GetResNameByItemID(item_id)
	size = size or 20
	return string.format("<quad name=%s:%s size=%s width=1 />",abName,assetName,size)
end