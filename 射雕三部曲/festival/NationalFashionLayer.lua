--[[
	文件名：NationalFashionLayer.lua
	描述：绝学展示界面
	创建人：heguanghui
	创建时间：2017.9.26
--]]
local NationalFashionLayer = class("NationalFashionLayer", function (params)
	return display.newLayer()
end)

function NationalFashionLayer:ctor(params)
	params = params or {}
	-- 活动实体Id列表
	self.mActivityIdList = params.activityIdList
	-- 该活动的主模块Id
	self.mParentModuleId = params.parentModuleId
	-- 该页面的数据信息
	self.mLayerData = params.cacheData

    self:initUI()
end

--添加UI
function NationalFashionLayer:initUI()
	--页面父节点
	self.mParentLayer = ui.newStdLayer()
	self:addChild(self.mParentLayer)

	--背景
	local bgSprite = ui.newSprite("xn_87.jpg")
	bgSprite:setPosition(320, 568)
	self.mParentLayer:addChild(bgSprite)
	
	--返回按钮
    local closeBtn = ui.newButton({
        normalImage = "c_29.png",
        position = cc.p(594, 930),
        clickAction = function(pSender)
            LayerManager.addLayer({
                name = "home.HomeLayer"
            })
        end
    })
    self.mParentLayer:addChild(closeBtn)
    self:createSkillView()
end

function NationalFashionLayer:createSkillView()
	local fashionModel = FashionModel.items[19010022]
	--普攻
	local tempCardN = require("common.CardNode").new({
		allowClick = true,
		onClickCallback = function()
			self:showSkillDlg(fashionModel.NAID, false, cc.p(540, 845))
		end
	})
	tempCardN:setPosition(565, 845)
	tempCardN:setSkillAttack({modelId = fashionModel.NAID, icon = fashionModel.attackIcon .. ".png", isSkill = false}, {CardShowAttr.eBorder})
	self.mParentLayer:addChild(tempCardN)
	--技攻
	local tempCardR = require("common.CardNode").new({
		allowClick = true,
		onClickCallback = function()
			self:showSkillDlg(fashionModel.RAID, true, cc.p(540, 730))
		end
	})
	tempCardR:setPosition(565, 730)
	tempCardR:setSkillAttack({modelId = fashionModel.RAID, icon = fashionModel.skillIcon .. ".png", isSkill = true}, {CardShowAttr.eBorder})
	self.mParentLayer:addChild(tempCardR)
end

-- 创建时装的技能介绍框
function NationalFashionLayer:showSkillDlg(modelId, isSkill, pos)
	local dlgBgNode = cc.Node:create()
	dlgBgNode:setContentSize(cc.size(150, 200))
	self.mParentLayer:addChild(dlgBgNode, 1)

	-- 背景图
	local dlgBgSprite = ui.newSprite("zr_53.png")
	local dlgBgSize = dlgBgSprite:getContentSize()
	dlgBgSprite:setAnchorPoint(cc.p(1, 1))
	dlgBgSprite:setPosition(pos)
	dlgBgNode:addChild(dlgBgSprite)

	-- 技能图标
	local skillIcon = "c_71.png"
    if (isSkill ~= nil) and (isSkill == true) then
        skillIcon = "c_70.png"
    end
    local skillSprite = ui.newSprite(skillIcon)
    skillSprite:setAnchorPoint(cc.p(0, 0.5))
    skillSprite:setPosition(20, dlgBgSize.height - 40)
    dlgBgSprite:addChild(skillSprite)

    -- 技能名字
    local itemData = AttackModel.items[modelId] or {}
    local nameLabel = ui.newLabel({
        text = itemData.name or "",
        color = Enums.Color.eNormalYellow,
        size = 24,
    })
    nameLabel:setAnchorPoint(cc.p(0, 0.5))
    nameLabel:setPosition(58, dlgBgSize.height - 40)
    dlgBgSprite:addChild(nameLabel)

    -- 技能描述
    local attackList = string.splitBySep(itemData.intro or "", "#73430D")
    local attackText = ""
	for _,v in ipairs(attackList) do
		attackText = attackText .. Enums.Color.eNormalWhiteH .. v
	end
    local introLabel = ui.newLabel({
        text = attackText,
        color = Enums.Color.eNormalWhite,
        size = 22,
        align = ui.TEXT_ALIGN_LEFT,
        valign = ui.TEXT_VALIGN_TOP,
        dimensions = cc.size(dlgBgSize.width - 40, 0)
    })
    introLabel:setAnchorPoint(cc.p(0, 1))
    introLabel:setPosition(20, dlgBgSize.height - 70)
    dlgBgSprite:addChild(introLabel)

    -- 注册触摸关闭
    ui.registerSwallowTouch({
		node = dlgBgNode,
		allowTouch = true,
        endedEvent = function(touch, event)
        	dlgBgNode:removeFromParent()
        end
		})
end

--获取页面恢复信息
function NationalFashionLayer:getRestoreData()
	local retData = {
		activityIdList = self.mActivityIdList,
		parentModuleId = self.mParentModuleId,
		cacheData = self.mLayerData
	}

	return retData
end

return NationalFashionLayer