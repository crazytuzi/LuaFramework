--------------------------------------------------------
-- 物品预览数据
--------------------------------------------------------
PreviewData = PreviewData or BaseClass()


----------极品预览索引----------
PreviewData.SHOP_PREVIEW = 1 -- 商店
PreviewData.FIRE_VISION_PREVIEW = 2 -- 烈焰幻境
PreviewData.DRAGON_SOUL_PREVIEW = 3 -- 龙魂圣城
----------end----------

function PreviewData:__init()
	if PreviewData.Instance then
		ErrorLog("[PreviewData]:Attempt to create singleton twice!")
	end
	PreviewData.Instance = self

	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()

	self.index = 1 -- 物品预览索引
end

function PreviewData:__delete()
	PreviewData.Instance = nil
end

----------设置----------

-- 设置物品预览显示索引
function PreviewData:SetPreviewIndex(index)
	self.index = index
end

-- 获取物品预览列表
function PreviewData:GetPreViewList()
	local text = ""

	if self.index == PreviewData.SHOP_PREVIEW then
		text = "scripts/config/client/shop_preview_cfg"
	elseif self.index == PreviewData.FIRE_VISION_PREVIEW then
		text = "scripts/config/client/fire_vision_preview_cfg"
	elseif self.index == PreviewData.DRAGON_SOUL_PREVIEW then
		text = "scripts/config/client/dragon_soul_preview_cfg"
	end

	return ConfigManager.Instance:GetConfig(text)
end
--------------------
